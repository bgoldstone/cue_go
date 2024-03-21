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
  final List<Cue> cues;
  final AddCues addCues;
  final void Function(void Function()) cueListState;
  const PlaybackBar(
      {required this.addCues,
      required this.cues,
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
          // Slider(
          //   onChanged: widget.setSliderValue,
          //   value: widget.getSliderValue(),

          // ),
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
                widget.cueListState(() {
                  Cue selectedCue = widget.cues[widget.getSelectedCue()];
                  bool isNextCue =
                      widget.getSelectedCue() + 1 < widget.cues.length;

                  // play audio
                  widget.cueListState(
                    () {
                      selectedCue.player
                          .playAudio(selectedCue.path, widget.cues,
                              widget.getSelectedCue(), widget.updateTimeLeft)
                          .then(
                        (bool autoFollow) {
                          if (autoFollow && isNextCue) {
                            Cue nextCue = widget.cues[widget.getSelectedCue() +
                                1 % widget.cues.length];
                            widget.setSelectedCue(widget.getSelectedCue() +
                                1 % widget.cues.length);
                            nextCue.player.playAudio(nextCue.path, widget.cues,
                                widget.getSelectedCue(), widget.updateTimeLeft);
                          }
                        },
                      );
                    },
                  );

                  // set next selected cue.
                  if (isNextCue) {
                    widget.setSelectedCue(
                        widget.getSelectedCue() + 1 % widget.cues.length);
                  }
                });
              },
            ),
          ),

          /// Button to pause the currently selected cue.
          IconButton(
            icon: const Icon(Icons.pause),
            iconSize: iconSize,
            color: iconColor,
            tooltip: 'Pause All Cues',
            onPressed: () {
              for (Cue cue in widget.cues) {
                if (cue.player.isPlaying()) {
                  widget.cueListState(() {
                    cue.player.pauseAudio().then(
                        (value) => debugPrint("paused cue: ${cue.cueNumber}"));
                  });
                }
              }
            },
          ),

          /// Button to stop the currently selected cue.
          IconButton(
            icon: const Icon(Icons.stop),
            iconSize: iconSize,
            color: iconColor,
            tooltip: 'Stop All Cues',
            onPressed: () {
              for (Cue cue in widget.cues) {
                debugPrint(
                    'Cue ${cue.name} ${cue.player.isPlaying()} Playing: ${cue.player.isPlaying()}');
                widget.cueListState(() {
                  if (cue.player.isPlaying()) {
                    cue.player.stopAudio();
                  }
                });

                debugPrint("stopped cue: ${cue.cueNumber}");
                debugPrint("Cue playing: ${cue.player.isPlaying()}");
              }
            },
          ),
          widget.addCues,
        ],
      ),
    );
  }
}
