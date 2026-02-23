






import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/genre_movies_screen.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_loading_widget.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_retry_widget.dart';
import 'dart:math' as math;
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
// ✅ Import Smart Widgets
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

// ✅ ==========================================================
// DATA PARSING
// ==========================================================
List<HorizontalVodModel> _parseAndSortVod(String jsonString) {
  final List<dynamic> jsonData = json.decode(jsonString);
  final vodList = jsonData
      .map((json) => HorizontalVodModel.fromJson(json as Map<String, dynamic>))
      .where((show) => show.status == 1)
      .toList()
    ..sort((a, b) => a.networks_order.compareTo(b.networks_order));
  return vodList;
}

enum LoadingState { initial, loading, rebuilding, loaded, error }

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

// ✅ Image Helpers
Widget displayImage(String imageUrl, {double? width, double? height, BoxFit fit = BoxFit.fill}) {
  if (imageUrl.isEmpty || imageUrl == 'localImage' || imageUrl.contains('localhost')) return _buildImgError(width, height);
  if (imageUrl.startsWith('data:image')) {
    try {
      Uint8List imageBytes = base64Decode(imageUrl.split(',').last);
      return Image.memory(imageBytes, fit: fit, width: width, height: height, errorBuilder: (c, e, s) => _buildImgError(width, height));
    } catch (e) { return _buildImgError(width, height); }
  } else if (imageUrl.startsWith('http')) {
    if (imageUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(imageUrl, width: width, height: height, fit: fit, placeholderBuilder: (c) => _buildImgLoader(width, height));
    } else {
      return Image.network(imageUrl, width: width, height: height, fit: fit, headers: const {'User-Agent': 'Flutter App'}, loadingBuilder: (c, child, progress) => progress == null ? child : _buildImgLoader(width, height), errorBuilder: (c, e, s) => _buildImgError(width, height));
    }
  } else { return _buildImgError(width, height); }
}
Widget _buildImgLoader(double? width, double? height) => SizedBox(width: width, height: height, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))));
Widget _buildImgError(double? width, double? height) => Container(width: width, height: height, decoration: const BoxDecoration(gradient: LinearGradient(colors: [ProfessionalColorsForHomePages.accentGreen, ProfessionalColorsForHomePages.accentBlue])), child: const Icon(Icons.broken_image, color: Colors.white, size: 24));


// ✅ ==========================================================
// VOD SERVICE
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
    if (DateTime.now().difference(cacheTime) > _cacheValidity) return null;
    return prefs.getString(_cacheKeyHorizontalVod);
  }

  static Future<String> fetchAndCacheRawData() async {
    final prefs = await SharedPreferences.getInstance();
    String authKey = SessionManager.authKey;
    var url = Uri.parse(SessionManager.baseUrl + 'getNetworks');
    final response = await https.post(url, headers: {'auth-key': authKey, 'Content-Type': 'application/json', 'Accept': 'application/json', 'domain': SessionManager.savedDomain}, body: json.encode({"network_id" :"" ,"data_for" : ""})).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final rawData = response.body;
      await prefs.setString(_cacheKeyHorizontalVod, rawData);
      await prefs.setString(_cacheKeyTimestamp, DateTime.now().toIso8601String());
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

class _HorzontalVodState extends State<HorzontalVod> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  LoadingState _loadingState = LoadingState.initial;
  String? _error;
  List<HorizontalVodModel> _vodList = [];
  int focusedIndex = -1;
  
  // ✅ Shadow State
  bool _isSectionFocused = false;

  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  Map<String, FocusNode> _vodFocusNodes = {};
  final FocusNode _retryFocusNode = FocusNode();
  late ScrollController _scrollController;
  final double _itemWidth = bannerwdt; 
  bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
    _loadInitialData();
  }

  @override
  void dispose() {
    _navigationLockTimer?.cancel();
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    _scrollController.dispose();
    _retryFocusNode.dispose();
    _cleanupFocusNodes();
    super.dispose();
  }


