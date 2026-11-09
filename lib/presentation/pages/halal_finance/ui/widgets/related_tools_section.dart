// ─────────────────────────────────────────────────────────────────────────────
// RelatedToolsSection — quick-nav cards for Islamic financial tools
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../apps/routes/route_name.dart';

class RelatedToolsSection extends StatelessWidget {
  const RelatedToolsSection({super.key});

  static const _tools = [
    _ToolItem(
      icon: Icons.calculate_rounded,
      title: 'Zakat\nCalculator',
      color: Color(0xffCDAD80),
      route: RoutesName.zakat,
    ),
    _ToolItem(
      icon: Icons.volunteer_activism_rounded,
      title: 'Sadaqah\nTracker',
      color: Color(0xff2E7D32),
      route: RoutesName.sadaqah,
    ),
    _ToolItem(
      icon: Icons.favorite_rounded,
      title: 'Waqf\nContributions',
      color: Color(0xffC62828),
      route: null, // placeholder
    ),
    _ToolItem(
      icon: Icons.account_tree_rounded,
      title: 'Islamic\nInheritance',
      color: Color(0xff1565C0),
      route: null, // placeholder
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w, bottom: 12.h),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.apps_rounded,
                  color: theme.colorScheme.primary,
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
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 1.55,
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
  final String? route;
  const _ToolItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.route,
  });
}

class _ToolCard extends StatelessWidget {
  final _ToolItem item;
  const _ToolCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: item.color.withValues(alpha: isDark ? 0.22 : 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                backgroundColor: cs.primary,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(item.icon, color: item.color, size: 20.r),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.hintColor,
                      height: 1.4,
                    ),
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
