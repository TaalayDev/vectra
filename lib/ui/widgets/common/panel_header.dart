import 'package:flutter/material.dart';

import '../../../app/theme/theme.dart';

class PanelHeader extends StatelessWidget {
  const PanelHeader({
    super.key,
    required this.title,
    required this.theme,
    this.trailing,
    this.onTap,
  });

  final String title;
  final AppTheme theme;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.surfaceVariant,
          border: Border(
            bottom: BorderSide(color: theme.divider, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
