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

Future<Map<String, dynamic>> createProjectAsync(
    String projectName, Directory appDocsDir) async {
  String rootBundleLocation =
      await rootBundle.loadString('assets/default_config/default.json');
  Map<String, dynamic> config = jsonDecode(rootBundleLocation);
  debugPrint(config.toString());
  File file = File('${appDocsDir.path}/$projectName.json');
  await file.writeAsString(jsonEncode(config));
  return config;
}

Future<void> saveProjectAsync(String projectName, Map<String, dynamic> config,
    Directory appDocsDir) async {
  File file = File('${appDocsDir.path}/$projectName.json');
  await file.writeAsString(jsonEncode(config));
}
