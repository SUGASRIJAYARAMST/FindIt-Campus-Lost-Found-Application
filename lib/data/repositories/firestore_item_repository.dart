import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/item_model.dart';

class FirestoreItemRepository {
  final CollectionReference _items = FirebaseFirestore.instance.collection('items');

  Future<void> addItem(ItemModel item) async {
    await _items.doc(item.id).set(item.toMap());
  }

  Stream<List<ItemModel>> itemsStream() {
    return _items.snapshots().map((snapshot) {
      return snapshot.docs.map((d) => ItemModel.fromMap(d.data() as Map<String, dynamic>)).toList();
    });
  }
}
