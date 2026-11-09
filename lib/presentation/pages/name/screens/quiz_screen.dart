import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/allah_names_controller.dart';
import '../widgets/name_colors.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AllahNamesController>();
    ctrl.startQuiz(count: 10);

    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cs.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Quiz Mode',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          Obx(
            () => Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: Text(
                  '${ctrl.currentQuizQuestion.value + 1} / ${ctrl.quizTotal.value}',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // Show result screen when quiz is finished
        if (ctrl.quizFinished) {
          return _QuizResult(ctrl: ctrl, cs: cs);
        }

        final q = ctrl.currentQuestion;
        final revealed = ctrl.quizAnswerRevealed.value;
        final selected = ctrl.quizAnswerSelected.value;

        return Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value:
                  (ctrl.currentQuizQuestion.value + 1) / ctrl.quizTotal.value,
              backgroundColor: cs.primary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(kNameEmerald),
              minHeight: 3,
            ),

            // Score chip + instruction
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'What does this name mean?',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12.sp,
                      color: theme.hintColor.withValues(alpha: 0.6),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: kNameEmerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '${ctrl.quizScore.value} pts',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: kNameEmerald,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Arabic name question card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.primary.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: kNameGold.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    q.name.arabic,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'naskh',
                      fontSize: 36.sp,
                      color: kNameGold,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    q.name.transliteration,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Answer options
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: q.options.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (_, i) {
                  final opt = q.options[i];
                  final isCorrect = opt.number == q.name.number;

                  Color bgColor;
                  Color borderColor;
                  Widget? trailIcon;

                  if (revealed) {
                    if (isCorrect) {
                      bgColor = kNameEmerald.withValues(alpha: 0.15);
                      borderColor = kNameEmerald;
                      trailIcon = Icon(
                        Icons.check_circle_rounded,
                        color: kNameEmerald,
                        size: 18.r,
                      );
                    } else if (selected == i) {
                      bgColor = Colors.red.withValues(alpha: 0.1);
                      borderColor = Colors.red;
                      trailIcon = Icon(
                        Icons.cancel_rounded,
                        color: Colors.red,
                        size: 18.r,
                      );
                    } else {
                      bgColor = cs.primaryContainer;
                      borderColor = cs.primary.withValues(alpha: 0.1);
                    }
                  } else {
                    bgColor = cs.primaryContainer;
                    borderColor = cs.primary.withValues(alpha: 0.12);
                  }

                  return GestureDetector(
                    onTap: () => ctrl.selectQuizAnswer(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          // Option letter badge
                          Container(
                            width: 28.r,
                            height: 28.r,
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + i),
                                style: TextStyle(
                                  fontFamily: 'kufi',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              opt.meaning,
                              style: TextStyle(
                                fontFamily: 'kufi',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                          if (trailIcon != null) trailIcon,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Next question button
            if (revealed)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    onPressed: ctrl.nextQuizQuestion,
                    child: Text(
                      ctrl.currentQuizQuestion.value < ctrl.quizTotal.value - 1
                          ? 'Next Question →'
                          : 'See Results',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

// ─── Quiz result screen ───────────────────────────────────────────────────────

class _QuizResult extends StatelessWidget {
  final AllahNamesController ctrl;
  final ColorScheme cs;

  const _QuizResult({required this.ctrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    final pct = (ctrl.quizScore.value / ctrl.quizTotal.value * 100).toInt();
    final excellent = pct >= 80;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              excellent ? '🌟 Excellent!' : '📚 Keep Practicing',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 26.sp,
                fontWeight: FontWeight.w900,
                color: theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),

            // Score circle
            Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: excellent
                      ? [kNameGold, kNameGoldLight]
                      : [cs.primary, cs.primary.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (excellent ? kNameGold : cs.primary).withValues(
                      alpha: 0.35,
                    ),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              '${ctrl.quizScore.value} / ${ctrl.quizTotal.value} correct',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 16.sp,
                color: theme.hintColor.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 8.h),

            // Score history
            if (ctrl.quizScoreHistory.length > 1)
              Text(
                'Best: ${ctrl.quizScoreHistory.reduce((a, b) => a > b ? a : b)} / ${ctrl.quizTotal.value}',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12.sp,
                  color: kNameEmerald,
                  fontWeight: FontWeight.w700,
                ),
              ),

            SizedBox(height: 36.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: cs.primary, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    onPressed: () => ctrl.startQuiz(count: 10),
                    child: Text(
                      'Try Again',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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
