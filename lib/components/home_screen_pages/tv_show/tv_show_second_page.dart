import 'dart:convert';
import 'package:http/http.dart' as https;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/manage_tv_shows.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_final_details_page.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ IMPORT करें TvShowFinalDetailsPage

// ✅ ADD: Cache Manager Class
class TVShowCacheManager {
  static const String _cacheKeyPrefix = 'tv_shows_cache_';
  static const String _timestampPrefix = 'tv_shows_timestamp_';
  static const Duration _cacheValidDuration = Duration(hours: 1);

  static String _getCacheKey(int tvChannelId) => '$_cacheKeyPrefix$tvChannelId';
  static String _getTimestampKey(int tvChannelId) =>
      '$_timestampPrefix$tvChannelId';

  static Future<void> saveToCache(
      int tvChannelId, List<TVShowDetailsModel> tvShows) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = tvShows
          .map((show) => {
                'id': show.id,
                'name': show.name,
                'thumbnail': show.thumbnail,
                'genre': show.genre,
                'description': show.description,
                'tv_channel_id': show.tvChannelId,
                'release_date': show.releaseDate,
                'status': show.status,
                'order': show.order,
                'created_at': show.createdAt,
                'updated_at': show.updatedAt,
              })
          .toList();

      await prefs.setString(_getCacheKey(tvChannelId), json.encode(jsonData));
      await prefs.setInt(
          _getTimestampKey(tvChannelId), DateTime.now().millisecondsSinceEpoch);
      print('✅ Cache saved for channel $tvChannelId');
    } catch (e) {
      print('❌ Error saving to cache: $e');
    }
  }

  static Future<List<TVShowDetailsModel>?> loadFromCache(
      int tvChannelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_getCacheKey(tvChannelId));

      if (cachedData == null) return null;

      final List<dynamic> jsonData = json.decode(cachedData);
      return jsonData.map((item) => TVShowDetailsModel.fromJson(item)).toList();
    } catch (e) {
      print('❌ Error loading from cache: $e');
      return null;
    }
  }

  static bool hasDataChanged(
      List<TVShowDetailsModel> oldList, List<TVShowDetailsModel> newList) {
    if (oldList.length != newList.length) return true;

    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i].id != newList[i].id ||
          oldList[i].name != newList[i].name ||
          oldList[i].updatedAt != newList[i].updatedAt) {
        return true;
      }
    }
    return false;
  }
}

class TVShowDetailsModel {
  final int id;
  final String name;
  final String? thumbnail;
  final String? genre;
  final String? description;
  final int tvChannelId;
  final String? releaseDate;
  final int status;
  final int order;
  final String? createdAt;
  final String? updatedAt;

  TVShowDetailsModel({
    required this.id,
    required this.name,
    this.thumbnail,
    this.genre,
    this.description,
    required this.tvChannelId,
    this.releaseDate,
    required this.status,
    required this.order,
    this.createdAt,
    this.updatedAt,
  });

