// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_shape.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecShapeData _$VecShapeDataFromJson(Map<String, dynamic> json) {
  return _VecShapeData.fromJson(json);
}

/// @nodoc
mixin _$VecShapeData {
  String get id => throw _privateConstructorUsedError;
  VecTransform get transform => throw _privateConstructorUsedError;
  List<VecFill> get fills => throw _privateConstructorUsedError;
  List<VecStroke> get strokes => throw _privateConstructorUsedError;
  double get opacity => throw _privateConstructorUsedError;
  VecBlendMode get blendMode => throw _privateConstructorUsedError;
  String? get clipMaskId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;

  /// Serializes this VecShapeData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecShapeData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecShapeDataCopyWith<VecShapeData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecShapeDataCopyWith<$Res> {
  factory $VecShapeDataCopyWith(
    VecShapeData value,
    $Res Function(VecShapeData) then,
  ) = _$VecShapeDataCopyWithImpl<$Res, VecShapeData>;
  @useResult
  $Res call({
    String id,
    VecTransform transform,
    List<VecFill> fills,
    List<VecStroke> strokes,
    double opacity,
    VecBlendMode blendMode,
    String? clipMaskId,
    String? name,
  });

  $VecTransformCopyWith<$Res> get transform;
}

/// @nodoc
class _$VecShapeDataCopyWithImpl<$Res, $Val extends VecShapeData>
    implements $VecShapeDataCopyWith<$Res> {
  _$VecShapeDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecShapeData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transform = null,
    Object? fills = null,
    Object? strokes = null,
    Object? opacity = null,
    Object? blendMode = null,
    Object? clipMaskId = freezed,
    Object? name = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            transform: null == transform
                ? _value.transform
                : transform // ignore: cast_nullable_to_non_nullable
                      as VecTransform,
            fills: null == fills
                ? _value.fills
                : fills // ignore: cast_nullable_to_non_nullable
                      as List<VecFill>,
            strokes: null == strokes
                ? _value.strokes
                : strokes // ignore: cast_nullable_to_non_nullable
                      as List<VecStroke>,
            opacity: null == opacity
                ? _value.opacity
                : opacity // ignore: cast_nullable_to_non_nullable
                      as double,
            blendMode: null == blendMode
                ? _value.blendMode
                : blendMode // ignore: cast_nullable_to_non_nullable
                      as VecBlendMode,
            clipMaskId: freezed == clipMaskId
                ? _value.clipMaskId
                : clipMaskId // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of VecShapeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecTransformCopyWith<$Res> get transform {
    return $VecTransformCopyWith<$Res>(_value.transform, (value) {
      return _then(_value.copyWith(transform: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VecShapeDataImplCopyWith<$Res>
    implements $VecShapeDataCopyWith<$Res> {
  factory _$$VecShapeDataImplCopyWith(
    _$VecShapeDataImpl value,
    $Res Function(_$VecShapeDataImpl) then,
  ) = __$$VecShapeDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    VecTransform transform,
    List<VecFill> fills,
    List<VecStroke> strokes,
    double opacity,
    VecBlendMode blendMode,
    String? clipMaskId,
    String? name,
  });

  @override
  $VecTransformCopyWith<$Res> get transform;
}

/// @nodoc
class __$$VecShapeDataImplCopyWithImpl<$Res>
    extends _$VecShapeDataCopyWithImpl<$Res, _$VecShapeDataImpl>
    implements _$$VecShapeDataImplCopyWith<$Res> {
  __$$VecShapeDataImplCopyWithImpl(
    _$VecShapeDataImpl _value,
    $Res Function(_$VecShapeDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecShapeData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transform = null,
    Object? fills = null,
    Object? strokes = null,
    Object? opacity = null,
    Object? blendMode = null,
    Object? clipMaskId = freezed,
    Object? name = freezed,
  }) {
    return _then(
      _$VecShapeDataImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        transform: null == transform
            ? _value.transform
            : transform // ignore: cast_nullable_to_non_nullable
                  as VecTransform,
        fills: null == fills
            ? _value._fills
            : fills // ignore: cast_nullable_to_non_nullable
                  as List<VecFill>,
        strokes: null == strokes
            ? _value._strokes
            : strokes // ignore: cast_nullable_to_non_nullable
                  as List<VecStroke>,
        opacity: null == opacity
            ? _value.opacity
            : opacity // ignore: cast_nullable_to_non_nullable
                  as double,
        blendMode: null == blendMode
            ? _value.blendMode
            : blendMode // ignore: cast_nullable_to_non_nullable
                  as VecBlendMode,
        clipMaskId: freezed == clipMaskId
            ? _value.clipMaskId
            : clipMaskId // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecShapeDataImpl implements _VecShapeData {
  const _$VecShapeDataImpl({
    required this.id,
    required this.transform,
    final List<VecFill> fills = const [],
    final List<VecStroke> strokes = const [],
    this.opacity = 1.0,
    this.blendMode = VecBlendMode.normal,
    this.clipMaskId,
    this.name,
  }) : _fills = fills,
       _strokes = strokes;

  factory _$VecShapeDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecShapeDataImplFromJson(json);

  @override
  final String id;
  @override
  final VecTransform transform;
  final List<VecFill> _fills;
  @override
  @JsonKey()
  List<VecFill> get fills {
    if (_fills is EqualUnmodifiableListView) return _fills;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fills);
  }

  final List<VecStroke> _strokes;
  @override
  @JsonKey()
  List<VecStroke> get strokes {
    if (_strokes is EqualUnmodifiableListView) return _strokes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strokes);
  }

  @override
  @JsonKey()
  final double opacity;
  @override
  @JsonKey()
  final VecBlendMode blendMode;
  @override
  final String? clipMaskId;
  @override
  final String? name;

  @override
  String toString() {
    return 'VecShapeData(id: $id, transform: $transform, fills: $fills, strokes: $strokes, opacity: $opacity, blendMode: $blendMode, clipMaskId: $clipMaskId, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecShapeDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transform, transform) ||
                other.transform == transform) &&
            const DeepCollectionEquality().equals(other._fills, _fills) &&
            const DeepCollectionEquality().equals(other._strokes, _strokes) &&
            (identical(other.opacity, opacity) || other.opacity == opacity) &&
            (identical(other.blendMode, blendMode) ||
                other.blendMode == blendMode) &&
            (identical(other.clipMaskId, clipMaskId) ||
                other.clipMaskId == clipMaskId) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    transform,
    const DeepCollectionEquality().hash(_fills),
    const DeepCollectionEquality().hash(_strokes),
    opacity,
    blendMode,
    clipMaskId,
    name,
  );

  /// Create a copy of VecShapeData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecShapeDataImplCopyWith<_$VecShapeDataImpl> get copyWith =>
      __$$VecShapeDataImplCopyWithImpl<_$VecShapeDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecShapeDataImplToJson(this);
  }
}

abstract class _VecShapeData implements VecShapeData {
  const factory _VecShapeData({
    required final String id,
    required final VecTransform transform,
    final List<VecFill> fills,
    final List<VecStroke> strokes,
    final double opacity,
    final VecBlendMode blendMode,
    final String? clipMaskId,
    final String? name,
  }) = _$VecShapeDataImpl;

  factory _VecShapeData.fromJson(Map<String, dynamic> json) =
      _$VecShapeDataImpl.fromJson;

  @override
  String get id;
  @override
  VecTransform get transform;
  @override
  List<VecFill> get fills;
  @override
  List<VecStroke> get strokes;
  @override
  double get opacity;
  @override
  VecBlendMode get blendMode;
  @override
  String? get clipMaskId;
  @override
  String? get name;

  /// Create a copy of VecShapeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecShapeDataImplCopyWith<_$VecShapeDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VecShape _$VecShapeFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'path':
      return VecPathShape.fromJson(json);
    case 'rectangle':
      return VecRectangleShape.fromJson(json);
    case 'ellipse':
      return VecEllipseShape.fromJson(json);
    case 'polygon':
      return VecPolygonShape.fromJson(json);
    case 'text':
      return VecTextShape.fromJson(json);
    case 'group':
      return VecGroupShape.fromJson(json);
    case 'symbolInstance':
      return VecSymbolInstanceShape.fromJson(json);
    case 'compound':
      return VecCompoundShape.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'type',
        'VecShape',
        'Invalid union type "${json['type']}"!',
      );
  }
}

