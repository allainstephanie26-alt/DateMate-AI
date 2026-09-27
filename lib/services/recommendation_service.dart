import '../models/app_models.dart';
import '../models/curated_place.dart';
import 'curated_place_service.dart';
import 'place_discovery_service.dart';

class RecommendationService {
  RecommendationService({PlaceDiscoveryService? discovery})
    : _discovery = discovery ?? PlaceDiscoveryService();
  final PlaceDiscoveryService _discovery;

  Future<List<DateSuggestion>> generateAsync({
    required CoupleModel couple,
    required String mood,
    int seed = 0,
    Set<String> excludedPlaceIds = const <String>{},
    Set<String>? foodsOverride,
    Set<String>? activitiesOverride,
    bool preferCheapest = false,
  }) async {
    final effectiveCouple = couple.copyWith(
      foods: foodsOverride,
      activities: activitiesOverride,
    );

    if (effectiveCouple.locations.isEmpty) {
      return generate(
        couple: effectiveCouple,
        mood: mood,
        seed: seed,
        excludedPlaceIds: excludedPlaceIds,
        preferCheapest: preferCheapest,
      );
    }

    final dynamicPlaces = await _discovery.discover(
      couple: effectiveCouple,
      mood: mood,
    );
    final filtered = _filterPlaces(
      dynamicPlaces,
      couple: effectiveCouple,
      mood: mood,
      excludedPlaceIds: excludedPlaceIds,
    );
    if (filtered.isNotEmpty) {
      return _rank(
        filtered,
        couple: effectiveCouple,
        mood: mood,
        seed: seed,
        preferCheapest: preferCheapest,
      );
    }

    return generate(
      couple: effectiveCouple,
      mood: mood,
      seed: seed,
      excludedPlaceIds: excludedPlaceIds,
      preferCheapest: preferCheapest,
    );
  }

  Future<List<DateSuggestion>> generateMoodAsync({
    required String mood,
    CoupleModel? couple,
    int seed = 0,
    Set<String> excludedPlaceIds = const <String>{},
    Set<String>? foodsOverride,
    Set<String>? activitiesOverride,
    bool preferCheapest = false,
  }) async {
    if (couple?.locations.isNotEmpty == true) {
      final effectiveCouple = couple!.copyWith(
        foods: foodsOverride,
        activities: activitiesOverride,
      );
      final dynamicPlaces = await _discovery.discover(
        couple: effectiveCouple,
        mood: mood,
      );
      final moodPlaces = _filterMood(
        dynamicPlaces,
        mood,
      ).where((place) => !excludedPlaceIds.contains(place.id)).toList();
      if (moodPlaces.isNotEmpty) {
        return _rank(
          moodPlaces,
          couple: effectiveCouple,
          mood: mood,
          seed: seed,
          preferCheapest: preferCheapest,
        );
      }
    }
    return generateForMood(
      mood,
      seed: seed,
      excludedPlaceIds: excludedPlaceIds,
      preferCheapest: preferCheapest,
    );
  }

  List<DateSuggestion> generate({
    required CoupleModel couple,
    required String mood,
    int seed = 0,
    Set<String> excludedPlaceIds = const <String>{},
    bool preferCheapest = false,
  }) {
    final places = _filterPlaces(
      CuratedPlaceService.places,
      couple: couple,
      mood: mood,
      excludedPlaceIds: excludedPlaceIds,
    );
    return _rank(
      places,
      couple: couple,
      mood: mood,
      seed: seed,
      preferCheapest: preferCheapest,
    );
  }

  List<DateSuggestion> generateForMood(
    String mood, {
    int seed = 0,
    Set<String> excludedPlaceIds = const <String>{},
    bool preferCheapest = false,
  }) => _rank(
    _filterMood(
      CuratedPlaceService.places,
      mood,
    ).where((place) => !excludedPlaceIds.contains(place.id)).toList(),
    mood: mood,
    seed: seed,
    preferCheapest: preferCheapest,
  );

  List<CuratedPlace> _filterPlaces(
    Iterable<CuratedPlace> source, {
    required CoupleModel couple,
    required String mood,
    Set<String> excludedPlaceIds = const <String>{},
  }) {
    return source.where((place) {
      if (excludedPlaceIds.contains(place.id)) return false;
      if (couple.locations.isNotEmpty &&
          !couple.locations.any(place.matchesLocation))
        return false;
      if (couple.foods.isNotEmpty &&
          !_matchesAnyRequested(couple.foods, place, food: true))
        return false;
      if (couple.activities.isNotEmpty &&
          !_matchesAnyRequested(couple.activities, place, food: false))
        return false;
      // A fixed budget is a hard ceiling. Unknown prices cannot be treated as fitting the budget.
      if (couple.budget > 0 &&
          (place.estimatedCostMax <= 0 ||
              place.estimatedCostMax > couple.budget))
        return false;
      return true;
    }).toList();
  }

