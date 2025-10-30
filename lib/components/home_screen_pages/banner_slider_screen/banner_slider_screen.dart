// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
//  
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

// // Ultra Fast Cache Manager with immediate memory access
// class UltraFastCacheManager {
//   static const String BANNER_CACHE_KEY = 'ultra_fast_banners';
//   static List<BannerDataModel>? _processedCache; // Pre-processed data
//   static DateTime? _cacheTime;
//   static const Duration CACHE_DURATION = Duration(hours: 2);

//   // ✅ Instant synchronous access to processed data
//   static List<BannerDataModel>? getInstantData() {
//     if (_processedCache != null && _isCacheValid()) {
//       return List.from(_processedCache!); // Return copy for safety
//     }
//     return null;
//   }

//   // ✅ Load cache on app start
//   static Future<void> initializeCache() async {
//     if (_processedCache != null) return; // Already loaded

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cachedString = prefs.getString(BANNER_CACHE_KEY);
//       final cacheTimeString = prefs.getString('${BANNER_CACHE_KEY}_time');

//       if (cachedString != null && cachedString.isNotEmpty) {
//         if (cacheTimeString != null) {
//           final cacheTime = DateTime.parse(cacheTimeString);
//           if (DateTime.now().difference(cacheTime) > CACHE_DURATION) {
//             return; // Cache expired
//           }
//           _cacheTime = cacheTime;
//         }

//         final List<dynamic> rawData = json.decode(cachedString);
//         _processedCache = _processRawData(rawData);
//       }
//     } catch (e) {
//       // Silent error
//     }
//   }

//   // ✅ Save processed data
//   static Future<void> saveData(List<dynamic> rawData) async {
//     _processedCache = _processRawData(rawData);
//     _cacheTime = DateTime.now();

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(BANNER_CACHE_KEY, json.encode(rawData));
//       await prefs.setString('${BANNER_CACHE_KEY}_time', _cacheTime!.toIso8601String());
//     } catch (e) {
//       // Silent error
//     }
//   }

//   // ✅ Process raw data immediately
//   static List<BannerDataModel> _processRawData(List<dynamic> rawData) {
//     List<BannerDataModel> processed = [];
//     for (var item in rawData) {
//       try {
//         final banner = BannerDataModel.fromJson(item);
//         if (banner.isActive) {
//           processed.add(banner);
//         }
//       } catch (e) {
//         // Skip invalid items
//       }
//     }
//     return processed;
//   }

//   static bool _isCacheValid() {
//     if (_cacheTime == null) return false;
//     return DateTime.now().difference(_cacheTime!) < CACHE_DURATION;
//   }

//   static void clearCache() {
//     _processedCache = null;
//     _cacheTime = null;
//   }
// }

// // Auth Headers
// Future<Map<String, String>> getAuthHeaders() async {
//   String authKey = '';

//   if (authKey.isEmpty) {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       authKey = prefs.getString('result_auth_key') ?? '';
//       // if (authKey.isNotEmpty) {
//       //   globalAuthKey = authKey;
//       // }
//     } catch (e) {
//       // Silent error
//     }
//   }

//   if (authKey.isEmpty) {
//     authKey = 'vLQTuPZUxktl5mVW';
//   }

//   return {
//     'auth-key': authKey,
//     'Accept': 'application/json',
//     'Content-Type': 'application/json',
//     'domain': 'coretechinfo.com',
//   };
// }

// // API Configuration
// class ApiConfig {
//   static const String PRIMARY_BASE_URL = 'https://dashboard.cpplayers.com/public/api/v2';
//   static const List<String> BANNER_ENDPOINTS = [
//     '$PRIMARY_BASE_URL/getCustomImageSlider',
//   ];
// }

// // API Functions
// Future<Map<String, String>> fetchVideoDataByIdFromBanners(String contentId) async {
//   // First try instant cache
//   List<BannerDataModel> banners = UltraFastCacheManager.getInstantData() ?? [];

//   try {
//     if (banners.isEmpty) {
//       // Fallback to API
//       final rawData = await fetchBannersData();
//       banners = UltraFastCacheManager._processRawData(rawData);
//     }

//     final matchedBanner = banners.firstWhere(
//       (banner) => banner.id.toString() == contentId,
//       orElse: () => throw Exception('Content not found'),
//     );

//     return {
//       'url': matchedBanner.url ?? '',
//       'type': matchedBanner.contentType.toString(),
//       'banner': matchedBanner.banner,
//       'name': matchedBanner.title,
//       'stream_type': matchedBanner.sourceType ?? '',
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
//           .get(Uri.parse(endpoint), headers: headers,)
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

// // Ultra Fast Banner Slider Widget
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
//   List<NewsItemModel>? _newsItemListCache;
//   bool isLoading = true;
//   String errorMessage = '';
//   late PageController _pageController;
//   Timer? _timer;
//   String? selectedContentId;
//   final FocusNode _buttonFocusNode = FocusNode();
//   bool _isNavigating = false;
//   final PaletteColorService _paletteColorService = PaletteColorService();
//   late FocusProvider _refreshProvider;
//   // String _deviceName = '';

//   // Animation controllers for shimmer effect
//   late AnimationController _shimmerController;
//   late Animation<double> _shimmerAnimation;

//   // Lazy getter for newsItemList
//   List<NewsItemModel> get newsItemList {
//     if (_newsItemListCache == null || _newsItemListCache!.length != bannerList.length) {
//       _newsItemListCache = bannerList.map((banner) => banner.toNewsItemModel()).toList();
//     }
//     return _newsItemListCache!;
//   }

//   @override
//   void initState() {
//     super.initState();
//     // _getDeviceInfo();
//     _initializeShimmerAnimation();
//     _initializeSlider();

//   }

// // // ✅ Apne purane function ko is naye aur behtar function se replace karein
// //   Future<void> _getDeviceInfo() async {
// //     final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
// //     String deviceIdentifier = 'Unknown Device';

// //     try {
// //       if (Platform.isAndroid) {
// //         final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
// //         final String brand = androidInfo.brand.toLowerCase();
// //         final String model = androidInfo.model;
// //         final String device = androidInfo.device; // 'device' name bhi zaroori hai

// //         if (brand == 'amazon') {
// //           //  AMAZON FIRE STICK CHECK
// //           switch (model) {
// //             case 'AFTKM':
// //               deviceIdentifier = 'AFTKM : Amazon Fire Stick 4K';
// //               break;
// //             case 'AFTKA':
// //               deviceIdentifier = 'AFTKA : Amazon Fire Stick 4K TEST';
// //               break;
// //             case 'AFTSS':
// //               deviceIdentifier = 'AFTSS : Amazon Fire Stick HD';
// //               break;
// //             // case 'AFTMM':
// //             case 'AFTT': // Ye dono HD models ho sakte hain
// //               deviceIdentifier = 'AFTT : Amazon Fire Stick ABC';
// //               break;
// //             default:
// //               deviceIdentifier = 'Amazon Fire TV Device';
// //           }
// //         } else if (brand == 'google') {
// //           // GOOGLE CHROMECAST CHECK
// //           // Yahan hum 'device' codename (sabrina/boreal) se check kar rahe hain jo zyada aasan hai
// //           switch (device) {
// //             case 'sabrina':
// //               deviceIdentifier = 'sabrina : Chromecast with Google TV (4K)';
// //               break;
// //             case 'boreal':
// //               deviceIdentifier = 'boreal : Chromecast with Google TV (HD)';
// //               break;
// //             default:
// //               deviceIdentifier = 'Google TV Device';
// //           }
// //         } else {
// //           // Baaki sabhi TV's ke liye fallback
// //           final bool isTv = androidInfo.systemFeatures.contains('android.software.leanback');
// //           String name = model.isEmpty ? '${androidInfo.brand} ${device}' : model;
// //           deviceIdentifier = isTv ? '$name (TV)' : name;
// //         }
// //       } else if (Platform.isIOS) {
// //         final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
// //         deviceIdentifier = iosInfo.name;
// //       }
// //     } catch (e) {
// //       print('Failed to get device info: $e');
// //       deviceIdentifier = 'Error getting name';
// //     }

// //     if (mounted) {
// //       setState(() {
// //         _deviceName = deviceIdentifier;
// //       });
// //     }
// //   }

//   void _initializeShimmerAnimation() {
//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
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

//   // ✅ Ultra fast initialization
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

//       // ✅ Load data instantly
//       await _loadBannerDataUltraFast();
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           errorMessage = 'Failed to initialize: $e';
//           isLoading = false;
//         });
//       }
//     }
//   }

//   // ✅ Ultra fast data loading
//   Future<void> _loadBannerDataUltraFast() async {
//     // Step 1: Try instant cache (< 1ms)
//     final cachedBanners = UltraFastCacheManager.getInstantData();

//     if (cachedBanners != null && cachedBanners.isNotEmpty) {
//       // ✅ Show instantly
//       _showBannersInstantly(cachedBanners);

//       // Background refresh (non-blocking)
//       _refreshDataInBackground();
//       return;
//     }

//     // Step 2: Initialize cache and load fresh data
//     await UltraFastCacheManager.initializeCache();
//     final initializedCache = UltraFastCacheManager.getInstantData();

//     if (initializedCache != null && initializedCache.isNotEmpty) {
//       _showBannersInstantly(initializedCache);
//       _refreshDataInBackground();
//     } else {
//       // No cache, load fresh data
//       await _loadFreshData();
//     }
//   }

//   // ✅ Show banners with zero async operations
//   void _showBannersInstantly(List<BannerDataModel> banners) {
//     if (mounted) {
//       setState(() {
//         bannerList = banners;
//         selectedContentId = banners.isNotEmpty ? banners[0].id.toString() : null;
//         isLoading = false;
//         errorMessage = '';
//         _newsItemListCache = null;
//       });

//       // Start background operations in next frame
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           _startAutoSlide();
//           _prefetchImages(); // Background image prefetch
//         }
//       });
//     }
//   }

//   // ✅ Background refresh without blocking UI
//   void _refreshDataInBackground() {
//     Future.delayed(Duration(milliseconds: 100), () async {
//       try {
//         final freshData = await fetchBannersData();
//         await UltraFastCacheManager.saveData(freshData);

//         final newBanners = UltraFastCacheManager.getInstantData();
//         if (mounted && newBanners != null && _shouldUpdateUI(newBanners)) {
//           setState(() {
//             bannerList = newBanners;
//             _newsItemListCache = null;
//           });
//         }
//       } catch (e) {
//         // Silent background error
//       }
//     });
//   }

//   // ✅ Load fresh data when no cache
//   Future<void> _loadFreshData() async {
//     try {
//       final freshData = await fetchBannersData();
//       await UltraFastCacheManager.saveData(freshData);

//       final banners = UltraFastCacheManager.getInstantData();
//       if (banners != null && mounted) {
//         _showBannersInstantly(banners);
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           errorMessage = 'Failed to load banners: $e';
//           isLoading = false;
//         });
//       }
//     }
//   }

//   // ✅ Background image prefetching
//   void _prefetchImages() {
//     for (var banner in bannerList) {
//       precacheImage(
//         CachedNetworkImageProvider(banner.banner),
//         context,
//       ).catchError((e) => null); // Silent errors
//     }
//   }

//   bool _shouldUpdateUI(List<BannerDataModel> newBanners) {
//     if (newBanners.length != bannerList.length) return true;

//     for (int i = 0; i < newBanners.length; i++) {
//       if (newBanners[i].id != bannerList[i].id) {
//         return true;
//       }
//     }
//     return false;
//   }

//   // Public refresh method
//   Future<void> refreshData() async {
//     await _loadBannerDataUltraFast();
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
//     if (isLoading) {
//       return _buildLoadingWidget();
//     }

//     if (bannerList.isEmpty) {
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
//         // ✅ Simple PageView without complex operations
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
//             return _buildSimpleBanner(banner, focusProvider);
//           },
//         ),

