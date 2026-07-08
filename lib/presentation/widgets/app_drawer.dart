import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/routes/app_router.dart';
import '../../l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = authProvider.user;
    final userModel = userProvider.userModel;

    final name = userModel?.name ?? user?.displayName ?? user?.email?.split('@').first ?? 'Student';
    final email = userModel?.email ?? user?.email ?? '';
    final photoUrl = userModel?.profileImage ?? user?.photoURL;
    final badge = userModel?.badge ?? loc.rookie;
    final points = userModel?.rewardPoints ?? 0;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(context, theme, isDark, name, email, photoUrl, badge, points),
            const SizedBox(height: 4),
            Expanded(
              child:               ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.home_rounded,
                    title: loc.home,
                    route: AppRouter.home,
                    isActive: ModalRoute.of(context)?.settings.name == AppRouter.home,
                  ),
                  _buildMenuItem(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.list_alt_rounded,
                    title: loc.myReports,
                    route: AppRouter.myReports,
                  ),
                  _buildMenuItem(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.history_rounded,
                    title: loc.reportHistory,
                    route: AppRouter.reportHistory,
                  ),
                  _buildMenuItem(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.favorite_rounded,
                    title: loc.favorites,
                    route: AppRouter.favorites,
                  ),
                  _buildMenuItem(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.archive_rounded,
                    title: loc.archive,
                    route: AppRouter.archive,
                  ),
                  _buildMenuItem(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Messages',
                    route: AppRouter.chatList,
                    badge: context.watch<ChatProvider>().totalUnread,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Divider(color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(10)),
                  ),
                  if (authProvider.isAdmin)
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      isDark: isDark,
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Admin Dashboard',
                      route: AppRouter.adminDashboard,
                    ),
                  if (authProvider.isAdmin)
                    const SizedBox(height: 4),
                  _buildMenuItem(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.settings_rounded,
                    title: loc.settings,
                    route: AppRouter.settings,
                  ),
                  _buildMenuItem(
                    context: context,
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.logout_rounded,
                    title: loc.logout,
                    route: null,
                    isLogout: true,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String name,
    String email,
    String? photoUrl,
    String badge,
    int points,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0B1929), const Color(0xFF111D2E)]
              : [const Color(0xFF0D47A1), const Color(0xFF1565C0)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: Colors.white.withAlpha(200), size: 24),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(height: 4),
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFF42A5F5),
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? CachedNetworkImageProvider(photoUrl) : null,
            onBackgroundImageError: (photoUrl != null && photoUrl.isNotEmpty) ? (_, _) {} : null,
            child: (photoUrl == null || photoUrl.isEmpty)
                ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'S', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24))
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withAlpha(160),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniBadge(Icons.emoji_events_rounded, badge, const Color(0xFF4FC3F7)),
              const SizedBox(width: 10),
              _buildMiniBadge(Icons.star_rounded, '$points pts', const Color(0xFFFFD54F)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    String? route,
    bool isActive = false,
    bool isLogout = false,
    int badge = 0,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isLogout
              ? const Color(0xFFE53935).withAlpha(20)
              : isActive
                  ? theme.colorScheme.primary.withAlpha(20)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isLogout
              ? const Color(0xFFE53935)
              : isActive
                  ? theme.colorScheme.primary
                  : isDark
                      ? Colors.white54
                      : Colors.black54,
          size: 22,
        ),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isLogout
                  ? const Color(0xFFE53935)
                  : isActive
                      ? theme.colorScheme.primary
                      : isDark
                          ? Colors.white70
                          : Colors.black87,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
          if (badge > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: const BoxDecoration(
                color: Color(0xFF43A047),
                shape: BoxShape.circle,
              ),
              child: Text(
                badge > 99 ? '99+' : '$badge',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        if (isLogout) {
          _handleLogout(context);
        } else {
          Navigator.pop(context);
          if (route != null && ModalRoute.of(context)?.settings.name != route) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.pushNamed(context, route);
              }
            });
          }
        }
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    final loc = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(loc.signOut),
        content: Text(loc.areYouSureSignOut),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.signOut, style: const TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    userProvider.clearUserData();
    await authProvider.signOut();
  }
}
