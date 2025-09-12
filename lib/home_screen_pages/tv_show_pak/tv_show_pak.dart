

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:mobi_tv_entertainment/home_screen_pages/tv_show/tv_show_second_page.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/tv_show_pak/tv_show_second_page.dart';
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

// ✅ Updated TV Show Model for Pakistani channels
class TVShowModel {
  final int id;
  final String name;
  final String? description;
  final String? logo;
  final String? language;
  final int status;
  final int order;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  TVShowModel({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    this.language,
    required this.status,
    required this.order,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory TVShowModel.fromJson(Map<String, dynamic> json) {
    return TVShowModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      logo: json['logo'],
      language: json['language'],
      status: json['status'] ?? 0,
      order: json['order'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }

  // Helper method to get channel type based on name
  String get channelType {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('drama')) return 'DRAMA';
    if (nameLower.contains('geo')) return 'GEO';
    if (nameLower.contains('ary')) return 'ARY';
    if (nameLower.contains('binge')) return 'BINGE';
    return 'CHANNEL';
  }

  // Helper method to get language display
  String get displayLanguage {
    return language?.toUpperCase() ?? 'URDU';
  }
}

// 🚀 Enhanced Pakistani TV Shows Service with Caching
class PakistaniTVShowsService {
  // Cache keys
  static const String _cacheKeyTVShows = 'cached_pak_tv_shows';
  static const String _cacheKeyTimestamp = 'cached_pak_tv_shows_timestamp';
  static const String _cacheKeyAuthKey = 'auth_key';

  // Cache duration (in milliseconds) - 1 hour
  static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

  /// Main method to get all Pakistani TV shows with caching
  static Future<List<TVShowModel>> getAllTVShows(
      {bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we should use cache
      if (!forceRefresh && await _shouldUseCache(prefs)) {
        print('📦 Loading Pakistani TV Shows from cache...');
        final cachedTVShows = await _getCachedTVShows(prefs);
        if (cachedTVShows.isNotEmpty) {
          print(
              '✅ Successfully loaded ${cachedTVShows.length} Pakistani TV shows from cache');

          // Load fresh data in background (without waiting)
          _loadFreshDataInBackground();

          return cachedTVShows;
        }
      }

      // Load fresh data if no cache or force refresh
      print('🌐 Loading fresh Pakistani TV Shows from API...');
      return await _fetchFreshTVShows(prefs);
    } catch (e) {
      print('❌ Error in getAllTVShows: $e');

      // Try to return cached data as fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedTVShows = await _getCachedTVShows(prefs);
        if (cachedTVShows.isNotEmpty) {
          print('🔄 Returning cached data as fallback');
          return cachedTVShows;
        }
      } catch (cacheError) {
        print('❌ Cache fallback also failed: $cacheError');
      }

      throw Exception('Failed to load Pakistani TV shows: $e');
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
            '📦 Pakistani TV Shows Cache is valid (${ageMinutes} minutes old)');
      } else {
        final ageMinutes = (cacheAge / (1000 * 60)).round();
        print('⏰ Pakistani TV Shows Cache expired (${ageMinutes} minutes old)');
      }

      return isValid;
    } catch (e) {
      print('❌ Error checking Pakistani TV Shows cache validity: $e');
      return false;
    }
  }

  /// Get TV shows from cache
  static Future<List<TVShowModel>> _getCachedTVShows(
      SharedPreferences prefs) async {
    try {
      final cachedData = prefs.getString(_cacheKeyTVShows);
      if (cachedData == null || cachedData.isEmpty) {
        print('📦 No cached Pakistani TV Shows data found');
        return [];
      }

      final List<dynamic> jsonData = json.decode(cachedData);
      final tvShows = jsonData
          .map((json) => TVShowModel.fromJson(json as Map<String, dynamic>))
          .where((show) =>
              show.status == 1 && show.deletedAt == null) // Filter active shows
          .toList();

      print(
          '📦 Successfully loaded ${tvShows.length} Pakistani TV shows from cache');
      return tvShows;
    } catch (e) {
      print('❌ Error loading cached Pakistani TV shows: $e');
      return [];
    }
  }

  /// Fetch fresh TV shows from API and cache them
  static Future<List<TVShowModel>> _fetchFreshTVShows(
      SharedPreferences prefs) async {
    try {
      String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';

      final response = await http.get(
        Uri.parse(
            'https://acomtv.coretechinfo.com/api/v2/getTvChannelsPak'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain': 'coretechinfo.com'
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        final allTVShows = jsonData
            .map((json) => TVShowModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Filter only active shows (status = 1 and not deleted)
        final activeTVShows = allTVShows
            .where((show) => show.status == 1 && show.deletedAt == null)
            .toList();

        // Sort by order field if available
        activeTVShows.sort((a, b) => a.order.compareTo(b.order));

        // Cache the fresh data (save all shows, but return only active ones)
        await _cacheTVShows(prefs, jsonData);

        print(
            '✅ Successfully loaded ${activeTVShows.length} active Pakistani TV shows from API (from ${allTVShows.length} total)');
        return activeTVShows;
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error fetching fresh Pakistani TV shows: $e');
      rethrow;
    }
  }

  /// Cache TV shows data
  static Future<void> _cacheTVShows(
      SharedPreferences prefs, List<dynamic> tvShowsData) async {
    try {
      final jsonString = json.encode(tvShowsData);
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Save TV shows data and timestamp
      await Future.wait([
        prefs.setString(_cacheKeyTVShows, jsonString),
        prefs.setString(_cacheKeyTimestamp, currentTimestamp),
      ]);

      print('💾 Successfully cached ${tvShowsData.length} Pakistani TV shows');
    } catch (e) {
      print('❌ Error caching Pakistani TV shows: $e');
    }
  }

  /// Load fresh data in background without blocking UI
  static void _loadFreshDataInBackground() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        print('🔄 Loading fresh Pakistani TV shows data in background...');
        final prefs = await SharedPreferences.getInstance();
        await _fetchFreshTVShows(prefs);
        print('✅ Pakistani TV Shows background refresh completed');
      } catch (e) {
        print('⚠️ Pakistani TV Shows background refresh failed: $e');
      }
    });
  }

  /// Clear all cached data
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_cacheKeyTVShows),
        prefs.remove(_cacheKeyTimestamp),
      ]);
      print('🗑️ Pakistani TV Shows cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing Pakistani TV Shows cache: $e');
    }
  }

  /// Get cache info for debugging
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString(_cacheKeyTimestamp);
      final cachedData = prefs.getString(_cacheKeyTVShows);

      if (timestampStr == null || cachedData == null) {
        return {
          'hasCachedData': false,
          'cacheAge': 0,
          'cachedTVShowsCount': 0,
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
        'cachedTVShowsCount': jsonData.length,
        'cacheSize': cacheSizeKB,
        'isValid': cacheAge < _cacheDurationMs,
      };
    } catch (e) {
      print('❌ Error getting Pakistani TV Shows cache info: $e');
      return {
        'hasCachedData': false,
        'cacheAge': 0,
        'cachedTVShowsCount': 0,
        'cacheSize': 0,
        'error': e.toString(),
      };
    }
  }

  /// Force refresh data (bypass cache)
  static Future<List<TVShowModel>> forceRefresh() async {
    print('🔄 Force refreshing Pakistani TV Shows data...');
    return await getAllTVShows(forceRefresh: true);
  }
}

