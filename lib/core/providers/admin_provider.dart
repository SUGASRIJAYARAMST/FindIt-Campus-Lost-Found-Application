import 'package:flutter/foundation.dart';

import '../../domain/models/user_model.dart';
import '../../domain/models/item_model.dart';
import '../services/firestore_service.dart';

class AdminProvider extends ChangeNotifier {
  final FirestoreService firestoreService;

  List<UserModel> _users = [];
  List<ItemModel> _items = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _errorMessage;

  AdminProvider({required this.firestoreService});

  List<UserModel> get users => _users;
  List<ItemModel> get items => _items;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> checkAdminRole(String uid) async {
    try {
      final doc = await firestoreService.document('users', uid);
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['role'] == 'admin';
      }
    } catch (e) {
      debugPrint('Error checking admin role: $e');
    }
    return false;
  }

  Future<void> loadDashboardStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final usersSnapshot = await firestoreService.collection('users').get();
      final itemsSnapshot = await firestoreService.collection('items').get();

      final totalUsers = usersSnapshot.size;
      final totalItems = itemsSnapshot.size;

      int lostItems = 0;
      int foundItems = 0;
      int recoveredItems = 0;
      int returnedItems = 0;

      final categoryCount = <String, int>{};
      final locationCount = <String, int>{};
      final monthlyCount = <String, int>{};

      for (final doc in itemsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final type = data['type'] as String? ?? '';
        final status = data['status'] as String? ?? '';
        final category = data['category'] as String? ?? 'Unknown';
        final location = data['location'] as String? ?? 'Unknown';

        if (type == 'lost') lostItems++;
        if (type == 'found') foundItems++;
        if (status == 'recovered') recoveredItems++;
        if (status == 'returned') returnedItems++;

        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        locationCount[location] = (locationCount[location] ?? 0) + 1;

        final createdAt = data['createdAt'];
        if (createdAt != null) {
          DateTime? date;
          if (createdAt is DateTime) {
            date = createdAt;
          } else if (createdAt is String) {
            date = DateTime.tryParse(createdAt);
          }
          if (date != null) {
            final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
            monthlyCount[monthKey] = (monthlyCount[monthKey] ?? 0) + 1;
          }
        }
      }

      final totalResolved = recoveredItems + returnedItems;
      final recoveryRate = totalItems > 0 ? ((totalResolved / totalItems) * 100).round() : 0;

      _stats = {
        'totalUsers': totalUsers,
        'totalItems': totalItems,
        'lostItems': lostItems,
        'foundItems': foundItems,
        'recoveredItems': recoveredItems,
        'returnedItems': returnedItems,
        'recoveryRate': recoveryRate,
        'categoryCount': categoryCount,
        'locationCount': locationCount,
        'monthlyCount': monthlyCount,
      };
    } catch (e) {
      debugPrint('Error loading stats: $e');
      _errorMessage = 'Failed to load dashboard stats.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await firestoreService.collection('users').get();
      _users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((u) => u.role != 'admin')
          .toList();
    } catch (e) {
      debugPrint('Error loading users: $e');
      _errorMessage = 'Failed to load users.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await firestoreService.collection('items').get();
      _items = snapshot.docs
          .map((doc) => ItemModel.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      debugPrint('Error loading items: $e');
      _errorMessage = 'Failed to load items.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String uid) async {
    try {
      await firestoreService.deleteData('users', uid);
      _users.removeWhere((u) => u.uid == uid);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete user.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> blockUser(String uid) async {
    try {
      await firestoreService.setData('users', uid, {
        'status': 'blocked',
      }, merge: true);
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to block user.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> unblockUser(String uid) async {
    try {
      await firestoreService.setData('users', uid, {
        'status': 'active',
      }, merge: true);
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to unblock user.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(String itemId) async {
    try {
      await firestoreService.deleteData('items', itemId);
      _items.removeWhere((i) => i.id == itemId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete item.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItemStatus(String itemId, String status) async {
    try {
      await firestoreService.setData('items', itemId, {
        'status': status,
      }, merge: true);
      await loadItems();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update item status.';
      notifyListeners();
      return false;
    }
  }

  List<UserModel> searchUsers(String query) {
    if (query.isEmpty) return _users;
    final q = query.toLowerCase();
    return _users.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.department.toLowerCase().contains(q);
    }).toList();
  }

  List<ItemModel> searchItems(String query) {
    if (query.isEmpty) return _items;
    final q = query.toLowerCase();
    return _items.where((i) {
      return i.title.toLowerCase().contains(q) ||
          i.category.toLowerCase().contains(q) ||
          i.location.toLowerCase().contains(q);
    }).toList();
  }
}
