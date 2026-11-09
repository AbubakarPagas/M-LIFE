// ─────────────────────────────────────────────────────────────────────────────
// CategoryChipBar — horizontal scrollable category filters
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/finance_tip_model.dart';

class CategoryChipBar extends StatelessWidget {
  final FinanceCategory selected;
  final ValueChanged<FinanceCategory> onSelected;

  const CategoryChipBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  // Map category → icon
  static const _icons = <FinanceCategory, IconData>{
    FinanceCategory.all: Icons.grid_view_rounded,
    FinanceCategory.saving: Icons.savings_rounded,
    FinanceCategory.budgeting: Icons.account_balance_wallet_rounded,
    FinanceCategory.investing: Icons.show_chart_rounded,
    FinanceCategory.business: Icons.store_rounded,
    FinanceCategory.zakat: Icons.volunteer_activism_rounded,
    FinanceCategory.debt: Icons.money_off_rounded,
    FinanceCategory.family: Icons.family_restroom_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        itemCount: FinanceCategory.values.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final cat = FinanceCategory.values[i];
          final isSelected = cat == selected;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? cs.primary
                  : cs.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected
                    ? cs.primary
                    : cs.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () => onSelected(cat),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _icons[cat] ?? Icons.label_rounded,
                        size: 13.r,
                        color: isSelected
                            ? Colors.white
                            : cs.primary.withValues(alpha: 0.60),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        cat.label,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 11.5.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : cs.primary.withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
