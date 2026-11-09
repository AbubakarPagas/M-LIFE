// ─────────────────────────────────────────────────────────────────────────────
// dars_mock_data.dart — Seed/mock data for development and testing
// Replace with real API calls in production.
// ─────────────────────────────────────────────────────────────────────────────

import '../models/dars_models.dart';

// ── Mock Scholars ─────────────────────────────────────────────────────────────

final mockScholars = <Scholar>[
  const Scholar(
    id: 's1',
    name: 'Sheikh Yasir Qadhi',
    arabicName: 'الشيخ ياسر قاضي',
    biography:
        'Dean of Academic Affairs at the Al-Maghrib Institute and a prominent Islamic scholar known for his lectures on theology, Seerah, and contemporary Islamic issues.',
    country: 'USA',
    specializations: ['Aqeedah', 'Seerah', 'Tafsir'],
    darsCount: 42,
  ),
  const Scholar(
    id: 's2',
    name: 'Sheikh Omar Suleiman',
    arabicName: 'الشيخ عمر سليمان',
    biography:
        'Founder and President of the Yaqeen Institute for Islamic Research, adjunct professor of Islamic Studies at Southern Methodist University.',
    country: 'USA',
    specializations: ['Islamic History', 'Spirituality', 'Quran'],
    darsCount: 35,
  ),
  const Scholar(
    id: 's3',
    name: 'Sheikh Nouman Ali Khan',
    arabicName: 'الشيخ نعمان علي خان',
    biography:
        'Founder and CEO of Bayyinah Institute, renowned for his unique approach to Quranic education and Arabic language.',
    country: 'USA',
    specializations: ['Quran', 'Arabic', 'Tafsir'],
    darsCount: 58,
  ),
  const Scholar(
    id: 's4',
    name: 'Sheikh Hamza Yusuf',
    arabicName: 'الشيخ حمزة يوسف',
    biography:
        'Co-founder of Zaytuna College, considered one of the most influential Islamic scholars in the Western world.',
    country: 'USA',
    specializations: ['Fiqh', 'Akhlaq', 'Islamic Philosophy'],
    darsCount: 29,
  ),
  const Scholar(
    id: 's5',
    name: 'Sheikh Said Rageah',
    arabicName: 'الشيخ سعيد راجح',
    biography:
        'Canadian Islamic scholar and founder of Mercy Mission, known for his inspiring talks on faith and character.',
    country: 'Canada',
    specializations: ['Hadith', 'Akhlaq', 'General'],
    darsCount: 24,
  ),
];

// ── Mock Topics ───────────────────────────────────────────────────────────────

final mockTopics = <DarsTopic>[
  const DarsTopic(
    id: 't1',
    title: 'Names of Allah',
    arabicTitle: 'أسماء الله الحسنى',
    category: DarsCategory.aqeedah,
    darsCount: 8,
  ),
  const DarsTopic(
    id: 't2',
    title: 'Life of the Prophet',
    arabicTitle: 'السيرة النبوية',
    category: DarsCategory.seerah,
    darsCount: 15,
  ),
  const DarsTopic(
    id: 't3',
    title: 'Prayer (Salah)',
    arabicTitle: 'الصلاة',
    category: DarsCategory.fiqh,
    darsCount: 6,
  ),
  const DarsTopic(
    id: 't4',
    title: 'Purification of the Soul',
    arabicTitle: 'تزكية النفس',
    category: DarsCategory.akhlaq,
    darsCount: 10,
  ),
  const DarsTopic(
    id: 't5',
    title: 'Tafsir al-Fatiha',
    arabicTitle: 'تفسير سورة الفاتحة',
    category: DarsCategory.tafsir,
    darsCount: 4,
  ),
];

// ── Mock Dars List ────────────────────────────────────────────────────────────

