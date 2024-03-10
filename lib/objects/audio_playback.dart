import 'package:audioplayers/audioplayers.dart';

import 'cue.dart';

class AudioPlayback {
  AudioPlayer player = AudioPlayer();

  Future<void> playAudio(String file, Function(Cue) onComplete, Cue cue,
      Function(Cue, int) updateTimeLeft) async {
    DeviceFileSource source = DeviceFileSource(file);
    await player.play(source);

    player.onPlayerComplete.listen((event) {
      onComplete(cue);
    });
  }

  Future<void> stopAudio() async {
    await player.stop();
  }

  Future<void> pauseAudio() async {
    await player.pause();
  }
}
