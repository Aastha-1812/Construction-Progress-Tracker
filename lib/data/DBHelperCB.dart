import 'dart:core';
import 'package:cbl/cbl.dart';
import '../models/worker_issue_model.dart';
import '../models/worker_project_map.dart';
import 'DBHelper.dart';
import 'DBProviderCb.dart';
import '../models/project_db_model.dart';
import '../models/form_model.dart';
import '../constants/db_fields.dart';



class DBHelperCB {

  static Future<void> addProject(Project project) async {
    final col = await DatabaseHelper.projects();
    await col.saveDocument(project.toDocument());
  }


  static Future<List<Project>> getAllProjects() async {
    final col = await DatabaseHelper.projects();

    final query = QueryBuilder()
        .select(
      SelectResult.all(),
      SelectResult.expression(Meta.id),
    )
        .from(DataSource.collection(col))
        .orderBy(
      Ordering.property(ProjectFields.projectName).ascending(),
    );

    final result = await query.execute();
    final rows = await result.allResults();

    return rows.map((row) {
      final map = row.dictionary(0)!.toPlainMap();
      final id = row.string(1)!;

      return Project.fromMap(id, map);
    }).toList();
  }


  static Future<List<Project>> getProjectsForManager(String managerId) async {
    final col = await DatabaseHelper.projects();

    final query = QueryBuilder()
        .select(
      SelectResult.all(),
      SelectResult.expression(Meta.id),
    )
        .from(DataSource.collection(col))
        .where(
      Expression.property(ProjectFields.managerId)
          .equalTo(Expression.string(managerId)),
    );

    final result = await query.execute();
    final rows = await result.allResults();

    return rows.map((row) {
      final map = row.dictionary(0)!.toPlainMap();
      final id = row.string(1)!;

      return Project.fromMap(id, map);
    }).toList();
  }


  static Future<void> addEntry(EntryModel entry) async {
    final col = await DatabaseHelper.entries();
    await col.saveDocument(entry.toDocument());
  }


  static Future<List<EntryModel>> getEntriesForProject(String projectId) async {
    final col = await DatabaseHelper.entries();

    final query = QueryBuilder()
        .select(
      SelectResult.all(),
      SelectResult.expression(Meta.id),
    )
        .from(DataSource.collection(col))
        .where(
      Expression.property(EntryFields.projectId)
          .equalTo(Expression.string(projectId)),
    )
        .orderBy(
      Ordering.property(EntryFields.createdAt).descending(),
    );

    final result = await query.execute();
    final rows = await result.allResults();

    return rows.map((row) {
      final map = row.dictionary(0)!.toPlainMap();
      final id = row.string(1)!;

      return EntryModel.fromMap(id, map);
    }).toList();
  }

  static Future<void> updateProjectStatus(String projectId, String newStatus) async {
    final col = await DatabaseHelper.projects();

    final doc = await col.document(projectId);
    if (doc == null) return;

    final mutable = doc.toMutable();
    mutable.setString(key: ProjectFields.status, newStatus);

    await col.saveDocument(mutable);
  }


  static Future<List<Project>> searchProjects(String query) async {
    final col = await DatabaseHelper.projects();
    final q = query.toLowerCase();

    final searchQuery = QueryBuilder()
        .select(
      SelectResult.expression(Meta.id).as(ProjectFields.id),
      SelectResult.property(ProjectFields.projectName),
      SelectResult.property(ProjectFields.managerId),
      SelectResult.property(ProjectFields.managerName),
      SelectResult.property(ProjectFields.location),
      SelectResult.property(ProjectFields.status),
    )
        .from(DataSource.collection(col))
        .where(
      Function_.lower(Expression.property(ProjectFields.projectName))
          .like(Expression.string("%$q%"))
          .or(
        Function_.lower(Expression.property(ProjectFields.managerName))
            .like(Expression.string("%$q%")),
      ),
    )
        .orderBy(
      Ordering.property(ProjectFields.projectName).ascending(),
    );

    final result = await searchQuery.execute();
    final rows = await result.allResults();

    return rows.map((row) {
      return Project(
        id: row.string(ProjectFields.id) ?? "",
        projectName: row.string(ProjectFields.projectName) ?? "",
        managerId: row.string(ProjectFields.managerId) ?? "",
        managerName: row.string(ProjectFields.managerName) ?? "",
        location: row.string(ProjectFields.location) ?? "",
        status: row.string(ProjectFields.status) ?? "",
      );
    }).toList();
  }

