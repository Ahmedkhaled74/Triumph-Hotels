import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://ticketx.triumphhotel.com/api/guest/notifications/test-session-id/read-all');
  
  print('Sending PATCH to $url');
  final response = await http.patch(url);
  
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  
  final getUrl = Uri.parse('https://ticketx.triumphhotel.com/api/guest/notifications/test-session-id');
  print('\nSending GET to $getUrl');
  final getResponse = await http.get(getUrl);
  
  print('GET status: ${getResponse.statusCode}');
  print('GET body: ${getResponse.body}');
}
