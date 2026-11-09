// ─────────────────────────────────────────────────────────────────────────────
// TimelineConnector — vertical line + dot for the feed timeline
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/feed_post_model.dart';

class TimelineConnector extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final FeedCategory category;

  const TimelineConnector({
    super.key,
    this.isFirst = false,
    this.isLast = false,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(
      context,
    ).colorScheme.primary.withValues(alpha: 0.14);
    final dotColor = _categoryColor(category);

    return SizedBox(
      width: 28.w,
      child: Column(
        children: [
          // Top line
          if (!isFirst)
            Container(width: 2, height: 20.h, color: lineColor)
          else
            SizedBox(height: 20.h),

          // Dot
          Container(
            width: 12.r,
            height: 12.r,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.40),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 5.r,
                height: 5.r,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Bottom line
          if (!isLast)
            Expanded(child: Container(width: 2, color: lineColor))
          else
            SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Color _categoryColor(FeedCategory cat) => switch (cat) {
    FeedCategory.quran => const Color(0xff0D7377),
    FeedCategory.tafsir => const Color(0xff2E7D32),
    FeedCategory.hadith => const Color(0xffCDAD80),
    FeedCategory.dailyDua => const Color(0xff6A1B9A),
    FeedCategory.islamicReminder => const Color(0xff1565C0),
    FeedCategory.goodDeeds => const Color(0xff2E7D32),
    FeedCategory.zakat => const Color(0xffCDAD80),
    FeedCategory.sadaqah => const Color(0xffE53935),
    FeedCategory.waqf => const Color(0xff4527A0),
    FeedCategory.islamicHistory => const Color(0xff6D4C41),
    FeedCategory.seerah => const Color(0xff00695C),
    FeedCategory.islamicArticles => const Color(0xff37474F),
    FeedCategory.islamicVideos => const Color(0xffD32F2F),
    FeedCategory.lectures => const Color(0xff1565C0),
    FeedCategory.ummahNews => const Color(0xff0277BD),
    FeedCategory.ramadan => const Color(0xFF7B1FA2),
    FeedCategory.hajjUmrah => const Color(0xff1B5E20),
    FeedCategory.all => const Color(0xff404C6E),
  };
}
