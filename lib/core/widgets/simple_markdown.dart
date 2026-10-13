import 'package:flutter/material.dart';

/// A block of simple markdown: heading (level 1–3), bullet item or paragraph.
sealed class MdBlock {
  const MdBlock(this.text);

  final String text;
}

class MdHeading extends MdBlock {
  const MdHeading(this.level, super.text);

  final int level;
}

class MdBullet extends MdBlock {
  const MdBullet(super.text);
}

class MdParagraph extends MdBlock {
  const MdParagraph(super.text);
}

/// Parses the markdown subset used by CHANGELOG.md: `#` headings, `-`/`*` bullets whose
/// indented lines continue them, and paragraphs; blank lines separate blocks.
List<MdBlock> parseMarkdown(String source) {
  final blocks = <MdBlock>[];
  String? open; // text of the bullet or paragraph being collected
  var openIsBullet = false;

  void flush() {
    if (open != null) blocks.add(openIsBullet ? MdBullet(open!) : MdParagraph(open!));
    open = null;
  }

  for (final raw in source.split('\n')) {
    final line = raw.trimRight();
    final heading = RegExp(r'^(#{1,3})\s+(.*)$').firstMatch(line);
    final bullet = RegExp(r'^[-*]\s+(.*)$').firstMatch(line);
    if (line.trim().isEmpty) {
      flush();
    } else if (heading != null) {
      flush();
      blocks.add(MdHeading(heading.group(1)!.length, heading.group(2)!.trim()));
    } else if (bullet != null) {
      flush();
      open = bullet.group(1)!.trim();
      openIsBullet = true;
    } else if (open != null) {
      open = '${open!} ${line.trim()}';
    } else {
      open = line.trim();
      openIsBullet = false;
    }
  }
  flush();
  return blocks;
}

/// Inline **bold**, *italic* and `code` as text spans.
List<InlineSpan> markdownInline(String text, TextStyle? base, {Color? codeBackground}) {
  final spans = <InlineSpan>[];
  final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');
  var last = 0;
  for (final m in pattern.allMatches(text)) {
    if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
    if (m.group(1) != null) {
      spans.add(TextSpan(text: m.group(1), style: const TextStyle(fontWeight: FontWeight.w600)));
    } else if (m.group(2) != null) {
      spans.add(TextSpan(text: m.group(2), style: const TextStyle(fontStyle: FontStyle.italic)));
    } else {
      spans.add(TextSpan(
        text: m.group(3),
        style: TextStyle(fontFamily: 'monospace', backgroundColor: codeBackground, fontSize: (base?.fontSize ?? 14) * .92),
      ));
    }
    last = m.end;
  }
  if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
  return spans;
}

/// Renders [blocks] as a column of text.
class SimpleMarkdown extends StatelessWidget {
  const SimpleMarkdown(this.blocks, {super.key});

  final List<MdBlock> blocks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = theme.textTheme.bodyMedium;
    final code = theme.colorScheme.surfaceContainerHighest;
    Widget rich(String text, TextStyle? style) =>
        Text.rich(TextSpan(style: style, children: markdownInline(text, style, codeBackground: code)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, b) in blocks.indexed)
          switch (b) {
            MdHeading(:final level, :final text) => Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 20, bottom: 6),
                child: rich(
                  text,
                  (level == 1 ? theme.textTheme.titleLarge : level == 2 ? theme.textTheme.titleMedium : theme.textTheme.titleSmall)
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
            MdBullet(:final text) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: const EdgeInsets.only(right: 8), child: Text('•', style: body)),
                    Expanded(child: rich(text, body)),
                  ],
                ),
              ),
            MdParagraph(:final text) =>
              Padding(padding: const EdgeInsets.only(bottom: 8), child: rich(text, body)),
          },
      ],
    );
  }
}