//         // ✅ Updated Watch Now Button with arrows
//         _buildNavigationButton(focusProvider),

//         // Page indicators
//         if (bannerList.length > 1) _buildPageIndicators(),
//       ],
//     );
//   }

//   // ✅ Updated button with left/right arrows instead of "Watch Now"
//   Widget _buildNavigationButton(FocusProvider focusProvider) {
//     return Positioned(
//       top: screenhgt * 0.03,
//       left: screenwdt * 0.03,
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
//                   vertical: screenhgt * 0.01,
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
//                     // ✅ Left Arrow
//                     Icon(
//                       Icons.chevron_left,
//                       color: focusProvider.isButtonFocused
//                           ? focusProvider.currentFocusColor ?? randomColor
//                           : hintColor,
//                       size: menutextsz * 1.5,
//                     ),
//                     // SizedBox(width: 8),
//                     // ✅ Play icon in center
//                     // Container(
//                     //   padding: EdgeInsets.all(8),
//                     //   decoration: BoxDecoration(
//                     //     color: focusProvider.isButtonFocused
//                     //         ? (focusProvider.currentFocusColor ?? randomColor).withOpacity(0.2)
//                     //         : Colors.white.withOpacity(0.1),
//                     //     shape: BoxShape.circle,
//                     //   ),
//                     //   child: Icon(
//                     //     Icons.play_arrow,
//                     //     color: focusProvider.isButtonFocused
//                     //         ? focusProvider.currentFocusColor ?? randomColor
//                     //         : hintColor,
//                     //     size: menutextsz * 1.2,
//                     //   ),
//                     // ),
//                     SizedBox(width: 8),
//                     // ✅ Right Arrow
//                     Icon(
//                       Icons.chevron_right,
//                       color: focusProvider.isButtonFocused
//                           ? focusProvider.currentFocusColor ?? randomColor
//                           : hintColor,
//                       size: menutextsz * 1.5,
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

//   // ✅ Simplified banner without heavy operations
//   Widget _buildSimpleBanner(BannerDataModel banner, FocusProvider focusProvider) {
//     final String deviceName = context.watch<DeviceInfoProvider>().deviceName;
//     return Container(
//       margin: const EdgeInsets.only(top: 1),
//       width: screenwdt,
//       height: screenhgt,
//       child: Stack(
//         children: [
//           // ✅ Optimized image loading
//           CachedNetworkImage(
//             imageUrl: banner.banner,
//             fit: BoxFit.fill,
//             // fit: BoxFit.cover,
//             placeholder: (context, url) => Image.asset('assets/streamstarting.gif'),
//             // Container(
//             //   color: Colors.grey[900],
//             //   child: Center(
//             //     child: Icon(
//             //       Icons.image,
//             //       color: Colors.grey[600],
//             //       size: 50,
//             //     ),
//             //   ),
//             // ),
//             errorWidget: (context, url, error) => Image.asset('assets/streamstarting.gif'),
//             // Container(
//             //   color: Colors.grey[800],
//             //   child: Center(
//             //     child: Icon(
//             //       Icons.broken_image,
//             //       color: Colors.grey[600],
//             //       size: 50,
//             //     ),
//             //   ),
//             // ),
//             cacheKey: banner.id.toString(),
//             fadeInDuration: Duration(milliseconds: 100), // Ultra fast fade
//             placeholderFadeInDuration: Duration.zero,
//             memCacheHeight: 400, // Smaller for faster loading
//             memCacheWidth: 600,  // Smaller for faster loading
//             useOldImageOnUrlChange: true,
//             width: screenwdt,
//             height: screenhgt,
//           ),

//           // ✅ Lightweight shimmer effect only when focused
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
//                           Colors.white.withOpacity(0.15),
//                           Colors.transparent,
//                         ],
//                         stops: [0.0, 0.5, 1.0],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//              // ✨ YEH NAYA CODE HAI DEVICE KA NAAM DIKHANE KE LIYE ✨
//           Positioned(
//             bottom: 100, // Neeche se 20 pixels upar
//             left: 200,   // Baayein se 20 pixels door
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.6), // Semi-transparent background
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 deviceName, // Yahan device ka naam show hoga
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16, // Font size aap adjust kar sakte hain
//                   fontWeight: FontWeight.bold,
//                   shadows: [
//                     Shadow(
//                       blurRadius: 2.0,
//                       color: Colors.black.withOpacity(0.5),
//                       offset: Offset(1.0, 1.0),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
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
//         // Error handling
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
//       // Silent error handling
//     }
//   }

//   Future<void> _handleProviderRefresh() async {
//     if (!mounted) return;

//     try {
//       if (_refreshProvider.shouldRefreshBanners) {
//         await _loadBannerDataUltraFast();
//         _refreshProvider.markBannersRefreshed();
//       }
//     } catch (e) {
//       // Silent error handling
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
//           // Silent error handling
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
//       // Silent error handling
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
//               // seasonId: null,
//               // isLastPlayedStored: false,
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
//     } finally {
//       _isNavigating = false;
//     }
//   }
// }







// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';
// import 'package:mobi_tv_entertainment/components/widgets/utils/random_light_color_widget.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // ✅ STEP 1: PURANA DATA FETCHING AUR CACHING CODE HATA DIYA GAYA HAI.
// // UltraFastCacheManager, getAuthHeaders, ApiConfig, etc., sab delete kar diye gaye hain.

// // Banner Data Model (No Changes)
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
//       updatedAt: updatedAt,
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

// // ✅ STEP 2: NAYA BANNER SERVICE BANAYA GAYA HAI (HorizontalVodService KI TARAH)
// class BannerService {
//   // Cache keys
//   static const String _cacheKeyBanners = 'cached_banners_data';
//   static const String _cacheKeyTimestamp = 'cached_banners_timestamp';

//   // Cache duration (2 ghante)
//   static const Duration _cacheDuration = Duration(hours: 2);

//   /// Main method to get banners with "stale-while-revalidate" caching
//   static Future<List<BannerDataModel>> getAllBanners(
//       {bool forceRefresh = false}) async {
//     final prefs = await SharedPreferences.getInstance();

//     if (!forceRefresh && await _shouldUseCache(prefs)) {
//       print('📦 Loading Banners from cache...');
//       final cachedBanners = await _getCachedBanners(prefs);
//       if (cachedBanners.isNotEmpty) {
//         _loadFreshDataInBackground(); // Background refresh
//         return cachedBanners;
//       }
//     }

//     print('🌐 Loading fresh Banners from API...');
//     return await _fetchFreshBanners(prefs);
//   }

//   /// Check if cache is still valid
//   static Future<bool> _shouldUseCache(SharedPreferences prefs) async {
//     final timestampStr = prefs.getString(_cacheKeyTimestamp);
//     if (timestampStr == null) return false;

//     final cachedTimestamp = DateTime.tryParse(timestampStr);
//     if (cachedTimestamp == null) return false;

//     final isCacheValid =
//         DateTime.now().difference(cachedTimestamp) < _cacheDuration;
//     print(
//         isCacheValid ? '✅ Banner Cache is valid.' : '⏰ Banner Cache expired.');
//     return isCacheValid;
//   }

//   /// Get banners from cache
//   static Future<List<BannerDataModel>> _getCachedBanners(
//       SharedPreferences prefs) async {
//     final cachedData = prefs.getString(_cacheKeyBanners);
//     if (cachedData == null || cachedData.isEmpty) return [];

//     try {
//       final List<dynamic> jsonData = json.decode(cachedData);
//       return jsonData
//           .map((item) => BannerDataModel.fromJson(item))
//           .where((banner) => banner.isActive)
//           .toList();
//     } catch (e) {
//       print('❌ Error parsing cached banners: $e');
//       return [];
//     }
//   }

//   // In class BannerService...

//   /// Fetch fresh banners from API and cache them
//   static Future<List<BannerDataModel>> _fetchFreshBanners(
//       SharedPreferences prefs) async {
//     try {
//       final List<dynamic> rawData = await _fetchBannersFromApi();

//       // 🕵️‍♂️ DEBUG: Print counts before and after filtering
//       print("----------- Data Filtering Check -----------");
//       print("📊 Total banners received from API: ${rawData.length}");

//       final activeBanners = rawData
//           .map((item) => BannerDataModel.fromJson(item))
//           .where((banner) => banner.isActive)
//           .toList();

//       print("✅ Active banners after filtering: ${activeBanners.length}");
//       print("------------------------------------------");

//       // Only cache if we have some data
//       if (rawData.isNotEmpty) {
//         await _cacheBanners(prefs, rawData);
//       }

//       return activeBanners;
//     } catch (e) {
//       print('❌ Error in _fetchFreshBanners: $e');
//       final cachedBanners = await _getCachedBanners(prefs);
//       if (cachedBanners.isNotEmpty) {
//         print(
//             '🔄 API failed, returning ${cachedBanners.length} cached banners as fallback.');
//         return cachedBanners;
//       }
//       rethrow; // Re-throw if cache is also empty
//     }
//   }

//   // /// Fetch fresh banners from API and cache them
//   // static Future<List<BannerDataModel>> _fetchFreshBanners(
//   //     SharedPreferences prefs) async {
//   //   try {
//   //     final List<dynamic> rawData = await _fetchBannersFromApi();
//   //     await _cacheBanners(prefs, rawData);

//   //     return rawData
//   //         .map((item) => BannerDataModel.fromJson(item))
//   //         .where((banner) => banner.isActive)
//   //         .toList();
//   //   } catch (e) {
//   //     print('❌ Error fetching fresh banners: $e');
//   //     final cachedBanners = await _getCachedBanners(prefs);
//   //     if (cachedBanners.isNotEmpty) {
//   //       print('🔄 API failed, returning cached data as fallback.');
//   //       return cachedBanners;
//   //     }
//   //     rethrow;
//   //   }
//   // }

//   /// Save new data to SharedPreferences
//   static Future<void> _cacheBanners(
//       SharedPreferences prefs, List<dynamic> rawData) async {
//     await prefs.setString(_cacheKeyBanners, json.encode(rawData));
//     await prefs.setString(_cacheKeyTimestamp, DateTime.now().toIso8601String());
//     print('💾 Successfully cached ${rawData.length} banners.');
//   }

//   /// Refresh data in the background without blocking UI
//   static void _loadFreshDataInBackground() {
//     Future.delayed(const Duration(milliseconds: 500), () async {
//       try {
//         print('🔄 Loading fresh banners in background...');
//         final prefs = await SharedPreferences.getInstance();
//         await _fetchFreshBanners(prefs);
//         print('✅ Banner background refresh completed.');
//       } catch (e) {
//         print('⚠️ Banner background refresh failed: $e');
//       }
//     });
//   }

// // In class BannerService...

//   /// Private method to fetch data from API
//   static Future<List<dynamic>> _fetchBannersFromApi() async {
//     // const String endpoint =
//     //     'https://dashboard.cpplayers.com/public/api/v2/getCustomImageSlider';
//     // final prefs = await SharedPreferences.getInstance();
//     // final authKey = prefs.getString('result_auth_key') ?? 'vLQTuPZUxktl5mVW';

//     // final headers = {
//     //   'auth-key': authKey,
//     //   'Accept': 'application/json',
//     //   'Content-Type': 'application/json',
//     //   'domain': 'coretechinfo.com',
//     // };

//     // // 🕵️‍♂️ DEBUG: Print request details
//     // print("----------- API Request Details -----------");
//     // print("🚀 Calling API Endpoint: $endpoint");
//     // print("🔑 Headers: $headers");
//     // print("-----------------------------------------");

//     try {
//       // final response = await https
//       //     .get(Uri.parse(endpoint), headers: headers)
//       //     .timeout(const Duration(seconds: 10)); // Added a timeout

