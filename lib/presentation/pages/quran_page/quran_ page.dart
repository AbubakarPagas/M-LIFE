import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:misbah_path/apps/routes/route_name.dart';

import 'quran.dart';

class Quran extends StatefulWidget {
  const Quran({super.key});

  @override
  State<Quran> createState() => _QuranState();
}

class _QuranState extends State<Quran> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primaryColor = cs.primary;
    final bgColor = cs.primaryContainer;
    final accentColor = cs.surface;

    return Scaffold(
      backgroundColor: bgColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: bgColor,
            elevation: 0,
            pinned: true,
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Decorative Islamic ornament dot
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'القرآن الكريم',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 26,
                      color: primaryColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Search button
              _AppBarIconButton(
                icon: CupertinoIcons.search,
                color: primaryColor,
                onTap: () {},
              ),
              // Settings button
              _AppBarIconButton(
                icon: CupertinoIcons.settings_solid,
                color: primaryColor,
                onTap: () => Navigator.pushNamed(context, RoutesName.setting),
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(58),
              child: _QuranTabBar(
                controller: _tabController,
                primaryColor: primaryColor,
                accentColor: accentColor,
                bgColor: bgColor,
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[QuranSurahList(), QuranJuz(), BookmarksList()],
        ),
      ),
    );
  }
}

// ─── Reusable AppBar icon button ────────────────────────────────────────────
class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AppBarIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.18), width: 1),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ─── Custom Tab Bar ──────────────────────────────────────────────────────────
class _QuranTabBar extends StatelessWidget {
  final TabController controller;
  final Color primaryColor;
  final Color accentColor;
  final Color bgColor;

  const _QuranTabBar({
    required this.controller,
    required this.primaryColor,
    required this.accentColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: controller,
        padding: const EdgeInsets.all(3),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelPadding: EdgeInsets.zero,
        tabs: [
          _TabItem(
            label: 'quran_sorah'.tr,
            selectedColor: bgColor,
            defaultColor: primaryColor,
          ),
          _TabItem(
            label: 'allJuz'.tr,
            selectedColor: bgColor,
            defaultColor: primaryColor,
          ),
          _TabItem(
            label: 'bookmarks'.tr,
            selectedColor: bgColor,
            defaultColor: primaryColor,
          ),
        ],
      ),
    );
  }
}

// ─── Individual tab item with animated color ────────────────────────────────
class _TabItem extends StatelessWidget {
  final String label;
  final Color selectedColor;
  final Color defaultColor;

  const _TabItem({
    required this.label,
    required this.selectedColor,
    required this.defaultColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: const TextStyle(
          fontFamily: 'kufi',
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
        child: Text(label),
      ),
    );
  }
}
