// ─────────────────────────────────────────────────────────────────────────────
// FinanceLocalDatasource — all static Islamic finance content
// ─────────────────────────────────────────────────────────────────────────────

import '../models/finance_tip_model.dart';
import '../models/halal_haram_model.dart';

class FinanceLocalDatasource {
  // ── Daily Tips (rotates by day-of-year) ──────────────────────────────────
  static const List<Map<String, String>> dailyTips = [
    {
      'icon': '💰',
      'title': 'Save Before You Spend',
      'body':
          'The Prophet ﷺ said: "The upper hand is better than the lower hand." '
          'Set aside savings immediately when income arrives — before any expenses.',
    },
    {
      'icon': '📊',
      'title': 'Track Every Dirham',
      'body':
          'A Muslim will be asked about their wealth — how it was earned and how it was spent. '
          'Recording your expenses daily builds accountability and baraka.',
    },
    {
      'icon': '🤝',
      'title': 'Avoid Interest (Riba) Completely',
      'body':
          'Allah has permitted trade and forbidden Riba (Al-Baqarah 2:275). '
          'Even a small amount of interest is prohibited. Seek halal banking alternatives.',
    },
    {
      'icon': '🏦',
      'title': 'Build an Emergency Fund',
      'body':
          'Yusuf (AS) stored grain for 7 years of hardship. '
          'Aim to save 3–6 months of expenses as a halal emergency reserve.',
    },
    {
      'icon': '📈',
      'title': 'Invest in Halal Businesses',
      'body':
          'Your money should grow in ways that please Allah. '
          'Screen investments to avoid alcohol, gambling, weapons, and interest-based companies.',
    },
  ];

