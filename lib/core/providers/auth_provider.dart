import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/referral_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  final FirestoreService firestoreService;
  final ReferralService? referralService;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _errorField;
  bool _isAdmin = false;
  StreamSubscription<User?>? _authSub;

  AuthProvider({
    required this.authService,
    required this.firestoreService,
    this.referralService,
  }) {
    _user = authService.currentUser;
    _authSub = authService.authStateChanges().listen((u) {
      _user = u;
      if (u != null) {
        _checkAdminRole(u.uid);
      } else {
        _isAdmin = false;
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorField => _errorField;
  bool get isAdmin => _isAdmin;

  void clearError() {
    _errorMessage = null;
    _errorField = null;
    notifyListeners();
  }

  // Pending registration data — used by fallback if primary Firestore write fails
  String? _pendingName;
  String? _pendingEmail;
  String? _pendingDepartment;
  String? _pendingPhone;

  Future<void> _checkAdminRole(String uid) async {
    try {
      final doc = await firestoreService.document('users', uid);
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        _isAdmin = data['role'] == 'admin';
        notifyListeners();

        // Always try to fix missing fields
        final savedDept = (data['department'] as String? ?? '').trim();
        final savedPhone = (data['phone'] as String? ?? '').trim();
        final savedName = (data['name'] as String? ?? '').trim();

        final fixData = <String, dynamic>{};
        if (savedName.isEmpty && _pendingName != null && _pendingName!.trim().isNotEmpty) {
          fixData['name'] = _pendingName!.trim();
        }
        if (savedDept.isEmpty && _pendingDepartment != null && _pendingDepartment!.trim().isNotEmpty) {
          fixData['department'] = _pendingDepartment!.trim();
        }
        if (savedPhone.isEmpty && _pendingPhone != null && _pendingPhone!.trim().isNotEmpty) {
          fixData['phone'] = _pendingPhone!.trim();
        }
        if (fixData.isNotEmpty) {
          debugPrint('AuthProvider: Fixing missing fields: ${fixData.keys.toList()}');
          await firestoreService.setData('users', uid, fixData, merge: true);
        }
        _clearPendingData();
      } else {
        debugPrint('AuthProvider: User doc missing for $uid — creating fallback');
        await _createFallbackUserDoc(
          uid,
          name: _pendingName,
          email: _pendingEmail,
          department: _pendingDepartment,
          phone: _pendingPhone,
        );
        _clearPendingData();
      }
    } catch (e) {
      debugPrint('Error checking admin role: $e');
      _isAdmin = false;
    }
  }

  void _clearPendingData() {
    _pendingName = null;
    _pendingEmail = null;
    _pendingDepartment = null;
    _pendingPhone = null;
  }

  Future<void> _createFallbackUserDoc(String uid, {String? name, String? email, String? department, String? phone}) async {
    try {
      final authUser = authService.currentUser;
      if (authUser == null) return;

      final suffix = uid.length >= 4 ? uid.substring(0, 4).toUpperCase() : uid.toUpperCase();
      final generatedCode = 'FI$suffix${DateTime.now().millisecondsSinceEpoch % 10000}';

      // Prefer form data (from registration), fall back to Auth data
      // If name is empty, use empty string so the profile dialog prompts user
      final displayName = (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : (authUser.displayName?.trim().isNotEmpty == true
              ? authUser.displayName!.trim()
              : '');
      final displayEmail = (email != null && email.trim().isNotEmpty)
          ? email.trim()
          : authUser.email ?? '';
      final displayDept = department?.trim() ?? '';
      final displayPhone = phone?.trim() ?? '';

      final userData = <String, dynamic>{
        'uid': uid,
        'name': displayName,
        'email': displayEmail,
        'role': 'student',
        'profileImage': authUser.photoURL ?? '',
        'rewardPoints': 0,
        'badge': 'Good Helper',
        'referralCode': generatedCode,
        'referredBy': '',
        'referralCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (displayDept.isNotEmpty) userData['department'] = displayDept;
      if (displayPhone.isNotEmpty) userData['phone'] = displayPhone;

      // Retry up to 3 times
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          await firestoreService.setData('users', uid, userData, merge: true);
          debugPrint('AuthProvider: Fallback user doc created for $uid (attempt $attempt)');
          return;
        } catch (writeError) {
          debugPrint('AuthProvider: Fallback write attempt $attempt failed: $writeError');
          if (attempt < 3) {
            await Future.delayed(Duration(milliseconds: 500 * attempt));
          }
        }
      }
    } catch (e) {
      debugPrint('AuthProvider: Fallback doc creation failed: $e');
    }
  }

  Future<void> ensureAdminChecked() async {
    if (_user != null) {
      await _checkAdminRole(_user!.uid);
    }
  }

  Future<bool> checkBlockedStatus() async {
    try {
      if (_user == null) return false;
      final doc = await firestoreService.document('users', _user!.uid);
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String? ?? 'active';
        debugPrint('checkBlockedStatus: uid=${_user!.uid}, status=$status');
        return status == 'blocked';
      }
      // Doc doesn't exist yet — treat as not blocked (new user)
      debugPrint('checkBlockedStatus: doc does not exist for ${_user!.uid}');
      return false;
    } catch (e) {
      // On error, treat as not blocked to avoid locking out legitimate users
      debugPrint('checkBlockedStatus ERROR: $e');
      return false;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    _errorMessage = null;
    _errorField = null;
    _setLoading(true);
    try {
      await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Explicitly clear error on success
      _errorMessage = null;
      _errorField = null;
    } on FirebaseAuthException catch (e) {
      _errorField = _mapErrorField(e.code);
      _errorMessage = _mapAuthError(e.code);
    } catch (e) {
      debugPrint('Unexpected sign-in error: $e');
      _errorField = null;
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }

    // Auth state listener may have set _user even if an error was caught.
    // If user is non-null, sign-in actually succeeded — clear any stale error.
    if (_user != null) {
      _errorMessage = null;
      _errorField = null;
      notifyListeners();
    }
  }

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
    String? profileImageUrl,
    String? referralCode,
  }) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      final credential = await authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        throw Exception('Registration failed: no user returned.');
      }

      final suffix = uid.length >= 4 ? uid.substring(0, 4).toUpperCase() : uid.toUpperCase();
      final generatedCode = 'FI$suffix${DateTime.now().millisecondsSinceEpoch % 10000}';

      final userData = <String, dynamic>{
        'uid': uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': 'student',
        'profileImage': '',
        'rewardPoints': 0,
        'badge': 'Good Helper',
        'referralCode': generatedCode,
        'referredBy': referralCode ?? '',
        'referralCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Store pending data so fallback can use it if primary write fails
      _pendingName = name;
      _pendingEmail = email;
      _pendingDepartment = null;
      _pendingPhone = null;

      debugPrint('AuthProvider: Writing user doc to Firestore for uid=$uid');
      // Retry Firestore write up to 3 times
      bool writeSucceeded = false;
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          await firestoreService.setData('users', uid, userData, merge: true);
          debugPrint('AuthProvider: User doc written successfully for uid=$uid (attempt $attempt)');
          writeSucceeded = true;
          break;
        } catch (writeError) {
          debugPrint('AuthProvider: Firestore write attempt $attempt failed: $writeError');
          if (attempt < 3) {
            await Future.delayed(Duration(milliseconds: 500 * attempt));
          }
        }
      }

      if (!writeSucceeded) {
        // Primary write failed — let fallback handle it via _authSub listener
        debugPrint('AuthProvider: All Firestore writes failed — fallback will create doc with form data');
      }

      // Verify name was saved — retry if missing (name is critical)
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        final verifyDoc = await firestoreService.document('users', uid);
        if (verifyDoc.exists && verifyDoc.data() != null) {
          final verifyData = verifyDoc.data() as Map<String, dynamic>;
          final savedName = (verifyData['name'] as String? ?? '').trim();
          if (name.trim().isNotEmpty && savedName.isEmpty) {
            debugPrint('AuthProvider: Name missing after write — retrying');
            await firestoreService.setData('users', uid, {
              'name': name.trim(),
            }, merge: true);
          }
        }
      } catch (e) {
        debugPrint('AuthProvider: Verification retry failed: $e');
      }
      _clearPendingData();

      if (referralCode != null && referralCode.trim().isNotEmpty && referralService != null) {
        // Delay to ensure user doc is fully written and replicated
        await Future.delayed(const Duration(milliseconds: 1500));
        try {
          final result = await referralService!.applyReferral(uid, referralCode.trim());
          if (result != null) {
            debugPrint('AuthProvider: Referral applied successfully');
          } else {
            debugPrint('AuthProvider: Referral code invalid or referral failed');
          }
        } catch (e) {
          debugPrint('AuthProvider: Referral apply failed: $e');
        }
      }

      try {
        await credential.user?.updateDisplayName(name.trim());
        if (profileImageUrl != null && profileImageUrl.trim().isNotEmpty) {
          await credential.user?.updatePhotoURL(profileImageUrl.trim());
          await firestoreService.setData('users', uid, {'profileImage': profileImageUrl.trim()}, merge: true);
        }
        _user = authService.currentUser;
        notifyListeners();
      } catch (e) {
        debugPrint('Profile update failed: $e');
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
    } on FirebaseException catch (e) {
      debugPrint('Firestore error during registration: ${e.code} - ${e.message}');
      _errorMessage = 'Account created but profile save failed. Please contact support.';
    } catch (e) {
      debugPrint('Registration error: $e');
      _errorMessage = 'Registration failed. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      await authService.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
    } catch (_) {
      _errorMessage = 'Unable to send password reset email.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _errorMessage = null;
    _isAdmin = false;
    _user = null;
    notifyListeners();
    try {
      await authService.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  Future<bool> deleteAccount() async {
    try {
      final uid = _user?.uid;
      if (uid == null) return false;

      await firestoreService.deleteData('users', uid);
      await _user?.delete();
      _user = null;
      _isAdmin = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Delete account error: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String? _mapErrorField(String code) {
    switch (code) {
      case 'invalid-email':
      case 'user-not-found':
      case 'email-already-in-use':
        return 'email';
      case 'wrong-password':
      case 'weak-password':
        return 'password';
      case 'invalid-credential':
        return null;
      default:
        return null;
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Email or password is incorrect. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Login failed. Please try again.';
    }
  }
}
