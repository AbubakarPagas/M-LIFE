// ─────────────────────────────────────────────────────────────────────────────
// PostDetailScreen — full post detail view
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/ummah_feed_controller.dart';
import '../../data/models/feed_post_model.dart';
import '../widgets/feed_post_card.dart';
import '../widgets/post_action_bar.dart';

const _kGold = Color(0xffCDAD80);

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final post = Get.arguments as FeedPostModel?;
    if (post == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Post not found',
            style: TextStyle(fontFamily: 'kufi', fontSize: 14.sp),
          ),
        ),
      );
    }

    final ctrl = UmmahFeedController.instance;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.secondary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero app bar ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160.h,
            pinned: true,
            backgroundColor: cs.primary,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20.r,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 22.r,
                ),
                onPressed: () => SharePlus.instance.share(
                  ShareParams(
                    text:
                        '${post.title}\n\n${post.description}\n\n${post.reference ?? ''}\n\n— Mishab Path',
                  ),
                ),
              ),
              SizedBox(width: 4.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.primary, cs.primary.withValues(alpha: 0.72)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18.w, 52.h, 18.w, 14.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Category badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _kGold.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: _kGold.withValues(alpha: 0.40),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                post.category.icon,
                                size: 10.r,
                                color: _kGold,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                post.category.label,
                                style: TextStyle(
                                  fontFamily: 'kufi',
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _kGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
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
                        Row(
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 11.r,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              post.authorName,
                              style: TextStyle(
                                fontFamily: 'kufi',
                                fontSize: 11.sp,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            if (post.isVerified)
                              Icon(
                                Icons.verified_rounded,
                                size: 12.r,
                                color: _kGold,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Arabic text
                if (post.arabicText != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.05),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: _kGold.withValues(alpha: 0.22)),
                    ),
                    child: Text(
                      post.arabicText!,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'naskh',
                        fontSize: 18.sp,
                        color: theme.hintColor,
                        height: 1.95,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                ],

                // Translation
                if (post.translation != null) ...[
                  Text(
                    post.translation!,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 13.sp,
                      color: theme.hintColor.withValues(alpha: 0.65),
                      height: 1.65,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],

                // Reference
                if (post.reference != null) ...[
                  Text(
                    post.reference!,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: _kGold,
                    ),
                  ),
                  SizedBox(height: 14.h),
                ],

                // Divider
                Divider(color: cs.primary.withValues(alpha: 0.10), height: 1),
                SizedBox(height: 14.h),

                // Full content or description
                Text(
                  post.fullContent ?? post.description,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    color: theme.hintColor.withValues(alpha: 0.75),
                    height: 1.75,
                  ),
                ),
                SizedBox(height: 20.h),

                // Meta row
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13.r,
                      color: theme.hintColor.withValues(alpha: 0.35),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${post.readingTimeMinutes} min read',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 11.sp,
                        color: theme.hintColor.withValues(alpha: 0.40),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13.r,
                      color: theme.hintColor.withValues(alpha: 0.35),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      ctrl.timeAgo(post.publishedAt),
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 11.sp,
                        color: theme.hintColor.withValues(alpha: 0.40),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Action bar
                PostActionBar(post: post),
                SizedBox(height: 24.h),

                // Related posts
                _RelatedPosts(category: post.category, currentId: post.id),
                SizedBox(height: 48.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Related posts
// ─────────────────────────────────────────────────────────────────────────────
class _RelatedPosts extends StatelessWidget {
  final FeedCategory category;
  final String currentId;

  const _RelatedPosts({required this.category, required this.currentId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ctrl = UmmahFeedController.instance;
    final related = ctrl.posts
        .where((p) => p.category == category && p.id != currentId)
        .take(3)
        .toList();

    if (related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: cs.primary.withValues(alpha: 0.10), height: 1),
        SizedBox(height: 16.h),
        Text(
          'More in ${category.label}',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: theme.hintColor,
          ),
        ),
        SizedBox(height: 12.h),
        ...related.asMap().entries.map(
          (e) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: FeedPostCard(
              post: e.value,
              isFirst: e.key == 0,
              isLast: e.key == related.length - 1,
            ),
          ),
        ),
      ],
    );
  }
}
