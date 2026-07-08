import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/routes/app_router.dart';
import '../../../domain/models/user_model.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    if (authProvider.user != null) {
      userProvider.fetchUserData(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authProvider.user;
    final userModel = userProvider.userModel;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09131F) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(loc.profile),
        centerTitle: true,
        leading: _buildThemeIconButton(context, themeProvider),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: loc.signOut,
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: userProvider.isLoading && userModel == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileHeader(context, theme, isDark, user, userModel, userProvider),
                  const SizedBox(height: 24),
                  _buildInfoSection(context, theme, isDark, userModel, user),
                  const SizedBox(height: 24),
                  _buildStatsSection(context, theme, isDark, userModel),
                  const SizedBox(height: 24),
                  _buildReferralSection(context, theme, isDark, userModel),
                  const SizedBox(height: 24),
                  _buildActionsSection(context, theme, isDark, userModel),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    dynamic user,
    UserModel? userModel,
    UserProvider userProvider,
  ) {
    final loc = AppLocalizations.of(context)!;
    final name = userModel?.name ?? user.displayName ?? 'Student';
    final photoUrl = userModel?.profileImage ?? user.photoURL;
    final badge = userModel?.badge ?? loc.rookie;

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
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFF42A5F5),
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? CachedNetworkImageProvider(photoUrl) : null,
                onBackgroundImageError: (photoUrl != null && photoUrl.isNotEmpty) ? (_, _) {} : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'S', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 36))
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _changeProfilePicture(context, userProvider),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0D47A1), size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withAlpha(160),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFF4FC3F7), size: 16),
                const SizedBox(width: 6),
                Text(badge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, ThemeData theme, bool isDark, UserModel? userModel, dynamic user) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2636) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, right: 12),
              child: GestureDetector(
                onTap: () => _showEditProfileDialog(context, userModel),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit_rounded, color: theme.colorScheme.primary, size: 16),
                ),
              ),
            ),
          ),
          _buildInfoTile(
            theme: theme,
            isDark: isDark,
            icon: Icons.person_outline_rounded,
            title: loc.fullName,
            value: userModel?.name ?? loc.notSet,
          ),
          _buildInfoTile(
            theme: theme,
            isDark: isDark,
            icon: Icons.mail_outline_rounded,
            title: loc.email,
            value: userModel != null && userModel.email.isNotEmpty ? userModel.email : (user.email ?? loc.notSet),
          ),
          _buildInfoTile(
            theme: theme,
            isDark: isDark,
            icon: Icons.admin_panel_settings_outlined,
            title: loc.role,
            value: (userModel?.role ?? 'student').toUpperCase(),
          ),
          _buildInfoTile(
            theme: theme,
            isDark: isDark,
            icon: Icons.school_outlined,
            title: loc.department,
            value: userModel?.department ?? loc.notSet,
          ),
          _buildInfoTile(
            theme: theme,
            isDark: isDark,
            icon: Icons.phone_outlined,
            title: loc.phone,
            value: userModel?.phone ?? loc.notSet,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          subtitle: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 72,
            color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
          ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, ThemeData theme, bool isDark, UserModel? userModel) {
    final loc = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme: theme,
            isDark: isDark,
            icon: Icons.star_rounded,
            value: '${userModel?.rewardPoints ?? 0}',
            label: loc.points,
            color: const Color(0xFFFFD54F),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme: theme,
            isDark: isDark,
            icon: Icons.emoji_events_rounded,
            value: userModel?.badge ?? loc.rookie,
            label: loc.badge,
            color: const Color(0xFF4FC3F7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralSection(BuildContext context, ThemeData theme, bool isDark, UserModel? userModel) {
    final loc = AppLocalizations.of(context)!;
    final referralCode = userModel?.referralCode ?? '';
    if (referralCode.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2636) : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.redeem_rounded, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.yourReferralCode,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Text(
                      loc.shareReferralCode,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withAlpha(30)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    referralCode,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: referralCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.copiedToClipboard),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Share.share(
                      'Join FindIt campus lost & found app! Use my referral code: $referralCode\n\nDownload now and enter code during registration to get bonus points!',
                      subject: 'FindIt Referral Code',
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.people_outline_rounded, size: 16, color: isDark ? Colors.white38 : Colors.black38),
              const SizedBox(width: 6),
              Text(
                '${userModel?.referralCount ?? 0} ${loc.friendsReferred}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, ThemeData theme, bool isDark, UserModel? userModel) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildActionButton(
          context: context,
          theme: theme,
          isDark: isDark,
          icon: Icons.edit_rounded,
          title: loc.editProfile,
          subtitle: loc.updateInfo,
          onTap: () => _showEditProfileDialog(context, userModel),
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          context: context,
          theme: theme,
          isDark: isDark,
          icon: Icons.photo_camera_rounded,
          title: loc.changePhoto,
          subtitle: loc.uploadPhoto,
          onTap: () => _changeProfilePicture(context, context.read<UserProvider>()),
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          context: context,
          theme: theme,
          isDark: isDark,
          icon: Icons.settings_outlined,
          title: loc.settings,
          subtitle: loc.appPrefs,
          onTap: () => Navigator.pushNamed(context, AppRouter.settings),
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          context: context,
          theme: theme,
          isDark: isDark,
          icon: Icons.delete_forever_rounded,
          title: 'Delete Account',
          subtitle: 'Permanently remove your data',
          isDestructive: true,
          onTap: () => _handleDeleteAccount(context),
        ),
      ],
    );
  }

  Widget _buildThemeIconButton(BuildContext context, ThemeProvider themeProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(40),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: isDark ? const Color(0xFFFFD54F) : Colors.white,
          size: 20,
        ),
      ),
      tooltip: isDark ? 'Light Mode' : 'Dark Mode',
      onPressed: () {
        themeProvider.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDestructive ? const Color(0xFFE53935).withAlpha(20) : theme.colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? const Color(0xFFE53935) : theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDestructive ? const Color(0xFFE53935) : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 2),
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
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white24 : Colors.black26,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeProfilePicture(BuildContext context, UserProvider userProvider) async {
    final loc = AppLocalizations.of(context)!;
    final currentPhotoUrl = userProvider.userModel?.profileImage;
    final hasPhoto = currentPhotoUrl != null && currentPhotoUrl.isNotEmpty;

    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: Text(loc.camera),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(loc.gallery),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              if (hasPhoto)
                ListTile(
                  leading: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFE53935)),
                  title: Text(loc.removePhoto, style: const TextStyle(color: Color(0xFFE53935))),
                  onTap: () => Navigator.pop(ctx, null),
                ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted) return;

    if (source == null) {
      final authProvider = context.read<AuthProvider>();
      final uid = authProvider.user?.uid;
      if (uid == null) return;

      await userProvider.removeProfileImage(uid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.profileRemoved)),
        );
      }
      return;
    }

    // Request permission before picking
    final hasPermission = await _requestImagePermission(source);
    if (!hasPermission || !context.mounted) return;

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 80);
      if (image == null || !context.mounted) return;

      final bytes = await image.readAsBytes();
      if (!context.mounted) return;
      final authProvider = context.read<AuthProvider>();
      final uid = authProvider.user?.uid;
      if (uid == null) return;

      await userProvider.uploadProfileImage(
        uid: uid,
        fileName: 'profile_$uid.jpg',
        fileBytes: bytes,
      );

      if (context.mounted) {
        if (userProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userProvider.errorMessage!),
              backgroundColor: const Color(0xFFE53935),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.profileUpdated)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  Future<bool> _requestImagePermission(ImageSource source) async {
    Permission permission;
    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      permission = Permission.photos;
    }

    var status = await permission.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      _showPermissionDeniedDialog();
      return false;
    }

    status = await permission.request();

    if (status.isGranted) return true;

    if (source == ImageSource.gallery && status.isDenied) {
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) return true;
    }

    // Permission denied — handle UI feedback
    _handlePermissionDenied(source, status);
    return false;
  }

  void _handlePermissionDenied(ImageSource source, PermissionStatus status) {
    if (!context.mounted) return;

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(source == ImageSource.camera
              ? 'Camera permission is required to take photos'
              : 'Gallery permission is required to select photos'),
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.photo_library_outlined, size: 48, color: Color(0xFF1565C0)),
        title: const Text('Permission Required'),
        content: const Text(
          'Camera and gallery permissions are needed to change your profile picture. Please enable them in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserModel? userModel) {
    final loc = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: userModel?.name ?? '');
    final deptController = TextEditingController(text: userModel?.department ?? '');
    final phoneController = TextEditingController(text: userModel?.phone ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(loc.editProfile),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: loc.fullName,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: deptController,
                decoration: InputDecoration(
                  labelText: loc.department,
                  prefixIcon: const Icon(Icons.school_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: loc.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final userProvider = context.read<UserProvider>();
              final uid = authProvider.user?.uid;
              if (uid == null) return;

              final success = await userProvider.updateProfile(
                uid: uid,
                name: nameController.text.trim(),
                department: deptController.text.trim(),
                phone: phoneController.text.trim(),
              );

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? loc.profileUpdateSuccess : loc.profileUpdateFail),
                    backgroundColor: success ? null : const Color(0xFFE53935),
                  ),
                );
              }
            },
            child: Text(loc.saveChanges, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(loc.signOut),
        content: Text(loc.areYouSureSignOut),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.signOut, style: const TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirmed == true) {
      context.read<UserProvider>().clearUserData();
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.login,
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account'),
        content: const Text('This will permanently delete your account and all data. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final success = await authProvider.deleteAccount();

    if (success) {
      userProvider.clearUserData();
    }

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.login,
        (route) => false,
      );
    }
  }
}
