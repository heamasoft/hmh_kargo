import 'package:flutter/material.dart';

/// Heama brand palette, ported from the HTML prototype's CSS custom properties.
class AppColors {
  AppColors._();

  static const Color midnight = Color(0xFF211B3E);
  static const Color midnight700 = Color(0xFF322A5A);
  static const Color pomegranate = Color(0xFFD6443A);
  static const Color pomegranateDark = Color(0xFFB5362E);
  static const Color saffron = Color(0xFFF2A33C);
  static const Color green = Color(0xFF2E9E6B);
  static const Color cloud = Color(0xFFF3F2F7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF211B3E);
  static const Color muted = Color(0xFF74708A);
  static const Color line = Color(0xFFE8E5F0);

  // Supporting tones used across screens.
  static const Color saffronInk = Color(0xFF3A2400); // text on saffron
  static const Color pomTintBg = Color(0xFFFDF3F2); // selected payment bg
  static const Color pomTintChip = Color(0xFFFDE9E7); // sale chip bg
  static const Color hintBg = Color(0xFFFFF6EC);
  static const Color hintBorder = Color(0xFFF3E4CC);
  static const Color hintText = Color(0xFF8A5A13);
  static const Color greenTint = Color(0xFFE7F6EE);
  static const Color transitTint = Color(0xFFEEF0FB);
  static const Color transitText = Color(0xFF3B4BB0);
  static const Color pinBg = Color(0xFFEEF0FB);

  // Gradient stops for the dark (welcome) background.
  static const Color welcomeTop = Color(0xFF2A2350);
  static const Color welcomeBottom = Color(0xFF1A1530);
  static const Color welcomeGlow = Color(0xFF4A3F80);

  // Muted-on-dark text.
  static const Color onDarkPrimary = Color(0xFFEDEAF7);
  static const Color onDarkMuted = Color(0xFFC6BFE4);
  static const Color onDarkFaint = Color(0xFFB9B3D4);
}
