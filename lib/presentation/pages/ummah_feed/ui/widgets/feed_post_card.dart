// ─────────────────────────────────────────────────────────────────────────────
// FeedPostCard — routes to the correct card type by PostType
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../apps/routes/route_name.dart';
import '../../controllers/ummah_feed_controller.dart';
import '../../data/models/feed_post_model.dart';
import 'post_action_bar.dart';
import 'timeline_connector.dart';

const _kGold = Color(0xffCDAD80);

class FeedPostCard extends StatelessWidget {
  final FeedPostModel post;
  final bool isFirst;
  final bool isLast;

  const FeedPostCard({
    super.key,
    required this.post,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline ──────────────────────────────────────────────────────
          TimelineConnector(
            isFirst: isFirst,
            isLast: isLast,
            category: post.category,
          ),
          SizedBox(width: 10.w),
          // ── Card ──────────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: _buildCard(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return switch (post.type) {
      PostType.quranVerse => _QuranVerseCard(post: post),
      PostType.tafsir => _TafsirCard(post: post),
      PostType.hadith => _HadithCard(post: post),
      PostType.reminder => _ReminderCard(post: post),
      PostType.islamicNews => _NewsCard(post: post),
      PostType.video => _VideoCard(post: post),
      PostType.audioLecture => _AudioCard(post: post),
      PostType.article => _ArticleCard(post: post),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared base card shell
// ─────────────────────────────────────────────────────────────────────────────

class _CardShell extends StatelessWidget {
  final Widget child;
  final Color? borderAccent;

  const _CardShell({required this.child, this.borderAccent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              borderAccent?.withValues(alpha: isDark ? 0.22 : 0.14) ??
              cs.primary.withValues(alpha: isDark ? 0.12 : 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.06 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared header row: category badge + author + time + verified
// ─────────────────────────────────────────────────────────────────────────────

class _PostHeader extends StatelessWidget {
  final FeedPostModel post;
  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctrl = UmmahFeedController.instance;
    final catColor = _catColor(post.category);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Category badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: isDark ? 0.18 : 0.10),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: catColor.withValues(alpha: 0.28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(post.category.icon, size: 11.r, color: catColor),
              SizedBox(width: 4.w),
              Text(
                post.category.label,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: catColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        // Reading time
        Icon(
          Icons.schedule_rounded,
          size: 12.r,
          color: theme.hintColor.withValues(alpha: 0.35),
        ),
        SizedBox(width: 4.w),
        Text(
          '${post.readingTimeMinutes} min',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 11.sp,
            color: theme.hintColor.withValues(alpha: 0.38),
          ),
        ),
        const Spacer(),
        // Verified
        if (post.isVerified) ...[
          Icon(Icons.verified_rounded, size: 13.r, color: _kGold),
          SizedBox(width: 4.w),
        ],
        // Time ago
        Text(
          ctrl.timeAgo(post.publishedAt),
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 11.sp,
            color: theme.hintColor.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }

  Color _catColor(FeedCategory cat) => switch (cat) {
    FeedCategory.quran => const Color(0xff0D7377),
    FeedCategory.tafsir => const Color(0xff2E7D32),
    FeedCategory.hadith => const Color(0xffCDAD80),
    FeedCategory.islamicReminder => const Color(0xff1565C0),
    FeedCategory.islamicVideos => const Color(0xffD32F2F),
    FeedCategory.lectures => const Color(0xff1565C0),
    FeedCategory.ummahNews => const Color(0xff0277BD),
    FeedCategory.seerah => const Color(0xff00695C),
    FeedCategory.islamicArticles => const Color(0xff37474F),
    FeedCategory.goodDeeds => const Color(0xff2E7D32),
    _ => const Color(0xff404C6E),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Author row
// ─────────────────────────────────────────────────────────────────────────────

class _AuthorRow extends StatelessWidget {
  final FeedPostModel post;
  const _AuthorRow({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 26.r,
          height: 26.r,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_rounded,
            size: 14.r,
            color: cs.primary.withValues(alpha: 0.60),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          post.authorName,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: theme.hintColor.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quran Verse Card
// ─────────────────────────────────────────────────────────────────────────────

class _QuranVerseCard extends StatelessWidget {
  final FeedPostModel post;
  const _QuranVerseCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _CardShell(
      borderAccent: const Color(0xff0D7377),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PostHeader(post: post),
            SizedBox(height: 10.h),
            // Arabic
            if (post.arabicText != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(
                    0xff0D7377,
                  ).withValues(alpha: isDark ? 0.12 : 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xff0D7377).withValues(alpha: 0.18),
                  ),
                ),
                child: Text(
                  post.arabicText!,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 18.sp,
                    color: theme.hintColor,
                    height: 1.85,
                  ),
                ),
              ),
            if (post.translation != null) ...[
              SizedBox(height: 8.h),
              Text(
                post.translation!,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 13.sp,
                  color: theme.hintColor.withValues(alpha: 0.62),
                  height: 1.55,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (post.reference != null) ...[
              SizedBox(height: 6.h),
              Text(
                post.reference!,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff0D7377),
                ),
              ),
            ],
            SizedBox(height: 12.h),
            _AuthorRow(post: post),
            SizedBox(height: 10.h),
            PostActionBar(
              post: post,
              onReadMore: post.fullContent != null
                  ? () {
                      UmmahFeedController.instance.markAsRead(post.id);
                      Get.toNamed(RoutesName.ummahFeedDetail, arguments: post);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tafsir Card
// ─────────────────────────────────────────────────────────────────────────────

class _TafsirCard extends StatelessWidget {
  final FeedPostModel post;
  const _TafsirCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _CardShell(
      borderAccent: const Color(0xff2E7D32),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PostHeader(post: post),
            SizedBox(height: 10.h),
            if (post.reference != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xff2E7D32).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  post.reference!,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff2E7D32),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
            if (post.arabicText != null) ...[
              Text(
                post.arabicText!,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'naskh',
                  fontSize: 17.sp,
                  color: theme.hintColor,
                  height: 1.7,
                ),
              ),
              SizedBox(height: 6.h),
            ],
            Text(
              post.title,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: theme.hintColor,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              post.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: theme.hintColor.withValues(alpha: 0.58),
                height: 1.55,
              ),
            ),
            SizedBox(height: 10.h),
            _AuthorRow(post: post),
            SizedBox(height: 10.h),
            PostActionBar(
              post: post,
              onReadMore: () {
                UmmahFeedController.instance.markAsRead(post.id);
                Get.toNamed(RoutesName.ummahFeedDetail, arguments: post);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hadith Card
// ─────────────────────────────────────────────────────────────────────────────

class _HadithCard extends StatelessWidget {
  final FeedPostModel post;
  const _HadithCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _CardShell(
      borderAccent: _kGold,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PostHeader(post: post),
            SizedBox(height: 10.h),
            if (post.arabicText != null) ...[
              Text(
                post.arabicText!,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'naskh',
                  fontSize: 17.sp,
                  color: _kGold,
                  height: 1.75,
                ),
              ),
              SizedBox(height: 8.h),
            ],
            if (post.translation != null) ...[
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: isDark ? 0.10 : 0.06),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: _kGold.withValues(alpha: 0.20)),
                ),
                child: Text(
                  post.translation!,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    color: theme.hintColor.withValues(alpha: 0.70),
                    height: 1.55,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
            ],
            if (post.reference != null)
              Text(
                post.reference!,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: _kGold,
                ),
              ),
            SizedBox(height: 6.h),
            Text(
              post.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: theme.hintColor.withValues(alpha: 0.55),
                height: 1.5,
              ),
            ),
            SizedBox(height: 10.h),
            _AuthorRow(post: post),
            SizedBox(height: 10.h),
            PostActionBar(
              post: post,
              onReadMore: post.fullContent != null
                  ? () {
                      UmmahFeedController.instance.markAsRead(post.id);
                      Get.toNamed(RoutesName.ummahFeedDetail, arguments: post);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reminder Card — gradient background
// ─────────────────────────────────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  final FeedPostModel post;
  const _ReminderCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary,
            cs.primary.withValues(alpha: 0.75),
            cs.primary.withValues(alpha: 0.60),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _kGold.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: _kGold.withValues(alpha: 0.40)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 9.r,
                        color: _kGold,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Reminder',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: _kGold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  UmmahFeedController.instance.timeAgo(post.publishedAt),
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 9.5.sp,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (post.arabicText != null) ...[
              Text(
                post.arabicText!,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'naskh',
                  fontSize: 15.sp,
                  color: _kGold,
                  height: 1.7,
                ),
              ),
              SizedBox(height: 6.h),
            ],
            Text(
              post.title,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              post.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: Colors.white.withValues(alpha: 0.78),
                height: 1.55,
              ),
            ),
            if (post.translation != null) ...[
              SizedBox(height: 8.h),
              Text(
                post.translation!,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12.sp,
                  color: _kGold.withValues(alpha: 0.80),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  size: 14.r,
                  color: Colors.white.withValues(alpha: 0.50),
                ),
                SizedBox(width: 5.w),
                Text(
                  post.authorName,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      UmmahFeedController.instance.toggleBookmark(post.id),
                  child: Icon(
                    post.isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 22.r,
                    color: post.isBookmarked
                        ? _kGold
                        : Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () =>
                      UmmahFeedController.instance.toggleAppreciation(post.id),
                  child: Icon(
                    post.isAppreciated
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 22.r,
                    color: post.isAppreciated
                        ? const Color(0xffF48FB1)
                        : Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// News Card
// ─────────────────────────────────────────────────────────────────────────────

class _NewsCard extends StatelessWidget {
  final FeedPostModel post;
  const _NewsCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return _CardShell(
      borderAccent: const Color(0xff0277BD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Container(
              height: 130.h,
              width: double.infinity,
              color: cs.primary.withValues(alpha: 0.15),
              child: post.imageUrl != null
                  ? Image.network(
                      post.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.public_rounded,
                        size: 40.r,
                        color: cs.primary.withValues(alpha: 0.30),
                      ),
                    )
                  : Icon(
                      Icons.public_rounded,
                      size: 40.r,
                      color: cs.primary.withValues(alpha: 0.30),
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PostHeader(post: post),
                SizedBox(height: 8.h),
                Text(
                  post.title,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.hintColor,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  post.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    color: theme.hintColor.withValues(alpha: 0.55),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 10.h),
                _AuthorRow(post: post),
                SizedBox(height: 10.h),
                PostActionBar(
                  post: post,
                  onReadMore: () {
                    UmmahFeedController.instance.markAsRead(post.id);
                    Get.toNamed(RoutesName.ummahFeedDetail, arguments: post);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Video Card
// ─────────────────────────────────────────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  final FeedPostModel post;
  const _VideoCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ctrl = UmmahFeedController.instance;

    return _CardShell(
      borderAccent: const Color(0xffD32F2F),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 16:9 thumbnail
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  post.imageUrl != null
                      ? Image.network(
                          post.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: cs.primary.withValues(alpha: 0.15),
                          ),
                        )
                      : Container(color: cs.primary.withValues(alpha: 0.15)),
                  // Play button overlay
                  Center(
                    child: Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28.r,
                      ),
                    ),
                  ),
                  // Duration badge
                  if (post.videoDurationSeconds != null)
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.70),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Text(
                          ctrl.formatDuration(post.videoDurationSeconds),
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PostHeader(post: post),
                SizedBox(height: 8.h),
                Text(
                  post.title,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.hintColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  post.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    color: theme.hintColor.withValues(alpha: 0.55),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 10.h),
                _AuthorRow(post: post),
                SizedBox(height: 10.h),
                PostActionBar(post: post),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Audio Lecture Card
// ─────────────────────────────────────────────────────────────────────────────

class _AudioCard extends StatelessWidget {
  final FeedPostModel post;
  const _AudioCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ctrl = UmmahFeedController.instance;

    return _CardShell(
      borderAccent: const Color(0xff1565C0),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PostHeader(post: post),
            SizedBox(height: 12.h),
            Row(
              children: [
                // Scholar avatar
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withValues(alpha: 0.12),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 24.r,
                    color: cs.primary.withValues(alpha: 0.50),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.hintColor,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        post.authorName,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 13.sp,
                          color: const Color(0xff1565C0),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                // Play button
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: const Color(0xff1565C0),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1565C0).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 22.r,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // Duration + progress bar
            Row(
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: 14.r,
                  color: theme.hintColor.withValues(alpha: 0.40),
                ),
                SizedBox(width: 4.w),
                Text(
                  ctrl.formatDuration(post.videoDurationSeconds),
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    color: theme.hintColor.withValues(alpha: 0.45),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Container(
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            PostActionBar(post: post),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Article Card
// ─────────────────────────────────────────────────────────────────────────────

class _ArticleCard extends StatelessWidget {
  final FeedPostModel post;
  const _ArticleCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return _CardShell(
      borderAccent: const Color(0xff37474F),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PostHeader(post: post),
            SizedBox(height: 10.h),
            if (post.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: SizedBox(
                  height: 100.h,
                  width: double.infinity,
                  child: Image.network(
                    post.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: cs.primary.withValues(alpha: 0.10)),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
            Text(
              post.title,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: theme.hintColor,
                height: 1.3,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              post.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: theme.hintColor.withValues(alpha: 0.58),
                height: 1.55,
              ),
            ),
            SizedBox(height: 10.h),
            _AuthorRow(post: post),
            SizedBox(height: 10.h),
            PostActionBar(
              post: post,
              onReadMore: () {
                UmmahFeedController.instance.markAsRead(post.id);
                Get.toNamed(RoutesName.ummahFeedDetail, arguments: post);
              },
            ),
          ],
        ),
      ),
    );
  }
}
