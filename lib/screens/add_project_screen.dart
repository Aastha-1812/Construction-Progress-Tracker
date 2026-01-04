import 'package:construction_progress_tracker/models/user_model.dart';
import 'package:flutter/material.dart';

import '../data/DBHelper.dart' as localDB;
import '../data/DBHelperCB.dart' as cdDB;
import '../models/project_db_model.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectFormState();
}

class _AddProjectFormState extends State<AddProjectScreen> {
  final TextEditingController projectNameCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();

  List<UserModel> managers = [];
  String? selectedManagerId;
  String? selectedManagerName;

  void loadManagers() async {
    final data = await localDB.DBHelper.getManagers();
    setState(() {
      managers = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadManagers();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      builder: (context, controller) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Add New Project",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),


                TextField(
                  controller: projectNameCtrl,
                  decoration: _inputDecoration("Project Name"),
                ),

                const SizedBox(height: 15),


                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: _inputDecoration("Select Manager"),
                  initialValue: selectedManagerId,
                  items: managers.map((manager) {
                    return DropdownMenuItem(
                      value: manager.id,
                      child: Text(manager.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedManagerId = value;
                      final selected = managers.firstWhere((m) => m.id == value);
                      selectedManagerName = selected.name;
                    });
                  },
                ),


                const SizedBox(height: 15),

                TextField(
                  controller: locationCtrl,
                  decoration: _inputDecoration("Location"),
                ),

                const SizedBox(height: 30),


                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A3DE8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      if (projectNameCtrl.text.isEmpty ||
                          selectedManagerId == null ||
                          locationCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("All fields are required")),
                        );
                        return;
                      }


                      final project = Project(
                        projectName: projectNameCtrl.text.trim(),
                        managerId: selectedManagerId!,
                        location: locationCtrl.text.trim(),
                        managerName: selectedManagerName!
                      );


                      await cdDB.DBHelperCB.addProject(project);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Project Added")),
                      );

                      Navigator.pop(context, true);
                    },
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
