import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme.dart';
import 'app_card.dart';
import 'place_image.dart';
import 'primary_gradient_button.dart';

class DateSuggestionCard extends StatelessWidget {
  const DateSuggestionCard({
    super.key,
    required this.suggestion,
    required this.isFavorite,
    required this.onAddToBucket,
    required this.onFavorite,
    this.onDetails,
  });

  final DateSuggestion suggestion;
  final bool isFavorite;
  final VoidCallback onAddToBucket;
  final VoidCallback onFavorite;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              PlaceImage(
                placeName: suggestion.title,
                source: suggestion.imageUrl,
                height: 188,
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
                        AppColors.primary.withValues(alpha: .70),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                top: 14,
                child: AppBadge(
                  label: suggestion.category,
                  icon: Icons.place_outlined,
                  strong: true,
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Material(
                  color: Colors.white.withValues(alpha: .92),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onFavorite,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20,
                        color: AppColors.gradientEnd,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Text(
                  suggestion.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Georgia',
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 11),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
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
                const SizedBox(height: 12),
                Text(
                  suggestion.matchTag,
                  style: const TextStyle(
                    color: AppColors.gradientEnd,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDetails,
                        child: const Text('View details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PrimaryGradientButton(
                        label: 'Save date',
                        icon: Icons.favorite_rounded,
                        onPressed: onAddToBucket,
                        height: 46,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
