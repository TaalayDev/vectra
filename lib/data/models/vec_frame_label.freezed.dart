// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_frame_label.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecFrameLabel _$VecFrameLabelFromJson(Map<String, dynamic> json) {
  return _VecFrameLabel.fromJson(json);
}

/// @nodoc
mixin _$VecFrameLabel {
  int get frame => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  /// Serializes this VecFrameLabel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecFrameLabel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecFrameLabelCopyWith<VecFrameLabel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecFrameLabelCopyWith<$Res> {
  factory $VecFrameLabelCopyWith(
    VecFrameLabel value,
    $Res Function(VecFrameLabel) then,
  ) = _$VecFrameLabelCopyWithImpl<$Res, VecFrameLabel>;
  @useResult
  $Res call({int frame, String label});
}

/// @nodoc
class _$VecFrameLabelCopyWithImpl<$Res, $Val extends VecFrameLabel>
    implements $VecFrameLabelCopyWith<$Res> {
  _$VecFrameLabelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecFrameLabel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? frame = null, Object? label = null}) {
    return _then(
      _value.copyWith(
            frame: null == frame
                ? _value.frame
                : frame // ignore: cast_nullable_to_non_nullable
                      as int,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VecFrameLabelImplCopyWith<$Res>
    implements $VecFrameLabelCopyWith<$Res> {
  factory _$$VecFrameLabelImplCopyWith(
    _$VecFrameLabelImpl value,
    $Res Function(_$VecFrameLabelImpl) then,
  ) = __$$VecFrameLabelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int frame, String label});
}

/// @nodoc
class __$$VecFrameLabelImplCopyWithImpl<$Res>
    extends _$VecFrameLabelCopyWithImpl<$Res, _$VecFrameLabelImpl>
    implements _$$VecFrameLabelImplCopyWith<$Res> {
  __$$VecFrameLabelImplCopyWithImpl(
    _$VecFrameLabelImpl _value,
    $Res Function(_$VecFrameLabelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecFrameLabel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? frame = null, Object? label = null}) {
    return _then(
      _$VecFrameLabelImpl(
        frame: null == frame
            ? _value.frame
            : frame // ignore: cast_nullable_to_non_nullable
                  as int,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecFrameLabelImpl implements _VecFrameLabel {
  const _$VecFrameLabelImpl({required this.frame, required this.label});

  factory _$VecFrameLabelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecFrameLabelImplFromJson(json);

  @override
  final int frame;
  @override
  final String label;

  @override
  String toString() {
    return 'VecFrameLabel(frame: $frame, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecFrameLabelImpl &&
            (identical(other.frame, frame) || other.frame == frame) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, frame, label);

  /// Create a copy of VecFrameLabel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecFrameLabelImplCopyWith<_$VecFrameLabelImpl> get copyWith =>
      __$$VecFrameLabelImplCopyWithImpl<_$VecFrameLabelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecFrameLabelImplToJson(this);
  }
}

abstract class _VecFrameLabel implements VecFrameLabel {
  const factory _VecFrameLabel({
    required final int frame,
    required final String label,
  }) = _$VecFrameLabelImpl;

  factory _VecFrameLabel.fromJson(Map<String, dynamic> json) =
      _$VecFrameLabelImpl.fromJson;

  @override
  int get frame;
  @override
  String get label;

  /// Create a copy of VecFrameLabel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecFrameLabelImplCopyWith<_$VecFrameLabelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
