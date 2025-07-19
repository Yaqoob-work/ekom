// import 'dart:async';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:math';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/video_widget/youtube_player.dart';
// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../video_widget/socket_service.dart';
// import '../sub_vod_screen/sub_vod.dart';
// import 'focussable_manage_movies_widget.dart';

// import 'package:flutter/material.dart';
// // import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// // import 'package:better_player/better_player.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// // Professional Color Palette
// class ProfessionalColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentGreen = Color(0xFF10B981);
//   static const accentRed = Color(0xFFEF4444);
//   static const accentOrange = Color(0xFFF59E0B);
//   static const accentPink = Color(0xFFEC4899);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
//   static const focusGlow = Color(0xFF60A5FA);

//   static List<Color> gradientColors = [
//     accentBlue,
//     accentPurple,
//     accentGreen,
//     accentRed,
//     accentOrange,
//     accentPink,
//   ];
// }

// // Professional Animation Durations
// class AnimationTiming {
//   static const Duration ultraFast = Duration(milliseconds: 150);
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration focus = Duration(milliseconds: 300);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// // Enhanced Network Helper (keeping your existing one)
// class NetworkHelper {
//   static final http.Client _client = http.Client();
//   static const int _maxConcurrentRequests = 3;
//   static int _activeRequests = 0;
//   static DateTime? _lastRequestTime;
//   static const Duration _requestCooldown = Duration(milliseconds: 500);

//   static Future<http.Response> getWithRetry(
//     String url, {
//     Map<String, String>? headers,
//     int timeout = 10,
//     int retries = 2,
//   }) async {
//     final now = DateTime.now();
//     if (_lastRequestTime != null &&
//         now.difference(_lastRequestTime!) < _requestCooldown) {
//       await Future.delayed(_requestCooldown);
//     }
//     _lastRequestTime = now;

//     while (_activeRequests >= _maxConcurrentRequests) {
//       await Future.delayed(const Duration(milliseconds: 100));
//     }

//     _activeRequests++;
//     try {
//       for (int i = 0; i < retries; i++) {
//         try {
//           final response = await _client
//               .get(Uri.parse(url), headers: headers)
//               .timeout(Duration(seconds: timeout));

//           if (response.statusCode == 200) {
//             return response;
//           }
//         } catch (e) {
//           if (i == retries - 1) rethrow;
//           await Future.delayed(Duration(seconds: 1 * (i + 1)));
//         }
//       }
//       throw Exception('Failed after $retries attempts');
//     } finally {
//       _activeRequests--;
//     }
//   }

//   static void dispose() {
//     _client.close();
//   }
// }

// // Enhanced Cache Manager (keeping your existing one)
// class CacheManager {
//   static const String moviesKey = 'movies_list';
//   static const String lastUpdateKey = 'movies_last_update';
//   static const int maxCacheAgeHours = 6;

//   static Future<void> saveMovies(List<dynamic> movies) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(moviesKey, json.encode(movies));
//       await prefs.setInt(lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
//     } catch (e) {}
//   }

//   static Future<List<dynamic>?> getCachedMovies() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cachedData = prefs.getString(moviesKey);
//       if (cachedData != null && !await isCacheExpired()) {
//         return json.decode(cachedData);
//       }
//     } catch (e) {}
//     return null;
//   }

//   static Future<bool> isCacheExpired() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final lastUpdate = prefs.getInt(lastUpdateKey);
//       if (lastUpdate == null) return true;

//       final now = DateTime.now().millisecondsSinceEpoch;
//       final maxAge = maxCacheAgeHours * 60 * 60 * 1000;

//       return (now - lastUpdate) > maxAge;
//     } catch (e) {
//       return true;
//     }
//   }
// }

// // Enhanced YouTube URL checker
// bool isYoutubeUrl(String? url) {
//   if (url == null || url.isEmpty) {
//     return false;
//   }

//   url = url.toLowerCase().trim();

//   bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
//   if (isYoutubeId) {
//     return true;
//   }

//   bool isYouTubeUrl = url.contains('youtube.com') ||
//       url.contains('youtu.be') ||
//       url.contains('youtube.com/shorts/') ||
//       url.contains('www.youtube.com') ||
//       url.contains('m.youtube.com');

//   return isYouTubeUrl;
// }

// // Professional Movie Card Widget
// class ProfessionalMovieCard extends StatefulWidget {
//   final dynamic movie;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;

//   const ProfessionalMovieCard({
//     Key? key,
//     required this.movie,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//   }) : super(key: key);

//   @override
//   _ProfessionalMovieCardState createState() => _ProfessionalMovieCardState();
// }

// class _ProfessionalMovieCardState extends State<ProfessionalMovieCard>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _glowController;
//   late AnimationController _shimmerController;

//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<double> _shimmerAnimation;

//   Color _dominantColor = ProfessionalColors.accentBlue;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();

//     _scaleController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _glowController = AnimationController(
//       duration: AnimationTiming.medium,
//       vsync: this,
//     );

//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.06,
//     ).animate(CurvedAnimation(
//       parent: _scaleController,
//       curve: Curves.easeOutCubic,
//     ));

//     _glowAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _glowController,
//       curve: Curves.easeInOut,
//     ));

//     _shimmerAnimation = Tween<double>(
//       begin: -1.0,
//       end: 2.0,
//     ).animate(CurvedAnimation(
//       parent: _shimmerController,
//       curve: Curves.easeInOut,
//     ));

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _scaleController.forward();
//       _glowController.forward();
//       _generateDominantColor();
//       widget.onColorChange(_dominantColor);
//       HapticFeedback.lightImpact();
//     } else {
//       _scaleController.reverse();
//       _glowController.reverse();
//     }
//   }

//   void _generateDominantColor() {
//     final colors = ProfessionalColors.gradientColors;
//     _dominantColor = colors[math.Random().nextInt(colors.length)];
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     _glowController.dispose();
//     _shimmerController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//     // Helper method for URL validation
//   bool _isValidImageUrl(String url) {
//     if (url.isEmpty) return false;

//     try {
//       final uri = Uri.parse(url);
//       if (!uri.hasAbsolutePath) return false;
//       if (uri.scheme != 'http' && uri.scheme != 'https') return false;

//       final path = uri.path.toLowerCase();
//       return path.contains('.jpg') ||
//              path.contains('.jpeg') ||
//              path.contains('.png') ||
//              path.contains('.webp') ||
//              path.contains('.gif') ||
//              path.contains('image') ||
//              path.contains('thumb') ||
//              path.contains('banner') ||
//              path.contains('poster');
//     } catch (e) {
//       return false;
//     }
//   }

//   // Enhanced image widget builder
//   Widget _buildEnhancedMovieImage(double width, double height) {
//     // Priority order: banner → poster → fallback
//     final bannerUrl = widget.movie['banner']?.toString() ?? '';
//     final posterUrl = widget.movie['poster']?.toString() ?? '';

//     return Container(
//       width: width,
//       height: height,
//       child: Stack(
//         children: [
//           // Default background with movie icon
//           Container(
//             width: width,
//             height: height,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   ProfessionalColors.cardDark,
//                   ProfessionalColors.surfaceDark,
//                 ],
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.movie_outlined,
//                   size: height * 0.25,
//                   color: ProfessionalColors.textSecondary,
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'MOVIE',
//                   style: TextStyle(
//                     color: ProfessionalColors.textSecondary,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: ProfessionalColors.accentBlue.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Text(
//                     'HD',
//                     style: TextStyle(
//                       color: ProfessionalColors.accentBlue,
//                       fontSize: 8,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Try banner first
//           if (_isValidImageUrl(bannerUrl))
//             _buildCachedImage(bannerUrl, width, height)
//           // Fallback to poster
//           else if (_isValidImageUrl(posterUrl))
//             _buildCachedImage(posterUrl, width, height),
//         ],
//       ),
//     );
//   }

//   Widget _buildCachedImage(String imageUrl, double width, double height) {
//     return CachedNetworkImage(
//       imageUrl: imageUrl,
//       width: width,
//       height: height,
//       fit: BoxFit.cover,
//       placeholder: (context, url) => Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               ProfessionalColors.cardDark,
//               ProfessionalColors.surfaceDark,
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: const Center(
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(
//               ProfessionalColors.accentBlue,
//             ),
//           ),
//         ),
//       ),
//       errorWidget: (context, url, error) => Container(), // Show background fallback
//       fadeInDuration: const Duration(milliseconds: 300),
//       fadeOutDuration: const Duration(milliseconds: 100),
//       memCacheWidth: 200,
//       memCacheHeight: 300,
//       maxWidthDiskCache: 400,
//       maxHeightDiskCache: 600,
//     );
//   }

//   // ↓ REPLACE EXISTING _buildMovieImage METHOD WITH THIS:

//   Widget _buildMovieImage(double screenWidth, double posterHeight) {
//     return Container(
//       width: double.infinity,
//       height: posterHeight,
//       child: _buildEnhancedMovieImage(double.infinity, posterHeight),
//     );
//   }

//   // ↓ REPLACE EXISTING _buildImagePlaceholder METHOD WITH THIS:

//   Widget _buildImagePlaceholder(double height) {
//     return Container(
//       height: height,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalColors.cardDark,
//             ProfessionalColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.movie_outlined,
//             size: height * 0.25,
//             color: ProfessionalColors.textSecondary,
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'MOVIE',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             decoration: BoxDecoration(
//               color: ProfessionalColors.accentBlue.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'HD QUALITY',
//               style: TextStyle(
//                 color: ProfessionalColors.accentBlue,
//                 fontSize: 8,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return AnimatedBuilder(
//       animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Container(
//             width: screenWidth * 0.19,
//             margin: const EdgeInsets.symmetric(horizontal: 6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _buildProfessionalPoster(screenWidth, screenHeight),
//                 // SizedBox(height: 10),
//                 _buildProfessionalTitle(screenWidth),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
//     final posterHeight = _isFocused ? screenHeight * 0.28 : screenHeight * 0.22;

//     return Container(
//       height: posterHeight,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           if (_isFocused) ...[
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.4),
//               blurRadius: 25,
//               spreadRadius: 3,
//               offset: const Offset(0, 8),
//             ),
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.2),
//               blurRadius: 45,
//               spreadRadius: 6,
//               offset: const Offset(0, 15),
//             ),
//           ] else ...[
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 10,
//               spreadRadius: 2,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Stack(
//           children: [
//             _buildMovieImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildQualityBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFocusBorder() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             width: 3,
//             color: _dominantColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmerEffect() {
//     return AnimatedBuilder(
//       animation: _shimmerAnimation,
//       builder: (context, child) {
//         return Positioned.fill(
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               gradient: LinearGradient(
//                 begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
//                 end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
//                 colors: [
//                   Colors.transparent,
//                   _dominantColor.withOpacity(0.15),
//                   Colors.transparent,
//                 ],
//                 stops: [0.0, 0.5, 1.0],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildQualityBadge() {
//     return Positioned(
//       top: 8,
//       right: 8,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.8),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: const Text(
//           'HD',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 9,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHoverOverlay() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               _dominantColor.withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: const Icon(
//               Icons.play_arrow_rounded,
//               color: Colors.white,
//               size: 30,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     final movieName =
//         widget.movie['name']?.toString()?.toUpperCase() ?? 'UNKNOWN';

//     return Container(
//       width: screenWidth * 0.18,
//       child: AnimatedDefaultTextStyle(
//         duration: AnimationTiming.medium,
//         style: TextStyle(
//           fontSize: _isFocused ? 13 : 11,
//           fontWeight: FontWeight.w600,
//           color: _isFocused ? _dominantColor : ProfessionalColors.textPrimary,
//           letterSpacing: 0.5,
//           shadows: _isFocused
//               ? [
//                   Shadow(
//                     color: _dominantColor.withOpacity(0.6),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Text(
//           movieName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // Professional View All Button
// class ProfessionalViewAllButton extends StatefulWidget {
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int totalMovies;

//   const ProfessionalViewAllButton({
//     Key? key,
//     required this.focusNode,
//     required this.onTap,
//     required this.totalMovies,
//   }) : super(key: key);

//   @override
//   _ProfessionalViewAllButtonState createState() =>
//       _ProfessionalViewAllButtonState();
// }

// class _ProfessionalViewAllButtonState extends State<ProfessionalViewAllButton>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _rotateController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _rotateAnimation;

//   bool _isFocused = false;
//   Color _currentColor = ProfessionalColors.accentBlue;

//   @override
//   void initState() {
//     super.initState();

//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     )..repeat(reverse: true);

//     _rotateController = AnimationController(
//       duration: const Duration(milliseconds: 3000),
//       vsync: this,
//     )..repeat();

//     _pulseAnimation = Tween<double>(
//       begin: 0.85,
//       end: 1.15,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));

//     _rotateAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_rotateController);

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//       if (_isFocused) {
//         _currentColor = ProfessionalColors.gradientColors[
//             math.Random().nextInt(ProfessionalColors.gradientColors.length)];
//         HapticFeedback.mediumImpact();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _rotateController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Container(
//       width: screenWidth * 0.19,
//       margin: const EdgeInsets.symmetric(horizontal: 6),
//       child: Column(
//         children: [
//           AnimatedBuilder(
//             animation: _isFocused ? _pulseAnimation : _rotateAnimation,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: _isFocused ? _pulseAnimation.value : 1.0,
//                 child: Transform.rotate(
//                   angle: _isFocused ? 0 : _rotateAnimation.value * 2 * math.pi,
//                   child: Container(
//                     height:
//                         _isFocused ? screenHeight * 0.28 : screenHeight * 0.22,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: _isFocused
//                             ? [
//                                 _currentColor,
//                                 _currentColor.withOpacity(0.7),
//                               ]
//                             : [
//                                 ProfessionalColors.cardDark,
//                                 ProfessionalColors.surfaceDark,
//                               ],
//                       ),
//                       boxShadow: [
//                         if (_isFocused) ...[
//                           BoxShadow(
//                             color: _currentColor.withOpacity(0.4),
//                             blurRadius: 25,
//                             spreadRadius: 3,
//                             offset: const Offset(0, 8),
//                           ),
//                         ] else ...[
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.4),
//                             blurRadius: 10,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ],
//                     ),
//                     child: _buildViewAllContent(),
//                   ),
//                 ),
//               );
//             },
//           ),
//           // SizedBox(height: 10),
//           _buildViewAllTitle(),
//         ],
//       ),
//     );
//   }

//   Widget _buildViewAllContent() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         border: _isFocused
//             ? Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 2,
//               )
//             : null,
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.1),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.grid_view_rounded,
//                   size: _isFocused ? 45 : 35,
//                   color: Colors.white,
//                 ),
//                 // SizedBox(height: 8),
//                 Text(
//                   'VIEW ALL',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: _isFocused ? 14 : 12,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.25),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '${widget.totalMovies}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildViewAllTitle() {
//     return AnimatedDefaultTextStyle(
//       duration: AnimationTiming.medium,
//       style: TextStyle(
//         fontSize: _isFocused ? 13 : 11,
//         fontWeight: FontWeight.w600,
//         color: _isFocused ? _currentColor : ProfessionalColors.textPrimary,
//         letterSpacing: 0.5,
//         shadows: _isFocused
//             ? [
//                 Shadow(
//                   color: _currentColor.withOpacity(0.6),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ]
//             : [],
//       ),
//       child: const Text(
//         'ALL MOVIES',
//         textAlign: TextAlign.center,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }
// }

// // Enhanced Loading Indicator
// class ProfessionalLoadingIndicator extends StatefulWidget {
//   final String message;

//   const ProfessionalLoadingIndicator({
//     Key? key,
//     this.message = 'Loading Movies...',
//   }) : super(key: key);

//   @override
//   _ProfessionalLoadingIndicatorState createState() =>
//       _ProfessionalLoadingIndicatorState();
// }

// class _ProfessionalLoadingIndicatorState
//     extends State<ProfessionalLoadingIndicator> with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _animation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_controller);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _animation,
//             builder: (context, child) {
//               return Container(
//                 width: 70,
//                 height: 70,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: SweepGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple,
//                       ProfessionalColors.accentGreen,
//                       ProfessionalColors.accentBlue,
//                     ],
//                     stops: [0.0, 0.3, 0.7, 1.0],
//                     transform: GradientRotation(_animation.value * 2 * math.pi),
//                   ),
//                 ),
//                 child: Container(
//                   margin: const EdgeInsets.all(5),
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: ProfessionalColors.primaryDark,
//                   ),
//                   child: const Icon(
//                     Icons.movie_rounded,
//                     color: ProfessionalColors.textPrimary,
//                     size: 28,
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 24),
//           Text(
//             widget.message,
//             style: const TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             width: 200,
//             height: 3,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(2),
//               color: ProfessionalColors.surfaceDark,
//             ),
//             child: AnimatedBuilder(
//               animation: _animation,
//               builder: (context, child) {
//                 return LinearProgressIndicator(
//                   value: _animation.value,
//                   backgroundColor: Colors.transparent,
//                   valueColor: const AlwaysStoppedAnimation<Color>(
//                     ProfessionalColors.accentBlue,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Main Enhanced Movies Screen
// class Movies extends StatefulWidget {
//   final Function(bool)? onFocusChange;
//   final FocusNode focusNode;

//   const Movies({Key? key, this.onFocusChange, required this.focusNode})
//       : super(key: key);

//   @override
//   _MoviesState createState() => _MoviesState();
// }

// class _MoviesState extends State<Movies>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   // Core data
//   List<dynamic> moviesList = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isNavigating = false;

//   // Animation Controllers
//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   // Services and controllers
//   final PaletteColorService _paletteColorService = PaletteColorService();
//   final ScrollController _scrollController = ScrollController();
//   late SocketService _socketService;

//   // Focus management
//   Map<String, FocusNode> movieFocusNodes = {};
//   FocusNode? _viewAllFocusNode;
//   Color _currentAccentColor = ProfessionalColors.accentBlue;

//   // Performance optimizations
//   Timer? _timer;
//   Timer? _backgroundFetchTimer;
//   DateTime? _lastFetchTime;
//   static const Duration _fetchCooldown = Duration(minutes: 3);

//   @override
//   void initState() {
//     super.initState();

//     _initializeAnimations();
//     _initializeServices();
//     _initializeViewAllFocusNode();
//     _loadCachedDataAndFetchMovies();

//     _backgroundFetchTimer = Timer.periodic(
//         const Duration(minutes: 10), (_) => _fetchMoviesInBackground());
//   }

//   void _initializeAnimations() {
//     _headerAnimationController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _listAnimationController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _headerSlideAnimation = Tween<Offset>(
//       begin: const Offset(0, -1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _headerAnimationController,
//       curve: Curves.easeOutCubic,
//     ));

//     _listFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _listAnimationController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   void _initializeServices() {
//     _socketService = SocketService();
//     _socketService.initSocket();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         Provider.of<FocusProvider>(context, listen: false)
//             .setMoviesScrollController(_scrollController);
//       }
//     });
//   }

//     void _initializeMovieFocusNodes() {
//     // Dispose existing nodes
//     for (var node in movieFocusNodes.values) {
//       try {
//         node.removeListener(() {});
//         node.dispose();
//       } catch (e) {}
//     }
//     movieFocusNodes.clear();

//     // Create new focus nodes WITHOUT automatic scroll listener
//     for (var movie in moviesList) {
//       try {
//         String movieId = movie['id'].toString();
//         movieFocusNodes[movieId] = FocusNode();
//         // ❌ REMOVED: ..addListener(() { _scrollToFocusedItem(movieId); });
//       } catch (e) {
//         // Silent error handling
//       }
//     }
//     _registerMoviesFocus();
//   }

//   // 🎯 CONTROLLED SCROLL FUNCTION
//   void _scrollToFocusedItem(String itemId) {
//     if (!mounted) return;

//     try {
//       final focusNode = movieFocusNodes[itemId];
//       if (focusNode != null &&
//           focusNode.hasFocus &&
//           focusNode.context != null) {
//         // Only scroll if really needed, with debouncing
//         Future.delayed(const Duration(milliseconds: 100), () {
//           if (mounted && focusNode.hasFocus) {
//             Scrollable.ensureVisible(
//               focusNode.context!,
//               alignment: 0.02,
//               duration: const Duration(milliseconds: 300), // Shorter duration
//               curve: Curves.easeOut, // Smoother curve
//             );
//           }
//         });
//       }
//     } catch (e) {}
//   }

//   // 🎯 IMPROVED MOVIE ITEM BUILDER
//   Widget _buildMovieItem(dynamic movie, int index) {
//     String movieId = movie['id'].toString();

//     movieFocusNodes.putIfAbsent(
//       movieId,
//       () => FocusNode(), // Simple FocusNode without listener
//     );

//     return Focus(
//       focusNode: movieFocusNodes[movieId],

//       // 🔧 IMPROVED FOCUS CHANGE HANDLER
//       onFocusChange: (hasFocus) async {
//         if (hasFocus && mounted) {
//           // Only handle color change, no automatic scrolling
//           try {
//             Color dominantColor = await _paletteColorService.getSecondaryColor(
//               movie['poster']?.toString() ?? '',
//               fallbackColor: ProfessionalColors.accentBlue,
//             );
//             if (mounted) {
//               context.read<ColorProvider>().updateColor(dominantColor, true);
//             }
//           } catch (e) {
//             if (mounted) {
//               context
//                   .read<ColorProvider>()
//                   .updateColor(ProfessionalColors.accentBlue, true);
//             }
//           }
//         } else if (mounted) {
//           context.read<ColorProvider>().resetColor();
//         }
//       },

