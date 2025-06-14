// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/main.dart';
// // import 'package:mobi_tv_entertainment/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/news_item_model.dart';
// import 'package:mobi_tv_entertainment/main.dart' as main;

// class ApiService {
//   ApiService();

//   Future<void> updateCacheOnPageEnter() async {
//     await _updateCacheInBackground();
//   }

//   List<NewsItemModel> allChannelList = [];
//   List<NewsItemModel> newsList = [];
//   List<NewsItemModel> movieList = [];
//   List<NewsItemModel> musicList = [];
//   List<NewsItemModel> entertainmentList = [];
//   List<NewsItemModel> religiousList = [];
//   List<NewsItemModel> sportsList = [];
//   List<int> allowedChannelIds = [];
//   bool tvenableAll = false;

//   final _updateController = StreamController<bool>.broadcast();
//   Stream<bool> get updateStream => _updateController.stream;

// // Future<List<NewsItemModel>> fetchMusicData() async {
// //   final response = await https.get(
// //     Uri.parse('https://api.ekomflix.com/android/getFeaturedLiveTV'),
// //     headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},

// //   );

// //   if (response.statusCode == 200) {
// //     final List<dynamic> data = json.decode(response.body);
// //     return data.map((item) => NewsItemModel.fromJson(item)).toList();
// //   } else {
// //     throw Exception('Failed to fetch music data');
// //   }
// // }

//   Future<List<NewsItemModel>> fetchMusicData() async {
//     try{
//     final response = await https.get(
//       // Uri.parse('https://api.ekomflix.com/android/getFeaturedLiveTV'),
//       Uri.parse('https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
//       headers: {'auth-key': 'vLQTuPZUxktl5mVW'},
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);

//       // List ko sort karein `index` ke basis pe (ascending order)
//       List<NewsItemModel> sortedList = data
//           .map((item) => NewsItemModel.fromJson(item))
//           .where((item) => item.index != null) // Null check
//           .toList()
//         ..sort((a, b) => int.parse(a.index).compareTo(int.parse(b.index)));

//       return sortedList;
//     } else {
//       // throw Exception('Failed to fetch music data');
//       throw Exception('Error fetching music data - Status Code: ${response.statusCode}');

//     }
//     } catch (e, stacktrace) {
//       print('Error fetching music data: $e');
//       throw Exception('Catch Error fetching music data :$e\n$stacktrace');

//     }
//   }

//   Future<List<NewsItemModel>> fetchNewsData() async {
//     final response = await https.get(
//       Uri.parse('https://api.ekomflix.com/android/getNewsData'),
//       headers: {'auth-key': 'vLQTuPZUxktl5mVW'},
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((item) => NewsItemModel.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to fetch news data');
//     }
//   }

//   Future<void> fetchSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cachedSettings = prefs.getString('settings');

//       if (cachedSettings != null) {
//         final settingsData = json.decode(cachedSettings);
//         allowedChannelIds = List<int>.from(settingsData['channels']);
//         tvenableAll = settingsData['tvenableAll'] == 1;
//       } else {
//         await _fetchAndCacheSettings();
//       }
//     } catch (e) {
//       throw Exception('Error fetching settings');
//     }
//   }

//   Future<void> _fetchAndCacheSettings() async {
//     final response = await https.get(
//       Uri.parse('https://api.ekomflix.com/android/getSettings'),
//       headers: {'auth-key': 'vLQTuPZUxktl5mVW'},
//     );

//     if (response.statusCode == 200) {
//       final settingsData = json.decode(response.body);
//       allowedChannelIds = List<int>.from(settingsData['channels']);
//       tvenableAll = settingsData['tvenableAll'] == 1;

//       final prefs = await SharedPreferences.getInstance();
//       prefs.setString('settings', response.body);
//     } else {
//       throw Exception('Failed to load settings');
//     }
//   }

//   Future<void> fetchEntertainment() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cachedEntertainment = prefs.getString('entertainment');

//       if (cachedEntertainment != null) {
//         final List<dynamic> responseData = json.decode(cachedEntertainment);
//         _processEntertainmentData(responseData);
//       } else {
//         await _fetchAndCacheEntertainment();
//       }
//     } catch (e) {
//       throw Exception('Error fetching entertainment data');
//     }
//   }

//   Future<void> _fetchAndCacheEntertainment() async {
//     final response = await https.get(
//       // Uri.parse('https://api.ekomflix.com/android/getFeaturedLiveTV'),
//       Uri.parse('https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
//       headers: {'auth-key': 'vLQTuPZUxktl5mVW'},

//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = json.decode(response.body);
//       _processEntertainmentData(responseData);

//       final prefs = await SharedPreferences.getInstance();
//       prefs.setString('entertainment', response.body);
//     } else {
//       throw Exception('Failed to load entertainment data');
//     }
//   }

//   void _processEntertainmentData(List<dynamic> responseData) {
//     List<NewsItemModel> allChannels = responseData
//         .where((channel) => _isChannelAllowed(channel))
//         .map((channel) => NewsItemModel.fromJson(channel))
//         .where((item) => item.index != null) // Null check
//         .toList()
//       ..sort((a, b) =>
//           int.parse(a.index).compareTo(int.parse(b.index))); // Sorting

//     allChannelList = allChannels;

//     newsList = allChannels
//         .where((channel) => channel.genres.contains('News'))
//         .toList();

//     movieList = allChannels
//         .where((channel) => channel.genres.contains('Movie'))
//         .toList();

//     musicList = allChannels
//         .where((channel) => channel.genres.contains('Music'))
//         .toList();

//     entertainmentList = allChannels
//         .where((channel) => channel.genres.contains('Entertainment'))
//         .toList();

//     religiousList = allChannels
//         .where((channel) => channel.genres.contains('Religious'))
//         .toList();

//     sportsList = allChannels
//         .where((channel) => channel.genres.contains('Sports'))
//         .toList();
//   }

//   bool _isChannelAllowed(dynamic channel) {
//     int channelId = int.tryParse(channel['id'].toString()) ?? 0;
//     String channelStatus = channel['status'].toString();
//     return channelStatus == "1" &&
//         (tvenableAll || allowedChannelIds.contains(channelId));
//   }

//   Future<void> _updateCacheInBackground() async {
//     try {
//       bool hasChanges = false;

//       final oldSettings = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('settings'));
//       await _fetchAndCacheSettings();
//       final newSettings = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('settings'));
//       if (oldSettings != newSettings) hasChanges = true;

//       final oldEntertainment = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('entertainment'));
//       await _fetchAndCacheEntertainment();
//       final newEntertainment = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('entertainment'));
//       if (oldEntertainment != newEntertainment) hasChanges = true;

//       if (hasChanges) {
//         _updateController.add(true);
//       }
//     } catch (e) {
//       print('Error updating cache in background: $e');
//     }
//   }

//   void dispose() {
//     _updateController.close();
//   }
// }

// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as https;
// // import 'package:mobi_tv_entertainment/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../main.dart';
// import '../models/news_item_model.dart';
// import 'package:mobi_tv_entertainment/main.dart' as main;

// class ApiService {
//   ApiService();

//   Future<void> updateCacheOnPageEnter() async {
//     await _updateCacheInBackground();
//   }

//   List<NewsItemModel> allChannelList = [];
//   List<NewsItemModel> newsList = [];
//   List<NewsItemModel> movieList = [];
//   List<NewsItemModel> musicList = [];
//   List<NewsItemModel> entertainmentList = [];
//   List<NewsItemModel> religiousList = [];
//   List<NewsItemModel> sportsList = [];
//   List<int> allowedChannelIds = [];
//   bool tvenableAll = false;

//   final _updateController = StreamController<bool>.broadcast();
//   Stream<bool> get updateStream => _updateController.stream;

//   Future<List<NewsItemModel>> fetchMusicData() async {
//     try{
//     final response = await https.get(
//       Uri.parse('https://api.ekomflix.com/android/getFeaturedLiveTV'),
//       // Uri.parse('https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
//       headers: {'x-api-key': globalAuthKey},
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);

