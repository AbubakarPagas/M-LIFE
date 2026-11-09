// ─────────────────────────────────────────────────────────────────────────────
// SurahUrlBuilder
//
// Constructs the remote URL for a full-surah MP3 given the reciter identifier
// stored by quran_library.
//
// quran_library uses identifiers that map to mp3quran.net server slugs, e.g.:
//   "ar.alafasy"   → server8.mp3quran.net/afs/
//   "ar.abdulbasit"→ download.quranicaudio.com/quran/abdulbasitmurattal/
//
// This mapping covers the most common reciters exposed by quran_library.
// Unknown reciter IDs fall back to the first source.
// ─────────────────────────────────────────────────────────────────────────────

class SurahUrlBuilder {
  SurahUrlBuilder._();

  /// Maps the reciter identifier to a base URL.
  static const Map<String, String> _reciterBaseUrls = {
    // quran_library reciters → mp3quran / quranicaudio servers
    'ar.alafasy': 'https://server8.mp3quran.net/afs/',
    'ar.abdulbasit':
        'https://download.quranicaudio.com/quran/abdulbasitmurattal/',
    'ar.abdulbasitmujawwad':
        'https://download.quranicaudio.com/quran/abdulbasit_mujawwad/',
    'ar.husary': 'https://download.quranicaudio.com/quran/husary/',
    'ar.husarymujawwad':
        'https://download.quranicaudio.com/quran/husary_mujawwad/',
    'ar.minshawi': 'https://download.quranicaudio.com/quran/minshawi_murattal/',
    'ar.minshawimujawwad':
        'https://download.quranicaudio.com/quran/minshawi_mujawwad/',
    'ar.shaatri': 'https://server.mp3quran.net/shtr/',
    'ar.mahermuaiqly': 'https://server12.mp3quran.net/maher/',
    'ar.saoodshuraym': 'https://server16.mp3quran.net/shraym/',
    'ar.saudshuraym': 'https://server16.mp3quran.net/shraym/',
    'ar.sudais': 'https://server11.mp3quran.net/sds/',
    'ar.ghamadi': 'https://server8.mp3quran.net/ghamadi/',
    'ar.muaiqly': 'https://server12.mp3quran.net/maher/',
    'ar.parhizgar': 'https://server8.mp3quran.net/prhzkar/',
  };

  /// Default fallback base URL (Abdul Basit murattal).
  static const String _fallbackBase =
      'https://download.quranicaudio.com/quran/abdulbasitmurattal/';

  /// Build the full MP3 URL for [surahNumber] (1–114) given a [reciterId].
  static String buildUrl(int surahNumber, String reciterId) {
    final base = _reciterBaseUrls[reciterId] ?? _fallbackBase;
    final surahStr = surahNumber.toString().padLeft(3, '0');
    return '$base$surahStr.mp3';
  }

  /// Whether the given reciterId is known/mapped.
  static bool isKnownReciter(String reciterId) =>
      _reciterBaseUrls.containsKey(reciterId);
}
