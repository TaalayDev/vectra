import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../providers/editor_state_provider.dart';
import '../common/icon_toggle_button.dart';

class ToolButtonGroup extends ConsumerWidget {
  const ToolButtonGroup({super.key, required this.theme});

  final AppTheme theme;

  static const _tools = [
    (VecTool.select, Icons.near_me_outlined, 'Select (V)'),
    (VecTool.pen, Icons.mode_edit_outline, 'Pen (P)'),
    (VecTool.line, Icons.horizontal_rule, 'Line (L)'),
    (VecTool.rectangle, Icons.rectangle_outlined, 'Rectangle (R)'),
    (VecTool.ellipse, Icons.circle_outlined, 'Ellipse (E)'),
    (VecTool.text, Icons.text_fields, 'Text (T)'),
    (VecTool.width, Icons.line_weight, 'Width (W)'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTool = ref.watch(activeToolProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (tool, icon, tooltip) in _tools) ...[
            IconToggleButton(
              icon: icon,
              isActive: activeTool == tool,
              onTap: () => ref.read(activeToolProvider.notifier).set(tool),
              theme: theme,
              tooltip: tooltip,
            ),
            const SizedBox(width: 2),
          ],
        ],
      ),
    );
  }
}
