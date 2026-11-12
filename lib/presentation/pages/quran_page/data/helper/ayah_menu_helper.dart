import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:quran_library/quran.dart';

import '/core/utils/constants/extensions/extensions.dart';
import '/core/utils/helpers/app_text_styles.dart';
import '/core/widgets/container_button.dart';
import '/core/widgets/share/share_ayah_options.dart';
import '/presentation/controllers/theme_controller.dart';
import '../../../../../core/utils/constants/extensions/bottom_sheet_extension.dart';
import '../../../../../core/utils/constants/extensions/convert_number_extension.dart';
import '../../../../../core/utils/constants/svg_constants.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/tab_bar_widget.dart';
import '../../controllers/mutashabihat_controller.dart';
import '../../quran.dart';
import '../../widgets/mutashabihat/mutashabihat_bottom_sheet.dart';
import '../../widgets/mutashabihat/mutashabihat_browse_sheet.dart';
import '../../widgets/search/controller/quran_search_controller.dart';

class AyahMenuHelper {
  const AyahMenuHelper._();

  static Worker? _playbackWorker;
  static StreamSubscription<int?>? _indexSubscription;
  static final ScrollController _ayahScrollController = ScrollController();

  static void show(
    BuildContext context, {
    required SurahModel surah,
    required AyahModel ayah,
    required int pageIndex,
    WordInfoKind initialKind = WordInfoKind.recitations,
  }) {
    final isDark = ThemeController.instance.isDarkMode;
    final quranCtrl = QuranController.instance;
    final wordCtrl = WordInfoCtrl.instance;
    wordCtrl.setSelectedKind(initialKind);

    final svc = WordAudioService.instance;
    _playbackWorker?.dispose();
    _playbackWorker = null;
    _indexSubscription?.cancel();
    _indexSubscription = null;

    _playbackWorker = ever(svc.isPlayingAyahWords, (playing) {
      if (playing) {
        _indexSubscription?.cancel();
        _indexSubscription = svc.player.currentIndexStream.listen((index) {
          if (index != null && svc.isPlayingAyahWords.value) {
            final ref = WordRef(
              surahNumber: surah.surahNumber,
              ayahNumber: ayah.ayahNumber,
              wordNumber: index + 1,
            );
            quranCtrl.state.ref.value = ref;
            svc.currentPlayingRef.value = ref;
            WordInfoCtrl.instance.update(['word_info_kind']);
            QuranCtrl.instance.update([
              'single_ayah_${surah.surahNumber}-${ayah.ayahNumber}',
            ]);
            _scrollToCurrentWord(ref, ayah);
          }
        });
      } else {
        _indexSubscription?.cancel();
        _indexSubscription = null;
      }
    });

    BottomSheetExtension(null).customBottomSheet(
      backgroundColor: Get.theme.colorScheme.primaryContainer,
      handleChild: context.customOrientation(
        _AyahNumberHandle(ayah: ayah, surah: surah),
        const SizedBox.shrink(),
      ),
      _AyahMenuBody(
        surah: surah,
        ayah: ayah,
        quranCtrl: quranCtrl,
        wordCtrl: wordCtrl,
        pageIndex: pageIndex,
        isDark: isDark,
        initialKind: initialKind,
        ayahScrollController: _ayahScrollController,
      ),
    );
  }

  static void _scrollToCurrentWord(WordRef ref, AyahModel ayah) {
    scrollToWord(
      _ayahScrollController,
      wordNumber: ref.wordNumber,
      totalWords: WordAudioService.instance.getAyahWordCount(
        ref.surahNumber,
        ref.ayahNumber,
      ),
    );
  }

