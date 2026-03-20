import 'package:flutter/material.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_layer.dart';
import '../../../data/models/vec_track.dart';

class TrackLabelColumn extends StatelessWidget {
  const TrackLabelColumn({
    super.key,
    required this.tracks,
    required this.layers,
    required this.theme,
    this.scrollController,
  });

  final List<VecTrack> tracks;
  final List<VecLayer> layers;
  final AppTheme theme;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.zero,
        itemCount: tracks.length,
        itemBuilder: (_, index) {
          final track = tracks[index];
          final layer = layers.where((l) => l.id == track.layerId).firstOrNull;
          final name = layer?.name ?? 'Track ${index + 1}';

          return Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.divider.withAlpha(40), width: 0.5),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              name,
              style: TextStyle(
                fontSize: 10,
                color: theme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}
