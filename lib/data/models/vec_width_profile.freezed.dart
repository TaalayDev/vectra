// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_width_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecWidthPoint _$VecWidthPointFromJson(Map<String, dynamic> json) {
  return _VecWidthPoint.fromJson(json);
}

/// @nodoc
mixin _$VecWidthPoint {
  double get position => throw _privateConstructorUsedError;
  double get leftWidth => throw _privateConstructorUsedError;
  double get rightWidth => throw _privateConstructorUsedError;

  /// Serializes this VecWidthPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecWidthPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecWidthPointCopyWith<VecWidthPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecWidthPointCopyWith<$Res> {
  factory $VecWidthPointCopyWith(
    VecWidthPoint value,
    $Res Function(VecWidthPoint) then,
  ) = _$VecWidthPointCopyWithImpl<$Res, VecWidthPoint>;
  @useResult
  $Res call({double position, double leftWidth, double rightWidth});
}

/// @nodoc
class _$VecWidthPointCopyWithImpl<$Res, $Val extends VecWidthPoint>
    implements $VecWidthPointCopyWith<$Res> {
  _$VecWidthPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecWidthPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? leftWidth = null,
    Object? rightWidth = null,
  }) {
    return _then(
      _value.copyWith(
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as double,
            leftWidth: null == leftWidth
                ? _value.leftWidth
                : leftWidth // ignore: cast_nullable_to_non_nullable
                      as double,
            rightWidth: null == rightWidth
                ? _value.rightWidth
                : rightWidth // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VecWidthPointImplCopyWith<$Res>
    implements $VecWidthPointCopyWith<$Res> {
  factory _$$VecWidthPointImplCopyWith(
    _$VecWidthPointImpl value,
    $Res Function(_$VecWidthPointImpl) then,
  ) = __$$VecWidthPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double position, double leftWidth, double rightWidth});
}

/// @nodoc
class __$$VecWidthPointImplCopyWithImpl<$Res>
    extends _$VecWidthPointCopyWithImpl<$Res, _$VecWidthPointImpl>
    implements _$$VecWidthPointImplCopyWith<$Res> {
  __$$VecWidthPointImplCopyWithImpl(
    _$VecWidthPointImpl _value,
    $Res Function(_$VecWidthPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecWidthPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? leftWidth = null,
    Object? rightWidth = null,
  }) {
    return _then(
      _$VecWidthPointImpl(
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as double,
        leftWidth: null == leftWidth
            ? _value.leftWidth
            : leftWidth // ignore: cast_nullable_to_non_nullable
                  as double,
        rightWidth: null == rightWidth
            ? _value.rightWidth
            : rightWidth // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecWidthPointImpl implements _VecWidthPoint {
  const _$VecWidthPointImpl({
    required this.position,
    required this.leftWidth,
    required this.rightWidth,
  });

  factory _$VecWidthPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecWidthPointImplFromJson(json);

  @override
  final double position;
  @override
  final double leftWidth;
  @override
  final double rightWidth;

  @override
  String toString() {
    return 'VecWidthPoint(position: $position, leftWidth: $leftWidth, rightWidth: $rightWidth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecWidthPointImpl &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.leftWidth, leftWidth) ||
                other.leftWidth == leftWidth) &&
            (identical(other.rightWidth, rightWidth) ||
                other.rightWidth == rightWidth));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, position, leftWidth, rightWidth);

  /// Create a copy of VecWidthPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecWidthPointImplCopyWith<_$VecWidthPointImpl> get copyWith =>
      __$$VecWidthPointImplCopyWithImpl<_$VecWidthPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecWidthPointImplToJson(this);
  }
}

abstract class _VecWidthPoint implements VecWidthPoint {
  const factory _VecWidthPoint({
    required final double position,
    required final double leftWidth,
    required final double rightWidth,
  }) = _$VecWidthPointImpl;

  factory _VecWidthPoint.fromJson(Map<String, dynamic> json) =
      _$VecWidthPointImpl.fromJson;

  @override
  double get position;
  @override
  double get leftWidth;
  @override
  double get rightWidth;

  /// Create a copy of VecWidthPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecWidthPointImplCopyWith<_$VecWidthPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VecWidthProfile _$VecWidthProfileFromJson(Map<String, dynamic> json) {
  return _VecWidthProfile.fromJson(json);
}

/// @nodoc
mixin _$VecWidthProfile {
  String? get name => throw _privateConstructorUsedError;
  List<VecWidthPoint> get points => throw _privateConstructorUsedError;

  /// Serializes this VecWidthProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecWidthProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecWidthProfileCopyWith<VecWidthProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecWidthProfileCopyWith<$Res> {
  factory $VecWidthProfileCopyWith(
    VecWidthProfile value,
    $Res Function(VecWidthProfile) then,
  ) = _$VecWidthProfileCopyWithImpl<$Res, VecWidthProfile>;
  @useResult
  $Res call({String? name, List<VecWidthPoint> points});
}

/// @nodoc
class _$VecWidthProfileCopyWithImpl<$Res, $Val extends VecWidthProfile>
    implements $VecWidthProfileCopyWith<$Res> {
  _$VecWidthProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecWidthProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = freezed, Object? points = null}) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as List<VecWidthPoint>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VecWidthProfileImplCopyWith<$Res>
    implements $VecWidthProfileCopyWith<$Res> {
  factory _$$VecWidthProfileImplCopyWith(
    _$VecWidthProfileImpl value,
    $Res Function(_$VecWidthProfileImpl) then,
  ) = __$$VecWidthProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? name, List<VecWidthPoint> points});
}

/// @nodoc
class __$$VecWidthProfileImplCopyWithImpl<$Res>
    extends _$VecWidthProfileCopyWithImpl<$Res, _$VecWidthProfileImpl>
    implements _$$VecWidthProfileImplCopyWith<$Res> {
  __$$VecWidthProfileImplCopyWithImpl(
    _$VecWidthProfileImpl _value,
    $Res Function(_$VecWidthProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecWidthProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = freezed, Object? points = null}) {
    return _then(
      _$VecWidthProfileImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        points: null == points
            ? _value._points
            : points // ignore: cast_nullable_to_non_nullable
                  as List<VecWidthPoint>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecWidthProfileImpl implements _VecWidthProfile {
  const _$VecWidthProfileImpl({
    this.name,
    required final List<VecWidthPoint> points,
  }) : _points = points;

  factory _$VecWidthProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecWidthProfileImplFromJson(json);

  @override
  final String? name;
  final List<VecWidthPoint> _points;
  @override
  List<VecWidthPoint> get points {
    if (_points is EqualUnmodifiableListView) return _points;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_points);
  }

  @override
  String toString() {
    return 'VecWidthProfile(name: $name, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecWidthProfileImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._points, _points));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    const DeepCollectionEquality().hash(_points),
  );

  /// Create a copy of VecWidthProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecWidthProfileImplCopyWith<_$VecWidthProfileImpl> get copyWith =>
      __$$VecWidthProfileImplCopyWithImpl<_$VecWidthProfileImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VecWidthProfileImplToJson(this);
  }
}

abstract class _VecWidthProfile implements VecWidthProfile {
  const factory _VecWidthProfile({
    final String? name,
    required final List<VecWidthPoint> points,
  }) = _$VecWidthProfileImpl;

  factory _VecWidthProfile.fromJson(Map<String, dynamic> json) =
      _$VecWidthProfileImpl.fromJson;

  @override
  String? get name;
  @override
  List<VecWidthPoint> get points;

  /// Create a copy of VecWidthProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecWidthProfileImplCopyWith<_$VecWidthProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
