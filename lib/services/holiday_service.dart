import 'dart:convert';
import 'package:http/http.dart' as http;

/// Modelo que representa un feriado público
class Holiday {
  final String localName;
  final DateTime date;

  Holiday({
    required this.localName,
    required this.date,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      localName: json['localName'],
      date: DateTime.parse(json['date']),
    );
  }
}

/// Servicio para obtener feriados públicos desde la API de Nager.Date
class HolidayService {
  static const String _baseUrl = 'https://date.nager.at/api/v3';

  /// Obtiene todos los feriados públicos del año para el país dado (por ejemplo "MX" para México)
  Future<List<Holiday>> fetchHolidays({required int year, required String countryCode}) async {
    final url = Uri.parse('$_baseUrl/PublicHolidays/$year/$countryCode');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((item) => Holiday.fromJson(item)).toList();
    } else {
      throw Exception('No se pudo obtener la lista de feriados');
    }
  }
}
