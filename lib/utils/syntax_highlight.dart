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

    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        child: ColoredBox(
          color: codeTheme['root']!.backgroundColor!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextButton.icon(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.zero)),
                    onPressed: () {
                      FlutterClipboard.copy(element.textContent.trim());
                    },
                    icon: const Icon(Icons.copy, size: 12),
                    label: const Text('Copy', style: TextStyle(fontSize: 12))),
              ),
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: HighlightView(element.textContent.trim(),
                      language: language,
                      // All available themes are listed in `themes` folder
                      theme: codeTheme,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      textStyle: GoogleFonts.sourceCodePro(
                          fontSize: 14, color: codeTheme['root']!.color!))),
            ],
          ),
        ),
      );
    });
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
        // FIXME: this only works with html renderer, not canvaskit
        return Text.rich(
          TextSpan(
            text: text,
            style: style
                .copyWith(fontFeatures: const [FontFeature.superscripts()]),
          ),
        );
      case "sub":
        // Transform the text into a subscript
        return Text.rich(
          TextSpan(
            text: text,
            style: style
                .copyWith(fontFeatures: const [FontFeature.superscripts()]),
          ),
        );
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
