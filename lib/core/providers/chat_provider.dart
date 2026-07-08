import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_room.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService chatService;

  List<ChatRoom> _chatRooms = [];
  List<ChatMessage> _messages = [];
  int _totalUnread = 0;
  StreamSubscription<List<ChatRoom>>? _roomsSub;
  StreamSubscription<List<ChatMessage>>? _messagesSub;
  StreamSubscription<int>? _unreadSub;

  ChatProvider({required this.chatService});

  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get messages => _messages;
  int get totalUnread => _totalUnread;

  void startListeningRooms(String uid) {
    _roomsSub?.cancel();
    _roomsSub = chatService.getChatRooms(uid).listen((rooms) async {
      final enriched = await _enrichRooms(rooms, uid);
      _chatRooms = enriched;
      notifyListeners();
    });
  }

  Future<List<ChatRoom>> _enrichRooms(List<ChatRoom> rooms, String currentUid) async {
    final needsEnrichment = rooms.where((r) =>
        r.otherUserName.isEmpty ||
        r.otherUserEmail.isEmpty ||
        r.itemDescription.isEmpty ||
        r.itemDate == null).toList();

    if (needsEnrichment.isEmpty) return rooms;

    final results = List<ChatRoom>.from(rooms);

    for (final room in needsEnrichment) {
      try {
        final idx = results.indexWhere((r) => r.id == room.id);
        if (idx == -1) continue;

        String name = room.otherUserName;
        String email = room.otherUserEmail;
        String desc = room.itemDescription;
        DateTime? date = room.itemDate;

        if (name.isEmpty || email.isEmpty) {
          final otherUid = room.participants.firstWhere(
            (p) => p != currentUid,
            orElse: () => '',
          );
          if (otherUid.isNotEmpty) {
            final userDoc = await FirebaseFirestore.instance.collection('users').doc(otherUid).get();
            if (userDoc.exists) {
              final data = userDoc.data()!;
              if (name.isEmpty) name = data['name'] as String? ?? '';
              if (email.isEmpty) email = data['email'] as String? ?? '';
            }
          }
        }

        if (desc.isEmpty && room.itemId.isNotEmpty) {
          final itemDoc = await FirebaseFirestore.instance.collection('items').doc(room.itemId).get();
          if (itemDoc.exists) {
            final data = itemDoc.data()!;
            desc = data['description'] as String? ?? '';
            final rawDate = data['itemDate'];
            if (rawDate is Timestamp) date = rawDate.toDate();
          }
        }

        results[idx] = ChatRoom(
          id: room.id,
          participants: room.participants,
          lastMessage: room.lastMessage,
          lastMessageTime: room.lastMessageTime,
          unreadCount: room.unreadCount,
          itemId: room.itemId,
          itemName: room.itemName,
          itemImage: room.itemImage,
          itemType: room.itemType,
          itemDescription: desc,
          itemDate: date,
          otherUserName: name,
          otherUserEmail: email,
          createdAt: room.createdAt,
        );

        // Write enriched fields back to Firestore so next load is instant
        await FirebaseFirestore.instance.collection('chats').doc(room.id).update({
          'otherUserName': name,
          'otherUserEmail': email,
          'itemDescription': desc,
          'itemDate': date != null ? Timestamp.fromDate(date) : null,
        });
      } catch (_) {}
    }

    return results;
  }

  void stopListeningRooms() {
    _roomsSub?.cancel();
    _roomsSub = null;
  }

  void startListeningMessages(String chatId) {
    _messagesSub?.cancel();
    _messagesSub = chatService.getMessages(chatId).listen((messages) {
      _messages = messages;
      notifyListeners();
    });
  }

  void stopListeningMessages() {
    _messagesSub?.cancel();
    _messagesSub = null;
  }

  void startListeningUnread(String uid) {
    _unreadSub?.cancel();
    _unreadSub = chatService.getTotalUnreadCount(uid).listen((total) {
      _totalUnread = total;
      notifyListeners();
    });
  }

  void stopListeningUnread() {
    _unreadSub?.cancel();
    _unreadSub = null;
  }

  Future<String> getOrCreateChatRoom({
    required String currentUid,
    required String otherUid,
    required String itemId,
    required String itemName,
    required String itemImage,
    required String itemType,
  }) async {
    return chatService.getOrCreateChatRoom(
      currentUid: currentUid,
      otherUid: otherUid,
      itemId: itemId,
      itemName: itemName,
      itemImage: itemImage,
      itemType: itemType,
    );
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    await chatService.sendMessage(
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      text: text,
    );
  }

  Future<void> markAsRead(String chatId, String uid) async {
    await chatService.markAsRead(chatId, uid);
  }

  @override
  void dispose() {
    stopListeningRooms();
    stopListeningMessages();
    stopListeningUnread();
    super.dispose();
  }
}
