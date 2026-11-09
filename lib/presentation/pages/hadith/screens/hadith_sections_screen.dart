import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../controller/hadith_controller.dart';
import '../models/hadith.dart';
import 'hadith_list_screen.dart';

/// Shows all sections (chapters) of a loaded Hadith book.
///
/// M2 — replaces bare CircularProgressIndicator with a shimmer list skeleton
///      while the book JSON is parsing in the isolate.
class HadithSectionsScreen extends StatelessWidget {
  final String bookSlug;

  const HadithSectionsScreen({super.key, required this.bookSlug});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ctrl = HadithController.instance;

    return Scaffold(
      backgroundColor: cs.tertiary,
      appBar: AppBar(
        backgroundColor: cs.tertiary,
        elevation: 0,
        title: Text(
          ctrl.bookDisplayName(bookSlug),
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 18,
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.to(
              () => HadithListScreen(
                bookSlug: bookSlug,
                sectionTitle: ctrl.bookDisplayName(bookSlug),
                sectionKey: null,
              ),
              transition: Transition.rightToLeft,
            ),
            child: Text(
              'All',
              style: TextStyle(
                fontFamily: 'kufi',
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // M2 — shimmer while loading
        if (ctrl.isLoadingBook) {
          return _SectionShimmer();
        }

        final sections = ctrl.sections;
        final sectionDetails = ctrl.sectionDetails;

        final keys =
            sections.keys
                .where((k) => k != '0' && sections[k]!.isNotEmpty)
                .toList()
              ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

        if (keys.isEmpty) {
          return Center(
            child: Text(
              'No sections found.',
              style: TextStyle(
                fontFamily: 'kufi',
                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          itemCount: keys.length,
          itemBuilder: (context, i) {
            final key = keys[i];
            final title = sections[key] ?? '';
            final detail = sectionDetails[key];
            final count = detail != null
                ? detail.getHadithNumberDifference() + 1
                : 0;

            return _SectionTile(
              index: i,
              sectionNumber: int.tryParse(key) ?? (i + 1),
              title: title,
              hadithCount: count,
              onTap: () => Get.to(
                () => HadithListScreen(
                  bookSlug: bookSlug,
                  sectionTitle: title,
                  sectionKey: int.tryParse(key),
                ),
                transition: Transition.rightToLeft,
              ),
            );
          },
        );
      }),
    );
  }
}

// ── M2: Shimmer skeleton ──────────────────────────────────────────────────────

class _SectionShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE0E0E0);
    final highlightColor = isDark
        ? const Color(0xFF3A3A3A)
        : const Color(0xFFF5F5F5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        itemCount: 14,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // Circle placeholder (section number)
              Container(
                margin: const EdgeInsets.all(16),
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      margin: const EdgeInsets.only(right: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section tile ──────────────────────────────────────────────────────────────

class _SectionTile extends StatelessWidget {
  final int index;
  final int sectionNumber;
  final String title;
  final int hadithCount;
  final VoidCallback onTap;

  const _SectionTile({
    required this.index,
    required this.sectionNumber,
    required this.title,
    required this.hadithCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cs.secondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.12),
                border: Border.all(color: cs.primary.withValues(alpha: 0.30)),
              ),
              child: Center(
                child: Text(
                  '$sectionNumber',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  if (hadithCount > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$hadithCount hadiths',
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 11,
                        color: Theme.of(
                          context,
                        ).hintColor.withValues(alpha: 0.50),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.primary.withValues(alpha: 0.50),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