// 🚀 Enhanced ProfessionalPakistaniTVShowsHorizontalList with Caching
class TvShowPak extends StatefulWidget {
  const TvShowPak({super.key});
  @override
  _TvShowPakState createState() => _TvShowPakState();
}

class _TvShowPakState extends State<TvShowPak>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  List<TVShowModel> tvShowsList = [];
  bool isLoading = true;
  int focusedIndex = -1;
  final int maxHorizontalItems = 7;
  Color _currentAccentColor = ProfessionalColors.accentGreen;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  Map<String, FocusNode> tvshowsPakFocusNodes = {};
  FocusNode? _viewAllFocusNode;
  FocusNode? _firstTVShowFocusNode;
  bool _hasReceivedFocusFromWebSeries = false;

  late ScrollController _scrollController;
  final double _itemWidth = 156.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
    _initializeFocusNodes();

    // 🚀 Use enhanced caching service for Pakistani channels
    fetchTVShowsWithCache();
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
    print('✅ Pakistani TV Shows focus nodes initialized');
  }

  void _scrollToPosition(int index) {
    if (index < tvShowsList.length && index < maxHorizontalItems) {
      String tvShowId = tvShowsList[index].id.toString();
      if (tvshowsPakFocusNodes.containsKey(tvShowId)) {
        final focusNode = tvshowsPakFocusNodes[tvShowId]!;

        Scrollable.ensureVisible(
          focusNode.context!,
          duration: AnimationTiming.scroll,
          curve: Curves.easeInOutCubic,
          alignment: 0.03,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        );

        print(
            '🎯 Scrollable.ensureVisible for index $index: ${tvShowsList[index].name}');
      }
    } else if (index == maxHorizontalItems && _viewAllFocusNode != null) {
      Scrollable.ensureVisible(
        _viewAllFocusNode!.context!,
        duration: AnimationTiming.scroll,
        curve: Curves.easeInOutCubic,
        alignment: 0.2,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );

      print('🎯 Scrollable.ensureVisible for ViewAll button');
    }
  }

  void _setupTVShowsFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && tvShowsList.isNotEmpty) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);

          final firstTVShowId = tvShowsList[0].id.toString();

          if (!tvshowsPakFocusNodes.containsKey(firstTVShowId)) {
            tvshowsPakFocusNodes[firstTVShowId] = FocusNode();
            print(
                '✅ Created focus node for first Pakistani TV show: $firstTVShowId');
          }

          _firstTVShowFocusNode = tvshowsPakFocusNodes[firstTVShowId];

          _firstTVShowFocusNode!.addListener(() {
            if (_firstTVShowFocusNode!.hasFocus &&
                !_hasReceivedFocusFromWebSeries) {
              _hasReceivedFocusFromWebSeries = true;
              setState(() {
                focusedIndex = 0;
              });
              _scrollToPosition(0);
              print(
                  '✅ Pakistani TV Shows received focus from webseries and scrolled');
            }
          });

          focusProvider.setFirstTVShowsPakFocusNode(_firstTVShowFocusNode!);
          print(
              '✅ Pakistani TV Shows first focus node registered: ${tvShowsList[0].name}');
        } catch (e) {
          print('❌ Pakistani TV Shows focus provider setup failed: $e');
        }
      }
    });
  }

  // 🚀 Enhanced fetch method with caching for Pakistani channels
  Future<void> fetchTVShowsWithCache() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Use cached data first, then fresh data
      final fetchedTVShows = await PakistaniTVShowsService.getAllTVShows();

      if (fetchedTVShows.isNotEmpty) {
        if (mounted) {
          setState(() {
            tvShowsList = fetchedTVShows;
            isLoading = false;
          });

          _createFocusNodesForItems();
          _setupTVShowsFocusProvider();

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
      print('Error fetching Pakistani TV Shows with cache: $e');
    }
  }

  // 🆕 Debug method to show cache information
  Future<void> _debugCacheInfo() async {
    try {
      final cacheInfo = await PakistaniTVShowsService.getCacheInfo();
      print('📊 Pakistani TV Shows Cache Info: $cacheInfo');
    } catch (e) {
      print('❌ Error getting Pakistani TV Shows cache info: $e');
    }
  }

  // 🆕 Force refresh TV shows
  Future<void> _forceRefreshTVShows() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Force refresh bypasses cache
      final fetchedTVShows = await PakistaniTVShowsService.forceRefresh();

      if (fetchedTVShows.isNotEmpty) {
        if (mounted) {
          setState(() {
            tvShowsList = fetchedTVShows;
            isLoading = false;
          });

          _createFocusNodesForItems();
          _setupTVShowsFocusProvider();

          _headerAnimationController.forward();
          _listAnimationController.forward();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Pakistani TV Shows refreshed successfully'),
              backgroundColor: ProfessionalColors.accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
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
      print('❌ Error force refreshing Pakistani TV shows: $e');
    }
  }

  void _createFocusNodesForItems() {
    for (var node in tvshowsPakFocusNodes.values) {
      try {
        node.removeListener(() {});
        node.dispose();
      } catch (e) {}
    }
    tvshowsPakFocusNodes.clear();

    for (int i = 0; i < tvShowsList.length && i < maxHorizontalItems; i++) {
      String tvShowId = tvShowsList[i].id.toString();
      if (!tvshowsPakFocusNodes.containsKey(tvShowId)) {
        tvshowsPakFocusNodes[tvShowId] = FocusNode();

        tvshowsPakFocusNodes[tvShowId]!.addListener(() {
          if (mounted && tvshowsPakFocusNodes[tvShowId]!.hasFocus) {
            setState(() {
              focusedIndex = i;
              _hasReceivedFocusFromWebSeries = true;
            });
            _scrollToPosition(i);
            print(
                '✅ Pakistani TV Show $i focused and scrolled: ${tvShowsList[i].name}');
          }
        });
      }
    }
    print(
        '✅ Created ${tvshowsPakFocusNodes.length} Pakistani TV show focus nodes with auto-scroll');
  }

  void _navigateToTVShowDetails(TVShowModel tvShow) {
    print('🎬 Navigating to Pakistani TV Show Details: ${tvShow.name}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TVShowsPakDetailsPage(
          tvChannelId: tvShow.id,
          channelName: tvShow.name,
          channelLogo: tvShow.logo,
        ),
      ),
    ).then((_) {
      print('🔙 Returned from Pakistani TV Show Details');
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          int currentIndex =
              tvShowsList.indexWhere((show) => show.id == tvShow.id);
          if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
            String tvShowId = tvShow.id.toString();
            if (tvshowsPakFocusNodes.containsKey(tvShowId)) {
              setState(() {
                focusedIndex = currentIndex;
                _hasReceivedFocusFromWebSeries = true;
              });
              tvshowsPakFocusNodes[tvShowId]!.requestFocus();
              _scrollToPosition(currentIndex);
              print('✅ Restored focus to ${tvShow.name}');
            }
          }
        }
      });
    });
  }

  void _navigateToGridPage() {
    print('🎬 Navigating to Pakistani TV Shows Grid Page...');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalPakistaniTVShowsGridPage(
          tvShowsList: tvShowsList,
          title: 'Pakistani TV Shows',
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ✅ ADD: Consumer to listen to color changes
    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        final bgColor = colorProvider.isItemFocused
            ? colorProvider.dominantColor.withOpacity(0.1)
            : ProfessionalColors.primaryDark;

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

  // ✅ ENHANCED: Pakistani TV Show item with color provider integration
  Widget _buildTVShowItem(
      TVShowModel tvShow, int index, double screenWidth, double screenHeight) {
    String tvShowId = tvShow.id.toString();

    tvshowsPakFocusNodes.putIfAbsent(
      tvShowId,
      () => FocusNode()
        ..addListener(() {
          if (mounted && tvshowsPakFocusNodes[tvShowId]!.hasFocus) {
            _scrollToPosition(index);
          }
        }),
    );

    return Focus(
      focusNode: tvshowsPakFocusNodes[tvShowId],
      onFocusChange: (hasFocus) async {
        if (hasFocus && mounted) {
          try {
            Color dominantColor = ProfessionalColors.gradientColors[
                math.Random()
                    .nextInt(ProfessionalColors.gradientColors.length)];

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
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (index < tvShowsList.length - 1 && index != 6) {
              String nextTVShowId = tvShowsList[index + 1].id.toString();
              FocusScope.of(context)
                  .requestFocus(tvshowsPakFocusNodes[nextTVShowId]);
              return KeyEventResult.handled;
            } else if (index == 6 && tvShowsList.length > 7) {
              FocusScope.of(context).requestFocus(_viewAllFocusNode);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              String prevTVShowId = tvShowsList[index - 1].id.toString();
              FocusScope.of(context)
                  .requestFocus(tvshowsPakFocusNodes[prevTVShowId]);
            }
              return KeyEventResult.handled;

          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            setState(() {
              focusedIndex = -1;
              _hasReceivedFocusFromWebSeries = false;
            });
            // ✅ ADD: Reset color when navigating away
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                try {
                  Provider.of<FocusProvider>(context, listen: false)
                      .requestFirstReligiousChannelFocus();
                  print(
                      '✅ Navigating back to webseries from Pakistani TV shows');
                } catch (e) {
                  print('❌ Failed to navigate to webseries: $e');
                }
              }
            });
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            setState(() {
              focusedIndex = -1;
              _hasReceivedFocusFromWebSeries = false;
            });
            // ✅ ADD: Reset color when navigating away
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                try {
                  Provider.of<FocusProvider>(context, listen: false)
                      .requestFirstSportsCategoryFocus();
                  // Navigate to next section
                  print('✅ Navigating down from Pakistani TV shows');
                } catch (e) {
                  print('❌ Failed to navigate down: $e');
                }
              }
            });
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.select) {
            print(
                '🎬 Enter pressed on ${tvShow.name} - Opening Details Page...');
            _navigateToTVShowDetails(tvShow);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _navigateToTVShowDetails(tvShow),
        child: ProfessionalPakistaniTVShowCard(
          tvShow: tvShow,
          focusNode: tvshowsPakFocusNodes[tvShowId]!,
          onTap: () => _navigateToTVShowDetails(tvShow),
          onColorChange: (color) {
            setState(() {
              _currentAccentColor = color;
            });
            // ✅ ADD: Update color provider when card changes color
            context.read<ColorProvider>().updateColor(color, true);
          },
          index: index,
          categoryTitle: 'PAKISTANI TV SHOWS',
        ),
      ),
    );
  }

  // ✅ Enhanced ViewAll focus handling with ColorProvider
  Widget _buildTVShowsList(double screenWidth, double screenHeight) {
    bool showViewAll = tvShowsList.length > 7;

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
          itemCount: showViewAll ? 8 : tvShowsList.length,
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

                    // ✅ ADD: Update color provider for ViewAll button
                    context
                        .read<ColorProvider>()
                        .updateColor(viewAllColor, true);
                  } else if (mounted) {
                    // ✅ ADD: Reset color when ViewAll loses focus
                    context.read<ColorProvider>().resetColor();
                  }
                },
                onKey: (FocusNode node, RawKeyEvent event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                      return KeyEventResult.handled;
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowLeft) {
                      if (tvShowsList.isNotEmpty && tvShowsList.length > 6) {
                        String tvShowId = tvShowsList[6].id.toString();
                        FocusScope.of(context)
                            .requestFocus(tvshowsPakFocusNodes[tvShowId]);
                        return KeyEventResult.handled;
                      }
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      setState(() {
                        focusedIndex = -1;
                        _hasReceivedFocusFromWebSeries = false;
                      });
                      // ✅ ADD: Reset color when navigating away from ViewAll
                      context.read<ColorProvider>().resetColor();
                      FocusScope.of(context).unfocus();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          try {
                            Provider.of<FocusProvider>(context, listen: false)
                                .requestFirstReligiousChannelFocus();
                            print(
                                '✅ Navigating back to webseries from Pakistani TV shows ViewAll');
                          } catch (e) {
                            print('❌ Failed to navigate to webseries: $e');
                          }
                        }
                      });
                      return KeyEventResult.handled;
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowDown) {
                      setState(() {
                        focusedIndex = -1;
                        _hasReceivedFocusFromWebSeries = false;
                      });
                      // ✅ ADD: Reset color when navigating away from ViewAll
                      context.read<ColorProvider>().resetColor();
                      FocusScope.of(context).unfocus();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          try {
                            Provider.of<FocusProvider>(context, listen: false)
                                .requestFirstSportsCategoryFocus();
                            // Navigate to next section after Pakistani TV Shows
                            print(
                                '✅ Navigating down from Pakistani TV Shows ViewAll');
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
                  child: ProfessionalPakistaniTVShowViewAllButton(
                    focusNode: _viewAllFocusNode!,
                    onTap: _navigateToGridPage,
                    totalItems: tvShowsList.length,
                    itemType: 'PAKISTANI TV SHOWS',
                  ),
                ),
              );
            }

            var tvShow = tvShowsList[index];
            return _buildTVShowItem(tvShow, index, screenWidth, screenHeight);
          },
        ),
      ),
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
                'PAKISTANI TV SHOWS',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            // Row(
            //   children: [
            //     // Pakistani TV Shows Count
            //     if (tvShowsList.length > 0)
            //       Container(
            //         padding:
            //             const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //         decoration: BoxDecoration(
            //           gradient: LinearGradient(
            //             colors: [
            //               ProfessionalColors.accentGreen.withOpacity(0.2),
            //               ProfessionalColors.accentBlue.withOpacity(0.2),
            //             ],
            //           ),
            //           borderRadius: BorderRadius.circular(20),
            //           border: Border.all(
            //             color: ProfessionalColors.accentGreen.withOpacity(0.3),
            //             width: 1,
            //           ),
            //         ),
            //         child: Text(
            //           '${tvShowsList.length} Pakistani Channels',
            //           style: const TextStyle(
            //             color: ProfessionalColors.textSecondary,
            //             fontSize: 12,
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //       ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(double screenWidth, double screenHeight) {
    if (isLoading) {
      return ProfessionalPakistaniTVShowLoadingIndicator(
          message: 'Loading Pakistani TV Shows...');
    } else if (tvShowsList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildTVShowsList(screenWidth, screenHeight);
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
            'No Pakistani TV Shows Found',
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new Pakistani channels',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();

    for (var entry in tvshowsPakFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
      } catch (e) {}
    }
    tvshowsPakFocusNodes.clear();

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
class PakistaniCacheManager {
  /// Clear all app caches
  static Future<void> clearAllCaches() async {
    try {
      await Future.wait([
        PakistaniTVShowsService.clearCache(),
        // Add other service cache clears here
        // WebSeriesService.clearCache(),
        // MoviesService.clearCache(),
      ]);
      print('🗑️ All Pakistani caches cleared successfully');
    } catch (e) {
      print('❌ Error clearing all Pakistani caches: $e');
    }
  }

