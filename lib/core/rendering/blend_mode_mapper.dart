import 'dart:ui' show BlendMode;

import '../../data/models/vec_fill.dart';

/// Maps [VecBlendMode] to Flutter's [BlendMode].
BlendMode mapBlendMode(VecBlendMode mode) {
  switch (mode) {
    case VecBlendMode.normal:
      return BlendMode.srcOver;
    case VecBlendMode.multiply:
      return BlendMode.multiply;
    case VecBlendMode.screen:
      return BlendMode.screen;
    case VecBlendMode.overlay:
      return BlendMode.overlay;
    case VecBlendMode.darken:
      return BlendMode.darken;
    case VecBlendMode.lighten:
      return BlendMode.lighten;
    case VecBlendMode.colorDodge:
      return BlendMode.colorDodge;
    case VecBlendMode.colorBurn:
      return BlendMode.colorBurn;
    case VecBlendMode.hardLight:
      return BlendMode.hardLight;
    case VecBlendMode.softLight:
      return BlendMode.softLight;
    case VecBlendMode.difference:
      return BlendMode.difference;
    case VecBlendMode.exclusion:
      return BlendMode.exclusion;
    case VecBlendMode.hue:
      return BlendMode.hue;
    case VecBlendMode.saturation:
      return BlendMode.saturation;
    case VecBlendMode.color:
      return BlendMode.color;
    case VecBlendMode.luminosity:
      return BlendMode.luminosity;
  }
}
