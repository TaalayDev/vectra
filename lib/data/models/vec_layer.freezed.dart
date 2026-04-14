// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_layer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecLayer _$VecLayerFromJson(Map<String, dynamic> json) {
  return _VecLayer.fromJson(json);
}

/// @nodoc
mixin _$VecLayer {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  VecLayerType get type => throw _privateConstructorUsedError;
  bool get visible => throw _privateConstructorUsedError;
  bool get locked => throw _privateConstructorUsedError;
  VecColor? get colorDot => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  List<VecShape> get shapes => throw _privateConstructorUsedError;

  /// When true this layer acts as a non-destructive tracing reference.
  /// It renders at [referenceOpacity] and is auto-locked.
  bool get isReference => throw _privateConstructorUsedError;

  /// Opacity used when [isReference] is true (0–1).
  double get referenceOpacity => throw _privateConstructorUsedError;

  /// Serializes this VecLayer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecLayer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecLayerCopyWith<VecLayer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecLayerCopyWith<$Res> {
  factory $VecLayerCopyWith(VecLayer value, $Res Function(VecLayer) then) =
      _$VecLayerCopyWithImpl<$Res, VecLayer>;
  @useResult
  $Res call({
    String id,
    String name,
    VecLayerType type,
    bool visible,
    bool locked,
    VecColor? colorDot,
    int order,
    String? parentId,
    List<VecShape> shapes,
    bool isReference,
    double referenceOpacity,
  });

  $VecColorCopyWith<$Res>? get colorDot;
}

