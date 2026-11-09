import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../adhan/widgets/adhan_theme.dart';
import '../bloc/notification_bloc.dart';
import '../data/models/notification_item.dart';
import 'notification_detail_screen.dart';

/// Notification Center — shows all saved Islamic reminders grouped by time.
class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationBloc()..add(LoadNotificationsEvent()),
      child: const _NotifCenterView(),
    );
  }
}

class _NotifCenterView extends StatefulWidget {
  const _NotifCenterView();

  @override
  State<_NotifCenterView> createState() => _NotifCenterViewState();
}

class _NotifCenterViewState extends State<_NotifCenterView> {
  final _searchCtrl = TextEditingController();
  NotificationCategory? _activeFilter;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter(BuildContext ctx, {NotificationCategory? category}) {
    setState(() => _activeFilter = category);
    ctx.read<NotificationBloc>().add(
      FilterNotificationsEvent(
        category: category,
        searchQuery: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
      ),
    );
  }

  void _applySearch(BuildContext ctx, String query) {
    ctx.read<NotificationBloc>().add(
      FilterNotificationsEvent(
        category: _activeFilter,
        searchQuery: query.isEmpty ? null : query,
      ),
    );
  }

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
                _AppBar(
                  showSearch: _showSearch,
                  searchCtrl: _searchCtrl,
                  onSearchToggle: () {
                    setState(() => _showSearch = !_showSearch);
                    if (!_showSearch) {
                      _searchCtrl.clear();
                      _applySearch(context, '');
                    }
                  },
                  onSearchChanged: (q) => _applySearch(context, q),
                  onMarkAll: () =>
                      context.read<NotificationBloc>().add(MarkAllReadEvent()),
                  onDeleteAll: () => _confirmDeleteAll(context),
                ),
                _FilterChips(
                  active: _activeFilter,
                  onSelect: (cat) => _applyFilter(context, category: cat),
                ),
                Expanded(
                  child: BlocBuilder<NotificationBloc, NotificationState>(
                    builder: (ctx, state) {
                      if (state is NotificationLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AdhanColors.emeraldGlow,
                          ),
                        );
                      }
                      if (state is NotificationError) {
                        return _EmptyState(message: state.message);
                      }
                      if (state is! NotificationLoaded) {
                        return const SizedBox.shrink();
                      }
                      if (state.items.isEmpty) {
                        return const _EmptyState(
                          message: 'No notifications yet',
                          icon: Icons.notifications_off_outlined,
                        );
                      }
                      return _NotifList(
                        grouped: state.grouped,
                        unreadCount: state.unreadCount,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AdhanColors.bgGradientMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete All Notifications',
          style: TextStyle(color: AdhanColors.pureWhite, fontSize: 16),
        ),
        content: const Text(
          'This will permanently delete all notification history.',
          style: TextStyle(color: AdhanColors.mutedWhite, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AdhanColors.mutedWhite),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              ctx.read<NotificationBloc>().add(DeleteAllNotificationsEvent());
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFEF5350)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final bool showSearch;
  final TextEditingController searchCtrl;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onMarkAll;
  final VoidCallback onDeleteAll;

  const _AppBar({
    required this.showSearch,
    required this.searchCtrl,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.onMarkAll,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              // Back
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
              // Unread badge + title
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (_, state) {
                  final unread = state is NotificationLoaded
                      ? state.unreadCount
                      : 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Notification Center',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AdhanColors.pureWhite,
                            ),
                          ),
                          if (unread > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AdhanColors.emeraldGlow,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$unread',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AdhanColors.pureWhite,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (unread > 0)
                        Text(
                          '$unread unread',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AdhanColors.mutedWhite,
                          ),
                        ),
                    ],
                  );
                },
              ),
              const Spacer(),
              // Actions
              _IconBtn(
                icon: showSearch ? Icons.search_off : Icons.search,
                onTap: onSearchToggle,
              ),
              const SizedBox(width: 6),
              _OverflowMenu(onMarkAll: onMarkAll, onDeleteAll: onDeleteAll),
            ],
          ),
          // Search bar
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: showSearch
                ? Padding(
                    key: const ValueKey('search'),
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AdhanColors.glassMid,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdhanColors.glassDark),
                      ),
                      child: TextField(
                        controller: searchCtrl,
                        onChanged: onSearchChanged,
                        style: const TextStyle(
                          color: AdhanColors.pureWhite,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search notifications…',
                          hintStyle: TextStyle(color: AdhanColors.mutedWhite),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AdhanColors.mutedWhite,
                            size: 18,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('no-search')),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AdhanColors.glassMid,
          shape: BoxShape.circle,
          border: Border.all(color: AdhanColors.glassDark),
        ),
        child: Icon(icon, size: 16, color: AdhanColors.softWhite),
      ),
    );
  }
}