//       // 🔧 IMPROVED KEY HANDLER
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//             if (index < moviesList.length - 1 && index != 4) {
//               String nextMovieId = moviesList[index + 1]['id'].toString();
//               FocusScope.of(context).requestFocus(movieFocusNodes[nextMovieId]);
//               // Manual scroll only when needed
//               _scrollToFocusedItem(nextMovieId);
//               return KeyEventResult.handled;
//             } else if (index == 4) {
//               FocusScope.of(context).requestFocus(_viewAllFocusNode);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//             if (index > 0) {
//               String prevMovieId = moviesList[index - 1]['id'].toString();
//               FocusScope.of(context).requestFocus(movieFocusNodes[prevMovieId]);
//               // Manual scroll only when needed
//               _scrollToFocusedItem(prevMovieId);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             context.read<FocusProvider>().requestSubVodFocus();
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 50), () {
//               if (mounted) {
//                 Provider.of<FocusProvider>(context, listen: false)
//                     .requestFirstWebseriesFocus();
//               }
//             });
//             return KeyEventResult.ignored;
//           } else if (event.logicalKey == LogicalKeyboardKey.select) {
//             _handleMovieTap(movie);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },

//       child: GestureDetector(
//         onTap: () => _handleMovieTap(movie),
//         child: ProfessionalMovieCard(
//           movie: movie,
//           focusNode: movieFocusNodes[movieId]!,
//           onTap: () => _handleMovieTap(movie),
//           onColorChange: (color) {
//             setState(() {
//               _currentAccentColor = color;
//             });
//           },
//           index: index,
//         ),
//       ),
//     );
//   }

//   void _initializeViewAllFocusNode() {
//     _viewAllFocusNode = FocusNode()
//       ..addListener(() {
//         if (mounted && _viewAllFocusNode!.hasFocus) {
//           setState(() {
//             _currentAccentColor = ProfessionalColors.gradientColors[
//                 math.Random()
//                     .nextInt(ProfessionalColors.gradientColors.length)];
//           });
//         }
//       });
//   }

//   void debugMovieData(Map<String, dynamic> movie) {}

//   void _sortMoviesData(List<dynamic> data) {
//     if (data.isEmpty) return;

//     try {
//       data.sort((a, b) {
//         final aIndex = a['index'];
//         final bIndex = b['index'];

//         if (aIndex == null && bIndex == null) return 0;
//         if (aIndex == null) return 1;
//         if (bIndex == null) return -1;

//         int aVal = 0;
//         int bVal = 0;

//         if (aIndex is num) {
//           aVal = aIndex.toInt();
//         } else if (aIndex is String) {
//           aVal = int.tryParse(aIndex) ?? 0;
//         }

//         if (bIndex is num) {
//           bVal = bIndex.toInt();
//         } else if (bIndex is String) {
//           bVal = int.tryParse(bIndex) ?? 0;
//         }

//         return aVal.compareTo(bVal);
//       });
//     } catch (e) {}
//   }

//   Future<void> _fetchMoviesInBackground() async {
//     if (!mounted) return;

//     final now = DateTime.now();
//     if (_lastFetchTime != null &&
//         now.difference(_lastFetchTime!) < _fetchCooldown) {
//       return;
//     }
//     _lastFetchTime = now;

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = AuthManager.authKey;
//       if (authKey.isEmpty) {
//         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//       }

//       final response = await NetworkHelper.getWithRetry(
//         'https://acomtv.coretechinfo.com/public/api/getAllMovies/records=5',
//         headers: {'auth-key': authKey},
//       );

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         _sortMoviesData(data);

//         final cachedMovies = prefs.getString('movies_list');
//         final String newMoviesJson = json.encode(data);

//         if (cachedMovies != newMoviesJson) {
//           await CacheManager.saveMovies(data);

//           if (mounted) {
//             setState(() {
//               moviesList = data;
//               _initializeMovieFocusNodes();
//             });
//           }
//         }
//       }
//     } catch (e) {}
//   }

//   Future<void> _fetchMovies() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = AuthManager.authKey;
//       if (authKey.isEmpty) {
//         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//       }

//       final response = await NetworkHelper.getWithRetry(
//         'https://acomtv.coretechinfo.com/public/api/getAllMovies/records=5',
//         headers: {'auth-key': authKey},
//       );

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         _sortMoviesData(data);

//         await CacheManager.saveMovies(data);

//         if (mounted) {
//           setState(() {
//             moviesList = data;
//             _initializeMovieFocusNodes();
//             _isLoading = false;
//           });

//           // Start animations after data loads
//           _headerAnimationController.forward();
//           _listAnimationController.forward();
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _errorMessage = 'Failed to load movies (${response.statusCode})';
//             _isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Network error: Please check connection';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   List<NewsItemModel> _convertToNewsItemModels(List<dynamic> movies) {
//     return movies.map((m) {
//       try {
//         Map<String, dynamic> movie = m as Map<String, dynamic>;
//         return NewsItemModel(
//           id: movie.safeString('id'),
//           name: movie.safeString('name'),
//           banner: movie.safeString('banner'),
//           poster: movie.safeString('poster'),
//           description: movie.safeString('description'),
//           url: movie.safeString('url'),
//           streamType: movie.safeString('streamType'),
//           type: movie.safeString('type'),
//           genres: movie.safeString('genres'),
//           status: movie.safeString('status'),
//           videoId: movie.safeString('videoId'),
//           index: movie.safeString('index'),
//           image: '',
//           unUpdatedUrl: '',
//         );
//       } catch (e) {
//         return NewsItemModel(
//           id: '',
//           name: 'Unknown',
//           banner: '',
//           poster: '',
//           description: '',
//           url: '',
//           streamType: '',
//           type: '',
//           genres: '',
//           status: '',
//           videoId: '',
//           index: '',
//           image: '',
//           unUpdatedUrl: '',
//         );
//       }
//     }).toList();
//   }

//   Future<void> _handleMovieTap(dynamic movie) async {
//     if (_isNavigating || !mounted) return;

//     _isNavigating = true;
//     bool dialogShown = false;
//     Timer? timeoutTimer;

//     try {
//       debugMovieData(movie);

//       if (mounted) {
//         dialogShown = true;
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return WillPopScope(
//               onWillPop: () async {
//                 _isNavigating = false;
//                 return true;
//               },
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.8),
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 50,
//                         height: 50,
//                         child: const CircularProgressIndicator(
//                           strokeWidth: 3,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             ProfessionalColors.accentBlue,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Preparing video...',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       }

//       timeoutTimer = Timer(const Duration(seconds: 20), () {
//         if (mounted && _isNavigating) {
//           _isNavigating = false;
//           if (dialogShown) {
//             Navigator.of(context, rootNavigator: true).pop();
//           }
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Request timeout. Please check your connection.'),
//               backgroundColor: ProfessionalColors.accentRed,
//             ),
//           );
//         }
//       });

//       Map<String, dynamic> movieMap = movie as Map<String, dynamic>;
//       String movieId = movieMap.safeString('id');
//       String originalUrl = movieMap.safeString('movie_url');
//       String updatedUrl = movieMap.safeString('movie_url');

//       if (originalUrl.isEmpty) {
//         throw Exception('Video URL is not available');
//       }

//       List<NewsItemModel> freshMovies = await Future.any([
//         _fetchFreshMoviesData(),
//         Future.delayed(const Duration(seconds: 12), () => <NewsItemModel>[]),
//       ]);

//       if (freshMovies.isEmpty) {
//         freshMovies = _convertToNewsItemModels(moviesList);
//       }

//       timeoutTimer.cancel();

//       if (mounted && _isNavigating) {
//         if (dialogShown) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }

//         if (updatedUrl.isEmpty) {
//           // ScaffoldMessenger.of(context).showSnackBar(
//           //   SnackBar(
//           //     content: Text('Video URL is not available'),
//           //     backgroundColor: ProfessionalColors.accentRed,
//           //   ),
//           // );
//           return;
//         }

//         try {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               // builder: (context) => VideoScreen(
//               //   channelList: freshMovies,
//               //   source: 'isMovieScreen',
//               //   name: movieMap.safeString('name'),
//               //   videoUrl: updatedUrl,
//               //   unUpdatedUrl: originalUrl,
//               //   bannerImageUrl: movieMap.safeString('banner'),
//               //   startAtPosition: Duration.zero,
//               //   videoType: '',
//               //   isLive: false,
//               //   isVOD: true,
//               //   isLastPlayedStored: false,
//               //   isSearch: false,
//               //   isBannerSlider: false,
//               //   videoId: int.tryParse(movieId),
//               //   seasonId: 0,
//               //   liveStatus: false,
//               // ),
//               builder: (context) => YouTubePlayerScreen(
//                 videoData: VideoData(
//                   id: movieId,
//                   title: movieMap.safeString('name'),
//                   youtubeUrl: updatedUrl,
//                   thumbnail: movieMap.safeString('banner'),
//                   //  description: movieMap.safeString('description'),
//                 ),
//                 playlist: freshMovies
//                     .map((m) => VideoData(
//                           id: m.id,
//                           title: m.name,
//                           youtubeUrl: m.url,
//                           thumbnail: m.banner,
//                           //  description: m.description,
//                         ))
//                     .toList(),
//               ),
//             ),
//           );
//         } catch (e) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Failed to open video player'),
//                 backgroundColor: ProfessionalColors.accentRed,
//               ),
//             );
//           }
//         }
//       }
//     } catch (e) {
//       timeoutTimer?.cancel();
//       if (mounted) {
//         if (dialogShown) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${e.toString()}'),
//             backgroundColor: ProfessionalColors.accentRed,
//           ),
//         );
//       }
//     } finally {
//       _isNavigating = false;
//       timeoutTimer?.cancel();
//     }
//   }

//   bool _isYoutubeUrl(String? url) {
//     if (url == null || url.isEmpty) {
//       return false;
//     }

//     url = url.toLowerCase().trim();

//     // bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}).hasMatch(url);
//     bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
//     if (isYoutubeId) {
//       return true;
//     }

//     bool isYoutubeUrl = url.contains('youtube.com') ||
//         url.contains('youtu.be') ||
//         url.contains('youtube.com/shorts/');
//     if (isYoutubeUrl) {
//       return true;
//     }

//     return false;
//   }

//   Future<List<NewsItemModel>> _fetchFreshMoviesData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = AuthManager.authKey;
//       if (authKey.isEmpty) {
//         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//       }

//       final response = await NetworkHelper.getWithRetry(
//         'https://acomtv.coretechinfo.com/public/api/getAllMovies/records=5',
//         headers: {'auth-key': authKey},
//       );

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
//         _sortMoviesData(data);
//         return _convertToNewsItemModels(data);
//       }
//     } catch (e) {}
//     return [];
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _backgroundFetchTimer?.cancel();
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();

//     for (var entry in movieFocusNodes.entries) {
//       try {
//         entry.value.removeListener(() {});
//         entry.value.dispose();
//       } catch (e) {}
//     }
//     movieFocusNodes.clear();

//     try {
//       _viewAllFocusNode?.removeListener(() {});
//       _viewAllFocusNode?.dispose();
//     } catch (e) {}

//     try {
//       _scrollController.dispose();
//     } catch (e) {}

//     _isNavigating = false;
//     super.dispose();
//   }

//   // void _initializeMovieFocusNodes() {
//   //   for (var node in movieFocusNodes.values) {
//   //     try {
//   //       node.removeListener(() {});
//   //       node.dispose();
//   //     } catch (e) {}
//   //   }
//   //   movieFocusNodes.clear();

//   //   for (var movie in moviesList) {
//   //     try {
//   //       String movieId = movie['id'].toString();
//   //       movieFocusNodes[movieId] = FocusNode()
//   //         ..addListener(() {
//   //           if (mounted && movieFocusNodes[movieId]!.hasFocus) {
//   //             _scrollToFocusedItem(movieId);
//   //           }
//   //         });
//   //     } catch (e) {
//   //       // Silent error handling
//   //     }
//   //   }
//   //   _registerMoviesFocus();
//   // }

//   void _registerMoviesFocus() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && moviesList.isNotEmpty) {
//         try {
//           final focusProvider = context.read<FocusProvider>();
//           final firstMovieId = moviesList[0]['id'].toString();

//           if (movieFocusNodes.containsKey(firstMovieId)) {
//             focusProvider
//                 .setFirstManageMoviesFocusNode(movieFocusNodes[firstMovieId]!);
//           }
//         } catch (e) {}
//       }
//     });
//   }

//   Future<void> _loadCachedDataAndFetchMovies() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final cachedMovies = await CacheManager.getCachedMovies();

//       if (cachedMovies != null && mounted) {
//         setState(() {
//           moviesList = cachedMovies;
//           _initializeMovieFocusNodes();
//           _isLoading = false;
//         });

//         _headerAnimationController.forward();
//         _listAnimationController.forward();
//         _fetchMoviesInBackground();
//       } else {
//         await _fetchLimitedMoviesForHomepage();
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Failed to load movies';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // void _scrollToFocusedItem(String itemId) {
//   //   if (!mounted) return;

//   //   try {
//   //     final focusNode = movieFocusNodes[itemId];
//   //     if (focusNode != null &&
//   //         focusNode.hasFocus &&
//   //         focusNode.context != null) {
//   //       Scrollable.ensureVisible(
//   //         focusNode.context!,
//   //         alignment: 0.02,
//   //         duration: AnimationTiming.scroll,
//   //         curve: Curves.easeInOutCubic,
//   //       );
//   //     }
//   //   } catch (e) {}
//   // }

//   Future<void> _fetchLimitedMoviesForHomepage() async {
//   if (!mounted) return;

//   setState(() {
//     _isLoading = true;
//     _errorMessage = '';
//   });

//   try {
//     final prefs = await SharedPreferences.getInstance();
//     String authKey = AuthManager.authKey;
//     if (authKey.isEmpty) {
//       authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//     }

//     // 🎯 LIMITED API CALL:
//     final response = await NetworkHelper.getWithRetry(
//       'https://acomtv.coretechinfo.com/public/api/getAllMovies?records=5',
//       headers: {'auth-key': authKey},
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       _sortMoviesData(data);

//       if (mounted) {
//         setState(() {
//           moviesList = data;
//           _initializeMovieFocusNodes();
//           _isLoading = false;
//         });

//         _headerAnimationController.forward();
//         _listAnimationController.forward();
//       }
//     } else {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Failed to load movies (${response.statusCode})';
//           _isLoading = false;
//         });
//       }
//     }
//   } catch (e) {
//     if (mounted) {
//       setState(() {
//         _errorMessage = 'Network error: Please check connection';
//         _isLoading = false;
//       });
//     }
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Column(
//         children: [
//           SizedBox(height: screenhgt * 0.02),
//           _buildProfessionalTitle(),
//           SizedBox(height: screenhgt * 0.01),
//           Expanded(child: _buildBody()),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle() {
//     return SlideTransition(
//       position: _headerSlideAnimation,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             ShaderMask(
//               shaderCallback: (bounds) => const LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentBlue,
//                   ProfessionalColors.accentPurple,
//                 ],
//               ).createShader(bounds),
//               child: Text(
//                 'MOVIES',
//                 style: TextStyle(
//                   fontSize: Headingtextsz,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//             ),
//             if (moviesList.isNotEmpty)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue.withOpacity(0.2),
//                       ProfessionalColors.accentPurple.withOpacity(0.2),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   '${moviesList.length} Movies',
//                   style: const TextStyle(
//                     color: ProfessionalColors.textSecondary,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return const ProfessionalLoadingIndicator(message: 'Loading Movies...');
//     } else if (_errorMessage.isNotEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   colors: [
//                     ProfessionalColors.accentRed.withOpacity(0.2),
//                     ProfessionalColors.accentRed.withOpacity(0.1),
//                   ],
//                 ),
//               ),
//               child: const Icon(
//                 Icons.error_outline_rounded,
//                 size: 40,
//                 color: ProfessionalColors.accentRed,
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Oops! Something went wrong',
//               style: TextStyle(
//                 color: ProfessionalColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _errorMessage,
//               style: const TextStyle(
//                 color: ProfessionalColors.textSecondary,
//                 fontSize: 14,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _fetchMovies,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: ProfessionalColors.accentBlue,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text(
//                 'Try Again',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//       );
//     } else if (moviesList.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   colors: [
//                     ProfessionalColors.accentBlue.withOpacity(0.2),
//                     ProfessionalColors.accentBlue.withOpacity(0.1),
//                   ],
//                 ),
//               ),
//               child: const Icon(
//                 Icons.movie_outlined,
//                 size: 40,
//                 color: ProfessionalColors.accentBlue,
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'No movies found',
//               style: TextStyle(
//                 color: ProfessionalColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Check back later for new content',
//               style: TextStyle(
//                 color: ProfessionalColors.textSecondary,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       );
//     } else {
//       return _buildMoviesList();
//     }
//   }

//   Widget _buildMoviesList() {
//     bool showViewAll = true;

//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: Container(
//         height: MediaQuery.of(context).size.height * 0.38,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.none,
//           controller: _scrollController,
//           padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
//           cacheExtent: 1200,
//           itemCount:  6 ,
//           itemBuilder: (context, index) {
//             if (showViewAll && index == 5) {
//               return Focus(
//                 focusNode: _viewAllFocusNode,
//                 onKey: (FocusNode node, RawKeyEvent event) {
//                   if (event is RawKeyDownEvent) {
//                     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowLeft) {
//                       if (moviesList.isNotEmpty && moviesList.length > 4) {
//                         String movieId = moviesList[4]['id'].toString();
//                         FocusScope.of(context)
//                             .requestFocus(movieFocusNodes[movieId]);
//                         return KeyEventResult.handled;
//                       }
//                     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                       context.read<FocusProvider>().requestSubVodFocus();
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowDown) {
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 50), () {
//                         if (mounted) {
//                           context
//                               .read<FocusProvider>()
//                               .requestFirstWebseriesFocus();
//                         }
//                       });
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.select) {
//                       _navigateToMoviesGrid();
//                       return KeyEventResult.handled;
//                     }
//                   }
//                   return KeyEventResult.ignored;
//                 },
//                 child: GestureDetector(
//                   onTap: _navigateToMoviesGrid,
//                   child: AdvancedProfessionalViewAllButton(
//                     focusNode: _viewAllFocusNode!,
//                     onTap: _navigateToMoviesGrid,
//                     totalMovies: moviesList.length,
//                   ),
//                 ),
//               );
//             }

//             var movie = moviesList[index];
//             return _buildMovieItem(movie, index);
//           },
//         ),
//       ),
//     );
//   }

//   // Widget _buildMovieItem(dynamic movie, int index) {
//   //   String movieId = movie['id'].toString();

//   //   movieFocusNodes.putIfAbsent(
//   //     movieId,
//   //     () => FocusNode()
//   //       ..addListener(() {
//   //         if (mounted && movieFocusNodes[movieId]!.hasFocus) {
//   //           _scrollToFocusedItem(movieId);
//   //         }
//   //       }),
//   //   );

//   //   return Focus(
//   //     focusNode: movieFocusNodes[movieId],
//   //     onFocusChange: (hasFocus) async {
//   //       if (hasFocus && mounted) {
//   //         try {
//   //           Color dominantColor = await _paletteColorService.getSecondaryColor(
//   //             movie['poster']?.toString() ?? '',
//   //             fallbackColor: ProfessionalColors.accentBlue,
//   //           );
//   //           if (mounted) {
//   //             context.read<ColorProvider>().updateColor(dominantColor, true);
//   //           }
//   //         } catch (e) {
//   //           if (mounted) {
//   //             context
//   //                 .read<ColorProvider>()
//   //                 .updateColor(ProfessionalColors.accentBlue, true);
//   //           }
//   //         }
//   //       } else if (mounted) {
//   //         context.read<ColorProvider>().resetColor();
//   //       }
//   //     },
//   //     onKey: (FocusNode node, RawKeyEvent event) {
//   //       if (event is RawKeyDownEvent) {
//   //         if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//   //           if (index < moviesList.length - 1 && index != 4) {
//   //             String nextMovieId = moviesList[index + 1]['id'].toString();
//   //             FocusScope.of(context).requestFocus(movieFocusNodes[nextMovieId]);
//   //             return KeyEventResult.handled;
//   //           } else if (index == 4 ) {
//   //             FocusScope.of(context).requestFocus(_viewAllFocusNode);
//   //             return KeyEventResult.handled;
//   //           }
//   //         } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//   //           if (index > 0) {
//   //             String prevMovieId = moviesList[index - 1]['id'].toString();
//   //             FocusScope.of(context).requestFocus(movieFocusNodes[prevMovieId]);
//   //             return KeyEventResult.handled;
//   //           }
//   //         } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//   //           context.read<FocusProvider>().requestSubVodFocus();
//   //           return KeyEventResult.handled;
//   //         } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//   //           FocusScope.of(context).unfocus();
//   //           Future.delayed(const Duration(milliseconds: 50), () {
//   //             if (mounted) {
//   //               Provider.of<FocusProvider>(context, listen: false)
//   //                   .requestFirstWebseriesFocus();
//   //             }
//   //           });
//   //           return KeyEventResult.ignored;
//   //         } else if (event.logicalKey == LogicalKeyboardKey.select) {
//   //           _handleMovieTap(movie);
//   //           return KeyEventResult.handled;
//   //         }
//   //       }
//   //       return KeyEventResult.ignored;
//   //     },
//   //     child: GestureDetector(
//   //       onTap: () => _handleMovieTap(movie),
//   //       child: ProfessionalMovieCard(
//   //         movie: movie,
//   //         focusNode: movieFocusNodes[movieId]!,
//   //         onTap: () => _handleMovieTap(movie),
//   //         onColorChange: (color) {
//   //           setState(() {
//   //             _currentAccentColor = color;
//   //           });
//   //         },
//   //         index: index,
//   //       ),
//   //     ),
//   //   );
//   // }

//   void _navigateToMoviesGrid() {
//     if (!_isNavigating && mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               ProfessionalMoviesGridView(),
//         ),
//       );
//     }
//   }
// }

// // 🎨 Advanced Professional View All Button - UI के साथ perfectly match

// class AdvancedProfessionalViewAllButton extends StatefulWidget {
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int totalMovies;

//   const AdvancedProfessionalViewAllButton({
//     Key? key,
//     required this.focusNode,
//     required this.onTap,
//     required this.totalMovies,
//   }) : super(key: key);

//   @override
//   _AdvancedProfessionalViewAllButtonState createState() =>
//       _AdvancedProfessionalViewAllButtonState();
// }

// class _AdvancedProfessionalViewAllButtonState
//     extends State<AdvancedProfessionalViewAllButton>
//     with TickerProviderStateMixin {
//   // Multiple Animation Controllers for complex effects
//   late AnimationController _scaleController;
//   late AnimationController _glowController;
//   late AnimationController _shimmerController;
//   late AnimationController _breathingController;
//   late AnimationController _particleController;

//   // Animations
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<double> _shimmerAnimation;
//   late Animation<double> _breathingAnimation;
//   late Animation<double> _particleAnimation;

//   // State
//   bool _isFocused = false;
//   Color _currentColor = ProfessionalColors.accentBlue;
//   List<Particle> _particles = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _generateParticles();
//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _initializeAnimations() {
//     // Scale Animation - Same as movie cards
//     _scaleController = AnimationController(
//       duration: const Duration(milliseconds: 700), // Match movie cards
//       vsync: this,
//     );

//     // Glow Animation
//     _glowController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     // Shimmer Animation
//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     // Breathing Animation (subtle pulse when not focused)
//     _breathingController = AnimationController(
//       duration: const Duration(milliseconds: 3000),
//       vsync: this,
//     )..repeat(reverse: true);

//     // Particle Animation
//     _particleController = AnimationController(
//       duration: const Duration(milliseconds: 4000),
//       vsync: this,
//     )..repeat();

//     // Animation Definitions
//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.04, // Same as movie cards
//     ).animate(CurvedAnimation(
//       parent: _scaleController,
//       curve: Curves.easeOutCubic,
//     ));

//     _glowAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _glowController,
//       curve: Curves.easeInOut,
//     ));

//     _shimmerAnimation = Tween<double>(
//       begin: -1.0,
//       end: 2.0,
//     ).animate(CurvedAnimation(
//       parent: _shimmerController,
//       curve: Curves.easeInOut,
//     ));

//     _breathingAnimation = Tween<double>(
//       begin: 0.95,
//       end: 1.02,
//     ).animate(CurvedAnimation(
//       parent: _breathingController,
//       curve: Curves.easeInOut,
//     ));

//     _particleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_particleController);
//   }

//   void _generateParticles() {
//     _particles = List.generate(
//         8,
//         (index) => Particle(
//               initialX: math.Random().nextDouble(),
//               initialY: math.Random().nextDouble(),
//               size: math.Random().nextDouble() * 3 + 1,
//               speed: math.Random().nextDouble() * 0.5 + 0.3,
//               color: ProfessionalColors.gradientColors[math.Random()
//                       .nextInt(ProfessionalColors.gradientColors.length)]
//                   .withOpacity(0.6),
//             ));
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//       if (_isFocused) {
//         _currentColor = ProfessionalColors.gradientColors[
//             math.Random().nextInt(ProfessionalColors.gradientColors.length)];
//         HapticFeedback.mediumImpact();
//       }
//     });

//     if (_isFocused) {
//       _scaleController.forward();
//       _glowController.forward();
//       _shimmerController.repeat();
//     } else {
//       _scaleController.reverse();
//       _glowController.reverse();
//       _shimmerController.stop();
//     }
//   }

//    Widget _buildMovieStyleBackground() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: _isFocused
//               ? [
//                   _currentColor.withOpacity(0.8),
//                   _currentColor.withOpacity(0.6),
//                   ProfessionalColors.cardDark.withOpacity(0.9),
//                 ]
//               : [
//                   ProfessionalColors.cardDark,
//                   ProfessionalColors.surfaceDark,
//                   ProfessionalColors.cardDark.withOpacity(0.8),
//                 ],
//         ),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               Colors.black.withOpacity(0.1),
//               Colors.black.withOpacity(0.3),
//             ],
//           ),
//         ),
//         // Add subtle pattern for visual enhancement
//         child: CustomPaint(
//           painter: _isFocused ? MovieGridPatternPainter(_currentColor) : null,
//           child: Container(),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     _glowController.dispose();
//     _shimmerController.dispose();
//     _breathingController.dispose();
//     _particleController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Container(
//       width: screenWidth * 0.24,
//       margin: const EdgeInsets.symmetric(horizontal: 6), // Same as movie cards
//       child: Column(
//         children: [
//           _buildAdvancedViewAllCard(screenWidth, screenHeight),
//           const SizedBox(height: 10), // Same spacing as movie cards
//           _buildAdvancedTitle(),
//         ],
//       ),
//     );
//   }

//   Widget _buildAdvancedViewAllCard(double screenWidth, double screenHeight) {
//     // Same height logic as movie cards
//     final cardHeight = _isFocused
//         ? screenHeight * 0.25 // Match movie card focused height
//         : screenHeight * 0.22; // Match movie card normal height

//     return AnimatedBuilder(
//       animation: Listenable.merge([
//         _scaleAnimation,
//         _glowAnimation,
//         _breathingAnimation,
//         _particleAnimation,
//       ]),
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _isFocused ? _scaleAnimation.value : _breathingAnimation.value,
//           child: Container(
//             height: cardHeight,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12), // Same as movie cards
//               boxShadow: [
//                 if (_isFocused) ...[
//                   // Same shadow pattern as movie cards
//                   BoxShadow(
//                     color: _currentColor.withOpacity(0.4),
//                     blurRadius: 25,
//                     spreadRadius: 3,
//                     offset: const Offset(0, 8),
//                   ),
//                   BoxShadow(
//                     color: _currentColor.withOpacity(0.2),
//                     blurRadius: 45,
//                     spreadRadius: 6,
//                     offset: const Offset(0, 15),
//                   ),
//                 ] else ...[
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.4),
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Stack(
//                 children: [
//                   _buildMovieStyleBackground(),
//                   if (_isFocused) _buildFocusBorder(),
//                   if (_isFocused) _buildShimmerEffect(),
//                   _buildFloatingParticles(),
//                   _buildCenterContent(),
//                   _buildQualityBadge(), // Same as movie cards
//                   if (_isFocused) _buildHoverOverlay(),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFocusBorder() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             width: 3,
//             color: _currentColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmerEffect() {
//     return AnimatedBuilder(
//       animation: _shimmerAnimation,
//       builder: (context, child) {
//         return Positioned.fill(
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               gradient: LinearGradient(
//                 begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
//                 end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
//                 colors: [
//                   Colors.transparent,
//                   _currentColor.withOpacity(0.15),
//                   Colors.transparent,
//                 ],
//                 stops: [0.0, 0.5, 1.0],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFloatingParticles() {
//     if (!_isFocused) return const SizedBox.shrink();

//     return AnimatedBuilder(
//       animation: _particleAnimation,
//       builder: (context, child) {
//         return Stack(
//           children: _particles.map((particle) {
//             final progress = (_particleAnimation.value + particle.speed) % 1.0;
//             final x = (particle.initialX + progress * 0.3) % 1.0;
//             final y = (particle.initialY + progress * 0.5) % 1.0;

//             return Positioned(
//               left: x * screenwdt * 0.19,
//               top: y * (MediaQuery.of(context).size.height * 0.25),
//               child: Container(
//                 width: particle.size,
//                 height: particle.size,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: particle.color,
//                   boxShadow: [
//                     BoxShadow(
//                       color: particle.color,
//                       blurRadius: particle.size,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   Widget _buildCenterContent() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Main Icon with rotation effect
//           AnimatedBuilder(
//             animation: _particleAnimation,
//             builder: (context, child) {
//               return Transform.rotate(
//                 angle: _isFocused ? _particleAnimation.value * 0.5 : 0,
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white.withOpacity(_isFocused ? 0.2 : 0.1),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(_isFocused ? 0.4 : 0.2),
//                       width: 2,
//                     ),
//                   ),
//                   child: Icon(
//                     Icons.grid_view_rounded,
//                     size: _isFocused ? 35 : 30,
//                     color: Colors.white,
//                   ),
//                 ),
//               );
//             },
//           ),

//           // SizedBox(height: 12),

//           // Text with typewriter effect
//           Text(
//             'VIEW ALL',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: _isFocused ? 14 : 12,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1.5,
//               shadows: [
//                 Shadow(
//                   color: _isFocused
//                       ? _currentColor.withOpacity(0.6)
//                       : Colors.black.withOpacity(0.5),
//                   blurRadius: _isFocused ? 8 : 4,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//           ),

//           // SizedBox(height: 6),

//           // Movie count badge
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: _isFocused
//                     ? [
//                         _currentColor.withOpacity(0.3),
//                         _currentColor.withOpacity(0.1),
//                       ]
//                     : [
//                         Colors.white.withOpacity(0.25),
//                         Colors.white.withOpacity(0.1),
//                       ],
//               ),
//               borderRadius: BorderRadius.circular(15),
//               border: Border.all(
//                 color: _isFocused
//                     ? _currentColor.withOpacity(0.5)
//                     : Colors.white.withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Text(
//               '${widget.totalMovies}',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQualityBadge() {
//     return Positioned(
//       top: 8,
//       right: 8,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.8),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: const Text(
//           'ALL',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 9,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHoverOverlay() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               _currentColor.withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: const Icon(
//               Icons.explore_rounded,
//               color: Colors.white,
//               size: 30,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAdvancedTitle() {
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.18, // Same as movie cards
//       child: AnimatedDefaultTextStyle(
//         duration: const Duration(milliseconds: 250), // Same timing as movie cards
//         style: TextStyle(
//           fontSize: _isFocused ? 13 : 11, // Same sizes as movie cards
//           fontWeight: FontWeight.w600,
//           color: _isFocused ? _currentColor : ProfessionalColors.textPrimary,
//           letterSpacing: 0.5,
//           shadows: _isFocused
//               ? [
//                   Shadow(
//                     color: _currentColor.withOpacity(0.6),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : [],
//         ),
//         child: const Text(
//           'ALL MOVIES',
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// class MovieGridPatternPainter extends CustomPainter {
//   final Color color;

//   MovieGridPatternPainter(this.color);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color.withOpacity(0.1)
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;

//     final spacing = 20.0;

//     // Draw grid pattern
//     for (double i = 0; i < size.width; i += spacing) {
//       canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
//     }

//     for (double i = 0; i < size.height; i += spacing) {
//       canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
//     }

//     // Add movie film strip effect
//     final filmPaint = Paint()
//       ..color = color.withOpacity(0.05)
//       ..style = PaintingStyle.fill;

//     for (double i = 0; i < size.width; i += 40) {
//       canvas.drawRect(
//         Rect.fromLTWH(i, 0, 20, size.height),
//         filmPaint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// // Particle class for floating effects
// class Particle {
//   final double initialX;
//   final double initialY;
//   final double size;
//   final double speed;
//   final Color color;

//   Particle({
//     required this.initialX,
//     required this.initialY,
//     required this.size,
//     required this.speed,
//     required this.color,
//   });
// }

// // 🔄 USAGE: Original ProfessionalViewAllButton को replace करें
// // Old code में यहाँ change करें:

// /*
// // REMOVE OLD:
// ProfessionalViewAllButton(
//   focusNode: _viewAllFocusNode!,
//   onTap: _navigateToMoviesGrid,
//   totalMovies: moviesList.length,
// )

// // ADD NEW:
// AdvancedProfessionalViewAllButton(
//   focusNode: _viewAllFocusNode!,
//   onTap: _navigateToMoviesGrid,
//   totalMovies: moviesList.length,
// )
// */

// // Enhanced Professional Movies Grid View with Independent Data Loading
// class ProfessionalMoviesGridView extends StatefulWidget {
//   const ProfessionalMoviesGridView({Key? key}) : super(key: key);

//   @override
//   _ProfessionalMoviesGridViewState createState() =>
//       _ProfessionalMoviesGridViewState();
// }

// class _ProfessionalMoviesGridViewState extends State<ProfessionalMoviesGridView>
//     with TickerProviderStateMixin {
//   // Data Management
//   List<dynamic> _allMoviesList = [];
//   Map<String, FocusNode> _movieFocusNodes = {};
//   bool _isLoading = true;
//   bool _isNavigating = false;
//   String _errorMessage = '';
//   int _totalMoviesCount = 0;

//   // Services
//   late SocketService _socketService;

//   // Animation Controllers
//   late AnimationController _fadeController;
//   late AnimationController _staggerController;
//   late AnimationController _loadingController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _loadingAnimation;

//   // Pagination and Performance
//   static const int _moviesPerPage = 20;
//   int _currentPage = 1;
//   bool _hasMoreMovies = true;
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _initializeServices();
//     _initializeAnimations();
//     _loadAllMoviesData();
//     _setupScrollListener();
//   }

//   void _initializeServices() {
//     _socketService = SocketService();
//     _socketService.initSocket();
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _staggerController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     _loadingController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     ));

//     _loadingAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_loadingController);
//   }

//   void _setupScrollListener() {
//     _scrollController.addListener(() {
//       // Load more movies when reaching 80% of scroll
//       if (_scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent * 0.8) {
//         _loadMoreMovies();
//       }
//     });
//   }

//   // 🎯 MAIN DATA LOADING METHOD
//   Future<void> _loadAllMoviesData() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = AuthManager.authKey;
//       if (authKey.isEmpty) {
//         authKey = prefs.getString('auth_key') ?? '';
//       }

//       // 🚀 FETCH ALL MOVIES WITHOUT LIMIT
//       final response = await NetworkHelper.getWithRetry(
//         'https://acomtv.coretechinfo.com/public/api/getAllMovies', // No records limit
//         headers: {'auth-key': authKey},
//         timeout: 15,
//         retries: 3,
//       );

//       if (response.statusCode == 200 && mounted) {
//         List<dynamic> moviesData = json.decode(response.body);

//         // Sort movies by index
//         _sortMoviesData(moviesData);

//         setState(() {
//           _allMoviesList = moviesData;
//           _totalMoviesCount = moviesData.length;
//           _initializeMovieFocusNodes();
//           _isLoading = false;
//         });

//         // Start animations
//         _fadeController.forward();
//         _staggerController.forward();

//         // Focus first movie
//         _focusFirstMovie();

//         // Cache the data
//         await CacheManager.saveMovies(moviesData);

//       } else {
//         _handleLoadingError('Failed to load movies (${response.statusCode})');
//       }
//     } catch (e) {
//       _handleLoadingError('Network error: Please check connection');
//     }
//   }

//   void _sortMoviesData(List<dynamic> data) {
//     if (data.isEmpty) return;

//     try {
//       data.sort((a, b) {
//         final aIndex = a['index'];
//         final bIndex = b['index'];

//         if (aIndex == null && bIndex == null) return 0;
//         if (aIndex == null) return 1;
//         if (bIndex == null) return -1;

//         int aVal = 0;
//         int bVal = 0;

//         if (aIndex is num) {
//           aVal = aIndex.toInt();
//         } else if (aIndex is String) {
//           aVal = int.tryParse(aIndex) ?? 0;
//         }

//         if (bIndex is num) {
//           bVal = bIndex.toInt();
//         } else if (bIndex is String) {
//           bVal = int.tryParse(bIndex) ?? 0;
//         }

//         return aVal.compareTo(bVal);
//       });
//     } catch (e) {
//       // Silent error handling
//     }
//   }

//   void _handleLoadingError(String message) {
//     if (mounted) {
//       setState(() {
//         _errorMessage = message;
//         _isLoading = false;
//       });
//     }
//   }

//   void _initializeMovieFocusNodes() {
//     // Dispose existing nodes
//     for (var node in _movieFocusNodes.values) {
//       try {
//         node.dispose();
//       } catch (e) {}
//     }
//     _movieFocusNodes.clear();

//     // Create new focus nodes
//     for (var movie in _allMoviesList) {
//       try {
//         String movieId = movie['id'].toString();
//         _movieFocusNodes[movieId] = FocusNode();
//       } catch (e) {}
//     }
//   }

//   void _focusFirstMovie() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && _allMoviesList.isNotEmpty) {
//         try {
//           final firstMovieId = _allMoviesList[0]['id'].toString();
//           if (_movieFocusNodes.containsKey(firstMovieId)) {
//             FocusScope.of(context).requestFocus(_movieFocusNodes[firstMovieId]);
//           }
//         } catch (e) {}
//       }
//     });
//   }

//   // 🔄 LOAD MORE MOVIES (for pagination if needed)
//   Future<void> _loadMoreMovies() async {
//     if (!_hasMoreMovies || _isLoading) return;

//     try {
//       _currentPage++;
//       // Implementation for pagination if API supports it
//       // This is optional and depends on your API
//     } catch (e) {
//       // Handle pagination error
//     }
//   }

//   // 🎬 MOVIE TAP HANDLER
//   Future<void> _handleGridMovieTap(dynamic movie) async {
//     if (_isNavigating || !mounted) return;

//     _isNavigating = true;
//     bool dialogShown = false;
//     Timer? timeoutTimer;

//     try {
//       if (mounted) {
//         dialogShown = true;
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return WillPopScope(
//               onWillPop: () async {
//                 _isNavigating = false;
//                 return true;
//               },
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.85),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 60,
//                         height: 60,
//                         child: const CircularProgressIndicator(
//                           strokeWidth: 4,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             ProfessionalColors.accentBlue,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'Loading Movie...',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Please wait',
//                         style: TextStyle(
//                           color: ProfessionalColors.textSecondary,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       }

//       // Set timeout
//       timeoutTimer = Timer(const Duration(seconds: 20), () {
//         if (mounted && _isNavigating) {
//           _isNavigating = false;
//           if (dialogShown) {
//             Navigator.of(context, rootNavigator: true).pop();
//           }
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Request timeout. Please check your connection.'),
//               backgroundColor: ProfessionalColors.accentRed,
//             ),
//           );
//         }
//       });

//       Map<String, dynamic> movieMap = movie as Map<String, dynamic>;
//       String movieId = movieMap.safeString('id');
//       String originalUrl = movieMap.safeString('movie_url');
//       String updatedUrl = movieMap.safeString('movie_url');

//       if (originalUrl.isEmpty) {
//         throw Exception('Video URL is not available');
//       }

//       // Convert current movies to NewsItemModel for video player
//       List<NewsItemModel> moviePlaylist = _convertToNewsItemModels(_allMoviesList);

//       timeoutTimer.cancel();

//       if (mounted && _isNavigating) {
//         if (dialogShown) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }

//         if (updatedUrl.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Video URL is not available'),
//               backgroundColor: ProfessionalColors.accentRed,
//             ),
//           );
//           return;
//         }

//         try {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => YouTubePlayerScreen(
//                 videoData: VideoData(
//                   id: movieId,
//                   title: movieMap.safeString('name'),
//                   youtubeUrl: updatedUrl,
//                   thumbnail: movieMap.safeString('banner'),
//                 ),
//                 playlist: moviePlaylist
//                     .map((m) => VideoData(
//                           id: m.id,
//                           title: m.name,
//                           youtubeUrl: m.url,
//                           thumbnail: m.banner,
//                         ))
//                     .toList(),
//               ),
//             ),
//           );
//         } catch (e) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Failed to open video player'),
//                 backgroundColor: ProfessionalColors.accentRed,
//               ),
//             );
//           }
//         }
//       }
//     } catch (e) {
//       timeoutTimer?.cancel();
//       if (mounted) {
//         if (dialogShown) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${e.toString()}'),
//             backgroundColor: ProfessionalColors.accentRed,
//           ),
//         );
//       }
//     } finally {
//       _isNavigating = false;
//       timeoutTimer?.cancel();
//     }
//   }

//   List<NewsItemModel> _convertToNewsItemModels(List<dynamic> movies) {
//     return movies.map((m) {
//       try {
//         Map<String, dynamic> movie = m as Map<String, dynamic>;
//         return NewsItemModel(
//           id: movie.safeString('id'),
//           name: movie.safeString('name'),
//           banner: movie.safeString('banner'),
//           poster: movie.safeString('poster'),
//           description: movie.safeString('description'),
//           url: movie.safeString('url'),
//           streamType: movie.safeString('streamType'),
//           type: movie.safeString('type'),
//           genres: movie.safeString('genres'),
//           status: movie.safeString('status'),
//           videoId: movie.safeString('videoId'),
//           index: movie.safeString('index'),
//           image: '',
//           unUpdatedUrl: '',
//         );
//       } catch (e) {
//         return NewsItemModel(
//           id: '',
//           name: 'Unknown',
//           banner: '',
//           poster: '',
//           description: '',
//           url: '',
//           streamType: '',
//           type: '',
//           genres: '',
//           status: '',
//           videoId: '',
//           index: '',
//           image: '',
//           unUpdatedUrl: '',
//         );
//       }
//     }).toList();
//   }

//   // 🔄 REFRESH DATA
//   Future<void> _refreshMoviesData() async {
//     setState(() {
//       _currentPage = 1;
//       _hasMoreMovies = true;
//     });
//     await _loadAllMoviesData();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _staggerController.dispose();
//     _loadingController.dispose();
//     _scrollController.dispose();

//     for (var node in _movieFocusNodes.values) {
//       try {
//         node.dispose();
//       } catch (e) {}
//     }
//     _movieFocusNodes.clear();

//     _isNavigating = false;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Stack(
//         children: [
//           // Background Gradient
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   ProfessionalColors.primaryDark,
//                   ProfessionalColors.surfaceDark.withOpacity(0.8),
//                   ProfessionalColors.primaryDark,
//                 ],
//               ),
//             ),
//           ),

//           // Main Content
//           Column(
//             children: [
//               _buildProfessionalAppBar(),
//               Expanded(child: _buildBody()),
//             ],
//           ),

//           // Loading Overlay
//           if (_isNavigating)
//             Container(
//               color: Colors.black.withOpacity(0.7),
//               child: const Center(
//                 child: ProfessionalLoadingIndicator(message: 'Loading Movie...'),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfessionalAppBar() {
//     return Container(
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 20,
//         left: 20,
//         right: 20,
//         bottom: 20,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             ProfessionalColors.surfaceDark.withOpacity(0.9),
//             ProfessionalColors.surfaceDark.withOpacity(0.7),
//             Colors.transparent,
//           ],
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentBlue.withOpacity(0.2),
//                   ProfessionalColors.accentPurple.withOpacity(0.2),
//                 ],
//               ),
//             ),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.arrow_back_rounded,
//                 color: Colors.white,
//                 size: 24,
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ShaderMask(
//                   shaderCallback: (bounds) => const LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple,
//                     ],
//                   ).createShader(bounds),
//                   child: const Text(
//                     'All Movies',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Row(
//             children: [
//               // Refresh Button
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentGreen.withOpacity(0.2),
//                       ProfessionalColors.accentBlue.withOpacity(0.2),
//                     ],
//                   ),
//                 ),
//                 child: IconButton(
//                   icon: AnimatedBuilder(
//                     animation: _loadingAnimation,
//                     builder: (context, child) {
//                       return Transform.rotate(
//                         angle: _isLoading ? _loadingAnimation.value * 2 * math.pi : 0,
//                         child: const Icon(
//                           Icons.refresh_rounded,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       );
//                     },
//                   ),
//                   onPressed: _isLoading ? null : _refreshMoviesData,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               // Movies Count Badge
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue.withOpacity(0.2),
//                       ProfessionalColors.accentPurple.withOpacity(0.2),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(15),
//                   border: Border.all(
//                     color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   '$_totalMoviesCount Movies',
//                   style: const TextStyle(
//                     color: ProfessionalColors.textSecondary,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return _buildLoadingView();
//     } else if (_errorMessage.isNotEmpty) {
//       return _buildErrorView();
//     } else if (_allMoviesList.isEmpty) {
//       return _buildEmptyView();
//     } else {
//       return _buildMoviesGrid();
//     }
//   }

//   Widget _buildLoadingView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _loadingAnimation,
//             builder: (context, child) {
//               return Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: SweepGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple,
//                       ProfessionalColors.accentGreen,
//                       ProfessionalColors.accentBlue,
//                     ],
//                     stops: [0.0, 0.3, 0.7, 1.0],
//                     transform: GradientRotation(_loadingAnimation.value * 2 * math.pi),
//                   ),
//                 ),
//                 child: Container(
//                   margin: const EdgeInsets.all(6),
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: ProfessionalColors.primaryDark,
//                   ),
//                   child: const Icon(
//                     Icons.movie_rounded,
//                     color: ProfessionalColors.textPrimary,
//                     size: 32,
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Loading All Movies...',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Please wait while we fetch the complete movie collection',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentRed.withOpacity(0.2),
//                   ProfessionalColors.accentRed.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.error_outline_rounded,
//               size: 40,
//               color: ProfessionalColors.accentRed,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Oops! Something went wrong',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _errorMessage,
//             style: const TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _refreshMoviesData,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: ProfessionalColors.accentBlue,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: const Text(
//               'Try Again',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentBlue.withOpacity(0.2),
//                   ProfessionalColors.accentBlue.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.movie_outlined,
//               size: 40,
//               color: ProfessionalColors.accentBlue,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No movies found',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Check back later for new content',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMoviesGrid() {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: RefreshIndicator(
//         onRefresh: _refreshMoviesData,
//         color: ProfessionalColors.accentBlue,
//         backgroundColor: ProfessionalColors.surfaceDark,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: GridView.builder(
//             controller: _scrollController,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 4,
//               mainAxisSpacing: 16,
//               crossAxisSpacing: 16,
//               childAspectRatio: 1.4,
//             ),
//             itemCount: _allMoviesList.length,
//             clipBehavior: Clip.none,
//             itemBuilder: (context, index) {
//               final movie = _allMoviesList[index];
//               String movieId = movie['id'].toString();

//               return AnimatedBuilder(
//                 animation: _staggerController,
//                 builder: (context, child) {
//                   final delay = (index / _allMoviesList.length) * 0.3;
//                   final animationValue = Interval(
//                     delay,
//                     (delay + 0.3).clamp(0.0, 1.0),
//                     curve: Curves.easeOutCubic,
//                   ).transform(_staggerController.value);

//                   return Transform.translate(
//                     offset: Offset(0, 30 * (1 - animationValue)),
//                     child: Opacity(
//                       opacity: animationValue,
//                       child: ProfessionalGridMovieCard(
//                         movie: movie,
//                         focusNode: _movieFocusNodes[movieId]!,
//                         onTap: () => _handleGridMovieTap(movie),
//                         index: index,
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// // 🔄 UPDATED NAVIGATION CALL - Home screen में यह change करें:

// /*
// // OLD navigation call in Movies widget:
// void _navigateToMoviesGrid() {
//   if (!_isNavigating && mounted) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProfessionalMoviesGridView(moviesList: moviesList), // ❌ OLD
//       ),
//     );
//   }
// }

// // NEW navigation call:
// void _navigateToMoviesGrid() {
//   if (!_isNavigating && mounted) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const ProfessionalMoviesGridView(), // ✅ NEW - No data passing
//       ),
//     );
//   }
// }
// */

// // // Enhanced Professional Movies Grid View
// // class ProfessionalMoviesGridView extends StatefulWidget {
// //   final List<dynamic> moviesList;

// //   const ProfessionalMoviesGridView({Key? key, required this.moviesList})
// //       : super(key: key);

// //   @override
// //   _ProfessionalMoviesGridViewState createState() =>
// //       _ProfessionalMoviesGridViewState();
// // }

// // class _ProfessionalMoviesGridViewState extends State<ProfessionalMoviesGridView>
// //     with TickerProviderStateMixin {
// //   late Map<String, FocusNode> _movieFocusNodes;
// //   bool _isLoading = false;
// //   late SocketService _socketService;

// //   // Animation Controllers
// //   late AnimationController _fadeController;
// //   late AnimationController _staggerController;
// //   late Animation<double> _fadeAnimation;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _socketService = SocketService();
// //     _socketService.initSocket();

// //     _movieFocusNodes = {
// //       for (var movie in widget.moviesList) movie['id'].toString(): FocusNode()
// //     };

// //   _fetchFullMoviesData();

// //     // Set up focus for the first movie
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (widget.moviesList.isNotEmpty) {
// //         final firstMovieId = widget.moviesList[0]['id'].toString();
// //         if (_movieFocusNodes.containsKey(firstMovieId)) {
// //           FocusScope.of(context).requestFocus(_movieFocusNodes[firstMovieId]);
// //         }
// //       }
// //     });

// //     _initializeAnimations();
// //     _startStaggeredAnimation();
// //   }

// //   // Add this method in _ProfessionalMoviesGridViewState class:
// // void _sortMoviesData(List<dynamic> data) {
// //   if (data.isEmpty) return;

// //   try {
// //     data.sort((a, b) {
// //       final aIndex = a['index'];
// //       final bIndex = b['index'];

// //       if (aIndex == null && bIndex == null) return 0;
// //       if (aIndex == null) return 1;
// //       if (bIndex == null) return -1;

// //       int aVal = 0;
// //       int bVal = 0;

// //       if (aIndex is num) {
// //         aVal = aIndex.toInt();
// //       } else if (aIndex is String) {
// //         aVal = int.tryParse(aIndex) ?? 0;
// //       }

// //       if (bIndex is num) {
// //         bVal = bIndex.toInt();
// //       } else if (bIndex is String) {
// //         bVal = int.tryParse(bIndex) ?? 0;
// //       }

// //       return aVal.compareTo(bVal);
// //     });
// //   } catch (e) {}
// // }

// //   // Add this method in GridView class:
// // Future<void> _fetchFullMoviesData() async {
// //   try {
// //     final prefs = await SharedPreferences.getInstance();
// //     String authKey = AuthManager.authKey;
// //     if (authKey.isEmpty) {
// //       authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
// //     }

// //     final response = await NetworkHelper.getWithRetry(
// //       'https://acomtv.coretechinfo.com/public/api/getAllMovies/20', // No limit
// //       headers: {'auth-key': authKey},
// //     );

// //     if (response.statusCode == 200 && mounted) {
// //       List<dynamic> fullData = json.decode(response.body);
// //       _sortMoviesData(fullData);

// //       setState(() {
// //         widget.moviesList.clear();
// //         widget.moviesList.addAll(fullData);

// //         // Update focus nodes
// //         _movieFocusNodes.clear();
// //         _movieFocusNodes = {
// //           for (var movie in fullData) movie['id'].toString(): FocusNode()
// //         };
// //       });
// //     }
// //   } catch (e) {}
// // }

// //   void _initializeAnimations() {
// //     _fadeController = AnimationController(
// //       duration: const Duration(milliseconds: 600),
// //       vsync: this,
// //     );

// //     _staggerController = AnimationController(
// //       duration: const Duration(milliseconds: 1200),
// //       vsync: this,
// //     );

// //     _fadeAnimation = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(CurvedAnimation(
// //       parent: _fadeController,
// //       curve: Curves.easeInOut,
// //     ));
// //   }

// //   void _startStaggeredAnimation() {
// //     _fadeController.forward();
// //     _staggerController.forward();
// //   }

// //   bool _isYoutubeUrl(String? url) {
// //     if (url == null || url.isEmpty) {
// //       return false;
// //     }

// //     url = url.toLowerCase().trim();

// //     bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
// //     if (isYoutubeId) {
// //       return true;
// //     }

// //     bool isYoutubeUrl = url.contains('youtube.com') ||
// //         url.contains('youtu.be') ||
// //         url.contains('youtube.com/shorts/');
// //     if (isYoutubeUrl) {
// //       return true;
// //     }

// //     return false;
// //   }

// //   Future<void> _handleGridMovieTap(dynamic movie) async {
// //     if (_isLoading || !mounted) return;

// //     setState(() {
// //       _isLoading = true;
// //     });

// //     bool dialogShown = false;
// //     try {
// //       if (mounted) {
// //         dialogShown = true;
// //         showDialog(
// //           context: context,
// //           barrierDismissible: false,
// //           builder: (BuildContext context) {
// //             return WillPopScope(
// //               onWillPop: () async {
// //                 setState(() {
// //                   _isLoading = false;
// //                 });
// //                 return true;
// //               },
// //               child: Center(
// //                 child: Container(
// //                   padding: const EdgeInsets.all(24),
// //                   decoration: BoxDecoration(
// //                     color: Colors.black.withOpacity(0.85),
// //                     borderRadius: BorderRadius.circular(20),
// //                     border: Border.all(
// //                       color: ProfessionalColors.accentBlue.withOpacity(0.3),
// //                       width: 1,
// //                     ),
// //                   ),
// //                   child: Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Container(
// //                         width: 60,
// //                         height: 60,
// //                         child: const CircularProgressIndicator(
// //                           strokeWidth: 4,
// //                           valueColor: AlwaysStoppedAnimation<Color>(
// //                             ProfessionalColors.accentBlue,
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20),
// //                       const Text(
// //                         'Loading Movie...',
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 8),
// //                       const Text(
// //                         'Please wait',
// //                         style: TextStyle(
// //                           color: ProfessionalColors.textSecondary,
// //                           fontSize: 14,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         );
// //       }

// //       Map<String, dynamic> movieMap = movie as Map<String, dynamic>;
// //       String movieId = movieMap.safeString('id');
// //       String originalUrl = movieMap.safeString('movie_url');
// //       String updatedUrl = movieMap.safeString('movie_url');

// //       if (originalUrl.isEmpty) {
// //         throw Exception('Video URL is not available');
// //       }

// //       if (isYoutubeUrl(updatedUrl)) {
// //         try {
// //           // final playUrl = await Future.any([
// //           //   _socketService.getUpdatedUrl(updatedUrl),
// //           //   Future.delayed(Duration(seconds: 15), () => ''),
// //           // ]);
// //           // final playUrl = await _socketService.getUpdatedUrl(updatedUrl);
// //           // if (playUrl.isNotEmpty) {
// //           //   // updatedUrl = playUrl;
// //           // } else {
// //           //   throw Exception('Failed to fetch updated URL');
// //           // }
// //         } catch (e) {
// //           // updatedUrl = originalUrl;
// //         }
// //       }

// //       List<NewsItemModel> freshMovies = await Future.any([
// //         _fetchFreshMoviesForGrid(),
// //         Future.delayed(const Duration(seconds: 10), () => <NewsItemModel>[]),
// //       ]);

// //       if (freshMovies.isEmpty) {
// //         freshMovies = widget.moviesList.map((m) {
// //           try {
// //             Map<String, dynamic> movieData = m as Map<String, dynamic>;
// //             return NewsItemModel(
// //               id: movieData.safeString('id'),
// //               name: movieData.safeString('name'),
// //               banner: movieData.safeString('banner'),
// //               poster: movieData.safeString('poster'),
// //               description: movieData.safeString('description'),
// //               url: movieData.safeString('url'),
// //               streamType: movieData.safeString('streamType'),
// //               type: movieData.safeString('type'),
// //               genres: movieData.safeString('genres'),
// //               status: movieData.safeString('status'),
// //               videoId: movieData.safeString('videoId'),
// //               index: movieData.safeString('index'),
// //               image: '',
// //               unUpdatedUrl: '',
// //             );
// //           } catch (e) {
// //             return NewsItemModel(
// //               id: '',
// //               name: 'Unknown',
// //               banner: '',
// //               poster: '',
// //               description: '',
// //               url: '',
// //               streamType: '',
// //               type: '',
// //               genres: '',
// //               status: '',
// //               videoId: '',
// //               index: '',
// //               image: '',
// //               unUpdatedUrl: '',
// //             );
// //           }
// //         }).toList();
// //       }

// //       if (mounted) {
// //         if (dialogShown) {
// //           Navigator.of(context, rootNavigator: true).pop();
// //         }

// //         if (updatedUrl.isEmpty) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //               content: const Text('Video URL is not available'),
// //               backgroundColor: ProfessionalColors.accentRed,
// //               behavior: SnackBarBehavior.floating,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //             ),
// //           );
// //           return;
// //         }

// //         await Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             // builder: (context) => VideoScreen(
// //             //   channelList: freshMovies,
// //             //   source: 'isMovieScreen',
// //             //   name: movieMap.safeString('name'),
// //             //   videoUrl: updatedUrl,
// //             //   unUpdatedUrl: originalUrl,
// //             //   bannerImageUrl: movieMap.safeString('banner'),
// //             //   startAtPosition: Duration.zero,
// //             //   videoType: '',
// //             //   isLive: false,
// //             //   isVOD: true,
// //             //   isLastPlayedStored: false,
// //             //   isSearch: false,
// //             //   isBannerSlider: false,
// //             //   videoId: int.tryParse(movieId),
// //             //   seasonId: 0,
// //             //   liveStatus: false,
// //             // ),
// //             //           builder: (context) => BetterPlayerExample (
// //             // videoUrl: updatedUrl,
// //             // videoTitle: movieMap.safeString('name'),
// //             // ),
// //             builder: (context) => YouTubePlayerScreen(
// //               videoData: VideoData(
// //                 id: movieId,
// //                 title: movieMap.safeString('name'),
// //                 youtubeUrl: updatedUrl,
// //                 thumbnail: movieMap.safeString('banner'),
// //                 //  description: movieMap.safeString('description'),
// //               ),
// //               playlist: freshMovies
// //                   .map((m) => VideoData(
// //                         id: m.id,
// //                         title: m.name,
// //                         youtubeUrl: m.url,
// //                         thumbnail: m.banner,
// //                         //  description: m.description,
// //                       ))
// //                   .toList(),
// //             ),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         if (dialogShown) {
// //           Navigator.of(context, rootNavigator: true).pop();
// //         }
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: const Text('Error loading movie'),
// //             backgroundColor: ProfessionalColors.accentRed,
// //             behavior: SnackBarBehavior.floating,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(10),
// //             ),
// //           ),
// //         );
// //       }
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           _isLoading = false;
// //         });
// //       }
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _fadeController.dispose();
// //     _staggerController.dispose();
// //     for (var node in _movieFocusNodes.values) {
// //       try {
// //         node.dispose();
// //       } catch (e) {}
// //     }
// //     super.dispose();
// //   }

// //   Future<List<NewsItemModel>> _fetchFreshMoviesForGrid() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       String authKey = AuthManager.authKey;
// //       if (authKey.isEmpty) {
// //         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
// //       }

// //       final response = await NetworkHelper.getWithRetry(
// //         'https://acomtv.coretechinfo.com/public/api/getAllMovies/records=20',
// //         headers: {'auth-key': authKey},
// //       );

// //       if (response.statusCode == 200) {
// //         List<dynamic> data = json.decode(response.body);

// //         if (data.isNotEmpty) {
// //           data.sort((a, b) {
// //             final aIndex = a['index'];
// //             final bIndex = b['index'];

// //             if (aIndex == null && bIndex == null) return 0;
// //             if (aIndex == null) return 1;
// //             if (bIndex == null) return -1;

// //             int aVal = 0;
// //             int bVal = 0;

// //             if (aIndex is num) {
// //               aVal = aIndex.toInt();
// //             } else if (aIndex is String) {
// //               aVal = int.tryParse(aIndex) ?? 0;
// //             }

// //             if (bIndex is num) {
// //               bVal = bIndex.toInt();
// //             } else if (bIndex is String) {
// //               bVal = int.tryParse(bIndex) ?? 0;
// //             }

// //             return aVal.compareTo(bVal);
// //           });
// //         }

// //         return data.map((m) {
// //           try {
// //             Map<String, dynamic> movie = m as Map<String, dynamic>;
// //             return NewsItemModel(
// //               id: movie.safeString('id'),
// //               name: movie.safeString('name'),
// //               banner: movie.safeString('banner'),
// //               poster: movie.safeString('poster'),
// //               description: movie.safeString('description'),
// //               url: movie.safeString('url'),
// //               streamType: movie.safeString('streamType'),
// //               type: movie.safeString('type'),
// //               genres: movie.safeString('genres'),
// //               status: movie.safeString('status'),
// //               videoId: movie.safeString('videoId'),
// //               index: movie.safeString('index'),
// //               image: '',
// //               unUpdatedUrl: '',
// //             );
// //           } catch (e) {
// //             return NewsItemModel(
// //               id: '',
// //               name: 'Unknown',
// //               banner: '',
// //               poster: '',
// //               description: '',
// //               url: '',
// //               streamType: '',
// //               type: '',
// //               genres: '',
// //               status: '',
// //               videoId: '',
// //               index: '',
// //               image: '',
// //               unUpdatedUrl: '',
// //             );
// //           }
// //         }).toList();
// //       }
// //     } catch (e) {}
// //     return [];
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: ProfessionalColors.primaryDark,
// //       body: Stack(
// //         children: [
// //           // Background Gradient
// //           Container(
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topCenter,
// //                 end: Alignment.bottomCenter,
// //                 colors: [
// //                   ProfessionalColors.primaryDark,
// //                   ProfessionalColors.surfaceDark.withOpacity(0.8),
// //                   ProfessionalColors.primaryDark,
// //                 ],
// //               ),
// //             ),
// //           ),

// //           // Main Content
// //           FadeTransition(
// //             opacity: _fadeAnimation,
// //             child: Column(
// //               children: [
// //                 _buildProfessionalAppBar(),
// //                 Expanded(
// //                   child: _buildMoviesGrid(),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           // Loading Overlay
// //           if (_isLoading)
// //             Container(
// //               color: Colors.black.withOpacity(0.7),
// //               child: const Center(
// //                 child:
// //                     ProfessionalLoadingIndicator(message: 'Loading Movie...'),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildProfessionalAppBar() {
// //     return Container(
// //       padding: EdgeInsets.only(
// //         top: MediaQuery.of(context).padding.top + 20,
// //         left: 20,
// //         right: 20,
// //         bottom: 20,
// //       ),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topCenter,
// //           end: Alignment.bottomCenter,
// //           colors: [
// //             ProfessionalColors.surfaceDark.withOpacity(0.9),
// //             ProfessionalColors.surfaceDark.withOpacity(0.7),
// //             Colors.transparent,
// //           ],
// //         ),
// //       ),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.center ,
// //         children: [
// //           Container(
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               gradient: LinearGradient(
// //                 colors: [
// //                   ProfessionalColors.accentBlue.withOpacity(0.2),
// //                   ProfessionalColors.accentPurple.withOpacity(0.2),
// //                 ],
// //               ),
// //             ),
// //             child: IconButton(
// //               icon: const Icon(
// //                 Icons.arrow_back_rounded,
// //                 color: Colors.white,
// //                 size: 24,
// //               ),
// //               onPressed: () => Navigator.pop(context),
// //             ),
// //           ),
// //           const SizedBox(width: 16),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 ShaderMask(
// //                   shaderCallback: (bounds) => const LinearGradient(
// //                     colors: [
// //                       ProfessionalColors.accentBlue,
// //                       ProfessionalColors.accentPurple,
// //                     ],
// //                   ).createShader(bounds),
// //                   child: const Text(
// //                     'All Movies',
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 24,
// //                       fontWeight: FontWeight.w700,
// //                       letterSpacing: 1.0,
// //                     ),
// //                   ),
// //                 ),
// //                 // const SizedBox(height: 4),

// //               ],
// //             ),
// //           ),
// //           Container(
// //                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(
// //                       colors: [
// //                         ProfessionalColors.accentBlue.withOpacity(0.2),
// //                         ProfessionalColors.accentPurple.withOpacity(0.2),
// //                       ],
// //                     ),
// //                     borderRadius: BorderRadius.circular(15),
// //                     border: Border.all(
// //                       color: ProfessionalColors.accentBlue.withOpacity(0.3),
// //                       width: 1,
// //                     ),
// //                   ),
// //                   child: Text(
// //                     '${widget.moviesList.length} Movies Available',
// //                     style: const TextStyle(
// //                       color: ProfessionalColors.textSecondary,
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                 ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildMoviesGrid() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 20),
// //       child: GridView.builder(
// //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //           crossAxisCount: 4,
// //           mainAxisSpacing: 16,
// //           crossAxisSpacing: 16,
// //           childAspectRatio: 1.6,
// //         ),
// //         itemCount: widget.moviesList.length,
// //         clipBehavior: Clip.none,
// //         itemBuilder: (context, index) {
// //           final movie = widget.moviesList[index];
// //           String movieId = movie['id'].toString();

// //           return AnimatedBuilder(
// //             animation: _staggerController,
// //             builder: (context, child) {
// //               final delay = (index / widget.moviesList.length) * 0.5;
// //               final animationValue = Interval(
// //                 delay,
// //                 delay + 0.5,
// //                 curve: Curves.easeOutCubic,
// //               ).transform(_staggerController.value);

// //               return Transform.translate(
// //                 offset: Offset(0, 50 * (1 - animationValue)),
// //                 child: Opacity(
// //                   opacity: animationValue,
// //                   child: ProfessionalGridMovieCard(
// //                     movie: movie,
// //                     focusNode: _movieFocusNodes[movieId]!,
// //                     onTap: () => _handleGridMovieTap(movie),
// //                     index: index,
// //                   ),
// //                 ),
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }

