import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider_task/task_provider.dart';
import '../services/notification_service.dart';

/// Bottom sheet para editar tareas existentes
class EditTaskSheet extends StatefulWidget {
  final int index; // Índice de la tarea a editar

  const EditTaskSheet({super.key, required this.index});

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late TextEditingController _controller; // Controlador del campo de texto
  DateTime? _selectedDate;               // Fecha seleccionada
  TimeOfDay? _selectedTime;              // Hora seleccionada

  @override
  void initState() {
    super.initState();
    // Obtiene la tarea actual y pre-llena los campos
    final task = Provider.of<TaskProvider>(context, listen: false).tasks[widget.index];
    _controller = TextEditingController(text: task.title);
    _selectedDate = task.dueDate;
    _selectedTime = task.dueTime ?? const TimeOfDay(hour: 8, minute: 0); // Hora por defecto
  }

  /// Guarda los cambios de la tarea editada
  void _submit() async {
    final newTitle = _controller.text.trim();
    if (newTitle.isNotEmpty) {
      int? notificationId;

      final task = Provider.of<TaskProvider>(context, listen: false).tasks[widget.index];

      // Cancela la notificación anterior si existe
      if (task.notificationId != null) {
        await NotificationService.cancelNotification(task.notificationId!);
      }

      // Notificación inmediata de actualización
      await NotificationService.showImmediateNotification(
        title: 'Tarea actualizada',
        body: 'Has actualizado la tarea: $newTitle',
        payload: 'Tarea actualizada: $newTitle',
      );

      // Programa nueva notificación si hay fecha y hora
      if (_selectedDate != null && _selectedTime != null) {
        final scheduledDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

        await NotificationService.scheduleNotification(
          title: 'Recordatorio de tarea actualizada',
          body: 'No olvides: $newTitle',
          scheduledDate: scheduledDateTime,
          payload: 'Tarea actualizada: $newTitle para $scheduledDateTime',
          notificationId: notificationId,
        );
      }

      // Actualiza la tarea en el provider
      Provider.of<TaskProvider>(context, listen: false).updateTask(
        widget.index,
        newTitle,
        newDate: _selectedDate,
        newTime: _selectedTime,
        notificationId: notificationId,
      );

      Navigator.pop(context);
    }
  }

  /// Muestra selector de fecha
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now, // Usa fecha actual o la ya seleccionada
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Muestra selector de hora
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(), // Usa hora actual o la ya seleccionada
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Ajuste para teclado
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título del sheet
          const Text('Editar tarea', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          // Campo de texto pre-llenado
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          
          // Selector de fecha
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickDate,
                child: const Text('Cambiar fecha'),
              ),
              const SizedBox(width: 10),
              if (_selectedDate != null)
                Text('${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            ],
          ),
          const SizedBox(height: 12),
          
          // Selector de hora
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickTime,
                child: const Text('Cambiar hora'),
              ),
              const SizedBox(width: 10),
              const Text('Hora: '),
              if (_selectedTime != null)
                Text('${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'),
            ],
          ),
          const SizedBox(height: 12),
          
          // Botón de guardar
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check),
            label: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}
