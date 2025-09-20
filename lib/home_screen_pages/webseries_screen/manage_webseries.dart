import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/services/history_service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:ui';

/*
  Ye code istemal karne se pehle, ye dependencies aapke pubspec.yaml file mein honi chahiye:
 
  dependencies:
    flutter:
      sdk: flutter
    provider: ^6.0.0
    http: ^1.0.0
    shared_preferences: ^2.0.0
    cached_network_image: ^3.2.0
*/

// ✅ Professional Color Palette
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

// ✅ WebSeries Model (series_order ke saath)
class WebSeriesModel {
  final int id;
  final String name;
  final String updatedAt;
  final String? description;
  final String? poster;
  final String? banner;
  final String? releaseDate;
  final String? genres;
  final int seriesOrder; // ✅ FIX: series_order add kiya gaya

  WebSeriesModel({
    required this.id,
    required this.name,
    required this.updatedAt,
    this.description,
    this.poster,
    this.banner,
    this.releaseDate,
    this.genres,
    required this.seriesOrder, // ✅ FIX: series_order add kiya gaya
  });

  factory WebSeriesModel.fromJson(Map<String, dynamic> json) {
    return WebSeriesModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      description: json['description'],
      poster: json['poster'],
      banner: json['banner'],
      releaseDate: json['release_date'],
      genres: json['genres'],
      seriesOrder:
          json['series_order'] ?? 9999, // ✅ FIX: series_order parse kiya gaya
    );
  }
}

// 🚀 Enhanced WebSeries Service with Caching and Sorting
class WebSeriesService {
  static const String _cacheKeyWebSeries = 'cached_web_series';
  static const String _cacheKeyTimestamp = 'cached_web_series_timestamp';
  static const String _cacheKeyAuthKey = 'auth_key';
  static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

  static Future<List<WebSeriesModel>> getAllWebSeries(
      {bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!forceRefresh && await _shouldUseCache(prefs)) {
        print('📦 Loading Web Series from cache...');
        final cachedWebSeries = await _getCachedWebSeries(prefs);
        if (cachedWebSeries.isNotEmpty) {
          _loadFreshDataInBackground();
          return cachedWebSeries;
        }
      }
      print('🌐 Loading fresh Web Series from API...');
      return await _fetchFreshWebSeries(prefs);
    } catch (e) {
      print('❌ Error in getAllWebSeries: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedWebSeries = await _getCachedWebSeries(prefs);
        if (cachedWebSeries.isNotEmpty) {
          print('🔄 Returning cached data as fallback');
          return cachedWebSeries;
        }
      } catch (cacheError) {
        print('❌ Cache fallback also failed: $cacheError');
      }
      throw Exception('Failed to load web series: $e');
    }
  }

  static Future<bool> _shouldUseCache(SharedPreferences prefs) async {
    try {
      final timestampStr = prefs.getString(_cacheKeyTimestamp);
      if (timestampStr == null) return false;
      final cachedTimestamp = int.tryParse(timestampStr);
      if (cachedTimestamp == null) return false;
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      return (currentTimestamp - cachedTimestamp) < _cacheDurationMs;
    } catch (e) {
      print('❌ Error checking WebSeries cache validity: $e');
      return false;
    }
  }

  static Future<List<WebSeriesModel>> _getCachedWebSeries(
      SharedPreferences prefs) async {
    try {
      final cachedData = prefs.getString(_cacheKeyWebSeries);
      if (cachedData == null || cachedData.isEmpty) return [];
      final List<dynamic> jsonData = json.decode(cachedData);
      List<WebSeriesModel> webSeries = jsonData
          .map((json) => WebSeriesModel.fromJson(json as Map<String, dynamic>))
          .toList();
      // ✅ FIX: Cache se load karte waqt bhi sort karein
      webSeries.sort((a, b) => a.seriesOrder.compareTo(b.seriesOrder));
      return webSeries;
    } catch (e) {
      print('❌ Error loading cached web series: $e');
      return [];
    }
  }

  static Future<List<WebSeriesModel>> _fetchFreshWebSeries(
      SharedPreferences prefs) async {
    try {
      String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';
      final response = await http.get(
        Uri.parse('https://dashboard.cpplayers.com/api/v2/getAllWebSeries'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain': 'coretechinfo.com'
        },
      );
      // .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        await _cacheWebSeries(prefs, jsonData);
        List<WebSeriesModel> webSeries = jsonData
            .map(
                (json) => WebSeriesModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // ✅ FIX: API se fetch karne ke baad data ko series_order se sort kiya gaya
        webSeries.sort((a, b) => a.seriesOrder.compareTo(b.seriesOrder));

        return webSeries;
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error fetching fresh web series: $e');
      rethrow;
    }
  }

  static Future<void> _cacheWebSeries(
      SharedPreferences prefs, List<dynamic> webSeriesData) async {
    try {
      final jsonString = json.encode(webSeriesData);
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await Future.wait([
        prefs.setString(_cacheKeyWebSeries, jsonString),
        prefs.setString(_cacheKeyTimestamp, currentTimestamp),
      ]);
      print('💾 Successfully cached ${webSeriesData.length} web series');
    } catch (e) {
      print('❌ Error caching web series: $e');
    }
  }

  static void _loadFreshDataInBackground() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        print('🔄 Loading fresh web series data in background...');
        final prefs = await SharedPreferences.getInstance();
        await _fetchFreshWebSeries(prefs);
        print('✅ WebSeries background refresh completed');
      } catch (e) {
        print('⚠️ WebSeries background refresh failed: $e');
      }
    });
  }

  static Future<List<WebSeriesModel>> forceRefresh() async {
    print('🔄 Force refreshing WebSeries data...');
    return await getAllWebSeries(forceRefresh: true);
  }
}

