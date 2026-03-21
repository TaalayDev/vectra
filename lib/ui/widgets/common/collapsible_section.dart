import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../app/theme/theme.dart';

class CollapsibleSection extends HookWidget {
  const CollapsibleSection({
    super.key,
    required this.title,
    required this.content,
    required this.theme,
    this.initiallyExpanded = true,
    this.action,
  });

  final String title;
  final Widget content;
  final AppTheme theme;
  final bool initiallyExpanded;

  /// Optional widget shown at the right of the section header (e.g. a + button).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(initiallyExpanded);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => expanded.value = !expanded.value,
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: expanded.value ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: theme.textDisabled,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
                const Spacer(),
                if (action != null) action!,
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: content,
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: expanded.value
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }
}