/// @nodoc
mixin _$VecShape {
  VecShapeData get data => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )
    path,
    required TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )
    rectangle,
    required TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )
    ellipse,
    required TResult Function(
      VecShapeData data,
      int sideCount,
      double? starDepth,
    )
    polygon,
    required TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )
    text,
    required TResult Function(VecShapeData data, List<VecShape> children) group,
    required TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )
    symbolInstance,
    required TResult Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )
    compound,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )?
    path,
    TResult? Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult? Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult? Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult? Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult? Function(VecShapeData data, List<VecShape> children)? group,
    TResult? Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult? Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )?
    compound,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VecShapeData data, List<VecPathNode> nodes, bool isClosed)?
    path,
    TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult Function(VecShapeData data, List<VecShape> children)? group,
    TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult Function(VecShapeData data, PathfinderOp op, List<VecShape> inputs)?
    compound,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VecPathShape value) path,
    required TResult Function(VecRectangleShape value) rectangle,
    required TResult Function(VecEllipseShape value) ellipse,
    required TResult Function(VecPolygonShape value) polygon,
    required TResult Function(VecTextShape value) text,
    required TResult Function(VecGroupShape value) group,
    required TResult Function(VecSymbolInstanceShape value) symbolInstance,
    required TResult Function(VecCompoundShape value) compound,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VecPathShape value)? path,
    TResult? Function(VecRectangleShape value)? rectangle,
    TResult? Function(VecEllipseShape value)? ellipse,
    TResult? Function(VecPolygonShape value)? polygon,
    TResult? Function(VecTextShape value)? text,
    TResult? Function(VecGroupShape value)? group,
    TResult? Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult? Function(VecCompoundShape value)? compound,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VecPathShape value)? path,
    TResult Function(VecRectangleShape value)? rectangle,
    TResult Function(VecEllipseShape value)? ellipse,
    TResult Function(VecPolygonShape value)? polygon,
    TResult Function(VecTextShape value)? text,
    TResult Function(VecGroupShape value)? group,
    TResult Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult Function(VecCompoundShape value)? compound,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this VecShape to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecShapeCopyWith<VecShape> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecShapeCopyWith<$Res> {
  factory $VecShapeCopyWith(VecShape value, $Res Function(VecShape) then) =
      _$VecShapeCopyWithImpl<$Res, VecShape>;
  @useResult
  $Res call({VecShapeData data});

  $VecShapeDataCopyWith<$Res> get data;
}

