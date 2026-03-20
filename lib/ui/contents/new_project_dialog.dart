import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/theme/theme.dart';
import '../../data/models/vec_color.dart';
import '../../data/models/vec_document.dart';
import '../contents/theme_selector.dart';

// =============================================================================
// Preset templates
// =============================================================================

class _Preset {
  final String name;
  final String subtitle;
  final IconData icon;
  final double width;
  final double height;
  final int fps;

  const _Preset({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.width,
    required this.height,
    required this.fps,
  });
}

const _presets = [
  _Preset(name: 'HD 1080p', subtitle: '1920 x 1080', icon: Icons.tv, width: 1920, height: 1080, fps: 24),
  _Preset(name: 'HD 720p', subtitle: '1280 x 720', icon: Icons.personal_video, width: 1280, height: 720, fps: 24),
  _Preset(name: '4K UHD', subtitle: '3840 x 2160', icon: Icons.monitor, width: 3840, height: 2160, fps: 24),
  _Preset(name: 'Square', subtitle: '1080 x 1080', icon: Icons.crop_square_rounded, width: 1080, height: 1080, fps: 24),
  _Preset(name: 'Instagram Story', subtitle: '1080 x 1920', icon: Icons.smartphone, width: 1080, height: 1920, fps: 30),
  _Preset(name: 'Web Banner', subtitle: '728 x 90', icon: Icons.web, width: 728, height: 90, fps: 24),
  _Preset(name: 'Icon', subtitle: '512 x 512', icon: Icons.apps, width: 512, height: 512, fps: 12),
  _Preset(name: 'Custom', subtitle: 'Set your own', icon: Icons.tune, width: 1920, height: 1080, fps: 24),
];

const _fpsOptions = [12, 15, 24, 25, 30, 60];

// =============================================================================
// Result class
// =============================================================================

class NewProjectResult {
  final String name;
  final double width;
  final double height;
  final int fps;
  final Color backgroundColor;

  const NewProjectResult({
    required this.name,
    required this.width,
    required this.height,
    required this.fps,
    required this.backgroundColor,
  });
}

// =============================================================================
// Dialog
// =============================================================================

class NewProjectDialog extends HookConsumerWidget {
  const NewProjectDialog({super.key});

  static Future<NewProjectResult?> show(BuildContext context) {
    return showDialog<NewProjectResult>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => const NewProjectDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).theme;
    final screenSize = MediaQuery.sizeOf(context);
    final isCompact = screenSize.width < 700;

    final nameController = useTextEditingController(text: 'Untitled');
    final widthController = useTextEditingController(text: '1920');
    final heightController = useTextEditingController(text: '1080');

    final selectedPreset = useState(0); // HD 1080p
    final selectedFps = useState(24);
    final bgColor = useState(Colors.white);
    final isCustom = useState(false);

    // Sync preset → fields
    void applyPreset(int index) {
      selectedPreset.value = index;
      final preset = _presets[index];
      widthController.text = preset.width.toInt().toString();
      heightController.text = preset.height.toInt().toString();
      selectedFps.value = preset.fps;
      isCustom.value = preset.name == 'Custom';
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 40,
        vertical: isCompact ? 24 : 40,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isCompact ? double.infinity : 720,
          maxHeight: screenSize.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.divider.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────
            _DialogHeader(theme: theme),

            // ── Body ────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project name
                    _SectionLabel(theme: theme, label: 'PROJECT NAME'),
                    const SizedBox(height: 8),
                    _NameField(theme: theme, controller: nameController),

                    const SizedBox(height: 24),

                    // Presets
                    _SectionLabel(theme: theme, label: 'CANVAS PRESET'),
                    const SizedBox(height: 10),
                    _PresetGrid(
                      theme: theme,
                      selectedIndex: selectedPreset.value,
                      onSelect: applyPreset,
                    ),

                    const SizedBox(height: 24),

                    // Dimensions + FPS
                    _SectionLabel(theme: theme, label: 'DIMENSIONS & FRAME RATE'),
                    const SizedBox(height: 10),
                    _DimensionsRow(
                      theme: theme,
                      widthController: widthController,
                      heightController: heightController,
                      isCustom: isCustom.value || selectedPreset.value == _presets.length - 1,
                      onChanged: () {
                        // Mark as custom if user edits
                        selectedPreset.value = _presets.length - 1;
                        isCustom.value = true;
                      },
                    ),
                    const SizedBox(height: 14),
                    _FpsSelector(
                      theme: theme,
                      selectedFps: selectedFps.value,
                      onSelect: (fps) => selectedFps.value = fps,
                    ),

                    const SizedBox(height: 24),

                    // Background color
                    _SectionLabel(theme: theme, label: 'BACKGROUND COLOR'),
                    const SizedBox(height: 10),
                    _BackgroundColorRow(
                      theme: theme,
                      selectedColor: bgColor.value,
                      onSelect: (c) => bgColor.value = c,
                    ),

                    const SizedBox(height: 24),

                    // Preview
                    _CanvasPreview(
                      theme: theme,
                      width: double.tryParse(widthController.text) ?? 1920,
                      height: double.tryParse(heightController.text) ?? 1080,
                      bgColor: bgColor.value,
                      fps: selectedFps.value,
                      name: nameController.text,
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Footer ──────────────────────────────────────────────
            _DialogFooter(
              theme: theme,
              onCancel: () => Navigator.of(context).pop(),
              onCreate: () {
                final name = nameController.text.trim().isEmpty ? 'Untitled' : nameController.text.trim();
                final w = double.tryParse(widthController.text) ?? 1920;
                final h = double.tryParse(heightController.text) ?? 1080;
                Navigator.of(context).pop(NewProjectResult(
                  name: name,
                  width: w.clamp(1, 16384),
                  height: h.clamp(1, 16384),
                  fps: selectedFps.value,
                  backgroundColor: bgColor.value,
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Header
// =============================================================================

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.theme});

  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 20, 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.divider.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.primaryColor, theme.accentColor],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.add_rounded, size: 22, color: theme.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Project',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Configure your canvas and get started',
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close_rounded, size: 20, color: theme.textDisabled),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Footer
// =============================================================================

class _DialogFooter extends StatelessWidget {
  const _DialogFooter({required this.theme, required this.onCancel, required this.onCreate});

  final AppTheme theme;
  final VoidCallback onCancel;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.divider.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          // Keyboard hint
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _KeyHint(theme: theme, label: 'Esc'),
              const SizedBox(width: 4),
              Text('cancel', style: TextStyle(fontSize: 10, color: theme.textDisabled)),
              const SizedBox(width: 12),
              _KeyHint(theme: theme, label: 'Enter'),
              const SizedBox(width: 4),
              Text('create', style: TextStyle(fontSize: 10, color: theme.textDisabled)),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: onCancel,
            child: Text('Cancel', style: TextStyle(color: theme.textSecondary)),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.rocket_launch_rounded, size: 16),
            label: const Text('Create Project'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyHint extends StatelessWidget {
  const _KeyHint({required this.theme, required this.label});

  final AppTheme theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.divider.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: theme.textDisabled),
      ),
    );
  }
}

