// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecMetaImpl _$$VecMetaImplFromJson(Map<String, dynamic> json) =>
    _$VecMetaImpl(
      name: json['name'] as String,
      version: (json['version'] as num?)?.toInt() ?? 1,
      fps: (json['fps'] as num?)?.toInt() ?? 24,
      stageWidth: (json['stageWidth'] as num?)?.toDouble() ?? 1920,
      stageHeight: (json['stageHeight'] as num?)?.toDouble() ?? 1080,
      backgroundColor: json['backgroundColor'] == null
          ? VecColor.white
          : VecColor.fromJson(json['backgroundColor'] as Map<String, dynamic>),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      modifiedAt: json['modifiedAt'] == null
          ? null
          : DateTime.parse(json['modifiedAt'] as String),
    );

Map<String, dynamic> _$$VecMetaImplToJson(_$VecMetaImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'fps': instance.fps,
      'stageWidth': instance.stageWidth,
      'stageHeight': instance.stageHeight,
      'backgroundColor': instance.backgroundColor,
      'createdAt': instance.createdAt?.toIso8601String(),
      'modifiedAt': instance.modifiedAt?.toIso8601String(),
    };

_$VecDocumentImpl _$$VecDocumentImplFromJson(Map<String, dynamic> json) =>
    _$VecDocumentImpl(
      meta: VecMeta.fromJson(json['meta'] as Map<String, dynamic>),
      symbols:
          (json['symbols'] as List<dynamic>?)
              ?.map((e) => VecSymbol.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      scenes:
          (json['scenes'] as List<dynamic>?)
              ?.map((e) => VecScene.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      assets:
          (json['assets'] as List<dynamic>?)
              ?.map((e) => VecAsset.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$VecDocumentImplToJson(_$VecDocumentImpl instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'symbols': instance.symbols,
      'scenes': instance.scenes,
      'assets': instance.assets,
    };
