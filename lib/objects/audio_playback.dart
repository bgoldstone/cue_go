import 'package:audioplayers/audioplayers.dart';

import 'cue.dart';

/// AudioPlayback object for the CueGo app.
class AudioPlayback {
  AudioPlayer player = AudioPlayer();

  Future<bool> playAudio(String file, Function(Cue) onComplete, List<Cue> cues,
      int cueIndex, void Function(Cue, int) updateTimeLeft) async {
    DeviceFileSource source = DeviceFileSource(file);
    await player.play(source);
    Cue nextCue;
    bool isNextCue = cueIndex + 1 < cues.length;
    bool returnValue = false;
    player.onDurationChanged.listen((event) {
      updateTimeLeft(cues[cueIndex], event.inSeconds);
    });
    player.onPlayerComplete.listen((event) {
      onComplete(cues[cueIndex]);
      if (isNextCue) {
        nextCue = cues[cueIndex + 1];
        returnValue = nextCue.cueOption == CueOption.autoFollow;
      }
    });
    return Future<bool>.value(returnValue);
  }

  Future<void> stopAudio() async {
    await player.stop();
  }

  Future<void> pauseAudio() async {
    await player.pause();
  }
}