// =============================================================================
// Section label
// =============================================================================

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.theme, required this.label});

  final AppTheme theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: theme.textDisabled,
        letterSpacing: 1.2,
      ),
    );
  }
}

// =============================================================================
// Name field
// =============================================================================

class _NameField extends StatelessWidget {
  const _NameField({required this.theme, required this.controller});

  final AppTheme theme;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: theme.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'My awesome animation',
        hintStyle: TextStyle(color: theme.textDisabled, fontWeight: FontWeight.w400),
        filled: true,
        fillColor: theme.surfaceVariant.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(MaterialCommunityIcons.rename_box, size: 18, color: theme.primaryColor),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.divider.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.divider.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
        ),
      ),
    );
  }
}

// =============================================================================
// Preset grid
// =============================================================================

class _PresetGrid extends StatelessWidget {
  const _PresetGrid({required this.theme, required this.selectedIndex, required this.onSelect});

  final AppTheme theme;
  final int selectedIndex;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_presets.length, (i) {
        final preset = _presets[i];
        final isSelected = selectedIndex == i;
        return _PresetChip(
          theme: theme,
          preset: preset,
          isSelected: isSelected,
          onTap: () => onSelect(i),
        );
      }),
    );
  }
}

class _PresetChip extends StatefulWidget {
  const _PresetChip({required this.theme, required this.preset, required this.isSelected, required this.onTap});

  final AppTheme theme;
  final _Preset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_PresetChip> createState() => _PresetChipState();
}

class _PresetChipState extends State<_PresetChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isSelected = widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor.withOpacity(0.12)
                : (_hovering ? theme.surfaceVariant : theme.surfaceVariant.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? theme.primaryColor : theme.divider.withOpacity(_hovering ? 0.5 : 0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.preset.icon,
                size: 16,
                color: isSelected ? theme.primaryColor : theme.textSecondary,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.preset.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? theme.primaryColor : theme.textPrimary,
                    ),
                  ),
                  Text(
                    widget.preset.subtitle,
                    style: TextStyle(fontSize: 9, color: theme.textDisabled),
                  ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_circle_rounded, size: 14, color: theme.primaryColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Dimensions row
// =============================================================================

class _DimensionsRow extends StatelessWidget {
  const _DimensionsRow({
    required this.theme,
    required this.widthController,
    required this.heightController,
    required this.isCustom,
    required this.onChanged,
  });

  final AppTheme theme;
  final TextEditingController widthController;
  final TextEditingController heightController;
  final bool isCustom;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DimensionField(
            theme: theme,
            label: 'Width',
            controller: widthController,
            suffix: 'px',
            enabled: isCustom,
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.close_rounded, size: 14, color: theme.textDisabled),
        ),
        Expanded(
          child: _DimensionField(
            theme: theme,
            label: 'Height',
            controller: heightController,
            suffix: 'px',
            enabled: isCustom,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _DimensionField extends StatelessWidget {
  const _DimensionField({
    required this.theme,
    required this.label,
    required this.controller,
    required this.suffix,
    required this.enabled,
    required this.onChanged,
  });

  final AppTheme theme;
  final String label;
  final TextEditingController controller;
  final String suffix;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => onChanged(),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: enabled ? theme.textPrimary : theme.textDisabled,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: theme.textSecondary),
        suffixText: suffix,
        suffixStyle: TextStyle(fontSize: 11, color: theme.textDisabled),
        filled: true,
        fillColor: enabled ? theme.surfaceVariant.withOpacity(0.5) : theme.surfaceVariant.withOpacity(0.25),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.divider.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.divider.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.divider.withOpacity(0.15)),
        ),
      ),
    );
  }
}