//     final prefs = await SharedPreferences.getInstance();
//     final authKey = prefs.getString('result_auth_key') ?? '';

//     final response = await https.get(
//       Uri.parse('https://dashboard.cpplayers.com/api/v2/getCustomImageSlider'),
//       headers: {
//         'auth-key': authKey,
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'domain': 'coretechinfo.com'
//       },
//     ).timeout(const Duration(seconds: 30));



//       // 🕵️‍♂️ DEBUG: Print response details
//       print("----------- API Response Details -----------");
//       print("✅ slider authKey: ${authKey}");
//       print("✅ Status Code: ${response.statusCode}");
//       print("📦 Response Body: ${response.body}");
//       print("------------------------------------------");

//       if (response.statusCode == 200) {
//         // Check if the body is not empty
//         if (response.body.isNotEmpty) {
//           final decodedData = json.decode(response.body);

//           // 🕵️‍♂️ DEBUG: Check the type of decoded data
//           if (decodedData is List) {
//             print("👍 Successfully parsed JSON as a List.");
//             return decodedData;
//           } else {
//             // This will catch cases where the API returns a map {'data': [...]} or an error map
//             print(
//                 "⚠️ WARNING: API did not return a JSON List. It returned a ${decodedData.runtimeType}.");
//             throw Exception('API response is not a List as expected.');
//           }
//         } else {
//           print("⚠️ WARNING: API returned a 200 OK but with an empty body.");
//           return []; // Return an empty list
//         }
//       } else {
//         // If status code is not 200, it's an error
//         throw Exception(
//             'Failed to load banners. Status Code: ${response.statusCode}');
//       }
//     } catch (e) {
//       // 🕵️‍♂️ DEBUG: Print any exception that occurs
//       print("----------- 🛑 API CALL FAILED 🛑 -----------");
//       print("❌ Error fetching banners: $e");
//       print("-------------------------------------------");
//       // Re-throw the exception so the calling function can handle it
//       throw Exception('Failed to load banners: $e');
//     }
//   }

// //   /// Private method to fetch data from API
// //   static Future<List<dynamic>> _fetchBannersFromApi() async {
// //     const String endpoint =
// //         'https://dashboard.cpplayers.com/public/api/v2/getCustomImageSlider';
// //     final prefs = await SharedPreferences.getInstance();
// //     final authKey = prefs.getString('result_auth_key') ?? 'vLQTuPZUxktl5mVW';

// //     final headers = {
// //       'auth-key': authKey,
// //       'Accept': 'application/json',
// //       'Content-Type': 'application/json',
// //       'domain': 'coretechinfo.com',
// //     };

// //     try {
// //       final response = await https.get(Uri.parse(endpoint), headers: headers);
// //       // .timeout(const Duration(seconds: 15));

// //       if (response.statusCode == 200) {
// //         return json.decode(response.body);
// //       } else {
// //         throw Exception('Failed to load banners: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       throw Exception('Failed to load banners: $e');
// //     }
// //   }
// }

// // Ultra Fast Banner Slider Widget
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

// class _BannerSliderState extends State<BannerSlider>
//     with SingleTickerProviderStateMixin {
//   // final SocketService _socketService = SocketService();
//   List<BannerDataModel> bannerList = [];
//   List<NewsItemModel>? _newsItemListCache;
//   bool isLoading = true;
//   String errorMessage = '';
//   late PageController _pageController;
//   Timer? _timer;
//   String? selectedContentId;
//   final FocusNode _buttonFocusNode = FocusNode();
//   bool _isNavigating = false;
//   late FocusProvider _refreshProvider;

//   late AnimationController _shimmerController;
//   late Animation<double> _shimmerAnimation;

//   List<NewsItemModel> get newsItemList {
//     if (_newsItemListCache == null ||
//         _newsItemListCache!.length != bannerList.length) {
//       _newsItemListCache =
//           bannerList.map((banner) => banner.toNewsItemModel()).toList();
//     }
//     return _newsItemListCache!;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeShimmerAnimation();
//     _initializeSlider();
//   }

//   void _initializeShimmerAnimation() {
//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
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
//     // _socketService.dispose();
//     _shimmerController.dispose();
//     _timer?.cancel();
//     // _buttonFocusNode.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeSlider() async {
//     // _socketService.initSocket();
//     _pageController = PageController();

//     _buttonFocusNode.addListener(() {
//       if (_buttonFocusNode.hasFocus) {
//         widget.onFocusChange?.call(true);
//       }
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         context.read<FocusProvider>().registerFocusNode('watchNow', _buttonFocusNode);
//       }
//     });

//     _buttonFocusNode.addListener(_onButtonFocusNode);

//     // ✅ Naye service se data load karo
//     await _fetchBannersWithCache();
//   }

//   // ✅ STEP 3: PURANE DATA LOADING FUNCTIONS KI JAGAH YEH NAYA FUNCTION
//   Future<void> _fetchBannersWithCache() async {
//     if (!mounted) return;
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final fetchedBanners = await BannerService.getAllBanners();
//       if (mounted) {
//         _showBannersInstantly(fetchedBanners);
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           errorMessage = 'Failed to load banners: $e';
//           bannerList = [];
//         });
//       }
//       print('❌ Error in _fetchBannersWithCache: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   void _showBannersInstantly(List<BannerDataModel> banners) {
//     if (mounted) {
//       setState(() {
//         bannerList = banners;
//         selectedContentId =
//             banners.isNotEmpty ? banners[0].id.toString() : null;
//         errorMessage = '';
//         _newsItemListCache = null;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           _startAutoSlide();
//           _prefetchImages();
//         }
//       });
//     }
//   }

//   void _prefetchImages() {
//     for (var banner in bannerList) {
//       precacheImage(
//         CachedNetworkImageProvider(banner.banner),
//         context,
//       ).catchError((e) => null);
//     }
//   }

//   // Public refresh method
//   Future<void> refreshData() async {
//     await _fetchBannersWithCache();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<FocusProvider>(
//       builder: (context, focusProvider, child) {
//         return Scaffold(
//           backgroundColor:
//               Colors.transparent, // Use transparent for better integration
//           body: _buildBody(focusProvider),
//         );
//       },
//     );
//   }

//   // Baki UI build functions (unchanged)...

//   Widget _buildBody(FocusProvider focusProvider) {
//     if (isLoading) {
//       return _buildLoadingWidget();
//     }
//     if (bannerList.isEmpty) {
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
//           const SizedBox(height: 20),
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
//           const SizedBox(height: 20),
//           Text(
//             'No banners available',
//             style: TextStyle(color: hintColor, fontSize: nametextsz),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: refreshData,
//             icon: const Icon(Icons.refresh),
//             label: const Text('Refresh'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget _buildBannerSlider(FocusProvider focusProvider) {
//   //   return Stack(
//   //     children: [
//   //       PageView.builder(
//   //         controller: _pageController,
//   //         itemCount: bannerList.length,
//   //         onPageChanged: (index) {
//   //           if (mounted) {
//   //             setState(() {
//   //               selectedContentId = bannerList[index].id.toString();
//   //             });
//   //           }
//   //         },
//   //         itemBuilder: (context, index) {
//   //           final banner = bannerList[index];
//   //           return _buildSimpleBanner(banner, focusProvider);
//   //         },
//   //       ),
//   //       _buildNavigationButton(focusProvider),
//   //       if (bannerList.length > 1) _buildPageIndicators(),
//   //     ],
//   //   );
//   // }

//   Widget _buildBannerSlider(FocusProvider focusProvider) {
//     return Stack(
//       children: [
//         // PageView (Pehle jaisa hi)
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
//             return _buildSimpleBanner(banner, focusProvider);
//           },
//         ),

//         // Navigation Button (Pehle jaisa hi)
//         _buildNavigationButton(focusProvider),

//         // Page Indicators (Pehle jaisa hi)
//         if (bannerList.length > 1) _buildPageIndicators(),

//         // ✅ NEW: Yahan par stationary naam aur gradient add karein
//         _buildStationaryTitle(focusProvider),
//       ],
//     );
//   }

// // ✅ NEW: Yeh poora naya function add karein
//   Widget _buildStationaryTitle(FocusProvider focusProvider) {
//     // Maujooda banner ko list se dhoondhein
//     final currentBanner = bannerList.firstWhere(
//       (b) => b.id.toString() == selectedContentId,
//       // Agar banner na mile to fallback
//       orElse: () => bannerList.isNotEmpty
//           ? bannerList.first
//           : BannerDataModel(
//               id: 0,
//               title: '',
//               banner: '',
//               contentType: 0,
//               status: 0,
//               createdAt: '',
//               updatedAt: ''),
//     );

//     return Stack(
//       children: [
//         // Gradient Overlay
//         Positioned(
//           left: 0,
//           right: 0,
//           bottom: 0,
//           height: screenhgt * 0.15,
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.bottomCenter,
//                 end: Alignment.topCenter,
//                 colors: [
//                   Colors.black.withOpacity(0.8),
//                   Colors.black.withOpacity(0.0),
//                 ],
//                 stops: const [0.0, 1.0],
//               ),
//             ),
//           ),
//         ),

//         // // Stylish Name (jo slide nahi hoga)
//         // Positioned(
//         //   left: screenwdt * 0.03,
//         //   right: screenwdt * 0.03,
//         //   bottom: screenhgt * 0.03,
//         //   child: AnimatedSwitcher(
//         //     duration: const Duration(milliseconds: 400),
//         //     transitionBuilder: (Widget child, Animation<double> animation) {
//         //       return FadeTransition(opacity: animation, child: child);
//         //     },
//         //     child: ShaderMask(
//         //       // Key dena zaroori hai taaki AnimatedSwitcher ko pata chale ki content badal gaya hai
//         //       key: ValueKey<String>(currentBanner.title),
//         //       shaderCallback: (Rect bounds) {
//         //         return const LinearGradient(
//         //           begin: Alignment.topLeft,
//         //           end: Alignment.bottomRight,
//         //           colors: [
//         //             Colors.deepOrangeAccent,
//         //             Colors.pinkAccent,
//         //             Colors.purpleAccent,
//         //             Colors.blueAccent,
//         //           ],
//         //         ).createShader(bounds);
//         //       },
//         //       child: Text(
//         //         currentBanner.title,
//         //         maxLines: 1,
//         //         overflow: TextOverflow.ellipsis,
//         //         style: TextStyle(
//         //           fontFamily: 'RobotoSlab',
//         //           fontSize: screenhgt * 0.05,
//         //           fontWeight: FontWeight.bold,
//         //           color: Colors.white,
//         //           shadows: [
//         //             Shadow(
//         //               color: Colors.black.withOpacity(0.8),
//         //               offset: const Offset(2, 2),
//         //               blurRadius: 4,
//         //             ),
//         //           ],
//         //           letterSpacing: 1.2,
//         //         ),
//         //       ),
//         //     ),
//         //   ),
//         // ),
//       ],
//     );
//   }

//   Widget _buildNavigationButton(FocusProvider focusProvider) {
//     return Positioned(
//       top: screenhgt * 0.2,
//       left: screenwdt * 0.03,
//       child: Focus(
//         focusNode: _buttonFocusNode,
//         onKeyEvent: _handleKeyEvent,
//         child: GestureDetector(
//           onTap: _handleWatchNowTap,
//           child: RandomLightColorWidget(
//             hasFocus: focusProvider.isButtonFocused,
//             childBuilder: (Color randomColor) {
//               return AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 margin: EdgeInsets.all(screenwdt * 0.001),
//                 padding: EdgeInsets.symmetric(
//                   vertical: screenhgt * 0.01,
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
//                             color:
//                                 (focusProvider.currentFocusColor ?? randomColor)
//                                     .withOpacity(0.5),
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
//                       Icons.chevron_left,
//                       color: focusProvider.isButtonFocused
//                           ? focusProvider.currentFocusColor ?? randomColor
//                           : hintColor,
//                       size: menutextsz * 1.5,
//                     ),
//                     const SizedBox(width: 8),
//                     Icon(
//                       Icons.chevron_right,
//                       color: focusProvider.isButtonFocused
//                           ? focusProvider.currentFocusColor ?? randomColor
//                           : hintColor,
//                       size: menutextsz * 1.5,
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
//           bool isSelected =
//               selectedContentId == bannerList[index].id.toString();
//           return AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             margin: const EdgeInsets.symmetric(horizontal: 4),
//             width: isSelected ? 12 : 8,
//             height: isSelected ? 12 : 8,
//             decoration: BoxDecoration(
//               color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
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

