import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_scene.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';

/// Horizontal scene tab bar displayed between the main content area and the
/// timeline panel.  Allows adding, deleting, renaming and switching scenes.
class SceneTabsBar extends ConsumerWidget {
  const SceneTabsBar({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(scenesProvider);
    final activeIdx = ref.watch(activeSceneIndexProvider);

    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        border: Border(
          top: BorderSide(color: theme.divider, width: 0.5),
          bottom: BorderSide(color: theme.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Scrollable tab list
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < scenes.length; i++)
                    _SceneTab(
                      scene: scenes[i],
                      isActive: i == activeIdx,
                      canDelete: scenes.length > 1,
                      theme: theme,
                      onActivate: () {
                        ref
                            .read(activeSceneIndexProvider.notifier)
                            .set(i);
                        ref
                            .read(selectedShapeIdProvider.notifier)
                            .clear();
                        ref
                            .read(selectedShapeIdsProvider.notifier)
                            .clear();
                      },
                      onDelete: () {
                        ref
                            .read(vecDocumentStateProvider.notifier)
                            .removeScene(scenes[i].id);
                        final newIdx =
                            (activeIdx >= i && activeIdx > 0)
                                ? activeIdx - 1
                                : (activeIdx >= scenes.length - 1
                                    ? scenes.length - 2
                                    : activeIdx);
                        ref
                            .read(activeSceneIndexProvider.notifier)
                            .set(newIdx.clamp(0, scenes.length - 2));
                      },
                      onRename: (name) {
                        ref
                            .read(vecDocumentStateProvider.notifier)
                            .updateScene(
                              scenes[i].id,
                              (s) => s.copyWith(name: name),
                            );
                      },
                    ),
                ],
              ),
            ),
          ),

          // Divider
          VerticalDivider(width: 1, color: theme.divider),

          // Add scene button
          Tooltip(
            message: 'Add scene',
            waitDuration: const Duration(milliseconds: 600),
            child: InkWell(
              onTap: () =>
                  ref.read(vecDocumentStateProvider.notifier).addNewScene(),
              child: SizedBox(
                width: 30,
                height: 30,
                child: Icon(Icons.add, size: 14, color: theme.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Individual scene tab
// =============================================================================

class _SceneTab extends StatefulWidget {
  const _SceneTab({
    required this.scene,
    required this.isActive,
    required this.canDelete,
    required this.theme,
    required this.onActivate,
    required this.onDelete,
    required this.onRename,
  });

  final VecScene scene;
  final bool isActive;
  final bool canDelete;
  final AppTheme theme;
  final VoidCallback onActivate;
  final VoidCallback onDelete;
  final void Function(String name) onRename;

  @override
  State<_SceneTab> createState() => _SceneTabState();
}

class _SceneTabState extends State<_SceneTab> {
  bool _isRenaming = false;
  late final TextEditingController _ctrl;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.scene.name);
  }

  @override
  void didUpdateWidget(_SceneTab old) {
    super.didUpdateWidget(old);
    if (!_isRenaming && old.scene.name != widget.scene.name) {
      _ctrl.text = widget.scene.name;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startRename() {
    setState(() {
      _ctrl.text = widget.scene.name;
      _ctrl.selection =
          TextSelection(baseOffset: 0, extentOffset: _ctrl.text.length);
      _isRenaming = true;
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  void _commitRename() {
    final name = _ctrl.text.trim();
    if (name.isNotEmpty && name != widget.scene.name) {
      widget.onRename(name);
    }
    setState(() => _isRenaming = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final isActive = widget.isActive;

    return GestureDetector(
      onTap: () {
        if (_isRenaming) return;
        widget.onActivate();
      },
      onDoubleTap: _startRename,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        constraints: const BoxConstraints(minWidth: 80, maxWidth: 160),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? t.surface : Colors.transparent,
          border: Border(
            right: BorderSide(color: t.divider, width: 0.5),
            bottom: BorderSide(
              color: isActive ? t.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name or inline rename field
            Flexible(
              child: _isRenaming
                  ? SizedBox(
                      height: 20,
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focusNode,
                        style:
                            TextStyle(fontSize: 11, color: t.textPrimary),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          filled: true,
                          fillColor: t.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3),
                            borderSide:
                                BorderSide(color: t.primaryColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3),
                            borderSide: BorderSide(
                                color: t.primaryColor, width: 1.5),
                          ),
                        ),
                        onSubmitted: (_) => _commitRename(),
                        onTapOutside: (_) => _commitRename(),
                      ),
                    )
                  : Text(
                      widget.scene.name,
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive ? t.textPrimary : t.textSecondary,
                        fontWeight: isActive
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),

            // Close button (only when there's more than one scene)
            if (widget.canDelete) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: widget.onDelete,
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: isActive
                      ? t.textSecondary
                      : t.textDisabled.withAlpha(100),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
