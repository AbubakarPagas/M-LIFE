// Islamically-themed welcome screen — English UI, theme-aware background.

import 'dart:math' as math;

import 'package:flutter/material.dart';

class SuggestedPrompts extends StatefulWidget {
  const SuggestedPrompts({super.key, required this.onSelected});
  final ValueChanged<String> onSelected;

  @override
  State<SuggestedPrompts> createState() => _SuggestedPromptsState();
}

class _SuggestedPromptsState extends State<SuggestedPrompts>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  static const List<Map<String, dynamic>> _prompts = [
    {
      'icon': Icons.menu_book_rounded,
      'text': 'Explain a Quranic verse',
      'sub': 'Quran Tafsir',
    },
    {
      'icon': Icons.mosque_rounded,
      'text': 'Islamic ruling on a matter',
      'sub': 'Islamic Jurisprudence',
    },
    {
      'icon': Icons.auto_stories_rounded,
      'text': 'Share a Prophetic hadith',
      'sub': 'Sunnah & Hadith',
    },
    {
      'icon': Icons.history_edu_rounded,
      'text': 'Story from Islamic history',
      'sub': 'Seerah & History',
    },
    {
      'icon': Icons.favorite_rounded,
      'text': 'Daily supplications & dhikr',
      'sub': 'Adhkar',
    },
    {
      'icon': Icons.lightbulb_outline_rounded,
      'text': 'Question about Aqeedah',
      'sub': 'Islamic Creed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8B6914);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // ── Bismillah calligraphy ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: goldColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  top: BorderSide(
                    color: goldColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                style: TextStyle(
                  color: goldColor,
                  fontSize: 18,
                  fontFamily: 'naskh',
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),

            const SizedBox(height: 32),

            // ── Fanar AI logo ─────────────────────────────────────────────
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    goldColor.withValues(alpha: 0.25),
                    goldColor.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: goldColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: goldColor.withValues(alpha: 0.2),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(80, 80),
                    painter: _OctagonPainter(
                      color: goldColor.withValues(alpha: 0.3),
                    ),
                  ),
                  Text(
                    'ف',
                    style: TextStyle(
                      color: goldColor,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'kufi',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              'Fanar AI',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'kufi',
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            Text(
              'فنار الذكاء الاصطناعي',
              style: TextStyle(
                color: goldColor.withValues(alpha: 0.85),
                fontSize: 13,
                fontFamily: 'naskh',
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),

            const SizedBox(height: 4),

            Text(
              'Your intelligent Islamic companion',
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.45),
                fontSize: 12,
                fontFamily: 'kufi',
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 36),

            // ── Decorative separator ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          goldColor.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: goldColor.withValues(alpha: 0.6),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          goldColor.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              'Start a question or choose a topic',
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
                fontFamily: 'kufi',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // ── Prompt chips ──────────────────────────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.4,
              ),
              itemCount: _prompts.length,
              itemBuilder: (context, index) {
                final p = _prompts[index];
                return _PromptCard(
                  icon: p['icon'] as IconData,
                  label: p['text'] as String,
                  subtitle: p['sub'] as String,
                  goldColor: goldColor,
                  cs: cs,
                  onTap: () => widget.onSelected(p['text'] as String),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Octagon painter ─────────────────────────────────────────────────────────

class _OctagonPainter extends CustomPainter {
  const _OctagonPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final path = Path();
    const sides = 8;
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / sides;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Prompt card ─────────────────────────────────────────────────────────────

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.goldColor,
    required this.cs,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color goldColor;
  final ColorScheme cs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: goldColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: goldColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: goldColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontFamily: 'kufi',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: goldColor.withValues(alpha: 0.7),
                      fontFamily: 'kufi',
                      fontSize: 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