class _OverflowMenu extends StatelessWidget {
  final VoidCallback onMarkAll;
  final VoidCallback onDeleteAll;
  const _OverflowMenu({required this.onMarkAll, required this.onDeleteAll});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AdhanColors.bgGradientMid,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AdhanColors.glassMid,
          shape: BoxShape.circle,
          border: Border.all(color: AdhanColors.glassDark),
        ),
        child: const Icon(
          Icons.more_vert,
          size: 16,
          color: AdhanColors.softWhite,
        ),
      ),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'mark_all',
          child: Row(
            children: [
              Icon(Icons.done_all, color: AdhanColors.emeraldGlow, size: 18),
              SizedBox(width: 10),
              Text(
                'Mark all as read',
                style: TextStyle(color: AdhanColors.pureWhite, fontSize: 13),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete_all',
          child: Row(
            children: [
              Icon(
                Icons.delete_sweep_outlined,
                color: Color(0xFFEF5350),
                size: 18,
              ),
              SizedBox(width: 10),
              Text(
                'Delete all',
                style: TextStyle(color: Color(0xFFEF5350), fontSize: 13),
              ),
            ],
          ),
        ),
      ],
      onSelected: (v) {
        if (v == 'mark_all') onMarkAll();
        if (v == 'delete_all') onDeleteAll();
      },
    );
  }
}

// ── Category filter chips ─────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final NotificationCategory? active;
  final ValueChanged<NotificationCategory?> onSelect;

  const _FilterChips({required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const cats = NotificationCategory.values;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _Chip(
              label: 'All',
              emoji: '🔔',
              isActive: active == null,
              onTap: () => onSelect(null),
            ),
          ),
          ...cats.map(
            (c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: c.label,
                emoji: c.emoji,
                isActive: active == c,
                onTap: () => onSelect(active == c ? null : c),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isActive;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.emoji,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AdhanColors.emeraldMid.withValues(alpha: 0.4)
              : AdhanColors.glassLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AdhanColors.emeraldGlow.withValues(alpha: 0.6)
                : AdhanColors.glassDark,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive
                    ? AdhanColors.emeraldGlow
                    : AdhanColors.mutedWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification list ─────────────────────────────────────────────────────────

class _NotifList extends StatelessWidget {
  final Map<String, List<NotificationItem>> grouped;
  final int unreadCount;

  const _NotifList({required this.grouped, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      physics: const BouncingScrollPhysics(),
      children: grouped.entries.expand((entry) {
        return [
          _BucketHeader(label: entry.key),
          const SizedBox(height: 6),
          ...entry.value.map((item) => _NotifCard(item: item)),
          const SizedBox(height: 12),
        ];
      }).toList(),
    );
  }
}

class _BucketHeader extends StatelessWidget {
  final String label;
  const _BucketHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AdhanColors.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AdhanColors.goldLight,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationItem item;
  const _NotifCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;

    return GestureDetector(
      onTap: () {
        // Mark as read
        if (isUnread && item.id != null) {
          context.read<NotificationBloc>().add(MarkReadEvent(item.id!));
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationDetailScreen(item: item),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isUnread
              ? AdhanColors.emeraldMid.withValues(alpha: 0.12)
              : AdhanColors.glassLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnread
                ? AdhanColors.emeraldGlow.withValues(alpha: 0.35)
                : AdhanColors.glassDark,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon bubble
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AdhanColors.glassMid,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnread
                        ? AdhanColors.emeraldGlow.withValues(alpha: 0.4)
                        : AdhanColors.glassDark,
                  ),
                ),
                child: Center(
                  child: Text(
                    item.category.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isUnread
                                  ? AdhanColors.pureWhite
                                  : AdhanColors.softWhite,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: const BoxDecoration(
                              color: AdhanColors.emeraldGlow,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.body,
                      style: TextStyle(
                        fontSize: 11,
                        color: AdhanColors.mutedWhite.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AdhanColors.glassMid,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category.label,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AdhanColors.mutedWhite,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTime(item.receivedAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AdhanColors.mutedWhite,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Swipe actions
              const SizedBox(width: 6),
              _CardActions(item: item),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('d MMM').format(dt);
  }
}

class _CardActions extends StatelessWidget {
  final NotificationItem item;
  const _CardActions({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (item.id != null) {
              context.read<NotificationBloc>().add(
                ArchiveNotificationEvent(item.id!),
              );
            }
          },
          child: const Icon(
            Icons.archive_outlined,
            size: 16,
            color: AdhanColors.mutedWhite,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            if (item.id != null) {
              context.read<NotificationBloc>().add(
                DeleteNotificationEvent(item.id!),
              );
            }
          },
          child: const Icon(
            Icons.delete_outline,
            size: 16,
            color: Color(0xFFEF5350),
          ),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyState({required this.message, this.icon = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AdhanColors.glassDark),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 15, color: AdhanColors.mutedWhite),
          ),
        ],
      ),
    );
  }
}
