// ─────────────────────────────────────────────────────────────────────────────
// FinanceSearchBar — search input for finance tips
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
  final FocusNode _focus = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _focus.addListener(() {
      setState(() => _hasFocus = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
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
        color: _hasFocus
            ? cs.surfaceContainer
            : cs.primary.withValues(alpha: isDark ? 0.08 : 0.055),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _hasFocus
              ? cs.primary.withValues(alpha: 0.35)
              : cs.primary.withValues(alpha: isDark ? 0.18 : 0.10),
          width: _hasFocus ? 1.5 : 1,
        ),
        boxShadow: _hasFocus
            ? [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(
            Icons.search_rounded,
            color: _hasFocus
                ? cs.primary.withValues(alpha: 0.65)
                : cs.primary.withValues(alpha: 0.38),
            size: 18.r,
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              onChanged: widget.onChanged,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 12.5.sp,
                color: cs.primary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12.sp,
                  color: cs.primary.withValues(alpha: 0.32),
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
                    child: Container(
                      margin: EdgeInsets.only(right: 10.w),
                      width: 20.r,
                      height: 20.r,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: cs.primary.withValues(alpha: 0.55),
                        size: 13.r,
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
