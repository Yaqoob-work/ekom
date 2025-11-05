import 'dart:async';
import 'dart:convert';
import 'dart:typed_data'; // Required for Uint8List (kTransparentImage)
import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart'; // Not used
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as https; // Alias ko 'http' rakha gaya hai
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_final_details_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// NOTE: Apne project ke anusaar neeche di gayi import lines ko aavashyakta anusaar badlein.
// Make sure to change the import lines below according to your project structure.
import 'package:mobi_tv_entertainment/main.dart'; // bannerhgt ke liye
import 'package:mobi_tv_entertainment/components/services/history_service.dart';

//==============================================================================
// SECTION 1: COMMON CLASSES AND MODELS
// Yeh classes data ko handle karne aur consistent UI ke liye hain.
//==============================================================================

class ProfessionalColors {
  static const primaryDark = Color(0xFF0A0E1A);
  static const surfaceDark = Color(0xFF1A1D29);
  static const cardDark = Color(0xFF2A2D3A);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGreen = Color.fromARGB(255, 59, 246, 68);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentPink = Color(0xFFEC4899);
  static const accentOrange = Color(0xFFF59E0B);
  static const accentRed = Color(0xFFEF4444);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);

  static List<Color> gradientColors = [accentBlue, accentPurple, accentPink];
}

class AnimationTiming {
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
}

// NetworkModel pehle jaisa hi rahega kyunki _fetchNetworks abhi bhi ise istemal karega
class NetworkModel {
  final int id;
  final String name;
  final String? logo;
  NetworkModel({required this.id, required this.name, this.logo});
  factory NetworkModel.fromJson(Map<String, dynamic> json) {
    return NetworkModel(
        id: json['id'] ?? 0, name: json['name'] ?? '', logo: json['logo']);
  }
}

// REFACTOR: TvShowModel ko ab TvChannel data represent karne ke liye update kiya gaya
class TvShowModel {
  // Naam TvShowModel hi rakhte hain consistency ke liye
  final int id;
  final String name; // Channel Name OR Show Name
  final String updatedAt; // Channel Updated At
  final String? poster; // Channel Logo OR Show Thumbnail
  final String? banner; // Channel Logo OR Show Thumbnail
  final String? genre; // Show Genre
  final int order; // Channel Order OR Show Order
  final String? language; // Channel Language

  TvShowModel({
    required this.id,
    required this.name,
    required this.updatedAt,
    this.poster,
    this.banner,
    this.genre, // Genre ko nullable rakha
    required this.order,
    this.language,
  });

  // Yeh factory TvChannel API (getTvChannels) se data parse karegi
  factory TvShowModel.fromJson(Map<String, dynamic> json) {
    return TvShowModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      poster: json['logo'], // 'logo' field se map kiya
      banner: json['logo'], // 'logo' field se map kiya
      genre: null, // 'genre' field nahi hai, null set kiya
      order: json['order'] ?? 9999,
      language: json['language'], // Naya field
    );
  }
}

//=================================================
// SECTION 1.1: NEW MODEL FOR TV SHOWS (from getTvShows API)
//=================================================
class TvShowItemModel {
  final int id;
  final String name;
  final String? thumbnail;
  final String? genre;
  final int tvChannelId;
  final int order;

  TvShowItemModel({
    required this.id,
    required this.name,
    this.thumbnail,
    this.genre,
    required this.tvChannelId,
    required this.order,
  });

  factory TvShowItemModel.fromJson(Map<String, dynamic> json) {
    return TvShowItemModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      thumbnail: json['thumbnail'],
      genre: json['genre'],
      tvChannelId: json['tv_channel_id'] ?? 0,
      order: json['order'] ?? 9999,
    );
  }
}

class SliderModel {
  final int id;
  final String title;
  final String banner;
  final String sliderFor;

  SliderModel(
      {required this.id,
      required this.title,
      required this.banner,
      required this.sliderFor});

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      banner: json['banner'] ?? '',
      sliderFor: json['slider_for'] ?? '',
    );
  }
}

class ApiNetworkModel {
  final int id;
  final String name;
  final String? logo;
  final int networksOrder;
  final List<SliderModel> sliders;

  ApiNetworkModel({
    required this.id,
    required this.name,
    this.logo,
    required this.networksOrder,
    this.sliders = const [],
  });

  factory ApiNetworkModel.fromJson(Map<String, dynamic> json) {
    var sliders = (json['sliders'] as List? ?? [])
        .map((item) => SliderModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return ApiNetworkModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'],
      networksOrder: json['networks_order'] ?? 9999,
      sliders: sliders,
    );
  }
}

