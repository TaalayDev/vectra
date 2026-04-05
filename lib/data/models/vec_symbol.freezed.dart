// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_symbol.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecSymbol _$VecSymbolFromJson(Map<String, dynamic> json) {
  return _VecSymbol.fromJson(json);
}

/// @nodoc
mixin _$VecSymbol {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  VecSymbolType get type => throw _privateConstructorUsedError;
  VecPoint? get registrationPoint => throw _privateConstructorUsedError;
  List<VecLayer> get layers => throw _privateConstructorUsedError;
  VecTimeline get timeline => throw _privateConstructorUsedError;
  String? get componentSetId => throw _privateConstructorUsedError;
  Map<String, String> get variantProperties =>
      throw _privateConstructorUsedError;

  /// Serializes this VecSymbol to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecSymbol
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecSymbolCopyWith<VecSymbol> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecSymbolCopyWith<$Res> {
  factory $VecSymbolCopyWith(VecSymbol value, $Res Function(VecSymbol) then) =
      _$VecSymbolCopyWithImpl<$Res, VecSymbol>;
  @useResult
  $Res call({
    String id,
    String name,
    VecSymbolType type,
    VecPoint? registrationPoint,
    List<VecLayer> layers,
    VecTimeline timeline,
    String? componentSetId,
    Map<String, String> variantProperties,
  });

  $VecPointCopyWith<$Res>? get registrationPoint;
  $VecTimelineCopyWith<$Res> get timeline;
}

/// @nodoc
class _$VecSymbolCopyWithImpl<$Res, $Val extends VecSymbol>
    implements $VecSymbolCopyWith<$Res> {
  _$VecSymbolCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecSymbol
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? registrationPoint = freezed,
    Object? layers = null,
    Object? timeline = null,
    Object? componentSetId = freezed,
    Object? variantProperties = null,
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
                      as VecSymbolType,
            registrationPoint: freezed == registrationPoint
                ? _value.registrationPoint
                : registrationPoint // ignore: cast_nullable_to_non_nullable
                      as VecPoint?,
            layers: null == layers
                ? _value.layers
                : layers // ignore: cast_nullable_to_non_nullable
                      as List<VecLayer>,
            timeline: null == timeline
                ? _value.timeline
                : timeline // ignore: cast_nullable_to_non_nullable
                      as VecTimeline,
            componentSetId: freezed == componentSetId
                ? _value.componentSetId
                : componentSetId // ignore: cast_nullable_to_non_nullable
                      as String?,
            variantProperties: null == variantProperties
                ? _value.variantProperties
                : variantProperties // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
          )
          as $Val,
    );
  }

  /// Create a copy of VecSymbol
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecPointCopyWith<$Res>? get registrationPoint {
    if (_value.registrationPoint == null) {
      return null;
    }

    return $VecPointCopyWith<$Res>(_value.registrationPoint!, (value) {
      return _then(_value.copyWith(registrationPoint: value) as $Val);
    });
  }

  /// Create a copy of VecSymbol
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
abstract class _$$VecSymbolImplCopyWith<$Res>
    implements $VecSymbolCopyWith<$Res> {
  factory _$$VecSymbolImplCopyWith(
    _$VecSymbolImpl value,
    $Res Function(_$VecSymbolImpl) then,
  ) = __$$VecSymbolImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    VecSymbolType type,
    VecPoint? registrationPoint,
    List<VecLayer> layers,
    VecTimeline timeline,
    String? componentSetId,
    Map<String, String> variantProperties,
  });

  @override
  $VecPointCopyWith<$Res>? get registrationPoint;
  @override
  $VecTimelineCopyWith<$Res> get timeline;
}

