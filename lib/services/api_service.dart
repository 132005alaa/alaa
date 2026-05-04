import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/daily_info.dart';

class ApiService {
  static const String apiUrl =
      'https://sheet.best/api/sheets/5ee77fdc-123c-47c5-8756-2d4a66ccfdc9';

  Future<List<DailyInfo>> fetchAllInfo() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => DailyInfo.fromJson(json)).toList();
      } else {
        throw Exception('فشل في التحميل: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('حدث خطأ: $e');
    }
  }
}
