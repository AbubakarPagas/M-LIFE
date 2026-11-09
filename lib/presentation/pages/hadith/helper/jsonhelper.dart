/// Builds the asset path for a hadith JSON file.
/// e.g. language="eng", book="bukhari" → "assets/json/eng-bukhari.json"
class JsonHelper {
  static String assetPath(String language, String book) {
    return 'assets/json/$language-$book.json';
  }

  /// Returns all asset paths available for a given language.
  static List<String> pathsForLanguage(String language, List<String> books) {
    return books.map((b) => assetPath(language, b)).toList();
  }
}
