import 'package:flutter/material.dart';

class PlaceCategory {
  final String key;
  final String label;
  final IconData icon;
  final bool isFood;
  final int gradientIndex;
  final List<String> nameNouns;
  final List<String> keywords;
  final int budgetLevel; // 1 = budget-friendly, 2 = mid, 3 = splurge

  const PlaceCategory({
    required this.key,
    required this.label,
    required this.icon,
    required this.isFood,
    required this.gradientIndex,
    required this.nameNouns,
    required this.keywords,
    required this.budgetLevel,
  });
}

class CatalogData {
  CatalogData._();

  // ---------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------
  static const foodCategories = <PlaceCategory>[
    PlaceCategory(
      key: 'ramen',
      label: 'Ramen',
      icon: Icons.ramen_dining_rounded,
      isFood: true,
      gradientIndex: 7,
      nameNouns: ['Ramen House', 'Noodle Bar', 'Ramen Kitchen', 'Ramen Stop'],
      keywords: ['ramen', 'noodle', 'japanese'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'korean_bbq',
      label: 'Korean BBQ',
      icon: Icons.outdoor_grill_rounded,
      isFood: true,
      gradientIndex: 1,
      nameNouns: ['Korean Grill', 'BBQ House', 'Grill Table', 'BBQ Garden'],
      keywords: ['korean', 'bbq', 'barbecue', 'grill'],
      budgetLevel: 2,
    ),
    PlaceCategory(
      key: 'pasta',
      label: 'Pasta',
      icon: Icons.dinner_dining_rounded,
      isFood: true,
      gradientIndex: 5,
      nameNouns: ['Trattoria', 'Pasta Bar', 'Pasta Kitchen', 'Italian Table'],
      keywords: ['pasta', 'italian'],
      budgetLevel: 2,
    ),
    PlaceCategory(
      key: 'pizza',
      label: 'Pizza',
      icon: Icons.local_pizza_rounded,
      isFood: true,
      gradientIndex: 1,
      nameNouns: ['Pizzeria', 'Pizza Kitchen', 'Pizza Bar', 'Wood-Fire Pizza'],
      keywords: ['pizza', 'italian'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'cafe',
      label: 'Cafe',
      icon: Icons.local_cafe_rounded,
      isFood: true,
      gradientIndex: 5,
      nameNouns: ['Coffee House', 'Cafe', 'Coffee Roasters', 'Brew Bar'],
      keywords: ['cafe', 'coffee'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'dessert',
      label: 'Dessert',
      icon: Icons.icecream_rounded,
      isFood: true,
      gradientIndex: 4,
      nameNouns: ['Dessert Bar', 'Sweets House', 'Patisserie', 'Dessert Cafe'],
      keywords: ['dessert', 'sweets', 'cake', 'ice cream'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'steak',
      label: 'Steak',
      icon: Icons.set_meal_rounded,
      isFood: true,
      gradientIndex: 7,
      nameNouns: ['Steakhouse', 'Chophouse', 'Grill Room', 'Steak Bar'],
      keywords: ['steak', 'grill'],
      budgetLevel: 3,
    ),
    PlaceCategory(
      key: 'thai',
      label: 'Thai',
      icon: Icons.soup_kitchen_rounded,
      isFood: true,
      gradientIndex: 2,
      nameNouns: ['Thai Kitchen', 'Thai Table', 'Thai Garden', 'Thai Bistro'],
      keywords: ['thai'],
      budgetLevel: 2,
    ),
    PlaceCategory(
      key: 'japanese',
      label: 'Japanese',
      icon: Icons.set_meal_rounded,
      isFood: true,
      gradientIndex: 6,
      nameNouns: ['Izakaya', 'Sushi Bar', 'Japanese Kitchen', 'Robata Grill'],
      keywords: ['japanese', 'sushi'],
      budgetLevel: 2,
    ),
    PlaceCategory(
      key: 'vegetarian',
      label: 'Vegetarian',
      icon: Icons.eco_rounded,
      isFood: true,
      gradientIndex: 2,
      nameNouns: [
        'Plant Kitchen',
        'Vegetarian Table',
        'Greens Bar',
        'Garden Kitchen',
      ],
      keywords: ['vegetarian', 'vegan', 'plant based'],
      budgetLevel: 2,
    ),
    PlaceCategory(
      key: 'silog',
      label: 'Silog',
      icon: Icons.rice_bowl_rounded,
      isFood: true,
      gradientIndex: 1,
      nameNouns: ['Silogan', 'Tapsilogan', 'Silog House', 'Turo-Turo'],
      keywords: ['silog', 'tapsilog', 'filipino'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'milk_tea',
      label: 'Milk tea',
      icon: Icons.emoji_food_beverage_rounded,
      isFood: true,
      gradientIndex: 4,
      nameNouns: ['Milk Tea Bar', 'Tea House', 'Bubble Tea Stop', 'Tea Bar'],
      keywords: ['milk tea', 'bubble tea', 'tea'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'ice_cream',
      label: 'Ice cream',
      icon: Icons.icecream_outlined,
      isFood: true,
      gradientIndex: 4,
      nameNouns: ['Creamery', 'Ice Cream Bar', 'Gelato House', 'Sundae Shop'],
      keywords: ['ice cream', 'gelato', 'dessert'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'food',
      label: 'Food',
      icon: Icons.restaurant_rounded,
      isFood: true,
      gradientIndex: 0,
      nameNouns: ['Kitchen', 'Bistro', 'Eatery', 'Table', 'Diner'],
      keywords: ['food', 'restaurant'],
      budgetLevel: 2,
    ),
  ];

  static const activityCategories = <PlaceCategory>[
    PlaceCategory(
      key: 'cafe_hopping',
      label: 'Cafe hopping',
      icon: Icons.coffee_maker_rounded,
      isFood: false,
      gradientIndex: 5,
      nameNouns: ['Coffee House', 'Cafe Row', 'Specialty Cafe', 'Corner Cafe'],
      keywords: ['cafe', 'coffee'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'movies',
      label: 'Movies',
      icon: Icons.local_movies_rounded,
      isFood: false,
      gradientIndex: 8,
      nameNouns: ['Cinema', 'Movie House', 'Film Theater', 'Cineplex'],
      keywords: ['movie', 'cinema', 'film'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'night_market',
      label: 'Night market',
      icon: Icons.storefront_rounded,
      isFood: false,
      gradientIndex: 1,
      nameNouns: [
        'Night Market',
        'Street Market',
        'Market Row',
        'Weekend Market',
      ],
      keywords: ['market', 'night market', 'street food'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'museum',
      label: 'Museum',
      icon: Icons.museum_rounded,
      isFood: false,
      gradientIndex: 3,
      nameNouns: ['Museum', 'Heritage House', 'Gallery Museum', 'Exhibit Hall'],
      keywords: ['museum', 'gallery', 'culture', 'heritage'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'arcade',
      label: 'Arcade',
      icon: Icons.sports_esports_rounded,
      isFood: false,
      gradientIndex: 8,
      nameNouns: ['Arcade', 'Game Hub', 'Fun Zone', 'Play Arena'],
      keywords: ['arcade', 'game', 'fun zone'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'picnic',
      label: 'Picnic',
      icon: Icons.grass_rounded,
      isFood: false,
      gradientIndex: 2,
      nameNouns: ['Park', 'Garden', 'Green Grounds', 'Picnic Grove'],
      keywords: ['park', 'garden', 'picnic'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'walk',
      label: 'Walk',
      icon: Icons.directions_walk_rounded,
      isFood: false,
      gradientIndex: 2,
      nameNouns: ['Promenade', 'Riverwalk', 'Boardwalk', 'Trail'],
      keywords: ['walk', 'trail', 'promenade'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'culture',
      label: 'Culture',
      icon: Icons.temple_buddhist_rounded,
      isFood: false,
      gradientIndex: 3,
      nameNouns: [
        'Heritage Site',
        'Cultural Center',
        'Historic Plaza',
        'Landmark',
      ],
      keywords: ['culture', 'heritage', 'historic'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'adventurous',
      label: 'Adventurous',
      icon: Icons.terrain_rounded,
      isFood: false,
      gradientIndex: 6,
      nameNouns: [
        'Adventure Park',
        'Zipline Park',
        'Trail Course',
        'Adventure Camp',
      ],
      keywords: ['adventure', 'zipline', 'trail', 'outdoor'],
      budgetLevel: 2,
    ),
    PlaceCategory(
      key: 'beach',
      label: 'Beach',
      icon: Icons.beach_access_rounded,
      isFood: false,
      gradientIndex: 6,
      nameNouns: ['Beach Cove', 'Beach Resort', 'Beach Club', 'Shoreline'],
      keywords: ['beach', 'shore', 'resort'],
      budgetLevel: 2,
    ),
    PlaceCategory(
      key: 'photography',
      label: 'Photography',
      icon: Icons.camera_alt_rounded,
      isFood: false,
      gradientIndex: 9,
      nameNouns: ['Viewpoint', 'Photo Spot', 'Scenic Deck', 'Overlook'],
      keywords: ['photography', 'viewpoint', 'scenic'],
      budgetLevel: 1,
    ),
    PlaceCategory(
      key: 'live_music',
      label: 'Live music',
      icon: Icons.music_note_rounded,
      isFood: false,
      gradientIndex: 8,
      nameNouns: ['Music Lounge', 'Live House', 'Acoustic Bar', 'Sessions Bar'],
      keywords: ['live music', 'music', 'band'],
      budgetLevel: 2,
    ),
    PlaceCategory(
      key: 'shopping',
      label: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      isFood: false,
      gradientIndex: 3,
      nameNouns: ['Shopping Center', 'Mall', 'Marketplace', 'Lifestyle Mall'],
      keywords: ['mall', 'shopping'],
      budgetLevel: 2,
    ),
    PlaceCategory(
      key: 'art',
      label: 'Art',
      icon: Icons.palette_rounded,
      isFood: false,
      gradientIndex: 9,
      nameNouns: ['Art Gallery', 'Art Space', 'Studio Gallery', 'Creative Hub'],
      keywords: ['art', 'gallery', 'studio'],
      budgetLevel: 1,
    ),
  ];

  static List<PlaceCategory> get allCategories => [
    ...foodCategories,
    ...activityCategories,
  ];

  static PlaceCategory? categoryByKey(String key) {
    for (final c in allCategories) {
      if (c.key == key) return c;
    }
    return null;
  }

  static PlaceCategory? matchCategory(String freeText, {required bool food}) {
    final v = freeText.toLowerCase().trim();
    final pool = food ? foodCategories : activityCategories;
    for (final c in pool) {
      if (c.label.toLowerCase() == v) return c;
    }
    for (final c in pool) {
      if (c.keywords.any((k) => v.contains(k) || k.contains(v))) return c;
    }
    return null;
  }

  static const cities = <String, _CityInfo>{
    'Angeles City': _CityInfo(
      province: 'Pampanga',
      priceMultiplier: 1.0,
      districts: [
        'Balibago',
        'Friendship Highway',
        'Fields Avenue',
        'Marquee Mall area',
        'Santo Domingo',
        'Malabañas',
      ],
    ),
    'Clark': _CityInfo(
      province: 'Pampanga',
      priceMultiplier: 1.15,
      districts: [
        'Clark Freeport Zone',
        'Mimosa',
        'SM City Clark area',
        'Filinvest Corporate City',
      ],
    ),
    'San Fernando': _CityInfo(
      province: 'Pampanga',
      priceMultiplier: 0.95,
      districts: ['Dolores', 'San Jose', 'Maimpis', 'Del Pilar'],
    ),
    'Makati': _CityInfo(
      province: 'Metro Manila',
      priceMultiplier: 1.5,
      districts: [
        'Poblacion',
        'Salcedo Village',
        'Legazpi Village',
        'Rockwell',
        'San Antonio',
      ],
    ),
    'Manila': _CityInfo(
      province: 'Metro Manila',
      priceMultiplier: 1.2,
      districts: ['Ermita', 'Malate', 'Intramuros', 'Binondo', 'Quiapo'],
    ),
    'Taguig': _CityInfo(
      province: 'Metro Manila',
      priceMultiplier: 1.45,
      districts: ['Bonifacio Global City', 'McKinley Hill', 'Fort Bonifacio'],
    ),
    'Quezon City': _CityInfo(
      province: 'Metro Manila',
      priceMultiplier: 1.15,
      districts: ['Tomas Morato', 'Eastwood', 'Katipunan', 'Timog Avenue'],
    ),
    'Pasig': _CityInfo(
      province: 'Metro Manila',
      priceMultiplier: 1.25,
      districts: ['Kapitolyo', 'Ortigas Center', 'Capitol Commons'],
    ),
    'Antipolo': _CityInfo(
      province: 'Rizal',
      priceMultiplier: 1.0,
      districts: ['Sumulong Highway', 'Cupang', 'Masinag'],
    ),
    'Tagaytay': _CityInfo(
      province: 'Cavite',
      priceMultiplier: 1.2,
      districts: ['Olivarez', 'Mendez Crossing', 'Silang Crossing'],
    ),
    'Baguio': _CityInfo(
      province: 'Benguet',
      priceMultiplier: 1.1,
      districts: ['Session Road', 'Camp John Hay', 'Legarda Road', 'Burnham'],
    ),
    'Cebu City': _CityInfo(
      province: 'Cebu',
      priceMultiplier: 1.15,
      districts: ['IT Park', 'Lahug', 'Capitol Site', 'Mabolo'],
    ),
    'Davao City': _CityInfo(
      province: 'Davao del Sur',
      priceMultiplier: 1.05,
      districts: ['Lanang', 'Matina', 'Bajada', 'Roxas Avenue'],
    ),
    'Iloilo City': _CityInfo(
      province: 'Iloilo',
      priceMultiplier: 1.0,
      districts: ['Iloilo Business Park', 'Jaro', 'Smallville'],
    ),
    'Bacolod': _CityInfo(
      province: 'Negros Occidental',
      priceMultiplier: 0.95,
      districts: ['Lacson Street', 'Goldenfields', 'Capitol Shopping Area'],
    ),
    'Subic': _CityInfo(
      province: 'Zambales',
      priceMultiplier: 1.1,
      districts: ['Subic Bay Freeport Zone', 'Baretto', 'Waterfront Road'],
    ),
  };

  static List<String> get cityNames => cities.keys.toList();

  static _CityInfo cityInfo(String city) =>
      cities[city] ??
      const _CityInfo(
        province: '',
        priceMultiplier: 1.0,
        districts: ['Downtown'],
      );

  // ---------------------------------------------------------------------
  // Name-generation fragments
  // ---------------------------------------------------------------------
  static const adjectives = <String>[
    'Golden',
    'Sunset',
    'Garden',
    'Cozy',
    'Urban',
    'Blue Hour',
    'Heritage',
    'Skyline',
    'Riverside',
    'Hidden',
    'Velvet',
    'Copper',
    'Maple',
    'Lantern',
    'Paper Moon',
    'Coral',
    'Amber',
    'Willow',
    'Cloud Nine',
    'Silver',
    'Little',
    'Old Town',
    'Northside',
    'Southbank',
    'Morning',
    'Evening',
    'Rustic',
    'Modern',
    'Vintage',
    'Daybreak',
    'Twilight',
    'First Light',
    'Quiet',
    'Sunny',
    'Breezy',
    'Warm',
    'Bright',
    'Homey',
    'Classic',
  ];

  static const connectors = <String>['', 'The ', ''];

  static const streetSuffixes = <String>[
    'Street',
    'Avenue',
    'Road',
    'Highway',
    'Lane',
    'Boulevard',
  ];
}

class _CityInfo {
  final String province;
  final double priceMultiplier;
  final List<String> districts;
  const _CityInfo({
    required this.province,
    required this.priceMultiplier,
    required this.districts,
  });
}
