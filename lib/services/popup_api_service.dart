import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:triumph_hotels/models/popup_offer.dart';

class PopupApiService {
  static const String baseUrl = 'https://triumphhotel.com/api/popup-offer/';

  Future<PopupOffer?> getActivePopup() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['offer'] != null) {
          return PopupOffer.fromJson(data['offer']);
        }
      }
    } catch (e) {
      print("Error fetching popup: $e");
    }
    return null;
  }
}
