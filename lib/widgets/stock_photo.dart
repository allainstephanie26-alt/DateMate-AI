import 'package:flutter/material.dart';

/// Category groups used to pick a free stock photo for a DateMate idea.
enum StockGroup {
  restaurant,
  cafe,
  outdoor,
  cinema,
  museum,
  beach,
  entertainment,
}

/// Free-to-use, photo-style imagery for DateMate Idea / AI recommendations.
///
/// Rules this file follows:
///  * Real photographs only — never an icon, emoji, pin, gradient or colored
///    box as the main image.
///  * Free to use with no payment, premium tier, API key or paid API:
///    Unsplash photos are served from their public CDN under the Unsplash
///    License, and loremflickr.com is a key-less keyword endpoint backed by
///    Creative-Commons Flickr photos.
///  * Used ONLY for generated "DateMate idea" places. Verified/curated places
///    keep their own bundled `assets/places/<id>.jpg` mapping untouched
///    (see PlaceImage).
///
/// Every group has several photos plus a keyword fallback, and the widget
/// walks that list on any load error, so one dead URL never leaves a card
/// without a photo.
class StockPhotoCatalog {
  StockPhotoCatalog._();

  static String _u(String id) =>
      'https://images.unsplash.com/photo-$id?auto=format&fit=crop&w=900&q=70';

  static final Map<StockGroup, List<String>> _photos = {
    StockGroup.restaurant: [
      _u('1517248135467-4c7edcad34c4'),
      _u('1414235077428-338989a2e8c0'),
      _u('1555396273-367ea4eb4db5'),
      _u('1504674900247-0877df9cc836'),
    ],
    StockGroup.cafe: [
      _u('1495474472287-4d71bcdd2085'),
      _u('1509042239860-f550ce710b93'),
      _u('1554118811-1e0d58224f24'),
      _u('1445116572660-236099ec97a0'),
    ],
    StockGroup.outdoor: [
      _u('1441974231531-c6227db76b6e'),
      _u('1501785888041-af3ef285b470'),
      _u('1506744038136-46273834b3fb'),
      _u('1470071459604-3b5ec3a7fe05'),
    ],
    StockGroup.cinema: [
      _u('1489599849927-2ee91cede3ba'),
      _u('1536440136628-849c177e76a1'),
      _u('1517604931442-7e0c8ed2963c'),
      _u('1478720568477-152d9b164e26'),
    ],
    StockGroup.museum: [
      _u('1518998053901-5348d3961a04'),
      _u('1565060169194-19fabf63012c'),
      _u('1554907984-15263bfd63bd'),
    ],
    StockGroup.beach: [
      _u('1507525428034-b723cf961d3e'),
      _u('1519046904884-53103b34b206'),
      _u('1473116763249-2faaef81ccda'),
    ],
    StockGroup.entertainment: [
      _u('1470229722913-7c0e2dbbafd3'),
      _u('1511671782779-c97d3d27a1d4'),
      _u('1493676304819-0d7a8d026dcf'),
    ],
  };

  static const Map<StockGroup, String> _flickrKeyword = {
    StockGroup.restaurant: 'restaurant,food',
    StockGroup.cafe: 'cafe,coffee',
    StockGroup.outdoor: 'nature,park',
    StockGroup.cinema: 'cinema,movie',
    StockGroup.museum: 'museum,gallery',
    StockGroup.beach: 'beach,sea',
    StockGroup.entertainment: 'concert,nightlife',
  };

  /// Bundled, already-shipped real photos that are an honest last resort when
  /// the device is offline. Only groups with a genuinely matching asset are
  /// listed; they are referenced, never remapped or modified.
  static const Map<StockGroup, String> _offlineAsset = {
    StockGroup.restaurant: 'assets/places/makimura-ramen-angeles.jpg',
    StockGroup.cafe: 'assets/places/makimura-ramen-angeles.jpg',
    StockGroup.outdoor: 'assets/places/burnham-park-baguio.jpg',
    StockGroup.museum: 'assets/places/ayala-museum-makati.jpg',
    StockGroup.beach: 'assets/places/alona-beach-bohol.jpg',
  };

  static bool _hasAny(String haystack, List<String> words) =>
      words.any(haystack.contains);

