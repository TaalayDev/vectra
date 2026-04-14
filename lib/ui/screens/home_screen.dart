import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;

import '../../app/theme/theme.dart';
import '../../core/import/svg_importer.dart';
import '../../data/models/vec_color.dart';
import '../../data/models/vec_shape.dart';
import '../../providers/document_provider.dart';
import '../../providers/recent_projects_provider.dart';
import '../contents/animated_background.dart';
import '../contents/new_project_dialog.dart';
import '../contents/theme_selector.dart';
import '../contents/theme_selector_sheet.dart';
import 'editor_screen.dart';

// =============================================================================
// Template data
// =============================================================================

class _Template {
  final String name;
  final String category;
  final IconData icon;
  final double width;
  final double height;
  final int fps;

  const _Template({
    required this.name,
    required this.category,
    required this.icon,
    required this.width,
    required this.height,
    this.fps = 24,
  });

  String get sizeLabel => '${width.toInt()} x ${height.toInt()}';
}

const _templates = [
  // Video
  _Template(name: 'HD 1080p', category: 'Video', icon: Icons.tv, width: 1920, height: 1080),
  _Template(name: 'HD 720p', category: 'Video', icon: Icons.personal_video, width: 1280, height: 720),
  _Template(name: '4K UHD', category: 'Video', icon: Icons.monitor, width: 3840, height: 2160),
  _Template(name: '2K QHD', category: 'Video', icon: Icons.desktop_windows_outlined, width: 2560, height: 1440),
  // Social
  _Template(
    name: 'Instagram Post',
    category: 'Social',
    icon: Icons.crop_square_rounded,
    width: 1080,
    height: 1080,
    fps: 30,
  ),
  _Template(name: 'Instagram Story', category: 'Social', icon: Icons.smartphone, width: 1080, height: 1920, fps: 30),
  _Template(name: 'YouTube Thumbnail', category: 'Social', icon: Icons.play_circle_outline, width: 1280, height: 720),
  _Template(
    name: 'Twitter/X Header',
    category: 'Social',
    icon: Icons.panorama_wide_angle_rounded,
    width: 1500,
    height: 500,
  ),
  // Web
  _Template(name: 'Web Banner', category: 'Web', icon: Icons.web, width: 728, height: 90),
  _Template(name: 'Leaderboard', category: 'Web', icon: Icons.view_column_outlined, width: 970, height: 250),
  _Template(name: 'Skyscraper', category: 'Web', icon: Icons.view_sidebar_outlined, width: 160, height: 600),
  // Design
  _Template(name: 'App Icon', category: 'Design', icon: Icons.apps, width: 512, height: 512, fps: 12),
  _Template(name: 'Favicon', category: 'Design', icon: Icons.tab_rounded, width: 64, height: 64, fps: 12),
  _Template(
    name: 'A4 Portrait',
    category: 'Design',
    icon: Icons.description_outlined,
    width: 2480,
    height: 3508,
    fps: 1,
  ),
  _Template(name: 'Presentation', category: 'Design', icon: Icons.slideshow_rounded, width: 1920, height: 1080),
];

class _ArtworkTemplate {
  final String id;
  final String name;
  final String assetPath;
  final String description;

  const _ArtworkTemplate({required this.id, required this.name, required this.assetPath, required this.description});
}