  static Future<void> deleteProjectAndEntries(String projectId) async {
    final projectsCol = await DatabaseHelper.projects();
    final entriesCol = await DatabaseHelper.entries();


    final projectDoc = await projectsCol.document(projectId);
    if (projectDoc != null) {
      await projectsCol.deleteDocument(projectDoc);
    }


    final query = QueryBuilder()
        .select(SelectResult.expression(Meta.id))
        .from(DataSource.collection(entriesCol))
        .where(Expression.property(EntryFields.projectId)
        .equalTo(Expression.string(projectId)));

    final result = await query.execute();
    final rows = await result.allResults();


    for (var row in rows) {
      final entryId = row.string(0);
      final entryDoc = await entriesCol.document(entryId!);
      if (entryDoc != null) {
        await entriesCol.deleteDocument(entryDoc);
      }
    }
  }


  static Future<void> addWorkerProjectMap(WorkerProjectMap mapping) async {
    final col = await DatabaseHelper.workerAssignments();

    final query = QueryBuilder()
        .select(SelectResult.expression(Meta.id))
        .from(DataSource.collection(col))
        .where(
      Expression.property("workerId").equalTo(Expression.string(mapping.workerId))
          .and(Expression.property("projectId").equalTo(Expression.string(mapping.projectId))),
    );

    final result = await query.execute();
    final rows = await result.allResults();

    if (rows.isNotEmpty) {
      return;
    }

    await col.saveDocument(mapping.toDocument());
  }


  static Future<Project?> getProjectById(String id) async {
    final col = await DatabaseHelper.projects();
    final doc = await col.document(id);

    if (doc == null) return null;

    final map = doc.toPlainMap();
    return Project.fromMap(id, map);
  }


  static Future<List<Project>> getProjectsForWorker(String workerId) async {
    final col = await DatabaseHelper.workerAssignments();

    final query = QueryBuilder()
        .select(
      SelectResult.all(),
      SelectResult.expression(Meta.id),
    )
        .from(DataSource.collection(col))
        .where(
      Expression.property("workerId")
          .equalTo(Expression.string(workerId)),
    );

    final result = await query.execute();
    final rows = await result.allResults();

    if (rows.isEmpty) return [];

    List<Project> projects = [];

    for (var row in rows) {
      final map = row.dictionary(0)!.toPlainMap();
      final projectId = map["projectId"] as String?;

      if (projectId == null) continue;

      final project = await getProjectById(projectId);
      if (project != null) {
        projects.add(project);
      }
    }

    return projects;
  }

  static Future<List<String>> getWorkersAssignedToProject(String projectId) async {
    final col = await DatabaseHelper.workerAssignments();

    final query = QueryBuilder()
        .select(SelectResult.all())
        .from(DataSource.collection(col))
        .where(
      Expression.property("projectId")
          .equalTo(Expression.string(projectId)),
    );

    final result = await query.execute();
    final rows = await result.allResults();

    List<String> workerIds = [];

    for (var row in rows) {
      final map = row.dictionary(0)!.toPlainMap();
      final workerId = map["workerId"] as String?;
      if (workerId != null) {
        workerIds.add(workerId);
      }
    }
    return workerIds;
  }

