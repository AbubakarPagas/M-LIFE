// ─────────────────────────────────────────────────────────────────────────────
// ZakatSettingsScreen — currency, nisab method, reminders
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/zakat_controller.dart';
import '../../data/models/zakat_calculation_model.dart';
import '../widgets/zakat_geometric_painter.dart';

const Color _kGold = Color(0xffCDAD80);

class ZakatSettingsScreen extends StatelessWidget {
  const ZakatSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ZakatController.instance;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
                  'Zakat Settings',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ),
              Obx(() {
                final settings = ctrl.settings.value;
                return SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 8.h,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _SettingsSection(
                        title: 'Calculation',
                        icon: Icons.calculate_rounded,
                        children: [
                          _CurrencyPicker(
                            current: settings.currency,
                            onChanged: (v) => ctrl.updateSettings(
                              settings.copyWith(currency: v),
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: cs.primary.withValues(alpha: 0.07),
                          ),
                          _NisabMethodPicker(
                            current: settings.defaultNisabMethod,
                            onChanged: (v) => ctrl.updateSettings(
                              settings.copyWith(defaultNisabMethod: v),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _SettingsSection(
                        title: 'Reminders',
                        icon: Icons.notifications_rounded,
                        children: [
                          _SwitchTile(
                            icon: Icons.calendar_month_rounded,
                            label: 'Annual Reminder',
                            subtitle: 'Remind me once a year to pay Zakat',
                            value: settings.annualReminderEnabled,
                            onChanged: (v) => ctrl.updateSettings(
                              settings.copyWith(annualReminderEnabled: v),
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: cs.primary.withValues(alpha: 0.07),
                          ),
                          _SwitchTile(
                            icon: Icons.nightlight_round,
                            label: 'Ramadan Reminder',
                            subtitle: 'Remind me during Ramadan',
                            value: settings.ramadanReminderEnabled,
                            onChanged: (v) => ctrl.updateSettings(
                              settings.copyWith(ramadanReminderEnabled: v),
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: cs.primary.withValues(alpha: 0.07),
                          ),
                          _SwitchTile(
                            icon: Icons.alarm_rounded,
                            label: 'Custom Reminder',
                            subtitle: 'Set a custom reminder date',
                            value: settings.customReminderEnabled,
                            onChanged: (v) => ctrl.updateSettings(
                              settings.copyWith(customReminderEnabled: v),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _SettingsSection(
                        title: 'Data',
                        icon: Icons.storage_rounded,
                        children: [
                          _ActionTile(
                            icon: Icons.delete_forever_rounded,
                            label: 'Clear Calculation History',
                            subtitle: 'Remove all saved calculations',
                            color: const Color(0xffE53935),
                            onTap: () => _confirmClear(context, ctrl),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _MetalPriceInfo(ctrl: ctrl),
                      SizedBox(height: 40.h),
                    ]),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, ZakatController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Clear History',
          style: TextStyle(fontFamily: 'kufi', fontSize: 15.sp),
        ),
        content: Text(
          'Delete all saved Zakat calculations?',
          style: TextStyle(fontFamily: 'kufi', fontSize: 12.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontFamily: 'kufi', fontSize: 13.sp),
            ),
          ),
          TextButton(
            onPressed: () async {
              ctrl.history.clear();
              Navigator.pop(context);
              Get.snackbar(
                'Done',
                'History cleared',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Theme.of(context).colorScheme.primary,
                colorText: Colors.white,
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: const Color(0xffE53935),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Row(
            children: [
              Icon(icon, size: 14.r, color: cs.primary.withValues(alpha: 0.55)),
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: cs.primary.withValues(alpha: 0.55),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.07),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _CurrencyPicker extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  const _CurrencyPicker({required this.current, required this.onChanged});

  static const _currencies = [
    'USD',
    'EUR',
    'GBP',
    'SAR',
    'AED',
    'MYR',
    'IDR',
    'PKR',
    'BDT',
    'EGP',
    'TRY',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.currency_exchange_rounded,
              color: cs.primary,
              size: 17.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Currency',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.hintColor,
                  ),
                ),
                Text(
                  'Select your currency',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.sp,
                    color: theme.hintColor.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: current,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
              dropdownColor: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.r),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              items: _currencies
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                        c,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 13.sp,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _NisabMethodPicker extends StatelessWidget {
  final NisabMethod current;
  final ValueChanged<NisabMethod> onChanged;
  const _NisabMethodPicker({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: _kGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.balance_rounded, color: _kGold, size: 17.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nisab Method',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.hintColor,
                  ),
                ),
                Text(
                  'Gold or Silver standard',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.sp,
                    color: theme.hintColor.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<NisabMethod>(
              value: current,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
              dropdownColor: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.r),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              items: NisabMethod.values
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(
                        m.name[0].toUpperCase() + m.name.substring(1),
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 13.sp,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: cs.primary, size: 17.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.hintColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.sp,
                    color: theme.hintColor.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: cs.primary,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 17.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 10.sp,
                      color: theme.hintColor.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.40),
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetalPriceInfo extends StatelessWidget {
  final ZakatController ctrl;
  const _MetalPriceInfo({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Obx(() {
      final prices = ctrl.metalPrices.value;
      final isCache = ctrl.pricesFromCache.value;

      return Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: _kGold.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _kGold.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: _kGold, size: 18.r),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCache
                        ? '📦 Using cached metal prices'
                        : '✅ Live metal prices loaded',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.hintColor.withValues(alpha: 0.70),
                    ),
                  ),
                  if (prices != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      'Gold: ${ctrl.formatCurrency(prices.goldPerGram)}/g  •  Silver: ${ctrl.formatCurrency(prices.silverPerGram)}/g',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 10.sp,
                        color: theme.hintColor.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: () => ctrl.fetchMetalPrices(forceRefresh: true),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Refresh',
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
        ),
      );
    });
  }
}
