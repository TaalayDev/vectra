import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

import '../../app/theme/theme.dart';
import '../../core/import/svg_importer.dart';
import '../../core/tools/drawing_tool_handler.dart';
import '../../data/models/vec_shape.dart';
import '../../providers/clipboard_provider.dart';
import '../../providers/document_provider.dart';
import '../../providers/drawing_state_provider.dart';
import '../../providers/editor_state_provider.dart';
import '../../providers/motion_path_provider.dart';
import '../../providers/toast_provider.dart';
import '../../ui/contents/dialogs/export_dialog.dart';
import '../../ui/contents/theme_selector.dart';
import '../contents/dialogs/shortcut_sheet.dart';
import '../contents/shortcuts_wrapper.dart';
import '../widgets/workspace/workspace_layout.dart';

const _uuid = Uuid();
const _pasteOffset = 20.0;
const _clipboardMime = 'application/x-vectra-shapes+json';

const _kImageExtensions = {'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'};

String _mimeFromExt(String ext) => switch (ext) {
  'png' => 'image/png',
  'jpg' || 'jpeg' => 'image/jpeg',
  'gif' => 'image/gif',
  'bmp' => 'image/bmp',
  'webp' => 'image/webp',
  _ => 'image/*',
};

/// Top-level function so it can be passed to [compute].
(int, int)? _decodeImageDimensions(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  return (decoded.width, decoded.height);
}

String _encodeClipboardPayload(List<VecShape> shapes) {
  return jsonEncode({
    'mime': _clipboardMime,
    'version': 1,
    'shapes': shapes.map((s) => s.toJson()).toList(growable: false),
  });
}

List<VecShape>? _decodeClipboardPayload(String? text) {
  if (text == null || text.isEmpty) return null;
  try {
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) return null;
    if (decoded['mime'] != _clipboardMime) return null;
    final rawShapes = decoded['shapes'];
    if (rawShapes is! List) return null;
    return rawShapes
        .whereType<Map>()
        .map((s) => VecShape.fromJson(Map<String, dynamic>.from(s)))
        .toList(growable: false);
  } catch (_) {
    return null;
  }
}

/// Returns a deep copy of [shape] with a fresh ID and [offset] added to x/y.
VecShape _cloneShape(VecShape shape, {double offset = _pasteOffset}) {
  return shape.copyWith(
    data: shape.data.copyWith(
      id: _uuid.v4(),
      transform: shape.data.transform.copyWith(x: shape.data.transform.x + offset, y: shape.data.transform.y + offset),
    ),
  );
}

