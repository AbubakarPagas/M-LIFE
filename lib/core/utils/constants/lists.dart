import 'package:get/get.dart';
import 'package:misbah_path/presentation/controllers/theme_controller.dart';

import 'api_constants.dart';

const List<Map<String, dynamic>> mushafSettingsList = [
  {
    'imageUrl': 'assets/images/quranb.jpg',
  },
  {
    'imageUrl': 'assets/images/quranssss.png',
  },
];

const List<Map<String, dynamic>> themeList = [
   {
    'name': AppTheme.blue,
    'svgUrl': 'assets/svg/theme0.svg',
    'title': 'Blue',
  },
  {
    'name': AppTheme.brown,
    'svgUrl': 'assets/svg/theme1.svg',
    'title': 'Brown',
  },
  {
    'name': AppTheme.green,
    'svgUrl': 'assets/svg/theme3.svg',
    'title': 'Green',
  },  
  {
    'name': AppTheme.dark,
    'svgUrl': 'assets/svg/theme2.svg',
    'title': 'Dark',
  },
];

List<String> translateName = <String>[
  'nothing',
  'English',
  'Español',
  'বাংলা',
  'اردو',
  'Soomaali',
  'bahasa Indonesia',
  'کوردی',
  'Türkçe',
  'Filipino',
];

List<String> shareTranslateName = <String>[
  'English',
  'Español',
  'বাংলা',
  'اردو',
  'Soomaali',
  'bahasa Indonesia',
  'کوردی',
  'Türkçe',
  'Filipino',
  // 'تفسير السعدي'
];

const List<String> semanticsTranslateName = <String>[
  'nothing',
  'English',
  'Spanish',
  'Bengal',
  'Urdu',
  'Somali',
  'Indonesian',
  'kurdish',
  'turkish',
  'filipino',
];


const List surahReaderInfo = [
  {
    'name': 'reader1',
    'readerD': '${ApiConstants.surahUrl1}',
    'readerN': 'abdul_basit_murattal/',
    'readerI': 'basit',
  },
  {
    'name': 'reader2',
    'readerD': '${ApiConstants.surahUrl1}',
    'readerN': 'muhammad_siddeeq_al-minshaawee/',
    'readerI': 'minshawy',
  },
  {
    'name': 'reader3',
    'readerD': '${ApiConstants.surahUrl1}',
    'readerN': 'mahmood_khaleel_al-husaree_iza3a/',
    'readerI': 'husary',
  },
  {
    'name': 'reader4',
    'readerD': '${ApiConstants.surahUrl1}',
    'readerN': 'ahmed_ibn_3ali_al-3ajamy/',
    'readerI': 'ajamy',
  },
  {
    'name': 'reader5',
    'readerD': '${ApiConstants.surahUrl1}',
    'readerN': 'maher_almu3aiqly/year1440/',
    'readerI': 'muaiqly',
  },
  {
    'name': 'reader6',
    'readerD': '${ApiConstants.surahUrl1}',
    'readerN': 'sa3ood_al-shuraym/',
    'readerI': 'saood',
  },
  {
    'name': 'reader7',
    'readerD': '${ApiConstants.surahUrl1}',
    'readerN': 'sa3d_al-ghaamidi/complete/',
    'readerI': 'Ghamadi',
  },
  {
    'name': 'reader8',
    'readerD': '${ApiConstants.surahUrl1}',
    'readerN': 'mustafa_al3azzawi/',
    'readerI': 'mustafa',
  },
  {
    'name': 'reader9',
    'readerD': '${ApiConstants.surahUrl1}',
    'readerN': 'nasser_bin_ali_alqatami/',
    'readerI': 'nasser',
  },
  {
    'name': 'reader10',
    'readerD': '${ApiConstants.surahUrl2}',
    'readerN': 'peshawa/Rewayat-Hafs-A-n-Assem/',
    'readerI': 'qader',
  },
  {
    'name': 'reader11',
    'readerD': '${ApiConstants.surahUrl3}',
    'readerN': 'taher/',
    'readerI': 'taher',
  },
  {
    'name': 'reader12',
    'readerD': '${ApiConstants.surahUrl4}',
    'readerN': 'aloosi/',
    'readerI': 'aloosi',
  },
  {
    'name': 'reader13',
    'readerD': '${ApiConstants.surahUrl4}',
    'readerN': 'wdee3/',
    'readerI': 'wdee3',
  },
  {
    'name': 'reader14',
    'readerD': '${ApiConstants.surahUrl1}',
    'readerN': 'yasser_ad-dussary/',
    'readerI': 'yasser_ad-dussary',
  },
  {
    'name': 'reader15',
    'readerD': '${ApiConstants.surahUrl1}',
    'readerN': 'abdullaah_3awwaad_al-juhaynee/',
    'readerI': 'Juhaynee',
  },
  {
    'name': 'reader16',
    'readerD': '${ApiConstants.surahUrl1}',
    'readerN': 'fares/',
    'readerI': 'Fares',
  },
  {
    'name': 'reader17',
    'readerD': '${ApiConstants.surahUrl1}',
    'readerN': 'muhammad_ayyoob_hq/',
    'readerI': 'ayyoob',
  },
  {
    'name': 'reader18',
    'readerD': '${ApiConstants.surahUrl3}',
    'readerN': 'maher/',
    'readerI': 'maher',
  },
  {
    'name': 'reader19',
    'readerD': '${ApiConstants.surahUrl2}',
    'readerN': 'nufais/Rewayat-Hafs-A-n-Assem/',
    'readerI': 'nufais',
  },
  {
    'name': 'reader20',
    'readerD': '${ApiConstants.surahUrl5}',
    'readerN': 'yasser/',
    'readerI': 'yasser_ad-dussary',
  },
];

