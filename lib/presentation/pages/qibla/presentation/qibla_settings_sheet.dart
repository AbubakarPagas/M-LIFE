// ── Qibla Settings Sheet ─────────────────────────────────────────────────────
// Islamic styling: gold dividers, surfaceContainer bg, kufi/naskh typography

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../adhan/widgets/adhan_theme.dart';
import '../controllers/qibla_controller.dart';
import '../models/qibla_settings_model.dart';

class QiblaSettingsSheet extends StatelessWidget {
  const QiblaSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QiblaController>();
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      minChildSize: 0.40,
      maxChildSize: 0.90,
      builder: (ctx, scrollCtrl) {
        return SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Obx(() {
            final s = ctrl.settings.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: kAdhanGold.withValues(alpha: 0.40),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                // Title with Arabic calligraphy
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kAdhanGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: kAdhanGold.withValues(alpha: 0.30),
                        ),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: kAdhanGoldDeep,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'إعدادات القبلة',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: 'naskh',
                            fontSize: 16,
                            color: kAdhanGold,
                          ),
                        ),
                        Text(
                          'qiblaSettings'.tr.isEmpty
                              ? 'Qibla Settings'
                              : 'qiblaSettings'.tr,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 22),
                _GoldDivider(),
                const SizedBox(height: 20),

                // North type
                _SectionLabel(
                  label: 'northType'.tr.isEmpty ? 'North Type' : 'northType'.tr,
                  cs: cs,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _SelectChip(
                        label: 'magneticNorth'.tr.isEmpty
                            ? 'Magnetic North'
                            : 'magneticNorth'.tr,
                        selected: s.northType == NorthType.magnetic,
                        cs: cs,
                        onTap: () => ctrl.updateSettings(
                          s.copyWith(northType: NorthType.magnetic),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SelectChip(
                        label: 'trueNorth'.tr.isEmpty
                            ? 'True North'
                            : 'trueNorth'.tr,
                        selected: s.northType == NorthType.trueNorth,
                        cs: cs,
                        onTap: () => ctrl.updateSettings(
                          s.copyWith(northType: NorthType.trueNorth),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _GoldDivider(),
                const SizedBox(height: 16),

                // Toggles
                _Toggle(
                  icon: Icons.vibration_rounded,
                  labelKey: 'vibration',
                  fallback: 'Vibration',
                  subtitleKey: 'vibrateWhenAligned',
                  subtitleFallback: 'Vibrate when facing Qibla',
                  value: s.vibrationEnabled,
                  cs: cs,
                  onChanged: (v) =>
                      ctrl.updateSettings(s.copyWith(vibrationEnabled: v)),
                ),
                _Toggle(
                  icon: Icons.volume_up_rounded,
                  labelKey: 'sound',
                  fallback: 'Sound',
                  subtitleKey: 'soundWhenAligned',
                  subtitleFallback: 'Play sound when aligned',
                  value: s.soundEnabled,
                  cs: cs,
                  onChanged: (v) =>
                      ctrl.updateSettings(s.copyWith(soundEnabled: v)),
                ),
                _Toggle(
                  icon: Icons.refresh_rounded,
                  labelKey: 'autoRefresh',
                  fallback: 'Auto Refresh',
                  subtitleKey: 'autoRefreshLocation',
                  subtitleFallback: 'Auto refresh location',
                  value: s.autoRefresh,
                  cs: cs,
                  onChanged: (v) =>
                      ctrl.updateSettings(s.copyWith(autoRefresh: v)),
                ),

                const SizedBox(height: 16),
                _GoldDivider(),
                const SizedBox(height: 16),

                // Sensitivity
                _SectionLabel(
                  label: 'compassSensitivity'.tr.isEmpty
                      ? 'Compass Sensitivity'
                      : 'compassSensitivity'.tr,
                  cs: cs,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.speed_rounded,
                      size: 16,
                      color: kAdhanGold,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: kAdhanGold,
                          inactiveTrackColor: kAdhanGold.withValues(
                            alpha: 0.20,
                          ),
                          thumbColor: kAdhanGoldDeep,
                          overlayColor: kAdhanGold.withValues(alpha: 0.15),
                        ),
                        child: Slider(
                          value: s.compassSensitivity,
                          min: 0.1,
                          max: 1.0,
                          divisions: 9,
                          onChanged: (v) => ctrl.updateSettings(
                            s.copyWith(compassSensitivity: v),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: kAdhanGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: kAdhanGold.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        '${(s.compassSensitivity * 100).round()}%',
                        style: const TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: kAdhanGoldDeep,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GoldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  kAdhanGold.withValues(alpha: 0.40),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: kAdhanGold,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kAdhanGold.withValues(alpha: 0.40),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _SectionLabel({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'kufi',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: cs.primary,
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ColorScheme cs;
  final VoidCallback onTap;
  const _SelectChip({
    required this.label,
    required this.selected,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? kAdhanGold.withValues(alpha: 0.15)
              : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? kAdhanGold : cs.primary.withValues(alpha: 0.15),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? kAdhanGoldDeep : cs.primary,
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final IconData icon;
  final String labelKey;
  final String fallback;
  final String subtitleKey;
  final String subtitleFallback;
  final bool value;
  final ColorScheme cs;
  final ValueChanged<bool> onChanged;

  const _Toggle({
    required this.icon,
    required this.labelKey,
    required this.fallback,
    required this.subtitleKey,
    required this.subtitleFallback,
    required this.value,
    required this.cs,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: kAdhanGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kAdhanGold.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, size: 17, color: kAdhanGoldDeep),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labelKey.tr.isEmpty ? fallback : labelKey.tr,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
                Text(
                  subtitleKey.tr.isEmpty ? subtitleFallback : subtitleKey.tr,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 10,
                    color: cs.primary.withValues(alpha: 0.50),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: kAdhanGoldDeep,
            activeTrackColor: kAdhanGold.withValues(alpha: 0.35),
            inactiveThumbColor: cs.primary.withValues(alpha: 0.30),
            inactiveTrackColor: cs.primary.withValues(alpha: 0.10),
          ),
        ],
      ),
    );
  }
}
