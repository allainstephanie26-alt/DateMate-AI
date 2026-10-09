import 'dart:async';

import '../data/catalog_data.dart';
import '../models/app_models.dart';
import 'cloud_sync_service.dart';
import 'place_catalog_service.dart';

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
    this.suggestions = const [],
  });
  final String reply;
  final String? selectedPlaceId;
  final DateSuggestion? selectedPlace;

  /// A short carousel of alternates shown under the reply so the couple can
  /// tap straight into another idea instead of typing "another" again.
  final List<DateSuggestion> suggestions;
}

class AiChatService {
  AiChatService(this._catalog, {CloudSyncService? cloud}) : _cloud = cloud;

  final PlaceCatalogService _catalog;
  final CloudSyncService? _cloud;

  /// True when the Gemini-powered Edge Function is worth attempting. Purely
  /// informational — safe to show in the chat header as a status pill.
  bool get cloudAssistantAvailable => _cloud?.enabled ?? false;

  Future<AiChatResult> sendMessage({
    required String message,
    required CoupleModel? couple,
    required String mood,
    required List<AiChatMessage> history,
    required List<DateSuggestion> places,
    Set<String> excludedPlaceIds = const <String>{},
    int seed = 0,
  }) async {
    final text = message.trim();
    final lower = text.toLowerCase();
    if (lower.isEmpty) {
      return const AiChatResult(
        reply:
            'Tell me what kind of date you want — a food craving, an '
            'activity, a mood, or even a city — and I’ll search DateMate’s '
            'place catalog for you.',
      );
    }

    if (_isGreeting(lower)) {
      return const AiChatResult(
        reply:
            'Hey! 💗 Tell me the vibe, a food craving, or an activity, '
            'and I’ll line up a date idea for you. You can also just say '
            '"surprise us".',
      );
    }
    if (_isThanks(lower)) {
      return const AiChatResult(
        reply: 'Anytime! Say the word whenever you want another idea. 💗',
      );
    }
    if (_isHelp(lower)) {
      return const AiChatResult(
        reply:
            'Try things like: "something cheap", "ramen night", '
            '"a museum date", "surprise us", "why this one?", '
            '"how much is it", or "save it". I can also switch city if you '
            'name one, e.g. "what about in Baguio?".',
      );
    }

    if (cloudAssistantAvailable) {
      final shortlist = places.isNotEmpty
          ? places
          : _catalog.quickPicks(
              CatalogQuery(
                locations: couple?.locations ?? const <String>{},
                foods: couple?.foods ?? const <String>{},
                activities: couple?.activities ?? const <String>{},
                budget: couple?.budget ?? 0,
                currency: couple?.budgetCurrency ?? 'PHP',
                mood: mood,
              ),
              count: 12,
            );
      final cloudResult = await _tryCloudReply(
        message: text,
        couple: couple,
        mood: mood,
        history: history,
        shortlist: shortlist,
        excludedPlaceIds: excludedPlaceIds,
      );
      if (cloudResult != null) return cloudResult;
    }

    final wantsCheaper = _containsAny(lower, [
      'cheaper',
      'less expensive',
      'lower budget',
      'more affordable',
      'budget friendly',
    ]);
    final wantsUpscale = _containsAny(lower, [
      'upscale',
      'fancier',
      'fancy',
      'nicer',
      'splurge',
      'premium',
      'expensive',
    ]);
    final wantsAnother = _containsAny(lower, [
      'another',
      'different',
      'pick again',
      'something else',
      'next',
      'surprise',
    ]);
    final asksWhy = _containsAny(lower, ['why', 'reason']);
    final asksPrice = _containsAny(lower, [
      'price',
      'cost',
      'how much',
      'budget for this',
    ]);
    final asksSave = _containsAny(lower, [
      'save',
      'bucket',
      'add it',
      'add this',
    ]);
    final asksHours = _containsAny(lower, [
      'hour',
      'open',
      'closed',
      'schedule',
    ]);
    final asksAddress = _containsAny(lower, [
      'where is',
      'address',
      'located',
      'location of',
    ]);

    final city = _detectCity(lower);
    final explicitBudget = _detectBudgetCeiling(lower);
    final category = _detectCategory(lower);
    final moodWord = _detectMood(lower);

    // Follow-ups about the currently selected place use it directly instead
    // of running a new search.
    if (places.isNotEmpty &&
        (asksWhy || asksPrice || asksSave || asksHours || asksAddress)) {
      final pick = places.firstWhere(
        (p) => !excludedPlaceIds.contains(p.id),
        orElse: () => places.first,
      );
      if (asksSave) {
        return AiChatResult(
          reply:
              '${pick.title} is ready — tap **Save** on the card below to '
              'add it to your Date Bucket List.',
          selectedPlaceId: pick.id,
          selectedPlace: pick,
        );
      }
      if (asksWhy) {
        return AiChatResult(
          reply:
              'I picked ${pick.title} because ${pick.recommendationReason.toLowerCase()} '
              '${pick.verified ? 'It is one of DateMate’s verified real places.' : 'It is a DateMate idea generated from your saved preferences, not a verified business — tap through to Maps before you go.'}',
          selectedPlaceId: pick.id,
          selectedPlace: pick,
        );
      }
      if (asksHours) {
        return AiChatResult(
          reply: pick.openingHours.isEmpty
              ? '${pick.title} doesn’t have listed hours yet — check the Maps link before heading out.'
              : '${pick.title} — ${pick.openingHours}.',
          selectedPlaceId: pick.id,
          selectedPlace: pick,
        );
      }
      if (asksAddress) {
        return AiChatResult(
          reply: pick.address.isEmpty
              ? '${pick.title} is in ${pick.location}. Open the Maps link on the card for exact directions.'
              : '${pick.title} is at ${pick.address}.',
          selectedPlaceId: pick.id,
          selectedPlace: pick,
        );
      }
      final menuNote = pick.menuUrl.isNotEmpty
          ? ' The stored menu link on the card has current prices.'
          : ' I don’t have a verified menu for this one, so I won’t guess exact line items.';
      return AiChatResult(
        reply:
            'The planning estimate for ${pick.title} is ${pick.price}. '
            'That’s a guide for two, not a guaranteed bill.$menuNote',
        selectedPlaceId: pick.id,
        selectedPlace: pick,
      );
    }

    // Otherwise, treat the message as a new (or refined) search.
    final locations = city != null
        ? {city}
        : (couple?.locations ?? const <String>{});
    final foods = <String>{
      if (category != null && category.isFood) category.label,
      if (category == null) ...(couple?.foods ?? const <String>{}),
    };
    final activities = <String>{
      if (category != null && !category.isFood) category.label,
      if (category == null) ...(couple?.activities ?? const <String>{}),
    };
    var budget = explicitBudget ?? couple?.budget ?? 0;
    if (wantsUpscale && budget > 0) budget = budget * 1.6;

    final query = CatalogQuery(
      locations: locations,
      foods: foods,
      activities: activities,
      budget: budget,
      currency: couple?.budgetCurrency ?? 'PHP',
      mood: moodWord ?? mood,
    );

    final results = _catalog.page(
      query,
      page: seed % 6,
      size: 6,
      excludedIds: excludedPlaceIds,
    );

    if (results.isEmpty) {
      return AiChatResult(
        reply:
            'I couldn’t find a match for that combination yet. Try '
            'loosening one thing — a different city, a wider budget, or a '
            'broader food/activity word — and I’ll search again.',
        suggestions: const [],
      );
    }

    final pick = results.first;
    final alternates = results.skip(1).take(3).toList();

    String opener;
    if (wantsAnother) {
      opener =
          'Got it — here’s another one: ${pick.title} in ${pick.location}.';
    } else if (wantsCheaper) {
      opener = 'Found a lighter option: ${pick.title} at ${pick.price}.';
    } else if (wantsUpscale) {
      opener =
          'Here’s something a bit more special: ${pick.title} in ${pick.location}.';
    } else if (category != null) {
      opener = 'On it — ${pick.title} in ${pick.location} matches that.';
    } else if (city != null) {
      opener = 'Switching the search to $city — first up: ${pick.title}.';
    } else if (moodWord != null) {
      opener =
          'For a ${moodWord.toLowerCase()} mood, I’d go with ${pick.title} in ${pick.location}.';
    } else {
      final vibe = mood.isEmpty
          ? 'your saved preferences'
          : 'your ${mood.toLowerCase()} mood';
      opener = 'Based on $vibe, I’d pick ${pick.title} in ${pick.location}.';
    }

    final tail = pick.verified
        ? ' It’s a verified real place.'
        : ' It’s a DateMate idea generated from your filters — double check it on Maps before you go.';

    return AiChatResult(
      reply:
          '$opener$tail Ask me why, ask for something cheaper or fancier, '
          'or say "pick another".',
      selectedPlaceId: pick.id,
      selectedPlace: pick,
      suggestions: alternates,
    );
  }

