import 'dart:io';

import 'package:cue_go/cue_list.dart';
import 'package:cue_go/login_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // Check if mpv is installed on Linux
  if (!kIsWeb &&
      Platform.isLinux &&
      Process.runSync("which", ["mpv"]).exitCode != 0) {
    throw Exception("mpv is not installed! To work on Linux, mpv is required!");
  }
  runApp(const CueGo());
}

/// Main class for the CueGo app.
class CueGo extends StatelessWidget {
  const CueGo({super.key});

  @override
  Widget build(BuildContext context) {
    // Set the preferred orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.grey, useMaterial3: true),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        primarySwatch: Colors.grey,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      routes: {
        '/': (context) => const LoginScreen(),
        '/cues': (context) => const CueList(),
      },
      initialRoute: '/cues',
    );
  }
}
