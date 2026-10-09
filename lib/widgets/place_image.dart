import 'dart:ui';

import 'package:flutter/material.dart';

import '../data/catalog_data.dart';
import '../theme.dart';
import 'stock_photo.dart';

class PlaceImage extends StatelessWidget {
  const PlaceImage({
    super.key,
    required this.placeName,
    this.category = '',
    this.seedKey = '',
    this.assetPath = '',
    this.height = 180,
    this.borderRadius = 18,
    this.aiIdea = false,
  });

  final String placeName;
  final String category;
  final String seedKey;

  /// Local asset path to a verified place's real photo.
  final String assetPath;

  final double height;
  final double borderRadius;

  /// True for DateMate Idea / AI recommendations that have no bundled photo.
  final bool aiIdea;

  IconData get _icon {
    final haystack = '$placeName $category'.toLowerCase();
    for (final c in CatalogData.allCategories) {
      if (haystack.contains(c.label.toLowerCase())) return c.icon;
      for (final k in c.keywords) {
        if (haystack.contains(k)) return c.icon;
      }
    }
    return Icons.favorite_rounded;
  }

  List<Color> _gradient() {
    final key = seedKey.isNotEmpty ? seedKey : placeName;
    final index = key.isEmpty
        ? 0
        : key.codeUnits.fold<int>(0, (a, b) => a + b) %
              AppColors.placeGradients.length;
    return AppColors.placeGradients[index];
  }

  Widget _hero() =>
      _IllustratedHero(icon: _icon, name: placeName, colors: _gradient());

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    final Widget content;
    if (assetPath.isNotEmpty) {
      content = Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => aiIdea
            ? StockPhoto(
                placeName: placeName,
                category: category,
                seedKey: seedKey,
              )
            : _hero(),
      );
    } else if (aiIdea) {
      content = StockPhoto(
        placeName: placeName,
        category: category,
        seedKey: seedKey,
      );
    } else {
      content = _hero();
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(height: height, width: double.infinity, child: content),
    );
  }
}

class _IllustratedHero extends StatelessWidget {
  const _IllustratedHero({
    required this.icon,
    required this.name,
    required this.colors,
  });

  final IconData icon;
  final String name;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? 'D' : trimmed[0].toUpperCase();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -40,
            top: -50,
            child: _blob(160, colors.last.withValues(alpha: .55)),
          ),
          Positioned(
            right: -30,
            bottom: -40,
            child: _blob(190, colors.first.withValues(alpha: .5)),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: .10),
                    Colors.transparent,
                    Colors.black.withValues(alpha: .22),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            right: -6,
            bottom: -14,
            child: Icon(
              icon,
              size: 104,
              color: Colors.white.withValues(alpha: .12),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .45),
                          width: 1.4,
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 27),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
