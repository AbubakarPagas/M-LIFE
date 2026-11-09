// ─────────────────────────────────────────────────────────────────────────────
// dars_controller.dart — GetX controller for the complete Dars feature
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/dars_database.dart';
import '../data/dars_mock_data.dart';
import '../models/dars_models.dart';
import 'dars_state.dart';

// ── Tiny UUID helper (no extra package needed) ────────────────────────────────
String _uuid() {
  const chars = '0123456789abcdef';
  final r = DateTime.now().microsecondsSinceEpoch;
  return List.generate(32, (i) => chars[(r >> (i % 8) * 4) & 0xf]).join();
}

class DarsController extends GetxController {
  static DarsController get instance =>
      GetInstance().putOrFind(() => DarsController());

  final DarsState state = DarsState();
  final DarsDatabase _db = DarsDatabase();
  final Dio _dio = Dio();

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  @override
  void onClose() {
    state.dispose();
    super.onClose();
  }

  Future<void> _init() async {
    await Future.wait([
      loadDars(),
      loadScholars(),
      loadCourses(),
      loadLiveDars(),
      _loadBookmarks(),
      _loadHistory(),
      _loadDownloads(),
      _loadPlaylists(),
      _loadFollowedScholars(),
      _loadProgress(),
    ]);
    _buildRecommendations();
    _initAudioPlayer();
  }

  // ── Library / Pagination ───────────────────────────────────────────────────

