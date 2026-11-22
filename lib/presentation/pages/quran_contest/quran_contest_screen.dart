// ─────────────────────────────────────────────────────────────────────────────
// quran_contest_screen.dart  — Premium Page
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class QuranContestScreen extends StatelessWidget {
  const QuranContestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.secondary,
      appBar: AppBar(
        backgroundColor: cs.secondary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Qur'an Contest",
          style: TextStyle(
            fontFamily: 'kufi',
            fontWeight: FontWeight.w800,
            fontSize: 17.sp,
            color: cs.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, size: 72.r, color: cs.primary),
            SizedBox(height: 20.h),
            Text(
              "Qur'an Contest",
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                'مسابقة القرآن الكريم — coming soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'naskh',
                  fontSize: 14.sp,
                  color: (isDark ? Colors.white : const Color(0xFF1A1A1A))
                      .withValues(alpha: 0.55),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
