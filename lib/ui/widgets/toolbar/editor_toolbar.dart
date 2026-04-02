import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/theme.dart';
import '../../../core/import/svg_importer.dart';
import '../../../data/models/vec_asset.dart';
import '../../../data/models/vec_shape.dart';
import '../../../data/models/vec_transform.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import '../../contents/dialogs/export_dialog.dart';

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
          const SizedBox(width: 12),

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

          // Canvas size controls
          _CanvasSizeControls(theme: theme),
          const SizedBox(width: 12),
          Container(width: 1, height: 20, color: theme.divider),
          const SizedBox(width: 8),

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
          _UndoRedoButtons(theme: theme),
          const SizedBox(width: 8),
          Container(width: 1, height: 20, color: theme.divider),
          const SizedBox(width: 8),
          _SnapControls(theme: theme),
          const SizedBox(width: 4),
          _OnionSkinToggle(theme: theme),
          const SizedBox(width: 8),
          Container(width: 1, height: 20, color: theme.divider),
          const SizedBox(width: 8),
          _ImportImageButton(theme: theme),
          const SizedBox(width: 6),
          _ImportSvgButton(theme: theme),
          const SizedBox(width: 6),
          _ExportButton(theme: theme),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    required this.icon,
    required this.onTap,
    required this.theme,
    this.tooltip,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final AppTheme theme;
  final String? tooltip;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final iconColor = enabled ? theme.inactiveIcon : theme.textDisabled.withAlpha(80);

    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(4),
        hoverColor: enabled ? theme.primaryColor.withAlpha(20) : Colors.transparent,
        child: SizedBox(width: 30, height: 30, child: Icon(icon, size: 16, color: iconColor)),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, waitDuration: const Duration(milliseconds: 500), child: child);
    }
    return child;
  }
}

class _CanvasSizeControls extends HookConsumerWidget {
  const _CanvasSizeControls({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(currentMetaProvider);
    final isEditing = useState(false);
    final widthController = useTextEditingController(text: meta.stageWidth.round().toString());
    final heightController = useTextEditingController(text: meta.stageHeight.round().toString());
    final widthFocus = useFocusNode();
    final heightFocus = useFocusNode();

    // Sync controllers when meta changes externally
    useEffect(() {
      if (!widthFocus.hasFocus) {
        widthController.text = meta.stageWidth.round().toString();
      }
      if (!heightFocus.hasFocus) {
        heightController.text = meta.stageHeight.round().toString();
      }
      return null;
    }, [meta.stageWidth, meta.stageHeight]);

    void applySize() {
      final w = double.tryParse(widthController.text);
      final h = double.tryParse(heightController.text);
      if (w != null && h != null && w >= 1 && h >= 1 && w <= 16384 && h <= 16384) {
        ref.read(vecDocumentStateProvider.notifier).updateMeta(meta.copyWith(stageWidth: w, stageHeight: h));
      } else {
        widthController.text = meta.stageWidth.round().toString();
        heightController.text = meta.stageHeight.round().toString();
      }
      isEditing.value = false;
    }

    if (isEditing.value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.crop, size: 14, color: theme.textSecondary),
          const SizedBox(width: 6),
          _SizeField(
            controller: widthController,
            focusNode: widthFocus,
            theme: theme,
            onSubmitted: (_) => heightFocus.requestFocus(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('×', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
          ),
          _SizeField(
            controller: heightController,
            focusNode: heightFocus,
            theme: theme,
            onSubmitted: (_) => applySize(),
          ),
          const SizedBox(width: 4),
          _ToolbarIconButton(icon: Icons.check, onTap: applySize, theme: theme, tooltip: 'Apply size'),
        ],
      );
    }

    void applyPreset(double w, double h) {
      ref.read(vecDocumentStateProvider.notifier).updateMeta(meta.copyWith(stageWidth: w, stageHeight: h));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Canvas size (click to edit)',
          waitDuration: const Duration(milliseconds: 500),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              hoverColor: theme.primaryColor.withAlpha(20),
              onTap: () {
                widthController.text = meta.stageWidth.round().toString();
                heightController.text = meta.stageHeight.round().toString();
                isEditing.value = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widthFocus.requestFocus();
                  widthController.selection = TextSelection(baseOffset: 0, extentOffset: widthController.text.length);
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.crop, size: 14, color: theme.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '${meta.stageWidth.round()} × ${meta.stageHeight.round()}',
                      style: TextStyle(fontSize: 11, color: theme.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Preset sizes dropdown
        Tooltip(
          message: 'Preset sizes',
          waitDuration: const Duration(milliseconds: 500),
          child: PopupMenuButton<(double, double)>(
            onSelected: (size) => applyPreset(size.$1, size.$2),
            color: theme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: theme.divider, width: 0.5),
            ),
            itemBuilder: (_) => [
              _presetHeader('Mobile'),
              _presetItem(theme, 'iPhone 15 Pro', 393, 852),
              _presetItem(theme, 'iPhone SE', 375, 667),
              _presetItem(theme, 'Android', 360, 800),
              _presetHeader('Tablet'),
              _presetItem(theme, 'iPad', 820, 1180),
              _presetItem(theme, 'iPad Pro 12.9"', 1024, 1366),
              _presetHeader('Desktop'),
              _presetItem(theme, '1920 × 1080', 1920, 1080),
              _presetItem(theme, '1440 × 900', 1440, 900),
              _presetItem(theme, '1280 × 720', 1280, 720),
              _presetHeader('Social'),
              _presetItem(theme, 'Instagram Post', 1080, 1080),
              _presetItem(theme, 'Twitter / X Banner', 1500, 500),
              _presetItem(theme, 'YouTube Thumbnail', 1280, 720),
              _presetHeader('Icons'),
              _presetItem(theme, '512 × 512', 512, 512),
              _presetItem(theme, '256 × 256', 256, 256),
              _presetItem(theme, '64 × 64', 64, 64),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Icon(Icons.expand_more, size: 14, color: theme.textDisabled),
            ),
          ),
        ),
      ],
    );
  }

  static PopupMenuEntry<(double, double)> _presetHeader(String label) => PopupMenuItem<(double, double)>(
    enabled: false,
    height: 24,
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.8),
    ),
  );

  static PopupMenuItem<(double, double)> _presetItem(AppTheme theme, String name, double w, double h) =>
      PopupMenuItem<(double, double)>(
        value: (w, h),
        height: 28,
        child: Row(
          children: [
            Expanded(
              child: Text(name, style: TextStyle(fontSize: 11, color: theme.textPrimary)),
            ),
            Text('${w.round()}×${h.round()}', style: TextStyle(fontSize: 10, color: theme.textDisabled)),
          ],
        ),
      );
}

