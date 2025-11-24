import 'package:flutter/material.dart';
import 'zshrc_text_parser.dart';

class ZshrcTextEditingController extends TextEditingController {
  ZshrcTextEditingController({String? text}) : super(text: text);
  
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // Use the ZshrcTextParser to create colored text spans
    return ZshrcTextParser.parseTextWithComments(text, baseStyle: style);
  }
}

class ZshrcTextField extends StatelessWidget {
  final ZshrcTextEditingController controller;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final bool expands;
  final TextAlignVertical? textAlignVertical;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final StrutStyle? strutStyle;
  final ScrollController? scrollController;
  
  const ZshrcTextField({
    super.key,
    required this.controller,
    this.onChanged,
    this.maxLines,
    this.expands = false,
    this.textAlignVertical,
    this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.strutStyle,
    this.scrollController,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      expands: expands,
      textAlignVertical: textAlignVertical,
      decoration: decoration,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      strutStyle: strutStyle,
      scrollController: scrollController,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
      ),
    );
  }
}