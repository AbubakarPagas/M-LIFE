import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_bar_widget.dart';
import '../widgets/tab_bar_view_widget.dart';

class AdhkarViewDua extends StatefulWidget {
  const AdhkarViewDua({Key? key}) : super(key: key);

  @override
  State<AdhkarViewDua> createState() => _AdhkarViewDuaState();
}

class _AdhkarViewDuaState extends State<AdhkarViewDua>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.secondary,
      appBar: AppBarWidget(
        isTitled: true,
        title: 'athkar'.tr,
        isFontSize: true,
        searchButton: const SizedBox.shrink(),
        isNotifi: true,
        isBooks: false,
        azkar: true,
        bottom: _DuaTabBar(controller: _tabController),
      ),
      body: SafeArea(child: TabBarViewWidget(controller: _tabController)),
    );
  }
}

// ── Animated Tab Bar ───────────────────────────────────────────────────────────

class _DuaTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  const _DuaTabBar({required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.14),
            width: 1,
          ),
        ),
        child: TabBar(
          controller: controller,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                cs.primary,
                Color.lerp(
                  cs.primary,
                  Get.isDarkMode ? Colors.black : Colors.white,
                  0.15,
                )!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.30),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          indicatorPadding: const EdgeInsets.all(3),
          labelColor: cs.secondary,
          unselectedLabelColor: cs.primary,
          labelStyle: const TextStyle(
            fontFamily: 'kufi',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'kufi',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            _TabItem(label: 'azkar'.tr, icon: Icons.auto_stories_rounded),
            _TabItem(label: 'azkarfav'.tr, icon: Icons.bookmark_rounded),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;

  const _TabItem({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}
