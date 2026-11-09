// ── Facing Qibla Banner ──────────────────────────────────────────────────────
// Animated status banner — Islamic gold styling

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../adhan/widgets/adhan_theme.dart';
import '../controllers/qibla_controller.dart';

class FacingQiblaBanner extends StatefulWidget {
  const FacingQiblaBanner({super.key});

  @override
  State<FacingQiblaBanner> createState() => _FacingQiblaBannerState();
}

class _FacingQiblaBannerState extends State<FacingQiblaBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  bool _wasAligned = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QiblaController>();

    return Obx(() {
      final aligned = ctrl.isFacingQibla.value;

      if (aligned && !_wasAligned) {
        _wasAligned = true;
        _ctrl.forward();
      } else if (!aligned && _wasAligned) {
        _wasAligned = false;
        _ctrl.reverse();
      }

      return FadeTransition(
        opacity: _fade,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: aligned
              ? const _AlignedBanner(key: ValueKey('aligned'))
              : const _NotAlignedBanner(key: ValueKey('not_aligned')),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AlignedBanner extends StatelessWidget {
  const _AlignedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kAdhanGoldLight.withValues(alpha: 0.20),
            kAdhanGold.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: kAdhanGold.withValues(alpha: 0.50),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: kAdhanGold.withValues(alpha: 0.20),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kAdhanGold.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: kAdhanGoldDeep,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'facingQibla'.tr.isEmpty
                ? 'You are facing the Qibla'
                : 'facingQibla'.tr,
            style: const TextStyle(
              fontFamily: 'kufi',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kAdhanGoldDeep,
            ),
          ),
          const SizedBox(width: 6),
          const Text('🕋', style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NotAlignedBanner extends StatelessWidget {
  const _NotAlignedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QiblaController>();
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: kAdhanGold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.explore_rounded,
              color: kAdhanGold,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Obx(() {
            final bearing = ctrl.qiblaResult.value?.bearing.round() ?? 0;
            return Text(
              'rotateToQibla'.tr.isEmpty
                  ? 'Rotate to Qibla ($bearing°)'
                  : 'rotateToQibla'.tr,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 12,
                color: cs.primary.withValues(alpha: 0.70),
              ),
            );
          }),
        ],
      ),
    );
  }
}
