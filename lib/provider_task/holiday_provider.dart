import 'package:flutter/material.dart';
import '../services/holiday_service.dart';

class HolidayProvider extends ChangeNotifier {
  final HolidayService _holidayService = HolidayService();
  List<Holiday>? _holidays;
  bool _isLoading = false;
  String? _errorMessage;

  List<Holiday>? get holidays => _holidays;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga los feriados del país y año especificados
  Future<void> loadHolidays(
      {required int year, required String countryCode}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final data = await _holidayService.fetchHolidays(
          year: year, countryCode: countryCode);
      _holidays = data;
    } catch (e) {
      _errorMessage = 'No se pudo obtener los feriados';
    }

    _isLoading = false;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Verifica si hoy es feriado
  Holiday? get todayHoliday {
    if (_holidays == null) return null;

    //final today = DateTime.now();
    final today = DateTime(2025, 9, 16); // fecha de prueba
    try {
      return _holidays!.firstWhere(
        (holiday) =>
            holiday.date.year == today.year &&
            holiday.date.month == today.month &&
            holiday.date.day == today.day,
      );
    } catch (_) {
      return null;
    }
  }
}
