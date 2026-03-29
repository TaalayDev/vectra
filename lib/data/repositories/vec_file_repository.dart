import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/vec_document.dart';

class VecFileRepository {
  static const _fileExtension = '.vct';
  static const _autosaveExtension = '.vct.autosave';

  /// Loads a [VecDocument] from a `.vct` file at [filePath].
  Future<VecDocument> loadFromFile(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    return VecDocument.fromJson(json);
  }

  /// Saves a [VecDocument] to [filePath].
  ///
  /// Writes directly to the target path. On macOS the sandbox entitlement
  /// `files.user-selected.read-write` grants access only to the file the user
  /// selected — a sibling `.tmp` file would be denied, so an atomic
  /// write-then-rename strategy cannot be used here.
  Future<void> saveToFile(String filePath, VecDocument document) async {
    final json = jsonEncode(document.toJson());
    await File(filePath).writeAsString(json, flush: true);
  }

  /// Saves an autosave snapshot alongside the main file.
  Future<void> saveAutosave(String filePath, VecDocument document) async {
    final autosavePath = _autosavePath(filePath);
    final json = jsonEncode(document.toJson());
    await File(autosavePath).writeAsString(json, flush: true);
  }

  /// Returns `true` if an autosave file exists and is newer than the main file.
  Future<bool> hasNewerAutosave(String filePath) async {
    final mainFile = File(filePath);
    final autosaveFile = File(_autosavePath(filePath));

    if (!await autosaveFile.exists()) return false;
    if (!await mainFile.exists()) return true;

    final mainModified = await mainFile.lastModified();
    final autosaveModified = await autosaveFile.lastModified();
    return autosaveModified.isAfter(mainModified);
  }

  /// Loads from the autosave file if it exists.
  Future<VecDocument?> loadAutosave(String filePath) async {
    final autosaveFile = File(_autosavePath(filePath));
    if (!await autosaveFile.exists()) return null;
    final content = await autosaveFile.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    return VecDocument.fromJson(json);
  }

  /// Deletes the autosave file after a successful manual save.
  Future<void> deleteAutosave(String filePath) async {
    final autosaveFile = File(_autosavePath(filePath));
    if (await autosaveFile.exists()) {
      await autosaveFile.delete();
    }
  }

  /// Returns the default directory for saving `.vct` files.
  Future<String> getDefaultSaveDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final vectraDir = Directory('${dir.path}/Vectra');
    if (!await vectraDir.exists()) {
      await vectraDir.create(recursive: true);
    }
    return vectraDir.path;
  }

  /// Lists all `.vct` files in a directory, sorted by last modified (newest first).
  Future<List<File>> listProjectFiles(String directoryPath) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return [];

    final files = await dir
        .list()
        .where((e) => e is File && e.path.endsWith(_fileExtension))
        .cast<File>()
        .toList();

    // Sort by last modified, newest first
    final withDates = <MapEntry<File, DateTime>>[];
    for (final file in files) {
      final modified = await file.lastModified();
      withDates.add(MapEntry(file, modified));
    }
    withDates.sort((a, b) => b.value.compareTo(a.value));

    return withDates.map((e) => e.key).toList();
  }

  String _autosavePath(String filePath) {
    if (filePath.endsWith(_fileExtension)) {
      return '${filePath.substring(0, filePath.length - _fileExtension.length)}$_autosaveExtension';
    }
    return '$filePath$_autosaveExtension';
  }
}
