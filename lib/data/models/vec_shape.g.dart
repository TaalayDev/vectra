// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_shape.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecShapeDataImpl _$$VecShapeDataImplFromJson(Map<String, dynamic> json) =>
    _$VecShapeDataImpl(
      id: json['id'] as String,
      transform: VecTransform.fromJson(
        json['transform'] as Map<String, dynamic>,
      ),
      fills:
          (json['fills'] as List<dynamic>?)
              ?.map((e) => VecFill.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      strokes:
          (json['strokes'] as List<dynamic>?)
              ?.map((e) => VecStroke.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      blendMode:
          $enumDecodeNullable(_$VecBlendModeEnumMap, json['blendMode']) ??
          VecBlendMode.normal,
      clipMaskId: json['clipMaskId'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$VecShapeDataImplToJson(_$VecShapeDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transform': instance.transform,
      'fills': instance.fills,
      'strokes': instance.strokes,
      'opacity': instance.opacity,
      'blendMode': _$VecBlendModeEnumMap[instance.blendMode]!,
      'clipMaskId': instance.clipMaskId,
      'name': instance.name,
    };

const _$VecBlendModeEnumMap = {
  VecBlendMode.normal: 'normal',
  VecBlendMode.multiply: 'multiply',
  VecBlendMode.screen: 'screen',
  VecBlendMode.overlay: 'overlay',
  VecBlendMode.darken: 'darken',
  VecBlendMode.lighten: 'lighten',
  VecBlendMode.colorDodge: 'colorDodge',
  VecBlendMode.colorBurn: 'colorBurn',
  VecBlendMode.hardLight: 'hardLight',
  VecBlendMode.softLight: 'softLight',
  VecBlendMode.difference: 'difference',
  VecBlendMode.exclusion: 'exclusion',
  VecBlendMode.hue: 'hue',
  VecBlendMode.saturation: 'saturation',
  VecBlendMode.color: 'color',
  VecBlendMode.luminosity: 'luminosity',
};

_$VecPathShapeImpl _$$VecPathShapeImplFromJson(Map<String, dynamic> json) =>
    _$VecPathShapeImpl(
      data: VecShapeData.fromJson(json['data'] as Map<String, dynamic>),
      nodes: (json['nodes'] as List<dynamic>)
          .map((e) => VecPathNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      isClosed: json['isClosed'] as bool? ?? false,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$VecPathShapeImplToJson(_$VecPathShapeImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
      'nodes': instance.nodes,
      'isClosed': instance.isClosed,
      'type': instance.$type,
    };

_$VecRectangleShapeImpl _$$VecRectangleShapeImplFromJson(
  Map<String, dynamic> json,
) => _$VecRectangleShapeImpl(
  data: VecShapeData.fromJson(json['data'] as Map<String, dynamic>),
  cornerRadii:
      (json['cornerRadii'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      const [0, 0, 0, 0],
  cornerStyle:
      $enumDecodeNullable(_$VecCornerStyleEnumMap, json['cornerStyle']) ??
      VecCornerStyle.round,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$VecRectangleShapeImplToJson(
  _$VecRectangleShapeImpl instance,
) => <String, dynamic>{
  'data': instance.data,
  'cornerRadii': instance.cornerRadii,
  'cornerStyle': _$VecCornerStyleEnumMap[instance.cornerStyle]!,
  'type': instance.$type,
};

const _$VecCornerStyleEnumMap = {
  VecCornerStyle.round: 'round',
  VecCornerStyle.inverted: 'inverted',
  VecCornerStyle.chamfer: 'chamfer',
};

_$VecEllipseShapeImpl _$$VecEllipseShapeImplFromJson(
  Map<String, dynamic> json,
) => _$VecEllipseShapeImpl(
  data: VecShapeData.fromJson(json['data'] as Map<String, dynamic>),
  startAngle: (json['startAngle'] as num?)?.toDouble() ?? 0,
  endAngle: (json['endAngle'] as num?)?.toDouble() ?? 360,
  innerRadius: (json['innerRadius'] as num?)?.toDouble() ?? 0,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$VecEllipseShapeImplToJson(
  _$VecEllipseShapeImpl instance,
) => <String, dynamic>{
  'data': instance.data,
  'startAngle': instance.startAngle,
  'endAngle': instance.endAngle,
  'innerRadius': instance.innerRadius,
  'type': instance.$type,
};

_$VecPolygonShapeImpl _$$VecPolygonShapeImplFromJson(
  Map<String, dynamic> json,
) => _$VecPolygonShapeImpl(
  data: VecShapeData.fromJson(json['data'] as Map<String, dynamic>),
  sideCount: (json['sideCount'] as num?)?.toInt() ?? 6,
  starDepth: (json['starDepth'] as num?)?.toDouble(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$VecPolygonShapeImplToJson(
  _$VecPolygonShapeImpl instance,
) => <String, dynamic>{
  'data': instance.data,
  'sideCount': instance.sideCount,
  'starDepth': instance.starDepth,
  'type': instance.$type,
};

_$VecTextShapeImpl _$$VecTextShapeImplFromJson(Map<String, dynamic> json) =>
    _$VecTextShapeImpl(
      data: VecShapeData.fromJson(json['data'] as Map<String, dynamic>),
      content: json['content'] as String,
      fontFamily: json['fontFamily'] as String? ?? 'Inter',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16,
      fontWeight: (json['fontWeight'] as num?)?.toInt() ?? 400,
      tracking: (json['tracking'] as num?)?.toDouble() ?? 0,
      leading: (json['leading'] as num?)?.toDouble() ?? 1.2,
      alignment:
          $enumDecodeNullable(_$VecTextAlignEnumMap, json['alignment']) ??
          VecTextAlign.left,
      textOnPathRef: json['textOnPathRef'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$VecTextShapeImplToJson(_$VecTextShapeImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
      'content': instance.content,
      'fontFamily': instance.fontFamily,
      'fontSize': instance.fontSize,
      'fontWeight': instance.fontWeight,
      'tracking': instance.tracking,
      'leading': instance.leading,
      'alignment': _$VecTextAlignEnumMap[instance.alignment]!,
      'textOnPathRef': instance.textOnPathRef,
      'type': instance.$type,
    };

const _$VecTextAlignEnumMap = {
  VecTextAlign.left: 'left',
  VecTextAlign.center: 'center',
  VecTextAlign.right: 'right',
  VecTextAlign.justify: 'justify',
};

_$VecGroupShapeImpl _$$VecGroupShapeImplFromJson(Map<String, dynamic> json) =>
    _$VecGroupShapeImpl(
      data: VecShapeData.fromJson(json['data'] as Map<String, dynamic>),
      children: (json['children'] as List<dynamic>)
          .map((e) => VecShape.fromJson(e as Map<String, dynamic>))
          .toList(),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$VecGroupShapeImplToJson(_$VecGroupShapeImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
      'children': instance.children,
      'type': instance.$type,
    };

_$VecSymbolInstanceShapeImpl _$$VecSymbolInstanceShapeImplFromJson(
  Map<String, dynamic> json,
) => _$VecSymbolInstanceShapeImpl(
  data: VecShapeData.fromJson(json['data'] as Map<String, dynamic>),
  symbolId: json['symbolId'] as String,
  colorTint: json['colorTint'] == null
      ? null
      : VecColor.fromJson(json['colorTint'] as Map<String, dynamic>),
  tintAmount: (json['tintAmount'] as num?)?.toDouble() ?? 0,
  alphaOverride: (json['alphaOverride'] as num?)?.toDouble() ?? 1.0,
  loopType:
      $enumDecodeNullable(_$VecLoopTypeEnumMap, json['loopType']) ??
      VecLoopType.loop,
  firstFrame: (json['firstFrame'] as num?)?.toInt() ?? 0,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$VecSymbolInstanceShapeImplToJson(
  _$VecSymbolInstanceShapeImpl instance,
) => <String, dynamic>{
  'data': instance.data,
  'symbolId': instance.symbolId,
  'colorTint': instance.colorTint,
  'tintAmount': instance.tintAmount,
  'alphaOverride': instance.alphaOverride,
  'loopType': _$VecLoopTypeEnumMap[instance.loopType]!,
  'firstFrame': instance.firstFrame,
  'type': instance.$type,
};

const _$VecLoopTypeEnumMap = {
  VecLoopType.loop: 'loop',
  VecLoopType.playOnce: 'playOnce',
  VecLoopType.pingPong: 'pingPong',
};

_$VecCompoundShapeImpl _$$VecCompoundShapeImplFromJson(
  Map<String, dynamic> json,
) => _$VecCompoundShapeImpl(
  data: VecShapeData.fromJson(json['data'] as Map<String, dynamic>),
  op: $enumDecode(_$PathfinderOpEnumMap, json['op']),
  inputs: (json['inputs'] as List<dynamic>)
      .map((e) => VecShape.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$VecCompoundShapeImplToJson(
  _$VecCompoundShapeImpl instance,
) => <String, dynamic>{
  'data': instance.data,
  'op': _$PathfinderOpEnumMap[instance.op]!,
  'inputs': instance.inputs,
  'type': instance.$type,
};

const _$PathfinderOpEnumMap = {
  PathfinderOp.unite: 'unite',
  PathfinderOp.minusFront: 'minusFront',
  PathfinderOp.intersect: 'intersect',
  PathfinderOp.exclude: 'exclude',
  PathfinderOp.divide: 'divide',
  PathfinderOp.trim: 'trim',
  PathfinderOp.outline: 'outline',
};

_$VecImageShapeImpl _$$VecImageShapeImplFromJson(Map<String, dynamic> json) =>
    _$VecImageShapeImpl(
      data: VecShapeData.fromJson(json['data'] as Map<String, dynamic>),
      assetId: json['assetId'] as String,
      fit:
          $enumDecodeNullable(_$VecImageFitEnumMap, json['fit']) ??
          VecImageFit.contain,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$VecImageShapeImplToJson(_$VecImageShapeImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
      'assetId': instance.assetId,
      'fit': _$VecImageFitEnumMap[instance.fit]!,
      'type': instance.$type,
    };

const _$VecImageFitEnumMap = {
  VecImageFit.contain: 'contain',
  VecImageFit.cover: 'cover',
  VecImageFit.fill: 'fill',
  VecImageFit.none: 'none',
};
