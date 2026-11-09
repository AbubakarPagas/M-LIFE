// ─────────────────────────────────────────────────────────────────────────────
// dars_models.dart — Complete data models for the Dars (Islamic Lessons) feature
// ─────────────────────────────────────────────────────────────────────────────

// ── Enumerations ─────────────────────────────────────────────────────────────

enum DarsType { audio, video, text }

enum LiveDarsStatus { upcoming, live, ended }

enum DownloadStatus { notDownloaded, downloading, downloaded, failed }

enum QuestionStatus { pending, approved, rejected }

enum DarsCategory {
  quran,
  tafsir,
  hadith,
  fiqh,
  aqeedah,
  seerah,
  islamicHistory,
  akhlaq,
  ramadan,
  general,
}

extension DarsCategoryExtension on DarsCategory {
  String get displayName {
    switch (this) {
      case DarsCategory.quran:
        return 'Quran';
      case DarsCategory.tafsir:
        return 'Tafsir';
      case DarsCategory.hadith:
        return 'Hadith';
      case DarsCategory.fiqh:
        return 'Fiqh';
      case DarsCategory.aqeedah:
        return 'Aqeedah';
      case DarsCategory.seerah:
        return 'Seerah';
      case DarsCategory.islamicHistory:
        return 'Islamic History';
      case DarsCategory.akhlaq:
        return 'Akhlaq';
      case DarsCategory.ramadan:
        return 'Ramadan';
      case DarsCategory.general:
        return 'General';
    }
  }

  String get arabicName {
    switch (this) {
      case DarsCategory.quran:
        return 'القرآن الكريم';
      case DarsCategory.tafsir:
        return 'التفسير';
      case DarsCategory.hadith:
        return 'الحديث';
      case DarsCategory.fiqh:
        return 'الفقه';
      case DarsCategory.aqeedah:
        return 'العقيدة';
      case DarsCategory.seerah:
        return 'السيرة النبوية';
      case DarsCategory.islamicHistory:
        return 'التاريخ الإسلامي';
      case DarsCategory.akhlaq:
        return 'الأخلاق';
      case DarsCategory.ramadan:
        return 'رمضان';
      case DarsCategory.general:
        return 'عام';
    }
  }

  String get emoji {
    switch (this) {
      case DarsCategory.quran:
        return '📖';
      case DarsCategory.tafsir:
        return '🔍';
      case DarsCategory.hadith:
        return '📜';
      case DarsCategory.fiqh:
        return '⚖️';
      case DarsCategory.aqeedah:
        return '🕌';
      case DarsCategory.seerah:
        return '🌙';
      case DarsCategory.islamicHistory:
        return '🏛️';
      case DarsCategory.akhlaq:
        return '💎';
      case DarsCategory.ramadan:
        return '🌙';
      case DarsCategory.general:
        return '📚';
    }
  }
}

// ── Scholar Model ─────────────────────────────────────────────────────────────

class Scholar {
  final String id;
  final String name;
  final String arabicName;
  final String? photoUrl;
  final String biography;
  final String? country;
  final List<String> specializations;
  final int darsCount;
  final bool isFollowed;

  const Scholar({
    required this.id,
    required this.name,
    required this.arabicName,
    this.photoUrl,
    required this.biography,
    this.country,
    this.specializations = const [],
    this.darsCount = 0,
    this.isFollowed = false,
  });

