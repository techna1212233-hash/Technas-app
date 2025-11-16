import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppState extends ChangeNotifier {
  final FirebaseService _fs = FirebaseService();

  User? user;
  DocumentSnapshot? userDoc;

  int coins = 0;
  String referralCode = '';

  bool autoMine = false;

  AppState() {
    init();
  }

  Future<void> init() async {
    user = await _fs.ensureUser();
    if (user != null) {
      _fs.streamUser(user!.uid).listen((snap) {
        userDoc = snap;
        coins = snap['coins'];
        referralCode = snap['referralCode'];
        notifyListeners();
      });
    }
  }

  Future<void> startMining() async {
    if (user == null) return;
    await _fs.addCoins(user!.uid, 1);
  }

  void toggleAutoMine() {
    autoMine = !autoMine;
    if (autoMine) {
      Future.doWhile(() async {
        if (!autoMine || user == null) return false;
        await Future.delayed(Duration(seconds: 5));
        await _fs.addCoins(user!.uid, 1);
        return true;
      });
    }
    notifyListeners();
  }

  Future<bool> useReferralCode(String code) async {
    if (user == null) return false;
    return await _fs.tryUseReferral(user!.uid, code);
  }

  Future<void> watchVideoEarn(int amount) async {
    if (user == null) return;
    await _fs.addCoins(user!.uid, amount);
  }

  Future<void> withdrawRequest(int amount, String method) async {
    if (user == null) return;
    await _fs.submitWithdraw(user!.uid, amount, method);
  }

  Future<bool> submitListing(int fee, String title) async {
    if (user == null) return false;
    if (coins < fee) return false;
    await _fs.createListing(user!.uid, fee, title);
    return true;
  }
}
