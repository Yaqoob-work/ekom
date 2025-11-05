
// import 'dart:async';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/genre_movies_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horizontal_list_details_page.dart';
// import 'dart:math' as math;
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_second_page.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:ui';

// // ✅ ==========================================================
// // DATA PARSING (Isolate Function)
// // This function runs in a background isolate to prevent UI freezes.
// // ==========================================================

// List<HorizontalVodModel> _parseAndSortVod(String jsonString) {
//   final List<dynamic> jsonData = json.decode(jsonString);

//   final vodList = jsonData
//       .map((json) => HorizontalVodModel.fromJson(json as Map<String, dynamic>))
//       .where((show) => show.status == 1) // First, filter by status
//       .toList()
//     ..sort((a, b) =>
//         a.networks_order.compareTo(b.networks_order)); // Then, sort the list

//   return vodList;
// }

// // ✅ ==========================================================
// // MODELS, CONSTANTS, AND HELPERS
// // ==========================================================

// enum LoadingState { initial, loading, rebuilding, loaded, error }

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

// class AnimationTiming {
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// class HorizontalVodModel {
//   final int id;
//   final String name;
//   final String? description;
//   final String? logo;
//   final String? releaseDate;
//   final String? genres;
//   final String? rating;
//   final String? language;
//   final int status;
//   final int networks_order;

//   HorizontalVodModel({
//     required this.id,
//     required this.name,
//     this.description,
//     this.logo,
//     this.releaseDate,
//     this.genres,
//     this.rating,
//     this.language,
//     required this.status,
//     required this.networks_order,
//   });

//   factory HorizontalVodModel.fromJson(Map<String, dynamic> json) {
//     return HorizontalVodModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       description: json['description'],
//       logo: json['logo'],
//       releaseDate: json['release_date'],
//       genres: json['genres'],
//       rating: json['rating'],
//       language: json['language'],
//       status: json['status'] ?? 0,
//       networks_order: json['networks_order'] ?? 999,
//     );
//   }
// }

// Widget displayImage(
//   String imageUrl, {
//   double? width,
//   double? height,
//   BoxFit fit = BoxFit.fill,
// }) {
//   if (imageUrl.isEmpty ||
//       imageUrl == 'localImage' ||
//       imageUrl.contains('localhost')) {
//     return _buildErrorWidget(width, height);
//   }

//   if (imageUrl.startsWith('data:image')) {
//     try {
//       Uint8List imageBytes = _getImageFromBase64String(imageUrl);
//       return Image.memory(
//         imageBytes,
//         fit: fit,
//         width: width,
//         height: height,
//         errorBuilder: (context, error, stackTrace) =>
//             _buildErrorWidget(width, height),
//       );
//     } catch (e) {
//       return _buildErrorWidget(width, height);
//     }
//   } else if (imageUrl.startsWith('http')) {
//     if (imageUrl.toLowerCase().endsWith('.svg')) {
//       return SvgPicture.network(
//         imageUrl,
//         width: width,
//         height: height,
//         fit: fit,
//         placeholderBuilder: (context) => _buildLoadingWidget(width, height),
//       );
//     } else {
//       return Image.network(
//         imageUrl,
//         width: width,
//         height: height,
//         fit: fit,
//         headers: const {'User-Agent': 'Flutter App'},
//         loadingBuilder: (context, child, progress) =>
//             progress == null ? child : _buildLoadingWidget(width, height),
//         errorBuilder: (context, error, stackTrace) =>
//             _buildErrorWidget(width, height),
//       );
//     }
//   } else {
//     return _buildErrorWidget(width, height);
//   }
// }

// Widget _buildLoadingWidget(double? width, double? height) {
//   return SizedBox(
//     width: width,
//     height: height,
//     child: const Center(
//       child: CircularProgressIndicator(
//         strokeWidth: 2,
//         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//       ),
//     ),
//   );
// }

// Widget _buildErrorWidget(double? width, double? height) {
//   return Container(
//     width: width,
//     height: height,
//     decoration: const BoxDecoration(
//       gradient: LinearGradient(colors: [
//         ProfessionalColors.accentGreen,
//         ProfessionalColors.accentBlue
//       ]),
//     ),
//     child: const Icon(Icons.broken_image, color: Colors.white, size: 24),
//   );
// }

// Uint8List _getImageFromBase64String(String base64String) {
//   return base64Decode(base64String.split(',').last);
// }

// // ✅ ==========================================================
// // OPTIMIZED VOD SERVICE
// // Now uses 'compute' for parsing to offload work from the main thread.
// // ==========================================================

// class HorizontalVodService {
//   static const String _cacheKeyHorizontalVod = 'cached_horizontal_vod';
//   static const String _cacheKeyTimestamp = 'cached_horizontal_vod_timestamp';
//   static const Duration _cacheValidity = Duration(hours: 1);

//   static Future<String?> getCachedRawData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final timestampStr = prefs.getString(_cacheKeyTimestamp);
//     if (timestampStr == null) return null;

//     final cacheTime = DateTime.parse(timestampStr);
//     if (DateTime.now().difference(cacheTime) > _cacheValidity) {
//       print('📦 VOD cache is expired.');
//       return null;
//     }

//     print('📦 VOD cache is valid.');
//     return prefs.getString(_cacheKeyHorizontalVod);
//   }

//   static Future<String> fetchAndCacheRawData() async {
//     print('🌐 Fetching fresh VOD data from API...');
//     final prefs = await SharedPreferences.getInstance();
//     final authKey = prefs.getString('result_auth_key') ?? '';

//     final response = await https.post(
//       Uri.parse('https://dashboard.cpplayers.com/api/v2/getNetworks'),
//       headers: {
//         'auth-key': authKey,
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'domain': 'coretechinfo.com'
//       },
//       body: json.encode({"network_id" :"" ,"data_for" : ""}),
//     ).timeout(const Duration(seconds: 30));