//       // List ko sort karein `index` ke basis pe (ascending order)
//       List<NewsItemModel> sortedList = data
//           .map((item) => NewsItemModel.fromJson(item))
//           .where((item) => item.index != null) // Null check
//           .toList()
//         ..sort((a, b) => int.parse(a.index).compareTo(int.parse(b.index)));

//       return sortedList;
//     } else {
//       // throw Exception('Failed to fetch music data');
//       throw Exception('Error fetching music data - Status Code: ${response.statusCode}');

//     }
//     } catch (e, stacktrace) {
//       print('Error fetching music data: $e');
//       throw Exception('Catch Error fetching music data :$e\n$stacktrace');

//     }
//   }

//   Future<List<NewsItemModel>> fetchNewsData() async {
//     final response = await https.get(
//       Uri.parse('https://api.ekomflix.com/android/getNewsData'),
//       headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((item) => NewsItemModel.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to fetch news data');
//     }
//   }

//   Future<void> fetchSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cachedSettings = prefs.getString('settings');

//       if (cachedSettings != null) {
//         final settingsData = json.decode(cachedSettings);
//         allowedChannelIds = List<int>.from(settingsData['channels']);
//         tvenableAll = settingsData['tvenableAll'] == 1;
//       } else {
//         await _fetchAndCacheSettings();
//       }
//     } catch (e) {
//       throw Exception('Error fetching settings');
//     }
//   }

//   Future<void> _fetchAndCacheSettings() async {
//     final response = await https.get(
//       Uri.parse('https://api.ekomflix.com/android/getSettings'),
//       headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
//     );

//     if (response.statusCode == 200) {
//       final settingsData = json.decode(response.body);
//       allowedChannelIds = List<int>.from(settingsData['channels']);
//       tvenableAll = settingsData['tvenableAll'] == 1;

//       final prefs = await SharedPreferences.getInstance();
//       prefs.setString('settings', response.body);
//     } else {
//       throw Exception('Failed to load settings');
//     }
//   }

//   Future<void> fetchEntertainment() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cachedEntertainment = prefs.getString('entertainment');

//       if (cachedEntertainment != null) {
//         final List<dynamic> responseData = json.decode(cachedEntertainment);
//         _processEntertainmentData(responseData);
//       } else {
//         await _fetchAndCacheEntertainment();
//       }
//     } catch (e) {
//       throw Exception('Error fetching entertainment data');
//     }
//   }

//   Future<void> _fetchAndCacheEntertainment() async {
//     final response = await https.get(
//       Uri.parse('https://api.ekomflix.com/android/getFeaturedLiveTV'),
//       // Uri.parse('https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
//       headers: {'x-api-key': globalAuthKey},
//       // headers: {'auth-key': '${main.authKey}'},

//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = json.decode(response.body);
//       _processEntertainmentData(responseData);

//       final prefs = await SharedPreferences.getInstance();
//       prefs.setString('entertainment', response.body);
//     } else {
//       throw Exception('Failed to load entertainment data');
//     }
//   }

