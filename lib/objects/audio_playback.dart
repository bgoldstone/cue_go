import 'package:audioplayers/audioplayers.dart';

import 'cue.dart';

/// AudioPlayback object for the CueGo app.
class AudioPlayback {
  AudioPlayer player = AudioPlayer();
  void Function(void Function()) cueListState;
  AudioPlayback({required this.cueListState});

  /// Plays the audio.
  Future<bool> playAudio(String file, List<Cue> cues, int cueIndex,
      void Function(Cue, int) updateTimeLeft) async {
    bool returnValue = false;
    cueListState(() {
      DeviceFileSource source = DeviceFileSource(file);
      player.play(source);
      Cue nextCue;
      bool isNextCue = cueIndex + 1 < cues.length;

      player.onDurationChanged.listen((event) {
        updateTimeLeft(cues[cueIndex], event.inSeconds);
      });
      player.onPlayerComplete.listen((event) {
        if (isNextCue) {
          nextCue = cues[cueIndex + 1];
          returnValue = nextCue.cueOption == CueOption.autoFollow;
        }
      });
    });
    return Future<bool>.value(returnValue);
  }

  bool isPlaying() {
    return player.state == PlayerState.playing;
  }

  String getPlayerState() {
    return player.state.toString();
  }

  /// Pauses the audio.
  void pauseAudio() {
    cueListState(
      () {
        player.pause();
      },
    );
  }

  /// Stops the audio.
  void stopAudio() {
    cueListState(
      () {
        player.stop();
      },
    );
  }
}
