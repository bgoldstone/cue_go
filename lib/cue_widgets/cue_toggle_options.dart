import 'package:cue_go/objects/cue.dart';
import 'package:flutter/material.dart';

class CueToggleOptions extends StatefulWidget {
  final Cue cue;
  const CueToggleOptions({required this.cue, super.key});

  @override
  State<CueToggleOptions> createState() => _CueToggleOptionsState();
}

class _CueToggleOptionsState extends State<CueToggleOptions> {
  CueType radioValue = CueType.none;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RadioMenuButton(
          value: CueType.none,
          groupValue: widget.cue.cueType,
          onChanged: (newValue) {
            setState(() {
              widget.cue.cueType = CueType.none;
            });
          },
          child: const Icon(Icons.not_interested),
        ),
        RadioMenuButton(
          value: CueType.autoContinue,
          groupValue: widget.cue.cueType,
          onChanged: (newValue) {
            setState(() {
              widget.cue.cueType = CueType.autoContinue;
            });
          },
          child: const Icon(Icons.keyboard_arrow_down),
        ),
        RadioMenuButton(
          value: CueType.autoFollow,
          groupValue: widget.cue.cueType,
          onChanged: (newValue) {
            setState(() {
              widget.cue.cueType = CueType.autoFollow;
            });
          },
          child: const Icon(Icons.keyboard_double_arrow_down),
        ),
      ],
    );
  }
}