  factory TVShowDetailsModel.fromJson(Map<String, dynamic> json) {
    return TVShowDetailsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      thumbnail: json['thumbnail'],
      genre: json['genre'],
      description: json['description'],
      tvChannelId: json['tv_channel_id'] ?? 0,
      releaseDate: json['release_date'],
      status: json['status'] ?? 0,
      order: json['order'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class TVShowDetailsPage extends StatefulWidget {
  final int tvChannelId;
  final String channelName;
  final String? channelLogo;

  const TVShowDetailsPage({
    Key? key,
    required this.tvChannelId,
    required this.channelName,
    this.channelLogo,
  }) : super(key: key);

  @override
  _TVShowDetailsPageState createState() => _TVShowDetailsPageState();
}

// 1. CLASS DECLARATION (keep exactly as is - no mixins added)
class _TVShowDetailsPageState extends State<TVShowDetailsPage>
    with TickerProviderStateMixin {
  List<TVShowDetailsModel> tvShowsList = [];
  bool isLoading = true;
  bool isBackgroundRefreshing = false; // ✅ Keep this variable
  String? errorMessage;
  int gridFocusedIndex = 0;
  final int columnsCount = 6;
  Map<int, FocusNode> gridFocusNodes = {};
  late ScrollController _scrollController;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late AnimationController _headerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

// 2. CLEAN initState (remove any WidgetsBinding.instance.addObserver)
  @override
  void initState() {
    super.initState();
    // ❌ REMOVE this line if present: WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _initializeAnimations();
    _startAnimations();
    _loadDataWithCache(); // ✅ Use cache loading

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _focusFirstGridItem();
    // });
  }

// 3. CLEAN dispose (remove any WidgetsBinding.instance.removeObserver)
  @override
  void dispose() {
    // ❌ REMOVE this line if present: WidgetsBinding.instance.removeObserver(this);
    _fadeController.dispose();
    _staggerController.dispose();
    _headerController.dispose();
    _scrollController.dispose();
    for (var node in gridFocusNodes.values) {
      try {
        node.dispose();
      } catch (e) {}
    }
    super.dispose();
  }

// 4. ❌ REMOVE any didChangeAppLifecycleState method completely

// 5. ✅ ADD: Simple async navigation method
  Future<void> _onTVShowSelected(TVShowDetailsModel tvShow) async {
    print('🎬 Selected TV Show: ${tvShow.name}');
    HapticFeedback.mediumImpact();

    try {
      print('Updating user history for: ${tvShow.name}');
      int? currentUserId = SessionManager.userId;
      final int? parsedId = tvShow.id;

      await HistoryService.updateUserHistory(
        userId: currentUserId!, // 1. User ID
        contentType: 4, // 2. Content Type (channel के लिए 4)
        eventId: parsedId!, // 3. Event ID (channel की ID)
        eventTitle: tvShow.name, // 4. Event Title (channel का नाम)
        url: '', // 5. URL (channel का URL)
        categoryId: 0, // 6. Category ID (डिफ़ॉल्ट 1)
      );
    } catch (e) {
      print("History update failed, but proceeding to play. Error: $e");
    }

    // ✅ Navigate and wait for return
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TvShowFinalDetailsPage(
          id: tvShow.id,
          banner: tvShow.thumbnail ?? '',
          poster: tvShow.thumbnail ?? '',
          name: tvShow.name,
        ),
      ),
    );

    // ✅ Refresh when user returns
    print('🔄 User returned, refreshing data...');
    // _loadDataWithCache();
  }

// ✅ SOLUTION: Focus पहले banner/card पर आने के लिए ये changes करें

// 1. ✅ UPDATE: _focusFirstGridItem method को improve करें
  void _focusFirstGridItem() {
    if (tvShowsList.isNotEmpty && gridFocusNodes.containsKey(0)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          gridFocusedIndex = 0;
        });

        // Focus को explicitly request करें
        if (mounted && gridFocusNodes[0] != null) {
          gridFocusNodes[0]!.requestFocus();
          print('✅ Focus set to first TV show card');
        }
      });
    }
  }

// 2. ✅ UPDATE: _createGridFocusNodes method में focus callback add करें
  void _createGridFocusNodes() {
    // Clear existing focus nodes
    for (var node in gridFocusNodes.values) {
      try {
        node.dispose();
      } catch (e) {}
    }
    gridFocusNodes.clear();

    for (int i = 0; i < tvShowsList.length; i++) {
      gridFocusNodes[i] = FocusNode();
      gridFocusNodes[i]!.addListener(() {
        if (gridFocusNodes[i]!.hasFocus) {
          setState(() {
            gridFocusedIndex = i; // ✅ ADD: Update focused index
          });
          _ensureItemVisible(i);
        }
      });
    }

    // ✅ ADD: First item को focus करें
    if (tvShowsList.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusFirstGridItem();
      });
    }
  }

// 3. ✅ UPDATE: _loadDataWithCache method में proper focus timing
  Future<void> _loadDataWithCache() async {
    print('🔄 Loading data with cache for channel ${widget.tvChannelId}');

    final cachedData =
        await TVShowCacheManager.loadFromCache(widget.tvChannelId);

    if (cachedData != null && cachedData.isNotEmpty) {
      setState(() {
        tvShowsList = cachedData;
        isLoading = false;
        errorMessage = null;
      });

      // ✅ IMPORTANT: पहले focus nodes create करें, फिर focus set करें
      _createGridFocusNodes();
      _staggerController.forward();
      print('✅ Cached data displayed instantly');

      // Background refresh
      _refreshDataInBackground();
    } else {
      // No cache, load from API
      fetchTVShowsDetails();
    }
  }

