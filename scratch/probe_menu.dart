import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

  try {
    final url = Uri.parse('https://ticketx.triumphhotel.com/api/guest/services');
    final request = await client.getUrl(url);
    final response = await request.close();
    
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      final List services = (data is Map && data.containsKey('data')) ? data['data'] : data;
      
      final Set<String> categories = {};
      for (var s in services) {
        categories.add(s['category']?.toString() ?? 'unknown');
      }
      
      print('Categories: $categories');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
