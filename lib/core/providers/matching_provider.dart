import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/item_model.dart';
import '../services/matching_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class MatchingProvider extends ChangeNotifier {
  final FirestoreService firestoreService;
  final NotificationService? notificationService;
  final MatchingService _matchingService = MatchingService();

  List<MatchResult> _matches = [];
  final Set<String> _dismissedMatches = {};
  bool _isMatching = false;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _lostSub;
  StreamSubscription<QuerySnapshot>? _foundSub;
  List<ItemModel> _lostItems = [];
  List<ItemModel> _foundItems = [];

  MatchingProvider({required this.firestoreService, this.notificationService});

  List<MatchResult> get matches =>
      _matches.where((m) => !_dismissedMatches.contains('${m.lostItem.id}_${m.foundItem.id}')).toList();
  bool get isMatching => _isMatching;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void startListening() {
    _lostSub?.cancel();
    _foundSub?.cancel();

    _lostSub = firestoreService
        .collection('items')
        .where('type', isEqualTo: 'lost')
        .snapshots()
        .listen(
      (snapshot) {
        _lostItems = snapshot.docs
            .map((doc) => ItemModel.fromMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .where((item) => item.status == 'lost' || item.status == 'matched')
            .toList();
        _runMatching();
      },
      onError: (error) {
        debugPrint('Lost items stream error: $error');
      },
    );

    _foundSub = firestoreService
        .collection('items')
        .where('type', isEqualTo: 'found')
        .snapshots()
        .listen(
      (snapshot) {
        _foundItems = snapshot.docs
            .map((doc) => ItemModel.fromMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .where((item) => item.status == 'found')
            .toList();
        _runMatching();
      },
      onError: (error) {
        debugPrint('Found items stream error: $error');
      },
    );
  }

  void stopListening() {
    _lostSub?.cancel();
    _foundSub?.cancel();
    _lostSub = null;
    _foundSub = null;
  }

  void _runMatching() {
    if (_lostItems.isEmpty || _foundItems.isEmpty) {
      _matches = [];
      notifyListeners();
      return;
    }

    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final freshLost = _lostItems.where((i) {
      final date = i.createdAt ?? i.itemDate;
      return date == null || date.isAfter(cutoff);
    }).toList();
    final freshFound = _foundItems.where((i) {
      final date = i.createdAt ?? i.itemDate;
      return date == null || date.isAfter(cutoff);
    }).toList();

    _isMatching = true;
    notifyListeners();

    _matches = _matchingService.findMatches(
      lostItems: freshLost,
      foundItems: freshFound,
      maxResults: 10,
    );

    _notifyNewMatches(_matches);

    _isMatching = false;
    notifyListeners();
  }

  List<MatchResult> getMatchesForItem(String itemId) {
    ItemModel? item;
    try {
      item = [..._lostItems, ..._foundItems].firstWhere((i) => i.id == itemId);
    } catch (e) {
      debugPrint('Item not found for matching: $itemId');
      return [];
    }

    if (item.id.isEmpty) return [];

    final oppositeItems = item.type == 'lost' ? _foundItems : _lostItems;

    return _matchingService.findMatchesForItem(
      item: item,
      oppositeItems: oppositeItems,
      maxResults: 10,
    );
  }

  void runManualMatch() {
    // Re-subscribe to streams to get fresh data from Firestore
    startListening();
  }

  void dismissMatch(String lostItemId, String foundItemId) {
    final key = '${lostItemId}_$foundItemId';
    _dismissedMatches.add(key);
    notifyListeners();
  }

  void restoreAllMatches() {
    _dismissedMatches.clear();
    notifyListeners();
  }

  void _notifyNewMatches(List<MatchResult> matches) async {
    if (notificationService == null) return;

    try {
      final existingNotifications = await firestoreService
          .collection('notifications')
          .where('type', isEqualTo: 'match')
          .get();

      final Set<String> notifiedItemIds = {};
      final Set<String> notifiedBodies = {};
      for (final doc in existingNotifications.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final itemId = data['itemId'] as String? ?? '';
        final body = data['body'] as String? ?? '';
        if (itemId.isNotEmpty) notifiedItemIds.add(itemId);
        if (body.isNotEmpty) notifiedBodies.add(body);
      }

      for (final match in matches) {
        if (match.score < 60) continue;

        final lostId = match.lostItem.id;
        if (notifiedItemIds.contains(lostId)) continue;

        final bodyText = '"${match.foundItem.title}" may match your lost "${match.lostItem.title}" (${match.score.round()}% match)';
        if (notifiedBodies.contains(bodyText)) continue;

        final ownerUid = match.lostItem.createdByUid;
        if (ownerUid.isEmpty) continue;

        await notificationService!.sendNotificationToUser(
          targetUid: ownerUid,
          title: 'Possible Match Found!',
          body: bodyText,
          data: {'itemId': lostId, 'type': 'match'},
        );

        notifiedItemIds.add(lostId);
        notifiedBodies.add(bodyText);
      }
    } catch (e) {
      debugPrint('Notify matches error: $e');
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
