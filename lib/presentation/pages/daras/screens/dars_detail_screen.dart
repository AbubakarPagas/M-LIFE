// ─────────────────────────────────────────────────────────────────────────────
// dars_detail_screen.dart — Full lesson detail view
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/dars_controller.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';
import 'dars_audio_player_screen.dart';
import 'dars_qanda_screen.dart';
import 'dars_scholar_profile_screen.dart';
import 'dars_video_player_screen.dart';

class DarsDetailScreen extends StatefulWidget {
  final Dars dars;
  const DarsDetailScreen({super.key, required this.dars});

  @override
  State<DarsDetailScreen> createState() => _DarsDetailScreenState();
}

class _DarsDetailScreenState extends State<DarsDetailScreen> {
  late final DarsController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = DarsController.instance;
    _ctrl.loadQuestionsForDars(widget.dars.id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dars = widget.dars;

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
          CustomScrollView(
            slivers: [
              // ── Hero header ──────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200.h,
                pinned: true,
                backgroundColor: cs.primary,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  onPressed: Get.back,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    onPressed: () => _ctrl.shareDars(dars),
                  ),
                  Obx(
                    () => IconButton(
                      icon: Icon(
                        _ctrl.isBookmarked(dars.id)
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        color: _ctrl.isBookmarked(dars.id)
                            ? kDarsGold
                            : Colors.white,
                      ),
                      onPressed: () => _ctrl.toggleBookmark(dars),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: cs.primary,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 48.h),
                        Container(
                          width: 72.r,
                          height: 72.r,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                          child: Icon(
                            dars.type == DarsType.video
                                ? Icons.play_circle_rounded
                                : Icons.headphones_rounded,
                            color: Colors.white,
                            size: 36.r,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Text(
                            dars.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 80.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Scholar row ────────────────────────────────────────
                    _ScholarRow(dars: dars, ctrl: _ctrl),
                    SizedBox(height: 14.h),

                    // ── Meta chips ─────────────────────────────────────────
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        DarsCategoryChip(category: dars.category),
                        DarsTypeBadge(type: dars.type),
                        _MetaChip(
                          Icons.access_time_rounded,
                          dars.durationFormatted,
                        ),
                        _MetaChip(
                          Icons.visibility_rounded,
                          '${dars.viewCount} views',
                        ),
                        _MetaChip(
                          Icons.star_rounded,
                          dars.rating.toStringAsFixed(1),
                          color: kDarsGold,
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // ── Progress ───────────────────────────────────────────
                    Obx(() {
                      final prog = _ctrl.getProgress(dars.id);
                      if (prog == null || prog.percentComplete == 0) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DarsProgressBar(
                            value: prog.percentComplete,
                            height: 6,
                            showLabel: true,
                          ),
                          SizedBox(height: 14.h),
                        ],
                      );
                    }),

                    // ── Play / Action buttons ──────────────────────────────
                    _ActionButtons(dars: dars, ctrl: _ctrl),
                    SizedBox(height: 18.h),

                    // ── Description ────────────────────────────────────────
                    _Section(
                      title: 'Description',
                      child: Text(
                        dars.description,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 12.5.sp,
                          color: Theme.of(
                            context,
                          ).hintColor.withValues(alpha: 0.70),
                          height: 1.7,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // ── Tags ───────────────────────────────────────────────
                    if (dars.tags.isNotEmpty)
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: dars.tags
                            .map(
                              (t) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 9.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: cs.primary.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Text(
                                  '#$t',
                                  style: TextStyle(
                                    fontFamily: 'kufi',
                                    fontSize: 10.sp,
                                    color: cs.primary.withValues(alpha: 0.75),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    SizedBox(height: 18.h),

                    // ── Q&A preview ────────────────────────────────────────
                    _QandAPreview(dars: dars, ctrl: _ctrl),
                    SizedBox(height: 18.h),

                    // ── Download / Playlist actions ────────────────────────
                    _BottomActions(dars: dars, ctrl: _ctrl),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Scholar Row ───────────────────────────────────────────────────────────────

class _ScholarRow extends StatelessWidget {
  final Dars dars;
  final DarsController ctrl;
  const _ScholarRow({required this.dars, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () =>
          Get.to(() => DarsScholarProfileScreen(scholar: dars.scholar)),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: cs.primary.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            ScholarAvatar(scholar: dars.scholar, size: 44),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dars.scholar.name,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  Text(
                    dars.scholar.arabicName,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'naskh',
                      fontSize: 11.sp,
                      color: kDarsGold.withValues(alpha: 0.75),
                    ),
                  ),
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
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MetaChip(this.icon, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? cs.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: c.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.r, color: c),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 10.sp,
              color: c,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action buttons ────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final Dars dars;
  final DarsController ctrl;
  const _ActionButtons({required this.dars, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isVideo = dars.type == DarsType.video;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              if (isVideo) {
                ctrl.openVideo(dars);
                Get.to(() => DarsVideoPlayerScreen(dars: dars));
              } else {
                ctrl.playAudio(dars);
                Get.to(
                  () => DarsAudioPlayerScreen(dars: dars),
                  transition: Transition.downToUp,
                );
              }
            },
            icon: Icon(
              isVideo ? Icons.play_circle_rounded : Icons.headphones_rounded,
              size: 18.r,
            ),
            label: Text(
              isVideo ? 'Watch Now' : 'Listen Now',
              style: TextStyle(fontFamily: 'kufi', fontSize: 13.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 13.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Obx(() {
          final status = ctrl.getDownloadStatus(dars.id);
          final isDownloaded = status == DownloadStatus.downloaded;
          final isDownloading = status == DownloadStatus.downloading;
          return Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: isDownloaded
                  ? kDarsGreen.withValues(alpha: 0.12)
                  : cs.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDownloaded
                    ? kDarsGreen.withValues(alpha: 0.30)
                    : cs.primary.withValues(alpha: 0.18),
              ),
            ),
            child: isDownloading
                ? Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Obx(() {
                      final p = ctrl.state.downloadProgress[dars.id] ?? 0.0;
                      return CircularProgressIndicator(
                        value: p,
                        strokeWidth: 2,
                        color: cs.primary,
                      );
                    }),
                  )
                : IconButton(
                    onPressed: isDownloaded
                        ? null
                        : () => ctrl.downloadDars(dars),
                    icon: Icon(
                      isDownloaded
                          ? Icons.download_done_rounded
                          : Icons.download_rounded,
                      color: isDownloaded ? kDarsGreen : cs.primary,
                      size: 20.r,
                    ),
                    padding: EdgeInsets.zero,
                  ),
          );
        }),
      ],
    );
  }
}

// ── Section wrapper ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).hintColor,
          ),
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}

// ── Q&A Preview ───────────────────────────────────────────────────────────────

class _QandAPreview extends StatelessWidget {
  final Dars dars;
  final DarsController ctrl;
  const _QandAPreview({required this.dars, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      final questions = ctrl.state.questionsByDars[dars.id] ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Q&A (${questions.length})',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).hintColor,
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => DarsQandAScreen(dars: dars)),
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 11.sp,
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (questions.isEmpty)
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: cs.primary.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.question_answer_rounded,
                    color: cs.primary.withValues(alpha: 0.45),
                    size: 18.r,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Be the first to ask a question',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 11.5.sp,
                      color: Theme.of(
                        context,
                      ).hintColor.withValues(alpha: 0.50),
                    ),
                  ),
                ],
              ),
            )
          else
            ...questions
                .where((q) => q.status == QuestionStatus.approved)
                .take(2)
                .map((q) => _QuestionPreviewTile(question: q, cs: cs)),
        ],
      );
    });
  }
}

