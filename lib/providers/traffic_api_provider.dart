import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class TrafficApiProvider {
  static const String _baseUrl = 'http://192.168.43.240:5000/predict';

  Future<String?> uploadImage(File image) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_baseUrl),
      );
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        return response.headers['content-disposition']!;
      } else {
        print('Failed to upload image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
