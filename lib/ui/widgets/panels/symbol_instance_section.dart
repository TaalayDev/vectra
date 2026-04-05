import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_color.dart';
import '../../../data/models/vec_shape.dart';
import '../../../data/models/vec_symbol.dart';
import '../../../data/models/vec_timeline.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import '../common/collapsible_section.dart';
import '../common/color_picker.dart';
import '../common/numeric_input.dart';
import 'properties_sections.dart';

class SymbolInstanceSection extends ConsumerWidget {
  const SymbolInstanceSection({
    super.key,
    required this.shape,
    required this.theme,
    required this.onUpdate,
    required this.onLiveUpdate,
    required this.onCommit,
  });

  final VecSymbolInstanceShape shape;
  final AppTheme theme;
  final ShapeCommit onUpdate;
  final ShapeLiveUpdate onLiveUpdate;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbols = ref.watch(symbolLibraryProvider);
    final resolvedSymbol = symbols.cast<VecSymbol?>().firstWhere(
      (s) => s!.id == shape.symbolId,
      orElse: () => null,
    );

    return CollapsibleSection(
      title: 'Symbol',
      theme: theme,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symbol reference dropdown
          _buildLabel('Master Symbol'),
          const SizedBox(height: 4),
          _SymbolDropdown(
            symbols: symbols,
            selectedId: shape.symbolId,
            theme: theme,
            onChanged: (id) => onUpdate(
              (s) => s.maybeMap(
                symbolInstance: (si) => si.copyWith(symbolId: id),
                orElse: () => s,
              ),
            ),
          ),

          if (resolvedSymbol == null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.warning_amber_outlined, size: 12, color: theme.error),
                const SizedBox(width: 4),
                Text(
                  'Symbol not found in library',
                  style: TextStyle(fontSize: 10, color: theme.error),
                ),
              ],
            ),
          ] else ...[
            // Variants UI
            Builder(
              builder: (context) {
                final parts = resolvedSymbol.name.split('/').map((s) => s.trim()).toList();
                if (parts.length <= 1) return const SizedBox.shrink();
                
                final baseName = parts.first;
                final siblingSymbols = symbols.cast<VecSymbol>().where((s) {
                  final sParts = s.name.split('/').map((x) => x.trim()).toList();
                  return sParts.isNotEmpty && sParts.first == baseName && sParts.length > 1;
                }).toList();

                if (siblingSymbols.length <= 1) return const SizedBox.shrink();

                // Compute properties for each sibling
                final siblingsProps = <String, Map<String, String>>{};
                final allKeys = <String>{};
                for (final s in siblingSymbols) {
                  final sParts = s.name.split('/').map((x) => x.trim()).toList();
                  final map = <String, String>{};
                  for (var i = 1; i < sParts.length; i++) {
                    final prop = sParts[i];
                    if (prop.contains('=')) {
                      final kv = prop.split('=');
                      map[kv[0].trim()] = kv[1].trim();
                    } else {
                      map['Property $i'] = prop;
                    }
                  }
                  siblingsProps[s.id] = map;
                  allKeys.addAll(map.keys);
                }

                final currentProps = siblingsProps[resolvedSymbol.id] ?? {};

                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final key in allKeys) ...[
                        _buildLabel(key),
                        const SizedBox(height: 4),
                        // Dropdown for this specific variant property
                        Container(
                          height: 28,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: theme.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: theme.divider),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: currentProps[key],
                              isExpanded: true,
                              dropdownColor: theme.surface,
                              style: TextStyle(color: theme.textPrimary, fontSize: 12),
                              items: () {
                                // Find all unique values for this key
                                final values = siblingsProps.values
                                    .map((m) => m[key])
                                    .whereType<String>()
                                    .toSet()
                                    .toList()..sort();
                                return values.map((val) => DropdownMenuItem(
                                  value: val,
                                  child: Text(val, style: TextStyle(color: theme.textPrimary, fontSize: 12)),
                                )).toList();
                              }(),
                              onChanged: (newVal) {
                                if (newVal == null || newVal == currentProps[key]) return;
                                
                                // Construct target properties
                                final targetProps = Map<String, String>.from(currentProps);
                                targetProps[key] = newVal;
                                
                                // Find best matching sibling
                                String bestSiblingId = resolvedSymbol.id;
                                int bestMatchCount = -1;

                                for (final entry in siblingsProps.entries) {
                                  int matchCount = 0;
                                  bool hasConflict = false;
                                  for (final tk in targetProps.keys) {
                                    if (entry.value[tk] == targetProps[tk]) {
                                      matchCount++;
                                    } else if (tk == key) {
                                      hasConflict = true;
                                    }
                                  }
                                  if (!hasConflict && matchCount > bestMatchCount) {
                                    bestMatchCount = matchCount;
                                    bestSiblingId = entry.key;
                                  }
                                }

                                if (bestSiblingId != resolvedSymbol.id) {
                                  onUpdate((s) => s.maybeMap(
                                    symbolInstance: (si) => si.copyWith(symbolId: bestSiblingId),
                                    orElse: () => s,
                                  ));
                                }
                              },
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: 10),

          // Edit master button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(Icons.edit_outlined, size: 12, color: theme.accentColor),
              label: Text(
                'Edit Master Symbol',
                style: TextStyle(fontSize: 11, color: theme.accentColor),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.accentColor.withAlpha(100)),
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: resolvedSymbol == null
                  ? null
                  : () {
                      ref.read(editingSymbolIdProvider.notifier).set(shape.symbolId);
                    },
            ),
          ),

          const SizedBox(height: 12),

          // Alpha override
          _buildLabel('Alpha Override'),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: shape.alphaOverride.clamp(0.0, 1.0),
                  min: 0,
                  max: 1,
                  activeColor: theme.accentColor,
                  inactiveColor: theme.divider,
                  onChanged: (v) => onLiveUpdate(
                    (s) => s.maybeMap(
                      symbolInstance: (si) => si.copyWith(alphaOverride: v),
                      orElse: () => s,
                    ),
                  ),
                  onChangeEnd: (_) => onCommit(),
                ),
              ),
              SizedBox(
                width: 44,
                child: NumericInput(
                  label: '%',
                  value: (shape.alphaOverride * 100).roundToDouble(),
                  min: 0,
                  max: 100,
                  theme: theme,
                  onChanged: (v) => onUpdate(
                    (s) => s.maybeMap(
                      symbolInstance: (si) => si.copyWith(alphaOverride: v / 100),
                      orElse: () => s,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Loop type dropdown
          _buildLabel('Loop'),
          const SizedBox(height: 4),
          _LoopTypeDropdown(
            value: shape.loopType,
            theme: theme,
            onChanged: (v) => onUpdate(
              (s) => s.maybeMap(
                symbolInstance: (si) => si.copyWith(loopType: v),
                orElse: () => s,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // First frame
          _buildLabel('Start Frame'),
          const SizedBox(height: 4),
          NumericInput(
            label: 'F',
            value: shape.firstFrame.toDouble(),
            min: 0,
            step: 1,
            theme: theme,
            onChanged: (v) => onUpdate(
              (s) => s.maybeMap(
                symbolInstance: (si) => si.copyWith(firstFrame: v.toInt()),
                orElse: () => s,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Color Tint
          _buildLabel('Color Tint'),
          const SizedBox(height: 4),
          Row(
            children: [
              // Swatch — tapping opens picker; when tint is null shows a dashed/transparent swatch
              GestureDetector(
                onTap: () async {
                  final initial = shape.colorTint?.toFlutterColor() ?? Colors.white;
                  final picked = await showColorPicker(
                    context: context,
                    initialColor: initial,
                    theme: theme,
                  );
                  if (picked != null) {
                    onUpdate((s) => s.maybeMap(
                      symbolInstance: (si) => si.copyWith(
                        colorTint: VecColor.fromFlutterColor(picked),
                        tintAmount: si.tintAmount == 0 ? 1.0 : si.tintAmount,
                      ),
                      orElse: () => s,
                    ));
                  }
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: shape.colorTint?.toFlutterColor() ?? Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: theme.divider),
                  ),
                  child: shape.colorTint == null
                      ? Icon(Icons.block, size: 14, color: theme.textDisabled)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PanelSlider(
                  value: shape.tintAmount.clamp(0.0, 1.0),
                  theme: theme,
                  onChanged: (v) => onLiveUpdate(
                    (s) => s.maybeMap(
                      symbolInstance: (si) => si.copyWith(tintAmount: v),
                      orElse: () => s,
                    ),
                  ),
                  onChangeEnd: (_) => onCommit(),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 36,
                child: Text(
                  '${(shape.tintAmount * 100).round()}%',
                  style: TextStyle(fontSize: 10, color: theme.textDisabled),
                  textAlign: TextAlign.right,
                ),
              ),
              // Clear tint button
              if (shape.colorTint != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => onUpdate((s) => s.maybeMap(
                    symbolInstance: (si) => si.copyWith(colorTint: null, tintAmount: 0),
                    orElse: () => s,
                  )),
                  child: Icon(Icons.close, size: 12, color: theme.textDisabled),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 10, color: theme.textDisabled),
    );
  }
}

// ---------------------------------------------------------------------------
// Symbol reference dropdown
// ---------------------------------------------------------------------------

class _SymbolDropdown extends StatelessWidget {
  const _SymbolDropdown({
    required this.symbols,
    required this.selectedId,
    required this.theme,
    required this.onChanged,
  });

  final List<VecSymbol> symbols;
  final String selectedId;
  final AppTheme theme;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: symbols.any((s) => s.id == selectedId) ? selectedId : null,
          isExpanded: true,
          dropdownColor: theme.surface,
          style: TextStyle(color: theme.textPrimary, fontSize: 12),
          hint: Text('Unknown symbol', style: TextStyle(color: theme.error, fontSize: 12)),
          items: symbols.map((sym) => DropdownMenuItem(
            value: sym.id,
            child: Text(sym.name, style: TextStyle(color: theme.textPrimary, fontSize: 12)),
          )).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loop type dropdown
// ---------------------------------------------------------------------------

class _LoopTypeDropdown extends StatelessWidget {
  const _LoopTypeDropdown({
    required this.value,
    required this.theme,
    required this.onChanged,
  });

  final VecLoopType value;
  final AppTheme theme;
  final void Function(VecLoopType) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<VecLoopType>(
          value: value,
          isExpanded: true,
          dropdownColor: theme.surface,
          style: TextStyle(color: theme.textPrimary, fontSize: 12),
          items: const [
            DropdownMenuItem(value: VecLoopType.loop, child: Text('Loop')),
            DropdownMenuItem(value: VecLoopType.playOnce, child: Text('Play Once')),
            DropdownMenuItem(value: VecLoopType.pingPong, child: Text('Ping Pong')),
          ],
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}
