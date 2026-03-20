import 'package:freezed_annotation/freezed_annotation.dart';

import 'vec_frame_label.dart';
import 'vec_motion_path.dart';
import 'vec_track.dart';

part 'vec_timeline.freezed.dart';
part 'vec_timeline.g.dart';

enum VecLoopType { loop, playOnce, pingPong }

@freezed
class VecTimeline with _$VecTimeline {
  const factory VecTimeline({
    required int duration,
    @Default(0) int inPoint,
    int? outPoint,
    @Default(VecLoopType.loop) VecLoopType loopType,
    @Default([]) List<VecTrack> tracks,
    @Default([]) List<VecFrameLabel> frameLabels,
    @Default([]) List<VecMotionPath> motionPaths,
  }) = _VecTimeline;

  factory VecTimeline.fromJson(Map<String, dynamic> json) =>
      _$VecTimelineFromJson(json);
}
