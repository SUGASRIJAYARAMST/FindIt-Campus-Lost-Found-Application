import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/item_model.dart';
import 'firestore_service.dart';

class ArchiveService {
  final FirestoreService firestoreService;

  ArchiveService({required this.firestoreService});

  Future<void> archiveItem(String itemId) async {
    try {
      final doc = await firestoreService.document('items', itemId);
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        await firestoreService.setData('archived_items', itemId, {
          ...data,
          'archivedAt': FieldValue.serverTimestamp(),
          'originalStatus': data['status'],
        });
        await firestoreService.deleteData('items', itemId);
      }
    } catch (e) {
      debugPrint('Error archiving item: $e');
    }
  }

  Future<void> unarchiveItem(String itemId) async {
    try {
      final doc = await firestoreService.document('archived_items', itemId);
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final restoredData = Map<String, dynamic>.from(data)
          ..remove('archivedAt')
          ..remove('originalStatus')
          ..['status'] = data['originalStatus'] ?? 'lost';
        await firestoreService.setData('items', itemId, restoredData);
        await firestoreService.deleteData('archived_items', itemId);
      }
    } catch (e) {
      debugPrint('Error unarchiving item: $e');
    }
  }

  Stream<List<ItemModel>> getArchivedItems() {
    return firestoreService
        .collection('archived_items')
        .orderBy('archivedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ItemModel.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    });
  }

  Future<void> autoArchiveOldItems({int daysOld = 20}) async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: daysOld));
      final snapshot = await firestoreService
          .collection('items')
          .where('status', whereIn: ['recovered', 'returned'])
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = data['createdAt'];
        if (createdAt != null) {
          DateTime createdDate;
          if (createdAt is Timestamp) {
            createdDate = createdAt.toDate();
          } else {
            continue;
          }
          if (createdDate.isBefore(cutoff)) {
            await archiveItem(doc.id);
            debugPrint('Auto-archived item: ${doc.id}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error auto-archiving: $e');
    }
  }

  Future<void> deleteArchivedItem(String itemId) async {
    try {
      await firestoreService.deleteData('archived_items', itemId);
    } catch (e) {
      debugPrint('Error deleting archived item: $e');
    }
  }
}
