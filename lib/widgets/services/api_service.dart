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
//       return AuthManager.authKey;
//     }

//     // Fallback to global variable
//     if (globalAuthKey.isNotEmpty) {
//       return globalAuthKey;
//     }

//     return '';
//   }

//   // Async method to ensure auth key is loaded
//   Future<String> _getAuthKeyAsync() async {
//     // Ensure AuthManager is initialized
//     await AuthManager.initialize();

//     // Try AuthManager first
//     if (AuthManager.hasValidAuthKey) {
//       return AuthManager.authKey;
//     }

//     // Try to load from SharedPreferences directly
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? authKey = prefs.getString('auth_key');

//       if (authKey != null && authKey.isNotEmpty) {
//         // Set it in AuthManager for future use
//         await AuthManager.setAuthKey(authKey);
//         return authKey;
//       }
//     } catch (e) {
//     }

//     // Fallback to global variable
//     if (globalAuthKey.isNotEmpty) {
//       return globalAuthKey;
//     }

//     throw Exception('Authentication required - please login again');
//   }

//   Future<List<NewsItemModel>> fetchMusicData() async {
//     try {
//       // Ensure we have a valid auth key
//       String authKey = await _getAuthKeyAsync();

//       if (authKey.isEmpty) {
//         throw Exception('No authentication key available');
//       }

//       // Try different API endpoints and header combinations
//       final response = await _makeAuthenticatedRequest(
//         'https://api.ekomflix.com/android/getFeaturedLiveTV',
//         authKey,
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);

//         // List ko sort karein `index` ke basis pe (ascending order)
//         List<NewsItemModel> sortedList = data
//             .map((item) => NewsItemModel.fromJson(item))
//             .where((item) => item.index != null) // Null check
//             .toList()
//           ..sort((a, b) => int.parse(a.index).compareTo(int.parse(b.index)));

//         return sortedList;
//       } else if (response.statusCode == 403) {

//         // Try to refresh auth key
//         await _handleAuthFailure();
//         throw Exception('Authentication failed - please login again');
//       } else {
//         throw Exception(
//             'Error fetching music data - Status Code: ${response.statusCode}');
//       }
//     } catch (e, stacktrace) {
//       throw Exception('Error fetching music data: $e');
//     }
//   }

//   // Helper method to make authenticated requests with multiple strategies
//   Future<https.Response> _makeAuthenticatedRequest(
//       String url, String authKey) async {

//     // Strategy 1: Use x-api-key header (current approach)
//     try {
//       final response1 = await https.get(
//         Uri.parse(url),
//         headers: {'x-api-key': authKey},
//       );

//       if (response1.statusCode == 200) {
//         return response1;
//       } else if (response1.statusCode == 403) {
//             '⚠️ Strategy 1 failed with 403, trying alternative approaches...');
//       }
//     } catch (e) {
//     }

//     // Strategy 2: Use auth-key header
//     try {
//       final response2 = await https.get(
//         Uri.parse(url),
//         headers: {'auth-key': authKey},
//       );

//       if (response2.statusCode == 200) {
//         return response2;
//       }
//     } catch (e) {
//     }

//     // Strategy 3: Use Authorization header
//     try {
//       final response3 = await https.get(
//         Uri.parse(url),
//         headers: {'Authorization': 'Bearer $authKey'},
//       );

//           '📡 Strategy 3 (Authorization Bearer) - Status: ${response3.statusCode}');

//       if (response3.statusCode == 200) {
//         return response3;
//       }
//     } catch (e) {
//     }

//     // Strategy 4: Try alternative API base URL with your auth key
//     try {
//       String altUrl = url.replaceAll('https://api.ekomflix.com',
//           'https://acomtv.coretechinfo.com/public/api');
//       final response4 = await https.get(
//         Uri.parse(altUrl),
//         headers: {'x-api-key': authKey},
//       );

//           '📡 Strategy 4 (Alternative URL + x-api-key) - Status: ${response4.statusCode}');

//       if (response4.statusCode == 200) {
//         return response4;
//       }
//     } catch (e) {
//     }

//     // Strategy 5: Try with auth-key on alternative URL
//     try {
//       String altUrl = url.replaceAll('https://api.ekomflix.com',
//           'https://acomtv.coretechinfo.com/public/api');
//       final response5 = await https.get(
//         Uri.parse(altUrl),
//         headers: {'auth-key': authKey},
//       );

//           '📡 Strategy 5 (Alternative URL + auth-key) - Status: ${response5.statusCode}');
//       return response5; // Return even if not 200, let calling method handle
//     } catch (e) {
//     }

