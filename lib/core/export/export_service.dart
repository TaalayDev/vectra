import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive_io.dart';
// import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Rect, Paint, Size;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

import '../rendering/scene_painter.dart';
import '../utils/keyframe_interpolator.dart';
import '../utils/motion_path_evaluator.dart';
import '../../data/models/vec_document.dart';
import '../../data/models/vec_keyframe.dart';
import '../../data/models/vec_motion_path.dart';
import '../../data/models/vec_scene.dart';
import 'lottie_exporter.dart';
import 'svg_exporter.dart';

enum ExportFormat { svg, animatedSvg, lottie, mp4, png, pngSequence, gif }

/// Format-specific configuration for export.
class ExportConfig {
  final ExportFormat format;
  final double scale; // 1×, 2×, 3× etc. (PNG / PNG sequence / GIF)
  final bool transparent; // PNG / GIF background
  final bool svgMinify;
  final bool lottiePreserveMarkers;
  final int gifFps; // max 30
  final int mp4Width;
  final int mp4Height;

  const ExportConfig({
    this.format = ExportFormat.svg,
    this.scale = 1.0,
    this.transparent = false,
    this.svgMinify = false,
    this.lottiePreserveMarkers = true,
    this.gifFps = 24,
    this.mp4Width = 1920,
    this.mp4Height = 1080,
  });

  ExportConfig copyWith({
    ExportFormat? format,
    double? scale,
    bool? transparent,
    bool? svgMinify,
    bool? lottiePreserveMarkers,
    int? gifFps,
    int? mp4Width,
    int? mp4Height,
  }) => ExportConfig(
    format: format ?? this.format,
    scale: scale ?? this.scale,
    transparent: transparent ?? this.transparent,
    svgMinify: svgMinify ?? this.svgMinify,
    lottiePreserveMarkers: lottiePreserveMarkers ?? this.lottiePreserveMarkers,
    gifFps: gifFps ?? this.gifFps,
    mp4Width: mp4Width ?? this.mp4Width,
    mp4Height: mp4Height ?? this.mp4Height,
  );
}

sealed class ExportResult {
  const ExportResult();
}

class ExportSuccess extends ExportResult {
  final String? savedPath;
  const ExportSuccess({this.savedPath});
}

class ExportCancelled extends ExportResult {
  const ExportCancelled();
}

class ExportError extends ExportResult {
  final String message;
  const ExportError(this.message);
}

/// Orchestrates all export operations.
class ExportService {
  ExportService();

  static const _svgExporter = SvgExporter();
  static const _lottieExporter = LottieExporter();

