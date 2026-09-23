import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// A small persistent local database for the finals build.
/// Hive uses IndexedDB on web and a local database on mobile platforms,
/// so the same Dart code persists data in Chrome, Android and iOS.
class LocalDatabase {
  static const _boxName = 'datemate_database';
  late Box<String> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  dynamic read(String key, [dynamic fallback]) {
    final value = _box.get(key);
    if (value == null) return fallback;
    try {
      return jsonDecode(value);
    } catch (_) {
      return fallback;
    }
  }

  Future<void> write(String key, dynamic value) async {
    await _box.put(key, jsonEncode(value));
  }

  Future<void> delete(String key) => _box.delete(key);

  Future<void> clear() => _box.clear();
}
