import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';

// ---------------------------------------------------------------------------
// Result returned when the user confirms the dialog
// ---------------------------------------------------------------------------

class ConvertToSymbolResult {
  const ConvertToSymbolResult({required this.name});
  final String name;
}

// ---------------------------------------------------------------------------
// Dialog
// ---------------------------------------------------------------------------

class ConvertToSymbolDialog extends ConsumerStatefulWidget {
  const ConvertToSymbolDialog({
    super.key,
    required this.theme,
    required this.defaultName,
  });

  final AppTheme theme;
  final String defaultName;

  /// Shows the dialog and returns the result, or null if cancelled.
  static Future<ConvertToSymbolResult?> show(
    BuildContext context,
    AppTheme theme, {
    String defaultName = 'Symbol',
  }) {
    return showDialog<ConvertToSymbolResult>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => ConvertToSymbolDialog(theme: theme, defaultName: defaultName),
    );
  }

  @override
  ConsumerState<ConvertToSymbolDialog> createState() => _ConvertToSymbolDialogState();
}

class _ConvertToSymbolDialogState extends ConsumerState<ConvertToSymbolDialog> {
  late final TextEditingController _nameController;
  late final FocusNode _nameFocus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.defaultName);
    _nameFocus = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
      _nameController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _nameController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _confirm() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(ConvertToSymbolResult(name: name));
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          _confirm();
        }
      },
      child: Dialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SizedBox(
          width: 320,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.widgets_outlined, size: 18, color: theme.accentColor),
                    const SizedBox(width: 8),
                    Text(
                      'Convert to Symbol',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name field
                Text(
                  'Symbol name',
                  style: TextStyle(color: theme.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  style: TextStyle(color: theme.textPrimary, fontSize: 13),
                  cursorColor: theme.accentColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: theme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: theme.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: theme.accentColor, width: 1.5),
                    ),
                  ),
                  onSubmitted: (_) => _confirm(),
                ),

                const SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.textSecondary,
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accentColor,
                        foregroundColor: theme.onAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: const Text('Convert', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
