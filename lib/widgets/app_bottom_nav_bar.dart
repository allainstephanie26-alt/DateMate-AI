import 'package:flutter/material.dart';
import '../theme.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, 'Suggest'),
    (Icons.favorite_border_rounded, Icons.favorite_rounded, 'Bucket'),
    (Icons.people_outline_rounded, Icons.people_rounded, 'Us'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.fromLTRB(7, 7, 7, 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outline.withValues(alpha: .7)),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final active = i == currentIndex;
            return Expanded(
              child: Semantics(
                button: true,
                selected: active,
                label: item.$3,
                child: InkWell(
                  onTap: () => onTap(i),
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? AppColors.blush : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          active ? item.$2 : item.$1,
                          color: active ? AppColors.primary : AppColors.muted,
                          size: 21,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.$3,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: active
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: active ? AppColors.primary : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
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
