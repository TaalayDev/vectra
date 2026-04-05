import 'vec_color.dart';

enum VecEffectType { blur, shadow, glow }

/// A visual effect applied to a shape (blur, drop shadow, outer glow).
class VecEffect {
  const VecEffect({
    this.type = VecEffectType.blur,
    this.enabled = true,
    this.blur = 4.0,
    this.offsetX = 0.0,
    this.offsetY = 4.0,
    this.spread = 0.0,
    this.color = const VecColor(a: 128, r: 0, g: 0, b: 0),
    this.opacity = 1.0,
  });

  final VecEffectType type;
  final bool enabled;

  /// Blur radius in logical pixels.
  final double blur;

  /// Horizontal offset (shadow only).
  final double offsetX;

  /// Vertical offset (shadow only).
  final double offsetY;

  /// Spread radius — expands shadow/glow before blur.
  final double spread;

  /// Color for shadow and glow effects.
  final VecColor color;

  /// Overall effect opacity (0..1).
  final double opacity;

  VecEffect copyWith({
    VecEffectType? type,
    bool? enabled,
    double? blur,
    double? offsetX,
    double? offsetY,
    double? spread,
    VecColor? color,
    double? opacity,
  }) =>
      VecEffect(
        type: type ?? this.type,
        enabled: enabled ?? this.enabled,
        blur: blur ?? this.blur,
        offsetX: offsetX ?? this.offsetX,
        offsetY: offsetY ?? this.offsetY,
        spread: spread ?? this.spread,
        color: color ?? this.color,
        opacity: opacity ?? this.opacity,
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'enabled': enabled,
        'blur': blur,
        'offsetX': offsetX,
        'offsetY': offsetY,
        'spread': spread,
        'color': color.toJson(),
        'opacity': opacity,
      };

  factory VecEffect.fromJson(Map<String, dynamic> json) => VecEffect(
        type: VecEffectType.values.firstWhere(
          (t) => t.name == (json['type'] as String?),
          orElse: () => VecEffectType.blur,
        ),
        enabled: json['enabled'] as bool? ?? true,
        blur: (json['blur'] as num?)?.toDouble() ?? 4.0,
        offsetX: (json['offsetX'] as num?)?.toDouble() ?? 0.0,
        offsetY: (json['offsetY'] as num?)?.toDouble() ?? 4.0,
        spread: (json['spread'] as num?)?.toDouble() ?? 0.0,
        color: json['color'] != null
            ? VecColor.fromJson(json['color'] as Map<String, dynamic>)
            : const VecColor(a: 128, r: 0, g: 0, b: 0),
        opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      );

  /// Default blur effect.
  static const VecEffect defaultBlur = VecEffect();

  /// Default drop shadow.
  static const VecEffect defaultShadow = VecEffect(
    type: VecEffectType.shadow,
    blur: 8.0,
    offsetX: 2.0,
    offsetY: 4.0,
    color: VecColor(a: 100, r: 0, g: 0, b: 0),
  );

  /// Default outer glow.
  static const VecEffect defaultGlow = VecEffect(
    type: VecEffectType.glow,
    blur: 12.0,
    offsetX: 0.0,
    offsetY: 0.0,
    spread: 2.0,
    color: VecColor(a: 180, r: 255, g: 200, b: 50),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VecEffect &&
          other.type == type &&
          other.enabled == enabled &&
          other.blur == blur &&
          other.offsetX == offsetX &&
          other.offsetY == offsetY &&
          other.spread == spread &&
          other.color == color &&
          other.opacity == opacity);

  @override
  int get hashCode =>
      Object.hash(type, enabled, blur, offsetX, offsetY, spread, color, opacity);
}