  static Future<void> removeWorkerFromProject(String workerId, String projectId) async {
    final col = await DatabaseHelper.workerAssignments();

    final query = QueryBuilder()
        .select(SelectResult.expression(Meta.id))
        .from(DataSource.collection(col))
        .where(
      Expression.property("workerId").equalTo(Expression.string(workerId))
          .and(Expression.property("projectId").equalTo(Expression.string(projectId))),
    );

    final result = await query.execute();
    final rows = await result.allResults();

    for (var row in rows) {
      final id = row.string(0);
      final doc = await col.document(id!);
      if (doc != null) {
        await col.deleteDocument(doc);
      }
    }
  }

  static Future<void> addWorkerIssue(WorkerIssueModel issue) async {
    final col = await DatabaseHelper.workerIssues();

    final doc = issue.toDocument();

    await col.saveDocument(doc);

  }

  static Future<Map<String, int>> getIssueCountsByCategory(String projectId) async {
    final col = await DatabaseHelper.workerIssues();

    final query = QueryBuilder()
        .select(
      SelectResult.property(WorkerIssueFields.category),
      SelectResult.expression(
        Function_.count(Expression.all()),
      ).as("count"),
    ).from(DataSource.collection(col))
        .where(
      Expression.property(WorkerIssueFields.projectId)
          .equalTo(Expression.string(projectId)),
    ).groupBy(
      Expression.property(WorkerIssueFields.category),
    );

    final result = await query.execute();
    final rows = await result.allResults();

    final Map<String, int> categoryMap = {};

    for (var row in rows) {
      final category = row.string(WorkerIssueFields.category);
      final count = row.integer("count");
      if (category != null) {
        categoryMap[category] = count;
      }
    }

    return categoryMap;
  }


  static Future<List<WorkerIssueModel>> getIssuesForCategory(String projectId, String category) async {

    final col = await DatabaseHelper.workerIssues();

    final query = QueryBuilder()
        .select(
      SelectResult.all(),
      SelectResult.expression(Meta.id),
    )
        .from(DataSource.collection(col))
        .where(
      Expression.property(WorkerIssueFields.projectId)
          .equalTo(Expression.string(projectId))
          .and(
        Expression.property(WorkerIssueFields.category)
            .equalTo(Expression.string(category)),
      ),
    ).orderBy(
      Ordering.property(WorkerIssueFields.createdAt).descending(),
    );

    final result = await query.execute();
    final rows = await result.allResults();

    return rows.map((row) {
      final map = row.dictionary(0)!.toPlainMap();
      final id = row.string(1)!;
      return WorkerIssueModel.fromMap(id, map);
    }).toList();
  }

  static Future<List<Project>> searchProjectsForManager(String managerId, String query) async {
    final col = await DatabaseHelper.projects();
    final q = query.toLowerCase();

    final searchQuery = QueryBuilder()
        .select(
      SelectResult.expression(Meta.id).as(ProjectFields.id),
      SelectResult.property(ProjectFields.projectName),
      SelectResult.property(ProjectFields.managerId),
      SelectResult.property(ProjectFields.managerName),
      SelectResult.property(ProjectFields.location),
      SelectResult.property(ProjectFields.status),
    )
        .from(DataSource.collection(col))
        .where(
      Expression.property(ProjectFields.managerId)
          .equalTo(Expression.string(managerId))
          .and(
        Function_.lower(Expression.property(ProjectFields.projectName))
            .like(Expression.string("%$q%"))
            .or(
          Function_.lower(
              Expression.property(ProjectFields.managerName))
              .like(Expression.string("%$q%")),
        ),
      ),
    ).orderBy(
      Ordering.property(ProjectFields.projectName).ascending(),
    );

    final result = await searchQuery.execute();
    final rows = await result.allResults();

    return rows.map((row) {
      return Project(
        id: row.string(ProjectFields.id) ?? "",
        projectName: row.string(ProjectFields.projectName) ?? "",
        managerId: row.string(ProjectFields.managerId) ?? "",
        managerName: row.string(ProjectFields.managerName) ?? "",
        location: row.string(ProjectFields.location) ?? "",
        status: row.string(ProjectFields.status) ?? "",
      );
    }).toList();
  }






}
