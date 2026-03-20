// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_shape_hint.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecShapeHint _$VecShapeHintFromJson(Map<String, dynamic> json) {
  return _VecShapeHint.fromJson(json);
}

/// @nodoc
mixin _$VecShapeHint {
  String get label => throw _privateConstructorUsedError;
  VecPoint get startPoint => throw _privateConstructorUsedError;
  VecPoint get endPoint => throw _privateConstructorUsedError;

  /// Serializes this VecShapeHint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecShapeHint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecShapeHintCopyWith<VecShapeHint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecShapeHintCopyWith<$Res> {
  factory $VecShapeHintCopyWith(
    VecShapeHint value,
    $Res Function(VecShapeHint) then,
  ) = _$VecShapeHintCopyWithImpl<$Res, VecShapeHint>;
  @useResult
  $Res call({String label, VecPoint startPoint, VecPoint endPoint});

  $VecPointCopyWith<$Res> get startPoint;
  $VecPointCopyWith<$Res> get endPoint;
}

/// @nodoc
class _$VecShapeHintCopyWithImpl<$Res, $Val extends VecShapeHint>
    implements $VecShapeHintCopyWith<$Res> {
  _$VecShapeHintCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecShapeHint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? startPoint = null,
    Object? endPoint = null,
  }) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            startPoint: null == startPoint
                ? _value.startPoint
                : startPoint // ignore: cast_nullable_to_non_nullable
                      as VecPoint,
            endPoint: null == endPoint
                ? _value.endPoint
                : endPoint // ignore: cast_nullable_to_non_nullable
                      as VecPoint,
          )
          as $Val,
    );
  }

  /// Create a copy of VecShapeHint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecPointCopyWith<$Res> get startPoint {
    return $VecPointCopyWith<$Res>(_value.startPoint, (value) {
      return _then(_value.copyWith(startPoint: value) as $Val);
    });
  }

  /// Create a copy of VecShapeHint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecPointCopyWith<$Res> get endPoint {
    return $VecPointCopyWith<$Res>(_value.endPoint, (value) {
      return _then(_value.copyWith(endPoint: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VecShapeHintImplCopyWith<$Res>
    implements $VecShapeHintCopyWith<$Res> {
  factory _$$VecShapeHintImplCopyWith(
    _$VecShapeHintImpl value,
    $Res Function(_$VecShapeHintImpl) then,
  ) = __$$VecShapeHintImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, VecPoint startPoint, VecPoint endPoint});

  @override
  $VecPointCopyWith<$Res> get startPoint;
  @override
  $VecPointCopyWith<$Res> get endPoint;
}

/// @nodoc
class __$$VecShapeHintImplCopyWithImpl<$Res>
    extends _$VecShapeHintCopyWithImpl<$Res, _$VecShapeHintImpl>
    implements _$$VecShapeHintImplCopyWith<$Res> {
  __$$VecShapeHintImplCopyWithImpl(
    _$VecShapeHintImpl _value,
    $Res Function(_$VecShapeHintImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecShapeHint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? startPoint = null,
    Object? endPoint = null,
  }) {
    return _then(
      _$VecShapeHintImpl(
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        startPoint: null == startPoint
            ? _value.startPoint
            : startPoint // ignore: cast_nullable_to_non_nullable
                  as VecPoint,
        endPoint: null == endPoint
            ? _value.endPoint
            : endPoint // ignore: cast_nullable_to_non_nullable
                  as VecPoint,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecShapeHintImpl implements _VecShapeHint {
  const _$VecShapeHintImpl({
    required this.label,
    required this.startPoint,
    required this.endPoint,
  });

  factory _$VecShapeHintImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecShapeHintImplFromJson(json);

  @override
  final String label;
  @override
  final VecPoint startPoint;
  @override
  final VecPoint endPoint;

  @override
  String toString() {
    return 'VecShapeHint(label: $label, startPoint: $startPoint, endPoint: $endPoint)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecShapeHintImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.startPoint, startPoint) ||
                other.startPoint == startPoint) &&
            (identical(other.endPoint, endPoint) ||
                other.endPoint == endPoint));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, startPoint, endPoint);

  /// Create a copy of VecShapeHint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecShapeHintImplCopyWith<_$VecShapeHintImpl> get copyWith =>
      __$$VecShapeHintImplCopyWithImpl<_$VecShapeHintImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecShapeHintImplToJson(this);
  }
}

abstract class _VecShapeHint implements VecShapeHint {
  const factory _VecShapeHint({
    required final String label,
    required final VecPoint startPoint,
    required final VecPoint endPoint,
  }) = _$VecShapeHintImpl;

  factory _VecShapeHint.fromJson(Map<String, dynamic> json) =
      _$VecShapeHintImpl.fromJson;

  @override
  String get label;
  @override
  VecPoint get startPoint;
  @override
  VecPoint get endPoint;

  /// Create a copy of VecShapeHint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecShapeHintImplCopyWith<_$VecShapeHintImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