//     // If all strategies fail, return a 403 response
//     return https.Response(
//         '{"error": "All authentication strategies failed"}', 403);
//   }

//   // Handle authentication failures
//   Future<void> _handleAuthFailure() async {
//     try {

//       // Clear invalid auth key
//       await AuthManager.clearAuthKey();

//       // You might want to trigger a re-login here
//       // For now, just clear the stored session
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('is_logged_in', false);

//     } catch (e) {
//     }
//   }

//   Future<List<NewsItemModel>> fetchNewsData() async {
//     try {

//       final response = await https.get(
//         Uri.parse('https://api.ekomflix.com/android/getNewsData'),
//         headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         return data.map((item) => NewsItemModel.fromJson(item)).toList();
//       } else {
//         throw Exception(
//             'Failed to fetch news data - Status Code: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to fetch news data: $e');
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
//       } else {
//         throw Exception(
//             'Failed to load settings - Status Code: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load settings: $e');
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

//       final response = await _makeAuthenticatedRequest(
//         'https://api.ekomflix.com/android/getFeaturedLiveTV',
//         authKey,
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> responseData = json.decode(response.body);

//         _processEntertainmentData(responseData);

//         final prefs = await SharedPreferences.getInstance();
//         prefs.setString('entertainment', response.body);
//       } else if (response.statusCode == 403) {

//         // Try to refresh auth key
//         await _handleAuthFailure();
//         throw Exception('Authentication failed - please login again');
//       } else {
//         throw Exception(
//             'Failed to load entertainment data - Status Code: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load entertainment data: $e');
//     }
//   }

//   void _processEntertainmentData(List<dynamic> responseData) {
//     try {

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

//     } catch (e) {
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
//       return false;
//     }
//   }

//   Future<void> _updateCacheInBackground() async {
//     try {
//       bool hasChanges = false;

//       // Update settings
//       final oldSettings = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('settings'));
//       await _fetchAndCacheSettings();
//       final newSettings = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('settings'));
//       if (oldSettings != newSettings) {
//         hasChanges = true;
//       }

//       // Update entertainment
//       final oldEntertainment = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('entertainment'));
//       await _fetchAndCacheEntertainment();
//       final newEntertainment = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('entertainment'));
//       if (oldEntertainment != newEntertainment) {
//         hasChanges = true;
//       }

//       if (hasChanges) {
//         _updateController.add(true);
//       } else {
//       }
//     } catch (e) {
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
// import '../models/news_item_model.dart';
// import '../../main.dart'; // Import for AuthManager and globalAuthKey

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

//   // Get auth key for getFeaturedLiveTV API calls
//   Future<String> _getAuthKeyForFeaturedLiveTV() async {
//     try {
//       // Ensure AuthManager is initialized
//       await AuthManager.initialize();

//       // Try AuthManager first
//       if (AuthManager.hasValidAuthKey) {
//         return AuthManager.authKey;
//       }

//       // Try global variable as fallback
//       if (globalAuthKey.isNotEmpty) {
//         return globalAuthKey;
//       }

//       // Try to load from SharedPreferences
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? authKey = prefs.getString('auth_key');

//       if (authKey != null && authKey.isNotEmpty) {
//         // Update AuthManager for future use
//         await AuthManager.setAuthKey(authKey);
//         return authKey;
//       }

//       throw Exception('Authentication required - please login again');
//     } catch (e) {
//       throw Exception('Failed to get authentication key');
//     }
//   }

//   Future<List<NewsItemModel>> fetchMusicData() async {
//     try {
//       // Get auth key for this API call
//       String authKey = await _getAuthKeyForFeaturedLiveTV();

