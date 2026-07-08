import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../services/firestore_service.dart';
import '../services/reward_service.dart';

class ReferralService {
  final FirestoreService firestoreService;
  final RewardService rewardService;

  static const int referralBonusReferrer = 25;
  static const int referralBonusReferee = 15;

  ReferralService({
    required this.firestoreService,
    required this.rewardService,
  });

  String generateReferralCode(String uid) {
    final suffix = uid.length >= 4 ? uid.substring(0, 4).toUpperCase() : uid.toUpperCase();
    final random = Random();
    final digits = random.nextInt(9000) + 1000;
    return 'FI$suffix$digits';
  }

  Future<void> ensureReferralCode(String uid) async {
    try {
      final doc = await firestoreService.document('users', uid);
      if (!doc.exists || doc.data() == null) return;

      final data = doc.data() as Map<String, dynamic>;
      final existing = data['referralCode'] as String? ?? '';

      if (existing.isEmpty) {
        final code = generateReferralCode(uid);
        await firestoreService.setData('users', uid, {
          'referralCode': code,
        }, merge: true);
      }
    } catch (e) {
      // silent
    }
  }

  Future<bool> validateReferralCode(String code) async {
    try {
      final snapshot = await firestoreService
          .collection('users')
          .where('referralCode', isEqualTo: code)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String?> applyReferral(String newUserId, String referralCode) async {
    for (int attempt = 1; attempt <= 5; attempt++) {
      try {
        debugPrint('ReferralService: Applying referral code "$referralCode" for user $newUserId (attempt $attempt)');

        // Check if user already used a referral code
        final newUserDoc = await firestoreService.document('users', newUserId);
        if (newUserDoc.exists && newUserDoc.data() != null) {
          final existingData = newUserDoc.data() as Map<String, dynamic>;
          final existingReferredBy = existingData['referredBy'] as String? ?? '';
          if (existingReferredBy.isNotEmpty) {
            debugPrint('ReferralService: User already used a referral code');
            return null;
          }
        }

        final snapshot = await firestoreService
            .collection('users')
            .where('referralCode', isEqualTo: referralCode)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) {
          debugPrint('ReferralService: No user found with referral code "$referralCode"');
          return null;
        }

        final referrerDoc = snapshot.docs.first;
        final referrerUid = referrerDoc.id;

        if (referrerUid == newUserId) {
          debugPrint('ReferralService: User cannot refer themselves');
          return null;
        }

        // Ensure new user doc exists before writing
        if (!newUserDoc.exists || newUserDoc.data() == null) {
          debugPrint('ReferralService: New user doc does not exist yet, waiting...');
          await Future.delayed(Duration(seconds: attempt));
          continue;
        }

        // Write referredBy to new user
        await firestoreService.setData('users', newUserId, {
          'referredBy': referralCode,
        }, merge: true);
        debugPrint('ReferralService: wrote referredBy to new user doc');

        // Read referrer doc FRESH to get current count
        final freshReferrerDoc = await firestoreService.document('users', referrerUid);
        final freshReferrerData = freshReferrerDoc.data() as Map<String, dynamic>?;
        final currentCount = (freshReferrerData?['referralCount'] as num?)?.toInt() ?? 0;

        // Increment referrer's referralCount
        await firestoreService.setData('users', referrerUid, {
          'referralCount': currentCount + 1,
        }, merge: true);
        debugPrint('ReferralService: referralCount updated for referrer $referrerUid: $currentCount -> ${currentCount + 1}');

        // Award bonus points
        try {
          await _awardReferralBonus(referrerUid, referralBonusReferrer, 'Referral Bonus - Invited a friend');
          await _awardReferralBonus(newUserId, referralBonusReferee, 'Welcome Bonus - Referred by friend');
          debugPrint('ReferralService: Bonus points awarded');
        } catch (e) {
          debugPrint('ReferralService: Bonus award failed: $e');
        }

        return referrerUid;
      } catch (e) {
        debugPrint('ReferralService: applyReferral attempt $attempt failed: $e');
        if (attempt < 5) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }
    debugPrint('ReferralService: All 5 attempts failed for referral code "$referralCode"');
    return null;
  }

  Future<void> _awardReferralBonus(String uid, int points, String reason) async {
    try {
      final doc = await firestoreService.document('users', uid);
      if (!doc.exists || doc.data() == null) return;

      final data = doc.data() as Map<String, dynamic>;
      final currentPoints = (data['rewardPoints'] as num?)?.toInt() ?? 0;
      final newPoints = currentPoints + points;
      final newBadge = rewardService.calculateBadge(newPoints);

      await firestoreService.setData('users', uid, {
        'rewardPoints': newPoints,
        'badge': newBadge,
      }, merge: true);

      await firestoreService.addData('rewards', {
        'uid': uid,
        'points': points,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // silent
    }
  }

  Future<List<Map<String, dynamic>>> getMyReferrals(String uid) async {
    try {
      final doc = await firestoreService.document('users', uid);
      if (!doc.exists || doc.data() == null) return [];

      final data = doc.data() as Map<String, dynamic>;
      final myCode = data['referralCode'] as String? ?? '';
      if (myCode.isEmpty) return [];

      final snapshot = await firestoreService
          .collection('users')
          .where('referredBy', isEqualTo: myCode)
          .get();

      return snapshot.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return {
          'name': (d['name'] as String?) ?? 'User',
          'email': (d['email'] as String?) ?? '',
          'joinedAt': d['createdAt'],
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