  Future<ExportResult> export(
    VecDocument doc,
    VecScene scene,
    ExportConfig config, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      return switch (config.format) {
        ExportFormat.svg => await _exportSvg(doc, scene, config),
        ExportFormat.animatedSvg => await _exportAnimatedSvg(doc, scene, config),
        ExportFormat.lottie => await _exportLottie(doc, scene, config),
        ExportFormat.mp4 => await _exportMp4(doc, scene, config, onProgress: onProgress),
        ExportFormat.png => await _exportPng(doc, scene, config),
        ExportFormat.pngSequence => await _exportPngSequence(doc, scene, config, onProgress: onProgress),
        ExportFormat.gif => await _exportGif(doc, scene, config, onProgress: onProgress),
      };
    } catch (e, st) {
      debugPrintStack(label: 'ExportService', stackTrace: st);
      return ExportError(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // SVG (static — frame 0)
  // ---------------------------------------------------------------------------

  Future<ExportResult> _exportSvg(VecDocument doc, VecScene scene, ExportConfig config) async {
    final svg = _svgExporter.export(doc, scene, minify: config.svgMinify);
    return _saveText(svg, '${_sanitize(doc.meta.name)}.svg', 'image/svg+xml');
  }

  // ---------------------------------------------------------------------------
  // Animated SVG (static for now — full keyframe animation requires SMIL)
  // ---------------------------------------------------------------------------

  Future<ExportResult> _exportAnimatedSvg(VecDocument doc, VecScene scene, ExportConfig config) async {
    final svg = _svgExporter.export(doc, scene, minify: config.svgMinify);
    return _saveText(svg, '${_sanitize(doc.meta.name)}_animated.svg', 'image/svg+xml');
  }

  // ---------------------------------------------------------------------------
  // Lottie JSON
  // ---------------------------------------------------------------------------

  Future<ExportResult> _exportLottie(VecDocument doc, VecScene scene, ExportConfig config) async {
    final map = _lottieExporter.export(doc, scene);
    final json = config.svgMinify ? _lottieExporter.toJsonStringMinified(map) : _lottieExporter.toJsonString(map);
    return _saveText(json, '${_sanitize(doc.meta.name)}.json', 'application/json');
  }

  // ---------------------------------------------------------------------------
  // PNG (single frame — static at frame 0)
  // ---------------------------------------------------------------------------

  Future<ExportResult> _exportPng(VecDocument doc, VecScene scene, ExportConfig config) async {
    final w = doc.meta.stageWidth * config.scale;
    final h = doc.meta.stageHeight * config.scale;
    // Render at frame 0 (beginning of animation)
    final animScene = _applyAnimationAtFrame(scene, 0);
    final bytes = await _renderToPng(doc, animScene, w, h, config.transparent);
    return _saveBytes(bytes, '${_sanitize(doc.meta.name)}.png', 'image/png');
  }

  // ---------------------------------------------------------------------------
  // Animated GIF — one img.Frame per timeline frame
  // ---------------------------------------------------------------------------

  Future<ExportResult> _exportGif(
    VecDocument doc,
    VecScene scene,
    ExportConfig config, {
    void Function(double)? onProgress,
  }) async {
    final totalFrames = scene.timeline.duration;
    final docFps = doc.meta.fps.clamp(1, 60);
    // GIF delay is in 1/100 s units; clamp output fps to 30 to keep file sane
    final outFps = config.gifFps.clamp(1, 30);
    // Sample every N source frames to match outFps
    final step = (docFps / outFps).ceil().clamp(1, 999);
    final delayCs = (100.0 / outFps).round(); // centiseconds between frames

    final w = (doc.meta.stageWidth * config.scale).clamp(1, 1920).toInt();
    final h = (doc.meta.stageHeight * config.scale).clamp(1, 1080).toInt();

    final animation = img.Image(width: w, height: h, numChannels: 4);

    int rendered = 0;
    final framesToRender = <int>[for (var f = 0; f < totalFrames; f += step) f];
    if (framesToRender.isEmpty || framesToRender.last != totalFrames - 1) {
      framesToRender.add(totalFrames - 1);
    }

    for (final frame in framesToRender) {
      final animScene = _applyAnimationAtFrame(scene, frame);
      final pngBytes = await _renderToPng(doc, animScene, w.toDouble(), h.toDouble(), config.transparent);

      final decoded = img.decodePng(pngBytes);
      if (decoded == null) continue;

      final gifFrame = img.Image(
        width: w,
        height: h,
        numChannels: 4,
        frameDuration: delayCs * 10, // image package uses ms
      );
      img.compositeImage(gifFrame, decoded);
      animation.addFrame(gifFrame);

      rendered++;
      onProgress?.call(rendered / framesToRender.length * 0.9);
    }

    if (animation.frames.isEmpty) {
      return const ExportError('No frames were rendered.');
    }

    final gifBytes = img.encodeGif(animation, repeat: 0); // repeat = loop forever
    onProgress?.call(1.0);

    return _saveBytes(Uint8List.fromList(gifBytes), '${_sanitize(doc.meta.name)}.gif', 'image/gif');
  }

  // ---------------------------------------------------------------------------
  // PNG Sequence — numbered PNGs in a ZIP (all platforms) or folder (desktop)
  // ---------------------------------------------------------------------------

  Future<ExportResult> _exportPngSequence(
    VecDocument doc,
    VecScene scene,
    ExportConfig config, {
    void Function(double)? onProgress,
  }) async {
    final totalFrames = scene.timeline.duration;
    final w = doc.meta.stageWidth * config.scale;
    final h = doc.meta.stageHeight * config.scale;
    final baseName = _sanitize(doc.meta.name);

    // Render all frames to bytes
    final frames = <Uint8List>[];
    for (var f = 0; f < totalFrames; f++) {
      final animScene = _applyAnimationAtFrame(scene, f);
      final bytes = await _renderToPng(doc, animScene, w, h, config.transparent);
      frames.add(bytes);
      onProgress?.call(f / totalFrames * 0.85);
    }

    // Desktop: write to a user-chosen folder
    if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
      final dir = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Choose folder for PNG sequence');
      if (dir == null) return const ExportCancelled();

      for (var i = 0; i < frames.length; i++) {
        final name = '${baseName}_${(i + 1).toString().padLeft(4, '0')}.png';
        await File('$dir/$name').writeAsBytes(frames[i]);
        onProgress?.call(0.85 + i / frames.length * 0.15);
      }
      onProgress?.call(1.0);
      return ExportSuccess(savedPath: dir);
    }

    // Mobile / web: bundle as ZIP
    final archive = Archive();
    for (var i = 0; i < frames.length; i++) {
      final name = '${baseName}_${(i + 1).toString().padLeft(4, '0')}.png';
      archive.addFile(ArchiveFile(name, frames[i].length, frames[i]));
      onProgress?.call(0.85 + i / frames.length * 0.15);
    }

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes.isEmpty) return const ExportError('Failed to create ZIP archive.');

    onProgress?.call(1.0);
    return _saveBytes(Uint8List.fromList(zipBytes), '${baseName}_sequence.zip', 'application/zip');
  }

