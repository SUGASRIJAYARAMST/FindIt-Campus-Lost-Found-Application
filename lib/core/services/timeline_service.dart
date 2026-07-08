import 'package:flutter/foundation.dart';

import '../../domain/models/timeline_event.dart';
import 'firestore_service.dart';

class TimelineService {
  final FirestoreService firestoreService;

  TimelineService({required this.firestoreService});

  Future<void> addEvent({
    required String itemId,
    required String eventType,
    required String description,
    required String performedBy,
    required String performedByName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final docRef = firestoreService.collection('timeline').doc();
      final event = TimelineEvent(
        id: docRef.id,
        itemId: itemId,
        eventType: eventType,
        description: description,
        performedBy: performedBy,
        performedByName: performedByName,
        metadata: metadata,
      );
      await docRef.set(event.toMap());
    } catch (e) {
      debugPrint('Error adding timeline event: $e');
    }
  }

  Stream<List<TimelineEvent>> getItemTimeline(String itemId) {
    return firestoreService
        .collection('timeline')
        .where('itemId', isEqualTo: itemId)
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => TimelineEvent.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
      events.sort((a, b) {
        if (a.timestamp == null && b.timestamp == null) return 0;
        if (a.timestamp == null) return 1;
        if (b.timestamp == null) return -1;
        return b.timestamp!.compareTo(a.timestamp!);
      });
      return events;
    });
  }

  Future<List<TimelineEvent>> getItemTimelineOnce(String itemId) async {
    try {
      final snapshot = await firestoreService
          .collection('timeline')
          .where('itemId', isEqualTo: itemId)
          .get();

      final events = snapshot.docs
          .map((doc) => TimelineEvent.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
      events.sort((a, b) {
        if (a.timestamp == null && b.timestamp == null) return 0;
        if (a.timestamp == null) return 1;
        if (b.timestamp == null) return -1;
        return b.timestamp!.compareTo(a.timestamp!);
      });
      return events;
    } catch (e) {
      debugPrint('Error getting timeline: $e');
      return [];
    }
  }
}
