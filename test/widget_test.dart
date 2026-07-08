import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:find_it/core/theme/app_theme.dart';

void main() {
  group('App Theme', () {
    testWidgets('light theme renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: Center(child: Text('Test'))),
        ),
      );
      expect(find.text('Test'), findsOneWidget);

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme, isNotNull);
    });

    testWidgets('dark theme renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: Center(child: Text('Test Dark'))),
        ),
      );
      expect(find.text('Test Dark'), findsOneWidget);

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme, isNotNull);
    });

    testWidgets('theme has Material 3 enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(),
        ),
      );

      final ThemeData theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.useMaterial3, isTrue);
    });

    testWidgets('app uses correct color scheme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(),
        ),
      );

      final ThemeData theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.colorScheme, isNotNull);
      expect(theme.colorScheme.primary, isNotNull);
    });

    testWidgets('default Scaffold renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(title: Text('Test App')),
            body: Center(child: Text('Hello World')),
          ),
        ),
      );

      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('text fields render correctly in light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: TextField(decoration: InputDecoration(labelText: 'Email')),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('buttons render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Click Me'),
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
