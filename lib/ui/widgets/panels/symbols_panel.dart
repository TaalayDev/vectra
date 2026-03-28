import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_layer.dart';
import '../../../data/models/vec_shape.dart';
import '../../../data/models/vec_symbol.dart';
import '../../../data/models/vec_timeline.dart';
import '../../../data/models/vec_transform.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import '../common/panel_header.dart';

const _uuid = Uuid();

class SymbolsPanel extends ConsumerWidget {
  const SymbolsPanel({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbols = ref.watch(symbolLibraryProvider);
    final docNotifier = ref.read(vecDocumentStateProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(right: BorderSide(color: theme.divider, width: 0.5)),
      ),
      child: Column(
        children: [
          PanelHeader(
            title: 'Symbols',
            theme: theme,
            trailing: _HeaderButton(
              icon: Icons.add,
              tooltip: 'New empty symbol',
              theme: theme,
              onTap: () {
                final id = _uuid.v4();
                final layerId = _uuid.v4();
                docNotifier.addSymbol(VecSymbol(
                  id: id,
                  name: 'Symbol ${symbols.length + 1}',
                  layers: [VecLayer(id: layerId, name: 'Layer 1')],
                  timeline: const VecTimeline(duration: 1),
                ));
              },
            ),
          ),
          Expanded(
            child: symbols.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: symbols.length,
                    itemBuilder: (context, i) => _SymbolRow(
                      symbol: symbols[i],
                      theme: theme,
                    ),
                  ),
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
          Icon(Icons.widgets_outlined, size: 32, color: theme.textDisabled.withAlpha(80)),
          const SizedBox(height: 8),
          Text('No symbols', style: TextStyle(fontSize: 12, color: theme.textDisabled)),
          const SizedBox(height: 4),
          Text(
            'Select shapes and use\n"Convert to Symbol"',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: theme.textDisabled.withAlpha(120)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Symbol row
// ---------------------------------------------------------------------------

class _SymbolRow extends ConsumerStatefulWidget {
  const _SymbolRow({required this.symbol, required this.theme});

  final VecSymbol symbol;
  final AppTheme theme;

  @override
  ConsumerState<_SymbolRow> createState() => _SymbolRowState();
}

class _SymbolRowState extends ConsumerState<_SymbolRow> {
  bool _renaming = false;
  late TextEditingController _renameController;

  @override
  void initState() {
    super.initState();
    _renameController = TextEditingController(text: widget.symbol.name);
  }

  @override
  void didUpdateWidget(_SymbolRow old) {
    super.didUpdateWidget(old);
    if (!_renaming) _renameController.text = widget.symbol.name;
  }

  @override
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }

  void _commitRename() {
    final name = _renameController.text.trim();
    if (name.isNotEmpty && name != widget.symbol.name) {
      ref.read(vecDocumentStateProvider.notifier)
          .updateSymbol(widget.symbol.id, (s) => s.copyWith(name: name));
    }
    setState(() => _renaming = false);
  }

  void _dragToCanvas() {
    // Drag creates a VecSymbolInstanceShape when dropped on canvas.
    // This is handled by the DragTarget in editor_canvas.
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final sym = widget.symbol;
    final editingId = ref.watch(editingSymbolIdProvider);
    final isEditing = editingId == sym.id;

    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          _renaming = true;
          _renameController.text = sym.name;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Select all text
          _renameController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _renameController.text.length,
          );
        });
      },
      child: Draggable<VecSymbol>(
        data: sym,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.accentColor.withAlpha(200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.widgets_outlined, size: 12, color: theme.onAccent),
                const SizedBox(width: 4),
                Text(sym.name, style: TextStyle(color: theme.onAccent, fontSize: 11)),
              ],
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: _buildRowContent(theme, sym, isEditing)),
        child: _buildRowContent(theme, sym, isEditing),
      ),
    );
  }

  Widget _buildRowContent(AppTheme theme, VecSymbol sym, bool isEditing) {
    return Container(
      height: 36,
      color: isEditing ? theme.accentColor.withAlpha(30) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(
            Icons.widgets_outlined,
            size: 14,
            color: isEditing ? theme.accentColor : theme.textDisabled,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _renaming
                ? TextField(
                    controller: _renameController,
                    autofocus: true,
                    style: TextStyle(color: theme.textPrimary, fontSize: 12),
                    cursorColor: theme.accentColor,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 2),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _commitRename(),
                    onEditingComplete: _commitRename,
                  )
                : Text(
                    sym.name,
                    style: TextStyle(
                      color: isEditing ? theme.accentColor : theme.textPrimary,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          if (!_renaming) ...[
            // Edit button
            _SmallIconButton(
              icon: Icons.edit_outlined,
              tooltip: 'Edit master',
              theme: theme,
              active: isEditing,
              onTap: () {
                if (isEditing) {
                  ref.read(editingSymbolIdProvider.notifier).clear();
                } else {
                  ref.read(editingSymbolIdProvider.notifier).set(sym.id);
                }
              },
            ),
            const SizedBox(width: 2),
            // Delete button
            _SmallIconButton(
              icon: Icons.delete_outline,
              tooltip: 'Delete symbol',
              theme: theme,
              color: theme.error,
              onTap: () {
                if (ref.read(editingSymbolIdProvider) == sym.id) {
                  ref.read(editingSymbolIdProvider.notifier).clear();
                }
                ref.read(vecDocumentStateProvider.notifier).removeSymbol(sym.id);
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.tooltip, required this.theme, required this.onTap});

  final IconData icon;
  final String tooltip;
  final AppTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(icon, size: 16, color: theme.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({
    required this.icon,
    required this.tooltip,
    required this.theme,
    required this.onTap,
    this.active = false,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final AppTheme theme;
  final VoidCallback onTap;
  final bool active;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Icon(
              icon,
              size: 13,
              color: active ? theme.accentColor : (color ?? theme.textDisabled),
            ),
          ),
        ),
      ),
    );
  }
}
