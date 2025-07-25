// // // // import 'dart:async';
// // // // import 'dart:convert';
// // // // import 'dart:math';
// // // // import 'dart:typed_data';
// // // // import 'package:cached_network_image/cached_network_image.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:flutter_spinkit/flutter_spinkit.dart';
// // // // import 'package:http/http.dart' as https;
// // // // import 'package:mobi_tv_entertainment/main.dart';
// // // // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // // // import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// // // // import 'package:mobi_tv_entertainment/video_widget/socket_service.dart';
// // // // import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// // // // import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player_4k.dart';
// // // // import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// // // // import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
// // // // import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
// // // // import 'package:mobi_tv_entertainment/widgets/utils/random_light_color_widget.dart';
// // // // import 'package:provider/provider.dart';
// // // // import 'package:shared_preferences/shared_preferences.dart';

// // // // import '../../widgets/small_widgets/app_assets.dart';

// // // // // Simple implementation of ImageCacheService for demonstration
// // // // class ImageCacheStats {
// // // //   final int totalFiles;
// // // //   final double totalSizeMB;
// // // //   ImageCacheStats({required this.totalFiles, required this.totalSizeMB});
// // // // }

// // // // class ImageCacheService {
// // // //   Future<void> init() async {
// // // //     // Initialize cache if needed
// // // //   }

// // // //   Future<bool> isCached(String url) async {
// // // //     // Always return false for demonstration
// // // //     return false;
// // // //   }

// // // //   Future<void> downloadAndCacheImage(String url) async {
// // // //     // Simulate download and cache
// // // //     await Future.delayed(Duration(milliseconds: 100));
// // // //   }

// // // //   Future<void> clearCache() async {
// // // //     // Simulate clearing cache
// // // //     await Future.delayed(Duration(milliseconds: 100));
// // // //   }

// // // //   Future<ImageCacheStats> getCacheStats() async {
// // // //     // Return dummy stats
// // // //     return ImageCacheStats(totalFiles: 0, totalSizeMB: 0.0);
// // // //   }
// // // // }

// // // // Future<Map<String, String>> getAuthHeaders() async {
// // // //   String authKey = '';

// // // //   // try {
// // // //   //   if (AuthManager.hasValidAuthKey) {
// // // //   //     authKey = AuthManager.authKey;
// // // //   //   }
// // // //   // } catch (e) {}

// // // //   // if (authKey.isEmpty && globalAuthKey.isNotEmpty) {
// // // //   //   authKey = globalAuthKey;
// // // //   // }

// // // //   if (authKey.isEmpty) {
// // // //     try {
// // // //       final prefs = await SharedPreferences.getInstance();
// // // //       authKey = prefs.getString('auth_key') ?? '';
// // // //       if (authKey.isNotEmpty) {
// // // //         globalAuthKey = authKey;
// // // //       }
// // // //     } catch (e) {}
// // // //   }

// // // //   if (authKey.isEmpty) {
// // // //     authKey = 'vLQTuPZUxktl5mVW';
// // // //   }

// // // //   return {
// // // //     'auth-key': authKey,
// // // //     // 'x-api-key': authKey,
// // // //     'Accept': 'application/json',
// // // //     'Content-Type': 'application/json',
// // // //     // 'User-Agent': 'MobiTV/1.0',
// // // //   };
// // // // }

// // // // class ApiConfig {
// // // //   static const String PRIMARY_BASE_URL =
// // // //       'https://acomtv.coretechinfo.com/public/api';

// // // //   static const List<String> FEATURED_TV_ENDPOINTS = [
// // // //     '$PRIMARY_BASE_URL/getCustomImageSlider',
// // // //   ];

// // // //   static const List<String> BANNER_ENDPOINTS = [
// // // //     '$PRIMARY_BASE_URL/getCustomImageSlider',
// // // //   ];
// // // // }

// // // // Future<Map<String, String>> fetchVideoDataByIdFromBanners(
// // // //     String contentId) async {
// // // //   final prefs = await SharedPreferences.getInstance();
// // // //   final cachedData = prefs.getString('live_featured_tv');

// // // //   List<dynamic> responseData;

// // // //   try {
// // // //     if (cachedData != null) {
// // // //       responseData = json.decode(cachedData);
// // // //     } else {
// // // //       Map<String, String> headers = await getAuthHeaders();
// // // //       bool success = false;
// // // //       String responseBody = '';

// // // //       for (int i = 0; i < ApiConfig.FEATURED_TV_ENDPOINTS.length; i++) {
// // // //         String endpoint = ApiConfig.FEATURED_TV_ENDPOINTS[i];

// // // //         try {
// // // //           Map<String, String> currentHeaders = Map.from(headers);

// // // //           if (endpoint.contains('api.ekomflix.com')) {
// // // //             currentHeaders = {
// // // //               'x-api-key': 'vLQTuPZUxktl5mVW',
// // // //               'Accept': 'application/json',
// // // //             };
// // // //           }

// // // //           final response = await https
// // // //               .get(
// // // //                 Uri.parse(endpoint),
// // // //                 headers: currentHeaders,
// // // //               )
// // // //               .timeout(Duration(seconds: 15));

// // // //           if (response.statusCode == 200) {
// // // //             String body = response.body.trim();
// // // //             if (body.startsWith('[') || body.startsWith('{')) {
// // // //               try {
// // // //                 json.decode(body);
// // // //                 responseBody = body;
// // // //                 success = true;
// // // //                 break;
// // // //               } catch (e) {
// // // //                 continue;
// // // //               }
// // // //             } else {
// // // //               continue;
// // // //             }
// // // //           } else {
// // // //             continue;
// // // //           }
// // // //         } catch (e) {
// // // //           continue;
// // // //         }
// // // //       }

// // // //       if (!success) {
// // // //         throw Exception('Failed to load featured live TV from all endpoints');
// // // //       }

// // // //       responseData = json.decode(responseBody);
// // // //       await prefs.setString('live_featured_tv', responseBody);
// // // //     }

// // // //     final matchedItem = responseData.firstWhere(
// // // //       (channel) => channel['id'].toString() == contentId,
// // // //       orElse: () => null,
// // // //     );

// // // //     if (matchedItem == null) {
// // // //       throw Exception('Content with ID $contentId not found');
// // // //     }

// // // //     return {
// // // //       'url': matchedItem['url'] ?? '',
// // // //       'type': matchedItem['type'] ?? '',
// // // //       'banner': matchedItem['banner'] ?? '',
// // // //       'name': matchedItem['name'] ?? '',
// // // //       'stream_type': matchedItem['stream_type'] ?? '',
// // // //     };
// // // //   } catch (e) {
// // // //     throw Exception('Something went wrong: $e');
// // // //   }
// // // // }

// // // // Future<List<dynamic>> fetchBannersData() async {
// // // //   Map<String, String> headers = await getAuthHeaders();
// // // //   bool success = false;
// // // //   String responseBody = '';

// // // //   for (int i = 0; i < ApiConfig.BANNER_ENDPOINTS.length; i++) {
// // // //     String endpoint = ApiConfig.BANNER_ENDPOINTS[i];

// // // //     try {
// // // //       Map<String, String> currentHeaders = Map.from(headers);

// // // //       if (endpoint.contains('api.ekomflix.com')) {
// // // //         currentHeaders = {
// // // //           'x-api-key': 'vLQTuPZUxktl5mVW',
// // // //           'Accept': 'application/json',
// // // //         };
// // // //       }

// // // //       final response = await https
// // // //           .get(
// // // //             Uri.parse(endpoint),
// // // //             headers: currentHeaders,
// // // //           )
// // // //           .timeout(Duration(seconds: 15));

// // // //       if (response.statusCode == 200) {
// // // //         String body = response.body.trim();
// // // //         if (body.startsWith('[') || body.startsWith('{')) {
// // // //           try {
// // // //             json.decode(body);
// // // //             responseBody = body;
// // // //             success = true;
// // // //             break;
// // // //           } catch (e) {
// // // //             continue;
// // // //           }
// // // //         } else {
// // // //           continue;
// // // //         }
// // // //       } else {
// // // //         continue;
// // // //       }
// // // //     } catch (e) {
// // // //       continue;
// // // //     }
// // // //   }

// // // //   if (!success) {
// // // //     throw Exception('Failed to load banners from all endpoints');
// // // //   }

// // // //   final List<dynamic> responseData = json.decode(responseBody);

// // // //   return responseData;
// // // // }

// // // // class GlobalEventBus {
// // // //   static final GlobalEventBus _instance = GlobalEventBus._internal();
// // // //   factory GlobalEventBus() => _instance;

// // // //   final StreamController<RefreshPageEvent> _controller =
// // // //       StreamController<RefreshPageEvent>.broadcast();

// // // //   GlobalEventBus._internal();

// // // //   Stream<RefreshPageEvent> get events => _controller.stream;
// // // //   void fire(RefreshPageEvent event) => _controller.add(event);
// // // //   void dispose() => _controller.close();
// // // // }

// // // // class RefreshPageEvent {
// // // //   final String pageId;

// // // //   RefreshPageEvent(this.pageId);
// // // // }

// // // // class BannerSlider extends StatefulWidget {
// // // //   final Function(bool)? onFocusChange;
// // // //   const BannerSlider(
// // // //       {Key? key, this.onFocusChange, required FocusNode focusNode})
// // // //       : super(key: key);
// // // //   @override
// // // //   _BannerSliderState createState() => _BannerSliderState();
// // // // }

// // // // class _BannerSliderState extends State<BannerSlider>
// // // //     with SingleTickerProviderStateMixin {
// // // //   // late SharedDataProvider sharedDataProvider;
// // // //   final SocketService _socketService = SocketService();
// // // //   List<NewsItemModel> bannerList = [];
// // // //   Map<String, Color> bannerColors = {};
// // // //   bool isLoading = true;
// // // //   String errorMessage = '';
// // // //   late PageController _pageController;
// // // //   late Timer _timer;
// // // //   String? selectedContentId;
// // // //   final FocusNode _buttonFocusNode = FocusNode();
// // // //   bool _isNavigating = false;
// // // //   final int _maxRetries = 3;
// // // //   final int _retryDelay = 5;
// // // //   final PaletteColorService _paletteColorService = PaletteColorService();

// // // //   Map<String, Uint8List> _bannerCache = {};
// // // //   late FocusProvider _refreshProvider;
// // // //   final ImageCacheService _imageCacheService = ImageCacheService();

// // // //   // 🌟 NEW: Animation controllers for shimmer effect
// // // //   late AnimationController _shimmerController;
// // // //   late Animation<double> _shimmerAnimation;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();

// // // //     // 🌟 Initialize shimmer animation
// // // //     _shimmerController = AnimationController(
// // // //       duration: const Duration(milliseconds: 1500),
// // // //       vsync: this,
// // // //     )..repeat();

// // // //     _shimmerAnimation = Tween<double>(
// // // //       begin: -1.0,
// // // //       end: 2.0,
// // // //     ).animate(CurvedAnimation(
// // // //       parent: _shimmerController,
// // // //       curve: Curves.easeInOut,
// // // //     ));

// // // //     _initializeSlider();
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _pageController.dispose();
// // // //     _socketService.dispose();

// // // //     // 🌟 Dispose shimmer controller
// // // //     _shimmerController.dispose();

// // // //     if (_timer.isActive) {
// // // //       _timer.cancel();
// // // //     }

// // // //     _buttonFocusNode.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Consumer<FocusProvider>(
// // // //       builder: (context, focusProvider, child) {
// // // //         return Scaffold(
// // // //           backgroundColor: cardColor,
// // // //           body: isLoading
// // // //               ? Center(
// // // //                   child: Column(
// // // //                     mainAxisAlignment: MainAxisAlignment.center,
// // // //                     children: [
// // // //                       SpinKitFadingCircle(color: borderColor, size: 50.0),
// // // //                       SizedBox(height: 20),
// // // //                       Text(
// // // //                         '...',
// // // //                         style: TextStyle(
// // // //                           color: hintColor,
// // // //                           fontSize: nametextsz,
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 )
// // // //               : errorMessage.isNotEmpty
// // // //                   ? Center(
// // // //                       child: Column(
// // // //                         mainAxisAlignment: MainAxisAlignment.center,
// // // //                         children: [
// // // //                           Icon(
// // // //                             Icons.error_outline,
// // // //                             color: Colors.red,
// // // //                             size: 50,
// // // //                           ),
// // // //                           SizedBox(height: 20),
// // // //                           Text(
// // // //                             'Something Went Wrong',
// // // //                             style: TextStyle(
// // // //                               fontSize: menutextsz,
// // // //                               color: Colors.red,
// // // //                               fontWeight: FontWeight.bold,
// // // //                             ),
// // // //                           ),
// // // //                           SizedBox(height: 10),
// // // //                           Padding(
// // // //                             padding: EdgeInsets.symmetric(horizontal: 20),
// // // //                             child: Text(
// // // //                               errorMessage,
// // // //                               style: TextStyle(
// // // //                                 fontSize: minitextsz,
// // // //                                 color: hintColor,
// // // //                               ),
// // // //                               textAlign: TextAlign.center,
// // // //                             ),
// // // //                           ),
// // // //                           SizedBox(height: 20),
// // // //                           ElevatedButton(
// // // //                             onPressed: () => fetchBanners(),
// // // //                             child: Text('Retry'),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                     )
// // // //                   : bannerList.isEmpty
// // // //                       ? Center(
// // // //                           child: Column(
// // // //                             mainAxisAlignment: MainAxisAlignment.center,
// // // //                             children: [
// // // //                               Icon(
// // // //                                 Icons.image_not_supported,
// // // //                                 color: hintColor.withOpacity(0.5),
// // // //                                 size: 50,
// // // //                               ),
// // // //                               SizedBox(height: 20),
// // // //                               Text(
// // // //                                 '',
// // // //                                 style: TextStyle(
// // // //                                   color: hintColor,
// // // //                                   fontSize: nametextsz,
// // // //                                 ),
// // // //                               ),
// // // //                             ],
// // // //                           ),
// // // //                         )
// // // //                       : Stack(
// // // //                           children: [
// // // //                             PageView.builder(
// // // //                               controller: _pageController,
// // // //                               itemCount: bannerList.length,
// // // //                               onPageChanged: (index) {
// // // //                                 if (mounted) {
// // // //                                   setState(() {
// // // //                                     selectedContentId =
// // // //                                         bannerList[index].contentId.toString();
// // // //                                   });
// // // //                                 }
// // // //                               },
// // // //                               itemBuilder: (context, index) {
// // // //                                 final banner = bannerList[index];
// // // //                                 return Stack(
// // // //                                   alignment: AlignmentDirectional.topCenter,
// // // //                                   children: [
// // // //                                     // 🌟 Main banner image with shimmer
// // // //                                     _buildBannerWithShimmer(
// // // //                                         banner, focusProvider),

// // // //                                     // Gradient overlay
// // // //                                     Container(
// // // //                                       margin: const EdgeInsets.only(top: 1),
// // // //                                       width: screenwdt,
// // // //                                       height: screenhgt,
// // // //                                       decoration: BoxDecoration(
// // // //                                         gradient: LinearGradient(
// // // //                                           begin: Alignment.topCenter,
// // // //                                           end: Alignment.bottomCenter,
// // // //                                           colors: [
// // // //                                             Colors.black.withOpacity(0.3),
// // // //                                             Colors.transparent,
// // // //                                             Colors.black.withOpacity(0.7),
// // // //                                           ],
// // // //                                           stops: [0.0, 0.5, 1.0],
// // // //                                         ),
// // // //                                       ),
// // // //                                     ),
// // // //                                   ],
// // // //                                 );
// // // //                               },
// // // //                             ),

// // // //                             // Watch Now Button with enhanced styling
// // // //                             Positioned(
// // // //                               top: screenhgt * 0.03,
// // // //                               left: screenwdt * 0.02,
// // // //                               child: Focus(
// // // //                                 focusNode: _buttonFocusNode,
// // // //                                 onKeyEvent: (node, event) {
// // // //                                   if (event.logicalKey ==
// // // //                                       LogicalKeyboardKey.arrowRight) {
// // // //                                     if (_pageController.hasClients &&
// // // //                                         _pageController.page != null &&
// // // //                                         _pageController.page! <
// // // //                                             bannerList.length - 1) {
// // // //                                       _pageController.nextPage(
// // // //                                         duration: Duration(milliseconds: 300),
// // // //                                         curve: Curves.easeInOut,
// // // //                                       );
// // // //                                       return KeyEventResult.handled;
// // // //                                     }
// // // //                                   } else if (event.logicalKey ==
// // // //                                       LogicalKeyboardKey.arrowLeft) {
// // // //                                     if (_pageController.hasClients &&
// // // //                                         _pageController.page != null &&
// // // //                                         _pageController.page! > 0) {
// // // //                                       _pageController.previousPage(
// // // //                                         duration: Duration(milliseconds: 300),
// // // //                                         curve: Curves.easeInOut,
// // // //                                       );
// // // //                                       return KeyEventResult.handled;
// // // //                                     }
// // // //                                   } else if (event is KeyDownEvent) {
// // // //                                     if (event.logicalKey ==
// // // //                                             LogicalKeyboardKey.select ||
// // // //                                         event.logicalKey ==
// // // //                                             LogicalKeyboardKey.enter) {
// // // //                                       if (selectedContentId != null) {
// // // //                                         final banner = bannerList.firstWhere(
// // // //                                             (b) =>
// // // //                                                 b.contentId ==
// // // //                                                 selectedContentId);
// // // //                                         fetchAndPlayVideo(
// // // //                                             banner.id, bannerList);
// // // //                                       }
// // // //                                       return KeyEventResult.handled;
// // // //                                     }
// // // //                                   }
// // // //                                   return KeyEventResult.ignored;
// // // //                                 },
// // // //                                 child: GestureDetector(
// // // //                                   onTap: () {
// // // //                                     if (selectedContentId != null) {
// // // //                                       final banner = bannerList.firstWhere(
// // // //                                           (b) =>
// // // //                                               b.contentId == selectedContentId);
// // // //                                       fetchAndPlayVideo(banner.id, bannerList);
// // // //                                     }
// // // //                                   },
// // // //                                   child: RandomLightColorWidget(
// // // //                                     hasFocus: focusProvider.isButtonFocused,
// // // //                                     childBuilder: (Color randomColor) {
// // // //                                       return AnimatedContainer(
// // // //                                         duration: Duration(milliseconds: 200),
// // // //                                         margin:
// // // //                                             EdgeInsets.all(screenwdt * 0.001),
// // // //                                         padding: EdgeInsets.symmetric(
// // // //                                           vertical: screenhgt * 0.02,
// // // //                                           horizontal: screenwdt * 0.02,
// // // //                                         ),
// // // //                                         decoration: BoxDecoration(
// // // //                                           color: focusProvider.isButtonFocused
// // // //                                               ? Colors.black87
// // // //                                               : Colors.black.withOpacity(0.6),
// // // //                                           borderRadius:
// // // //                                               BorderRadius.circular(12),
// // // //                                           border: Border.all(
// // // //                                             color: focusProvider.isButtonFocused
// // // //                                                 ? focusProvider
// // // //                                                         .currentFocusColor ??
// // // //                                                     randomColor
// // // //                                                 : Colors.white.withOpacity(0.3),
// // // //                                             width: focusProvider.isButtonFocused
// // // //                                                 ? 3.0
// // // //                                                 : 1.0,
// // // //                                           ),
// // // //                                           boxShadow:
// // // //                                               focusProvider.isButtonFocused
// // // //                                                   ? [
// // // //                                                       BoxShadow(
// // // //                                                         color: (focusProvider
// // // //                                                                     .currentFocusColor ??
// // // //                                                                 randomColor)
// // // //                                                             .withOpacity(0.5),
// // // //                                                         blurRadius: 20.0,
// // // //                                                         spreadRadius: 5.0,
// // // //                                                       ),
// // // //                                                     ]
// // // //                                                   : [
// // // //                                                       BoxShadow(
// // // //                                                         color: Colors.black
// // // //                                                             .withOpacity(0.3),
// // // //                                                         blurRadius: 10.0,
// // // //                                                         spreadRadius: 2.0,
// // // //                                                       ),
// // // //                                                     ],
// // // //                                         ),
// // // //                                         child: Row(
// // // //                                           mainAxisSize: MainAxisSize.min,
// // // //                                           children: [
// // // //                                             Icon(
// // // //                                               Icons.play_arrow,
// // // //                                               color: focusProvider
// // // //                                                       .isButtonFocused
// // // //                                                   ? focusProvider
// // // //                                                           .currentFocusColor ??
// // // //                                                       randomColor
// // // //                                                   : hintColor,
// // // //                                               size: menutextsz * 1.2,
// // // //                                             ),
// // // //                                             SizedBox(width: 8),
// // // //                                             Text(
// // // //                                               'Watch Now',
// // // //                                               style: TextStyle(
// // // //                                                 fontSize: menutextsz,
// // // //                                                 color: focusProvider
// // // //                                                         .isButtonFocused
// // // //                                                     ? focusProvider
// // // //                                                             .currentFocusColor ??
// // // //                                                         randomColor
// // // //                                                     : hintColor,
// // // //                                                 fontWeight: FontWeight.bold,
// // // //                                               ),
// // // //                                             ),
// // // //                                           ],
// // // //                                         ),
// // // //                                       );
// // // //                                     },
// // // //                                   ),
// // // //                                 ),
// // // //                               ),
// // // //                             ),

// // // //                             // Page indicators
// // // //                             if (bannerList.length > 1)
// // // //                               Positioned(
// // // //                                 top: screenhgt * 0.05,
// // // //                                 right: screenwdt * 0.05,
// // // //                                 child: Row(
// // // //                                   mainAxisAlignment: MainAxisAlignment.center,
// // // //                                   children:
// // // //                                       bannerList.asMap().entries.map((entry) {
// // // //                                     int index = entry.key;
// // // //                                     bool isSelected = selectedContentId ==
// // // //                                         bannerList[index].contentId;

// // // //                                     return AnimatedContainer(
// // // //                                       duration: Duration(milliseconds: 300),
// // // //                                       margin:
// // // //                                           EdgeInsets.symmetric(horizontal: 4),
// // // //                                       width: isSelected ? 12 : 8,
// // // //                                       height: isSelected ? 12 : 8,
// // // //                                       decoration: BoxDecoration(
// // // //                                         color: isSelected
// // // //                                             ? Colors.white
// // // //                                             : Colors.white.withOpacity(0.5),
// // // //                                         shape: BoxShape.circle,
// // // //                                         boxShadow: [
// // // //                                           BoxShadow(
// // // //                                             color:
// // // //                                                 Colors.black.withOpacity(0.3),
// // // //                                             blurRadius: 4,
// // // //                                             spreadRadius: 1,
// // // //                                           ),
// // // //                                         ],
// // // //                                       ),
// // // //                                     );
// // // //                                   }).toList(),
// // // //                                 ),
// // // //                               ),
// // // //                           ],
// // // //                         ),
// // // //         );
// // // //       },
// // // //     );
// // // //   }

// // // //   // 🌟 NEW: Build banner with shimmer effect
// // // //   Widget _buildBannerWithShimmer(
// // // //       NewsItemModel banner, FocusProvider focusProvider) {
// // // //     return Container(
// // // //       margin: const EdgeInsets.only(top: 1),
// // // //       width: screenwdt,
// // // //       height: screenhgt,
// // // //       child: Stack(
// // // //         children: [
// // // //           // Main banner image
// // // //           CachedNetworkImage(
// // // //             imageUrl: banner.banner,
// // // //             fit: BoxFit.fill,
// // // //             placeholder: (context, url) => Image.asset('assets/streamstarting.gif'),
// // // //             errorWidget: (context, url, error) =>
// // // //                 Image.asset('assets/streamstarting.gif'),
// // // //             cacheKey: banner.contentId,
// // // //             fadeInDuration: Duration(milliseconds: 500),
// // // //             memCacheHeight: 800,
// // // //             memCacheWidth: 1200,
// // // //             width: screenwdt,
// // // //             height: screenhgt,
// // // //           ),

