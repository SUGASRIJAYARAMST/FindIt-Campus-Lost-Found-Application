import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:find_it/domain/models/item_model.dart';

void main() {
  group('ItemModel', () {
    test('creates with required fields only', () {
      final item = ItemModel(
        id: 'i1',
        title: 'Blue Backpack',
        category: 'Bags',
        description: 'A blue backpack',
        location: 'Library',
        contactNumber: '09123456789',
        type: 'lost',
        createdBy: 'John',
        createdByUid: 'u1',
      );

      expect(item.id, 'i1');
      expect(item.title, 'Blue Backpack');
      expect(item.category, 'Bags');
      expect(item.description, 'A blue backpack');
      expect(item.location, 'Library');
      expect(item.contactNumber, '09123456789');
      expect(item.type, 'lost');
      expect(item.status, 'lost');
      expect(item.createdBy, 'John');
      expect(item.createdByUid, 'u1');
      expect(item.imageUrl, '');
      expect(item.itemDate, isNull);
      expect(item.createdAt, isNull);
      expect(item.claimedBy, isNull);
      expect(item.claimedAt, isNull);
    });

    group('fromMap', () {
      test('parses complete map with Timestamps', () {
        final now = DateTime(2025, 6, 15);
        final map = {
          'id': 'i1',
          'title': 'Blue Backpack',
          'category': 'Bags',
          'description': 'A blue backpack',
          'location': 'Library',
          'itemDate': Timestamp.fromDate(now),
          'imageUrl': 'https://img.com/bag.jpg',
          'contactNumber': '09123456789',
          'type': 'lost',
          'status': 'lost',
          'createdBy': 'John',
          'createdByUid': 'u1',
          'createdAt': Timestamp.fromDate(now),
          'claimedBy': 'u2',
          'claimedAt': Timestamp.fromDate(now),
        };

        final item = ItemModel.fromMap(map);

        expect(item.id, 'i1');
        expect(item.title, 'Blue Backpack');
        expect(item.itemDate, now);
        expect(item.imageUrl, 'https://img.com/bag.jpg');
        expect(item.type, 'lost');
        expect(item.status, 'lost');
        expect(item.claimedBy, 'u2');
        expect(item.claimedAt, now);
      });

      test('migrates open status to lost', () {
        final item = ItemModel.fromMap({'status': 'open', 'type': 'lost'});
        expect(item.status, 'lost');
      });

      test('preserves available status as-is (only open migrates to lost)', () {
        final item = ItemModel.fromMap({'status': 'available', 'type': 'found'});
        expect(item.status, 'available');
      });

      test('handles DateTime values for dates', () {
        final now = DateTime(2025, 6, 1);
        final item = ItemModel.fromMap({
          'itemDate': now,
          'createdAt': now,
          'claimedAt': now,
        });

        expect(item.itemDate, now);
        expect(item.createdAt, now);
        expect(item.claimedAt, now);
      });

      test('handles String values for dates', () {
        final item = ItemModel.fromMap({
          'itemDate': '2025-06-01T12:00:00.000',
          'createdAt': '2025-06-01T12:00:00.000',
          'claimedAt': 'invalid-date',
        });

        expect(item.itemDate, isNotNull);
        expect(item.createdAt, isNotNull);
        expect(item.claimedAt, isNull); // invalid string returns null
      });

      test('handles empty map with defaults', () {
        final item = ItemModel.fromMap({});

        expect(item.id, '');
        expect(item.title, '');
        expect(item.type, 'lost');
        expect(item.status, 'lost');
        expect(item.imageUrl, '');
      });

      test('handles null values gracefully', () {
        final item = ItemModel.fromMap({
          'id': null,
          'title': null,
          'itemDate': null,
          'createdAt': null,
        });

        expect(item.id, '');
        expect(item.title, '');
        expect(item.itemDate, isNull);
        expect(item.createdAt, isNull);
      });
    });

    group('toMap', () {
      test('produces correct map', () {
        final item = ItemModel(
          id: 'i1',
          title: 'Phone',
          category: 'Electronics',
          description: 'iPhone 15',
          location: 'Cafeteria',
          contactNumber: '09123456789',
          type: 'found',
          status: 'found',
          createdBy: 'John',
          createdByUid: 'u1',
        );

        final map = item.toMap();

        expect(map['id'], 'i1');
        expect(map['title'], 'Phone');
        expect(map['type'], 'found');
        expect(map['status'], 'found');
        expect(map['createdAt'], isA<FieldValue>());
      });

      test('converts DateTime to Timestamp in toMap', () {
        final now = DateTime(2025, 6, 1);
        final item = ItemModel(
          id: 'i1',
          title: 'Phone',
          category: 'Electronics',
          description: 'iPhone 15',
          location: 'Cafeteria',
          contactNumber: '09123456789',
          type: 'found',
          createdBy: 'John',
          createdByUid: 'u1',
          itemDate: now,
          claimedAt: now,
        );

        final map = item.toMap();

        expect(map['itemDate'], isA<Timestamp>());
        expect((map['itemDate'] as Timestamp).toDate(), now);
        expect(map['claimedAt'], isA<Timestamp>());
      });

      test('toMap null dates produce null values', () {
        final item = ItemModel(
          id: 'i1',
          title: 'Phone',
          category: 'Electronics',
          description: '',
          location: 'Cafeteria',
          contactNumber: '09123456789',
          type: 'found',
          createdBy: 'John',
          createdByUid: 'u1',
        );

        final map = item.toMap();

        expect(map['itemDate'], isNull);
        expect(map['claimedAt'], isNull);
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        final item = ItemModel(
          id: 'i1',
          title: 'Phone',
          category: 'Electronics',
          description: '',
          location: 'Cafeteria',
          contactNumber: '09123456789',
          type: 'found',
          createdBy: 'John',
          createdByUid: 'u1',
        );
        final copy = item.copyWith();

        expect(copy.id, item.id);
        expect(copy.title, item.title);
      });

      test('copies with specific changes', () {
        final item = ItemModel(
          id: 'i1',
          title: 'Phone',
          category: 'Electronics',
          description: '',
          location: 'Cafeteria',
          contactNumber: '09123456789',
          type: 'found',
          createdBy: 'John',
          createdByUid: 'u1',
        );
        final copy = item.copyWith(title: 'Laptop', status: 'claimed');

        expect(copy.id, 'i1');
        expect(copy.title, 'Laptop');
        expect(copy.status, 'claimed');
      });
    });

    group('statusDisplay', () {
      test('returns Lost for lost status', () {
        final item = _testItem(status: 'lost');
        expect(item.statusDisplay, 'Lost');
      });

      test('returns Found for found status', () {
        final item = _testItem(status: 'found');
        expect(item.statusDisplay, 'Found');
      });

      test('returns Matched for matched status', () {
        final item = _testItem(status: 'matched');
        expect(item.statusDisplay, 'Matched');
      });

      test('returns Recovered for recovered status', () {
        final item = _testItem(status: 'recovered');
        expect(item.statusDisplay, 'Recovered');
      });

      test('returns Claimed for claimed status', () {
        final item = _testItem(status: 'claimed');
        expect(item.statusDisplay, 'Claimed');
      });

      test('returns Returned for returned status', () {
        final item = _testItem(status: 'returned');
        expect(item.statusDisplay, 'Returned');
      });

      test('returns raw status for unknown', () {
        final item = _testItem(status: 'unknown');
        expect(item.statusDisplay, 'unknown');
      });
    });

    group('typeDisplay', () {
      test('returns Lost Item for lost type', () {
        final item = _testItem(type: 'lost');
        expect(item.typeDisplay, 'Lost Item');
      });

      test('returns Found Item for found type', () {
        final item = _testItem(type: 'found');
        expect(item.typeDisplay, 'Found Item');
      });
    });
  });
}

ItemModel _testItem({String status = 'lost', String type = 'lost'}) {
  return ItemModel(
    id: 'i1',
    title: 'Test Item',
    category: 'Test',
    description: 'Test desc',
    location: 'Test loc',
    contactNumber: '09123456789',
    type: type,
    status: status,
    createdBy: 'Test User',
    createdByUid: 'u1',
  );
}
