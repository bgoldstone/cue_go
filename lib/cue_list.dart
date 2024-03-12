import 'dart:io';

import 'package:cue_go/cue_widgets/add_cues.dart';
import 'package:cue_go/cue_widgets/cue_toggle_options.dart';
import 'package:cue_go/cue_widgets/playback_bar.dart';
import 'package:cue_go/objects/audio_playback.dart';
import 'package:cue_go/objects/cue.dart';
import 'package:cue_go/objects/file_io.dart';
import 'package:flutter/material.dart';

import 'cue_widgets/player_widget.dart';
import 'cue_widgets/volume_widget.dart';

/// Cue List Widget that displays the list of cues.
class CueList extends StatefulWidget {
  const CueList({super.key});

  @override
  State<CueList> createState() => _CueListState();
}

/// CueListState class for the CueList widget.
class _CueListState extends State<CueList> {
  List<Cue> cues = [];
  double sliderValue = 0.0;
  Map<String, dynamic> _projectConfig = {};
  Map<String, dynamic> _cueGoConfig = {};
  int selectedCue = 0;
  late Directory appDocsDir;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    for (Cue cue in cues) {
      cue.player.stopAudio();
      cue.player.player.dispose();
    }
  }

  /// Gets the index of the currently selected cue.
  int getSelectedCue() {
    return selectedCue;
  }

  /// Sets the index of the currently selected cue.
  void setSelectedCue(int index) {
    setState(() {
      selectedCue = index;
    });
  }

  /// Adds an audio cue to the list of cues.
  void addAudioCue(String file) {
    String fileName = file.split('/').last;
    setState(() {
      Cue cue = Cue(fileName.replaceAll(RegExp('\\.[^.]*'), ""), file);
      cue.cueNumber = '${cues.length + 1}';
      cue.player = AudioPlayback();
      cues.add(cue);
      _projectConfig['cues'] = cues;
    });
  }

  Future<void> getCueGoConfigAndProject() async {
    appDocsDir = await getAppDocsDir();
    Map<String, dynamic> cueGoConfig = await getCueGoConfigAsync(appDocsDir);
    Map<String, dynamic> projectConfig =
        await getProjectAsync(cueGoConfig['current_project'], appDocsDir);
    setState(() {
      _cueGoConfig = cueGoConfig;
      _projectConfig = projectConfig;
    });
    loadProject();
    return;
  }

  void loadProject() {
    if (_projectConfig['cues'] == null) {
      cues = [];
    }
    List<Map<String, dynamic>> cueList =
        List<Map<String, dynamic>>.from(_projectConfig['cues']);

    if (cueList.isEmpty) {
      return;
    }
    for (Map<String, dynamic> cueMap in cueList) {
      Cue cue = Cue(cueMap['name'], cueMap['path']);
      cue.cueNumber = cueMap['cue_number'];
      cue.player = AudioPlayback();
      setState(() {
        cues.add(cue);
      });
    }
  }

  void saveProject() async {
    Map<String, dynamic> cueMap = {
      'cues': [],
    };
    for (Cue cue in cues) {
      cueMap['cues'].add({
        'name': cue.name,
        'path': cue.path,
        'cue_number': cue.cueNumber,
      });
    }
    await saveProjectAsync(_cueGoConfig['current_project'], cueMap, appDocsDir);
  }

  /// Builds the ListView widget that displays the list of cues.
  Widget cueBuilder(BuildContext context, int index) {
    const TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    Cue cue = cues[index];
    return GestureDetector(
      child: Card(
        color: index == selectedCue ? Colors.green : Colors.green[900],
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.music_note,
                        color: Colors.black,
                        size: 20,
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        alignment: Alignment.center,
                        child: Text(
                          cue.name,
                          style: textStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'Cue: ${cue.cueNumber}',
                        style: textStyle,
                      ),
                    ],
                  ),
                  Container(
                    width: 200,
                    height: 150,
                    alignment: Alignment.center,
                    child: PlayerWidget(
                      player: cue.player.player,
                      cue: cue,
                    ),
                  ),
                  Row(
                    children: [
                      VolumeSlider(player: cue.player.player),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CueToggleOptions(cue: cue),
                ],
              )
            ],
          ),
        ),
      ),
      onTap: () {
        setState(() {
          selectedCue = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCueGoConfigAndProject(),
      builder: (context, future) {
        if (future.hasData) {
          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemBuilder: cueBuilder, itemCount: cues.length),
                ),
                PlaybackBar(
                  cues: cues,
                  setSelectedCue: setSelectedCue,
                  getSelectedCue: getSelectedCue,
                  stopCues: () {
                    for (Cue cue in cues) {
                      cue.player.stopAudio();
                      setState(() {
                        cue.isPlaying = false;
                      });
                    }
                  },
                  toggleIsPlaying: (cue) {
                    setState(() {
                      cue.isPlaying = !cue.isPlaying;
                    });
                  },
                  updateTimeLeft: (cue, secondsLeft) {
                    setState(() {
                      cue.secondsLeft = secondsLeft;
                    });
                  },
                  addCues: AddCues(
                    audioCueCallback: addAudioCue,
                    project: _cueGoConfig['current_project'],
                  ),
                ),
              ],
            ),
          );
        } else if (future.hasError) {
          throw future.error.toString();
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}
