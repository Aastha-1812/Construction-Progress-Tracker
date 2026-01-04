import 'package:equatable/equatable.dart';

abstract class EntryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EntryInitial extends EntryState {}

class EntrySaving extends EntryState {}

class EntrySaved extends EntryState {}

class EntrySaveFailure extends EntryState {
  final String message;
  EntrySaveFailure(this.message);

  @override
  List<Object?> get props => [message];
}
