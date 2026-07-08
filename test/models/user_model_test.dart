import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:find_it/domain/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('creates with required fields only', () {
      final user = UserModel(uid: 'u1', name: 'John', email: 'john@test.com');

      expect(user.uid, 'u1');
      expect(user.name, 'John');
      expect(user.email, 'john@test.com');
      expect(user.department, '');
      expect(user.phone, '');
      expect(user.role, 'student');
      expect(user.status, 'active');
      expect(user.profileImage, '');
      expect(user.rewardPoints, 0);
      expect(user.badge, 'Good Helper');
      expect(user.referralCode, '');
      expect(user.referredBy, '');
      expect(user.referralCount, 0);
      expect(user.createdAt, isNull);
    });

    test('creates with all fields', () {
      final now = DateTime(2025, 1, 15);
      final user = UserModel(
        uid: 'u1',
        name: 'John',
        email: 'john@test.com',
        department: 'CS',
        phone: '1234567890',
        role: 'admin',
        status: 'active',
        profileImage: 'https://img.com/pic.jpg',
        rewardPoints: 100,
        badge: 'Campus Hero',
        referralCode: 'FIAB1234',
        referredBy: 'FICD5678',
        referralCount: 5,
        createdAt: now,
      );

      expect(user.department, 'CS');
      expect(user.phone, '1234567890');
      expect(user.role, 'admin');
      expect(user.profileImage, 'https://img.com/pic.jpg');
      expect(user.rewardPoints, 100);
      expect(user.badge, 'Campus Hero');
      expect(user.referralCode, 'FIAB1234');
      expect(user.referredBy, 'FICD5678');
      expect(user.referralCount, 5);
      expect(user.createdAt, now);
    });

    test('isBlocked returns true when status is blocked', () {
      final user = UserModel(
        uid: 'u1',
        name: 'John',
        email: 'j@test.com',
        status: 'blocked',
      );
      expect(user.isBlocked, isTrue);
    });

    test('isBlocked returns false when status is active', () {
      final user = UserModel(uid: 'u1', name: 'John', email: 'j@test.com');
      expect(user.isBlocked, isFalse);
    });

    test('toMap produces correct map', () {
      final user = UserModel(uid: 'u1', name: 'John', email: 'j@test.com');
      final map = user.toMap();

      expect(map['uid'], 'u1');
      expect(map['name'], 'John');
      expect(map['email'], 'j@test.com');
      expect(map['department'], '');
      expect(map['phone'], '');
      expect(map['role'], 'student');
      expect(map['status'], 'active');
      expect(map['profileImage'], '');
      expect(map['rewardPoints'], 0);
      expect(map['badge'], 'Good Helper');
      expect(map['referralCode'], '');
      expect(map['referredBy'], '');
      expect(map['referralCount'], 0);
      expect(map['createdAt'], isA<FieldValue>());
    });

    group('fromMap', () {
      test('parses complete map with Timestamp', () {
        final timestamp = Timestamp.fromDate(DateTime(2025, 6, 1));
        final map = {
          'uid': 'u1',
          'name': 'John',
          'email': 'j@test.com',
          'department': 'CS',
          'phone': '123',
          'role': 'admin',
          'status': 'blocked',
          'profileImage': 'img.jpg',
          'rewardPoints': 50,
          'badge': 'Beginner Finder',
          'referralCode': 'FIAB1234',
          'referredBy': 'FICD5678',
          'referralCount': 3,
          'createdAt': timestamp,
        };

        final user = UserModel.fromMap(map);

        expect(user.uid, 'u1');
        expect(user.name, 'John');
        expect(user.email, 'j@test.com');
        expect(user.department, 'CS');
        expect(user.phone, '123');
        expect(user.role, 'admin');
        expect(user.status, 'blocked');
        expect(user.profileImage, 'img.jpg');
        expect(user.rewardPoints, 50);
        expect(user.badge, 'Beginner Finder');
        expect(user.referralCode, 'FIAB1234');
        expect(user.referredBy, 'FICD5678');
        expect(user.referralCount, 3);
        expect(user.createdAt, timestamp.toDate());
      });

      test('handles empty map with defaults', () {
        final user = UserModel.fromMap({});

        expect(user.uid, '');
        expect(user.name, '');
        expect(user.email, '');
        expect(user.department, '');
        expect(user.phone, '');
        expect(user.role, 'student');
        expect(user.status, 'active');
        expect(user.rewardPoints, 0);
        expect(user.badge, 'Good Helper');
      });

      test('handles null values in map', () {
        final user = UserModel.fromMap({
          'uid': null,
          'name': null,
          'email': null,
          'rewardPoints': null,
          'referralCount': null,
        });

        expect(user.uid, '');
        expect(user.name, '');
        expect(user.rewardPoints, 0);
        expect(user.referralCount, 0);
      });

      test('handles numeric types for rewardPoints and referralCount', () {
        final user = UserModel.fromMap({
          'rewardPoints': 42.0,
          'referralCount': 7.0,
        });

        expect(user.rewardPoints, 42);
        expect(user.referralCount, 7);
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        final user = UserModel(uid: 'u1', name: 'John', email: 'j@test.com');
        final copy = user.copyWith();

        expect(copy.uid, user.uid);
        expect(copy.name, user.name);
        expect(copy.email, user.email);
      });

      test('copies with specific field changes', () {
        final user = UserModel(uid: 'u1', name: 'John', email: 'j@test.com');
        final copy = user.copyWith(name: 'Jane', rewardPoints: 50);

        expect(copy.uid, 'u1');
        expect(copy.name, 'Jane');
        expect(copy.email, 'j@test.com');
        expect(copy.rewardPoints, 50);
      });
    });
  });
}
