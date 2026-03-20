// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_asset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecAsset _$VecAssetFromJson(Map<String, dynamic> json) {
  return _VecAsset.fromJson(json);
}

/// @nodoc
mixin _$VecAsset {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  VecAssetType get type => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  String? get mimeType => throw _privateConstructorUsedError;

  /// Serializes this VecAsset to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecAsset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecAssetCopyWith<VecAsset> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecAssetCopyWith<$Res> {
  factory $VecAssetCopyWith(VecAsset value, $Res Function(VecAsset) then) =
      _$VecAssetCopyWithImpl<$Res, VecAsset>;
  @useResult
  $Res call({
    String id,
    String name,
    VecAssetType type,
    String path,
    String? mimeType,
  });
}

/// @nodoc
class _$VecAssetCopyWithImpl<$Res, $Val extends VecAsset>
    implements $VecAssetCopyWith<$Res> {
  _$VecAssetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecAsset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? path = null,
    Object? mimeType = freezed,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as VecAssetType,
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            mimeType: freezed == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VecAssetImplCopyWith<$Res>
    implements $VecAssetCopyWith<$Res> {
  factory _$$VecAssetImplCopyWith(
    _$VecAssetImpl value,
    $Res Function(_$VecAssetImpl) then,
  ) = __$$VecAssetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    VecAssetType type,
    String path,
    String? mimeType,
  });
}

/// @nodoc
class __$$VecAssetImplCopyWithImpl<$Res>
    extends _$VecAssetCopyWithImpl<$Res, _$VecAssetImpl>
    implements _$$VecAssetImplCopyWith<$Res> {
  __$$VecAssetImplCopyWithImpl(
    _$VecAssetImpl _value,
    $Res Function(_$VecAssetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecAsset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? path = null,
    Object? mimeType = freezed,
  }) {
    return _then(
      _$VecAssetImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as VecAssetType,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        mimeType: freezed == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecAssetImpl implements _VecAsset {
  const _$VecAssetImpl({
    required this.id,
    required this.name,
    required this.type,
    required this.path,
    this.mimeType,
  });

  factory _$VecAssetImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecAssetImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final VecAssetType type;
  @override
  final String path;
  @override
  final String? mimeType;

  @override
  String toString() {
    return 'VecAsset(id: $id, name: $name, type: $type, path: $path, mimeType: $mimeType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecAssetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, type, path, mimeType);

  /// Create a copy of VecAsset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecAssetImplCopyWith<_$VecAssetImpl> get copyWith =>
      __$$VecAssetImplCopyWithImpl<_$VecAssetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecAssetImplToJson(this);
  }
}

abstract class _VecAsset implements VecAsset {
  const factory _VecAsset({
    required final String id,
    required final String name,
    required final VecAssetType type,
    required final String path,
    final String? mimeType,
  }) = _$VecAssetImpl;

  factory _VecAsset.fromJson(Map<String, dynamic> json) =
      _$VecAssetImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  VecAssetType get type;
  @override
  String get path;
  @override
  String? get mimeType;

  /// Create a copy of VecAsset
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecAssetImplCopyWith<_$VecAssetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