class _SizeField extends StatelessWidget {
  const _SizeField({required this.controller, required this.focusNode, required this.theme, this.onSubmitted});

  final TextEditingController controller;
  final FocusNode focusNode;
  final AppTheme theme;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 24,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 11, color: theme.textPrimary, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: theme.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: theme.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: theme.primaryColor),
          ),
          isDense: true,
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Import SVG button
// ---------------------------------------------------------------------------

class _ImportSvgButton extends ConsumerWidget {
  const _ImportSvgButton({required this.theme});
  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: 'Import SVG',
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          hoverColor: theme.primaryColor.withAlpha(20),
          onTap: () => _pickAndImport(ref),
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.divider.withAlpha(100)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.file_download_outlined, size: 13, color: theme.textSecondary),
                const SizedBox(width: 5),
                Text(
                  'Import',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: theme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndImport(WidgetRef ref) async {
    try {
      String? svgContent;

      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['svg'],
          withData: true,
        );
        final bytes = result?.files.firstOrNull?.bytes;
        if (bytes == null) return;
        svgContent = String.fromCharCodes(bytes);
      } else {
        final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['svg']);
        final path = result?.files.firstOrNull?.path;
        if (path == null) return;
        svgContent = await File(path).readAsString();
      }

      const importer = SvgImporter();
      final shapes = importer.import(svgContent);
      if (shapes.isEmpty) return;

      final scene = ref.read(activeSceneProvider);
      final layerId = ref.read(activeLayerIdProvider);
      if (scene == null || layerId == null) return;

      ref.read(vecDocumentStateProvider.notifier).addShapes(scene.id, layerId, shapes);

      // Select the first imported shape
      if (shapes.isNotEmpty) {
        ref.read(selectedShapeIdProvider.notifier).set(shapes.first.id);
        ref.read(selectedShapeIdsProvider.notifier).setSingle(shapes.first.id);
      }
    } catch (_) {
      // Silently ignore import errors
    }
  }
}

