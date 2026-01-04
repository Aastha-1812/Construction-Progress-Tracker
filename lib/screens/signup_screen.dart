
import 'package:construction_progress_tracker/screens/worker_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/db_fields.dart';
import '../screens/login_screen.dart';
import '../data/DBHelper.dart';
import '../screens/manager_dashboard.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String password = "";

  late AnimationController fadeController;
  late Animation<double> fadeAnimation;
  String email = "";
  String? _selectedRole;





  @override
  void initState() {
    super.initState();

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    fadeAnimation =
        CurvedAnimation(parent: fadeController, curve: Curves.easeIn);

    fadeController.forward();
  }

  @override
  void dispose() {
    fadeController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a role")),
      );
      return;
    }

    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String pass = passwordController.text.trim();

    try {

      int id = await DBHelper.createUser(
        name,
        email,
        pass,
        _selectedRole!,
      );

      if (id > 0) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool(PrefsKeys.isLoggedIn, true);
        prefs.setString(PrefsKeys.role, _selectedRole!);
        prefs.setString(PrefsKeys.userId, id.toString());
        prefs.setString(PrefsKeys.name, name);
        prefs.setString(PrefsKeys.email, email);
        prefs.setString(PrefsKeys.password, pass);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup Successful!")),
        );
        if (_selectedRole == "manager") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ManagerDashboard(
                managerId: id.toString(),
                managerName: name,
              ),
            ),
          );
        } else if (_selectedRole == "worker") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WorkerDashboard(
                workerId: id.toString(),
                workerName: name,
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  Widget _buildRule(String text, bool valid) {
    return Row(
      children: [
        Icon(
          valid ? Icons.check_circle : Icons.cancel,
          color: valid ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: valid ? Colors.green : Colors.red,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF6A3DE8);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeColor, const Color(0xFF9F70FF)],
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
            ),

            const SizedBox(height: 50),


            FadeTransition(
              opacity: fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.account_circle, color: themeColor),
                          labelText: "Name",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Name is required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),


                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined, color: themeColor),
                          labelText: "Email",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Email is required";
                          }
                          if (!value.contains("@") || !value.contains(".com")) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 6),

                      if (email.isNotEmpty && (!email.contains("@") || !email.contains(".com")))
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Please enter a valid email",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      const SizedBox(height: 15),





                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline, color: themeColor),
                          labelText: "Password",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Password is required";
                          }
                          if (value.length < 6) {
                            return "Minimum 6 characters required";
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return "Must contain at least one capital letter";
                          }
                          if (!RegExp(r'[!@#\$%^&*(),.?\":{}|<>]')
                              .hasMatch(value)) {
                            return "Must contain at least one special character";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRule(
                              "At least 6 characters",
                              password.length >= 6,
                            ),
                            _buildRule(
                              "One capital letter (A-Z)",
                              RegExp(r'[A-Z]').hasMatch(password),
                            ),
                            _buildRule(
                              "One special character",
                              RegExp(r'[!@#\$%^&*(),.?\":{}|<>]')
                                  .hasMatch(password),
                            ),
                          ],
                        ),
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


                      const SizedBox(height: 30),


                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _onSignUpPressed,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  themeColor,
                                  const Color(0xFF9F70FF),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                "Sign Up",
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
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text(
                          "Already have an account? Login",
                          style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

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
              ),
            ),
          ],
        ),
      ),
    );
  }


}
