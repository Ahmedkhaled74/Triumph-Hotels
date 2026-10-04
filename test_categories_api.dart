import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://ticketx.triumphhotel.com/api/guest/admin/place-categories?sessionId=dummy_session_id');
  final response = await http.get(url, headers: {
    'Accept': 'application/json',
    'Accept-Language': 'ar',
  });
  print('Categories (ar): \${response.body}');
  
  final responseEn = await http.get(url, headers: {
    'Accept': 'application/json',
    'Accept-Language': 'en',
  });
  print('Categories (en): \${responseEn.body}');
}