// // Professional Grid Movie Card
// class ProfessionalGridMovieCard extends StatefulWidget {
//   final dynamic movie;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int index;

//   const ProfessionalGridMovieCard({
//     Key? key,
//     required this.movie,
//     required this.focusNode,
//     required this.onTap,
//     required this.index,
//   }) : super(key: key);

//   @override
//   _ProfessionalGridMovieCardState createState() =>
//       _ProfessionalGridMovieCardState();
// }

// class _ProfessionalGridMovieCardState extends State<ProfessionalGridMovieCard>
//     with TickerProviderStateMixin {
//   late AnimationController _hoverController;
//   late AnimationController _glowController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;

//   Color _dominantColor = ProfessionalColors.accentBlue;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();

//     _hoverController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _glowController = AnimationController(
//       duration: AnimationTiming.medium,
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.05,
//     ).animate(CurvedAnimation(
//       parent: _hoverController,
//       curve: Curves.easeOutCubic,
//     ));

//     _glowAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _glowController,
//       curve: Curves.easeInOut,
//     ));

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _hoverController.forward();
//       _glowController.forward();
//       _generateDominantColor();
//       HapticFeedback.lightImpact();
//     } else {
//       _hoverController.reverse();
//       _glowController.reverse();
//     }
//   }

//   void _generateDominantColor() {
//     final colors = ProfessionalColors.gradientColors;
//     _dominantColor = colors[math.Random().nextInt(colors.length)];
//   }

