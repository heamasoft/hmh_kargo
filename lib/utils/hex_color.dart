import 'package:flutter/material.dart';

/// Parses a "#RRGGBB" (or "RRGGBB") hex string into a [Color].
Color hexToColor(String hex, {Color fallback = const Color(0xFFC9B6E8)}) {
  var h = hex.replaceAll('#', '').trim();
  if (h.length == 6) h = 'FF$h';
  final value = int.tryParse(h, radix: 16);
  return value == null ? fallback : Color(value);
}

/// Two-stop gradient colors from a list of hex strings (falls back to a pair).
List<Color> gradientFromHex(List<dynamic>? hexes) {
  if (hexes == null || hexes.isEmpty) {
    return const [Color(0xFFC9B6E8), Color(0xFFE9C7D6)];
  }
  final colors = hexes.map((h) => hexToColor(h.toString())).toList();
  if (colors.length == 1) colors.add(colors.first);
  return colors;
}
