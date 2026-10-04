import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

  try {
    final url = Uri.parse('https://ticketx.triumphhotel.com/api/guest/admin/place-categories?sessionId=d6b2a3a6-491f-42c8-a6bc-9e9cb3006e64&language=ja');
    final request = await client.getUrl(url);
    final response = await request.close();
    
    final responseBody = await response.transform(utf8.decoder).join();
    final categories = jsonDecode(responseBody);
    
    for (final cat in categories) {
      final originalName = cat['original_name'];
      if (originalName != null) {
        final subUrl = Uri.parse('https://ticketx.triumphhotel.com/api/guest/subcategories/$originalName?sessionId=d6b2a3a6-491f-42c8-a6bc-9e9cb3006e64&language=ja');
        final subReq = await client.getUrl(subUrl);
        final subRes = await subReq.close();
        final subBody = await subRes.transform(utf8.decoder).join();
        print('Subcategories for $originalName: $subBody');
      }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
