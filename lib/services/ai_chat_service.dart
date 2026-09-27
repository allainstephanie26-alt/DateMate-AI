import '../models/app_models.dart';
import 'recommendation_service.dart';

class AiChatMessage {
  const AiChatMessage({required this.role, required this.text});
  final String role;
  final String text;
  Map<String, dynamic> toMap() => {'role': role, 'text': text};
}

class AiChatResult {
  const AiChatResult({
    required this.reply,
    this.selectedPlaceId,
    this.selectedPlace,
  });
  final String reply;
  final String? selectedPlaceId;
  final DateSuggestion? selectedPlace;
}

/// DateMate's conversational layer is deliberately separated from the data
/// and recommendation layers. It interprets the user's request, then sends
/// the resulting constraints through the same RecommendationService used by
/// Generate Ideas. It never invents place facts.
class AiChatService {
  const AiChatService(this._recommendations);

  final RecommendationService _recommendations;

  Future<AiChatResult> sendMessage({
    required String message,
    required CoupleModel? couple,
    required String mood,
    required List<AiChatMessage> history,
    required List<DateSuggestion> places,
    Set<String> excludedPlaceIds = const <String>{},
    int seed = 0,
  }) async {
    final text = message.trim().toLowerCase();
    if (text.isEmpty) {
      return const AiChatResult(
        reply:
            'Tell me what kind of date you want and I’ll search the same real-place pipeline for you.',
      );
    }

    final cheaper =
        text.contains('cheaper') ||
        text.contains('less expensive') ||
        text.contains('lower budget') ||
        text.contains('more affordable');
    final food =
        text.contains('food') ||
        text.contains('eat') ||
        text.contains('meal') ||
        text.contains('ramen') ||
        text.contains('cafe') ||
        text.contains('coffee') ||
        text.contains('restaurant') ||
        text.contains('pizza') ||
        text.contains('pasta') ||
        text.contains('dessert') ||
        text.contains('bbq');
    final another =
        text.contains('another') ||
        text.contains('different') ||
        text.contains('pick again') ||
        text.contains('something else');
    final why = text.contains('why') || text.contains('reason');
    final price =
        text.contains('price') ||
        text.contains('cost') ||
        text.contains('expensive') ||
        text.contains('menu') ||
        text.contains('how much');
    final saved = text.contains('save') || text.contains('bucket');
    final greeting =
        text.contains('hello') ||
        text == 'hi' ||
        text.startsWith('hi ') ||
        text.contains('hey');

    // Informational requests use the currently selected pipeline result.
    // No new place is created just to answer a factual follow-up.
    if (places.isNotEmpty && (why || price || saved)) {
      final pick = places.firstWhere(
        (p) => !excludedPlaceIds.contains(p.id),
        orElse: () => places.first,
      );

      if (saved) {
        return AiChatResult(
          reply:
              '${pick.title} is ready. Tap Save on the place card to add it to your Date Bucket List.',
          selectedPlaceId: pick.id,
          selectedPlace: pick,
        );
      }
      if (why) {
        return AiChatResult(
          reply:
              'I picked ${pick.title} because ${pick.recommendationReason.toLowerCase()} I only use facts already returned by DateMate’s place-data pipeline.',
          selectedPlaceId: pick.id,
          selectedPlace: pick,
        );
      }
      final menuNote = pick.menuUrl.isNotEmpty
          ? ' The stored menu link can be opened for current menu details.'
          : ' I do not have a verified full menu, so I will not invent menu items.';
      return AiChatResult(
        reply:
            'The stored planning estimate for ${pick.title} is ${pick.price}. It is a planning guide for two, not a guaranteed current bill.$menuNote',
        selectedPlaceId: pick.id,
        selectedPlace: pick,
      );
    }

    final foodFocus = _foodFocus(text);
    final activityFocus = _activityFocus(text);

    // Chat constraints are transient. They do not overwrite the couple's
    // saved preferences. They are fed into the exact same dynamic discovery,
    // hard-filtering and ranking pipeline used by Generate Ideas.
    List<DateSuggestion> candidates;
    if (couple != null) {
      final foodsOverride = food ? <String>{foodFocus ?? 'Food'} : null;
      final activitiesOverride = activityFocus == null
          ? null
          : <String>{activityFocus};

      candidates = await _recommendations.generateAsync(
        couple: couple,
        mood: mood,
        seed: seed,
        excludedPlaceIds: excludedPlaceIds,
        foodsOverride: foodsOverride,
        activitiesOverride: activitiesOverride,
        preferCheapest: cheaper,
      );
    } else {
      candidates = await _recommendations.generateMoodAsync(
        mood: mood,
        seed: seed,
        excludedPlaceIds: excludedPlaceIds,
        preferCheapest: cheaper,
        foodsOverride: food ? <String>{foodFocus ?? 'Food'} : null,
        activitiesOverride: activityFocus == null
            ? null
            : <String>{activityFocus},
      );
    }

    if (candidates.isEmpty) {
      if (food) {
        return const AiChatResult(
          reply:
              'I could not find a real place that satisfies that food request together with the current location, preferences and budget. Try a broader food choice or a different budget.',
        );
      }
      if (cheaper) {
        return const AiChatResult(
          reply:
              'I could not find another verified place below your saved budget. I kept the budget as a hard limit rather than guessing a price.',
        );
      }
      return const AiChatResult(
        reply:
            'I could not find another verified place for those filters. I would rather say that than invent a place or price.',
      );
    }

    final pick = candidates.first;

    if (another) {
      return AiChatResult(
        reply:
            'Absolutely. I kept your current location, budget and filters, excluded the previous pick, and searched again. My next real-place pick is ${pick.title} in ${pick.location}.',
        selectedPlaceId: pick.id,
        selectedPlace: pick,
      );
    }
    if (cheaper) {
      return AiChatResult(
        reply:
            'Got it — I sent your request back through the same filters and prioritized the lower-cost verified match. My pick is ${pick.title} at ${pick.price}.',
        selectedPlaceId: pick.id,
        selectedPlace: pick,
      );
    }
    if (food) {
      return AiChatResult(
        reply:
            'Sure — I searched the same location and budget pipeline with your food request added as a temporary filter. My pick is ${pick.title} in ${pick.location}.',
        selectedPlaceId: pick.id,
        selectedPlace: pick,
      );
    }
    if (greeting) {
      return AiChatResult(
        reply:
            'Hey! 💗 Tell me the vibe, food or activity you want, and I’ll search the same real-place recommendation pipeline for you.',
        selectedPlaceId: pick.id,
        selectedPlace: pick,
      );
    }

    final vibe = mood.isEmpty
        ? 'your current filters'
        : 'your ${mood.toLowerCase()} mood';
    return AiChatResult(
      reply:
          'I’ve got you. Based on $vibe, I searched the real-place pipeline and picked ${pick.title} in ${pick.location}. Ask me why, ask for something cheaper, ask about food or price, or say “pick another.”',
      selectedPlaceId: pick.id,
      selectedPlace: pick,
    );
  }

  String? _foodFocus(String text) {
    if (text.contains('ramen')) return 'Ramen';
    if (text.contains('korean bbq') || text.contains('bbq')) return 'BBQ';
    if (text.contains('pizza')) return 'Pizza';
    if (text.contains('pasta') || text.contains('italian')) return 'Pasta';
    if (text.contains('dessert') || text.contains('ice cream'))
      return 'Dessert';
    if (text.contains('cafe') || text.contains('coffee')) return 'Cafe';
    if (text.contains('japanese')) return 'Japanese';
    if (text.contains('thai')) return 'Thai';
    if (text.contains('steak')) return 'Steak';
    return null;
  }

  String? _activityFocus(String text) {
    if (text.contains('movie') || text.contains('cinema')) return 'Movie';
    if (text.contains('museum')) return 'Museum';
    if (text.contains('arcade')) return 'Arcade';
    if (text.contains('beach')) return 'Beach';
    if (text.contains('shopping') || text.contains('mall')) return 'Shopping';
    if (text.contains('art') || text.contains('gallery')) return 'Art';
    if (text.contains('live music')) return 'Live music';
    if (text.contains('picnic') || text.contains('walk')) return 'Walk';
    return null;
  }
}
