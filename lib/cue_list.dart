import 'dart:io';

import 'package:cue_go/cue_widgets/cue_toggle_options.dart';
import 'package:cue_go/cue_widgets/menu.dart';
import 'package:cue_go/objects/cue.dart';
import 'package:cue_go/objects/file_io.dart';
import 'package:flutter/material.dart';

import 'cue_widgets/add_cues.dart';
import 'cue_widgets/playback_bar.dart';
import 'cue_widgets/volume_widget.dart';
import 'objects/audio.dart';

/// Cue List Widget that displays the list of cues.
class CueList extends StatefulWidget {
  const CueList({super.key});

  @override
  State<CueList> createState() => _CueListState();
}

/// CueListState class for the CueList widget.
class _CueListState extends State<CueList> {
  List<Cue> _cues = [];
  double sliderValue = 0.0;
  Map<String, dynamic> _projectConfig = {};
  Map<String, dynamic> _cueGoConfig = {};
  int selectedCue = 0;
  late Directory appDocsDir;
  List<Audio> players = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    for (Audio player in players) {
      player.stop();
      player.dispose();
    }
    // Saves the current project and the cue go config.
    Future.wait([
      saveCueGoConfigAsync(_cueGoConfig, appDocsDir),
      saveProjectAsync(
          _cueGoConfig['current_project'], _projectConfig, appDocsDir),
    ]);
  }

  /// Gets the index of the currently selected cue.
  int getSelectedCue() {
    return selectedCue;
  }

  /// Sets the index of the currently selected cue.
  void setSelectedCue(int index) {
    // setState(() {
    //   selectedCue = index;
    // });
  }

  /// Adds an audio cue to the list of cues.
  void addAudioCue(String filePath) {
    // gets filename from filepath.
    String fileName = filePath.split('/').last;
    //removes file extension.
    String fileNameWithoutExtension =
        fileName.replaceAll(RegExp('\\.[^.]*'), "");
    // creates a cue with the filename and filepath.
    Cue cue = Cue(fileNameWithoutExtension, filePath);
    // Sets a default cue number.
    cue.cueNumber = '${_cues.length + 1}';
    //adds new playback object.

    _cues.add(cue);
    //adds audio cue to project config.
    _projectConfig['cues'].add({
      'name': fileNameWithoutExtension,
      'path': filePath,
      'cue_number': cue.cueNumber
    });
    // Saves the project config.
    saveProject();
    dispose();
    players.add(Audio(cue.path));
  }

  /// Loads the project and the cue go config.
  Future<List<Cue>> getCueGoConfigAndProject() async {
    try {
      appDocsDir = await getAppDocsDir();
      Map<String, dynamic> cueGoConfig = await getCueGoConfigAsync(appDocsDir);
      Map<String, dynamic> projectConfig =
          await getProjectAsync(cueGoConfig['current_project'], appDocsDir);
      _projectConfig = projectConfig;
      _cueGoConfig = cueGoConfig;
      List<Cue> cues = loadCues(projectConfig);
      _cues = cues;
      saveProject();
    } catch (e) {
      return List<Cue>.empty();
    }
    return _cues;
  }

  /// Loads the cues from the project config into the cue list.
  List<Cue> loadCues(Map<String, dynamic> projectConfig) {
    List<Cue> cues = [];
    if (projectConfig['cues'] != null) {
      List<Map<String, dynamic>> cueList =
          List<Map<String, dynamic>>.from(projectConfig['cues']);
      if (cueList.isEmpty) {
        return [];
      }
      // maps the cue attributes to the cue object.
      players.clear();
      for (Map<String, dynamic> cueMap in cueList) {
        Cue cue = Cue(cueMap['name'], cueMap['path']);
        cue.cueNumber = cueMap['cue_number'];
        cue.cueOption = CueOption.values[cueMap['cue_option']];
        cues.add(cue);
        players.add(Audio(cue.path));
      }
    }
    return cues;
  }

  /// Loads the project and saves the current project.
  /// also updates the cue go config.
  /// @param projectAbsolutePath the absolute path of the project.
  Future<void> loadProject(String projectAbsolutePath) async {
    // Save Current Project.
    await saveProject();
    // Load New Project.
    Map<String, dynamic> project =
        await getAbsoluteProjectAsync(projectAbsolutePath, appDocsDir);
    //Update CueGo Config
    Map<String, dynamic> newCueGoConfig = _cueGoConfig;
    newCueGoConfig['current_project'] = project['name'];
    // Save new CueGo Config.
    await saveCueGoConfigAsync(newCueGoConfig, appDocsDir);
    // gets cues from new project.
    List<Cue> cues = loadCues(project);
    setState(() {
      _cues = cues;
      _projectConfig = project;
      _cueGoConfig = newCueGoConfig;
    });
  }

  /// Saves the current project.
  Future<void> saveProject() async {
    Map<String, dynamic> cueMap = {
      'name': _projectConfig['name'],
      'cues': [],
    };
    // Converts the cues into a map.
    for (Cue cue in _cues) {
      cueMap['cues'].add({
        'name': cue.name,
        'path': cue.path,
        'cue_number': cue.cueNumber,
        'cue_option': cue.cueOption.index
      });
    }
    await saveProjectAsync(_projectConfig['name'], cueMap, appDocsDir);
  }

  /// Creates a new project.
  ///
  /// @param name The name of the project.
  Future<void> createNewProject(String projectName) async {
    await saveProject();
    Map<String, dynamic> newProject =
        await createProjectAsync(projectName, appDocsDir);
    setState(() {
      _cueGoConfig['current_project'] = projectName;
      _projectConfig = newProject;
      _projectConfig['name'] = projectName;
    });
    await saveCueGoConfigAsync(_cueGoConfig, appDocsDir);
  }

  /// Builds the ListView widget that displays the list of cues.
  /// @param context the context of the widget.
  /// @param index the index of the cue.
  Widget cueBuilder(BuildContext context, int index) {
    const TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    // get the cue at the index.
    Cue cue = _cues[index];
    Audio player = players[index];
    return GestureDetector(
      child: Dismissible(
          key: Key(index.toString()),
          child: Card(
            // set the color of the card based on if it is selected.
            color: index == selectedCue ? Colors.green : Colors.green[900],
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
                            width: 100,
                            height: 100,
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) =>
                                        editCueNameDialog(cue));
                              },
                              child: Text(
                                cue.name,
                                style: textStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          TextButton(
                            child: Text(
                              'Cue: ${cue.cueNumber}',
                              style: textStyle,
                            ),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) => editCueNumberDialog(cue),
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
                          VolumeSlider(player: player.player),
                        ],
                      ),
                    ],
                  ),
                  // Displays the toggle options.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CueToggleOptions(
                        cue: cue,
                        setNewOption: (CueOption option) {
                          setState(() {
                            cue.cueOption = option;
                          });
                          saveProject();
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          player.play();
                          // setState(() {
                          //   selectedCue = (index + 1) % _cues.length;
                          // });
                        },
                        icon: player.isPlaying
                            ? const Icon(Icons.play_arrow_outlined)
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
            deleteCue(index);
          }),
      // Changes the current cue to the selected cue.
      onTap: () {
        // setState(() {
        //   selectedCue = index;
        // });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<Cue>> initializeProject = getCueGoConfigAndProject();
    return FutureBuilder(
      future: initializeProject,
      builder: (context, future) {
        if (future.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Project: ${_projectConfig['name']}',
              ),
            ),
            drawer: Menu(
              currentRouteName: '/cues',
              newProject: createNewProject,
              appDocsDir: appDocsDir,
              loadProject: loadProject,
              saveProject: saveProject,
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemBuilder: cueBuilder,
                    itemCount: _cues.length,
                  ),
                ),
                PlaybackBar(
                  players: players,
                  setSelectedCue: setSelectedCue,
                  getSelectedCue: getSelectedCue,
                  updateTimeLeft: (cue, secondsLeft) {
                    setState(() {
                      cue.secondsLeft = secondsLeft;
                    });
                  },
                  addCues: AddCues(
                    audioCueCallback: addAudioCue,
                    project: _cueGoConfig['current_project'],
                  ),
                  cueListState: setState,
                ),
              ],
            ),
          );
        } else if (future.hasError) {
          throw future.error.toString();
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
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
              saveProject();
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
              saveProject();
              Navigator.pop(context);
            }),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        )
      ],
    );
  }

  void deleteCue(int index) {
    setState(() {
      saveProject();
      players.removeAt(index);
      setState(() {
        _cues.removeAt(index);
      });
    });
  }
}
