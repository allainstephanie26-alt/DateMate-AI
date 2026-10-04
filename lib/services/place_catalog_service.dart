import 'dart:math';

import '../data/catalog_data.dart';
import '../data/curated_seed.dart';
import '../models/app_models.dart';
import '../models/curated_place.dart';

/// A single request describing what the couple wants to see.
class CatalogQuery {
  final Set<String> locations;
  final Set<String> foods;
  final Set<String> activities;
  final double budget;
  final String currency;
  final String mood;

  const CatalogQuery({
    this.locations = const {},
    this.foods = const {},
    this.activities = const {},
    this.budget = 0,
    this.currency = 'PHP',
    this.mood = '',
  });

  CatalogQuery copyWith({
    Set<String>? locations,
    Set<String>? foods,
    Set<String>? activities,
    double? budget,
    String? currency,
    String? mood,
  }) => CatalogQuery(
    locations: locations ?? this.locations,
    foods: foods ?? this.foods,
    activities: activities ?? this.activities,
    budget: budget ?? this.budget,
    currency: currency ?? this.currency,
    mood: mood ?? this.mood,
  );
}

/// Generates and ranks date-place suggestions entirely on-device.
///
/// There is no network call anywhere in this class. That is what makes
/// suggestion generation and preference saving fast: the previous version of
/// the app awaited an OpenStreetMap geocoder + Overpass query on the
/// critical path of "Save preferences" and "Generate ideas", which is what
/// made both feel slow and occasionally show nothing. This version answers
/// from an in-memory, deterministically-generated catalog, so results are
/// instant and can be paged forever for a "scroll for more places" browsing
/// experience without ever integrating a paid places API.
class PlaceCatalogService {
  PlaceCatalogService();

  /// Places handed back to the UI during this session, keyed by id, so a
  /// chat follow-up ("why did you pick that one?") or a bucket-list save can
  /// look a generated place back up without regenerating it.
  final Map<String, CuratedPlace> _sessionCache = {};

  static const int pageSize = 16;

  // ---------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------

  /// Returns one page (default 16) of ranked suggestions for [query]. Page
  /// 0 leads with any matching verified seed places; every page after that,
  /// and the remainder of page 0, is generated on the fly. Call again with
  /// `page + 1` to load more — there is no upper bound, which is how the
  /// "browse many places" scroll works without an API.
  List<DateSuggestion> page(
    CatalogQuery query, {
    required int page,
    int size = pageSize,
    Set<String> excludedIds = const {},
  }) {
    final places = <CuratedPlace>[];

    if (page == 0) {
      places.addAll(
        _matchingSeed(query).where((p) => !excludedIds.contains(p.id)),
      );
    }

    final cities = _targetCities(query);
    final categories = _targetCategories(query);
    if (cities.isNotEmpty && categories.isNotEmpty) {
      final pairs = <(String, PlaceCategory)>[
        for (final c in cities)
          for (final cat in categories) (c, cat),
      ];
      final needed = size - places.length;
      if (needed > 0 && pairs.isNotEmpty) {
        final generated = _generateSlice(
          pairs: pairs,
          query: query,
          startIndex: page * size,
          count: needed + excludedIds.length, // over-fetch to survive excludes
        ).where((p) => !excludedIds.contains(p.id)).take(needed);
        places.addAll(generated);
      }
    }

    for (final p in places) {
      _sessionCache[p.id] = p;
    }

    return _rank(places, query).map((p) => _toSuggestion(p, query)).toList();
  }

  /// A short, high-confidence list (used by the home dashboard's "Tonight's
  /// idea" and mood tiles) — just the first page, trimmed.
  List<DateSuggestion> quickPicks(CatalogQuery query, {int count = 8}) {
    return page(query, page: 0, size: count);
  }

  CuratedPlace? placeById(String id) => _sessionCache[id];

  DateSuggestion? suggestionById(String id, CatalogQuery query) {
    final place = _sessionCache[id];
    if (place == null) return null;
    return _toSuggestion(place, query);
  }

  // ---------------------------------------------------------------------
  // Seed matching
  // ---------------------------------------------------------------------

  List<CuratedPlace> _matchingSeed(CatalogQuery query) {
    return CuratedSeed.places.where((place) {
      if (query.locations.isNotEmpty &&
          !query.locations.any(place.matchesLocation)) {
        return false;
      }
      if (query.foods.isNotEmpty &&
          !place.matchesAny(query.foods, {
            ...place.categories,
            ...place.tags,
            ...place.foodTypes,
          })) {
        return false;
      }
      if (query.activities.isNotEmpty &&
          !place.matchesAny(query.activities, {
            ...place.categories,
            ...place.tags,
          })) {
        return false;
      }
      if (query.budget > 0 &&
          place.estimatedCostMax > 0 &&
          place.estimatedCostMax > query.budget) {
        return false;
      }
      return true;
    }).toList();
  }

