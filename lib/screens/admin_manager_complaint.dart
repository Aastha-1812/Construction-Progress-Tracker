import 'package:flutter/material.dart';
import '../data/DBHelper.dart';
import 'admin_complaint_list.dart';

class AdminComplaintManagersScreen extends StatefulWidget {
  const AdminComplaintManagersScreen({super.key});

  @override
  State<AdminComplaintManagersScreen> createState() =>
      _AdminComplaintManagersScreenState();
}

class _AdminComplaintManagersScreenState
    extends State<AdminComplaintManagersScreen> {

  final Color themeColor = const Color(0xFF6A3DE8);

  bool isLoading = true;
  List<Map<String, dynamic>> managers = [];

  @override
  void initState() {
    super.initState();
    loadManagersWithComplaintCounts();
  }

  Future<void> loadManagersWithComplaintCounts() async {
    final grouped = await DBHelper.getComplaintsGroupedByManager();

    List<Map<String, dynamic>> temp = [];

    grouped.forEach((managerId, complaintList) {
      if (complaintList.isNotEmpty) {
        temp.add({
          "managerId": managerId,
          "managerName": complaintList.first["managerName"],
          "complaintCount": complaintList.length,
        });
      }
    });

    setState(() {
      managers = temp;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 4,
        title: const Text(
          "Complaints",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : managers.isEmpty
          ? const Center(
        child: Text("No complaints submitted yet",
            style: TextStyle(fontSize: 18, color: Colors.grey)),
      )
          : ListView.builder(
        itemCount: managers.length,
        itemBuilder: (context, index) {
          final manager = managers[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 2,
            shadowColor: themeColor.withValues(alpha: 0.2),
            child: ListTile(
              title: Text(
                manager["managerName"],
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "${manager["complaintCount"]} Complaints",
                style: const TextStyle(color: Colors.red),
              ),
              trailing: const Icon(Icons.chevron_right),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminComplaintListScreen(
                      managerId: manager["managerId"],
                      managerName: manager["managerName"],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
