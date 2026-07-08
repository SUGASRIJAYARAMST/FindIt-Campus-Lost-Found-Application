import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class FirebaseServiceProviders {
  final AuthService authService;
  final FirestoreService firestoreService;

  FirebaseServiceProviders({
    required this.authService,
    required this.firestoreService,
  });
}

class FirebaseServicesNotifier extends ChangeNotifier {
  final AuthService authService;
  final FirestoreService firestoreService;

  FirebaseServicesNotifier({
    required this.authService,
    required this.firestoreService,
  });
}
