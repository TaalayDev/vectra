import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';

class PlaybackControls extends ConsumerWidget {
  const PlaybackControls({
    super.key,
    required this.theme,
    required this.fps,
    required this.duration,
  });

  final AppTheme theme;
  final int fps;
  final int duration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider);
    final playhead = ref.watch(playheadFrameProvider);

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: theme.toolbarColor,
        border: Border(
          bottom: BorderSide(color: theme.divider, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Step back
          _ControlButton(
            icon: Icons.skip_previous,
            onTap: () {
              final f = ref.read(playheadFrameProvider);
              if (f > 0) ref.read(playheadFrameProvider.notifier).set(f - 1);
            },
            theme: theme,
          ),
          const SizedBox(width: 2),
          // Play / Pause
          _ControlButton(
            icon: isPlaying ? Icons.pause : Icons.play_arrow,
            onTap: () => ref.read(isPlayingProvider.notifier).toggle(),
            theme: theme,
            isAccent: true,
          ),
          const SizedBox(width: 2),
          // Step forward
          _ControlButton(
            icon: Icons.skip_next,
            onTap: () {
              final f = ref.read(playheadFrameProvider);
              if (f < duration - 1) ref.read(playheadFrameProvider.notifier).set(f + 1);
            },
            theme: theme,
          ),
          const SizedBox(width: 16),
          // Frame counter
          Text(
            '${playhead + 1} / $duration',
            style: TextStyle(
              fontSize: 11,
              color: theme.textSecondary,
              fontWeight: FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const Spacer(),
          // FPS
          Text(
            '$fps fps',
            style: TextStyle(fontSize: 10, color: theme.textDisabled),
          ),
          const SizedBox(width: 12),
          // Loop toggle
          _ControlButton(
            icon: Icons.repeat,
            onTap: () {},
            theme: theme,
            isAccent: true,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.theme,
    this.isAccent = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final AppTheme theme;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        hoverColor: theme.primaryColor.withAlpha(20),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            icon,
            size: 16,
            color: isAccent ? theme.primaryColor : theme.inactiveIcon,
          ),
        ),
      ),
    );
  }
}
