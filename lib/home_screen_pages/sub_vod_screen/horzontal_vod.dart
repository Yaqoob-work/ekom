

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/horizontal_list_details_page.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
import 'dart:math' as math;
import 'package:mobi_tv_entertainment/home_screen_pages/tv_show/tv_show_second_page.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

// ✅ Professional Color Palette (same as WebSeries)
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




// ✅ Professional Animation Durations
class AnimationTiming {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration focus = Duration(milliseconds: 300);
  static const Duration scroll = Duration(milliseconds: 800);
}

// ✅ TV Show Model (same structure)
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
    );
  }
}


// Updated displayImage function with SVG support and better error handling
Widget displayImage(
  String imageUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.fill,
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

// 🚀 Enhanced Vod Service with Caching (WebSeries Style)
class HorizontalVodService {
  // Cache keys
  static const String _cacheKeyHorizontalVod = 'cached_horizontal_vod';
  static const String _cacheKeyTimestamp = 'cached_horizontal_vod_timestamp';
  static const String _cacheKeyAuthKey = 'auth_key';
  
  // Cache duration (in milliseconds) - 1 hour
  static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour
  
  /// Main method to get all Vod with caching
  static Future<List<HorizontalVodModel>> getAllHorizontalVod({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if we should use cache
      if (!forceRefresh && await _shouldUseCache(prefs)) {
        print('📦 Loading Vod from cache...');
        final cachedHorizontalVod = await _getCachedHorizontalVod(prefs);
        if (cachedHorizontalVod.isNotEmpty) {
          print('✅ Successfully loaded ${cachedHorizontalVod.length} Vod from cache');
          
          // Load fresh data in background (without waiting)
          _loadFreshDataInBackground();
          
          return cachedHorizontalVod;
        }
      }
      
      // Load fresh data if no cache or force refresh
      print('🌐 Loading fresh Vod from API...');
      return await _fetchFreshHorizontalVod(prefs);
      
    } catch (e) {
      print('❌ Error in getAllHorizontalVod: $e');
      
      // Try to return cached data as fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedHorizontalVod = await _getCachedHorizontalVod(prefs);
        if (cachedHorizontalVod.isNotEmpty) {
          print('🔄 Returning cached data as fallback');
          return cachedHorizontalVod;
        }
      } catch (cacheError) {
        print('❌ Cache fallback also failed: $cacheError');
      }
      
      throw Exception('Failed to load Vod: $e');
    }
  }
  
  /// Check if cached data is still valid
  static Future<bool> _shouldUseCache(SharedPreferences prefs) async {
    try {
      final timestampStr = prefs.getString(_cacheKeyTimestamp);
      if (timestampStr == null) return false;
      
      final cachedTimestamp = int.tryParse(timestampStr);
      if (cachedTimestamp == null) return false;
      
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      final cacheAge = currentTimestamp - cachedTimestamp;
      
      final isValid = cacheAge < _cacheDurationMs;
      
      if (isValid) {
        final ageMinutes = (cacheAge / (1000 * 60)).round();
        print('📦 Vod Cache is valid (${ageMinutes} minutes old)');
      } else {
        final ageMinutes = (cacheAge / (1000 * 60)).round();
        print('⏰ Vod Cache expired (${ageMinutes} minutes old)');
      }
      
      return isValid;
    } catch (e) {
      print('❌ Error checking Vod cache validity: $e');
      return false;
    }
  }
  
  /// Get Vod from cache
  static Future<List<HorizontalVodModel>> _getCachedHorizontalVod(SharedPreferences prefs) async {
    try {
      final cachedData = prefs.getString(_cacheKeyHorizontalVod);
      if (cachedData == null || cachedData.isEmpty) {
        print('📦 No cached Vod data found');
        return [];
      }
      
      final List<dynamic> jsonData = json.decode(cachedData);
      final HorizontalVod = jsonData
          .map((json) => HorizontalVodModel.fromJson(json as Map<String, dynamic>))
          .where((show) => show.status == 1) // Filter active shows
          .toList();
      
      print('📦 Successfully loaded ${HorizontalVod.length} Vod from cache');
      return HorizontalVod;
    } catch (e) {
      print('❌ Error loading cached Vod: $e');
      return [];
    }
  }
  
  /// Fetch fresh Vod from API and cache them
  static Future<List<HorizontalVodModel>> _fetchFreshHorizontalVod(SharedPreferences prefs) async {
    try {
      String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';
      
      final response = await http.get(
        Uri.parse('https://acomtv.coretechinfo.com/public/api/getNetworks'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        
        final allHorizontalVod = jsonData
            .map((json) => HorizontalVodModel.fromJson(json as Map<String, dynamic>))
            .toList();
            
        // Filter only active shows (status = 1)
        final activeHorizontalVod = allHorizontalVod.where((show) => show.status == 1).toList();
        
        // Cache the fresh data (save all shows, but return only active ones)
        await _cacheHorizontalVod(prefs, jsonData);
        
        print('✅ Successfully loaded ${activeHorizontalVod.length} active Vod from API (from ${allHorizontalVod.length} total)');
        return activeHorizontalVod;
        
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error fetching fresh Vod: $e');
      rethrow;
    }
  }
  
  /// Cache Vod data
  static Future<void> _cacheHorizontalVod(SharedPreferences prefs, List<dynamic> HorizontalVodData) async {
    try {
      final jsonString = json.encode(HorizontalVodData);
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Save Vod data and timestamp
      await Future.wait([
        prefs.setString(_cacheKeyHorizontalVod, jsonString),
        prefs.setString(_cacheKeyTimestamp, currentTimestamp),
      ]);
      
      print('💾 Successfully cached ${HorizontalVodData.length} Vod');
    } catch (e) {
      print('❌ Error caching Vod: $e');
    }
  }
  
  /// Load fresh data in background without blocking UI
  static void _loadFreshDataInBackground() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        print('🔄 Loading fresh Vod data in background...');
        final prefs = await SharedPreferences.getInstance();
        await _fetchFreshHorizontalVod(prefs);
        print('✅ Vod background refresh completed');
      } catch (e) {
        print('⚠️ Vod background refresh failed: $e');
      }
    });
  }
  
  /// Clear all cached data
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_cacheKeyHorizontalVod),
        prefs.remove(_cacheKeyTimestamp),
      ]);
      print('🗑️ Vod cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing Vod cache: $e');
    }
  }
  
  /// Get cache info for debugging
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString(_cacheKeyTimestamp);
      final cachedData = prefs.getString(_cacheKeyHorizontalVod);
      
      if (timestampStr == null || cachedData == null) {
        return {
          'hasCachedData': false,
          'cacheAge': 0,
          'cachedHorizontalVodCount': 0,
          'cacheSize': 0,
        };
      }
      
      final cachedTimestamp = int.tryParse(timestampStr) ?? 0;
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      final cacheAge = currentTimestamp - cachedTimestamp;
      final cacheAgeMinutes = (cacheAge / (1000 * 60)).round();
      
      final List<dynamic> jsonData = json.decode(cachedData);
      final cacheSizeKB = (cachedData.length / 1024).round();
      
      return {
        'hasCachedData': true,
        'cacheAge': cacheAgeMinutes,
        'cachedHorizontalVodCount': jsonData.length,
        'cacheSize': cacheSizeKB,
        'isValid': cacheAge < _cacheDurationMs,
      };
    } catch (e) {
      print('❌ Error getting Vod cache info: $e');
      return {
        'hasCachedData': false,
        'cacheAge': 0,
        'cachedHorizontalVodCount': 0,
        'cacheSize': 0,
        'error': e.toString(),
      };
    }
  }
  
  /// Force refresh data (bypass cache)
  static Future<List<HorizontalVodModel>> forceRefresh() async {
    print('🔄 Force refreshing Vod data...');
    return await getAllHorizontalVod(forceRefresh: true);
  }
}

// 🚀 Enhanced HorzontalVod with Caching (WebSeries Style)
class HorzontalVod extends StatefulWidget {
  @override
  _HorzontalVodState createState() =>
      _HorzontalVodState();
}

