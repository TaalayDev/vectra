import 'package:flutter/material.dart';

import '../../../app/theme/theme.dart';

class ColorSwatchButton extends StatelessWidget {
  const ColorSwatchButton({
    super.key,
    required this.color,
    required this.theme,
    this.onTap,
    this.size = 24,
  });

  final Color color;
  final AppTheme theme;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: theme.divider, width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3.5),
          child: CustomPaint(
            painter: _CheckerPainter(theme.gridLine.withAlpha(60)),
            child: Container(color: color),
          ),
        ),
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  _CheckerPainter(this.checkerColor);

  final Color checkerColor;

  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 4.0;
    final paint = Paint()..color = checkerColor;
    for (var y = 0.0; y < size.height; y += cellSize) {
      for (var x = 0.0; x < size.width; x += cellSize) {
        final col = (x / cellSize).floor();
        final row = (y / cellSize).floor();
        if ((col + row) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckerPainter old) => old.checkerColor != checkerColor;
}
