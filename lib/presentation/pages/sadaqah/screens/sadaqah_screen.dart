// ─────────────────────────────────────────────────────────────────────────────
// sadaqah_screen.dart — Sadaqah Jariyah main screen
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/sadaqah_controller.dart';
import '../data/mock_data.dart';
import '../widgets/campaign_card.dart';
import '../widgets/campaign_skeleton.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/donation_type_toggle.dart';
import '../widgets/my_donations_section.dart';

class SadaqahScreen extends StatefulWidget {
  const SadaqahScreen({super.key});

  @override
  State<SadaqahScreen> createState() => _SadaqahScreenState();
}

class _SadaqahScreenState extends State<SadaqahScreen>
    with TickerProviderStateMixin {
  late final SadaqahController _ctrl;
  late final TextEditingController _searchCtrl;
  late final AnimationController _headerAnimCtrl;
  late final Animation<double> _headerFade;
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = SadaqahController.instance;
    _searchCtrl = TextEditingController();

    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerFade = CurvedAnimation(
      parent: _headerAnimCtrl,
      curve: Curves.easeOut,
    );
    _headerAnimCtrl.forward();

    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _headerAnimCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final bg = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: bg,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          // ── Collapsible app bar with header ──────────────────────────
          SliverAppBar(
            expandedHeight: 230.h,
            pinned: true,
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: primary,
                size: 20.sp,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share_rounded, color: primary, size: 22.sp),
                onPressed: () => SharePlus.instance.share(
                  ShareParams(
                    text:
                        'Support amazing Islamic charity campaigns '
                        'on Sadaqah Jariyah! 🤲',
                  ),
                ),
              ),
              Gap(4.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: FadeTransition(
                opacity: _headerFade,
                child: const _SadaqahHeader(),
              ),
            ),
          ),

          // ── Search bar ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SearchBar(
              ctrl: _searchCtrl,
              primary: primary,
              onChanged: _ctrl.setSearchQuery,
            ),
          ),

          // ── Donation type toggle ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: const DonationTypeToggle(),
            ),
          ),

          // ── Tab bar ───────────────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabCtrl,
                indicatorColor: primary,
                labelColor: primary,
                unselectedLabelColor: primary.withValues(alpha: 0.40),
                labelStyle: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12.sp,
                ),
                tabs: const [
                  Tab(text: 'Campaigns'),
                  Tab(text: 'Favorites'),
                  Tab(text: 'My Donations'),
                ],
                indicatorWeight: 3,
              ),
              bg: bg,
            ),
          ),
        ],
        body: RefreshIndicator(
          color: primary,
          onRefresh: _ctrl.refresh,
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _CampaignsTab(ctrl: _ctrl),
              _FavoritesTab(ctrl: _ctrl),
              const _MyDonationsTab(),
            ],
          ),
        ),
      ),

      // ── Prominent Donate Now FAB ──────────────────────────────────────
      floatingActionButton: _DonateNowFab(primary: primary),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _SadaqahHeader extends StatelessWidget {
  const _SadaqahHeader();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            primary.withValues(alpha: 0.75),
            primary.withValues(alpha: 0.55),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle star pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: CustomPaint(painter: _StarPatternPainter()),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Title row
                Row(
                  children: [
                    Container(
                      width: 46.w,
                      height: 46.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(13.r),
                      ),
                      child: Icon(
                        Icons.volunteer_activism_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                    Gap(12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'صدقة جارية',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: 'naskh',
                            fontSize: 20.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Sadaqah Jariyah',
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 13.sp,
                            color: Colors.white.withValues(alpha: 0.80),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Gap(14.h),
                // Quran verse
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        SadaqahMockData.headerArabic,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'naskh',
                          fontSize: 12.sp,
                          color: Colors.white.withValues(alpha: 0.92),
                          height: 1.7,
                        ),
                      ),
                      Gap(5.h),
                      Text(
                        SadaqahMockData.headerTranslation,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 9.sp,
                          color: Colors.white.withValues(alpha: 0.70),
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final Color primary;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.ctrl,
    required this.primary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: primary.withValues(alpha: 0.15)),
        ),
        child: TextField(
          controller: ctrl,
          onChanged: onChanged,
          style: TextStyle(fontFamily: 'kufi', fontSize: 13.sp, color: primary),
          decoration: InputDecoration(
            hintText: 'Search campaigns…',
            hintStyle: TextStyle(
              fontFamily: 'kufi',
              fontSize: 12.sp,
              color: primary.withValues(alpha: 0.40),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: primary.withValues(alpha: 0.50),
              size: 20.sp,
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: ctrl,
              builder: (_, val, __) => val.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        ctrl.clear();
                        onChanged('');
                      },
                      child: Icon(
                        Icons.close_rounded,
                        color: primary.withValues(alpha: 0.50),
                        size: 18.sp,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Campaigns Tab
// ─────────────────────────────────────────────────────────────────────────────
class _CampaignsTab extends StatelessWidget {
  final SadaqahController ctrl;
  const _CampaignsTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = ctrl.loadState.value;

      if (state == SadaqahLoadState.loading) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CategoryBarPadded(),
              Gap(8.h),
              const CampaignSkeleton(),
            ],
          ),
        );
      }

      if (state == SadaqahLoadState.error) {
        return _ErrorView(
          message: ctrl.errorMessage.value,
          onRetry: ctrl.fetchCampaigns,
          primary: Theme.of(context).primaryColor,
        );
      }

      final list = ctrl.campaigns;

      return CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _CategoryBarPadded()),
          SliverToBoxAdapter(child: Gap(4.h)),
          if (list.isEmpty)
            SliverFillRemaining(child: _EmptyCampaigns(ctrl: ctrl))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => CampaignCard(campaign: list[i]),
                childCount: list.length,
              ),
            ),
          SliverToBoxAdapter(child: Gap(80.h)),
        ],
      );
    });
  }
}

