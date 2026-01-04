import 'package:flutter/material.dart';
import '../data/DBHelperCB.dart';
import '../models/form_model.dart';
import 'form_details_screen.dart';

class AdminProjectScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const AdminProjectScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<AdminProjectScreen> createState() => _AdminProjectScreenState();
}

class _AdminProjectScreenState extends State<AdminProjectScreen> {
  List<EntryModel> uploadedForms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      isLoading = true;
    });

    try {
      final entries = await DBHelperCB.getEntriesForProject(widget.projectId);
      setState(() {
        uploadedForms = entries;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        uploadedForms = [];
        isLoading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        backgroundColor: const Color(0xFF6A3DE8),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : AdminFormListTab(forms: uploadedForms),
    );
  }
}


class AdminFormListTab extends StatelessWidget {
  final List<EntryModel> forms;

  const AdminFormListTab({super.key, required this.forms});

  @override
  Widget build(BuildContext context) {
    if (forms.isEmpty) {
      return const Center(
        child: Text(
          "No reports submitted yet.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: forms.length,
      itemBuilder: (context, index) {
        final form = forms[index];

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EntryDetailsScreen(entry: form),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading:
              const Icon(Icons.description_rounded, color: Color(0xFF6A3DE8)),
              title: Text("Report ID: ${form.id}"),
              subtitle: Text("Progress: ${form.progress}% • Workers: ${form.workers}"),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
          ),
        );
      },
    );
  }
}
