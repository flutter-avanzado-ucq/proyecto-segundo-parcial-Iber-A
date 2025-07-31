import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animaciones_notificaciones/services/holiday_service.dart';
import 'package:flutter_animaciones_notificaciones/services/weather_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animaciones_notificaciones/widgets/header.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/holiday_provider.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/weather_provider.dart';

/// Fake provider que suministra datos de clima fijos para la prueba
class FakeWeatherProvider extends WeatherProvider {
  @override
  WeatherData? get weatherData => WeatherData(
        temperature: 25.5,
        description: 'Soleado',
        cityName: 'Querétaro',
        iconCode: '01d',
      );
  @override
  bool get isLoading => false;
  @override
  String? get errorMessage => null;
}

// Fake provider de feriados que muestra un feriado "de prueba"1
class FakeHolidayProvider extends HolidayProvider {
  @override
  Holiday? get todayHoliday => Holiday(
        localName: 'Día de prueba',
        date: DateTime.now(),
      );
}

// Se define un fake image usando MemoryImage para evitar solicitudes HTTP
final MemoryImage fakeImage = MemoryImage(Uint8List.fromList(
  [137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,1,0,0,0,1,8,6,0,0,0,31,21,196,137,0,0,0,12,73,68,65,84,8,153,99,96,0,0,0,2,0,1,226,82,124,211,0,0,0,0,73,69,78,68,174,66,96,130]
));

// Se define la función para inyectar la imagen fake para el clima
ImageProvider fakeWeatherImageProvider(String iconCode) => fakeImage;

// HttpOverrides para evitar solicitudes HTTP en test, lanzando excepción en caso de intento
class _NoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    throw UnsupportedError('No HTTP requests allowed in widget tests');
  }
}

void main() {
  // Se establece el HttpOverride para que no se realicen solicitudes HTTP
  setUpAll(() => HttpOverrides.global = _NoNetworkHttpOverrides());

  testWidgets('Header muestra feriado y clima correctamente', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          // Se inyectan los fake providers
          ChangeNotifierProvider<WeatherProvider>(create: (_) => FakeWeatherProvider()),
          ChangeNotifierProvider<HolidayProvider>(create: (_) => FakeHolidayProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es')],
          home: Scaffold(
            // Se inyecta el Header con los fake images para evitar solicitudes reales
            body: Header(
              avatarImage: fakeImage,
              weatherImageProvider: fakeWeatherImageProvider,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Se verifican los textos esperados en pantalla
    expect(find.textContaining('Día de prueba'), findsOneWidget);
    expect(find.textContaining('25.5'), findsOneWidget);
    expect(find.textContaining('Soleado'), findsOneWidget);
  });
}