  List<CuratedPlace> _filterMood(Iterable<CuratedPlace> source, String mood) {
    final value = mood.trim().toLowerCase();
    return source.where((place) {
      if (value == 'foodie')
        return place.foodTypes.isNotEmpty ||
            place.categories.any(_foodCategory);
      if (value == 'cheap date')
        return place.estimatedCostMax == 0 ||
            place.budgetLevel <= 1 ||
            place.estimatedCostMax <= 1000;
      if (value == 'adventurous')
        return place.categories.any(
              (v) => _containsAny(v, const ['adventure', 'activity']),
            ) ||
            place.tags.any(
              (v) => _containsAny(v, const [
                'adventure',
                'outdoor',
                'escape',
                'sport',
                'golf',
                'theme park',
              ]),
            );
      return place.categories.any(
            (v) => _containsAny(v, const ['cafe', 'park', 'museum', 'culture']),
          ) ||
          place.tags.any(
            (v) => _containsAny(v, const [
              'chill',
              'cafe',
              'park',
              'garden',
              'museum',
            ]),
          );
    }).toList();
  }

  bool _matchesAnyRequested(
    Set<String> requested,
    CuratedPlace place, {
    required bool food,
  }) {
    for (final wanted in requested) {
      if (_matchesRequested(wanted, place, food: food)) return true;
    }
    return false;
  }

  bool _matchesRequested(
    String wanted,
    CuratedPlace place, {
    required bool food,
  }) {
    final query = _normalize(wanted);
    if (query.isEmpty) return false;
    final available = <String>{
      ...place.categories,
      ...place.tags,
      ...place.foodTypes,
      place.name,
    }.map(_normalize).where((v) => v.isNotEmpty).toSet();

    final aliases = _aliases(query, food: food);
    for (final alias in aliases) {
      if (available.any(
        (candidate) =>
            candidate == alias ||
            candidate.contains(alias) ||
            alias.contains(candidate),
      ))
        return true;
    }
    final words = query.split(' ').where((v) => v.length > 2).toList();
    return words.isNotEmpty &&
        available.any((candidate) => words.every(candidate.contains));
  }

  Set<String> _aliases(String query, {required bool food}) {
    final values = <String>{query};
    if (food) {
      if (query.contains('ramen')) values.addAll({'ramen'});
      if (query.contains('korean bbq') || query == 'bbq')
        values.addAll({'korean', 'bbq', 'barbecue'});
      if (query.contains('japanese'))
        values.addAll({'japanese', 'sushi', 'ramen'});
      if (query.contains('cafe') || query.contains('coffee'))
        values.addAll({'cafe', 'coffee'});
      if (query.contains('dessert') || query.contains('ice cream'))
        values.addAll({'dessert', 'ice cream', 'confectionery', 'cake'});
      if (query.contains('pizza')) values.addAll({'pizza', 'italian'});
      if (query.contains('pasta')) values.addAll({'pasta', 'italian'});
      if (query.contains('thai')) values.add('thai');
      if (query.contains('steak')) values.addAll({'steak', 'steak house'});
    } else {
      if (query.contains('movie')) values.add('cinema');
      if (query.contains('museum')) values.add('museum');
      if (query.contains('arcade')) values.addAll({'arcade', 'game'});
      if (query.contains('walk') || query.contains('picnic'))
        values.addAll({'park', 'garden'});
      if (query.contains('art'))
        values.addAll({'gallery', 'culture', 'arts centre'});
      if (query.contains('shopping')) values.add('shopping');
      if (query.contains('adventurous'))
        values.addAll({'adventure', 'activity'});
      if (query.contains('live music'))
        values.addAll({'music', 'theatre', 'concert'});
    }
    return values;
  }

  bool _containsAny(String value, List<String> terms) {
    final v = value.toLowerCase();
    return terms.any(v.contains);
  }

