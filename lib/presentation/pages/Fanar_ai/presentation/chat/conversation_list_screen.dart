// ConversationListScreen — theme-aware background, English UI.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/conversation.dart';
import '../viewmodel/fanar_chat_controller.dart';
import 'chat_screen.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  late final FanarChatController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = FanarChatController.instance;
    _ctrl.searchConversations('');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8B6914);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _ConversationHeader(
            cs: cs,
            goldColor: goldColor,
            onNewChat: () async {
              await _ctrl.startNewConversation();
              if (context.mounted) Get.off<void>(() => const ChatScreen());
            },
            onBack: Get.back,
          ),

          // ── Gold divider ─────────────────────────────────────────────────
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  goldColor.withValues(alpha: 0.6),
                  goldColor,
                  goldColor.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // ── Search bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: goldColor.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: TextStyle(
                  color: cs.onSurface,
                  fontFamily: 'kufi',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search conversations…',
                  hintStyle: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.35),
                    fontFamily: 'kufi',
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: goldColor.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 4,
                  ),
                ),
                onChanged: _ctrl.searchConversations,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ── Conversations list ────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              final convs = _ctrl.conversations.toList();
              if (convs.isEmpty) {
                return _EmptyState(goldColor: goldColor);
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                itemCount: convs.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: goldColor.withValues(alpha: 0.08),
                  indent: 64,
                ),
                itemBuilder: (context, index) {
                  final conv = convs[index];
                  final isActive =
                      _ctrl.activeConversation.value?.id == conv.id;
                  return _ConversationTile(
                    conversation: conv,
                    isActive: isActive,
                    goldColor: goldColor,
                    cs: cs,
                    isDark: isDark,
                    onTap: () async {
                      await _ctrl.openConversation(conv);
                      if (context.mounted) {
                        Get.off<void>(() => const ChatScreen());
                      }
                    },
                    onRename: () =>
                        _showRenameDialog(context, conv, goldColor, cs, isDark),
                    onDelete: () =>
                        _showDeleteDialog(context, conv, goldColor, cs, isDark),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    Conversation conv,
    Color goldColor,
    ColorScheme cs,
    bool isDark,
  ) {
    final textCtrl = TextEditingController(text: conv.title);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: goldColor.withValues(alpha: 0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.edit_outlined, color: goldColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Rename',
              style: TextStyle(
                color: goldColor,
                fontFamily: 'kufi',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: textCtrl,
          autofocus: true,
          style: TextStyle(color: cs.onSurface, fontFamily: 'kufi'),
          decoration: InputDecoration(
            hintText: 'Conversation title',
            hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: goldColor.withValues(alpha: 0.3)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: goldColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Cancel',
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.5),
                fontFamily: 'kufi',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final title = textCtrl.text.trim();
              if (title.isNotEmpty && conv.id != null) {
                _ctrl.renameConversation(conv.id!, title);
              }
              Get.back<void>();
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: goldColor,
                fontFamily: 'kufi',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Conversation conv,
    Color goldColor,
    ColorScheme cs,
    bool isDark,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Delete conversation?',
              style: TextStyle(
                color: Colors.redAccent,
                fontFamily: 'kufi',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          '"${conv.title}" and all its messages will be permanently deleted.',
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.7),
            fontFamily: 'kufi',
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Cancel',
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.5),
                fontFamily: 'kufi',
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (conv.id != null) await _ctrl.deleteConversation(conv.id!);
              if (context.mounted) Get.back<void>();
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontFamily: 'kufi',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({
    required this.cs,
    required this.goldColor,
    required this.onNewChat,
    required this.onBack,
  });

  final ColorScheme cs;
  final Color goldColor;
  final VoidCallback onNewChat;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 14,
        left: 8,
        right: 8,
      ),
      color: cs.surface,
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: goldColor,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Conversations',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontFamily: 'kufi',
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'المحادثات',
                  style: TextStyle(
                    color: goldColor.withValues(alpha: 0.5),
                    fontFamily: 'kufi',
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onNewChat,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: goldColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: goldColor.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.add_rounded, color: goldColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.goldColor});
  final Color goldColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: goldColor.withValues(alpha: 0.08),
              border: Border.all(color: goldColor.withValues(alpha: 0.2)),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 28,
              color: goldColor.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.5),
              fontFamily: 'kufi',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Start a new chat',
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.3),
              fontFamily: 'kufi',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Conversation tile ────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.isActive,
    required this.goldColor,
    required this.cs,
    required this.isDark,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  final Conversation conversation;
  final bool isActive;
  final Color goldColor;
  final ColorScheme cs;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? goldColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(color: goldColor.withValues(alpha: 0.3))
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: goldColor.withValues(alpha: isActive ? 0.2 : 0.08),
            border: Border.all(
              color: goldColor.withValues(alpha: isActive ? 0.5 : 0.2),
            ),
          ),
          child: Center(
            child: Text(
              _getInitial(conversation.title),
              style: TextStyle(
                color: goldColor,
                fontFamily: 'kufi',
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        title: Text(
          conversation.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isActive ? goldColor : cs.onSurface,
            fontFamily: 'kufi',
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          _formatDate(conversation.updatedAt),
          style: TextStyle(
            color: goldColor.withValues(alpha: 0.45),
            fontFamily: 'kufi',
            fontSize: 11,
          ),
        ),
        trailing: PopupMenuButton<String>(
          color: cs.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: goldColor.withValues(alpha: 0.2)),
          ),
          icon: Icon(
            Icons.more_horiz_rounded,
            color: goldColor.withValues(alpha: 0.5),
          ),
          onSelected: (val) {
            if (val == 'rename') onRename();
            if (val == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            PopupMenuItem<String>(
              value: 'rename',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, color: goldColor, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Rename',
                    style: TextStyle(color: cs.onSurface, fontFamily: 'kufi'),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Delete',
                    style: TextStyle(color: cs.onSurface, fontFamily: 'kufi'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitial(String title) =>
      title.isEmpty ? 'N' : title[0].toUpperCase();

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