  // ── Finance Tips ──────────────────────────────────────────────────────────
  static const List<FinanceTipModel> tips = [
    // ── Saving ───────────────────────────────────────────────────────────────
    FinanceTipModel(
      id: 'tip_001',
      title: 'The 1/3 Rule of Islamic Spending',
      description:
          'Classical scholars advised dividing income into thirds: one-third for needs, '
          'one-third for savings, and one-third for charity.',
      fullContent:
          'The Prophet ﷺ advised moderation in all things, including spending. '
          'Dividing income into thirds — needs, savings, and charity — aligns with the '
          'Islamic principle of balance. This prevents extravagance (Israf) condemned in the Quran '
          '(Al-A\'raf 7:31) while ensuring financial security and fulfilling social obligations.',
      category: FinanceCategory.saving,
      readingTimeMinutes: 2,
      isFeatured: true,
      quranRef: 'Al-A\'raf 7:31',
    ),
    FinanceTipModel(
      id: 'tip_002',
      title: 'Saving for Hajj and Major Goals',
      description:
          'Saving specifically for Hajj, education, or a home is encouraged. '
          'Label your savings accounts by purpose to maintain clarity and intention.',
      fullContent:
          'Islam encourages planning for major life obligations. Setting up dedicated '
          'savings goals with clear intentions (niyyah) — such as Hajj, children\'s education, '
          'or buying a home without mortgage — transforms savings into an act of worship. '
          'The Prophet ﷺ praised those who plan for their families\' future.',
      category: FinanceCategory.saving,
      readingTimeMinutes: 2,
    ),
    FinanceTipModel(
      id: 'tip_003',
      title: 'Contentment (Qana\'ah) as Wealth',
      description:
          'The Prophet ﷺ said: "Richness is not having many possessions. '
          'Rather, true richness is the richness of the soul."',
      fullContent:
          'Qana\'ah — contentment with what Allah has provided — is considered one of the '
          'greatest forms of wealth in Islam. It does not mean laziness or lack of ambition; '
          'rather, it means not being enslaved by material desires. '
          'This mindset naturally leads to less spending and more saving.',
      category: FinanceCategory.saving,
      readingTimeMinutes: 2,
      hadithRef: 'Sahih al-Bukhari, Book 81, Hadith 453',
    ),

    // ── Budgeting ─────────────────────────────────────────────────────────────
    FinanceTipModel(
      id: 'tip_004',
      title: 'Zero-Based Budgeting the Islamic Way',
      description:
          'Assign every dirham a purpose before the month begins. '
          'Needs, wants, Zakat, Sadaqah, and savings — all planned intentionally.',
      fullContent:
          'Zero-based budgeting means your income minus all planned expenses equals zero — '
          'every dirham has a job. An Islamic zero-based budget starts by allocating Zakat '
          'and Sadaqah first, then essential needs, savings, and finally discretionary spending. '
          'This mirrors the prophetic guidance of prioritizing obligations before desires.',
      category: FinanceCategory.budgeting,
      readingTimeMinutes: 3,
    ),
    FinanceTipModel(
      id: 'tip_005',
      title: 'Avoid Israf (Extravagance)',
      description:
          'Allah says: "Indeed, the wasteful are brothers of the devils." '
          'Overspending is a spiritual problem as much as a financial one.',
      fullContent:
          '"And do not spend wastefully. Indeed, the wasteful are brothers of the devils, '
          'and ever has Satan been to his Lord ungrateful." — Al-Isra 17:26-27. '
          'Islamic budgeting is grounded in the principle of avoiding waste in food, clothing, '
          'entertainment, and lifestyle. Review monthly expenses to identify unnecessary items.',
      category: FinanceCategory.budgeting,
      readingTimeMinutes: 2,
      quranRef: 'Al-Isra 17:26-27',
    ),
    FinanceTipModel(
      id: 'tip_006',
      title: 'The 50/30/20 Halal Budget Framework',
      description:
          '50% needs, 20% savings & Zakat, 30% wants — '
          'a simple framework that keeps Islamic financial duties front and center.',
      fullContent:
          'A halal adaptation of the popular 50/30/20 rule puts necessities at 50%, '
          'savings, Zakat, and charity at 20%, and wants (halal entertainment, dining, gifts) '
          'at 30%. Unlike conventional finance, Zakat is treated as a non-negotiable '
          'obligation within the budget — not an optional expense.',
      category: FinanceCategory.budgeting,
      readingTimeMinutes: 3,
    ),

    // ── Investing ─────────────────────────────────────────────────────────────
    FinanceTipModel(
      id: 'tip_007',
      title: 'Shariah-Compliant Stock Screening',
      description:
          'Not all stocks are halal. Screen companies for Riba, alcohol, '
          'gambling, weapons, and pork before investing.',
      fullContent:
          'When investing in stocks, scholars have established screening criteria: '
          '(1) The company\'s primary business must be halal. '
          '(2) Debt-to-market-cap ratio should be below 33%. '
          '(3) Interest income should be below 5% of total revenue. '
          'Apps like Zoya and IslamicFinanceGuru offer automated halal stock screening.',
      category: FinanceCategory.investing,
      readingTimeMinutes: 3,
    ),
    FinanceTipModel(
      id: 'tip_008',
      title: 'Sukuk — Islamic Bonds',
      description:
          'Sukuk represent ownership in real assets, not debt. '
          'They provide returns without interest, making them halal alternatives to bonds.',
      fullContent:
          'Sukuk (Islamic bonds) are asset-backed securities that represent ownership '
          'in a tangible asset or project. Unlike conventional bonds that pay interest, '
          'Sukuk pay returns from the profit generated by the underlying asset. '
          'They are widely available in Muslim-majority countries and increasingly in the West.',
      category: FinanceCategory.investing,
      readingTimeMinutes: 3,
    ),
    FinanceTipModel(
      id: 'tip_009',
      title: 'Real Estate as a Halal Investment',
      description:
          'Property ownership is one of the most endorsed forms of wealth preservation '
          'in Islamic tradition — as long as it is purchased without Riba.',
      fullContent:
          'Real estate has always been a favored form of investment in Islamic culture. '
          'The Prophet ﷺ and his companions owned land and property. '
          'However, purchasing through an interest-bearing mortgage is problematic. '
          'Islamic mortgages (Murabaha, Diminishing Musharakah) offer Riba-free alternatives '
          'available through Islamic banks in many countries.',
      category: FinanceCategory.investing,
      readingTimeMinutes: 3,
    ),

    // ── Business ──────────────────────────────────────────────────────────────
    FinanceTipModel(
      id: 'tip_010',
      title: 'Honesty in Trade is Worship',
      description:
          '"The truthful, trustworthy merchant will be with the prophets, the truthful, '
          'and the martyrs." — Prophet Muhammad ﷺ',
      fullContent:
          'The Prophet ﷺ was himself a merchant before prophethood and praised honest '
          'trade extensively. An honest Muslim business owner who fulfills contracts, '
          'delivers what is promised, and treats employees fairly is performing a great act '
          'of worship. Business ethics in Islam include transparency, accurate measurement, '
          'and fair dealing.',
      category: FinanceCategory.business,
      readingTimeMinutes: 2,
      hadithRef: 'Sunan al-Tirmidhi, Hadith 1209',
    ),
    FinanceTipModel(
      id: 'tip_011',
      title: 'Mudarabah — Islamic Partnership Finance',
      description:
          'In Mudarabah, one partner provides capital while the other provides labor. '
          'Profits are shared; losses fall on the capital provider. A perfectly halal model.',
      fullContent:
          'Mudarabah is one of the oldest Islamic business structures, used by the Prophet ﷺ '
          'himself in his business dealings with Khadijah (RA). It aligns incentives: '
          'the capital provider shares in the profit but also bears the risk of loss, '
          'while the working partner loses their time and effort. '
          'Modern Islamic banks use this structure for investment accounts.',
      category: FinanceCategory.business,
      readingTimeMinutes: 3,
    ),

    // ── Zakat ─────────────────────────────────────────────────────────────────
    FinanceTipModel(
      id: 'tip_012',
      title: 'Zakat Purifies Your Wealth',
      description:
          '"Take from their wealth a charity by which you purify them." '
          '(At-Tawbah 9:103). Zakat is not a tax — it is purification.',
      fullContent:
          'Zakat is 2.5% of zakatable wealth held above the Nisab threshold for one lunar year. '
          'It purifies wealth spiritually and redistributes wealth economically. '
          'Many scholars say that a Muslim who pays Zakat regularly will find baraka '
          '(blessing) in the remaining wealth. Use the built-in Zakat Calculator to ensure '
          'you are paying the correct amount.',
      category: FinanceCategory.zakat,
      readingTimeMinutes: 2,
      quranRef: 'At-Tawbah 9:103',
    ),
    FinanceTipModel(
      id: 'tip_013',
      title: 'Sadaqah Jariyah — Ongoing Charity',
      description:
          'Recurring charity that continues after death. A water well, a school, '
          'a Quran shared — all generate rewards indefinitely.',
      fullContent:
          '"When a person dies, his deeds come to an end except for three: '
          'Sadaqah Jariyah (ongoing charity), knowledge which is beneficial, '
          'or a virtuous child who prays for him." — Sahih Muslim. '
          'Financial planning from an Islamic perspective includes allocating for '
          'Sadaqah Jariyah — investments in infrastructure, education, or endowments '
          'that outlive you.',
      category: FinanceCategory.zakat,
      readingTimeMinutes: 2,
      hadithRef: 'Sahih Muslim, Hadith 1631',
    ),

    // ── Debt ─────────────────────────────────────────────────────────────────
    FinanceTipModel(
      id: 'tip_014',
      title: 'The Prophet ﷺ Sought Refuge from Debt',
      description:
          'The Prophet ﷺ regularly said: "O Allah, I seek refuge in You from '
          'grief and sadness, and from debt and the dominance of men."',
      fullContent:
          'Debt was taken very seriously by the Prophet ﷺ — he even refused to pray '
          'over the body of a person who died in debt (until the debt was settled by companions). '
          'This does not mean all debt is forbidden; it means debt should be avoided when possible '
          'and paid immediately when incurred. Avoid lifestyle debt. Consider halal financing '
          'alternatives for major purchases.',
      category: FinanceCategory.debt,
      readingTimeMinutes: 2,
      hadithRef: 'Sahih al-Bukhari, Book 75, Hadith 380',
    ),
    FinanceTipModel(
      id: 'tip_015',
      title: 'Debt-Free Living as a Goal',
      description:
          'Islam does not prohibit all debt but strongly discourages excess. '
          'Create a debt elimination plan and make du\'a for relief.',
      fullContent:
          'If you are in debt, the Islamic approach is to: '
          '(1) Make sincere repentance and du\'a. '
          '(2) List all debts from smallest to largest. '
          '(3) Pay minimum on all; throw extra at the smallest (snowball method). '
          '(4) Avoid new debt. '
          '(5) Seek halal income increases. '
          'The Quran commands fulfilling financial obligations (Al-Baqarah 2:282).',
      category: FinanceCategory.debt,
      readingTimeMinutes: 3,
    ),

    // ── Family Finance ────────────────────────────────────────────────────────
    FinanceTipModel(
      id: 'tip_016',
      title: 'Islamic Inheritance (Meerath)',
      description:
          'Islam prescribes precise shares for family members in inheritance. '
          'Not having a valid Islamic will can lead to disputes and loss of rights.',
      fullContent:
          'The Quran (An-Nisa 4:11-12) prescribes detailed inheritance shares for '
          'spouses, children, parents, and siblings. Muslim families should: '
          '(1) Prepare an Islamic will (Wasiyyah). '
          '(2) Ensure it complies with local law. '
          '(3) Update it regularly. '
          'A maximum of 1/3 of the estate can be willed to non-heirs or charity.',
      category: FinanceCategory.family,
      readingTimeMinutes: 3,
      quranRef: 'An-Nisa 4:11-12',
    ),
    FinanceTipModel(
      id: 'tip_017',
      title: 'Teaching Children About Money in Islam',
      description:
          'Introduce children to halal earning, saving, giving Sadaqah, '
          'and avoiding waste from a young age.',
      fullContent:
          'The Prophet ﷺ taught companions\' children about generosity and earning. '
          'Practical steps: (1) Give children a small allowance and teach them to split it — '
          'saving, spending, and charity. (2) Involve them in Zakat calculation. '
          '(3) Take them to donate food or money. '
          '(4) Teach them the difference between wants and needs. '
          'Financial tarbiyah (upbringing) is part of Islamic parenting.',
      category: FinanceCategory.family,
      readingTimeMinutes: 2,
    ),
  ];

