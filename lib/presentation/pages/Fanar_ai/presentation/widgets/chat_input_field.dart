// ChatInputField — theme-aware background, English hint text.

import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    super.key,
    required this.onSend,
    this.isLoading = false,
  });

  final ValueChanged<String> onSend;
  final bool isLoading;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textCtrl = TextEditingController();
  bool _hasText = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(() {
      final has = _textCtrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(ChatInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isLoading && _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _send() {
    if (widget.isLoading) return;
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8B6914);
    final islamicGreen = isDark
        ? const Color(0xFF1B4D3E)
        : const Color(0xFF2D6A4F);

    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        // Use theme surface — clean and theme-aware
        color: cs.surface,
        border: Border(
          top: BorderSide(color: goldColor.withValues(alpha: 0.3), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Text field ────────────────────────────────────────────────
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 140),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _hasText
                        ? goldColor.withValues(alpha: 0.5)
                        : goldColor.withValues(alpha: 0.2),
                    width: _hasText ? 1.5 : 1,
                  ),
                  boxShadow: _hasText
                      ? [
                          BoxShadow(
                            color: goldColor.withValues(alpha: 0.08),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: TextField(
                  controller: _textCtrl,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontFamily: 'kufi',
                    fontSize: 14,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your message…',
                    hintStyle: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.35),
                      fontFamily: 'kufi',
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ── Send / Loading button ─────────────────────────────────────
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) => Transform.scale(
                scale: widget.isLoading ? _pulseAnim.value : 1.0,
                child: child,
              ),
              child: GestureDetector(
                onTap: (_hasText && !widget.isLoading) ? _send : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: (_hasText && !widget.isLoading)
                        ? LinearGradient(
                            colors: [
                              islamicGreen,
                              islamicGreen.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: (_hasText && !widget.isLoading)
                        ? null
                        : goldColor.withValues(alpha: 0.15),
                    border: Border.all(
                      color: (_hasText && !widget.isLoading)
                          ? Colors.transparent
                          : goldColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: (_hasText && !widget.isLoading)
                        ? [
                            BoxShadow(
                              color: islamicGreen.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: widget.isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              goldColor,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          size: 20,
                          color: _hasText
                              ? Colors.white
                              : goldColor.withValues(alpha: 0.4),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
