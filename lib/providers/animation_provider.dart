import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/utils/keyframe_interpolator.dart';
import '../core/utils/motion_path_evaluator.dart';
import '../data/models/vec_keyframe.dart';
import '../data/models/vec_scene.dart';
import '../data/models/vec_timeline.dart';
import 'document_provider.dart';
import 'editor_state_provider.dart';

part 'animation_provider.g.dart';

// ---------------------------------------------------------------------------
// Playback timer
// ---------------------------------------------------------------------------

/// Void provider that drives [PlayheadFrame] forward at the current fps.
/// Rebuilds (and restarts the timer) whenever [isPlayingProvider] or fps changes.
/// Watch this once in a long-lived widget so the timer is always running.
@Riverpod(keepAlive: true)
void playbackTicker(PlaybackTickerRef ref) {
  final isPlaying = ref.watch(isPlayingProvider);
  if (!isPlaying) return;

  final fps = ref.watch(currentMetaProvider).fps.clamp(1, 240);
  final scene = ref.watch(activeSceneProvider);
  final duration = scene?.timeline.duration ?? 72;
  final loopType = scene?.timeline.loopType ?? VecLoopType.loop;

  final timer = Timer.periodic(
    Duration(milliseconds: (1000.0 / fps).round()),
    (_) {
      final current = ref.read(playheadFrameProvider);
      final next = current + 1;
      if (next >= duration) {
        switch (loopType) {
          case VecLoopType.loop:
          case VecLoopType.pingPong:
            ref.read(playheadFrameProvider.notifier).set(0);
          case VecLoopType.playOnce:
            ref.read(playheadFrameProvider.notifier).set(duration - 1);
            ref.read(isPlayingProvider.notifier).set(false);
        }
      } else {
        ref.read(playheadFrameProvider.notifier).set(next);
      }
    },
  );

  ref.onDispose(timer.cancel);
}

// ---------------------------------------------------------------------------
// Animated scene
// ---------------------------------------------------------------------------

/// Returns a version of [activeSceneProvider] with shape transforms/opacities/
/// fills/strokes interpolated to the current [PlayheadFrame].
///
/// Shapes that have no shape-level track are returned unchanged.
@riverpod
VecScene? animatedScene(AnimatedSceneRef ref) {
  final scene = ref.watch(activeSceneProvider);
  if (scene == null) return null;

  final playhead = ref.watch(playheadFrameProvider);

  // Build map: shapeId → keyframes list
  final shapeKeyframes = <String, List<VecKeyframe>>{};
  for (final track in scene.timeline.tracks) {
    final sid = track.shapeId;
    if (sid == null || track.keyframes.isEmpty) continue;
    shapeKeyframes[sid] = track.keyframes;
  }

  // Build normalised playhead t ∈ [0,1] based on timeline duration
  final duration = scene.timeline.duration;
  final playheadT = duration > 1 ? playhead / (duration - 1) : 0.0;

  // Build motion-path lookup: shapeId → VecMotionPath
  final motionPaths = {
    for (final mp in scene.motionPaths)
      if (mp.nodes.length >= 2) mp.shapeId: mp,
  };

  final interpolatedScene = shapeKeyframes.isEmpty
      ? scene
      : scene.copyWith(
          layers: [
            for (final layer in scene.layers)
              layer.copyWith(
                shapes: [
                  for (final shape in layer.shapes)
                    () {
                      final kfs = shapeKeyframes[shape.id];
                      if (kfs == null) return shape;
                      return KeyframeInterpolator.applyAtFrame(
                          shape, kfs, playhead);
                    }(),
                ],
              ),
          ],
        );

  if (motionPaths.isEmpty) return interpolatedScene;

  // Apply motion path displacement
  return interpolatedScene.copyWith(
    layers: [
      for (final layer in interpolatedScene.layers)
        layer.copyWith(
          shapes: [
            for (final shape in layer.shapes)
              () {
                final mp = motionPaths[shape.id];
                if (mp == null) return shape;
                final t = mp.easeAlongPath ? _easeInOut(playheadT) : playheadT;
                final pos = MotionPathEvaluator.evaluate(
                    mp.nodes, mp.isClosed, t);
                final angle = mp.orientToPath
                    ? MotionPathEvaluator.evaluateAngle(
                        mp.nodes, mp.isClosed, t)
                    : shape.transform.rotation;
                return shape.copyWith(
                  data: shape.data.copyWith(
                    transform: shape.transform.copyWith(
                      x: pos.dx,
                      y: pos.dy,
                      rotation: mp.orientToPath ? angle : shape.transform.rotation,
                    ),
                  ),
                );
              }(),
          ],
        ),
    ],
  );
}

double _easeInOut(double t) {
  // Cubic ease-in-out
  return t < 0.5 ? 4 * t * t * t : 1 - (-2 * t + 2) * (-2 * t + 2) * (-2 * t + 2) / 2;
}
