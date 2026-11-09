// ── Qibla Settings Service ───────────────────────────────────────────────────
// Persists and loads QiblaSettings using GetStorage.

import 'package:get_storage/get_storage.dart';

import '../models/qibla_settings_model.dart';

const _kQiblaSettingsKey = 'QIBLA_SETTINGS';

class QiblaSettingsService {
  final GetStorage _box;

  QiblaSettingsService() : _box = GetStorage();

  /// Reads persisted settings, or returns defaults.
  QiblaSettings load() {
    final raw = _box.read<Map>(_kQiblaSettingsKey);
    if (raw == null) return const QiblaSettings();
    return QiblaSettings.fromMap(Map<String, dynamic>.from(raw));
  }

  /// Saves [settings] to storage.
  Future<void> save(QiblaSettings settings) =>
      _box.write(_kQiblaSettingsKey, settings.toMap());
}
