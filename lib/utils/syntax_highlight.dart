import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:openchat_frontend/views/components/flutter_highlighter.dart';

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';
    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }

    const codeTheme = githubTheme;
    final multiline = element.textContent.contains('\n');

    return Text.rich(
      TextSpan(
        children: multiline
            ? [
                WidgetSpan(
                    child: ColoredBox(
                  color: codeTheme['root']!.backgroundColor!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (multiline)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextButton.icon(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.zero)),
                              onPressed: () {
                                FlutterClipboard.copy(
                                    element.textContent.trim());
                              },
                              icon: const Icon(Icons.copy, size: 12),
                              label: const Text('Copy',
                                  style: TextStyle(fontSize: 12))),
                        ),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: HighlightView(element.textContent,
                              language: language,
                              // All available themes are listed in `themes` folder
                              theme: codeTheme,
                              padding: multiline
                                  ? const EdgeInsets.fromLTRB(16, 0, 16, 12)
                                  : const EdgeInsets.symmetric(horizontal: 4),
                              textStyle: GoogleFonts.sourceCodePro(
                                  fontSize: 14,
                                  color: codeTheme['root']!.color!))),
                    ],
                  ),
                ))
              ]
            : [
                TextSpan(
                    text: element.textContent,
                    style: GoogleFonts.robotoMono(
                        color: codeTheme['root']!.color!,
                        backgroundColor: codeTheme['root']!.backgroundColor)),
              ],
      ),
    );
  }
}

class SimpleSTXHtmlSyntax extends md.InlineSyntax {
  SimpleSTXHtmlSyntax()
      : super(r'<([a-z]+)><\|(.*?)\|><\/\1>', caseSensitive: false);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final String tag = match.group(1)!;
    final String text = match.group(2)!;
    final Map json = {"tag": tag, "text": text};
    parser.addNode(md.Element.text("html", jsonEncode(json)));
    return true;
  }
}

String numToSuperscript(String num) {
  // Use unicode superscript characters
  final superscript = {
    '0': '\u2070',
    '1': '\u00B9',
    '2': '\u00B2',
    '3': '\u00B3',
    '4': '\u2074',
    '5': '\u2075',
    '6': '\u2076',
    '7': '\u2077',
    '8': '\u2078',
    '9': '\u2079',
  };
  return num.split('').map((e) => superscript[e] ?? e).join();
}

class SimpleHtmlBuilder extends MarkdownElementBuilder {
  final TextStyle style;

  SimpleHtmlBuilder(this.style);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final Map json = jsonDecode(element.textContent);
    final String tag = json["tag"];
    final String text = json["text"];
    switch (tag) {
      case "sup":
        // Transform the text into a superscript
        return const Text.rich(TextSpan(text: "")); // Temporarily disabled
      // return Text.rich(
      //   TextSpan(text: "${numToSuperscript(text)} ", style: style),
      // );
      case "tooltip":
        // Transform the text into a tooltip
        return Tooltip(
          message: text,
          child: const Icon(Icons.info_outline),
        );
      default:
        return null;
    }
  }
}

const githubTheme = {
  'root':
      TextStyle(color: Color(0xff333333), backgroundColor: Color(0xfff8f8f8)),
  'comment': TextStyle(color: Color(0xff999988), fontStyle: FontStyle.italic),
  'quote': TextStyle(color: Color(0xff999988), fontStyle: FontStyle.italic),
  'keyword': TextStyle(color: Color(0xff333333), fontWeight: FontWeight.bold),
  'selector-tag':
      TextStyle(color: Color(0xff333333), fontWeight: FontWeight.bold),
  'subst': TextStyle(color: Color(0xff333333), fontWeight: FontWeight.normal),
  'number': TextStyle(color: Color(0xff008080)),
  'literal': TextStyle(color: Color(0xff008080)),
  'variable': TextStyle(color: Color(0xff008080)),
  'template-variable': TextStyle(color: Color(0xff008080)),
  'string': TextStyle(color: Color(0xffdd1144)),
  'doctag': TextStyle(color: Color(0xffdd1144)),
  'title': TextStyle(color: Color(0xff990000), fontWeight: FontWeight.bold),
  'section': TextStyle(color: Color(0xff990000), fontWeight: FontWeight.bold),
  'selector-id':
      TextStyle(color: Color(0xff990000), fontWeight: FontWeight.bold),
  'type': TextStyle(color: Color(0xff445588), fontWeight: FontWeight.bold),
  'tag': TextStyle(color: Color(0xff000080), fontWeight: FontWeight.normal),
  'name': TextStyle(color: Color(0xff000080), fontWeight: FontWeight.normal),
  'attribute':
      TextStyle(color: Color(0xff000080), fontWeight: FontWeight.normal),
  'regexp': TextStyle(color: Color(0xff009926)),
  'link': TextStyle(color: Color(0xff009926)),
  'symbol': TextStyle(color: Color(0xff990073)),
  'bullet': TextStyle(color: Color(0xff990073)),
  'built_in': TextStyle(color: Color(0xff0086b3)),
  'builtin-name': TextStyle(color: Color(0xff0086b3)),
  'meta': TextStyle(color: Color(0xff999999), fontWeight: FontWeight.bold),
  'deletion': TextStyle(backgroundColor: Color(0xffffdddd)),
  'addition': TextStyle(backgroundColor: Color(0xffddffdd)),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.bold),
  'titlebg': TextStyle(color: Colors.white, backgroundColor: Color(0xff404040)),
};
