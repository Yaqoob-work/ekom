// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel_details_page.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/webseries_details_page.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:math' as math;
// import 'dart:ui';

// // ✅ Professional Color Palette (same as Movies)
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

// // ✅ Professional Animation Durations
// class AnimationTiming {
//   static const Duration ultraFast = Duration(milliseconds: 150);
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration focus = Duration(milliseconds: 300);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// // ✅ Religious Channel Model
// class ReligiousChannelModel {
//   final int id;
//   final String name;
//   final String? logo;
//   final String? description;
//   final String language;
//   final int status;
//   final int relOrder;
//   final String createdAt;
//   final String updatedAt;
//   final String? deletedAt;

//   ReligiousChannelModel({
//     required this.id,
//     required this.name,
//     this.logo,
//     this.description,
//     required this.language,
//     required this.status,
//     required this.relOrder,
//     required this.createdAt,
//     required this.updatedAt,
//     this.deletedAt,
//   });

//   factory ReligiousChannelModel.fromJson(Map<String, dynamic> json) {
//     return ReligiousChannelModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       logo: json['logo'],
//       description: json['description'],
//       language: json['language'] ?? '',
//       status: json['status'] ?? 0,
//       relOrder: json['rel_order'] ?? 0,
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       deletedAt: json['deleted_at'],
//     );
//   }
// }

// // 🚀 Enhanced Religious Channels Service with Caching
// class ReligiousChannelsService {
//   // Cache keys
//   static const String _cacheKeyChannels = 'cached_religious_channels';
//   static const String _cacheKeyTimestamp =
//       'cached_religious_channels_timestamp';
//   static const String _cacheKeyAuthKey = 'result_auth_key';

//   // Cache duration (in milliseconds) - 1 hour
//   static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

//   /// Main method to get all religious channels with caching
//   static Future<List<ReligiousChannelModel>> getAllReligiousChannels(
//       {bool forceRefresh = false}) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // Check if we should use cache
//       if (!forceRefresh && await _shouldUseCache(prefs)) {
//         print('📦 Loading Religious Channels from cache...');
//         final cachedChannels = await _getCachedChannels(prefs);
//         if (cachedChannels.isNotEmpty) {
//           print(
//               '✅ Successfully loaded ${cachedChannels.length} religious channels from cache');

//           // Load fresh data in background (without waiting)
//           _loadFreshDataInBackground();

//           return cachedChannels;
//         }
//       }

//       // Load fresh data if no cache or force refresh
//       print('🌐 Loading fresh Religious Channels from API...');
//       return await _fetchFreshChannels(prefs);
//     } catch (e) {
//       print('❌ Error in getAllReligiousChannels: $e');

//       // Try to return cached data as fallback
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final cachedChannels = await _getCachedChannels(prefs);
//         if (cachedChannels.isNotEmpty) {
//           print('🔄 Returning cached data as fallback');
//           return cachedChannels;
//         }
//       } catch (cacheError) {
//         print('❌ Cache fallback also failed: $cacheError');
//       }

//       throw Exception('Failed to load religious channels: $e');
//     }
//   }

//   /// Check if cached data is still valid
//   static Future<bool> _shouldUseCache(SharedPreferences prefs) async {
//     try {
//       final timestampStr = prefs.getString(_cacheKeyTimestamp);
//       if (timestampStr == null) return false;

//       final cachedTimestamp = int.tryParse(timestampStr);
//       if (cachedTimestamp == null) return false;

//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
//       final cacheAge = currentTimestamp - cachedTimestamp;

//       final isValid = cacheAge < _cacheDurationMs;

//       if (isValid) {
//         final ageMinutes = (cacheAge / (1000 * 60)).round();
//         print(
//             '📦 Religious Channels Cache is valid (${ageMinutes} minutes old)');
//       } else {
//         final ageMinutes = (cacheAge / (1000 * 60)).round();
//         print('⏰ Religious Channels Cache expired (${ageMinutes} minutes old)');
//       }

//       return isValid;
//     } catch (e) {
//       print('❌ Error checking Religious Channels cache validity: $e');
//       return false;
//     }
//   }

//   /// Get religious channels from cache
//   static Future<List<ReligiousChannelModel>> _getCachedChannels(
//       SharedPreferences prefs) async {
//     try {
//       final cachedData = prefs.getString(_cacheKeyChannels);
//       if (cachedData == null || cachedData.isEmpty) {
//         print('📦 No cached Religious Channels data found');
//         return [];
//       }

//       final List<dynamic> jsonData = json.decode(cachedData);
//       final channels = jsonData
//           .map((json) =>
//               ReligiousChannelModel.fromJson(json as Map<String, dynamic>))
//           .toList();

//       print(
//           '📦 Successfully loaded ${channels.length} religious channels from cache');
//       return channels;
//     } catch (e) {
//       print('❌ Error loading cached religious channels: $e');
//       return [];
//     }
//   }

//   /// Fetch fresh religious channels from API and cache them
//   static Future<List<ReligiousChannelModel>> _fetchFreshChannels(
//       SharedPreferences prefs) async {
//     try {
//       String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';

//       final response = await http.get(
//         Uri.parse(
//             'https://dashboard.cpplayers.com/public/api/v2/getReligiousChannels'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': 'coretechinfo.com',
//         },
//       );
//       // .timeout(
//       // const Duration(seconds: 30),
//       // onTimeout: () {
//       // throw Exception('Request timeout');
//       // },
//       // );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);

//         final channels = jsonData
//             .map((json) =>
//                 ReligiousChannelModel.fromJson(json as Map<String, dynamic>))
//             .toList();

//         // Cache the fresh data
//         await _cacheChannels(prefs, jsonData);

//         print(
//             '✅ Successfully loaded ${channels.length} fresh religious channels from API');
//         return channels;
//       } else {
//         throw Exception(
//             'API Error: ${response.statusCode} - ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('❌ Error fetching fresh religious channels: $e');
//       rethrow;
//     }
//   }

//   /// Cache religious channels data
//   static Future<void> _cacheChannels(
//       SharedPreferences prefs, List<dynamic> channelsData) async {
//     try {
//       final jsonString = json.encode(channelsData);
//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

//       // Save channels data and timestamp
//       await Future.wait([
//         prefs.setString(_cacheKeyChannels, jsonString),
//         prefs.setString(_cacheKeyTimestamp, currentTimestamp),
//       ]);

//       print('💾 Successfully cached ${channelsData.length} religious channels');
//     } catch (e) {
//       print('❌ Error caching religious channels: $e');
//     }
//   }

//   /// Load fresh data in background without blocking UI
//   static void _loadFreshDataInBackground() {
//     Future.delayed(const Duration(milliseconds: 500), () async {
//       try {
//         print('🔄 Loading fresh religious channels data in background...');
//         final prefs = await SharedPreferences.getInstance();
//         await _fetchFreshChannels(prefs);
//         print('✅ Religious Channels background refresh completed');
//       } catch (e) {
//         print('⚠️ Religious Channels background refresh failed: $e');
//       }
//     });
//   }

//   /// Clear all cached data
//   static Future<void> clearCache() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await Future.wait([
//         prefs.remove(_cacheKeyChannels),
//         prefs.remove(_cacheKeyTimestamp),
//       ]);
//       print('🗑️ Religious Channels cache cleared successfully');
//     } catch (e) {
//       print('❌ Error clearing Religious Channels cache: $e');
//     }
//   }

//   /// Get cache info for debugging
//   static Future<Map<String, dynamic>> getCacheInfo() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final timestampStr = prefs.getString(_cacheKeyTimestamp);
//       final cachedData = prefs.getString(_cacheKeyChannels);

//       if (timestampStr == null || cachedData == null) {
//         return {
//           'hasCachedData': false,
//           'cacheAge': 0,
//           'cachedChannelsCount': 0,
//           'cacheSize': 0,
//         };
//       }

//       final cachedTimestamp = int.tryParse(timestampStr) ?? 0;
//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
//       final cacheAge = currentTimestamp - cachedTimestamp;
//       final cacheAgeMinutes = (cacheAge / (1000 * 60)).round();

//       final List<dynamic> jsonData = json.decode(cachedData);
//       final cacheSizeKB = (cachedData.length / 1024).round();

//       return {
//         'hasCachedData': true,
//         'cacheAge': cacheAgeMinutes,
//         'cachedChannelsCount': jsonData.length,
//         'cacheSize': cacheSizeKB,
//         'isValid': cacheAge < _cacheDurationMs,
//       };
//     } catch (e) {
//       print('❌ Error getting Religious Channels cache info: $e');
//       return {
//         'hasCachedData': false,
//         'cacheAge': 0,
//         'cachedChannelsCount': 0,
//         'cacheSize': 0,
//         'error': e.toString(),
//       };
//     }
//   }

//   /// Force refresh data (bypass cache)
//   static Future<List<ReligiousChannelModel>> forceRefresh() async {
//     print('🔄 Force refreshing Religious Channels data...');
//     return await getAllReligiousChannels(forceRefresh: true);
//   }
// }

// // 🚀 Enhanced  ManageReligiousShows with Caching
// class ManageReligiousShows extends StatefulWidget {
//   const ManageReligiousShows({super.key});
//   @override
//   _ManageReligiousShowsState createState() => _ManageReligiousShowsState();
// }

// class _ManageReligiousShowsState extends State<ManageReligiousShows>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<ReligiousChannelModel> channelsList = [];
//   bool isLoading = true;
//   int focusedIndex = -1;
//   final int maxHorizontalItems = 7;
//   Color _currentAccentColor = ProfessionalColors.accentOrange;

//   // Animation Controllers
//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   Map<String, FocusNode> channelsFocusNodes = {};
//   FocusNode? _viewAllFocusNode;
//   FocusNode? _firstChannelFocusNode;
//   bool _hasReceivedFocusFromWebSeries = false;

//   late ScrollController _scrollController;
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _initializeAnimations();
//     _initializeFocusNodes();

//     // 🚀 Use enhanced caching service
//     fetchChannelsWithCache();
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

//   void _initializeFocusNodes() {
//     _viewAllFocusNode = FocusNode();
//     print('✅ Religious Channels focus nodes initialized');
//   }

//   void _scrollToPosition(int index) {
//     if (index < channelsList.length && index < maxHorizontalItems) {
//       String channelId = channelsList[index].id.toString();
//       if (channelsFocusNodes.containsKey(channelId)) {
//         final focusNode = channelsFocusNodes[channelId]!;

//         Scrollable.ensureVisible(
//           focusNode.context!,
//           duration: AnimationTiming.scroll,
//           curve: Curves.easeInOutCubic,
//           alignment: 0.03,
//           alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
//         );

