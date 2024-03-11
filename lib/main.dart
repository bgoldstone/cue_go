import 'package:cue_go/cue_list.dart';
import 'package:cue_go/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CueGo());
}

/// Main class for the CueGo app.
class CueGo extends StatelessWidget {
  const CueGo({super.key});

  @override
  Widget build(BuildContext context) {
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
