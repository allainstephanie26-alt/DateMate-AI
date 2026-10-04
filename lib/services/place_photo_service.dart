import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacePhotoService {
  PlacePhotoService._();
  static final PlacePhotoService instance = PlacePhotoService._();

  final Map<String, String?> _cache = {};
  final Map<String, Future<String?>> _inFlight = {};

  Future<String?> findPhoto(String query, {int thumbSizePx = 960}) async {
    final key = query.trim().toLowerCase();
    if (key.isEmpty) return null;
    if (_cache.containsKey(key)) return _cache[key];
    final pending = _inFlight[key];
    if (pending != null) return pending;

    final future = _fetch(query, key, thumbSizePx);
    _inFlight[key] = future;
    final result = await future;
    _inFlight.remove(key);
    return result;
  }

  Future<String?> _fetch(String query, String key, int thumbSizePx) async {
    try {
      final uri = Uri.https('en.wikipedia.org', '/w/api.php', {
        'action': 'query',
        'generator': 'search',
        'gsrsearch': query,
        'gsrnamespace': '0',
        'gsrlimit': '1',
        'prop': 'pageimages',
        'piprop': 'thumbnail',
        'pithumbsize': '$thumbSizePx',
        'format': 'json',
        'origin': '*',
      });

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 6));

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
      _cache[key] = null;
      return null;
    } catch (_) {
      _cache[key] = null;
      return null;
    }
  }
}
