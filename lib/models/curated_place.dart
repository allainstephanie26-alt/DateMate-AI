class CuratedPlace {
  final String id;
  final String name;
  final String country;
  final String city;
  final String address;
  final Set<String> categories;
  final Set<String> tags;
  final Set<String> foodTypes;
  final String currency;
  final double estimatedCostMin;
  final double estimatedCostMax;
  final int budgetLevel;
  final String imageAsset;
  final String googleMapsUrl;
  final String officialWebsiteUrl;
  final String menuUrl;
  final String hours;
  final String description;
  final String verifiedSourceUrl;

  final bool verified;

  const CuratedPlace({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    required this.address,
    required this.categories,
    required this.tags,
    required this.foodTypes,
    required this.currency,
    required this.estimatedCostMin,
    required this.estimatedCostMax,
    required this.budgetLevel,
    required this.imageAsset,
    required this.googleMapsUrl,
    required this.officialWebsiteUrl,
    required this.menuUrl,
    required this.hours,
    required this.description,
    required this.verifiedSourceUrl,
    this.verified = false,
  });

  String get locationLabel => '$city, $country';

  String get hoursStatus {
    final value = hours.trim();
    final lower = value.toLowerCase();
    if (value.isEmpty || lower.contains('check ') || lower.contains('vary')) {
      return 'Check hours';
    }
    final now = DateTime.now();
    final day = <String>[
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ][now.weekday - 1];
    if (RegExp(r'closed\s+' + day, caseSensitive: false).hasMatch(value)) {
      return 'Closed today';
    }
    final range = RegExp(
      r'(\d{1,2}:\d{2}\s*[AP]M)\s*[–-]\s*(\d{1,2}:\d{2}\s*[AP]M)',
      caseSensitive: false,
    ).firstMatch(value);
    if (range == null) return 'Hours listed';
    int minutes(String text) {
      final m = RegExp(
        r'(\d{1,2}):(\d{2})\s*([AP]M)',
        caseSensitive: false,
      ).firstMatch(text)!;
      var h = int.parse(m.group(1)!);
      final min = int.parse(m.group(2)!);
      final ap = m.group(3)!.toUpperCase();
      if (ap == 'PM' && h != 12) h += 12;
      if (ap == 'AM' && h == 12) h = 0;
      return h * 60 + min;
    }

    final start = minutes(range.group(1)!);
    final end = minutes(range.group(2)!);
    final current = now.hour * 60 + now.minute;
    final open = end < start
        ? (current >= start || current <= end)
        : (current >= start && current <= end);
    return open ? 'Open now' : 'Closed now';
  }

  String get priceLabel {
    if (estimatedCostMin == 0 && estimatedCostMax == 0) {
      return 'Price not verified';
    }

    return '$currency ${estimatedCostMin.round()}–${estimatedCostMax.round()} for two';
  }

  bool matchesLocation(String selected) {
    final query = _normalizeLocation(selected);
    if (query.isEmpty) return false;

    final cityValue = _normalizeLocation(city);
    final countryValue = _normalizeLocation(country);
    final addressValue = _normalizeLocation(address);
    final haystack = '$cityValue $countryValue $addressValue';

    const ignored = {
      'city',
      'province',
      'municipality',
      'metro',
      'the',
      'philippines',
      'ph',
    };
    final tokens = query
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.length > 2 && !ignored.contains(token))
        .toList();

    if (tokens.isEmpty) {
      return query == cityValue ||
          query == countryValue ||
          haystack.contains(query);
    }

    // Every meaningful location token must match. This prevents a saved
    // Angeles preference from leaking into a Clark recommendation merely
    // because both locations are in Pampanga.
    return tokens.every(haystack.contains);
  }

  String _normalizeLocation(String value) => value
      .toLowerCase()
      .replaceAll('–', '-')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  bool matchesAny(Set<String> selected, Set<String> available) {
    if (selected.isEmpty) {
      return true;
    }

    return selected.any((value) {
      final normalized = value.toLowerCase().trim();

      return available.any((candidate) {
        final candidateNormalized = candidate.toLowerCase().trim();

        return candidateNormalized.contains(normalized) ||
            normalized.contains(candidateNormalized);
      });
    });
  }
}
