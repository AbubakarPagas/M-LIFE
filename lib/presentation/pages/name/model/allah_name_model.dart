/// Model for a single Name of Allah from the 99 Asma-ul-Husna.
class AllahName {
  final int number;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String description;
  final String quranRef;
  final String reflection;

  const AllahName({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.description,
    required this.quranRef,
    required this.reflection,
  });
}
