import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

  try {
    final url = Uri.parse('https://ticketx.triumphhotel.com/api/guest/services/all?sessionId=d6b2a3a6-491f-42c8-a6bc-9e9cb3006e64&language=ja');
    final request = await client.getUrl(url);
    final response = await request.close();
    
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      if (data is Map && data.containsKey('services')) {
        final List services = data['services'];
        print('Total services: ${services.length}');
        if (services.isNotEmpty) {
          print('First service keys: ${services.first.keys}');
          for (var i = 0; i < (services.length > 5 ? 5 : services.length); i++) {
            print(services[i]);
          }
        }
      } else if (data is List) {
        print('Total services: ${data.length}');
        if (data.isNotEmpty) {
          print('First service keys: ${data.first.keys}');
          for (var i = 0; i < (data.length > 5 ? 5 : data.length); i++) {
            print(data[i]);
          }
        }
      } else {
        print('Data format: $data');
      }
    } else {
      print('Status: ${response.statusCode}');
      print('Body: $responseBody');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
