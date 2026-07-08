import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference collection(String path) => _firestore.collection(path);

  Stream<List<Map<String, dynamic>>> collectionStream(String path) {
    return collection(path).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    });
  }

  Future<DocumentSnapshot> document(String path, String id) async {
    return collection(path).doc(id).get();
  }

  Future<void> setData(
    String path,
    String id,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    await collection(path).doc(id).set(data, SetOptions(merge: merge));
  }

  Future<void> addData(String path, Map<String, dynamic> data) async {
    await collection(path).add(data);
  }

  Future<void> deleteData(String path, String id) async {
    await collection(path).doc(id).delete();
  }

  Future<void> seedAdmin() async {
    const adminUid = 'KoLpnYljUOPzuJlgMKyzwTsEoDr2';
    final doc = await collection('users').doc(adminUid).get();
    if (!doc.exists) {
      await collection('users').doc(adminUid).set({
        'uid': adminUid,
        'name': 'Sugasrijayaram S T',
        'email': 'sugasrijayaramst@gmail.com',
        'department': 'admin',
        'phone': '9043035295',
        'role': 'admin',
        'profileImage': '',
        'rewardPoints': 100,
        'badge': 'Campus Hero',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
