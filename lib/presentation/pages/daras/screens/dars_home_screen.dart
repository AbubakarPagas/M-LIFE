// ─────────────────────────────────────────────────────────────────────────────
// dars_home_screen.dart — Dars feature home / dashboard
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/dars_controller.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';
import 'dars_all_screen.dart';
import 'dars_audio_player_screen.dart';
import 'dars_bookmarks_screen.dart';
import 'dars_categories_screen.dart';
import 'dars_courses_screen.dart';
import 'dars_detail_screen.dart';
import 'dars_downloads_screen.dart';
import 'dars_history_screen.dart';
import 'dars_live_screen.dart';
import 'dars_playlists_screen.dart';
import 'dars_scholar_profile_screen.dart';
import 'dars_search_screen.dart';

class DarsHomeScreen extends StatefulWidget {
  const DarsHomeScreen({super.key});

  @override
  State<DarsHomeScreen> createState() => _DarsHomeScreenState();
}

class _DarsHomeScreenState extends State<DarsHomeScreen> {
  late final DarsController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = DarsController.instance;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.tertiary,
      body: Stack(
        children: [
          // ── Islamic geometric background ───────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: DarsIslamicBgPainter(
                primaryColor: cs.primary,
                surfaceColor: cs.surface,
                isDark: isDark,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _DarsHomeAppBar(ctrl: _ctrl, cs: cs),
                Expanded(
                  child: RefreshIndicator(
                    color: cs.primary,
                    onRefresh: () => _ctrl.loadDars(refresh: true),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 100.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Quick-access feature grid ──────────────────────
                          _QuickAccessGrid(ctrl: _ctrl),
                          SizedBox(height: 6.h),

                          // ── Continue Learning ──────────────────────────────
                          Obx(() {
                            final cont = _ctrl.continueLearning;
                            if (cont.isEmpty) return const SizedBox.shrink();
                            return _ContinueLearningSection(
                              entries: cont,
                              ctrl: _ctrl,
                            );
                          }),

                          // ── Live Dars ──────────────────────────────────────
                          Obx(() {
                            final live = _ctrl.state.liveDars
                                .where((l) => l.isActive || l.isUpcoming)
                                .take(2)
                                .toList();
                            if (live.isEmpty) return const SizedBox.shrink();
                            return _LiveDarsSection(items: live, ctrl: _ctrl);
                          }),

                          // ── Recommended ────────────────────────────────────
                          Obx(() {
                            final recs = _ctrl.state.recommended;
                            if (recs.isEmpty) return const SizedBox.shrink();
                            return _RecommendedSection(
                              items: recs,
                              ctrl: _ctrl,
                            );
                          }),

                          // ── Browse Scholars ────────────────────────────────
                          Obx(() {
                            final scholars = _ctrl.state.scholars;
                            if (scholars.isEmpty)
                              return const SizedBox.shrink();
                            return _ScholarsSection(
                              scholars: scholars,
                              ctrl: _ctrl,
                            );
                          }),

                          // ── Courses ────────────────────────────────────────
                          Obx(() {
                            final courses = _ctrl.state.courses;
                            if (courses.isEmpty) return const SizedBox.shrink();
                            return _CoursesSection(
                              courses: courses,
                              ctrl: _ctrl,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Mini audio player ──────────────────────────────────────────────
          Obx(() {
            final current = _ctrl.state.currentAudioDars.value;
            if (current == null) return const SizedBox.shrink();
            return Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MiniAudioPlayer(
                dars: current,
                isPlaying: _ctrl.state.isAudioPlaying.value,
                progress: _ctrl.audioProgressPercent,
                onPlayPause: () => _ctrl.playAudio(current),
                onExpand: () => Get.to(
                  () => DarsAudioPlayerScreen(dars: current),
                  transition: Transition.downToUp,
                ),
                onClose: _ctrl.stopAudio,
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _DarsHomeAppBar extends StatelessWidget {
  final DarsController ctrl;
  final ColorScheme cs;
  const _DarsHomeAppBar({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 12.w, 10.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الدُّرُوس الإسلامية',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 12.sp,
                    color: kDarsGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Islamic Lessons',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).hintColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          DarsAppBarButton(
            icon: Icons.search_rounded,
            tooltip: 'Search lessons',
            onTap: () => Get.to(
              () => const DarsSearchScreen(),
              transition: Transition.downToUp,
            ),
          ),
          SizedBox(width: 8.w),
          DarsAppBarButton(
            icon: Icons.tune_rounded,
            tooltip: 'Browse all',
            onTap: () => Get.to(() => const DarsAllScreen()),
          ),
        ],
      ),
    );
  }
}

// ── Quick-access grid ─────────────────────────────────────────────────────────

class _QuickAccessGrid extends StatelessWidget {
  final DarsController ctrl;
  const _QuickAccessGrid({required this.ctrl});

  static const _items = [
    _GridItem(Icons.library_music_rounded, 'All Lessons', 'all'),
    _GridItem(Icons.category_rounded, 'Categories', 'categories'),
    _GridItem(Icons.live_tv_rounded, 'Live', 'live'),
    _GridItem(Icons.school_rounded, 'Courses', 'courses'),
    _GridItem(Icons.bookmark_rounded, 'Bookmarks', 'bookmarks'),
    _GridItem(Icons.download_rounded, 'Downloads', 'downloads'),
    _GridItem(Icons.history_rounded, 'History', 'history'),
    _GridItem(Icons.playlist_play_rounded, 'Playlists', 'playlists'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 8.w,
      ),
      itemCount: _items.length,
      itemBuilder: (_, i) {
        final item = _items[i];
        return GestureDetector(
          onTap: () => _navigate(item.route),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: cs.primary.withValues(alpha: isDark ? 0.10 : 0.07),
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: isDark ? 0.05 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: isDark ? 0.16 : 0.09),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(item.icon, color: cs.primary, size: 18.r),
                ),
                SizedBox(height: 5.h),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.75),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigate(String route) {
    switch (route) {
      case 'all':
        Get.to(() => const DarsAllScreen());
        break;
      case 'categories':
        Get.to(() => const DarsCategoriesScreen());
        break;
      case 'live':
        Get.to(() => const DarsLiveScreen());
        break;
      case 'courses':
        Get.to(() => const DarsCoursesScreen());
        break;
      case 'bookmarks':
        Get.to(() => const DarsBookmarksScreen());
        break;
      case 'downloads':
        Get.to(() => const DarsDownloadsScreen());
        break;
      case 'history':
        Get.to(() => const DarsHistoryScreen());
        break;
      case 'playlists':
        Get.to(() => const DarsPlaylistsScreen());
        break;
    }
  }
}

class _GridItem {
  final IconData icon;
  final String label;
  final String route;
  const _GridItem(this.icon, this.label, this.route);
}

// ── Continue Learning ─────────────────────────────────────────────────────────

class _ContinueLearningSection extends StatelessWidget {
  final List<DarsHistoryEntry> entries;
  final DarsController ctrl;
  const _ContinueLearningSection({required this.entries, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DarsSectionHeader(
          title: 'Continue Learning',
          arabicTitle: 'تابع التعلم',
          icon: Icons.play_circle_rounded,
          color: kDarsGreen,
          actionLabel: 'See All',
          onActionTap: () => Get.to(() => const DarsHistoryScreen()),
        ),
        SizedBox(
          height: 110.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: entries.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (_, i) {
              final entry = entries[i];
              final dars = ctrl.getDarsById(entry.darsId);
              if (dars == null) return const SizedBox.shrink();
              final prog = ctrl.getProgress(entry.darsId);
              return GestureDetector(
                onTap: () => Get.to(() => DarsDetailScreen(dars: dars)),
                child: Container(
                  width: 200.w,
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: kDarsGreen.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30.r,
                            height: 30.r,
                            decoration: BoxDecoration(
                              color: kDarsGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: kDarsGreen,
                              size: 16.r,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              entry.darsTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'kufi',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).hintColor,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (prog != null)
                        DarsProgressBar(
                          value: prog.percentComplete,
                          color: kDarsGreen,
                          height: 4,
                          showLabel: true,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 14.h),
      ],
    );
  }
}

// ── Live Dars Section ─────────────────────────────────────────────────────────

class _LiveDarsSection extends StatelessWidget {
  final List<LiveDars> items;
  final DarsController ctrl;
  const _LiveDarsSection({required this.items, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DarsSectionHeader(
          title: 'Live & Upcoming',
          arabicTitle: 'مباشر وقادم',
          icon: Icons.live_tv_rounded,
          color: kDarsLive,
          actionLabel: 'See All',
          onActionTap: () => Get.to(() => const DarsLiveScreen()),
        ),
        ...items.map(
          (live) => _LiveCard(live: live, ctrl: ctrl, cs: cs, isDark: isDark),
        ),
        SizedBox(height: 6.h),
      ],
    );
  }
}

class _LiveCard extends StatelessWidget {
  final LiveDars live;
  final DarsController ctrl;
  final ColorScheme cs;
  final bool isDark;
  const _LiveCard({
    required this.live,
    required this.ctrl,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: live.isActive
              ? kDarsLive.withValues(alpha: 0.35)
              : cs.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: live.isActive
                  ? kDarsLive.withValues(alpha: 0.12)
                  : cs.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              live.isActive ? Icons.sensors_rounded : Icons.event_rounded,
              color: live.isActive ? kDarsLive : cs.primary,
              size: 22.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (live.isActive) ...[
                      const LiveBadge(),
                      SizedBox(width: 6.w),
                    ],
                    Expanded(
                      child: Text(
                        live.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  live.scholar.name,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.sp,
                    color: cs.primary.withValues(alpha: 0.70),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (live.isActive)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarsLive,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Join',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Obx(() {
              final hasReminder = ctrl.hasLiveReminder(live.id);
              return GestureDetector(
                onTap: () => ctrl.toggleLiveReminder(live),
                child: Icon(
                  hasReminder
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  color: hasReminder
                      ? kDarsGold
                      : cs.primary.withValues(alpha: 0.40),
                  size: 22.r,
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ── Recommended Section ───────────────────────────────────────────────────────

class _RecommendedSection extends StatelessWidget {
  final List<Dars> items;
  final DarsController ctrl;
  const _RecommendedSection({required this.items, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DarsSectionHeader(
          title: 'Recommended',
          arabicTitle: 'مُوصى به',
          icon: Icons.auto_awesome_rounded,
          color: kDarsGold,
          actionLabel: 'See All',
          onActionTap: () => Get.to(() => const DarsAllScreen()),
        ),
        SizedBox(
          height: 180.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (_, i) => _RecommendedCard(dars: items[i], ctrl: ctrl),
          ),
        ),
        SizedBox(height: 14.h),
      ],
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final Dars dars;
  final DarsController ctrl;
  const _RecommendedCard({required this.dars, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Get.to(() => DarsDetailScreen(dars: dars)),
      child: Container(
        width: 150.w,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: cs.primary.withValues(alpha: isDark ? 0.09 : 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 70.h,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.16 : 0.09),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Icon(
                  dars.type == DarsType.video
                      ? Icons.play_circle_rounded
                      : Icons.headphones_rounded,
                  color: cs.primary,
                  size: 28.r,
                ),
              ),
            ),
            SizedBox(height: 7.h),
            DarsCategoryChip(category: dars.category, small: true),
            SizedBox(height: 4.h),
            Text(
              dars.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).hintColor,
                height: 1.25,
              ),
            ),
            const Spacer(),
            Text(
              dars.durationFormatted,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 9.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scholars Section ──────────────────────────────────────────────────────────

class _ScholarsSection extends StatelessWidget {
  final List<Scholar> scholars;
  final DarsController ctrl;
  const _ScholarsSection({required this.scholars, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DarsSectionHeader(
          title: 'Our Scholars',
          arabicTitle: 'علماؤنا',
          icon: Icons.people_rounded,
          actionLabel: 'See All',
          onActionTap: () => Get.to(() => const DarsAllScholarScreen()),
        ),
        SizedBox(
          height: 88.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: scholars.length,
            separatorBuilder: (_, __) => SizedBox(width: 14.w),
            itemBuilder: (_, i) => ScholarAvatar(
              scholar: scholars[i],
              size: 52,
              showName: true,
              onTap: () =>
                  Get.to(() => DarsScholarProfileScreen(scholar: scholars[i])),
            ),
          ),
        ),
        SizedBox(height: 14.h),
      ],
    );
  }
}

// ── Courses Section ───────────────────────────────────────────────────────────

class _CoursesSection extends StatelessWidget {
  final List<DarsCourse> courses;
  final DarsController ctrl;
  const _CoursesSection({required this.courses, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DarsSectionHeader(
          title: 'Courses',
          arabicTitle: 'الدورات',
          icon: Icons.school_rounded,
          actionLabel: 'See All',
          onActionTap: () => Get.to(() => const DarsCoursesScreen()),
        ),
        ...courses
            .take(2)
            .map(
              (c) => GestureDetector(
                onTap: () => Get.to(() => DarsCourseDetailScreen(course: c)),
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: isDark ? 0.09 : 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(
                            alpha: isDark ? 0.16 : 0.09,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          color: cs.primary,
                          size: 24.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'kufi',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${c.lessonCount} lessons · ${c.scholar.name}',
                              style: TextStyle(
                                fontFamily: 'kufi',
                                fontSize: 10.sp,
                                color: Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: 0.50),
                              ),
                            ),
                            if (c.progressPercent > 0) ...[
                              SizedBox(height: 6.h),
                              DarsProgressBar(
                                value: c.progressPercent,
                                height: 4,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: cs.primary.withValues(alpha: 0.35),
                        size: 20.r,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

// ── All Scholars grid screen ──────────────────────────────────────────────────

class DarsAllScholarScreen extends StatelessWidget {
  const DarsAllScholarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = DarsController.instance;

    return Scaffold(
      backgroundColor: cs.tertiary,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: DarsIslamicBgPainter(
                primaryColor: cs.primary,
                surfaceColor: cs.surface,
                isDark: isDark,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 12.w, 10.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: Get.back,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Theme.of(context).hintColor,
                          size: 22.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'All Scholars',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    final scholars = ctrl.state.scholars;
                    if (scholars.isEmpty) {
                      return const DarsEmptyState(
                        title: 'No Scholars',
                        subtitle: 'Scholar profiles will appear here.',
                        icon: Icons.people_rounded,
                      );
                    }
                    return GridView.builder(
                      padding: EdgeInsets.all(16.r),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.75,
                        mainAxisSpacing: 16.h,
                        crossAxisSpacing: 12.w,
                      ),
                      itemCount: scholars.length,
                      itemBuilder: (_, i) => ScholarAvatar(
                        scholar: scholars[i],
                        size: 60,
                        showName: true,
                        onTap: () => Get.to(
                          () => DarsScholarProfileScreen(scholar: scholars[i]),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
