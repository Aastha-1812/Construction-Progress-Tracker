import 'package:flutter/material.dart';
import '../data/DBHelper.dart';
import '../models/worker_manager_complain_model.dart';
import '../data/DBHelperCB.dart' as cbDB;
import '../models/project_db_model.dart';

class WorkerComplaintScreen extends StatefulWidget {
  final String workerId;
  final String workerName;

  const WorkerComplaintScreen({
    super.key,
    required this.workerId,
    required this.workerName,
  });

  @override
  State<WorkerComplaintScreen> createState() => _WorkerComplaintScreenState();
}

class _WorkerComplaintScreenState extends State<WorkerComplaintScreen> {
  final Color themeColor = const Color(0xFF6A3DE8);

  List<Project> workerProjects = [];
  List<Map<String, String>> managers = [];

  String? selectedManagerId;
  String? selectedManagerName;

  final TextEditingController _complaintController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadManagers();
  }
  Future<void> submitComplaint() async {
    if (selectedManagerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a manager")),
      );
      return;
    }

    if (_complaintController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complaint cannot be empty")),
      );
      return;
    }

    final complaint = WorkerManagerComplaint(
      workerId: widget.workerId,
      workerName: widget.workerName,
      managerId: selectedManagerId!,
      managerName: selectedManagerName!,
      message: _complaintController.text.trim(),
    );


    await DBHelper.addComplaint(complaint.toMap());


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Complaint submitted successfully")),
    );

    Navigator.pop(context);
  }

  Future<void> loadManagers() async {
    workerProjects =
    await cbDB.DBHelperCB.getProjectsForWorker(widget.workerId);

    final Set<String> added = {};

    for (var project in workerProjects) {
      if (!added.contains(project.managerId)) {
        added.add(project.managerId);

        managers.add({
          "id": project.managerId,
          "name": project.managerName,
        });
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text("Submit Complaint", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Manager",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: selectedManagerId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12),
              ),
              hint: const Text("Choose manager"),
              items: managers.map((m) {
                return DropdownMenuItem(
                  value: m["id"],
                  child: Text(m["name"]!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedManagerId = value;
                  selectedManagerName = managers.firstWhere((m) => m["id"] == value)["name"];
                });
              },
            ),

            const SizedBox(height: 20),

            const Text(
              "Complaint Message",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _complaintController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Write your complaint here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: submitComplaint,
                child: const Text(
                  "Submit Complaint",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
