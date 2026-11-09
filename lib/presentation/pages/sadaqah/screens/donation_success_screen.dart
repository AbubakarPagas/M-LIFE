// ─────────────────────────────────────────────────────────────────────────────
// donation_success_screen.dart — thank-you + dua screen after payment
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../widgets/sadaqah_colors.dart';

class DonationSuccessScreen extends StatefulWidget {
  final String campaignTitle;
  final double amount;
  final String paymentMethod;
  final bool isMonthly;

  const DonationSuccessScreen({
    super.key,
    required this.campaignTitle,
    required this.amount,
    required this.paymentMethod,
    required this.isMonthly,
  });

  @override
  State<DonationSuccessScreen> createState() => _DonationSuccessScreenState();
}

class _DonationSuccessScreenState extends State<DonationSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _scaleCtrl.forward();
    Future.delayed(
      const Duration(milliseconds: 200),
      () => _fadeCtrl.forward(),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),

              // ── Animated check circle ──────────────────────────────────
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 110.w,
                  height: 110.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [SadaqahColors.teal, SadaqahColors.tealLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: SadaqahColors.teal.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 56.sp,
                  ),
                ),
              ),
              SizedBox(height: 28.h),

              // ── Thank you + receipt ────────────────────────────────────
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    Text(
                      'JazakAllahu Khairan! 🤲',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontFamily: 'kufi',
                        fontWeight: FontWeight.w800,
                        color: theme.hintColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'May Allah accept your Sadaqah Jariyah',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: 'kufi',
                        color: theme.hintColor.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Receipt card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        color: theme.canvasColor,
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _row('Campaign', widget.campaignTitle, context),
                          _divider(),
                          _row(
                            'Amount',
                            '\$${widget.amount.toStringAsFixed(0)}',
                            context,
                            valueColor: SadaqahColors.teal,
                          ),
                          _divider(),
                          _row(
                            'Type',
                            widget.isMonthly ? 'Monthly' : 'One-Time',
                            context,
                          ),
                          _divider(),
                          _row('Payment', widget.paymentMethod, context),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Dua banner
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            SadaqahColors.headerTop,
                            SadaqahColors.headerBot,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '﴿ وَمَا تُنفِقُوا مِنْ خَيْرٍ فَلِأَنفُسِكُمْ ﴾',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: 'naskh',
                              color: SadaqahColors.goldLight,
                              height: 1.8,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          const Text(
                            '"Whatever good you give is for yourselves." — Al-Baqarah 2:272',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'اللَّهُمَّ تَقَبَّلْ مِنَّا',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontFamily: 'naskh',
                              color: SadaqahColors.gold,
                            ),
                          ),
                          const Text(
                            'O Allah, accept from us.',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white60,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => SharePlus.instance.share(
                              ShareParams(
                                text:
                                    'I just donated \$${widget.amount.toStringAsFixed(0)} '
                                    'to "${widget.campaignTitle}" via Sadaqah Jariyah. '
                                    'Join me in giving! 🤲',
                              ),
                            ),
                            icon: const Icon(Icons.share_outlined),
                            label: const Text(
                              'Share',
                              style: TextStyle(fontFamily: 'kufi'),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: SadaqahColors.gold,
                              side: const BorderSide(color: SadaqahColors.gold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 13.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              Icons.home_outlined,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Back to Campaigns',
                              style: TextStyle(
                                fontFamily: 'kufi',
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SadaqahColors.gold,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 13.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value,
    BuildContext context, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'kufi',
              color: Theme.of(context).hintColor.withValues(alpha: 0.55),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'kufi',
                fontWeight: FontWeight.w700,
                color: valueColor ?? Theme.of(context).hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: SadaqahColors.gold.withValues(alpha: 0.15));
}
