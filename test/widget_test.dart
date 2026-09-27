import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:datemate_ai/theme.dart';

void main() {
  test('DateMate AI uses the mockup-inspired palette', () {
    expect(AppColors.primary, const Color(0xFF64172F));
    expect(AppColors.primaryDark, const Color(0xFF431020));
    expect(AppColors.gradientEnd, const Color(0xFFD6427D));
    expect(AppColors.background, const Color(0xFFFFF8F5));
    expect(AppColors.blush, const Color(0xFFFCE5EC));
  });

  test('DateMate AI theme uses Material 3 and the warm background', () {
    expect(appTheme.scaffoldBackgroundColor, AppColors.background);
    expect(appTheme.useMaterial3, true);
  });
}
