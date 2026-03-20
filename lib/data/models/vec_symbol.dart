import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_layer.dart';
import 'vec_point.dart';
import 'vec_timeline.dart';

part 'vec_symbol.freezed.dart';
part 'vec_symbol.g.dart';

enum VecSymbolType { graphic, movieClip, button }

@freezed
class VecSymbol with _$VecSymbol {
  const factory VecSymbol({
    required String id,
    required String name,
    @Default(VecSymbolType.graphic) VecSymbolType type,
    VecPoint? registrationPoint,
    required List<VecLayer> layers,
    required VecTimeline timeline,
  }) = _VecSymbol;

  factory VecSymbol.fromJson(Map<String, dynamic> json) =>
      _$VecSymbolFromJson(json);
}
