part of '../quran.dart';

// ملاحظة هامة: يجب تضمين هذا الودجت ضمن Scaffold عند الاستدعاء حتى لا تظهر مشكلة "No Scaffold widget found"
// Important: This widget must be shown inside a Scaffold to avoid "No Scaffold widget found" error.

class ShowTafsirWidget extends StatelessWidget {
  late final int ayahUQNumber;
  final int pageIndex;
  final BuildContext context;
  final int ayahNumber;
  final bool isDark;
  final TafsirStyle? tafsirStyle;

  ShowTafsirWidget({
    super.key,
    required this.ayahUQNumber,
    required this.ayahNumber,
    required this.pageIndex,
    required this.context,
    required this.isDark,
    this.tafsirStyle,
  });

  final tafsirCtrl = TafsirCtrl.instance;
  final quranCtrl = QuranCtrl.instance;
  final tajweedCtrl = TajweedAyaCtrl.instance;

  @override
  Widget build(BuildContext context) {
    final TafsirStyle s =
        tafsirStyle ??
        (TafsirTheme.of(context)?.style ??
            TafsirStyle.defaults(isDark: isDark, context: context));

    final double deviceHeight = MediaQuery.maybeOf(context)?.size.height ?? 600;
    final double deviceWidth = MediaQuery.maybeOf(context)?.size.width ?? 400;
    final double sheetHeight = s.heightOfBottomSheet ?? (deviceHeight * 0.9);
    final double sheetWidth = s.widthOfBottomSheet ?? deviceWidth;

    final primary = Get.theme.colorScheme.primary;
    final canvas = Get.theme.canvasColor;
    final surface = Get.theme.colorScheme.surface;
    final container = Get.theme.colorScheme.primaryContainer;

    return GetBuilder<TafsirCtrl>(
      id: 'actualTafsirContent',
      builder: (tafsirCtrl) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DefaultTabController(
            length: 2,
            child: Container(
              height: sheetHeight,
              width: sheetWidth,
              decoration: BoxDecoration(
                color: s.backgroundColor ?? container,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ── Drag handle ─────────────────────────────────────
                  _TafsirDragHandle(primary: primary),

                  // ── Header: tab bar + toolbar ────────────────────────
                  _TafsirHeader(
                    s: s,
                    isDark: isDark,
                    primary: primary,
                    canvas: canvas,
                    surface: surface,
                    container: container,
                  ),

                  // ── Thin accent line ─────────────────────────────────
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary.withValues(alpha: 0.6),
                          surface.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // ── Tab content ──────────────────────────────────────
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 1 — Tafsir
                        _TafsirContentTab(
                          s: s,
                          isDark: isDark,
                          ayahUQNumber: ayahUQNumber,
                          pageIndex: pageIndex,
                          primary: primary,
                        ),
                        // Tab 2 — Tajweed rules
                        _TajweedAyaTab(
                          ayahUQNumber: ayahUQNumber,
                          ayahNumber: ayahNumber,
                          quranCtrl: quranCtrl,
                          tajweedCtrl: tajweedCtrl,
                          isDark: isDark,
                          tafsirStyle: s,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Drag handle at the very top of the sheet
// ─────────────────────────────────────────────────────────────
class _TafsirDragHandle extends StatelessWidget {
  const _TafsirDragHandle({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Header: tab bar + toolbar row
// ─────────────────────────────────────────────────────────────
class _TafsirHeader extends StatelessWidget {
  const _TafsirHeader({
    required this.s,
    required this.isDark,
    required this.primary,
    required this.canvas,
    required this.surface,
    required this.container,
  });

  final TafsirStyle s;
  final bool isDark;
  final Color primary;
  final Color canvas;
  final Color surface;
  final Color container;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            primary.withValues(alpha: 0.88),
          ],
          begin: AlignmentDirectional.centerEnd,
          end: AlignmentDirectional.centerStart,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Tab bar ────────────────────────────────────────────
          TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: surface,
            indicatorWeight: 3,
            dividerColor: Colors.transparent,
            labelStyle:
                s.tabBarLabelStyle ??
                AppTextStyles.titleSmall().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: canvas,
                ),
            unselectedLabelStyle:
                s.tabBarUnselectedLabelStyle ??
                AppTextStyles.titleSmall().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: canvas.withValues(alpha: 0.5),
                ),
            tabs: [
              Tab(text: 'tafsir'.tr),
              Tab(text: 'tajweedRules'.tr),
            ],
          ),

          // ── Toolbar row ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Change tafsir selector
                ChangeTafsirDialog(tafsirStyle: s, isDark: isDark),

                // Actions: share | copy | font size
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TafsirToolbarButton(
                      svgPath: SvgPath.svgHomeShare,
                      iconColor: surface,
                      tooltip: 'share'.tr,
                      onTap: () =>
                          QuranController.instance.shareTafsirOnTap(),
                    ),
                    _ToolbarDivider(color: canvas),
                    _TafsirToolbarButton(
                      svgPath: SvgPath.svgQuranCopy,
                      iconColor: surface,
                      tooltip: 'copy'.tr,
                      onTap: () =>
                          QuranUi(QuranController.instance).copyTafsirOnTap(),
                    ),
                    _ToolbarDivider(color: canvas),
                    // Font size popup
                    s.fontSizeWidget ??
                        fontSizeDropDown(
                          height: 28.0,
                          tafsirStyle: s,
                          isDark: isDark,
                        ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tafsir content tab (swipeable pages per ayah)
// ─────────────────────────────────────────────────────────────
class _TafsirContentTab extends StatelessWidget {
  const _TafsirContentTab({
    required this.s,
    required this.isDark,
    required this.ayahUQNumber,
    required this.pageIndex,
    required this.primary,
  });

  final TafsirStyle s;
  final bool isDark;
  final int ayahUQNumber;
  final int pageIndex;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Ayah swipe hint ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swipe_rounded,
                size: 14,
                color: Get.theme.colorScheme.inversePrimary.withValues(
                  alpha: 0.4,
                ),
              ),
              const Gap(4),
              Text(
                'swipeForAyahs'.tr,
                style: AppTextStyles.titleSmall().copyWith(
                  fontSize: 11,
                  color: Get.theme.colorScheme.inversePrimary.withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Tafsir pages ─────────────────────────────────────────
        Expanded(
          child: TafsirPagesBuildWidget(
            pageIndex: pageIndex,
            ayahUQNumber: ayahUQNumber,
            tafsirStyle: s,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Small icon button in the tafsir toolbar
// ─────────────────────────────────────────────────────────────
class _TafsirToolbarButton extends StatelessWidget {
  const _TafsirToolbarButton({
    required this.svgPath,
    required this.iconColor,
    required this.onTap,
    this.tooltip = '',
  });

  final String svgPath;
  final Color iconColor;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: const SizedBox().customSvgWithCustomColor(
            svgPath,
            color: iconColor,
            height: 22,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Thin vertical divider between toolbar icons
// ─────────────────────────────────────────────────────────────
class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: color.withValues(alpha: 0.2),
    );
  }
}
