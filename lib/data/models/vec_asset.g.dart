// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vec_asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VecAssetImpl _$$VecAssetImplFromJson(Map<String, dynamic> json) =>
    _$VecAssetImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$VecAssetTypeEnumMap, json['type']),
      path: json['path'] as String,
      mimeType: json['mimeType'] as String?,
      dataBase64: json['dataBase64'] as String?,
    );

Map<String, dynamic> _$$VecAssetImplToJson(_$VecAssetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$VecAssetTypeEnumMap[instance.type]!,
      'path': instance.path,
      'mimeType': instance.mimeType,
      'dataBase64': instance.dataBase64,
    };

const _$VecAssetTypeEnumMap = {
  VecAssetType.image: 'image',
  VecAssetType.font: 'font',
};
