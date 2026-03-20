import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import 'tool_button_group.dart';

class EditorToolbar extends HookConsumerWidget {
  const EditorToolbar({super.key, required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(currentMetaProvider);
    final zoom = ref.watch(zoomLevelProvider);
    final isEditing = useState(false);
    final nameController = useTextEditingController(text: meta.name);
    final nameFocus = useFocusNode();

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.toolbarColor,
        border: Border(bottom: BorderSide(color: theme.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          // Left: tool buttons
          ToolButtonGroup(theme: theme),

          const Spacer(),

          // Center: document name
          if (isEditing.value)
            SizedBox(
              width: 200,
              height: 28,
              child: TextField(
                controller: nameController,
                focusNode: nameFocus,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: theme.textPrimary, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: theme.primaryColor),
                  ),
                  isDense: true,
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    ref.read(vecDocumentStateProvider.notifier).updateMeta(meta.copyWith(name: value.trim()));
                  }
                  isEditing.value = false;
                },
                onTapOutside: (_) {
                  isEditing.value = false;
                },
              ),
            )
          else
            GestureDetector(
              onDoubleTap: () {
                nameController.text = meta.name;
                isEditing.value = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  nameFocus.requestFocus();
                  nameController.selection = TextSelection(baseOffset: 0, extentOffset: nameController.text.length);
                });
              },
              child: Text(
                meta.name,
                style: TextStyle(fontSize: 13, color: theme.textPrimary, fontWeight: FontWeight.w500),
              ),
            ),

          const Spacer(),

          // Right: zoom controls + actions
          _ToolbarIconButton(
            icon: Icons.remove,
            onTap: () => ref.read(zoomLevelProvider.notifier).zoomOut(),
            theme: theme,
            tooltip: 'Zoom out',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => ref.read(zoomLevelProvider.notifier).zoom100(),
              child: SizedBox(
                width: 48,
                child: Text(
                  '${(zoom * 100).round()}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: theme.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          _ToolbarIconButton(
            icon: Icons.add,
            onTap: () => ref.read(zoomLevelProvider.notifier).zoomIn(),
            theme: theme,
            tooltip: 'Zoom in',
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 20, color: theme.divider),
          const SizedBox(width: 8),
          _ToolbarIconButton(icon: Icons.undo, onTap: () {}, theme: theme, tooltip: 'Undo'),
          _ToolbarIconButton(icon: Icons.redo, onTap: () {}, theme: theme, tooltip: 'Redo'),
          const SizedBox(width: 8),
          Container(width: 1, height: 20, color: theme.divider),
          const SizedBox(width: 8),
          _ToolbarIconButton(icon: Icons.file_download_outlined, onTap: () {}, theme: theme, tooltip: 'Export'),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({required this.icon, required this.onTap, required this.theme, this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final AppTheme theme;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        hoverColor: theme.primaryColor.withAlpha(20),
        child: SizedBox(width: 30, height: 30, child: Icon(icon, size: 16, color: theme.inactiveIcon)),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, waitDuration: const Duration(milliseconds: 500), child: child);
    }
    return child;
  }
}
