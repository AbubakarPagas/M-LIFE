part of '../../quran.dart';

class QuranTopBar extends StatelessWidget {
   QuranTopBar({super.key});

  final quranCtrl = QuranCtrl.instance;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: Transform.translate(
        offset: const Offset(0, 75),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0, 8.0, 0),
          child: SizedBox(
            width: context.customOrientation(Get.width -50, .10),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .12),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ── Left action buttons ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Auto-scroll button (only in default display mode)
                        Obx(() {
                          final isAutoScrollActive =
                              AutoScrollCtrl.instance.state.isActive.value;
                          final isDefaultMode =
                              QuranCtrl.instance.state.displayMode.value ==
                              QuranDisplayMode.defaultMode;

                          if (!isDefaultMode) return const SizedBox.shrink();

                          return _TopBarIconButton(
                            svgPath: SvgPath.svgQuranArrowDown,
                            isActive: isAutoScrollActive,
                            activeColor: cs.primary,
                            inactiveColor: cs.primary.withValues(alpha: .45),
                            onPressed: () {
                              final ctrl = AutoScrollCtrl.instance;
                              if (ctrl.state.isActive.value) {
                                ctrl.stopAutoScroll();
                              } else {
                                final currentPage = QuranCtrl
                                    .instance
                                    .state
                                    .currentPageNumber
                                    .value;
                                ctrl.startAutoScroll(currentPage);
                              }
                              QuranController.instance.showControl();
                            },
                          );
                        }),

                        const SizedBox(width: 4),

                        // Playlist button
                        _TopBarIconButton(
                          svgPath: SvgPath.svgAudioPlaylist,
                          isActive: false,
                          activeColor: cs.primary,
                          inactiveColor: cs.primary,
                          onPressed: () => customBottomSheet(
                            backgroundColor: cs.primaryContainer,
                            AyahsPlayListWidget(),
                            bottomSheetWidth: context.customOrientation(
                              Get.width,
                              Get.width * .75,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Divider ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: cs.primary.withValues(alpha: .2),
                    ),
                  ),

                  // ── Tab bar (Quran / Recitations) ────────────────────────
                  Expanded(child: QuranOrTenRecitationsTabBar()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable minimal icon button ─────────────────────────────────────────────

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({
    required this.svgPath,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onPressed,
  });

  final String svgPath;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: .15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: SvgPicture.asset(
            svgPath,
            height: 22,
            width: 22,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
