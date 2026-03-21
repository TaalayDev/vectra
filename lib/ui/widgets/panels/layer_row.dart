import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_layer.dart';
import '../../../data/models/vec_shape.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';

// =============================================================================
// LayerRow
// =============================================================================

class LayerRow extends ConsumerStatefulWidget {
  const LayerRow({
    super.key,
    required this.layer,
    required this.sceneId,
    required this.isActive,
    required this.theme,
    required this.index, // position in the ReorderableListView
  });

  final VecLayer layer;
  final String sceneId;
  final bool isActive;
  final AppTheme theme;
  final int index;

  @override
  ConsumerState<LayerRow> createState() => _LayerRowState();
}

class _LayerRowState extends ConsumerState<LayerRow> {
  bool _isExpanded = false;
  bool _isRenaming = false;
  late final TextEditingController _renameCtrl;
  final _renameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _renameCtrl = TextEditingController(text: widget.layer.name);
  }

  @override
  void didUpdateWidget(LayerRow old) {
    super.didUpdateWidget(old);
    if (!_isRenaming && old.layer.name != widget.layer.name) {
      _renameCtrl.text = widget.layer.name;
    }
  }

  @override
  void dispose() {
    _renameCtrl.dispose();
    _renameFocus.dispose();
    super.dispose();
  }

  void _startRename() {
    setState(() {
      _renameCtrl.text = widget.layer.name;
      _renameCtrl.selection =
          TextSelection(baseOffset: 0, extentOffset: _renameCtrl.text.length);
      _isRenaming = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _renameFocus.requestFocus();
    });
  }

  void _commitRename() {
    final name = _renameCtrl.text.trim();
    if (name.isNotEmpty && name != widget.layer.name) {
      ref.read(vecDocumentStateProvider.notifier).updateLayer(
            widget.sceneId,
            widget.layer.id,
            (l) => l.copyWith(name: name),
          );
    }
    setState(() => _isRenaming = false);
  }

  AppTheme get t => widget.theme;

  @override
  Widget build(BuildContext context) {
    final selectedShapeId = ref.watch(selectedShapeIdProvider);
    final layer = widget.layer;
    final dotColor = layer.colorDot?.toFlutterColor() ?? t.accentColor;
    final hasShapes = layer.shapes.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // -----------------------------------------------------------------------
        // Main layer row
        // -----------------------------------------------------------------------
        GestureDetector(
          onTap: () {
            if (_isRenaming) return;
            ref.read(activeLayerIdProvider.notifier).set(layer.id);
          },
          onDoubleTap: _startRename,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: 36,
            padding: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? t.primaryColor.withAlpha(25)
                  : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color:
                      widget.isActive ? t.primaryColor : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                // Drag handle
                ReorderableDragStartListener(
                  index: widget.index,
                  child: SizedBox(
                    width: 20,
                    height: 36,
                    child: Icon(
                      Icons.drag_indicator,
                      size: 14,
                      color: t.textDisabled.withAlpha(120),
                    ),
                  ),
                ),

                // Expand arrow (only when layer has shapes)
                GestureDetector(
                  onTap: hasShapes
                      ? () => setState(() => _isExpanded = !_isExpanded)
                      : null,
                  child: SizedBox(
                    width: 16,
                    height: 36,
                    child: hasShapes
                        ? Icon(
                            _isExpanded
                                ? Icons.expand_more
                                : Icons.chevron_right,
                            size: 14,
                            color: t.textDisabled,
                          )
                        : null,
                  ),
                ),

                const SizedBox(width: 4),

                // Color dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),

                // Layer name — inline rename or static text
                Expanded(
                  child: _isRenaming
                      ? _RenameField(
                          controller: _renameCtrl,
                          focusNode: _renameFocus,
                          theme: t,
                          onCommit: _commitRename,
                        )
                      : Text(
                          layer.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isActive
                                ? t.textPrimary
                                : t.textSecondary,
                            fontWeight: widget.isActive
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),

                // Guide badge
                if (layer.type == VecLayerType.guide)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: t.surfaceVariant,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text('G',
                          style: TextStyle(
                              fontSize: 8, color: t.textDisabled)),
                    ),
                  ),

                // Visibility toggle
                _SmallIconButton(
                  icon: layer.visible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: layer.visible ? t.activeIcon : t.textDisabled,
                  onTap: () => ref
                      .read(vecDocumentStateProvider.notifier)
                      .updateLayer(widget.sceneId, layer.id,
                          (l) => l.copyWith(visible: !l.visible)),
                ),
                const SizedBox(width: 2),

                // Lock toggle
                _SmallIconButton(
                  icon: layer.locked ? Icons.lock : Icons.lock_open,
                  color: layer.locked ? t.warning : t.textDisabled,
                  onTap: () => ref
                      .read(vecDocumentStateProvider.notifier)
                      .updateLayer(widget.sceneId, layer.id,
                          (l) => l.copyWith(locked: !l.locked)),
                ),
              ],
            ),
          ),
        ),

        // -----------------------------------------------------------------------
        // Shape sub-rows (when expanded)
        // -----------------------------------------------------------------------
        if (_isExpanded && hasShapes)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = layer.shapes.length - 1; i >= 0; i--)
                _ShapeRow(
                  shape: layer.shapes[i],
                  layerId: layer.id,
                  isSelected: layer.shapes[i].id == selectedShapeId,
                  theme: t,
                  onTap: () {
                    ref
                        .read(selectedShapeIdProvider.notifier)
                        .set(layer.shapes[i].id);
                    ref
                        .read(selectedShapeIdsProvider.notifier)
                        .setSingle(layer.shapes[i].id);
                    ref
                        .read(activeLayerIdProvider.notifier)
                        .set(layer.id);
                  },
                ),
            ],
          ),
      ],
    );
  }
}