class _HorzontalVodState
    extends State<HorzontalVod>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  List<HorizontalVodModel> HorizontalVodList = [];
  bool isLoading = true;
  int focusedIndex = -1;
  final int maxHorizontalItems = 7;
  Color _currentAccentColor = ProfessionalColors.accentGreen;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  Map<String, FocusNode> HorizontalVodFocusNodes = {};
  FocusNode? _viewAllFocusNode;
  FocusNode? _firstHorizontalVodFocusNode;
  bool _hasReceivedFocusFromWebSeries = false;

  late ScrollController _scrollController;
  final double _itemWidth = 156.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
    _initializeFocusNodes();
    
    // 🚀 Use enhanced caching service
    fetchHorizontalVodWithCache();
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

  void _initializeFocusNodes() {
    _viewAllFocusNode = FocusNode();
    print('✅ Vod focus nodes initialized');
  }

  // void _scrollToPosition(int index) {
  //   if (index < HorizontalVodList.length && index < maxHorizontalItems) {
  //     String HorizontalVodId = HorizontalVodList[index].id.toString();
  //     if (HorizontalVodFocusNodes.containsKey(HorizontalVodId)) {
  //       final focusNode = HorizontalVodFocusNodes[HorizontalVodId]!;
        
  //       Scrollable.ensureVisible(
  //         focusNode.context!,
  //         duration: AnimationTiming.scroll,
  //         curve: Curves.linear,
  //         alignment: 0.03,
  //         alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
  //       );
        
  //       print('🎯 Scrollable.ensureVisible for index $index: ${HorizontalVodList[index].name}');
  //     }
  //   } else if (index == maxHorizontalItems && _viewAllFocusNode != null) {
  //     Scrollable.ensureVisible(
  //       _viewAllFocusNode!.context!,
  //       duration: AnimationTiming.scroll,
  //       curve: Curves.linear,
  //       alignment: 0.2,
  //       alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
  //     );
      
  //     print('🎯 Scrollable.ensureVisible for ViewAll button');
  //   }
  // }



  // File: sub_vod.dart
// Inside the _HorzontalVodState class

void _scrollToPosition(int index) {
  // Ensure the controller has clients before using it
  if (!_scrollController.hasClients) return;

  // The item's width (156) + horizontal margin (6 + 6 = 12)
  final double itemTotalWidth = _itemWidth + 12; 
  final double targetOffset = index * itemTotalWidth;

  _scrollController.animateTo(
    // Clamp the value to ensure it doesn't go beyond the max scroll extent
    targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
    duration: AnimationTiming.scroll,
    curve: Curves.easeOutCubic, // A smoother curve than linear
  );
  
  print('🎯 Horizontal scroll to index $index: ${HorizontalVodList[index].name}');
}



// void _scrollToPosition(int index) {
//   if (index < HorizontalVodList.length && index < maxHorizontalItems) {
//     // Calculate horizontal offset for the focused item
//     final double targetOffset = index * (_itemWidth + 40); // item width + margin
    
//     // Animate to specific horizontal position
//     _scrollController.animateTo(
//       targetOffset,
//       duration: AnimationTiming.scroll,
//       curve: Curves.linear,
//     );
    
//     print('🎯 Horizontal scroll to index $index: ${HorizontalVodList[index].name}');
//   } else if (index == maxHorizontalItems && _viewAllFocusNode != null) {
//     // Scroll to ViewAll button position
//     final double viewAllOffset = maxHorizontalItems * (_itemWidth + 40);
    
//     _scrollController.animateTo(
//       viewAllOffset,
//       duration: AnimationTiming.scroll,
//       curve: Curves.linear,
//     );
    
//     print('🎯 Horizontal scroll to ViewAll button');
//   }
// }


  void _setupHorizontalVodFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && HorizontalVodList.isNotEmpty) {
        try {
          final focusProvider = Provider.of<FocusProvider>(context, listen: false);

          final firstHorizontalVodId = HorizontalVodList[0].id.toString();

          if (!HorizontalVodFocusNodes.containsKey(firstHorizontalVodId)) {
            HorizontalVodFocusNodes[firstHorizontalVodId] = FocusNode();
            print('✅ Created focus node for first TV show: $firstHorizontalVodId');
          }

          _firstHorizontalVodFocusNode = HorizontalVodFocusNodes[firstHorizontalVodId];

          _firstHorizontalVodFocusNode!.addListener(() {
            if (_firstHorizontalVodFocusNode!.hasFocus && !_hasReceivedFocusFromWebSeries) {
              _hasReceivedFocusFromWebSeries = true;
              setState(() {
                focusedIndex = 0;
              });
              _scrollToPosition(0);
              print('✅ Vod received focus from webseries and scrolled');
            }
          });

          focusProvider.setFirstHorizontalListNetworksFocusNode(_firstHorizontalVodFocusNode!);
          print('✅ Vod first focus node registered: ${HorizontalVodList[0].name}');

        } catch (e) {
          print('❌ Vod focus provider setup failed: $e');
        }
      }
    });
  }




//   // 🚀 Enhanced fetch method with caching
//   Future<void> fetchHorizontalVodWithCache() async {
//     if (!mounted) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Use cached data first, then fresh data
//       final fetchedHorizontalVod = await HorizontalVodService.getAllHorizontalVod();

//       if (fetchedHorizontalVod.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             HorizontalVodList = fetchedHorizontalVod;
//             isLoading = false;
//           });

//           _createFocusNodesForItems();
//           _setupHorizontalVodFocusProvider();
          
//           // Start animations after data loads
//           _headerAnimationController.forward();
//           _listAnimationController.forward();
          
//           // Debug cache info
//           _debugCacheInfo();
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//       print('Error fetching Vod with cache: $e');
//     }
//   }

//   // 🆕 Debug method to show cache information
//   Future<void> _debugCacheInfo() async {
//     try {
//       final cacheInfo = await HorizontalVodService.getCacheInfo();
//       print('📊 Vod Cache Info: $cacheInfo');
//     } catch (e) {
//       print('❌ Error getting Vod cache info: $e');
//     }
//   }

//   // 🆕 Force refresh Vod
//   Future<void> _forceRefreshHorizontalVod() async {
//     if (!mounted) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Force refresh bypasses cache
//       final fetchedHorizontalVod = await HorizontalVodService.forceRefresh();

//       if (fetchedHorizontalVod.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             HorizontalVodList = fetchedHorizontalVod;
//             isLoading = false;
//           });

//           _createFocusNodesForItems();
//           _setupHorizontalVodFocusProvider();
          
//           _headerAnimationController.forward();
//           _listAnimationController.forward();
          
//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Vod refreshed successfully'),
//               backgroundColor: ProfessionalColors.accentGreen,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           );
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//       print('❌ Error force refreshing Vod: $e');
//     }
//   }

//   void _createFocusNodesForItems() {
//     for (var node in HorizontalVodFocusNodes.values) {
//       try {
//         node.removeListener(() {});
//         node.dispose();
//       } catch (e) {}
//     }
//     HorizontalVodFocusNodes.clear();

//     for (int i = 0; i < HorizontalVodList.length && i < maxHorizontalItems; i++) {
//       String HorizontalVodId = HorizontalVodList[i].id.toString();
//       if (!HorizontalVodFocusNodes.containsKey(HorizontalVodId)) {
//         HorizontalVodFocusNodes[HorizontalVodId] = FocusNode();

//         HorizontalVodFocusNodes[HorizontalVodId]!.addListener(() {
//           if (mounted && HorizontalVodFocusNodes[HorizontalVodId]!.hasFocus) {
//             setState(() {
//               focusedIndex = i;
//               _hasReceivedFocusFromWebSeries = true;
//             });
//             _scrollToPosition(i);
//             print('✅ TV Show $i focused and scrolled: ${HorizontalVodList[i].name}');
//           }
//         });
//       }
//     }
//     print('✅ Created ${HorizontalVodFocusNodes.length} TV show focus nodes with auto-scroll');
//   }

