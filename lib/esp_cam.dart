import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class ImageStreamPage extends StatefulWidget {
  const ImageStreamPage({super.key});

  @override
  _ImageStreamPageState createState() => _ImageStreamPageState();
}

class _ImageStreamPageState extends State<ImageStreamPage> {
  final String streamUrl = "http://192.168.4.1/image";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.width * 0),

          Transform.rotate(
            angle: 0,//3.1416 // 180 degrees in radians
            child: Mjpeg(
              stream: streamUrl,
              isLive: true,
              timeout: const Duration(seconds: 5),
              fit: BoxFit.cover,
              loading: (context) {
                debugPrint("[DEBUG] Loading MJPEG stream...");
                return const Center(child: CircularProgressIndicator());
              },
              error: (context, error, stackTrace) {
                debugPrint("[ERROR] Failed to load MJPEG stream: $error");
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 40),
                      const SizedBox(height: 8),
                      const Text("Failed to load stream."),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
