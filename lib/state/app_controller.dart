import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import '../services/cloud_sync_service.dart';
import '../services/local_database.dart';
import '../services/place_catalog_service.dart';

class AppController extends ChangeNotifier {
  final LocalDatabase db;
  final PlaceCatalogService catalog;
  final CloudSyncService cloud;

  AppController(this.db, this.catalog, this.cloud);

  UserModel? currentUser;
  CoupleModel? couple;
  List<BucketListItem> bucketItems = [];
  Set<String> favorites = {};
  String mood = 'Chill';
  List<DateSuggestion> currentSuggestions = [];

  Set<String> recentlyShownIds = {};

  bool ready = false;
  bool busy = false;
  bool syncing = false;
  bool generating = false;
  String? errorMessage;
  StreamSubscription<CoupleModel>? _coupleSubscription;
  StreamSubscription<List<BucketListItem>>? _bucketSubscription;

  static const _usersKey = 'users';
  static const _couplesKey = 'couples';
  static const _sessionKey = 'sessionUserId';

  Future<void> load() async {
    final sessionId = db.read(_sessionKey) as String?;
    if (sessionId != null) {
      if (cloud.enabled) {
        try {
          final cloudUser = await cloud.loadUser(sessionId);
          if (cloudUser != null) {
            currentUser = cloudUser;
            await _loadCouple();
          }
        } catch (_) {}
      } else {
        final users = _users;
        final raw = users[sessionId];
        if (raw != null) {
          currentUser = UserModel.fromMap(Map<String, dynamic>.from(raw));
          await _loadCouple();
        }
      }
    }
    ready = true;
    notifyListeners();
  }

  Map<String, dynamic> get _users =>
      Map<String, dynamic>.from(db.read(_usersKey, <String, dynamic>{}) as Map);
  Map<String, dynamic> get _couples => Map<String, dynamic>.from(
    db.read(_couplesKey, <String, dynamic>{}) as Map,
  );

  String _hash(String input) => sha256.convert(utf8.encode(input)).toString();
  String _id(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}';

  // ---------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------