//     if (response.statusCode == 200) {
//       final rawData = response.body;
//       await prefs.setString(_cacheKeyHorizontalVod, rawData);
//       await prefs.setString(
//           _cacheKeyTimestamp, DateTime.now().toIso8601String());
//       print('💾 VOD data fetched and cached successfully.');
//       return rawData;
//     } else {
//       throw Exception('API Error: ${response.statusCode}');
//     }
//   }
// }

// // ✅ ==========================================================
// // MAIN WIDGET: HorzontalVod
// // ==========================================================

// class HorzontalVod extends StatefulWidget {
//   const HorzontalVod({super.key});
//   @override
//   _HorzontalVodState createState() => _HorzontalVodState();
// }

// class _HorzontalVodState extends State<HorzontalVod>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   // ✅ State variables
//   LoadingState _loadingState = LoadingState.initial;
//   String? _error;
//   List<HorizontalVodModel> _vodList = [];

//   int focusedIndex = -1;

//   // Animation Controllers
//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   // Focus and Scroll Controllers
//   Map<String, FocusNode> _vodFocusNodes = {};
//   late ScrollController _scrollController;
//   final double _itemWidth = bannerwdt;
//     bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _initializeAnimations();
//     _loadInitialData(); // ✅ Data loading entry point
//   }

//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();
//     _scrollController.dispose();
//     _cleanupFocusNodes();
//     super.dispose();
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

//   // ✅ Data loading orchestration method
//   Future<void> _loadInitialData() async {
//     final cachedRawData = await HorizontalVodService.getCachedRawData();

//     if (cachedRawData != null && cachedRawData.isNotEmpty) {
//       print('🚀 Loading VOD from valid cache...');
//       final parsedData = await compute(_parseAndSortVod, cachedRawData);
//       _applyDataToState(parsedData);
//       return;
//     }

//     print('📡 No valid VOD cache found, fetching fresh data...');
//     await _fetchDataWithLoading();
//   }

//   // ✅ Method for fetching data and showing a loading indicator
//   Future<void> _fetchDataWithLoading() async {
//     if (mounted)
//       setState(() {
//         _loadingState = LoadingState.loading;
//         _error = null;
//       });

//     try {
//       final freshRawData = await HorizontalVodService.fetchAndCacheRawData();
//       if (freshRawData.isNotEmpty) {
//         final parsedData = await compute(_parseAndSortVod, freshRawData);
//         _applyDataToState(parsedData);
//       } else {
//         throw Exception('Failed to load data: API returned empty.');
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = e.toString();
//           _loadingState = LoadingState.error;
//         });
//       }
//     }
//   }

//   // ✅ Cleanly disposes old focus nodes
//   void _cleanupFocusNodes() {
//     for (var node in _vodFocusNodes.values) {
//       try {
//         node.dispose();
//       } catch (e) {}
//     }
//     _vodFocusNodes.clear();
//   }



//   // // ✅ Cleanly disposes old focus nodes (except the registered one)
//   // void _cleanupFocusNodes() {
//   //   // ❗️ BADLAV YAHAN: Sirf un nodes ko dispose karein jo provider mein register NAHI hue
//   //   String? firstVodId;
//   //   if (_vodList.isNotEmpty) {
//   //     firstVodId = _vodList[0].id.toString();
//   //   }

//   //   for (var entry in _vodFocusNodes.entries) {
//   //     // Agar node register nahi hua hai (yaani first VOD item nahi hai), tabhi use yahan dispose karein
//   //     if (entry.key != firstVodId) {
//   //       try {
//   //         // Listener hatana zaroori nahi hai kyunki node dispose ho raha hai
//   //         entry.value.dispose();
//   //       } catch (e) {}
//   //     }
//   //   }
//   //   _vodFocusNodes.clear();
//   // }

//   // ✅ Method to apply parsed data to the state
//   void _applyDataToState(List<HorizontalVodModel> vodList) {
//     if (!mounted) return;

//     setState(() {
//       _loadingState = LoadingState.rebuilding;
//     });

//     _cleanupFocusNodes();

//     _vodList = vodList;

//     // Create new focus nodes for all items
//     for (final vod in _vodList) {
//       String vodId = vod.id.toString();
//       _vodFocusNodes[vodId] = FocusNode();
//     }

//     setState(() {
//       _loadingState = LoadingState.loaded;
//     });

//     // Setup focus provider for navigation from other sections
//     _setupFocusProvider();

//     // Start UI animations
//     _headerAnimationController.forward();
//     _listAnimationController.forward();
//   }

//   void _setupFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && _vodList.isNotEmpty) {
//         final focusProvider =
//             Provider.of<FocusProvider>(context, listen: false);
//         final firstVodId = _vodList[0].id.toString();
//         final firstNode = _vodFocusNodes[firstVodId];

//         if (firstNode != null) {
//           // focusProvider.setFirstHorizontalListNetworksFocusNode(firstNode);
//           focusProvider.registerFocusNode('subVod', firstNode);
//           print('✅ VOD first focus node registered: ${_vodList[0].name}');
//         }
//       }
//     });
//   }

//   void _scrollToPosition(int index) {
//     if (!_scrollController.hasClients) return;
//     final double targetOffset = index * (_itemWidth + 12); // item width + margin

//     _scrollController.animateTo(
//       targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
//       duration: AnimationTiming.scroll,
//       curve: Curves.easeOutCubic,
//     );
//   }

//   void _navigateToHorizontalVodDetails(HorizontalVodModel vod) async {
//     print('🎬 Navigating to TV Show Details: ${vod.name}');

//     try {
//       print('Updating user history for: ${vod.name}');
//       int? currentUserId = SessionManager.userId;
//       final int? parsedId = vod.id;