final mockDarsList = <Dars>[
  Dars(
    id: 'd1',
    title: 'Introduction to Aqeedah',
    arabicTitle: 'مقدمة في علم العقيدة',
    description:
        'A comprehensive introduction to Islamic theology, covering the fundamentals of faith and the six pillars of Iman.',
    scholar: mockScholars[0],
    category: DarsCategory.aqeedah,
    topic: mockTopics[0],
    type: DarsType.audio,
    thumbnailUrl: null,
    audioUrl: 'https://example.com/audio/aqeedah_intro.mp3',
    duration: const Duration(minutes: 48, seconds: 30),
    publishedAt: DateTime(2024, 1, 15),
    viewCount: 12450,
    rating: 4.8,
    tags: ['aqeedah', 'faith', 'theology'],
    courseId: 'c1',
    courseOrder: 1,
  ),
  Dars(
    id: 'd2',
    title: 'Seerah: The Birth of the Prophet ﷺ',
    arabicTitle: 'السيرة: مولد النبي ﷺ',
    description:
        'Exploring the historical context of the birth of Prophet Muhammad ﷺ and the state of Arabia before Islam.',
    scholar: mockScholars[1],
    category: DarsCategory.seerah,
    topic: mockTopics[1],
    type: DarsType.video,
    thumbnailUrl: null,
    videoUrl: 'https://example.com/video/seerah_birth.mp4',
    duration: const Duration(hours: 1, minutes: 12),
    publishedAt: DateTime(2024, 2, 3),
    viewCount: 8900,
    rating: 4.9,
    tags: ['seerah', 'prophet', 'history'],
    courseId: 'c2',
    courseOrder: 1,
  ),
  Dars(
    id: 'd3',
    title: 'Tafsir Surah Al-Fatiha',
    arabicTitle: 'تفسير سورة الفاتحة',
    description:
        'Deep linguistic and spiritual analysis of Surah Al-Fatiha, the opening chapter of the Quran.',
    scholar: mockScholars[2],
    category: DarsCategory.tafsir,
    topic: mockTopics[4],
    type: DarsType.audio,
    thumbnailUrl: null,
    audioUrl: 'https://example.com/audio/tafsir_fatiha.mp3',
    duration: const Duration(minutes: 55),
    publishedAt: DateTime(2024, 3, 10),
    viewCount: 21300,
    rating: 5.0,
    tags: ['tafsir', 'quran', 'fatiha'],
    courseId: null,
    courseOrder: null,
  ),
  Dars(
    id: 'd4',
    title: 'The Fiqh of Prayer',
    arabicTitle: 'فقه الصلاة',
    description:
        'A practical guide to the correct performance of the five daily prayers according to the Shafi\'i madhab.',
    scholar: mockScholars[3],
    category: DarsCategory.fiqh,
    topic: mockTopics[2],
    type: DarsType.video,
    thumbnailUrl: null,
    videoUrl: 'https://example.com/video/fiqh_salah.mp4',
    duration: const Duration(hours: 1, minutes: 30),
    publishedAt: DateTime(2024, 4, 5),
    viewCount: 15700,
    rating: 4.7,
    tags: ['fiqh', 'salah', 'prayer'],
    courseId: 'c3',
    courseOrder: 1,
  ),
  Dars(
    id: 'd5',
    title: 'Purifying the Heart',
    arabicTitle: 'تزكية القلب',
    description:
        'How to cleanse the heart from spiritual diseases such as envy, arrogance, and attachment to this world.',
    scholar: mockScholars[4],
    category: DarsCategory.akhlaq,
    topic: mockTopics[3],
    type: DarsType.audio,
    thumbnailUrl: null,
    audioUrl: 'https://example.com/audio/purifying_heart.mp3',
    duration: const Duration(minutes: 42),
    publishedAt: DateTime(2024, 5, 20),
    viewCount: 9800,
    rating: 4.6,
    tags: ['akhlaq', 'heart', 'spirituality'],
    courseId: null,
    courseOrder: null,
  ),
  Dars(
    id: 'd6',
    title: 'Introduction to Hadith Sciences',
    arabicTitle: 'مقدمة في علوم الحديث',
    description:
        'Understanding the classification, authentication and study of Prophetic traditions.',
    scholar: mockScholars[0],
    category: DarsCategory.hadith,
    type: DarsType.audio,
    thumbnailUrl: null,
    audioUrl: 'https://example.com/audio/hadith_sciences.mp3',
    duration: const Duration(hours: 1, minutes: 5),
    publishedAt: DateTime(2024, 6, 8),
    viewCount: 7200,
    rating: 4.8,
    tags: ['hadith', 'sciences', 'isnad'],
    courseId: 'c1',
    courseOrder: 2,
  ),
  Dars(
    id: 'd7',
    title: 'Islamic History: The Rightly Guided Caliphs',
    arabicTitle: 'التاريخ الإسلامي: الخلفاء الراشدون',
    description:
        'A journey through the era of Abu Bakr, Umar, Uthman, and Ali رضي الله عنهم.',
    scholar: mockScholars[1],
    category: DarsCategory.islamicHistory,
    type: DarsType.video,
    thumbnailUrl: null,
    videoUrl: 'https://example.com/video/caliphs.mp4',
    duration: const Duration(hours: 1, minutes: 45),
    publishedAt: DateTime(2024, 7, 14),
    viewCount: 11200,
    rating: 4.9,
    tags: ['history', 'caliphs', 'companions'],
    courseId: 'c2',
    courseOrder: 2,
  ),
  Dars(
    id: 'd8',
    title: 'Ramadan: A Month of Transformation',
    arabicTitle: 'رمضان: شهر التحول',
    description:
        'How to make the most of the blessed month of Ramadan through worship, reflection, and community.',
    scholar: mockScholars[2],
    category: DarsCategory.ramadan,
    type: DarsType.audio,
    thumbnailUrl: null,
    audioUrl: 'https://example.com/audio/ramadan_transform.mp3',
    duration: const Duration(minutes: 38),
    publishedAt: DateTime(2024, 3, 1),
    viewCount: 18500,
    rating: 4.9,
    tags: ['ramadan', 'fasting', 'worship'],
    courseId: null,
    courseOrder: null,
  ),
  Dars(
    id: 'd9',
    title: 'The Names of Allah: Al-Rahman',
    arabicTitle: 'أسماء الله: الرحمن',
    description:
        'Deep dive into the name Al-Rahman (The Most Merciful) and how it should transform our relationship with Allah.',
    scholar: mockScholars[3],
    category: DarsCategory.aqeedah,
    topic: mockTopics[0],
    type: DarsType.audio,
    thumbnailUrl: null,
    audioUrl: 'https://example.com/audio/al_rahman.mp3',
    duration: const Duration(minutes: 52),
    publishedAt: DateTime(2024, 8, 18),
    viewCount: 6400,
    rating: 4.7,
    tags: ['names', 'allah', 'mercy'],
    courseId: 'c1',
    courseOrder: 3,
  ),
  Dars(
    id: 'd10',
    title: 'General Islamic Ethics',
    arabicTitle: 'الأخلاق الإسلامية العامة',
    description:
        'Understanding the moral framework of Islam and how to implement Islamic values in daily life.',
    scholar: mockScholars[4],
    category: DarsCategory.general,
    type: DarsType.audio,
    thumbnailUrl: null,
    audioUrl: 'https://example.com/audio/islamic_ethics.mp3',
    duration: const Duration(minutes: 35),
    publishedAt: DateTime(2024, 9, 2),
    viewCount: 5100,
    rating: 4.5,
    tags: ['ethics', 'morals', 'character'],
    courseId: null,
    courseOrder: null,
  ),
];

