import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory> getAppDocsDir() async {
  Directory dir = await getApplicationDocumentsDirectory();
  Directory cueGo = Directory('${dir.path}/cue_go');
  if (!await cueGo.exists()) {
    await cueGo.create();
  }
  return cueGo;
}

Future<Map<String, dynamic>> getCueGoConfigAsync(Directory appDocsDir) async {
  File file = File('${appDocsDir.path}/cue_go.conf');
  if (await file.exists()) {
    String config = await file.readAsString();
    return jsonDecode(config);
  } else {
    return createCueGoConfigAsync(appDocsDir);
  }
}

Future<Map<String, dynamic>> createCueGoConfigAsync(
    Directory appDocsDir) async {
  String rootBundleLocation =
      await rootBundle.loadString('assets/default_config/cue_go.conf');
  Map<String, dynamic> config = jsonDecode(rootBundleLocation);
  File file = File('${appDocsDir.path}/cue_go.conf');
  await file.writeAsString(jsonEncode(config));
  debugPrint('Created cue_go.conf');

  return config;
}

Future<void> saveCueGoConfigAsync(
    Map<String, dynamic> config, Directory appDocsDir) async {
  File file = File('${appDocsDir.path}/cue_go.conf');
  await file.writeAsString(jsonEncode(config));
}

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
Future<Map<String, dynamic>> getAbsoluteProjectAsync(
    String projectPath, Directory appDocsDir) async {
  File file = File('$projectPath.json');
  debugPrint(file.path);
  if (await file.exists()) {
    String config = await file.readAsString();
    return jsonDecode(config);
  }
  String fileName = projectPath.split('/').last.replaceAll(".json", "");
  return createProjectAsync(fileName, appDocsDir);
}

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

Future<void> saveProjectAsync(String projectName, Map<String, dynamic> config,
    Directory appDocsDir) async {
  File file = File('${appDocsDir.path}/$projectName.json');
  await file.writeAsString(jsonEncode(config));
}

Future<bool> projectExistsAsync(String projectName) async {
  Directory appDocsDir = await getAppDocsDir();
  File file = File('${appDocsDir.path}/$projectName.json');
  return await file.exists();
}
