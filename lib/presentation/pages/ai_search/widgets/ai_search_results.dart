part of '../ai_search.dart';

class AiSearchResults extends StatelessWidget {
  AiSearchResults({super.key});

  final ctrl = AiSearchController.instance;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final primary = theme.primaryColor;
    final surface = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: primary,
      body: Column(
        children: [
          // ── Custom header ────────────────────────────────────────────────
          _MidadHeader(primary: primary, surface: surface),
          // ── Body ─────────────────────────────────────────────────────────
          Expanded(
            child: SafeArea(
              top: false,
              child: Obx(() {
                if (ctrl.state.midasMode.value == MidasMode.assistant) {
                  return _buildAssistantMode(context);
                }
                return _buildSemanticMode(context);
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Semantic (vector) mode ─────────────────────────────────────────────────
  Widget _buildSemanticMode(BuildContext context) {
    ctrl.ensureInitialized();
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Expanded(child: Center(child: _buildContent(context, ctrl))),
            Obx(() {
              if (!ctrl.state.hasAnySectionLoaded) return const SizedBox.shrink();
              return _buildInputArea(context);
            }),
          ],
        ),
        FloatingMenuWidget(ctrl: ctrl),
      ],
    );
  }

  // ── AI assistant mode ──────────────────────────────────────────────────────
  Widget _buildAssistantMode(BuildContext context) {
    return Obx(() {
      final online = ConnectionController.instance.isOnline;
      if (!online) {
        return _buildOfflineState(context);
      }
      return Column(
        children: [
          Expanded(child: UnifiedAssistantView()),
          _buildInputArea(context),
        ],
      );
    });
  }

  Widget _buildOfflineState(BuildContext context) {
    final surface = context.theme.colorScheme.surface;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const IconWidget(isOnlineMode: true),
        const Gap(8),
        Text(
          'noInternet'.tr,
          style: AppTextStyles.titleMedium(
            fontSize: 22,
            color: surface,
          ),
          textAlign: TextAlign.center,
        ),
        customLottie(LottieConstants.assetsLottieNoInternet, width: 90.0),
      ],
    );
  }

  // ── Shared input area: InputBarWidget wrapped in a styled surface ──────────
  Widget _buildInputArea(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.primaryColor,
        border: Border(
          top: BorderSide(
            color: context.theme.colorScheme.surface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: InputBarWidget(),
    );
  }

  // ── Content dispatcher ─────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context, AiSearchController ctrl) {
    if (!ctrl.isInitialized.value) {
      return _buildInitializing(context, ctrl);
    }
    if (!ctrl.state.hasAnySectionLoaded) {
      return _buildSectionDownloadPrompt(context, ctrl);
    }
    if (ctrl.state.isLoading.value) {
      return Center(
        child: CircularProgressIndicator(
          color: context.theme.colorScheme.surface,
          strokeWidth: 2,
        ),
      );
    }
    final hasResults = SearchSection.all.any(
      (s) => ctrl.state.sectionResults(s.id).isNotEmpty,
    );
    if (!ctrl.state.isSearching.value && !hasResults) {
      if (ctrl.state.searchTextEditing.text.isNotEmpty && hasResults) {
        return _buildNoResults(context, ctrl);
      }
      return _buildEmptyState(context, ctrl);
    }
    return _buildGroupedResults(context, ctrl);
  }

