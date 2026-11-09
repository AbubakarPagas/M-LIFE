// ─────────────────────────────────────────────────────────────────────────────
// ZakatHistoryScreen — all saved calculations with edit/delete/notes
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/zakat_controller.dart';
import '../../data/models/zakat_calculation_model.dart';
import '../widgets/payment_progress_card.dart';
import '../widgets/zakat_geometric_painter.dart';

const Color _kGold = Color(0xffCDAD80);
const Color _kGreen = Color(0xff2E7D32);
const Color _kRed = Color(0xffE53935);

class ZakatHistoryScreen extends StatelessWidget {
  const ZakatHistoryScreen({super.key});

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
                  'Calculation History',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                actions: [
                  Obx(
                    () => ctrl.history.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.delete_sweep_rounded,
                              color: _kRed,
                              size: 22.r,
                            ),
                            onPressed: () => _confirmClear(context, ctrl),
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(width: 4.w),
                ],
              ),
              Obx(() {
                if (ctrl.history.isEmpty) {
                  return SliverFillRemaining(child: _EmptyHistory(cs: cs));
                }
                return SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 8.h,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _HistoryCard(
                        calc: ctrl.history[i],
                        ctrl: ctrl,
                        context: ctx,
                      ),
                      childCount: ctrl.history.length,
                    ),
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
          'Delete all calculation history? This cannot be undone.',
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
            onPressed: () {
              ctrl.history.clear();
              Navigator.pop(context);
            },
            child: Text(
              'Delete All',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: _kRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyHistory({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            size: 54.r,
            color: cs.primary.withValues(alpha: 0.20),
          ),
          SizedBox(height: 16.h),
          Text(
            'No calculations yet',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: cs.primary.withValues(alpha: 0.40),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your saved calculations will appear here.',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 12.sp,
              color: cs.primary.withValues(alpha: 0.30),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ZakatCalculationModel calc;
  final ZakatController ctrl;
  final BuildContext context;
  const _HistoryCard({
    required this.calc,
    required this.ctrl,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final theme = Theme.of(ctx);
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
    final dt = calc.calculatedAt;
    final dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.07 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: _kGold.withValues(alpha: isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: _kGold,
                    size: 19.r,
                  ),
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
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.hintColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Nisab: ${calc.nisabMethod.name[0].toUpperCase()}${calc.nisabMethod.name.substring(1)} method',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 10.sp,
                          color: theme.hintColor.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  ctrl.formatCurrency(calc.zakatDue),
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: calc.isZakatObligatory
                        ? _kGold
                        : theme.hintColor.withValues(alpha: 0.30),
                  ),
                ),
              ],
            ),
          ),
          // ── Stats row ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
            child: Row(
              children: [
                _StatChip(
                  label: 'Assets',
                  value: ctrl.formatCurrency(calc.totalAssets),
                  color: _kGreen,
                ),
                SizedBox(width: 8.w),
                _StatChip(
                  label: 'Liabilities',
                  value: ctrl.formatCurrency(calc.totalLiabilities),
                  color: _kRed,
                ),
                SizedBox(width: 8.w),
                _StatChip(
                  label: 'Net',
                  value: ctrl.formatCurrency(calc.netWealth),
                  color: cs.primary,
                ),
              ],
            ),
          ),
          // ── Payment progress ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 4.h),
            child: PaymentProgressCard(
              calc: calc,
              formattedZakatDue: ctrl.formatCurrency(calc.zakatDue),
              formattedPaid: ctrl.formatCurrency(calc.amountPaid),
              formattedRemaining: ctrl.formatCurrency(calc.remainingDue),
            ),
          ),
          // ── Notes ────────────────────────────────────────────────────────
          if (calc.notes != null && calc.notes!.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 8.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  calc.notes!,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 11.sp,
                    color: theme.hintColor.withValues(alpha: 0.55),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          // ── Actions ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _IconBtn(
                  icon: Icons.note_add_rounded,
                  label: 'Note',
                  color: cs.primary,
                  onTap: () => _showNoteDialog(ctx, calc),
                ),
                SizedBox(width: 8.w),
                _IconBtn(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  color: _kRed,
                  onTap: () => _confirmDelete(ctx, calc.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNoteDialog(BuildContext ctx, ZakatCalculationModel calc) {
    final noteCtrl = TextEditingController(text: calc.notes ?? '');
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(
          'Add Note',
          style: TextStyle(fontFamily: 'kufi', fontSize: 15.sp),
        ),
        content: TextField(
          controller: noteCtrl,
          maxLines: 3,
          style: TextStyle(fontFamily: 'kufi', fontSize: 13.sp),
          decoration: InputDecoration(
            hintText: 'Add a note…',
            hintStyle: TextStyle(fontFamily: 'kufi', fontSize: 12.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(fontFamily: 'kufi', fontSize: 13.sp),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ctrl.addNote(id: calc.id, note: noteCtrl.text);
              Navigator.pop(ctx);
            },
            child: Text(
              'Save',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, String id) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(
          'Delete Calculation',
          style: TextStyle(fontFamily: 'kufi', fontSize: 15.sp),
        ),
        content: Text(
          'Remove this calculation from history?',
          style: TextStyle(fontFamily: 'kufi', fontSize: 12.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(fontFamily: 'kufi', fontSize: 13.sp),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ctrl.deleteHistory(id);
              Navigator.pop(ctx);
            },
            child: Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: _kRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.14 : 0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 9.sp,
                color: Theme.of(context).hintColor.withValues(alpha: 0.40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14.r),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
