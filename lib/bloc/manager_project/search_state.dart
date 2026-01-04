import '../../models/project_db_model.dart';

abstract class ManagerProjectState {}

class ManagerProjectLoading extends ManagerProjectState {}

class ManagerProjectLoaded extends ManagerProjectState {
  final List<Project> allProjects;
  final List<Project> filteredProjects;
  final String managerId;

  ManagerProjectLoaded({
    required this.allProjects,
    required this.filteredProjects,
    required this.managerId,
  });
}

class ManagerProjectError extends ManagerProjectState {
  final String message;
  ManagerProjectError(this.message);
}