//   Widget _buildSimpleBanner(
//       BannerDataModel banner, FocusProvider focusProvider) {
//     final String deviceName = context.watch<DeviceInfoProvider>().deviceName;
//     // ✅ Naya unique URL banayein
//     final String uniqueImageUrl = "${banner.banner}?v=${banner.updatedAt}";
//     // ✅ Naya unique cache key banayein
//     final String uniqueCacheKey = "${banner.id.toString()}_${banner.updatedAt}";

//     return SizedBox(
//       width: screenwdt,
//       height: screenhgt,
//       child: Stack(
//         children: [
//           CachedNetworkImage(
//             imageUrl: uniqueImageUrl,
//             fit: BoxFit.fill,
//             placeholder: (context, url) =>
//                 Image.asset('assets/streamstarting.gif'),
//             errorWidget: (context, url, error) =>
//                 Image.asset('assets/streamstarting.gif'),
//             cacheKey: uniqueCacheKey,
//             fadeInDuration: const Duration(milliseconds: 100),
//             placeholderFadeInDuration: Duration.zero,
//             memCacheHeight: 400,
//             memCacheWidth: 600,
//             useOldImageOnUrlChange: true,
//             width: screenwdt,
//             height: screenhgt,
//           ),
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
//                           Colors.white.withOpacity(0.15),
//                           Colors.transparent,
//                         ],
//                         stops: const [0.0, 0.5, 1.0],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }

//   // // Event Handlers
//   // KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
//   //   if (event is! KeyDownEvent) return KeyEventResult.ignored;

//   //   if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//   //     if (_pageController.hasClients &&
//   //         _pageController.page != null &&
//   //         _pageController.page! < bannerList.length - 1) {
//   //       _pageController.nextPage(
//   //         duration: const Duration(milliseconds: 300),
//   //         curve: Curves.easeInOut,
//   //       );
//   //       return KeyEventResult.handled;
//   //     }
//   //   } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//   //     if (_pageController.hasClients &&
//   //         _pageController.page != null &&
//   //         _pageController.page! > 0) {
//   //       _pageController.previousPage(
//   //         duration: const Duration(milliseconds: 300),
//   //         curve: Curves.easeInOut,
//   //       );
//   //       return KeyEventResult.handled;
//   //     }
//   //   } else if (event.logicalKey == LogicalKeyboardKey.select ||
//   //       event.logicalKey == LogicalKeyboardKey.enter) {
//   //     _handleWatchNowTap();
//   //     return KeyEventResult.handled;
//   //   }
//   //   return KeyEventResult.ignored;
//   // }



//   // Event Handlers
// // ✅✅✅ YAHAN BADLAV KIYA GAYA HAI ✅✅✅
// KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
//   if (event is! KeyDownEvent) return KeyEventResult.ignored;

//   if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//     if (_pageController.hasClients &&
//         _pageController.page != null &&
//         _pageController.page! < bannerList.length - 1) {
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//       return KeyEventResult.handled;
//     }
//   } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//     if (_pageController.hasClients &&
//         _pageController.page != null &&
//         _pageController.page! > 0) {
//       _pageController.previousPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//       return KeyEventResult.handled;
//     }
//   } 
//   // ✅ Naya logic: Arrow Down ke liye
//   else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//     // FocusProvider se neeche wale section (Live Channels) par focus bhejein
//     node.unfocus();
//     widget.onFocusChange?.call(false);
//     Future.delayed(const Duration(milliseconds: 50), () {
//       if (mounted) {
//         // Aapke FocusProvider ka function yahan call ho raha hai
//         context.read<FocusProvider>().requestFocus('liveChannelLanguage');
//       }
//     });
//     return KeyEventResult.handled;
//   } 
//   else if (event.logicalKey == LogicalKeyboardKey.select ||
//       event.logicalKey == LogicalKeyboardKey.enter) {
//     _handleWatchNowTap();
//     return KeyEventResult.handled;
//   }
//   return KeyEventResult.ignored;
// }

//   // ✅ STEP 4: VIDEO PLAY LOGIC KO AASAAN BANAYA GAYA
//   void _handleWatchNowTap() {
//     if (selectedContentId != null && bannerList.isNotEmpty) {
//       try {
//         final banner = bannerList.firstWhere(
//           (b) => b.id.toString() == selectedContentId,
//           orElse: () => bannerList.first,
//         );
//         // Poora banner object pass karein taaki dobara fetch na karna pade
//         fetchAndPlayVideo(banner, newsItemList);
//       } catch (e) {
//         print("Error finding banner: $e");
//       }
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // _refreshProvider = context.watch<FocusProvider>();
//     // if (_refreshProvider.shouldRefreshBanners) {
//     //   _handleProviderRefresh();
//     // }
//   }

//   // Future<void> _handleProviderRefresh() async {
//   //   if (!mounted) return;
//   //   await _fetchBannersWithCache();
//   //   _refreshProvider.markBannersRefreshed();
//   // }

//   void _startAutoSlide() {
//     _timer?.cancel(); // Pehle se chal rahe timer ko rokein
//     if (bannerList.isNotEmpty) {
//       _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
//         if (!mounted || !_pageController.hasClients) {
//           timer.cancel();
//           return;
//         }
//         if (_pageController.page == bannerList.length - 1) {
//           _pageController.jumpToPage(0);
//         } else {
//           _pageController.nextPage(
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeIn,
//           );
//         }
//       });
//     }
//   }

//   void _onButtonFocusNode() {
//     if (!mounted) return;

//     if (_buttonFocusNode.hasFocus) {
//       final random = Random();
//       final color = Color.fromRGBO(
//         random.nextInt(256),
//         random.nextInt(256),
//         random.nextInt(256),
//         1,
//       );
//       context.read<FocusProvider>().setButtonFocus(true, color: color);
//       context.read<ColorProvider>().updateColor(color, true);
//     } else {
//       context.read<FocusProvider>().resetFocus();
//       context.read<ColorProvider>().resetColor();
//     }
//   }

//   // ✅ STEP 5: VIDEO PLAY FUNCTION AB BANNER OBJECT LETA HAI
//   Future<void> fetchAndPlayVideo(
//       BannerDataModel banner, List<NewsItemModel> channelList) async {
//     if (_isNavigating) return;
//     _isNavigating = true;

