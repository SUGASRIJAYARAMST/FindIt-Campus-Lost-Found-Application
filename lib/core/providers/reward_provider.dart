import 'package:flutter/foundation.dart';

import '../../domain/models/user_model.dart';
import '../services/reward_service.dart';

class RewardProvider extends ChangeNotifier {
  final RewardService rewardService;

  UserModel? _userModel;
  List<Map<String, dynamic>> _rewardHistory = [];
  List<UserModel> _leaderboard = [];
  bool _isLoading = false;
  String? _errorMessage;

  RewardProvider({required this.rewardService});

  UserModel? get userModel => _userModel;
  List<Map<String, dynamic>> get rewardHistory => _rewardHistory;
  List<UserModel> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadUserData(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final doc = await rewardService.firestoreService.document('users', uid);
      if (doc.exists && doc.data() != null) {
        _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _errorMessage = 'Failed to load user data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRewardHistory(String uid) async {
    try {
      _rewardHistory = await rewardService.getRewardHistory(uid);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading reward history: $e');
    }
  }

  Future<void> loadLeaderboard() async {
    try {
      _leaderboard = await rewardService.getLeaderboard(limit: 10);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading leaderboard: $e');
    }
  }

  Future<void> awardPointsForReturn(String uid) async {
    try {
      await rewardService.awardPointsForReturn(uid);
      await loadUserData(uid);
      await loadRewardHistory(uid);
    } catch (e) {
      _errorMessage = 'Failed to award points.';
      notifyListeners();
    }
  }

  Future<void> awardPointsForClaim(String uid) async {
    try {
      await rewardService.awardPointsForClaim(uid);
      await loadUserData(uid);
      await loadRewardHistory(uid);
    } catch (e) {
      _errorMessage = 'Failed to award points.';
      notifyListeners();
    }
  }

  int get currentPoints => _userModel?.rewardPoints ?? 0;
  String get currentBadge => _userModel?.badge ?? 'Good Helper';

  double get progressToNextBadge {
    final points = currentPoints;
    final threshold = rewardService.getNextBadgeThreshold(points);
    final prevThreshold = rewardService.getProgressToNextBadge(points);
    if (threshold == prevThreshold) return 1.0;
    return ((points - prevThreshold) / (threshold - prevThreshold)).clamp(0.0, 1.0);
  }

  String get nextBadgeName => rewardService.getNextBadgeName(currentPoints);

  List<Map<String, dynamic>> get allBadges => RewardService.allBadges;
}
