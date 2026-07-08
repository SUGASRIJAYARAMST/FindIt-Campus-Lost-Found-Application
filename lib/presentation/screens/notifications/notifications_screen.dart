import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/routes/app_router.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final uid = context.read<AuthProvider>().user?.uid ?? '';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09131F) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, size: 22),
            tooltip: 'Mark all read',
            onPressed: () => _markAllRead(uid),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('uid', isEqualTo: uid)
            .snapshots()
            .handleError((error) {
          debugPrint('Notifications stream error: $error');
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey.withAlpha(80)),
                  const SizedBox(height: 16),
                  Text('Unable to load notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_rounded, size: 64, color: Colors.grey.withAlpha(80)),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                  const SizedBox(height: 6),
                  Text('You\'ll see updates about your items here', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                ],
              ),
            );
          }

          final docs = [...snapshot.data!.docs];
          docs.sort((a, b) {
            final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final body = data['body'] ?? '';
              final type = data['type'] ?? '';
              final read = data['read'] ?? false;
              final createdAt = data['createdAt'] as Timestamp?;
              final timeAgo = createdAt != null ? _formatTimeAgo(createdAt.toDate()) : '';

              return Dismissible(
                key: Key(docs[index].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) => docs[index].reference.delete(),
                child: GestureDetector(
                  onTap: () {
                    if (!read) docs[index].reference.update({'read': true});
                    if (type == 'chat_message') {
                      final chatId = data['chatId'] as String? ?? '';
                      final senderId = data['senderId'] as String? ?? '';
                      final itemName = data['itemName'] as String? ?? '';
                      if (chatId.isNotEmpty) {
                        Navigator.pushNamed(context, AppRouter.conversation, arguments: {
                          'chatId': chatId,
                          'otherUid': senderId,
                          'itemName': itemName.isNotEmpty ? itemName : 'Chat',
                        });
                      }
                    } else {
                      _showNotificationDialog(context, title, body, type, timeAgo, isDark, docs[index].reference, theme);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? read ? const Color(0xFF152030) : const Color(0xFF1A2636)
                          : read ? const Color(0xFFF8F9FA) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: read
                            ? Colors.transparent
                            : theme.colorScheme.primary.withAlpha(30),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getIconColor(type).withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_getIcon(type), color: _getIconColor(type), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                      ),
                                    ),
                                  ),
                                  if (!read)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF42A5F5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                timeAgo,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white30 : Colors.black26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showNotificationDialog(BuildContext context, String title, String body, String type, String timeAgo, bool isDark, DocumentReference ref, ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getIconColor(type).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(type), color: _getIconColor(type), size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              timeAgo,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white30 : Colors.black26,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle(color: isDark ? Colors.white54 : Colors.black45)),
          ),
          TextButton(
            onPressed: () async {
              await ref.delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _markAllRead(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('uid', isEqualTo: uid)
          .get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['read'] != true) {
          await doc.reference.update({'read': true});
        }
      }
    } catch (e) {
      debugPrint('Mark all read failed: $e');
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'match': return Icons.search_rounded;
      case 'claim': return Icons.check_circle_outline_rounded;
      case 'status_update': return Icons.update_rounded;
      case 'reward': return Icons.star_rounded;
      case 'system': return Icons.info_outline_rounded;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'match': return const Color(0xFF42A5F5);
      case 'claim': return const Color(0xFF43A047);
      case 'status_update': return const Color(0xFFFFA726);
      case 'reward': return const Color(0xFFFFD54F);
      case 'system': return const Color(0xFF78909C);
      default: return const Color(0xFF42A5F5);
    }
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
