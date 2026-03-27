import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../core/export/export_service.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import '../../../providers/export_provider.dart';
import '../../contents/theme_selector.dart';

// ---------------------------------------------------------------------------
// Entry point — adaptive show
// ---------------------------------------------------------------------------

class ExportDialog extends StatelessWidget {
  const ExportDialog({super.key});

  /// Shows the export dialog on desktop or a bottom sheet on mobile.
  static void show(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 700;
    if (isDesktop) {
      showDialog<void>(context: context, barrierColor: Colors.black54, builder: (_) => const ExportDialog());
    } else {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _ExportBottomSheet(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(child: _ExportDialogContent(onClose: () => Navigator.of(context).pop()));
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet wrapper
// ---------------------------------------------------------------------------

class _ExportBottomSheet extends StatelessWidget {
  const _ExportBottomSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => _ExportDialogContent(
        onClose: () => Navigator.of(context).pop(),
        scrollController: scrollController,
        isBottomSheet: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Core content widget
// ---------------------------------------------------------------------------

class _ExportDialogContent extends HookConsumerWidget {
  const _ExportDialogContent({required this.onClose, this.scrollController, this.isBottomSheet = false});

  final VoidCallback onClose;
  final ScrollController? scrollController;
  final bool isBottomSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).theme;
    final exportState = ref.watch(exportProvider);
    final notifier = ref.read(exportProvider.notifier);
    final screenSize = MediaQuery.sizeOf(context);
    final isCompact = screenSize.width < 700;

    // Auto-close on success after a short delay
    // Auto-close on success; auto-reset cancelled state
    useEffect(() {
      if (exportState.status == ExportStatus.success) {
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) onClose();
        });
      }
      if (exportState.status == ExportStatus.cancelled) {
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) notifier.reset();
        });
      }
      return null;
    }, [exportState.status]);

    Widget content = Container(
      constraints: BoxConstraints(
        maxWidth: isCompact ? double.infinity : 680,
        maxHeight: isBottomSheet ? double.infinity : screenSize.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: isBottomSheet ? Radius.zero : const Radius.circular(20),
          bottomRight: isBottomSheet ? Radius.zero : const Radius.circular(20),
        ),
        border: Border.all(color: theme.divider.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 48,
            spreadRadius: 0,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isBottomSheet) _DragHandle(theme: theme),
          _Header(theme: theme, onClose: onClose),
          Flexible(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _SectionLabel(theme: theme, label: 'FORMAT'),
                  const SizedBox(height: 12),
                  _FormatGrid(theme: theme, exportState: exportState, notifier: notifier),
                  const SizedBox(height: 24),
                  _SectionLabel(theme: theme, label: 'OPTIONS'),
                  const SizedBox(height: 12),
                  _OptionsPanel(theme: theme, exportState: exportState, notifier: notifier),
                  const SizedBox(height: 24),
                  _OutputPreview(theme: theme, exportState: exportState),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _Footer(
            theme: theme,
            exportState: exportState,
            onCancel: onClose,
            onExport: () {
              final doc = ref.read(vecDocumentStateProvider);
              final scene = ref.read(activeSceneProvider);
              if (scene != null) {
                notifier.runExport(doc, scene);
              }
            },
          ),
        ],
      ),
    );

    if (!isBottomSheet) {
      content = Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 40, vertical: isCompact ? 24 : 40),
        child: content,
      );
    }

    return content;
  }
}

// ---------------------------------------------------------------------------
// Drag handle (bottom sheet)
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.theme});
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(color: theme.divider.withOpacity(0.4), borderRadius: BorderRadius.circular(2)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.theme, required this.onClose});
  final AppTheme theme;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.divider.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.primaryColor, theme.accentColor],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.upload_rounded, size: 20, color: theme.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text('Choose format and options', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, size: 18, color: theme.textDisabled),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Format grid
// ---------------------------------------------------------------------------