const _artworkTemplates = [
  _ArtworkTemplate(
    id: 'person',
    name: 'Person',
    assetPath: 'assets/vectors/artwork_person.svg',
    description: 'Simple character illustration',
  ),
  _ArtworkTemplate(
    id: 'duck',
    name: 'Duck',
    assetPath: 'assets/vectors/artwork_duck.svg',
    description: 'Cute duck icon/mascot',
  ),
  _ArtworkTemplate(
    id: 'cat',
    name: 'Cat',
    assetPath: 'assets/vectors/artwork_cat.svg',
    description: 'Rounded cat mascot drawing',
  ),
  _ArtworkTemplate(
    id: 'rocket',
    name: 'Rocket',
    assetPath: 'assets/vectors/artwork_rocket.svg',
    description: 'Playful rocket badge',
  ),
  _ArtworkTemplate(
    id: 'fox',
    name: 'Fox',
    assetPath: 'assets/vectors/artwork_fox.svg',
    description: 'Clever fox with bushy tail',
  ),
  _ArtworkTemplate(
    id: 'robot',
    name: 'Robot',
    assetPath: 'assets/vectors/artwork_robot.svg',
    description: 'Retro robot with chest display',
  ),
  _ArtworkTemplate(
    id: 'penguin',
    name: 'Penguin',
    assetPath: 'assets/vectors/artwork_penguin.svg',
    description: 'Cozy penguin with winter hat',
  ),
  _ArtworkTemplate(
    id: 'dragon',
    name: 'Dragon',
    assetPath: 'assets/vectors/artwork_dragon.svg',
    description: 'Cute dragon breathing fire',
  ),
  _ArtworkTemplate(
    id: 'astronaut',
    name: 'Astronaut',
    assetPath: 'assets/vectors/artwork_astronaut.svg',
    description: 'Space explorer in full suit',
  ),
  _ArtworkTemplate(
    id: 'bear',
    name: 'Bear',
    assetPath: 'assets/vectors/artwork_bear.svg',
    description: 'Cozy bear with honey pot',
  ),
];

// =============================================================================
// Home screen
// =============================================================================

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).theme;
    final recentProjects = ref.watch(recentProjectsProvider);
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width > 900;
    final isMedium = size.width > 600;
    final isDragging = useState(false);

    Future<void> handleDrop(DropDoneDetails detail) async {
      isDragging.value = false;
      final files = detail.files;
      if (files.isEmpty) return;
      final file = files.first;
      final path = file.path;
      final ext = path.split('.').last.toLowerCase();

      if (ext == 'vct') {
        await ref.read(vecDocumentStateProvider.notifier).openFile(path);
        if (context.mounted) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditorScreen()));
        }
      } else if (ext == 'svg') {
        final svgContent = await File(path).readAsString();
        final name = path.split(Platform.pathSeparator).last.replaceAll('.svg', '');
        const stageW = 1080.0;
        const stageH = 1080.0;
        ref.read(vecDocumentStateProvider.notifier).newDocument(
          name: name,
          stageWidth: stageW,
          stageHeight: stageH,
          fps: 24,
        );
        const importer = SvgImporter();
        final shapes = _centerShapesOnStage(importer.import(svgContent), stageW, stageH);
        final doc = ref.read(vecDocumentStateProvider);
        if (doc.scenes.isNotEmpty && doc.scenes.first.layers.isNotEmpty && shapes.isNotEmpty) {
          final scene = doc.scenes.first;
          ref.read(vecDocumentStateProvider.notifier).addShapes(scene.id, scene.layers.first.id, shapes);
        }
        if (context.mounted) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditorScreen()));
        }
      } else if (_kImageExtensions.contains(ext)) {
        final fileName = path.split(Platform.pathSeparator).last;
        final bytes = await File(path).readAsBytes();
        final dims = await compute(_decodeImageDimensions, bytes);
        if (dims == null) return;
        // Create a new document sized to the image.
        final docName = fileName.contains('.') ? fileName.substring(0, fileName.lastIndexOf('.')) : fileName;
        final stageW = dims.$1.toDouble();
        final stageH = dims.$2.toDouble();
        ref.read(vecDocumentStateProvider.notifier).newDocument(
          name: docName,
          stageWidth: stageW,
          stageHeight: stageH,
          fps: 24,
        );
        final doc = ref.read(vecDocumentStateProvider);
        if (doc.scenes.isNotEmpty) {
          ref.read(vecDocumentStateProvider.notifier).addRasterLayer(
            doc.scenes.first.id,
            assetName: fileName,
            mimeType: _mimeFromExt(ext),
            dataBase64: base64Encode(bytes),
            imageWidth: stageW,
            imageHeight: stageH,
          );
        }
        if (context.mounted) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditorScreen()));
        }
      }
    }

    return Scaffold(
      backgroundColor: theme.background,
      body: DropTarget(
        onDragEntered: (_) {
          if (ModalRoute.of(context)?.isCurrent ?? false) isDragging.value = true;
        },
        onDragExited: (_) => isDragging.value = false,
        onDragDone: (detail) {
          if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
          handleDrop(detail);
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBackground(
                // intensity: 0.15,
                enableAnimation: true,
                child: Container(color: Colors.transparent),
              ),
            ),
            // Positioned.fill(
            //   child: DecoratedBox(
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //         begin: Alignment.topLeft,
            //         end: Alignment.bottomRight,
            //         colors: [
            //           theme.background.withOpacity(0.95),
            //           theme.background.withOpacity(0.85),
            //           Color.lerp(theme.background, theme.primaryColor, 0.03)!.withOpacity(0.9),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            SafeArea(
              child: isWide
                  ? _WideLayout(theme: theme, recentProjects: recentProjects)
                  : _NarrowLayout(theme: theme, recentProjects: recentProjects, isMedium: isMedium),
            ),
            if (isDragging.value) _DropOverlay(theme: theme, message: 'Drop .vct  ·  .svg  ·  or image to open'),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Wide layout — sidebar (logo + actions + recent) | templates
// =============================================================================

class _WideLayout extends ConsumerWidget {
  const _WideLayout({required this.theme, required this.recentProjects});

  final AppTheme theme;
  final AsyncValue<List<RecentProject>> recentProjects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Left sidebar
        SizedBox(
          width: 320,
          child: _Sidebar(theme: theme, recentProjects: recentProjects),
        ),
        Container(width: 1, color: theme.divider.withValues(alpha: 0.3)),
        // Right — templates
        Expanded(child: _TemplatesArea(theme: theme)),
      ],
    );
  }
}

