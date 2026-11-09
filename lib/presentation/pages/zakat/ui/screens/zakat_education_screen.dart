// ─────────────────────────────────────────────────────────────────────────────
// ZakatEducationScreen — learn about Zakat with Quran verses & Hadith
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/zakat_geometric_painter.dart';

const Color _kGold = Color(0xffCDAD80);
const Color _kGoldDeep = Color(0xffCD9974);
const Color _kGreen = Color(0xff2E7D32);

class ZakatEducationScreen extends StatefulWidget {
  const ZakatEducationScreen({super.key});
  @override
  State<ZakatEducationScreen> createState() => _ZakatEducationScreenState();
}

class _ZakatEducationScreenState extends State<ZakatEducationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _sections.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  static const _sections = ['Basics', 'Nisab & Hawl', 'Recipients', 'FAQ'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.secondary,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ZakatGeometricPainter(
                color: isDark ? _kGold : cs.primary,
                opacity: 0.04,
              ),
            ),
          ),
          NestedScrollView(
            headerSliverBuilder: (ctx, _) => [
              SliverAppBar(
                pinned: true,
                backgroundColor: cs.secondary,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: cs.primary,
                    size: 20.r,
                  ),
                  onPressed: () => Navigator.maybePop(context),
                ),
                title: Text(
                  'Learn About Zakat',
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabDelegate(
                  TabBar(
                    controller: _tabs,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: cs.primary,
                    labelColor: cs.primary,
                    unselectedLabelColor: cs.primary.withValues(alpha: 0.35),
                    labelStyle: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12.sp,
                    ),
                    tabs: _sections.map((s) => Tab(text: s)).toList(),
                  ),
                  bg: cs.secondary,
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabs,
              children: const [
                _BasicsTab(),
                _NisabHawlTab(),
                _RecipientsTab(),
                _FaqTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tab;
  final Color bg;
  const _TabDelegate(this.tab, {required this.bg});
  @override
  double get minExtent => tab.preferredSize.height + 1;
  @override
  double get maxExtent => tab.preferredSize.height + 1;
  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlaps) =>
      Container(color: bg, child: tab);
  @override
  bool shouldRebuild(_TabDelegate old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — Basics
// ─────────────────────────────────────────────────────────────────────────────
class _BasicsTab extends StatelessWidget {
  const _BasicsTab();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      children: [
        const _QuranVerse(
          arabic:
              'وَأَقِيمُوا الصَّلَاةَ وَآتُوا الزَّكَاةَ وَارْكَعُوا مَعَ الرَّاكِعِينَ',
          translation:
              '"Establish prayer and give Zakat and bow with those who bow [in worship and obedience]."',
          reference: '— Al-Baqarah 2:43',
        ),
        SizedBox(height: 14.h),
        const _InfoCard(
          icon: Icons.help_outline_rounded,
          title: 'What is Zakat?',
          color: _kGold,
          body:
              'Zakat is one of the Five Pillars of Islam. It is a mandatory annual charity (2.5% of qualifying wealth) paid by eligible Muslims to purify their wealth and help those in need. The word "Zakat" means purification and growth.',
        ),
        SizedBox(height: 12.h),
        const _InfoCard(
          icon: Icons.person_outline_rounded,
          title: 'Who Must Pay Zakat?',
          color: _kGreen,
          body:
              'Every adult Muslim who:\n• Possesses wealth above the Nisab threshold\n• Has held that wealth for one lunar year (Hawl)\n• Is free and sane\n\nZakat is obligatory regardless of gender or nationality.',
        ),
        SizedBox(height: 12.h),
        const _InfoCard(
          icon: Icons.account_balance_wallet_rounded,
          title: 'What Wealth is Zakatable?',
          color: Color(0xff1565C0),
          body:
              '• Cash (home, bank, foreign currency)\n• Gold & Silver\n• Business inventory & trade goods\n• Stocks, investments & crypto\n• Agricultural produce\n• Livestock\n• Rental income & savings\n\nPersonal-use items (home, car, furniture) are NOT zakatable.',
        ),
        SizedBox(height: 12.h),
        const _HadithCard(
          arabic: 'بُنِيَ الإِسْلامُ عَلَى خَمْسٍ',
          text:
              '"Islam has been built upon five (pillars): the testimony that there is no god but Allah and that Muhammad is the Messenger of Allah, establishing the prayer, giving Zakat, Hajj to the House, and fasting in Ramadan."',
          reference: '— Sahih al-Bukhari, Book 2, Hadith 7',
        ),
        SizedBox(height: 40.h),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — Nisab & Hawl
// ─────────────────────────────────────────────────────────────────────────────
class _NisabHawlTab extends StatelessWidget {
  const _NisabHawlTab();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      children: [
        const _InfoCard(
          icon: Icons.balance_rounded,
          title: 'What is Nisab?',
          color: _kGold,
          body:
              'Nisab is the minimum amount of wealth a Muslim must possess before Zakat becomes obligatory. It is based on the value of:\n\n🥇 Gold Nisab: 85 grams of gold\n🥈 Silver Nisab: 595 grams of silver\n\nMost scholars use Gold Nisab. Using Silver Nisab results in a lower threshold, making more people eligible to pay Zakat (which benefits more recipients).',
        ),
        SizedBox(height: 12.h),
        const _InfoCard(
          icon: Icons.access_time_rounded,
          title: 'What is Hawl?',
          color: Color(0xff6A1B9A),
          body:
              'Hawl means one complete lunar year (354 days). Zakat is only due if your wealth has been at or above the Nisab threshold for a full lunar year.\n\nIf your wealth drops below Nisab at any point during the year, the Hawl resets.',
        ),
        SizedBox(height: 12.h),
        _NisabComparisonCard(),
        SizedBox(height: 12.h),
        const _HadithCard(
          arabic: 'لَيْسَ فِيمَا دُونَ خَمْسِ أَوَاقٍ صَدَقَةٌ',
          text:
              '"There is no Zakat on less than five awaq (of silver)." The Prophet ﷺ also specified the Nisab for gold and other assets.',
          reference: '— Sahih al-Bukhari, Book 24, Hadith 486',
        ),
        SizedBox(height: 40.h),
      ],
    );
  }
}

class _NisabComparisonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kGold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nisab Comparison',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: theme.hintColor,
            ),
          ),
          SizedBox(height: 12.h),
          const _NisabRow(
            metal: 'Gold',
            grams: '85g',
            color: _kGold,
            note: 'Higher threshold, stricter',
          ),
          SizedBox(height: 8.h),
          const _NisabRow(
            metal: 'Silver',
            grams: '595g',
            color: Color(0xff9E9E9E),
            note: 'Lower threshold, more inclusive',
          ),
          SizedBox(height: 12.h),
          Text(
            '💡 Both methods are valid. Many contemporary scholars recommend Gold Nisab as it is more conservative and prevents hardship.',
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 10.5.sp,
              color: theme.hintColor.withValues(alpha: 0.50),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NisabRow extends StatelessWidget {
  final String metal;
  final String grams;
  final Color color;
  final String note;
  const _NisabRow({
    required this.metal,
    required this.grams,
    required this.color,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Text(
          '$metal ($grams)',
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const Spacer(),
        Text(
          note,
          style: TextStyle(
            fontFamily: 'kufi',
            fontSize: 10.sp,
            color: Theme.of(context).hintColor.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 — Recipients
// ─────────────────────────────────────────────────────────────────────────────
class _RecipientsTab extends StatelessWidget {
  const _RecipientsTab();
  @override
  Widget build(BuildContext context) {
    const recipients = [
      (
        '1. The Poor (Al-Fuqara)',
        'Those who lack sufficient means to meet basic needs.',
        Icons.person_off_rounded,
        Color(0xffE53935),
      ),
      (
        '2. The Needy (Al-Masakin)',
        'Those who have some income but not enough to fulfill needs.',
        Icons.people_outline_rounded,
        Color(0xffF57C00),
      ),
      (
        '3. Zakat Collectors',
        'Those employed to administer and distribute Zakat.',
        Icons.manage_accounts_rounded,
        Color(0xff1565C0),
      ),
      (
        '4. New Muslims',
        'Those who have recently entered Islam and need support.',
        Icons.favorite_outline_rounded,
        Color(0xff2E7D32),
      ),
      (
        '5. Freeing Captives',
        'Historically for freeing slaves; today for prisoner aid.',
        Icons.lock_open_rounded,
        Color(0xff6A1B9A),
      ),
      (
        '6. Debtors',
        'Those overwhelmed by debt who cannot repay on their own.',
        Icons.money_off_rounded,
        Color(0xffCDAD80),
      ),
      (
        '7. In the Way of Allah',
        'Efforts for the cause of Allah, including education, dawah.',
        Icons.volunteer_activism_rounded,
        Color(0xff004D40),
      ),
      (
        '8. The Wayfarer',
        'Stranded travelers in need of assistance.',
        Icons.directions_walk_rounded,
        Color(0xff37474F),
      ),
    ];

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      children: [
        const _QuranVerse(
          arabic:
              'إِنَّمَا الصَّدَقَاتُ لِلْفُقَرَاءِ وَالْمَسَاكِينِ وَالْعَامِلِينَ عَلَيْهَا وَالْمُؤَلَّفَةِ قُلُوبُهُمْ وَفِي الرِّقَابِ وَالْغَارِمِينَ وَفِي سَبِيلِ اللَّهِ وَابْنِ السَّبِيلِ ۖ فَرِيضَةً مِّنَ اللَّهِ ۗ وَاللَّهُ عَلِيمٌ حَكِيمٌ',
          translation:
              '"Zakat expenditures are only for the poor and for the needy and for those employed to collect (Zakat) and for bringing hearts together (for Islam) and for freeing captives (or slaves) and for those in debt and for the cause of Allah and for the (stranded) traveler – an obligation (imposed) by Allah. And Allah is Knowing and Wise."',
          reference: '— At-Tawbah 9:60',
        ),
        SizedBox(height: 16.h),
        ...recipients.map(
          (r) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _RecipientTile(
              title: r.$1,
              desc: r.$2,
              icon: r.$3,
              color: r.$4,
            ),
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }
}

class _RecipientTile extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  const _RecipientTile({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 18.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  desc,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 11.sp,
                    color: theme.hintColor.withValues(alpha: 0.55),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 4 — FAQ
// ─────────────────────────────────────────────────────────────────────────────
class _FaqTab extends StatelessWidget {
  const _FaqTab();

  static const _faqs = [
    (
      'Can I give Zakat to non-Muslims?',
      'According to the majority of scholars, Zakat must be given to Muslims. However, voluntary Sadaqah can be given to anyone in need.',
    ),
    (
      'Can I pay Zakat in advance?',
      'Yes, most scholars allow paying Zakat in advance before the Hawl ends, as long as the Nisab has been reached.',
    ),
    (
      'Is Zakat due on retirement funds / 401k?',
      'Many scholars say yes, Zakat is due on accessible retirement funds. For locked funds, Zakat may be paid when accessed. Consult a scholar for your situation.',
    ),
    (
      'What if I missed Zakat in previous years?',
      'You should calculate and pay the missed Zakat as soon as possible. Repent to Allah and make up what was missed.',
    ),
    (
      'Can a husband give Zakat to his wife?',
      'Generally, a husband cannot give Zakat to his wife since he is financially responsible for her. However, a wife can give Zakat to her husband if he is in need.',
    ),
    (
      'Is business real estate zakatable?',
      'Real estate used for trade or rent is zakatable on its rental income or market value. Personal-use property is not zakatable.',
    ),
    (
      'How is Zakat on stocks calculated?',
      'For trading stocks: 2.5% of the full market value. For long-term investment stocks: 2.5% of dividend income or a portion of the company\'s zakatable assets.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      children: [
        ..._faqs.map(
          (f) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _FaqTile(question: f.$1, answer: f.$2),
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: _open
                ? cs.primary.withValues(alpha: 0.35)
                : cs.primary.withValues(alpha: isDark ? 0.10 : 0.07),
            width: _open ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: TextStyle(
                      fontFamily: 'kufi',
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.hintColor,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: cs.primary,
                    size: 22.r,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Text(
                  widget.answer,
                  style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: 11.5.sp,
                    color: theme.hintColor.withValues(alpha: 0.58),
                    height: 1.55,
                  ),
                ),
              ),
              crossFadeState: _open
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────
class _QuranVerse extends StatelessWidget {
  final String arabic;
  final String translation;
  final String reference;
  const _QuranVerse({
    required this.arabic,
    required this.translation,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.08),
            theme.colorScheme.primary.withValues(alpha: isDark ? 0.10 : 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kGold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kGoldDeep, _kGold]),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 14.r,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Quran',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 11.sp,
                  color: _kGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'naskh',
              fontSize: 14.sp,
              color: theme.hintColor,
              height: 1.8,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            translation,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 11.sp,
              color: theme.hintColor.withValues(alpha: 0.60),
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            reference,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: _kGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  final String arabic;
  final String text;
  final String reference;
  const _HadithCard({
    required this.arabic,
    required this.text,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote_rounded, color: cs.primary, size: 18.r),
              SizedBox(width: 8.w),
              Text(
                'Hadith',
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 11.sp,
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'naskh',
              fontSize: 13.sp,
              color: theme.hintColor,
              height: 1.7,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 11.sp,
              color: theme.hintColor.withValues(alpha: 0.58),
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            reference,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String body;
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.20 : 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: color, size: 18.r),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'kufi',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            body,
            style: TextStyle(
              fontFamily: 'kufi',
              fontSize: 12.sp,
              color: theme.hintColor.withValues(alpha: 0.60),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
