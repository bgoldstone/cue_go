import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class VolumeSlider extends StatefulWidget {
  final AudioPlayer player;
  const VolumeSlider({required this.player, super.key});

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  double _sliderValue = 0.5;
  double previousVolume = 0;
  bool isMuted = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: isMuted
              ? const Icon(Icons.volume_off)
              : const Icon(Icons.volume_up),
          iconSize: 38,
          onPressed: () {
            if (isMuted) {
              widget.player.setVolume(previousVolume);
              setState(() {
                isMuted = false;
              });
            } else {
              previousVolume = widget.player.volume;
              widget.player.setVolume(0);
              setState(() {
                isMuted = true;
              });
            }
          },
        ),
        Text(
          "Volume: ${(_sliderValue * 100).toStringAsFixed(0)}%",
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: RotatedBox(
            quarterTurns: 3,
            key: const Key('volume_slider'),
            child: Slider(
              min: 0,
              max: 1,
              divisions: 20,
              value: _sliderValue,
              onChanged: (double value) {
                setState(() {
                  _sliderValue = value;
                  isMuted = false;
                  widget.player.setVolume(_sliderValue);
                });
              },
              activeColor: Colors.green[900],
              inactiveColor: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
