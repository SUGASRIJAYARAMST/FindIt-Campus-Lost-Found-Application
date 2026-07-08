import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/routes/app_router.dart';
import '../../../domain/models/chat_room.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid ?? '';
      context.read<ChatProvider>().startListeningRooms(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final currentUid = context.read<AuthProvider>().user?.uid ?? '';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09131F) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final uid = context.read<AuthProvider>().user?.uid ?? '';
          context.read<ChatProvider>().startListeningRooms(uid);
        },
        child: chatProvider.chatRooms.isEmpty
            ? _buildEmptyState(theme, isDark)
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: chatProvider.chatRooms.length,
                itemBuilder: (context, index) {
                  final room = chatProvider.chatRooms[index];
                  final otherUid = room.participants.firstWhere(
                    (p) => p != currentUid,
                    orElse: () => '',
                  );
                  final unread = room.unreadCount[currentUid] ?? 0;
                  return _buildChatTile(context, room, otherUid, unread, theme, isDark);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: theme.colorScheme.primary.withAlpha(150),
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Message someone about their reported item to start a conversation',
              style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildChatTile(BuildContext context, ChatRoom room, String otherUid, int unread, ThemeData theme, bool isDark) {
    final itemType = room.itemType;
    final itemColor = itemType == 'lost' ? const Color(0xFFE53935) : const Color(0xFF43A047);

    final displayName = room.otherUserName.isNotEmpty
        ? room.otherUserName
        : (room.otherUserEmail.isNotEmpty ? room.otherUserEmail : 'User');
    final subtitle = room.itemDescription.isNotEmpty ? room.itemDescription : (room.lastMessage.isNotEmpty ? room.lastMessage : 'Start conversation...');
    final itemDateStr = _formatDate(room.itemDate);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.conversation,
          arguments: {
            'chatId': room.id,
            'otherUid': otherUid,
            'itemName': room.itemName,
            'otherUserName': room.otherUserName,
            'otherUserEmail': room.otherUserEmail,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2636) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: unread > 0
              ? Border.all(color: theme.colorScheme.primary.withAlpha(40), width: 1.5)
              : null,
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: itemColor.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: room.itemImage.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        imageUrl: room.itemImage,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(color: itemColor.withAlpha(20)),
                        errorWidget: (_, _, _) => Icon(
                          itemType == 'lost' ? Icons.help_outline_rounded : Icons.check_circle_outline_rounded,
                          color: itemColor,
                          size: 24,
                        ),
                      ),
                    )
                  : Icon(
                      itemType == 'lost' ? Icons.help_outline_rounded : Icons.check_circle_outline_rounded,
                      color: itemColor,
                      size: 24,
                    ),
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
                          displayName,
                          style: TextStyle(
                            fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w700,
                            fontSize: 15,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: itemColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          itemType.toUpperCase(),
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: itemColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    room.itemName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                            color: unread > 0
                                ? (isDark ? Colors.white70 : Colors.black87)
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                        ),
                      ),
                      if (itemDateStr.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          itemDateStr,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (unread > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
