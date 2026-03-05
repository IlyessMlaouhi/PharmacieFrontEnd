import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

class EmployeeService {
  // change this to your machine's IP — NOT localhost
  // on Android emulator, 10.0.2.2 maps to your PC's localhost


  static const String _baseUrl = 'http://192.168.100.7:8080/api/v1/employees';
  // GET /api/v1/employees
  Future<List<Employee>> getAllEmployees() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Employee.fromJson(json)).toList();
    }
    throw Exception('Failed to load employees: ${response.body}');
  }

  // POST /api/v1/employees
  Future<Employee> createEmployee(Employee employee) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(employee.toJson()),
    );
    if (response.statusCode == 201) {
      return Employee.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create employee: ${response.body}');
  }

  // PUT /api/v1/employees/{id}
  Future<Employee> updateEmployee(int id, Employee employee) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(employee.toJson()),
    );
    if (response.statusCode == 200) {
      return Employee.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update employee: ${response.body}');
  }

  // DELETE /api/v1/employees/{id}
  Future<void> deleteEmployee(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete employee: ${response.body}');
    }
  }
}