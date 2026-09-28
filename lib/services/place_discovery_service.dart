import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/app_models.dart';
import '../models/curated_place.dart';

class PlaceDiscoveryService {
  PlaceDiscoveryService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const nominatimUrl = 'https://nominatim.openstreetmap.org/search';
  static const overpassEndpoints = <String>[
    'https://overpass-api.de/api/interpreter',
    'https://overpass.private.coffee/api/interpreter',
  ];

  static const int radiusMeters = 15000;
  static const int maxResults = 100;

  final Map<String, _GeocodedLocation?> _locationCache = {};
  final Map<String, List<CuratedPlace>> _placeCache = {};
  DateTime? _lastGeocodeRequest;

  Future<List<CuratedPlace>> discover({
    required CoupleModel? couple,
    required String mood,
  }) async {
    final location = couple?.locations.isNotEmpty == true
        ? couple!.locations.first.trim()
        : '';
    if (location.isEmpty) return [];

    final geocoded = await _geocode(location);
    if (geocoded == null) return [];

    final cacheKey = _cacheKey(location, couple, mood);
    final cached = _placeCache[cacheKey];
    if (cached != null) return List<CuratedPlace>.from(cached);

    final query = _buildQuery(
      lat: geocoded.lat,
      lon: geocoded.lon,
      foods: couple?.foods ?? const <String>{},
      activities: couple?.activities ?? const <String>{},
      mood: mood,
    );

    final raw = await _queryOverpass(query);
    final unique = <String, CuratedPlace>{};
    for (final element in raw) {
      final place = _toPlace(element, geocoded, couple?.budgetCurrency ?? '');
      if (place != null) unique[place.id] = place;
    }

    final result = unique.values.take(maxResults).toList();
    _placeCache[cacheKey] = result;
    return List<CuratedPlace>.from(result);
  }

  Future<_GeocodedLocation?> _geocode(String value) async {
    final key = value.toLowerCase().trim();
    if (_locationCache.containsKey(key)) return _locationCache[key];

    final last = _lastGeocodeRequest;
    if (last != null) {
      final wait = const Duration(seconds: 1) - DateTime.now().difference(last);
      if (wait > Duration.zero) await Future<void>.delayed(wait);
    }
    _lastGeocodeRequest = DateTime.now();

    try {
      final uri = Uri.parse(nominatimUrl).replace(
        queryParameters: {
          'q': value,
          'format': 'jsonv2',
          'limit': '1',
          'addressdetails': '1',
        },
      );

      final response = await _client
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'User-Agent':
                  'DateMate-AI/1.0 (+https://github.com/allainstephanie26-alt/DateMate-AI)',
            },
          )
          .timeout(const Duration(seconds: 9));
      if (response.statusCode != 200) {
        _locationCache[key] = null;
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty || decoded.first is! Map) {
        _locationCache[key] = null;
        return null;
      }

      final item = Map<String, dynamic>.from(decoded.first as Map);
      final lat = double.tryParse(item['lat']?.toString() ?? '');
      final lon = double.tryParse(item['lon']?.toString() ?? '');
      if (lat == null || lon == null) {
        _locationCache[key] = null;
        return null;
      }

