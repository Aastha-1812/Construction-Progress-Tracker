abstract class ManagerProjectEvent {}

class LoadManagerProjects extends ManagerProjectEvent {
  final String managerId;
  LoadManagerProjects(this.managerId);
}

class SearchManagerProjects extends ManagerProjectEvent {
  final String managerId;
  final String query;
  SearchManagerProjects(this.managerId, this.query);
}
