import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/hadith_controller.dart';
import '../models/hadith.dart';
import '../widgets/hadith_card.dart';

/// M6 — Global search screen.
///
/// Searches across ALL hadiths in the currently-loaded book (all sections).
/// If no book is loaded the user is prompted to select one from the Books tab.
/// Uses a 300ms debounce and shows result count.
class HadithGlobalSearchScreen extends StatefulWidget {
  const HadithGlobalSearchScreen({super.key});

  @override
  State<HadithGlobalSearchScreen> createState() =>
      _HadithGlobalSearchScreenState();
}

class _HadithGlobalSearchScreenState extends State<HadithGlobalSearchScreen> {
  final TextEditingController _queryCtrl = TextEditingController();
  Timer? _debounce;
  List<Hadith> _results = [];
  String _committedQuery = '';
  bool _hasSearched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _queryCtrl.dispose();
    super.dispose();
  }

  void _onChanged(String raw) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final ctrl = HadithController.instance;
      final results = ctrl.globalSearch(raw);
      if (mounted) {
        setState(() {
          _results = results;
          _committedQuery = raw;
          _hasSearched = raw.trim().isNotEmpty;
        });
      }
    });
  }

  void _clear() {
    _debounce?.cancel();
    _queryCtrl.clear();
    setState(() {
      _results = [];
      _committedQuery = '';
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ctrl = HadithController.instance;
    final bookLoaded = ctrl.currentBook != null;
    final bookName = bookLoaded
        ? ctrl.bookDisplayName(ctrl.state.currentBookName.value)
        : '';

    return Scaffold(
      backgroundColor: cs.tertiary,
      appBar: AppBar(
        backgroundColor: cs.tertiary,
        elevation: 0,
        title: TextField(
          controller: _queryCtrl,
          autofocus: true,
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontFamily: 'kufi',
          ),
          decoration: InputDecoration(
            hintText: bookLoaded
                ? 'Search in $bookName…'
                : 'Load a book first, then search…',
            hintStyle: TextStyle(
              color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              fontFamily: 'kufi',
              fontSize: 13,
            ),
            border: InputBorder.none,
            suffixIcon: _queryCtrl.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: cs.primary),
                    onPressed: _clear,
                  )
                : null,
          ),
          onChanged: bookLoaded ? _onChanged : null,
          enabled: bookLoaded,
        ),
      ),
      body: bookLoaded ? _buildBody(context, cs) : _buildNoBookBody(context),
    );
  }

  Widget _buildNoBookBody(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Theme.of(context).hintColor.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              'No book loaded',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Go to the Books tab, open a collection, then come back here to search across all its hadiths.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 13,
                color: Theme.of(context).hintColor.withValues(alpha: 0.55),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text(
                'Back to Books',
                style: TextStyle(fontFamily: 'kufi', fontSize: 14),
              ),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme cs) {
    // Initial state — no query yet
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.manage_search_rounded,
              size: 56,
              color: cs.primary.withValues(alpha: 0.30),
            ),
            const SizedBox(height: 12),
            Text(
              'Type to search',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 15,
                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Searches text and hadith number',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 12,
                color: Theme.of(context).hintColor.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      );
    }

    // No results
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 52,
              color: Theme.of(context).hintColor.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            Text(
              'No hadiths found for',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 14,
                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '"$_committedQuery"',
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ],
        ),
      );
    }

    // Results
    final bookName = HadithController.instance.state.currentBookName.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Result count banner
        Container(
          margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 15,
                color: cs.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${_results.length} result${_results.length == 1 ? '' : 's'}'
                ' for "$_committedQuery"',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 12,
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: _results.length,
            itemBuilder: (context, i) =>
                HadithCard(hadith: _results[i], index: i, bookName: bookName),
          ),
        ),
      ],
    );
  }
}
