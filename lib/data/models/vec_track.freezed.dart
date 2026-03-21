// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecTrack _$VecTrackFromJson(Map<String, dynamic> json) {
  return _VecTrack.fromJson(json);
}

/// @nodoc
mixin _$VecTrack {
  String get id => throw _privateConstructorUsedError;
  String get layerId => throw _privateConstructorUsedError;

  /// Null = layer-wide track. Non-null = shape-level track for this shapeId.
  String? get shapeId => throw _privateConstructorUsedError;
  List<VecKeyframe> get keyframes => throw _privateConstructorUsedError;

  /// Serializes this VecTrack to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecTrack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecTrackCopyWith<VecTrack> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecTrackCopyWith<$Res> {
  factory $VecTrackCopyWith(VecTrack value, $Res Function(VecTrack) then) =
      _$VecTrackCopyWithImpl<$Res, VecTrack>;
  @useResult
  $Res call({
    String id,
    String layerId,
    String? shapeId,
    List<VecKeyframe> keyframes,
  });
}

/// @nodoc
class _$VecTrackCopyWithImpl<$Res, $Val extends VecTrack>
    implements $VecTrackCopyWith<$Res> {
  _$VecTrackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecTrack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? layerId = null,
    Object? shapeId = freezed,
    Object? keyframes = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            layerId: null == layerId
                ? _value.layerId
                : layerId // ignore: cast_nullable_to_non_nullable
                      as String,
            shapeId: freezed == shapeId
                ? _value.shapeId
                : shapeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            keyframes: null == keyframes
                ? _value.keyframes
                : keyframes // ignore: cast_nullable_to_non_nullable
                      as List<VecKeyframe>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VecTrackImplCopyWith<$Res>
    implements $VecTrackCopyWith<$Res> {
  factory _$$VecTrackImplCopyWith(
    _$VecTrackImpl value,
    $Res Function(_$VecTrackImpl) then,
  ) = __$$VecTrackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String layerId,
    String? shapeId,
    List<VecKeyframe> keyframes,
  });
}

/// @nodoc
class __$$VecTrackImplCopyWithImpl<$Res>
    extends _$VecTrackCopyWithImpl<$Res, _$VecTrackImpl>
    implements _$$VecTrackImplCopyWith<$Res> {
  __$$VecTrackImplCopyWithImpl(
    _$VecTrackImpl _value,
    $Res Function(_$VecTrackImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecTrack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? layerId = null,
    Object? shapeId = freezed,
    Object? keyframes = null,
  }) {
    return _then(
      _$VecTrackImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        layerId: null == layerId
            ? _value.layerId
            : layerId // ignore: cast_nullable_to_non_nullable
                  as String,
        shapeId: freezed == shapeId
            ? _value.shapeId
            : shapeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        keyframes: null == keyframes
            ? _value._keyframes
            : keyframes // ignore: cast_nullable_to_non_nullable
                  as List<VecKeyframe>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecTrackImpl implements _VecTrack {
  const _$VecTrackImpl({
    required this.id,
    required this.layerId,
    this.shapeId,
    final List<VecKeyframe> keyframes = const [],
  }) : _keyframes = keyframes;

  factory _$VecTrackImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecTrackImplFromJson(json);

  @override
  final String id;
  @override
  final String layerId;

  /// Null = layer-wide track. Non-null = shape-level track for this shapeId.
  @override
  final String? shapeId;
  final List<VecKeyframe> _keyframes;
  @override
  @JsonKey()
  List<VecKeyframe> get keyframes {
    if (_keyframes is EqualUnmodifiableListView) return _keyframes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyframes);
  }

  @override
  String toString() {
    return 'VecTrack(id: $id, layerId: $layerId, shapeId: $shapeId, keyframes: $keyframes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecTrackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.layerId, layerId) || other.layerId == layerId) &&
            (identical(other.shapeId, shapeId) || other.shapeId == shapeId) &&
            const DeepCollectionEquality().equals(
              other._keyframes,
              _keyframes,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    layerId,
    shapeId,
    const DeepCollectionEquality().hash(_keyframes),
  );

  /// Create a copy of VecTrack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecTrackImplCopyWith<_$VecTrackImpl> get copyWith =>
      __$$VecTrackImplCopyWithImpl<_$VecTrackImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecTrackImplToJson(this);
  }
}

abstract class _VecTrack implements VecTrack {
  const factory _VecTrack({
    required final String id,
    required final String layerId,
    final String? shapeId,
    final List<VecKeyframe> keyframes,
  }) = _$VecTrackImpl;

  factory _VecTrack.fromJson(Map<String, dynamic> json) =
      _$VecTrackImpl.fromJson;

  @override
  String get id;
  @override
  String get layerId;

  /// Null = layer-wide track. Non-null = shape-level track for this shapeId.
  @override
  String? get shapeId;
  @override
  List<VecKeyframe> get keyframes;

  /// Create a copy of VecTrack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecTrackImplCopyWith<_$VecTrackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
