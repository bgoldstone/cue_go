import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'cue.dart';

/// AudioPlayback object for the CueGo app.
class AudioPlayback {
  final AudioPlayer player = AudioPlayer();
  final void Function(void Function()) cueListState;
  AudioPlayback({required this.cueListState});

  /// Plays the audio.
  Future<bool> playAudio(String file, List<Cue> cues, int cueIndex,
      void Function(Cue, int) updateTimeLeft) async {
    bool returnValue = false;
    player.setFilePath(file, preload: true);
    player.play();
    cueListState(() {
      Cue nextCue;
      bool isNextCue = cueIndex + 1 < cues.length;
      player.durationStream.listen((event) {
        updateTimeLeft(cues[cueIndex], player.duration!.inSeconds);
      });

      if (isNextCue) {
        nextCue = cues[cueIndex + 1];
        returnValue = nextCue.cueOption == CueOption.autoFollow;
      }
    });
    return Future<bool>.value(returnValue);
  }

  bool isPlaying() {
    return player.playing;
  }

  /// Pauses the audio.
  Future<void> pauseAudio() async {
    await player.pause();
  }

  /// Stops the audio.
  Future<void> stopAudio() async {
    debugPrint("Stopping audio playback");
    await player.stop();
  }
}
