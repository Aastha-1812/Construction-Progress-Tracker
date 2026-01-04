import 'package:construction_progress_tracker/screens/worker_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/db_fields.dart';
import '../screens/signup_screen.dart';
import '../data/DBHelper.dart';
import '../screens/admin_dashboard.dart';
import '../screens/manager_dashboard.dart';
import '../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController fadeController;
  late Animation<double> fadeAnimation;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _checkLoggedIn();

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    fadeAnimation = CurvedAnimation(parent: fadeController, curve: Curves.easeIn);

    fadeController.forward();
  }

  void _checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLogged = prefs.getBool(PrefsKeys.isLoggedIn) ?? false;

    if (!isLogged) return;

    String role = prefs.getString(PrefsKeys.role) ?? "";
    String id = prefs.getString(PrefsKeys.userId) ?? "";
    String name = prefs.getString(PrefsKeys.name) ?? "";
    String email = prefs.getString(PrefsKeys.email) ?? "";
    String pw = prefs.getString(PrefsKeys.password) ?? "";


    if (email == AdminCredentials.email &&
        pw == AdminCredentials.password) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
      return;
    }
    if (role == "manager") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ManagerDashboard(
            managerId: id,
            managerName: name,
          ),
        ),
      );
      return;
    }

    if (role == "worker") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WorkerDashboard(
            workerId: id,
            workerName: name,
          ),
        ),
      );
      return;
    }
  }



  void _onLoginPressed() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password are required!")),
      );
      return;
    }

    try {

      if (_selectedRole == "admin") {
        if (email == AdminCredentials.email && password == AdminCredentials.password) {

          final prefs = await SharedPreferences.getInstance();
          prefs.setBool(PrefsKeys.isLoggedIn, true);
          prefs.setString(PrefsKeys.role, "admin");
          prefs.setString(PrefsKeys.email, AdminCredentials.email);
          prefs.setString(PrefsKeys.password, AdminCredentials.password);
          prefs.setString(PrefsKeys.name, AdminCredentials.name);
          prefs.setString(PrefsKeys.userId, "admin");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid admin credentials")),
          );
        }

        return;
      }



      UserModel? user = await DBHelper.loginUser(email, password);

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password!")),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool(PrefsKeys.isLoggedIn, true);
      prefs.setString(PrefsKeys.role, user.role);
      prefs.setString(PrefsKeys.email, email);
      prefs.setString(PrefsKeys.name, user.name);
      prefs.setString(PrefsKeys.password, password);
      prefs.setString(PrefsKeys.userId, user.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful!")),
      );


      if (user.role == "manager") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ManagerDashboard(
              managerId: user.id,
              managerName: user.name,
            ),
          ),
        );
        return;
      }


      if (user.role == "worker") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WorkerDashboard(
              workerId: user.id,
              workerName: user.name,
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unknown role!")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  @override
  void dispose() {
    fadeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF6A3DE8);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(themeColor),
            const SizedBox(height: 20),
            buildLoginUI(themeColor),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader(Color themeColor) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor,
            const Color(0xFF9F70FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.engineering_rounded,
                color: Colors.white,
                size: 70,
              ),
              SizedBox(height: 10),
              Text(
                "Create an account!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Track and manage site progress effortlessly",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildLoginUI(Color themeColor) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 25),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _fieldDecoration("Email", Icons.email_outlined),
            ),

            const SizedBox(height: 15),


            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: _fieldDecoration("Password", Icons.lock_outline),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: InputDecoration(
                labelText: "Select Role",
                prefixIcon: const Icon(Icons.people_alt_outlined, color: Color(0xFF6A3DE8)),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "admin",
                  child: Text("Admin"),
                ),
                DropdownMenuItem(
                  value: "manager",
                  child: Text("Manager"),
                ),
                DropdownMenuItem(
                  value: "worker",
                  child: Text("Worker"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              validator: (value) =>
              value == null ? "Please select a role" : null,
            ),


            const SizedBox(height: 28),


            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _onLoginPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [themeColor, const Color(0xFF9F70FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),


            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: Text(
                "Create an account",
                style: TextStyle(
                  color: themeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "A 24/7 Software product",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }


  InputDecoration _fieldDecoration(String label, IconData prefix) {
    return InputDecoration(
      prefixIcon: Icon(prefix, color: const Color(0xFF6A3DE8)),
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }




}



