// ─────────────────────────────────────────────────────────────────────────────
// FinanceTipModel — a single Islamic finance tip
// ─────────────────────────────────────────────────────────────────────────────

class FinanceTipModel {
  final String id;
  final String title;
  final String description;
  final String fullContent;
  final FinanceCategory category;
  final int readingTimeMinutes;
  final bool isBookmarked;
  final bool isFeatured;
  final String? quranRef; // e.g. "Al-Baqarah 2:275"
  final String? hadithRef; // brief citation

  const FinanceTipModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fullContent,
    required this.category,
    this.readingTimeMinutes = 2,
    this.isBookmarked = false,
    this.isFeatured = false,
    this.quranRef,
    this.hadithRef,
  });

  FinanceTipModel copyWith({bool? isBookmarked}) => FinanceTipModel(
    id: id,
    title: title,
    description: description,
    fullContent: fullContent,
    category: category,
    readingTimeMinutes: readingTimeMinutes,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    isFeatured: isFeatured,
    quranRef: quranRef,
    hadithRef: hadithRef,
  );
}

enum FinanceCategory {
  all,
  saving,
  budgeting,
  investing,
  business,
  zakat,
  debt,
  family;

  String get label => switch (this) {
    FinanceCategory.all => 'All',
    FinanceCategory.saving => 'Saving',
    FinanceCategory.budgeting => 'Budgeting',
    FinanceCategory.investing => 'Investing',
    FinanceCategory.business => 'Business',
    FinanceCategory.zakat => 'Zakat',
    FinanceCategory.debt => 'Debt',
    FinanceCategory.family => 'Family',
  };
}
