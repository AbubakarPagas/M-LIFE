// ChatScreen — Islamic aesthetic with theme-aware background.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/chat_message.dart';
import '../viewmodel/fanar_chat_controller.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/message_bubble.dart';
import '../widgets/suggested_prompts.dart';
import '../widgets/typing_indicator.dart';
import 'conversation_list_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollCtrl = ScrollController();
  late final FanarChatController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = FanarChatController.instance;
    ever(_ctrl.messages, (_) => _scrollToBottom());
    ever(_ctrl.isTyping, (_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(context, cs, isDark),
      body: Stack(
        children: [
          // Subtle Islamic geometric background
          Positioned.fill(
            child: CustomPaint(
              painter: _GeometricPatternPainter(
                color: cs.onSurface.withValues(alpha: 0.035),
              ),
            ),
          ),

          Column(
            children: [
              // Golden divider
              _GoldenDivider(cs: cs, isDark: isDark),

              // Message list
              Expanded(
                child: _MessageList(scrollCtrl: _scrollCtrl, ctrl: _ctrl),
              ),

              // Error banner
              Obx(() {
                if (_ctrl.chatStatus.value == FanarChatStatus.error) {
                  return _ErrorBanner(
                    message: _ctrl.errorMessage.value,
                    onDismiss: _ctrl.clearError,
                    onRetry: () {
                      _ctrl.clearError();
                      final msgs = _ctrl.messages.toList();
                      ChatMessage? lastUser;
                      for (int i = msgs.length - 1; i >= 0; i--) {
                        if (msgs[i].role == 'user') {
                          lastUser = msgs[i];
                          break;
                        }
                      }
                      if (lastUser != null) {
                        _ctrl.messages.remove(lastUser);
                        _ctrl.sendUserMessage(lastUser.content);
                      }
                    },
                  );
                }
                return const SizedBox.shrink();
              }),

              // Input bar
              Obx(
                () => ChatInputField(
                  isLoading:
                      _ctrl.isTyping.value ||
                      _ctrl.chatStatus.value == FanarChatStatus.loading,
                  onSend: _ctrl.sendUserMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ColorScheme cs,
    bool isDark,
  ) {
    final goldColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8B6914);

    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              color: goldColor.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                // Conversations drawer button
                _AppBarIconButton(
                  icon: Icons.menu_rounded,
                  color: cs.onSurface,
                  tooltip: 'Conversations',
                  onTap: () => Get.to<void>(
                    () => const ConversationListScreen(),
                    transition: Transition.leftToRight,
                  ),
                ),

                // Title
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Fanar logo circle
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  goldColor.withValues(alpha: 0.3),
                                  goldColor.withValues(alpha: 0.05),
                                ],
                              ),
                              border: Border.all(
                                color: goldColor.withValues(alpha: 0.6),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: goldColor.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'ف',
                                style: TextStyle(
                                  color: goldColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'kufi',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Obx(() {
                            final conv = _ctrl.activeConversation.value;
                            return Flexible(
                              child: Text(
                                conv?.title ?? 'Fanar AI',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontFamily: 'kufi',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your Islamic AI Companion',
                        style: TextStyle(
                          color: goldColor.withValues(alpha: 0.75),
                          fontFamily: 'kufi',
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Model selector
                Obx(
                  () => PopupMenuButton<String>(
                    tooltip: 'Select model',
                    color: cs.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: goldColor.withValues(alpha: 0.25),
                      ),
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: goldColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: goldColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: goldColor,
                        size: 18,
                      ),
                    ),
                    initialValue: _ctrl.selectedModel.value,
                    onSelected: _ctrl.selectModel,
                    itemBuilder: (_) => _ctrl.availableModels.map((m) {
                      final isSelected = m.id == _ctrl.selectedModel.value;
                      return PopupMenuItem<String>(
                        value: m.id,
                        child: Row(
                          children: [
                            if (isSelected)
                              Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: goldColor,
                              )
                            else
                              const SizedBox(width: 16),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  m.displayName,
                                  style: TextStyle(
                                    color: cs.onSurface,
                                    fontFamily: 'kufi',
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (m.description != null)
                                  Text(
                                    m.description!,
                                    style: TextStyle(
                                      color: goldColor.withValues(alpha: 0.6),
                                      fontFamily: 'kufi',
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // New chat
                _AppBarIconButton(
                  icon: Icons.add_rounded,
                  color: cs.onSurface,
                  tooltip: 'New chat',
                  onTap: _ctrl.startNewConversation,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Geometric background pattern ────────────────────────────────────────────

class _GeometricPatternPainter extends CustomPainter {
  const _GeometricPatternPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    const step = 64.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawEightPointStar(canvas, paint, Offset(x, y), 14);
      }
    }
  }

  void _drawEightPointStar(
    Canvas canvas,
    Paint paint,
    Offset center,
    double r,
  ) {
    const points = 8;
    final innerR = r * 0.45;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final radius = i.isEven ? r : innerR;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Golden divider ───────────────────────────────────────────────────────────

class _GoldenDivider extends StatelessWidget {
  const _GoldenDivider({required this.cs, required this.isDark});
  final ColorScheme cs;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final goldColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8B6914);
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            goldColor.withValues(alpha: 0.5),
            goldColor.withValues(alpha: 0.8),
            goldColor.withValues(alpha: 0.5),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─── AppBar icon button ───────────────────────────────────────────────────────

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

// ─── Message list ─────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({required this.scrollCtrl, required this.ctrl});
  final ScrollController scrollCtrl;
  final FanarChatController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msgs = ctrl.messages.toList();
      final isTyping = ctrl.isTyping.value;
      final isEmpty = msgs.isEmpty && !isTyping;

      if (isEmpty) {
        return SingleChildScrollView(
          child: SuggestedPrompts(onSelected: ctrl.sendUserMessage),
        );
      }

      final assistantIndices = <int>{};
      for (int i = msgs.length - 1; i >= 0; i--) {
        if (msgs[i].role == 'assistant') {
          assistantIndices.add(i);
          break;
        }
      }

      return ListView.builder(
        controller: scrollCtrl,
        padding: const EdgeInsets.only(top: 16, bottom: 12),
        itemCount: msgs.length + (isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (isTyping && index == msgs.length) {
            return const TypingIndicator();
          }
          final msg = msgs[index];
          return MessageBubble(
            key: ValueKey(msg.id ?? index),
            message: msg,
            isLastAssistant: assistantIndices.contains(index),
          );
        },
      );
    });
  }
}

// ─── Error banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onDismiss,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onDismiss;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFB00020).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFB00020).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB00020),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFB00020),
                fontFamily: 'kufi',
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Color(0xFF2D6A4F),
                fontFamily: 'kufi',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFFB00020),
              size: 18,
            ),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