//   void _navigateToHorizontalVodDetails(HorizontalVodModel HorizontalVod) {
//     print('🎬 Navigating to TV Show Details: ${HorizontalVod.name}');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => HorizontalListDetailsPage(
//           tvChannelId: HorizontalVod.id,
//           channelName: HorizontalVod.name,
//           channelLogo: HorizontalVod.logo,
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from TV Show Details');
//       Future.delayed(Duration(milliseconds: 300), () {
//         if (mounted) {
//           int currentIndex = HorizontalVodList.indexWhere((ts) => ts.id == HorizontalVod.id);
//           if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
//             String HorizontalVodId = HorizontalVod.id.toString();
//             if (HorizontalVodFocusNodes.containsKey(HorizontalVodId)) {
//               setState(() {
//                 focusedIndex = currentIndex;
//                 _hasReceivedFocusFromWebSeries = true;
//               });
//               HorizontalVodFocusNodes[HorizontalVodId]!.requestFocus();
//               _scrollToPosition(currentIndex);
//               print('✅ Restored focus to ${HorizontalVod.name}');
//             }
//           }
//         }
//       });
//     });
//   }


  // 🚀 Enhanced fetch method with caching
  Future<void> fetchHorizontalVodWithCache() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Use cached data first, then fresh data
      final fetchedHorizontalVod = await HorizontalVodService.getAllHorizontalVod();

      if (fetchedHorizontalVod.isNotEmpty) {
        if (mounted) {
          setState(() {
            HorizontalVodList = fetchedHorizontalVod;
            isLoading = false;
          });

          _createFocusNodesForItems();
          _setupHorizontalVodFocusProvider();
          
          // Start animations after data loads
          _headerAnimationController.forward();
          _listAnimationController.forward();
          
          // Debug cache info
          _debugCacheInfo();
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching Vod with cache: $e');
    }
  }

  // 🆕 Debug method to show cache information
  Future<void> _debugCacheInfo() async {
    try {
      final cacheInfo = await HorizontalVodService.getCacheInfo();
      print('📊 Vod Cache Info: $cacheInfo');
    } catch (e) {
      print('❌ Error getting Vod cache info: $e');
    }
  }

  // 🆕 Force refresh Vod
  Future<void> _forceRefreshHorizontalVod() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Force refresh bypasses cache
      final fetchedHorizontalVod = await HorizontalVodService.forceRefresh();

      if (fetchedHorizontalVod.isNotEmpty) {
        if (mounted) {
          setState(() {
            HorizontalVodList = fetchedHorizontalVod;
            isLoading = false;
          });

          _createFocusNodesForItems();
          _setupHorizontalVodFocusProvider();
          
          _headerAnimationController.forward();
          _listAnimationController.forward();
          
          // // Show success message
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: const Text('Vod refreshed successfully'),
          //     backgroundColor: ProfessionalColors.accentGreen,
          //     behavior: SnackBarBehavior.floating,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //   ),
          // );
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('❌ Error force refreshing Vod: $e');
    }
  }

  void _createFocusNodesForItems() {
    for (var node in HorizontalVodFocusNodes.values) {
      try {
        node.removeListener(() {});
        node.dispose();
      } catch (e) {}
    }
    HorizontalVodFocusNodes.clear();

    for (int i = 0; i < HorizontalVodList.length && i < maxHorizontalItems; i++) {
      String HorizontalVodId = HorizontalVodList[i].id.toString();
      if (!HorizontalVodFocusNodes.containsKey(HorizontalVodId)) {
        HorizontalVodFocusNodes[HorizontalVodId] = FocusNode();

        HorizontalVodFocusNodes[HorizontalVodId]!.addListener(() {
          if (mounted && HorizontalVodFocusNodes[HorizontalVodId]!.hasFocus) {
            setState(() {
              focusedIndex = i;
              _hasReceivedFocusFromWebSeries = true;
            });
            _scrollToPosition(i);
            print('✅ TV Show $i focused and scrolled: ${HorizontalVodList[i].name}');
          }
        });
      }
    }
    print('✅ Created ${HorizontalVodFocusNodes.length} TV show focus nodes with auto-scroll');
  }

  void _navigateToHorizontalVodDetails(HorizontalVodModel HorizontalVod) {
    print('🎬 Navigating to TV Show Details: ${HorizontalVod.name}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HorizontalListDetailsPage(
          tvChannelId: HorizontalVod.id,
          channelName: HorizontalVod.name,
          channelLogo: HorizontalVod.logo,
        ),
      ),
    ).then((_) {
      print('🔙 Returned from TV Show Details');
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          int currentIndex = HorizontalVodList.indexWhere((show) => show.id == HorizontalVod.id);
          if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
            String HorizontalVodId = HorizontalVod.id.toString();
            if (HorizontalVodFocusNodes.containsKey(HorizontalVodId)) {
              setState(() {
                focusedIndex = currentIndex;
                _hasReceivedFocusFromWebSeries = true;
              });
              HorizontalVodFocusNodes[HorizontalVodId]!.requestFocus();
              _scrollToPosition(currentIndex);
              print('✅ Restored focus to ${HorizontalVod.name}');
            }
          }
        }
      });
    });
  }

  void _navigateToGridPage() {
    print('🎬 Navigating to Vod Grid Page...');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalHorizontalVodGridPage(
          HorizontalVodList: HorizontalVodList,
          title: 'CONTENTS',
        ),
      ),
    ).then((_) {
      print('🔙 Returned from grid page');
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted && _viewAllFocusNode != null) {
          setState(() {
            focusedIndex = maxHorizontalItems;
            _hasReceivedFocusFromWebSeries = true;
          });
          _viewAllFocusNode!.requestFocus();
          _scrollToPosition(maxHorizontalItems);
          print('✅ Focused back to ViewAll button and scrolled');
        }
      });
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   super.build(context);
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final screenHeight = MediaQuery.of(context).size.height;

  //   return Scaffold(
  //     backgroundColor: Colors.transparent,
  //     body: Container(
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topCenter,
  //           end: Alignment.bottomCenter,
  //           colors: [
  //             ProfessionalColors.primaryDark,
  //             ProfessionalColors.surfaceDark.withOpacity(0.5),
  //           ],
  //         ),
  //       ),
  //       child: Column(
  //         children: [
  //           SizedBox(height: screenHeight * 0.02),
  //           _buildProfessionalTitle(screenWidth),
  //           SizedBox(height: screenHeight * 0.01),
  //           Expanded(child: _buildBody(screenWidth, screenHeight)),
  //         ],
  //       ),
  //     ),
  //   );
  // }



  @override
