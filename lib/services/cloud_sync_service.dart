import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_models.dart';

/// A backend-neutral stand-in for Supabase's `User`/`Session` auth result.
///
/// `AppController` used to reach directly into Firebase's `UserCredential`
/// (`.user!.uid`, `.user!.emailVerified`, `.user!.sendEmailVerification()`).
/// Supabase's `User` shapes that information differently (`.id`,
/// `.emailConfirmedAt`, no callable verification method), so this class
/// normalizes both into one small, stable shape. `AppController` only ever
/// touches `CloudAuthResult`, never the Supabase SDK types directly.
class CloudAuthResult {
  final String uid;
  final String email;
  final bool emailVerified;

  const CloudAuthResult({
    required this.uid,
    required this.email,
    required this.emailVerified,
  });
}

/// Handles authentication and cloud data sync through Supabase
/// (Postgres + Auth + Realtime) instead of Firebase.
///
/// Every public method here keeps the exact name it had in the Firebase
/// version (`saveCouple`, `loadBucket`, `watchCouple`, `signIn`, ...) so
/// `AppController` — and everything above it — did not need to change.
/// Cloud sync stays fully optional: if `SUPABASE_URL` /
/// `SUPABASE_PUBLISHABLE_KEY` are not supplied at build time, [enabled]
/// stays false and the app runs entirely on the local Hive database,
/// exactly like the Firebase version did when unconfigured.
class CloudSyncService {
  bool enabled = false;

  static const _url = String.fromEnvironment(
    'https://mmsvqcmqmfjfndchivpa.supabase.co',
  );
  // Supabase's dashboard now calls this the "publishable key" (previously
  // "anon key") — same value, same purpose: safe to ship in a client,
  // protected entirely by the RLS policies in the SQL migration.
  static const _publishableKey = String.fromEnvironment(
    'sb_publishable_2lzJ9PeGlnC5ryj3GR-SWAQ_glWyz5Qy',
  );

  bool get configured => _url.isNotEmpty && _publishableKey.isNotEmpty;

  SupabaseClient? _client;
  SupabaseClient get client => _client!;
  GoTrueClient get _auth => client.auth;

  Future<void> init() async {
    if (!configured) return;
    try {
      await Supabase.initialize(url: _url, anonKey: _publishableKey);
      _client = Supabase.instance.client;
      enabled = true;
    } catch (_) {
      enabled = false;
    }
  }

  /// The Supabase Edge Function name used for the Gemini-powered chat
  /// upgrade (invoked from `AiChatService._tryCloudReply`). Kept here so
  /// both the function name and the client it's called through live in
  /// one place.
  static const aiChatFunction = 'datemate-chat';

  CloudAuthResult? _fromUser(User? user) {
    if (user == null) return null;
    return CloudAuthResult(
      uid: user.id,
      email: user.email ?? '',
      emailVerified: user.emailConfirmedAt != null,
    );
  }

  CloudAuthResult? get currentAuthUser => _fromUser(_auth.currentUser);

  /// [name] is passed as Supabase Auth user metadata (`raw_user_meta_data`),
  /// not written to `profiles` directly — there is no authenticated session
  /// yet if the project requires email confirmation, so a client-side write
  /// to `profiles` would be rejected by row-level security. Instead, the
  /// `handle_new_user` trigger in the SQL migration reads this metadata and
  /// creates the profile row itself, with elevated privileges, the instant
  /// the auth user is created. See `supabase/migrations/0001_init.sql`.
  Future<CloudAuthResult> signUp(
    String email,
    String password, {
    required String name,
  }) async {
    final res = await _auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    final result = _fromUser(res.user);
    if (result == null) throw Exception('Sign up did not return a user.');
    return result;
  }

