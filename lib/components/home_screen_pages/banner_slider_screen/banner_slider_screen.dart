
import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_retry_widget.dart';
import 'package:mobi_tv_entertainment/main.dart'; 
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';
import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
// ✅ Import Smart Widgets
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ... (BannerDataModel & BannerService remain unchanged) ...
// Copy them from your existing file.

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

  BannerDataModel({required this.id, required this.title, required this.banner, required this.contentType, this.contentId, this.sourceType, this.url, required this.status, required this.createdAt, required this.updatedAt, this.deletedAt});
  factory BannerDataModel.fromJson(Map<String, dynamic> json) {
    return BannerDataModel(id: json['id'] ?? 0, title: json['title'] ?? '', banner: json['banner'] ?? '', contentType: json['content_type'] ?? 1, contentId: json['content_id'], sourceType: json['source_type'], url: json['url'], status: json['status'] ?? 0, createdAt: json['created_at'] ?? '', updatedAt: json['updated_at'] ?? '', deletedAt: json['deleted_at']);
  }
  bool get isActive => status == 1 && deletedAt == null;
  NewsItemModel toNewsItemModel() {
    return NewsItemModel(id: id.toString(), name: title, updatedAt: updatedAt, banner: banner, contentId: id.toString(), type: contentType.toString(), url: url ?? '', status: status.toString(), unUpdatedUrl: '', poster: '', image: '');
  }
}

class BannerService {
  static const String _cacheKeyBanners = 'cached_banners_data';
  static const String _cacheKeyTimestamp = 'cached_banners_timestamp';
  static const Duration _cacheDuration = Duration(hours: 2);

  static Future<List<BannerDataModel>> getAllBanners({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh && await _shouldUseCache(prefs)) {
      final cachedBanners = await _getCachedBanners(prefs);
      if (cachedBanners.isNotEmpty) {
        _loadFreshDataInBackground();
        return cachedBanners;
      }
    }
    return await _fetchFreshBanners(prefs);
  }
  static Future<bool> _shouldUseCache(SharedPreferences prefs) async {
    final timestampStr = prefs.getString(_cacheKeyTimestamp);
    if (timestampStr == null) return false;
    final cachedTimestamp = DateTime.tryParse(timestampStr);
    if (cachedTimestamp == null) return false;
    return DateTime.now().difference(cachedTimestamp) < _cacheDuration;
  }
  static Future<List<BannerDataModel>> _getCachedBanners(SharedPreferences prefs) async {
    final cachedData = prefs.getString(_cacheKeyBanners);
    if (cachedData == null || cachedData.isEmpty) return [];
    try {
      final List<dynamic> jsonData = json.decode(cachedData);
      return jsonData.map((item) => BannerDataModel.fromJson(item)).where((banner) => banner.isActive).toList();
    } catch (e) { return []; }
  }
  static Future<List<BannerDataModel>> _fetchFreshBanners(SharedPreferences prefs) async {
    try {
      final List<dynamic> rawData = await _fetchBannersFromApi();
      final activeBanners = rawData.map((item) => BannerDataModel.fromJson(item)).where((banner) => banner.isActive).toList();
      if (rawData.isNotEmpty) await _cacheBanners(prefs, rawData);
      return activeBanners;
    } catch (e) {
      final cachedBanners = await _getCachedBanners(prefs);
      if (cachedBanners.isNotEmpty) return cachedBanners;
      rethrow;
    }
  }
  static Future<void> _cacheBanners(SharedPreferences prefs, List<dynamic> rawData) async {
    await prefs.setString(_cacheKeyBanners, json.encode(rawData));
    await prefs.setString(_cacheKeyTimestamp, DateTime.now().toIso8601String());
  }
  static void _loadFreshDataInBackground() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await _fetchFreshBanners(prefs);
      } catch (e) {}
    });
  }
  static Future<List<dynamic>> _fetchBannersFromApi() async {
    try {
      String authKey = SessionManager.authKey;
      var url = Uri.parse(SessionManager.baseUrl + 'getCustomImageSlider');
      final response = await https.get(url, headers: {'auth-key': authKey, 'Content-Type': 'application/json', 'Accept': 'application/json', 'domain': SessionManager.savedDomain}).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decodedData = json.decode(response.body);
        if (decodedData is List) return decodedData;
        throw Exception('API response is not a List');
      } else { throw Exception('Failed to load banners. Status: ${response.statusCode}'); }
    } catch (e) { throw Exception('Failed to load banners: $e'); }
  }
}

