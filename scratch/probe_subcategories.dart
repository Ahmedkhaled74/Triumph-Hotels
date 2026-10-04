import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

  try {
    final url = Uri.parse('https://ticketx.triumphhotel.com/api/guest/subcategories/attraction?sessionId=d6b2a3a6-491f-42c8-a6bc-9e9cb3006e64&language=ja');
    final request = await client.getUrl(url);
    final response = await request.close();
    
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(responseBody);
      print('Subcategories Response: $data');
    } else {
      print('Subcategories Status: ${response.statusCode}');
      print('Subcategories Body: $responseBody');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
