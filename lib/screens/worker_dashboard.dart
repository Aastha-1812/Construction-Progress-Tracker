import 'dart:io';
import 'package:construction_progress_tracker/screens/worker_complaint_screen.dart';
import 'package:construction_progress_tracker/screens/worker_issue_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/db_fields.dart';
import '../models/user_model.dart';
import '../data/DBHelper.dart';
import '../models/project_db_model.dart';
import '../data/DBHelperCB.dart' as cdDB;
import '../widgets/project_card.dart';
import 'login_screen.dart';
import 'help_support_screen.dart';

class WorkerDashboard extends StatefulWidget {
  final String workerId;
  final String workerName;

  const WorkerDashboard({
    super.key,
    required this.workerId,
    required this.workerName,
  });

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  final Color themeColor = const Color(0xFF6A3DE8);

  List<Project> assignedProjects = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAssignedProjects();
  }



  Future<void> loadAssignedProjects() async {
    setState(() => isLoading = true);

    assignedProjects =
    await cdDB.DBHelperCB.getProjectsForWorker(widget.workerId);

    setState(() => isLoading = false);
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
            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : assignedProjects.isEmpty
                  ? const Center(
                child: Text(
                  "No projects assigned yet",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: assignedProjects.length,
                itemBuilder: (context, index) {
                  final p = assignedProjects[index];
                  return ProjectCard(
                    project: p,
                    showStatus: true,
                    showAssignedInfo: true,
                    assignedBy: p.managerName,
                    onTap: () {
                      if (p.status == "Complete") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("This project is marked completed")),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkerIssueScreen(
                            projectId: p.id,
                            projectName: p.projectName,
                            workerId: widget.workerId,
                            workerName: widget.workerName,
                          ),
                        ),
                      );
                    },
                  );

                },
              ),
            )
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
            color: themeColor.withValues(alpha: 0.4),
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

          const SizedBox(width: 18),

          // STATIC WORKER ICON (no avatar)
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: const Icon(Icons.construction, size: 30, color: Colors.white),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, ${widget.workerName}",
                style: const TextStyle(color: Colors.white70, fontSize: 15),
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
          )
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
            decoration: const BoxDecoration(color: Color(0xFF6A3DE8)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.construction,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.workerName,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text("Complaints"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WorkerComplaintScreen(workerId: widget.workerId, workerName: widget.workerName)),
              );
            },
          ),


          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Help & Support"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HelperScreen()),
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
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

}


