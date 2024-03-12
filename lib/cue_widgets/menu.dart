import 'dart:io';

import 'package:cue_go/cue_widgets/file_chooser.dart';
import 'package:cue_go/objects/file_io.dart';
import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  final String currentRouteName;
  final void Function(String) newProject;
  final Directory appDocsDir;
  final void Function(String) loadProject;
  final void Function() saveProject;
  const Menu(
      {required this.currentRouteName,
      required this.newProject,
      required this.appDocsDir,
      required this.loadProject,
      required this.saveProject,
      super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    TextEditingController newProjectController = TextEditingController();
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.purple,
            ),
            child: Text("CueGo Menu"),
          ),
          ListTile(
            title: const Text("Cues"),
            onTap: () {
              if (widget.currentRouteName != '/cues') {
                Navigator.pushNamed(context, '/cues');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          ListTile(
            title: const Text("Create New Project"),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return createProjectDialog(newProjectController, context);
                  });
            },
          ),
          ListTile(
            title: const Text("Load Project"),
            onTap: () {
              loadExistingProject(context);
            },
          ),
          ListTile(
            title: const Text("Save Project"),
            onTap: () {
              widget.saveProject();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void loadExistingProject(BuildContext context) {
    pickProject(widget.appDocsDir).then(
      (file) => {
        if (file != null)
          {
            widget.loadProject(file),
            Navigator.pop(context),
          }
        else
          {
            Navigator.pop(context),
          }
      },
    );
  }

  AlertDialog createProjectDialog(
      TextEditingController newProjectController, BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Project'),
      content: Column(
        children: [
          const Text('Create New Project'),
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Project Name',
            ),
            controller: newProjectController,
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            projectExistsAsync(newProjectController.text).then((value) {
              projectExistsAction(value, context, newProjectController);
            });
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  void projectExistsAction(bool projectExists, BuildContext context,
      TextEditingController newProjectController) {
    if (projectExists) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Project already exists'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      widget.newProject(newProjectController.text);
    }
  }
}
