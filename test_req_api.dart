import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // Using the session ID from earlier: 78cc0f2e-f68b-4e08-a611-874708d4149b
  final sessionId = '78cc0f2e-f68b-4e08-a611-874708d4149b';
  final url = Uri.parse('https://ticketx.triumphhotel.com/api/guest/requests/$sessionId');
  
  final res = await http.get(url, headers: {'Content-Type': 'application/json'});
  print('Status: ${res.statusCode}');
  
  try {
    final body = jsonDecode(res.body);
    if (body is List && body.isNotEmpty) {
      print('Keys of first request: ${body.first.keys.toList()}');
      print('Unread fields? ${body.first.keys.where((k) => k.toString().toLowerCase().contains("unread")).toList()}');
      print('First request: ${body.first}');
    } else if (body is Map && body.containsKey('data')) {
       print('Keys of first request in data: ${body['data'].first.keys.toList()}');
       print('First request in data: ${body['data'].first}');
    }
  } catch (e) {
    print('Failed: $e');
  }
}
