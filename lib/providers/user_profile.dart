import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  // static const String _baseUrl = 'http://192.168.43.240:5000';

  static const String _baseUrl = 'https://driving-guide.onrender.com';

  Future<void> updateLocalDialect(String userId, String newDialect) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/update_local_dialect'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'local_dialect': newDialect}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update local dialect');
    }
  }

  Future<String?> getUserDialect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('local_dialect') ?? 'TWI';
  }

  Future<void> setUserDialect(String dialect) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_dialect', dialect);
  }

  Future<void> setUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}