// 4. ✅ UPDATE: fetchTVShowsDetails method में भी proper focus
  Future<void> fetchTVShowsDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      String authKey = prefs.getString('result_auth_key') ?? '';

      final response = await https.get(
        Uri.parse(
            'https://dashboard.cpplayers.com/api/v2/getTvShows/${widget.tvChannelId}'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain': 'coretechinfo.com'
        },
      );

      print('🔍 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final shows =
            jsonData.map((item) => TVShowDetailsModel.fromJson(item)).toList();

        // ✅ Save to cache
        await TVShowCacheManager.saveToCache(widget.tvChannelId, shows);

        setState(() {
          tvShowsList = shows;
          isLoading = false;
        });

        if (tvShowsList.isNotEmpty) {
          // ✅ IMPORTANT: Focus nodes create करने के बाद animation start करें
          _createGridFocusNodes();
          _staggerController.forward();
          print('✅ Successfully loaded ${tvShowsList.length} TV shows');
        } else {
          setState(() {
            errorMessage = 'No TV shows found for this channel';
          });
        }
      } else {
        throw Exception('Failed to load TV shows: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading TV shows: $e';
      });
      print('❌ Error fetching TV shows: $e');
    }
  }

// 5. ✅ UPDATE: _buildGridView में autofocus को handle करें
  Widget _buildGridView() {
    return Focus(
      autofocus: true, // ✅ KEEP: This ensures main focus container gets focus
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
            if (gridFocusedIndex < tvShowsList.length) {
              _onTVShowSelected(tvShowsList[gridFocusedIndex]);
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnsCount,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.5,
          ),
          itemCount: tvShowsList.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _staggerController,
              builder: (context, child) {
                final delay = (index / tvShowsList.length) * 0.5;
                final animationValue = Interval(
                  delay,
                  delay + 0.5,
                  curve: Curves.easeOutCubic,
                ).transform(_staggerController.value);

                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: TVShowDetailsCard(
                      tvShow: tvShowsList[index],
                      focusNode: gridFocusNodes[index]!,
                      onTap: () => _onTVShowSelected(tvShowsList[index]),
                      index: index,
                      isFocused: gridFocusedIndex == index,
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

// 6. ✅ OPTIONAL: Page resume पर भी focus restore करें
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ ADD: जब page visible हो तो focus restore करें
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && tvShowsList.isNotEmpty && gridFocusNodes.containsKey(0)) {
        if (!gridFocusNodes.values.any((node) => node.hasFocus)) {
          _focusFirstGridItem();
        }
      }
    });
  }

/* 
✅ SUMMARY OF CHANGES:

1. _focusFirstGridItem() को improve किया
2. _createGridFocusNodes() में automatic focus set करने का logic add किया
3. Data load होने के बाद proper timing पर focus set करने का logic
4. Page resume पर focus restore करने का logic
5. initState से duplicate focus call हटाया

ये changes करने के बाद:
- Page load होते ही पहला TV show card focused होगा
- Visual focus indicator (border, glow) दिखेगा
- Navigation keys से proper movement होगी
- Page return पर भी focus restore होगा

*/

// // 6. ✅ ADD: Cache loading method
// Future<void> _loadDataWithCache() async {
//   print('🔄 Loading data with cache for channel ${widget.tvChannelId}');

//   final cachedData = await TVShowCacheManager.loadFromCache(widget.tvChannelId);

//   if (cachedData != null && cachedData.isNotEmpty) {
//     setState(() {
//       tvShowsList = cachedData;
//       isLoading = false;
//       errorMessage = null;
//     });

//     _createGridFocusNodes();
//     _staggerController.forward();
//     print('✅ Cached data displayed instantly');

//     // Background refresh
//     _refreshDataInBackground();
//   } else {
//     // No cache, load from API
//     fetchTVShowsDetails();
//   }
// }