//   // void _processEntertainmentData(List<dynamic> responseData) {
//   //   allChannelList = responseData
//   //       .where((channel) => _isChannelAllowed(channel))
//   //       .map((channel) => NewsItemModel.fromJson(channel))
//   //       .toList();

//   //   newsList = responseData
//   //       .where((channel) =>
//   //           _isChannelAllowed(channel) &&
//   //           channel['genres'].toString().contains('News'))
//   //       .map((channel) => NewsItemModel.fromJson(channel))
//   //       .toList();

//   //   movieList = responseData
//   //       .where((channel) =>
//   //           _isChannelAllowed(channel) &&
//   //           channel['genres'].toString().contains('Movie'))
//   //       .map((channel) => NewsItemModel.fromJson(channel))
//   //       .toList();

//   //   musicList = responseData
//   //       .where((channel) =>
//   //           _isChannelAllowed(channel) &&
//   //           channel['genres'].toString().contains('Music'))
//   //       .map((channel) => NewsItemModel.fromJson(channel))
//   //       .toList();

//   //   entertainmentList = responseData
//   //       .where((channel) =>
//   //           _isChannelAllowed(channel) &&
//   //           channel['genres'].toString().contains('Entertainment'))
//   //       .map((channel) => NewsItemModel.fromJson(channel))
//   //       .toList();

//   //   religiousList = responseData
//   //       .where((channel) =>
//   //           _isChannelAllowed(channel) &&
//   //           channel['genres'].toString().contains('Religious'))
//   //       .map((channel) => NewsItemModel.fromJson(channel))
//   //       .toList();

//   //   sportsList = responseData
//   //       .where((channel) =>
//   //           _isChannelAllowed(channel) &&
//   //           channel['genres'].toString().contains('Sports'))
//   //       .map((channel) => NewsItemModel.fromJson(channel))
//   //       .toList();
//   // }

//   void _processEntertainmentData(List<dynamic> responseData) {
//     List<NewsItemModel> allChannels = responseData
//         .where((channel) => _isChannelAllowed(channel))
//         .map((channel) => NewsItemModel.fromJson(channel))
//         .where((item) => item.index != null) // Null check
//         .toList()
//       ..sort((a, b) =>
//           int.parse(a.index).compareTo(int.parse(b.index))); // Sorting

//     allChannelList = allChannels;

//     newsList = allChannels
//         .where((channel) => channel.genres.contains('News'))
//         .toList();

//     movieList = allChannels
//         .where((channel) => channel.genres.contains('Movie'))
//         .toList();

//     musicList = allChannels
//         .where((channel) => channel.genres.contains('Music'))
//         .toList();

//     entertainmentList = allChannels
//         .where((channel) => channel.genres.contains('Entertainment'))
//         .toList();

//     religiousList = allChannels
//         .where((channel) => channel.genres.contains('Religious'))
//         .toList();

//     sportsList = allChannels
//         .where((channel) => channel.genres.contains('Sports'))
//         .toList();
//   }

//   bool _isChannelAllowed(dynamic channel) {
//     int channelId = int.tryParse(channel['id'].toString()) ?? 0;
//     String channelStatus = channel['status'].toString();
//     return channelStatus == "1" &&
//         (tvenableAll || allowedChannelIds.contains(channelId));
//   }

//   Future<void> _updateCacheInBackground() async {
//     try {
//       bool hasChanges = false;

//       final oldSettings = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('settings'));
//       await _fetchAndCacheSettings();
//       final newSettings = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('settings'));
//       if (oldSettings != newSettings) hasChanges = true;

//       final oldEntertainment = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('entertainment'));
//       await _fetchAndCacheEntertainment();
//       final newEntertainment = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('entertainment'));
//       if (oldEntertainment != newEntertainment) hasChanges = true;

//       if (hasChanges) {
//         _updateController.add(true);
//       }
//     } catch (e) {
//       print('Error updating cache in background: $e');
//     }
//   }

//   void dispose() {
//     _updateController.close();
//   }
// }





// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as https;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../main.dart';
// import '../models/news_item_model.dart';

// class ApiService {
//   ApiService();

//   Future<void> updateCacheOnPageEnter() async {
//     await _updateCacheInBackground();
//   }

//   List<NewsItemModel> allChannelList = [];
//   List<NewsItemModel> newsList = [];
//   List<NewsItemModel> movieList = [];
//   List<NewsItemModel> musicList = [];
//   List<NewsItemModel> entertainmentList = [];
//   List<NewsItemModel> religiousList = [];
//   List<NewsItemModel> sportsList = [];
//   List<int> allowedChannelIds = [];
//   bool tvenableAll = false;

//   final _updateController = StreamController<bool>.broadcast();
//   Stream<bool> get updateStream => _updateController.stream;

//   // Get auth key with fallback options
//   String _getAuthKey() {
//     // Try AuthManager first (recommended)
//     if (AuthManager.hasValidAuthKey) {
//       print('🔑 Using AuthManager auth key: ${AuthManager.authKey}');
//       return AuthManager.authKey;
//     }

//     // Fallback to global variable
//     if (globalAuthKey.isNotEmpty) {
//       print('🔑 Using global auth key: $globalAuthKey');
//       return globalAuthKey;
//     }

//     print('❌ No auth key available');
//     return '';
//   }

//   // Async method to ensure auth key is loaded
//   Future<String> _getAuthKeyAsync() async {
//     // Ensure AuthManager is initialized
//     await AuthManager.initialize();

//     // Try AuthManager first
//     if (AuthManager.hasValidAuthKey) {
//       print('🔑 Using AuthManager auth key: ${AuthManager.authKey}');
//       return AuthManager.authKey;
//     }