//     // Show loading dialog
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return const Center(
//             child: CircularProgressIndicator()); // Simple loader
//       },
//     );

//     try {
//       // Ab API call ki zaroorat nahi, data seedhe banner object se milega
//       final responseData = {
//         'url': banner.url ?? '',
//         'type': banner.contentType.toString(),
//         'banner': banner.banner,
//         'name': banner.title,
//         'stream_type': banner.sourceType ?? '',
//       };

//       if (mounted)
//         Navigator.of(context, rootNavigator: true).pop(); // Close loader

//       if (mounted) {
//         //   Navigator.push(
//         //     context,
//         //     MaterialPageRoute(
//         //       builder: (context) => VideoScreen(
//         //         videoUrl: responseData['url']!,
//         //         channelList: channelList,
//         //         videoId: banner.id,
//         //         // videoType: responseData['type']!,
//         //         isLive: true,
//         //         // isVOD: false,
//         //         bannerImageUrl: responseData['banner']!,
//         //         // startAtPosition: Duration.zero,
//         //         // isBannerSlider: true,
//         //         // source: 'isBannerSlider',
//         //         isSearch: false,
//         //         // unUpdatedUrl: responseData['url']!,
//         //         name: responseData['name']!,
//         //         liveStatus: true, updatedAt: '',
//         //       ),
//         //     ),
//         //   );
//       }
//     } catch (e) {
//       if (mounted)
//         Navigator.of(context, rootNavigator: true).pop(); // Close loader
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to load video: $e'),
//             backgroundColor: Colors.red.shade700,
//           ),
//         );
//       }
//     } finally {
//       _isNavigating = false;
//     }
//   }
// }






// import 'dart:async';
// import 'dart:convert';
// import 'dart:math'; // Keep this import
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show.dart';
// import 'package:mobi_tv_entertainment/main.dart'; // Assuming bannerhgt, screenwdt, etc. are defined here
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart'; // Still needed for navigation
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart'; // Make sure this is the correct path
// import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';
// // import 'package:mobi_tv_entertainment/components/widgets/utils/random_light_color_widget.dart'; // REMOVED
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // ✅ Banner Data Model (No Changes)
// class BannerDataModel {
//  final int id;
//  final String title;
//  final String banner;
//  final int contentType;
//  final int? contentId;
//  final String? sourceType;
//  final String? url;
//  final int status;
//  final String createdAt;
//  final String updatedAt;
//  final String? deletedAt;

//  BannerDataModel({
//    required this.id,
//    required this.title,
//    required this.banner,
//    required this.contentType,
//    this.contentId,
//    this.sourceType,
//    this.url,
//    required this.status,
//    required this.createdAt,
//    required this.updatedAt,
//    this.deletedAt,
//  });

//  factory BannerDataModel.fromJson(Map<String, dynamic> json) {
//    return BannerDataModel(
//      id: json['id'] ?? 0,
//      title: json['title'] ?? '',
//      banner: json['banner'] ?? '',
//      contentType: json['content_type'] ?? 1,
//      contentId: json['content_id'],
//      sourceType: json['source_type'],
//      url: json['url'],
//      status: json['status'] ?? 0,
//      createdAt: json['created_at'] ?? '',
//      updatedAt: json['updated_at'] ?? '',
//      deletedAt: json['deleted_at'],
//    );
//  }

//  bool get isActive => status == 1 && deletedAt == null;

//  NewsItemModel toNewsItemModel() {
//    return NewsItemModel(
//      id: id.toString(),
//      name: title,
//      updatedAt: updatedAt,
//      banner: banner,
//      contentId: id.toString(),
//      type: contentType.toString(),
//      url: url ?? '',
//      status: status.toString(),
//      unUpdatedUrl: '',
//      poster: '',
//      image: '',
//    );
//  }
// }

// // ✅ Banner Service (No Changes Needed Here)
// class BannerService {
//  static const String _cacheKeyBanners = 'cached_banners_data';
//  static const String _cacheKeyTimestamp = 'cached_banners_timestamp';
//  static const Duration _cacheDuration = Duration(hours: 2);

//  static Future<List<BannerDataModel>> getAllBanners(
//      {bool forceRefresh = false}) async {
//    final prefs = await SharedPreferences.getInstance();

//    if (!forceRefresh && await _shouldUseCache(prefs)) {
//      print('📦 Loading Banners from cache...');
//      final cachedBanners = await _getCachedBanners(prefs);
//      if (cachedBanners.isNotEmpty) {
//        _loadFreshDataInBackground();
//        return cachedBanners;
//      }
//    }

//    print('🌐 Loading fresh Banners from API...');
//    return await _fetchFreshBanners(prefs);
//  }

//  static Future<bool> _shouldUseCache(SharedPreferences prefs) async {
//    final timestampStr = prefs.getString(_cacheKeyTimestamp);
//    if (timestampStr == null) return false;
//    final cachedTimestamp = DateTime.tryParse(timestampStr);
//    if (cachedTimestamp == null) return false;
//    final isCacheValid = DateTime.now().difference(cachedTimestamp) < _cacheDuration;
//    print(isCacheValid ? '✅ Banner Cache is valid.' : '⏰ Banner Cache expired.');
//    return isCacheValid;
//  }

//  static Future<List<BannerDataModel>> _getCachedBanners(
//      SharedPreferences prefs) async {
//    final cachedData = prefs.getString(_cacheKeyBanners);
//    if (cachedData == null || cachedData.isEmpty) return [];
//    try {
//      final List<dynamic> jsonData = json.decode(cachedData);
//      return jsonData
//          .map((item) => BannerDataModel.fromJson(item))
//          .where((banner) => banner.isActive)
//          .toList();
//    } catch (e) {
//      print('❌ Error parsing cached banners: $e');
//      return [];
//    }
//  }

//  static Future<List<BannerDataModel>> _fetchFreshBanners(
//      SharedPreferences prefs) async {
//    try {
//      final List<dynamic> rawData = await _fetchBannersFromApi();
//      final activeBanners = rawData
//          .map((item) => BannerDataModel.fromJson(item))
//          .where((banner) => banner.isActive)
//          .toList();
//      if (rawData.isNotEmpty) {
//        await _cacheBanners(prefs, rawData);
//      }
//      return activeBanners;
//    } catch (e) {
//      print('❌ Error in _fetchFreshBanners: $e');
//      final cachedBanners = await _getCachedBanners(prefs);
//      if (cachedBanners.isNotEmpty) {
//        print('🔄 API failed, returning ${cachedBanners.length} cached banners as fallback.');
//        return cachedBanners;
//      }
//      rethrow;
//    }
//  }

//  static Future<void> _cacheBanners(
//      SharedPreferences prefs, List<dynamic> rawData) async {
//    await prefs.setString(_cacheKeyBanners, json.encode(rawData));
//    await prefs.setString(_cacheKeyTimestamp, DateTime.now().toIso8601String());
//    print('💾 Successfully cached ${rawData.length} banners.');
//  }

//  static void _loadFreshDataInBackground() {
//    Future.delayed(const Duration(milliseconds: 500), () async {
//      try {
//        print('🔄 Loading fresh banners in background...');
//        final prefs = await SharedPreferences.getInstance();
//        await _fetchFreshBanners(prefs);
//        print('✅ Banner background refresh completed.');
//      } catch (e) {
//        print('⚠️ Banner background refresh failed: $e');
//      }
//    });
//  }

//  static Future<List<dynamic>> _fetchBannersFromApi() async {
//    try {
//      final prefs = await SharedPreferences.getInstance();
//      final authKey = prefs.getString('result_auth_key') ?? '';
//      final response = await https.get(
//        Uri.parse('https://dashboard.cpplayers.com/api/v2/getCustomImageSlider'),
//        headers: {
//          'auth-key': authKey,
//          'Content-Type': 'application/json',
//          'Accept': 'application/json',
//          'domain': 'coretechinfo.com'
//        },
//      ).timeout(const Duration(seconds: 30));

//      print("----------- API Response Details -----------");
//      print("✅ slider authKey: ${authKey}");
//      print("✅ Status Code: ${response.statusCode}");
//      // print("📦 Response Body: ${response.body}"); // Optional: Can be long
//      print("------------------------------------------");


//      if (response.statusCode == 200) {
//        if (response.body.isNotEmpty) {
//          final decodedData = json.decode(response.body);
//          if (decodedData is List) {
//            print("👍 Successfully parsed JSON as a List.");
//            return decodedData;
//          } else {
//            print("⚠️ WARNING: API did not return a JSON List. It returned a ${decodedData.runtimeType}.");
//            throw Exception('API response is not a List as expected.');
//          }
//        } else {
//          print("⚠️ WARNING: API returned a 200 OK but with an empty body.");
//          return [];
//        }
//      } else {
//        throw Exception('Failed to load banners. Status Code: ${response.statusCode}');
//      }
//    } catch (e) {
//      print("----------- 🛑 API CALL FAILED 🛑 -----------");
//      print("❌ Error fetching banners: $e");
//      print("-------------------------------------------");
//      throw Exception('Failed to load banners: $e');
//    }
//  }
// }

// // ✅ Ultra Fast Banner Slider Widget (Simplified State Management)
// class BannerSlider extends StatefulWidget {
//  final Function(bool)? onFocusChange; // Still useful for parent communication
//  final FocusNode focusNode; // Keep this if parent needs to control focus

//  const BannerSlider({
//    Key? key,
//    this.onFocusChange,
//    required this.focusNode, // Keep receiving from parent if needed
//  }) : super(key: key);

//  @override
//  _BannerSliderState createState() => _BannerSliderState();
// }

// class _BannerSliderState extends State<BannerSlider>
//    with SingleTickerProviderStateMixin {
//  // State Variables
//  List<BannerDataModel> bannerList = [];
//  List<NewsItemModel>? _newsItemListCache; // Cache for video player playlist
//  bool isLoading = true;
//  String errorMessage = '';

//  // UI Control
//  late PageController _pageController;
//  Timer? _timer;
//  String? selectedContentId; // To know which banner is currently shown
//  bool _isNavigating = false; // Prevent double navigation

//  // Focus Node (Managed within this widget)
//  final FocusNode _buttonFocusNode = FocusNode();

//  // Animations
//  late AnimationController _shimmerController;
//  late Animation<double> _shimmerAnimation;

//  // Getter for playlist
//  List<NewsItemModel> get newsItemList {
//    if (_newsItemListCache == null || _newsItemListCache!.length != bannerList.length) {
//      _newsItemListCache = bannerList.map((banner) => banner.toNewsItemModel()).toList();
//    }
//    return _newsItemListCache!;
//  }

//  @override
//  void initState() {
//    super.initState();
//    _initializeShimmerAnimation();
//    _initializeSlider();
//  }

//  void _initializeShimmerAnimation() {
//    _shimmerController = AnimationController(
//      duration: const Duration(milliseconds: 1200),
//      vsync: this,
//    )..repeat();
//    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
//        CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));
//  }

//  @override
//  void dispose() {
//    if (_pageController.hasClients) {
//      _pageController.dispose();
//    }
//    _shimmerController.dispose();
//    _timer?.cancel();
//    // ❗️ _buttonFocusNode will be disposed by the FocusProvider where it's registered.
//    // DO NOT dispose it here if registered externally.
//    // If it were *only* used internally, you would dispose it: _buttonFocusNode.dispose();
//    super.dispose();
//  }

//  Future<void> _initializeSlider() async {
//    _pageController = PageController();

//    // Simple listener to trigger rebuilds on focus change for UI updates
//    _buttonFocusNode.addListener(() {
//      if (mounted) {
//        setState(() {}); // Update UI based on focus
//        widget.onFocusChange?.call(_buttonFocusNode.hasFocus); // Inform parent
//      }
//    });

//    // Register the focus node with the external provider
//    WidgetsBinding.instance.addPostFrameCallback((_) {
//      if (mounted) {
//        // Ensure context is available
//        try {
//          // Use context.read ONLY inside callbacks like this or build methods
//          context.read<FocusProvider>().registerFocusNode('watchNow', _buttonFocusNode);
//          print("✅ watchNow FocusNode registered in FocusProvider.");
//        } catch (e) {
//          print("❌ Error registering watchNow FocusNode: $e");
//          // Handle error, maybe the provider isn't ready?
//        }
//      }
//    });

//    // Fetch initial banner data
//    await _fetchBannersWithCache();
//  }

//  Future<void> _fetchBannersWithCache() async {
//    if (!mounted) return;
//    setState(() => isLoading = true);
//    try {
//      final fetchedBanners = await BannerService.getAllBanners();
//      if (mounted) {
//        _showBannersInstantly(fetchedBanners);
//      }
//    } catch (e) {
//      if (mounted) {
//        setState(() {
//          errorMessage = 'Failed to load banners: $e';
//          bannerList = [];
//        });
//      }
//      print('❌ Error in _fetchBannersWithCache: $e');
//    } finally {
//      if (mounted) {
//        setState(() => isLoading = false);
//      }
//    }
//  }

//  void _showBannersInstantly(List<BannerDataModel> banners) {
//    if (mounted) {
//      setState(() {
//        bannerList = banners;
//        selectedContentId = banners.isNotEmpty ? banners[0].id.toString() : null;
//        errorMessage = '';
//        _newsItemListCache = null; // Reset playlist cache
//      });
//      WidgetsBinding.instance.addPostFrameCallback((_) {
//        if (mounted) {
//          _startAutoSlide();
//          _prefetchImages();
//        }
//      });
//    }
//  }

//  void _prefetchImages() {
//    if (!mounted) return; // Check mounted before using context
//    for (var banner in bannerList) {
//      if (banner.banner.isNotEmpty) {
//        precacheImage(CachedNetworkImageProvider(banner.banner), context)
//            .catchError((e, stackTrace) {
//          // Silently ignore pre-cache errors or log them minimally
//          // print('Warning: Failed to precache image ${banner.banner}. Error: $e');
//          return null;
//        });
//      }
//    }
//  }


//  Future<void> refreshData() async {
//    await _fetchBannersWithCache();
//  }

//  @override
//  Widget build(BuildContext context) {
//    // No longer need Consumer<FocusProvider> here just for button state
//    return Scaffold(
//      backgroundColor: Colors.transparent,
//      body: _buildBody(), // Pass focus state directly if needed, or check node.hasFocus
//    );
//  }

//  Widget _buildBody() {
//    if (isLoading) {
//      return _buildLoadingWidget();
//    }
//    if (errorMessage.isNotEmpty && bannerList.isEmpty) {
//      // Show error only if loading failed AND there's no cached data
//      return _buildErrorWidget();
//    }
//    if (bannerList.isEmpty) {
//      return _buildEmptyWidget();
//    }
//    return _buildBannerSlider();
//  }


//  Widget _buildLoadingWidget() {
//    return Center(
//      child: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: [
//          SpinKitFadingCircle(color: borderColor, size: 50.0),
//          const SizedBox(height: 20),
//          Text(
//            'Loading banners...',
//            style: TextStyle(color: hintColor, fontSize: nametextsz),
//          ),
//        ],
//      ),
//    );
//  }

//  Widget _buildErrorWidget() {
//   return Center(
//      child: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: [
//          Icon(
//            Icons.cloud_off,
//            color: hintColor.withOpacity(0.5),
//            size: 50,
//          ),
//          const SizedBox(height: 20),
//          Text(
//            'Failed to load banners',
//            style: TextStyle(color: hintColor, fontSize: nametextsz),
//            textAlign: TextAlign.center,
//          ),
//          const SizedBox(height: 10),
//           Text(
//            errorMessage, // Show specific error
//            style: TextStyle(color: Colors.red[300], fontSize: nametextsz * 0.8),
//            textAlign: TextAlign.center,
//          ),
//          const SizedBox(height: 20),
//          ElevatedButton.icon(
//            onPressed: refreshData,
//            icon: const Icon(Icons.refresh),
//            label: const Text('Retry'),
//            style: ElevatedButton.styleFrom(
//              backgroundColor: Colors.blue,
//              foregroundColor: Colors.white,
//            ),
//          ),
//        ],
//      ),
//    );
// }


//  Widget _buildEmptyWidget() {
//    return Center(
//      child: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: [
//          Icon(
//            Icons.image_not_supported,
//            color: hintColor.withOpacity(0.5),
//            size: 50,
//          ),
//          const SizedBox(height: 20),
//          Text(
//            'No banners available',
//            style: TextStyle(color: hintColor, fontSize: nametextsz),
//          ),
//          const SizedBox(height: 20),
//          ElevatedButton.icon(
//            onPressed: refreshData, // Allow refresh even if empty
//            icon: const Icon(Icons.refresh),
//            label: const Text('Refresh'),
//            style: ElevatedButton.styleFrom(
//              backgroundColor: Colors.blue,
//              foregroundColor: Colors.white,
//            ),
//          ),
//        ],
//      ),
//    );
//  }

//  Widget _buildBannerSlider() {
//    return Stack(
//      children: [
//        PageView.builder(
//          controller: _pageController,
//          itemCount: bannerList.length,
//          onPageChanged: (index) {
//            if (mounted) {
//              setState(() => selectedContentId = bannerList[index].id.toString());
//            }
//          },
//          itemBuilder: (context, index) {
//            final banner = bannerList[index];
//            return _buildSimpleBanner(banner);
//          },
//        ),
//        _buildNavigationButton(),
//        if (bannerList.length > 1) _buildPageIndicators(),
//        _buildStationaryTitle(),
//      ],
//    );
//  }

//  Widget _buildStationaryTitle() {
//    final currentBanner = bannerList.firstWhere(
//      (b) => b.id.toString() == selectedContentId,
//      orElse: () => bannerList.isNotEmpty
//          ? bannerList.first
//          : BannerDataModel(id: 0, title: '', banner: '', contentType: 0, status: 0, createdAt: '', updatedAt: ''),
//    );

//    return Stack(
//      children: [
//        Positioned(
//          left: 0, right: 0, bottom: 0, height: screenhgt * 0.15,
//          child: Container(
//            decoration: BoxDecoration(
//              gradient: LinearGradient(
//                begin: Alignment.bottomCenter,
//                end: Alignment.topCenter,
//                colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.0)],
//                stops: const [0.0, 1.0],
//              ),
//            ),
//          ),
//        ),
//        // Optional: Add stationary title text here if needed
//        /*
//        Positioned(
//          left: screenwdt * 0.03,
//          right: screenwdt * 0.03,
//          bottom: screenhgt * 0.03,
//          child: AnimatedSwitcher(...)
//        )
//        */
//      ],
//    );
//  }

//  Widget _buildNavigationButton() {
//    final bool hasFocus = _buttonFocusNode.hasFocus;
//    // Example: Using a fixed focus color or cycling through a predefined list
//    final List<Color> focusColors = [ProfessionalColors.accentBlue, ProfessionalColors.accentPurple, ProfessionalColors.accentGreen];
//    final Color focusColor = focusColors[bannerList.indexWhere((b) => b.id.toString() == selectedContentId) % focusColors.length];


//    return Positioned(
//      top: screenhgt * 0.2,
//      left: screenwdt * 0.03,
//      child: Focus(
//        focusNode: _buttonFocusNode,
//        onKeyEvent: _handleKeyEvent,
//        child: GestureDetector(
//          onTap: _handleWatchNowTap,
//          child: AnimatedContainer(
//            duration: const Duration(milliseconds: 200),
//            margin: EdgeInsets.all(screenwdt * 0.001),
//            padding: EdgeInsets.symmetric(
//              vertical: screenhgt * 0.01,
//              horizontal: screenwdt * 0.02,
//            ),
//            decoration: BoxDecoration(
//              color: hasFocus ? Colors.black87 : Colors.black.withOpacity(0.6),
//              borderRadius: BorderRadius.circular(12),
//              border: Border.all(
//                color: hasFocus ? focusColor : Colors.white.withOpacity(0.3),
//                width: hasFocus ? 3.0 : 1.0,
//              ),
//              boxShadow: hasFocus
//                  ? [BoxShadow(color: focusColor.withOpacity(0.5), blurRadius: 20.0, spreadRadius: 5.0)]
//                  : [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10.0, spreadRadius: 2.0)],
//            ),
//            child: Row(
//              mainAxisSize: MainAxisSize.min,
//              children: [
//                Icon(Icons.chevron_left, color: hasFocus ? focusColor : hintColor, size: menutextsz * 1.5),
//                const SizedBox(width: 8),
//                Icon(Icons.chevron_right, color: hasFocus ? focusColor : hintColor, size: menutextsz * 1.5),
//              ],
//            ),
//          ),
//        ),
//      ),
//    );
//  }

//  Widget _buildPageIndicators() {
//    return Positioned(
//      top: screenhgt * 0.05,
//      right: screenwdt * 0.05,
//      child: Row(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: bannerList.asMap().entries.map((entry) {
//          int index = entry.key;
//          bool isSelected = selectedContentId == bannerList[index].id.toString();
//          return AnimatedContainer(
//            duration: const Duration(milliseconds: 300),
//            margin: const EdgeInsets.symmetric(horizontal: 4),
//            width: isSelected ? 12 : 8,
//            height: isSelected ? 12 : 8,
//            decoration: BoxDecoration(
//              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
//              shape: BoxShape.circle,
//              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, spreadRadius: 1)],
//            ),
//          );
//        }).toList(),
//      ),
//    );
//  }

//  Widget _buildSimpleBanner(BannerDataModel banner) {
//    final bool isButtonFocused = _buttonFocusNode.hasFocus;
//    final String uniqueImageUrl = "${banner.banner}?v=${banner.updatedAt}";
//    final String uniqueCacheKey = "${banner.id.toString()}_${banner.updatedAt}";

//    return SizedBox(
//      width: screenwdt,
//      height: screenhgt,
//      child: Stack(
//        children: [
//          CachedNetworkImage(
//            imageUrl: uniqueImageUrl,
//            fit: BoxFit.fill,
//            placeholder: (context, url) => Image.asset('assets/streamstarting.gif'),
//            errorWidget: (context, url, error) => Image.asset('assets/streamstarting.gif'),
//            cacheKey: uniqueCacheKey,
//            fadeInDuration: const Duration(milliseconds: 100),
//            placeholderFadeInDuration: Duration.zero,
//            // Consider adjusting memCache based on testing
//            // memCacheHeight: 400,
//            // memCacheWidth: 600,
//            useOldImageOnUrlChange: true,
//            width: screenwdt,
//            height: screenhgt,
//          ),
//          if (isButtonFocused)
//            AnimatedBuilder(
//              animation: _shimmerAnimation,
//              builder: (context, child) {
//                return Positioned.fill(
//                  child: Container(
//                    decoration: BoxDecoration(
//                      gradient: LinearGradient(
//                        begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
//                        end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
//                        colors: [
//                          Colors.transparent,
//                          Colors.white.withOpacity(0.15),
//                          Colors.transparent,
//                        ],
//                        stops: const [0.0, 0.5, 1.0],
//                      ),
//                    ),
//                  ),
//                );
//              },
//            ),
//        ],
//      ),
//    );
//  }

//  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
//    if (event is! KeyDownEvent) return KeyEventResult.ignored;

//    // Get provider instance inside the handler
//    final focusProvider = context.read<FocusProvider>();

//    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//      if (_pageController.hasClients && _pageController.page != null && _pageController.page! < bannerList.length - 1) {
//        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
//        return KeyEventResult.handled;
//      }
//    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//      if (_pageController.hasClients && _pageController.page != null && _pageController.page! > 0) {
//        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
//        return KeyEventResult.handled;
//      }
//    }
//    else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//      node.unfocus();
//      widget.onFocusChange?.call(false); // Inform parent if needed
//      Future.delayed(const Duration(milliseconds: 50), () {
//        if (mounted) {
//          focusProvider.requestFocus('liveChannelLanguage'); // Use provider instance
//        }
//      });
//      return KeyEventResult.handled;
//    }
//    else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
//      _handleWatchNowTap();
//      return KeyEventResult.handled;
//    }
//    return KeyEventResult.ignored;
//  }

//  void _handleWatchNowTap() {
//    if (selectedContentId != null && bannerList.isNotEmpty) {
//      try {
//        final banner = bannerList.firstWhere(
//          (b) => b.id.toString() == selectedContentId,
//          orElse: () => bannerList.first,
//        );
//        fetchAndPlayVideo(banner, newsItemList);
//      } catch (e) {
//        print("Error finding banner: $e");
//      }
//    }
//  }

//  // didChangeDependencies can be removed if not used for refreshing

//  void _startAutoSlide() {
//    _timer?.cancel();
//    if (bannerList.isNotEmpty) {
//      _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
//        if (!mounted || !_pageController.hasClients) {
//          timer.cancel();
//          return;
//        }
//        int nextPage = (_pageController.page!.round() + 1) % bannerList.length;
//        _pageController.animateToPage(
//          nextPage,
//          duration: const Duration(milliseconds: 300),
//          curve: Curves.easeIn,
//        );
//      });
//    }
//  }

//  // _onButtonFocusNode method is removed

//  Future<void> fetchAndPlayVideo(BannerDataModel banner, List<NewsItemModel> channelList) async {
//    if (_isNavigating) return;
//    _isNavigating = true;

//    // Show loading dialog (simple version)
//    showDialog(
//      context: context,
//      barrierDismissible: false,
//      builder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
//    );

//    try {
//      final responseData = {
//        'url': banner.url ?? '',
//        'type': banner.contentType.toString(),
//        'banner': banner.banner,
//        'name': banner.title,
//        'stream_type': banner.sourceType ?? '',
//      };

//      if (mounted) Navigator.of(context, rootNavigator: true).pop(); // Close loader

//      if (mounted) {
//        // Navigate to the appropriate video player based on content type/source type
//        // Example:
//        Navigator.push(
//          context,
//          MaterialPageRoute(
//            builder: (context) => VideoScreen( // Replace with your actual player logic
//              videoUrl: responseData['url']!,
//              bannerImageUrl: responseData['banner']!,
//              channelList: channelList, // Pass the playlist
//              videoId: banner.id,
//              name: responseData['name']!,
//              liveStatus: true, // Determine this based on your data (e.g., contentType)
//              updatedAt: banner.updatedAt,
//              source: 'isBannerSlider',
//            ),
//          ),
//        );
//      }
//    } catch (e) {
//      if (mounted) Navigator.of(context, rootNavigator: true).pop(); // Close loader
//      if (mounted) {
//        ScaffoldMessenger.of(context).showSnackBar(
//          SnackBar(content: Text('Failed to load video: $e'), backgroundColor: Colors.red.shade700),
//        );
//      }
//    } finally {
//      _isNavigating = false;
//    }
//  }

// } // End of _BannerSliderState


// // ✅ Professional Colors (Keep this)
// // ✅ Animation Timing (Keep this)










import 'dart:async';
import 'dart:convert';
import 'dart:math'; // Keep this import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel.dart';
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show.dart'; // Unused import
import 'package:mobi_tv_entertainment/main.dart'; // Assuming bannerhgt, screenwdt, etc. are defined here
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart'; // Still needed for navigation
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart'; // Make sure this is the correct path
import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Banner Data Model (No Changes)
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
     updatedAt: updatedAt,
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

// ✅ Banner Service (No Changes Needed Here)
class BannerService {
 static const String _cacheKeyBanners = 'cached_banners_data';
 static const String _cacheKeyTimestamp = 'cached_banners_timestamp';
 static const Duration _cacheDuration = Duration(hours: 2);

 static Future<List<BannerDataModel>> getAllBanners(
     {bool forceRefresh = false}) async {
   final prefs = await SharedPreferences.getInstance();

   if (!forceRefresh && await _shouldUseCache(prefs)) {
     print('📦 Loading Banners from cache...');
     final cachedBanners = await _getCachedBanners(prefs);
     if (cachedBanners.isNotEmpty) {
       _loadFreshDataInBackground();
       return cachedBanners;
     }
   }

   print('🌐 Loading fresh Banners from API...');
   return await _fetchFreshBanners(prefs);
 }

 static Future<bool> _shouldUseCache(SharedPreferences prefs) async {
   final timestampStr = prefs.getString(_cacheKeyTimestamp);
   if (timestampStr == null) return false;
   final cachedTimestamp = DateTime.tryParse(timestampStr);
   if (cachedTimestamp == null) return false;
   final isCacheValid = DateTime.now().difference(cachedTimestamp) < _cacheDuration;
   print(isCacheValid ? '✅ Banner Cache is valid.' : '⏰ Banner Cache expired.');
   return isCacheValid;
 }

 static Future<List<BannerDataModel>> _getCachedBanners(
     SharedPreferences prefs) async {
   final cachedData = prefs.getString(_cacheKeyBanners);
   if (cachedData == null || cachedData.isEmpty) return [];
   try {
     final List<dynamic> jsonData = json.decode(cachedData);
     return jsonData
         .map((item) => BannerDataModel.fromJson(item))
         .where((banner) => banner.isActive)
         .toList();
   } catch (e) {
     print('❌ Error parsing cached banners: $e');
     return [];
   }
 }

 static Future<List<BannerDataModel>> _fetchFreshBanners(
     SharedPreferences prefs) async {
   try {
     final List<dynamic> rawData = await _fetchBannersFromApi();
     final activeBanners = rawData
         .map((item) => BannerDataModel.fromJson(item))
         .where((banner) => banner.isActive)
         .toList();
     if (rawData.isNotEmpty) {
       await _cacheBanners(prefs, rawData);
     }
     return activeBanners;
   } catch (e) {
     print('❌ Error in _fetchFreshBanners: $e');
     final cachedBanners = await _getCachedBanners(prefs);
     if (cachedBanners.isNotEmpty) {
       print('🔄 API failed, returning ${cachedBanners.length} cached banners as fallback.');
       return cachedBanners;
     }
     rethrow;
   }
 }

 static Future<void> _cacheBanners(
     SharedPreferences prefs, List<dynamic> rawData) async {
   await prefs.setString(_cacheKeyBanners, json.encode(rawData));
   await prefs.setString(_cacheKeyTimestamp, DateTime.now().toIso8601String());
   print('💾 Successfully cached ${rawData.length} banners.');
 }

 static void _loadFreshDataInBackground() {
   Future.delayed(const Duration(milliseconds: 500), () async {
     try {
       print('🔄 Loading fresh banners in background...');
       final prefs = await SharedPreferences.getInstance();
       await _fetchFreshBanners(prefs);
       print('✅ Banner background refresh completed.');
     } catch (e) {
       print('⚠️ Banner background refresh failed: $e');
     }
   });
 }

 static Future<List<dynamic>> _fetchBannersFromApi() async {
   try {
     final prefs = await SharedPreferences.getInstance();
     final authKey = prefs.getString('result_auth_key') ?? '';
     final response = await https.get(
       Uri.parse('https://dashboard.cpplayers.com/api/v2/getCustomImageSlider'),
       headers: {
         'auth-key': authKey,
         'Content-Type': 'application/json',
         'Accept': 'application/json',
         'domain': 'coretechinfo.com'
       },
     ).timeout(const Duration(seconds: 30));

     print("----------- API Response Details -----------");
     print("✅ slider authKey: ${authKey}");
     print("✅ Status Code: ${response.statusCode}");
     // print("📦 Response Body: ${response.body}"); // Optional: Can be long
     print("------------------------------------------");


     if (response.statusCode == 200) {
       if (response.body.isNotEmpty) {
         final decodedData = json.decode(response.body);
         if (decodedData is List) {
           print("👍 Successfully parsed JSON as a List.");
           return decodedData;
         } else {
           print("⚠️ WARNING: API did not return a JSON List. It returned a ${decodedData.runtimeType}.");
           throw Exception('API response is not a List as expected.');
         }
       } else {
         print("⚠️ WARNING: API returned a 200 OK but with an empty body.");
         return [];
       }
     } else {
       throw Exception('Failed to load banners. Status Code: ${response.statusCode}');
     }
   } catch (e) {
     print("----------- 🛑 API CALL FAILED 🛑 -----------");
     print("❌ Error fetching banners: $e");
     print("-------------------------------------------");
     throw Exception('Failed to load banners: $e');
   }
 }
}

// ✅ Ultra Fast Banner Slider Widget (Simplified State Management)
class BannerSlider extends StatefulWidget {
 final Function(bool)? onFocusChange; // Still useful for parent communication
 final FocusNode focusNode; // Keep this if parent needs to control focus

 const BannerSlider({
   Key? key,
   this.onFocusChange,
   required this.focusNode, // Keep receiving from parent if needed
 }) : super(key: key);

 @override
 _BannerSliderState createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider>
    with SingleTickerProviderStateMixin {
 // State Variables
 List<BannerDataModel> bannerList = [];
 List<NewsItemModel>? _newsItemListCache; // Cache for video player playlist
 bool isLoading = true;
 String errorMessage = '';

 // UI Control
 late PageController _pageController;
 Timer? _timer;
 String? selectedContentId; // To know which banner is currently shown
 bool _isNavigating = false; // Prevent double navigation

 // Focus Node (Managed within this widget)
 // ❗️ Important: Use the focusNode passed from the parent widget
 // final FocusNode _buttonFocusNode = FocusNode(); // Remove this line

 // Animations
 late AnimationController _shimmerController;
 late Animation<double> _shimmerAnimation;

 // Getter for playlist
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
   _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
       CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));
 }

 @override
 void dispose() {
   if (_pageController.hasClients) {
     _pageController.dispose();
   }
   _shimmerController.dispose();
   _timer?.cancel();
   // ❗️ widget.focusNode ko yahan dispose NAHI karna hai, yeh HomeScreen mein hoga.
   super.dispose();
 }

 Future<void> _initializeSlider() async {
   _pageController = PageController();

  //  // Simple listener to trigger rebuilds on focus change for UI updates
  //  // ❗️ Use widget.focusNode instead of _buttonFocusNode
  //  widget.focusNode.addListener(() {
  //    if (mounted) {
  //      setState(() {}); // Update UI based on focus
  //      widget.onFocusChange?.call(widget.focusNode.hasFocus); // Inform parent
  //    }
  //  });

  widget.focusNode.addListener(() {
    if (mounted) {
     setState(() {}); // Update UI based on focus
     widget.onFocusChange?.call(widget.focusNode.hasFocus); // Inform parent

     // ❗️ ADDED: Pause/Resume auto-slide based on focus
     if (widget.focusNode.hasFocus) {
       _timer?.cancel(); // Focus milne par timer pause karein
     } else {
       _startAutoSlide(); // Focus hatne par timer resume karein
     }
    }
  });

   // ❗️ Register widget.focusNode with the provider
   WidgetsBinding.instance.addPostFrameCallback((_) {
     if (mounted) {
       try {
         context.read<FocusProvider>().registerFocusNode('watchNow', widget.focusNode);
         print("✅ watchNow FocusNode registered in FocusProvider.");
       } catch (e) {
         print("❌ Error registering watchNow FocusNode: $e");
       }
     }
   });

   // Fetch initial banner data
   await _fetchBannersWithCache();
 }

 Future<void> _fetchBannersWithCache() async {
   if (!mounted) return;
   setState(() => isLoading = true);
   try {
     final fetchedBanners = await BannerService.getAllBanners();
     if (mounted) {
       _showBannersInstantly(fetchedBanners);
     }
   } catch (e) {
     if (mounted) {
       setState(() {
         errorMessage = 'Failed to load banners: $e';
         bannerList = [];
       });
     }
     print('❌ Error in _fetchBannersWithCache: $e');
   } finally {
     if (mounted) {
       setState(() => isLoading = false);
     }
   }
 }

 void _showBannersInstantly(List<BannerDataModel> banners) {
   if (mounted) {
     setState(() {
       bannerList = banners;
       selectedContentId = banners.isNotEmpty ? banners[0].id.toString() : null;
       errorMessage = '';
       _newsItemListCache = null; // Reset playlist cache
     });
     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted) {
         _startAutoSlide();
         _prefetchImages();
       }
     });
   }
 }

 void _prefetchImages() {
   if (!mounted) return; // Check mounted before using context
   for (var banner in bannerList) {
     if (banner.banner.isNotEmpty) {
       precacheImage(CachedNetworkImageProvider(banner.banner), context)
           .catchError((e, stackTrace) {
         // Silently ignore pre-cache errors or log them minimally
         // print('Warning: Failed to precache image ${banner.banner}. Error: $e');
         return null; // Return null in catchError
       });
     }
   }
 }


 Future<void> refreshData() async {
   await _fetchBannersWithCache();
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.transparent,
     body: _buildBody(),
   );
 }

 Widget _buildBody() {
   if (isLoading) {
     return _buildLoadingWidget();
   }
   if (errorMessage.isNotEmpty && bannerList.isEmpty) {
     return _buildErrorWidget();
   }
   if (bannerList.isEmpty) {
     return _buildEmptyWidget();
   }
   return _buildBannerSlider();
 }


 Widget _buildLoadingWidget() {
   return Center(
     child: Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         SpinKitFadingCircle(color: borderColor ?? Colors.grey, size: 50.0), // Use default if null
         const SizedBox(height: 20),
         Text(
           'Loading banners...',
           style: TextStyle(color: hintColor ?? Colors.grey[600], fontSize: nametextsz ?? 14.0), // Use default if null
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
        Icon(
          Icons.cloud_off,
          color: (hintColor ?? Colors.grey[600])?.withOpacity(0.5), // Use default if null
          size: 50,
        ),
        const SizedBox(height: 20),
        Text(
          'Failed to load banners',
          style: TextStyle(color: hintColor ?? Colors.grey[600], fontSize: nametextsz ?? 14.0), // Use default if null
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
         Text(
           errorMessage, // Show specific error
           style: TextStyle(color: Colors.red[300], fontSize: (nametextsz ?? 14.0) * 0.8), // Use default if null
           textAlign: TextAlign.center,
         ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: refreshData,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Consider using Theme color
            foregroundColor: Colors.white,
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
           color: (hintColor ?? Colors.grey[600])?.withOpacity(0.5), // Use default if null
           size: 50,
         ),
         const SizedBox(height: 20),
         Text(
           'No banners available',
           style: TextStyle(color: hintColor ?? Colors.grey[600], fontSize: nametextsz ?? 14.0), // Use default if null
         ),
         const SizedBox(height: 20),
         ElevatedButton.icon(
           onPressed: refreshData, // Allow refresh even if empty
           icon: const Icon(Icons.refresh),
           label: const Text('Refresh'),
           style: ElevatedButton.styleFrom(
             backgroundColor: Colors.blue, // Consider using Theme color
             foregroundColor: Colors.white,
           ),
         ),
       ],
     ),
   );
 }

 Widget _buildBannerSlider() {
   return Stack(
     children: [
       PageView.builder(
         controller: _pageController,
         itemCount: bannerList.length,
         onPageChanged: (index) {
           if (mounted && index < bannerList.length) { // Add bounds check
             setState(() => selectedContentId = bannerList[index].id.toString());
           }
         },
         itemBuilder: (context, index) {
            if (index >= bannerList.length) return const SizedBox.shrink(); // Bounds check
           final banner = bannerList[index];
           return _buildSimpleBanner(banner);
         },
       ),
       _buildNavigationButton(),
       if (bannerList.length > 1) _buildPageIndicators(),
       _buildStationaryTitle(),
     ],
   );
 }

 Widget _buildStationaryTitle() {
    // Find current banner safely
    BannerDataModel? currentBanner = bannerList.isNotEmpty
        ? bannerList.firstWhere(
            (b) => b.id.toString() == selectedContentId,
            orElse: () => bannerList.first, // Fallback to first if ID not found
          )
        : null;

    // Use screenhgt or provide a default if null
    double effectiveScreenHeight = screenhgt ?? MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Positioned(
          left: 0, right: 0, bottom: 0, height: effectiveScreenHeight * 0.15,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.0)],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        // Optional: Add stationary title text here if needed and currentBanner is not null
        /*
        if (currentBanner != null)
          Positioned(
            left: screenwdt * 0.03,
            right: screenwdt * 0.03,
            bottom: effectiveScreenHeight * 0.03,
            child: AnimatedSwitcher(...)
          )
        */
      ],
    );
 }


 Widget _buildNavigationButton() {
   // ❗️ Use widget.focusNode
   final bool hasFocus = widget.focusNode.hasFocus;
   // Example: Using a fixed focus color or cycling through a predefined list
   final List<Color> focusColors = [ProfessionalColors.accentBlue, ProfessionalColors.accentPurple, ProfessionalColors.accentGreen];
    // Safe index calculation
    int bannerIndex = bannerList.indexWhere((b) => b.id.toString() == selectedContentId);
    if (bannerIndex == -1) bannerIndex = 0; // Default to 0 if not found
    final Color focusColor = bannerList.isNotEmpty ? focusColors[bannerIndex % focusColors.length] : ProfessionalColors.accentBlue; // Default if list empty

    // Use screen dimensions safely with defaults
    double effectiveScreenHeight = screenhgt ?? MediaQuery.of(context).size.height;
    double effectiveScreenWidth = screenwdt ?? MediaQuery.of(context).size.width;
    double effectiveMenuTextSz = menutextsz ?? 16.0; // Example default


   return Positioned(
     top: effectiveScreenHeight * 0.2,
     left: effectiveScreenWidth * 0.03,
     child: Focus(
       // ❗️ Use widget.focusNode
       focusNode: widget.focusNode,
       onKeyEvent: _handleKeyEvent,
       child: GestureDetector(
         onTap: _handleWatchNowTap,
         child: AnimatedContainer(
           duration: const Duration(milliseconds: 200),
           margin: EdgeInsets.all(effectiveScreenWidth * 0.001),
           padding: EdgeInsets.symmetric(
             vertical: effectiveScreenHeight * 0.01,
             horizontal: effectiveScreenWidth * 0.02,
           ),
           decoration: BoxDecoration(
             color: hasFocus ? Colors.black87 : Colors.black.withOpacity(0.6),
             borderRadius: BorderRadius.circular(12),
             border: Border.all(
               color: hasFocus ? focusColor : Colors.white.withOpacity(0.3),
               width: hasFocus ? 3.0 : 1.0,
             ),
             boxShadow: hasFocus
                 ? [BoxShadow(color: focusColor.withOpacity(0.5), blurRadius: 20.0, spreadRadius: 5.0)]
                 : [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10.0, spreadRadius: 2.0)],
           ),
           child: Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               Icon(Icons.chevron_left, color: hasFocus ? focusColor : (hintColor ?? Colors.grey[600]), size: effectiveMenuTextSz * 1.5),
               const SizedBox(width: 8),
               Icon(Icons.chevron_right, color: hasFocus ? focusColor : (hintColor ?? Colors.grey[600]), size: effectiveMenuTextSz * 1.5),
             ],
           ),
         ),
       ),
     ),
   );
 }


 Widget _buildPageIndicators() {
    // Use screen dimensions safely with defaults
    double effectiveScreenHeight = screenhgt ?? MediaQuery.of(context).size.height;
    double effectiveScreenWidth = screenwdt ?? MediaQuery.of(context).size.width;

   return Positioned(
     top: effectiveScreenHeight * 0.15,
     right: effectiveScreenWidth * 0.05,
     child: Row(
       mainAxisAlignment: MainAxisAlignment.center,
       children: bannerList.asMap().entries.map((entry) {
         int index = entry.key;
         // Ensure index is within bounds before accessing bannerList
         if (index >= bannerList.length) return const SizedBox.shrink();

         bool isSelected = selectedContentId == bannerList[index].id.toString();
         return AnimatedContainer(
           duration: const Duration(milliseconds: 300),
           margin: const EdgeInsets.symmetric(horizontal: 4),
           width: isSelected ? 12 : 8,
           height: isSelected ? 12 : 8,
           decoration: BoxDecoration(
             color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
             shape: BoxShape.circle,
             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, spreadRadius: 1)],
           ),
         );
       }).toList(),
     ),
   );
 }

 Widget _buildSimpleBanner(BannerDataModel banner) {
    // ❗️ Use widget.focusNode
   final bool isButtonFocused = widget.focusNode.hasFocus;
   final String uniqueImageUrl = "${banner.banner}?v=${banner.updatedAt}";
   final String uniqueCacheKey = "${banner.id.toString()}_${banner.updatedAt}";

    // Use screen dimensions safely with defaults
    double effectiveScreenHeight = screenhgt ?? MediaQuery.of(context).size.height;
    double effectiveScreenWidth = screenwdt ?? MediaQuery.of(context).size.width;

   return SizedBox(
     width: effectiveScreenWidth,
     height: effectiveScreenHeight,
     child: Stack(
       children: [
         CachedNetworkImage(
           imageUrl: uniqueImageUrl,
           fit: BoxFit.fill,
           placeholder: (context, url) => Image.asset('assets/streamstarting.gif', fit: BoxFit.fill, width: effectiveScreenWidth, height: effectiveScreenHeight), // Ensure placeholder fills
           errorWidget: (context, url, error) => Image.asset('assets/streamstarting.gif', fit: BoxFit.fill, width: effectiveScreenWidth, height: effectiveScreenHeight), // Ensure error widget fills
           cacheKey: uniqueCacheKey,
           fadeInDuration: const Duration(milliseconds: 100),
           placeholderFadeInDuration: Duration.zero,
           // Consider adjusting memCache based on testing
           // memCacheHeight: 400,
           // memCacheWidth: 600,
           useOldImageOnUrlChange: true,
           width: effectiveScreenWidth, // Explicit width
           height: effectiveScreenHeight, // Explicit height
         ),
         if (isButtonFocused)
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
                       stops: const [0.0, 0.5, 1.0],
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

// ✅ ==========================================================
// ✅ [UPDATED] _handleKeyEvent Logic
// ✅ ==========================================================
 KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
   if (event is! KeyDownEvent) return KeyEventResult.ignored;

   // Get provider instance inside the handler
   final focusProvider = context.read<FocusProvider>();

   if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
     if (_pageController.hasClients && _pageController.page != null && _pageController.page! < bannerList.length - 1) {
       _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
       _startAutoSlide();
       return KeyEventResult.handled;
     }
   } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
     if (_pageController.hasClients && _pageController.page != null && _pageController.page! > 0) {
       _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
       _startAutoSlide();
       return KeyEventResult.handled;
     }
   }
   // --- Arrow Up ---
   else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
       // ❗️ CHANGED: Call focusPreviousRow
       context.read<ColorProvider>().resetColor(); // Optional: reset color if needed
      //  focusProvider.focusPreviousRow(); // Ask provider (will do nothing as it's the first row)
      context.read<FocusProvider>().requestFocus('topNavigation');
       return KeyEventResult.handled;
   }
   // --- Arrow Down ---
   else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
     // ❗️ CHANGED: Call focusNextRow
     node.unfocus(); // Unfocus the current banner button
     widget.onFocusChange?.call(false); // Inform parent if needed
     context.read<ColorProvider>().resetColor(); // Optional: reset color
     focusProvider.focusNextRow(); // Ask provider to focus the next visible row
     return KeyEventResult.handled;
   }
   // --- Select/Enter ---
   else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
     _handleWatchNowTap();
     return KeyEventResult.handled;
   }
   return KeyEventResult.ignored;
 }
