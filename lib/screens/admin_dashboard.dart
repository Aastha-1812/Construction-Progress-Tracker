import 'dart:async';
import 'package:construction_progress_tracker/screens/admin_manager_complaint.dart';
import 'package:construction_progress_tracker/screens/help_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/kpi/kpi_bloc.dart';
import '../bloc/kpi/kpi_event.dart';
import '../bloc/kpi/kpi_state.dart';
import '../bloc/project/project_bloc.dart';
import '../bloc/project/project_event.dart';
import '../bloc/project/project_state.dart';
import '../constants/db_fields.dart';
import '../models/project_db_model.dart';
import '../screens/add_project_screen.dart';
import '../screens/admin_project_screen.dart';
import '../services/weather_service.dart';
import '../widgets/app_search_bar.dart';
import 'file_download_screen.dart';
import 'login_screen.dart';
import '../data/DBHelperCB.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final Color themeColor = const Color(0xFF6A3DE8);
  final ScrollController kpiScrollController = ScrollController();
  TextEditingController searchCtrl = TextEditingController();
  List<Project> filtered = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<KpiBloc>().add(LoadKpiData());
    context.read<ProjectBloc>().add(LoadProjects());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<ProjectBloc>().add(SearchProjectsEvent(query));
    });
  }
  String getEmoji(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains("cloud")) return "☁️";
    if (condition.contains("rain")) return "🌧️";
    if (condition.contains("clear")) return "☀️";
    if (condition.contains("storm")) return "⛈️";
    if (condition.contains("snow")) return "❄️";
    return "🌤️";
  }


  void _confirmDeleteProject(BuildContext context, String projectId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Project"),
        content: const Text("Are you sure you want to delete this project?\n\nThis will also remove all related entries."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              context.read<ProjectBloc>().add(DeleteProjectRequested(projectId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Project deleted successfully")),
              );


            },

            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: _buildDrawer(),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8560F0),
        onPressed: () async {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withAlpha(50),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (_) => AddProjectScreen(),
          );

          if (result == true) {
            context.read<ProjectBloc>().add(LoadProjects());
            context.read<KpiBloc>().add(LoadKpiData());
          }
        },
        child: const Icon(Icons.add, size: 32),
      ),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: StreamBuilder<Map<String, dynamic>>(
              stream: WeatherService().weatherStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: weatherTile(snapshot.data!),
                );
              },
            ),
          ),

          SliverToBoxAdapter(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text("Overview",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),


          SliverToBoxAdapter(
            child: SizedBox(
              height: 130,
              child: BlocBuilder<KpiBloc, KpiState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        kpiCard(Icons.people_alt_rounded, "${state.managers}", "Managers"),
                        kpiCard(Icons.apartment_rounded, "${state.projects}", "Projects"),
                        kpiCard(Icons.verified_outlined, "${state.completedProjects}", "Completed"),
                        kpiCard(Icons.bar_chart_rounded, "${state.reports}", "Reports"),
                        kpiCard(
                          Icons.download_rounded,
                          "Download",
                          "Files",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => FileDownloadScreen(themeColor : themeColor)),
                            );
                          },
                        ),

                        const SizedBox(width: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 20)),


          BlocBuilder<ProjectBloc, ProjectState>(
            builder: (context, state) {
              if (state is ProjectLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is ProjectError) {
                return SliverFillRemaining(
                  child: Center(child: Text("Error loading projects")),
                );
              }

              if (state is ProjectLoaded) {
                final projects = state.projects;

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index == 0){
                        return AppSearchBar(
                          controller: searchCtrl,
                          hintText: "Search by project or manager...",
                          onChanged: _onSearchChanged,
                        );
                      }
                      if (index == 1) return const SizedBox(height: 20);
                      if (index == 2){
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Projects",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        );}

                      final project = projects[index - 3];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: siteCard(
                          project.id,
                          project.projectName,
                          project.managerId,
                          project.location,
                          project.managerName,
                          project.status,
                              (newStatus) {
                            context.read<ProjectBloc>().add(
                              UpdateProjectStatusEvent(project.id, newStatus),
                            );
                            context.read<KpiBloc>().add(LoadKpiData());
                          },
                        ),
                      );
                    },
                   childCount: projects.length + 3,
                  ),
                );
              }

              return const SliverToBoxAdapter(child: SizedBox());
            },
          ),

          SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

    );
  }


  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColor, themeColor.withAlpha(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const Icon(Icons.menu, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello Admin",
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              SizedBox(height: 4),
              Text(
                "Dashboard",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget kpiCard(IconData icon, String count, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: themeColor),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }


  Widget siteCard(
      String projectId,
      String projectName,
      String managerId,
      String location,
      String managerName,
      String status,
      Function(String) onStatusChange,
      ) {
    bool isCompleted = status == StatusConstants.complete;

    return Stack(
      children: [
        Opacity(
          opacity: isCompleted ? 0.4 : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              border: Border.all(color: getStatusColor(status), width: 2),
              borderRadius: BorderRadius.circular(22),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6), // spacing since delete icon is above
                  Text(projectName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text("Manager Name: $managerName"),
                  Text("Location: $location"),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Status: $status",
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      DropdownButton<String>(
                        value: status,
                        items: [
                          StatusConstants.notStarted,
                          StatusConstants.inProgress,
                          StatusConstants.complete,
                        ]
                            .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s),
                        ))
                            .toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) onStatusChange(newStatus);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8560F0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminProjectScreen(
                              projectId: projectId,
                              projectName: projectName,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.remove_red_eye,
                          size: 16, color: Colors.white),
                      label: const Text("View",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          right: 8,
          top: 8,
          child: IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
              size: 24,
            ),
            onPressed: () {
              _confirmDeleteProject(context, projectId);

            },
          ),
        ),

      ],
    );

  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: themeColor),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text("Admin Menu",
                  style: TextStyle(color: Colors.white, fontSize: 22)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text("Complaints"),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdminComplaintManagersScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_sharp),
            title: const Text("Help&Support"),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => HelperScreen()));
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget weatherTile(Map<String, dynamic> data) {
    if (data.containsKey("error")) {
      return const ListTile(
        leading: Icon(Icons.error, color: Colors.red),
        title: Text("Weather unavailable"),
      );
    }

    final temp = data["main"]["temp"];
    final condition = data["weather"][0]["description"];

    return ListTile(
      leading: Text(getEmoji(condition), style: const TextStyle(fontSize: 40)),
      title: Text(
        "$temp°C",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        condition.toString().toUpperCase(),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case StatusConstants.notStarted:
        return Colors.grey;
      case StatusConstants.inProgress:
        return Colors.orange;
      case StatusConstants.complete:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
