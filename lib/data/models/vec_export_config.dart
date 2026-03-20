import 'package:freezed_annotation/freezed_annotation.dart';

part 'vec_export_config.freezed.dart';
part 'vec_export_config.g.dart';

enum VecExportFormat { svg, animatedSvg, lottie, mp4, png, pngSequence, gif }

@freezed
class VecExportConfig with _$VecExportConfig {
  const factory VecExportConfig({
    @Default(VecExportFormat.lottie) VecExportFormat format,
    @Default(1.0) double resolutionScale,
    @Default(90) int quality,
    @Default(false) bool transparent,
  }) = _VecExportConfig;

  factory VecExportConfig.fromJson(Map<String, dynamic> json) =>
      _$VecExportConfigFromJson(json);
}
