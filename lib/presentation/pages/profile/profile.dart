// ─────────────────────────────────────────────────────────────────────────────
// profile.dart — Redesigned Islamic Profile Dashboard
// Clean Architecture · Material 3 · Dark/Light · Emerald & Gold palette
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../sadaqah/screens/sadaqah_screen.dart';
import '../tasbih/widgets/geometric_pattern_painter.dart';
import 'controller/profile_controller.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_sections.dart';

// ── Colour tokens (shared across widgets in this file) ────────────────────────
const _kGold = Color(0xffCDAD80);
const _kGoldDeep = Color(0xffCD9974);
const _kEmerald = Color(0xff10B981);
const _kRed = Color(0xffE53935);

// ─────────────────────────────────────────────────────────────────────────────
// Root widget
// ─────────────────────────────────────────────────────────────────────────────

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  late final ProfileController _ctrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(ProfileController(), permanent: false);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: cs.secondary,
      body: Stack(
        children: [
          // ── 1. Islamic geometric pattern ──────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricPatternPainter(
                color: isDark ? _kGold : cs.primary,
                opacity: isDark ? 0.040 : 0.048,
              ),
            ),
          ),
          // ── 2. Top radial glow ────────────────────────────────────────
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Container(
              height: 260.h,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.88,
                  colors: [
                    cs.primary.withValues(alpha: isDark ? 0.14 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── 3. Main scroll ────────────────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Hero app bar ─────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 190.h,
                  collapsedHeight: 64.h,
                  pinned: true,
                  floating: false,
                  stretch: true,
                  elevation: 0,
                  backgroundColor: cs.primary,

                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    // ── Pinned compact avatar + name shown on collapse ───
                    titlePadding: EdgeInsets.only(left: 56.w, bottom: 12.h),
                    title: Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Small glowing avatar ring
                          SizedBox(
                            width: 34.r,
                            height: 34.r,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Gold sweep ring
                                Container(
                                  width: 34.r,
                                  height: 34.r,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: SweepGradient(
                                      colors: [
                                        kGold,
                                        kGoldLight,
                                        kGold,
                                        kGoldDeep,
                                        kGold,
                                      ],
                                    ),
                                  ),
                                ),
                                // Avatar image
                                Container(
                                  width: 28.r,
                                  height: 28.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: kGold.withValues(alpha: 0.55),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 14.r,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.10,
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/account.png',
                                        fit: BoxFit.cover,
                                        width: 28.r,
                                        height: 28.r,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.person_rounded,
                                          size: 14.r,
                                          color: kGold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          // Name + greeting
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _ctrl.userName.value,
                                style: TextStyle(
                                  fontFamily: 'kufi',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'السَّلامُ عَلَيْكُم',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'naskh',
                                  fontSize: 10.sp,
                                  color: kGold.withValues(alpha: 0.85),
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    background: const ProfileHeader(),
                  ),
                ),

                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(height: 14.h),

                      // // ── Worship stats bar ───────────────────────────
                      // _WorshipStatsBar(ctrl: _ctrl),
                      // SizedBox(height: 18.h),

                      // ── Daily verse ──────────────────────────────────
                      const _DailyVerseBanner(),
                      SizedBox(height: 18.h),

                      // ── Islamic Wallet ───────────────────────────────
                      const _SectionLabel(
                        icon: Icons.account_balance_wallet_rounded,
                        title: 'Islamic Wallet',
                        arabicTitle: 'المحفظة الإسلامية',
                        color: _kGold,
                      ),
                      SizedBox(height: 8.h),
                      const _IslamicWalletSection(),
                      SizedBox(height: 20.h),

                      // ── Account Settings ─────────────────────────────
                      const AccountSettingsSection(),
                      SizedBox(height: 20.h),

                      // ── Islamic Preferences ──────────────────────────
                      const IslamicPreferencesSection(),
                      SizedBox(height: 20.h),

                      // ── Support ──────────────────────────────────────
                      const SupportSection(),
                      SizedBox(height: 24.h),

                      // ── Version ──────────────────────────────────────
                      const _VersionLabel(),
                      SizedBox(height: 14.h),

                      // ── Logout ───────────────────────────────────────
                      const LogoutSection(),
                      SizedBox(height: 48.h),
                    ]),
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

//* / ─────────────────────────────────────────────────────────────────────────────
// Daily Verse Banner

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.18
                    : 0.10,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 16.r),
          ),
          SizedBox(height: 5.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 9.5.sp,
              color: Theme.of(context).hintColor.withValues(alpha: 0.45),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Verse Banner
// ─────────────────────────────────────────────────────────────────────────────

class _DailyVerseBanner extends StatelessWidget {
  const _DailyVerseBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withValues(alpha: isDark ? 0.18 : 0.07),
            cs.primary.withValues(alpha: isDark ? 0.08 : 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _kGold.withValues(alpha: 0.22), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _kGold.withValues(alpha: isDark ? 0.10 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gold quote icon
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kGoldDeep, _kGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13.r),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withValues(alpha: 0.30),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.format_quote_rounded,
              color: Colors.white,
              size: 19.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 15.sp,
                    color: _kGold,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '"Indeed, Allah is with the patient." — Al-Baqarah 2:153',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10.5.sp,
                    color: theme.hintColor.withValues(alpha: 0.50),
                    height: 1.5,
                    fontStyle: FontStyle.italic,
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
// Section Label — reusable header above each group
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? arabicTitle;
  final Color color;

  const _SectionLabel({
    required this.icon,
    required this.title,
    this.arabicTitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Row(
        children: [
          Container(
            width: 3.5.w,
            height: 26.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_kGold, color],
              ),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(9.r),
              border: Border.all(color: color.withValues(alpha: 0.20)),
            ),
            child: Icon(icon, color: color, size: 15.r),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: theme.hintColor,
                ),
              ),
              if (arabicTitle != null)
                Text(
                  arabicTitle!,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 11.sp,
                    color: _kGold.withValues(alpha: 0.65),
                    height: 1.2,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Islamic Wallet Section — 4 feature tiles in a card
// ─────────────────────────────────────────────────────────────────────────────

class _IslamicWalletSection extends StatelessWidget {
  const _IslamicWalletSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tiles = [
      _WalletEntry(
        icon: Icons.mosque_rounded,
        color: cs.primary,
        title: 'Sadaqah Jariyah',
        subtitle: 'Track ongoing charity',
        badge: 'Active',
        onTap: () => Get.to(
          () => const SadaqahScreen(),
          transition: Transition.downToUp,
        ),
      ),
      _WalletEntry(
        icon: Icons.calculate_rounded,
        color: _kGold,
        title: 'Zakat Calculator',
        subtitle: 'Calculate annual Zakat',
        onTap: () => Get.toNamed('/zakat'),
      ),
      _WalletEntry(
        icon: Icons.favorite_rounded,
        color: _kRed,
        title: 'Waqf Contributions',
        subtitle: 'Islamic endowment',
        onTap: () {},
        // onTap: () => Get.to(
        /*   () => const SadaqahScreen(),
          transition: Transition.downToUp, */
        // ),
      ),
      _WalletEntry(
        icon: Icons.auto_awesome_rounded,
        color: _kEmerald,
        title: 'Halal Finance Tips',
        subtitle: 'Interest-free guidance',
        onTap: () => Get.toNamed('/halal-finance'),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.07 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          children: tiles.asMap().entries.map((e) {
            final isLast = e.key == tiles.length - 1;
            return Column(
              children: [
                _WalletTile(entry: e.value),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 60.w,
                    endIndent: 16.w,
                    color: cs.primary.withValues(alpha: 0.07),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _WalletEntry {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;
  const _WalletEntry({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.onTap,
  });
}

class _WalletTile extends StatelessWidget {
  final _WalletEntry entry;
  const _WalletTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: entry.onTap,
        splashColor: entry.color.withValues(alpha: 0.08),
        highlightColor: entry.color.withValues(alpha: 0.04),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
          child: Row(
            children: [
              // Icon badge
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: entry.color.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(13.r),
                  border: Border.all(
                    color: entry.color.withValues(alpha: isDark ? 0.22 : 0.14),
                  ),
                ),
                child: Icon(entry.icon, color: entry.color, size: 20.r),
              ),
              SizedBox(width: 14.w),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.hintColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      entry.subtitle,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 11.sp,
                        color: theme.hintColor.withValues(alpha: 0.48),
                      ),
                    ),
                  ],
                ),
              ),
              // Badge or chevron
              if (entry.badge != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _kGold.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: _kGold.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    entry.badge!,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: _kGold,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.hintColor.withValues(alpha: 0.22),
                  size: 20.r,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Version label
// ─────────────────────────────────────────────────────────────────────────────

class _VersionLabel extends StatelessWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '✦',
          style: TextStyle(
            color: _kGold.withValues(alpha: 0.35),
            fontSize: 8.sp,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          'Mishab Path  v1.0.0',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 11.sp,
            color: theme.hintColor.withValues(alpha: 0.28),
            letterSpacing: 0.4,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '✦',
          style: TextStyle(
            color: _kGold.withValues(alpha: 0.35),
            fontSize: 8.sp,
          ),
        ),
      ],
    );
  }
}