//         print(
//             '🎯 Scrollable.ensureVisible for index $index: ${channelsList[index].name}');
//       }
//     } else if (index == maxHorizontalItems && _viewAllFocusNode != null) {
//       Scrollable.ensureVisible(
//         _viewAllFocusNode!.context!,
//         duration: AnimationTiming.scroll,
//         curve: Curves.easeInOutCubic,
//         alignment: 0.2,
//         alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
//       );

//       print('🎯 Scrollable.ensureVisible for ViewAll button');
//     }
//   }

//   void _setupFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && channelsList.isNotEmpty) {
//         try {
//           final focusProvider =
//               Provider.of<FocusProvider>(context, listen: false);

//           final firstChannelId = channelsList[0].id.toString();

//           if (!channelsFocusNodes.containsKey(firstChannelId)) {
//             channelsFocusNodes[firstChannelId] = FocusNode();
//             print(
//                 '✅ Created focus node for first religious channel: $firstChannelId');
//           }

//           _firstChannelFocusNode = channelsFocusNodes[firstChannelId];

//           _firstChannelFocusNode!.addListener(() {
//             if (_firstChannelFocusNode!.hasFocus &&
//                 !_hasReceivedFocusFromWebSeries) {
//               _hasReceivedFocusFromWebSeries = true;
//               setState(() {
//                 focusedIndex = 0;
//               });
//               _scrollToPosition(0);
//               print(
//                   '✅ Religious Channels received focus from web series and scrolled');
//             }
//           });

//           // Register with focus provider using appropriate method
//           focusProvider.registerFocusNode(
//               'religiousChannels', _firstChannelFocusNode!);
//           print(
//               '✅ Religious Channels first focus node registered: ${channelsList[0].name}');
//         } catch (e) {
//           print('❌ Religious Channels focus provider setup failed: $e');
//         }
//       }
//     });
//   }

//   // 🚀 Enhanced fetch method with caching
//   Future<void> fetchChannelsWithCache() async {
//     if (!mounted) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Use cached data first, then fresh data
//       final fetchedChannels =
//           await ReligiousChannelsService.getAllReligiousChannels();

//       if (fetchedChannels.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             channelsList = fetchedChannels;
//             isLoading = false;
//           });

//           _createFocusNodesForItems();
//           _setupFocusProvider();

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
//       print('Error fetching Religious Channels with cache: $e');
//     }
//   }

//   // 🆕 Debug method to show cache information
//   Future<void> _debugCacheInfo() async {
//     try {
//       final cacheInfo = await ReligiousChannelsService.getCacheInfo();
//       print('📊 Religious Channels Cache Info: $cacheInfo');
//     } catch (e) {
//       print('❌ Error getting Religious Channels cache info: $e');
//     }
//   }

//   // 🆕 Force refresh channels
//   Future<void> _forceRefreshChannels() async {
//     if (!mounted) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Force refresh bypasses cache
//       final fetchedChannels = await ReligiousChannelsService.forceRefresh();

//       if (fetchedChannels.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             channelsList = fetchedChannels;
//             isLoading = false;
//           });

//           _createFocusNodesForItems();
//           _setupFocusProvider();

//           _headerAnimationController.forward();
//           _listAnimationController.forward();

//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Religious Channels refreshed successfully'),
//               backgroundColor: ProfessionalColors.accentOrange,
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
//       print('❌ Error force refreshing religious channels: $e');
//     }
//   }

//   void _createFocusNodesForItems() {
//     for (var node in channelsFocusNodes.values) {
//       try {
//         node.removeListener(() {});
//         node.dispose();
//       } catch (e) {}
//     }
//     channelsFocusNodes.clear();

//     for (int i = 0; i < channelsList.length && i < maxHorizontalItems; i++) {
//       String channelId = channelsList[i].id.toString();
//       if (!channelsFocusNodes.containsKey(channelId)) {
//         channelsFocusNodes[channelId] = FocusNode();

//         channelsFocusNodes[channelId]!.addListener(() {
//           if (mounted && channelsFocusNodes[channelId]!.hasFocus) {
//             setState(() {
//               focusedIndex = i;
//               _hasReceivedFocusFromWebSeries = true;
//             });
//             _scrollToPosition(i);
//             print(
//                 '✅ Religious Channel $i focused and scrolled: ${channelsList[i].name}');
//           }
//         });
//       }
//     }
//     print(
//         '✅ Created ${channelsFocusNodes.length} religious channels focus nodes with auto-scroll');
//   }

//   // void _navigateToChannelDetails(ReligiousChannelModel channel) {
//   //   print('📺 Navigating to Religious Channel Details: ${channel.name}');

