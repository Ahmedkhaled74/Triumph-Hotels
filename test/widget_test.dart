import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Probe Place F&B Order API', () async {
    final uri = Uri.parse('https://ticketx.triumphhotel.com/api/guest/dining/orders');
    // Using dummy but valid-looking UUIDs
    final sessionId = '47282586-7e37-47ab-b687-6a3256f064c6'; 
    final venueId = '47282586-7e37-47ab-b687-6a3256f064c6';
    final itemId = 'b5715677-b698-422d-88da-c16a007e28f8';
    
    Future<void> probe(Map<String, dynamic> body, String testName) async {
      print('--- Testing $testName ---');
      final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
      print('Status: ${res.statusCode}');
      print('Body: ${res.body}');
    }

    // Test 1: snake_case root, camelCase items
    await probe({
      'session_id': sessionId,
      'venue_id': venueId,
      'items': [{'menuItemId': itemId, 'quantity': 1, 'specialInstructions': 'test'}]
    }, 'Root snake_case, Items camelCase');

    // Test 2: snake_case root, snake_case items with special instructions
    await probe({
      'session_id': sessionId,
      'venue_id': venueId,
      'items': [{'menu_item_id': itemId, 'quantity': 1, 'special_instructions': 'test'}]
    }, 'All snake_case with special instructions');
    
    // Test 3: include total_amount
    await probe({
      'session_id': sessionId,
      'venue_id': venueId,
      'total_amount': 25.0,
      'items': [{'menu_item_id': itemId, 'quantity': 1, 'price': 25.0}]
    }, 'All snake_case with total_amount and price');

    // Test 4: query string session id fallback
    final uriWithQuery = Uri.parse('https://ticketx.triumphhotel.com/api/guest/dining/orders?sessionId=$sessionId');
    print('--- Testing Query String Fallback ---');
    final res4 = await http.post(uriWithQuery, headers: {'Content-Type': 'application/json'}, body: jsonEncode({
      'venue_id': venueId,
      'items': [{'menu_item_id': itemId, 'quantity': 1}]
    }));
    print('Status: ${res4.statusCode}');
    print('Body: ${res4.body}');
  });
}
