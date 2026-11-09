part of '../../quran.dart';

/// Display Settings bottom sheet
/// Sections:
///   1. Translation language selector
///   2. Default tafsir selector
class DisplaySettingsSheet extends StatelessWidget {
  const DisplaySettingsSheet({Key? key}) : super(key: key);

  static const Color _gold = Color(0xFFD4A435);
  static const Color _goldFaint = Color(0xFFF0C96A);

  static const List<_TransOption> _translations = [
    _TransOption(value: 0, label: 'English', flag: '🇬🇧'),
    _TransOption(value: 1, label: 'Español', flag: '🇪🇸'),
    _TransOption(value: 2, label: 'Bengali', flag: '🇧🇩'),
    _TransOption(value: 3, label: 'Urdu', flag: '🇵🇰'),
    _TransOption(value: 4, label: 'Somali', flag: '🇸🇴'),
    _TransOption(value: 5, label: 'Indonesian', flag: '🇮🇩'),
    _TransOption(value: 6, label: 'Kurdish', flag: '🏳️'),
    _TransOption(value: 7, label: 'Türkçe', flag: '🇹🇷'),
  ];

  static const List<_TafsirOption> _tafsirs = [
    _TafsirOption(
      value: 0,
      label: 'Al-Jalalayn',
      author: 'Jalal al-Din al-Suyuti',
    ),
    _TafsirOption(
      value: 1,
      label: 'Ibn Kathir',
      author: 'Ibn Kathir al-Dimashqi',
    ),
    _TafsirOption(value: 2, label: 'Al-Tabari', author: 'Ibn Jarir al-Tabari'),
    _TafsirOption(
      value: 3,
      label: 'Al-Baghawi',
      author: 'Abu Muhammad al-Baghawi',
    ),
    _TafsirOption(
      value: 4,
      label: 'Al-Qurtubi',
      author: 'Muhammad ibn Ahmad al-Qurtubi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final transCtrl = TafsirCtrl.instance;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Fixed header (handle + title + gold line) ──────────────────
            const _SheetHeader(gold: _gold, goldFaint: _goldFaint),

            // ── Scrollable body ────────────────────────────────────────────
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  // ── Section 1: Translation ─────────────────────────────
                  const _DisplaySettingsSectionHeader(
                    icon: Icons.translate_rounded,
                    label: 'Default Translation',
                    gold: _gold,
                  ),
                  const SizedBox(height: 14),
                  Obx(() {
                    final selected = transCtrl.radioValue.value;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _translations.map((opt) {
                        final isSelected = selected == opt.value;
                        return _TranslationChip(
                          opt: opt,
                          isSelected: isSelected,
                          gold: _gold,
                          onTap: () {
                            transCtrl.handleRadioValueChanged(
                              opt.value,
                              pageNumber: QuranCtrl
                                  .instance
                                  .state
                                  .currentPageNumber
                                  .value,
                            );
                          },
                        );
                      }).toList(),
                    );
                  }),

                  const SizedBox(height: 32),

                  // ── Section 2: Tafsir ──────────────────────────────────
                  const _DisplaySettingsSectionHeader(
                    icon: Icons.menu_book_rounded,
                    label: 'Default Tafsir',
                    gold: _gold,
                  ),
                  const SizedBox(height: 14),
                  Obx(() {
                    final selectedTafsir = transCtrl.radioValue.value;
                    return Column(
                      children: _tafsirs.map((opt) {
                        final isSelected = selectedTafsir == opt.value;
                        return _TafsirTile(
                          opt: opt,
                          isSelected: isSelected,
                          gold: _gold,
                          onTap: () {
                            transCtrl.handleRadioValueChanged(
                              opt.value,
                              pageNumber: QuranCtrl
                                  .instance
                                  .state
                                  .currentPageNumber
                                  .value,
                            );
                          },
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fixed sheet header: drag handle + decorative gold line + title
// ─────────────────────────────────────────────────────────────────────────────
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.gold, required this.goldFaint});
  final Color gold;
  final Color goldFaint;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Decorative Islamic arch icon + title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                SvgPath.svgDecorations,
                height: 22,
                colorFilter: ColorFilter.mode(gold, BlendMode.srcIn),
              ),
              const SizedBox(width: 10),
              Text(
                'Display Settings',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: cs.onSurface,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 10),
              Transform.flip(
                flipX: true,
                child: SvgPicture.asset(
                  SvgPath.svgDecorations,
                  height: 22,
                  colorFilter: ColorFilter.mode(gold, BlendMode.srcIn),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Gold gradient divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  gold.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header row: icon + label + trailing line
// ─────────────────────────────────────────────────────────────────────────────
class _DisplaySettingsSectionHeader extends StatelessWidget {
  const _DisplaySettingsSectionHeader({
    required this.icon,
    required this.label,
    required this.gold,
  });
  final IconData icon;
  final String label;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: gold.withValues(alpha: 0.30), width: 1),
          ),
          child: Icon(icon, size: 16, color: gold),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'kufi',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gold.withValues(alpha: 0.35), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Translation language chip
// ─────────────────────────────────────────────────────────────────────────────
class _TranslationChip extends StatelessWidget {
  const _TranslationChip({
    required this.opt,
    required this.isSelected,
    required this.gold,
    required this.onTap,
  });
  final _TransOption opt;
  final bool isSelected;
  final Color gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? gold.withValues(alpha: 0.15)
              : cs.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? gold : cs.outline.withValues(alpha: 0.25),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gold.withValues(alpha: 0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(opt.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 7),
            Text(
              opt.label,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? gold : cs.onSurface.withValues(alpha: 0.85),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_circle_rounded, size: 14, color: gold),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tafsir selection tile
// ─────────────────────────────────────────────────────────────────────────────
class _TafsirTile extends StatelessWidget {
  const _TafsirTile({
    required this.opt,
    required this.isSelected,
    required this.gold,
    required this.onTap,
  });
  final _TafsirOption opt;
  final bool isSelected;
  final Color gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected
              ? gold.withValues(alpha: 0.10)
              : cs.surface.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? gold : cs.outline.withValues(alpha: 0.20),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gold.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Custom radio dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? gold : Colors.transparent,
                border: Border.all(
                  color: isSelected ? gold : cs.outline.withValues(alpha: 0.40),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 14),

            // Book icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (isSelected ? gold : cs.onSurface).withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 15,
                color: isSelected ? gold : cs.onSurface.withValues(alpha: 0.45),
              ),
            ),

            const SizedBox(width: 12),

            // Name + author
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opt.label,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? gold : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    opt.author,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────
class _TransOption {
  final int value;
  final String label;
  final String flag;
  const _TransOption({
    required this.value,
    required this.label,
    required this.flag,
  });
}

class _TafsirOption {
  final int value;
  final String label;
  final String author;
  const _TafsirOption({
    required this.value,
    required this.label,
    required this.author,
  });
}
