import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../video_widget/socket_service.dart';
import '../../video_widget/video_screen.dart';
import '../../widgets/models/news_item_model.dart';
import '../../widgets/small_widgets/loading_indicator.dart';
import '../../widgets/utils/color_service.dart';
import 'focussable_subvod_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

// API Service class for consistent header management
class ApiService {
  static Future<Map<String, String>> getHeaders() async {
    await AuthManager.initialize();
    String authKey = AuthManager.authKey;

    if (authKey.isEmpty) {
      throw Exception('Auth key not found. Please login again.');
    }

    return {
      'auth-key': authKey, // Updated header name
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  static String get baseUrl => 'https://acomtv.coretechinfo.com/public/api/';
}

// Helper function to safely parse integers from dynamic values
int safeParseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;

  if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(value) ?? defaultValue;
  } else if (value is double) {
    return value.toInt();
  }

  return defaultValue;
}

// Helper function to safely parse strings
String safeParseString(dynamic value, {String defaultValue = ''}) {
  if (value == null) return defaultValue;
  return value.toString();
}

// Updated NetworkApi model with proper int handling
class NetworkApi {
  final int id; // Now properly int
  final String name;
  final String logo;
  final int networksOrder; // Changed to int

  NetworkApi({
    required this.id,
    required this.name,
    required this.logo,
    required this.networksOrder,
  });

  factory NetworkApi.fromJson(Map<String, dynamic> json) {
    return NetworkApi(
      id: safeParseInt(json['id']), // Safe int parsing
      name: safeParseString(json['name'], defaultValue: 'No Name'),
      logo: safeParseString(json['logo'], defaultValue: 'localImage'),
      networksOrder: safeParseInt(json['networks_order']), // Now int
    );
  }

  // Override equality for listEquals comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkApi &&
        other.id == id &&
        other.name == name &&
        other.logo == logo &&
        other.networksOrder == networksOrder;
  }

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ logo.hashCode ^ networksOrder.hashCode;
}

// Updated MovieDetailsApi model with proper int handling
class MovieDetailsApi {
  final int id; // Now properly int
  final String name;
  final String banner;
  final String poster;
  final String genres;
  final int status; // Changed from String to int

  MovieDetailsApi({
    required this.id,
    required this.name,
    required this.banner,
    required this.poster,
    required this.genres,
    required this.status,
  });

  factory MovieDetailsApi.fromJson(Map<String, dynamic> json) {
    return MovieDetailsApi(
      id: safeParseInt(json['id']), // Safe int parsing
      name: safeParseString(json['name'], defaultValue: 'No Name'),
      banner: safeParseString(json['banner'], defaultValue: 'localImage'),
      poster: safeParseString(json['poster'], defaultValue: 'localImage'),
      genres: safeParseString(json['genres'], defaultValue: 'Unknown'),
      status: safeParseInt(json['status']), // Now int instead of string
    );
  }

  // Helper method to check if movie is active
  bool get isActive => status == 1;

  // Override equality for comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovieDetailsApi &&
        other.id == id &&
        other.name == name &&
        other.banner == banner &&
        other.poster == poster &&
        other.genres == genres &&
        other.status == status;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      banner.hashCode ^
      poster.hashCode ^
      genres.hashCode ^
      status.hashCode;
}

// Updated fetch functions with proper error handling

Future<MovieDetailsApi> fetchMovieDetails(
    BuildContext context, int contentId) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedMovieDetails = prefs.getString('movie_details_$contentId');

  // Step 1: Return cached data immediately if available
  if (cachedMovieDetails != null) {
    try {
      final Map<String, dynamic> body = json.decode(cachedMovieDetails);
      return MovieDetailsApi.fromJson(body);
    } catch (e) {
      // Clear corrupted cache
      prefs.remove('movie_details_$contentId');
    }
  }

  // Step 2: Fetch API data if no cache is available
  try {
    final headers = await ApiService.getHeaders();

    final response = await https.get(
      Uri.parse('${ApiService.baseUrl}getMovieDetails/$contentId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final movieDetails = MovieDetailsApi.fromJson(body);

      // Step 3: Cache the fetched data
      prefs.setString('movie_details_$contentId', response.body);

      return movieDetails;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Something went wrong');
    } else {
      throw Exception('Something went wrong');
    }
  } catch (e) {
    rethrow;
  }
}

