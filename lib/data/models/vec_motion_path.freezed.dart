// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vec_motion_path.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VecMotionPath _$VecMotionPathFromJson(Map<String, dynamic> json) {
  return _VecMotionPath.fromJson(json);
}

/// @nodoc
mixin _$VecMotionPath {
  String get id => throw _privateConstructorUsedError;
  String get shapeId => throw _privateConstructorUsedError;
  List<VecPathNode> get nodes => throw _privateConstructorUsedError;
  bool get isClosed => throw _privateConstructorUsedError;
  bool get orientToPath => throw _privateConstructorUsedError;
  bool get easeAlongPath => throw _privateConstructorUsedError;

  /// Serializes this VecMotionPath to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VecMotionPath
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VecMotionPathCopyWith<VecMotionPath> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VecMotionPathCopyWith<$Res> {
  factory $VecMotionPathCopyWith(
    VecMotionPath value,
    $Res Function(VecMotionPath) then,
  ) = _$VecMotionPathCopyWithImpl<$Res, VecMotionPath>;
  @useResult
  $Res call({
    String id,
    String shapeId,
    List<VecPathNode> nodes,
    bool isClosed,
    bool orientToPath,
    bool easeAlongPath,
  });
}

/// @nodoc
class _$VecMotionPathCopyWithImpl<$Res, $Val extends VecMotionPath>
    implements $VecMotionPathCopyWith<$Res> {
  _$VecMotionPathCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VecMotionPath
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shapeId = null,
    Object? nodes = null,
    Object? isClosed = null,
    Object? orientToPath = null,
    Object? easeAlongPath = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            shapeId: null == shapeId
                ? _value.shapeId
                : shapeId // ignore: cast_nullable_to_non_nullable
                      as String,
            nodes: null == nodes
                ? _value.nodes
                : nodes // ignore: cast_nullable_to_non_nullable
                      as List<VecPathNode>,
            isClosed: null == isClosed
                ? _value.isClosed
                : isClosed // ignore: cast_nullable_to_non_nullable
                      as bool,
            orientToPath: null == orientToPath
                ? _value.orientToPath
                : orientToPath // ignore: cast_nullable_to_non_nullable
                      as bool,
            easeAlongPath: null == easeAlongPath
                ? _value.easeAlongPath
                : easeAlongPath // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VecMotionPathImplCopyWith<$Res>
    implements $VecMotionPathCopyWith<$Res> {
  factory _$$VecMotionPathImplCopyWith(
    _$VecMotionPathImpl value,
    $Res Function(_$VecMotionPathImpl) then,
  ) = __$$VecMotionPathImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String shapeId,
    List<VecPathNode> nodes,
    bool isClosed,
    bool orientToPath,
    bool easeAlongPath,
  });
}

/// @nodoc
class __$$VecMotionPathImplCopyWithImpl<$Res>
    extends _$VecMotionPathCopyWithImpl<$Res, _$VecMotionPathImpl>
    implements _$$VecMotionPathImplCopyWith<$Res> {
  __$$VecMotionPathImplCopyWithImpl(
    _$VecMotionPathImpl _value,
    $Res Function(_$VecMotionPathImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VecMotionPath
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shapeId = null,
    Object? nodes = null,
    Object? isClosed = null,
    Object? orientToPath = null,
    Object? easeAlongPath = null,
  }) {
    return _then(
      _$VecMotionPathImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        shapeId: null == shapeId
            ? _value.shapeId
            : shapeId // ignore: cast_nullable_to_non_nullable
                  as String,
        nodes: null == nodes
            ? _value._nodes
            : nodes // ignore: cast_nullable_to_non_nullable
                  as List<VecPathNode>,
        isClosed: null == isClosed
            ? _value.isClosed
            : isClosed // ignore: cast_nullable_to_non_nullable
                  as bool,
        orientToPath: null == orientToPath
            ? _value.orientToPath
            : orientToPath // ignore: cast_nullable_to_non_nullable
                  as bool,
        easeAlongPath: null == easeAlongPath
            ? _value.easeAlongPath
            : easeAlongPath // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VecMotionPathImpl implements _VecMotionPath {
  const _$VecMotionPathImpl({
    required this.id,
    required this.shapeId,
    final List<VecPathNode> nodes = const [],
    this.isClosed = false,
    this.orientToPath = false,
    this.easeAlongPath = false,
  }) : _nodes = nodes;

  factory _$VecMotionPathImpl.fromJson(Map<String, dynamic> json) =>
      _$$VecMotionPathImplFromJson(json);

  @override
  final String id;
  @override
  final String shapeId;
  final List<VecPathNode> _nodes;
  @override
  @JsonKey()
  List<VecPathNode> get nodes {
    if (_nodes is EqualUnmodifiableListView) return _nodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nodes);
  }

  @override
  @JsonKey()
  final bool isClosed;
  @override
  @JsonKey()
  final bool orientToPath;
  @override
  @JsonKey()
  final bool easeAlongPath;

  @override
  String toString() {
    return 'VecMotionPath(id: $id, shapeId: $shapeId, nodes: $nodes, isClosed: $isClosed, orientToPath: $orientToPath, easeAlongPath: $easeAlongPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VecMotionPathImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shapeId, shapeId) || other.shapeId == shapeId) &&
            const DeepCollectionEquality().equals(other._nodes, _nodes) &&
            (identical(other.isClosed, isClosed) ||
                other.isClosed == isClosed) &&
            (identical(other.orientToPath, orientToPath) ||
                other.orientToPath == orientToPath) &&
            (identical(other.easeAlongPath, easeAlongPath) ||
                other.easeAlongPath == easeAlongPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    shapeId,
    const DeepCollectionEquality().hash(_nodes),
    isClosed,
    orientToPath,
    easeAlongPath,
  );

  /// Create a copy of VecMotionPath
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VecMotionPathImplCopyWith<_$VecMotionPathImpl> get copyWith =>
      __$$VecMotionPathImplCopyWithImpl<_$VecMotionPathImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VecMotionPathImplToJson(this);
  }
}

abstract class _VecMotionPath implements VecMotionPath {
  const factory _VecMotionPath({
    required final String id,
    required final String shapeId,
    final List<VecPathNode> nodes,
    final bool isClosed,
    final bool orientToPath,
    final bool easeAlongPath,
  }) = _$VecMotionPathImpl;

  factory _VecMotionPath.fromJson(Map<String, dynamic> json) =
      _$VecMotionPathImpl.fromJson;

  @override
  String get id;
  @override
  String get shapeId;
  @override
  List<VecPathNode> get nodes;
  @override
  bool get isClosed;
  @override
  bool get orientToPath;
  @override
  bool get easeAlongPath;

  /// Create a copy of VecMotionPath
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VecMotionPathImplCopyWith<_$VecMotionPathImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
