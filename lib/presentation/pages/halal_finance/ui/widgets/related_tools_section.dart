// ─────────────────────────────────────────────────────────────────────────────
// RelatedToolsSection — quick-nav cards for Islamic financial tools
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../apps/routes/route_name.dart';

const Color _kGold = Color(0xffCDAD80);
const Color _kEmerald = Color(0xff1A5C45);

class RelatedToolsSection extends StatelessWidget {
  const RelatedToolsSection({super.key});

  static const _tools = [
    _ToolItem(
      icon: Icons.calculate_rounded,
      title: 'Zakat\nCalculator',
      color: Color(0xffCDAD80),
      gradientEnd: Color(0xffB8864E),
      route: RoutesName.zakat,
    ),
    _ToolItem(
      icon: Icons.volunteer_activism_rounded,
      title: 'Sadaqah\nTracker',
      color: Color(0xff2E8B57),
      gradientEnd: Color(0xff1A5C45),
      route: RoutesName.sadaqah,
    ),
    _ToolItem(
      icon: Icons.favorite_rounded,
      title: 'Waqf\nContributions',
      color: Color(0xffC62828),
      gradientEnd: Color(0xff8B1A1A),
      route: null,
    ),
    _ToolItem(
      icon: Icons.account_tree_rounded,
      title: 'Islamic\nInheritance',
      color: Color(0xff1565C0),
      gradientEnd: Color(0xff0D47A1),
      route: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.apps_rounded,
                color: cs.primary,
                size: 17.r,
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Related Tools',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.hintColor,
                  ),
                ),
                Text(
                  'Quick access to Islamic finance tools',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.sp,
                    color: theme.hintColor.withValues(alpha: 0.42),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 14.h),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 1.60,
          children: _tools.map((t) => _ToolCard(item: t)).toList(),
        ),
      ],
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String title;
  final Color color;
  final Color gradientEnd;
  final String? route;

  const _ToolItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.gradientEnd,
    required this.route,
  });
}

class _ToolCard extends StatelessWidget {
  final _ToolItem item;
  const _ToolCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: item.color.withValues(alpha: isDark ? 0.20 : 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: isDark ? 0.07 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            if (item.route != null) {
              Get.toNamed(item.route!);
            } else {
              Get.snackbar(
                'Coming Soon',
                '${item.title.replaceAll('\n', ' ')} will be available soon!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: _kEmerald,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
                borderRadius: 12,
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        item.color.withValues(alpha: isDark ? 0.22 : 0.12),
                        item.gradientEnd.withValues(alpha: isDark ? 0.14 : 0.07),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13.r),
                    border: Border.all(
                      color: item.color.withValues(alpha: isDark ? 0.18 : 0.12),
                    ),
                  ),
                  child: Icon(item.icon, color: item.color, size: 19.r),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).hintColor,
                          height: 1.4,
                        ),
                      ),
                      if (item.route == null) ...[
                        SizedBox(height: 3.h),
                        Text(
                          'Coming soon',
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 9.sp,
                            color: Theme.of(context).hintColor.withValues(alpha: 0.38),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
