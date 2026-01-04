import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/DBHelperCB.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc() : super(ProjectLoading()) {
    on<LoadProjects>(_loadProjects);
    on<AddProjectEvent>(_addProject);
    on<UpdateProjectStatusEvent>(_updateProjectStatus);
    on<SearchProjectsEvent>((event, emit) async {
      emit(ProjectLoading());

      final results = await DBHelperCB.searchProjects(event.query);

      emit(ProjectLoaded(results));
    });


    on<DeleteProjectRequested>((event, emit) async {

      await DBHelperCB.deleteProjectAndEntries(event.projectId);

      final projects = await DBHelperCB.getAllProjects();

      emit(ProjectLoaded(projects));
    });


  }

  Future<void> _loadProjects(
      LoadProjects event, Emitter<ProjectState> emit) async {
    try {
      final projects = await DBHelperCB.getAllProjects();
      emit(ProjectLoaded(projects));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _addProject(
      AddProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      await DBHelperCB.addProject(event.project);
      add(LoadProjects());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _updateProjectStatus(UpdateProjectStatusEvent event,
      Emitter<ProjectState> emit) async {
    try {
      await DBHelperCB.updateProjectStatus(event.projectId, event.newStatus);
      add(LoadProjects());
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }
}
