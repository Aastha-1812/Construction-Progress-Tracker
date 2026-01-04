import 'package:cbl/cbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cbl_flutter/cbl_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/manager_project/search_bloc.dart';
import 'services/initial_data_loader.dart';
import 'services/manager_static_loader.dart';
import 'bloc/kpi/kpi_bloc.dart';
import 'bloc/kpi/kpi_event.dart';
import 'bloc/project/project_bloc.dart';
import 'bloc/project/project_event.dart';
import 'bloc/project_form/project_form_bloc.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CouchbaseLiteFlutter.init();
  runApp(const ConstructionApp());
}

class ConstructionApp extends StatelessWidget {
  const ConstructionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => KpiBloc()),
        BlocProvider(create: (_) => ProjectBloc()),
        BlocProvider(create: (_) => EntryBloc()),
        BlocProvider(create: (_) => ManagerProjectBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Construction Progress Tracker",
        home: FutureBuilder(
          future: _initializeAppOnce(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

Future<void> _initializeAppOnce() async {
  final prefs = await SharedPreferences.getInstance();

  if (!(prefs.getBool("projects_loaded") ?? false)) {
    await InitialDataLoader.loadInitialProjects();
    await prefs.setBool("projects_loaded", true);
  }
  if (!(prefs.getBool("static_managers_loaded") ?? false)) {
    await StaticLoader.loadManagers();
    await prefs.setBool("static_managers_loaded", true);
  }
}