// 🚀 Enhanced ProfessionalWebSeriesHorizontalList
class ProfessionalWebSeriesHorizontalList extends StatefulWidget {
  const ProfessionalWebSeriesHorizontalList({super.key});
  @override
  _ProfessionalWebSeriesHorizontalListState createState() =>
      _ProfessionalWebSeriesHorizontalListState();
}

class _ProfessionalWebSeriesHorizontalListState
    extends State<ProfessionalWebSeriesHorizontalList>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  List<WebSeriesModel> webSeriesList = [];
  bool isLoading = true;
  int focusedIndex = -1;
  final int maxHorizontalItems = 7;

  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  Map<String, FocusNode> webseriesFocusNodes = {};
  FocusNode? _viewAllFocusNode;
  FocusNode? _firstWebSeriesFocusNode;
  bool _hasReceivedFocusFromMovies = false;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
    _initializeFocusNodes();
    fetchWebSeriesWithCache();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    for (var node in webseriesFocusNodes.values) {
      node.dispose();
    }
    webseriesFocusNodes.clear();
    _viewAllFocusNode?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _headerAnimationController =
        AnimationController(duration: AnimationTiming.slow, vsync: this);
    _listAnimationController =
        AnimationController(duration: AnimationTiming.slow, vsync: this);
    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _headerAnimationController,
                curve: Curves.easeOutCubic));
    _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _listAnimationController, curve: Curves.easeInOut));
  }

  void _initializeFocusNodes() {
    _viewAllFocusNode = FocusNode();
  }

  void _scrollToPosition(int index) {
    if (!mounted || !_scrollController.hasClients) return;
    try {
      double bannerwidth = bannerwdt;
      double scrollPosition = index * bannerwidth;
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } catch (e) {
      print('Error scrolling in webseries: $e');
    }
  }

  void _setupFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && webSeriesList.isNotEmpty) {
        final focusProvider =
            Provider.of<FocusProvider>(context, listen: false);
        final firstWebSeriesId = webSeriesList[0].id.toString();
        webseriesFocusNodes.putIfAbsent(firstWebSeriesId, () => FocusNode());
        _firstWebSeriesFocusNode = webseriesFocusNodes[firstWebSeriesId];
        _firstWebSeriesFocusNode?.addListener(() {
          if (_firstWebSeriesFocusNode!.hasFocus &&
              !_hasReceivedFocusFromMovies) {
            _hasReceivedFocusFromMovies = true;
            setState(() => focusedIndex = 0);
            _scrollToPosition(0);
          }
        });
        focusProvider
            .setFirstManageWebseriesFocusNode(_firstWebSeriesFocusNode!);
      }
    });
  }

  Future<void> fetchWebSeriesWithCache() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final fetchedWebSeries = await WebSeriesService.getAllWebSeries();
      if (mounted) {
        setState(() {
          webSeriesList = fetchedWebSeries;
          isLoading = false;
        });
        _createFocusNodesForItems();
        _setupFocusProvider();
        _headerAnimationController.forward();
        _listAnimationController.forward();
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      print('Error fetching WebSeries with cache: $e');
    }
  }

  void _createFocusNodesForItems() {
    for (var node in webseriesFocusNodes.values) {
      node.dispose();
    }
    webseriesFocusNodes.clear();
    for (int i = 0; i < webSeriesList.length && i < maxHorizontalItems; i++) {
      String webSeriesId = webSeriesList[i].id.toString();
      webseriesFocusNodes[webSeriesId] = FocusNode();
      webseriesFocusNodes[webSeriesId]!.addListener(() {
        if (mounted && webseriesFocusNodes[webSeriesId]!.hasFocus) {
          setState(() {
            focusedIndex = i;
            _hasReceivedFocusFromMovies = true;
          });
          _scrollToPosition(i);
        }
      });
    }
  }

  void _navigateToWebSeriesDetails(WebSeriesModel webSeries) async {
    try {
      print('Updating user history for: ${webSeries.name}');
      int? currentUserId = SessionManager.userId;
      // final int? parsedContentType = episode.contentType;
      final int? parsedId = webSeries.id;

      await HistoryService.updateUserHistory(
        userId: currentUserId!, // 1. User ID
        contentType: 2, // 2. Content Type (episode के लिए 4)
        eventId: parsedId!, // 3. Event ID (episode की ID)
        eventTitle: webSeries.name, // 4. Event Title (episode का नाम)
        url: '', // 5. URL (episode का URL)
        categoryId: 0, // 6. Category ID (डिफ़ॉल्ट 1)
      );
    } catch (e) {
      print("History update failed, but proceeding to play. Error: $e");
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebSeriesDetailsPage(
          id: webSeries.id,
          banner: webSeries.banner ?? webSeries.poster ?? '',
          poster: webSeries.poster ?? webSeries.banner ?? '',
          logo: webSeries.poster ?? webSeries.banner ?? '',
          name: webSeries.name,
          updatedAt: webSeries.updatedAt,
        ),
      ),
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          int currentIndex =
              webSeriesList.indexWhere((ws) => ws.id == webSeries.id);
          if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
            String webSeriesId = webSeries.id.toString();
            if (webseriesFocusNodes.containsKey(webSeriesId)) {
              setState(() {
                focusedIndex = currentIndex;
                _hasReceivedFocusFromMovies = true;
              });
              webseriesFocusNodes[webSeriesId]!.requestFocus();
              _scrollToPosition(currentIndex);
            }
          }
        }
      });
    });
  }

  void _navigateToGridPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalWebSeriesGridPage(
          webSeriesList: webSeriesList,
          title: 'All Web Series',
        ),
      ),
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _viewAllFocusNode != null) {
          setState(() {
            focusedIndex = maxHorizontalItems;
            _hasReceivedFocusFromMovies = true;
          });
          _viewAllFocusNode!.requestFocus();
          _scrollToPosition(maxHorizontalItems);
        }
      });
    });
  }

  // BUILD METHOD and WIDGETS
  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                const SizedBox(height: 20),
                _buildProfessionalTitle(),
                const SizedBox(height: 10),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalTitle() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  ProfessionalColors.accentPurple,
                  ProfessionalColors.accentBlue
                ],
              ).createShader(bounds),
              child: const Text(
                'WEB SERIES',
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0),
              ),
            ),
            // if (webSeriesList.isNotEmpty)
            //   Container(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(colors: [
            //         ProfessionalColors.accentPurple.withOpacity(0.2),
            //         ProfessionalColors.accentBlue.withOpacity(0.2),
            //       ]),
            //       borderRadius: BorderRadius.circular(20),
            //       border: Border.all(
            //           color: ProfessionalColors.accentPurple.withOpacity(0.3),
            //           width: 1),
            //     ),
            //     child: Text(
            //       '${webSeriesList.length} Series Available',
            //       style: const TextStyle(
            //           color: ProfessionalColors.textSecondary,
            //           fontSize: 12,
            //           fontWeight: FontWeight.w500),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const ProfessionalWebSeriesLoadingIndicator(
          message: 'Loading Web Series...');
    } else if (webSeriesList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildWebSeriesList();
    }
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tv_off_outlined,
              size: 50, color: ProfessionalColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'No Web Series Found',
            style: TextStyle(
                color: ProfessionalColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Please check back later.',
            style: TextStyle(
                color: ProfessionalColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildWebSeriesList() {
    bool showViewAll = webSeriesList.length > 7;
    return FadeTransition(
      opacity: _listFadeAnimation,
      child: SizedBox(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: showViewAll ? 8 : webSeriesList.length,
          itemBuilder: (context, index) {
            if (showViewAll && index == 7) {
              return _buildViewAllButton();
            }
            var webSeries = webSeriesList[index];
            return _buildWebSeriesItem(webSeries, index);
          },
        ),
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Focus(
      focusNode: _viewAllFocusNode,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            FocusScope.of(context).requestFocus(
                webseriesFocusNodes[webSeriesList[6].id.toString()]);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            // Right arrow dabane par focus ko yahin roke rakhein
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            Provider.of<FocusProvider>(context, listen: false)
                .requestFirstMoviesFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            Provider.of<FocusProvider>(context, listen: false)
                .requestFirstTVShowsFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            _navigateToGridPage();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _navigateToGridPage,
        child: ProfessionalWebSeriesViewAllButton(
          focusNode: _viewAllFocusNode!,
          onTap: _navigateToGridPage,
          totalItems: webSeriesList.length,
        ),
      ),
    );
  }

  Widget _buildWebSeriesItem(WebSeriesModel webSeries, int index) {
    String webSeriesId = webSeries.id.toString();
    FocusNode? focusNode = webseriesFocusNodes[webSeriesId];

    if (focusNode == null) return const SizedBox.shrink();

    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          Color dominantColor = ProfessionalColors.gradientColors[
              math.Random().nextInt(ProfessionalColors.gradientColors.length)];
          context.read<ColorProvider>().updateColor(dominantColor, true);
        } else {
          context.read<ColorProvider>().resetColor();
        }
      },
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (index < 6 && index < webSeriesList.length - 1) {
              FocusScope.of(context).requestFocus(
                  webseriesFocusNodes[webSeriesList[index + 1].id.toString()]);
            } else if (index == 6 && webSeriesList.length > 7) {
              FocusScope.of(context).requestFocus(_viewAllFocusNode);
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              FocusScope.of(context).requestFocus(
                  webseriesFocusNodes[webSeriesList[index - 1].id.toString()]);
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Provider.of<FocusProvider>(context, listen: false)
                .requestFirstMoviesFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Provider.of<FocusProvider>(context, listen: false)
                .requestFirstTVShowsFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            _navigateToWebSeriesDetails(webSeries);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _navigateToWebSeriesDetails(webSeries),
        child: ProfessionalWebSeriesCard(
          webSeries: webSeries,
          focusNode: focusNode,
          onTap: () => _navigateToWebSeriesDetails(webSeries),
        ),
      ),
    );
  }
}

