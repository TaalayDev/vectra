import 'package:freezed_annotation/freezed_annotation.dart';

part 'vec_frame_label.freezed.dart';
part 'vec_frame_label.g.dart';

@freezed
class VecFrameLabel with _$VecFrameLabel {
  const factory VecFrameLabel({
    required int frame,
    required String label,
  }) = _VecFrameLabel;

  factory VecFrameLabel.fromJson(Map<String, dynamic> json) =>
      _$VecFrameLabelFromJson(json);
}