//   //   // For now, show a dialog with channel info
//   //   // You can replace this with your channel details page
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) => AlertDialog(
//   //       backgroundColor: ProfessionalColors.cardDark,
//   //       title: Text(
//   //         channel.name,
//   //         style: TextStyle(color: ProfessionalColors.textPrimary),
//   //       ),
//   //       content: Column(
//   //         mainAxisSize: MainAxisSize.min,
//   //         crossAxisAlignment: CrossAxisAlignment.start,
//   //         children: [
//   //           Text(
//   //             'Language: ${channel.language}',
//   //             style: TextStyle(color: ProfessionalColors.textSecondary),
//   //           ),
//   //           if (channel.description != null) ...[
//   //             SizedBox(height: 8),
//   //             Text(
//   //               'Description: ${channel.description}',
//   //               style: TextStyle(color: ProfessionalColors.textSecondary),
//   //             ),
//   //           ],
//   //           SizedBox(height: 8),
//   //           Text(
//   //             'Status: ${channel.status == 1 ? "Active" : "Inactive"}',
//   //             style: TextStyle(
//   //               color: channel.status == 1
//   //                   ? ProfessionalColors.accentGreen
//   //                   : ProfessionalColors.accentRed,
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(context),
//   //           child: Text(
//   //             'Close',
//   //             style: TextStyle(color: ProfessionalColors.accentOrange),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   ).then((_) {
//   //     print('🔙 Returned from Channel Details');
//   //     Future.delayed(Duration(milliseconds: 300), () {
//   //       if (mounted) {
//   //         int currentIndex = channelsList.indexWhere((ch) => ch.id == channel.id);
//   //         if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
//   //           String channelId = channel.id.toString();
//   //           if (channelsFocusNodes.containsKey(channelId)) {
//   //             setState(() {
//   //               focusedIndex = currentIndex;
//   //               _hasReceivedFocusFromWebSeries = true;
//   //             });
//   //             channelsFocusNodes[channelId]!.requestFocus();
//   //             _scrollToPosition(currentIndex);
//   //             print('✅ Restored focus to ${channel.name}');
//   //           }
//   //         }
//   //       }
//   //     });
//   //   });
//   // }

// // ✅ Updated _navigateToChannelDetails method in  ManageReligiousShows

//   void _navigateToChannelDetails(ReligiousChannelModel channel) {
//     print('📺 Navigating to Religious Channel Details: ${channel.name}');

//     // Navigate to ReligiousChannelDetailsPage instead of showing dialog
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ReligiousChannelDetailsPage(
//           id: channel.id,
//           banner: channel.logo ?? '', // Use logo as banner if available
//           poster: channel.logo ?? '', // Use logo as poster if available
//           name: channel.name, updatedAt: channel.updatedAt,
//         ),
//       ),
//     );
//     //.then((_) {
//     //   print('🔙 Returned from Religious Channel Details');
//     //   Future.delayed(Duration(milliseconds: 300), () {
//     //     if (mounted) {
//     //       int currentIndex = channelsList.indexWhere((ch) => ch.id == channel.id);
//     //       if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
//     //         String channelId = channel.id.toString();
//     //         if (channelsFocusNodes.containsKey(channelId)) {
//     //           setState(() {
//     //             focusedIndex = currentIndex;
//     //             _hasReceivedFocusFromWebSeries = true;
//     //           });
//     //           channelsFocusNodes[channelId]!.requestFocus();
//     //           _scrollToPosition(currentIndex);
//     //           print('✅ Restored focus to ${channel.name}');
//     //         }
//     //       }
//     //     }
//     //   });
//     // });
//   }

//   void _navigateToGridPage() {
//     print('📺 Navigating to Religious Channels Grid Page...');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProfessionalReligiousChannelsGridPage(
//           channelsList: channelsList,
//           title: 'Religious Channels',
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from grid page');
//       Future.delayed(Duration(milliseconds: 300), () {
//         if (mounted && _viewAllFocusNode != null) {
//           setState(() {
//             focusedIndex = maxHorizontalItems;
//             _hasReceivedFocusFromWebSeries = true;
//           });
//           _viewAllFocusNode!.requestFocus();
//           _scrollToPosition(maxHorizontalItems);
//           print('✅ Focused back to ViewAll button and scrolled');
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     // ✅ ADD: Consumer to listen to color changes
//     return Consumer<ColorProvider>(
//       builder: (context, colorProvider, child) {
//         final bgColor = colorProvider.isItemFocused
//             ? colorProvider.dominantColor.withOpacity(0.1)
//             : ProfessionalColors.primaryDark;

//         return Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Container(
//             // ✅ ENHANCED: Dynamic background gradient based on focused item
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

//   // 🚀 Enhanced Title with Cache Status
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
//                   ProfessionalColors.accentOrange,
//                   ProfessionalColors.accentRed,
//                 ],
//               ).createShader(bounds),
//               child: Text(
//                 'RELIGIOUS CHANNELS',
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//             ),
//             // Row(
//             //   children: [
//             //     // Channels Count
//             //     if (channelsList.length > 0)
//             //       Container(
//             //         padding:
//             //             const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             //         decoration: BoxDecoration(
//             //           gradient: LinearGradient(
//             //             colors: [
//             //               ProfessionalColors.accentOrange.withOpacity(0.2),
//             //               ProfessionalColors.accentRed.withOpacity(0.2),
//             //             ],
//             //           ),
//             //           borderRadius: BorderRadius.circular(20),
//             //           border: Border.all(
//             //             color: ProfessionalColors.accentOrange.withOpacity(0.3),
//             //             width: 1,
//             //           ),
//             //         ),
//             //         child: Text(
//             //           '${channelsList.length} Channels Available',
//             //           style: const TextStyle(
//             //             color: ProfessionalColors.textSecondary,
//             //             fontSize: 12,
//             //             fontWeight: FontWeight.w500,
//             //           ),
//             //         ),
//             //       ),
//             //   ],
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(double screenWidth, double screenHeight) {
//     if (isLoading) {
//       return ProfessionalReligiousChannelsLoadingIndicator(
//           message: 'Loading Religious Channels...');
//     } else if (channelsList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildChannelsList(screenWidth, screenHeight);
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
//                   ProfessionalColors.accentOrange.withOpacity(0.2),
//                   ProfessionalColors.accentOrange.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.tv_outlined,
//               size: 40,
//               color: ProfessionalColors.accentOrange,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No Religious Channels Found',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Check back later for new channels',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChannelsList(double screenWidth, double screenHeight) {
//     bool showViewAll = channelsList.length > 7;

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
//           itemCount: showViewAll ? 8 : channelsList.length,
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
//                       if (channelsList.isNotEmpty && channelsList.length > 6) {
//                         String channelId = channelsList[6].id.toString();
//                         FocusScope.of(context)
//                             .requestFocus(channelsFocusNodes[channelId]);
//                       }
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                       setState(() {
//                         focusedIndex = -1;
//                         _hasReceivedFocusFromWebSeries = false;
//                       });
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 100), () {
//                         if (mounted) {
//                           try {
//                             // Provider.of<FocusProvider>(context, listen: false)
//                             //     .requestFirstSportsCategoryFocus();
//                             // Provider.of<FocusProvider>(context, listen: false)
//                             //     .requestFirstSportsCategoryFocus();
//                             Provider.of<FocusProvider>(context, listen: false)
//                                 .requestFocus('sportsCategory');
//                             print(
//                                 '✅ Navigating back to web series from religious channels');
//                           } catch (e) {
//                             print('❌ Failed to navigate to web series: $e');
//                           }
//                         }
//                       });
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowDown) {
//                       setState(() {
//                         focusedIndex = -1;
//                         _hasReceivedFocusFromWebSeries = false;
//                       });
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 100), () {
//                         if (mounted) {
//                           try {
//                             // Provider.of<FocusProvider>(context, listen: false)
//                             //     .requestFirstTVShowsPakFocus();
//                             Provider.of<FocusProvider>(context, listen: false)
//                                 .requestFocus('tvShowsPak');
//                             print(
//                                 '✅ Navigating to TV Shows from religious channels ViewAll');
//                           } catch (e) {
//                             print('❌ Failed to navigate to TV Shows: $e');
//                           }
//                         }
//                       });
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//                         event.logicalKey == LogicalKeyboardKey.select) {
//                       print('📺 ViewAll button pressed - Opening Grid Page...');
//                       _navigateToGridPage();
//                       return KeyEventResult.handled;
//                     }
//                   }
//                   return KeyEventResult.ignored;
//                 },
//                 child: GestureDetector(
//                   onTap: _navigateToGridPage,
//                   child: ProfessionalReligiousChannelsViewAllButton(
//                     focusNode: _viewAllFocusNode!,
//                     onTap: _navigateToGridPage,
//                     totalItems: channelsList.length,
//                     itemType: 'CHANNELS',
//                   ),
//                 ),
//               );
//             }

//             var channel = channelsList[index];
//             return _buildChannelItem(channel, index, screenWidth, screenHeight);
//           },
//         ),
//       ),
//     );
//   }

//   // ✅ ENHANCED: Channel item with color provider integration
//   Widget _buildChannelItem(ReligiousChannelModel channel, int index,
//       double screenWidth, double screenHeight) {
//     String channelId = channel.id.toString();

//     channelsFocusNodes.putIfAbsent(
//       channelId,
//       () => FocusNode()
//         ..addListener(() {
//           if (mounted && channelsFocusNodes[channelId]!.hasFocus) {
//             _scrollToPosition(index);
//           }
//         }),
//     );

//     return Focus(
//       focusNode: channelsFocusNodes[channelId],
//       onFocusChange: (hasFocus) async {
//         if (hasFocus && mounted) {
//           try {
//             Color dominantColor = ProfessionalColors.gradientColors[
//                 math.Random()
//                     .nextInt(ProfessionalColors.gradientColors.length)];

//             setState(() {
//               _currentAccentColor = dominantColor;
//               focusedIndex = index;
//               _hasReceivedFocusFromWebSeries = true;
//             });

//             // ✅ ADD: Update color provider
//             context.read<ColorProvider>().updateColor(dominantColor, true);
//           } catch (e) {
//             print('Focus change handling failed: $e');
//           }
//         } else if (mounted) {
//           // ✅ ADD: Reset color when focus lost
//           context.read<ColorProvider>().resetColor();
//         }
//       },
//       // onKey: (FocusNode node, RawKeyEvent event) {
//       //   if (event is RawKeyDownEvent) {
//       //     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//       //       if (index < channelsList.length - 1 && index != 6) {
//       //         String nextChannelId = channelsList[index + 1].id.toString();
//       //         FocusScope.of(context)
//       //             .requestFocus(channelsFocusNodes[nextChannelId]);
//       //         return KeyEventResult.handled;
//       //       } else if (index == 6 && channelsList.length > 7) {
//       //         FocusScope.of(context).requestFocus(_viewAllFocusNode);
//       //         return KeyEventResult.handled;
//       //       }
//       //     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       //       if (index > 0) {
//       //         String prevChannelId = channelsList[index - 1].id.toString();
//       //         FocusScope.of(context)
//       //             .requestFocus(channelsFocusNodes[prevChannelId]);
//       //       }
//       //       return KeyEventResult.handled;
//       //     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       //       setState(() {
//       //         focusedIndex = -1;
//       //         _hasReceivedFocusFromWebSeries = false;
//       //       });
//       //       // ✅ ADD: Reset color when navigating away
//       //       context.read<ColorProvider>().resetColor();
//       //       FocusScope.of(context).unfocus();
//       //       Future.delayed(const Duration(milliseconds: 100), () {
//       //         if (mounted) {
//       //           try {
//       //             Provider.of<FocusProvider>(context, listen: false)
//       //                 .requestFirstSportsCategoryFocus();
//       //             print(
//       //                 '✅ Navigating back to web series from religious channels');
//       //           } catch (e) {
//       //             print('❌ Failed to navigate to web series: $e');
//       //           }
//       //         }
//       //       });
//       //       return KeyEventResult.handled;
//       //     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       //       setState(() {
//       //         focusedIndex = -1;
//       //         _hasReceivedFocusFromWebSeries = false;
//       //       });
//       //       // ✅ ADD: Reset color when navigating away
//       //       context.read<ColorProvider>().resetColor();
//       //       FocusScope.of(context).unfocus();
//       //       Future.delayed(const Duration(milliseconds: 100), () {
//       //         if (mounted) {
//       //           try {
//       //             Provider.of<FocusProvider>(context, listen: false)
//       //                 .requestFirstTVShowsPakFocus();
//       //             print('✅ Navigating to TV Shows from religious channels');
//       //           } catch (e) {
//       //             print('❌ Failed to navigate to TV Shows: $e');
//       //           }
//       //         }
//       //       });
//       //       return KeyEventResult.handled;
//       //     } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//       //         event.logicalKey == LogicalKeyboardKey.select) {
//       //       print('📺 Enter pressed on ${channel.name} - Opening Details...');
//       //       _navigateToChannelDetails(channel);
//       //       return KeyEventResult.handled;
//       //     }
//       //   }
//       //   return KeyEventResult.ignored;
//       // },

//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           final key = event.logicalKey;

//           // --- हॉरिजॉन्टल मूवमेंट (लेफ्ट/राइट) के लिए थ्रॉटलिंग ---
//           if (key == LogicalKeyboardKey.arrowRight ||
//               key == LogicalKeyboardKey.arrowLeft) {
//             // 1. अगर नेविगेशन लॉक्ड है, तो कुछ न करें
//             if (_isNavigationLocked) return KeyEventResult.handled;

//             // 2. नेविगेशन को लॉक करें और 300ms का टाइमर शुरू करें
//             setState(() => _isNavigationLocked = true);
//             _navigationLockTimer = Timer(const Duration(milliseconds: 600), () {
//               if (mounted) setState(() => _isNavigationLocked = false);
//             });

//             // 3. अब फोकस बदलें
//             if (key == LogicalKeyboardKey.arrowRight) {
//               if (index < channelsList.length - 1 &&
//                   index < maxHorizontalItems - 1) {
//                 String nextChannelId = channelsList[index + 1].id.toString();
//                 FocusScope.of(context)
//                     .requestFocus(channelsFocusNodes[nextChannelId]);
//               } else if (index == maxHorizontalItems - 1 &&
//                   channelsList.length > maxHorizontalItems) {
//                 FocusScope.of(context).requestFocus(_viewAllFocusNode);
//               } else {
//                 _navigationLockTimer?.cancel();
//                 if (mounted) setState(() => _isNavigationLocked = false);
//               }
//             } else if (key == LogicalKeyboardKey.arrowLeft) {
//               if (index > 0) {
//                 String prevChannelId = channelsList[index - 1].id.toString();
//                 FocusScope.of(context)
//                     .requestFocus(channelsFocusNodes[prevChannelId]);
//               } else {
//                 _navigationLockTimer?.cancel();
//                 if (mounted) setState(() => _isNavigationLocked = false);
//               }
//             }
//             return KeyEventResult.handled;
//           }

//           // --- बाकी कीज़ (अप/डाउन/सेलेक्ट) को तुरंत हैंडल करें ---
//           if (key == LogicalKeyboardKey.arrowUp) {
//             setState(() {
//               focusedIndex = -1;
//               _hasReceivedFocusFromWebSeries = false;
//             });
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 100), () {
//               if (mounted) {
//                 try {
//                   // Provider.of<FocusProvider>(context, listen: false)
//                   //     .requestFirstSportsCategoryFocus();
//                   Provider.of<FocusProvider>(context, listen: false)
//                       .requestFocus('sportsCategory');
//                 } catch (e) {
//                   print('❌ Failed to navigate up: $e');
//                 }
//               }
//             });
//             return KeyEventResult.handled;
//           } else if (key == LogicalKeyboardKey.arrowDown) {
//             setState(() {
//               focusedIndex = -1;
//               _hasReceivedFocusFromWebSeries = false;
//             });
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 100), () {
//               if (mounted) {
//                 try {
//                   // Provider.of<FocusProvider>(context, listen: false)
//                   //     .requestFirstTVShowsPakFocus();
//                   Provider.of<FocusProvider>(context, listen: false)
//                       .requestFocus('tvShowsPak');
//                 } catch (e) {
//                   print('❌ Failed to navigate down: $e');
//                 }
//               }
//             });
//             return KeyEventResult.handled;
//           } else if (key == LogicalKeyboardKey.enter ||
//               key == LogicalKeyboardKey.select) {
//             _navigateToChannelDetails(channel);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () => _navigateToChannelDetails(channel),
//         child: ProfessionalReligiousChannelCard(
//           channel: channel,
//           focusNode: channelsFocusNodes[channelId]!,
//           onTap: () => _navigateToChannelDetails(channel),
//           onColorChange: (color) {
//             setState(() {
//               _currentAccentColor = color;
//             });
//             // ✅ ADD: Update color provider when card changes color
//             context.read<ColorProvider>().updateColor(color, true);
//           },
//           index: index,
//           categoryTitle: 'RELIGIOUS CHANNELS',
//         ),
//       ),
//     );
//   }

// //   @override
// //   void dispose() {
// //     _navigationLockTimer?.cancel();
// //     _headerAnimationController.dispose();
// //     _listAnimationController.dispose();

// //     for (var entry in channelsFocusNodes.entries) {
// //       try {
// //         entry.value.removeListener(() {});
// //         entry.value.dispose();
// //       } catch (e) {}
// //     }
// //     channelsFocusNodes.clear();

// //     try {
// //       _viewAllFocusNode?.removeListener(() {});
// //       _viewAllFocusNode?.dispose();
// //     } catch (e) {}

// //     try {
// //       _scrollController.dispose();
// //     } catch (e) {}

// //     super.dispose();
// //   }
// // }

//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();

//     // ❗️ BADLAV YAHAN: Sirf un nodes ko dispose karein jo provider mein register NAHI hue
//     String? firstChannelId;
//     if (channelsList.isNotEmpty) {
//       firstChannelId = channelsList[0].id.toString();
//     }

//     for (var entry in channelsFocusNodes.entries) {
//       // Agar node register nahi hua hai (yaani first channel nahi hai), tabhi use yahan dispose karein
//       if (entry.key != firstChannelId) {
//         try {
//           entry.value.removeListener(() {});
//           entry.value.dispose();
//         } catch (e) {}
//       }
//     }
//     channelsFocusNodes.clear();

//     try {
//       // ViewAll node provider mein register nahi hota, isliye use dispose karna theek hai
//       _viewAllFocusNode?.removeListener(() {});
//       _viewAllFocusNode?.dispose();
//     } catch (e) {}

//     try {
//       _scrollController.dispose();
//     } catch (e) {}

//     super.dispose();
//   }
// }

// // ✅ Professional Religious Channel Card
// class ProfessionalReligiousChannelCard extends StatefulWidget {
//   final ReligiousChannelModel channel;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalReligiousChannelCard({
//     Key? key,
//     required this.channel,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalReligiousChannelCardState createState() =>
//       _ProfessionalReligiousChannelCardState();
// }

// class _ProfessionalReligiousChannelCardState
//     extends State<ProfessionalReligiousChannelCard>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _glowController;
//   late AnimationController _shimmerController;

//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<double> _shimmerAnimation;

//   Color _dominantColor = ProfessionalColors.accentOrange;
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
//             _buildChannelImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildLanguageBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildChannelImage(double screenWidth, double posterHeight) {
//     return Container(
//       width: double.infinity,
//       height: posterHeight,
//       child: widget.channel.logo != null && widget.channel.logo!.isNotEmpty
//           ? Image.network(
//               widget.channel.logo!,
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
//             Icons.radio_rounded,
//             size: height * 0.25,
//             color: ProfessionalColors.textSecondary,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'RELIGIOUS',
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
//               color: ProfessionalColors.accentOrange.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'LIVE',
//               style: TextStyle(
//                 color: ProfessionalColors.accentOrange,
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

//   Widget _buildLanguageBadge() {
//     String language = widget.channel.language.toUpperCase();
//     Color badgeColor = ProfessionalColors.accentOrange;

//     // Different colors for different languages
//     if (language.toLowerCase().contains('hindi')) {
//       badgeColor = ProfessionalColors.accentOrange;
//     } else if (language.toLowerCase().contains('punjabi')) {
//       badgeColor = ProfessionalColors.accentGreen;
//     } else if (language.toLowerCase().contains('english')) {
//       badgeColor = ProfessionalColors.accentBlue;
//     } else if (language.toLowerCase().contains('urdu')) {
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
//           language,
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
//     final channelName = widget.channel.name.toUpperCase();

//     return Container(
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
//           channelName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // ✅ Professional View All Button for Religious Channels
// class ProfessionalReligiousChannelsViewAllButton extends StatefulWidget {
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int totalItems;
//   final String itemType;

//   const ProfessionalReligiousChannelsViewAllButton({
//     Key? key,
//     required this.focusNode,
//     required this.onTap,
//     required this.totalItems,
//     this.itemType = 'CHANNELS',
//   }) : super(key: key);

//   @override
//   _ProfessionalReligiousChannelsViewAllButtonState createState() =>
//       _ProfessionalReligiousChannelsViewAllButtonState();
// }

// class _ProfessionalReligiousChannelsViewAllButtonState
//     extends State<ProfessionalReligiousChannelsViewAllButton>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _rotateController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _rotateAnimation;

//   bool _isFocused = false;
//   Color _currentColor = ProfessionalColors.accentOrange;

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
//       width: bannerwdt,
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
//                     height: _isFocused ? focussedBannerhgt : bannerhgt,
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
//                   Icons.radio_rounded,
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

// // ✅ Professional Loading Indicator for Religious Channels
// class ProfessionalReligiousChannelsLoadingIndicator extends StatefulWidget {
//   final String message;

//   const ProfessionalReligiousChannelsLoadingIndicator({
//     Key? key,
//     this.message = 'Loading Religious Channels...',
//   }) : super(key: key);

//   @override
//   _ProfessionalReligiousChannelsLoadingIndicatorState createState() =>
//       _ProfessionalReligiousChannelsLoadingIndicatorState();
// }

// class _ProfessionalReligiousChannelsLoadingIndicatorState
//     extends State<ProfessionalReligiousChannelsLoadingIndicator>
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
//                       ProfessionalColors.accentOrange,
//                       ProfessionalColors.accentRed,
//                       ProfessionalColors.accentPink,
//                       ProfessionalColors.accentOrange,
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
//                     Icons.radio_rounded,
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
//                     ProfessionalColors.accentOrange,
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

// // ✅ Professional Religious Channels Grid Page
// class ProfessionalReligiousChannelsGridPage extends StatefulWidget {
//   final List<ReligiousChannelModel> channelsList;
//   final String title;

//   const ProfessionalReligiousChannelsGridPage({
//     Key? key,
//     required this.channelsList,
//     this.title = 'All Religious Channels',
//   }) : super(key: key);

//   @override
//   _ProfessionalReligiousChannelsGridPageState createState() =>
//       _ProfessionalReligiousChannelsGridPageState();
// }

// class _ProfessionalReligiousChannelsGridPageState
//     extends State<ProfessionalReligiousChannelsGridPage>
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
//     for (int i = 0; i < widget.channelsList.length; i++) {
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

//   void _ensureItemVisible(int index) {
//     if (_scrollController.hasClients) {
//       final int row = index ~/ columnsCount;
//       final double itemHeight = 200.0;
//       final double targetOffset = row * itemHeight;

//       _scrollController.animateTo(
//         targetOffset,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void _navigateGrid(LogicalKeyboardKey key) {
//     int newIndex = gridFocusedIndex;
//     final int totalItems = widget.channelsList.length;
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

//     if (newIndex != gridFocusedIndex &&
//         newIndex >= 0 &&
//         newIndex < totalItems) {
//       setState(() {
//         gridFocusedIndex = newIndex;
//       });
//       gridFocusNodes[newIndex]!.requestFocus();
//     }
//   }

//   void _navigateToChannelDetails(ReligiousChannelModel channel, int index) {
//     print('📺 Grid: Navigating to Religious Channel Details: ${channel.name}');

//     // Navigate to ReligiousChannelDetailsPage instead of showing dialog
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ReligiousChannelDetailsPage(
//           id: channel.id,
//           banner: channel.logo ?? '', // Use logo as banner if available
//           poster: channel.logo ?? '', // Use logo as poster if available
//           name: channel.name, updatedAt: channel.updatedAt,
//         ),
//       ),
//     );
//     // .then((_) {
//     //     print('🔙 Returned from Channel Details to Grid');
//     //     Future.delayed(Duration(milliseconds: 300), () {
//     //       if (mounted && gridFocusNodes.containsKey(index)) {
//     //         setState(() {
//     //           gridFocusedIndex = index;
//     //         });
//     //         gridFocusNodes[index]!.requestFocus();
//     //         print('✅ Restored grid focus to index $index');
//     //       }
//     //     });
//     //   });
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
//         top: MediaQuery.of(context).padding.top + 10,
//         left: 40,
//         right: 40,
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
//           const SizedBox(height: 10),
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentOrange.withOpacity(0.2),
//                   ProfessionalColors.accentRed.withOpacity(0.2),
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
//                       ProfessionalColors.accentOrange,
//                       ProfessionalColors.accentRed,
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
//                 // Container(
//                 //   padding:
//                 //       const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 //   decoration: BoxDecoration(
//                 //     gradient: LinearGradient(
//                 //       colors: [
//                 //         ProfessionalColors.accentOrange.withOpacity(0.2),
//                 //         ProfessionalColors.accentRed.withOpacity(0.1),
//                 //       ],
//                 //     ),
//                 //     borderRadius: BorderRadius.circular(15),
//                 //     border: Border.all(
//                 //       color: ProfessionalColors.accentOrange.withOpacity(0.3),
//                 //       width: 1,
//                 //     ),
//                 //   ),
//                 //   child: Text(
//                 //     '${widget.channelsList.length} Channels Available',
//                 //     style: const TextStyle(
//                 //       color: ProfessionalColors.accentOrange,
//                 //       fontSize: 12,
//                 //       fontWeight: FontWeight.w500,
//                 //     ),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }

//   Widget _buildGridView() {
//     if (widget.channelsList.isEmpty) {
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
//                     ProfessionalColors.accentOrange.withOpacity(0.2),
//                     ProfessionalColors.accentOrange.withOpacity(0.1),
//                   ],
//                 ),
//               ),
//               child: const Icon(
//                 Icons.radio_rounded,
//                 size: 40,
//                 color: ProfessionalColors.accentOrange,
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
//               'Check back later for new channels',
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
//           if ([
//             LogicalKeyboardKey.arrowUp,
//             LogicalKeyboardKey.arrowDown,
//             LogicalKeyboardKey.arrowLeft,
//             LogicalKeyboardKey.arrowRight,
//           ].contains(event.logicalKey)) {
//             _navigateGrid(event.logicalKey);
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//               event.logicalKey == LogicalKeyboardKey.select) {
//             if (gridFocusedIndex < widget.channelsList.length) {
//               _navigateToChannelDetails(
//                 widget.channelsList[gridFocusedIndex],
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
//             crossAxisCount: columnsCount,
//             crossAxisSpacing: 15,
//             mainAxisSpacing: 15,
//             childAspectRatio: 1.5,
//           ),
//           itemCount: widget.channelsList.length,
//           itemBuilder: (context, index) {
//             return AnimatedBuilder(
//               animation: _staggerController,
//               builder: (context, child) {
//                 final delay = (index / widget.channelsList.length) * 0.5;
//                 final animationValue = Interval(
//                   delay,
//                   delay + 0.5,
//                   curve: Curves.easeOutCubic,
//                 ).transform(_staggerController.value);

//                 return Transform.translate(
//                   offset: Offset(0, 50 * (1 - animationValue)),
//                   child: Opacity(
//                     opacity: animationValue,
//                     child: ProfessionalGridReligiousChannelCard(
//                       channel: widget.channelsList[index],
//                       focusNode: gridFocusNodes[index]!,
//                       onTap: () => _navigateToChannelDetails(
//                           widget.channelsList[index], index),
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

// // ✅ Professional Grid Religious Channel Card
// class ProfessionalGridReligiousChannelCard extends StatefulWidget {
//   final ReligiousChannelModel channel;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalGridReligiousChannelCard({
//     Key? key,
//     required this.channel,
//     required this.focusNode,
//     required this.onTap,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalGridReligiousChannelCardState createState() =>
//       _ProfessionalGridReligiousChannelCardState();
// }

// class _ProfessionalGridReligiousChannelCardState
//     extends State<ProfessionalGridReligiousChannelCard>
//     with TickerProviderStateMixin {
//   late AnimationController _hoverController;
//   late AnimationController _glowController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;

//   Color _dominantColor = ProfessionalColors.accentOrange;
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
//                       _buildChannelImage(),
//                       if (_isFocused) _buildFocusBorder(),
//                       _buildGradientOverlay(),
//                       _buildChannelInfo(),
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

//   Widget _buildChannelImage() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       child: widget.channel.logo != null && widget.channel.logo!.isNotEmpty
//           ? Image.network(
//               widget.channel.logo!,
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
//               Icons.radio_rounded,
//               size: 40,
//               color: ProfessionalColors.textSecondary,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'RELIGIOUS',
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
//                 color: ProfessionalColors.accentOrange.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Text(
//                 'LIVE',
//                 style: TextStyle(
//                   color: ProfessionalColors.accentOrange,
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

//   Widget _buildChannelInfo() {
//     final channelName = widget.channel.name;

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
//               channelName.toUpperCase(),
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
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: ProfessionalColors.accentOrange.withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: ProfessionalColors.accentOrange.withOpacity(0.5),
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       widget.channel.language.toUpperCase(),
//                       style: const TextStyle(
//                         color: ProfessionalColors.accentOrange,
//                         fontSize: 8,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
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
//                       widget.channel.status == 1 ? 'LIVE' : 'OFFLINE',
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






import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel_details_page.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/webseries_details_page.dart'; // Iski zaroorat nahi
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:ui';

// ✅ Professional Color Palette (same as Movies)
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

// ✅ Religious Channel Model
class ReligiousChannelModel {
  final int id;
  final String name;
  final String? logo;
  final String? description;
  final String language;
  final int status;
  final int relOrder;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  ReligiousChannelModel({
    required this.id,
    required this.name,
    this.logo,
    this.description,
    required this.language,
    required this.status,
    required this.relOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory ReligiousChannelModel.fromJson(Map<String, dynamic> json) {
    return ReligiousChannelModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'],
      description: json['description'],
      language: json['language'] ?? '',
      status: json['status'] ?? 0,
      relOrder: json['rel_order'] ?? 9999, // Provide a default high value
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
    );
  }
}

// 🚀 Enhanced Religious Channels Service with Caching
class ReligiousChannelsService {
  // Cache keys
  static const String _cacheKeyChannels = 'cached_religious_channels';
  static const String _cacheKeyTimestamp =
      'cached_religious_channels_timestamp';
  static const String _cacheKeyAuthKey = 'result_auth_key';

  // Cache duration (in milliseconds) - 1 hour
  static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

  /// Main method to get all religious channels with caching
  static Future<List<ReligiousChannelModel>> getAllReligiousChannels(
      {bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we should use cache
      if (!forceRefresh && await _shouldUseCache(prefs)) {
        print('📦 Loading Religious Channels from cache...');
        final cachedChannels = await _getCachedChannels(prefs);
        if (cachedChannels.isNotEmpty) {
          print(
              '✅ Successfully loaded ${cachedChannels.length} religious channels from cache');

          // Load fresh data in background (without waiting)
          _loadFreshDataInBackground();

          return cachedChannels;
        }
      }

      // Load fresh data if no cache or force refresh
      print('🌐 Loading fresh Religious Channels from API...');
      return await _fetchFreshChannels(prefs);
    } catch (e) {
      print('❌ Error in getAllReligiousChannels: $e');

      // Try to return cached data as fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedChannels = await _getCachedChannels(prefs);
        if (cachedChannels.isNotEmpty) {
          print('🔄 Returning cached data as fallback');
          return cachedChannels;
        }
      } catch (cacheError) {
        print('❌ Cache fallback also failed: $cacheError');
      }

      throw Exception('Failed to load religious channels: $e');
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
        print(
            '📦 Religious Channels Cache is valid (${ageMinutes} minutes old)');
      } else {
        final ageMinutes = (cacheAge / (1000 * 60)).round();
        print('⏰ Religious Channels Cache expired (${ageMinutes} minutes old)');
      }

      return isValid;
    } catch (e) {
      print('❌ Error checking Religious Channels cache validity: $e');
      return false;
    }
  }

  /// Get religious channels from cache
  static Future<List<ReligiousChannelModel>> _getCachedChannels(
      SharedPreferences prefs) async {
    try {
      final cachedData = prefs.getString(_cacheKeyChannels);
      if (cachedData == null || cachedData.isEmpty) {
        print('📦 No cached Religious Channels data found');
        return [];
      }

      final List<dynamic> jsonData = json.decode(cachedData);
      final channels = jsonData
          .map((json) =>
              ReligiousChannelModel.fromJson(json as Map<String, dynamic>))
          .where((channel) => channel.status == 1) // Filter active channels
          .toList();

       // Sort by rel_order
      channels.sort((a, b) => a.relOrder.compareTo(b.relOrder));


      print(
          '📦 Successfully loaded ${channels.length} active religious channels from cache');
      return channels;
    } catch (e) {
      print('❌ Error loading cached religious channels: $e');
      return [];
    }
  }

  /// Fetch fresh religious channels from API and cache them
  static Future<List<ReligiousChannelModel>> _fetchFreshChannels(
      SharedPreferences prefs) async {
    try {
      String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';

      final response = await http.get(
        Uri.parse(
            'https://dashboard.cpplayers.com/public/api/v2/getReligiousChannels'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain': 'coretechinfo.com',
        },
      ).timeout(
            const Duration(seconds: 30), // Added timeout
            onTimeout: () {
              throw TimeoutException('The connection has timed out, Please try again!');
            },
          );


      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        final allChannels = jsonData
            .map((json) =>
                ReligiousChannelModel.fromJson(json as Map<String, dynamic>))
            .toList();

         // Filter active channels
        final activeChannels = allChannels.where((channel) => channel.status == 1).toList();

        // Sort by rel_order
        activeChannels.sort((a, b) => a.relOrder.compareTo(b.relOrder));

        // Cache the fresh data (save all channels from API response)
        await _cacheChannels(prefs, jsonData);

        print(
            '✅ Successfully loaded ${activeChannels.length} active religious channels from API (from ${allChannels.length} total)');
        return activeChannels;
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error fetching fresh religious channels: $e');
      rethrow;
    }
  }

  /// Cache religious channels data
  static Future<void> _cacheChannels(
      SharedPreferences prefs, List<dynamic> channelsData) async {
    try {
      final jsonString = json.encode(channelsData);
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Save channels data and timestamp
      await Future.wait([
        prefs.setString(_cacheKeyChannels, jsonString),
        prefs.setString(_cacheKeyTimestamp, currentTimestamp),
      ]);

      print('💾 Successfully cached ${channelsData.length} religious channels');
    } catch (e) {
      print('❌ Error caching religious channels: $e');
    }
  }

  /// Load fresh data in background without blocking UI
  static void _loadFreshDataInBackground() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        print('🔄 Loading fresh religious channels data in background...');
        final prefs = await SharedPreferences.getInstance();
        await _fetchFreshChannels(prefs);
        print('✅ Religious Channels background refresh completed');
      } catch (e) {
        print('⚠️ Religious Channels background refresh failed: $e');
      }
    });
  }

  /// Clear all cached data
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_cacheKeyChannels),
        prefs.remove(_cacheKeyTimestamp),
      ]);
      print('🗑️ Religious Channels cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing Religious Channels cache: $e');
    }
  }

  /// Get cache info for debugging
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString(_cacheKeyTimestamp);
      final cachedData = prefs.getString(_cacheKeyChannels);

      if (timestampStr == null || cachedData == null) {
        return {
          'hasCachedData': false,
          'cacheAge': 0,
          'cachedChannelsCount': 0,
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
        'cachedChannelsCount': jsonData.length,
        'cacheSize': cacheSizeKB,
        'isValid': cacheAge < _cacheDurationMs,
      };
    } catch (e) {
      print('❌ Error getting Religious Channels cache info: $e');
      return {
        'hasCachedData': false,
        'cacheAge': 0,
        'cachedChannelsCount': 0,
        'cacheSize': 0,
        'error': e.toString(),
      };
    }
  }

  /// Force refresh data (bypass cache)
  static Future<List<ReligiousChannelModel>> forceRefresh() async {
    print('🔄 Force refreshing Religious Channels data...');
    return await getAllReligiousChannels(forceRefresh: true);
  }
}

