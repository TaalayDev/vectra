import 'models/vec_easing.dart';
import 'models/vec_keyframe.dart';
import 'models/vec_transform.dart';

// ---------------------------------------------------------------------------
// Preset model
// ---------------------------------------------------------------------------

enum AnimationPresetCategory { enter, exit, loop, attention }

/// A single relative keyframe within a preset.
/// [frameOffset] is relative to the start / application frame.
class PresetKeyframe {
  const PresetKeyframe({
    required this.frameOffset,
    required this.keyframe,
  });

  final int frameOffset;
  final VecKeyframe keyframe;
}

/// A named animation preset consisting of a list of relative keyframes.
class AnimationPreset {
  const AnimationPreset({
    required this.id,
    required this.name,
    required this.category,
    required this.keyframes,
    this.description = '',
  });

  final String id;
  final String name;
  final AnimationPresetCategory category;
  final List<PresetKeyframe> keyframes;
  final String description;

  /// Duration in frames (offset of the last keyframe).
  int get duration => keyframes.isEmpty ? 0 : keyframes.last.frameOffset;
}

// ---------------------------------------------------------------------------
// Built-in preset library
// ---------------------------------------------------------------------------

const _easeOut = VecEasing.preset(preset: VecEasingPreset.easeOut);
const _easeIn = VecEasing.preset(preset: VecEasingPreset.easeIn);
const _easeInOut = VecEasing.preset(preset: VecEasingPreset.easeInOut);
const _spring = VecEasing.preset(preset: VecEasingPreset.spring);
const _elastic = VecEasing.preset(preset: VecEasingPreset.elastic);

class AnimationPresets {
  AnimationPresets._();

