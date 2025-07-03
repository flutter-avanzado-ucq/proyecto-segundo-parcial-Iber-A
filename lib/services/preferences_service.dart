import 'package:hive/hive.dart';

/// Servicio para manejar las preferencias del usuario usando Hive
/// Almacena configuraciones de forma persistente en el dispositivo
class PreferencesService {
  static const String _boxName = 'preferences_box';  // Nombre del contenedor Hive
  static const String _themeKey = 'isDarkMode';      // Clave para el tema

  /// Guarda la preferencia del tema oscuro
  /// [isDark] - true para tema oscuro, false para tema claro
  static Future<void> setDarkMode(bool isDark) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_themeKey, isDark);
  }

  /// Obtiene la preferencia del tema guardada
  /// Retorna false por defecto si no existe valor guardado
  static Future<bool> getDarkMode() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_themeKey, defaultValue: false);
  }
}
