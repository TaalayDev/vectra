import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class ColorHistoryNotifier extends StateNotifier<List<Color>> {
  static const _key = 'vec_color_history';
  static const _max = 16;

  ColorHistoryNotifier() : super(const []) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_key) ?? [];
    if (stored.isNotEmpty) {
      state = stored
          .map((h) => int.tryParse('FF$h', radix: 16))
          .whereType<int>()
          .map(Color.new)
          .toList();
    }
  }

  Future<void> addColor(Color color) async {
    // Strip alpha — history stores opaque colors only
    final c = Color.fromARGB(
      255,
      (color.r * 255).round(),
      (color.g * 255).round(),
      (color.b * 255).round(),
    );
    final updated = [c, ...state.where((x) => x.toARGB32() != c.toARGB32())]
        .take(_max)
        .toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated.map(_toHex).toList());
  }

  static String _toHex(Color c) {
    final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '$r$g$b'.toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final colorHistoryProvider =
    StateNotifierProvider<ColorHistoryNotifier, List<Color>>(
  (ref) => ColorHistoryNotifier(),
);
