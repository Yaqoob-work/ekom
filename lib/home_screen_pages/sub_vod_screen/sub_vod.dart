import 'dart:async';
import 'dart:convert';
import 'package:mobi_tv_entertainment/home_screen_pages/movies_screen/movies.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/horizontal_list_details_page.dart';
import 'package:mobi_tv_entertainment/services/history_service.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'dart:math' as math;
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../video_widget/socket_service.dart';
import '../../video_widget/video_screen.dart';
import '../../widgets/models/news_item_model.dart';
import '../../widgets/small_widgets/loading_indicator.dart';
import '../../widgets/utils/color_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobi_tv_entertainment/main.dart';


// API Service class for consistent header management
class ApiService {
  static Future<Map<String, String>> getHeaders() async {
    // await AuthManager.initialize();
    // String authKey = AuthManager.authKey;

          SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authKey = prefs.getString('auth_key');

    // if (authKey.isEmpty) {
    //   throw Exception('Auth key not found. Please login again.');
    // }

    return {
      'auth-key': authKey??'', // Updated header name
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'domain': 'coretechinfo.com'
    };
  }

  static String get baseUrl => 'https://acomtv.coretechinfo.com/api/v2/';
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
  final int updatedAt; // Now properly int
  final String name;
  final String logo;
  final int networksOrder; // Changed to int

  NetworkApi({
    required this.id,
    required this.updatedAt,
    required this.name,
    required this.logo,
    required this.networksOrder,
  });

  factory NetworkApi.fromJson(Map<String, dynamic> json) {
    return NetworkApi(
      id: safeParseInt(json['id']), // Safe int parsing
      updatedAt: safeParseInt(json['updated_at']), // Safe int parsing
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

// Alternative simpler version if you want source_url and type
Future<Map<String, dynamic>> fetchMoviePlayLink(int movieId) async {
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'movie_source_data_$movieId';
  final cachedSourceData = prefs.getString(cacheKey);

  // Check cache first
  if (cachedSourceData != null) {
    try {
      final Map<String, dynamic> cachedData = json.decode(cachedSourceData);
      return cachedData;
    } catch (e) {
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
            return sourceData;
          }
        }

        // If no exact match, use first item
        final Map<String, dynamic> firstItem =
            body.first as Map<String, dynamic>;
        String sourceUrl = safeParseString(firstItem['source_url']);
        int type = safeParseInt(firstItem['type']);
        int linkType = safeParseInt(firstItem['link_type']);

        // if (sourceUrl.length == 11 && !sourceUrl.contains('http')) {
        //   sourceUrl = 'https://www.youtube.com/watch?v=$sourceUrl';
        // }

        final sourceData = {
          'source_url': sourceUrl,
          'type': type,
          'link_type': linkType,
          'id': safeParseInt(firstItem['id']),
          'name': safeParseString(firstItem['name']),
          'quality': safeParseString(firstItem['quality']),
        };

        prefs.setString(cacheKey, json.encode(sourceData));
        return sourceData;
      }
    }

    throw Exception('No valid source URL found');
  } catch (e) {
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

// Updated displayImage function with SVG support and better error handling
Widget displayImage(
  String imageUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.fill, 
  // required String cachedKey,
}) {
  if (imageUrl.isEmpty || imageUrl == 'localImage') {
    return Image.asset(localImage);
  }

  // Handle localhost URLs - replace with fallback
  if (imageUrl.contains('localhost')) {
    return Image.asset(localImage);
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
      // return CachedNetworkImage(
      //   imageUrl: imageUrl,
      //   cacheKey: cachedKey,
      //   placeholder: (context, url) {
      //     return _buildLoadingWidget(width, height);
      //   },
      //   errorWidget: (context, url, error) {
      //     return _buildErrorWidget(width, height);
      //   },
      //   fit: fit,
      //   width: width,
      //   height: height,
      //   // Add timeout
      //   httpHeaders: {
      //     'User-Agent': 'Flutter App',
      //   },
      // );

 return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        headers: const {
          'User-Agent': 'Flutter App',
        },
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          // If the image is fully loaded, display it
          if (loadingProgress == null) {
            return child;
          }
          // Otherwise, show your loading widget
          return _buildLoadingWidget(width, height);
        },
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          // If an error occurs, display your error widget
          return _buildErrorWidget(width, height);
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
    child: const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    ),
  );
}

