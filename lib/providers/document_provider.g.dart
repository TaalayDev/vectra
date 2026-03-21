// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentMetaHash() => r'848168fa4c8b0e2d610198527630ccc3c11956de';

/// See also [currentMeta].
@ProviderFor(currentMeta)
final currentMetaProvider = AutoDisposeProvider<VecMeta>.internal(
  currentMeta,
  name: r'currentMetaProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentMetaHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentMetaRef = AutoDisposeProviderRef<VecMeta>;
String _$scenesHash() => r'2431520f5ffd7303386e67478b55cc55e5fcdead';

/// See also [scenes].
@ProviderFor(scenes)
final scenesProvider = AutoDisposeProvider<List<VecScene>>.internal(
  scenes,
  name: r'scenesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scenesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScenesRef = AutoDisposeProviderRef<List<VecScene>>;
String _$symbolLibraryHash() => r'c5c12472395de0f3f1290dcbf35f6683feb076f1';

/// See also [symbolLibrary].
@ProviderFor(symbolLibrary)
final symbolLibraryProvider = AutoDisposeProvider<List<VecSymbol>>.internal(
  symbolLibrary,
  name: r'symbolLibraryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$symbolLibraryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SymbolLibraryRef = AutoDisposeProviderRef<List<VecSymbol>>;
String _$vecDocumentStateHash() => r'3f051c858854cfe15d4a0a8bab5f62f164ca1919';

/// See also [VecDocumentState].
@ProviderFor(VecDocumentState)
final vecDocumentStateProvider =
    NotifierProvider<VecDocumentState, VecDocument>.internal(
      VecDocumentState.new,
      name: r'vecDocumentStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$vecDocumentStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VecDocumentState = Notifier<VecDocument>;
String _$activeSceneIndexHash() => r'3d2746efc1a6597bcee47a88dcc19e3de42da622';

/// See also [ActiveSceneIndex].
@ProviderFor(ActiveSceneIndex)
final activeSceneIndexProvider =
    AutoDisposeNotifierProvider<ActiveSceneIndex, int>.internal(
      ActiveSceneIndex.new,
      name: r'activeSceneIndexProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeSceneIndexHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveSceneIndex = AutoDisposeNotifier<int>;
String _$activeLayerIdHash() => r'cb8ad95189d1b56383ea1587b2c80f5cb89133a0';

/// See also [ActiveLayerId].
@ProviderFor(ActiveLayerId)
final activeLayerIdProvider =
    AutoDisposeNotifierProvider<ActiveLayerId, String?>.internal(
      ActiveLayerId.new,
      name: r'activeLayerIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeLayerIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveLayerId = AutoDisposeNotifier<String?>;
String _$playheadFrameHash() => r'632d940a962bc2abcdeb32accd8af36ba0221a8b';

/// See also [PlayheadFrame].
@ProviderFor(PlayheadFrame)
final playheadFrameProvider =
    AutoDisposeNotifierProvider<PlayheadFrame, int>.internal(
      PlayheadFrame.new,
      name: r'playheadFrameProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$playheadFrameHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlayheadFrame = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
