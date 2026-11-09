// ─────────────────────────────────────────────────────────────────────────────
// FinanceSearchBar — search input for tips
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FinanceSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hint;

  const FinanceSearchBar({
    super.key,
    required this.onChanged,
    this.hint = 'Search Islamic finance tips…',
  });

  @override
  State<FinanceSearchBar> createState() => _FinanceSearchBarState();
}

class _FinanceSearchBarState extends State<FinanceSearchBar> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 46.h,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: isDark ? 0.10 : 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.22 : 0.12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(
            Icons.search_rounded,
            color: cs.primary.withValues(alpha: 0.45),
            size: 19.r,
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: widget.onChanged,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: cs.primary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12.sp,
                  color: cs.primary.withValues(alpha: 0.35),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 13.h,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _ctrl,
            builder: (_, val, __) => val.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _ctrl.clear();
                      widget.onChanged('');
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: Icon(
                        Icons.close_rounded,
                        color: cs.primary.withValues(alpha: 0.45),
                        size: 18.r,
                      ),
                    ),
                  )
                : SizedBox(width: 10.w),
          ),
        ],
      ),
    );
  }
}
