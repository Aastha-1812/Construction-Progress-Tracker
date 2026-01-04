import 'package:cbl/cbl.dart';

import '../constants/db_fields.dart';

class WorkerIssueModel {
  final String id;
  final String projectId;
  final String workerId;
  final String workerName;
  final String category;
  final String issueText;
  final String? imagePath;
  final String? videoPath;
  final DateTime createdAt;

  WorkerIssueModel({
    required this.id,
    required this.projectId,
    required this.workerId,
    required this.workerName,
    required this.category,
    required this.issueText,
    this.imagePath,
    this.videoPath,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      WorkerIssueFields.projectId: projectId,
      WorkerIssueFields.workerId: workerId,
      WorkerIssueFields.workerName: workerName,
      WorkerIssueFields.category: category,
      WorkerIssueFields.issueText: issueText,
      WorkerIssueFields.imagePath: imagePath,
      WorkerIssueFields.videoPath: videoPath,
      WorkerIssueFields.createdAt: createdAt.toIso8601String(),
    };
  }

  MutableDocument toDocument() {
    return MutableDocument.withId(id, toMap());
  }

  factory WorkerIssueModel.fromMap(String id, Map<String, Object?> map) {
    return WorkerIssueModel(
      id: id,
      projectId: map[WorkerIssueFields.projectId] as String? ?? "",
      workerId: map[WorkerIssueFields.workerId] as String? ?? "",
      workerName: map[WorkerIssueFields.workerName] as String? ?? "",
      category: map[WorkerIssueFields.category] as String? ?? "",
      issueText: map[WorkerIssueFields.issueText] as String? ?? "",
      imagePath: map[WorkerIssueFields.imagePath] as String?,
      videoPath: map[WorkerIssueFields.videoPath] as String?,
      createdAt: DateTime.tryParse(
        map[WorkerIssueFields.createdAt] as String? ?? "",
      ) ??
          DateTime.now(),
    );
  }

}
