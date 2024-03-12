import 'package:cue_go/cue_widgets/add_cues.dart';
import 'package:cue_go/objects/cue.dart';
import 'package:flutter/material.dart';

/// PlaybackBar widget for the CueGo app.
///
///
/// [setSelectedCue] is a callback function that sets the selected cue.
///
///
/// [getSelectedCue] is a callback function that gets the selected cue.
///
///
/// [stopCues] is a callback function that stops the playback of the cues.
///
///
/// [toggleIsPlaying] is a callback function that toggles the playback of the cues.
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
  final Function() stopCues;
  final Function(Cue) toggleIsPlaying;
  final Function(Cue, int) updateTimeLeft;
  final List<Cue> cues;
  final AddCues addCues;
  const PlaybackBar(
      {required this.addCues,
      required this.cues,
      required this.setSelectedCue,
      required this.getSelectedCue,
      required this.stopCues,
      required this.toggleIsPlaying,
      required this.updateTimeLeft,
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
          // Slider(
          //   onChanged: widget.setSliderValue,
          //   value: widget.getSliderValue(),

          // ),
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
                Cue selectedCue = widget.cues[widget.getSelectedCue()];
                Cue nextCue = widget
                    .cues[widget.getSelectedCue() + 1 % widget.cues.length];
                selectedCue.player.playAudio(
                    selectedCue.path,
                    widget.toggleIsPlaying,
                    widget.cues,
                    widget.getSelectedCue(),
                    widget.updateTimeLeft);
                widget
                    .setSelectedCue(
                        widget.getSelectedCue() + 1 % widget.cues.length)
                    .then((bool autoFollow) {
                  if (autoFollow) {
                    widget.toggleIsPlaying(nextCue);
                    nextCue.player.playAudio(
                        nextCue.path,
                        widget.toggleIsPlaying,
                        widget.cues,
                        widget.getSelectedCue(),
                        widget.updateTimeLeft);
                  }
                });
                setState(() {
                  selectedCue.isPlaying = true;
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.pause),
            iconSize: iconSize,
            color: iconColor,
            tooltip: 'Pause All Cues',
            onPressed: () async {
              for (Cue cue in widget.cues) {
                if (cue.isPlaying) {
                  cue.player.pauseAudio();
                  setState(() {
                    cue.isPlaying = false;
                  });
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            iconSize: iconSize,
            color: iconColor,
            tooltip: 'Stop All Cues',
            onPressed: widget.stopCues,
          ),
          widget.addCues,
        ],
      ),
    );
  }
}
