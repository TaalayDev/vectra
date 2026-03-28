// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeSceneHash() => r'6d8158ce6746841e6c9a7a7786be65840e20b2f9';

/// See also [activeScene].
@ProviderFor(activeScene)
final activeSceneProvider = AutoDisposeProvider<VecScene?>.internal(
  activeScene,
  name: r'activeSceneProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeSceneHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveSceneRef = AutoDisposeProviderRef<VecScene?>;
String _$activeLayerHash() => r'154d729570e65b4e00b8161504ecda82eb170ccc';

/// See also [activeLayer].
@ProviderFor(activeLayer)
final activeLayerProvider = AutoDisposeProvider<VecLayer?>.internal(
  activeLayer,
  name: r'activeLayerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeLayerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveLayerRef = AutoDisposeProviderRef<VecLayer?>;
String _$selectedShapeHash() => r'e02c070e4403461874c11711b8e8f2031c689e43';

/// See also [selectedShape].
@ProviderFor(selectedShape)
final selectedShapeProvider = AutoDisposeProvider<VecShape?>.internal(
  selectedShape,
  name: r'selectedShapeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedShapeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedShapeRef = AutoDisposeProviderRef<VecShape?>;
String _$activeToolHash() => r'a291a86ebb8bc48b7806828ce4f5c8efddc0c8fb';

/// See also [ActiveTool].
@ProviderFor(ActiveTool)
final activeToolProvider =
    AutoDisposeNotifierProvider<ActiveTool, VecTool>.internal(
      ActiveTool.new,
      name: r'activeToolProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeToolHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveTool = AutoDisposeNotifier<VecTool>;
String _$zoomLevelHash() => r'841cf64d5796ef948f42730a29bbe697b3eeeae4';

/// See also [ZoomLevel].
@ProviderFor(ZoomLevel)
final zoomLevelProvider =
    AutoDisposeNotifierProvider<ZoomLevel, double>.internal(
      ZoomLevel.new,
      name: r'zoomLevelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$zoomLevelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ZoomLevel = AutoDisposeNotifier<double>;
String _$undoAvailabilityHash() => r'f6e1d7f6aa75f3f5a877d00909343f23da1b08b8';

/// Undo / redo availability flags — updated by VecDocumentState after every commit.
///
/// Copied from [UndoAvailability].
@ProviderFor(UndoAvailability)
final undoAvailabilityProvider =
    NotifierProvider<UndoAvailability, ({bool canUndo, bool canRedo})>.internal(
      UndoAvailability.new,
      name: r'undoAvailabilityProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$undoAvailabilityHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UndoAvailability = Notifier<({bool canUndo, bool canRedo})>;
String _$fitRequestHash() => r'a19e16965a48446f29f546408259ce3898a82b12';

/// Incremented to request a zoom-to-fit from the canvas.
///
/// Copied from [FitRequest].
@ProviderFor(FitRequest)
final fitRequestProvider =
    AutoDisposeNotifierProvider<FitRequest, int>.internal(
      FitRequest.new,
      name: r'fitRequestProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fitRequestHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FitRequest = AutoDisposeNotifier<int>;
String _$canvasOffsetHash() => r'31543d2c9b634e6d285dbea093d98da0ff55111c';

/// See also [CanvasOffset].
@ProviderFor(CanvasOffset)
final canvasOffsetProvider =
    AutoDisposeNotifierProvider<CanvasOffset, Offset>.internal(
      CanvasOffset.new,
      name: r'canvasOffsetProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$canvasOffsetHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CanvasOffset = AutoDisposeNotifier<Offset>;
String _$cursorPositionHash() => r'e77b01083c7d5cebe6e03910d94d5bdab3f07d9d';

/// See also [CursorPosition].
@ProviderFor(CursorPosition)
final cursorPositionProvider =
    AutoDisposeNotifierProvider<CursorPosition, Offset>.internal(
      CursorPosition.new,
      name: r'cursorPositionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cursorPositionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CursorPosition = AutoDisposeNotifier<Offset>;
String _$panelVisibilityHash() => r'0a8bea0b47db0ddccf39fec2689e2bd404de847a';

/// See also [PanelVisibility].
@ProviderFor(PanelVisibility)
final panelVisibilityProvider =
    AutoDisposeNotifierProvider<
      PanelVisibility,
      ({bool layers, bool properties, bool timeline})
    >.internal(
      PanelVisibility.new,
      name: r'panelVisibilityProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$panelVisibilityHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PanelVisibility =
    AutoDisposeNotifier<({bool layers, bool properties, bool timeline})>;
String _$timelineHeightHash() => r'4a67843ba1d11ceb433ef959a02b0cd27a9afe56';

/// See also [TimelineHeight].
@ProviderFor(TimelineHeight)
final timelineHeightProvider =
    AutoDisposeNotifierProvider<TimelineHeight, double>.internal(
      TimelineHeight.new,
      name: r'timelineHeightProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$timelineHeightHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TimelineHeight = AutoDisposeNotifier<double>;
String _$selectedShapeIdHash() => r'407eb50eff395244e084017de7408ff2d26bdc80';

/// See also [SelectedShapeId].
@ProviderFor(SelectedShapeId)
final selectedShapeIdProvider =
    AutoDisposeNotifierProvider<SelectedShapeId, String?>.internal(
      SelectedShapeId.new,
      name: r'selectedShapeIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedShapeIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedShapeId = AutoDisposeNotifier<String?>;
String _$selectedShapeIdsHash() => r'893d0fde58f58cdfb1efc9c56db1785831abdf3a';

/// Multi-selection: ordered list of selected shape IDs.
/// The last entry is considered the "primary" selected shape for the
/// Properties Panel. Kept in sync with [SelectedShapeId] by the canvas.
///
/// Copied from [SelectedShapeIds].
@ProviderFor(SelectedShapeIds)
final selectedShapeIdsProvider =
    AutoDisposeNotifierProvider<SelectedShapeIds, List<String>>.internal(
      SelectedShapeIds.new,
      name: r'selectedShapeIdsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedShapeIdsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedShapeIds = AutoDisposeNotifier<List<String>>;
String _$isPlayingHash() => r'3f76a99475e2acd6f86181558f9645b2762950f4';

/// See also [IsPlaying].
@ProviderFor(IsPlaying)
final isPlayingProvider = AutoDisposeNotifierProvider<IsPlaying, bool>.internal(
  IsPlaying.new,
  name: r'isPlayingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isPlayingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$IsPlaying = AutoDisposeNotifier<bool>;
String _$activeGroupIdHash() => r'7ab40fa79d27f7c9ba489e4b4ad01ff57a076aaf';

/// The ID of the group shape currently being edited in isolate mode.
/// Null when not in group-edit mode.
///
/// Copied from [ActiveGroupId].
@ProviderFor(ActiveGroupId)
final activeGroupIdProvider =
    AutoDisposeNotifierProvider<ActiveGroupId, String?>.internal(
      ActiveGroupId.new,
      name: r'activeGroupIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeGroupIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveGroupId = AutoDisposeNotifier<String?>;
String _$editingSymbolIdHash() => r'47720bb1666848baee826dd21c9de2dba6cd8fc9';

/// The ID of the symbol currently being edited in Symbol Edit Mode.
/// Null when not editing a symbol master.
///
/// Copied from [EditingSymbolId].
@ProviderFor(EditingSymbolId)
final editingSymbolIdProvider =
    AutoDisposeNotifierProvider<EditingSymbolId, String?>.internal(
      EditingSymbolId.new,
      name: r'editingSymbolIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$editingSymbolIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EditingSymbolId = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
