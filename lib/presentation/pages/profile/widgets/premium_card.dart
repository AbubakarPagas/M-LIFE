import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/profile_controller.dart';
import 'islamic_bg_painter.dart';
import 'profile_header.dart' show kGold, kGoldLight, kGoldDeep;

class PremiumCard extends StatelessWidget {
  const PremiumCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    return Obx(
      () => ctrl.isPremium.value ? const _ActiveCard() : const _UpgradeCard(),
    );
  }
}

// ─── Upgrade card ─────────────────────────────────────────────────────────────

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: ctrl.togglePremium,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary,
              Color.lerp(cs.primary, const Color(0xff1A2744), 0.55)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: kGold.withValues(alpha: 0.35), width: 1),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Islamic pattern overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22.r),
                child: const CustomPaint(
                  painter: IslamicBgPainter(
                    starColor: kGold,
                    ringColor: kGold,
                    starOpacity: 0.08,
                    ringOpacity: 0.03,
                    tileSize: 50,
                  ),
                ),
              ),
            ),

            // Corner crescent ornament
            Positioned(
              top: -8,
              right: -8,
              child: CustomPaint(
                size: Size(80.r, 80.r),
                painter: _CrescentPainter(color: kGold),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _GoldIconBadge(
                      icon: Icons.workspace_premium_rounded,
                      size: 22.r,
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upgrade to Premium',
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'ترقية إلى المميز',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: 'naskh',
                            fontSize: 12.sp,
                            color: kGold.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  'Unlock advanced Islamic content, offline access, '
                  'ad-free experience and exclusive features.',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.55,
                  ),
                ),
                SizedBox(height: 14.h),

                // Feature chips
                Wrap(
                  spacing: 7.w,
                  runSpacing: 6.h,
                  children: const [
                    _Chip('🚫  No Ads'),
                    _Chip('📥  Offline'),
                    _Chip('✨  Exclusive'),
                    _Chip('🎯  Advanced'),
                  ],
                ),
                SizedBox(height: 16.h),

                // CTA button
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 11.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kGoldDeep, kGold, kGoldLight],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: kGold.withValues(alpha: 0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 15.r,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'Get Premium',
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

// ─── Active premium card ──────────────────────────────────────────────────────

class _ActiveCard extends StatelessWidget {
  const _ActiveCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kGoldDeep, kGold, kGoldLight, kGold],
          stops: [0.0, 0.35, 0.7, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: kGold.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle star overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.r),
              child: const CustomPaint(
                painter: IslamicBgPainter(
                  starColor: Colors.white,
                  ringColor: Colors.white,
                  starOpacity: 0.07,
                  ringOpacity: 0.03,
                  tileSize: 44,
                ),
              ),
            ),
          ),
          Row(
            children: [
              _GoldIconBadge(
                icon: Icons.workspace_premium_rounded,
                size: 28.r,
                bgColor: Colors.white.withValues(alpha: 0.2),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Member',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'عضو مميز',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'naskh',
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 13.r,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'All features unlocked',
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 10.5.sp,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _GoldIconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? bgColor;

  const _GoldIconBadge({required this.icon, required this.size, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.8,
      height: size * 1.8,
      decoration: BoxDecoration(
        color: bgColor ?? kGold.withValues(alpha: 0.22),
        shape: BoxShape.circle,
        border: Border.all(color: kGold.withValues(alpha: 0.5), width: 1),
      ),
      child: Icon(icon, color: kGold, size: size),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'kufi',
          fontSize: 9.5.sp,
          color: Colors.white.withValues(alpha: 0.88),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Crescent ornament ────────────────────────────────────────────────────────

class _CrescentPainter extends CustomPainter {
  final Color color;
  const _CrescentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.13)
      ..style = PaintingStyle.fill;

    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final r1 = size.width * 0.42;
    final r2 = size.width * 0.30;
    final offset = size.width * 0.14;

    final path = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r1));
    final hole = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(cx + offset, cy - offset), radius: r2),
      );
    canvas.drawPath(Path.combine(PathOperation.difference, path, hole), paint);
  }

  @override
  bool shouldRepaint(_CrescentPainter old) => false;
}
