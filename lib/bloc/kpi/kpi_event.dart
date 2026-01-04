import 'package:equatable/equatable.dart';

abstract class KpiEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadKpiData extends KpiEvent {}
