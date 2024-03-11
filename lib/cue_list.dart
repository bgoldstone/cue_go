import 'package:cue_go/cue_widgets/add_cues.dart';
import 'package:cue_go/cue_widgets/cue_toggle_options.dart';
import 'package:cue_go/cue_widgets/playback_bar.dart';
import 'package:cue_go/objects/audio_playback.dart';
import 'package:cue_go/objects/cue.dart';
import 'package:flutter/material.dart';

import 'audioplayer_helpers/player_widget.dart';

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
  final Map<String, dynamic> _project = {'cues': <Cue>[]};
  final Map<String, dynamic> _cueConfig = {'current_project': 'Test'};
  int selectedCue = 0;
  @override
  void initState() {
    super.initState();
    cues = _project['cues'];
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
      Cue cue = Cue(fileName, file);
      cue.cueNumber = '${cues.length + 1}';
      cue.player = AudioPlayback();
      cues.add(cue);
      _project['cues'] = cues;
    });
  }

  /// Builds the ListView widget that displays the list of cues.
  Widget cueBuilder(BuildContext context, int index) {
    const TextStyle textStyle = TextStyle(
      color: Colors.black,
    );
    Cue cue = cues[index];
    return GestureDetector(
      child: Card(
        color: index == selectedCue ? Colors.green : Colors.green[900],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.music_note,
                color: Colors.black,
              ),
              Text(
                cue.name,
                style: textStyle,
              ),
              Text(
                'Cue: ${cue.cueNumber}',
                style: textStyle,
              ),
              PlayerWidget(player: cue.player.player),
              CueToggleOptions(cue: cue),
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
              project: _cueConfig['current_project'],
            ),
          ),
        ],
      ),
    );
  }
}
