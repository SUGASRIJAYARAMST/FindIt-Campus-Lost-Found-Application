import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:find_it/domain/models/timeline_event.dart';

void main() {
  group('TimelineEvent', () {
    test('creates with required fields', () {
      final event = TimelineEvent(
        id: 'e1',
        itemId: 'i1',
        eventType: 'created',
        description: 'Item reported',
        performedBy: 'u1',
        performedByName: 'John',
      );

      expect(event.id, 'e1');
      expect(event.itemId, 'i1');
      expect(event.eventType, 'created');
      expect(event.description, 'Item reported');
      expect(event.performedBy, 'u1');
      expect(event.performedByName, 'John');
      expect(event.timestamp, isNull);
      expect(event.metadata, isNull);
    });

    test('creates with all fields', () {
      final now = DateTime(2025, 6, 1);
      final event = TimelineEvent(
        id: 'e1',
        itemId: 'i1',
        eventType: 'claimed',
        description: 'Item claimed',
        performedBy: 'u1',
        performedByName: 'John',
        timestamp: now,
        metadata: {'key': 'value'},
      );

      expect(event.timestamp, now);
      expect(event.metadata, {'key': 'value'});
    });

    group('fromMap', () {
      test('parses complete map with Timestamp', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 6, 1));
        final map = {
          'id': 'e1',
          'itemId': 'i1',
          'eventType': 'created',
          'description': 'Item reported',
          'performedBy': 'u1',
          'performedByName': 'John',
          'timestamp': timestamp,
          'metadata': {'key': 'value'},
        };

        final event = TimelineEvent.fromMap(map);

        expect(event.id, 'e1');
        expect(event.itemId, 'i1');
        expect(event.eventType, 'created');
        expect(event.description, 'Item reported');
        expect(event.performedBy, 'u1');
        expect(event.performedByName, 'John');
        expect(event.timestamp, timestamp.toDate());
        expect(event.metadata, {'key': 'value'});
      });

      test('handles string timestamp', () {
        final event = TimelineEvent.fromMap({
          'timestamp': '2025-06-01T12:00:00.000',
        });

        expect(event.timestamp, isNotNull);
      });

      test('handles null timestamp', () {
        final event = TimelineEvent.fromMap({
          'timestamp': null,
        });

        expect(event.timestamp, isNull);
      });

      test('handles empty map with defaults', () {
        final event = TimelineEvent.fromMap({});

        expect(event.id, '');
        expect(event.itemId, '');
        expect(event.eventType, '');
        expect(event.description, '');
        expect(event.performedBy, '');
        expect(event.performedByName, '');
        expect(event.timestamp, isNull);
        expect(event.metadata, isNull);
      });
    });

    group('toMap', () {
      test('produces correct map', () {
        final event = TimelineEvent(
          id: 'e1',
          itemId: 'i1',
          eventType: 'claimed',
          description: 'Item claimed',
          performedBy: 'u1',
          performedByName: 'John',
        );

        final map = event.toMap();

        expect(map['id'], 'e1');
        expect(map['itemId'], 'i1');
        expect(map['eventType'], 'claimed');
        expect(map['description'], 'Item claimed');
        expect(map['performedBy'], 'u1');
        expect(map['performedByName'], 'John');
        expect(map['timestamp'], isA<FieldValue>());
        expect(map['metadata'], isNull);
      });

      test('includes metadata when present', () {
        final event = TimelineEvent(
          id: 'e1',
          itemId: 'i1',
          eventType: 'created',
          description: 'Item reported',
          performedBy: 'u1',
          performedByName: 'John',
          metadata: {'reason': 'test'},
        );

        final map = event.toMap();
        expect(map['metadata'], {'reason': 'test'});
      });
    });

    group('eventTypeDisplay', () {
      test('returns Reported for created', () {
        final event = TimelineEvent(
          id: 'e1', itemId: 'i1', eventType: 'created',
          description: '', performedBy: '', performedByName: '',
        );
        expect(event.eventTypeDisplay, 'Reported');
      });

      test('returns Claimed for claimed', () {
        final event = TimelineEvent(
          id: 'e1', itemId: 'i1', eventType: 'claimed',
          description: '', performedBy: '', performedByName: '',
        );
        expect(event.eventTypeDisplay, 'Claimed');
      });

      test('returns Matched for matched', () {
        final event = TimelineEvent(
          id: 'e1', itemId: 'i1', eventType: 'matched',
          description: '', performedBy: '', performedByName: '',
        );
        expect(event.eventTypeDisplay, 'Matched');
      });

      test('returns Recovered for recovered', () {
        final event = TimelineEvent(
          id: 'e1', itemId: 'i1', eventType: 'recovered',
          description: '', performedBy: '', performedByName: '',
        );
        expect(event.eventTypeDisplay, 'Recovered');
      });

      test('returns Returned for returned', () {
        final event = TimelineEvent(
          id: 'e1', itemId: 'i1', eventType: 'returned',
          description: '', performedBy: '', performedByName: '',
        );
        expect(event.eventTypeDisplay, 'Returned');
      });

      test('returns Updated for updated', () {
        final event = TimelineEvent(
          id: 'e1', itemId: 'i1', eventType: 'updated',
          description: '', performedBy: '', performedByName: '',
        );
        expect(event.eventTypeDisplay, 'Updated');
      });

      test('returns Archived for archived', () {
        final event = TimelineEvent(
          id: 'e1', itemId: 'i1', eventType: 'archived',
          description: '', performedBy: '', performedByName: '',
        );
        expect(event.eventTypeDisplay, 'Archived');
      });

      test('returns raw eventType for unknown', () {
        final event = TimelineEvent(
          id: 'e1', itemId: 'i1', eventType: 'custom',
          description: '', performedBy: '', performedByName: '',
        );
        expect(event.eventTypeDisplay, 'custom');
      });
    });
  });
}
