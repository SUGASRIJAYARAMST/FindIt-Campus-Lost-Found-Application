import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String location;
  final DateTime? itemDate;
  final String imageUrl;
  final String contactNumber;
  final String type;
  final String status;
  final String createdBy;
  final String createdByUid;
  final DateTime? createdAt;
  final String? claimedBy;
  final DateTime? claimedAt;

  ItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    this.itemDate,
    this.imageUrl = '',
    required this.contactNumber,
    required this.type,
    this.status = 'lost',
    required this.createdBy,
    required this.createdByUid,
    this.createdAt,
    this.claimedBy,
    this.claimedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'location': location,
      'itemDate': itemDate != null ? Timestamp.fromDate(itemDate!) : null,
      'imageUrl': imageUrl,
      'contactNumber': contactNumber,
      'type': type,
      'status': status,
      'createdBy': createdBy,
      'createdByUid': createdByUid,
      'createdAt': FieldValue.serverTimestamp(),
      'claimedBy': claimedBy,
      'claimedAt': claimedAt != null ? Timestamp.fromDate(claimedAt!) : null,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? '',
      description: map['description'] as String? ?? '',
      location: map['location'] as String? ?? '',
      itemDate: _parseDateTime(map['itemDate']),
      imageUrl: map['imageUrl'] as String? ?? '',
      contactNumber: map['contactNumber'] as String? ?? '',
      type: map['type'] as String? ?? 'lost',
      status: (map['status'] as String? ?? 'lost') == 'open' ? 'lost' : (map['status'] as String? ?? 'lost'),
      createdBy: map['createdBy'] as String? ?? '',
      createdByUid: map['createdByUid'] as String? ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      claimedBy: map['claimedBy'] as String?,
      claimedAt: _parseDateTime(map['claimedAt']),
    );
  }

  ItemModel copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? location,
    DateTime? itemDate,
    String? imageUrl,
    String? contactNumber,
    String? type,
    String? status,
    String? createdBy,
    String? createdByUid,
    DateTime? createdAt,
    String? claimedBy,
    DateTime? claimedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      location: location ?? this.location,
      itemDate: itemDate ?? this.itemDate,
      imageUrl: imageUrl ?? this.imageUrl,
      contactNumber: contactNumber ?? this.contactNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdByUid: createdByUid ?? this.createdByUid,
      createdAt: createdAt ?? this.createdAt,
      claimedBy: claimedBy ?? this.claimedBy,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'lost':
        return 'Lost';
      case 'open':
        return type == 'lost' ? 'Lost' : 'Found';
      case 'matched':
        return 'Matched';
      case 'recovered':
        return 'Recovered';
      case 'found':
        return 'Found';
      case 'claimed':
        return 'Claimed';
      case 'returned':
        return 'Returned';
      default:
        return status;
    }
  }

  String get typeDisplay => type == 'lost' ? 'Lost Item' : 'Found Item';
}
