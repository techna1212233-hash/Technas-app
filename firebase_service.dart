import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> ensureUser() async {
    User? user = _auth.currentUser;
    if (user == null) {
      final cred = await _auth.signInAnonymously();
      user = cred.user;
    }

    if (user != null) {
      final doc = _db.collection('users').doc(user.uid);
      final snap = await doc.get();

      if (!snap.exists) {
        final code = 'TECHNA${DateTime.now().millisecondsSinceEpoch % 9999}';
        await doc.set({
          'coins': 0,
          'referralCode': code,
          'referredBy': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
    return user;
  }

  Stream<DocumentSnapshot> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<void> addCoins(String uid, int amount) async {
    final ref = _db.collection('users').doc(uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final curr = snap['coins'] ?? 0;
      tx.update(ref, {'coins': curr + amount});
    });
  }

  Future<bool> tryUseReferral(String uid, String code) async {
    final result = await _db
        .collection('users')
        .where('referralCode', isEqualTo: code)
        .limit(1).get();

    if (result.docs.isEmpty) return false;

    final referDoc = result.docs.first;
    final refUid = referDoc.id;

    if (refUid == uid) return false;

    final myDoc = _db.collection('users').doc(uid);
    final snap = await myDoc.get();

    if (snap['referredBy'] != null) return false;

    final batch = _db.batch();
    batch.update(referDoc.reference, {'coins': referDoc['coins'] + 10});
    batch.update(myDoc, {'coins': snap['coins'] + 10, 'referredBy': refUid});
    await batch.commit();

    return true;
  }

  Future<void> submitWithdraw(String uid, int amount, String method) async {
    await _db.collection('withdraws').add({
      'userId': uid,
      'amount': amount,
      'method': method,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createListing(String uid, int fee, String title) async {
    final userRef = _db.collection('users').doc(uid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final coins = snap['coins'] ?? 0;
      if (coins < fee) throw Exception("Not enough coins");

      tx.update(userRef, {'coins': coins - fee});
      tx.set(_db.collection('listings').doc(), {
        'userId': uid,
        'title': title,
        'fee': fee,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
