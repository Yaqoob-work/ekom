import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/home_screen_pages/kids_shows/kid_channels_details_page.dart';

// NOTE: Check your project structure imports
// import 'package:mobi_tv_entertainment/components/home_screen_pages/kid_channels/kid_channels_details_page.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';

//==============================================================================
// SECTION 1: COMMON CLASSES AND MODELS (REFACTORED)
//==============================================================================

class KidChannelsColors {
  static const primaryDark = Color(0xFF0A0E1A);
  static const surfaceDark = Color(0xFF1A1D29);
  static const cardDark = Color(0xFF2A2D3A);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGreen = Color(0xFF10B981);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentPink = Color(0xFFEC4899);
  static const accentOrange = Color(0xFFF59E0B);
  static const accentRed = Color(0xFFEF4444);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);

  static List<Color> gradientColors = [accentOrange, accentGreen, accentBlue];
}

class AnimationTiming {
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
}

// ---------------------------------------------------------------------------
// REFACTORED MODEL: KidChannelsModel
// This is the primary model used for the UI Display list.
// It normalizes 'logo' (from channels) and 'thumbnail' (from shows) into 'image'.
// ---------------------------------------------------------------------------
class KidChannelsModel {
  final int id;
  final String title;
  final String image; // unified field for Logo or Thumbnail
  final String updatedAt;
  final String? genre;
  final int order;
  final String? language;

  KidChannelsModel({
    required this.id,
    required this.title,
    required this.image,
    required this.updatedAt,
    this.genre,
    required this.order,
    this.language,
  });

  factory KidChannelsModel.fromJson(Map<String, dynamic> json) {
    // LOGIC: Check for 'logo' first (Channels), then 'thumbnail' or 'poster'
    String extractedImage = '';
    if (json['logo'] != null) {
      extractedImage = json['logo'];
    } else if (json['thumbnail'] != null) {
      extractedImage = json['thumbnail'];
    } else if (json['poster'] != null) {
      extractedImage = json['poster'];
    }

    return KidChannelsModel(
      id: json['id'] ?? 0,
      title: json['name'] ?? json['title'] ?? '',
      image: extractedImage,
      updatedAt: json['updated_at'] ?? '',
      genre: null, 
      order: json['order'] ?? 9999,
      language: json['language'],
    );
  }
}

// ---------------------------------------------------------------------------
// REFACTORED MODEL: KidChannelsShowItemModel
// Used specifically when parsing the 'getKidsShows' API response.
// ---------------------------------------------------------------------------
class KidChannelsShowItemModel {
  final int id;
  final String title;
  final String thumbnail; // Explicit naming: API sends thumbnail
  final String? genre;
  final int kidChannelsId;
  final int order;

  KidChannelsShowItemModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.genre,
    required this.kidChannelsId,
    required this.order,
  });

  factory KidChannelsShowItemModel.fromJson(Map<String, dynamic> json) {
    return KidChannelsShowItemModel(
      id: json['id'] ?? 0,
      title: json['name'] ?? json['title'] ?? '',
      // Explicit mapping: API 'thumbnail' -> Model 'thumbnail'
      thumbnail: json['thumbnail'] ?? json['logo'] ?? '', 
      genre: json['genre'],
      kidChannelsId: json['kid_channel_id'] ?? json['category_id'] ?? 0,
      order: json['order'] ?? 9999,
    );
  }
}

class SliderModel {
  final int id;
  final String title;
  final String thumbnail;
  final String sliderFor;

  SliderModel(
      {required this.id,
      required this.title,
      required this.thumbnail,
      required this.sliderFor});

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
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

class ProfessionalKidChannelsLoadingIndicator extends StatelessWidget {
  final String message;
  const ProfessionalKidChannelsLoadingIndicator({Key? key, required this.message})
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
                colors: KidChannelsColors.gradientColors,
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
              color: KidChannelsColors.textPrimary,
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
// SECTION 2: MAIN PAGE WIDGET AND STATE (KID CHANNELS)
//==============================================================================

class KidChannelsSliderScreen extends StatefulWidget {
  final String title;
  final int? initialNetworkId;

  const KidChannelsSliderScreen({
    Key? key,
    this.title = 'Kid Channels',
    this.initialNetworkId,
  }) : super(key: key);

