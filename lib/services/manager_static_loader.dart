import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/DBHelper.dart';

class StaticLoader {
  static const String _flag = "static_managers_loaded";

  static Future<void> loadManagers() async {
    final prefs = await SharedPreferences.getInstance();


    final alreadyLoaded = prefs.getBool(_flag) ?? false;
    if (alreadyLoaded) {
      return;
    }



    final jsonString = await rootBundle.loadString("assets/managers.json");
    final List data = json.decode(jsonString);

    for (var m in data) {
      await DBHelper.createUser(
        m["name"],
        m["email"],
        m["password"],
        m["role"],
      );
    }


    await prefs.setBool(_flag, true);

    print("Static managers loaded successfully.");
  }
}