Widget build(BuildContext context) {
  super.build(context);
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  // ✅ ADD: Consumer to listen to color changes (Same as WebSeries)
  return Consumer<ColorProvider>(
    builder: (context, colorProvider, child) {
      final bgColor = colorProvider.isItemFocused
          ? colorProvider.dominantColor.withOpacity(0.1)
          // : const Color.fromARGB(255, 175, 180, 196);
          :ProfessionalColors.primaryDark;

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          // ✅ ENHANCED: Dynamic background gradient based on focused item
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

  // 🚀 Enhanced Title with Cache Status and Refresh Button
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
            Row(
              children: [
                // // 🆕 Refresh Button
                // GestureDetector(
                //   onTap: isLoading ? null : _forceRefreshHorizontalVod,
                //   child: Container(
                //     padding: const EdgeInsets.all(8),
                //     decoration: BoxDecoration(
                //       color: ProfessionalColors.accentGreen.withOpacity(0.2),
                //       borderRadius: BorderRadius.circular(8),
                //       border: Border.all(
                //         color: ProfessionalColors.accentGreen.withOpacity(0.3),
                //         width: 1,
                //       ),
                //     ),
                //     child: isLoading
                //         ? SizedBox(
                //             width: 16,
                //             height: 16,
                //             child: CircularProgressIndicator(
                //               strokeWidth: 2,
                //               valueColor: AlwaysStoppedAnimation<Color>(
                //                 ProfessionalColors.accentGreen,
                //               ),
                //             ),
                //           )
                //         : Icon(
                //             Icons.refresh,
                //             size: 16,
                //             color: ProfessionalColors.accentGreen,
                //           ),
                //   ),
                // ),
                // const SizedBox(width: 12),
                // Vod Count
                if (HorizontalVodList.length > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ProfessionalColors.accentGreen.withOpacity(0.2),
                          ProfessionalColors.accentBlue.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ProfessionalColors.accentGreen.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${HorizontalVodList.length} Shows Available',
                      style: const TextStyle(
                        color: ProfessionalColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(double screenWidth, double screenHeight) {
    if (isLoading) {
      return ProfessionalHorizontalVodLoadingIndicator(
          message: 'Loading Vod...');
    } else if (HorizontalVodList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildHorizontalVodList(screenWidth, screenHeight);
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
            'No Vod Found',
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

  Widget _buildHorizontalVodList(double screenWidth, double screenHeight) {
    bool showViewAll = HorizontalVodList.length > 7;

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
          itemCount: showViewAll ? 8 : HorizontalVodList.length,
          itemBuilder: (context, index) {
            if (showViewAll && index == 7) {
              return Focus(
                focusNode: _viewAllFocusNode,
                // onFocusChange: (hasFocus) {
                //   if (hasFocus && mounted) {
                //     Color viewAllColor = ProfessionalColors.gradientColors[
                //         math.Random().nextInt(ProfessionalColors.gradientColors.length)];

                //     setState(() {
                //       _currentAccentColor = viewAllColor;
                //     });
                //   }
                // },
                onFocusChange: (hasFocus) {
  if (hasFocus && mounted) {
    Color viewAllColor = ProfessionalColors.gradientColors[
        math.Random().nextInt(ProfessionalColors.gradientColors.length)];

    setState(() {
      _currentAccentColor = viewAllColor;
    });

    // ✅ ADD: Update color provider for ViewAll button
    context.read<ColorProvider>().updateColor(viewAllColor, true);
  } else if (mounted) {
    // ✅ ADD: Reset color when ViewAll loses focus
    context.read<ColorProvider>().resetColor();
  }
},
                onKey: (FocusNode node, RawKeyEvent event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                      return KeyEventResult.handled;
                    }
                    
                    
                    
                     else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                      if (HorizontalVodList.isNotEmpty && HorizontalVodList.length > 6) {
                        String HorizontalVodId = HorizontalVodList[6].id.toString();
                        FocusScope.of(context).requestFocus(HorizontalVodFocusNodes[HorizontalVodId]);
                        return KeyEventResult.handled;
                      }
                    } 
                    else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    setState(() {
                      focusedIndex = -1;
                      _hasReceivedFocusFromWebSeries = false;
                    });
                      context.read<ColorProvider>().resetColor();
                    FocusScope.of(context).unfocus();
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) {
                        try {
                          // ✅ NEW: Go to current selected navigation's first channel
                          context.read<FocusProvider>().requestCurrentNavFirstChannelFocus();
                          print('✅ Navigating from HorizontalVod ViewAll to current selected nav first channel');
                        } catch (e) {
                          print('❌ Failed to navigate to current nav first channel from ViewAll: $e');
                        }
                      }
                    });
                    return KeyEventResult.handled;
                  } 
                    else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                      setState(() {
                        focusedIndex = -1;
                        _hasReceivedFocusFromWebSeries = false;
                      });
                        context.read<ColorProvider>().resetColor();
                      FocusScope.of(context).unfocus();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          try {
                            // Navigate to next section after Vod
                            context.read<FocusProvider>().requestFirstMoviesFocus();
                            print('✅ Navigating down from Vod ViewAll');
                          } catch (e) {
                            print('❌ Failed to navigate down: $e');
                          }
                        }
                      });
                      return KeyEventResult.handled;
                    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                               event.logicalKey == LogicalKeyboardKey.select) {
                      print('🎬 ViewAll button pressed - Opening Grid Page...');
                      _navigateToGridPage();
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: GestureDetector(
                  onTap: _navigateToGridPage,
                  child: ProfessionalHorizontalVodViewAllButton(
                    focusNode: _viewAllFocusNode!,
                    onTap: _navigateToGridPage,
                    totalItems: HorizontalVodList.length,
                    itemType: 'CONTENTS',
                  ),
                ),
              );
            }

            var HorizontalVod = HorizontalVodList[index];
            return _buildHorizontalVodItem(HorizontalVod, index, screenWidth, screenHeight);
          },
        ),
      ),
    );
  }

  Widget _buildHorizontalVodItem(HorizontalVodModel HorizontalVod, int index, double screenWidth, double screenHeight) {
    String HorizontalVodId = HorizontalVod.id.toString();

    HorizontalVodFocusNodes.putIfAbsent(
      HorizontalVodId,
      () => FocusNode()
        ..addListener(() {
          if (mounted && HorizontalVodFocusNodes[HorizontalVodId]!.hasFocus) {
            _scrollToPosition(index);
          }
        }),
    );

    return Focus(
      focusNode: HorizontalVodFocusNodes[HorizontalVodId],
      // onFocusChange: (hasFocus) async {
      //   if (hasFocus && mounted) {
      //     try {
      //       Color dominantColor = ProfessionalColors.gradientColors[
      //           math.Random().nextInt(ProfessionalColors.gradientColors.length)];

      //       setState(() {
      //         _currentAccentColor = dominantColor;
      //         focusedIndex = index;
      //         _hasReceivedFocusFromWebSeries = true;
      //       });
      //     } catch (e) {
      //       print('Focus change handling failed: $e');
      //     }
      //   }
      // },
      onFocusChange: (hasFocus) async {
  if (hasFocus && mounted) {
    try {
      Color dominantColor = ProfessionalColors.gradientColors[
          math.Random().nextInt(ProfessionalColors.gradientColors.length)];

      setState(() {
        _currentAccentColor = dominantColor;
        focusedIndex = index;
        _hasReceivedFocusFromWebSeries = true;
      });

      // ✅ ADD: Update color provider
      context.read<ColorProvider>().updateColor(dominantColor, true);
    } catch (e) {
      print('Focus change handling failed: $e');
    }
  } else if (mounted) {
    // ✅ ADD: Reset color when focus lost
    context.read<ColorProvider>().resetColor();
  }
},
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          // if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          //   if (index < HorizontalVodList.length - 1 && index != 6) {
          //     String nextHorizontalVodId = HorizontalVodList[index + 1].id.toString();
          //     FocusScope.of(context).requestFocus(HorizontalVodFocusNodes[nextHorizontalVodId]);
          //     return KeyEventResult.handled;
          //   } else if (index == 6 && HorizontalVodList.length > 7) {
          //     FocusScope.of(context).requestFocus(_viewAllFocusNode);
          //     return KeyEventResult.handled;
          //   }
          // } 

          // File: sub_vod.dart
// Inside the onKey handler in _buildHorizontalVodItem

if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
  bool showViewAll = HorizontalVodList.length > maxHorizontalItems;

  // If this is not the last visible logo...
  if (index < maxHorizontalItems - 1 && index < HorizontalVodList.length - 1) {
    String nextHorizontalVodId = HorizontalVodList[index + 1].id.toString();
    FocusScope.of(context).requestFocus(HorizontalVodFocusNodes[nextHorizontalVodId]);
    return KeyEventResult.handled;
  }
  // If this is the last logo and the "View All" button exists, move to it.
  else if (showViewAll && index == maxHorizontalItems - 1) {
      FocusScope.of(context).requestFocus(_viewAllFocusNode);
      return KeyEventResult.handled;
  }
}
          
          else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              String prevHorizontalVodId = HorizontalVodList[index - 1].id.toString();
              FocusScope.of(context).requestFocus(HorizontalVodFocusNodes[prevHorizontalVodId]);
              return KeyEventResult.handled;
            }
          } 
        else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          setState(() {
            focusedIndex = -1;
            _hasReceivedFocusFromWebSeries = false;
          });
          
            context.read<ColorProvider>().resetColor();
          FocusScope.of(context).unfocus();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              try {
                // ✅ NEW: Go to current selected navigation's first channel instead of webseries
                context.read<FocusProvider>().requestCurrentNavFirstChannelFocus();
                print('✅ Navigating from HorizontalVod to current selected nav first channel');
              } catch (e) {
                print('❌ Failed to navigate to current nav first channel: $e');
              }
            }
          });
          return KeyEventResult.handled;
        } 
          else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            setState(() {
              focusedIndex = -1;
              _hasReceivedFocusFromWebSeries = false;
            });
              context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                try {
                  // Navigate to next section
                  context.read<FocusProvider>().requestFirstMoviesFocus();
                  print('✅ Navigating down from Vod');
                } catch (e) {
                  print('❌ Failed to navigate down: $e');
                }
              }
            });
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                     event.logicalKey == LogicalKeyboardKey.select) {
            print('🎬 Enter pressed on ${HorizontalVod.name} - Opening Details Page...');
            _navigateToHorizontalVodDetails(HorizontalVod);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _navigateToHorizontalVodDetails(HorizontalVod),
        child: ProfessionalHorizontalVodCard(
          HorizontalVod: HorizontalVod,
          focusNode: HorizontalVodFocusNodes[HorizontalVodId]!,
          onTap: () => _navigateToHorizontalVodDetails(HorizontalVod),
          // onColorChange: (color) {
          //   setState(() {
          //     _currentAccentColor = color;
          //   });
          // },
          onColorChange: (color) {
  setState(() {
    _currentAccentColor = color;
  });
  // ✅ ADD: Update color provider when card changes color
  context.read<ColorProvider>().updateColor(color, true);
},
          index: index,
          categoryTitle: 'CONTENTS',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();

    for (var entry in HorizontalVodFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
      } catch (e) {}
    }
    HorizontalVodFocusNodes.clear();

    try {
      _viewAllFocusNode?.removeListener(() {});
      _viewAllFocusNode?.dispose();
    } catch (e) {}

    try {
      _scrollController.dispose();
    } catch (e) {}

    super.dispose();
  }
}