// // // //           // 🌟 Shimmer effect overlay
// // // //           if (focusProvider.isButtonFocused)
// // // //             AnimatedBuilder(
// // // //               animation: _shimmerAnimation,
// // // //               builder: (context, child) {
// // // //                 return Positioned.fill(
// // // //                   child: Container(
// // // //                     decoration: BoxDecoration(
// // // //                       gradient: LinearGradient(
// // // //                         begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
// // // //                         end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
// // // //                         colors: [
// // // //                           Colors.transparent,
// // // //                           Colors.white.withOpacity(0.1),
// // // //                           Colors.white.withOpacity(0.2),
// // // //                           Colors.white.withOpacity(0.1),
// // // //                           Colors.transparent,
// // // //                         ],
// // // //                         stops: [0.0, 0.3, 0.5, 0.7, 1.0],
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 );
// // // //               },
// // // //             ),

// // // //           // 🌟 Enhanced glow effect when focused
// // // //           if (focusProvider.isButtonFocused)
// // // //             Positioned.fill(
// // // //               child: Container(
// // // //                 decoration: BoxDecoration(
// // // //                   gradient: RadialGradient(
// // // //                     center: Alignment.center,
// // // //                     radius: 0.8,
// // // //                     colors: [
// // // //                       (focusProvider.currentFocusColor ?? Colors.blue)
// // // //                           .withOpacity(0.1),
// // // //                       Colors.transparent,
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ),

// // // //           // 🌟 Border glow effect
// // // //           if (focusProvider.isButtonFocused)
// // // //             Positioned.fill(
// // // //               child: Container(
// // // //                 decoration: BoxDecoration(
// // // //                   border: Border.all(
// // // //                     color: (focusProvider.currentFocusColor ?? Colors.blue)
// // // //                         .withOpacity(0.3),
// // // //                     width: 2.0,
// // // //                   ),
// // // //                   borderRadius: BorderRadius.circular(8),
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   // 🌟 Alternative shimmer effect method (more subtle)
// // // //   Widget _buildSubtleShimmer(
// // // //       NewsItemModel banner, FocusProvider focusProvider) {
// // // //     return Container(
// // // //       margin: const EdgeInsets.only(top: 1),
// // // //       width: screenwdt,
// // // //       height: screenhgt,
// // // //       child: Stack(
// // // //         children: [
// // // //           // Main image
// // // //           CachedNetworkImage(
// // // //             imageUrl: banner.banner,
// // // //             fit: BoxFit.fill,
// // // //             placeholder: (context, url) => Image.asset('assets/streamstarting.gif'),
// // // //             errorWidget: (context, url, error) =>
// // // //                 Image.asset('assets/streamstarting.gif'),
// // // //             cacheKey: banner.contentId,
// // // //             fadeInDuration: Duration(milliseconds: 500),
// // // //             memCacheHeight: 800,
// // // //             memCacheWidth: 1200,
// // // //           ),

// // // //           // Subtle shimmer when focused
// // // //           if (focusProvider.isButtonFocused)
// // // //             AnimatedBuilder(
// // // //               animation: _shimmerAnimation,
// // // //               builder: (context, child) {
// // // //                 return Positioned.fill(
// // // //                   child: Container(
// // // //                     decoration: BoxDecoration(
// // // //                       gradient: LinearGradient(
// // // //                         begin: Alignment.topLeft,
// // // //                         end: Alignment.bottomRight,
// // // //                         colors: [
// // // //                           Colors.transparent,
// // // //                           Colors.white.withOpacity(0.05),
// // // //                           Colors.transparent,
// // // //                         ],
// // // //                         stops: [
// // // //                           (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
// // // //                           _shimmerAnimation.value.clamp(0.0, 1.0),
// // // //                           (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
// // // //                         ],
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 );
// // // //               },
// // // //             ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   // 🌟 Professional shimmer effect (SubVod style)
// // // //   Widget _buildProfessionalShimmer(
// // // //       NewsItemModel banner, FocusProvider focusProvider) {
// // // //     return Container(
// // // //       margin: const EdgeInsets.only(top: 1),
// // // //       width: screenwdt,
// // // //       height: screenhgt,
// // // //       child: Stack(
// // // //         children: [
// // // //           // Main banner image
// // // //           CachedNetworkImage(
// // // //             imageUrl: banner.banner,
// // // //             fit: BoxFit.fill,
// // // //             placeholder: (context, url) => Image.asset('assets/streamstarting.gif'),
// // // //             errorWidget: (context, url, error) =>
// // // //                 Image.asset('assets/streamstarting.gif'),
// // // //             cacheKey: banner.contentId,
// // // //             fadeInDuration: Duration(milliseconds: 500),
// // // //             memCacheHeight: 800,
// // // //             memCacheWidth: 1200,
// // // //           ),

// // // //           // Professional shimmer effect (same as SubVod)
// // // //           if (focusProvider.isButtonFocused)
// // // //             AnimatedBuilder(
// // // //               animation: _shimmerAnimation,
// // // //               builder: (context, child) {
// // // //                 return Positioned.fill(
// // // //                   child: Container(
// // // //                     decoration: BoxDecoration(
// // // //                       borderRadius: BorderRadius.circular(8),
// // // //                       gradient: LinearGradient(
// // // //                         begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
// // // //                         end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
// // // //                         colors: [
// // // //                           Colors.transparent,
// // // //                           (focusProvider.currentFocusColor ?? Colors.blue)
// // // //                               .withOpacity(0.15),
// // // //                           Colors.transparent,
// // // //                         ],
// // // //                         stops: [0.0, 0.5, 1.0],
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 );
// // // //               },
// // // //             ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   // @override
// // // //   // void initState() {
// // // //   //   super.initState();
// // // //   //   _initializeSlider();
// // // //   // }

// // // //   Future<void> _initializeSlider() async {
// // // //     // Initialize image cache service first
// // // //     await _imageCacheService.init();

// // // //     // sharedDataProvider = context.read<SharedDataProvider>();

// // // //     _socketService.initSocket();
// // // //     _pageController = PageController();

// // // //     _buttonFocusNode.addListener(() {
// // // //       if (_buttonFocusNode.hasFocus) {
// // // //         widget.onFocusChange?.call(true);
// // // //       }
// // // //     });

// // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //       context.read<FocusProvider>().setWatchNowFocusNode(_buttonFocusNode);
// // // //     });

// // // //     _buttonFocusNode.addListener(_onButtonFocusNode);

// // // //     await _loadCachedData();

// // // //     if (bannerList.isNotEmpty) {
// // // //       _startAutoSlide();
// // // //       // Preload images for better performance
// // // //       _preloadImages();
// // // //     }
// // // //   }

// // // //   // Preload images in background for smooth experience
// // // //   Future<void> _preloadImages() async {
// // // //     for (final banner in bannerList) {
// // // //       try {
// // // //         // Check if already cached
// // // //         final isCached = await _imageCacheService.isCached(banner.banner);

// // // //         if (!isCached) {
// // // //           // Download in background without blocking UI
// // // //           _imageCacheService
// // // //               .downloadAndCacheImage(banner.banner)
// // // //               .catchError((e) {
// // // //             print('Failed to preload image: ${banner.banner}');
// // // //           });
// // // //         }
// // // //       } catch (e) {
// // // //         print('Error preloading image: $e');
// // // //       }
// // // //     }
// // // //   }

// // // //   // Enhanced fetchBanners with image preloading
// // // //   Future<void> fetchBanners({bool isBackgroundFetch = false}) async {
// // // //     if (!isBackgroundFetch) {
// // // //       setState(() {
// // // //         isLoading = true;
// // // //         errorMessage = '';
// // // //       });
// // // //     }

// // // //     try {
// // // //       final prefs = await SharedPreferences.getInstance();
// // // //       final cachedBanners = prefs.getString('banners');

// // // //       final List<dynamic> responseData = await fetchBannersData();

// // // //       if (cachedBanners != null) {
// // // //         try {
// // // //           final cachedData = json.decode(cachedBanners);
// // // //           if (json.encode(cachedData) == json.encode(responseData)) {
// // // //             // Data hasn't changed, but still preload any missing images
// // // //             if (!isBackgroundFetch) {
// // // //               setState(() => isLoading = false);
// // // //             }
// // // //             _preloadImages();
// // // //             return;
// // // //           }
// // // //         } catch (e) {}
// // // //       }

// // // //       List<NewsItemModel> filteredBanners = [];

// // // //       for (var banner in responseData) {
// // // //         try {
// // // //           bool isActive = false;

// // // //           if (banner['status'] != null) {
// // // //             var status = banner['status'];

// // // //             if (status is String) {
// // // //               isActive = status == "1" ||
// // // //                   status.toLowerCase() == "active" ||
// // // //                   status.toLowerCase() == "true";
// // // //             } else if (status is int) {
// // // //               isActive = status == 1;
// // // //             } else if (status is bool) {
// // // //               isActive = status;
// // // //             }
// // // //           } else {
// // // //             isActive = true;
// // // //           }

// // // //           if (isActive) {
// // // //             try {
// // // //               final newsItem = NewsItemModel.fromJson(banner);
// // // //               filteredBanners.add(newsItem);
// // // //             } catch (e) {}
// // // //           }
// // // //         } catch (e) {}
// // // //       }

// // // //       setState(() {
// // // //         bannerList = filteredBanners;
// // // //         selectedContentId = bannerList.isNotEmpty ? bannerList[0].id : null;
// // // //         isLoading = false;
// // // //         errorMessage = '';
// // // //       });

// // // //       await prefs.setString('banners', json.encode(responseData));

// // // //       if (bannerList.isNotEmpty) {
// // // //         await _fetchBannerColors();
// // // //         if (!_timer.isActive) {
// // // //           _startAutoSlide();
// // // //         }
// // // //         // Preload images after successful fetch
// // // //         _preloadImages();
// // // //       }
// // // //     } catch (e) {
// // // //       if (!isBackgroundFetch) {
// // // //         setState(() {
// // // //           errorMessage = 'Failed to load banners: $e';
// // // //           isLoading = false;
// // // //         });
// // // //       }
// // // //     }
// // // //   }

// // // //   // Add cache management methods
// // // //   Future<void> clearImageCache() async {
// // // //     try {
// // // //       await _imageCacheService.clearCache();
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         SnackBar(
// // // //           content: Text('Image cache cleared successfully'),
// // // //           backgroundColor: Colors.green,
// // // //         ),
// // // //       );
// // // //     } catch (e) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         SnackBar(
// // // //           content: Text('Failed to clear cache: $e'),
// // // //           backgroundColor: Colors.red,
// // // //         ),
// // // //       );
// // // //     }
// // // //   }

// // // //   Future<void> showCacheInfo() async {
// // // //     try {
// // // //       final stats = await _imageCacheService.getCacheStats();

// // // //       showDialog(
// // // //         context: context,
// // // //         builder: (BuildContext context) {
// // // //           return AlertDialog(
// // // //             title: Text('Cache Information'),
// // // //             content: Column(
// // // //               mainAxisSize: MainAxisSize.min,
// // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // //               children: [
// // // //                 Text('Total cached files: ${stats.totalFiles}'),
// // // //                 Text('Cache size: ${stats.totalSizeMB.toStringAsFixed(2)} MB'),
// // // //                 SizedBox(height: 10),
// // // //                 Text(
// // // //                   'Cache helps load images faster and reduces data usage.',
// // // //                   style: TextStyle(fontSize: 12, color: Colors.grey),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             actions: [
// // // //               TextButton(
// // // //                 onPressed: () => Navigator.of(context).pop(),
// // // //                 child: Text('OK'),
// // // //               ),
// // // //               TextButton(
// // // //                 onPressed: () {
// // // //                   Navigator.of(context).pop();
// // // //                   clearImageCache();
// // // //                 },
// // // //                 child: Text('Clear Cache'),
// // // //               ),
// // // //             ],
// // // //           );
// // // //         },
// // // //       );
// // // //     } catch (e) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         SnackBar(
// // // //           content: Text('Failed to get cache info: $e'),
// // // //           backgroundColor: Colors.red,
// // // //         ),
// // // //       );
// // // //     }
// // // //   }

// // // //   // @override
// // // //   // void dispose() {
// // // //   //   _pageController.dispose();
// // // //   //   _socketService.dispose();

// // // //   //   if (_timer.isActive) {
// // // //   //     _timer.cancel();
// // // //   //   }

// // // //   //   _buttonFocusNode.dispose();

// // // //   //   super.dispose();
// // // //   // }

// // // //   // Enhanced _loadCachedData with image cache check
// // // //   Future<void> _loadCachedData() async {
// // // //     final prefs = await SharedPreferences.getInstance();
// // // //     final cachedBanners = prefs.getString('banners');

// // // //     if (cachedBanners != null) {
// // // //       try {
// // // //         final List<dynamic> responseData = json.decode(cachedBanners);

// // // //         List<NewsItemModel> filteredBanners = [];

// // // //         for (var banner in responseData) {
// // // //           try {
// // // //             bool isActive = false;

// // // //             if (banner['status'] != null) {
// // // //               var status = banner['status'];

// // // //               if (status is String) {
// // // //                 isActive = status == "1" ||
// // // //                     status.toLowerCase() == "active" ||
// // // //                     status.toLowerCase() == "true";
// // // //               } else if (status is int) {
// // // //                 isActive = status == 1;
// // // //               } else if (status is bool) {
// // // //                 isActive = status;
// // // //               }
// // // //             } else {
// // // //               isActive = true;
// // // //             }

// // // //             if (isActive) {
// // // //               try {
// // // //                 final newsItem = NewsItemModel.fromJson(banner);
// // // //                 filteredBanners.add(newsItem);
// // // //               } catch (e) {}
// // // //             }
// // // //           } catch (e) {}
// // // //         }

// // // //         setState(() {
// // // //           bannerList = filteredBanners;
// // // //           selectedContentId = bannerList.isNotEmpty ? bannerList[0].id : null;
// // // //           isLoading = false;
// // // //         });

// // // //         if (bannerList.isNotEmpty) {
// // // //           await _fetchBannerColors();
// // // //           // Check which images are cached and preload missing ones
// // // //           _preloadImages();
// // // //         }
// // // //       } catch (e) {
// // // //         setState(() => isLoading = false);
// // // //       }
// // // //     } else {
// // // //       setState(() => isLoading = false);
// // // //     }

// // // //     // Fetch fresh data in background
// // // //     fetchBanners(isBackgroundFetch: true);
// // // //   }

// // // //   // Future<void> _initializeSlider() async {
// // // //   //   sharedDataProvider = context.read<SharedDataProvider>();

// // // //   //   _socketService.initSocket();
// // // //   //   _pageController = PageController();

// // // //   //   _buttonFocusNode.addListener(() {
// // // //   //     if (_buttonFocusNode.hasFocus) {
// // // //   //       widget.onFocusChange?.call(true);
// // // //   //     }
// // // //   //   });

// // // //   //   WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //   //     context.read<FocusProvider>().setWatchNowFocusNode(_buttonFocusNode);
// // // //   //   });

// // // //   //   _buttonFocusNode.addListener(_onButtonFocusNode);

// // // //   //   await _loadCachedData();

// // // //   //   if (bannerList.isNotEmpty) {
// // // //   //     _startAutoSlide();
// // // //   //   }
// // // //   // }

// // // //   @override
// // // //   void didChangeDependencies() {
// // // //     super.didChangeDependencies();

// // // //     _refreshProvider = context.watch<FocusProvider>();

// // // //     if (_refreshProvider.shouldRefreshBanners ||
// // // //         _refreshProvider.shouldRefreshLastPlayed) {
// // // //       _handleProviderRefresh();
// // // //     }
// // // //   }

// // // //   Future<void> _handleProviderRefresh() async {
// // // //     if (!mounted) return;

// // // //     try {
// // // //       if (_refreshProvider.shouldRefreshBanners) {
// // // //         await fetchBanners(isBackgroundFetch: true);
// // // //         _refreshProvider.markBannersRefreshed();
// // // //       }
// // // //     } catch (e) {}
// // // //   }

// // // //   // @override
// // // //   // void dispose() {
// // // //   //   _pageController.dispose();
// // // //   //   _socketService.dispose();

// // // //   //   if (_timer.isActive) {
// // // //   //     _timer.cancel();
// // // //   //   }

// // // //   //   _buttonFocusNode.dispose();

// // // //   //   super.dispose();
// // // //   // }

// // // //   Future<void> _fetchBannerColors() async {
// // // //     for (var banner in bannerList) {
// // // //       try {
// // // //         final imageUrl = banner.banner;
// // // //         final secondaryColor =
// // // //             await _paletteColorService.getSecondaryColor(imageUrl);

// // // //         if (mounted) {
// // // //           setState(() {
// // // //             bannerColors[banner.contentId] = secondaryColor;
// // // //           });
// // // //         }
// // // //       } catch (e) {}
// // // //     }
// // // //   }

// // // //   void _startAutoSlide() {
// // // //     if (bannerList.isNotEmpty) {
// // // //       _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
// // // //         if (!mounted) {
// // // //           timer.cancel();
// // // //           return;
// // // //         }

// // // //         try {
// // // //           if (_pageController.hasClients) {
// // // //             if (_pageController.page == bannerList.length - 1) {
// // // //               _pageController.jumpToPage(0);
// // // //             } else {
// // // //               _pageController.nextPage(
// // // //                 duration: const Duration(milliseconds: 300),
// // // //                 curve: Curves.easeIn,
// // // //               );
// // // //             }
// // // //           }
// // // //         } catch (e) {}
// // // //       });
// // // //     }
// // // //   }

// // // //   bool isYoutubeUrl(String? url) {
// // // //     if (url == null || url.isEmpty) {
// // // //       return false;
// // // //     }

// // // //     url = url.toLowerCase().trim();

// // // //     bool isYoutubeId = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url);
// // // //     if (isYoutubeId) {
// // // //       return true;
// // // //     }

// // // //     bool isYoutubeUrl = url.contains('youtube.com') ||
// // // //         url.contains('youtu.be') ||
// // // //         url.contains('youtube.com/shorts/');

// // // //     return isYoutubeUrl;
// // // //   }

// // // //   String formatUrl(String url, {Map<String, String>? params}) {
// // // //     if (url.isEmpty) {
// // // //       throw Exception("Empty URL provided");
// // // //     }

// // // //     return url;
// // // //   }

// // // //   void _onButtonFocusNode() {
// // // //     if (_buttonFocusNode.hasFocus) {
// // // //       final random = Random();
// // // //       final color = Color.fromRGBO(
// // // //         random.nextInt(256),
// // // //         random.nextInt(256),
// // // //         random.nextInt(256),
// // // //         1,
// // // //       );
// // // //       context.read<FocusProvider>().setButtonFocus(true, color: color);
// // // //       context.read<ColorProvider>().updateColor(color, true);
// // // //     } else {
// // // //       context.read<FocusProvider>().resetFocus();
// // // //       context.read<ColorProvider>().resetColor();
// // // //     }
// // // //   }

// // // //   // Future<void> fetchBanners({bool isBackgroundFetch = false}) async {
// // // //   //   if (!isBackgroundFetch) {
// // // //   //     setState(() {
// // // //   //       isLoading = true;
// // // //   //       errorMessage = '';
// // // //   //     });
// // // //   //   }

// // // //   //   try {
// // // //   //     final prefs = await SharedPreferences.getInstance();
// // // //   //     final cachedBanners = prefs.getString('banners');

// // // //   //     final List<dynamic> responseData = await fetchBannersData();

// // // //   //     for (int i = 0; i < responseData.length; i++) {
// // // //   //       final item = responseData[i];
// // // //   //     }

// // // //   //     if (cachedBanners != null) {
// // // //   //       try {
// // // //   //         final cachedData = json.decode(cachedBanners);
// // // //   //         if (json.encode(cachedData) == json.encode(responseData)) {
// // // //   //           return;
// // // //   //         }
// // // //   //       } catch (e) {}
// // // //   //     }

// // // //   //     List<NewsItemModel> filteredBanners = [];

// // // //   //     for (var banner in responseData) {
// // // //   //       try {
// // // //   //         bool isActive = false;

// // // //   //         if (banner['status'] != null) {
// // // //   //           var status = banner['status'];

// // // //   //           if (status is String) {
// // // //   //             isActive = status == "1" ||
// // // //   //                 status.toLowerCase() == "active" ||
// // // //   //                 status.toLowerCase() == "true";
// // // //   //           } else if (status is int) {
// // // //   //             isActive = status == 1;
// // // //   //           } else if (status is bool) {
// // // //   //             isActive = status;
// // // //   //           }
// // // //   //         } else {
// // // //   //           isActive = true;
// // // //   //         }

// // // //   //         if (isActive) {
// // // //   //           try {
// // // //   //             final newsItem = NewsItemModel.fromJson(banner);
// // // //   //             filteredBanners.add(newsItem);
// // // //   //           } catch (e) {}
// // // //   //         } else {}
// // // //   //       } catch (e) {}
// // // //   //     }

// // // //   //     setState(() {
// // // //   //       bannerList = filteredBanners;
// // // //   //       selectedContentId = bannerList.isNotEmpty ? bannerList[0].id : null;
// // // //   //       isLoading = false;
// // // //   //       errorMessage = '';
// // // //   //     });

// // // //   //     await prefs.setString('banners', json.encode(responseData));

// // // //   //     for (int i = 0; i < bannerList.length; i++) {
// // // //   //       final banner = bannerList[i];
// // // //   //     }

// // // //   //     if (bannerList.isNotEmpty) {
// // // //   //       await _fetchBannerColors();
// // // //   //       if (!_timer.isActive) {
// // // //   //         _startAutoSlide();
// // // //   //       }
// // // //   //     } else {}
// // // //   //   } catch (e) {
// // // //   //     if (!isBackgroundFetch) {
// // // //   //       setState(() {
// // // //   //         errorMessage = 'Failed to load banners: $e';
// // // //   //         isLoading = false;
// // // //   //       });
// // // //   //     }
// // // //   //   }
// // // //   // }

// // // //   // Future<void> _loadCachedData() async {
// // // //   //   final prefs = await SharedPreferences.getInstance();
// // // //   //   final cachedBanners = prefs.getString('banners');

// // // //   //   if (cachedBanners != null) {
// // // //   //     try {
// // // //   //       final List<dynamic> responseData = json.decode(cachedBanners);

// // // //   //       List<NewsItemModel> filteredBanners = [];

// // // //   //       for (var banner in responseData) {
// // // //   //         try {
// // // //   //           bool isActive = false;

// // // //   //           if (banner['status'] != null) {
// // // //   //             var status = banner['status'];

// // // //   //             if (status is String) {
// // // //   //               isActive = status == "1" ||
// // // //   //                   status.toLowerCase() == "active" ||
// // // //   //                   status.toLowerCase() == "true";
// // // //   //             } else if (status is int) {
// // // //   //               isActive = status == 1;
// // // //   //             } else if (status is bool) {
// // // //   //               isActive = status;
// // // //   //             }
// // // //   //           } else {
// // // //   //             isActive = true;
// // // //   //           }

// // // //   //           if (isActive) {
// // // //   //             try {
// // // //   //               final newsItem = NewsItemModel.fromJson(banner);
// // // //   //               filteredBanners.add(newsItem);
// // // //   //             } catch (e) {}
// // // //   //           }
// // // //   //         } catch (e) {}
// // // //   //       }

// // // //   //       setState(() {
// // // //   //         bannerList = filteredBanners;
// // // //   //         selectedContentId = bannerList.isNotEmpty ? bannerList[0].id : null;
// // // //   //         isLoading = false;
// // // //   //       });

// // // //   //       if (bannerList.isNotEmpty) {
// // // //   //         await _fetchBannerColors();
// // // //   //       }
// // // //   //     } catch (e) {
// // // //   //       setState(() => isLoading = false);
// // // //   //     }
// // // //   //   } else {
// // // //   //     setState(() => isLoading = false);
// // // //   //   }

// // // //   //   fetchBanners(isBackgroundFetch: true);
// // // //   // }

// // // //   Future<void> fetchAndPlayVideo(
// // // //       String contentId, List<NewsItemModel> channelList) async {
// // // //     if (_isNavigating) {
// // // //       return;
// // // //     }

// // // //     _isNavigating = true;

// // // //     bool shouldPlayVideo = true;
// // // //     bool shouldPop = true;

// // // //     try {
// // // //       showDialog(
// // // //         context: context,
// // // //         barrierDismissible: false,
// // // //         builder: (BuildContext context) {
// // // //           return WillPopScope(
// // // //             onWillPop: () async {
// // // //               shouldPlayVideo = false;
// // // //               shouldPop = false;
// // // //               return true;
// // // //             },
// // // //             child: Center(
// // // //               child: Container(
// // // //                 padding: EdgeInsets.all(20),
// // // //                 decoration: BoxDecoration(
// // // //                   color: Colors.black87,
// // // //                   borderRadius: BorderRadius.circular(10),
// // // //                 ),
// // // //                 child: Column(
// // // //                   mainAxisSize: MainAxisSize.min,
// // // //                   children: [
// // // //                     SpinKitFadingCircle(
// // // //                       color: borderColor,
// // // //                       size: 50.0,
// // // //                     ),
// // // //                     SizedBox(height: 15),
// // // //                     Text(
// // // //                       '',
// // // //                       style: TextStyle(
// // // //                         color: Colors.white,
// // // //                         fontSize: nametextsz,
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           );
// // // //         },
// // // //       );

