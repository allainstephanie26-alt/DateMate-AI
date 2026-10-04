import 'dart:ui';

import 'package:flutter/material.dart';

import '../data/catalog_data.dart';
import '../theme.dart';

/// A place "photo" card: a real local photo when one exists, and a
/// designed illustrated hero — not a flat icon badge — when it doesn't.
///
/// This app makes no network image calls and uses no place-photo API (see
/// `assets/places/README.md` for why). For the small set of verified real
/// places, a real photo can be dropped in at `assets/places/<id>.jpg` and
/// this widget picks it up automatically via [assetPath] — no other code
/// changes needed. `Image.asset`'s own `errorBuilder` guarantees that a
/// missing or corrupt file can never render as Flutter's broken-image
/// icon: it falls straight through to the illustrated hero instead, so
/// every card always renders something intentional.
///
/// The illustrated hero itself is built from layered, blurred gradient
/// "aurora" shapes plus a glass icon medallion — designed to read as a
/// branded editorial image, not a generic category icon.
class PlaceImage extends StatelessWidget {
  const PlaceImage({
    super.key,
    required this.placeName,
    this.category = '',
    this.seedKey = '',
    this.assetPath = '',
    this.height = 180,
    this.borderRadius = 18,
  });

  final String placeName;
  final String category;
  final String seedKey;

  /// Local asset path to a real photo, e.g. `assets/places/hardin-angeles.jpg`.
  /// Empty for every generated "DateMate idea" place, and for a verified
  /// place whose photo hasn't been added yet.
  final String assetPath;

  final double height;
  final double borderRadius;

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

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: assetPath.isEmpty
            ? _IllustratedHero(
                icon: _icon,
                name: placeName,
                colors: _gradient(),
              )
            : Image.asset(
                assetPath,
                fit: BoxFit.cover,
                // A missing/corrupt file can never show as a broken-image
                // icon — it falls through to the same illustrated hero
                // every generated place already uses.
                errorBuilder: (_, __, ___) => _IllustratedHero(
                  icon: _icon,
                  name: placeName,
                  colors: _gradient(),
                ),
              ),
      ),
    );
  }
}

/// The designed fallback hero: layered blurred "aurora" blobs over a
/// 3-stop brand gradient, a soft diagonal sheen, and a glass medallion
/// holding the category icon + the place's initial — composed to read as
/// an intentional piece of art, not a placeholder.
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
          // Blurred aurora blobs — the "blurred elements" layer.
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
          Positioned(
            right: 10,
            top: -20,
            child: _blob(90, Colors.white.withValues(alpha: .22)),
          ),
          // Diagonal gloss sheen for a premium, polished finish.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: .14),
                    Colors.transparent,
                    Colors.black.withValues(alpha: .10),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          // Large watermark icon, low-opacity, for depth and category cue.
          Positioned(
            right: -6,
            bottom: -14,
            child: Icon(
              icon,
              size: 104,
              color: Colors.white.withValues(alpha: .14),
            ),
          ),
          // Glass medallion with the category icon + initial — the focal
          // point, deliberately composed rather than a bare icon-on-color.
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
                        color: Colors.white.withValues(alpha: .22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .55),
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
