import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/export/export_service.dart';
import '../data/models/vec_document.dart';
import '../data/models/vec_scene.dart';

// ---------------------------------------------------------------------------
// Export state
// ---------------------------------------------------------------------------

enum ExportStatus { idle, exporting, success, cancelled, error }

class ExportState {
  final ExportFormat format;
  final double scale;
  final bool transparent;
  final bool svgMinify;
  final bool lottiePreserveMarkers;
  final int gifFps;
  final int mp4Width;
  final int mp4Height;
  final ExportStatus status;
  final String? errorMessage;
  final String? savedPath;
  final double progress; // 0.0 – 1.0

  const ExportState({
    this.format = ExportFormat.svg,
    this.scale = 1.0,
    this.transparent = false,
    this.svgMinify = false,
    this.lottiePreserveMarkers = true,
    this.gifFps = 24,
    this.mp4Width = 1920,
    this.mp4Height = 1080,
    this.status = ExportStatus.idle,
    this.errorMessage,
    this.savedPath,
    this.progress = 0.0,
  });

  ExportState copyWith({
    ExportFormat? format,
    double? scale,
    bool? transparent,
    bool? svgMinify,
    bool? lottiePreserveMarkers,
    int? gifFps,
    int? mp4Width,
    int? mp4Height,
    ExportStatus? status,
    String? errorMessage,
    String? savedPath,
    double? progress,
  }) => ExportState(
    format: format ?? this.format,
    scale: scale ?? this.scale,
    transparent: transparent ?? this.transparent,
    svgMinify: svgMinify ?? this.svgMinify,
    lottiePreserveMarkers: lottiePreserveMarkers ?? this.lottiePreserveMarkers,
    gifFps: gifFps ?? this.gifFps,
    mp4Width: mp4Width ?? this.mp4Width,
    mp4Height: mp4Height ?? this.mp4Height,
    status: status ?? this.status,
    errorMessage: errorMessage,
    savedPath: savedPath,
    progress: progress ?? this.progress,
  );

  ExportConfig get config => ExportConfig(
    format: format,
    scale: scale,
    transparent: transparent,
    svgMinify: svgMinify,
    lottiePreserveMarkers: lottiePreserveMarkers,
    gifFps: gifFps,
    mp4Width: mp4Width,
    mp4Height: mp4Height,
  );

  bool get isExporting => status == ExportStatus.exporting;
  bool get isIdle => status == ExportStatus.idle;
}

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class ExportNotifier extends StateNotifier<ExportState> {
  ExportNotifier() : super(const ExportState());

  void setFormat(ExportFormat format) =>
      state = state.copyWith(format: format, status: ExportStatus.idle);

  void setScale(double scale) => state = state.copyWith(scale: scale);

  void setTransparent(bool v) => state = state.copyWith(transparent: v);

  void setSvgMinify(bool v) => state = state.copyWith(svgMinify: v);

  void setLottieMarkers(bool v) => state = state.copyWith(lottiePreserveMarkers: v);

  void setGifFps(int fps) => state = state.copyWith(gifFps: fps.clamp(1, 30));

  void setMp4Size(int w, int h) =>
      state = state.copyWith(mp4Width: w.clamp(1, 1920), mp4Height: h.clamp(1, 1080));

  void reset() => state = state.copyWith(
        status: ExportStatus.idle,
        errorMessage: null,
        savedPath: null,
        progress: 0.0,
      );

  Future<void> runExport(VecDocument doc, VecScene scene) async {
    if (state.isExporting) return;

    state = state.copyWith(
      status: ExportStatus.exporting,
      progress: 0.0,
      errorMessage: null,
      savedPath: null,
    );

    final result = await ExportService().export(
      doc,
      scene,
      state.config,
      onProgress: (p) => state = state.copyWith(progress: p.clamp(0.0, 1.0)),
    );

    switch (result) {
      case ExportSuccess(:final savedPath):
        state = state.copyWith(
          status: ExportStatus.success,
          savedPath: savedPath,
          progress: 1.0,
        );
      case ExportCancelled():
        state = state.copyWith(
          status: ExportStatus.cancelled,
          progress: 0.0,
        );
      case ExportError(:final message):
        state = state.copyWith(
          status: ExportStatus.error,
          errorMessage: message,
          progress: 0.0,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final exportProvider = StateNotifierProvider<ExportNotifier, ExportState>(
  (_) => ExportNotifier(),
);
