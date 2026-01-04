import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/form_model.dart';

class EntryDetailsScreen extends StatefulWidget {
  final EntryModel entry;

  const EntryDetailsScreen({super.key, required this.entry});

  @override
  State<EntryDetailsScreen> createState() => _EntryDetailsScreenState();
}

class _EntryDetailsScreenState extends State<EntryDetailsScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    if (widget.entry.videoPath != null) {
      try {
        _videoController = VideoPlayerController.file(
          File(widget.entry.videoPath!),
        );

        await _videoController!.initialize();
        setState(() {});
      } catch (e) {
        print("Error loading video: $e");
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Entry Details"),
        backgroundColor: const Color(0xFF6A3DE8),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Workers: ${entry.workers}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Text(
              "Progress: ${entry.progress}%",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            const Text(
              "Issues:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),

            Text(
              entry.issues,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            Text(
              "Uploaded: ${entry.createdAt}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),


            if (entry.imagePath != null) ...[
              const Text(
                "Image Uploaded",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(entry.imagePath!),
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 30),
            ],

            if (_videoController != null &&
                _videoController!.value.isInitialized) ...[
              const Text(
                "Video Uploaded",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),

              VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: Colors.purple,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.black26,
                ),
              ),

              IconButton(
                iconSize: 40,
                icon: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
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
          ],
        ),
      ),
    );
  }
}
