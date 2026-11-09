import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/allah_names_controller.dart';
import '../model/allah_name_model.dart';
import '../widgets/name_colors.dart';

class NameDetailScreen extends StatelessWidget {
  final AllahName name;
  const NameDetailScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AllahNamesController>();
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Collapsible hero ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240.h,
            pinned: true,
            backgroundColor: cs.primary,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              Obx(
                () => IconButton(
                  icon: Icon(
                    ctrl.isFavorite(name.number)
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: ctrl.isFavorite(name.number)
                        ? Colors.red
                        : Colors.white,
                  ),
                  onPressed: () => ctrl.toggleFavorite(name.number),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () => _shareContent(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Geometric background
                  CustomPaint(painter: _DetailBgPainter(color: kNameGold)),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primary.withValues(alpha: 0.97),
                          cs.primary.withValues(alpha: 0.78),
                        ],
                      ),
                    ),
                  ),
                  // Hero content
                  Positioned.fill(
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Number pill
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: kNameGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: kNameGold.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '# ${name.number} of 99',
                                style: TextStyle(
                                  fontFamily: 'kufi',
                                  fontSize: 11.sp,
                                  color: kNameGold,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),

                            // Arabic name
                            Text(
                              name.arabic,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'naskh',
                                fontSize: 40.sp,
                                color: kNameGold,
                                height: 1.6,
                                shadows: [
                                  Shadow(
                                    color: kNameGold.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 6.h),

                            // Transliteration
                            Text(
                              name.transliteration,
                              style: TextStyle(
                                fontFamily: 'kufi',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4.h),

                            // Meaning
                            Text(
                              '"${name.meaning}"',
                              style: TextStyle(
                                fontFamily: 'kufi',
                                fontSize: 13.sp,
                                color: Colors.white.withValues(alpha: 0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Detail body ────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.all(16.r),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Description card
                _DetailCard(
                  icon: Icons.info_outline_rounded,
                  title: 'Description',
                  child: Text(
                    name.description,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 13.sp,
                      color: theme.hintColor.withValues(alpha: 0.8),
                      height: 1.7,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Quranic reference
                _DetailCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Quranic Reference',
                  iconColor: kNameGold,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: kNameGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: kNameGold.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          color: kNameGold,
                          size: 14.r,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          name.quranRef,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: kNameGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Reflection card
                _DetailCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Reflection & Benefit',
                  iconColor: kNameEmerald,
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: kNameEmerald.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: kNameEmerald.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✦ ',
                          style: TextStyle(color: kNameGold, fontSize: 12.sp),
                        ),
                        Expanded(
                          child: Text(
                            name.reflection,
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 13.sp,
                              color: theme.hintColor.withValues(alpha: 0.8),
                              height: 1.7,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Navigation between names
                _NameNavigation(currentName: name, ctrl: ctrl, cs: cs),
                SizedBox(height: 16.h),

                // Mark as learned
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ctrl.learnedNames.contains(name.number)
                            ? kNameEmerald
                            : cs.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      icon: Icon(
                        ctrl.learnedNames.contains(name.number)
                            ? Icons.check_circle_rounded
                            : Icons.school_rounded,
                        color: Colors.white,
                        size: 20.r,
                      ),
                      label: Text(
                        ctrl.learnedNames.contains(name.number)
                            ? 'Learned ✓'
                            : 'Mark as Learned',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        ctrl.markAsLearned(name.number);
                        HapticFeedback.mediumImpact();
                      },
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _shareContent() {
    Share.share(
      '✨ ${name.arabic}\n'
      '${name.transliteration} — ${name.meaning}\n\n'
      '${name.description}\n\n'
      '📖 ${name.quranRef}\n\n'
      '#AsmaUlHusna #99NamesOfAllah #Islam',
    );
  }
}

// ─── Prev / Next navigation ───────────────────────────────────────────────────

class _NameNavigation extends StatelessWidget {
  final AllahName currentName;
  final AllahNamesController ctrl;
  final ColorScheme cs;

  const _NameNavigation({
    required this.currentName,
    required this.ctrl,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPrev = currentName.number > 1;
    final hasNext = currentName.number < 99;

    return Row(
      children: [
        if (hasPrev)
          Expanded(
            child: _NavTile(
              label: '← Previous',
              nameLine: ctrl.allNames[currentName.number - 2].arabic,
              cs: cs,
              theme: theme,
              onTap: () => Get.off(
                () => NameDetailScreen(
                  name: ctrl.allNames[currentName.number - 2],
                ),
                transition: Transition.leftToRight,
              ),
            ),
          ),
        if (hasPrev && hasNext) SizedBox(width: 8.w),
        if (hasNext)
          Expanded(
            child: _NavTile(
              label: 'Next →',
              nameLine: ctrl.allNames[currentName.number].arabic,
              cs: cs,
              theme: theme,
              isRight: true,
              onTap: () => Get.off(
                () => NameDetailScreen(name: ctrl.allNames[currentName.number]),
                transition: Transition.rightToLeft,
              ),
            ),
          ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final String nameLine;
  final ColorScheme cs;
  final ThemeData theme;
  final VoidCallback onTap;
  final bool isRight;

  const _NavTile({
    required this.label,
    required this.nameLine,
    required this.cs,
    required this.theme,
    required this.onTap,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: isRight
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 10.sp,
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              nameLine,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'naskh',
                fontSize: 14.sp,
                color: kNameGold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable detail section card ─────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Color? iconColor;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.child,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = iconColor ?? cs.primary;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.primary.withValues(alpha: 0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 15.r),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

// ─── Geometric background painter ─────────────────────────────────────────────

class _DetailBgPainter extends CustomPainter {
  final Color color;
  const _DetailBgPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    const tile = 52.0;
    final cols = (size.width / tile).ceil() + 1;
    final rows = (size.height / tile).ceil() + 1;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * tile + (r.isOdd ? tile / 2 : 0);
        final cy = r * tile.toDouble();
        _drawStar(canvas, Offset(cx, cy), tile * 0.34, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path();
    const pts = 8;
    final inner = r * 0.42;
    for (int i = 0; i < pts * 2; i++) {
      final angle = (i * math.pi / pts) - math.pi / 2;
      final radius = i.isEven ? r : inner;
      final x = c.dx + radius * math.cos(angle);
      final y = c.dy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_DetailBgPainter old) => false;
}
