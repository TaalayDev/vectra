import 'package:flutter/material.dart';

import '../../../app/theme/theme.dart';
import 'frame_grid.dart';

class TrackLabelColumn extends StatelessWidget {
  const TrackLabelColumn({
    super.key,
    required this.rows,
    required this.theme,
    this.scrollController,
  });

  final List<TrackRow> rows;
  final AppTheme theme;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    // Ruler header (same height as FrameGrid ruler)
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ruler height spacer
          Container(
            height: FrameGrid.rulerHeight,
            decoration: BoxDecoration(
              color: theme.surfaceVariant.withAlpha(80),
              border: Border(
                bottom: BorderSide(color: theme.divider.withAlpha(60), width: 0.5),
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Layer / Shape',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: theme.textDisabled,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Shape rows
          Expanded(
            child: rows.isEmpty
                ? Center(
                    child: Text(
                      'No shapes',
                      style: TextStyle(fontSize: 10, color: theme.textDisabled),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    itemCount: rows.length,
                    itemBuilder: (_, i) {
                      final row = rows[i];
                      return Container(
                        height: FrameGrid.trackHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.divider.withAlpha(40),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              row.icon,
                              size: 10,
                              color: theme.textDisabled,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                row.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
