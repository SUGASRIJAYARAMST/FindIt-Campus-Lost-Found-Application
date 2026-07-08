import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService notificationService;

  bool _isInitialized = false;
  bool _isEnabled = true;
  int _unreadCount = 0;
  StreamSubscription<QuerySnapshot>? _unreadSub;

  NotificationProvider({required this.notificationService});

  bool get isInitialized => _isInitialized;
  bool get isEnabled => _isEnabled;
  int get unreadCount => _unreadCount;

  Future<void> initialize(String uid) async {
    if (_isInitialized) return;
    try {
      await notificationService.initialize();
      await notificationService.saveTokenToFirestore(uid);
      await notificationService.cleanupOldNotifications();
      _isInitialized = true;
      _startUnreadListener(uid);
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  void _startUnreadListener(String uid) {
    _unreadSub?.cancel();
    _unreadSub = FirebaseFirestore.instance
        .collection('notifications')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      _unreadCount = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['read'] == false;
      }).length;
      notifyListeners();
    });
  }

  void stopListening() {
    _unreadSub?.cancel();
    _unreadSub = null;
    _isInitialized = false;
  }

  Future<void> toggleNotifications(bool enabled) async {
    _isEnabled = enabled;
    notifyListeners();
  }

  Future<void> sendItemMatchNotification({
    required String targetUid,
    required String itemTitle,
    required String itemId,
  }) async {
    await notificationService.sendNotificationToUser(
      targetUid: targetUid,
      title: 'Possible Match Found!',
      body: 'We found a possible match for "$itemTitle"',
      data: {'itemId': itemId, 'type': 'match'},
    );
  }

  Future<void> sendClaimNotification({
    required String targetUid,
    required String itemTitle,
    required String claimantName,
    required String itemId,
  }) async {
    await notificationService.sendNotificationToUser(
      targetUid: targetUid,
      title: 'Item Claimed!',
      body: '$claimantName has claimed your item "$itemTitle"',
      data: {'itemId': itemId, 'type': 'claim'},
    );
  }

  Future<void> sendStatusUpdateNotification({
    required String targetUid,
    required String itemTitle,
    required String newStatus,
    required String itemId,
  }) async {
    await notificationService.sendNotificationToUser(
      targetUid: targetUid,
      title: 'Item Status Updated',
      body: '"$itemTitle" has been marked as $newStatus',
      data: {'itemId': itemId, 'type': 'status_update'},
    );
  }

  @override
  void dispose() {
    _unreadSub?.cancel();
    super.dispose();
  }
}
