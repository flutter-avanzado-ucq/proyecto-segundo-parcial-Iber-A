import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio para manejar todas las operaciones relacionadas con notificaciones locales
/// Utiliza flutter_local_notifications para mostrar notificaciones inmediatas y programadas
class NotificationService {
  /// Plugin principal para manejar notificaciones locales
  /// Se declara como static para acceso global sin instanciación
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el sistema de notificaciones para Android e iOS
  /// Debe llamarse al inicio de la aplicación antes de usar cualquier funcionalidad de notificaciones
  static Future<void> initializeNotifications() async {
    // Configuración específica para Android - define el ícono de notificación
    const androidSettings = AndroidInitializationSettings('ic_notification');
    
    // Configuración específica para iOS/macOS (Darwin)
    const iosSettings = DarwinInitializationSettings();

    // Configuración combinada para ambas plataformas
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Inicializa las zonas horarias para notificaciones programadas
    tz.initializeTimeZones();

    // Inicializa el plugin con las configuraciones y callback de respuesta
    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  /// Callback que se ejecuta cuando el usuario toca una notificación
  /// [response] contiene información sobre la notificación tocada
  static void _onNotificationResponse(NotificationResponse response) {
    // Si la notificación tiene datos adjuntos (payload), los imprime
    if (response.payload != null) {
      print('🔔 Payload: ${response.payload}');
    }
  }

  /// Solicita permisos para mostrar notificaciones al usuario
  /// En Android verifica y solicita permisos generales
  /// En iOS solicita permisos específicos (alerta, badge, sonido)
  static Future<void> requestPermission() async {
    // Verifica si los permisos de notificación están denegados en Android
    if (await Permission.notification.isDenied ||
        await Permission.notification.isPermanentlyDenied) {
      // Solicita permisos de notificación
      await Permission.notification.request();
    }

    // Para iOS: solicita permisos específicos de notificación
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Muestra una notificación inmediata (sin programar)
  /// [title] - Título de la notificación
  /// [body] - Contenido/mensaje de la notificación
  /// [payload] - Datos opcionales adjuntos a la notificación
  static Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Configuración específica para Android con alta prioridad
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',                    // ID único del canal
      'Notificaciones Instantáneas',        // Nombre del canal visible al usuario
      channelDescription: 'Canal para notificaciones inmediatas',
      importance: Importance.high,          // Importancia alta
      priority: Priority.high,              // Prioridad alta
    );

    // Envolvemos la configuración de Android en NotificationDetails
    const details = NotificationDetails(android: androidDetails);

    // Muestra la notificación con un ID único basado en timestamp
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000), // ID único
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Programa una notificación para mostrarse en una fecha y hora específica
  /// [title] - Título de la notificación
  /// [body] - Contenido/mensaje de la notificación
  /// [scheduledDate] - Fecha y hora exacta cuando debe aparecer la notificación
  /// [notificationId] - ID único para identificar y poder cancelar la notificación
  /// [payload] - Datos opcionales adjuntos a la notificación
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    required int notificationId,
    String? payload,
  }) async {
    // Configuración específica para Android para notificaciones programadas
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',                  // ID único del canal para programadas
      'Notificaciones Programadas',         // Nombre del canal
      channelDescription: 'Canal para recordatorios de tareas',
      importance: Importance.high,          // Importancia alta
      priority: Priority.high,              // Prioridad alta
    );

    // Envolvemos la configuración en NotificationDetails
    const details = NotificationDetails(android: androidDetails);

    // Programa la notificación usando zonedSchedule para manejar zonas horarias
    await _notificationsPlugin.zonedSchedule(
      notificationId,                       // ID único para esta notificación
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local), // Convierte a zona horaria local
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Permite ejecutar incluso en modo de ahorro de batería
      payload: payload,
    );
  }

  /// Cancela una notificación programada específica
  /// [id] - ID único de la notificación a cancelar
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}