// ── Mock Live Dars ────────────────────────────────────────────────────────────

final mockLiveDars = <LiveDars>[
  LiveDars(
    id: 'l1',
    title: 'Live Friday Reminder',
    arabicTitle: 'تذكير الجمعة المباشر',
    description: 'Weekly live session covering contemporary Islamic questions.',
    scholar: mockScholars[0],
    category: DarsCategory.general,
    scheduledAt: DateTime.now().add(const Duration(hours: 2)),
    estimatedDuration: const Duration(hours: 1),
    status: LiveDarsStatus.upcoming,
    joinUrl: 'https://example.com/live/friday-reminder',
    registeredCount: 340,
  ),
  LiveDars(
    id: 'l2',
    title: 'Tafsir Live Session',
    arabicTitle: 'جلسة تفسير مباشرة',
    description: 'Live Quran tafsir series — continuing Surah Al-Baqarah.',
    scholar: mockScholars[2],
    category: DarsCategory.tafsir,
    scheduledAt: DateTime.now().subtract(const Duration(minutes: 15)),
    estimatedDuration: const Duration(hours: 1, minutes: 30),
    status: LiveDarsStatus.live,
    joinUrl: 'https://example.com/live/tafsir-baqarah',
    registeredCount: 892,
  ),
  LiveDars(
    id: 'l3',
    title: 'Q&A with Sheikh Omar Suleiman',
    arabicTitle: 'أسئلة وأجوبة مع الشيخ عمر سليمان',
    description: 'Open Q&A session on faith, contemporary issues, and more.',
    scholar: mockScholars[1],
    category: DarsCategory.general,
    scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 5)),
    estimatedDuration: const Duration(hours: 2),
    status: LiveDarsStatus.upcoming,
    joinUrl: 'https://example.com/live/qa-omar',
    registeredCount: 1240,
  ),
];

