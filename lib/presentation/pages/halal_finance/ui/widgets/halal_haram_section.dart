// ─────────────────────────────────────────────────────────────────────────────
// HalalHaramSection — expandable halal / haram practices cards
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/halal_haram_model.dart';

const Color _kGold = Color(0xffCDAD80);
const Color _kGreen = Color(0xff1A5C45);
const Color _kGreenLight = Color(0xff2E8B57);
const Color _kRed = Color(0xffC62828);
const Color _kRedLight = Color(0xffE53935);

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
        _SectionHeader(
          icon: Icons.balance_rounded,
          title: 'Halal vs Haram',
          subtitle: 'Islamic financial practices explained',
        ),
        SizedBox(height: 14.h),
        _ExpandableCard(
          isHalal: true,
          entries: halalEntries,
        ),
        SizedBox(height: 10.h),
        _ExpandableCard(
          isHalal: false,
          entries: haramEntries,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expandable card
// ─────────────────────────────────────────────────────────────────────────────
class _ExpandableCard extends StatefulWidget {
  final bool isHalal;
  final List<HalalHaramEntry> entries;

  const _ExpandableCard({
    required this.isHalal,
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

  Color get _primary => widget.isHalal ? _kGreen : _kRed;
  Color get _secondary => widget.isHalal ? _kGreenLight : _kRedLight;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rotate = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _anim.forward() : _anim.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: _expanded
              ? _primary.withValues(alpha: isDark ? 0.32 : 0.22)
              : _primary.withValues(alpha: isDark ? 0.14 : 0.09),
          width: _expanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(
              alpha: _expanded ? (isDark ? 0.10 : 0.06) : 0.02,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _primary.withValues(alpha: isDark ? 0.30 : 0.15),
                          _secondary.withValues(alpha: isDark ? 0.18 : 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(13.r),
                      border: Border.all(
                        color:
                            _primary.withValues(alpha: isDark ? 0.22 : 0.14),
                      ),
                    ),
                    child: Icon(
                      widget.isHalal
                          ? Icons.check_circle_outline_rounded
                          : Icons.cancel_outlined,
                      color: _primary,
                      size: 19.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isHalal
                              ? 'Halal Practices'
                              : 'Haram Practices',
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          widget.isHalal
                              ? '${widget.entries.length} permitted activities'
                              : '${widget.entries.length} prohibited activities',
                          style: TextStyle(
                            fontFamily: 'kufi',
                            fontSize: 10.sp,
                            color: theme.hintColor.withValues(alpha: 0.42),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: isDark ? 0.12 : 0.07),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: RotationTransition(
                      turns: _rotate,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _primary.withValues(alpha: 0.70),
                        size: 20.r,
                      ),
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
                Divider(
                  height: 1,
                  color: _primary.withValues(alpha: 0.10),
                ),
                ...widget.entries.asMap().entries.map((e) {
                  return _EntryTile(
                    entry: e.value,
                    color: _primary,
                    showDivider: e.key < widget.entries.length - 1,
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

// ─────────────────────────────────────────────────────────────────────────────
// Entry tile
// ─────────────────────────────────────────────────────────────────────────────
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
                width: 8.r,
                height: 8.r,
                margin: EdgeInsets.only(top: 4.h),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
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
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 10.r,
                            color: color.withValues(alpha: 0.60),
                          ),
                          SizedBox(width: 4.w),
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
            indent: 34.w,
            endIndent: 16.w,
            color: cs.primary.withValues(alpha: 0.06),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────
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
            color: _kGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: _kGold, size: 17.r),
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