//       await HistoryService.updateUserHistory(
//         userId: currentUserId!,
//         contentType: 0,
//         eventId: parsedId!,
//         eventTitle: vod.name,
//         url: '',
//         categoryId: 0,
//       );
//     } catch (e) {
//       print("History update failed, but proceeding. Error: $e");
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => GenreMoviesScreen(
//           tvChannelId: (vod.id).toString(),
//           logoUrl: vod.logo ?? '',
//           title: vod.name,
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from TV Show Details');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Consumer<ColorProvider>(
//       builder: (context, colorProvider, child) {
//         final bgColor = colorProvider.isItemFocused
//             ? colorProvider.dominantColor.withOpacity(0.1)
//             : ProfessionalColors.primaryDark;

//         return Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   bgColor,
//                   bgColor.withOpacity(0.8),
//                   ProfessionalColors.primaryDark,
//                 ],
//               ),
//             ),
//             child: Column(
//               children: [
//                 SizedBox(height: screenHeight * 0.02),
//                 _buildProfessionalTitle(screenWidth),
//                 SizedBox(height: screenHeight * 0.01),
//                 Expanded(child: _buildBody(screenWidth, screenHeight)),
//               ],
//             ),
//           ),
//         );
//       },
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
//                   ProfessionalColors.accentGreen,
//                   ProfessionalColors.accentBlue,
//                 ],
//               ).createShader(bounds),
//               child: Text(
//                 'CONTENTS',
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ Updated _buildBody to use the LoadingState enum
//   Widget _buildBody(double screenWidth, double screenHeight) {
//     switch (_loadingState) {
//       case LoadingState.initial:
//       case LoadingState.loading:
//         return const ProfessionalHorizontalVodLoadingIndicator(
//             message: 'Loading Contents...');

//       case LoadingState.error:
//         return Center(
//             child:
//                 Text('Error: $_error', style: const TextStyle(color: Colors.red)));

//       case LoadingState.rebuilding:
//       case LoadingState.loaded:
//         if (_vodList.isEmpty) {
//           return _buildEmptyWidget();
//         } else {
//           return _buildHorizontalVodList(screenWidth, screenHeight);
//         }
//     }
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
//                   ProfessionalColors.accentGreen.withOpacity(0.2),
//                   ProfessionalColors.accentGreen.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.live_tv_outlined,
//               size: 40,
//               color: ProfessionalColors.accentGreen,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No Content Found',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Check back later for new shows',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ REFACTORED: Removed "View All" button and logic to display all items.
//   Widget _buildHorizontalVodList(double screenWidth, double screenHeight) {
//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: SizedBox(
//         height: screenHeight * 0.38,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.none,
//           controller: _scrollController,
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//           cacheExtent: 9999,
//           itemCount: _vodList.length, // Display all items from the list
//           itemBuilder: (context, index) {
//             var vod = _vodList[index];
//             return _buildHorizontalVodItem(vod, index, screenWidth, screenHeight);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildHorizontalVodItem(
//       HorizontalVodModel vod, int index, double screenWidth, double screenHeight) {
//     String vodId = vod.id.toString();
//     FocusNode? focusNode = _vodFocusNodes[vodId];

//     // Safety check if focus node doesn't exist
//     if (focusNode == null) return const SizedBox.shrink();

//     return Focus(
//       focusNode: focusNode,
//       onFocusChange: (hasFocus) {
//         if (hasFocus && mounted) {
//           _scrollToPosition(index);
//           setState(() => focusedIndex = index);
//           context.read<ColorProvider>().updateColor(
//               ProfessionalColors.gradientColors[
//                   math.Random().nextInt(ProfessionalColors.gradientColors.length)],
//               true);
//         } else if (mounted) {
//           context.read<ColorProvider>().resetColor();
//         }
//       },
//       // onKey: (node, event) {
//       //   if (event is RawKeyDownEvent) {
//       //     if (event.logicalKey == LogicalKeyboardKey.enter ||
//       //         event.logicalKey == LogicalKeyboardKey.select) {
//       //       _navigateToHorizontalVodDetails(vod);
//       //       return KeyEventResult.handled;
//       //     }
//       //   }
//       //   return KeyEventResult.ignored;
//       // },
//       // Inside _buildHorizontalVodItem in horizontal_vod.dart

// // onKey: (node, event) {
// //     if (event is RawKeyDownEvent) {
// //         // --- Navigation Logic for Arrow Keys ---

// //         if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
// //             if (index < _vodList.length - 1) {
// //                 String nextVodId = _vodList[index + 1].id.toString();
// //                 FocusScope.of(context).requestFocus(_vodFocusNodes[nextVodId]);
// //                 return KeyEventResult.handled;
// //             }
// //         } 
        
// //         else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
// //             if (index > 0) {
// //                 String prevVodId = _vodList[index - 1].id.toString();
// //                 FocusScope.of(context).requestFocus(_vodFocusNodes[prevVodId]);
// //                 return KeyEventResult.handled;
// //             }
// //         } 
        
// //         // else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// //         //     // This assumes you have a Live TV or similar section above.
// //         //     // Based on your other files, this would be the correct call.
// //         //     context.read<ColorProvider>().resetColor();
// //         //     FocusScope.of(context).unfocus();
// //         //     Future.delayed(const Duration(milliseconds: 50), () {
// //         //         if (mounted) {
// //         //             context.read<FocusProvider>().requestLiveChannelsFocus();
// //         //         }
// //         //     });
// //         //     return KeyEventResult.handled;
// //         // } 



// //             // ✅ STEP 3.1: ARROW UP ka logic update karein
// //     else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// //       context.read<ColorProvider>().resetColor();
// //       FocusScope.of(context).unfocus();
// //       Future.delayed(const Duration(milliseconds: 50), () {
// //         if (mounted) {
// //           // Provider se active genre par focus karne ko kahein
// //           // context.read<FocusProvider>().requestFocusOnActiveLiveGenre();
// //           context.read<FocusProvider>().requestLiveChannelLanguageFocus();
// //         }
// //       });
// //       return KeyEventResult.handled;
// //     } 
        
// //         // ✅ THIS IS THE NEW LOGIC YOU ASKED FOR
// //         else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
// //             context.read<ColorProvider>().resetColor();
// //             FocusScope.of(context).unfocus();
// //             Future.delayed(const Duration(milliseconds: 50), () {
// //                 if (mounted) {
// //                     // Ask the provider to focus the first movie item
// //                     Provider.of<FocusProvider>(context, listen: false)
// //                         .requestFirstMoviesFocus();
// //                 }
// //             });
// //             return KeyEventResult.handled;
// //         }

// //         // --- Action Logic for Select/Enter ---
        
// //         else if (event.logicalKey == LogicalKeyboardKey.enter ||
// //             event.logicalKey == LogicalKeyboardKey.select) {
// //             _navigateToHorizontalVodDetails(vod);
// //             return KeyEventResult.handled;
// //         }
// //     }
// //     return KeyEventResult.ignored;
// // },


// onKey: (node, event) {
//       if (event is RawKeyDownEvent) {
//         final key = event.logicalKey;

//         // --- हॉरिजॉन्टल मूवमेंट (लेफ्ट/राइट) के लिए थ्रॉटलिंग ---
//         if (key == LogicalKeyboardKey.arrowRight ||
//             key == LogicalKeyboardKey.arrowLeft) {
              
//           // 1. अगर नेविगेशन लॉक्ड है, तो कुछ न करें
//           if (_isNavigationLocked) return KeyEventResult.handled;

//           // 2. नेविगेशन को लॉक करें और 300ms का टाइमर शुरू करें
//           setState(() => _isNavigationLocked = true);
//           _navigationLockTimer = Timer(const Duration(milliseconds: 600), () {
//             if (mounted) setState(() => _isNavigationLocked = false);
//           });

//           // 3. अब फोकस बदलें
//           if (key == LogicalKeyboardKey.arrowRight) {
//             if (index < _vodList.length - 1) {
//               String nextVodId = _vodList[index + 1].id.toString();
//               FocusScope.of(context).requestFocus(_vodFocusNodes[nextVodId]);
//             } else {
//               // अगर लिस्ट के अंत में हैं, तो लॉक तुरंत हटा दें
//               _navigationLockTimer?.cancel();
//               if (mounted) setState(() => _isNavigationLocked = false);
//             }
//           } else if (key == LogicalKeyboardKey.arrowLeft) {
//             if (index > 0) {
//               String prevVodId = _vodList[index - 1].id.toString();
//               FocusScope.of(context).requestFocus(_vodFocusNodes[prevVodId]);
//             } else {
//               // अगर लिस्ट की शुरुआत में हैं, तो लॉक तुरंत हटा दें
//               _navigationLockTimer?.cancel();
//               if (mounted) setState(() => _isNavigationLocked = false);
//             }
//           }
//           return KeyEventResult.handled;
//         }

//         // // --- बाकी कीज़ (अप/डाउन/सेलेक्ट) को तुरंत हैंडल करें ---
//         // if (key == LogicalKeyboardKey.arrowUp) {
//         //   context.read<ColorProvider>().resetColor();
//         //   FocusScope.of(context).unfocus();
//         //   Future.delayed(const Duration(milliseconds: 50), () {
//         //     if (mounted) {
//         //       context.read<FocusProvider>().requestLiveChannelLanguageFocus();
//         //     }
//         //   });
//         //   return KeyEventResult.handled;
//         // } 
//         if (key == LogicalKeyboardKey.arrowUp) {
//           context.read<ColorProvider>().resetColor();
//           FocusScope.of(context).unfocus();
//           // Future.delayed(const Duration(milliseconds: 50), () {
//             if (mounted) {
//               // ❗️ BADLAV 1: Naya requestFocus method
//               context.read<FocusProvider>().requestFocus('liveChannelLanguage'); 
//             }
//           // });
//           return KeyEventResult.handled;
//         }
//         // else if (key == LogicalKeyboardKey.arrowDown) {
//         //   context.read<ColorProvider>().resetColor();
//         //   FocusScope.of(context).unfocus();
//         //   Future.delayed(const Duration(milliseconds: 50), () {
//         //     if (mounted) {
//         //       Provider.of<FocusProvider>(context, listen: false)
//         //           .requestFirstMoviesFocus();
//         //     }
//         //   });
//         //   return KeyEventResult.handled;
//         // }


//         // } 
//         else if (key == LogicalKeyboardKey.arrowDown) {
//           context.read<ColorProvider>().resetColor();
//           // FocusScope.of(context).unfocus();
//           // Future.delayed(const Duration(milliseconds: 50), () {
//             if (mounted) {
//               // ❗️ BADLAV 2: Naya requestFocus method
//               Provider.of<FocusProvider>(context, listen: false)
//                   .requestFocus('manageMovies'); 
//             }
//           // });
//           return KeyEventResult.handled;
//         }
//          else if (key == LogicalKeyboardKey.enter ||
//             key == LogicalKeyboardKey.select) {
//           _navigateToHorizontalVodDetails(vod);
//           return KeyEventResult.handled;
//         }
//       }
//       return KeyEventResult.ignored;
//     },
//       child: GestureDetector(
//         onTap: () => _navigateToHorizontalVodDetails(vod),
//         child: ProfessionalHorizontalVodCard(
//           HorizontalVod: vod,
//           focusNode: focusNode,
//           onTap: () => _navigateToHorizontalVodDetails(vod),
//           onColorChange: (color) {
//             if (focusNode.hasFocus) {
//               context.read<ColorProvider>().updateColor(color, true);
//             }
//           },
//           index: index,
//           categoryTitle: 'CONTENTS',
//         ),
//       ),
//     );
//   }
// }

// // ✅ ==========================================================
// // SUPPORTING WIDGETS
// // ==========================================================

// // ✅ Professional Loading Indicator
// class ProfessionalHorizontalVodLoadingIndicator extends StatefulWidget {
//   final String message;

//   const ProfessionalHorizontalVodLoadingIndicator({
//     Key? key,
//     this.message = 'Loading Vod...',
//   }) : super(key: key);

//   @override
//   _ProfessionalHorizontalVodLoadingIndicatorState createState() =>
//       _ProfessionalHorizontalVodLoadingIndicatorState();
// }

// class _ProfessionalHorizontalVodLoadingIndicatorState
//     extends State<ProfessionalHorizontalVodLoadingIndicator>
//     with TickerProviderStateMixin {
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
//                       ProfessionalColors.accentGreen,
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentOrange,
//                       ProfessionalColors.accentGreen,
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
//                     Icons.live_tv_rounded,
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
//                     ProfessionalColors.accentGreen,
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

// // ✅ Professional TV Show Card
// class ProfessionalHorizontalVodCard extends StatefulWidget {
//   final HorizontalVodModel HorizontalVod;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalHorizontalVodCard({
//     Key? key,
//     required this.HorizontalVod,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalHorizontalVodCardState createState() =>
//       _ProfessionalHorizontalVodCardState();
// }

// class _ProfessionalHorizontalVodCardState
//     extends State<ProfessionalHorizontalVodCard> with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _glowController;
//   late AnimationController _shimmerController;

//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<double> _shimmerAnimation;

//   Color _dominantColor = ProfessionalColors.accentGreen;
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
//             width: bannerwdt,
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
//     final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;

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
//             _buildHorizontalVodImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildGenreBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHorizontalVodImage(double screenWidth, double posterHeight) {
//     return SizedBox(
//       width: double.infinity,
//       height: posterHeight,
//       child: widget.HorizontalVod.logo != null &&
//               widget.HorizontalVod.logo!.isNotEmpty
//           ? displayImage(
//               widget.HorizontalVod.logo!,
//               fit: BoxFit.cover,
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
//             Icons.live_tv_rounded,
//             size: height * 0.25,
//             color: ProfessionalColors.textSecondary,
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'TV SHOW',
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
//               color: ProfessionalColors.accentGreen.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'LIVE',
//               style: TextStyle(
//                 color: ProfessionalColors.accentGreen,
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
//                 stops: const [0.0, 0.5, 1.0],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildGenreBadge() {
//     String genre = 'CONTENTS';
//     Color badgeColor = ProfessionalColors.accentGreen;

//     if (widget.HorizontalVod.genres != null) {
//       if (widget.HorizontalVod.genres!.toLowerCase().contains('news')) {
//         genre = 'NEWS';
//         badgeColor = ProfessionalColors.accentRed;
//       } else if (widget.HorizontalVod.genres!
//           .toLowerCase()
//           .contains('sports')) {
//         genre = 'SPORTS';
//         badgeColor = ProfessionalColors.accentOrange;
//       } else if (widget.HorizontalVod.genres!
//           .toLowerCase()
//           .contains('entertainment')) {
//         genre = 'ENTERTAINMENT';
//         badgeColor = ProfessionalColors.accentPink;
//       } else if (widget.HorizontalVod.genres!
//           .toLowerCase()
//           .contains('documentary')) {
//         genre = 'DOCUMENTARY';
//         badgeColor = ProfessionalColors.accentBlue;
//       }
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
//             child: Icon(
//               Icons.play_arrow_rounded,
//               color: _dominantColor,
//               size: 30,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     final HorizontalVodName = widget.HorizontalVod.name.toUpperCase();

//     return SizedBox(
//       width: bannerwdt,
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
//           HorizontalVodName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }








import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/genre_movies_screen.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horizontal_list_details_page.dart';
import 'dart:math' as math;
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_second_page.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

// ✅ ==========================================================
// DATA PARSING (Isolate Function)
// ==========================================================

List<HorizontalVodModel> _parseAndSortVod(String jsonString) {
  final List<dynamic> jsonData = json.decode(jsonString);

  final vodList = jsonData
      .map((json) => HorizontalVodModel.fromJson(json as Map<String, dynamic>))
      .where((show) => show.status == 1) // First, filter by status
      .toList()
    ..sort((a, b) =>
        a.networks_order.compareTo(b.networks_order)); // Then, sort the list

  return vodList;
}

// ✅ ==========================================================
// MODELS, CONSTANTS, AND HELPERS
// ==========================================================

enum LoadingState { initial, loading, rebuilding, loaded, error }

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

class AnimationTiming {
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration scroll = Duration(milliseconds: 800);
}

class HorizontalVodModel {
  final int id;
  final String name;
  final String? description;
  final String? logo;
  final String? releaseDate;
  final String? genres;
  final String? rating;
  final String? language;
  final int status;
  final int networks_order;

  HorizontalVodModel({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    this.releaseDate,
    this.genres,
    this.rating,
    this.language,
    required this.status,
    required this.networks_order,
  });

  factory HorizontalVodModel.fromJson(Map<String, dynamic> json) {
    return HorizontalVodModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      logo: json['logo'],
      releaseDate: json['release_date'],
      genres: json['genres'],
      rating: json['rating'],
      language: json['language'],
      status: json['status'] ?? 0,
      networks_order: json['networks_order'] ?? 999,
    );
  }
}

