/// A preset Dhikr with its Arabic text, transliteration, translation and target.
class DhikrPreset {
  final String name;
  final String arabic;
  final String transliteration;
  final String translation;
  final int target;
  final String emoji;

  const DhikrPreset({
    required this.name,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.target,
    required this.emoji,
  });

  static const List<DhikrPreset> defaults = [
    DhikrPreset(
      name: 'SubhanAllah',
      arabic: 'سُبْحَانَ اللَّهِ',
      transliteration: 'Subhan Allah',
      translation: 'Glory be to Allah',
      target: 33,
      emoji: '✨',
    ),
    DhikrPreset(
      name: 'Alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      transliteration: 'Alhamdu lillah',
      translation: 'All praise is due to Allah',
      target: 33,
      emoji: '🌿',
    ),
    DhikrPreset(
      name: 'Allahu Akbar',
      arabic: 'اللَّهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      translation: 'Allah is the Greatest',
      target: 34,
      emoji: '🌟',
    ),
    DhikrPreset(
      name: 'Astaghfirullah',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      transliteration: 'Astaghfirullah',
      translation: 'I seek forgiveness from Allah',
      target: 100,
      emoji: '🤲',
    ),
    DhikrPreset(
      name: 'La ilaha illallah',
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      transliteration: 'La ilaha illallah',
      translation: 'There is no god but Allah',
      target: 100,
      emoji: '☪️',
    ),
  ];
}