// // // //       final responseData = await fetchVideoDataByIdFromBanners(contentId);

// // // //       if (shouldPop && context.mounted) {
// // // //         Navigator.of(context, rootNavigator: true).pop();
// // // //       }

// // // //       if (shouldPlayVideo && context.mounted) {
// // // //         Navigator.push(
// // // //           context,
// // // //           MaterialPageRoute(
// // // //             builder: (context) => VideoScreen(
// // // //               videoUrl: responseData['url'] ?? '',
// // // //               channelList: channelList,
// // // //               videoId: int.tryParse(contentId) ?? 0,
// // // //               videoType: responseData['type'] ?? '',
// // // //               isLive: true,
// // // //               isVOD: false,
// // // //               bannerImageUrl: responseData['banner'] ?? '',
// // // //               startAtPosition: Duration.zero,
// // // //               isBannerSlider: true,
// // // //               source: 'isBannerSlider',
// // // //               isSearch: false,
// // // //               unUpdatedUrl: responseData['url'] ?? '',
// // // //               name: responseData['name'] ?? '',
// // // //               liveStatus: true,
// // // //               seasonId: null,
// // // //               isLastPlayedStored: false,
// // // //             ),
// // // //           ),

// // // //           // builder: (context) => YouTubePlayerScreen(
// // // //           //   videoData: VideoData(
// // // //           //     id: contentId,
// // // //           //     title: responseData['name'] ?? '',
// // // //           //     youtubeUrl: responseData['url'] ?? '',
// // // //           //     thumbnail: responseData['banner'] ?? '',
// // // //           //   ),
// // // //           //   playlist: channelList
// // // //           //       .map((m) => VideoData(
// // // //           //             id: m.id,
// // // //           //             title: m.name,
// // // //           //             youtubeUrl: m.url,
// // // //           //             thumbnail: m.banner,
// // // //           //           ))
// // // //           //       .toList(),
// // // //           // ),
// // // //         );
// // // //       }
// // // //     } catch (e) {
// // // //       if (shouldPop && context.mounted) {
// // // //         Navigator.of(context, rootNavigator: true).pop();
// // // //       }

