import 'package:uuid/uuid.dart';

class WorkerManagerComplaint {
  final String id;
  final String workerId;
  final String workerName;
  final String managerId;
  final String managerName;
  final String message;
  final int timestamp;

  WorkerManagerComplaint({
    String? id,
    required this.workerId,
    required this.workerName,
    required this.managerId,
    required this.managerName,
    required this.message,
    int? timestamp,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "workerId": workerId,
      "workerName": workerName,
      "managerId": managerId,
      "managerName": managerName,
      "message": message,
      "timestamp": timestamp,
    };
  }

  factory WorkerManagerComplaint.fromMap(Map<String, dynamic> map) {
    return WorkerManagerComplaint(
      id: map["id"],
      workerId: map["workerId"],
      workerName: map["workerName"],
      managerId: map["managerId"],
      managerName: map["managerName"],
      message: map["message"],
      timestamp: map["timestamp"],
    );
  }
}
