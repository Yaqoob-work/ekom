





import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/device_info_provider.dart';
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
    'domain': 'coretechinfo.com',
  };
}

// API Configuration
class ApiConfig {
  static const String PRIMARY_BASE_URL = 'https://acomtv.coretechinfo.com/public/api/v2';
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
          .get(Uri.parse(endpoint), headers: headers,)
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
  // String _deviceName = '';

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
    // _getDeviceInfo();
    _initializeShimmerAnimation();
    _initializeSlider();

  }

// // ✅ Apne purane function ko is naye aur behtar function se replace karein
//   Future<void> _getDeviceInfo() async {
//     final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//     String deviceIdentifier = 'Unknown Device';

//     try {
//       if (Platform.isAndroid) {
//         final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
//         final String brand = androidInfo.brand.toLowerCase();
//         final String model = androidInfo.model;
//         final String device = androidInfo.device; // 'device' name bhi zaroori hai

//         if (brand == 'amazon') {
//           //  AMAZON FIRE STICK CHECK
//           switch (model) {
//             case 'AFTKM':
//               deviceIdentifier = 'AFTKM : Amazon Fire Stick 4K';
//               break;
//             case 'AFTKA':
//               deviceIdentifier = 'AFTKA : Amazon Fire Stick 4K TEST';
//               break;
//             case 'AFTSS':
//               deviceIdentifier = 'AFTSS : Amazon Fire Stick HD';
//               break;
//             // case 'AFTMM':
//             case 'AFTT': // Ye dono HD models ho sakte hain
//               deviceIdentifier = 'AFTT : Amazon Fire Stick ABC';
//               break;
//             default:
//               deviceIdentifier = 'Amazon Fire TV Device';
//           }
//         } else if (brand == 'google') {
//           // GOOGLE CHROMECAST CHECK
//           // Yahan hum 'device' codename (sabrina/boreal) se check kar rahe hain jo zyada aasan hai
//           switch (device) {
//             case 'sabrina':
//               deviceIdentifier = 'sabrina : Chromecast with Google TV (4K)';
//               break;
//             case 'boreal':
//               deviceIdentifier = 'boreal : Chromecast with Google TV (HD)';
//               break;
//             default:
//               deviceIdentifier = 'Google TV Device';
//           }
//         } else {
//           // Baaki sabhi TV's ke liye fallback
//           final bool isTv = androidInfo.systemFeatures.contains('android.software.leanback');
//           String name = model.isEmpty ? '${androidInfo.brand} ${device}' : model;
//           deviceIdentifier = isTv ? '$name (TV)' : name;
//         }
//       } else if (Platform.isIOS) {
//         final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
//         deviceIdentifier = iosInfo.name;
//       }
//     } catch (e) {
//       print('Failed to get device info: $e');
//       deviceIdentifier = 'Error getting name';
//     }

//     if (mounted) {
//       setState(() {
//         _deviceName = deviceIdentifier;
//       });
//     }
//   }

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
      left: screenwdt * 0.03,
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
                  vertical: screenhgt * 0.01,
                  horizontal: screenwdt * 0.02,
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
    final String deviceName = context.watch<DeviceInfoProvider>().deviceName;
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
             // ✨ YEH NAYA CODE HAI DEVICE KA NAAM DIKHANE KE LIYE ✨
          Positioned(
            bottom: 100, // Neeche se 20 pixels upar
            left: 200,   // Baayein se 20 pixels door
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6), // Semi-transparent background
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                deviceName, // Yahan device ka naam show hoga
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Font size aap adjust kar sakte hain
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
            ),
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
              // seasonId: null,
              // isLastPlayedStored: false,
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