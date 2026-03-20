// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_timeline.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecTimeline _$VecTimelineFromJson(Map<String, dynamic> json) {
  return _VecTimeline.fromJson(json);
}

/// @nodoc
mixin _$VecTimeline {
  int get duration => throw _privateConstructorUsedError;
  int get inPoint => throw _privateConstructorUsedError;
  int? get outPoint => throw _privateConstructorUsedError;
  VecLoopType get loopType => throw _privateConstructorUsedError;
  List<VecTrack> get tracks => throw _privateConstructorUsedError;
  List<VecFrameLabel> get frameLabels => throw _privateConstructorUsedError;
  List<VecMotionPath> get motionPaths => throw _privateConstructorUsedError;

  /// Serializes this VecTimeline to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecTimeline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecTimelineCopyWith<VecTimeline> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecTimelineCopyWith<$Res> {
  factory $VecTimelineCopyWith(
    VecTimeline value,
    $Res Function(VecTimeline) then,
  ) = _$VecTimelineCopyWithImpl<$Res, VecTimeline>;
  @useResult
  $Res call({
    int duration,
    int inPoint,
    int? outPoint,
    VecLoopType loopType,
    List<VecTrack> tracks,
    List<VecFrameLabel> frameLabels,
    List<VecMotionPath> motionPaths,
  });
}