Future<List<NetworkApi>> fetchNetworks(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedNetworks = prefs.getString('networks');

  List<NetworkApi> networks = [];
  List<NetworkApi> apiNetworks = [];

  // Step 1: Use cached data for fast UI rendering
  if (cachedNetworks != null) {
    try {
      List<dynamic> cachedBody = json.decode(cachedNetworks);
      networks =
          cachedBody.map((dynamic item) => NetworkApi.fromJson(item)).toList();
    } catch (e) {
      prefs.remove('networks');
    }
  }

  // Step 2: Fetch API data in the background
  try {
    final headers = await ApiService.getHeaders();

    final response = await https.get(
      Uri.parse('${ApiService.baseUrl}getNetworks'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      apiNetworks =
          body.map((dynamic item) => NetworkApi.fromJson(item)).toList();

      // Step 3: Compare cached data with API data
      if (!listEquals(networks, apiNetworks)) {
        prefs.setString('networks', response.body);
        return apiNetworks;
      } else {}
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Something went wrong');
    }
  } catch (e) {
    if (networks.isEmpty) {
      rethrow; // Only throw if no cached data available
    }
  }

  return networks;
}

Future<List<NewsItemModel>> fetchContent(
    BuildContext context, int networkId) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedContent = prefs.getString('content_$networkId');

  List<NewsItemModel> content = [];

  // Step 1: Use cached data for fast UI rendering
  if (cachedContent != null) {
    try {
      List<dynamic> cachedBody = json.decode(cachedContent);
      content = cachedBody
          .map((dynamic item) => NewsItemModel.fromJson(item))
          .toList();
      content.sort(
          (a, b) => safeParseInt(a.index).compareTo(safeParseInt(b.index)));
    } catch (e) {
      prefs.remove('content_$networkId');
    }
  }

  // Step 2: Fetch API data in the background and compare with cache
  try {
    final headers = await ApiService.getHeaders();

    final response = await https.get(
      Uri.parse('${ApiService.baseUrl}getAllContentsOfNetwork/$networkId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<NewsItemModel> apiContent =
          body.map((dynamic item) => NewsItemModel.fromJson(item)).toList();

      // Sorting API data
      apiContent.sort(
          (a, b) => safeParseInt(a.index).compareTo(safeParseInt(b.index)));

      // Step 3: Compare cached data with API data
      if (!listEquals(content, apiContent)) {
        prefs.setString('content_$networkId', json.encode(body));
        return apiContent;
      } else {}
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Something went wrong');
    } else {
      throw Exception('Something went wrong');
    }
  } catch (e) {
    if (content.isEmpty) {
      rethrow; // Only throw if no cached data available
    }
  }

  return content;
}

// Future<Map<String, dynamic>> fetchMoviePlayLink(int movieId) async {
//   final prefs = await SharedPreferences.getInstance();
//   final cachedPlayLink = prefs.getString('movie_playlink_$movieId');

//   if (cachedPlayLink != null) {
//     try {
//       final Map<String, dynamic> cachedData = json.decode(cachedPlayLink);
//       return {
//         'url': safeParseString(cachedData['url']),
//         'type': safeParseString(cachedData['type']),
//         'id': safeParseInt(cachedData['id']), // Added id field
//         'status': safeParseInt(cachedData['status']) // Added status field
//       };
//     } catch (e) {
//       prefs.remove('movie_playlink_$movieId');
//     }
//   }

//   try {
//     final headers = await ApiService.getHeaders();

//     final response = await https.get(
//       Uri.parse('${ApiService.baseUrl}getMoviePlayLinks/$movieId/0'),
//       headers: headers,
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> body = json.decode(response.body);
//       if (body.isNotEmpty) {
//         final Map<String, dynamic> firstItem =
//             body.first as Map<String, dynamic>;

//         final playLinkData = {
//           'url': safeParseString(firstItem['url']),
//           'type': safeParseString(firstItem['type']),
//           'id': safeParseInt(firstItem['id']),
//           'status': safeParseInt(firstItem['status'])
//         };

//         prefs.setString('movie_playlink_$movieId', json.encode(playLinkData));
//         return playLinkData;
//       }
//       return {'url': '', 'type': '', 'id': 0, 'status': 0};
//     } else if (response.statusCode == 401 || response.statusCode == 403) {
//       throw Exception('Something went wrong');
//     } else {
//       throw Exception('Something went wrong');
//     }
//   } catch (e) {
//     rethrow;
//   }
// }

// Alternative simpler version if you want source_url and type
Future<Map<String, dynamic>> fetchMoviePlayLink(int movieId) async {
  print('🔍 === Fetching Source URL and Type for Movie ID: $movieId ===');
  
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'movie_source_data_$movieId';
  final cachedSourceData = prefs.getString(cacheKey);

  // Check cache first
  if (cachedSourceData != null) {
    try {
      final Map<String, dynamic> cachedData = json.decode(cachedSourceData);
      print('💾 Found cached source data: $cachedData');
      return cachedData;
    } catch (e) {
      print('❌ Cache decode failed: $e');
      prefs.remove(cacheKey);
    }
  }

  try {
    final headers = await ApiService.getHeaders();
    final apiUrl = '${ApiService.baseUrl}getMoviePlayLinks/$movieId/0';
    
    final response = await https.get(
      Uri.parse(apiUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      
      if (body.isNotEmpty) {
        // Search for matching ID
        for (var item in body) {
          final Map<String, dynamic> itemMap = item as Map<String, dynamic>;
          final int itemId = safeParseInt(itemMap['id']);
          
          if (itemId == movieId) {
            String sourceUrl = safeParseString(itemMap['source_url']);
            int type = safeParseInt(itemMap['type']);
            int linkType = safeParseInt(itemMap['link_type']);
            
            // Handle YouTube IDs

            
            final sourceData = {
              'source_url': sourceUrl,
              'type': type,
              'link_type': linkType,
              'id': itemId,
              'name': safeParseString(itemMap['name']),
              'quality': safeParseString(itemMap['quality']),
            };
            
            // Cache the source data
            prefs.setString(cacheKey, json.encode(sourceData));
            print('✅ Found and cached source data: $sourceData');
            return sourceData;
          }
        }
        
        // If no exact match, use first item
        final Map<String, dynamic> firstItem = body.first as Map<String, dynamic>;
        String sourceUrl = safeParseString(firstItem['source_url']);
        int type = safeParseInt(firstItem['type']);
        int linkType = safeParseInt(firstItem['link_type']);
        
        if (sourceUrl.length == 11 && !sourceUrl.contains('http')) {
          sourceUrl = 'https://www.youtube.com/watch?v=$sourceUrl';
        }
        
        final sourceData = {
          'source_url': sourceUrl,
          'type': type,
          'link_type': linkType,
          'id': safeParseInt(firstItem['id']),
          'name': safeParseString(firstItem['name']),
          'quality': safeParseString(firstItem['quality']),
        };
        
        prefs.setString(cacheKey, json.encode(sourceData));
        print('⚠️ No exact match, using first item source data: $sourceData');
        return sourceData;
      }
    }
    
    throw Exception('No valid source URL found');
  } catch (e) {
    print('❌ Error fetching source URL and type: $e');
    rethrow;
  }
}

// Updated utility functions
Future<Color> fetchPaletteColor(String imageUrl) async {
  try {
    return await PaletteColorService().getSecondaryColor(imageUrl);
  } catch (e) {
    return Colors.grey; // Fallback color
  }
}

// // Updated NewsItemModel class to handle the API response correctly
// class NewsItemModel {
//   final int id;
//   final String name;
//   final String banner;
//   final String poster;
//   final String index;
//   final int status;
//   final String description;
//   final String genres;

//   NewsItemModel({
//     required this.id,
//     required this.name,
//     required this.banner,
//     required this.poster,
//     required this.index,
//     required this.status,
//     this.description = '',
//     this.genres = '',
//   });

//   factory NewsItemModel.fromJson(Map<String, dynamic> json) {
//     return NewsItemModel(
//       id: safeParseInt(json['id']),
//       name: safeParseString(json['name'], defaultValue: 'No Name'),
//       banner: safeParseString(json['banner'], defaultValue: 'localImage'),
//       poster: safeParseString(json['poster'], defaultValue: 'localImage'),
//       index: safeParseString(json['index'], defaultValue: '0'),
//       status: safeParseInt(json['status']),
//       description: safeParseString(json['description'], defaultValue: ''),
//       genres: safeParseString(json['genres'], defaultValue: ''),
//     );
//   }

//   // Helper method
//   bool get isActive => status == 1;

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is NewsItemModel &&
//         other.id == id &&
//         other.name == name &&
//         other.banner == banner &&
//         other.poster == poster &&
//         other.index == index &&
//         other.status == status;
//   }

//   @override
//   int get hashCode =>
//       id.hashCode ^
//       name.hashCode ^
//       banner.hashCode ^
//       poster.hashCode ^
//       index.hashCode ^
//       status.hashCode;
// }

// // Also update your displayImage function to handle errors better
// Widget displayImage(
//   String imageUrl, {
//   double? width,
//   double? height,
// }) {

//   if (imageUrl.isEmpty || imageUrl == 'localImage') {
//     return localImage;
//   }

//   if (imageUrl.startsWith('data:image')) {
//     // Handle base64-encoded images
//     try {
//       Uint8List imageBytes = _getImageFromBase64String(imageUrl);
//       return Image.memory(
//         imageBytes,
//         fit: BoxFit.fill,
//         width: width,
//         height: height,
//         errorBuilder: (context, error, stackTrace) {
//           return localImage;
//         },
//       );
//     } catch (e) {
//       return localImage;
//     }
//   } else if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
//     // Handle URL images
//     return CachedNetworkImage(
//       imageUrl: imageUrl,
//       placeholder: (context, url) {
//         return localImage;
//       },
//       errorWidget: (context, url, error) {
//         return localImage;
//       },
//       fit: BoxFit.fill,
//       width: width,
//       height: height,
//     );
//   } else {
//     // Fallback for invalid image data
//     return localImage;
//   }
// }

// Updated displayImage function with SVG support and better error handling
Widget displayImage(
  String imageUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.fill,
}) {
  if (imageUrl.isEmpty || imageUrl == 'localImage') {
    return localImage;
  }

  // Handle localhost URLs - replace with fallback
  if (imageUrl.contains('localhost')) {
    return localImage;
  }

  if (imageUrl.startsWith('data:image')) {
    // Handle base64-encoded images
    try {
      Uint8List imageBytes = _getImageFromBase64String(imageUrl);
      return Image.memory(
        imageBytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget(width, height);
        },
      );
    } catch (e) {
      return _buildErrorWidget(width, height);
    }
  } else if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
    // Check if it's an SVG image
    if (imageUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) {
          return _buildLoadingWidget(width, height);
        },
      );
    } else {
      // Handle regular URL images (PNG, JPG, etc.)
      return CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) {
          return _buildLoadingWidget(width, height);
        },
        errorWidget: (context, url, error) {
          return _buildErrorWidget(width, height);
        },
        fit: fit,
        width: width,
        height: height,
        // Add timeout
        httpHeaders: {
          'User-Agent': 'Flutter App',
        },
      );
    }
  } else {
    // Fallback for invalid image data
    return _buildErrorWidget(width, height);
  }
}

