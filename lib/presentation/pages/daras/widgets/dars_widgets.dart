// ─────────────────────────────────────────────────────────────────────────────
// dars_widgets.dart — Reusable UI components for the Dars feature
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../models/dars_models.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const kDarsGold = Color(0xffCDAD80);
const kDarsGoldDeep = Color(0xffCD9974);
const kDarsGreen = Color(0xff10B981);
const kDarsRed = Color(0xffE53935);
const kDarsLive = Color(0xffEF4444);

// ── DarsCard — main lesson card ───────────────────────────────────────────────

class DarsCard extends StatelessWidget {
  final Dars dars;
  final VoidCallback onTap;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;
  final double? progress; // 0.0 – 1.0

  const DarsCard({
    super.key,
    required this.dars,
    required this.onTap,
    this.isBookmarked = false,
    this.onBookmarkTap,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: cs.primary.withValues(alpha: isDark ? 0.10 : 0.07),
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: isDark ? 0.06 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(dars: dars, cs: cs, isDark: isDark),
                Expanded(
                  child: _CardInfo(dars: dars, cs: cs, isDark: isDark),
                ),
                _BookmarkButton(
                  isBookmarked: isBookmarked,
                  onTap: onBookmarkTap,
                  cs: cs,
                ),
              ],
            ),
            // Progress bar (if started)
            if (progress != null && progress! > 0)
              _ProgressStrip(progress: progress!, cs: cs),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final Dars dars;
  final ColorScheme cs;
  final bool isDark;
  const _Thumbnail({
    required this.dars,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 80.h,
      margin: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: dars.thumbnailUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.network(
                dars.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _TypeIcon(type: dars.type, cs: cs),
              ),
            )
          : _TypeIcon(type: dars.type, cs: cs),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final DarsType type;
  final ColorScheme cs;
  const _TypeIcon({required this.type, required this.cs});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (type) {
      case DarsType.video:
        icon = Icons.play_circle_rounded;
        color = cs.primary;
        break;
      case DarsType.text:
        icon = Icons.article_rounded;
        color = kDarsGold;
        break;
      default:
        icon = Icons.headphones_rounded;
        color = cs.primary;
    }
    return Center(
      child: Icon(icon, color: color, size: 32.r),
    );
  }
}

class _CardInfo extends StatelessWidget {
  final Dars dars;
  final ColorScheme cs;
  final bool isDark;
  const _CardInfo({required this.dars, required this.cs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10.h, 4.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DarsCategoryChip(category: dars.category, small: true),
          SizedBox(height: 4.h),
          Text(
            dars.title,
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
          SizedBox(height: 4.h),
          Text(
            dars.scholar.name,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 10.sp,
              color: cs.primary.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              DarsTypeBadge(type: dars.type),
              SizedBox(width: 6.w),
              Icon(
                Icons.access_time_rounded,
                size: 10.r,
                color: Theme.of(context).hintColor.withValues(alpha: 0.45),
              ),
              SizedBox(width: 2.w),
              Text(
                dars.durationFormatted,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 9.5.sp,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback? onTap;
  final ColorScheme cs;
  const _BookmarkButton({
    required this.isBookmarked,
    this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, right: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_outline_rounded,
          color: isBookmarked ? kDarsGold : cs.primary.withValues(alpha: 0.35),
          size: 20.r,
        ),
      ),
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  final double progress;
  final ColorScheme cs;
  const _ProgressStrip({required this.progress, required this.cs});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 3.h,
        backgroundColor: cs.primary.withValues(alpha: 0.10),
        valueColor: const AlwaysStoppedAnimation<Color>(kDarsGold),
      ),
    );
  }
}

// ── DarsCategoryChip ──────────────────────────────────────────────────────────

class DarsCategoryChip extends StatelessWidget {
  final DarsCategory category;
  final bool selected;
  final VoidCallback? onTap;
  final bool small;

  const DarsCategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 6.w : 10.w,
          vertical: small ? 2.h : 5.h,
        ),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary
              : cs.primary.withValues(alpha: isDark ? 0.14 : 0.08),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? cs.primary : cs.primary.withValues(alpha: 0.20),
            width: 1,
          ),
        ),
        child: Text(
          '${category.emoji} ${category.displayName}',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: small ? 9.sp : 11.sp,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : cs.primary.withValues(alpha: isDark ? 0.90 : 0.80),
          ),
        ),
      ),
    );
  }
}

