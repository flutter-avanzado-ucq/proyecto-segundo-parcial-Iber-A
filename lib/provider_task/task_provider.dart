import 'package:flutter/material.dart';
import '../services/notification_service.dart';

/// Modelo de datos que representa una tarea individual
class Task {
  String title;          // Título de la tarea
  bool done;            // Estado de completado (true = completada)
  DateTime? dueDate;    // Fecha de vencimiento (opcional)
  TimeOfDay? dueTime;   // Hora de vencimiento (opcional)
  int? notificationId;  // ID de la notificación asociada (opcional)

  /// Constructor de la clase Task
  /// [title] es requerido, el resto de parámetros son opcionales
  Task({
    required this.title,
    this.done = false,    // Por defecto, las tareas no están completadas
    this.dueDate,
    this.dueTime,
    this.notificationId,
  });

  get key => null;
}

/// Provider que gestiona el estado de las tareas en la aplicación
/// Extiende ChangeNotifier para notificar cambios a los widgets que escuchan
class TaskProvider with ChangeNotifier {
  // Lista privada que almacena todas las tareas
  final List<Task> _tasks = [];

  /// Getter que retorna una lista inmutable de tareas
  /// Previene modificaciones directas desde fuera del provider
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Agrega una nueva tarea a la lista
  /// [title] - Título de la tarea (requerido)
  /// [dueDate] - Fecha de vencimiento (opcional)
  /// [dueTime] - Hora de vencimiento (opcional)
  /// [notificationId] - ID de notificación asociada (opcional)
  void addTask(String title, {DateTime? dueDate, TimeOfDay? dueTime, int? notificationId}) {
    // Inserta la nueva tarea al inicio de la lista (las más recientes primero)
    _tasks.insert(0, Task(
      title: title,
      dueDate: dueDate,
      dueTime: dueTime,
      notificationId: notificationId,
    ));
    // Notifica a todos los widgets que escuchan sobre el cambio
    notifyListeners();
  }

  /// Cambia el estado de completado de una tarea
  /// [index] - Índice de la tarea en la lista
  void toggleTask(int index) {
    // Invierte el estado actual de la tarea (completada/no completada)
    _tasks[index].done = !_tasks[index].done;
    // Notifica a los widgets sobre el cambio de estado
    notifyListeners();
  }

  /// Elimina una tarea de la lista
  /// [index] - Índice de la tarea a eliminar
  void removeTask(int index) {
    final task = _tasks[index];
    // Si la tarea tiene una notificación asociada, cancelarla antes de eliminar
    if (task.notificationId != null) {
      NotificationService.cancelNotification(task.notificationId!);
    }
    // Eliminar la tarea de la lista
    _tasks.removeAt(index);
    // Notificar sobre la eliminación
    notifyListeners();
  }

  /// Actualiza una tarea existente con nueva información
  /// [index] - Índice de la tarea a actualizar
  /// [newTitle] - Nuevo título para la tarea
  /// [newDate] - Nueva fecha de vencimiento (opcional)
  /// [newTime] - Nueva hora de vencimiento (opcional)
  /// [notificationId] - Nuevo ID de notificación (opcional)
  void updateTask(int index, String newTitle, {DateTime? newDate, TimeOfDay? newTime, int? notificationId}) {
    final task = _tasks[index];

    // Si ya tenía una notificación previa, cancelar
    if (task.notificationId != null) {
      NotificationService.cancelNotification(task.notificationId!);
    }

    // Actualizar los campos de la tarea con los nuevos valores
    _tasks[index].title = newTitle;
    _tasks[index].dueDate = newDate;
    _tasks[index].dueTime = newTime;
    _tasks[index].notificationId = notificationId;

    // Notificar a los widgets que escuchan sobre la actualización
    notifyListeners();
  }
}