// Helper widget for loading state
Widget _buildLoadingWidget(double? width, double? height) {
  return Container(
    width: width,
    height: height,
    child: Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    ),
  );
}

// Helper widget for error state
Widget _buildErrorWidget(double? width, double? height) {
  return localImage;
}

// Helper function to decode base64 images
Uint8List _getImageFromBase64String(String base64String) {
  return base64Decode(base64String.split(',').last);
}

// // Widget to handle image loading (either base64 or URL)
// Widget displayImage(
//   String imageUrl, {
//   double? width,
//   double? height,
// }) {
//   if (imageUrl.startsWith('data:image')) {
//     // Handle base64-encoded images
//     Uint8List imageBytes = _getImageFromBase64String(imageUrl);
//     return Image.memory(
//       imageBytes,
//       fit: BoxFit.fill,
//       width: width,
//       height: height,
//     );
//   } else if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
//     // Handle URL images
//     return CachedNetworkImage(
//       imageUrl: imageUrl,
//       placeholder: (context, url) => localImage,
//       errorWidget: (context, url, error) => localImage,
//       fit: BoxFit.fill,
//       width: width,
//       height: height,
//     );
//   } else {
//     // Fallback for invalid image data
//     return localImage;
//   }
// }

// Error handling helper for authentication errors
class AuthErrorHandler {
  static void handleAuthError(BuildContext context, dynamic error) {
    if (error.toString().contains('Authentication failed') ||
        error.toString().contains('Auth key not found')) {
      // Clear auth data
      AuthManager.clearAuthKey();

      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session expired. Please login again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

// Updated SubVod widget with proper error handling
class SubVod extends StatefulWidget {
  final Function(bool)? onFocusChange;

  const SubVod({Key? key, this.onFocusChange, required FocusNode focusNode})
      : super(key: key);

  @override
  _SubVodState createState() => _SubVodState();
}

// class _SubVodState extends State<SubVod> {
//   List<NetworkApi> _networks = [];
//   bool _isLoading = true;
//   bool _cacheLoaded = false;
//   late FocusNode firstSubVodFocusNode;

//   @override
//   void initState() {
//     super.initState();

//     firstSubVodFocusNode = FocusNode()
//       ..onKey = (node, event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             context.read<FocusProvider>().requestMusicItemFocus(context);
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             context.read<FocusProvider>().requestManageMoviesFocus;
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       };

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<FocusProvider>().setFirstSubVodFocusNode(firstSubVodFocusNode);
//     });

//     _loadCachedNetworks();
//     _fetchNetworksInBackground();
//   }

//   Future<void> _loadCachedNetworks() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cachedNetworks = prefs.getString('networks');

//     if (cachedNetworks != null) {
//       try {
//         List<dynamic> cachedBody = json.decode(cachedNetworks);
//         setState(() {
//           _networks = cachedBody.map((dynamic item) => NetworkApi.fromJson(item)).toList();
//           _isLoading = false;
//           _cacheLoaded = true;
//         });
//       } catch (e) {
//       }
//     } else {
//     }
//   }

//   Future<void> _fetchNetworksInBackground() async {
//     try {
//       final fetchedNetworks = await fetchNetworks(context);

//       if (!listEquals(_networks, fetchedNetworks)) {
//         setState(() {
//           _networks = fetchedNetworks;
//         });
//       }
//     } catch (e) {

//       // Handle authentication errors
//       AuthErrorHandler.handleAuthError(context, e);

//       if (!_cacheLoaded) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//       Color backgroundColor = colorProvider.isItemFocused
//           ? colorProvider.dominantColor.withOpacity(0.3)
//           : Colors.black87;

//       return Scaffold(
//         backgroundColor: Colors.transparent,
//         body: _isLoading
//             ? Center(child: LoadingIndicator())
//             : _buildNetworksList(),
//       );
//     });
//   }

//   Widget _buildNetworksList() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               'Contents',
//               style: TextStyle(
//                 fontSize: 24.0,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           );
//         }),
//         Expanded(
//           child: _networks.isEmpty
//               ? Center(child: Text('No Networks Available',
//                   style: TextStyle(color: Colors.white, fontSize: 18)))
//               : ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: _networks.length,
//                   itemBuilder: (context, index) {
//                     final network = _networks[index];
//                     final focusNode = index == 0 ? firstSubVodFocusNode : FocusNode()
//                       ..onKey = (node, event) {
//                         if (event is RawKeyDownEvent) {
//                           if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                             context.read<FocusProvider>().requestMusicItemFocus(context);
//                             return KeyEventResult.handled;
//                           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                             context.read<FocusProvider>().requestFirstMoviesFocus();
//                             return KeyEventResult.handled;
//                           }
//                         }
//                         return KeyEventResult.ignored;
//                       };

//                     return FocussableSubvodWidget(
//                       imageUrl: network.logo,
//                       name: network.name,
//                       focusNode: focusNode,
//                       onTap: () async {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ContentScreen(networkId: network.id),
//                           ),
//                         );
//                       },
//                       fetchPaletteColor: fetchPaletteColor,
//                     );
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }

class _SubVodState extends State<SubVod> {
  List<NetworkApi> _networks = [];
  bool _isLoading = true;
  bool _cacheLoaded = false;
  String _errorMessage = '';
  late FocusNode firstSubVodFocusNode;

