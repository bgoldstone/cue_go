import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// Pick a file from the file system. Returns null if the user cancels.
Future<String?> pickAudio() async {
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(type: FileType.audio, allowMultiple: false);
  if (result == null) return null;
  return result.files.single.path;
}

Future<String?> pickProject(Directory appDocsDir) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
    allowMultiple: false,
    initialDirectory: '${appDocsDir.path}/cue_go',
  );
  if (result == null) return null;
  // Returns the path of the picked file.
  return result.files.single.path?.replaceAll(".json", '');
}
