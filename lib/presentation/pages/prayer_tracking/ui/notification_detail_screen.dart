import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../adhan/widgets/adhan_theme.dart';
import '../bloc/notification_bloc.dart';
import '../data/models/notification_item.dart';

/// Full notification detail screen.
class NotificationDetailScreen extends StatelessWidget {
  final NotificationItem item;

  const NotificationDetailScreen({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdhanColors.bgGradientTop,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AdhanGradients.background),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _DetailAppBar(item: item),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _CategoryBadge(category: item.category),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AdhanColors.pureWhite,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Metadata row
                      _MetadataRow(item: item),
                      const SizedBox(height: 20),
                      // Gold divider
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AdhanColors.gold.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Full body
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AdhanColors.glassLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AdhanColors.glassDark),
                        ),
                        child: Text(
                          item.body,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AdhanColors.softWhite,
                            height: 1.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Action buttons
                      _ActionButtons(item: item),
                    ],
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

// ── App bar ───────────────────────────────────────────────────────────────────

class _DetailAppBar extends StatelessWidget {
  final NotificationItem item;
  const _DetailAppBar({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AdhanColors.glassMid,
                shape: BoxShape.circle,
                border: Border.all(color: AdhanColors.glassDark),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AdhanColors.softWhite,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Notification Detail',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AdhanColors.pureWhite,
            ),
          ),
          const Spacer(),
          // Read status indicator
          if (!item.isRead)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AdhanColors.emeraldGlow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AdhanColors.emeraldGlow.withValues(alpha: 0.5),
                ),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AdhanColors.emeraldGlow,
                  letterSpacing: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Category badge ────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final NotificationCategory category;
  const _CategoryBadge({required this.category});

  Color get _color {
    return switch (category) {
      NotificationCategory.prayerTime => AdhanColors.emeraldGlow,
      NotificationCategory.adhan => AdhanColors.goldLight,
      NotificationCategory.jumuah => const Color(0xFF4CAF50),
      NotificationCategory.quranReading => const Color(0xFF64B5F6),
      NotificationCategory.dhikr => const Color(0xFFCE93D8),
      NotificationCategory.dailyHadith => AdhanColors.gold,
      NotificationCategory.dailyAyah => AdhanColors.goldLight,
      NotificationCategory.ramadan => const Color(0xFFFF7043),
      NotificationCategory.islamicEvents => const Color(0xFF4DB6AC),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _color.withValues(alpha: 0.4), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                category.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Metadata row ──────────────────────────────────────────────────────────────

class _MetadataRow extends StatelessWidget {
  final NotificationItem item;
  const _MetadataRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.access_time_rounded,
          size: 13,
          color: AdhanColors.mutedWhite,
        ),
        const SizedBox(width: 5),
        Text(
          DateFormat('EEEE, d MMMM yyyy  •  HH:mm').format(item.receivedAt),
          style: const TextStyle(fontSize: 11, color: AdhanColors.mutedWhite),
        ),
      ],
    );
  }
}

// ── Action buttons ────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final NotificationItem item;
  const _ActionButtons({required this.item});

  @override
  Widget build(BuildContext context) {
    // We need a NotificationBloc above – it is provided by NotificationCenterScreen.
    // If navigated directly, we wrap defensively.
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (ctx, _) {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (!item.isRead && item.id != null)
              _ActionBtn(
                icon: Icons.done_rounded,
                label: 'Mark Read',
                color: AdhanColors.emeraldGlow,
                onTap: () {
                  ctx.read<NotificationBloc>().add(MarkReadEvent(item.id!));
                  Navigator.maybePop(ctx);
                },
              ),
            if (!item.isArchived && item.id != null)
              _ActionBtn(
                icon: Icons.archive_outlined,
                label: 'Archive',
                color: AdhanColors.goldLight,
                onTap: () {
                  ctx.read<NotificationBloc>().add(
                    ArchiveNotificationEvent(item.id!),
                  );
                  Navigator.maybePop(ctx);
                },
              ),
            if (item.id != null)
              _ActionBtn(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                color: const Color(0xFFEF5350),
                onTap: () {
                  ctx.read<NotificationBloc>().add(
                    DeleteNotificationEvent(item.id!),
                  );
                  Navigator.maybePop(ctx);
                },
              ),
            _ActionBtn(
              icon: Icons.copy_rounded,
              label: 'Copy',
              color: AdhanColors.mutedWhite,
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: '${item.title}\n\n${item.body}'),
                );
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
