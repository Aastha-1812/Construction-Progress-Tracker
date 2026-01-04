import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/DBHelper.dart';
import '../models/user_model.dart';


class ProfilePage extends StatefulWidget {
  final String managerId;
  const ProfilePage({super.key, required this.managerId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? user;
  File? avatarFile;

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final fetchedUser = await DBHelper.getUserById(widget.managerId);
    setState(() {
      user = fetchedUser;
      nameController.text = user?.name ?? '';
      emailController.text = user?.email ?? '';
      if (user?.avatarPath != null && user!.avatarPath.isNotEmpty) {
        avatarFile = File(user!.avatarPath);
      }
    });
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      avatarFile = File(picked.path);
      final updatedUser = user!.copyWith(avatarPath: picked.path);
      await DBHelper.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile photo updated successfully")),
      );

      setState(() => user = updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF6A3DE8);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style : TextStyle(color: Colors.white)),
        backgroundColor: themeColor,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            GestureDetector(
              onTap: _pickAvatar,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: themeColor.withValues(alpha: 0.2),
                backgroundImage:
                avatarFile != null ? FileImage(avatarFile!) : null,
                child: avatarFile == null
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),


            TextField(
              controller: TextEditingController(text: user!.role),
              enabled: false,
              decoration: const InputDecoration(
                labelText: "Role",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),


            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: themeColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangePasswordPage(user: user!),
                  ),
                );
              },
              child: const Text("Change Password", style : TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}


class ChangePasswordPage extends StatefulWidget {
  final UserModel user;
  const ChangePasswordPage({super.key, required this.user});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();

  Future<void> _changePassword() async {
    if (oldPassCtrl.text != widget.user.password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Old password incorrect")),
      );
      return;
    }

    final updated = widget.user.copyWith(password: newPassCtrl.text.trim());
    await DBHelper.updateUser(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password changed successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF6A3DE8);

    return Scaffold(
      appBar: AppBar(title: const Text("Change Password",style : TextStyle(color: Colors.white)), backgroundColor: themeColor),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: oldPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Old Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: newPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: themeColor),
              onPressed: _changePassword,
              child: const Text("Update Password",style : TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

