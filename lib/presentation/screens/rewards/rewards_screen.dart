import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/reward_service.dart';
import '../../../domain/models/user_model.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  bool _hasCheckedIn = false;
  bool _isCheckingIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureDataLoaded());
  }

  Future<void> _ensureDataLoaded() async {
    final userProvider = context.read<UserProvider>();
    final authProvider = context.read<AuthProvider>();
    if (userProvider.userModel == null && authProvider.user != null) {
      await userProvider.fetchUserData(authProvider.user!.uid);
    }
    await _checkDailyStatus();
  }

  Future<void> _checkDailyStatus() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) return;

    final rewardService = context.read<RewardService>();
    final checkedIn = await rewardService.hasCheckedInToday(authProvider.user!.uid);
    if (mounted) {
      setState(() {
        _hasCheckedIn = checkedIn;
      });
    }
  }

  Future<void> _handleCheckIn() async {
    if (_isCheckingIn || _hasCheckedIn) return;

    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    if (authProvider.user == null) return;

    setState(() => _isCheckingIn = true);

    final rewardService = context.read<RewardService>();
    final success = await rewardService.dailyCheckIn(authProvider.user!.uid);

    if (success && mounted) {
      await userProvider.fetchUserData(authProvider.user!.uid);
      setState(() {
        _hasCheckedIn = true;
        _isCheckingIn = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+${RewardService.pointsPerCheckIn} points for daily check-in!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else if (mounted) {
      setState(() => _isCheckingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userProvider = context.watch<UserProvider>();
    final userModel = userProvider.userModel;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09131F) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Rewards'),
        centerTitle: true,
      ),
      body: userModel == null
          ? _buildLoadingOrError(theme, isDark, userProvider)
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildPointsCard(theme, isDark, userModel),
                  const SizedBox(height: 24),
                  _buildBadgeSection(theme, isDark, userModel),
                  const SizedBox(height: 24),
                  _buildRewardsHistory(theme, isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingOrError(ThemeData theme, bool isDark, UserProvider userProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (userProvider.isLoading)
            const CircularProgressIndicator()
          else ...[
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load rewards',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black38,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                final authProvider = context.read<AuthProvider>();
                if (authProvider.user != null) {
                  userProvider.fetchUserData(authProvider.user!.uid);
                }
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPointsCard(ThemeData theme, bool isDark, UserModel userModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0B1929), const Color(0xFF111D2E)]
              : [const Color(0xFF0D47A1), const Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 44),
          ),
          const SizedBox(height: 16),
          Text(
            '${userModel.rewardPoints}',
            style: theme.textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reward Points',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withAlpha(180),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Current Badge: ${userModel.badge}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeSection(ThemeData theme, bool isDark, UserModel userModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badge Progress',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),
        ...RewardService.allBadges.map((badge) {
          final badgeData = _BadgeData(
            badge['name'] as String,
            Icons.emoji_events_outlined,
            badge['min'] as int,
            Color(badge['color'] as int),
          );
          return _buildBadgeCard(theme, isDark, badgeData, userModel);
        }),
      ],
    );
  }

  Widget _buildBadgeCard(ThemeData theme, bool isDark, _BadgeData badge, UserModel userModel) {
    final isUnlocked = userModel.rewardPoints >= badge.points;
    final isCurrent = userModel.badge == badge.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2636) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrent
            ? Border.all(color: badge.color.withAlpha(120), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked ? badge.color.withAlpha(30) : Colors.grey.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              badge.icon,
              color: isUnlocked ? badge.color : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isUnlocked ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${badge.points} points required',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badge.color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Current',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: badge.color),
              ),
            )
          else if (isUnlocked)
            Icon(Icons.check_circle_rounded, color: badge.color, size: 22)
          else
            Icon(Icons.lock_outline_rounded, color: Colors.grey.withAlpha(120), size: 22),
        ],
      ),
    );
  }

  Widget _buildRewardsHistory(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How to Earn Points',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),
        _buildEarnCard(theme, isDark, Icons.add_circle_outline_rounded, 'Report Lost Item', '+10 pts', const Color(0xFFFF7043)),
        _buildEarnCard(theme, isDark, Icons.search_off_rounded, 'Report Found Item', '+15 pts', const Color(0xFF26A69A)),
        _buildEarnCard(theme, isDark, Icons.check_circle_outline_rounded, 'Item Recovered', '+25 pts', const Color(0xFF43A047)),
        const SizedBox(height: 12),
        _buildCheckInCard(theme, isDark),
      ],
    );
  }

  Widget _buildCheckInCard(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: _hasCheckedIn ? null : _handleCheckIn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hasCheckedIn
              ? Colors.green.withAlpha(isDark ? 30 : 15)
              : isDark ? const Color(0xFF1A2636) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hasCheckedIn ? Colors.green.withAlpha(80) : const Color(0xFFFFA726).withAlpha(40),
            width: _hasCheckedIn ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 15 : 5),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _hasCheckedIn
                    ? Colors.green.withAlpha(25)
                    : const Color(0xFFFFA726).withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isCheckingIn
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _hasCheckedIn ? Icons.check_circle_rounded : Icons.star_border_rounded,
                      color: _hasCheckedIn ? Colors.green : const Color(0xFFFFA726),
                      size: 22,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hasCheckedIn ? 'Checked In Today!' : 'Daily Check-in',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _hasCheckedIn
                          ? Colors.green
                          : isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _hasCheckedIn ? 'Come back tomorrow' : 'Tap to earn +5 pts',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (_hasCheckedIn ? Colors.green : const Color(0xFFFFA726)).withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _hasCheckedIn ? 'Done' : '+5 pts',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _hasCheckedIn ? Colors.green : const Color(0xFFFFA726),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarnCard(ThemeData theme, bool isDark, IconData icon, String title, String points, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2636) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 15 : 5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              points,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeData {
  final String name;
  final IconData icon;
  final int points;
  final Color color;
  const _BadgeData(this.name, this.icon, this.points, this.color);
}
