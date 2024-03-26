import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Gets the Application Documents directory from path_provider package.
Future<Directory> getAppDocsDir() async {
  Directory dir = await getApplicationDocumentsDirectory();
  Directory cueGo = Directory('${dir.path}/cue_go');
  if (!await cueGo.exists()) {
    await cueGo.create();
  }
  return cueGo;
}

/// Gets the Cue Go configuration directory from path_provider package.
/// If the configuration does not exist, it creates it.
/// @param appDocsDir the application documents directory.
Future<Map<String, dynamic>> getCueGoConfigAsync(Directory appDocsDir) async {
  File file = File('${appDocsDir.path}/cue_go.conf');
  if (await file.exists()) {
    String config = await file.readAsString();
    return jsonDecode(config);
  } else {
    return createCueGoConfigAsync(appDocsDir);
  }
}

/// Creates the Cue Go configuration if it does not exist.
/// @param appDocsDir the application documents directory.s
Future<Map<String, dynamic>> createCueGoConfigAsync(
    Directory appDocsDir) async {
  String rootBundleLocation =
      await rootBundle.loadString('assets/default_config/cue_go.conf');
  Map<String, dynamic> config = jsonDecode(rootBundleLocation);
  File file = File('${appDocsDir.path}/cue_go.conf');
  await file.writeAsString(jsonEncode(config));

  return config;
}

/// Save thecue Go configuration.
/// @param config the updated cue go configuration.
/// @param appDocsDir the application documents directory.
Future<void> saveCueGoConfigAsync(
    Map<String, dynamic> config, Directory appDocsDir) async {
  File file = File('${appDocsDir.path}/cue_go.conf');
  await file.writeAsString(jsonEncode(config));
}

/// Get the project from the project name and loads it if it exists.
/// @param projectName the name of the project.
/// @param appDocsDir the application documents directory.
Future<Map<String, dynamic>> getProjectAsync(
    String projectName, Directory appDocsDir) async {
  File file = File('${appDocsDir.path}/$projectName.json');
  if (await file.exists()) {
    String config = await file.readAsString();
    return jsonDecode(config);
  } else {
    return createProjectAsync(projectName, appDocsDir);
  }
}

/// Get the absolute path of the project file and loads it if it exists.
/// @param projectPath the absolute path of the project.
/// @param appDocsDir the application documents directory.
Future<Map<String, dynamic>> getAbsoluteProjectAsync(
    String projectPath, Directory appDocsDir) async {
  File file = File('$projectPath.json');
  if (await file.exists()) {
    String config = await file.readAsString();
    return jsonDecode(config);
  }
  String fileName = projectPath.split('/').last.replaceAll(".json", "");
  return createProjectAsync(fileName, appDocsDir);
}

/// Creates a new project and loads it.
/// @param projectName the name of the project.
/// @param appDocsDir the application documents directory.
Future<Map<String, dynamic>> createProjectAsync(
    String projectName, Directory appDocsDir) async {
  String rootBundleLocation =
      await rootBundle.loadString('assets/default_config/default.json');
  Map<String, dynamic> config = jsonDecode(rootBundleLocation);
  File file = File('${appDocsDir.path}/$projectName.json');
  config['name'] = projectName;
  await file.writeAsString(jsonEncode(config));
  return config;
}

/// Saves the project to the Application Documents Directory.
/// @param projectName the name of the project.
/// @param config the project configuration.
/// @param appDocsDir the application documents directory.
Future<void> saveProjectAsync(String projectName, Map<String, dynamic> config,
    Directory appDocsDir) async {
  File file = File('${appDocsDir.path}/$projectName.json');
  await file.writeAsString(jsonEncode(config));
}

/// Checks if the project exists.
/// @param projectName the name of the project.
/// @param appDocsDir the application documents directory.
Future<bool> projectExistsAsync(
    String projectName, Directory appDocsDir) async {
  File file = File('${appDocsDir.path}/$projectName.json');
  return await file.exists();
}
