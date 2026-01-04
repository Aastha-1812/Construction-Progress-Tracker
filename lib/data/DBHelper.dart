import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../constants/db_fields.dart';
import '../models/user_model.dart';
import '../constants/db_fields.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();

  static Database? _database;


  static Future<Database> getDB() async {
    _database ??= await _openDB();
    return _database!;
  }


  static Future<Database> _openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "construct3.db");

    return await openDatabase(
      dbPath,
      version: 2,
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE worker_manager_complaints (
            id TEXT PRIMARY KEY,
            workerId TEXT,
            workerName TEXT,
            managerId TEXT,
            managerName TEXT,
            message TEXT,
            timestamp INTEGER
          )
        ''');
        }
      },
    );
  }


  static Future<void> _createTables(Database db, int version) async {
    await db.execute("""
    CREATE TABLE ${UserFields.tableName} (
      ${UserFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${UserFields.name} TEXT,
      ${UserFields.email} TEXT UNIQUE,
      ${UserFields.password} TEXT,
      ${UserFields.role} TEXT,
      ${UserFields.avatarPath} TEXT
    )
  """);
    await db.execute('''
  CREATE TABLE worker_manager_complaints (
    id TEXT PRIMARY KEY,
    workerId TEXT,
    workerName TEXT,
    managerId TEXT,
    managerName TEXT,
    message TEXT,
    timestamp INTEGER
  )
''');

  }



  static Future<int> createUser(
      String name,
      String email,
      String password,
      String role,
      ) async {
    final db = await getDB();

    return await db.insert(
      UserFields.tableName,
      {
        UserFields.name: name,
        UserFields.email: email,
        UserFields.password: password,
        UserFields.role: role,
        UserFields.avatarPath: "",
      },
    );


  }




  static Future<UserModel?> loginUser(String email, String password) async {
    final db = await getDB();

    final res = await db.query(
      UserFields.tableName,
      where: "${UserFields.email} = ? AND ${UserFields.password} = ?",
      whereArgs: [email, password],
    );

    if (res.isNotEmpty) {
      return UserModel.fromMap(res.first);
    }
    return null;
  }

  static Future<List<UserModel>> getManagers() async {
    final db = await getDB();

    final res = await db.query(
      UserFields.tableName,
      where: "${UserFields.role} = ?",
      whereArgs: ["manager"],
    );

    return res.map((e) => UserModel.fromMap(e)).toList();
  }

  static Future<UserModel?> getUserById(String id) async {
    final db = await getDB();

    final res = await db.query(
      UserFields.tableName,
      where: "${UserFields.id} = ?",
      whereArgs: [id],
    );

    if (res.isNotEmpty) {
      return UserModel.fromMap(res.first);
    }
    return null;
  }


  static Future<int> updateUser(UserModel user) async {
    final db = await getDB();

    return await db.update(
      UserFields.tableName,
      {
        UserFields.name: user.name,
        UserFields.email: user.email,
        UserFields.password: user.password,
        UserFields.role: user.role,
        UserFields.avatarPath: user.avatarPath,
      },
      where: "${UserFields.id} = ?",
      whereArgs: [user.id],
    );
  }


  static Future<List<UserModel>> getWorkers() async {
    final db = await getDB();

    final res = await db.query(
      UserFields.tableName,
      where: "${UserFields.role} = ?",
      whereArgs: ["worker"],
    );

    return res.map((e) => UserModel.fromMap(e)).toList();
  }


  static Future<int> addComplaint(Map<String, dynamic> data) async {
    final db = await getDB();
    return await db.insert("worker_manager_complaints", data);
  }

  static Future<Map<String, List<Map<String, dynamic>>>> getComplaintsGroupedByManager() async {
    final db = await getDB();

    final result = await db.query("worker_manager_complaints");

    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var row in result) {
      final String managerId = row["managerId"] as String;

      if (!grouped.containsKey(managerId)) {
        grouped[managerId] = [];
      }

      grouped[managerId]!.add(row);
    }

    return grouped;
  }


  static Future<List<Map<String, dynamic>>> getComplaintsForManager(String managerId) async {
    final db = await getDB();

    return await db.query(
      "worker_manager_complaints",
      where: "managerId = ?",
      whereArgs: [managerId],
      orderBy: "timestamp DESC",
    );
  }




}

