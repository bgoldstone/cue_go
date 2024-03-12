import 'package:cue_go/objects/cue.dart';
import 'package:flutter/material.dart';

class CueToggleOptions extends StatefulWidget {
  final Cue cue;
  final void Function(CueOption) setNewOption;
  const CueToggleOptions(
      {required this.cue, required this.setNewOption, super.key});

  @override
  State<CueToggleOptions> createState() => _CueToggleOptionsState();
}

/// CueToggleOptions widget for auto follow and auto continue cues.
class _CueToggleOptionsState extends State<CueToggleOptions> {
  CueOption radioValue = CueOption.none;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: 'No Follow or Continue',
          child: RadioMenuButton(
            value: CueOption.none,
            groupValue: widget.cue.cueOption,
            onChanged: (newOption) {
              radioValue = CueOption.none;
              widget.setNewOption(CueOption.none);
            },
            child: const Icon(Icons.not_interested),
          ),
        ),
        Tooltip(
          message: 'Auto Follow',
          child: RadioMenuButton(
            value: CueOption.autoFollow,
            groupValue: widget.cue.cueOption,
            onChanged: (newOption) {
              radioValue = CueOption.autoFollow;
              widget.setNewOption(CueOption.autoFollow);
            },
            child: const Icon(Icons.keyboard_arrow_down),
          ),
        ),
      ],
    );
  }
}
