import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme.dart';
import 'app_card.dart';
import 'place_image.dart';
import 'primary_gradient_button.dart';

class DateSuggestionCard extends StatefulWidget {
  const DateSuggestionCard({
    super.key,
    required this.suggestion,
    required this.isFavorite,
    required this.isSaved,
    required this.onAddToBucket,
    required this.onFavorite,
    this.onDetails,
  });

  final DateSuggestion suggestion;
  final bool isFavorite;
  final bool isSaved;
  final VoidCallback? onAddToBucket;
  final VoidCallback onFavorite;
  final VoidCallback? onDetails;

  @override
  State<DateSuggestionCard> createState() => _DateSuggestionCardState();
}

class _DateSuggestionCardState extends State<DateSuggestionCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onDetails == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = widget.suggestion;
    return AnimatedScale(
      scale: _pressed ? .985 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: AppCard(
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.only(bottom: 18),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.card),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onDetails,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    PlaceImage(
                      placeName: suggestion.title,
                      category: suggestion.category,
                      seedKey: suggestion.placeId,
                      assetPath: suggestion.imageUrl,
                      height: 208,
                      borderRadius: 0,
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: .05),
                              AppColors.primaryDark.withValues(alpha: .78),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 14,
                      right: 54,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          AppBadge(
                            label: suggestion.category,
                            icon: Icons.place_outlined,
                            strong: true,
                          ),
                          AppBadge(
                            label: suggestion.verified
                                ? 'Verified'
                                : 'DateMate idea',
                            icon: suggestion.verified
                                ? Icons.verified_rounded
                                : Icons.auto_awesome_rounded,
                            gradient: suggestion.verified,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Material(
                        color: Colors.white.withValues(alpha: .94),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: widget.onFavorite,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              widget.isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 20,
                              color: AppColors.magenta,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 15,
                      child: Text(
                        suggestion.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          height: 1.08,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(17, 15, 17, 17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          AppBadge(
                            label: suggestion.location,
                            icon: Icons.location_on_outlined,
                          ),
                          AppBadge(
                            label: suggestion.price,
                            icon: Icons.payments_outlined,
                          ),
                          if (suggestion.openingHours.isNotEmpty)
                            AppBadge(
                              label: _statusLabel(suggestion.openingHours),
                              icon: Icons.schedule_outlined,
                            ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(right: 7),
                            decoration: const BoxDecoration(
                              color: AppColors.violet,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              suggestion.matchTag,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.violetDeep,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: widget.onDetails,
                              child: const Text('View details'),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: PrimaryGradientButton(
                              label: widget.isSaved ? 'Saved' : 'Save date',
                              icon: widget.isSaved
                                  ? Icons.check_rounded
                                  : Icons.favorite_rounded,
                              onPressed: widget.onAddToBucket,
                              height: 47,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(String hours) {
    final lower = hours.toLowerCase();
    if (lower.startsWith('open now')) return 'Open now';
    if (lower.startsWith('closed')) return 'Closed';
    if (lower.contains('not verified')) return 'Hours unverified';
    return 'Hours listed';
  }
}
