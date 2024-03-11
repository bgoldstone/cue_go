import 'package:cue_go/add_cues.dart';
import 'package:cue_go/objects/cue.dart';
import 'package:flutter/material.dart';

class PlaybackBar extends StatefulWidget {
  final Function(double) setSliderValue;
  final double Function() getSliderValue;
  final Function(int) setSelectedCue;
  final int Function() getSelectedCue;
  final Function() stopCues;
  final Function(Cue) toggleIsPlaying;
  final Function(Cue, int) updateTimeLeft;
  final List<Cue> cues;
  final AddCues addCues;
  const PlaybackBar(
      {required this.setSliderValue,
      required this.getSliderValue,
      required this.addCues,
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
                selectedCue.player.playAudio(
                    selectedCue.path,
                    widget.toggleIsPlaying,
                    widget.cues[widget.getSelectedCue()],
                    widget.updateTimeLeft);
                widget.setSelectedCue(
                    widget.getSelectedCue() + 1 % widget.cues.length);
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
