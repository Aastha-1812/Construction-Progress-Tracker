import 'package:equatable/equatable.dart';

class KpiState extends Equatable {
  final int managers;
  final int projects;
  final int completedProjects;
  final int reports;

  const KpiState({
    required this.managers,
    required this.projects,
    required this.completedProjects,
    required this.reports,
  });

  factory KpiState.initial() => const KpiState(
    managers: 0,
    projects: 0,
    completedProjects: 0,
    reports: 0,
  );

  KpiState copyWith({
    int? managers,
    int? projects,
    int? completedProjects,
    int? reports,
  }) {
    return KpiState(
      managers: managers ?? this.managers,
      projects: projects ?? this.projects,
      completedProjects: completedProjects ?? this.completedProjects,
      reports: reports ?? this.reports,
    );
  }

  @override
  List<Object?> get props => [managers, projects, completedProjects, reports];
}