// 7. ✅ ADD: Background refresh method
  Future<void> _refreshDataInBackground() async {
    if (isBackgroundRefreshing) return;

    setState(() {
      isBackgroundRefreshing = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String authKey = prefs.getString('result_auth_key') ?? '';

      final response = await https.get(
        Uri.parse(
            'https://dashboard.cpplayers.com/api/v2/getTvShows/${widget.tvChannelId}'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain': 'coretechinfo.com'
        },
      );

      print('🔍 Background API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final newData =
            jsonData.map((item) => TVShowDetailsModel.fromJson(item)).toList();

        final hasChanged =
            TVShowCacheManager.hasDataChanged(tvShowsList, newData);

        if (hasChanged) {
          print('📱 Data changed, updating UI and cache');

          await TVShowCacheManager.saveToCache(widget.tvChannelId, newData);

          // Preserve current user focus
          final currentFocusedIndex = gridFocusedIndex;

          setState(() {
            tvShowsList = newData;
          });

          _createGridFocusNodes();

          // Restore focus if possible
          if (currentFocusedIndex < tvShowsList.length) {
            setState(() {
              gridFocusedIndex = currentFocusedIndex;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (gridFocusNodes.containsKey(currentFocusedIndex)) {
                gridFocusNodes[currentFocusedIndex]!.requestFocus();
              }
            });
          }

          // _showDataUpdatedIndicator();
        } else {
          print('✅ No changes detected in background refresh');
        }
      }
    } catch (e) {
      print('❌ Background refresh failed: $e');
    } finally {
      setState(() {
        isBackgroundRefreshing = false;
      });
    }
  }

// // 8. ✅ REPLACE: Enhanced fetchTVShowsDetails method
// Future<void> fetchTVShowsDetails() async {
//   try {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     final prefs = await SharedPreferences.getInstance();
//     String authKey = prefs.getString('result_auth_key') ?? '';

//     final response = await https.get(
//       Uri.parse('https://dashboard.cpplayers.com/public/api/getTvShows/${widget.tvChannelId}'),
//       headers: {
//         'auth-key': authKey,
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     );

//     print('🔍 API Response Status: ${response.statusCode}');
//     print('🔍 API Response Body: ${response.body}');

//     if (response.statusCode == 200) {
//       final List<dynamic> jsonData = json.decode(response.body);
//       final shows = jsonData.map((item) => TVShowDetailsModel.fromJson(item)).toList();

//       // ✅ Save to cache
//       await TVShowCacheManager.saveToCache(widget.tvChannelId, shows);

//       setState(() {
//         tvShowsList = shows;
//         isLoading = false;
//       });

//       if (tvShowsList.isNotEmpty) {
//         _createGridFocusNodes();
//         _staggerController.forward();
//         print('✅ Successfully loaded ${tvShowsList.length} TV shows');
//       } else {
//         setState(() {
//           errorMessage = 'No TV shows found for this channel';
//         });
//       }
//     } else {
//       throw Exception('Failed to load TV shows: ${response.statusCode}');
//     }
//   } catch (e) {
//     setState(() {
//       isLoading = false;
//       errorMessage = 'Error loading TV shows: $e';
//     });
//     print('❌ Error fetching TV shows: $e');
//   }
// }

