// ─────────────────────────────────────────────────────────────────────────────
// ZakatDashboardScreen — main screen for the Zakat Calculator module
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../apps/routes/route_name.dart';
import '../../controllers/zakat_controller.dart';
import '../widgets/nisab_status_banner.dart';
import '../widgets/zakat_geometric_painter.dart';
import '../widgets/zakat_summary_card.dart';

const Color _kGold = Color(0xffCDAD80);
const Color _kGoldDeep = Color(0xffCD9974);
const Color _kGreen = Color(0xff2E7D32);

class ZakatDashboardScreen extends StatefulWidget {
  const ZakatDashboardScreen({super.key});

  @override
  State<ZakatDashboardScreen> createState() => _ZakatDashboardScreenState();
}

class _ZakatDashboardScreenState extends State<ZakatDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final ZakatController _ctrl;
  late final AnimationController _headerAnim;
  late final Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(ZakatController(), permanent: false);
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: cs.secondary,
      body: Stack(
        children: [
          // ── Background pattern ─────────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: ZakatGeometricPainter(
                color: isDark ? _kGold : cs.primary,
                opacity: isDark ? 0.045 : 0.055,
              ),
            ),
          ),
          // ── Radial top glow ────────────────────────────────────────────
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Container(
              height: 300.h,
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
          // ── Main content ───────────────────────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(cs, isDark),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 16.h),
                    FadeTransition(
                      opacity: _headerFade,
                      child: _HeroZakatCard(ctrl: _ctrl),
                    ),
                    SizedBox(height: 16.h),
                    const NisabStatusBanner(),
                    SizedBox(height: 16.h),
                    _LivePricesRow(ctrl: _ctrl),
                    SizedBox(height: 16.h),
                    _StatsGrid(ctrl: _ctrl),
                    SizedBox(height: 20.h),
                    _CalculateButton(ctrl: _ctrl),
                    SizedBox(height: 20.h),
                    _QuickActions(ctrl: _ctrl),
                    SizedBox(height: 24.h),
                    _RecentHistory(ctrl: _ctrl),
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

  SliverAppBar _buildAppBar(ColorScheme cs, bool isDark) {
    return SliverAppBar(
      expandedHeight: 70.h,
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: cs.secondary,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: cs.primary,
          size: 20.r,
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kGoldDeep, _kGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(
              Icons.calculate_rounded,
              color: Colors.white,
              size: 16.r,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'Zakat Calculator',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ],
      ),
      actions: [
        Obx(
          () => _ctrl.isLoadingPrices.value
              ? Padding(
                  padding: EdgeInsets.all(14.r),
                  child: SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: cs.primary,
                    size: 22.r,
                  ),
                  tooltip: 'Refresh prices',
                  onPressed: () => _ctrl.fetchMetalPrices(forceRefresh: true),
                ),
        ),
        IconButton(
          icon: Icon(Icons.settings_rounded, color: cs.primary, size: 22.r),
          onPressed: () => Get.toNamed(RoutesName.zakatSettings),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Zakat Card
// ─────────────────────────────────────────────────────────────────────────────
class _HeroZakatCard extends StatelessWidget {
  final ZakatController ctrl;
  const _HeroZakatCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final zakatDue = ctrl.previewZakat;
      final netWealth = ctrl.previewNetWealth;
      final last = ctrl.lastResult.value;

      return Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary,
              cs.primary.withValues(alpha: 0.80),
              cs.primary.withValues(alpha: 0.65),
            ],
          ),
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: isDark ? 0.30 : 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'الزكاة',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 22.sp,
                    color: _kGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (last != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Last: ${_formatDate(last.calculatedAt)}',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 10.sp,
                        color: Colors.white.withValues(alpha: 0.70),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Zakat Due',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 12.sp,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              ctrl.formatCurrency(zakatDue),
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 32.sp,
                fontWeight: FontWeight.w800,
                color: zakatDue > 0
                    ? _kGold
                    : Colors.white.withValues(alpha: 0.45),
                height: 1.1,
              ),
            ),
            SizedBox(height: 12.h),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
            SizedBox(height: 12.h),
            Row(
              children: [
                _MiniStat(
                  label: 'Net Wealth',
                  value: ctrl.formatCurrency(netWealth),
                  color: Colors.white,
                ),
                SizedBox(width: 16.w),
                const _MiniStat(label: 'Rate', value: '2.5%', color: _kGold),
              ],
            ),
          ],
        ),
      );
    });
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 10.sp,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Live Prices Row
// ─────────────────────────────────────────────────────────────────────────────
class _LivePricesRow extends StatelessWidget {
  final ZakatController ctrl;
  const _LivePricesRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final prices = ctrl.metalPrices.value;
      final isCache = ctrl.pricesFromCache.value;
      return Row(
        children: [
          Expanded(
            child: ZakatSummaryCard(
              label: 'Gold / gram',
              value: prices == null
                  ? '--'
                  : ctrl.formatCurrency(prices.goldPerGram),
              icon: Icons.circle,
              iconColor: _kGold,
              subtitle: isCache ? 'Cached' : 'Live',
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: ZakatSummaryCard(
              label: 'Silver / gram',
              value: prices == null
                  ? '--'
                  : ctrl.formatCurrency(prices.silverPerGram),
              icon: Icons.circle_outlined,
              iconColor: const Color(0xff9E9E9E),
              subtitle: isCache ? 'Cached' : 'Live',
            ),
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Grid — Total Assets, Liabilities, Net Wealth, Zakat Due
// ─────────────────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final ZakatController ctrl;
  const _StatsGrid({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final prices = ctrl.metalPrices.value;
      final goldValue = prices == null
          ? 0.0
          : (ctrl.assets.value.goldMarketValueOverride > 0
                ? ctrl.assets.value.goldMarketValueOverride
                : ctrl.assets.value.goldWeightGrams *
                      (ctrl.assets.value.goldPurity / 100) *
                      prices.goldPerGram);
      final silverValue = prices == null
          ? 0.0
          : (ctrl.assets.value.silverMarketValueOverride > 0
                ? ctrl.assets.value.silverMarketValueOverride
                : ctrl.assets.value.silverWeightGrams * prices.silverPerGram);
      final totalAssets =
          ctrl.assets.value.totalCash +
          goldValue +
          silverValue +
          ctrl.assets.value.totalInvestments +
          ctrl.assets.value.totalBusiness +
          ctrl.assets.value.totalIncome;
      final totalLiabilities = ctrl.liabilities.value.total;
      final netWealth = ctrl.previewNetWealth;
      final zakatDue = ctrl.previewZakat;

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ZakatSummaryCard(
                  label: 'Total Assets',
                  value: ctrl.formatCurrency(totalAssets),
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: cs.primary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ZakatSummaryCard(
                  label: 'Total Liabilities',
                  value: ctrl.formatCurrency(totalLiabilities),
                  icon: Icons.remove_circle_outline_rounded,
                  iconColor: const Color(0xffE53935),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: ZakatSummaryCard(
                  label: 'Net Wealth',
                  value: ctrl.formatCurrency(netWealth),
                  icon: Icons.trending_up_rounded,
                  iconColor: _kGreen,
                  valueColor: _kGreen,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ZakatSummaryCard(
                  label: 'Zakat Due',
                  value: ctrl.formatCurrency(zakatDue),
                  icon: Icons.volunteer_activism_rounded,
                  iconColor: _kGold,
                  valueColor: zakatDue > 0 ? _kGold : null,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calculate Button
// ─────────────────────────────────────────────────────────────────────────────
class _CalculateButton extends StatelessWidget {
  final ZakatController ctrl;
  const _CalculateButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kGoldDeep, _kGold],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: _kGold.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: ctrl.isSaving.value ? null : _onCalculate,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (ctrl.isSaving.value)
                    SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  else
                    Icon(
                      Icons.calculate_rounded,
                      color: Colors.white,
                      size: 20.r,
                    ),
                  SizedBox(width: 10.w),
                  Text(
                    ctrl.isSaving.value ? 'Calculating…' : 'Calculate Zakat',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
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

  void _onCalculate() async {
    final result = await ZakatController.instance.calculate();
    if (result != null) {
      Get.toNamed(RoutesName.zakatResult);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions
// ─────────────────────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final ZakatController ctrl;
  const _QuickActions({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final actions = [
      (
        Icons.account_balance_wallet_rounded,
        'Assets',
        RoutesName.zakatAssets,
        cs.primary,
      ),
      (
        Icons.remove_circle_outline_rounded,
        'Liabilities',
        RoutesName.zakatLiabilities,
        const Color(0xffE53935),
      ),
      (Icons.history_rounded, 'History', RoutesName.zakatHistory, _kGold),
      (Icons.menu_book_rounded, 'Learn', RoutesName.zakatEducation, _kGreen),
    ];

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.08 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: theme.hintColor,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actions
                .map(
                  (a) => _QuickActionBtn(
                    icon: a.$1,
                    label: a.$2,
                    route: a.$3,
                    color: a.$4,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Column(
        children: [
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: color.withValues(alpha: isDark ? 0.22 : 0.14),
              ),
            ),
            child: Icon(icon, color: color, size: 22.r),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 10.5.sp,
              color: Theme.of(context).hintColor.withValues(alpha: 0.70),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent History Preview
// ─────────────────────────────────────────────────────────────────────────────
class _RecentHistory extends StatelessWidget {
  final ZakatController ctrl;
  const _RecentHistory({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Obx(() {
      final recent = ctrl.history.take(3).toList();
      if (recent.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Calculations',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.hintColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Get.toNamed(RoutesName.zakatHistory),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 11.sp,
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...recent.map((calc) => _HistoryTile(calc: calc, ctrl: ctrl)),
        ],
      );
    });
  }
}

class _HistoryTile extends StatelessWidget {
  final dynamic calc;
  final ZakatController ctrl;
  const _HistoryTile({required this.calc, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dt = calc.calculatedAt as DateTime;
    final dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.10 : 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: _kGold.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.receipt_long_rounded, color: _kGold, size: 18.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.hintColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Net Wealth: ${ctrl.formatCurrency(calc.netWealth as double)}',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.5.sp,
                    color: theme.hintColor.withValues(alpha: 0.50),
                  ),
                ),
              ],
            ),
          ),
          Text(
            ctrl.formatCurrency(calc.zakatDue as double),
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: _kGold,
            ),
          ),
        ],
      ),
    );
  }
}
