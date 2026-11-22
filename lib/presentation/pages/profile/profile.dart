// ─────────────────────────────────────────────────────────────────────────────
// profile.dart — Premium Islamic Profile
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../sadaqah/screens/sadaqah_screen.dart';
import '../tasbih/widgets/geometric_pattern_painter.dart';
import '../premium/premium_access_guard.dart';
import '../quran_contest/quran_contest_screen.dart';
import 'controller/profile_controller.dart';
import 'widgets/islamic_bg_painter.dart';
import 'widgets/profile_header.dart' show ProfileHeader;
import 'widgets/settings_sections.dart';

// ── File-local colour tokens ───────────────────────────────────────────────────
const _kGold      = Color(0xffCDAD80);
const _kGoldDeep  = Color(0xffA8873A);
const _kGoldLight = Color(0xffE8C97A);
const _kEmerald   = Color(0xff10B981);
const _kRed       = Color(0xffE53935);

// ─────────────────────────────────────────────────────────────────────────────

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  late final ProfileController _ctrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(ProfileController(), permanent: false);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: cs.secondary,
      body: Stack(
        children: [
          // ── Full-page subtle geometric background ─────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricPatternPainter(
                color: isDark ? _kGold : cs.primary,
                opacity: isDark ? 0.035 : 0.040,
              ),
            ),
          ),

          // ── Main scrollable content ────────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                // ── Status-bar safe space ──────────────────────────────
                SizedBox(height: MediaQuery.of(context).padding.top + 12.h),

                // ── 1. Profile Header (minimal, centred) ──────────────
                const ProfileHeader(),
                SizedBox(height: 24.h),

                // ── 2. My Islamic Journey ──────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: const _IslamicJourneySection(),
                ),
                SizedBox(height: 24.h),

                // ── 3. Islamic Preferences ─────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: const IslamicPreferencesSection(),
                ),
                SizedBox(height: 24.h),

                // ── 4. Account & Security ──────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: const AccountSettingsSection(),
                ),
                SizedBox(height: 24.h),

                // ── 5. Help & Support ──────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: const SupportSection(),
                ),
                SizedBox(height: 24.h),

                // ── Version label ──────────────────────────────────────
                const _VersionLabel(),
                SizedBox(height: 16.h),

                // ── Logout ─────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: const LogoutSection(),
                ),
                SizedBox(height: 52.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section — My Islamic Journey  (Live Contest cards)
// ─────────────────────────────────────────────────────────────────────────────

class _IslamicJourneySection extends StatelessWidget {
  const _IslamicJourneySection();

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final cs        = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(left: 2.w, bottom: 14.h),
          child: Row(
            children: [
              Container(
                width: 3.5.w,
                height: 28.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_kGold, Color(0xffCD9974)],
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(11.r),
                  border: Border.all(
                    color: _kGold.withValues(alpha: 0.22),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    color: _kGold, size: 18.r),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'My Islamic Journey'.tr,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: 0.1,
                    ),
                  ),
                 /*  Text(
                    'مسيرتي الإسلامية',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'naskh',
                      fontSize: 11.sp,
                      color: _kGold.withValues(alpha: isDark ? 0.70 : 0.60),
                      height: 1.2,
                    ),
                  ), */
                ],
              ),
              const Spacer(),
              // "LIVE" pill
              _LivePill(),
            ],
          ),
        ),

        // ── Two live-contest cards side by side ────────────────────────
        Row(
          children: [
            Expanded(
              child: _LiveContestCard(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary,
                    Color.lerp(cs.primary, const Color(0xff1A2744), 0.55)!,
                  ],
                ),
                accentColor: _kGold,
                icon: Icons.mosque_rounded,
                arabicLabel: 'صدقة جارية',
                title: 'Sadaqah\nJariyah',
                participants: '2.4k',
                progress: 0.68,
                progressLabel: '68% funded',
                timeLabel: 'Ongoing',
                onTap: () => PremiumAccessGuard.check(
                  context,
                  feature: PremiumFeature.sadaqahJariyah,
                  onAllowed: () => Get.to(
                    () => const SadaqahScreen(),
                    transition: Transition.downToUp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _LiveContestCard(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff8B6914), Color(0xff5C4008)],
                ),
                accentColor: _kGoldLight,
                icon: Icons.menu_book_rounded,
                arabicLabel: 'مسابقة القرآن',
                title: "Qur'an\nContest",
                participants: '1.1k',
                progress: 0.42,
                progressLabel: 'Round 3 / 7',
                timeLabel: '3d left',
                onTap: () => PremiumAccessGuard.check(
                  context,
                  feature: PremiumFeature.quranContest,
                  onAllowed: () => Get.to(
                    () => const QuranContestScreen(),
                    transition: Transition.downToUp,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 14.h),

        // ── Important Notes banner ─────────────────────────────────────
        _ImportantNotesBanner(),
      ],
    );
  }
}

// ── LIVE pill ──────────────────────────────────────────────────────────────────

class _LivePill extends StatefulWidget {
  @override
  State<_LivePill> createState() => _LivePillState();
}

class _LivePillState extends State<_LivePill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xffE53935).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xffE53935).withValues(alpha: 0.40),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 7.r,
              height: 7.r,
              decoration: const BoxDecoration(
                color: Color(0xffE53935),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            'LIVE',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xffE53935),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Live Contest Card ──────────────────────────────────────────────────────────

class _LiveContestCard extends StatelessWidget {
  final LinearGradient gradient;
  final Color accentColor;
  final IconData icon;
  final String arabicLabel;
  final String title;
  final String participants;
  final double progress;      // 0.0 → 1.0
  final String progressLabel;
  final String timeLabel;
  final VoidCallback onTap;