  @visibleForTesting
  static void scrollToWord(
    ScrollController controller, {
    required int wordNumber,
    required int totalWords,
  }) {
    if (!controller.hasClients || totalWords <= 1) return;
    for (final position in List.of(controller.positions)) {
      final maxScroll = position.maxScrollExtent;
      if (maxScroll <= 0) continue;
      final targetScroll = maxScroll * (wordNumber - 1) / (totalWords - 1);
      position.animateTo(
        targetScroll.clamp(0.0, maxScroll),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Handle: ayah number + surah name shown above the sheet body
// ─────────────────────────────────────────────────────────────
class _AyahNumberHandle extends StatelessWidget {
  const _AyahNumberHandle({required this.ayah, required this.surah});

  final AyahModel ayah;
  final SurahModel surah;

  @override
  Widget build(BuildContext context) {
    final primary = Get.theme.colorScheme.primary;
    final onPrimary = Get.theme.colorScheme.primaryContainer;
    final surface = Get.theme.colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Surah name pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              surah.arabicName,
              style: AppTextStyles.titleSmall().copyWith(
                color: primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Gap(10),
          // Ayah number badge
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withValues(alpha: 0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              '${ayah.ayahNumber}'.convertEnglishNumbersToArabic(
                ayah.ayahNumber.toString(),
              ),
              style: const TextStyle(
                fontFamily: 'ayahNumber',
                fontSize: 22,
                height: 1.2,
                package: 'quran_library',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Main body of the bottom sheet
// ─────────────────────────────────────────────────────────────
class _AyahMenuBody extends StatelessWidget {
  const _AyahMenuBody({
    required this.surah,
    required this.ayah,
    required this.quranCtrl,
    required this.wordCtrl,
    required this.pageIndex,
    required this.isDark,
    required this.initialKind,
    required this.ayahScrollController,
  });

  final SurahModel surah;
  final AyahModel ayah;
  final QuranController quranCtrl;
  final WordInfoCtrl wordCtrl;
  final int pageIndex;
  final bool isDark;
  final WordInfoKind initialKind;
  final ScrollController ayahScrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Section 1: Ayah text + word controls ─────────────────
        _AyahTextSection(
          surah: surah,
          ayah: ayah,
          quranCtrl: quranCtrl,
          wordCtrl: wordCtrl,
          isDark: isDark,
          ayahScrollController: ayahScrollController,
        ),
        const Gap(10),

        // ── Section 2: Word info panel ───────────────────────────
        _WordInfoSection(
          quranCtrl: quranCtrl,
          wordCtrl: wordCtrl,
          isDark: isDark,
          initialKind: initialKind,
        ),
        const Gap(10),

        // ── Section 3: Action buttons ────────────────────────────
        _ActionButtonsSection(
          ayah: ayah,
          surah: surah,
          pageIndex: pageIndex,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section 1 — Ayah text with word highlight + audio controls
// ─────────────────────────────────────────────────────────────
class _AyahTextSection extends StatelessWidget {
  const _AyahTextSection({
    required this.surah,
    required this.ayah,
    required this.quranCtrl,
    required this.wordCtrl,
    required this.isDark,
    required this.ayahScrollController,
  });

  final SurahModel surah;
  final AyahModel ayah;
  final QuranController quranCtrl;
  final WordInfoCtrl wordCtrl;
  final bool isDark;
  final ScrollController ayahScrollController;

  @override
  Widget build(BuildContext context) {
    final svc = WordAudioService.instance;
    final surface = Get.theme.colorScheme.surface;
    final primary = Get.theme.colorScheme.primary;
    final container = Get.theme.colorScheme.primaryContainer;
    final searchCtrl = QuranSearchController.instance;

    // Initialise the word ref
    quranCtrl.state.ref.value = WordRef(
      surahNumber: surah.surahNumber,
      ayahNumber: ayah.ayahNumber,
      wordNumber: 1,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Get.theme.colorScheme.surface.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Ayah word strip ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  // Accent bar
                  Container(
                    height: 42,
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary,
                          primary.withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: ayahScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Obx(() {
                        final playingRef =
                            (svc.isPlayingAyahWords.value &&
                                svc.currentPlayingRef.value != null &&
                                svc.currentPlayingRef.value!.wordNumber > 0)
                            ? svc.currentPlayingRef.value
                            : null;
                        return GetSingleAyah(
                          surahNumber: surah.surahNumber,
                          ayahNumber: ayah.ayahNumber,
                          enableWordSelection: true,
                          isDark: isDark,
                          enabledTajweed:
                              QuranCtrl.instance.state.isTajweedEnabled.value,
                          externalSelectedWordRef: playingRef,
                          onWordTap: (ref) {
                            quranCtrl.state.ref.value = ref;
                            WordInfoCtrl.instance.update(['word_info_kind']);
                          },
                          selectedWordColor: Colors.amber.withValues(
                            alpha: 0.3,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Thin divider ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Get.theme.colorScheme.surface.withValues(alpha: 0.12),
            ),
          ),

          // ── Word display + audio controls ────────────────────
          GetBuilder<WordInfoCtrl>(
            id: 'word_info_kind',
            builder: (wordCtrl) {
              final words = ayah.text
                  .trim()
                  .split(RegExp(r'\s+'))
                  .where((w) => RegExp(r'[\u0620-\u064A]').hasMatch(w))
                  .toList();
              final wordsSearch = ayah.ayaTextEmlaey
                  .trim()
                  .split(RegExp(r'\s+'))
                  .where((w) => RegExp(r'[\u0620-\u064A]').hasMatch(w))
                  .toList();
              final wordIndex = quranCtrl.state.ref.value.wordNumber - 1;
              final selectedWord =
                  (wordIndex >= 0 && wordIndex < words.length)
                  ? words[wordIndex]
                  : '';
              final selectedSearchWord =
                  (wordIndex >= 0 && wordIndex < wordsSearch.length)
                  ? wordsSearch[wordIndex]
                  : '';

              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                child: Row(
                  children: [
                    // ── Selected word chip ───────────────────
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          selectedWord,
                          style: TextStyle(
                            fontFamily: 'uthmanic2',
                            fontSize: 20,
                            height: 1.3,
                            color: Get.theme.colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                    ),
                    const Gap(8),
                    // ── Audio + search controls ──────────────
                    Expanded(
                      flex: 3,
                      child: Obx(() {
                        final ref = quranCtrl.state.ref.value;
                        final playing = svc.isPlaying.value;
                        final loading = svc.isLoading.value;
                        final currentRef = svc.currentPlayingRef.value;
                        final isAyahMode = svc.isPlayingAyahWords.value;

                        final isWordPlaying =
                            playing && !isAyahMode && currentRef == ref;
                        final isAyahPlaying =
                            playing &&
                            isAyahMode &&
                            currentRef?.surahNumber == ref.surahNumber &&
                            currentRef?.ayahNumber == ref.ayahNumber;
                        final isWordLoading =
                            loading && !isAyahMode && currentRef == ref;
                        final isAyahLoading =
                            loading &&
                            isAyahMode &&
                            currentRef?.surahNumber == ref.surahNumber &&
                            currentRef?.ayahNumber == ref.ayahNumber;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _AudioIconButton(
                              svgPath: isWordPlaying
                                  ? SvgPath.svgAudioPauseArrow
                                  : SvgPath.svgAudioPlayWord,
                              isLoading: isWordLoading,
                              tooltip: 'play_word',
                              onTap: () async {
                                await wordCtrl.playWordAudio(
                                  quranCtrl.state.ref.value,
                                );
                              },
                            ),
                            _AudioIconButton(
                              svgPath: isAyahPlaying
                                  ? SvgPath.svgAudioPauseArrow
                                  : SvgPath.svgAudioPlayAllWord,
                              isLoading: isAyahLoading,
                              tooltip: 'play_ayah_words',
                              onTap: () async {
                                await wordCtrl.playAyahWordsAudio(
                                  quranCtrl.state.ref.value,
                                );
                              },
                            ),
                            _AudioIconButton(
                              svgPath: SvgPath.svgHomeSearch,
                              isLoading: false,
                              tooltip: 'search_word',
                              onTap: () {
                                Get.back();
                                searchCtrl.state.searchTextEditing.text =
                                    selectedSearchWord;
                                searchCtrl.search(selectedSearchWord);
                                searchCtrl.surahSearchMethod(
                                  selectedSearchWord,
                                );
                                quranCtrl.setTopBarType =
                                    TopBarType.search;
                                quranCtrl.state.tabBarController.toggle();
                              },
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section 2 — Word info panel
// ─────────────────────────────────────────────────────────────
class _WordInfoSection extends StatelessWidget {
  const _WordInfoSection({
    required this.quranCtrl,
    required this.wordCtrl,
    required this.isDark,
    required this.initialKind,
  });

  final QuranController quranCtrl;
  final WordInfoCtrl wordCtrl;
  final bool isDark;
  final WordInfoKind initialKind;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 191.h,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Get.theme.colorScheme.surface.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GetBuilder<WordInfoCtrl>(
          id: 'word_info_kind',
          builder: (wordCtrl) => WordInfoWidget(
            ref: quranCtrl.state.ref.value,
            initialKind: initialKind,
            ctrl: wordCtrl,
            isDark: isDark,
            defaults: quranCtrl.wordInfoStyle,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section 3 — Action buttons grid
// ─────────────────────────────────────────────────────────────
class _ActionButtonsSection extends StatelessWidget {
  const _ActionButtonsSection({
    required this.ayah,
    required this.surah,
    required this.pageIndex,
  });

  final AyahModel ayah;
  final SurahModel surah;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    final primary = Get.theme.colorScheme.primary;
    final canvas = Get.theme.canvasColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ── Tafsir ─────────────────────────────────────────
          _ActionItem(
            svgPath: SvgPath.svgQuranTafsir,
            label: 'tafsir'.tr,
            iconColor: canvas,
            child: TafsirButton(
              ayah: ayah,
              pageIndex: pageIndex,
              withBack: true,
            ),
          ),

          _ActionDivider(),

          // ── Play this ayah ─────────────────────────────────
          _ActionItem(
            svgPath: SvgPath.svgAudioPlayArrow,
            label: 'play'.tr,
            iconColor: canvas,
            child: PlayButton(
              ayah: ayah,
              surah: surah,
              singleAyahOnly: true,
              withBack: true,
            ),
          ),

          _ActionDivider(),

          // ── Play full surah ────────────────────────────────
          _ActionItem(
            svgPath: SvgPath.svgQuranPlayAll,
            label: 'surah'.tr,
            iconColor: canvas,
            child: PlayButton(
              surah: surah,
              ayah: ayah,
              withBack: true,
            ),
          ),

          _ActionDivider(),

          // ── Bookmark ───────────────────────────────────────
          _BookmarkActionItem(
            surah: surah,
            ayah: ayah,
            pageIndex: pageIndex,
          ),

          _ActionDivider(),

          // ── Copy ───────────────────────────────────────────
          _ActionItem(
            svgPath: SvgPath.svgQuranCopy,
            label: 'copy'.tr,
            iconColor: canvas,
            child: CopyButton(ayah: ayah, surah: surah),
          ),

          _ActionDivider(),

          // ── Share ──────────────────────────────────────────
          _ActionItem(
            svgPath: SvgPath.svgHomeShare,
            label: 'share'.tr,
            iconColor: canvas,
            child: ShareAyahOptions(
              ayah: ayah,
              surah: surah,
              pageNumber: pageIndex,
              singleAyahMode: false,
            ),
          ),

          _ActionDivider(),

          // ── Mutashabihat ───────────────────────────────────
          _MutashabihatActionItem(
            surah: surah,
            ayah: ayah,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Reusable: single action item (icon + label stacked)
// ─────────────────────────────────────────────────────────────
class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.svgPath,
    required this.label,
    required this.iconColor,
    required this.child,
  });

  final String svgPath;
  final String label;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 40,
          width: 36,
          child: child,
        ),
        const Gap(4),
        Text(
          label,
          style: AppTextStyles.titleSmall().copyWith(
            fontSize: 9,
            color: iconColor.withValues(alpha: 0.75),
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bookmark action item (reactive — changes icon color)
// ─────────────────────────────────────────────────────────────
class _BookmarkActionItem extends StatelessWidget {
  const _BookmarkActionItem({
    required this.surah,
    required this.ayah,
    required this.pageIndex,
  });

  final SurahModel surah;
  final AyahModel ayah;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    final canvas = Get.theme.canvasColor;
    final surface = Get.theme.colorScheme.surface;

    return GetBuilder<BookmarksController>(
      id: 'ayah_bookmarked',
      builder: (bookmarksCtrl) {
        final isBookmarked = bookmarksCtrl
            .hasBookmark(surah.surahNumber, ayah.ayahUQNumber)
            .value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 40,
              width: 36,
              child: AddBookmarkButton(
                surah: surah,
                ayah: ayah,
                pageIndex: pageIndex,
                iconColor: isBookmarked ? surface : canvas,
              ),
            ),
            const Gap(4),
            Text(
              'bookmark'.tr,
              style: AppTextStyles.titleSmall().copyWith(
                fontSize: 9,
                color: isBookmarked
                    ? surface
                    : canvas.withValues(alpha: 0.75),
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Mutashabihat action item (badge + reactive)
// ─────────────────────────────────────────────────────────────
class _MutashabihatActionItem extends StatelessWidget {
  const _MutashabihatActionItem({
    required this.surah,
    required this.ayah,
  });

  final SurahModel surah;
  final AyahModel ayah;

  @override
  Widget build(BuildContext context) {
    final canvas = Get.theme.canvasColor;
    final surface = Get.theme.colorScheme.surface;
    final container = Get.theme.colorScheme.primaryContainer;
    final count = MutashabihatController.instance.getPhrasesCountForVerse(
      surah.surahNumber,
      ayah.ayahNumber,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 40,
          width: 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomButton(
                height: 40,
                width: 36,
                iconSize: 34,
                isCustomSvgColor: true,
                svgPath: SvgPath.svgQuranMutashabihat,
                svgColor: canvas,
                onPressed: () {
                  if (count > 0) {
                    MutashabihatBottomSheet.show(
                      context: context,
                      surahNumber: surah.surahNumber,
                      ayahNumber: ayah.ayahNumber,
                    );
                  } else {
                    MutashabihatBrowseSheet.show(context);
                  }
                },
              ),
              if (count > 0)
                PositionedDirectional(
                  top: -4,
                  end: -6,
                  child: Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      color: surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: container.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$count'.convertNumbersToCurrentLang(),
                      style: AppTextStyles.titleSmall().copyWith(
                        fontSize: 9,
                        color: container,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Gap(4),
        Text(
          'similar'.tr,
          style: AppTextStyles.titleSmall().copyWith(
            fontSize: 9,
            color: canvas.withValues(alpha: 0.75),
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Thin vertical divider between action buttons
// ─────────────────────────────────────────────────────────────
class _ActionDivider extends StatelessWidget {
  const _ActionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Get.theme.canvasColor.withValues(alpha: 0.2),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Small icon button used for word-level audio controls
// ─────────────────────────────────────────────────────────────
class _AudioIconButton extends StatelessWidget {
  const _AudioIconButton({
    required this.svgPath,
    required this.isLoading,
    required this.onTap,
    this.tooltip = '',
  });

  final String svgPath;
  final bool isLoading;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return ContainerButton(
      height: 40,
      width: 40,
      isPreparingDownload: isLoading,
      svgWithColorPath: svgPath,
      svgColor: Get.theme.hintColor,
      backgroundColor: Colors.transparent,
      onPressed: onTap,
    );
  }
}
