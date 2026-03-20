// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_path_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecPathNode _$VecPathNodeFromJson(Map<String, dynamic> json) {
  return _VecPathNode.fromJson(json);
}

/// @nodoc
mixin _$VecPathNode {
  VecPoint get position => throw _privateConstructorUsedError;
  VecPoint? get handleIn => throw _privateConstructorUsedError;
  VecPoint? get handleOut => throw _privateConstructorUsedError;
  VecNodeType get type => throw _privateConstructorUsedError;

  /// Serializes this VecPathNode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecPathNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecPathNodeCopyWith<VecPathNode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecPathNodeCopyWith<$Res> {
  factory $VecPathNodeCopyWith(
    VecPathNode value,
    $Res Function(VecPathNode) then,
  ) = _$VecPathNodeCopyWithImpl<$Res, VecPathNode>;
  @useResult
  $Res call({
    VecPoint position,
    VecPoint? handleIn,
    VecPoint? handleOut,
    VecNodeType type,
  });

  $VecPointCopyWith<$Res> get position;
  $VecPointCopyWith<$Res>? get handleIn;
  $VecPointCopyWith<$Res>? get handleOut;
}

/// @nodoc
class _$VecPathNodeCopyWithImpl<$Res, $Val extends VecPathNode>
    implements $VecPathNodeCopyWith<$Res> {
  _$VecPathNodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecPathNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? handleIn = freezed,
    Object? handleOut = freezed,
    Object? type = null,
  }) {
    return _then(
      _value.copyWith(
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as VecPoint,
            handleIn: freezed == handleIn
                ? _value.handleIn
                : handleIn // ignore: cast_nullable_to_non_nullable
                      as VecPoint?,
            handleOut: freezed == handleOut
                ? _value.handleOut
                : handleOut // ignore: cast_nullable_to_non_nullable
                      as VecPoint?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as VecNodeType,
          )
          as $Val,
    );
  }

  /// Create a copy of VecPathNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecPointCopyWith<$Res> get position {
    return $VecPointCopyWith<$Res>(_value.position, (value) {
      return _then(_value.copyWith(position: value) as $Val);
    });
  }

  /// Create a copy of VecPathNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecPointCopyWith<$Res>? get handleIn {
    if (_value.handleIn == null) {
      return null;
    }

    return $VecPointCopyWith<$Res>(_value.handleIn!, (value) {
      return _then(_value.copyWith(handleIn: value) as $Val);
    });
  }

  /// Create a copy of VecPathNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecPointCopyWith<$Res>? get handleOut {
    if (_value.handleOut == null) {
      return null;
    }

    return $VecPointCopyWith<$Res>(_value.handleOut!, (value) {
      return _then(_value.copyWith(handleOut: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VecPathNodeImplCopyWith<$Res>
    implements $VecPathNodeCopyWith<$Res> {
  factory _$$VecPathNodeImplCopyWith(
    _$VecPathNodeImpl value,
    $Res Function(_$VecPathNodeImpl) then,
  ) = __$$VecPathNodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VecPoint position,
    VecPoint? handleIn,
    VecPoint? handleOut,
    VecNodeType type,
  });

  @override
  $VecPointCopyWith<$Res> get position;
  @override
  $VecPointCopyWith<$Res>? get handleIn;
  @override
  $VecPointCopyWith<$Res>? get handleOut;
}

/// @nodoc
class __$$VecPathNodeImplCopyWithImpl<$Res>
    extends _$VecPathNodeCopyWithImpl<$Res, _$VecPathNodeImpl>
    implements _$$VecPathNodeImplCopyWith<$Res> {
  __$$VecPathNodeImplCopyWithImpl(
    _$VecPathNodeImpl _value,
    $Res Function(_$VecPathNodeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecPathNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? handleIn = freezed,
    Object? handleOut = freezed,
    Object? type = null,
  }) {
    return _then(
      _$VecPathNodeImpl(
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as VecPoint,
        handleIn: freezed == handleIn
            ? _value.handleIn
            : handleIn // ignore: cast_nullable_to_non_nullable
                  as VecPoint?,
        handleOut: freezed == handleOut
            ? _value.handleOut
            : handleOut // ignore: cast_nullable_to_non_nullable
                  as VecPoint?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as VecNodeType,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecPathNodeImpl implements _VecPathNode {
  const _$VecPathNodeImpl({
    required this.position,
    this.handleIn,
    this.handleOut,
    this.type = VecNodeType.corner,
  });

  factory _$VecPathNodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecPathNodeImplFromJson(json);

  @override
  final VecPoint position;
  @override
  final VecPoint? handleIn;
  @override
  final VecPoint? handleOut;
  @override
  @JsonKey()
  final VecNodeType type;

  @override
  String toString() {
    return 'VecPathNode(position: $position, handleIn: $handleIn, handleOut: $handleOut, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecPathNodeImpl &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.handleIn, handleIn) ||
                other.handleIn == handleIn) &&
            (identical(other.handleOut, handleOut) ||
                other.handleOut == handleOut) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, position, handleIn, handleOut, type);

  /// Create a copy of VecPathNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecPathNodeImplCopyWith<_$VecPathNodeImpl> get copyWith =>
      __$$VecPathNodeImplCopyWithImpl<_$VecPathNodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecPathNodeImplToJson(this);
  }
}

abstract class _VecPathNode implements VecPathNode {
  const factory _VecPathNode({
    required final VecPoint position,
    final VecPoint? handleIn,
    final VecPoint? handleOut,
    final VecNodeType type,
  }) = _$VecPathNodeImpl;

  factory _VecPathNode.fromJson(Map<String, dynamic> json) =
      _$VecPathNodeImpl.fromJson;

  @override
  VecPoint get position;
  @override
  VecPoint? get handleIn;
  @override
  VecPoint? get handleOut;
  @override
  VecNodeType get type;

  /// Create a copy of VecPathNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecPathNodeImplCopyWith<_$VecPathNodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
