// ─────────────────────────────────────────────────────────────────────────────
// premium_access_modal.dart
// Luxurious Islamic-inspired Premium Unlock Modal
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../profile/controller/profile_controller.dart';

// ── Colour tokens ──────────────────────────────────────────────────────────────
const _kMidnightEmerald = Color(0xff0A2A1E); // midnight emerald green
const _kDeepGreen = Color(0xff0D3B26); // deep Islamic green
const _kEmeraldAccent = Color(0xff1A5C3A); // emerald mid-tone
const _kChampagne = Color(0xffE8C97A); // champagne gold
const _kChampagneDeep = Color(0xffC9A84C); // deeper gold
const _kChampagneLight = Color(0xffF2DFA0); // light gold shimmer
const _kTextWhite = Color(0xffF5F0E8); // warm white

// ─────────────────────────────────────────────────────────────────────────────
// Public entry-point
// ─────────────────────────────────────────────────────────────────────────────

/// Shows the Premium Unlock modal as a bottom-sheet style dialog.
/// [featureName] is the premium feature the user tried to access.
/// Returns true if the user went on to unlock premium.
Future<bool?> showPremiumAccessModal(
  BuildContext context, {
  required String featureName,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Premium Access',
    barrierColor: Colors.black.withValues(alpha: 0.72),
    transitionDuration: const Duration(milliseconds: 420),
    pageBuilder: (ctx, anim, secondaryAnim) => _PremiumAccessModal(
      featureName: featureName,
      animation: anim,
    ),
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Modal widget
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumAccessModal extends StatefulWidget {
  final String featureName;
  final Animation<double> animation;

  const _PremiumAccessModal({
    required this.featureName,
    required this.animation,
  });

  @override
  State<_PremiumAccessModal> createState() => _PremiumAccessModalState();
}

class _PremiumAccessModalState extends State<_PremiumAccessModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _onUnlockTap() {
    Navigator.of(context).pop(true);
    // Connect to the existing premium flow via ProfileController.togglePremium
    // In production this would launch the subscription/payment flow.
    final ctrl = Get.find<ProfileController>();
    ctrl.togglePremium();
  }

  void _onMaybeLaterTap() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width > 600;

    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWide ? 500 : mq.size.width * 0.93,
            maxHeight: mq.size.height * 0.92,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kMidnightEmerald, _kDeepGreen, Color(0xff0B3020)],
                stops: [0.0, 0.55, 1.0],
              ),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: _kChampagne.withValues(alpha: 0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kDeepGreen.withValues(alpha: 0.55),
                  blurRadius: 48,
                  spreadRadius: 4,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: _kChampagne.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.r),
              child: Stack(
                children: [
                  // ── Islamic geometric background ──────────────────
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _IslamicGeometricPainter(
                        primaryColor: _kChampagne,
                        accentColor: _kEmeraldAccent,
                      ),
                    ),
                  ),

                  // ── Shimmer sweep overlay ─────────────────────────
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _shimmerCtrl,
                      builder: (_, __) => CustomPaint(
                        painter: _ShimmerPainter(_shimmerCtrl.value),
                      ),
                    ),
                  ),

                  // ── Top crescent ornament ─────────────────────────
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Opacity(
                      opacity: 0.14,
                      child: CustomPaint(
                        size: Size(130.r, 130.r),
                        painter: _CrescentPainter(color: _kChampagne),
                      ),
                    ),
                  ),

                  // ── Scrollable content ────────────────────────────
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(22.w, 20.h, 22.w, 28.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Close button row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _CloseButton(onTap: _onMaybeLaterTap),
                          ],
                        ),
                        SizedBox(height: 4.h),

                        // Crown icon
                        _AnimatedCrown(shimmer: _shimmerCtrl),
                        SizedBox(height: 14.h),

                        // Badge
                        _ExclusiveBadge(),
                        SizedBox(height: 14.h),

                        // Main heading
                        Text(
                          'Unlock Your Premium\nExperience',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: _kChampagne,
                            height: 1.3,
                            letterSpacing: 0.2,
                            shadows: [
                              Shadow(
                                color: _kChampagne.withValues(alpha: 0.35),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // Description
                        Text(
                          'Unlock exclusive Islamic experiences designed to '
                          'strengthen your faith, expand your knowledge, and '
                          'make your journey more meaningful.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 12.sp,
                            color: _kTextWhite.withValues(alpha: 0.75),
                            height: 1.65,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Feature section
                        _PremiumFeaturesSection(
                          highlightedFeature: widget.featureName,
                        ),
                        SizedBox(height: 22.h),

                        // Primary CTA
                        _UnlockButton(onTap: _onUnlockTap),
                        SizedBox(height: 10.h),

                        // Maybe later
                        _MaybeLaterButton(onTap: _onMaybeLaterTap),
                        SizedBox(height: 14.h),

                        // Footer message
                        Text(
                          'Invest in knowledge. Grow in faith.\nMake every moment meaningful.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 10.5.sp,
                            color: _kChampagne.withValues(alpha: 0.55),
                            fontStyle: FontStyle.italic,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Crown
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedCrown extends StatelessWidget {
  final AnimationController shimmer;
  const _AnimatedCrown({required this.shimmer});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (_, __) => Container(
        width: 76.r,
        height: 76.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              _kEmeraldAccent.withValues(alpha: 0.80),
              _kDeepGreen.withValues(alpha: 0.95),
            ],
            stops: const [0.0, 1.0],
          ),
          border: Border.all(
            color: _kChampagne.withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _kChampagne.withValues(alpha: 0.22 + 0.10 * shimmer.value),
              blurRadius: 22,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          Icons.workspace_premium_rounded,
          color: _kChampagne,
          size: 38.r,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Exclusive badge
// ─────────────────────────────────────────────────────────────────────────────

class _ExclusiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kChampagneDeep, _kChampagne, _kChampagneLight],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: _kChampagne.withValues(alpha: 0.38),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: _kMidnightEmerald, size: 11.r),
          SizedBox(width: 5.w),
          Text(
            'EXCLUSIVE PREMIUM ACCESS',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 9.sp,
              fontWeight: FontWeight.w900,
              color: _kMidnightEmerald,
              letterSpacing: 0.9,
            ),
          ),
          SizedBox(width: 5.w),
          Icon(Icons.star_rounded, color: _kMidnightEmerald, size: 11.r),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium features section
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumFeaturesSection extends StatelessWidget {
  final String highlightedFeature;

  const _PremiumFeaturesSection({required this.highlightedFeature});

  static const _features = [
    _PremiumFeatureData(
      icon: Icons.volunteer_activism_rounded,
      label: 'Sadaqah Jariyah',
      arabic: 'صدقة جارية',
      routeKey: 'Sadaqah Jariyah',
    ),
    _PremiumFeatureData(
      icon: Icons.menu_book_rounded,
      label: "Qur'an Contest",
      arabic: 'مسابقة القرآن',
      routeKey: "Qur'an Contest",
    ),
    _PremiumFeatureData(
      icon: Icons.live_tv_rounded,
      label: 'Islamic Live',
      arabic: 'البث الإسلامي',
      routeKey: 'Islamic Live',
    ),
    _PremiumFeatureData(
      icon: Icons.school_rounded,
      label: 'Daras',
      arabic: 'الدروس الإسلامية',
      routeKey: 'Daras',
    ),
    _PremiumFeatureData(
      icon: Icons.auto_awesome_rounded,
      label: 'Fanar AI',
      arabic: 'فنار الذكاء الاصطناعي',
      routeKey: 'Fanar AI',
    ),
    _PremiumFeatureData(
      icon: Icons.quiz_rounded,
      label: 'Quiz Topic',
      arabic: 'موضوعات الاختبار',
      routeKey: 'Quiz Topic',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: _kChampagne.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 3.w,
                height: 20.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_kChampagne, _kChampagneDeep],
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Your Premium Access Includes:',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w800,
                  color: _kChampagne,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Feature grid 2×3
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 8.w,
              childAspectRatio: 2.6,
            ),
            itemCount: _features.length,
            itemBuilder: (_, i) => _FeatureCard(
              data: _features[i],
              isHighlighted:
                  _features[i].routeKey == highlightedFeature,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeatureData {
  final IconData icon;
  final String label;
  final String arabic;
  final String routeKey;

  const _PremiumFeatureData({
    required this.icon,
    required this.label,
    required this.arabic,
    required this.routeKey,
  });
}

class _FeatureCard extends StatelessWidget {
  final _PremiumFeatureData data;
  final bool isHighlighted;

  const _FeatureCard({required this.data, required this.isHighlighted});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: isHighlighted
            ? const LinearGradient(
                colors: [_kChampagneDeep, _kEmeraldAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  _kEmeraldAccent.withValues(alpha: 0.28),
                  _kMidnightEmerald.withValues(alpha: 0.40),
                ],
              ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isHighlighted
              ? _kChampagne.withValues(alpha: 0.65)
              : _kChampagne.withValues(alpha: 0.14),
          width: 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: _kChampagne.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ]
            : [],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
        child: Row(
          children: [
            Container(
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Colors.white.withValues(alpha: 0.18)
                    : _kChampagne.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                data.icon,
                size: 14.r,
                color: isHighlighted ? Colors.white : _kChampagne,
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.label,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w700,
                      color: isHighlighted ? Colors.white : _kTextWhite,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    data.arabic,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'naskh',
                      fontSize: 8.sp,
                      color: isHighlighted
                          ? Colors.white.withValues(alpha: 0.80)
                          : _kChampagne.withValues(alpha: 0.58),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA Buttons
// ─────────────────────────────────────────────────────────────────────────────

class _UnlockButton extends StatelessWidget {
  final VoidCallback onTap;
  const _UnlockButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kChampagneDeep, _kChampagne, _kChampagneLight],
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: _kChampagne.withValues(alpha: 0.50),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              color: _kMidnightEmerald,
              size: 18.r,
            ),
            SizedBox(width: 8.w),
            Text(
              'Unlock Premium Now',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
                color: _kMidnightEmerald,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaybeLaterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MaybeLaterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 44.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _kChampagne.withValues(alpha: 0.28),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            'Maybe Later',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: _kTextWhite.withValues(alpha: 0.65),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.r,
        height: 30.r,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: _kChampagne.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.close_rounded,
          color: _kTextWhite.withValues(alpha: 0.65),
          size: 15.r,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painters
// ─────────────────────────────────────────────────────────────────────────────

/// Islamic 8-point star geometric tile pattern
class _IslamicGeometricPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  const _IslamicGeometricPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final ringPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    const tileSize = 56.0;
    const r = 18.0;
    const innerR = r * 0.42;
    const points = 8;

    for (double x = 0; x < size.width + tileSize; x += tileSize) {
      for (double y = 0; y < size.height + tileSize; y += tileSize) {
        final center = Offset(x, y);

        // Draw 8-point star
        final path = Path();
        for (int i = 0; i < points; i++) {
          final outerAngle = (i * 2 * math.pi / points) - math.pi / 2;
          final innerAngle =
              outerAngle + (math.pi / points);
          final outerPt =
              Offset(center.dx + r * math.cos(outerAngle),
                  center.dy + r * math.sin(outerAngle));
          final innerPt = Offset(
            center.dx + innerR * math.cos(innerAngle),
            center.dy + innerR * math.sin(innerAngle),
          );
          if (i == 0) {
            path.moveTo(outerPt.dx, outerPt.dy);
          } else {
            path.lineTo(outerPt.dx, outerPt.dy);
          }
          path.lineTo(innerPt.dx, innerPt.dy);
        }
        path.close();
        canvas.drawPath(path, starPaint);

        // Ring around star
        canvas.drawCircle(center, r * 1.45, ringPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IslamicGeometricPainter old) =>
      old.primaryColor != primaryColor;
}

/// Animated diagonal shimmer sweep
class _ShimmerPainter extends CustomPainter {
  final double progress;
  _ShimmerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final x = -size.width + (size.width * 2.6) * progress;
    final gradient = LinearGradient(
      colors: [
        Colors.transparent,
        _kChampagne.withValues(alpha: 0.055),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final rect = Rect.fromLTWH(x, 0, size.width * 0.65, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..blendMode = BlendMode.plus;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter old) =>
      old.progress != progress;
}

/// Crescent moon ornament
class _CrescentPainter extends CustomPainter {
  final Color color;
  const _CrescentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final r = size.width * 0.42;
    final path = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    final cutPath = Path()
      ..addOval(
          Rect.fromCircle(center: Offset(cx + r * 0.55, cy), radius: r * 0.80));
    canvas.drawPath(
      Path.combine(PathOperation.difference, path, cutPath),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CrescentPainter old) => old.color != color;
}
