import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Font helpers matching the prototype:
///  - Bricolage Grotesque  -> display / headings
///  - Plus Jakarta Sans    -> body / UI text
class AppFonts {
  AppFonts._();

  /// Display font (headings, prices, big numbers).
  static TextStyle display({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w800,
    Color color = AppColors.ink,
    double? height,
    double letterSpacing = -0.4,
  }) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Body font (labels, paragraphs, buttons).
  static TextStyle body({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  static TextTheme textTheme(TextTheme base) {
    return GoogleFonts.plusJakartaSansTextTheme(base).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );
  }
}