Widget displayImage(
  String imageUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.fill,
}) {
  if (imageUrl.isEmpty ||
      imageUrl == 'localImage' ||
      imageUrl.contains('localhost')) {
    return _buildErrorWidget(width, height);
  }

  if (imageUrl.startsWith('data:image')) {
    try {
      Uint8List imageBytes = _getImageFromBase64String(imageUrl);
      return Image.memory(
        imageBytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorWidget(width, height),
      );
    } catch (e) {
      return _buildErrorWidget(width, height);
    }
  } else if (imageUrl.startsWith('http')) {
    if (imageUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) => _buildLoadingWidget(width, height),
      );
    } else {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        headers: const {'User-Agent': 'Flutter App'},
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _buildLoadingWidget(width, height),
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorWidget(width, height),
      );
    }
  } else {
    return _buildErrorWidget(width, height);
  }
}

Widget _buildLoadingWidget(double? width, double? height) {
  return SizedBox(
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

Widget _buildErrorWidget(double? width, double? height) {
  return Container(
    width: width,
    height: height,
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [
        ProfessionalColors.accentGreen,
        ProfessionalColors.accentBlue
      ]),
    ),
    child: const Icon(Icons.broken_image, color: Colors.white, size: 24),
  );
}

Uint8List _getImageFromBase64String(String base64String) {
  return base64Decode(base64String.split(',').last);
}

