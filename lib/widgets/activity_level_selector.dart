import 'package:flutter/material.dart';

/// Widget for selecting activity level
class ActivityLevelSelector extends StatefulWidget {
  final String? selectedLevel;
  final ValueChanged<String> onChanged;
  final List<String> activityLevels;
  final Map<String, String>? descriptions;

  const ActivityLevelSelector({
    super.key,
    required this.selectedLevel,
    required this.onChanged,
    required this.activityLevels,
    this.descriptions,
  });

  @override
  State<ActivityLevelSelector> createState() => _ActivityLevelSelectorState();
}

class _ActivityLevelSelectorState extends State<ActivityLevelSelector> {
  late String _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.selectedLevel ?? widget.activityLevels.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Level',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.activityLevels.length,
          itemBuilder: (context, index) {
            final level = widget.activityLevels[index];
            final isSelected = _selectedLevel == level;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedLevel = level);
                  widget.onChanged(level);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                            ),
                            if (widget.descriptions != null &&
                                widget.descriptions!.containsKey(level))
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  widget.descriptions![level]!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
