import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:misbah_path/helpers/gps_location_helper.dart';
import 'package:provider/provider.dart';

import '../../../../apps/routes/route_name.dart';
import '../../../../provider/adhanProvider.dart';
import '../../../../provider/dependencies/AdhanDependencyProvider.dart';
import '../../../../provider/dependencies/tabProvider.dart';
import '../../../../provider/locationProvider.dart';
import '../../../../widgets/draggable_home.dart';
import '../model/collection.dart';
import '../widgets/daily_zeker.dart';
import '../widgets/hijri_date.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final locationState = context.watch<LocationProvider>().locationState;
    final adhanDependency = context.watch<AdhanDependencyProvider>();

    final adhanProvider = locationState is LocationAvailable
        ? AdhanProvider(adhanDependency, locationState.locationInfo)
        : null;

    final currentAdhan = adhanProvider?.currentAdhan;
    final nextAdhan = adhanProvider?.nextAdhan;

    return DraggableHome(
      title: currentAdhan != null
          ? Text(
              currentAdhan.title,
              style: TextStyle(
                fontFamily: 'kufi',
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : const SizedBox(),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_none_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
      headerWidget: _HeaderWidget(),
      headerBottomBar: const SizedBox(height: 8),
      body: [_buildBody(context)],
      fullyStretchable: true,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBarColor: Theme.of(context).colorScheme.secondary,
      locationState: locationState,
      adhanDependencyProvider: adhanDependency,
      currentAdhan: currentAdhan,
      nextAdhan: nextAdhan,
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final bgColor = theme.colorScheme.secondary;

    return Container(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hijri Date Card ──────────────────────────────────────
            const _SectionCard(
              child: Padding(padding: EdgeInsets.all(5.0), child: HijriDate()),
            ),
            // const Gap(16),
            // _SectionLabel(label: 'quickAccess'.tr, primaryColor: primaryColor),
            // const Gap(10),
            _FeatureGrid(context: context),
            const Gap(10),
            // ── Quran Audio Banner ────────────────────────────────────
            // _SectionLabel(label: 'quranAudio'.tr, primaryColor: primaryColor),
            const Gap(10),
            _QuranAudioBanner(),
            const Gap(10),
            // ── Daily Zeker ───────────────────────────────────────────
            // _SectionLabel(label: 'dailyZeker'.tr, primaryColor: primaryColor),
            const Gap(10),
            DailyZeker(),
            const Gap(24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header widget with mosque image + gradient overlay
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.asset('assets/images/quranb.jpg', fit: BoxFit.cover),
        // Rich gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.92),
                Theme.of(
                  context,
                ).colorScheme.inverseSurface.withValues(alpha: 0.82),
                Theme.of(context).primaryColor.withValues(alpha: 0.70),
              ],
            ),
          ),
        ),
        // Decorative geometric pattern (subtle)
        Positioned.fill(
          child: Opacity(opacity: 0.06, child: _IslamicPatternPainter()),
        ),
      ],
    );
  }
}

// Simple repeating geometric widget (pure Flutter, no external asset needed)
class _IslamicPatternPainter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GeometricPatternPainter());
  }
}

class _GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const spacing = 48.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final center = Offset(x, y);
        const r = 16.0;
        // Draw 8-point star
        for (int i = 0; i < 8; i++) {
          final angle = (i * 3.14159 * 2) / 8;
          final innerAngle = angle + (3.14159 / 8);
          canvas.drawLine(
            Offset(center.dx + r * _cos(angle), center.dy + r * _sin(angle)),
            Offset(
              center.dx + (r * 0.45) * _cos(innerAngle),
              center.dy + (r * 0.45) * _sin(innerAngle),
            ),
            paint,
          );
        }
      }
    }
  }

  double _cos(double a) =>
      (a * 180 / 3.14159) % 360 == 90 || (a * 180 / 3.14159) % 360 == 270
      ? 0
      : _approxCos(a);
  double _sin(double a) => _approxSin(a);

  double _approxCos(double a) {
    // Simple Taylor approximation
    double x = a % (2 * 3.14159265);
    return 1 -
        (x * x) / 2 +
        (x * x * x * x) / 24 -
        (x * x * x * x * x * x) / 720;
  }

  double _approxSin(double a) {
    double x = a % (2 * 3.14159265);
    return x -
        (x * x * x) / 6 +
        (x * x * x * x * x) / 120 -
        (x * x * x * x * x * x * x) / 5040;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final Color primaryColor;

  const _SectionLabel({required this.label, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Gap(8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wrapper card with subtle shadow + rounded corners
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature grid — 3-column tile layout
// ─────────────────────────────────────────────────────────────────────────────
class _FeatureGrid extends StatelessWidget {
  final BuildContext context;
  const _FeatureGrid({required this.context});

  @override
  Widget build(BuildContext ctx) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: collections.length,
      itemBuilder: (_, index) => _FeatureTile(
        collection: collections[index],
        index: index,
        onTap: () {
          if (collections[index].routeName == RoutesName.prayerTime) {
            context.read<TabProvider>().onChangingTab(1);
          } else {
            Navigator.pushNamed(context, collections[index].routeName);
          }
        },
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final Collection collection;
  final int index;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.collection,
    required this.index,
    required this.onTap,
  });

  // Accent colors cycling per tile for a vibrant Islamic palette
  static const List<Color> _tileAccents = [
    Color(0xff3D5A80), // deep blue
    Color(0xff5C7A5B), // forest green
    Color(0xff7B5E3C), // warm brown
    Color(0xff6B4C7A), // royal purple
    Color(0xff2E7D7D), // teal
    Color(0xff8B4513), // saddle brown
    Color(0xff1B5E6B), // deep teal
    Color(0xff5A4A7A), // indigo
    Color(0xff4A6741), // sage green
    Color(0xff7A3C3C), // burgundy
    Color(0xff3C5C78), // slate blue
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _tileAccents[index % _tileAccents.length];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark
              ? accent.withValues(alpha: 0.18)
              : accent.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.22), width: 1),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/images/collections/${collection.svgName}.png',
                fit: BoxFit.contain,
                // color: accent,
              ),
            ),
            const Gap(6),
            // Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                collection.title.tr,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: accent,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quran Audio Banner
// ─────────────────────────────────────────────────────────────────────────────
class _QuranAudioBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final surface = Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, RoutesName.audio),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [primary, surface],
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Gap(16),
            // Quran icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(
                'assets/svg/quran_au_ic.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const Gap(14),
            // Title + subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'quranAudio'.tr,
                    style: const TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    'listenToQuran'.tr.isEmpty
                        ? 'Listen to the Holy Quran'
                        : 'listenToQuran'.tr,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.80),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow
            Container(
              margin: const EdgeInsets.only(right: 16),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
