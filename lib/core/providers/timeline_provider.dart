import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/timeline_event.dart';
import '../services/timeline_service.dart';

class TimelineProvider extends ChangeNotifier {
  final TimelineService timelineService;

  List<TimelineEvent> _events = [];
  bool _isLoading = false;
  StreamSubscription<List<TimelineEvent>>? _subscription;

  TimelineProvider({required this.timelineService});

  List<TimelineEvent> get events => _events;
  bool get isLoading => _isLoading;

  void startListening(String itemId) {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = timelineService.getItemTimeline(itemId).listen(
      (events) {
        _events = events;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Timeline stream error: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> addEvent({
    required String itemId,
    required String eventType,
    required String description,
    required String performedBy,
    required String performedByName,
    Map<String, dynamic>? metadata,
  }) async {
    await timelineService.addEvent(
      itemId: itemId,
      eventType: eventType,
      description: description,
      performedBy: performedBy,
      performedByName: performedByName,
      metadata: metadata,
    );
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
