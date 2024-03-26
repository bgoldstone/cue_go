import 'package:just_audio/just_audio.dart';

class Audio {
  late final AudioPlayer _player;
  Duration _position = Duration.zero;
  void _initializePlayer(String filePath) {
    // Replace the URL with a valid audio file URL
    _player.setFilePath(filePath).then((_) => _player.stop().then((_) => null));
    _position = _player.position;
  }

  AudioPlayer get player => _player;
  bool get isPlaying => _player.playing;
  int get position => _position.inSeconds;
  bool get isPaused => _position.inSeconds != 0;

  Audio(String filePath) {
    _player = AudioPlayer();
    _initializePlayer(filePath);
  }

  void dispose() {
    _player.dispose();
  }

  Future<void> play() async {
    await _player.seek(_position);
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }
}