// 🚀 Enhanced Cache Management Utility Class
class CacheManager {
  /// Clear all app caches
  static Future<void> clearAllCaches() async {
    try {
      await Future.wait([
        HorizontalVodService.clearCache(),
        // Add other service cache clears here
        // WebSeriesService.clearCache(),
        // MoviesService.clearCache(),
      ]);
      print('🗑️ All caches cleared successfully');
    } catch (e) {
      print('❌ Error clearing all caches: $e');
    }
  }

  /// Get comprehensive cache info for all services
  static Future<Map<String, dynamic>> getAllCacheInfo() async {
    try {
      final HorizontalVodCacheInfo = await HorizontalVodService.getCacheInfo();
      // Add other service cache info here
      // final webSeriesCacheInfo = await WebSeriesService.getCacheInfo();
      // final moviesCacheInfo = await MoviesService.getCacheInfo();

      return {
        'HorizontalVod': HorizontalVodCacheInfo,
        // 'webSeries': webSeriesCacheInfo,
        // 'movies': moviesCacheInfo,
        'totalCacheSize': _calculateTotalCacheSize([
          HorizontalVodCacheInfo,
          // webSeriesCacheInfo,
          // moviesCacheInfo,
        ]),
      };
    } catch (e) {
      print('❌ Error getting all cache info: $e');
      return {
        'error': e.toString(),
        'HorizontalVod': {'hasCachedData': false},
      };
    }
  }

  static int _calculateTotalCacheSize(List<Map<String, dynamic>> cacheInfos) {
    int totalSize = 0;
    for (final info in cacheInfos) {
      if (info['cacheSize'] is int) {
        totalSize += info['cacheSize'] as int;
      }
    }
    return totalSize;
  }

  /// Force refresh all data
  static Future<void> forceRefreshAllData() async {
    try {
      await Future.wait([
        HorizontalVodService.forceRefresh(),
        // Add other service force refreshes here
        // WebSeriesService.forceRefresh(),
        // MoviesService.forceRefresh(),
      ]);
      print('🔄 All data force refreshed successfully');
    } catch (e) {
      print('❌ Error force refreshing all data: $e');
    }
  }
}

// ✅ Professional TV Show Card (same as WebSeries style)
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
  _ProfessionalHorizontalVodCardState createState() => _ProfessionalHorizontalVodCardState();
}

