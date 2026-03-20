import 'dart:async';

import '../models/vec_color.dart';
import '../models/vec_document.dart';
import '../repositories/vec_file_repository.dart';

class VecDocumentService {
  VecDocumentService({required VecFileRepository repository})
      : _repository = repository;

  final VecFileRepository _repository;
  Timer? _autosaveTimer;
  String? _currentFilePath;
  bool _isDirty = false;

  String? get currentFilePath => _currentFilePath;
  bool get isDirty => _isDirty;

  /// Creates a new blank document.
  VecDocument createNew({
    String name = 'Untitled',
    double stageWidth = 1920,
    double stageHeight = 1080,
    int fps = 24,
    VecColor backgroundColor = VecColor.white,
  }) {
    _currentFilePath = null;
    _isDirty = false;
    stopAutosave();
    return VecDocument.blank(
      name: name,
      stageWidth: stageWidth,
      stageHeight: stageHeight,
      fps: fps,
      backgroundColor: backgroundColor,
    );
  }

  /// Opens a `.vct` file. If a newer autosave exists, [onAutosaveFound] is
  /// called with the recovered document so the caller can decide whether to
  /// use it.
  Future<VecDocument> openFile(
    String filePath, {
    Future<bool> Function(VecDocument recovered)? onAutosaveFound,
  }) async {
    _currentFilePath = filePath;
    _isDirty = false;

    if (onAutosaveFound != null &&
        await _repository.hasNewerAutosave(filePath)) {
      final recovered = await _repository.loadAutosave(filePath);
      if (recovered != null) {
        final useRecovered = await onAutosaveFound(recovered);
        if (useRecovered) {
          return recovered;
        }
      }
    }

    return _repository.loadFromFile(filePath);
  }

  /// Saves the document to the current file path.
  /// Throws [StateError] if no file path has been set (use [saveAs] instead).
  Future<void> save(VecDocument document) async {
    if (_currentFilePath == null) {
      throw StateError(
        'No file path set. Use saveAs() for new documents.',
      );
    }
    await _repository.saveToFile(_currentFilePath!, document);
    await _repository.deleteAutosave(_currentFilePath!);
    _isDirty = false;
  }

  /// Saves the document to a new file path.
  Future<void> saveAs(VecDocument document, String filePath) async {
    _currentFilePath = filePath;
    await _repository.saveToFile(filePath, document);
    await _repository.deleteAutosave(filePath);
    _isDirty = false;
  }

  /// Marks the document as having unsaved changes.
  void markDirty() {
    _isDirty = true;
  }

  /// Starts periodic autosave. [getCurrentDocument] is called each interval
  /// to get the latest document state.
  void startAutosave(
    VecDocument Function() getCurrentDocument, {
    Duration interval = const Duration(seconds: 30),
  }) {
    stopAutosave();
    _autosaveTimer = Timer.periodic(interval, (_) async {
      if (_isDirty && _currentFilePath != null) {
        await _repository.saveAutosave(
          _currentFilePath!,
          getCurrentDocument(),
        );
      }
    });
  }

  /// Stops the autosave timer.
  void stopAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = null;
  }

  /// Returns the default save directory.
  Future<String> getDefaultSaveDirectory() =>
      _repository.getDefaultSaveDirectory();

  void dispose() {
    stopAutosave();
  }
}
