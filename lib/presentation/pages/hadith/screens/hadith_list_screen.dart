import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../core/services/services_locator.dart';
import '../../../controllers/general/general_controller.dart';
import '../controller/hadith_controller.dart';
import '../widgets/hadith_card.dart';

/// Shows the list of hadiths for a selected section.
///
/// M1 — Uses ScrollablePositionedList so we can both jump to the last-read
///      index and save the current visible index when the user leaves.
/// H3 — Search input calls ctrl.setSearchQuery() which debounces 300 ms.
/// H5 — Font-size slider is available from the AppBar.
class HadithListScreen extends StatefulWidget {
  final String bookSlug;
  final String sectionTitle;
  final int? sectionKey;

  const HadithListScreen({
    super.key,
    required this.bookSlug,
    required this.sectionTitle,
    this.sectionKey,
  });

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;
  bool _showFontSlider = false;

  // M1 — scroll controller that lets us jump to an index and read current pos
  final ItemScrollController _scrollCtrl = ItemScrollController();
  final ItemPositionsListener _posListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    final ctrl = HadithController.instance;
    ctrl.selectSection(widget.sectionKey);

    // M1 — jump to last-read index after first frame (list must be built first)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ctrl.lastReadBook == widget.bookSlug &&
          ctrl.lastReadSectionKey == widget.sectionKey) {
        final idx = ctrl.lastReadScrollIndex;
        if (idx > 0 && _scrollCtrl.isAttached) {
          _scrollCtrl.jumpTo(index: idx);
        }
      }
    });
  }

  @override
  void dispose() {
    // M1 — persist the topmost visible item index when the user leaves
    _saveScrollPosition();
    _searchCtrl.dispose();
    // Clear debounce + query on exit
    final ctrl = HadithController.instance;
    ctrl.state.searchDebounce?.cancel();
    ctrl.state.searchQuery.value = '';
    super.dispose();
  }

  void _saveScrollPosition() {
    final positions = _posListener.itemPositions.value;
    if (positions.isEmpty) return;
    final topIndex = positions
        .where((p) => p.itemLeadingEdge >= 0)
        .fold<int>(0, (min, p) => p.index < min ? p.index : min);
    HadithController.instance.saveLastRead(
      bookSlug: widget.bookSlug,
      sectionKey: widget.sectionKey,
      scrollIndex: topIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ctrl = HadithController.instance;
    final generalCtrl = sl<GeneralController>();

    return Scaffold(
      backgroundColor: cs.tertiary,
      appBar: AppBar(
        backgroundColor: cs.tertiary,
        elevation: 0,
        title: _showSearch
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontFamily: 'kufi',
                ),
                decoration: InputDecoration(
                  hintText: 'Search text or hadith number…',
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                    fontFamily: 'kufi',
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: ctrl.setSearchQuery,
              )
            : Text(
                widget.sectionTitle,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 16,
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        actions: [
          // H5 — font size toggle
          IconButton(
            tooltip: 'Font size',
            icon: Icon(Icons.text_fields_rounded, color: cs.primary, size: 22),
            onPressed: () => setState(() => _showFontSlider = !_showFontSlider),
          ),
          // Search toggle
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
              color: cs.primary,
            ),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchCtrl.clear();
                ctrl.state.searchDebounce?.cancel();
                ctrl.state.searchQuery.value = '';
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // H5 — animated font slider panel
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: _showFontSlider
                ? _FontSizePanel(ctrl: generalCtrl)
                : const SizedBox.shrink(),
          ),

          Expanded(
            child: Obx(() {
              final hadiths = ctrl.hadithsForCurrentSection;

              if (hadiths.isEmpty) {
                return Center(
                  child: Text(
                    'No hadiths found.',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                      fontSize: 15,
                    ),
                  ),
                );
              }

              // M1 — ScrollablePositionedList for position tracking/restoring
              return ScrollablePositionedList.builder(
                itemScrollController: _scrollCtrl,
                itemPositionsListener: _posListener,
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                itemCount: hadiths.length,
                itemBuilder: (context, i) => HadithCard(
                  hadith: hadiths[i],
                  index: i,
                  bookName: widget.bookSlug,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── H5 — Font size panel ──────────────────────────────────────────────────────

class _FontSizePanel extends StatelessWidget {
  final GeneralController ctrl;
  const _FontSizePanel({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 4),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Obx(() {
        final size = ctrl.state.fontSizeArabic.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.text_fields_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Arabic font size',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const Spacer(),
                Text(
                  'أ  ${size.round()}',
                  style: TextStyle(
                    fontFamily: 'naskh',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: cs.primary,
                inactiveTrackColor: cs.primary.withValues(alpha: 0.20),
                thumbColor: cs.primary,
                overlayColor: cs.primary.withValues(alpha: 0.15),
              ),
              child: Slider(
                value: size.clamp(14.0, 36.0),
                min: 14,
                max: 36,
                divisions: 22,
                onChanged: (v) => ctrl.state.fontSizeArabic.value = v,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'A',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 11,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    'A',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 18,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