  const _LiveContestCard({
    required this.gradient,
    required this.accentColor,
    required this.icon,
    required this.arabicLabel,
    required this.title,
    required this.participants,
    required this.progress,
    required this.progressLabel,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        splashColor: accentColor.withValues(alpha: 0.12),
        highlightColor: accentColor.withValues(alpha: 0.06),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.30),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.38),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22.r),
            child: Stack(
              children: [
                // ── Geometric overlay ──────────────────────────────
                Positioned.fill(
                  child: CustomPaint(
                    painter: IslamicBgPainter(
                      starColor: accentColor,
                      ringColor: accentColor,
                      starOpacity: 0.08,
                      ringOpacity: 0.03,
                      tileSize: 44,
                    ),
                  ),
                ),

                // ── Card content ───────────────────────────────────
                Padding(
                  padding: EdgeInsets.all(14.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: icon + live dot
                      Row(
                        children: [
                          Container(
                            width: 38.r,
                            height: 38.r,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Icon(icon,
                                color: accentColor, size: 20.r),
                          ),
                          const Spacer(),
                          _PulsingDot(color: accentColor),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Arabic label
                      Text(
                        arabicLabel,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'naskh',
                          fontSize: 11.sp,
                          color: accentColor.withValues(alpha: 0.85),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // English title
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Progress bar
                      _ContestProgressBar(
                        value: progress,
                        color: accentColor,
                      ),
                      SizedBox(height: 6.h),

                      // Bottom row: progress label + time
                      Row(
                        children: [
                          Text(
                            progressLabel,
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 9.5.sp,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 10.r,
                                color: accentColor.withValues(alpha: 0.80),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                timeLabel,
                                style: TextStyle(
                                  fontFamily: 'kufi',
                                  fontSize: 9.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      // Participants row
                      Row(
                        children: [
                          Icon(
                            Icons.people_rounded,
                            size: 11.r,
                            color: Colors.white.withValues(alpha: 0.50),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '$participants participants',
                            style: TextStyle(
                              fontFamily: 'kufi',
                              fontSize: 9.5.sp,
                              color: Colors.white.withValues(alpha: 0.50),
                            ),
                          ),
                        ],
                      ),
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

// ── Pulsing live dot ───────────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8.r,
        height: 8.r,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.60),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Contest progress bar ───────────────────────────────────────────────────────

class _ContestProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  const _ContestProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 5.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withValues(alpha: 0.70),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.55),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Important Notes banner ─────────────────────────────────────────────────────

class _ImportantNotesBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final notes = [
      _NoteEntry(
        icon: Icons.volunteer_activism_rounded,
        title: 'Waqf Contribution',
        // arabicTitle: 'مساهمة الوقف',
        subtitle: 'Support Islamic endowments & charitable causes',
        color: _kRed,
        onTap: () {},
      ),
      _NoteEntry(
        icon: Icons.trending_up_rounded,
        title: 'Halal Finance Tips',
        // arabicTitle: 'نصائح التمويل الحلال',
        subtitle: 'Interest-free guidance for ethical living',
        color: _kEmerald,
        onTap: () => Get.toNamed('/halal-finance'),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: _kGold.withValues(alpha: isDark ? 0.18 : 0.14),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _kGold.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Banner header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _kGold.withValues(alpha: isDark ? 0.18 : 0.12),
                  _kGoldDeep.withValues(alpha: isDark ? 0.08 : 0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Row(
              children: [
                Icon(Icons.star_rounded, color: _kGold, size: 16.r),
                SizedBox(width: 8.w),
                Text(
                  'Important Notes',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _kGold,
                  ),
                ),
                const Spacer(),
                Text(
                  'ملاحظات مهمة',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 12.sp,
                    color: _kGold.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),

          // Note tiles
          ...notes.asMap().entries.map((e) {
            final isLast = e.key == notes.length - 1;
            return Column(
              children: [
                _NoteTile(entry: e.value),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 60.w,
                    endIndent: 16.w,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.055)
                        : Colors.black.withValues(alpha: 0.055),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _NoteEntry {
  final IconData icon;
  final String title;
  // final String arabicTitle;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _NoteEntry({
    required this.icon,
    required this.title,
    // required this.arabicTitle,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _NoteTile extends StatelessWidget {
  final _NoteEntry entry;
  const _NoteTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor  = (isDark ? Colors.white : Colors.black)
        .withValues(alpha: 0.40);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: entry.onTap,
        borderRadius: BorderRadius.circular(20.r),
        splashColor: entry.color.withValues(alpha: 0.07),
        highlightColor: entry.color.withValues(alpha: 0.03),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
          child: Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: entry.color.withValues(alpha: isDark ? 0.17 : 0.09),
                  borderRadius: BorderRadius.circular(13.r),
                  border: Border.all(
                    color: entry.color.withValues(alpha: isDark ? 0.22 : 0.14),
                  ),
                ),
                child: Icon(entry.icon, color: entry.color, size: 20.r),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      entry.subtitle,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 11.sp,
                        color: subColor,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: entry.color.withValues(alpha: 0.45),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '✦',
          style: TextStyle(
            color: _kGold.withValues(alpha: 0.32),
            fontSize: 8.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          'Mishab Path  v1.0.0',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 11.sp,
            color: Theme.of(context).hintColor.withValues(alpha: 0.26),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          '✦',
          style: TextStyle(
            color: _kGold.withValues(alpha: 0.32),
            fontSize: 8.sp,
          ),
        ),
      ],
    );
  }
}
