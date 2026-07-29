import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A capsule-style segmented tab selector.
///
/// Renders a pill-shaped container with two or more segments. The active
/// segment slides smoothly thanks to an [AnimatedAlign] thumb.
class CapsuleTab<T> extends StatelessWidget {
  final List<CapsuleTabItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  const CapsuleTab({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = items.indexWhere((e) => e.value == selectedValue);
    final activeIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Stack(
        children: [
          // Sliding thumb
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: FractionalOffset(
              activeIndex / (items.length - 1).clamp(1, double.infinity),
              0.5,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / items.length,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  height: 30,
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
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.2,
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
