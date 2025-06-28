import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider_task/task_provider.dart';
import '../services/notification_service.dart';

/// Widget que muestra un bottom sheet para agregar nuevas tareas
/// Permite al usuario ingresar título, fecha y hora de vencimiento
class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

/// Estado del widget AddTaskSheet que maneja la lógica de entrada de datos
class _AddTaskSheetState extends State<AddTaskSheet> {
  // Controlador para el campo de texto del título de la tarea
  final _controller = TextEditingController();
  // Fecha seleccionada para el vencimiento (opcional)
  DateTime? _selectedDate;
  // Hora seleccionada para el vencimiento (opcional)
  TimeOfDay? _selectedTime;

  /// Limpia los recursos cuando el widget se destruye
  @override
  void dispose() {
    // Libera la memoria del controlador de texto
    _controller.dispose();
    super.dispose();
  }

  /// Procesa la creación de una nueva tarea cuando el usuario confirma
  /// Valida los datos, crea notificaciones y agrega la tarea al provider
  void _submit() async {
    // Obtiene el texto del campo y elimina espacios en blanco
    final text = _controller.text.trim();
    
    // Solo procede si hay texto ingresado
    if (text.isNotEmpty) {
      int? notificationId;

      // Muestra una notificación inmediata confirmando la creación de la tarea
      await NotificationService.showImmediateNotification(
        title: 'Nueva tarea',
        body: 'Has agregado la tarea: $text',
        payload: 'Tarea: $text',
      );

      // Si se seleccionaron fecha y hora, programa una notificación recordatoria
      if (_selectedDate != null && _selectedTime != null) {
        // Combina la fecha y hora seleccionadas en un solo DateTime
        final scheduledDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        // Genera un ID único para la notificación programada
        notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

        // Programa la notificación recordatoria
        await NotificationService.scheduleNotification(
          title: 'Recordatorio de tarea',
          body: 'No olvides: $text',
          scheduledDate: scheduledDateTime,
          payload: 'Tarea programada: $text para $scheduledDateTime',
          notificationId: notificationId,
        );
      }

      // Agrega la tarea al provider usando Provider.of sin escuchar cambios
      Provider.of<TaskProvider>(context, listen: false).addTask(
        text,
        dueDate: _selectedDate,
        dueTime: _selectedTime,
        notificationId: notificationId,
      );

      // Cierra el bottom sheet después de agregar la tarea
      Navigator.pop(context);
    }
  }

  /// Muestra un selector de fecha y actualiza _selectedDate
  /// Solo permite seleccionar fechas futuras (desde hoy hasta 5 años adelante)
  Future<void> _pickDate() async {
    final now = DateTime.now();
    // Muestra el selector de fecha nativo
    final picked = await showDatePicker(
      context: context,
      initialDate: now,              // Fecha inicial es hoy
      firstDate: now,                // No permite fechas pasadas
      lastDate: DateTime(now.year + 5), // Hasta 5 años en el futuro
    );
    
    // Si el usuario seleccionó una fecha, actualiza el estado
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Muestra un selector de hora y actualiza _selectedTime
  /// Permite seleccionar cualquier hora del día
  Future<void> _pickTime() async {
    // Muestra el selector de hora nativo
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(), // Hora inicial es la actual
    );
    
    // Si el usuario seleccionó una hora, actualiza el estado
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// Construye la interfaz del bottom sheet para agregar tareas
  /// Incluye campo de texto, selectores de fecha/hora y botón de confirmación
  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding dinámico que se ajusta cuando aparece el teclado
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Se ajusta al teclado
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ocupa solo el espacio necesario
        children: [
          // Título del bottom sheet
          const Text(
            'Agregar nueva tarea', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 12),
          
          // Campo de texto para el título de la tarea
          TextField(
            controller: _controller,
            autofocus: true, // Automáticamente enfoca este campo
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
            // Permite enviar con Enter
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          
          // Fila para selector de fecha
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickDate,
                child: const Text('Seleccionar fecha'),
              ),
              const SizedBox(width: 10),
              // Muestra la fecha seleccionada si existe
              if (_selectedDate != null)
                Text('${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            ],
          ),
          const SizedBox(height: 12),
          
          // Fila para selector de hora
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickTime,
                child: const Text('Seleccionar hora'),
              ),
              const SizedBox(width: 10),
              const Text('Hora: '),
              // Muestra la hora seleccionada si existe, formateada con ceros a la izquierda
              if (_selectedTime != null)
                Text('${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'),
            ],
          ),
          const SizedBox(height: 12),
          
          // Botón principal para confirmar y agregar la tarea
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check),
            label: const Text('Agregar tarea'),
          ),
        ],
      ),
    );
  }
}
