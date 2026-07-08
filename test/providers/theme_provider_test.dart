import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:find_it/core/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    late ThemeProvider provider;

    setUp(() {
      provider = ThemeProvider();
    });

    test('defaults to system theme', () {
      expect(provider.themeMode, ThemeMode.system);
      expect(provider.isSystem, isTrue);
      expect(provider.isDark, isFalse);
    });

    group('setThemeMode', () {
      test('sets light theme', () {
        provider.setThemeMode(ThemeMode.light);
        expect(provider.themeMode, ThemeMode.light);
        expect(provider.isSystem, isFalse);
        expect(provider.isDark, isFalse);
      });

      test('sets dark theme', () {
        provider.setThemeMode(ThemeMode.dark);
        expect(provider.themeMode, ThemeMode.dark);
        expect(provider.isDark, isTrue);
        expect(provider.isSystem, isFalse);
      });

      test('sets system theme', () {
        provider.setThemeMode(ThemeMode.light);
        provider.setThemeMode(ThemeMode.system);
        expect(provider.themeMode, ThemeMode.system);
        expect(provider.isSystem, isTrue);
      });

      test('notifies listeners on setThemeMode', () {
        int notifyCount = 0;
        provider.addListener(() => notifyCount++);

        provider.setThemeMode(ThemeMode.dark);
        expect(notifyCount, 1);
      });
    });

    group('toggleTheme', () {
      test('toggles from system to light', () {
        provider.toggleTheme();
        expect(provider.themeMode, ThemeMode.light);
      });

      test('toggles from light to dark', () {
        provider.setThemeMode(ThemeMode.light);
        provider.toggleTheme();
        expect(provider.themeMode, ThemeMode.dark);
      });

      test('toggles from dark to system', () {
        provider.setThemeMode(ThemeMode.dark);
        provider.toggleTheme();
        expect(provider.themeMode, ThemeMode.system);
      });

      test('cycling through all modes', () {
        expect(provider.themeMode, ThemeMode.system);
        provider.toggleTheme(); // -> light
        expect(provider.themeMode, ThemeMode.light);
        provider.toggleTheme(); // -> dark
        expect(provider.themeMode, ThemeMode.dark);
        provider.toggleTheme(); // -> system
        expect(provider.themeMode, ThemeMode.system);
      });

      test('notifies listeners on toggle', () {
        int notifyCount = 0;
        provider.addListener(() => notifyCount++);

        provider.toggleTheme();
        expect(notifyCount, 1);
      });
    });

    group('themeModeLabel', () {
      test('returns System for system', () {
        expect(provider.themeModeLabel, 'System');
      });

      test('returns Light for light', () {
        provider.setThemeMode(ThemeMode.light);
        expect(provider.themeModeLabel, 'Light');
      });

      test('returns Dark for dark', () {
        provider.setThemeMode(ThemeMode.dark);
        expect(provider.themeModeLabel, 'Dark');
      });
    });

    group('themeModeIcon', () {
      test('returns brightness_auto for system', () {
        expect(provider.themeModeIcon, Icons.brightness_auto_rounded);
      });

      test('returns light_mode for light', () {
        provider.setThemeMode(ThemeMode.light);
        expect(provider.themeModeIcon, Icons.light_mode_rounded);
      });

      test('returns dark_mode for dark', () {
        provider.setThemeMode(ThemeMode.dark);
        expect(provider.themeModeIcon, Icons.dark_mode_rounded);
      });
    });

    test('multiple listeners are notified', () {
      int count1 = 0;
      int count2 = 0;
      provider.addListener(() => count1++);
      provider.addListener(() => count2++);

      provider.toggleTheme();
      expect(count1, 1);
      expect(count2, 1);
    });
  });
}
