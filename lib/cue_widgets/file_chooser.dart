import 'package:file_picker/file_picker.dart';

/// Pick a file from the file system. Returns null if the user cancels.
Future<String?> pickFile() async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.audio);
  if (result == null) return null;
  return result.files.single.path;
}
