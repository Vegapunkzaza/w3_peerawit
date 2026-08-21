import 'dart:convert';

import 'package:http/http.dart' as http;
import 'model.dart';

class ApiService {
  static Future<List<Model>> fetchStudent() async {
    final response = await http.get(
      Uri.parse("https://6a7eb3a53183f5fd884a57a0.mockapi.io/student"),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonDate = jsonDecode(response.body);
      return jsonDate.map((json) => Model.fromJson(json)).toList();
    } else {
      throw Exception("ไม่สามารถโหลดข้อมูลได้");
    }
  }
}
