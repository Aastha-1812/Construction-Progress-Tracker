import 'package:equatable/equatable.dart';
import '../../models/form_model.dart';

abstract class EntryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SaveEntryRequested extends EntryEvent {
  final EntryModel entry;
  SaveEntryRequested({required this.entry});

  @override
  List<Object?> get props => [entry];
}
