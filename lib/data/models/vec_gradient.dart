import 'vec_color.dart';

enum VecGradientType { linear, radial, angular }

/// A single color stop in a gradient.
class VecGradientStop {
  const VecGradientStop({required this.color, required this.position});

  final VecColor color;

  /// Position along the gradient, 0.0 = start, 1.0 = end.
  final double position;

  VecGradientStop copyWith({VecColor? color, double? position}) =>
      VecGradientStop(color: color ?? this.color, position: position ?? this.position);

  Map<String, dynamic> toJson() => {
        'color': color.toJson(),
        'position': position,
      };

  factory VecGradientStop.fromJson(Map<String, dynamic> json) => VecGradientStop(
        color: VecColor.fromJson(json['color'] as Map<String, dynamic>),
        position: (json['position'] as num).toDouble(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VecGradientStop && other.color == color && other.position == position);

  @override
  int get hashCode => Object.hash(color, position);
}

/// A gradient used as a fill.
class VecGradient {
  const VecGradient({
    this.type = VecGradientType.linear,
    required this.stops,
    this.angle = 90.0,
    this.centerX = 0.5,
    this.centerY = 0.5,
    this.radius = 0.7071,
    this.boundX,
    this.boundY,
    this.boundW,
    this.boundH,
  });

  final VecGradientType type;

  /// Color stops ordered by position.
  final List<VecGradientStop> stops;

  /// Angle in degrees for linear gradients. 0° = left→right, 90° = top→bottom.
  final double angle;

  /// Center X (0..1) relative to bounding box for radial gradients.
  final double centerX;

  /// Center Y (0..1) relative to bounding box for radial gradients.
  final double centerY;

  /// Radius as a fraction of the diagonal half-length for radial gradients.
  final double radius;

  /// Optional override for the local bounding box X to support global seamless wrapping.
  final double? boundX;
  
  /// Optional override for the local bounding box Y.
  final double? boundY;

  /// Optional override for the local bounding box Width.
  final double? boundW;

  /// Optional override for the local bounding box Height.
  final double? boundH;

  VecGradient copyWith({
    VecGradientType? type,
    List<VecGradientStop>? stops,
    double? angle,
    double? centerX,
    double? centerY,
    double? radius,
    double? boundX,
    double? boundY,
    double? boundW,
    double? boundH,
  }) =>
      VecGradient(
        type: type ?? this.type,
        stops: stops ?? this.stops,
        angle: angle ?? this.angle,
        centerX: centerX ?? this.centerX,
        centerY: centerY ?? this.centerY,
        radius: radius ?? this.radius,
        boundX: boundX ?? this.boundX,
        boundY: boundY ?? this.boundY,
        boundW: boundW ?? this.boundW,
        boundH: boundH ?? this.boundH,
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'stops': stops.map((s) => s.toJson()).toList(),
        'angle': angle,
        'centerX': centerX,
        'centerY': centerY,
        'radius': radius,
        if (boundX != null) 'boundX': boundX,
        if (boundY != null) 'boundY': boundY,
        if (boundW != null) 'boundW': boundW,
        if (boundH != null) 'boundH': boundH,
      };

  factory VecGradient.fromJson(Map<String, dynamic> json) => VecGradient(
        type: VecGradientType.values.firstWhere(
          (t) => t.name == (json['type'] as String?),
          orElse: () => VecGradientType.linear,
        ),
        stops: (json['stops'] as List<dynamic>)
            .map((s) => VecGradientStop.fromJson(s as Map<String, dynamic>))
            .toList(),
        angle: (json['angle'] as num?)?.toDouble() ?? 90.0,
        centerX: (json['centerX'] as num?)?.toDouble() ?? 0.5,
        centerY: (json['centerY'] as num?)?.toDouble() ?? 0.5,
        radius: (json['radius'] as num?)?.toDouble() ?? 0.7071,
        boundX: (json['boundX'] as num?)?.toDouble(),
        boundY: (json['boundY'] as num?)?.toDouble(),
        boundW: (json['boundW'] as num?)?.toDouble(),
        boundH: (json['boundH'] as num?)?.toDouble(),
      );

  /// Default two-stop linear gradient (white → transparent).
  static const VecGradient defaultLinear = VecGradient(
    stops: [
      VecGradientStop(color: VecColor(r: 255, g: 255, b: 255), position: 0),
      VecGradientStop(color: VecColor(r: 0, g: 0, b: 0), position: 1),
    ],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VecGradient &&
          other.type == type &&
          other.stops == stops &&
          other.angle == angle &&
          other.centerX == centerX &&
          other.centerY == centerY &&
          other.radius == radius &&
          other.boundX == boundX &&
          other.boundY == boundY &&
          other.boundW == boundW &&
          other.boundH == boundH);

  @override
  int get hashCode => Object.hash(type, stops, angle, centerX, centerY, radius, boundX, boundY, boundW, boundH);
}