  // ---------------------------------------------------------------------
  // Target resolution
  // ---------------------------------------------------------------------

  List<String> _targetCities(CatalogQuery query) {
    if (query.locations.isEmpty) return CatalogData.cityNames;
    final matched = <String>{};
    for (final wanted in query.locations) {
      final w = wanted.toLowerCase().trim();
      for (final city in CatalogData.cityNames) {
        if (w.contains(city.toLowerCase()) || city.toLowerCase().contains(w)) {
          matched.add(city);
        }
      }
    }
    // An unrecognized location still deserves results: fall back to the
    // full city list rather than returning nothing.
    return matched.isEmpty ? CatalogData.cityNames : matched.toList();
  }

  List<PlaceCategory> _targetCategories(CatalogQuery query) {
    final matched = <PlaceCategory>{};
    for (final f in query.foods) {
      final c = CatalogData.matchCategory(f, food: true);
      if (c != null) matched.add(c);
    }
    for (final a in query.activities) {
      final c = CatalogData.matchCategory(a, food: false);
      if (c != null) matched.add(c);
    }
    if (matched.isNotEmpty) return matched.toList();

    final mood = query.mood.toLowerCase().trim();
    if (mood == 'foodie') return CatalogData.foodCategories;
    if (mood == 'adventurous') {
      return CatalogData.allCategories
          .where(
            (c) => const {
              'adventurous',
              'beach',
              'photography',
              'live_music',
              'night_market',
              'korean_bbq',
            }.contains(c.key),
          )
          .toList();
    }
    if (mood == 'cheap date') {
      return CatalogData.allCategories
          .where((c) => c.budgetLevel <= 1)
          .toList();
    }
    if (mood == 'chill') {
      return CatalogData.allCategories
          .where(
            (c) => const {
              'cafe',
              'picnic',
              'walk',
              'museum',
              'culture',
              'cafe_hopping',
              'art',
              'milk_tea',
              'dessert',
            }.contains(c.key),
          )
          .toList();
    }
    return CatalogData.allCategories;
  }

  // ---------------------------------------------------------------------
  // Generation
  // ---------------------------------------------------------------------

  Iterable<CuratedPlace> _generateSlice({
    required List<(String, PlaceCategory)> pairs,
    required CatalogQuery query,
    required int startIndex,
    required int count,
  }) sync* {
    for (var i = 0; i < count; i++) {
      final globalIndex = startIndex + i;
      final pairIndex = globalIndex % pairs.length;
      final variant = globalIndex ~/ pairs.length;
      final (city, category) = pairs[pairIndex];
      yield _generateOne(city, category, variant, query);
    }
  }

  CuratedPlace _generateOne(
    String city,
    PlaceCategory category,
    int variant,
    CatalogQuery query,
  ) {
    final seed = Object.hash(city, category.key, variant);
    final rng = Random(seed);
    final info = CatalogData.cityInfo(city);

    final adjective =
        CatalogData.adjectives[rng.nextInt(CatalogData.adjectives.length)];
    final noun = category.nameNouns[rng.nextInt(category.nameNouns.length)];
    final name = '$adjective $noun';

    final district = info.districts[rng.nextInt(info.districts.length)];
    final unit = 100 + rng.nextInt(800);
    final suffix = CatalogData
        .streetSuffixes[rng.nextInt(CatalogData.streetSuffixes.length)];
    final streetNumber = 1 + rng.nextInt(30);
    final address =
        'Unit $unit, $district $suffix $streetNumber, $city'
        '${info.province.isEmpty ? '' : ', ${info.province}'}, Philippines';

    var costMin = _baseCost(
      category.budgetLevel,
      info.priceMultiplier,
      rng,
      low: true,
    );
    var costMax = _baseCost(
      category.budgetLevel,
      info.priceMultiplier,
      rng,
      low: false,
    );
    if (query.budget > 0) {
      costMax = costMax < query.budget ? costMax : query.budget.roundToDouble();
      if (costMin >= costMax) costMin = (costMax * 0.6).roundToDouble();
    }

    final openHour = 8 + rng.nextInt(6);
    final closeHour = category.isFood
        ? 21 + rng.nextInt(3)
        : 17 + rng.nextInt(4);
    final hours = category.isFood
        ? 'Daily, ${_formatHour(openHour)}–${_formatHour(closeHour > 23 ? closeHour - 12 : closeHour)}'
        : 'Daily, ${_formatHour(openHour)}–${_formatHour(closeHour)}';

    final mapsQuery = Uri.encodeComponent('$name, $district, $city');

    return CuratedPlace(
      id: 'idea-${category.key}-${city.toLowerCase().replaceAll(' ', '')}-$variant',
      name: name,
      country: 'Philippines',
      city: city,
      address: address,
      categories: {category.label, if (category.isFood) 'Food' else 'Activity'},
      tags: {category.label},
      foodTypes: category.isFood ? {category.label} : const {},
      currency: 'PHP',
      estimatedCostMin: costMin,
      estimatedCostMax: costMax,
      budgetLevel: category.budgetLevel,
      imageAsset: '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=$mapsQuery',
      officialWebsiteUrl: '',
      menuUrl: '',
      hours: hours,
      description:
          'A ${adjective.toLowerCase()} ${category.label.toLowerCase()} spot in $district, $city — '
          'a DateMate idea generated from your saved preferences, not a verified listing.',
      verifiedSourceUrl: '',
      verified: false,
    );
  }

