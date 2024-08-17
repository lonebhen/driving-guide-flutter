import 'dart:convert';
import 'package:driving_guide/providers/user_profile.dart';
import 'package:http/http.dart' as http;


class OtpProvider {

  // static const String _baseUrl = 'http://192.168.43.240:5000';
  static const String _baseUrl = 'https://driving-guide.onrender.com';
  UserProfile userProfile = new UserProfile();

  Future<Map<String, dynamic>> generateOtp(String msisdn) async {
    final url = Uri.parse('$_baseUrl/generate-otp');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'msisdn': msisdn});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to generate OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> validateOtp(String code, String msisdn) async {
    final url = Uri.parse('$_baseUrl/validate-otp');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'code': code, 'msisdn': msisdn});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        userProfile.setUserId(msisdn);
        userProfile.setUserDialect("TWI");
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to validate OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

}