const _formats = [
  (ExportFormat.svg, 'SVG', 'Vector, static', MaterialCommunityIcons.svg, Color(0xFFFF7043)),
  (ExportFormat.animatedSvg, 'Animated SVG', 'CSS animations', Icons.animation_rounded, Color(0xFFAB47BC)),
  (ExportFormat.lottie, 'Lottie JSON', 'iOS · Android · Web', MaterialCommunityIcons.code_json, Color(0xFF29B6F6)),
  (ExportFormat.mp4, 'MP4', 'H.264, up to 1080p', Icons.movie_rounded, Color(0xFF26A69A)),
  (ExportFormat.png, 'PNG', 'Single frame', Icons.image_rounded, Color(0xFF66BB6A)),
  (ExportFormat.pngSequence, 'PNG Sequence', 'Per-frame export', Icons.burst_mode_rounded, Color(0xFFFFCA28)),
  (ExportFormat.gif, 'GIF', 'Social · Messaging', Icons.gif_box_outlined, Color(0xFFEF5350)),
];

class _FormatGrid extends StatelessWidget {
  const _FormatGrid({required this.theme, required this.exportState, required this.notifier});

  final AppTheme theme;
  final ExportState exportState;
  final ExportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _formats.map((f) {
        final (format, label, subtitle, icon, color) = f;
        return _FormatCard(
          theme: theme,
          format: format,
          label: label,
          subtitle: subtitle,
          icon: icon,
          accentColor: color,
          isSelected: exportState.format == format,
          onTap: () => notifier.setFormat(format),
        );
      }).toList(),
    );
  }
}