// 🚀 Enhanced ManageReligiousShows with Caching
class ManageReligiousShows extends StatefulWidget {
  const ManageReligiousShows({super.key});
  @override
  _ManageReligiousShowsState createState() => _ManageReligiousShowsState();
}

class _ManageReligiousShowsState extends State<ManageReligiousShows>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  List<ReligiousChannelModel> channelsList = [];
  bool isLoading = true;
  int focusedIndex = -1;
  final int maxHorizontalItems = 7;
  Color _currentAccentColor = ProfessionalColors.accentOrange;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  Map<String, FocusNode> channelsFocusNodes = {};
  FocusNode? _viewAllFocusNode;
  FocusNode? _firstChannelFocusNode; // Provider mein register karne ke liye
  bool _hasReceivedFocusFromSports = false; // Updated variable name

  late ScrollController _scrollController;
  bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
    _initializeFocusNodes();
    fetchChannelsWithCache();
  }

  // ✅ ==========================================================
  // ✅ [UPDATED] Sahi dispose logic
  // ✅ ==========================================================
  @override
  void dispose() {
    _navigationLockTimer?.cancel();
    _headerAnimationController.dispose();
    _listAnimationController.dispose();

    // Sirf un nodes ko dispose karein jo provider mein register NAHI hue
    String? firstChannelId;
    if (channelsList.isNotEmpty) {
      firstChannelId = channelsList[0].id.toString();
    }

    for (var entry in channelsFocusNodes.entries) {
      // Agar node register nahi hua hai (yaani first channel nahi hai), tabhi use yahan dispose karein
      if (entry.key != firstChannelId) {
        try {
          entry.value.removeListener(() {});
          entry.value.dispose();
        } catch (e) {}
      }
    }
    // Pehle item ka node provider mein dispose hoga.

    channelsFocusNodes.clear();
    // ViewAll node provider mein register nahi hota, isliye use dispose karna theek hai
    _viewAllFocusNode?.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  // ✅ ==========================================================
  // ✅ END OF [UPDATED] dispose logic
  // ✅ ==========================================================


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
    print('✅ Religious Channels focus nodes initialized');
  }

   // Scrolling logic
  void _scrollToPosition(int index) {
     if (!mounted || !_scrollController.hasClients) return;
    try {
      double itemWidth = bannerwdt + 12; // Card width + horizontal margin (6+6)
      double targetPosition = index * itemWidth;

      targetPosition =
          targetPosition.clamp(0.0, _scrollController.position.maxScrollExtent);

      _scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 350), // Snappier scroll
        curve: Curves.easeOutCubic,
      );
    } catch (e) {
      print('Error scrolling in religious channels: $e');
    }
  }


