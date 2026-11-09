// ─────────────────────────────────────────────────────────────────────────────
// ZakatLiabilitiesScreen — enter deductible liabilities
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controllers/zakat_controller.dart';
import '../../data/models/zakat_liabilities_model.dart';
import '../widgets/zakat_amount_field.dart';
import '../widgets/zakat_geometric_painter.dart';

const Color _kGold = Color(0xffCDAD80);
const Color _kRed = Color(0xffE53935);

class ZakatLiabilitiesScreen extends StatefulWidget {
  const ZakatLiabilitiesScreen({super.key});
  @override
  State<ZakatLiabilitiesScreen> createState() => _ZakatLiabilitiesScreenState();
}

class _ZakatLiabilitiesScreenState extends State<ZakatLiabilitiesScreen> {
  late ZakatLiabilitiesModel _draft;
  late ZakatController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ZakatController.instance;
    _draft = _ctrl.liabilities.value;
  }

  void _update(ZakatLiabilitiesModel updated) {
    setState(() => _draft = updated);
    _ctrl.updateLiabilities(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final currency = _ctrl.settings.value.currency;

    return Scaffold(
      backgroundColor: cs.secondary,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ZakatGeometricPainter(
                color: isDark ? _kGold : cs.primary,
                opacity: 0.04,
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
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
                  'Liabilities',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                actions: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: Text(
                        '- ${_ctrl.formatCurrency(_draft.total)}',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: _kRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _InfoBanner(),
                    SizedBox(height: 16.h),
                    _LiabSection(
                      currency: currency,
                      draft: _draft,
                      onUpdate: _update,
                      ctrl: _ctrl,
                    ),
                    SizedBox(height: 16.h),
                    _TotalCard(total: _draft.total, ctrl: _ctrl),
                    SizedBox(height: 40.h),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: cs.primary, size: 18.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Only short-term (immediate) liabilities are deductible from Zakatable wealth. Long-term loans are generally not deductible according to most scholars.',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 11.sp,
                color: theme.hintColor.withValues(alpha: 0.60),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiabSection extends StatelessWidget {
  final String currency;
  final ZakatLiabilitiesModel draft;
  final ValueChanged<ZakatLiabilitiesModel> onUpdate;
  final ZakatController ctrl;
  const _LiabSection({
    required this.currency,
    required this.draft,
    required this.onUpdate,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final fields = [
      (
        'Short-term Debts',
        'Debts due within the year',
        draft.shortTermDebts,
        (double v) => onUpdate(draft.copyWith(shortTermDebts: v)),
      ),
      (
        'Bills Due',
        'Utility, rent, bills payable now',
        draft.billsDue,
        (double v) => onUpdate(draft.copyWith(billsDue: v)),
      ),
      (
        'Business Expenses',
        'Outstanding business costs',
        draft.businessExpenses,
        (double v) => onUpdate(draft.copyWith(businessExpenses: v)),
      ),
      (
        'Loans Payable',
        'Current portion of loans',
        draft.loansPayable,
        (double v) => onUpdate(draft.copyWith(loansPayable: v)),
      ),
      (
        'Other Liabilities',
        'Any other immediate obligations',
        draft.otherLiabilities,
        (double v) => onUpdate(draft.copyWith(otherLiabilities: v)),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: _kRed.withValues(alpha: isDark ? 0.18 : 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: _kRed.withValues(alpha: isDark ? 0.06 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: _kRed.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.remove_circle_outline_rounded,
                  color: _kRed,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Deductible Liabilities',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...fields.map(
            (f) => Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: ZakatAmountField(
                label: f.$1,
                hint: f.$2,
                initialValue: f.$3,
                currency: currency,
                onChanged: f.$4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double total;
  final ZakatController ctrl;
  const _TotalCard({required this.total, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kRed.withValues(alpha: 0.90),
            _kRed.withValues(alpha: 0.70),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: _kRed.withValues(alpha: 0.30),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.remove_circle_rounded, color: Colors.white, size: 28.r),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Liabilities',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.70),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                ctrl.formatCurrency(total),
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
