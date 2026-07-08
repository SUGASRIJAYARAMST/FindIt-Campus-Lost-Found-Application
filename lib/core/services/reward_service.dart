import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/user_model.dart';
import '../services/firestore_service.dart';

class RewardService {
  final FirestoreService firestoreService;

  RewardService({required this.firestoreService});

  static const int pointsPerReturn = 10;
  static const int pointsPerClaim = 5;
  static const int pointsPerLostReport = 10;
  static const int pointsPerFoundReport = 15;
  static const int pointsPerCheckIn = 5;

  static const Map<String, int> badgeThresholds = {
    'Good Helper': 50,
    'Beginner Finder': 100,
    'Trusted Finder': 250,
    'Campus Hero': 500,
    'Lost & Found Champion': 1000,
  };

  static const List<Map<String, dynamic>> allBadges = [
    {'name': 'Good Helper', 'min': 0, 'max': 49, 'icon': '👍', 'color': 0xFF66BB6A},
    {'name': 'Beginner Finder', 'min': 50, 'max': 99, 'icon': '🌱', 'color': 0xFF90A4AE},
    {'name': 'Trusted Finder', 'min': 100, 'max': 249, 'icon': '🤝', 'color': 0xFF4FC3F7},
    {'name': 'Campus Hero', 'min': 250, 'max': 499, 'icon': '🦸', 'color': 0xFFFFD54F},
    {'name': 'Lost & Found Champion', 'min': 500, 'max': 99999, 'icon': '🏆', 'color': 0xFFFF8A65},
  ];

  Future<void> awardPointsForReturn(String uid) async {
    try {
      final doc = await firestoreService.document('users', uid);
      if (!doc.exists || doc.data() == null) return;

      final data = doc.data() as Map<String, dynamic>;
      final currentPoints = (data['rewardPoints'] as num?)?.toInt() ?? 0;
      final newPoints = currentPoints + pointsPerReturn;
      final newBadge = calculateBadge(newPoints);

      await firestoreService.setData('users', uid, {
        'rewardPoints': newPoints,
        'badge': newBadge,
      }, merge: true);

      await _addRewardHistory(uid, pointsPerReturn, 'Item Returned Successfully');
      await _notifyUser(uid, 'Reward Earned!', 'You earned $pointsPerReturn points for returning an item.', 'reward');
    } catch (e) {
      throw Exception('Failed to award points: $e');
    }
  }

  Future<void> awardPointsForReport(String uid, String type) async {
    try {
      final doc = await firestoreService.document('users', uid);
      if (!doc.exists || doc.data() == null) return;

      final data = doc.data() as Map<String, dynamic>;
      final currentPoints = (data['rewardPoints'] as num?)?.toInt() ?? 0;
      final points = type == 'lost' ? pointsPerLostReport : pointsPerFoundReport;
      final newPoints = currentPoints + points;
      final newBadge = calculateBadge(newPoints);

      await firestoreService.setData('users', uid, {
        'rewardPoints': newPoints,
        'badge': newBadge,
      }, merge: true);

      final reason = type == 'lost' ? 'Reported Lost Item' : 'Reported Found Item';
      await _addRewardHistory(uid, points, reason);
      await _notifyUser(uid, 'Reward Earned!', 'You earned $points points for reporting a $type item.', 'reward');
    } catch (e) {
      throw Exception('Failed to award points: $e');
    }
  }

  Future<void> awardPointsForClaim(String uid) async {
    try {
      final doc = await firestoreService.document('users', uid);
      if (!doc.exists || doc.data() == null) return;

      final data = doc.data() as Map<String, dynamic>;
      final currentPoints = (data['rewardPoints'] as num?)?.toInt() ?? 0;
      final newPoints = currentPoints + 5;
      final newBadge = calculateBadge(newPoints);

      await firestoreService.setData('users', uid, {
        'rewardPoints': newPoints,
        'badge': newBadge,
      }, merge: true);

      await _addRewardHistory(uid, 5, 'Item Claimed');
    } catch (e) {
      throw Exception('Failed to award points: $e');
    }
  }