// ── Mock Courses ──────────────────────────────────────────────────────────────

final mockCourses = <DarsCourse>[
  DarsCourse(
    id: 'c1',
    title: 'Foundations of Islamic Theology',
    arabicTitle: 'أساسيات العقيدة الإسلامية',
    description:
        'A structured 10-lesson course covering the core beliefs of Islam from the Quran and Sunnah.',
    scholar: mockScholars[0],
    category: DarsCategory.aqeedah,
    darsIds: ['d1', 'd6', 'd9'],
    publishedAt: DateTime(2024, 1, 1),
    progressPercent: 0.33,
  ),
  DarsCourse(
    id: 'c2',
    title: 'Complete Seerah of the Prophet ﷺ',
    arabicTitle: 'السيرة النبوية الكاملة',
    description:
        'The life of Prophet Muhammad ﷺ from birth to the completion of the message.',
    scholar: mockScholars[1],
    category: DarsCategory.seerah,
    darsIds: ['d2', 'd7'],
    publishedAt: DateTime(2024, 2, 1),
    progressPercent: 0.0,
  ),
  DarsCourse(
    id: 'c3',
    title: 'Fiqh of Worship',
    arabicTitle: 'فقه العبادات',
    description:
        'Practical jurisprudence covering Taharah, Salah, Zakat, Sawm, and Hajj.',
    scholar: mockScholars[3],
    category: DarsCategory.fiqh,
    darsIds: ['d4'],
    publishedAt: DateTime(2024, 4, 1),
    progressPercent: 0.0,
  ),
];

// ── Mock Q&A ──────────────────────────────────────────────────────────────────

final mockQuestions = <DarsQuestion>[
  DarsQuestion(
    id: 'q1',
    darsId: 'd1',
    questionText:
        'Can you explain the difference between Iman and Islam in more detail?',
    askedAt: DateTime(2024, 1, 20),
    status: QuestionStatus.approved,
    answers: [
      DarsAnswer(
        id: 'a1',
        questionId: 'q1',
        answerText:
            'Islam refers to the outward submission — the five pillars. Iman refers to the inward belief — the six pillars. A Muslim may perform outward acts, but a Mumin has both outward deeds and inward conviction.',
        answeredBy: 'Sheikh Yasir Qadhi',
        isScholarAnswer: true,
        answeredAt: DateTime(2024, 1, 22),
      ),
    ],
  ),
  DarsQuestion(
    id: 'q2',
    darsId: 'd1',
    questionText: 'What are the best books to read on Aqeedah for beginners?',
    askedAt: DateTime(2024, 1, 25),
    status: QuestionStatus.approved,
    answers: [
      DarsAnswer(
        id: 'a2',
        questionId: 'q2',
        answerText:
            'Start with "The Three Fundamental Principles" by Ibn Abd al-Wahhab, then "Aqeedah al-Wasitiyyah" by Ibn Taymiyyah. For English readers, "The Fundamentals of Tawheed" by Bilal Philips is excellent.',
        answeredBy: 'Sheikh Yasir Qadhi',
        isScholarAnswer: true,
        answeredAt: DateTime(2024, 1, 27),
      ),
    ],
  ),
];

// ── Recommended Dars (simple local algorithm) ─────────────────────────────────

/// Returns recommended dars based on the provided categories and history.
/// Privacy-conscious: purely local, no external data sent.
List<Dars> getRecommendations({
  Set<DarsCategory> preferredCategories = const {},
  Set<String> watchedIds = const {},
  int limit = 6,
}) {
  final unwatched = mockDarsList.where((d) => !watchedIds.contains(d.id));

  if (preferredCategories.isEmpty) {
    return unwatched.take(limit).toList();
  }

  final preferred = unwatched
      .where((d) => preferredCategories.contains(d.category))
      .toList();
  final others = unwatched
      .where((d) => !preferredCategories.contains(d.category))
      .toList();

  return [...preferred, ...others].take(limit).toList();
}