  /// Get comprehensive cache info for all services
  static Future<Map<String, dynamic>> getAllCacheInfo() async {
    try {
      final pakTVShowsCacheInfo = await PakistaniTVShowsService.getCacheInfo();
      // Add other service cache info here
      // final webSeriesCacheInfo = await WebSeriesService.getCacheInfo();
      // final moviesCacheInfo = await MoviesService.getCacheInfo();

      return {
        'pakistaniTVShows': pakTVShowsCacheInfo,
        // 'webSeries': webSeriesCacheInfo,
        // 'movies': moviesCacheInfo,
        'totalCacheSize': _calculateTotalCacheSize([
          pakTVShowsCacheInfo,
          // webSeriesCacheInfo,
          // moviesCacheInfo,
        ]),
      };
    } catch (e) {
      print('❌ Error getting all Pakistani cache info: $e');
      return {
        'error': e.toString(),
        'pakistaniTVShows': {'hasCachedData': false},
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
        PakistaniTVShowsService.forceRefresh(),
        // Add other service force refreshes here
        // WebSeriesService.forceRefresh(),
        // MoviesService.forceRefresh(),
      ]);
      print('🔄 All Pakistani data force refreshed successfully');
    } catch (e) {
      print('❌ Error force refreshing all Pakistani data: $e');
    }
  }
}