  static final List<AnimationPreset> builtIn = [
    // ── Enter ─────────────────────────────────────────────────────────────
    AnimationPreset(
      id: 'enter_fade_in',
      name: 'Fade In',
      category: AnimationPresetCategory.enter,
      description: 'Fade from transparent to opaque',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(frame: 0, opacity: 0.0, easing: _easeOut),
        ),
        PresetKeyframe(
          frameOffset: 18,
          keyframe: VecKeyframe(frame: 18, opacity: 1.0),
        ),
      ],
    ),
    AnimationPreset(
      id: 'enter_slide_up',
      name: 'Slide Up',
      category: AnimationPresetCategory.enter,
      description: 'Slide in from below',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 0.0,
            transform: VecTransform(x: 0, y: 60, width: 100, height: 100),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 18,
          keyframe: VecKeyframe(
            frame: 18,
            opacity: 1.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'enter_slide_down',
      name: 'Slide Down',
      category: AnimationPresetCategory.enter,
      description: 'Slide in from above',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 0.0,
            transform: VecTransform(x: 0, y: -60, width: 100, height: 100),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 18,
          keyframe: VecKeyframe(
            frame: 18,
            opacity: 1.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'enter_scale_up',
      name: 'Scale Up',
      category: AnimationPresetCategory.enter,
      description: 'Grow from small to full size',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 0.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 0.0, scaleY: 0.0),
            easing: _spring,
          ),
        ),
        PresetKeyframe(
          frameOffset: 24,
          keyframe: VecKeyframe(
            frame: 24,
            opacity: 1.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'enter_bounce_in',
      name: 'Bounce In',
      category: AnimationPresetCategory.enter,
      description: 'Overshoot spring entrance',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 0.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 0.0, scaleY: 0.0),
            easing: _elastic,
          ),
        ),
        PresetKeyframe(
          frameOffset: 30,
          keyframe: VecKeyframe(
            frame: 30,
            opacity: 1.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
          ),
        ),
      ],
    ),

    // ── Exit ──────────────────────────────────────────────────────────────
    AnimationPreset(
      id: 'exit_fade_out',
      name: 'Fade Out',
      category: AnimationPresetCategory.exit,
      description: 'Fade to transparent',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(frame: 0, opacity: 1.0, easing: _easeIn),
        ),
        PresetKeyframe(
          frameOffset: 18,
          keyframe: VecKeyframe(frame: 18, opacity: 0.0),
        ),
      ],
    ),
    AnimationPreset(
      id: 'exit_slide_down',
      name: 'Slide Down',
      category: AnimationPresetCategory.exit,
      description: 'Slide out downward',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 1.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100),
            easing: _easeIn,
          ),
        ),
        PresetKeyframe(
          frameOffset: 18,
          keyframe: VecKeyframe(
            frame: 18,
            opacity: 0.0,
            transform: VecTransform(x: 0, y: 60, width: 100, height: 100),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'exit_scale_down',
      name: 'Scale Down',
      category: AnimationPresetCategory.exit,
      description: 'Shrink to nothing',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 1.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
            easing: _easeIn,
          ),
        ),
        PresetKeyframe(
          frameOffset: 18,
          keyframe: VecKeyframe(
            frame: 18,
            opacity: 0.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 0.0, scaleY: 0.0),
          ),
        ),
      ],
    ),

    // ── Loop ──────────────────────────────────────────────────────────────
    AnimationPreset(
      id: 'loop_pulse',
      name: 'Pulse',
      category: AnimationPresetCategory.loop,
      description: 'Breathing scale loop',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 18,
          keyframe: VecKeyframe(
            frame: 18,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.1, scaleY: 1.1),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 36,
          keyframe: VecKeyframe(
            frame: 36,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'loop_float',
      name: 'Float',
      category: AnimationPresetCategory.loop,
      description: 'Gentle up-down oscillation',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 24,
          keyframe: VecKeyframe(
            frame: 24,
            transform: VecTransform(x: 0, y: -12, width: 100, height: 100),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 48,
          keyframe: VecKeyframe(
            frame: 48,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'loop_spin',
      name: 'Spin',
      category: AnimationPresetCategory.loop,
      description: '360° continuous rotation',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 0),
            easing: const VecEasing.preset(preset: VecEasingPreset.linear),
          ),
        ),
        PresetKeyframe(
          frameOffset: 36,
          keyframe: VecKeyframe(
            frame: 36,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 360),
          ),
        ),
      ],
    ),

    // ── Attention ─────────────────────────────────────────────────────────
    AnimationPreset(
      id: 'attention_shake',
      name: 'Shake',
      category: AnimationPresetCategory.attention,
      description: 'Rapid horizontal shake',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(frame: 0, transform: VecTransform(x: 0, y: 0, width: 100, height: 100)),
        ),
        PresetKeyframe(
          frameOffset: 4,
          keyframe: VecKeyframe(frame: 4, transform: VecTransform(x: -8, y: 0, width: 100, height: 100)),
        ),
        PresetKeyframe(
          frameOffset: 8,
          keyframe: VecKeyframe(frame: 8, transform: VecTransform(x: 8, y: 0, width: 100, height: 100)),
        ),
        PresetKeyframe(
          frameOffset: 12,
          keyframe: VecKeyframe(frame: 12, transform: VecTransform(x: -6, y: 0, width: 100, height: 100)),
        ),
        PresetKeyframe(
          frameOffset: 16,
          keyframe: VecKeyframe(frame: 16, transform: VecTransform(x: 6, y: 0, width: 100, height: 100)),
        ),
        PresetKeyframe(
          frameOffset: 20,
          keyframe: VecKeyframe(frame: 20, transform: VecTransform(x: 0, y: 0, width: 100, height: 100)),
        ),
      ],
    ),
    AnimationPreset(
      id: 'attention_bounce',
      name: 'Bounce',
      category: AnimationPresetCategory.attention,
      description: 'Quick vertical bounce',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 8,
          keyframe: VecKeyframe(
            frame: 8,
            transform: VecTransform(x: 0, y: -20, width: 100, height: 100),
            easing: _easeIn,
          ),
        ),
        PresetKeyframe(
          frameOffset: 16,
          keyframe: VecKeyframe(
            frame: 16,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 22,
          keyframe: VecKeyframe(
            frame: 22,
            transform: VecTransform(x: 0, y: -10, width: 100, height: 100),
            easing: _easeIn,
          ),
        ),
        PresetKeyframe(
          frameOffset: 28,
          keyframe: VecKeyframe(
            frame: 28,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100),
          ),
        ),
      ],
    ),
  ];
}