  // ── Halal practices ───────────────────────────────────────────────────────
  static const List<HalalHaramEntry> halalEntries = [
    HalalHaramEntry(
      title: 'Trade & Commerce (Bai\')',
      explanation:
          '"Allah has permitted trade and forbidden Riba." Buying and selling goods at '
          'agreed prices is a blessed activity when conducted honestly.',
      isHalal: true,
      reference: 'Al-Baqarah 2:275',
    ),
    HalalHaramEntry(
      title: 'Profit-Sharing (Mudarabah & Musharakah)',
      explanation:
          'Partnership contracts where profits and risks are shared equitably are fully '
          'permitted and encouraged in Islamic commercial law.',
      isHalal: true,
    ),
    HalalHaramEntry(
      title: 'Leasing (Ijarah)',
      explanation:
          'Renting assets — property, vehicles, equipment — and charging a fair rental fee '
          'is a halal and widely used alternative to interest-bearing loans.',
      isHalal: true,
    ),
    HalalHaramEntry(
      title: 'Zakat & Sadaqah',
      explanation:
          'Giving 2.5% of qualifying wealth as Zakat and voluntary charity purifies wealth '
          'and increases baraka. It is an act of worship, not merely a tax.',
      isHalal: true,
      reference: 'Al-Baqarah 2:261',
    ),
    HalalHaramEntry(
      title: 'Halal Stock Investing',
      explanation:
          'Owning shares in companies whose primary business is permissible — technology, '
          'healthcare, real estate, food (non-haram) — is permitted with appropriate screening.',
      isHalal: true,
    ),
    HalalHaramEntry(
      title: 'Gold & Silver Savings',
      explanation:
          'Holding physical gold and silver is a Sunnah-endorsed way to preserve wealth '
          'and is free from the counterparty risk of fiat currencies.',
      isHalal: true,
    ),
  ];