// =============================================================================
// Inline rename text field
// =============================================================================

class _RenameField extends StatelessWidget {
  const _RenameField({
    required this.controller,
    required this.focusNode,
    required this.theme,
    required this.onCommit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final AppTheme theme;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: TextStyle(fontSize: 12, color: theme.textPrimary),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        filled: true,
        fillColor: theme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(color: theme.primaryColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
        ),
      ),
      onSubmitted: (_) => onCommit(),
      onTapOutside: (_) => onCommit(),
    );
  }
}

// =============================================================================
// Shape sub-row
// =============================================================================

class _ShapeRow extends StatelessWidget {
  const _ShapeRow({
    required this.shape,
    required this.layerId,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  final VecShape shape;
  final String layerId;
  final bool isSelected;
  final AppTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 28,
        padding: const EdgeInsets.only(left: 40, right: 8),
        color: isSelected
            ? theme.primaryColor.withAlpha(20)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(_shapeIcon(), size: 12, color: theme.textDisabled),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _shapeName(),
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? theme.textPrimary
                      : theme.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shapeName() => shape.map(
        path: (_) => 'Path',
        rectangle: (_) => 'Rectangle',
        ellipse: (_) => 'Ellipse',
        polygon: (_) => 'Polygon',
        text: (s) => s.content.trim().isEmpty ? 'Text' : s.content.trim(),
        group: (_) => 'Group',
        symbolInstance: (_) => 'Symbol',
        compound: (_) => 'Compound',
      );

  IconData _shapeIcon() => shape.map(
        path: (_) => Icons.route,
        rectangle: (_) => Icons.rectangle_outlined,
        ellipse: (_) => Icons.circle_outlined,
        polygon: (_) => Icons.hexagon_outlined,
        text: (_) => Icons.text_fields,
        group: (_) => Icons.folder_outlined,
        symbolInstance: (_) => Icons.widgets_outlined,
        compound: (_) => Icons.join_inner,
      );
}

// =============================================================================
// Small icon button
// =============================================================================

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
