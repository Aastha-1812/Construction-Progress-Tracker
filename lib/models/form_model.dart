import 'package:cbl/cbl.dart';
import '../constants/db_fields.dart';

class EntryModel {
  String id;
  final String projectId;
  final int workers;
  final String issues;
  final int progress;
  final String? imagePath;
  final String? videoPath;
  final DateTime createdAt;

  EntryModel({
    this.id = '',
    required this.projectId,
    required this.workers,
    required this.issues,
    required this.progress,
    this.imagePath,
    this.videoPath,
    required this.createdAt,
  });


  Map<String, Object?> toMap() => {
    EntryFields.projectId: projectId,
    EntryFields.workers: workers,
    EntryFields.issues: issues,
    EntryFields.progress: progress,
    EntryFields.imagePath: imagePath,
    EntryFields.videoPath: videoPath,
    EntryFields.createdAt: createdAt.toIso8601String(),
  };


  MutableDocument toDocument() {
    return id.isEmpty
        ? MutableDocument(toMap())
        : MutableDocument.withId(id, toMap());
  }


  factory EntryModel.fromMap(String id, Map<String, Object?> map) {
    return EntryModel(
      id: id,
      projectId: map[EntryFields.projectId] as String,
      workers: map[EntryFields.workers] as int,
      issues: map[EntryFields.issues] as String,
      progress: map[EntryFields.progress] as int,
      imagePath: map[EntryFields.imagePath] as String?,
      videoPath: map[EntryFields.videoPath] as String?,
      createdAt: DateTime.parse(map[EntryFields.createdAt] as String),
    );
  }
}