  Future<bool> login(
    String email,
    String password, {
    bool remember = true,
  }) async {
    _setBusy(true);
    errorMessage = null;
    final normalized = email.trim().toLowerCase();
    try {
      if (cloud.enabled) {
        final credential = await cloud.signIn(normalized, password);
        final refreshed = await cloud.refreshCurrentUser() ?? credential;
        if (!refreshed.emailVerified) {
          errorMessage =
              'Please verify your email before signing in. Check your inbox for the confirmation link.';
          try {
            await cloud.resendVerificationEmail(normalized);
          } catch (_) {}
          await cloud.signOut();
          await db.delete(_sessionKey);
          _setBusy(false);
          return false;
        }
        final profile = await cloud.loadUser(refreshed.uid);
        if (profile == null) {
          errorMessage =
              'Your account profile is missing. Please create the account again.';
          _setBusy(false);
          return false;
        }
        currentUser = profile;
        if (profile.coupleId == null) {
          await createCouple();
        } else {
          await _loadCouple();
        }
      } else {
        final users = _users;
        UserModel? found;
        for (final value in users.values) {
          final user = UserModel.fromMap(Map<String, dynamic>.from(value));
          if (user.email == normalized) {
            found = user;
            break;
          }
        }
        if (found == null || found.passwordHash != _hash(password)) {
          errorMessage = 'The email or password is incorrect.';
          _setBusy(false);
          return false;
        }
        currentUser = found;
        await _loadCouple();
      }
      if (remember) {
        await db.write(_sessionKey, currentUser!.id);
      } else {
        await db.delete(_sessionKey);
      }
      _setBusy(false);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _friendlyError(e);
      _setBusy(false);
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    errorMessage = null;
    final cleanName = name.trim();
    final normalized = email.trim().toLowerCase();
    if (cleanName.isEmpty || !normalized.contains('@') || password.length < 6) {
      errorMessage =
          'Enter your name, a valid email, and a password of at least 6 characters.';
      _setBusy(false);
      return false;
    }

    try {
      if (cloud.enabled) {
        await cloud.signUp(normalized, password, name: cleanName);
        await cloud.signOut();
        await db.delete(_sessionKey);
        _setBusy(false);
        notifyListeners();
        return true;
      } else {
        final users = _users;
        if (users.values.any(
          (v) =>
              UserModel.fromMap(Map<String, dynamic>.from(v)).email ==
              normalized,
        )) {
          errorMessage = 'An account with that email already exists.';
          _setBusy(false);
          return false;
        }
        final user = UserModel(
          id: _id('user'),
          email: normalized,
          name: cleanName,
          passwordHash: _hash(password),
          coupleId: null,
          createdAt: DateTime.now(),
        );
        users[user.id] = user.toMap();
        await db.write(_usersKey, users);
        currentUser = user;
        await createCouple();
        await db.write(_sessionKey, currentUser!.id);
        _setBusy(false);
        notifyListeners();
        return true;
      }
    } catch (e) {
      errorMessage = _friendlyError(e);
      _setBusy(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    final normalized = email.trim().toLowerCase();
    if (!normalized.contains('@')) {
      errorMessage = 'Enter a valid email address.';
      notifyListeners();
      return false;
    }

    try {
      if (cloud.enabled) {
        await cloud.resetPassword(normalized);
        errorMessage = null;
        notifyListeners();
        return true;
      }
      errorMessage =
          'Password reset requires Supabase authentication to be enabled.';
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (cloud.enabled) {
      try {
        await cloud.signOut();
      } catch (_) {}
    }
    currentUser = null;
    couple = null;
    bucketItems = [];
    favorites = {};
    currentSuggestions = [];
    await db.delete(_sessionKey);
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Couple
  // ---------------------------------------------------------------------

  Future<void> createCouple() async {
    if (currentUser == null) return;
    final id = _id('couple');
    final newCouple = CoupleModel(
      id: id,
      code: _makeCode(),
      memberIds: [currentUser!.id],
      memberNames: {currentUser!.id: currentUser!.name},
      foods: <String>{},
      activities: <String>{},
      locations: <String>{},
      budget: 0,
      budgetCurrency: 'PHP',
      updatedAt: DateTime.now(),
    );
    couple = newCouple;
    if (cloud.enabled) {
      await cloud.saveCouple(newCouple);
      await _attachUserToCouple(currentUser!, id);
    } else {
      final couples = _couples;
      couples[id] = newCouple.toMap();
      await db.write(_couplesKey, couples);
      await _attachUserToCouple(currentUser!, id);
    }
    await _loadCouple();
  }

  String _makeCode() {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    return 'DM-${now.substring(now.length - 4)}';
  }

  Future<bool> joinCouple(String code) async {
    if (currentUser == null || code.trim().isEmpty) return false;
    final normalized = code.trim().toUpperCase();
    try {
      if (cloud.enabled) {
        final joined = await cloud.joinCoupleByCode(normalized);
        currentUser = currentUser!.copyWith(coupleId: joined.id);
        await _loadCouple();
        notifyListeners();
        return true;
      }

      CoupleModel? existing;
      for (final value in _couples.values) {
        final candidate = CoupleModel.fromMap(Map<String, dynamic>.from(value));
        if (candidate.code.toUpperCase() == normalized) {
          existing = candidate;
          break;
        }
      }
      if (existing == null) {
        errorMessage = 'No couple was found with that code.';
        notifyListeners();
        return false;
      }
      if (existing.memberIds.length >= 2 &&
          !existing.memberIds.contains(currentUser!.id)) {
        errorMessage = 'That couple already has two members.';
        notifyListeners();
        return false;
      }
      final members = {...existing.memberIds, currentUser!.id}.toList();
      final names = {
        ...existing.memberNames,
        currentUser!.id: currentUser!.name,
      };
      final updated = existing.copyWith(memberIds: members, memberNames: names);
      final couples = _couples;
      couples[updated.id] = updated.toMap();
      await db.write(_couplesKey, couples);
      await _attachUserToCouple(currentUser!, updated.id);
      await _loadCouple();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> _attachUserToCouple(UserModel user, String coupleId) async {
    final updated = user.copyWith(coupleId: coupleId);
    currentUser = updated;
    if (cloud.enabled) {
      await cloud.saveUser(updated);
    } else {
      final users = _users;
      users[user.id] = updated.toMap();
      await db.write(_usersKey, users);
    }
  }

  Future<void> _loadCouple() async {
    if (currentUser?.coupleId == null) {
      couple = null;
      bucketItems = [];
      favorites = {};
      currentSuggestions = [];
      return;
    }
    if (cloud.enabled) {
      couple = await cloud.loadCouple(currentUser!.coupleId!);
      if (couple != null) {
        final profiles = await cloud.loadUsers(couple!.memberIds);
        final names = {...couple!.memberNames};
        for (final entry in profiles.entries) {
          names[entry.key] = entry.value.name;
        }
        if (names.length != couple!.memberNames.length ||
            names.entries.any((e) => e.value != couple!.memberNames[e.key])) {
          couple = couple!.copyWith(memberNames: names);
          unawaited(cloud.saveCouple(couple!));
        }
        bucketItems = await cloud.loadBucket(couple!.id);
        favorites = await cloud.loadFavorites(couple!.id);
      }
    } else {
      final raw = _couples[currentUser!.coupleId!];
      if (raw == null) return;
      couple = CoupleModel.fromMap(Map<String, dynamic>.from(raw));
      final names = {...couple!.memberNames};
      final users = _users;
      for (final memberId in couple!.memberIds) {
        final member = users[memberId];
        if (member is Map) {
          names[memberId] = (member['name'] ?? 'Partner').toString();
        }
      }
      if (names.length != couple!.memberNames.length) {
        couple = couple!.copyWith(memberNames: names);
        final couples = _couples;
        couples[couple!.id] = couple!.toMap();
        await db.write(_couplesKey, couples);
      }
      final bucketRaw = db.read('bucket_${couple!.id}', <dynamic>[]) as List;
      bucketItems = bucketRaw
          .map((e) => BucketListItem.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      favorites = Set<String>.from(
        db.read('favorites_${couple!.id}', <dynamic>[]) as List,
      );
    }
    _generateSuggestions();
    _startRealtimeSync();
  }

  void _startRealtimeSync() {
    _coupleSubscription?.cancel();
    _bucketSubscription?.cancel();
    if (!cloud.enabled || couple == null) return;
    final coupleId = couple!.id;
    _coupleSubscription = cloud.watchCouple(coupleId).listen((updated) {
      couple = updated;
      _generateSuggestions();
      notifyListeners();
    });
    _bucketSubscription = cloud.watchBucket(coupleId).listen((items) {
      bucketItems = items;
      notifyListeners();
    });
  }

  Future<void> refreshFromCloud() async {
    if (!cloud.enabled || currentUser?.coupleId == null) return;
    syncing = true;
    notifyListeners();
    try {
      await _loadCouple();
    } finally {
      syncing = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------
  // Preferences + suggestions
  // ---------------------------------------------------------------------

  Future<void> savePreferences({
    required Set<String> foods,
    required Set<String> activities,
    required Set<String> locations,
    required double budget,
    required String budgetCurrency,
  }) async {
    if (couple == null) return;
    couple = couple!.copyWith(
      foods: foods,
      activities: activities,
      locations: locations,
      budget: budget,
      budgetCurrency: budgetCurrency,
    );
    _generateSuggestions();
    notifyListeners();

    final couples = _couples;
    couples[couple!.id] = couple!.toMap();
    await db.write(_couplesKey, couples);

    if (cloud.enabled) {
      syncing = true;
      notifyListeners();
      unawaited(
        cloud.saveCouple(couple!).whenComplete(() {
          syncing = false;
          notifyListeners();
        }),
      );
    }
  }

  CatalogQuery buildQuery({String? moodOverride}) => CatalogQuery(
    locations: couple?.locations ?? const <String>{},
    foods: couple?.foods ?? const <String>{},
    activities: couple?.activities ?? const <String>{},
    budget: couple?.budget ?? 0,
    currency: couple?.budgetCurrency ?? 'PHP',
    mood: moodOverride ?? mood,
  );

  List<DateSuggestion> browsePlaces({
    required int page,
    int size = PlaceCatalogService.pageSize,
    String? moodOverride,
    Set<String> excludeIds = const {},
  }) {
    return catalog.page(
      buildQuery(moodOverride: moodOverride),
      page: page,
      size: size,
      excludedIds: excludeIds,
    );
  }

  Future<void> generateSuggestions(String selectedMood) async {
    mood = selectedMood;
    generating = true;
    notifyListeners();
    _generateSuggestions();
    generating = false;
    notifyListeners();
  }

  Future<void> generateMoodIdeas(String selectedMood) =>
      generateSuggestions(selectedMood);

  void _generateSuggestions() {
    if (couple == null) {
      currentSuggestions = [];
      return;
    }
    currentSuggestions = catalog.quickPicks(buildQuery());
    recentlyShownIds = {
      ...recentlyShownIds,
      ...currentSuggestions.map((s) => s.id),
    };
  }

  Future<void> refreshSuggestions() async {
    generating = true;
    notifyListeners();
    if (couple != null) {
      final next = catalog.page(
        buildQuery(),
        page: (recentlyShownIds.length ~/ PlaceCatalogService.pageSize) + 1,
        size: 8,
        excludedIds: recentlyShownIds,
      );
      currentSuggestions = next.isNotEmpty
          ? next
          : catalog.quickPicks(buildQuery());
      recentlyShownIds = {
        ...recentlyShownIds,
        ...currentSuggestions.map((s) => s.id),
      };
    }
    generating = false;
    notifyListeners();
  }

  bool isSavedSuggestion(DateSuggestion suggestion) {
    return bucketItems.any(
      (item) =>
          item.name.trim().toLowerCase() ==
              suggestion.title.trim().toLowerCase() ||
          (suggestion.placeId.isNotEmpty &&
              item.id.endsWith(suggestion.placeId)),
    );
  }

  // ---------------------------------------------------------------------
  // Bucket list
  // ---------------------------------------------------------------------

  Future<bool> addToBucket(DateSuggestion suggestion) async {
    if (couple == null || currentUser == null) return false;
    if (isSavedSuggestion(suggestion)) return false;
    final item = BucketListItem(
      id: suggestion.placeId.isNotEmpty
          ? 'bucket-${suggestion.placeId}'
          : _id('bucket'),
      name: suggestion.title,
      category: suggestion.category,
      price: suggestion.price,
      subtitle: suggestion.subtitle,
      addedBy: currentUser!.id,
      createdAt: DateTime.now(),
      status: BucketListStatus.pending,
      imageUrl: suggestion.imageUrl,
      verified: suggestion.verified,
    );
    bucketItems = [item, ...bucketItems];
    notifyListeners();
    unawaited(_saveBucket());
    return true;
  }

  Future<void> addManualBucket(
    String name,
    String category,
    String price,
  ) async {
    if (couple == null || currentUser == null || name.trim().isEmpty) return;
    final item = BucketListItem(
      id: _id('bucket'),
      name: name.trim(),
      category: category.trim().isEmpty ? 'Other' : category.trim(),
      price: price.trim().isEmpty ? 'Not set' : price.trim(),
      subtitle: 'Added manually',
      addedBy: currentUser!.id,
      createdAt: DateTime.now(),
      status: BucketListStatus.pending,
    );
    bucketItems = [item, ...bucketItems];
    notifyListeners();
    unawaited(_saveBucket());
  }

  Future<void> toggleBucket(String id) async {
    final index = bucketItems.indexWhere((i) => i.id == id);
    if (index < 0) return;
    final old = bucketItems[index];
    final done = old.status == BucketListStatus.pending;
    bucketItems[index] = old.copyWith(
      status: done ? BucketListStatus.done : BucketListStatus.pending,
      completedAt: done ? DateTime.now() : null,
      clearCompletedAt: !done,
    );
    notifyListeners();
    unawaited(_saveBucket());
  }

  Future<void> reviewBucket(String id, double rating, String note) async {
    final index = bucketItems.indexWhere((i) => i.id == id);
    if (index < 0) return;
    bucketItems[index] = bucketItems[index].copyWith(
      status: BucketListStatus.done,
      rating: rating,
      note: note.trim().isEmpty ? null : note.trim(),
      completedAt: DateTime.now(),
    );
    notifyListeners();
    unawaited(_saveBucket());
  }

  Future<void> deleteBucket(String id) async {
    bucketItems.removeWhere((i) => i.id == id);
    notifyListeners();
    if (cloud.enabled && couple != null) {
      unawaited(cloud.deleteBucketItem(couple!.id, id));
    } else {
      unawaited(_saveBucket());
    }
  }

  Future<void> _saveBucket() async {
    if (couple == null) return;
    if (cloud.enabled) {
      await cloud.saveBucket(couple!.id, bucketItems);
    } else {
      await db.write(
        'bucket_${couple!.id}',
        bucketItems.map((i) => i.toMap()).toList(),
      );
    }
  }

  Future<void> toggleFavorite(String suggestionId) async {
    if (couple == null) return;
    if (favorites.contains(suggestionId)) {
      favorites.remove(suggestionId);
    } else {
      favorites.add(suggestionId);
    }
    notifyListeners();
    if (cloud.enabled) {
      unawaited(cloud.saveFavorites(couple!.id, favorites));
    } else {
      unawaited(db.write('favorites_${couple!.id}', favorites.toList()));
    }
  }

  bool isFavorite(String id) => favorites.contains(id);

  Future<void> updateName(String name) async {
    if (currentUser == null || name.trim().isEmpty) return;
    currentUser = currentUser!.copyWith(name: name.trim());
    notifyListeners();
    if (cloud.enabled) {
      unawaited(cloud.saveUser(currentUser!));
    } else {
      final users = _users;
      users[currentUser!.id] = currentUser!.toMap();
      unawaited(db.write(_usersKey, users));
    }
    if (couple != null && couple!.memberIds.contains(currentUser!.id)) {
      final names = {
        ...couple!.memberNames,
        currentUser!.id: currentUser!.name,
      };
      couple = couple!.copyWith(memberNames: names);
      notifyListeners();
      if (cloud.enabled) {
        unawaited(cloud.saveCouple(couple!));
      } else {
        final couples = _couples;
        couples[couple!.id] = couple!.toMap();
        unawaited(db.write(_couplesKey, couples));
      }
    }
  }

  @override
  void dispose() {
    _coupleSubscription?.cancel();
    _bucketSubscription?.cancel();
    super.dispose();
  }

  void _setBusy(bool value) {
    busy = value;
    notifyListeners();
  }

  String _friendlyError(Object error) {
    final raw = error.toString();
    for (final known in const [
      'No couple was found with that code.',
      'That couple already has two members.',
    ]) {
      if (raw.contains(known)) return known;
    }

    final message = raw.toLowerCase();
    if (message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('user_already_exists')) {
      return 'That email is already registered.';
    }
    if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials') ||
        message.contains('invalid email or password')) {
      return 'The email or password is incorrect.';
    }
    if (message.contains('weak-password') ||
        message.contains('weak_password') ||
        message.contains('should be at least')) {
      return 'Use a stronger password with at least 6 characters.';
    }
    if (message.contains('rate limit') ||
        message.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (message.contains('socketexception') ||
        message.contains('network') ||
        message.contains('failed host lookup')) {
      return 'Network connection failed. Please try again.';
    }
    return 'Something went wrong. Please check your details and try again.';
  }
}
