import 'dart:async';
import 'dart:isolate';
import 'dart:io';
import 'package:flutter/material.dart';

class FileDownloadScreen extends StatefulWidget {
  final Color themeColor;

  const FileDownloadScreen({super.key, required this.themeColor});

  @override
  _FileDownloadScreenState createState() => _FileDownloadScreenState();
}

class _FileDownloadScreenState extends State<FileDownloadScreen> {
  double progress = 0.0;
  String? downloadedFilePath;

  ReceivePort? receivePort;
  Isolate? apiIsolate;

  @override
  void dispose() {
    apiIsolate?.kill(priority: Isolate.immediate);
    receivePort?.close();
    super.dispose();
  }

  Future<void> startDownload() async {
    receivePort = ReceivePort();

    apiIsolate = await Isolate.spawn(
      downloadFileTask,
      receivePort!.sendPort,
    );

    receivePort!.listen((message) {
      if (message is Map && message.containsKey("progress")) {
        setState(() {
          progress = message["progress"];
        });
      }

      if (message is Map && message.containsKey("done")) {
        setState(() {
          downloadedFilePath = message["done"];
        });
      }

      if (message is Map && message.containsKey("error")) {
        print("Download Error: ${message["error"]}");
      }
    });
  }


  static Future<void> downloadFileTask(SendPort sendPort) async {
    const fileURL = "https://pdfobject.com/pdf/sample.pdf";

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(fileURL));
      final response = await request.close();
      final contentLength = response.contentLength;
      int downloaded = 0;
      final downloadDir = Directory("/storage/emulated/0/Download");

      final filePath = "${downloadDir.path}/sample.pdf";
      final file = File(filePath);
      final sink = file.openWrite();

      await for (var chunk in response) {
        downloaded += chunk.length;
        sink.add(chunk);

        if (contentLength > 0) {
          double progress = (downloaded / contentLength) * 100;
          sendPort.send({"progress": progress});
        }
      }

      await sink.flush();
      await sink.close();

      sendPort.send({"done": filePath});
    } catch (e) {
      sendPort.send({"error": e.toString()});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = widget.themeColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Download PDF (Isolate)",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: themeColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: downloadedFilePath == null
            ? buildDownloadUI(themeColor)
            : buildResultUI(themeColor),
      ),
    );
  }

  Widget buildDownloadUI(Color themeColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${progress.toStringAsFixed(0)}%",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: themeColor,
          ),
        ),

        const SizedBox(height: 20),

        LinearProgressIndicator(
          value: progress / 100,
          minHeight: 12,
          color: themeColor,
          backgroundColor: Colors.grey.shade300,
        ),

        const SizedBox(height: 40),

        ElevatedButton(
          onPressed: startDownload,
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: const Text(
            "Download PDF",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget buildResultUI(Color themeColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: themeColor, size: 60),
        const SizedBox(height: 20),

        const Text(
          "PDF Downloaded Successfully!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        Text(
          "Saved at:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Text(
          downloadedFilePath ?? "",
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),

        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: () {
            setState(() {
              progress = 0;
              downloadedFilePath = null;
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: themeColor),
          child: const Text("Download Again",
              style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}
