import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../domain/models/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final adminProvider = context.watch<AdminProvider>();

    var displayUsers = _searchQuery.isEmpty
        ? adminProvider.users
        : adminProvider.searchUsers(_searchQuery);

    if (_filterStatus == 'active') {
      displayUsers = displayUsers.where((u) => !u.isBlocked).toList();
    } else if (_filterStatus == 'blocked') {
      displayUsers = displayUsers.where((u) => u.isBlocked).toList();
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09131F) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('User Management'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(theme, isDark),
          _buildFilterChips(theme, isDark, adminProvider),
          Expanded(
            child: adminProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayUsers.isEmpty
                    ? _buildEmptyState(theme, isDark)
                    : _buildUserList(displayUsers, adminProvider, theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, bool isDark, AdminProvider provider) {
    final total = provider.users.length;
    final activeCount = provider.users.where((u) => !u.isBlocked).length;
    final blockedCount = provider.users.where((u) => u.isBlocked).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: [
          _buildChip('All ($total)', _filterStatus == 'all', () {
            setState(() => _filterStatus = 'all');
          }, isDark),
          const SizedBox(width: 8),
          _buildChip('Active ($activeCount)', _filterStatus == 'active', () {
            setState(() => _filterStatus = 'active');
          }, isDark),
          const SizedBox(width: 8),
          _buildChip('Blocked ($blockedCount)', _filterStatus == 'blocked', () {
            setState(() => _filterStatus = 'blocked');
          }, isDark),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF42A5F5).withAlpha(25) : (isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF42A5F5).withAlpha(80) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF42A5F5) : (isDark ? Colors.white54 : Colors.black45),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search users...',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black26),
          prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white38 : Colors.black26, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? const Color(0xFF1A2636) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: theme.colorScheme.primary.withAlpha(100)),
          const SizedBox(height: 16),
          Text('No users found', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38)),
        ],
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users, AdminProvider provider, ThemeData theme, bool isDark) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: users.length,
      itemBuilder: (context, index) => _buildUserCard(users[index], provider, theme, isDark),
    );
  }

  Widget _buildUserCard(UserModel user, AdminProvider provider, ThemeData theme, bool isDark) {
    final isBlocked = user.isBlocked;

    return GestureDetector(
      onTap: () => _showUserDetailDialog(user, provider, theme, isDark),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2636) : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primary.withAlpha(30),
              backgroundImage: user.profileImage.isNotEmpty ? CachedNetworkImageProvider(user.profileImage) : null,
              child: user.profileImage.isEmpty
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: const Color(0xFFFFD54F)),
                      const SizedBox(width: 4),
                      Text(
                        '${user.rewardPoints} pts',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white38 : Colors.black38),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isBlocked ? const Color(0xFFE53935).withAlpha(25) : const Color(0xFF43A047).withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isBlocked ? 'Blocked' : 'Active',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isBlocked ? const Color(0xFFE53935) : const Color(0xFF43A047),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'detail', child: Text('View Details')),
                if (!isBlocked)
                  const PopupMenuItem(value: 'block', child: Text('Block User')),
                if (isBlocked)
                  const PopupMenuItem(value: 'unblock', child: Text('Unblock User')),
                const PopupMenuItem(value: 'delete', child: Text('Delete User', style: TextStyle(color: Color(0xFFE53935)))),
              ],
              onSelected: (value) {
                if (value == 'detail') {
                  _showUserDetailDialog(user, provider, theme, isDark);
                } else {
                  _handleUserAction(value, user, provider);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetailDialog(UserModel user, AdminProvider provider, ThemeData theme, bool isDark) {
    final userItems = provider.items.where((i) => i.createdByUid == user.uid).length;
    final lostItems = provider.items.where((i) => i.createdByUid == user.uid && i.type == 'lost').length;
    final foundItems = provider.items.where((i) => i.createdByUid == user.uid && i.type == 'found').length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withAlpha(30),
              backgroundImage: user.profileImage.isNotEmpty ? CachedNetworkImageProvider(user.profileImage) : null,
              child: user.profileImage.isEmpty
                  ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 16))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(user.email, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(Icons.school_outlined, 'Department', user.department.isNotEmpty ? user.department : 'Not set'),
            _buildDetailRow(Icons.phone_outlined, 'Phone', user.phone.isNotEmpty ? user.phone : 'Not set'),
            _buildDetailRow(Icons.star_rounded, 'Reward Points', '${user.rewardPoints}'),
            _buildDetailRow(Icons.emoji_events_rounded, 'Badge', user.badge),
            _buildDetailRow(Icons.redeem_rounded, 'Referral Code', user.referralCode.isNotEmpty ? user.referralCode : 'None'),
            _buildDetailRow(Icons.inventory_2_rounded, 'Items Posted', '$userItems (Lost: $lostItems, Found: $foundItems)'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: user.isBlocked ? const Color(0xFFE53935).withAlpha(20) : const Color(0xFF43A047).withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.isBlocked ? 'BLOCKED' : 'ACTIVE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: user.isBlocked ? const Color(0xFFE53935) : const Color(0xFF43A047),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleUserAction(user.isBlocked ? 'unblock' : 'block', user, provider);
            },
            child: Text(
              user.isBlocked ? 'Unblock' : 'Block',
              style: TextStyle(color: user.isBlocked ? const Color(0xFF43A047) : const Color(0xFFFFA726)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text('$label: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(String action, UserModel user, AdminProvider provider) {
    switch (action) {
      case 'block':
        _confirmAction('Block ${user.name}?', () async {
          final success = await provider.blockUser(user.uid);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? '${user.name} has been blocked' : 'Failed to block ${user.name}'),
                backgroundColor: success ? const Color(0xFF43A047) : const Color(0xFFE53935),
              ),
            );
          }
        });
        break;
      case 'unblock':
        _confirmAction('Unblock ${user.name}?', () async {
          final success = await provider.unblockUser(user.uid);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? '${user.name} has been unblocked' : 'Failed to unblock ${user.name}'),
                backgroundColor: success ? const Color(0xFF43A047) : const Color(0xFFE53935),
              ),
            );
          }
        });
        break;
      case 'delete':
        _confirmAction('Delete ${user.name}? This cannot be undone.', () async {
          final success = await provider.deleteUser(user.uid);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? 'User deleted' : 'Failed to delete user'),
                backgroundColor: success ? const Color(0xFF43A047) : const Color(0xFFE53935),
              ),
            );
          }
        });
        break;
    }
  }

  void _confirmAction(String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
