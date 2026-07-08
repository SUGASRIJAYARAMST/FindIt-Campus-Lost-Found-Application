import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/services/notification_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboardStats();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFeedback() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirmed == true) {
      context.read<UserProvider>().clearUserData();
      await context.read<AuthProvider>().signOut();
    }
  }

  void _showAdminMenu(BuildContext context, ThemeData theme, bool isDark) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Admin Menu',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim, secondaryAnim) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0D1B2A) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 20,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.shield_rounded, color: theme.colorScheme.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Panel',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                  ),
                                ),
                                Text(
                                  'Dashboard Menu',
                                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close_rounded, size: 20, color: isDark ? Colors.white54 : Colors.black38),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(height: 1, color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(8)),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'MANAGEMENT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDrawerTile(
                      icon: Icons.people_rounded,
                      title: 'User Management',
                      subtitle: 'Manage users & permissions',
                      color: theme.colorScheme.primary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(context, AppRouter.adminUsers);
                      },
                    ),
                    _buildDrawerTile(
                      icon: Icons.inventory_2_rounded,
                      title: 'Item Management',
                      subtitle: 'Manage lost & found items',
                      color: const Color(0xFF26A69A),
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(context, AppRouter.adminItems);
                      },
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'SUPPORT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDrawerTile(
                      icon: Icons.feedback_outlined,
                      title: 'Feedback',
                      subtitle: 'View user feedback',
                      color: const Color(0xFFFFA726),
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(ctx);
                        _scrollToFeedback();
                      },
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1, color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(8)),
                    ),
                    const SizedBox(height: 8),
                    _buildDrawerTile(
                      icon: Icons.logout_rounded,
                      title: 'Sign Out',
                      subtitle: 'Log out of admin account',
                      color: const Color(0xFFE53935),
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(ctx);
                        _handleSignOut(context);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: isDark ? Colors.white30 : Colors.black26),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? Colors.white24 : Colors.black26,
        size: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09131F) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _showAdminMenu(context, theme, isDark),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => adminProvider.loadDashboardStats(),
          ),
          IconButton(
            icon: const Icon(Icons.home_rounded),
            tooltip: 'Switch to User',
            onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.home),
          ),
        ],
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => adminProvider.loadDashboardStats(),
                child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCards(adminProvider, theme, isDark),
                    const SizedBox(height: 28),
                    _buildQuickActions(theme, isDark),
                    const SizedBox(height: 28),
                    _buildRecentActivity(theme, isDark),
                    const SizedBox(height: 28),
                    _buildChartsSection(adminProvider, theme, isDark),
                    const SizedBox(height: 28),
                    _buildFeedbackSection(theme, isDark),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewCards(AdminProvider provider, ThemeData theme, bool isDark) {
    final stats = provider.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              Icons.people_rounded,
              '${stats['totalUsers'] ?? 0}',
              'Users',
              const Color(0xFF42A5F5),
              isDark,
            ),
            _buildStatCard(
              Icons.inventory_2_rounded,
              '${stats['totalItems'] ?? 0}',
              'Items',
              const Color(0xFF5C6BC0),
              isDark,
            ),
            _buildStatCard(
              Icons.report_problem_rounded,
              '${stats['lostItems'] ?? 0}',
              'Lost',
              const Color(0xFFE53935),
              isDark,
            ),
            _buildStatCard(
              Icons.search_off_rounded,
              '${stats['foundItems'] ?? 0}',
              'Found',
              const Color(0xFF43A047),
              isDark,
            ),
            _buildStatCard(
              Icons.check_circle_rounded,
              '${stats['recoveredItems'] ?? 0}',
              'Recovered',
              const Color(0xFFFFA726),
              isDark,
            ),
            _buildStatCard(
              Icons.assignment_return_rounded,
              '${stats['returnedItems'] ?? 0}',
              'Returned',
              const Color(0xFF26A69A),
              isDark,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRecoveryRateCard(stats['recoveryRate'] ?? 0, theme, isDark),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2636) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryRateCard(int rate, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0B1929), const Color(0xFF111D2E)]
              : [const Color(0xFF0D47A1), const Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recovery Rate',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(180),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$rate%',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'of reported items recovered',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: rate / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withAlpha(30),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                ),
                Center(
                  child: Text(
                    '$rate%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Management',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                Icons.people_rounded,
                'Users',
                'Manage users',
                const Color(0xFF42A5F5),
                () => Navigator.pushNamed(context, AppRouter.adminUsers),
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                Icons.inventory_2_rounded,
                'Items',
                'Manage items',
                const Color(0xFF26A69A),
                () => Navigator.pushNamed(context, AppRouter.adminItems),
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2636) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 20 : 8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('items')
              .orderBy('createdAt', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2636) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Icon(Icons.history_rounded, size: 40, color: Colors.grey.withAlpha(80)),
                    const SizedBox(height: 8),
                    Text('No recent activity', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ],
                ),
              );
            }

            final docs = snapshot.data!.docs;
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2636) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 20 : 8),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (ctx, idx) => Divider(
                  height: 1,
                  indent: 60,
                  color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                ),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final title = data['title'] ?? 'Unknown';
                  final type = data['type'] ?? '';
                  final status = data['status'] ?? '';
                  final createdAt = data['createdAt'] as Timestamp?;
                  final timeAgo = createdAt != null ? _formatTimeAgo(createdAt.toDate()) : '';

                  final isLost = type == 'lost';
                  final color = isLost ? const Color(0xFFE53935) : const Color(0xFF43A047);
                  final icon = isLost ? Icons.report_problem_rounded : Icons.search_off_rounded;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${type.toUpperCase()} • $status',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                    ),
                    trailing: Text(
                      timeAgo,
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.black26),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChartsSection(AdminProvider provider, ThemeData theme, bool isDark) {
    final categoryCount = provider.stats['categoryCount'] as Map<String, dynamic>? ?? {};
    final locationCount = provider.stats['locationCount'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),
        if (categoryCount.isNotEmpty)
          _buildBarChart('Categories', categoryCount, const Color(0xFF5C6BC0), isDark),
        const SizedBox(height: 16),
        if (locationCount.isNotEmpty)
          _buildBarChart('Top Locations', locationCount, const Color(0xFF26A69A), isDark),
      ],
    );
  }

  Widget _buildBarChart(String title, Map<String, dynamic> data, Color color, bool isDark) {
    final sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topItems = sorted.take(5).toList();
    final maxValue = topItems.isNotEmpty ? topItems.first.value : 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2636) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          ...topItems.map((entry) {
            final percentage = maxValue > 0 ? (entry.value / maxValue) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 8,
                      backgroundColor: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'User Feedback',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF42A5F5).withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF42A5F5)),
                  SizedBox(width: 4),
                  Text('Auto-deletes after 15 days', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF42A5F5))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('feedback')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2636) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Icon(Icons.feedback_outlined, size: 48, color: Colors.grey.withAlpha(80)),
                    const SizedBox(height: 12),
                    Text('No feedback yet', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  ],
                ),
              );
            }

            final docs = snapshot.data!.docs;
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2636) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 20 : 8),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (ctx, idx) => Divider(
                  height: 1,
                  indent: 20,
                  color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                ),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final email = data['email'] ?? 'Unknown';
                  final message = data['message'] ?? '';
                  final status = data['status'] ?? 'pending';
                  final adminReply = data['adminReply'] as String?;
                  final createdAt = data['createdAt'] as Timestamp?;
                  final timeAgo = createdAt != null ? _formatTimeAgo(createdAt.toDate()) : '';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: status == 'resolved'
                            ? const Color(0xFF43A047).withAlpha(20)
                            : status == 'replied'
                                ? const Color(0xFF42A5F5).withAlpha(20)
                                : const Color(0xFFFFA726).withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        status == 'resolved'
                            ? Icons.check_circle_rounded
                            : status == 'replied'
                                ? Icons.reply_rounded
                                : Icons.pending_actions_rounded,
                        color: status == 'resolved'
                            ? const Color(0xFF43A047)
                            : status == 'replied'
                                ? const Color(0xFF42A5F5)
                                : const Color(0xFFFFA726),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      email,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                          if (adminReply != null && adminReply.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF42A5F5).withAlpha(10),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF42A5F5).withAlpha(30)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.reply_rounded, size: 14, color: Color(0xFF42A5F5)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      adminReply,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF42A5F5)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (timeAgo.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                timeAgo,
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.black26),
                              ),
                            ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, size: 20, color: isDark ? Colors.white38 : Colors.black38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) async {
                        if (value == 'resolve') {
                          await docs[index].reference.update({'status': 'resolved'});
                        } else if (value == 'reply') {
                          _showReplyDialog(context, docs[index].reference, docs[index].id, data);
                        } else if (value == 'delete') {
                          await docs[index].reference.delete();
                        }
                      },
                      itemBuilder: (ctx) => [
                        if (status != 'resolved')
                          const PopupMenuItem(value: 'resolve', child: Text('Mark Resolved')),
                        const PopupMenuItem(value: 'reply', child: Text('Reply')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Color(0xFFE53935)))),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showReplyDialog(BuildContext context, DocumentReference feedbackRef, String feedbackId, Map<String, dynamic> feedbackData) {
    final controller = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.reply_rounded, color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Reply to Feedback')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                feedbackData['message'] ?? '',
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(180)),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your reply...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final replyText = controller.text.trim();
              if (replyText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reply')),
                );
                return;
              }
              Navigator.pop(ctx);

              try {
                final userUid = feedbackData['uid'] as String? ?? '';
                final userEmail = feedbackData['email'] as String? ?? '';
                final notificationService = context.read<NotificationService>();

                await feedbackRef.update({
                  'adminReply': replyText,
                  'adminReplyAt': FieldValue.serverTimestamp(),
                  'status': 'replied',
                });

                if (userUid.isNotEmpty) {
                  await notificationService.sendNotificationToUser(
                    targetUid: userUid,
                    title: 'Admin replied to your feedback',
                    body: replyText,
                    data: {'type': 'feedback_reply', 'feedbackId': feedbackId},
                  );
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reply sent to $userEmail'),
                      backgroundColor: const Color(0xFF43A047),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to send reply: $e'),
                      backgroundColor: const Color(0xFFE53935),
                    ),
                  );
                }
              }
            },
            child: const Text('Send Reply', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