  Future<AiChatResult?> _tryCloudReply({
    required String message,
    required CoupleModel? couple,
    required String mood,
    required List<AiChatMessage> history,
    required List<DateSuggestion> shortlist,
    required Set<String> excludedPlaceIds,
  }) async {
    final cloud = _cloud;
    if (cloud == null || !cloud.enabled || shortlist.isEmpty) return null;

    try {
      final candidates = shortlist
          .where((s) => !excludedPlaceIds.contains(s.id))
          .take(12)
          .toList();
      if (candidates.isEmpty) return null;

      final response = await cloud.client.functions
          .invoke(
            CloudSyncService.aiChatFunction,
            body: {
              'message': message,
              'mood': mood,
              'history': history.map((m) => m.toMap()).toList(),
              'preferences': {
                'foods': (couple?.foods ?? const <String>{}).toList(),
                'activities': (couple?.activities ?? const <String>{}).toList(),
                'locations': (couple?.locations ?? const <String>{}).toList(),
                'budget': couple?.budget ?? 0,
                'currency': couple?.budgetCurrency ?? 'PHP',
              },
              'places': [
                for (final s in candidates)
                  {
                    'id': s.id,
                    'title': s.title,
                    'category': s.category,
                    'location': s.location,
                    'price': s.price,
                    'hours': s.openingHours,
                    'verified': s.verified,
                    'reason': s.recommendationReason,
                  },
              ],
            },
          )
          .timeout(const Duration(seconds: 12));

      final data = response.data;
      if (data is! Map) return null;

      final reply = (data['reply'] as String?)?.trim();
      if (reply == null || reply.isEmpty) return null;

      final selectedId = data['selectedPlaceId'] as String?;
      DateSuggestion? selected;
      if (selectedId != null) {
        for (final s in candidates) {
          if (s.id == selectedId) {
            selected = s;
            break;
          }
        }
      }

      final alternates = candidates
          .where((s) => s.id != selected?.id)
          .take(3)
          .toList();

      return AiChatResult(
        reply: reply,
        selectedPlaceId: selected?.id,
        selectedPlace: selected,
        suggestions: alternates,
      );
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------
  // Intent + entity detection
  // ---------------------------------------------------------------------

  bool _isGreeting(String v) =>
      v == 'hi' ||
      v.startsWith('hi ') ||
      v == 'hello' ||
      v.startsWith('hello') ||
      v.contains('hey') ||
      v == 'yo';

  bool _isThanks(String v) =>
      _containsAny(v, ['thank', 'thanks', 'thx', 'appreciate']);

  bool _isHelp(String v) => _containsAny(v, [
    'help',
    'what can you do',
    'how does this work',
    'commands',
  ]);

  bool _containsAny(String v, List<String> terms) => terms.any(v.contains);

  String? _detectCity(String v) {
    for (final city in CatalogData.cityNames) {
      if (v.contains(city.toLowerCase())) return city;
    }
    return null;
  }

  PlaceCategory? _detectCategory(String v) {
    for (final c in CatalogData.allCategories) {
      if (v.contains(c.label.toLowerCase())) return c;
      for (final k in c.keywords) {
        if (v.contains(k)) return c;
      }
    }
    return null;
  }

  String? _detectMood(String v) {
    if (v.contains('foodie')) return 'Foodie';
    if (v.contains('adventurous') || v.contains('adventure'))
      return 'Adventurous';
    if (v.contains('chill') || v.contains('relax')) return 'Chill';
    if (v.contains('cheap date') || v.contains('budget date'))
      return 'Cheap date';
    return null;
  }

  double? _detectBudgetCeiling(String v) {
    final match = RegExp(
      r'(under|below|within|less than)\s*(?:php|₱)?\s*([\d,]{2,7})',
    ).firstMatch(v);
    if (match == null) return null;
    final raw = match.group(2)?.replaceAll(',', '');
    return raw == null ? null : double.tryParse(raw);
  }
}