class _ProfessionalHorizontalVodCardState extends State<ProfessionalHorizontalVodCard>
    with TickerProviderStateMixin {
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
    return Container(
      width: double.infinity,
      height: posterHeight,
      child: widget.HorizontalVod.logo != null && widget.HorizontalVod.logo!.isNotEmpty
          ? 
          // Image.network(
          //     widget.HorizontalVod.logo!,
          //     fit: BoxFit.cover,
          //     loadingBuilder: (context, child, loadingProgress) {
          //       if (loadingProgress == null) return child;
          //       return _buildImagePlaceholder(posterHeight);
          //     },
          //     errorBuilder: (context, error, stackTrace) =>
          //         _buildImagePlaceholder(posterHeight),
          //   )
             displayImage(
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
          Text(
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
                stops: [0.0, 0.5, 1.0],
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
      } else if (widget.HorizontalVod.genres!.toLowerCase().contains('sports')) {
        genre = 'SPORTS';
        badgeColor = ProfessionalColors.accentOrange;
      } else if (widget.HorizontalVod.genres!.toLowerCase().contains('entertainment')) {
        genre = 'ENTERTAINMENT';
        badgeColor = ProfessionalColors.accentPink;
      } else if (widget.HorizontalVod.genres!.toLowerCase().contains('documentary')) {
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

    return Container(
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




// ✅ Professional View All Button (same as WebSeries)
class ProfessionalHorizontalVodViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int totalItems;
  final String itemType;

  const ProfessionalHorizontalVodViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
    required this.totalItems,
    this.itemType = 'CONTENTS',
  }) : super(key: key);

  @override
  _ProfessionalHorizontalVodViewAllButtonState createState() =>
      _ProfessionalHorizontalVodViewAllButtonState();
}

class _ProfessionalHorizontalVodViewAllButtonState extends State<ProfessionalHorizontalVodViewAllButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  bool _isFocused = false;
  Color _currentColor = ProfessionalColors.accentGreen;

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
      width: bannerwdt,
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
                    height: _isFocused ? focussedBannerhgt : bannerhgt,
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
                  Icons.live_tv_rounded,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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

class _ProfessionalHorizontalVodLoadingIndicatorState extends State<ProfessionalHorizontalVodLoadingIndicator>
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




// // ✅ Professional Vod Grid Page
// class ProfessionalHorizontalVodGridPage extends StatefulWidget {
//   final List<HorizontalVodModel> HorizontalVodList;
//   final String title;

//   const ProfessionalHorizontalVodGridPage({
//     Key? key,
//     required this.HorizontalVodList,
//     this.title = 'All Vod',
//   }) : super(key: key);

//   @override
//   _ProfessionalHorizontalVodGridPageState createState() => _ProfessionalHorizontalVodGridPageState();
// }

// class _ProfessionalHorizontalVodGridPageState extends State<ProfessionalHorizontalVodGridPage>
//     with TickerProviderStateMixin {
//   int gridFocusedIndex = 0;
//   final int columnsCount = 6;
//   Map<int, FocusNode> gridFocusNodes = {};
//   late ScrollController _scrollController;

//   // Animation Controllers
//   late AnimationController _fadeController;
//   late AnimationController _staggerController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _createGridFocusNodes();
//     _initializeAnimations();
//     _startStaggeredAnimation();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusFirstGridItem();
//     });
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

//   void _createGridFocusNodes() {
//     for (int i = 0; i < widget.HorizontalVodList.length; i++) {
//       gridFocusNodes[i] = FocusNode();
//       gridFocusNodes[i]!.addListener(() {
//         if (gridFocusNodes[i]!.hasFocus) {
//           _ensureItemVisible(i);
//         }
//       });
//     }
//   }

//   void _focusFirstGridItem() {
//     if (gridFocusNodes.containsKey(0)) {
//       setState(() {
//         gridFocusedIndex = 0;
//       });
//       gridFocusNodes[0]!.requestFocus();
//     }
//   }

//   // void _ensureItemVisible(int index) {
//   //   if (_scrollController.hasClients) {
//   //     final int row = index ~/ columnsCount;
//   //     final double itemHeight = bannerhgt;
//   //     final double targetOffset = row * itemHeight;

//   //     _scrollController.animateTo(
//   //       targetOffset,
//   //       duration: Duration(milliseconds: 1000),
//   //       curve: Curves.linear,
//   //     );
//   //   }
//   // }


// // ✅ SOLUTION: Smooth और responsive scrolling
// void _ensureItemVisible(int index) {
//   if (_scrollController.hasClients) {
//     final int row = index ~/ columnsCount;
//     final double itemHeight = bannerhgt + 15; // Include spacing
//     final double currentOffset = _scrollController.offset;
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double visibleArea = screenHeight - bannerhgt; // Account for header/padding
    
//     // Calculate target position
//     final double itemTopPosition = row * itemHeight;
//     final double itemBottomPosition = itemTopPosition + itemHeight;
    
//     // Only scroll if item is not fully visible
//     if (itemTopPosition < currentOffset || itemBottomPosition > currentOffset + visibleArea) {
//       double targetOffset;
      
//       // Determine scroll direction and target
//       if (itemTopPosition < currentOffset) {
//         // Scroll up - align item to top with small margin
//         targetOffset = itemTopPosition - 20;
//       } else {
//         // Scroll down - align item to bottom of visible area
//         targetOffset = itemBottomPosition - visibleArea + 20;
//       }
      
//       // Ensure target is within bounds
//       targetOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
      
//       // Smooth animation with better curve
//       _scrollController.animateTo(
//         targetOffset,
//         duration: const Duration(milliseconds: 400), // ✅ Faster response
//         curve: Curves.easeOutCubic, // ✅ Smooth curve
//       );
//     }
//   }
// }


//   void _navigateGrid(LogicalKeyboardKey key) {
//     int newIndex = gridFocusedIndex;
//     final int totalItems = widget.HorizontalVodList.length;
//     final int currentRow = gridFocusedIndex ~/ columnsCount;
//     final int currentCol = gridFocusedIndex % columnsCount;

//     switch (key) {
//       case LogicalKeyboardKey.arrowRight:
//         if (gridFocusedIndex < totalItems - 1) {
//           newIndex = gridFocusedIndex + 1;
//         }
//         break;

//       case LogicalKeyboardKey.arrowLeft:
//         if (gridFocusedIndex > 0) {
//           newIndex = gridFocusedIndex - 1;
//         }
//         break;

//       case LogicalKeyboardKey.arrowDown:
//         final int nextRowIndex = (currentRow + 1) * columnsCount + currentCol;
//         if (nextRowIndex < totalItems) {
//           newIndex = nextRowIndex;
//         }
//         break;

//       case LogicalKeyboardKey.arrowUp:
//         if (currentRow > 0) {
//           final int prevRowIndex = (currentRow - 1) * columnsCount + currentCol;
//           newIndex = prevRowIndex;
//         }
//         break;
//     }

//     if (newIndex != gridFocusedIndex && newIndex >= 0 && newIndex < totalItems) {
//       setState(() {
//         gridFocusedIndex = newIndex;
//       });
//       gridFocusNodes[newIndex]!.requestFocus();
//     }
//   }



//     void _navigateToHorizontalVodDetails(HorizontalVodModel HorizontalVod, int index) {
//     print('🎬 Grid: Navigating to TV Show Details: ${HorizontalVod.name}');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => HorizontalListDetailsPage(
//           tvChannelId: HorizontalVod.id,
//           channelName: HorizontalVod.name,
//           channelLogo: HorizontalVod.logo,
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from TV Show Details to Grid');
//       Future.delayed(Duration(milliseconds: 300), () {
//         if (mounted && gridFocusNodes.containsKey(index)) {
//           setState(() {
//             gridFocusedIndex = index;
//           });
//           gridFocusNodes[index]!.requestFocus();
//           print('✅ Restored grid focus to index $index');
//         }
//       });
//     });
//   }

//   // void _navigateToHorizontalVodDetails(HorizontalVodModel HorizontalVod, int index) {
//   //   print('🎬 Grid: Navigating to TV Show Details: ${HorizontalVod.name}');

//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => HorizontalVodDetailsPage(
//   //         tvChannelId: HorizontalVod.id,
//   //         channelName: HorizontalVod.name,
//   //         channelLogo: HorizontalVod.logo,
//   //       ),
//   //     ),
//   //   ).then((_) {
//   //     print('🔙 Returned from TV Show Details to Grid');
//   //     Future.delayed(Duration(milliseconds: 300), () {
//   //       if (mounted && gridFocusNodes.containsKey(index)) {
//   //         setState(() {
//   //           gridFocusedIndex = index;
//   //         });
//   //         gridFocusNodes[index]!.requestFocus();
//   //         print('✅ Restored grid focus to index $index');
//   //       }
//   //     });
//   //   });
//   // }

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
//                   child: _buildGridView(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfessionalAppBar() {
//     return Container(
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 20,
//         left: 40,
//         right: 40,
//         bottom: 0,
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
//                   ProfessionalColors.accentGreen.withOpacity(0.2),
//                   ProfessionalColors.accentBlue.withOpacity(0.2),
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
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ShaderMask(
//                   shaderCallback: (bounds) => const LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentGreen,
//                       ProfessionalColors.accentBlue,
//                     ],
//                   ).createShader(bounds),
//                   child: Text(
//                     widget.title,
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
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         ProfessionalColors.accentGreen.withOpacity(0.2),
//                         ProfessionalColors.accentBlue.withOpacity(0.1),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(
//                       color: ProfessionalColors.accentGreen.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Text(
//                     '${widget.HorizontalVodList.length} Vod Available',
//                     style: const TextStyle(
//                       color: ProfessionalColors.accentGreen,
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

//   Widget _buildGridView() {
//     if (widget.HorizontalVodList.isEmpty) {
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
//                     ProfessionalColors.accentGreen.withOpacity(0.2),
//                     ProfessionalColors.accentGreen.withOpacity(0.1),
//                   ],
//                 ),
//               ),
//               child: const Icon(
//                 Icons.live_tv_outlined,
//                 size: 40,
//                 color: ProfessionalColors.accentGreen,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No ${widget.title} Found',
//               style: TextStyle(
//                 color: ProfessionalColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Check back later for new shows',
//               style: TextStyle(
//                 color: ProfessionalColors.textSecondary,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Focus(
//       autofocus: true,
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent) {
//           // if (event.logicalKey == LogicalKeyboardKey.escape ||
//           //     event.logicalKey == LogicalKeyboardKey.goBack) {
//           //   Navigator.pop(context);
//           //   return KeyEventResult.handled;
//           // } else
//            if ([
//             LogicalKeyboardKey.arrowUp,
//             LogicalKeyboardKey.arrowDown,
//             LogicalKeyboardKey.arrowLeft,
//             LogicalKeyboardKey.arrowRight,
//           ].contains(event.logicalKey)) {
//             _navigateGrid(event.logicalKey);
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//                      event.logicalKey == LogicalKeyboardKey.select) {
//             if (gridFocusedIndex < widget.HorizontalVodList.length) {
//               _navigateToHorizontalVodDetails(
//                 widget.HorizontalVodList[gridFocusedIndex],
//                 gridFocusedIndex,
//               );
//             }
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: GridView.builder(
//           controller: _scrollController,
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             // crossAxisCount: columnsCount,
//             crossAxisCount: 6,
//             crossAxisSpacing: 15,
//             mainAxisSpacing: 15,
//             childAspectRatio: 1.5,
//           ),
//           itemCount: widget.HorizontalVodList.length,
//           itemBuilder: (context, index) {
//             return AnimatedBuilder(
//               animation: _staggerController,
//               builder: (context, child) {
//                 final delay = (index / widget.HorizontalVodList.length) * 0.5;
//                 final animationValue = Interval(
//                   delay,
//                   delay + 0.5,
//                   curve: Curves.easeOutCubic,
//                 ).transform(_staggerController.value);

//                 return Transform.translate(
//                   offset: Offset(0, 50 * (1 - animationValue)),
//                   child: Opacity(
//                     opacity: animationValue,
//                     child: ProfessionalGridHorizontalVodCard(
//                       HorizontalVod: widget.HorizontalVodList[index],
//                       focusNode: gridFocusNodes[index]!,
//                       onTap: () => _navigateToHorizontalVodDetails(widget.HorizontalVodList[index], index),
//                       index: index,
//                       categoryTitle: widget.title,
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _staggerController.dispose();
//     _scrollController.dispose();
//     for (var node in gridFocusNodes.values) {
//       try {
//         node.dispose();
//       } catch (e) {}
//     }
//     super.dispose();
//   }
// }


// ✅ ENHANCED: Professional Vod Grid Page with Smooth Scrolling

class ProfessionalHorizontalVodGridPage extends StatefulWidget {
  final List<HorizontalVodModel> HorizontalVodList;
  final String title;

  const ProfessionalHorizontalVodGridPage({
    Key? key,
    required this.HorizontalVodList,
    this.title = 'All Vod',
  }) : super(key: key);

  @override
  _ProfessionalHorizontalVodGridPageState createState() => _ProfessionalHorizontalVodGridPageState();
}

class _ProfessionalHorizontalVodGridPageState extends State<ProfessionalHorizontalVodGridPage>
    with TickerProviderStateMixin {
  
  // ✅ Enhanced Focus Management - Similar to ListDetailsPage
  int gridFocusedIndex = 0;
  final int columnsCount = 6;
  Map<String, FocusNode> gridFocusNodes = {}; // Changed to String keys like ListDetailsPage
  late ScrollController _scrollController;
  bool _isLoading = false; // Added loading state

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
    _startStaggeredAnimation();

    // ✅ Initialize focus nodes AFTER widget is built - Similar to ListDetailsPage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGridFocusNodes();
      _focusFirstGridItem();
    });
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

  // ✅ ENHANCED: Professional Focus Nodes Creation - Similar to ListDetailsPage
  void _initializeGridFocusNodes() {
    // Safely dispose existing nodes first
    for (var entry in gridFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
      } catch (e) {
        print('⚠️ Error disposing grid focus node ${entry.key}: $e');
      }
    }

    // Clear the map and create new nodes
    gridFocusNodes.clear();

    // Create focus nodes for all Vod with String keys
    for (int i = 0; i < widget.HorizontalVodList.length; i++) {
      String vodId = widget.HorizontalVodList[i].id.toString();
      gridFocusNodes[vodId] = FocusNode()
        ..addListener(() {
          if (mounted && gridFocusNodes[vodId]!.hasFocus) {
            setState(() {
              gridFocusedIndex = i;
            });
            _scrollToFocusedItem(vodId);
          }
        });
    }

    print('✅ Created ${gridFocusNodes.length} grid focus nodes');
  }

  void _focusFirstGridItem() {
    if (widget.HorizontalVodList.isNotEmpty && gridFocusNodes.isNotEmpty) {
      final firstVodId = widget.HorizontalVodList[0].id.toString();
      if (gridFocusNodes.containsKey(firstVodId)) {
        try {
          setState(() {
            gridFocusedIndex = 0;
          });
          FocusScope.of(context).requestFocus(gridFocusNodes[firstVodId]);
          print('✅ Focus set to first grid item: $firstVodId');
        } catch (e) {
          print('⚠️ Error setting initial grid focus: $e');
        }
      }
    }
  }


  
  // ✅ Fixed scroll to focused item
  void _scrollToFocusedItem(String itemId) {
    if (!mounted) return;

    try {
      final focusNode = gridFocusNodes[itemId];
      if (focusNode != null &&
          focusNode.hasFocus &&
          focusNode.context != null) {
        Scrollable.ensureVisible(
          focusNode.context!,
          alignment: 0.1, // Keep focused item visible
          duration: AnimationTiming.scroll,
          curve: Curves.easeInOutCubic,
        );
      }
    } catch (e) {
      print('⚠️ Error scrolling to focused item: $e');
    }
  }


  // // ✅ ENHANCED: Smooth Scrolling - Same as ListDetailsPage
  // void _scrollToFocusedItem(int index) {
  //   if (!mounted || !_scrollController.hasClients) return;

  //   try {
  //     final int row = index ~/ columnsCount;
  //     final double itemHeight = bannerhgt + 30; // Include spacing
  //     final double currentOffset = _scrollController.offset;
  //     final double screenHeight = MediaQuery.of(context).size.height;
  //     final double visibleArea = screenHeight - 150; // Account for header/padding
      
  //     // Calculate target position
  //     final double itemTopPosition = row * itemHeight;
  //     final double itemBottomPosition = itemTopPosition + itemHeight;
      
  //     // Only scroll if item is not fully visible
  //     if (itemTopPosition < currentOffset || itemBottomPosition > currentOffset + visibleArea) {
  //       double targetOffset;
        
  //       // Determine scroll direction and target
  //       if (itemTopPosition < currentOffset) {
  //         // Scroll up - align item to top with small margin
  //         targetOffset = itemTopPosition - 20;
  //       } else {
  //         // Scroll down - align item to bottom of visible area
  //         targetOffset = itemBottomPosition - visibleArea + 20;
  //       }
        
  //       // Ensure target is within bounds
  //       targetOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
        
  //       // ✅ Smooth animation with better curve - Same as ListDetailsPage
  //       _scrollController.animateTo(
  //         targetOffset,
  //         duration: AnimationTiming.scroll, // 800ms
  //         curve: Curves.easeInOutCubic, // ✅ Smooth curve
  //       );
        
  //       print('🎯 Smooth scroll to row $row (item $index)');
  //     }
  //   } catch (e) {
  //     print('⚠️ Error scrolling to focused item: $e');
  //   }
  // }

  // ✅ ENHANCED: Professional Grid Navigation - Similar to ListDetailsPage arrow key handling
  void _navigateGrid(LogicalKeyboardKey key) {
    if (_isLoading) return; // Prevent navigation during loading

    int newIndex = gridFocusedIndex;
    final int totalItems = widget.HorizontalVodList.length;
    final int currentRow = gridFocusedIndex ~/ columnsCount;
    final int currentCol = gridFocusedIndex % columnsCount;

    switch (key) {
      case LogicalKeyboardKey.arrowRight:
        if (gridFocusedIndex < totalItems - 1) {
          newIndex = gridFocusedIndex + 1;
        }
        break;

      case LogicalKeyboardKey.arrowLeft:
        if (gridFocusedIndex > 0) {
          newIndex = gridFocusedIndex - 1;
        }
        break;

      case LogicalKeyboardKey.arrowDown:
        final int nextRowIndex = (currentRow + 1) * columnsCount + currentCol;
        if (nextRowIndex < totalItems) {
          newIndex = nextRowIndex;
        } else {
          // ✅ If next row doesn't exist, go to last item in the last row
          final int lastRowStartIndex = ((totalItems - 1) ~/ columnsCount) * columnsCount;
          final int targetIndex = lastRowStartIndex + currentCol;
          if (targetIndex < totalItems) {
            newIndex = targetIndex;
          } else {
            newIndex = totalItems - 1; // Go to very last item
          }
        }
        break;

      case LogicalKeyboardKey.arrowUp:
        if (currentRow > 0) {
          final int prevRowIndex = (currentRow - 1) * columnsCount + currentCol;
          newIndex = prevRowIndex;
        }
        break;
    }

    if (newIndex != gridFocusedIndex && newIndex >= 0 && newIndex < totalItems) {
      final newVodId = widget.HorizontalVodList[newIndex].id.toString();
      if (gridFocusNodes.containsKey(newVodId)) {
        setState(() {
          gridFocusedIndex = newIndex;
        });
        FocusScope.of(context).requestFocus(gridFocusNodes[newVodId]);
        
        // ✅ Add haptic feedback for better UX
        HapticFeedback.lightImpact();
        
        print('🎯 Navigated to grid item $newIndex');
      }
    }
  }

  // ✅ ENHANCED: Professional Vod Selection with Loading Handling - Similar to ListDetailsPage
  Future<void> _navigateToHorizontalVodDetails(HorizontalVodModel HorizontalVod, int index) async {
    if (_isLoading || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    print('🎬 Grid: Navigating to TV Show Details: ${HorizontalVod.name}');

    try {
      await Navigator.push(
        context,
        PageRouteBuilder(
          // ✅ Smooth page transition
          pageBuilder: (context, animation, secondaryAnimation) => HorizontalListDetailsPage(
            tvChannelId: HorizontalVod.id,
            channelName: HorizontalVod.name,
            channelLogo: HorizontalVod.logo,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } catch (e) {
      print('❌ Error navigating to details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening ${HorizontalVod.name}'),
            backgroundColor: ProfessionalColors.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // ✅ Restore focus to the same item after returning - Similar to ListDetailsPage
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && index < widget.HorizontalVodList.length) {
            final vodId = widget.HorizontalVodList[index].id.toString();
            if (gridFocusNodes.containsKey(vodId)) {
              setState(() {
                gridFocusedIndex = index;
              });
              FocusScope.of(context).requestFocus(gridFocusNodes[vodId]);
              print('✅ Restored grid focus to index $index');
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Container(
        // Background Gradient
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
        child: Stack(
          children: [
            // ✅ Main Content with proper padding for AppBar
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // ✅ AppBar height placeholder to push content down
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + 80, // AppBar total height
                  ),
                  Expanded(
                    child: _buildGridView(),
                  ),
                ],
              ),
            ),

            // ✅ AppBar positioned on top with proper z-index
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildProfessionalAppBar(),
            ),

            // ✅ Loading Overlay - Always on top
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: ProfessionalHorizontalVodLoadingIndicator(message: 'Opening TV Show...'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalAppBar() {
    return Container(
      // ✅ Enhanced AppBar with proper z-index and blur effect
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ProfessionalColors.primaryDark.withOpacity(0.95), // More opaque
            ProfessionalColors.surfaceDark.withOpacity(0.9),
            ProfessionalColors.surfaceDark.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
        // ✅ Add bottom border for better separation
        border: Border(
          bottom: BorderSide(
            color: ProfessionalColors.accentGreen.withOpacity(0.2),
            width: 1,
          ),
        ),
        // ✅ Add subtle shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          // ✅ Add blur effect for modern look
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 40,
              right: 40,
              bottom: 5, // Add bottom padding
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        ProfessionalColors.accentGreen.withOpacity(0.3),
                        ProfessionalColors.accentBlue.withOpacity(0.3),
                      ],
                    ),
                    // ✅ Add elevation to back button
                    boxShadow: [
                      BoxShadow(
                        color: ProfessionalColors.accentGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ✅ Enhanced title with better shadow
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            ProfessionalColors.accentGreen,
                            ProfessionalColors.accentBlue,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // ✅ Enhanced count badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ProfessionalColors.accentGreen.withOpacity(0.3),
                              ProfessionalColors.accentBlue.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: ProfessionalColors.accentGreen.withOpacity(0.4),
                            width: 1,
                          ),
                          // ✅ Add elevation to count badge
                          boxShadow: [
                            BoxShadow(
                              color: ProfessionalColors.accentGreen.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${widget.HorizontalVodList.length} Shows Available',
                          style: const TextStyle(
                            color: ProfessionalColors.accentGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    if (widget.HorizontalVodList.isEmpty) {
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
            Text(
              'No ${widget.title} Found',
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

    return Focus(
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent && !_isLoading) {
          if ([
            LogicalKeyboardKey.arrowUp,
            LogicalKeyboardKey.arrowDown,
            LogicalKeyboardKey.arrowLeft,
            LogicalKeyboardKey.arrowRight,
          ].contains(event.logicalKey)) {
            _navigateGrid(event.logicalKey);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                     event.logicalKey == LogicalKeyboardKey.select) {
            if (gridFocusedIndex < widget.HorizontalVodList.length) {
              _navigateToHorizontalVodDetails(
                widget.HorizontalVodList[gridFocusedIndex],
                gridFocusedIndex,
              );
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Padding(
        padding: EdgeInsets.all(20),
        child: GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnsCount,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.5,
          ),
          itemCount: widget.HorizontalVodList.length,
          clipBehavior: Clip.none, // ✅ Allow shadows to be visible
          itemBuilder: (context, index) {
            final vod = widget.HorizontalVodList[index];
            String vodId = vod.id.toString();

            // ✅ Safe check for focus node existence - Similar to ListDetailsPage
            if (!gridFocusNodes.containsKey(vodId)) {
              print('⚠️ Grid focus node not found for VOD: $vodId');
              return const SizedBox.shrink();
            }

            return AnimatedBuilder(
              animation: _staggerController,
              builder: (context, child) {
                final delay = (index / widget.HorizontalVodList.length) * 0.5;
                final animationValue = Interval(
                  delay,
                  delay + 0.5,
                  curve: Curves.easeOutCubic,
                ).transform(_staggerController.value);

                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: ProfessionalGridHorizontalVodCard(
                      HorizontalVod: vod,
                      focusNode: gridFocusNodes[vodId]!,
                      onTap: () => _navigateToHorizontalVodDetails(vod, index),
                      index: index,
                      categoryTitle: widget.title,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    _scrollController.dispose();
    
    // ✅ ENHANCED: Safely dispose all focus nodes - Similar to ListDetailsPage
    for (var entry in gridFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
        print('✅ Disposed grid focus node: ${entry.key}');
      } catch (e) {
        print('⚠️ Error disposing grid focus node ${entry.key}: $e');
      }
    }
    gridFocusNodes.clear();
    
    super.dispose();
  }
}

// ✅ Professional Grid TV Show Card
class ProfessionalGridHorizontalVodCard extends StatefulWidget {
  final HorizontalVodModel HorizontalVod;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int index;
  final String categoryTitle;

  const ProfessionalGridHorizontalVodCard({
    Key? key,
    required this.HorizontalVod,
    required this.focusNode,
    required this.onTap,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalGridHorizontalVodCardState createState() => _ProfessionalGridHorizontalVodCardState();
}

class _ProfessionalGridHorizontalVodCardState extends State<ProfessionalGridHorizontalVodCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  Color _dominantColor = ProfessionalColors.accentGreen;
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
                      _buildHorizontalVodImage(),
                      if (_isFocused) _buildFocusBorder(),
                      _buildGradientOverlay(),
                      _buildHorizontalVodInfo(),
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

  Widget _buildHorizontalVodImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: widget.HorizontalVod.logo != null && widget.HorizontalVod.logo!.isNotEmpty
          ? 
          // Image.network(
          //     widget.HorizontalVod.logo!,
          //     fit: BoxFit.cover,
          //     loadingBuilder: (context, child, loadingProgress) {
          //       if (loadingProgress == null) return child;
          //       return _buildImagePlaceholder();
          //     },
          //     errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
          //   )
          displayImage(
        widget.HorizontalVod.logo!,
        fit: BoxFit.cover,
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
              Icons.live_tv_outlined,
              size: 40,
              color: ProfessionalColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
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

  Widget _buildHorizontalVodInfo() {
    final HorizontalVodName = widget.HorizontalVod.name;

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
              HorizontalVodName.toUpperCase(),
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
            if (_isFocused && widget.HorizontalVod.genres != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ProfessionalColors.accentGreen.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ProfessionalColors.accentGreen.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.HorizontalVod.genres!.toUpperCase(),
                      style: const TextStyle(
                        color: ProfessionalColors.accentGreen,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _dominantColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _dominantColor.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'LIVE',
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