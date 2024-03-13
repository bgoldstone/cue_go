import 'audio_playback.dart';

/// Cue object for the CueGo app.
class Cue {
  String name;
  String path;
  double startPosition = 0;
  double endPosition = 0;
  String cueNumber = "";
  int secondsLeft = 0;
  late AudioPlayback player;
  bool isAutoFollow = false;
  CueOption cueOption = CueOption.none;
  bool isPlaying = false;
  Cue(this.name, this.path);
}

/// CueOption enum for the CueGo app.
enum CueOption { none, autoFollow }
