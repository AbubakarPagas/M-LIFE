// ─────────────────────────────────────────────────────────────────────────────
// FeedLocalDatasource — authentic Islamic content for the Ummah Feed
// ─────────────────────────────────────────────────────────────────────────────

import '../models/feed_post_model.dart';

class FeedLocalDatasource {
  static final List<FeedPostModel> posts = [
    // ── Quran Verses ─────────────────────────────────────────────────────────
    FeedPostModel(
      id: 'q_001',
      type: PostType.quranVerse,
      category: FeedCategory.quran,
      title: 'Ayat Al-Kursi — The Throne Verse',
      description:
          'The greatest verse in the Quran, describing Allah\'s absolute sovereignty over all creation, His eternal awareness, and His incomprehensible greatness.',
      arabicText:
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ',
      translation:
          '"Allah — there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep."',
      reference: 'Al-Baqarah 2:255',
      authorName: 'Mishab Path',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(hours: 1)),
      readingTimeMinutes: 2,
      appreciateCount: 4821,
      bookmarkCount: 1203,
      fullContent:
          'Ayat Al-Kursi is considered the greatest ayah in the Quran. The Prophet ﷺ said: "Whoever recites Ayat Al-Kursi after every obligatory prayer, nothing will prevent him from entering Paradise except death." (An-Nasa\'i). This verse encapsulates the essence of Tawhid — the oneness and absolute sovereignty of Allah.',
    ),
    FeedPostModel(
      id: 'q_002',
      type: PostType.quranVerse,
      category: FeedCategory.quran,
      title: 'Surah Al-Fatiha — The Opening',
      description:
          'The most recited verse in the Quran, the opening chapter that is recited in every unit of prayer. It encompasses praise, gratitude, and sincere supplication.',
      arabicText:
          'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۝ الرَّحْمَٰنِ الرَّحِيمِ ۝ مَالِكِ يَوْمِ الدِّينِ',
      translation:
          '"All praise is due to Allah, Lord of all worlds — The Entirely Merciful, the Especially Merciful — Master of the Day of Recompense."',
      reference: 'Al-Fatiha 1:2-4',
      authorName: 'Mishab Path',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
      readingTimeMinutes: 2,
      appreciateCount: 6540,
      bookmarkCount: 2100,
      fullContent:
          'Surah Al-Fatiha is called "Umm al-Quran" (Mother of the Quran) and "As-Sab\' Al-Mathani" (The Seven Oft-Repeated Verses). Ibn Abbas narrated that the Prophet ﷺ said: "By Him in Whose hand my soul is, nothing like it has been revealed in the Torah, the Gospel, the Psalms, or the Quran."',
    ),
    FeedPostModel(
      id: 'q_003',
      type: PostType.quranVerse,
      category: FeedCategory.quran,
      title: 'Verse of Light — Nur',
      description:
          'One of the most beautiful verses describing Allah\'s divine light and how it illuminates the heavens and the earth for those who open their hearts.',
      arabicText:
          'اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ ۚ مَثَلُ نُورِهِ كَمِشْكَاةٍ فِيهَا مِصْبَاحٌ',
      translation:
          '"Allah is the Light of the heavens and the earth. The example of His light is like a niche within which is a lamp."',
      reference: 'An-Nur 24:35',
      authorName: 'Mishab Path',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      readingTimeMinutes: 3,
      appreciateCount: 3287,
      bookmarkCount: 987,
    ),
    FeedPostModel(
      id: 'q_004',
      type: PostType.quranVerse,
      category: FeedCategory.quran,
      title: 'Verse of Patience — With Hardship Comes Ease',
      description:
          'A deeply comforting reminder that every difficulty is paired with ease — mentioned twice for emphasis, assuring believers that relief always follows hardship.',
      arabicText:
          'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      translation:
          '"For indeed, with hardship will be ease. Indeed, with hardship will be ease."',
      reference: 'Ash-Sharh 94:5-6',
      authorName: 'Mishab Path',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(hours: 7)),
      readingTimeMinutes: 2,
      appreciateCount: 8902,
      bookmarkCount: 3412,
    ),

    // ── Tafsir ───────────────────────────────────────────────────────────────
    FeedPostModel(
      id: 't_001',
      type: PostType.tafsir,
      category: FeedCategory.tafsir,
      title: 'Tafsir of Ayat Al-Kursi',
      description:
          'Ibn Kathir explains the profound meanings embedded in this great verse — from Al-Hayy (Ever-Living) to Al-Qayyum (Self-Sustaining Sustainer) and what these names reveal about Allah\'s attributes.',
      arabicText: 'لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ',
      translation: 'Neither drowsiness overtakes Him nor sleep',
      reference: 'Al-Baqarah 2:255 — Ibn Kathir Commentary',
      authorName: 'Ibn Kathir (summarized)',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(hours: 9)),
      readingTimeMinutes: 5,
      appreciateCount: 2341,
      bookmarkCount: 876,
      fullContent:
          'Ibn Kathir explains: "Al-Hayy" means the Ever-Living who never dies, while "Al-Qayyum" means the Self-Subsisting Sustainer of all things. The negation of sleep and drowsiness emphasizes that Allah\'s watchfulness over His creation is perfect and eternal — unlike any created being. This verse is the most comprehensive of all Quranic verses in conveying the concept of Tawhid.',
    ),
    FeedPostModel(
      id: 't_002',
      type: PostType.tafsir,
      category: FeedCategory.tafsir,
      title: 'Understanding Surah Al-Ikhlas',
      description:
          'A scholarly explanation of why this short surah is considered equal to one-third of the Quran in reward. Its four verses define the complete concept of Tawhid and refute all forms of polytheism.',
      arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ',
      translation: 'Say: He is Allah, the One. Allah, the Eternal Refuge.',
      reference: 'Al-Ikhlas 112:1-2 — Tafsir As-Sa\'di',
      authorName: 'Imam As-Sa\'di (summarized)',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(hours: 11)),
      readingTimeMinutes: 4,
      appreciateCount: 1987,
      bookmarkCount: 654,
    ),
    FeedPostModel(
      id: 't_003',
      type: PostType.tafsir,
      category: FeedCategory.tafsir,
      title: 'The Meaning of "Sabr" in the Quran',
      description:
          'A comprehensive tafsir exploring how patience (Sabr) appears in over 90 verses, covering three dimensions: patience in obeying Allah, patience in avoiding sin, and patience during trials.',
      reference: 'Various verses — Thematic Tafsir',
      authorName: 'Dr. Yasir Qadhi',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      readingTimeMinutes: 6,
      appreciateCount: 3109,
      bookmarkCount: 1098,
    ),

    // ── Hadith ───────────────────────────────────────────────────────────────
    FeedPostModel(
      id: 'h_001',
      type: PostType.hadith,
      category: FeedCategory.hadith,
      title: 'The Hadith of Intentions',
      description:
          'The most fundamental hadith in Islam — the Prophet ﷺ teaches that every action is judged by its intention. A deed done purely for Allah is rewarded; the same deed done for worldly gain earns only what was intended.',
      arabicText:
          'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
      translation:
          '"Actions are judged by intentions, and every person will get what they intended."',
      reference: 'Sahih Al-Bukhari, Book 1, Hadith 1',
      authorName: 'Mishab Path',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      readingTimeMinutes: 3,
      appreciateCount: 5432,
      bookmarkCount: 2876,
      fullContent:
          'Imam An-Nawawi placed this hadith first in his Forty Hadiths, saying: "This hadith is one of the most important foundations of Islam." Scholars have said it is equivalent to one-third of all Islamic knowledge. Every act of worship — prayer, fasting, charity, knowledge-seeking — is given value by the purity of the niyyah (intention) behind it.',
    ),
    FeedPostModel(
      id: 'h_002',
      type: PostType.hadith,
      category: FeedCategory.hadith,
      title: 'The Hadith on the Best of People',
      description:
          'The Prophet ﷺ defined excellence in character through service — the best among us are those who benefit others most, not those with the most wealth or highest status.',
      arabicText: 'خَيْرُ النَّاسِ أَنْفَعُهُمْ لِلنَّاسِ',
      translation: '"The best of people are those most beneficial to people."',
      reference:
          'Al-Mu\'jam Al-Awsat, Al-Tabarani — Authenticated by Al-Albani',
      authorName: 'Mishab Path',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      readingTimeMinutes: 2,
      appreciateCount: 4231,
      bookmarkCount: 1543,
    ),
    FeedPostModel(
      id: 'h_003',
      type: PostType.hadith,
      category: FeedCategory.hadith,
      title: 'Hadith on Smiling as Charity',
      description:
          'In a beautiful teaching, the Prophet ﷺ showed that even the simplest gesture — a sincere smile — counts as an act of charity (Sadaqah) when offered to a fellow Muslim.',
      arabicText: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ',
      translation: '"Your smile for your brother is a charity."',
      reference: 'Jami\' At-Tirmidhi, Hadith 1956',
      authorName: 'Mishab Path',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(hours: 14)),
      readingTimeMinutes: 2,
      appreciateCount: 7821,
      bookmarkCount: 3201,
    ),
    FeedPostModel(
      id: 'h_004',
      type: PostType.hadith,
      category: FeedCategory.hadith,
      title: 'The Hadith of the 99 Names',
      description:
          'The Prophet ﷺ revealed that Allah has ninety-nine names, and whosoever memorizes and acts upon them will enter Paradise — a profound invitation to know and love Allah deeply.',
      arabicText:
          'إِنَّ لِلَّهِ تِسْعَةً وَتِسْعِينَ اسْمًا، مِئَةً إِلاَّ وَاحِدًا، مَنْ أَحْصَاهَا دَخَلَ الْجَنَّةَ',
      translation:
          '"Allah has ninety-nine names. Whoever memorizes them will enter Paradise."',
      reference: 'Sahih Al-Bukhari, Hadith 2736',
      authorName: 'Mishab Path',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      readingTimeMinutes: 3,
      appreciateCount: 3890,
      bookmarkCount: 1765,
    ),

    // ── Reminders ────────────────────────────────────────────────────────────
    FeedPostModel(
      id: 'r_001',
      type: PostType.reminder,
      category: FeedCategory.islamicReminder,
      title: 'Your Dua Is Never Wasted',
      description:
          'Every prayer you raise to Allah is heard, recorded, and answered — either immediately, deferred to a better time, or saved as a treasure for the Hereafter. Never despair of supplication.',
      arabicText: 'وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ',
      translation: '"And your Lord says: Call upon Me, I will respond to you."',
      reference: 'Ghafir 40:60',
      authorName: 'Mishab Path',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      readingTimeMinutes: 1,
      appreciateCount: 9123,
      bookmarkCount: 4321,
    ),
    FeedPostModel(
      id: 'r_002',
      type: PostType.reminder,
      category: FeedCategory.islamicReminder,
      title: 'Begin Every Task with Bismillah',
      description:
          'The Prophet ﷺ said any important matter not begun with Bismillah is cut off from blessing. This simple invocation transforms every mundane act into an act of worship.',
      authorName: 'Mishab Path',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(hours: 16)),
      readingTimeMinutes: 1,
      appreciateCount: 6754,
      bookmarkCount: 2987,
    ),
    FeedPostModel(
      id: 'r_003',
      type: PostType.reminder,
      category: FeedCategory.goodDeeds,
      title: 'Plant a Tree — A Sadaqah That Lives On',
      description:
          'The Prophet ﷺ said: "If a Muslim plants a tree or sows seeds, and then a bird, a person, or an animal eats from it, it is regarded as a charitable gift (Sadaqah) for him." Even the smallest environmental act carries eternal reward.',
      arabicText:
          'مَا مِنْ مُسْلِمٍ يَغْرِسُ غَرْسًا إِلاَّ كَانَ مَا أُكِلَ مِنْهُ لَهُ صَدَقَةً',
      translation:
          '"No Muslim plants a plant, except that whatever is eaten from it is a charity for him."',
      reference: 'Sahih Al-Bukhari, Hadith 2320',
      authorName: 'Mishab Path',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      readingTimeMinutes: 2,
      appreciateCount: 4567,
      bookmarkCount: 1890,
    ),

    // ── Islamic News ──────────────────────────────────────────────────────────
    FeedPostModel(
      id: 'n_001',
      type: PostType.islamicNews,
      category: FeedCategory.ummahNews,
      title: 'Masjid Al-Haram Expansion Reaches New Milestone',
      description:
          'The Saudi General Presidency for the Affairs of the Two Holy Mosques announced a new phase of the Grand Mosque expansion, expected to accommodate an additional 1.5 million worshippers by 2027.',
      authorName: 'Ummah News',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      readingTimeMinutes: 3,
      imageUrl: 'https://picsum.photos/seed/makkah/600/400',
      appreciateCount: 2890,
      bookmarkCount: 876,
    ),
    FeedPostModel(
      id: 'n_002',
      type: PostType.islamicNews,
      category: FeedCategory.ummahNews,
      title: 'Global Islamic Relief Effort Raised \$200M in Ramadan',
      description:
          'Muslim charities worldwide reported a record-breaking fundraising season during Ramadan, with over \$200 million raised for humanitarian causes across 47 countries, supporting refugees and disaster relief.',
      authorName: 'Islamic Relief Global',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      readingTimeMinutes: 4,
      imageUrl: 'https://picsum.photos/seed/charity/600/400',
      appreciateCount: 5432,
      bookmarkCount: 1234,
    ),
    FeedPostModel(
      id: 'n_003',
      type: PostType.islamicNews,
      category: FeedCategory.ummahNews,
      title: 'New Islamic Studies Institute Opens in London',
      description:
          'A new institute dedicated to Islamic scholarship, combining traditional learning with contemporary research, has opened its doors in East London, welcoming students from across Europe.',
      authorName: 'Muslim World Monitor',
      isVerified: false,
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      readingTimeMinutes: 3,
      imageUrl: 'https://picsum.photos/seed/institute/600/400',
      appreciateCount: 1876,
      bookmarkCount: 456,
    ),

    // ── Videos ───────────────────────────────────────────────────────────────
    FeedPostModel(
      id: 'v_001',
      type: PostType.video,
      category: FeedCategory.islamicVideos,
      title: 'The Power of Istighfar — Seeking Forgiveness',
      description:
          'Sheikh Omar Suleiman delivers a powerful lecture on why seeking Allah\'s forgiveness is one of the most transformative acts a believer can perform, backed by Quranic verses and Prophetic traditions.',
      authorName: 'Sheikh Omar Suleiman',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(hours: 20)),
      readingTimeMinutes: 1,
      imageUrl: 'https://picsum.photos/seed/video1/600/340',
      videoUrl: 'https://example.com/video1',
      videoDurationSeconds: 2847,
      appreciateCount: 12430,
      bookmarkCount: 4321,
    ),
    FeedPostModel(
      id: 'v_002',
      type: PostType.video,
      category: FeedCategory.islamicVideos,
      title: 'Understanding Tawakkul — Complete Trust in Allah',
      description:
          'A deeply moving exploration of what it truly means to place your trust in Allah while still taking the necessary means, and how this balance leads to inner peace.',
      authorName: 'Nouman Ali Khan',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      readingTimeMinutes: 1,
      imageUrl: 'https://picsum.photos/seed/video2/600/340',
      videoUrl: 'https://example.com/video2',
      videoDurationSeconds: 3612,
      appreciateCount: 9870,
      bookmarkCount: 3456,
    ),

    // ── Audio Lectures ────────────────────────────────────────────────────────
    FeedPostModel(
      id: 'a_001',
      type: PostType.audioLecture,
      category: FeedCategory.lectures,
      title: 'Riyad As-Salihin: Gardens of the Righteous',
      description:
          'A series of audio lectures walking through Imam An-Nawawi\'s classic collection of prophetic hadiths, covering righteous character, worship, and daily life in Islam.',
      authorName: 'Mufti Menk',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      readingTimeMinutes: 1,
      audioUrl: 'https://example.com/audio1',
      videoDurationSeconds: 5420,
      appreciateCount: 7654,
      bookmarkCount: 2345,
    ),
    FeedPostModel(
      id: 'a_002',
      type: PostType.audioLecture,
      category: FeedCategory.lectures,
      title: 'Seerah: The Life of the Prophet ﷺ',
      description:
          'An immersive audio journey through the life of Prophet Muhammad ﷺ — from his birth in Makkah to the completion of the divine message, presented with historical context and spiritual insights.',
      authorName: 'Sheikh Yasir Qadhi',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(days: 4)),
      readingTimeMinutes: 1,
      audioUrl: 'https://example.com/audio2',
      videoDurationSeconds: 7230,
      appreciateCount: 11234,
      bookmarkCount: 5678,
    ),

    // ── Articles ──────────────────────────────────────────────────────────────
    FeedPostModel(
      id: 'ar_001',
      type: PostType.article,
      category: FeedCategory.islamicArticles,
      title: 'The Islamic Concept of Time: Making Every Moment Count',
      description:
          'Islam places extraordinary emphasis on the value of time — the Quran swears by time in Surah Al-Asr, and the Prophet ﷺ warned against its squandering. This article explores practical Islamic time management.',
      authorName: 'Islamic Horizons',
      isVerified: false,
      publishedAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      readingTimeMinutes: 7,
      imageUrl: 'https://picsum.photos/seed/time/600/400',
      appreciateCount: 3456,
      bookmarkCount: 1234,
      fullContent:
          'The opening of Surah Al-Asr is remarkable in its conciseness: "By time, indeed mankind is in loss..." (103:1-2). Imam Al-Shafi\'i said that if people reflected on this surah alone, it would be sufficient guidance for them. Time in Islam is a trust (amanah) — we will be asked about it on the Day of Judgment. The Prophet ﷺ said: "Take advantage of five before five: your youth before your old age, your health before your illness, your wealth before your poverty, your free time before you are preoccupied, and your life before your death." (Authenticated by Al-Hakim)',
    ),
    FeedPostModel(
      id: 'ar_002',
      type: PostType.article,
      category: FeedCategory.seerah,
      title: 'The Treaty of Hudaybiyyah: A Victory Disguised as Defeat',
      description:
          'When the companions signed what appeared to be an unfavorable peace treaty, they were deeply troubled. Allah called it "a clear victory." This article explores the profound wisdom behind this pivotal moment in Islamic history.',
      authorName: 'Dr. Ali Muhammad As-Sallabi',
      isVerified: true,
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      readingTimeMinutes: 8,
      imageUrl: 'https://picsum.photos/seed/hudaybiyya/600/400',
      appreciateCount: 4321,
      bookmarkCount: 1876,
    ),
  ];

  static List<FeedPostModel> getByCategory(FeedCategory category) {
    if (category == FeedCategory.all) return posts;
    return posts.where((p) => p.category == category).toList();
  }

  static List<FeedPostModel> getFeatured() =>
      posts.where((p) => p.appreciateCount > 5000).take(4).toList();

  static Map<String, String> getDailyTip() {
    final tips = [
      {
        'icon': '🤲',
        'title': 'Begin Your Day with Fajr',
        'body':
            'The Prophet ﷺ said the blessings of early morning are unmatched. Start every day with Fajr prayer and Dhikr to fill it with barakah.',
      },
      {
        'icon': '📖',
        'title': 'Read One Page of Quran',
        'body':
            'Even a single page read with reflection and sincerity carries immense reward. Make it a daily habit.',
      },
      {
        'icon': '❤️',
        'title': 'Send Salawat on the Prophet ﷺ',
        'body':
            'Whoever sends one salawat, Allah sends ten blessings upon him. Make it a habit throughout your day.',
      },
      {
        'icon': '🌿',
        'title': 'Say SubhanAllah 100 Times',
        'body':
            'The Prophet ﷺ said saying "SubhanAllah wa bihamdihi" 100 times removes sins even if they are like sea foam.',
      },
      {
        'icon': '🕌',
        'title': 'Pray Your Sunnah Prayers',
        'body':
            'The 12 daily Sunnah prayers build a house for you in Paradise. Do not miss them.',
      },
    ];
    final idx = DateTime.now().dayOfYear % tips.length;
    return tips[idx];
  }
}

extension _DateTimeExt on DateTime {
  int get dayOfYear {
    final start = DateTime(year, 1, 1);
    return difference(start).inDays;
  }
}
