// ─────────────────────────────────────────────────────────────────────────────
// ZakatResultScreen — final calculation result with all details
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../apps/routes/route_name.dart';
import '../../controllers/zakat_controller.dart';
import '../../data/models/zakat_calculation_model.dart';
import '../widgets/payment_progress_card.dart';
import '../widgets/zakat_geometric_painter.dart';

const Color _kGold = Color(0xffCDAD80);
const Color _kGreen = Color(0xff2E7D32);

class ZakatResultScreen extends StatelessWidget {
  const ZakatResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ZakatController.instance;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final result = ctrl.lastResult.value;
      if (result == null) {
        return Scaffold(
          backgroundColor: cs.secondary,
          body: Center(
            child: Text(
              'No calculation yet.\nPlease go back and calculate.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 14.sp,
                color: cs.primary,
              ),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: cs.secondary,
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: ZakatGeometricPainter(
                  color: isDark ? _kGold : cs.primary,
                  opacity: 0.045,
                ),
              ),
            ),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(cs, context),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(height: 12.h),
                      _ZakatCircle(result: result, ctrl: ctrl),
                      SizedBox(height: 20.h),
                      _NisabResult(result: result, ctrl: ctrl),
                      SizedBox(height: 16.h),
                      _BreakdownCard(result: result, ctrl: ctrl),
                      SizedBox(height: 16.h),
                      PaymentProgressCard(
                        calc: result,
                        formattedZakatDue: ctrl.formatCurrency(result.zakatDue),
                        formattedPaid: ctrl.formatCurrency(result.amountPaid),
                        formattedRemaining: ctrl.formatCurrency(
                          result.remainingDue,
                        ),
                        onUpdatePayment: () =>
                            _showPaymentDialog(context, result, ctrl),
                      ),
                      SizedBox(height: 16.h),
                      _MetalPricesCard(result: result, ctrl: ctrl),
                      SizedBox(height: 16.h),
                      _ActionButtons(result: result, ctrl: ctrl),
                      SizedBox(height: 40.h),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  SliverAppBar _buildAppBar(ColorScheme cs, BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: cs.secondary,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: cs.primary,
          size: 20.r,
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        'Zakat Result',
        style: TextStyle(
          fontFamily: 'kufi',
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: cs.primary,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.history_rounded, color: cs.primary, size: 22.r),
          onPressed: () => Get.toNamed(RoutesName.zakatHistory),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  void _showPaymentDialog(
    BuildContext ctx,
    ZakatCalculationModel calc,
    ZakatController ctrl,
  ) {
    final amtCtrl = TextEditingController(
      text: calc.amountPaid > 0 ? calc.amountPaid.toStringAsFixed(2) : '',
    );
    var status = calc.paymentStatus.obs;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Payment',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(ctx).hintColor,
                ),
              ),
              SizedBox(height: 16.h),
              Obx(
                () => Wrap(
                  spacing: 8.w,
                  children: PaymentStatus.values.map((s) {
                    final isSelected = status.value == s;
                    final color = s == PaymentStatus.paid
                        ? _kGreen
                        : s == PaymentStatus.partiallyPaid
                        ? _kGold
                        : const Color(0xffE53935);
                    return GestureDetector(
                      onTap: () => status.value = s,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? color
                                : color.withValues(alpha: 0.30),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          s.name[0].toUpperCase() + s.name.substring(1),
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 12.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: isSelected
                                ? color
                                : color.withValues(alpha: 0.60),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: amtCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(fontFamily: 'kufi', fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: 'Amount Paid',
                  labelStyle: TextStyle(fontFamily: 'kufi', fontSize: 12.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final paid = double.tryParse(amtCtrl.text) ?? 0;
                    await ctrl.updatePayment(
                      id: calc.id,
                      status: status.value,
                      amountPaid: paid,
                    );
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Zakat circular indicator
// ─────────────────────────────────────────────────────────────────────────────
class _ZakatCircle extends StatelessWidget {
  final ZakatCalculationModel result;
  final ZakatController ctrl;
  const _ZakatCircle({required this.result, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = result.netWealth > 0
        ? (result.zakatDue / result.netWealth).clamp(0.0, 1.0)
        : 0.0;

    return Center(
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 80.r,
            lineWidth: 10.r,
            percent: pct,
            animation: true,
            animationDuration: 1000,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: result.isZakatObligatory
                ? _kGold
                : theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.10),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  result.isZakatObligatory ? '2.5%' : '0%',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: result.isZakatObligatory
                        ? _kGold
                        : theme.hintColor.withValues(alpha: 0.40),
                  ),
                ),
                Text(
                  'Zakat Rate',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.sp,
                    color: theme.hintColor.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            ctrl.formatCurrency(result.zakatDue),
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: result.isZakatObligatory
                  ? _kGold
                  : theme.hintColor.withValues(alpha: 0.35),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Zakat Due',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 12.sp,
              color: theme.hintColor.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nisab result banner
// ─────────────────────────────────────────────────────────────────────────────
class _NisabResult extends StatelessWidget {
  final ZakatCalculationModel result;
  final ZakatController ctrl;
  const _NisabResult({required this.result, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isObl = result.isZakatObligatory;
    final color = isObl ? _kGreen : Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(
            isObl ? Icons.verified_rounded : Icons.info_outline_rounded,
            color: color,
            size: 22.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isObl ? '✅ Zakat is Obligatory' : '❌ Nisab Not Reached',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Nisab (${result.nisabMethod.name}): ${ctrl.formatCurrency(result.nisabValue)} | '
                  'Net Wealth: ${ctrl.formatCurrency(result.netWealth)}',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.sp,
                    color: color.withValues(alpha: 0.65),
                    height: 1.4,
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

// ─────────────────────────────────────────────────────────────────────────────
// Breakdown Card
// ─────────────────────────────────────────────────────────────────────────────
class _BreakdownCard extends StatelessWidget {
  final ZakatCalculationModel result;
  final ZakatController ctrl;
  const _BreakdownCard({required this.result, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final rows = [
      ('Total Assets', result.totalAssets, _kGreen),
      ('Total Liabilities', result.totalLiabilities, const Color(0xffE53935)),
      ('Net Wealth', result.netWealth, cs.primary),
      ('Nisab Threshold', result.nisabValue, const Color(0xff9E9E9E)),
      ('Zakat Due (2.5%)', result.zakatDue, _kGold),
    ];

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.07 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calculation Breakdown',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: theme.hintColor,
            ),
          ),
          SizedBox(height: 14.h),
          ...rows.map(
            (r) => _BreakdownRow(
              label: r.$1,
              value: ctrl.formatCurrency(r.$2),
              color: r.$3,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 12.sp,
                color: theme.hintColor.withValues(alpha: 0.65),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metal Prices Card
// ─────────────────────────────────────────────────────────────────────────────
class _MetalPricesCard extends StatelessWidget {
  final ZakatCalculationModel result;
  final ZakatController ctrl;
  const _MetalPricesCard({required this.result, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kGold.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Icon(Icons.price_change_rounded, color: _kGold, size: 20.r),
          SizedBox(width: 10.w),
          Text(
            'Prices used:',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 11.sp,
              color: theme.hintColor.withValues(alpha: 0.55),
            ),
          ),
          const Spacer(),
          Text(
            'Gold ${ctrl.formatCurrency(result.goldPricePerGram)}/g',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: _kGold,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'Silver ${ctrl.formatCurrency(result.silverPricePerGram)}/g',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Buttons
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final ZakatCalculationModel result;
  final ZakatController ctrl;
  const _ActionButtons({required this.result, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            icon: Icons.history_rounded,
            label: 'History',
            color: cs.primary,
            onTap: () => Get.toNamed(RoutesName.zakatHistory),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _ActionBtn(
            icon: Icons.menu_book_rounded,
            label: 'Learn',
            color: _kGreen,
            onTap: () => Get.toNamed(RoutesName.zakatEducation),
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.18 : 0.10),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.25 : 0.18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18.r),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
