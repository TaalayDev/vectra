import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/models/vec_shape.dart';

/// Holds the shapes most recently copied (or cut) by the user.
/// Session-only — not persisted across app restarts.
class ClipboardNotifier extends StateNotifier<List<VecShape>> {
  ClipboardNotifier() : super(const []);

  void set(List<VecShape> shapes) => state = List.unmodifiable(shapes);
  void clear() => state = const [];
}

final clipboardProvider =
    StateNotifierProvider<ClipboardNotifier, List<VecShape>>(
  (ref) => ClipboardNotifier(),
);
