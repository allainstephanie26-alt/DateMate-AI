import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/app_models.dart';

/// Optional cloud backend.
///
/// The app remains runnable with Hive when Firebase environment values are not
/// supplied. When the values are supplied, authentication and user/couple
/// data are stored in Firebase Authentication + Cloud Firestore and changes
/// are synchronized through the repository methods below.
class CloudSyncService {
  bool enabled = false;

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );

  bool get configured =>
      _apiKey.isNotEmpty &&
      _appId.isNotEmpty &&
      _messagingSenderId.isNotEmpty &&
      _projectId.isNotEmpty;

  Future<void> init() async {
    if (!configured) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: _apiKey,
            appId: _appId,
            messagingSenderId: _messagingSenderId,
            projectId: _projectId,
            authDomain: _authDomain.isEmpty ? null : _authDomain,
            storageBucket: _storageBucket.isEmpty ? null : _storageBucket,
          ),
        );
      }
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      enabled = true;
    } catch (_) {
      enabled = false;
    }
  }

  FirebaseAuth get auth => _auth!;
  FirebaseFirestore get firestore => _firestore!;

  Future<UserCredential> signUp(String email, String password) =>
      auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signIn(String email, String password) =>
      auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => auth.signOut();

  Future<void> resetPassword(String email) =>
      auth.sendPasswordResetEmail(email: email);

  Future<Map<String, UserModel>> loadUsers(List<String> ids) async {
    final result = <String, UserModel>{};
    for (final id in ids) {
      final user = await loadUser(id);
      if (user != null) result[id] = user;
    }
    return result;
  }

  Future<void> saveUser(UserModel user) async {
    await firestore
        .collection('users')
        .doc(user.id)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> loadUser(String uid) async {
    final snap = await firestore.collection('users').doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserModel.fromMap(Map<String, dynamic>.from(snap.data()!));
  }

  Stream<CoupleModel> watchCouple(String id) => firestore
      .collection('couples')
      .doc(id)
      .snapshots()
      .where((s) => s.exists)
      .map((s) => CoupleModel.fromMap(Map<String, dynamic>.from(s.data()!)));

  Stream<List<BucketListItem>> watchBucket(String coupleId) => firestore
      .collection('couples')
      .doc(coupleId)
      .collection('bucketItems')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map(
              (d) =>
                  BucketListItem.fromMap(Map<String, dynamic>.from(d.data())),
            )
            .toList(),
      );

  Future<void> saveCouple(CoupleModel couple) async {
    await firestore
        .collection('couples')
        .doc(couple.id)
        .set(couple.toMap(), SetOptions(merge: true));
  }

  Future<CoupleModel?> loadCouple(String id) async {
    final snap = await firestore.collection('couples').doc(id).get();
    if (!snap.exists || snap.data() == null) return null;
    return CoupleModel.fromMap(Map<String, dynamic>.from(snap.data()!));
  }

  Future<CoupleModel?> findCoupleByCode(String code) async {
    final snap = await firestore
        .collection('couples')
        .where('code', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return CoupleModel.fromMap(
      Map<String, dynamic>.from(snap.docs.first.data()),
    );
  }

  Future<List<BucketListItem>> loadBucket(String coupleId) async {
    final snap = await firestore
        .collection('couples')
        .doc(coupleId)
        .collection('bucketItems')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => BucketListItem.fromMap(Map<String, dynamic>.from(d.data())))
        .toList();
  }

  Future<void> saveBucket(String coupleId, List<BucketListItem> items) async {
    final batch = firestore.batch();
    final collection = firestore
        .collection('couples')
        .doc(coupleId)
        .collection('bucketItems');
    for (final item in items) {
      batch.set(collection.doc(item.id), item.toMap());
    }
    await batch.commit();
  }

  Future<void> deleteBucketItem(String coupleId, String id) => firestore
      .collection('couples')
      .doc(coupleId)
      .collection('bucketItems')
      .doc(id)
      .delete();

  Future<Set<String>> loadFavorites(String coupleId) async {
    final snap = await firestore
        .collection('couples')
        .doc(coupleId)
        .collection('meta')
        .doc('favorites')
        .get();
    if (!snap.exists) return {};
    return Set<String>.from((snap.data()?['ids'] as List?) ?? const []);
  }

  Future<void> saveFavorites(String coupleId, Set<String> ids) => firestore
      .collection('couples')
      .doc(coupleId)
      .collection('meta')
      .doc('favorites')
      .set({'ids': ids.toList()});
}