  // ── Empty/welcome state ────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, AiSearchController ctrl) {
    final surface = context.theme.colorScheme.surface;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const IconWidget(),
          Text(
            'startSearchPrompt'.tr,
            style: AppTextStyles.titleMedium(
              fontSize: 15,
              color: surface.withValues(alpha: 0.85),
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(28),
          _buildSuggestionGrid(context, [
            'ما فضل صلاة الليل؟',
            'أحكام الزكاة',
            'أدلة على وجود الله',
            'كيفية الوضوء',
            'فضل سورة البقرة',
          ]),
          const Gap(28),
          const MidadNoteWidget(),
        ],
      ),
    );
  }

  Widget _buildSuggestionGrid(BuildContext context, List<String> suggestions) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((s) => _suggestionChip(context, s)).toList(),
    );
  }

  Widget _suggestionChip(
    BuildContext context,
    String text, {
    bool withArrow = false,
  }) {
    return ContainerButton(
      title: text,
      horizontalPadding: 10.0,
      withArrow: withArrow,
      backgroundColor: context.theme.colorScheme.surface,
      titleStyle: AppTextStyles.titleSmall(color: Colors.black),
      onPressed: () {
        ctrl.state.searchTextEditing.text = text;
        ctrl.search(text);
      },
    );
  }

  // ── Section download prompt ────────────────────────────────────────────────
  Widget _buildSectionDownloadPrompt(
    BuildContext context,
    AiSearchController ctrl,
  ) {
    final surface = context.theme.colorScheme.surface;
    final error = context.theme.colorScheme.error;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox().customSvg(SvgPath.svgHomeMidadIcon, height: 70),
            const Gap(12),
            Text(
              'midadWelcome'.tr,
              style: AppTextStyles.titleMedium(
                fontSize: 12,
                color: surface,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'midadWelcomeDesc'.tr,
              style: AppTextStyles.titleMedium(
                fontSize: 14,
                color: surface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(20),
            Text(
              'midadSelectSections'.tr,
              style: AppTextStyles.titleMedium(
                fontSize: 14,
                color: surface.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            Obx(() => !ctrl.state.isSharedLoaded.value
                ? SharedDownloadCard(onDownload: () => ctrl.downloadShared())
                : Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 18,
                            color: surface.withValues(alpha: 0.6)),
                        const Gap(8),
                        Text(
                          'sharedFilesReady'.tr,
                          style: AppTextStyles.titleMedium(
                            fontSize: 13,
                            color: surface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )),
            Obx(() => !ctrl.state.isSharedLoaded.value
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'sharedFilesRequired'.tr,
                      style: AppTextStyles.titleMedium(
                        fontSize: 12,
                        color: error.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : const SizedBox.shrink()),
            ...SearchSection.all.map(
              (section) => SectionDownloadCard(
                section: section,
                onDownload: () => ctrl.downloadSection(section),
              ),
            ),
            const Gap(12),
            Obx(() {
              if (!ctrl.state.isSharedLoaded.value) {
                return const SizedBox.shrink();
              }
              final hasUndownloaded = SearchSection.all.any(
                (s) => !ctrl.state.isSectionLoaded(s.id).value,
              );
              if (!hasUndownloaded) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => ctrl.downloadAllSections(ctrl),
                    icon: Icon(Icons.download_rounded,
                        size: 18,
                        color: surface.withValues(alpha: 0.8)),
                    label: Text(
                      'downloadAll'.tr,
                      style: AppTextStyles.titleMedium(
                        fontSize: 14,
                        color: surface.withValues(alpha: 0.8),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: surface.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            const Gap(16),
            Text(
              'midadLaterHint'.tr,
              style: AppTextStyles.titleMedium(
                fontSize: 12,
                color: surface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Initializing state ─────────────────────────────────────────────────────
  Widget _buildInitializing(BuildContext context, AiSearchController ctrl) {
    final surface = context.theme.colorScheme.surface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox().customSvg(SvgPath.svgHomeMidadIcon, height: 70),
          const Gap(24),
          customLottie(LottieConstants.assetsLottieSplashLoading, width: 60.0),
          const Gap(16),
          Text(
            'initializingMidad'.tr,
            style: AppTextStyles.titleMedium(
              fontSize: 15,
              color: surface,
            ),
          ),
          const Gap(8),
          Text(
            'initializingMidadDesc'.tr,
            style: AppTextStyles.titleMedium(
              fontSize: 13,
              color: surface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── No results state ───────────────────────────────────────────────────────
  Widget _buildNoResults(BuildContext context, AiSearchController ctrl) {
    final surface = context.theme.colorScheme.surface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconWidget(),
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: surface.withValues(alpha: 0.5),
            ),
            const Gap(6),
            Text(
              'noResultsFound'.tr,
              style: AppTextStyles.titleMedium(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: surface.withValues(alpha: 0.9),
              ),
            ),
            const Gap(8),
            Text(
              'tryDifferentQuery'.tr,
              style: AppTextStyles.titleMedium(
                fontSize: 13,
                color: surface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Grouped results ────────────────────────────────────────────────────────
  Widget _buildGroupedResults(BuildContext context, AiSearchController ctrl) {
    final query = ctrl.state.searchTextEditing.text.trim().isEmpty
        ? ctrl.state.currentQuery.value
        : ctrl.state.searchTextEditing.text.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          children: [
            const IconWidget(),
            if (query.isNotEmpty) _buildUserQuery(context, query),
            const Gap(12),
            if (!ctrl.state.introStreamed.value)
              _buildStreamingIntro(context, ctrl, query)
            else if (ctrl.state.hasAnyResult)
              _buildStaticIntro(context, ctrl, query),
            const Gap(16),
            if (ctrl.state.introStreamed.value)
              for (final section in SearchSection.all) ...[
                if (ctrl.state.sectionResults(section.id).isNotEmpty)
                  _CategorySection(
                    title: '${'from'.tr} ${section.titleAr.tr}',
                    results: ctrl.state.sectionResults(section.id),
                    sectionId: section.id,
                    query: query,
                    hasMore: ctrl.state.hasMore(section.id),
                    remainingCount: ctrl.state.remainingCount(section.id),
                    totalCount: ctrl.state.totalCount(section.id),
                    onShowMore: () => ctrl.state.showMore(section.id),
                  ),
                if (ctrl.state.searchingCategory.value == section.id)
                  _buildSearchingIndicator(
                    context,
                    'جاري البحث في ${section.titleAr}...',
                  ),
              ],
            if (ctrl.state.allResultsReady.value) ...[
              const Gap(16),
              _buildFollowUpSuggestions(context, query),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserQuery(BuildContext context, String query) {
    final surface = context.theme.colorScheme.surface;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(right: 20, left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: surface.withValues(alpha: 0.08),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
          ),
          border: Border.all(color: surface.withValues(alpha: 0.1)),
        ),
        child: Text(
          query,
          style: AppTextStyles.titleMedium(
            fontSize: 15,
            height: 1.4,
            color: surface,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchingIndicator(BuildContext context, String text) {
    final surface = context.theme.colorScheme.surface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: surface.withValues(alpha: 0.3),
            ),
          ),
          const Gap(10),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: surface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpSuggestions(BuildContext context, String query) {
    final suggestions = _generateFollowUpSuggestions(query);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: suggestions
            .map((s) => _suggestionChip(context, s, withArrow: true))
            .toList(),
      ),
    );
  }

  List<String> _generateFollowUpSuggestions(String query) {
    final lower = query.trim().toLowerCase();
    final topic = _extractTopic(query.trim());

    if (_matchesAny(lower, ['فضل', 'فضلها', 'فوائد', 'ثواب', 'أجر', 'فائدة'])) {
      return ['أحاديث عن $topic', '$topic في القرآن الكريم', 'كيفية $topic'];
    }
    if (_matchesAny(lower, ['أحكام', 'حكم', 'كيف', 'كيفية', 'شروط', 'واجب', 'سنة', 'مستحب', 'مكروه', 'حرام', 'حلال'])) {
      return ['أدلة $topic من السنة', '$topic في القرآن الكريم', 'شروط $topic'];
    }
    if (_matchesAny(lower, ['عقيدة', 'توحيد', 'إيمان', 'إله', 'الله', 'قدر', 'قضاء', 'يوم القيامة', 'جنة', 'نار'])) {
      return ['أدلة $topic من القرآن', 'أحاديث عن $topic', '$topic عند أهل السنة'];
    }
    if (_matchesAny(lower, ['غزوة', 'سيرة', 'النبي', 'الرسول', 'صحابي', 'معركة', 'فتح', 'هجرة'])) {
      return ['الدروس المستفادة من $topic', 'أحداث $topic', 'أحاديث عن $topic'];
    }
    if (_matchesAny(lower, ['تفسير', 'معنى', 'آية', 'سورة', 'تأويل'])) {
      return ['أسباب نزول $topic', '$topic في كتب التفسير', 'فضل $topic'];
    }
    if (_matchesAny(lower, ['أدلة', 'دليل', 'برهان', 'حجة'])) {
      return ['أحاديث عن $topic', '$topic في القرآن الكريم', 'أقوال العلماء في $topic'];
    }
    if (_matchesAny(lower, ['حديث', 'أحاديث', 'رواه', 'البخاري', 'مسلم', 'سند'])) {
      return ['درجة حديث $topic', 'شرح $topic', '$topic في كتب السنة'];
    }
    if (_matchesAny(lower, ['فرق', 'مقارنة', 'أيهما', 'أفضل', 'الصحيح'])) {
      return ['أدلة $topic', 'أقوال العلماء في $topic', '$topic في القرآن والسنة'];
    }
    return ['أحاديث عن $topic', '$topic في القرآن الكريم', 'أقوال العلماء في $topic'];
  }

  String _extractTopic(String query) {
    var topic = query.trim();
    final prefixes = [
      'ما ', 'ما هي ', 'ما هو ', 'ماذا ', 'هل ', 'كيف ', 'كيفية ',
      'لماذا ', 'لما ', 'أين ', 'متى ', 'من ', 'كم ', 'أحكام ',
      'حكم ', 'فضل ', 'فوائد ', 'فائدة ', 'أدلة على ', 'أدلة ',
      'دليل على ', 'دليل ', 'تفسير ', 'معنى ', 'شروط ', 'أسباب ',
    ];
    for (final prefix in prefixes) {
      if (topic.startsWith(prefix)) {
        topic = topic.substring(prefix.length);
        break;
      }
    }
    if (topic.endsWith('؟') || topic.endsWith('?')) {
      topic = topic.substring(0, topic.length - 1);
    }
    return topic.trim();
  }

  bool _matchesAny(String text, List<String> keywords) {
    for (final kw in keywords) {
      if (text.contains(kw)) return true;
    }
    return false;
  }

  Widget _buildStreamingIntro(
    BuildContext context,
    AiSearchController ctrl,
    String query,
  ) {
    final introText = _buildIntroText(query, ctrl);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: StreamingTextMarkdown(
          text: introText,
          wordByWord: true,
          chunkSize: 1,
          styleSheet: AppTextStyles.titleMedium(
            fontSize: 15,
            height: 1.6,
            color: context.theme.canvasColor,
          ),
          textDirection: TextDirection.rtl,
          markdownEnabled: true,
          onComplete: () {
            ctrl.state.introStreamed.value = true;
          },
        ),
      ),
    );
  }

  Widget _buildStaticIntro(
    BuildContext context,
    AiSearchController ctrl,
    String query,
  ) {
    final introText = _buildIntroText(query, ctrl);
    final plainText = introText.replaceAll('**', '');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          plainText,
          style: AppTextStyles.titleMedium(
            fontSize: 15,
            height: 1.6,
            color: context.theme.canvasColor,
          ),
        ),
      ),
    );
  }

  String _buildIntroText(String query, AiSearchController ctrl) {
    final enabledTitles = SearchSection.all
        .where((s) => ctrl.state.isSectionEnabled(s.id))
        .map((s) => s.titleAr.tr)
        .toList();

    String sectionsText;
    if (enabledTitles.isEmpty) {
      sectionsText = 'المصادر المتاحة';
    } else if (enabledTitles.length == 1) {
      sectionsText = enabledTitles.first;
    } else if (enabledTitles.length == 2) {
      sectionsText = '${enabledTitles.first}، ثم ${enabledTitles.last}';
    } else {
      sectionsText =
          '${enabledTitles.take(enabledTitles.length - 1).join('، ')}، ثم ${enabledTitles.last}';
    }

    return 'أبحث عن **$query**...\n\n'
        'أفهم سؤالك جيداً. دعني أبحث لك في المصادر المتاحة وأجمع أفضل ما يتعلق بموضوعك.\n\n'
        'سأبدأ البحث في $sectionsText...\n\n'
        'النتائج ستظهر تباعاً فور العثور عليها...';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Midad header — replaces the generic AppBarWidget
// ─────────────────────────────────────────────────────────────────────────────
class _MidadHeader extends StatelessWidget {
  final Color primary;
  final Color surface;

  const _MidadHeader({required this.primary, required this.surface});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final ctrl = AiSearchController.instance;

    return Container(
      padding: EdgeInsets.only(top: topPad + 8, bottom: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: primary,
        border: Border(
          bottom: BorderSide(
            color: surface.withValues(alpha: 0.10),
          ),
        ),
      ),
      child: Row(
        children: [
          // ── Back button ──────────────────────────────────────────────────
          _HeaderBtn(
            onTap: () => Get.back(),
            child: Transform.flip(
              flipX: Directionality.of(context) == TextDirection.rtl,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: surface,
              ),
            ),
          ),
          const Gap(10),

          // ── Midad icon + title ───────────────────────────────────────────
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: const SizedBox().customSvgWithCustomColor(
                    SvgPath.svgHomeMidadIcon,
                    height: 28,
                    color: surface,
                  ),
                ),
                const Gap(8),
                Text(
                  'مداد',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: surface,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // ── Action buttons ───────────────────────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mode toggle
              Obx(() {
                final isAssistant =
                    ctrl.state.midasMode.value == MidasMode.assistant;
                return _HeaderBtn(
                  onTap: () => ctrl.state.midasMode.value =
                      isAssistant ? MidasMode.semantic : MidasMode.assistant,
                  child: const SizedBox().customSvgWithCustomColor(
                    isAssistant
                        ? SvgPath.svgHomeOffline
                        : SvgPath.svgHomeAiMcp,
                    height: 20,
                    color: surface,
                  ),
                );
              }),
              const Gap(6),
              // New conversation
              _HeaderBtn(
                onTap: () => ctrl.clearConversation(),
                child: const SizedBox().customSvgWithCustomColor(
                  SvgPath.svgHomeNewChat,
                  height: 20,
                  color: surface,
                ),
              ),
              const Gap(6),
              // History
              _HeaderBtn(
                onTap: () => customBottomSheet(const ChatHistorySheet()),
                child: const SizedBox().customSvgWithCustomColor(
                  SvgPath.svgHomeHistory,
                  height: 20,
                  color: surface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A compact square button used in the Midad header.
class _HeaderBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _HeaderBtn({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    final surface = context.theme.colorScheme.surface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: surface.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: surface.withValues(alpha: 0.14)),
        ),
        child: Center(child: child),
      ),
    );
  }
}
