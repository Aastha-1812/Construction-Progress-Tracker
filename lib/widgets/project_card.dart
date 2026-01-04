import 'package:flutter/material.dart';
import '../models/project_db_model.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final bool showStatus;
  final bool showAssignedInfo;
  final String? assignedBy;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.showStatus = false,
    this.showAssignedInfo = false,
    this.assignedBy,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  project.projectName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                if (showStatus) _statusBadge(project.status),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.place, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  project.location,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (showAssignedInfo && assignedBy != null)
              Row(
                children: [
                  const Icon(Icons.person, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  RichText(
                    text: TextSpan(
                      text: "Assigned by: ",
                      style: const TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: assignedBy,
                          style: TextStyle(
                            color: Color(0xFF6A3DE8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg = Colors.grey.shade300;
    Color text = Colors.black54;

    if (status == "Complete") {
      bg = Colors.green.shade100;
      text = Colors.green.shade800;
    } else if (status == "In Progress") {
      bg = Colors.orange.shade100;
      text = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
