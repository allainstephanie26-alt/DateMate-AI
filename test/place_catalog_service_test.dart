import 'package:flutter_test/flutter_test.dart';

import 'package:datemate_ai/services/place_catalog_service.dart';

void main() {
  group('PlaceCatalogService', () {
    test('quickPicks returns results even with no saved preferences', () {
      final catalog = PlaceCatalogService();
      final results = catalog.quickPicks(const CatalogQuery());
      expect(results, isNotEmpty);
    });

    test('a location filter only returns places in that city', () {
      final catalog = PlaceCatalogService();
      final results = catalog.page(
        const CatalogQuery(locations: {'Baguio'}, foods: {'Cafe'}),
        page: 0,
        size: 20,
      );
      expect(results, isNotEmpty);
      for (final place in results) {
        expect(place.location.toLowerCase(), contains('baguio'));
      }
    });

    test('paging never repeats the same place id, proving the catalog can '
        'scroll indefinitely without an external API', () {
      final catalog = PlaceCatalogService();
      const query = CatalogQuery(locations: {'Angeles City'}, foods: {'Ramen'});
      final seen = <String>{};
      for (var page = 0; page < 12; page++) {
        final results = catalog.page(query, page: page, size: 16);
        for (final r in results) {
          expect(seen.contains(r.id), isFalse, reason: 'duplicate: ${r.id}');
          seen.add(r.id);
        }
      }
      expect(seen.length, greaterThan(100));
    });

    test('generated ideas respect the couple\'s budget ceiling', () {
      final catalog = PlaceCatalogService();
      const budget = 500.0;
      final results = catalog.page(
        const CatalogQuery(
          locations: {'Manila'},
          activities: {'Museum'},
          budget: budget,
        ),
        page: 1,
        size: 10,
      );
      expect(results, isNotEmpty);
      for (final r in results) {
        expect(r.estimatedCostMax, lessThanOrEqualTo(budget));
      }
    });

    test('an unrecognized location still returns ideas instead of nothing', () {
      final catalog = PlaceCatalogService();
      final results = catalog.page(
        const CatalogQuery(locations: {'Atlantis'}),
        page: 0,
        size: 8,
      );
      expect(results, isNotEmpty);
    });

    test(
      'verified seed places are labeled distinctly from generated ideas',
      () {
        final catalog = PlaceCatalogService();
        final results = catalog.page(
          const CatalogQuery(locations: {'Taguig'}, activities: {'Museum'}),
          page: 0,
          size: 5,
        );
        expect(results.any((r) => r.verified), isTrue);
        expect(
          results
              .where((r) => r.verified)
              .every((r) => r.matchTag == 'Verified place'),
          isTrue,
        );
      },
    );
  });
}