class _CategoryBarPadded extends StatelessWidget {
  const _CategoryBarPadded();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: 10.h, bottom: 2.h),
    child: const CategoryFilterBar(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Favorites Tab
// ─────────────────────────────────────────────────────────────────────────────
class _FavoritesTab extends StatelessWidget {
  final SadaqahController ctrl;
  const _FavoritesTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Obx(() {
      final favs = ctrl.favoriteCampaigns;

      if (favs.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 52.sp,
                  color: primary.withValues(alpha: 0.25),
                ),
                Gap(14.h),
                Text(
                  'No favorites yet',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 15.sp,
                    color: primary.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap(8.h),
                Text(
                  'Tap the ♥ on any campaign to save it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    color: primary.withValues(alpha: 0.30),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.only(top: 8.h, bottom: 80.h),
        itemCount: favs.length,
        itemBuilder: (_, i) => CampaignCard(campaign: favs[i]),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My Donations Tab
// ─────────────────────────────────────────────────────────────────────────────
class _MyDonationsTab extends StatelessWidget {
  const _MyDonationsTab();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 12),
          MyDonationsSection(),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Donate Now FAB
// ─────────────────────────────────────────────────────────────────────────────
class _DonateNowFab extends StatelessWidget {
  final Color primary;
  const _DonateNowFab({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: ElevatedButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Choose a campaign below to donate! 🤲',
              style: TextStyle(fontFamily: 'kufi'),
            ),
            backgroundColor: primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 13.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
        icon: Icon(Icons.volunteer_activism_rounded, size: 20.sp),
        label: Text(
          'Donate Now',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error / Empty states
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Color primary;
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 52.sp,
              color: primary.withValues(alpha: 0.30),
            ),
            Gap(14.h),
            Text(
              message.isEmpty ? 'Something went wrong.' : message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13.sp,
                color: primary.withValues(alpha: 0.55),
              ),
            ),
            Gap(18.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(fontFamily: 'kufi', fontSize: 13.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCampaigns extends StatelessWidget {
  final SadaqahController ctrl;
  const _EmptyCampaigns({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 52.sp,
              color: primary.withValues(alpha: 0.25),
            ),
            Gap(14.h),
            Text(
              'No campaigns found',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 14.sp,
                color: primary.withValues(alpha: 0.45),
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(8.h),
            TextButton(
              onPressed: () {
                ctrl.setCategory(null);
                ctrl.setSearchQuery('');
              },
              child: Text(
                'Clear filters',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 13.sp,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SliverPersistentHeaderDelegate for the TabBar
// ─────────────────────────────────────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color bg;
  const _TabBarDelegate(this.tabBar, {required this.bg});

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlaps) =>
      Container(color: bg, child: tabBar);

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Islamic star geometric background painter
// ─────────────────────────────────────────────────────────────────────────────
class _StarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const spacing = 44.0;
    const r = 14.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final center = Offset(x, y);
        for (int i = 0; i < 8; i++) {
          final a1 = i * 3.14159265 * 2 / 8;
          final a2 = a1 + 3.14159265 / 8;
          canvas.drawLine(
            Offset(center.dx + r * _cos(a1), center.dy + r * _sin(a1)),
            Offset(
              center.dx + r * 0.45 * _cos(a2),
              center.dy + r * 0.45 * _sin(a2),
            ),
            paint,
          );
        }
      }
    }
  }

  double _cos(double a) {
    // Taylor approximation — avoids dart:math import
    final x = a % (2 * 3.14159265);
    return 1 - x * x / 2 + x * x * x * x / 24 - x * x * x * x * x * x / 720;
  }

  double _sin(double a) {
    final x = a % (2 * 3.14159265);
    return x - x * x * x / 6 + x * x * x * x * x / 120;
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
