import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_room.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

class ChatService {
  final FirestoreService firestoreService;
  final NotificationService? notificationService;

  ChatService({required this.firestoreService, this.notificationService});

  Future<String> getOrCreateChatRoom({
    required String currentUid,
    required String otherUid,
    required String itemId,
    required String itemName,
    required String itemImage,
    required String itemType,
  }) async {
    final existing = await firestoreService
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .get();

    for (final doc in existing.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final participants = List<String>.from(data['participants'] ?? []);
      if (participants.contains(otherUid) && data['itemId'] == itemId) {
        return doc.id;
      }
    }

    String otherUserName = '';
    String otherUserEmail = '';
    String itemDescription = '';
    DateTime? itemDate;

    try {
      final otherUserDoc = await firestoreService.document('users', otherUid);
      if (otherUserDoc.exists) {
        final userData = otherUserDoc.data() as Map<String, dynamic>?;
        otherUserName = userData?['name'] as String? ?? '';
        otherUserEmail = userData?['email'] as String? ?? '';
      }
    } catch (_) {}

    try {
      final itemDoc = await firestoreService.document('items', itemId);
      if (itemDoc.exists) {
        final itemData = itemDoc.data() as Map<String, dynamic>?;
        itemDescription = itemData?['description'] as String? ?? '';
        final itemDateRaw = itemData?['itemDate'];
        if (itemDateRaw is Timestamp) {
          itemDate = itemDateRaw.toDate();
        }
      }
    } catch (_) {}

    final chatRef = firestoreService.collection('chats').doc();
    final chatRoom = ChatRoom(
      id: chatRef.id,
      participants: [currentUid, otherUid],
      itemId: itemId,
      itemName: itemName,
      itemImage: itemImage,
      itemType: itemType,
      itemDescription: itemDescription,
      itemDate: itemDate,
      otherUserName: otherUserName,
      otherUserEmail: otherUserEmail,
    );
    await chatRef.set(chatRoom.toMap());
    return chatRef.id;
  }

  Stream<List<ChatRoom>> getChatRooms(String uid) {
    return firestoreService
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      final rooms = snapshot.docs
          .map((doc) => ChatRoom.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
      rooms.sort((a, b) {
        final aTime = a.lastMessageTime ?? a.createdAt;
        final bTime = b.lastMessageTime ?? b.createdAt;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });
      return rooms;
    });
  }

  Stream<List<ChatMessage>> getMessages(String chatId) {
    return firestoreService
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final messageRef = firestoreService
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final message = ChatMessage(
      id: messageRef.id,
      senderId: senderId,
      senderName: senderName,
      text: text,
    );
    await messageRef.set(message.toMap());

    final chatDoc = await firestoreService.collection('chats').doc(chatId).get();
    final chatData = chatDoc.data() as Map<String, dynamic>?;
    final participants = List<String>.from(chatData?['participants'] ?? []);
    final unreadCount = Map<String, int>.from(chatData?['unreadCount'] ?? {});

    for (final pid in participants) {
      if (pid != senderId) {
        unreadCount[pid] = (unreadCount[pid] ?? 0) + 1;
      }
    }

    await firestoreService.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': unreadCount,
    });

    final itemName = chatData?['itemName'] as String? ?? '';

    for (final pid in participants) {
      if (pid != senderId && notificationService != null) {
        try {
          await notificationService!.sendNotificationToUser(
            targetUid: pid,
            title: 'Message from $senderName',
            body: text.length > 80 ? '${text.substring(0, 80)}...' : text,
            data: {
              'type': 'chat_message',
              'chatId': chatId,
              'senderId': senderId,
              'senderName': senderName,
              'itemName': itemName,
            },
          );
        } catch (e) {
          debugPrint('Chat notification error: $e');
        }
      }
    }
  }

  Future<void> markAsRead(String chatId, String uid) async {
    try {
      final unreadSnapshot = await firestoreService
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('read', isEqualTo: false)
          .get();

      for (final doc in unreadSnapshot.docs) {
        final data = doc.data();
        if (data['senderId'] != uid) {
          await doc.reference.update({'read': true});
        }
      }

      await firestoreService.collection('chats').doc(chatId).update({
        'unreadCount.$uid': 0,
      });
    } catch (e) {
      debugPrint('Mark as read error: $e');
    }
  }

  Stream<int> getTotalUnreadCount(String uid) {
    return firestoreService
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final unreadCount = Map<String, int>.from(data['unreadCount'] ?? {});
        total += (unreadCount[uid] ?? 0);
      }
      return total;
    });
  }
}
