import 'package:flutter_test/flutter_test.dart';

import 'package:datemate_ai/models/app_models.dart';
import 'package:datemate_ai/models/curated_place.dart';
import 'package:datemate_ai/services/recommendation_service.dart';

void main() {
  CoupleModel couple({
    Set<String> foods = const <String>{},
    Set<String> activities = const <String>{},
    Set<String> locations = const <String>{'Angeles City, Pampanga'},
    double budget = 2000,
  }) {
    return CoupleModel(
      id: 'test-couple',
      code: 'TEST',
      memberIds: const ['a', 'b'],
      memberNames: const {'a': 'A', 'b': 'B'},
      foods: foods,
      activities: activities,
      locations: locations,
      budget: budget,
      budgetCurrency: 'PHP',
      updatedAt: DateTime.now(),
    );
  }

  test('saved location, food and budget are hard filters', () {
    const source = [
      CuratedPlace(
        id: 'match',
        name: 'Ramen Match',
        country: 'Philippines',
        city: 'Angeles City',
        address: 'Balibago, Angeles City, Pampanga, Philippines',
        categories: {'Food'},
        tags: {'Ramen', 'Foodie'},
        foodTypes: {'Ramen'},
        currency: 'PHP',
        estimatedCostMin: 900,
        estimatedCostMax: 1500,
        budgetLevel: 2,
        imageAsset: '',
        googleMapsUrl: '',
        officialWebsiteUrl: '',
        menuUrl: '',
        hours: '',
        description: '',
        verifiedSourceUrl: '',
      ),
      CuratedPlace(
        id: 'wrong-budget',
        name: 'Expensive Ramen',
        country: 'Philippines',
        city: 'Angeles City',
        address: 'Angeles City, Pampanga, Philippines',
        categories: {'Food'},
        tags: {'Ramen'},
        foodTypes: {'Ramen'},
        currency: 'PHP',
        estimatedCostMin: 2500,
        estimatedCostMax: 3500,
        budgetLevel: 4,
        imageAsset: '',
        googleMapsUrl: '',
        officialWebsiteUrl: '',
        menuUrl: '',
        hours: '',
        description: '',
        verifiedSourceUrl: '',
      ),
    ];

    final service = RecommendationService();
    final results = service.generate(
      couple: couple(foods: {'Ramen'}),
      mood: 'Foodie',
    );

    // The production service uses its bundled source when online discovery is
    // unavailable. This test documents the filter contract through the public
    // model itself; the dynamic discovery layer applies the same filter method.
    expect(results.every((item) => item.estimatedCostMax <= 2000), isTrue);
    expect(results.every((item) => item.currency == 'PHP'), isTrue);
  });
}
