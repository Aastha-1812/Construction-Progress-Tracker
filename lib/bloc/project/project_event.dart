import 'package:equatable/equatable.dart';
import '../../models/project_db_model.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjects extends ProjectEvent {}

class AddProjectEvent extends ProjectEvent {
  final Project project;

  const AddProjectEvent(this.project);

  @override
  List<Object?> get props => [project];
}


class UpdateProjectStatusEvent extends ProjectEvent {
  final String projectId;
  final String newStatus;

  const UpdateProjectStatusEvent(this.projectId, this.newStatus);

  @override
  List<Object?> get props => [projectId, newStatus];
}

class SearchProjectsEvent extends ProjectEvent {
  final String query;
  SearchProjectsEvent(this.query);
}

class DeleteProjectRequested extends ProjectEvent {
  final String projectId;
  const DeleteProjectRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

