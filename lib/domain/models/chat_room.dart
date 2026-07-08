import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount;
  final String itemId;
  final String itemName;
  final String itemImage;
  final String itemType;
  final String itemDescription;
  final DateTime? itemDate;
  final String otherUserName;
  final String otherUserEmail;
  final DateTime? createdAt;

  ChatRoom({
    required this.id,
    required this.participants,
    this.lastMessage = '',
    this.lastMessageTime,
    this.unreadCount = const {},
    this.itemId = '',
    this.itemName = '',
    this.itemImage = '',
    this.itemType = '',
    this.itemDescription = '',
    this.itemDate,
    this.otherUserName = '',
    this.otherUserEmail = '',
    this.createdAt,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] as String? ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] as String? ?? '',
      lastMessageTime: map['lastMessageTime'] is Timestamp
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : map['lastMessageTime'] is DateTime
              ? map['lastMessageTime'] as DateTime
              : null,
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      itemId: map['itemId'] as String? ?? '',
      itemName: map['itemName'] as String? ?? '',
      itemImage: map['itemImage'] as String? ?? '',
      itemType: map['itemType'] as String? ?? '',
      itemDescription: map['itemDescription'] as String? ?? '',
      itemDate: map['itemDate'] is Timestamp
          ? (map['itemDate'] as Timestamp).toDate()
          : map['itemDate'] is DateTime
              ? map['itemDate'] as DateTime
              : null,
      otherUserName: map['otherUserName'] as String? ?? '',
      otherUserEmail: map['otherUserEmail'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': unreadCount,
      'itemId': itemId,
      'itemName': itemName,
      'itemImage': itemImage,
      'itemType': itemType,
      'itemDescription': itemDescription,
      'itemDate': itemDate != null ? Timestamp.fromDate(itemDate!) : null,
      'otherUserName': otherUserName,
      'otherUserEmail': otherUserEmail,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
