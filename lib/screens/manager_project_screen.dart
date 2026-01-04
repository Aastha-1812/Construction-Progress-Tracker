import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../bloc/project_form/project_form_bloc.dart';
import '../bloc/project_form/project_form_event.dart';
import '../bloc/project_form/project_form_state.dart';
import '../data/DBHelperCB.dart';
import '../screens/file_name_popup.dart';
import '../models/form_model.dart';
import 'assign_workers_screen.dart';
import 'issue_details_screen.dart';
import '../widgets/issue_pie_chart.dart';

class ManagerProjectScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ManagerProjectScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ManagerProjectScreen> createState() => _ManagerProjectScreenState();
}

class _ManagerProjectScreenState extends State<ManagerProjectScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      AssignWorkersScreen(projectId: widget.projectId),
      UploadFormTab(projectId: widget.projectId),
      ManagerIssuesScreen(projectId: widget.projectId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        backgroundColor: const Color(0xFF6A3DE8),
        foregroundColor: Colors.white,
      ),

      body: screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF6A3DE8),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group_add),
            label: "Assign",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: "Issues",
          ),
        ],
      ),
    );
  }
}


class UploadFormTab extends StatefulWidget {
  final String projectId;

  const UploadFormTab({super.key, required this.projectId});

  @override
  State<UploadFormTab> createState() => _UploadFormTabState();
}

class _UploadFormTabState extends State<UploadFormTab> {
  final TextEditingController workersController = TextEditingController();
  final TextEditingController issuesController = TextEditingController();
  final TextEditingController progressController = TextEditingController();

  static const platform = MethodChannel('media_channel');

  Uint8List? imageBytes;
  String? selectedImagePath;
  String? selectedVideoPath;
  VideoPlayerController? _videoController;

  static const int maxImageSize = 5 * 1024 * 1024;
  static const int maxVideoSize = 50 * 1024 * 1024;


  Future<void> pickImage() async {
    try {
      final path = await platform.invokeMethod<String>("pickImage");
      if (path == null) return;

      final file = File(path);
      final size = await file.length();

      if (size > maxImageSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image too large! Max allowed: 5 MB")),
        );
        return;
      }

      selectedImagePath = path;
      final bytes = await file.readAsBytes();

      setState(() => imageBytes = bytes);
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> captureImage() async {
    try {
      final path = await platform.invokeMethod<String>("captureImage");
      if (path == null) return;

      final file = File(path);
      final size = await file.length();

      if (size > maxImageSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image too large! Max allowed: 5 MB")),
        );
        return;
      }

      selectedImagePath = path;
      final bytes = await file.readAsBytes();

      setState(() => imageBytes = bytes);
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  Future<void> pickVideo() async {
    try {
      final path = await platform.invokeMethod<String>("pickVideo");
      if (path == null) return;

      final file = File(path);
      final size = await file.length();

      if (size > maxVideoSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video too large! Max allowed: 50 MB")),
        );
        return;
      }

      selectedVideoPath = path;

      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();

      setState(() {});
    } catch (e) {
      print("Error picking video: $e");
    }
  }

  Future<void> captureVideo() async {
    try {
      final path = await platform.invokeMethod<String>("captureVideo");
      if (path == null) return;

      final file = File(path);
      final size = await file.length();

      if (size > maxVideoSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video too large! Max allowed: 50 MB")),
        );
        return;
      }

      selectedVideoPath = path;

      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();

      setState(() {});
    } catch (e) {
      print("Error capturing video: $e");
    }
  }

  Future<void> startVoiceInput() async {
    try {
      const speechChannel = MethodChannel('speech_channel');
      final recognizedText = await speechChannel.invokeMethod<String>("startListening");

      if (recognizedText != null && recognizedText.isNotEmpty) {
        setState(() {
          issuesController.text =
              "${issuesController.text} $recognizedText".trim();
        });
      }
    } catch (e) {
      print("Speech error: $e");
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EntryBloc, EntryState>(
      listener: (context, state) {
        switch (state) {
          case EntrySaving():
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
            break;

          case EntrySaved():
            Navigator.pop(context);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Form saved successfully!")),
            );
            break;

          case EntrySaveFailure(message: var msg):
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $msg")),
            );
            break;

          default:
            break;
        }
      },

      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: workersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Number of Workers",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: issuesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Issues Faced",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.mic, color: Color(0xFF6A3DE8)),
                    onPressed: startVoiceInput,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: progressController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Progress (%)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  "⚠ Max Image Size: 5 MB | Max Video Size: 50 MB",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              if (imageBytes != null)
                Container(
                  width: double.infinity,
                  height: 220,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(imageBytes!, fit: BoxFit.cover),
                  ),
                ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Upload Image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A3DE8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: captureImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Camera"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A3DE8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (_videoController != null &&
                  _videoController!.value.isInitialized)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: VideoPlayer(_videoController!),
                        ),
                      ),
                      const SizedBox(height: 12),
                      VideoProgressIndicator(
                        _videoController!,
                        allowScrubbing: true,
                      ),
                      IconButton(
                        iconSize: 40,
                        color: const Color(0xFF6A3DE8),
                        icon: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                        ),
                        onPressed: () {
                          setState(() {
                            _videoController!.value.isPlaying
                                ? _videoController!.pause()
                                : _videoController!.play();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: pickVideo,
                      icon: const Icon(Icons.video_library),
                      label: const Text("Upload Video"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A3DE8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: captureVideo,
                      icon: const Icon(Icons.videocam),
                      label: const Text("Camera"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A3DE8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final fileName = await showFileNamePopup(context);
                    if (fileName == null) return;

                    final entry = EntryModel(
                      id: fileName,
                      projectId: widget.projectId,
                      workers: int.tryParse(workersController.text) ?? 0,
                      issues: issuesController.text,
                      progress: int.tryParse(progressController.text) ?? 0,
                      imagePath: selectedImagePath,
                      videoPath: selectedVideoPath,
                      createdAt: DateTime.now(),
                    );

                    context.read<EntryBloc>().add(
                      SaveEntryRequested(entry: entry),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A3DE8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Submit Form",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



class ManagerIssuesScreen extends StatefulWidget {
  final String projectId;

  const ManagerIssuesScreen({super.key, required this.projectId});

  @override
  State<ManagerIssuesScreen> createState() => _ManagerIssuesScreenState();
}

class _ManagerIssuesScreenState extends State<ManagerIssuesScreen> {
  bool loading = true;
  Map<String, int> categoryCounts = {};
  final List<String> standardCategories = [
    "Food",
    "Water",
    "Safety",
    "Equipment",
    "Other",
  ];


  @override
  void initState() {
    super.initState();
    loadIssues();
  }

  Future<void> loadIssues() async {
    final countsFromDB = await DBHelperCB.getIssueCountsByCategory(widget.projectId);
    categoryCounts = {
      for (var c in standardCategories) c: countsFromDB[c] ?? 0,
    };

    setState(() => loading = false);
  }


  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: IssuePieChart(data: categoryCounts),
          ),
        ),

        const SizedBox(height: 20),
        ...standardCategories.map((category) {
          final count = categoryCounts[category] ?? 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 4,
              color: Colors.white,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

                leading: const Icon(
                  Icons.error_outline,
                  color: Color(0xFF6A3DE8),
                  size: 26,
                ),

                title: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                trailing: CircleAvatar(
                  backgroundColor: const Color(0xFF6A3DE8),
                  radius: 16,
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IssueDetailsScreen(
                        projectId: widget.projectId,
                        category: category,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }




}

