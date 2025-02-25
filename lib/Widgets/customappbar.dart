import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar buildCustomAppBar(BuildContext context) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple[800]!, Colors.blueGrey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
    title: Text(
      "Video Library",
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    centerTitle: true,
    leading: IconButton(
      icon: Icon(Icons.menu, color: Colors.white),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.search, color: Colors.white),
        onPressed: () {
          // Handle search action
        },
      ),
      IconButton(
        icon: Icon(Icons.notifications, color: Colors.white),
        onPressed: () {
          // Handle notifications
        },
      ),
    ],
  );
}
