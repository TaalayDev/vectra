import 'models/vec_easing.dart';
import 'models/vec_keyframe.dart';
import 'models/vec_transform.dart';

// ---------------------------------------------------------------------------
// Preset model
// ---------------------------------------------------------------------------

enum AnimationPresetCategory { enter, exit, loop, attention, transform, reveal }

/// A single relative keyframe within a preset.
/// [frameOffset] is relative to the start / application frame.
class PresetKeyframe {
  const PresetKeyframe({required this.frameOffset, required this.keyframe});

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
        PresetKeyframe(frameOffset: 0, keyframe: VecKeyframe(frame: 0, opacity: 0.0, easing: _easeOut)),
        PresetKeyframe(frameOffset: 18, keyframe: VecKeyframe(frame: 18, opacity: 1.0)),
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
          keyframe: VecKeyframe(frame: 18, opacity: 1.0, transform: VecTransform(x: 0, y: 0, width: 100, height: 100)),
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
          keyframe: VecKeyframe(frame: 18, opacity: 1.0, transform: VecTransform(x: 0, y: 0, width: 100, height: 100)),
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
    AnimationPreset(
      id: 'enter_slide_left',
      name: 'Slide Left',
      category: AnimationPresetCategory.enter,
      description: 'Slide in from the right side',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 0.0,
            transform: VecTransform(x: 80, y: 0, width: 100, height: 100),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 18,
          keyframe: VecKeyframe(frame: 18, opacity: 1.0, transform: VecTransform(x: 0, y: 0, width: 100, height: 100)),
        ),
      ],
    ),
    AnimationPreset(
      id: 'enter_slide_right',
      name: 'Slide Right',
      category: AnimationPresetCategory.enter,
      description: 'Slide in from the left side',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 0.0,
            transform: VecTransform(x: -80, y: 0, width: 100, height: 100),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 18,
          keyframe: VecKeyframe(frame: 18, opacity: 1.0, transform: VecTransform(x: 0, y: 0, width: 100, height: 100)),
        ),
      ],
    ),
    AnimationPreset(
      id: 'enter_zoom_fade',
      name: 'Zoom Fade In',
      category: AnimationPresetCategory.enter,
      description: 'Subtle zoom and fade entrance',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 0.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 0.85, scaleY: 0.85),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 20,
          keyframe: VecKeyframe(
            frame: 20,
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
        PresetKeyframe(frameOffset: 0, keyframe: VecKeyframe(frame: 0, opacity: 1.0, easing: _easeIn)),
        PresetKeyframe(frameOffset: 18, keyframe: VecKeyframe(frame: 18, opacity: 0.0)),
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
          keyframe: VecKeyframe(frame: 18, opacity: 0.0, transform: VecTransform(x: 0, y: 60, width: 100, height: 100)),
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
    AnimationPreset(
      id: 'exit_slide_left',
      name: 'Slide Left',
      category: AnimationPresetCategory.exit,
      description: 'Slide out to the left',
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
            transform: VecTransform(x: -80, y: 0, width: 100, height: 100),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'exit_slide_right',
      name: 'Slide Right',
      category: AnimationPresetCategory.exit,
      description: 'Slide out to the right',
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
          keyframe: VecKeyframe(frame: 18, opacity: 0.0, transform: VecTransform(x: 80, y: 0, width: 100, height: 100)),
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
          keyframe: VecKeyframe(frame: 48, transform: VecTransform(x: 0, y: 0, width: 100, height: 100)),
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
          keyframe: VecKeyframe(frame: 36, transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 360)),
        ),
      ],
    ),
    AnimationPreset(
      id: 'loop_breathe_opacity',
      name: 'Breathe Opacity',
      category: AnimationPresetCategory.loop,
      description: 'Gentle opacity breathing loop',
      keyframes: [
        PresetKeyframe(frameOffset: 0, keyframe: VecKeyframe(frame: 0, opacity: 1.0, easing: _easeInOut)),
        PresetKeyframe(frameOffset: 20, keyframe: VecKeyframe(frame: 20, opacity: 0.65, easing: _easeInOut)),
        PresetKeyframe(frameOffset: 40, keyframe: VecKeyframe(frame: 40, opacity: 1.0)),
      ],
    ),
    AnimationPreset(
      id: 'loop_wobble',
      name: 'Wobble',
      category: AnimationPresetCategory.loop,
      description: 'Small alternating rotation wobble',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 0),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 10,
          keyframe: VecKeyframe(
            frame: 10,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: -6),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 20,
          keyframe: VecKeyframe(
            frame: 20,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 6),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 30,
          keyframe: VecKeyframe(frame: 30, transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 0)),
        ),
      ],
    ),
    AnimationPreset(
      id: 'loop_sway',
      name: 'Sway',
      category: AnimationPresetCategory.loop,
      description: 'Horizontal drifting sway',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: -8, y: 0, width: 100, height: 100),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 24,
          keyframe: VecKeyframe(
            frame: 24,
            transform: VecTransform(x: 8, y: 0, width: 100, height: 100),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 48,
          keyframe: VecKeyframe(frame: 48, transform: VecTransform(x: -8, y: 0, width: 100, height: 100)),
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
          keyframe: VecKeyframe(frame: 28, transform: VecTransform(x: 0, y: 0, width: 100, height: 100)),
        ),
      ],
    ),
    AnimationPreset(
      id: 'attention_nudge',
      name: 'Nudge',
      category: AnimationPresetCategory.attention,
      description: 'Quick directional nudge',
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
          frameOffset: 6,
          keyframe: VecKeyframe(
            frame: 6,
            transform: VecTransform(x: 18, y: 0, width: 100, height: 100),
            easing: _easeIn,
          ),
        ),
        PresetKeyframe(
          frameOffset: 12,
          keyframe: VecKeyframe(frame: 12, transform: VecTransform(x: 0, y: 0, width: 100, height: 100)),
        ),
      ],
    ),
    AnimationPreset(
      id: 'attention_tada',
      name: 'Ta-da',
      category: AnimationPresetCategory.attention,
      description: 'Pop scale with quick rotation accent',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0, rotation: 0),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 8,
          keyframe: VecKeyframe(
            frame: 8,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.18, scaleY: 1.18, rotation: -8),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 16,
          keyframe: VecKeyframe(
            frame: 16,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0, rotation: 0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'attention_flip',
      name: 'Flip',
      category: AnimationPresetCategory.attention,
      description: 'Fast rotational flip accent',
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
          frameOffset: 16,
          keyframe: VecKeyframe(frame: 16, transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 360)),
        ),
      ],
    ),
    AnimationPreset(
      id: 'attention_rubber_band',
      name: 'Rubber Band',
      category: AnimationPresetCategory.attention,
      description: 'Stretchy rubber-band snap',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 6,
          keyframe: VecKeyframe(
            frame: 6,
            transform: VecTransform(x: 16, y: 0, width: 100, height: 100, scaleX: 0.78, scaleY: 1.22),
            easing: _spring,
          ),
        ),
        PresetKeyframe(
          frameOffset: 14,
          keyframe: VecKeyframe(
            frame: 14,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.12, scaleY: 0.88),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 22,
          keyframe: VecKeyframe(
            frame: 22,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'attention_jello',
      name: 'Jello',
      category: AnimationPresetCategory.attention,
      description: 'Wobbly scale jiggle',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 5,
          keyframe: VecKeyframe(
            frame: 5,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.2, scaleY: 0.8),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 10,
          keyframe: VecKeyframe(
            frame: 10,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 0.88, scaleY: 1.12),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 15,
          keyframe: VecKeyframe(
            frame: 15,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.08, scaleY: 0.92),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 20,
          keyframe: VecKeyframe(
            frame: 20,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 0.96, scaleY: 1.04),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 26,
          keyframe: VecKeyframe(
            frame: 26,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'attention_head_shake',
      name: 'Head Shake',
      category: AnimationPresetCategory.attention,
      description: 'Side-to-side shake with tilt',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 0),
          ),
        ),
        PresetKeyframe(
          frameOffset: 5,
          keyframe: VecKeyframe(
            frame: 5,
            transform: VecTransform(x: -12, y: 0, width: 100, height: 100, rotation: -5),
          ),
        ),
        PresetKeyframe(
          frameOffset: 10,
          keyframe: VecKeyframe(
            frame: 10,
            transform: VecTransform(x: 12, y: 0, width: 100, height: 100, rotation: 5),
          ),
        ),
        PresetKeyframe(
          frameOffset: 15,
          keyframe: VecKeyframe(
            frame: 15,
            transform: VecTransform(x: -8, y: 0, width: 100, height: 100, rotation: -3),
          ),
        ),
        PresetKeyframe(
          frameOffset: 20,
          keyframe: VecKeyframe(
            frame: 20,
            transform: VecTransform(x: 8, y: 0, width: 100, height: 100, rotation: 3),
          ),
        ),
        PresetKeyframe(
          frameOffset: 26,
          keyframe: VecKeyframe(
            frame: 26,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'attention_swing',
      name: 'Swing',
      category: AnimationPresetCategory.attention,
      description: 'Pendulum-like rotation swing',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 0),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 8,
          keyframe: VecKeyframe(
            frame: 8,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 22),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 16,
          keyframe: VecKeyframe(
            frame: 16,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: -16),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 24,
          keyframe: VecKeyframe(
            frame: 24,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 10),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 32,
          keyframe: VecKeyframe(
            frame: 32,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'attention_zoom_pulse',
      name: 'Zoom Pulse',
      category: AnimationPresetCategory.attention,
      description: 'Quick scale-up emphasis pop',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 8,
          keyframe: VecKeyframe(
            frame: 8,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.3, scaleY: 1.3),
            easing: _spring,
          ),
        ),
        PresetKeyframe(
          frameOffset: 20,
          keyframe: VecKeyframe(
            frame: 20,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'attention_heartbeat',
      name: 'Heartbeat',
      category: AnimationPresetCategory.attention,
      description: 'Double-thump heartbeat pulse',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 5,
          keyframe: VecKeyframe(
            frame: 5,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.18, scaleY: 1.18),
            easing: _easeIn,
          ),
        ),
        PresetKeyframe(
          frameOffset: 10,
          keyframe: VecKeyframe(
            frame: 10,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 14,
          keyframe: VecKeyframe(
            frame: 14,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.12, scaleY: 1.12),
            easing: _easeIn,
          ),
        ),
        PresetKeyframe(
          frameOffset: 20,
          keyframe: VecKeyframe(
            frame: 20,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
          ),
        ),
      ],
    ),

    // ── Enter (additional) ────────────────────────────────────────────────
    AnimationPreset(
      id: 'enter_spiral_in',
      name: 'Spiral In',
      category: AnimationPresetCategory.enter,
      description: 'Rotate and scale in together',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 0.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 0.0, scaleY: 0.0, rotation: -270),
            easing: _spring,
          ),
        ),
        PresetKeyframe(
          frameOffset: 28,
          keyframe: VecKeyframe(
            frame: 28,
            opacity: 1.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0, rotation: 0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'enter_drop',
      name: 'Drop',
      category: AnimationPresetCategory.enter,
      description: 'Drop from above with squash landing',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 0.0,
            transform: VecTransform(x: 0, y: -80, width: 100, height: 100, scaleX: 0.8, scaleY: 0.8),
            easing: _easeIn,
          ),
        ),
        PresetKeyframe(
          frameOffset: 14,
          keyframe: VecKeyframe(
            frame: 14,
            opacity: 1.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.2, scaleY: 0.75),
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
      id: 'enter_drift_in',
      name: 'Drift In',
      category: AnimationPresetCategory.enter,
      description: 'Float in diagonally from bottom-left',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 0.0,
            transform: VecTransform(x: -50, y: 40, width: 100, height: 100),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 22,
          keyframe: VecKeyframe(
            frame: 22,
            opacity: 1.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100),
          ),
        ),
      ],
    ),

    // ── Exit (additional) ─────────────────────────────────────────────────
    AnimationPreset(
      id: 'exit_fly_off',
      name: 'Fly Off',
      category: AnimationPresetCategory.exit,
      description: 'Shoot upward and shrink away',
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
            transform: VecTransform(x: 0, y: -80, width: 100, height: 100, scaleX: 0.4, scaleY: 0.4),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'exit_explode',
      name: 'Explode',
      category: AnimationPresetCategory.exit,
      description: 'Scale up and vanish outward',
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
          frameOffset: 16,
          keyframe: VecKeyframe(
            frame: 16,
            opacity: 0.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.6, scaleY: 1.6),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'exit_spin_out',
      name: 'Spin Out',
      category: AnimationPresetCategory.exit,
      description: 'Rotate and shrink to nothing',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 1.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0, rotation: 0),
            easing: _easeIn,
          ),
        ),
        PresetKeyframe(
          frameOffset: 22,
          keyframe: VecKeyframe(
            frame: 22,
            opacity: 0.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 0.0, scaleY: 0.0, rotation: 270),
          ),
        ),
      ],
    ),

    // ── Loop (additional) ─────────────────────────────────────────────────
    AnimationPreset(
      id: 'loop_orbit',
      name: 'Orbit',
      category: AnimationPresetCategory.loop,
      description: 'Gentle circular orbit path',
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
          frameOffset: 12,
          keyframe: VecKeyframe(
            frame: 12,
            transform: VecTransform(x: 14, y: -8, width: 100, height: 100),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 24,
          keyframe: VecKeyframe(
            frame: 24,
            transform: VecTransform(x: 0, y: -16, width: 100, height: 100),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 36,
          keyframe: VecKeyframe(
            frame: 36,
            transform: VecTransform(x: -14, y: -8, width: 100, height: 100),
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
      id: 'loop_tremble',
      name: 'Tremble',
      category: AnimationPresetCategory.loop,
      description: 'Rapid micro-shake loop',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(frame: 0, transform: VecTransform(x: 0, y: 0, width: 100, height: 100)),
        ),
        PresetKeyframe(
          frameOffset: 2,
          keyframe: VecKeyframe(frame: 2, transform: VecTransform(x: -3, y: 1, width: 100, height: 100)),
        ),
        PresetKeyframe(
          frameOffset: 4,
          keyframe: VecKeyframe(frame: 4, transform: VecTransform(x: 3, y: -1, width: 100, height: 100)),
        ),
        PresetKeyframe(
          frameOffset: 6,
          keyframe: VecKeyframe(frame: 6, transform: VecTransform(x: -2, y: 2, width: 100, height: 100)),
        ),
        PresetKeyframe(
          frameOffset: 8,
          keyframe: VecKeyframe(frame: 8, transform: VecTransform(x: 2, y: -2, width: 100, height: 100)),
        ),
        PresetKeyframe(
          frameOffset: 10,
          keyframe: VecKeyframe(frame: 10, transform: VecTransform(x: 0, y: 0, width: 100, height: 100)),
        ),
      ],
    ),
    AnimationPreset(
      id: 'loop_pendulum',
      name: 'Pendulum',
      category: AnimationPresetCategory.loop,
      description: 'Side-to-side pendulum swing',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: -28),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 20,
          keyframe: VecKeyframe(
            frame: 20,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 28),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 40,
          keyframe: VecKeyframe(
            frame: 40,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: -28),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'loop_blink',
      name: 'Blink',
      category: AnimationPresetCategory.loop,
      description: 'Periodic visibility blink',
      keyframes: [
        PresetKeyframe(frameOffset: 0, keyframe: VecKeyframe(frame: 0, opacity: 1.0)),
        PresetKeyframe(frameOffset: 2, keyframe: VecKeyframe(frame: 2, opacity: 1.0)),
        PresetKeyframe(frameOffset: 4, keyframe: VecKeyframe(frame: 4, opacity: 0.0)),
        PresetKeyframe(frameOffset: 6, keyframe: VecKeyframe(frame: 6, opacity: 1.0)),
        PresetKeyframe(frameOffset: 36, keyframe: VecKeyframe(frame: 36, opacity: 1.0)),
      ],
    ),
    AnimationPreset(
      id: 'loop_spin_slow',
      name: 'Spin Slow',
      category: AnimationPresetCategory.loop,
      description: 'Slow continuous rotation',
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
          frameOffset: 72,
          keyframe: VecKeyframe(frame: 72, transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 360)),
        ),
      ],
    ),

    // ── Transform ─────────────────────────────────────────────────────────
    AnimationPreset(
      id: 'transform_squash_stretch',
      name: 'Squash & Stretch',
      category: AnimationPresetCategory.transform,
      description: 'Classic squash then stretch deform',
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
          frameOffset: 9,
          keyframe: VecKeyframe(
            frame: 9,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.35, scaleY: 0.65),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 18,
          keyframe: VecKeyframe(
            frame: 18,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 0.65, scaleY: 1.35),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 28,
          keyframe: VecKeyframe(
            frame: 28,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'transform_skew_warp',
      name: 'Skew Warp',
      category: AnimationPresetCategory.transform,
      description: 'Alternating horizontal skew',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, skewX: 0),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 8,
          keyframe: VecKeyframe(
            frame: 8,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, skewX: 18),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 16,
          keyframe: VecKeyframe(
            frame: 16,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, skewX: -18),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 24,
          keyframe: VecKeyframe(
            frame: 24,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, skewX: 0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'transform_tilt_rock',
      name: 'Tilt Rock',
      category: AnimationPresetCategory.transform,
      description: 'Gentle rocking tilt with Y skew',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: -10, skewY: -4),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 12,
          keyframe: VecKeyframe(
            frame: 12,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: 10, skewY: 4),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 24,
          keyframe: VecKeyframe(
            frame: 24,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, rotation: -10, skewY: -4),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'transform_pump',
      name: 'Pump',
      category: AnimationPresetCategory.transform,
      description: 'Vertical scale pump with squash',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 8,
          keyframe: VecKeyframe(
            frame: 8,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.15, scaleY: 0.82),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 16,
          keyframe: VecKeyframe(
            frame: 16,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 0.88, scaleY: 1.18),
            easing: _easeInOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 24,
          keyframe: VecKeyframe(
            frame: 24,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'transform_flatten',
      name: 'Flatten',
      category: AnimationPresetCategory.transform,
      description: 'Crush flat then restore',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
            easing: _easeIn,
          ),
        ),
        PresetKeyframe(
          frameOffset: 10,
          keyframe: VecKeyframe(
            frame: 10,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.5, scaleY: 0.15),
            easing: _spring,
          ),
        ),
        PresetKeyframe(
          frameOffset: 26,
          keyframe: VecKeyframe(
            frame: 26,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
          ),
        ),
      ],
    ),

    // ── Reveal ────────────────────────────────────────────────────────────
    AnimationPreset(
      id: 'reveal_grow_up',
      name: 'Grow Up',
      category: AnimationPresetCategory.reveal,
      description: 'Scale up from bottom edge',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 0.0,
            transform: VecTransform(x: 0, y: 20, width: 100, height: 100, scaleX: 1.0, scaleY: 0.0),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 18,
          keyframe: VecKeyframe(
            frame: 18,
            opacity: 1.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'reveal_grow_wide',
      name: 'Grow Wide',
      category: AnimationPresetCategory.reveal,
      description: 'Expand from center horizontally',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 0.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 0.0, scaleY: 1.0),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 18,
          keyframe: VecKeyframe(
            frame: 18,
            opacity: 1.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'reveal_iris_in',
      name: 'Iris In',
      category: AnimationPresetCategory.reveal,
      description: 'Radial scale from zero',
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
          frameOffset: 22,
          keyframe: VecKeyframe(
            frame: 22,
            opacity: 1.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'reveal_iris_out',
      name: 'Iris Out',
      category: AnimationPresetCategory.reveal,
      description: 'Radial shrink to zero',
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
          frameOffset: 22,
          keyframe: VecKeyframe(
            frame: 22,
            opacity: 0.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 0.0, scaleY: 0.0),
          ),
        ),
      ],
    ),
    AnimationPreset(
      id: 'reveal_uncover',
      name: 'Uncover',
      category: AnimationPresetCategory.reveal,
      description: 'Slide-uncover from left edge',
      keyframes: [
        PresetKeyframe(
          frameOffset: 0,
          keyframe: VecKeyframe(
            frame: 0,
            opacity: 0.0,
            transform: VecTransform(x: -60, y: 0, width: 100, height: 100, scaleX: 0.0, scaleY: 1.0),
            easing: _easeOut,
          ),
        ),
        PresetKeyframe(
          frameOffset: 20,
          keyframe: VecKeyframe(
            frame: 20,
            opacity: 1.0,
            transform: VecTransform(x: 0, y: 0, width: 100, height: 100, scaleX: 1.0, scaleY: 1.0),
          ),
        ),
      ],
    ),
  ];
}