// ✅ ==========================================================
// OPTIMIZED VOD SERVICE
// ==========================================================

class HorizontalVodService {
  static const String _cacheKeyHorizontalVod = 'cached_horizontal_vod';
  static const String _cacheKeyTimestamp = 'cached_horizontal_vod_timestamp';
  static const Duration _cacheValidity = Duration(hours: 1);

  static Future<String?> getCachedRawData() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString(_cacheKeyTimestamp);
    if (timestampStr == null) return null;

    final cacheTime = DateTime.parse(timestampStr);
    if (DateTime.now().difference(cacheTime) > _cacheValidity) {
      print('📦 VOD cache is expired.');
      return null;
    }

    print('📦 VOD cache is valid.');
    return prefs.getString(_cacheKeyHorizontalVod);
  }

  static Future<String> fetchAndCacheRawData() async {
    print('🌐 Fetching fresh VOD data from API...');
    final prefs = await SharedPreferences.getInstance();
            String authKey = SessionManager.authKey ;
      var url = Uri.parse(SessionManager.baseUrl + 'getNetworks');

    final response = await https.post(url,
      // Uri.parse('https://dashboard.cpplayers.com/api/v2/getNetworks'),
      headers: {
        'auth-key': authKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'domain': SessionManager.savedDomain
      },
      body: json.encode({"network_id" :"" ,"data_for" : ""}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final rawData = response.body;
      await prefs.setString(_cacheKeyHorizontalVod, rawData);
      await prefs.setString(
          _cacheKeyTimestamp, DateTime.now().toIso8601String());
      print('💾 VOD data fetched and cached successfully.');
      return rawData;
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }
}

// ✅ ==========================================================
// MAIN WIDGET: HorzontalVod
// ==========================================================

class HorzontalVod extends StatefulWidget {
  const HorzontalVod({super.key});
  @override
  _HorzontalVodState createState() => _HorzontalVodState();
}

class _HorzontalVodState extends State<HorzontalVod>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  // ✅ State variables
  LoadingState _loadingState = LoadingState.initial;
  String? _error;
  List<HorizontalVodModel> _vodList = [];

  int focusedIndex = -1;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  // Focus and Scroll Controllers
  Map<String, FocusNode> _vodFocusNodes = {};
  late ScrollController _scrollController;
  final double _itemWidth = bannerwdt;
  bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
    _loadInitialData(); // ✅ Data loading entry point
  }

  @override
  void dispose() {
    _navigationLockTimer?.cancel();
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    _scrollController.dispose();
    _cleanupFocusNodes(); // ✅ Call updated cleanup
    super.dispose();
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

  // ✅ Data loading orchestration method
  Future<void> _loadInitialData() async {
    final cachedRawData = await HorizontalVodService.getCachedRawData();

    if (cachedRawData != null && cachedRawData.isNotEmpty) {
      print('🚀 Loading VOD from valid cache...');
      final parsedData = await compute(_parseAndSortVod, cachedRawData);
      _applyDataToState(parsedData);
      return;
    }

    print('📡 No valid VOD cache found, fetching fresh data...');
    await _fetchDataWithLoading();
  }

  // ✅ Method for fetching data and showing a loading indicator
  Future<void> _fetchDataWithLoading() async {
    if (mounted)
      setState(() {
        _loadingState = LoadingState.loading;
        _error = null;
      });

    try {
      final freshRawData = await HorizontalVodService.fetchAndCacheRawData();
      if (freshRawData.isNotEmpty) {
        final parsedData = await compute(_parseAndSortVod, freshRawData);
        _applyDataToState(parsedData);
      } else {
        throw Exception('Failed to load data: API returned empty.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loadingState = LoadingState.error;
        });
      }
    }
  }

  // ✅ [UPDATED] Cleanly disposes old focus nodes
  // Yeh function ab sirf un nodes ko dispose karega jo provider mein register NAHI hue
  void _cleanupFocusNodes() {
    String? firstVodId;
    if (_vodList.isNotEmpty) {
      firstVodId = _vodList[0].id.toString();
    }

    for (var entry in _vodFocusNodes.entries) {
      // Agar node register nahi hua hai (yaani first VOD item nahi hai), tabhi use yahan dispose karein
      if (entry.key != firstVodId) {
        try {
          // Listener hatana zaroori nahi hai kyunki node dispose ho raha hai
          entry.value.dispose();
        } catch (e) {}
      }
    }
    _vodFocusNodes.clear();
  }

  // ✅ Method to apply parsed data to the state
  void _applyDataToState(List<HorizontalVodModel> vodList) {
    if (!mounted) return;

    setState(() {
      _loadingState = LoadingState.rebuilding;
    });

    _cleanupFocusNodes(); // Purane nodes hatayein

    _vodList = vodList;

    // Create new focus nodes for all items
    for (final vod in _vodList) {
      String vodId = vod.id.toString();
      _vodFocusNodes[vodId] = FocusNode();
    }

    setState(() {
      _loadingState = LoadingState.loaded;
    });

    // Setup focus provider for navigation from other sections
    _setupFocusProvider();

    // Start UI animations
    _headerAnimationController.forward();
    _listAnimationController.forward();
  }

  void _setupFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _vodList.isNotEmpty) {
        final focusProvider =
            Provider.of<FocusProvider>(context, listen: false);
        final firstVodId = _vodList[0].id.toString();
        final firstNode = _vodFocusNodes[firstVodId];

        if (firstNode != null) {
          focusProvider.registerFocusNode('subVod', firstNode);
          print('✅ VOD first focus node registered: ${_vodList[0].name}');
        }
      }
    });
  }

  void _scrollToPosition(int index) {
    if (!_scrollController.hasClients) return;
    final double targetOffset = index * (_itemWidth + 12); // item width + margin

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: AnimationTiming.scroll,
      curve: Curves.easeOutCubic,
    );
  }

  void _navigateToHorizontalVodDetails(HorizontalVodModel vod) async {
    print('🎬 Navigating to TV Show Details: ${vod.name}');

    try {
      print('Updating user history for: ${vod.name}');
      int? currentUserId = SessionManager.userId;
      final int? parsedId = vod.id;

      await HistoryService.updateUserHistory(
        userId: currentUserId!,
        contentType: 0,
        eventId: parsedId!,
        eventTitle: vod.name,
        url: '',
        categoryId: 0,
      );
    } catch (e) {
      print("History update failed, but proceeding. Error: $e");
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenreMoviesScreen(
          tvChannelId: (vod.id).toString(),
          logoUrl: vod.logo ?? '',
          title: vod.name,
        ),
      ),
    ).then((_) {
      print('🔙 Returned from TV Show Details');
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        final bgColor = colorProvider.isItemFocused
            ? colorProvider.dominantColor.withOpacity(0.1)
            : ProfessionalColors.primaryDark;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bgColor,
                  bgColor.withOpacity(0.8),
                  ProfessionalColors.primaryDark,
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
      },
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
                  ProfessionalColors.accentGreen,
                  ProfessionalColors.accentBlue,
                ],
              ).createShader(bounds),
              child: Text(
                'CONTENTS',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Updated _buildBody to use the LoadingState enum
  Widget _buildBody(double screenWidth, double screenHeight) {
    switch (_loadingState) {
      case LoadingState.initial:
      case LoadingState.loading:
        return const ProfessionalHorizontalVodLoadingIndicator(
            message: 'Loading Contents...');

      case LoadingState.error:
        return Center(
            child:
                Text('Error: $_error', style: const TextStyle(color: Colors.red)));

      case LoadingState.rebuilding:
      case LoadingState.loaded:
        if (_vodList.isEmpty) {
          return _buildEmptyWidget();
        } else {
          return _buildHorizontalVodList(screenWidth, screenHeight);
        }
    }
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
                  ProfessionalColors.accentGreen.withOpacity(0.2),
                  ProfessionalColors.accentGreen.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.live_tv_outlined,
              size: 40,
              color: ProfessionalColors.accentGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Content Found',
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new shows',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ REFACTORED: Removed "View All" button and logic to display all items.
  Widget _buildHorizontalVodList(double screenWidth, double screenHeight) {
    return FadeTransition(
      opacity: _listFadeAnimation,
      child: SizedBox(
        height: screenHeight * 0.38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
          cacheExtent: 9999,
          itemCount: _vodList.length, // Display all items from the list
          itemBuilder: (context, index) {
            var vod = _vodList[index];
            return _buildHorizontalVodItem(vod, index, screenWidth, screenHeight);
          },
        ),
      ),
    );
  }

  Widget _buildHorizontalVodItem(
      HorizontalVodModel vod, int index, double screenWidth, double screenHeight) {
    String vodId = vod.id.toString();
    FocusNode? focusNode = _vodFocusNodes[vodId];

    // Safety check if focus node doesn't exist
    if (focusNode == null) return const SizedBox.shrink();

    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus && mounted) {
          _scrollToPosition(index);
          setState(() => focusedIndex = index);
          context.read<ColorProvider>().updateColor(
              ProfessionalColors.gradientColors[
                  math.Random().nextInt(ProfessionalColors.gradientColors.length)],
              true);
        } else if (mounted) {
          context.read<ColorProvider>().resetColor();
        }
      },
    // ✅ ==========================================================
    // ✅ [UPDATED] onKey LOGIC
    // ✅ ==========================================================
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          final key = event.logicalKey;

          // --- हॉरिजॉन्टल मूवमेंट (लेफ्ट/राइट) के लिए थ्रॉटलिंग ---
          if (key == LogicalKeyboardKey.arrowRight ||
              key == LogicalKeyboardKey.arrowLeft) {
            
            if (_isNavigationLocked) return KeyEventResult.handled;

            setState(() => _isNavigationLocked = true);
            _navigationLockTimer = Timer(const Duration(milliseconds: 600), () {
              if (mounted) setState(() => _isNavigationLocked = false);
            });

            if (key == LogicalKeyboardKey.arrowRight) {
              if (index < _vodList.length - 1) {
                String nextVodId = _vodList[index + 1].id.toString();
                FocusScope.of(context).requestFocus(_vodFocusNodes[nextVodId]);
              } else {
                _navigationLockTimer?.cancel();
                if (mounted) setState(() => _isNavigationLocked = false);
              }
            } else if (key == LogicalKeyboardKey.arrowLeft) {
              if (index > 0) {
                String prevVodId = _vodList[index - 1].id.toString();
                FocusScope.of(context).requestFocus(_vodFocusNodes[prevVodId]);
              } else {
                _navigationLockTimer?.cancel();
                if (mounted) setState(() => _isNavigationLocked = false);
              }
            }
            return KeyEventResult.handled;
          }

          // --- वर्टिकल मूवमेंट (अप/डाउन) ---
          if (key == LogicalKeyboardKey.arrowUp) {
            context.read<ColorProvider>().resetColor();
            // Naya method call karein
            context.read<FocusProvider>().focusPreviousRow(); 
            return KeyEventResult.handled;
          } 
          
          else if (key == LogicalKeyboardKey.arrowDown) {
            context.read<ColorProvider>().resetColor();
            // Naya method call karein
            context.read<FocusProvider>().focusNextRow();
            return KeyEventResult.handled;
          } 
          
          else if (key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.select) {
            _navigateToHorizontalVodDetails(vod);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    // ✅ ==========================================================
    // ✅ END OF [UPDATED] onKey LOGIC
    // ✅ ==========================================================
      child: GestureDetector(
        onTap: () => _navigateToHorizontalVodDetails(vod),
        child: ProfessionalHorizontalVodCard(
          HorizontalVod: vod,
          focusNode: focusNode,
          onTap: () => _navigateToHorizontalVodDetails(vod),
          onColorChange: (color) {
            if (focusNode.hasFocus) {
              context.read<ColorProvider>().updateColor(color, true);
            }
          },
          index: index,
          categoryTitle: 'CONTENTS',
        ),
      ),
    );
  }
}

