import 'package:flutter/material.dart';
import '../theme.dart';

/// A floating, frosted-glass nav bar — the active tab is filled with the
/// brand gradient (an "active state" highlight) instead of a flat tint, so
/// it reads as the one place on screen you're always oriented by.
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
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadows.floating,
        ),
        child: GlassLayer(
          borderRadius: 28,
          blur: 22,
          opacity: .82,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(7, 7, 7, 7),
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
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          gradient: active ? AppColors.buttonGradient : null,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: active
                              ? const [
                                  BoxShadow(
                                    color: Color(0x3DE6367F),
                                    blurRadius: 14,
                                    offset: Offset(0, 5),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              active ? item.$2 : item.$1,
                              color: active ? Colors.white : AppColors.muted,
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
                                color: active ? Colors.white : AppColors.muted,
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
        ),
      ),
    );
  }
}