  double _baseCost(
    int budgetLevel,
    double multiplier,
    Random rng, {
    required bool low,
  }) {
    final tiers = <int, (double, double)>{
      1: (150, 700),
      2: (500, 1800),
      3: (1500, 4000),
      4: (4000, 12000),
    };
    final (lo, hi) = tiers[budgetLevel.clamp(1, 4)]!;
    final base = low ? lo : hi;
    final jitter = base * (0.85 + rng.nextDouble() * 0.3);
    return (jitter * multiplier / 10).round() * 10.0;
  }

  String _formatHour(int hour24) {
    final h = hour24 % 24;
    final period = h >= 12 ? 'PM' : 'AM';
    var h12 = h % 12;
    if (h12 == 0) h12 = 12;
    return '$h12:00 $period';
  }

  // ---------------------------------------------------------------------
  // Ranking + conversion
  // ---------------------------------------------------------------------

  List<CuratedPlace> _rank(List<CuratedPlace> places, CatalogQuery query) {
    final scored = places.map((p) {
      var score = 0;
      if (p.verified) score += 50;
      if (query.locations.isNotEmpty && query.locations.any(p.matchesLocation))
        score += 20;
      if (query.foods.isNotEmpty &&
          p.matchesAny(query.foods, {
            ...p.categories,
            ...p.tags,
            ...p.foodTypes,
          })) {
        score += 20;
      }
      if (query.activities.isNotEmpty &&
          p.matchesAny(query.activities, {...p.categories, ...p.tags})) {
        score += 20;
      }
      if (query.budget > 0 &&
          p.estimatedCostMax > 0 &&
          p.estimatedCostMax <= query.budget) {
        score += 10;
      }
      return MapEntry(p, score);
    }).toList();
    scored.sort((a, b) {
      final byScore = b.value.compareTo(a.value);
      return byScore != 0 ? byScore : a.key.name.compareTo(b.key.name);
    });
    return scored.map((e) => e.key).toList();
  }

  DateSuggestion _toSuggestion(CuratedPlace place, CatalogQuery query) {
    final reasons = <String>[];
    if (place.verified) reasons.add('verified place');
    if (query.locations.isNotEmpty) reasons.add('location match');
    if (query.foods.isNotEmpty) reasons.add('food match');
    if (query.activities.isNotEmpty) reasons.add('activity match');
    if (query.budget > 0) {
      reasons.add(
        place.estimatedCostMax > 0 ? 'within budget' : 'price not verified',
      );
    }
    if (query.mood.trim().isNotEmpty)
      reasons.add('${query.mood.toLowerCase()} mood');

    final reasonText = reasons.isEmpty
        ? (place.verified
              ? 'A verified real place near your search.'
              : 'A DateMate idea generated to match your saved preferences.')
        : '${reasons.first[0].toUpperCase()}${reasons.first.substring(1)}'
              '${reasons.length > 1 ? ' · ${reasons.skip(1).join(' · ')}' : ''}.';

    return DateSuggestion(
      id: 'place-${place.id}',
      title: place.name,
      subtitle: place.description,
      price: place.estimatedCostMax > 0
          ? place.priceLabel
          : 'Price not verified',
      category: place.categories.isNotEmpty ? place.categories.first : 'Date',
      matchTag: place.verified ? 'Verified place' : 'DateMate idea',
      location: place.locationLabel,
      // Verified seed places carry a real local asset path (see
      // assets/places/); generated "DateMate idea" places have none by
      // definition, so this stays empty and PlaceImage shows the
      // illustrated hero instead. Never a network URL — see PlaceImage's
      // doc comment for why.
      imageUrl: place.imageAsset,
      placeId: place.id,
      country: place.country,
      address: place.address,
      currency: place.currency,
      estimatedCostMin: place.estimatedCostMin,
      estimatedCostMax: place.estimatedCostMax,
      googleMapsUrl: place.googleMapsUrl,
      officialWebsiteUrl: place.officialWebsiteUrl,
      menuUrl: place.menuUrl,
      openingHours: place.hours,
      recommendationReason: reasonText,
      verifiedSourceUrl: place.verifiedSourceUrl,
      verified: place.verified,
    );
  }
}
