import 'package:flutter/material.dart';
import '../theme.dart';

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (onBack != null) ...[
              AppIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                tooltip: 'Back',
                onTap: onBack!,
              ),
              const SizedBox(width: 13),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (trailing != null) ...[
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerRight, child: trailing!),
        ],
      ],
    );
  }
}

class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.size = 44,
    this.iconSize = 17,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final double size;
  final double iconSize;

  /// When true the button uses the brand gradient (for "next / continue").
  final bool filled;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final radius = BorderRadius.circular(widget.size * .36);
    final button = AnimatedScale(
      scale: _pressed ? .92 : 1,
      duration: const Duration(milliseconds: 100),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1 : .4,
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.filled ? AppColors.buttonGradient : null,
            color: widget.filled ? null : Colors.white.withValues(alpha: .07),
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withValues(alpha: widget.filled ? .25 : .13),
            ),
            boxShadow: _pressed || widget.filled
                ? const [
                    BoxShadow(
                      color: Color(0x40E6367F),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              borderRadius: radius,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: widget.filled ? Colors.white : AppColors.pinkText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.tooltip,
      child: widget.tooltip == null
          ? button
          : Tooltip(message: widget.tooltip!, child: button),
    );
  }
}