  @override
  void initState() {
    super.initState();

    firstSubVodFocusNode = FocusNode()
      ..onKey = (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            context.read<FocusProvider>().requestMusicItemFocus(context);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            context
                .read<FocusProvider>()
                .requestManageMoviesFocus(); // Added missing parentheses
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<FocusProvider>()
          .setFirstSubVodFocusNode(firstSubVodFocusNode);
    });

    _initializeData();
  }

  Future<void> _initializeData() async {
    // Load cached data first
    await _loadCachedNetworks();

    // Then fetch fresh data
    await _fetchNetworksInBackground();

    // Ensure loading is turned off even if both methods fail
    if (mounted && _isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCachedNetworks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedNetworks = prefs.getString('networks');

      if (cachedNetworks != null && cachedNetworks.isNotEmpty) {
        List<dynamic> cachedBody = json.decode(cachedNetworks);
        List<NetworkApi> networks = cachedBody
            .map((dynamic item) => NetworkApi.fromJson(item))
            .toList();

        if (mounted) {
          setState(() {
            _networks = networks;
            _isLoading = false;
            _cacheLoaded = true;
            _errorMessage = '';
          });
        }
      } else {}
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading cached data: $e';
        });
      }
    }
  }

  Future<void> _fetchNetworksInBackground() async {
    try {
      final fetchedNetworks = await fetchNetworks(context);

      if (!mounted) return;

      // Update UI if data is different or if we don't have cached data
      if (!listEquals(_networks, fetchedNetworks) || !_cacheLoaded) {
        setState(() {
          _networks = fetchedNetworks;
          _isLoading = false;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (!_cacheLoaded || _networks.isEmpty) {
            _errorMessage = 'Something went wrong';
          }
        });
      }

      // Handle authentication errors
      AuthErrorHandler.handleAuthError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
      Color backgroundColor = colorProvider.isItemFocused
          ? colorProvider.dominantColor.withOpacity(0.3)
          : Colors.black87;

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildBody(),
      );
    });
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicator(),
            SizedBox(height: 20),
            Text(
              'Loading Networks...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty && _networks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'Error Loading Networks',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                _fetchNetworksInBackground();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_networks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tv_off, color: Colors.grey, size: 48),
            SizedBox(height: 16),
            Text(
              'No Networks Available',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                _fetchNetworksInBackground();
              },
              child: Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return _buildNetworksList();
  }

  Widget _buildNetworksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<ColorProvider>(builder: (context, colorProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Contents',
              style: TextStyle(
                fontSize: Headingtextsz,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        }),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _networks.length,
            itemBuilder: (context, index) {
              final network = _networks[index];
              final isFirst = index == 0;

              final focusNode = isFirst ? firstSubVodFocusNode : FocusNode()
                ..onKey = (node, event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      context
                          .read<FocusProvider>()
                          .requestMusicItemFocus(context);
                      return KeyEventResult.handled;
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowDown) {
                      context.read<FocusProvider>().requestFirstMoviesFocus();
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                };

              return FocussableSubvodWidget(
                imageUrl: network.logo,
                name: network.name,
                focusNode: focusNode,
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ContentScreen(networkId: network.id),
                    ),
                  );
                },
                fetchPaletteColor: fetchPaletteColor,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    firstSubVodFocusNode.dispose();
    super.dispose();
  }
}

