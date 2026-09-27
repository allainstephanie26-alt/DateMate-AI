import 'package:flutter/material.dart';
import '../theme.dart';

class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: selected ? Colors.white : AppColors.gradientEnd,
            ),
            const SizedBox(width: 5),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.outline),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.primary,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }
}