//     // Try to load from SharedPreferences directly
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? authKey = prefs.getString('auth_key');

//       if (authKey != null && authKey.isNotEmpty) {
//         // Set it in AuthManager for future use
//         await AuthManager.setAuthKey(authKey);
//         print('🔑 Loaded auth key from SharedPreferences: $authKey');
//         return authKey;
//       }
//     } catch (e) {
//       print('❌ Error loading auth key from SharedPreferences: $e');
//     }

//     // Fallback to global variable
//     if (globalAuthKey.isNotEmpty) {
//       print('🔑 Using global auth key fallback: $globalAuthKey');
//       return globalAuthKey;
//     }

//     print('❌ No auth key available in any source');
//     throw Exception('Authentication required - please login again');
//   }

//   Future<List<NewsItemModel>> fetchMusicData() async {
//     try {
//       // Ensure we have a valid auth key
//       String authKey = await _getAuthKeyAsync();

//       if (authKey.isEmpty) {
//         throw Exception('No authentication key available');
//       }

//       print('🎵 Fetching music data with auth key: $authKey');

//       // Try different API endpoints and header combinations
//       final response = await _makeAuthenticatedRequest(
//         'https://api.ekomflix.com/android/getFeaturedLiveTV',
//         authKey,
//       );

//       print('🎵 Music API Response Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         print('🎵 Received ${data.length} music items');

//         // List ko sort karein `index` ke basis pe (ascending order)
//         List<NewsItemModel> sortedList = data
//             .map((item) => NewsItemModel.fromJson(item))
//             .where((item) => item.index != null) // Null check
//             .toList()
//           ..sort((a, b) => int.parse(a.index).compareTo(int.parse(b.index)));

//         print('✅ Music data fetched successfully: ${sortedList.length} items');
//         return sortedList;
//       } else if (response.statusCode == 403) {
//         print('❌ 403 Forbidden - Auth key might be invalid or expired');
//         print('❌ Current auth key: $authKey');
//         print('❌ Response body: ${response.body}');

//         // Try to refresh auth key
//         await _handleAuthFailure();
//         throw Exception('Authentication failed - please login again');
//       } else {
//         print('❌ Music API failed with status: ${response.statusCode}');
//         print('❌ Response body: ${response.body}');
//         throw Exception(
//             'Error fetching music data - Status Code: ${response.statusCode}');
//       }
//     } catch (e, stacktrace) {
//       print('❌ Error fetching music data: $e');
//       print('❌ Stacktrace: $stacktrace');
//       throw Exception('Error fetching music data: $e');
//     }
//   }

//   // Helper method to make authenticated requests with multiple strategies
//   Future<https.Response> _makeAuthenticatedRequest(
//       String url, String authKey) async {
//     print('🌐 Making authenticated request to: $url');
//     print('🔑 Using auth key: $authKey');

//     // Strategy 1: Use x-api-key header (current approach)
//     try {
//       final response1 = await https.get(
//         Uri.parse(url),
//         headers: {'x-api-key': authKey},
//       );

//       print('📡 Strategy 1 (x-api-key) - Status: ${response1.statusCode}');

//       if (response1.statusCode == 200) {
//         return response1;
//       } else if (response1.statusCode == 403) {
//         print(
//             '⚠️ Strategy 1 failed with 403, trying alternative approaches...');
//       }
//     } catch (e) {
//       print('❌ Strategy 1 failed: $e');
//     }

//     // Strategy 2: Use auth-key header
//     try {
//       final response2 = await https.get(
//         Uri.parse(url),
//         headers: {'auth-key': authKey},
//       );

//       print('📡 Strategy 2 (auth-key) - Status: ${response2.statusCode}');

//       if (response2.statusCode == 200) {
//         return response2;
//       }
//     } catch (e) {
//       print('❌ Strategy 2 failed: $e');
//     }

//     // Strategy 3: Use Authorization header
//     try {
//       final response3 = await https.get(
//         Uri.parse(url),
//         headers: {'Authorization': 'Bearer $authKey'},
//       );

//       print(
//           '📡 Strategy 3 (Authorization Bearer) - Status: ${response3.statusCode}');

//       if (response3.statusCode == 200) {
//         return response3;
//       }
//     } catch (e) {
//       print('❌ Strategy 3 failed: $e');
//     }

//     // Strategy 4: Try alternative API base URL with your auth key
//     try {
//       String altUrl = url.replaceAll('https://api.ekomflix.com',
//           'https://acomtv.coretechinfo.com/public/api');
//       final response4 = await https.get(
//         Uri.parse(altUrl),
//         headers: {'x-api-key': authKey},
//       );

//       print(
//           '📡 Strategy 4 (Alternative URL + x-api-key) - Status: ${response4.statusCode}');

//       if (response4.statusCode == 200) {
//         return response4;
//       }
//     } catch (e) {
//       print('❌ Strategy 4 failed: $e');
//     }

//     // Strategy 5: Try with auth-key on alternative URL
//     try {
//       String altUrl = url.replaceAll('https://api.ekomflix.com',
//           'https://acomtv.coretechinfo.com/public/api');
//       final response5 = await https.get(
//         Uri.parse(altUrl),
//         headers: {'auth-key': authKey},
//       );

//       print(
//           '📡 Strategy 5 (Alternative URL + auth-key) - Status: ${response5.statusCode}');
//       return response5; // Return even if not 200, let calling method handle
//     } catch (e) {
//       print('❌ Strategy 5 failed: $e');
//     }

//     // If all strategies fail, return a 403 response
//     return https.Response(
//         '{"error": "All authentication strategies failed"}', 403);
//   }

