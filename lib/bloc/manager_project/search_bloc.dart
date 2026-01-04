import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/DBHelperCB.dart';
import 'search_event.dart';
import 'search_state.dart';

class ManagerProjectBloc extends Bloc<ManagerProjectEvent, ManagerProjectState> {
  ManagerProjectBloc() : super(ManagerProjectLoading()) {
    on<LoadManagerProjects>(_loadProjects);
    on<SearchManagerProjects>(_searchProjects);
  }


  Future<void> _loadProjects(LoadManagerProjects event, Emitter<ManagerProjectState> emit) async {
    emit(ManagerProjectLoading());

    try {
      final projects = await DBHelperCB.getProjectsForManager(event.managerId);

      emit(ManagerProjectLoaded(
        allProjects: projects,
        filteredProjects: projects,
        managerId: event.managerId,
      ));
    } catch (e) {
      emit(ManagerProjectError(e.toString()));
    }
  }

  Future<void> _searchProjects(SearchManagerProjects event, Emitter<ManagerProjectState> emit,) async {
    emit(ManagerProjectLoading());

    try {
      if (event.query.trim().isEmpty) {
        final all = await DBHelperCB.getProjectsForManager(event.managerId);

        emit(ManagerProjectLoaded(
          allProjects: all,
          filteredProjects: all,
          managerId: event.managerId,
        ));
        return;
      }

      final results = await DBHelperCB.searchProjectsForManager(
        event.managerId,
        event.query,
      );

      final all = await DBHelperCB.getProjectsForManager(event.managerId);

      emit(ManagerProjectLoaded(
        allProjects: all,
        filteredProjects: results,
        managerId: event.managerId,
      ));
    } catch (e) {
      emit(ManagerProjectError(e.toString()));
    }
  }
}
