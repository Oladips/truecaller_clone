import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String? text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final Color? color;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final int? maxLines;
  final double? letterSpacing;
  const CustomText({
    Key? key,
    this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.fontFamily,
    this.overflow,
    this.textAlign,
    this.maxLines,
    this.letterSpacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: fontFamily ?? "OpenSans",
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