//   // Handle authentication failures
//   Future<void> _handleAuthFailure() async {
//     try {
//       print('🔄 Handling auth failure - clearing invalid auth key');

//       // Clear invalid auth key
//       await AuthManager.clearAuthKey();

//       // You might want to trigger a re-login here
//       // For now, just clear the stored session
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('is_logged_in', false);

//       print('✅ Invalid auth session cleared');
//     } catch (e) {
//       print('❌ Error handling auth failure: $e');
//     }
//   }

//   Future<List<NewsItemModel>> fetchNewsData() async {
//     try {
//       print('📰 Fetching news data...');

//       final response = await https.get(
//         Uri.parse('https://api.ekomflix.com/android/getNewsData'),
//         headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         print('✅ News data fetched successfully: ${data.length} items');
//         return data.map((item) => NewsItemModel.fromJson(item)).toList();
//       } else {
//         throw Exception(
//             'Failed to fetch news data - Status Code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Error fetching news data: $e');
//       throw Exception('Failed to fetch news data: $e');
//     }
//   }

//   Future<void> fetchSettings() async {
//     try {
//       print('⚙️ Fetching settings...');

//       final prefs = await SharedPreferences.getInstance();
//       final cachedSettings = prefs.getString('settings');

//       if (cachedSettings != null) {
//         print('📦 Using cached settings');
//         final settingsData = json.decode(cachedSettings);
//         allowedChannelIds = List<int>.from(settingsData['channels']);
//         tvenableAll = settingsData['tvenableAll'] == 1;
//         print('✅ Settings loaded from cache');
//       } else {
//         print('🌐 Fetching fresh settings from API');
//         await _fetchAndCacheSettings();
//       }
//     } catch (e) {
//       print('❌ Error fetching settings: $e');
//       throw Exception('Error fetching settings: $e');
//     }
//   }

//   Future<void> _fetchAndCacheSettings() async {
//     try {
//       final response = await https.get(
//         Uri.parse('https://api.ekomflix.com/android/getSettings'),
//         headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
//       );

//       if (response.statusCode == 200) {
//         final settingsData = json.decode(response.body);
//         allowedChannelIds = List<int>.from(settingsData['channels']);
//         tvenableAll = settingsData['tvenableAll'] == 1;

//         final prefs = await SharedPreferences.getInstance();
//         prefs.setString('settings', response.body);
//         print('✅ Settings fetched and cached successfully');
//       } else {
//         throw Exception(
//             'Failed to load settings - Status Code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Error fetching and caching settings: $e');
//       throw Exception('Failed to load settings: $e');
//     }
//   }

//   Future<void> fetchEntertainment() async {
//     try {
//       print('🎬 Fetching entertainment data...');

//       final prefs = await SharedPreferences.getInstance();
//       final cachedEntertainment = prefs.getString('entertainment');

//       if (cachedEntertainment != null) {
//         print('📦 Using cached entertainment data');
//         final List<dynamic> responseData = json.decode(cachedEntertainment);
//         _processEntertainmentData(responseData);
//         print('✅ Entertainment data loaded from cache');
//       } else {
//         print('🌐 Fetching fresh entertainment data from API');
//         await _fetchAndCacheEntertainment();
//       }
//     } catch (e) {
//       print('❌ Error fetching entertainment data: $e');
//       throw Exception('Error fetching entertainment data: $e');
//     }
//   }

//   Future<void> _fetchAndCacheEntertainment() async {
//     try {
//       // Ensure we have a valid auth key
//       String authKey = await _getAuthKeyAsync();

//       if (authKey.isEmpty) {
//         throw Exception('No authentication key available');
//       }

//       print('🎬 Fetching entertainment with auth key: $authKey');

//       final response = await _makeAuthenticatedRequest(
//         'https://api.ekomflix.com/android/getFeaturedLiveTV',
//         authKey,
//       );

//       print('🎬 Entertainment API Response Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final List<dynamic> responseData = json.decode(response.body);
//         print('🎬 Received ${responseData.length} entertainment items');

//         _processEntertainmentData(responseData);

//         final prefs = await SharedPreferences.getInstance();
//         prefs.setString('entertainment', response.body);
//         print('✅ Entertainment data fetched and cached successfully');
//       } else if (response.statusCode == 403) {
//         print('❌ 403 Forbidden - Auth key might be invalid or expired');
//         print('❌ Current auth key: $authKey');
//         print('❌ Response body: ${response.body}');

//         // Try to refresh auth key
//         await _handleAuthFailure();
//         throw Exception('Authentication failed - please login again');
//       } else {
//         print('❌ Entertainment API failed with status: ${response.statusCode}');
//         print('❌ Response body: ${response.body}');
//         throw Exception(
//             'Failed to load entertainment data - Status Code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Error fetching and caching entertainment: $e');
//       throw Exception('Failed to load entertainment data: $e');
//     }
//   }

//   void _processEntertainmentData(List<dynamic> responseData) {
//     try {
//       print('🔄 Processing entertainment data...');

//       List<NewsItemModel> allChannels = responseData
//           .where((channel) => _isChannelAllowed(channel))
//           .map((channel) => NewsItemModel.fromJson(channel))
//           .where((item) => item.index != null) // Null check
//           .toList()
//         ..sort((a, b) =>
//             int.parse(a.index).compareTo(int.parse(b.index))); // Sorting

//       allChannelList = allChannels;

//       newsList = allChannels
//           .where((channel) => channel.genres.contains('News'))
//           .toList();

//       movieList = allChannels
//           .where((channel) => channel.genres.contains('Movie'))
//           .toList();

