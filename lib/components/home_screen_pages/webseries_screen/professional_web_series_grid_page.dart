








import 'dart:async';
import 'dart:convert';
import 'dart:ui';
// CHANGE 1: CachedNetworkImage import ko hata diya gaya hai.
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// NOTE: Apne project ke anusaar neeche di gayi import lines ko aavashyakta anusaar badlein.
// Make sure to change the import lines below according to your project structure.
import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/webseries_details_page.dart';
import 'package:mobi_tv_entertainment/main.dart';
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

class WebSeriesModel {
  final int id;
  final String name;
  final String updatedAt;
  final String? poster;
  final String? banner;
  final String? genres;
  final int seriesOrder;
  final List<NetworkModel> networks;

  WebSeriesModel({
    required this.id,
    required this.name,
    required this.updatedAt,
    this.poster,
    this.banner,
    this.genres,
    required this.seriesOrder,
    this.networks = const [],
  });

  factory WebSeriesModel.fromJson(Map<String, dynamic> json) {
    var networks = (json['networks'] as List? ?? [])
        .map((item) => NetworkModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return WebSeriesModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      poster: json['poster'],
      banner: json['banner'],
      genres: json['genres'],
      seriesOrder: json['series_order'] ?? 9999,
      networks: networks,
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

class ProfessionalWebSeriesGridPage extends StatefulWidget {
  final String title;
  const ProfessionalWebSeriesGridPage({Key? key, this.title = 'All Web Series'})
      : super(key: key);

  @override
  _ProfessionalWebSeriesGridPageState createState() =>
      _ProfessionalWebSeriesGridPageState();
}

class _ProfessionalWebSeriesGridPageState
    extends State<ProfessionalWebSeriesGridPage>
    with SingleTickerProviderStateMixin {
  List<WebSeriesModel> _webSeriesList = [];
  bool _isLoading = true;
  String? _errorMessage;

  // CHANGE 2: Cache se sambandhit variables hata diye gaye hain.
  // static const String _cacheKeyWebSeries = 'grid_page_cached_web_series';
  // static const String _cacheKeyTimestamp = 'grid_page_cached_web_series_timestamp';
  // static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour cache

  // Focus and Scroll Controllers
  List<FocusNode> _itemFocusNodes = [];
  List<FocusNode> _networkFocusNodes = [];
  List<FocusNode> _genreFocusNodes = [];
  List<FocusNode> _keyboardFocusNodes = [];
  final FocusNode _widgetFocusNode = FocusNode();
  final ScrollController _listScrollController = ScrollController();
  final ScrollController _networkScrollController = ScrollController();
  final ScrollController _genreScrollController = ScrollController();

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
  int _focusedGenreIndex = 0;
  int _focusedItemIndex = -1;
  String _selectedNetworkName = '';
  String? _selectedNetworkLogo;
  String _selectedGenre = 'All';
  List<WebSeriesModel> _filteredWebSeriesList = [];
  List<ApiNetworkModel> _apiNetworks = [];
  List<String> _uniqueNetworks = [];
  List<String> _uniqueGenres = [];

  // Animation and Loading State
  bool _isVideoLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _currentBackgroundUrl;
  List<SliderModel> _currentWebSeriesSliders = [];
  int _currentSliderIndex = 0;

  String _lastNavigationDirection = 'horizontal';

  // ===== FIX START: Hang/Crash issue ko theek karne ke liye variables =====
  bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;
  // ===== FIX END =====

  // Search State
  bool _isSearching = false;
  bool _showKeyboard = false;
  String _searchText = '';
  Timer? _debounce;
  List<WebSeriesModel> _searchResults = [];
  bool _isSearchLoading = false;
  late FocusNode _searchButtonFocusNode;

  bool _isGenreLoading = false;

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
    _searchButtonFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
    _fetchDataForPage();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _sliderPageController.dispose();
    _fadeController.dispose();
    _widgetFocusNode.dispose();
    _listScrollController.dispose();
    _networkScrollController.dispose();
    _genreScrollController.dispose();
    _searchButtonFocusNode.dispose();
    _debounce?.cancel();

    // ===== FIX START: Memory leak se bachne ke liye Timer ko cancel karein =====
    _navigationLockTimer?.cancel();
    // ===== FIX END =====

    _disposeFocusNodes(_itemFocusNodes);
    _disposeFocusNodes(_networkFocusNodes);
    _disposeFocusNodes(_genreFocusNodes);
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
            _isLoading
                ? const Center(
                    child: ProfessionalWebSeriesLoadingIndicator(
                        message: 'Loading All Series...'))
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : _buildPageContent(),
            if (_isVideoLoading && _errorMessage == null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
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

  //=================================================
  // SECTION 2.1: DATA FETCHING AND PROCESSING
  //=================================================

  Future<void> _fetchDataForPage({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        _fetchAndCacheWebSeries(forceRefresh: forceRefresh),
        _fetchNetworks(),
      ]);
      final fetchedList = results[0] as List<WebSeriesModel>;
      final fetchedNetworks = results[1] as List<ApiNetworkModel>;
      fetchedList.sort((a, b) => a.seriesOrder.compareTo(b.seriesOrder));
      fetchedNetworks
          .sort((a, b) => a.networksOrder.compareTo(b.networksOrder));
      
      // CHANGE 3: Data fetch hone ke baad list ko ek baar shuffle karein.
      fetchedList.shuffle();

      if (mounted) {
        if (fetchedList.isEmpty) _errorMessage = "No Web Series Found.";
        setState(() {
          _webSeriesList = fetchedList;
          _apiNetworks = fetchedNetworks;
        });
        if (_errorMessage == null) {
          _processInitialData();
          _initializeFocusNodes();
          _startAnimations();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _networkFocusNodes.isNotEmpty) {
              _networkFocusNodes[0].requestFocus();
            }
          });
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Failed to load Web Series.\nPlease check your connection.";
        });
      }
    }
  }

  // CHANGE 4: Caching logic ko function se hata diya gaya hai.
  // Yeh function ab hamesha API se data fetch karega.
  Future<List<WebSeriesModel>> _fetchAndCacheWebSeries(
      {bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      String authKey = prefs.getString('result_auth_key') ?? '';
      final response = await http.get(
        Uri.parse('https://dashboard.cpplayers.com/api/v2/getAllWebSeries'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain': 'coretechinfo.com'
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map(
                (item) => WebSeriesModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load web series: $e');
    }
  }

  Future<List<ApiNetworkModel>> _fetchNetworks() async {
    final prefs = await SharedPreferences.getInstance();
    final authKey = prefs.getString('result_auth_key') ?? '';
    try {
      final response = await http
          .post(
            Uri.parse('https://dashboard.cpplayers.com/api/v2/getNetworks'),
            headers: {
              'auth-key': authKey,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'domain': 'coretechinfo.com'
            },
            body: json.encode({"network_id": "", "data_for": "webseries"}),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) => ApiNetworkModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load networks: $e');
    }
  }

  void _processInitialData() {
    if (_webSeriesList.isEmpty && _apiNetworks.isEmpty) return;
    _uniqueNetworks = _apiNetworks.map((n) => n.name).toList();
    if (_uniqueNetworks.isNotEmpty) {
      _selectedNetworkName = _uniqueNetworks[0];
      _updateSelectedNetworkData();
      _updateGenresForSelectedNetwork();
    }
    _applyFilters();
  }



  //=================================================
// SECTION 2.3: STATE MANAGEMENT & UI LOGIC (ke Aas Paas Add Karein)
//=================================================

  // ===== FIX START: Pehle scroll karke fir focus karne ke liye naya function =====
  void _focusFirstListItemWithScroll() {
    if (_itemFocusNodes.isEmpty) return;

    // List ko shuruaat mein scroll karein
    if (_listScrollController.hasClients) {
      _listScrollController.animateTo(
        0.0,
        duration: AnimationTiming.fast, // 250ms
        curve: Curves.easeInOut,
      );
    }

    // Thodi der baad (scroll animation shuru hone ke baad) pehle item par focus karein.
    // Isse user ko scroll animation dikhega aur fir focus highlight aayega.
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted && _itemFocusNodes.isNotEmpty) {
        setState(() => _focusedItemIndex = 0);
        _itemFocusNodes[0].requestFocus();
      }
    });
  }
  // ===== FIX END =====



  //=================================================
  // SECTION 2.2: KEYBOARD AND FOCUS NAVIGATION
  //=================================================

  KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
    
    bool searchHasFocus = _searchButtonFocusNode.hasFocus;
    bool networkHasFocus = _networkFocusNodes.any((n) => n.hasFocus);
    bool genreHasFocus = _genreFocusNodes.any((n) => n.hasFocus);
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
      if (listHasFocus || genreHasFocus || searchHasFocus) {
        _networkFocusNodes[_focusedNetworkIndex].requestFocus();
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
        return KeyEventResult.handled; // Do nothing
      }
      if (key == LogicalKeyboardKey.arrowRight && _genreFocusNodes.isNotEmpty) {
        _genreFocusNodes[0].requestFocus();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowUp && _networkFocusNodes.isNotEmpty) {
        _networkFocusNodes[_focusedNetworkIndex].requestFocus();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
        setState(() => _focusedItemIndex = 0);
        // _itemFocusNodes[0].requestFocus();
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
      } else if (genreHasFocus) {
        _navigateGenres(key);
      } else if (listHasFocus) {
        _navigateList(key);
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ===== FIX START: Fast navigation hang/crash ke liye updated function =====
  void _navigateList(LogicalKeyboardKey key) {
    // Agar navigation pehle se locked hai, to function se bahar nikal jao
    if (_isNavigationLocked) return;

    if (_focusedItemIndex == -1 || _itemFocusNodes.isEmpty) return;

    // Navigation ko turant lock karo
    setState(() {
      _isNavigationLocked = true;
    });

    // Ek chota Timer set karo jo lock ko thodi der baad khol dega
    // Yeh 300ms ka cooldown period dega
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
      if (_genreFocusNodes.isNotEmpty) {
        _genreFocusNodes[_focusedGenreIndex].requestFocus();
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
      final currentList =
          _isSearching ? _searchResults : _filteredWebSeriesList;
      if (newIndex + 1 < currentList.length) {
        newIndex++;
        setState(() => _lastNavigationDirection = 'horizontal');
      }
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter) {
      
      // Enter/Select par cooldown nahi chahiye, isliye lock turant hata do
      _isNavigationLocked = false;
      _navigationLockTimer?.cancel();

      final currentList =
          _isSearching ? _searchResults : _filteredWebSeriesList;
      _navigateToWebSeriesDetails(currentList[_focusedItemIndex], _focusedItemIndex);
      return;
    }

    if (newIndex != _focusedItemIndex) {
      setState(() => _focusedItemIndex = newIndex);
      _itemFocusNodes[newIndex].requestFocus();
    } else {
      // Agar index nahi badla (e.g., pehle item par left dabaya), to lock hata do
      _isNavigationLocked = false;
      _navigationLockTimer?.cancel();
    }
  }
  // ===== FIX END =====

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
      _updateSelectedNetwork();
      _searchButtonFocusNode.requestFocus();
      return;
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter) {
      _updateSelectedNetwork();
      return;
    }
    if (newIndex != _focusedNetworkIndex) {
      setState(() => _focusedNetworkIndex = newIndex);
      _networkFocusNodes[newIndex].requestFocus();
      _updateAndScrollToFocus(
          _networkFocusNodes, newIndex, _networkScrollController, 160);
    }
  }

  void _navigateGenres(LogicalKeyboardKey key) {
    int newIndex = _focusedGenreIndex;
    if (key == LogicalKeyboardKey.arrowLeft) {
      if (newIndex > 0) {
        newIndex--;
        setState(() => _lastNavigationDirection = 'horizontal');
      } else {
        _searchButtonFocusNode.requestFocus();
        return;
      }
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (newIndex < _uniqueGenres.length - 1) {
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
      _updateSelectedGenre();
      if (_itemFocusNodes.isNotEmpty) {
        setState(() => _focusedItemIndex = 0);
        // _itemFocusNodes[0].requestFocus();
        _focusFirstListItemWithScroll();
      }
      return;
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter) {
      _updateSelectedGenre();
      return;
    }
    if (newIndex != _focusedGenreIndex) {
      setState(() => _focusedGenreIndex = newIndex);
      _genreFocusNodes[newIndex].requestFocus();
      _updateAndScrollToFocus(
          _genreFocusNodes, newIndex, _genreScrollController, 160);
    }
  }

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

  void _applyFilters() {
    if (_isSearching) {
      setState(() {
        _isSearching = false;
        _searchText = '';
        _searchResults.clear();
      });
    }
    _filteredWebSeriesList = _webSeriesList.where((series) {
      final bool networkMatch = _selectedNetworkName.isEmpty ||
          series.networks.any((n) => n.name == _selectedNetworkName);
      final bool genreMatch = _selectedGenre == 'All' ||
          (series.genres
                  ?.split(',')
                  .map((e) => e.trim())
                  .contains(_selectedGenre) ??
              false);
      return networkMatch && genreMatch;
    }).toList();
    
    // CHANGE 5: Yahan se shuffle ko hata diya gaya hai.
    // _filteredWebSeriesList.shuffle(); 
    
    _rebuildItemFocusNodes();
    _focusedItemIndex = -1;
  }

  void _updateSelectedNetwork() {
    setState(() {
      _selectedNetworkName = _uniqueNetworks[_focusedNetworkIndex];
      _updateSelectedNetworkData();
      _updateGenresForSelectedNetwork();
      _rebuildGenreFocusNodes();
      _focusedGenreIndex = 0;
      _selectedGenre = 'All';
      _applyFilters();
    });
  }

  void _updateSelectedGenre() {
    setState(() {
      _selectedGenre = _uniqueGenres[_focusedGenreIndex];
      _applyFilters();
    });
  }

  void _updateSelectedNetworkData() {
    final selectedNetwork = _apiNetworks.firstWhere(
        (n) => n.name == _selectedNetworkName,
        orElse: () => ApiNetworkModel(id: -1, name: '', networksOrder: 9999));
    final webSeriesSliders = selectedNetwork.sliders
        .where((s) => s.sliderFor == 'webseries')
        .toList();
    setState(() {
      _selectedNetworkLogo = selectedNetwork.logo;
      _currentWebSeriesSliders = webSeriesSliders;
      _currentSliderIndex = 0;
      if (webSeriesSliders.isNotEmpty) {
        _currentBackgroundUrl = webSeriesSliders.first.banner;
      } else {
        _currentBackgroundUrl = selectedNetwork.logo;
      }
    });

    if (_sliderPageController.hasClients && _currentWebSeriesSliders.isNotEmpty) {
      _sliderPageController.jumpToPage(0);
    }
  }

  void _updateGenresForSelectedNetwork() {
    if (_selectedNetworkName.isEmpty || _webSeriesList.isEmpty) return;
    final networkSpecificSeries = _webSeriesList
        .where((series) => series.networks.any((n) => n.name == _selectedNetworkName))
        .toList();
    final Set<String> genres = {'All'};
    for (final series in networkSpecificSeries) {
      if (series.genres != null && series.genres!.isNotEmpty) {
        final genreList = series.genres!
            .split(',')
            .map((g) => g.trim())
            .where((g) => g.isNotEmpty);
        genres.addAll(genreList.where((g) =>
            g.toLowerCase() != 'web series' && g.toLowerCase() != 'webseries'));
      }
    }
    final sortedGenres = genres.toList()..sort();
    if (sortedGenres.contains('All')) {
      sortedGenres.remove('All');
      sortedGenres.insert(0, 'All');
    }
    _uniqueGenres = sortedGenres;
  }

  void _performSearch(String searchTerm) {
    _debounce?.cancel();
    if (searchTerm.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _isSearchLoading = false;
        _searchResults.clear();
        _rebuildItemFocusNodes();
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() {
        _isSearchLoading = true;
        _isSearching = true;
        _searchResults.clear();
      });
      final results = await _performSearchInNetwork(searchTerm);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearchLoading = false;
        _rebuildItemFocusNodes();
      });
    });
  }

  Future<List<WebSeriesModel>> _performSearchInNetwork(String searchTerm) async {
    if (searchTerm.isEmpty || _selectedNetworkName.isEmpty) {
      return [];
    }
    final networkSeries = _webSeriesList
        .where((series) => series.networks.any((n) => n.name == _selectedNetworkName))
        .toList();
    return networkSeries
        .where(
            (series) => series.name.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
  }

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
        _searchText += ' ';
      } else {
        _searchText += value;
      }
      _performSearch(_searchText);
    });
  }

  Future<void> _navigateToWebSeriesDetails(
      WebSeriesModel webSeries, int index) async {
    if (_isVideoLoading) return;
    setState(() => _isVideoLoading = true);
    try {
      int? currentUserId = SessionManager.userId;
      await HistoryService.updateUserHistory(
        userId: currentUserId!,
        contentType: 2,
        eventId: webSeries.id,
        eventTitle: webSeries.name,
        url: '',
        categoryId: 0,
      );
    } catch (e) {
      // History update failure should not block navigation
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
      setState(() {
        _isVideoLoading = false;
        _focusedItemIndex = index;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _focusedItemIndex >= 0 &&
            _focusedItemIndex < _itemFocusNodes.length) {
          _itemFocusNodes[_focusedItemIndex].requestFocus();
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
    _fadeController.forward();
  }

  void _initializeFocusNodes() {
    _disposeFocusNodes(_networkFocusNodes);
    _networkFocusNodes = List.generate(
        _uniqueNetworks.length, (index) => FocusNode(debugLabel: 'Network-$index'));
    _rebuildGenreFocusNodes();
    _rebuildItemFocusNodes();
    _rebuildKeyboardFocusNodes();
  }

  void _rebuildGenreFocusNodes() {
    _disposeFocusNodes(_genreFocusNodes);
    _genreFocusNodes = List.generate(
        _uniqueGenres.length, (index) => FocusNode(debugLabel: 'Genre-$index'));
  }

  void _rebuildItemFocusNodes() {
    _disposeFocusNodes(_itemFocusNodes);
    final currentList = _isSearching ? _searchResults : _filteredWebSeriesList;
    _itemFocusNodes = List.generate(
        currentList.length, (index) => FocusNode(debugLabel: 'Item-$index'));
  }

  void _rebuildKeyboardFocusNodes() {
    _disposeFocusNodes(_keyboardFocusNodes);
    int totalKeys =
        _keyboardLayout.fold(0, (prev, row) => prev + row.length);
    _keyboardFocusNodes =
        List.generate(totalKeys, (index) => FocusNode(debugLabel: 'Key-$index'));
  }

  int _getFocusNodeIndexForKey(int row, int col) {
    int index = 0;
    for (int r = 0; r < row; r++) {
      index += _keyboardLayout[r].length;
    }
    return index + col;
  }

  void _disposeFocusNodes(List<FocusNode> nodes) {
    for (var node in nodes) {
      node.dispose();
    }
  }

  void _updateAndScrollToFocus(List<FocusNode> nodes, int index,
      ScrollController controller, double itemWidth) {
    if (!mounted ||
        index < 0 ||
        index >= nodes.length ||
        !controller.hasClients) return;
    double screenWidth = MediaQuery.of(context).size.width;
    double scrollPosition = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    controller.animateTo(
      scrollPosition.clamp(0.0, controller.position.maxScrollExtent),
      duration: AnimationTiming.fast,
      curve: Curves.easeInOut,
    );
  }

  //=================================================
  // SECTION 2.5: WIDGET BUILDER METHODS
  //=================================================

  Widget _buildPageContent() {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.02, vertical: screenhgt * 0.02),

      child: Column(
        children: [
          _buildTopFilterBar(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildContentBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBody() {
    return Column(
      children: [
        SizedBox(
          height: screenhgt * 0.5,
          child: _showKeyboard ? _buildSearchUI() : const SizedBox.shrink(),
        ),
        _buildSliderIndicators(),
        _buildGenreAndSearchButtons(),
        SizedBox(height: screenhgt * 0.02),
        _buildWebSeriesList(),
      ],
    );
  }
  
  Widget _buildBackgroundOrSlider() {
    if (_currentWebSeriesSliders.isNotEmpty) {
      return WebSeriesBannerSlider(
        sliders: _currentWebSeriesSliders,
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

  Widget _buildDynamicBackground() {
    return AnimatedSwitcher(
      duration: AnimationTiming.medium,
      child: _currentBackgroundUrl != null && _currentBackgroundUrl!.isNotEmpty
          ? Container(
              key: ValueKey<String>(_currentBackgroundUrl!),
              decoration: BoxDecoration(
                image: DecorationImage(
                  // CHANGE 6: CachedNetworkImageProvider ko NetworkImage se badla gaya.
                  image: NetworkImage(_currentBackgroundUrl!),
                  fit: BoxFit.cover,
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

  Widget _buildTopFilterBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top +5,
            bottom: 5,
            left: screenwdt * 0.015,
            right: 0,
          ),
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   colors: [
            //     Colors.black.withOpacity(0.3),
            //     Colors.black.withOpacity(0.1),
            //   ],
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            // ),
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

  Widget _buildNetworkFilter() {
    return SizedBox(
      height: 30,
      child: Center(
        child: ListView.builder(
          controller: _networkScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: _uniqueNetworks.length,
          itemBuilder: (context, index) {
            final networkName = _uniqueNetworks[index];
            final focusNode = _networkFocusNodes[index];
            final isSelected = _selectedNetworkName == networkName;
            
            return Focus(
              focusNode: focusNode,
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  setState(() => _focusedNetworkIndex = index);
                }
              },
              child: _buildGlassEffectButton(
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

  Widget _buildGenreAndSearchButtons() {
    if (_uniqueGenres.length <= 1 && !_isSearching) {
      return const SizedBox.shrink();
    }
    if (_isGenreLoading) {
      return SizedBox(
        height: 30,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    return SizedBox(
      height: 30,
      child: Center(
        child: ListView.builder(
          controller: _genreScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: _uniqueGenres.length + 1, // +1 for Search button
          padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.015),
          itemBuilder: (context, index) {
            if (index == 0) { // Search Button
              return Focus(
                focusNode: _searchButtonFocusNode,
                child: _buildGlassEffectButton(
                  focusNode: _searchButtonFocusNode,
                  isSelected: _isSearching,
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
                  child:  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        ("Search").toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Genre Buttons
            final genreIndex = index - 1;
            final genre = _uniqueGenres[genreIndex];
            final focusNode = _genreFocusNodes[genreIndex];
            final isSelected = !_isSearching && _selectedGenre == genre;

            return Focus(
              focusNode: focusNode,
              child: _buildGlassEffectButton(
                focusNode: focusNode,
                isSelected: isSelected,
                focusColor: _focusColors[genreIndex % _focusColors.length],
                onTap: () {
                  setState(() => _focusedGenreIndex = genreIndex);
                  focusNode.requestFocus();
                  _updateSelectedGenre();
                },
                child: Text(
                  genre.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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

  Widget _buildWebSeriesList() {
    final currentList = _isSearching ? _searchResults : _filteredWebSeriesList;

    if (_isSearchLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (currentList.isEmpty) {
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
                // const SizedBox(height: 10),
                Text(
                  _isSearching && _searchText.isNotEmpty
                      ? "No results found for '$_searchText'"
                      : 'No series available for this filter.',
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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: ListView.builder(
          controller: _listScrollController,
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.015),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            return Container(
              width: bannerwdt * 1.2,
              margin: const EdgeInsets.only(right: 12.0),
              child: InkWell(
                focusNode: _itemFocusNodes[index],
                onTap: () => _navigateToWebSeriesDetails(currentList[index], index),
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    setState(() => _focusedItemIndex = index);
                    _updateAndScrollToFocus(
                        _itemFocusNodes, index, _listScrollController, (bannerwdt * 1.2) + 12);
                  }
                },
                child: OptimizedWebSeriesCard(
                  webSeries: currentList[index],
                  isFocused: _focusedItemIndex == index,
                  onTap: () =>
                      _navigateToWebSeriesDetails(currentList[index], index),
                  cardHeight: bannerhgt * 1.2,
                  networkLogo: _selectedNetworkLogo,
                  uniqueIndex: index,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

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
                  ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: const Text(
                    "Search Web Series",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                    border: Border.all(color: ProfessionalColors.accentPurple, width: 2),
                  ),
                  child: Text(
                    _searchText.isEmpty ? 'Start typing...' : _searchText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _searchText.isEmpty ? Colors.white54 : Colors.white,
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

  Widget _buildKeyboardRow(List<String> keys, int rowIndex) {
    int startIndex = 0;
    for (int i = 0; i < rowIndex; i++) {
      startIndex += _keyboardLayout[i].length;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.asMap().entries.map((entry) {
        final colIndex = entry.key;
        final key = entry.value;
        final focusIndex = startIndex + colIndex;
        final isFocused = _focusedKeyRow == rowIndex && _focusedKeyCol == colIndex;
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
            focusNode: _keyboardFocusNodes[focusIndex],
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

  Widget _buildSliderIndicators() {
    if (_currentWebSeriesSliders.length <= 1) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_currentWebSeriesSliders.length, (index) {
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
                  color: hasFocus ? Colors.white : Colors.white.withOpacity(0.3),
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
// Yeh chhote, reusable widgets hain jo page par istemal hote hain.
//==============================================================================

class OptimizedWebSeriesCard extends StatelessWidget {
  final WebSeriesModel webSeries;
  final bool isFocused;
  final VoidCallback onTap;
  final double cardHeight;
  final String? networkLogo;
  final int uniqueIndex;

  const OptimizedWebSeriesCard({
    Key? key,
    required this.webSeries,
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
                  _buildWebSeriesImage(),
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
          child: Text(webSeries.name,
              style: TextStyle(
                  color: isFocused
                      ? focusColor
                      : ProfessionalColors.textSecondary,
                  fontSize: 14,
                  fontWeight: isFocused ? FontWeight.bold : FontWeight.normal),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  // CHANGE 7: CachedNetworkImage ko Image.network se badal diya gaya hai.
  Widget _buildWebSeriesImage() {
    final imageUrl = webSeries.banner;
    
    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            // `loadingBuilder` ka istemal placeholder dikhane ke liye kiya gaya hai.
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildImagePlaceholder();
            },
            // `errorBuilder` ka istemal error hone par placeholder dikhane ke liye kiya gaya hai.
            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
              return _buildImagePlaceholder();
            },
          )
        : _buildImagePlaceholder();
  }
  
  Widget _buildImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ProfessionalColors.accentGreen,
            ProfessionalColors.accentBlue,
          ],
        ),
      ),
      child: const Icon(
        Icons.broken_image,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class WebSeriesBannerSlider extends StatefulWidget {
  final List<SliderModel> sliders;
  final ValueChanged<int> onPageChanged;
  final PageController controller;

  const WebSeriesBannerSlider({
    Key? key,
    required this.sliders,
    required this.onPageChanged,
    required this.controller,
  }) : super(key: key);

  @override
  _WebSeriesBannerSliderState createState() => _WebSeriesBannerSliderState();
}

class _WebSeriesBannerSliderState extends State<WebSeriesBannerSlider> {
  Timer? _timer;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.sliders.length > 1) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(WebSeriesBannerSlider oldWidget) {
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
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !widget.controller.hasClients || widget.sliders.length <= 1) return;

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
              // CHANGE 8: Yahan bhi CachedNetworkImage ko Image.network se badal diya gaya hai.
              Image.network(
                slider.banner,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => 
                    progress == null ? child : Container(color: ProfessionalColors.surfaceDark),
                errorBuilder: (context, error, stackTrace) => 
                    Container(color: ProfessionalColors.surfaceDark),
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
                    stops: const [0.0, 0.5, 0.7, 0.9],
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






