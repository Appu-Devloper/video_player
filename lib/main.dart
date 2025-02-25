import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/video_list_screen.dart';
import 'services/video_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => VideoProvider()..loadProgress(),
      child: MaterialApp(debugShowCheckedModeBanner: false,
        home: VideoListScreen()),
    ),
  );
}
