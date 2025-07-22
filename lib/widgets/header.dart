import 'package:flutter/material.dart';import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Nuevos imports
import 'package:provider/provider.dart';
import '../provider_task/weather_provider.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    //Acceso al provider del clima
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final weather = weatherProvider.weatherData;

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
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
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
              const SizedBox(height: 8), // espacio visual

              //Nuevo: Mostrar clima si está disponible 
              if (weather != null)
                Row(
                  children: [
                    Image.network(
                      'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png',
                      width: 28,
                      height: 28,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C - ${weather.description}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              if (weatherProvider.isLoading)
                const Text(
                  'Cargando clima...',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              if (weatherProvider.errorMessage != null)
                Text(
                  weatherProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