// // =========================================================================
// // GRID PAGE - CRASH FIX AND PERFORMANCE OPTIMIZATION
// // =========================================================================
// class ProfessionalWebSeriesGridPage extends StatefulWidget {
//   final List<WebSeriesModel> webSeriesList;
//   final String title;

//   const ProfessionalWebSeriesGridPage({
//     Key? key,
//     required this.webSeriesList,
//     this.title = 'All Web Series',
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesGridPageState createState() =>
//       _ProfessionalWebSeriesGridPageState();
// }

// class _ProfessionalWebSeriesGridPageState
//     extends State<ProfessionalWebSeriesGridPage>
//     with SingleTickerProviderStateMixin {
//   // ✅ FIX: _itemFocusNodes ko late se initialize kiya jayega.
//   // Isse humein crash se bachne mein madad milegi.
//   late List<FocusNode> _itemFocusNodes;
//   final FocusNode _widgetFocusNode = FocusNode();
//   final ScrollController _scrollController = ScrollController();

//   int focusedIndex = 0;
//   bool _isVideoLoading = false;
//   static const int _itemsPerRow = 6;

//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // ✅ FIX: Ab hum saare focus nodes ek saath nahi banayenge.
//     _itemFocusNodes = List.generate(
//       widget.webSeriesList.length,
//       (index) => FocusNode(),
//     );

