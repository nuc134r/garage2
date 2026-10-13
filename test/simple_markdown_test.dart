import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/widgets/simple_markdown.dart';

void main() {
  test('parses headings, bullets with continuation lines and paragraphs', () {
    final blocks = parseMarkdown('''
## 2.5.2

- Filled icons.
- Settings are less
  cluttered.

Some text
on two lines.
''');
    expect(blocks.map((b) => b.runtimeType), [MdHeading, MdBullet, MdBullet, MdParagraph]);
    expect((blocks[0] as MdHeading).level, 2);
    expect(blocks[0].text, '2.5.2');
    expect(blocks[2].text, 'Settings are less cluttered.');
    expect(blocks[3].text, 'Some text on two lines.');
  });

  test('inline bold, italic and code', () {
    final spans = markdownInline('a **b** *c* `d` e', null).cast<TextSpan>();
    expect(spans.map((s) => s.text), ['a ', 'b', ' ', 'c', ' ', 'd', ' e']);
    expect(spans[1].style?.fontWeight, FontWeight.w600);
    expect(spans[3].style?.fontStyle, FontStyle.italic);
    expect(spans[5].style?.fontFamily, 'monospace');
  });
}