//  // Yeh function ab seedha _firstChannelFocusNode ko register karta hai
//   void _setupFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && channelsList.isNotEmpty) {
//         try {
//           final focusProvider =
//               Provider.of<FocusProvider>(context, listen: false);

//           final firstChannelId = channelsList[0].id.toString();
//            // Ensure the node exists or create it
//            if (!channelsFocusNodes.containsKey(firstChannelId)) {
//                 channelsFocusNodes[firstChannelId] = FocusNode();
//            }
//           _firstChannelFocusNode = channelsFocusNodes[firstChannelId];


//           if (_firstChannelFocusNode != null) {
//             // Node ko provider mein 'religiousChannels' ID se register karein
//             focusProvider.registerFocusNode(
//                 'religiousChannels', _firstChannelFocusNode!);
//             print(
//                 '✅ Religious Channels first focus node registered: ${channelsList[0].name}');

//             // Listener yahin add karein
//             _firstChannelFocusNode!.addListener(() {
//                if (!mounted) return; // Add mount check
//               if (_firstChannelFocusNode!.hasFocus &&
//                   !_hasReceivedFocusFromSports) { // Updated variable name
//                 _hasReceivedFocusFromSports = true;
//                 setState(() {
//                   focusedIndex = 0;
//                 });
//                 _scrollToPosition(0);
//                 print(
//                     '✅ Religious Channels received focus from Sports and scrolled');
//               }
//             });
//           }
//         } catch (e) {
//           print('❌ Religious Channels focus provider setup failed: $e');
//         }
//       }
//     });
//   }



