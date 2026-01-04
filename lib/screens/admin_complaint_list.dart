import 'package:flutter/material.dart';
import '../data/DBHelper.dart';

class AdminComplaintListScreen extends StatefulWidget {
  final String managerId;
  final String managerName;

  const AdminComplaintListScreen({
    super.key,
    required this.managerId,
    required this.managerName,
  });

  @override
  State<AdminComplaintListScreen> createState() =>
      _AdminComplaintListScreenState();
}

class _AdminComplaintListScreenState extends State<AdminComplaintListScreen> {
  final Color themeColor = const Color(0xFF6A3DE8);

  bool isLoading = true;
  List<Map<String, dynamic>> complaints = [];

  @override
  void initState() {
    super.initState();
    loadComplaints();
  }

  Future<void> loadComplaints() async {
    final result = await DBHelper.getComplaintsForManager(widget.managerId);

    setState(() {
      complaints = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 4,
        title: Text(
          "Complaints - ${widget.managerName}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : complaints.isEmpty
          ? const Center(
        child: Text(
          "No complaints found",
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaints[index];

          return Card(
            margin: const EdgeInsets.all(12),
            elevation: 2,
            shadowColor: themeColor.withValues(alpha: 0.2),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint["workerName"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    complaint["message"],
                    style: const TextStyle(fontSize: 15),
                  ),

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _formatTimestamp(complaint["timestamp"]),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

   String _formatTimestamp(int millis) {
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return "${_month(date.month)} ${date.day}, ${date.year}";
  }

  String _month(int m) {
    const months = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m];
  }
}
