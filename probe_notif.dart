import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://ticketx.triumphhotel.com/api/notifications?page=1&limit=50');
  
  try {
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
    });
    
    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
