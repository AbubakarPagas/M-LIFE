// Lightweight Markdown renderer built with Flutter's rich text stack.
// Avoids adding a new dependency — handles the most common markdown patterns
// (bold, italic, inline code, code blocks, unordered lists, headers).

import 'package:flutter/material.dart';

class MarkdownRenderer extends StatelessWidget {
  const MarkdownRenderer({
    super.key,
    required this.content,
    required this.textColor,
  });

  final String content;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final blocks = _parseBlocks(content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks
          .map((b) => _BlockWidget(block: b, textColor: textColor))
          .toList(),
    );
  }

  // Split into logical blocks: code fence, list block, or plain paragraph.
  List<_Block> _parseBlocks(String text) {
    final blocks = <_Block>[];
    final lines = text.split('\n');
    final buffer = StringBuffer();
    bool inCodeBlock = false;
    final codeBuffer = StringBuffer();
    String? codeLanguage;

    void flushParagraph() {
      final s = buffer.toString().trim();
      if (s.isNotEmpty) blocks.add(_Block(type: _BlockType.paragraph, text: s));
      buffer.clear();
    }

    for (final line in lines) {
      if (line.startsWith('```')) {
        if (!inCodeBlock) {
          flushParagraph();
          inCodeBlock = true;
          codeLanguage = line.substring(3).trim();
        } else {
          blocks.add(
            _Block(
              type: _BlockType.codeBlock,
              text: codeBuffer.toString(),
              extra: codeLanguage,
            ),
          );
          codeBuffer.clear();
          codeLanguage = null;
          inCodeBlock = false;
        }
        continue;
      }
      if (inCodeBlock) {
        codeBuffer.writeln(line);
        continue;
      }

      // Detect list items — keep them as a single block.
      final isList =
          line.startsWith('- ') ||
          line.startsWith('* ') ||
          RegExp(r'^\d+\.\s').hasMatch(line);
      if (isList) {
        flushParagraph();
        blocks.add(_Block(type: _BlockType.listItem, text: line));
        continue;
      }

      // Header lines.
      if (line.startsWith('#')) {
        flushParagraph();
        blocks.add(_Block(type: _BlockType.header, text: line));
        continue;
      }

      buffer.writeln(line);
    }

    // Close any unclosed code block.
    if (inCodeBlock && codeBuffer.isNotEmpty) {
      blocks.add(
        _Block(type: _BlockType.codeBlock, text: codeBuffer.toString()),
      );
    }

    flushParagraph();
    return blocks;
  }
}

// ─── Block types ─────────────────────────────────────────────────────────────

enum _BlockType { paragraph, header, listItem, codeBlock }

class _Block {
  const _Block({required this.type, required this.text, this.extra});
  final _BlockType type;
  final String text;
  final String? extra; // language hint for code blocks
}

// ─── Block widget ─────────────────────────────────────────────────────────────

class _BlockWidget extends StatelessWidget {
  const _BlockWidget({required this.block, required this.textColor});
  final _Block block;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case _BlockType.codeBlock:
        return _CodeBlock(code: block.text, language: block.extra);
      case _BlockType.header:
        return _HeaderText(raw: block.text, textColor: textColor);
      case _BlockType.listItem:
        return _ListItem(raw: block.text, textColor: textColor);
      case _BlockType.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text.rich(
            _buildInlineSpan(block.text, textColor),
            style: TextStyle(
              color: textColor,
              fontFamily: 'kufi',
              fontSize: 14,
              height: 1.6,
            ),
          ),
        );
    }
  }
}

// ─── Inline span parser (bold, italic, inline code) ──────────────────────────

TextSpan _buildInlineSpan(String text, Color baseColor) {
  final spans = <InlineSpan>[];
  // Matches: **bold**, *italic*, `code`
  final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');
  int cursor = 0;

  for (final match in pattern.allMatches(text)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, match.start)));
    }
    if (match.group(1) != null) {
      // **bold**
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else if (match.group(2) != null) {
      // *italic*
      spans.add(
        TextSpan(
          text: match.group(2),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    } else if (match.group(3) != null) {
      // `inline code`
      spans.add(
        WidgetSpan(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              match.group(3)!,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
      );
    }
    cursor = match.end;
  }

  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor)));
  }

  return TextSpan(
    children: spans,
    style: TextStyle(
      color: baseColor,
      fontFamily: 'kufi',
      fontSize: 14,
      height: 1.6,
    ),
  );
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code, this.language});
  final String code;
  final String? language;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (language != null && language!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                language!,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              code.trimRight(),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({required this.raw, required this.textColor});
  final String raw;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    // Count leading '#' characters.
    int level = 0;
    for (final ch in raw.characters) {
      if (ch == '#')
        level++;
      else
        break;
    }
    level = level.clamp(1, 6);
    final text = raw.substring(level).trim();

    final fontSize = [24.0, 20.0, 17.0, 15.0, 14.0, 13.0][level - 1];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'kufi',
          height: 1.4,
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({required this.raw, required this.textColor});
  final String raw;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    // Strip the list marker.
    final text = raw.replaceFirst(RegExp(r'^[-*]\s|\d+\.\s'), '');
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 8),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text.rich(
              _buildInlineSpan(text, textColor),
              style: TextStyle(
                color: textColor,
                fontFamily: 'kufi',
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
