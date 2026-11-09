import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../controller/allah_names_controller.dart';
import '../model/allah_name_model.dart';
import '../screens/name_detail_screen.dart';
import 'name_colors.dart';

// ─── Grid card ────────────────────────────────────────────────────────────────

class NameGridCard extends StatelessWidget {
  final AllahName name;
  final int index;

  const NameGridCard({super.key, required this.name, required this.index});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AllahNamesController>();
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return AnimationConfiguration.staggeredGrid(
      position: index,
      columnCount: 2,
      duration: const Duration(milliseconds: 380),
      child: ScaleAnimation(
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: () {
              ctrl.addToRecent(name.number - 1);
              Get.to(
                () => NameDetailScreen(name: name),
                transition: Transition.cupertino,
              );
            },
            child: Obx(() {
              final fav = ctrl.isFavorite(name.number);
              final learned = ctrl.learnedNames.contains(name.number);
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: learned
                        ? [
                            kNameEmerald.withValues(alpha: 0.14),
                            cs.surfaceContainer,
                          ]
                        : [cs.primaryContainer, cs.surfaceContainer],
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: learned
                        ? kNameEmerald.withValues(alpha: 0.4)
                        : cs.primary.withValues(alpha: 0.1),
                    width: learned ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Number badge row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 7.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '${name.number}',
                                  style: TextStyle(
                                    fontFamily: 'kufi',
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w800,
                                    color: cs.primary,
                                  ),
                                ),
                              ),
                              if (learned)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: kNameEmerald,
                                  size: 14.r,
                                ),
                            ],
                          ),
                          SizedBox(height: 8.h),

                          // Arabic name
                          Text(
                            name.arabic,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'naskh',
                              fontSize: 30.sp,
                              color: kNameGold,
                              height: 1.6,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6.h),

                          // Transliteration
                          Text(
                            name.transliteration,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: theme.hintColor,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 4.h),

                          // Meaning
                          Text(
                            name.meaning,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 11.sp,
                              color: theme.hintColor.withValues(alpha: 0.65),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Favorite icon
                    Positioned(
                      right: 4.r,
                      bottom: 4.r,
                      child: GestureDetector(
                        onTap: () => ctrl.toggleFavorite(name.number),
                        child: Icon(
                          fav ? Icons.favorite_rounded : Icons.favorite_border,
                          color: fav
                              ? Colors.red
                              : theme.hintColor.withValues(alpha: 0.25),
                          size: 16.r,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── List tile ────────────────────────────────────────────────────────────────

class NameListTile extends StatelessWidget {
  final AllahName name;
  final int index;

  const NameListTile({super.key, required this.name, required this.index});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AllahNamesController>();
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 300),
      child: SlideAnimation(
        horizontalOffset: 40,
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: () {
              ctrl.addToRecent(name.number - 1);
              Get.to(
                () => NameDetailScreen(name: name),
                transition: Transition.cupertino,
              );
            },
            child: Obx(() {
              final fav = ctrl.isFavorite(name.number);
              final learned = ctrl.learnedNames.contains(name.number);
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: learned
                      ? kNameEmerald.withValues(alpha: 0.07)
                      : cs.primaryContainer,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: learned
                        ? kNameEmerald.withValues(alpha: 0.3)
                        : cs.primary.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Number circle
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${name.number}',
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.arabic,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'naskh',
                              fontSize: 26.sp,
                              color: kNameGold,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            name.transliteration,
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: theme.hintColor.withValues(alpha: 0.85),
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            name.meaning,
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 11.sp,
                              color: theme.hintColor.withValues(alpha: 0.55),
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Fav + chevron
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () => ctrl.toggleFavorite(name.number),
                          child: Icon(
                            fav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border,
                            color: fav
                                ? Colors.red
                                : theme.hintColor.withValues(alpha: 0.25),
                            size: 16.r,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: theme.hintColor.withValues(alpha: 0.25),
                          size: 16.r,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
