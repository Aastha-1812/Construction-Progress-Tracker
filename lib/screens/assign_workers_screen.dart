import 'package:flutter/material.dart';
import '../data/DBHelper.dart';
import '../data/DBHelperCB.dart';
import '../models/user_model.dart';
import '../models/worker_project_map.dart';

class AssignWorkersScreen extends StatefulWidget {
  final String projectId;

  const AssignWorkersScreen({super.key, required this.projectId});

  @override
  State<AssignWorkersScreen> createState() => _AssignWorkersScreenState();
}

class _AssignWorkersScreenState extends State<AssignWorkersScreen> {
  List<UserModel> allWorkers = [];
  Set<String> selectedWorkerIds = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadWorkers();
  }

  Future<void> loadWorkers() async {
    setState(() => loading = true);

    final workers = await DBHelper.getWorkers();

    final assignedIds = await DBHelperCB.getWorkersAssignedToProject(widget.projectId);
    selectedWorkerIds = assignedIds.map((e) => e.toString()).toSet();

    setState(() {
      allWorkers = workers;
      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.only(top: 12),
        itemCount: allWorkers.length,
        itemBuilder: (context, index) {
          final worker = allWorkers[index];
          final workerId = worker.id.toString();

          return CheckboxListTile(
            title: Text(worker.name),
            subtitle: Text(worker.email),
            activeColor: const Color(0xFF6A3DE8),

            value: selectedWorkerIds.contains(workerId),

              onChanged: (checked) async {
                setState(() {
                  if (checked == true) {
                    selectedWorkerIds.add(workerId);
                  } else {
                    selectedWorkerIds.remove(workerId);
                  }
                });
                if (checked == true) {
                  await DBHelperCB.addWorkerProjectMap(WorkerProjectMap(workerId: workerId, projectId: widget.projectId),
                  );
                } else {
                  await DBHelperCB.removeWorkerFromProject(workerId, widget.projectId);
                }
              }

          );
        },
      ),


    );
  }
}
