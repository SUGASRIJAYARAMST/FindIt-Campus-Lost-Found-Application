import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/item_model.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService favoriteService;

  List<String> _favoriteIds = [];
  List<ItemModel> _favoriteItems = [];
  bool _isLoading = false;
  String? _uid;
  StreamSubscription<List<String>>? _subscription;

  FavoriteProvider({required this.favoriteService});

  List<String> get favoriteIds => _favoriteIds;
  List<ItemModel> get favoriteItems => _favoriteItems;
  bool get isLoading => _isLoading;

  void startListening(String uid) {
    _uid = uid;
    _subscription?.cancel();
    _subscription = favoriteService.getUserFavoriteIds(uid).listen(
      (ids) {
        _favoriteIds = ids;
        _syncFavoriteItems();
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Favorites stream error: $error');
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  bool isFavorited(String itemId) {
    return _favoriteIds.contains(itemId);
  }

  Future<void> toggleFavorite(String uid, String itemId) async {
    final wasFavorited = _favoriteIds.contains(itemId);

    if (wasFavorited) {
      _favoriteIds.remove(itemId);
    } else {
      _favoriteIds.add(itemId);
    }
    notifyListeners();

    try {
      await favoriteService.toggleFavorite(uid, itemId);
    } catch (e) {
      if (wasFavorited) {
        _favoriteIds.add(itemId);
      } else {
        _favoriteIds.remove(itemId);
      }
      notifyListeners();
    }
  }

  Future<void> loadFavorites(String uid) async {
    _uid = uid;
    _isLoading = true;
    notifyListeners();

    try {
      _favoriteItems = await favoriteService.getUserFavorites(uid);
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _syncFavoriteItems() {
    if (_uid == null) return;
    final idSet = _favoriteIds.toSet();
    _favoriteItems = _favoriteItems.where((item) => idSet.contains(item.id)).toList();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