  /// Maps a place name + category to a photo group.
  static StockGroup groupFor(String placeName, String category) {
    final h = '$category $placeName'.toLowerCase();
    if (_hasAny(h, ['cinema', 'movie', 'film', 'theater', 'theatre', 'imax'])) {
      return StockGroup.cinema;
    }
    if (_hasAny(h, ['museum', 'gallery', 'art ', 'exhibit', 'culture'])) {
      return StockGroup.museum;
    }
    if (_hasAny(h, [
      'cafe',
      'café',
      'coffee',
      'milk tea',
      'tea ',
      'dessert',
      'ice cream',
      'bakery',
      'brunch',
    ])) {
      return StockGroup.cafe;
    }
    if (_hasAny(h, ['beach', 'island', 'surf', 'snorkel', 'sea ', 'resort'])) {
      return StockGroup.beach;
    }
    if (_hasAny(h, [
      'arcade',
      'live music',
      'concert',
      'night market',
      'bowling',
      'karaoke',
      'shopping',
    ])) {
      return StockGroup.entertainment;
    }
    if (_hasAny(h, [
      'park',
      'picnic',
      'walk',
      'nature',
      'hike',
      'garden',
      'falls',
      'mountain',
      'farm',
      'lake',
      'view',
      'trail',
      'adventur',
      'photograph',
      'outdoor',
    ])) {
      return StockGroup.outdoor;
    }
    return StockGroup.restaurant;
  }

  /// Ordered candidate URLs for a place. The starting photo is picked
  /// deterministically from [seedKey] so different ideas in the same
  /// category do not all show the identical picture.
  static List<String> urlsFor(StockGroup group, String seedKey) {
    final list = _photos[group]!;
    final seed = seedKey.codeUnits.fold<int>(0, (a, b) => a + b);
    final start = list.isEmpty ? 0 : seed % list.length;
    final ordered = [
      for (var i = 0; i < list.length; i++) list[(start + i) % list.length],
    ];
    ordered.add(
      'https://loremflickr.com/900/600/${_flickrKeyword[group]}?lock=${seed % 97 + 1}',
    );
    return ordered;
  }

  static String? offlineAssetFor(StockGroup group) => _offlineAsset[group];
}

/// A real stock photograph for a DateMate idea.
///
/// While loading it shows a quiet dark shimmer (a loading state, not the
/// image). On a load error it advances to the next free photo; if every
/// network source fails it falls back to a bundled real photo of a matching
/// category when one exists.
class StockPhoto extends StatefulWidget {
  const StockPhoto({
    super.key,
    required this.placeName,
    required this.category,
    this.seedKey = '',
  });

  final String placeName;
  final String category;
  final String seedKey;

  @override
  State<StockPhoto> createState() => _StockPhotoState();
}

class _StockPhotoState extends State<StockPhoto> {
  late StockGroup _group;
  late List<String> _urls;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant StockPhoto old) {
    super.didUpdateWidget(old);
    if (old.placeName != widget.placeName ||
        old.category != widget.category ||
        old.seedKey != widget.seedKey) {
      _resolve();
    }
  }

  void _resolve() {
    _group = StockPhotoCatalog.groupFor(widget.placeName, widget.category);
    final seed = widget.seedKey.isNotEmpty ? widget.seedKey : widget.placeName;
    _urls = StockPhotoCatalog.urlsFor(_group, seed);
    _index = 0;
  }

  /// Advance to the next source — guarded so a repeated error callback for
  /// the same failed URL can never skip a candidate.
  void _next(int failedIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _index == failedIndex) setState(() => _index++);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_index < _urls.length) {
      final current = _index;
      return Image.network(
        _urls[_index],
        key: ValueKey(_urls[_index]),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const _PhotoShimmer();
        },
        errorBuilder: (context, error, stack) {
          _next(current);
          return const _PhotoShimmer();
        },
      );
    }

    final asset = StockPhotoCatalog.offlineAssetFor(_group);
    if (asset != null) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const _PhotoShimmer(),
      );
    }
    return const _PhotoShimmer();
  }
}

class _PhotoShimmer extends StatefulWidget {
  const _PhotoShimmer();

  @override
  State<_PhotoShimmer> createState() => _PhotoShimmerState();
}

class _PhotoShimmerState extends State<_PhotoShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.5 + _c.value * 3, -0.3),
            end: Alignment(-0.5 + _c.value * 3, 0.3),
            colors: const [
              Color(0xFF1E1329),
              Color(0xFF33203F),
              Color(0xFF1E1329),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