// // // //       if (context.mounted) {
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           SnackBar(
// // // //             content: Text('Something went wrong'),
// // // //             duration: Duration(seconds: 3),
// // // //             backgroundColor: Colors.red.shade700,
// // // //           ),
// // // //         );
// // // //       }
// // // //     } finally {
// // // //       _isNavigating = false;
// // // //     }
// // // //   }

// // // //   void _scrollToFocusedItem(int index) {
// // // //     // Remove this method as it's not needed anymore
// // // //   }

// // // //   Uint8List _getCachedImage(String base64String) {
// // // //     try {
// // // //       if (!_bannerCache.containsKey(base64String)) {
// // // //         final base64Content = base64String.split(',').last;
// // // //         _bannerCache[base64String] = base64Decode(base64Content);
// // // //       }
// // // //       return _bannerCache[base64String]!;
// // // //     } catch (e) {
// // // //       return Uint8List.fromList([
// // // //         0x89,
// // // //         0x50,
// // // //         0x4E,
// // // //         0x47,
// // // //         0x0D,
// // // //         0x0A,
// // // //         0x1A,
// // // //         0x0A,
// // // //         0x00,
// // // //         0x00,
// // // //         0x00,
// // // //         0x0D,
// // // //         0x49,
// // // //         0x48,
// // // //         0x44,
// // // //         0x52,
// // // //         0x00,
// // // //         0x00,
// // // //         0x00,
// // // //         0x01,
// // // //         0x00,
// // // //         0x00,
// // // //         0x00,
// // // //         0x01,
// // // //         0x08,
// // // //         0x02,
// // // //         0x00,
// // // //         0x00,
// // // //         0x00,
// // // //         0x90,
// // // //         0x77,
// // // //         0x53,
// // // //         0xDE,
// // // //         0x00,
// // // //         0x00,
// // // //         0x00,
// // // //         0x0C,
// // // //         0x49,
// // // //         0x44,
// // // //         0x41,
// // // //         0x54,
// // // //         0x78,
// // // //         0x01,
// // // //         0x63,
// // // //         0x00,
// // // //         0x01,
// // // //         0x00,
// // // //         0x05,
// // // //         0x00,
// // // //         0x01,
// // // //         0xE2,
// // // //         0x26,
// // // //         0x05,
// // // //         0x9B,
// // // //         0x00,
// // // //         0x00,
// // // //         0x00,
// // // //         0x00,
// // // //         0x49,
// // // //         0x45,
// // // //         0x4E,
// // // //         0x44,
// // // //         0xAE,
// // // //         0x42,
// // // //         0x60,
// // // //         0x82
// // // //       ]);
// // // //     }
// // // //   }

// // // //   bool isLiveVideoUrl(String url) {
// // // //     String lowerUrl = url.toLowerCase().trim();

// // // //     if (RegExp(r'^[a-zA-Z0-9_-]{10,15}$').hasMatch(lowerUrl)) {
// // // //       return false;
// // // //     }

// // // //     if (!lowerUrl.startsWith('http://') && !lowerUrl.startsWith('https://')) {
// // // //       return false;
// // // //     }

// // // //     if (lowerUrl.contains(".m3u8") ||
// // // //         lowerUrl.contains("live") ||
// // // //         lowerUrl.contains("stream") ||
// // // //         lowerUrl.contains("broadcast") ||
// // // //         lowerUrl.contains("playlist")) {
// // // //       return true;
// // // //     }

// // // //     List<String> videoExtensions = [".mp4", ".mov", ".avi", ".flv", ".mkv"];
// // // //     for (String ext in videoExtensions) {
// // // //       if (lowerUrl.endsWith(ext)) {
// // // //         return false;
// // // //       }
// // // //     }

// // // //     return false;
// // // //   }

// // // //   List<bool> checkLiveVideoList(List<String> urls) {
// // // //     return urls.map(isYoutubeUrl).toList();
// // // //   }

// // // //   String safeToString(dynamic value, {String defaultValue = ''}) {
// // // //     if (value == null) return defaultValue;
// // // //     return value.toString();
// // // //   }

// // // //   Widget _buildErrorImage() {
// // // //     return Container(
// // // //       color: Colors.grey.shade800,
// // // //       child: Image.asset(localImage),
// // // //     );
// // // //   }

// // // //   bool get isSliderReady =>
// // // //       !isLoading && errorMessage.isEmpty && bannerList.isNotEmpty;

// // // //   Map<String, dynamic>? get currentBannerInfo {
// // // //     if (selectedContentId == null || bannerList.isEmpty) return null;

// // // //     try {
// // // //       final banner = bannerList.firstWhere(
// // // //         (b) => b.contentId == selectedContentId,
// // // //         orElse: () => bannerList.first,
// // // //       );

// // // //       return {
// // // //         'id': banner.contentId,
// // // //         'name': banner.name,
// // // //         'banner': banner.banner,
// // // //         'url': banner.url,
// // // //         'type': banner.type,
// // // //       };
// // // //     } catch (e) {
// // // //       return null;
// // // //     }
// // // //   }
// // // // }

// // // // extension DurationExtension on Duration {
// // // //   String toHHMMSS() {
// // // //     String twoDigits(int n) => n.toString().padLeft(2, '0');
// // // //     String hours = inHours > 0 ? '${twoDigits(inHours)}:' : '';
// // // //     String minutes = twoDigits(inMinutes.remainder(60));
// // // //     String seconds = twoDigits(inSeconds.remainder(60));
// // // //     return '$hours$minutes:$seconds';
// // // //   }
// // // // }

// // // // class BannerSliderManager {
// // // //   static BannerSlider? _instance;

// // // //   static void setInstance(BannerSlider instance) {
// // // //     _instance = instance;
// // // //   }

// // // //   static BannerSlider? get instance => _instance;

// // // //   static void refreshBanners() {
// // // //     GlobalEventBus().fire(RefreshPageEvent('uniquePageId'));
// // // //   }

// // // //   static void clearInstance() {
// // // //     _instance = null;
// // // //   }
// // // // }

// // // // String formatAuthKey(String? key) {
// // // //   if (key == null || key.isEmpty) return '';

// // // //   key = key.trim();

// // // //   if (key.length < 10) {}

// // // //   return key;
// // // // }

// // // // Future<bool> checkEndpointHealth(String endpoint) async {
// // // //   try {
// // // //     final response =
// // // //         await https.head(Uri.parse(endpoint)).timeout(Duration(seconds: 5));
// // // //     return response.statusCode == 200 || response.statusCode == 405;
// // // //   } catch (e) {
// // // //     return false;
// // // //   }
// // // // }

// // // // Future<String> getBestApiEndpoint(List<String> endpoints) async {
// // // //   for (String endpoint in endpoints) {
// // // //     if (await checkEndpointHealth(endpoint)) {
// // // //       return endpoint;
// // // //     }
// // // //   }

// // // //   return endpoints.first;
// // // // }

// // // // Future<T> retryApiCall<T>(
// // // //   Future<T> Function() apiCall, {
// // // //   int maxRetries = 3,
// // // //   Duration delay = const Duration(seconds: 2),
// // // // }) async {
// // // //   for (int attempt = 1; attempt <= maxRetries; attempt++) {
// // // //     try {
// // // //       return await apiCall();
// // // //     } catch (e) {
// // // //       if (attempt == maxRetries) {
// // // //         rethrow;
// // // //       }

// // // //       await Future.delayed(delay);
// // // //     }
// // // //   }

// // // //   throw Exception('All retry attempts failed');
// // // // }

// // // // class CacheManager {
// // // //   static const String BANNER_CACHE_KEY = 'banners';
// // // //   static const String FEATURED_TV_CACHE_KEY = 'live_featured_tv';
// // // //   static const String LAST_PLAYED_CACHE_KEY = 'last_played_videos';

// // // //   static Future<void> clearAllCache() async {
// // // //     try {
// // // //       final prefs = await SharedPreferences.getInstance();
// // // //       await prefs.remove(BANNER_CACHE_KEY);
// // // //       await prefs.remove(FEATURED_TV_CACHE_KEY);
// // // //     } catch (e) {}
// // // //   }

// // // //   static Future<void> clearBannerCache() async {
// // // //     try {
// // // //       final prefs = await SharedPreferences.getInstance();
// // // //       await prefs.remove(BANNER_CACHE_KEY);
// // // //     } catch (e) {}
// // // //   }

// // // //   static Future<Map<String, int>> getCacheInfo() async {
// // // //     try {
// // // //       final prefs = await SharedPreferences.getInstance();

// // // //       final bannerSize = prefs.getString(BANNER_CACHE_KEY)?.length ?? 0;
// // // //       final featuredTVSize =
// // // //           prefs.getString(FEATURED_TV_CACHE_KEY)?.length ?? 0;
// // // //       final lastPlayedCount =
// // // //           prefs.getStringList(LAST_PLAYED_CACHE_KEY)?.length ?? 0;

// // // //       return {
// // // //         'bannerCacheSize': bannerSize,
// // // //         'featuredTVCacheSize': featuredTVSize,
// // // //         'lastPlayedCount': lastPlayedCount,
// // // //       };
// // // //     } catch (e) {
// // // //       return {};
// // // //     }
// // // //   }
// // // // }








// // // import 'dart:async';
// // // import 'dart:convert';
// // // import 'dart:math';
// // // import 'dart:typed_data';
// // // import 'package:cached_network_image/cached_network_image.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter_spinkit/flutter_spinkit.dart';
// // // import 'package:http/http.dart' as https;
// // // import 'package:mobi_tv_entertainment/main.dart';
// // // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // // import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// // // import 'package:mobi_tv_entertainment/video_widget/socket_service.dart';
// // // import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// // // import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// // // import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
// // // import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
// // // import 'package:mobi_tv_entertainment/widgets/utils/random_light_color_widget.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';

// // // import '../../widgets/small_widgets/app_assets.dart';

// // // // Cache Data Model
// // // class CacheDataModel {
// // //   final List<dynamic> data;
// // //   final DateTime timestamp;
// // //   final String version;

// // //   CacheDataModel({
// // //     required this.data,
// // //     required this.timestamp,
// // //     required this.version,
// // //   });

// // //   Map<String, dynamic> toJson() => {
// // //     'data': data,
// // //     'timestamp': timestamp.millisecondsSinceEpoch,
// // //     'version': version,
// // //   };

// // //   factory CacheDataModel.fromJson(Map<String, dynamic> json) => CacheDataModel(
// // //     data: json['data'] ?? [],
// // //     timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
// // //     version: json['version'] ?? '1.0',
// // //   );

// // //   bool isExpired({Duration expiration = const Duration(hours: 1)}) {
// // //     return DateTime.now().difference(timestamp) > expiration;
// // //   }
// // // }

// // // // Smart Cache Manager
// // // class SmartCacheManager {
// // //   static const String BANNER_CACHE_KEY = 'smart_banners_cache';
// // //   static const String FEATURED_TV_CACHE_KEY = 'smart_featured_tv_cache';
// // //   static const String CACHE_VERSION = '2.0';

// // //   static Future<CacheDataModel?> getCachedData(String key) async {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final cachedString = prefs.getString(key);
      
// // //       if (cachedString != null && cachedString.isNotEmpty) {
// // //         final jsonData = json.decode(cachedString);
// // //         return CacheDataModel.fromJson(jsonData);
// // //       }
// // //     } catch (e) {
// // //       print('Error reading cache: $e');
// // //     }
// // //     return null;
// // //   }

// // //   static Future<void> setCachedData(String key, List<dynamic> data) async {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final cacheModel = CacheDataModel(
// // //         data: data,
// // //         timestamp: DateTime.now(),
// // //         version: CACHE_VERSION,
// // //       );
// // //       await prefs.setString(key, json.encode(cacheModel.toJson()));
// // //     } catch (e) {
// // //       print('Error saving cache: $e');
// // //     }
// // //   }

// // //   static Future<void> clearCache(String key) async {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       await prefs.remove(key);
// // //     } catch (e) {
// // //       print('Error clearing cache: $e');
// // //     }
// // //   }

// // //   static Future<void> clearAllCache() async {
// // //     await Future.wait([
// // //       clearCache(BANNER_CACHE_KEY),
// // //       clearCache(FEATURED_TV_CACHE_KEY),
// // //     ]);
// // //   }
// // // }

// // // // Image Cache Service
// // // class ImageCacheStats {
// // //   final int totalFiles;
// // //   final double totalSizeMB;
// // //   ImageCacheStats({required this.totalFiles, required this.totalSizeMB});
// // // }

// // // class ImageCacheService {
// // //   Future<void> init() async {
// // //     // Initialize cache if needed
// // //   }

// // //   Future<bool> isCached(String url) async {
// // //     return false;
// // //   }

// // //   Future<void> downloadAndCacheImage(String url) async {
// // //     await Future.delayed(Duration(milliseconds: 100));
// // //   }

// // //   Future<void> clearCache() async {
// // //     await Future.delayed(Duration(milliseconds: 100));
// // //   }

// // //   Future<ImageCacheStats> getCacheStats() async {
// // //     return ImageCacheStats(totalFiles: 0, totalSizeMB: 0.0);
// // //   }
// // // }

// // // // Auth Headers
// // // Future<Map<String, String>> getAuthHeaders() async {
// // //   String authKey = '';

// // //   if (authKey.isEmpty) {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       authKey = prefs.getString('auth_key') ?? '';
// // //       if (authKey.isNotEmpty) {
// // //         globalAuthKey = authKey;
// // //       }
// // //     } catch (e) {
// // //       print('Error getting auth key: $e');
// // //     }
// // //   }

// // //   if (authKey.isEmpty) {
// // //     authKey = 'vLQTuPZUxktl5mVW';
// // //   }

// // //   return {
// // //     'auth-key': authKey,
// // //     'Accept': 'application/json',
// // //     'Content-Type': 'application/json',
// // //   };
// // // }

// // // // API Configuration
// // // class ApiConfig {
// // //   static const String PRIMARY_BASE_URL = 'https://acomtv.coretechinfo.com/public/api';
// // //   static const List<String> FEATURED_TV_ENDPOINTS = [
// // //     '$PRIMARY_BASE_URL/getCustomImageSlider',
// // //   ];
// // //   static const List<String> BANNER_ENDPOINTS = [
// // //     '$PRIMARY_BASE_URL/getCustomImageSlider',
// // //   ];
// // // }

// // // // API Functions
// // // Future<Map<String, String>> fetchVideoDataByIdFromBanners(String contentId) async {
// // //   final cachedData = await SmartCacheManager.getCachedData(SmartCacheManager.FEATURED_TV_CACHE_KEY);
  
// // //   List<dynamic> responseData = [];

// // //   try {
// // //     if (cachedData != null && !cachedData.isExpired()) {
// // //       responseData = cachedData.data;
// // //     } else {
// // //       Map<String, String> headers = await getAuthHeaders();
// // //       bool success = false;
// // //       String responseBody = '';

// // //       for (int i = 0; i < ApiConfig.FEATURED_TV_ENDPOINTS.length; i++) {
// // //         String endpoint = ApiConfig.FEATURED_TV_ENDPOINTS[i];

// // //         try {
// // //           Map<String, String> currentHeaders = Map.from(headers);

// // //           if (endpoint.contains('api.ekomflix.com')) {
// // //             currentHeaders = {
// // //               'x-api-key': 'vLQTuPZUxktl5mVW',
// // //               'Accept': 'application/json',
// // //             };
// // //           }

// // //           final response = await https
// // //               .get(Uri.parse(endpoint), headers: currentHeaders)
// // //               .timeout(Duration(seconds: 15));

// // //           if (response.statusCode == 200) {
// // //             String body = response.body.trim();
// // //             if (body.startsWith('[') || body.startsWith('{')) {
// // //               try {
// // //                 json.decode(body);
// // //                 responseBody = body;
// // //                 success = true;
// // //                 break;
// // //               } catch (e) {
// // //                 continue;
// // //               }
// // //             }
// // //           }
// // //         } catch (e) {
// // //           continue;
// // //         }
// // //       }

// // //       if (!success) {
// // //         throw Exception('Failed to load featured live TV from all endpoints');
// // //       }

// // //       responseData = json.decode(responseBody);
// // //       await SmartCacheManager.setCachedData(SmartCacheManager.FEATURED_TV_CACHE_KEY, responseData);
// // //     }

// // //     final matchedItem = responseData.firstWhere(
// // //       (channel) => channel['id'].toString() == contentId,
// // //       orElse: () => null,
// // //     );

// // //     if (matchedItem == null) {
// // //       throw Exception('Content with ID $contentId not found');
// // //     }

// // //     return {
// // //       'url': matchedItem['url']?.toString() ?? '',
// // //       'type': matchedItem['type']?.toString() ?? '',
// // //       'banner': matchedItem['banner']?.toString() ?? '',
// // //       'name': matchedItem['name']?.toString() ?? '',
// // //       'stream_type': matchedItem['stream_type']?.toString() ?? '',
// // //     };
// // //   } catch (e) {
// // //     throw Exception('Something went wrong: $e');
// // //   }
// // // }

// // // Future<List<dynamic>> fetchBannersData() async {
// // //   Map<String, String> headers = await getAuthHeaders();
// // //   bool success = false;
// // //   String responseBody = '';

// // //   for (int i = 0; i < ApiConfig.BANNER_ENDPOINTS.length; i++) {
// // //     String endpoint = ApiConfig.BANNER_ENDPOINTS[i];

// // //     try {
// // //       Map<String, String> currentHeaders = Map.from(headers);

// // //       if (endpoint.contains('api.ekomflix.com')) {
// // //         currentHeaders = {
// // //           'x-api-key': 'vLQTuPZUxktl5mVW',
// // //           'Accept': 'application/json',
// // //         };
// // //       }

// // //       final response = await https
// // //           .get(Uri.parse(endpoint), headers: currentHeaders)
// // //           .timeout(Duration(seconds: 15));

// // //       if (response.statusCode == 200) {
// // //         String body = response.body.trim();
// // //         if (body.startsWith('[') || body.startsWith('{')) {
// // //           try {
// // //             json.decode(body);
// // //             responseBody = body;
// // //             success = true;
// // //             break;
// // //           } catch (e) {
// // //             continue;
// // //           }
// // //         }
// // //       }
// // //     } catch (e) {
// // //       continue;
// // //     }
// // //   }

// // //   if (!success) {
// // //     throw Exception('Failed to load banners from all endpoints');
// // //   }

// // //   return json.decode(responseBody);
// // // }

// // // // Event Bus
// // // class GlobalEventBus {
// // //   static final GlobalEventBus _instance = GlobalEventBus._internal();
// // //   factory GlobalEventBus() => _instance;

// // //   final StreamController<RefreshPageEvent> _controller =
// // //       StreamController<RefreshPageEvent>.broadcast();

// // //   GlobalEventBus._internal();

// // //   Stream<RefreshPageEvent> get events => _controller.stream;
// // //   void fire(RefreshPageEvent event) => _controller.add(event);
// // //   void dispose() => _controller.close();
// // // }

// // // class RefreshPageEvent {
// // //   final String pageId;
// // //   RefreshPageEvent(this.pageId);
// // // }

// // // // Main Banner Slider Widget
// // // class BannerSlider extends StatefulWidget {
// // //   final Function(bool)? onFocusChange;
// // //   final FocusNode focusNode;
  
// // //   const BannerSlider({
// // //     Key? key, 
// // //     this.onFocusChange, 
// // //     required this.focusNode
// // //   }) : super(key: key);
  
// // //   @override
// // //   _BannerSliderState createState() => _BannerSliderState();
// // // }

// // // class _BannerSliderState extends State<BannerSlider>
// // //     with SingleTickerProviderStateMixin {
  
// // //   final SocketService _socketService = SocketService();
// // //   List<NewsItemModel> bannerList = [];
// // //   Map<String, Color> bannerColors = {};
// // //   bool isLoading = true;
// // //   bool isLoadingFromCache = false;
// // //   String errorMessage = '';
// // //   late PageController _pageController;
// // //   Timer? _timer;
// // //   String? selectedContentId;
// // //   final FocusNode _buttonFocusNode = FocusNode();
// // //   bool _isNavigating = false;
// // //   final PaletteColorService _paletteColorService = PaletteColorService();
// // //   Map<String, Uint8List> _bannerCache = {};
// // //   late FocusProvider _refreshProvider;
// // //   final ImageCacheService _imageCacheService = ImageCacheService();

// // //   // Animation controllers for shimmer effect
// // //   late AnimationController _shimmerController;
// // //   late Animation<double> _shimmerAnimation;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _initializeShimmerAnimation();
// // //     _initializeSlider();
// // //   }

// // //   void _initializeShimmerAnimation() {
// // //     _shimmerController = AnimationController(
// // //       duration: const Duration(milliseconds: 1500),
// // //       vsync: this,
// // //     )..repeat();

// // //     _shimmerAnimation = Tween<double>(
// // //       begin: -1.0,
// // //       end: 2.0,
// // //     ).animate(CurvedAnimation(
// // //       parent: _shimmerController,
// // //       curve: Curves.easeInOut,
// // //     ));
// // //   }

// // //   @override
// // //   void dispose() {
// // //     if (_pageController.hasClients) {
// // //       _pageController.dispose();
// // //     }
// // //     _socketService.dispose();
// // //     _shimmerController.dispose();
// // //     if (_timer != null && _timer!.isActive) {
// // //       _timer!.cancel();
// // //     }
// // //     _buttonFocusNode.dispose();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Consumer<FocusProvider>(
// // //       builder: (context, focusProvider, child) {
// // //         return Scaffold(
// // //           backgroundColor: cardColor,
// // //           body: _buildBody(focusProvider),
// // //         );
// // //       },
// // //     );
// // //   }

// // //   Widget _buildBody(FocusProvider focusProvider) {
// // //     if (isLoading && bannerList.isEmpty) {
// // //       return _buildLoadingWidget();
// // //     }

// // //     if (errorMessage.isNotEmpty && bannerList.isEmpty) {
// // //       return _buildErrorWidget();
// // //     }

// // //     if (bannerList.isEmpty && !isLoading) {
// // //       return _buildEmptyWidget();
// // //     }

// // //     return _buildBannerSlider(focusProvider);
// // //   }

// // //   Widget _buildLoadingWidget() {
// // //     return Center(
// // //       child: Column(
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: [
// // //           SpinKitFadingCircle(color: borderColor, size: 50.0),
// // //           SizedBox(height: 20),
// // //           Text(
// // //             isLoadingFromCache ? 'Loading from cache...' : 'Loading...',
// // //             style: TextStyle(
// // //               color: hintColor,
// // //               fontSize: nametextsz,
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildErrorWidget() {
// // //     return Center(
// // //       child: Column(
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: [
// // //           Icon(Icons.error_outline, color: Colors.red, size: 50),
// // //           SizedBox(height: 20),
// // //           Text(
// // //             'Something Went Wrong',
// // //             style: TextStyle(
// // //               fontSize: menutextsz,
// // //               color: Colors.red,
// // //               fontWeight: FontWeight.bold,
// // //             ),
// // //           ),
// // //           SizedBox(height: 10),
// // //           Padding(
// // //             padding: EdgeInsets.symmetric(horizontal: 20),
// // //             child: Text(
// // //               errorMessage,
// // //               style: TextStyle(fontSize: minitextsz, color: hintColor),
// // //               textAlign: TextAlign.center,
// // //             ),
// // //           ),
// // //           SizedBox(height: 20),
// // //           ElevatedButton(
// // //             onPressed: () => _loadData(forceRefresh: true),
// // //             child: Text('Retry'),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildEmptyWidget() {
// // //     return Center(
// // //       child: Column(
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: [
// // //           Icon(
// // //             Icons.image_not_supported,
// // //             color: hintColor.withOpacity(0.5),
// // //             size: 50,
// // //           ),
// // //           SizedBox(height: 20),
// // //           Text(
// // //             'No content available',
// // //             style: TextStyle(color: hintColor, fontSize: nametextsz),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildBannerSlider(FocusProvider focusProvider) {
// // //     return Stack(
// // //       children: [
// // //         // Page View
// // //         PageView.builder(
// // //           controller: _pageController,
// // //           itemCount: bannerList.length,
// // //           onPageChanged: (index) {
// // //             if (mounted) {
// // //               setState(() {
// // //                 selectedContentId = bannerList[index].contentId.toString();
// // //               });
// // //             }
// // //           },
// // //           itemBuilder: (context, index) {
// // //             final banner = bannerList[index];
// // //             return Stack(
// // //               alignment: AlignmentDirectional.topCenter,
// // //               children: [
// // //                 _buildBannerWithShimmer(banner, focusProvider),
// // //                 _buildGradientOverlay(),
// // //               ],
// // //             );
// // //           },
// // //         ),

// // //         // Watch Now Button
// // //         _buildWatchNowButton(focusProvider),

// // //         // Page indicators
// // //         if (bannerList.length > 1) _buildPageIndicators(),

// // //         // Cache status indicator
// // //         if (isLoadingFromCache) _buildCacheStatusIndicator(),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildGradientOverlay() {
// // //     return Container(
// // //       margin: const EdgeInsets.only(top: 1),
// // //       width: screenwdt,
// // //       height: screenhgt,
// // //       decoration: BoxDecoration(
// // //         gradient: LinearGradient(
// // //           begin: Alignment.topCenter,
// // //           end: Alignment.bottomCenter,
// // //           colors: [
// // //             Colors.black.withOpacity(0.3),
// // //             Colors.transparent,
// // //             Colors.black.withOpacity(0.7),
// // //           ],
// // //           stops: [0.0, 0.5, 1.0],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildWatchNowButton(FocusProvider focusProvider) {
// // //     return Positioned(
// // //       top: screenhgt * 0.03,
// // //       left: screenwdt * 0.02,
// // //       child: Focus(
// // //         focusNode: _buttonFocusNode,
// // //         onKeyEvent: _handleKeyEvent,
// // //         child: GestureDetector(
// // //           onTap: _handleWatchNowTap,
// // //           child: RandomLightColorWidget(
// // //             hasFocus: focusProvider.isButtonFocused,
// // //             childBuilder: (Color randomColor) {
// // //               return AnimatedContainer(
// // //                 duration: Duration(milliseconds: 200),
// // //                 margin: EdgeInsets.all(screenwdt * 0.001),
// // //                 padding: EdgeInsets.symmetric(
// // //                   vertical: screenhgt * 0.02,
// // //                   horizontal: screenwdt * 0.02,
// // //                 ),
// // //                 decoration: BoxDecoration(
// // //                   color: focusProvider.isButtonFocused
// // //                       ? Colors.black87
// // //                       : Colors.black.withOpacity(0.6),
// // //                   borderRadius: BorderRadius.circular(12),
// // //                   border: Border.all(
// // //                     color: focusProvider.isButtonFocused
// // //                         ? focusProvider.currentFocusColor ?? randomColor
// // //                         : Colors.white.withOpacity(0.3),
// // //                     width: focusProvider.isButtonFocused ? 3.0 : 1.0,
// // //                   ),
// // //                   boxShadow: focusProvider.isButtonFocused
// // //                       ? [
// // //                           BoxShadow(
// // //                             color: (focusProvider.currentFocusColor ?? randomColor)
// // //                                 .withOpacity(0.5),
// // //                             blurRadius: 20.0,
// // //                             spreadRadius: 5.0,
// // //                           ),
// // //                         ]
// // //                       : [
// // //                           BoxShadow(
// // //                             color: Colors.black.withOpacity(0.3),
// // //                             blurRadius: 10.0,
// // //                             spreadRadius: 2.0,
// // //                           ),
// // //                         ],
// // //                 ),
// // //                 child: Row(
// // //                   mainAxisSize: MainAxisSize.min,
// // //                   children: [
// // //                     Icon(
// // //                       Icons.play_arrow,
// // //                       color: focusProvider.isButtonFocused
// // //                           ? focusProvider.currentFocusColor ?? randomColor
// // //                           : hintColor,
// // //                       size: menutextsz * 1.2,
// // //                     ),
// // //                     SizedBox(width: 8),
// // //                     Text(
// // //                       'Watch Now',
// // //                       style: TextStyle(
// // //                         fontSize: menutextsz,
// // //                         color: focusProvider.isButtonFocused
// // //                             ? focusProvider.currentFocusColor ?? randomColor
// // //                             : hintColor,
// // //                         fontWeight: FontWeight.bold,
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               );
// // //             },
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildPageIndicators() {
// // //     return Positioned(
// // //       top: screenhgt * 0.05,
// // //       right: screenwdt * 0.05,
// // //       child: Row(
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: bannerList.asMap().entries.map((entry) {
// // //           int index = entry.key;
// // //           bool isSelected = selectedContentId == bannerList[index].contentId;

// // //           return AnimatedContainer(
// // //             duration: Duration(milliseconds: 300),
// // //             margin: EdgeInsets.symmetric(horizontal: 4),
// // //             width: isSelected ? 12 : 8,
// // //             height: isSelected ? 12 : 8,
// // //             decoration: BoxDecoration(
// // //               color: isSelected
// // //                   ? Colors.white
// // //                   : Colors.white.withOpacity(0.5),
// // //               shape: BoxShape.circle,
// // //               boxShadow: [
// // //                 BoxShadow(
// // //                   color: Colors.black.withOpacity(0.3),
// // //                   blurRadius: 4,
// // //                   spreadRadius: 1,
// // //                 ),
// // //               ],
// // //             ),
// // //           );
// // //         }).toList(),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildCacheStatusIndicator() {
// // //     return Positioned(
// // //       top: screenhgt * 0.01,
// // //       right: screenwdt * 0.01,
// // //       child: Container(
// // //         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// // //         decoration: BoxDecoration(
// // //           color: Colors.blue.withOpacity(0.8),
// // //           borderRadius: BorderRadius.circular(12),
// // //         ),
// // //         child: Row(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             Icon(Icons.cached, color: Colors.white, size: 12),
// // //             SizedBox(width: 4),
// // //             Text(
// // //               'Updating...',
// // //               style: TextStyle(color: Colors.white, fontSize: 10),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildBannerWithShimmer(NewsItemModel banner, FocusProvider focusProvider) {
// // //     return Container(
// // //       margin: const EdgeInsets.only(top: 1),
// // //       width: screenwdt,
// // //       height: screenhgt,
// // //       child: Stack(
// // //         children: [
// // //           // Main banner image
// // //           CachedNetworkImage(
// // //             imageUrl: banner.banner,
// // //             fit: BoxFit.fill,
// // //             placeholder: (context, url) => Image.asset('assets/streamstarting.gif'),
// // //             errorWidget: (context, url, error) => Image.asset('assets/streamstarting.gif'),
// // //             cacheKey: banner.contentId,
// // //             fadeInDuration: Duration(milliseconds: 500),
// // //             memCacheHeight: 800,
// // //             memCacheWidth: 1200,
// // //             width: screenwdt,
// // //             height: screenhgt,
// // //           ),

// // //           // Shimmer effect overlay when focused
// // //           if (focusProvider.isButtonFocused)
// // //             AnimatedBuilder(
// // //               animation: _shimmerAnimation,
// // //               builder: (context, child) {
// // //                 return Positioned.fill(
// // //                   child: Container(
// // //                     decoration: BoxDecoration(
// // //                       gradient: LinearGradient(
// // //                         begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
// // //                         end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
// // //                         colors: [
// // //                           Colors.transparent,
// // //                           Colors.white.withOpacity(0.1),
// // //                           Colors.white.withOpacity(0.2),
// // //                           Colors.white.withOpacity(0.1),
// // //                           Colors.transparent,
// // //                         ],
// // //                         stops: [0.0, 0.3, 0.5, 0.7, 1.0],
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 );
// // //               },
// // //             ),

// // //           // Enhanced glow effect when focused
// // //           if (focusProvider.isButtonFocused)
// // //             Positioned.fill(
// // //               child: Container(
// // //                 decoration: BoxDecoration(
// // //                   gradient: RadialGradient(
// // //                     center: Alignment.center,
// // //                     radius: 0.8,
// // //                     colors: [
// // //                       (focusProvider.currentFocusColor ?? Colors.blue).withOpacity(0.1),
// // //                       Colors.transparent,
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),

// // //           // Border glow effect
// // //           if (focusProvider.isButtonFocused)
// // //             Positioned.fill(
// // //               child: Container(
// // //                 decoration: BoxDecoration(
// // //                   border: Border.all(
// // //                     color: (focusProvider.currentFocusColor ?? Colors.blue).withOpacity(0.3),
// // //                     width: 2.0,
// // //                   ),
// // //                   borderRadius: BorderRadius.circular(8),
// // //                 ),
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // Event Handlers
// // //   KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
// // //     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
// // //       if (_pageController.hasClients &&
// // //           _pageController.page != null &&
// // //           _pageController.page! < bannerList.length - 1) {
// // //         _pageController.nextPage(
// // //           duration: Duration(milliseconds: 300),
// // //           curve: Curves.easeInOut,
// // //         );
// // //         return KeyEventResult.handled;
// // //       }
// // //     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
// // //       if (_pageController.hasClients &&
// // //           _pageController.page != null &&
// // //           _pageController.page! > 0) {
// // //         _pageController.previousPage(
// // //           duration: Duration(milliseconds: 300),
// // //           curve: Curves.easeInOut,
// // //         );
// // //         return KeyEventResult.handled;
// // //       }
// // //     } else if (event is KeyDownEvent) {
// // //       if (event.logicalKey == LogicalKeyboardKey.select ||
// // //           event.logicalKey == LogicalKeyboardKey.enter) {
// // //         _handleWatchNowTap();
// // //         return KeyEventResult.handled;
// // //       }
// // //     }
// // //     return KeyEventResult.ignored;
// // //   }

// // //   void _handleWatchNowTap() {
// // //     if (selectedContentId != null && bannerList.isNotEmpty) {
// // //       try {
// // //         final banner = bannerList.firstWhere(
// // //           (b) => b.contentId == selectedContentId,
// // //           orElse: () => bannerList.first,
// // //         );
// // //         fetchAndPlayVideo(banner.id, bannerList);
// // //       } catch (e) {
// // //         print('Error in watch now tap: $e');
// // //       }
// // //     }
// // //   }

// // //   // Initialization Methods
// // //   Future<void> _initializeSlider() async {
// // //     try {
// // //       await _imageCacheService.init();

// // //       _socketService.initSocket();
// // //       _pageController = PageController();

// // //       _buttonFocusNode.addListener(() {
// // //         if (_buttonFocusNode.hasFocus) {
// // //           widget.onFocusChange?.call(true);
// // //         }
// // //       });

// // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // //         if (mounted) {
// // //           context.read<FocusProvider>().setWatchNowFocusNode(_buttonFocusNode);
// // //         }
// // //       });

// // //       _buttonFocusNode.addListener(_onButtonFocusNode);

// // //       // Smart data loading strategy
// // //       await _loadData();
// // //     } catch (e) {
// // //       print('Error initializing slider: $e');
// // //       if (mounted) {
// // //         setState(() {
// // //           errorMessage = 'Failed to initialize: $e';
// // //           isLoading = false;
// // //         });
// // //       }
// // //     }
// // //   }

// // //   // Enhanced Data Loading Strategy
// // //   Future<void> _loadData({bool forceRefresh = false}) async {
// // //     print('🚀 Starting data load - forceRefresh: $forceRefresh');
    
// // //     if (!forceRefresh) {
// // //       // Step 1: Try to load from cache first
// // //       await _loadFromCache();
// // //     }

// // //     // Step 2: Always fetch fresh data from API (in background if cache loaded)
// // //     await _fetchFreshDataFromAPI();
// // //   }

// // //   Future<void> _loadFromCache() async {
// // //     try {
// // //       print('📦 Attempting to load from cache...');
      
// // //       final cachedData = await SmartCacheManager.getCachedData(
// // //         SmartCacheManager.BANNER_CACHE_KEY
// // //       );

// // //       if (cachedData != null && cachedData.data.isNotEmpty) {
// // //         print('✅ Cache found with ${cachedData.data.length} items');
        
// // //         if (mounted) {
// // //           setState(() {
// // //             isLoadingFromCache = true;
// // //           });
// // //         }

// // //         final processedBanners = await _processRawBannerData(cachedData.data);
        
// // //         if (processedBanners.isNotEmpty && mounted) {
// // //           setState(() {
// // //             bannerList = processedBanners;
// // //             selectedContentId = bannerList.isNotEmpty ? bannerList[0].id : null;
// // //             isLoading = false;
// // //             isLoadingFromCache = false;
// // //             errorMessage = '';
// // //           });

// // //           print('✅ Loaded ${bannerList.length} banners from cache');
          
// // //           // Start auto slide and fetch colors
// // //           if (bannerList.isNotEmpty) {
// // //             _startAutoSlide();
// // //             _fetchBannerColors();
// // //             _preloadImages();
// // //           }
// // //         } else {
// // //           print('⚠️ Cache data processed but no valid banners found');
// // //           if (mounted) {
// // //             setState(() {
// // //               isLoadingFromCache = false;
// // //             });
// // //           }
// // //         }
// // //       } else {
// // //         print('❌ No cache found');
// // //       }
// // //     } catch (e) {
// // //       print('❌ Error loading from cache: $e');
// // //       if (mounted) {
// // //         setState(() {
// // //           isLoadingFromCache = false;
// // //         });
// // //       }
// // //     }
// // //   }

// // //   Future<void> _fetchFreshDataFromAPI() async {
// // //     try {
// // //       print('🌐 Fetching fresh data from API...');

// // //       // Show loading indicator only if no cache data is displayed
// // //       if (bannerList.isEmpty && mounted) {
// // //         setState(() {
// // //           isLoading = true;
// // //           errorMessage = '';
// // //         });
// // //       } else {
// // //         // Show cache update indicator
// // //         if (mounted) {
// // //           setState(() {
// // //             isLoadingFromCache = true;
// // //           });
// // //         }
// // //       }

// // //       final List<dynamic> responseData = await fetchBannersData();
// // //       print('✅ API returned ${responseData.length} items');

// // //       // Check if data has changed compared to what we have
// // //       if (_hasDataChanged(responseData)) {
// // //         print('🔄 Data has changed, updating...');
        
// // //         // Save to cache
// // //         await SmartCacheManager.setCachedData(
// // //           SmartCacheManager.BANNER_CACHE_KEY, 
// // //           responseData
// // //         );

// // //         // Process and update UI
// // //         final processedBanners = await _processRawBannerData(responseData);
        
// // //         if (mounted) {
// // //           setState(() {
// // //             bannerList = processedBanners;
// // //             selectedContentId = bannerList.isNotEmpty ? bannerList[0].id : null;
// // //             isLoading = false;
// // //             isLoadingFromCache = false;
// // //             errorMessage = '';
// // //           });
// // //         }

// // //         print('✅ Updated with ${bannerList.length} banners from API');

// // //         // Start auto slide and fetch colors if this is the first load
// // //         if (bannerList.isNotEmpty) {
// // //           if (_timer == null || !_timer!.isActive) {
// // //             _startAutoSlide();
// // //           }
// // //           _fetchBannerColors();
// // //           _preloadImages();
// // //         }
// // //       } else {
// // //         print('✅ Data unchanged, keeping current display');
// // //         if (mounted) {
// // //           setState(() {
// // //             isLoading = false;
// // //             isLoadingFromCache = false;
// // //           });
// // //         }
// // //       }
// // //     } catch (e) {
// // //       print('❌ Error fetching from API: $e');
      
// // //       // Only show error if we have no data to display
// // //       if (bannerList.isEmpty && mounted) {
// // //         setState(() {
// // //           errorMessage = 'Failed to load banners: $e';
// // //           isLoading = false;
// // //           isLoadingFromCache = false;
// // //         });
// // //       } else {
// // //         // Just hide the loading indicator but keep current data
// // //         if (mounted) {
// // //           setState(() {
// // //             isLoading = false;
// // //             isLoadingFromCache = false;
// // //           });
// // //         }
        
// // //         // Show a subtle notification that update failed
// // //         if (mounted && context.mounted) {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             SnackBar(
// // //               content: Text('Failed to update content'),
// // //               duration: Duration(seconds: 2),
// // //               backgroundColor: Colors.orange.shade600,
// // //             ),
// // //           );
// // //         }
// // //       }
// // //     }
// // //   }

// // //   bool _hasDataChanged(List<dynamic> newData) {
// // //     if (bannerList.length != newData.length) {
// // //       return true;
// // //     }
    
// // //     // Compare key fields to detect changes
// // //     try {
// // //       for (int i = 0; i < bannerList.length && i < newData.length; i++) {
// // //         final current = bannerList[i];
// // //         final newItem = newData[i];
        
// // //         if (current.id != newItem['id']?.toString() ||
// // //             current.name != newItem['name']?.toString() ||
// // //             current.banner != newItem['banner']?.toString() ||
// // //             current.url != newItem['url']?.toString()) {
// // //           return true;
// // //         }
// // //       }
// // //       return false;
// // //     } catch (e) {
// // //       // If comparison fails, assume data changed
// // //       return true;
// // //     }
// // //   }

// // //   Future<List<NewsItemModel>> _processRawBannerData(List<dynamic> rawData) async {
// // //     List<NewsItemModel> filteredBanners = [];

// // //     for (var banner in rawData) {
// // //       try {
// // //         bool isActive = false;

// // //         if (banner['status'] != null) {
// // //           var status = banner['status'];

// // //           if (status is String) {
// // //             isActive = status == "1" ||
// // //                 status.toLowerCase() == "active" ||
// // //                 status.toLowerCase() == "true";
// // //           } else if (status is int) {
// // //             isActive = status == 1;
// // //           } else if (status is bool) {
// // //             isActive = status;
// // //           }
// // //         } else {
// // //           isActive = true;
// // //         }

// // //         if (isActive) {
// // //           try {
// // //             final newsItem = NewsItemModel.fromJson(banner);
// // //             filteredBanners.add(newsItem);
// // //           } catch (e) {
// // //             print('Error creating NewsItemModel: $e');
// // //           }
// // //         }
// // //       } catch (e) {
// // //         print('Error processing banner: $e');
// // //       }
// // //     }

// // //     return filteredBanners;
// // //   }

// // //   // Preload images in background for smooth experience
// // //   Future<void> _preloadImages() async {
// // //     for (final banner in bannerList) {
// // //       try {
// // //         final isCached = await _imageCacheService.isCached(banner.banner);

// // //         if (!isCached) {
// // //           _imageCacheService
// // //               .downloadAndCacheImage(banner.banner)
// // //               .catchError((e) {
// // //             print('Failed to preload image: ${banner.banner}');
// // //           });
// // //         }
// // //       } catch (e) {
// // //         print('Error preloading image: $e');
// // //       }
// // //     }
// // //   }

// // //   @override
// // //   void didChangeDependencies() {
// // //     super.didChangeDependencies();

// // //     try {
// // //       _refreshProvider = context.watch<FocusProvider>();

// // //       if (_refreshProvider.shouldRefreshBanners ||
// // //           _refreshProvider.shouldRefreshLastPlayed) {
// // //         _handleProviderRefresh();
// // //       }
// // //     } catch (e) {
// // //       print('Error in didChangeDependencies: $e');
// // //     }
// // //   }

// // //   Future<void> _handleProviderRefresh() async {
// // //     if (!mounted) return;

// // //     try {
// // //       if (_refreshProvider.shouldRefreshBanners) {
// // //         await _fetchFreshDataFromAPI();
// // //         _refreshProvider.markBannersRefreshed();
// // //       }
// // //     } catch (e) {
// // //       print('Error in provider refresh: $e');
// // //     }
// // //   }

// // //   Future<void> _fetchBannerColors() async {
// // //     for (var banner in bannerList) {
// // //       try {
// // //         final imageUrl = banner.banner;
// // //         final secondaryColor =
// // //             await _paletteColorService.getSecondaryColor(imageUrl);

// // //         if (mounted) {
// // //           setState(() {
// // //             bannerColors[banner.contentId] = secondaryColor;
// // //           });
// // //         }
// // //       } catch (e) {
// // //         print('Error fetching banner color: $e');
// // //       }
// // //     }
// // //   }

// // //   void _startAutoSlide() {
// // //     if (bannerList.isNotEmpty && (_timer == null || !_timer!.isActive)) {
// // //       _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
// // //         if (!mounted) {
// // //           timer.cancel();
// // //           return;
// // //         }

// // //         try {
// // //           if (_pageController.hasClients) {
// // //             if (_pageController.page == bannerList.length - 1) {
// // //               _pageController.jumpToPage(0);
// // //             } else {
// // //               _pageController.nextPage(
// // //                 duration: const Duration(milliseconds: 300),
// // //                 curve: Curves.easeIn,
// // //               );
// // //             }
// // //           }
// // //         } catch (e) {
// // //           print('Error in auto slide: $e');
// // //         }
// // //       });
// // //     }
// // //   }

// // //   void _onButtonFocusNode() {
// // //     try {
// // //       if (_buttonFocusNode.hasFocus) {
// // //         final random = Random();
// // //         final color = Color.fromRGBO(
// // //           random.nextInt(256),
// // //           random.nextInt(256),
// // //           random.nextInt(256),
// // //           1,
// // //         );
// // //         if (mounted) {
// // //           context.read<FocusProvider>().setButtonFocus(true, color: color);
// // //           context.read<ColorProvider>().updateColor(color, true);
// // //         }
// // //       } else {
// // //         if (mounted) {
// // //           context.read<FocusProvider>().resetFocus();
// // //           context.read<ColorProvider>().resetColor();
// // //         }
// // //       }
// // //     } catch (e) {
// // //       print('Error in button focus handler: $e');
// // //     }
// // //   }


// // //   Future<void> fetchAndPlayVideo(
// // //       String contentId, List<NewsItemModel> channelList) async {
// // //     if (_isNavigating) {
// // //       return;
// // //     }

// // //     _isNavigating = true;

// // //     bool shouldPlayVideo = true;
// // //     bool shouldPop = true;

// // //     try {
// // //       if (mounted) {
// // //         showDialog(
// // //           context: context,
// // //           barrierDismissible: false,
// // //           builder: (BuildContext context) {
// // //             return WillPopScope(
// // //               onWillPop: () async {
// // //                 shouldPlayVideo = false;
// // //                 shouldPop = false;
// // //                 return true;
// // //               },
// // //               child: Center(
// // //                 child: Container(
// // //                   padding: EdgeInsets.all(20),
// // //                   decoration: BoxDecoration(
// // //                     color: Colors.black87,
// // //                     borderRadius: BorderRadius.circular(10),
// // //                   ),
// // //                   child: Column(
// // //                     mainAxisSize: MainAxisSize.min,
// // //                     children: [
// // //                       SpinKitFadingCircle(
// // //                         color: borderColor,
// // //                         size: 50.0,
// // //                       ),
// // //                       SizedBox(height: 15),
// // //                       Text(
// // //                         'Loading video...',
// // //                         style: TextStyle(
// // //                           color: Colors.white,
// // //                           fontSize: nametextsz,
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ),
// // //             );
// // //           },
// // //         );
// // //       }

// // //       final responseData = await fetchVideoDataByIdFromBanners(contentId);

// // //       if (shouldPop && mounted && context.mounted) {
// // //         Navigator.of(context, rootNavigator: true).pop();
// // //       }

// // //       if (shouldPlayVideo && mounted && context.mounted) {
// // //         Navigator.push(
// // //           context,
// // //           MaterialPageRoute(
// // //             builder: (context) => VideoScreen(
// // //               videoUrl: responseData['url'] ?? '',
// // //               channelList: channelList,
// // //               videoId: int.tryParse(contentId) ?? 0,
// // //               videoType: responseData['type'] ?? '',
// // //               isLive: true,
// // //               isVOD: false,
// // //               bannerImageUrl: responseData['banner'] ?? '',
// // //               startAtPosition: Duration.zero,
// // //               isBannerSlider: true,
// // //               source: 'isBannerSlider',
// // //               isSearch: false,
// // //               unUpdatedUrl: responseData['url'] ?? '',
// // //               name: responseData['name'] ?? '',
// // //               liveStatus: true,
// // //               seasonId: null,
// // //               isLastPlayedStored: false,
// // //             ),
// // //           ),
// // //         );
// // //       }
// // //     } catch (e) {
// // //       if (shouldPop && mounted && context.mounted) {
// // //         Navigator.of(context, rootNavigator: true).pop();
// // //       }

// // //       if (mounted && context.mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(
// // //             content: Text('Something went wrong'),
// // //             duration: Duration(seconds: 3),
// // //             backgroundColor: Colors.red.shade700,
// // //           ),
// // //         );
// // //       }
// // //     } finally {
// // //       _isNavigating = false;
// // //     }
// // //   }

// // //   Uint8List _getCachedImage(String base64String) {
// // //     try {
// // //       if (!_bannerCache.containsKey(base64String)) {
// // //         final base64Content = base64String.split(',').last;
// // //         _bannerCache[base64String] = base64Decode(base64Content);
// // //       }
// // //       return _bannerCache[base64String]!;
// // //     } catch (e) {
// // //       return Uint8List.fromList([
// // //         0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
// // //         0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
// // //         0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
// // //         0x0C, 0x49, 0x44, 0x41, 0x54, 0x78, 0x01, 0x63, 0x00, 0x01, 0x00, 0x05,
// // //         0x00, 0x01, 0xE2, 0x26, 0x05, 0x9B, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
// // //         0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
// // //       ]);
// // //     }
// // //   }
// // //   }









// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:math';
// // import 'dart:typed_data';
// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_spinkit/flutter_spinkit.dart';
// // import 'package:http/http.dart' as https;
// // import 'package:mobi_tv_entertainment/main.dart';
// // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// // import 'package:mobi_tv_entertainment/video_widget/socket_service.dart';
// // import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// // import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// // import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
// // import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
// // import 'package:mobi_tv_entertainment/widgets/utils/random_light_color_widget.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // import '../../widgets/small_widgets/app_assets.dart';

// // // Enhanced Cache Data Model
// // class EnhancedCacheDataModel {
// //   final List<dynamic> data;
// //   final DateTime timestamp;
// //   final String version;
// //   final int dataHash;
// //   final Map<String, dynamic> metadata;

// //   EnhancedCacheDataModel({
// //     required this.data,
// //     required this.timestamp,
// //     required this.version,
// //     required this.dataHash,
// //     this.metadata = const {},
// //   });

// //   Map<String, dynamic> toJson() => {
// //         'data': data,
// //         'timestamp': timestamp.millisecondsSinceEpoch,
// //         'version': version,
// //         'dataHash': dataHash,
// //         'metadata': metadata,
// //       };

// //   factory EnhancedCacheDataModel.fromJson(Map<String, dynamic> json) =>
// //       EnhancedCacheDataModel(
// //         data: json['data'] ?? [],
// //         timestamp:
// //             DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
// //         version: json['version'] ?? '1.0',
// //         dataHash: json['dataHash'] ?? 0,
// //         metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
// //       );

// //   bool isExpired({Duration expiration = const Duration(hours: 1)}) {
// //     return DateTime.now().difference(timestamp) > expiration;
// //   }

// //   bool isStale({Duration staleTime = const Duration(minutes: 30)}) {
// //     return DateTime.now().difference(timestamp) > staleTime;
// //   }

// //   int getAgeInMinutes() {
// //     return DateTime.now().difference(timestamp).inMinutes;
// //   }

// //   static int generateDataHash(List<dynamic> data) {
// //     try {
// //       final dataString = data
// //           .map((item) =>
// //               '${item['id']}_${item['name']}_${item['banner']}_${item['url']}')
// //           .join('|');
// //       return dataString.hashCode;
// //     } catch (e) {
// //       return data.length.hashCode;
// //     }
// //   }
// // }

// // // Enhanced Smart Cache Manager
// // class EnhancedSmartCacheManager {
// //   static const String BANNER_CACHE_KEY = 'enhanced_banners_cache';
// //   static const String FEATURED_TV_CACHE_KEY = 'enhanced_featured_tv_cache';
// //   static const String CACHE_VERSION = '3.0';

// //   static const Duration DEFAULT_CACHE_DURATION = Duration(hours: 2);
// //   static const Duration STALE_CACHE_THRESHOLD = Duration(minutes: 30);
// //   static const Duration MAX_CACHE_AGE = Duration(days: 7);

// //   static Future<EnhancedCacheDataModel?> getCachedData(String key) async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final cachedString = prefs.getString(key);

// //       if (cachedString != null && cachedString.isNotEmpty) {
// //         final jsonData = json.decode(cachedString);
// //         final cacheModel = EnhancedCacheDataModel.fromJson(jsonData);

// //         if (cacheModel.getAgeInMinutes() > MAX_CACHE_AGE.inMinutes) {
// //           print(
// //               '🗑️ Cache too old (${cacheModel.getAgeInMinutes()} minutes), ignoring');
// //           await clearCache(key);
// //           return null;
// //         }

// //         return cacheModel;
// //       }
// //     } catch (e) {
// //       print('❌ Error reading cache: $e');
// //       await clearCache(key);
// //     }
// //     return null;
// //   }

// //   static Future<void> setCachedData(
// //     String key,
// //     List<dynamic> data, {
// //     Map<String, dynamic>? metadata,
// //   }) async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final dataHash = EnhancedCacheDataModel.generateDataHash(data);

// //       final cacheModel = EnhancedCacheDataModel(
// //         data: data,
// //         timestamp: DateTime.now(),
// //         version: CACHE_VERSION,
// //         dataHash: dataHash,
// //         metadata: metadata ?? {},
// //       );

// //       await prefs.setString(key, json.encode(cacheModel.toJson()));
// //       print('💾 Cache saved: ${data.length} items, hash: $dataHash');
// //     } catch (e) {
// //       print('❌ Error saving cache: $e');
// //     }
// //   }

// //   static bool hasDataChanged(EnhancedCacheDataModel? cachedData, List<dynamic> newData) {
// //     if (cachedData == null) return true;

// //     final newDataHash = EnhancedCacheDataModel.generateDataHash(newData);
// //     final hasChanged = cachedData.dataHash != newDataHash;

// //     print('📊 Data comparison: cached hash: ${cachedData.dataHash}, new hash: $newDataHash, changed: $hasChanged');
// //     return hasChanged;
// //   }

// //   static Future<Map<String, dynamic>> getCacheStats(String key) async {
// //     try {
// //       final cachedData = await getCachedData(key);
// //       if (cachedData != null) {
// //         return {
// //           'exists': true,
// //           'itemCount': cachedData.data.length,
// //           'ageMinutes': cachedData.getAgeInMinutes(),
// //           'isExpired': cachedData.isExpired(),
// //           'isStale': cachedData.isStale(),
// //           'version': cachedData.version,
// //           'timestamp': cachedData.timestamp.toIso8601String(),
// //         };
// //       }
// //     } catch (e) {
// //       print('Error getting cache stats: $e');
// //     }

// //     return {
// //       'exists': false,
// //       'itemCount': 0,
// //       'ageMinutes': 0,
// //       'isExpired': true,
// //       'isStale': true,
// //     };
// //   }

// //   static Future<void> clearCache(String key) async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       await prefs.remove(key);
// //       print('🗑️ Cache cleared: $key');
// //     } catch (e) {
// //       print('❌ Error clearing cache: $e');
// //     }
// //   }

// //   static Future<void> clearAllCache() async {
// //     await Future.wait([
// //       clearCache(BANNER_CACHE_KEY),
// //       clearCache(FEATURED_TV_CACHE_KEY),
// //     ]);
// //     print('🗑️ All caches cleared');
// //   }

// //   static Future<bool> validateCacheIntegrity(String key) async {
// //     try {
// //       final cachedData = await getCachedData(key);
// //       if (cachedData == null) return false;

// //       if (cachedData.version != CACHE_VERSION) {
// //         print('⚠️ Cache version mismatch, clearing cache');
// //         await clearCache(key);
// //         return false;
// //       }

// //       if (cachedData.data.isEmpty) {
// //         print('⚠️ Empty cache data, clearing cache');
// //         await clearCache(key);
// //         return false;
// //       }

// //       return true;
// //     } catch (e) {
// //       print('❌ Cache validation failed: $e');
// //       await clearCache(key);
// //       return false;
// //     }
// //   }
// // }

// // // Image Cache Service
// // class ImageCacheStats {
// //   final int totalFiles;
// //   final double totalSizeMB;
// //   ImageCacheStats({required this.totalFiles, required this.totalSizeMB});
// // }

// // class ImageCacheService {
// //   Future<void> init() async {
// //     // Initialize cache if needed
// //   }

// //   Future<bool> isCached(String url) async {
// //     return false;
// //   }

// //   Future<void> downloadAndCacheImage(String url) async {
// //     await Future.delayed(Duration(milliseconds: 100));
// //   }

// //   Future<void> clearCache() async {
// //     await Future.delayed(Duration(milliseconds: 100));
// //   }

// //   Future<ImageCacheStats> getCacheStats() async {
// //     return ImageCacheStats(totalFiles: 0, totalSizeMB: 0.0);
// //   }
// // }

// // // Auth Headers
// // Future<Map<String, String>> getAuthHeaders() async {
// //   String authKey = '';

// //   if (authKey.isEmpty) {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       authKey = prefs.getString('auth_key') ?? '';
// //       if (authKey.isNotEmpty) {
// //         globalAuthKey = authKey;
// //       }
// //     } catch (e) {
// //       print('Error getting auth key: $e');
// //     }
// //   }

// //   if (authKey.isEmpty) {
// //     authKey = 'vLQTuPZUxktl5mVW';
// //   }

// //   return {
// //     'auth-key': authKey,
// //     'Accept': 'application/json',
// //     'Content-Type': 'application/json',
// //   };
// // }

// // // API Configuration
// // class ApiConfig {
// //   static const String PRIMARY_BASE_URL = 'https://acomtv.coretechinfo.com/public/api';
// //   static const List<String> FEATURED_TV_ENDPOINTS = [
// //     '$PRIMARY_BASE_URL/getCustomImageSlider',
// //   ];
// //   static const List<String> BANNER_ENDPOINTS = [
// //     '$PRIMARY_BASE_URL/getCustomImageSlider',
// //   ];
// // }

// // // API Functions
// // Future<Map<String, String>> fetchVideoDataByIdFromBanners(String contentId) async {
// //   final cachedData = await EnhancedSmartCacheManager.getCachedData(
// //       EnhancedSmartCacheManager.FEATURED_TV_CACHE_KEY);

// //   List<dynamic> responseData = [];

// //   try {
// //     if (cachedData != null && !cachedData.isExpired()) {
// //       responseData = cachedData.data;
// //     } else {
// //       Map<String, String> headers = await getAuthHeaders();
// //       bool success = false;
// //       String responseBody = '';

// //       for (int i = 0; i < ApiConfig.FEATURED_TV_ENDPOINTS.length; i++) {
// //         String endpoint = ApiConfig.FEATURED_TV_ENDPOINTS[i];

// //         try {
// //           Map<String, String> currentHeaders = Map.from(headers);

// //           if (endpoint.contains('api.ekomflix.com')) {
// //             currentHeaders = {
// //               'x-api-key': 'vLQTuPZUxktl5mVW',
// //               'Accept': 'application/json',
// //             };
// //           }

// //           final response = await https
// //               .get(Uri.parse(endpoint), headers: currentHeaders)
// //               .timeout(Duration(seconds: 15));

// //           if (response.statusCode == 200) {
// //             String body = response.body.trim();
// //             if (body.startsWith('[') || body.startsWith('{')) {
// //               try {
// //                 json.decode(body);
// //                 responseBody = body;
// //                 success = true;
// //                 break;
// //               } catch (e) {
// //                 continue;
// //               }
// //             }
// //           }
// //         } catch (e) {
// //           continue;
// //         }
// //       }

// //       if (!success) {
// //         throw Exception('Failed to load featured live TV from all endpoints');
// //       }

// //       responseData = json.decode(responseBody);
// //       await EnhancedSmartCacheManager.setCachedData(
// //           EnhancedSmartCacheManager.FEATURED_TV_CACHE_KEY, responseData);
// //     }

// //     final matchedItem = responseData.firstWhere(
// //       (channel) => channel['id'].toString() == contentId,
// //       orElse: () => null,
// //     );

// //     if (matchedItem == null) {
// //       throw Exception('Content with ID $contentId not found');
// //     }

// //     return {
// //       'url': matchedItem['url']?.toString() ?? '',
// //       'type': matchedItem['type']?.toString() ?? '',
// //       'banner': matchedItem['banner']?.toString() ?? '',
// //       'name': matchedItem['name']?.toString() ?? '',
// //       'stream_type': matchedItem['stream_type']?.toString() ?? '',
// //     };
// //   } catch (e) {
// //     throw Exception('Something went wrong: $e');
// //   }
// // }

// // Future<List<dynamic>> fetchBannersData() async {
// //   Map<String, String> headers = await getAuthHeaders();
// //   bool success = false;
// //   String responseBody = '';

// //   for (int i = 0; i < ApiConfig.BANNER_ENDPOINTS.length; i++) {
// //     String endpoint = ApiConfig.BANNER_ENDPOINTS[i];

// //     try {
// //       Map<String, String> currentHeaders = Map.from(headers);

// //       if (endpoint.contains('api.ekomflix.com')) {
// //         currentHeaders = {
// //           'x-api-key': 'vLQTuPZUxktl5mVW',
// //           'Accept': 'application/json',
// //         };
// //       }

// //       final response = await https
// //           .get(Uri.parse(endpoint), headers: currentHeaders)
// //           .timeout(Duration(seconds: 15));

// //       if (response.statusCode == 200) {
// //         String body = response.body.trim();
// //         if (body.startsWith('[') || body.startsWith('{')) {
// //           try {
// //             json.decode(body);
// //             responseBody = body;
// //             success = true;
// //             break;
// //           } catch (e) {
// //             continue;
// //           }
// //         }
// //       }
// //     } catch (e) {
// //       continue;
// //     }
// //   }

// //   if (!success) {
// //     throw Exception('Failed to load banners from all endpoints');
// //   }

// //   return json.decode(responseBody);
// // }

// // // // Event Bus
// // // class GlobalEventBus {
// // //   static final GlobalEventBus _instance = GlobalEventBus._internal();
// // //   factory GlobalEventBus() => _instance;

// // //   final StreamController<RefreshPageEvent> _controller =
// // //       StreamController<RefreshPageEvent>.broadcast();

// // //   GlobalEventBus._internal();

// // //   Stream<RefreshPageEvent> get events => _controller.stream;
// // //   void fire(RefreshPageEvent event) => _controller.add(event);
// // //   void dispose() => _controller.close();
// // // }

// // // class RefreshPageEvent {
// // //   final String pageId;
// // //   RefreshPageEvent(this.pageId);
// // // }

// // // Main Banner Slider Widget
// // class BannerSlider extends StatefulWidget {
// //   final Function(bool)? onFocusChange;
// //   final FocusNode focusNode;

// //   const BannerSlider({
// //     Key? key,
// //     this.onFocusChange,
// //     required this.focusNode,
// //   }) : super(key: key);

// //   @override
// //   _BannerSliderState createState() => _BannerSliderState();
// // }

// // class _BannerSliderState extends State<BannerSlider> with SingleTickerProviderStateMixin {
// //   final SocketService _socketService = SocketService();
// //   List<NewsItemModel> bannerList = [];
// //   Map<String, Color> bannerColors = {};
// //   bool isLoading = true;
// //   bool isLoadingFromCache = false;
// //   String errorMessage = '';
// //   late PageController _pageController;
// //   Timer? _timer;
// //   String? selectedContentId;
// //   final FocusNode _buttonFocusNode = FocusNode();
// //   bool _isNavigating = false;
// //   final PaletteColorService _paletteColorService = PaletteColorService();
// //   Map<String, Uint8List> _bannerCache = {};
// //   late FocusProvider _refreshProvider;
// //   final ImageCacheService _imageCacheService = ImageCacheService();

// //   // New variables for enhanced caching
// //   bool _isBackgroundRefreshing = false;

// //   // Animation controllers for shimmer effect
// //   late AnimationController _shimmerController;
// //   late Animation<double> _shimmerAnimation;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeShimmerAnimation();
// //     _initializeSliderWithEnhancedCaching();
// //   }

// //   void _initializeShimmerAnimation() {
// //     _shimmerController = AnimationController(
// //       duration: const Duration(milliseconds: 1500),
// //       vsync: this,
// //     )..repeat();

// //     _shimmerAnimation = Tween<double>(
// //       begin: -1.0,
// //       end: 2.0,
// //     ).animate(CurvedAnimation(
// //       parent: _shimmerController,
// //       curve: Curves.easeInOut,
// //     ));
// //   }

// //   @override
// //   void dispose() {
// //     if (_pageController.hasClients) {
// //       _pageController.dispose();
// //     }
// //     _socketService.dispose();
// //     _shimmerController.dispose();
// //     if (_timer != null && _timer!.isActive) {
// //       _timer!.cancel();
// //     }
// //     _buttonFocusNode.dispose();
// //     super.dispose();
// //   }

// //   // Enhanced initialization with smart caching
// //   Future<void> _initializeSliderWithEnhancedCaching() async {
// //     try {
// //       await _imageCacheService.init();
// //       _socketService.initSocket();
// //       _pageController = PageController();

// //       // Validate cache integrity on startup
// //       final isValidCache = await EnhancedSmartCacheManager.validateCacheIntegrity(
// //           EnhancedSmartCacheManager.BANNER_CACHE_KEY);

// //       if (!isValidCache) {
// //         print('⚠️ Invalid cache detected, will fetch fresh data');
// //       }

// //       _buttonFocusNode.addListener(() {
// //         if (_buttonFocusNode.hasFocus) {
// //           widget.onFocusChange?.call(true);
// //         }
// //       });

// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         if (mounted) {
// //           context.read<FocusProvider>().setWatchNowFocusNode(_buttonFocusNode);
// //         }
// //       });

// //       _buttonFocusNode.addListener(_onButtonFocusNode);

// //       // Use smart loading strategy
// //       await _smartDataLoadWithStrategy();
// //     } catch (e) {
// //       print('Error initializing slider: $e');
// //       if (mounted) {
// //         setState(() {
// //           errorMessage = 'Failed to initialize: $e';
// //           isLoading = false;
// //         });
// //       }
// //     }
// //   }

// //   // Smart data loading with enhanced caching strategy
// //   Future<void> _smartDataLoadWithStrategy() async {
// //     print('🚀 Starting smart data load with caching strategy...');

// //     try {
// //       // Step 1: Try to load from cache first (for immediate display)
// //       final cacheLoaded = await _loadFromCacheFirst();

// //       // Step 2: Always fetch fresh data from API (update cache)
// //       await _fetchAndUpdateCache(hasInitialData: cacheLoaded);
// //     } catch (e) {
// //       print('❌ Error in smart data load: $e');

// //       if (mounted) {
// //         setState(() {
// //           if (bannerList.isEmpty) {
// //             errorMessage = 'Failed to load content: $e';
// //             isLoading = false;
// //           }
// //           isLoadingFromCache = false;
// //         });
// //       }
// //     }
// //   }

// //   // Load from cache first for immediate display
// //   Future<bool> _loadFromCacheFirst() async {
// //     try {
// //       print('📦 Loading from cache for immediate display...');

// //       final cachedData = await EnhancedSmartCacheManager.getCachedData(
// //           EnhancedSmartCacheManager.BANNER_CACHE_KEY);

// //       if (cachedData != null && cachedData.data.isNotEmpty) {
// //         print(
// //             '✅ Cache found with ${cachedData.data.length} items (Age: ${cachedData.getAgeInMinutes()} minutes)');

// //         final processedBanners = await _processRawBannerData(cachedData.data);

// //         if (processedBanners.isNotEmpty && mounted) {
// //           setState(() {
// //             bannerList = processedBanners;
// //             selectedContentId = bannerList.isNotEmpty ? bannerList[0].id : null;
// //             isLoading = false;
// //             errorMessage = '';
// //           });

// //           print('✅ Displayed ${bannerList.length} banners from cache');

// //           // Start UI components
// //           if (bannerList.isNotEmpty) {
// //             _startAutoSlide();
// //             _fetchBannerColors();
// //             _preloadImages();
// //           }

// //           return true; // Cache data loaded successfully
// //         }
// //       } else {
// //         print('❌ No cache found or cache is empty');
// //       }

// //       return false; // No cache data available
// //     } catch (e) {
// //       print('❌ Error loading from cache: $e');
// //       return false;
// //     }
// //   }

// //   // Fetch fresh data and update cache
// //   Future<void> _fetchAndUpdateCache({bool hasInitialData = false}) async {
// //     try {
// //       print('🌐 Fetching fresh data from API...');

// //       // Show appropriate loading indicators
// //       if (mounted) {
// //         setState(() {
// //           if (hasInitialData) {
// //             _isBackgroundRefreshing = true;
// //             isLoadingFromCache = true;
// //           } else {
// //             isLoading = true;
// //             errorMessage = '';
// //           }
// //         });
// //       }

// //       // Fetch fresh data from API
// //       final List<dynamic> responseData = await fetchBannersData();
// //       print('✅ API returned ${responseData.length} items');

// //       // Check if data has actually changed
// //       final cachedData = await EnhancedSmartCacheManager.getCachedData(
// //           EnhancedSmartCacheManager.BANNER_CACHE_KEY);
// //       final hasChanges = EnhancedSmartCacheManager.hasDataChanged(cachedData, responseData);

// //       // Always update cache with fresh data
// //       await EnhancedSmartCacheManager.setCachedData(
// //           EnhancedSmartCacheManager.BANNER_CACHE_KEY, responseData);
// //       print('💾 Cache updated with fresh data');

// //       // Process fresh data
// //       final processedBanners = await _processRawBannerData(responseData);

// //       if (mounted) {
// //         setState(() {
// //           bannerList = processedBanners;
// //           selectedContentId = bannerList.isNotEmpty ? bannerList[0].id : null;
// //           isLoading = false;
// //           isLoadingFromCache = false;
// //           _isBackgroundRefreshing = false;
// //           errorMessage = '';
// //         });

// //         // Show update notification if data changed and user was seeing cached data
// //         if (hasInitialData && hasChanges && context.mounted) {
// //           _showUpdateNotification('Content updated');
// //         }
// //       }

// //       print('✅ UI updated with ${bannerList.length} fresh banners');

// //       // Initialize UI components if this is the first successful load
// //       if (bannerList.isNotEmpty) {
// //         if (_timer == null || !_timer!.isActive) {
// //           _startAutoSlide();
// //         }
// //         _fetchBannerColors();
// //         _preloadImages();
// //       }
// //     } catch (e) {
// //       print('❌ Error fetching from API: $e');

// //       if (mounted) {
// //         setState(() {
// //           isLoadingFromCache = false;
// //           _isBackgroundRefreshing = false;

// //           // Only show error if we have no data to display
// //           if (!hasInitialData) {
// //             errorMessage = 'Failed to load banners: $e';
// //             isLoading = false;
// //           } else {
// //             isLoading = false;
// //           }
// //         });
// //       }

// //       // Show error notification if user was seeing cached data
// //       if (hasInitialData && mounted && context.mounted) {
// //         _showUpdateNotification('Failed to update content', isError: true);
// //       }
// //     }
// //   }

// //   // Force refresh method
// //   Future<void> _forceRefresh() async {
// //     print('🔄 Force refresh triggered');

// //     try {
// //       if (mounted) {
// //         setState(() {
// //           isLoading = true;
// //           errorMessage = '';
// //         });
// //       }

// //       // Fetch fresh data from API
// //       final List<dynamic> responseData = await fetchBannersData();

// //       // Update cache
// //       await EnhancedSmartCacheManager.setCachedData(
// //           EnhancedSmartCacheManager.BANNER_CACHE_KEY, responseData);

// //       // Process and update UI
// //       final processedBanners = await _processRawBannerData(responseData);

// //       if (mounted) {
// //         setState(() {
// //           bannerList = processedBanners;
// //           selectedContentId = bannerList.isNotEmpty ? bannerList[0].id : null;
// //           isLoading = false;
// //           errorMessage = '';
// //         });
// //       }

// //       _showUpdateNotification('Content refreshed!');
// //     } catch (e) {
// //       print('❌ Force refresh failed: $e');

// //       if (mounted) {
// //         setState(() {
// //           if (bannerList.isEmpty) {
// //             errorMessage = 'Failed to refresh: $e';
// //           }
// //           isLoading = false;
// //         });
// //       }

// //       _showUpdateNotification('Refresh failed', isError: true);
// //     }
// //   }

// //   // Clear cache and reload
// //   Future<void> _clearCacheAndReload() async {
// //     try {
// //       await EnhancedSmartCacheManager.clearCache(
// //           EnhancedSmartCacheManager.BANNER_CACHE_KEY);

// //       if (mounted) {
// //         setState(() {
// //           bannerList.clear();
// //           isLoading = true;
// //           errorMessage = '';
// //         });
// //       }

// //       await _smartDataLoadWithStrategy();
// //       _showUpdateNotification('Cache cleared and reloaded');
// //     } catch (e) {
// //       print('Error clearing cache: $e');
// //       _showUpdateNotification('Failed to clear cache', isError: true);
// //     }
// //   }

// //   // Get cache information
// //   Future<Map<String, dynamic>> _getCacheInfo() async {
// //     return await EnhancedSmartCacheManager.getCacheStats(
// //         EnhancedSmartCacheManager.BANNER_CACHE_KEY);
// //   }

// //   // Show update notification
// //   void _showUpdateNotification(String message, {bool isError = false}) {
// //     if (!mounted || !context.mounted) return;

// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           children: [
// //             Icon(
// //               isError ? Icons.error_outline : Icons.refresh,
// //               color: Colors.white,
// //               size: 16,
// //             ),
// //             SizedBox(width: 8),
// //             Text(message),
// //           ],
// //         ),
// //         duration: Duration(seconds: 2),
// //         backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
// //         behavior: SnackBarBehavior.floating,
// //         margin: EdgeInsets.only(
// //           bottom: MediaQuery.of(context).size.height - 100,
// //           left: 20,
// //           right: 20,
// //         ),
// //       ),
// //     );
// //   }

// //   // Process raw banner data
// //   Future<List<NewsItemModel>> _processRawBannerData(List<dynamic> rawData) async {
// //     List<NewsItemModel> filteredBanners = [];
// //     int processedCount = 0;
// //     int errorCount = 0;

// //     for (var banner in rawData) {
// //       try {
// //         bool isActive = _checkBannerStatus(banner);

// //         if (isActive) {
// //           try {
// //             final newsItem = NewsItemModel.fromJson(banner);
// //             filteredBanners.add(newsItem);
// //             processedCount++;
// //           } catch (e) {
// //             errorCount++;
// //             print('❌ Error creating NewsItemModel for banner ${banner['id']}: $e');
// //           }
// //         }
// //       } catch (e) {
// //         errorCount++;
// //         print('❌ Error processing banner: $e');
// //       }
// //     }

// //     print('📊 Processed: $processedCount active banners, $errorCount errors');
// //     return filteredBanners;
// //   }

// //   // Helper method to check banner status
// //   bool _checkBannerStatus(dynamic banner) {
// //     try {
// //       if (banner['status'] != null) {
// //         var status = banner['status'];

// //         if (status is String) {
// //           return status == "1" ||
// //               status.toLowerCase() == "active" ||
// //               status.toLowerCase() == "true";
// //         } else if (status is int) {
// //           return status == 1;
// //         } else if (status is bool) {
// //           return status;
// //         }
// //       }
// //       return true; // Default to active if no status field
// //     } catch (e) {
// //       print('Error checking banner status: $e');
// //       return false;
// //     }
// //   }

// //   // Force refresh method for external calls
// //   Future<void> _loadData({bool forceRefresh = false}) async {
// //     print('🔄 Manual refresh triggered - forceRefresh: $forceRefresh');

// //     if (forceRefresh) {
// //       await _forceRefresh();
// //     } else {
// //       await _smartDataLoadWithStrategy();
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Consumer<FocusProvider>(
// //       builder: (context, focusProvider, child) {
// //         return Scaffold(
// //           backgroundColor: cardColor,
// //           body: _buildBody(focusProvider),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildBody(FocusProvider focusProvider) {
// //     // Show loading only if no data and initial load
// //     if (isLoading && bannerList.isEmpty) {
// //       return _buildLoadingWidget();
// //     }

// //     // Show error only if no data and not loading
// //     if (errorMessage.isNotEmpty && bannerList.isEmpty && !isLoading) {
// //       return _buildEnhancedErrorWidget();
// //     }

// //     // Show empty state only if no data, not loading, and no error
// //     if (bannerList.isEmpty && !isLoading && errorMessage.isEmpty) {
// //       return _buildEmptyWidget();
// //     }

// //     // Show banner slider if we have data
// //     return _buildBannerSlider(focusProvider);
// //   }

// //   Widget _buildLoadingWidget() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           SpinKitFadingCircle(color: borderColor, size: 50.0),
// //           SizedBox(height: 20),
// //           Text(
// //             isLoadingFromCache ? 'Loading from cache...' : 'Loading...',
// //             style: TextStyle(
// //               color: hintColor,
// //               fontSize: nametextsz,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // Enhanced error widget with cache options
// //   Widget _buildEnhancedErrorWidget() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(Icons.error_outline, color: Colors.red, size: 50),
// //           SizedBox(height: 20),
// //           Text(
// //             'Something Went Wrong',
// //             style: TextStyle(
// //               fontSize: menutextsz,
// //               color: Colors.red,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           SizedBox(height: 10),
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 20),
// //             child: Text(
// //               errorMessage,
// //               style: TextStyle(fontSize: minitextsz, color: hintColor),
// //               textAlign: TextAlign.center,
// //             ),
// //           ),
// //           SizedBox(height: 30),

// //           // Action buttons
// //           Wrap(
// //             spacing: 10,
// //             children: [
// //               ElevatedButton.icon(
// //                 onPressed: _forceRefresh,
// //                 icon: Icon(Icons.refresh),
// //                 label: Text('Retry'),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.blue,
// //                   foregroundColor: Colors.white,
// //                 ),
// //               ),
// //               ElevatedButton.icon(
// //                 onPressed: _clearCacheAndReload,
// //                 icon: Icon(Icons.clear_all),
// //                 label: Text('Clear Cache'),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.orange,
// //                   foregroundColor: Colors.white,
// //                 ),
// //               ),
// //             ],
// //           ),

// //           // Cache info (for debugging)
// //           SizedBox(height: 20),
// //           FutureBuilder<Map<String, dynamic>>(
// //             future: _getCacheInfo(),
// //             builder: (context, snapshot) {
// //               if (snapshot.hasData) {
// //                 final cacheInfo = snapshot.data!;
// //                 return Container(
// //                   padding: EdgeInsets.all(10),
// //                   margin: EdgeInsets.symmetric(horizontal: 20),
// //                   decoration: BoxDecoration(
// //                     color: Colors.grey.shade800,
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       Text(
// //                         'Cache Info',
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       SizedBox(height: 5),
// //                       Text(
// //                         'Exists: ${cacheInfo['exists']}\n'
// //                         'Items: ${cacheInfo['itemCount']}\n'
// //                         'Age: ${cacheInfo['ageMinutes']} min\n'
// //                         'Expired: ${cacheInfo['isExpired']}',
// //                         style: TextStyle(
// //                           color: Colors.white70,
// //                           fontSize: 12,
// //                         ),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               }
// //               return SizedBox.shrink();
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildEmptyWidget() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(
// //             Icons.image_not_supported,
// //             color: hintColor.withOpacity(0.5),
// //             size: 50,
// //           ),
// //           SizedBox(height: 20),
// //           Text(
// //             'No content available',
// //             style: TextStyle(color: hintColor, fontSize: nametextsz),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildBannerSlider(FocusProvider focusProvider) {
// //     return Stack(
// //       children: [
// //         // Page View
// //         PageView.builder(
// //           controller: _pageController,
// //           itemCount: bannerList.length,
// //           onPageChanged: (index) {
// //             if (mounted) {
// //               setState(() {
// //                 selectedContentId = bannerList[index].contentId.toString();
// //               });
// //             }
// //           },
// //           itemBuilder: (context, index) {
// //             final banner = bannerList[index];
// //             return Stack(
// //               alignment: AlignmentDirectional.topCenter,
// //               children: [
// //                 _buildBannerWithShimmer(banner, focusProvider),
// //                 _buildGradientOverlay(),
// //               ],
// //             );
// //           },
// //         ),

// //         // Watch Now Button
// //         _buildWatchNowButton(focusProvider),

// //         // Page indicators
// //         if (bannerList.length > 1) _buildPageIndicators(),

// //         // Enhanced cache status indicator
// //         if (_isBackgroundRefreshing || isLoadingFromCache)
// //           _buildEnhancedCacheStatusIndicator(),
// //       ],
// //     );
// //   }

// //   Widget _buildGradientOverlay() {
// //     return Container(
// //       margin: const EdgeInsets.only(top: 1),
// //       width: screenwdt,
// //       height: screenhgt,
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topCenter,
// //           end: Alignment.bottomCenter,
// //           colors: [
// //             Colors.black.withOpacity(0.3),
// //             Colors.transparent,
// //             Colors.black.withOpacity(0.7),
// //           ],
// //           stops: [0.0, 0.5, 1.0],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildWatchNowButton(FocusProvider focusProvider) {
// //     return Positioned(
// //       top: screenhgt * 0.03,
// //       left: screenwdt * 0.02,
// //       child: Focus(
// //         focusNode: _buttonFocusNode,
// //         onKeyEvent: _handleKeyEvent,
// //         child: GestureDetector(
// //           onTap: _handleWatchNowTap,
// //           child: RandomLightColorWidget(
// //             hasFocus: focusProvider.isButtonFocused,
// //             childBuilder: (Color randomColor) {
// //               return AnimatedContainer(
// //                 duration: Duration(milliseconds: 200),
// //                 margin: EdgeInsets.all(screenwdt * 0.001),
// //                 padding: EdgeInsets.symmetric(
// //                   vertical: screenhgt * 0.02,
// //                   horizontal: screenwdt * 0.02,
// //                 ),
// //                 decoration: BoxDecoration(
// //                   color: focusProvider.isButtonFocused
// //                       ? Colors.black87
// //                       : Colors.black.withOpacity(0.6),
// //                   borderRadius: BorderRadius.circular(12),
// //                   border: Border.all(
// //                     color: focusProvider.isButtonFocused
// //                         ? focusProvider.currentFocusColor ?? randomColor
// //                         : Colors.white.withOpacity(0.3),
// //                     width: focusProvider.isButtonFocused ? 3.0 : 1.0,
// //                   ),
// //                   boxShadow: focusProvider.isButtonFocused
// //                       ? [
// //                           BoxShadow(
// //                             color: (focusProvider.currentFocusColor ?? randomColor)
// //                                 .withOpacity(0.5),
// //                             blurRadius: 20.0,
// //                             spreadRadius: 5.0,
// //                           ),
// //                         ]
// //                       : [
// //                           BoxShadow(
// //                             color: Colors.black.withOpacity(0.3),
// //                             blurRadius: 10.0,
// //                             spreadRadius: 2.0,
// //                           ),
// //                         ],
// //                 ),
// //                 child: Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     Icon(
// //                       Icons.play_arrow,
// //                       color: focusProvider.isButtonFocused
// //                           ? focusProvider.currentFocusColor ?? randomColor
// //                           : hintColor,
// //                       size: menutextsz * 1.2,
// //                     ),
// //                     SizedBox(width: 8),
// //                     Text(
// //                       'Watch Now',
// //                       style: TextStyle(
// //                         fontSize: menutextsz,
// //                         color: focusProvider.isButtonFocused
// //                             ? focusProvider.currentFocusColor ?? randomColor
// //                             : hintColor,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             },
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildPageIndicators() {
// //     return Positioned(
// //       top: screenhgt * 0.05,
// //       right: screenwdt * 0.05,
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: bannerList.asMap().entries.map((entry) {
// //           int index = entry.key;
// //           bool isSelected = selectedContentId == bannerList[index].contentId;

// //           return AnimatedContainer(
// //             duration: Duration(milliseconds: 300),
// //             margin: EdgeInsets.symmetric(horizontal: 4),
// //             width: isSelected ? 12 : 8,
// //             height: isSelected ? 12 : 8,
// //             decoration: BoxDecoration(
// //               color: isSelected
// //                   ? Colors.white
// //                   : Colors.white.withOpacity(0.5),
// //               shape: BoxShape.circle,
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.3),
// //                   blurRadius: 4,
// //                   spreadRadius: 1,
// //                 ),
// //               ],
// //             ),
// //           );
// //         }).toList(),
// //       ),
// //     );
// //   }

// //   // Enhanced cache status indicator with more details
// //   Widget _buildEnhancedCacheStatusIndicator() {
// //     return Positioned(
// //       top: screenhgt * 0.01,
// //       right: screenwdt * 0.01,
// //       child: FutureBuilder<Map<String, dynamic>>(
// //         future: _getCacheInfo(),
// //         builder: (context, snapshot) {
// //           final cacheInfo = snapshot.data ?? {};

// //           return AnimatedContainer(
// //             duration: Duration(milliseconds: 300),
// //             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //             decoration: BoxDecoration(
// //               color: _isBackgroundRefreshing
// //                   ? Colors.blue.withOpacity(0.9)
// //                   : Colors.orange.withOpacity(0.9),
// //               borderRadius: BorderRadius.circular(12),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.3),
// //                   blurRadius: 4,
// //                   spreadRadius: 1,
// //                 ),
// //               ],
// //             ),
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 SizedBox(
// //                   width: 12,
// //                   height: 12,
// //                   child: CircularProgressIndicator(
// //                     strokeWidth: 2,
// //                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //                   ),
// //                 ),
// //                 SizedBox(width: 6),
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     Text(
// //                       _isBackgroundRefreshing ? 'Updating...' : 'Loading...',
// //                       style: TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 10,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                     if (cacheInfo['ageMinutes'] != null)
// //                       Text(
// //                         'Cache: ${cacheInfo['ageMinutes']}m old',
// //                         style: TextStyle(
// //                           color: Colors.white70,
// //                           fontSize: 8,
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildBannerWithShimmer(NewsItemModel banner, FocusProvider focusProvider) {
// //     return Container(
// //       margin: const EdgeInsets.only(top: 1),
// //       width: screenwdt,
// //       height: screenhgt,
// //       child: Stack(
// //         children: [
// //           // Main banner image
// //           CachedNetworkImage(
// //             imageUrl: banner.banner,
// //             fit: BoxFit.fill,
// //             placeholder: (context, url) => Image.asset('assets/streamstarting.gif'),
// //             errorWidget: (context, url, error) => Image.asset('assets/streamstarting.gif'),
// //             cacheKey: banner.contentId,
// //             fadeInDuration: Duration(milliseconds: 500),
// //             memCacheHeight: 800,
// //             memCacheWidth: 1200,
// //             width: screenwdt,
// //             height: screenhgt,
// //           ),

// //           // Shimmer effect overlay when focused
// //           if (focusProvider.isButtonFocused)
// //             AnimatedBuilder(
// //               animation: _shimmerAnimation,
// //               builder: (context, child) {
// //                 return Positioned.fill(
// //                   child: Container(
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
// //                         end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
// //                         colors: [
// //                           Colors.transparent,
// //                           Colors.white.withOpacity(0.1),
// //                           Colors.white.withOpacity(0.2),
// //                           Colors.white.withOpacity(0.1),
// //                           Colors.transparent,
// //                         ],
// //                         stops: [0.0, 0.3, 0.5, 0.7, 1.0],
// //                       ),
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),

// //           // Enhanced glow effect when focused
// //           if (focusProvider.isButtonFocused)
// //             Positioned.fill(
// //               child: Container(
// //                 decoration: BoxDecoration(
// //                   gradient: RadialGradient(
// //                     center: Alignment.center,
// //                     radius: 0.8,
// //                     colors: [
// //                       (focusProvider.currentFocusColor ?? Colors.blue).withOpacity(0.1),
// //                       Colors.transparent,
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),

// //           // Border glow effect
// //           if (focusProvider.isButtonFocused)
// //             Positioned.fill(
// //               child: Container(
// //                 decoration: BoxDecoration(
// //                   border: Border.all(
// //                     color: (focusProvider.currentFocusColor ?? Colors.blue).withOpacity(0.3),
// //                     width: 2.0,
// //                   ),
// //                   borderRadius: BorderRadius.circular(8),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   // Event Handlers
// //   KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
// //     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
// //       if (_pageController.hasClients &&
// //           _pageController.page != null &&
// //           _pageController.page! < bannerList.length - 1) {
// //         _pageController.nextPage(
// //           duration: Duration(milliseconds: 300),
// //           curve: Curves.easeInOut,
// //         );
// //         return KeyEventResult.handled;
// //       }
// //     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
// //       if (_pageController.hasClients &&
// //           _pageController.page != null &&
// //           _pageController.page! > 0) {
// //         _pageController.previousPage(
// //           duration: Duration(milliseconds: 300),
// //           curve: Curves.easeInOut,
// //         );
// //         return KeyEventResult.handled;
// //       }
// //     } else if (event is KeyDownEvent) {
// //       if (event.logicalKey == LogicalKeyboardKey.select ||
// //           event.logicalKey == LogicalKeyboardKey.enter) {
// //         _handleWatchNowTap();
// //         return KeyEventResult.handled;
// //       }
// //     }
// //     return KeyEventResult.ignored;
// //   }

// //   void _handleWatchNowTap() {
// //     if (selectedContentId != null && bannerList.isNotEmpty) {
// //       try {
// //         final banner = bannerList.firstWhere(
// //           (b) => b.contentId == selectedContentId,
// //           orElse: () => bannerList.first,
// //         );
// //         fetchAndPlayVideo(banner.id, bannerList);
// //       } catch (e) {
// //         print('Error in watch now tap: $e');
// //       }
// //     }
// //   }

// //   // Preload images in background for smooth experience
// //   Future<void> _preloadImages() async {
// //     for (final banner in bannerList) {
// //       try {
// //         final isCached = await _imageCacheService.isCached(banner.banner);

// //         if (!isCached) {
// //           _imageCacheService.downloadAndCacheImage(banner.banner).catchError((e) {
// //             print('Failed to preload image: ${banner.banner}');
// //           });
// //         }
// //       } catch (e) {
// //         print('Error preloading image: $e');
// //       }
// //     }
// //   }

// //   @override
// //   void didChangeDependencies() {
// //     super.didChangeDependencies();

// //     try {
// //       _refreshProvider = context.watch<FocusProvider>();

// //       if (_refreshProvider.shouldRefreshBanners ||
// //           _refreshProvider.shouldRefreshLastPlayed) {
// //         _handleProviderRefresh();
// //       }
// //     } catch (e) {
// //       print('Error in didChangeDependencies: $e');
// //     }
// //   }

// //   Future<void> _handleProviderRefresh() async {
// //     if (!mounted) return;

// //     try {
// //       if (_refreshProvider.shouldRefreshBanners) {
// //         await _fetchAndUpdateCache(hasInitialData: bannerList.isNotEmpty);
// //         _refreshProvider.markBannersRefreshed();
// //       }
// //     } catch (e) {
// //       print('Error in provider refresh: $e');
// //     }
// //   }

// //   Future<void> _fetchBannerColors() async {
// //     for (var banner in bannerList) {
// //       try {
// //         final imageUrl = banner.banner;
// //         final secondaryColor = await _paletteColorService.getSecondaryColor(imageUrl);

// //         if (mounted) {
// //           setState(() {
// //             bannerColors[banner.contentId] = secondaryColor;
// //           });
// //         }
// //       } catch (e) {
// //         print('Error fetching banner color: $e');
// //       }
// //     }
// //   }

// //   void _startAutoSlide() {
// //     if (bannerList.isNotEmpty && (_timer == null || !_timer!.isActive)) {
// //       _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
// //         if (!mounted) {
// //           timer.cancel();
// //           return;
// //         }

// //         try {
// //           if (_pageController.hasClients) {
// //             if (_pageController.page == bannerList.length - 1) {
// //               _pageController.jumpToPage(0);
// //             } else {
// //               _pageController.nextPage(
// //                 duration: const Duration(milliseconds: 300),
// //                 curve: Curves.easeIn,
// //               );
// //             }
// //           }
// //         } catch (e) {
// //           print('Error in auto slide: $e');
// //         }
// //       });
// //     }
// //   }

// //   void _onButtonFocusNode() {
// //     try {
// //       if (_buttonFocusNode.hasFocus) {
// //         final random = Random();
// //         final color = Color.fromRGBO(
// //           random.nextInt(256),
// //           random.nextInt(256),
// //           random.nextInt(256),
// //           1,
// //         );
// //         if (mounted) {
// //           context.read<FocusProvider>().setButtonFocus(true, color: color);
// //           context.read<ColorProvider>().updateColor(color, true);
// //         }
// //       } else {
// //         if (mounted) {
// //           context.read<FocusProvider>().resetFocus();
// //           context.read<ColorProvider>().resetColor();
// //         }
// //       }
// //     } catch (e) {
// //       print('Error in button focus handler: $e');
// //     }
// //   }

// //   Future<void> fetchAndPlayVideo(String contentId, List<NewsItemModel> channelList) async {
// //     if (_isNavigating) {
// //       return;
// //     }

// //     _isNavigating = true;

// //     bool shouldPlayVideo = true;
// //     bool shouldPop = true;

// //     try {
// //       if (mounted) {
// //         showDialog(
// //           context: context,
// //           barrierDismissible: false,
// //           builder: (BuildContext context) {
// //             return WillPopScope(
// //               onWillPop: () async {
// //                 shouldPlayVideo = false;
// //                 shouldPop = false;
// //                 return true;
// //               },
// //               child: Center(
// //                 child: Container(
// //                   padding: EdgeInsets.all(20),
// //                   decoration: BoxDecoration(
// //                     color: Colors.black87,
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                   child: Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       SpinKitFadingCircle(
// //                         color: borderColor,
// //                         size: 50.0,
// //                       ),
// //                       SizedBox(height: 15),
// //                       Text(
// //                         'Loading video...',
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontSize: nametextsz,
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

// //       final responseData = await fetchVideoDataByIdFromBanners(contentId);

// //       if (shouldPop && mounted && context.mounted) {
// //         Navigator.of(context, rootNavigator: true).pop();
// //       }

// //       if (shouldPlayVideo && mounted && context.mounted) {
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (context) => VideoScreen(
// //               videoUrl: responseData['url'] ?? '',
// //               channelList: channelList,
// //               videoId: int.tryParse(contentId) ?? 0,
// //               videoType: responseData['type'] ?? '',
// //               isLive: true,
// //               isVOD: false,
// //               bannerImageUrl: responseData['banner'] ?? '',
// //               startAtPosition: Duration.zero,
// //               isBannerSlider: true,
// //               source: 'isBannerSlider',
// //               isSearch: false,
// //               unUpdatedUrl: responseData['url'] ?? '',
// //               name: responseData['name'] ?? '',
// //               liveStatus: true,
// //               seasonId: null,
// //               isLastPlayedStored: false,
// //             ),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       if (shouldPop && mounted && context.mounted) {
// //         Navigator.of(context, rootNavigator: true).pop();
// //       }

// //       if (mounted && context.mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Something went wrong'),
// //             duration: Duration(seconds: 3),
// //             backgroundColor: Colors.red.shade700,
// //           ),
// //         );
// //       }
// //     } finally {
// //       _isNavigating = false;
// //     }
// //   }

// //   Uint8List _getCachedImage(String base64String) {
// //     try {
// //       if (!_bannerCache.containsKey(base64String)) {
// //         final base64Content = base64String.split(',').last;
// //         _bannerCache[base64String] = base64Decode(base64Content);
// //       }
// //       return _bannerCache[base64String]!;
// //     } catch (e) {
// //       return Uint8List.fromList([
// //         0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
// //         0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
// //         0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
// //         0x0C, 0x49, 0x44, 0x41, 0x54, 0x78, 0x01, 0x63, 0x00, 0x01, 0x00, 0x05,
// //         0x00, 0x01, 0xE2, 0x26, 0x05, 0x9B, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
// //         0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
// //       ]);
// //     }
// //   }
// // }



// //test

// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/video_widget/socket_service.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
// import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
// import 'package:mobi_tv_entertainment/widgets/utils/random_light_color_widget.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../widgets/small_widgets/app_assets.dart';

// // Banner Data Model
// class BannerDataModel {
//   final int id;
//   final String title;
//   final String banner;
//   final int contentType;
//   final int? contentId;
//   final String? sourceType;
//   final String? url;
//   final int status;
//   final String createdAt;
//   final String updatedAt;
//   final String? deletedAt;

//   BannerDataModel({
//     required this.id,
//     required this.title,
//     required this.banner,
//     required this.contentType,
//     this.contentId,
//     this.sourceType,
//     this.url,
//     required this.status,
//     required this.createdAt,
//     required this.updatedAt,
//     this.deletedAt,
//   });

//   factory BannerDataModel.fromJson(Map<String, dynamic> json) {
//     return BannerDataModel(
//       id: json['id'] ?? 0,
//       title: json['title'] ?? '',
//       banner: json['banner'] ?? '',
//       contentType: json['content_type'] ?? 1,
//       contentId: json['content_id'],
//       sourceType: json['source_type'],
//       url: json['url'],
//       status: json['status'] ?? 0,
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       deletedAt: json['deleted_at'],
//     );
//   }

//   bool get isActive => status == 1 && deletedAt == null;

//   NewsItemModel toNewsItemModel() {
//     return NewsItemModel(
//       id: id.toString(),
//       name: title,
//       banner: banner,
//       contentId: id.toString(),
//       type: contentType.toString(),
//       url: url ?? '',
//       status: status.toString(), 
//       unUpdatedUrl: '', 
//       poster: '', 
//       image: '',
//     );
//   }
// }





// // Simplified Cache Manager
// class SimpleCacheManager {
//   static const String BANNER_CACHE_KEY = 'simple_banners_cache';

//   // Get cached data
//   static Future<List<dynamic>?> getCachedData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cachedString = prefs.getString(BANNER_CACHE_KEY);
      
//       if (cachedString != null && cachedString.isNotEmpty) {
//         final List<dynamic> cachedData = json.decode(cachedString);
//         print('📦 Cache found: ${cachedData.length} items');
//         return cachedData;
//       }
//     } catch (e) {
//       print('❌ Error reading cache: $e');
//     }
//     return null;
//   }

//   // Save data to cache
//   static Future<void> setCachedData(List<dynamic> data) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(BANNER_CACHE_KEY, json.encode(data));
//       print('💾 Cache updated: ${data.length} items saved');
//     } catch (e) {
//       print('❌ Error saving cache: $e');
//     }
//   }

//   // Clear cache
//   static Future<void> clearCache() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(BANNER_CACHE_KEY);
//       print('🗑️ Cache cleared');
//     } catch (e) {
//       print('❌ Error clearing cache: $e');
//     }
//   }
// }

// // Auth Headers
// Future<Map<String, String>> getAuthHeaders() async {
//   String authKey = '';

//   if (authKey.isEmpty) {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       authKey = prefs.getString('auth_key') ?? '';
//       if (authKey.isNotEmpty) {
//         globalAuthKey = authKey;
//       }
//     } catch (e) {
//       print('Error getting auth key: $e');
//     }
//   }

//   if (authKey.isEmpty) {
//     authKey = 'vLQTuPZUxktl5mVW';
//   }

//   return {
//     'auth-key': authKey,
//     'Accept': 'application/json',
//     'Content-Type': 'application/json',
//   };
// }

// // API Configuration
// class ApiConfig {
//   static const String PRIMARY_BASE_URL = 'https://acomtv.coretechinfo.com/public/api';
//   static const List<String> BANNER_ENDPOINTS = [
//     '$PRIMARY_BASE_URL/getCustomImageSlider',
//   ];
// }

// // API Functions
// Future<Map<String, String>> fetchVideoDataByIdFromBanners(String contentId) async {
//   // First try cache
//   final cachedData = await SimpleCacheManager.getCachedData();
//   List<dynamic> responseData = [];

//   try {
//     if (cachedData != null && cachedData.isNotEmpty) {
//       responseData = cachedData;
//     } else {
//       // Fetch from API if no cache
//       responseData = await fetchBannersData();
//     }

//     final matchedItem = responseData.firstWhere(
//       (item) => item['id'].toString() == contentId,
//       orElse: () => null,
//     );

//     if (matchedItem == null) {
//       throw Exception('Content with ID $contentId not found');
//     }

//     return {
//       'url': matchedItem['url']?.toString() ?? '',
//       'type': matchedItem['content_type']?.toString() ?? '',
//       'banner': matchedItem['banner']?.toString() ?? '',
//       'name': matchedItem['title']?.toString() ?? '',
//       'stream_type': matchedItem['source_type']?.toString() ?? '',
//     };
//   } catch (e) {
//     throw Exception('Something went wrong: $e');
//   }
// }

// Future<List<dynamic>> fetchBannersData() async {
//   Map<String, String> headers = await getAuthHeaders();
//   bool success = false;
//   String responseBody = '';

//   for (int i = 0; i < ApiConfig.BANNER_ENDPOINTS.length; i++) {
//     String endpoint = ApiConfig.BANNER_ENDPOINTS[i];

//     try {
//       final response = await https
//           .get(Uri.parse(endpoint), headers: headers)
//           .timeout(Duration(seconds: 15));

//       if (response.statusCode == 200) {
//         String body = response.body.trim();
//         if (body.startsWith('[') || body.startsWith('{')) {
//           try {
//             json.decode(body);
//             responseBody = body;
//             success = true;
//             break;
//           } catch (e) {
//             continue;
//           }
//         }
//       }
//     } catch (e) {
//       continue;
//     }
//   }

//   if (!success) {
//     throw Exception('Failed to load banners from all endpoints');
//   }

//   return json.decode(responseBody);
// }

// // Main Banner Slider Widget
// class BannerSlider extends StatefulWidget {
//   final Function(bool)? onFocusChange;
//   final FocusNode focusNode;

//   const BannerSlider({
//     Key? key,
//     this.onFocusChange,
//     required this.focusNode,
//   }) : super(key: key);

//   @override
//   _BannerSliderState createState() => _BannerSliderState();
// }

// class _BannerSliderState extends State<BannerSlider> with SingleTickerProviderStateMixin {
//   final SocketService _socketService = SocketService();
//   List<BannerDataModel> bannerList = [];
//   List<NewsItemModel> newsItemList = [];
//   Map<String, Color> bannerColors = {};
//   bool isLoading = true;
//   String errorMessage = '';
//   late PageController _pageController;
//   Timer? _timer;
//   String? selectedContentId;
//   final FocusNode _buttonFocusNode = FocusNode();
//   bool _isNavigating = false;
//   final PaletteColorService _paletteColorService = PaletteColorService();
//   Map<String, Uint8List> _bannerCache = {};
//   late FocusProvider _refreshProvider;

//   // Animation controllers for shimmer effect
//   late AnimationController _shimmerController;
//   late Animation<double> _shimmerAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeShimmerAnimation();
//     _initializeSlider();
//   }

//   void _initializeShimmerAnimation() {
//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _shimmerAnimation = Tween<double>(
//       begin: -1.0,
//       end: 2.0,
//     ).animate(CurvedAnimation(
//       parent: _shimmerController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   @override
//   void dispose() {
//     if (_pageController.hasClients) {
//       _pageController.dispose();
//     }
//     _socketService.dispose();
//     _shimmerController.dispose();
//     if (_timer != null && _timer!.isActive) {
//       _timer!.cancel();
//     }
//     _buttonFocusNode.dispose();
//     super.dispose();
//   }

//   // Simplified initialization
//   Future<void> _initializeSlider() async {
//     try {
//       _socketService.initSocket();
//       _pageController = PageController();

//       _buttonFocusNode.addListener(() {
//         if (_buttonFocusNode.hasFocus) {
//           widget.onFocusChange?.call(true);
//         }
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           context.read<FocusProvider>().setWatchNowFocusNode(_buttonFocusNode);
//         }
//       });

//       _buttonFocusNode.addListener(_onButtonFocusNode);

//       // Start the simplified loading process
//       await _loadBannerData();
//     } catch (e) {
//       print('Error initializing slider: $e');
//       if (mounted) {
//         setState(() {
//           errorMessage = 'Failed to initialize: $e';
//           isLoading = false;
//         });
//       }
//     }
//   }

//   // Simplified data loading - shows cache immediately, then updates with fresh data
//   Future<void> _loadBannerData() async {
//     try {
//       print('🚀 Starting simplified data loading...');

//       // Step 1: Try to show cached data immediately
//       await _showCachedDataIfAvailable();

//       // Step 2: Always fetch fresh data and update cache
//       await _fetchAndUpdateCache();

//     } catch (e) {
//       print('❌ Error in data loading: $e');
//       if (mounted) {
//         setState(() {
//           if (bannerList.isEmpty) {
//             errorMessage = 'Failed to load content: $e';
//           }
//           isLoading = false;
//         });
//       }
//     }
//   }

//   // Show cached data immediately if available
//   Future<void> _showCachedDataIfAvailable() async {
//     try {
//       final cachedData = await SimpleCacheManager.getCachedData();
      
//       if (cachedData != null && cachedData.isNotEmpty) {
//         print('✅ Showing cached data: ${cachedData.length} items');
        
//         final processedBanners = _processRawBannerData(cachedData);
        
//         if (processedBanners.isNotEmpty && mounted) {
//           setState(() {
//             bannerList = processedBanners;
//             newsItemList = bannerList.map((banner) => banner.toNewsItemModel()).toList();
//             selectedContentId = bannerList.isNotEmpty ? bannerList[0].id.toString() : null;
//             isLoading = false;
//             errorMessage = '';
//           });

//           // Start UI components
//           _startAutoSlide();
//           _fetchBannerColors();
//         }
//       } else {
//         print('📭 No cached data found');
//       }
//     } catch (e) {
//       print('❌ Error showing cached data: $e');
//     }
//   }

//   // Fetch fresh data and update cache
//   Future<void> _fetchAndUpdateCache() async {
//     try {
//       print('🌐 Fetching fresh data from API...');
      
//       // Fetch fresh data
//       final List<dynamic> freshData = await fetchBannersData();
//       print('✅ API returned ${freshData.length} items');

//       // Update cache with fresh data
//       await SimpleCacheManager.setCachedData(freshData);

//       // Process fresh data
//       final processedBanners = _processRawBannerData(freshData);

//       if (mounted) {
//         setState(() {
//           bannerList = processedBanners;
//           newsItemList = bannerList.map((banner) => banner.toNewsItemModel()).toList();
//           selectedContentId = bannerList.isNotEmpty ? bannerList[0].id.toString() : null;
//           isLoading = false;
//           errorMessage = '';
//         });

//         print('✅ UI updated with ${bannerList.length} fresh banners');
//       }

//       // Initialize UI components if needed
//       if (bannerList.isNotEmpty) {
//         if (_timer == null || !_timer!.isActive) {
//           _startAutoSlide();
//         }
//         _fetchBannerColors();
//       }

//     } catch (e) {
//       print('❌ Error fetching fresh data: $e');
      
//       // Only show error if we have no cached data
//       if (mounted && bannerList.isEmpty) {
//         setState(() {
//           errorMessage = 'Failed to load banners: $e';
//           isLoading = false;
//         });
//       }
//     }
//   }

//   // Process raw banner data
//   List<BannerDataModel> _processRawBannerData(List<dynamic> rawData) {
//     List<BannerDataModel> activeBanners = [];
//     int processedCount = 0;
//     int inactiveCount = 0;

//     for (var bannerJson in rawData) {
//       try {
//         final banner = BannerDataModel.fromJson(bannerJson);
        
//         if (banner.isActive) {
//           activeBanners.add(banner);
//           processedCount++;
//         } else {
//           inactiveCount++;
//         }
//       } catch (e) {
//         print('❌ Error processing banner: $e');
//       }
//     }

//     print('📊 Processing complete: $processedCount active, $inactiveCount inactive');
//     return activeBanners;
//   }

//   // Public method for refreshing data
//   Future<void> refreshData() async {
//     print('🔄 Refresh requested');
//     await _loadBannerData();
//   }

//   // Clear cache and reload
//   Future<void> clearCacheAndReload() async {
//     try {
//       await SimpleCacheManager.clearCache();
      
//       if (mounted) {
//         setState(() {
//           bannerList.clear();
//           newsItemList.clear();
//           isLoading = true;
//           errorMessage = '';
//         });
//       }

//       await _loadBannerData();
//     } catch (e) {
//       print('Error clearing cache: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<FocusProvider>(
//       builder: (context, focusProvider, child) {
//         return Scaffold(
//           backgroundColor: cardColor,
//           body: _buildBody(focusProvider),
//         );
//       },
//     );
//   }

//   Widget _buildBody(FocusProvider focusProvider) {
//     if (isLoading && bannerList.isEmpty) {
//       return _buildLoadingWidget();
//     }

//     if (bannerList.isEmpty && !isLoading) {
//       return _buildEmptyWidget();
//     }

//     return _buildBannerSlider(focusProvider);
//   }

//   Widget _buildLoadingWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SpinKitFadingCircle(color: borderColor, size: 50.0),
//           SizedBox(height: 20),
//           Text(
//             'Loading banners...',
//             style: TextStyle(
//               color: hintColor,
//               fontSize: nametextsz,
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
//           Icon(
//             Icons.image_not_supported,
//             color: hintColor.withOpacity(0.5),
//             size: 50,
//           ),
//           SizedBox(height: 20),
//           Text(
//             'No banners available',
//             style: TextStyle(color: hintColor, fontSize: nametextsz),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: refreshData,
//             icon: Icon(Icons.refresh),
//             label: Text('Refresh'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBannerSlider(FocusProvider focusProvider) {
//     return Stack(
//       children: [
//         // Page View
//         PageView.builder(
//           controller: _pageController,
//           itemCount: bannerList.length,
//           onPageChanged: (index) {
//             if (mounted) {
//               setState(() {
//                 selectedContentId = bannerList[index].id.toString();
//               });
//             }
//           },
//           itemBuilder: (context, index) {
//             final banner = bannerList[index];
//             return Stack(
//               alignment: AlignmentDirectional.topCenter,
//               children: [
//                 _buildBannerWithShimmer(banner, focusProvider),
//               ],
//             );
//           },
//         ),

//         // Watch Now Button
//         _buildWatchNowButton(focusProvider),

//         // Page indicators
//         if (bannerList.length > 1) _buildPageIndicators(),
//       ],
//     );
//   }

//   Widget _buildWatchNowButton(FocusProvider focusProvider) {
//     return Positioned(
//       top: screenhgt * 0.03,
//       left: screenwdt * 0.02,
//       child: Focus(
//         focusNode: _buttonFocusNode,
//         onKeyEvent: _handleKeyEvent,
//         child: GestureDetector(
//           onTap: _handleWatchNowTap,
//           child: RandomLightColorWidget(
//             hasFocus: focusProvider.isButtonFocused,
//             childBuilder: (Color randomColor) {
//               return AnimatedContainer(
//                 duration: Duration(milliseconds: 200),
//                 margin: EdgeInsets.all(screenwdt * 0.001),
//                 padding: EdgeInsets.symmetric(
//                   vertical: screenhgt * 0.02,
//                   horizontal: screenwdt * 0.02,
//                 ),
//                 decoration: BoxDecoration(
//                   color: focusProvider.isButtonFocused
//                       ? Colors.black87
//                       : Colors.black.withOpacity(0.6),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: focusProvider.isButtonFocused
//                         ? focusProvider.currentFocusColor ?? randomColor
//                         : Colors.white.withOpacity(0.3),
//                     width: focusProvider.isButtonFocused ? 3.0 : 1.0,
//                   ),
//                   boxShadow: focusProvider.isButtonFocused
//                       ? [
//                           BoxShadow(
//                             color: (focusProvider.currentFocusColor ?? randomColor)
//                                 .withOpacity(0.5),
//                             blurRadius: 20.0,
//                             spreadRadius: 5.0,
//                           ),
//                         ]
//                       : [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.3),
//                             blurRadius: 10.0,
//                             spreadRadius: 2.0,
//                           ),
//                         ],
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.play_arrow,
//                       color: focusProvider.isButtonFocused
//                           ? focusProvider.currentFocusColor ?? randomColor
//                           : hintColor,
//                       size: menutextsz * 1.2,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       'Watch Now',
//                       style: TextStyle(
//                         fontSize: menutextsz,
//                         color: focusProvider.isButtonFocused
//                             ? focusProvider.currentFocusColor ?? randomColor
//                             : hintColor,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPageIndicators() {
//     return Positioned(
//       top: screenhgt * 0.05,
//       right: screenwdt * 0.05,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: bannerList.asMap().entries.map((entry) {
//           int index = entry.key;
//           bool isSelected = selectedContentId == bannerList[index].id.toString();

//           return AnimatedContainer(
//             duration: Duration(milliseconds: 300),
//             margin: EdgeInsets.symmetric(horizontal: 4),
//             width: isSelected ? 12 : 8,
//             height: isSelected ? 12 : 8,
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? Colors.white
//                   : Colors.white.withOpacity(0.5),
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 4,
//                   spreadRadius: 1,
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildBannerWithShimmer(BannerDataModel banner, FocusProvider focusProvider) {
//     return Container(
//       margin: const EdgeInsets.only(top: 1),
//       width: screenwdt,
//       height: screenhgt,
//       child: Stack(
//         children: [
//           // Main banner image
//           CachedNetworkImage(
//             imageUrl: banner.banner,
//             fit: BoxFit.fill,
//             placeholder: (context, url) => Image.asset('assets/streamstarting.gif'),
//             errorWidget: (context, url, error) => Image.asset('assets/streamstarting.gif'),
//             cacheKey: banner.id.toString(),
//             fadeInDuration: Duration(milliseconds: 500),
//             memCacheHeight: 800,
//             memCacheWidth: 1200,
//             width: screenwdt,
//             height: screenhgt,
//           ),

//           // Shimmer effect overlay when focused
//           if (focusProvider.isButtonFocused)
//             AnimatedBuilder(
//               animation: _shimmerAnimation,
//               builder: (context, child) {
//                 return Positioned.fill(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
//                         end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
//                         colors: [
//                           Colors.transparent,
//                           Colors.white.withOpacity(0.1),
//                           Colors.white.withOpacity(0.2),
//                           Colors.white.withOpacity(0.1),
//                           Colors.transparent,
//                         ],
//                         stops: [0.0, 0.3, 0.5, 0.7, 1.0],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),

//           // Enhanced glow effect when focused
//           if (focusProvider.isButtonFocused)
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: RadialGradient(
//                     center: Alignment.center,
//                     radius: 0.8,
//                     colors: [
//                       (focusProvider.currentFocusColor ?? Colors.blue).withOpacity(0.1),
//                       Colors.transparent,
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//           // Border glow effect
//           if (focusProvider.isButtonFocused)
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: (focusProvider.currentFocusColor ?? Colors.blue).withOpacity(0.3),
//                     width: 2.0,
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // Event Handlers
//   KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
//     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//       if (_pageController.hasClients &&
//           _pageController.page != null &&
//           _pageController.page! < bannerList.length - 1) {
//         _pageController.nextPage(
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//         return KeyEventResult.handled;
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       if (_pageController.hasClients &&
//           _pageController.page != null &&
//           _pageController.page! > 0) {
//         _pageController.previousPage(
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//         return KeyEventResult.handled;
//       }
//     } else if (event is KeyDownEvent) {
//       if (event.logicalKey == LogicalKeyboardKey.select ||
//           event.logicalKey == LogicalKeyboardKey.enter) {
//         _handleWatchNowTap();
//         return KeyEventResult.handled;
//       }
//     }
//     return KeyEventResult.ignored;
//   }

//   void _handleWatchNowTap() {
//     if (selectedContentId != null && bannerList.isNotEmpty) {
//       try {
//         final banner = bannerList.firstWhere(
//           (b) => b.id.toString() == selectedContentId,
//           orElse: () => bannerList.first,
//         );
//         fetchAndPlayVideo(banner.id.toString(), newsItemList);
//       } catch (e) {
//         print('Error in watch now tap: $e');
//       }
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     try {
//       _refreshProvider = context.watch<FocusProvider>();

//       if (_refreshProvider.shouldRefreshBanners ||
//           _refreshProvider.shouldRefreshLastPlayed) {
//         _handleProviderRefresh();
//       }
//     } catch (e) {
//       print('Error in didChangeDependencies: $e');
//     }
//   }

//   Future<void> _handleProviderRefresh() async {
//     if (!mounted) return;

//     try {
//       if (_refreshProvider.shouldRefreshBanners) {
//         await _loadBannerData();
//         _refreshProvider.markBannersRefreshed();
//       }
//     } catch (e) {
//       print('Error in provider refresh: $e');
//     }
//   }

//   Future<void> _fetchBannerColors() async {
//     for (var banner in bannerList) {
//       try {
//         final imageUrl = banner.banner;
//         final secondaryColor = await _paletteColorService.getSecondaryColor(imageUrl);

//         if (mounted) {
//           setState(() {
//             bannerColors[banner.id.toString()] = secondaryColor;
//           });
//         }
//       } catch (e) {
//         print('Error fetching banner color: $e');
//       }
//     }
//   }

//   void _startAutoSlide() {
//     if (bannerList.isNotEmpty && (_timer == null || !_timer!.isActive)) {
//       _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
//         if (!mounted) {
//           timer.cancel();
//           return;
//         }

//         try {
//           if (_pageController.hasClients) {
//             if (_pageController.page == bannerList.length - 1) {
//               _pageController.jumpToPage(0);
//             } else {
//               _pageController.nextPage(
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeIn,
//               );
//             }
//           }
//         } catch (e) {
//           print('Error in auto slide: $e');
//         }
//       });
//     }
//   }

//   void _onButtonFocusNode() {
//     try {
//       if (_buttonFocusNode.hasFocus) {
//         final random = Random();
//         final color = Color.fromRGBO(
//           random.nextInt(256),
//           random.nextInt(256),
//           random.nextInt(256),
//           1,
//         );
//         if (mounted) {
//           context.read<FocusProvider>().setButtonFocus(true, color: color);
//           context.read<ColorProvider>().updateColor(color, true);
//         }
//       } else {
//         if (mounted) {
//           context.read<FocusProvider>().resetFocus();
//           context.read<ColorProvider>().resetColor();
//         }
//       }
//     } catch (e) {
//       print('Error in button focus handler: $e');
//     }
//   }

//   Future<void> fetchAndPlayVideo(String contentId, List<NewsItemModel> channelList) async {
//     if (_isNavigating) {
//       return;
//     }

//     _isNavigating = true;

//     bool shouldPlayVideo = true;
//     bool shouldPop = true;

//     try {
//       if (mounted) {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return WillPopScope(
//               onWillPop: () async {
//                 shouldPlayVideo = false;
//                 shouldPop = false;
//                 return true;
//               },
//               child: Center(
//                 child: Container(
//                   padding: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.black87,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SpinKitFadingCircle(
//                         color: borderColor,
//                         size: 50.0,
//                       ),
//                       SizedBox(height: 15),
//                       Text(
//                         'Loading video...',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: nametextsz,
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

//       final responseData = await fetchVideoDataByIdFromBanners(contentId);

//       if (shouldPop && mounted && context.mounted) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//       if (shouldPlayVideo && mounted && context.mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VideoScreen(
//               videoUrl: responseData['url'] ?? '',
//               channelList: channelList,
//               videoId: int.tryParse(contentId) ?? 0,
//               videoType: responseData['type'] ?? '',
//               isLive: true,
//               isVOD: false,
//               bannerImageUrl: responseData['banner'] ?? '',
//               startAtPosition: Duration.zero,
//               isBannerSlider: true,
//               source: 'isBannerSlider',
//               isSearch: false,
//               unUpdatedUrl: responseData['url'] ?? '',
//               name: responseData['name'] ?? '',
//               liveStatus: true,
//               seasonId: null,
//               isLastPlayedStored: false,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (shouldPop && mounted && context.mounted) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//       if (mounted && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to load video: Something went wrong'),
//             duration: Duration(seconds: 3),
//             backgroundColor: Colors.red.shade700,
//           ),
//         );
//       }
//       print('Error fetching and playing video: $e');
//     } finally {
//       _isNavigating = false;
//     }
//   }

//   Uint8List _getCachedImage(String base64String) {
//     try {
//       if (!_bannerCache.containsKey(base64String)) {
//         final base64Content = base64String.split(',').last;
//         _bannerCache[base64String] = base64Decode(base64Content);
//       }
//       return _bannerCache[base64String]!;
//     } catch (e) {
//       return Uint8List.fromList([
//         0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
//         0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
//         0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
//         0x0C, 0x49, 0x44, 0x41, 0x54, 0x78, 0x01, 0x63, 0x00, 0x01, 0x00, 0x05,
//         0x00, 0x01, 0xE2, 0x26, 0x05, 0x9B, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
//         0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
//       ]);
//     }
//   }
// }






import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/video_widget/socket_service.dart';
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
import 'package:mobi_tv_entertainment/widgets/utils/random_light_color_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/small_widgets/app_assets.dart';

// Banner Data Model
class BannerDataModel {
  final int id;
  final String title;
  final String banner;
  final int contentType;
  final int? contentId;
  final String? sourceType;
  final String? url;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  BannerDataModel({
    required this.id,
    required this.title,
    required this.banner,
    required this.contentType,
    this.contentId,
    this.sourceType,
    this.url,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory BannerDataModel.fromJson(Map<String, dynamic> json) {
    return BannerDataModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      banner: json['banner'] ?? '',
      contentType: json['content_type'] ?? 1,
      contentId: json['content_id'],
      sourceType: json['source_type'],
      url: json['url'],
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
    );
  }

  bool get isActive => status == 1 && deletedAt == null;

  NewsItemModel toNewsItemModel() {
    return NewsItemModel(
      id: id.toString(),
      name: title,
      banner: banner,
      contentId: id.toString(),
      type: contentType.toString(),
      url: url ?? '',
      status: status.toString(), 
      unUpdatedUrl: '', 
      poster: '', 
      image: '',
    );
  }
}

// Ultra Fast Cache Manager with immediate memory access
class UltraFastCacheManager {
  static const String BANNER_CACHE_KEY = 'ultra_fast_banners';
  static List<BannerDataModel>? _processedCache; // Pre-processed data
  static DateTime? _cacheTime;
  static const Duration CACHE_DURATION = Duration(hours: 2);

  // ✅ Instant synchronous access to processed data
  static List<BannerDataModel>? getInstantData() {
    if (_processedCache != null && _isCacheValid()) {
      return List.from(_processedCache!); // Return copy for safety
    }
    return null;
  }

  // ✅ Load cache on app start
  static Future<void> initializeCache() async {
    if (_processedCache != null) return; // Already loaded

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(BANNER_CACHE_KEY);
      final cacheTimeString = prefs.getString('${BANNER_CACHE_KEY}_time');
      
      if (cachedString != null && cachedString.isNotEmpty) {
        if (cacheTimeString != null) {
          final cacheTime = DateTime.parse(cacheTimeString);
          if (DateTime.now().difference(cacheTime) > CACHE_DURATION) {
            return; // Cache expired
          }
          _cacheTime = cacheTime;
        }

        final List<dynamic> rawData = json.decode(cachedString);
        _processedCache = _processRawData(rawData);
      }
    } catch (e) {
      // Silent error
    }
  }

  // ✅ Save processed data
  static Future<void> saveData(List<dynamic> rawData) async {
    _processedCache = _processRawData(rawData);
    _cacheTime = DateTime.now();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(BANNER_CACHE_KEY, json.encode(rawData));
      await prefs.setString('${BANNER_CACHE_KEY}_time', _cacheTime!.toIso8601String());
    } catch (e) {
      // Silent error
    }
  }

  // ✅ Process raw data immediately
  static List<BannerDataModel> _processRawData(List<dynamic> rawData) {
    List<BannerDataModel> processed = [];
    for (var item in rawData) {
      try {
        final banner = BannerDataModel.fromJson(item);
        if (banner.isActive) {
          processed.add(banner);
        }
      } catch (e) {
        // Skip invalid items
      }
    }
    return processed;
  }

  static bool _isCacheValid() {
    if (_cacheTime == null) return false;
    return DateTime.now().difference(_cacheTime!) < CACHE_DURATION;
  }

  static void clearCache() {
    _processedCache = null;
    _cacheTime = null;
  }
}

// Auth Headers
Future<Map<String, String>> getAuthHeaders() async {
  String authKey = '';

  if (authKey.isEmpty) {
    try {
      final prefs = await SharedPreferences.getInstance();
      authKey = prefs.getString('auth_key') ?? '';
      if (authKey.isNotEmpty) {
        globalAuthKey = authKey;
      }
    } catch (e) {
      // Silent error
    }
  }

  if (authKey.isEmpty) {
    authKey = 'vLQTuPZUxktl5mVW';
  }

  return {
    'auth-key': authKey,
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}

// API Configuration
class ApiConfig {
  static const String PRIMARY_BASE_URL = 'https://acomtv.coretechinfo.com/public/api';
  static const List<String> BANNER_ENDPOINTS = [
    '$PRIMARY_BASE_URL/getCustomImageSlider',
  ];
}

// API Functions
Future<Map<String, String>> fetchVideoDataByIdFromBanners(String contentId) async {
  // First try instant cache
  List<BannerDataModel> banners = UltraFastCacheManager.getInstantData() ?? [];

  try {
    if (banners.isEmpty) {
      // Fallback to API
      final rawData = await fetchBannersData();
      banners = UltraFastCacheManager._processRawData(rawData);
    }

    final matchedBanner = banners.firstWhere(
      (banner) => banner.id.toString() == contentId,
      orElse: () => throw Exception('Content not found'),
    );

    return {
      'url': matchedBanner.url ?? '',
      'type': matchedBanner.contentType.toString(),
      'banner': matchedBanner.banner,
      'name': matchedBanner.title,
      'stream_type': matchedBanner.sourceType ?? '',
    };
  } catch (e) {
    throw Exception('Something went wrong: $e');
  }
}

Future<List<dynamic>> fetchBannersData() async {
  Map<String, String> headers = await getAuthHeaders();
  bool success = false;
  String responseBody = '';

  for (int i = 0; i < ApiConfig.BANNER_ENDPOINTS.length; i++) {
    String endpoint = ApiConfig.BANNER_ENDPOINTS[i];

    try {
      final response = await https
          .get(Uri.parse(endpoint), headers: headers)
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        String body = response.body.trim();
        if (body.startsWith('[') || body.startsWith('{')) {
          try {
            json.decode(body);
            responseBody = body;
            success = true;
            break;
          } catch (e) {
            continue;
          }
        }
      }
    } catch (e) {
      continue;
    }
  }

  if (!success) {
    throw Exception('Failed to load banners from all endpoints');
  }

  return json.decode(responseBody);
}

// Ultra Fast Banner Slider Widget
class BannerSlider extends StatefulWidget {
  final Function(bool)? onFocusChange;
  final FocusNode focusNode;

  const BannerSlider({
    Key? key,
    this.onFocusChange,
    required this.focusNode,
  }) : super(key: key);

  @override
  _BannerSliderState createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> with SingleTickerProviderStateMixin {
  final SocketService _socketService = SocketService();
  List<BannerDataModel> bannerList = [];
  List<NewsItemModel>? _newsItemListCache;
  bool isLoading = true;
  String errorMessage = '';
  late PageController _pageController;
  Timer? _timer;
  String? selectedContentId;
  final FocusNode _buttonFocusNode = FocusNode();
  bool _isNavigating = false;
  final PaletteColorService _paletteColorService = PaletteColorService();
  late FocusProvider _refreshProvider;

  // Animation controllers for shimmer effect
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  // Lazy getter for newsItemList
  List<NewsItemModel> get newsItemList {
    if (_newsItemListCache == null || _newsItemListCache!.length != bannerList.length) {
      _newsItemListCache = bannerList.map((banner) => banner.toNewsItemModel()).toList();
    }
    return _newsItemListCache!;
  }

  @override
  void initState() {
    super.initState();
    _initializeShimmerAnimation();
    _initializeSlider();
  }

  void _initializeShimmerAnimation() {
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    if (_pageController.hasClients) {
      _pageController.dispose();
    }
    _socketService.dispose();
    _shimmerController.dispose();
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    _buttonFocusNode.dispose();
    super.dispose();
  }

  // ✅ Ultra fast initialization
  Future<void> _initializeSlider() async {
    try {
      _socketService.initSocket();
      _pageController = PageController();

      _buttonFocusNode.addListener(() {
        if (_buttonFocusNode.hasFocus) {
          widget.onFocusChange?.call(true);
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<FocusProvider>().setWatchNowFocusNode(_buttonFocusNode);
        }
      });

      _buttonFocusNode.addListener(_onButtonFocusNode);

      // ✅ Load data instantly
      await _loadBannerDataUltraFast();
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to initialize: $e';
          isLoading = false;
        });
      }
    }
  }

  // ✅ Ultra fast data loading
  Future<void> _loadBannerDataUltraFast() async {
    // Step 1: Try instant cache (< 1ms)
    final cachedBanners = UltraFastCacheManager.getInstantData();
    
    if (cachedBanners != null && cachedBanners.isNotEmpty) {
      // ✅ Show instantly
      _showBannersInstantly(cachedBanners);
      
      // Background refresh (non-blocking)
      _refreshDataInBackground();
      return;
    }

    // Step 2: Initialize cache and load fresh data
    await UltraFastCacheManager.initializeCache();
    final initializedCache = UltraFastCacheManager.getInstantData();
    
    if (initializedCache != null && initializedCache.isNotEmpty) {
      _showBannersInstantly(initializedCache);
      _refreshDataInBackground();
    } else {
      // No cache, load fresh data
      await _loadFreshData();
    }
  }

  // ✅ Show banners with zero async operations
  void _showBannersInstantly(List<BannerDataModel> banners) {
    if (mounted) {
      setState(() {
        bannerList = banners;
        selectedContentId = banners.isNotEmpty ? banners[0].id.toString() : null;
        isLoading = false;
        errorMessage = '';
        _newsItemListCache = null;
      });

      // Start background operations in next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startAutoSlide();
          _prefetchImages(); // Background image prefetch
        }
      });
    }
  }

  // ✅ Background refresh without blocking UI
  void _refreshDataInBackground() {
    Future.delayed(Duration(milliseconds: 100), () async {
      try {
        final freshData = await fetchBannersData();
        await UltraFastCacheManager.saveData(freshData);
        
        final newBanners = UltraFastCacheManager.getInstantData();
        if (mounted && newBanners != null && _shouldUpdateUI(newBanners)) {
          setState(() {
            bannerList = newBanners;
            _newsItemListCache = null;
          });
        }
      } catch (e) {
        // Silent background error
      }
    });
  }

  // ✅ Load fresh data when no cache
  Future<void> _loadFreshData() async {
    try {
      final freshData = await fetchBannersData();
      await UltraFastCacheManager.saveData(freshData);
      
      final banners = UltraFastCacheManager.getInstantData();
      if (banners != null && mounted) {
        _showBannersInstantly(banners);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load banners: $e';
          isLoading = false;
        });
      }
    }
  }

  // ✅ Background image prefetching
  void _prefetchImages() {
    for (var banner in bannerList) {
      precacheImage(
        CachedNetworkImageProvider(banner.banner),
        context,
      ).catchError((e) => null); // Silent errors
    }
  }

  bool _shouldUpdateUI(List<BannerDataModel> newBanners) {
    if (newBanners.length != bannerList.length) return true;
    
    for (int i = 0; i < newBanners.length; i++) {
      if (newBanners[i].id != bannerList[i].id) {
        return true;
      }
    }
    return false;
  }

  // Public refresh method
  Future<void> refreshData() async {
    await _loadBannerDataUltraFast();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FocusProvider>(
      builder: (context, focusProvider, child) {
        return Scaffold(
          backgroundColor: cardColor,
          body: _buildBody(focusProvider),
        );
      },
    );
  }

  Widget _buildBody(FocusProvider focusProvider) {
    if (isLoading) {
      return _buildLoadingWidget();
    }

    if (bannerList.isEmpty) {
      return _buildEmptyWidget();
    }

    return _buildBannerSlider(focusProvider);
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(color: borderColor, size: 50.0),
          SizedBox(height: 20),
          Text(
            'Loading banners...',
            style: TextStyle(
              color: hintColor,
              fontSize: nametextsz,
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
          Icon(
            Icons.image_not_supported,
            color: hintColor.withOpacity(0.5),
            size: 50,
          ),
          SizedBox(height: 20),
          Text(
            'No banners available',
            style: TextStyle(color: hintColor, fontSize: nametextsz),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: refreshData,
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlider(FocusProvider focusProvider) {
    return Stack(
      children: [
        // ✅ Simple PageView without complex operations
        PageView.builder(
          controller: _pageController,
          itemCount: bannerList.length,
          onPageChanged: (index) {
            if (mounted) {
              setState(() {
                selectedContentId = bannerList[index].id.toString();
              });
            }
          },
          itemBuilder: (context, index) {
            final banner = bannerList[index];
            return _buildSimpleBanner(banner, focusProvider);
          },
        ),

        // ✅ Updated Watch Now Button with arrows
        _buildNavigationButton(focusProvider),

        // Page indicators
        if (bannerList.length > 1) _buildPageIndicators(),
      ],
    );
  }

  // ✅ Updated button with left/right arrows instead of "Watch Now"
  Widget _buildNavigationButton(FocusProvider focusProvider) {
    return Positioned(
      top: screenhgt * 0.03,
      left: screenwdt * 0.02,
      child: Focus(
        focusNode: _buttonFocusNode,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          onTap: _handleWatchNowTap,
          child: RandomLightColorWidget(
            hasFocus: focusProvider.isButtonFocused,
            childBuilder: (Color randomColor) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.all(screenwdt * 0.001),
                padding: EdgeInsets.symmetric(
                  vertical: screenhgt * 0.02,
                  horizontal: screenwdt * 0.025,
                ),
                decoration: BoxDecoration(
                  color: focusProvider.isButtonFocused
                      ? Colors.black87
                      : Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: focusProvider.isButtonFocused
                        ? focusProvider.currentFocusColor ?? randomColor
                        : Colors.white.withOpacity(0.3),
                    width: focusProvider.isButtonFocused ? 3.0 : 1.0,
                  ),
                  boxShadow: focusProvider.isButtonFocused
                      ? [
                          BoxShadow(
                            color: (focusProvider.currentFocusColor ?? randomColor)
                                .withOpacity(0.5),
                            blurRadius: 20.0,
                            spreadRadius: 5.0,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Left Arrow
                    Icon(
                      Icons.chevron_left,
                      color: focusProvider.isButtonFocused
                          ? focusProvider.currentFocusColor ?? randomColor
                          : hintColor,
                      size: menutextsz * 1.5,
                    ),
                    // SizedBox(width: 8),
                    // ✅ Play icon in center
                    // Container(
                    //   padding: EdgeInsets.all(8),
                    //   decoration: BoxDecoration(
                    //     color: focusProvider.isButtonFocused
                    //         ? (focusProvider.currentFocusColor ?? randomColor).withOpacity(0.2)
                    //         : Colors.white.withOpacity(0.1),
                    //     shape: BoxShape.circle,
                    //   ),
                    //   child: Icon(
                    //     Icons.play_arrow,
                    //     color: focusProvider.isButtonFocused
                    //         ? focusProvider.currentFocusColor ?? randomColor
                    //         : hintColor,
                    //     size: menutextsz * 1.2,
                    //   ),
                    // ),
                    SizedBox(width: 8),
                    // ✅ Right Arrow
                    Icon(
                      Icons.chevron_right,
                      color: focusProvider.isButtonFocused
                          ? focusProvider.currentFocusColor ?? randomColor
                          : hintColor,
                      size: menutextsz * 1.5,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Positioned(
      top: screenhgt * 0.05,
      right: screenwdt * 0.05,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: bannerList.asMap().entries.map((entry) {
          int index = entry.key;
          bool isSelected = selectedContentId == bannerList[index].id.toString();

          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: isSelected ? 12 : 8,
            height: isSelected ? 12 : 8,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ✅ Simplified banner without heavy operations
  Widget _buildSimpleBanner(BannerDataModel banner, FocusProvider focusProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 1),
      width: screenwdt,
      height: screenhgt,
      child: Stack(
        children: [
          // ✅ Optimized image loading
          CachedNetworkImage(
            imageUrl: banner.banner,
            fit: BoxFit.fill,
            placeholder: (context, url) => Image.asset('assets/streamstarting.gif'),
            // Container(
            //   color: Colors.grey[900],
            //   child: Center(
            //     child: Icon(
            //       Icons.image,
            //       color: Colors.grey[600],
            //       size: 50,
            //     ),
            //   ),
            // ),
            errorWidget: (context, url, error) => Image.asset('assets/streamstarting.gif'),
            // Container(
            //   color: Colors.grey[800],
            //   child: Center(
            //     child: Icon(
            //       Icons.broken_image,
            //       color: Colors.grey[600],
            //       size: 50,
            //     ),
            //   ),
            // ),
            cacheKey: banner.id.toString(),
            fadeInDuration: Duration(milliseconds: 100), // Ultra fast fade
            placeholderFadeInDuration: Duration.zero,
            memCacheHeight: 400, // Smaller for faster loading
            memCacheWidth: 600,  // Smaller for faster loading
            useOldImageOnUrlChange: true,
            width: screenwdt,
            height: screenhgt,
          ),

          // ✅ Lightweight shimmer effect only when focused
          if (focusProvider.isButtonFocused)
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
                        end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.15),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // Event Handlers
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_pageController.hasClients &&
          _pageController.page != null &&
          _pageController.page! < bannerList.length - 1) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return KeyEventResult.handled;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_pageController.hasClients &&
          _pageController.page != null &&
          _pageController.page! > 0) {
        _pageController.previousPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return KeyEventResult.handled;
      }
    } else if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        _handleWatchNowTap();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _handleWatchNowTap() {
    if (selectedContentId != null && bannerList.isNotEmpty) {
      try {
        final banner = bannerList.firstWhere(
          (b) => b.id.toString() == selectedContentId,
          orElse: () => bannerList.first,
        );
        fetchAndPlayVideo(banner.id.toString(), newsItemList);
      } catch (e) {
        // Error handling
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    try {
      _refreshProvider = context.watch<FocusProvider>();

      if (_refreshProvider.shouldRefreshBanners ||
          _refreshProvider.shouldRefreshLastPlayed) {
        _handleProviderRefresh();
      }
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> _handleProviderRefresh() async {
    if (!mounted) return;

    try {
      if (_refreshProvider.shouldRefreshBanners) {
        await _loadBannerDataUltraFast();
        _refreshProvider.markBannersRefreshed();
      }
    } catch (e) {
      // Silent error handling
    }
  }

  void _startAutoSlide() {
    if (bannerList.isNotEmpty && (_timer == null || !_timer!.isActive)) {
      _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        try {
          if (_pageController.hasClients) {
            if (_pageController.page == bannerList.length - 1) {
              _pageController.jumpToPage(0);
            } else {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            }
          }
        } catch (e) {
          // Silent error handling
        }
      });
    }
  }

  void _onButtonFocusNode() {
    try {
      if (_buttonFocusNode.hasFocus) {
        final random = Random();
        final color = Color.fromRGBO(
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
          1,
        );
        if (mounted) {
          context.read<FocusProvider>().setButtonFocus(true, color: color);
          context.read<ColorProvider>().updateColor(color, true);
        }
      } else {
        if (mounted) {
          context.read<FocusProvider>().resetFocus();
          context.read<ColorProvider>().resetColor();
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> fetchAndPlayVideo(String contentId, List<NewsItemModel> channelList) async {
    if (_isNavigating) {
      return;
    }

    _isNavigating = true;

    bool shouldPlayVideo = true;
    bool shouldPop = true;

    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                shouldPlayVideo = false;
                shouldPop = false;
                return true;
              },
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SpinKitFadingCircle(
                        color: borderColor,
                        size: 50.0,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Loading video...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: nametextsz,
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

      final responseData = await fetchVideoDataByIdFromBanners(contentId);

      if (shouldPop && mounted && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (shouldPlayVideo && mounted && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScreen(
              videoUrl: responseData['url'] ?? '',
              channelList: channelList,
              videoId: int.tryParse(contentId) ?? 0,
              videoType: responseData['type'] ?? '',
              isLive: true,
              isVOD: false,
              bannerImageUrl: responseData['banner'] ?? '',
              startAtPosition: Duration.zero,
              isBannerSlider: true,
              source: 'isBannerSlider',
              isSearch: false,
              unUpdatedUrl: responseData['url'] ?? '',
              name: responseData['name'] ?? '',
              liveStatus: true,
              seasonId: null,
              isLastPlayedStored: false,
            ),
          ),
        );
      }
    } catch (e) {
      if (shouldPop && mounted && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load video: Something went wrong'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      _isNavigating = false;
    }
  }
}