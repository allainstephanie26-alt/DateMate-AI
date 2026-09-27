import 'dart:convert';

import 'package:http/http.dart' as http;

/// Free image lookup used when the app does not have a bundled place photo.
/// It uses Wikipedia's public MediaWiki API and does not require a paid API key.
class PlaceImageService {
  PlaceImageService._();

  static final Map<String, String?> _cache = <String, String?>{};

  static Future<String?> findImage(String placeName) async {
    final key = placeName.trim().toLowerCase();
    if (key.isEmpty) return null;
    if (_cache.containsKey(key)) return _cache[key];

    try {
      final uri = Uri.https('en.wikipedia.org', '/w/api.php', {
        'action': 'query',
        'generator': 'search',
        'gsrsearch': placeName,
        'gsrnamespace': '0',
        'gsrlimit': '1',
        'prop': 'pageimages',
        'piprop': 'thumbnail',
        'pithumbsize': '900',
        'format': 'json',
        'origin': '*',
      });

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        _cache[key] = null;
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final pages = body['query']?['pages'];
      if (pages is! Map) {
        _cache[key] = null;
        return null;
      }

      for (final raw in pages.values) {
        if (raw is Map) {
          final thumbnail = raw['thumbnail'];
          final source = thumbnail is Map ? thumbnail['source'] : null;
          if (source is String && source.isNotEmpty) {
            _cache[key] = source;
            return source;
          }
        }
      }
    } catch (_) {
      // The UI has a designed fallback when the public image service is unavailable.
    }

    _cache[key] = null;
    return null;
  }
}
