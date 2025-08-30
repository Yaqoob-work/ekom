







import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/provider/device_info_provider.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_video_player.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
import 'package:mobi_tv_entertainment/video_widget/socket_service.dart';
import 'package:mobi_tv_entertainment/video_widget/youtube_webview_player.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Optimized Genre Network Widget - Caching Version
class GenreNetworkWidget extends StatefulWidget {
  final int tvChannelId;
  final String channelName;
  final String? channelLogo;

  const GenreNetworkWidget({
    Key? key,
    required this.tvChannelId,
    required this.channelName,
    this.channelLogo,
  }) : super(key: key);

  @override
  State<GenreNetworkWidget> createState() => _GenreNetworkWidgetState();
}

class _GenreNetworkWidgetState extends State<GenreNetworkWidget>
    with SingleTickerProviderStateMixin {
  List<String> availableGenres = [];
  Map<String, List<ContentItem>> genreContentMap = {};
  bool isLoading = false; // Is loading for the first time (if no cache)
  bool _isVideoLoading = false;
  String? errorMessage;

  // Focus management
  int focusedGenreIndex = 0;
  int focusedItemIndex = 0;
  final FocusNode _widgetFocusNode = FocusNode();
  final ScrollController _verticalScrollController = ScrollController();
  List<ScrollController> _horizontalScrollControllers = [];

  // Socket service for video handling
  final SocketService _socketService = SocketService();

  // Animation Controller
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _socketService.initSocket();
    // Load data with the new caching strategy
    _loadDataWithCache();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _widgetFocusNode.dispose();
    _verticalScrollController.dispose();
    _socketService.dispose();
    for (var controller in _horizontalScrollControllers) {
      if (controller.hasClients) {
        controller.dispose();
      }
    }
    _horizontalScrollControllers.clear();
    super.dispose();
  }

  // =======================================================================
  // NEW CACHING LOGIC / नया कैशिंग लॉजिक
  // =======================================================================

  /// Main method to orchestrate data loading with caching.
  /// यह डेटा लोड करने का मुख्य तरीका है जो कैशिंग का उपयोग करता है।
  Future<void> _loadDataWithCache() async {
    // Step 1: Try to load from cache and display immediately.
    // स्टेप 1: कैश से डेटा लोड करके तुरंत दिखाने की कोशिश करें।
    bool isLoadedFromCache = await _loadFromCache();

    // If cache is empty, show the main loading indicator.
    // अगर कैश खाली है, तो मुख्य लोडिंग इंडिकेटर दिखाएं।
    if (!isLoadedFromCache && mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    // Step 2: Always fetch fresh data from the network in the background.
    // This will update the UI and the cache when it arrives.
    // स्टेप 2: हमेशा बैकग्राउंड में नेटवर्क से नया डेटा फ़ेच करें।
    // यह आने पर UI और कैश को अपडेट कर देगा।
    try {
      await _fetchFromNetworkAndCache();
    } catch (e) {
      // If fetching fails and there was no cache, show an error.
      // अगर फ़ेचिंग विफल हो जाती है और कोई कैश नहीं था, तो एक त्रुटि दिखाएं।
      if (!isLoadedFromCache && mounted) {
        setState(() {
          errorMessage = e.toString();
        });
      }
      // If cache was already shown, we can ignore the network error silently
      // as the user already sees some data.
      print("Background fetch failed: $e");
    } finally {
      // Hide the main loading indicator once the initial load is done.
      // प्रारंभिक लोड पूरा हो जाने पर मुख्य लोडिंग इंडिकेटर छिपा दें।
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Tries to load genres and content from SharedPreferences.
  /// SharedPreferences से शैलियों और सामग्री को लोड करने का प्रयास करता है।
  Future<bool> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedGenresJson =
          prefs.getString('genres_cache_${widget.tvChannelId}');
      final String? cachedContentJson =
          prefs.getString('content_cache_${widget.tvChannelId}');

      if (cachedGenresJson != null && cachedContentJson != null) {
        print("✅ Data found in cache. Loading from cache...");
        // Decode and process cached genres
        final genresData = json.decode(cachedGenresJson);
        List<String> fetchedGenres = List<String>.from(genresData['genres']);
        if (!fetchedGenres.contains('Web Series')) {
          fetchedGenres.add('Web Series');
        }

        // Process cached content
        final contentData = json.decode(cachedContentJson);

        // This setState will quickly show the old data
        if (mounted) {
          setState(() {
            availableGenres = fetchedGenres;
          });
          // Process content data after genres are set
          await _processContentData(contentData['data']);
        }

        _initializeAndScroll();
        print("✅ Cache loaded successfully.");
        return true;
      }
    } catch (e) {
      print("Error loading from cache: $e");
      // If cache is corrupted, it will be overwritten by network fetch.
    }
    print("ℹ️ No data in cache.");
    return false;
  }

  // /// Fetches data from the network and saves it to the cache.
  // /// नेटवर्क से डेटा फ़ेच करता है और उसे कैश में सहेजता है।
  // Future<void> _fetchFromNetworkAndCache() async {
  //   print("🌐 Fetching fresh data from network...");
  //   final prefs = await SharedPreferences.getInstance();
  //   String authKey = prefs.getString('auth_key') ?? '';
  //   if (authKey.isEmpty) throw Exception('Auth key not found');

  //   // 1. Fetch and Cache Genres
  //   final genresResponse = await https.get(
  //     Uri.parse(
  //         'https://acomtv.coretechinfo.com/public/api/getGenreByContentNetwork/${widget.tvChannelId}'),
  //     headers: {
  //       'auth-key': authKey,
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //     },
  //   );

  //   if (genresResponse.statusCode != 200) {
  //     throw Exception('Failed to fetch genres: ${genresResponse.statusCode}');
  //   }
  //   await prefs.setString(
  //       'genres_cache_${widget.tvChannelId}', genresResponse.body);

  //   // 2. Fetch and Cache Content
  //   final contentResponse = await https.post(
  //     Uri.parse(
  //         'https://acomtv.coretechinfo.com/public/api/v2/getAllContentsOfNetworkNew'),
  //     headers: {
  //       'auth-key': authKey,
  //       'domain': 'coretechinfo.com',
  //     },
  //     body: json.encode({"genre": "", "network_id": widget.tvChannelId}),
  //   );

  //   if (contentResponse.statusCode != 200) {
  //     throw Exception('Failed to fetch content: ${contentResponse.statusCode}');
  //   }
  //   await prefs.setString(
  //       'content_cache_${widget.tvChannelId}', contentResponse.body);
  //   print("💾 Fresh data saved to cache.");

  //   // 3. Process the newly fetched data
  //   final genresData = json.decode(genresResponse.body);
  //   List<String> fetchedGenres = List<String>.from(genresData['genres']);
  //   if (!fetchedGenres.contains('Web Series')) {
  //     fetchedGenres.add('Web Series');
  //   }

  //   final contentData = json.decode(contentResponse.body);

  //   // This setState updates the UI with fresh data
  //   if (mounted) {
  //     setState(() {
  //       errorMessage = null; // Clear any previous errors
  //       availableGenres = fetchedGenres;
  //     });
  //     await _processContentData(contentData['data']);
  //   }

  //   _initializeAndScroll();
  //   print("🌐 Network fetch and UI update complete.");
  // }

  /// Helper function to initialize controllers and scroll into view.
  /// यह नियंत्रकों को शुरू करने और दृश्य में स्क्रॉल करने के लिए एक सहायक फ़ंक्शन है।
  void _initializeAndScroll() {
    if (!mounted) return;
    _initializeScrollControllers();
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _widgetFocusNode.requestFocus();
        _scrollToFocusedGenre();
      }
    });
  }

  /// Fetches data from the network and saves it to the cache.
  /// नेटवर्क से डेटा फ़ेच करता है और उसे कैश में सहेजता है।
  Future<void> _fetchFromNetworkAndCache() async {
    print("🌐 Fetching fresh data from network...");
    final prefs = await SharedPreferences.getInstance();
    String authKey = prefs.getString('auth_key') ?? '';
    if (authKey.isEmpty) throw Exception('Auth key not found');

    try {
      // 1. Fetch and Cache Genres
      final genresResponse = await https.get(
        Uri.parse(
            'https://acomtv.coretechinfo.com/api/v2/getGenreByContentNetwork/${widget.tvChannelId}'),
            // 'https://acomtv.coretechinfo.com/public/api/getGenreByContentNetwork/${widget.tvChannelId}'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain':'coretechinfo.com'
        },
      );

      if (genresResponse.statusCode != 200) {
        throw Exception('Failed to fetch genres: ${genresResponse.statusCode}');
      }
      await prefs.setString(
          'genres_cache_${widget.tvChannelId}', genresResponse.body);

      // 2. Fetch and Cache Content
      final contentResponse = await https.post(
        Uri.parse(
            'https://acomtv.coretechinfo.com/api/v2/getAllContentsOfNetworkNew'),
        headers: {
          'auth-key': authKey,
          'domain': 'coretechinfo.com',
        },
        body: json.encode({"genre": "", "network_id": widget.tvChannelId}),
      );

      if (contentResponse.statusCode != 200) {
        throw Exception(
            'Failed to fetch content: ${contentResponse.statusCode}');
      }

      // ===================== DEBUG LOGGING AND SAFE PARSING START =====================
      // Print the size of the response body in MB to check for large data
      final responseSizeInMB = contentResponse.bodyBytes.length / (1024 * 1024);
      print(
          '✅ [DEBUG] Content Response Size for channel ${widget.tvChannelId}: ${responseSizeInMB.toStringAsFixed(2)} MB');

      // Decode the content data safely
      final contentData = json.decode(contentResponse.body);
      final totalItems = (contentData['data'] as List).length;
      print('✅ [DEBUG] Total content items fetched: $totalItems');
      // ===================== DEBUG LOGGING AND SAFE PARSING END =======================

      await prefs.setString(
          'content_cache_${widget.tvChannelId}', contentResponse.body);
      print("💾 Fresh data saved to cache.");

      // 3. Process the newly fetched data
      final genresData = json.decode(genresResponse.body);
      List<String> fetchedGenres = List<String>.from(genresData['genres']);
      if (!fetchedGenres.contains('Web Series')) {
        fetchedGenres.add('Web Series');
      }

      // This setState updates the UI with fresh data
      if (mounted) {
        setState(() {
          errorMessage = null; // Clear any previous errors
          availableGenres = fetchedGenres;
        });
        // Process content using the already decoded data
        await _processContentData(contentData['data']);
      }

      _initializeAndScroll();
      print("🌐 Network fetch and UI update complete.");
    } catch (e, stackTrace) {
      // This will catch any error during network calls or JSON decoding
      print(
          '❌ [CRITICAL ERROR] A failure occurred in _fetchFromNetworkAndCache: $e');
      print('Stack Trace: $stackTrace');
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load or process data from the server.';
        });
      }
    }
  }

  /// Pull to refresh functionality
  Future<void> _handleRefresh() async {
    // Refresh should always fetch from network, ignoring cache.
    await _fetchFromNetworkAndCache();
  }

  // =======================================================================
  // END OF NEW CACHING LOGIC
  // =======================================================================

  // Calculate genre section height for scrolling
  double _calculateGenreSectionHeight() {
    double genreHeaderContainer = 56.0;
    double spaceBetweenHeaderAndContent = 16.0;
    double contentHeight = bannerhgt + 15;
    double sectionBottomMargin = 24.0;

    return genreHeaderContainer +
        spaceBetweenHeaderAndContent +
        contentHeight +
        sectionBottomMargin;
  }

  // Scroll to focused genre
  void _scrollToFocusedGenre() {
    if (!mounted || !_verticalScrollController.hasClients) return;

    try {
      // Reset horizontal scroll to beginning
      if (focusedGenreIndex < _horizontalScrollControllers.length) {
        final horizontalController =
            _horizontalScrollControllers[focusedGenreIndex];
        if (horizontalController.hasClients) {
          horizontalController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }

      // Handle vertical scroll
      double sectionHeight = _calculateGenreSectionHeight();
      double targetOffset = focusedGenreIndex * sectionHeight;
      double topPadding = 50.0;
      targetOffset = math.max(0, targetOffset - topPadding);

      double maxOffset = _verticalScrollController.position.maxScrollExtent;
      targetOffset = math.min(targetOffset, maxOffset);

      _verticalScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } catch (e) {
      print('Scroll error: $e');
    }
  }

  void _initializeScrollControllers() {
    // Clear existing controllers first
    for (var controller in _horizontalScrollControllers) {
      if (controller.hasClients) {
        controller.dispose();
      }
    }
    _horizontalScrollControllers.clear();

    // Create new ones
    for (int i = 0; i < genreContentMap.length; i++) {
      _horizontalScrollControllers.add(ScrollController());
    }
  }

  // Process content data in batches to prevent memory overload
  Future<void> _processContentData(List<dynamic> contentData) async {
      // Sort the data by 'series_order' before processing it
  contentData.sort((a, b) {
    // series_order null हो सकता है, इसलिए null-safety का ध्यान रखें
    // Handle potential nulls for series_order
    final int? orderA = a['series_order'];
    final int? orderB = b['series_order'];

    if (orderA == null && orderB == null) return 0; // दोनों null हैं, तो कोई बदलाव नहीं
    if (orderA == null) return 1;  // null वाले आइटम्स को अंत में रखें
    if (orderB == null) return -1; // null वाले आइटम्स को अंत में रखें

    return orderA.compareTo(orderB); // बढ़ते क्रम में सॉर्ट करें (ascending)
  });


  
    Map<String, List<ContentItem>> tempGenreMap = {};

    // Initialize genre map
    for (String genre in availableGenres) {
      tempGenreMap[genre] = [];
    }

    const batchSize = 10;
    for (int i = 0; i < contentData.length; i += batchSize) {
      if (!mounted) return; // Check if still mounted

      final endIndex = math.min(i + batchSize, contentData.length);
      final batch = contentData.sublist(i, endIndex);

      // Process batch
      for (var contentItem in batch) {
        if (contentItem['status'] != 1) continue;

        ContentItem content = ContentItem.fromJson(contentItem);

        // Skip content without playable URLs for movies
        if (content.contentType == 1 &&
            (content.movieUrl == null || content.movieUrl!.isEmpty)) {
          continue;
        }

        String contentGenres = contentItem['genres'] ?? '';
        List<String> itemGenres =
            contentGenres.split(',').map((g) => g.trim()).toList();

        bool addedToAnyGenre = false;

        // Add to appropriate genres
        for (String itemGenre in itemGenres) {
          for (String availableGenre in availableGenres) {
            if (availableGenre.toLowerCase() == itemGenre.toLowerCase()) {
              tempGenreMap[availableGenre]?.add(content);
              addedToAnyGenre = true;
              break;
            }
          }
        }

        // Special handling for Web Series
        if (!addedToAnyGenre && content.contentType == 2) {
          if (availableGenres.contains('Web Series')) {
            tempGenreMap['Web Series']?.add(content);
          }
        }
      }

      // Allow UI to breathe between batches
      await Future.delayed(Duration.zero);
    }

    // Remove empty genres
    tempGenreMap.removeWhere((key, value) => value.isEmpty);

    if (mounted) {
      setState(() {
        genreContentMap = tempGenreMap;
      });
    }
  }

  // Key navigation handler
  void _handleKeyNavigation(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    if (genreContentMap.isEmpty || _isVideoLoading) return;

    final genres = genreContentMap.keys.toList();
    final currentGenreItems = genreContentMap[genres[focusedGenreIndex]] ?? [];

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _moveGenreFocusUp(genres);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _moveGenreFocusDown(genres);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _moveItemFocusLeft();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _moveItemFocusRight(currentGenreItems);
    } else if (event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.enter) {
      _handleSelectAction(currentGenreItems, genres[focusedGenreIndex]);
    }
  }

  void _handleSelectAction(
      List<ContentItem> currentGenreItems, String currentGenre) {
    final hasViewAll = currentGenreItems.length > 10;

    if (hasViewAll && focusedItemIndex == 10) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GenreAllContentPage(
            genreTitle: currentGenre,
            allContent: currentGenreItems,
            channelName: widget.channelName,
          ),
        ),
      );
    } else {
      if (focusedItemIndex < currentGenreItems.length) {
        _handleContentTap(currentGenreItems[focusedItemIndex]);
      }
    }
  }

  void _moveGenreFocusUp(List<String> genres) {
    if (focusedGenreIndex <= 0) return;

    setState(() {
      focusedGenreIndex--;
      focusedItemIndex = 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToFocusedGenre();
      _widgetFocusNode.requestFocus();
    });

    HapticFeedback.lightImpact();
  }

  void _moveGenreFocusDown(List<String> genres) {
    if (focusedGenreIndex >= genres.length - 1) return;

    setState(() {
      focusedGenreIndex++;
      focusedItemIndex = 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToFocusedGenre();
      _widgetFocusNode.requestFocus();
    });

    HapticFeedback.lightImpact();
  }

  void _moveItemFocusLeft() {
    if (focusedItemIndex <= 0) return;

    setState(() {
      focusedItemIndex = focusedItemIndex - 1;
    });

    _scrollToFocusedItem();
    HapticFeedback.lightImpact();
  }

  void _moveItemFocusRight(List<ContentItem> currentGenreItems) {
    final hasViewAll = currentGenreItems.length > 10;
    final displayCount =
        hasViewAll ? 11 : math.min(currentGenreItems.length, 10);

    if (focusedItemIndex >= displayCount - 1) return;

    setState(() {
      focusedItemIndex = focusedItemIndex + 1;
    });

    _scrollToFocusedItem();
    HapticFeedback.lightImpact();
  }

  Future<void> _handleContentTap(ContentItem content) async {
    if (_isVideoLoading || !mounted) return;

    setState(() {
      _isVideoLoading = true;
    });

    try {
      // Special handling for Web Series - Navigate to WebSeriesDetailsPage
      if (content.contentType == 2) {
        // Navigate to Web Series Details Page instead of playing trailer
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebSeriesDetailsPage(
              id: content.id,
              banner: content.banner ?? '',
              poster: content.poster ?? '',
              logo: widget.channelLogo ?? '',
              name: content.name,
            ),
          ),
        );
        return; // Exit early for web series
      }

      // Handle Movies and other content types
      String? playableUrl = content.getPlayableUrl();

      if (playableUrl == null || playableUrl.isEmpty) {
        throw Exception('No video URL found for this content');
      }

      if (!mounted) return;

      // Handle different source types for movies
      if (content.sourceType == 'YoutubeLive' ||
          (content.youtubeTrailer != null &&
              content.youtubeTrailer!.isNotEmpty)) {
        print('isYoutube');

        String youtubeUrl = content.sourceType == 'YoutubeLive'
            ? playableUrl
            : content.youtubeTrailer!;
        final deviceInfo = context.read<DeviceInfoProvider>();

        if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
        print('isAFTSS');

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => YoutubeWebviewPlayer(
                videoUrl: playableUrl,
                name: content.name,
              ),
            ),
          );
        } else {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomYoutubePlayer(
                  videoData: VideoData(
                    id: content.id.toString(),
                    title: content.name,
                    youtubeUrl: youtubeUrl,
                    thumbnail: content.poster ?? content.banner ?? '',
                    description: content.description ?? '',
                  ),
                  playlist: [
                    VideoData(
                      id: content.id.toString(),
                      title: content.name,
                      youtubeUrl: youtubeUrl,
                      thumbnail: content.poster ?? content.banner ?? '',
                      description: content.description ?? '',
                    ),
                  ],
                ),
              ));
        }
      } else {
        // Handle regular video files (M3u8, MP4, etc.)
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomVideoPlayer(
              videoUrl: playableUrl,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error loading content';
        if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          errorMessage = 'Network error. Please check your connection';
        } else if (e.toString().contains('format') ||
            e.toString().contains('codec')) {
          errorMessage = 'Video format not supported';
        } else if (e.toString().contains('not found') ||
            e.toString().contains('404')) {
          errorMessage = 'Content not available';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: ProfessionalColors.accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _handleContentTap(content),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
    }
  }

  void _scrollToFocusedItem() {
    if (!mounted) return;

    if (focusedGenreIndex < _horizontalScrollControllers.length) {
      final controller = _horizontalScrollControllers[focusedGenreIndex];
      if (controller.hasClients) {
        double itemWidth = 180.0;
        double targetOffset = focusedItemIndex * itemWidth;

        double viewportWidth = controller.position.viewportDimension;
        double currentOffset = controller.offset;
        double maxOffset = controller.position.maxScrollExtent;

        double scrollPadding = 40.0;

        if (targetOffset < currentOffset) {
          double newOffset = math.max(0, targetOffset - scrollPadding);
          controller.animateTo(
            newOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else if (targetOffset + itemWidth > currentOffset + viewportWidth) {
          double newOffset =
              targetOffset + itemWidth - viewportWidth + scrollPadding;
          newOffset = math.min(newOffset, maxOffset);
          controller.animateTo(
            newOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  Widget _buildProfessionalAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ProfessionalColors.primaryDark.withOpacity(0.98),
            ProfessionalColors.surfaceDark.withOpacity(0.95),
            ProfessionalColors.surfaceDark.withOpacity(0.9),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: ProfessionalColors.accentGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
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
                    gradient: LinearGradient(
                      colors: [
                        ProfessionalColors.accentGreen.withOpacity(0.4),
                        ProfessionalColors.accentBlue.withOpacity(0.4),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ProfessionalColors.accentGreen.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
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
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.8),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ProfessionalColors.accentGreen.withOpacity(0.4),
                              ProfessionalColors.accentBlue.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color:
                                ProfessionalColors.accentGreen.withOpacity(0.6),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${genreContentMap.length} Genres • ${genreContentMap.values.fold(0, (sum, list) => sum + list.length)} Shows',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.channelLogo != null)
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27.5),
                      border: Border.all(
                        color: ProfessionalColors.accentGreen.withOpacity(0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              ProfessionalColors.accentGreen.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.5),
                      child: CachedNetworkImage(
                        imageUrl: widget.channelLogo!,
                        fit: BoxFit.cover,
                        memCacheWidth: 110, // Optimize memory
                        memCacheHeight: 110,
                        errorWidget: (context, url, error) => Container(
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
        ),
      ),
    );
  }

  // Optimized genre section
  Widget _buildGenreSection(
      String genre, List<ContentItem> contentList, int genreIndex) {
    final isFocusedGenre = focusedGenreIndex == genreIndex;

    final displayItems = contentList.take(10).toList();
    final hasMore = contentList.length > 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genre Header
          Container(
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isFocusedGenre
                    ? [
                        ProfessionalColors.accentGreen.withOpacity(0.3),
                        ProfessionalColors.accentBlue.withOpacity(0.2),
                      ]
                    : [
                        ProfessionalColors.cardDark.withOpacity(0.6),
                        ProfessionalColors.surfaceDark.withOpacity(0.4),
                      ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isFocusedGenre
                    ? ProfessionalColors.accentGreen.withOpacity(0.5)
                    : ProfessionalColors.cardDark.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    genre.toUpperCase(),
                    style: TextStyle(
                      fontSize: isFocusedGenre ? 18 : 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isFocusedGenre
                          ? ProfessionalColors.accentGreen
                          : ProfessionalColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFocusedGenre
                        ? ProfessionalColors.accentGreen.withOpacity(0.2)
                        : ProfessionalColors.cardDark.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isFocusedGenre
                          ? ProfessionalColors.accentGreen.withOpacity(0.4)
                          : ProfessionalColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${contentList.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isFocusedGenre
                          ? ProfessionalColors.accentGreen
                          : ProfessionalColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content List
          SizedBox(
            height: bannerhgt + 15,
            child: ListView.builder(
              controller: genreIndex < _horizontalScrollControllers.length
                  ? _horizontalScrollControllers[genreIndex]
                  : null,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              addAutomaticKeepAlives: false, // Memory optimization
              cacheExtent: 1000, // Limited cache
              itemCount:
                  hasMore ? displayItems.length + 1 : displayItems.length,
              itemBuilder: (context, index) {
                // View All button
                if (hasMore && index == displayItems.length) {
                  final isFocused = focusedGenreIndex == genreIndex &&
                      focusedItemIndex == index;

                  return _buildViewAllCard(
                    isFocused: isFocused,
                    totalCount: contentList.length,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GenreAllContentPage(
                            genreTitle: genre,
                            allContent: contentList,
                            channelName: widget.channelName,
                          ),
                        ),
                      );
                    },
                  );
                }

                // Regular content cards
                final content = displayItems[index];
                final isFocused = focusedGenreIndex == genreIndex &&
                    focusedItemIndex == index;

                return OptimizedContentCard(
                  content: content,
                  isFocused: isFocused,
                  onTap: () => _handleContentTap(content),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // View All Card Widget
  Widget _buildViewAllCard({
    required bool isFocused,
    required int totalCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isFocused
                ? [
                    ProfessionalColors.accentGreen.withOpacity(0.3),
                    ProfessionalColors.accentBlue.withOpacity(0.3),
                  ]
                : [
                    ProfessionalColors.cardDark.withOpacity(0.8),
                    ProfessionalColors.surfaceDark.withOpacity(0.6),
                  ],
          ),
          border: Border.all(
            color: isFocused
                ? ProfessionalColors.accentGreen
                : ProfessionalColors.cardDark.withOpacity(0.5),
            width: isFocused ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFocused
                    ? ProfessionalColors.accentGreen.withOpacity(0.3)
                    : ProfessionalColors.cardDark.withOpacity(0.5),
                border: Border.all(
                  color: isFocused
                      ? ProfessionalColors.accentGreen
                      : ProfessionalColors.textSecondary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.grid_view_rounded,
                size: 15,
                color: isFocused
                    ? ProfessionalColors.accentGreen
                    : ProfessionalColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'VIEW ALL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: isFocused
                    ? ProfessionalColors.accentGreen
                    : ProfessionalColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isFocused
                    ? ProfessionalColors.accentGreen.withOpacity(0.2)
                    : ProfessionalColors.cardDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$totalCount items',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isFocused
                      ? ProfessionalColors.accentGreen
                      : ProfessionalColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: ProfessionalColors.primaryDark,
  //     body: Container(
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topCenter,
  //           end: Alignment.bottomCenter,
  //           colors: [
  //             ProfessionalColors.primaryDark,
  //             ProfessionalColors.surfaceDark.withOpacity(0.8),
  //             ProfessionalColors.primaryDark,
  //           ],
  //         ),
  //       ),
  //       child: Stack(
  //         children: [
  //           FadeTransition(
  //             opacity: _fadeAnimation,
  //             child: Column(
  //               children: [
  //                 SizedBox(
  //                   height: MediaQuery.of(context).padding.top + 100,
  //                 ),
  //                 Expanded(
  //                   child: RawKeyboardListener(
  //                     focusNode: _widgetFocusNode,
  //                     onKey: _handleKeyNavigation,
  //                     autofocus: false,
  //                     child: RefreshIndicator(
  //                       onRefresh: _handleRefresh,
  //                       color: ProfessionalColors.accentGreen,
  //                       backgroundColor: ProfessionalColors.cardDark,
  //                       child: _buildContent(),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Positioned(
  //             top: 0,
  //             left: 0,
  //             right: 0,
  //             child: _buildProfessionalAppBar(),
  //           ),
  //           if (_isVideoLoading)
  //             Positioned.fill(
  //               child: Container(
  //                 color: Colors.black.withOpacity(0.7),
  //                 child: const Center(
  //                   child: ProfessionalLoadingIndicator(
  //                     message: 'Loading Video...',
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           if (isLoading && genreContentMap.isEmpty)
  //             Positioned.fill(
  //               child: Container(
  //                 color: Colors.black.withOpacity(0.7),
  //                 child: const Center(
  //                   child: ProfessionalLoadingIndicator(
  //                     message: 'Loading Content...',
  //                   ),
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }



  // Replace your current build method with this updated version

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
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top + 100,
                ),
                Expanded(
                  child: RawKeyboardListener(
                    focusNode: _widgetFocusNode,
                    onKey: _handleKeyNavigation,
                    autofocus: false,
                    child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: ProfessionalColors.accentGreen,
                      backgroundColor: ProfessionalColors.cardDark,
                      child: _buildContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildProfessionalAppBar(),
          ),
          
          // Video Loading Overlay
          if (_isVideoLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: ProfessionalLoadingIndicator(
                    message: 'Loading Video...',
                  ),
                ),
              ),
            ),
            
          // Main Loading Overlay - This is the key fix
          if (isLoading && genreContentMap.isEmpty)
            Positioned.fill(
              child: Container(
                color: ProfessionalColors.primaryDark.withOpacity(0.95),
                child: const Center(
                  child: ProfessionalLoadingIndicator(
                    message: 'Loading Content...',
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

// Updated _buildContent method to ensure proper loading state handling
Widget _buildContent() {
  // Show empty container when loading for the first time
  if (isLoading && genreContentMap.isEmpty) {
    return Container(); // This ensures the loading overlay is visible
  } 
  // Error state with no cached data
  else if (errorMessage != null && genreContentMap.isEmpty) {
    return _buildErrorWidget();
  } 
  // No content found after loading
  else if (genreContentMap.isEmpty && !isLoading) {
    return _buildEmptyWidget();
  } 
  // Show content (either from cache or fresh data)
  else {
    final genres = genreContentMap.keys.toList();

    return ListView.builder(
      controller: _verticalScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 20, bottom: 100),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final String genreName = genres[index];
        final List<ContentItem> contentList = genreContentMap[genreName]!;
        return _buildGenreSection(genreName, contentList, index);
      },
    );
  }
}


  // Widget _buildContent() {
  //   if (isLoading && genreContentMap.isEmpty) {
  //     return const SizedBox.shrink();
  //   } else if (errorMessage != null && genreContentMap.isEmpty) {
  //     return _buildErrorWidget();
  //   } else if (genreContentMap.isEmpty) {
  //     return _buildEmptyWidget();
  //   } else {
  //     return SingleChildScrollView(
  //       controller: _verticalScrollController,
  //       physics: const AlwaysScrollableScrollPhysics(),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const SizedBox(height: 20),
  //           ...genreContentMap.entries.toList().asMap().entries.map((entry) {
  //             int genreIndex = entry.key;
  //             var genreEntry = entry.value;
  //             return _buildGenreSection(
  //                 genreEntry.key, genreEntry.value, genreIndex);
  //           }).toList(),
  //           const SizedBox(height: 100),
  //         ],
  //       ),
  //     );
  //   }
  // }

  // Widget _buildContent() {
  //   if (isLoading && genreContentMap.isEmpty) {
  //     // Show nothing while the initial loading indicator is visible
  //     return const SizedBox.shrink();
  //   } else if (errorMessage != null && genreContentMap.isEmpty) {
  //     // If there's an error and no cached data to show
  //     return _buildErrorWidget();
  //   } else if (genreContentMap.isEmpty) {
  //     // If loading is finished but no content was found
  //     return _buildEmptyWidget();
  //   } else {
  //     // ===================== OPTIMIZATION: USE ListView.builder =====================
  //     // This is the main fix for the crash. It only builds the genre rows
  //     // that are visible on the screen, saving a huge amount of memory.

  //     final genres = genreContentMap.keys.toList();

  //     return ListView.builder(
  //       controller: _verticalScrollController,
  //       physics: const AlwaysScrollableScrollPhysics(),
  //       // Add vertical padding directly to the ListView
  //       padding: const EdgeInsets.only(top: 20, bottom: 100),
  //       itemCount: genres.length,
  //       // The builder function is called only for visible items
  //       itemBuilder: (context, index) {
  //         final String genreName = genres[index];
  //         final List<ContentItem> contentList = genreContentMap[genreName]!;

  //         // Pass the correct index to _buildGenreSection for focus management
  //         return _buildGenreSection(genreName, contentList, index);
  //       },
  //     );
  //     // ================================= END OF OPTIMIZATION =================================
  //   }
  // }

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
            'Something went wrong',
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
            onPressed: _loadDataWithCache,
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
          const Text(
            'No Content Found',
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Pull down to refresh',
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

// COMPLETELY OPTIMIZED CONTENT CARD - NO ANIMATIONS
class OptimizedContentCard extends StatelessWidget {
  final ContentItem content;
  final bool isFocused;
  final VoidCallback onTap;

  const OptimizedContentCard({
    Key? key,
    required this.content,
    required this.isFocused,
    required this.onTap,
  }) : super(key: key);

  Color _getContentTypeColor() {
    switch (content.contentType) {
      case 1:
        return ProfessionalColors.accentGreen; // Movies
      case 2:
        return ProfessionalColors.accentBlue; // Web Series
      default:
        return ProfessionalColors.accentPurple; // Others
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: bannerwdt,
        height: bannerhgt,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: isFocused
              ? Border.all(
                  color: ProfessionalColors.accentGreen,
                  width: 3,
                )
              : null,
          boxShadow: [
            if (isFocused) ...[
              BoxShadow(
                color: ProfessionalColors.accentGreen.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
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
              _buildContentImage(),
              _buildGradientOverlay(),
              _buildContentInfo(),
              if (isFocused) _buildPlayButton(),
              _buildNetworkOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: _buildImageWidget(),
    );
  }

  Widget _buildImageWidget() {
    if (content.poster != null && content.poster!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: content.poster!,
        fit: BoxFit.cover,
        memCacheWidth: 300, // Memory optimization
        memCacheHeight: 400,
        maxWidthDiskCache: 300,
        maxHeightDiskCache: 400,
        placeholder: (context, url) => _buildImagePlaceholder(),
        errorWidget: (context, url, error) => _buildBannerWidget(),
      );
    } else {
      return _buildBannerWidget();
    }
  }

  Widget _buildBannerWidget() {
    if (content.banner != null && content.banner!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: content.banner!,
        fit: BoxFit.cover,
        memCacheWidth: 300,
        memCacheHeight: 400,
        maxWidthDiskCache: 300,
        maxHeightDiskCache: 400,
        placeholder: (context, url) => _buildImagePlaceholder(),
        errorWidget: (context, url, error) => _buildImagePlaceholder(),
      );
    } else {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
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
            Icon(
              content.contentType == 1
                  ? Icons.movie_outlined
                  : content.contentType == 2
                      ? Icons.tv_outlined
                      : Icons.live_tv_outlined,
              size: 40,
              color: ProfessionalColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getContentTypeColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                content.contentTypeName.toUpperCase(),
                style: TextStyle(
                  color: _getContentTypeColor(),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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

  Widget _buildContentInfo() {
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
            // Content type indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getContentTypeColor().withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _getContentTypeColor().withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                content.contentTypeName.toUpperCase(),
                style: TextStyle(
                  color: _getContentTypeColor(),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              content.name.toUpperCase(),
              style: TextStyle(
                color:
                    isFocused ? ProfessionalColors.accentGreen : Colors.white,
                fontSize: isFocused ? 13 : 12,
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
          color: ProfessionalColors.accentGreen.withOpacity(0.9),
        ),
        child: Icon(
          content.contentType == 2
              ? Icons.playlist_play
              : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildNetworkOverlay() {
    if (content.networks.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: CachedNetworkImage(
            imageUrl: content.networks.first.logo,
            fit: BoxFit.cover,
            memCacheWidth: 56,
            memCacheHeight: 56,
            errorWidget: (context, url, error) {
              return Container(
                color: ProfessionalColors.accentBlue.withOpacity(0.8),
                child: const Icon(
                  Icons.tv,
                  size: 16,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// All other classes remain the same but simplified
class ContentItem {
  final int id;
  final String name;
  final String? description;
  final String genres;
  final String? releaseDate;
  final int? runtime;
  final String? poster;
  final String? banner;
  final String? sourceType;
  final int contentType;
  final int status;
  final List<NetworkData> networks;
  final String? movieUrl;
  final int? seriesOrder;
  final String? youtubeTrailer;

  ContentItem({
    required this.id,
    required this.name,
    this.description,
    required this.genres,
    this.releaseDate,
    this.runtime,
    this.poster,
    this.banner,
    this.sourceType,
    required this.contentType,
    required this.status,
    required this.networks,
    this.movieUrl,
    this.seriesOrder,
    this.youtubeTrailer,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    List<NetworkData> networksList = [];
    if (json['networks'] != null) {
      for (var network in json['networks']) {
        networksList.add(NetworkData(
          id: network['id'],
          name: network['name'],
          logo: network['logo'],
        ));
      }
    }

    return ContentItem(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      genres: json['genres'] ?? '',
      releaseDate: json['release_date'],
      runtime: json['runtime'],
      poster: json['poster'],
      banner: json['banner'],
      sourceType: json['source_type'],
      contentType: json['content_type'] ?? 1,
      status: json['status'] ?? 0,
      networks: networksList,
      movieUrl: json['movie_url'],
      seriesOrder: json['series_order'],
      youtubeTrailer: json['youtube_trailer'],
    );
  }

  String? getPlayableUrl() {
    if (contentType == 1 && movieUrl != null && movieUrl!.isNotEmpty) {
      return movieUrl;
    }

    if (contentType == 2) {
      if (youtubeTrailer != null && youtubeTrailer!.isNotEmpty) {
        return youtubeTrailer;
      }
      return null;
    }

    return movieUrl;
  }

  bool get isPlayable {
    if (contentType == 2) {
      return true;
    }
    String? url = getPlayableUrl();
    return url != null && url.isNotEmpty;
  }

  String get contentTypeName {
    switch (contentType) {
      case 1:
        return 'Movie';
      case 2:
        return 'Web Series';
      default:
        return 'Unknown';
    }
  }
}

class NetworkData {
  final int id;
  final String name;
  final String logo;

  NetworkData({
    required this.id,
    required this.name,
    required this.logo,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkData &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// OPTIMIZED Genre All Content Page
class GenreAllContentPage extends StatefulWidget {
  final String genreTitle;
  final List<ContentItem> allContent;
  final String channelName;

  const GenreAllContentPage({
    Key? key,
    required this.genreTitle,
    required this.allContent,
    required this.channelName,
  }) : super(key: key);

  @override
  State<GenreAllContentPage> createState() => _GenreAllContentPageState();
}

class _GenreAllContentPageState extends State<GenreAllContentPage>
    with SingleTickerProviderStateMixin {
  final FocusNode _gridFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  int focusedIndex = 0;
  bool _isVideoLoading = false;
  final SocketService _socketService = SocketService();
  static const double _gridMainAxisSpacing = 10.0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late List<FocusNode> _itemFocusNodes;

  @override
  void initState() {
    super.initState();
    _socketService.initSocket();

    _fadeController = AnimationController(
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

    _fadeController.forward();

    _itemFocusNodes = List.generate(
      widget.allContent.length,
      (index) => FocusNode(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _gridFocusNode.requestFocus();
        // Start by focusing on the first item
        _itemFocusNodes[focusedIndex].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _gridFocusNode.dispose();
    for (var node in _itemFocusNodes) {
      node.dispose();
    }
    _scrollController.dispose();
    _socketService.dispose();
    super.dispose();
  }

  void _updateAndScrollToFocus() {
    if (!mounted || focusedIndex >= _itemFocusNodes.length) return;

    final focusNode = _itemFocusNodes[focusedIndex];
    focusNode.requestFocus();

    // Ensure the widget is visible on screen
    Scrollable.ensureVisible(
      focusNode.context!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.2, // Tries to center the item in the viewport
    );
  }

  void _handleKeyNavigation(RawKeyEvent event) {
    if (event is! RawKeyDownEvent || _isVideoLoading) return;

    const itemsPerRow = 6;
    final totalItems = widget.allContent.length;
    int previousIndex = focusedIndex;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (focusedIndex % itemsPerRow != 0) {
        setState(() => focusedIndex--);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (focusedIndex % itemsPerRow != itemsPerRow - 1 &&
          focusedIndex < totalItems - 1) {
        setState(() => focusedIndex++);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (focusedIndex >= itemsPerRow) {
        setState(() => focusedIndex -= itemsPerRow);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (focusedIndex < totalItems - itemsPerRow) {
        setState(() => focusedIndex =
            math.min(focusedIndex + itemsPerRow, totalItems - 1));
      }
    } else if (event.logicalKey == LogicalKeyboardKey.select ||
        event.logicalKey == LogicalKeyboardKey.enter) {
      _handleContentTap(widget.allContent[focusedIndex]);
      return;
    }

    if (previousIndex != focusedIndex) {
      _updateAndScrollToFocus();
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _handleContentTap(ContentItem content) async {
    if (_isVideoLoading || !mounted) return;

    setState(() {
      _isVideoLoading = true;
    });

    try {
      String? playableUrl = content.getPlayableUrl();

      if (playableUrl == null || playableUrl.isEmpty) {
        if (content.contentType == 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${content.name} - Episodes will be available soon'),
              backgroundColor: ProfessionalColors.accentBlue,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          return;
        } else {
          throw Exception('No video URL found for this content');
        }
      }

      if (!mounted) return;

      if (content.sourceType == 'YoutubeLive' ||
          (content.youtubeTrailer != null &&
              content.youtubeTrailer!.isNotEmpty)) {
        print('isYoutube');
        final deviceInfo = context.read<DeviceInfoProvider>();
        String youtubeUrl = content.sourceType == 'YoutubeLive'
            ? playableUrl
            : content.youtubeTrailer!;
        if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
        print('isAFTSS');

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => YoutubeWebviewPlayer(
                videoUrl: playableUrl,
                name: content.name,
              ),
            ),
          );
        } else {
          await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomYoutubePlayer(
                  videoData: VideoData(
                    id: content.id.toString(),
                    title: content.name,
                    youtubeUrl: youtubeUrl,
                    thumbnail: content.poster ?? content.banner ?? '',
                    description: content.description ?? '',
                  ),
                  playlist: [
                    VideoData(
                      id: content.id.toString(),
                      title: content.name,
                      youtubeUrl: youtubeUrl,
                      thumbnail: content.poster ?? content.banner ?? '',
                      description: content.description ?? '',
                    ),
                  ],
                ),
              ));
        }
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomVideoPlayer(
              videoUrl: playableUrl,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading content: ${e.toString()}'),
            backgroundColor: ProfessionalColors.accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
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
                _buildAppBar(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: RawKeyboardListener(
                      focusNode: _gridFocusNode,
                      onKey: _handleKeyNavigation,
                      child: _buildGridContent(),
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
                    child: ProfessionalLoadingIndicator(
                      message: 'Loading Video...',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ProfessionalColors.primaryDark.withOpacity(0.98),
            ProfessionalColors.surfaceDark.withOpacity(0.95),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      ProfessionalColors.accentGreen.withOpacity(0.4),
                      ProfessionalColors.accentBlue.withOpacity(0.4),
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
                        widget.genreTitle.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.allContent.length} items • ${widget.channelName}',
                      style: const TextStyle(
                        color: ProfessionalColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 1.5,
          mainAxisSpacing: _gridMainAxisSpacing,
        ),
        clipBehavior: Clip.none,
        addAutomaticKeepAlives: false, // Memory optimization
        cacheExtent: 1000, // Limited cache
        itemCount: widget.allContent.length,
        itemBuilder: (context, index) {
          final content = widget.allContent[index];
          final isFocused = focusedIndex == index;

          return Focus(
            focusNode: _itemFocusNodes[index],
            child: OptimizedContentCard(
              content: content,
              isFocused: isFocused,
              onTap: () => _handleContentTap(content),
            ),
          );
        },
      ),
    );
  }
}

// Professional Color Palette
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
}

// // MEMORY OPTIMIZED Loading Indicator
// class ProfessionalLoadingIndicator extends StatefulWidget {
//   final String message;

//   const ProfessionalLoadingIndicator({
//     Key? key,
//     required this.message,
//   }) : super(key: key);

//   @override
//   _ProfessionalLoadingIndicatorState createState() =>
//       _ProfessionalLoadingIndicatorState();
// }

// class _ProfessionalLoadingIndicatorState
//     extends State<ProfessionalLoadingIndicator>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();
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
//           Container(
//             width: 70,
//             height: 70,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: ProfessionalColors.accentGreen,
//                 width: 3,
//               ),
//             ),
//             child: RotationTransition(
//               turns: _controller,
//               child: const Icon(
//                 Icons.live_tv_rounded,
//                 color: ProfessionalColors.accentGreen,
//                 size: 28,
//               ),
//             ),
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
//         ],
//       ),
//     );
//   }
// }

// // Memory optimized Image Cache Configuration
// class ImageCacheConfig {
//   static void configureImageCache() {
//     // Configure image cache to prevent memory issues
//     PaintingBinding.instance.imageCache.maximumSize =
//         100; // Reduced from default 1000
//     PaintingBinding.instance.imageCache.maximumSizeBytes =
//         50 << 20; // 50MB instead of 100MB
//   }
// }





// Optional: Enhanced Loading Indicator with better animation
class ProfessionalLoadingIndicator extends StatefulWidget {
  final String message;
  final Color? primaryColor;
  final Color? textColor;

  const ProfessionalLoadingIndicator({
    Key? key,
    required this.message,
    this.primaryColor,
    this.textColor,
  }) : super(key: key);

  @override
  _ProfessionalLoadingIndicatorState createState() =>
      _ProfessionalLoadingIndicatorState();
}

class _ProfessionalLoadingIndicatorState
    extends State<ProfessionalLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? ProfessionalColors.accentGreen;
    final textColor = widget.textColor ?? ProfessionalColors.textPrimary;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading icon with pulse effect
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withOpacity(0.3),
                    primaryColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: primaryColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: RotationTransition(
                turns: _spinController,
                child: Icon(
                  Icons.live_tv_rounded,
                  color: primaryColor,
                  size: 32,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Loading message
          Text(
            widget.message,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Loading dots animation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _spinController,
                builder: (context, child) {
                  final delay = index * 0.2;
                  final animationValue = (_spinController.value - delay) % 1.0;
                  final opacity = animationValue < 0.5 ? 
                      (animationValue * 2) : (2 - animationValue * 2);
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withOpacity(opacity.clamp(0.2, 1.0)),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}