import 'package:cloud_firestore/cloud_firestore.dart';

class TimelineEvent {
  final String id;
  final String itemId;
  final String eventType;
  final String description;
  final String performedBy;
  final String performedByName;
  final DateTime? timestamp;
  final Map<String, dynamic>? metadata;

  TimelineEvent({
    required this.id,
    required this.itemId,
    required this.eventType,
    required this.description,
    required this.performedBy,
    required this.performedByName,
    this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'eventType': eventType,
      'description': description,
      'performedBy': performedBy,
      'performedByName': performedByName,
      'timestamp': FieldValue.serverTimestamp(),
      'metadata': metadata,
    };
  }

  factory TimelineEvent.fromMap(Map<String, dynamic> map) {
    return TimelineEvent(
      id: map['id'] as String? ?? '',
      itemId: map['itemId'] as String? ?? '',
      eventType: map['eventType'] as String? ?? '',
      description: map['description'] as String? ?? '',
      performedBy: map['performedBy'] as String? ?? '',
      performedByName: map['performedByName'] as String? ?? '',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : map['timestamp'] != null
              ? DateTime.tryParse(map['timestamp'] as String)
              : null,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  String get eventTypeDisplay {
    switch (eventType) {
      case 'created':
        return 'Reported';
      case 'claimed':
        return 'Claimed';
      case 'matched':
        return 'Matched';
      case 'recovered':
        return 'Recovered';
      case 'returned':
        return 'Returned';
      case 'updated':
        return 'Updated';
      case 'archived':
        return 'Archived';
      default:
        return eventType;
    }
  }
}
