import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShortcutsWrapper extends StatefulWidget {
  const ShortcutsWrapper({
    super.key,
    required this.child,
    required this.onUndo,
    required this.onRedo,
    required this.onSave,
    this.onSaveAs,
    this.onZoomIn,
    this.onZoomOut,
    this.onZoomFit,
    this.onZoomSelection,
    this.onZoom100,
    this.onSwapColors,
    this.onDefaultColors,
    this.onToggleUI,
    this.onPanStart,
    this.onPanEnd,
    this.onPipetteStart,
    this.onPipetteEnd,
    this.onLayerChanged,
    this.onColorPicker,
    this.onNewLayer,
    this.onDeleteLayer,
    this.onExport,
    this.onImport,
    this.onSelectAll,
    this.onDeselectAll,
    this.onCopy,
    this.onPaste,
    this.onPasteInPlace,
    this.onCut,
    this.onDuplicate,
    this.onGroup,
    this.onUngroup,
    this.onBringForward,
    this.onSendBackward,
    this.onBringToFront,
    this.onSendToBack,
    this.onCtrlEnter,
    this.onEscape,
    this.onEnter,
    this.onHelpSheet,
    this.onToolSwitch,
    this.onNudge,
    this.currentBrushSize = 1,
    this.maxBrushSize = 10,
    this.maxLayers = 10,
    this.focusNode,
  });

  final Widget child;

  // Basic actions
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onSave;
  final VoidCallback? onSaveAs;

  // View actions
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onZoomFit;
  final VoidCallback? onZoomSelection;
  final VoidCallback? onZoom100;

  // Color actions
  final VoidCallback? onSwapColors;
  final VoidCallback? onDefaultColors;
  final VoidCallback? onColorPicker;

  // UI actions
  final VoidCallback? onToggleUI;
  final VoidCallback? onPanStart;
  final VoidCallback? onPanEnd;
  final VoidCallback? onPipetteStart;
  final VoidCallback? onPipetteEnd;

  // Layer actions
  final Function(int)? onLayerChanged;
  final VoidCallback? onNewLayer;
  final VoidCallback? onDeleteLayer;

  // File actions
  final VoidCallback? onExport;
  final VoidCallback? onImport;

  // Selection actions
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;
  final VoidCallback? onCopy;
  final VoidCallback? onPaste;
  final VoidCallback? onPasteInPlace;
  final VoidCallback? onCut;
  final VoidCallback? onDuplicate;
  final VoidCallback? onGroup;
  final VoidCallback? onUngroup;
  // Z-order actions
  final VoidCallback? onBringForward;
  final VoidCallback? onSendBackward;
  final VoidCallback? onBringToFront;
  final VoidCallback? onSendToBack;
  final VoidCallback? onCtrlEnter;
  final VoidCallback? onEscape;
  final VoidCallback? onEnter;
  final VoidCallback? onHelpSheet;
  final void Function(String key)? onToolSwitch;

  /// Called when Arrow keys are pressed while the select tool is active.
  /// [dx] and [dy] are the pixel offset to apply (1 or 10 px).
  final void Function(double dx, double dy)? onNudge;

  // State
  final int currentBrushSize;
  final int maxBrushSize;
  final int maxLayers;
  final FocusNode? focusNode;

  @override
  State<ShortcutsWrapper> createState() => _ShortcutsWrapperState();
}

class _ShortcutsWrapperState extends State<ShortcutsWrapper> {
  late FocusNode _focusNode;
  bool _isSpacePressed = false;
  bool _isAltPressed = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();

