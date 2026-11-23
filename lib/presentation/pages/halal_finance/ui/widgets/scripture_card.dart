// ─────────────────────────────────────────────────────────────────────────────
// ScriptureCard — Featured Quran verse or Hadith card in the carousel
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const Color _kGold = Color(0xffCDAD80);
const Color _kGoldDeep = Color(0xffB8864E);
const Color _kEmerald = Color(0xff1A5C45);

class ScriptureCard extends StatelessWidget {
  final Map<String, String> data;

  const ScriptureCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isQuran = data['type'] == 'quran';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xff0F2419),
                  const Color(0xff162D1F),
                ]
              : [
                  _kEmerald.withValues(alpha: 0.08),
                  _kEmerald.withValues(alpha: 0.03),
                ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: _kGold.withValues(alpha: isDark ? 0.30 : 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _kGold.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(18.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_kGoldDeep, _kGold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    isQuran
                        ? Icons.menu_book_rounded
                        : Icons.format_quote_rounded,
                    color: Colors.white,
                    size: 16.r,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isQuran ? 'Quran' : 'Hadith',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: _kGold,
                        ),
                      ),
                      Text(
                        data['reference'] ?? '',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 9.5.sp,
                          color: _kGold.withValues(alpha: 0.60),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            // ── Gold divider ─────────────────────────────────────────────────
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _kGold.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // ── Arabic text ──────────────────────────────────────────────────
            Text(
              data['arabic'] ?? '',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'naskh',
                fontSize: 14.sp,
                color: theme.hintColor,
                height: 2.0,
              ),
            ),
            SizedBox(height: 10.h),
            // ── Translation ──────────────────────────────────────────────────
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : _kEmerald.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : _kEmerald.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  data['translation'] ?? '',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 11.sp,
                    color: theme.hintColor.withValues(alpha: 0.65),
                    height: 1.60,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
