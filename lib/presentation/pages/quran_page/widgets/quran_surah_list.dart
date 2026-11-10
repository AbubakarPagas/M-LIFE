part of '../quran.dart';

typedef QuranSurahListChildBuilder =
    Widget Function(BuildContext context, int index);
typedef QuranSurahListSelectedBuilder = bool Function(int index);

class QuranSurahList extends StatelessWidget {
  final Function(int index)? onTap;
  final QuranSurahListChildBuilder? leadingChild;
  final ScrollController? controller;
  final QuranSurahListSelectedBuilder? isSelected;
  final double? marginBottom;

  QuranSurahList({
    super.key,
    this.onTap,
    this.leadingChild,
    this.controller,
    this.isSelected,
    this.marginBottom = 0.0,
  });

  final quranCtrl = QuranController.instance;

  @override
  Widget build(BuildContext context) {
    quranCtrl.scrollToCurrentSurah();
    final currentIndex = quranCtrl.currentSurahIndex;
    final cs = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final accent = cs.surface; // gold / sage / tan depending on theme
    final bg = cs.primaryContainer;

    return CupertinoScrollbar(
      controller: controller ?? quranCtrl.surahController,
      child: Container(
        color: bg,
        child: ListView.builder(
          padding: EdgeInsets.only(
            top: 12,
            left: 12,
            right: 12,
            bottom: marginBottom ?? 110.0,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: quranCtrl.state.surahs.length,
          controller: controller ?? quranCtrl.surahController,
          itemBuilder: (_, index) {
            final surah = quranCtrl.state.surahs[index];
            return Obx(() {
              final selected =
                  (isSelected?.call(index) ?? currentIndex == index).obs;
              return _SurahCard(
                surah: surah,
                index: index,
                isSelected: selected.value,
                accent: accent,
                primary: primary,
                bg: bg,
                leadingChild: leadingChild,
                onTap: () {
                  // onTap?.call(index) ??
                  Get.to(() => QuranHome(), transition: Transition.downToUp);
                  quranCtrl.changeSurahListOnTap(surah.ayahs.first.page);
                },
              );
            });
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Individual Surah Card
// ─────────────────────────────────────────────────────────────────────────────

class _SurahCard extends StatelessWidget {
  final dynamic surah; // SurahModel from quran_library
  final int index;
  final bool isSelected;
  final Color accent;
  final Color primary;
  final Color bg;
  final QuranSurahListChildBuilder? leadingChild;
  final VoidCallback onTap;

  const _SurahCard({
    required this.surah,
    required this.index,
    required this.isSelected,
    required this.accent,
    required this.primary,
    required this.bg,
    required this.leadingChild,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: 0.08) : bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accent.withValues(alpha: 0.80)
                : primary.withValues(alpha: 0.12),
            width: isSelected ? 1.5 : 1.0,
          ),
         boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: isSelected ? 0.10 : 0.04),
              blurRadius: isSelected ? 12 : 4,
              offset: const Offset(0, 2),
            ),
          ], 
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // ── Left accent stripe ───────────────────────────────────────
       /*        AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 5,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [accent, accent.withValues(alpha: 0.4)],
                  ),
                ),
              ),
 */
              const SizedBox(width: 10),

              // ── Surah number badge ───────────────────────────────────────
              _SurahNumberBadge(
                number: surah.surahNumber,
                accent: accent,
                primary: primary,
                bg: bg,
              ),

              const SizedBox(width: 12),

              // ── Centre: Arabic calligraphic name + meta ──────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Arabic SVG name
                    RepaintBoundary(
                      child: customSvgWithColor(
                        'assets/svg/surah_name/00${index + 1}.svg',
                        color: primary,
                        width: 100,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // English name + revelation type badge
                    Row(
                      children: [
                        Text(
                          surah.englishName,
                          style: AppTextStyles.titleSmall(
                            fontSize: 12,
                            color: primary.withValues(alpha: 0.65),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _RevelationBadge(
                          type: surah.revelationType,
                          accent: accent,
                          primary: primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ── Right: leading child override or info panel ───────────────
              leadingChild?.call(context, index) ??
                  _SurahInfoPanel(
                    surah: surah,
                    accent: accent,
                    primary: primary,
                    bg: bg,
                  ),

              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Surah Number Badge  — ornamental diamond ring with number inside
// ─────────────────────────────────────────────────────────────────────────────

class _SurahNumberBadge extends StatelessWidget {
  final int number;
  final Color accent;
  final Color primary;
  final Color bg;

  const _SurahNumberBadge({
    required this.number,
    required this.accent,
    required this.primary,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.25),
                accent.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(
              color: accent.withValues(alpha: 0.55),
              width: 1.5,
            ),
          ),
        ),
        // Inner filled circle
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(shape: BoxShape.circle, color: primary),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '$number'.convertNumbersToCurrentLang(),
                style: AppTextStyles.titleSmall(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: bg,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Revelation type badge  ( مكية / مدنية )
// ─────────────────────────────────────────────────────────────────────────────

class _RevelationBadge extends StatelessWidget {
  final String type; // 'Meccan' | 'Medinan'
  final Color accent;
  final Color primary;

  const _RevelationBadge({
    required this.type,
    required this.accent,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    if (type.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 0.8),
      ),
      child: Text(
        type.tr,
        style: AppTextStyles.titleSmall(
          fontSize: 10,
          color: primary,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Info panel — shows page & ayah count with decorative gold divider
// ─────────────────────────────────────────────────────────────────────────────

class _SurahInfoPanel extends StatelessWidget {
  final dynamic surah;
  final Color accent;
  final Color primary;
  final Color bg;

  const _SurahInfoPanel({
    required this.surah,
    required this.accent,
    required this.primary,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.22), width: 0.8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _InfoRow(
            label: 'page'.tr,
            value: '${surah.ayahs.first.page}'.convertNumbersToCurrentLang(),
            accent: accent,
            primary: primary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.0),
                    accent.withValues(alpha: 0.6),
                    accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          _InfoRow(
            label: 'aya_count'.tr,
            value: '${surah.ayahs.last.ayahNumber}'
                .convertNumbersToCurrentLang(),
            accent: accent,
            primary: primary,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final Color primary;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.accent,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleSmall(
            fontSize: 9,
            color: accent,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleSmall(
            fontSize: 14,
            color: primary,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