/// @nodoc
class _$VecShapeCopyWithImpl<$Res, $Val extends VecShape>
    implements $VecShapeCopyWith<$Res> {
  _$VecShapeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as VecShapeData,
          )
          as $Val,
    );
  }

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecShapeDataCopyWith<$Res> get data {
    return $VecShapeDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VecPathShapeImplCopyWith<$Res>
    implements $VecShapeCopyWith<$Res> {
  factory _$$VecPathShapeImplCopyWith(
    _$VecPathShapeImpl value,
    $Res Function(_$VecPathShapeImpl) then,
  ) = __$$VecPathShapeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({VecShapeData data, List<VecPathNode> nodes, bool isClosed});

  @override
  $VecShapeDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$VecPathShapeImplCopyWithImpl<$Res>
    extends _$VecShapeCopyWithImpl<$Res, _$VecPathShapeImpl>
    implements _$$VecPathShapeImplCopyWith<$Res> {
  __$$VecPathShapeImplCopyWithImpl(
    _$VecPathShapeImpl _value,
    $Res Function(_$VecPathShapeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? nodes = null,
    Object? isClosed = null,
  }) {
    return _then(
      _$VecPathShapeImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as VecShapeData,
        nodes: null == nodes
            ? _value._nodes
            : nodes // ignore: cast_nullable_to_non_nullable
                  as List<VecPathNode>,
        isClosed: null == isClosed
            ? _value.isClosed
            : isClosed // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecPathShapeImpl extends VecPathShape {
  const _$VecPathShapeImpl({
    required this.data,
    required final List<VecPathNode> nodes,
    this.isClosed = false,
    final String? $type,
  }) : _nodes = nodes,
       $type = $type ?? 'path',
       super._();

  factory _$VecPathShapeImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecPathShapeImplFromJson(json);

  @override
  final VecShapeData data;
  final List<VecPathNode> _nodes;
  @override
  List<VecPathNode> get nodes {
    if (_nodes is EqualUnmodifiableListView) return _nodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nodes);
  }

  @override
  @JsonKey()
  final bool isClosed;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'VecShape.path(data: $data, nodes: $nodes, isClosed: $isClosed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecPathShapeImpl &&
            (identical(other.data, data) || other.data == data) &&
            const DeepCollectionEquality().equals(other._nodes, _nodes) &&
            (identical(other.isClosed, isClosed) ||
                other.isClosed == isClosed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    data,
    const DeepCollectionEquality().hash(_nodes),
    isClosed,
  );

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecPathShapeImplCopyWith<_$VecPathShapeImpl> get copyWith =>
      __$$VecPathShapeImplCopyWithImpl<_$VecPathShapeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )
    path,
    required TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )
    rectangle,
    required TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )
    ellipse,
    required TResult Function(
      VecShapeData data,
      int sideCount,
      double? starDepth,
    )
    polygon,
    required TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )
    text,
    required TResult Function(VecShapeData data, List<VecShape> children) group,
    required TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )
    symbolInstance,
    required TResult Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )
    compound,
  }) {
    return path(data, nodes, isClosed);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )?
    path,
    TResult? Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult? Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult? Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult? Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult? Function(VecShapeData data, List<VecShape> children)? group,
    TResult? Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult? Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )?
    compound,
  }) {
    return path?.call(data, nodes, isClosed);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VecShapeData data, List<VecPathNode> nodes, bool isClosed)?
    path,
    TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult Function(VecShapeData data, List<VecShape> children)? group,
    TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult Function(VecShapeData data, PathfinderOp op, List<VecShape> inputs)?
    compound,
    required TResult orElse(),
  }) {
    if (path != null) {
      return path(data, nodes, isClosed);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VecPathShape value) path,
    required TResult Function(VecRectangleShape value) rectangle,
    required TResult Function(VecEllipseShape value) ellipse,
    required TResult Function(VecPolygonShape value) polygon,
    required TResult Function(VecTextShape value) text,
    required TResult Function(VecGroupShape value) group,
    required TResult Function(VecSymbolInstanceShape value) symbolInstance,
    required TResult Function(VecCompoundShape value) compound,
  }) {
    return path(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VecPathShape value)? path,
    TResult? Function(VecRectangleShape value)? rectangle,
    TResult? Function(VecEllipseShape value)? ellipse,
    TResult? Function(VecPolygonShape value)? polygon,
    TResult? Function(VecTextShape value)? text,
    TResult? Function(VecGroupShape value)? group,
    TResult? Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult? Function(VecCompoundShape value)? compound,
  }) {
    return path?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VecPathShape value)? path,
    TResult Function(VecRectangleShape value)? rectangle,
    TResult Function(VecEllipseShape value)? ellipse,
    TResult Function(VecPolygonShape value)? polygon,
    TResult Function(VecTextShape value)? text,
    TResult Function(VecGroupShape value)? group,
    TResult Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult Function(VecCompoundShape value)? compound,
    required TResult orElse(),
  }) {
    if (path != null) {
      return path(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$VecPathShapeImplToJson(this);
  }
}

abstract class VecPathShape extends VecShape {
  const factory VecPathShape({
    required final VecShapeData data,
    required final List<VecPathNode> nodes,
    final bool isClosed,
  }) = _$VecPathShapeImpl;
  const VecPathShape._() : super._();

  factory VecPathShape.fromJson(Map<String, dynamic> json) =
      _$VecPathShapeImpl.fromJson;

  @override
  VecShapeData get data;
  List<VecPathNode> get nodes;
  bool get isClosed;

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecPathShapeImplCopyWith<_$VecPathShapeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VecRectangleShapeImplCopyWith<$Res>
    implements $VecShapeCopyWith<$Res> {
  factory _$$VecRectangleShapeImplCopyWith(
    _$VecRectangleShapeImpl value,
    $Res Function(_$VecRectangleShapeImpl) then,
  ) = __$$VecRectangleShapeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VecShapeData data,
    List<double> cornerRadii,
    VecCornerStyle cornerStyle,
  });

  @override
  $VecShapeDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$VecRectangleShapeImplCopyWithImpl<$Res>
    extends _$VecShapeCopyWithImpl<$Res, _$VecRectangleShapeImpl>
    implements _$$VecRectangleShapeImplCopyWith<$Res> {
  __$$VecRectangleShapeImplCopyWithImpl(
    _$VecRectangleShapeImpl _value,
    $Res Function(_$VecRectangleShapeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? cornerRadii = null,
    Object? cornerStyle = null,
  }) {
    return _then(
      _$VecRectangleShapeImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as VecShapeData,
        cornerRadii: null == cornerRadii
            ? _value._cornerRadii
            : cornerRadii // ignore: cast_nullable_to_non_nullable
                  as List<double>,
        cornerStyle: null == cornerStyle
            ? _value.cornerStyle
            : cornerStyle // ignore: cast_nullable_to_non_nullable
                  as VecCornerStyle,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecRectangleShapeImpl extends VecRectangleShape {
  const _$VecRectangleShapeImpl({
    required this.data,
    final List<double> cornerRadii = const [0, 0, 0, 0],
    this.cornerStyle = VecCornerStyle.round,
    final String? $type,
  }) : _cornerRadii = cornerRadii,
       $type = $type ?? 'rectangle',
       super._();

  factory _$VecRectangleShapeImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecRectangleShapeImplFromJson(json);

  @override
  final VecShapeData data;
  final List<double> _cornerRadii;
  @override
  @JsonKey()
  List<double> get cornerRadii {
    if (_cornerRadii is EqualUnmodifiableListView) return _cornerRadii;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cornerRadii);
  }

  @override
  @JsonKey()
  final VecCornerStyle cornerStyle;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'VecShape.rectangle(data: $data, cornerRadii: $cornerRadii, cornerStyle: $cornerStyle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecRectangleShapeImpl &&
            (identical(other.data, data) || other.data == data) &&
            const DeepCollectionEquality().equals(
              other._cornerRadii,
              _cornerRadii,
            ) &&
            (identical(other.cornerStyle, cornerStyle) ||
                other.cornerStyle == cornerStyle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    data,
    const DeepCollectionEquality().hash(_cornerRadii),
    cornerStyle,
  );

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecRectangleShapeImplCopyWith<_$VecRectangleShapeImpl> get copyWith =>
      __$$VecRectangleShapeImplCopyWithImpl<_$VecRectangleShapeImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )
    path,
    required TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )
    rectangle,
    required TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )
    ellipse,
    required TResult Function(
      VecShapeData data,
      int sideCount,
      double? starDepth,
    )
    polygon,
    required TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )
    text,
    required TResult Function(VecShapeData data, List<VecShape> children) group,
    required TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )
    symbolInstance,
    required TResult Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )
    compound,
  }) {
    return rectangle(data, cornerRadii, cornerStyle);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )?
    path,
    TResult? Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult? Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult? Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult? Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult? Function(VecShapeData data, List<VecShape> children)? group,
    TResult? Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult? Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )?
    compound,
  }) {
    return rectangle?.call(data, cornerRadii, cornerStyle);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VecShapeData data, List<VecPathNode> nodes, bool isClosed)?
    path,
    TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult Function(VecShapeData data, List<VecShape> children)? group,
    TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult Function(VecShapeData data, PathfinderOp op, List<VecShape> inputs)?
    compound,
    required TResult orElse(),
  }) {
    if (rectangle != null) {
      return rectangle(data, cornerRadii, cornerStyle);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VecPathShape value) path,
    required TResult Function(VecRectangleShape value) rectangle,
    required TResult Function(VecEllipseShape value) ellipse,
    required TResult Function(VecPolygonShape value) polygon,
    required TResult Function(VecTextShape value) text,
    required TResult Function(VecGroupShape value) group,
    required TResult Function(VecSymbolInstanceShape value) symbolInstance,
    required TResult Function(VecCompoundShape value) compound,
  }) {
    return rectangle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VecPathShape value)? path,
    TResult? Function(VecRectangleShape value)? rectangle,
    TResult? Function(VecEllipseShape value)? ellipse,
    TResult? Function(VecPolygonShape value)? polygon,
    TResult? Function(VecTextShape value)? text,
    TResult? Function(VecGroupShape value)? group,
    TResult? Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult? Function(VecCompoundShape value)? compound,
  }) {
    return rectangle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VecPathShape value)? path,
    TResult Function(VecRectangleShape value)? rectangle,
    TResult Function(VecEllipseShape value)? ellipse,
    TResult Function(VecPolygonShape value)? polygon,
    TResult Function(VecTextShape value)? text,
    TResult Function(VecGroupShape value)? group,
    TResult Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult Function(VecCompoundShape value)? compound,
    required TResult orElse(),
  }) {
    if (rectangle != null) {
      return rectangle(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$VecRectangleShapeImplToJson(this);
  }
}

abstract class VecRectangleShape extends VecShape {
  const factory VecRectangleShape({
    required final VecShapeData data,
    final List<double> cornerRadii,
    final VecCornerStyle cornerStyle,
  }) = _$VecRectangleShapeImpl;
  const VecRectangleShape._() : super._();

  factory VecRectangleShape.fromJson(Map<String, dynamic> json) =
      _$VecRectangleShapeImpl.fromJson;

  @override
  VecShapeData get data;
  List<double> get cornerRadii;
  VecCornerStyle get cornerStyle;

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecRectangleShapeImplCopyWith<_$VecRectangleShapeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VecEllipseShapeImplCopyWith<$Res>
    implements $VecShapeCopyWith<$Res> {
  factory _$$VecEllipseShapeImplCopyWith(
    _$VecEllipseShapeImpl value,
    $Res Function(_$VecEllipseShapeImpl) then,
  ) = __$$VecEllipseShapeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VecShapeData data,
    double startAngle,
    double endAngle,
    double innerRadius,
  });

  @override
  $VecShapeDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$VecEllipseShapeImplCopyWithImpl<$Res>
    extends _$VecShapeCopyWithImpl<$Res, _$VecEllipseShapeImpl>
    implements _$$VecEllipseShapeImplCopyWith<$Res> {
  __$$VecEllipseShapeImplCopyWithImpl(
    _$VecEllipseShapeImpl _value,
    $Res Function(_$VecEllipseShapeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? startAngle = null,
    Object? endAngle = null,
    Object? innerRadius = null,
  }) {
    return _then(
      _$VecEllipseShapeImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as VecShapeData,
        startAngle: null == startAngle
            ? _value.startAngle
            : startAngle // ignore: cast_nullable_to_non_nullable
                  as double,
        endAngle: null == endAngle
            ? _value.endAngle
            : endAngle // ignore: cast_nullable_to_non_nullable
                  as double,
        innerRadius: null == innerRadius
            ? _value.innerRadius
            : innerRadius // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecEllipseShapeImpl extends VecEllipseShape {
  const _$VecEllipseShapeImpl({
    required this.data,
    this.startAngle = 0,
    this.endAngle = 360,
    this.innerRadius = 0,
    final String? $type,
  }) : $type = $type ?? 'ellipse',
       super._();

  factory _$VecEllipseShapeImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecEllipseShapeImplFromJson(json);

  @override
  final VecShapeData data;
  @override
  @JsonKey()
  final double startAngle;
  @override
  @JsonKey()
  final double endAngle;
  @override
  @JsonKey()
  final double innerRadius;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'VecShape.ellipse(data: $data, startAngle: $startAngle, endAngle: $endAngle, innerRadius: $innerRadius)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecEllipseShapeImpl &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.startAngle, startAngle) ||
                other.startAngle == startAngle) &&
            (identical(other.endAngle, endAngle) ||
                other.endAngle == endAngle) &&
            (identical(other.innerRadius, innerRadius) ||
                other.innerRadius == innerRadius));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, data, startAngle, endAngle, innerRadius);

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecEllipseShapeImplCopyWith<_$VecEllipseShapeImpl> get copyWith =>
      __$$VecEllipseShapeImplCopyWithImpl<_$VecEllipseShapeImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )
    path,
    required TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )
    rectangle,
    required TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )
    ellipse,
    required TResult Function(
      VecShapeData data,
      int sideCount,
      double? starDepth,
    )
    polygon,
    required TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )
    text,
    required TResult Function(VecShapeData data, List<VecShape> children) group,
    required TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )
    symbolInstance,
    required TResult Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )
    compound,
  }) {
    return ellipse(data, startAngle, endAngle, innerRadius);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )?
    path,
    TResult? Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult? Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult? Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult? Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult? Function(VecShapeData data, List<VecShape> children)? group,
    TResult? Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult? Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )?
    compound,
  }) {
    return ellipse?.call(data, startAngle, endAngle, innerRadius);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VecShapeData data, List<VecPathNode> nodes, bool isClosed)?
    path,
    TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult Function(VecShapeData data, List<VecShape> children)? group,
    TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult Function(VecShapeData data, PathfinderOp op, List<VecShape> inputs)?
    compound,
    required TResult orElse(),
  }) {
    if (ellipse != null) {
      return ellipse(data, startAngle, endAngle, innerRadius);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VecPathShape value) path,
    required TResult Function(VecRectangleShape value) rectangle,
    required TResult Function(VecEllipseShape value) ellipse,
    required TResult Function(VecPolygonShape value) polygon,
    required TResult Function(VecTextShape value) text,
    required TResult Function(VecGroupShape value) group,
    required TResult Function(VecSymbolInstanceShape value) symbolInstance,
    required TResult Function(VecCompoundShape value) compound,
  }) {
    return ellipse(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VecPathShape value)? path,
    TResult? Function(VecRectangleShape value)? rectangle,
    TResult? Function(VecEllipseShape value)? ellipse,
    TResult? Function(VecPolygonShape value)? polygon,
    TResult? Function(VecTextShape value)? text,
    TResult? Function(VecGroupShape value)? group,
    TResult? Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult? Function(VecCompoundShape value)? compound,
  }) {
    return ellipse?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VecPathShape value)? path,
    TResult Function(VecRectangleShape value)? rectangle,
    TResult Function(VecEllipseShape value)? ellipse,
    TResult Function(VecPolygonShape value)? polygon,
    TResult Function(VecTextShape value)? text,
    TResult Function(VecGroupShape value)? group,
    TResult Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult Function(VecCompoundShape value)? compound,
    required TResult orElse(),
  }) {
    if (ellipse != null) {
      return ellipse(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$VecEllipseShapeImplToJson(this);
  }
}

abstract class VecEllipseShape extends VecShape {
  const factory VecEllipseShape({
    required final VecShapeData data,
    final double startAngle,
    final double endAngle,
    final double innerRadius,
  }) = _$VecEllipseShapeImpl;
  const VecEllipseShape._() : super._();

  factory VecEllipseShape.fromJson(Map<String, dynamic> json) =
      _$VecEllipseShapeImpl.fromJson;

  @override
  VecShapeData get data;
  double get startAngle;
  double get endAngle;
  double get innerRadius;

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecEllipseShapeImplCopyWith<_$VecEllipseShapeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VecPolygonShapeImplCopyWith<$Res>
    implements $VecShapeCopyWith<$Res> {
  factory _$$VecPolygonShapeImplCopyWith(
    _$VecPolygonShapeImpl value,
    $Res Function(_$VecPolygonShapeImpl) then,
  ) = __$$VecPolygonShapeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({VecShapeData data, int sideCount, double? starDepth});

  @override
  $VecShapeDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$VecPolygonShapeImplCopyWithImpl<$Res>
    extends _$VecShapeCopyWithImpl<$Res, _$VecPolygonShapeImpl>
    implements _$$VecPolygonShapeImplCopyWith<$Res> {
  __$$VecPolygonShapeImplCopyWithImpl(
    _$VecPolygonShapeImpl _value,
    $Res Function(_$VecPolygonShapeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? sideCount = null,
    Object? starDepth = freezed,
  }) {
    return _then(
      _$VecPolygonShapeImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as VecShapeData,
        sideCount: null == sideCount
            ? _value.sideCount
            : sideCount // ignore: cast_nullable_to_non_nullable
                  as int,
        starDepth: freezed == starDepth
            ? _value.starDepth
            : starDepth // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecPolygonShapeImpl extends VecPolygonShape {
  const _$VecPolygonShapeImpl({
    required this.data,
    this.sideCount = 6,
    this.starDepth,
    final String? $type,
  }) : $type = $type ?? 'polygon',
       super._();

  factory _$VecPolygonShapeImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecPolygonShapeImplFromJson(json);

  @override
  final VecShapeData data;
  @override
  @JsonKey()
  final int sideCount;
  @override
  final double? starDepth;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'VecShape.polygon(data: $data, sideCount: $sideCount, starDepth: $starDepth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecPolygonShapeImpl &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.sideCount, sideCount) ||
                other.sideCount == sideCount) &&
            (identical(other.starDepth, starDepth) ||
                other.starDepth == starDepth));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, data, sideCount, starDepth);

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecPolygonShapeImplCopyWith<_$VecPolygonShapeImpl> get copyWith =>
      __$$VecPolygonShapeImplCopyWithImpl<_$VecPolygonShapeImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )
    path,
    required TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )
    rectangle,
    required TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )
    ellipse,
    required TResult Function(
      VecShapeData data,
      int sideCount,
      double? starDepth,
    )
    polygon,
    required TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )
    text,
    required TResult Function(VecShapeData data, List<VecShape> children) group,
    required TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )
    symbolInstance,
    required TResult Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )
    compound,
  }) {
    return polygon(data, sideCount, starDepth);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )?
    path,
    TResult? Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult? Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult? Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult? Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult? Function(VecShapeData data, List<VecShape> children)? group,
    TResult? Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult? Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )?
    compound,
  }) {
    return polygon?.call(data, sideCount, starDepth);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VecShapeData data, List<VecPathNode> nodes, bool isClosed)?
    path,
    TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult Function(VecShapeData data, List<VecShape> children)? group,
    TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult Function(VecShapeData data, PathfinderOp op, List<VecShape> inputs)?
    compound,
    required TResult orElse(),
  }) {
    if (polygon != null) {
      return polygon(data, sideCount, starDepth);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VecPathShape value) path,
    required TResult Function(VecRectangleShape value) rectangle,
    required TResult Function(VecEllipseShape value) ellipse,
    required TResult Function(VecPolygonShape value) polygon,
    required TResult Function(VecTextShape value) text,
    required TResult Function(VecGroupShape value) group,
    required TResult Function(VecSymbolInstanceShape value) symbolInstance,
    required TResult Function(VecCompoundShape value) compound,
  }) {
    return polygon(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VecPathShape value)? path,
    TResult? Function(VecRectangleShape value)? rectangle,
    TResult? Function(VecEllipseShape value)? ellipse,
    TResult? Function(VecPolygonShape value)? polygon,
    TResult? Function(VecTextShape value)? text,
    TResult? Function(VecGroupShape value)? group,
    TResult? Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult? Function(VecCompoundShape value)? compound,
  }) {
    return polygon?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VecPathShape value)? path,
    TResult Function(VecRectangleShape value)? rectangle,
    TResult Function(VecEllipseShape value)? ellipse,
    TResult Function(VecPolygonShape value)? polygon,
    TResult Function(VecTextShape value)? text,
    TResult Function(VecGroupShape value)? group,
    TResult Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult Function(VecCompoundShape value)? compound,
    required TResult orElse(),
  }) {
    if (polygon != null) {
      return polygon(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$VecPolygonShapeImplToJson(this);
  }
}

abstract class VecPolygonShape extends VecShape {
  const factory VecPolygonShape({
    required final VecShapeData data,
    final int sideCount,
    final double? starDepth,
  }) = _$VecPolygonShapeImpl;
  const VecPolygonShape._() : super._();

  factory VecPolygonShape.fromJson(Map<String, dynamic> json) =
      _$VecPolygonShapeImpl.fromJson;

  @override
  VecShapeData get data;
  int get sideCount;
  double? get starDepth;

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecPolygonShapeImplCopyWith<_$VecPolygonShapeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VecTextShapeImplCopyWith<$Res>
    implements $VecShapeCopyWith<$Res> {
  factory _$$VecTextShapeImplCopyWith(
    _$VecTextShapeImpl value,
    $Res Function(_$VecTextShapeImpl) then,
  ) = __$$VecTextShapeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VecShapeData data,
    String content,
    String fontFamily,
    double fontSize,
    int fontWeight,
    double tracking,
    double leading,
    VecTextAlign alignment,
    String? textOnPathRef,
  });

  @override
  $VecShapeDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$VecTextShapeImplCopyWithImpl<$Res>
    extends _$VecShapeCopyWithImpl<$Res, _$VecTextShapeImpl>
    implements _$$VecTextShapeImplCopyWith<$Res> {
  __$$VecTextShapeImplCopyWithImpl(
    _$VecTextShapeImpl _value,
    $Res Function(_$VecTextShapeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? content = null,
    Object? fontFamily = null,
    Object? fontSize = null,
    Object? fontWeight = null,
    Object? tracking = null,
    Object? leading = null,
    Object? alignment = null,
    Object? textOnPathRef = freezed,
  }) {
    return _then(
      _$VecTextShapeImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as VecShapeData,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        fontFamily: null == fontFamily
            ? _value.fontFamily
            : fontFamily // ignore: cast_nullable_to_non_nullable
                  as String,
        fontSize: null == fontSize
            ? _value.fontSize
            : fontSize // ignore: cast_nullable_to_non_nullable
                  as double,
        fontWeight: null == fontWeight
            ? _value.fontWeight
            : fontWeight // ignore: cast_nullable_to_non_nullable
                  as int,
        tracking: null == tracking
            ? _value.tracking
            : tracking // ignore: cast_nullable_to_non_nullable
                  as double,
        leading: null == leading
            ? _value.leading
            : leading // ignore: cast_nullable_to_non_nullable
                  as double,
        alignment: null == alignment
            ? _value.alignment
            : alignment // ignore: cast_nullable_to_non_nullable
                  as VecTextAlign,
        textOnPathRef: freezed == textOnPathRef
            ? _value.textOnPathRef
            : textOnPathRef // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecTextShapeImpl extends VecTextShape {
  const _$VecTextShapeImpl({
    required this.data,
    required this.content,
    this.fontFamily = 'Inter',
    this.fontSize = 16,
    this.fontWeight = 400,
    this.tracking = 0,
    this.leading = 1.2,
    this.alignment = VecTextAlign.left,
    this.textOnPathRef,
    final String? $type,
  }) : $type = $type ?? 'text',
       super._();

  factory _$VecTextShapeImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecTextShapeImplFromJson(json);

  @override
  final VecShapeData data;
  @override
  final String content;
  @override
  @JsonKey()
  final String fontFamily;
  @override
  @JsonKey()
  final double fontSize;
  @override
  @JsonKey()
  final int fontWeight;
  @override
  @JsonKey()
  final double tracking;
  @override
  @JsonKey()
  final double leading;
  @override
  @JsonKey()
  final VecTextAlign alignment;
  @override
  final String? textOnPathRef;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'VecShape.text(data: $data, content: $content, fontFamily: $fontFamily, fontSize: $fontSize, fontWeight: $fontWeight, tracking: $tracking, leading: $leading, alignment: $alignment, textOnPathRef: $textOnPathRef)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecTextShapeImpl &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.fontFamily, fontFamily) ||
                other.fontFamily == fontFamily) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.fontWeight, fontWeight) ||
                other.fontWeight == fontWeight) &&
            (identical(other.tracking, tracking) ||
                other.tracking == tracking) &&
            (identical(other.leading, leading) || other.leading == leading) &&
            (identical(other.alignment, alignment) ||
                other.alignment == alignment) &&
            (identical(other.textOnPathRef, textOnPathRef) ||
                other.textOnPathRef == textOnPathRef));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    data,
    content,
    fontFamily,
    fontSize,
    fontWeight,
    tracking,
    leading,
    alignment,
    textOnPathRef,
  );

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecTextShapeImplCopyWith<_$VecTextShapeImpl> get copyWith =>
      __$$VecTextShapeImplCopyWithImpl<_$VecTextShapeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )
    path,
    required TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )
    rectangle,
    required TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )
    ellipse,
    required TResult Function(
      VecShapeData data,
      int sideCount,
      double? starDepth,
    )
    polygon,
    required TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )
    text,
    required TResult Function(VecShapeData data, List<VecShape> children) group,
    required TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )
    symbolInstance,
    required TResult Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )
    compound,
  }) {
    return text(
      data,
      content,
      fontFamily,
      fontSize,
      fontWeight,
      tracking,
      leading,
      alignment,
      textOnPathRef,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )?
    path,
    TResult? Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult? Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult? Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult? Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult? Function(VecShapeData data, List<VecShape> children)? group,
    TResult? Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult? Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )?
    compound,
  }) {
    return text?.call(
      data,
      content,
      fontFamily,
      fontSize,
      fontWeight,
      tracking,
      leading,
      alignment,
      textOnPathRef,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VecShapeData data, List<VecPathNode> nodes, bool isClosed)?
    path,
    TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult Function(VecShapeData data, List<VecShape> children)? group,
    TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult Function(VecShapeData data, PathfinderOp op, List<VecShape> inputs)?
    compound,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(
        data,
        content,
        fontFamily,
        fontSize,
        fontWeight,
        tracking,
        leading,
        alignment,
        textOnPathRef,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VecPathShape value) path,
    required TResult Function(VecRectangleShape value) rectangle,
    required TResult Function(VecEllipseShape value) ellipse,
    required TResult Function(VecPolygonShape value) polygon,
    required TResult Function(VecTextShape value) text,
    required TResult Function(VecGroupShape value) group,
    required TResult Function(VecSymbolInstanceShape value) symbolInstance,
    required TResult Function(VecCompoundShape value) compound,
  }) {
    return text(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VecPathShape value)? path,
    TResult? Function(VecRectangleShape value)? rectangle,
    TResult? Function(VecEllipseShape value)? ellipse,
    TResult? Function(VecPolygonShape value)? polygon,
    TResult? Function(VecTextShape value)? text,
    TResult? Function(VecGroupShape value)? group,
    TResult? Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult? Function(VecCompoundShape value)? compound,
  }) {
    return text?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VecPathShape value)? path,
    TResult Function(VecRectangleShape value)? rectangle,
    TResult Function(VecEllipseShape value)? ellipse,
    TResult Function(VecPolygonShape value)? polygon,
    TResult Function(VecTextShape value)? text,
    TResult Function(VecGroupShape value)? group,
    TResult Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult Function(VecCompoundShape value)? compound,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$VecTextShapeImplToJson(this);
  }
}

