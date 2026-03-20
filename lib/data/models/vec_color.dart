import 'dart:ui' show Color;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'vec_color.freezed.dart';
part 'vec_color.g.dart';

@freezed
class VecColor with _$VecColor {
  const VecColor._();

  const factory VecColor({
    @Default(255) int a,
    required int r,
    required int g,
    required int b,
  }) = _VecColor;

  factory VecColor.fromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    final value = int.parse(hex, radix: 16);
    return VecColor(
      a: (value >> 24) & 0xFF,
      r: (value >> 16) & 0xFF,
      g: (value >> 8) & 0xFF,
      b: value & 0xFF,
    );
  }

  factory VecColor.fromFlutterColor(Color color) => VecColor(
        a: (color.a * 255.0).round().clamp(0, 255),
        r: (color.r * 255.0).round().clamp(0, 255),
        g: (color.g * 255.0).round().clamp(0, 255),
        b: (color.b * 255.0).round().clamp(0, 255),
      );

  static const white = VecColor(a: 255, r: 255, g: 255, b: 255);
  static const black = VecColor(a: 255, r: 0, g: 0, b: 0);
  static const transparent = VecColor(a: 0, r: 0, g: 0, b: 0);

  Color toFlutterColor() => Color.fromARGB(a, r, g, b);

  String toHex({bool includeAlpha = false}) {
    final hex = StringBuffer('#');
    if (includeAlpha) hex.write(a.toRadixString(16).padLeft(2, '0'));
    hex.write(r.toRadixString(16).padLeft(2, '0'));
    hex.write(g.toRadixString(16).padLeft(2, '0'));
    hex.write(b.toRadixString(16).padLeft(2, '0'));
    return hex.toString().toUpperCase();
  }

  factory VecColor.fromJson(Map<String, dynamic> json) =>
      _$VecColorFromJson(json);
}