  Scholar copyWith({
    String? id,
    String? name,
    String? arabicName,
    String? photoUrl,
    String? biography,
    String? country,
    List<String>? specializations,
    int? darsCount,
    bool? isFollowed,
  }) {
    return Scholar(
      id: id ?? this.id,
      name: name ?? this.name,
      arabicName: arabicName ?? this.arabicName,
      photoUrl: photoUrl ?? this.photoUrl,
      biography: biography ?? this.biography,
      country: country ?? this.country,
      specializations: specializations ?? this.specializations,
      darsCount: darsCount ?? this.darsCount,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }

  factory Scholar.fromJson(Map<String, dynamic> json) {
    return Scholar(
      id: json['id'] as String,
      name: json['name'] as String,
      arabicName: json['arabicName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      biography: json['biography'] as String? ?? '',
      country: json['country'] as String?,
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      darsCount: json['darsCount'] as int? ?? 0,
      isFollowed: json['isFollowed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'arabicName': arabicName,
        'photoUrl': photoUrl,
        'biography': biography,
        'country': country,
        'specializations': specializations,
        'darsCount': darsCount,
        'isFollowed': isFollowed,
      };
}

// ── Topic Model ───────────────────────────────────────────────────────────────

class DarsTopic {
  final String id;
  final String title;
  final String arabicTitle;
  final String? description;
  final DarsCategory category;
  final int darsCount;

  const DarsTopic({
    required this.id,
    required this.title,
    required this.arabicTitle,
    this.description,
    required this.category,
    this.darsCount = 0,
  });

  factory DarsTopic.fromJson(Map<String, dynamic> json) {
    return DarsTopic(
      id: json['id'] as String,
      title: json['title'] as String,
      arabicTitle: json['arabicTitle'] as String? ?? '',
      description: json['description'] as String?,
      category: DarsCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => DarsCategory.general,
      ),
      darsCount: json['darsCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'arabicTitle': arabicTitle,
        'description': description,
        'category': category.name,
        'darsCount': darsCount,
      };
}

// ── Main Dars Model ───────────────────────────────────────────────────────────

class Dars {
  final String id;
  final String title;
  final String arabicTitle;
  final String description;
  final Scholar scholar;
  final DarsCategory category;
  final DarsTopic? topic;
  final DarsType type;
  final String? thumbnailUrl;
  final String? audioUrl;
  final String? videoUrl;
  final Duration duration;
  final DateTime publishedAt;
  final int viewCount;
  final double rating;
  final List<String> tags;
  final String? courseId;
  final int? courseOrder;

  const Dars({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.description,
    required this.scholar,
    required this.category,
    this.topic,
    required this.type,
    this.thumbnailUrl,
    this.audioUrl,
    this.videoUrl,
    required this.duration,
    required this.publishedAt,
    this.viewCount = 0,
    this.rating = 0.0,
    this.tags = const [],
    this.courseId,
    this.courseOrder,
  });

  String get durationFormatted {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  factory Dars.fromJson(Map<String, dynamic> json) {
    return Dars(
      id: json['id'] as String,
      title: json['title'] as String,
      arabicTitle: json['arabicTitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      scholar: Scholar.fromJson(json['scholar'] as Map<String, dynamic>),
      category: DarsCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => DarsCategory.general,
      ),
      topic: json['topic'] != null
          ? DarsTopic.fromJson(json['topic'] as Map<String, dynamic>)
          : null,
      type: DarsType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => DarsType.audio,
      ),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      duration: Duration(seconds: json['durationSeconds'] as int? ?? 0),
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
          DateTime.now(),
      viewCount: json['viewCount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      courseId: json['courseId'] as String?,
      courseOrder: json['courseOrder'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'arabicTitle': arabicTitle,
        'description': description,
        'scholar': scholar.toJson(),
        'category': category.name,
        'topic': topic?.toJson(),
        'type': type.name,
        'thumbnailUrl': thumbnailUrl,
        'audioUrl': audioUrl,
        'videoUrl': videoUrl,
        'durationSeconds': duration.inSeconds,
        'publishedAt': publishedAt.toIso8601String(),
        'viewCount': viewCount,
        'rating': rating,
        'tags': tags,
        'courseId': courseId,
        'courseOrder': courseOrder,
      };
}

// ── Lesson Progress Model ─────────────────────────────────────────────────────

class LessonProgress {
  final String darsId;
  final Duration position;
  final Duration totalDuration;
  final bool isCompleted;
  final DateTime lastWatched;

  const LessonProgress({
    required this.darsId,
    required this.position,
    required this.totalDuration,
    this.isCompleted = false,
    required this.lastWatched,
  });

  double get percentComplete {
    if (totalDuration.inSeconds == 0) return 0.0;
    return (position.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
  }

  LessonProgress copyWith({
    String? darsId,
    Duration? position,
    Duration? totalDuration,
    bool? isCompleted,
    DateTime? lastWatched,
  }) {
    return LessonProgress(
      darsId: darsId ?? this.darsId,
      position: position ?? this.position,
      totalDuration: totalDuration ?? this.totalDuration,
      isCompleted: isCompleted ?? this.isCompleted,
      lastWatched: lastWatched ?? this.lastWatched,
    );
  }
}

// ── Bookmark Model ────────────────────────────────────────────────────────────

class DarsBookmark {
  final String id;
  final String darsId;
  final String darsTitle;
  final String scholarName;
  final String? thumbnailUrl;
  final DarsType darsType;
  final DateTime savedAt;
  final Duration? savedPosition;

  const DarsBookmark({
    required this.id,
    required this.darsId,
    required this.darsTitle,
    required this.scholarName,
    this.thumbnailUrl,
    required this.darsType,
    required this.savedAt,
    this.savedPosition,
  });
}

// ── Download Model ────────────────────────────────────────────────────────────

class DarsDownload {
  final String id;
  final String darsId;
  final String darsTitle;
  final String scholarName;
  final String? thumbnailUrl;
  final DarsType darsType;
  final DownloadStatus status;
  final double progress;
  final String? localPath;
  final int fileSizeBytes;
  final DateTime downloadedAt;

  const DarsDownload({
    required this.id,
    required this.darsId,
    required this.darsTitle,
    required this.scholarName,
    this.thumbnailUrl,
    required this.darsType,
    this.status = DownloadStatus.notDownloaded,
    this.progress = 0.0,
    this.localPath,
    this.fileSizeBytes = 0,
    required this.downloadedAt,
  });

  DarsDownload copyWith({
    String? id,
    String? darsId,
    String? darsTitle,
    String? scholarName,
    String? thumbnailUrl,
    DarsType? darsType,
    DownloadStatus? status,
    double? progress,
    String? localPath,
    int? fileSizeBytes,
    DateTime? downloadedAt,
  }) {
    return DarsDownload(
      id: id ?? this.id,
      darsId: darsId ?? this.darsId,
      darsTitle: darsTitle ?? this.darsTitle,
      scholarName: scholarName ?? this.scholarName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      darsType: darsType ?? this.darsType,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      localPath: localPath ?? this.localPath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) return '${fileSizeBytes}B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

// ── Live Dars Model ───────────────────────────────────────────────────────────

class LiveDars {
  final String id;
  final String title;
  final String arabicTitle;
  final String description;
  final Scholar scholar;
  final DarsCategory category;
  final DateTime scheduledAt;
  final Duration? estimatedDuration;
  final LiveDarsStatus status;
  final String? joinUrl;
  final String? thumbnailUrl;
  final int registeredCount;
  final bool hasReminder;

  const LiveDars({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.description,
    required this.scholar,
    required this.category,
    required this.scheduledAt,
    this.estimatedDuration,
    required this.status,
    this.joinUrl,
    this.thumbnailUrl,
    this.registeredCount = 0,
    this.hasReminder = false,
  });

  bool get isActive => status == LiveDarsStatus.live;
  bool get isUpcoming => status == LiveDarsStatus.upcoming;

  LiveDars copyWith({bool? hasReminder, LiveDarsStatus? status}) {
    return LiveDars(
      id: id,
      title: title,
      arabicTitle: arabicTitle,
      description: description,
      scholar: scholar,
      category: category,
      scheduledAt: scheduledAt,
      estimatedDuration: estimatedDuration,
      status: status ?? this.status,
      joinUrl: joinUrl,
      thumbnailUrl: thumbnailUrl,
      registeredCount: registeredCount,
      hasReminder: hasReminder ?? this.hasReminder,
    );
  }
}

// ── Playlist Model ────────────────────────────────────────────────────────────

class DarsPlaylist {
  final String id;
  final String name;
  final String? description;
  final List<String> darsIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverThumbnailUrl;

  const DarsPlaylist({
    required this.id,
    required this.name,
    this.description,
    this.darsIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.coverThumbnailUrl,
  });

  int get lessonCount => darsIds.length;

  DarsPlaylist copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? darsIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coverThumbnailUrl,
  }) {
    return DarsPlaylist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      darsIds: darsIds ?? this.darsIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverThumbnailUrl: coverThumbnailUrl ?? this.coverThumbnailUrl,
    );
  }
}

// ── Course Model ──────────────────────────────────────────────────────────────

class DarsCourse {
  final String id;
  final String title;
  final String arabicTitle;
  final String description;
  final Scholar scholar;
  final DarsCategory category;
  final String? thumbnailUrl;
  final List<String> darsIds;
  final DateTime publishedAt;
  final bool isCompleted;
  final double progressPercent;

  const DarsCourse({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.description,
    required this.scholar,
    required this.category,
    this.thumbnailUrl,
    this.darsIds = const [],
    required this.publishedAt,
    this.isCompleted = false,
    this.progressPercent = 0.0,
  });

  int get lessonCount => darsIds.length;

  DarsCourse copyWith({double? progressPercent, bool? isCompleted}) {
    return DarsCourse(
      id: id,
      title: title,
      arabicTitle: arabicTitle,
      description: description,
      scholar: scholar,
      category: category,
      thumbnailUrl: thumbnailUrl,
      darsIds: darsIds,
      publishedAt: publishedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      progressPercent: progressPercent ?? this.progressPercent,
    );
  }

  factory DarsCourse.fromJson(Map<String, dynamic> json) {
    return DarsCourse(
      id: json['id'] as String,
      title: json['title'] as String,
      arabicTitle: json['arabicTitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      scholar: Scholar.fromJson(json['scholar'] as Map<String, dynamic>),
      category: DarsCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => DarsCategory.general,
      ),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      darsIds: (json['darsIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
          DateTime.now(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      progressPercent:
          (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ── Q&A Models ────────────────────────────────────────────────────────────────

class DarsQuestion {
  final String id;
  final String darsId;
  final String questionText;
  final DateTime askedAt;
  final QuestionStatus status;
  final List<DarsAnswer> answers;

  const DarsQuestion({
    required this.id,
    required this.darsId,
    required this.questionText,
    required this.askedAt,
    this.status = QuestionStatus.pending,
    this.answers = const [],
  });
}

class DarsAnswer {
  final String id;
  final String questionId;
  final String answerText;
  final String answeredBy;
  final bool isScholarAnswer;
  final DateTime answeredAt;

  const DarsAnswer({
    required this.id,
    required this.questionId,
    required this.answerText,
    required this.answeredBy,
    this.isScholarAnswer = false,
    required this.answeredAt,
  });
}

// ── Dars History Entry ────────────────────────────────────────────────────────

class DarsHistoryEntry {
  final String darsId;
  final String darsTitle;
  final String scholarName;
  final String? thumbnailUrl;
  final DarsType darsType;
  final Duration lastPosition;
  final DateTime watchedAt;
  final bool isCompleted;

  const DarsHistoryEntry({
    required this.darsId,
    required this.darsTitle,
    required this.scholarName,
    this.thumbnailUrl,
    required this.darsType,
    required this.lastPosition,
    required this.watchedAt,
    this.isCompleted = false,
  });
}

// ── Notification Model ────────────────────────────────────────────────────────

class DarsNotificationModel {
  final String id;
  final String title;
  final String body;
  final String? darsId;
  final String? liveId;
  final DateTime scheduledAt;
  final bool isRead;

  const DarsNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.darsId,
    this.liveId,
    required this.scheduledAt,
    this.isRead = false,
  });
}