void _restoreInternalFocus() {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!mounted) return;

    // 1. Pehle thoda wait karein taaki screen transition finish ho jaye
    await Future.delayed(const Duration(milliseconds: 300));

    final focusProvider = Provider.of<FocusProvider>(context, listen: false);
    final savedItemId = focusProvider.lastFocusedItemId;

    if (savedItemId != null && _vodFocusNodes.containsKey(savedItemId)) {
      final targetNode = _vodFocusNodes[savedItemId]!;
      
      // 2. Focus request karein
      targetNode.requestFocus();
      
      // 3. Scroll position sync karein
      int index = _vodList.indexWhere((v) => v.id.toString() == savedItemId);
      if (index != -1) {
        _scrollToPosition(index);
        if (mounted) setState(() => focusedIndex = index);
      }

      // 4. Sabse important: Agar focus kahin aur chala jaye toh usse wapas kheechein
      // Yeh ensure karta hai ki 'focus gaayab' na ho
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && !targetNode.hasFocus) {
          targetNode.requestFocus();
        }
      });
    }
  });
}

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(duration: AnimationTiming.slow, vsync: this);
    _listAnimationController = AnimationController(duration: AnimationTiming.slow, vsync: this);
    _headerSlideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutCubic));
    _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _listAnimationController, curve: Curves.easeInOut));
  }

  Future<void> _loadInitialData() async {
    final cachedRawData = await HorizontalVodService.getCachedRawData();
    if (cachedRawData != null && cachedRawData.isNotEmpty) {
      final parsedData = await compute(_parseAndSortVod, cachedRawData);
      _applyDataToState(parsedData);
      return;
    }
    await _fetchDataWithLoading();
  }

  Future<void> _fetchDataWithLoading() async {
    if (mounted) setState(() { _loadingState = LoadingState.loading; _error = null; });
    try {
      final freshRawData = await HorizontalVodService.fetchAndCacheRawData();
      if (freshRawData.isNotEmpty) {
        final parsedData = await compute(_parseAndSortVod, freshRawData);
        _applyDataToState(parsedData);
      } else {
        throw Exception('Failed to load data: Empty response');
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loadingState = LoadingState.error; });
      _setupFocusProvider(); 
    }
  }

  void _cleanupFocusNodes() {
    String? firstVodId;
    if (_vodList.isNotEmpty) firstVodId = _vodList[0].id.toString();
    for (var entry in _vodFocusNodes.entries) {
      if (entry.key != firstVodId) {
        try { entry.value.dispose(); } catch (e) {}
      }
    }
    _vodFocusNodes.clear();
  }

  // void _applyDataToState(List<HorizontalVodModel> vodList) {
  //   if (!mounted) return;
  //   setState(() { _loadingState = LoadingState.rebuilding; });
  //   _cleanupFocusNodes();
  //   _vodList = vodList;
  //   for (final vod in _vodList) {
  //     _vodFocusNodes[vod.id.toString()] = FocusNode();
  //   }
  //   setState(() { _loadingState = LoadingState.loaded; });
  //   _setupFocusProvider();
  //   _headerAnimationController.forward();
  //   _listAnimationController.forward();
  // }


  void _applyDataToState(List<HorizontalVodModel> vodList) {
  if (!mounted) return;
  setState(() { _loadingState = LoadingState.rebuilding; });
  _cleanupFocusNodes();
  _vodList = vodList;
  for (final vod in _vodList) {
    _vodFocusNodes[vod.id.toString()] = FocusNode();
  }
  setState(() { _loadingState = LoadingState.loaded; });
  _setupFocusProvider();
  _headerAnimationController.forward();
  _listAnimationController.forward();

// ✅ FIX: Sirf tab focus restore karein jab focus actually isi section mein hona chahiye
  final focusProvider = Provider.of<FocusProvider>(context, listen: false);
  if (focusProvider.lastFocusedIdentifier == 'subVod') {
    _restoreInternalFocus(); 
  } 
}

  void _setupFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final focusProvider = Provider.of<FocusProvider>(context, listen: false);
        
        if (_vodList.isNotEmpty) {
          // Success Case
          final firstVodId = _vodList[0].id.toString();
          final firstNode = _vodFocusNodes[firstVodId];
          if (firstNode != null) {
            focusProvider.registerFocusNode('subVod', firstNode);
            // NOTE: We do NOT request focus here automatically (as requested)
          }
        } else if (_loadingState == LoadingState.error) {
          // Error Case
          focusProvider.registerFocusNode('subVod', _retryFocusNode);
        }
      }
    });
  }

  void _scrollToPosition(int index) {
    if (!_scrollController.hasClients) return;
    final double targetOffset = index * (_itemWidth + 12);
    _scrollController.animateTo(targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent), duration: AnimationTiming.scroll, curve: Curves.easeOutCubic);
  }

  void _navigateToHorizontalVodDetails(HorizontalVodModel vod) async {
    final focusProvider = Provider.of<FocusProvider>(context, listen: false);
  
  // 1. Row identifier save karein (subVod)
  focusProvider.updateLastFocusedIdentifier('subVod');
  
  // 2. SPECIFIC BANNER ID save karein
  focusProvider.updateLastFocusedItemId(vod.id.toString());
    try {
      int? currentUserId = SessionManager.userId;
      final int? parsedId = vod.id;
      await HistoryService.updateUserHistory(userId: currentUserId!, contentType: 0, eventId: parsedId!, eventTitle: vod.name, url: '', categoryId: 0);
    } catch (e) {}
   await Navigator.push(context, MaterialPageRoute(builder: (context) => GenreMoviesScreen(tvChannelId: (vod.id).toString(), logoUrl: vod.logo ?? '', title: vod.name)));
  if (mounted) {
    _restoreInternalFocus();
  }
  }

  // ✅ UPDATED ERROR WIDGET (Using Smart Widget)
  Widget _buildErrorWidget(double height) {
    return SizedBox(
      height: height,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: ProfessionalColorsForHomePages.cardDark.withOpacity(0.3), borderRadius: BorderRadius.circular(50), border: Border.all(color: ProfessionalColorsForHomePages.accentRed.withOpacity(0.3))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 20, color: ProfessionalColorsForHomePages.accentRed),
              const SizedBox(width: 10),
              Flexible(child: Text("Connection Failed", style: const TextStyle(color: ProfessionalColorsForHomePages.textPrimary, fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 15),
              // ✅ Smart Retry Widget
              SmartRetryWidget(
                errorMessage: _error ?? "Error",
                onRetry: _fetchDataWithLoading,
                focusNode: _retryFocusNode,
                providerIdentifier: 'subVod',
                onFocusChange: (hasFocus) {
                   if(mounted) setState(() => _isSectionFocused = hasFocus);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(double screenWidth, double screenHeight) {
    double effectiveBannerHgt = bannerhgt ?? screenHeight * 0.2;
    double effectiveBannerWdt = bannerwdt ?? screenWidth * 0.18;

    switch (_loadingState) {
      case LoadingState.initial:
      case LoadingState.loading:
        // ✅ Smart Loading
        return SmartLoadingWidget(itemWidth: effectiveBannerWdt, itemHeight: effectiveBannerHgt);
      case LoadingState.error:
        // ✅ Smart Error
        return _buildErrorWidget(effectiveBannerHgt);
      case LoadingState.rebuilding:
      case LoadingState.loaded:
        if (_vodList.isEmpty) return _buildEmptyWidget();
        else return _buildHorizontalVodList(screenWidth, screenHeight);
    }
  }

  Widget _buildEmptyWidget() {
    return Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.live_tv_outlined, size: 24, color: Colors.grey), SizedBox(width: 10), Text("No Content Found", style: TextStyle(color: Colors.white, fontSize: 12))]));
  }

  Widget _buildHorizontalVodList(double screenWidth, double screenHeight) {
    return FadeTransition(
      opacity: _listFadeAnimation,
      child: SizedBox(
        height: (screenhgt ?? MediaQuery.of(context).size.height) * 0.38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
          cacheExtent: 9999,
          itemCount: _vodList.length,
          itemBuilder: (context, index) {
            var vod = _vodList[index];
            return _buildHorizontalVodItem(vod, index, screenWidth, screenHeight);
          },
        ),
      ),
    );
  }

  Widget _buildHorizontalVodItem(HorizontalVodModel vod, int index, double screenWidth, double screenHeight) {
    String vodId = vod.id.toString();
    FocusNode? focusNode = _vodFocusNodes[vodId];
    if (focusNode == null) return const SizedBox.shrink();

    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) {
        if (mounted) setState(() => _isSectionFocused = hasFocus); // ✅ Shadow Update
        if (hasFocus && mounted) {
          context.read<FocusProvider>().updateLastFocusedItemId(vodId);
          _scrollToPosition(index);
          setState(() => focusedIndex = index);
          context.read<ColorProvider>().updateColor(ProfessionalColorsForHomePages.accentBlue, true);
        } else if (mounted) {
          context.read<ColorProvider>().resetColor();
        }
      },
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.arrowLeft) {
            if (_isNavigationLocked) return KeyEventResult.handled;
            setState(() => _isNavigationLocked = true);
            _navigationLockTimer = Timer(const Duration(milliseconds: 600), () { if (mounted) setState(() => _isNavigationLocked = false); });
            if (key == LogicalKeyboardKey.arrowRight) {
              if (index < _vodList.length - 1) { String nextVodId = _vodList[index + 1].id.toString(); FocusScope.of(context).requestFocus(_vodFocusNodes[nextVodId]); } 
              else { _navigationLockTimer?.cancel(); if (mounted) setState(() => _isNavigationLocked = false); }
            } else if (key == LogicalKeyboardKey.arrowLeft) {
              if (index > 0) { String prevVodId = _vodList[index - 1].id.toString(); FocusScope.of(context).requestFocus(_vodFocusNodes[prevVodId]); } 
              else { _navigationLockTimer?.cancel(); if (mounted) setState(() => _isNavigationLocked = false); }
            }
            return KeyEventResult.handled;
          }
          // ✅ Vertical Navigation calling Provider
          if (key == LogicalKeyboardKey.arrowUp) {
            context.read<FocusProvider>().updateLastFocusedIdentifier('subVod');
            context.read<FocusProvider>().focusPreviousRow();
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowDown) {
            context.read<FocusProvider>().updateLastFocusedIdentifier('subVod');
            context.read<FocusProvider>().focusNextRow();
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
            _navigateToHorizontalVodDetails(vod);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _navigateToHorizontalVodDetails(vod),
        child: ProfessionalHorizontalVodCard(
          HorizontalVod: vod,
          focusNode: focusNode,
          onTap: () => _navigateToHorizontalVodDetails(vod),
          onColorChange: (color) {},
          index: index,
          categoryTitle: 'CONTENTS',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = (screenhgt ?? screenHeight) * 0.38;

    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        
        // ✅ CINEMATIC SHADOW LOGIC
        bool showShadow = _isSectionFocused;

        return Scaffold(
          backgroundColor: Colors.white,
          body: ClipRect(
            child: SizedBox(
              height: containerHeight,
              child: Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: (screenhgt ?? screenHeight) * 0.01),
                      _buildProfessionalTitle(screenWidth),
                      Expanded(child: _buildBody(screenWidth, screenHeight)),
                    ],
                  ),
                  
                  // ✅ SHADOW OVERLAY
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          gradient: showShadow
                              ? LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.8), // Top Shadow
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.8), // Bottom Shadow
                                  ],
                                  stops: const [0.0, 0.25, 0.75, 1.0],
                                )
                              : null,
                        ),
                      ),
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
  
  Widget _buildProfessionalTitle(double screenWidth) {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [ProfessionalColorsForHomePages.accentGreen, ProfessionalColorsForHomePages.accentBlue],
              ).createShader(bounds),
              child: const Text("CONTENTS", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 2.0)),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Professional TV Show Card (Unchanged)
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

  Color _dominantColor = ProfessionalColorsForHomePages.accentBlue;
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
    _dominantColor = ProfessionalColorsForHomePages.accentBlue;
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
            ProfessionalColorsForHomePages.cardDark,
            ProfessionalColorsForHomePages.surfaceDark,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.live_tv_rounded,
            size: height * 0.25,
            color: ProfessionalColorsForHomePages.textSecondary,
          ),
          const SizedBox(height: 8),
          const Text(
            'TV SHOW',
            style: TextStyle(
              color: ProfessionalColorsForHomePages.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ProfessionalColorsForHomePages.accentGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: ProfessionalColorsForHomePages.accentGreen,
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
    Color badgeColor = ProfessionalColorsForHomePages.accentGreen;

    if (widget.HorizontalVod.genres != null) {
      if (widget.HorizontalVod.genres!.toLowerCase().contains('news')) {
        genre = 'NEWS';
        badgeColor = ProfessionalColorsForHomePages.accentRed;
      } else if (widget.HorizontalVod.genres!
          .toLowerCase()
          .contains('sports')) {
        genre = 'SPORTS';
        badgeColor = ProfessionalColorsForHomePages.accentOrange;
      } else if (widget.HorizontalVod.genres!
          .toLowerCase()
          .contains('entertainment')) {
        genre = 'ENTERTAINMENT';
        badgeColor = ProfessionalColorsForHomePages.accentPink;
      } else if (widget.HorizontalVod.genres!
          .toLowerCase()
          .contains('documentary')) {
        genre = 'DOCUMENTARY';
        badgeColor = ProfessionalColorsForHomePages.accentBlue;
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
          color: _isFocused ? _dominantColor : ProfessionalColorsForHomePages.primaryDark,
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