// ✅ Professional Pakistani TV Show Card
class ProfessionalPakistaniTVShowCard extends StatefulWidget {
  final TVShowModel tvShow;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;
  final int index;
  final String categoryTitle;

  const ProfessionalPakistaniTVShowCard({
    Key? key,
    required this.tvShow,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalPakistaniTVShowCardState createState() =>
      _ProfessionalPakistaniTVShowCardState();
}

class _ProfessionalPakistaniTVShowCardState
    extends State<ProfessionalPakistaniTVShowCard>
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
            _buildTVShowImage(screenWidth, posterHeight),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            _buildChannelTypeBadge(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTVShowImage(double screenWidth, double posterHeight) {
    return Container(
      width: double.infinity,
      height: posterHeight,
      child: widget.tvShow.logo != null && widget.tvShow.logo!.isNotEmpty
          ? Image.network(
              widget.tvShow.logo!,
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
            Icons.live_tv_rounded,
            size: height * 0.25,
            color: ProfessionalColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            'PAKISTANI TV',
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
            child: Text(
              widget.tvShow.displayLanguage,
              style: const TextStyle(
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

  Widget _buildChannelTypeBadge() {
    String channelType = widget.tvShow.channelType;
    Color badgeColor = ProfessionalColors.accentGreen;

    // Set color based on channel type
    switch (channelType) {
      case 'DRAMA':
        badgeColor = ProfessionalColors.accentPink;
        break;
      case 'GEO':
        badgeColor = ProfessionalColors.accentBlue;
        break;
      case 'ARY':
        badgeColor = ProfessionalColors.accentOrange;
        break;
      case 'BINGE':
        badgeColor = ProfessionalColors.accentPurple;
        break;
      default:
        badgeColor = ProfessionalColors.accentGreen;
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
          channelType,
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
    final tvShowName = widget.tvShow.name.toUpperCase();

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
          tvShowName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ✅ Professional Pakistani View All Button
class ProfessionalPakistaniTVShowViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int totalItems;
  final String itemType;

  const ProfessionalPakistaniTVShowViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
    required this.totalItems,
    this.itemType = 'PAKISTANI TV SHOWS',
  }) : super(key: key);

  @override
  _ProfessionalPakistaniTVShowViewAllButtonState createState() =>
      _ProfessionalPakistaniTVShowViewAllButtonState();
}

class _ProfessionalPakistaniTVShowViewAllButtonState
    extends State<ProfessionalPakistaniTVShowViewAllButton>
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

// ✅ Professional Pakistani Loading Indicator
class ProfessionalPakistaniTVShowLoadingIndicator extends StatefulWidget {
  final String message;

  const ProfessionalPakistaniTVShowLoadingIndicator({
    Key? key,
    this.message = 'Loading Pakistani TV Shows...',
  }) : super(key: key);

  @override
  _ProfessionalPakistaniTVShowLoadingIndicatorState createState() =>
      _ProfessionalPakistaniTVShowLoadingIndicatorState();
}

class _ProfessionalPakistaniTVShowLoadingIndicatorState
    extends State<ProfessionalPakistaniTVShowLoadingIndicator>
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

// ✅ Professional Pakistani TV Shows Grid Page
class ProfessionalPakistaniTVShowsGridPage extends StatefulWidget {
  final List<TVShowModel> tvShowsList;
  final String title;

  const ProfessionalPakistaniTVShowsGridPage({
    Key? key,
    required this.tvShowsList,
    this.title = 'All Pakistani TV Shows',
  }) : super(key: key);

  @override
  _ProfessionalPakistaniTVShowsGridPageState createState() =>
      _ProfessionalPakistaniTVShowsGridPageState();
}

class _ProfessionalPakistaniTVShowsGridPageState
    extends State<ProfessionalPakistaniTVShowsGridPage>
    with TickerProviderStateMixin {
  int gridFocusedIndex = 0;
  final int columnsCount = 5;
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
    for (int i = 0; i < widget.tvShowsList.length; i++) {
      gridFocusNodes[i] = FocusNode();
      gridFocusNodes[i]!.addListener(() {
        if (gridFocusNodes[i]!.hasFocus) {
          _ensureItemVisible(i);
        }
      });
    }
  }

  void _focusFirstGridItem() {
    if (gridFocusNodes.containsKey(0)) {
      setState(() {
        gridFocusedIndex = 0;
      });
      gridFocusNodes[0]!.requestFocus();
    }
  }

  void _ensureItemVisible(int index) {
    if (_scrollController.hasClients) {
      final int row = index ~/ columnsCount;
      final double itemHeight = 200.0;
      final double targetOffset = row * itemHeight;

      _scrollController.animateTo(
        targetOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateGrid(LogicalKeyboardKey key) {
    int newIndex = gridFocusedIndex;
    final int totalItems = widget.tvShowsList.length;
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
        }
        break;

      case LogicalKeyboardKey.arrowUp:
        if (currentRow > 0) {
          final int prevRowIndex = (currentRow - 1) * columnsCount + currentCol;
          newIndex = prevRowIndex;
        }
        break;
    }

    if (newIndex != gridFocusedIndex &&
        newIndex >= 0 &&
        newIndex < totalItems) {
      setState(() {
        gridFocusedIndex = newIndex;
      });
      gridFocusNodes[newIndex]!.requestFocus();
    }
  }

  void _navigateToTVShowDetails(TVShowModel tvShow, int index) {
    print('🎬 Grid: Navigating to Pakistani TV Show Details: ${tvShow.name}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TVShowsPakDetailsPage(
          tvChannelId: tvShow.id,
          channelName: tvShow.name,
          channelLogo: tvShow.logo,
        ),
      ),
    ).then((_) {
      print('🔙 Returned from Pakistani TV Show Details to Grid');
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted && gridFocusNodes.containsKey(index)) {
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
                  ProfessionalColors.accentGreen.withOpacity(0.2),
                  ProfessionalColors.accentBlue.withOpacity(0.2),
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
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Container(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       colors: [
                //         ProfessionalColors.accentGreen.withOpacity(0.2),
                //         ProfessionalColors.accentBlue.withOpacity(0.1),
                //       ],
                //     ),
                //     borderRadius: BorderRadius.circular(15),
                //     border: Border.all(
                //       color: ProfessionalColors.accentGreen.withOpacity(0.3),
                //       width: 1,
                //     ),
                //   ),
                //   child: Text(
                //     '${widget.tvShowsList.length} Pakistani Channels Available',
                //     style: const TextStyle(
                //       color: ProfessionalColors.accentGreen,
                //       fontSize: 12,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    if (widget.tvShowsList.isEmpty) {
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
              'Check back later for new Pakistani channels',
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
            if (gridFocusedIndex < widget.tvShowsList.length) {
              _navigateToTVShowDetails(
                widget.tvShowsList[gridFocusedIndex],
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
            crossAxisCount: 6,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.5,
          ),
          itemCount: widget.tvShowsList.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _staggerController,
              builder: (context, child) {
                final delay = (index / widget.tvShowsList.length) * 0.5;
                final animationValue = Interval(
                  delay,
                  delay + 0.5,
                  curve: Curves.easeOutCubic,
                ).transform(_staggerController.value);

                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: ProfessionalGridPakistaniTVShowCard(
                      tvShow: widget.tvShowsList[index],
                      focusNode: gridFocusNodes[index]!,
                      onTap: () => _navigateToTVShowDetails(
                          widget.tvShowsList[index], index),
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
    for (var node in gridFocusNodes.values) {
      try {
        node.dispose();
      } catch (e) {}
    }
    super.dispose();
  }
}

// ✅ Professional Grid Pakistani TV Show Card
class ProfessionalGridPakistaniTVShowCard extends StatefulWidget {
  final TVShowModel tvShow;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int index;
  final String categoryTitle;

  const ProfessionalGridPakistaniTVShowCard({
    Key? key,
    required this.tvShow,
    required this.focusNode,
    required this.onTap,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalGridPakistaniTVShowCardState createState() =>
      _ProfessionalGridPakistaniTVShowCardState();
}

class _ProfessionalGridPakistaniTVShowCardState
    extends State<ProfessionalGridPakistaniTVShowCard>
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
                      _buildTVShowImage(),
                      if (_isFocused) _buildFocusBorder(),
                      _buildGradientOverlay(),
                      _buildTVShowInfo(),
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

  Widget _buildTVShowImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: widget.tvShow.logo != null && widget.tvShow.logo!.isNotEmpty
          ? Image.network(
              widget.tvShow.logo!,
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
              Icons.live_tv_outlined,
              size: 40,
              color: ProfessionalColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              'PAKISTANI TV',
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
              child: Text(
                widget.tvShow.displayLanguage,
                style: const TextStyle(
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

  Widget _buildTVShowInfo() {
    final tvShowName = widget.tvShow.name;

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
              tvShowName.toUpperCase(),
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
                      color: ProfessionalColors.accentGreen.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ProfessionalColors.accentGreen.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.tvShow.channelType,
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
                      widget.tvShow.displayLanguage,
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
