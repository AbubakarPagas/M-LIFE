import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/services/languages/app_constants.dart';
import '../../../../core/services/languages/localization_controller.dart';
import '../../../../core/services/services_locator.dart';
import '../../../../core/utils/constants/lists.dart';
import '../../../../core/utils/helpers/app_text_styles.dart';
import '../../../controllers/general/general_controller.dart';
import '/presentation/controllers/theme_controller.dart';
import '../quran.dart';

class QuranSettingsList extends StatelessWidget {
  final bool? isQuranSetting;
  final bool? isCalendarSetting;
  final bool? isStartScreen;

  QuranSettingsList({
    Key? key,
    this.isQuranSetting,
    this.isCalendarSetting = false,
    this.isStartScreen = false,
  }) : super(key: key);

  final generalCtrl = GeneralController.instance;
  final quranCtrl = QuranController.instance;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GetBuilder<ThemeController>(
      builder: (_) {
        return Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              const _HandleBar(),
              const _SettingsHeader(),
              Divider(
                height: 1,
                thickness: 1,
                indent: 20,
                endIndent: 20,
                color: Theme.of(context).colorScheme.inversePrimary.withValues(alpha: .08),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                  children: [
                    _SettingSection(
                      icon: Icons.language_rounded,
                      titleKey: 'langChange',
                      child: const _LanguageContent(),
                    ),
                    const Gap(10),
                    _SettingSection(
                      icon: Icons.palette_outlined,
                      titleKey: 'themeTitle',
                      child: const _ThemeContent(),
                    ),
                    const Gap(10),
                    _SettingSection(
                      icon: Icons.font_download_outlined,
                      titleKey: 'fontFamilyTitle',
                      child: _FontFamilyContent(),
                    ),
                    if (isQuranSetting == true) ...[
                      const Gap(10),
                      _SettingSection(
                        icon: Icons.menu_book_rounded,
                        titleKey: 'choseQuran',
                        child: MushafSettings(),
                      ),
                    ],
                    const Gap(8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _HandleBar extends StatelessWidget {
  const _HandleBar();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 2),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary.withValues(alpha: .2),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: theme.primaryColorLight.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.tune_rounded, color: theme.primaryColorLight, size: 20),
          ),
          const Gap(12),
          Text('setting'.tr, style: AppTextStyles.titleLarge().copyWith(fontSize: 20)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic collapsible section card
// ─────────────────────────────────────────────────────────────────────────────
class _SettingSection extends StatefulWidget {
  final IconData icon;
  final String titleKey;
  final Widget child;

  const _SettingSection({
    required this.icon,
    required this.titleKey,
    required this.child,
  });

  @override
  State<_SettingSection> createState() => _SettingSectionState();
}

class _SettingSectionState extends State<_SettingSection>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;
  late final AnimationController _ctrl;
  late final Animation<double> _sizeFactor;
  late final Animation<double> _chevronTurn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _sizeFactor = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _chevronTurn = Tween<double>(begin: 0.0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.inversePrimary.withValues(alpha: .07), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // ── Header row ──────────────────────────────────────
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColorLight.withValues(alpha: .13),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(widget.icon, size: 18, color: theme.primaryColorLight),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          widget.titleKey.tr,
                          style: AppTextStyles.titleSmall().copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: cs.inversePrimary,
                          ),
                        ),
                      ),
                      RotationTransition(
                        turns: _chevronTurn,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22,
                          color: cs.inversePrimary.withValues(alpha: .45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Collapsible body ────────────────────────────────
            SizeTransition(
              sizeFactor: _sizeFactor,
              axisAlignment: -1,
              child: Column(
                children: [
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: cs.inversePrimary.withValues(alpha: .07),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: widget.child,
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
// Language picker — chip-style row of languages
// ─────────────────────────────────────────────────────────────────────────────
class _LanguageContent extends StatelessWidget {
  const _LanguageContent();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (lc) {
        final languages = AppConstants.languages;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(languages.length, (i) {
            final lang = languages[i];
            final isSelected = lc.selectedIndex == i;
            final theme = Theme.of(context);
            return GestureDetector(
              onTap: () => lc.changeLangOnTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primaryColorLight.withValues(alpha: .22)
                      : theme.colorScheme.inversePrimary.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? theme.primaryColorLight.withValues(alpha: .6)
                        : theme.colorScheme.inversePrimary.withValues(alpha: .10),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(Icons.check_rounded, size: 14, color: theme.primaryColorLight),
                      const Gap(5),
                    ],
                    Text(
                      lang.languageName,
                      style: AppTextStyles.titleSmall().copyWith(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected
                            ? theme.primaryColorLight
                            : theme.colorScheme.inversePrimary.withValues(alpha: .65),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme picker — SVG thumbnail cards
// ─────────────────────────────────────────────────────────────────────────────
class _ThemeContent extends StatelessWidget {
  const _ThemeContent();

  @override
  Widget build(BuildContext context) {
    final themeCtrl = sl<ThemeController>();
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(themeList.length, (index) {
          final item = themeList[index];
          final isSelected = item['name'] == themeCtrl.currentTheme;
          final theme = Theme.of(context);
          return GestureDetector(
            onTap: () {
              themeCtrl.setTheme(item['name']);
              Get.forceAppUpdate().then((_) => Get.back());
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.primaryColorLight.withValues(alpha: .15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? theme.primaryColorLight.withValues(alpha: .5)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  SvgPicture.asset(item['svgUrl'], height: 70),
                  const Gap(8),
                  Text(
                    '${item['title']}',
                    style: AppTextStyles.titleSmall().copyWith(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected
                          ? theme.primaryColorLight
                          : theme.colorScheme.inversePrimary.withValues(alpha: .5),
                    ),
                  ),
                  const Gap(4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Font family picker — pill list with loading feedback
// ─────────────────────────────────────────────────────────────────────────────
class _FontFamilyContent extends StatelessWidget {
  _FontFamilyContent();

  final _loadingFont = ''.obs;

  void _changeFont(String font, ThemeController themeCtrl) {
    _loadingFont.value = font;
    Future.delayed(const Duration(milliseconds: 150), () {
      themeCtrl.setFontFamily(font);
      Future.delayed(const Duration(milliseconds: 100), () {
        _loadingFont.value = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = ThemeController.instance;
    final theme = Theme.of(context);
    return GetBuilder<ThemeController>(
      id: 'font_family',
      builder: (_) {
        return Obx(() {
          return Column(
            children: ThemeController.availableFontFamilies.map((font) {
              final isLoading = _loadingFont.value == font;
              final isSelected = themeCtrl.currentFontFamily == font;
              final displayKey = ThemeController.fontFamilyTranslationKeys[font] ?? font;
              final double fontSize = font == 'naskh' ? 22 : font == 'kufi' ? 17 : 20;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: isLoading ? null : () => _changeFont(font, themeCtrl),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColorLight.withValues(alpha: .18)
                          : theme.colorScheme.inversePrimary.withValues(alpha: .04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? theme.primaryColorLight.withValues(alpha: .55)
                            : theme.colorScheme.inversePrimary.withValues(alpha: .08),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 6,
                          height: 32,
                          margin: const EdgeInsetsDirectional.only(end: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.primaryColorLight
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            displayKey.tr,
                            style: AppTextStyles.titleMedium(
                              fontFamily: font,
                              fontSize: fontSize,
                              color: isSelected
                                  ? theme.colorScheme.inverseSurface
                                  : theme.colorScheme.inversePrimary.withValues(alpha: .5),
                            ),
                          ),
                        ),
                        if (isLoading)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.primaryColorLight,
                            ),
                          )
                        else if (isSelected)
                          Icon(Icons.check_rounded, size: 18, color: theme.primaryColorLight),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        });
      },
    );
  }
}
