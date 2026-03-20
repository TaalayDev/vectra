// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecMeta _$VecMetaFromJson(Map<String, dynamic> json) {
  return _VecMeta.fromJson(json);
}

/// @nodoc
mixin _$VecMeta {
  String get name => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  int get fps => throw _privateConstructorUsedError;
  double get stageWidth => throw _privateConstructorUsedError;
  double get stageHeight => throw _privateConstructorUsedError;
  VecColor get backgroundColor => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get modifiedAt => throw _privateConstructorUsedError;

  /// Serializes this VecMeta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecMetaCopyWith<VecMeta> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecMetaCopyWith<$Res> {
  factory $VecMetaCopyWith(VecMeta value, $Res Function(VecMeta) then) =
      _$VecMetaCopyWithImpl<$Res, VecMeta>;
  @useResult
  $Res call({
    String name,
    int version,
    int fps,
    double stageWidth,
    double stageHeight,
    VecColor backgroundColor,
    DateTime? createdAt,
    DateTime? modifiedAt,
  });

  $VecColorCopyWith<$Res> get backgroundColor;
}

/// @nodoc
class _$VecMetaCopyWithImpl<$Res, $Val extends VecMeta>
    implements $VecMetaCopyWith<$Res> {
  _$VecMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? version = null,
    Object? fps = null,
    Object? stageWidth = null,
    Object? stageHeight = null,
    Object? backgroundColor = null,
    Object? createdAt = freezed,
    Object? modifiedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as int,
            fps: null == fps
                ? _value.fps
                : fps // ignore: cast_nullable_to_non_nullable
                      as int,
            stageWidth: null == stageWidth
                ? _value.stageWidth
                : stageWidth // ignore: cast_nullable_to_non_nullable
                      as double,
            stageHeight: null == stageHeight
                ? _value.stageHeight
                : stageHeight // ignore: cast_nullable_to_non_nullable
                      as double,
            backgroundColor: null == backgroundColor
                ? _value.backgroundColor
                : backgroundColor // ignore: cast_nullable_to_non_nullable
                      as VecColor,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            modifiedAt: freezed == modifiedAt
                ? _value.modifiedAt
                : modifiedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of VecMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecColorCopyWith<$Res> get backgroundColor {
    return $VecColorCopyWith<$Res>(_value.backgroundColor, (value) {
      return _then(_value.copyWith(backgroundColor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VecMetaImplCopyWith<$Res> implements $VecMetaCopyWith<$Res> {
  factory _$$VecMetaImplCopyWith(
    _$VecMetaImpl value,
    $Res Function(_$VecMetaImpl) then,
  ) = __$$VecMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    int version,
    int fps,
    double stageWidth,
    double stageHeight,
    VecColor backgroundColor,
    DateTime? createdAt,
    DateTime? modifiedAt,
  });

  @override
  $VecColorCopyWith<$Res> get backgroundColor;
}

/// @nodoc
class __$$VecMetaImplCopyWithImpl<$Res>
    extends _$VecMetaCopyWithImpl<$Res, _$VecMetaImpl>
    implements _$$VecMetaImplCopyWith<$Res> {
  __$$VecMetaImplCopyWithImpl(
    _$VecMetaImpl _value,
    $Res Function(_$VecMetaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? version = null,
    Object? fps = null,
    Object? stageWidth = null,
    Object? stageHeight = null,
    Object? backgroundColor = null,
    Object? createdAt = freezed,
    Object? modifiedAt = freezed,
  }) {
    return _then(
      _$VecMetaImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as int,
        fps: null == fps
            ? _value.fps
            : fps // ignore: cast_nullable_to_non_nullable
                  as int,
        stageWidth: null == stageWidth
            ? _value.stageWidth
            : stageWidth // ignore: cast_nullable_to_non_nullable
                  as double,
        stageHeight: null == stageHeight
            ? _value.stageHeight
            : stageHeight // ignore: cast_nullable_to_non_nullable
                  as double,
        backgroundColor: null == backgroundColor
            ? _value.backgroundColor
            : backgroundColor // ignore: cast_nullable_to_non_nullable
                  as VecColor,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        modifiedAt: freezed == modifiedAt
            ? _value.modifiedAt
            : modifiedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecMetaImpl implements _VecMeta {
  const _$VecMetaImpl({
    required this.name,
    this.version = 1,
    this.fps = 24,
    this.stageWidth = 1920,
    this.stageHeight = 1080,
    this.backgroundColor = VecColor.white,
    this.createdAt,
    this.modifiedAt,
  });

  factory _$VecMetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecMetaImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey()
  final int version;
  @override
  @JsonKey()
  final int fps;
  @override
  @JsonKey()
  final double stageWidth;
  @override
  @JsonKey()
  final double stageHeight;
  @override
  @JsonKey()
  final VecColor backgroundColor;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? modifiedAt;

  @override
  String toString() {
    return 'VecMeta(name: $name, version: $version, fps: $fps, stageWidth: $stageWidth, stageHeight: $stageHeight, backgroundColor: $backgroundColor, createdAt: $createdAt, modifiedAt: $modifiedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecMetaImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.fps, fps) || other.fps == fps) &&
            (identical(other.stageWidth, stageWidth) ||
                other.stageWidth == stageWidth) &&
            (identical(other.stageHeight, stageHeight) ||
                other.stageHeight == stageHeight) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.modifiedAt, modifiedAt) ||
                other.modifiedAt == modifiedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    version,
    fps,
    stageWidth,
    stageHeight,
    backgroundColor,
    createdAt,
    modifiedAt,
  );

  /// Create a copy of VecMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecMetaImplCopyWith<_$VecMetaImpl> get copyWith =>
      __$$VecMetaImplCopyWithImpl<_$VecMetaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecMetaImplToJson(this);
  }
}

abstract class _VecMeta implements VecMeta {
  const factory _VecMeta({
    required final String name,
    final int version,
    final int fps,
    final double stageWidth,
    final double stageHeight,
    final VecColor backgroundColor,
    final DateTime? createdAt,
    final DateTime? modifiedAt,
  }) = _$VecMetaImpl;

  factory _VecMeta.fromJson(Map<String, dynamic> json) = _$VecMetaImpl.fromJson;

  @override
  String get name;
  @override
  int get version;
  @override
  int get fps;
  @override
  double get stageWidth;
  @override
  double get stageHeight;
  @override
  VecColor get backgroundColor;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get modifiedAt;

  /// Create a copy of VecMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecMetaImplCopyWith<_$VecMetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VecDocument _$VecDocumentFromJson(Map<String, dynamic> json) {
  return _VecDocument.fromJson(json);
}

/// @nodoc
mixin _$VecDocument {
  VecMeta get meta => throw _privateConstructorUsedError;
  List<VecSymbol> get symbols => throw _privateConstructorUsedError;
  List<VecScene> get scenes => throw _privateConstructorUsedError;
  List<VecAsset> get assets => throw _privateConstructorUsedError;

  /// Serializes this VecDocument to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecDocumentCopyWith<VecDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecDocumentCopyWith<$Res> {
  factory $VecDocumentCopyWith(
    VecDocument value,
    $Res Function(VecDocument) then,
  ) = _$VecDocumentCopyWithImpl<$Res, VecDocument>;
  @useResult
  $Res call({
    VecMeta meta,
    List<VecSymbol> symbols,
    List<VecScene> scenes,
    List<VecAsset> assets,
  });

  $VecMetaCopyWith<$Res> get meta;
}

/// @nodoc
class _$VecDocumentCopyWithImpl<$Res, $Val extends VecDocument>
    implements $VecDocumentCopyWith<$Res> {
  _$VecDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meta = null,
    Object? symbols = null,
    Object? scenes = null,
    Object? assets = null,
  }) {
    return _then(
      _value.copyWith(
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as VecMeta,
            symbols: null == symbols
                ? _value.symbols
                : symbols // ignore: cast_nullable_to_non_nullable
                      as List<VecSymbol>,
            scenes: null == scenes
                ? _value.scenes
                : scenes // ignore: cast_nullable_to_non_nullable
                      as List<VecScene>,
            assets: null == assets
                ? _value.assets
                : assets // ignore: cast_nullable_to_non_nullable
                      as List<VecAsset>,
          )
          as $Val,
    );
  }

  /// Create a copy of VecDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecMetaCopyWith<$Res> get meta {
    return $VecMetaCopyWith<$Res>(_value.meta, (value) {
      return _then(_value.copyWith(meta: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VecDocumentImplCopyWith<$Res>
    implements $VecDocumentCopyWith<$Res> {
  factory _$$VecDocumentImplCopyWith(
    _$VecDocumentImpl value,
    $Res Function(_$VecDocumentImpl) then,
  ) = __$$VecDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VecMeta meta,
    List<VecSymbol> symbols,
    List<VecScene> scenes,
    List<VecAsset> assets,
  });

  @override
  $VecMetaCopyWith<$Res> get meta;
}

/// @nodoc
class __$$VecDocumentImplCopyWithImpl<$Res>
    extends _$VecDocumentCopyWithImpl<$Res, _$VecDocumentImpl>
    implements _$$VecDocumentImplCopyWith<$Res> {
  __$$VecDocumentImplCopyWithImpl(
    _$VecDocumentImpl _value,
    $Res Function(_$VecDocumentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meta = null,
    Object? symbols = null,
    Object? scenes = null,
    Object? assets = null,
  }) {
    return _then(
      _$VecDocumentImpl(
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as VecMeta,
        symbols: null == symbols
            ? _value._symbols
            : symbols // ignore: cast_nullable_to_non_nullable
                  as List<VecSymbol>,
        scenes: null == scenes
            ? _value._scenes
            : scenes // ignore: cast_nullable_to_non_nullable
                  as List<VecScene>,
        assets: null == assets
            ? _value._assets
            : assets // ignore: cast_nullable_to_non_nullable
                  as List<VecAsset>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecDocumentImpl implements _VecDocument {
  const _$VecDocumentImpl({
    required this.meta,
    final List<VecSymbol> symbols = const [],
    final List<VecScene> scenes = const [],
    final List<VecAsset> assets = const [],
  }) : _symbols = symbols,
       _scenes = scenes,
       _assets = assets;

  factory _$VecDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecDocumentImplFromJson(json);

  @override
  final VecMeta meta;
  final List<VecSymbol> _symbols;
  @override
  @JsonKey()
  List<VecSymbol> get symbols {
    if (_symbols is EqualUnmodifiableListView) return _symbols;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_symbols);
  }

  final List<VecScene> _scenes;
  @override
  @JsonKey()
  List<VecScene> get scenes {
    if (_scenes is EqualUnmodifiableListView) return _scenes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scenes);
  }

  final List<VecAsset> _assets;
  @override
  @JsonKey()
  List<VecAsset> get assets {
    if (_assets is EqualUnmodifiableListView) return _assets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assets);
  }

  @override
  String toString() {
    return 'VecDocument(meta: $meta, symbols: $symbols, scenes: $scenes, assets: $assets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecDocumentImpl &&
            (identical(other.meta, meta) || other.meta == meta) &&
            const DeepCollectionEquality().equals(other._symbols, _symbols) &&
            const DeepCollectionEquality().equals(other._scenes, _scenes) &&
            const DeepCollectionEquality().equals(other._assets, _assets));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    meta,
    const DeepCollectionEquality().hash(_symbols),
    const DeepCollectionEquality().hash(_scenes),
    const DeepCollectionEquality().hash(_assets),
  );

  /// Create a copy of VecDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecDocumentImplCopyWith<_$VecDocumentImpl> get copyWith =>
      __$$VecDocumentImplCopyWithImpl<_$VecDocumentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecDocumentImplToJson(this);
  }
}

abstract class _VecDocument implements VecDocument {
  const factory _VecDocument({
    required final VecMeta meta,
    final List<VecSymbol> symbols,
    final List<VecScene> scenes,
    final List<VecAsset> assets,
  }) = _$VecDocumentImpl;

  factory _VecDocument.fromJson(Map<String, dynamic> json) =
      _$VecDocumentImpl.fromJson;

  @override
  VecMeta get meta;
  @override
  List<VecSymbol> get symbols;
  @override
  List<VecScene> get scenes;
  @override
  List<VecAsset> get assets;

  /// Create a copy of VecDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecDocumentImplCopyWith<_$VecDocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