  // ── Haram practices ───────────────────────────────────────────────────────
  static const List<HalalHaramEntry> haramEntries = [
    HalalHaramEntry(
      title: 'Riba (Interest / Usury)',
      explanation:
          '"Allah has declared war on those who deal in Riba." All forms of interest — '
          'bank loans, credit card interest, interest-bearing savings — are strictly forbidden.',
      isHalal: false,
      reference: 'Al-Baqarah 2:278-279',
    ),
    HalalHaramEntry(
      title: 'Gambling (Maysir)',
      explanation:
          '"O you who believe! Intoxicants, gambling... are abominations from Satan\'s handiwork." '
          'Casinos, lotteries, sports betting, and speculative trading are all forbidden.',
      isHalal: false,
      reference: 'Al-Ma\'idah 5:90',
    ),
    HalalHaramEntry(
      title: 'Fraud & Deception (Gharar)',
      explanation:
          'Excessive uncertainty in contracts — selling what you do not own, '
          'hiding defects, or misleading buyers — is prohibited. Contracts must be transparent.',
      isHalal: false,
    ),
    HalalHaramEntry(
      title: 'Hoarding (Ihtikar)',
      explanation:
          'Stockpiling essential goods to drive up prices and profit from others\' hardship '
          'is condemned. The Prophet ﷺ cursed those who hoard.',
      isHalal: false,
      reference: 'Sahih Muslim, Hadith 1605',
    ),
    HalalHaramEntry(
      title: 'Investing in Haram Industries',
      explanation:
          'Profits from alcohol, tobacco, weapons, pork, pornography, or conventional '
          'banking (Riba-based) are impermissible regardless of how high the returns are.',
      isHalal: false,
    ),
    HalalHaramEntry(
      title: 'Bribery (Rishwah)',
      explanation:
          '"The curse of Allah is upon the one who gives a bribe and the one who '
          'takes it." All forms of corrupt payments are forbidden.',
      isHalal: false,
      reference: 'Sunan Abu Dawud, Hadith 3580',
    ),
  ];

