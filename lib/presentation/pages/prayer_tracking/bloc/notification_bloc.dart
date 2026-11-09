import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/datasources/prayer_tracking_db.dart';
import '../data/models/notification_item.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Events
// ─────────────────────────────────────────────────────────────────────────────

abstract class NotificationEvent {}

class LoadNotificationsEvent extends NotificationEvent {
  final NotificationCategory? category;
  final bool includeArchived;
  final String? searchQuery;
  LoadNotificationsEvent({
    this.category,
    this.includeArchived = false,
    this.searchQuery,
  });
}

class SaveNotificationEvent extends NotificationEvent {
  final NotificationItem item;
  SaveNotificationEvent(this.item);
}

class MarkReadEvent extends NotificationEvent {
  final int id;
  MarkReadEvent(this.id);
}

class MarkAllReadEvent extends NotificationEvent {}

class DeleteNotificationEvent extends NotificationEvent {
  final int id;
  DeleteNotificationEvent(this.id);
}

class DeleteAllNotificationsEvent extends NotificationEvent {}

class ArchiveNotificationEvent extends NotificationEvent {
  final int id;
  ArchiveNotificationEvent(this.id);
}

class FilterNotificationsEvent extends NotificationEvent {
  final NotificationCategory? category;
  final String? searchQuery;
  FilterNotificationsEvent({this.category, this.searchQuery});
}

// ─────────────────────────────────────────────────────────────────────────────
// States
// ─────────────────────────────────────────────────────────────────────────────

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationItem> items;
  final int unreadCount;
  final NotificationCategory? activeFilter;
  final String? activeSearch;

  NotificationLoaded({
    required this.items,
    required this.unreadCount,
    this.activeFilter,
    this.activeSearch,
  });

  /// Group notifications by time bucket for UI display
  Map<String, List<NotificationItem>> get grouped {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yest = today.subtract(const Duration(days: 1));
    final week = today.subtract(const Duration(days: 7));

    final buckets = <String, List<NotificationItem>>{
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Earlier': [],
    };

    for (final item in items) {
      final d = DateTime(
        item.receivedAt.year,
        item.receivedAt.month,
        item.receivedAt.day,
      );
      if (!d.isBefore(today)) {
        buckets['Today']!.add(item);
      } else if (!d.isBefore(yest)) {
        buckets['Yesterday']!.add(item);
      } else if (!d.isBefore(week)) {
        buckets['This Week']!.add(item);
      } else {
        buckets['Earlier']!.add(item);
      }
    }

    // Remove empty buckets
    buckets.removeWhere((_, v) => v.isEmpty);
    return buckets;
  }
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

// ─────────────────────────────────────────────────────────────────────────────
// Bloc
// ─────────────────────────────────────────────────────────────────────────────

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final PrayerTrackingDb _db;
  NotificationCategory? _activeFilter;
  String? _activeSearch;

  NotificationBloc({PrayerTrackingDb? db})
    : _db = db ?? PrayerTrackingDb.instance,
      super(NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoad);
    on<SaveNotificationEvent>(_onSave);
    on<MarkReadEvent>(_onMarkRead);
    on<MarkAllReadEvent>(_onMarkAll);
    on<DeleteNotificationEvent>(_onDelete);
    on<DeleteAllNotificationsEvent>(_onDeleteAll);
    on<ArchiveNotificationEvent>(_onArchive);
    on<FilterNotificationsEvent>(_onFilter);
  }

  Future<void> _reload(Emitter<NotificationState> emit) async {
    final items = await _db.getNotifications(
      category: _activeFilter,
      searchQuery: _activeSearch,
    );
    final unread = await _db.getUnreadCount();
    emit(
      NotificationLoaded(
        items: items,
        unreadCount: unread,
        activeFilter: _activeFilter,
        activeSearch: _activeSearch,
      ),
    );
  }

  Future<void> _onLoad(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    _activeFilter = event.category;
    _activeSearch = event.searchQuery;
    try {
      await _reload(emit);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onSave(
    SaveNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _db.saveNotification(event.item);
      await _reload(emit);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkRead(
    MarkReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _db.markNotificationRead(event.id);
      await _reload(emit);
    } catch (_) {}
  }

  Future<void> _onMarkAll(
    MarkAllReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _db.markAllRead();
      await _reload(emit);
    } catch (_) {}
  }

  Future<void> _onDelete(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _db.deleteNotification(event.id);
      await _reload(emit);
    } catch (_) {}
  }

  Future<void> _onDeleteAll(
    DeleteAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _db.deleteAllNotifications();
      await _reload(emit);
    } catch (_) {}
  }

  Future<void> _onArchive(
    ArchiveNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _db.archiveNotification(event.id);
      await _reload(emit);
    } catch (_) {}
  }

  Future<void> _onFilter(
    FilterNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    _activeFilter = event.category;
    _activeSearch = event.searchQuery;
    try {
      await _reload(emit);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
