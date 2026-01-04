import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import '../data/DBHelperCB.dart';
import '../models/worker_issue_model.dart';

class WorkerIssueScreen extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String workerId;
  final String workerName;

  const WorkerIssueScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.workerId,
    required this.workerName,
  });

  @override
  State<WorkerIssueScreen> createState() => _WorkerIssueScreenState();
}

class _WorkerIssueScreenState extends State<WorkerIssueScreen> {
  String selectedCategory = "Food";
  final TextEditingController issueCtrl = TextEditingController();

  String? imagePath;
  String? videoPath;

  VideoPlayerController? _videoController;

  static const mediaChannel = MethodChannel('media_channel');
  static const speechChannel = MethodChannel('speech_channel');
  static const int maxImageSize = 5 * 1024 * 1024;
  static const int maxVideoSize = 50 * 1024 * 1024;

  final List<String> categories = [
    "Food",
    "Water",
    "Safety",
    "Equipment",
    "Other",
  ];

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final path = await mediaChannel.invokeMethod<String>("pickImage");
    if (path == null) return;

    final file = File(path);
    final size = await file.length();

    if (size > maxImageSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image too large! Max allowed: 5 MB")),
      );
      return;
    }

    setState(() => imagePath = path);
  }

  Future<void> _captureImage() async {
    final path = await mediaChannel.invokeMethod<String>("captureImage");
    if (path == null) return;

    final file = File(path);
    final size = await file.length();

    if (size > maxImageSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image too large! Max allowed: 5 MB")),
      );
      return;
    }

    setState(() => imagePath = path);
  }

  Future<void> _pickVideo() async {
    final path = await mediaChannel.invokeMethod<String>("pickVideo");
    if (path == null) return;

    final file = File(path);
    final size = await file.length();

    if (size > maxVideoSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Video too large! Max allowed: 50 MB")),
      );
      return;
    }

    await _loadVideo(path);
  }

  Future<void> _captureVideo() async {
    final path = await mediaChannel.invokeMethod<String>("captureVideo");
    if (path == null) return;

    final file = File(path);
    final size = await file.length();

    if (size > maxVideoSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Video too large! Max allowed: 50 MB")),
      );
      return;
    }

    await _loadVideo(path);
  }

  Future<void> _loadVideo(String path) async {
    videoPath = path;

    _videoController?.dispose();
    _videoController = VideoPlayerController.file(File(path));

    await _videoController!.initialize();
    setState(() {});
  }

  Future<void> _startVoiceInput() async {
    try {
      final text = await speechChannel.invokeMethod<String>("startListening");
      if (text != null && text.isNotEmpty) {
        setState(() => issueCtrl.text = "${issueCtrl.text} $text".trim());
      }
    } catch (e) {
      print("Speech error: $e");
    }
  }

  Future<void> submitIssue() async {
    if (issueCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please describe the issue")),
      );
      return;
    }

    final issue = WorkerIssueModel(
      id: const Uuid().v4(),
      projectId: widget.projectId,
      workerId: widget.workerId,
      workerName: widget.workerName,
      category: selectedCategory,
      issueText: issueCtrl.text.trim(),
      imagePath: imagePath,
      videoPath: videoPath,
      createdAt: DateTime.now(),
    );

    await DBHelperCB.addWorkerIssue(issue);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Issue submitted successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Issue"),
        backgroundColor: const Color(0xFF6A3DE8),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("Issue Category",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            DropdownButtonFormField(
              initialValue: selectedCategory,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: (v) => setState(() => selectedCategory = v!),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: issueCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Describe the issue",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic, color: Color(0xFF6A3DE8)),
                  onPressed: _startVoiceInput,
                ),
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
            const SizedBox(height: 20),
            if (imagePath != null)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(imagePath!), fit: BoxFit.cover),
                ),
              ),

            _buildImageButtons(),
            const SizedBox(height: 20),

            if (_videoController != null &&
                _videoController!.value.isInitialized)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                    const SizedBox(height: 10),
                    VideoProgressIndicator(_videoController!,
                        allowScrubbing: true),
                    IconButton(
                      iconSize: 40,
                      color: const Color(0xFF6A3DE8),
                      icon: Icon(_videoController!.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled),
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

            _buildVideoButtons(),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitIssue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A3DE8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Submit Issue",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImageButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text("Upload Image"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A3DE8),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _captureImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text("Camera"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A3DE8),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _pickVideo,
            icon: const Icon(Icons.video_library),
            label: const Text("Upload Video"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A3DE8),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _captureVideo,
            icon: const Icon(Icons.videocam),
            label: const Text("Camera"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A3DE8),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
