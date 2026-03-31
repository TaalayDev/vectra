import 'package:flutter/painting.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/models/vec_stroke.dart';

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

class FreeDrawSettings {
  const FreeDrawSettings({
    this.color = const Color(0xFF323C50),
    this.width = 2.0,
    this.opacity = 1.0,
    this.close = false,
    this.fill = false,
    this.cap = VecStrokeCap.round,
  });

  final Color color;
  final double width;
  final double opacity;
  final bool close;
  final bool fill;
  final VecStrokeCap cap;

  FreeDrawSettings copyWith({
    Color? color,
    double? width,
    double? opacity,
    bool? close,
    bool? fill,
    VecStrokeCap? cap,
  }) {
    return FreeDrawSettings(
      color: color ?? this.color,
      width: width ?? this.width,
      opacity: opacity ?? this.opacity,
      close: close ?? this.close,
      fill: fill ?? this.fill,
      cap: cap ?? this.cap,
    );
  }
}

class FreeDrawNotifier extends StateNotifier<FreeDrawSettings> {
  FreeDrawNotifier() : super(const FreeDrawSettings());

  void setColor(Color c) => state = state.copyWith(color: c);
  void setWidth(double w) => state = state.copyWith(width: w.clamp(0.5, 128.0));
  void setOpacity(double o) => state = state.copyWith(opacity: o.clamp(0.0, 1.0));
  void setClose(bool v) => state = state.copyWith(close: v);
  void setFill(bool v) => state = state.copyWith(fill: v);
  void setCap(VecStrokeCap c) => state = state.copyWith(cap: c);
}

final freeDrawSettingsProvider =
    StateNotifierProvider<FreeDrawNotifier, FreeDrawSettings>(
  (ref) => FreeDrawNotifier(),
);

// ---------------------------------------------------------------------------
// Active stroke state
// ---------------------------------------------------------------------------

class FreeDrawStroke {
  FreeDrawStroke(List<Offset> points) : points = List.unmodifiable(points);
  final List<Offset> points;
}

class ActiveFreeDrawingNotifier extends StateNotifier<FreeDrawStroke?> {
  ActiveFreeDrawingNotifier() : super(null);

  final List<Offset> _pts = [];

  void start(Offset pt) {
    _pts.clear();
    _pts.add(pt);
    state = FreeDrawStroke(List.of(_pts));
  }

  void addPoint(Offset pt) {
    if (_pts.isEmpty) return;
    // Thin: skip if within 3 canvas px of last point
    if ((_pts.last - pt).distance < 3.0) return;
    _pts.add(pt);
    state = FreeDrawStroke(List.of(_pts));
  }

  FreeDrawStroke? finish() {
    final result = _pts.length >= 2 ? FreeDrawStroke(List.of(_pts)) : null;
    _pts.clear();
    state = null;
    return result;
  }

  void cancel() {
    _pts.clear();
    state = null;
  }
}

final activeFreeDrawingProvider =
    StateNotifierProvider<ActiveFreeDrawingNotifier, FreeDrawStroke?>(
  (ref) => ActiveFreeDrawingNotifier(),
);
