import 'package:just_audio/just_audio.dart';

class Audio {
  final AudioPlayer player;
  Duration _position = Duration.zero;
  AudioPlayer get getPlayer => player;
  bool get isPlaying => player.playing;
  int get position => _position.inSeconds;
  bool get isPaused => _position.inSeconds != 0;
  void Function(Function()) setStateCallback;

  Audio(
      {required this.player,
      required String filePath,
      required void Function(Audio player) addToPlayerList,
      required this.setStateCallback}) {
    _initializePlayer(filePath);
    addToPlayerList(this);
  }
  void _initializePlayer(String filePath) async {
    // Replace the URL with a valid audio file URL
    await player
        .setAudioSource(AudioSource.file(filePath.replaceAll('file://', '')));
    await player.stop();
    _position = player.position;
  }

  void dispose() {
    player.dispose();
  }

  Future<void> play() async {
    await player.play();
  }

  Future<void> stop() async {
    await player.stop();
  }
}
