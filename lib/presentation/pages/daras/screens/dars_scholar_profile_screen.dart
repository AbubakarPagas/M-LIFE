// ─────────────────────────────────────────────────────────────────────────────
// dars_scholar_profile_screen.dart — Scholar bio + all their lessons
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/dars_controller.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';
import 'dars_detail_screen.dart';

class DarsScholarProfileScreen extends StatelessWidget {
  final Scholar scholar;
  const DarsScholarProfileScreen({super.key, required this.scholar});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = DarsController.instance;
    final lessons = ctrl.getDarsByScholar(scholar.id);

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
              // ── Hero ───────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 220.h,
                pinned: true,
                backgroundColor: cs.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white),
                  onPressed: Get.back,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: cs.primary,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40.h),
                        ScholarAvatar(scholar: scholar, size: 72),
                        SizedBox(height: 12.h),
                        Text(
                          scholar.name,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          scholar.arabicName,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: 'naskh',
                            fontSize: 13.sp,
                            color: kDarsGold.withValues(alpha: 0.85),
                          ),
                        ),
                        if (scholar.country != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            '📍 ${scholar.country}',
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 10.sp,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 80.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Follow & stats row ─────────────────────────────────
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.library_music_rounded,
                          value: '${scholar.darsCount}',
                          label: 'Lessons',
                          cs: cs,
                        ),
                        SizedBox(width: 8.w),
                        ...scholar.specializations
                            .take(2)
                            .map(
                              (s) => Padding(
                                padding: EdgeInsets.only(right: 6.w),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: kDarsGold.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                        color:
                                            kDarsGold.withValues(alpha: 0.25)),
                                  ),
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontFamily: 'kufi',
                                      fontSize: 9.5.sp,
                                      color: kDarsGold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        const Spacer(),
                        // Follow button
                        Obx(() {
                          final isFollowing =
                              ctrl.isFollowingScholar(scholar.id);
                          return ElevatedButton(
                            onPressed: () =>
                                ctrl.toggleFollowScholar(scholar),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing
                                  ? cs.primary.withValues(alpha: 0.12)
                                  : cs.primary,
                              foregroundColor: isFollowing
                                  ? cs.primary
                                  : Colors.white,
                              side: isFollowing
                                  ? BorderSide(
                                      color: cs.primary
                                          .withValues(alpha: 0.35))
                                  : null,
                              minimumSize: Size(80.w, 34.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w),
                            ),
                            child: Text(
                              isFollowing ? 'Following' : 'Follow',
                              style: TextStyle(
                                  fontFamily: 'kufi', fontSize: 11.sp),
                            ),
                          );
                        }),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // ── Biography ──────────────────────────────────────────
                    Text(
                      'About',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      scholar.biography,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 12.sp,
                        color: Theme.of(context)
                            .hintColor
                            .withValues(alpha: 0.68),
                        height: 1.7,
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // ── Lessons by this scholar ────────────────────────────
                    DarsSectionHeader(
                      title: 'Lessons by ${scholar.name.split(' ').first}',
                      icon: Icons.headphones_rounded,
                    ),
                    if (lessons.isEmpty)
                      const DarsEmptyState(
                        title: 'No Lessons Yet',
                        subtitle:
                            'Check back later for new content from this scholar.',
                        icon: Icons.hourglass_empty_rounded,
                      )
                    else
                      ...lessons.map(
                        (d) => Obx(
                          () => DarsCard(
                            dars: d,
                            onTap: () =>
                                Get.to(() => DarsDetailScreen(dars: d)),
                            isBookmarked: ctrl.isBookmarked(d.id),
                            onBookmarkTap: () => ctrl.toggleBookmark(d),
                            progress:
                                ctrl.getProgress(d.id)?.percentComplete,
                          ),
                        ),
                      ),
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ColorScheme cs;
  const _StatChip(
      {required this.icon,
      required this.value,
      required this.label,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: cs.primary),
          SizedBox(width: 4.w),
          Text(
            '$value $label',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}
