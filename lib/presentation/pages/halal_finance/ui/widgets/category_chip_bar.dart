// ─────────────────────────────────────────────────────────────────────────────
// CategoryChipBar — horizontal scrollable category filter chips
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/finance_tip_model.dart';

const Color _kGold = Color(0xffCDAD80);
const Color _kEmerald = Color(0xff1A5C45);

class CategoryChipBar extends StatelessWidget {
  final FinanceCategory selected;
  final ValueChanged<FinanceCategory> onSelected;

  const CategoryChipBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _icons = <FinanceCategory, IconData>{
    FinanceCategory.all:        Icons.grid_view_rounded,
    FinanceCategory.saving:     Icons.savings_rounded,
    FinanceCategory.budgeting:  Icons.account_balance_wallet_rounded,
    FinanceCategory.investing:  Icons.show_chart_rounded,
    FinanceCategory.business:   Icons.store_rounded,
    FinanceCategory.zakat:      Icons.volunteer_activism_rounded,
    FinanceCategory.debt:       Icons.money_off_rounded,
    FinanceCategory.family:     Icons.family_restroom_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 36.h,
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
              gradient: isSelected
                  ? LinearGradient(
                      colors: isDark
                          ? [_kEmerald, const Color(0xff2E8B57)]
                          : [_kEmerald, const Color(0xff2E8B57)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : cs.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected
                    ? _kGold.withValues(alpha: 0.40)
                    : cs.primary.withValues(alpha: 0.14),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _kEmerald.withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
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
                        size: 12.r,
                        color: isSelected
                            ? _kGold
                            : cs.primary.withValues(alpha: 0.55),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        cat.label,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 11.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : cs.primary.withValues(alpha: 0.65),
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
