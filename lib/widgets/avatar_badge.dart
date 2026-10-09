import 'package:flutter/material.dart';

class AvatarBadge extends StatelessWidget {
  final String initial;
  final Color backgroundColor;
  final Color textColor;
  const AvatarBadge({
    super.key,
    required this.initial,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: backgroundColor,
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white.withValues(alpha: .28),
        width: 1.6,
      ),
      boxShadow: [
        BoxShadow(
          color: backgroundColor.withValues(alpha: .35),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    alignment: Alignment.center,
    child: Text(
      initial,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w800,
        fontSize: 14.5,
      ),
    ),
  );
}
