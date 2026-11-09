// ─────────────────────────────────────────────────────────────────────────────
// HalalHaramSection — two expandable cards for halal / haram practices
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/halal_haram_model.dart';

const Color _kGreen = Color(0xff2E7D32);
const Color _kRed = Color(0xffC62828);

class HalalHaramSection extends StatelessWidget {
  final List<HalalHaramEntry> halalEntries;
  final List<HalalHaramEntry> haramEntries;

  const HalalHaramSection({
    super.key,
    required this.halalEntries,
    required this.haramEntries,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          icon: Icons.balance_rounded,
          title: 'Halal vs Haram',
          subtitle: 'Islamic financial practices explained',
        ),
        SizedBox(height: 12.h),
        _ExpandableCard(
          title: '✅ Halal Practices',
          subtitle: '${halalEntries.length} permitted activities',
          headerColor: _kGreen,
          entries: halalEntries,
        ),
        SizedBox(height: 10.h),
        _ExpandableCard(
          title: '❌ Haram Practices',
          subtitle: '${haramEntries.length} prohibited activities',
          headerColor: _kRed,
          entries: haramEntries,
        ),
      ],
    );
  }
}

class _ExpandableCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color headerColor;
  final List<HalalHaramEntry> entries;

  const _ExpandableCard({
    required this.title,
    required this.subtitle,
    required this.headerColor,
    required this.entries,
  });

  @override
  State<_ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<_ExpandableCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _anim;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rotate = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final color = widget.headerColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: _expanded
              ? color.withValues(alpha: isDark ? 0.35 : 0.25)
              : color.withValues(alpha: isDark ? 0.15 : 0.10),
          width: _expanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(
              alpha: _expanded ? (isDark ? 0.10 : 0.06) : 0.02,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.18 : 0.10),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      widget.title.startsWith('✅')
                          ? Icons.check_circle_outline_rounded
                          : Icons.cancel_outlined,
                      color: color,
                      size: 19.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 10.sp,
                            color: theme.hintColor.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: _rotate,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: color.withValues(alpha: 0.60),
                      size: 22.r,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Entries ───────────────────────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, color: color.withValues(alpha: 0.12)),
                ...widget.entries.asMap().entries.map((e) {
                  final isLast = e.key == widget.entries.length - 1;
                  return _EntryTile(
                    entry: e.value,
                    color: color,
                    showDivider: !isLast,
                  );
                }),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final HalalHaramEntry entry;
  final Color color;
  final bool showDivider;

  const _EntryTile({
    required this.entry,
    required this.color,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 7.r,
                height: 7.r,
                margin: EdgeInsets.only(top: 5.h),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.hintColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      entry.explanation,
                      style: TextStyle(
                        fontFamily: 'kufi',
                        fontSize: 11.sp,
                        color: theme.hintColor.withValues(alpha: 0.55),
                        height: 1.55,
                      ),
                    ),
                    if (entry.reference != null) ...[
                      SizedBox(height: 5.h),
                      Text(
                        entry.reference!,
                        style: TextStyle(
                          fontFamily: 'kufi',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: color.withValues(alpha: 0.70),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 33.w,
            endIndent: 16.w,
            color: cs.primary.withValues(alpha: 0.06),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: cs.primary, size: 17.r),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: theme.hintColor,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'kufi',
                fontSize: 10.sp,
                color: theme.hintColor.withValues(alpha: 0.42),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
