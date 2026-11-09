// ─────────────────────────────────────────────────────────────────────────────
// ScriptureCard — Featured Quran verse or Hadith card
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const Color _kGold = Color(0xffCDAD80);
const Color _kGoldDeep = Color(0xffCD9974);

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
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: isDark ? 0.22 : 0.10),
            cs.primary.withValues(alpha: isDark ? 0.12 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _kGold.withValues(alpha: 0.28), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _kGold.withValues(alpha: isDark ? 0.12 : 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
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
              Column(
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
                      color: _kGold.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // ── Arabic ────────────────────────────────────────────────────────
          Text(
            data['arabic'] ?? '',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'naskh',
              fontSize: 15.sp,
              color: theme.hintColor,
              height: 1.85,
            ),
          ),
          SizedBox(height: 10.h),
          // ── Translation ───────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: isDark ? 0.10 : 0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              data['translation'] ?? '',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 11.5.sp,
                color: theme.hintColor.withValues(alpha: 0.65),
                height: 1.60,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
