import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelperScreen extends StatelessWidget {
  const HelperScreen({super.key});


  Future<void> _launchEmail() async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'support@constructiontracker.com',
        query: 'subject=Support Request',
      );

      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      final gmailWeb = Uri.parse(
          "https://mail.google.com/mail/?view=cm&fs=1&to=support@constructiontracker.com"
      );
      await launchUrl(gmailWeb, mode: LaunchMode.externalApplication);
    }
  }
  Future<void> _launchPhone(BuildContext context) async {
    try {
      await launchUrl(Uri(scheme: 'tel', path: '+919876543210'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Phone dialer not available on emulator")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: const Color(0xFF6A3DE8),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "About the Product",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),


              const Text(
                "Construction Progress Tracker is a smart project monitoring system "
                    "originally developed in 2018. Our team has been continuously working "
                    "to improve the app with new features, performance updates, and "
                    "stability enhancements. The platform helps managers upload daily "
                    "construction progress while enabling admins to monitor all projects "
                    "in real time.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 25),
              const Text(
                "For Support:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.email_outlined, size: 22),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _launchEmail,
                    child: const Text(
                      "support@constructiontracker.com",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // PHONE ROW
              Row(
                children: [
                  const Icon(Icons.phone, size: 22),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () async {
                      await _launchPhone(context);
                    },
                    child: const Text(
                      "+91 9876543210",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
