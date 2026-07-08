import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/item_model.dart';
import 'firestore_service.dart';

class FavoriteService {
  final FirestoreService firestoreService;

  FavoriteService({required this.firestoreService});

  Future<void> toggleFavorite(String uid, String itemId) async {
    try {
      final docId = '${uid}_$itemId';
      final doc = await firestoreService.document('favorites', docId);

      if (doc.exists) {
        await firestoreService.deleteData('favorites', docId);
      } else {
        await firestoreService.setData('favorites', docId, {
          'uid': uid,
          'itemId': itemId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<bool> isFavorited(String uid, String itemId) async {
    try {
      final docId = '${uid}_$itemId';
      final doc = await firestoreService.document('favorites', docId);
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking favorite: $e');
      return false;
    }
  }

  Stream<List<String>> getUserFavoriteIds(String uid) {
    return firestoreService
        .collection('favorites')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['itemId'] as String)
          .toList();
    });
  }

  Future<List<ItemModel>> getUserFavorites(String uid) async {
    try {
      final favSnapshot = await firestoreService
          .collection('favorites')
          .where('uid', isEqualTo: uid)
          .get();

      final itemIds = favSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['itemId'] as String)
          .toList();

      if (itemIds.isEmpty) return [];

      // Batch fetch items in chunks of 10 (Firestore 'in' operator limit)
      final items = <ItemModel>[];
      for (int i = 0; i < itemIds.length; i += 10) {
        final chunk = itemIds.sublist(
          i,
          i + 10 > itemIds.length ? itemIds.length : i + 10,
        );
        
        final snapshot = await firestoreService
            .collection('items')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (final doc in snapshot.docs) {
          items.add(ItemModel.fromMap({
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          }));
        }
      }

      return items;
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }

  Future<int> getFavoriteCount(String uid) async {
    try {
      final snapshot = await firestoreService
          .collection('favorites')
          .where('uid', isEqualTo: uid)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting favorite count: $e');
      return 0;
    }
  }
}
