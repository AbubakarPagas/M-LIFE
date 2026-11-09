// MessageBubble — theme-aware background, English context menu.

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/chat_message.dart';
import '../viewmodel/fanar_chat_controller.dart';
import 'markdown_renderer.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.isLastAssistant = false,
  });

  final ChatMessage message;
  final bool isLastAssistant;

  bool get _isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Row(
        mainAxisAlignment: _isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isUser) ...[
            _AiAvatar(isDark: isDark),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: _BubbleBody(
              message: message,
              isLastAssistant: isLastAssistant,
              isDark: isDark,
            ),
          ),
          if (_isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ─── AI Avatar ────────────────────────────────────────────────────────────────

class _AiAvatar extends StatelessWidget {
  const _AiAvatar({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final goldColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8B6914);
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            goldColor.withValues(alpha: 0.2),
            goldColor.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: goldColor.withValues(alpha: 0.5), width: 1),
        boxShadow: [
          BoxShadow(color: goldColor.withValues(alpha: 0.15), blurRadius: 8),
        ],
      ),
      child: Center(
        child: Text(
          'ف',
          style: TextStyle(
            color: goldColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'kufi',
          ),
        ),
      ),
    );
  }
}

// ─── Bubble body ──────────────────────────────────────────────────────────────

class _BubbleBody extends StatelessWidget {
  const _BubbleBody({
    required this.message,
    required this.isLastAssistant,
    required this.isDark,
  });

  final ChatMessage message;
  final bool isLastAssistant;
  final bool isDark;

  bool get _isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final goldColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8B6914);

    final Color bgColor;
    final Color textColor;
    final BorderRadius borderRadius;

    if (_isUser) {
      bgColor = isDark ? const Color(0xFF1B4D3E) : const Color(0xFF2D6A4F);
      textColor = Colors.white;
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(5),
      );
    } else {
      // AI bubble uses the theme surface container — clean & theme-aware
      bgColor = cs.surfaceContainerHighest;
      textColor = cs.onSurface;
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(5),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    }

    final ctrl = FanarChatController.instance;

    return GestureDetector(
      onLongPress: () => _showContextMenu(context, ctrl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
          border: _isUser
              ? null
              : Border.all(color: goldColor.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: _isUser
                  ? const Color(0xFF2D6A4F).withValues(alpha: 0.25)
                  : goldColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isUser
                ? Text(
                    message.content,
                    style: TextStyle(
                      color: textColor,
                      fontFamily: 'kufi',
                      fontSize: 14,
                      height: 1.6,
                    ),
                    textDirection: _isArabic(message.content)
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                  )
                : MarkdownRenderer(
                    content: message.content,
                    textColor: textColor,
                  ),
            if (!_isUser)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _ActionRow(
                  message: message,
                  isLastAssistant: isLastAssistant,
                  controller: ctrl,
                  goldColor: goldColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isArabic(String text) {
    if (text.isEmpty) return false;
    final arabicCount = RegExp(r'[\u0600-\u06FF]').allMatches(text).length;
    return arabicCount > text.length * 0.3;
  }

  void _showContextMenu(BuildContext context, FanarChatController ctrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8B6914);
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: goldColor.withValues(alpha: 0.3), width: 1),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: goldColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _MenuTile(
                icon: Icons.copy_rounded,
                label: 'Copy',
                goldColor: goldColor,
                onTap: () {
                  Navigator.pop(context);
                  ctrl.copyMessage(message.content);
                },
              ),
              _MenuTile(
                icon: Icons.share_rounded,
                label: 'Share',
                goldColor: goldColor,
                onTap: () {
                  Navigator.pop(context);
                  SharePlus.instance.share(ShareParams(text: message.content));
                },
              ),
              if (!_isUser && isLastAssistant)
                _MenuTile(
                  icon: Icons.refresh_rounded,
                  label: 'Regenerate',
                  goldColor: goldColor,
                  onTap: () {
                    Navigator.pop(context);
                    ctrl.regenerateLastResponse();
                  },
                ),
              if (message.id != null)
                _MenuTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  goldColor: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                    ctrl.deleteMessage(message.id!);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Action row ───────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.message,
    required this.isLastAssistant,
    required this.controller,
    required this.goldColor,
  });

  final ChatMessage message;
  final bool isLastAssistant;
  final FanarChatController controller;
  final Color goldColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconBtn(
          icon: Icons.copy_rounded,
          tooltip: 'Copy',
          color: goldColor.withValues(alpha: 0.6),
          onTap: () => controller.copyMessage(message.content),
        ),
        _IconBtn(
          icon: Icons.share_rounded,
          tooltip: 'Share',
          color: goldColor.withValues(alpha: 0.6),
          onTap: () =>
              SharePlus.instance.share(ShareParams(text: message.content)),
        ),
        if (isLastAssistant)
          _IconBtn(
            icon: Icons.refresh_rounded,
            tooltip: 'Regenerate',
            color: goldColor.withValues(alpha: 0.6),
            onTap: controller.regenerateLastResponse,
          ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.goldColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color goldColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: goldColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: goldColor, size: 18),
      ),
      title: Text(
        label,
        style: TextStyle(color: cs.onSurface, fontFamily: 'kufi', fontSize: 14),
      ),
      onTap: onTap,
    );
  }
}
