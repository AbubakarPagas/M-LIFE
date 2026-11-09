import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../presentation/pages/adhkar/widgets/setting/azkar_setting.dart';
import '../services/notifications_manager.dart';
import '../utils/constants/extensions/alignment_rotated_extension.dart';
import '../utils/constants/extensions/bottom_sheet_extension.dart';
import '../utils/constants/extensions/extensions.dart';
import '../utils/constants/svg_constants.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool isTitled;
  final bool isFontSize;
  final Widget searchButton;
  final String title;
  final Color? color;
  final bool isNotifi;
  final bool isBooks;
  final bool azkar;
  final PreferredSizeWidget? bottom;

  const AppBarWidget({
    super.key,
    required this.isTitled,
    required this.title,
    required this.isFontSize,
    required this.searchButton,
    this.color,
    required this.isNotifi,
    required this.isBooks,
    this.azkar = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: color ?? cs.primaryContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,

      // ── Back / notification leading ──────────────────────────────────────
      leading: _AppBarLeading(
        onTap: () {
          if (isNotifi) {
          /*   NotificationManager().updateBookProgress(
              title,
              isBooks
                  ? 'notifyBooksBody'.trParams({'bookName': title})
                  : 'notifyAdhkarBody'.trParams({'adhkarType': title}),
              0,
            ); */
          }
          Get.back();
        },
      ),

      // ── Title badge ──────────────────────────────────────────────────────
      title: isTitled ? _AppBarTitle(title: title) : const SizedBox.shrink(),

      // ── Actions ──────────────────────────────────────────────────────────
      actions: [
        if (azkar)
          // Padding(
          //   padding: const EdgeInsets.only(right: 12),
          //   child: _AppBarIconBtn(
          //     icon: SvgPicture.asset(
          //       SvgPath.svgOptions,
          //       height: 18,
          //       width: 18,
          //       colorFilter: ColorFilter.mode(cs.primary, BlendMode.srcIn),
          //     ),
          //     onTap: () => customBottomSheet(AzkarSetting()),
          //     semanticLabel: 'settings',
          //   ),
          // ),
          _AppBarIconBtn(
            icon: SvgPicture.asset(
              SvgPath.svgHomeSetting,
              height: 18,
              width: 18,
              colorFilter: ColorFilter.mode(cs.primary, BlendMode.srcIn),
            ),
            onTap: () => customBottomSheet(AzkarSetting()),
          ),
        /*  Semantics(
          button: true,
          label: 'back',
          child: GestureDetector(
            onTap: () => customBottomSheet(AzkarSetting()),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: SvgPicture.asset(
                SvgPath.svgOptions,
                height: 20,
                width: 20,
                colorFilter: ColorFilter.mode(cs.primary, BlendMode.srcIn),
              ),
            ),
          ),
        ), */
      ],

      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

// ── Leading back button ────────────────────────────────────────────────────────

class _AppBarLeading extends StatelessWidget {
  final VoidCallback onTap;
  const _AppBarLeading({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'back',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Center(
            child: Transform.flip(
              flipX: alignmentLayout(false, true),
              child: Image.asset(
                'assets/images/arrow_back.png',
                color: Theme.of(context).colorScheme.surface,
                height: 20,
                width: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Title badge ────────────────────────────────────────────────────────────────

class _AppBarTitle extends StatelessWidget {
  final String title;
  const _AppBarTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.surface, width: 1),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Get.isDarkMode ? Colors.white : Theme.of(context).hintColor,
          fontSize: context.customOrientation(18.0, 24.0),
          fontFamily: 'kufi',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Icon button ────────────────────────────────────────────────────────────────

class _AppBarIconBtn extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final String? semanticLabel;

  const _AppBarIconBtn({
    required this.icon,
    required this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}
