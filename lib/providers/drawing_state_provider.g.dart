// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeDrawingHash() => r'a4b912386d70dd990bd507d5eddefd784f8c6643';

/// See also [ActiveDrawing].
@ProviderFor(ActiveDrawing)
final activeDrawingProvider =
    AutoDisposeNotifierProvider<ActiveDrawing, DrawingState?>.internal(
      ActiveDrawing.new,
      name: r'activeDrawingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeDrawingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveDrawing = AutoDisposeNotifier<DrawingState?>;
String _$activePenDrawingHash() => r'2a6e9bd7def24e96dcc69828fd5794b702f4d221';

/// See also [ActivePenDrawing].
@ProviderFor(ActivePenDrawing)
final activePenDrawingProvider =
    AutoDisposeNotifierProvider<ActivePenDrawing, PenDrawingState?>.internal(
      ActivePenDrawing.new,
      name: r'activePenDrawingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activePenDrawingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActivePenDrawing = AutoDisposeNotifier<PenDrawingState?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
