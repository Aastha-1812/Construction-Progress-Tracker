import 'package:cbl/cbl.dart';
import 'package:uuid/uuid.dart';
import '../constants/db_fields.dart';

var uuid = Uuid();

class Project {
  String id;
  String projectName;
  String managerId;
  String managerName;
  String location;
  String status;

  Project({
    String? id,
    required this.projectName,
    required this.managerId,
    required this.managerName,
    required this.location,
    this.status = ProjectFields.defaultStatus,
  }) : id = id ?? uuid.v4();


  Map<String, Object?> toMap() {
    return {
      ProjectFields.projectName: projectName,
      ProjectFields.managerId: managerId,
      ProjectFields.managerName: managerName,
      ProjectFields.location: location,
      ProjectFields.status: status,
    };
  }


  MutableDocument toDocument() {
    return MutableDocument.withId(id, toMap());
  }


  factory Project.fromMap(String id, Map<String, Object?> map) {
    return Project(
      id: id,
      projectName: map[ProjectFields.projectName] as String? ?? '',
      managerId: map[ProjectFields.managerId] as String? ?? '',
      managerName: map[ProjectFields.managerName] as String? ?? '',
      location: map[ProjectFields.location] as String? ?? '',
      status: map[ProjectFields.status] as String? ??
          ProjectFields.defaultStatus,
    );
  }
}
