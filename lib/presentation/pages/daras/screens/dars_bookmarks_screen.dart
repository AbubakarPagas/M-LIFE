// ─────────────────────────────────────────────────────────────────────────────
// dars_bookmarks_screen.dart — All bookmarked lessons
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/dars_controller.dart';
import '../models/dars_models.dart';
import '../widgets/dars_widgets.dart';
import 'dars_detail_screen.dart';

class DarsBookmarksScreen extends StatelessWidget {
  const DarsBookmarksScreen({super.key});

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
                _BookmarksAppBar(cs: cs),
                Expanded(
                  child: Obx(() {
                    final bms = ctrl.state.bookmarks;
                    if (bms.isEmpty) {
                      return const DarsEmptyState(
                        title: 'No Bookmarks',
                        subtitle:
                            'Tap the bookmark icon on any lesson to save it here.',
                        icon: Icons.bookmark_border_rounded,
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 80.h),
                      itemCount: bms.length,
                      itemBuilder: (_, i) {
                        final bm = bms[i];
                        final dars = ctrl.getDarsById(bm.darsId);
                        return _BookmarkTile(
                          bookmark: bm,
                          dars: dars,
                          ctrl: ctrl,
                          cs: cs,
                          isDark: isDark,
                        );
                      },
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

class _BookmarksAppBar extends StatelessWidget {
  final ColorScheme cs;
  const _BookmarksAppBar({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المحفوظات',
                  // textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 11.sp,
                    color: kDarsGold,
                  ),
                ),
                Text(
                  'Bookmarks',
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
          Obx(() {
            final count = DarsController.instance.state.bookmarks.length;
            return Text(
              '$count saved',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 10.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.40),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  final DarsBookmark bookmark;
  final Dars? dars;
  final DarsController ctrl;
  final ColorScheme cs;
  final bool isDark;
  const _BookmarkTile({
    required this.bookmark,
    required this.dars,
    required this.ctrl,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');

    return GestureDetector(
      onTap: () {
        if (dars != null) {
          Get.to(() => DarsDetailScreen(dars: dars!));
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: kDarsGold.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            // Type icon
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.14 : 0.09),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                bookmark.darsType == DarsType.video
                    ? Icons.play_circle_rounded
                    : Icons.headphones_rounded,
                color: cs.primary,
                size: 22.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookmark.darsTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).hintColor,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    bookmark.scholarName,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 10.sp,
                      color: cs.primary.withValues(alpha: 0.65),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Saved ${dateFmt.format(bookmark.savedAt)}',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 9.sp,
                      color: Theme.of(
                        context,
                      ).hintColor.withValues(alpha: 0.38),
                    ),
                  ),
                  if (bookmark.savedPosition != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      'Saved at ${_fmtPos(bookmark.savedPosition!)}',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 9.sp,
                        color: kDarsGold.withValues(alpha: 0.70),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (dars != null) ctrl.toggleBookmark(dars!);
              },
              child: Icon(Icons.bookmark_rounded, color: kDarsGold, size: 22.r),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtPos(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }
}