class EditorScreen extends HookConsumerWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).theme;
    final isDragging = useState(false);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final notifier = ref.read(vecDocumentStateProvider.notifier);
        if (!notifier.isDirty) {
          if (context.mounted) Navigator.of(context).pop();
          return;
        }
        // Show "unsaved changes" confirmation
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Unsaved changes'),
            content: const Text('You have unsaved changes that will be lost if you leave. Continue?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Leave')),
            ],
          ),
        );
        if ((leave ?? false) && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: theme.background,
        body: ShortcutsWrapper(
          onUndo: () => ref.read(vecDocumentStateProvider.notifier).undo(),
          onRedo: () => ref.read(vecDocumentStateProvider.notifier).redo(),
          onSave: () async {
            // Ctrl+S — only saves if document already has a file path.
            // For new documents use Ctrl+Shift+S (Save As).
            final notifier = ref.read(vecDocumentStateProvider.notifier);
            if (notifier.hasFilePath) {
              await notifier.save();
              ref.read(toastProvider.notifier).show('Saved');
            }
          },
          onSaveAs: () async {
            final notifier = ref.read(vecDocumentStateProvider.notifier);
            final docName = ref.read(vecDocumentStateProvider).meta.name;
            final path = await FilePicker.platform.saveFile(
              dialogTitle: 'Save document as',
              fileName: '$docName.vct',
              type: FileType.custom,
              allowedExtensions: ['vct'],
            );
            if (path != null) {
              await notifier.saveAs(path);
              final fileName = path.split('/').last;
              ref.read(toastProvider.notifier).show('Saved as $fileName');
            }
          },
          onZoomIn: () => ref.read(zoomLevelProvider.notifier).zoomIn(),
          onZoomOut: () => ref.read(zoomLevelProvider.notifier).zoomOut(),
          onZoomFit: () => ref.read(fitRequestProvider.notifier).request(),
          onZoomSelection: () => ref.read(fitSelectionRequestProvider.notifier).state++,
          onZoom100: () => ref.read(zoomLevelProvider.notifier).zoom100(),
          onToggleUI: () => ref.read(panelVisibilityProvider.notifier).toggleAll(),
          onNewLayer: () {
            final scene = ref.read(activeSceneProvider);
            if (scene != null) {
              ref.read(vecDocumentStateProvider.notifier).addLayer(scene.id);
            }
          },
          onDeleteLayer: () {
            // If a shape is selected, delete the shape instead of the layer
            final selectedId = ref.read(selectedShapeIdProvider);
            if (selectedId != null) {
              final scene = ref.read(activeSceneProvider);
              final layerId = ref.read(activeLayerIdProvider);
              if (scene != null && layerId != null) {
                ref.read(vecDocumentStateProvider.notifier).removeShape(scene.id, layerId, selectedId);
                ref.read(selectedShapeIdProvider.notifier).clear();
              }
              return;
            }
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            if (scene != null && layerId != null) {
              ref.read(vecDocumentStateProvider.notifier).removeLayer(scene.id, layerId);
            }
          },
          onEscape: () {
            // Exit inline text editing first
            final textEditingId = ref.read(textEditingShapeIdProvider);
            if (textEditingId != null) {
              ref.read(vecDocumentStateProvider.notifier).commitCurrentState();
              ref.read(textEditingShapeIdProvider.notifier).state = null;
              return;
            }
            // Cancel motion path drawing if active
            final mpTarget = ref.read(motionPathDrawTargetProvider);
            if (mpTarget != null) {
              ref.read(motionPathDrawTargetProvider.notifier).cancel();
              ref.read(motionPathPreviewNodesProvider.notifier).clear();
              return;
            }
            final tool = ref.read(activeToolProvider);
            // Cancel any in-progress drag drawing
            ref.read(activeDrawingProvider.notifier).finish();
            // Finish pen path as open (not closed)
            if (tool == VecTool.pen) {
              final penState = ref.read(activePenDrawingProvider.notifier).finish();
              if (penState != null && penState.points.length >= 2) {
                final baseColor = ref.read(baseColorProvider);
                final handler = DrawingToolHandler(fillColor: baseColor.fillColor, strokeColor: baseColor.strokeColor);
                final shape = handler.createPath(penState, closed: false);
                final scene = ref.read(activeSceneProvider);
                final layerId = ref.read(activeLayerIdProvider);
                if (scene != null && layerId != null) {
                  ref.read(vecDocumentStateProvider.notifier).addShape(scene.id, layerId, shape);
                  ref.read(selectedShapeIdProvider.notifier).set(shape.id);
                }
              }
              ref.read(activeToolProvider.notifier).set(VecTool.select);
              return;
            }
            // Exit symbol edit mode if active
            final editingSymbol = ref.read(editingSymbolIdProvider);
            if (editingSymbol != null) {
              ref.read(editingSymbolIdProvider.notifier).clear();
              ref.read(selectedShapeIdProvider.notifier).clear();
              ref.read(selectedShapeIdsProvider.notifier).clear();
              return;
            }
            // Exit group-edit mode if active, otherwise deselect
            final groupId = ref.read(activeGroupIdProvider);
            if (groupId != null) {
              ref.read(activeGroupIdProvider.notifier).clear();
              ref.read(selectedShapeIdProvider.notifier).set(groupId);
              ref.read(selectedShapeIdsProvider.notifier).setSingle(groupId);
            } else {
              ref.read(selectedShapeIdProvider.notifier).clear();
              ref.read(selectedShapeIdsProvider.notifier).clear();
            }
            // Switch back to select tool
            ref.read(activeToolProvider.notifier).set(VecTool.select);
          },
          onEnter: () {
            final tool = ref.read(activeToolProvider);
            if (tool == VecTool.pen) {
              final penState = ref.read(activePenDrawingProvider.notifier).finish();
              if (penState != null && penState.points.length >= 2) {
                final baseColor = ref.read(baseColorProvider);
                final handler = DrawingToolHandler(fillColor: baseColor.fillColor, strokeColor: baseColor.strokeColor);
                final shape = handler.createPath(penState, closed: true);
                final scene = ref.read(activeSceneProvider);
                final layerId = ref.read(activeLayerIdProvider);
                if (scene != null && layerId != null) {
                  ref.read(vecDocumentStateProvider.notifier).addShape(scene.id, layerId, shape);
                  ref.read(selectedShapeIdProvider.notifier).set(shape.id);
                }
              }
            }
          },
          onToolSwitch: (key) {
            final tool = switch (key) {
              'V' => VecTool.select,
              'P' => VecTool.pen,
              'L' => VecTool.line,
              'R' => VecTool.rectangle,
              'E' => VecTool.ellipse,
              'T' => VecTool.text,
              'U' => VecTool.bend,
              'K' => VecTool.knife,
              'B' => VecTool.freedraw,
              _ => null,
            };
            if (tool != null) {
              ref.read(activeToolProvider.notifier).set(tool);
            }
          },
          onNudge: (dx, dy) {
            final selectedId = ref.read(selectedShapeIdProvider);
            if (selectedId == null) return;
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            if (scene == null || layerId == null) return;
            final groupId = ref.read(activeGroupIdProvider);
            if (groupId != null) {
              // Nudge a child inside the active group
              ref
                  .read(vecDocumentStateProvider.notifier)
                  .updateGroupChildNoHistory(
                    scene.id,
                    layerId,
                    groupId,
                    selectedId,
                    (c) => c.copyWith(
                      data: c.data.copyWith(
                        transform: c.transform.copyWith(x: c.transform.x + dx, y: c.transform.y + dy),
                      ),
                    ),
                  );
              ref.read(vecDocumentStateProvider.notifier).commitCurrentState();
              return;
            }
            ref
                .read(vecDocumentStateProvider.notifier)
                .updateShape(
                  scene.id,
                  layerId,
                  selectedId,
                  (shape) => shape.copyWith(
                    data: shape.data.copyWith(
                      transform: shape.transform.copyWith(x: shape.transform.x + dx, y: shape.transform.y + dy),
                    ),
                  ),
                );
          },
          onSelectAll: () {
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            if (scene == null || layerId == null) return;
            for (final layer in scene.layers) {
              if (layer.id != layerId) continue;
              final ids = layer.shapes.map((s) => s.id).toList();
              if (ids.isEmpty) return;
              ref.read(selectedShapeIdsProvider.notifier).setAll(ids);
              ref.read(selectedShapeIdProvider.notifier).set(ids.last);
              return;
            }
          },
          onDeselectAll: () {
            ref.read(selectedShapeIdProvider.notifier).clear();
            ref.read(selectedShapeIdsProvider.notifier).clear();
          },
          onCopy: () {
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            if (scene == null || layerId == null) return;
            final selectedIds = ref.read(selectedShapeIdsProvider);
            if (selectedIds.isEmpty) return;
            for (final layer in scene.layers) {
              if (layer.id != layerId) continue;
              final shapes = layer.shapes.where((s) => selectedIds.contains(s.id)).toList();
              if (shapes.isNotEmpty) {
                ref.read(clipboardProvider.notifier).set(shapes);
                Clipboard.setData(ClipboardData(text: _encodeClipboardPayload(shapes)));
                ref.read(toastProvider.notifier).show('Copied ${shapes.length} shape${shapes.length > 1 ? 's' : ''}');
              }
              return;
            }
          },
          onPaste: () async {
            final systemText = (await Clipboard.getData('text/plain'))?.text;
            final systemShapes = _decodeClipboardPayload(systemText);
            final List<VecShape> clipboard = systemShapes ?? ref.read(clipboardProvider);
            if (clipboard.isEmpty) return;
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            if (scene == null || layerId == null) return;
            final clones = clipboard.map(_cloneShape).toList();
            ref.read(vecDocumentStateProvider.notifier).addShapes(scene.id, layerId, clones);
            ref.read(selectedShapeIdsProvider.notifier).setAll(clones.map((s) => s.id).toList());
            ref.read(selectedShapeIdProvider.notifier).set(clones.last.id);
            ref.read(toastProvider.notifier).show('Pasted ${clones.length} shape${clones.length > 1 ? 's' : ''}');
          },
          onPasteInPlace: () async {
            // Paste at exact same coordinates (no offset)
            final systemText = (await Clipboard.getData('text/plain'))?.text;
            final systemShapes = _decodeClipboardPayload(systemText);
            final List<VecShape> clipboard = systemShapes ?? ref.read(clipboardProvider);
            if (clipboard.isEmpty) return;
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            if (scene == null || layerId == null) return;
            final clones = clipboard.map((s) => _cloneShape(s, offset: 0)).toList();
            ref.read(vecDocumentStateProvider.notifier).addShapes(scene.id, layerId, clones);
            ref.read(selectedShapeIdsProvider.notifier).setAll(clones.map((s) => s.id).toList());
            ref.read(selectedShapeIdProvider.notifier).set(clones.last.id);
            ref.read(toastProvider.notifier).show('Pasted in place');
          },
          onCut: () {
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            if (scene == null || layerId == null) return;
            final selectedIds = ref.read(selectedShapeIdsProvider);
            if (selectedIds.isEmpty) return;
            // Copy first
            for (final layer in scene.layers) {
              if (layer.id != layerId) continue;
              final shapes = layer.shapes.where((s) => selectedIds.contains(s.id)).toList();
              if (shapes.isNotEmpty) {
                ref.read(clipboardProvider.notifier).set(shapes);
                Clipboard.setData(ClipboardData(text: _encodeClipboardPayload(shapes)));
              }
              break;
            }
            // Remove in one undo step
            ref.read(vecDocumentStateProvider.notifier).removeShapes(scene.id, layerId, selectedIds.toList());
            ref.read(selectedShapeIdProvider.notifier).clear();
            ref.read(selectedShapeIdsProvider.notifier).clear();
            ref.read(toastProvider.notifier).show('Cut');
          },
          onDuplicate: () {
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            if (scene == null || layerId == null) return;
            final selectedIds = ref.read(selectedShapeIdsProvider);
            if (selectedIds.isEmpty) return;
            for (final layer in scene.layers) {
              if (layer.id != layerId) continue;
              final clones = layer.shapes.where((s) => selectedIds.contains(s.id)).map(_cloneShape).toList();
              if (clones.isEmpty) return;
              ref.read(vecDocumentStateProvider.notifier).addShapes(scene.id, layerId, clones);
              ref.read(selectedShapeIdsProvider.notifier).setAll(clones.map((s) => s.id).toList());
              ref.read(selectedShapeIdProvider.notifier).set(clones.last.id);
              ref.read(toastProvider.notifier).show('Duplicated');
              return;
            }
          },
          onGroup: () {
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            if (scene == null || layerId == null) return;
            final selectedIds = ref.read(selectedShapeIdsProvider);
            if (selectedIds.length < 2) return;
            final groupId = ref
                .read(vecDocumentStateProvider.notifier)
                .groupShapes(scene.id, layerId, selectedIds.toList());
            ref.read(selectedShapeIdProvider.notifier).set(groupId);
            ref.read(selectedShapeIdsProvider.notifier).setSingle(groupId);
            ref.read(toastProvider.notifier).show('Grouped');
          },
          onUngroup: () {
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            if (scene == null || layerId == null) return;
            final selectedId = ref.read(selectedShapeIdProvider);
            if (selectedId == null) return;
            final childIds = ref.read(vecDocumentStateProvider.notifier).ungroupShape(scene.id, layerId, selectedId);
            if (childIds.isNotEmpty) {
              ref.read(selectedShapeIdsProvider.notifier).setAll(childIds);
              ref.read(selectedShapeIdProvider.notifier).set(childIds.last);
              ref.read(toastProvider.notifier).show('Ungrouped');
            } else {
              ref.read(selectedShapeIdProvider.notifier).clear();
              ref.read(selectedShapeIdsProvider.notifier).clear();
            }
          },
          onBringForward: () {
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            final shapeId = ref.read(selectedShapeIdProvider);
            if (scene != null && layerId != null && shapeId != null) {
              ref.read(vecDocumentStateProvider.notifier).bringForward(scene.id, layerId, shapeId);
            }
          },
          onSendBackward: () {
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            final shapeId = ref.read(selectedShapeIdProvider);
            if (scene != null && layerId != null && shapeId != null) {
              ref.read(vecDocumentStateProvider.notifier).sendBackward(scene.id, layerId, shapeId);
            }
          },
          onBringToFront: () {
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            final shapeId = ref.read(selectedShapeIdProvider);
            if (scene != null && layerId != null && shapeId != null) {
              ref.read(vecDocumentStateProvider.notifier).bringToFront(scene.id, layerId, shapeId);
            }
          },
          onSendToBack: () {
            final scene = ref.read(activeSceneProvider);
            final layerId = ref.read(activeLayerIdProvider);
            final shapeId = ref.read(selectedShapeIdProvider);
            if (scene != null && layerId != null && shapeId != null) {
              ref.read(vecDocumentStateProvider.notifier).sendToBack(scene.id, layerId, shapeId);
            }
          },
          onExport: () => ExportDialog.show(context),
          onHelpSheet: () => showShortcutSheet(context, theme),
          onPipetteStart: () => ref.read(pipetteModeProvider.notifier).state = true,
          onPipetteEnd: () {
            ref.read(pipetteModeProvider.notifier).state = false;
            ref.read(pipetteColorProvider.notifier).state = null;
          },
          onImport: () async {
            final notifier = ref.read(vecDocumentStateProvider.notifier);
            // Warn about unsaved changes before opening another file
            if (notifier.isDirty) {
              final proceed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Unsaved changes'),
                  content: const Text('Opening a new file will discard unsaved changes. Continue?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Open')),
                  ],
                ),
              );
              if (!(proceed ?? false)) return;
            }
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['vct'],
              dialogTitle: 'Open document',
            );
            if (result != null && result.files.single.path != null) {
              await notifier.openFile(result.files.single.path!);
              final fileName = result.files.single.path!.split('/').last;
              ref.read(toastProvider.notifier).show('Opened $fileName');
            }
          },
          child: DropTarget(
            onDragEntered: (_) => isDragging.value = true,
            onDragExited: (_) => isDragging.value = false,
            onDragDone: (detail) async {
              isDragging.value = false;
              final files = detail.files;
              if (files.isEmpty) return;
              final file = files.first;
              final path = file.path;
              final ext = path.split('.').last.toLowerCase();

              if (ext == 'vct') {
                final notifier = ref.read(vecDocumentStateProvider.notifier);
                if (notifier.isDirty) {
                  final proceed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Unsaved changes'),
                      content: const Text('Opening a new file will discard unsaved changes. Continue?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Open')),
                      ],
                    ),
                  );
                  if (!(proceed ?? false)) return;
                }
                await notifier.openFile(path);
                final fileName = path.split('/').last;
                if (context.mounted) ref.read(toastProvider.notifier).show('Opened $fileName');
              } else if (ext == 'svg') {
                final svgContent = await File(path).readAsString();
                const importer = SvgImporter();
                final shapes = importer.import(svgContent);
                if (shapes.isEmpty) return;
                final scene = ref.read(activeSceneProvider);
                final layerId = ref.read(activeLayerIdProvider);
                if (scene == null || layerId == null) return;
                ref.read(vecDocumentStateProvider.notifier).addShapes(scene.id, layerId, shapes);
                final fileName = path.split(Platform.pathSeparator).last;
                if (context.mounted) ref.read(toastProvider.notifier).show('Imported $fileName');
              } else if (_kImageExtensions.contains(ext)) {
                final scene = ref.read(activeSceneProvider);
                if (scene == null) return;
                final bytes = await File(path).readAsBytes();
                final dims = await compute(_decodeImageDimensions, bytes);
                final fileName = path.split(Platform.pathSeparator).last;
                if (dims == null) {
                  if (context.mounted) ref.read(toastProvider.notifier).show('Could not read image');
                  return;
                }
                final dataBase64 = base64Encode(bytes);
                ref
                    .read(vecDocumentStateProvider.notifier)
                    .addRasterLayer(
                      scene.id,
                      assetName: fileName,
                      mimeType: _mimeFromExt(ext),
                      dataBase64: dataBase64,
                      imageWidth: dims.$1.toDouble(),
                      imageHeight: dims.$2.toDouble(),
                    );
                // Switch active layer to the newly-created raster layer.
                final newScene = ref.read(activeSceneProvider);
                if (newScene != null && newScene.layers.isNotEmpty) {
                  ref.read(activeLayerIdProvider.notifier).set(newScene.layers.last.id);
                }
                if (context.mounted) ref.read(toastProvider.notifier).show('Added raster layer: $fileName');
              }
            },
            child: Stack(
              children: [
                WorkspaceLayout(theme: theme),
                if (isDragging.value) _EditorDropOverlay(theme: theme),
              ],
            ),
          ),
        ),
      ), // Scaffold
    ); // PopScope
  }
}

// =============================================================================
// Drop overlay for the editor
// =============================================================================

class _EditorDropOverlay extends StatelessWidget {
  const _EditorDropOverlay({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: theme.primaryColor.withValues(alpha: 0.08),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: theme.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.primaryColor, width: 2),
                boxShadow: [
                  BoxShadow(color: theme.primaryColor.withValues(alpha: 0.2), blurRadius: 24, spreadRadius: 4),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.file_download_outlined, size: 48, color: theme.primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    'Drop .vct to open  ·  .svg to import  ·  image to raster layer',
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.textPrimary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