List tafsirNameList = [
  {'name': '${'tafIbnkatheerN'.tr}', 'bookName': '${'tafIbnkatheerD'.tr}'},
  {'name': '${'tafBaghawyN'.tr}', 'bookName': '${'tafBaghawyD'.tr}'},
  {'name': '${'tafQurtubiN'.tr}', 'bookName': '${'tafQurtubiD'.tr}'},
  {'name': '${'tafSaadiN'.tr}', 'bookName': '${'tafSaadiD'.tr}'},
  {'name': '${'tafTabariN'.tr}', 'bookName': '${'tafTabariD'.tr}'},
  {'name': 'English', 'bookName': ''},
  {'name': 'Español', 'bookName': ''},
  {'name': 'বাংলা', 'bookName': ''},
  {'name': 'اردو', 'bookName': ''},
  {'name': 'Soomaali', 'bookName': ''},
  {'name': 'bahasa Indonesia', 'bookName': ''},
  {'name': 'کوردی', 'bookName': ''},
  {'name': 'Türkçe', 'bookName': ''},
];

const List tafsirNameRandom = [
  {'name': '${'tafIbnkatheerN'}', 'bookName': '${'tafIbnkatheerD'}'},
  {'name': '${'tafBaghawyN'}', 'bookName': '${'tafBaghawyD'}'},
  {'name': '${'tafQurtubiN'}', 'bookName': '${'tafQurtubiD'}'},
  {'name': '${'tafSaadiN'}', 'bookName': '${'tafSaadiD'}'},
  {'name': '${'tafTabariN'}', 'bookName': '${'tafTabariD'}'},
];

const List ayahReaderInfo = [
  {
    'name': 'reader1',
    'readerD': 'Abdul_Basit_Murattal_192kbps',
    'readerI': 'basit',
    'url': ApiConstants.ayahs2ndSource,
  },
  {
    'name': 'reader2',
    'readerD': 'Minshawy_Murattal_128kbps',
    'readerI': 'minshawy',
    'url': ApiConstants.ayahs2ndSource,
  },
  {
    'name': 'reader3',
    'readerD': 'Husary_128kbps',
    'readerI': 'husary',
    'url': ApiConstants.ayahs2ndSource,
  },
  {
    'name': 'reader4',
    'readerD': '128/ar.ahmedajamy',
    'readerI': 'ajamy',
    'url': ApiConstants.ayahs1stSource,
  },
  {
    'name': 'reader5',
    'readerD': 'MaherAlMuaiqly128kbps',
    'readerI': 'muaiqly',
    'url': ApiConstants.ayahs2ndSource,
  },
  {
    'name': 'reader6',
    'readerD': 'Saood_ash-Shuraym_128kbps',
    'readerI': 'saood',
    'url': ApiConstants.ayahs2ndSource,
  },
  {
    'name': 'reader15',
    'readerD': 'Abdullaah_3awwaad_Al-Juhaynee_128kbps',
    'readerI': 'Juhaynee',
    'url': ApiConstants.ayahs2ndSource,
  },
  {
    'name': 'reader16',
    'readerD': 'Fares_Abbad_64kbps',
    'readerI': 'Fares',
    'url': ApiConstants.ayahs2ndSource,
  },
  {
    'name': 'reader17',
    'readerD': '128/ar.muhammadayyoub',
    'readerI': 'ayyoob',
    'url': ApiConstants.ayahs1stSource,
  },
  {
    'name': 'reader18',
    'readerD': 'MaherAlMuaiqly128kbps',
    'readerI': 'maher',
    'url': ApiConstants.ayahs2ndSource,
  },
  {
    'name': 'reader20',
    'readerD': 'Yasser_Ad-Dussary_128kbps',
    'readerI': 'yasser_ad-dussary',
    'url': ApiConstants.ayahs2ndSource,
  },
];

// monthHadithsList — returns translated hadith content for the current app language.
// Using a getter (not const) so .tr resolves at call-time and always reflects
// the currently selected locale without any manual rebuilds.
List<Map<String, String>> get monthHadithsList => List.generate(
      12,
      (i) {
        final m = i + 1;
        return {
          'hadithPart1': 'hadith_m${m}_part1'.tr,
          'hadithPart2': 'hadith_m${m}_part2'.tr,
          'bookName': 'hadith_m${m}_book'.tr,
        };
      },
    );