//   bool _isValidImageUrl(String url) {
//     if (url.isEmpty) return false;

//     try {
//       final uri = Uri.parse(url);
//       if (!uri.hasAbsolutePath) return false;
//       if (uri.scheme != 'http' && uri.scheme != 'https') return false;

//       final path = uri.path.toLowerCase();
//       return path.contains('.jpg') ||
//              path.contains('.jpeg') ||
//              path.contains('.png') ||
//              path.contains('.webp') ||
//              path.contains('.gif') ||
//              path.contains('image') ||
//              path.contains('thumb') ||
//              path.contains('banner') ||
//              path.contains('poster');
//     } catch (e) {
//       return false;
//     }
//   }

//   // ↓ REPLACE EXISTING _buildMovieImage METHOD:

//   Widget _buildMovieImage() {
//     final bannerUrl = widget.movie['banner']?.toString() ?? '';
//     final posterUrl = widget.movie['poster']?.toString() ?? '';

//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       child: Stack(
//         children: [
//           // Default background with movie info
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   ProfessionalColors.cardDark,
//                   ProfessionalColors.surfaceDark,
//                 ],
//               ),
//             ),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.movie_outlined,
//                     size: 40,
//                     color: ProfessionalColors.textSecondary,
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'MOVIE',
//                     style: TextStyle(
//                       color: ProfessionalColors.textSecondary,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: ProfessionalColors.accentBlue.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Text(
//                       'HD',
//                       style: TextStyle(
//                         color: ProfessionalColors.accentBlue,
//                         fontSize: 8,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Try banner first
//           if (_isValidImageUrl(bannerUrl))
//             CachedNetworkImage(
//               imageUrl: bannerUrl,
//               fit: BoxFit.cover,
//               width: double.infinity,
//               height: double.infinity,
//               placeholder: (context, url) => Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.cardDark,
//                       ProfessionalColors.surfaceDark,
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       ProfessionalColors.accentBlue,
//                     ),
//                   ),
//                 ),
//               ),
//               errorWidget: (context, url, error) {
//                 // Fallback to poster
//                 if (_isValidImageUrl(posterUrl)) {
//                   return CachedNetworkImage(
//                     imageUrl: posterUrl,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: double.infinity,
//                     errorWidget: (context, url, error) => Container(),
//                   );
//                 }
//                 return Container(); // Show background fallback
//               },
//               fadeInDuration: const Duration(milliseconds: 300),
//               fadeOutDuration: const Duration(milliseconds: 100),
//             )
//           // Fallback to poster if banner is invalid
//           else if (_isValidImageUrl(posterUrl))
//             CachedNetworkImage(
//               imageUrl: posterUrl,
//               fit: BoxFit.cover,
//               width: double.infinity,
//               height: double.infinity,
//               placeholder: (context, url) => Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.cardDark,
//                       ProfessionalColors.surfaceDark,
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       ProfessionalColors.accentBlue,
//                     ),
//                   ),
//                 ),
//               ),
//               errorWidget: (context, url, error) => Container(),
//               fadeInDuration: const Duration(milliseconds: 300),
//               fadeOutDuration: const Duration(milliseconds: 100),
//             ),
//         ],
//       ),
//     );
//   }