    // Auto-focus when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  bool get isDesktopOrWeb {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  LogicalKeyboardKey get controlKey {
    return defaultTargetPlatform == TargetPlatform.macOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control;
  }

  @override
  Widget build(BuildContext context) {
    if (!isDesktopOrWeb) {
      return widget.child;
    }

    return GestureDetector(
      onTap: () {
        if (!_focusNode.hasFocus && _focusNode.canRequestFocus) {
          _focusNode.requestFocus();
        }
      },
      child: Shortcuts(
        shortcuts: _buildShortcuts(),
        child: Actions(
          actions: _buildActions(),
          child: Focus(
            focusNode: _focusNode,
            autofocus: true,
            canRequestFocus: true,
            skipTraversal: false,
            onKeyEvent: (_, event) {
              _handleKeyEvent(event);
              return KeyEventResult.ignored;
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    // Handle spacebar for temporary pan mode
    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (event is KeyDownEvent && !_isSpacePressed) {
        _isSpacePressed = true;
        widget.onPanStart?.call();
      } else if (event is KeyUpEvent && _isSpacePressed) {
        _isSpacePressed = false;
        widget.onPanEnd?.call();
      }
    }

    // Handle Escape key
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onEscape?.call();
    }

    // Handle '?' key — open keyboard shortcut help sheet
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.slash &&
        HardwareKeyboard.instance.isShiftPressed &&
        !HardwareKeyboard.instance.isControlPressed &&
        !HardwareKeyboard.instance.isMetaPressed) {
      widget.onHelpSheet?.call();
      return;
    }

    // Handle Enter key (without modifiers — Ctrl+Enter is in shortcuts map)
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      if (!HardwareKeyboard.instance.isControlPressed && !HardwareKeyboard.instance.isMetaPressed) {
        widget.onEnter?.call();
      }
    }

    // Handle tool switch keys (V, P, R, E, T) — only when no modifier is held
    if (event is KeyDownEvent &&
        !HardwareKeyboard.instance.isControlPressed &&
        !HardwareKeyboard.instance.isMetaPressed &&
        !HardwareKeyboard.instance.isShiftPressed) {
      final toolKeys = {
        LogicalKeyboardKey.keyV,
        LogicalKeyboardKey.keyP,
        LogicalKeyboardKey.keyL,
        LogicalKeyboardKey.keyR,
        LogicalKeyboardKey.keyE,
        LogicalKeyboardKey.keyT,
      };
      if (toolKeys.contains(event.logicalKey)) {
        widget.onToolSwitch?.call(event.logicalKey.keyLabel);
      }
    }

    // Handle Arrow keys for nudging selected shapes
    if ((event is KeyDownEvent || event is KeyRepeatEvent) &&
        !HardwareKeyboard.instance.isControlPressed &&
        !HardwareKeyboard.instance.isMetaPressed) {
      final shift = HardwareKeyboard.instance.isShiftPressed;
      final step = shift ? 10.0 : 1.0;
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        widget.onNudge?.call(-step, 0);
        return;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        widget.onNudge?.call(step, 0);
        return;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        widget.onNudge?.call(0, -step);
        return;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        widget.onNudge?.call(0, step);
        return;
      }
    }

    // Handle Alt key for temporary pipette/eyedropper mode
    if (event.logicalKey == LogicalKeyboardKey.altLeft || event.logicalKey == LogicalKeyboardKey.altRight) {
      if (event is KeyDownEvent && !_isAltPressed) {
        _isAltPressed = true;
        widget.onPipetteStart?.call();
      } else if (event is KeyUpEvent && _isAltPressed) {
        _isAltPressed = false;
        widget.onPipetteEnd?.call();
      }
    }
  }

  Map<LogicalKeySet, Intent> _buildShortcuts() {
    return {
      // Basic editing
      LogicalKeySet(controlKey, LogicalKeyboardKey.keyZ): const UndoIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.keyY): const RedoIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyZ): const RedoIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.keyS): const SaveIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyS): const SaveAsIntent(),

      // File operations
      LogicalKeySet(controlKey, LogicalKeyboardKey.keyE): const ExportIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.keyO): const ImportIntent(),

      // Zoom
      LogicalKeySet(LogicalKeyboardKey.equal): const ZoomInIntent(),
      LogicalKeySet(LogicalKeyboardKey.minus): const ZoomOutIntent(),
      LogicalKeySet(LogicalKeyboardKey.digit0): const ZoomFitIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyF): const ZoomSelectionIntent(),
      LogicalKeySet(LogicalKeyboardKey.digit1): const Zoom100Intent(),

      // Colors
      LogicalKeySet(LogicalKeyboardKey.keyX): const SwapColorsIntent(),
      LogicalKeySet(LogicalKeyboardKey.keyD): const DefaultColorsIntent(),
      LogicalKeySet(LogicalKeyboardKey.keyC): const ColorPickerIntent(),

      // UI
      LogicalKeySet(LogicalKeyboardKey.tab): const ToggleUIIntent(),
      // Note: Space is handled directly in _handleKeyEvent for key up support

      // Layers (1-9)
      LogicalKeySet(LogicalKeyboardKey.digit1): const LayerIntent(0),
      LogicalKeySet(LogicalKeyboardKey.digit2): const LayerIntent(1),
      LogicalKeySet(LogicalKeyboardKey.digit3): const LayerIntent(2),
      LogicalKeySet(LogicalKeyboardKey.digit4): const LayerIntent(3),
      LogicalKeySet(LogicalKeyboardKey.digit5): const LayerIntent(4),
      LogicalKeySet(LogicalKeyboardKey.digit6): const LayerIntent(5),
      LogicalKeySet(LogicalKeyboardKey.digit7): const LayerIntent(6),
      LogicalKeySet(LogicalKeyboardKey.digit8): const LayerIntent(7),
      LogicalKeySet(LogicalKeyboardKey.digit9): const LayerIntent(8),

      // Layer management
      LogicalKeySet(controlKey, LogicalKeyboardKey.keyN): const NewLayerIntent(),
      LogicalKeySet(LogicalKeyboardKey.delete): const DeleteLayerIntent(),

      // Selection
      LogicalKeySet(controlKey, LogicalKeyboardKey.keyA): const SelectAllIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.keyD): const DeselectAllIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.keyC): const CopyIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.keyV): const PasteIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyV): const PasteInPlaceIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.keyX): const CutIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.keyJ): const DuplicateIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.keyG): const GroupIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyG): const UngroupIntent(),
      // Z-order
      LogicalKeySet(controlKey, LogicalKeyboardKey.bracketRight): const BringForwardIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.bracketLeft): const SendBackwardIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.shift, LogicalKeyboardKey.bracketRight): const BringToFrontIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.shift, LogicalKeyboardKey.bracketLeft): const SendToBackIntent(),
      LogicalKeySet(controlKey, LogicalKeyboardKey.enter): CallbackIntent(widget.onCtrlEnter ?? () {}),
    };
  }

  Map<Type, Action<Intent>> _buildActions() {
    return {
      UndoIntent: CallbackAction<UndoIntent>(onInvoke: (intent) => widget.onUndo()),
      RedoIntent: CallbackAction<RedoIntent>(onInvoke: (intent) => widget.onRedo()),
      SaveIntent: CallbackAction<SaveIntent>(onInvoke: (intent) => widget.onSave()),
      SaveAsIntent: CallbackAction<SaveAsIntent>(onInvoke: (intent) => widget.onSaveAs?.call()),
      ExportIntent: CallbackAction<ExportIntent>(onInvoke: (intent) => widget.onExport?.call()),
      ImportIntent: CallbackAction<ImportIntent>(onInvoke: (intent) => widget.onImport?.call()),
      ZoomInIntent: CallbackAction<ZoomInIntent>(onInvoke: (intent) => widget.onZoomIn?.call()),
      ZoomOutIntent: CallbackAction<ZoomOutIntent>(onInvoke: (intent) => widget.onZoomOut?.call()),
      ZoomFitIntent: CallbackAction<ZoomFitIntent>(onInvoke: (intent) => widget.onZoomFit?.call()),
      ZoomSelectionIntent: CallbackAction<ZoomSelectionIntent>(onInvoke: (intent) => widget.onZoomSelection?.call()),
      Zoom100Intent: CallbackAction<Zoom100Intent>(onInvoke: (intent) => widget.onZoom100?.call()),
      SwapColorsIntent: CallbackAction<SwapColorsIntent>(onInvoke: (intent) => widget.onSwapColors?.call()),
      DefaultColorsIntent: CallbackAction<DefaultColorsIntent>(onInvoke: (intent) => widget.onDefaultColors?.call()),
      ColorPickerIntent: CallbackAction<ColorPickerIntent>(onInvoke: (intent) => widget.onColorPicker?.call()),
      ToggleUIIntent: CallbackAction<ToggleUIIntent>(onInvoke: (intent) => widget.onToggleUI?.call()),
      PanStartIntent: CallbackAction<PanStartIntent>(
        onInvoke: (intent) {
          if (!_isSpacePressed) {
            _isSpacePressed = true;
            widget.onPanStart?.call();
          }
          return null;
        },
      ),
      LayerIntent: CallbackAction<LayerIntent>(
        onInvoke: (intent) {
          if (intent.layerIndex < widget.maxLayers) {
            widget.onLayerChanged?.call(intent.layerIndex);
          }
          return null;
        },
      ),
      NewLayerIntent: CallbackAction<NewLayerIntent>(onInvoke: (intent) => widget.onNewLayer?.call()),
      DeleteLayerIntent: CallbackAction<DeleteLayerIntent>(onInvoke: (intent) => widget.onDeleteLayer?.call()),
      SelectAllIntent: CallbackAction<SelectAllIntent>(onInvoke: (intent) => widget.onSelectAll?.call()),
      DeselectAllIntent: CallbackAction<DeselectAllIntent>(onInvoke: (intent) => widget.onDeselectAll?.call()),
      CopyIntent: CallbackAction<CopyIntent>(onInvoke: (intent) => widget.onCopy?.call()),
      PasteIntent: CallbackAction<PasteIntent>(onInvoke: (intent) => widget.onPaste?.call()),
      PasteInPlaceIntent: CallbackAction<PasteInPlaceIntent>(onInvoke: (intent) => widget.onPasteInPlace?.call()),
      CutIntent: CallbackAction<CutIntent>(onInvoke: (intent) => widget.onCut?.call()),
      DuplicateIntent: CallbackAction<DuplicateIntent>(onInvoke: (intent) => widget.onDuplicate?.call()),
      GroupIntent: CallbackAction<GroupIntent>(onInvoke: (intent) => widget.onGroup?.call()),
      UngroupIntent: CallbackAction<UngroupIntent>(onInvoke: (intent) => widget.onUngroup?.call()),
      BringForwardIntent: CallbackAction<BringForwardIntent>(onInvoke: (_) => widget.onBringForward?.call()),
      SendBackwardIntent: CallbackAction<SendBackwardIntent>(onInvoke: (_) => widget.onSendBackward?.call()),
      BringToFrontIntent: CallbackAction<BringToFrontIntent>(onInvoke: (_) => widget.onBringToFront?.call()),
      SendToBackIntent: CallbackAction<SendToBackIntent>(onInvoke: (_) => widget.onSendToBack?.call()),
      CallbackIntent: CallbackAction<CallbackIntent>(onInvoke: (intent) => intent.callback()),
    };
  }
}