// // 9. ✅ ADD: Update indicator method
// void _showDataUpdatedIndicator() {
//   if (mounted) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Row(
//           children: [
//             Icon(Icons.refresh, color: Colors.white, size: 16),
//             SizedBox(width: 8),
//             Text('TV shows updated', style: TextStyle(fontSize: 12)),
//           ],
//         ),
//         backgroundColor: ProfessionalColors.accentGreen.withOpacity(0.8),
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
// }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _headerController.forward();
    _fadeController.forward();
  }

  // // ✅ REPLACE: Main cache loading method
  // Future<void> _loadDataWithCache() async {
  //   print('🔄 Loading data with cache for channel ${widget.tvChannelId}');

  //   final cachedData =
  //       await TVShowCacheManager.loadFromCache(widget.tvChannelId);

  //   if (cachedData != null && cachedData.isNotEmpty) {
  //     setState(() {
  //       tvShowsList = cachedData;
  //       isLoading = false;
  //       errorMessage = null;
  //     });

  //     _createGridFocusNodes();
  //     _staggerController.forward();
  //     print('✅ Cached data displayed instantly');

  //     _refreshDataInBackground();
  //   } else {
  //     await _fetchFromAPI(showLoading: true);
  //   }
  // }

  // // ✅ ADD: Background refresh method
  // Future<void> _refreshDataInBackground() async {
  //   if (isBackgroundRefreshing) return;

  //   setState(() {
  //     isBackgroundRefreshing = true;
  //   });

  //   try {
  //     final newData = await _fetchTVShowsFromAPI();

  //     if (newData != null) {
  //       final hasChanged =
  //           TVShowCacheManager.hasDataChanged(tvShowsList, newData);

  //       if (hasChanged) {
  //         await TVShowCacheManager.saveToCache(widget.tvChannelId, newData);

  //         setState(() {
  //           tvShowsList = newData;
  //         });

  //         _createGridFocusNodes();
  //         _showDataUpdatedIndicator();
  //       }
  //     }
  //   } catch (e) {
  //     print('❌ Background refresh failed: $e');
  //   } finally {
  //     setState(() {
  //       isBackgroundRefreshing = false;
  //     });
  //   }
  // }

  // // ✅ ADD: API fetch method
  // Future<List<TVShowDetailsModel>?> _fetchTVShowsFromAPI() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     String authKey = prefs.getString('result_auth_key') ?? '';

  //     final response = await https.get(
  //       Uri.parse(
  //           'https://dashboard.cpplayers.com/public/api/getTvShows/${widget.tvChannelId}'),
  //       headers: {
  //         'auth-key': authKey,
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> jsonData = json.decode(response.body);
  //       return jsonData
  //           .map((item) => TVShowDetailsModel.fromJson(item))
  //           .toList();
  //     } else {
  //       throw Exception('Failed to load TV shows: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('❌ API fetch error: $e');
  //     return null;
  //   }
  // }

  // // ✅ REPLACE: Updated fetch method
  // Future<void> _fetchFromAPI({bool showLoading = false}) async {
  //   if (showLoading) {
  //     setState(() {
  //       isLoading = true;
  //       errorMessage = null;
  //     });
  //   }

  //   try {
  //     final newData = await _fetchTVShowsFromAPI();

  //     if (newData != null) {
  //       await TVShowCacheManager.saveToCache(widget.tvChannelId, newData);

  //       setState(() {
  //         tvShowsList = newData;
  //         isLoading = false;
  //       });

  //       if (tvShowsList.isNotEmpty) {
  //         _createGridFocusNodes();
  //         _staggerController.forward();
  //       } else {
  //         setState(() {
  //           errorMessage = 'No TV shows found for this channel';
  //         });
  //       }
  //     } else {
  //       throw Exception('Failed to fetch data from API');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //       errorMessage = 'Error loading TV shows: $e';
  //     });
  //   }
  // }

  // // ✅ ADD: Update indicator method
  // void _showDataUpdatedIndicator() {
  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Row(
  //           children: [
  //             Icon(Icons.refresh, color: Colors.white, size: 16),
  //             SizedBox(width: 8),
  //             Text('Content updated', style: TextStyle(fontSize: 12)),
  //           ],
  //         ),
  //         backgroundColor: ProfessionalColors.accentGreen.withOpacity(0.8),
  //         duration: const Duration(seconds: 2),
  //         behavior: SnackBarBehavior.floating,
  //         margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //       ),
  //     );
  //   }
  // }

  // void _createGridFocusNodes() {
  //   // Clear existing focus nodes
  //   for (var node in gridFocusNodes.values) {
  //     try {
  //       node.dispose();
  //     } catch (e) {}
  //   }
  //   gridFocusNodes.clear();

  //   for (int i = 0; i < tvShowsList.length; i++) {
  //     gridFocusNodes[i] = FocusNode();
  //     gridFocusNodes[i]!.addListener(() {
  //       if (gridFocusNodes[i]!.hasFocus) {
  //         _ensureItemVisible(i);
  //       }
  //     });
  //   }
  // }

  // void _focusFirstGridItem() {
  //   if (gridFocusNodes.containsKey(0)) {
  //     setState(() {
  //       gridFocusedIndex = 0;
  //     });
  //     gridFocusNodes[0]!.requestFocus();
  //   }
  // }

  void _ensureItemVisible(int index) {
    if (_scrollController.hasClients) {
      final int row = index ~/ columnsCount;
      final double itemHeight = 280.0; // Adjusted for TV show cards
      final double targetOffset = row * itemHeight;

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateGrid(LogicalKeyboardKey key) {
    int newIndex = gridFocusedIndex;
    final int totalItems = tvShowsList.length;
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

  // void _onTVShowSelected(TVShowDetailsModel tvShow) {
  //   print('🎬 Selected TV Show: ${tvShow.name}');
  //   HapticFeedback.mediumImpact();

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => TvShowFinalDetailsPage(
  //         id: tvShow.id,
  //         banner: tvShow.thumbnail ?? '',
  //         poster: tvShow.thumbnail ?? '',
  //         name: tvShow.name,
  //       ),
  //     ),
  //   );
  // }

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
                _buildHeader(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),

          // ✅ ADD: Background refresh indicator
          if (isBackgroundRefreshing)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ProfessionalColors.accentGreen.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Updating',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
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
                      widget.channelName,
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
                  //     '${tvShowsList.length} Shows Available',
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
            // Container(
            //         padding:
            //             const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            //         decoration: BoxDecoration(
            //           gradient: LinearGradient(
            //             colors: [
            //               ProfessionalColors.accentGreen.withOpacity(0.2),
            //               ProfessionalColors.accentBlue.withOpacity(0.1),
            //             ],
            //           ),
            //           borderRadius: BorderRadius.circular(15),
            //           border: Border.all(
            //             color: ProfessionalColors.accentGreen.withOpacity(0.3),
            //             width: 1,
            //           ),
            //         ),
            //         child: Text(
            //           '${tvShowsList.length} Shows Available',
            //           style: const TextStyle(
            //             color: ProfessionalColors.accentGreen,
            //             fontSize: 12,
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //       ),
            if (widget.channelLogo != null)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: ProfessionalColors.accentGreen.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: Image.network(
                    widget.channelLogo!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ProfessionalColors.accentGreen,
                            ProfessionalColors.accentBlue,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.live_tv,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const ProfessionalTVShowNetworkLoadingIndicator(
        message: 'Loading TV Shows...',
      );
    } else if (errorMessage != null) {
      return _buildErrorWidget();
    } else if (tvShowsList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildGridView();
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
              Icons.error_outline,
              size: 40,
              color: ProfessionalColors.accentRed,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Error Loading TV Shows',
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Unknown error occurred',
            style: const TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchTVShowsDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfessionalColors.accentGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
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
            'No Shows Found for ${widget.channelName}',
            style: const TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
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

//   Widget _buildGridView() {
//     return Focus(
//       autofocus: true,
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent) {
//           // if (event.logicalKey == LogicalKeyboardKey.escape ||
//           //     event.logicalKey == LogicalKeyboardKey.goBack) {
//           //   Navigator.pop(context);
//           //   return KeyEventResult.handled;
//           // }
//           //  else
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
//             if (gridFocusedIndex < tvShowsList.length) {
//               _onTVShowSelected(tvShowsList[gridFocusedIndex]);
//             }
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: GridView.builder(
//           controller: _scrollController,
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 6,
//             crossAxisSpacing: 15,
//             mainAxisSpacing: 15,
//             childAspectRatio: 1.5,
//           ),
//           itemCount: tvShowsList.length,
//           itemBuilder: (context, index) {
//             return AnimatedBuilder(
//               animation: _staggerController,
//               builder: (context, child) {
//                 final delay = (index / tvShowsList.length) * 0.5;
//                 final animationValue = Interval(
//                   delay,
//                   delay + 0.5,
//                   curve: Curves.easeOutCubic,
//                 ).transform(_staggerController.value);

//                 return Transform.translate(
//                   offset: Offset(0, 50 * (1 - animationValue)),
//                   child: Opacity(
//                     opacity: animationValue,
//                     child: TVShowDetailsCard(
//                       tvShow: tvShowsList[index],
//                       focusNode: gridFocusNodes[index]!,
//                       onTap: () => _onTVShowSelected(tvShowsList[index]),
//                       index: index,
//                       isFocused: gridFocusedIndex == index,
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
}

// ✅ TV Show Details Card (यह unchanged रहेगा)
class TVShowDetailsCard extends StatefulWidget {
  final TVShowDetailsModel tvShow;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int index;
  final bool isFocused;

  const TVShowDetailsCard({
    Key? key,
    required this.tvShow,
    required this.focusNode,
    required this.onTap,
    required this.index,
    required this.isFocused,
  }) : super(key: key);

  @override
  _TVShowDetailsCardState createState() => _TVShowDetailsCardState();
}

class _TVShowDetailsCardState extends State<TVShowDetailsCard>
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
      child:
          widget.tvShow.thumbnail != null && widget.tvShow.thumbnail!.isNotEmpty
              ? Image.network(
                  widget.tvShow.thumbnail!,
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
              'TV SHOW',
              style: TextStyle(
                color: ProfessionalColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
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
            if (_isFocused && widget.tvShow.genre != null) ...[
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
                      widget.tvShow.genre!.split(',').first.toUpperCase(),
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
