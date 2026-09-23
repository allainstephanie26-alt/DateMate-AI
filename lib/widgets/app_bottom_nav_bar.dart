import 'package:flutter/material.dart';
import '../theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const items = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.auto_awesome_outlined, Icons.auto_awesome, 'Suggest'),
    (Icons.checklist_outlined, Icons.checklist, 'Bucket'),
    (Icons.person_outline, Icons.person, 'Us'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final item = items[i];
            final active = i == currentIndex;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? item.$2 : item.$1,
                        color: active
                            ? AppColors.gradientEnd
                            : AppColors.onSurfaceVariant,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.$3,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: active
                              ? AppColors.gradientEnd
                              : AppColors.onSurfaceVariant,
                          fontWeight: active
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
