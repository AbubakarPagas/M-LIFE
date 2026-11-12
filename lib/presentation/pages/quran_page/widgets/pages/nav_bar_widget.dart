part of '../../quran.dart';

enum NavBarType { none, surahList, bookmarkList }

class NavBarWidget extends StatelessWidget {
  final Widget? bodyChild;
  final Widget? handleChild;
  final double? handleHeight;
  final FlexibleSheetController navBarController;

  NavBarWidget({
    super.key,
    this.bodyChild,
    this.handleChild,
    this.handleHeight,
    required this.navBarController,
  });

  final generalCtrl = GeneralController.instance;
  final quranCtrl = QuranController.instance;
  final tasmee = TasmeeCtrl.instance;

  @override
  Widget build(BuildContext context) {
    final isTasmee = tasmee.state.isTasmeeMode.value;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (quranCtrl.state.tabBarController.isOpen) {
          quranCtrl.state.isPlayExpanded.value = false;
          return;
        }
        if (isTasmee) return;
        if (details.primaryDelta != null && handleChild == null) {
          if (details.primaryDelta! < -8 &&
              quranCtrl.getNavBarType(NavBarType.none).value) {
            Future.delayed(const Duration(milliseconds: 10), () {
              quranCtrl.state.isPlayExpanded.value = true;
            });
          } else if (details.primaryDelta! > 8) {
            quranCtrl.state.isPlayExpanded.value = false;
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FlexibleSheet(
            maxHeight: context.customOrientation(
              constraints.maxHeight - 150,
              constraints.maxHeight - 70,
            ),
            minHeight: 0,
            initialHeight: 0,
            alignment: context.customOrientation(
              Alignment.bottomCenter,
              AlignmentDirectional.bottomStart,
            ),
            width: context.customOrientation(Get.width, Get.width * 0.5),
            isDraggable: false,
            direction: SheetDirection.bottomToTop,
            snapBehavior: SheetSnapBehavior.snapToEdge,
            controller: navBarController,
            onStateChanged: (state) {
              if (quranCtrl.state.navBarType.value == NavBarType.none &&
                  !tasmee.state.isTasmeeMode.value) {
                quranCtrl.state.isPlayExpanded.value = state;
                log('isOpen: $state');
              }
            },
            handleBuilder: (currentHeight) {
              final isExpanded = currentHeight >= 155;
              return _NavHandle(
                isExpanded: isExpanded,
                handleChild: handleChild,
                handleHeight: handleHeight,
                navBarController: navBarController,
                isTasmee: isTasmee,
              );
            },
            childBuilder: (_) {
              return Material(
                elevation: 0,
                color: Colors.transparent,
                child: quranCtrl.getNavBarType(NavBarType.surahList).value
                    ? bodyChild ?? SurahJuzList()
                    : BookmarksList(),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Handle bar (drag pill + card) ─────────────────────────────────────────────

class _NavHandle extends StatelessWidget {
  const _NavHandle({
    required this.isExpanded,
    required this.navBarController,
    required this.isTasmee,
    this.handleChild,
    this.handleHeight,
  });

  final bool isExpanded;
  final FlexibleSheetController navBarController;
  final bool isTasmee;
  final Widget? handleChild;
  final double? handleHeight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ── Drag pill ──────────────────────────────────────────────────
          Container(
            height: 4,
            width: 44,
            margin: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: cs.primary.withValues(alpha: .30),
            ),
          ),

          // ── Card ───────────────────────────────────────────────────────
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 230),
              curve: Curves.easeInOut,
              height: handleHeight ??
                  (QuranController.instance.state.isPlayExpanded.value
                      ? 170
                      : 58),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                color: cs.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .10),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: handleChild ??
                  _NavHandleContent(
                    isExpanded: isExpanded,
                    navBarController: navBarController,
                    isTasmee: isTasmee,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contents inside the handle card ──────────────────────────────────────────

class _NavHandleContent extends StatelessWidget {
  const _NavHandleContent({
    required this.isExpanded,
    required this.navBarController,
    required this.isTasmee,
  });

  final bool isExpanded;
  final FlexibleSheetController navBarController;
  final bool isTasmee;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final quranCtrl = QuranController.instance;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Left nav button: Surah list ──────────────────────────────────
        _NavIconButton(
          svgPath: isExpanded &&
                  quranCtrl.getNavBarType(NavBarType.surahList).value
              ? SvgPath.svgHomeClose
              : SvgPath.svgHomeSurahList,
          color: cs.primary,
          onPressed: () {
            isExpanded
                ? quranCtrl.setNavBarType = NavBarType.none
                : quranCtrl.setNavBarType = NavBarType.surahList;
            navBarController.toggle();
            quranCtrl.state.isPlayExpanded.value = false;
          },
        ),

        // ── Centre: Audio / Tasmee ───────────────────────────────────────
        Expanded(
          child: GetBuilder<GeneralController>(
            id: 'showControl',
            builder: (gc) =>
                gc.state.isShowControl.value ||
                gc.state.showAudioWidgetTemporarily.value
                ? isTasmee
                      ? TasmeeBarWidget()
                      : AudioWidget()
                : const SizedBox.shrink(),
          ),
        ),

        // ── Right nav button: Bookmarks (hidden in tasmee) ───────────────
        isTasmee
            ? const SizedBox(width: 50)
            : _NavIconButton(
                svgPath: isExpanded &&
                        quranCtrl
                            .getNavBarType(NavBarType.bookmarkList)
                            .value
                    ? SvgPath.svgHomeClose
                    : SvgPath.svgHomeBookmarkList,
                color: cs.primary,
                onPressed: () {
                  isExpanded
                      ? quranCtrl.setNavBarType = NavBarType.none
                      : quranCtrl.setNavBarType = NavBarType.bookmarkList;
                  navBarController.toggle();
                  quranCtrl.state.isPlayExpanded.value = false;
                },
              ),
      ],
    );
  }
}

// ── Minimal square icon tap target ───────────────────────────────────────────

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.svgPath,
    required this.color,
    required this.onPressed,
  });

  final String svgPath;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 50,
        height: 58,
        child: Center(
          child: SvgPicture.asset(
            svgPath,
            height: 26,
            width: 26,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