// Updated VOD widget
class VOD extends StatefulWidget {
  @override
  _VODState createState() => _VODState();
}

class _VODState extends State<VOD> {
  List<NetworkApi> _networks = [];
  bool _isLoading = true;
  bool _cacheLoaded = false;
  Map<int, FocusNode> firstRowFocusNodes = {};

  @override
  void initState() {
    super.initState();

    // Initialize focus nodes for first row items
    for (int i = 0; i < 5; i++) {
      final focusNode = FocusNode();
      firstRowFocusNodes[i] = focusNode;

      focusNode.onKey = (node, event) {
        if (event is RawKeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
              context.read<FocusProvider>().requestVodMenuFocus();
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowLeft:
              if (i > 0) {
                firstRowFocusNodes[i - 1]?.requestFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            case LogicalKeyboardKey.arrowRight:
              if (i < 4 && i < _networks.length - 1) {
                firstRowFocusNodes[i + 1]?.requestFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            case LogicalKeyboardKey.arrowDown:
              if (_networks.length > 5) {
                FocusScope.of(context).nextFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
          }
        }
        return KeyEventResult.ignored;
      };
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (firstRowFocusNodes.containsKey(0)) {
        context
            .read<FocusProvider>()
            .setFirstVodBannerFocusNode(firstRowFocusNodes[0]!);
        firstRowFocusNodes[0]?.requestFocus();
      }
    });

    _loadCachedNetworks();
    _fetchNetworksInBackground();
  }

  Future<void> _loadCachedNetworks() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedNetworks = prefs.getString('networks');

    if (cachedNetworks != null) {
      try {
        List<dynamic> cachedBody = json.decode(cachedNetworks);
        setState(() {
          _networks = cachedBody
              .map((dynamic item) => NetworkApi.fromJson(item))
              .toList();
          _isLoading = false;
          _cacheLoaded = true;
        });
      } catch (e) {}
    }
  }

  Future<void> _fetchNetworksInBackground() async {
    try {
      final fetchedNetworks = await fetchNetworks(context);

      if (!listEquals(_networks, fetchedNetworks)) {
        setState(() {
          _networks = fetchedNetworks;
        });
      }
    } catch (e) {
      AuthErrorHandler.handleAuthError(context, e);

      if (!_cacheLoaded) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.read<FocusProvider>().requestWatchNowFocus();
        }
      },
      child: Consumer<ColorProvider>(builder: (context, colorProvider, child) {
        Color backgroundColor = colorProvider.isItemFocused
            ? colorProvider.dominantColor
            : cardColor;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: _isLoading
              ? Center(child: LoadingIndicator())
              : _networks.isNotEmpty
                  ? Container(
                      color: Colors.black54, child: _buildNetworksList())
                  : Center(
                      child: Text('No Networks Available',
                          style: TextStyle(color: Colors.white, fontSize: 18))),
        );
      }),
    );
  }

  Widget _buildNetworksList() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.8,
      ),
      itemCount: _networks.length,
      itemBuilder: (context, index) {
        final network = _networks[index];
        final isFirstRow = index < 5;

        return FocussableSubvodWidget(
          focusNode: isFirstRow ? firstRowFocusNodes[index] : null,
          imageUrl: network.logo,
          name: network.name,
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContentScreen(networkId: network.id),
              ),
            );
          },
          fetchPaletteColor: fetchPaletteColor,
        );
      },
    );
  }

  @override
  void dispose() {
    firstRowFocusNodes.values.forEach((node) => node.dispose());
    super.dispose();
  }
}

// Updated ContentScreen widget
class ContentScreen extends StatefulWidget {
  final int networkId;

  ContentScreen({required this.networkId});

  @override
  _ContentScreenState createState() => _ContentScreenState();
}

// class _ContentScreenState extends State<ContentScreen> {
//   List<NewsItemModel> _content = [];
//   bool _isLoading = true;
//   bool _cacheLoaded = false;
//   FocusNode firstItemFocusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();

//     _loadCachedContent();
//     _fetchContentInBackground();

//     Future.delayed(Duration(milliseconds: 50), () async {
//       firstItemFocusNode.requestFocus();
//     });
//   }

// Future<void> _loadCachedContent() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cachedContent = prefs.getString('content_${widget.networkId}');

//     if (cachedContent != null) {
//       try {
//         List<dynamic> cachedBody = json.decode(cachedContent);
//         setState(() {
//           _content = cachedBody.map((dynamic item) => NewsItemModel.fromJson(item)).toList();
//           _isLoading = false;
//           _cacheLoaded = true;
//         });
//       } catch (e) {
//       }
//     } else {
//     }
//   }

//   Future<void> _fetchContentInBackground() async {
//     try {
//       final fetchedContent = await fetchContent(context, widget.networkId);

//       if (!listEquals(_content, fetchedContent)) {
//         setState(() {
//           _content = fetchedContent;
//         });
//       }
//     } catch (e) {
//       AuthErrorHandler.handleAuthError(context, e);
//     } finally {
//       if (!_cacheLoaded) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//       Color backgroundColor = colorProvider.isItemFocused
//           ? colorProvider.dominantColor.withOpacity(0.3)
//           : Colors.black87;

//       return Scaffold(
//         backgroundColor: backgroundColor,
//         body: _isLoading
//             ? Center(child: CircularProgressIndicator())
//             : _buildContentList(),
//       );
//     });
//   }

//   // Widget _buildContentList() {
//   //   if (_content.isEmpty) {
//   //     return Center(
//   //       child: Text(
//   //         'No Content Available',
//   //         style: TextStyle(color: Colors.white, fontSize: 18),
//   //       ),
//   //     );
//   //   }

//   //   // Sort content by index (now handling int properly)
//   //   _content.sort((a, b) => safeParseInt(a.index).compareTo(safeParseInt(b.index)));

