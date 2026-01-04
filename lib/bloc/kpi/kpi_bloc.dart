import 'package:bloc/bloc.dart';
import 'package:cbl/cbl.dart';
import '../../data/DBHelper.dart';
import '../../data/DBHelperCB.dart';
import '../../data/DBProviderCb.dart';
import '../../constants/db_fields.dart';
import 'kpi_event.dart';
import 'kpi_state.dart';

class KpiBloc extends Bloc<KpiEvent, KpiState> {
  KpiBloc() : super(KpiState.initial()) {
    on<LoadKpiData>(_loadData);
  }

  Future<void> _loadData(LoadKpiData event, Emitter<KpiState> emit) async {


    final managersList = await DBHelper.getManagers();
    final managersCount = managersList.length;
    final projectsList = await DBHelperCB.getAllProjects();
    final projectsCount = projectsList.length;
    final completedCount = projectsList
        .where((p) => p.status == StatusConstants.complete)
        .length;
    final entriesCol = await DatabaseHelper.entries();

    final query = QueryBuilder()
        .select(SelectResult.expression(Meta.id))
        .from(DataSource.collection(entriesCol));

    final result = await query.execute();
    final rows = await result.allResults();
    final reportsCount = rows.length;
    emit(state.copyWith(
      managers: managersCount,
      projects: projectsCount,
      completedProjects: completedCount,
      reports: reportsCount,
    ));
  }
}