//     _initializeAnimations();
//     _startAnimations();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && _itemFocusNodes.isNotEmpty) {
//         _itemFocusNodes[focusedIndex].requestFocus();
//       }
//     });
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//         duration: const Duration(milliseconds: 400), vsync: this);
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
//   }

//   void _startAnimations() {
//     _fadeController.forward();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _widgetFocusNode.dispose();
//     _scrollController.dispose();

//     for (var node in _itemFocusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   void _handleKeyNavigation(RawKeyEvent event) {
//     if (event is! RawKeyDownEvent ||
//         _isVideoLoading ||
//         widget.webSeriesList.isEmpty) return;

//     final totalItems = widget.webSeriesList.length;
//     int previousIndex = focusedIndex;

//     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       if (focusedIndex >= _itemsPerRow) {
//         setState(() => focusedIndex -= _itemsPerRow);
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       if (focusedIndex < totalItems - _itemsPerRow) {
//         setState(
//             () => focusedIndex = math.min(focusedIndex + _itemsPerRow, totalItems - 1));
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       if (focusedIndex % _itemsPerRow != 0) {
//         setState(() => focusedIndex--);
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//       if (focusedIndex % _itemsPerRow != _itemsPerRow - 1 &&
//           focusedIndex < totalItems - 1) {
//         setState(() => focusedIndex++);
//       }
//     } else if (event.logicalKey == LogicalKeyboardKey.select ||
//         event.logicalKey == LogicalKeyboardKey.enter) {
//       _navigateToWebSeriesDetails(
//           widget.webSeriesList[focusedIndex], focusedIndex);
//     }

//     if (previousIndex != focusedIndex) {
//       _updateAndScrollToFocus();
//       HapticFeedback.lightImpact();
//     }
//   }

//   void _safeSetState(VoidCallback fn) {
//     if (mounted) {
//       setState(fn);
//     }
//   }

//   void _updateAndScrollToFocus() {
//     if (!mounted || focusedIndex >= _itemFocusNodes.length) return;

//     final focusNode = _itemFocusNodes[focusedIndex];
//     focusNode.requestFocus();

//     // Ensure the widget is visible on screen
//     Scrollable.ensureVisible(
//       focusNode.context!,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOutCubic,
//       alignment: 0.3,
//     );
//   }

//   Future<void> _navigateToWebSeriesDetails(WebSeriesModel webSeries, int index) async {
//     if (_isVideoLoading) return;

//     _safeSetState(() => _isVideoLoading = true);

//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => WebSeriesDetailsPage(
//           id: webSeries.id,
//           banner: webSeries.banner ?? webSeries.poster ?? '',
//           poster: webSeries.poster ?? '',
//           name: webSeries.name,
//         ),
//       ),
//     );

//     if (mounted) {
//       _safeSetState(() {
//         _isVideoLoading = false;
//         focusedIndex = index;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           _updateAndScrollToFocus();
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               ProfessionalColors.primaryDark,
//               ProfessionalColors.surfaceDark.withOpacity(0.8),
//               ProfessionalColors.primaryDark,
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 _buildProfessionalAppBar(),
//                 Expanded(
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: RawKeyboardListener(
//                       focusNode: _widgetFocusNode,
//                       onKey: _handleKeyNavigation,
//                       autofocus: false,
//                       child: _buildContent(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (_isVideoLoading)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.7),
//                   child: const Center(
//                     child: ProfessionalWebSeriesLoadingIndicator(
//                         message: 'Loading Details...'),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalAppBar() {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(
//             bottom: BorderSide(
//                 color: ProfessionalColors.accentPurple.withOpacity(0.3),
//                 width: 1)),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 15,
//               offset: const Offset(0, 3))
//         ],
//       ),
//       child: ClipRRect(
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
//           child: Container(
//             padding: EdgeInsets.only(
//               top: MediaQuery.of(context).padding.top + 15,
//               left: 40,
//               right: 40,
//               bottom: 15,
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(colors: [
//                       ProfessionalColors.accentPurple.withOpacity(0.4),
//                       ProfessionalColors.accentBlue.withOpacity(0.4),
//                     ]),
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.arrow_back_rounded,
//                         color: Colors.white, size: 24),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ShaderMask(
//                         shaderCallback: (bounds) => const LinearGradient(
//                           colors: [
//                             ProfessionalColors.accentPurple,
//                             ProfessionalColors.accentBlue
//                           ],
//                         ).createShader(bounds),
//                         child: Text(
//                           widget.title.toUpperCase(),
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.w700,
//                               letterSpacing: 1.0),
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(colors: [
//                             ProfessionalColors.accentPurple.withOpacity(0.4),
//                             ProfessionalColors.accentBlue.withOpacity(0.3),
//                           ]),
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(
//                               color: ProfessionalColors.accentPurple
//                                   .withOpacity(0.6),
//                               width: 1),
//                         ),
//                         child: Text(
//                           '${widget.webSeriesList.length} Web Series Available',
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildContent() {
//     if (widget.webSeriesList.isEmpty) {
//       return const Center(
//         child: Text(
//           'No Web Series Found',
//           style: TextStyle(color: ProfessionalColors.textSecondary, fontSize: 18),
//         ),
//       );
//     } else {
//       return _buildGridView();
//     }
//   }

//   Widget _buildGridView() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: GridView.builder(
//         controller: _scrollController,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: _itemsPerRow,
//           crossAxisSpacing: 15.0,
//           mainAxisSpacing: 15.0,
//           childAspectRatio: 1.5,
//         ),
//         clipBehavior: Clip.none,
//         itemCount: widget.webSeriesList.length,
//         itemBuilder: (context, index) {
//           return Focus(
//             focusNode: _itemFocusNodes[index],
//             child: OptimizedWebSeriesGridCard(
//               webSeries: widget.webSeriesList[index],
//               isFocused: focusedIndex == index,
//               onTap: () => _navigateToWebSeriesDetails(
//                   widget.webSeriesList[index], index),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// ... (Your existing code for imports, models, services, etc.)

// =========================================================================
// GRID PAGE - CRASH FIX AND PERFORMANCE OPTIMIZATION
// =========================================================================
class ProfessionalWebSeriesGridPage extends StatefulWidget {
  final List<WebSeriesModel> webSeriesList;
  final String title;

  const ProfessionalWebSeriesGridPage({
    Key? key,
    required this.webSeriesList,
    this.title = 'All Web Series',
  }) : super(key: key);

  @override
  _ProfessionalWebSeriesGridPageState createState() =>
      _ProfessionalWebSeriesGridPageState();
}

class _ProfessionalWebSeriesGridPageState
    extends State<ProfessionalWebSeriesGridPage>
    with SingleTickerProviderStateMixin {
  late List<FocusNode> _itemFocusNodes;
  final FocusNode _widgetFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  int focusedIndex = 0;
  bool _isVideoLoading = false;
  static const int _itemsPerRow = 6;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    print(
        "GridPage initState: webSeriesList length = ${widget.webSeriesList.length}");
    _initializeAnimations();
    _startAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ FIX: Initialize focus nodes here to ensure widget.webSeriesList is available
    _itemFocusNodes = List.generate(
      widget.webSeriesList.length,
      (index) => FocusNode(),
    );
    print(
        "GridPage didChangeDependencies: _itemFocusNodes length = ${_itemFocusNodes.length}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _itemFocusNodes.isNotEmpty) {
        _itemFocusNodes[focusedIndex].requestFocus();
      }
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
  }

  void _startAnimations() {
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _widgetFocusNode.dispose();
    _scrollController.dispose();

    for (var node in _itemFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleKeyNavigation(RawKeyEvent event) {
    if (event is! RawKeyDownEvent ||
        _isVideoLoading ||
        widget.webSeriesList.isEmpty) return;

    final totalItems = widget.webSeriesList.length;
    int previousIndex = focusedIndex;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (focusedIndex >= _itemsPerRow) {
        setState(() => focusedIndex -= _itemsPerRow);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (focusedIndex < totalItems - _itemsPerRow) {
        setState(() => focusedIndex =
            math.min(focusedIndex + _itemsPerRow, totalItems - 1));
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (focusedIndex % _itemsPerRow != 0) {
        setState(() => focusedIndex--);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (focusedIndex % _itemsPerRow != _itemsPerRow - 1 &&
          focusedIndex < totalItems - 1) {
        setState(() => focusedIndex++);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.enter) {
      _navigateToWebSeriesDetails(
          widget.webSeriesList[focusedIndex], focusedIndex);
    }

    if (previousIndex != focusedIndex) {
      _updateAndScrollToFocus();
      HapticFeedback.lightImpact();
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  void _updateAndScrollToFocus() {
    if (!mounted || focusedIndex >= _itemFocusNodes.length) return;

    final focusNode = _itemFocusNodes[focusedIndex];
    focusNode.requestFocus();

    // Ensure the widget is visible on screen
    Scrollable.ensureVisible(
      focusNode.context!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      alignment: 0.3,
    );
  }

  Future<void> _navigateToWebSeriesDetails(
      WebSeriesModel webSeries, int index) async {
    if (_isVideoLoading) return;

    _safeSetState(() => _isVideoLoading = true);

    try {
      print('Updating user history for: ${webSeries.name}');
      int? currentUserId = SessionManager.userId;
      // final int? parsedContentType = episode.contentType;
      final int? parsedId = webSeries.id;

      await HistoryService.updateUserHistory(
        userId: currentUserId!, // 1. User ID
        contentType: 2, // 2. Content Type (episode के लिए 4)
        eventId: parsedId!, // 3. Event ID (episode की ID)
        eventTitle: webSeries.name, // 4. Event Title (episode का नाम)
        url: '', // 5. URL (episode का URL)
        categoryId: 0, // 6. Category ID (डिफ़ॉल्ट 1)
      );
    } catch (e) {
      print("History update failed, but proceeding to play. Error: $e");
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebSeriesDetailsPage(
          id: webSeries.id,
          banner: webSeries.banner ?? webSeries.poster ?? '',
          poster: webSeries.poster ?? webSeries.banner ?? '',
          logo: webSeries.poster ?? webSeries.banner ?? '',
          name: webSeries.name,
          updatedAt: webSeries.updatedAt,
        ),
      ),
    );

    if (mounted) {
      _safeSetState(() {
        _isVideoLoading = false;
        focusedIndex = index;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateAndScrollToFocus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Container(
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
            Column(
              children: [
                _buildProfessionalAppBar(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: RawKeyboardListener(
                      focusNode: _widgetFocusNode,
                      onKey: _handleKeyNavigation,
                      autofocus: true,
                      child: _buildContent(),
                    ),
                  ),
                ),
              ],
            ),
            if (_isVideoLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: ProfessionalWebSeriesLoadingIndicator(
                        message: 'Loading Details...'),
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
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: ProfessionalColors.accentPurple.withOpacity(0.3),
                width: 1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 3))
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 15,
              left: 40,
              right: 40,
              bottom: 15,
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      ProfessionalColors.accentPurple.withOpacity(0.4),
                      ProfessionalColors.accentBlue.withOpacity(0.4),
                    ]),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 24),
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
                            ProfessionalColors.accentPurple,
                            ProfessionalColors.accentBlue
                          ],
                        ).createShader(bounds),
                        child: Text(
                          widget.title.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 12, vertical: 6),
                      //   decoration: BoxDecoration(
                      //     gradient: LinearGradient(colors: [
                      //       ProfessionalColors.accentPurple.withOpacity(0.4),
                      //       ProfessionalColors.accentBlue.withOpacity(0.3),
                      //     ]),
                      //     borderRadius: BorderRadius.circular(15),
                      //     border: Border.all(
                      //         color: ProfessionalColors.accentPurple
                      //             .withOpacity(0.6),
                      //         width: 1),
                      //   ),
                      //   child: Text(
                      //     '${widget.webSeriesList.length} Web Series Available',
                      //     style: const TextStyle(
                      //         color: Colors.white,
                      //         fontSize: 12,
                      //         fontWeight: FontWeight.w600),
                      //   ),
                      // ),
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

  Widget _buildContent() {
    if (widget.webSeriesList.isEmpty) {
      return const Center(
        child: Text(
          'No Web Series Found',
          style:
              TextStyle(color: ProfessionalColors.textSecondary, fontSize: 18),
        ),
      );
    } else {
      return _buildGridView();
    }
  }

  Widget _buildGridView() {
    print(
        "Building GridView with ${_itemFocusNodes.length} focus nodes and ${widget.webSeriesList.length} items.");
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _itemsPerRow,
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15.0,
          childAspectRatio: 1.5,
        ),
        clipBehavior: Clip.none,
        itemCount: widget.webSeriesList.length,
        itemBuilder: (context, index) {
          if (index >= _itemFocusNodes.length) {
            // Safety check
            print(
                "Error: Index $index is out of bounds for _itemFocusNodes with length ${_itemFocusNodes.length}");
            return const SizedBox.shrink();
          }
          return Focus(
            focusNode: _itemFocusNodes[index],
            child: OptimizedWebSeriesGridCard(
              webSeries: widget.webSeriesList[index],
              isFocused: focusedIndex == index,
              onTap: () => _navigateToWebSeriesDetails(
                  widget.webSeriesList[index], index),
            ),
          );
        },
      ),
    );
  }
}

// ... (Rest of your code for supporting widgets)

// =========================================================================
// SUPPORTING WIDGETS (CARDS, BUTTONS, INDICATORS)
// =========================================================================

class ProfessionalWebSeriesCard extends StatefulWidget {
  final WebSeriesModel webSeries;
  final FocusNode focusNode;
  final VoidCallback onTap;

  const ProfessionalWebSeriesCard({
    Key? key,
    required this.webSeries,
    required this.focusNode,
    required this.onTap,
  }) : super(key: key);

  @override
  _ProfessionalWebSeriesCardState createState() =>
      _ProfessionalWebSeriesCardState();
}

class _ProfessionalWebSeriesCardState extends State<ProfessionalWebSeriesCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  Color _dominantColor = ProfessionalColors.accentBlue;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _scaleController =
        AnimationController(duration: AnimationTiming.slow, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() => _isFocused = widget.focusNode.hasFocus);
    if (_isFocused) {
      _scaleController.forward();
      _dominantColor = ProfessionalColors.gradientColors[
          math.Random().nextInt(ProfessionalColors.gradientColors.length)];
      HapticFeedback.lightImpact();
    } else {
      _scaleController.reverse();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: bannerwdt,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfessionalPoster(),
                _buildProfessionalTitle(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalPoster() {
    final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;
    return Container(
      height: posterHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: _isFocused ? Border.all(color: _dominantColor, width: 3) : null,
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: _dominantColor.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 3,
              offset: const Offset(0, 8),
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            _buildWebSeriesImage(posterHeight),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebSeriesImage(double posterHeight) {
    final String uniqueImageUrl =
        "${widget.webSeries.banner}?v=${widget.webSeries.updatedAt}";
    // ✅ Naya unique cache key banayein
    final String uniqueCacheKey =
        "${widget.webSeries.id.toString()}_${widget.webSeries.updatedAt}";
    return SizedBox(
      width: double.infinity,
      height: posterHeight,
      child: widget.webSeries.banner != null &&
              widget.webSeries.banner!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: uniqueImageUrl,
              fit: BoxFit.cover,
              memCacheHeight: 300,
              cacheKey: uniqueCacheKey,
              placeholder: (context, url) => _buildImagePlaceholder(),
              errorWidget: (context, url, error) => _buildImagePlaceholder(),
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
          colors: [ProfessionalColors.cardDark, ProfessionalColors.surfaceDark],
        ),
      ),
      child: const Center(
        child: Icon(Icons.tv_outlined,
            size: 40, color: ProfessionalColors.textSecondary),
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
            colors: [Colors.transparent, _dominantColor.withOpacity(0.1)],
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
            ),
            child:
                Icon(Icons.play_arrow_rounded, color: _dominantColor, size: 30),
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalTitle() {
    return SizedBox(
      width: bannerwdt,
      child: AnimatedDefaultTextStyle(
        duration: AnimationTiming.medium,
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11,
          fontWeight: FontWeight.w600,
          color: _isFocused ? _dominantColor : ProfessionalColors.textPrimary,
          letterSpacing: 0.5,
        ),
        child: Text(
          widget.webSeries.name.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class OptimizedWebSeriesGridCard extends StatelessWidget {
  final WebSeriesModel webSeries;
  final bool isFocused;
  final VoidCallback onTap;

  const OptimizedWebSeriesGridCard({
    Key? key,
    required this.webSeries,
    required this.isFocused,
    required this.onTap,
  }) : super(key: key);

  Color _getDominantColor() {
    final colors = ProfessionalColors.gradientColors;
    return colors[math.Random(webSeries.id).nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    final dominantColor = _getDominantColor();
    return AnimatedContainer(
      duration: AnimationTiming.fast,
      transform:
          isFocused ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: isFocused ? Border.all(color: dominantColor, width: 3) : null,
        boxShadow: [
          if (isFocused)
            BoxShadow(
              color: dominantColor.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildWebSeriesImage(),
            _buildGradientOverlay(),
            _buildWebSeriesInfo(dominantColor),
            if (isFocused) _buildPlayButton(dominantColor),
          ],
        ),
      ),
    );
  }

  Widget _buildWebSeriesImage() {
    final imageUrl = webSeries.banner ?? webSeries.poster;
    final String uniqueImageUrl = "${imageUrl}?v=${webSeries.updatedAt}";
    // ✅ Naya unique cache key banayein
    final String uniqueCacheKey =
        "${webSeries.id.toString()}_${webSeries.updatedAt}";
    return imageUrl != null && imageUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: uniqueImageUrl,
            fit: BoxFit.cover,
            memCacheHeight: 300,
            cacheKey: uniqueCacheKey,
            placeholder: (context, url) => _buildImagePlaceholder(),
            errorWidget: (context, url, error) => _buildImagePlaceholder(),
          )
        : _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: ProfessionalColors.cardDark,
      child: const Center(
        child: Icon(Icons.tv_outlined,
            size: 40, color: ProfessionalColors.textSecondary),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black54, Colors.black87],
            stops: [0.4, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildWebSeriesInfo(Color dominantColor) {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: Text(
        webSeries.name.toUpperCase(),
        style: TextStyle(
          color: isFocused ? dominantColor : Colors.white,
          fontSize: isFocused ? 13 : 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPlayButton(Color dominantColor) {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dominantColor.withOpacity(0.9),
        ),
        child:
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}

class ProfessionalWebSeriesViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int totalItems;

  const ProfessionalWebSeriesViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
    required this.totalItems,
  }) : super(key: key);

  @override
  _ProfessionalWebSeriesViewAllButtonState createState() =>
      _ProfessionalWebSeriesViewAllButtonState();
}

class _ProfessionalWebSeriesViewAllButtonState
    extends State<ProfessionalWebSeriesViewAllButton> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: bannerwdt,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          AnimatedContainer(
            duration: AnimationTiming.fast,
            height: _isFocused ? focussedBannerhgt : bannerhgt,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: _isFocused
                  ? Border.all(color: ProfessionalColors.accentPurple, width: 3)
                  : null,
              gradient: const LinearGradient(
                colors: [
                  ProfessionalColors.cardDark,
                  ProfessionalColors.surfaceDark
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.grid_view_rounded,
                    size: 35,
                    color: _isFocused
                        ? ProfessionalColors.accentPurple
                        : Colors.white),
                const SizedBox(height: 8),
                Text('VIEW ALL',
                    style: TextStyle(
                        color: _isFocused
                            ? ProfessionalColors.accentPurple
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 6),
                // Text('${widget.totalItems}',
                //     style: const TextStyle(
                //         color: ProfessionalColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: AnimationTiming.medium,
            style: TextStyle(
              fontSize: _isFocused ? 13 : 11,
              fontWeight: FontWeight.w600,
              color: _isFocused
                  ? ProfessionalColors.accentPurple
                  : ProfessionalColors.textPrimary,
            ),
            child: const Text('ALL SERIES', textAlign: TextAlign.center),
          )
        ],
      ),
    );
  }
}

class ProfessionalWebSeriesLoadingIndicator extends StatelessWidget {
  final String message;
  const ProfessionalWebSeriesLoadingIndicator({Key? key, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
              color: ProfessionalColors.accentPurple),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
                color: ProfessionalColors.textPrimary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
