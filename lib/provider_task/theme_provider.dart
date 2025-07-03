import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

/// Provider que maneja el tema de la aplicación (claro/oscuro)
/// Persiste las preferencias del usuario usando SharedPreferences
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false; // Estado interno del tema

  /// Getter para obtener el estado actual del tema
  bool get isDarkMode => _isDarkMode;

  /// Constructor que carga el tema guardado al inicializar
  ThemeProvider() {
    loadTheme();
  }

  /// Carga el tema guardado desde las preferencias del usuario
  Future<void> loadTheme() async {
    _isDarkMode = await PreferencesService.getDarkMode();
    notifyListeners(); // Notifica a los widgets que escuchan
  }

  /// Alterna entre tema claro y oscuro
  /// Guarda la preferencia y notifica el cambio
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await PreferencesService.setDarkMode(_isDarkMode); // Persiste el cambio
    notifyListeners(); // Notifica a los widgets que escuchan
  }
}