//       musicList = allChannels
//           .where((channel) => channel.genres.contains('Music'))
//           .toList();

//       entertainmentList = allChannels
//           .where((channel) => channel.genres.contains('Entertainment'))
//           .toList();

//       religiousList = allChannels
//           .where((channel) => channel.genres.contains('Religious'))
//           .toList();

//       sportsList = allChannels
//           .where((channel) => channel.genres.contains('Sports'))
//           .toList();

//       print('✅ Entertainment data processed successfully:');
//       print('   📺 All channels: ${allChannelList.length}');
//       print('   📰 News: ${newsList.length}');
//       print('   🎬 Movies: ${movieList.length}');
//       print('   🎵 Music: ${musicList.length}');
//       print('   🎭 Entertainment: ${entertainmentList.length}');
//       print('   🙏 Religious: ${religiousList.length}');
//       print('   ⚽ Sports: ${sportsList.length}');
//     } catch (e) {
//       print('❌ Error processing entertainment data: $e');
//       throw Exception('Error processing entertainment data: $e');
//     }
//   }

//   bool _isChannelAllowed(dynamic channel) {
//     try {
//       int channelId = int.tryParse(channel['id'].toString()) ?? 0;
//       String channelStatus = channel['status'].toString();
//       bool isAllowed = channelStatus == "1" &&
//           (tvenableAll || allowedChannelIds.contains(channelId));
//       return isAllowed;
//     } catch (e) {
//       print('❌ Error checking channel permission: $e');
//       return false;
//     }
//   }

//   Future<void> _updateCacheInBackground() async {
//     try {
//       print('🔄 Updating cache in background...');
//       bool hasChanges = false;

//       // Update settings
//       final oldSettings = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('settings'));
//       await _fetchAndCacheSettings();
//       final newSettings = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('settings'));
//       if (oldSettings != newSettings) {
//         hasChanges = true;
//         print('📝 Settings updated');
//       }

//       // Update entertainment
//       final oldEntertainment = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('entertainment'));
//       await _fetchAndCacheEntertainment();
//       final newEntertainment = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('entertainment'));
//       if (oldEntertainment != newEntertainment) {
//         hasChanges = true;
//         print('🎬 Entertainment data updated');
//       }

//       if (hasChanges) {
//         _updateController.add(true);
//         print('✅ Cache updated successfully');
//       } else {
//         print('ℹ️ No changes detected in cache');
//       }
//     } catch (e) {
//       print('❌ Error updating cache in background: $e');
//     }
//   }

//   void dispose() {
//     _updateController.close();
//   }
// }



import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_item_model.dart';
import '../../main.dart'; // Import for AuthManager and globalAuthKey

class ApiService {
  ApiService();

  Future<void> updateCacheOnPageEnter() async {
    await _updateCacheInBackground();
  }

  List<NewsItemModel> allChannelList = [];
  List<NewsItemModel> newsList = [];
  List<NewsItemModel> movieList = [];
  List<NewsItemModel> musicList = [];
  List<NewsItemModel> entertainmentList = [];
  List<NewsItemModel> religiousList = [];
  List<NewsItemModel> sportsList = [];
  List<int> allowedChannelIds = [];
  bool tvenableAll = false;

  final _updateController = StreamController<bool>.broadcast();
  Stream<bool> get updateStream => _updateController.stream;

  // Get auth key for getFeaturedLiveTV API calls
  Future<String> _getAuthKeyForFeaturedLiveTV() async {
    try {
      // Ensure AuthManager is initialized
      await AuthManager.initialize();
      
      // Try AuthManager first
      if (AuthManager.hasValidAuthKey) {
        print('🔑 Using AuthManager auth key for getFeaturedLiveTV: ${AuthManager.authKey}');
        return AuthManager.authKey;
      }
      
      // Try global variable as fallback
      if (globalAuthKey.isNotEmpty) {
        print('🔑 Using global auth key for getFeaturedLiveTV: $globalAuthKey');
        return globalAuthKey;
      }
      
      // Try to load from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authKey = prefs.getString('auth_key');
      
      if (authKey != null && authKey.isNotEmpty) {
        print('🔑 Loaded auth key from SharedPreferences for getFeaturedLiveTV: $authKey');
        // Update AuthManager for future use
        await AuthManager.setAuthKey(authKey);
        return authKey;
      }
      
      print('❌ No auth key available for getFeaturedLiveTV');
      throw Exception('Authentication required - please login again');
    } catch (e) {
      print('❌ Error getting auth key: $e');
      throw Exception('Failed to get authentication key');
    }
  }

