import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/hadith_controller.dart';
import 'screens/hadith_bookmarks_screen.dart';
import 'screens/hadith_books_screen.dart';
import 'screens/hadith_global_search_screen.dart';
import 'screens/hadith_list_screen.dart';
import 'screens/hadith_sections_screen.dart';

class Hadith extends StatefulWidget {
  const Hadith({super.key});

  @override
  State<Hadith> createState() => _HadithState();
}

class _HadithState extends State<Hadith> {
  @override
  void initState() {
    super.initState();
    HadithController.instance; // warm up the controller
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ctrl = HadithController.instance;

    return Scaffold(
      backgroundColor: cs.tertiary,
      body: Stack(
        children: [
          // ── Islamic geometric background ──────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _IslamicBgPainter(
                primaryColor: cs.primary,
                surfaceColor: cs.surface,
                isDark: Theme.of(context).brightness == Brightness.dark,
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────────
          SafeArea(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // ── Custom AppBar ────────────────────────────────────────
                  _HadithAppBar(
                    cs: cs,
                    ctrl: ctrl,
                    onSearchTap: () => Get.to(
                      () => const HadithGlobalSearchScreen(),
                      transition: Transition.downToUp,
                    ),
                    onSettingsTap: () => _showSettingsSheet(context, ctrl),
                  ),

                  // ── M1: Continue reading banner ──────────────────────────
                  Obx(() {
                    if (!ctrl.hasLastRead) return const SizedBox.shrink();
                    return _ContinueReadingBanner(ctrl: ctrl);
                  }),

                  // ── Tab bar ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: cs.secondary.withValues(alpha: 0.80),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: cs.surface.withValues(alpha: 0.40),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        unselectedLabelColor: Colors.grey,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              cs.primary,
                              cs.primary.withValues(alpha: 0.75),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.30),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.menu_book_rounded, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  'Books',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'kufi',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.bookmark_rounded, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  'Bookmarks',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'kufi',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Expanded(
                    child: TabBarView(
                      children: [HadithBooksScreen(), HadithBookmarksScreen()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── M4: Notification + settings bottom sheet ──────────────────────────────

  void _showSettingsSheet(BuildContext context, HadithController ctrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _HadithSettingsSheet(ctrl: ctrl),
    );
  }
}

// ── Custom AppBar ─────────────────────────────────────────────────────────────

class _HadithAppBar extends StatelessWidget {
  final ColorScheme cs;
  final HadithController ctrl;
  final VoidCallback onSearchTap;
  final VoidCallback onSettingsTap;

  const _HadithAppBar({
    required this.cs,
    required this.ctrl,
    required this.onSearchTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 10),
      child: Row(
        children: [
          // Arabic ornament + title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الحديث الشريف',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 13,
                    color: cs.surface,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'hadith'.tr.capitalizeFirst ?? 'Hadith',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 22,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Search
          _AppBarButton(
            icon: Icons.manage_search_rounded,
            cs: cs,
            tooltip: 'Search all hadiths',
            onTap: onSearchTap,
          ),
          const SizedBox(width: 8),

          // Settings
          _AppBarButton(
            icon: CupertinoIcons.settings_solid,
            cs: cs,
            tooltip: 'Settings',
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final ColorScheme cs;
  final String tooltip;
  final VoidCallback onTap;

  const _AppBarButton({
    required this.icon,
    required this.cs,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cs.secondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: cs.surface.withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.10),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: cs.primary, size: 19),
        ),
      ),
    );
  }
}

// ── M1: Continue reading banner ───────────────────────────────────────────────

class _ContinueReadingBanner extends StatelessWidget {
  final HadithController ctrl;
  const _ContinueReadingBanner({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () async {
        final restored = await ctrl.resumeLastRead();
        if (!restored) return;
        final bookSlug = ctrl.lastReadBook;
        // Navigate to sections first, then the list will auto-scroll
        Get.to(
          () => HadithSectionsScreen(bookSlug: bookSlug),
          transition: Transition.rightToLeft,
        )?.then((_) {
          Get.to(
            () => HadithListScreen(
              bookSlug: bookSlug,
              sectionTitle: ctrl.bookDisplayName(bookSlug),
              sectionKey: ctrl.lastReadSectionKey,
            ),
            transition: Transition.rightToLeft,
          );
        });
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.menu_book_rounded, color: cs.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue reading',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 11,
                      color: cs.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    ctrl.bookDisplayName(ctrl.lastReadBook),
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.primary.withValues(alpha: 0.6),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── M4: Settings sheet ────────────────────────────────────────────────────────

class _HadithSettingsSheet extends StatefulWidget {
  final HadithController ctrl;
  const _HadithSettingsSheet({required this.ctrl});

  @override
  State<_HadithSettingsSheet> createState() => _HadithSettingsSheetState();
}

class _HadithSettingsSheetState extends State<_HadithSettingsSheet> {
  late bool _notifEnabled;

  @override
  void initState() {
    super.initState();
    _notifEnabled = widget.ctrl.isDailyNotifEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hadith Settings',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 16),

            // M4 — Daily notification toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cs.tertiary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.primary.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: cs.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Hadith',
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        Text(
                          'Receive one hadith reminder every day at 7:00 AM',
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.55),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _notifEnabled,
                    activeThumbColor: cs.primary,
                    onChanged: (val) async {
                      await widget.ctrl.setDailyNotification(enabled: val);
                      setState(() => _notifEnabled = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // M1 — Clear last read
            if (widget.ctrl.hasLastRead)
              GestureDetector(
                onTap: () {
                  widget.ctrl.saveLastRead(
                    bookSlug: '',
                    sectionKey: null,
                    scrollIndex: 0,
                  );
                  widget.ctrl.state.lastReadBook.value = '';
                  Get.back();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cs.tertiary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.history_toggle_off_rounded,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Clear reading history',
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Islamic Background Painter ────────────────────────────────────────────────

class _IslamicBgPainter extends CustomPainter {
  final Color primaryColor;
  final Color surfaceColor;
  final bool isDark;

  const _IslamicBgPainter({
    required this.primaryColor,
    required this.surfaceColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Corner arch ornaments ────────────────────────────────────────────
    final archPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.08 : 0.06)
      ..style = PaintingStyle.fill;

    // Top-right large arch circle
    canvas.drawCircle(Offset(size.width + 40, -40), 120, archPaint);
    // Bottom-left arch circle
    canvas.drawCircle(Offset(-40, size.height + 30), 100, archPaint);

    // ── Tiled 8-pointed star grid ─────────────────────────────────────────
    final starPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.055 : 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    const tileSize = 52.0;
    final cols = (size.width / tileSize).ceil() + 2;
    final rows = (size.height / tileSize).ceil() + 2;

    for (int row = -1; row < rows; row++) {
      for (int col = -1; col < cols; col++) {
        final cx = col * tileSize + (row.isOdd ? tileSize / 2 : 0);
        final cy = row * tileSize * 0.88;
        _drawStar8(canvas, starPaint, Offset(cx, cy), tileSize * 0.36);
      }
    }

    // ── Top header band gradient overlay ────────────────────────────────
    final headerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withValues(alpha: isDark ? 0.15 : 0.10),
          primaryColor.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, 200));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 200), headerPaint);

    // ── Subtle divider lines (mashrabiya effect) ─────────────────────────
    final linePaint = Paint()
      ..color = surfaceColor.withValues(alpha: isDark ? 0.06 : 0.08)
      ..strokeWidth = 0.6;

    // Diagonal lines subtle overlay
    const spacing = 36.0;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        linePaint,
      );
    }
  }

  void _drawStar8(Canvas canvas, Paint paint, Offset center, double r) {
    const points = 8;
    final innerR = r * 0.42;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final radius = i.isEven ? r : innerR;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_IslamicBgPainter old) =>
      old.primaryColor != primaryColor ||
      old.surfaceColor != surfaceColor ||
      old.isDark != isDark;
}
