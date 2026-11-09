// ─────────────────────────────────────────────────────────────────────────────
// PaymentProgressCard — shows payment status with animated progress
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../data/models/zakat_calculation_model.dart';

class PaymentProgressCard extends StatelessWidget {
  final ZakatCalculationModel calc;
  final String formattedZakatDue;
  final String formattedPaid;
  final String formattedRemaining;
  final VoidCallback? onUpdatePayment;

  const PaymentProgressCard({
    super.key,
    required this.calc,
    required this.formattedZakatDue,
    required this.formattedPaid,
    required this.formattedRemaining,
    this.onUpdatePayment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const kGold = Color(0xffCDAD80);

    final statusColor = _statusColor(calc.paymentStatus);
    final progress = calc.paymentProgress;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Payment Status',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.hintColor,
                ),
              ),
              const Spacer(),
              _StatusBadge(status: calc.paymentStatus),
              if (onUpdatePayment != null) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: onUpdatePayment,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Update',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 10.sp,
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 14.h),
          // Progress bar
          LinearPercentIndicator(
            percent: progress.clamp(0.0, 1.0),
            lineHeight: 8.h,
            barRadius: Radius.circular(4.r),
            backgroundColor: cs.primary.withValues(alpha: 0.10),
            progressColor: statusColor,
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 800,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _PayStat(
                label: 'Total Due',
                value: formattedZakatDue,
                color: theme.hintColor,
              ),
              _PayStat(
                label: 'Paid',
                value: formattedPaid,
                color: const Color(0xff2E7D32),
              ),
              _PayStat(
                label: 'Remaining',
                value: formattedRemaining,
                color: kGold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return const Color(0xff2E7D32);
      case PaymentStatus.partiallyPaid:
        return const Color(0xffCDAD80);
      case PaymentStatus.pending:
        return const Color(0xffE53935);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final PaymentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (status) {
      PaymentStatus.paid => (
        const Color(0xff2E7D32),
        'Paid',
        Icons.check_circle_rounded,
      ),
      PaymentStatus.partiallyPaid => (
        const Color(0xffCDAD80),
        'Partial',
        Icons.timelapse_rounded,
      ),
      PaymentStatus.pending => (
        const Color(0xffE53935),
        'Pending',
        Icons.hourglass_empty_rounded,
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.r, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _PayStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 9.5.sp,
              color: theme.hintColor.withValues(alpha: 0.40),
            ),
          ),
        ],
      ),
    );
  }
}
