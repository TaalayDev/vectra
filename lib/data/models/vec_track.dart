import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_keyframe.dart';

part 'vec_track.freezed.dart';
part 'vec_track.g.dart';

@freezed
class VecTrack with _$VecTrack {
  const factory VecTrack({
    required String id,
    required String layerId,
    @Default([]) List<VecKeyframe> keyframes,
  }) = _VecTrack;

  factory VecTrack.fromJson(Map<String, dynamic> json) =>
      _$VecTrackFromJson(json);
}