  @override
  _KidChannelsSliderScreenState createState() =>
      _KidChannelsSliderScreenState();
}

class _KidChannelsSliderScreenState extends State<KidChannelsSliderScreen>
    with SingleTickerProviderStateMixin {
  List<KidChannelsModel> _kidChannelsList = [];
  bool _isLoading = true;
  bool _isListLoading = false;
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
  String _selectedNetworktitle = '';
  String? _selectedNetworkLogo;

  Map<String, int?> _channelFilters = {};
  String _selectedChannelFiltertitle = '';
  int? _selectedChannelFilterId;
  bool _isDisplayingShows = false;

  List<KidChannelsModel> _currentViewMasterList = [];
  List<KidChannelsModel> _displayList = [];
  List<ApiNetworkModel> _apiNetworks = [];
  List<String> _uniqueNetworks = [];

  // Animation and Loading State
  bool _isVideoLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _currentBackgroundUrl;
  List<SliderModel> _currentKidChannelsSliders = [];
  int _currentSliderIndex = 0;

  String _lastNavigationDirection = 'horizontal';

  bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;

  // Search State
  bool _isSearching = false;
  bool _showKeyboard = false;
  String _searchText = '';
  Timer? _debounce;
  late FocusNode _searchButtonFocusNode;

  final List<Color> _focusColors = [
    KidChannelsColors.accentOrange,
    KidChannelsColors.accentGreen,
    KidChannelsColors.accentBlue,
    KidChannelsColors.accentPurple,
    KidChannelsColors.accentPink
  ];

  @override
  void initState() {
    super.initState();
    _sliderPageController = PageController();
    _searchButtonFocusNode = FocusNode();
    _searchButtonFocusNode.addListener(_setStateListener);
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
      backgroundColor: KidChannelsColors.primaryDark,
      body: Focus(
        focusNode: _widgetFocusNode,
        autofocus: true,
        onKey: _onKeyHandler,
        child: Stack(
          children: [
            _buildBackgroundOrSlider(),
            _isLoading
                ? const Center(
                    child: ProfessionalKidChannelsLoadingIndicator(
                        message: 'Loading Kid Channels...'))
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : _buildPageContent(),
            if (_isVideoLoading && _errorMessage == null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: const Center(
                    child: ProfessionalKidChannelsLoadingIndicator(
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
  // SECTION 2.1: DATA FETCHING
  //=================================================

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

      int initialIndex = 0;
      int networkIdToFetch;

      if (widget.initialNetworkId != null) {
        int foundIndex =
            fetchedNetworks.indexWhere((n) => n.id == widget.initialNetworkId);
        if (foundIndex != -1) {
          initialIndex = foundIndex;
        }
      }

      final initialNetwork = fetchedNetworks[initialIndex];
      networkIdToFetch = initialNetwork.id;

      setState(() {
        _apiNetworks = fetchedNetworks;
        _uniqueNetworks = _apiNetworks.map((n) => n.name).toList();
        _focusedNetworkIndex = initialIndex;
        _selectedNetworktitle = initialNetwork.name;
      });

      // 2. Fetch KidChannels
      final fetchedList =
          await _fetchKidChannelsForNetwork(networkIdToFetch);

      if (!mounted) return;

      setState(() {
        _kidChannelsList = fetchedList;
        if (_kidChannelsList.isEmpty) _errorMessage = "No Kid Channels Found.";
      });

      if (_errorMessage == null) {
        _processInitialData();
        _updateChannelFilters();
        await _fetchDataForView();
        _initializeFocusNodes();
        _startAnimations();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              _networkFocusNodes.isNotEmpty &&
              _focusedNetworkIndex < _networkFocusNodes.length) {
            _networkFocusNodes[_focusedNetworkIndex].requestFocus();
            _updateAndScrollToFocus(_networkFocusNodes, _focusedNetworkIndex,
                _networkScrollController, 160);
          }
        });
      }
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Failed to load data.\nPlease check your connection.";
          debugPrint("Error fetching initial data: $e");
        });
      }
    }
  }