// =============================================================================
// Narrow layout — single column scroll
// =============================================================================

class _NarrowLayout extends ConsumerWidget {
  const _NarrowLayout({required this.theme, required this.recentProjects, required this.isMedium});

  final AppTheme theme;
  final AsyncValue<List<RecentProject>> recentProjects;
  final bool isMedium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizes = theme.sizes;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMedium ? sizes.xxl * 1.5 : sizes.xl, vertical: sizes.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LogoHeader(theme: theme),
          SizedBox(height: sizes.xl + sizes.xs),
          _ActionButtons(theme: theme),
          SizedBox(height: sizes.xxl),
          _TemplatesSection(theme: theme),
          SizedBox(height: sizes.xxl),
          _RecentProjectsCompact(theme: theme, recentProjects: recentProjects),
          SizedBox(height: sizes.lg),
          _BottomBar(theme: theme),
        ],
      ),
    );
  }
}

// =============================================================================
// Sidebar (wide)
// =============================================================================

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.theme, required this.recentProjects});

  final AppTheme theme;
  final AsyncValue<List<RecentProject>> recentProjects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizes = theme.sizes;

    return Container(
      color: theme.surface.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: sizes.xxl + sizes.sm),
          _LogoHeader(theme: theme),
          SizedBox(height: sizes.xxl),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sizes.xl),
            child: _ActionButtons(theme: theme),
          ),
          SizedBox(height: sizes.xl + sizes.xs),
          // Recent projects — compact list
          Expanded(
            child: _RecentProjectsCompact(theme: theme, recentProjects: recentProjects),
          ),
          SizedBox(height: sizes.xs),
          _BottomBar(theme: theme),
          SizedBox(height: sizes.sm),
        ],
      ),
    );
  }
}

// =============================================================================
// Logo header
// =============================================================================

