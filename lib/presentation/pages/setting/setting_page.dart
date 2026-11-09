import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:misbah_path/core/utils/constants/extensions/extensions.dart';

import '../../../services/azkar_widget_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: context.theme.colorScheme.tertiary,
      ),
    );
    return Scaffold(
      backgroundColor: context.theme.colorScheme.tertiary,
      appBar: AppBar(
        backgroundColor: context.theme.colorScheme.tertiary,
        leading: CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: Icon(
            CupertinoIcons.back,
            size: 30,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'setting'.tr,
          style: TextStyle(
            fontFamily: 'kufi',
            color: context.theme.hintColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        children: [
          const Gap(32),

          ButtonSetting(
            ontap: () {},
            title: 'Prayer Times',
            iconData: FlutterIslamicIcons.solidPrayingPerson,
          ),
          const Gap(10),
          ButtonSetting(
            ontap: () {},
            title: 'Reminder & Notification',
            iconData: CupertinoIcons.bell_solid,
          ),
          const Gap(10),
          ButtonSetting(
            ontap: () {},
            title: 'Quran',
            iconData: FlutterIslamicIcons.solidQuran,
          ),
          const Gap(10),
          const Gap(10),
          ButtonSetting(
            ontap: () {},
            title: 'Themes',
            iconData: Icons.color_lens,
          ),
          const Gap(10),
          ButtonSetting(
            ontap: () {},
            title: 'About',
            iconData: CupertinoIcons.info,
          ),

          // ── Azkar Home Widget (Android only) ──────────────────────────────
          if (Platform.isAndroid) ...[
            const Gap(10),
            const _AzkarWidgetToggle(),
          ],

          const Gap(24),
        ],
      ),
    );
  }
}

// ── Azkar Widget toggle tile ──────────────────────────────────────────────────

class _AzkarWidgetToggle extends StatelessWidget {
  const _AzkarWidgetToggle();

  @override
  Widget build(BuildContext context) {
    final svc = AzkarWidgetService.instance;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: .2),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Expanded(
              flex: 2,
              child: Icon(
                FlutterIslamicIcons.solidMosque,
                color: Get.theme.colorScheme.primary,
                size: 30,
              ),
            ),
            // Vertical divider
            context.vDivider(height: 20.0),
            // Text block
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Azkar Home Widget',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 15,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    'Show a different Azkar every hour on your home screen.',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 11,
                      color: Theme.of(context).hintColor.withValues(alpha: .65),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Toggle switch
            Obx(() {
              if (svc.isLoading.value) {
                return const SizedBox(
                  width: 36,
                  height: 20,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return CupertinoSwitch(
                value: svc.isEnabled.value,
                activeTrackColor: Get.theme.colorScheme.primary,
                onChanged: (value) async {
                  try {
                    await svc.setEnabled(value);
                  } catch (_) {
                    // Error is logged inside the service; show a snackbar.
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Could not enable Azkar widget.'
                                : 'Could not disable Azkar widget.',
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Existing ButtonSetting widget (unchanged) ─────────────────────────────────

class ButtonSetting extends StatelessWidget {
  final Function ontap;
  final bool icons;
  final String title;
  final IconData iconData;
  const ButtonSetting({
    super.key,
    required this.ontap,
    required this.title,
    this.icons = true,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: .2),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: InkWell(
          child: SizedBox(
            height: 45,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Icon(
                    iconData,
                    color: Get.theme.colorScheme.primary,
                    size: 30,
                  ),
                ),
                context.vDivider(height: 20.0),
                Expanded(
                  flex: 8,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 16,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 1,
                  child: Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Theme.of(context).hintColor,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
