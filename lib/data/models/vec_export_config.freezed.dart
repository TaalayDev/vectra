// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_export_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecExportConfig _$VecExportConfigFromJson(Map<String, dynamic> json) {
  return _VecExportConfig.fromJson(json);
}

/// @nodoc
mixin _$VecExportConfig {
  VecExportFormat get format => throw _privateConstructorUsedError;
  double get resolutionScale => throw _privateConstructorUsedError;
  int get quality => throw _privateConstructorUsedError;
  bool get transparent => throw _privateConstructorUsedError;

  /// Serializes this VecExportConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecExportConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecExportConfigCopyWith<VecExportConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecExportConfigCopyWith<$Res> {
  factory $VecExportConfigCopyWith(
    VecExportConfig value,
    $Res Function(VecExportConfig) then,
  ) = _$VecExportConfigCopyWithImpl<$Res, VecExportConfig>;
  @useResult
  $Res call({
    VecExportFormat format,
    double resolutionScale,
    int quality,
    bool transparent,
  });
}

/// @nodoc
class _$VecExportConfigCopyWithImpl<$Res, $Val extends VecExportConfig>
    implements $VecExportConfigCopyWith<$Res> {
  _$VecExportConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecExportConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? format = null,
    Object? resolutionScale = null,
    Object? quality = null,
    Object? transparent = null,
  }) {
    return _then(
      _value.copyWith(
            format: null == format
                ? _value.format
                : format // ignore: cast_nullable_to_non_nullable
                      as VecExportFormat,
            resolutionScale: null == resolutionScale
                ? _value.resolutionScale
                : resolutionScale // ignore: cast_nullable_to_non_nullable
                      as double,
            quality: null == quality
                ? _value.quality
                : quality // ignore: cast_nullable_to_non_nullable
                      as int,
            transparent: null == transparent
                ? _value.transparent
                : transparent // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VecExportConfigImplCopyWith<$Res>
    implements $VecExportConfigCopyWith<$Res> {
  factory _$$VecExportConfigImplCopyWith(
    _$VecExportConfigImpl value,
    $Res Function(_$VecExportConfigImpl) then,
  ) = __$$VecExportConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VecExportFormat format,
    double resolutionScale,
    int quality,
    bool transparent,
  });
}

/// @nodoc
class __$$VecExportConfigImplCopyWithImpl<$Res>
    extends _$VecExportConfigCopyWithImpl<$Res, _$VecExportConfigImpl>
    implements _$$VecExportConfigImplCopyWith<$Res> {
  __$$VecExportConfigImplCopyWithImpl(
    _$VecExportConfigImpl _value,
    $Res Function(_$VecExportConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecExportConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? format = null,
    Object? resolutionScale = null,
    Object? quality = null,
    Object? transparent = null,
  }) {
    return _then(
      _$VecExportConfigImpl(
        format: null == format
            ? _value.format
            : format // ignore: cast_nullable_to_non_nullable
                  as VecExportFormat,
        resolutionScale: null == resolutionScale
            ? _value.resolutionScale
            : resolutionScale // ignore: cast_nullable_to_non_nullable
                  as double,
        quality: null == quality
            ? _value.quality
            : quality // ignore: cast_nullable_to_non_nullable
                  as int,
        transparent: null == transparent
            ? _value.transparent
            : transparent // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecExportConfigImpl implements _VecExportConfig {
  const _$VecExportConfigImpl({
    this.format = VecExportFormat.lottie,
    this.resolutionScale = 1.0,
    this.quality = 90,
    this.transparent = false,
  });

  factory _$VecExportConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecExportConfigImplFromJson(json);

  @override
  @JsonKey()
  final VecExportFormat format;
  @override
  @JsonKey()
  final double resolutionScale;
  @override
  @JsonKey()
  final int quality;
  @override
  @JsonKey()
  final bool transparent;

  @override
  String toString() {
    return 'VecExportConfig(format: $format, resolutionScale: $resolutionScale, quality: $quality, transparent: $transparent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecExportConfigImpl &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.resolutionScale, resolutionScale) ||
                other.resolutionScale == resolutionScale) &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.transparent, transparent) ||
                other.transparent == transparent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, format, resolutionScale, quality, transparent);

  /// Create a copy of VecExportConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecExportConfigImplCopyWith<_$VecExportConfigImpl> get copyWith =>
      __$$VecExportConfigImplCopyWithImpl<_$VecExportConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VecExportConfigImplToJson(this);
  }
}

abstract class _VecExportConfig implements VecExportConfig {
  const factory _VecExportConfig({
    final VecExportFormat format,
    final double resolutionScale,
    final int quality,
    final bool transparent,
  }) = _$VecExportConfigImpl;

  factory _VecExportConfig.fromJson(Map<String, dynamic> json) =
      _$VecExportConfigImpl.fromJson;

  @override
  VecExportFormat get format;
  @override
  double get resolutionScale;
  @override
  int get quality;
  @override
  bool get transparent;

  /// Create a copy of VecExportConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecExportConfigImplCopyWith<_$VecExportConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
