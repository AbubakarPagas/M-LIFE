// ─────────────────────────────────────────────────────────────────────────────
// FinanceTipCard — list item for a single finance tip
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/finance_tip_model.dart';

const Color _kGold = Color(0xffCDAD80);

class FinanceTipCard extends StatelessWidget {
  final FinanceTipModel tip;
  final VoidCallback onBookmark;
  final VoidCallback? onTap;

  const FinanceTipCard({
    super.key,
    required this.tip,
    required this.onBookmark,
    this.onTap,
  });

  // Color per category
  Color _categoryColor(FinanceCategory cat, bool isDark) => switch (cat) {
    FinanceCategory.saving => const Color(0xff2E7D32),
    FinanceCategory.budgeting => const Color(0xff1565C0),
    FinanceCategory.investing => const Color(0xff4A148C),
    FinanceCategory.business => const Color(0xffE65100),
    FinanceCategory.zakat => _kGold,
    FinanceCategory.debt => const Color(0xffC62828),
    FinanceCategory.family => const Color(0xff00695C),
    FinanceCategory.all => const Color(0xff37474F),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final catColor = _categoryColor(tip.category, isDark);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.07 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: onTap ?? () => _showDetail(context),
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: category + reading time ──────────────────────
                Row(
                  children: [
                    _CategoryBadge(category: tip.category, color: catColor),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.schedule_rounded,
                      size: 11.r,
                      color: theme.hintColor.withValues(alpha: 0.35),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '${tip.readingTimeMinutes} min read',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 10.sp,
                        color: theme.hintColor.withValues(alpha: 0.40),
                      ),
                    ),
                    const Spacer(),
                    // Bookmark
                    _IconBtn(
                      icon: tip.isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: tip.isBookmarked
                          ? _kGold
                          : theme.hintColor.withValues(alpha: 0.30),
                      onTap: onBookmark,
                      tooltip: 'Bookmark',
                    ),
                    SizedBox(width: 4.w),
                    // Share
                    _IconBtn(
                      icon: Icons.share_rounded,
                      color: theme.hintColor.withValues(alpha: 0.30),
                      onTap: () => _share(),
                      tooltip: 'Share',
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                // ── Title ─────────────────────────────────────────────────
                Text(
                  tip.title,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.hintColor,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6.h),
                // ── Description ───────────────────────────────────────────
                Text(
                  tip.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    color: theme.hintColor.withValues(alpha: 0.58),
                    height: 1.55,
                  ),
                ),
                // ── Quran/Hadith ref ──────────────────────────────────────
                if (tip.quranRef != null || tip.hadithRef != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 11.r,
                        color: catColor.withValues(alpha: 0.60),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        tip.quranRef ?? tip.hadithRef ?? '',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 10.sp,
                          color: catColor.withValues(alpha: 0.70),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _share() {
    SharePlus.instance.share(
      ShareParams(
        text:
            '${tip.title}\n\n${tip.description}\n\n— Mishab Path Islamic Finance',
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final catColor = _categoryColor(
      tip.category,
      theme.brightness == Brightness.dark,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.70,
        maxChildSize: 0.92,
        minChildSize: 0.40,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  children: [
                    _CategoryBadge(category: tip.category, color: catColor),
                    SizedBox(height: 12.h),
                    Text(
                      tip.title,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: theme.hintColor,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      tip.fullContent,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 13.sp,
                        color: theme.hintColor.withValues(alpha: 0.65),
                        height: 1.7,
                      ),
                    ),
                    if (tip.quranRef != null) ...[
                      SizedBox(height: 14.h),
                      _RefChip(
                        label: tip.quranRef!,
                        icon: Icons.menu_book_rounded,
                        color: catColor,
                      ),
                    ],
                    if (tip.hadithRef != null) ...[
                      SizedBox(height: 8.h),
                      _RefChip(
                        label: tip.hadithRef!,
                        icon: Icons.format_quote_rounded,
                        color: catColor,
                      ),
                    ],
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final FinanceCategory category;
  final Color color;
  const _CategoryBadge({required this.category, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.28 : 0.20),
        ),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontFamily: 'kufi',
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.all(4.r),
          child: Icon(icon, color: color, size: 18.r),
        ),
      ),
    );
  }
}

class _RefChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _RefChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.r, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
