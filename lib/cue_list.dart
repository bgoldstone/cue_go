import 'dart:io';

import 'package:cue_go/cue_widgets/add_cues.dart';
import 'package:cue_go/cue_widgets/cue_toggle_options.dart';
import 'package:cue_go/cue_widgets/menu.dart';
import 'package:cue_go/cue_widgets/playback_bar.dart';
import 'package:cue_go/objects/audio_playback.dart';
import 'package:cue_go/objects/cue.dart';
import 'package:cue_go/objects/file_io.dart';
import 'package:flutter/material.dart';

import 'cue_widgets/player_widget.dart';
import 'cue_widgets/volume_widget.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    for (Cue cue in _cues) {
      cue.player.stopAudio();
      cue.player.player.dispose();
    }
    () async {
      await saveCueGoConfigAsync(_cueGoConfig, appDocsDir);
      await saveProjectAsync(
          _cueGoConfig['current_project'], _projectConfig, appDocsDir);
    };
  }

  /// Gets the index of the currently selected cue.
  int getSelectedCue() {
    return selectedCue;
  }

  /// Sets the index of the currently selected cue.
  void setSelectedCue(int index) {
    setState(() {
      selectedCue = index;
    });
  }

  /// Adds an audio cue to the list of cues.
  void addAudioCue(String filePath) {
    String fileName = filePath.split('/').last;
    String fileNameWithoutExtension =
        fileName.replaceAll(RegExp('\\.[^.]*'), "");
    Cue cue = Cue(fileNameWithoutExtension, filePath);
    cue.cueNumber = '${_cues.length + 1}';
    cue.player = AudioPlayback();

    _cues.add(cue);
    _projectConfig['cues'].add({
      'name': fileNameWithoutExtension,
      'path': filePath,
      'cue_number': cue.cueNumber
    });
    saveProject();
    setState(() {});
  }

  Future<bool> getCueGoConfigAndProject() async {
    appDocsDir = await getAppDocsDir();
    Map<String, dynamic> cueGoConfig = await getCueGoConfigAsync(appDocsDir);
    Map<String, dynamic> projectConfig =
        await getProjectAsync(cueGoConfig['current_project'], appDocsDir);

    _projectConfig = projectConfig;
    _cueGoConfig = cueGoConfig;
    List<Cue> cues = loadCues(projectConfig);
    _cues = cues;
    saveProject();
    return true;
  }

  List<Cue> loadCues(Map<String, dynamic> projectConfig) {
    List<Cue> cues = [];
    if (projectConfig['cues'] != null) {
      List<Map<String, dynamic>> cueList =
          List<Map<String, dynamic>>.from(projectConfig['cues']);
      if (cueList.isEmpty) {
        return [];
      }

      for (Map<String, dynamic> cueMap in cueList) {
        debugPrint(
            'Loading Cue: ${cueMap['name']} for Project: ${projectConfig['name']}');
        Cue cue = Cue(cueMap['name'], cueMap['path']);
        cue.cueNumber = cueMap['cue_number'];
        cue.player = AudioPlayback();
        cues.add(cue);
      }
    }
    return cues;
  }

  String getProjectName() {
    return _projectConfig['name'];
  }

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

  Future<void> saveProject() async {
    Map<String, dynamic> cueMap = {
      'name': _projectConfig['name'],
      'cues': [],
    };
    for (Cue cue in _cues) {
      cueMap['cues'].add({
        'name': cue.name,
        'path': cue.path,
        'cue_number': cue.cueNumber,
      });
    }
    await saveProjectAsync(_projectConfig['name'], cueMap, appDocsDir);
  }

  Future<void> createNewProject(String projectName) async {
    await saveProject();
    Map<String, dynamic> newProject =
        await createProjectAsync(projectName, appDocsDir);

    _cueGoConfig['current_project'] = projectName;
    _projectConfig = newProject;
    _projectConfig['name'] = projectName;
    await saveCueGoConfigAsync(_cueGoConfig, appDocsDir);
    setState(() {});
  }

  /// Builds the ListView widget that displays the list of cues.
  Widget cueBuilder(BuildContext context, int index) {
    const TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    Cue cue = _cues[index];
    return GestureDetector(
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
                        child: Text(
                          cue.name,
                          style: textStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'Cue: ${cue.cueNumber}',
                        style: textStyle,
                      ),
                    ],
                  ),
                  // Displays the player widget
                  Container(
                    width: 200,
                    height: 150,
                    alignment: Alignment.center,
                    child: PlayerWidget(
                      player: cue.player.player,
                      cue: cue,
                    ),
                  ),
                  // Displays the volume slider
                  Row(
                    children: [
                      VolumeSlider(player: cue.player.player),
                    ],
                  ),
                ],
              ),
              // Displays the toggle options.
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CueToggleOptions(cue: cue),
                ],
              )
            ],
          ),
        ),
      ),
      onTap: () {
        setState(() {
          selectedCue = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Future<void> initializeProject = getCueGoConfigAndProject();
    return FutureBuilder(
      future: initializeProject,
      builder: (context, future) {
        if (future.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Project: ${getProjectName()}',
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
                  cues: _cues,
                  setSelectedCue: setSelectedCue,
                  getSelectedCue: getSelectedCue,
                  stopCues: () {
                    for (Cue cue in _cues) {
                      cue.player.stopAudio();
                      setState(() {
                        cue.isPlaying = false;
                      });
                    }
                  },
                  toggleIsPlaying: (cue) {
                    setState(() {
                      cue.isPlaying = !cue.isPlaying;
                    });
                  },
                  updateTimeLeft: (cue, secondsLeft) {
                    setState(() {
                      cue.secondsLeft = secondsLeft;
                    });
                  },
                  addCues: AddCues(
                    audioCueCallback: addAudioCue,
                    project: _cueGoConfig['current_project'],
                  ),
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
}