class _FormatCard extends StatefulWidget {
  const _FormatCard({
    required this.theme,
    required this.format,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  final AppTheme theme;
  final ExportFormat format;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_FormatCard> createState() => _FormatCardState();
}

class _FormatCardState extends State<_FormatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final th = widget.theme;
    final sel = widget.isSelected;
    final color = widget.accentColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 144,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: sel ? color.withOpacity(0.12) : (_hovered ? th.surfaceVariant : th.surfaceVariant.withOpacity(0.45)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sel ? color : th.divider.withOpacity(_hovered ? 0.5 : 0.18),
              width: sel ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: sel ? color.withOpacity(0.18) : th.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, size: 17, color: sel ? color : th.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w600,
                  color: sel ? color : th.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(widget.subtitle, style: TextStyle(fontSize: 9, color: th.textDisabled)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Options panel (format-specific)
// ---------------------------------------------------------------------------

class _OptionsPanel extends StatelessWidget {
  const _OptionsPanel({required this.theme, required this.exportState, required this.notifier});

  final AppTheme theme;
  final ExportState exportState;
  final ExportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return switch (exportState.format) {
      ExportFormat.svg || ExportFormat.animatedSvg => _SvgOptions(theme: theme, state: exportState, notifier: notifier),
      ExportFormat.lottie => _LottieOptions(theme: theme, state: exportState, notifier: notifier),
      ExportFormat.mp4 => _Mp4Options(theme: theme, state: exportState, notifier: notifier),
      ExportFormat.png ||
      ExportFormat.pngSequence ||
      ExportFormat.gif => _RasterOptions(theme: theme, state: exportState, notifier: notifier),
    };
  }
}

// ---------------------------------------------------------------------------
// SVG options
// ---------------------------------------------------------------------------

class _SvgOptions extends StatelessWidget {
  const _SvgOptions({required this.theme, required this.state, required this.notifier});
  final AppTheme theme;
  final ExportState state;
  final ExportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return _OptionsCard(
      theme: theme,
      children: [
        _ToggleRow(
          theme: theme,
          label: 'Minify output',
          subtitle: 'Remove whitespace and comments',
          value: state.svgMinify,
          onChanged: notifier.setSvgMinify,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Lottie options
// ---------------------------------------------------------------------------

class _LottieOptions extends StatelessWidget {
  const _LottieOptions({required this.theme, required this.state, required this.notifier});
  final AppTheme theme;
  final ExportState state;
  final ExportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return _OptionsCard(
      theme: theme,
      children: [
        _ToggleRow(
          theme: theme,
          label: 'Preserve named markers',
          subtitle: 'Include timeline frame labels as Lottie markers',
          value: state.lottiePreserveMarkers,
          onChanged: notifier.setLottieMarkers,
        ),
        _Separator(theme: theme),
        _ToggleRow(
          theme: theme,
          label: 'Minify JSON',
          subtitle: 'Reduce file size for production use',
          value: state.svgMinify,
          onChanged: notifier.setSvgMinify,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// MP4 options
// ---------------------------------------------------------------------------

class _Mp4Options extends HookWidget {
  const _Mp4Options({required this.theme, required this.state, required this.notifier});
  final AppTheme theme;
  final ExportState state;
  final ExportNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final wCtrl = useTextEditingController(text: state.mp4Width.toString());
    final hCtrl = useTextEditingController(text: state.mp4Height.toString());

    return _OptionsCard(
      theme: theme,
      children: [
        Row(
          children: [
            Expanded(
              child: _LabeledField(
                theme: theme,
                label: 'Width',
                controller: wCtrl,
                suffix: 'px',
                onChanged: (_) {
                  final w = int.tryParse(wCtrl.text) ?? state.mp4Width;
                  notifier.setMp4Size(w, state.mp4Height);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.close_rounded, size: 12, color: theme.textDisabled),
            ),
            Expanded(
              child: _LabeledField(
                theme: theme,
                label: 'Height',
                controller: hCtrl,
                suffix: 'px',
                onChanged: (_) {
                  final h = int.tryParse(hCtrl.text) ?? state.mp4Height;
                  notifier.setMp4Size(state.mp4Width, h);
                },
              ),
            ),
          ],
        ),
        _Separator(theme: theme),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: theme.textDisabled),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'MP4 export requires the desktop renderer — coming soon.',
                  style: TextStyle(fontSize: 11, color: theme.textDisabled),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Raster options (PNG / PNG sequence / GIF)
// ---------------------------------------------------------------------------

class _RasterOptions extends StatelessWidget {
  const _RasterOptions({required this.theme, required this.state, required this.notifier});
  final AppTheme theme;
  final ExportState state;
  final ExportNotifier notifier;

  static const _scales = [(1.0, '1×'), (2.0, '2×'), (3.0, '3×'), (4.0, '4×')];

  static const _gifFpsOptions = [8, 12, 15, 24, 30];

  @override
  Widget build(BuildContext context) {
    return _OptionsCard(
      theme: theme,
      children: [
        // Resolution scale
        Row(
          children: [
            Icon(Icons.photo_size_select_large_rounded, size: 15, color: theme.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Resolution',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary),
            ),
            const SizedBox(width: 12),
            Wrap(
              spacing: 6,
              children: _scales.map((s) {
                final (scale, label) = s;
                return _ScaleChip(
                  theme: theme,
                  label: label,
                  isSelected: state.scale == scale,
                  onTap: () => notifier.setScale(scale),
                );
              }).toList(),
            ),
          ],
        ),

        if (state.format == ExportFormat.gif) ...[
          _Separator(theme: theme),
          Row(
            children: [
              Icon(MaterialCommunityIcons.timer_outline, size: 15, color: theme.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Frame rate',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary),
              ),
              const SizedBox(width: 12),
              Wrap(
                spacing: 6,
                children: _gifFpsOptions.map((fps) {
                  return _ScaleChip(
                    theme: theme,
                    label: '${fps}fps',
                    isSelected: state.gifFps == fps,
                    onTap: () => notifier.setGifFps(fps),
                  );
                }).toList(),
              ),
            ],
          ),
        ],

        _Separator(theme: theme),
        _ToggleRow(
          theme: theme,
          label: 'Transparent background',
          subtitle: 'Export with alpha channel (PNG/GIF)',
          value: state.transparent,
          onChanged: notifier.setTransparent,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Output preview strip
// ---------------------------------------------------------------------------

class _OutputPreview extends ConsumerWidget {
  const _OutputPreview({required this.theme, required this.exportState});
  final AppTheme theme;
  final ExportState exportState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doc = ref.watch(currentMetaProvider);
    final w = doc.stageWidth;
    final h = doc.stageHeight;

    final (ext, desc) = _formatMeta(exportState);
    final exportW = exportState.format == ExportFormat.mp4 ? exportState.mp4Width.toDouble() : w * exportState.scale;
    final exportH = exportState.format == ExportFormat.mp4 ? exportState.mp4Height.toDouble() : h * exportState.scale;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.divider.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // File icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.divider.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                ext.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: theme.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${doc.name}.$ext',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '$desc — ${exportW.toInt()} × ${exportH.toInt()}px',
                  style: TextStyle(fontSize: 11, color: theme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, String) _formatMeta(ExportState s) => switch (s.format) {
    ExportFormat.svg => ('svg', 'Vector SVG'),
    ExportFormat.animatedSvg => ('svg', 'Animated SVG'),
    ExportFormat.lottie => ('json', 'Lottie JSON'),
    ExportFormat.mp4 => ('mp4', 'H.264 Video'),
    ExportFormat.png => ('png', 'PNG Image'),
    ExportFormat.pngSequence => ('png', 'PNG Sequence'),
    ExportFormat.gif => ('gif', 'Animated GIF'),
  };
}

// ---------------------------------------------------------------------------
// Footer
// ---------------------------------------------------------------------------

class _Footer extends StatelessWidget {
  const _Footer({required this.theme, required this.exportState, required this.onCancel, required this.onExport});

  final AppTheme theme;
  final ExportState exportState;
  final VoidCallback onCancel;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final isExporting = exportState.isExporting;
    final isSuccess = exportState.status == ExportStatus.success;
    final isError = exportState.status == ExportStatus.error;
    final isCancelled = exportState.status == ExportStatus.cancelled;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.divider.withOpacity(0.2))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error banner
          if (isError && exportState.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, size: 15, color: theme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(exportState.errorMessage!, style: TextStyle(fontSize: 11, color: theme.error)),
                  ),
                ],
              ),
            ),
          ],

          // Success banner
          if (isSuccess) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 15, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 8),
                  Text(
                    exportState.savedPath != null
                        ? 'Saved to ${exportState.savedPath!.split('/').last}'
                        : 'Exported successfully!',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF4CAF50)),
                  ),
                ],
              ),
            ),
          ],

          // Cancelled banner
          if (isCancelled) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.surfaceVariant.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.divider.withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 15, color: theme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'No location selected — tap Export to try again.',
                    style: TextStyle(fontSize: 11, color: theme.textSecondary),
                  ),
                ],
              ),
            ),
          ],

          // Progress bar
          if (isExporting) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                backgroundColor: theme.divider.withOpacity(0.2),
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isExporting ? null : onCancel,
                child: Text('Cancel', style: TextStyle(color: isExporting ? theme.textDisabled : theme.textSecondary)),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: isExporting || isSuccess ? null : onExport,
                icon: isExporting
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: theme.onPrimary),
                      )
                    : Icon(isSuccess ? Icons.check_rounded : Icons.upload_rounded, size: 15),
                label: Text(
                  isExporting
                      ? 'Exporting…'
                      : isSuccess
                      ? 'Done'
                      : isCancelled
                      ? 'Try Again'
                      : 'Export',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: isSuccess ? const Color(0xFF4CAF50) : theme.primaryColor,
                  foregroundColor: theme.onPrimary,
                  disabledBackgroundColor: isSuccess
                      ? const Color(0xFF4CAF50).withOpacity(0.7)
                      : theme.primaryColor.withOpacity(0.5),
                  disabledForegroundColor: theme.onPrimary.withOpacity(0.7),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable sub-widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.theme, required this.label});
  final AppTheme theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: theme.textDisabled, letterSpacing: 1.2),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  const _OptionsCard({required this.theme, required this.children});
  final AppTheme theme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.divider.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((child) {
          return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: child);
        }).toList(),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.theme,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final AppTheme theme;
  final String label;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11, color: theme.textDisabled)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: theme.primaryColor,
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return theme.primaryColor.withOpacity(0.3);
            }
            return theme.divider.withOpacity(0.3);
          }),
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator({required this.theme});
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 0.5, color: theme.divider.withOpacity(0.25));
  }
}

class _ScaleChip extends StatefulWidget {
  const _ScaleChip({required this.theme, required this.label, required this.isSelected, required this.onTap});
  final AppTheme theme;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_ScaleChip> createState() => _ScaleChipState();
}

class _ScaleChipState extends State<_ScaleChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final th = widget.theme;
    final sel = widget.isSelected;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: sel ? th.primaryColor : (_hovered ? th.surfaceVariant : th.surfaceVariant.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: sel ? th.primaryColor : th.divider.withOpacity(_hovered ? 0.5 : 0.2)),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
              color: sel ? th.onPrimary : th.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.theme,
    required this.label,
    required this.controller,
    required this.suffix,
    required this.onChanged,
  });

  final AppTheme theme;
  final String label;
  final TextEditingController controller;
  final String suffix;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: theme.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 11, color: theme.textSecondary),
        suffixText: suffix,
        suffixStyle: TextStyle(fontSize: 11, color: theme.textDisabled),
        filled: true,
        fillColor: theme.surfaceVariant.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.divider.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.divider.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
