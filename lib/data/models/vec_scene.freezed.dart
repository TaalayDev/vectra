// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_scene.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecScene _$VecSceneFromJson(Map<String, dynamic> json) {
  return _VecScene.fromJson(json);
}

/// @nodoc
mixin _$VecScene {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<VecLayer> get layers => throw _privateConstructorUsedError;
  VecTimeline get timeline => throw _privateConstructorUsedError;
  List<VecMotionPath> get motionPaths => throw _privateConstructorUsedError;

  /// Serializes this VecScene to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecScene
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecSceneCopyWith<VecScene> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecSceneCopyWith<$Res> {
  factory $VecSceneCopyWith(VecScene value, $Res Function(VecScene) then) =
      _$VecSceneCopyWithImpl<$Res, VecScene>;
  @useResult
  $Res call({
    String id,
    String name,
    List<VecLayer> layers,
    VecTimeline timeline,
    List<VecMotionPath> motionPaths,
  });

  $VecTimelineCopyWith<$Res> get timeline;
}

/// @nodoc
class _$VecSceneCopyWithImpl<$Res, $Val extends VecScene>
    implements $VecSceneCopyWith<$Res> {
  _$VecSceneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecScene
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? layers = null,
    Object? timeline = null,
    Object? motionPaths = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            layers: null == layers
                ? _value.layers
                : layers // ignore: cast_nullable_to_non_nullable
                      as List<VecLayer>,
            timeline: null == timeline
                ? _value.timeline
                : timeline // ignore: cast_nullable_to_non_nullable
                      as VecTimeline,
            motionPaths: null == motionPaths
                ? _value.motionPaths
                : motionPaths // ignore: cast_nullable_to_non_nullable
                      as List<VecMotionPath>,
          )
          as $Val,
    );
  }

  /// Create a copy of VecScene
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecTimelineCopyWith<$Res> get timeline {
    return $VecTimelineCopyWith<$Res>(_value.timeline, (value) {
      return _then(_value.copyWith(timeline: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VecSceneImplCopyWith<$Res>
    implements $VecSceneCopyWith<$Res> {
  factory _$$VecSceneImplCopyWith(
    _$VecSceneImpl value,
    $Res Function(_$VecSceneImpl) then,
  ) = __$$VecSceneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    List<VecLayer> layers,
    VecTimeline timeline,
    List<VecMotionPath> motionPaths,
  });

  @override
  $VecTimelineCopyWith<$Res> get timeline;
}

/// @nodoc
class __$$VecSceneImplCopyWithImpl<$Res>
    extends _$VecSceneCopyWithImpl<$Res, _$VecSceneImpl>
    implements _$$VecSceneImplCopyWith<$Res> {
  __$$VecSceneImplCopyWithImpl(
    _$VecSceneImpl _value,
    $Res Function(_$VecSceneImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecScene
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? layers = null,
    Object? timeline = null,
    Object? motionPaths = null,
  }) {
    return _then(
      _$VecSceneImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        layers: null == layers
            ? _value._layers
            : layers // ignore: cast_nullable_to_non_nullable
                  as List<VecLayer>,
        timeline: null == timeline
            ? _value.timeline
            : timeline // ignore: cast_nullable_to_non_nullable
                  as VecTimeline,
        motionPaths: null == motionPaths
            ? _value._motionPaths
            : motionPaths // ignore: cast_nullable_to_non_nullable
                  as List<VecMotionPath>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecSceneImpl implements _VecScene {
  const _$VecSceneImpl({
    required this.id,
    required this.name,
    required final List<VecLayer> layers,
    required this.timeline,
    final List<VecMotionPath> motionPaths = const [],
  }) : _layers = layers,
       _motionPaths = motionPaths;

  factory _$VecSceneImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecSceneImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<VecLayer> _layers;
  @override
  List<VecLayer> get layers {
    if (_layers is EqualUnmodifiableListView) return _layers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_layers);
  }

  @override
  final VecTimeline timeline;
  final List<VecMotionPath> _motionPaths;
  @override
  @JsonKey()
  List<VecMotionPath> get motionPaths {
    if (_motionPaths is EqualUnmodifiableListView) return _motionPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_motionPaths);
  }

  @override
  String toString() {
    return 'VecScene(id: $id, name: $name, layers: $layers, timeline: $timeline, motionPaths: $motionPaths)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecSceneImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._layers, _layers) &&
            (identical(other.timeline, timeline) ||
                other.timeline == timeline) &&
            const DeepCollectionEquality().equals(
              other._motionPaths,
              _motionPaths,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_layers),
    timeline,
    const DeepCollectionEquality().hash(_motionPaths),
  );

  /// Create a copy of VecScene
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecSceneImplCopyWith<_$VecSceneImpl> get copyWith =>
      __$$VecSceneImplCopyWithImpl<_$VecSceneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecSceneImplToJson(this);
  }
}

abstract class _VecScene implements VecScene {
  const factory _VecScene({
    required final String id,
    required final String name,
    required final List<VecLayer> layers,
    required final VecTimeline timeline,
    final List<VecMotionPath> motionPaths,
  }) = _$VecSceneImpl;

  factory _VecScene.fromJson(Map<String, dynamic> json) =
      _$VecSceneImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<VecLayer> get layers;
  @override
  VecTimeline get timeline;
  @override
  List<VecMotionPath> get motionPaths;

  /// Create a copy of VecScene
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecSceneImplCopyWith<_$VecSceneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
