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
  Widget build(BuildContext context) => CircleAvatar(
    radius: 18,
    backgroundColor: backgroundColor,
    child: Text(
      initial,
      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
    ),
  );
}
