import 'dart:convert';
import 'package:construction_progress_tracker/data/DBProviderCb.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/DBHelperCB.dart';
import '../constants/db_fields.dart';
import '../models/project_db_model.dart';

class InitialDataLoader {
  static const _flag = "initial_projects_loaded";


  static Future<void> loadInitialProjects() async {
    final prefs = await SharedPreferences.getInstance();


    if (prefs.getBool(_flag) == true) {
      return;
    }

    final jsonString = await rootBundle.loadString("assets/projects.json");
    final List<dynamic> projectList = json.decode(jsonString);

    final col = await DatabaseHelper.projects();

    for (var p in projectList) {
      final project = Project.fromMap(p["id"], {
        ProjectFields.projectName: p["projectName"],
        ProjectFields.managerId: p["managerId"],
        ProjectFields.managerName: p["managerName"],
        ProjectFields.location: p["location"],
        ProjectFields.status: p["status"],
      });


      await col.saveDocument(project.toDocument());
    }


    await prefs.setBool(_flag, true);
  }
}
