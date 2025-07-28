import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_animaciones_notificaciones/widgets/card_tarea.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/holiday_provider.dart';

void main() {
  testWidgets('TaskCard muestra el título y responde al botón de check',
      (WidgetTester tester) async {
    bool fueMarcado = false;

    final animationController = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 500),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es')],
        home: ChangeNotifierProvider<HolidayProvider>(
          create: (_) => HolidayProvider(),
          builder: (context, _) => Scaffold(
            body: TaskCard(
              title: 'Tarea de prueba',
              isDone: false,
              onToggle: () {
                fueMarcado = true;
              },
              onDelete: () {},
              iconRotation: animationController,
              index: 0,
            ),
          ),
        ),
      ),
    );

    // Verificar que el título se muestra correctamente
    expect(find.text('Tarea de prueba'), findsOneWidget);

    // Verificar que aparece el icono de tarea incompleta
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

    // Simular un tap en el botón de check
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));

    // Re-renderizar la interfaz
    await tester.pump();

    // Verificar que el botón de check ahora está marcado
    expect(fueMarcado, isTrue);
  });
}

class TestVSync implements TickerProvider {
  const TestVSync();

  @override
  Ticker createTicker(onTick) => Ticker(onTick);
}