  bool _foodCategory(String value) => _containsAny(value, [
    'food',
    'ramen',
    'cafe',
    'restaurant',
    'dessert',
    'food court',
  ]);
  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll('_', ' ')
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  List<DateSuggestion> _rank(
    List<CuratedPlace> places, {
    CoupleModel? couple,
    String mood = '',
    int seed = 0,
    bool preferCheapest = false,
  }) {
    final scored = places.map((place) {
      var score = 0;
      if (couple != null) {
        if (couple.locations.isNotEmpty) score += 20;
        if (couple.foods.isNotEmpty &&
            _matchesAnyRequested(couple.foods, place, food: true))
          score += 20;
        if (couple.activities.isNotEmpty &&
            _matchesAnyRequested(couple.activities, place, food: false))
          score += 20;
        if (couple.budget > 0 &&
            place.estimatedCostMax > 0 &&
            place.estimatedCostMax <= couple.budget)
          score += 10;
        if (couple.budget > 0 && place.estimatedCostMax == 0) score -= 2;
      }
      final moodValue = mood.toLowerCase();
      if (moodValue == 'foodie' &&
          (place.foodTypes.isNotEmpty || place.categories.any(_foodCategory)))
        score += 8;
      if (moodValue == 'cheap date' &&
          (place.estimatedCostMax == 0 || place.budgetLevel <= 1))
        score += 8;
      if (moodValue == 'adventurous' &&
          place.categories.any(
            (v) => _containsAny(v, ['adventure', 'activity']),
          ))
        score += 8;
      if (moodValue == 'chill' &&
          place.categories.any(
            (v) => _containsAny(v, ['cafe', 'park', 'museum', 'culture']),
          ))
        score += 8;
      return MapEntry(place, score);
    }).toList();

    scored.sort((a, b) {
      if (preferCheapest) {
        final aCost = a.key.estimatedCostMax;
        final bCost = b.key.estimatedCostMax;
        final cost = aCost.compareTo(bCost);
        if (cost != 0) return cost;
      }
      final score = b.value.compareTo(a.value);
      return score != 0 ? score : a.key.name.compareTo(b.key.name);
    });

    if (scored.isEmpty) return [];
    final rotation = preferCheapest ? 0 : seed % scored.length;
    final rotated = [...scored.skip(rotation), ...scored.take(rotation)];
    return rotated
        .take(8)
        .map((entry) => _toSuggestion(entry.key, couple, mood))
        .toList();
  }

  DateSuggestion _toSuggestion(
    CuratedPlace place,
    CoupleModel? couple,
    String mood,
  ) {
    final reasons = <String>[];
    if (couple?.locations.isNotEmpty == true) reasons.add('location match');
    if (couple?.foods.isNotEmpty == true) reasons.add('food match');
    if (couple?.activities.isNotEmpty == true) reasons.add('activity match');
    if (couple?.budget != null && couple!.budget > 0)
      reasons.add(
        place.estimatedCostMax > 0 ? 'within budget' : 'price not verified',
      );
    if (mood.trim().isNotEmpty) reasons.add('${mood.toLowerCase()} mood');

    return DateSuggestion(
      id: 'place-${place.id}',
      title: place.name,
      subtitle: place.description,
      price: place.estimatedCostMax > 0
          ? place.priceLabel
          : 'Price not verified',
      category: place.categories.isNotEmpty ? place.categories.first : 'Date',
      matchTag: reasons.isEmpty ? 'DateMate pick' : reasons.join(' · '),
      location: place.locationLabel,
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
      recommendationReason: _reason(place, couple, mood),
      verifiedSourceUrl: place.verifiedSourceUrl,
    );
  }

  String _reason(CuratedPlace place, CoupleModel? couple, String mood) {
    final reasons = <String>[];
    if (couple?.locations.isNotEmpty == true)
      reasons.add('it was found in your selected location');
    if (couple?.foods.isNotEmpty == true)
      reasons.add('it matches your selected food preference');
    if (couple?.activities.isNotEmpty == true)
      reasons.add('it matches your selected activity preference');
    if (couple?.budget != null && couple!.budget > 0)
      reasons.add(
        place.estimatedCostMax > 0
            ? 'its stored planning estimate fits your budget'
            : 'its price is not verified by the place-data source',
      );
    if (mood.trim().isNotEmpty)
      reasons.add('it fits your ${mood.toLowerCase()} mood');
    if (reasons.isEmpty) return 'A real place discovered for this date search.';
    return '${reasons.first[0].toUpperCase()}${reasons.first.substring(1)}${reasons.length > 1 ? ' ${reasons.skip(1).join(', ')}' : ''}.';
  }
}