//   // ↓ REPLACE EXISTING _buildImagePlaceholder METHOD:

//   Widget _buildImagePlaceholder() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalColors.cardDark,
//             ProfessionalColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.movie_outlined,
//               size: 40,
//               color: ProfessionalColors.textSecondary,
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'MOVIE',
//               style: TextStyle(
//                 color: ProfessionalColors.textSecondary,
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(
//                 color: ProfessionalColors.accentBlue.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Text(
//                 'HD QUALITY',
//                 style: TextStyle(
//                   color: ProfessionalColors.accentBlue,
//                   fontSize: 8,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _hoverController.dispose();
//     _glowController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       focusNode: widget.focusNode,
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.select ||
//               event.logicalKey == LogicalKeyboardKey.enter) {
//             widget.onTap();
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: AnimatedBuilder(
//           animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
//           builder: (context, child) {
//             return Transform.scale(
//               scale: _scaleAnimation.value,
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     if (_isFocused) ...[
//                       BoxShadow(
//                         color: _dominantColor.withOpacity(0.4),
//                         blurRadius: 20,
//                         spreadRadius: 2,
//                         offset: const Offset(0, 8),
//                       ),
//                       BoxShadow(
//                         color: _dominantColor.withOpacity(0.2),
//                         blurRadius: 35,
//                         spreadRadius: 4,
//                         offset: const Offset(0, 12),
//                       ),
//                     ] else ...[
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 8,
//                         spreadRadius: 1,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: Stack(
//                     children: [
//                       _buildMovieImage(),
//                       if (_isFocused) _buildFocusBorder(),
//                       _buildGradientOverlay(),
//                       _buildMovieInfo(),
//                       if (_isFocused) _buildPlayButton(),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildFocusBorder() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             width: 3,
//             color: _dominantColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGradientOverlay() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               Colors.transparent,
//               Colors.black.withOpacity(0.7),
//               Colors.black.withOpacity(0.9),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMovieInfo() {
//     final movieName = widget.movie['name']?.toString() ?? 'Unknown';

//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               movieName.toUpperCase(),
//               style: TextStyle(
//                 color: _isFocused ? _dominantColor : Colors.white,
//                 fontSize: _isFocused ? 13 : 12,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5,
//                 shadows: [
//                   Shadow(
//                     color: Colors.black.withOpacity(0.8),
//                     blurRadius: 4,
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (_isFocused) ...[
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: _dominantColor.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: _dominantColor.withOpacity(0.4),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   'HD',
//                   style: TextStyle(
//                     color: _dominantColor,
//                     fontSize: 9,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlayButton() {
//     return Positioned(
//       top: 12,
//       right: 12,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: _dominantColor.withOpacity(0.9),
//           boxShadow: [
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.4),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: const Icon(
//           Icons.play_arrow_rounded,
//           color: Colors.white,
//           size: 24,
//         ),
//       ),
//     );
//   }
// }

// // Safe Type Conversion Extension (keeping your existing one)
// extension SafeTypeConversion on Map<String, dynamic> {
//   String safeString(String key, [String defaultValue = '']) {
//     try {
//       final value = this[key];
//       if (value == null) return defaultValue;
//       return value.toString();
//     } catch (e) {
//       return defaultValue;
//     }
//   }

//   int safeInt(String key, [int defaultValue = 0]) {
//     try {
//       final value = this[key];
//       if (value == null) return defaultValue;
//       if (value is int) return value;
//       if (value is String) {
//         return int.tryParse(value) ?? defaultValue;
//       }
//       if (value is double) {
//         return value.toInt();
//       }
//       return defaultValue;
//     } catch (e) {
//       return defaultValue;
//     }
//   }

//   double safeDouble(String key, [double defaultValue = 0.0]) {
//     try {
//       final value = this[key];
//       if (value == null) return defaultValue;
//       if (value is double) return value;
//       if (value is int) return value.toDouble();
//       if (value is String) {
//         return double.tryParse(value) ?? defaultValue;
//       }
//       return defaultValue;
//     } catch (e) {
//       return defaultValue;
//     }
//   }

//   bool safeBool(String key, [bool defaultValue = false]) {
//     try {
//       final value = this[key];
//       if (value == null) return defaultValue;
//       if (value is bool) return value;
//       if (value is String) {
//         return value.toLowerCase() == 'true';
//       }
//       if (value is int) {
//         return value == 1;
//       }
//       return defaultValue;
//     } catch (e) {
//       return defaultValue;
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';

// // Professional Color Palette (same as GenericLiveChannels)
// class ProfessionalColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentGreen = Color(0xFF10B981);
//   static const accentRed = Color(0xFFEF4444);
//   static const accentOrange = Color(0xFFF59E0B);
//   static const accentPink = Color(0xFFEC4899);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
//   static const focusGlow = Color(0xFF60A5FA);

//   static List<Color> gradientColors = [
//     accentBlue,
//     accentPurple,
//     accentGreen,
//     accentRed,
//     accentOrange,
//     accentPink,
//   ];
// }

// // Professional Animation Durations
// class AnimationTiming {
//   static const Duration ultraFast = Duration(milliseconds: 150);
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration focus = Duration(milliseconds: 300);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// // Movie Model
// class Movie {
//   final int id;
//   final String name;
//   final String description;
//   final String genres;
//   final String releaseDate;
//   final int? runtime;
//   final String? poster;
//   final String? banner;
//   final String sourceType;
//   final String movieUrl;
//   final List<Network> networks;

//   Movie({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.genres,
//     required this.releaseDate,
//     this.runtime,
//     this.poster,
//     this.banner,
//     required this.sourceType,
//     required this.movieUrl,
//     required this.networks,
//   });

//   factory Movie.fromJson(Map<String, dynamic> json) {
//     return Movie(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       description: json['description'] ?? '',
//       genres: json['genres']?.toString() ?? '',
//       releaseDate: json['release_date'] ?? '',
//       runtime: json['runtime'],
//       poster: json['poster'],
//       banner: json['banner'],
//       sourceType: json['source_type'] ?? '',
//       movieUrl: json['movie_url'] ?? '',
//       networks: (json['networks'] as List?)
//               ?.map((network) => Network.fromJson(network))
//               .toList() ??
//           [],
//     );
//   }
// }

// class Network {
//   final int id;
//   final String name;
//   final String logo;

//   Network({
//     required this.id,
//     required this.name,
//     required this.logo,
//   });

//   factory Network.fromJson(Map<String, dynamic> json) {
//     return Network(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       logo: json['logo'] ?? '',
//     );
//   }
// }

// // API Service
// class MovieService {
//   static Future<List<Movie>> getAllMovies() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = prefs.getString('auth_key') ?? '';

//       final response = await http.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllMovies'),
//         headers: {'auth-key': authKey},
//       );

//       if (response.statusCode == 200) {
//         final dynamic responseBody = json.decode(response.body);

//         List<dynamic> jsonData;
//         if (responseBody is List) {
//           jsonData = responseBody;
//         } else if (responseBody is Map && responseBody['data'] != null) {
//           jsonData = responseBody['data'] as List;
//         } else {
//           throw Exception('Unexpected API response format');
//         }

//         return jsonData
//             .map((json) => Movie.fromJson(json as Map<String, dynamic>))
//             .toList();
//       } else {
//         throw Exception('Failed to load movies: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error loading movies: $e');
//       throw Exception('Failed to load movies: $e');
//     }
//   }
// }

// // Professional Movies Horizontal List Widget
// class ProfessionalMoviesHorizontalList extends StatefulWidget {
//   final Function(bool)? onFocusChange;
//   final FocusNode focusNode;
//   final String displayTitle;
//   final int navigationIndex;

//   const ProfessionalMoviesHorizontalList({
//     Key? key,
//     this.onFocusChange,
//     required this.focusNode,
//     this.displayTitle = "MOVIES",
//     required this.navigationIndex,
//   }) : super(key: key);

//   @override
//   _ProfessionalMoviesHorizontalListState createState() =>
//       _ProfessionalMoviesHorizontalListState();
// }

// class _ProfessionalMoviesHorizontalListState
//     extends State<ProfessionalMoviesHorizontalList>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<Movie> displayMoviesList = [];
//   List<Movie> fullMoviesList = [];
//   int totalMoviesCount = 0;

//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isNavigating = false;
//   bool _isLoadingFullList = false;

//   // Animation Controllers
//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   // Focus management
//   Map<String, FocusNode> movieFocusNodes = {};
//   FocusNode? _viewAllFocusNode;
//   Color _currentAccentColor = ProfessionalColors.accentBlue;

//   final ScrollController _scrollController = ScrollController();
//   final int _maxItemsToShow = 7;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _initializeViewAllFocusNode();
//     _setupFocusProvider();
//     _fetchDisplayMovies();
//   }

//   void _setupFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         try {
//           // Register with focus provider similar to GenericLiveChannels
//           // You'll need to implement this based on your FocusProvider
//           print(
//               '✅ Movies focus registered for ${widget.displayTitle} (index: ${widget.navigationIndex})');
//         } catch (e) {
//           print('❌ Focus provider setup failed: $e');
//         }
//       }
//     });
//   }

//   void _initializeAnimations() {
//     _headerAnimationController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _listAnimationController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _headerSlideAnimation = Tween<Offset>(
//       begin: const Offset(0, -1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _headerAnimationController,
//       curve: Curves.easeOutCubic,
//     ));

//     _listFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _listAnimationController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   void _initializeViewAllFocusNode() {
//     _viewAllFocusNode = FocusNode()
//       ..addListener(() {
//         if (mounted && _viewAllFocusNode!.hasFocus) {
//           setState(() {
//             _currentAccentColor = ProfessionalColors.gradientColors[
//                 math.Random()
//                     .nextInt(ProfessionalColors.gradientColors.length)];
//           });
//         }
//       });
//   }

//   Future<void> _fetchDisplayMovies() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final fetchedMovies = await MovieService.getAllMovies();

//       if (fetchedMovies.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             totalMoviesCount = fetchedMovies.length;
//             displayMoviesList = fetchedMovies.take(_maxItemsToShow).toList();
//             _initializeMovieFocusNodes();
//             _isLoading = false;
//           });

//           _headerAnimationController.forward();
//           _listAnimationController.forward();
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _errorMessage = 'No movies found';
//             _isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Network error: Please check connection';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchFullMoviesList() async {
//     if (!mounted || _isLoadingFullList || fullMoviesList.isNotEmpty) return;

//     setState(() {
//       _isLoadingFullList = true;
//     });

//     try {
//       final fetchedMovies = await MovieService.getAllMovies();

//       if (mounted) {
//         setState(() {
//           fullMoviesList = fetchedMovies;
//           _isLoadingFullList = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoadingFullList = false;
//         });
//       }
//     }
//   }

//   void _initializeMovieFocusNodes() {
//     // Clear existing focus nodes
//     for (var node in movieFocusNodes.values) {
//       try {
//         node.removeListener(() {});
//         node.dispose();
//       } catch (e) {}
//     }
//     movieFocusNodes.clear();

//     // Create focus nodes for display movies
//     for (var movie in displayMoviesList) {
//       try {
//         String movieId = movie.id.toString();
//         movieFocusNodes[movieId] = FocusNode()
//           ..addListener(() {
//             if (mounted && movieFocusNodes[movieId]!.hasFocus) {
//               _scrollToFocusedItem(movieId);
//             }
//           });
//       } catch (e) {
//         // Silent error handling
//       }
//     }

//     _registerMoviesFocus();
//   }

//   void _registerMoviesFocus() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && displayMoviesList.isNotEmpty) {
//         try {
//           // Register first movie focus
//           final firstMovieId = displayMoviesList[0].id.toString();
//           if (movieFocusNodes.containsKey(firstMovieId)) {
//             // Register with your focus provider
//           }
//         } catch (e) {
//           print('❌ Focus provider registration failed: $e');
//         }
//       }
//     });
//   }

//   void _scrollToFocusedItem(String itemId) {
//     if (!mounted) return;

//     try {
//       final focusNode = movieFocusNodes[itemId];
//       if (focusNode != null &&
//           focusNode.hasFocus &&
//           focusNode.context != null) {
//         Scrollable.ensureVisible(
//           focusNode.context!,
//           alignment: 0.02,
//           duration: AnimationTiming.scroll,
//           curve: Curves.easeInOutCubic,
//         );
//       }
//     } catch (e) {}
//   }

//   Future<void> _handleMovieTap(Movie movie) async {
//     if (_isNavigating) return;
//     _isNavigating = true;

//     bool dialogShown = false;

//     if (mounted) {
//       dialogShown = true;
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return WillPopScope(
//             onWillPop: () async {
//               _isNavigating = false;
//               return true;
//             },
//             child: Center(
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 50,
//                       height: 50,
//                       child: const CircularProgressIndicator(
//                         strokeWidth: 3,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           ProfessionalColors.accentBlue,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Loading movie...',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     }

//     try {
//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//       // Navigate to video player (you'll need to implement based on your video player)
//       // Example:
//       // await Navigator.push(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder: (context) => VideoScreen(
//       //       videoUrl: movie.movieUrl,
//       //       bannerImageUrl: movie.banner,
//       //       name: movie.name,
//       //       // ... other parameters
//       //     ),
//       //   ),
//       // );

//       print('Playing movie: ${movie.name}');
//     } catch (e) {
//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Something went wrong')),
//       );
//     } finally {
//       _isNavigating = false;
//     }
//   }

//   void _navigateToMoviesGrid() async {
//     if (!_isNavigating && mounted) {
//       if (fullMoviesList.isEmpty) {
//         await _fetchFullMoviesList();
//       }

//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ProfessionalMoviesGridView(
//               moviesList: fullMoviesList.isNotEmpty
//                   ? fullMoviesList
//                   : displayMoviesList,
//               categoryTitle: widget.displayTitle,
//             ),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();

//     for (var entry in movieFocusNodes.entries) {
//       try {
//         entry.value.removeListener(() {});
//         entry.value.dispose();
//       } catch (e) {}
//     }
//     movieFocusNodes.clear();

//     try {
//       _viewAllFocusNode?.removeListener(() {});
//       _viewAllFocusNode?.dispose();
//     } catch (e) {}

//     try {
//       _scrollController.dispose();
//     } catch (e) {}

//     _isNavigating = false;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               ProfessionalColors.primaryDark,
//               ProfessionalColors.surfaceDark.withOpacity(0.5),
//             ],
//           ),
//         ),
//         child: Column(
//           children: [
//             SizedBox(height: screenHeight * 0.02),
//             _buildProfessionalTitle(screenWidth),
//             SizedBox(height: screenHeight * 0.01),
//             Expanded(child: _buildBody(screenWidth, screenHeight)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     return SlideTransition(
//       position: _headerSlideAnimation,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             ShaderMask(
//               shaderCallback: (bounds) => const LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentBlue,
//                   ProfessionalColors.accentPurple,
//                 ],
//               ).createShader(bounds),
//               child: Text(
//                 widget.displayTitle,
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//             ),
//             if (totalMoviesCount > 0)
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue.withOpacity(0.2),
//                       ProfessionalColors.accentPurple.withOpacity(0.2),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   '${totalMoviesCount} Movies Available',
//                   style: const TextStyle(
//                     color: ProfessionalColors.textSecondary,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(double screenWidth, double screenHeight) {
//     if (_isLoading) {
//       return ProfessionalLoadingIndicator(
//           message: 'Loading ${widget.displayTitle}...');
//     } else if (_errorMessage.isNotEmpty) {
//       return _buildErrorWidget();
//     } else if (displayMoviesList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildMoviesList(screenWidth, screenHeight);
//     }
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentRed.withOpacity(0.2),
//                   ProfessionalColors.accentRed.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.error_outline_rounded,
//               size: 40,
//               color: ProfessionalColors.accentRed,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Oops! Something went wrong',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _errorMessage,
//             style: const TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _fetchDisplayMovies,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: ProfessionalColors.accentBlue,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Try Again',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentBlue.withOpacity(0.2),
//                   ProfessionalColors.accentBlue.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.movie_outlined,
//               size: 40,
//               color: ProfessionalColors.accentBlue,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'No ${widget.displayTitle} Found',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Check back later for new content',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMoviesList(double screenWidth, double screenHeight) {
//     bool showViewAll = totalMoviesCount > 7;

//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: Container(
//         height: screenHeight * 0.38,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.none,
//           controller: _scrollController,
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//           cacheExtent: 1200,
//           itemCount: showViewAll ? 8 : displayMoviesList.length,
//           itemBuilder: (context, index) {
//             if (showViewAll && index == 7) {
//               return Focus(
//                 focusNode: _viewAllFocusNode,
//                 onFocusChange: (hasFocus) {
//                   if (hasFocus && mounted) {
//                     Color viewAllColor = ProfessionalColors.gradientColors[
//                         math.Random()
//                             .nextInt(ProfessionalColors.gradientColors.length)];

//                     setState(() {
//                       _currentAccentColor = viewAllColor;
//                     });
//                   }
//                 },
//                 onKey: (FocusNode node, RawKeyEvent event) {
//                   if (event is RawKeyDownEvent) {
//                     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowLeft) {
//                       if (displayMoviesList.isNotEmpty &&
//                           displayMoviesList.length > 6) {
//                         String movieId = displayMoviesList[6].id.toString();
//                         FocusScope.of(context)
//                             .requestFocus(movieFocusNodes[movieId]);
//                         return KeyEventResult.handled;
//                       }
//                     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                       // Navigate to navigation button
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowDown) {
//                       // Navigate to next section
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.select) {
//                       _navigateToMoviesGrid();
//                       return KeyEventResult.handled;
//                     }
//                   }
//                   return KeyEventResult.ignored;
//                 },
//                 child: GestureDetector(
//                   onTap: _navigateToMoviesGrid,
//                   child: ProfessionalViewAllButton(
//                     focusNode: _viewAllFocusNode!,
//                     onTap: _navigateToMoviesGrid,
//                     totalItems: totalMoviesCount,
//                     itemType: 'MOVIES',
//                   ),
//                 ),
//               );
//             }

//             var movie = displayMoviesList[index];
//             return _buildMovieItem(movie, index, screenWidth, screenHeight);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildMovieItem(
//       Movie movie, int index, double screenWidth, double screenHeight) {
//     String movieId = movie.id.toString();

//     movieFocusNodes.putIfAbsent(
//       movieId,
//       () => FocusNode()
//         ..addListener(() {
//           if (mounted && movieFocusNodes[movieId]!.hasFocus) {
//             _scrollToFocusedItem(movieId);
//           }
//         }),
//     );

//     return Focus(
//       focusNode: movieFocusNodes[movieId],
//       onFocusChange: (hasFocus) async {
//         if (hasFocus && mounted) {
//           try {
//             Color dominantColor = ProfessionalColors.gradientColors[
//                 math.Random()
//                     .nextInt(ProfessionalColors.gradientColors.length)];

//             setState(() {
//               _currentAccentColor = dominantColor;
//             });

//             widget.onFocusChange?.call(true);
//           } catch (e) {
//             print('Focus change handling failed: $e');
//           }
//         } else if (mounted) {
//           widget.onFocusChange?.call(false);
//         }
//       },
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//             if (index < displayMoviesList.length - 1 && index != 6) {
//               String nextMovieId = displayMoviesList[index + 1].id.toString();
//               FocusScope.of(context).requestFocus(movieFocusNodes[nextMovieId]);
//               return KeyEventResult.handled;
//             } else if (index == 6 && totalMoviesCount > 7) {
//               FocusScope.of(context).requestFocus(_viewAllFocusNode);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//             if (index > 0) {
//               String prevMovieId = displayMoviesList[index - 1].id.toString();
//               FocusScope.of(context).requestFocus(movieFocusNodes[prevMovieId]);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             // Navigate to navigation button
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             // Navigate to next section
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.select) {
//             _handleMovieTap(movie);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () => _handleMovieTap(movie),
//         child: ProfessionalMovieCard(
//           movie: movie,
//           focusNode: movieFocusNodes[movieId]!,
//           onTap: () => _handleMovieTap(movie),
//           onColorChange: (color) {
//             setState(() {
//               _currentAccentColor = color;
//             });
//           },
//           index: index,
//           categoryTitle: widget.displayTitle,
//         ),
//       ),
//     );
//   }
// }

// // Professional Movie Card
// class ProfessionalMovieCard extends StatefulWidget {
//   final Movie movie;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalMovieCard({
//     Key? key,
//     required this.movie,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalMovieCardState createState() => _ProfessionalMovieCardState();
// }

// class _ProfessionalMovieCardState extends State<ProfessionalMovieCard>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _glowController;
//   late AnimationController _shimmerController;

//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<double> _shimmerAnimation;

//   Color _dominantColor = ProfessionalColors.accentBlue;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();

//     _scaleController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _glowController = AnimationController(
//       duration: AnimationTiming.medium,
//       vsync: this,
//     );

//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.06,
//     ).animate(CurvedAnimation(
//       parent: _scaleController,
//       curve: Curves.easeOutCubic,
//     ));

//     _glowAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _glowController,
//       curve: Curves.easeInOut,
//     ));

//     _shimmerAnimation = Tween<double>(
//       begin: -1.0,
//       end: 2.0,
//     ).animate(CurvedAnimation(
//       parent: _shimmerController,
//       curve: Curves.easeInOut,
//     ));

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _scaleController.forward();
//       _glowController.forward();
//       _generateDominantColor();
//       widget.onColorChange(_dominantColor);
//       HapticFeedback.lightImpact();
//     } else {
//       _scaleController.reverse();
//       _glowController.reverse();
//     }
//   }

//   void _generateDominantColor() {
//     final colors = ProfessionalColors.gradientColors;
//     _dominantColor = colors[math.Random().nextInt(colors.length)];
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     _glowController.dispose();
//     _shimmerController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return AnimatedBuilder(
//       animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Container(
//             width: screenWidth * 0.19,
//             margin: const EdgeInsets.symmetric(horizontal: 6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _buildProfessionalPoster(screenWidth, screenHeight),
//                 _buildProfessionalTitle(screenWidth),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
//     final posterHeight = _isFocused ? screenHeight * 0.28 : screenHeight * 0.22;

//     return Container(
//       height: posterHeight,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           if (_isFocused) ...[
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.4),
//               blurRadius: 25,
//               spreadRadius: 3,
//               offset: const Offset(0, 8),
//             ),
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.2),
//               blurRadius: 45,
//               spreadRadius: 6,
//               offset: const Offset(0, 15),
//             ),
//           ] else ...[
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 10,
//               spreadRadius: 2,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Stack(
//           children: [
//             _buildMovieImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildGenreBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMovieImage(double screenWidth, double posterHeight) {
//     return Container(
//       width: double.infinity,
//       height: posterHeight,
//       child: widget.movie.banner != null && widget.movie.banner!.isNotEmpty
//           ? Image.network(
//               widget.movie.banner!,
//               fit: BoxFit.cover,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return _buildImagePlaceholder(posterHeight);
//               },
//               errorBuilder: (context, error, stackTrace) =>
//                   _buildImagePlaceholder(posterHeight),
//             )
//           : _buildImagePlaceholder(posterHeight),
//     );
//   }

//   Widget _buildImagePlaceholder(double height) {
//     return Container(
//       height: height,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalColors.cardDark,
//             ProfessionalColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.movie_outlined,
//             size: height * 0.25,
//             color: ProfessionalColors.textSecondary,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             widget.categoryTitle,
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             decoration: BoxDecoration(
//               color: ProfessionalColors.accentBlue.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'HD',
//               style: TextStyle(
//                 color: ProfessionalColors.accentBlue,
//                 fontSize: 8,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFocusBorder() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             width: 3,
//             color: _dominantColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmerEffect() {
//     return AnimatedBuilder(
//       animation: _shimmerAnimation,
//       builder: (context, child) {
//         return Positioned.fill(
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               gradient: LinearGradient(
//                 begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
//                 end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
//                 colors: [
//                   Colors.transparent,
//                   _dominantColor.withOpacity(0.15),
//                   Colors.transparent,
//                 ],
//                 stops: [0.0, 0.5, 1.0],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildGenreBadge() {
//     String genre = 'HD';
//     Color badgeColor = ProfessionalColors.accentBlue;

//     if (widget.movie.genres.toLowerCase().contains('comedy')) {
//       genre = 'COMEDY';
//       badgeColor = ProfessionalColors.accentGreen;
//     } else if (widget.movie.genres.toLowerCase().contains('action')) {
//       genre = 'ACTION';
//       badgeColor = ProfessionalColors.accentRed;
//     } else if (widget.movie.genres.toLowerCase().contains('romantic')) {
//       genre = 'ROMANCE';
//       badgeColor = ProfessionalColors.accentPink;
//     } else if (widget.movie.genres.toLowerCase().contains('drama')) {
//       genre = 'DRAMA';
//       badgeColor = ProfessionalColors.accentPurple;
//     }

//     return Positioned(
//       top: 8,
//       right: 8,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//         decoration: BoxDecoration(
//           color: badgeColor.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Text(
//           genre,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 8,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHoverOverlay() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               _dominantColor.withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: const Icon(
//               Icons.play_arrow_rounded,
//               color: Colors.white,
//               size: 30,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     final movieName = widget.movie.name.toUpperCase();

//     return Container(
//       width: screenWidth * 0.18,
//       child: AnimatedDefaultTextStyle(
//         duration: AnimationTiming.medium,
//         style: TextStyle(
//           fontSize: _isFocused ? 13 : 11,
//           fontWeight: FontWeight.w600,
//           color: _isFocused ? _dominantColor : ProfessionalColors.textPrimary,
//           letterSpacing: 0.5,
//           shadows: _isFocused
//               ? [
//                   Shadow(
//                     color: _dominantColor.withOpacity(0.6),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Text(
//           movieName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // Professional View All Button
// class ProfessionalViewAllButton extends StatefulWidget {
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int totalItems;
//   final String itemType;

//   const ProfessionalViewAllButton({
//     Key? key,
//     required this.focusNode,
//     required this.onTap,
//     required this.totalItems,
//     this.itemType = 'ITEMS',
//   }) : super(key: key);

//   @override
//   _ProfessionalViewAllButtonState createState() =>
//       _ProfessionalViewAllButtonState();
// }

// class _ProfessionalViewAllButtonState extends State<ProfessionalViewAllButton>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _rotateController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _rotateAnimation;

//   bool _isFocused = false;
//   Color _currentColor = ProfessionalColors.accentBlue;

//   @override
//   void initState() {
//     super.initState();

//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     )..repeat(reverse: true);

//     _rotateController = AnimationController(
//       duration: const Duration(milliseconds: 3000),
//       vsync: this,
//     )..repeat();

//     _pulseAnimation = Tween<double>(
//       begin: 0.85,
//       end: 1.15,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));

//     _rotateAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_rotateController);

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//       if (_isFocused) {
//         _currentColor = ProfessionalColors.gradientColors[
//             math.Random().nextInt(ProfessionalColors.gradientColors.length)];
//         HapticFeedback.mediumImpact();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _rotateController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Container(
//       width: screenWidth * 0.19,
//       margin: const EdgeInsets.symmetric(horizontal: 6),
//       child: Column(
//         children: [
//           AnimatedBuilder(
//             animation: _isFocused ? _pulseAnimation : _rotateAnimation,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: _isFocused ? _pulseAnimation.value : 1.0,
//                 child: Transform.rotate(
//                   angle: _isFocused ? 0 : _rotateAnimation.value * 2 * math.pi,
//                   child: Container(
//                     height:
//                         _isFocused ? screenHeight * 0.28 : screenHeight * 0.22,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: _isFocused
//                             ? [
//                                 _currentColor,
//                                 _currentColor.withOpacity(0.7),
//                               ]
//                             : [
//                                 ProfessionalColors.cardDark,
//                                 ProfessionalColors.surfaceDark,
//                               ],
//                       ),
//                       boxShadow: [
//                         if (_isFocused) ...[
//                           BoxShadow(
//                             color: _currentColor.withOpacity(0.4),
//                             blurRadius: 25,
//                             spreadRadius: 3,
//                             offset: const Offset(0, 8),
//                           ),
//                         ] else ...[
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.4),
//                             blurRadius: 10,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ],
//                     ),
//                     child: _buildViewAllContent(),
//                   ),
//                 ),
//               );
//             },
//           ),
//           _buildViewAllTitle(),
//         ],
//       ),
//     );
//   }

//   Widget _buildViewAllContent() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         border: _isFocused
//             ? Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 2,
//               )
//             : null,
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.1),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.grid_view_rounded,
//                   size: _isFocused ? 45 : 35,
//                   color: Colors.white,
//                 ),
//                 Text(
//                   'VIEW ALL',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: _isFocused ? 14 : 12,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.25),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '${widget.totalItems}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildViewAllTitle() {
//     return AnimatedDefaultTextStyle(
//       duration: AnimationTiming.medium,
//       style: TextStyle(
//         fontSize: _isFocused ? 13 : 11,
//         fontWeight: FontWeight.w600,
//         color: _isFocused ? _currentColor : ProfessionalColors.textPrimary,
//         letterSpacing: 0.5,
//         shadows: _isFocused
//             ? [
//                 Shadow(
//                   color: _currentColor.withOpacity(0.6),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ]
//             : [],
//       ),
//       child: Text(
//         'ALL ${widget.itemType}',
//         textAlign: TextAlign.center,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }
// }

// // Professional Loading Indicator
// class ProfessionalLoadingIndicator extends StatefulWidget {
//   final String message;

//   const ProfessionalLoadingIndicator({
//     Key? key,
//     this.message = 'Loading...',
//   }) : super(key: key);

//   @override
//   _ProfessionalLoadingIndicatorState createState() =>
//       _ProfessionalLoadingIndicatorState();
// }

// class _ProfessionalLoadingIndicatorState
//     extends State<ProfessionalLoadingIndicator> with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _animation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_controller);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _animation,
//             builder: (context, child) {
//               return Container(
//                 width: 70,
//                 height: 70,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: SweepGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple,
//                       ProfessionalColors.accentGreen,
//                       ProfessionalColors.accentBlue,
//                     ],
//                     stops: [0.0, 0.3, 0.7, 1.0],
//                     transform: GradientRotation(_animation.value * 2 * math.pi),
//                   ),
//                 ),
//                 child: Container(
//                   margin: const EdgeInsets.all(5),
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: ProfessionalColors.primaryDark,
//                   ),
//                   child: const Icon(
//                     Icons.movie_rounded,
//                     color: ProfessionalColors.textPrimary,
//                     size: 28,
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 24),
//           Text(
//             widget.message,
//             style: const TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             width: 200,
//             height: 3,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(2),
//               color: ProfessionalColors.surfaceDark,
//             ),
//             child: AnimatedBuilder(
//               animation: _animation,
//               builder: (context, child) {
//                 return LinearProgressIndicator(
//                   value: _animation.value,
//                   backgroundColor: Colors.transparent,
//                   valueColor: const AlwaysStoppedAnimation<Color>(
//                     ProfessionalColors.accentBlue,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Professional Movies Grid View
// class ProfessionalMoviesGridView extends StatefulWidget {
//   final List<Movie> moviesList;
//   final String categoryTitle;

//   const ProfessionalMoviesGridView({
//     Key? key,
//     required this.moviesList,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalMoviesGridViewState createState() =>
//       _ProfessionalMoviesGridViewState();
// }

// class _ProfessionalMoviesGridViewState extends State<ProfessionalMoviesGridView>
//     with TickerProviderStateMixin {
//   late Map<String, FocusNode> _movieFocusNodes;
//   bool _isLoading = false;

//   // Animation Controllers
//   late AnimationController _fadeController;
//   late AnimationController _staggerController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _movieFocusNodes = {
//       for (var movie in widget.moviesList) movie.id.toString(): FocusNode()
//     };

//     // Set up focus for the first movie
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (widget.moviesList.isNotEmpty) {
//         final firstMovieId = widget.moviesList[0].id.toString();
//         if (_movieFocusNodes.containsKey(firstMovieId)) {
//           FocusScope.of(context).requestFocus(_movieFocusNodes[firstMovieId]);
//         }
//       }
//     });

//     _initializeAnimations();
//     _startStaggeredAnimation();
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _staggerController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   void _startStaggeredAnimation() {
//     _fadeController.forward();
//     _staggerController.forward();
//   }

//   Future<void> _handleGridMovieTap(Movie movie) async {
//     if (_isLoading || !mounted) return;

//     setState(() {
//       _isLoading = true;
//     });

//     bool dialogShown = false;
//     try {
//       if (mounted) {
//         dialogShown = true;
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return WillPopScope(
//               onWillPop: () async {
//                 setState(() {
//                   _isLoading = false;
//                 });
//                 return true;
//               },
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.85),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 60,
//                         height: 60,
//                         child: const CircularProgressIndicator(
//                           strokeWidth: 4,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             ProfessionalColors.accentBlue,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'Loading Movie...',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Please wait',
//                         style: TextStyle(
//                           color: ProfessionalColors.textSecondary,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       }

//       if (mounted) {
//         if (dialogShown) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }

//         // Navigate to video player
//         print('Playing movie: ${movie.name}');
//         // Add your video player navigation here
//       }
//     } catch (e) {
//       if (mounted) {
//         if (dialogShown) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Error loading movie'),
//             backgroundColor: ProfessionalColors.accentRed,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _staggerController.dispose();
//     for (var node in _movieFocusNodes.values) {
//       try {
//         node.dispose();
//       } catch (e) {}
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Stack(
//         children: [
//           // Background Gradient
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   ProfessionalColors.primaryDark,
//                   ProfessionalColors.surfaceDark.withOpacity(0.8),
//                   ProfessionalColors.primaryDark,
//                 ],
//               ),
//             ),
//           ),

//           // Main Content
//           FadeTransition(
//             opacity: _fadeAnimation,
//             child: Column(
//               children: [
//                 _buildProfessionalAppBar(),
//                 Expanded(
//                   child: _buildMoviesGrid(),
//                 ),
//               ],
//             ),
//           ),

//           // Loading Overlay
//           if (_isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.7),
//               child: const Center(
//                 child:
//                     ProfessionalLoadingIndicator(message: 'Loading Movie...'),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfessionalAppBar() {
//     return Container(
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 10,
//         left: 20,
//         right: 20,
//         bottom: 20,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             ProfessionalColors.surfaceDark.withOpacity(0.9),
//             ProfessionalColors.surfaceDark.withOpacity(0.7),
//             Colors.transparent,
//           ],
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentBlue.withOpacity(0.2),
//                   ProfessionalColors.accentPurple.withOpacity(0.2),
//                 ],
//               ),
//             ),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.arrow_back_rounded,
//                 color: Colors.white,
//                 size: 24,
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ShaderMask(
//                   shaderCallback: (bounds) => const LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple,
//                     ],
//                   ).createShader(bounds),
//                   child: Text(
//                     widget.categoryTitle,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         ProfessionalColors.accentBlue.withOpacity(0.2),
//                         ProfessionalColors.accentPurple.withOpacity(0.1),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(
//                       color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Text(
//                     '${widget.moviesList.length} Movies Available',
//                     style: const TextStyle(
//                       color: ProfessionalColors.accentBlue,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMoviesGrid() {
//     if (widget.moviesList.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   colors: [
//                     ProfessionalColors.accentBlue.withOpacity(0.2),
//                     ProfessionalColors.accentBlue.withOpacity(0.1),
//                   ],
//                 ),
//               ),
//               child: const Icon(
//                 Icons.movie_outlined,
//                 size: 40,
//                 color: ProfessionalColors.accentBlue,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No ${widget.categoryTitle} Found',
//               style: TextStyle(
//                 color: ProfessionalColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Check back later for new content',
//               style: TextStyle(
//                 color: ProfessionalColors.textSecondary,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 5,
//           mainAxisSpacing: 16,
//           crossAxisSpacing: 16,
//           childAspectRatio: 1.6,
//         ),
//         itemCount: widget.moviesList.length,
//         clipBehavior: Clip.none,
//         itemBuilder: (context, index) {
//           final movie = widget.moviesList[index];
//           String movieId = movie.id.toString();

//           return AnimatedBuilder(
//             animation: _staggerController,
//             builder: (context, child) {
//               final delay = (index / widget.moviesList.length) * 0.5;
//               final animationValue = Interval(
//                 delay,
//                 delay + 0.5,
//                 curve: Curves.easeOutCubic,
//               ).transform(_staggerController.value);

//               return Transform.translate(
//                 offset: Offset(0, 50 * (1 - animationValue)),
//                 child: Opacity(
//                   opacity: animationValue,
//                   child: ProfessionalGridMovieCard(
//                     movie: movie,
//                     focusNode: _movieFocusNodes[movieId]!,
//                     onTap: () => _handleGridMovieTap(movie),
//                     index: index,
//                     categoryTitle: widget.categoryTitle,
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// // Professional Grid Movie Card
// class ProfessionalGridMovieCard extends StatefulWidget {
//   final Movie movie;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalGridMovieCard({
//     Key? key,
//     required this.movie,
//     required this.focusNode,
//     required this.onTap,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalGridMovieCardState createState() =>
//       _ProfessionalGridMovieCardState();
// }

// class _ProfessionalGridMovieCardState extends State<ProfessionalGridMovieCard>
//     with TickerProviderStateMixin {
//   late AnimationController _hoverController;
//   late AnimationController _glowController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;

//   Color _dominantColor = ProfessionalColors.accentBlue;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();

//     _hoverController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _glowController = AnimationController(
//       duration: AnimationTiming.medium,
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.05,
//     ).animate(CurvedAnimation(
//       parent: _hoverController,
//       curve: Curves.easeOutCubic,
//     ));

//     _glowAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _glowController,
//       curve: Curves.easeInOut,
//     ));

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _hoverController.forward();
//       _glowController.forward();
//       _generateDominantColor();
//       HapticFeedback.lightImpact();
//     } else {
//       _hoverController.reverse();
//       _glowController.reverse();
//     }
//   }

//   void _generateDominantColor() {
//     final colors = ProfessionalColors.gradientColors;
//     _dominantColor = colors[math.Random().nextInt(colors.length)];
//   }

//   @override
//   void dispose() {
//     _hoverController.dispose();
//     _glowController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       focusNode: widget.focusNode,
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.select ||
//               event.logicalKey == LogicalKeyboardKey.enter) {
//             widget.onTap();
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: AnimatedBuilder(
//           animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
//           builder: (context, child) {
//             return Transform.scale(
//               scale: _scaleAnimation.value,
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     if (_isFocused) ...[
//                       BoxShadow(
//                         color: _dominantColor.withOpacity(0.4),
//                         blurRadius: 20,
//                         spreadRadius: 2,
//                         offset: const Offset(0, 8),
//                       ),
//                       BoxShadow(
//                         color: _dominantColor.withOpacity(0.2),
//                         blurRadius: 35,
//                         spreadRadius: 4,
//                         offset: const Offset(0, 12),
//                       ),
//                     ] else ...[
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 8,
//                         spreadRadius: 1,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: Stack(
//                     children: [
//                       _buildMovieImage(),
//                       if (_isFocused) _buildFocusBorder(),
//                       _buildGradientOverlay(),
//                       _buildMovieInfo(),
//                       if (_isFocused) _buildPlayButton(),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildMovieImage() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       child: widget.movie.banner != null && widget.movie.banner!.isNotEmpty
//           ? Image.network(
//               widget.movie.banner!,
//               fit: BoxFit.cover,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return _buildImagePlaceholder();
//               },
//               errorBuilder: (context, error, stackTrace) =>
//                   _buildImagePlaceholder(),
//             )
//           : _buildImagePlaceholder(),
//     );
//   }

//   Widget _buildImagePlaceholder() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalColors.cardDark,
//             ProfessionalColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.movie_outlined,
//               size: 40,
//               color: ProfessionalColors.textSecondary,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               widget.categoryTitle,
//               style: TextStyle(
//                 color: ProfessionalColors.textSecondary,
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(
//                 color: ProfessionalColors.accentBlue.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Text(
//                 'HD',
//                 style: TextStyle(
//                   color: ProfessionalColors.accentBlue,
//                   fontSize: 8,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFocusBorder() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             width: 3,
//             color: _dominantColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGradientOverlay() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               Colors.transparent,
//               Colors.black.withOpacity(0.7),
//               Colors.black.withOpacity(0.9),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMovieInfo() {
//     final movieName = widget.movie.name;

//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               movieName.toUpperCase(),
//               style: TextStyle(
//                 color: _isFocused ? _dominantColor : Colors.white,
//                 fontSize: _isFocused ? 13 : 12,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5,
//                 shadows: [
//                   Shadow(
//                     color: Colors.black.withOpacity(0.8),
//                     blurRadius: 4,
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (_isFocused) ...[
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   if (widget.movie.runtime != null)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: ProfessionalColors.accentGreen.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color:
//                               ProfessionalColors.accentGreen.withOpacity(0.5),
//                           width: 1,
//                         ),
//                       ),
//                       child: Text(
//                         '${widget.movie.runtime}m',
//                         style: const TextStyle(
//                           color: ProfessionalColors.accentGreen,
//                           fontSize: 8,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: _dominantColor.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: _dominantColor.withOpacity(0.4),
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       'HD',
//                       style: TextStyle(
//                         color: _dominantColor,
//                         fontSize: 8,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlayButton() {
//     return Positioned(
//       top: 12,
//       right: 12,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: _dominantColor.withOpacity(0.9),
//           boxShadow: [
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.4),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: const Icon(
//           Icons.play_arrow_rounded,
//           color: Colors.white,
//           size: 24,
//         ),
//       ),
//     );
//   }
// }

// // Main Movies Screen
// class MoviesScreen extends StatefulWidget {
//   @override
//   _MoviesScreenState createState() => _MoviesScreenState();
// }

// class _MoviesScreenState extends State<MoviesScreen> {
//   final FocusNode _moviesFocusNode = FocusNode();

//   @override
//   void dispose() {
//     _moviesFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: SafeArea(
//         child: ProfessionalMoviesHorizontalList(
//           focusNode: _moviesFocusNode,
//           displayTitle: "FEATURED MOVIES",
//           navigationIndex: 3, // Adjust based on your navigation structure
//           onFocusChange: (bool hasFocus) {
//             // Handle focus change if needed
//             print('Movies section focus: $hasFocus');
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_video_player.dart';
import 'package:mobi_tv_entertainment/video_widget/device_detector_firestick.dart';
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player_4k.dart';
import 'package:mobi_tv_entertainment/video_widget/youtube_frame.dart';
import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

bool isYoutubeUrl(String? url) {
  if (url == null || url.isEmpty) {
    return false;
  }

  url = url.toLowerCase().trim();

  // First check if it's a YouTube ID (exactly 11 characters)
  bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
  if (isYoutubeId) {
    return true;
  }

  // Then check for regular YouTube URLs
  bool isYoutubeUrl = url.contains('youtube.com') ||
      url.contains('youtu.be') ||
      url.contains('youtube.com/shorts/');
  if (isYoutubeUrl) {
    return true;
  }

  return false;
}

// Professional Color Palette (same as GenericLiveChannels)
class ProfessionalColors {
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
  static const focusGlow = Color(0xFF60A5FA);

  static List<Color> gradientColors = [
    accentBlue,
    accentPurple,
    accentGreen,
    accentRed,
    accentOrange,
    accentPink,
  ];
}

// Professional Animation Durations
class AnimationTiming {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration focus = Duration(milliseconds: 300);
  static const Duration scroll = Duration(milliseconds: 800);
}

// Movie Model
class Movie {
  final int id;
  final String name;
  final String description;
  final String genres;
  final String releaseDate;
  final int? runtime;
  final String? poster;
  final String? banner;
  final String sourceType;
  final String movieUrl;
  final List<Network> networks;

  Movie({
    required this.id,
    required this.name,
    required this.description,
    required this.genres,
    required this.releaseDate,
    this.runtime,
    this.poster,
    this.banner,
    required this.sourceType,
    required this.movieUrl,
    required this.networks,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      genres: json['genres']?.toString() ?? '',
      releaseDate: json['release_date'] ?? '',
      runtime: json['runtime'],
      poster: json['poster'],
      banner: json['banner'],
      sourceType: json['source_type'] ?? '',
      movieUrl: json['movie_url'] ?? '',
      networks: (json['networks'] as List?)
              ?.map((network) => Network.fromJson(network))
              .toList() ??
          [],
    );
  }
}

class Network {
  final int id;
  final String name;
  final String logo;

  Network({
    required this.id,
    required this.name,
    required this.logo,
  });

  factory Network.fromJson(Map<String, dynamic> json) {
    return Network(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}

// API Service
class MovieService {
  static Future<List<Movie>> getAllMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String authKey = prefs.getString('auth_key') ?? '';

      final response = await http.get(
        Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllMovies'),
        headers: {'auth-key': authKey},
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        List<dynamic> jsonData;
        if (responseBody is List) {
          jsonData = responseBody;
        } else if (responseBody is Map && responseBody['data'] != null) {
          jsonData = responseBody['data'] as List;
        } else {
          throw Exception('Unexpected API response format');
        }

        return jsonData
            .map((json) => Movie.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading movies: $e');
      throw Exception('Failed to load movies: $e');
    }
  }
}

// Professional Movies Horizontal List Widget
class ProfessionalMoviesHorizontalList extends StatefulWidget {
  final Function(bool)? onFocusChange;
  final FocusNode focusNode;
  final String displayTitle;
  final int navigationIndex;

  const ProfessionalMoviesHorizontalList({
    Key? key,
    this.onFocusChange,
    required this.focusNode,
    this.displayTitle = "MOVIES",
    required this.navigationIndex,
  }) : super(key: key);

  @override
  _ProfessionalMoviesHorizontalListState createState() =>
      _ProfessionalMoviesHorizontalListState();
}

class _ProfessionalMoviesHorizontalListState
    extends State<ProfessionalMoviesHorizontalList>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  List<Movie> displayMoviesList = [];
  List<Movie> fullMoviesList = [];
  int totalMoviesCount = 0;

  bool _isLoading = true;
  String _errorMessage = '';
  bool _isNavigating = false;
  bool _isLoadingFullList = false;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  // Focus management
  Map<String, FocusNode> movieFocusNodes = {};
  FocusNode? _viewAllFocusNode;
  Color _currentAccentColor = ProfessionalColors.accentBlue;

  final ScrollController _scrollController = ScrollController();
  final int _maxItemsToShow = 7;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeViewAllFocusNode();
    _setupFocusProvider();
    _fetchDisplayMovies();
  }

  void _setupFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);

          // ✅ Special handling for Live page (index 0)
          if (widget.navigationIndex == 0) {
            focusProvider.setLiveChannelsFocusNode(widget.focusNode);
            print('✅ Live focus node specially registered');
          }

          // ✅ MOVIES: Register with navigation index for all pages
          focusProvider.registerGenericChannelFocus(
              widget.navigationIndex, _scrollController, widget.focusNode);

          // ✅ MOVIES: Register first movie focus node for SubVod navigation
          if (displayMoviesList.isNotEmpty) {
            final firstMovieId = displayMoviesList[0].id.toString();
            if (movieFocusNodes.containsKey(firstMovieId)) {
              focusProvider.setFirstManageMoviesFocusNode(
                  movieFocusNodes[firstMovieId]!);
              print(
                  '✅ Movies first focus node registered for SubVod navigation');
            }
          }

          print(
              '✅ Generic focus registered for ${widget.displayTitle} (index: ${widget.navigationIndex})');
        } catch (e) {
          print('❌ Focus provider setup failed: $e');
        }
      }
    });
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _listFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeViewAllFocusNode() {
    _viewAllFocusNode = FocusNode()
      ..addListener(() {
        if (mounted && _viewAllFocusNode!.hasFocus) {
          setState(() {
            _currentAccentColor = ProfessionalColors.gradientColors[
                math.Random()
                    .nextInt(ProfessionalColors.gradientColors.length)];
          });
        }
      });
  }

  Future<void> _fetchDisplayMovies() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final fetchedMovies = await MovieService.getAllMovies();

      if (fetchedMovies.isNotEmpty) {
        if (mounted) {
          setState(() {
            totalMoviesCount = fetchedMovies.length;
            displayMoviesList = fetchedMovies.take(_maxItemsToShow).toList();
            _initializeMovieFocusNodes();
            _isLoading = false;
          });

          _headerAnimationController.forward();
          _listAnimationController.forward();
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'No movies found';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error: Please check connection';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchFullMoviesList() async {
    if (!mounted || _isLoadingFullList || fullMoviesList.isNotEmpty) return;

    setState(() {
      _isLoadingFullList = true;
    });

    try {
      final fetchedMovies = await MovieService.getAllMovies();

      if (mounted) {
        setState(() {
          fullMoviesList = fetchedMovies;
          _isLoadingFullList = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFullList = false;
        });
      }
    }
  }

  void _initializeMovieFocusNodes() {
    // Clear existing focus nodes
    for (var node in movieFocusNodes.values) {
      try {
        node.removeListener(() {});
        node.dispose();
      } catch (e) {}
    }
    movieFocusNodes.clear();

    // Create focus nodes for display movies
    for (var movie in displayMoviesList) {
      try {
        String movieId = movie.id.toString();
        movieFocusNodes[movieId] = FocusNode()
          ..addListener(() {
            if (mounted && movieFocusNodes[movieId]!.hasFocus) {
              _scrollToFocusedItem(movieId);
            }
          });
      } catch (e) {
        // Silent error handling
      }
    }

    _registerMoviesFocus();
  }

  void _registerMoviesFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && displayMoviesList.isNotEmpty) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);

          // Register first movie with focus provider
          final firstMovieId = displayMoviesList[0].id.toString();
          if (movieFocusNodes.containsKey(firstMovieId)) {
            // ✅ MOVIES: Register first movie focus node for SubVod arrow down navigation
            focusProvider
                .setFirstManageMoviesFocusNode(movieFocusNodes[firstMovieId]!);
            print(
                '✅ Movies first banner focus registered for SubVod navigation');

            focusProvider.registerGenericChannelFocus(widget.navigationIndex,
                _scrollController, movieFocusNodes[firstMovieId]!);
          }

          // Register ViewAll focus node
          if (_viewAllFocusNode != null) {
            focusProvider.registerViewAllFocusNode(
                widget.navigationIndex, _viewAllFocusNode!);
          }
        } catch (e) {
          print('❌ Focus provider registration failed: $e');
        }
      }
    });
  }

  void _scrollToFocusedItem(String itemId) {
    if (!mounted) return;

    try {
      final focusNode = movieFocusNodes[itemId];
      if (focusNode != null &&
          focusNode.hasFocus &&
          focusNode.context != null) {
        Scrollable.ensureVisible(
          focusNode.context!,
          alignment: 0.02,
          duration: AnimationTiming.scroll,
          curve: Curves.easeInOutCubic,
        );
      }
    } catch (e) {}
  }

  Future<void> _handleMovieTap(Movie movie) async {
    if (_isNavigating) return;
    _isNavigating = true;

    bool dialogShown = false;

    if (mounted) {
      dialogShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              _isNavigating = false;
              return true;
            },
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ProfessionalColors.accentBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Loading movie...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    try {
      if (dialogShown) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Add this helper method in ProfessionalMoviesHorizontalList
      List<NewsItemModel> _convertMoviesToNewsItems(List<Movie> movies) {
        return movies
            .map((movie) => NewsItemModel(
                  id: movie.id.toString(),
                  name: movie.name,
                  banner: movie.banner ?? movie.poster ?? '',
                  url: movie.movieUrl,
                  unUpdatedUrl: movie.movieUrl,
                  contentType: '1', // Movie type
                  streamType: movie.sourceType,
                  liveStatus: false,
                  poster: movie.poster ?? movie.banner ?? '',
                  image: movie.banner ?? movie.poster ?? '',
                  // Other required fields...
                ))
            .toList();
      }

// // In _handleMovieTap method
// await Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => VideoScreen(
//       videoUrl: movie.movieUrl,
//       bannerImageUrl: movie.banner ?? movie.poster ?? '',
//       startAtPosition: Duration.zero,
//       videoType: movie.sourceType,
//       channelList: _convertMoviesToNewsItems(displayMoviesList), // ✅ Convert and send
//       isLive: false,
//       isVOD: true,
//       isBannerSlider: false,
//       source: 'isMovieScreen',
//       isSearch: false,
//       videoId: movie.id,
//       unUpdatedUrl: movie.movieUrl,
//       name: movie.name,
//       seasonId: null,
//       isLastPlayedStored: true,
//       liveStatus: false,
//     ),
//   ),
// );
      if (isYoutubeUrl(movie.movieUrl)) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomYoutubePlayer(
              videoUrl: movie.movieUrl,
            ),
          ),
        );

        // // ✅ VIDEO PLAYING - Navigate to VideoScreen with proper parameters
        // await Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => VideoScreen(
        //       videoUrl: movie.movieUrl,
        //       bannerImageUrl: movie.banner ?? movie.poster ?? '',
        //       startAtPosition: Duration.zero,
        //       videoType: movie.sourceType,
        //       channelList: [], // Empty for movies
        //       isLive: false,
        //       isVOD: true,
        //       isBannerSlider: false,
        //       source: 'moviesScreen',
        //       isSearch: false,
        //       videoId: movie.id,
        //       unUpdatedUrl: movie.movieUrl,
        //       name: movie.name,
        //       seasonId: null,
        //       isLastPlayedStored: true,
        //       liveStatus: false,
        //       // // Additional movie-specific parameters
        //       // description: movie.description,
        //       // genres: movie.genres,
        //       // releaseDate: movie.releaseDate,
        //       // runtime: movie.runtime,
        //     ),
        //   ),
        // );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomVideoPlayer(
              videoUrl: movie.movieUrl,
            ),
          ),
        );
      }
      print('✅ Movie played successfully: ${movie.name}');
    } catch (e) {
      if (dialogShown) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // ✅ Better error handling with specific error messages
      String errorMessage = 'Something went wrong';
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('format') ||
          e.toString().contains('codec')) {
        errorMessage = 'Video format not supported';
      } else if (e.toString().contains('not found') ||
          e.toString().contains('404')) {
        errorMessage = 'Movie not found or unavailable';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: ProfessionalColors.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _handleMovieTap(movie),
          ),
        ),
      );
    } finally {
      _isNavigating = false;
    }
  }

  void _navigateToMoviesGrid() async {
    if (!_isNavigating && mounted) {
      if (fullMoviesList.isEmpty) {
        await _fetchFullMoviesList();
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfessionalMoviesGridView(
              moviesList: fullMoviesList.isNotEmpty
                  ? fullMoviesList
                  : displayMoviesList,
              categoryTitle: widget.displayTitle,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();

    for (var entry in movieFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
      } catch (e) {}
    }
    movieFocusNodes.clear();

    try {
      _viewAllFocusNode?.removeListener(() {});
      _viewAllFocusNode?.dispose();
    } catch (e) {}

    try {
      _scrollController.dispose();
    } catch (e) {}

    _isNavigating = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ProfessionalColors.primaryDark,
              ProfessionalColors.surfaceDark.withOpacity(0.5),
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            _buildProfessionalTitle(screenWidth),
            SizedBox(height: screenHeight * 0.01),
            Expanded(child: _buildBody(screenWidth, screenHeight)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalTitle(double screenWidth) {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  ProfessionalColors.accentBlue,
                  ProfessionalColors.accentPurple,
                ],
              ).createShader(bounds),
              child: Text(
                widget.displayTitle,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            if (totalMoviesCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ProfessionalColors.accentBlue.withOpacity(0.2),
                      ProfessionalColors.accentPurple.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ProfessionalColors.accentBlue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${totalMoviesCount} Movies Available',
                  style: const TextStyle(
                    color: ProfessionalColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(double screenWidth, double screenHeight) {
    if (_isLoading) {
      return ProfessionalLoadingIndicator(
          message: 'Loading ${widget.displayTitle}...');
    } else if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    } else if (displayMoviesList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildMoviesList(screenWidth, screenHeight);
    }
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
                  ProfessionalColors.accentRed.withOpacity(0.2),
                  ProfessionalColors.accentRed.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: ProfessionalColors.accentRed,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: const TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchDisplayMovies,
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfessionalColors.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
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
                  ProfessionalColors.accentBlue.withOpacity(0.2),
                  ProfessionalColors.accentBlue.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.movie_outlined,
              size: 40,
              color: ProfessionalColors.accentBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No ${widget.displayTitle} Found',
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new content',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviesList(double screenWidth, double screenHeight) {
    bool showViewAll = totalMoviesCount > 7;

    return FadeTransition(
      opacity: _listFadeAnimation,
      child: Container(
        height: screenHeight * 0.38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
          cacheExtent: 1200,
          itemCount: showViewAll ? 8 : displayMoviesList.length,
          itemBuilder: (context, index) {
            if (showViewAll && index == 7) {
              return Focus(
                focusNode: _viewAllFocusNode,
                onFocusChange: (hasFocus) {
                  if (hasFocus && mounted) {
                    Color viewAllColor = ProfessionalColors.gradientColors[
                        math.Random()
                            .nextInt(ProfessionalColors.gradientColors.length)];

                    setState(() {
                      _currentAccentColor = viewAllColor;
                    });
                  }
                },
                onKey: (FocusNode node, RawKeyEvent event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                      return KeyEventResult.handled;
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowLeft) {
                      if (displayMoviesList.isNotEmpty &&
                          displayMoviesList.length > 6) {
                        String movieId = displayMoviesList[6].id.toString();
                        FocusScope.of(context)
                            .requestFocus(movieFocusNodes[movieId]);
                        return KeyEventResult.handled;
                      }
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      FocusScope.of(context).unfocus();
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (mounted) {
                          context.read<FocusProvider>().requestSubVodFocus();
                        }
                      });
                      // Navigate to navigation button
                      return KeyEventResult.handled;
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowDown) {
                      FocusScope.of(context).unfocus();
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (mounted) {
                          Provider.of<FocusProvider>(context, listen: false)
                              .requestFirstWebseriesFocus();
                        }
                      });
                      // Navigate to next section
                      return KeyEventResult.handled;
                    } else if (event.logicalKey == LogicalKeyboardKey.select) {
                      _navigateToMoviesGrid();
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: GestureDetector(
                  onTap: _navigateToMoviesGrid,
                  child: ProfessionalViewAllButton(
                    focusNode: _viewAllFocusNode!,
                    onTap: _navigateToMoviesGrid,
                    totalItems: totalMoviesCount,
                    itemType: 'MOVIES',
                  ),
                ),
              );
            }

            var movie = displayMoviesList[index];
            return _buildMovieItem(movie, index, screenWidth, screenHeight);
          },
        ),
      ),
    );
  }

  Widget _buildMovieItem(
      Movie movie, int index, double screenWidth, double screenHeight) {
    String movieId = movie.id.toString();

    movieFocusNodes.putIfAbsent(
      movieId,
      () => FocusNode()
        ..addListener(() {
          if (mounted && movieFocusNodes[movieId]!.hasFocus) {
            _scrollToFocusedItem(movieId);
          }
        }),
    );

    return Focus(
      focusNode: movieFocusNodes[movieId],
      onFocusChange: (hasFocus) async {
        if (hasFocus && mounted) {
          try {
            Color dominantColor = ProfessionalColors.gradientColors[
                math.Random()
                    .nextInt(ProfessionalColors.gradientColors.length)];

            setState(() {
              _currentAccentColor = dominantColor;
            });

            widget.onFocusChange?.call(true);
          } catch (e) {
            print('Focus change handling failed: $e');
          }
        } else if (mounted) {
          widget.onFocusChange?.call(false);
        }
      },
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (index < displayMoviesList.length - 1 && index != 6) {
              String nextMovieId = displayMoviesList[index + 1].id.toString();
              FocusScope.of(context).requestFocus(movieFocusNodes[nextMovieId]);
              return KeyEventResult.handled;
            } else if (index == 6 && totalMoviesCount > 7) {
              FocusScope.of(context).requestFocus(_viewAllFocusNode);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              String prevMovieId = displayMoviesList[index - 1].id.toString();
              FocusScope.of(context).requestFocus(movieFocusNodes[prevMovieId]);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                context.read<FocusProvider>().requestSubVodFocus();
              }
            });
            // Navigate to navigation button
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                Provider.of<FocusProvider>(context, listen: false)
                    .requestFirstWebseriesFocus();
              }
            });
            // Navigate to next section
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.select) {
            _handleMovieTap(movie);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _handleMovieTap(movie),
        child: ProfessionalMovieCard(
          movie: movie,
          focusNode: movieFocusNodes[movieId]!,
          onTap: () => _handleMovieTap(movie),
          onColorChange: (color) {
            setState(() {
              _currentAccentColor = color;
            });
          },
          index: index,
          categoryTitle: widget.displayTitle,
        ),
      ),
    );
  }
}