// Yeh function ab seedha _firstChannelFocusNode ko register karta hai
  void _setupFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && channelsList.isNotEmpty) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);

          final firstChannelId = channelsList[0].id.toString();
          // Ensure the node exists or create it
          if (!channelsFocusNodes.containsKey(firstChannelId)) {
            channelsFocusNodes[firstChannelId] = FocusNode();
             print('⚠️ First channel focus node was missing, created it.'); // Added debug log
          }
          _firstChannelFocusNode = channelsFocusNodes[firstChannelId];


          if (_firstChannelFocusNode != null) {
            // Node ko provider mein 'religiousChannels' ID se register karein
            focusProvider.registerFocusNode(
                'religiousChannels', _firstChannelFocusNode!);
            print(
                '✅ Religious Channels first focus node registered: ${channelsList[0].name}');

            // Listener yahin add karein
            _firstChannelFocusNode!.addListener(() {
                // ✅ ==========================================================
                // ✅ [FIXED] Listener logic
                // ✅ ==========================================================
                // Check karein ki widget mounted hai aur node ko focus mila hai
                if (mounted && _firstChannelFocusNode!.hasFocus) {

                  // _hasReceivedFocusFromSports flag ko sirf tab set karein jab
                  // focus pehli baar row mein aa रहा है.
                  if (!_hasReceivedFocusFromSports) {
                    _hasReceivedFocusFromSports = true;
                  }

                  // State update aur scroll logic ko hamesha run karein
                  // jab bhi yeh node focus mein aaye.
                  setState(() => focusedIndex = 0);
                  _scrollToPosition(0);
                   print('✅ Religious Channels (first item) received focus and scrolled');
                }
                // ✅ ==========================================================
                // ✅ END OF [FIXED] listener logic
                // ✅ ==========================================================
            });
          } else {
             print('❌ ERROR: _firstChannelFocusNode is null after attempting creation!');
          }
        } catch (e) {
          print('❌ Religious Channels focus provider setup failed: $e');
        }
      } else {
         print('ℹ️ SetupFocusProvider skipped: mounted=$mounted, channelsList empty=${channelsList.isEmpty}');
      }
    });
  }


  // 🚀 Enhanced fetch method with caching
  Future<void> fetchChannelsWithCache() async {
    if (!mounted) return;
    setState(() { isLoading = true; });
    try {
      final fetchedChannels =
          await ReligiousChannelsService.getAllReligiousChannels();
      if (fetchedChannels.isNotEmpty) {
        if (mounted) {
          setState(() {
            channelsList = fetchedChannels;
            isLoading = false;
          });
          _createFocusNodesForItems(); // Focus nodes banayein
          _setupFocusProvider(); // *Uske baad* provider ko setup karein
          _headerAnimationController.forward();
          _listAnimationController.forward();
          _debugCacheInfo();
        }
      } else {
        if (mounted) { setState(() { isLoading = false; }); }
      }
    } catch (e) {
      if (mounted) { setState(() { isLoading = false; }); }
      print('Error fetching Religious Channels with cache: $e');
    }
  }

  // 🆕 Debug method to show cache information
  Future<void> _debugCacheInfo() async {
    try {
      final cacheInfo = await ReligiousChannelsService.getCacheInfo();
      print('📊 Religious Channels Cache Info: $cacheInfo');
    } catch (e) {
      print('❌ Error getting Religious Channels cache info: $e');
    }
  }

  // 🆕 Force refresh channels
  Future<void> _forceRefreshChannels() async {
    if (!mounted) return;
    setState(() { isLoading = true; });
    try {
      final fetchedChannels = await ReligiousChannelsService.forceRefresh();
      if (fetchedChannels.isNotEmpty) {
        if (mounted) {
          setState(() {
            channelsList = fetchedChannels;
            isLoading = false;
          });
          _createFocusNodesForItems();
          _setupFocusProvider();
          _headerAnimationController.forward();
          _listAnimationController.forward();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Religious Channels refreshed successfully'),
              backgroundColor: ProfessionalColors.accentOrange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(10), ),
            ),
          );
        }
      } else {
        if (mounted) { setState(() { isLoading = false; }); }
      }
    } catch (e) {
      if (mounted) { setState(() { isLoading = false; }); }
      print('❌ Error force refreshing religious channels: $e');
    }
  }

 void _createFocusNodesForItems() {
    // Purane nodes ko saaf karein (naye dispose logic ke hisaab se)
    channelsFocusNodes.clear();

    for (int i = 0; i < channelsList.length && i < maxHorizontalItems; i++) {
      String channelId = channelsList[i].id.toString();
      channelsFocusNodes[channelId] = FocusNode(); // Naya node banayein

      // Pehle node ke alawa baaki nodes ke liye listener yahin add karein
      // (Pehle node ka listener _setupFocusProvider mein add hoga)
      if (i > 0) {
        channelsFocusNodes[channelId]!.addListener(() {
           if (!mounted) return; // Add mount check
          if (channelsFocusNodes[channelId]!.hasFocus) {
            setState(() {
              focusedIndex = i;
              _hasReceivedFocusFromSports = true; // Updated variable
            });
            _scrollToPosition(i);
            print(
                '✅ Religious Channel $i focused and scrolled: ${channelsList[i].name}');
          }
        });
      }
    }
    print(
        '✅ Created ${channelsFocusNodes.length} religious channels focus nodes with auto-scroll');
  }


  void _navigateToChannelDetails(ReligiousChannelModel channel) {
    print('📺 Navigating to Religious Channel Details: ${channel.name}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReligiousChannelDetailsPage(
          id: channel.id,
          banner: channel.logo ?? '', // Use logo as banner if available
          poster: channel.logo ?? '', // Use logo as poster if available
          name: channel.name, updatedAt: channel.updatedAt,
        ),
      ),
    ).then((_) { // Added .then() for focus restoration
       print('🔙 Returned from Religious Channel Details');
       Future.delayed(Duration(milliseconds: 300), () {
         if (mounted) {
           int currentIndex = channelsList.indexWhere((ch) => ch.id == channel.id);
           if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
             String channelId = channel.id.toString();
             if (channelsFocusNodes.containsKey(channelId)) {
                if (!mounted) return; // Add mount check before setState
               setState(() {
                 focusedIndex = currentIndex;
                 _hasReceivedFocusFromSports = true; // Updated variable
               });
               channelsFocusNodes[channelId]!.requestFocus();
               _scrollToPosition(currentIndex);
               print('✅ Restored focus to ${channel.name}');
             }
           }
         }
       });
     });
  }


  void _navigateToGridPage() {
    print('📺 Navigating to Religious Channels Grid Page...');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalReligiousChannelsGridPage(
          channelsList: channelsList,
          title: 'Religious Channels',
        ),
      ),
    ).then((_) {
      print('🔙 Returned from grid page');
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted && _viewAllFocusNode != null) {
          setState(() {
            focusedIndex = maxHorizontalItems;
            _hasReceivedFocusFromSports = true; // Updated variable
          });
          _viewAllFocusNode!.requestFocus();
          _scrollToPosition(maxHorizontalItems);
          print('✅ Focused back to ViewAll button and scrolled');
        }
      });
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

  Widget _buildChannelItem(ReligiousChannelModel channel, int index,
      double screenWidth, double screenHeight) {
    String channelId = channel.id.toString();
    FocusNode? focusNode = channelsFocusNodes[channelId];

    if (focusNode == null) return const SizedBox.shrink();


    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) async {
         if (!mounted) return; // Add mount check
        if (hasFocus) {
          try {
            Color dominantColor = ProfessionalColors.gradientColors[
                math.Random()
                    .nextInt(ProfessionalColors.gradientColors.length)];

            setState(() {
              _currentAccentColor = dominantColor;
              focusedIndex = index;
              _hasReceivedFocusFromSports = true; // Updated variable
            });
            context.read<ColorProvider>().updateColor(dominantColor, true);
          } catch (e) { print('Focus change handling failed: $e'); }
        } else {
          context.read<ColorProvider>().resetColor();
        }
      },
    // ✅ ==========================================================
    // ✅ [UPDATED] Item onKey LOGIC
    // ✅ ==========================================================
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          final key = event.logicalKey;

          // --- हॉरिजॉन्टल मूवमेंट (लेफ्ट/राइट) के लिए थ्रॉटलिंग ---
          if (key == LogicalKeyboardKey.arrowRight ||
              key == LogicalKeyboardKey.arrowLeft) {
            if (_isNavigationLocked) return KeyEventResult.handled;

            setState(() => _isNavigationLocked = true);
            _navigationLockTimer = Timer(const Duration(milliseconds: 600), () { // Consistent duration
              if (mounted) setState(() => _isNavigationLocked = false);
            });

            if (key == LogicalKeyboardKey.arrowRight) {
              // Same View All logic as before
              if (index < maxHorizontalItems - 1 && index < channelsList.length - 1) {
                String nextChannelId = channelsList[index + 1].id.toString();
                 if (channelsFocusNodes.containsKey(nextChannelId)) {
                  FocusScope.of(context).requestFocus(channelsFocusNodes[nextChannelId]);
                 } else {
                   _navigationLockTimer?.cancel();
                   if (mounted) setState(() => _isNavigationLocked = false);
                 }
              } else if (index == maxHorizontalItems - 1 && channelsList.length > maxHorizontalItems) {
                 if (_viewAllFocusNode != null) {
                   FocusScope.of(context).requestFocus(_viewAllFocusNode);
                 } else {
                   _navigationLockTimer?.cancel();
                   if (mounted) setState(() => _isNavigationLocked = false);
                 }
              } else {
                _navigationLockTimer?.cancel();
                if (mounted) setState(() => _isNavigationLocked = false);
              }
            } else if (key == LogicalKeyboardKey.arrowLeft) {
              if (index > 0) {
                String prevChannelId = channelsList[index - 1].id.toString();
                if (channelsFocusNodes.containsKey(prevChannelId)) {
                    FocusScope.of(context).requestFocus(channelsFocusNodes[prevChannelId]);
                } else {
                   _navigationLockTimer?.cancel();
                   if (mounted) setState(() => _isNavigationLocked = false);
                }
              } else {
                _navigationLockTimer?.cancel();
                if (mounted) setState(() => _isNavigationLocked = false);
              }
            }
            return KeyEventResult.handled;
          }

          // --- वर्टिकल मूवमेंट (अप/डाउन) ---
          if (key == LogicalKeyboardKey.arrowUp) {
            // ✅ CHANGED: Use focusPreviousRow
            setState(() {
              focusedIndex = -1;
              _hasReceivedFocusFromSports = false; // Updated variable
            });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus(); // Unfocus current item
            context.read<FocusProvider>().focusPreviousRow(); // Ask provider
            return KeyEventResult.handled;
          }

          else if (key == LogicalKeyboardKey.arrowDown) {
            // ✅ CHANGED: Use focusNextRow
             setState(() {
              focusedIndex = -1;
              _hasReceivedFocusFromSports = false; // Updated variable
            });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus(); // Unfocus current item
            context.read<FocusProvider>().focusNextRow(); // Ask provider
            return KeyEventResult.handled;
          }

          else if (key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.select) {
            _navigateToChannelDetails(channel);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    // ✅ ==========================================================
    // ✅ END OF [UPDATED] onKey LOGIC
    // ✅ ==========================================================
      child: GestureDetector(
        onTap: () => _navigateToChannelDetails(channel),
        child: ProfessionalReligiousChannelCard(
          channel: channel,
          focusNode: focusNode,
          onTap: () => _navigateToChannelDetails(channel),
          onColorChange: (color) {
             if (!mounted) return; // Add mount check
            setState(() { _currentAccentColor = color; });
            context.read<ColorProvider>().updateColor(color, true);
          },
          index: index,
          categoryTitle: 'RELIGIOUS CHANNELS',
        ),
      ),
    );
  }


  Widget _buildChannelsList(double screenWidth, double screenHeight) {
    bool showViewAll = channelsList.length > maxHorizontalItems;
    int itemCount = math.min(channelsList.length, maxHorizontalItems);

    return FadeTransition(
      opacity: _listFadeAnimation,
      child: Container(
        height: screenHeight * 0.38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
          cacheExtent: 9999, // Increased cache extent
          itemCount: showViewAll ? itemCount + 1 : itemCount, // +1 for View All
          itemBuilder: (context, index) {
            if (showViewAll && index == itemCount) {
              return _buildViewAllButton(); // Show View All button at the end
            }
            var channel = channelsList[index];
            return _buildChannelItem(channel, index, screenWidth, screenHeight);
          },
        ),
      ),
    );
  }

  // View All Button Widget
  Widget _buildViewAllButton() {
     if (_viewAllFocusNode == null) return const SizedBox.shrink(); // Safety check

    return Focus(
      focusNode: _viewAllFocusNode,
      onFocusChange: (hasFocus) {
         if (!mounted) return; // Add mount check
        if (hasFocus) {
          Color viewAllColor = ProfessionalColors.gradientColors[
              math.Random()
                  .nextInt(ProfessionalColors.gradientColors.length)];
          setState(() { _currentAccentColor = viewAllColor; });
          context.read<ColorProvider>().updateColor(viewAllColor, true);
           _scrollToPosition(maxHorizontalItems); // Scroll View All into view
        } else {
          context.read<ColorProvider>().resetColor();
        }
      },
    // ✅ ==========================================================
    // ✅ [UPDATED] ViewAll onKey LOGIC
    // ✅ ==========================================================
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
           final key = event.logicalKey;

          if (key == LogicalKeyboardKey.arrowRight) {
             // Cannot move right from View All
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowLeft) {
             // Move focus to the last actual category item
             if (channelsList.isNotEmpty && channelsList.length >= maxHorizontalItems) {
               String channelId = channelsList[maxHorizontalItems - 1].id.toString();
               if (channelsFocusNodes.containsKey(channelId)) {
                  FocusScope.of(context).requestFocus(channelsFocusNodes[channelId]);
                  return KeyEventResult.handled;
               }
             }
          }

          else if (key == LogicalKeyboardKey.arrowUp) {
            // ✅ CHANGED: Use focusPreviousRow
            setState(() {
              focusedIndex = -1; // Reset index when moving vertically
              _hasReceivedFocusFromSports = false; // Updated variable
            });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            context.read<FocusProvider>().focusPreviousRow();
            return KeyEventResult.handled;
          }

          else if (key == LogicalKeyboardKey.arrowDown) {
            // ✅ CHANGED: Use focusNextRow
             setState(() {
              focusedIndex = -1; // Reset index when moving vertically
              _hasReceivedFocusFromSports = false; // Updated variable
            });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            context.read<FocusProvider>().focusNextRow();
            return KeyEventResult.handled;
          }

          else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
            _navigateToGridPage();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    // ✅ ==========================================================
    // ✅ END OF [UPDATED] onKey LOGIC
    // ✅ ==========================================================
      child: GestureDetector(
        onTap: _navigateToGridPage,
        child: ProfessionalReligiousChannelsViewAllButton(
          focusNode: _viewAllFocusNode!,
          onTap: _navigateToGridPage,
          totalItems: channelsList.length,
          itemType: 'CHANNELS', // Specific type
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
                  ProfessionalColors.accentOrange,
                  ProfessionalColors.accentRed,
                ],
              ).createShader(bounds),
              child: Text(
                'RELIGIOUS CHANNELS',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            // Refresh button can be added here
          ],
        ),
      ),
    );
  }

  Widget _buildBody(double screenWidth, double screenHeight) {
    if (isLoading) {
      return ProfessionalReligiousChannelsLoadingIndicator(
          message: 'Loading Religious Channels...');
    } else if (channelsList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildChannelsList(screenWidth, screenHeight);
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
                  ProfessionalColors.accentOrange.withOpacity(0.2),
                  ProfessionalColors.accentOrange.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.tv_outlined, // Changed icon
              size: 40,
              color: ProfessionalColors.accentOrange,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Religious Channels Found',
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new channels',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// SUPPORTING WIDGETS (Inmein koi change nahi hai)
// ==========================================================
// (ProfessionalReligiousChannelCard, ProfessionalReligiousChannelsViewAllButton, ProfessionalReligiousChannelsLoadingIndicator, etc.)
// ... (Your existing supporting widget code remains the same) ...

// ✅ Professional Religious Channel Card
class ProfessionalReligiousChannelCard extends StatefulWidget {
  final ReligiousChannelModel channel;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;
  final int index;
  final String categoryTitle;

  const ProfessionalReligiousChannelCard({
    Key? key,
    required this.channel,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalReligiousChannelCardState createState() =>
      _ProfessionalReligiousChannelCardState();
}

class _ProfessionalReligiousChannelCardState
    extends State<ProfessionalReligiousChannelCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  Color _dominantColor = ProfessionalColors.accentOrange;
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
     if (!mounted) return; // Add mount check
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
    widget.focusNode.removeListener(_handleFocusChange); // Remove listener first
    _scaleController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
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
            _buildChannelImage(screenWidth, posterHeight),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            _buildLanguageBadge(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelImage(double screenWidth, double posterHeight) {
    return Container(
      width: double.infinity,
      height: posterHeight,
      child: widget.channel.logo != null && widget.channel.logo!.isNotEmpty
          ? Image.network(
              widget.channel.logo!,
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
            Icons.radio_rounded, // Icon for religious channels
            size: height * 0.25,
            color: ProfessionalColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            'RELIGIOUS',
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
              color: ProfessionalColors.accentOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: ProfessionalColors.accentOrange,
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

  Widget _buildLanguageBadge() {
    String language = widget.channel.language.toUpperCase();
    Color badgeColor = ProfessionalColors.accentOrange;

    // Different colors for different languages
    if (language.toLowerCase().contains('hindi')) {
      badgeColor = ProfessionalColors.accentOrange;
    } else if (language.toLowerCase().contains('punjabi')) {
      badgeColor = ProfessionalColors.accentGreen;
    } else if (language.toLowerCase().contains('english')) {
      badgeColor = ProfessionalColors.accentBlue;
    } else if (language.toLowerCase().contains('urdu')) {
      badgeColor = ProfessionalColors.accentPurple;
    } else {
       badgeColor = ProfessionalColors.accentPink; // Default fallback color
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
          language,
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
    final channelName = widget.channel.name.toUpperCase();

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
          channelName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ✅ Professional View All Button for Religious Channels
class ProfessionalReligiousChannelsViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int totalItems;
  final String itemType;

  const ProfessionalReligiousChannelsViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
    required this.totalItems,
    this.itemType = 'CHANNELS',
  }) : super(key: key);

  @override
  _ProfessionalReligiousChannelsViewAllButtonState createState() =>
      _ProfessionalReligiousChannelsViewAllButtonState();
}

class _ProfessionalReligiousChannelsViewAllButtonState
    extends State<ProfessionalReligiousChannelsViewAllButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  bool _isFocused = false;
  Color _currentColor = ProfessionalColors.accentOrange;

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

   @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange); // Remove listener first
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }


  void _handleFocusChange() {
     if (!mounted) return; // Add mount check
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
                  Icons.radio_rounded, // Icon for religious channels
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

// ✅ Professional Loading Indicator for Religious Channels
class ProfessionalReligiousChannelsLoadingIndicator extends StatefulWidget {
  final String message;

  const ProfessionalReligiousChannelsLoadingIndicator({
    Key? key,
    this.message = 'Loading Religious Channels...',
  }) : super(key: key);

  @override
  _ProfessionalReligiousChannelsLoadingIndicatorState createState() =>
      _ProfessionalReligiousChannelsLoadingIndicatorState();
}

class _ProfessionalReligiousChannelsLoadingIndicatorState
    extends State<ProfessionalReligiousChannelsLoadingIndicator>
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
                      ProfessionalColors.accentOrange,
                      ProfessionalColors.accentRed,
                      ProfessionalColors.accentPink,
                      ProfessionalColors.accentOrange,
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
                    Icons.radio_rounded, // Icon for religious channels
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
                    ProfessionalColors.accentOrange,
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

// ✅ Professional Religious Channels Grid Page
class ProfessionalReligiousChannelsGridPage extends StatefulWidget {
  final List<ReligiousChannelModel> channelsList;
  final String title;

  const ProfessionalReligiousChannelsGridPage({
    Key? key,
    required this.channelsList,
    this.title = 'All Religious Channels',
  }) : super(key: key);

  @override
  _ProfessionalReligiousChannelsGridPageState createState() =>
      _ProfessionalReligiousChannelsGridPageState();
}

class _ProfessionalReligiousChannelsGridPageState
    extends State<ProfessionalReligiousChannelsGridPage>
    with TickerProviderStateMixin {
  int gridFocusedIndex = 0;
  final int columnsCount = 6;
  Map<int, FocusNode> gridFocusNodes = {};
  late ScrollController _scrollController;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _createGridFocusNodes();
    _initializeAnimations();
    _startStaggeredAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusFirstGridItem();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    _scrollController.dispose();
    for (var node in gridFocusNodes.values) {
      try {
        node.removeListener(() {}); // Remove listener before disposing
        node.dispose();
      } catch (e) {}
    }
    gridFocusNodes.clear(); // Clear the map after disposing nodes
    super.dispose();
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

  void _createGridFocusNodes() {
    for (int i = 0; i < widget.channelsList.length; i++) {
      gridFocusNodes[i] = FocusNode();
      gridFocusNodes[i]!.addListener(() {
        if (!mounted) return; // Add mount check
        if (gridFocusNodes[i]!.hasFocus) {
          setState(() => gridFocusedIndex = i); // Update focused index on focus change
          _ensureItemVisible(i);
        }
      });
    }
  }


  void _focusFirstGridItem() {
    if (gridFocusNodes.containsKey(0)) {
       if (!mounted) return; // Add mount check before setState
      setState(() {
        gridFocusedIndex = 0;
      });
      gridFocusNodes[0]!.requestFocus();
    }
  }

  void _ensureItemVisible(int index) {
    if (_scrollController.hasClients) {
      final int row = index ~/ columnsCount;
      final double itemHeight = 200.0; // Estimate or calculate item height
      final double targetOffset = row * itemHeight;

      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent), // Clamp the value
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }


  void _navigateGrid(LogicalKeyboardKey key) {
    int newIndex = gridFocusedIndex;
    final int totalItems = widget.channelsList.length;
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
         // Ensure the next index exists
        if (nextRowIndex < totalItems) {
            newIndex = nextRowIndex;
        } else {
             // Try to go to the last item if moving down from the last partially filled row
             newIndex = totalItems - 1;
        }
        break;

      case LogicalKeyboardKey.arrowUp:
        if (currentRow > 0) {
          final int prevRowIndex = (currentRow - 1) * columnsCount + currentCol;
           // The previous row index will always be valid if currentRow > 0
          newIndex = prevRowIndex;
        }
        break;
      default: // Added default case to handle other keys if necessary
          break;
    }

    if (newIndex != gridFocusedIndex &&
        newIndex >= 0 &&
        newIndex < totalItems) {
      if (!mounted) return; // Add mount check before setState
      setState(() {
        gridFocusedIndex = newIndex;
      });
      if (gridFocusNodes.containsKey(newIndex)) { // Check if node exists
          gridFocusNodes[newIndex]!.requestFocus();
      }
    }
  }


  void _navigateToChannelDetails(ReligiousChannelModel channel, int index) {
    print('📺 Grid: Navigating to Religious Channel Details: ${channel.name}');

    // Navigate to ReligiousChannelDetailsPage instead of showing dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReligiousChannelDetailsPage(
          id: channel.id,
          banner: channel.logo ?? '', // Use logo as banner if available
          poster: channel.logo ?? '', // Use logo as poster if available
          name: channel.name, updatedAt: channel.updatedAt,
        ),
      ),
    ).then((_) {
       print('🔙 Returned from Channel Details to Grid');
       Future.delayed(Duration(milliseconds: 300), () {
         if (!mounted) return; // Add mount check
        if (gridFocusNodes.containsKey(index)) {
          setState(() {
            gridFocusedIndex = index;
          });
          gridFocusNodes[index]!.requestFocus();
          print('✅ Restored grid focus to index $index');
        }
      });
     });
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
                  child: _buildGridView(),
                ),
              ],
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
        left: 40,
        right: 40,
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
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalColors.accentOrange.withOpacity(0.2),
                  ProfessionalColors.accentRed.withOpacity(0.2),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      ProfessionalColors.accentOrange,
                      ProfessionalColors.accentRed,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    widget.title,
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
                         ProfessionalColors.accentOrange.withOpacity(0.2),
                         ProfessionalColors.accentRed.withOpacity(0.1),
                       ],
                     ),
                     borderRadius: BorderRadius.circular(15),
                     border: Border.all(
                       color: ProfessionalColors.accentOrange.withOpacity(0.3),
                       width: 1,
                     ),
                   ),
                   child: Text(
                     '${widget.channelsList.length} Channels Available',
                     style: const TextStyle(
                       color: ProfessionalColors.accentOrange,
                       fontSize: 12,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                 ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    if (widget.channelsList.isEmpty) {
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
                    ProfessionalColors.accentOrange.withOpacity(0.2),
                    ProfessionalColors.accentOrange.withOpacity(0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.radio_rounded, // Icon for religious channels
                size: 40,
                color: ProfessionalColors.accentOrange,
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
              'Check back later for new channels',
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
      autofocus: true, // Autofocus the grid itself
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
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
             // Ensure focused index is valid before navigating
            if (gridFocusedIndex >= 0 && gridFocusedIndex < widget.channelsList.length) {
              _navigateToChannelDetails(
                widget.channelsList[gridFocusedIndex],
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
            childAspectRatio: 1.5, // Aspect ratio might need adjustment
          ),
          itemCount: widget.channelsList.length,
          itemBuilder: (context, index) {
            // Check if focus node exists before building the card
             if (!gridFocusNodes.containsKey(index)) {
                 return const SizedBox.shrink(); // Or a placeholder
             }
            return AnimatedBuilder(
              animation: _staggerController,
              builder: (context, child) {
                // Stagger animation calculation
                final delay = (index / widget.channelsList.length) * 0.5;
                 // Ensure delay + 0.5 does not exceed 1.0
                 final endInterval = (delay + 0.5).clamp(0.0, 1.0);
                 final startInterval = delay.clamp(0.0, endInterval); // Ensure start <= end

                final animationValue = Interval(
                   startInterval,
                   endInterval, // Use clamped end interval
                  curve: Curves.easeOutCubic,
                ).transform(_staggerController.value);

                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: ProfessionalGridReligiousChannelCard(
                      channel: widget.channelsList[index],
                      focusNode: gridFocusNodes[index]!,
                      onTap: () => _navigateToChannelDetails(
                          widget.channelsList[index], index),
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
}

// ✅ Professional Grid Religious Channel Card
class ProfessionalGridReligiousChannelCard extends StatefulWidget {
  final ReligiousChannelModel channel;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int index;
  final String categoryTitle;

  const ProfessionalGridReligiousChannelCard({
    Key? key,
    required this.channel,
    required this.focusNode,
    required this.onTap,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalGridReligiousChannelCardState createState() =>
      _ProfessionalGridReligiousChannelCardState();
}

class _ProfessionalGridReligiousChannelCardState
    extends State<ProfessionalGridReligiousChannelCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  Color _dominantColor = ProfessionalColors.accentOrange;
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

   @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange); // Remove listener first
    _hoverController.dispose();
    _glowController.dispose();
    super.dispose();
  }


  void _handleFocusChange() {
     if (!mounted) return; // Add mount check
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
  Widget build(BuildContext context) {
    return Focus( // Wrap with Focus widget to handle Enter/Select key
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
                      _buildChannelImage(),
                      if (_isFocused) _buildFocusBorder(),
                      _buildGradientOverlay(),
                      _buildChannelInfo(),
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

  Widget _buildChannelImage() {
     // Placeholder remains the same
    Widget placeholder = Container(
      width: double.infinity,
      height: double.infinity,
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
              Icons.radio_rounded, // Use the specific icon
              size: 40, // Adjust size as needed for grid
              color: ProfessionalColors.textSecondary,
            ),
             const SizedBox(height: 8),
             Text( // Optionally display name in placeholder too
               widget.channel.name.toUpperCase(),
               style: TextStyle(
                  color: ProfessionalColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
               ),
               textAlign: TextAlign.center,
               maxLines: 2,
               overflow: TextOverflow.ellipsis,
             ),
          ],
        ),
      ),
    );

    if (widget.channel.logo != null && widget.channel.logo!.isNotEmpty) {
      return Image.network(
        widget.channel.logo!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
             child: CircularProgressIndicator(
               value: loadingProgress.expectedTotalBytes != null
                   ? loadingProgress.cumulativeBytesLoaded /
                       loadingProgress.expectedTotalBytes!
                   : null,
               strokeWidth: 2,
               color: _dominantColor,
             ),
           );
        },
        errorBuilder: (context, error, stackTrace) {
           print('❌ Error loading grid channel image: ${widget.channel.logo}');
           return placeholder;
        },
      );
    } else {
      return placeholder;
    }
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

  Widget _buildChannelInfo() {
    final channelName = widget.channel.name;

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
              channelName.toUpperCase(),
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
               Row( // Use Row for multiple badges if needed
                 children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                     decoration: BoxDecoration(
                       color: ProfessionalColors.accentOrange.withOpacity(0.3), // Language color
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(
                         color: ProfessionalColors.accentOrange.withOpacity(0.5),
                         width: 1,
                       ),
                     ),
                     child: Text(
                       widget.channel.language.toUpperCase(),
                       style: const TextStyle(
                         color: ProfessionalColors.accentOrange,
                         fontSize: 8,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ),
                    // Add more badges here if needed
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