  String calculateBadge(int points) {
    String badge = 'Good Helper';
    for (final entry in badgeThresholds.entries) {
      if (points >= entry.value) {
        badge = entry.key;
      }
    }
    return badge;
  }

  Future<bool> dailyCheckIn(String uid) async {
    try {
      final doc = await firestoreService.document('users', uid);
      if (!doc.exists || doc.data() == null) return false;

      final data = doc.data() as Map<String, dynamic>;
      final lastCheckIn = data['lastCheckInDate'];

      DateTime? lastCheckInDate;
      if (lastCheckIn is Timestamp) {
        lastCheckInDate = lastCheckIn.toDate();
      } else if (lastCheckIn is String) {
        lastCheckInDate = DateTime.tryParse(lastCheckIn);
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (lastCheckInDate != null) {
        final lastDay = DateTime(lastCheckInDate.year, lastCheckInDate.month, lastCheckInDate.day);
        if (lastDay.isAtSameMomentAs(today)) {
          return false;
        }
      }

      final currentPoints = (data['rewardPoints'] as num?)?.toInt() ?? 0;
      final newPoints = currentPoints + pointsPerCheckIn;
      final newBadge = calculateBadge(newPoints);

      await firestoreService.setData('users', uid, {
        'rewardPoints': newPoints,
        'badge': newBadge,
        'lastCheckInDate': FieldValue.serverTimestamp(),
      }, merge: true);

      await _addRewardHistory(uid, pointsPerCheckIn, 'Daily Check-in');
      await _notifyUser(uid, 'Daily Check-in!', 'You earned $pointsPerCheckIn points for checking in today.', 'reward');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasCheckedInToday(String uid) async {
    try {
      final doc = await firestoreService.document('users', uid);
      if (!doc.exists || doc.data() == null) return false;

      final data = doc.data() as Map<String, dynamic>;
      final lastCheckIn = data['lastCheckInDate'];

      DateTime? lastCheckInDate;
      if (lastCheckIn is Timestamp) {
        lastCheckInDate = lastCheckIn.toDate();
      } else if (lastCheckIn is String) {
        lastCheckInDate = DateTime.tryParse(lastCheckIn);
      }

      if (lastCheckInDate == null) return false;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastDay = DateTime(lastCheckInDate.year, lastCheckInDate.month, lastCheckInDate.day);
      return lastDay.isAtSameMomentAs(today);
    } catch (e) {
      return false;
    }
  }

  Future<void> _addRewardHistory(String uid, int points, String reason) async {
    await firestoreService.addData('rewards', {
      'uid': uid,
      'points': points,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _notifyUser(String uid, String title, String body, String type) async {
    try {
      await firestoreService.addData('notifications', {
        'uid': uid,
        'title': title,
        'body': body,
        'type': type,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> getRewardHistory(String uid) async {
    try {
      final snapshot = await firestoreService
          .collection('rewards')
          .where('uid', isEqualTo: uid)
          .get();

      final docs = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
      docs.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return (bTime as dynamic).compareTo(aTime as dynamic);
      });
      return docs.take(20).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> getLeaderboard({int limit = 10}) async {
    try {
      final snapshot = await firestoreService
          .collection('users')
          .orderBy('rewardPoints', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  int getProgressToNextBadge(int currentPoints) {
    for (final entry in badgeThresholds.entries) {
      if (currentPoints < entry.value) {
        return entry.value - 1;
      }
    }
    return currentPoints;
  }

  int getNextBadgeThreshold(int currentPoints) {
    for (final entry in badgeThresholds.entries) {
      if (currentPoints < entry.value) {
        return entry.value;
      }
    }
    return 9999; // Return max threshold when user has reached highest badge
  }

  String getNextBadgeName(int currentPoints) {
    for (final entry in badgeThresholds.entries) {
      if (currentPoints < entry.value) {
        return entry.key;
      }
    }
    return 'Max Badge Reached';
  }
}
