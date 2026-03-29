import 'package:hooks_riverpod/hooks_riverpod.dart';

class VecToast {
  final String message;
  final int id;
  final bool isError;
  const VecToast({required this.message, required this.id, this.isError = false});
}

class ToastNotifier extends StateNotifier<VecToast?> {
  ToastNotifier() : super(null);

  int _nextId = 0;

  void show(String message, {bool isError = false}) {
    state = VecToast(message: message, id: _nextId++, isError: isError);
  }
}

final toastProvider = StateNotifierProvider<ToastNotifier, VecToast?>(
  (ref) => ToastNotifier(),
);
