import 'package:cbl/cbl.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class WorkerProjectMap {
  final String id;
  final String workerId;
  final String projectId;
  final DateTime assignedAt;

  WorkerProjectMap({
    String? id,
    required this.workerId,
    required this.projectId,
    DateTime? assignedAt,
  })  : id = id ?? uuid.v4(),
        assignedAt = assignedAt ?? DateTime.now();

  Map<String, Object?> toMap() {
    return {
      "workerId": workerId,
      "projectId": projectId,
      "assignedAt": assignedAt.toIso8601String(),
    };
  }

  MutableDocument toDocument() {
    return MutableDocument.withId(id, toMap());
  }

  factory WorkerProjectMap.fromMap(String id, Map<String, Object?> map) {
    return WorkerProjectMap(
      id: id,
      workerId: map["workerId"] as String,
      projectId: map["projectId"] as String,
      assignedAt: DateTime.parse(map["assignedAt"] as String),
    );
  }
}
