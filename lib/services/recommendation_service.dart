import '../models/app_models.dart';

class RecommendationService {
  List<DateSuggestion> generate({
    required CoupleModel couple,
    required String mood,
    int seed = 0,
  }) {
    if (couple.foods.isEmpty &&
        couple.activities.isEmpty &&
        couple.locations.isEmpty) {
      return [];
    }

    final foods = couple.foods.isEmpty
        ? ['a cozy cafe']
        : couple.foods.toList();
    final activities = couple.activities.isEmpty
        ? ['Cafe hopping']
        : couple.activities.toList();
    final locations = couple.locations.isEmpty
        ? ['your chosen area']
        : couple.locations.toList();

    final results = <DateSuggestion>[];

    for (var i = 0; i < 3; i++) {
      final food = foods[(i + seed) % foods.length];
      final activity = activities[(i * 2 + seed) % activities.length];
      final location = locations[(i + seed) % locations.length];

      final title = switch (i) {
        0 => '$activity + $food',
        1 => 'A $mood $activity date',
        _ => '$food & $activity in $location',
      };

      results.add(
        DateSuggestion(
          id: 'idea-${DateTime.now().microsecondsSinceEpoch}-$i-$seed',
          title: title,
          subtitle: 'A $mood plan built from the preferences you saved.',
          price: couple.budget > 0
              ? 'Up to ₱${couple.budget.round()}'
              : 'Set a budget',
          category: activity,
          matchTag: 'Matched to your choices',
          location: location,
          imageUrl: '',
        ),
      );
    }

    return results;
  }
}
