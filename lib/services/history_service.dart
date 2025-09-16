// // history_service.dart

// import 'package:http/http.dart' as https;
// import 'dart:convert';

// import 'package:shared_preferences/shared_preferences.dart';

// class HistoryService {
//   static const String _apiUrl = 'https://dashboard.cpplayers.com/api/v2/updateUserHistory';

//   static Future<void> updateUserHistory({
//     required int eventId,
//     required String eventTitle,
//     required String url,
//   }) async {
//     try {
//           final prefs = await SharedPreferences.getInstance();
//     String authKey = '${prefs.getString('auth_key')}' ;

//       // यहाँ user_id को हार्डकोड किया गया है, आप इसे अपनी ऐप की state से प्राप्त कर सकते हैं
//       final int userId = 0;
//       final int contentType = 0; // Movie के लिए
//       final int categoryId = 0; // Default category

//       final response = await https.post(
//         Uri.parse(_apiUrl),
//       headers: {
//         'auth-key': authKey,
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//         'domain': 'coretechinfo.com'
//       },
//         body: jsonEncode({
//           'user_id': userId,
//           'content_type': contentType,
//           'event_id': eventId,
//           'event_title': eventTitle,
//           'url': url,
//           'category_id': categoryId,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('✅ User history updated successfully for event: $eventTitle');
//       } else {
//         print('❌ Failed to update user history. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('❌ An error occurred while updating user history: $e');
//     }
//   }
// }

// history_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // User ID के लिए इसे इम्पोर्ट करें

class HistoryService {
  static const String _apiUrl =
      'https://dashboard.cpplayers.com/api/v2/updateUserHistory';

  // मेथड को सभी 6 फ़ील्ड्स लेने के लिए अपडेट किया गया है
  static Future<void> updateUserHistory({
    required int userId,
    required int contentType,
    required int eventId,
    required String eventTitle,
    required String url,
    required int categoryId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String authKey = '${prefs.getString('auth_key')}';
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'auth-key': authKey,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'domain': 'coretechinfo.com'
        },
        body: jsonEncode({
          'user_id': userId,
          'content_type': contentType,
          'event_id': eventId,
          'event_title': eventTitle,
          'url': url,
          'category_id': categoryId,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ User history updated successfully for event: $eventTitle');
      } else {
        print(
            '❌ Failed to update user history. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ An error occurred while updating user history: $e');
    }
  }
}

// User ID पाने के लिए एक हेल्पर फंक्शन (आप इसे अपनी ऐप की ज़रूरत के हिसाब से बदल सकते हैं)
Future<int> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  // 'user_id' को SharedPreferences से पढ़ें, अगर नहीं मिलता तो डिफ़ॉल्ट 2 मानें
  return prefs.getInt('user_id') ?? 2;
}
