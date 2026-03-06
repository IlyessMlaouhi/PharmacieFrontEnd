import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shift.dart';

class ShiftService {
  static const String _baseUrl = 'http://192.168.100.7:8080/api/v1/shifts';

  // GET /api/v1/shifts?from=yyyy-MM-dd&to=yyyy-MM-dd
  Future<List<Shift>> getShiftsByDateRange(String from, String to) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?from=$from&to=$to'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Shift.fromJson(json)).toList();
    }
    throw Exception('Failed to load shifts: ${response.body}');
  }

  // POST /api/v1/shifts
  Future<Shift> createShift(Shift shift) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(shift.toJson()),
    );
    if (response.statusCode == 201) {
      return Shift.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create shift: ${response.body}');
  }

  // PUT /api/v1/shifts/{id}
  Future<Shift> updateShift(int id, Shift shift) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(shift.toJson()),
    );
    if (response.statusCode == 200) {
      return Shift.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update shift: ${response.body}');
  }

  // DELETE /api/v1/shifts/{id}
  Future<void> deleteShift(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete shift: ${response.body}');
    }
  }
}