  // ── Featured Quran & Hadith ───────────────────────────────────────────────
  static const List<Map<String, String>> scriptureCards = [
    {
      'type': 'quran',
      'arabic': 'وَأَحَلَّ اللَّهُ الْبَيْعَ وَحَرَّمَ الرِّبَا',
      'translation':
          '"Allah has permitted trade and forbidden Riba (interest)."',
      'reference': 'Al-Baqarah 2:275',
    },
    {
      'type': 'quran',
      'arabic':
          'مَّثَلُ الَّذِينَ يُنفِقُونَ أَمْوَالَهُمْ فِي سَبِيلِ اللَّهِ كَمَثَلِ حَبَّةٍ أَنبَتَتْ سَبْعَ سَنَابِلَ',
      'translation':
          '"The example of those who spend in the way of Allah is like a grain that '
          'grows seven spikes, in each spike a hundred grains..."',
      'reference': 'Al-Baqarah 2:261',
    },
    {
      'type': 'hadith',
      'arabic':
          'التَّاجِرُ الصَّدُوقُ الأَمِينُ مَعَ النَّبِيِّينَ وَالصِّدِّيقِينَ وَالشُّهَدَاء',
      'translation':
          '"The truthful, trustworthy merchant will be with the prophets, the truthful, '
          'and the martyrs (on the Day of Judgment)."',
      'reference': 'Sunan al-Tirmidhi, Hadith 1209',
    },
    {
      'type': 'hadith',
      'arabic':
          'مَا أَكَلَ أَحَدٌ طَعَامًا قَطُّ خَيْرًا مِنْ أَنْ يَأْكُلَ مِنْ عَمَلِ يَدِهِ',
      'translation':
          '"No one has ever eaten food that is better than eating from the work of '
          'his own hands."',
      'reference': 'Sahih al-Bukhari, Book 34, Hadith 286',
    },
  ];
}
