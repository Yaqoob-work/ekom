import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/services/history_service.dart';

// COMMON CLASSES
class ProfessionalColors {
  static const primaryDark = Color(0xFF0A0E1A);
  static const surfaceDark = Color(0xFF1A1D29);
  static const cardDark = Color(0xFF2A2D3A);
  static const accentBlue = Color(0xFF3B82F6);
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
    return NetworkModel(id: json['id'] ?? 0, name: json['name'] ?? '', logo: json['logo']);
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

class ProfessionalWebSeriesLoadingIndicator extends StatelessWidget {
  final String message;
  const ProfessionalWebSeriesLoadingIndicator({Key? key, required this.message}) : super(key: key);
  
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

// PAGE WIDGET
class ProfessionalWebSeriesGridPage extends StatefulWidget {
  final String title;
  const ProfessionalWebSeriesGridPage({Key? key, this.title = 'All Web Series'}) : super(key: key);

  @override
  _ProfessionalWebSeriesGridPageState createState() => _ProfessionalWebSeriesGridPageState();
}

class _ProfessionalWebSeriesGridPageState extends State<ProfessionalWebSeriesGridPage>
    with SingleTickerProviderStateMixin {
  List<WebSeriesModel> _webSeriesList = [];
  bool _isLoading = true;
  String? _errorMessage;

  static const String _cacheKeyWebSeries = 'grid_page_cached_web_series';
  static const String _cacheKeyTimestamp = 'grid_page_cached_web_series_timestamp';
  static const int _cacheDurationMs = 60 * 60 * 1000;

  List<FocusNode> _itemFocusNodes = [];
  List<FocusNode> _networkFocusNodes = [];
  List<FocusNode> _genreFocusNodes = [];
  List<FocusNode> _keyboardFocusNodes = [];
  final FocusNode _widgetFocusNode = FocusNode();
  final ScrollController _listScrollController = ScrollController();
  final ScrollController _networkScrollController = ScrollController();
  final ScrollController _genreScrollController = ScrollController();
  
  int _focusedKeyRow = 0;
  int _focusedKeyCol = 0;
  final List<List<String>> _keyboardLayout = [
    "1234567890".split(''),
    "qwertyuiop".split(''),
    "asdfghjkl".split(''),
    ["z", "x", "c", "v", "b", "n", "m", "DEL"],
    [" ", "OK"],
  ];

  int _focusedNetworkIndex = 0;
  int _focusedGenreIndex = 0;
  int _focusedItemIndex = -1;
  String _selectedNetworkName = '';
  String? _selectedNetworkLogo;
  String _selectedGenre = 'All';
  List<WebSeriesModel> _filteredWebSeriesList = [];
  List<String> _uniqueNetworks = [];
  List<String> _uniqueGenres = [];

  bool _isVideoLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _currentBackgroundUrl;
  
  String _lastNavigationDirection = 'horizontal';

  // Search state
  bool _isSearching = false;
  bool _showKeyboard = false;
  String _searchText = '';
  Timer? _debounce;
  List<WebSeriesModel> _searchResults = [];
  bool _isSearchLoading = false;
  late FocusNode _searchButtonFocusNode;

  @override
  void initState() {
    super.initState();
    _searchButtonFocusNode = FocusNode();
    _searchButtonFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
    _fetchDataForPage();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _widgetFocusNode.dispose();
    _listScrollController.dispose();
    _networkScrollController.dispose();
    _genreScrollController.dispose();
    _searchButtonFocusNode.dispose();
    _debounce?.cancel();
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
            _buildDynamicBackground(),
            _isLoading
                ? const Center(child: ProfessionalWebSeriesLoadingIndicator(message: 'Loading All Series...'))
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : _buildPageContent(),
            if (_isVideoLoading && _errorMessage == null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: const Center(
                    child: ProfessionalWebSeriesLoadingIndicator(message: 'Loading Details...'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicBackground() {
    return AnimatedSwitcher(
      duration: AnimationTiming.medium,
      child: _currentBackgroundUrl != null && _currentBackgroundUrl!.isNotEmpty
          ? Container(
              key: ValueKey<String>(_currentBackgroundUrl!),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(_currentBackgroundUrl!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ProfessionalColors.primaryDark.withOpacity(0.5),
                      ProfessionalColors.primaryDark.withOpacity(0.7),
                      ProfessionalColors.primaryDark.withOpacity(0.85),
                      ProfessionalColors.primaryDark,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 0.85],
                  ),
                ),
              ),
            )
          : Container(
              key: const ValueKey<String>('no_bg'),
              decoration: BoxDecoration(
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

  Widget _buildPageContent() {
    return Column(
      children: [
        _buildTopFilterBar(),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildContentBody(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopFilterBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20,
            bottom: 10,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Focus(
                canRequestFocus: false,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(child: _buildNetworkFilter()),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<WebSeriesModel>> _fetchAndCacheWebSeries({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh) {
      final cachedTimestampStr = prefs.getString(_cacheKeyTimestamp);
      if (cachedTimestampStr != null) {
        final cachedTimestamp = int.parse(cachedTimestampStr);
        final now = DateTime.now().millisecondsSinceEpoch;
        if ((now - cachedTimestamp) < _cacheDurationMs) {
          final cachedData = prefs.getString(_cacheKeyWebSeries);
          if (cachedData != null) {
            print("✅ Loading ALL web series from CACHE.");
            final List<dynamic> jsonData = json.decode(cachedData);
            return jsonData
                .map((item) => WebSeriesModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }
      }
    }
    print("🌍 Fetching ALL web series from NETWORK.");
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
        await prefs.setString(_cacheKeyWebSeries, response.body);
        await prefs.setString(_cacheKeyTimestamp, DateTime.now().millisecondsSinceEpoch.toString());
        return jsonData
            .map((item) => WebSeriesModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      final cachedData = prefs.getString(_cacheKeyWebSeries);
      if (cachedData != null) {
        print("⚠️ Network failed. Falling back to STALE CACHE.");
        final List<dynamic> jsonData = json.decode(cachedData);
        return jsonData
            .map((item) => WebSeriesModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load web series and no cache available: $e');
    }
  }

  Future<void> _fetchDataForPage({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedList = await _fetchAndCacheWebSeries(forceRefresh: forceRefresh);
      fetchedList.sort((a, b) => a.seriesOrder.compareTo(b.seriesOrder));
      if (mounted) {
        if (fetchedList.isEmpty) _errorMessage = "No Web Series Found.";
        setState(() => _webSeriesList = fetchedList);

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
      print("❌ Error in Page data pipeline: $e");
      if (mounted)
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load Web Series.\nPlease check your connection.";
        });
    }
  }

  KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
    
    bool searchHasFocus = _searchButtonFocusNode.hasFocus;
    bool networkHasFocus = _networkFocusNodes.any((n) => n.hasFocus);
    bool genreHasFocus = _genreFocusNodes.any((n) => n.hasFocus);
    bool listHasFocus = _itemFocusNodes.any((n) => n.hasFocus);
    bool keyboardHasFocus = _keyboardFocusNodes.any((n) => n.hasFocus);
    final LogicalKeyboardKey key = event.logicalKey;

    if (key == LogicalKeyboardKey.goBack) {
      if (_showKeyboard && keyboardHasFocus) {
        setState(() {
          _showKeyboard = false;
          _focusedKeyRow = 0;
          _focusedKeyCol = 0;
        });
        _searchButtonFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (_showKeyboard) {
        setState(() => _showKeyboard = false);
        _searchButtonFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (listHasFocus || genreHasFocus || searchHasFocus) {
        _networkFocusNodes[_focusedNetworkIndex].requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // Handle keyboard navigation
    if (keyboardHasFocus && _showKeyboard) {
      return _navigateKeyboard(key);
    }

    // Handle search button
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
        _itemFocusNodes[0].requestFocus();
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
      if (networkHasFocus)
        _navigateNetworks(key);
      else if (genreHasFocus)
        _navigateGenres(key);
      else if (listHasFocus) _navigateList(key);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
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
      if (newCol > 0) {
        newCol--;
      }
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (newCol < _keyboardLayout[newRow].length - 1) {
        newCol++;
      }
    } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
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

  int _getFocusNodeIndexForKey(int row, int col) {
    int index = 0;
    for (int r = 0; r < row; r++) {
      index += _keyboardLayout[r].length;
    }
    return index + col;
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
            const SizedBox(height: 32),
            ElevatedButton.icon(
              focusNode: FocusNode(),
              onPressed: () => _fetchDataForPage(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: ProfessionalColors.accentBlue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

  void _processInitialData() {
    if (_webSeriesList.isEmpty) return;
    Set<String> allNetworks = {};
    for (var series in _webSeriesList) {
      for (var network in series.networks) {
        allNetworks.add(network.name);
      }
    }
    _uniqueNetworks = allNetworks.toList()..sort();
    if (_uniqueNetworks.isNotEmpty) {
      _selectedNetworkName = _uniqueNetworks[0];
      _updateSelectedNetworkLogo();
      _updateGenresForSelectedNetwork();
    }
    _applyFilters();
  }

  void _initializeFocusNodes() {
    _disposeFocusNodes(_networkFocusNodes);
    _networkFocusNodes =
        List.generate(_uniqueNetworks.length, (index) => FocusNode(debugLabel: 'Network-$index'));
    _rebuildGenreFocusNodes();
    _rebuildItemFocusNodes();
    _rebuildKeyboardFocusNodes();
  }

  void _rebuildKeyboardFocusNodes() {
    _disposeFocusNodes(_keyboardFocusNodes);
    int totalKeys = 0;
    for (var row in _keyboardLayout) {
      totalKeys += row.length;
    }
    _keyboardFocusNodes = List.generate(totalKeys, (index) => FocusNode(debugLabel: 'Key-$index'));
  }

  void _rebuildGenreFocusNodes() {
    _disposeFocusNodes(_genreFocusNodes);
    _genreFocusNodes =
        List.generate(_uniqueGenres.length, (index) => FocusNode(debugLabel: 'Genre-$index'));
  }

  void _rebuildItemFocusNodes() {
    _disposeFocusNodes(_itemFocusNodes);
    final currentList = _isSearching ? _searchResults : _filteredWebSeriesList;
    _itemFocusNodes = List.generate(
        currentList.length, (index) => FocusNode(debugLabel: 'Item-$index'));
  }

  void _applyFilters() {
    if (_isSearching) {
      setState(() {
        _isSearching = false;
        _searchText = '';
        _searchResults.clear();
      });
    }

    _filteredWebSeriesList = _webSeriesList.where((series) {
      final bool networkMatch =
          _selectedNetworkName.isEmpty || series.networks.any((n) => n.name == _selectedNetworkName);
      final bool genreMatch = _selectedGenre == 'All' ||
          (series.genres?.split(',').map((e) => e.trim()).contains(_selectedGenre) ?? false);
      return networkMatch && genreMatch;
    }).toList();
    _rebuildItemFocusNodes();
    _focusedItemIndex = -1;
  }

  void _updateGenresForSelectedNetwork() {
    if (_selectedNetworkName.isEmpty) return;
    final networkSpecificSeries = _webSeriesList
        .where((series) => series.networks.any((n) => n.name == _selectedNetworkName))
        .toList();
    Set<String> genres = {'All'};
    for (var series in networkSpecificSeries) {
      if (series.genres != null && series.genres!.isNotEmpty) {
        genres.addAll(series.genres!.split(',').map((e) => e.trim()).where((g) => g.isNotEmpty));
      }
    }
    _uniqueGenres = genres.toList()..sort();
    if (!_uniqueGenres.contains('All')) _uniqueGenres.insert(0, 'All');
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(duration: AnimationTiming.medium, vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  void _startAnimations() {
    _fadeController.forward();
  }

  void _disposeFocusNodes(List<FocusNode> nodes) {
    for (var node in nodes) {
      node.dispose();
    }
  }

  // Search Methods
  Future<List<WebSeriesModel>> _performSearchInNetwork(String searchTerm) async {
    if (searchTerm.isEmpty || _selectedNetworkName.isEmpty) {
      return [];
    }

    final networkSeries = _webSeriesList
        .where((series) => series.networks.any((n) => n.name == _selectedNetworkName))
        .toList();

    return networkSeries
        .where((series) => series.name.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
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
    } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _updateSelectedNetwork();
      return;
    }
    if (newIndex != _focusedNetworkIndex) {
      setState(() => _focusedNetworkIndex = newIndex);
      _networkFocusNodes[newIndex].requestFocus();
      _updateAndScrollToFocus(_networkFocusNodes, newIndex, _networkScrollController, 160);
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
        _itemFocusNodes[0].requestFocus();
      }
      return;
    } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _updateSelectedGenre();
      return;
    }
    if (newIndex != _focusedGenreIndex) {
      setState(() => _focusedGenreIndex = newIndex);
      _genreFocusNodes[newIndex].requestFocus();
      _updateAndScrollToFocus(_genreFocusNodes, newIndex, _genreScrollController, 160);
    }
  }

  void _navigateList(LogicalKeyboardKey key) {
    if (_focusedItemIndex == -1 || _itemFocusNodes.isEmpty) return;
    int newIndex = _focusedItemIndex;
    if (key == LogicalKeyboardKey.arrowUp) {
      setState(() => _lastNavigationDirection = 'vertical');
      if (_genreFocusNodes.isNotEmpty)
        _genreFocusNodes[_focusedGenreIndex].requestFocus();
      else
        _searchButtonFocusNode.requestFocus();
      setState(() => _focusedItemIndex = -1);
      return;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      return;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (newIndex > 0) {
        newIndex--;
        setState(() => _lastNavigationDirection = 'horizontal');
      }
    } else if (key == LogicalKeyboardKey.arrowRight) {
      final currentList = _isSearching ? _searchResults : _filteredWebSeriesList;
      if (newIndex + 1 < currentList.length) {
        newIndex++;
        setState(() => _lastNavigationDirection = 'horizontal');
      }
    } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      final currentList = _isSearching ? _searchResults : _filteredWebSeriesList;
      _navigateToWebSeriesDetails(currentList[_focusedItemIndex], _focusedItemIndex);
      return;
    }
    if (newIndex != _focusedItemIndex) {
      setState(() => _focusedItemIndex = newIndex);
      _itemFocusNodes[newIndex].requestFocus();
    }
  }

  void _updateSelectedNetworkLogo() {
    _selectedNetworkLogo = _webSeriesList
        .expand((s) => s.networks)
        .firstWhere((n) => n.name == _selectedNetworkName,
            orElse: () => NetworkModel(id: -1, name: '', logo: null))
        .logo;
    setState(() {
      _currentBackgroundUrl = _selectedNetworkLogo;
    });
  }

  void _updateSelectedNetwork() {
    setState(() {
      _selectedNetworkName = _uniqueNetworks[_focusedNetworkIndex];
      _updateSelectedNetworkLogo();
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

  void _updateAndScrollToFocus(
      List<FocusNode> nodes, int index, ScrollController controller, double itemWidth) {
    if (!mounted || index < 0 || index >= nodes.length || !controller.hasClients) return;
    double screenWidth = MediaQuery.of(context).size.width;
    double scrollPosition = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    controller.animateTo(
      scrollPosition.clamp(0.0, controller.position.maxScrollExtent),
      duration: AnimationTiming.fast,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _navigateToWebSeriesDetails(WebSeriesModel webSeries, int index) async {
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
      print("History update failed: $e");
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

  Widget _buildNetworkFilter() {
    final bool networkSectionHasFocus = _networkFocusNodes.any((n) => n.hasFocus);
    
    return SizedBox(
      height: screenhgt * 0.07,
      child: ListView.builder(
        controller: _networkScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _uniqueNetworks.length,
        itemBuilder: (context, index) {
          return _buildFilterButton(
            focusNode: _networkFocusNodes[index],
            text: _uniqueNetworks[index],
            isFocused: networkSectionHasFocus && _focusedNetworkIndex == index,
            isSelected: _selectedNetworkName == _uniqueNetworks[index],
            navigationDirection: _lastNavigationDirection,
            sectionType: 'network',
            onTap: () {
              setState(() => _focusedNetworkIndex = index);
              _networkFocusNodes[index].requestFocus();
              _updateSelectedNetwork();
            },
            onFocusChange: (hasFocus) {
              if (hasFocus) setState(() => _focusedNetworkIndex = index);
            },
          );
        },
      ),
    );
  }

  Widget _buildContentBody() {
    
    return Column(
      children: [
        SizedBox(
          height: screenhgt * 0.52,
          child: _showKeyboard ? _buildSearchUI() : const SizedBox.shrink(),
        ),
        _buildGenreFilter(),
        const SizedBox(height: 8),
        _buildWebSeriesList(),
      ],
    );
  }

  Widget _buildGenreFilter() {
    if (_uniqueGenres.length <= 1 && !_isSearching) return const SizedBox.shrink();
    
    final bool genreSectionHasFocus = _genreFocusNodes.any((n) => n.hasFocus);
    
    return Container(
      height: screenhgt * 0.07,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        controller: _genreScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _uniqueGenres.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Focus(
              focusNode: _searchButtonFocusNode,
              child: InkWell(
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
                child: AnimatedContainer(
                  duration: AnimationTiming.fast,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _searchButtonFocusNode.hasFocus
                        ? const LinearGradient(
                            colors: [
                              ProfessionalColors.accentOrange,
                              ProfessionalColors.accentPink,
                            ],
                          )
                        : null,
                    color: _searchButtonFocusNode.hasFocus
                        ? null
                        : (_isSearching
                            ? ProfessionalColors.accentPurple
                            : Colors.white.withOpacity(0.05)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _searchButtonFocusNode.hasFocus
                          ? Colors.white
                          : (_isSearching
                              ? ProfessionalColors.accentPurple.withOpacity(0.5)
                              : Colors.white.withOpacity(0.1)),
                      width: _searchButtonFocusNode.hasFocus ? 3.0 : 1.0,
                    ),
                    boxShadow: _searchButtonFocusNode.hasFocus
                        ? [
                            BoxShadow(
                              color: ProfessionalColors.accentOrange.withOpacity(0.7),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : _isSearching
                            ? [
                                BoxShadow(
                                  color: ProfessionalColors.accentPurple.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isSearching ? 'SEARCHING...' : 'SEARCH',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          
          final genreIndex = index - 1;
          return _buildFilterButton(
            focusNode: _genreFocusNodes[genreIndex],
            text: _uniqueGenres[genreIndex],
            isFocused: genreSectionHasFocus && _focusedGenreIndex == genreIndex,
            isSelected: _selectedGenre == _uniqueGenres[genreIndex],
            navigationDirection: _lastNavigationDirection,
            sectionType: 'genre',
            onTap: () {
              setState(() => _focusedGenreIndex = genreIndex);
              _genreFocusNodes[genreIndex].requestFocus();
              _updateSelectedGenre();
            },
            onFocusChange: (hasFocus) {
              if (hasFocus) setState(() => _focusedGenreIndex = genreIndex);
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterButton({
    required FocusNode focusNode,
    required String text,
    required bool isFocused,
    required bool isSelected,
    required String navigationDirection,
    required String sectionType,
    required VoidCallback onTap,
    required ValueChanged<bool> onFocusChange,
  }) {
    Color getFocusedSelectedBorderColor() {
      if (sectionType == 'network') {
        return const Color(0xFF00D9FF);
      } else {
        return const Color(0xFFFF6B35);
      }
    }
    
    Color getBackgroundColor() {
      if (isFocused && isSelected) {
        return ProfessionalColors.accentPurple;
      } else if (isFocused) {
        return ProfessionalColors.accentBlue;
      } else if (isSelected) {
        return ProfessionalColors.accentPurple.withOpacity(0.4);
      }
      return Colors.white.withOpacity(0.05);
    }

    Color getBorderColor() {
      if (isFocused && isSelected) {
        return getFocusedSelectedBorderColor();
      } else if (isFocused) {
        return Colors.white.withOpacity(0.9);
      } else if (isSelected) {
        return Colors.white.withOpacity(0.15);
      }
      return Colors.white.withOpacity(0.1);
    }

    Color getTextColor() {
      if (isFocused && isSelected) {
        return getFocusedSelectedBorderColor();
      } else if (isFocused) {
        return Colors.white;
      } else if (isSelected) {
        return Colors.white.withOpacity(0.5);
      }
      return Colors.white.withOpacity(0.7);
    }

    double getBorderWidth() {
      if (isFocused) {
        return 3.0;
      } else if (isSelected) {
        return 1.0;
      }
      return 1.0;
    }

    double getScale() {
      return isFocused ? 1.05 : 1.0;
    }

    List<BoxShadow>? getBoxShadow() {
      if (isFocused && isSelected) {
        return [
          BoxShadow(
            color: getFocusedSelectedBorderColor().withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ];
      } else if (isFocused) {
        return [
          BoxShadow(
            color: ProfessionalColors.accentBlue.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ];
      }
      return null;
    }

    return Transform.scale(
      scale: getScale(),
      child: InkWell(
        focusNode: focusNode,
        onTap: onTap,
        onFocusChange: onFocusChange,
        child: AnimatedContainer(
          duration: AnimationTiming.fast,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: getBackgroundColor(),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: getBorderColor(),
              width: getBorderWidth(),
            ),
            boxShadow: getBoxShadow(),
          ),
          child: Center(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                color: getTextColor(),
                fontWeight: isFocused || isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: isFocused ? 13 : 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebSeriesList() {
    final currentList = _isSearching ? _searchResults : _filteredWebSeriesList;
    
    if (_isSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentList.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(20),
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
                size: 60,
                color: ProfessionalColors.textSecondary,
              ),
              const SizedBox(height: 16),
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
      );
    }

    return SizedBox(
      height: bannerhgt * 1.5,
      child: ListView.builder(
        controller: _listScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        itemCount: currentList.length,
        itemBuilder: (context, index) {
          return Container(
            width: bannerwdt,
            margin: const EdgeInsets.only(right: 16),
            child: InkWell(
              focusNode: _itemFocusNodes[index],
              onTap: () => _navigateToWebSeriesDetails(currentList[index], index),
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  setState(() => _focusedItemIndex = index);
                  _updateAndScrollToFocus(_itemFocusNodes, index, _listScrollController, bannerwdt + 16);
                }
              },
              child: OptimizedWebSeriesCard(
                webSeries: currentList[index],
                isFocused: _focusedItemIndex == index,
                onTap: () => _navigateToWebSeriesDetails(currentList[index], index),
                cardHeight: bannerhgt * 2,
              ),
            ),
          );
        },
      ),
    );
  }
}

class OptimizedWebSeriesCard extends StatelessWidget {
  final WebSeriesModel webSeries;
  final bool isFocused;
  final VoidCallback onTap;
  final double cardHeight;

  const OptimizedWebSeriesCard({
    Key? key,
    required this.webSeries,
    required this.isFocused,
    required this.onTap,
    required this.cardHeight,
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
      curve: Curves.easeInOut,
      transform: isFocused ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
      transformAlignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (isFocused)
                    BoxShadow(
                      color: dominantColor.withOpacity(0.5),
                      blurRadius: 24,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    border: isFocused
                        ? Border.all(
                            color: dominantColor,
                            width: 3,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildWebSeriesImage(),
                      _buildGradientOverlay(),
                      if (isFocused) _buildPlayButton(dominantColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildWebSeriesInfo(dominantColor),
        ],
      ),
    );
  }

  Widget _buildWebSeriesImage() {
    final imageUrl = webSeries.poster ?? webSeries.banner;
    final String uniqueImageUrl = "${imageUrl}?v=${webSeries.updatedAt}";
    final String uniqueCacheKey = "${webSeries.id.toString()}_${webSeries.updatedAt}";
    return imageUrl != null && imageUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: uniqueImageUrl,
            fit: BoxFit.cover,
            memCacheHeight: (cardHeight * 1.2).toInt(),
            cacheKey: uniqueCacheKey,
            placeholder: (context, url) => _buildImagePlaceholder(),
            errorWidget: (context, url, error) => _buildImagePlaceholder(),
          )
        : _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: ProfessionalColors.cardDark,
      child: Center(
        child: Icon(
          Icons.tv_rounded,
          size: 50,
          color: ProfessionalColors.textSecondary.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.5),
              // Colors.black.withOpacity(0.95),
            ],
            stops: const [0.0, 0.5, 0.8, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildWebSeriesInfo(Color dominantColor) {
    final fontSize = (cardHeight * 0.045).clamp(11.0, 14.0);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        webSeries.name,
        style: TextStyle(
          color: isFocused ? dominantColor : Colors.white,
          fontSize: isFocused ? fontSize + 1 : fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
          height: 1.2,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPlayButton(Color dominantColor) {
    final buttonSize = (cardHeight * 0.12).clamp(32.0, 44.0);
    final iconSize = buttonSize * 0.65;
    
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [dominantColor, dominantColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: dominantColor.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}