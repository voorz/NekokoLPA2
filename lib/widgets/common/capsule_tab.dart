import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A capsule-style segmented tab selector with fixed-width segments.
///
/// Renders a pill-shaped container with two or more segments. The active
/// segment slides smoothly thanks to an [AnimatedPositioned] thumb.
class CapsuleTab<T> extends StatelessWidget {
  final List<CapsuleTabItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  /// Width of each individual segment (label + thumb).
  final double segmentWidth;

  const CapsuleTab({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.segmentWidth = 72,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = items.indexWhere((e) => e.value == selectedValue);
    final activeIndex = selectedIndex < 0 ? 0 : selectedIndex;

    const padding = 3.0;
    final totalWidth = segmentWidth * items.length + padding * 2;

    return Container(
      width: totalWidth,
      height: 30 + padding * 2,
      padding: const EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Sliding thumb — fixed width, animated left position
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            left: activeIndex * segmentWidth,
            top: 0,
            bottom: 0,
            width: segmentWidth,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Tab labels
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == activeIndex;
              return GestureDetector(
                onTap: () {
                  if (!isActive) {
                    HapticFeedback.selectionClick();
                    onChanged(item.value);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: segmentWidth,
                  height: 30,
                  child: Center(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class CapsuleTabItem<T> {
  final T value;
  final String label;

  const CapsuleTabItem({required this.value, required this.label});
}
