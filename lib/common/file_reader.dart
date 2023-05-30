import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<List<String>> openFileBrowser() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    PlatformFile file = result.files.first;
    // Use the selected file
    File selectedFile = File(file.path!);

    try {
      List<String> lines = await selectedFile.readAsLines();
      return lines;
    } catch (e) {
      return [];
    }
  } else {
    return [];
  }
}

Future<String> openFileSaveDialog() async {
  final path = await FilePicker.platform.getDirectoryPath();

  if (path != null) {
    return path;
  } else {
    return "";
  }
}
