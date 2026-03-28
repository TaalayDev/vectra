import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../data/models/vec_shape.dart';
import '../../../data/models/vec_symbol.dart';
import '../../../data/models/vec_timeline.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/editor_state_provider.dart';
import '../common/collapsible_section.dart';
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
