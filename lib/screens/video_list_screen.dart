import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_videos/Models/video_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../Models/datasource.dart';
import '../Widgets/customappbar.dart';
import '../services/video_provider.dart';
import 'video_player_screen.dart';

class VideoListScreen extends StatelessWidget {
  static bool _isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:buildCustomAppBar(context),
      backgroundColor: Colors.black,
      body: Consumer<VideoProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: videos.length,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            itemBuilder: (context, index) {
              Duration? watchedDuration = provider.videoProgress[videos[index].id];
              Duration? totalDuration = provider.totalDuration[videos[index].id];
              bool isCompleted = watchedDuration != null && totalDuration != null && watchedDuration.inSeconds >= totalDuration.inSeconds;

              bool isLocked = index != 0 &&
                  (provider.videoProgress[videos[index - 1].id]?.inSeconds ?? 0) <
                      (provider.totalDuration[videos[index - 1].id]?.inSeconds ?? 1);
              
           return GestureDetector(
  onTap: () async {
    if (isLocked) {
      if (!_isDialogShowing) {
      
        _showLockedDialog(context);
      }
      return;
    }
    VideoPlayerController controller =
        VideoPlayerController.networkUrl(Uri.parse(videos[index].url));
    await controller.initialize();
    _showPlaybackDialog(context, controller, videos[index], isCompleted);
  },
  child: Container(
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      gradient: LinearGradient(
        colors: [Colors.deepPurple[800]!, Colors.blueGrey[900]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: Offset(2, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                child: Image.network(
                  videos[index].image,
                  width: 130,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient Overlay on Image for Better Visibility
              
              if (isLocked)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: Icon(Icons.lock, color: Colors.red, size: 32),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    videos[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  if (watchedDuration != null && totalDuration != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gradient Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              gradient: LinearGradient(
                                colors: [Colors.blueAccent, Colors.purpleAccent],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: watchedDuration.inSeconds / totalDuration.inSeconds,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 6),
                        // Watched Percentage
                        Text(
                          "${((watchedDuration.inSeconds / totalDuration.inSeconds) * 100).toStringAsFixed(0)}% Watched",
                          style: TextStyle(color: Colors.grey[300], fontSize: 12),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);

            },
          );
        },
      ),
    );
  }

  void _showPlaybackDialog(BuildContext context, VideoPlayerController controller, Video video, bool isCompleted) async {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedPosition = prefs.getInt(video.id);

    if (isCompleted) {
      savedPosition = 0;
    }

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Resume Playback"),
          content: Text("Do you want to resume from where you left off?"),
          actions: [
            CupertinoDialogAction(
              child: Text("No"),
              onPressed: () {
                _isDialogShowing = false;
                Navigator.pop(context);
                _playVideo(context, controller, video, startAt: Duration.zero);
              },
            ),
            CupertinoDialogAction(
              child: Text("Yes"),
              onPressed: () {
                _isDialogShowing = false;
                Navigator.pop(context);
                _playVideo(context, controller, video, startAt: Duration(seconds: savedPosition ?? 0));
              },
            ),
          ],
        );
      },
    );
  }

  void _playVideo(BuildContext context, VideoPlayerController controller, Video video, {required Duration startAt}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(controller: controller, video: video, startAt: startAt),
      ),
    );
  }

  void _showLockedDialog(BuildContext context) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Video Locked"),
          content: Text("You must complete the previous video to unlock this one."),
          actions: [
            CupertinoDialogAction(
              child: Text("OK"),
              onPressed: () {
                _isDialogShowing = false;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}