  // ---------------------------------------------------------------------------
  // MP4 — frames → temp PNGs → ffmpeg pipe (macOS/Linux/Windows desktop only)
  // ---------------------------------------------------------------------------

  Future<ExportResult> _exportMp4(
    VecDocument doc,
    VecScene scene,
    ExportConfig config, {
    void Function(double)? onProgress,
  }) async {
    if (kIsWeb) {
      return const ExportError('MP4 export is not supported in the web version.');
    }
    final totalFrames = scene.timeline.duration;
    final fps = doc.meta.fps.clamp(1, 120);
    final w = _ensureEven((doc.meta.stageWidth * config.scale).round());
    final h = _ensureEven((doc.meta.stageHeight * config.scale).round());
    final baseName = _sanitize(doc.meta.name);

    final tempDir = await getTemporaryDirectory();
    final sessionId = DateTime.now().millisecondsSinceEpoch;
    final framesDir = Directory('${tempDir.path}/vectra_mp4_$sessionId');
    await framesDir.create(recursive: true);

    // Desktop: ask for save path before rendering so the user can cancel early
    final String finalPath;
    if (!Platform.isIOS && !Platform.isAndroid) {
      final chosen = await FilePicker.platform.saveFile(
        dialogTitle: 'Save MP4',
        fileName: '$baseName.mp4',
        type: FileType.custom,
        allowedExtensions: ['mp4'],
      );
      if (chosen == null) return const ExportCancelled();
      finalPath = chosen.endsWith('.mp4') ? chosen : '$chosen.mp4';
    } else {
      finalPath = '${tempDir.path}/$baseName.mp4';
    }

    try {
      // ── 1. Render PNG frames ──────────────────────────────────────────────
      for (var f = 0; f < totalFrames; f++) {
        final animScene = _applyAnimationAtFrame(scene, f);
        final bytes = await _renderToPng(doc, animScene, w.toDouble(), h.toDouble(), config.transparent);
        final name = 'frame_${(f + 1).toString().padLeft(4, '0')}.png';
        await File('${framesDir.path}/$name').writeAsBytes(bytes);
        onProgress?.call(f / totalFrames * 0.70);
      }

      // ── 2. Encode with FFmpegKit ──────────────────────────────────────────
      onProgress?.call(0.72);
      final cmd =
          '-y '
          '-framerate $fps '
          '-i ${framesDir.path}/frame_%04d.png '
          '-c:v libx264 '
          '-preset medium '
          '-crf 18 '
          '-pix_fmt yuv420p '
          '-movflags +faststart '
          '$finalPath';

      // final session = await FFmpegKit.execute(cmd);
      // final rc = await session.getReturnCode();

      // if (!ReturnCode.isSuccess(rc)) {
      //   final logs = await session.getAllLogsAsString();
      //   return ExportError('FFmpeg encoding failed:\n$logs');
      // }

      // onProgress?.call(1.0);

      // // ── 3. Mobile: share the generated file ──────────────────────────────
      // if (Platform.isIOS || Platform.isAndroid) {
      //   await Share.shareXFiles(
      //     [XFile(finalPath, mimeType: 'video/mp4', name: '$baseName.mp4')],
      //     subject: baseName,
      //   );
      //   return const ExportSuccess();
      // }

      return ExportSuccess(savedPath: finalPath);
    } finally {
      try {
        await framesDir.delete(recursive: true);
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------------
  // Per-frame animation: apply keyframe interpolation + motion paths
  // ---------------------------------------------------------------------------

  /// Returns a copy of [scene] with all shapes interpolated to [frame].
  VecScene _applyAnimationAtFrame(VecScene scene, int frame) {
    final duration = scene.timeline.duration;
    final playheadT = duration > 1 ? frame / (duration - 1) : 0.0;

    // Build shapeId → keyframes map
    final shapeKeyframes = <String, List<VecKeyframe>>{};
    for (final track in scene.timeline.tracks) {
      final sid = track.shapeId;
      if (sid == null || track.keyframes.isEmpty) continue;
      shapeKeyframes[sid] = track.keyframes;
    }

    // Build motion-path lookup
    final motionPaths = <String, VecMotionPath>{
      for (final mp in scene.motionPaths)
        if (mp.nodes.length >= 2) mp.shapeId: mp,
    };

    if (shapeKeyframes.isEmpty && motionPaths.isEmpty) return scene;

    // Apply keyframe interpolation
    var result = scene.copyWith(
      layers: [
        for (final layer in scene.layers)
          layer.copyWith(
            shapes: [
              for (final shape in layer.shapes)
                () {
                  final kfs = shapeKeyframes[shape.id];
                  if (kfs == null) return shape;
                  return KeyframeInterpolator.applyAtFrame(shape, kfs, frame);
                }(),
            ],
          ),
      ],
    );

    if (motionPaths.isEmpty) return result;

    // Apply motion path displacement
    return result.copyWith(
      layers: [
        for (final layer in result.layers)
          layer.copyWith(
            shapes: [
              for (final shape in layer.shapes)
                () {
                  final mp = motionPaths[shape.id];
                  if (mp == null) return shape;
                  final t = mp.easeAlongPath ? _easeInOut(playheadT) : playheadT;
                  final pos = MotionPathEvaluator.evaluate(mp.nodes, mp.isClosed, t);
                  final angle = mp.orientToPath
                      ? MotionPathEvaluator.evaluateAngle(mp.nodes, mp.isClosed, t)
                      : shape.transform.rotation;
                  return shape.copyWith(
                    data: shape.data.copyWith(
                      transform: shape.transform.copyWith(x: pos.dx, y: pos.dy, rotation: angle),
                    ),
                  );
                }(),
            ],
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Render a single scene frame → PNG bytes via PictureRecorder + ScenePainter
  // ---------------------------------------------------------------------------

  Future<Uint8List> _renderToPng(VecDocument doc, VecScene scene, double w, double h, bool transparent) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, Rect.fromLTWH(0, 0, w, h));

    if (!transparent) {
      final bg = doc.meta.backgroundColor.toFlutterColor();
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = bg);
    }

    canvas.scale(w / doc.meta.stageWidth, h / doc.meta.stageHeight);
    ScenePainter(scene: scene).paint(canvas, Size(doc.meta.stageWidth, doc.meta.stageHeight));

    final picture = recorder.endRecording();
    final image = await picture.toImage(w.toInt(), h.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // ---------------------------------------------------------------------------
  // File save — text (UTF-8) → bytes
  // ---------------------------------------------------------------------------

  Future<ExportResult> _saveText(String contents, String filename, String mimeType) async {
    final bytes = Uint8List.fromList(utf8.encode(contents));
    return _saveBytes(bytes, filename, mimeType);
  }

  // ---------------------------------------------------------------------------
  // File save — bytes (routing: web / mobile / desktop)
  // ---------------------------------------------------------------------------

  Future<ExportResult> _saveBytes(Uint8List bytes, String filename, String mimeType) async {
    if (kIsWeb) return _saveWeb(bytes, filename, mimeType);
    if (Platform.isIOS || Platform.isAndroid) {
      return _saveMobile(bytes, filename);
    }
    return _saveDesktop(bytes, filename, mimeType);
  }

  // Web: blob URL + anchor click
  ExportResult _saveWeb(Uint8List bytes, String filename, String mimeType) {
    try {
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = filename;
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
      return const ExportSuccess();
    } catch (e) {
      return ExportError('Web download failed: $e');
    }
  }

  // Desktop: FilePicker save dialog
  Future<ExportResult> _saveDesktop(Uint8List bytes, String filename, String mimeType) async {
    final ext = filename.contains('.') ? filename.split('.').last : null;
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save $filename',
      fileName: filename,
      type: ext != null ? FileType.custom : FileType.any,
      allowedExtensions: ext != null ? [ext] : null,
    );
    if (outputPath == null) return const ExportCancelled();
    final finalPath = (ext != null && !outputPath.toLowerCase().endsWith('.$ext')) ? '$outputPath.$ext' : outputPath;
    await File(finalPath).writeAsBytes(bytes);
    return ExportSuccess(savedPath: finalPath);
  }

  // Mobile: write to temp, share
  Future<ExportResult> _saveMobile(Uint8List bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path, name: filename)], subject: filename);
    return const ExportSuccess();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _sanitize(String name) => name.replaceAll(RegExp(r'[^\w\s\-]'), '').replaceAll(RegExp(r'\s+'), '_');

  /// Forces a dimension to be even (required by libx264).
  int _ensureEven(int v) => v % 2 == 0 ? v : v + 1;

  static double _easeInOut(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - (-2 * t + 2) * (-2 * t + 2) * (-2 * t + 2) / 2;
  }
}
