import 'dart:async';
import 'dart:developer';

import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' hide Priority;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:misbah_path/core/utils/constants/lists.dart';
import 'package:quran_library/quran_library.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '/presentation/controllers/theme_controller.dart';
import '../../../core/services/audio/audio_cache_manager.dart';
import '../../../core/services/audio/quran_audio_handler.dart';
import '../../../core/services/audio/surah_url_builder.dart';
import '../../../core/services/notifications_manager.dart';
import '../../../core/utils/constants/extensions/convert_number_extension.dart';
import '../../../core/utils/constants/extensions/extensions.dart';
import '../../../core/utils/constants/extensions/svg_extensions.dart';
import '../../../core/utils/constants/lottie.dart';
import '../../../core/utils/constants/lottie_constants.dart';
import '../../../core/utils/constants/shared_preferences_constants.dart';
import '../../../core/utils/constants/svg_constants.dart';
import '../../../core/widgets/seek_bar.dart';
import '../../../database/audio_cache_db/audio_cache_database.dart';
import '../quran_page/quran.dart';
import '../quran_page/widgets/search/search_extensions/convert_arabic_to_english_numbers_extension.dart';
import '../quran_page/widgets/search/search_extensions/highlight_extension.dart';
import 'data/models/ayah_segment_model.dart';
import 'data/repositories/segment_repository.dart';

part '../surah_audio/audio_surah.dart';
part '../surah_audio/controller/surah_audio_helper.dart';
part '../surah_audio/controller/surah_audio_segment_helper.dart';
part '../surah_audio/controller/surah_audio_state.dart';
part '../surah_audio/controller/surah_download_service.dart';
part '../surah_audio/screens/audio_settings_screen.dart';
part '../surah_audio/screens/audio_storage_screen.dart';
part '../surah_audio/screens/audio_surah_with_ayahs.dart';
part '../surah_audio/widgets/back_drop_widget.dart';
part '../surah_audio/widgets/collapsed_play_widget.dart';
part '../surah_audio/widgets/last_listen.dart';
part '../surah_audio/widgets/online_play_button.dart';
part '../surah_audio/widgets/play_banner.dart';
part '../surah_audio/widgets/play_widget.dart';
part '../surah_audio/widgets/surah_audio_list.dart';
part '../surah_audio/widgets/surah_cache_download_button.dart';
part '../surah_audio/widgets/surah_playback_notifier.dart';
part '../surah_audio/widgets/surah_search.dart';
part '../surah_audio/widgets/surah_seek_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FullReciterMeta — shared model for reciter identity + avatar colours.
// Used by AudioSettingsScreen, AudioStorageScreen, AudioSurahWithAyahs, etc.
// ─────────────────────────────────────────────────────────────────────────────

class FullReciterMeta {
  final String id;
  final String displayName;
  final String initial;
  final Color colorA; // gradient start
  final Color colorB; // gradient end
  final String country;
  final String url;
  final String routeName;
  final String img;

  const FullReciterMeta({
    required this.id,
    required this.displayName,
    required this.initial,
    required this.colorA,
    required this.colorB,
    required this.country,
    required this.url,
    required this.routeName,
    required this.img,
  });
}

