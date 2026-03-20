// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_color.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecColor _$VecColorFromJson(Map<String, dynamic> json) {
  return _VecColor.fromJson(json);
}

/// @nodoc
mixin _$VecColor {
  int get a => throw _privateConstructorUsedError;
  int get r => throw _privateConstructorUsedError;
  int get g => throw _privateConstructorUsedError;
  int get b => throw _privateConstructorUsedError;

  /// Serializes this VecColor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecColor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecColorCopyWith<VecColor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecColorCopyWith<$Res> {
  factory $VecColorCopyWith(VecColor value, $Res Function(VecColor) then) =
      _$VecColorCopyWithImpl<$Res, VecColor>;
  @useResult
  $Res call({int a, int r, int g, int b});
}

/// @nodoc
class _$VecColorCopyWithImpl<$Res, $Val extends VecColor>
    implements $VecColorCopyWith<$Res> {
  _$VecColorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecColor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? a = null,
    Object? r = null,
    Object? g = null,
    Object? b = null,
  }) {
    return _then(
      _value.copyWith(
            a: null == a
                ? _value.a
                : a // ignore: cast_nullable_to_non_nullable
                      as int,
            r: null == r
                ? _value.r
                : r // ignore: cast_nullable_to_non_nullable
                      as int,
            g: null == g
                ? _value.g
                : g // ignore: cast_nullable_to_non_nullable
                      as int,
            b: null == b
                ? _value.b
                : b // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VecColorImplCopyWith<$Res>
    implements $VecColorCopyWith<$Res> {
  factory _$$VecColorImplCopyWith(
    _$VecColorImpl value,
    $Res Function(_$VecColorImpl) then,
  ) = __$$VecColorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int a, int r, int g, int b});
}

/// @nodoc
class __$$VecColorImplCopyWithImpl<$Res>
    extends _$VecColorCopyWithImpl<$Res, _$VecColorImpl>
    implements _$$VecColorImplCopyWith<$Res> {
  __$$VecColorImplCopyWithImpl(
    _$VecColorImpl _value,
    $Res Function(_$VecColorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecColor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? a = null,
    Object? r = null,
    Object? g = null,
    Object? b = null,
  }) {
    return _then(
      _$VecColorImpl(
        a: null == a
            ? _value.a
            : a // ignore: cast_nullable_to_non_nullable
                  as int,
        r: null == r
            ? _value.r
            : r // ignore: cast_nullable_to_non_nullable
                  as int,
        g: null == g
            ? _value.g
            : g // ignore: cast_nullable_to_non_nullable
                  as int,
        b: null == b
            ? _value.b
            : b // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecColorImpl extends _VecColor {
  const _$VecColorImpl({
    this.a = 255,
    required this.r,
    required this.g,
    required this.b,
  }) : super._();

  factory _$VecColorImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecColorImplFromJson(json);

  @override
  @JsonKey()
  final int a;
  @override
  final int r;
  @override
  final int g;
  @override
  final int b;

  @override
  String toString() {
    return 'VecColor(a: $a, r: $r, g: $g, b: $b)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecColorImpl &&
            (identical(other.a, a) || other.a == a) &&
            (identical(other.r, r) || other.r == r) &&
            (identical(other.g, g) || other.g == g) &&
            (identical(other.b, b) || other.b == b));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, a, r, g, b);

  /// Create a copy of VecColor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecColorImplCopyWith<_$VecColorImpl> get copyWith =>
      __$$VecColorImplCopyWithImpl<_$VecColorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecColorImplToJson(this);
  }
}

abstract class _VecColor extends VecColor {
  const factory _VecColor({
    final int a,
    required final int r,
    required final int g,
    required final int b,
  }) = _$VecColorImpl;
  const _VecColor._() : super._();

  factory _VecColor.fromJson(Map<String, dynamic> json) =
      _$VecColorImpl.fromJson;

  @override
  int get a;
  @override
  int get r;
  @override
  int get g;
  @override
  int get b;

  /// Create a copy of VecColor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecColorImplCopyWith<_$VecColorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
