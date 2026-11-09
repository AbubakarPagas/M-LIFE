// ─────────────────────────────────────────────────────────────────────────────
// dars_state.dart — Observable state for the Dars feature (GetX)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../models/dars_models.dart';

class DarsState {
  // ── Library ───────────────────────────────────────────────────────────────
  final RxList<Dars> allDars = <Dars>[].obs;
  final RxBool isLoadingDars = false.obs;
  final RxBool hasMoreDars = true.obs;
  final RxInt currentPage = 0.obs;
  static const int pageSize = 10;

  // ── Filtering & Sorting ───────────────────────────────────────────────────
  final Rx<DarsCategory?> selectedCategory = Rx<DarsCategory?>(null);
  final RxString sortBy = 'newest'.obs; // newest | popular | rating
  final Rx<DarsType?> filterType = Rx<DarsType?>(null);

  // ── Search ────────────────────────────────────────────────────────────────
  final RxString searchQuery = ''.obs;
  final RxList<Dars> searchResults = <Dars>[].obs;
  final RxBool isSearching = false.obs;
  Timer? searchDebounce;

  // ── Scholars ──────────────────────────────────────────────────────────────
  final RxList<Scholar> scholars = <Scholar>[].obs;
  final RxList<String> followedScholarIds = <String>[].obs;

  // ── Courses ───────────────────────────────────────────────────────────────
  final RxList<DarsCourse> courses = <DarsCourse>[].obs;
  final RxBool isLoadingCourses = false.obs;

  // ── Live Dars ─────────────────────────────────────────────────────────────
  final RxList<LiveDars> liveDars = <LiveDars>[].obs;
  final RxList<String> liveReminderIds = <String>[].obs;

  // ── Bookmarks ─────────────────────────────────────────────────────────────
  final RxList<DarsBookmark> bookmarks = <DarsBookmark>[].obs;
  final RxSet<String> bookmarkedIds = <String>{}.obs;

  // ── History ───────────────────────────────────────────────────────────────
  final RxList<DarsHistoryEntry> history = <DarsHistoryEntry>[].obs;

  // ── Downloads ─────────────────────────────────────────────────────────────
  final RxList<DarsDownload> downloads = <DarsDownload>[].obs;
  final RxMap<String, double> downloadProgress = <String, double>{}.obs;

  // ── Progress tracking ─────────────────────────────────────────────────────
  final RxMap<String, LessonProgress> progressMap =
      <String, LessonProgress>{}.obs;

  // ── Playlists ─────────────────────────────────────────────────────────────
  final RxList<DarsPlaylist> playlists = <DarsPlaylist>[].obs;

  // ── Recommendations ───────────────────────────────────────────────────────
  final RxList<Dars> recommended = <Dars>[].obs;

  // ── Q&A ───────────────────────────────────────────────────────────────────
  final RxMap<String, List<DarsQuestion>> questionsByDars =
      <String, List<DarsQuestion>>{}.obs;

  // ── Audio Player ──────────────────────────────────────────────────────────
  final Rx<Dars?> currentAudioDars = Rx<Dars?>(null);
  final RxBool isAudioPlaying = false.obs;
  final RxBool isAudioLoading = false.obs;
  final Rx<Duration> audioPosition = Duration.zero.obs;
  final Rx<Duration> audioDuration = Duration.zero.obs;
  final RxDouble audioSpeed = 1.0.obs;
  AudioPlayer? audioPlayer;

  // ── Video Player ──────────────────────────────────────────────────────────
  final Rx<Dars?> currentVideoDars = Rx<Dars?>(null);
  final RxBool isVideoPlaying = false.obs;
  final Rx<Duration> videoPosition = Duration.zero.obs;
  final Rx<Duration> videoDuration = Duration.zero.obs;
  final RxDouble videoSpeed = 1.0.obs;
  final RxString selectedVideoQuality = '720p'.obs;

  // ── Notifications ─────────────────────────────────────────────────────────
  final RxBool newDarsNotif = true.obs;
  final RxBool liveDarsNotif = true.obs;
  final RxBool scholarNotif = true.obs;

  // ── Error state ───────────────────────────────────────────────────────────
  final RxString errorMessage = ''.obs;

  void dispose() {
    searchDebounce?.cancel();
    audioPlayer?.dispose();
  }
}