  Future<CloudAuthResult> signIn(String email, String password) async {
    final res = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    final result = _fromUser(res.user);
    if (result == null) throw Exception('Sign in did not return a user.');
    return result;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> resetPassword(String email) =>
      _auth.resetPasswordForEmail(email);

  /// Resends the sign-up confirmation email. Supabase has no direct
  /// equivalent of Firebase's `user.sendEmailVerification()` — confirmation
  /// is resent through `auth.resend` instead.
  Future<void> resendVerificationEmail(String email) =>
      _auth.resend(type: OtpType.signup, email: email);

  /// Firebase's `User.reload()` re-fetches the user's verification flag in
  /// place. Supabase re-reads it by refreshing the session; if that fails
  /// (e.g. no network), this falls back to whatever the client already has
  /// cached rather than throwing.
  Future<CloudAuthResult?> refreshCurrentUser() async {
    try {
      final res = await _auth.refreshSession();
      return _fromUser(res.user);
    } catch (_) {
      return _fromUser(_auth.currentUser);
    }
  }

  /// Used to authenticate calls to the Gemini Edge Function manually if
  /// ever needed; `client.functions.invoke` already attaches this
  /// automatically, so most callers do not need it.
  Future<String?> getIdToken() async => _auth.currentSession?.accessToken;

  // ---------------------------------------------------------------------
  // profiles (one row per Supabase auth user)
  // ---------------------------------------------------------------------

  Future<void> saveUser(UserModel user) async {
    await client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'couple_id': user.coupleId,
    });
  }

  Future<UserModel?> loadUser(String uid) async {
    final row = await client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (row == null) return null;
    return _userFromRow(row);
  }

  Future<Map<String, UserModel>> loadUsers(List<String> ids) async {
    if (ids.isEmpty) return {};
    final rows = await client.from('profiles').select().inFilter('id', ids);
    return {for (final r in rows) r['id'] as String: _userFromRow(r)};
  }

  UserModel _userFromRow(Map<String, dynamic> r) => UserModel(
    id: r['id'] as String,
    email: r['email'] as String? ?? '',
    name: r['name'] as String? ?? '',
    passwordHash: '',
    coupleId: r['couple_id'] as String?,
    createdAt:
        DateTime.tryParse(r['created_at']?.toString() ?? '') ?? DateTime.now(),
  );

  // ---------------------------------------------------------------------
  // couples
  //
  // Membership is derived from `profiles.couple_id` rather than stored a
  // second time on the couple row, so there is one source of truth for
  // "who is in this couple" and it can never drift out of sync.
  // ---------------------------------------------------------------------

  Future<void> saveCouple(CoupleModel couple) async {
    await client.from('couples').upsert({
      'id': couple.id,
      'code': couple.code,
      'foods': couple.foods.toList(),
      'activities': couple.activities.toList(),
      'locations': couple.locations.toList(),
      'budget': couple.budget,
      'budget_currency': couple.budgetCurrency,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<CoupleModel?> loadCouple(String id) async {
    final row = await client
        .from('couples')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return _hydrateMembers(_coupleFromRow(row));
  }

  Future<CoupleModel?> findCoupleByCode(String code) async {
    final row = await client
        .from('couples')
        .select()
        .eq('code', code.trim().toUpperCase())
        .maybeSingle();
    if (row == null) return null;
    return _hydrateMembers(_coupleFromRow(row));
  }

  /// Attaches the current user to the couple with [code] and returns it.
  ///
  /// This calls the `join_couple` Postgres function instead of a plain
  /// table update: the ordinary "only members can update a couple" RLS
  /// policy correctly refuses a direct update here, because the caller
  /// isn't a member yet — that's exactly the situation this function
  /// exists to handle, with the two-member limit enforced server-side
  /// inside it. Throws with a human-readable message on failure (no
  /// matching code, couple already full).
  Future<CoupleModel> joinCoupleByCode(String code) async {
    final row = await client.rpc(
      'join_couple',
      params: {'target_code': code.trim().toUpperCase()},
    );
    if (row == null) {
      throw Exception('No couple was found with that code.');
    }
    final map = Map<String, dynamic>.from(row as Map);
    return _hydrateMembers(_coupleFromRow(map));
  }

  CoupleModel _coupleFromRow(Map<String, dynamic> r) => CoupleModel(
    id: r['id'] as String,
    code: r['code'] as String,
    memberIds: const [],
    memberNames: const {},
    foods: Set<String>.from(r['foods'] as List? ?? const []),
    activities: Set<String>.from(r['activities'] as List? ?? const []),
    locations: Set<String>.from(r['locations'] as List? ?? const []),
    budget: (r['budget'] as num?)?.toDouble() ?? 0,
    budgetCurrency: r['budget_currency']?.toString() ?? 'PHP',
    updatedAt:
        DateTime.tryParse(r['updated_at']?.toString() ?? '') ?? DateTime.now(),
  );

  Future<CoupleModel> _hydrateMembers(CoupleModel couple) async {
    final rows = await client
        .from('profiles')
        .select('id, name')
        .eq('couple_id', couple.id);
    final ids = <String>[];
    final names = <String, String>{};
    for (final r in rows) {
      final id = r['id'] as String;
      ids.add(id);
      names[id] = (r['name'] as String?)?.trim().isNotEmpty == true
          ? r['name'] as String
          : 'Partner';
    }
    return couple.copyWith(memberIds: ids, memberNames: names);
  }

  // ---------------------------------------------------------------------
  // bucket list
  // ---------------------------------------------------------------------

  Future<List<BucketListItem>> loadBucket(String coupleId) async {
    final rows = await client
        .from('bucket_items')
        .select()
        .eq('couple_id', coupleId)
        .order('created_at', ascending: false);
    return rows.map<BucketListItem>(_bucketFromRow).toList();
  }

  /// Live updates so both partners see additions, completions, and reviews
  /// as they happen, the same way Firestore's `snapshots()` did.
  Stream<List<BucketListItem>> watchBucket(String coupleId) {
    return client
        .from('bucket_items')
        .stream(primaryKey: ['id'])
        .eq('couple_id', coupleId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map<BucketListItem>(_bucketFromRow).toList());
  }

  Future<void> saveBucket(String coupleId, List<BucketListItem> items) async {
    if (items.isEmpty) return;
    await client.from('bucket_items').upsert([
      for (final item in items)
        {
          'id': item.id,
          'couple_id': coupleId,
          'name': item.name,
          'category': item.category,
          'price': item.price,
          'subtitle': item.subtitle,
          'added_by': item.addedBy,
          'status': item.status.name,
          'rating': item.rating,
          'note': item.note,
          'completed_at': item.completedAt?.toIso8601String(),
          'image_url': item.imageUrl,
        },
    ]);
  }

  Future<void> deleteBucketItem(String coupleId, String id) =>
      client.from('bucket_items').delete().eq('id', id);

  BucketListItem _bucketFromRow(Map<String, dynamic> r) => BucketListItem(
    id: r['id'] as String,
    name: r['name'] as String? ?? 'Untitled date',
    category: r['category'] as String? ?? 'Other',
    price: r['price'] as String? ?? '',
    subtitle: r['subtitle'] as String? ?? '',
    addedBy: r['added_by'] as String? ?? '',
    createdAt:
        DateTime.tryParse(r['created_at']?.toString() ?? '') ?? DateTime.now(),
    status: BucketListStatus.values.firstWhere(
      (s) => s.name == r['status'],
      orElse: () => BucketListStatus.pending,
    ),
    rating: (r['rating'] as num?)?.toDouble(),
    note: r['note'] as String?,
    completedAt: r['completed_at'] == null
        ? null
        : DateTime.tryParse(r['completed_at'].toString()),
    imageUrl: r['image_url'] as String? ?? '',
  );

  // ---------------------------------------------------------------------
  // favorites — one row per (couple, suggestion) instead of an id array,
  // so two partners tapping the heart at the same moment never overwrite
  // each other the way a single "favorites: [...]" array write could.
  // ---------------------------------------------------------------------

  Future<Set<String>> loadFavorites(String coupleId) async {
    final rows = await client
        .from('favorites')
        .select('suggestion_id')
        .eq('couple_id', coupleId);
    return rows.map<String>((r) => r['suggestion_id'] as String).toSet();
  }

  Future<void> saveFavorites(String coupleId, Set<String> ids) async {
    await client.from('favorites').delete().eq('couple_id', coupleId);
    if (ids.isEmpty) return;
    await client.from('favorites').upsert([
      for (final id in ids) {'couple_id': coupleId, 'suggestion_id': id},
    ]);
  }

  // ---------------------------------------------------------------------
  // Realtime couple sync — lets one partner's saved preferences appear on
  // the other partner's screen without a manual refresh.
  // ---------------------------------------------------------------------

  Stream<CoupleModel> watchCouple(String id) {
    return client
        .from('couples')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .asyncMap((rows) async {
          if (rows.isEmpty) return null;
          return _hydrateMembers(_coupleFromRow(rows.first));
        })
        .where((couple) => couple != null)
        .map((couple) => couple!);
  }
}