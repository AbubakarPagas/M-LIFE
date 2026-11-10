part of '../quran.dart';

class QuranJuzList extends StatelessWidget {
  QuranJuzList({super.key});

  final quranCtrl = QuranController.instance;

  @override
  Widget build(BuildContext context) {
    quranCtrl.scrollToCurrentJuz();
    final jozzNames = QuranLibrary.allJoz;
    final hizbNames = QuranLibrary.allHizb;
    final isCurrent = quranCtrl.getCurrentJuzNumber;
    final cs = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final accent = cs.surface; // gold / sage / tan
    final bg = cs.primaryContainer;

    return CupertinoScrollbar(
      controller: quranCtrl.juzController,
      child: Container(
        color: bg,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 110),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: 30,
          controller: quranCtrl.juzController,
          itemBuilder: (_, index) {
            final juzNumber = index + 1;
            final juz = quranCtrl.state.allAyahs.firstWhere(
              (a) => a.juz == juzNumber,
            );
            final surah = quranCtrl.getCurrentSurahByPage(juz.page);
            final hizb1Index = index * 2;
            final hizb2Index = index * 2 + 1;
            final selected = isCurrent(index);

            return Obx(
              () => _JuzGroup(
                juzNumber: juzNumber,
                juzName: jozzNames[index],
                surahArabicName: surah.arabicName,
                startPage: juz.page,
                isSelected: selected.value,
                primary: primary,
                accent: accent,
                bg: bg,
                hizbNames: hizbNames,
                hizb1Index: hizb1Index,
                hizb2Index: hizb2Index,
                onJuzTap: () {
                  Get.to(() => QuranHome(), transition: Transition.downToUp);
                  QuranLibrary().jumpToJoz(juzNumber);
                  quranCtrl.state.navBarController.close();
                },
                onHizbTap: (hizbNumber) {
                  Get.to(() => QuranHome(), transition: Transition.downToUp);
                  QuranLibrary().jumpToHizb(hizbNumber);
                  quranCtrl.state.navBarController.close();
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
//  Juz Group: header card + 2 hizb rows
// ─────────────────────────────────────────────────────────────────────────────

class _JuzGroup extends StatelessWidget {
  final int juzNumber;
  final String juzName;
  final String surahArabicName;
  final int startPage;
  final bool isSelected;
  final Color primary;
  final Color accent;
  final Color bg;
  final List<String> hizbNames;
  final int hizb1Index;
  final int hizb2Index;
  final VoidCallback onJuzTap;
  final void Function(int hizbNumber) onHizbTap;

  const _JuzGroup({
    required this.juzNumber,
    required this.juzName,
    required this.surahArabicName,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Juz header card ───────────────────────────────────────────────
          _JuzCard(
            juzNumber: juzNumber,
            juzName: juzName,
            surahArabicName: surahArabicName,
            startPage: startPage,
            isSelected: isSelected,
            primary: primary,
            accent: accent,
            bg: bg,
            onTap: onJuzTap,
          ),

          // ── Hizb rows ─────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border(
                left: BorderSide(
                  color: accent.withValues(alpha: 0.25),
                  width: 1,
                ),
                right: BorderSide(
                  color: accent.withValues(alpha: 0.25),
                  width: 1,
                ),
                bottom: BorderSide(
                  color: accent.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: List.generate(2, (hi) {
                final hizbGlobalIndex =
                    hi == 0 ? hizb1Index : hizb2Index;
                if (hizbGlobalIndex >= hizbNames.length) {
                  return const SizedBox.shrink();
                }
                final hizbNumber = hizbGlobalIndex + 1;
                final isLast = hi == 1 ||
                    (hi == 0 && hizb2Index >= hizbNames.length);
                return _HizbRow(
                  hizbNumber: hizbNumber,
                  hizbName: hizbNames[hizbGlobalIndex],
                  isEven: hi.isEven,
                  isLast: isLast,
                  primary: primary,
                  accent: accent,
                  onTap: () => onHizbTap(hizbNumber),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Juz Header Card
// ─────────────────────────────────────────────────────────────────────────────

class _JuzCard extends StatelessWidget {
  final int juzNumber;
  final String juzName;
  final String surahArabicName;
  final int startPage;
  final bool isSelected;
  final Color primary;
  final Color accent;
  final Color bg;
  final VoidCallback onTap;

  const _JuzCard({
    required this.juzNumber,
    required this.juzName,
    required this.surahArabicName,
    required this.startPage,
    required this.isSelected,
    required this.primary,
    required this.accent,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: 88,
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: 0.08) : bg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            // Square bottom corners — hizb panel attaches below
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(4),
          ),
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
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(4),
          ),
          child: Row(
            children: [
              // ── Left accent stripe ─────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 5,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accent,
                      accent.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // ── Juz number badge ───────────────────────────────────────
              _JuzNumberBadge(
                number: juzNumber,
                accent: accent,
                primary: primary,
                bg: bg,
              ),

              const SizedBox(width: 12),

              // ── Centre: juz name + starting surah ─────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        juzName,
                        style: AppTextStyles.titleMedium(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // small decorative dot
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsetsDirectional.only(end: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent,
                          ),
                        ),
                        Text(
                          surahArabicName,
                          style: AppTextStyles.titleSmall(
                            fontSize: 13,
                            color: primary.withValues(alpha: 0.65),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ── Right: page info panel ─────────────────────────────────
              _JuzPagePanel(
                page: startPage,
                accent: accent,
                primary: primary,
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
//  Juz Number Badge  (same concentric-circle style as surah badge)
// ─────────────────────────────────────────────────────────────────────────────

class _JuzNumberBadge extends StatelessWidget {
  final int number;
  final Color accent;
  final Color primary;
  final Color bg;

  const _JuzNumberBadge({
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary,
          ),
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
//  Juz page panel (right side of header card)
// ─────────────────────────────────────────────────────────────────────────────

class _JuzPagePanel extends StatelessWidget {
  final int page;
  final Color accent;
  final Color primary;

  const _JuzPagePanel({
    required this.page,
    required this.accent,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accent.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Column(
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
              fontSize: 18,
              color: primary,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Hizb Row  — sits beneath the juz card
// ─────────────────────────────────────────────────────────────────────────────

class _HizbRow extends StatelessWidget {
  final int hizbNumber;
  final String hizbName;
  final bool isEven;
  final bool isLast;
  final Color primary;
  final Color accent;
  final VoidCallback onTap;

  const _HizbRow({
    required this.hizbNumber,
    required this.hizbName,
    required this.isEven,
    required this.isLast,
    required this.primary,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            )
          : BorderRadius.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isEven
              ? primary.withValues(alpha: 0.04)
              : Colors.transparent,
          borderRadius: isLast
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                )
              : null,
          border: !isLast
              ? Border(
                  bottom: BorderSide(
                    color: accent.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            // Hizb number pill
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.18),
                border: Border.all(
                  color: accent.withValues(alpha: 0.45),
                  width: 0.8,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$hizbNumber'.convertNumbersToCurrentLang(),
                style: AppTextStyles.titleSmall(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: primary,
                  height: 1,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Hizb name
            Expanded(
              child: Text(
                hizbName,
                style: AppTextStyles.titleSmall(
                  fontSize: 13,
                  color: primary.withValues(alpha: 0.75),
                ),
              ),
            ),

            // Subtle chevron
            Icon(
              Icons.chevron_left,
              size: 16,
              color: accent.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