abstract class VecTextShape extends VecShape {
  const factory VecTextShape({
    required final VecShapeData data,
    required final String content,
    final String fontFamily,
    final double fontSize,
    final int fontWeight,
    final double tracking,
    final double leading,
    final VecTextAlign alignment,
    final String? textOnPathRef,
  }) = _$VecTextShapeImpl;
  const VecTextShape._() : super._();

  factory VecTextShape.fromJson(Map<String, dynamic> json) =
      _$VecTextShapeImpl.fromJson;

  @override
  VecShapeData get data;
  String get content;
  String get fontFamily;
  double get fontSize;
  int get fontWeight;
  double get tracking;
  double get leading;
  VecTextAlign get alignment;
  String? get textOnPathRef;

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecTextShapeImplCopyWith<_$VecTextShapeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VecGroupShapeImplCopyWith<$Res>
    implements $VecShapeCopyWith<$Res> {
  factory _$$VecGroupShapeImplCopyWith(
    _$VecGroupShapeImpl value,
    $Res Function(_$VecGroupShapeImpl) then,
  ) = __$$VecGroupShapeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({VecShapeData data, List<VecShape> children});

  @override
  $VecShapeDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$VecGroupShapeImplCopyWithImpl<$Res>
    extends _$VecShapeCopyWithImpl<$Res, _$VecGroupShapeImpl>
    implements _$$VecGroupShapeImplCopyWith<$Res> {
  __$$VecGroupShapeImplCopyWithImpl(
    _$VecGroupShapeImpl _value,
    $Res Function(_$VecGroupShapeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? children = null}) {
    return _then(
      _$VecGroupShapeImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as VecShapeData,
        children: null == children
            ? _value._children
            : children // ignore: cast_nullable_to_non_nullable
                  as List<VecShape>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecGroupShapeImpl extends VecGroupShape {
  const _$VecGroupShapeImpl({
    required this.data,
    required final List<VecShape> children,
    final String? $type,
  }) : _children = children,
       $type = $type ?? 'group',
       super._();

  factory _$VecGroupShapeImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecGroupShapeImplFromJson(json);

  @override
  final VecShapeData data;
  final List<VecShape> _children;
  @override
  List<VecShape> get children {
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_children);
  }

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'VecShape.group(data: $data, children: $children)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecGroupShapeImpl &&
            (identical(other.data, data) || other.data == data) &&
            const DeepCollectionEquality().equals(other._children, _children));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    data,
    const DeepCollectionEquality().hash(_children),
  );

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecGroupShapeImplCopyWith<_$VecGroupShapeImpl> get copyWith =>
      __$$VecGroupShapeImplCopyWithImpl<_$VecGroupShapeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )
    path,
    required TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )
    rectangle,
    required TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )
    ellipse,
    required TResult Function(
      VecShapeData data,
      int sideCount,
      double? starDepth,
    )
    polygon,
    required TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )
    text,
    required TResult Function(VecShapeData data, List<VecShape> children) group,
    required TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )
    symbolInstance,
    required TResult Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )
    compound,
  }) {
    return group(data, children);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )?
    path,
    TResult? Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult? Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult? Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult? Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult? Function(VecShapeData data, List<VecShape> children)? group,
    TResult? Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult? Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )?
    compound,
  }) {
    return group?.call(data, children);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VecShapeData data, List<VecPathNode> nodes, bool isClosed)?
    path,
    TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult Function(VecShapeData data, List<VecShape> children)? group,
    TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult Function(VecShapeData data, PathfinderOp op, List<VecShape> inputs)?
    compound,
    required TResult orElse(),
  }) {
    if (group != null) {
      return group(data, children);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VecPathShape value) path,
    required TResult Function(VecRectangleShape value) rectangle,
    required TResult Function(VecEllipseShape value) ellipse,
    required TResult Function(VecPolygonShape value) polygon,
    required TResult Function(VecTextShape value) text,
    required TResult Function(VecGroupShape value) group,
    required TResult Function(VecSymbolInstanceShape value) symbolInstance,
    required TResult Function(VecCompoundShape value) compound,
  }) {
    return group(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VecPathShape value)? path,
    TResult? Function(VecRectangleShape value)? rectangle,
    TResult? Function(VecEllipseShape value)? ellipse,
    TResult? Function(VecPolygonShape value)? polygon,
    TResult? Function(VecTextShape value)? text,
    TResult? Function(VecGroupShape value)? group,
    TResult? Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult? Function(VecCompoundShape value)? compound,
  }) {
    return group?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VecPathShape value)? path,
    TResult Function(VecRectangleShape value)? rectangle,
    TResult Function(VecEllipseShape value)? ellipse,
    TResult Function(VecPolygonShape value)? polygon,
    TResult Function(VecTextShape value)? text,
    TResult Function(VecGroupShape value)? group,
    TResult Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult Function(VecCompoundShape value)? compound,
    required TResult orElse(),
  }) {
    if (group != null) {
      return group(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$VecGroupShapeImplToJson(this);
  }
}

abstract class VecGroupShape extends VecShape {
  const factory VecGroupShape({
    required final VecShapeData data,
    required final List<VecShape> children,
  }) = _$VecGroupShapeImpl;
  const VecGroupShape._() : super._();

  factory VecGroupShape.fromJson(Map<String, dynamic> json) =
      _$VecGroupShapeImpl.fromJson;

  @override
  VecShapeData get data;
  List<VecShape> get children;

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecGroupShapeImplCopyWith<_$VecGroupShapeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VecSymbolInstanceShapeImplCopyWith<$Res>
    implements $VecShapeCopyWith<$Res> {
  factory _$$VecSymbolInstanceShapeImplCopyWith(
    _$VecSymbolInstanceShapeImpl value,
    $Res Function(_$VecSymbolInstanceShapeImpl) then,
  ) = __$$VecSymbolInstanceShapeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VecShapeData data,
    String symbolId,
    VecColor? colorTint,
    double tintAmount,
    double alphaOverride,
    VecLoopType loopType,
    int firstFrame,
  });

  @override
  $VecShapeDataCopyWith<$Res> get data;
  $VecColorCopyWith<$Res>? get colorTint;
}

