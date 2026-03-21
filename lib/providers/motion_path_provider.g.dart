// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'motion_path_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeSceneMotionPathsHash() =>
    r'21e4f9226b8d171c1d2ed64205381cee5ef47f44';

/// See also [activeSceneMotionPaths].
@ProviderFor(activeSceneMotionPaths)
final activeSceneMotionPathsProvider =
    AutoDisposeProvider<List<VecMotionPath>>.internal(
      activeSceneMotionPaths,
      name: r'activeSceneMotionPathsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeSceneMotionPathsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveSceneMotionPathsRef = AutoDisposeProviderRef<List<VecMotionPath>>;
String _$selectedShapeMotionPathHash() =>
    r'61fa7c72da2a9b97494f094aae08098f66fe1702';

/// Returns the motion path for the currently selected shape, or null.
///
/// Copied from [selectedShapeMotionPath].
@ProviderFor(selectedShapeMotionPath)
final selectedShapeMotionPathProvider =
    AutoDisposeProvider<VecMotionPath?>.internal(
      selectedShapeMotionPath,
      name: r'selectedShapeMotionPathProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedShapeMotionPathHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedShapeMotionPathRef = AutoDisposeProviderRef<VecMotionPath?>;
String _$motionPathDrawTargetHash() =>
    r'7e77b66ee0464dd2d6a25b2b1c3df94692bcea3a';

/// When non-null, the user is in motion-path drawing mode for this shapeId.
///
/// Copied from [MotionPathDrawTarget].
@ProviderFor(MotionPathDrawTarget)
final motionPathDrawTargetProvider =
    AutoDisposeNotifierProvider<MotionPathDrawTarget, String?>.internal(
      MotionPathDrawTarget.new,
      name: r'motionPathDrawTargetProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$motionPathDrawTargetHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MotionPathDrawTarget = AutoDisposeNotifier<String?>;
String _$motionPathPreviewNodesHash() =>
    r'3d07f49caa456156cd58eb06add3d6979417869f';

/// Live preview nodes accumulated while the user clicks during drawing mode.
///
/// Copied from [MotionPathPreviewNodes].
@ProviderFor(MotionPathPreviewNodes)
final motionPathPreviewNodesProvider =
    AutoDisposeNotifierProvider<
      MotionPathPreviewNodes,
      List<VecPathNode>
    >.internal(
      MotionPathPreviewNodes.new,
      name: r'motionPathPreviewNodesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$motionPathPreviewNodesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MotionPathPreviewNodes = AutoDisposeNotifier<List<VecPathNode>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
