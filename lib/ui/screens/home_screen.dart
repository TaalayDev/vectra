import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/theme/theme.dart';
import '../../data/models/vec_color.dart';
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
  final Color? accentOverride; // optional tint for the preview

  const _Template({
    required this.name,
    required this.category,
    required this.icon,
    required this.width,
    required this.height,
    this.fps = 24,
    this.accentOverride,
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
  _Template(name: 'Instagram Post', category: 'Social', icon: Icons.crop_square_rounded, width: 1080, height: 1080, fps: 30),
  _Template(name: 'Instagram Story', category: 'Social', icon: Icons.smartphone, width: 1080, height: 1920, fps: 30),
  _Template(name: 'YouTube Thumbnail', category: 'Social', icon: Icons.play_circle_outline, width: 1280, height: 720),
  _Template(name: 'Twitter/X Header', category: 'Social', icon: Icons.panorama_wide_angle_rounded, width: 1500, height: 500),
  // Web
  _Template(name: 'Web Banner', category: 'Web', icon: Icons.web, width: 728, height: 90),
  _Template(name: 'Leaderboard', category: 'Web', icon: Icons.view_column_outlined, width: 970, height: 250),
  _Template(name: 'Skyscraper', category: 'Web', icon: Icons.view_sidebar_outlined, width: 160, height: 600),
  // Design
  _Template(name: 'App Icon', category: 'Design', icon: Icons.apps, width: 512, height: 512, fps: 12),
  _Template(name: 'Favicon', category: 'Design', icon: Icons.tab_rounded, width: 64, height: 64, fps: 12),
  _Template(name: 'A4 Portrait', category: 'Design', icon: Icons.description_outlined, width: 2480, height: 3508, fps: 1),
  _Template(name: 'Presentation', category: 'Design', icon: Icons.slideshow_rounded, width: 1920, height: 1080),
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

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(
              intensity: 0.15,
              enableAnimation: true,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.background.withOpacity(0.95),
                    theme.background.withOpacity(0.85),
                    Color.lerp(theme.background, theme.primaryColor, 0.03)!.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: isWide
                ? _WideLayout(theme: theme, recentProjects: recentProjects)
                : _NarrowLayout(theme: theme, recentProjects: recentProjects, isMedium: isMedium),
          ),
        ],
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
        Container(width: 1, color: theme.divider.withOpacity(0.3)),
        // Right — templates
        Expanded(
          child: _TemplatesArea(theme: theme),
        ),
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
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMedium ? 48 : 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LogoHeader(theme: theme),
          const SizedBox(height: 28),
          _ActionButtons(theme: theme),
          const SizedBox(height: 32),
          _TemplatesSection(theme: theme),
          const SizedBox(height: 32),
          _RecentProjectsCompact(theme: theme, recentProjects: recentProjects),
          const SizedBox(height: 24),
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
    return Container(
      color: theme.surface.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          _LogoHeader(theme: theme),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: _ActionButtons(theme: theme),
          ),
          const SizedBox(height: 28),
          // Recent projects — compact list
          Expanded(
            child: _RecentProjectsCompact(theme: theme, recentProjects: recentProjects),
          ),
          const SizedBox(height: 8),
          _BottomBar(theme: theme),
          const SizedBox(height: 12),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.primaryColor, theme.accentColor],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 3)),
              ],
            ),
            child: Center(
              child: Text(
                'V',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: theme.onPrimary, letterSpacing: -1),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vectra',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: theme.textPrimary, letterSpacing: -0.5),
              ),
              Text(
                'Vector Animation Studio',
                style: TextStyle(fontSize: 11, color: theme.textSecondary, letterSpacing: 0.3),
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
    ref.read(vecDocumentStateProvider.notifier).newDocument(
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
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? (_hovering ? theme.primaryColor : theme.primaryColor.withOpacity(0.9))
                : (_hovering ? theme.surfaceVariant : theme.surface.withOpacity(0.6)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isPrimary
                  ? theme.primaryColor
                  : (_hovering ? theme.primaryColor.withOpacity(0.4) : theme.divider.withOpacity(0.3)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 16, color: widget.isPrimary ? theme.onPrimary : theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, size: 14, color: theme.textDisabled),
              const SizedBox(width: 6),
              Text(
                'RECENT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: theme.textDisabled,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          recentProjects.when(
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: theme.primaryColor, strokeWidth: 1.5))),
            ),
            error: (_, __) => Text('Could not load projects', style: TextStyle(fontSize: 12, color: theme.textDisabled)),
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
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: _hovering ? theme.primaryColor.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                MaterialCommunityIcons.vector_square,
                size: 14,
                color: _hovering ? theme.primaryColor : theme.textDisabled,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.project.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _hovering ? theme.textPrimary : theme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(widget.project.modifiedAt),
                style: TextStyle(fontSize: 10, color: theme.textDisabled),
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
    final categories = <String, List<_Template>>{};
    for (final t in _templates) {
      categories.putIfAbsent(t.category, () => []).add(t);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 40, 36, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start from a template',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: theme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Pick a canvas size and start creating',
            style: TextStyle(fontSize: 13, color: theme.textSecondary),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categories.entries.map((entry) {
                  return _TemplateCategorySection(
                    theme: theme,
                    category: entry.key,
                    templates: entry.value,
                  );
                }).toList(),
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
    final categories = <String, List<_Template>>{};
    for (final t in _templates) {
      categories.putIfAbsent(t.category, () => []).add(t);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Templates',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: theme.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Pick a canvas size and start creating',
          style: TextStyle(fontSize: 13, color: theme.textSecondary),
        ),
        const SizedBox(height: 20),
        ...categories.entries.map((entry) {
          return _TemplateCategorySection(
            theme: theme,
            category: entry.key,
            templates: entry.value,
          );
        }),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              category.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: theme.textDisabled,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Divider(color: theme.divider.withOpacity(0.2), height: 1)),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: templates.map((t) => _TemplateCard(theme: theme, template: t)).toList(),
        ),
        const SizedBox(height: 24),
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
    final aspect = (t.width / t.height).clamp(0.3, 4.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _createFromTemplate(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 155,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hovering ? theme.surfaceVariant : theme.surface.withOpacity(0.45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovering ? theme.primaryColor.withOpacity(0.5) : theme.divider.withOpacity(0.2),
            ),
            boxShadow: _hovering
                ? [BoxShadow(color: theme.primaryColor.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 3))]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aspect ratio preview
              Center(
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: AspectRatio(
                    aspectRatio: aspect,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _hovering
                            ? theme.primaryColor.withOpacity(0.12)
                            : theme.surfaceVariant.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _hovering ? theme.primaryColor.withOpacity(0.3) : theme.divider.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          t.icon,
                          size: 16,
                          color: _hovering ? theme.primaryColor : theme.textDisabled,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _hovering ? theme.primaryColor : theme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                t.sizeLabel,
                style: TextStyle(
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
    ref.read(vecDocumentStateProvider.notifier).newDocument(
          name: 'Untitled',
          stageWidth: t.width,
          stageHeight: t.height,
          fps: t.fps,
        );
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditorScreen()));
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          Text('v1.0.0', style: TextStyle(fontSize: 10, color: theme.textDisabled, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Container(width: 3, height: 3, decoration: BoxDecoration(color: theme.textDisabled, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('Flutter', style: TextStyle(fontSize: 10, color: theme.textDisabled)),
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