// ✅ ==========================================================
// SUPPORTING WIDGETS (ProfessionalHorizontalVodLoadingIndicator, ProfessionalHorizontalVodCard)
// In widgets mein koi badlav nahi hai, isliye main inhein dobara paste nahi kar raha hoon.
// ... (Aapka baaki ka code... ProfessionalHorizontalVodLoadingIndicator... ProfessionalHorizontalVodCard... etc.)
// ...
// ...
// ✅ ==========================================================


// ✅ Professional Loading Indicator
class ProfessionalHorizontalVodLoadingIndicator extends StatefulWidget {
  final String message;

  const ProfessionalHorizontalVodLoadingIndicator({
    Key? key,
    this.message = 'Loading Vod...',
  }) : super(key: key);

  @override
  _ProfessionalHorizontalVodLoadingIndicatorState createState() =>
      _ProfessionalHorizontalVodLoadingIndicatorState();
}

class _ProfessionalHorizontalVodLoadingIndicatorState
    extends State<ProfessionalHorizontalVodLoadingIndicator>
    with TickerProviderStateMixin {
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
                      ProfessionalColors.accentGreen,
                      ProfessionalColors.accentBlue,
                      ProfessionalColors.accentOrange,
                      ProfessionalColors.accentGreen,
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
                    Icons.live_tv_rounded,
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
                    ProfessionalColors.accentGreen,
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

// ✅ Professional TV Show Card
class ProfessionalHorizontalVodCard extends StatefulWidget {
  final HorizontalVodModel HorizontalVod;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;
  final int index;
  final String categoryTitle;

  const ProfessionalHorizontalVodCard({
    Key? key,
    required this.HorizontalVod,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalHorizontalVodCardState createState() =>
      _ProfessionalHorizontalVodCardState();
}

class _ProfessionalHorizontalVodCardState
    extends State<ProfessionalHorizontalVodCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  Color _dominantColor = ProfessionalColors.accentGreen;
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
            width: bannerwdt,
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
    final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;

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
            _buildHorizontalVodImage(screenWidth, posterHeight),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            _buildGenreBadge(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalVodImage(double screenWidth, double posterHeight) {
    return SizedBox(
      width: double.infinity,
      height: posterHeight,
      child: widget.HorizontalVod.logo != null &&
              widget.HorizontalVod.logo!.isNotEmpty
          ? displayImage(
              widget.HorizontalVod.logo!,
              fit: BoxFit.cover,
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
            Icons.live_tv_rounded,
            size: height * 0.25,
            color: ProfessionalColors.textSecondary,
          ),
          const SizedBox(height: 8),
          const Text(
            'TV SHOW',
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
              color: ProfessionalColors.accentGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: ProfessionalColors.accentGreen,
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
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenreBadge() {
    String genre = 'CONTENTS';
    Color badgeColor = ProfessionalColors.accentGreen;

    if (widget.HorizontalVod.genres != null) {
      if (widget.HorizontalVod.genres!.toLowerCase().contains('news')) {
        genre = 'NEWS';
        badgeColor = ProfessionalColors.accentRed;
      } else if (widget.HorizontalVod.genres!
          .toLowerCase()
          .contains('sports')) {
        genre = 'SPORTS';
        badgeColor = ProfessionalColors.accentOrange;
      } else if (widget.HorizontalVod.genres!
          .toLowerCase()
          .contains('entertainment')) {
        genre = 'ENTERTAINMENT';
        badgeColor = ProfessionalColors.accentPink;
      } else if (widget.HorizontalVod.genres!
          .toLowerCase()
          .contains('documentary')) {
        genre = 'DOCUMENTARY';
        badgeColor = ProfessionalColors.accentBlue;
      }
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
            child: Icon(
              Icons.play_arrow_rounded,
              color: _dominantColor,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalTitle(double screenWidth) {
    final HorizontalVodName = widget.HorizontalVod.name.toUpperCase();

    return SizedBox(
      width: bannerwdt,
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
          HorizontalVodName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}