// =============================================================================
// FPS selector
// =============================================================================

class _FpsSelector extends StatelessWidget {
  const _FpsSelector({required this.theme, required this.selectedFps, required this.onSelect});

  final AppTheme theme;
  final int selectedFps;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(MaterialCommunityIcons.timer_outline, size: 16, color: theme.textSecondary),
        const SizedBox(width: 8),
        Text('FPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
        const SizedBox(width: 14),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _fpsOptions.map((fps) {
              final isSelected = fps == selectedFps;
              return _FpsChip(
                theme: theme,
                fps: fps,
                isSelected: isSelected,
                onTap: () => onSelect(fps),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _FpsChip extends StatefulWidget {
  const _FpsChip({required this.theme, required this.fps, required this.isSelected, required this.onTap});

  final AppTheme theme;
  final int fps;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_FpsChip> createState() => _FpsChipState();
}

class _FpsChipState extends State<_FpsChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isSelected = widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor
                : (_hovering ? theme.surfaceVariant : theme.surfaceVariant.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? theme.primaryColor : theme.divider.withOpacity(_hovering ? 0.5 : 0.2),
            ),
          ),
          child: Text(
            '${widget.fps}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? theme.onPrimary : theme.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Background color row
// =============================================================================

const _bgColorOptions = [
  ('White', Colors.white),
  ('Black', Colors.black),
  ('Transparent', Colors.transparent),
];

class _BackgroundColorRow extends StatelessWidget {
  const _BackgroundColorRow({required this.theme, required this.selectedColor, required this.onSelect});

  final AppTheme theme;
  final Color selectedColor;
  final void Function(Color) onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _bgColorOptions.map((opt) {
        final (label, color) = opt;
        final isSelected = selectedColor == color;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _ColorOption(
            theme: theme,
            label: label,
            color: color,
            isSelected: isSelected,
            onTap: () => onSelect(color),
          ),
        );
      }).toList(),
    );
  }
}

class _ColorOption extends StatefulWidget {
  const _ColorOption({
    required this.theme,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final AppTheme theme;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_ColorOption> createState() => _ColorOptionState();
}

class _ColorOptionState extends State<_ColorOption> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isSelected = widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor.withOpacity(0.1)
                : (_hovering ? theme.surfaceVariant : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? theme.primaryColor : theme.divider.withOpacity(_hovering ? 0.5 : 0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color swatch
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.divider.withOpacity(0.4)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: widget.color == Colors.transparent
                      ? CustomPaint(painter: _CheckerPainter())
                      : ColoredBox(color: widget.color),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? theme.primaryColor : theme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 4.0;
    final light = Paint()..color = Colors.white;
    final dark = Paint()..color = const Color(0xFFCCCCCC);

    for (var y = 0.0; y < size.height; y += cellSize) {
      for (var x = 0.0; x < size.width; x += cellSize) {
        final isLight = ((x / cellSize).floor() + (y / cellSize).floor()) % 2 == 0;
        canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), isLight ? light : dark);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// Canvas preview
// =============================================================================

class _CanvasPreview extends HookWidget {
  const _CanvasPreview({
    required this.theme,
    required this.width,
    required this.height,
    required this.bgColor,
    required this.fps,
    required this.name,
  });

  final AppTheme theme;
  final double width;
  final double height;
  final Color bgColor;
  final int fps;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (width <= 0 || height <= 0) return const SizedBox.shrink();

    final aspectRatio = width / height;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.divider.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          // Mini preview canvas
          Container(
            height: 100,
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: aspectRatio.clamp(0.2, 5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor == Colors.transparent ? null : bgColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.divider.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: bgColor == Colors.transparent
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: CustomPaint(painter: _CheckerPainter(), child: const SizedBox.expand()),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Summary line
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SummaryTag(
                theme: theme,
                icon: Icons.aspect_ratio_rounded,
                text: '${width.toInt()} x ${height.toInt()}',
              ),
              const SizedBox(width: 12),
              _SummaryTag(
                theme: theme,
                icon: MaterialCommunityIcons.timer_outline,
                text: '${fps}fps',
              ),
              const SizedBox(width: 12),
              _SummaryTag(
                theme: theme,
                icon: Icons.palette_outlined,
                text: bgColor == Colors.transparent
                    ? 'Transparent'
                    : bgColor == Colors.white
                        ? 'White'
                        : 'Black',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryTag extends StatelessWidget {
  const _SummaryTag({required this.theme, required this.icon, required this.text});

  final AppTheme theme;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: theme.textDisabled),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: theme.textSecondary,
            fontWeight: FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
