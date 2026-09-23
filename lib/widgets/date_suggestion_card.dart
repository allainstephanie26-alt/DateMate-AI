import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme.dart';
import 'primary_gradient_button.dart';

class DateSuggestionCard extends StatelessWidget {
  const DateSuggestionCard({
    super.key,
    required this.suggestion,
    required this.isFavorite,
    required this.onAddToBucket,
    required this.onFavorite,
  });

  final DateSuggestion suggestion;
  final bool isFavorite;
  final VoidCallback onAddToBucket;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _visualHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        suggestion.title,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onFavorite,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Favorite',
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: AppColors.gradientEnd,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  suggestion.subtitle,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _pill(Icons.location_on_outlined, suggestion.location),
                    _pill(Icons.payments_outlined, suggestion.price),
                    _pill(Icons.auto_awesome, suggestion.matchTag),
                  ],
                ),
                const SizedBox(height: 13),
                PrimaryGradientButton(
                  label: 'Add to Bucket List',
                  icon: Icons.add,
                  onPressed: onAddToBucket,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _visualHeader() {
    final icon = _iconForCategory(suggestion.category);
    return Container(
      height: 112,
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Stack(
        children: [
          Positioned(
            left: -20,
            top: -34,
            child: Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.09),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -25,
            bottom: -50,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                color: AppColors.rose.withOpacity(.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.16),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(.28)),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 10,
            child: _headerPill(Icons.place_outlined, suggestion.location),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: _headerPill(Icons.favorite, suggestion.price),
          ),
        ],
      ),
    );
  }

  Widget _headerPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.94),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.gradientEnd),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.gradientEnd),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String category) {
    final value = category.toLowerCase();
    if (value.contains('food') ||
        value.contains('cafe') ||
        value.contains('eat')) {
      return Icons.local_cafe;
    }
    if (value.contains('walk') ||
        value.contains('park') ||
        value.contains('outdoor')) {
      return Icons.park_outlined;
    }
    if (value.contains('movie')) return Icons.movie_outlined;
    if (value.contains('market')) return Icons.storefront_outlined;
    if (value.contains('game')) return Icons.sports_esports_outlined;
    if (value.contains('museum')) return Icons.museum_outlined;
    return Icons.favorite_outline;
  }
}
