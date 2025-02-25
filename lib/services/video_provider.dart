
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/datasource.dart';

class VideoProvider extends ChangeNotifier {
  Map<String, Duration> videoProgress = {};
   Map<String, Duration> totalDuration = {};


 void updateProgress(String id, Duration duration, Duration total) async {
    videoProgress[id] = duration;
    totalDuration[id] = total;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(id, duration.inSeconds);
    prefs.setInt('${id}_total', total.inSeconds);
    notifyListeners();
  }

  Future<void> loadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var video in videos) {
      int? seconds = prefs.getInt(video.id);
      if (seconds != null) {
        videoProgress[video.id] = Duration(seconds: seconds);
      }
    }
    notifyListeners();
  }
}
