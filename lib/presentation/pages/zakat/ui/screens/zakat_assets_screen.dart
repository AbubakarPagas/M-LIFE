// ─────────────────────────────────────────────────────────────────────────────
// ZakatAssetsScreen — enter all zakatable assets
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/zakat_controller.dart';
import '../../data/models/zakat_assets_model.dart';
import '../widgets/zakat_amount_field.dart';
import '../widgets/zakat_geometric_painter.dart';

const Color _kGold = Color(0xffCDAD80);

class ZakatAssetsScreen extends StatefulWidget {
  const ZakatAssetsScreen({super.key});
  @override
  State<ZakatAssetsScreen> createState() => _ZakatAssetsScreenState();
}

class _ZakatAssetsScreenState extends State<ZakatAssetsScreen> {
  late ZakatAssetsModel _draft;
  late ZakatController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ZakatController.instance;
    _draft = _ctrl.assets.value;
  }

  void _update(ZakatAssetsModel updated) {
    setState(() => _draft = updated);
    _ctrl.updateAsset(updated);
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
                  'Zakatable Assets',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                actions: [
                  Obx(() {
                    final prices = _ctrl.metalPrices.value;
                    final goldVal = prices == null
                        ? 0.0
                        : (_draft.goldMarketValueOverride > 0
                              ? _draft.goldMarketValueOverride
                              : _draft.goldWeightGrams *
                                    (_draft.goldPurity / 100) *
                                    prices.goldPerGram);
                    final silverVal = prices == null
                        ? 0.0
                        : (_draft.silverMarketValueOverride > 0
                              ? _draft.silverMarketValueOverride
                              : _draft.silverWeightGrams *
                                    prices.silverPerGram);
                    final total =
                        _draft.totalCash +
                        goldVal +
                        silverVal +
                        _draft.totalInvestments +
                        _draft.totalBusiness +
                        _draft.totalIncome;
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: Text(
                          _ctrl.formatCurrency(total),
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: _kGold,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _AssetSection(
                      icon: Icons.payments_rounded,
                      title: 'Cash & Currency',
                      color: cs.primary,
                      children: [
                        ZakatAmountField(
                          label: 'Cash at Home',
                          initialValue: _draft.cashAtHome,
                          currency: currency,
                          onChanged: (v) =>
                              _update(_draft.copyWith(cashAtHome: v)),
                        ),
                        SizedBox(height: 12.h),
                        ZakatAmountField(
                          label: 'Cash in Bank',
                          initialValue: _draft.cashInBank,
                          currency: currency,
                          onChanged: (v) =>
                              _update(_draft.copyWith(cashInBank: v)),
                        ),
                        SizedBox(height: 12.h),
                        ZakatAmountField(
                          label: 'Foreign Currency',
                          initialValue: _draft.foreignCurrency,
                          currency: currency,
                          onChanged: (v) =>
                              _update(_draft.copyWith(foreignCurrency: v)),
                        ),
                        _SubtotalRow(
                          label: 'Cash Subtotal',
                          value: _draft.totalCash,
                          ctrl: _ctrl,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _GoldSection(
                      draft: _draft,
                      onUpdate: _update,
                      ctrl: _ctrl,
                      currency: currency,
                    ),
                    SizedBox(height: 16.h),
                    _SilverSection(
                      draft: _draft,
                      onUpdate: _update,
                      ctrl: _ctrl,
                      currency: currency,
                    ),
                    SizedBox(height: 16.h),
                    _AssetSection(
                      icon: Icons.show_chart_rounded,
                      title: 'Investments',
                      color: const Color(0xff1565C0),
                      children: [
                        ZakatAmountField(
                          label: 'Stocks',
                          initialValue: _draft.stocks,
                          currency: currency,
                          onChanged: (v) => _update(_draft.copyWith(stocks: v)),
                        ),
                        SizedBox(height: 12.h),
                        ZakatAmountField(
                          label: 'Mutual Funds',
                          initialValue: _draft.mutualFunds,
                          currency: currency,
                          onChanged: (v) =>
                              _update(_draft.copyWith(mutualFunds: v)),
                        ),
                        SizedBox(height: 12.h),
                        ZakatAmountField(
                          label: 'ETFs',
                          initialValue: _draft.etfs,
                          currency: currency,
                          onChanged: (v) => _update(_draft.copyWith(etfs: v)),
                        ),
                        SizedBox(height: 12.h),
                        ZakatAmountField(
                          label: 'Cryptocurrency',
                          initialValue: _draft.cryptocurrency,
                          currency: currency,
                          onChanged: (v) =>
                              _update(_draft.copyWith(cryptocurrency: v)),
                        ),
                        _SubtotalRow(
                          label: 'Investments Subtotal',
                          value: _draft.totalInvestments,
                          ctrl: _ctrl,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _AssetSection(
                      icon: Icons.store_rounded,
                      title: 'Business',
                      color: const Color(0xff6A1B9A),
                      children: [
                        ZakatAmountField(
                          label: 'Business Inventory',
                          initialValue: _draft.businessInventory,
                          currency: currency,
                          onChanged: (v) =>
                              _update(_draft.copyWith(businessInventory: v)),
                        ),
                        SizedBox(height: 12.h),
                        ZakatAmountField(
                          label: 'Business Cash',
                          initialValue: _draft.businessCash,
                          currency: currency,
                          onChanged: (v) =>
                              _update(_draft.copyWith(businessCash: v)),
                        ),
                        SizedBox(height: 12.h),
                        ZakatAmountField(
                          label: 'Receivables',
                          initialValue: _draft.businessReceivables,
                          currency: currency,
                          onChanged: (v) =>
                              _update(_draft.copyWith(businessReceivables: v)),
                        ),
                        _SubtotalRow(
                          label: 'Business Subtotal',
                          value: _draft.totalBusiness,
                          ctrl: _ctrl,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _AssetSection(
                      icon: Icons.savings_rounded,
                      title: 'Income & Savings',
                      color: const Color(0xff2E7D32),
                      children: [
                        ZakatAmountField(
                          label: 'Rental Income',
                          initialValue: _draft.rentalIncome,
                          currency: currency,
                          onChanged: (v) =>
                              _update(_draft.copyWith(rentalIncome: v)),
                        ),
                        SizedBox(height: 12.h),
                        ZakatAmountField(
                          label: 'Savings',
                          initialValue: _draft.savings,
                          currency: currency,
                          onChanged: (v) =>
                              _update(_draft.copyWith(savings: v)),
                        ),
                        _SubtotalRow(
                          label: 'Income Subtotal',
                          value: _draft.totalIncome,
                          ctrl: _ctrl,
                        ),
                      ],
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Helpers: Section wrapper, Gold/Silver sections, Subtotal row
// ─────────────────────────────────────────────────────────────────────────────

class _AssetSection extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;
  const _AssetSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
  });
  @override
  State<_AssetSection> createState() => _AssetSectionState();
}

class _AssetSectionState extends State<_AssetSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: widget.color.withValues(alpha: isDark ? 0.18 : 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: isDark ? 0.06 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(
                        alpha: isDark ? 0.18 : 0.10,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 18.r),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.hintColor,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: theme.hintColor.withValues(alpha: 0.40),
                      size: 22.r,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: widget.color.withValues(alpha: 0.12),
                  ),
                  SizedBox(height: 14.h),
                  ...widget.children,
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

class _SubtotalRow extends StatelessWidget {
  final String label;
  final double value;
  final ZakatController ctrl;
  const _SubtotalRow({
    required this.label,
    required this.value,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: _kGold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: _kGold.withValues(alpha: 0.20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 11.sp,
                color: theme.hintColor.withValues(alpha: 0.60),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              ctrl.formatCurrency(value),
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _kGold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldSection extends StatelessWidget {
  final ZakatAssetsModel draft;
  final ValueChanged<ZakatAssetsModel> onUpdate;
  final ZakatController ctrl;
  final String currency;
  const _GoldSection({
    required this.draft,
    required this.onUpdate,
    required this.ctrl,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return _AssetSection(
      icon: Icons.circle,
      title: 'Gold',
      color: _kGold,
      children: [
        ZakatAmountField(
          label: 'Weight',
          suffixLabel: 'grams',
          initialValue: draft.goldWeightGrams,
          currency: currency,
          onChanged: (v) => onUpdate(draft.copyWith(goldWeightGrams: v)),
        ),
        SizedBox(height: 12.h),
        ZakatAmountField(
          label: 'Purity (%)',
          hint: '100 = 24K',
          suffixLabel: '%',
          initialValue: draft.goldPurity,
          currency: currency,
          onChanged: (v) =>
              onUpdate(draft.copyWith(goldPurity: v.clamp(0, 100))),
        ),
        SizedBox(height: 12.h),
        ZakatAmountField(
          label: 'Market Value Override (optional)',
          hint: 'Leave 0 to auto-calculate',
          initialValue: draft.goldMarketValueOverride,
          currency: currency,
          onChanged: (v) =>
              onUpdate(draft.copyWith(goldMarketValueOverride: v)),
        ),
        Obx(() {
          final prices = ctrl.metalPrices.value;
          final calculated = prices == null
              ? 0.0
              : draft.goldWeightGrams *
                    (draft.goldPurity / 100) *
                    prices.goldPerGram;
          final displayVal = draft.goldMarketValueOverride > 0
              ? draft.goldMarketValueOverride
              : calculated;
          return _SubtotalRow(
            label: 'Gold Value',
            value: displayVal,
            ctrl: ctrl,
          );
        }),
      ],
    );
  }
}

class _SilverSection extends StatelessWidget {
  final ZakatAssetsModel draft;
  final ValueChanged<ZakatAssetsModel> onUpdate;
  final ZakatController ctrl;
  final String currency;
  const _SilverSection({
    required this.draft,
    required this.onUpdate,
    required this.ctrl,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return _AssetSection(
      icon: Icons.circle_outlined,
      title: 'Silver',
      color: const Color(0xff9E9E9E),
      children: [
        ZakatAmountField(
          label: 'Weight',
          suffixLabel: 'grams',
          initialValue: draft.silverWeightGrams,
          currency: currency,
          onChanged: (v) => onUpdate(draft.copyWith(silverWeightGrams: v)),
        ),
        SizedBox(height: 12.h),
        ZakatAmountField(
          label: 'Market Value Override (optional)',
          hint: 'Leave 0 to auto-calculate',
          initialValue: draft.silverMarketValueOverride,
          currency: currency,
          onChanged: (v) =>
              onUpdate(draft.copyWith(silverMarketValueOverride: v)),
        ),
        Obx(() {
          final prices = ctrl.metalPrices.value;
          final calculated = prices == null
              ? 0.0
              : draft.silverWeightGrams * prices.silverPerGram;
          final displayVal = draft.silverMarketValueOverride > 0
              ? draft.silverMarketValueOverride
              : calculated;
          return _SubtotalRow(
            label: 'Silver Value',
            value: displayVal,
            ctrl: ctrl,
          );
        }),
      ],
    );
  }
}
