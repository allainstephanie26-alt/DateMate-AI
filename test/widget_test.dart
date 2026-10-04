import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:datemate_ai/theme.dart';

void main() {
  test('DateMate AI uses the mockup-inspired palette', () {
    expect(AppColors.primary, const Color(0xFF64172F));
    expect(AppColors.primaryDark, const Color(0xFF3C0E1E));
    expect(AppColors.gradientEnd, const Color(0xFFD6427D));
    expect(AppColors.background, const Color(0xFFFFF7F4));
    expect(AppColors.blush, const Color(0xFFFCE5EC));
  });

  test('DateMate AI theme uses Material 3 and the warm background', () {
    expect(appTheme.scaffoldBackgroundColor, AppColors.background);
    expect(appTheme.useMaterial3, true);
  });

  test('every place gradient has exactly two colors', () {
    for (final pair in AppColors.placeGradients) {
      expect(pair.length, 2);
    }
  });
}