// ── DarsTypeBadge ─────────────────────────────────────────────────────────────

class DarsTypeBadge extends StatelessWidget {
  final DarsType type;
  const DarsTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String label;
    Color color;
    IconData icon;
    switch (type) {
      case DarsType.video:
        label = 'Video';
        color = Colors.blue;
        icon = Icons.videocam_rounded;
        break;
      case DarsType.text:
        label = 'Text';
        color = kDarsGold;
        icon = Icons.article_rounded;
        break;
      default:
        label = 'Audio';
        color = cs.primary;
        icon = Icons.headphones_rounded;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9.r, color: color),
          SizedBox(width: 2.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── ScholarAvatar ─────────────────────────────────────────────────────────────

class ScholarAvatar extends StatelessWidget {
  final Scholar scholar;
  final double size;
  final bool showName;
  final VoidCallback? onTap;

  const ScholarAvatar({
    super.key,
    required this.scholar,
    this.size = 48,
    this.showName = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget avatar = Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.primary.withValues(alpha: 0.12),
        border: Border.all(
          color: kDarsGold.withValues(alpha: 0.40),
          width: 1.5,
        ),
      ),
      child: scholar.photoUrl != null
          ? ClipOval(
              child: Image.network(
                scholar.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initials(context),
              ),
            )
          : _initials(context),
    );

    if (!showName) return GestureDetector(onTap: onTap, child: avatar);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          avatar,
          SizedBox(height: 4.h),
          SizedBox(
            width: size.r + 12.w,
            child: Text(
              scholar.name.split(' ').take(2).join('\n'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 9.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.75),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initials(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final parts = scholar.name.split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'
        : parts[0][0];
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          fontFamily: 'kufi',
          fontSize: (size * 0.35).sp,
          fontWeight: FontWeight.w700,
          color: cs.primary,
        ),
      ),
    );
  }
}

// ── DarsProgressBar ───────────────────────────────────────────────────────────

class DarsProgressBar extends StatelessWidget {
  final double value; // 0.0 – 1.0
  final Color? color;
  final double height;
  final bool showLabel;

  const DarsProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 6,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final barColor = color ?? kDarsGold;
    final clamped = value.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: EdgeInsets.only(bottom: 3.h),
            child: Text(
              '${(clamped * 100).toInt()}% complete',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 9.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.55),
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height.r),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: height.h,
            backgroundColor: cs.primary.withValues(alpha: 0.10),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

// ── LiveBadge ─────────────────────────────────────────────────────────────────

class LiveBadge extends StatefulWidget {
  const LiveBadge({super.key});

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: kDarsLive,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6.r,
              height: 6.r,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              'LIVE',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── DarsEmptyState ────────────────────────────────────────────────────────────

class DarsEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const DarsEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.auto_stories_rounded,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.14 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 34.r,
                color: cs.primary.withValues(alpha: 0.55),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).hintColor,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 12.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.50),
                height: 1.5,
              ),
            ),
            if (onAction != null) ...[
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 11.h,
                  ),
                ),
                child: Text(
                  actionLabel ?? 'Explore',
                  style: TextStyle(fontFamily: 'kufi', fontSize: 13.sp),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── DarsErrorState ────────────────────────────────────────────────────────────

class DarsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const DarsErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 42.r,
              color: kDarsRed.withValues(alpha: 0.65),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.65),
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 14.h),
              TextButton.icon(
                onPressed: onRetry,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 16.r,
                  color: cs.primary,
                ),
                label: Text(
                  'Retry',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── DarsLoadingShimmer ────────────────────────────────────────────────────────

class DarsLoadingShimmer extends StatelessWidget {
  final int count;
  const DarsLoadingShimmer({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = cs.primary.withValues(alpha: 0.06);
    final highlight = cs.primary.withValues(alpha: 0.13);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        itemBuilder: (_, __) => Container(
          height: 90.h,
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}

// ── DarsSectionHeader ─────────────────────────────────────────────────────────

class DarsSectionHeader extends StatelessWidget {
  final String title;
  final String? arabicTitle;
  final IconData icon;
  final Color? color;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const DarsSectionHeader({
    super.key,
    required this.title,
    this.arabicTitle,
    required this.icon,
    this.color,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? cs.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 3.w,
            height: 26.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kDarsGold, c],
              ),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 30.r,
            height: 30.r,
            decoration: BoxDecoration(
              color: c.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: c.withValues(alpha: 0.20)),
            ),
            child: Icon(icon, color: c, size: 15.r),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
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
                if (arabicTitle != null)
                  Text(
                    arabicTitle!,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'naskh',
                      fontSize: 10.sp,
                      color: kDarsGold.withValues(alpha: 0.65),
                    ),
                  ),
              ],
            ),
          ),
          if (actionLabel != null && onActionTap != null)
            GestureDetector(
              onTap: onActionTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: isDark ? 0.16 : 0.09),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  actionLabel!,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                    color: c,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── MiniAudioPlayer — persistent bottom mini-player ──────────────────────────

