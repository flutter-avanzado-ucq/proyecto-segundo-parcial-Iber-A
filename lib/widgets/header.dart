import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../provider_task/weather_provider.dart';
import '../provider_task/holiday_provider.dart';

class Header extends StatelessWidget {
  // Se inyectan los proveedores de imagen para poder sustituirlos en pruebas
  final ImageProvider avatarImage;
  // Permite inyectar un proveedor de imagen basado en el código de ícono
  final ImageProvider Function(String iconCode) weatherImageProvider;

  const Header({
    Key? key,
    // Valor por defecto: se usa una imagen de red (NetworkImage)
    this.avatarImage = const NetworkImage('https://...'),
    // Valor por defecto: se utiliza la función _defaultWeatherImageProvider para imágenes de clima
    this.weatherImageProvider = _defaultWeatherImageProvider,
  }) : super(key: key);

  // Función por defecto que arma un NetworkImage basado en iconCode
  static ImageProvider _defaultWeatherImageProvider(String iconCode) =>
      NetworkImage('https://openweathermap.org/img/wn/${iconCode}@2x.png');

  @override
  Widget build(BuildContext context) {
    // Se obtienen las localizaciones y los providers de clima y feriados
    final localizations = AppLocalizations.of(context)!;
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final weather = weatherProvider.weatherData;
    final holidayProvider = Provider.of<HolidayProvider>(context);
    final holidayToday = holidayProvider.todayHoliday;

    // Construcción del header con avatar, texto y, de haber, clima y feriado
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 156, 11, 185), Color.fromARGB(255, 9, 205, 219)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: avatarImage,  // Se usa la imagen inyectada
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.greeting,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                localizations.todayTasks,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              // Si hay datos del clima, se muestra la imagen y la información
              if (weather != null)
                Row(
                  children: [
                    Image(
                      image: weatherImageProvider(weather.iconCode),  // Se utiliza la función inyectada
                      width: 28,
                      height: 28,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C - ${weather.description}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    )
                  ],
                ),
              // Se muestran estados de carga o error del clima si es necesario
              if (weatherProvider.isLoading)
                Text(
                  localizations.weatherLoading,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              if (weatherProvider.errorMessage != null)
                Text(
                  weatherProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              // Se muestra el feriado de hoy, si existe
              if (holidayToday != null)
                Text(
                  '${localizations.holiday} ${holidayToday.localName}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
            ],
          ),
        ],
      ),
    );
  }
}