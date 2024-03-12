import 'package:audioplayers/audioplayers.dart';

import 'cue.dart';

/// AudioPlayback object for the CueGo app.
class AudioPlayback {
  AudioPlayer player = AudioPlayer();

  Future<void> playAudio(String file, Function(Cue) onComplete, List<Cue> cues,
      int cueIndex, void Function(Cue, int) updateTimeLeft) async {
    DeviceFileSource source = DeviceFileSource(file);
    await player.play(source);
    Cue nextCue;
    bool isNextCue = cueIndex + 1 < cues.length;
    player.onDurationChanged.listen((event) {
      updateTimeLeft(cues[cueIndex], event.inSeconds);
    });
    player.onPlayerComplete.listen((event) async {
      onComplete(cues[cueIndex]);
      if (isNextCue) {
        nextCue = cues[cueIndex + 1];
        if (nextCue.cueOption == CueOption.autoFollow) {
          await playAudio(
              nextCue.path, onComplete, cues, cueIndex + 1, updateTimeLeft);
        }
      }
    });
  }

  Future<void> stopAudio() async {
    await player.stop();
  }

  Future<void> pauseAudio() async {
    await player.pause();
  }
}
