import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'controller/tasbih_controller.dart';
import 'widgets/counter_area.dart';
import 'widgets/dhikr_selector_card.dart';
import 'widgets/geometric_pattern_painter.dart';
import 'widgets/quick_actions_bar.dart';
import 'widgets/stats_section.dart';
import 'widgets/tap_button.dart';

class Tasbih extends StatefulWidget {
  const Tasbih({super.key});

  @override
  State<Tasbih> createState() => _TasbihState();
}

class _TasbihState extends State<Tasbih> {
  late final TasbihController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(TasbihController(), permanent: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const gold = Color(0xffCDAD80);

    return Scaffold(
      backgroundColor: theme.colorScheme.secondary,
      body: Stack(
        children: [
          // ── Islamic geometric background pattern ─────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricPatternPainter(
                color: isDark ? gold : cs.primary,
                opacity: isDark ? 0.045 : 0.055,
              ),
            ),
          ),

          // ── Radial glow from top ─────────────────────────────────────────
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Container(
              height: 320.h,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.85,
                  colors: [
                    cs.primary.withValues(alpha: isDark ? 0.12 : 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main scrollable content ──────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // App Bar
                _TasbihAppBar(ctrl: _ctrl),

                // Scrollable body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),

                        // Dhikr name & translation
                        const _DhikrHeader(),

                        SizedBox(height: 14.h),

                        // Dhikr selector card
                        const DhikrSelectorCard(),

                        SizedBox(height: 22.h),

                        // Counter ring
                        const CounterArea(),

                        SizedBox(height: 22.h),

                        // Main tap button
                        const TapCountButton(),

                        SizedBox(height: 20.h),

                        // Progress text
                        const _ProgressLabel(),

                        SizedBox(height: 18.h),

                        // Quick actions
                        const QuickActionsBar(),

                        SizedBox(height: 24.h),

                        // Divider
                        Divider(
                          color: cs.primary.withValues(alpha: 0.12),
                          thickness: 1,
                        ),

                        SizedBox(height: 14.h),

                        // Stats & history
                        const StatsSection(),

                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _TasbihAppBar extends StatelessWidget {
  final TasbihController ctrl;
  const _TasbihAppBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const gold = Color(0xffCDAD80);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      child: Row(
        children: [
          // Islamic star icon + title
          Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: gold,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التسبيح',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'naskh',
                      fontSize: 15.sp,
                      color: gold,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Tasbih Counter',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.hintColor,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Vibration quick toggle
          Obx(
            () => GestureDetector(
              onTap: ctrl.toggleVibration,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Icon(
                  ctrl.vibrationEnabled.value
                      ? Icons.vibration_rounded
                      : Icons.smartphone_rounded,
                  color: ctrl.vibrationEnabled.value
                      ? cs.primary
                      : theme.hintColor.withValues(alpha: 0.35),
                  size: 18.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dhikr header ─────────────────────────────────────────────────────────────

class _DhikrHeader extends StatelessWidget {
  const _DhikrHeader();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TasbihController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const gold = Color(0xffCDAD80);

    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: Container(
          key: ValueKey(ctrl.selectedDhikrIndex.value),
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primary.withValues(alpha: 0.08),
                cs.primary.withValues(alpha: 0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: gold.withValues(alpha: 0.18), width: 1),
          ),
          child: Column(
            children: [
              Text(
                ctrl.currentDhikr.arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'naskh',
                  fontSize: 22.sp,
                  color: gold,
                  height: 1.8,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                ctrl.currentDhikr.transliteration,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 11.sp,
                  color: theme.hintColor.withValues(alpha: 0.55),
                  letterSpacing: 0.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '"${ctrl.currentDhikr.translation}"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 11.sp,
                  color: theme.hintColor.withValues(alpha: 0.4),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Progress label ───────────────────────────────────────────────────────────

class _ProgressLabel extends StatelessWidget {
  const _ProgressLabel();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TasbihController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const gold = Color(0xffCDAD80);

    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress percent badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              '${(ctrl.progress * 100).toInt()}%  progress',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            '•',
            style: TextStyle(
              color: theme.hintColor.withValues(alpha: 0.3),
              fontSize: 18.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            ctrl.isCompleted.value
                ? 'All done! 🎉'
                : '${ctrl.remainingCount} remaining',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 12.sp,
              color: ctrl.isCompleted.value
                  ? gold
                  : theme.hintColor.withValues(alpha: 0.5),
              fontWeight: ctrl.isCompleted.value
                  ? FontWeight.w700
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
