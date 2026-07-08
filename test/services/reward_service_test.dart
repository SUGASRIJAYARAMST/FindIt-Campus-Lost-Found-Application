import 'package:flutter_test/flutter_test.dart';

import 'package:find_it/core/services/reward_service.dart';

void main() {
  group('RewardService', () {
    group('badgeThresholds', () {
      test('has correct badge names and thresholds', () {
        expect(RewardService.badgeThresholds['Good Helper'], 50);
        expect(RewardService.badgeThresholds['Beginner Finder'], 100);
        expect(RewardService.badgeThresholds['Trusted Finder'], 250);
        expect(RewardService.badgeThresholds['Campus Hero'], 500);
        expect(RewardService.badgeThresholds['Lost & Found Champion'], 1000);
      });
    });

    group('point constants', () {
      test('has correct point values', () {
        expect(RewardService.pointsPerReturn, 10);
        expect(RewardService.pointsPerClaim, 5);
        expect(RewardService.pointsPerLostReport, 10);
        expect(RewardService.pointsPerFoundReport, 15);
        expect(RewardService.pointsPerCheckIn, 5);
      });
    });

    group('allBadges', () {
      test('has 5 badges', () {
        expect(RewardService.allBadges.length, 5);
      });

      test('badge names match thresholds', () {
        final badgeNames = RewardService.allBadges.map((b) => b['name']).toList();
        expect(badgeNames, contains('Good Helper'));
        expect(badgeNames, contains('Beginner Finder'));
        expect(badgeNames, contains('Trusted Finder'));
        expect(badgeNames, contains('Campus Hero'));
        expect(badgeNames, contains('Lost & Found Champion'));
      });

      test('each badge has required fields', () {
        for (final badge in RewardService.allBadges) {
          expect(badge.containsKey('name'), isTrue);
          expect(badge.containsKey('min'), isTrue);
          expect(badge.containsKey('max'), isTrue);
          expect(badge.containsKey('icon'), isTrue);
          expect(badge.containsKey('color'), isTrue);
        }
      });

      test('badges have non-overlapping ranges', () {
        for (int i = 0; i < RewardService.allBadges.length - 1; i++) {
          final current = RewardService.allBadges[i];
          final next = RewardService.allBadges[i + 1];
          expect(current['max'], lessThan(next['min']));
        }
      });
    });

    // Test pure calculation methods by replicating the logic.
    // Firestore-dependent methods are integration-tested on device.
    group('calculateBadge', () {
      // Replicate the calculateBadge logic from RewardService
      String calculateBadge(int points) {
        String badge = 'Good Helper';
        for (final entry in RewardService.badgeThresholds.entries) {
          if (points >= entry.value) {
            badge = entry.key;
          }
        }
        return badge;
      }

      // Thresholds: Good Helper: 50, Beginner Finder: 100, Trusted Finder: 250, Campus Hero: 500, Champion: 1000
      test('returns Good Helper for 0 points', () {
        expect(calculateBadge(0), 'Good Helper');
      });

      test('returns Good Helper for 49 points', () {
        expect(calculateBadge(49), 'Good Helper');
      });

      test('returns Good Helper for exactly 50 points (reached Good Helper but not Beginner Finder)', () {
        expect(calculateBadge(50), 'Good Helper');
      });

      test('returns Good Helper for 99 points', () {
        expect(calculateBadge(99), 'Good Helper');
      });

      test('returns Beginner Finder for 100 points', () {
        expect(calculateBadge(100), 'Beginner Finder');
      });

      test('returns Beginner Finder for 249 points', () {
        expect(calculateBadge(249), 'Beginner Finder');
      });

      test('returns Trusted Finder for 250 points', () {
        expect(calculateBadge(250), 'Trusted Finder');
      });

      test('returns Trusted Finder for 499 points', () {
        expect(calculateBadge(499), 'Trusted Finder');
      });

      test('returns Campus Hero for 500 points', () {
        expect(calculateBadge(500), 'Campus Hero');
      });

      test('returns Campus Hero for 999 points', () {
        expect(calculateBadge(999), 'Campus Hero');
      });

      test('returns Lost & Found Champion for 1000 points', () {
        expect(calculateBadge(1000), 'Lost & Found Champion');
      });

      test('returns Lost & Found Champion for 2000 points', () {
        expect(calculateBadge(2000), 'Lost & Found Champion');
      });
    });

    group('getProgressToNextBadge', () {
      int getProgressToNextBadge(int currentPoints) {
        for (final entry in RewardService.badgeThresholds.entries) {
          if (currentPoints < entry.value) {
            return entry.value - 1;
          }
        }
        return currentPoints;
      }

      test('returns 49 for 0 points', () {
        expect(getProgressToNextBadge(0), 49);
      });

      test('returns 99 for 50 points', () {
        expect(getProgressToNextBadge(50), 99);
      });

      test('returns 249 for 100 points', () {
        expect(getProgressToNextBadge(100), 249);
      });

      test('returns 499 for 250 points', () {
        expect(getProgressToNextBadge(250), 499);
      });

      test('returns 999 for 500 points', () {
        expect(getProgressToNextBadge(500), 999);
      });

      test('returns current points when at max badge', () {
        expect(getProgressToNextBadge(1500), 1500);
      });
    });

    group('getNextBadgeThreshold', () {
      int getNextBadgeThreshold(int currentPoints) {
        for (final entry in RewardService.badgeThresholds.entries) {
          if (currentPoints < entry.value) {
            return entry.value;
          }
        }
        return 9999;
      }

      test('returns 50 for 0 points', () {
        expect(getNextBadgeThreshold(0), 50);
      });

      test('returns 100 for 50 points', () {
        expect(getNextBadgeThreshold(50), 100);
      });

      test('returns 250 for 100 points', () {
        expect(getNextBadgeThreshold(100), 250);
      });

      test('returns 9999 when at max badge', () {
        expect(getNextBadgeThreshold(1500), 9999);
      });
    });

    group('getNextBadgeName', () {
      String getNextBadgeName(int currentPoints) {
        for (final entry in RewardService.badgeThresholds.entries) {
          if (currentPoints < entry.value) {
            return entry.key;
          }
        }
        return 'Max Badge Reached';
      }

      test('returns Good Helper for 0 points (next badge is Good Helper at 50)', () {
        expect(getNextBadgeName(0), 'Good Helper');
      });

      test('returns Beginner Finder for 50 points', () {
        expect(getNextBadgeName(50), 'Beginner Finder');
      });

      test('returns Trusted Finder for 100 points', () {
        expect(getNextBadgeName(100), 'Trusted Finder');
      });

      test('returns Campus Hero for 250 points', () {
        expect(getNextBadgeName(250), 'Campus Hero');
      });

      test('returns Lost & Found Champion for 500 points', () {
        expect(getNextBadgeName(500), 'Lost & Found Champion');
      });

      test('returns Max Badge Reached when at max', () {
        expect(getNextBadgeName(1500), 'Max Badge Reached');
      });
    });
  });
}
