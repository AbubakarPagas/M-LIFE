/// Domain model for a stored notification item.
library notification_item;

enum NotificationCategory {
  prayerTime,
  adhan,
  jumuah,
  quranReading,
  dhikr,
  dailyHadith,
  dailyAyah,
  ramadan,
  islamicEvents,
}

extension NotificationCategoryX on NotificationCategory {
  String get label {
    return switch (this) {
      NotificationCategory.prayerTime => 'Prayer Time',
      NotificationCategory.adhan => 'Adhan',
      NotificationCategory.jumuah => "Jumu'ah",
      NotificationCategory.quranReading => 'Quran Reading',
      NotificationCategory.dhikr => 'Dhikr',
      NotificationCategory.dailyHadith => 'Daily Hadith',
      NotificationCategory.dailyAyah => 'Daily Ayah',
      NotificationCategory.ramadan => 'Ramadan',
      NotificationCategory.islamicEvents => 'Islamic Events',
    };
  }

  String get emoji {
    return switch (this) {
      NotificationCategory.prayerTime => '🕐',
      NotificationCategory.adhan => '📢',
      NotificationCategory.jumuah => '🕌',
      NotificationCategory.quranReading => '📖',
      NotificationCategory.dhikr => '📿',
      NotificationCategory.dailyHadith => '🌙',
      NotificationCategory.dailyAyah => '✨',
      NotificationCategory.ramadan => '🌙',
      NotificationCategory.islamicEvents => '📅',
    };
  }

  String toStorageString() => name;

  static NotificationCategory fromStorageString(String? s) {
    if (s == null) return NotificationCategory.prayerTime;
    try {
      return NotificationCategory.values.firstWhere((e) => e.name == s);
    } catch (_) {
      return NotificationCategory.prayerTime;
    }
  }
}

class NotificationItem {
  final int? id; // auto-incremented DB id
  final String title;
  final String body;
  final NotificationCategory category;
  final DateTime receivedAt;
  final bool isRead;
  final bool isArchived;

  const NotificationItem({
    this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.receivedAt,
    this.isRead = false,
    this.isArchived = false,
  });

  NotificationItem copyWith({int? id, bool? isRead, bool? isArchived}) =>
      NotificationItem(
        id: id ?? this.id,
        title: title,
        body: body,
        category: category,
        receivedAt: receivedAt,
        isRead: isRead ?? this.isRead,
        isArchived: isArchived ?? this.isArchived,
      );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'body': body,
    'category': category.toStorageString(),
    'receivedAt': receivedAt.toIso8601String(),
    'isRead': isRead ? 1 : 0,
    'isArchived': isArchived ? 1 : 0,
  };

  factory NotificationItem.fromMap(Map<String, dynamic> m) => NotificationItem(
    id: m['id'] as int?,
    title: m['title'] as String,
    body: m['body'] as String,
    category: NotificationCategoryX.fromStorageString(m['category'] as String?),
    receivedAt: DateTime.parse(m['receivedAt'] as String),
    isRead: (m['isRead'] as int?) == 1,
    isArchived: (m['isArchived'] as int?) == 1,
  );
}
