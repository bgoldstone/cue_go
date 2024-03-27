import 'package:cue_go/cue_widgets/volume_widget.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../objects/audio.dart';
import '../objects/cue.dart';

class CueWidget extends StatefulWidget {
  final Cue cue;
  final int index;
  final bool Function(int index) isSelected;
  final void Function(int index) deleteCue;
  final void Function(Audio player) addToPlayerList;
  final void Function(int index) setSelectedCue;
  const CueWidget(
      {super.key,
      required this.cue,
      required this.index,
      required this.deleteCue,
      required this.isSelected,
      required this.addToPlayerList,
      required this.setSelectedCue});

  @override
  State<CueWidget> createState() => _CueWidgetState();
}

class _CueWidgetState extends State<CueWidget> {
  late final Audio player = Audio(
      filePath: widget.cue.path,
      player: AudioPlayer(),
      addToPlayerList: widget.addToPlayerList);
  @override
  void dispose() {
    super.dispose();
    widget.addToPlayerList(player);
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    // get the cue at the widget.index.

    return GestureDetector(
      child: Dismissible(
          key: Key(widget.index.toString()),
          child: Card(
            // set the color of the card based on if it is selected.
            color: widget.isSelected(widget.index)
                ? Colors.green
                : Colors.green[900],
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Displays the music note icon, the name of the cue, and the number of the cue
                      Row(
                        children: [
                          const Icon(
                            Icons.music_note,
                            color: Colors.black,
                            size: 20,
                          ),
                          Container(
                            width: 200,
                            height: 100,
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) =>
                                        editCueNameDialog(widget.cue));
                              },
                              child: Text(
                                widget.cue.name,
                                style: textStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          TextButton(
                            child: Text(
                              'Cue: ${widget.cue.cueNumber}',
                              style: textStyle,
                            ),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) =>
                                  editCueNumberDialog(widget.cue),
                            ),
                          ),
                        ],
                      ),
                      // Displays the player widget
                      // Container(
                      //   width: 200,
                      //   height: 150,
                      //   alignment: Alignment.center,
                      //   child: PlayerWidget(
                      //     player: player.player,
                      //     cue: cue,
                      //   ),
                      // ),
                      // Displays the volume slider
                      Row(
                        children: [
                          VolumeSlider(player: player.getPlayer),
                        ],
                      ),
                    ],
                  ),
                  // Displays the toggle options.
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     CueToggleOptions(
                  //       cue: widget.cue,
                  //       setNewOption: (CueOption option) {
                  //         setState(() {
                  //           widget.cue.cueOption = option;
                  //         });
                  //       },
                  //     ),
                  //   ],
                  // ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          player.play();
                          // setState(() {
                          //   selectedCue = (widget.index + 1) % _cues.length;
                          // });
                        },
                        icon: player.isPlaying
                            ? const Icon(
                                Icons.play_arrow,
                                color: Colors.black,
                              )
                            : const Icon(Icons.play_arrow),
                        tooltip: "Play Audio",
                      ),
                      IconButton(
                        onPressed: () {
                          player.stop();
                        },
                        icon: const Icon(Icons.stop),
                        tooltip: "Stop Audio",
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          onDismissed: (direction) {
            widget.deleteCue(widget.index);
          }),
      // Changes the current cue to the selected widget.cue.
      onTap: () {
        setState(() {
          widget.setSelectedCue(widget.index);
        });
      },
    );
  }

  /// Shows a dialog for editing the cue number of the cue.
  Widget editCueNumberDialog(Cue cue) {
    TextEditingController cueNumberController =
        TextEditingController(text: cue.cueNumber);
    return AlertDialog(
      title: const Text('Edit Cue Number'),
      content: TextField(
          controller: cueNumberController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Cue Number',
          )),
      actions: [
        TextButton(
            child: const Text('Ok'),
            onPressed: () {
              setState(() {
                cue.cueNumber = cueNumberController.text;
              });
              Navigator.pop(context);
            }),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        )
      ],
    );
  }

  /// Shows a dialog for editing the cue name of the cue.
  Widget editCueNameDialog(Cue cue) {
    TextEditingController cueNumberController =
        TextEditingController(text: cue.name);
    return AlertDialog(
      title: const Text('Edit Cue Name'),
      content: TextField(
          controller: cueNumberController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Cue Name',
          )),
      actions: [
        TextButton(
            child: const Text('Ok'),
            onPressed: () {
              setState(() {
                cue.name = cueNumberController.text;
              });
              Navigator.pop(context);
            }),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        )
      ],
    );
  }
}
