import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Simple wrapper for dropped files
class DroppedFile {
  final String path;
  final String name;

  DroppedFile(this.path) : name = path.split(Platform.pathSeparator).last;

  Future<Uint8List> readAsBytes() async {
    return File(path).readAsBytes();
  }
}

/// Types of files that can be dropped
enum DroppedFileType { image, project, unknown }

/// Result of processing a dropped file
class DroppedFileResult {
  final DroppedFileType type;
  final img.Image? image;
  final String? errorMessage;
  final String fileName;

  DroppedFileResult({required this.type, required this.fileName, this.image, this.errorMessage});

  bool get isSuccess => errorMessage == null;
  bool get hasImage => image != null;
}

/// Service for handling dropped files in PixelVerse
class DropHandlerService {
  static final DropHandlerService _instance = DropHandlerService._internal();
  factory DropHandlerService() => _instance;
  DropHandlerService._internal();

  /// Supported image extensions
  static const List<String> imageExtensions = ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'];

  /// Supported Aseprite extensions
  static const List<String> asepriteExtensions = ['ase', 'aseprite'];

  /// Project file extension
  static const String projectExtension = 'pxv';

  /// Determine the type of a dropped file based on its extension
  DroppedFileType getFileType(String path) {
    final extension = path.split('.').last.toLowerCase();

    if (imageExtensions.contains(extension)) {
      return DroppedFileType.image;
    } else if (extension == projectExtension) {
      return DroppedFileType.project;
    }

    return DroppedFileType.unknown;
  }

  /// Process a single dropped file from path
  Future<DroppedFileResult> processDroppedFile(String filePath) async {
    final file = DroppedFile(filePath);
    final fileName = file.name;
    final fileType = getFileType(fileName);

    try {
      final bytes = await file.readAsBytes();

      switch (fileType) {
        case DroppedFileType.image:
          return await _processImageFile(bytes, fileName);
        case DroppedFileType.project:
          return await _processProjectFile(bytes, fileName);
        case DroppedFileType.unknown:
          return DroppedFileResult(
            type: DroppedFileType.unknown,
            fileName: fileName,
            errorMessage: 'Unsupported file type',
          );
      }
    } catch (e) {
      debugPrint('Error processing dropped file: $e');
      return DroppedFileResult(type: fileType, fileName: fileName, errorMessage: 'Failed to process file: $e');
    }
  }

  /// Process multiple dropped files from paths
  Future<List<DroppedFileResult>> processDroppedFiles(List<String> filePaths) async {
    final results = <DroppedFileResult>[];
    for (final path in filePaths) {
      results.add(await processDroppedFile(path));
    }
    return results;
  }

  /// Process an image file and return as a decoded image
  Future<DroppedFileResult> _processImageFile(Uint8List bytes, String fileName) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) {
        return DroppedFileResult(
          type: DroppedFileType.image,
          fileName: fileName,
          errorMessage: 'Could not decode image',
        );
      }

      return DroppedFileResult(type: DroppedFileType.image, fileName: fileName, image: image);
    } catch (e) {
      return DroppedFileResult(
        type: DroppedFileType.image,
        fileName: fileName,
        errorMessage: 'Failed to decode image: $e',
      );
    }
  }

  /// Process a .pxv project file
  Future<DroppedFileResult> _processProjectFile(Uint8List bytes, String fileName) async {
    try {
      final jsonString = String.fromCharCodes(bytes);
      final jsonData = _parseJson(jsonString);
      if (jsonData == null) {
        return DroppedFileResult(
          type: DroppedFileType.project,
          fileName: fileName,
          errorMessage: 'Invalid project file format',
        );
      }

      return DroppedFileResult(type: DroppedFileType.project, fileName: fileName);
    } catch (e) {
      return DroppedFileResult(
        type: DroppedFileType.project,
        fileName: fileName,
        errorMessage: 'Failed to parse project file: $e',
      );
    }
  }

  Map<String, dynamic>? _parseJson(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
