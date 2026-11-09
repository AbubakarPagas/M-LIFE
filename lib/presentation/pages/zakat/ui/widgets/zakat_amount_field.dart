// ─────────────────────────────────────────────────────────────────────────────
// ZakatAmountField — styled currency input field used in asset/liability forms
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ZakatAmountField extends StatefulWidget {
  final String label;
  final String? hint;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final String currency;
  final String? suffixLabel; // e.g. "grams"
  final bool readOnly;
  final TextInputAction? textInputAction;

  const ZakatAmountField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue = 0,
    required this.onChanged,
    this.currency = 'USD',
    this.suffixLabel,
    this.readOnly = false,
    this.textInputAction,
  });

  @override
  State<ZakatAmountField> createState() => _ZakatAmountFieldState();
}

class _ZakatAmountFieldState extends State<ZakatAmountField> {
  late final TextEditingController _ctrl;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.initialValue > 0
          ? widget.initialValue.toStringAsFixed(
              widget.suffixLabel != null ? 3 : 2,
            )
          : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String val) {
    if (val.isEmpty) {
      setState(() => _hasError = false);
      widget.onChanged(0);
      return;
    }
    final parsed = double.tryParse(val);
    if (parsed == null || parsed < 0) {
      setState(() => _hasError = true);
      return;
    }
    setState(() => _hasError = false);
    widget.onChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primary = cs.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: theme.hintColor.withValues(alpha: 0.70),
          ),
        ),
        SizedBox(height: 6.h),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _hasError
                ? Colors.red.withValues(alpha: 0.06)
                : primary.withValues(alpha: isDark ? 0.08 : 0.04),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _hasError
                  ? Colors.red.withValues(alpha: 0.50)
                  : primary.withValues(alpha: isDark ? 0.20 : 0.12),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              if (widget.suffixLabel == null) ...[
                SizedBox(width: 12.w),
                Text(
                  _currencySymbol(widget.currency),
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    color: primary.withValues(alpha: 0.50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  readOnly: widget.readOnly,
                  onChanged: _onChanged,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,4}'),
                    ),
                  ],
                  textInputAction:
                      widget.textInputAction ?? TextInputAction.next,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 14.sp,
                    color: theme.hintColor,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint ?? '0.00',
                    hintStyle: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 13.sp,
                      color: theme.hintColor.withValues(alpha: 0.25),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 13.h,
                    ),
                  ),
                ),
              ),
              if (widget.suffixLabel != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Text(
                    widget.suffixLabel!,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 11.sp,
                      color: primary.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_hasError) ...[
          SizedBox(height: 4.h),
          Text(
            'Please enter a valid positive number',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 10.sp,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  String _currencySymbol(String code) {
    const map = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'SAR': 'SAR',
      'AED': 'AED',
      'MYR': 'RM',
    };
    return map[code] ?? code;
  }
}