//   //   return Padding(
//   //     padding: EdgeInsets.symmetric(
//   //         horizontal: screenwdt * 0.03, vertical: screenhgt * 0.01),
//   //     child: GridView.builder(
//   //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//   //           crossAxisCount: 5, childAspectRatio: 0.8),
//   //       itemCount: _content.length,
//   //       itemBuilder: (context, index) {
//   //         final contentItem = _content[index];

//   //         return FocussableSubvodWidget(
//   //           focusNode: index == 0 ? firstItemFocusNode : null,
//   //           imageUrl: contentItem.banner,
//   //           name: contentItem.name,
//   //           onTap: () async {
//   //             // Convert string ID to int properly
//   //             int contentId = safeParseInt(contentItem.id);

//   //             Navigator.push(
//   //               context,
//   //               MaterialPageRoute(
//   //                 builder: (context) => DetailsPage(
//   //                   id: contentId,
//   //                   channelList: _content,
//   //                   source: 'isContentScreenViaDetailsPageChannelList',
//   //                   banner: contentItem.banner,
//   //                   name: contentItem.name ?? '',
//   //                 ),
//   //               ),
//   //             );
//   //           },
//   //           fetchPaletteColor: fetchPaletteColor,
//   //         );
//   //       },
//   //     ),
//   //   );
//   // }

//   Widget _buildContentList() {
//     if (_content.isEmpty) {
//       return Center(
//         child: Text(
//           'No Content Available',
//           style: TextStyle(color: Colors.white, fontSize: 18),
//         ),
//       );
//     }

//     // Sort content by index (now handling int properly)
//     _content.sort((a, b) => safeParseInt(a.index).compareTo(safeParseInt(b.index)));

//     return Padding(
//       padding: EdgeInsets.symmetric(
//           horizontal: screenwdt * 0.03, vertical: screenhgt * 0.01),
//       child: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 5, childAspectRatio: 0.8),
//         itemCount: _content.length,
//         itemBuilder: (context, index) {
//           final contentItem = _content[index];

//           // Debug print to check image URLs

//           return FocussableSubvodWidget(
//             focusNode: index == 0 ? firstItemFocusNode : null,
//             // Use poster instead of banner for better image display
//             imageUrl: contentItem.poster.isNotEmpty ? contentItem.poster : contentItem.banner,
//             name: contentItem.name,
//             onTap: () async {
//               // Convert string ID to int properly
//               int contentId = safeParseInt(contentItem.id);

//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => DetailsPage(
//                     id: contentId,
//                     channelList: _content,
//                     source: 'isContentScreenViaDetailsPageChannelList',
//                     banner: contentItem.banner,
//                     name: contentItem.name ?? '',
//                   ),
//                 ),
//               );
//             },
//             fetchPaletteColor: fetchPaletteColor,
//           );
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     firstItemFocusNode.dispose();
//     super.dispose();
//   }
// }

// Using existing NewsItemModel - no changes needed to the model

// Updated ContentScreen with better debug logging
class _ContentScreenState extends State<ContentScreen> {
  List<NewsItemModel> _content = [];
  bool _isLoading = true;
  bool _cacheLoaded = false;
  String _errorMessage = '';
  FocusNode firstItemFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _initializeContent();

    Future.delayed(Duration(milliseconds: 50), () async {
      firstItemFocusNode.requestFocus();
    });
  }

  Future<void> _initializeContent() async {
    // Load cached data first
    await _loadCachedContent();

    // Then fetch fresh data
    await _fetchContentInBackground();

    // Ensure loading is turned off even if both methods fail
    if (mounted && _isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCachedContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedContent = prefs.getString('content_${widget.networkId}');

      if (cachedContent != null && cachedContent.isNotEmpty) {
        List<dynamic> cachedBody = json.decode(cachedContent);
        List<NewsItemModel> content = cachedBody
            .map((dynamic item) => NewsItemModel.fromJson(item))
            .toList();

        if (mounted) {
          setState(() {
            _content = content;
            _isLoading = false;
            _cacheLoaded = true;
            _errorMessage = '';
          });
        }

        // Debug: Print first few items
        for (int i = 0; i < (_content.length > 2 ? 2 : _content.length); i++) {
          final item = _content[i];
        }
      } else {}
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading cached data: $e';
        });
      }
    }
  }

  Future<void> _fetchContentInBackground() async {
    try {
      final fetchedContent = await fetchContent(context, widget.networkId);

      if (!mounted) return;

      // Debug: Print API response details
      for (int i = 0;
          i < (fetchedContent.length > 2 ? 2 : fetchedContent.length);
          i++) {
        final item = fetchedContent[i];
      }

      // Update UI if data is different or if we don't have cached data
      if (!listEquals(_content, fetchedContent) || !_cacheLoaded) {
        setState(() {
          _content = fetchedContent;
          _isLoading = false;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (!_cacheLoaded || _content.isEmpty) {
            _errorMessage = 'Something went wrong';
          }
        });
      }

      // Handle authentication errors
      AuthErrorHandler.handleAuthError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
      Color backgroundColor = colorProvider.isItemFocused
          ? colorProvider.dominantColor.withOpacity(0.3)
          : Colors.black87;

      return Scaffold(
        backgroundColor: backgroundColor,
        body: _buildBody(),
      );
    });
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Loading Content...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty && _content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'Error Loading Content',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                _fetchContentInBackground();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_outlined, color: Colors.grey, size: 48),
            SizedBox(height: 16),
            Text(
              'No Content Available',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'This network has no content to display',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                _fetchContentInBackground();
              },
              child: Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return _buildContentGrid();
  }

  Widget _buildContentGrid() {
    // Sort content by index
    _content
        .sort((a, b) => safeParseInt(a.index).compareTo(safeParseInt(b.index)));

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenwdt * 0.03, vertical: screenhgt * 0.01),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, childAspectRatio: 0.8),
        itemCount: _content.length,
        itemBuilder: (context, index) {
          final contentItem = _content[index];

          // Debug print for each item being built

          // Choose the best image URL (prefer poster over banner)
          String imageUrl = '';
          if (contentItem.poster.isNotEmpty &&
              contentItem.poster != 'localImage') {
            imageUrl = contentItem.poster;
          } else if (contentItem.banner.isNotEmpty &&
              contentItem.banner != 'localImage') {
            imageUrl = contentItem.banner;
          } else if (contentItem.image.isNotEmpty &&
              contentItem.image != 'localImage') {
            imageUrl = contentItem.image;
          } else if (contentItem.thumbnail_high.isNotEmpty &&
              contentItem.thumbnail_high != 'localImage') {
            imageUrl = contentItem.thumbnail_high;
          } else {
            imageUrl = 'localImage';
          }

          return FocussableSubvodWidget(
            focusNode: index == 0 ? firstItemFocusNode : null,
            imageUrl: imageUrl,
            name: contentItem.name,
            onTap: () async {
              int contentId = int.tryParse(contentItem.id) ?? 0;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsPage(
                    id: contentId,
                    channelList: _content,
                    source: 'isContentScreenViaDetailsPageChannelList',
                    banner: contentItem.banner,
                    name: contentItem.name,
                  ),
                ),
              );
            },
            fetchPaletteColor: fetchPaletteColor,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    firstItemFocusNode.dispose();
    super.dispose();
  }
}

