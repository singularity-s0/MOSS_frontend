import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-light.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';
    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }

    final codeTheme = MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .platformBrightness ==
            Brightness.light
        ? atomOneLightTheme
        : atomOneDarkTheme;

    return HighlightView(
      element.textContent,
      language: language,
      // All available themes are listed in `themes` folder
      theme: codeTheme,
      padding: const EdgeInsets.all(8),
      textStyle: const TextStyle(
        fontFeatures: [FontFeature.tabularFigures()], // monospace
      ),
    );
  }
}
