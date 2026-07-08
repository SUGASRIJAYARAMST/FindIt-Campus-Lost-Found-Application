import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static Future<FirebaseApp> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        return Firebase.initializeApp();
      }
      return Firebase.app();
    } on FirebaseException catch (e) {
      if (e.code == 'core/duplicate-app') {
        return Firebase.app();
      }
      rethrow;
    }
  }
}
