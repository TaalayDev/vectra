import 'package:flutter/material.dart';

import '../../../app/theme/theme.dart';

class IconToggleButton extends StatelessWidget {
  const IconToggleButton({
    super.key,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.theme,
    this.tooltip,
    this.size = 36,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final AppTheme theme;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: theme.primaryColor.withAlpha(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isActive ? theme.primaryColor.withAlpha(38) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? theme.primaryColor : theme.inactiveIcon,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        waitDuration: const Duration(milliseconds: 500),
        child: child,
      );
    }

    return child;
  }
}
