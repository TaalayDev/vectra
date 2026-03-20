// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_export_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecExportConfigImpl _$$VecExportConfigImplFromJson(
  Map<String, dynamic> json,
) => _$VecExportConfigImpl(
  format:
      $enumDecodeNullable(_$VecExportFormatEnumMap, json['format']) ??
      VecExportFormat.lottie,
  resolutionScale: (json['resolutionScale'] as num?)?.toDouble() ?? 1.0,
  quality: (json['quality'] as num?)?.toInt() ?? 90,
  transparent: json['transparent'] as bool? ?? false,
);

Map<String, dynamic> _$$VecExportConfigImplToJson(
  _$VecExportConfigImpl instance,
) => <String, dynamic>{
  'format': _$VecExportFormatEnumMap[instance.format]!,
  'resolutionScale': instance.resolutionScale,
  'quality': instance.quality,
  'transparent': instance.transparent,
};

const _$VecExportFormatEnumMap = {
  VecExportFormat.svg: 'svg',
  VecExportFormat.animatedSvg: 'animatedSvg',
  VecExportFormat.lottie: 'lottie',
  VecExportFormat.mp4: 'mp4',
  VecExportFormat.png: 'png',
  VecExportFormat.pngSequence: 'pngSequence',
  VecExportFormat.gif: 'gif',
};
