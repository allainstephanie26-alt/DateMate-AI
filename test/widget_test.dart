import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:datemate_ai/theme.dart';

void main() {
  test('DateMate AI uses the correct project colors', () {
    expect(AppColors.primary, const Color(0xFF65172F));
    expect(AppColors.primaryDark, const Color(0xFF4B1024));
    expect(AppColors.gradientEnd, const Color(0xFFD83F78));
    expect(AppColors.background, const Color(0xFFFFF7F5));
    expect(AppColors.secondary, const Color(0xFFFCE4EB));
  });

  test('DateMate AI theme is configured correctly', () {
    expect(appTheme.scaffoldBackgroundColor, AppColors.background);
    expect(appTheme.useMaterial3, true);
  });
}
