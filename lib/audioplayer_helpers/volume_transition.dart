import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

/// Add transition feature to a given [player] by [fadeObservable] and [fade].
///
/// From https://github.com/bluefireteam/audioplayers/issues/945
class VolumeTransition {
  final AudioPlayer player;

  const VolumeTransition(this.player);

  /// Custom Howler Fade
  /// [audio transition implementation](https://github.com/gmpassos/howler.dart/blob/master/lib/src/howler_base.dart#L1691)
  ///
  /// Stream based fade
  Stream<double> fadeObservable(
      {required Duration duration,
      required double from,
      required double to}) async* {
    final length = duration.inMilliseconds;
    final diff = to - from;
    final steps = (diff / 0.01).abs();
    final period = max(4, (steps > 0) ? length ~/ steps : length);

    var lastTick = DateTime.now().millisecondsSinceEpoch;
    var volume = from;

    double computation(int computationCount) {
      if ((to < from && volume <= to) || (to > from && volume >= to)) {
        return double.nan;
      }

      final now = DateTime.now().millisecondsSinceEpoch;

      final tick = (now - lastTick) / length;

      lastTick = now;

      volume += diff * tick;

      if (diff < 0) {
        volume = max(to, volume);
      } else {
        volume = min(to, volume);
      }

      volume = (volume * 100).round() / 100;

      return volume;
    }

    final ticker =
        Stream<double>.periodic(Duration(milliseconds: period), computation);

    await for (final volume in ticker) {
      final effectiveVolume = volume.isNaN ? to : volume;

      await player.setVolume(effectiveVolume);

      yield volume;

      if (volume.isNaN) break;
    }
  }

  /// Future based fade that uses [fadeObservable] with a [Completer]
  Future<void> fade(
      {required Duration duration, required double to, required double from}) {
    final completer = Completer<void>();

    late StreamSubscription<double> subscription;

    void listener(double volume) {
      if (volume.isNaN) {
        completer.complete();
        subscription.cancel();
      }
    }

    subscription =
        fadeObservable(duration: duration, to: to, from: from).listen(listener);

    return completer.future;
  }
}