// Helper widget for error state
Widget _buildErrorWidget(double? width, double? height) {
  return Image.asset(localImage);
}

// Helper function to decode base64 images
Uint8List _getImageFromBase64String(String base64String) {
  return base64Decode(base64String.split(',').last);
}

// Error handling helper for authentication errors
class AuthErrorHandler {
  static void handleAuthError(BuildContext context, dynamic error) {
    if (error.toString().contains('Authentication failed') ||
        error.toString().contains('Auth key not found')) {
      // Clear auth data
      // AuthManager.clearAuthKey();

      // // Navigate to login screen
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => LoginScreen()),
      //   (route) => false,
      // );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please login again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

// 🎨 PROFESSIONAL SUBVOD & VOD UI - WEBSERIES STYLE

// ================================
// 1. PROFESSIONAL COLORS & ANIMATIONS
// ================================

class ProfessionalVODColors {
  static const primaryDark = Color(0xFF0A0E1A);
  static const surfaceDark = Color(0xFF1A1D29);
  static const cardDark = Color(0xFF2A2D3A);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentGreen = Color(0xFF10B981);
  static const accentRed = Color(0xFFEF4444);
  static const accentOrange = Color(0xFFF59E0B);
  static const accentPink = Color(0xFFEC4899);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);

  static List<Color> gradientColors = [
    accentBlue,
    accentPurple,
    accentGreen,
    accentRed,
    accentOrange,
    accentPink,
  ];
}

class VODAnimationTiming {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration focus = Duration(milliseconds: 700);
  static const Duration scroll = Duration(milliseconds: 800);
}



// 🎯 FIXED ProfessionalNetworkCard - Handle enter key properly
class ProfessionalNetworkCard extends StatefulWidget {
  final NetworkApi network;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int index;

  const ProfessionalNetworkCard({
    Key? key,
    required this.network,
    required this.focusNode,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  _ProfessionalNetworkCardState createState() =>
      _ProfessionalNetworkCardState();
}

class _ProfessionalNetworkCardState extends State<ProfessionalNetworkCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  Color _dominantColor = ProfessionalVODColors.accentBlue;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: VODAnimationTiming.focus,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: VODAnimationTiming.medium,
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });

    if (_isFocused) {
      _scaleController.forward();
      _glowController.forward();
      _generateDominantColor();
      HapticFeedback.lightImpact();
    } else {
      _scaleController.reverse();
      _glowController.reverse();
    }
  }

  void _generateDominantColor() {
    final colors = ProfessionalVODColors.gradientColors;
    _dominantColor = colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: screenwdt * 0.18,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              children: [
                // 🎯 WRAP WITH FOCUS AND GESTURE DETECTOR
                Focus(
                  focusNode: widget.focusNode,
                  onKey: (FocusNode node, RawKeyEvent event) {
                    if (event is RawKeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.select ||
                          event.logicalKey == LogicalKeyboardKey.enter) {
                        widget.onTap();
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: _buildNetworkPoster(),
                  ),
                ),
                const SizedBox(height: 10),
                _buildNetworkTitle(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkPoster() {
    return Container(
      height: screenhgt * 0.20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (_isFocused) ...[
            BoxShadow(
              color: _dominantColor.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 3,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: _dominantColor.withOpacity(0.2),
              blurRadius: 45,
              spreadRadius: 6,
              offset: const Offset(0, 15),
            ),
          ] else ...[
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            _buildNetworkImage(),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            _buildNetworkBadge(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: displayImage(
        widget.network.logo,
        // cachedKey: "${widget.network.id}_${widget.network.updatedAt}",
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildFocusBorder() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 3,
            color: _dominantColor,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
                end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
                colors: [
                  Colors.transparent,
                  _dominantColor.withOpacity(0.15),
                  Colors.transparent,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ProfessionalVODColors.accentGreen,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoverOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              _dominantColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkTitle() {
    final networkName = widget.network.name.toUpperCase();

    return Container(
      width: screenwdt * 0.16,
      child: AnimatedDefaultTextStyle(
        duration: VODAnimationTiming.medium,
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11,
          fontWeight: FontWeight.w600,
          color:
              _isFocused ? _dominantColor : ProfessionalVODColors.textPrimary,
          letterSpacing: 0.5,
          shadows: _isFocused
              ? [
                  Shadow(
                    color: _dominantColor.withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          networkName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}





// Updated Movie model for getAllMovies API
class MovieItem {
  final int id;
  final String name;
  final String description;
  final String genres;
  final String releaseDate;
  final int? runtime;
  final String sourceType;
  final String? youtubeTrailer;
  final String movieUrl;
  final String? poster;
  final String? banner;
  final int status;
  final int contentType;
  final List<NetworkInfo> networks;

  MovieItem({
    required this.id,
    required this.name,
    required this.description,
    required this.genres,
    required this.releaseDate,
    this.runtime,
    required this.sourceType,
    this.youtubeTrailer,
    required this.movieUrl,
    this.poster,
    this.banner,
    required this.status,
    required this.contentType,
    required this.networks,
  });

  factory MovieItem.fromJson(Map<String, dynamic> json) {
    var networksFromJson = json['networks'] as List? ?? [];
    List<NetworkInfo> networksList = networksFromJson
        .map((networkJson) => NetworkInfo.fromJson(networkJson))
        .toList();

    return MovieItem(
      id: safeParseInt(json['id']),
      name: safeParseString(json['name'], defaultValue: 'No Name'),
      description: safeParseString(json['description'], defaultValue: ''),
      genres: safeParseString(json['genres'], defaultValue: 'Unknown'),
      releaseDate: safeParseString(json['release_date'], defaultValue: ''),
      runtime: json['runtime'] != null ? safeParseInt(json['runtime']) : null,
      sourceType: safeParseString(json['source_type'], defaultValue: ''),
      youtubeTrailer: json['youtube_trailer'],
      movieUrl: safeParseString(json['movie_url'], defaultValue: ''),
      poster: json['poster'],
      banner: json['banner'],
      status: safeParseInt(json['status']),
      contentType: safeParseInt(json['content_type']),
      networks: networksList,
    );
  }

  // Helper method to check if movie is active
  bool get isActive => status == 1;

  // Get best image URL
  String get bestImageUrl {
    if (poster != null && poster!.isNotEmpty && poster != 'localImage') {
      return poster!;
    } else if (banner != null && banner!.isNotEmpty && banner != 'localImage') {
      return banner!;
    } else {
      return 'localImage';
    }
  }

  // Get banner URL for video screen
  String get bannerUrl {
    if (banner != null && banner!.isNotEmpty && banner != 'localImage') {
      return banner!;
    } else if (poster != null && poster!.isNotEmpty && poster != 'localImage') {
      return poster!;
    } else {
      return 'localImage';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovieItem &&
        other.id == id &&
        other.name == name &&
        other.movieUrl == movieUrl &&
        other.status == status;
  }

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ movieUrl.hashCode ^ status.hashCode;
}

class NetworkInfo {
  final int id;
  final String name;
  final String logo;

  NetworkInfo({
    required this.id,
    required this.name,
    required this.logo,
  });

  factory NetworkInfo.fromJson(Map<String, dynamic> json) {
    return NetworkInfo(
      id: safeParseInt(json['id']),
      name: safeParseString(json['name'], defaultValue: 'Unknown Network'),
      logo: safeParseString(json['logo'], defaultValue: 'localImage'),
    );
  }
}

// Updated fetch function for movies
Future<List<MovieItem>> fetchAllMovies(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedMovies = prefs.getString('all_movies');

  List<MovieItem> movies = [];
  List<MovieItem> apiMovies = [];

  // Step 1: Use cached data for fast UI rendering
  if (cachedMovies != null) {
    try {
      List<dynamic> cachedBody = json.decode(cachedMovies);
      movies =
          cachedBody.map((dynamic item) => MovieItem.fromJson(item)).toList();
    } catch (e) {
      prefs.remove('all_movies');
    }
  }

  // Step 2: Fetch API data in the background
  try {
    final headers = await ApiService.getHeaders();

    final response = await https.get(
      Uri.parse('${ApiService.baseUrl}getAllMovies'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      apiMovies = body.map((dynamic item) => MovieItem.fromJson(item)).toList();

      // Step 3: Compare cached data with API data
      if (!listEquals(movies, apiMovies)) {
        prefs.setString('all_movies', response.body);
        return apiMovies;
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Something went wrong');
    }
  } catch (e) {
    if (movies.isEmpty) {
      rethrow; // Only throw if no cached data available
    }
  }

  return movies;
}

// Filter movies by network ID
List<MovieItem> filterMoviesByNetwork(List<MovieItem> movies, int networkId) {
  return movies.where((movie) {
    return movie.networks.any((network) => network.id == networkId) &&
        movie.isActive;
  }).toList();
}

// Modified fetchAllMovies function to get movie URL by content ID
Future<String?> fetchMovieUrlByContentId(
    BuildContext context, int contentId) async {
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'movie_url_$contentId';
  final cachedUrl = prefs.getString(cacheKey);

  // Check cache first
  if (cachedUrl != null && cachedUrl.isNotEmpty) {
    return cachedUrl;
  }

  try {
    final headers = await ApiService.getHeaders();

    final response = await https.get(
      Uri.parse('${ApiService.baseUrl}getAllMovies'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);

      // Search for movie with matching content ID
      for (var movieJson in body) {
        final MovieItem movie = MovieItem.fromJson(movieJson);

        // Match content ID with movie ID
        if (movie.id == contentId &&
            movie.isActive &&
            movie.movieUrl.isNotEmpty) {
          // Cache the result
          prefs.setString(cacheKey, movie.movieUrl);
          return movie.movieUrl;
        }
      }

      return null;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to fetch movies: ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  }
}

// Create a content ID to movie URL mapping
Future<Map<int, String>> createContentToMovieUrlMap(
    BuildContext context, List<int> contentIds) async {
  Map<int, String> urlMap = {};

  try {
    final headers = await ApiService.getHeaders();

    final response = await https.get(
      Uri.parse('${ApiService.baseUrl}getAllMovies'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);

      for (var movieJson in body) {
        final MovieItem movie = MovieItem.fromJson(movieJson);

        // If this movie ID matches any of our content IDs
        if (contentIds.contains(movie.id) &&
            movie.isActive &&
            movie.movieUrl.isNotEmpty) {
          urlMap[movie.id] = movie.movieUrl;
        }
      }

      return urlMap;
    } else {
      throw Exception('Failed to fetch movies: ${response.statusCode}');
    }
  } catch (e) {
    return urlMap; // Return empty map on error
  }
}

class VOD extends StatefulWidget {
  @override
  _VODState createState() => _VODState();
}

class _VODState extends State<VOD> with TickerProviderStateMixin {
  List<NetworkApi> _networks = [];
  bool _isLoading = true;
  bool _cacheLoaded = false;
  String _errorMessage = '';

  // Focus management for grid
  List<FocusNode> gridFocusNodes = [];
  int currentFocusIndex = 0;
  static const int itemsPerRow = 6;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _gridAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _gridFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDataWithFallback();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: VODAnimationTiming.slow,
      vsync: this,
    );

    _gridAnimationController = AnimationController(
      duration: VODAnimationTiming.slow,
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _gridFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gridAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeDataWithFallback() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _loadCachedNetworks();

      if (_networks.isEmpty) {
        await _fetchNetworksDirectly();
      } else {
        await _fetchNetworksInBackground();
      }

      _headerAnimationController.forward();
      _gridAnimationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load networks: $e';
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

          _setupGridFocusNodes();
          _headerAnimationController.forward();
          _gridAnimationController.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading cached data: $e';
        });
      }
    }
  }

  Future<void> _fetchNetworksDirectly() async {
    try {
      final headers = await ApiService.getHeaders();
      final response = await https.get(
        Uri.parse('${ApiService.baseUrl}getNetworks'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<NetworkApi> apiNetworks =
            body.map((dynamic item) => NetworkApi.fromJson(item)).toList();

        if (mounted) {
          setState(() {
            _networks = apiNetworks;
            _isLoading = false;
            _errorMessage = '';
            _cacheLoaded = true;
          });

          final prefs = await SharedPreferences.getInstance();
          prefs.setString('networks', response.body);

          _setupGridFocusNodes();
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _fetchNetworksInBackground() async {
    try {
      final fetchedNetworks = await fetchNetworks(context);

      if (!mounted) return;

      if (!listEquals(_networks, fetchedNetworks) || !_cacheLoaded) {
        setState(() {
          _networks = fetchedNetworks;
          _isLoading = false;
          _errorMessage = '';
        });

        _setupGridFocusNodes();
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

      AuthErrorHandler.handleAuthError(context, e);
    }
  }

  void _setupGridFocusNodes() {
    // Dispose existing focus nodes
    for (var node in gridFocusNodes) {
      node.dispose();
    }
    gridFocusNodes.clear();

    // Create new focus nodes for each network
    for (int i = 0; i < _networks.length; i++) {
      final focusNode = FocusNode();

      // Grid navigation logic
      focusNode.onKey = (node, event) {
        if (event is RawKeyDownEvent) {
          final currentRow = i ~/ itemsPerRow;
          final currentCol = i % itemsPerRow;
          final totalRows = (_networks.length / itemsPerRow).ceil();

          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
              if (currentRow == 0) {
                // If in first row, go to VodMenu
                context.read<FocusProvider>().requestVodMenuFocus();
                return KeyEventResult.handled;
              } else {
                // Go to item above
                int targetIndex = (currentRow - 1) * itemsPerRow + currentCol;
                if (targetIndex < _networks.length) {
                  currentFocusIndex = targetIndex;
                  gridFocusNodes[targetIndex].requestFocus();
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;

            case LogicalKeyboardKey.arrowDown:
              if (currentRow < totalRows - 1) {
                // Go to item below
                int targetIndex = (currentRow + 1) * itemsPerRow + currentCol;
                if (targetIndex < _networks.length) {
                  currentFocusIndex = targetIndex;
                  gridFocusNodes[targetIndex].requestFocus();
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;

            case LogicalKeyboardKey.arrowLeft:
              if (currentCol > 0) {
                currentFocusIndex = i - 1;
                gridFocusNodes[i - 1].requestFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;

            case LogicalKeyboardKey.arrowRight:
              if (currentCol < itemsPerRow - 1 && i + 1 < _networks.length) {
                currentFocusIndex = i + 1;
                gridFocusNodes[i + 1].requestFocus();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;

            case LogicalKeyboardKey.select:
            case LogicalKeyboardKey.enter:
              _navigateToNetwork(_networks[i]);
              return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };

      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          currentFocusIndex = i;
        }
      });

      gridFocusNodes.add(focusNode);
    }

    // Register first focus node with FocusProvider
    if (gridFocusNodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context
              .read<FocusProvider>()
              .setFirstVodBannerFocusNode(gridFocusNodes[0]);

          // Auto-focus first item after a delay
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && gridFocusNodes.isNotEmpty) {
              // Don't auto-focus, let FocusProvider handle it
            }
          });
        }
      });
    }
  }

  // void _navigateToNetwork(NetworkApi network) async {
  //   try {
  //     await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => ContentScreen(networkId: network.id),
  //       ),
  //     );

  //     // Re-focus when returning
  //     if (mounted && currentFocusIndex < gridFocusNodes.length) {
  //       Future.delayed(const Duration(milliseconds: 100), () {
  //         if (mounted) {
  //           gridFocusNodes[currentFocusIndex].requestFocus();
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     // Handle navigation error
  //   }
  // }

// 4. Update VOD Grid Navigation as well
// In _VODState class, update the _navigateToNetwork method:
  void _navigateToNetwork(NetworkApi network) async {
                    try{
          print('Updating user history for: ${network.name}');
      int? currentUserId = SessionManager.userId;
    // final int? parsedContentType = episode.contentType;
    final int? parsedId = network.id;

      await HistoryService.updateUserHistory(
        userId: currentUserId!, // 1. User ID
        contentType: 0, // 2. Content Type (episode के लिए 4)
        eventId: parsedId!, // 3. Event ID (episode की ID)
        eventTitle: network.name, // 4. Event Title (episode का नाम)
        url: '', // 5. URL (episode का URL)
        categoryId: 0, // 6. Category ID (डिफ़ॉल्ट 1)
      );
    } catch (e) {
      print("History update failed, but proceeding to play. Error: $e");
    }
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GenreNetworkWidget(
            tvChannelId: network.id,
            channelName: network.name, 
          ),
          // builder: (context) => HorizontalListDetailsPage(
          //   tvChannelId: network.id,
          //   channelName: network.name, 
          // ),
        ),
      );

      // Re-focus when returning
      if (mounted && currentFocusIndex < gridFocusNodes.length) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            gridFocusNodes[currentFocusIndex].requestFocus();
          }
        });
      }
    } catch (e) {
      // Handle navigation error
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
        final bgColor = colorProvider.isItemFocused
            ? colorProvider.dominantColor.withOpacity(0.1)
            : ProfessionalVODColors.primaryDark;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bgColor,
                  ProfessionalVODColors.primaryDark,
                  ProfessionalVODColors.surfaceDark.withOpacity(0.5),
                ],
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: screenhgt * 0.02),
                _buildProfessionalVODHeader(),
                SizedBox(height: screenhgt * 0.02),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfessionalVODHeader() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        // padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
        padding: EdgeInsets.only(
            left: screenwdt * 0.05,
            right: screenwdt * 0.05,
            top: screenhgt * 0.02,
            bottom: screenhgt * 0.02),

        child: Column(
          children: [
            // Main Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Side - Title with Icon
                Row(
                  children: [
                    // Animated Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ProfessionalVODColors.accentPurple,
                            ProfessionalVODColors.accentPink,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: ProfessionalVODColors.accentPurple
                                .withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.dashboard_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Title Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              ProfessionalVODColors.accentPurple,
                              ProfessionalVODColors.accentPink,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'CONTENTS',
                            style: TextStyle(
                              fontSize: Headingtextsz + 2,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Browse All Network Content',
                          style: TextStyle(
                            color: ProfessionalVODColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Right Side - Grid Stats
                if (_networks.isNotEmpty)
                  Row(
                    children: [


                      
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ProfessionalVODColors.accentPurple
                                  .withOpacity(0.3),
                              ProfessionalVODColors.accentPink.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ProfessionalVODColors.accentPurple
                                .withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.account_tree_rounded,
                              size: 16,
                              color: ProfessionalVODColors.accentPurple,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_networks.length} NETWORKS',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // const SizedBox(height: 16),

            // Enhanced Grid Stats Bar
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.centerLeft,
            //       end: Alignment.centerRight,
            //       colors: [
            //         ProfessionalVODColors.surfaceDark.withOpacity(0.6),
            //         ProfessionalVODColors.cardDark.withOpacity(0.8),
            //         ProfessionalVODColors.surfaceDark.withOpacity(0.6),
            //       ],
            //     ),
            //     borderRadius: BorderRadius.circular(15),
            //     border: Border.all(
            //       color: ProfessionalVODColors.accentPurple.withOpacity(0.2),
            //       width: 1,
            //     ),
            //   ),
            // child: Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     _buildVODStatItem(
            //       icon: Icons.view_module_rounded,
            //       label: 'LAYOUT',
            //       value: '4x∞',
            //       color: ProfessionalVODColors.accentBlue,
            //     ),
            //     _buildVODDivider(),
            //     _buildVODStatItem(
            //       icon: Icons.visibility_rounded,
            //       label: 'BROWSING',
            //       value: 'EASY',
            //       color: ProfessionalVODColors.accentGreen,
            //     ),
            //     _buildVODDivider(),
            //     _buildVODStatItem(
            //       icon: Icons.search_rounded,
            //       label: 'DISCOVERY',
            //       value: 'SMART',
            //       color: ProfessionalVODColors.accentOrange,
            //     ),
            //     _buildVODDivider(),
            //     _buildVODStatItem(
            //       icon: Icons.favorite_rounded,
            //       label: 'FAVORITES',
            //       value: 'SAVE',
            //       color: ProfessionalVODColors.accentPink,
            //     ),
            //   ],
            // ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildVODStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: ProfessionalVODColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildVODDivider() {
    return Container(
      height: 30,
      width: 1,
      color: ProfessionalVODColors.accentPurple.withOpacity(0.3),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildProfessionalVODLoadingIndicator();
    } else if (_errorMessage.isNotEmpty && _networks.isEmpty) {
      return _buildErrorWidget();
    } else if (_networks.isEmpty) {
      return _buildNoNetworksMessage();
    } else {
      return _buildNetworksGrid();
    }
  }

  Widget _buildProfessionalVODLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  ProfessionalVODColors.accentPurple,
                  ProfessionalVODColors.accentPink,
                  ProfessionalVODColors.accentBlue,
                  ProfessionalVODColors.accentPurple,
                ],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ProfessionalVODColors.primaryDark,
              ),
              child: const Icon(
                Icons.dashboard_rounded,
                color: ProfessionalVODColors.textPrimary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading VOD Content...',
            style: TextStyle(
              color: ProfessionalVODColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalVODColors.accentRed.withOpacity(0.2),
                  ProfessionalVODColors.accentRed.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: ProfessionalVODColors.accentRed,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Error Loading Networks',
            style: TextStyle(
              color: ProfessionalVODColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ProfessionalVODColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              _initializeDataWithFallback();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfessionalVODColors.accentBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoNetworksMessage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No Networks Available',
            style: TextStyle(
              color: ProfessionalVODColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check your connection and try again',
            style: TextStyle(
              color: ProfessionalVODColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworksGrid() {
    return FadeTransition(
      opacity: _gridFadeAnimation,
      child: Container(
        // padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.05),
        padding: EdgeInsets.only(
            left: screenwdt * 0.05,
            right: screenwdt * 0.05,
            top: screenwdt * 0.02),

        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6, // Same as ContentScreen
            mainAxisSpacing: 16,
            crossAxisSpacing: 25,
            childAspectRatio: 1.5,
          ),
          itemCount: _networks.length,
          clipBehavior: Clip.none,
          itemBuilder: (context, index) {
            final network = _networks[index];

            return ProfessionalVODGridCard(
              network: network,
              focusNode:
                  index < gridFocusNodes.length ? gridFocusNodes[index] : null,
              onTap: () => _navigateToNetwork(network),
              index: index,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _gridAnimationController.dispose();

    // Dispose all grid focus nodes
    for (var node in gridFocusNodes) {
      node.dispose();
    }
    gridFocusNodes.clear();

    super.dispose();
  }
}


class ProfessionalVODGridCard extends StatefulWidget {
  final NetworkApi network;
  final FocusNode? focusNode;
  final VoidCallback onTap;
  final int index;

  const ProfessionalVODGridCard({
    Key? key,
    required this.network,
    this.focusNode,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  _ProfessionalVODGridCardState createState() =>
      _ProfessionalVODGridCardState();
}

class _ProfessionalVODGridCardState extends State<ProfessionalVODGridCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  Color _dominantColor = ProfessionalVODColors.accentPurple;
  bool _isFocused = false;
  late FocusNode _effectiveFocusNode;

  @override
  void initState() {
    super.initState();

    _effectiveFocusNode = widget.focusNode ?? FocusNode();

    _hoverController = AnimationController(
      duration: VODAnimationTiming.focus,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: VODAnimationTiming.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _effectiveFocusNode.hasFocus;
    });

    if (_isFocused) {
      _hoverController.forward();
      _glowController.forward();
      _generateDominantColor();
      HapticFeedback.lightImpact();
    } else {
      _hoverController.reverse();
      _glowController.reverse();
    }
  }

  void _generateDominantColor() {
    final colors = ProfessionalVODColors.gradientColors;
    _dominantColor = colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _glowController.dispose();
    _effectiveFocusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _effectiveFocusNode,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    if (_isFocused) ...[
                      BoxShadow(
                        color: _dominantColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: _dominantColor.withOpacity(0.2),
                        blurRadius: 35,
                        spreadRadius: 4,
                        offset: const Offset(0, 12),
                      ),
                    ] else ...[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      _buildNetworkImage(),
                      if (_isFocused) _buildFocusBorder(),
                      _buildGradientOverlay(),
                      _buildNetworkInfo(),
                      if (_isFocused) _buildPlayButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNetworkImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: displayImage(
        widget.network.logo,
        fit: BoxFit.cover,
        // cachedKey: "${widget.network.id}_${widget.network.updatedAt}",
      ),
    );
  }

  Widget _buildFocusBorder() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 3,
            color: _dominantColor,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkInfo() {
    final networkName = widget.network.name;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              networkName.toUpperCase(),
              style: TextStyle(
                color: _isFocused ? _dominantColor : Colors.white,
                fontSize: _isFocused ? 13 : 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (_isFocused) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _dominantColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _dominantColor.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: ProfessionalVODColors.accentGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: _dominantColor,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'HD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

// 🎨 PROFESSIONAL SUBVOD & VOD UI PART 3 - FINAL CODE

// ================================
// CONTINUED FROM PART 2 - VOD GRID CARD COMPLETION
// ================================

  Widget _buildPlayButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _dominantColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: _dominantColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}