/// All known reciters with their avatar colours, initials, and metadata.
const List<FullReciterMeta> kAllReciters = [
  FullReciterMeta(
    id: 'ar.alafasy',
    displayName: 'مشاري راشد العفاسي',
    initial: 'م',
    colorA: Color(0xff2E7D32),
    colorB: Color(0xff66BB6A),
    country: 'الكويت',
    url: 'ar.alafasy',
    routeName: 'alafasy',
    img: '',
  ),
  FullReciterMeta(
    id: 'ar.abdulbasit',
    displayName: 'عبد الباسط عبد الصمد',
    initial: 'ع',
    colorA: Color(0xff1565C0),
    colorB: Color(0xff42A5F5),
    country: 'مصر',
    url: 'ar.abdulbasit',
    routeName: 'abdulbasit',
    img: '',
  ),
  FullReciterMeta(
    id: 'ar.abdulbasitmujawwad',
    displayName: 'عبد الباسط (مجوّد)',
    initial: 'ع',
    colorA: Color(0xff0277BD),
    colorB: Color(0xff29B6F6),
    country: 'مصر',
    url: 'ar.abdulbasitmujawwad',
    routeName: 'abdulbasitmujawwad',
    img: '',
  ),
  FullReciterMeta(
    id: 'ar.husary',
    displayName: 'محمود خليل الحصري',
    initial: 'ح',
    colorA: Color(0xff4A148C),
    colorB: Color(0xffAB47BC),
    country: 'مصر',
    url: 'ar.husary',
    routeName: 'husary',
    img: '',
  ),
  FullReciterMeta(
    id: 'ar.husarymujawwad',
    displayName: 'الحصري (مجوّد)',
    initial: 'ح',
    colorA: Color(0xff6A1B9A),
    colorB: Color(0xffCE93D8),
    country: 'مصر',
    url: 'ar.husarymujawwad',
    routeName: 'husarymujawwad',
    img: '',
  ),
  FullReciterMeta(
    id: 'ar.minshawi',
    displayName: 'محمد صديق المنشاوي',
    initial: 'ن',
    colorA: Color(0xffBF360C),
    colorB: Color(0xffFF7043),
    country: 'مصر',
    url: 'ar.minshawi',
    routeName: 'minshawi',
    img: '',
  ),
  FullReciterMeta(
    id: 'ar.minshawimujawwad',
    displayName: 'المنشاوي (مجوّد)',
    initial: 'ن',
    colorA: Color(0xffD84315),
    colorB: Color(0xffFF8A65),
    country: 'مصر',
    url: 'ar.minshawimujawwad',
    routeName: 'minshawimujawwad',
    img: '',
  ),
  FullReciterMeta(
    id: 'ar.shaatri',
    displayName: 'أبو بكر الشاطري',
    initial: 'ش',
    colorA: Color(0xff33691E),
    colorB: Color(0xff9CCC65),
    country: 'السعودية',
    url: 'ar.shaatri',
    routeName: 'shaatri',
    img: '',
  ),
  FullReciterMeta(
    id: 'ar.mahermuaiqly',
    displayName: 'ماهر المعيقلي',
    initial: 'ه',
    colorA: Color(0xff827717),
    colorB: Color(0xffD4E157),
    country: 'السعودية',
    url: 'ar.mahermuaiqly',
    routeName: 'mahermuaiqly',
    img: '',
  ),
  FullReciterMeta(
    id: 'ar.saoodshuraym',
    displayName: 'سعود الشريم',
    initial: 'س',
    colorA: Color(0xff004D40),
    colorB: Color(0xff26A69A),
    country: 'السعودية',
    url: 'ar.saoodshuraym',
    routeName: 'saoodshuraym',
    img: '',
  ),
  FullReciterMeta(
    id: 'ar.saudshuraym',
    displayName: 'سعود الشريم',
    initial: 'س',
    colorA: Color(0xff004D40),
    colorB: Color(0xff26A69A),
    country: 'السعودية',
    url: 'ar.saudshuraym',
    routeName: 'saudshuraym',
    img: '',
  ),
  FullReciterMeta(
    id: 'ar.sudais',
    displayName: 'عبد الرحمن السديس',
    initial: 'د',
    colorA: Color(0xff880E4F),
    colorB: Color(0xffF06292),
    country: 'السعودية',
    url: 'ar.sudais',
    routeName: 'sudais',
    img: '',
  ),
  FullReciterMeta(
    id: 'ar.ghamadi',
    displayName: 'سعد الغامدي',
    initial: 'غ',
    colorA: Color(0xff37474F),
    colorB: Color(0xff78909C),
    country: 'السعودية',
    url: 'ar.ghamadi',
    routeName: 'ghamadi',
    img: '',
  ),
  FullReciterMeta(
    id: 'ar.muaiqly',
    displayName: 'ماهر المعيقلي',
    initial: 'ه',
    colorA: Color(0xff827717),
    colorB: Color(0xffD4E157),
    country: 'السعودية',
    url: 'ar.muaiqly',
    routeName: 'muaiqly',
    img: '',
  ),
  FullReciterMeta(
    id: 'ar.parhizgar',
    displayName: 'محمد صالح پرهيزگار',
    initial: 'پ',
    colorA: Color(0xff3E2723),
    colorB: Color(0xff8D6E63),
    country: 'إيران',
    url: 'ar.parhizgar',
    routeName: 'parhizgar',
    img: '',
  ),
];