class _QuestionPreviewTile extends StatelessWidget {
  final DarsQuestion question;
  final ColorScheme cs;
  const _QuestionPreviewTile({required this.question, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: cs.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.questionText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).hintColor,
            ),
          ),
          if (question.answers.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              question.answers.first.answerText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 10.5.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.55),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Bottom actions ────────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final Dars dars;
  final DarsController ctrl;
  const _BottomActions({required this.dars, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        _ActionTile(
          icon: Icons.playlist_add_rounded,
          label: 'Add to Playlist',
          color: cs.primary,
          onTap: () => _showAddToPlaylistSheet(context),
        ),
        SizedBox(width: 8.w),
        _ActionTile(
          icon: Icons.share_rounded,
          label: 'Share',
          color: kDarsGreen,
          onTap: () => ctrl.shareDars(dars),
        ),
      ],
    );
  }

  void _showAddToPlaylistSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => _AddToPlaylistSheet(dars: dars, ctrl: ctrl),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: color.withValues(alpha: 0.20)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20.r),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddToPlaylistSheet extends StatelessWidget {
  final Dars dars;
  final DarsController ctrl;
  const _AddToPlaylistSheet({required this.dars, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'Add to Playlist',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).hintColor,
              ),
            ),
            SizedBox(height: 14.h),
            Obx(() {
              final playlists = ctrl.state.playlists;
              if (playlists.isEmpty) {
                return Text(
                  'No playlists yet. Create one from the Playlists screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.50),
                  ),
                );
              }
              return Column(
                children: playlists
                    .map(
                      (p) => ListTile(
                        leading: Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.playlist_play_rounded,
                            color: cs.primary,
                            size: 18.r,
                          ),
                        ),
                        title: Text(
                          p.name,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        subtitle: Text(
                          '${p.lessonCount} lessons',
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 10.sp,
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.45),
                          ),
                        ),
                        onTap: () {
                          ctrl.addToPlaylist(p, dars);
                          Get.back();
                        },
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
