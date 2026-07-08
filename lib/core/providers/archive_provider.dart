import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/item_model.dart';
import '../services/archive_service.dart';

class ArchiveProvider extends ChangeNotifier {
  final ArchiveService archiveService;

  List<ItemModel> _archivedItems = [];
  bool _isLoading = false;
  StreamSubscription<List<ItemModel>>? _subscription;

  ArchiveProvider({required this.archiveService});

  List<ItemModel> get archivedItems => _archivedItems;
  bool get isLoading => _isLoading;

  void startListening() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = archiveService.getArchivedItems().listen(
      (items) {
        _archivedItems = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Archive stream error: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> archiveItem(String itemId) async {
    await archiveService.archiveItem(itemId);
  }

  Future<void> unarchiveItem(String itemId) async {
    await archiveService.unarchiveItem(itemId);
  }

  Future<void> deleteArchivedItem(String itemId) async {
    await archiveService.deleteArchivedItem(itemId);
  }

  Future<void> autoArchiveOldItems({int daysOld = 20}) async {
    await archiveService.autoArchiveOldItems(daysOld: daysOld);
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
