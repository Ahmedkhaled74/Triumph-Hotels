import 'dart:convert';
import 'dart:io';

void main() async {
  final url = Uri.parse('https://ticketx.triumphhotel.com/api/guest/requests');
  // I need a session ID to test this. 
  // Let's create a session.
  final loginUrl = Uri.parse('https://ticketx.triumphhotel.com/api/guest/login/room');
  final loginRes = await HttpClient().postUrl(loginUrl)
    ..headers.contentType = ContentType.json
    ..write(jsonEncode({
      'hotelId': '2',
      'roomNumber': '101',
      'resvNameId': 'Test', // We don't know a valid login!
    }));
  
  print('Cannot test without valid login');
}
