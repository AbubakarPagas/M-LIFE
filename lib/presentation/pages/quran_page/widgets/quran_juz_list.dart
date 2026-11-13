part of '../quran.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  QuranJuzList  — clean, professional Islamic juz & hizb browser
// ─────────────────────────────────────────────────────────────────────────────

class QuranJuzList extends StatelessWidget {
  QuranJuzList({super.key});

  final quranCtrl = QuranController.instance;

  @override
  Widget build(BuildContext context) {
    quranCtrl.scrollToCurrentJuz();

    final jozzNames = QuranLibrary.allJoz;
    final hizbNames = QuranLibrary.allHizb;
    final isCurrent = quranCtrl.getCurrentJuzNumber;
    final cs        = Theme.of(context).colorScheme;
    final primary   = cs.primary;
    final accent    = cs.surface;
    final bg        = cs.primaryContainer;

    return CupertinoScrollbar(
      controller: quranCtrl.juzController,
      child: Container(
        color: bg,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 110),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: 30,
          controller: quranCtrl.juzController,
          itemBuilder: (_, index) {
            final juzNumber     = index + 1;
            final firstAyah     = quranCtrl.state.allAyahs
                .firstWhere((a) => a.juz == juzNumber);
            final surah         = quranCtrl.getCurrentSurahByPage(firstAyah.page);
            final firstAyahText = firstAyah.text;
            final hizb1Index    = index * 2;
            final hizb2Index    = index * 2 + 1;
            final selected      = isCurrent(index);

            return Obx(
              () => _JuzCard(
                juzNumber:        juzNumber,
                juzName:          jozzNames[index],
                surahArabicName:  surah.arabicName,
                surahEnglishName: surah.englishName,
                firstAyahText:    firstAyahText,
                startPage:        firstAyah.page,
                isSelected:       selected.value,
                primary:          primary,
                accent:           accent,
                bg:               bg,
                hizbNames:        hizbNames,
                hizb1Index:       hizb1Index,
                hizb2Index:       hizb2Index,
                onJuzTap: () {
                  // onJuzTap?.call(index);
                  QuranLibrary().jumpToJoz(juzNumber);
                  quranCtrl.state.navBarController.close();
                  Get.to(() => QuranHome(), transition: Transition.downToUp);
                },
                onHizbTap: (hizbNumber) {
                  QuranLibrary().jumpToHizb(hizbNumber);
                  quranCtrl.state.navBarController.close();
                  Get.to(() => QuranHome(), transition: Transition.downToUp);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _JuzCard  — full expandable card: header + 2 hizb rows
// ─────────────────────────────────────────────────────────────────────────────

class _JuzCard extends StatelessWidget {
  final int    juzNumber;
  final String juzName;
  final String surahArabicName;
  final String surahEnglishName;
  final String firstAyahText;
  final int    startPage;
  final bool   isSelected;
  final Color  primary;
  final Color  accent;
  final Color  bg;
  final List<String>               hizbNames;
  final int                        hizb1Index;
  final int                        hizb2Index;
  final VoidCallback               onJuzTap;
  final void Function(int hizbNumber) onHizbTap;

  const _JuzCard({
    required this.juzNumber,
    required this.juzName,
    required this.surahArabicName,
    required this.surahEnglishName,
    required this.firstAyahText,
    required this.startPage,
    required this.isSelected,
    required this.primary,
    required this.accent,
    required this.bg,
    required this.hizbNames,
    required this.hizb1Index,
    required this.hizb2Index,
    required this.onJuzTap,
    required this.onHizbTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? primary.withValues(alpha: 0.07) : bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? accent.withValues(alpha: 0.85)
              : primary.withValues(alpha: 0.10),
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: isSelected ? 0.09 : 0.03),
            blurRadius: isSelected ? 16 : 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header row ───────────────────────────────────────────────
            _JuzHeader(
              juzNumber:        juzNumber,
              juzName:          juzName,
              surahArabicName:  surahArabicName,
              surahEnglishName: surahEnglishName,
              firstAyahText:    firstAyahText,
              startPage:        startPage,
              isSelected:       isSelected,
              primary:          primary,
              accent:           accent,
              bg:               bg,
              onTap:            onJuzTap,
            ),

            // ── Ornamental divider ────────────────────────────────────────
            _OrnamentalDivider(accent: accent, primary: primary),

            // ── Hizb rows ─────────────────────────────────────────────────
            for (int hi = 0; hi < 2; hi++) ...[
              Builder(
                builder: (_) {
                  final globalIdx = hi == 0 ? hizb1Index : hizb2Index;
                  if (globalIdx >= hizbNames.length) return const SizedBox.shrink();
                  final hizbNumber = globalIdx + 1;
                  final isLast     = hi == 1 || (hi == 0 && hizb2Index >= hizbNames.length);
                  final hizbHalf   = hi == 0 ? 1 : 2;
                  return _HizbRow(
                    hizbNumber: hizbNumber,
                    hizbName:   hizbNames[globalIdx],
                    hizbHalf:   hizbHalf,
                    isEven:     hi.isEven,
                    isLast:     isLast,
                    primary:    primary,
                    accent:     accent,
                    bg:         bg,
                    onTap:      () => onHizbTap(hizbNumber),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _JuzHeader  — tap-able top section of the card
// ─────────────────────────────────────────────────────────────────────────────

class _JuzHeader extends StatelessWidget {
  final int    juzNumber;
  final String juzName;
  final String surahArabicName;
  final String surahEnglishName;
  final String firstAyahText;
  final int    startPage;
  final bool   isSelected;
  final Color  primary;
  final Color  accent;
  final Color  bg;
  final VoidCallback onTap;

  const _JuzHeader({
    required this.juzNumber,
    required this.juzName,
    required this.surahArabicName,
    required this.surahEnglishName,
    required this.firstAyahText,
    required this.startPage,
    required this.isSelected,
    required this.primary,
    required this.accent,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: accent.withValues(alpha: 0.12),
      highlightColor: accent.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Juz number medallion ────────────────────────────────────
            _JuzMedallion(
              number:     juzNumber,
              isSelected: isSelected,
              primary:    primary,
              accent:     accent,
              bg:         bg,
            ),

            const SizedBox(width: 14),

            // ── Centre: juz name + surah + first ayah ───────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Juz Arabic name ────────────────────────────────────
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      juzName,
                      style: AppTextStyles.titleMedium(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: primary,
                        height: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ── Surah name row: Arabic (bold) + English ────────────
                  Row(
                    children: [
                      _AccentDiamond(accent: accent),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          surahArabicName,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleSmall(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: primary.withValues(alpha: 0.85),
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '·',
                        style: AppTextStyles.titleSmall(
                          fontSize: 12,
                          color: accent.withValues(alpha: 0.60),
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          surahEnglishName,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleSmall(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primary.withValues(alpha: 0.55),
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── First ayah text preview ────────────────────────────
                  Text(
                    firstAyahText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'uthmanic2',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: primary.withValues(alpha: 0.65),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ── Right: page badge ────────────────────────────────────────
            _PageBadge(
              page:    startPage,
              accent:  accent,
              primary: primary,
              bg:      bg,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _JuzMedallion  — concentric-ring juz number badge
// ─────────────────────────────────────────────────────────────────────────────

class _JuzMedallion extends StatelessWidget {
  final int   number;
  final bool  isSelected;
  final Color primary;
  final Color accent;
  final Color bg;

  const _JuzMedallion({
    required this.number,
    required this.isSelected,
    required this.primary,
    required this.accent,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Outer glow ring ─────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: isSelected ? 0.35 : 0.22),
                accent.withValues(alpha: isSelected ? 0.12 : 0.06),
              ],
            ),
            border: Border.all(
              color: accent.withValues(alpha: isSelected ? 0.75 : 0.45),
              width: isSelected ? 2.0 : 1.5,
            ),
          ),
        ),

        // ── Inner filled circle ──────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary,
            boxShadow: isSelected
                ? [BoxShadow(color: primary.withValues(alpha: 0.25), blurRadius: 8)]
                : [],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'جزء',
                style: AppTextStyles.titleSmall(
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  color: bg.withValues(alpha: 0.65),
                  height: 1.0,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '$number'.convertNumbersToCurrentLang(),
                    style: AppTextStyles.titleSmall(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: bg,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _PageBadge  — compact page number display on the right
// ─────────────────────────────────────────────────────────────────────────────

class _PageBadge extends StatelessWidget {
  final int   page;
  final Color accent;
  final Color primary;
  final Color bg;

  const _PageBadge({
    required this.page,
    required this.accent,
    required this.primary,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withValues(alpha: 0.28),
          width: 0.9,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'page'.tr,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall(
              fontSize: 9,
              color: accent,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$page'.convertNumbersToCurrentLang(),
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall(
              fontSize: 17,
              color: primary,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _OrnamentalDivider  — thin gradient line between header and hizb rows
// ─────────────────────────────────────────────────────────────────────────────

class _OrnamentalDivider extends StatelessWidget {
  final Color accent;
  final Color primary;

  const _OrnamentalDivider({required this.accent, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.0),
                    accent.withValues(alpha: 0.50),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '✦',
              style: TextStyle(
                fontSize: 9,
                color: accent.withValues(alpha: 0.65),
                height: 1,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.50),
                    accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _HizbRow  — single hizb entry beneath the juz header
// ─────────────────────────────────────────────────────────────────────────────

class _HizbRow extends StatelessWidget {
  final int    hizbNumber;
  final String hizbName;
  final int    hizbHalf;
  final bool   isEven;
  final bool   isLast;
  final Color  primary;
  final Color  accent;
  final Color  bg;
  final VoidCallback onTap;

  const _HizbRow({
    required this.hizbNumber,
    required this.hizbName,
    required this.hizbHalf,
    required this.isEven,
    required this.isLast,
    required this.primary,
    required this.accent,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rowBg = isEven
        ? primary.withValues(alpha: 0.035)
        : Colors.transparent;

    return InkWell(
      onTap: onTap,
      splashColor: accent.withValues(alpha: 0.10),
      highlightColor: accent.withValues(alpha: 0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        decoration: BoxDecoration(
          color: rowBg,
          border: !isLast
              ? Border(
                  top: BorderSide(
                    color: accent.withValues(alpha: 0.12),
                    width: 0.7,
                  ),
                )
              : const Border(
                  top: BorderSide(color: Colors.transparent, width: 0),
                ),
        ),
        child: Row(
          children: [
            // ── Half-juz label pill ──────────────────────────────────────
            _HizbHalfPill(
              hizbHalf: hizbHalf,
              accent:   accent,
              primary:  primary,
            ),

            const SizedBox(width: 10),

            // ── Hizb number badge ────────────────────────────────────────
            _HizbBadge(
              number:  hizbNumber,
              primary: primary,
              accent:  accent,
              bg:      bg,
            ),

            const SizedBox(width: 12),

            // ── Hizb Arabic name ─────────────────────────────────────────
            Expanded(
              child: Text(
                hizbName,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleSmall(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: primary.withValues(alpha: 0.80),
                  height: 1.2,
                ),
              ),
            ),

            // ── Trailing chevron ─────────────────────────────────────────
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.10),
              ),
              child: Icon(
                Icons.chevron_left,
                size: 16,
                color: accent.withValues(alpha: 0.70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _HizbHalfPill  — "الأول" / "الثاني" label
// ─────────────────────────────────────────────────────────────────────────────

class _HizbHalfPill extends StatelessWidget {
  final int   hizbHalf;
  final Color accent;
  final Color primary;

  const _HizbHalfPill({
    required this.hizbHalf,
    required this.accent,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final label = hizbHalf == 1 ? 'الأول' : 'الثاني';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: 0.38),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.titleSmall(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: primary.withValues(alpha: 0.80),
          height: 1.1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _HizbBadge  — small circular number for the hizb
// ─────────────────────────────────────────────────────────────────────────────

class _HizbBadge extends StatelessWidget {
  final int   number;
  final Color primary;
  final Color accent;
  final Color bg;

  const _HizbBadge({
    required this.number,
    required this.primary,
    required this.accent,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withValues(alpha: 0.08),
        border: Border.all(
          color: primary.withValues(alpha: 0.22),
          width: 0.9,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number'.convertNumbersToCurrentLang(),
        style: AppTextStyles.titleSmall(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: primary,
          height: 1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _AccentDiamond  — tiny decorative diamond/dot
// ─────────────────────────────────────────────────────────────────────────────

class _AccentDiamond extends StatelessWidget {
  final Color accent;

  const _AccentDiamond({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.785, // 45°
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.80),
          borderRadius: BorderRadius.circular(1.5),
        ),
      ),
    );
  }
}
