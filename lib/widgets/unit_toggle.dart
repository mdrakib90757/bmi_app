import 'package:flutter/material.dart';

import '../models/unit_system.dart';

/// Widget for toggling between metric and imperial units
class UnitToggle extends StatelessWidget {
  final UnitSystem currentUnit;
  final ValueChanged<UnitSystem> onChanged;

  const UnitToggle({
    super.key,
    required this.currentUnit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildToggleButton(
            context: context,
            label: 'Metric',
            value: UnitSystem.metric,
            isSelected: currentUnit == UnitSystem.metric,
          ),
          _buildToggleButton(
            context: context,
            label: 'Imperial',
            value: UnitSystem.imperial,
            isSelected: currentUnit == UnitSystem.imperial,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required String label,
    required UnitSystem value,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
