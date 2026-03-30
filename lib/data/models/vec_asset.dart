import 'package:freezed_annotation/freezed_annotation.dart';

part 'vec_asset.freezed.dart';
part 'vec_asset.g.dart';

enum VecAssetType { image, font }

@freezed
class VecAsset with _$VecAsset {
  const factory VecAsset({
    required String id,
    required String name,
    required VecAssetType type,
    required String path,
    String? mimeType,
    /// Base64-encoded raw bytes for embedded assets (images, etc.).
    String? dataBase64,
  }) = _VecAsset;

  factory VecAsset.fromJson(Map<String, dynamic> json) =>
      _$VecAssetFromJson(json);
}