/// @nodoc
class _$VecTimelineCopyWithImpl<$Res, $Val extends VecTimeline>
    implements $VecTimelineCopyWith<$Res> {
  _$VecTimelineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecTimeline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? duration = null,
    Object? inPoint = null,
    Object? outPoint = freezed,
    Object? loopType = null,
    Object? tracks = null,
    Object? frameLabels = null,
    Object? motionPaths = null,
  }) {
    return _then(
      _value.copyWith(
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            inPoint: null == inPoint
                ? _value.inPoint
                : inPoint // ignore: cast_nullable_to_non_nullable
                      as int,
            outPoint: freezed == outPoint
                ? _value.outPoint
                : outPoint // ignore: cast_nullable_to_non_nullable
                      as int?,
            loopType: null == loopType
                ? _value.loopType
                : loopType // ignore: cast_nullable_to_non_nullable
                      as VecLoopType,
            tracks: null == tracks
                ? _value.tracks
                : tracks // ignore: cast_nullable_to_non_nullable
                      as List<VecTrack>,
            frameLabels: null == frameLabels
                ? _value.frameLabels
                : frameLabels // ignore: cast_nullable_to_non_nullable
                      as List<VecFrameLabel>,
            motionPaths: null == motionPaths
                ? _value.motionPaths
                : motionPaths // ignore: cast_nullable_to_non_nullable
                      as List<VecMotionPath>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VecTimelineImplCopyWith<$Res>
    implements $VecTimelineCopyWith<$Res> {
  factory _$$VecTimelineImplCopyWith(
    _$VecTimelineImpl value,
    $Res Function(_$VecTimelineImpl) then,
  ) = __$$VecTimelineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int duration,
    int inPoint,
    int? outPoint,
    VecLoopType loopType,
    List<VecTrack> tracks,
    List<VecFrameLabel> frameLabels,
    List<VecMotionPath> motionPaths,
  });
}

/// @nodoc
class __$$VecTimelineImplCopyWithImpl<$Res>
    extends _$VecTimelineCopyWithImpl<$Res, _$VecTimelineImpl>
    implements _$$VecTimelineImplCopyWith<$Res> {
  __$$VecTimelineImplCopyWithImpl(
    _$VecTimelineImpl _value,
    $Res Function(_$VecTimelineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecTimeline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? duration = null,
    Object? inPoint = null,
    Object? outPoint = freezed,
    Object? loopType = null,
    Object? tracks = null,
    Object? frameLabels = null,
    Object? motionPaths = null,
  }) {
    return _then(
      _$VecTimelineImpl(
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        inPoint: null == inPoint
            ? _value.inPoint
            : inPoint // ignore: cast_nullable_to_non_nullable
                  as int,
        outPoint: freezed == outPoint
            ? _value.outPoint
            : outPoint // ignore: cast_nullable_to_non_nullable
                  as int?,
        loopType: null == loopType
            ? _value.loopType
            : loopType // ignore: cast_nullable_to_non_nullable
                  as VecLoopType,
        tracks: null == tracks
            ? _value._tracks
            : tracks // ignore: cast_nullable_to_non_nullable
                  as List<VecTrack>,
        frameLabels: null == frameLabels
            ? _value._frameLabels
            : frameLabels // ignore: cast_nullable_to_non_nullable
                  as List<VecFrameLabel>,
        motionPaths: null == motionPaths
            ? _value._motionPaths
            : motionPaths // ignore: cast_nullable_to_non_nullable
                  as List<VecMotionPath>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecTimelineImpl implements _VecTimeline {
  const _$VecTimelineImpl({
    required this.duration,
    this.inPoint = 0,
    this.outPoint,
    this.loopType = VecLoopType.loop,
    final List<VecTrack> tracks = const [],
    final List<VecFrameLabel> frameLabels = const [],
    final List<VecMotionPath> motionPaths = const [],
  }) : _tracks = tracks,
       _frameLabels = frameLabels,
       _motionPaths = motionPaths;

  factory _$VecTimelineImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecTimelineImplFromJson(json);

  @override
  final int duration;
  @override
  @JsonKey()
  final int inPoint;
  @override
  final int? outPoint;
  @override
  @JsonKey()
  final VecLoopType loopType;
  final List<VecTrack> _tracks;
  @override
  @JsonKey()
  List<VecTrack> get tracks {
    if (_tracks is EqualUnmodifiableListView) return _tracks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tracks);
  }

  final List<VecFrameLabel> _frameLabels;
  @override
  @JsonKey()
  List<VecFrameLabel> get frameLabels {
    if (_frameLabels is EqualUnmodifiableListView) return _frameLabels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_frameLabels);
  }

  final List<VecMotionPath> _motionPaths;
  @override
  @JsonKey()
  List<VecMotionPath> get motionPaths {
    if (_motionPaths is EqualUnmodifiableListView) return _motionPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_motionPaths);
  }

  @override
  String toString() {
    return 'VecTimeline(duration: $duration, inPoint: $inPoint, outPoint: $outPoint, loopType: $loopType, tracks: $tracks, frameLabels: $frameLabels, motionPaths: $motionPaths)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecTimelineImpl &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.inPoint, inPoint) || other.inPoint == inPoint) &&
            (identical(other.outPoint, outPoint) ||
                other.outPoint == outPoint) &&
            (identical(other.loopType, loopType) ||
                other.loopType == loopType) &&
            const DeepCollectionEquality().equals(other._tracks, _tracks) &&
            const DeepCollectionEquality().equals(
              other._frameLabels,
              _frameLabels,
            ) &&
            const DeepCollectionEquality().equals(
              other._motionPaths,
              _motionPaths,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    duration,
    inPoint,
    outPoint,
    loopType,
    const DeepCollectionEquality().hash(_tracks),
    const DeepCollectionEquality().hash(_frameLabels),
    const DeepCollectionEquality().hash(_motionPaths),
  );

  /// Create a copy of VecTimeline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecTimelineImplCopyWith<_$VecTimelineImpl> get copyWith =>
      __$$VecTimelineImplCopyWithImpl<_$VecTimelineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecTimelineImplToJson(this);
  }
}

abstract class _VecTimeline implements VecTimeline {
  const factory _VecTimeline({
    required final int duration,
    final int inPoint,
    final int? outPoint,
    final VecLoopType loopType,
    final List<VecTrack> tracks,
    final List<VecFrameLabel> frameLabels,
    final List<VecMotionPath> motionPaths,
  }) = _$VecTimelineImpl;

  factory _VecTimeline.fromJson(Map<String, dynamic> json) =
      _$VecTimelineImpl.fromJson;

  @override
  int get duration;
  @override
  int get inPoint;
  @override
  int? get outPoint;
  @override
  VecLoopType get loopType;
  @override
  List<VecTrack> get tracks;
  @override
  List<VecFrameLabel> get frameLabels;
  @override
  List<VecMotionPath> get motionPaths;

  /// Create a copy of VecTimeline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecTimelineImplCopyWith<_$VecTimelineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
