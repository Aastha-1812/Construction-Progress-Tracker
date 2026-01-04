import 'package:construction_progress_tracker/bloc/project_form/project_form_event.dart';
import 'package:construction_progress_tracker/bloc/project_form/project_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/DBHelperCB.dart';


class EntryBloc extends Bloc<EntryEvent, EntryState> {
  EntryBloc() : super(EntryInitial()) {
    on<SaveEntryRequested>(_onSaveEntry);
  }

  Future<void> _onSaveEntry(SaveEntryRequested event, Emitter<EntryState> emit,) async
  {
    emit(EntrySaving());
    try {
      await DBHelperCB.addEntry(event.entry);
      emit(EntrySaved());
    } catch (e) {
      emit(EntrySaveFailure(e.toString()));
    }
  }
}