  Future<List<KidChannelsModel>> _fetchKidChannelsForNetwork(
      int networkId) async {
    try {
      String authKey = SessionManager.authKey;
      var url = Uri.parse(SessionManager.baseUrl +
          'getKidsChannels?content_network=$networkId');
      final response = await https.get(
        url,
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain': SessionManager.savedDomain
        },
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return [];

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) =>
                KidChannelsModel.fromJson(item as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load kid channels for network $networkId: $e');
      throw Exception('Failed to load kid channels for network $networkId: $e');
    }
  }

  Future<List<KidChannelsShowItemModel>> _fetchKidChannelsShowsForChannel(
      int channelId) async {
    String authKey = SessionManager.authKey;
    var url = Uri.parse(SessionManager.baseUrl + 'getKidsShows/$channelId');
    try {
      final response = await https.get(
        url,
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
                KidChannelsShowItemModel.fromJson(item as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load kid channels shows for channel $channelId: $e');
      throw Exception('Failed to load kid channels shows for channel $channelId: $e');
    }
  }

  Future<List<ApiNetworkModel>> _fetchNetworks() async {
    String authKey = SessionManager.authKey;
    var url = Uri.parse(SessionManager.baseUrl + 'getNetworks');
    try {
      final response = await https
          .post(
            url,
            headers: {
              'auth-key': authKey,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'domain': SessionManager.savedDomain,
            },
            body: json.encode({"network_id": "", "data_for": "kidchannels"}),
          )
          .timeout(const Duration(seconds: 30));

      if (!mounted) return [];

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) => ApiNetworkModel.fromJson(item as Map<String, dynamic>))
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
    _updateSelectedNetworkData();
  }

  //=================================================
  // SECTION 2.2: KEYBOARD AND FOCUS NAVIGATION
  //=================================================

  void _focusFirstListItemWithScroll() {
    if (_itemFocusNodes.isEmpty) return;

    if (_listScrollController.hasClients) {
      _listScrollController.animateTo(
        0.0,
        duration: AnimationTiming.fast,
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
        return KeyEventResult.handled;
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
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _navigateList(LogicalKeyboardKey key) {
    if (_isNavigationLocked) return;
    if (_focusedItemIndex == -1 || _itemFocusNodes.isEmpty) return;

    setState(() {
      _isNavigationLocked = true;
    });

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
      _isNavigationLocked = false;
      _navigationLockTimer?.cancel();
      return;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _isNavigationLocked = false;
      _navigationLockTimer?.cancel();
      return;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (newIndex > 0) {
        newIndex--;
        setState(() => _lastNavigationDirection = 'horizontal');
      }
    } else if (key == LogicalKeyboardKey.arrowRight) {
      final currentList = _displayList;
      if (newIndex + 1 < currentList.length) {
        newIndex++;
        setState(() => _lastNavigationDirection = 'horizontal');
      }
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter) {
      _isNavigationLocked = false;
      _navigationLockTimer?.cancel();

      final currentList = _displayList;
      _navigateToKidChannelsDetails(currentList[_focusedItemIndex], _focusedItemIndex);
      return;
    }

    if (newIndex != _focusedItemIndex &&
        newIndex >= 0 &&
        newIndex < _itemFocusNodes.length) {
      setState(() => _focusedItemIndex = newIndex);
      _itemFocusNodes[newIndex].requestFocus();
    } else {
      _isNavigationLocked = false;
      _navigationLockTimer?.cancel();
    }
  }

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

  void _navigateChannelFilters(LogicalKeyboardKey key) {
    final filtertitles = _channelFilters.keys.toList();

    if (filtertitles.isEmpty) {
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
      return;
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
      if (newIndex < filtertitles.length - 1) {
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
      if (_itemFocusNodes.isNotEmpty) {
        _focusFirstListItemWithScroll();
      }
      return;
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter) {
      _updateSelectedChannelFilter();
      return;
    }
    if (newIndex != _focusedChannelFilterIndex) {
      setState(() => _focusedChannelFilterIndex = newIndex);
      _channelFilterFocusNodes[newIndex].requestFocus();
      _updateAndScrollToFocus(
          _channelFilterFocusNodes, newIndex, _channelFilterScrollController, 160);
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

    List<KidChannelsModel> newMasterList = [];

    try {
      if (_selectedChannelFilterId != null) {
        // Fetch Shows (e.g., Tom & Jerry episodes)
        final List<KidChannelsShowItemModel> showItems =
            await _fetchKidChannelsShowsForChannel(_selectedChannelFilterId!);

        // CONVERSION LOGIC: Map ShowItem -> KidChannelsModel (Generic Display)
        newMasterList = showItems
            .map((show) => KidChannelsModel(
                  id: show.id,
                  title: show.title,
                  // IMPORTANT: Map show.thumbnail to the generic 'image' field
                  image: show.thumbnail, 
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
    });

    _startAnimations();
  }

  void _applySearchFilter() {
    if (!mounted) return;

    List<KidChannelsModel> filteredList = [];
    if (_isSearching && _searchText.isNotEmpty) {
      final searchTerm = _searchText.toLowerCase();
      filteredList = _currentViewMasterList.where((item) {
        return item.title.toLowerCase().contains(searchTerm);
      }).toList();
    } else {
      filteredList = List.from(_currentViewMasterList);
    }

    setState(() {
      _displayList = filteredList;
      _rebuildItemFocusNodes();
      _focusedItemIndex = -1;
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
      final newChannelList =
          await _fetchKidChannelsForNetwork(selectedNetwork.id);
      if (!mounted) return;

      setState(() {
        _kidChannelsList = newChannelList;
        _selectedNetworktitle = selectedNetwork.name;
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
          _kidChannelsList = [];
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
    final filtertitles = _channelFilters.keys.toList();
    if (filtertitles.isEmpty ||
        _focusedChannelFilterIndex >= filtertitles.length ||
        _channelFilterFocusNodes.isEmpty) return;

    _debounce?.cancel();

    final newFiltertitle = filtertitles[_focusedChannelFilterIndex];
    if (newFiltertitle == _selectedChannelFiltertitle) return;

    setState(() {
      _selectedChannelFiltertitle = newFiltertitle;
      _selectedChannelFilterId = _channelFilters[_selectedChannelFiltertitle];
      _isDisplayingShows = (_selectedChannelFilterId != null);

      _fetchDataForView();
    });
  }

  void _updateSelectedNetworkData() {
    if (_apiNetworks.isEmpty || _focusedNetworkIndex >= _apiNetworks.length)
      return;

    final selectedNetwork = _apiNetworks.firstWhere(
        (n) => n.name == _selectedNetworktitle,
        orElse: () => ApiNetworkModel(id: -1, name: '', networksOrder: 9999));

    final kidChannelsSliders = selectedNetwork.sliders
        .where((s) => s.sliderFor == 'kidchannels')
        .toList();

    setState(() {
      _selectedNetworkLogo = selectedNetwork.logo;
      _currentKidChannelsSliders = kidChannelsSliders;
      _currentSliderIndex = 0;
      if (kidChannelsSliders.isNotEmpty) {
        _currentBackgroundUrl = kidChannelsSliders.first.thumbnail;
      } else {
        _currentBackgroundUrl = selectedNetwork.logo;
      }
    });

    if (_sliderPageController.hasClients &&
        _currentKidChannelsSliders.isNotEmpty) {
      _sliderPageController.jumpToPage(0);
    }
  }

  void _updateChannelFilters() {
    setState(() {
      if (_kidChannelsList.isEmpty) {
        _channelFilters = {};
      } else {
        final Map<String, int?> newFilters = {};
        for (final channel in _kidChannelsList) {
          if (channel.title.isNotEmpty && !newFilters.containsKey(channel.title)) {
            newFilters[channel.title] = channel.id;
          }
        }
        _channelFilters = newFilters;
      }

      if (_channelFilters.isNotEmpty) {
        _selectedChannelFiltertitle = _channelFilters.keys.first;
        _selectedChannelFilterId = _channelFilters.values.first;
        _isDisplayingShows = true;
        _focusedChannelFilterIndex = 0;
      } else {
        _selectedChannelFiltertitle = '';
        _selectedChannelFilterId = null;
        _isDisplayingShows = false;
        _focusedChannelFilterIndex = -1;
      }
    });
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
        if (_searchText.isNotEmpty && !_searchText.endsWith(' ')) {
          _searchText += ' ';
        }
      } else {
        _searchText += value;
      }
      _isSearching = _searchText.isNotEmpty;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), () {
        _applySearchFilter();
      });
    });
  }

  Future<void> _navigateToKidChannelsDetails(
      KidChannelsModel item, int index) async {
    if (_isVideoLoading) return;
    setState(() => _isVideoLoading = true);

    try {
      int? currentUserId = SessionManager.userId;
      HistoryService.updateUserHistory(
        userId: currentUserId!,
        contentType: 6,
        eventId: item.id,
        eventTitle: item.title,
        url: '',
        categoryId: 0,
      ).catchError((e) {
        debugPrint("History update failed: $e");
      });
    } catch (e) {
      debugPrint("Error getting userId for History: $e");
    }

    // ✅ NAVIGATE TO KID CHANNELS DETAILS
    await Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => KidChannelsDetailsPage(
           id: item.id,
           // IMPORTANT: Use the unified 'image' field here
          //  thumbnail: item.image, 
           poster: item.image,
          //  title: item.title, 
          //  updatedAt: item.updatedAt, 
           banner: item.image, name: item.title,
         ),
       ),
    );

    if (mounted) {
      setState(() {
        _isVideoLoading = false;
        if (index >= 0 && index < _itemFocusNodes.length) {
          _focusedItemIndex = index;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                _itemFocusNodes.isNotEmpty &&
                _focusedItemIndex < _itemFocusNodes.length) {
              _itemFocusNodes[_focusedItemIndex].requestFocus();
              _updateAndScrollToFocus(
                  _itemFocusNodes, _focusedItemIndex, _listScrollController, (bannerwdt * 1.1) + 15);
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
    _fadeController.reset();
    _fadeController.forward();
  }

  void _initializeFocusNodes() {
    _disposeFocusNodes(_networkFocusNodes);
    _networkFocusNodes = List.generate(
        _apiNetworks.length,
        (index) => FocusNode(debugLabel: 'Network-$index')
          ..addListener(_setStateListener));
    _rebuildChannelFilterFocusNodes();
    _rebuildItemFocusNodes();
    _rebuildKeyboardFocusNodes();
  }

  void _rebuildChannelFilterFocusNodes() {
    _disposeFocusNodes(_channelFilterFocusNodes);
    _channelFilterFocusNodes = List.generate(
        _channelFilters.length,
        (index) => FocusNode(debugLabel: 'ChannelFilter-$index')
          ..addListener(_setStateListener));
  }

  void _rebuildItemFocusNodes() {
    _disposeFocusNodes(_itemFocusNodes);
    final currentList = _displayList;
    _itemFocusNodes = List.generate(
        currentList.length,
        (index) => FocusNode(debugLabel: 'Item-$index')
          ..addListener(_setStateListener));
  }

  void _rebuildKeyboardFocusNodes() {
    _disposeFocusNodes(_keyboardFocusNodes);
    int totalKeys =
        _keyboardLayout.fold(0, (prev, row) => prev + row.length);
    _keyboardFocusNodes = List.generate(
        totalKeys,
        (index) => FocusNode(debugLabel: 'Key-$index')
          ..addListener(_setStateListener));
  }

  int _getFocusNodeIndexForKey(int row, int col) {
    int index = 0;
    for (int r = 0; r < row; r++) {
      index += _keyboardLayout[r].length;
    }
    return index + col;
  }

  void _setStateListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _disposeFocusNodes(List<FocusNode> nodes) {
    for (var node in nodes) {
      node.removeListener(_setStateListener);
      node.dispose();
    }
    nodes.clear();
  }

  void _updateAndScrollToFocus(List<FocusNode> nodes, int index,
      ScrollController controller, double itemWidth) {
    if (!mounted ||
        index < 0 ||
        index >= nodes.length ||
        !controller.hasClients) return;
    double screenWidth = MediaQuery.of(context).size.width;
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

  Widget _buildPageContent() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenwdt * 0.02, vertical: screenhgt * 0.02),
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
        _buildChannelFilterAndSearchButtons(),
        SizedBox(height: screenhgt * 0.02),
        _buildKidChannelsList(), 
      ],
    );
  }

  Widget _buildBackgroundOrSlider() {
    if (_currentKidChannelsSliders.isNotEmpty) {
      return KidChannelsThumbnailSlider(
        sliders: _currentKidChannelsSliders,
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
      child: _currentBackgroundUrl != null &&
              _currentBackgroundUrl!.isNotEmpty
          ? Container(
              key: ValueKey<String>(_currentBackgroundUrl!),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(_currentBackgroundUrl!),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    debugPrint(
                        'Error loading background image: $_currentBackgroundUrl');
                  },
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      KidChannelsColors.primaryDark.withOpacity(0.2),
                      KidChannelsColors.primaryDark.withOpacity(0.4),
                      KidChannelsColors.primaryDark.withOpacity(0.6),
                      KidChannelsColors.primaryDark.withOpacity(0.9),
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
                    KidChannelsColors.primaryDark,
                    KidChannelsColors.surfaceDark,
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
              return const SizedBox.shrink();
            final networktitle = _uniqueNetworks[index];
            final focusNode = _networkFocusNodes[index];
            final isSelected = _selectedNetworktitle == networktitle;

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
                  networktitle.toUpperCase(),
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

  Widget _buildChannelFilterAndSearchButtons() {
    final filtertitles = _channelFilters.keys.toList();

    if (filtertitles.isEmpty && !_isSearching) {
      return const SizedBox(height: 30);
    }

    return SizedBox(
      height: 30,
      child: Center(
        child: ListView.builder(
          controller: _channelFilterScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: filtertitles.length + 1, // +1 for Search button
          padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.015),
          itemBuilder: (context, index) {
            if (index == 0) {
              // Search Button
              return Focus(
                focusNode: _searchButtonFocusNode,
                child: _buildGlassEffectButton(
                  focusNode: _searchButtonFocusNode,
                  isSelected: _isSearching || _showKeyboard,
                  focusColor: KidChannelsColors.accentOrange,
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
                          fontWeight: FontWeight.bold,
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
            if (filterIndex >= filtertitles.length ||
                filterIndex >= _channelFilterFocusNodes.length) {
              return const SizedBox.shrink(); // Guard
            }
            final filtertitle = filtertitles[filterIndex];
            final focusNode = _channelFilterFocusNodes[filterIndex];
            final isSelected =
                !_isSearching && _selectedChannelFiltertitle == filtertitle;

            return Focus(
              focusNode: focusNode,
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  setState(() => _focusedChannelFilterIndex = filterIndex);
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
                  filtertitle.toUpperCase(),
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

  Widget _buildKidChannelsList() {
    final currentList = _displayList;

    if (currentList.isEmpty && !_isListLoading) {
      return Expanded(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: KidChannelsColors.surfaceDark.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.child_care_rounded, // ✅ KidChannels Icon
                  size: 25,
                  color: KidChannelsColors.textSecondary,
                ),
                Text(
                  _isSearching && _searchText.isNotEmpty
                      ? "No results found for '$_searchText'"
                      : 'No kid channels available.',
                  style: const TextStyle(
                    color: KidChannelsColors.textSecondary,
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
        padding: const EdgeInsets.only(top: 1.0, bottom: 10.0),
        child: ListView.builder(
          controller: _listScrollController,
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.015),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            if (index >= _itemFocusNodes.length)
              return const SizedBox.shrink();
            final item = currentList[index];
            final focusNode = _itemFocusNodes[index];

            return Container(
              width: bannerwdt * 1.1,
              margin: const EdgeInsets.only(right: 15.0),
              alignment: Alignment.topCenter,
              child: InkWell(
                focusNode: focusNode,
                onTap: () => _navigateToKidChannelsDetails(item, index),
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    setState(() => _focusedItemIndex = index);
                    _updateAndScrollToFocus(_itemFocusNodes, index,
                        _listScrollController, (bannerwdt * 1.1) + 15);
                  }
                },
                child: OptimizedKidChannelsCard(
                  item: item,
                  isFocused: _focusedItemIndex == index,
                  onTap: () => _navigateToKidChannelsDetails(item, index),
                  cardHeight: bannerhgt * 1.0,
                  networkLogo:
                      _isDisplayingShows ? null : _selectedNetworkLogo,
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
                      KidChannelsColors.accentBlue,
                      KidChannelsColors.accentPurple,
                    ],
                  ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: Text(
                    "Search in $_selectedChannelFiltertitle",
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: KidChannelsColors.accentPurple, width: 2),
                  ),
                  child: Text(
                    _searchText.isEmpty ? 'Start typing...' : _searchText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _searchText.isEmpty
                          ? Colors.white54
                          : Colors.white,
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
    int startIndex = _getFocusNodeIndexForKey(rowIndex, 0);

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
                    ? KidChannelsColors.accentPurple
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
                  fontWeight:
                      isFocused ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSliderIndicators() {
    if (_currentKidChannelsSliders.length <= 1) {
      return const SizedBox(height: 28);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_currentKidChannelsSliders.length, (index) {
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

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: KidChannelsColors.surfaceDark.withOpacity(0.5),
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
                color: KidChannelsColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              focusNode: FocusNode(),
              onPressed: () => _fetchDataForPage(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: KidChannelsColors.accentBlue,
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
// SECTION 3: REUSABLE UI COMPONENTS (KID CHANNELS)
//==============================================================================

class OptimizedKidChannelsCard extends StatelessWidget {
  final KidChannelsModel item;
  final bool isFocused;
  final VoidCallback onTap;
  final double cardHeight;
  final String? networkLogo;
  final int uniqueIndex;

  const OptimizedKidChannelsCard({
    Key? key,
    required this.item,
    required this.isFocused,
    required this.onTap,
    required this.cardHeight,
    this.networkLogo,
    required this.uniqueIndex,
  }) : super(key: key);

  final List<Color> _focusColors = const [
    KidChannelsColors.accentOrange,
    KidChannelsColors.accentGreen,
    KidChannelsColors.accentBlue,
    KidChannelsColors.accentPurple,
    KidChannelsColors.accentPink
  ];

  @override
  Widget build(BuildContext context) {
    final focusColor = _focusColors[uniqueIndex % _focusColors.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: cardHeight, // Defines Image area height
          width: double.infinity,
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
                  _buildKidChannelsImage(),
                  if (isFocused)
                    Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
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
                            backgroundImage:
                                CachedNetworkImageProvider(networkLogo!),
                            backgroundColor: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
        // const SizedBox(height: 8), // Spacing between Image and Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(item.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isFocused
                      ? focusColor
                      : Colors.white, // ✅ White color for visibility
                  fontSize: 15,
                  fontWeight: isFocused ? FontWeight.bold : FontWeight.w500,
                  shadows: [
                    Shadow(
                        color: Colors.black.withOpacity(0.8),
                        blurRadius: 2,
                        offset: Offset(0, 1))
                  ]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildKidChannelsImage() {
    // IMPORTANT: Now we just use the unified 'image' field
    final imageUrl = item.image;

    return imageUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.fill,
            placeholder: (context, url) => _buildImagePlaceholder(),
            errorWidget: (context, url, error) {
              debugPrint('Error loading item image: $imageUrl, Error: $error');
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
            KidChannelsColors.accentGreen,
            KidChannelsColors.accentBlue,
          ],
        ),
      ),
      child: const Icon(
        Icons.toys_outlined, // ✅ KidChannels Placeholder
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class KidChannelsThumbnailSlider extends StatefulWidget {
  final List<SliderModel> sliders;
  final ValueChanged<int> onPageChanged;
  final PageController controller;

  const KidChannelsThumbnailSlider({
    Key? key,
    required this.sliders,
    required this.onPageChanged,
    required this.controller,
  }) : super(key: key);

  @override
  _KidChannelsThumbnailSliderState createState() =>
      _KidChannelsThumbnailSliderState();
}

class _KidChannelsThumbnailSliderState
    extends State<KidChannelsThumbnailSlider> {
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
  void didUpdateWidget(KidChannelsThumbnailSlider oldWidget) {
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
              CachedNetworkImage(
                imageUrl: slider.thumbnail,
                fit: BoxFit.fill,
                placeholder: (context, url) =>
                    Container(color: KidChannelsColors.surfaceDark),
                errorWidget: (context, url, error) {
                  debugPrint('Error loading slider image: ${slider.thumbnail}');
                  return Container(color: KidChannelsColors.surfaceDark);
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      KidChannelsColors.primaryDark.withOpacity(0.2),
                      KidChannelsColors.primaryDark.withOpacity(0.4),
                      KidChannelsColors.primaryDark.withOpacity(0.6),
                      KidChannelsColors.primaryDark.withOpacity(0.9),
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