// UI REFACTOR: Loading indicator from WebSeries
class ProfessionalTvShowLoadingIndicator extends StatelessWidget {
  final String message;
  const ProfessionalTvShowLoadingIndicator({Key? key, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: ProfessionalColors.gradientColors,
              ),
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

//==============================================================================
// SECTION 2: MAIN PAGE WIDGET AND STATE
// Yeh page ka main structure aur logic hai.
//==============================================================================

class TvShowPakSliderScreen extends StatefulWidget {
  // <--- BADLAAV YAHAN
  final String title;
  final int? initialNetworkId; // ✅ YEH ADD KIYA GAYA HAI

  const TvShowPakSliderScreen({
    // <--- BADLAAV YAHAN
    Key? key,
    this.title = 'All TV Shows',
    this.initialNetworkId, // ✅ YEH ADD KIYA GAYA HAI
  }) : super(key: key);

  @override
  _TvShowPakSliderScreenState createState() => // <--- BADLAAV YAHAN
      _TvShowPakSliderScreenState(); // <--- BADLAAV YAHAN
}

class _TvShowPakSliderScreenState // <--- BADLAAV YAHAN
    extends State<TvShowPakSliderScreen> // <--- BADLAAV YAHAN
    with
        SingleTickerProviderStateMixin {
  List<TvShowModel> _tvShowList =
      []; // Yeh ab Channels ki MASTER list hogi (Network change par update hoti hai)
  bool _isLoading = true; // Overall page loading
  bool _isListLoading = false; // Network/Filter change par list loading
  String? _errorMessage;

  // Focus and Scroll Controllers
  List<FocusNode> _itemFocusNodes = [];
  List<FocusNode> _networkFocusNodes = [];
  List<FocusNode> _channelFilterFocusNodes = [];
  List<FocusNode> _keyboardFocusNodes = [];
  final FocusNode _widgetFocusNode = FocusNode();
  final ScrollController _listScrollController = ScrollController();
  final ScrollController _networkScrollController = ScrollController();
  final ScrollController _channelFilterScrollController = ScrollController();

  late PageController _sliderPageController;

  // Keyboard State
  int _focusedKeyRow = 0;
  int _focusedKeyCol = 0;
  final List<List<String>> _keyboardLayout = [
    "1234567890".split(''),
    "qwertyuiop".split(''),
    "asdfghjkl".split(''),
    ["z", "x", "c", "v", "b", "n", "m", "DEL"],
    [" ", "OK"],
  ];

  // UI and Filter State
  int _focusedNetworkIndex = 0;
  int _focusedChannelFilterIndex = 0;
  int _focusedItemIndex = -1;
  String _selectedNetworkName = '';
  String? _selectedNetworkLogo;

  Map<String, int?> _channelFilters =
      {}; // Holds "Channel Name" -> Channel ID ("All" removed)
  String _selectedChannelFilterName = ''; // Default empty
  int? _selectedChannelFilterId; // Default null
  bool _isDisplayingShows = false;

  List<TvShowModel> _currentViewMasterList =
      []; // NEW: Holds all items for the current filter (pre-search)
  List<TvShowModel> _displayList =
      []; // List jo UI mein render hogi (ya toh channels ya shows)
  List<ApiNetworkModel> _apiNetworks = [];
  List<String> _uniqueNetworks = [];

  // Animation and Loading State
  bool _isVideoLoading = false; // Detail page navigation loading
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _currentBackgroundUrl;
  List<SliderModel> _currentTvShowSliders = [];
  int _currentSliderIndex = 0;

  String _lastNavigationDirection = 'horizontal';

  // UI REFACTOR: Hang/Crash fix variables from WebSeries
  bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;

  // Search State
  bool _isSearching = false;
  bool _showKeyboard = false;
  String _searchText = '';
  Timer? _debounce;
  late FocusNode _searchButtonFocusNode;

  // bool _isGenreLoading = false; // Not used

  final List<Color> _focusColors = [
    ProfessionalColors.accentBlue,
    ProfessionalColors.accentPurple,
    ProfessionalColors.accentOrange,
    ProfessionalColors.accentPink,
    ProfessionalColors.accentRed
  ];

  @override
  void initState() {
    super.initState();
    _sliderPageController = PageController();
    _searchButtonFocusNode = FocusNode();
    _searchButtonFocusNode.addListener(_setStateListener); // Listener add
    _widgetFocusNode.addListener(_setStateListener);
    _fetchDataForPage();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _sliderPageController.dispose();
    _fadeController.dispose();
    _widgetFocusNode.removeListener(_setStateListener);
    _widgetFocusNode.dispose();
    _listScrollController.dispose();
    _networkScrollController.dispose();
    _channelFilterScrollController.dispose();
    _searchButtonFocusNode.removeListener(_setStateListener);
    _searchButtonFocusNode.dispose();
    _debounce?.cancel();
    _navigationLockTimer?.cancel();
    _disposeFocusNodes(_itemFocusNodes);
    _disposeFocusNodes(_networkFocusNodes);
    _disposeFocusNodes(_channelFilterFocusNodes);
    _disposeFocusNodes(_keyboardFocusNodes);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Focus(
        focusNode: _widgetFocusNode,
        autofocus: true,
        onKey: _onKeyHandler,
        child: Stack(
          children: [
            _buildBackgroundOrSlider(),
            _isLoading // Initial page load
                ? const Center(
                    child: ProfessionalTvShowLoadingIndicator(
                        message: 'Loading Channels...'))
                : _errorMessage != null
                    ? _buildErrorWidget() // UI REFACTOR: Use WebSeries error widget
                    : _buildPageContent(), // UI REFACTOR: Use WebSeries layout
            if (_isVideoLoading &&
                _errorMessage == null) // Detail page navigation
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: const Center(
                    child: ProfessionalTvShowLoadingIndicator(
                        message: 'Loading Details...'),
                  ),
                ),
              ),
            // UI REFACTOR: _isListLoading (list specific) spinner is removed
            // The WebSeries UI doesn't have it, it relies on the main _isLoading
            // and search's _isSearchLoading (which we removed)
          ],
        ),
      ),
    );
  }

  //=================================================
  // SECTION 2.1: DATA FETCHING AND PROCESSING
  //=================================================

  // ✅ [UPDATED] Is function ko initialNetworkId ke liye update kiya gaya hai
  Future<void> _fetchDataForPage({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // 1. Fetch Networks
      final fetchedNetworks = await _fetchNetworks();
      if (!mounted) return;
      fetchedNetworks
          .sort((a, b) => a.networksOrder.compareTo(b.networksOrder));

      if (fetchedNetworks.isEmpty) {
        throw Exception("No networks found.");
      }

      // ✅ --- START: YAHAN BADLAAV KIYA GAYA HAI ---

      // Initial network ID aur index dhoondhein
      int initialIndex = 0;
      int networkIdToFetch;

      if (widget.initialNetworkId != null) {
        int foundIndex =
            fetchedNetworks.indexWhere((n) => n.id == widget.initialNetworkId);
        if (foundIndex != -1) {
          initialIndex = foundIndex; // Agar ID mil gaya toh usey set karein
        }
      }

      // Initial network ki details set karein
      final initialNetwork = fetchedNetworks[initialIndex];
      networkIdToFetch = initialNetwork.id;

      setState(() {
        _apiNetworks = fetchedNetworks;
        _uniqueNetworks = _apiNetworks.map((n) => n.name).toList();

        // State ko initial values se set karein
        _focusedNetworkIndex = initialIndex;
        _selectedNetworkName = initialNetwork.name;
      });

      // 2. Fetch TV Channels for the *selected* network
      final fetchedList =
          await _fetchTvShowsForNetwork(networkIdToFetch); // <-- NAYA

      // ✅ --- END: BADLAAV KHATAM ---

      if (!mounted) return;

      setState(() {
        _tvShowList = fetchedList;
        if (_tvShowList.isEmpty)
          _errorMessage =
              "No TV Channels Found for this network."; // Updated message
      });

      if (_errorMessage == null) {
        _processInitialData();
        _updateChannelFilters(); // This will select the first channel
        await _fetchDataForView(); // Fetch shows for the first channel
        _initializeFocusNodes();
        _startAnimations();

        // ✅ --- START: YAHAN BADLAAV KIYA GAYA HAI ---
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              _networkFocusNodes.isNotEmpty &&
              _focusedNetworkIndex < _networkFocusNodes.length) {
            // Sahi index par focus request karein
            _networkFocusNodes[_focusedNetworkIndex].requestFocus();

            // Us index tak scroll bhi karein
            _updateAndScrollToFocus(
                _networkFocusNodes,
                _focusedNetworkIndex,
                _networkScrollController,
                160 // Yeh aapke network button ki average width hai
                );
          }
        });
        // ✅ --- END: BADLAAV KHATAM ---
      }
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Failed to load initial data.\nPlease check your connection.";
          debugPrint("Error fetching initial data: $e");
        });
      }
    }
  }

  Future<List<TvShowModel>> _fetchTvShowsForNetwork(int networkId) async {
    try {
            String authKey = SessionManager.authKey ;
      var url = Uri.parse(SessionManager.baseUrl + 'getTvChannelsPak?content_network=$networkId');
      final response = await https.get(url,
        // Uri.parse(
        //     'https://dashboard.cpplayers.com/api/v3/getTvChannelsPak?content_network=$networkId'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain': SessionManager.savedDomain,
        },
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return [];

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) => TvShowModel.fromJson(item as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load tv channels for network $networkId: $e');
      throw Exception('Failed to load tv channels for network $networkId: $e');
    }
  }

  Future<List<TvShowItemModel>> _fetchTvShowsForChannel(int channelId) async {
            String authKey = SessionManager.authKey ;
      var url = Uri.parse(SessionManager.baseUrl + 'getTvShowsPak/$channelId');
    try {
      final response = await https.get(url,
        // Uri.parse(
        //     'https://dashboard.cpplayers.com/api/v3/getTvShowsPak/$channelId'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain': SessionManager.savedDomain,
        },
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return [];

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) =>
                TvShowItemModel.fromJson(item as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load tv shows for channel $channelId: $e');
      throw Exception('Failed to load tv shows for channel $channelId: $e');
    }
  }

  Future<List<ApiNetworkModel>> _fetchNetworks() async {
            String authKey = SessionManager.authKey ;
      var url = Uri.parse(SessionManager.baseUrl + 'getNetworks');
    try {
      final response = await https
          .post(url,
            // Uri.parse('https://dashboard.cpplayers.com/api/v3/getNetworks'),
            headers: {
              'auth-key': authKey,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'domain': SessionManager.savedDomain,
            },
            body: json.encode({
              "network_id": "",
              "data_for": "tvshowspak"
            }), // <--- BADLAAV YAHAN
          )
          .timeout(const Duration(seconds: 30));

      if (!mounted) return [];

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) =>
                ApiNetworkModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load networks: $e');
      throw Exception('Failed to load networks: $e');
    }
  }

  void _processInitialData() {
    if (_apiNetworks.isEmpty) return;
    // _uniqueNetworks pehle hi _fetchDataForPage mein set ho chuka hai
    // _selectedNetworkName pehle hi _fetchDataForPage mein set ho chuka hai
    _updateSelectedNetworkData(); // Slider/Background
  }

  //=================================================
  // SECTION 2.3: STATE MANAGEMENT & UI LOGIC (ke Aas Paas Add Karein)
  //=================================================

  // UI REFACTOR: Function from WebSeries
  void _focusFirstListItemWithScroll() {
    if (_itemFocusNodes.isEmpty) return;

    if (_listScrollController.hasClients) {
      _listScrollController.animateTo(
        0.0,
        duration: AnimationTiming.fast, // 250ms
        curve: Curves.easeInOut,
      );
    }

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted && _itemFocusNodes.isNotEmpty) {
        setState(() => _focusedItemIndex = 0);
        _itemFocusNodes[0].requestFocus();
      }
    });
  }

  //=================================================
  // SECTION 2.2: KEYBOARD AND FOCUS NAVIGATION
  //=================================================

  KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent || _isListLoading || _isLoading)
      return KeyEventResult.ignored;

    bool searchHasFocus = _searchButtonFocusNode.hasFocus;
    bool networkHasFocus = _networkFocusNodes.any((n) => n.hasFocus);
    bool channelFilterHasFocus =
        _channelFilterFocusNodes.any((n) => n.hasFocus);
    bool listHasFocus = _itemFocusNodes.any((n) => n.hasFocus);
    bool keyboardHasFocus = _keyboardFocusNodes.any((n) => n.hasFocus);
    final LogicalKeyboardKey key = event.logicalKey;

    if (key == LogicalKeyboardKey.goBack) {
      if (_showKeyboard) {
        setState(() {
          _showKeyboard = false;
          _focusedKeyRow = 0;
          _focusedKeyCol = 0;
        });
        _searchButtonFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (listHasFocus || channelFilterHasFocus || searchHasFocus) {
        if (_networkFocusNodes.isNotEmpty) {
          _networkFocusNodes[_focusedNetworkIndex].requestFocus();
        }
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (keyboardHasFocus && _showKeyboard) {
      return _navigateKeyboard(key);
    }

    if (searchHasFocus) {
      if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
        setState(() {
          _showKeyboard = true;
          _focusedKeyRow = 0;
          _focusedKeyCol = 0;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _keyboardFocusNodes.isNotEmpty) {
            _keyboardFocusNodes[0].requestFocus();
          }
        });
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowLeft) {
        // UI REFACTOR: Logic from WebSeries
        return KeyEventResult.handled; // Do nothing
      }
      if (key == LogicalKeyboardKey.arrowRight &&
          _channelFilterFocusNodes.isNotEmpty) {
        _channelFilterFocusNodes[0].requestFocus();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowUp && _networkFocusNodes.isNotEmpty) {
        _networkFocusNodes[_focusedNetworkIndex].requestFocus();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
        _focusFirstListItemWithScroll();
        return KeyEventResult.handled;
      }
      return KeyEventResult.handled;
    }

    if ([
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.select,
      LogicalKeyboardKey.enter
    ].contains(key)) {
      if (networkHasFocus) {
        _navigateNetworks(key);
      } else if (channelFilterHasFocus) {
        _navigateChannelFilters(key);
      } else if (listHasFocus) {
        _navigateList(key);
      } // UI REFACTOR: Uses new _navigateList
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // UI REFACTOR: _navigateList from WebSeries, adapted for TvShow state
  void _navigateList(LogicalKeyboardKey key) {
    // Agar navigation pehle se locked hai, to function se bahar nikal jao
    if (_isNavigationLocked) return;

    if (_focusedItemIndex == -1 || _itemFocusNodes.isEmpty) return;

    // Navigation ko turant lock karo
    setState(() {
      _isNavigationLocked = true;
    });

    // Ek chota Timer set karo jo lock ko thodi der baad khol dega
    // Yeh 700ms ka cooldown period dega
    _navigationLockTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _isNavigationLocked = false;
        });
      }
    });

    int newIndex = _focusedItemIndex;

    if (key == LogicalKeyboardKey.arrowUp) {
      setState(() => _lastNavigationDirection = 'vertical');
      if (_channelFilterFocusNodes.isNotEmpty) {
        _channelFilterFocusNodes[_focusedChannelFilterIndex].requestFocus();
      } else {
        _searchButtonFocusNode.requestFocus();
      }
      setState(() => _focusedItemIndex = -1);

      // Lock aur timer ko cancel kar do kyunki hum list se bahar ja rahe hain
      _isNavigationLocked = false;
      _navigationLockTimer?.cancel();
      return;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      // arrowDown par kuch nahi karna hai, isliye lock hata do
      _isNavigationLocked = false;
      _navigationLockTimer?.cancel();
      return;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (newIndex > 0) {
        newIndex--;
        setState(() => _lastNavigationDirection = 'horizontal');
      }
    } else if (key == LogicalKeyboardKey.arrowRight) {
      final currentList = _displayList; // Use TvShow state
      if (newIndex + 1 < currentList.length) {
        newIndex++;
        setState(() => _lastNavigationDirection = 'horizontal');
      }
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter) {
      // Enter/Select par cooldown nahi chahiye, isliye lock turant hata do
      _isNavigationLocked = false;
      _navigationLockTimer?.cancel();

      final currentList = _displayList; // Use TvShow state
      _navigateToTvShowDetails(currentList[_focusedItemIndex],
          _focusedItemIndex); // Use TvShow navigation
      return;
    }

    if (newIndex != _focusedItemIndex &&
        newIndex >= 0 &&
        newIndex < _itemFocusNodes.length) {
      setState(() => _focusedItemIndex = newIndex);
      _itemFocusNodes[newIndex].requestFocus();
    } else {
      // Agar index nahi badla (e.g., pehle item par left dabaya), to lock hata do
      _isNavigationLocked = false;
      _navigationLockTimer?.cancel();
    }
  }

  // UI REFACTOR: _navigateNetworks from WebSeries, adapted for TvShow state
  void _navigateNetworks(LogicalKeyboardKey key) {
    int newIndex = _focusedNetworkIndex;
    if (key == LogicalKeyboardKey.arrowLeft) {
      if (newIndex > 0) {
        newIndex--;
        setState(() => _lastNavigationDirection = 'horizontal');
      }
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (newIndex < _uniqueNetworks.length - 1) {
        newIndex++;
        setState(() => _lastNavigationDirection = 'horizontal');
      }
    } else if (key == LogicalKeyboardKey.arrowDown) {
      setState(() => _lastNavigationDirection = 'vertical');
      // _updateSelectedNetwork(); // Don't update on down, only on select
      _searchButtonFocusNode.requestFocus();
      return;
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter) {
      _updateSelectedNetwork(); // Update on select
      return;
    }
    if (newIndex != _focusedNetworkIndex) {
      setState(() => _focusedNetworkIndex = newIndex);
      _networkFocusNodes[newIndex].requestFocus();
      _updateAndScrollToFocus(
          _networkFocusNodes, newIndex, _networkScrollController, 160);
    }
  }

  // UI REFACTOR: _navigateGenres from WebSeries, adapted for TvShow state
  void _navigateChannelFilters(LogicalKeyboardKey key) {
    final filterNames = _channelFilters.keys.toList();

    // Agar filter list khali hai
    if (filterNames.isEmpty) {
      if (key == LogicalKeyboardKey.arrowLeft) {
        _searchButtonFocusNode.requestFocus();
      } else if (key == LogicalKeyboardKey.arrowUp &&
          _networkFocusNodes.isNotEmpty) {
        setState(() => _lastNavigationDirection = 'vertical');
        _networkFocusNodes[_focusedNetworkIndex].requestFocus();
      } else if (key == LogicalKeyboardKey.arrowDown &&
          _itemFocusNodes.isNotEmpty) {
        setState(() => _lastNavigationDirection = 'vertical');
        _focusFirstListItemWithScroll();
      }
      return; // Baaki keys ignore karein
    }

    int newIndex = _focusedChannelFilterIndex;
    if (key == LogicalKeyboardKey.arrowLeft) {
      if (newIndex > 0) {
        newIndex--;
        setState(() => _lastNavigationDirection = 'horizontal');
      } else {
        _searchButtonFocusNode.requestFocus();
        return;
      }
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (newIndex < filterNames.length - 1) {
        newIndex++;
        setState(() => _lastNavigationDirection = 'horizontal');
      }
    } else if (key == LogicalKeyboardKey.arrowUp) {
      if (_networkFocusNodes.isNotEmpty) {
        setState(() => _lastNavigationDirection = 'vertical');
        _networkFocusNodes[_focusedNetworkIndex].requestFocus();
      }
      return;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      setState(() => _lastNavigationDirection = 'vertical');
      // _updateSelectedChannelFilter(); // Don't update on down, only on select
      if (_itemFocusNodes.isNotEmpty) {
        _focusFirstListItemWithScroll();
      }
      return;
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter) {
      _updateSelectedChannelFilter(); // Update on select
      return;
    }
    if (newIndex != _focusedChannelFilterIndex) {
      setState(() => _focusedChannelFilterIndex = newIndex);
      _channelFilterFocusNodes[newIndex].requestFocus();
      _updateAndScrollToFocus(_channelFilterFocusNodes, newIndex,
          _channelFilterScrollController, 160); // 160 is approx width
    }
  }

  // UI REFACTOR: _navigateKeyboard from WebSeries
  KeyEventResult _navigateKeyboard(LogicalKeyboardKey key) {
    int newRow = _focusedKeyRow;
    int newCol = _focusedKeyCol;
    if (key == LogicalKeyboardKey.arrowUp) {
      if (newRow > 0) {
        newRow--;
        newCol = math.min(newCol, _keyboardLayout[newRow].length - 1);
      }
    } else if (key == LogicalKeyboardKey.arrowDown) {
      if (newRow < _keyboardLayout.length - 1) {
        newRow++;
        newCol = math.min(newCol, _keyboardLayout[newRow].length - 1);
      }
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (newCol > 0) newCol--;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (newCol < _keyboardLayout[newRow].length - 1) newCol++;
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter) {
      final keyValue = _keyboardLayout[newRow][newCol];
      _onKeyPressed(keyValue);
      return KeyEventResult.handled;
    }

    if (newRow != _focusedKeyRow || newCol != _focusedKeyCol) {
      setState(() {
        _focusedKeyRow = newRow;
        _focusedKeyCol = newCol;
      });
      final focusIndex = _getFocusNodeIndexForKey(newRow, newCol);
      if (focusIndex >= 0 && focusIndex < _keyboardFocusNodes.length) {
        _keyboardFocusNodes[focusIndex].requestFocus();
      }
    }
    return KeyEventResult.handled;
  }

  //=================================================
  // SECTION 2.3: STATE MANAGEMENT & UI LOGIC
  //=================================================

  // Data logic (fetching, filtering) remains from TvShowSliderScreen
  Future<void> _fetchDataForView() async {
    _debounce?.cancel();

    setState(() {
      _isListLoading = true;
      _displayList.clear();
      _currentViewMasterList.clear();
      _rebuildItemFocusNodes();
      _errorMessage = null;

      _searchText = '';
      _isSearching = false;
    });

    List<TvShowModel> newMasterList = [];

    try {
      if (_selectedChannelFilterId != null) {
        final List<TvShowItemModel> showItems =
            await _fetchTvShowsForChannel(_selectedChannelFilterId!);

        newMasterList = showItems
            .map((show) => TvShowModel(
                  id: show.id,
                  name: show.name,
                  poster: show.thumbnail,
                  banner: show.thumbnail,
                  updatedAt: '',
                  order: show.order,
                  genre: show.genre,
                  language: null,
                ))
            .toList();
        _isDisplayingShows = true;
      } else {
        newMasterList = [];
        _isDisplayingShows = false;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load data. Please try again.";
          debugPrint("Error in _fetchDataForView: $e");
        });
        newMasterList = [];
      }
    }

    if (!mounted) return;

    setState(() {
      _currentViewMasterList = newMasterList;
      _displayList = List.from(_currentViewMasterList);
      _isListLoading = false;
      _rebuildItemFocusNodes();
      _focusedItemIndex = -1;

      if (_displayList.isNotEmpty) {
        _focusFirstListItemWithScroll();
      }
    });

    _startAnimations();
  }

  // void _applySearchFilter() {
  //  if (!mounted) return;

  //  List<TvShowModel> filteredList = [];
  //  if (_isSearching && _searchText.isNotEmpty) {
  //    final searchTerm = _searchText.toLowerCase();
  //    filteredList = _currentViewMasterList.where((item) {
  //      return item.name.toLowerCase().contains(searchTerm);
  //    }).toList();
  //  } else {
  //    filteredList = List.from(_currentViewMasterList);
  //  }

  //  setState(() {
  //    _displayList = filteredList;
  //    _rebuildItemFocusNodes();
  //    _focusedItemIndex = -1;

  //    if (_displayList.isNotEmpty) {
  //      _focusFirstListItemWithScroll();
  //    }
  //  });
  //  _startAnimations();
  // }

  // NEW: Yeh function sirf search apply karta hai, data fetch nahi karta
  void _applySearchFilter() {
    if (!mounted) return;

    List<TvShowModel> filteredList = [];
    if (_isSearching && _searchText.isNotEmpty) {
      final searchTerm = _searchText.toLowerCase();
      // Search hamesha _currentViewMasterList mein hoga
      filteredList = _currentViewMasterList.where((item) {
        return item.name.toLowerCase().contains(searchTerm);
      }).toList();
    } else {
      // Agar search khali hai, toh poori master list dikhayein
      filteredList = List.from(_currentViewMasterList);
    }

    setState(() {
      _displayList = filteredList; // Sirf display list update karein
      _rebuildItemFocusNodes();
      _focusedItemIndex =
          -1; // List index ko reset karein, lekin focus move na karein

      // ===== FIX =====
      // Neeche di gayi lines ko comment ya delete kar diya gaya hai
      // Taaki focus keyboard par hi rahe
      // if (_displayList.isNotEmpty) {
      //   _focusFirstListItemWithScroll();
      // }
      // ===== END FIX =====
    });
    _startAnimations();
  }

  void _updateSelectedNetwork() async {
    if (_apiNetworks.isEmpty || _focusedNetworkIndex >= _apiNetworks.length)
      return;

    final selectedNetwork = _apiNetworks[_focusedNetworkIndex];
    _debounce?.cancel();

    setState(() {
      _isListLoading = true;
      _errorMessage = null;
      _displayList = [];
      _currentViewMasterList.clear();
      _rebuildItemFocusNodes();
      _isSearching = false;
      _searchText = '';
    });

    try {
      final newChannelList = await _fetchTvShowsForNetwork(selectedNetwork.id);
      if (!mounted) return;

      setState(() {
        _tvShowList = newChannelList;
        _selectedNetworkName = selectedNetwork.name;
        _updateSelectedNetworkData();

        _updateChannelFilters();
        _rebuildChannelFilterFocusNodes();
      });

      await _fetchDataForView();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListLoading = false;
          _errorMessage =
              "Failed to load channels for ${selectedNetwork.name}.";
          _tvShowList = [];
          _displayList = [];
          _currentViewMasterList.clear();
          _updateChannelFilters();
          _rebuildChannelFilterFocusNodes();
          debugPrint("Error in _updateSelectedNetwork: $e");
        });
      }
    }
  }

  void _updateSelectedChannelFilter() {
    final filterNames = _channelFilters.keys.toList();
    if (filterNames.isEmpty ||
        _focusedChannelFilterIndex >= filterNames.length ||
        _channelFilterFocusNodes.isEmpty) return;

    _debounce?.cancel();

    final newFilterName = filterNames[_focusedChannelFilterIndex];
    if (newFilterName == _selectedChannelFilterName) return;

    setState(() {
      _selectedChannelFilterName = newFilterName;
      _selectedChannelFilterId = _channelFilters[_selectedChannelFilterName];
      _isDisplayingShows = (_selectedChannelFilterId != null);

      _fetchDataForView();
    });
  }

  void _updateSelectedNetworkData() {
    if (_apiNetworks.isEmpty || _focusedNetworkIndex >= _apiNetworks.length)
      return;

    final selectedNetwork = _apiNetworks.firstWhere(
        (n) => n.name == _selectedNetworkName,
        orElse: () => ApiNetworkModel(id: -1, name: '', networksOrder: 9999));

    final tvShowSliders = selectedNetwork.sliders
        .where((s) => s.sliderFor == 'tvshowspak')
        .toList();

    setState(() {
      _selectedNetworkLogo = selectedNetwork.logo;
      _currentTvShowSliders = tvShowSliders; // Use TvShow variable
      _currentSliderIndex = 0;
      if (tvShowSliders.isNotEmpty) {
        _currentBackgroundUrl = tvShowSliders.first.banner;
      } else {
        _currentBackgroundUrl = selectedNetwork.logo;
      }
    });

    if (_sliderPageController.hasClients && _currentTvShowSliders.isNotEmpty) {
      // Use TvShow variable
      _sliderPageController.jumpToPage(0);
    }
  }

  void _updateChannelFilters() {
    setState(() {
      if (_tvShowList.isEmpty) {
        _channelFilters = {};
      } else {
        final Map<String, int?> newFilters = {};
        for (final channel in _tvShowList) {
          if (channel.name.isNotEmpty &&
              !newFilters.containsKey(channel.name)) {
            newFilters[channel.name] = channel.id;
          }
        }
        _channelFilters = newFilters;
      }

      if (_channelFilters.isNotEmpty) {
        _selectedChannelFilterName = _channelFilters.keys.first;
        _selectedChannelFilterId = _channelFilters.values.first;
        _isDisplayingShows = true;
        _focusedChannelFilterIndex = 0;
      } else {
        _selectedChannelFilterName = '';
        _selectedChannelFilterId = null;
        _isDisplayingShows = false;
        _focusedChannelFilterIndex = -1;
      }

      print("Updated Channel Filters: ${_channelFilters.keys.toList()}");
    });
  }

  // UI REFACTOR: _onKeyPressed from WebSeries
  void _onKeyPressed(String value) {
    setState(() {
      if (value == 'OK') {
        _showKeyboard = false;
        if (_itemFocusNodes.isNotEmpty) {
          _itemFocusNodes.first.requestFocus();
        } else {
          _searchButtonFocusNode.requestFocus();
        }
        return;
      }
      if (value == 'DEL') {
        if (_searchText.isNotEmpty) {
          _searchText = _searchText.substring(0, _searchText.length - 1);
        }
      } else if (value == ' ') {
        if (_searchText.isNotEmpty && !_searchText.endsWith(' ')) {
          // Logic from TvShow
          _searchText += ' ';
        }
      } else {
        _searchText += value;
      }
      _isSearching = _searchText.isNotEmpty; // TvShow logic
      _debounce?.cancel(); // TvShow logic
      _debounce = Timer(const Duration(milliseconds: 400), () {
        // TvShow logic
        _applySearchFilter(); // TvShow logic
      });
    });
  }

  Future<void> _navigateToTvShowDetails(TvShowModel item, int index) async {
    if (_isVideoLoading) return;
    setState(() => _isVideoLoading = true);

    try {
      int? currentUserId = SessionManager.userId;
      HistoryService.updateUserHistory(
        userId: currentUserId!,
        contentType: 4,
        eventId: item.id,
        eventTitle: item.name,
        url: '',
        categoryId: 0,
      ).catchError((e) {
        debugPrint("History update failed: $e");
      });
    } catch (e) {
      debugPrint("Error getting userId for History: $e");
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TvShowFinalDetailsPage(
          id: item.id,
          banner: item.banner ?? item.poster ?? '',
          poster: item.poster ?? item.banner ?? '',
          name: item.name,
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _isVideoLoading = false;
        if (index >= 0 && index < _itemFocusNodes.length) {
          // Restore focus logic
          _focusedItemIndex = index;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                _itemFocusNodes.isNotEmpty &&
                _focusedItemIndex < _itemFocusNodes.length) {
              _itemFocusNodes[_focusedItemIndex].requestFocus();
              _updateAndScrollToFocus(
                  _itemFocusNodes,
                  _focusedItemIndex,
                  _listScrollController,
                  (bannerwdt * 1.2) + 12); // UI REFACTOR: Use 1.2 width
            }
          });
        } else {
          _focusedItemIndex = -1;
          if (_itemFocusNodes.isNotEmpty) {
            _focusFirstListItemWithScroll();
          } else if (_channelFilterFocusNodes.isNotEmpty &&
              _focusedChannelFilterIndex >= 0) {
            _channelFilterFocusNodes[_focusedChannelFilterIndex].requestFocus();
          } else {
            _searchButtonFocusNode.requestFocus();
          }
        }
      });
    }
  }

  //=================================================
  // SECTION 2.4: INITIALIZATION AND CLEANUP
  //=================================================

  void _initializeAnimations() {
    _fadeController =
        AnimationController(duration: AnimationTiming.medium, vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  void _startAnimations() {
    _fadeController.reset(); // Reset from TvShow logic
    _fadeController.forward();
  }

  void _initializeFocusNodes() {
    _disposeFocusNodes(_networkFocusNodes);
    _networkFocusNodes = List.generate(
        _apiNetworks.length,
        (index) => FocusNode(debugLabel: 'Network-$index')
          ..addListener(_setStateListener)); // Add listener
    _rebuildChannelFilterFocusNodes();
    _rebuildItemFocusNodes();
    _rebuildKeyboardFocusNodes();
  }

  void _rebuildChannelFilterFocusNodes() {
    _disposeFocusNodes(_channelFilterFocusNodes);
    _channelFilterFocusNodes = List.generate(
        _channelFilters.length,
        (index) => FocusNode(debugLabel: 'ChannelFilter-$index')
          ..addListener(_setStateListener)); // Add listener
  }

  void _rebuildItemFocusNodes() {
    _disposeFocusNodes(_itemFocusNodes);
    final currentList = _displayList;
    _itemFocusNodes = List.generate(
        currentList.length,
        (index) => FocusNode(debugLabel: 'Item-$index')
          ..addListener(_setStateListener)); // Add listener
  }

  void _rebuildKeyboardFocusNodes() {
    _disposeFocusNodes(_keyboardFocusNodes);
    int totalKeys = _keyboardLayout.fold(0, (prev, row) => prev + row.length);
    _keyboardFocusNodes = List.generate(
        totalKeys,
        (index) => FocusNode(debugLabel: 'Key-$index')
          ..addListener(_setStateListener)); // Add listener
  }

  int _getFocusNodeIndexForKey(int row, int col) {
    int index = 0;
    for (int r = 0; r < row; r++) {
      index += _keyboardLayout[r].length;
    }
    return index + col;
  }

  // UI REFACTOR: Add _setStateListener
  void _setStateListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _disposeFocusNodes(List<FocusNode> nodes) {
    for (var node in nodes) {
      node.removeListener(_setStateListener); // Remove listener
      node.dispose();
    }
    nodes.clear(); // Clear from TvShow logic
  }

  // UI REFACTOR: _updateAndScrollToFocus from WebSeries
  void _updateAndScrollToFocus(List<FocusNode> nodes, int index,
      ScrollController controller, double itemWidth) {
    if (!mounted ||
        index < 0 ||
        index >= nodes.length ||
        !controller.hasClients) return;
    double screenWidth = MediaQuery.of(context).size.width;
    // Use WebSeries logic
    double scrollPosition =
        (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    controller.animateTo(
      scrollPosition.clamp(0.0, controller.position.maxScrollExtent),
      duration: AnimationTiming.fast,
      curve: Curves.easeInOut,
    );
  }

  //=================================================
  // SECTION 2.5: WIDGET BUILDER METHODS
  //=================================================

  // UI REFACTOR: _buildPageContent from WebSeries
  Widget _buildPageContent() {
    return Padding(
      // Use WebSeries padding
      padding: EdgeInsets.symmetric(
          horizontal: screenwdt * 0.02, vertical: screenhgt * 0.02),
      child: Column(
        children: [
          _buildTopFilterBar(),
          Expanded(
            // Use WebSeries layout
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildContentBody(),
            ),
          ),
        ],
      ),
    );
  }

  // UI REFACTOR: _buildContentBody from WebSeries
  Widget _buildContentBody() {
    return Column(
      children: [
        SizedBox(
          // Keyboard placeholder
          height: screenhgt * 0.5,
          child: _showKeyboard ? _buildSearchUI() : const SizedBox.shrink(),
        ),
        _buildSliderIndicators(),
        _buildChannelFilterAndSearchButtons(), // Renamed call
        SizedBox(height: screenhgt * 0.02),
        _buildTvShowList(), // Renamed call
      ],
    );
  }

  // UI REFACTOR: _buildBackgroundOrSlider from WebSeries
  Widget _buildBackgroundOrSlider() {
    if (_currentTvShowSliders.isNotEmpty) {
      // Use TvShow variable
      return TvShowBannerSlider(
        // Use TvShow widget
        sliders: _currentTvShowSliders, // Use TvShow variable
        controller: _sliderPageController,
        onPageChanged: (index) {
          if (mounted) {
            setState(() {
              _currentSliderIndex = index;
            });
          }
        },
      );
    } else {
      return _buildDynamicBackground();
    }
  }

  // UI REFACTOR: _buildDynamicBackground from WebSeries
  Widget _buildDynamicBackground() {
    return AnimatedSwitcher(
      duration: AnimationTiming.medium,
      child: _currentBackgroundUrl != null && _currentBackgroundUrl!.isNotEmpty
          ? Container(
              key: ValueKey<String>(_currentBackgroundUrl!),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_currentBackgroundUrl!),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // Added error handler
                    debugPrint(
                        'Error loading background image: $_currentBackgroundUrl');
                  },
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ProfessionalColors.primaryDark.withOpacity(0.2),
                      ProfessionalColors.primaryDark.withOpacity(0.4),
                      ProfessionalColors.primaryDark.withOpacity(0.6),
                      ProfessionalColors.primaryDark.withOpacity(0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 0.7, 0.9],
                  ),
                ),
              ),
            )
          : Container(
              key: const ValueKey<String>('no_bg'),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ProfessionalColors.primaryDark,
                    ProfessionalColors.surfaceDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
    );
  }

  // UI REFACTOR: _buildTopFilterBar from WebSeries
  Widget _buildTopFilterBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 5,
            bottom: 5,
            left: screenwdt * 0.015,
            right: 0,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(child: _buildNetworkFilter()),
            ],
          ),
        ),
      ),
    );
  }

  // UI REFACTOR: _buildNetworkFilter from WebSeries
  Widget _buildNetworkFilter() {
    return SizedBox(
      height: 30,
      child: Center(
        child: ListView.builder(
          controller: _networkScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: _uniqueNetworks.length,
          itemBuilder: (context, index) {
            if (index >= _networkFocusNodes.length)
              return const SizedBox.shrink(); // Guard
            final networkName = _uniqueNetworks[index];
            final focusNode = _networkFocusNodes[index];
            final isSelected = _selectedNetworkName == networkName;

            return Focus(
              focusNode: focusNode,
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  setState(() => _focusedNetworkIndex = index);
                  // Scroll is handled by _navigateNetworks
                }
              },
              child: _buildGlassEffectButton(
                // Use WebSeries button
                focusNode: focusNode,
                isSelected: isSelected,
                focusColor: _focusColors[index % _focusColors.length],
                onTap: () {
                  setState(() => _focusedNetworkIndex = index);
                  focusNode.requestFocus();
                  _updateSelectedNetwork();
                },
                child: Text(
                  networkName.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: focusNode.hasFocus || isSelected
                        ? FontWeight.bold
                        : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // UI REFACTOR: _buildGenreAndSearchButtons from WebSeries, adapted for TvShow state
  Widget _buildChannelFilterAndSearchButtons() {
    final filterNames = _channelFilters.keys.toList();

    if (filterNames.isEmpty && !_isSearching) {
      return const SizedBox(height: 30); // Keep height consistent
    }

    // Removed _isGenreLoading check

    return SizedBox(
      height: 30,
      child: Center(
        child: ListView.builder(
          controller: _channelFilterScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: filterNames.length + 1, // +1 for Search button
          padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.015),
          itemBuilder: (context, index) {
            if (index == 0) {
              // Search Button
              return Focus(
                focusNode: _searchButtonFocusNode,
                child: _buildGlassEffectButton(
                  focusNode: _searchButtonFocusNode,
                  isSelected: _isSearching || _showKeyboard, // Use TvShow logic
                  focusColor: ProfessionalColors.accentOrange,
                  onTap: () {
                    _searchButtonFocusNode.requestFocus();
                    setState(() {
                      _showKeyboard = true;
                      _focusedKeyRow = 0;
                      _focusedKeyCol = 0;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _keyboardFocusNodes.isNotEmpty) {
                        _keyboardFocusNodes[0].requestFocus();
                      }
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        ("Search").toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold, // Always bold
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Channel Filter Buttons
            final filterIndex = index - 1;
            if (filterIndex >= filterNames.length ||
                filterIndex >= _channelFilterFocusNodes.length) {
              return const SizedBox.shrink(); // Guard
            }
            final filterName = filterNames[filterIndex];
            final focusNode = _channelFilterFocusNodes[filterIndex];
            final isSelected =
                !_isSearching && _selectedChannelFilterName == filterName;

            return Focus(
              focusNode: focusNode,
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  setState(() => _focusedChannelFilterIndex = filterIndex);
                  // Scroll is handled by _navigateChannelFilters
                }
              },
              child: _buildGlassEffectButton(
                focusNode: focusNode,
                isSelected: isSelected,
                focusColor: _focusColors[filterIndex % _focusColors.length],
                onTap: () {
                  setState(() => _focusedChannelFilterIndex = filterIndex);
                  focusNode.requestFocus();
                  _updateSelectedChannelFilter();
                },
                child: Text(
                  filterName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold, // Always bold
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // UI REFACTOR: _buildWebSeriesList from WebSeries, adapted for TvShow state
  Widget _buildTvShowList() {
    final currentList = _displayList;

    // Removed _isSearchLoading check

    if (currentList.isEmpty && !_isListLoading) {
      // Check global list loading
      return Expanded(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ProfessionalColors.surfaceDark.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.tv_off_rounded,
                  size: 25,
                  color: ProfessionalColors.textSecondary,
                ),
                Text(
                  _isSearching && _searchText.isNotEmpty
                      ? "No results found for '$_searchText'"
                      : 'No items available for this filter.', // Updated text
                  style: const TextStyle(
                    color: ProfessionalColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // UI REFACTOR: Use Expanded to fill space
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: ListView.builder(
          controller: _listScrollController,
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.015),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            if (index >= _itemFocusNodes.length)
              return const SizedBox.shrink(); // Guard
            final item = currentList[index];
            final focusNode = _itemFocusNodes[index];

            return Container(
              width: bannerwdt * 1.2, // Use WebSeries width
              margin: const EdgeInsets.only(right: 12.0),
              child: InkWell(
                focusNode: focusNode,
                onTap: () => _navigateToTvShowDetails(item, index),
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    setState(() => _focusedItemIndex = index);
                    _updateAndScrollToFocus(_itemFocusNodes, index,
                        _listScrollController, (bannerwdt * 1.2) + 12);
                  }
                },
                child: OptimizedTvShowCard(
                  // Use new card
                  tvShow: item, // Pass TvShowModel
                  isFocused: _focusedItemIndex == index,
                  onTap: () => _navigateToTvShowDetails(item, index),
                  cardHeight: bannerhgt * 1.2, // Use WebSeries height
                  networkLogo: _isDisplayingShows
                      ? null
                      : _selectedNetworkLogo, // Keep TvShow logic
                  uniqueIndex: index,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // UI REFACTOR: _buildSearchUI from WebSeries
  Widget _buildSearchUI() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      ProfessionalColors.accentBlue,
                      ProfessionalColors.accentPurple,
                    ],
                  ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: Text(
                    "Search in $_selectedChannelFilterName", // Use TvShow text
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    maxLines: 2, // Allow wrapping
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: ProfessionalColors.accentPurple, width: 2),
                  ),
                  child: Text(
                    _searchText.isEmpty ? 'Start typing...' : _searchText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          _searchText.isEmpty ? Colors.white54 : Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: _buildQwertyKeyboard(),
        ),
      ],
    );
  }

  // UI REFACTOR: _buildQwertyKeyboard from WebSeries
  Widget _buildQwertyKeyboard() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (int rowIndex = 0; rowIndex < _keyboardLayout.length; rowIndex++)
            _buildKeyboardRow(_keyboardLayout[rowIndex], rowIndex),
        ],
      ),
    );
  }

  // UI REFACTOR: _buildKeyboardRow from WebSeries
  Widget _buildKeyboardRow(List<String> keys, int rowIndex) {
    int startIndex =
        _getFocusNodeIndexForKey(rowIndex, 0); // Use TvShow function

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.asMap().entries.map((entry) {
        final colIndex = entry.key;
        final key = entry.value;
        if (startIndex + colIndex >= _keyboardFocusNodes.length)
          return const SizedBox.shrink(); // Guard
        final focusIndex = startIndex + colIndex;
        final focusNode = _keyboardFocusNodes[focusIndex];
        final isFocused =
            _focusedKeyRow == rowIndex && _focusedKeyCol == colIndex;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        double width;
        if (key == ' ') {
          width = screenWidth * 0.315;
        } else if (key == 'OK' || key == 'DEL') {
          width = screenWidth * 0.09;
        } else {
          width = screenWidth * 0.045;
        }

        return Container(
          width: width,
          height: screenHeight * 0.08,
          margin: const EdgeInsets.all(4.0),
          child: Focus(
            focusNode: focusNode,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  _focusedKeyRow = rowIndex;
                  _focusedKeyCol = colIndex;
                });
              }
            },
            child: ElevatedButton(
              onPressed: () => _onKeyPressed(key),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFocused
                    ? ProfessionalColors.accentPurple
                    : Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: isFocused
                      ? const BorderSide(color: Colors.white, width: 3)
                      : BorderSide.none,
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // UI REFACTOR: _buildSliderIndicators from WebSeries
  Widget _buildSliderIndicators() {
    if (_currentTvShowSliders.length <= 1) {
      // Use TvShow variable
      return const SizedBox(height: 28); // Match WebSeries height (10+8+10)
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_currentTvShowSliders.length, (index) {
        // Use TvShow variable
        bool isActive = _currentSliderIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
          height: 8.0,
          width: isActive ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  // UI REFACTOR: _buildGlassEffectButton from WebSeries
  Widget _buildGlassEffectButton({
    required FocusNode focusNode,
    required VoidCallback onTap,
    required bool isSelected,
    required Color focusColor,
    required Widget child,
  }) {
    bool hasFocus = focusNode.hasFocus;
    bool isHighlighted = hasFocus || isSelected;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
              decoration: BoxDecoration(
                color: hasFocus
                    ? focusColor
                    : isSelected
                        ? focusColor.withOpacity(0.5)
                        : Colors.white.withOpacity(0.08),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.white.withOpacity(0.1),
                  ],
                  stops: const [0.0, 0.8],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color:
                      hasFocus ? Colors.white : Colors.white.withOpacity(0.3),
                  width: hasFocus ? 3 : 2,
                ),
                boxShadow: isHighlighted
                    ? [
                        BoxShadow(
                          color: focusColor.withOpacity(0.8),
                          blurRadius: 15,
                          spreadRadius: 3,
                        )
                      ]
                    : null,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // UI REFACTOR: _buildErrorWidget from WebSeries
  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: ProfessionalColors.surfaceDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Colors.red,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ProfessionalColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              focusNode: FocusNode(), // An unfocusable node
              onPressed: () => _fetchDataForPage(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: ProfessionalColors.accentBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//==============================================================================
// SECTION 3: REUSABLE UI COMPONENTS
//==============================================================================

// UI REFACTOR: OptimizedTvShowCard based on WebSeries card
class OptimizedTvShowCard extends StatelessWidget {
  final TvShowModel tvShow; // Use TvShowModel
  final bool isFocused;
  final VoidCallback onTap;
  final double cardHeight;
  final String? networkLogo;
  final int uniqueIndex;

  const OptimizedTvShowCard({
    Key? key,
    required this.tvShow, // Use TvShowModel
    required this.isFocused,
    required this.onTap,
    required this.cardHeight,
    this.networkLogo,
    required this.uniqueIndex,
  }) : super(key: key);

  final List<Color> _focusColors = const [
    ProfessionalColors.accentBlue,
    ProfessionalColors.accentPurple,
    ProfessionalColors.accentPink,
    ProfessionalColors.accentOrange,
    ProfessionalColors.accentRed
  ];

  @override
  Widget build(BuildContext context) {
    final focusColor = _focusColors[uniqueIndex % _focusColors.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: cardHeight,
          child: AnimatedContainer(
            duration: AnimationTiming.fast,
            transform: isFocused
                ? (Matrix4.identity()..scale(1.05))
                : Matrix4.identity(),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: isFocused
                    ? Border.all(color: focusColor, width: 3)
                    : Border.all(color: Colors.transparent, width: 3),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                            color: focusColor.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 1)
                      ]
                    : []),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildTvShowImage(), // Use updated image builder
                  if (isFocused)
                    Positioned(
                        left: 5,
                        top: 5,
                        child: Container(
                            color: Colors.black.withOpacity(0.4),
                            child: Icon(Icons.play_circle_filled_outlined,
                                color: focusColor, size: 40))),
                  if (networkLogo != null && networkLogo!.isNotEmpty)
                    Positioned(
                        top: 5,
                        right: 5,
                        child: CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(networkLogo!),
                            backgroundColor: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 2.0, right: 2.0),
          child: Text(tvShow.name, // Use tvShow.name
              style: TextStyle(
                  color:
                      isFocused ? focusColor : ProfessionalColors.textSecondary,
                  fontSize: 14,
                  fontWeight: isFocused ? FontWeight.bold : FontWeight.normal),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  // UI REFACTOR: _buildWebSeriesImage from WebSeries, adapted
  Widget _buildTvShowImage() {
    final imageUrl = tvShow.poster; // Use tvShow.poster

    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            fit: BoxFit.fill, // Keep 'contain' from TvShow logic for logos
            // `loadingBuilder` ka istemal placeholder dikhane ke liye kiya gaya hai.
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildImagePlaceholder();
            },
            // `errorBuilder` ka istemal error hone par placeholder dikhane ke liye kiya gaya hai.
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              debugPrint(
                  'Error loading item image: $imageUrl, Error: $exception');
              return _buildImagePlaceholder();
            },
          )
        : _buildImagePlaceholder();
  }

  // UI REFACTOR: _buildImagePlaceholder from WebSeries
  Widget _buildImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ProfessionalColors.accentGreen, // Use WebSeries colors
            ProfessionalColors.accentBlue,
          ],
        ),
      ),
      child: const Icon(
        Icons.tv_rounded, // Use TvShow icon
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

// UI REFACTOR: TvShowBannerSlider based on WebSeries
class TvShowBannerSlider extends StatefulWidget {
  final List<SliderModel> sliders;
  final ValueChanged<int> onPageChanged;
  final PageController controller;

  const TvShowBannerSlider({
    Key? key,
    required this.sliders,
    required this.onPageChanged,
    required this.controller,
  }) : super(key: key);

  @override
  _TvShowBannerSliderState createState() => _TvShowBannerSliderState();
}

class _TvShowBannerSliderState extends State<TvShowBannerSlider> {
  Timer? _timer;
  double _opacity = 1.0; // From WebSeries

  @override
  void initState() {
    super.initState();
    if (widget.sliders.length > 1) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(TvShowBannerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sliders.length != widget.sliders.length) {
      _timer?.cancel();
      if (widget.sliders.length > 1) {
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      // Use WebSeries 8s duration
      if (!mounted ||
          !widget.controller.hasClients ||
          widget.sliders.length <= 1) return;

      int currentPage = widget.controller.page?.round() ?? 0;
      int nextPage = (currentPage + 1) % widget.sliders.length;

      widget.controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sliders.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      // Use WebSeries opacity
      opacity: _opacity,
      duration: const Duration(milliseconds: 400),
      child: PageView.builder(
        controller: widget.controller,
        itemCount: widget.sliders.length,
        onPageChanged: widget.onPageChanged,
        itemBuilder: (context, index) {
          final slider = widget.sliders[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                slider.banner,
                fit: BoxFit.fill,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Container(color: ProfessionalColors.surfaceDark),
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading slider image: ${slider.banner}');
                  return Container(color: ProfessionalColors.surfaceDark);
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ProfessionalColors.primaryDark.withOpacity(0.2),
                      ProfessionalColors.primaryDark.withOpacity(0.4),
                      ProfessionalColors.primaryDark.withOpacity(0.6),
                      ProfessionalColors.primaryDark.withOpacity(0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 0.7, 0.9], // Use WebSeries stops
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
