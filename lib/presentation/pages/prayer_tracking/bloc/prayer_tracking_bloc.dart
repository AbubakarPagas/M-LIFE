import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/datasources/prayer_tracking_db.dart';
import '../data/models/prayer_record.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Events
// ─────────────────────────────────────────────────────────────────────────────

abstract class PrayerTrackingEvent {}

class LoadRecordsEvent extends PrayerTrackingEvent {
  final DateTime date;
  LoadRecordsEvent(this.date);
}

class UpdatePrayerStatusEvent extends PrayerTrackingEvent {
  final String dateKey;
  final int prayerIndex;
  final PrayerStatus status;
  UpdatePrayerStatusEvent({
    required this.dateKey,
    required this.prayerIndex,
    required this.status,
  });
}

class LoadMonthEvent extends PrayerTrackingEvent {
  final int year;
  final int month;
  LoadMonthEvent(this.year, this.month);
}

class LoadWeeklyStatsEvent extends PrayerTrackingEvent {}

class LoadMonthlyStatsEvent extends PrayerTrackingEvent {
  final int year;
  final int month;
  LoadMonthlyStatsEvent(this.year, this.month);
}

class LoadStreakEvent extends PrayerTrackingEvent {}

// ─────────────────────────────────────────────────────────────────────────────
// States
// ─────────────────────────────────────────────────────────────────────────────

abstract class PrayerTrackingState {}

class PrayerTrackingInitial extends PrayerTrackingState {}

class PrayerTrackingLoading extends PrayerTrackingState {}

class PrayerTrackingError extends PrayerTrackingState {
  final String message;
  PrayerTrackingError(this.message);
}

class DailyRecordLoaded extends PrayerTrackingState {
  final PrayerRecord record;
  final int streak;
  DailyRecordLoaded({required this.record, required this.streak});
}

class MonthCalendarLoaded extends PrayerTrackingState {
  final int year;
  final int month;

  /// dateKey → PrayerRecord
  final Map<String, PrayerRecord> records;
  MonthCalendarLoaded({
    required this.year,
    required this.month,
    required this.records,
  });
}

class WeeklyStatsLoaded extends PrayerTrackingState {
  final int completedTotal;
  final int missedTotal;
  final double completionPct;
  final double avgScore;
  WeeklyStatsLoaded({
    required this.completedTotal,
    required this.missedTotal,
    required this.completionPct,
    required this.avgScore,
  });
}

class MonthlyStatsLoaded extends PrayerTrackingState {
  final double completionPct;
  final int longestStreak;
  final String mostConsistentPrayer;
  final List<double> weeklyScores;
  MonthlyStatsLoaded({
    required this.completionPct,
    required this.longestStreak,
    required this.mostConsistentPrayer,
    required this.weeklyScores,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Bloc
// ─────────────────────────────────────────────────────────────────────────────

class PrayerTrackingBloc
    extends Bloc<PrayerTrackingEvent, PrayerTrackingState> {
  final PrayerTrackingDb _db;

  PrayerTrackingBloc({PrayerTrackingDb? db})
    : _db = db ?? PrayerTrackingDb.instance,
      super(PrayerTrackingInitial()) {
    on<LoadRecordsEvent>(_onLoadRecords);
    on<UpdatePrayerStatusEvent>(_onUpdateStatus);
    on<LoadMonthEvent>(_onLoadMonth);
    on<LoadWeeklyStatsEvent>(_onLoadWeekly);
    on<LoadMonthlyStatsEvent>(_onLoadMonthly);
    on<LoadStreakEvent>(_onLoadStreak);
  }

  Future<void> _onLoadRecords(
    LoadRecordsEvent event,
    Emitter<PrayerTrackingState> emit,
  ) async {
    emit(PrayerTrackingLoading());
    try {
      final key = PrayerRecord.dateKey(event.date);
      final record = await _db.getRecord(key) ?? PrayerRecord(date: key);
      final streak = await _db.getPrayerStreak();
      emit(DailyRecordLoaded(record: record, streak: streak));
    } catch (e) {
      emit(PrayerTrackingError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    UpdatePrayerStatusEvent event,
    Emitter<PrayerTrackingState> emit,
  ) async {
    try {
      await _db.updatePrayerStatus(
        date: event.dateKey,
        prayerIndex: event.prayerIndex,
        status: event.status,
      );
      // Re-load the day after update
      final record =
          await _db.getRecord(event.dateKey) ??
          PrayerRecord(date: event.dateKey);
      final streak = await _db.getPrayerStreak();
      emit(DailyRecordLoaded(record: record, streak: streak));
    } catch (e) {
      emit(PrayerTrackingError(e.toString()));
    }
  }

  Future<void> _onLoadMonth(
    LoadMonthEvent event,
    Emitter<PrayerTrackingState> emit,
  ) async {
    emit(PrayerTrackingLoading());
    try {
      final list = await _db.getMonthRecords(event.year, event.month);
      final map = {for (final r in list) r.date: r};
      emit(
        MonthCalendarLoaded(year: event.year, month: event.month, records: map),
      );
    } catch (e) {
      emit(PrayerTrackingError(e.toString()));
    }
  }

  Future<void> _onLoadWeekly(
    LoadWeeklyStatsEvent event,
    Emitter<PrayerTrackingState> emit,
  ) async {
    emit(PrayerTrackingLoading());
    try {
      final stats = await _db.getWeeklyStats();
      emit(
        WeeklyStatsLoaded(
          completedTotal: stats.completedTotal,
          missedTotal: stats.missedTotal,
          completionPct: stats.completionPct,
          avgScore: stats.avgScore,
        ),
      );
    } catch (e) {
      emit(PrayerTrackingError(e.toString()));
    }
  }

  Future<void> _onLoadMonthly(
    LoadMonthlyStatsEvent event,
    Emitter<PrayerTrackingState> emit,
  ) async {
    emit(PrayerTrackingLoading());
    try {
      final stats = await _db.getMonthlyStats(event.year, event.month);
      emit(
        MonthlyStatsLoaded(
          completionPct: stats.completionPct,
          longestStreak: stats.longestStreak,
          mostConsistentPrayer: stats.mostConsistentPrayer,
          weeklyScores: stats.weeklyScores,
        ),
      );
    } catch (e) {
      emit(PrayerTrackingError(e.toString()));
    }
  }

  Future<void> _onLoadStreak(
    LoadStreakEvent event,
    Emitter<PrayerTrackingState> emit,
  ) async {
    try {
      final streak = await _db.getPrayerStreak();
      // We only emit if we already have a daily record loaded
      if (state is DailyRecordLoaded) {
        final s = state as DailyRecordLoaded;
        emit(DailyRecordLoaded(record: s.record, streak: streak));
      }
    } catch (_) {}
  }
}
