// ─────────────────────────────────────────────────────────────────────────────
// FeedPostModel — data model for a single Ummah Feed post
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

enum PostType {
  quranVerse,
  tafsir,
  hadith,
  reminder,
  islamicNews,
  video,
  audioLecture,
  article,
}

enum FeedCategory {
  all,
  quran,
  tafsir,
  hadith,
  dailyDua,
  islamicReminder,
  goodDeeds,
  zakat,
  sadaqah,
  waqf,
  islamicHistory,
  seerah,
  islamicArticles,
  islamicVideos,
  lectures,
  ummahNews,
  ramadan,
  hajjUmrah;

  String get label => switch (this) {
    FeedCategory.all => 'All',
    FeedCategory.quran => 'Quran',
    FeedCategory.tafsir => 'Tafsir',
    FeedCategory.hadith => 'Hadith',
    FeedCategory.dailyDua => 'Daily Dua',
    FeedCategory.islamicReminder => 'Reminders',
    FeedCategory.goodDeeds => 'Good Deeds',
    FeedCategory.zakat => 'Zakat',
    FeedCategory.sadaqah => 'Sadaqah',
    FeedCategory.waqf => 'Waqf',
    FeedCategory.islamicHistory => 'History',
    FeedCategory.seerah => 'Seerah',
    FeedCategory.islamicArticles => 'Articles',
    FeedCategory.islamicVideos => 'Videos',
    FeedCategory.lectures => 'Lectures',
    FeedCategory.ummahNews => 'Ummah News',
    FeedCategory.ramadan => 'Ramadan',
    FeedCategory.hajjUmrah => 'Hajj & Umrah',
  };

  IconData get icon => switch (this) {
    FeedCategory.all => Icons.grid_view_rounded,
    FeedCategory.quran => Icons.menu_book_rounded,
    FeedCategory.tafsir => Icons.auto_stories_rounded,
    FeedCategory.hadith => Icons.format_quote_rounded,
    FeedCategory.dailyDua => Icons.volunteer_activism_rounded,
    FeedCategory.islamicReminder => Icons.notifications_rounded,
    FeedCategory.goodDeeds => Icons.star_rounded,
    FeedCategory.zakat => Icons.calculate_rounded,
    FeedCategory.sadaqah => Icons.favorite_rounded,
    FeedCategory.waqf => Icons.account_balance_rounded,
    FeedCategory.islamicHistory => Icons.history_edu_rounded,
    FeedCategory.seerah => Icons.person_rounded,
    FeedCategory.islamicArticles => Icons.article_rounded,
    FeedCategory.islamicVideos => Icons.play_circle_rounded,
    FeedCategory.lectures => Icons.headset_rounded,
    FeedCategory.ummahNews => Icons.public_rounded,
    FeedCategory.ramadan => Icons.nights_stay_rounded,
    FeedCategory.hajjUmrah => Icons.mosque_rounded,
  };
}

// ─────────────────────────────────────────────────────────────────────────────

class FeedPostModel {
  final String id;
  final PostType type;
  final FeedCategory category;
  final String title;
  final String description;
  final String? arabicText;
  final String? translation;
  final String? reference;
  final String authorName;
  final bool isVerified;
  final DateTime publishedAt;
  final int readingTimeMinutes;
  final String? imageUrl;
  final String? audioUrl;
  final String? videoUrl;
  final int? videoDurationSeconds;
  final int appreciateCount;
  final int bookmarkCount;
  final bool isBookmarked;
  final bool isAppreciated;
  final String? fullContent;

  const FeedPostModel({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.description,
    this.arabicText,
    this.translation,
    this.reference,
    required this.authorName,
    this.isVerified = false,
    required this.publishedAt,
    this.readingTimeMinutes = 2,
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
    this.videoDurationSeconds,
    this.appreciateCount = 0,
    this.bookmarkCount = 0,
    this.isBookmarked = false,
    this.isAppreciated = false,
    this.fullContent,
  });

  FeedPostModel copyWith({
    String? id,
    PostType? type,
    FeedCategory? category,
    String? title,
    String? description,
    String? arabicText,
    String? translation,
    String? reference,
    String? authorName,
    bool? isVerified,
    DateTime? publishedAt,
    int? readingTimeMinutes,
    String? imageUrl,
    String? audioUrl,
    String? videoUrl,
    int? videoDurationSeconds,
    int? appreciateCount,
    int? bookmarkCount,
    bool? isBookmarked,
    bool? isAppreciated,
    String? fullContent,
  }) {
    return FeedPostModel(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      arabicText: arabicText ?? this.arabicText,
      translation: translation ?? this.translation,
      reference: reference ?? this.reference,
      authorName: authorName ?? this.authorName,
      isVerified: isVerified ?? this.isVerified,
      publishedAt: publishedAt ?? this.publishedAt,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      videoDurationSeconds: videoDurationSeconds ?? this.videoDurationSeconds,
      appreciateCount: appreciateCount ?? this.appreciateCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isAppreciated: isAppreciated ?? this.isAppreciated,
      fullContent: fullContent ?? this.fullContent,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'category': category.index,
    'title': title,
    'description': description,
    'arabicText': arabicText,
    'translation': translation,
    'reference': reference,
    'authorName': authorName,
    'isVerified': isVerified,
    'publishedAt': publishedAt.toIso8601String(),
    'readingTimeMinutes': readingTimeMinutes,
    'imageUrl': imageUrl,
    'audioUrl': audioUrl,
    'videoUrl': videoUrl,
    'videoDurationSeconds': videoDurationSeconds,
    'appreciateCount': appreciateCount,
    'bookmarkCount': bookmarkCount,
    'isBookmarked': isBookmarked,
    'isAppreciated': isAppreciated,
    'fullContent': fullContent,
  };

  factory FeedPostModel.fromJson(Map<String, dynamic> json) => FeedPostModel(
    id: json['id'] as String,
    type: PostType.values[json['type'] as int],
    category: FeedCategory.values[json['category'] as int],
    title: json['title'] as String,
    description: json['description'] as String,
    arabicText: json['arabicText'] as String?,
    translation: json['translation'] as String?,
    reference: json['reference'] as String?,
    authorName: json['authorName'] as String,
    isVerified: json['isVerified'] as bool? ?? false,
    publishedAt: DateTime.parse(json['publishedAt'] as String),
    readingTimeMinutes: json['readingTimeMinutes'] as int? ?? 2,
    imageUrl: json['imageUrl'] as String?,
    audioUrl: json['audioUrl'] as String?,
    videoUrl: json['videoUrl'] as String?,
    videoDurationSeconds: json['videoDurationSeconds'] as int?,
    appreciateCount: json['appreciateCount'] as int? ?? 0,
    bookmarkCount: json['bookmarkCount'] as int? ?? 0,
    isBookmarked: json['isBookmarked'] as bool? ?? false,
    isAppreciated: json['isAppreciated'] as bool? ?? false,
    fullContent: json['fullContent'] as String?,
  );
}
