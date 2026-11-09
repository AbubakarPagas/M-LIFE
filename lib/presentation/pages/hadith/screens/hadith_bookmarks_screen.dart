import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/hadith_controller.dart';
import '../helper/databasehelper.dart';
import '../widgets/hadith_card.dart';

/// Shows saved/bookmarked hadiths from the local SQLite database.
///
/// M3 — wrapped in RefreshIndicator so users can pull-to-refresh the list.
class HadithBookmarksScreen extends StatefulWidget {
  const HadithBookmarksScreen({super.key});

  @override
  State<HadithBookmarksScreen> createState() => _HadithBookmarksScreenState();
}

class _HadithBookmarksScreenState extends State<HadithBookmarksScreen> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final rows = await MyDatabaseHelper.instance.readHadithData();
    if (mounted) {
      setState(() {
        _rows = rows;
        _loading = false;
      });
    }
  }

  Future<void> _delete(Map<String, dynamic> row) async {
    final id = row[MyDatabaseHelper.columnId] as int;
    await MyDatabaseHelper.instance.deleteOneRow(
      MyDatabaseHelper.tableNameHadiths,
      id,
    );
    HadithController.instance.state.bookmarkedIds.remove(
      '${row[MyDatabaseHelper.columnBookName]}-'
      '${row[MyDatabaseHelper.columnHadithNumber]}-'
      '${row[MyDatabaseHelper.columnLanguage]}',
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    if (_rows.isEmpty) {
      // M3 — empty state is also wrapped so the user can pull to refresh
      return RefreshIndicator(
        color: cs.primary,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 60,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No bookmarks yet.',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 15,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pull down to refresh',
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).hintColor.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // M3 — RefreshIndicator wrapping the bookmarks list
    return RefreshIndicator(
      color: cs.primary,
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: _rows.length,
        itemBuilder: (context, i) {
          final row = _rows[i];
          return _BookmarkCard(
            row: row,
            index: i,
            onDelete: () => _delete(row),
          );
        },
      ),
    );
  }
}

// ── Bookmark card ─────────────────────────────────────────────────────────────

class _BookmarkCard extends StatelessWidget {
  final Map<String, dynamic> row;
  final int index;
  final VoidCallback onDelete;

  const _BookmarkCard({
    required this.row,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = HadithController.instance;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bookName = row[MyDatabaseHelper.columnBookName] as String? ?? '';
    final hadithNum = row[MyDatabaseHelper.columnHadithNumber];
    final textAra = row[MyDatabaseHelper.columnTextArabic] as String? ?? '';
    final text = row[MyDatabaseHelper.columnTextTranslated] as String? ?? '';
    final lang = row[MyDatabaseHelper.columnLanguage] as String? ?? '';

    final accentColor = kHadithPalettes[index % kHadithPalettes.length][0];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.30 : 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              color: cs.primary,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: kHadithGold.withValues(alpha: 0.40),
                      ),
                    ),
                    child: Text(
                      '#$hadithNum',
                      style: const TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ctrl.bookDisplayName(bookName),
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        Text(
                          ctrl.languageDisplayName(lang),
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _HBtn(
                    icon: Icons.copy_rounded,
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(
                          text:
                              '$textAra\n\n$text\n'
                              '— ${ctrl.bookDisplayName(bookName)} #$hadithNum',
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  _HBtn(
                    icon: Icons.share_rounded,
                    onTap: () {
                      SharePlus.instance.share(
                        ShareParams(
                          text:
                              '$textAra\n\n$text\n'
                              '— ${ctrl.bookDisplayName(bookName)} #$hadithNum',
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  _HBtn(icon: Icons.bookmark_remove_rounded, onTap: onDelete),
                ],
              ),
            ),
            _BMTextBlock(
              text: textAra,
              accentColor: accentColor,
              isArabic: true,
            ),
            if (text.isNotEmpty && text != textAra)
              _BMTextBlock(
                text: text,
                accentColor: accentColor,
                isArabic: false,
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _HBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.85),
          size: 15,
        ),
      ),
    );
  }
}

class _BMTextBlock extends StatelessWidget {
  final String text;
  final Color accentColor;
  final bool isArabic;

  const _BMTextBlock({
    required this.text,
    required this.accentColor,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(14, isArabic ? 14 : 8, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
      ),
      child: Text(
        text,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontFamily: isArabic ? 'naskh' : 'kufi',
          fontSize: isArabic ? 18 : 14,
          height: 2.0,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }
}
