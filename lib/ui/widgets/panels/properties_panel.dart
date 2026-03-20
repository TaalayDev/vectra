import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_shape.dart';
import '../../../providers/editor_state_provider.dart';
import '../common/panel_header.dart';
import 'properties_sections.dart';

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shape = ref.watch(selectedShapeProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          left: BorderSide(color: theme.divider, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          PanelHeader(
            title: shape != null ? _shapeTypeName(shape) : 'Properties',
            theme: theme,
          ),
          Expanded(
            child: shape == null ? _buildEmptyState() : _buildSections(shape),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 32,
            color: theme.textDisabled.withAlpha(80),
          ),
          const SizedBox(height: 8),
          Text(
            'No selection',
            style: TextStyle(
              fontSize: 12,
              color: theme.textDisabled,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a shape to see\nits properties',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: theme.textDisabled.withAlpha(120),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSections(VecShape shape) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        TransformSection(transform: shape.transform, theme: theme),
        Divider(height: 1, color: theme.divider.withAlpha(60)),
        FillSection(fills: shape.fills, theme: theme),
        Divider(height: 1, color: theme.divider.withAlpha(60)),
        StrokeSection(strokes: shape.strokes, theme: theme),
        Divider(height: 1, color: theme.divider.withAlpha(60)),
        BlendSection(
          opacity: shape.opacity,
          blendMode: shape.blendMode,
          theme: theme,
        ),
      ],
    );
  }

  String _shapeTypeName(VecShape shape) {
    return shape.map(
      path: (_) => 'Path',
      rectangle: (_) => 'Rectangle',
      ellipse: (_) => 'Ellipse',
      polygon: (_) => 'Polygon',
      text: (_) => 'Text',
      group: (_) => 'Group',
      symbolInstance: (_) => 'Symbol',
    );
  }
}