class _LogoHeader extends StatelessWidget {
  const _LogoHeader({required this.theme});
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final sizes = theme.sizes;
    final textTheme = theme.textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sizes.xl + sizes.sm),
      child: Row(
        children: [
          Container(
            width: sizes.buttonHeight,
            height: sizes.buttonHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.primaryColor, theme.accentColor],
              ),
              borderRadius: theme.radii.medium,
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: sizes.lg * 0.6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'V',
                style: textTheme.titleLarge?.copyWith(
                  fontSize: sizes.iconLg,
                  fontWeight: FontWeight.w900,
                  color: theme.onPrimary,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
          SizedBox(width: sizes.sm + 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vectra',
                style: textTheme.titleLarge?.copyWith(
                  fontSize: sizes.xl,
                  fontWeight: FontWeight.w800,
                  color: theme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Vector Animation Studio',
                style: textTheme.bodySmall?.copyWith(fontSize: 11, color: theme.textSecondary, letterSpacing: 0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Action buttons
// =============================================================================

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.theme});
  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ActionButton(
          theme: theme,
          icon: Icons.add_rounded,
          label: 'New Project',
          isPrimary: true,
          onTap: () => _createNewProject(context, ref),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                theme: theme,
                icon: Icons.folder_open_rounded,
                label: 'Open',
                onTap: () => _openProject(context, ref),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                theme: theme,
                icon: Icons.palette_outlined,
                label: 'Theme',
                onTap: () => ThemeSelectorBottomSheet.show(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _createNewProject(BuildContext context, WidgetRef ref) async {
    final result = await NewProjectDialog.show(context);
    if (result == null) return;
    ref
        .read(vecDocumentStateProvider.notifier)
        .newDocument(
          name: result.name,
          stageWidth: result.width,
          stageHeight: result.height,
          fps: result.fps,
          backgroundColor: VecColor.fromFlutterColor(result.backgroundColor),
        );
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditorScreen()));
    }
  }

  Future<void> _openProject(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['vct']);
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      await ref.read(vecDocumentStateProvider.notifier).openFile(path);
      if (context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditorScreen()));
      }
    }
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.theme,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final AppTheme theme;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final sizes = theme.sizes;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(minHeight: sizes.buttonHeight),
          padding: theme.buttons.padding,
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? (_hovering ? theme.primaryColor : theme.primaryColor.withValues(alpha: 0.9))
                : (_hovering ? theme.surfaceVariant : theme.surface.withValues(alpha: 0.6)),
            borderRadius: theme.radii.medium,
            border: Border.all(
              color: widget.isPrimary
                  ? theme.primaryColor
                  : (_hovering ? theme.primaryColor.withValues(alpha: 0.4) : theme.divider.withValues(alpha: 0.3)),
              width: theme.borders.regular,
            ),
            boxShadow: [
              if (_hovering)
                BoxShadow(
                  color: (widget.isPrimary ? theme.primaryColor : theme.accentColor).withValues(alpha: 0.12),
                  blurRadius: sizes.lg * 0.7,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: theme.buttons.iconSize,
                color: widget.isPrimary ? theme.onPrimary : theme.primaryColor,
              ),
              SizedBox(width: sizes.xs),
              Text(
                widget.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 13,
                  fontWeight: theme.primaryFontWeight,
                  color: widget.isPrimary ? theme.onPrimary : theme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Recent projects — compact list
// =============================================================================

class _RecentProjectsCompact extends ConsumerWidget {
  const _RecentProjectsCompact({required this.theme, required this.recentProjects});

  final AppTheme theme;
  final AsyncValue<List<RecentProject>> recentProjects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizes = theme.sizes;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sizes.xl + sizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, size: sizes.iconSm - 2, color: theme.textDisabled),
              SizedBox(width: sizes.xxs + 2),
              Text(
                'RECENT',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: theme.textDisabled,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: sizes.sm - 2),
          recentProjects.when(
            loading: () => Padding(
              padding: EdgeInsets.symmetric(vertical: sizes.md),
              child: Center(
                child: SizedBox(
                  width: sizes.iconSm,
                  height: sizes.iconSm,
                  child: CircularProgressIndicator(color: theme.primaryColor, strokeWidth: 1.5),
                ),
              ),
            ),
            error: (_, __) =>
                Text('Could not load projects', style: TextStyle(fontSize: 12, color: theme.textDisabled)),
            data: (projects) {
              if (projects.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('No recent projects', style: TextStyle(fontSize: 12, color: theme.textDisabled)),
                );
              }
              return Column(
                children: projects.take(8).map((p) {
                  return _RecentRow(
                    theme: theme,
                    project: p,
                    onTap: () async {
                      await ref.read(vecDocumentStateProvider.notifier).openFile(p.filePath);
                      if (context.mounted) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditorScreen()));
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecentRow extends StatefulWidget {
  const _RecentRow({required this.theme, required this.project, required this.onTap});

  final AppTheme theme;
  final RecentProject project;
  final VoidCallback onTap;

  @override
  State<_RecentRow> createState() => _RecentRowState();
}

class _RecentRowState extends State<_RecentRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final sizes = theme.sizes;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.symmetric(horizontal: sizes.sm - 2, vertical: sizes.xs),
          margin: EdgeInsets.only(bottom: sizes.xxs / 2),
          decoration: BoxDecoration(
            color: _hovering ? theme.primaryColor.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: theme.radii.small,
          ),
          child: Row(
            children: [
              Icon(
                MaterialCommunityIcons.vector_square,
                size: sizes.iconSm - 2,
                color: _hovering ? theme.primaryColor : theme.textDisabled,
              ),
              SizedBox(width: sizes.sm - 2),
              Expanded(
                child: Text(
                  widget.project.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _hovering ? theme.textPrimary : theme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: sizes.xs),
              Text(
                _formatDate(widget.project.modifiedAt),
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, color: theme.textDisabled),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Templates area (right side of wide layout)
// =============================================================================

class _TemplatesArea extends ConsumerWidget {
  const _TemplatesArea({required this.theme});
  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizes = theme.sizes;
    final textTheme = theme.textTheme;
    final categories = <String, List<_Template>>{};
    for (final t in _templates) {
      categories.putIfAbsent(t.category, () => []).add(t);
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(sizes.xxl + sizes.xs, sizes.xxl + sizes.sm, sizes.xxl + sizes.xs, sizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start from a template',
            style: textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w700, color: theme.textPrimary),
          ),
          SizedBox(height: sizes.xxs),
          Text(
            'Pick a canvas size and start creating',
            style: textTheme.bodyMedium?.copyWith(fontSize: 13, color: theme.textSecondary),
          ),
          SizedBox(height: sizes.xl + sizes.xs),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...categories.entries.map((entry) {
                    return _TemplateCategorySection(theme: theme, category: entry.key, templates: entry.value);
                  }),
                  _ArtworkTemplatesSection(theme: theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Templates section (narrow layout — inline, no scroll wrapper)
// =============================================================================

class _TemplatesSection extends ConsumerWidget {
  const _TemplatesSection({required this.theme});
  final AppTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizes = theme.sizes;
    final textTheme = theme.textTheme;
    final categories = <String, List<_Template>>{};
    for (final t in _templates) {
      categories.putIfAbsent(t.category, () => []).add(t);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Templates',
          style: textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700, color: theme.textPrimary),
        ),
        SizedBox(height: sizes.xxs),
        Text(
          'Pick a canvas size and start creating',
          style: textTheme.bodyMedium?.copyWith(fontSize: 13, color: theme.textSecondary),
        ),
        SizedBox(height: sizes.lg),
        ...categories.entries.map((entry) {
          return _TemplateCategorySection(theme: theme, category: entry.key, templates: entry.value);
        }),
        _ArtworkTemplatesSection(theme: theme),
      ],
    );
  }
}

// =============================================================================
// Template category section
// =============================================================================

class _TemplateCategorySection extends StatelessWidget {
  const _TemplateCategorySection({required this.theme, required this.category, required this.templates});

  final AppTheme theme;
  final String category;
  final List<_Template> templates;

  @override
  Widget build(BuildContext context) {
    final sizes = theme.sizes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              category.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: theme.textDisabled,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(width: sizes.xs),
            Expanded(child: Divider(color: theme.divider.withValues(alpha: 0.2), height: 1)),
          ],
        ),
        SizedBox(height: sizes.sm - 2),
        Wrap(
          spacing: sizes.sm - 2,
          runSpacing: sizes.sm - 2,
          children: templates.map((t) => _TemplateCard(theme: theme, template: t)).toList(),
        ),
        SizedBox(height: sizes.xl),
      ],
    );
  }
}

// =============================================================================
// Template card
// =============================================================================

class _TemplateCard extends ConsumerStatefulWidget {
  const _TemplateCard({required this.theme, required this.template});

  final AppTheme theme;
  final _Template template;

  @override
  ConsumerState<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends ConsumerState<_TemplateCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final t = widget.template;
    final sizes = theme.sizes;
    final textTheme = theme.textTheme;
    final aspect = (t.width / t.height).clamp(0.3, 4.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _createFromTemplate(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: sizes.xxl * 5,
          padding: EdgeInsets.all(sizes.sm + 2),
          decoration: BoxDecoration(
            color: _hovering ? theme.surfaceVariant : theme.surface.withValues(alpha: 0.45),
            borderRadius: theme.radii.large,
            border: Border.all(
              color: _hovering ? theme.primaryColor.withValues(alpha: 0.5) : theme.divider.withValues(alpha: 0.2),
              width: theme.borders.thin,
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.08),
                      blurRadius: sizes.lg * 0.6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: sizes.xxl + sizes.lg,
                  alignment: Alignment.center,
                  child: AspectRatio(
                    aspectRatio: aspect,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _hovering
                            ? theme.primaryColor.withValues(alpha: 0.12)
                            : theme.surfaceVariant.withValues(alpha: 0.8),
                        borderRadius: theme.radii.extraSmall,
                        border: Border.all(
                          color: _hovering
                              ? theme.primaryColor.withValues(alpha: 0.3)
                              : theme.divider.withValues(alpha: 0.3),
                          width: theme.borders.thin,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          t.icon,
                          size: sizes.iconSm,
                          color: _hovering ? theme.primaryColor : theme.textDisabled,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: sizes.sm - 2),
              Text(
                t.name,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _hovering ? theme.primaryColor : theme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: sizes.xxs / 2),
              Text(
                t.sizeLabel,
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: theme.textDisabled,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createFromTemplate(BuildContext context) {
    final t = widget.template;
    ref
        .read(vecDocumentStateProvider.notifier)
        .newDocument(name: t.name, stageWidth: t.width, stageHeight: t.height, fps: t.fps);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditorScreen()));
  }
}

class _ArtworkTemplatesSection extends StatelessWidget {
  const _ArtworkTemplatesSection({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final sizes = theme.sizes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ARTWORK TEMPLATES',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: theme.textDisabled,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(width: sizes.xs),
            Expanded(child: Divider(color: theme.divider.withValues(alpha: 0.2), height: 1)),
          ],
        ),
        SizedBox(height: sizes.sm - 2),
        Wrap(
          spacing: sizes.sm - 2,
          runSpacing: sizes.sm - 2,
          children: _artworkTemplates.map((t) => _ArtworkTemplateCard(theme: theme, template: t)).toList(),
        ),
        SizedBox(height: sizes.xl),
      ],
    );
  }
}

class _ArtworkTemplateCard extends ConsumerStatefulWidget {
  const _ArtworkTemplateCard({required this.theme, required this.template});

  final AppTheme theme;
  final _ArtworkTemplate template;

  @override
  ConsumerState<_ArtworkTemplateCard> createState() => _ArtworkTemplateCardState();
}

class _ArtworkTemplateCardState extends ConsumerState<_ArtworkTemplateCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final t = widget.template;
    final sizes = theme.sizes;
    final textTheme = theme.textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _createFromArtworkTemplate(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: sizes.xxl * 5,
          padding: EdgeInsets.all(sizes.sm + 2),
          decoration: BoxDecoration(
            color: _hovering ? theme.surfaceVariant : theme.surface.withValues(alpha: 0.45),
            borderRadius: theme.radii.large,
            border: Border.all(
              color: _hovering ? theme.primaryColor.withValues(alpha: 0.5) : theme.divider.withValues(alpha: 0.2),
              width: theme.borders.thin,
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.08),
                      blurRadius: sizes.lg * 0.6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: sizes.xxl + sizes.lg,
                  width: sizes.xxl * 2 + sizes.xs,
                  decoration: BoxDecoration(
                    color: _hovering
                        ? theme.primaryColor.withValues(alpha: 0.12)
                        : theme.surfaceVariant.withValues(alpha: 0.8),
                    borderRadius: theme.radii.small,
                    border: Border.all(
                      color: _hovering
                          ? theme.primaryColor.withValues(alpha: 0.3)
                          : theme.divider.withValues(alpha: 0.3),
                      width: theme.borders.thin,
                    ),
                  ),
                  padding: EdgeInsets.all(sizes.xxs + 2),
                  child: SvgPicture.asset(
                    t.assetPath,
                    fit: BoxFit.contain,
                    placeholderBuilder: (_) => Icon(
                      Icons.image_outlined,
                      size: sizes.iconSm + 2,
                      color: _hovering ? theme.primaryColor : theme.textDisabled,
                    ),
                  ),
                ),
              ),
              SizedBox(height: sizes.sm - 2),
              Text(
                t.name,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _hovering ? theme.primaryColor : theme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: sizes.xxs / 2),
              Text(
                t.description,
                style: textTheme.labelSmall?.copyWith(fontSize: 10, color: theme.textDisabled),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createFromArtworkTemplate(BuildContext context) async {
    final t = widget.template;
    final notifier = ref.read(vecDocumentStateProvider.notifier);
    const stageW = 1080.0;
    const stageH = 1080.0;
    notifier.newDocument(name: t.name, stageWidth: stageW, stageHeight: stageH, fps: 24);

    try {
      final svgContent = await rootBundle.loadString(t.assetPath);
      const importer = SvgImporter();
      final imported = importer.import(svgContent);
      final shapes = _centerShapesOnStage(imported, stageW, stageH);

      final doc = ref.read(vecDocumentStateProvider);
      if (doc.scenes.isNotEmpty && doc.scenes.first.layers.isNotEmpty && shapes.isNotEmpty) {
        final scene = doc.scenes.first;
        final layer = scene.layers.first;
        notifier.addShapes(scene.id, layer.id, shapes);
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not load artwork template.')));
      return;
    }

    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditorScreen()));
  }
}

List<VecShape> _centerShapesOnStage(List<VecShape> shapes, double stageW, double stageH) {
  if (shapes.isEmpty) return const [];

  final bounds = _shapesBounds(shapes);
  if (bounds == null) return shapes;

  final contentCx = bounds.$1 + bounds.$3 / 2;
  final contentCy = bounds.$2 + bounds.$4 / 2;
  final stageCx = stageW / 2;
  final stageCy = stageH / 2;
  final dx = stageCx - contentCx;
  final dy = stageCy - contentCy;

  if (dx == 0 && dy == 0) return shapes;
  return shapes.map((s) => _translateShape(s, dx, dy)).toList();
}

/// Returns (minX, minY, width, height) for shape bounds in stage space.
(double, double, double, double)? _shapesBounds(List<VecShape> shapes) {
  double? minX;
  double? minY;
  double? maxX;
  double? maxY;

  void includeRect(double x, double y, double w, double h) {
    final right = x + w;
    final bottom = y + h;
    minX = minX == null ? x : (x < minX! ? x : minX);
    minY = minY == null ? y : (y < minY! ? y : minY);
    maxX = maxX == null ? right : (right > maxX! ? right : maxX);
    maxY = maxY == null ? bottom : (bottom > maxY! ? bottom : maxY);
  }

  void walk(VecShape shape, double parentX, double parentY) {
    shape.map(
      path: (s) {
        includeRect(
          parentX + s.data.transform.x,
          parentY + s.data.transform.y,
          s.data.transform.width,
          s.data.transform.height,
        );
      },
      rectangle: (s) {
        includeRect(
          parentX + s.data.transform.x,
          parentY + s.data.transform.y,
          s.data.transform.width,
          s.data.transform.height,
        );
      },
      ellipse: (s) {
        includeRect(
          parentX + s.data.transform.x,
          parentY + s.data.transform.y,
          s.data.transform.width,
          s.data.transform.height,
        );
      },
      polygon: (s) {
        includeRect(
          parentX + s.data.transform.x,
          parentY + s.data.transform.y,
          s.data.transform.width,
          s.data.transform.height,
        );
      },
      text: (s) {
        includeRect(
          parentX + s.data.transform.x,
          parentY + s.data.transform.y,
          s.data.transform.width,
          s.data.transform.height,
        );
      },
      symbolInstance: (s) {
        includeRect(
          parentX + s.data.transform.x,
          parentY + s.data.transform.y,
          s.data.transform.width,
          s.data.transform.height,
        );
      },
      compound: (s) {
        includeRect(
          parentX + s.data.transform.x,
          parentY + s.data.transform.y,
          s.data.transform.width,
          s.data.transform.height,
        );
      },
      image: (s) {
        includeRect(
          parentX + s.data.transform.x,
          parentY + s.data.transform.y,
          s.data.transform.width,
          s.data.transform.height,
        );
      },
      group: (s) {
        final gx = parentX + s.data.transform.x;
        final gy = parentY + s.data.transform.y;
        if (s.children.isEmpty) {
          includeRect(gx, gy, s.data.transform.width, s.data.transform.height);
          return;
        }
        for (final child in s.children) {
          walk(child, gx, gy);
        }
      },
    );
  }

  for (final shape in shapes) {
    walk(shape, 0, 0);
  }

  if (minX == null || minY == null || maxX == null || maxY == null) return null;
  return (minX!, minY!, maxX! - minX!, maxY! - minY!);
}

VecShape _translateShape(VecShape shape, double dx, double dy) {
  VecShapeData shift(VecShapeData d) => d.copyWith(
    transform: d.transform.copyWith(x: d.transform.x + dx, y: d.transform.y + dy),
  );

  return shape.map(
    path: (s) => s.copyWith(data: shift(s.data)),
    rectangle: (s) => s.copyWith(data: shift(s.data)),
    ellipse: (s) => s.copyWith(data: shift(s.data)),
    polygon: (s) => s.copyWith(data: shift(s.data)),
    text: (s) => s.copyWith(data: shift(s.data)),
    symbolInstance: (s) => s.copyWith(data: shift(s.data)),
    compound: (s) => s.copyWith(data: shift(s.data)),
    image: (s) => s.copyWith(data: shift(s.data)),
    group: (s) => s.copyWith(data: shift(s.data)),
  );
}

// =============================================================================
// Image drop helpers
// =============================================================================

const _kImageExtensions = {'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'};

String _mimeFromExt(String ext) => switch (ext) {
  'png' => 'image/png',
  'jpg' || 'jpeg' => 'image/jpeg',
  'gif' => 'image/gif',
  'bmp' => 'image/bmp',
  'webp' => 'image/webp',
  _ => 'image/*',
};

/// Top-level function so it can be passed to [compute].
(int, int)? _decodeImageDimensions(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  return (decoded.width, decoded.height);
}

// =============================================================================
// Drop overlay
// =============================================================================

class _DropOverlay extends StatelessWidget {
  const _DropOverlay({required this.theme, required this.message});

  final AppTheme theme;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: theme.primaryColor.withValues(alpha: 0.12),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: theme.surface.withValues(alpha: 0.95),
              borderRadius: theme.radii.large,
              border: Border.all(color: theme.primaryColor, width: 2),
              boxShadow: [
                BoxShadow(color: theme.primaryColor.withValues(alpha: 0.2), blurRadius: 24, spreadRadius: 4),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.file_download_outlined, size: 48, color: theme.primaryColor),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Bottom bar
// =============================================================================

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.theme});
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final sizes = theme.sizes;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sizes.xl + sizes.sm),
      child: Row(
        children: [
          Text(
            'v1.0.0',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: theme.textDisabled,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: sizes.xs),
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(color: theme.textDisabled, shape: BoxShape.circle),
          ),
          SizedBox(width: sizes.xs),
          Text('Flutter', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, color: theme.textDisabled)),
        ],
      ),
    );
  }
}

// =============================================================================
// Helpers
// =============================================================================

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';

  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}';
}