// Professional Movie Card
class ProfessionalMovieCard extends StatefulWidget {
  final Movie movie;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;
  final int index;
  final String categoryTitle;

  const ProfessionalMovieCard({
    Key? key,
    required this.movie,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalMovieCardState createState() => _ProfessionalMovieCardState();
}

class _ProfessionalMovieCardState extends State<ProfessionalMovieCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  Color _dominantColor = ProfessionalColors.accentBlue;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: AnimationTiming.medium,
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.06,
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
      widget.onColorChange(_dominantColor);
      HapticFeedback.lightImpact();
    } else {
      _scaleController.reverse();
      _glowController.reverse();
    }
  }

  void _generateDominantColor() {
    final colors = ProfessionalColors.gradientColors;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: screenWidth * 0.19,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfessionalPoster(screenWidth, screenHeight),
                _buildProfessionalTitle(screenWidth),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
    final posterHeight = _isFocused ? screenHeight * 0.28 : screenHeight * 0.22;

    return Container(
      height: posterHeight,
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
            _buildMovieImage(screenWidth, posterHeight),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            _buildGenreBadge(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieImage(double screenWidth, double posterHeight) {
    return Container(
      width: double.infinity,
      height: posterHeight,
      child: widget.movie.banner != null && widget.movie.banner!.isNotEmpty
          ? Image.network(
              widget.movie.banner!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder(posterHeight);
              },
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(posterHeight),
            )
          : _buildImagePlaceholder(posterHeight),
    );
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalColors.cardDark,
            ProfessionalColors.surfaceDark,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            size: height * 0.25,
            color: ProfessionalColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            widget.categoryTitle,
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ProfessionalColors.accentBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'HD',
              style: TextStyle(
                color: ProfessionalColors.accentBlue,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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

  Widget _buildGenreBadge() {
    String genre = 'HD';
    Color badgeColor = ProfessionalColors.accentBlue;

    if (widget.movie.genres.toLowerCase().contains('comedy')) {
      genre = 'COMEDY';
      badgeColor = ProfessionalColors.accentGreen;
    } else if (widget.movie.genres.toLowerCase().contains('action')) {
      genre = 'ACTION';
      badgeColor = ProfessionalColors.accentRed;
    } else if (widget.movie.genres.toLowerCase().contains('romantic')) {
      genre = 'ROMANCE';
      badgeColor = ProfessionalColors.accentPink;
    } else if (widget.movie.genres.toLowerCase().contains('drama')) {
      genre = 'DRAMA';
      badgeColor = ProfessionalColors.accentPurple;
    }

    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          genre,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
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

  Widget _buildProfessionalTitle(double screenWidth) {
    final movieName = widget.movie.name.toUpperCase();

    return Container(
      width: screenWidth * 0.18,
      child: AnimatedDefaultTextStyle(
        duration: AnimationTiming.medium,
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11,
          fontWeight: FontWeight.w600,
          color: _isFocused ? _dominantColor : ProfessionalColors.textPrimary,
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
          movieName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// Professional View All Button
class ProfessionalViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int totalItems;
  final String itemType;

  const ProfessionalViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
    required this.totalItems,
    this.itemType = 'ITEMS',
  }) : super(key: key);

  @override
  _ProfessionalViewAllButtonState createState() =>
      _ProfessionalViewAllButtonState();
}

class _ProfessionalViewAllButtonState extends State<ProfessionalViewAllButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  bool _isFocused = false;
  Color _currentColor = ProfessionalColors.accentBlue;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotateController);

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
      if (_isFocused) {
        _currentColor = ProfessionalColors.gradientColors[
            math.Random().nextInt(ProfessionalColors.gradientColors.length)];
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.19,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _isFocused ? _pulseAnimation : _rotateAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isFocused ? _pulseAnimation.value : 1.0,
                child: Transform.rotate(
                  angle: _isFocused ? 0 : _rotateAnimation.value * 2 * math.pi,
                  child: Container(
                    height:
                        _isFocused ? screenHeight * 0.28 : screenHeight * 0.22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isFocused
                            ? [
                                _currentColor,
                                _currentColor.withOpacity(0.7),
                              ]
                            : [
                                ProfessionalColors.cardDark,
                                ProfessionalColors.surfaceDark,
                              ],
                      ),
                      boxShadow: [
                        if (_isFocused) ...[
                          BoxShadow(
                            color: _currentColor.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 3,
                            offset: const Offset(0, 8),
                          ),
                        ] else ...[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ],
                    ),
                    child: _buildViewAllContent(),
                  ),
                ),
              );
            },
          ),
          _buildViewAllTitle(),
        ],
      ),
    );
  }

  Widget _buildViewAllContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: _isFocused
            ? Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.grid_view_rounded,
                  size: _isFocused ? 45 : 35,
                  color: Colors.white,
                ),
                Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _isFocused ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.totalItems}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewAllTitle() {
    return AnimatedDefaultTextStyle(
      duration: AnimationTiming.medium,
      style: TextStyle(
        fontSize: _isFocused ? 13 : 11,
        fontWeight: FontWeight.w600,
        color: _isFocused ? _currentColor : ProfessionalColors.textPrimary,
        letterSpacing: 0.5,
        shadows: _isFocused
            ? [
                Shadow(
                  color: _currentColor.withOpacity(0.6),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Text(
        'ALL ${widget.itemType}',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// Professional Loading Indicator
class ProfessionalLoadingIndicator extends StatefulWidget {
  final String message;

  const ProfessionalLoadingIndicator({
    Key? key,
    this.message = 'Loading...',
  }) : super(key: key);

  @override
  _ProfessionalLoadingIndicatorState createState() =>
      _ProfessionalLoadingIndicatorState();
}

class _ProfessionalLoadingIndicatorState
    extends State<ProfessionalLoadingIndicator> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      ProfessionalColors.accentBlue,
                      ProfessionalColors.accentPurple,
                      ProfessionalColors.accentGreen,
                      ProfessionalColors.accentBlue,
                    ],
                    stops: [0.0, 0.3, 0.7, 1.0],
                    transform: GradientRotation(_animation.value * 2 * math.pi),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ProfessionalColors.primaryDark,
                  ),
                  child: const Icon(
                    Icons.movie_rounded,
                    color: ProfessionalColors.textPrimary,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            widget.message,
            style: const TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 200,
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: ProfessionalColors.surfaceDark,
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _animation.value,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    ProfessionalColors.accentBlue,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Professional Movies Grid View
class ProfessionalMoviesGridView extends StatefulWidget {
  final List<Movie> moviesList;
  final String categoryTitle;

  const ProfessionalMoviesGridView({
    Key? key,
    required this.moviesList,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalMoviesGridViewState createState() =>
      _ProfessionalMoviesGridViewState();
}

class _ProfessionalMoviesGridViewState extends State<ProfessionalMoviesGridView>
    with TickerProviderStateMixin {
  late Map<String, FocusNode> _movieFocusNodes;
  bool _isLoading = false;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _movieFocusNodes = {
      for (var movie in widget.moviesList) movie.id.toString(): FocusNode()
    };

    // Set up focus for the first movie
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.moviesList.isNotEmpty) {
        final firstMovieId = widget.moviesList[0].id.toString();
        if (_movieFocusNodes.containsKey(firstMovieId)) {
          FocusScope.of(context).requestFocus(_movieFocusNodes[firstMovieId]);
        }
      }
    });

    _initializeAnimations();
    _startStaggeredAnimation();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startStaggeredAnimation() {
    _fadeController.forward();
    _staggerController.forward();
  }

  Future<void> _handleGridMovieTap(Movie movie) async {
    if (_isLoading || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    bool dialogShown = false;
    try {
      if (mounted) {
        dialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                setState(() {
                  _isLoading = false;
                });
                return true;
              },
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ProfessionalColors.accentBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        child: const CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ProfessionalColors.accentBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Loading Movie...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please wait',
                        style: TextStyle(
                          color: ProfessionalColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }

      if (mounted) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop();
        }

// ProfessionalMoviesGridView class में helper method add करें
        List<NewsItemModel> _convertMoviesToNewsItems(List<Movie> movies) {
          return movies
              .map((movie) => NewsItemModel(
                    id: movie.id.toString(),
                    contentId: movie.id.toString(),
                    name: movie.name,
                    banner: movie.banner ?? movie.poster ?? '',
                    image: movie.poster ?? '',
                    url: movie.movieUrl,
                    unUpdatedUrl: movie.movieUrl,
                    contentType: '1', // Movie type
                    streamType: movie.sourceType,
                    liveStatus: false,
                    videoId: movie.id.toString(),
                    poster: movie.poster ?? movie.banner ?? '',
                    // Add other required fields as needed
                  ))
              .toList();
        }

// _handleGridMovieTap में use करें
        if (isYoutubeUrl(movie.movieUrl)) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              // builder: (context) => VideoScreen(
              //   videoUrl: movie.movieUrl,
              //   bannerImageUrl: movie.banner ?? movie.poster ?? '',
              //   startAtPosition: Duration.zero,
              //   videoType: movie.sourceType,
              //   channelList: _convertMoviesToNewsItems(widget.moviesList), // ✅ Convert and send
              //   isLive: false,
              //   isVOD: true,
              //   isBannerSlider: false,
              //   source: 'isMovieScreen',
              //   isSearch: false,
              //   videoId: movie.id,
              //   unUpdatedUrl: movie.movieUrl,
              //   name: movie.name,
              //   seasonId: null,
              //   isLastPlayedStored: true,
              //   liveStatus: false,
              // ),
              builder: (context) => CustomYoutubePlayer(
                videoUrl: movie.movieUrl,
              ),
            ),
          );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              // builder: (context) => VideoScreen(
              //   videoUrl: movie.movieUrl,
              //   bannerImageUrl: movie.banner ?? movie.poster ?? '',
              //   startAtPosition: Duration.zero,
              //   videoType: movie.sourceType,
              //   channelList: _convertMoviesToNewsItems(widget.moviesList), // ✅ Convert and send
              //   isLive: false,
              //   isVOD: true,
              //   isBannerSlider: false,
              //   source: 'isMovieScreen',
              //   isSearch: false,
              //   videoId: movie.id,
              //   unUpdatedUrl: movie.movieUrl,
              //   name: movie.name,
              //   seasonId: null,
              //   isLastPlayedStored: true,
              //   liveStatus: false,
              // ),
              builder: (context) => CustomVideoPlayer(
                videoUrl: movie.movieUrl,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (dialogShown) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        // ✅ Enhanced error handling for grid view
        String errorMessage = 'Error loading movie';
        if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          errorMessage = 'Network error. Please check your connection';
        } else if (e.toString().contains('format') ||
            e.toString().contains('codec')) {
          errorMessage = 'Video format not supported';
        } else if (e.toString().contains('not found') ||
            e.toString().contains('404')) {
          errorMessage = 'Movie not found or unavailable';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: ProfessionalColors.accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _handleGridMovieTap(movie),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    for (var node in _movieFocusNodes.values) {
      try {
        node.dispose();
      } catch (e) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ProfessionalColors.primaryDark,
                  ProfessionalColors.surfaceDark.withOpacity(0.8),
                  ProfessionalColors.primaryDark,
                ],
              ),
            ),
          ),

          // Main Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildProfessionalAppBar(),
                Expanded(
                  child: _buildMoviesGrid(),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child:
                    ProfessionalLoadingIndicator(message: 'Loading Movie...'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfessionalAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ProfessionalColors.surfaceDark.withOpacity(0.9),
            ProfessionalColors.surfaceDark.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalColors.accentBlue.withOpacity(0.2),
                  ProfessionalColors.accentPurple.withOpacity(0.2),
                ],
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      ProfessionalColors.accentBlue,
                      ProfessionalColors.accentPurple,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    widget.categoryTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ProfessionalColors.accentBlue.withOpacity(0.2),
                        ProfessionalColors.accentPurple.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: ProfessionalColors.accentBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${widget.moviesList.length} Movies Available',
                    style: const TextStyle(
                      color: ProfessionalColors.accentBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviesGrid() {
    if (widget.moviesList.isEmpty) {
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
                    ProfessionalColors.accentBlue.withOpacity(0.2),
                    ProfessionalColors.accentBlue.withOpacity(0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.movie_outlined,
                size: 40,
                color: ProfessionalColors.accentBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${widget.categoryTitle} Found',
              style: TextStyle(
                color: ProfessionalColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for new content',
              style: TextStyle(
                color: ProfessionalColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: widget.moviesList.length,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          final movie = widget.moviesList[index];
          String movieId = movie.id.toString();

          return AnimatedBuilder(
            animation: _staggerController,
            builder: (context, child) {
              final delay = (index / widget.moviesList.length) * 0.5;
              final animationValue = Interval(
                delay,
                delay + 0.5,
                curve: Curves.easeOutCubic,
              ).transform(_staggerController.value);

              return Transform.translate(
                offset: Offset(0, 50 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue,
                  child: ProfessionalGridMovieCard(
                    movie: movie,
                    focusNode: _movieFocusNodes[movieId]!,
                    onTap: () => _handleGridMovieTap(movie),
                    index: index,
                    categoryTitle: widget.categoryTitle,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Professional Grid Movie Card
class ProfessionalGridMovieCard extends StatefulWidget {
  final Movie movie;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int index;
  final String categoryTitle;

  const ProfessionalGridMovieCard({
    Key? key,
    required this.movie,
    required this.focusNode,
    required this.onTap,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalGridMovieCardState createState() =>
      _ProfessionalGridMovieCardState();
}

class _ProfessionalGridMovieCardState extends State<ProfessionalGridMovieCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  Color _dominantColor = ProfessionalColors.accentBlue;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: AnimationTiming.medium,
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

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
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
    final colors = ProfessionalColors.gradientColors;
    _dominantColor = colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _glowController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKey: (node, event) {
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
                      _buildMovieImage(),
                      if (_isFocused) _buildFocusBorder(),
                      _buildGradientOverlay(),
                      _buildMovieInfo(),
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

  Widget _buildMovieImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: widget.movie.banner != null && widget.movie.banner!.isNotEmpty
          ? Image.network(
              widget.movie.banner!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder();
              },
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalColors.cardDark,
            ProfessionalColors.surfaceDark,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_outlined,
              size: 40,
              color: ProfessionalColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              widget.categoryTitle,
              style: TextStyle(
                color: ProfessionalColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ProfessionalColors.accentBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'HD',
                style: TextStyle(
                  color: ProfessionalColors.accentBlue,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildMovieInfo() {
    final movieName = widget.movie.name;

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
              movieName.toUpperCase(),
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
                  if (widget.movie.runtime != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ProfessionalColors.accentGreen.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              ProfessionalColors.accentGreen.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${widget.movie.runtime}m',
                        style: const TextStyle(
                          color: ProfessionalColors.accentGreen,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
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
                    child: Text(
                      'HD',
                      style: TextStyle(
                        color: _dominantColor,
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

// Main Movies Screen
class MoviesScreen extends StatefulWidget {
  @override
  _MoviesScreenState createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final FocusNode _moviesFocusNode = FocusNode();

  @override
  void dispose() {
    _moviesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: SafeArea(
        child: ProfessionalMoviesHorizontalList(
          focusNode: _moviesFocusNode,
          displayTitle: "RECENTLY ADDED",
          navigationIndex: 3, // Adjust based on your navigation structure
          onFocusChange: (bool hasFocus) {
            // Handle focus change if needed
            print('Movies section focus: $hasFocus');
          },
        ),
      ),
    );
  }
}
