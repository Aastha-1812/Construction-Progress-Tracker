import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/manager_project/search_bloc.dart';
import '../bloc/manager_project/search_event.dart';
import '../bloc/manager_project/search_state.dart';
import '../constants/db_fields.dart';
import '../models/user_model.dart';
import '../data/DBHelper.dart';
import '../models/project_db_model.dart';
import '../data/DBHelperCB.dart' as cdDB;
import '../screens/manager_project_screen.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/project_card.dart';
import 'help_support_screen.dart';
import 'profile_page.dart';
import 'login_screen.dart';

class ManagerDashboard extends StatefulWidget {
  final String managerId;
  final String managerName;

  const ManagerDashboard({
    super.key,
    required this.managerId,
    required this.managerName,
  });

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard>
    with TickerProviderStateMixin {
  final Color themeColor = const Color(0xFF6A3DE8);
  UserModel? user;
  bool isLoading = true;

  late AnimationController _controller;
  late Animation<double> fadeAnimation;

  TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUser();
    context.read<ManagerProjectBloc>().add(
      LoadManagerProjects(widget.managerId),
    );


    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    searchCtrl.dispose();
    super.dispose();
  }


  Future<void> loadUser() async {
    final fetched = await DBHelper.getUserById(widget.managerId);
    setState(() => user = fetched);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            AppSearchBar(
              controller: searchCtrl,
              hintText: "Search projects...",
              onChanged: (query) {
                context.read<ManagerProjectBloc>().add(
                  SearchManagerProjects(widget.managerId, query),
                );
              },
            ),


            const SizedBox(height: 16),


            Expanded(
              child: BlocBuilder<ManagerProjectBloc, ManagerProjectState>(
                builder: (context, state) {
                  if (state is ManagerProjectLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ManagerProjectError) {
                    return Center(
                      child: Text(
                        "Error: ${state.message}",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (state is ManagerProjectLoaded) {
                    final projects = state.filteredProjects;

                    if (projects.isEmpty) {
                      return const Center(
                        child: Text(
                          "No matching projects",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }

                    _controller.forward();

                    return FadeTransition(
                      opacity: fadeAnimation,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final p = projects[index];

                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _controller,
                                curve: Interval(index * 0.15, 1.0, curve: Curves.easeOut),
                              ),
                            ),
                            child: ProjectCard(
                            project: p,
                            showStatus: true,
                            showAssignedInfo: true,
                            onTap: () {
                              if (p.status != "Complete") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ManagerProjectScreen(
                                      projectId: p.id,
                                      projectName: p.projectName,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          );
                        },
                      ),
                    );
                  }

                  // fallback
                  return Container();
                },
              ),
            )
            ,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor,
            themeColor.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const Icon(Icons.menu, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 16),

          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            backgroundImage: (user != null && user!.avatarPath.isNotEmpty)
                ? FileImage(File(user!.avatarPath))
                : null,
            child: (user == null || user!.avatarPath.isEmpty)
                ? const Icon(Icons.person, color: Colors.white, size: 30)
                : null,
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, ${widget.managerName}",
                style:
                const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 4),
              const Text(
                "Your Projects",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }




  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration:
            const BoxDecoration(color: Color(0xFF6A3DE8)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: (user != null &&
                      user!.avatarPath.isNotEmpty)
                      ? FileImage(File(user!.avatarPath))
                      : null,
                  child: (user == null ||
                      user!.avatarPath.isEmpty)
                      ? const Icon(Icons.person,
                      color: Colors.white, size: 40)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.managerName,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProfilePage(managerId: widget.managerId),
                ),
              ).then((_) => loadUser());
            },
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Help & Support"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => HelperScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              await PrefsHelper.clearLogin();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
