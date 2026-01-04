import 'package:shared_preferences/shared_preferences.dart';

class ProjectFields {
  static const tableName = "projects";

  static const id = "id";
  static const projectName = "projectName";
  static const managerId = "managerId";
  static const managerName = "managerName";
  static const location = "location";
  static const status = "status";
  static const String defaultStatus = "Not Started";
}

class EntryFields {
  static const tableName = "entries";

  static const id = "id";
  static const projectId = "projectId";
  static const workers = "workers";
  static const issues = "issues";
  static const progress = "progress";
  static const imagePath = "imagePath";
  static const videoPath = "videoPath";
  static const createdAt = "createdAt";
}

class UserFields {
  static const String id = "id";
  static const String name = "name";
  static const String email = "email";
  static const String password = "password";
  static const String role = "role";
  static const String tableName = "users";
  static const String avatarPath =  "avatarPath";

}
class StatusConstants {
  static const String notStarted = "Not Started";
  static const String inProgress = "In Progress";
  static const String complete = "Complete";
}

class PrefsKeys {
  static const isLoggedIn = "isLoggedIn";
  static const role = "role";
  static const name = "name";
  static const email = "email";
  static const password = "password";
  static const userId = "userId";
  static const staticManagersLoaded = "staticManagersLoaded";
  static const staticWorkersLoaded = "staticWorkersLoaded";

}

class AdminCredentials {
  static const email = "aastha@gmail.com";
  static const password = "123456789";
  static const name = "Aastha";
}

class PrefsHelper {
  static Future<void> clearLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.isLoggedIn);
    await prefs.remove(PrefsKeys.role);
    await prefs.remove(PrefsKeys.name);
    await prefs.remove(PrefsKeys.email);
    await prefs.remove(PrefsKeys.password);
    await prefs.remove(PrefsKeys.userId);
  }
}

class WeatherFields {
  static const apiKey = "88d2045a8a21fd714b566e65615c9ae6";
  static const city = "Pune";
  static const baseUrl = "https://api.openweathermap.org/data/2.5/weather";
  static const units = "metric";
  static const updateIntervalSeconds = 10;

}

class CollectionNames {
  static const projects = "projects";
  static const entries = "entries";
}

class WorkerProjectFields {
  static const tableName = "worker_project_map";
}
class WorkerIssueFields {
  static const tableName = "worker_issues";

  static const id = "id";
  static const projectId = "projectId";
  static const workerId = "workerId";
  static const workerName = "workerName";
  static const category = "category";
  static const issueText = "issueText";
  static const imagePath = "imagePath";
  static const videoPath = "videoPath";
  static const createdAt = "createdAt";
}





