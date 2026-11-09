// ─────────────────────────────────────────────────────────────────────────────
// FeaturedCarousel — horizontal PageView of top posts
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../apps/routes/route_name.dart';
import '../../controllers/ummah_feed_controller.dart';
import '../../data/models/feed_post_model.dart';

const _kGold = Color(0xffCDAD80);

class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({super.key});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  final _pageCtrl = PageController(viewportFraction: 0.88);

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = UmmahFeedController.instance;

    return Obx(() {
      final posts = ctrl.featuredPosts;
      if (posts.isEmpty) return const SizedBox.shrink();

      return Column(
        children: [
          SizedBox(
            height: 110.h,
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: posts.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: _FeaturedItem(post: posts[i]),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          SmoothPageIndicator(
            controller: _pageCtrl,
            count: posts.length,
            effect: WormEffect(
              dotHeight: 5.r,
              dotWidth: 5.r,
              activeDotColor: _kGold,
              dotColor: Colors.white.withValues(alpha: 0.30),
              spacing: 4,
            ),
          ),
        ],
      );
    });
  }
}

class _FeaturedItem extends StatelessWidget {
  final FeedPostModel post;
  const _FeaturedItem({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UmmahFeedController.instance.markAsRead(post.id);
        Get.toNamed(RoutesName.ummahFeedDetail, arguments: post);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _kGold.withValues(alpha: 0.35)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: _kGold.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(post.category.icon, color: _kGold, size: 18.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    post.category.label,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 9.5.sp,
                      color: _kGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    post.authorName,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 10.sp,
                      color: Colors.white.withValues(alpha: 0.60),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12.r,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }
}