// ✅ ==========================================================
// ✅ END OF [UPDATED] _handleKeyEvent Logic
// ✅ ==========================================================


 void _handleWatchNowTap() {
   if (selectedContentId != null && bannerList.isNotEmpty) {
     try {
       // Find the banner safely
       final banner = bannerList.firstWhere(
         (b) => b.id.toString() == selectedContentId,
         // Provide a fallback if not found (e.g., the first banner)
         orElse: () => bannerList.first,
       );
       fetchAndPlayVideo(banner, newsItemList);
     } catch (e) {
        // This catch might be redundant if orElse is used, but good for safety
       print("Error finding banner or bannerList is empty: $e");
       // Optionally show a message to the user
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Could not play banner content.'), backgroundColor: Colors.red.shade700),
          );
       }
     }
   } else {
      print("Cannot play: No banner selected or banner list is empty.");
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('No banner selected.'), backgroundColor: Colors.orange.shade700),
          );
       }
   }
 }


//  void _startAutoSlide() {
//    _timer?.cancel();
//    if (bannerList.length > 1) { // Only start if more than one banner
//      _timer = Timer.periodic(const Duration(seconds: 8), (Timer timer) {
//        if (!mounted || !_pageController.hasClients || !_pageController.hasListeners) { // Add hasListeners check
//          timer.cancel();
//          return;
//        }
//         // Check if page is not null before accessing it
//         double? currentPage = _pageController.page;
//         if (currentPage == null) return;