/// @nodoc
class __$$VecSymbolInstanceShapeImplCopyWithImpl<$Res>
    extends _$VecShapeCopyWithImpl<$Res, _$VecSymbolInstanceShapeImpl>
    implements _$$VecSymbolInstanceShapeImplCopyWith<$Res> {
  __$$VecSymbolInstanceShapeImplCopyWithImpl(
    _$VecSymbolInstanceShapeImpl _value,
    $Res Function(_$VecSymbolInstanceShapeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? symbolId = null,
    Object? colorTint = freezed,
    Object? tintAmount = null,
    Object? alphaOverride = null,
    Object? loopType = null,
    Object? firstFrame = null,
  }) {
    return _then(
      _$VecSymbolInstanceShapeImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as VecShapeData,
        symbolId: null == symbolId
            ? _value.symbolId
            : symbolId // ignore: cast_nullable_to_non_nullable
                  as String,
        colorTint: freezed == colorTint
            ? _value.colorTint
            : colorTint // ignore: cast_nullable_to_non_nullable
                  as VecColor?,
        tintAmount: null == tintAmount
            ? _value.tintAmount
            : tintAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        alphaOverride: null == alphaOverride
            ? _value.alphaOverride
            : alphaOverride // ignore: cast_nullable_to_non_nullable
                  as double,
        loopType: null == loopType
            ? _value.loopType
            : loopType // ignore: cast_nullable_to_non_nullable
                  as VecLoopType,
        firstFrame: null == firstFrame
            ? _value.firstFrame
            : firstFrame // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VecColorCopyWith<$Res>? get colorTint {
    if (_value.colorTint == null) {
      return null;
    }

    return $VecColorCopyWith<$Res>(_value.colorTint!, (value) {
      return _then(_value.copyWith(colorTint: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$VecSymbolInstanceShapeImpl extends VecSymbolInstanceShape {
  const _$VecSymbolInstanceShapeImpl({
    required this.data,
    required this.symbolId,
    this.colorTint,
    this.tintAmount = 0,
    this.alphaOverride = 1.0,
    this.loopType = VecLoopType.loop,
    this.firstFrame = 0,
    final String? $type,
  }) : $type = $type ?? 'symbolInstance',
       super._();

  factory _$VecSymbolInstanceShapeImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecSymbolInstanceShapeImplFromJson(json);

  @override
  final VecShapeData data;
  @override
  final String symbolId;
  @override
  final VecColor? colorTint;
  @override
  @JsonKey()
  final double tintAmount;
  @override
  @JsonKey()
  final double alphaOverride;
  @override
  @JsonKey()
  final VecLoopType loopType;
  @override
  @JsonKey()
  final int firstFrame;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'VecShape.symbolInstance(data: $data, symbolId: $symbolId, colorTint: $colorTint, tintAmount: $tintAmount, alphaOverride: $alphaOverride, loopType: $loopType, firstFrame: $firstFrame)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecSymbolInstanceShapeImpl &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.symbolId, symbolId) ||
                other.symbolId == symbolId) &&
            (identical(other.colorTint, colorTint) ||
                other.colorTint == colorTint) &&
            (identical(other.tintAmount, tintAmount) ||
                other.tintAmount == tintAmount) &&
            (identical(other.alphaOverride, alphaOverride) ||
                other.alphaOverride == alphaOverride) &&
            (identical(other.loopType, loopType) ||
                other.loopType == loopType) &&
            (identical(other.firstFrame, firstFrame) ||
                other.firstFrame == firstFrame));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    data,
    symbolId,
    colorTint,
    tintAmount,
    alphaOverride,
    loopType,
    firstFrame,
  );

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecSymbolInstanceShapeImplCopyWith<_$VecSymbolInstanceShapeImpl>
  get copyWith =>
      __$$VecSymbolInstanceShapeImplCopyWithImpl<_$VecSymbolInstanceShapeImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )
    path,
    required TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )
    rectangle,
    required TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )
    ellipse,
    required TResult Function(
      VecShapeData data,
      int sideCount,
      double? starDepth,
    )
    polygon,
    required TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )
    text,
    required TResult Function(VecShapeData data, List<VecShape> children) group,
    required TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )
    symbolInstance,
    required TResult Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )
    compound,
  }) {
    return symbolInstance(
      data,
      symbolId,
      colorTint,
      tintAmount,
      alphaOverride,
      loopType,
      firstFrame,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )?
    path,
    TResult? Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult? Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult? Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult? Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult? Function(VecShapeData data, List<VecShape> children)? group,
    TResult? Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult? Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )?
    compound,
  }) {
    return symbolInstance?.call(
      data,
      symbolId,
      colorTint,
      tintAmount,
      alphaOverride,
      loopType,
      firstFrame,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VecShapeData data, List<VecPathNode> nodes, bool isClosed)?
    path,
    TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult Function(VecShapeData data, List<VecShape> children)? group,
    TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult Function(VecShapeData data, PathfinderOp op, List<VecShape> inputs)?
    compound,
    required TResult orElse(),
  }) {
    if (symbolInstance != null) {
      return symbolInstance(
        data,
        symbolId,
        colorTint,
        tintAmount,
        alphaOverride,
        loopType,
        firstFrame,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VecPathShape value) path,
    required TResult Function(VecRectangleShape value) rectangle,
    required TResult Function(VecEllipseShape value) ellipse,
    required TResult Function(VecPolygonShape value) polygon,
    required TResult Function(VecTextShape value) text,
    required TResult Function(VecGroupShape value) group,
    required TResult Function(VecSymbolInstanceShape value) symbolInstance,
    required TResult Function(VecCompoundShape value) compound,
  }) {
    return symbolInstance(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VecPathShape value)? path,
    TResult? Function(VecRectangleShape value)? rectangle,
    TResult? Function(VecEllipseShape value)? ellipse,
    TResult? Function(VecPolygonShape value)? polygon,
    TResult? Function(VecTextShape value)? text,
    TResult? Function(VecGroupShape value)? group,
    TResult? Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult? Function(VecCompoundShape value)? compound,
  }) {
    return symbolInstance?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VecPathShape value)? path,
    TResult Function(VecRectangleShape value)? rectangle,
    TResult Function(VecEllipseShape value)? ellipse,
    TResult Function(VecPolygonShape value)? polygon,
    TResult Function(VecTextShape value)? text,
    TResult Function(VecGroupShape value)? group,
    TResult Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult Function(VecCompoundShape value)? compound,
    required TResult orElse(),
  }) {
    if (symbolInstance != null) {
      return symbolInstance(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$VecSymbolInstanceShapeImplToJson(this);
  }
}

abstract class VecSymbolInstanceShape extends VecShape {
  const factory VecSymbolInstanceShape({
    required final VecShapeData data,
    required final String symbolId,
    final VecColor? colorTint,
    final double tintAmount,
    final double alphaOverride,
    final VecLoopType loopType,
    final int firstFrame,
  }) = _$VecSymbolInstanceShapeImpl;
  const VecSymbolInstanceShape._() : super._();

  factory VecSymbolInstanceShape.fromJson(Map<String, dynamic> json) =
      _$VecSymbolInstanceShapeImpl.fromJson;

  @override
  VecShapeData get data;
  String get symbolId;
  VecColor? get colorTint;
  double get tintAmount;
  double get alphaOverride;
  VecLoopType get loopType;
  int get firstFrame;

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecSymbolInstanceShapeImplCopyWith<_$VecSymbolInstanceShapeImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VecCompoundShapeImplCopyWith<$Res>
    implements $VecShapeCopyWith<$Res> {
  factory _$$VecCompoundShapeImplCopyWith(
    _$VecCompoundShapeImpl value,
    $Res Function(_$VecCompoundShapeImpl) then,
  ) = __$$VecCompoundShapeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({VecShapeData data, PathfinderOp op, List<VecShape> inputs});

  @override
  $VecShapeDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$VecCompoundShapeImplCopyWithImpl<$Res>
    extends _$VecShapeCopyWithImpl<$Res, _$VecCompoundShapeImpl>
    implements _$$VecCompoundShapeImplCopyWith<$Res> {
  __$$VecCompoundShapeImplCopyWithImpl(
    _$VecCompoundShapeImpl _value,
    $Res Function(_$VecCompoundShapeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? op = null, Object? inputs = null}) {
    return _then(
      _$VecCompoundShapeImpl(
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as VecShapeData,
        op: null == op
            ? _value.op
            : op // ignore: cast_nullable_to_non_nullable
                  as PathfinderOp,
        inputs: null == inputs
            ? _value._inputs
            : inputs // ignore: cast_nullable_to_non_nullable
                  as List<VecShape>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecCompoundShapeImpl extends VecCompoundShape {
  const _$VecCompoundShapeImpl({
    required this.data,
    required this.op,
    required final List<VecShape> inputs,
    final String? $type,
  }) : _inputs = inputs,
       $type = $type ?? 'compound',
       super._();

  factory _$VecCompoundShapeImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecCompoundShapeImplFromJson(json);

  @override
  final VecShapeData data;
  @override
  final PathfinderOp op;
  final List<VecShape> _inputs;
  @override
  List<VecShape> get inputs {
    if (_inputs is EqualUnmodifiableListView) return _inputs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_inputs);
  }

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'VecShape.compound(data: $data, op: $op, inputs: $inputs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecCompoundShapeImpl &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.op, op) || other.op == op) &&
            const DeepCollectionEquality().equals(other._inputs, _inputs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    data,
    op,
    const DeepCollectionEquality().hash(_inputs),
  );

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecCompoundShapeImplCopyWith<_$VecCompoundShapeImpl> get copyWith =>
      __$$VecCompoundShapeImplCopyWithImpl<_$VecCompoundShapeImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )
    path,
    required TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )
    rectangle,
    required TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )
    ellipse,
    required TResult Function(
      VecShapeData data,
      int sideCount,
      double? starDepth,
    )
    polygon,
    required TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )
    text,
    required TResult Function(VecShapeData data, List<VecShape> children) group,
    required TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )
    symbolInstance,
    required TResult Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )
    compound,
  }) {
    return compound(data, op, inputs);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      VecShapeData data,
      List<VecPathNode> nodes,
      bool isClosed,
    )?
    path,
    TResult? Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult? Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult? Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult? Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult? Function(VecShapeData data, List<VecShape> children)? group,
    TResult? Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult? Function(
      VecShapeData data,
      PathfinderOp op,
      List<VecShape> inputs,
    )?
    compound,
  }) {
    return compound?.call(data, op, inputs);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(VecShapeData data, List<VecPathNode> nodes, bool isClosed)?
    path,
    TResult Function(
      VecShapeData data,
      List<double> cornerRadii,
      VecCornerStyle cornerStyle,
    )?
    rectangle,
    TResult Function(
      VecShapeData data,
      double startAngle,
      double endAngle,
      double innerRadius,
    )?
    ellipse,
    TResult Function(VecShapeData data, int sideCount, double? starDepth)?
    polygon,
    TResult Function(
      VecShapeData data,
      String content,
      String fontFamily,
      double fontSize,
      int fontWeight,
      double tracking,
      double leading,
      VecTextAlign alignment,
      String? textOnPathRef,
    )?
    text,
    TResult Function(VecShapeData data, List<VecShape> children)? group,
    TResult Function(
      VecShapeData data,
      String symbolId,
      VecColor? colorTint,
      double tintAmount,
      double alphaOverride,
      VecLoopType loopType,
      int firstFrame,
    )?
    symbolInstance,
    TResult Function(VecShapeData data, PathfinderOp op, List<VecShape> inputs)?
    compound,
    required TResult orElse(),
  }) {
    if (compound != null) {
      return compound(data, op, inputs);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VecPathShape value) path,
    required TResult Function(VecRectangleShape value) rectangle,
    required TResult Function(VecEllipseShape value) ellipse,
    required TResult Function(VecPolygonShape value) polygon,
    required TResult Function(VecTextShape value) text,
    required TResult Function(VecGroupShape value) group,
    required TResult Function(VecSymbolInstanceShape value) symbolInstance,
    required TResult Function(VecCompoundShape value) compound,
  }) {
    return compound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VecPathShape value)? path,
    TResult? Function(VecRectangleShape value)? rectangle,
    TResult? Function(VecEllipseShape value)? ellipse,
    TResult? Function(VecPolygonShape value)? polygon,
    TResult? Function(VecTextShape value)? text,
    TResult? Function(VecGroupShape value)? group,
    TResult? Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult? Function(VecCompoundShape value)? compound,
  }) {
    return compound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VecPathShape value)? path,
    TResult Function(VecRectangleShape value)? rectangle,
    TResult Function(VecEllipseShape value)? ellipse,
    TResult Function(VecPolygonShape value)? polygon,
    TResult Function(VecTextShape value)? text,
    TResult Function(VecGroupShape value)? group,
    TResult Function(VecSymbolInstanceShape value)? symbolInstance,
    TResult Function(VecCompoundShape value)? compound,
    required TResult orElse(),
  }) {
    if (compound != null) {
      return compound(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$VecCompoundShapeImplToJson(this);
  }
}

abstract class VecCompoundShape extends VecShape {
  const factory VecCompoundShape({
    required final VecShapeData data,
    required final PathfinderOp op,
    required final List<VecShape> inputs,
  }) = _$VecCompoundShapeImpl;
  const VecCompoundShape._() : super._();

  factory VecCompoundShape.fromJson(Map<String, dynamic> json) =
      _$VecCompoundShapeImpl.fromJson;

  @override
  VecShapeData get data;
  PathfinderOp get op;
  List<VecShape> get inputs;

  /// Create a copy of VecShape
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecCompoundShapeImplCopyWith<_$VecCompoundShapeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