// Intents
class UndoIntent extends Intent {
  const UndoIntent();
}

class RedoIntent extends Intent {
  const RedoIntent();
}

class SaveIntent extends Intent {
  const SaveIntent();
}

class SaveAsIntent extends Intent {
  const SaveAsIntent();
}

class BringForwardIntent extends Intent {
  const BringForwardIntent();
}

class SendBackwardIntent extends Intent {
  const SendBackwardIntent();
}

class BringToFrontIntent extends Intent {
  const BringToFrontIntent();
}

class SendToBackIntent extends Intent {
  const SendToBackIntent();
}

class ExportIntent extends Intent {
  const ExportIntent();
}

class ImportIntent extends Intent {
  const ImportIntent();
}

class ZoomInIntent extends Intent {
  const ZoomInIntent();
}

class ZoomOutIntent extends Intent {
  const ZoomOutIntent();
}

class ZoomFitIntent extends Intent {
  const ZoomFitIntent();
}

class Zoom100Intent extends Intent {
  const Zoom100Intent();
}

class ZoomSelectionIntent extends Intent {
  const ZoomSelectionIntent();
}

class SwapColorsIntent extends Intent {
  const SwapColorsIntent();
}

class DefaultColorsIntent extends Intent {
  const DefaultColorsIntent();
}

class ColorPickerIntent extends Intent {
  const ColorPickerIntent();
}

class ToggleUIIntent extends Intent {
  const ToggleUIIntent();
}

class PanStartIntent extends Intent {
  const PanStartIntent();
}

class LayerIntent extends Intent {
  const LayerIntent(this.layerIndex);
  final int layerIndex;
}

class NewLayerIntent extends Intent {
  const NewLayerIntent();
}

class DeleteLayerIntent extends Intent {
  const DeleteLayerIntent();
}

class SelectAllIntent extends Intent {
  const SelectAllIntent();
}

class DeselectAllIntent extends Intent {
  const DeselectAllIntent();
}

class CopyIntent extends Intent {
  const CopyIntent();
}

class PasteIntent extends Intent {
  const PasteIntent();
}

class PasteInPlaceIntent extends Intent {
  const PasteInPlaceIntent();
}

class CutIntent extends Intent {
  const CutIntent();
}

class DuplicateIntent extends Intent {
  const DuplicateIntent();
}

class GroupIntent extends Intent {
  const GroupIntent();
}

class UngroupIntent extends Intent {
  const UngroupIntent();
}

class CallbackIntent extends Intent {
  final VoidCallback callback;

  const CallbackIntent(this.callback);
}