  Future<List<NewsItemModel>> fetchMusicData() async {
    try {
      // Get auth key for this API call
      String authKey = await _getAuthKeyForFeaturedLiveTV();
      
      print('🎵 Fetching music data with auth key: $authKey');
      
      final response = await https.get(
        Uri.parse('https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
        headers: {
          'auth-key': authKey, // Using auth-key instead of x-api-key
          'Accept': 'application/json',
        },
      );

      print('🎵 Music API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('🎵 Raw API Response: ${response.body}');
        
        final List<dynamic> data = json.decode(response.body);
        print('🎵 Received ${data.length} music items');
        
        // Debug: Print first item structure
        if (data.isNotEmpty) {
          print('🔍 First item structure: ${data.first}');
        }

        // Safe parsing with error handling for each item
        List<NewsItemModel> processedList = [];
        
        for (int i = 0; i < data.length; i++) {
          try {
            var item = data[i];
            
            // Ensure all required fields are strings
            var processedItem = _sanitizeItemData(item);
            
            NewsItemModel newsItem = NewsItemModel.fromJson(processedItem);
            
            // Only add if index is not null
            if (newsItem.index != null && newsItem.index.isNotEmpty) {
              processedList.add(newsItem);
            }
          } catch (e) {
            print('❌ Error parsing item $i: $e');
            print('❌ Problematic item: ${data[i]}');
            // Continue with next item instead of failing completely
          }
        }

        // Sort the successfully parsed items
        List<NewsItemModel> sortedList = processedList
          ..sort((a, b) {
            try {
              return int.parse(a.index).compareTo(int.parse(b.index));
            } catch (e) {
              print('⚠️ Sorting error for items: ${a.index} vs ${b.index}');
              return 0; // Keep original order if sorting fails
            }
          });

        print('✅ Music data fetched successfully: ${sortedList.length} items');
        return sortedList;
      } else if (response.statusCode == 403) {
        print('❌ 403 Forbidden - Auth key might be invalid');
        print('❌ Response: ${response.body}');
        throw Exception('Authentication failed - please login again');
      } else {
        print('❌ Music API failed with status: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        throw Exception('Error fetching music data - Status Code: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      print('❌ Error fetching music data: $e');
      print('❌ Stacktrace: $stacktrace');
      throw Exception('Error fetching music data: $e');
    }
  }

  // Helper method to sanitize API data before parsing
  Map<String, dynamic> _sanitizeItemData(dynamic item) {
    if (item is! Map<String, dynamic>) {
      throw Exception('Item is not a valid map structure');
    }
    
    Map<String, dynamic> sanitized = Map<String, dynamic>.from(item);
    
    // Convert common integer fields to strings
    List<String> fieldsToStringify = [
      'id', 'index', 'status', 'channel_id', 'category_id', 
      'subcategory_id', 'language_id', 'country_id', 'featured',
      'trending', 'is_kids_friendly', 'banner_ads', 'channel_number'
    ];
    
    for (String field in fieldsToStringify) {
      if (sanitized.containsKey(field)) {
        sanitized[field] = sanitized[field].toString();
      }
    }
    
    // Add missing required fields with default values
    Map<String, dynamic> defaultValues = {
      'poster': sanitized['banner'] ?? '', // Use banner as poster if poster missing
      'category': 'Live TV', // Default category
      'streamType': 'M3u8', // Default stream type
      'type': 'Live', // Default type
      'genres': 'Entertainment', // Default genre
      'videoId': sanitized['id'].toString(), // Use id as videoId
      'index': sanitized['channel_number']?.toString() ?? sanitized['id']?.toString() ?? '1', // Use channel_number or id as index
    };
    
    // Add missing fields
    for (String key in defaultValues.keys) {
      if (!sanitized.containsKey(key) || sanitized[key] == null || sanitized[key] == '') {
        sanitized[key] = defaultValues[key];
      }
    }
    
    // Handle genres field specially
    if (sanitized.containsKey('genres')) {
      var genres = sanitized['genres'];
      if (genres is List) {
        // Convert list to comma-separated string if it's a list
        sanitized['genres'] = genres.join(',');
      } else {
        // Ensure it's a string
        sanitized['genres'] = genres.toString();
      }
    }
    
    // Handle any other array fields that should be strings
    List<String> arrayFieldsToStringify = [
      'tags', 'actors', 'directors', 'writers'
    ];
    
    for (String field in arrayFieldsToStringify) {
      if (sanitized.containsKey(field)) {
        var value = sanitized[field];
        if (value is List) {
          sanitized[field] = value.join(',');
        } else {
          sanitized[field] = value.toString();
        }
      }
    }
    
    // Ensure all required string fields exist
    List<String> requiredStringFields = [
      'id', 'name', 'description', 'banner', 'poster', 
      'category', 'url', 'streamType', 'type', 'genres', 
      'status', 'videoId', 'index'
    ];
    
    for (String field in requiredStringFields) {
      if (!sanitized.containsKey(field) || sanitized[field] == null) {
        sanitized[field] = '';
      } else {
        sanitized[field] = sanitized[field].toString();
      }
    }
    
    print('🔧 Sanitized item: $sanitized');
    return sanitized;
  }

  // News API - uses original static key
  Future<List<NewsItemModel>> fetchNewsData() async {
    final response = await https.get(
      Uri.parse('https://acomtv.coretechinfo.com/public/api/getNewsData'),
      headers: {'x-api-key': 'vLQTuPZUxktl5mVW'}, // Static key
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => NewsItemModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch news data');
    }
  }

  // Settings API - uses original static key
  Future<void> fetchSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedSettings = prefs.getString('settings');

      if (cachedSettings != null) {
        final settingsData = json.decode(cachedSettings);
        allowedChannelIds = List<int>.from(settingsData['channels']);
        tvenableAll = settingsData['tvenableAll'] == 1;
      } else {
        await _fetchAndCacheSettings();
      }
    } catch (e) {
      throw Exception('Error fetching settings');
    }
  }

  Future<void> _fetchAndCacheSettings() async {
    final response = await https.get(
      Uri.parse('https://api.ekomflix.com/android/getSettings'),
      headers: {'x-api-key': 'vLQTuPZUxktl5mVW'}, // Static key
    );

    if (response.statusCode == 200) {
      final settingsData = json.decode(response.body);
      allowedChannelIds = List<int>.from(settingsData['channels']);
      tvenableAll = settingsData['tvenableAll'] == 1;

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('settings', response.body);
    } else {
      throw Exception('Failed to load settings');
    }
  }

  Future<void> fetchEntertainment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedEntertainment = prefs.getString('entertainment');

      if (cachedEntertainment != null) {
        final List<dynamic> responseData = json.decode(cachedEntertainment);
        _processEntertainmentData(responseData);
      } else {
        await _fetchAndCacheEntertainment();
      }
    } catch (e) {
      throw Exception('Error fetching entertainment data');
    }
  }

  Future<void> _fetchAndCacheEntertainment() async {
    try {
      // Get auth key for this API call
      String authKey = await _getAuthKeyForFeaturedLiveTV();
      
      print('🎬 Fetching entertainment with auth key: $authKey');
      
      final response = await https.get(
        Uri.parse('https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
        headers: {
          'auth-key': authKey, // Using auth-key with user's login auth key
          'Accept': 'application/json',
        },
      );

      print('🎬 Entertainment API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('🎬 Raw Entertainment API Response: ${response.body}');
        
        final List<dynamic> responseData = json.decode(response.body);
        print('🎬 Received ${responseData.length} entertainment items');
        
        // Debug: Print first item structure
        if (responseData.isNotEmpty) {
          print('🔍 First entertainment item structure: ${responseData.first}');
        }
        
        // Sanitize data before processing
        List<dynamic> sanitizedData = [];
        
        for (int i = 0; i < responseData.length; i++) {
          try {
            var sanitizedItem = _sanitizeItemData(responseData[i]);
            sanitizedData.add(sanitizedItem);
          } catch (e) {
            print('❌ Error sanitizing entertainment item $i: $e');
            print('❌ Problematic entertainment item: ${responseData[i]}');
            // Skip this item and continue
          }
        }
        
        print('🎬 Successfully sanitized ${sanitizedData.length} entertainment items');
        
        _processEntertainmentData(sanitizedData);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('entertainment', json.encode(sanitizedData));
        print('✅ Entertainment data fetched and cached successfully');
      } else if (response.statusCode == 403) {
        print('❌ 403 Forbidden - Auth key might be invalid');
        print('❌ Response: ${response.body}');
        throw Exception('Authentication failed - please login again');
      } else {
        print('❌ Entertainment API failed with status: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        throw Exception('Failed to load entertainment data - Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching and caching entertainment: $e');
      throw Exception('Failed to load entertainment data: $e');
    }
  }

  void _processEntertainmentData(List<dynamic> responseData) {
    try {
      print('🔄 Processing entertainment data...');
      
      List<NewsItemModel> allChannels = [];
      
      for (int i = 0; i < responseData.length; i++) {
        try {
          var item = responseData[i];
          
          // Check if channel is allowed before creating NewsItemModel
          if (_isChannelAllowed(item)) {
            NewsItemModel newsItem = NewsItemModel.fromJson(item);
            
            // Only add if index is not null
            if (newsItem.index != null && newsItem.index.isNotEmpty) {
              allChannels.add(newsItem);
            }
          }
        } catch (e) {
          print('❌ Error processing entertainment item $i: $e');
          print('❌ Problematic item: ${responseData[i]}');
          // Continue with next item
        }
      }

      // Sort channels
      allChannels.sort((a, b) {
        try {
          return int.parse(a.index).compareTo(int.parse(b.index));
        } catch (e) {
          print('⚠️ Sorting error for entertainment items: ${a.index} vs ${b.index}');
          return 0;
        }
      });

      allChannelList = allChannels;

      // Filter by genres
      newsList = allChannels
          .where((channel) => channel.genres.contains('News'))
          .toList();

      movieList = allChannels
          .where((channel) => channel.genres.contains('Movie'))
          .toList();

      musicList = allChannels
          .where((channel) => channel.genres.contains('Music'))
          .toList();

      entertainmentList = allChannels
          .where((channel) => channel.genres.contains('Entertainment'))
          .toList();

      religiousList = allChannels
          .where((channel) => channel.genres.contains('Religious'))
          .toList();

      sportsList = allChannels
          .where((channel) => channel.genres.contains('Sports'))
          .toList();
          
      print('✅ Entertainment data processed successfully:');
      print('   📺 All channels: ${allChannelList.length}');
      print('   📰 News: ${newsList.length}');
      print('   🎬 Movies: ${movieList.length}');
      print('   🎵 Music: ${musicList.length}');
      print('   🎭 Entertainment: ${entertainmentList.length}');
      print('   🙏 Religious: ${religiousList.length}');
      print('   ⚽ Sports: ${sportsList.length}');
    } catch (e) {
      print('❌ Error in _processEntertainmentData: $e');
      throw Exception('Error processing entertainment data: $e');
    }
  }

  bool _isChannelAllowed(dynamic channel) {
    int channelId = int.tryParse(channel['id'].toString()) ?? 0;
    String channelStatus = channel['status'].toString();
    return channelStatus == "1" &&
        (tvenableAll || allowedChannelIds.contains(channelId));
  }

  Future<void> _updateCacheInBackground() async {
    try {
      bool hasChanges = false;

      // Update settings (uses static key)
      final oldSettings = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('settings'));
      await _fetchAndCacheSettings();
      final newSettings = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('settings'));
      if (oldSettings != newSettings) hasChanges = true;

      // Update entertainment (uses user's auth key)
      final oldEntertainment = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('entertainment'));
      await _fetchAndCacheEntertainment();
      final newEntertainment = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('entertainment'));
      if (oldEntertainment != newEntertainment) hasChanges = true;

      if (hasChanges) {
        _updateController.add(true);
      }
    } catch (e) {
      print('Error updating cache in background: $e');
    }
  }

  void dispose() {
    _updateController.close();
  }
}