      final address = item['address'] is Map
          ? Map<String, dynamic>.from(item['address'] as Map)
          : <String, dynamic>{};
      final city =
          (address['city'] ??
                  address['town'] ??
                  address['municipality'] ??
                  address['village'] ??
                  address['county'] ??
                  value)
              .toString();
      final state = (address['state'] ?? address['state_district'] ?? '')
          .toString();
      final country = (address['country'] ?? '').toString().trim();
      final normalizedCountry = country.toLowerCase();
      // DateMate-AI is Philippines-only. If the selected location resolves
      // outside the Philippines, do not query or display foreign places.
      final isPhilippines =
          normalizedCountry == 'philippines' ||
          normalizedCountry == 'the philippines' ||
          normalizedCountry == 'ph' ||
          normalizedCountry == 'republic of the philippines';
      if (!isPhilippines) {
        _locationCache[key] = null;
        return null;
      }
      final result = _GeocodedLocation(
        lat: lat,
        lon: lon,
        city: city,
        state: state,
        country: country,
        displayName: item['display_name']?.toString() ?? value,
      );
      _locationCache[key] = result;
      return result;
    } catch (_) {
      _locationCache[key] = null;
      return null;
    }
  }

  String _buildQuery({
    required double lat,
    required double lon,
    required Set<String> foods,
    required Set<String> activities,
    required String mood,
  }) {
    final requestedTerms = <String>{
      ...foods.expand(_searchTermsForFood),
      ...activities.expand(_searchTermsForActivity),
      ..._searchTermsForMood(mood),
    }..removeWhere((v) => v.trim().isEmpty);

    final escaped = requestedTerms
        .map(_cleanRegex)
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList();
    final requestedRegex = escaped.isEmpty ? '' : escaped.join('|');

    final specific = requestedRegex.isEmpty
        ? ''
        : '''
  nwr(around:$radiusMeters,$lat,$lon)["name"~"$requestedRegex",i];
  nwr(around:$radiusMeters,$lat,$lon)["cuisine"~"$requestedRegex",i];
  nwr(around:$radiusMeters,$lat,$lon)["amenity"~"$requestedRegex",i];
  nwr(around:$radiusMeters,$lat,$lon)["leisure"~"$requestedRegex",i];
  nwr(around:$radiusMeters,$lat,$lon)["tourism"~"$requestedRegex",i];
''';

    return '''
[out:json][timeout:25];
(
  nwr(around:$radiusMeters,$lat,$lon)["name"]["amenity"~"restaurant|cafe|fast_food|food_court|ice_cream|cinema|theatre|arts_centre|museum|library"];
  nwr(around:$radiusMeters,$lat,$lon)["name"]["leisure"~"park|garden|sports_centre|fitness_centre|bowling_alley|golf_course|miniature_golf|water_park|stadium|escape_game|track"];
  nwr(around:$radiusMeters,$lat,$lon)["name"]["tourism"~"attraction|museum|theme_park|zoo|aquarium|gallery|viewpoint"];
  nwr(around:$radiusMeters,$lat,$lon)["name"]["shop"~"bakery|pastry|chocolate|coffee|confectionery|mall"];
  nwr(around:$radiusMeters,$lat,$lon)["name"]["cuisine"];
$specific
);
out center tags;
''';
  }

  Iterable<String> _searchTermsForFood(String value) {
    final v = value.toLowerCase().trim();
    if (v.contains('ramen')) return const ['ramen'];
    if (v.contains('korean bbq') || v == 'bbq')
      return const ['korean', 'bbq', 'barbecue'];
    if (v.contains('japanese')) return const ['japanese', 'sushi', 'ramen'];
    if (v.contains('thai')) return const ['thai'];
    if (v.contains('pizza')) return const ['pizza', 'italian'];
    if (v.contains('pasta') || v.contains('italian'))
      return const ['italian', 'pasta'];
    if (v.contains('steak')) return const ['steak', 'steak_house'];
    if (v.contains('dessert') || v.contains('ice cream'))
      return const ['dessert', 'ice_cream', 'confectionery', 'cake'];
    if (v.contains('cafe') || v.contains('coffee'))
      return const ['cafe', 'coffee'];
    if (v.contains('milk tea')) return const ['bubble_tea', 'tea'];
    if (v.contains('vegetarian')) return const ['vegetarian'];
    if (v.contains('food')) return const ['restaurant', 'food'];
    return [v];
  }

  Iterable<String> _searchTermsForActivity(String value) {
    final v = value.toLowerCase().trim();
    if (v.contains('movie')) return const ['cinema'];
    if (v.contains('museum')) return const ['museum'];
    if (v.contains('arcade')) return const ['arcade', 'game'];
    if (v.contains('picnic') || v == 'walk') return const ['park', 'garden'];
    if (v.contains('beach')) return const ['beach'];
    if (v.contains('live music')) return const ['music', 'concert', 'theatre'];
    if (v.contains('shopping')) return const ['mall', 'shopping'];
    if (v.contains('art')) return const ['gallery', 'arts_centre'];
    if (v.contains('culture'))
      return const ['museum', 'gallery', 'arts_centre'];
    if (v.contains('adventurous'))
      return const ['theme_park', 'escape_game', 'sports_centre', 'golf'];
    if (v.contains('cafe hopping')) return const ['cafe'];
    return [v];
  }

  Iterable<String> _searchTermsForMood(String mood) {
    final v = mood.toLowerCase().trim();
    if (v == 'foodie') return const ['restaurant', 'cafe', 'food'];
    if (v == 'adventurous')
      return const ['adventure', 'theme_park', 'sports', 'escape'];
    if (v == 'chill') return const ['cafe', 'park', 'garden', 'museum'];
    return const [];
  }

  Future<List<Map<String, dynamic>>> _queryOverpass(String query) async {
    for (final endpoint in overpassEndpoints) {
      try {
        final response = await _client
            .post(
              Uri.parse(endpoint),
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/x-www-form-urlencoded',
                'User-Agent':
                    'DateMate-AI/1.0 (+https://github.com/allainstephanie26-alt/DateMate-AI)',
              },
              body: {'data': query},
            )
            .timeout(const Duration(seconds: 30));
        if (response.statusCode != 200) continue;
        final decoded = jsonDecode(response.body);
        final elements = decoded is Map ? decoded['elements'] : null;
        if (elements is List) {
          return elements
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      } catch (_) {}
    }
    return [];
  }

  CuratedPlace? _toPlace(
    Map<String, dynamic> element,
    _GeocodedLocation location,
    String currency,
  ) {
    final rawTags = element['tags'];
    if (rawTags is! Map) return null;
    final tags = Map<String, dynamic>.from(rawTags);
    final name = tags['name']?.toString().trim() ?? '';
    if (name.isEmpty) return null;
    // The geocoded search area is already Philippines-only, but keep this
    // guard so no foreign-tagged OSM element can leak into the UI.
    final taggedCountry =
        tags['addr:country']?.toString().trim().toLowerCase() ?? '';
    if (taggedCountry.isNotEmpty &&
        taggedCountry != 'ph' &&
        taggedCountry != 'philippines' &&
        taggedCountry != 'the philippines') {
      return null;
    }

    final type = element['type']?.toString() ?? 'node';
    final osmId = element['id']?.toString() ?? name;
    final id = 'osm-$type-$osmId';
    final city = tags['addr:city']?.toString().trim().isNotEmpty == true
        ? tags['addr:city'].toString()
        : location.city;
    final address = _address(tags, city, location.state, location.country);
    final cuisine = _splitTags(tags['cuisine']);
    final categories = _categories(tags, cuisine);
    final tagsSet = <String>{
      ...categories,
      ..._splitTags(tags['leisure']),
      ..._splitTags(tags['tourism']),
      ...cuisine,
      ..._splitTags(tags['sport']),
    };

    final mapsQuery = Uri.encodeComponent(
      address.isEmpty ? '$name ${location.displayName}' : '$name, $address',
    );
    final image = tags['image']?.toString() ?? '';
    final website =
        tags['website']?.toString() ??
        tags['contact:website']?.toString() ??
        '';
    final menu =
        tags['menu']?.toString() ?? tags['contact:menu']?.toString() ?? '';
    final hours = tags['opening_hours']?.toString() ?? '';
    final price =
        tags['price_range']?.toString() ??
        tags['price:range']?.toString() ??
        '';
    final verifiedCost = _parsePriceRange(price);
    final category = categories.isEmpty ? 'Date place' : categories.first;

    return CuratedPlace(
      id: id,
      name: name,
      country: location.country.isEmpty ? 'Unknown country' : location.country,
      city: city,
      address: address.isEmpty ? location.displayName : address,
      categories: categories.isEmpty ? {'Date place'} : categories,
      tags: tagsSet.isEmpty ? {'Date place'} : tagsSet,
      foodTypes: cuisine,
      currency: currency,
      estimatedCostMin: verifiedCost?.$1 ?? 0,
      estimatedCostMax: verifiedCost?.$2 ?? 0,
      budgetLevel: verifiedCost == null ? 0 : _budgetLevel(verifiedCost.$2),
      imageAsset: image.startsWith('http') ? image : '',
      googleMapsUrl:
          'https://www.google.com/maps/search/?api=1&query=$mapsQuery',
      officialWebsiteUrl: website,
      menuUrl: menu,
      hours: hours.isEmpty ? 'Hours not verified in OpenStreetMap' : hours,
      description: _description(category, cuisine, tags),
      verifiedSourceUrl: 'https://www.openstreetmap.org/$type/$osmId',
    );
  }

  String _address(
    Map<String, dynamic> tags,
    String city,
    String state,
    String country,
  ) {
    final parts = <String>[
      tags['addr:housenumber']?.toString() ?? '',
      tags['addr:street']?.toString() ?? '',
      tags['addr:suburb']?.toString() ?? '',
      city,
      tags['addr:state']?.toString() ?? state,
      country,
    ].where((v) => v.trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  Set<String> _categories(Map<String, dynamic> tags, Set<String> cuisine) {
    final result = <String>{};
    final amenity = tags['amenity']?.toString().toLowerCase() ?? '';
    final leisure = tags['leisure']?.toString().toLowerCase() ?? '';
    final tourism = tags['tourism']?.toString().toLowerCase() ?? '';
    final shop = tags['shop']?.toString().toLowerCase() ?? '';
    if (amenity.contains('restaurant') ||
        amenity.contains('fast_food') ||
        amenity.contains('food_court'))
      result.add('Food');
    if (amenity.contains('cafe') || shop == 'coffee') result.add('Cafe');
    if (amenity.contains('ice_cream') ||
        shop == 'pastry' ||
        shop == 'chocolate' ||
        shop == 'confectionery')
      result.add('Dessert');
    if (amenity.contains('cinema')) result.add('Cinema');
    if (amenity.contains('theatre')) result.add('Theatre');
    if (amenity.contains('museum') || tourism.contains('museum'))
      result.add('Museum');
    if (tourism.contains('gallery') || amenity.contains('arts_centre'))
      result.add('Culture');
    if (leisure.contains('park') || leisure.contains('garden'))
      result.add('Park');
    if (leisure.contains('sports') ||
        leisure.contains('fitness') ||
        leisure.contains('golf') ||
        leisure.contains('bowling') ||
        leisure.contains('escape'))
      result.add('Activity');
    if (tourism.contains('theme_park') ||
        tourism.contains('zoo') ||
        tourism.contains('aquarium') ||
        tourism.contains('attraction'))
      result.add('Adventure');
    if (shop == 'mall') result.add('Shopping');
    if (cuisine.isNotEmpty) result.add('Food');
    return result;
  }

  Set<String> _splitTags(dynamic value) {
    if (value == null) return {};
    return value
        .toString()
        .split(RegExp(r'[;,]'))
        .map((v) => v.trim().replaceAll('_', ' '))
        .where((v) => v.isNotEmpty)
        .toSet();
  }

  String _description(
    String category,
    Set<String> cuisine,
    Map<String, dynamic> tags,
  ) {
    if (cuisine.isNotEmpty)
      return '$category with ${cuisine.take(3).join(', ')} listed in OpenStreetMap.';
    final leisure = tags['leisure']?.toString().replaceAll('_', ' ') ?? '';
    if (leisure.isNotEmpty)
      return '$category listed as a $leisure place in OpenStreetMap.';
    return '$category discovered for this location from OpenStreetMap data.';
  }

  (double, double)? _parsePriceRange(String value) {
    final numbers = RegExp(r'\d+(?:\.\d+)?')
        .allMatches(value)
        .map((m) => double.tryParse(m.group(0)!))
        .whereType<double>()
        .toList();
    if (numbers.isEmpty) return null;
    return numbers.length == 1
        ? (numbers.first, numbers.first)
        : (numbers.first, numbers[1]);
  }

  int _budgetLevel(double max) {
    if (max <= 500) return 1;
    if (max <= 1500) return 2;
    if (max <= 3500) return 3;
    return 4;
  }

  String _cleanRegex(String value) => value
      .trim()
      .replaceAll(RegExp(r'[\\\[\]().*+?{}|^$]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String _cacheKey(String location, CoupleModel? couple, String mood) {
    final foods =
        (couple?.foods ?? {}).map((v) => v.toLowerCase().trim()).toList()
          ..sort();
    final activities =
        (couple?.activities ?? {}).map((v) => v.toLowerCase().trim()).toList()
          ..sort();
    return '${location.toLowerCase().trim()}|${foods.join(',')}|${activities.join(',')}|${couple?.budgetCurrency ?? ''}|${couple?.budget ?? 0}|${mood.toLowerCase().trim()}';
  }

  void clearCache() {
    _locationCache.clear();
    _placeCache.clear();
  }

  void dispose() => _client.close();
}

class _GeocodedLocation {
  const _GeocodedLocation({
    required this.lat,
    required this.lon,
    required this.city,
    required this.state,
    required this.country,
    required this.displayName,
  });
  final double lat;
  final double lon;
  final String city;
  final String state;
  final String country;
  final String displayName;
}