/// @nodoc
class _$VecLayerCopyWithImpl<$Res, $Val extends VecLayer>
    implements $VecLayerCopyWith<$Res> {
  _$VecLayerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecLayer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? visible = null,
    Object? locked = null,
    Object? colorDot = freezed,
    Object? order = null,
    Object? parentId = freezed,
    Object? shapes = null,
    Object? isReference = null,
    Object? referenceOpacity = null,
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
                      as VecLayerType,
            visible: null == visible
                ? _value.visible
                : visible // ignore: cast_nullable_to_non_nullable
                      as bool,
            locked: null == locked
                ? _value.locked
                : locked // ignore: cast_nullable_to_non_nullable
                      as bool,
            colorDot: freezed == colorDot
                ? _value.colorDot
                : colorDot // ignore: cast_nullable_to_non_nullable
                      as VecColor?,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            shapes: null == shapes
                ? _value.shapes
                : shapes // ignore: cast_nullable_to_non_nullable
                      as List<VecShape>,
            isReference: null == isReference
                ? _value.isReference
                : isReference // ignore: cast_nullable_to_non_nullable
                      as bool,
            referenceOpacity: null == referenceOpacity
                ? _value.referenceOpacity
                : referenceOpacity // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }

  /// Create a copy of VecLayer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecColorCopyWith<$Res>? get colorDot {
    if (_value.colorDot == null) {
      return null;
    }

    return $VecColorCopyWith<$Res>(_value.colorDot!, (value) {
      return _then(_value.copyWith(colorDot: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VecLayerImplCopyWith<$Res>
    implements $VecLayerCopyWith<$Res> {
  factory _$$VecLayerImplCopyWith(
    _$VecLayerImpl value,
    $Res Function(_$VecLayerImpl) then,
  ) = __$$VecLayerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    VecLayerType type,
    bool visible,
    bool locked,
    VecColor? colorDot,
    int order,
    String? parentId,
    List<VecShape> shapes,
    bool isReference,
    double referenceOpacity,
  });

  @override
  $VecColorCopyWith<$Res>? get colorDot;
}

/// @nodoc
class __$$VecLayerImplCopyWithImpl<$Res>
    extends _$VecLayerCopyWithImpl<$Res, _$VecLayerImpl>
    implements _$$VecLayerImplCopyWith<$Res> {
  __$$VecLayerImplCopyWithImpl(
    _$VecLayerImpl _value,
    $Res Function(_$VecLayerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecLayer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? visible = null,
    Object? locked = null,
    Object? colorDot = freezed,
    Object? order = null,
    Object? parentId = freezed,
    Object? shapes = null,
    Object? isReference = null,
    Object? referenceOpacity = null,
  }) {
    return _then(
      _$VecLayerImpl(
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
                  as VecLayerType,
        visible: null == visible
            ? _value.visible
            : visible // ignore: cast_nullable_to_non_nullable
                  as bool,
        locked: null == locked
            ? _value.locked
            : locked // ignore: cast_nullable_to_non_nullable
                  as bool,
        colorDot: freezed == colorDot
            ? _value.colorDot
            : colorDot // ignore: cast_nullable_to_non_nullable
                  as VecColor?,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        shapes: null == shapes
            ? _value._shapes
            : shapes // ignore: cast_nullable_to_non_nullable
                  as List<VecShape>,
        isReference: null == isReference
            ? _value.isReference
            : isReference // ignore: cast_nullable_to_non_nullable
                  as bool,
        referenceOpacity: null == referenceOpacity
            ? _value.referenceOpacity
            : referenceOpacity // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecLayerImpl implements _VecLayer {
  const _$VecLayerImpl({
    required this.id,
    required this.name,
    this.type = VecLayerType.normal,
    this.visible = true,
    this.locked = false,
    this.colorDot,
    this.order = 0,
    this.parentId,
    final List<VecShape> shapes = const [],
    this.isReference = false,
    this.referenceOpacity = 0.5,
  }) : _shapes = shapes;

  factory _$VecLayerImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecLayerImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final VecLayerType type;
  @override
  @JsonKey()
  final bool visible;
  @override
  @JsonKey()
  final bool locked;
  @override
  final VecColor? colorDot;
  @override
  @JsonKey()
  final int order;
  @override
  final String? parentId;
  final List<VecShape> _shapes;
  @override
  @JsonKey()
  List<VecShape> get shapes {
    if (_shapes is EqualUnmodifiableListView) return _shapes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_shapes);
  }

  /// When true this layer acts as a non-destructive tracing reference.
  /// It renders at [referenceOpacity] and is auto-locked.
  @override
  @JsonKey()
  final bool isReference;

  /// Opacity used when [isReference] is true (0–1).
  @override
  @JsonKey()
  final double referenceOpacity;

  @override
  String toString() {
    return 'VecLayer(id: $id, name: $name, type: $type, visible: $visible, locked: $locked, colorDot: $colorDot, order: $order, parentId: $parentId, shapes: $shapes, isReference: $isReference, referenceOpacity: $referenceOpacity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecLayerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            (identical(other.locked, locked) || other.locked == locked) &&
            (identical(other.colorDot, colorDot) ||
                other.colorDot == colorDot) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            const DeepCollectionEquality().equals(other._shapes, _shapes) &&
            (identical(other.isReference, isReference) ||
                other.isReference == isReference) &&
            (identical(other.referenceOpacity, referenceOpacity) ||
                other.referenceOpacity == referenceOpacity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    type,
    visible,
    locked,
    colorDot,
    order,
    parentId,
    const DeepCollectionEquality().hash(_shapes),
    isReference,
    referenceOpacity,
  );

  /// Create a copy of VecLayer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecLayerImplCopyWith<_$VecLayerImpl> get copyWith =>
      __$$VecLayerImplCopyWithImpl<_$VecLayerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecLayerImplToJson(this);
  }
}

abstract class _VecLayer implements VecLayer {
  const factory _VecLayer({
    required final String id,
    required final String name,
    final VecLayerType type,
    final bool visible,
    final bool locked,
    final VecColor? colorDot,
    final int order,
    final String? parentId,
    final List<VecShape> shapes,
    final bool isReference,
    final double referenceOpacity,
  }) = _$VecLayerImpl;

  factory _VecLayer.fromJson(Map<String, dynamic> json) =
      _$VecLayerImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  VecLayerType get type;
  @override
  bool get visible;
  @override
  bool get locked;
  @override
  VecColor? get colorDot;
  @override
  int get order;
  @override
  String? get parentId;
  @override
  List<VecShape> get shapes;

  /// When true this layer acts as a non-destructive tracing reference.
  /// It renders at [referenceOpacity] and is auto-locked.
  @override
  bool get isReference;

  /// Opacity used when [isReference] is true (0–1).
  @override
  double get referenceOpacity;

  /// Create a copy of VecLayer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecLayerImplCopyWith<_$VecLayerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