//       final response = await https.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
//         headers: {
//           'auth-key': authKey, // Using auth-key instead of x-api-key
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {

//         final List<dynamic> data = json.decode(response.body);

//         // Debug: Print first item structure
//         if (data.isNotEmpty) {
//         }

//         // Safe parsing with error handling for each item
//         List<NewsItemModel> processedList = [];

//         for (int i = 0; i < data.length; i++) {
//           try {
//             var item = data[i];

//             // Ensure all required fields are strings
//             var processedItem = _sanitizeItemData(item);

//             NewsItemModel newsItem = NewsItemModel.fromJson(processedItem);

//             // Only add if index is not null
//             if (newsItem.index != null && newsItem.index.isNotEmpty) {
//               processedList.add(newsItem);
//             }
//           } catch (e) {
//             // Continue with next item instead of failing completely
//           }
//         }

//         // Sort the successfully parsed items
//         List<NewsItemModel> sortedList = processedList
//           ..sort((a, b) {
//             try {
//               return int.parse(a.index).compareTo(int.parse(b.index));
//             } catch (e) {
//               return 0; // Keep original order if sorting fails
//             }
//           });

//         return sortedList;
//       } else if (response.statusCode == 403) {
//         throw Exception('Authentication failed - please login again');
//       } else {
//         throw Exception('Error fetching music data - Status Code: ${response.statusCode}');
//       }
//     } catch (e, stacktrace) {
//       throw Exception('Error fetching music data: $e');
//     }
//   }

//   // Helper method to sanitize API data before parsing
//   Map<String, dynamic> _sanitizeItemData(dynamic item) {
//     if (item is! Map<String, dynamic>) {
//       throw Exception('Item is not a valid map structure');
//     }

//     Map<String, dynamic> sanitized = Map<String, dynamic>.from(item);

//     // Convert common integer fields to strings
//     List<String> fieldsToStringify = [
//       'id', 'index', 'status', 'channel_id', 'category_id',
//       'subcategory_id', 'language_id', 'country_id', 'featured',
//       'trending', 'is_kids_friendly', 'banner_ads', 'channel_number'
//     ];

//     for (String field in fieldsToStringify) {
//       if (sanitized.containsKey(field)) {
//         sanitized[field] = sanitized[field].toString();
//       }
//     }

//     // Add missing required fields with default values
//     Map<String, dynamic> defaultValues = {
//       'poster': sanitized['banner'] ?? '', // Use banner as poster if poster missing
//       'category': 'Live TV', // Default category
//       'streamType': 'M3u8', // Default stream type
//       'type': 'Live', // Default type
//       'genres': 'Entertainment', // Default genre
//       'videoId': sanitized['id'].toString(), // Use id as videoId
//       'index': sanitized['channel_number']?.toString() ?? sanitized['id']?.toString() ?? '1', // Use channel_number or id as index
//     };

//     // Add missing fields
//     for (String key in defaultValues.keys) {
//       if (!sanitized.containsKey(key) || sanitized[key] == null || sanitized[key] == '') {
//         sanitized[key] = defaultValues[key];
//       }
//     }

//     // Handle genres field specially
//     if (sanitized.containsKey('genres')) {
//       var genres = sanitized['genres'];
//       if (genres is List) {
//         // Convert list to comma-separated string if it's a list
//         sanitized['genres'] = genres.join(',');
//       } else {
//         // Ensure it's a string
//         sanitized['genres'] = genres.toString();
//       }
//     }

//     // Handle any other array fields that should be strings
//     List<String> arrayFieldsToStringify = [
//       'tags', 'actors', 'directors', 'writers'
//     ];

//     for (String field in arrayFieldsToStringify) {
//       if (sanitized.containsKey(field)) {
//         var value = sanitized[field];
//         if (value is List) {
//           sanitized[field] = value.join(',');
//         } else {
//           sanitized[field] = value.toString();
//         }
//       }
//     }

//     // Ensure all required string fields exist
//     List<String> requiredStringFields = [
//       'id', 'name', 'description', 'banner', 'poster',
//       'category', 'url', 'streamType', 'type', 'genres',
//       'status', 'videoId', 'index'
//     ];

//     for (String field in requiredStringFields) {
//       if (!sanitized.containsKey(field) || sanitized[field] == null) {
//         sanitized[field] = '';
//       } else {
//         sanitized[field] = sanitized[field].toString();
//       }
//     }

//     return sanitized;
//   }

//   // News API - uses original static key
//   Future<List<NewsItemModel>> fetchNewsData() async {
//     final response = await https.get(
//       Uri.parse('https://acomtv.coretechinfo.com/public/api/getNewsData'),
//       headers: {'x-api-key': 'vLQTuPZUxktl5mVW'}, // Static key
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((item) => NewsItemModel.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to fetch news data');
//     }
//   }

//   // Settings API - uses original static key
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
//       headers: {'x-api-key': 'vLQTuPZUxktl5mVW'}, // Static key
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
//     try {
//       // Get auth key for this API call
//       String authKey = await _getAuthKeyForFeaturedLiveTV();

//       final response = await https.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
//         headers: {
//           'auth-key': authKey, // Using auth-key with user's login auth key
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {

//         final List<dynamic> responseData = json.decode(response.body);

//         // Debug: Print first item structure
//         if (responseData.isNotEmpty) {
//         }

//         // Sanitize data before processing
//         List<dynamic> sanitizedData = [];

//         for (int i = 0; i < responseData.length; i++) {
//           try {
//             var sanitizedItem = _sanitizeItemData(responseData[i]);
//             sanitizedData.add(sanitizedItem);
//           } catch (e) {
//             // Skip this item and continue
//           }
//         }

//         _processEntertainmentData(sanitizedData);

//         final prefs = await SharedPreferences.getInstance();
//         prefs.setString('entertainment', json.encode(sanitizedData));
//       } else if (response.statusCode == 403) {
//         throw Exception('Authentication failed - please login again');
//       } else {
//         throw Exception('Failed to load entertainment data - Status Code: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load entertainment data: $e');
//     }
//   }

//   void _processEntertainmentData(List<dynamic> responseData) {
//     try {

//       List<NewsItemModel> allChannels = [];

//       for (int i = 0; i < responseData.length; i++) {
//         try {
//           var item = responseData[i];

//           // Check if channel is allowed before creating NewsItemModel
//           if (_isChannelAllowed(item)) {
//             NewsItemModel newsItem = NewsItemModel.fromJson(item);

//             // Only add if index is not null
//             if (newsItem.index != null && newsItem.index.isNotEmpty) {
//               allChannels.add(newsItem);
//             }
//           }
//         } catch (e) {
//           // Continue with next item
//         }
//       }

//       // Sort channels
//       allChannels.sort((a, b) {
//         try {
//           return int.parse(a.index).compareTo(int.parse(b.index));
//         } catch (e) {
//           return 0;
//         }
//       });

//       allChannelList = allChannels;

//       // Filter by genres
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

//     } catch (e) {
//       throw Exception('Error processing entertainment data: $e');
//     }
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

//       // Update settings (uses static key)
//       final oldSettings = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('settings'));
//       await _fetchAndCacheSettings();
//       final newSettings = await SharedPreferences.getInstance()
//           .then((prefs) => prefs.getString('settings'));
//       if (oldSettings != newSettings) hasChanges = true;

//       // Update entertainment (uses user's auth key)
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
import '../../main.dart';

class ApiService {
  ApiService();

  // Base URL for images
  static const String imageBaseUrl = 'https://acomtv.coretechinfo.com/public/';

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

  Future<String> _getAuthKeyForFeaturedLiveTV() async {
    try {
      await AuthManager.initialize();

      // if (AuthManager.hasValidAuthKey) {
      //   return AuthManager.authKey;
      // }

      if (globalAuthKey.isNotEmpty) {
        return globalAuthKey;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authKey = prefs.getString('auth_key');

      if (authKey != null && authKey.isNotEmpty) {
        await AuthManager.setAuthKey(authKey);
        return authKey;
      }

      throw Exception('Authentication required - please login again');
    } catch (e) {
      throw Exception('Failed to get authentication key');
    }
  }

  Future<List<NewsItemModel>> fetchMusicData() async {
    try {
      String authKey = await _getAuthKeyForFeaturedLiveTV();

      final response = await https.get(
        Uri.parse(
            'https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
        headers: {
          'auth-key': authKey,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseMap = json.decode(response.body);
        List<NewsItemModel> allItems = [];

        // Process each category
        responseMap.forEach((category, items) {
          if (items is List) {
            for (var item in items) {
              try {
                var processedItem = _sanitizeItemData(item, category);
                NewsItemModel newsItem = NewsItemModel.fromJson(processedItem);

                if (newsItem.index != null && newsItem.index.isNotEmpty) {
                  allItems.add(newsItem);
                }
              } catch (e) {}
            }
          }
        });

        // Sort by channel_number (index)
        allItems.sort((a, b) {
          try {
            return int.parse(a.index).compareTo(int.parse(b.index));
          } catch (e) {
            return 0;
          }
        });

        return allItems;
      } else if (response.statusCode == 403) {
        throw Exception('Authentication failed - please login again');
      } else {
        throw Exception(
            'Error fetching music data - Status Code: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      throw Exception('Error fetching music data: $e');
    }
  }

  // Helper method to sanitize and fix API data
  Map<String, dynamic> _sanitizeItemData(dynamic item, String category) {
    if (item is! Map<String, dynamic>) {
      throw Exception('Item is not a valid map structure');
    }

    Map<String, dynamic> sanitized = Map<String, dynamic>.from(item);

    // Fix image URLs - convert relative paths to absolute URLs
    if (sanitized.containsKey('banner')) {
      String banner = sanitized['banner'].toString();
      if (!banner.startsWith('http')) {
        // Convert relative path to absolute URL
        sanitized['banner'] = imageBaseUrl + banner;
      }
    }

    // Convert numeric fields to strings
    List<String> fieldsToStringify = ['id', 'channel_number', 'status'];

    for (String field in fieldsToStringify) {
      if (sanitized.containsKey(field)) {
        sanitized[field] = sanitized[field].toString();
      }
    }

    // Add missing required fields with proper defaults
    Map<String, dynamic> defaultValues = {
      'poster': sanitized['banner'] ?? '', // Use banner as poster
      'category': category, // Use the category from API structure
      'streamType': 'M3u8',
      'type': 'Live',
      'videoId': sanitized['id'].toString(),
      'index': sanitized['channel_number']?.toString() ??
          sanitized['id']?.toString() ??
          '1',
    };

    // Add missing fields
    for (String key in defaultValues.keys) {
      if (!sanitized.containsKey(key) ||
          sanitized[key] == null ||
          sanitized[key] == '') {
        sanitized[key] = defaultValues[key];
      }
    }

    // Ensure description is not null
    if (sanitized['description'] == null) {
      sanitized['description'] = sanitized['name'] ?? '';
    }

    // Handle genres - map category to proper genre if genres field is missing
    if (!sanitized.containsKey('genres') || sanitized['genres'] == null) {
      // Map category names to proper genres
      switch (category.toLowerCase()) {
        case 'news':
          sanitized['genres'] = 'News';
          break;
        case 'sports':
          sanitized['genres'] = 'Sports';
          break;
        case 'movies':
          sanitized['genres'] = 'Movie';
          break;
        case 'entertainment':
          sanitized['genres'] = 'Entertainment';
          break;
        case 'religios': // Note: API has typo "Religios"
          sanitized['genres'] = 'Religious';
          break;
        case 'Music': // Note: API has typo "Religios"
          sanitized['genres'] = 'Music';
          break;
        default:
          sanitized['genres'] = 'Entertainment';
      }
    }

    // Ensure all required string fields exist
    List<String> requiredStringFields = [
      'id',
      'name',
      'description',
      'banner',
      'poster',
      'category',
      'url',
      'streamType',
      'type',
      'genres',
      'status',
      'videoId',
      'index'
    ];

    for (String field in requiredStringFields) {
      if (!sanitized.containsKey(field) || sanitized[field] == null) {
        sanitized[field] = '';
      } else {
        sanitized[field] = sanitized[field].toString();
      }
    }

    return sanitized;
  }

  Future<List<NewsItemModel>> fetchNewsData() async {
    final response = await https.get(
      Uri.parse('https://acomtv.coretechinfo.com/public/api/getNewsData'),
      headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => NewsItemModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch news data');
    }
  }

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
      headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
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
        final Map<String, dynamic> responseData =
            json.decode(cachedEntertainment);
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
      String authKey = await _getAuthKeyForFeaturedLiveTV();

      final response = await https.get(
        Uri.parse(
            'https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
        headers: {
          'auth-key': authKey,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _processEntertainmentData(responseData);

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('entertainment', json.encode(responseData));
      } else if (response.statusCode == 403) {
        throw Exception('Authentication failed - please login again');
      } else {
        throw Exception(
            'Failed to load entertainment data - Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load entertainment data: $e');
    }
  }

  void _processEntertainmentData(Map<String, dynamic> responseData) {
    try {
      List<NewsItemModel> allChannels = [];

      // Process each category in the response
      responseData.forEach((category, items) {
        if (items is List) {
          for (var item in items) {
            try {
              if (_isChannelAllowed(item)) {
                var sanitizedItem = _sanitizeItemData(item, category);
                NewsItemModel newsItem = NewsItemModel.fromJson(sanitizedItem);

                if (newsItem.index != null && newsItem.index.isNotEmpty) {
                  allChannels.add(newsItem);
                }
              }
            } catch (e) {}
          }
        }
      });

      // Sort channels by index (channel_number)
      allChannels.sort((a, b) {
        try {
          return int.parse(a.index).compareTo(int.parse(b.index));
        } catch (e) {
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
          .where((channel) => channel.genres.contains('Religios'))
          .toList();

      sportsList = allChannels
          .where((channel) => channel.genres.contains('Sports'))
          .toList();
    } catch (e) {
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

      final oldSettings = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('settings'));
      await _fetchAndCacheSettings();
      final newSettings = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('settings'));
      if (oldSettings != newSettings) hasChanges = true;

      final oldEntertainment = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('entertainment'));
      await _fetchAndCacheEntertainment();
      final newEntertainment = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('entertainment'));
      if (oldEntertainment != newEntertainment) hasChanges = true;

      if (hasChanges) {
        _updateController.add(true);
      }
    } catch (e) {}
  }

  void dispose() {
    _updateController.close();
  }
}
