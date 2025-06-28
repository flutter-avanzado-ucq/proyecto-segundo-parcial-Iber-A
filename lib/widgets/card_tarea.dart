import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/edit_task_sheet.dart';

/// Widget que representa una tarjeta individual de tarea con animaciones
class TaskCard extends StatelessWidget {
  final String title;          // Título de la tarea
  final bool isDone;          // Estado de completado
  final VoidCallback onToggle; // Callback para cambiar estado
  final VoidCallback onDelete; // Callback para eliminar
  final Animation<double> iconRotation; // Animación del ícono
  final DateTime? dueDate;    // Fecha de vencimiento opcional
  final TimeOfDay? dueTime;   // Hora de vencimiento opcional
  final int index;            // Índice en la lista

  const TaskCard({
    super.key,
    required this.title,
    required this.isDone,
    required this.onToggle,
    required this.onDelete,
    required this.iconRotation,
    required this.index,
    this.dueDate,
    this.dueTime,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isDone ? 0.4 : 1.0, // Opacidad reducida para tareas completadas
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Color verde claro para completadas, amarillo claro para pendientes
          color: isDone ? const Color(0xFFD0F0C0) : const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ListTile(
          // Ícono de estado con animación de rotación
          leading: GestureDetector(
            onTap: onToggle,
            child: AnimatedBuilder(
              animation: iconRotation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: iconRotation.value * pi,
                  child: Icon(
                    isDone ? Icons.refresh : Icons.radio_button_unchecked,
                    color: isDone ? Colors.teal : Colors.grey,
                    size: 30,
                  ),
                );
              },
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título con tachado si está completada
              Text(
                title,
                style: TextStyle(
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  fontSize: 18,
                  color: isDone ? Colors.black45 : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Información de fecha y hora si existe
              if (dueDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Vence: ${DateFormat('dd/MM/yyyy').format(dueDate!)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (dueTime != null)
                        Text(
                          'Hora: ${dueTime!.hour.toString().padLeft(2, '0')}:${dueTime!.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          // Botones de editar y eliminar
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón editar - abre bottom sheet
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => EditTaskSheet(index: index),
                  );
                },
              ),
              // Botón eliminar
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