  Future<void> loadDars({bool refresh = false}) async {
    if (state.isLoadingDars.value) return;
    if (refresh) {
      state.currentPage.value = 0;
      state.allDars.clear();
      state.hasMoreDars.value = true;
    }
    if (!state.hasMoreDars.value) return;

    state.isLoadingDars.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final source = _filteredSortedList();
      final start = state.currentPage.value * DarsState.pageSize;
      if (start >= source.length) {
        state.hasMoreDars.value = false;
        return;
      }
      final end = (start + DarsState.pageSize).clamp(0, source.length);
      state.allDars.addAll(source.sublist(start, end));
      state.currentPage.value++;
      state.hasMoreDars.value = end < source.length;
    } catch (e) {
      state.errorMessage.value = 'Failed to load lessons. Please try again.';
      log('loadDars error: $e', name: 'DarsController');
    } finally {
      state.isLoadingDars.value = false;
    }
  }

  List<Dars> _filteredSortedList() {
    var list = List<Dars>.from(mockDarsList);
    if (state.selectedCategory.value != null) {
      list = list
          .where((d) => d.category == state.selectedCategory.value)
          .toList();
    }
    if (state.filterType.value != null) {
      list = list.where((d) => d.type == state.filterType.value).toList();
    }
    switch (state.sortBy.value) {
      case 'popular':
        list.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        list.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    }
    return list;
  }

  void setCategory(DarsCategory? cat) {
    state.selectedCategory.value = cat;
    loadDars(refresh: true);
  }

  void setSortBy(String sort) {
    state.sortBy.value = sort;
    loadDars(refresh: true);
  }

  void setFilterType(DarsType? type) {
    state.filterType.value = type;
    loadDars(refresh: true);
  }

  // ── Scholars ───────────────────────────────────────────────────────────────

  Future<void> loadScholars() async {
    state.scholars.assignAll(mockScholars);
  }

  List<Dars> getDarsByScholar(String scholarId) =>
      mockDarsList.where((d) => d.scholar.id == scholarId).toList();

  Future<void> toggleFollowScholar(Scholar scholar) async {
    final isFollowing = state.followedScholarIds.contains(scholar.id);
    if (isFollowing) {
      await _db.unfollowScholar(scholar.id);
      state.followedScholarIds.remove(scholar.id);
    } else {
      await _db.followScholar({
        'scholar_id': scholar.id,
        'scholar_name': scholar.name,
        'arabic_name': scholar.arabicName,
        'photo_url': scholar.photoUrl,
        'followed_at_ms': DateTime.now().millisecondsSinceEpoch,
      });
      state.followedScholarIds.add(scholar.id);
    }
  }

  bool isFollowingScholar(String scholarId) =>
      state.followedScholarIds.contains(scholarId);

  Future<void> _loadFollowedScholars() async {
    try {
      final rows = await _db.getFollowedScholars();
      state.followedScholarIds.assignAll(
        rows.map((r) => r['scholar_id'] as String),
      );
    } catch (e) {
      log('_loadFollowedScholars: $e', name: 'DarsController');
    }
  }

  // ── Courses ────────────────────────────────────────────────────────────────

  Future<void> loadCourses() async {
    state.isLoadingCourses.value = true;
    await Future.delayed(const Duration(milliseconds: 200));
    final enriched = mockCourses.map((c) {
      final completedCount = c.darsIds
          .where((id) => state.progressMap[id]?.isCompleted == true)
          .length;
      final progress = c.darsIds.isEmpty
          ? 0.0
          : completedCount / c.darsIds.length;
      return c.copyWith(progressPercent: progress);
    }).toList();
    state.courses.assignAll(enriched);
    state.isLoadingCourses.value = false;
  }

  List<Dars> getCourseLessons(String courseId) =>
      mockDarsList.where((d) => d.courseId == courseId).toList()
        ..sort((a, b) => (a.courseOrder ?? 0).compareTo(b.courseOrder ?? 0));

  // ── Live Dars ──────────────────────────────────────────────────────────────

  Future<void> loadLiveDars() async {
    state.liveDars.assignAll(mockLiveDars);
    try {
      final reminders = await _db.getLiveReminders();
      state.liveReminderIds.assignAll(
        reminders.map((r) => r['live_id'] as String),
      );
    } catch (e) {
      log('loadLiveDars: $e', name: 'DarsController');
    }
  }

  Future<void> toggleLiveReminder(LiveDars live) async {
    final hasReminder = state.liveReminderIds.contains(live.id);
    if (hasReminder) {
      await _db.removeLiveReminder(live.id);
      state.liveReminderIds.remove(live.id);
    } else {
      await _db.setLiveReminder({
        'live_id': live.id,
        'title': live.title,
        'scheduled_at_ms': live.scheduledAt.millisecondsSinceEpoch,
      });
      state.liveReminderIds.add(live.id);
    }
  }

  bool hasLiveReminder(String liveId) => state.liveReminderIds.contains(liveId);

  // ── Search ─────────────────────────────────────────────────────────────────

  void setSearchQuery(String raw) {
    state.searchDebounce?.cancel();
    state.searchDebounce = Timer(const Duration(milliseconds: 300), () {
      state.searchQuery.value = raw.trim();
      _performSearch(raw.trim());
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      state.searchResults.clear();
      state.isSearching.value = false;
      return;
    }
    state.isSearching.value = true;
    final q = query.toLowerCase();
    final results = mockDarsList.where((d) {
      return d.title.toLowerCase().contains(q) ||
          d.arabicTitle.contains(q) ||
          d.scholar.name.toLowerCase().contains(q) ||
          d.category.displayName.toLowerCase().contains(q) ||
          d.tags.any((t) => t.toLowerCase().contains(q)) ||
          (d.topic?.title.toLowerCase().contains(q) ?? false);
    }).toList();
    state.searchResults.assignAll(results);
    state.isSearching.value = false;
  }

  void clearSearch() {
    state.searchQuery.value = '';
    state.searchResults.clear();
    state.searchDebounce?.cancel();
  }

  // ── Bookmarks ──────────────────────────────────────────────────────────────

  Future<void> toggleBookmark(Dars dars) async {
    final alreadyBookmarked = state.bookmarkedIds.contains(dars.id);
    if (alreadyBookmarked) {
      await _db.deleteBookmark(dars.id);
      state.bookmarkedIds.remove(dars.id);
      state.bookmarks.removeWhere((b) => b.darsId == dars.id);
    } else {
      final id = _uuid();
      final pos = state.progressMap[dars.id]?.position.inSeconds;
      await _db.insertBookmark({
        'id': id,
        'dars_id': dars.id,
        'dars_title': dars.title,
        'scholar_name': dars.scholar.name,
        'thumbnail_url': dars.thumbnailUrl,
        'dars_type': dars.type.name,
        'saved_at_ms': DateTime.now().millisecondsSinceEpoch,
        'saved_position_secs': pos,
      });
      state.bookmarkedIds.add(dars.id);
      state.bookmarks.insert(
        0,
        DarsBookmark(
          id: id,
          darsId: dars.id,
          darsTitle: dars.title,
          scholarName: dars.scholar.name,
          thumbnailUrl: dars.thumbnailUrl,
          darsType: dars.type,
          savedAt: DateTime.now(),
          savedPosition: pos != null ? Duration(seconds: pos) : null,
        ),
      );
    }
  }

  bool isBookmarked(String darsId) => state.bookmarkedIds.contains(darsId);

  Future<void> _loadBookmarks() async {
    try {
      final rows = await _db.getAllBookmarks();
      final bookmarks = rows
          .map(
            (r) => DarsBookmark(
              id: r['id'] as String,
              darsId: r['dars_id'] as String,
              darsTitle: r['dars_title'] as String,
              scholarName: r['scholar_name'] as String,
              thumbnailUrl: r['thumbnail_url'] as String?,
              darsType: DarsType.values.firstWhere(
                (t) => t.name == r['dars_type'],
                orElse: () => DarsType.audio,
              ),
              savedAt: DateTime.fromMillisecondsSinceEpoch(
                r['saved_at_ms'] as int,
              ),
              savedPosition: r['saved_position_secs'] != null
                  ? Duration(seconds: r['saved_position_secs'] as int)
                  : null,
            ),
          )
          .toList();
      state.bookmarks.assignAll(bookmarks);
      state.bookmarkedIds.assignAll(bookmarks.map((b) => b.darsId));
    } catch (e) {
      log('_loadBookmarks: $e', name: 'DarsController');
    }
  }

  // ── History ────────────────────────────────────────────────────────────────

  Future<void> addToHistory(Dars dars, {Duration? position}) async {
    final pos = position ?? Duration.zero;
    final progress = state.progressMap[dars.id];
    await _db.upsertHistory({
      'dars_id': dars.id,
      'dars_title': dars.title,
      'scholar_name': dars.scholar.name,
      'thumbnail_url': dars.thumbnailUrl,
      'dars_type': dars.type.name,
      'last_position_secs': pos.inSeconds,
      'watched_at_ms': DateTime.now().millisecondsSinceEpoch,
      'is_completed': (progress?.isCompleted ?? false) ? 1 : 0,
    });
    final entry = DarsHistoryEntry(
      darsId: dars.id,
      darsTitle: dars.title,
      scholarName: dars.scholar.name,
      thumbnailUrl: dars.thumbnailUrl,
      darsType: dars.type,
      lastPosition: pos,
      watchedAt: DateTime.now(),
      isCompleted: progress?.isCompleted ?? false,
    );
    state.history.removeWhere((h) => h.darsId == dars.id);
    state.history.insert(0, entry);
  }

  Future<void> clearHistory() async {
    await _db.clearHistory();
    state.history.clear();
  }

  Future<void> removeHistoryEntry(String darsId) async {
    await _db.deleteHistoryEntry(darsId);
    state.history.removeWhere((h) => h.darsId == darsId);
  }

  Future<void> _loadHistory() async {
    try {
      final rows = await _db.getHistory();
      state.history.assignAll(
        rows.map(
          (r) => DarsHistoryEntry(
            darsId: r['dars_id'] as String,
            darsTitle: r['dars_title'] as String,
            scholarName: r['scholar_name'] as String,
            thumbnailUrl: r['thumbnail_url'] as String?,
            darsType: DarsType.values.firstWhere(
              (t) => t.name == r['dars_type'],
              orElse: () => DarsType.audio,
            ),
            lastPosition: Duration(seconds: r['last_position_secs'] as int),
            watchedAt: DateTime.fromMillisecondsSinceEpoch(
              r['watched_at_ms'] as int,
            ),
            isCompleted: (r['is_completed'] as int) == 1,
          ),
        ),
      );
    } catch (e) {
      log('_loadHistory: $e', name: 'DarsController');
    }
  }

  List<DarsHistoryEntry> get continueLearning =>
      state.history.where((h) => !h.isCompleted).take(5).toList();

  // ── Progress ───────────────────────────────────────────────────────────────

  Future<void> updateProgress(
    String darsId,
    Duration position,
    Duration total,
  ) async {
    final isCompleted =
        total.inSeconds > 0 && position.inSeconds >= total.inSeconds * 0.95;
    state.progressMap[darsId] = LessonProgress(
      darsId: darsId,
      position: position,
      totalDuration: total,
      isCompleted: isCompleted,
      lastWatched: DateTime.now(),
    );
    await _db.upsertProgress({
      'dars_id': darsId,
      'position_secs': position.inSeconds,
      'total_duration_secs': total.inSeconds,
      'is_completed': isCompleted ? 1 : 0,
      'last_watched_ms': DateTime.now().millisecondsSinceEpoch,
    });
  }

  LessonProgress? getProgress(String darsId) => state.progressMap[darsId];

  Future<void> _loadProgress() async {
    try {
      final rows = await _db.getAllProgress();
      for (final r in rows) {
        state.progressMap[r['dars_id'] as String] = LessonProgress(
          darsId: r['dars_id'] as String,
          position: Duration(seconds: r['position_secs'] as int),
          totalDuration: Duration(seconds: r['total_duration_secs'] as int),
          isCompleted: (r['is_completed'] as int) == 1,
          lastWatched: DateTime.fromMillisecondsSinceEpoch(
            r['last_watched_ms'] as int,
          ),
        );
      }
    } catch (e) {
      log('_loadProgress: $e', name: 'DarsController');
    }
  }

  // ── Downloads ──────────────────────────────────────────────────────────────

  Future<void> downloadDars(Dars dars) async {
    final url = dars.type == DarsType.video ? dars.videoUrl : dars.audioUrl;
    if (url == null) return;

    final id = _uuid();
    final download = DarsDownload(
      id: id,
      darsId: dars.id,
      darsTitle: dars.title,
      scholarName: dars.scholar.name,
      thumbnailUrl: dars.thumbnailUrl,
      darsType: dars.type,
      status: DownloadStatus.downloading,
      downloadedAt: DateTime.now(),
    );
    state.downloads.removeWhere((d) => d.darsId == dars.id);
    state.downloads.insert(0, download);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final ext = dars.type == DarsType.video ? 'mp4' : 'mp3';
      final path = '${dir.path}/dars_${dars.id}.$ext';

      await _dio.download(
        url,
        path,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            state.downloadProgress[dars.id] = progress;
            final idx = state.downloads.indexWhere((d) => d.id == id);
            if (idx != -1) {
              state.downloads[idx] = state.downloads[idx].copyWith(
                progress: progress,
              );
            }
          }
        },
      );

      final file = File(path);
      final fileSize = await file.length();

      await _db.upsertDownload({
        'id': id,
        'dars_id': dars.id,
        'dars_title': dars.title,
        'scholar_name': dars.scholar.name,
        'thumbnail_url': dars.thumbnailUrl,
        'dars_type': dars.type.name,
        'status': 'downloaded',
        'progress': 1.0,
        'local_path': path,
        'file_size_bytes': fileSize,
        'downloaded_at_ms': DateTime.now().millisecondsSinceEpoch,
      });

      final idx = state.downloads.indexWhere((d) => d.id == id);
      if (idx != -1) {
        state.downloads[idx] = state.downloads[idx].copyWith(
          status: DownloadStatus.downloaded,
          progress: 1.0,
          localPath: path,
          fileSizeBytes: fileSize,
        );
      }
    } catch (e) {
      log('downloadDars error: $e', name: 'DarsController');
      final idx = state.downloads.indexWhere((d) => d.id == id);
      if (idx != -1) {
        state.downloads[idx] = state.downloads[idx].copyWith(
          status: DownloadStatus.failed,
        );
      }
    } finally {
      state.downloadProgress.remove(dars.id);
    }
  }

  Future<void> deleteDownload(DarsDownload download) async {
    if (download.localPath != null) {
      final file = File(download.localPath!);
      if (await file.exists()) await file.delete();
    }
    await _db.deleteDownload(download.id);
    state.downloads.removeWhere((d) => d.id == download.id);
  }

  DownloadStatus getDownloadStatus(String darsId) {
    final d = state.downloads.firstWhereOrNull((d) => d.darsId == darsId);
    return d?.status ?? DownloadStatus.notDownloaded;
  }

  bool isDownloaded(String darsId) =>
      getDownloadStatus(darsId) == DownloadStatus.downloaded;

  Future<void> _loadDownloads() async {
    try {
      final rows = await _db.getAllDownloads();
      state.downloads.assignAll(
        rows.map(
          (r) => DarsDownload(
            id: r['id'] as String,
            darsId: r['dars_id'] as String,
            darsTitle: r['dars_title'] as String,
            scholarName: r['scholar_name'] as String,
            thumbnailUrl: r['thumbnail_url'] as String?,
            darsType: DarsType.values.firstWhere(
              (t) => t.name == r['dars_type'],
              orElse: () => DarsType.audio,
            ),
            status: DownloadStatus.values.firstWhere(
              (s) => s.name == r['status'],
              orElse: () => DownloadStatus.notDownloaded,
            ),
            progress: (r['progress'] as num).toDouble(),
            localPath: r['local_path'] as String?,
            fileSizeBytes: r['file_size_bytes'] as int,
            downloadedAt: DateTime.fromMillisecondsSinceEpoch(
              r['downloaded_at_ms'] as int,
            ),
          ),
        ),
      );
    } catch (e) {
      log('_loadDownloads: $e', name: 'DarsController');
    }
  }

  // ── Playlists ──────────────────────────────────────────────────────────────

  Future<DarsPlaylist> createPlaylist(
    String name, {
    String? description,
  }) async {
    final id = _uuid();
    final now = DateTime.now();
    await _db.insertPlaylist({
      'id': id,
      'name': name,
      'description': description,
      'created_at_ms': now.millisecondsSinceEpoch,
      'updated_at_ms': now.millisecondsSinceEpoch,
    });
    final playlist = DarsPlaylist(
      id: id,
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
    state.playlists.insert(0, playlist);
    return playlist;
  }

  Future<void> deletePlaylist(String id) async {
    await _db.deletePlaylist(id);
    state.playlists.removeWhere((p) => p.id == id);
  }

  Future<void> addToPlaylist(DarsPlaylist playlist, Dars dars) async {
    if (playlist.darsIds.contains(dars.id)) return;
    await _db.addToPlaylist({
      'playlist_id': playlist.id,
      'dars_id': dars.id,
      'sort_order': playlist.darsIds.length,
      'dars_title': dars.title,
      'scholar_name': dars.scholar.name,
      'thumbnail_url': dars.thumbnailUrl,
      'dars_type': dars.type.name,
      'duration_secs': dars.duration.inSeconds,
    });
    final idx = state.playlists.indexWhere((p) => p.id == playlist.id);
    if (idx != -1) {
      state.playlists[idx] = playlist.copyWith(
        darsIds: [...playlist.darsIds, dars.id],
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> removeFromPlaylist(DarsPlaylist playlist, String darsId) async {
    await _db.removeFromPlaylist(playlist.id, darsId);
    final idx = state.playlists.indexWhere((p) => p.id == playlist.id);
    if (idx != -1) {
      state.playlists[idx] = playlist.copyWith(
        darsIds: playlist.darsIds.where((id) => id != darsId).toList(),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getPlaylistItems(String playlistId) =>
      _db.getPlaylistItems(playlistId);

  Future<void> _loadPlaylists() async {
    try {
      final rows = await _db.getAllPlaylists();
      final playlists = <DarsPlaylist>[];
      for (final r in rows) {
        final items = await _db.getPlaylistItems(r['id'] as String);
        playlists.add(
          DarsPlaylist(
            id: r['id'] as String,
            name: r['name'] as String,
            description: r['description'] as String?,
            darsIds: items.map((i) => i['dars_id'] as String).toList(),
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              r['created_at_ms'] as int,
            ),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(
              r['updated_at_ms'] as int,
            ),
            coverThumbnailUrl: r['cover_thumbnail_url'] as String?,
          ),
        );
      }
      state.playlists.assignAll(playlists);
    } catch (e) {
      log('_loadPlaylists: $e', name: 'DarsController');
    }
  }

  // ── Q&A ────────────────────────────────────────────────────────────────────

  Future<void> loadQuestionsForDars(String darsId) async {
    try {
      final dbRows = await _db.getQuestionsForDars(darsId);
      final dbQuestions = dbRows.map(
        (r) => DarsQuestion(
          id: r['id'] as String,
          darsId: r['dars_id'] as String,
          questionText: r['question_text'] as String,
          askedAt: DateTime.fromMillisecondsSinceEpoch(r['asked_at_ms'] as int),
          status: QuestionStatus.values.firstWhere(
            (s) => s.name == r['status'],
            orElse: () => QuestionStatus.pending,
          ),
        ),
      );
      final mockQs = mockQuestions.where((q) => q.darsId == darsId).toList();
      state.questionsByDars[darsId] = [...mockQs, ...dbQuestions];
    } catch (e) {
      log('loadQuestionsForDars: $e', name: 'DarsController');
    }
  }

  Future<void> submitQuestion(String darsId, String questionText) async {
    if (questionText.trim().isEmpty) return;
    final id = _uuid();
    await _db.insertQuestion({
      'id': id,
      'dars_id': darsId,
      'question_text': questionText.trim(),
      'asked_at_ms': DateTime.now().millisecondsSinceEpoch,
      'status': 'pending',
    });
    final newQ = DarsQuestion(
      id: id,
      darsId: darsId,
      questionText: questionText.trim(),
      askedAt: DateTime.now(),
      status: QuestionStatus.pending,
    );
    final current = List<DarsQuestion>.from(
      state.questionsByDars[darsId] ?? [],
    );
    current.add(newQ);
    state.questionsByDars[darsId] = current;
  }

  // ── Recommendations ────────────────────────────────────────────────────────

  void _buildRecommendations() {
    final watchedIds = state.history.map((h) => h.darsId).toSet();
    final preferredCats = _inferPreferredCategories();
    final recs = getRecommendations(
      preferredCategories: preferredCats,
      watchedIds: watchedIds,
    );
    state.recommended.assignAll(recs);
  }

  Set<DarsCategory> _inferPreferredCategories() {
    final counts = <DarsCategory, int>{};
    for (final h in state.history) {
      final dars = mockDarsList.firstWhereOrNull((d) => d.id == h.darsId);
      if (dars != null) {
        counts[dars.category] = (counts[dars.category] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toSet();
  }

  // ── Audio Player ───────────────────────────────────────────────────────────

  void _initAudioPlayer() {
    state.audioPlayer = AudioPlayer();

    state.audioPlayer!.playerStateStream.listen((ps) {
      state.isAudioPlaying.value =
          ps.playing && ps.processingState != ProcessingState.completed;
      state.isAudioLoading.value =
          ps.processingState == ProcessingState.loading ||
          ps.processingState == ProcessingState.buffering;

      if (ps.processingState == ProcessingState.completed) {
        final dars = state.currentAudioDars.value;
        if (dars != null) {
          updateProgress(dars.id, dars.duration, dars.duration);
          addToHistory(dars, position: dars.duration);
        }
      }
    });

    state.audioPlayer!.positionStream.listen((pos) {
      state.audioPosition.value = pos;
      if (pos.inSeconds > 0 && pos.inSeconds % 10 == 0) {
        final dars = state.currentAudioDars.value;
        final total = state.audioDuration.value;
        if (dars != null && total.inSeconds > 0) {
          updateProgress(dars.id, pos, total);
        }
      }
    });

    state.audioPlayer!.durationStream.listen((dur) {
      if (dur != null) state.audioDuration.value = dur;
    });
  }

  Future<void> playAudio(Dars dars) async {
    final url = dars.audioUrl;
    if (url == null) return;

    if (state.currentAudioDars.value?.id == dars.id) {
      if (state.audioPlayer!.playing) {
        await state.audioPlayer!.pause();
      } else {
        await state.audioPlayer!.play();
      }
      return;
    }

    state.currentAudioDars.value = dars;
    final localDownload = state.downloads.firstWhereOrNull(
      (d) => d.darsId == dars.id && d.status == DownloadStatus.downloaded,
    );

    try {
      final savedProgress = state.progressMap[dars.id];
      final startPos = savedProgress?.isCompleted == true
          ? Duration.zero
          : savedProgress?.position ?? Duration.zero;

      if (localDownload?.localPath != null) {
        await state.audioPlayer!.setFilePath(localDownload!.localPath!);
      } else {
        await state.audioPlayer!.setUrl(url);
      }

      if (startPos.inSeconds > 0) {
        await state.audioPlayer!.seek(startPos);
      }
      await state.audioPlayer!.play();
      await addToHistory(dars, position: startPos);
    } catch (e) {
      log('playAudio error: $e', name: 'DarsController');
      state.errorMessage.value = 'Could not play audio. Please try again.';
    }
  }

  Future<void> pauseAudio() async => state.audioPlayer?.pause();

  Future<void> seekAudio(Duration position) async {
    await state.audioPlayer?.seek(position);
    final dars = state.currentAudioDars.value;
    if (dars != null) {
      await updateProgress(dars.id, position, state.audioDuration.value);
    }
  }

  Future<void> skipForwardAudio({int seconds = 30}) async {
    final newPos = state.audioPosition.value + Duration(seconds: seconds);
    final cap = state.audioDuration.value;
    await seekAudio(newPos > cap ? cap : newPos);
  }

  Future<void> skipBackwardAudio({int seconds = 10}) async {
    final newPos = state.audioPosition.value - Duration(seconds: seconds);
    await seekAudio(newPos < Duration.zero ? Duration.zero : newPos);
  }

  Future<void> setAudioSpeed(double speed) async {
    state.audioSpeed.value = speed;
    await state.audioPlayer?.setSpeed(speed);
  }

  Future<void> stopAudio() async {
    final dars = state.currentAudioDars.value;
    if (dars != null) {
      await updateProgress(
        dars.id,
        state.audioPosition.value,
        state.audioDuration.value,
      );
      await addToHistory(dars, position: state.audioPosition.value);
    }
    await state.audioPlayer?.stop();
    state.currentAudioDars.value = null;
    state.audioPosition.value = Duration.zero;
    state.audioDuration.value = Duration.zero;
  }

  double get audioProgressPercent {
    final total = state.audioDuration.value.inSeconds;
    if (total == 0) return 0.0;
    return (state.audioPosition.value.inSeconds / total).clamp(0.0, 1.0);
  }

  // ── Video Player ───────────────────────────────────────────────────────────

  Future<void> openVideo(Dars dars) async {
    state.currentVideoDars.value = dars;
    final saved = state.progressMap[dars.id];
    state.videoPosition.value = saved?.isCompleted == true
        ? Duration.zero
        : saved?.position ?? Duration.zero;
    state.videoDuration.value = dars.duration;
    await addToHistory(dars, position: state.videoPosition.value);
  }

  Future<void> updateVideoProgress(Duration pos, Duration total) async {
    state.videoPosition.value = pos;
    state.videoDuration.value = total;
    final dars = state.currentVideoDars.value;
    if (dars != null) await updateProgress(dars.id, pos, total);
  }

  // ── Sharing ────────────────────────────────────────────────────────────────

  Future<void> shareDars(Dars dars) async {
    final deepLink = 'https://mishabpath.app/dars/${dars.id}';
    await SharePlus.instance.share(
      ShareParams(
        text:
            '🎙️ ${dars.title}\n'
            '👨‍🏫 ${dars.scholar.name}\n'
            '📚 ${dars.category.displayName}\n\n'
            'Listen on Mishab Path: $deepLink',
        subject: dars.title,
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Dars? getDarsById(String id) =>
      mockDarsList.firstWhereOrNull((d) => d.id == id);

  Scholar? getScholarById(String id) =>
      mockScholars.firstWhereOrNull((s) => s.id == id);

  DarsCourse? getCourseById(String id) =>
      mockCourses.firstWhereOrNull((c) => c.id == id);

  String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  String formatRelativeDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }
}
