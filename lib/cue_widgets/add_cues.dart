import 'package:cue_go/cue_widgets/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

/// AddCues widget for adding cues to the CueGo project.
class AddCues extends StatelessWidget {
  final Function audioCueCallback;
  final String project;
  const AddCues(
      {required this.audioCueCallback, required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      animatedIconTheme: const IconThemeData(size: 40.0),
      backgroundColor: Colors.deepPurpleAccent,
      visible: true,
      curve: Curves.bounceInOut,
      childMargin: const EdgeInsets.all(15),
      tooltip: "Add Cues",
      children: [
        SpeedDialChild(
          child: const Icon(Icons.add),
          label: 'Add Audio Cue',
          labelBackgroundColor: Colors.green,
          labelStyle: const TextStyle(color: Colors.white),
          backgroundColor: const Color.fromRGBO(76, 175, 80, 1),
          shape: const CircleBorder(),
          onTap: pickAudioFile,
        ),
      ],
    );
  }

  /// Pick an audio file from the file system and call [audioCueCallback] with
  void pickAudioFile() async {
    String? file = await pickFile();
    if (file != null) {
      audioCueCallback(file);
    }
  }
}
