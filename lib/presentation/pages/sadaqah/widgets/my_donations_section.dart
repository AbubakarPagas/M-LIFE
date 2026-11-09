// ─────────────────────────────────────────────────────────────────────────────
// my_donations_section.dart — total donated + history list + receipt share
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/sadaqah_controller.dart';
import '../models/donation_model.dart';
import 'sadaqah_colors.dart';

class MyDonationsSection extends StatelessWidget {
  const MyDonationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = SadaqahController.instance;
    final theme = Theme.of(context);

    return Obx(() {
      final history = ctrl.donationHistory;
      final total = ctrl.totalDonated;
      final isLoading = ctrl.isLoadingHistory.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Total donated banner ────────────────────────────────────────
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SadaqahColors.headerTop, SadaqahColors.headerBot],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: SadaqahColors.gold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('🤲', style: TextStyle(fontSize: 24.sp)),
                  ),
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Sadaqah',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'kufi',
                        color: SadaqahColors.goldLight,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '\$${total.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontFamily: 'kufi',
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      '${history.length}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontFamily: 'kufi',
                        fontWeight: FontWeight.w800,
                        color: SadaqahColors.gold,
                      ),
                    ),
                    Text(
                      'Donations',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontFamily: 'kufi',
                        color: SadaqahColors.goldLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 22.h),

          // ── Section title ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Donation History',
              style: TextStyle(
                fontSize: 15.sp,
                fontFamily: 'kufi',
                fontWeight: FontWeight.w700,
                color: theme.hintColor,
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // ── List ────────────────────────────────────────────────────────
          if (isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                  strokeWidth: 2.5,
                ),
              ),
            )
          else if (history.isEmpty)
            _EmptyHistory()
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: history.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, i) => _DonationTile(donation: history[i]),
            ),
        ],
      );
    });
  }
}

// ── Single history tile ───────────────────────────────────────────────────────
class _DonationTile extends StatelessWidget {
  final DonationModel donation;
  const _DonationTile({required this.donation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        leading: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              donation.campaignEmoji,
              style: TextStyle(fontSize: 20.sp),
            ),
          ),
        ),
        title: Text(
          donation.campaignTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: 'kufi',
            fontWeight: FontWeight.w600,
            color: theme.hintColor,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              donation.formattedDate,
              style: TextStyle(
                fontSize: 10.sp,
                color: theme.hintColor.withValues(alpha: 0.50),
              ),
            ),
            if (donation.isMonthly) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: SadaqahColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  'Monthly',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: SadaqahColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  donation.formattedAmount,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'kufi',
                    fontWeight: FontWeight.w800,
                    color: SadaqahColors.teal,
                  ),
                ),
                Text(
                  donation.paymentMethod,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: theme.hintColor.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => SharePlus.instance.share(
                ShareParams(
                  text:
                      'My Sadaqah receipt:\n'
                      'Campaign: ${donation.campaignTitle}\n'
                      'Amount: ${donation.formattedAmount}\n'
                      'Date: ${donation.formattedDate}\n'
                      'Method: ${donation.paymentMethod}\n\n'
                      'Barak Allahu feekum 🤲',
                ),
              ),
              child: Icon(
                Icons.download_outlined,
                size: 20.sp,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Column(
        children: [
          Text('🤲', style: TextStyle(fontSize: 48.sp)),
          SizedBox(height: 12.h),
          Text(
            'No donations yet',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'kufi',
              color: Theme.of(context).hintColor.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Your Sadaqah Jariyah will appear here',
            style: TextStyle(
              fontSize: 11.sp,
              color: Theme.of(context).hintColor.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