/// @nodoc
class __$$VecSymbolImplCopyWithImpl<$Res>
    extends _$VecSymbolCopyWithImpl<$Res, _$VecSymbolImpl>
    implements _$$VecSymbolImplCopyWith<$Res> {
  __$$VecSymbolImplCopyWithImpl(
    _$VecSymbolImpl _value,
    $Res Function(_$VecSymbolImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecSymbol
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? registrationPoint = freezed,
    Object? layers = null,
    Object? timeline = null,
    Object? componentSetId = freezed,
    Object? variantProperties = null,
  }) {
    return _then(
      _$VecSymbolImpl(
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
                  as VecSymbolType,
        registrationPoint: freezed == registrationPoint
            ? _value.registrationPoint
            : registrationPoint // ignore: cast_nullable_to_non_nullable
                  as VecPoint?,
        layers: null == layers
            ? _value._layers
            : layers // ignore: cast_nullable_to_non_nullable
                  as List<VecLayer>,
        timeline: null == timeline
            ? _value.timeline
            : timeline // ignore: cast_nullable_to_non_nullable
                  as VecTimeline,
        componentSetId: freezed == componentSetId
            ? _value.componentSetId
            : componentSetId // ignore: cast_nullable_to_non_nullable
                  as String?,
        variantProperties: null == variantProperties
            ? _value._variantProperties
            : variantProperties // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecSymbolImpl implements _VecSymbol {
  const _$VecSymbolImpl({
    required this.id,
    required this.name,
    this.type = VecSymbolType.graphic,
    this.registrationPoint,
    required final List<VecLayer> layers,
    required this.timeline,
    this.componentSetId,
    final Map<String, String> variantProperties = const {},
  }) : _layers = layers,
       _variantProperties = variantProperties;

  factory _$VecSymbolImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecSymbolImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final VecSymbolType type;
  @override
  final VecPoint? registrationPoint;
  final List<VecLayer> _layers;
  @override
  List<VecLayer> get layers {
    if (_layers is EqualUnmodifiableListView) return _layers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_layers);
  }

  @override
  final VecTimeline timeline;
  @override
  final String? componentSetId;
  final Map<String, String> _variantProperties;
  @override
  @JsonKey()
  Map<String, String> get variantProperties {
    if (_variantProperties is EqualUnmodifiableMapView)
      return _variantProperties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_variantProperties);
  }

  @override
  String toString() {
    return 'VecSymbol(id: $id, name: $name, type: $type, registrationPoint: $registrationPoint, layers: $layers, timeline: $timeline, componentSetId: $componentSetId, variantProperties: $variantProperties)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecSymbolImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.registrationPoint, registrationPoint) ||
                other.registrationPoint == registrationPoint) &&
            const DeepCollectionEquality().equals(other._layers, _layers) &&
            (identical(other.timeline, timeline) ||
                other.timeline == timeline) &&
            (identical(other.componentSetId, componentSetId) ||
                other.componentSetId == componentSetId) &&
            const DeepCollectionEquality().equals(
              other._variantProperties,
              _variantProperties,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    type,
    registrationPoint,
    const DeepCollectionEquality().hash(_layers),
    timeline,
    componentSetId,
    const DeepCollectionEquality().hash(_variantProperties),
  );

  /// Create a copy of VecSymbol
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecSymbolImplCopyWith<_$VecSymbolImpl> get copyWith =>
      __$$VecSymbolImplCopyWithImpl<_$VecSymbolImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecSymbolImplToJson(this);
  }
}

abstract class _VecSymbol implements VecSymbol {
  const factory _VecSymbol({
    required final String id,
    required final String name,
    final VecSymbolType type,
    final VecPoint? registrationPoint,
    required final List<VecLayer> layers,
    required final VecTimeline timeline,
    final String? componentSetId,
    final Map<String, String> variantProperties,
  }) = _$VecSymbolImpl;

  factory _VecSymbol.fromJson(Map<String, dynamic> json) =
      _$VecSymbolImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  VecSymbolType get type;
  @override
  VecPoint? get registrationPoint;
  @override
  List<VecLayer> get layers;
  @override
  VecTimeline get timeline;
  @override
  String? get componentSetId;
  @override
  Map<String, String> get variantProperties;

  /// Create a copy of VecSymbol
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecSymbolImplCopyWith<_$VecSymbolImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
