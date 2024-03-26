import 'package:cue_go/cue_widgets/add_cues.dart';
import 'package:cue_go/objects/cue.dart';
import 'package:flutter/material.dart';

import '../objects/audio.dart';

/// PlaybackBar widget for the CueGo app.
///
///
/// [setSelectedCue] is a callback function that sets the selected cue.
///
///
/// [getSelectedCue] is a callback function that gets the selected cue.
///
///
/// [updateTimeLeft] is a callback function that updates the time left in the cue.
///
///
/// [cues] is a list of cues.
///
///
/// [addCues] is an instance of the AddCues widget.
class PlaybackBar extends StatefulWidget {
  final Function(int) setSelectedCue;
  final int Function() getSelectedCue;
  final Function(Cue, int) updateTimeLeft;
  final List<Audio> players;
  final AddCues addCues;
  final void Function(void Function()) cueListState;

  const PlaybackBar(
      {required this.addCues,
      required this.players,
      required this.setSelectedCue,
      required this.getSelectedCue,
      required this.updateTimeLeft,
      required this.cueListState,
      super.key});

  @override
  State<PlaybackBar> createState() => _PlaybackBarState();
}

class _PlaybackBarState extends State<PlaybackBar> {
  @override
  Widget build(BuildContext context) {
    const double iconSize = 40.0;
    const Color iconColor = Colors.white;
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Button to play the currently selected cue.
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
            alignment: Alignment.center,
            child: IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: iconSize,
              color: iconColor,
              splashRadius: 5,
              tooltip: 'Play Selected Cue',
              onPressed: () {
                widget.players[widget.getSelectedCue()].play();
                widget.setSelectedCue(
                    (widget.getSelectedCue() + 1) % widget.players.length);
              },
            ),
          ),

          /// Button to stop the currently selected cue.
          IconButton(
            icon: const Icon(Icons.stop),
            iconSize: iconSize,
            color: iconColor,
            tooltip: 'Stop All Cues',
            onPressed: () {
              for (Audio player in widget.players) {
                player.stop();
              }
            },
          ),
          widget.addCues,
        ],
      ),
    );
  }
}
