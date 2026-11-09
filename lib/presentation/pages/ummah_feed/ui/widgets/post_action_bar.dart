// ─────────────────────────────────────────────────────────────────────────────
// PostActionBar — appreciate · bookmark · share · read more
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/ummah_feed_controller.dart';
import '../../data/models/feed_post_model.dart';

const _kGold = Color(0xffCDAD80);

class PostActionBar extends StatelessWidget {
  final FeedPostModel post;
  final VoidCallback? onReadMore;

  const PostActionBar({super.key, required this.post, this.onReadMore});

  @override
  Widget build(BuildContext context) {
    final ctrl = UmmahFeedController.instance;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        // ── Appreciate ───────────────────────────────────────────────────────
        _ActionBtn(
          icon: post.isAppreciated
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          label: ctrl.formatCount(post.appreciateCount),
          color: post.isAppreciated
              ? const Color(0xffE53935)
              : theme.hintColor.withValues(alpha: 0.38),
          onTap: () => ctrl.toggleAppreciation(post.id),
        ),
        SizedBox(width: 14.w),
        // ── Bookmark ─────────────────────────────────────────────────────────
        _ActionBtn(
          icon: post.isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          label: ctrl.formatCount(post.bookmarkCount),
          color: post.isBookmarked
              ? _kGold
              : theme.hintColor.withValues(alpha: 0.38),
          onTap: () => ctrl.toggleBookmark(post.id),
        ),
        SizedBox(width: 14.w),
        // ── Share ─────────────────────────────────────────────────────────────
        _ActionBtn(
          icon: Icons.share_rounded,
          color: theme.hintColor.withValues(alpha: 0.38),
          onTap: () => SharePlus.instance.share(
            ShareParams(
              text:
                  '${post.title}\n\n${post.description}\n\n${post.reference ?? ''}\n\n— Mishab Path',
            ),
          ),
        ),
        const Spacer(),
        // ── Read More ────────────────────────────────────────────────────────
        if (onReadMore != null)
          GestureDetector(
            onTap: onReadMore,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Read More',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14.r,
                  color: cs.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(icon, key: ValueKey(icon), color: color, size: 22.r),
          ),
          if (label != null) ...[
            SizedBox(width: 4.w),
            Text(
              label!,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
