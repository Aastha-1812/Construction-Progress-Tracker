import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../data/DBHelperCB.dart';
import '../models/worker_issue_model.dart';

class IssueDetailsScreen extends StatefulWidget {
  final String projectId;
  final String category;

  const IssueDetailsScreen({
    super.key,
    required this.projectId,
    required this.category,
  });

  @override
  State<IssueDetailsScreen> createState() => _IssueDetailsScreenState();
}

class _IssueDetailsScreenState extends State<IssueDetailsScreen> {
  bool loading = true;
  List<WorkerIssueModel> issues = [];

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    loadIssues();
  }

  Future<void> loadIssues() async {
    issues = await DBHelperCB.getIssuesForCategory(
      widget.projectId,
      widget.category,
    );

    setState(() => loading = false);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<VideoPlayerController> _initializeController(String path) async {
    if (_videoController != null) {
      await _videoController!.pause();
      _videoController!.dispose();
    }

    _videoController = VideoPlayerController.file(File(path));
    await _videoController!.initialize();

    return _videoController!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: const Color(0xFF6A3DE8),
        foregroundColor: Colors.white,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : issues.isEmpty
          ? const Center(child: Text("No issues in this category"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: issues.length,
        itemBuilder: (context, index) {
          final issue = issues[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 18),
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    issue.issueText,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),


                  if (issue.imagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(issue.imagePath!),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 14),

                  if (issue.videoPath != null)
                    FutureBuilder(
                      future: _initializeController(issue.videoPath!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final controller = snapshot.data as VideoPlayerController;

                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio:
                                controller.value.aspectRatio,
                                child: VideoPlayer(controller),
                              ),
                            ),

                            const SizedBox(height: 8),

                            VideoProgressIndicator(
                              controller,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: Color(0xFF6A3DE8),
                                bufferedColor: Colors.grey,
                                backgroundColor:
                                Colors.grey.shade300,
                              ),
                            ),

                            IconButton(
                              iconSize: 38,
                              color: const Color(0xFF6A3DE8),
                              icon: Icon(
                                controller.value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_fill,
                              ),
                              onPressed: () {
                                setState(() {
                                  controller.value.isPlaying
                                      ? controller.pause()
                                      : controller.play();
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),

                  const SizedBox(height: 16),

                  Text(
                    "Submitted by: ${issue.workerName}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    issue.createdAt.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
