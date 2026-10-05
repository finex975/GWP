import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0E0E0E);
  static const Color surface = Color(0xFF1C1C1C);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  static const Color chatBackground = Color(0xFF0E0E0E);

  static const Color primary = Color(0xFF2AABEE);
  static const Color primaryDark = Color(0xFF1E96D1);
  static const Color accent = Color(0xFF2AABEE);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF707070);
  static const Color textHint = Color(0xFF8A8A8A);

  static const Color bubbleOutgoing = Color(0xFF2B5278);
  static const Color bubbleIncoming = Color(0xFF182533);
  static const Color bubbleOutgoingText = Color(0xFFFFFFFF);
  static const Color bubbleIncomingText = Color(0xFFFFFFFF);

  static const Color online = Color(0xFF4DCD5E);
  static const Color offline = Color(0xFF707070);
  static const Color read = Color(0xFF4FC3F7);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB300);
  static const Color success = Color(0xFF4DCD5E);

  static const Color divider = Color(0xFF2A2A2A);
  static const Color border = Color(0xFF333333);

  static const LinearGradient nameGradient = LinearGradient(
    colors: [Color(0xFF22D3EE), Color(0xFFA78BFA)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}