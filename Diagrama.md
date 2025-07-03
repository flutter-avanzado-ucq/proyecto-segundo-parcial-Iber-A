# Diagrama de Arquitectura - Sistema de Temas

## Flujo de Comunicación: UI → ThemeProvider → PreferencesService → Hive

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐
│       UI        │    │  ThemeProvider  │    │PreferencesService│    │    Hive     │
│   (MaterialApp) │    │                 │    │                 │    │ (Database)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────┘
         │                       │                       │                     │
         │                       │                       │                     │
         │   Consumer<Theme>     │                       │                     │
         │◄──────────────────────│                       │                     │
         │                       │                       │                     │
         │                       │   getDarkMode()       │                     │
         │                       │──────────────────────►│                     │
         │                       │                       │                     │
         │                       │                       │   box.get(key)      │
         │                       │                       │────────────────────►│
         │                       │                       │                     │
         │                       │                       │   bool value        │
         │                       │                       │◄────────────────────│
         │                       │                       │                     │
         │                       │   return bool         │                     │
         │                       │◄──────────────────────│                     │
         │                       │                       │                     │
         │  themeMode: isDark?   │                       │                     │
         │  ThemeMode.dark :     │                       │                     │
         │  ThemeMode.light      │                       │                     │
         │◄──────────────────────│                       │                     │
```

## Flujo cuando el Usuario Cambia el Tema

### 1. Inicialización de la App
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              App Startup                                       │
│                                                                                 │
│  1. main() → WidgetsFlutterBinding.ensureInitialized()                        │
│  2. Hive.initFlutter()                                                         │
│  3. ThemeProvider() constructor ejecuta loadTheme()                            │
│  4. loadTheme() → PreferencesService.getDarkMode()                            │
│  5. PreferencesService → Hive.openBox() → box.get('isDarkMode')               │
│  6. MaterialApp usa Consumer<ThemeProvider> para aplicar tema inicial          │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 2. Usuario Cambia el Tema (Interacción)
```
┌─────────────────┐
│   User Action   │
│  (Toggle Theme) │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐
│       UI        │    │  ThemeProvider  │    │PreferencesService│    │    Hive     │
│   (Switch/Btn)  │    │                 │    │                 │    │             │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────┘
         │                       │                       │                     │
         │                       │                       │                     │
         │ 1. onTap()            │                       │                     │
         │ toggleTheme()         │                       │                     │
         │──────────────────────►│                       │                     │
         │                       │                       │                     │
         │                       │ 2. _isDarkMode =      │                     │
         │                       │    !_isDarkMode       │                     │
         │                       │                       │                     │
         │                       │ 3. setDarkMode(bool)  │                     │
         │                       │──────────────────────►│                     │
         │                       │                       │                     │
         │                       │                       │ 4. box.put(key,val) │
         │                       │                       │────────────────────►│
         │                       │                       │                     │
         │                       │                       │ 5. ✅ Saved         │
         │                       │                       │◄────────────────────│
         │                       │                       │                     │
         │                       │ 6. await complete     │                     │
         │                       │◄──────────────────────│                     │
         │                       │                       │                     │
         │                       │ 7. notifyListeners()  │                     │
         │                       │                       │                     │
         │ 8. Consumer rebuilds  │                       │                     │
         │    with new theme     │                       │                     │
         │◄──────────────────────│                       │                     │
         │                       │                       │                     │
         │ 9. UI actualizada     │                       │                     │
         │    con nuevo tema     │                       │                     │
```

## Detalles de Implementación

### ThemeProvider (Estado Global)
```dart
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  
  // Carga tema guardado al inicializar
  ThemeProvider() {
    loadTheme();
  }
  
  // Alterna tema y persiste cambio
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await PreferencesService.setDarkMode(_isDarkMode);
    notifyListeners(); // 🔄 Notifica a todos los Consumer
  }
}
```

### PreferencesService (Capa de Persistencia)
```dart
class PreferencesService {
  // Guarda en Hive
  static Future<void> setDarkMode(bool isDark) async {
    final box = await Hive.openBox('preferences_box');
    await box.put('isDarkMode', isDark);
  }
  
  // Lee desde Hive
  static Future<bool> getDarkMode() async {
    final box = await Hive.openBox('preferences_box');
    return box.get('isDarkMode', defaultValue: false);
  }
}
```

### MaterialApp (UI Reactiva)
```dart
MaterialApp(
  theme: AppTheme.theme,        // Tema claro
  darkTheme: ThemeData.dark(),  // Tema oscuro
  themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
  // 👆 Se actualiza automáticamente cuando ThemeProvider notifica cambios
)
```


## Flujo de Datos (Resumen)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│  UI (Consumer) ◄─── notifyListeners() ◄─── ThemeProvider                      │
│       │                                         │                              │
│       │                                         │                              │
│       └─── toggleTheme() ─────────────────────►│                              │
│                                                 │                              │
│                                                 ▼                              │
│                                    PreferencesService                          │
│                                                 │                              │
│                                                 ▼                              │
│                                            Hive Database                       │
│                                        (Almacenamiento Local)                  │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```