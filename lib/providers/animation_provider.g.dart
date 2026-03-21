// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$playbackTickerHash() => r'50203d290f20a81fe4cfc75a5df74538268607ba';

/// Void provider that drives [PlayheadFrame] forward at the current fps.
/// Rebuilds (and restarts the timer) whenever [isPlayingProvider] or fps changes.
/// Watch this once in a long-lived widget so the timer is always running.
///
/// Copied from [playbackTicker].
@ProviderFor(playbackTicker)
final playbackTickerProvider = Provider<void>.internal(
  playbackTicker,
  name: r'playbackTickerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$playbackTickerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlaybackTickerRef = ProviderRef<void>;
String _$animatedSceneHash() => r'c64dd6de273dccfb866d5c6e10fe920f6d2dc02b';

/// Returns a version of [activeSceneProvider] with shape transforms/opacities/
/// fills/strokes interpolated to the current [PlayheadFrame].
///
/// Shapes that have no shape-level track are returned unchanged.
///
/// Copied from [animatedScene].
@ProviderFor(animatedScene)
final animatedSceneProvider = AutoDisposeProvider<VecScene?>.internal(
  animatedScene,
  name: r'animatedSceneProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$animatedSceneHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnimatedSceneRef = AutoDisposeProviderRef<VecScene?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
