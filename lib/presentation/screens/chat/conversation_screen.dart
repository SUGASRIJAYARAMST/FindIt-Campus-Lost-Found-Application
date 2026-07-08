import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../domain/models/chat_message.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final ChatProvider _chatProvider;
  String _chatId = '';
  String _itemName = '';
  int _prevMessageCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final newChatId = args?['chatId'] ?? '';
    _itemName = args?['itemName'] ?? '';

    if (newChatId != _chatId) {
      _chatId = newChatId;
      _chatProvider = context.read<ChatProvider>();
      _chatProvider.startListeningMessages(_chatId);

      final uid = context.read<AuthProvider>().user?.uid ?? '';
      _chatProvider.markAsRead(_chatId, uid);

      _scrollToBottom(immediate: true);
    }
  }

  void _scrollToBottom({bool immediate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: immediate ? 50 : 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _chatProvider.stopListeningMessages();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final uid = authProvider.user?.uid ?? '';
    final name = userProvider.userModel?.name.isNotEmpty == true
        ? userProvider.userModel!.name
        : (authProvider.user?.displayName ?? authProvider.user?.email ?? 'User');

    _chatProvider.sendMessage(
      chatId: _chatId,
      senderId: uid,
      senderName: name,
      text: text,
    );
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUid = context.read<AuthProvider>().user?.uid ?? '';
    final chatProvider = context.watch<ChatProvider>();
    final messages = chatProvider.messages;

    if (messages.length > _prevMessageCount) {
      _scrollToBottom();
    }
    _prevMessageCount = messages.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF09131F) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _itemName.isNotEmpty ? _itemName : 'Chat',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              messages.isNotEmpty ? '${messages.length} messages' : 'Start conversation',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              _chatProvider.startListeningMessages(_chatId);
              final uid = context.read<AuthProvider>().user?.uid ?? '';
              _chatProvider.markAsRead(_chatId, uid);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey.withAlpha(80)),
                        const SizedBox(height: 12),
                        Text(
                          'Say hello!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start the conversation about this item',
                          style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUid;
                      final showTime = index == messages.length - 1 ||
                          (index < messages.length - 1 &&
                              messages[index].senderId != messages[index + 1].senderId);
                      return _buildMessage(msg, isMe, showTime, theme, isDark);
                    },
                  ),
          ),
          _buildInputBar(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg, bool isMe, bool showTime, ThemeData theme, bool isDark) {
    final time = msg.timestamp != null
        ? '${msg.timestamp!.hour.toString().padLeft(2, '0')}:${msg.timestamp!.minute.toString().padLeft(2, '0')}'
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe
                    ? theme.colorScheme.primary
                    : isDark
                        ? const Color(0xFF1A2636)
                        : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 15 : 5),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 15,
                  color: isMe
                      ? Colors.white
                      : isDark
                          ? Colors.white70
                          : Colors.black87,
                ),
              ),
            ),
            if (showTime) ...[
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(fontSize: 10, color: isDark ? Colors.white24 : Colors.black26),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      msg.read ? Icons.done_all_rounded : Icons.done_rounded,
                      size: 14,
                      color: msg.read ? theme.colorScheme.primary : (isDark ? Colors.white24 : Colors.black26),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1B2A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 5),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(8) : const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black26),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
