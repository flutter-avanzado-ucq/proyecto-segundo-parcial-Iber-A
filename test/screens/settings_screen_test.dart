import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_animaciones_notificaciones/screens/settings_screen.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/theme_provider.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/locale_provider.dart';

void main() {
  testWidgets('SettingsScreen muestra opciones de idioma y tema',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(
              create: (_) => ThemeProvider()),
          ChangeNotifierProvider<LocaleProvider>(
              create: (_) => LocaleProvider()),
        ],
        child: const MaterialApp(
          // Se establecen los delegates y locales necesarios para la localización
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('es')],
          locale: Locale('es'),
          // Se carga el SettingsScreen a probar
          home: Scaffold(body: SettingsScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Se ajusta la expectativa para buscar el texto "Idioma" según la ARB en español
    expect(find.text('Idioma'), findsAtLeastNWidgets(1));
  });
}