//        int nextPage = (currentPage.round() + 1) % bannerList.length;
//        try { // Add try-catch for page controller operations
//           _pageController.animateToPage(
//              nextPage,
//              duration: const Duration(milliseconds: 300),
//              curve: Curves.easeIn,
//            );
//        } catch (e) {
//           print("Error animating PageController: $e");
//           timer.cancel(); // Stop timer if error occurs
//        }

//      });
//    }
//  }



void _startAutoSlide() {
    _timer?.cancel();
    
    // ❗️ YEH BHI ADD KAREIN: Agar button pehle se focused hai toh slide start na karein
    if (widget.focusNode.hasFocus) return; 

    if (bannerList.length > 1) { // Only start if more than one banner
      _timer = Timer.periodic(const Duration(seconds: 8), (Timer timer) {
        
        // ❗️ FIX YAHAN HAI: .hasListeners check ko hata diya gaya hai
        if (!mounted || !_pageController.hasClients) {
          timer.cancel();
          return;
        }
        
        // Check if page is not null before accessing it
        double? currentPage = _pageController.page;
        if (currentPage == null) return;

        int nextPage = (currentPage.round() + 1) % bannerList.length;
        try { // Add try-catch for page controller operations
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        } catch (e) {
          print("Error animating PageController: $e");
          timer.cancel(); // Stop timer if error occurs
        }
      });
    }
  }


 Future<void> fetchAndPlayVideo(BannerDataModel banner, List<NewsItemModel> channelList) async {
   if (_isNavigating) return;
   _isNavigating = true;

   // Show loading dialog (simple version)
    if (mounted) { // Check mount before showing dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
        );
    } else {
        _isNavigating = false; // Ensure navigation flag is reset if not mounted
        return;
    }


   try {
     final responseData = {
       'url': banner.url ?? '',
       'type': banner.contentType.toString(),
       'banner': banner.banner,
       'name': banner.title,
       'stream_type': banner.sourceType ?? '',
     };

     if (mounted) Navigator.of(context, rootNavigator: true).pop(); // Close loader

     if (mounted) {
       // Determine liveStatus based on your logic (e.g., contentType or sourceType)
       bool isLive = banner.contentType == 0; // Example: Assuming 0 means live channel

       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (context) => VideoScreen(
             videoUrl: responseData['url']!,
             bannerImageUrl: responseData['banner']!,
             channelList: channelList, // Pass the playlist
             videoId: banner.id,
             name: responseData['name']!,
             liveStatus: isLive, // Use determined status
             updatedAt: banner.updatedAt,
             source: 'isBannerSlider',
           ),
         ),
       );
     }
   } catch (e) {
     if (mounted) Navigator.of(context, rootNavigator: true).pop(); // Close loader
     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Failed to load video: $e'), backgroundColor: Colors.red.shade700),
       );
     }
   } finally {
     // Add small delay before resetting navigation flag to prevent rapid re-entry issues
     Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) { // Check mount again before setting state
           _isNavigating = false;
        }
     });

   }
 }

} // End of _BannerSliderState


// ✅ Professional Colors (Keep this)
// ✅ Animation Timing (Keep this)