import 'package:flutter/material.dart';

class ZshrcTextParser {
  /// Parses text and creates TextSpans with different colors based on '#' characters
  /// When a '#' is encountered, all subsequent characters in that line become gray
  static TextSpan parseTextWithComments(String text, {TextStyle? baseStyle}) {
    final lines = text.split('\n');
    final spans = <TextSpan>[];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineSpans = _parseLine(line, baseStyle);
      spans.addAll(lineSpans);
      
      // Add newline character (except for the last line)
      if (i < lines.length - 1) {
        spans.add(TextSpan(text: '\n', style: baseStyle));
      }
    }
    
    return TextSpan(children: spans);
  }
  
  /// Parses a single line and creates TextSpans with different colors
  static List<TextSpan> _parseLine(String line, TextStyle? baseStyle) {
    final spans = <TextSpan>[];
    final commentIndex = line.indexOf('#');
    
    if (commentIndex == -1) {
      // No '#' found in the line, use base style for the entire line
      spans.add(TextSpan(text: line, style: baseStyle));
    } else {
      // '#' found, split the line into two parts
      final beforeComment = line.substring(0, commentIndex);
      final commentAndAfter = line.substring(commentIndex);
      
      // Add the part before '#' with base style
      if (beforeComment.isNotEmpty) {
        spans.add(TextSpan(text: beforeComment, style: baseStyle));
      }
      
      // Add the '#' and everything after it with gray color
      final grayStyle = baseStyle?.copyWith(
        color: const Color.fromARGB(255, 102, 159, 102),
      ) ?? TextStyle(color: Colors.grey[500]);
      
      spans.add(TextSpan(text: commentAndAfter, style: grayStyle));
    }
    
    return spans;
  }
  
  /// Creates a rich text widget with syntax highlighting for .zshrc files
  static Widget buildRichText(String text, {
    TextStyle? baseStyle,
    TextStyle? commentStyle,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
  }) {
    final defaultBaseStyle = baseStyle ?? const TextStyle(
      fontFamily: 'monospace',
      fontSize: 14,
      color: Colors.black87,
    );
    
    return RichText(
      text: parseTextWithComments(text, baseStyle: defaultBaseStyle),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      textAlign: textAlign ?? TextAlign.left,
    );
  }
}