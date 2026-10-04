import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  // Try to login to get a session id
  final loginRes = await http.post(
    Uri.parse('https://triumphhotel.com/v1/api/guest/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'roomNumber': '405', 'resvNameId': '12345'}),
  );
  print('Login: ${loginRes.body}');
  
  final data = jsonDecode(loginRes.body);
  final sessionId = data['sessionId'] ?? data['accessToken'];
  
  // Try fetching unread count
  final unreadRes = await http.get(
    Uri.parse('https://triumphhotel.com/v1/api/guest-chat/unread-count/$sessionId'),
  );
  print('Unread Count: ${unreadRes.body}');
  
  // Try marking as read
  final markRes = await http.post(
    Uri.parse('https://triumphhotel.com/v1/api/guest-chat/mark-read/$sessionId'),
  );
  print('Mark Read: ${markRes.body}');
}