// ✅ BANNER SLIDER WIDGET
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

class _BannerSliderState extends State<BannerSlider>
    with SingleTickerProviderStateMixin {
  // State Variables
  List<BannerDataModel> bannerList = [];
  List<NewsItemModel>? _newsItemListCache; 
  bool isLoading = true;
  String errorMessage = '';

  // UI Control
  late PageController _pageController;
  Timer? _timer;
  String? selectedContentId; 
  bool _isNavigating = false; 
  
  // ✅ Focus State for Background Design
  bool _isFocused = false;

  // New Local Retry Focus Node
  final FocusNode _retryFocusNode = FocusNode();

  // Animations
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

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
    _retryFocusNode.dispose(); 
    super.dispose();
  }

  Future<void> _initializeSlider() async {
    _pageController = PageController();

    widget.focusNode.addListener(() {
      if (mounted) {
        setState(() {
           // Update local focus state
           _isFocused = widget.focusNode.hasFocus;
        }); 
        
        widget.onFocusChange?.call(widget.focusNode.hasFocus); 

        if (widget.focusNode.hasFocus) {
          _timer?.cancel(); 
        } else {
          _startAutoSlide(); 
        }
      }
    });

    _registerFocusNode(widget.focusNode);
    await _fetchBannersWithCache();
  }

  void _registerFocusNode(FocusNode node) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<FocusProvider>().registerFocusNode('watchNow', node);
        } catch (e) {
          print("❌ Error registering watchNow FocusNode: $e");
        }
      }
    });
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
          errorMessage = 'Failed to load banners';
          bannerList = [];
        });
        _registerFocusNode(_retryFocusNode);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showBannersInstantly(List<BannerDataModel> banners) {
    if (mounted) {
      setState(() {
        bannerList = banners;
        selectedContentId = banners.isNotEmpty ? banners[0].id.toString() : null;
        errorMessage = '';
        _newsItemListCache = null; 
      });
      _registerFocusNode(widget.focusNode);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startAutoSlide();
          _prefetchImages();
        }
      });
    }
  }

  void _prefetchImages() {
    if (!mounted) return;
    for (var banner in bannerList) {
      if (banner.banner.isNotEmpty) {
        precacheImage(CachedNetworkImageProvider(banner.banner), context).catchError((e,s) => null);
      }
    }
  }

  Future<void> refreshData() async {
    await _fetchBannersWithCache();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          // ✅ Background Design: Subtle Gradient when Focused
          gradient: _isFocused 
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    ProfessionalColorsForHomePages.accentBlue.withOpacity(0.08), 
                  ],
                )
              : null,
          border: Border(
            bottom: BorderSide(
              color: _isFocused 
                  ? ProfessionalColorsForHomePages.accentBlue.withOpacity(0.1) 
                  : Colors.transparent,
              width: 1,
            ),
          ),
        ),
        child: _buildBody(),
      ),
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
          SpinKitFadingCircle(color: ProfessionalColorsForHomePages.accentBlue, size: 50.0),
          const SizedBox(height: 20),
          const Text('Loading Highlights...', style: TextStyle(color: Colors.grey, fontSize: 14.0)),
        ],
      ),
    );
  }

  // ✅ UPDATED ERROR WIDGET USING SMART SERVICE
  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.8),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: ProfessionalColorsForHomePages.accentRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded, color: ProfessionalColorsForHomePages.accentRed, size: 40),
            ),
            const SizedBox(height: 15),
            const Text('Connection Failed', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("Unable to load banners", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 25),
            
            // ✅ USING REUSABLE SMART RETRY
            SmartRetryWidget(
                errorMessage: errorMessage, 
                onRetry: refreshData, 
                focusNode: _retryFocusNode,
                providerIdentifier: 'watchNow',
                onFocusChange: (hasFocus) {
                   if(mounted) setState(() => _isFocused = hasFocus);
                },
                // ✅ Override Arrow Up to go to Top Navigation
                onArrowUpOverride: () {
                   context.read<FocusProvider>().updateLastFocusedIdentifier('watchNow');
                   context.read<FocusProvider>().requestFocus('topNavigation');
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 50),
          const SizedBox(height: 15),
          Text('No banners available', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 20),
          SmartRetryWidget(
              errorMessage: '', 
              onRetry: refreshData, 
              focusNode: _retryFocusNode,
              providerIdentifier: 'watchNow',
              onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
              onArrowUpOverride: () {
                   context.read<FocusProvider>().updateLastFocusedIdentifier('watchNow');
                   context.read<FocusProvider>().requestFocus('topNavigation');
              },
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
            if (mounted && index < bannerList.length) {
              setState(() => selectedContentId = bannerList[index].id.toString());
            }
          },
          itemBuilder: (context, index) {
             if (index >= bannerList.length) return const SizedBox.shrink();
            final banner = bannerList[index];
            return _buildSimpleBanner(banner);
          },
        ),
        // _buildNavigationButton(),
        if (bannerList.length > 1) _buildPageIndicators(),
        _buildStationaryTitle(),
      ],
    );
  }

  Widget _buildStationaryTitle() {
    return Positioned(
      left: 0, right: 0, bottom: 0, height: MediaQuery.of(context).size.height * 0.15,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
      ),
    );
  }

  // Widget _buildNavigationButton() {
  //   final bool hasFocus = widget.focusNode.hasFocus;
  //   final List<Color> focusColors = [
  //     ProfessionalColorsForHomePages.accentBlue, 
  //     ProfessionalColorsForHomePages.accentPurple, 
  //     ProfessionalColorsForHomePages.accentGreen
  //   ];
  //   int bannerIndex = bannerList.indexWhere((b) => b.id.toString() == selectedContentId);
  //   if (bannerIndex == -1) bannerIndex = 0;
  //   final Color focusColor = bannerList.isNotEmpty ? focusColors[bannerIndex % focusColors.length] : ProfessionalColorsForHomePages.accentBlue;

  //   double effectiveScreenHeight = MediaQuery.of(context).size.height;
  //   double effectiveScreenWidth = MediaQuery.of(context).size.width;

  //   return Positioned(
  //     top: effectiveScreenHeight * 0.2,
  //     left: effectiveScreenWidth * 0.03,
  //     child: Focus(
  //       focusNode: widget.focusNode,
  //       onKeyEvent: _handleKeyEvent,
  //       child: GestureDetector(
  //         onTap: _handleWatchNowTap,
  //         child: AnimatedContainer(
  //           duration: const Duration(milliseconds: 200),
  //           padding: EdgeInsets.symmetric(vertical: effectiveScreenHeight * 0.01, horizontal: effectiveScreenWidth * 0.02),
  //           decoration: BoxDecoration(
  //             color: hasFocus ? Colors.black87 : Colors.black.withOpacity(0.6),
  //             borderRadius: BorderRadius.circular(12),
  //             border: Border.all(color: hasFocus ? focusColor : Colors.white.withOpacity(0.3), width: hasFocus ? 3.0 : 1.0),
  //             boxShadow: hasFocus
  //                 ? [BoxShadow(color: focusColor.withOpacity(0.5), blurRadius: 20.0, spreadRadius: 5.0)]
  //                 : [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10.0, spreadRadius: 2.0)],
  //           ),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Icon(Icons.chevron_left, color: hasFocus ? focusColor : Colors.grey[600]),
  //               const SizedBox(width: 8),
  //               Icon(Icons.chevron_right, color: hasFocus ? focusColor : Colors.grey[600]),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPageIndicators() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.15,
      right: MediaQuery.of(context).size.width * 0.05,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: bannerList.asMap().entries.map((entry) {
          int index = entry.key;
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
    final bool isButtonFocused = widget.focusNode.hasFocus;
    final String uniqueImageUrl = "${banner.banner}?v=${banner.updatedAt}";
    
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: uniqueImageUrl,
            fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            placeholder: (context, url) => Image.asset('assets/streamstarting.gif', fit: BoxFit.fill),
            errorWidget: (context, url, error) => Image.asset('assets/streamstarting.gif', fit: BoxFit.fill),
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
                        colors: [Colors.transparent, Colors.white.withOpacity(0.15), Colors.transparent],
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

  // KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
  //   if (event is! KeyDownEvent) return KeyEventResult.ignored;
  //   final focusProvider = context.read<FocusProvider>();

  //   if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
  //     if (_pageController.hasClients && _pageController.page! < bannerList.length - 1) {
  //       _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  //       return KeyEventResult.handled;
  //     }
  //   } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
  //     if (_pageController.hasClients && _pageController.page! > 0) {
  //       _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  //       return KeyEventResult.handled;
  //     }
  //   } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
  //      context.read<ColorProvider>().resetColor();
  //      focusProvider.requestFocus('topNavigation');
  //      return KeyEventResult.handled;
  //   } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
  //      node.unfocus();
  //      widget.onFocusChange?.call(false);
  //      context.read<ColorProvider>().resetColor();
  //      focusProvider.updateLastFocusedIdentifier('watchNow');
  //      focusProvider.focusNextRow();
  //      return KeyEventResult.handled;
  //   } else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
  //     _handleWatchNowTap();
  //     return KeyEventResult.handled;
  //   }
  //   return KeyEventResult.ignored;
  // }


  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final focusProvider = context.read<FocusProvider>();

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_pageController.hasClients && _pageController.page! < bannerList.length - 1) {
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        return KeyEventResult.handled;
      }
    } 
    
    // ✅ 1. LEFT ARROW LOGIC UPDATE
    else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_pageController.hasClients && (_pageController.page?.round() ?? 0) > 0) {
        // Agar pehle banner par nahi hain, to pichla banner dikhayein
        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        return KeyEventResult.handled;
      } else {
        // NAYA: Agar pehle banner par hain aur Left dabaya, to Sidebar par focus wapas bhej dein!
        context.read<ColorProvider>().resetColor();
        focusProvider.requestFocus('activeSidebar');
        return KeyEventResult.handled;
      }
    } 
    
    else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      //  context.read<ColorProvider>().resetColor();
      //  focusProvider.requestFocus('topNavigation');
       return KeyEventResult.handled;
    } 
    
    // ✅ 2. DOWN ARROW LOGIC UPDATE
    else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      //  node.unfocus();
      //  widget.onFocusChange?.call(false);
      //  context.read<ColorProvider>().resetColor();
       
      //  // NAYA: Niche wale dynamically loaded page ke item ko focus bhejenge
      //  focusProvider.triggerBannerDown(); 
       
       return KeyEventResult.handled;
    } 
    
    else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
      _handleWatchNowTap();
      return KeyEventResult.handled;
    }
    
    return KeyEventResult.ignored;
  }

  void _handleWatchNowTap() {
    if (selectedContentId != null && bannerList.isNotEmpty) {
      try {
        final banner = bannerList.firstWhere((b) => b.id.toString() == selectedContentId, orElse: () => bannerList.first);
        fetchAndPlayVideo(banner, newsItemList);
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  void _startAutoSlide() {
    _timer?.cancel();
    if (widget.focusNode.hasFocus) return; 
    if (bannerList.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 8), (Timer timer) {
        if (!mounted || !_pageController.hasClients) {
          timer.cancel();
          return;
        }
        double? currentPage = _pageController.page;
        if (currentPage == null) return;
        int nextPage = (currentPage.round() + 1) % bannerList.length;
        try {
          _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        } catch (e) {
          timer.cancel();
        }
      });
    }
  }

  Future<void> fetchAndPlayVideo(BannerDataModel banner, List<NewsItemModel> channelList) async {
    if (_isNavigating) return;
    _isNavigating = true;
    if (mounted) showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) => const Center(child: CircularProgressIndicator()));

    try {
      final responseData = {
        'url': banner.url ?? '',
        'type': banner.contentType.toString(),
        'banner': banner.banner,
        'name': banner.title,
        'stream_type': banner.sourceType ?? '',
      };
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (mounted) {
        bool isLive = banner.contentType == 0;
        Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(
              videoUrl: responseData['url']!,
              bannerImageUrl: responseData['banner']!,
              channelList: channelList,
              videoId: banner.id,
              name: responseData['name']!,
              liveStatus: isLive,
              updatedAt: banner.updatedAt,
              source: 'isBannerSlider',
            )));
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _isNavigating = false;
      });
    }
  }
}