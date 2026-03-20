import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_layer.dart';
import '../../../providers/document_provider.dart';

class LayerRow extends ConsumerWidget {
  const LayerRow({
    super.key,
    required this.layer,
    required this.sceneId,
    required this.isActive,
    required this.theme,
  });

  final VecLayer layer;
  final String sceneId;
  final bool isActive;
  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dotColor = layer.colorDot?.toFlutterColor() ?? theme.accentColor;

    return GestureDetector(
      onTap: () => ref.read(activeLayerIdProvider.notifier).set(layer.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.primaryColor.withAlpha(25) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? theme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            // Color dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // Layer name
            Expanded(
              child: Text(
                layer.name,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? theme.textPrimary : theme.textSecondary,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Guide badge
            if (layer.type == VecLayerType.guide)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.surfaceVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'G',
                    style: TextStyle(fontSize: 8, color: theme.textDisabled),
                  ),
                ),
              ),
            // Visibility toggle
            _SmallIconButton(
              icon: layer.visible ? Icons.visibility : Icons.visibility_off,
              color: layer.visible ? theme.activeIcon : theme.textDisabled,
              onTap: () {
                ref.read(vecDocumentStateProvider.notifier).updateLayer(
                      sceneId,
                      layer.id,
                      (l) => l.copyWith(visible: !l.visible),
                    );
              },
            ),
            const SizedBox(width: 2),
            // Lock toggle
            _SmallIconButton(
              icon: layer.locked ? Icons.lock : Icons.lock_open,
              color: layer.locked ? theme.warning : theme.textDisabled,
              onTap: () {
                ref.read(vecDocumentStateProvider.notifier).updateLayer(
                      sceneId,
                      layer.id,
                      (l) => l.copyWith(locked: !l.locked),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
