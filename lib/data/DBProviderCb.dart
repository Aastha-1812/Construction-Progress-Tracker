import 'package:cbl/cbl.dart';
import '../constants/db_fields.dart';

class DatabaseHelper {
  static Database? _db;


  static Future<Database> get database async {
    _db ??= await Database.openAsync('project2_db');
    return _db!;
  }

  static Future<Collection> projects() async {
    final db = await database;
    var col = await db.collection(ProjectFields.tableName);
    col ??= await db.createCollection(ProjectFields.tableName);

    return col;
  }

  static Future<Collection> entries() async {
    final db = await database;
    var col = await db.collection(EntryFields.tableName);
    col ??= await db.createCollection(EntryFields.tableName);

    return col;
  }

  static Future<Collection> workerAssignments() async {
    final db = await database;
    var col = await db.collection(WorkerProjectFields.tableName);
    col ??= await db.createCollection(WorkerProjectFields.tableName);

    return col;
  }
  static Future<Collection> workerIssues() async {
    final db = await database;
    var col = await db.collection(WorkerIssueFields.tableName);

    col ??= await db.createCollection(WorkerIssueFields.tableName);
    return col;
  }



}
