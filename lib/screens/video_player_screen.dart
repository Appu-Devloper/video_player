import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../Models/video_model.dart';
import '../services/video_provider.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoPlayerController controller;
  final Video video;
  final Duration startAt;
  VideoPlayerScreen({required this.controller, required this.video, required this.startAt});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool isFullScreen = false;
  bool showControls = true;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    widget.controller.seekTo(widget.startAt);
    widget.controller.play();
    widget.controller.addListener(_updateProgress);
  }

  void _updateProgress() {
    if (mounted) {
      setState(() {});
      Provider.of<VideoProvider>(context, listen: false)
          .updateProgress(widget.video.id, widget.controller.value.position, widget.controller.value.duration);
    }
  }

  void toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
      if (isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showControls = !showControls;
                    if (widget.controller.value.isPlaying) {
                      widget.controller.pause();
                      isPaused = true;
                    } else {
                      widget.controller.play();
                      isPaused = false;
                    }
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(widget.controller),
                    if (isPaused)
                      Icon(
                        Icons.play_circle_filled,
                        size: 80,
                        color: Colors.white,
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 40,
            child: CupertinoButton(
              child: Icon(CupertinoIcons.back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                  child: Text(
                    widget.video.title,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                VideoProgressIndicator(widget.controller, allowScrubbing: false),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                  child: Text(
                    "${_formatDuration(widget.controller.value.position)} / ${_formatDuration(widget.controller.value.duration)}",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (showControls)
            Positioned(
              bottom: 50,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.fullscreen, color: Colors.white, size: 30),
                onPressed: toggleFullScreen,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateProgress);
    widget.controller.dispose();
    super.dispose();
  }
}