// Updated DetailsPage widget with proper int handling
class DetailsPage extends StatefulWidget {
  final int id;
  final List<NewsItemModel> channelList;
  final String source;
  final String banner;
  final String name;

  DetailsPage({
    required this.id,
    required this.channelList,
    required this.source,
    required this.banner,
    required this.name,
  });

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final SocketService _socketService = SocketService();
  MovieDetailsApi? _movieDetails;
  final int _maxRetries = 3;
  final int _retryDelay = 5; // seconds
  bool _shouldContinueLoading = true;
  bool _isLoading = false;
  bool _isVideoPlaying = false;
  Timer? _timer;
  bool _isReturningFromVideo = false;
  FocusNode firstItemFocusNode = FocusNode();
  Color headingColor = Colors.grey;

  @override
  void initState() {
    super.initState();

    _socketService.initSocket();
    checkServerStatus();

    Future.delayed(Duration(milliseconds: 100), () async {
      await _loadCachedAndFetchMovieDetails(widget.id);
      if (_movieDetails != null) {
        _fetchAndSetHeadingColor(_movieDetails!.banner);
      }
      firstItemFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _socketService.dispose();
    _timer?.cancel();
    firstItemFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchAndSetHeadingColor(String bannerUrl) async {
    try {
      Color paletteColor = await fetchPaletteColor(bannerUrl);
      setState(() {
        headingColor = paletteColor;
      });
    } catch (e) {}
  }

  Future<void> _loadCachedAndFetchMovieDetails(int contentId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final movieDetails = await fetchMovieDetails(context, contentId);

      if (!mounted) return;

      setState(() {
        _movieDetails = movieDetails;
        _isLoading = false;
      });

      // Fetch updated heading color when details are loaded
      if (movieDetails.banner.isNotEmpty) {
        _fetchAndSetHeadingColor(movieDetails.banner);
      }
    } catch (e) {
      AuthErrorHandler.handleAuthError(context, e);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _movieDetails = null;
        });
      }
    }
  }

  void checkServerStatus() {
    Timer.periodic(Duration(seconds: 10), (timer) {
      if (!_socketService.socket.connected) {
        _socketService.initSocket();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: _isLoading
          ? Center(child: LoadingIndicator())
          : _isReturningFromVideo
              ? Center(
                  child: Text(
                    '',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : _movieDetails != null
                  ? _buildMovieDetailsUI(context, _movieDetails!)
                  : Center(
                      child: Text(
                        '...',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
    );
  }

  Widget _buildMovieDetailsUI(
      BuildContext context, MovieDetailsApi movieDetails) {
    return Container(
      child: Stack(
        children: [
          // Only show banner if status is active (1)
          if (movieDetails.isActive)
            displayImage(
              movieDetails.banner ?? localImage,
              width: screenwdt,
              height: screenhgt,
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: screenhgt * 0.05),
                Container(
                  child: Text(
                    movieDetails.name,
                    style: TextStyle(
                      color: headingColor,
                      fontSize: Headingtextsz * 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                // Status info
                if (!movieDetails.isActive)
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Content not available (Status: ${movieDetails.status})',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return FocussableSubvodWidget(
                        focusNode: firstItemFocusNode,
                        imageUrl: movieDetails.poster ?? localImage,
                        name: '',
                        onTap: () => movieDetails.isActive
                            ? _playVideo(movieDetails)
                            : _showInactiveContentMessage(),
                        fetchPaletteColor: fetchPaletteColor,
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showInactiveContentMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('This content is currently not available'),
        backgroundColor: Colors.red,
      ),
    );
  }

//   Future<void> _playVideo(MovieDetailsApi movieDetails) async {
//     if (_isVideoPlaying) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _isVideoPlaying = true;
//     });
//     _shouldContinueLoading = true;

//     try {
//       Map<String, dynamic> playLinkData = await fetchMoviePlayLink(widget.id);
//       // Map<String, dynamic> originalUrl = await fetchMoviePlayLink(widget.id);
//       // String playType = safeParseString(playLinkData['type']);
// String originalUrl = playLinkData['url'] ?? '';
// String updatedUrl = playLinkData['url'] ?? '';
//       if (playLinkData.isNotEmpty) {
//         print('playLinkData: $updatedUrl');
//         // Create mutable copy for URL updates
//         // Update the URL field in playLinkData using getUpdatedUrl
//          updatedUrl = await _socketService.getUpdatedUrl(playLinkData['url']);
//         playLinkData['url'] = updatedUrl;
//         print('afterplayLinkData: $playLinkData');

//         bool liveStatus = false;

//         if (_shouldContinueLoading) {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => VideoScreen(
//                 videoUrl: updatedUrl,
//                 videoId: widget.id,
//                 channelList: widget.channelList,
//                 videoType: '',
//                 bannerImageUrl: widget.banner,
//                 startAtPosition: Duration.zero,
//                 isLive: false,
//                 isVOD: true,
//                 isBannerSlider: false,
//                 source: widget.source,
//                 isSearch: false,
//                 unUpdatedUrl: originalUrl,
//                 name: widget.name,
//                 liveStatus: liveStatus,
//               ),
//             ),
//           );
//         }

//         setState(() {
//           _isLoading = false;
//           _isReturningFromVideo = true;
//         });

//         setState(() {
//           _isReturningFromVideo = false;
//         });
//       } else {
//         throw Exception('Empty play URL received');
//       }
//     } catch (e) {
//       _handleVideoError(context);
//       AuthErrorHandler.handleAuthError(context, e);
//     } finally {
//       setState(() {
//         _isLoading = false;
//         _isVideoPlaying = false;
//       });
//     }
//   }
// }

  Future<void> _playVideo(MovieDetailsApi movieDetails) async {
    print('🎬 === STARTING _playVideo ===');
    print('🎬 Movie ID: ${widget.id}');
    print('🎬 Movie Name: ${movieDetails.name}');
    print('🎬 Movie Status: ${movieDetails.status}');
    print('🎬 Is Active: ${movieDetails.isActive}');

    if (_isVideoPlaying) {
      print('❌ Video already playing, returning');
      return;
    }

    setState(() {
      _isLoading = true;
      _isVideoPlaying = true;
    });

    _shouldContinueLoading = true;
    print('✅ UI state updated, starting video process');

    try {
      // Step 1: Fetch movie play link
      print('📡 === STEP 1: Fetching Play Link ===');
      Map<String, dynamic> playLinkData = await fetchMoviePlayLink(widget.id);
      String originalUrl = playLinkData['source_url'] ?? '';

      print('📡 Play link data received:');
      print('   - URL: $originalUrl');

      // Step 2: Get original URL
      String updatedUrl;
      print('🔗 Original URL: $originalUrl');
      print('🔗 Original URL Length: ${originalUrl.length}');

      if (originalUrl.isEmpty) {
        print('❌ ERROR: Original URL is empty');
        throw Exception('Original URL is empty');
      }

      // Step 3: Update URL using socket service
      print('🔌 === STEP 2: Socket Service ===');
      print('🔌 Socket connected: ${_socketService.socket.connected}');

      // try {
      //   print('🔌 Calling _socketService.getUpdatedUrl...');
      //   updatedUrl = await _socketService.getUpdatedUrl(originalUrl);
      //   print('🔌 Socket response received');
      //   print('🔗UpdatedURL: $updatedUrl');
      //   print('🔗 Updated URL Length: ${updatedUrl.length}');
      // } catch (e) {
      //   print('❌ Socket service failed: $e');
      //   print('🔄 Using original URL as fallback');
      //   updatedUrl = originalUrl;
      // }

        updatedUrl = await _socketService.getUpdatedUrl(originalUrl);
        print('🔗UpdatedURL: $updatedUrl');


      if (updatedUrl.isEmpty) {
        print('❌ ERROR: Updated URL is empty');
        throw Exception('Updated URL is empty');
      }

      // Step 4: URL validation
      print('✅ === STEP 3: URL Validation ===');
      bool isValidUrl = Uri.tryParse(updatedUrl) != null;
      print('✅ URL is valid URI: $isValidUrl');

      if (updatedUrl.startsWith('http://') ||
          updatedUrl.startsWith('https://')) {
        print('✅ URL has valid HTTP protocol');
      } else {
        print('⚠️ WARNING: URL does not start with http/https');
      }

      // Step 5: Navigation check
      print('🚀 === STEP 4: Navigation Check ===');
      print('🚀 Should continue loading: $_shouldContinueLoading');
      print('🚀 Widget mounted: $mounted');

      if (!_shouldContinueLoading) {
        print('❌ Loading cancelled by user');
        return;
      }

      if (!mounted) {
        print('❌ Widget not mounted, aborting navigation');
        return;
      }

      // Step 6: Navigate to VideoScreen
      print('📱 === STEP 5: Navigating to VideoScreen ===');
      print('📱 Final video URL for VideoScreen: $updatedUrl');
      // print('📱 Video Type: ${playLinkData['type']}');
      print('📱 Banner URL: ${widget.banner}');
      print('📱 Video Name: ${widget.name}');

      bool liveStatus = false;
      print('📱 Live Status: $liveStatus');
      print('📱 Starting Navigator.push...');

      if (_shouldContinueLoading) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              print('📱 Building VideoScreen widget...');
              return VideoScreen(
                videoUrl: updatedUrl,
                videoId: widget.id,
                channelList: widget.channelList,
                videoType:  '',
                bannerImageUrl: widget.banner,
                startAtPosition: Duration.zero,
                isLive: false,
                isVOD: true,
                isBannerSlider: false,
                source: widget.source,
                isSearch: false,
                unUpdatedUrl: originalUrl,
                name: widget.name,
                liveStatus: liveStatus,
              );
            },
          ),
        );
        print('📱 Returned from VideoScreen');
      }

      // Update UI after returning
      setState(() {
        _isLoading = false;
        _isReturningFromVideo = true;
      });
      print('✅ UI updated after video return');

      setState(() {
        _isReturningFromVideo = false;
      });
      print('✅ Reset returning state');
    } catch (e, stackTrace) {
      print('❌ === ERROR OCCURRED ===');
      print('❌ Error: $e');
      print('❌ StackTrace: $stackTrace');

      _handleVideoError(context);
      AuthErrorHandler.handleAuthError(context, e);
    } finally {
      print('🏁 === FINALLY BLOCK ===');
      setState(() {
        _isLoading = false;
        _isVideoPlaying = false;
      });
      print('🏁 Final cleanup completed');
      print('🎬 === END _playVideo ===\n');
    }
  }

  void _handleVideoError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Something Went Wrong', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
