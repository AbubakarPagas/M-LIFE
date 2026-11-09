// ─────────────────────────────────────────────────────────────────────────────
// payment_screen.dart  —  secure payment method selection + amount entry.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/sadaqah_controller.dart';
import '../models/campaign_model.dart';
import '../models/donation_model.dart';
import '../widgets/sadaqah_colors.dart';
import 'donation_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final CampaignModel campaign;
  const PaymentScreen({super.key, required this.campaign});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final SadaqahController _ctrl = Get.find<SadaqahController>();
  final _amountCtrl = TextEditingController(text: '50');
  PaymentMethod _selectedMethod = PaymentMethod.card;

  final List<double> _quickAmounts = [10, 25, 50, 100, 250, 500];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: SadaqahColors.headerTop,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Complete Donation',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          // Secure badge
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 13.sp,
                  color: SadaqahColors.gold,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Secure',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: SadaqahColors.gold,
                    fontFamily: 'kufi',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Campaign summary ──────────────────────────────────────────
            _CampaignSummaryCard(campaign: widget.campaign),
            SizedBox(height: 22.h),

            // ── Donation type toggle ──────────────────────────────────────
            _SectionLabel('Donation Type'),
            SizedBox(height: 10.h),
            Obx(
              () => _DonationTypeToggle(
                isMonthly: _ctrl.isMonthly.value,
                onToggle: _ctrl.toggleMonthly,
              ),
            ),
            SizedBox(height: 22.h),

            // ── Amount ────────────────────────────────────────────────────
            _SectionLabel('Select Amount'),
            SizedBox(height: 10.h),
            _QuickAmountGrid(amounts: _quickAmounts, controller: _amountCtrl),
            SizedBox(height: 14.h),
            _AmountField(controller: _amountCtrl),
            SizedBox(height: 22.h),

            // ── Payment methods ───────────────────────────────────────────
            _SectionLabel('Payment Method'),
            SizedBox(height: 10.h),
            ...PaymentMethod.values.map(
              (m) => _PaymentMethodTile(
                method: m,
                selected: m == _selectedMethod,
                onTap: () => setState(() => _selectedMethod = m),
              ),
            ),
            SizedBox(height: 28.h),

            // ── Confirm button ────────────────────────────────────────────
            Obx(
              () => _ConfirmButton(
                isLoading: _ctrl.isSubmitting.value,
                onTap: _confirmDonation,
              ),
            ),
            SizedBox(height: 16.h),

            // Security note
            Center(
              child: Text(
                '🔒  Your payment is encrypted and secure',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: theme.hintColor.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDonation() async {
    final raw = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (raw <= 0) {
      Get.snackbar(
        'Invalid Amount',
        'Please enter a valid donation amount.',
        backgroundColor: SadaqahColors.urgent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final ok = await _ctrl.donate(
      campaignId: widget.campaign.id,
      amount: raw,
      paymentMethod: _selectedMethod.label,
    );

    if (ok && mounted) {
      Get.off(
        () => DonationSuccessScreen(
          campaignTitle: widget.campaign.title,
          amount: raw,
          paymentMethod: _selectedMethod.label,
          isMonthly: _ctrl.isMonthly.value,
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _CampaignSummaryCard extends StatelessWidget {
  final CampaignModel campaign;
  const _CampaignSummaryCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: SadaqahColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: SadaqahColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(campaign.emoji, style: TextStyle(fontSize: 34.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'kufi',
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${campaign.formattedRaised} raised of ${campaign.formattedGoal}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: SadaqahColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 13.sp,
      fontFamily: 'kufi',
      fontWeight: FontWeight.w700,
      color: Theme.of(context).hintColor,
    ),
  );
}

class _DonationTypeToggle extends StatelessWidget {
  final bool isMonthly;
  final VoidCallback onToggle;
  const _DonationTypeToggle({required this.isMonthly, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _Tab(
            label: 'One-Time',
            selected: !isMonthly,
            icon: '💝',
            onTap: () {
              if (isMonthly) onToggle();
            },
          ),
          _Tab(
            label: 'Monthly',
            selected: isMonthly,
            icon: '🔄',
            onTap: () {
              if (!isMonthly) onToggle();
            },
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label, icon;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: selected ? SadaqahColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: TextStyle(fontSize: 14.sp)),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'kufi',
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? Colors.white : Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAmountGrid extends StatefulWidget {
  final List<double> amounts;
  final TextEditingController controller;
  const _QuickAmountGrid({required this.amounts, required this.controller});

  @override
  State<_QuickAmountGrid> createState() => _QuickAmountGridState();
}

class _QuickAmountGridState extends State<_QuickAmountGrid> {
  double? _selected = 50;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: widget.amounts.map((a) {
        final sel = _selected == a;
        return GestureDetector(
          onTap: () {
            setState(() => _selected = a);
            widget.controller.text = a.toStringAsFixed(0);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: sel ? SadaqahColors.gold : Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: sel
                    ? SadaqahColors.gold
                    : SadaqahColors.gold.withOpacity(0.3),
              ),
              boxShadow: sel
                  ? [
                      BoxShadow(
                        color: SadaqahColors.gold.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              '\$${a.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'kufi',
                fontWeight: FontWeight.w700,
                color: sel ? Colors.white : Theme.of(context).hintColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  const _AmountField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        fontFamily: 'kufi',
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).hintColor,
      ),
      decoration: InputDecoration(
        prefixText: '\$ ',
        prefixStyle: TextStyle(
          fontFamily: 'kufi',
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: SadaqahColors.teal,
        ),
        hintText: 'Enter custom amount',
        filled: true,
        fillColor: Theme.of(context).canvasColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: SadaqahColors.gold.withOpacity(0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: SadaqahColors.gold, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: SadaqahColors.gold.withOpacity(0.3)),
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentMethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: selected
              ? SadaqahColors.gold.withOpacity(0.12)
              : Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected
                ? SadaqahColors.gold
                : SadaqahColors.gold.withOpacity(0.2),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Text(method.icon, style: TextStyle(fontSize: 22.sp)),
            SizedBox(width: 14.w),
            Text(
              method.label,
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'kufi',
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: Theme.of(context).hintColor,
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? SadaqahColors.gold
                      : Theme.of(context).hintColor.withOpacity(0.3),
                  width: 2,
                ),
                color: selected ? SadaqahColors.gold : Colors.transparent,
              ),
              child: selected
                  ? Icon(Icons.check, size: 12.sp, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _ConfirmButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [SadaqahColors.gold, SadaqahColors.goldDark],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: SadaqahColors.gold.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.volunteer_activism, color: Colors.white),
                    SizedBox(width: 8.w),
                    Text(
                      'Confirm Donation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontFamily: 'kufi',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
