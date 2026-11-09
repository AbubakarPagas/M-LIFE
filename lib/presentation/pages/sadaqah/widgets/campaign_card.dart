// ─────────────────────────────────────────────────────────────────────────────
// campaign_card.dart — rich campaign card with progress bar & donate button
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/sadaqah_controller.dart';
import '../models/campaign_model.dart';
import '../screens/payment_screen.dart';
import '../widgets/sadaqah_colors.dart';
import '../widgets/sadaqah_progress_bar.dart';

class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;

  const CampaignCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctrl = SadaqahController.instance;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Colour band header ──────────────────────────────────────────
          _CardHeader(
            campaign: campaign,
            onFavorite: () => ctrl.toggleFavorite(campaign.id),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '${CampaignCategory.emoji(campaign.category)}  ${campaign.category}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontFamily: 'kufi',
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),

                // Title
                Text(
                  campaign.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'kufi',
                    fontWeight: FontWeight.w700,
                    color: theme.hintColor,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 6.h),

                // Description
                Text(
                  campaign.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: theme.hintColor.withValues(alpha: 0.65),
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 12.h),

                // Progress bar + amounts
                SadaqahProgressBar(
                  progress: campaign.progress,
                  primaryColor: theme.dividerColor,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text(
                      campaign.formattedRaised,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'kufi',
                        fontWeight: FontWeight.w700,
                        color: theme.dividerColor,
                      ),
                    ),
                    Text(
                      ' raised of ',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.hintColor.withValues(alpha: 0.50),
                      ),
                    ),
                    Text(
                      campaign.formattedGoal,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontFamily: 'kufi',
                        color: theme.hintColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(campaign.progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontFamily: 'kufi',
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Donor count + share + donate row
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 13.sp,
                      color: theme.hintColor.withValues(alpha: 0.55),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${campaign.donorCount} donors',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontFamily: 'kufi',
                        color: theme.hintColor.withValues(alpha: 0.55),
                      ),
                    ),
                    const Spacer(),

                    // Share
                    GestureDetector(
                      onTap: () => SharePlus.instance.share(
                        ShareParams(
                          text:
                              'Help fund "${campaign.title}" — '
                              '${campaign.formattedRaised} raised of '
                              '${campaign.formattedGoal}. Donate now! 🤲',
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(7.w),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.share_outlined,
                          size: 15.sp,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Donate button
                    GestureDetector(
                      onTap: () => Get.to(
                        () => PaymentScreen(campaign: campaign),
                        transition: Transition.downToUp,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 9.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.30),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'Donate',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontFamily: 'kufi',
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gradient header band ──────────────────────────────────────────────────────
class _CardHeader extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback onFavorite;
  const _CardHeader({required this.campaign, required this.onFavorite});

  static const _gradients = <String, List<Color>>{
    CampaignCategory.waterWell: [Color(0xFF1B6CA8), Color(0xFF1E3C72)],
    CampaignCategory.quranSponsorship: [Color(0xFF2C5F2E), Color(0xFF1A3A1B)],
    CampaignCategory.orphanSupport: [Color(0xFF614385), Color(0xFF516395)],
    CampaignCategory.mosqueConstruction: [Color(0xFF373B44), Color(0xFF4286F4)],
    CampaignCategory.islamicEducation: [Color(0xFF834D9B), Color(0xFFD04ED6)],
    CampaignCategory.emergencyRelief: [Color(0xFFB71C1C), Color(0xFF880E4F)],
  };

  @override
  Widget build(BuildContext context) {
    final colors =
        _gradients[campaign.category] ??
        [SadaqahColors.headerTop, SadaqahColors.headerBot];

    return Container(
      height: 110.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: _circle(80.r, Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: _circle(100.r, Colors.white.withValues(alpha: 0.04)),
          ),

          // Emoji
          Center(
            child: Text(campaign.emoji, style: TextStyle(fontSize: 46.sp)),
          ),

          // Featured badge
          if (campaign.isFeatured)
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: SadaqahColors.gold,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '⭐ Featured',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.white,
                    fontFamily: 'kufi',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          // Favourite button
          Positioned(
            right: 10,
            top: 10,
            child: GestureDetector(
              onTap: onFavorite,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  campaign.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: campaign.isFavorite
                      ? Colors.redAccent
                      : Colors.white70,
                  size: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
