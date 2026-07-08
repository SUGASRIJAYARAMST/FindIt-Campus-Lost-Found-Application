import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/notification_service.dart';

class FeedbackManagementScreen extends StatefulWidget {
  const FeedbackManagementScreen({super.key});

  @override
  State<FeedbackManagementScreen> createState() => _FeedbackManagementScreenState();
}

class _FeedbackManagementScreenState extends State<FeedbackManagementScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09131F) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Feedback Management'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterChips(theme, isDark),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feedback')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(theme, isDark);
                }

                var docs = snapshot.data!.docs;

                if (_filterStatus != 'all') {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['status'] == _filterStatus;
                  }).toList();
                }

                if (docs.isEmpty) {
                  return _buildEmptyState(theme, isDark);
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  itemCount: docs.length,
                  itemBuilder: (context, index) => _buildFeedbackCard(docs[index], theme, isDark),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          _buildChip('All', _filterStatus == 'all', () {
            setState(() => _filterStatus = 'all');
          }, isDark),
          const SizedBox(width: 8),
          _buildChip('Pending', _filterStatus == 'pending', () {
            setState(() => _filterStatus = 'pending');
          }, isDark),
          const SizedBox(width: 8),
          _buildChip('Replied', _filterStatus == 'replied', () {
            setState(() => _filterStatus = 'replied');
          }, isDark),
          const SizedBox(width: 8),
          _buildChip('Resolved', _filterStatus == 'resolved', () {
            setState(() => _filterStatus = 'resolved');
          }, isDark),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF42A5F5).withAlpha(25)
              : isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.black.withAlpha(5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF42A5F5).withAlpha(80)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF42A5F5)
                : (isDark ? Colors.white54 : Colors.black45),
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
          Icon(Icons.feedback_outlined, size: 64, color: theme.colorScheme.primary.withAlpha(100)),
          const SizedBox(height: 16),
          Text(
            'No feedback yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'User feedback will appear here',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(DocumentSnapshot doc, ThemeData theme, bool isDark) {
    final data = doc.data() as Map<String, dynamic>;
    final email = data['email'] ?? 'Unknown';
    final message = data['message'] ?? '';
    final status = data['status'] ?? 'pending';
    final adminReply = data['adminReply'] as String?;
    final createdAt = data['createdAt'] as Timestamp?;
    final timeAgo = createdAt != null ? _formatTimeAgo(createdAt.toDate()) : '';

    final statusColor = status == 'resolved'
        ? const Color(0xFF43A047)
        : status == 'replied'
            ? const Color(0xFF42A5F5)
            : const Color(0xFFFFA726);

    final statusIcon = status == 'resolved'
        ? Icons.check_circle_rounded
        : status == 'replied'
            ? Icons.reply_rounded
            : Icons.pending_actions_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.black26),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 20, color: isDark ? Colors.white38 : Colors.black38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) => _handleAction(value, doc, data),
                  itemBuilder: (ctx) => [
                    if (status != 'resolved')
                      const PopupMenuItem(value: 'resolve', child: Text('Mark Resolved')),
                    const PopupMenuItem(value: 'reply', child: Text('Reply')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Color(0xFFE53935)))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            if (adminReply != null && adminReply.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF42A5F5).withAlpha(10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF42A5F5).withAlpha(30)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.reply_rounded, size: 16, color: Color(0xFF42A5F5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        adminReply,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF42A5F5)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleAction(String action, DocumentSnapshot doc, Map<String, dynamic> data) {
    switch (action) {
      case 'resolve':
        doc.reference.update({'status': 'resolved'});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Marked as resolved'), backgroundColor: Color(0xFF43A047)),
          );
        }
        break;
      case 'reply':
        _showReplyDialog(doc.reference, doc.id, data);
        break;
      case 'delete':
        _confirmDelete(doc.reference);
        break;
    }
  }

  void _showReplyDialog(DocumentReference ref, String feedbackId, Map<String, dynamic> data) {
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
                data['message'] ?? '',
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
                final userUid = data['uid'] as String? ?? '';
                final userEmail = data['email'] as String? ?? '';
                final notificationService = context.read<NotificationService>();

                await ref.update({
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

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reply sent to $userEmail'),
                      backgroundColor: const Color(0xFF43A047),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
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

  void _confirmDelete(DocumentReference ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Feedback'),
        content: const Text('Are you sure you want to delete this feedback?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.delete();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback deleted'), backgroundColor: Color(0xFF43A047)),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