class MiniAudioPlayer extends StatelessWidget {
  final Dars dars;
  final bool isPlaying;
  final double progress; // 0.0–1.0
  final VoidCallback onPlayPause;
  final VoidCallback onExpand;
  final VoidCallback onClose;

  const MiniAudioPlayer({
    super.key,
    required this.dars,
    required this.isPlaying,
    required this.progress,
    required this.onPlayPause,
    required this.onExpand,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onExpand,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.headphones_rounded,
                      color: Colors.white,
                      size: 18.r,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dars.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          dars.scholar.name,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 9.sp,
                            color: Colors.white.withValues(alpha: 0.70),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onPlayPause,
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_filled_rounded,
                      color: Colors.white,
                      size: 30.r,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 34.r,
                      minHeight: 34.r,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: onClose,
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.65),
                      size: 18.r,
                    ),
                  ),
                ],
              ),
            ),
            // Progress strip
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16.r),
              ),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3.h,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(kDarsGold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── IslamicBgPainter — reusable for Dars screens ──────────────────────────────

class DarsIslamicBgPainter extends CustomPainter {
  final Color primaryColor;
  final Color surfaceColor;
  final bool isDark;

  const DarsIslamicBgPainter({
    required this.primaryColor,
    required this.surfaceColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final archPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.07 : 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width + 40, -40), 120, archPaint);
    canvas.drawCircle(Offset(-40, size.height + 30), 90, archPaint);

    final starPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.050 : 0.038)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65;

    const tileSize = 54.0;
    final cols = (size.width / tileSize).ceil() + 2;
    final rows = (size.height / tileSize).ceil() + 2;

    for (int row = -1; row < rows; row++) {
      for (int col = -1; col < cols; col++) {
        final cx = col * tileSize + (row.isOdd ? tileSize / 2 : 0);
        final cy = row * tileSize * 0.88;
        _drawStar8(canvas, starPaint, Offset(cx, cy), tileSize * 0.34);
      }
    }
  }

  void _drawStar8(Canvas canvas, Paint paint, Offset center, double r) {
    const pts = 8;
    final inner = r * 0.42;
    final path = Path();
    for (int i = 0; i < pts * 2; i++) {
      final angle = (i * math.pi / pts) - math.pi / 2;
      final radius = i.isEven ? r : inner;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DarsIslamicBgPainter old) =>
      old.primaryColor != primaryColor || old.isDark != isDark;
}

// ── DarsAppBarButton — consistent icon button ─────────────────────────────────

class DarsAppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final int? badgeCount;

  const DarsAppBarButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: cs.secondary,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: cs.surface.withValues(alpha: 0.45),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: cs.primary, size: 19.r),
      ),
    );
    if (badgeCount != null && badgeCount! > 0) {
      btn = Stack(
        clipBehavior: Clip.none,
        children: [
          btn,
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              width: 16.r,
              height: 16.r,
              decoration: const BoxDecoration(
                color: kDarsRed,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (tooltip != null) return Tooltip(message: tooltip!, child: btn);
    return btn;
  }
}
