import 'package:flutter/material.dart';

import '../../../app/theme/theme.dart';

/// Shows the keyboard shortcut cheat-sheet dialog.
void showShortcutSheet(BuildContext context, AppTheme theme) {
  showDialog<void>(
    context: context,
    builder: (ctx) => _ShortcutSheetDialog(theme: theme),
  );
}

class _ShortcutSheetDialog extends StatelessWidget {
  const _ShortcutSheetDialog({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 640,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
              decoration: BoxDecoration(
                color: theme.surfaceVariant,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                border: Border(bottom: BorderSide(color: theme.divider, width: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.keyboard_outlined, size: 16, color: theme.accentColor),
                  const SizedBox(width: 8),
                  Text(
                    'Keyboard Shortcuts',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Icon(Icons.close, size: 16, color: theme.textDisabled),
                    ),
                  ),
                ],
              ),
            ),

            // Body — two-column grid
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildColumn(_leftGroups)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildColumn(_rightGroups)),
                  ],
                ),
              ),
            ),

            // Footer hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.divider, width: 0.5)),
              ),
              child: Row(
                children: [
                  _Kbd(key_: '?', theme: theme),
                  const SizedBox(width: 8),
                  Text(
                    'opens this panel',
                    style: TextStyle(fontSize: 10, color: theme.textDisabled),
                  ),
                  const Spacer(),
                  Text(
                    'macOS: ⌘  ·  Windows/Linux: Ctrl',
                    style: TextStyle(fontSize: 10, color: theme.textDisabled),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(List<_Group> groups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              group.title.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: theme.textDisabled,
                letterSpacing: 1,
              ),
            ),
          ),
          for (final entry in group.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.label,
                      style:
                          TextStyle(fontSize: 11, color: theme.textSecondary),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: entry.keys
                        .map((k) => Padding(
                              padding: const EdgeInsets.only(left: 3),
                              child: _Kbd(key_: k, theme: theme),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  static const _leftGroups = [
    _Group('Tools', [
      _Entry('Select', ['V']),
      _Entry('Pen', ['P']),
      _Entry('Line', ['L']),
      _Entry('Rectangle', ['R']),
      _Entry('Ellipse', ['E']),
      _Entry('Text', ['T']),
    ]),
    _Group('View', [
      _Entry('Zoom In', ['+']),
      _Entry('Zoom Out', ['−']),
      _Entry('Zoom to Fit', ['0']),
      _Entry('Zoom 100%', ['1']),
      _Entry('Pan (hold)', ['Space']),
      _Entry('Toggle Panels', ['Tab']),
    ]),
    _Group('File', [
      _Entry('Save', ['⌘', 'S']),
      _Entry('Save As', ['⌘', '⇧', 'S']),
      _Entry('Open', ['⌘', 'O']),
      _Entry('Export', ['⌘', 'E']),
    ]),
  ];

  static const _rightGroups = [
    _Group('Edit', [
      _Entry('Undo', ['⌘', 'Z']),
      _Entry('Redo', ['⌘', '⇧', 'Z']),
      _Entry('Copy', ['⌘', 'C']),
      _Entry('Paste', ['⌘', 'V']),
      _Entry('Paste in Place', ['⌘', '⇧', 'V']),
      _Entry('Cut', ['⌘', 'X']),
      _Entry('Duplicate', ['⌘', 'J']),
      _Entry('Select All', ['⌘', 'A']),
      _Entry('Deselect', ['⌘', 'D']),
      _Entry('Delete', ['⌫']),
    ]),
    _Group('Arrange', [
      _Entry('Group', ['⌘', 'G']),
      _Entry('Ungroup', ['⌘', '⇧', 'G']),
      _Entry('Bring Forward', ['⌘', ']']),
      _Entry('Send Backward', ['⌘', '[']),
      _Entry('Bring to Front', ['⌘', '⇧', ']']),
      _Entry('Send to Back', ['⌘', '⇧', '[']),
    ]),
    _Group('Nudge', [
      _Entry('Move 1px', ['↑ ↓ ← →']),
      _Entry('Move 10px', ['⇧ + Arrow']),
    ]),
  ];
}

class _Group {
  final String title;
  final List<_Entry> entries;
  const _Group(this.title, this.entries);
}

class _Entry {
  final String label;
  final List<String> keys;
  const _Entry(this.label, this.keys);
}

class _Kbd extends StatelessWidget {
  const _Kbd({required this.key_, required this.theme});

  final String key_;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: theme.divider),
        boxShadow: [
          BoxShadow(
              color: theme.divider.withAlpha(80),
              offset: const Offset(0, 1),
              blurRadius: 0),
        ],
      ),
      child: Text(
        key_,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: theme.textSecondary,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