// ---------------------------------------------------------------------------
// Export button
// ---------------------------------------------------------------------------

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.theme});
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Export (Cmd+E)',
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          hoverColor: theme.primaryColor.withOpacity(0.12),
          onTap: () => ExportDialog.show(context),
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.primaryColor.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.upload_rounded, size: 13, color: theme.primaryColor),
                const SizedBox(width: 5),
                Text(
                  'Export',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.primaryColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UndoRedoButtons extends ConsumerWidget {
  const _UndoRedoButtons({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availability = ref.watch(undoAvailabilityProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToolbarIconButton(
          icon: Icons.undo,
          onTap: availability.canUndo ? () => ref.read(vecDocumentStateProvider.notifier).undo() : () {},
          theme: theme,
          tooltip: 'Undo (Ctrl+Z)',
          enabled: availability.canUndo,
        ),
        _ToolbarIconButton(
          icon: Icons.redo,
          onTap: availability.canRedo ? () => ref.read(vecDocumentStateProvider.notifier).redo() : () {},
          theme: theme,
          tooltip: 'Redo (Ctrl+Shift+Z)',
          enabled: availability.canRedo,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Onion skin toggle
// ---------------------------------------------------------------------------

class _OnionSkinToggle extends ConsumerWidget {
  const _OnionSkinToggle({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(onionSettingsProvider);
    final notifier = ref.read(onionSettingsProvider.notifier);
    final active = settings.enabled;

    return Tooltip(
      message: 'Onion skinning',
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: notifier.toggleEnabled,
          borderRadius: BorderRadius.circular(4),
          hoverColor: theme.primaryColor.withAlpha(20),
          child: Container(
            width: 28,
            height: 28,
            decoration: active
                ? BoxDecoration(color: theme.primaryColor.withAlpha(18), borderRadius: BorderRadius.circular(4))
                : null,
            child: Icon(Icons.layers_outlined, size: 15, color: active ? theme.primaryColor : theme.inactiveIcon),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Snap + Ruler toggle controls
// ---------------------------------------------------------------------------

class _SnapControls extends ConsumerWidget {
  const _SnapControls({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(snapSettingsProvider);
    final notifier = ref.read(snapSettingsProvider.notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SnapToggle(
          icon: Icons.straighten_outlined,
          active: snap.showRulers,
          onTap: notifier.toggleRulers,
          tooltip: 'Toggle rulers',
          theme: theme,
        ),
        _SnapToggle(
          icon: Icons.grid_4x4_outlined,
          active: snap.toGrid,
          onTap: notifier.toggleGrid,
          tooltip: 'Snap to grid (${snap.gridSize}px)',
          theme: theme,
        ),
        _SnapToggle(
          icon: Icons.near_me_outlined,
          active: snap.toObjects,
          onTap: notifier.toggleObjects,
          tooltip: 'Snap to objects',
          theme: theme,
        ),
        _SnapToggle(
          icon: Icons.grid_on_outlined,
          active: snap.showGrid,
          onTap: notifier.toggleShowGrid,
          tooltip: 'Show grid',
          theme: theme,
        ),
      ],
    );
  }
}

class _SnapToggle extends StatelessWidget {
  const _SnapToggle({
    required this.icon,
    required this.active,
    required this.onTap,
    required this.tooltip,
    required this.theme,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final String tooltip;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final iconColor = active ? theme.primaryColor : theme.inactiveIcon;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          hoverColor: theme.primaryColor.withAlpha(20),
          child: Container(
            width: 28,
            height: 28,
            decoration: active
                ? BoxDecoration(color: theme.primaryColor.withAlpha(18), borderRadius: BorderRadius.circular(4))
                : null,
            child: Icon(icon, size: 15, color: iconColor),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Import Image button
// ---------------------------------------------------------------------------

class _ImportImageButton extends ConsumerWidget {
  const _ImportImageButton({required this.theme});
  final AppTheme theme;

  static const _uuid = Uuid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: 'Import Image (PNG, JPG, WebP)',
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          hoverColor: theme.primaryColor.withAlpha(20),
          onTap: () => _pickAndImport(context, ref),
          child: Container(
            width: 30,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.divider.withAlpha(100)),
            ),
            child: Icon(Icons.image_outlined, size: 14, color: theme.textSecondary),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndImport(BuildContext context, WidgetRef ref) async {
    try {
      List<int>? bytes;
      late String fileName;
      String? mimeType;

      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
        final file = result?.files.firstOrNull;
        if (file == null) return;
        bytes = file.bytes?.toList();
        fileName = file.name;
        mimeType = _mimeFromName(file.name);
      } else {
        final result = await FilePicker.platform.pickFiles(type: FileType.image);
        final file = result?.files.firstOrNull;
        if (file == null || file.path == null) return;
        bytes = await File(file.path!).readAsBytes();
        fileName = file.name;
        mimeType = _mimeFromName(file.name);
      }

      if (bytes == null || bytes.isEmpty) return;

      final assetId = _uuid.v4();
      final shapeId = _uuid.v4();
      final dataBase64 = base64Encode(bytes);

      final asset = VecAsset(
        id: assetId,
        name: fileName,
        type: VecAssetType.image,
        path: fileName,
        mimeType: mimeType,
        dataBase64: dataBase64,
      );

      // Place image at centre of stage with natural dimensions capped to 800px
      final meta = ref.read(currentMetaProvider);
      const maxSide = 800.0;
      // We don't have the actual pixel size here; default to 400×300
      final w = maxSide.clamp(1.0, meta.stageWidth);
      final h = (w * 3 / 4).clamp(1.0, meta.stageHeight);
      final x = (meta.stageWidth - w) / 2;
      final y = (meta.stageHeight - h) / 2;

      final shape = VecShape.image(
        data: VecShapeData(
          id: shapeId,
          name: fileName,
          transform: VecTransform(x: x, y: y, width: w, height: h),
        ),
        assetId: assetId,
      );

      final docNotifier = ref.read(vecDocumentStateProvider.notifier);
      docNotifier.addAsset(asset);

      final scene = ref.read(activeSceneProvider);
      final layerId = ref.read(activeLayerIdProvider);
      if (scene == null || layerId == null) return;

      docNotifier.addShape(scene.id, layerId, shape);

      ref.read(selectedShapeIdProvider.notifier).set(shapeId);
      ref.read(selectedShapeIdsProvider.notifier).setSingle(shapeId);
    } catch (_) {
      // Silently ignore import errors
    }
  }

  String? _mimeFromName(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return null;
    }
  }
}
