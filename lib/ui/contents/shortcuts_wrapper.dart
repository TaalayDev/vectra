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
  bool _isPipettePressed = false;

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

  /// Returns true when a text-editing widget (TextField, TextFormField, etc.)
  /// currently owns keyboard focus.
  bool get _isTextFieldFocused {
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null || primary.context == null) return false;
    bool found = false;
    primary.context!.visitAncestorElements((element) {
      if (element.widget is EditableText) {
        found = true;
        return false; // stop visiting
      }
      return true;
    });
    return found;
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
        // Delay focus reclaim so child widgets (TextFields) that also
        // process this tap can request focus first.  If a text-editing
        // widget ends up focused, don't steal it.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_isTextFieldFocused) return;
          if (!_focusNode.hasFocus && _focusNode.canRequestFocus) {
            _focusNode.requestFocus();
          }
        });
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
              // Don't handle shortcuts while a text field is focused —
              // key events only arrive here via focus-tree bubbling.
              if (_isTextFieldFocused) return KeyEventResult.ignored;
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
    // Always handle space (pan) and alt (pipette) — they need key-up tracking
    // and don't conflict with text input.
    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (event is KeyDownEvent && !_isSpacePressed) {
        _isSpacePressed = true;
        widget.onPanStart?.call();
      } else if (event is KeyUpEvent && _isSpacePressed) {
        _isSpacePressed = false;
        widget.onPanEnd?.call();
      }
    }
    // 'I' key — toggle eyedropper / pipette mode (press to enter, press again to exit)
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyI) {
      if (!_isPipettePressed) {
        _isPipettePressed = true;
        widget.onPipetteStart?.call();
      } else {
        _isPipettePressed = false;
        widget.onPipetteEnd?.call();
      }
    }

    // Skip all remaining shortcuts while a text field is focused — they would
    // steal characters / trigger actions instead of typing.
    if (_isTextFieldFocused) return;

    // Escape
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onEscape?.call();
    }

    // '?' — help sheet
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.slash &&
        HardwareKeyboard.instance.isShiftPressed &&
        !HardwareKeyboard.instance.isControlPressed &&
        !HardwareKeyboard.instance.isMetaPressed) {
      widget.onHelpSheet?.call();
      return;
    }

    // Enter (without modifiers)
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      if (!HardwareKeyboard.instance.isControlPressed && !HardwareKeyboard.instance.isMetaPressed) {
        widget.onEnter?.call();
      }
    }

    // -----------------------------------------------------------------------
    // Bare-key shortcuts (no modifier).
    // These MUST live here (not in _buildShortcuts) because the Shortcuts
    // widget returns KeyEventResult.handled which tells the platform the
    // key was consumed — blocking character insertion in TextFields.
    // -----------------------------------------------------------------------
    if (event is KeyDownEvent &&
        !HardwareKeyboard.instance.isControlPressed &&
        !HardwareKeyboard.instance.isMetaPressed &&
        !HardwareKeyboard.instance.isShiftPressed) {
      // Tool switch keys
      final toolKeys = {
        LogicalKeyboardKey.keyV,
        LogicalKeyboardKey.keyP,
        LogicalKeyboardKey.keyL,
        LogicalKeyboardKey.keyR,
        LogicalKeyboardKey.keyE,
        LogicalKeyboardKey.keyT,
        LogicalKeyboardKey.keyU,
      };
      if (toolKeys.contains(event.logicalKey)) {
        widget.onToolSwitch?.call(event.logicalKey.keyLabel);
        return;
      }

      // Color shortcuts
      if (event.logicalKey == LogicalKeyboardKey.keyX) { widget.onSwapColors?.call(); return; }
      if (event.logicalKey == LogicalKeyboardKey.keyD) { widget.onDefaultColors?.call(); return; }
      if (event.logicalKey == LogicalKeyboardKey.keyC) { widget.onColorPicker?.call(); return; }

      // Zoom
      if (event.logicalKey == LogicalKeyboardKey.equal) { widget.onZoomIn?.call(); return; }
      if (event.logicalKey == LogicalKeyboardKey.minus) { widget.onZoomOut?.call(); return; }

      // Tab — toggle UI
      if (event.logicalKey == LogicalKeyboardKey.tab) { widget.onToggleUI?.call(); return; }

      // Delete — delete layer / selection
      if (event.logicalKey == LogicalKeyboardKey.delete ||
          event.logicalKey == LogicalKeyboardKey.backspace) {
        widget.onDeleteLayer?.call();
        return;
      }

      // Digit keys: 0 = zoom fit, 1 = zoom 100% / layer 0, 2-9 = layers
      if (event.logicalKey == LogicalKeyboardKey.digit0) { widget.onZoomFit?.call(); return; }
      if (event.logicalKey == LogicalKeyboardKey.digit1) { widget.onZoom100?.call(); return; }
      final digitKeys = {
        LogicalKeyboardKey.digit1: 0, LogicalKeyboardKey.digit2: 1,
        LogicalKeyboardKey.digit3: 2, LogicalKeyboardKey.digit4: 3,
        LogicalKeyboardKey.digit5: 4, LogicalKeyboardKey.digit6: 5,
        LogicalKeyboardKey.digit7: 6, LogicalKeyboardKey.digit8: 7,
        LogicalKeyboardKey.digit9: 8,
      };
      final layerIdx = digitKeys[event.logicalKey];
      if (layerIdx != null && layerIdx < widget.maxLayers) {
        widget.onLayerChanged?.call(layerIdx);
        return;
      }
    }

    // Arrow keys — nudge (no Ctrl/Meta required, Shift = 10px step)
    if ((event is KeyDownEvent || event is KeyRepeatEvent) &&
        !HardwareKeyboard.instance.isControlPressed &&
        !HardwareKeyboard.instance.isMetaPressed) {
      final shift = HardwareKeyboard.instance.isShiftPressed;
      final step = shift ? 10.0 : 1.0;
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) { widget.onNudge?.call(-step, 0); return; }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) { widget.onNudge?.call(step, 0); return; }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) { widget.onNudge?.call(0, -step); return; }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) { widget.onNudge?.call(0, step); return; }
    }
  }

  /// Only modifier-based shortcuts belong here. The Shortcuts widget returns
  /// `KeyEventResult.handled` for matches, which tells the platform the key
  /// was consumed — this blocks character insertion in TextFields. All
  /// bare-key shortcuts (no modifier) are handled in `_handleKeyEvent`
  /// instead, which always returns `KeyEventResult.ignored`.
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
      LogicalKeySet(controlKey, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyF): const ZoomSelectionIntent(),

      // Layer management
      LogicalKeySet(controlKey, LogicalKeyboardKey.keyN): const NewLayerIntent(),

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
      // Only actions triggered by modifier-key Shortcuts belong here.
      // Bare-key actions are dispatched directly from _handleKeyEvent.
      UndoIntent: CallbackAction<UndoIntent>(onInvoke: (intent) => widget.onUndo()),
      RedoIntent: CallbackAction<RedoIntent>(onInvoke: (intent) => widget.onRedo()),
      SaveIntent: CallbackAction<SaveIntent>(onInvoke: (intent) => widget.onSave()),
      SaveAsIntent: CallbackAction<SaveAsIntent>(onInvoke: (intent) => widget.onSaveAs?.call()),
      ExportIntent: CallbackAction<ExportIntent>(onInvoke: (intent) => widget.onExport?.call()),
      ImportIntent: CallbackAction<ImportIntent>(onInvoke: (intent) => widget.onImport?.call()),
      ZoomSelectionIntent: CallbackAction<ZoomSelectionIntent>(onInvoke: (intent) => widget.onZoomSelection?.call()),
      NewLayerIntent: CallbackAction<NewLayerIntent>(onInvoke: (intent) => widget.onNewLayer?.call()),
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
