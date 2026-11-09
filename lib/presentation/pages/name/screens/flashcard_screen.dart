import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/allah_names_controller.dart';
import '../model/allah_name_model.dart';
import '../widgets/name_colors.dart';

class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AllahNamesController>();
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cs.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Flashcards',
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
                  '${ctrl.flashcardIndex.value + 1} / 99',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final name = ctrl.currentFlashcard;
        final flipped = ctrl.showFlashcardAnswer.value;
        final learned = ctrl.learnedNames.contains(name.number);

        return Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (ctrl.flashcardIndex.value + 1) / 99,
              backgroundColor: cs.primary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(kNameEmerald),
              minHeight: 3,
            ),

            // Flip card
            Expanded(
              child: GestureDetector(
                onTap: ctrl.flipFlashcard,
                onHorizontalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) < 0) {
                    ctrl.nextFlashcard();
                  } else {
                    ctrl.prevFlashcard();
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(scale: anim, child: child),
                    ),
                    child: Container(
                      key: ValueKey('${name.number}_$flipped'),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primary.withValues(alpha: 0.95),
                            cs.primary.withValues(alpha: 0.75),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: kNameGold.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: flipped
                          ? _CardBack(name: name)
                          : _CardFront(name: name),
                    ),
                  ),
                ),
              ),
            ),

            // Controls row
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
              child: Row(
                children: [
                  _NavBtn(
                    icon: Icons.arrow_back_ios_rounded,
                    onTap: ctrl.prevFlashcard,
                    cs: cs,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: learned ? kNameEmerald : cs.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      icon: Icon(
                        learned
                            ? Icons.check_circle_rounded
                            : Icons.school_rounded,
                        color: Colors.white,
                        size: 18.r,
                      ),
                      label: Text(
                        learned ? 'Learned' : 'Mark Learned',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () => ctrl.markAsLearned(name.number),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  _NavBtn(
                    icon: Icons.arrow_forward_ios_rounded,
                    onTap: ctrl.nextFlashcard,
                    cs: cs,
                  ),
                ],
              ),
            ),

            // Hint
            Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Text(
                'Tap card to flip  •  Swipe to navigate',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 10.sp,
                  color: theme.hintColor.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Card front (Arabic only) ─────────────────────────────────────────────────

class _CardFront extends StatelessWidget {
  final AllahName name;
  const _CardFront({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '#${name.number}',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 12.sp,
              color: kNameGold.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            name.arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'naskh',
              fontSize: 52.sp,
              color: kNameGold,
              height: 1.6,
              shadows: [
                Shadow(color: kNameGold.withValues(alpha: 0.3), blurRadius: 20),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_rounded,
                color: Colors.white.withValues(alpha: 0.35),
                size: 14.r,
              ),
              SizedBox(width: 4.w),
              Text(
                'Tap to reveal meaning',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 11.sp,
                  color: Colors.white.withValues(alpha: 0.4),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Card back (meaning + description) ───────────────────────────────────────

class _CardBack extends StatelessWidget {
  final AllahName name;
  const _CardBack({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Transliteration
          Text(
            name.transliteration,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),

          // Meaning badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: kNameGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: kNameGold.withValues(alpha: 0.45),
                width: 1,
              ),
            ),
            child: Text(
              name.meaning,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: kNameGold,
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Short description
          Text(
            name.description,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 11.sp,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Navigation button ────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _NavBtn({required this.icon, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Icon(icon, color: cs.primary, size: 18.r),
      ),
    );
  }
}
