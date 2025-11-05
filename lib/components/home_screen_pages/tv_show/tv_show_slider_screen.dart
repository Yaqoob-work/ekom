








// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';
// // CHANGE 1: CachedNetworkImage import ko hata diya gaya hai.
// // import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:math' as math;
// import 'package:http/http.dart' as https;
// import 'package:shared_preferences/shared_preferences.dart';

// // NOTE: Apne project ke anusaar neeche di gayi import lines ko aavashyakta anusaar badlein.
// // Make sure to change the import lines below according to your project structure.
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/webseries_details_page.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';

// //==============================================================================
// // SECTION 1: COMMON CLASSES AND MODELS
// // Yeh classes data ko handle karne aur consistent UI ke liye hain.
// //==============================================================================

// class ProfessionalColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentGreen = Color.fromARGB(255, 59, 246, 68);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentPink = Color(0xFFEC4899);
//   static const accentOrange = Color(0xFFF59E0B);
//   static const accentRed = Color(0xFFEF4444);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);

//   static List<Color> gradientColors = [accentBlue, accentPurple, accentPink];
// }

// class AnimationTiming {
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
// }

// class NetworkModel {
//   final int id;
//   final String name;
//   final String? logo;
//   NetworkModel({required this.id, required this.name, this.logo});
//   factory NetworkModel.fromJson(Map<String, dynamic> json) {
//     return NetworkModel(
//         id: json['id'] ?? 0, name: json['name'] ?? '', logo: json['logo']);
//   }
// }

// class WebSeriesModel {
//   final int id;
//   final String name;
//   final String updatedAt;
//   final String? poster;
//   final String? banner;
//   final String? genres;
//   final int seriesOrder;
//   final List<NetworkModel> networks;

//   WebSeriesModel({
//     required this.id,
//     required this.name,
//     required this.updatedAt,
//     this.poster,
//     this.banner,
//     this.genres,
//     required this.seriesOrder,
//     this.networks = const [],
//   });

//   factory WebSeriesModel.fromJson(Map<String, dynamic> json) {
//     var networks = (json['networks'] as List? ?? [])
//         .map((item) => NetworkModel.fromJson(item as Map<String, dynamic>))
//         .toList();
//     return WebSeriesModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       poster: json['poster'],
//       banner: json['banner'],
//       genres: json['genres'],
//       seriesOrder: json['series_order'] ?? 9999,
//       networks: networks,
//     );
//   }
// }

// class SliderModel {
//   final int id;
//   final String title;
//   final String banner;
//   final String sliderFor;

//   SliderModel(
//       {required this.id,
//       required this.title,
//       required this.banner,
//       required this.sliderFor});

//   factory SliderModel.fromJson(Map<String, dynamic> json) {
//     return SliderModel(
//       id: json['id'] ?? 0,
//       title: json['title'] ?? '',
//       banner: json['banner'] ?? '',
//       sliderFor: json['slider_for'] ?? '',
//     );
//   }
// }

// class ApiNetworkModel {
//   final int id;
//   final String name;
//   final String? logo;
//   final int networksOrder;
//   final List<SliderModel> sliders;

//   ApiNetworkModel({
//     required this.id,
//     required this.name,
//     this.logo,
//     required this.networksOrder,
//     this.sliders = const [],
//   });

//   factory ApiNetworkModel.fromJson(Map<String, dynamic> json) {
//     var sliders = (json['sliders'] as List? ?? [])
//         .map((item) => SliderModel.fromJson(item as Map<String, dynamic>))
//         .toList();
//     return ApiNetworkModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       logo: json['logo'],
//       networksOrder: json['networks_order'] ?? 9999,
//       sliders: sliders,
//     );
//   }
// }

// class ProfessionalWebSeriesLoadingIndicator extends StatelessWidget {
//   final String message;
//   const ProfessionalWebSeriesLoadingIndicator({Key? key, required this.message})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: ProfessionalColors.gradientColors,
//               ),
//             ),
//             child: const CircularProgressIndicator(
//               color: Colors.white,
//               strokeWidth: 3,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             message,
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


// //==============================================================================
// // SECTION 2: MAIN PAGE WIDGET AND STATE
// // Yeh page ka main structure aur logic hai.
// //==============================================================================

// class TvShowSliderScreen extends StatefulWidget {
//   final String title;
//   const TvShowSliderScreen({Key? key, this.title = 'All Web Series'})
//       : super(key: key);

//   @override
//   _TvShowSliderScreenState createState() =>
//       _TvShowSliderScreenState();
// }

// class _TvShowSliderScreenState
//     extends State<TvShowSliderScreen>
//     with SingleTickerProviderStateMixin {
//   List<WebSeriesModel> _webSeriesList = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   // CHANGE 2: Cache se sambandhit variables hata diye gaye hain.
//   // static const String _cacheKeyWebSeries = 'grid_page_cached_web_series';
//   // static const String _cacheKeyTimestamp = 'grid_page_cached_web_series_timestamp';
//   // static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour cache

//   // Focus and Scroll Controllers
//   List<FocusNode> _itemFocusNodes = [];
//   List<FocusNode> _networkFocusNodes = [];
//   List<FocusNode> _genreFocusNodes = [];
//   List<FocusNode> _keyboardFocusNodes = [];
//   final FocusNode _widgetFocusNode = FocusNode();
//   final ScrollController _listScrollController = ScrollController();
//   final ScrollController _networkScrollController = ScrollController();
//   final ScrollController _genreScrollController = ScrollController();

//   late PageController _sliderPageController;

//   // Keyboard State
//   int _focusedKeyRow = 0;
//   int _focusedKeyCol = 0;
//   final List<List<String>> _keyboardLayout = [
//     "1234567890".split(''),
//     "qwertyuiop".split(''),
//     "asdfghjkl".split(''),
//     ["z", "x", "c", "v", "b", "n", "m", "DEL"],
//     [" ", "OK"],
//   ];

//   // UI and Filter State
//   int _focusedNetworkIndex = 0;
//   int _focusedGenreIndex = 0;
//   int _focusedItemIndex = -1;
//   String _selectedNetworkName = '';
//   String? _selectedNetworkLogo;
//   String _selectedGenre = 'All';
//   List<WebSeriesModel> _filteredWebSeriesList = [];
//   List<ApiNetworkModel> _apiNetworks = [];
//   List<String> _uniqueNetworks = [];
//   List<String> _uniqueGenres = [];

//   // Animation and Loading State
//   bool _isVideoLoading = false;
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//   String? _currentBackgroundUrl;
//   List<SliderModel> _currentWebSeriesSliders = [];
//   int _currentSliderIndex = 0;

//   String _lastNavigationDirection = 'horizontal';

//   // ===== FIX START: Hang/Crash issue ko theek karne ke liye variables =====
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;
//   // ===== FIX END =====

//   // Search State
//   bool _isSearching = false;
//   bool _showKeyboard = false;
//   String _searchText = '';
//   Timer? _debounce;
//   List<WebSeriesModel> _searchResults = [];
//   bool _isSearchLoading = false;
//   late FocusNode _searchButtonFocusNode;

//   bool _isGenreLoading = false;

//   final List<Color> _focusColors = [
//     ProfessionalColors.accentBlue,
//     ProfessionalColors.accentPurple,
//     ProfessionalColors.accentOrange,
//     ProfessionalColors.accentPink,
//     ProfessionalColors.accentRed
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _sliderPageController = PageController();
//     _searchButtonFocusNode = FocusNode();
//     _searchButtonFocusNode.addListener(() {
//       if (mounted) setState(() {});
//     });
//     _fetchDataForPage();
//     _initializeAnimations();
//   }

//   @override
//   void dispose() {
//     _sliderPageController.dispose();
//     _fadeController.dispose();
//     _widgetFocusNode.dispose();
//     _listScrollController.dispose();
//     _networkScrollController.dispose();
//     _genreScrollController.dispose();
//     _searchButtonFocusNode.dispose();
//     _debounce?.cancel();

//     // ===== FIX START: Memory leak se bachne ke liye Timer ko cancel karein =====
//     _navigationLockTimer?.cancel();
//     // ===== FIX END =====

//     _disposeFocusNodes(_itemFocusNodes);
//     _disposeFocusNodes(_networkFocusNodes);
//     _disposeFocusNodes(_genreFocusNodes);
//     _disposeFocusNodes(_keyboardFocusNodes);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Focus(
//         focusNode: _widgetFocusNode,
//         autofocus: true,
//         onKey: _onKeyHandler,
//         child: Stack(
//           children: [
//             _buildBackgroundOrSlider(),
//             _isLoading
//                 ? const Center(
//                     child: ProfessionalWebSeriesLoadingIndicator(
//                         message: 'Loading All Series...'))
//                 : _errorMessage != null
//                     ? _buildErrorWidget()
//                     : _buildPageContent(),
//             if (_isVideoLoading && _errorMessage == null)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.8),
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

//   //=================================================
//   // SECTION 2.1: DATA FETCHING AND PROCESSING
//   //=================================================

//   Future<void> _fetchDataForPage({bool forceRefresh = false}) async {
//     if (!mounted) return;
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       final results = await Future.wait([
//         _fetchAndCacheWebSeries(forceRefresh: forceRefresh),
//         _fetchNetworks(),
//       ]);
//       final fetchedList = results[0] as List<WebSeriesModel>;
//       final fetchedNetworks = results[1] as List<ApiNetworkModel>;
//       fetchedList.sort((a, b) => a.seriesOrder.compareTo(b.seriesOrder));
//       fetchedNetworks
//           .sort((a, b) => a.networksOrder.compareTo(b.networksOrder));
      
//       // CHANGE 3: Data fetch hone ke baad list ko ek baar shuffle karein.
//       fetchedList.shuffle();

//       if (mounted) {
//         if (fetchedList.isEmpty) _errorMessage = "No Web Series Found.";
//         setState(() {
//           _webSeriesList = fetchedList;
//           _apiNetworks = fetchedNetworks;
//         });
//         if (_errorMessage == null) {
//           _processInitialData();
//           _initializeFocusNodes();
//           _startAnimations();
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (mounted && _networkFocusNodes.isNotEmpty) {
//               _networkFocusNodes[0].requestFocus();
//             }
//           });
//         }
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage =
//               "Failed to load Web Series.\nPlease check your connection.";
//         });
//       }
//     }
//   }

//   // CHANGE 4: Caching logic ko function se hata diya gaya hai.
//   // Yeh function ab hamesha API se data fetch karega.
//   Future<List<WebSeriesModel>> _fetchAndCacheWebSeries(
//       {bool forceRefresh = false}) async {
//     final prefs = await SharedPreferences.getInstance();
//     try {
//       String authKey = prefs.getString('result_auth_key') ?? '';
//       final response = await https.get(
//         Uri.parse('https://dashboard.cpplayers.com/api/v2/getAllWebSeries'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': 'coretechinfo.com'
//         },
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         return jsonData
//             .map(
//                 (item) => WebSeriesModel.fromJson(item as Map<String, dynamic>))
//             .toList();
//       } else {
//         throw Exception('API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load web series: $e');
//     }
//   }

//   Future<List<ApiNetworkModel>> _fetchNetworks() async {
//     final prefs = await SharedPreferences.getInstance();
//     final authKey = prefs.getString('result_auth_key') ?? '';
//     try {
//       final response = await https
//           .post(
//             Uri.parse('https://dashboard.cpplayers.com/api/v3/getNetworks'),
//             headers: {
//               'auth-key': authKey,
//               'Content-Type': 'application/json',
//               'Accept': 'application/json',
//               'domain': 'coretechinfo.com'
//             },
//             body: json.encode({"network_id": "", "data_for": "tvshows"}),
//           )
//           .timeout(const Duration(seconds: 30));
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         return jsonData
//             .map((item) => ApiNetworkModel.fromJson(item as Map<String, dynamic>))
//             .toList();
//       } else {
//         throw Exception('API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load networks: $e');
//     }
//   }

//   void _processInitialData() {
//     if (_webSeriesList.isEmpty && _apiNetworks.isEmpty) return;
//     _uniqueNetworks = _apiNetworks.map((n) => n.name).toList();
//     if (_uniqueNetworks.isNotEmpty) {
//       _selectedNetworkName = _uniqueNetworks[0];
//       _updateSelectedNetworkData();
//       _updateGenresForSelectedNetwork();
//     }
//     _applyFilters();
//   }



//   //=================================================
// // SECTION 2.3: STATE MANAGEMENT & UI LOGIC (ke Aas Paas Add Karein)
// //=================================================

//   // ===== FIX START: Pehle scroll karke fir focus karne ke liye naya function =====
//   void _focusFirstListItemWithScroll() {
//     if (_itemFocusNodes.isEmpty) return;

//     // List ko shuruaat mein scroll karein
//     if (_listScrollController.hasClients) {
//       _listScrollController.animateTo(
//         0.0,
//         duration: AnimationTiming.fast, // 250ms
//         curve: Curves.easeInOut,
//       );
//     }

//     // Thodi der baad (scroll animation shuru hone ke baad) pehle item par focus karein.
//     // Isse user ko scroll animation dikhega aur fir focus highlight aayega.
//     Future.delayed(const Duration(milliseconds: 250), () {
//       if (mounted && _itemFocusNodes.isNotEmpty) {
//         setState(() => _focusedItemIndex = 0);
//         _itemFocusNodes[0].requestFocus();
//       }
//     });
//   }
//   // ===== FIX END =====



//   //=================================================
//   // SECTION 2.2: KEYBOARD AND FOCUS NAVIGATION
//   //=================================================

//   KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
//     if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
    
//     bool searchHasFocus = _searchButtonFocusNode.hasFocus;
//     bool networkHasFocus = _networkFocusNodes.any((n) => n.hasFocus);
//     bool genreHasFocus = _genreFocusNodes.any((n) => n.hasFocus);
//     bool listHasFocus = _itemFocusNodes.any((n) => n.hasFocus);
//     bool keyboardHasFocus = _keyboardFocusNodes.any((n) => n.hasFocus);
//     final LogicalKeyboardKey key = event.logicalKey;

//     if (key == LogicalKeyboardKey.goBack) {
//       if (_showKeyboard) {
//         setState(() {
//           _showKeyboard = false;
//           _focusedKeyRow = 0;
//           _focusedKeyCol = 0;
//         });
//         _searchButtonFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (listHasFocus || genreHasFocus || searchHasFocus) {
//         _networkFocusNodes[_focusedNetworkIndex].requestFocus();
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.ignored;
//     }

//     if (keyboardHasFocus && _showKeyboard) {
//       return _navigateKeyboard(key);
//     }
    
//     if (searchHasFocus) {
//       if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//         setState(() {
//           _showKeyboard = true;
//           _focusedKeyRow = 0;
//           _focusedKeyCol = 0;
//         });
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted && _keyboardFocusNodes.isNotEmpty) {
//             _keyboardFocusNodes[0].requestFocus();
//           }
//         });
//         return KeyEventResult.handled;
//       }
//       if (key == LogicalKeyboardKey.arrowLeft) {
//         return KeyEventResult.handled; // Do nothing
//       }
//       if (key == LogicalKeyboardKey.arrowRight && _genreFocusNodes.isNotEmpty) {
//         _genreFocusNodes[0].requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (key == LogicalKeyboardKey.arrowUp && _networkFocusNodes.isNotEmpty) {
//         _networkFocusNodes[_focusedNetworkIndex].requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
//         setState(() => _focusedItemIndex = 0);
//         // _itemFocusNodes[0].requestFocus();
//          _focusFirstListItemWithScroll();
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.handled;
//     }

//     if ([
//       LogicalKeyboardKey.arrowUp,
//       LogicalKeyboardKey.arrowDown,
//       LogicalKeyboardKey.arrowLeft,
//       LogicalKeyboardKey.arrowRight,
//       LogicalKeyboardKey.select,
//       LogicalKeyboardKey.enter
//     ].contains(key)) {
//       if (networkHasFocus) {
//         _navigateNetworks(key);
//       } else if (genreHasFocus) {
//         _navigateGenres(key);
//       } else if (listHasFocus) {
//         _navigateList(key);
//       }
//       return KeyEventResult.handled;
//     }

//     return KeyEventResult.ignored;
//   }

//   // ===== FIX START: Fast navigation hang/crash ke liye updated function =====
//   void _navigateList(LogicalKeyboardKey key) {
//     // Agar navigation pehle se locked hai, to function se bahar nikal jao
//     if (_isNavigationLocked) return;

//     if (_focusedItemIndex == -1 || _itemFocusNodes.isEmpty) return;

//     // Navigation ko turant lock karo
//     setState(() {
//       _isNavigationLocked = true;
//     });

//     // Ek chota Timer set karo jo lock ko thodi der baad khol dega
//     // Yeh 300ms ka cooldown period dega
//     _navigationLockTimer = Timer(const Duration(milliseconds: 700), () {
//       if (mounted) {
//         setState(() {
//           _isNavigationLocked = false;
//         });
//       }
//     });

//     int newIndex = _focusedItemIndex;
    
//     if (key == LogicalKeyboardKey.arrowUp) {
//       setState(() => _lastNavigationDirection = 'vertical');
//       if (_genreFocusNodes.isNotEmpty) {
//         _genreFocusNodes[_focusedGenreIndex].requestFocus();
//       } else {
//         _searchButtonFocusNode.requestFocus();
//       }
//       setState(() => _focusedItemIndex = -1);
      
//       // Lock aur timer ko cancel kar do kyunki hum list se bahar ja rahe hain
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();
//       return;

//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       // arrowDown par kuch nahi karna hai, isliye lock hata do
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();
//       return;

//     } else if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newIndex > 0) {
//         newIndex--;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       final currentList =
//           _isSearching ? _searchResults : _filteredWebSeriesList;
//       if (newIndex + 1 < currentList.length) {
//         newIndex++;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
      
//       // Enter/Select par cooldown nahi chahiye, isliye lock turant hata do
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();

//       final currentList =
//           _isSearching ? _searchResults : _filteredWebSeriesList;
//       _navigateToWebSeriesDetails(currentList[_focusedItemIndex], _focusedItemIndex);
//       return;
//     }

//     if (newIndex != _focusedItemIndex) {
//       setState(() => _focusedItemIndex = newIndex);
//       _itemFocusNodes[newIndex].requestFocus();
//     } else {
//       // Agar index nahi badla (e.g., pehle item par left dabaya), to lock hata do
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();
//     }
//   }
//   // ===== FIX END =====

//   void _navigateNetworks(LogicalKeyboardKey key) {
//     int newIndex = _focusedNetworkIndex;
//     if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newIndex > 0) {
//         newIndex--;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       if (newIndex < _uniqueNetworks.length - 1) {
//         newIndex++;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       setState(() => _lastNavigationDirection = 'vertical');
//       _updateSelectedNetwork();
//       _searchButtonFocusNode.requestFocus();
//       return;
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       _updateSelectedNetwork();
//       return;
//     }
//     if (newIndex != _focusedNetworkIndex) {
//       setState(() => _focusedNetworkIndex = newIndex);
//       _networkFocusNodes[newIndex].requestFocus();
//       _updateAndScrollToFocus(
//           _networkFocusNodes, newIndex, _networkScrollController, 160);
//     }
//   }

//   void _navigateGenres(LogicalKeyboardKey key) {
//     int newIndex = _focusedGenreIndex;
//     if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newIndex > 0) {
//         newIndex--;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       } else {
//         _searchButtonFocusNode.requestFocus();
//         return;
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       if (newIndex < _uniqueGenres.length - 1) {
//         newIndex++;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.arrowUp) {
//       if (_networkFocusNodes.isNotEmpty) {
//         setState(() => _lastNavigationDirection = 'vertical');
//         _networkFocusNodes[_focusedNetworkIndex].requestFocus();
//       }
//       return;
//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       setState(() => _lastNavigationDirection = 'vertical');
//       _updateSelectedGenre();
//       if (_itemFocusNodes.isNotEmpty) {
//         setState(() => _focusedItemIndex = 0);
//         // _itemFocusNodes[0].requestFocus();
//         _focusFirstListItemWithScroll();
//       }
//       return;
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       _updateSelectedGenre();
//       return;
//     }
//     if (newIndex != _focusedGenreIndex) {
//       setState(() => _focusedGenreIndex = newIndex);
//       _genreFocusNodes[newIndex].requestFocus();
//       _updateAndScrollToFocus(
//           _genreFocusNodes, newIndex, _genreScrollController, 160);
//     }
//   }

//   KeyEventResult _navigateKeyboard(LogicalKeyboardKey key) {
//     int newRow = _focusedKeyRow;
//     int newCol = _focusedKeyCol;
//     if (key == LogicalKeyboardKey.arrowUp) {
//       if (newRow > 0) {
//         newRow--;
//         newCol = math.min(newCol, _keyboardLayout[newRow].length - 1);
//       }
//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       if (newRow < _keyboardLayout.length - 1) {
//         newRow++;
//         newCol = math.min(newCol, _keyboardLayout[newRow].length - 1);
//       }
//     } else if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newCol > 0) newCol--;
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       if (newCol < _keyboardLayout[newRow].length - 1) newCol++;
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       final keyValue = _keyboardLayout[newRow][newCol];
//       _onKeyPressed(keyValue);
//       return KeyEventResult.handled;
//     }

//     if (newRow != _focusedKeyRow || newCol != _focusedKeyCol) {
//       setState(() {
//         _focusedKeyRow = newRow;
//         _focusedKeyCol = newCol;
//       });
//       final focusIndex = _getFocusNodeIndexForKey(newRow, newCol);
//       if (focusIndex >= 0 && focusIndex < _keyboardFocusNodes.length) {
//         _keyboardFocusNodes[focusIndex].requestFocus();
//       }
//     }
//     return KeyEventResult.handled;
//   }

//   //=================================================
//   // SECTION 2.3: STATE MANAGEMENT & UI LOGIC
//   //=================================================

//   void _applyFilters() {
//     if (_isSearching) {
//       setState(() {
//         _isSearching = false;
//         _searchText = '';
//         _searchResults.clear();
//       });
//     }
//     _filteredWebSeriesList = _webSeriesList.where((series) {
//       final bool networkMatch = _selectedNetworkName.isEmpty ||
//           series.networks.any((n) => n.name == _selectedNetworkName);
//       final bool genreMatch = _selectedGenre == 'All' ||
//           (series.genres
//                   ?.split(',')
//                   .map((e) => e.trim())
//                   .contains(_selectedGenre) ??
//               false);
//       return networkMatch && genreMatch;
//     }).toList();
    
//     // CHANGE 5: Yahan se shuffle ko hata diya gaya hai.
//     // _filteredWebSeriesList.shuffle(); 
    
//     _rebuildItemFocusNodes();
//     _focusedItemIndex = -1;
//   }

//   void _updateSelectedNetwork() {
//     setState(() {
//       _selectedNetworkName = _uniqueNetworks[_focusedNetworkIndex];
//       _updateSelectedNetworkData();
//       _updateGenresForSelectedNetwork();
//       _rebuildGenreFocusNodes();
//       _focusedGenreIndex = 0;
//       _selectedGenre = 'All';
//       _applyFilters();
//     });
//   }

//   void _updateSelectedGenre() {
//     setState(() {
//       _selectedGenre = _uniqueGenres[_focusedGenreIndex];
//       _applyFilters();
//     });
//   }

//   void _updateSelectedNetworkData() {
//     final selectedNetwork = _apiNetworks.firstWhere(
//         (n) => n.name == _selectedNetworkName,
//         orElse: () => ApiNetworkModel(id: -1, name: '', networksOrder: 9999));
//     final webSeriesSliders = selectedNetwork.sliders
//         .where((s) => s.sliderFor == 'tvshows')
//         .toList();
//     setState(() {
//       _selectedNetworkLogo = selectedNetwork.logo;
//       _currentWebSeriesSliders = webSeriesSliders;
//       _currentSliderIndex = 0;
//       if (webSeriesSliders.isNotEmpty) {
//         _currentBackgroundUrl = webSeriesSliders.first.banner;
//       } else {
//         _currentBackgroundUrl = selectedNetwork.logo;
//       }
//     });

//     if (_sliderPageController.hasClients && _currentWebSeriesSliders.isNotEmpty) {
//       _sliderPageController.jumpToPage(0);
//     }
//   }

//   void _updateGenresForSelectedNetwork() {
//     if (_selectedNetworkName.isEmpty || _webSeriesList.isEmpty) return;
//     final networkSpecificSeries = _webSeriesList
//         .where((series) => series.networks.any((n) => n.name == _selectedNetworkName))
//         .toList();
//     final Set<String> genres = {'All'};
//     for (final series in networkSpecificSeries) {
//       if (series.genres != null && series.genres!.isNotEmpty) {
//         final genreList = series.genres!
//             .split(',')
//             .map((g) => g.trim())
//             .where((g) => g.isNotEmpty);
//         genres.addAll(genreList.where((g) =>
//             g.toLowerCase() != 'web series' && g.toLowerCase() != 'webseries'));
//       }
//     }
//     final sortedGenres = genres.toList()..sort();
//     if (sortedGenres.contains('All')) {
//       sortedGenres.remove('All');
//       sortedGenres.insert(0, 'All');
//     }
//     _uniqueGenres = sortedGenres;
//   }

//   void _performSearch(String searchTerm) {
//     _debounce?.cancel();
//     if (searchTerm.trim().isEmpty) {
//       setState(() {
//         _isSearching = false;
//         _isSearchLoading = false;
//         _searchResults.clear();
//         _rebuildItemFocusNodes();
//       });
//       return;
//     }
//     _debounce = Timer(const Duration(milliseconds: 400), () async {
//       if (!mounted) return;
//       setState(() {
//         _isSearchLoading = true;
//         _isSearching = true;
//         _searchResults.clear();
//       });
//       final results = await _performSearchInNetwork(searchTerm);
//       if (!mounted) return;
//       setState(() {
//         _searchResults = results;
//         _isSearchLoading = false;
//         _rebuildItemFocusNodes();
//       });
//     });
//   }

//   Future<List<WebSeriesModel>> _performSearchInNetwork(String searchTerm) async {
//     if (searchTerm.isEmpty || _selectedNetworkName.isEmpty) {
//       return [];
//     }
//     final networkSeries = _webSeriesList
//         .where((series) => series.networks.any((n) => n.name == _selectedNetworkName))
//         .toList();
//     return networkSeries
//         .where(
//             (series) => series.name.toLowerCase().contains(searchTerm.toLowerCase()))
//         .toList();
//   }

//   void _onKeyPressed(String value) {
//     setState(() {
//       if (value == 'OK') {
//         _showKeyboard = false;
//         if (_itemFocusNodes.isNotEmpty) {
//           _itemFocusNodes.first.requestFocus();
//         } else {
//           _searchButtonFocusNode.requestFocus();
//         }
//         return;
//       }
//       if (value == 'DEL') {
//         if (_searchText.isNotEmpty) {
//           _searchText = _searchText.substring(0, _searchText.length - 1);
//         }
//       } else if (value == ' ') {
//         _searchText += ' ';
//       } else {
//         _searchText += value;
//       }
//       _performSearch(_searchText);
//     });
//   }

//   Future<void> _navigateToWebSeriesDetails(
//       WebSeriesModel webSeries, int index) async {
//     if (_isVideoLoading) return;
//     setState(() => _isVideoLoading = true);
//     try {
//       int? currentUserId = SessionManager.userId;
//       await HistoryService.updateUserHistory(
//         userId: currentUserId!,
//         contentType: 2,
//         eventId: webSeries.id,
//         eventTitle: webSeries.name,
//         url: '',
//         categoryId: 0,
//       );
//     } catch (e) {
//       // History update failure should not block navigation
//     }
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => WebSeriesDetailsPage(
//           id: webSeries.id,
//           banner: webSeries.banner ?? webSeries.poster ?? '',
//           poster: webSeries.poster ?? webSeries.banner ?? '',
//           logo: webSeries.poster ?? webSeries.banner ?? '',
//           name: webSeries.name,
//           updatedAt: webSeries.updatedAt,
//         ),
//       ),
//     );
//     if (mounted) {
//       setState(() {
//         _isVideoLoading = false;
//         _focusedItemIndex = index;
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted &&
//             _focusedItemIndex >= 0 &&
//             _focusedItemIndex < _itemFocusNodes.length) {
//           _itemFocusNodes[_focusedItemIndex].requestFocus();
//         }
//       });
//     }
//   }


//   //=================================================
//   // SECTION 2.4: INITIALIZATION AND CLEANUP
//   //=================================================

//   void _initializeAnimations() {
//     _fadeController =
//         AnimationController(duration: AnimationTiming.medium, vsync: this);
//     _fadeAnimation =
//         CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
//   }

//   void _startAnimations() {
//     _fadeController.forward();
//   }

//   void _initializeFocusNodes() {
//     _disposeFocusNodes(_networkFocusNodes);
//     _networkFocusNodes = List.generate(
//         _uniqueNetworks.length, (index) => FocusNode(debugLabel: 'Network-$index'));
//     _rebuildGenreFocusNodes();
//     _rebuildItemFocusNodes();
//     _rebuildKeyboardFocusNodes();
//   }

//   void _rebuildGenreFocusNodes() {
//     _disposeFocusNodes(_genreFocusNodes);
//     _genreFocusNodes = List.generate(
//         _uniqueGenres.length, (index) => FocusNode(debugLabel: 'Genre-$index'));
//   }

//   void _rebuildItemFocusNodes() {
//     _disposeFocusNodes(_itemFocusNodes);
//     final currentList = _isSearching ? _searchResults : _filteredWebSeriesList;
//     _itemFocusNodes = List.generate(
//         currentList.length, (index) => FocusNode(debugLabel: 'Item-$index'));
//   }

//   void _rebuildKeyboardFocusNodes() {
//     _disposeFocusNodes(_keyboardFocusNodes);
//     int totalKeys =
//         _keyboardLayout.fold(0, (prev, row) => prev + row.length);
//     _keyboardFocusNodes =
//         List.generate(totalKeys, (index) => FocusNode(debugLabel: 'Key-$index'));
//   }

//   int _getFocusNodeIndexForKey(int row, int col) {
//     int index = 0;
//     for (int r = 0; r < row; r++) {
//       index += _keyboardLayout[r].length;
//     }
//     return index + col;
//   }

//   void _disposeFocusNodes(List<FocusNode> nodes) {
//     for (var node in nodes) {
//       node.dispose();
//     }
//   }

//   void _updateAndScrollToFocus(List<FocusNode> nodes, int index,
//       ScrollController controller, double itemWidth) {
//     if (!mounted ||
//         index < 0 ||
//         index >= nodes.length ||
//         !controller.hasClients) return;
//     double screenWidth = MediaQuery.of(context).size.width;
//     double scrollPosition = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
//     controller.animateTo(
//       scrollPosition.clamp(0.0, controller.position.maxScrollExtent),
//       duration: AnimationTiming.fast,
//       curve: Curves.easeInOut,
//     );
//   }

//   //=================================================
//   // SECTION 2.5: WIDGET BUILDER METHODS
//   //=================================================

//   Widget _buildPageContent() {
//     return Padding(
//       padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.02, vertical: screenhgt * 0.02),

//       child: Column(
//         children: [
//           _buildTopFilterBar(),
//           Expanded(
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: _buildContentBody(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContentBody() {
//     return Column(
//       children: [
//         SizedBox(
//           height: screenhgt * 0.5,
//           child: _showKeyboard ? _buildSearchUI() : const SizedBox.shrink(),
//         ),
//         _buildSliderIndicators(),
//         _buildGenreAndSearchButtons(),
//         SizedBox(height: screenhgt * 0.02),
//         _buildWebSeriesList(),
//       ],
//     );
//   }
  
//   Widget _buildBackgroundOrSlider() {
//     if (_currentWebSeriesSliders.isNotEmpty) {
//       return WebSeriesBannerSlider(
//         sliders: _currentWebSeriesSliders,
//         controller: _sliderPageController,
//         onPageChanged: (index) {
//           if (mounted) {
//             setState(() {
//               _currentSliderIndex = index;
//             });
//           }
//         },
//       );
//     } else {
//       return _buildDynamicBackground();
//     }
//   }

//   Widget _buildDynamicBackground() {
//     return AnimatedSwitcher(
//       duration: AnimationTiming.medium,
//       child: _currentBackgroundUrl != null && _currentBackgroundUrl!.isNotEmpty
//           ? Container(
//               key: ValueKey<String>(_currentBackgroundUrl!),
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   // CHANGE 6: CachedNetworkImageProvider ko NetworkImage se badla gaya.
//                   image: NetworkImage(_currentBackgroundUrl!),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.primaryDark.withOpacity(0.2),
//                       ProfessionalColors.primaryDark.withOpacity(0.4),
//                       ProfessionalColors.primaryDark.withOpacity(0.6),
//                       ProfessionalColors.primaryDark.withOpacity(0.9),
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     stops: const [0.0, 0.5, 0.7, 0.9],
//                   ),
//                 ),
//               ),
//             )
//           : Container(
//               key: const ValueKey<String>('no_bg'),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     ProfessionalColors.primaryDark,
//                     ProfessionalColors.surfaceDark,
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _buildTopFilterBar() {
//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: EdgeInsets.only(
//             top: MediaQuery.of(context).padding.top +5,
//             bottom: 5,
//             left: screenwdt * 0.015,
//             right: 0,
//           ),
//           decoration: BoxDecoration(
//             // gradient: LinearGradient(
//             //   colors: [
//             //     Colors.black.withOpacity(0.3),
//             //     Colors.black.withOpacity(0.1),
//             //   ],
//             //   begin: Alignment.topCenter,
//             //   end: Alignment.bottomCenter,
//             // ),
//             color: Colors.transparent,
//             border: Border(
//               bottom: BorderSide(
//                 color: Colors.white.withOpacity(0.1),
//                 width: 1,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               Expanded(child: _buildNetworkFilter()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNetworkFilter() {
//     return SizedBox(
//       height: 30,
//       child: Center(
//         child: ListView.builder(
//           controller: _networkScrollController,
//           scrollDirection: Axis.horizontal,
//           itemCount: _uniqueNetworks.length,
//           itemBuilder: (context, index) {
//             final networkName = _uniqueNetworks[index];
//             final focusNode = _networkFocusNodes[index];
//             final isSelected = _selectedNetworkName == networkName;
            
//             return Focus(
//               focusNode: focusNode,
//               onFocusChange: (hasFocus) {
//                 if (hasFocus) {
//                   setState(() => _focusedNetworkIndex = index);
//                 }
//               },
//               child: _buildGlassEffectButton(
//                 focusNode: focusNode,
//                 isSelected: isSelected,
//                 focusColor: _focusColors[index % _focusColors.length],
//                 onTap: () {
//                   setState(() => _focusedNetworkIndex = index);
//                   focusNode.requestFocus();
//                   _updateSelectedNetwork();
//                 },
//                 child: Text(
//                   networkName.toUpperCase(),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: focusNode.hasFocus || isSelected
//                         ? FontWeight.bold
//                         : FontWeight.w500,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildGenreAndSearchButtons() {
//     if (_uniqueGenres.length <= 1 && !_isSearching) {
//       return const SizedBox.shrink();
//     }
//     if (_isGenreLoading) {
//       return SizedBox(
//         height: 30,
//         child: const Center(
//           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//         ),
//       );
//     }

//     return SizedBox(
//       height: 30,
//       child: Center(
//         child: ListView.builder(
//           controller: _genreScrollController,
//           scrollDirection: Axis.horizontal,
//           itemCount: _uniqueGenres.length + 1, // +1 for Search button
//           padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.015),
//           itemBuilder: (context, index) {
//             if (index == 0) { // Search Button
//               return Focus(
//                 focusNode: _searchButtonFocusNode,
//                 child: _buildGlassEffectButton(
//                   focusNode: _searchButtonFocusNode,
//                   isSelected: _isSearching,
//                   focusColor: ProfessionalColors.accentOrange,
//                   onTap: () {
//                     _searchButtonFocusNode.requestFocus();
//                     setState(() {
//                       _showKeyboard = true;
//                       _focusedKeyRow = 0;
//                       _focusedKeyCol = 0;
//                     });
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       if (mounted && _keyboardFocusNodes.isNotEmpty) {
//                         _keyboardFocusNodes[0].requestFocus();
//                       }
//                     });
//                   },
//                   child:  Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.search, color: Colors.white),
//                       SizedBox(width: 8),
//                       Text(
//                         ("Search").toUpperCase(),
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }

//             // Genre Buttons
//             final genreIndex = index - 1;
//             final genre = _uniqueGenres[genreIndex];
//             final focusNode = _genreFocusNodes[genreIndex];
//             final isSelected = !_isSearching && _selectedGenre == genre;

//             return Focus(
//               focusNode: focusNode,
//               child: _buildGlassEffectButton(
//                 focusNode: focusNode,
//                 isSelected: isSelected,
//                 focusColor: _focusColors[genreIndex % _focusColors.length],
//                 onTap: () {
//                   setState(() => _focusedGenreIndex = genreIndex);
//                   focusNode.requestFocus();
//                   _updateSelectedGenre();
//                 },
//                 child: Text(
//                   genre.toUpperCase(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildWebSeriesList() {
//     final currentList = _isSearching ? _searchResults : _filteredWebSeriesList;

//     if (_isSearchLoading) {
//       return const Expanded(child: Center(child: CircularProgressIndicator()));
//     }

//     if (currentList.isEmpty) {
//       return Expanded(
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(15),
//             margin: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: ProfessionalColors.surfaceDark.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.white.withOpacity(0.1)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.tv_off_rounded,
//                   size: 25,
//                   color: ProfessionalColors.textSecondary,
//                 ),
//                 // const SizedBox(height: 10),
//                 Text(
//                   _isSearching && _searchText.isNotEmpty
//                       ? "No results found for '$_searchText'"
//                       : 'No series available for this filter.',
//                   style: const TextStyle(
//                     color: ProfessionalColors.textSecondary,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.only(top: 1.0),
//         child: ListView.builder(
//           controller: _listScrollController,
//           clipBehavior: Clip.none,
//           scrollDirection: Axis.horizontal,
//           padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.015),
//           itemCount: currentList.length,
//           itemBuilder: (context, index) {
//             return Container(
//               width: bannerwdt * 1.2,
//               margin: const EdgeInsets.only(right: 12.0),
//               child: InkWell(
//                 focusNode: _itemFocusNodes[index],
//                 onTap: () => _navigateToWebSeriesDetails(currentList[index], index),
//                 onFocusChange: (hasFocus) {
//                   if (hasFocus) {
//                     setState(() => _focusedItemIndex = index);
//                     _updateAndScrollToFocus(
//                         _itemFocusNodes, index, _listScrollController, (bannerwdt * 1.2) + 12);
//                   }
//                 },
//                 child: OptimizedWebSeriesCard(
//                   webSeries: currentList[index],
//                   isFocused: _focusedItemIndex == index,
//                   onTap: () =>
//                       _navigateToWebSeriesDetails(currentList[index], index),
//                   cardHeight: bannerhgt * 1.2,
//                   networkLogo: _selectedNetworkLogo,
//                   uniqueIndex: index,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchUI() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           flex: 4,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ShaderMask(
//                   blendMode: BlendMode.srcIn,
//                   shaderCallback: (bounds) => const LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple,
//                     ],
//                   ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
//                   child: const Text(
//                     "Search Web Series",
//                     style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Container(
//                   width: double.infinity,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: ProfessionalColors.accentPurple, width: 2),
//                   ),
//                   child: Text(
//                     _searchText.isEmpty ? 'Start typing...' : _searchText,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: _searchText.isEmpty ? Colors.white54 : Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Expanded(
//           flex: 6,
//           child: _buildQwertyKeyboard(),
//         ),
//       ],
//     );
//   }

//   Widget _buildQwertyKeyboard() {
//     return Container(
//       color: Colors.transparent,
//       padding: const EdgeInsets.all(5),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           for (int rowIndex = 0; rowIndex < _keyboardLayout.length; rowIndex++)
//             _buildKeyboardRow(_keyboardLayout[rowIndex], rowIndex),
//         ],
//       ),
//     );
//   }

//   Widget _buildKeyboardRow(List<String> keys, int rowIndex) {
//     int startIndex = 0;
//     for (int i = 0; i < rowIndex; i++) {
//       startIndex += _keyboardLayout[i].length;
//     }

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: keys.asMap().entries.map((entry) {
//         final colIndex = entry.key;
//         final key = entry.value;
//         final focusIndex = startIndex + colIndex;
//         final isFocused = _focusedKeyRow == rowIndex && _focusedKeyCol == colIndex;
//         final screenWidth = MediaQuery.of(context).size.width;
//         final screenHeight = MediaQuery.of(context).size.height;
//         double width;
//         if (key == ' ') {
//           width = screenWidth * 0.315;
//         } else if (key == 'OK' || key == 'DEL') {
//           width = screenWidth * 0.09;
//         } else {
//           width = screenWidth * 0.045;
//         }

//         return Container(
//           width: width,
//           height: screenHeight * 0.08,
//           margin: const EdgeInsets.all(4.0),
//           child: Focus(
//             focusNode: _keyboardFocusNodes[focusIndex],
//             onFocusChange: (hasFocus) {
//               if (hasFocus) {
//                 setState(() {
//                   _focusedKeyRow = rowIndex;
//                   _focusedKeyCol = colIndex;
//                 });
//               }
//             },
//             child: ElevatedButton(
//               onPressed: () => _onKeyPressed(key),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isFocused
//                     ? ProfessionalColors.accentPurple
//                     : Colors.white.withOpacity(0.1),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                   side: isFocused
//                       ? const BorderSide(color: Colors.white, width: 3)
//                       : BorderSide.none,
//                 ),
//                 padding: EdgeInsets.zero,
//               ),
//               child: Text(
//                 key,
//                 style: TextStyle(
//                   fontSize: 22.0,
//                   fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildSliderIndicators() {
//     if (_currentWebSeriesSliders.length <= 1) {
//       return const SizedBox.shrink();
//     }
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(_currentWebSeriesSliders.length, (index) {
//         bool isActive = _currentSliderIndex == index;
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
//           height: 8.0,
//           width: isActive ? 24.0 : 8.0,
//           decoration: BoxDecoration(
//             color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
//             borderRadius: BorderRadius.circular(12),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildGlassEffectButton({
//     required FocusNode focusNode,
//     required VoidCallback onTap,
//     required bool isSelected,
//     required Color focusColor,
//     required Widget child,
//   }) {
//     bool hasFocus = focusNode.hasFocus;
//     bool isHighlighted = hasFocus || isSelected;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(right: 15),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(30),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
//               decoration: BoxDecoration(
//                 color: hasFocus
//                     ? focusColor
//                     : isSelected
//                         ? focusColor.withOpacity(0.5)
//                         : Colors.white.withOpacity(0.08),
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.black.withOpacity(0.25),
//                     Colors.white.withOpacity(0.1),
//                   ],
//                   stops: const [0.0, 0.8],
//                 ),
//                 borderRadius: BorderRadius.circular(30),
//                 border: Border.all(
//                   color: hasFocus ? Colors.white : Colors.white.withOpacity(0.3),
//                   width: hasFocus ? 3 : 2,
//                 ),
//                 boxShadow: isHighlighted
//                     ? [
//                         BoxShadow(
//                           color: focusColor.withOpacity(0.8),
//                           blurRadius: 15,
//                           spreadRadius: 3,
//                         )
//                       ]
//                     : null,
//               ),
//               child: child,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.all(40),
//         padding: const EdgeInsets.all(32),
//         decoration: BoxDecoration(
//           color: ProfessionalColors.surfaceDark.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(color: Colors.white.withOpacity(0.1)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.red.withOpacity(0.1),
//               ),
//               child: const Icon(
//                 Icons.cloud_off_rounded,
//                 color: Colors.red,
//                 size: 60,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               _errorMessage ?? 'Something went wrong.',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: ProfessionalColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               focusNode: FocusNode(), // An unfocusable node
//               onPressed: () => _fetchDataForPage(forceRefresh: true),
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Try Again'),
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 backgroundColor: ProfessionalColors.accentBlue,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// //==============================================================================
// // SECTION 3: REUSABLE UI COMPONENTS
// // Yeh chhote, reusable widgets hain jo page par istemal hote hain.
// //==============================================================================

// class OptimizedWebSeriesCard extends StatelessWidget {
//   final WebSeriesModel webSeries;
//   final bool isFocused;
//   final VoidCallback onTap;
//   final double cardHeight;
//   final String? networkLogo;
//   final int uniqueIndex;

//   const OptimizedWebSeriesCard({
//     Key? key,
//     required this.webSeries,
//     required this.isFocused,
//     required this.onTap,
//     required this.cardHeight,
//     this.networkLogo,
//     required this.uniqueIndex,
//   }) : super(key: key);

//   final List<Color> _focusColors = const [
//     ProfessionalColors.accentBlue,
//     ProfessionalColors.accentPurple,
//     ProfessionalColors.accentPink,
//     ProfessionalColors.accentOrange,
//     ProfessionalColors.accentRed
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final focusColor = _focusColors[uniqueIndex % _focusColors.length];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         SizedBox(
//           height: cardHeight,
//           child: AnimatedContainer(
//             duration: AnimationTiming.fast,
//             transform: isFocused
//                 ? (Matrix4.identity()..scale(1.05))
//                 : Matrix4.identity(),
//             transformAlignment: Alignment.center,
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8.0),
//                 border: isFocused
//                     ? Border.all(color: focusColor, width: 3)
//                     : Border.all(color: Colors.transparent, width: 3),
//                 boxShadow: isFocused
//                     ? [
//                         BoxShadow(
//                             color: focusColor.withOpacity(0.5),
//                             blurRadius: 12,
//                             spreadRadius: 1)
//                       ]
//                     : []),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(6.0),
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   _buildWebSeriesImage(),
//                   if (isFocused)
//                     Positioned(
//                         left: 5,
//                         top: 5,
//                         child: Container(
//                             color: Colors.black.withOpacity(0.4),
//                             child: Icon(Icons.play_circle_filled_outlined,
//                                 color: focusColor, size: 40))),
//                   if (networkLogo != null && networkLogo!.isNotEmpty)
//                     Positioned(
//                         top: 5,
//                         right: 5,
//                         child: CircleAvatar(
//                             radius: 12,
//                             backgroundImage: NetworkImage(networkLogo!),
//                             backgroundColor: Colors.black54)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 8.0, left: 2.0, right: 2.0),
//           child: Text(webSeries.name,
//               style: TextStyle(
//                   color: isFocused
//                       ? focusColor
//                       : ProfessionalColors.textSecondary,
//                   fontSize: 14,
//                   fontWeight: isFocused ? FontWeight.bold : FontWeight.normal),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis),
//         ),
//       ],
//     );
//   }

//   // CHANGE 7: CachedNetworkImage ko Image.network se badal diya gaya hai.
//   Widget _buildWebSeriesImage() {
//     final imageUrl = webSeries.banner;
    
//     return imageUrl != null && imageUrl.isNotEmpty
//         ? Image.network(
//             imageUrl,
//             fit: BoxFit.cover,
//             // `loadingBuilder` ka istemal placeholder dikhane ke liye kiya gaya hai.
//             loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//               if (loadingProgress == null) return child;
//               return _buildImagePlaceholder();
//             },
//             // `errorBuilder` ka istemal error hone par placeholder dikhane ke liye kiya gaya hai.
//             errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
//               return _buildImagePlaceholder();
//             },
//           )
//         : _buildImagePlaceholder();
//   }
  
//   Widget _buildImagePlaceholder() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             ProfessionalColors.accentGreen,
//             ProfessionalColors.accentBlue,
//           ],
//         ),
//       ),
//       child: const Icon(
//         Icons.broken_image,
//         color: Colors.white,
//         size: 24,
//       ),
//     );
//   }
// }

// class WebSeriesBannerSlider extends StatefulWidget {
//   final List<SliderModel> sliders;
//   final ValueChanged<int> onPageChanged;
//   final PageController controller;

//   const WebSeriesBannerSlider({
//     Key? key,
//     required this.sliders,
//     required this.onPageChanged,
//     required this.controller,
//   }) : super(key: key);

//   @override
//   _WebSeriesBannerSliderState createState() => _WebSeriesBannerSliderState();
// }

// class _WebSeriesBannerSliderState extends State<WebSeriesBannerSlider> {
//   Timer? _timer;
//   double _opacity = 1.0;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.sliders.length > 1) {
//       _startTimer();
//     }
//   }

//   @override
//   void didUpdateWidget(WebSeriesBannerSlider oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.sliders.length != widget.sliders.length) {
//       _timer?.cancel();
//       if (widget.sliders.length > 1) {
//         _startTimer();
//       }
//     }
//   }

//   void _startTimer() {
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
//       if (!mounted || !widget.controller.hasClients || widget.sliders.length <= 1) return;

//       int currentPage = widget.controller.page?.round() ?? 0;
//       int nextPage = (currentPage + 1) % widget.sliders.length;

//       widget.controller.animateToPage(
//         nextPage,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.sliders.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return AnimatedOpacity(
//       opacity: _opacity,
//       duration: const Duration(milliseconds: 400),
//       child: PageView.builder(
//         controller: widget.controller,
//         itemCount: widget.sliders.length,
//         onPageChanged: widget.onPageChanged,
//         itemBuilder: (context, index) {
//           final slider = widget.sliders[index];
//           return Stack(
//             fit: StackFit.expand,
//             children: [
//               // CHANGE 8: Yahan bhi CachedNetworkImage ko Image.network se badal diya gaya hai.
//               Image.network(
//                 slider.banner,
//                 fit: BoxFit.cover,
//                 loadingBuilder: (context, child, progress) => 
//                     progress == null ? child : Container(color: ProfessionalColors.surfaceDark),
//                 errorBuilder: (context, error, stackTrace) => 
//                     Container(color: ProfessionalColors.surfaceDark),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.primaryDark.withOpacity(0.2),
//                       ProfessionalColors.primaryDark.withOpacity(0.4),
//                       ProfessionalColors.primaryDark.withOpacity(0.6),
//                       ProfessionalColors.primaryDark.withOpacity(0.9),
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     stops: const [0.0, 0.5, 0.7, 0.9],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }






// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';
// // CHANGE 1: CachedNetworkImage import ko hata diya gaya hai.
// // import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:math' as math;
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_final_details_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // NOTE: Apne project ke anusaar neeche di gayi import lines ko aavashyakta anusaar badlein.
// // Make sure to change the import lines below according to your project structure.

// // REFACTOR: Webseries details page ko TvShow details page se badla
// // import 'package:mobi_tv_entertainment/components/home_screen_pages/tvshows_screen/tvshow_details_page.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';

// //==============================================================================
// // SECTION 1: COMMON CLASSES AND MODELS
// // Yeh classes data ko handle karne aur consistent UI ke liye hain.
// //==============================================================================

// class ProfessionalColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentGreen = Color.fromARGB(255, 59, 246, 68);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentPink = Color(0xFFEC4899);
//   static const accentOrange = Color(0xFFF59E0B);
//   static const accentRed = Color(0xFFEF4444);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);

//   static List<Color> gradientColors = [accentBlue, accentPurple, accentPink];
// }

// class AnimationTiming {
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
// }

// class NetworkModel {
//   final int id;
//   final String name;
//   final String? logo;
//   NetworkModel({required this.id, required this.name, this.logo});
//   factory NetworkModel.fromJson(Map<String, dynamic> json) {
//     return NetworkModel(
//         id: json['id'] ?? 0, name: json['name'] ?? '', logo: json['logo']);
//   }
// }

// // REFACTOR: WebSeriesModel -> TvShowModel
// class TvShowModel {
//   final int id;
//   final String name;
//   final String updatedAt;
//   final String? poster;
//   final String? banner;
//   final String? genres;
//   final int seriesOrder; // REFACTOR: Iska naam 'seriesOrder' hi rakha hai API consistency ke liye
//   final List<NetworkModel> networks;

//   TvShowModel({
//     required this.id,
//     required this.name,
//     required this.updatedAt,
//     this.poster,
//     this.banner,
//     this.genres,
//     required this.seriesOrder,
//     this.networks = const [],
//   });

//   factory TvShowModel.fromJson(Map<String, dynamic> json) {
//     var networks = (json['networks'] as List? ?? [])
//         .map((item) => NetworkModel.fromJson(item as Map<String, dynamic>))
//         .toList();
//     return TvShowModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       poster: json['poster'],
//       banner: json['banner'],
//       genres: json['genres'],
//       seriesOrder: json['series_order'] ?? 9999,
//       networks: networks,
//     );
//   }
// }

// class SliderModel {
//   final int id;
//   final String title;
//   final String banner;
//   final String sliderFor;

//   SliderModel(
//       {required this.id,
//       required this.title,
//       required this.banner,
//       required this.sliderFor});

//   factory SliderModel.fromJson(Map<String, dynamic> json) {
//     return SliderModel(
//       id: json['id'] ?? 0,
//       title: json['title'] ?? '',
//       banner: json['banner'] ?? '',
//       sliderFor: json['slider_for'] ?? '',
//     );
//   }
// }

// class ApiNetworkModel {
//   final int id;
//   final String name;
//   final String? logo;
//   final int networksOrder;
//   final List<SliderModel> sliders;

//   ApiNetworkModel({
//     required this.id,
//     required this.name,
//     this.logo,
//     required this.networksOrder,
//     this.sliders = const [],
//   });

//   factory ApiNetworkModel.fromJson(Map<String, dynamic> json) {
//     var sliders = (json['sliders'] as List? ?? [])
//         .map((item) => SliderModel.fromJson(item as Map<String, dynamic>))
//         .toList();
//     return ApiNetworkModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       logo: json['logo'],
//       networksOrder: json['networks_order'] ?? 9999,
//       sliders: sliders,
//     );
//   }
// }

// // REFACTOR: ProfessionalWebSeriesLoadingIndicator -> ProfessionalTvShowLoadingIndicator
// class ProfessionalTvShowLoadingIndicator extends StatelessWidget {
//   final String message;
//   const ProfessionalTvShowLoadingIndicator({Key? key, required this.message})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: ProfessionalColors.gradientColors,
//               ),
//             ),
//             child: const CircularProgressIndicator(
//               color: Colors.white,
//               strokeWidth: 3,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             message,
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


// //==============================================================================
// // SECTION 2: MAIN PAGE WIDGET AND STATE
// // Yeh page ka main structure aur logic hai.
// //==============================================================================

// class TvShowSliderScreen extends StatefulWidget {
//   // REFACTOR: Title ko 'All Tv Shows' kiya
//   final String title;
//   const TvShowSliderScreen({Key? key, this.title = 'All TV Shows'})
//       : super(key: key);

//   @override
//   _TvShowSliderScreenState createState() =>
//       _TvShowSliderScreenState();
// }

// class _TvShowSliderScreenState
//     extends State<TvShowSliderScreen>
//     with SingleTickerProviderStateMixin {
//   // REFACTOR: _webSeriesList -> _tvShowList
//   List<TvShowModel> _tvShowList = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   // CHANGE 2: Cache se sambandhit variables hata diye gaye hain.
//   // REFACTOR: Cache keys ko conflict se bachne ke liye badla
//   // static const String _cacheKeyTvShows = 'grid_page_cached_tv_shows';
//   // static const String _cacheKeyTvShowsTimestamp = 'grid_page_cached_tv_shows_timestamp';
//   // static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour cache

//   // Focus and Scroll Controllers
//   List<FocusNode> _itemFocusNodes = [];
//   List<FocusNode> _networkFocusNodes = [];
//   List<FocusNode> _genreFocusNodes = [];
//   List<FocusNode> _keyboardFocusNodes = [];
//   final FocusNode _widgetFocusNode = FocusNode();
//   final ScrollController _listScrollController = ScrollController();
//   final ScrollController _networkScrollController = ScrollController();
//   final ScrollController _genreScrollController = ScrollController();

//   late PageController _sliderPageController;

//   // Keyboard State
//   int _focusedKeyRow = 0;
//   int _focusedKeyCol = 0;
//   final List<List<String>> _keyboardLayout = [
//     "1234567890".split(''),
//     "qwertyuiop".split(''),
//     "asdfghjkl".split(''),
//     ["z", "x", "c", "v", "b", "n", "m", "DEL"],
//     [" ", "OK"],
//   ];

//   // UI and Filter State
//   int _focusedNetworkIndex = 0;
//   int _focusedGenreIndex = 0;
//   int _focusedItemIndex = -1;
//   String _selectedNetworkName = '';
//   String? _selectedNetworkLogo;
//   String _selectedGenre = 'All';
//   // REFACTOR: _filteredWebSeriesList -> _filteredTvShowList
//   List<TvShowModel> _filteredTvShowList = [];
//   List<ApiNetworkModel> _apiNetworks = [];
//   List<String> _uniqueNetworks = [];
//   List<String> _uniqueGenres = [];

//   // Animation and Loading State
//   bool _isVideoLoading = false;
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//   String? _currentBackgroundUrl;
//   // REFACTOR: _currentWebSeriesSliders -> _currentTvShowSliders
//   List<SliderModel> _currentTvShowSliders = [];
//   int _currentSliderIndex = 0;

//   String _lastNavigationDirection = 'horizontal';

//   // ===== FIX START: Hang/Crash issue ko theek karne ke liye variables =====
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;
//   // ===== FIX END =====

//   // Search State
//   bool _isSearching = false;
//   bool _showKeyboard = false;
//   String _searchText = '';
//   Timer? _debounce;
//   // REFACTOR: _searchResults type
//   List<TvShowModel> _searchResults = [];
//   bool _isSearchLoading = false;
//   late FocusNode _searchButtonFocusNode;

//   bool _isGenreLoading = false;

//   final List<Color> _focusColors = [
//     ProfessionalColors.accentBlue,
//     ProfessionalColors.accentPurple,
//     ProfessionalColors.accentOrange,
//     ProfessionalColors.accentPink,
//     ProfessionalColors.accentRed
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _sliderPageController = PageController();
//     _searchButtonFocusNode = FocusNode();
//     _searchButtonFocusNode.addListener(() {
//       if (mounted) setState(() {});
//     });
//     _fetchDataForPage();
//     _initializeAnimations();
//   }

//   @override
//   void dispose() {
//     _sliderPageController.dispose();
//     _fadeController.dispose();
//     _widgetFocusNode.dispose();
//     _listScrollController.dispose();
//     _networkScrollController.dispose();
//     _genreScrollController.dispose();
//     _searchButtonFocusNode.dispose();
//     _debounce?.cancel();

//     // ===== FIX START: Memory leak se bachne ke liye Timer ko cancel karein =====
//     _navigationLockTimer?.cancel();
//     // ===== FIX END =====

//     _disposeFocusNodes(_itemFocusNodes);
//     _disposeFocusNodes(_networkFocusNodes);
//     _disposeFocusNodes(_genreFocusNodes);
//     _disposeFocusNodes(_keyboardFocusNodes);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Focus(
//         focusNode: _widgetFocusNode,
//         autofocus: true,
//         onKey: _onKeyHandler,
//         child: Stack(
//           children: [
//             _buildBackgroundOrSlider(),
//             _isLoading
//                 ? const Center(
//                     // REFACTOR: Loading message
//                     child: ProfessionalTvShowLoadingIndicator(
//                         message: 'Loading All Shows...'))
//                 : _errorMessage != null
//                     ? _buildErrorWidget()
//                     : _buildPageContent(),
//             if (_isVideoLoading && _errorMessage == null)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.8),
//                   child: const Center(
//                     child: ProfessionalTvShowLoadingIndicator(
//                         message: 'Loading Details...'),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   //=================================================
//   // SECTION 2.1: DATA FETCHING AND PROCESSING
//   //=================================================

//   Future<void> _fetchDataForPage({bool forceRefresh = false}) async {
//     if (!mounted) return;
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       final results = await Future.wait([
//         // REFACTOR: Call _fetchAndCacheTvShows
//         _fetchAndCacheTvShows(forceRefresh: forceRefresh),
//         _fetchNetworks(),
//       ]);
//       // REFACTOR: Cast to TvShowModel
//       final fetchedList = results[0] as List<TvShowModel>;
//       final fetchedNetworks = results[1] as List<ApiNetworkModel>;
//       fetchedList.sort((a, b) => a.seriesOrder.compareTo(b.seriesOrder));
//       fetchedNetworks
//           .sort((a, b) => a.networksOrder.compareTo(b.networksOrder));
      
//       // CHANGE 3: Data fetch hone ke baad list ko ek baar shuffle karein.
//       fetchedList.shuffle();

//       if (mounted) {
//         // REFACTOR: Error message
//         if (fetchedList.isEmpty) _errorMessage = "No TV Shows Found.";
//         setState(() {
//           // REFACTOR: _webSeriesList -> _tvShowList
//           _tvShowList = fetchedList;
//           _apiNetworks = fetchedNetworks;
//         });
//         if (_errorMessage == null) {
//           _processInitialData();
//           _initializeFocusNodes();
//           _startAnimations();
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (mounted && _networkFocusNodes.isNotEmpty) {
//               _networkFocusNodes[0].requestFocus();
//             }
//           });
//         }
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           // REFACTOR: Error message
//           _errorMessage =
//               "Failed to load TV Shows.\nPlease check your connection.";
//         });
//       }
//     }
//   }

//   // CHANGE 4: Caching logic ko function se hata diya gaya hai.
//   // Yeh function ab hamesha API se data fetch karega.
//   // REFACTOR: _fetchAndCacheWebSeries -> _fetchAndCacheTvShows
//   Future<List<TvShowModel>> _fetchAndCacheTvShows(
//       {bool forceRefresh = false}) async {
//     final prefs = await SharedPreferences.getInstance();
//     try {
//       String authKey = prefs.getString('result_auth_key') ?? '';
//       // REFACTOR: API Endpoint
//       final response = await https.get(
//         Uri.parse('https://dashboard.cpplayers.com/api/v2/getAllWebSeries'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': 'coretechinfo.com'
//         },
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         return jsonData
//             .map(
//                 // REFACTOR: Use TvShowModel.fromJson
//                 (item) => TvShowModel.fromJson(item as Map<String, dynamic>))
//             .toList();
//       } else {
//         throw Exception('API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       // REFACTOR: Error message
//       throw Exception('Failed to load tv shows: $e');
//     }
//   }

//   Future<List<ApiNetworkModel>> _fetchNetworks() async {
//     final prefs = await SharedPreferences.getInstance();
//     final authKey = prefs.getString('result_auth_key') ?? '';
//     try {
//       final response = await https
//           .post(
//             Uri.parse('https://dashboard.cpplayers.com/api/v3/getNetworks'),
//             headers: {
//               'auth-key': authKey,
//               'Content-Type': 'application/json',
//               'Accept': 'application/json',
//               'domain': 'coretechinfo.com'
//             },
//             body: json.encode({"network_id": "", "data_for": "tvshows"}),
//           )
//           .timeout(const Duration(seconds: 30));
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         return jsonData
//             .map((item) => ApiNetworkModel.fromJson(item as Map<String, dynamic>))
//             .toList();
//       } else {
//         throw Exception('API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load networks: $e');
//     }
//   }

//   void _processInitialData() {
//     // REFACTOR: _webSeriesList -> _tvShowList
//     if (_tvShowList.isEmpty && _apiNetworks.isEmpty) return;
//     _uniqueNetworks = _apiNetworks.map((n) => n.name).toList();
//     if (_uniqueNetworks.isNotEmpty) {
//       _selectedNetworkName = _uniqueNetworks[0];
//       _updateSelectedNetworkData();
//       _updateGenresForSelectedNetwork();
//     }
//     _applyFilters();
//   }



//   //=================================================
// // SECTION 2.3: STATE MANAGEMENT & UI LOGIC (ke Aas Paas Add Karein)
// //=================================================

//   // ===== FIX START: Pehle scroll karke fir focus karne ke liye naya function =====
//   void _focusFirstListItemWithScroll() {
//     if (_itemFocusNodes.isEmpty) return;

//     // List ko shuruaat mein scroll karein
//     if (_listScrollController.hasClients) {
//       _listScrollController.animateTo(
//         0.0,
//         duration: AnimationTiming.fast, // 250ms
//         curve: Curves.easeInOut,
//       );
//     }

//     // Thodi der baad (scroll animation shuru hone ke baad) pehle item par focus karein.
//     // Isse user ko scroll animation dikhega aur fir focus highlight aayega.
//     Future.delayed(const Duration(milliseconds: 250), () {
//       if (mounted && _itemFocusNodes.isNotEmpty) {
//         setState(() => _focusedItemIndex = 0);
//         _itemFocusNodes[0].requestFocus();
//       }
//     });
//   }
//   // ===== FIX END =====



//   //=================================================
//   // SECTION 2.2: KEYBOARD AND FOCUS NAVIGATION
//   //=================================================

//   KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
//     if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
    
//     bool searchHasFocus = _searchButtonFocusNode.hasFocus;
//     bool networkHasFocus = _networkFocusNodes.any((n) => n.hasFocus);
//     bool genreHasFocus = _genreFocusNodes.any((n) => n.hasFocus);
//     bool listHasFocus = _itemFocusNodes.any((n) => n.hasFocus);
//     bool keyboardHasFocus = _keyboardFocusNodes.any((n) => n.hasFocus);
//     final LogicalKeyboardKey key = event.logicalKey;

//     if (key == LogicalKeyboardKey.goBack) {
//       if (_showKeyboard) {
//         setState(() {
//           _showKeyboard = false;
//           _focusedKeyRow = 0;
//           _focusedKeyCol = 0;
//         });
//         _searchButtonFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (listHasFocus || genreHasFocus || searchHasFocus) {
//         _networkFocusNodes[_focusedNetworkIndex].requestFocus();
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.ignored;
//     }

//     if (keyboardHasFocus && _showKeyboard) {
//       return _navigateKeyboard(key);
//     }
    
//     if (searchHasFocus) {
//       if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//         setState(() {
//           _showKeyboard = true;
//           _focusedKeyRow = 0;
//           _focusedKeyCol = 0;
//         });
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted && _keyboardFocusNodes.isNotEmpty) {
//             _keyboardFocusNodes[0].requestFocus();
//           }
//         });
//         return KeyEventResult.handled;
//       }
//       if (key == LogicalKeyboardKey.arrowLeft) {
//         return KeyEventResult.handled; // Do nothing
//       }
//       if (key == LogicalKeyboardKey.arrowRight && _genreFocusNodes.isNotEmpty) {
//         _genreFocusNodes[0].requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (key == LogicalKeyboardKey.arrowUp && _networkFocusNodes.isNotEmpty) {
//         _networkFocusNodes[_focusedNetworkIndex].requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
//         setState(() => _focusedItemIndex = 0);
//         // _itemFocusNodes[0].requestFocus();
//          _focusFirstListItemWithScroll();
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.handled;
//     }

//     if ([
//       LogicalKeyboardKey.arrowUp,
//       LogicalKeyboardKey.arrowDown,
//       LogicalKeyboardKey.arrowLeft,
//       LogicalKeyboardKey.arrowRight,
//       LogicalKeyboardKey.select,
//       LogicalKeyboardKey.enter
//     ].contains(key)) {
//       if (networkHasFocus) {
//         _navigateNetworks(key);
//       } else if (genreHasFocus) {
//         _navigateGenres(key);
//       } else if (listHasFocus) {
//         _navigateList(key);
//       }
//       return KeyEventResult.handled;
//     }

//     return KeyEventResult.ignored;
//   }

//   // ===== FIX START: Fast navigation hang/crash ke liye updated function =====
//   void _navigateList(LogicalKeyboardKey key) {
//     // Agar navigation pehle se locked hai, to function se bahar nikal jao
//     if (_isNavigationLocked) return;

//     if (_focusedItemIndex == -1 || _itemFocusNodes.isEmpty) return;

//     // Navigation ko turant lock karo
//     setState(() {
//       _isNavigationLocked = true;
//     });

//     // Ek chota Timer set karo jo lock ko thodi der baad khol dega
//     // Yeh 300ms ka cooldown period dega
//     _navigationLockTimer = Timer(const Duration(milliseconds: 700), () {
//       if (mounted) {
//         setState(() {
//           _isNavigationLocked = false;
//         });
//       }
//     });

//     int newIndex = _focusedItemIndex;
    
//     if (key == LogicalKeyboardKey.arrowUp) {
//       setState(() => _lastNavigationDirection = 'vertical');
//       if (_genreFocusNodes.isNotEmpty) {
//         _genreFocusNodes[_focusedGenreIndex].requestFocus();
//       } else {
//         _searchButtonFocusNode.requestFocus();
//       }
//       setState(() => _focusedItemIndex = -1);
      
//       // Lock aur timer ko cancel kar do kyunki hum list se bahar ja rahe hain
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();
//       return;

//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       // arrowDown par kuch nahi karna hai, isliye lock hata do
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();
//       return;

//     } else if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newIndex > 0) {
//         newIndex--;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       final currentList =
//           _isSearching ? _searchResults : _filteredTvShowList; // REFACTOR
//       if (newIndex + 1 < currentList.length) {
//         newIndex++;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
      
//       // Enter/Select par cooldown nahi chahiye, isliye lock turant hata do
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();

//       final currentList =
//           _isSearching ? _searchResults : _filteredTvShowList; // REFACTOR
//       // REFACTOR
//       _navigateToTvShowDetails(currentList[_focusedItemIndex], _focusedItemIndex);
//       return;
//     }

//     if (newIndex != _focusedItemIndex) {
//       setState(() => _focusedItemIndex = newIndex);
//       _itemFocusNodes[newIndex].requestFocus();
//     } else {
//       // Agar index nahi badla (e.g., pehle item par left dabaya), to lock hata do
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();
//     }
//   }
//   // ===== FIX END =====

//   void _navigateNetworks(LogicalKeyboardKey key) {
//     int newIndex = _focusedNetworkIndex;
//     if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newIndex > 0) {
//         newIndex--;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       if (newIndex < _uniqueNetworks.length - 1) {
//         newIndex++;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       setState(() => _lastNavigationDirection = 'vertical');
//       _updateSelectedNetwork();
//       _searchButtonFocusNode.requestFocus();
//       return;
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       _updateSelectedNetwork();
//       return;
//     }
//     if (newIndex != _focusedNetworkIndex) {
//       setState(() => _focusedNetworkIndex = newIndex);
//       _networkFocusNodes[newIndex].requestFocus();
//       _updateAndScrollToFocus(
//           _networkFocusNodes, newIndex, _networkScrollController, 160);
//     }
//   }

//   void _navigateGenres(LogicalKeyboardKey key) {
//     int newIndex = _focusedGenreIndex;
//     if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newIndex > 0) {
//         newIndex--;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       } else {
//         _searchButtonFocusNode.requestFocus();
//         return;
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       if (newIndex < _uniqueGenres.length - 1) {
//         newIndex++;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.arrowUp) {
//       if (_networkFocusNodes.isNotEmpty) {
//         setState(() => _lastNavigationDirection = 'vertical');
//         _networkFocusNodes[_focusedNetworkIndex].requestFocus();
//       }
//       return;
//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       setState(() => _lastNavigationDirection = 'vertical');
//       _updateSelectedGenre();
//       if (_itemFocusNodes.isNotEmpty) {
//         setState(() => _focusedItemIndex = 0);
//         // _itemFocusNodes[0].requestFocus();
//         _focusFirstListItemWithScroll();
//       }
//       return;
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       _updateSelectedGenre();
//       return;
//     }
//     if (newIndex != _focusedGenreIndex) {
//       setState(() => _focusedGenreIndex = newIndex);
//       _genreFocusNodes[newIndex].requestFocus();
//       _updateAndScrollToFocus(
//           _genreFocusNodes, newIndex, _genreScrollController, 160);
//     }
//   }

//   KeyEventResult _navigateKeyboard(LogicalKeyboardKey key) {
//     int newRow = _focusedKeyRow;
//     int newCol = _focusedKeyCol;
//     if (key == LogicalKeyboardKey.arrowUp) {
//       if (newRow > 0) {
//         newRow--;
//         newCol = math.min(newCol, _keyboardLayout[newRow].length - 1);
//       }
//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       if (newRow < _keyboardLayout.length - 1) {
//         newRow++;
//         newCol = math.min(newCol, _keyboardLayout[newRow].length - 1);
//       }
//     } else if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newCol > 0) newCol--;
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       if (newCol < _keyboardLayout[newRow].length - 1) newCol++;
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       final keyValue = _keyboardLayout[newRow][newCol];
//       _onKeyPressed(keyValue);
//       return KeyEventResult.handled;
//     }

//     if (newRow != _focusedKeyRow || newCol != _focusedKeyCol) {
//       setState(() {
//         _focusedKeyRow = newRow;
//         _focusedKeyCol = newCol;
//       });
//       final focusIndex = _getFocusNodeIndexForKey(newRow, newCol);
//       if (focusIndex >= 0 && focusIndex < _keyboardFocusNodes.length) {
//         _keyboardFocusNodes[focusIndex].requestFocus();
//       }
//     }
//     return KeyEventResult.handled;
//   }

//   //=================================================
//   // SECTION 2.3: STATE MANAGEMENT & UI LOGIC
//   //=================================================

//   void _applyFilters() {
//     if (_isSearching) {
//       setState(() {
//         _isSearching = false;
//         _searchText = '';
//         _searchResults.clear();
//       });
//     }
//     // REFACTOR: _webSeriesList -> _tvShowList
//     _filteredTvShowList = _tvShowList.where((series) {
//       final bool networkMatch = _selectedNetworkName.isEmpty ||
//           series.networks.any((n) => n.name == _selectedNetworkName);
//       final bool genreMatch = _selectedGenre == 'All' ||
//           (series.genres
//                   ?.split(',')
//                   .map((e) => e.trim())
//                   .contains(_selectedGenre) ??
//               false);
//       return networkMatch && genreMatch;
//     }).toList();
    
//     // CHANGE 5: Yahan se shuffle ko hata diya gaya hai.
//     // _filteredTvShowList.shuffle();  
    
//     _rebuildItemFocusNodes();
//     _focusedItemIndex = -1;
//   }

//   void _updateSelectedNetwork() {
//     setState(() {
//       _selectedNetworkName = _uniqueNetworks[_focusedNetworkIndex];
//       _updateSelectedNetworkData();
//       _updateGenresForSelectedNetwork();
//       _rebuildGenreFocusNodes();
//       _focusedGenreIndex = 0;
//       _selectedGenre = 'All';
//       _applyFilters();
//     });
//   }

//   void _updateSelectedGenre() {
//     setState(() {
//       _selectedGenre = _uniqueGenres[_focusedGenreIndex];
//       _applyFilters();
//     });
//   }

//   void _updateSelectedNetworkData() {
//     final selectedNetwork = _apiNetworks.firstWhere(
//         (n) => n.name == _selectedNetworkName,
//         orElse: () => ApiNetworkModel(id: -1, name: '', networksOrder: 9999));
//     // REFACTOR: webSeriesSliders -> tvShowSliders
//     final tvShowSliders = selectedNetwork.sliders
//         .where((s) => s.sliderFor == 'tvshows')
//         .toList();
//     setState(() {
//       _selectedNetworkLogo = selectedNetwork.logo;
//       // REFACTOR: _currentWebSeriesSliders -> _currentTvShowSliders
//       _currentTvShowSliders = tvShowSliders;
//       _currentSliderIndex = 0;
//       // REFACTOR: webSeriesSliders -> tvShowSliders
//       if (tvShowSliders.isNotEmpty) {
//         _currentBackgroundUrl = tvShowSliders.first.banner;
//       } else {
//         _currentBackgroundUrl = selectedNetwork.logo;
//       }
//     });

//     // REFACTOR: _currentWebSeriesSliders -> _currentTvShowSliders
//     if (_sliderPageController.hasClients && _currentTvShowSliders.isNotEmpty) {
//       _sliderPageController.jumpToPage(0);
//     }
//   }

//   void _updateGenresForSelectedNetwork() {
//     // REFACTOR: _webSeriesList -> _tvShowList
//     if (_selectedNetworkName.isEmpty || _tvShowList.isEmpty) return;
//     // REFACTOR: _webSeriesList -> _tvShowList
//     final networkSpecificSeries = _tvShowList
//         .where((series) => series.networks.any((n) => n.name == _selectedNetworkName))
//         .toList();
//     final Set<String> genres = {'All'};
//     for (final series in networkSpecificSeries) {
//       if (series.genres != null && series.genres!.isNotEmpty) {
//         final genreList = series.genres!
//             .split(',')
//             .map((g) => g.trim())
//             .where((g) => g.isNotEmpty);
//         // REFACTOR: 'web series' -> 'tv show'
//         genres.addAll(genreList.where((g) =>
//             g.toLowerCase() != 'tv show' && g.toLowerCase() != 'tvshow'));
//       }
//     }
//     final sortedGenres = genres.toList()..sort();
//     if (sortedGenres.contains('All')) {
//       sortedGenres.remove('All');
//       sortedGenres.insert(0, 'All');
//     }
//     _uniqueGenres = sortedGenres;
//   }

//   void _performSearch(String searchTerm) {
//     _debounce?.cancel();
//     if (searchTerm.trim().isEmpty) {
//       setState(() {
//         _isSearching = false;
//         _isSearchLoading = false;
//         _searchResults.clear();
//         _rebuildItemFocusNodes();
//       });
//       return;
//     }
//     _debounce = Timer(const Duration(milliseconds: 400), () async {
//       if (!mounted) return;
//       setState(() {
//         _isSearchLoading = true;
//         _isSearching = true;
//         _searchResults.clear();
//       });
//       final results = await _performSearchInNetwork(searchTerm);
//       if (!mounted) return;
//       setState(() {
//         _searchResults = results;
//         _isSearchLoading = false;
//         _rebuildItemFocusNodes();
//       });
//     });
//   }

//   // REFACTOR: Return type
//   Future<List<TvShowModel>> _performSearchInNetwork(String searchTerm) async {
//     if (searchTerm.isEmpty || _selectedNetworkName.isEmpty) {
//       return [];
//     }
//     // REFACTOR: _webSeriesList -> _tvShowList
//     final networkSeries = _tvShowList
//         .where((series) => series.networks.any((n) => n.name == _selectedNetworkName))
//         .toList();
//     return networkSeries
//         .where(
//             (series) => series.name.toLowerCase().contains(searchTerm.toLowerCase()))
//         .toList();
//   }

//   void _onKeyPressed(String value) {
//     setState(() {
//       if (value == 'OK') {
//         _showKeyboard = false;
//         if (_itemFocusNodes.isNotEmpty) {
//           _itemFocusNodes.first.requestFocus();
//         } else {
//           _searchButtonFocusNode.requestFocus();
//         }
//         return;
//       }
//       if (value == 'DEL') {
//         if (_searchText.isNotEmpty) {
//           _searchText = _searchText.substring(0, _searchText.length - 1);
//         }
//       } else if (value == ' ') {
//         _searchText += ' ';
//       } else {
//         _searchText += value;
//       }
//       _performSearch(_searchText);
//     });
//   }

//   // REFACTOR: _navigateToWebSeriesDetails -> _navigateToTvShowDetails
//   Future<void> _navigateToTvShowDetails(
//       TvShowModel tvShow, int index) async {
//     if (_isVideoLoading) return;
//     setState(() => _isVideoLoading = true);
//     try {
//       int? currentUserId = SessionManager.userId;
//       await HistoryService.updateUserHistory(
//         userId: currentUserId!,
//         contentType: 2, // NOTE: Assuming '2' is for TV Shows/WebSeries
//         eventId: tvShow.id,
//         eventTitle: tvShow.name,
//         url: '',
//         categoryId: 0,
//       );
//     } catch (e) {
//       // History update failure should not block navigation
//     }
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         // REFACTOR: WebSeriesDetailsPage -> TvShowDetailsPage
//         builder: (context) => TvShowFinalDetailsPage(
//           id: tvShow.id,
//           banner: tvShow.banner ?? tvShow.poster ?? '',
//           poster: tvShow.poster ?? tvShow.banner ?? '',
//           // logo: tvShow.poster ?? tvShow.banner ?? '',
//           name: tvShow.name,
//           // updatedAt: tvShow.updatedAt,
//         ),
//       ),
//     );
//     if (mounted) {
//       setState(() {
//         _isVideoLoading = false;
//         _focusedItemIndex = index;
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted &&
//             _focusedItemIndex >= 0 &&
//             _focusedItemIndex < _itemFocusNodes.length) {
//           _itemFocusNodes[_focusedItemIndex].requestFocus();
//         }
//       });
//     }
//   }


//   //=================================================
//   // SECTION 2.4: INITIALIZATION AND CLEANUP
//   //=================================================

//   void _initializeAnimations() {
//     _fadeController =
//         AnimationController(duration: AnimationTiming.medium, vsync: this);
//     _fadeAnimation =
//         CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
//   }

//   void _startAnimations() {
//     _fadeController.forward();
//   }

//   void _initializeFocusNodes() {
//     _disposeFocusNodes(_networkFocusNodes);
//     _networkFocusNodes = List.generate(
//         _uniqueNetworks.length, (index) => FocusNode(debugLabel: 'Network-$index'));
//     _rebuildGenreFocusNodes();
//     _rebuildItemFocusNodes();
//     _rebuildKeyboardFocusNodes();
//   }

//   void _rebuildGenreFocusNodes() {
//     _disposeFocusNodes(_genreFocusNodes);
//     _genreFocusNodes = List.generate(
//         _uniqueGenres.length, (index) => FocusNode(debugLabel: 'Genre-$index'));
//   }

//   void _rebuildItemFocusNodes() {
//     _disposeFocusNodes(_itemFocusNodes);
//     // REFACTOR: _filteredWebSeriesList -> _filteredTvShowList
//     final currentList = _isSearching ? _searchResults : _filteredTvShowList;
//     _itemFocusNodes = List.generate(
//         currentList.length, (index) => FocusNode(debugLabel: 'Item-$index'));
//   }

//   void _rebuildKeyboardFocusNodes() {
//     _disposeFocusNodes(_keyboardFocusNodes);
//     int totalKeys =
//         _keyboardLayout.fold(0, (prev, row) => prev + row.length);
//     _keyboardFocusNodes =
//         List.generate(totalKeys, (index) => FocusNode(debugLabel: 'Key-$index'));
//   }

//   int _getFocusNodeIndexForKey(int row, int col) {
//     int index = 0;
//     for (int r = 0; r < row; r++) {
//       index += _keyboardLayout[r].length;
//     }
//     return index + col;
//   }

//   void _disposeFocusNodes(List<FocusNode> nodes) {
//     for (var node in nodes) {
//       node.dispose();
//     }
//   }

//   void _updateAndScrollToFocus(List<FocusNode> nodes, int index,
//       ScrollController controller, double itemWidth) {
//     if (!mounted ||
//         index < 0 ||
//         index >= nodes.length ||
//         !controller.hasClients) return;
//     double screenWidth = MediaQuery.of(context).size.width;
//     double scrollPosition = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
//     controller.animateTo(
//       scrollPosition.clamp(0.0, controller.position.maxScrollExtent),
//       duration: AnimationTiming.fast,
//       curve: Curves.easeInOut,
//     );
//   }

//   //=================================================
//   // SECTION 2.5: WIDGET BUILDER METHODS
//   //=================================================

//   Widget _buildPageContent() {
//     return Padding(
//       padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.02, vertical: screenhgt * 0.02),

//       child: Column(
//         children: [
//           _buildTopFilterBar(),
//           Expanded(
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: _buildContentBody(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContentBody() {
//     return Column(
//       children: [
//         SizedBox(
//           height: screenhgt * 0.5,
//           child: _showKeyboard ? _buildSearchUI() : const SizedBox.shrink(),
//         ),
//         _buildSliderIndicators(),
//         _buildGenreAndSearchButtons(),
//         SizedBox(height: screenhgt * 0.02),
//         // REFACTOR: Call _buildTvShowList
//         _buildTvShowList(),
//       ],
//     );
//   }
  
//   Widget _buildBackgroundOrSlider() {
//     // REFACTOR: _currentWebSeriesSliders -> _currentTvShowSliders
//     if (_currentTvShowSliders.isNotEmpty) {
//       // REFACTOR: WebSeriesBannerSlider -> TvShowBannerSlider
//       return TvShowBannerSlider(
//         sliders: _currentTvShowSliders,
//         controller: _sliderPageController,
//         onPageChanged: (index) {
//           if (mounted) {
//             setState(() {
//               _currentSliderIndex = index;
//             });
//           }
//         },
//       );
//     } else {
//       return _buildDynamicBackground();
//     }
//   }

//   Widget _buildDynamicBackground() {
//     return AnimatedSwitcher(
//       duration: AnimationTiming.medium,
//       child: _currentBackgroundUrl != null && _currentBackgroundUrl!.isNotEmpty
//           ? Container(
//               key: ValueKey<String>(_currentBackgroundUrl!),
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   // CHANGE 6: CachedNetworkImageProvider ko NetworkImage se badla gaya.
//                   image: NetworkImage(_currentBackgroundUrl!),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.primaryDark.withOpacity(0.2),
//                       ProfessionalColors.primaryDark.withOpacity(0.4),
//                       ProfessionalColors.primaryDark.withOpacity(0.6),
//                       ProfessionalColors.primaryDark.withOpacity(0.9),
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     stops: const [0.0, 0.5, 0.7, 0.9],
//                   ),
//                 ),
//               ),
//             )
//           : Container(
//               key: const ValueKey<String>('no_bg'),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     ProfessionalColors.primaryDark,
//                     ProfessionalColors.surfaceDark,
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _buildTopFilterBar() {
//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: EdgeInsets.only(
//             top: MediaQuery.of(context).padding.top +5,
//             bottom: 5,
//             left: screenwdt * 0.015,
//             right: 0,
//           ),
//           decoration: BoxDecoration(
//             // gradient: LinearGradient(
//             //  colors: [
//             //    Colors.black.withOpacity(0.3),
//             //    Colors.black.withOpacity(0.1),
//             //  ],
//             //  begin: Alignment.topCenter,
//             //  end: Alignment.bottomCenter,
//             // ),
//             color: Colors.transparent,
//             border: Border(
//               bottom: BorderSide(
//                 color: Colors.white.withOpacity(0.1),
//                 width: 1,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               Expanded(child: _buildNetworkFilter()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNetworkFilter() {
//     return SizedBox(
//       height: 30,
//       child: Center(
//         child: ListView.builder(
//           controller: _networkScrollController,
//           scrollDirection: Axis.horizontal,
//           itemCount: _uniqueNetworks.length,
//           itemBuilder: (context, index) {
//             final networkName = _uniqueNetworks[index];
//             final focusNode = _networkFocusNodes[index];
//             final isSelected = _selectedNetworkName == networkName;
            
//             return Focus(
//               focusNode: focusNode,
//               onFocusChange: (hasFocus) {
//                 if (hasFocus) {
//                   setState(() => _focusedNetworkIndex = index);
//                 }
//               },
//               child: _buildGlassEffectButton(
//                 focusNode: focusNode,
//                 isSelected: isSelected,
//                 focusColor: _focusColors[index % _focusColors.length],
//                 onTap: () {
//                   setState(() => _focusedNetworkIndex = index);
//                   focusNode.requestFocus();
//                   _updateSelectedNetwork();
//                 },
//                 child: Text(
//                   networkName.toUpperCase(),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: focusNode.hasFocus || isSelected
//                         ? FontWeight.bold
//                         : FontWeight.w500,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildGenreAndSearchButtons() {
//     if (_uniqueGenres.length <= 1 && !_isSearching) {
//       return const SizedBox.shrink();
//     }
//     if (_isGenreLoading) {
//       return SizedBox(
//         height: 30,
//         child: const Center(
//           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//         ),
//       );
//     }

//     return SizedBox(
//       height: 30,
//       child: Center(
//         child: ListView.builder(
//           controller: _genreScrollController,
//           scrollDirection: Axis.horizontal,
//           itemCount: _uniqueGenres.length + 1, // +1 for Search button
//           padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.015),
//           itemBuilder: (context, index) {
//             if (index == 0) { // Search Button
//               return Focus(
//                 focusNode: _searchButtonFocusNode,
//                 child: _buildGlassEffectButton(
//                   focusNode: _searchButtonFocusNode,
//                   isSelected: _isSearching,
//                   focusColor: ProfessionalColors.accentOrange,
//                   onTap: () {
//                     _searchButtonFocusNode.requestFocus();
//                     setState(() {
//                       _showKeyboard = true;
//                       _focusedKeyRow = 0;
//                       _focusedKeyCol = 0;
//                     });
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       if (mounted && _keyboardFocusNodes.isNotEmpty) {
//                         _keyboardFocusNodes[0].requestFocus();
//                       }
//                     });
//                   },
//                   child:  Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.search, color: Colors.white),
//                       SizedBox(width: 8),
//                       Text(
//                         ("Search").toUpperCase(),
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }

//             // Genre Buttons
//             final genreIndex = index - 1;
//             final genre = _uniqueGenres[genreIndex];
//             final focusNode = _genreFocusNodes[genreIndex];
//             final isSelected = !_isSearching && _selectedGenre == genre;

//             return Focus(
//               focusNode: focusNode,
//               child: _buildGlassEffectButton(
//                 focusNode: focusNode,
//                 isSelected: isSelected,
//                 focusColor: _focusColors[genreIndex % _focusColors.length],
//                 onTap: () {
//                   setState(() => _focusedGenreIndex = genreIndex);
//                   focusNode.requestFocus();
//                   _updateSelectedGenre();
//                 },
//                 child: Text(
//                   genre.toUpperCase(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // REFACTOR: _buildWebSeriesList -> _buildTvShowList
//   Widget _buildTvShowList() {
//     // REFACTOR: _filteredWebSeriesList -> _filteredTvShowList
//     final currentList = _isSearching ? _searchResults : _filteredTvShowList;

//     if (_isSearchLoading) {
//       return const Expanded(child: Center(child: CircularProgressIndicator()));
//     }

//     if (currentList.isEmpty) {
//       return Expanded(
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(15),
//             margin: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: ProfessionalColors.surfaceDark.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.white.withOpacity(0.1)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.tv_off_rounded,
//                   size: 25,
//                   color: ProfessionalColors.textSecondary,
//                 ),
//                 // const SizedBox(height: 10),
//                 Text(
//                   _isSearching && _searchText.isNotEmpty
//                       ? "No results found for '$_searchText'"
//                       // REFACTOR: Text
//                       : 'No shows available for this filter.',
//                   style: const TextStyle(
//                     color: ProfessionalColors.textSecondary,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.only(top: 1.0),
//         child: ListView.builder(
//           controller: _listScrollController,
//           clipBehavior: Clip.none,
//           scrollDirection: Axis.horizontal,
//           padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.015),
//           itemCount: currentList.length,
//           itemBuilder: (context, index) {
//             return Container(
//               width: bannerwdt * 1.2,
//               margin: const EdgeInsets.only(right: 12.0),
//               child: InkWell(
//                 focusNode: _itemFocusNodes[index],
//                 // REFACTOR: Call _navigateToTvShowDetails
//                 onTap: () => _navigateToTvShowDetails(currentList[index], index),
//                 onFocusChange: (hasFocus) {
//                   if (hasFocus) {
//                     setState(() => _focusedItemIndex = index);
//                     _updateAndScrollToFocus(
//                         _itemFocusNodes, index, _listScrollController, (bannerwdt * 1.2) + 12);
//                   }
//                 },
//                 // REFACTOR: OptimizedWebSeriesCard -> OptimizedTvShowCard
//                 child: OptimizedTvShowCard(
//                   tvShow: currentList[index],
//                   isFocused: _focusedItemIndex == index,
//                   onTap: () =>
//                       // REFACTOR: Call _navigateToTvShowDetails
//                       _navigateToTvShowDetails(currentList[index], index),
//                   cardHeight: bannerhgt * 1.2,
//                   networkLogo: _selectedNetworkLogo,
//                   uniqueIndex: index,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchUI() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           flex: 4,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ShaderMask(
//                   blendMode: BlendMode.srcIn,
//                   shaderCallback: (bounds) => const LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple,
//                     ],
//                   ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
//                   // REFACTOR: Text
//                   child: const Text(
//                     "Search TV Shows",
//                     style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Container(
//                   width: double.infinity,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: ProfessionalColors.accentPurple, width: 2),
//                   ),
//                   child: Text(
//                     _searchText.isEmpty ? 'Start typing...' : _searchText,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: _searchText.isEmpty ? Colors.white54 : Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Expanded(
//           flex: 6,
//           child: _buildQwertyKeyboard(),
//         ),
//       ],
//     );
//   }

//   Widget _buildQwertyKeyboard() {
//     return Container(
//       color: Colors.transparent,
//       padding: const EdgeInsets.all(5),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           for (int rowIndex = 0; rowIndex < _keyboardLayout.length; rowIndex++)
//             _buildKeyboardRow(_keyboardLayout[rowIndex], rowIndex),
//         ],
//       ),
//     );
//   }

//   Widget _buildKeyboardRow(List<String> keys, int rowIndex) {
//     int startIndex = 0;
//     for (int i = 0; i < rowIndex; i++) {
//       startIndex += _keyboardLayout[i].length;
//     }

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: keys.asMap().entries.map((entry) {
//         final colIndex = entry.key;
//         final key = entry.value;
//         final focusIndex = startIndex + colIndex;
//         final isFocused = _focusedKeyRow == rowIndex && _focusedKeyCol == colIndex;
//         final screenWidth = MediaQuery.of(context).size.width;
//         final screenHeight = MediaQuery.of(context).size.height;
//         double width;
//         if (key == ' ') {
//           width = screenWidth * 0.315;
//         } else if (key == 'OK' || key == 'DEL') {
//           width = screenWidth * 0.09;
//         } else {
//           width = screenWidth * 0.045;
//         }

//         return Container(
//           width: width,
//           height: screenHeight * 0.08,
//           margin: const EdgeInsets.all(4.0),
//           child: Focus(
//             focusNode: _keyboardFocusNodes[focusIndex],
//             onFocusChange: (hasFocus) {
//               if (hasFocus) {
//                 setState(() {
//                   _focusedKeyRow = rowIndex;
//                   _focusedKeyCol = colIndex;
//                 });
//               }
//             },
//             child: ElevatedButton(
//               onPressed: () => _onKeyPressed(key),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isFocused
//                     ? ProfessionalColors.accentPurple
//                     : Colors.white.withOpacity(0.1),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                   side: isFocused
//                       ? const BorderSide(color: Colors.white, width: 3)
//                       : BorderSide.none,
//                 ),
//                 padding: EdgeInsets.zero,
//               ),
//               child: Text(
//                 key,
//                 style: TextStyle(
//                   fontSize: 22.0,
//                   fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildSliderIndicators() {
//     // REFACTOR: _currentWebSeriesSliders -> _currentTvShowSliders
//     if (_currentTvShowSliders.length <= 1) {
//       return const SizedBox.shrink();
//     }
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       // REFACTOR: _currentWebSeriesSliders -> _currentTvShowSliders
//       children: List.generate(_currentTvShowSliders.length, (index) {
//         bool isActive = _currentSliderIndex == index;
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
//           height: 8.0,
//           width: isActive ? 24.0 : 8.0,
//           decoration: BoxDecoration(
//             color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
//             borderRadius: BorderRadius.circular(12),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildGlassEffectButton({
//     required FocusNode focusNode,
//     required VoidCallback onTap,
//     required bool isSelected,
//     required Color focusColor,
//     required Widget child,
//   }) {
//     bool hasFocus = focusNode.hasFocus;
//     bool isHighlighted = hasFocus || isSelected;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(right: 15),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(30),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
//               decoration: BoxDecoration(
//                 color: hasFocus
//                     ? focusColor
//                     : isSelected
//                         ? focusColor.withOpacity(0.5)
//                         : Colors.white.withOpacity(0.08),
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.black.withOpacity(0.25),
//                     Colors.white.withOpacity(0.1),
//                   ],
//                   stops: const [0.0, 0.8],
//                 ),
//                 borderRadius: BorderRadius.circular(30),
//                 border: Border.all(
//                   color: hasFocus ? Colors.white : Colors.white.withOpacity(0.3),
//                   width: hasFocus ? 3 : 2,
//                 ),
//                 boxShadow: isHighlighted
//                     ? [
//                         BoxShadow(
//                           color: focusColor.withOpacity(0.8),
//                           blurRadius: 15,
//                           spreadRadius: 3,
//                         )
//                       ]
//                     : null,
//               ),
//               child: child,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.all(40),
//         padding: const EdgeInsets.all(32),
//         decoration: BoxDecoration(
//           color: ProfessionalColors.surfaceDark.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(color: Colors.white.withOpacity(0.1)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.red.withOpacity(0.1),
//               ),
//               child: const Icon(
//                 Icons.cloud_off_rounded,
//                 color: Colors.red,
//                 size: 60,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               _errorMessage ?? 'Something went wrong.',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: ProfessionalColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               focusNode: FocusNode(), // An unfocusable node
//               onPressed: () => _fetchDataForPage(forceRefresh: true),
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Try Again'),
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 backgroundColor: ProfessionalColors.accentBlue,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// //==============================================================================
// // SECTION 3: REUSABLE UI COMPONENTS
// // Yeh chhote, reusable widgets hain jo page par istemal hote hain.
// //==============================================================================

// // REFACTOR: OptimizedWebSeriesCard -> OptimizedTvShowCard
// class OptimizedTvShowCard extends StatelessWidget {
//   // REFACTOR: webSeries -> tvShow
//   final TvShowModel tvShow;
//   final bool isFocused;
//   final VoidCallback onTap;
//   final double cardHeight;
//   final String? networkLogo;
//   final int uniqueIndex;

//   const OptimizedTvShowCard({
//     Key? key,
//     // REFACTOR: webSeries -> tvShow
//     required this.tvShow,
//     required this.isFocused,
//     required this.onTap,
//     required this.cardHeight,
//     this.networkLogo,
//     required this.uniqueIndex,
//   }) : super(key: key);

//   final List<Color> _focusColors = const [
//     ProfessionalColors.accentBlue,
//     ProfessionalColors.accentPurple,
//     ProfessionalColors.accentPink,
//     ProfessionalColors.accentOrange,
//     ProfessionalColors.accentRed
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final focusColor = _focusColors[uniqueIndex % _focusColors.length];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         SizedBox(
//           height: cardHeight,
//           child: AnimatedContainer(
//             duration: AnimationTiming.fast,
//             transform: isFocused
//                 ? (Matrix4.identity()..scale(1.05))
//                 : Matrix4.identity(),
//             transformAlignment: Alignment.center,
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8.0),
//                 border: isFocused
//                     ? Border.all(color: focusColor, width: 3)
//                     : Border.all(color: Colors.transparent, width: 3),
//                 boxShadow: isFocused
//                     ? [
//                         BoxShadow(
//                             color: focusColor.withOpacity(0.5),
//                             blurRadius: 12,
//                             spreadRadius: 1)
//                       ]
//                     : []),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(6.0),
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   // REFACTOR: Call _buildTvShowImage
//                   _buildTvShowImage(),
//                   if (isFocused)
//                     Positioned(
//                         left: 5,
//                         top: 5,
//                         child: Container(
//                             color: Colors.black.withOpacity(0.4),
//                             child: Icon(Icons.play_circle_filled_outlined,
//                                 color: focusColor, size: 40))),
//                   if (networkLogo != null && networkLogo!.isNotEmpty)
//                     Positioned(
//                         top: 5,
//                         right: 5,
//                         child: CircleAvatar(
//                             radius: 12,
//                             backgroundImage: NetworkImage(networkLogo!),
//                             backgroundColor: Colors.black54)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 8.0, left: 2.0, right: 2.0),
//           // REFACTOR: webSeries.name -> tvShow.name
//           child: Text(tvShow.name,
//               style: TextStyle(
//                   color: isFocused
//                       ? focusColor
//                       : ProfessionalColors.textSecondary,
//                   fontSize: 14,
//                   fontWeight: isFocused ? FontWeight.bold : FontWeight.normal),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis),
//         ),
//       ],
//     );
//   }

//   // CHANGE 7: CachedNetworkImage ko Image.network se badal diya gaya hai.
//   // REFACTOR: _buildWebSeriesImage -> _buildTvShowImage
//   Widget _buildTvShowImage() {
//     // REFACTOR: webSeries.banner -> tvShow.banner
//     final imageUrl = tvShow.banner;
    
//     return imageUrl != null && imageUrl.isNotEmpty
//         ? Image.network(
//             imageUrl,
//             fit: BoxFit.cover,
//             // `loadingBuilder` ka istemal placeholder dikhane ke liye kiya gaya hai.
//             loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//               if (loadingProgress == null) return child;
//               return _buildImagePlaceholder();
//             },
//             // `errorBuilder` ka istemal error hone par placeholder dikhane ke liye kiya gaya hai.
//             errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
//               return _buildImagePlaceholder();
//             },
//           )
//         : _buildImagePlaceholder();
//   }
  
//   Widget _buildImagePlaceholder() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             ProfessionalColors.accentGreen,
//             ProfessionalColors.accentBlue,
//           ],
//         ),
//       ),
//       child: const Icon(
//         Icons.broken_image,
//         color: Colors.white,
//         size: 24,
//       ),
//     );
//   }
// }

// // REFACTOR: WebSeriesBannerSlider -> TvShowBannerSlider
// class TvShowBannerSlider extends StatefulWidget {
//   final List<SliderModel> sliders;
//   final ValueChanged<int> onPageChanged;
//   final PageController controller;

//   const TvShowBannerSlider({
//     Key? key,
//     required this.sliders,
//     required this.onPageChanged,
//     required this.controller,
//   }) : super(key: key);

//   @override
//   // REFACTOR: _WebSeriesBannerSliderState -> _TvShowBannerSliderState
//   _TvShowBannerSliderState createState() => _TvShowBannerSliderState();
// }

// // REFACTOR: _WebSeriesBannerSliderState -> _TvShowBannerSliderState
// class _TvShowBannerSliderState extends State<TvShowBannerSlider> {
//   Timer? _timer;
//   double _opacity = 1.0;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.sliders.length > 1) {
//       _startTimer();
//     }
//   }

//   @override
//   // REFACTOR: WebSeriesBannerSlider -> TvShowBannerSlider
//   void didUpdateWidget(TvShowBannerSlider oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.sliders.length != widget.sliders.length) {
//       _timer?.cancel();
//       if (widget.sliders.length > 1) {
//         _startTimer();
//       }
//     }
//   }

//   void _startTimer() {
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
//       if (!mounted || !widget.controller.hasClients || widget.sliders.length <= 1) return;

//       int currentPage = widget.controller.page?.round() ?? 0;
//       int nextPage = (currentPage + 1) % widget.sliders.length;

//       widget.controller.animateToPage(
//         nextPage,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.sliders.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return AnimatedOpacity(
//       opacity: _opacity,
//       duration: const Duration(milliseconds: 400),
//       child: PageView.builder(
//         controller: widget.controller,
//         itemCount: widget.sliders.length,
//         onPageChanged: widget.onPageChanged,
//         itemBuilder: (context, index) {
//           final slider = widget.sliders[index];
//           return Stack(
//             fit: StackFit.expand,
//             children: [
//               // CHANGE 8: Yahan bhi CachedNetworkImage ko Image.network se badal diya gaya hai.
//               Image.network(
//                 slider.banner,
//                 fit: BoxFit.cover,
//                 loadingBuilder: (context, child, progress) =>  
//                     progress == null ? child : Container(color: ProfessionalColors.surfaceDark),
//                 errorBuilder: (context, error, stackTrace) =>  
//                     Container(color: ProfessionalColors.surfaceDark),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.primaryDark.withOpacity(0.2),
//                       ProfessionalColors.primaryDark.withOpacity(0.4),
//                       ProfessionalColors.primaryDark.withOpacity(0.6),
//                       ProfessionalColors.primaryDark.withOpacity(0.9),
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     stops: const [0.0, 0.5, 0.7, 0.9],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }








// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data'; // Required for Uint8List (kTransparentImage)
// import 'dart:ui';
// // import 'package:cached_network_image/cached_network_image.dart'; // Not used
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:math' as math;
// import 'package:http/http.dart' as http; // Alias ko 'http' rakha gaya hai
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_final_details_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // NOTE: Apne project ke anusaar neeche di gayi import lines ko aavashyakta anusaar badlein.
// // Make sure to change the import lines below according to your project structure.
// import 'package:mobi_tv_entertainment/main.dart'; // bannerhgt ke liye
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';

// //==============================================================================
// // SECTION 1: COMMON CLASSES AND MODELS
// // Yeh classes data ko handle karne aur consistent UI ke liye hain.
// //==============================================================================

// class ProfessionalColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentGreen = Color.fromARGB(255, 59, 246, 68);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentPink = Color(0xFFEC4899);
//   static const accentOrange = Color(0xFFF59E0B);
//   static const accentRed = Color(0xFFEF4444);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);

//   static List<Color> gradientColors = [accentBlue, accentPurple, accentPink];
// }

// class AnimationTiming {
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
// }

// // NetworkModel pehle jaisa hi rahega kyunki _fetchNetworks abhi bhi ise istemal karega
// class NetworkModel {
//   final int id;
//   final String name;
//   final String? logo;
//   NetworkModel({required this.id, required this.name, this.logo});
//   factory NetworkModel.fromJson(Map<String, dynamic> json) {
//     return NetworkModel(
//         id: json['id'] ?? 0, name: json['name'] ?? '', logo: json['logo']);
//   }
// }

// // REFACTOR: TvShowModel ko ab TvChannel data represent karne ke liye update kiya gaya
// class TvShowModel { // Naam TvShowModel hi rakhte hain consistency ke liye
//   final int id;
//   final String name; // Channel Name OR Show Name
//   final String updatedAt; // Channel Updated At
//   final String? poster; // Channel Logo OR Show Thumbnail
//   final String? banner; // Channel Logo OR Show Thumbnail
//   final String? genre; // Show Genre
//   final int order; // Channel Order OR Show Order
//   final String? language; // Channel Language

//   TvShowModel({
//     required this.id,
//     required this.name,
//     required this.updatedAt,
//     this.poster,
//     this.banner,
//     this.genre, // Genre ko nullable rakha
//     required this.order,
//     this.language,
//   });

//   // Yeh factory TvChannel API (getTvChannels) se data parse karegi
//   factory TvShowModel.fromJson(Map<String, dynamic> json) {
//     return TvShowModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       poster: json['logo'], // 'logo' field se map kiya
//       banner: json['logo'], // 'logo' field se map kiya
//       genre: null, // 'genre' field nahi hai, null set kiya
//       order: json['order'] ?? 9999,
//       language: json['language'], // Naya field
//     );
//   }
// }

// //=================================================
// // SECTION 1.1: NEW MODEL FOR TV SHOWS (from getTvShows API)
// //=================================================
// class TvShowItemModel {
//   final int id;
//   final String name;
//   final String? thumbnail;
//   final String? genre;
//   final int tvChannelId;
//   final int order;

//   TvShowItemModel({
//     required this.id,
//     required this.name,
//     this.thumbnail,
//     this.genre,
//     required this.tvChannelId,
//     required this.order,
//   });

//   factory TvShowItemModel.fromJson(Map<String, dynamic> json) {
//     return TvShowItemModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       thumbnail: json['thumbnail'],
//       genre: json['genre'],
//       tvChannelId: json['tv_channel_id'] ?? 0,
//       order: json['order'] ?? 9999,
//     );
//   }
// }


// class SliderModel {
//   final int id;
//   final String title;
//   final String banner;
//   final String sliderFor;

//   SliderModel(
//       {required this.id,
//       required this.title,
//       required this.banner,
//       required this.sliderFor});

//   factory SliderModel.fromJson(Map<String, dynamic> json) {
//     return SliderModel(
//       id: json['id'] ?? 0,
//       title: json['title'] ?? '',
//       banner: json['banner'] ?? '',
//       sliderFor: json['slider_for'] ?? '',
//     );
//   }
// }

// class ApiNetworkModel {
//   final int id;
//   final String name;
//   final String? logo;
//   final int networksOrder;
//   final List<SliderModel> sliders;

//   ApiNetworkModel({
//     required this.id,
//     required this.name,
//     this.logo,
//     required this.networksOrder,
//     this.sliders = const [],
//   });

//   factory ApiNetworkModel.fromJson(Map<String, dynamic> json) {
//     var sliders = (json['sliders'] as List? ?? [])
//         .map((item) => SliderModel.fromJson(item as Map<String, dynamic>))
//         .toList();
//     return ApiNetworkModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       logo: json['logo'],
//       networksOrder: json['networks_order'] ?? 9999,
//       sliders: sliders,
//     );
//   }
// }

// // UI REFACTOR: Loading indicator from WebSeries
// class ProfessionalTvShowLoadingIndicator extends StatelessWidget {
//   final String message;
//   const ProfessionalTvShowLoadingIndicator({Key? key, required this.message})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: ProfessionalColors.gradientColors,
//               ),
//             ),
//             child: const CircularProgressIndicator(
//               color: Colors.white,
//               strokeWidth: 3,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             message,
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


// //==============================================================================
// // SECTION 2: MAIN PAGE WIDGET AND STATE
// // Yeh page ka main structure aur logic hai.
// //==============================================================================

// class TvShowSliderScreen extends StatefulWidget {
//   final String title;
//   const TvShowSliderScreen({Key? key, this.title = 'All TV Shows'})
//       : super(key: key);

//   @override
//   _TvShowSliderScreenState createState() =>
//       _TvShowSliderScreenState();
// }

// class _TvShowSliderScreenState
//     extends State<TvShowSliderScreen>
//     with SingleTickerProviderStateMixin {
//   List<TvShowModel> _tvShowList = []; // Yeh ab Channels ki MASTER list hogi (Network change par update hoti hai)
//   bool _isLoading = true; // Overall page loading
//   bool _isListLoading = false; // Network/Filter change par list loading
//   String? _errorMessage;

//   // Focus and Scroll Controllers
//   List<FocusNode> _itemFocusNodes = [];
//   List<FocusNode> _networkFocusNodes = [];
//   List<FocusNode> _channelFilterFocusNodes = []; 
//   List<FocusNode> _keyboardFocusNodes = [];
//   final FocusNode _widgetFocusNode = FocusNode();
//   final ScrollController _listScrollController = ScrollController();
//   final ScrollController _networkScrollController = ScrollController();
//   final ScrollController _channelFilterScrollController = ScrollController(); 

//   late PageController _sliderPageController;

//   // Keyboard State
//   int _focusedKeyRow = 0;
//   int _focusedKeyCol = 0;
//   final List<List<String>> _keyboardLayout = [
//     "1234567890".split(''),
//     "qwertyuiop".split(''),
//     "asdfghjkl".split(''),
//     ["z", "x", "c", "v", "b", "n", "m", "DEL"],
//     [" ", "OK"],
//   ];

//   // UI and Filter State
//   int _focusedNetworkIndex = 0;
//   int _focusedChannelFilterIndex = 0; 
//   int _focusedItemIndex = -1;
//   String _selectedNetworkName = '';
//   String? _selectedNetworkLogo;
  
//   Map<String, int?> _channelFilters = {}; // Holds "Channel Name" -> Channel ID ("All" removed)
//   String _selectedChannelFilterName = ''; // Default empty
//   int? _selectedChannelFilterId; // Default null
//   bool _isDisplayingShows = false; 

//   List<TvShowModel> _currentViewMasterList = []; // NEW: Holds all items for the current filter (pre-search)
//   List<TvShowModel> _displayList = []; // List jo UI mein render hogi (ya toh channels ya shows)
//   List<ApiNetworkModel> _apiNetworks = [];
//   List<String> _uniqueNetworks = [];
 
//   // Animation and Loading State
//   bool _isVideoLoading = false; // Detail page navigation loading
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//   String? _currentBackgroundUrl;
//   List<SliderModel> _currentTvShowSliders = [];
//   int _currentSliderIndex = 0;

//   String _lastNavigationDirection = 'horizontal';

//   // UI REFACTOR: Hang/Crash fix variables from WebSeries
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   // Search State
//   bool _isSearching = false;
//   bool _showKeyboard = false;
//   String _searchText = '';
//   Timer? _debounce;
//   late FocusNode _searchButtonFocusNode;

//   // bool _isGenreLoading = false; // Not used

//   final List<Color> _focusColors = [
//     ProfessionalColors.accentBlue,
//     ProfessionalColors.accentPurple,
//     ProfessionalColors.accentOrange,
//     ProfessionalColors.accentPink,
//     ProfessionalColors.accentRed
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _sliderPageController = PageController();
//     _searchButtonFocusNode = FocusNode();
//     _searchButtonFocusNode.addListener(_setStateListener); // Listener add
//     _widgetFocusNode.addListener(_setStateListener);
//     _fetchDataForPage();
//     _initializeAnimations();
//   }

//   @override
//   void dispose() {
//     _sliderPageController.dispose();
//     _fadeController.dispose();
//     _widgetFocusNode.removeListener(_setStateListener);
//     _widgetFocusNode.dispose();
//     _listScrollController.dispose();
//     _networkScrollController.dispose();
//     _channelFilterScrollController.dispose(); 
//     _searchButtonFocusNode.removeListener(_setStateListener);
//     _searchButtonFocusNode.dispose();
//     _debounce?.cancel();
//     _navigationLockTimer?.cancel();
//     _disposeFocusNodes(_itemFocusNodes);
//     _disposeFocusNodes(_networkFocusNodes);
//     _disposeFocusNodes(_channelFilterFocusNodes); 
//     _disposeFocusNodes(_keyboardFocusNodes);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Focus(
//         focusNode: _widgetFocusNode,
//         autofocus: true,
//         onKey: _onKeyHandler,
//         child: Stack(
//           children: [
//             _buildBackgroundOrSlider(),
//             _isLoading // Initial page load
//                 ? const Center(
//                     child: ProfessionalTvShowLoadingIndicator(
//                         message: 'Loading Channels...')) 
//                 : _errorMessage != null
//                     ? _buildErrorWidget() // UI REFACTOR: Use WebSeries error widget
//                     : _buildPageContent(), // UI REFACTOR: Use WebSeries layout
//             if (_isVideoLoading && _errorMessage == null) // Detail page navigation
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.8),
//                   child: const Center(
//                     child: ProfessionalTvShowLoadingIndicator(
//                         message: 'Loading Details...'),
//                   ),
//                 ),
//               ),
//             // UI REFACTOR: _isListLoading (list specific) spinner is removed
//             // The WebSeries UI doesn't have it, it relies on the main _isLoading
//             // and search's _isSearchLoading (which we removed)
//           ],
//         ),
//       ),
//     );
//   }

//   //=================================================
//   // SECTION 2.1: DATA FETCHING AND PROCESSING
//   //=================================================

//   // Data fetching logic remains the same (from TvShowSliderScreen)
//   Future<void> _fetchDataForPage({bool forceRefresh = false}) async {
//     if (!mounted) return;
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       // 1. Fetch Networks
//       final fetchedNetworks = await _fetchNetworks();
//       if (!mounted) return;
//       fetchedNetworks.sort((a, b) => a.networksOrder.compareTo(b.networksOrder));

//       if (fetchedNetworks.isEmpty) {
//         throw Exception("No networks found.");
//       }
//       setState(() {
//          _apiNetworks = fetchedNetworks;
//          _uniqueNetworks = _apiNetworks.map((n) => n.name).toList();
//       });

//       // 2. Fetch TV Channels for the first network
//       final int firstNetworkId = fetchedNetworks[0].id;
//       final fetchedList = await _fetchTvShowsForNetwork(firstNetworkId); 
//       if (!mounted) return;


//       setState(() {
//         _tvShowList = fetchedList; 
//         if (_tvShowList.isEmpty) _errorMessage = "No TV Channels Found for the first network."; 
//       });

//       if (_errorMessage == null) {
//         _processInitialData(); 
//         _updateChannelFilters(); // This will select the first channel
//         await _fetchDataForView(); // Fetch shows for the first channel
//         _initializeFocusNodes();
//         _startAnimations();
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted && _networkFocusNodes.isNotEmpty) {
//             _networkFocusNodes[0].requestFocus();
//           }
//         });
//       }
//        setState(() => _isLoading = false);

//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage =
//               "Failed to load initial data.\nPlease check your connection.";
//            debugPrint("Error fetching initial data: $e");
//         });
//       }
//     }
//   }

//   Future<List<TvShowModel>> _fetchTvShowsForNetwork(int networkId) async {
//     final prefs = await SharedPreferences.getInstance();
//     try {
//       String authKey = prefs.getString('result_auth_key') ?? '';
//       final response = await http.get(
//         Uri.parse('https://dashboard.cpplayers.com/api/v3/getTvChannels?content_network=$networkId'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': 'coretechinfo.com'
//         },
//       ).timeout(const Duration(seconds: 30));

//       if (!mounted) return [];

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         return jsonData
//             .map(
//                 (item) => TvShowModel.fromJson(item as Map<String, dynamic>)) 
//             .toList()
//                ..sort((a, b) => a.order.compareTo(b.order)); 
//       } else {
//         throw Exception('API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Failed to load tv channels for network $networkId: $e'); 
//       throw Exception('Failed to load tv channels for network $networkId: $e');
//     }
//   }

//   Future<List<TvShowItemModel>> _fetchTvShowsForChannel(int channelId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final authKey = prefs.getString('result_auth_key') ?? '';
//     try {
//       final response = await http.get( 
//         Uri.parse('https://dashboard.cpplayers.com/api/v2/getTvShows/$channelId'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': 'coretechinfo.com'
//         },
//       ).timeout(const Duration(seconds: 30));

//       if (!mounted) return [];

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         return jsonData
//             .map((item) => TvShowItemModel.fromJson(item as Map<String, dynamic>))
//             .toList()
//               ..sort((a, b) => a.order.compareTo(b.order)); 
//       } else {
//         throw Exception('API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Failed to load tv shows for channel $channelId: $e');
//       throw Exception('Failed to load tv shows for channel $channelId: $e');
//     }
//   }

//   Future<List<ApiNetworkModel>> _fetchNetworks() async {
//     final prefs = await SharedPreferences.getInstance();
//     final authKey = prefs.getString('result_auth_key') ?? '';
//     try {
//       final response = await http
//           .post(
//             Uri.parse('https://dashboard.cpplayers.com/api/v3/getNetworks'),
//             headers: {
//               'auth-key': authKey,
//               'Content-Type': 'application/json',
//               'Accept': 'application/json',
//               'domain': 'coretechinfo.com'
//             },
//             body: json.encode({"network_id": "", "data_for": "tvshows"}), 
//           )
//           .timeout(const Duration(seconds: 30));

//        if (!mounted) return [];

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         return jsonData
//             .map((item) => ApiNetworkModel.fromJson(item as Map<String, dynamic>))
//             .toList();
//       } else {
//         throw Exception('API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//        debugPrint('Failed to load networks: $e');
//       throw Exception('Failed to load networks: $e');
//     }
//   }

//   void _processInitialData() {
//     if (_apiNetworks.isEmpty) return;
//     _uniqueNetworks = _apiNetworks.map((n) => n.name).toList();
//     if (_uniqueNetworks.isNotEmpty) {
//       _selectedNetworkName = _uniqueNetworks[0];
//       _updateSelectedNetworkData(); // Slider/Background
//     }
//   }


//   //=================================================
//   // SECTION 2.3: STATE MANAGEMENT & UI LOGIC (ke Aas Paas Add Karein)
//   //=================================================

//   // UI REFACTOR: Function from WebSeries
//   void _focusFirstListItemWithScroll() {
//     if (_itemFocusNodes.isEmpty) return;

//     if (_listScrollController.hasClients) {
//       _listScrollController.animateTo(
//         0.0,
//         duration: AnimationTiming.fast, // 250ms
//         curve: Curves.easeInOut,
//       );
//     }
    
//     Future.delayed(const Duration(milliseconds: 250), () {
//       if (mounted && _itemFocusNodes.isNotEmpty) {
//         setState(() => _focusedItemIndex = 0);
//         _itemFocusNodes[0].requestFocus();
//       }
//     });
//   }


//   //=================================================
//   // SECTION 2.2: KEYBOARD AND FOCUS NAVIGATION
//   //=================================================

//   KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
//      if (event is! RawKeyDownEvent || _isListLoading || _isLoading) return KeyEventResult.ignored;

//     bool searchHasFocus = _searchButtonFocusNode.hasFocus;
//     bool networkHasFocus = _networkFocusNodes.any((n) => n.hasFocus);
//     bool channelFilterHasFocus = _channelFilterFocusNodes.any((n) => n.hasFocus);
//     bool listHasFocus = _itemFocusNodes.any((n) => n.hasFocus);
//     bool keyboardHasFocus = _keyboardFocusNodes.any((n) => n.hasFocus);
//     final LogicalKeyboardKey key = event.logicalKey;

//     if (key == LogicalKeyboardKey.goBack) {
//       if (_showKeyboard) {
//         setState(() { _showKeyboard = false; _focusedKeyRow = 0; _focusedKeyCol = 0; });
//         _searchButtonFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (listHasFocus || channelFilterHasFocus || searchHasFocus) { 
//          if (_networkFocusNodes.isNotEmpty) { _networkFocusNodes[_focusedNetworkIndex].requestFocus(); }
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.ignored;
//     }

//     if (keyboardHasFocus && _showKeyboard) { return _navigateKeyboard(key); }

//     if (searchHasFocus) {
//       if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//         setState(() { _showKeyboard = true; _focusedKeyRow = 0; _focusedKeyCol = 0; });
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted && _keyboardFocusNodes.isNotEmpty) { _keyboardFocusNodes[0].requestFocus(); }
//         });
//         return KeyEventResult.handled;
//       }
//       if (key == LogicalKeyboardKey.arrowLeft) {
//         // UI REFACTOR: Logic from WebSeries
//         return KeyEventResult.handled; // Do nothing
//       }
//       if (key == LogicalKeyboardKey.arrowRight && _channelFilterFocusNodes.isNotEmpty) { 
//         _channelFilterFocusNodes[0].requestFocus(); 
//         return KeyEventResult.handled;
//       }
//       if (key == LogicalKeyboardKey.arrowUp && _networkFocusNodes.isNotEmpty) {
//         _networkFocusNodes[_focusedNetworkIndex].requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
//          _focusFirstListItemWithScroll();
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.handled;
//     }

//     if ([ LogicalKeyboardKey.arrowUp, LogicalKeyboardKey.arrowDown, LogicalKeyboardKey.arrowLeft, LogicalKeyboardKey.arrowRight, LogicalKeyboardKey.select, LogicalKeyboardKey.enter ].contains(key)) {
//       if (networkHasFocus) { _navigateNetworks(key); }
//       else if (channelFilterHasFocus) { _navigateChannelFilters(key); } 
//       else if (listHasFocus) { _navigateList(key); } // UI REFACTOR: Uses new _navigateList
//       return KeyEventResult.handled;
//     }

//     return KeyEventResult.ignored;
//   }

//   // UI REFACTOR: _navigateList from WebSeries, adapted for TvShow state
//   void _navigateList(LogicalKeyboardKey key) {
//     // Agar navigation pehle se locked hai, to function se bahar nikal jao
//     if (_isNavigationLocked) return;

//     if (_focusedItemIndex == -1 || _itemFocusNodes.isEmpty) return;

//     // Navigation ko turant lock karo
//     setState(() {
//       _isNavigationLocked = true;
//     });

//     // Ek chota Timer set karo jo lock ko thodi der baad khol dega
//     // Yeh 700ms ka cooldown period dega
//     _navigationLockTimer = Timer(const Duration(milliseconds: 700), () {
//       if (mounted) {
//         setState(() {
//           _isNavigationLocked = false;
//         });
//       }
//     });

//     int newIndex = _focusedItemIndex;
    
//     if (key == LogicalKeyboardKey.arrowUp) {
//       setState(() => _lastNavigationDirection = 'vertical');
//       if (_channelFilterFocusNodes.isNotEmpty) {
//         _channelFilterFocusNodes[_focusedChannelFilterIndex].requestFocus();
//       } else {
//         _searchButtonFocusNode.requestFocus();
//       }
//       setState(() => _focusedItemIndex = -1);
      
//       // Lock aur timer ko cancel kar do kyunki hum list se bahar ja rahe hain
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();
//       return;

//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       // arrowDown par kuch nahi karna hai, isliye lock hata do
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();
//       return;

//     } else if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newIndex > 0) {
//         newIndex--;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       final currentList = _displayList; // Use TvShow state
//       if (newIndex + 1 < currentList.length) {
//         newIndex++;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
      
//       // Enter/Select par cooldown nahi chahiye, isliye lock turant hata do
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();

//       final currentList = _displayList; // Use TvShow state
//       _navigateToTvShowDetails(currentList[_focusedItemIndex], _focusedItemIndex); // Use TvShow navigation
//       return;
//     }

//     if (newIndex != _focusedItemIndex && newIndex >= 0 && newIndex < _itemFocusNodes.length) {
//       setState(() => _focusedItemIndex = newIndex);
//       _itemFocusNodes[newIndex].requestFocus();
//     } else {
//       // Agar index nahi badla (e.g., pehle item par left dabaya), to lock hata do
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();
//     }
//   }


//   // UI REFACTOR: _navigateNetworks from WebSeries, adapted for TvShow state
//   void _navigateNetworks(LogicalKeyboardKey key) {
//     int newIndex = _focusedNetworkIndex;
//     if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newIndex > 0) {
//         newIndex--;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       if (newIndex < _uniqueNetworks.length - 1) {
//         newIndex++;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       setState(() => _lastNavigationDirection = 'vertical');
//       // _updateSelectedNetwork(); // Don't update on down, only on select
//       _searchButtonFocusNode.requestFocus();
//       return;
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       _updateSelectedNetwork(); // Update on select
//       return;
//     }
//     if (newIndex != _focusedNetworkIndex) {
//       setState(() => _focusedNetworkIndex = newIndex);
//       _networkFocusNodes[newIndex].requestFocus();
//       _updateAndScrollToFocus(
//           _networkFocusNodes, newIndex, _networkScrollController, 160);
//     }
//   }

//   // UI REFACTOR: _navigateGenres from WebSeries, adapted for TvShow state
//   void _navigateChannelFilters(LogicalKeyboardKey key) {
//     final filterNames = _channelFilters.keys.toList();
    
//     // Agar filter list khali hai
//     if (filterNames.isEmpty) {
//         if (key == LogicalKeyboardKey.arrowLeft) {
//             _searchButtonFocusNode.requestFocus();
//         } else if (key == LogicalKeyboardKey.arrowUp && _networkFocusNodes.isNotEmpty) {
//              setState(() => _lastNavigationDirection = 'vertical');
//              _networkFocusNodes[_focusedNetworkIndex].requestFocus();
//         } else if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
//              setState(() => _lastNavigationDirection = 'vertical');
//               _focusFirstListItemWithScroll();
//         }
//         return; // Baaki keys ignore karein
//     }
    
//     int newIndex = _focusedChannelFilterIndex;
//     if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newIndex > 0) {
//         newIndex--;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       } else {
//         _searchButtonFocusNode.requestFocus();
//         return;
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       if (newIndex < filterNames.length - 1) {
//         newIndex++;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.arrowUp) {
//       if (_networkFocusNodes.isNotEmpty) {
//         setState(() => _lastNavigationDirection = 'vertical');
//         _networkFocusNodes[_focusedNetworkIndex].requestFocus();
//       }
//       return;
//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       setState(() => _lastNavigationDirection = 'vertical');
//       // _updateSelectedChannelFilter(); // Don't update on down, only on select
//       if (_itemFocusNodes.isNotEmpty) {
//         _focusFirstListItemWithScroll();
//       }
//       return;
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       _updateSelectedChannelFilter(); // Update on select
//       return;
//     }
//     if (newIndex != _focusedChannelFilterIndex) {
//       setState(() => _focusedChannelFilterIndex = newIndex);
//       _channelFilterFocusNodes[newIndex].requestFocus();
//       _updateAndScrollToFocus(
//           _channelFilterFocusNodes, newIndex, _channelFilterScrollController, 160); // 160 is approx width
//     }
//   }

//   // UI REFACTOR: _navigateKeyboard from WebSeries
//   KeyEventResult _navigateKeyboard(LogicalKeyboardKey key) {
//     int newRow = _focusedKeyRow;
//     int newCol = _focusedKeyCol;
//     if (key == LogicalKeyboardKey.arrowUp) {
//       if (newRow > 0) {
//         newRow--;
//         newCol = math.min(newCol, _keyboardLayout[newRow].length - 1);
//       }
//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       if (newRow < _keyboardLayout.length - 1) {
//         newRow++;
//         newCol = math.min(newCol, _keyboardLayout[newRow].length - 1);
//       }
//     } else if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newCol > 0) newCol--;
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       if (newCol < _keyboardLayout[newRow].length - 1) newCol++;
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       final keyValue = _keyboardLayout[newRow][newCol];
//       _onKeyPressed(keyValue);
//       return KeyEventResult.handled;
//     }

//     if (newRow != _focusedKeyRow || newCol != _focusedKeyCol) {
//       setState(() {
//         _focusedKeyRow = newRow;
//         _focusedKeyCol = newCol;
//       });
//       final focusIndex = _getFocusNodeIndexForKey(newRow, newCol);
//       if (focusIndex >= 0 && focusIndex < _keyboardFocusNodes.length) {
//         _keyboardFocusNodes[focusIndex].requestFocus();
//       }
//     }
//     return KeyEventResult.handled;
//   }

//   //=================================================
//   // SECTION 2.3: STATE MANAGEMENT & UI LOGIC
//   //=================================================

//   // Data logic (fetching, filtering) remains from TvShowSliderScreen
//   Future<void> _fetchDataForView() async {
//     _debounce?.cancel(); 

//     setState(() {
//       _isListLoading = true;
//       _displayList.clear(); 
//       _currentViewMasterList.clear(); 
//       _rebuildItemFocusNodes(); 
//       _errorMessage = null; 
      
//       _searchText = ''; 
//       _isSearching = false;
//     });

//     List<TvShowModel> newMasterList = [];

//     try {
//       if (_selectedChannelFilterId != null) {
//         final List<TvShowItemModel> showItems =
//             await _fetchTvShowsForChannel(_selectedChannelFilterId!);
        
//         newMasterList = showItems.map((show) => TvShowModel(
//               id: show.id,
//               name: show.name,
//               poster: show.thumbnail, 
//               banner: show.thumbnail, 
//               updatedAt: '', 
//               order: show.order, 
//               genre: show.genre,
//               language: null,
//             )).toList();
//         _isDisplayingShows = true; 
//       } else {
//         newMasterList = []; 
//         _isDisplayingShows = false;
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = "Failed to load data. Please try again.";
//           debugPrint("Error in _fetchDataForView: $e");
//         });
//         newMasterList = []; 
//       }
//     }

//     if (!mounted) return;

//     setState(() {
//       _currentViewMasterList = newMasterList; 
//       _displayList = List.from(_currentViewMasterList); 
//       _isListLoading = false; 
//       _rebuildItemFocusNodes(); 
//       _focusedItemIndex = -1; 
      
//       if (_displayList.isNotEmpty) {
//         _focusFirstListItemWithScroll();
//       }
//     });

//     _startAnimations();
//   }
  
//   // void _applySearchFilter() {
//   //   if (!mounted) return;

//   //   List<TvShowModel> filteredList = [];
//   //   if (_isSearching && _searchText.isNotEmpty) {
//   //     final searchTerm = _searchText.toLowerCase();
//   //     filteredList = _currentViewMasterList.where((item) {
//   //       return item.name.toLowerCase().contains(searchTerm);
//   //     }).toList();
//   //   } else {
//   //     filteredList = List.from(_currentViewMasterList);
//   //   }

//   //   setState(() {
//   //     _displayList = filteredList; 
//   //     _rebuildItemFocusNodes();
//   //     _focusedItemIndex = -1;

//   //     if (_displayList.isNotEmpty) {
//   //       _focusFirstListItemWithScroll();
//   //     }
//   //   });
//   //   _startAnimations();
//   // }



//   // NEW: Yeh function sirf search apply karta hai, data fetch nahi karta
//   void _applySearchFilter() {
//     if (!mounted) return;

//     List<TvShowModel> filteredList = [];
//     if (_isSearching && _searchText.isNotEmpty) {
//       final searchTerm = _searchText.toLowerCase();
//       // Search hamesha _currentViewMasterList mein hoga
//       filteredList = _currentViewMasterList.where((item) {
//         return item.name.toLowerCase().contains(searchTerm);
//       }).toList();
//     } else {
//       // Agar search khali hai, toh poori master list dikhayein
//       filteredList = List.from(_currentViewMasterList);
//     }

//     setState(() {
//       _displayList = filteredList; // Sirf display list update karein
//       _rebuildItemFocusNodes();
//       _focusedItemIndex = -1; // List index ko reset karein, lekin focus move na karein

//       // ===== FIX =====
//       // Neeche di gayi lines ko comment ya delete kar diya gaya hai
//       // Taaki focus keyboard par hi rahe
//       // if (_displayList.isNotEmpty) {
//       //   _focusFirstListItemWithScroll(); 
//       // }
//       // ===== END FIX =====
//     });
//     _startAnimations();
//   }

//   void _updateSelectedNetwork() async {
//      if (_apiNetworks.isEmpty || _focusedNetworkIndex >= _apiNetworks.length) return; 

//     final selectedNetwork = _apiNetworks[_focusedNetworkIndex];
//     _debounce?.cancel(); 

//     setState(() {
//       _isListLoading = true; 
//       _errorMessage = null; 
//        _displayList = []; 
//        _currentViewMasterList.clear();
//        _rebuildItemFocusNodes(); 
//        _isSearching = false; 
//        _searchText = '';
//     });

//     try {
//       final newChannelList = await _fetchTvShowsForNetwork(selectedNetwork.id);
//       if (!mounted) return;

//       setState(() {
//         _tvShowList = newChannelList; 
//         _selectedNetworkName = selectedNetwork.name;
//         _updateSelectedNetworkData(); 
        
//         _updateChannelFilters(); 
//         _rebuildChannelFilterFocusNodes();
//       });
      
//       await _fetchDataForView(); 
      
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isListLoading = false;
//           _errorMessage = "Failed to load channels for ${selectedNetwork.name}.";
//           _tvShowList = []; 
//           _displayList = [];
//           _currentViewMasterList.clear();
//            _updateChannelFilters(); 
//            _rebuildChannelFilterFocusNodes();
//             debugPrint("Error in _updateSelectedNetwork: $e");
//         });
//       }
//     }
//   }

//   void _updateSelectedChannelFilter() {
//     final filterNames = _channelFilters.keys.toList();
//     if (filterNames.isEmpty || _focusedChannelFilterIndex >= filterNames.length || _channelFilterFocusNodes.isEmpty) return;

//     _debounce?.cancel(); 

//     final newFilterName = filterNames[_focusedChannelFilterIndex];
//     if (newFilterName == _selectedChannelFilterName) return;

//     setState(() {
//       _selectedChannelFilterName = newFilterName;
//       _selectedChannelFilterId = _channelFilters[_selectedChannelFilterName];
//       _isDisplayingShows = (_selectedChannelFilterId != null);
      
//       _fetchDataForView();
//     });
//   }

//   void _updateSelectedNetworkData() {
//      if (_apiNetworks.isEmpty || _focusedNetworkIndex >= _apiNetworks.length) return; 

//     final selectedNetwork = _apiNetworks.firstWhere(
//         (n) => n.name == _selectedNetworkName,
//         orElse: () => ApiNetworkModel(id: -1, name: '', networksOrder: 9999));
        
//     final tvShowSliders = selectedNetwork.sliders
//         .where((s) => s.sliderFor == 'tvshows')
//         .toList();

//     setState(() {
//       _selectedNetworkLogo = selectedNetwork.logo;
//       _currentTvShowSliders = tvShowSliders; // Use TvShow variable
//       _currentSliderIndex = 0;
//       if (tvShowSliders.isNotEmpty) {
//         _currentBackgroundUrl = tvShowSliders.first.banner;
//       } else {
//         _currentBackgroundUrl = selectedNetwork.logo;
//       }
//     });

//     if (_sliderPageController.hasClients && _currentTvShowSliders.isNotEmpty) { // Use TvShow variable
//       _sliderPageController.jumpToPage(0);
//     }
//   }

//   void _updateChannelFilters() {
//     setState(() {
//       if (_tvShowList.isEmpty) {
//         _channelFilters = {}; 
//       } else {
//         final Map<String, int?> newFilters = {}; 
//         for (final channel in _tvShowList) {
//           if (channel.name.isNotEmpty && !newFilters.containsKey(channel.name)) {
//             newFilters[channel.name] = channel.id;
//           }
//         }
//         _channelFilters = newFilters;
//       }
      
//       if (_channelFilters.isNotEmpty) {
//         _selectedChannelFilterName = _channelFilters.keys.first;
//         _selectedChannelFilterId = _channelFilters.values.first;
//         _isDisplayingShows = true; 
//         _focusedChannelFilterIndex = 0;
//       } else {
//         _selectedChannelFilterName = '';
//         _selectedChannelFilterId = null;
//         _isDisplayingShows = false;
//         _focusedChannelFilterIndex = -1;
//       }

//       print("Updated Channel Filters: ${_channelFilters.keys.toList()}"); 
//     });
//   }


//   // UI REFACTOR: _onKeyPressed from WebSeries
//   void _onKeyPressed(String value) {
//     setState(() {
//       if (value == 'OK') {
//         _showKeyboard = false;
//         if (_itemFocusNodes.isNotEmpty) {
//           _itemFocusNodes.first.requestFocus();
//         } else {
//           _searchButtonFocusNode.requestFocus();
//         }
//         return;
//       }
//       if (value == 'DEL') {
//         if (_searchText.isNotEmpty) {
//           _searchText = _searchText.substring(0, _searchText.length - 1);
//         }
//       } else if (value == ' ') {
//         if (_searchText.isNotEmpty && !_searchText.endsWith(' ')) { // Logic from TvShow
//           _searchText += ' ';
//         }
//       } else {
//         _searchText += value;
//       }
//       _isSearching = _searchText.isNotEmpty; // TvShow logic
//       _debounce?.cancel(); // TvShow logic
//       _debounce = Timer(const Duration(milliseconds: 400), () { // TvShow logic
//         _applySearchFilter(); // TvShow logic
//       });
//     });
//   }

//   Future<void> _navigateToTvShowDetails(
//       TvShowModel item, int index) async { 
//     if (_isVideoLoading) return;
//     setState(() => _isVideoLoading = true);
    
//     try {
//       int? currentUserId = SessionManager.userId;
//       HistoryService.updateUserHistory(
//         userId: currentUserId!,
//         contentType: 4, 
//         eventId: item.id, 
//         eventTitle: item.name, 
//         url: '',
//         categoryId: 0,
//       ).catchError((e) { debugPrint("History update failed: $e"); });
//     } catch (e) { debugPrint("Error getting userId for History: $e"); }

//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TvShowFinalDetailsPage(
//           id: item.id, 
//           banner: item.banner ?? item.poster ?? '', 
//           poster: item.poster ?? item.banner ?? '', 
//           name: item.name, 
//         ),
//       ),
//     );

//     if (mounted) {
//       setState(() {
//         _isVideoLoading = false;
//          if (index >= 0 && index < _itemFocusNodes.length) { // Restore focus logic
//             _focusedItemIndex = index;
//              WidgetsBinding.instance.addPostFrameCallback((_) {
//                  if(mounted && _itemFocusNodes.isNotEmpty && _focusedItemIndex < _itemFocusNodes.length) {
//                    _itemFocusNodes[_focusedItemIndex].requestFocus();
//                    _updateAndScrollToFocus(
//                        _itemFocusNodes, _focusedItemIndex, _listScrollController, (bannerwdt * 1.2) + 12); // UI REFACTOR: Use 1.2 width
//                  }
//                });
//          } else {
//             _focusedItemIndex = -1;
//             if(_itemFocusNodes.isNotEmpty) { _focusFirstListItemWithScroll(); }
//             else if (_channelFilterFocusNodes.isNotEmpty && _focusedChannelFilterIndex >= 0) { _channelFilterFocusNodes[_focusedChannelFilterIndex].requestFocus(); } 
//             else { _searchButtonFocusNode.requestFocus(); }
//          }
//       });
//     }
//   }


//   //=================================================
//   // SECTION 2.4: INITIALIZATION AND CLEANUP
//   //=================================================

//   void _initializeAnimations() {
//     _fadeController =
//         AnimationController(duration: AnimationTiming.medium, vsync: this);
//     _fadeAnimation =
//         CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
//   }

//   void _startAnimations() {
//     _fadeController.reset(); // Reset from TvShow logic
//     _fadeController.forward();
//   }

//   void _initializeFocusNodes() {
//     _disposeFocusNodes(_networkFocusNodes);
//     _networkFocusNodes = List.generate(
//         _apiNetworks.length, (index) => FocusNode(debugLabel: 'Network-$index')..addListener(_setStateListener)); // Add listener
//     _rebuildChannelFilterFocusNodes();
//     _rebuildItemFocusNodes();
//     _rebuildKeyboardFocusNodes();
//   }

//   void _rebuildChannelFilterFocusNodes() {
//     _disposeFocusNodes(_channelFilterFocusNodes);
//     _channelFilterFocusNodes = List.generate(
//         _channelFilters.length, (index) => FocusNode(debugLabel: 'ChannelFilter-$index')..addListener(_setStateListener)); // Add listener
//   }

//   void _rebuildItemFocusNodes() {
//     _disposeFocusNodes(_itemFocusNodes);
//     final currentList = _displayList;
//     _itemFocusNodes = List.generate(
//         currentList.length, (index) => FocusNode(debugLabel: 'Item-$index')..addListener(_setStateListener)); // Add listener
//   }

//   void _rebuildKeyboardFocusNodes() {
//     _disposeFocusNodes(_keyboardFocusNodes);
//     int totalKeys =
//         _keyboardLayout.fold(0, (prev, row) => prev + row.length);
//     _keyboardFocusNodes =
//         List.generate(totalKeys, (index) => FocusNode(debugLabel: 'Key-$index')..addListener(_setStateListener)); // Add listener
//   }

//   int _getFocusNodeIndexForKey(int row, int col) {
//     int index = 0;
//     for (int r = 0; r < row; r++) {
//       index += _keyboardLayout[r].length;
//     }
//     return index + col;
//   }

//   // UI REFACTOR: Add _setStateListener
//   void _setStateListener() { if (mounted) { setState(() {}); } }

//   void _disposeFocusNodes(List<FocusNode> nodes) {
//     for (var node in nodes) {
//       node.removeListener(_setStateListener); // Remove listener
//       node.dispose();
//     }
//     nodes.clear(); // Clear from TvShow logic
//   }

//   // UI REFACTOR: _updateAndScrollToFocus from WebSeries
//   void _updateAndScrollToFocus(List<FocusNode> nodes, int index,
//       ScrollController controller, double itemWidth) {
//     if (!mounted ||
//         index < 0 ||
//         index >= nodes.length ||
//         !controller.hasClients) return;
//     double screenWidth = MediaQuery.of(context).size.width;
//     // Use WebSeries logic
//     double scrollPosition = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
//     controller.animateTo(
//       scrollPosition.clamp(0.0, controller.position.maxScrollExtent),
//       duration: AnimationTiming.fast,
//       curve: Curves.easeInOut,
//     );
//   }

//   //=================================================
//   // SECTION 2.5: WIDGET BUILDER METHODS
//   //=================================================

//   // UI REFACTOR: _buildPageContent from WebSeries
//   Widget _buildPageContent() {
//     return Padding(
//       // Use WebSeries padding
//       padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.02, vertical: screenhgt * 0.02),
//       child: Column(
//         children: [
//           _buildTopFilterBar(),
//           Expanded( // Use WebSeries layout
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: _buildContentBody(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // UI REFACTOR: _buildContentBody from WebSeries
//   Widget _buildContentBody() {
//     return Column(
//       children: [
//         SizedBox( // Keyboard placeholder
//           height: screenhgt * 0.5,
//           child: _showKeyboard ? _buildSearchUI() : const SizedBox.shrink(),
//         ),
//         _buildSliderIndicators(),
//         _buildChannelFilterAndSearchButtons(), // Renamed call
//         SizedBox(height: screenhgt * 0.02),
//         _buildTvShowList(), // Renamed call
//       ],
//     );
//   }
  
//   // UI REFACTOR: _buildBackgroundOrSlider from WebSeries
//   Widget _buildBackgroundOrSlider() {
//     if (_currentTvShowSliders.isNotEmpty) { // Use TvShow variable
//       return TvShowBannerSlider( // Use TvShow widget
//         sliders: _currentTvShowSliders, // Use TvShow variable
//         controller: _sliderPageController,
//         onPageChanged: (index) {
//           if (mounted) {
//             setState(() {
//               _currentSliderIndex = index;
//             });
//           }
//         },
//       );
//     } else {
//       return _buildDynamicBackground();
//     }
//   }

//   // UI REFACTOR: _buildDynamicBackground from WebSeries
//   Widget _buildDynamicBackground() {
//     return AnimatedSwitcher(
//       duration: AnimationTiming.medium,
//       child: _currentBackgroundUrl != null && _currentBackgroundUrl!.isNotEmpty
//           ? Container(
//               key: ValueKey<String>(_currentBackgroundUrl!),
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: NetworkImage(_currentBackgroundUrl!),
//                   fit: BoxFit.cover,
//                   onError: (exception, stackTrace) { // Added error handler
//                     debugPrint('Error loading background image: $_currentBackgroundUrl');
//                   },
//                 ),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.primaryDark.withOpacity(0.2),
//                       ProfessionalColors.primaryDark.withOpacity(0.4),
//                       ProfessionalColors.primaryDark.withOpacity(0.6),
//                       ProfessionalColors.primaryDark.withOpacity(0.9),
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     stops: const [0.0, 0.5, 0.7, 0.9],
//                   ),
//                 ),
//               ),
//             )
//           : Container(
//               key: const ValueKey<String>('no_bg'),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     ProfessionalColors.primaryDark,
//                     ProfessionalColors.surfaceDark,
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//             ),
//     );
//   }

//   // UI REFACTOR: _buildTopFilterBar from WebSeries
//   Widget _buildTopFilterBar() {
//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: EdgeInsets.only(
//             top: MediaQuery.of(context).padding.top + 5,
//             bottom: 5,
//             left: screenwdt * 0.015,
//             right: 0,
//           ),
//           decoration: BoxDecoration(
//             color: Colors.transparent,
//             border: Border(
//               bottom: BorderSide(
//                 color: Colors.white.withOpacity(0.1),
//                 width: 1,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               Expanded(child: _buildNetworkFilter()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // UI REFACTOR: _buildNetworkFilter from WebSeries
//   Widget _buildNetworkFilter() {
//     return SizedBox(
//       height: 30,
//       child: Center(
//         child: ListView.builder(
//           controller: _networkScrollController,
//           scrollDirection: Axis.horizontal,
//           itemCount: _uniqueNetworks.length,
//           itemBuilder: (context, index) {
//             if (index >= _networkFocusNodes.length) return const SizedBox.shrink(); // Guard
//             final networkName = _uniqueNetworks[index];
//             final focusNode = _networkFocusNodes[index];
//             final isSelected = _selectedNetworkName == networkName;
            
//             return Focus(
//               focusNode: focusNode,
//               onFocusChange: (hasFocus) {
//                 if (hasFocus) {
//                   setState(() => _focusedNetworkIndex = index);
//                   // Scroll is handled by _navigateNetworks
//                 }
//               },
//               child: _buildGlassEffectButton( // Use WebSeries button
//                 focusNode: focusNode,
//                 isSelected: isSelected,
//                 focusColor: _focusColors[index % _focusColors.length],
//                 onTap: () {
//                   setState(() => _focusedNetworkIndex = index);
//                   focusNode.requestFocus();
//                   _updateSelectedNetwork();
//                 },
//                 child: Text(
//                   networkName.toUpperCase(),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: focusNode.hasFocus || isSelected
//                         ? FontWeight.bold
//                         : FontWeight.w500,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // UI REFACTOR: _buildGenreAndSearchButtons from WebSeries, adapted for TvShow state
//   Widget _buildChannelFilterAndSearchButtons() {
//     final filterNames = _channelFilters.keys.toList();

//     if (filterNames.isEmpty && !_isSearching) {
//       return const SizedBox(height: 30); // Keep height consistent
//     }
    
//     // Removed _isGenreLoading check

//     return SizedBox(
//       height: 30,
//       child: Center(
//         child: ListView.builder(
//           controller: _channelFilterScrollController,
//           scrollDirection: Axis.horizontal,
//           itemCount: filterNames.length + 1, // +1 for Search button
//           padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.015),
//           itemBuilder: (context, index) {
//             if (index == 0) { // Search Button
//               return Focus(
//                 focusNode: _searchButtonFocusNode,
//                 child: _buildGlassEffectButton(
//                   focusNode: _searchButtonFocusNode,
//                   isSelected: _isSearching || _showKeyboard, // Use TvShow logic
//                   focusColor: ProfessionalColors.accentOrange,
//                   onTap: () {
//                     _searchButtonFocusNode.requestFocus();
//                     setState(() {
//                       _showKeyboard = true;
//                       _focusedKeyRow = 0;
//                       _focusedKeyCol = 0;
//                     });
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       if (mounted && _keyboardFocusNodes.isNotEmpty) {
//                         _keyboardFocusNodes[0].requestFocus();
//                       }
//                     });
//                   },
//                   child:  Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.search, color: Colors.white),
//                       SizedBox(width: 8),
//                       Text(
//                         ("Search").toUpperCase(),
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold, // Always bold
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }

//             // Channel Filter Buttons
//             final filterIndex = index - 1;
//             if (filterIndex >= filterNames.length || filterIndex >= _channelFilterFocusNodes.length) {
//               return const SizedBox.shrink(); // Guard
//             }
//             final filterName = filterNames[filterIndex];
//             final focusNode = _channelFilterFocusNodes[filterIndex];
//             final isSelected = !_isSearching && _selectedChannelFilterName == filterName;

//             return Focus(
//               focusNode: focusNode,
//               onFocusChange: (hasFocus) {
//                  if (hasFocus) {
//                   setState(() => _focusedChannelFilterIndex = filterIndex);
//                   // Scroll is handled by _navigateChannelFilters
//                 }
//               },
//               child: _buildGlassEffectButton(
//                 focusNode: focusNode,
//                 isSelected: isSelected,
//                 focusColor: _focusColors[filterIndex % _focusColors.length],
//                 onTap: () {
//                   setState(() => _focusedChannelFilterIndex = filterIndex);
//                   focusNode.requestFocus();
//                   _updateSelectedChannelFilter();
//                 },
//                 child: Text(
//                   filterName.toUpperCase(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold, // Always bold
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // UI REFACTOR: _buildWebSeriesList from WebSeries, adapted for TvShow state
//   Widget _buildTvShowList() {
//     final currentList = _displayList;

//     // Removed _isSearchLoading check
    
//     if (currentList.isEmpty && !_isListLoading) { // Check global list loading
//       return Expanded(
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(15),
//             margin: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: ProfessionalColors.surfaceDark.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.white.withOpacity(0.1)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.tv_off_rounded,
//                   size: 25,
//                   color: ProfessionalColors.textSecondary,
//                 ),
//                 Text(
//                   _isSearching && _searchText.isNotEmpty
//                       ? "No results found for '$_searchText'"
//                       : 'No items available for this filter.', // Updated text
//                   style: const TextStyle(
//                     color: ProfessionalColors.textSecondary,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
    
//     // UI REFACTOR: Use Expanded to fill space
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.only(top: 1.0),
//         child: ListView.builder(
//           controller: _listScrollController,
//           clipBehavior: Clip.none,
//           scrollDirection: Axis.horizontal,
//           padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.015),
//           itemCount: currentList.length,
//           itemBuilder: (context, index) {
//             if (index >= _itemFocusNodes.length) return const SizedBox.shrink(); // Guard
//             final item = currentList[index];
//             final focusNode = _itemFocusNodes[index];
            
//             return Container(
//               width: bannerwdt * 1.2, // Use WebSeries width
//               margin: const EdgeInsets.only(right: 12.0),
//               child: InkWell(
//                 focusNode: focusNode,
//                 onTap: () => _navigateToTvShowDetails(item, index),
//                 onFocusChange: (hasFocus) {
//                   if (hasFocus) {
//                     setState(() => _focusedItemIndex = index);
//                     _updateAndScrollToFocus(
//                         _itemFocusNodes, index, _listScrollController, (bannerwdt * 1.2) + 12);
//                   }
//                 },
//                 child: OptimizedTvShowCard( // Use new card
//                   tvShow: item, // Pass TvShowModel
//                   isFocused: _focusedItemIndex == index,
//                   onTap: () =>
//                       _navigateToTvShowDetails(item, index),
//                   cardHeight: bannerhgt * 1.2, // Use WebSeries height
//                   networkLogo: _isDisplayingShows ? null : _selectedNetworkLogo, // Keep TvShow logic
//                   uniqueIndex: index,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // UI REFACTOR: _buildSearchUI from WebSeries
//   Widget _buildSearchUI() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           flex: 4,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ShaderMask(
//                   blendMode: BlendMode.srcIn,
//                   shaderCallback: (bounds) => const LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple,
//                     ],
//                   ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
//                   child: Text(
//                     "Search in $_selectedChannelFilterName", // Use TvShow text
//                     style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                     maxLines: 2, // Allow wrapping
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Container(
//                   width: double.infinity,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: ProfessionalColors.accentPurple, width: 2),
//                   ),
//                   child: Text(
//                     _searchText.isEmpty ? 'Start typing...' : _searchText,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: _searchText.isEmpty ? Colors.white54 : Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Expanded(
//           flex: 6,
//           child: _buildQwertyKeyboard(),
//         ),
//       ],
//     );
//   }

//   // UI REFACTOR: _buildQwertyKeyboard from WebSeries
//   Widget _buildQwertyKeyboard() {
//     return Container(
//       color: Colors.transparent,
//       padding: const EdgeInsets.all(5),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           for (int rowIndex = 0; rowIndex < _keyboardLayout.length; rowIndex++)
//             _buildKeyboardRow(_keyboardLayout[rowIndex], rowIndex),
//         ],
//       ),
//     );
//   }

//   // UI REFACTOR: _buildKeyboardRow from WebSeries
//   Widget _buildKeyboardRow(List<String> keys, int rowIndex) {
//     int startIndex = _getFocusNodeIndexForKey(rowIndex, 0); // Use TvShow function

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: keys.asMap().entries.map((entry) {
//         final colIndex = entry.key;
//         final key = entry.value;
//         if (startIndex + colIndex >= _keyboardFocusNodes.length) return const SizedBox.shrink(); // Guard
//         final focusIndex = startIndex + colIndex;
//         final focusNode = _keyboardFocusNodes[focusIndex];
//         final isFocused = _focusedKeyRow == rowIndex && _focusedKeyCol == colIndex;
//         final screenWidth = MediaQuery.of(context).size.width;
//         final screenHeight = MediaQuery.of(context).size.height;
//         double width;
//         if (key == ' ') {
//           width = screenWidth * 0.315;
//         } else if (key == 'OK' || key == 'DEL') {
//           width = screenWidth * 0.09;
//         } else {
//           width = screenWidth * 0.045;
//         }

//         return Container(
//           width: width,
//           height: screenHeight * 0.08,
//           margin: const EdgeInsets.all(4.0),
//           child: Focus(
//             focusNode: focusNode,
//             onFocusChange: (hasFocus) {
//               if (hasFocus) {
//                 setState(() {
//                   _focusedKeyRow = rowIndex;
//                   _focusedKeyCol = colIndex;
//                 });
//               }
//             },
//             child: ElevatedButton(
//               onPressed: () => _onKeyPressed(key),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isFocused
//                     ? ProfessionalColors.accentPurple
//                     : Colors.white.withOpacity(0.1),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                   side: isFocused
//                       ? const BorderSide(color: Colors.white, width: 3)
//                       : BorderSide.none,
//                 ),
//                 padding: EdgeInsets.zero,
//               ),
//               child: Text(
//                 key,
//                 style: TextStyle(
//                   fontSize: 22.0,
//                   fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // UI REFACTOR: _buildSliderIndicators from WebSeries
//   Widget _buildSliderIndicators() {
//     if (_currentTvShowSliders.length <= 1) { // Use TvShow variable
//       return const SizedBox(height: 28); // Match WebSeries height (10+8+10)
//     }
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(_currentTvShowSliders.length, (index) { // Use TvShow variable
//         bool isActive = _currentSliderIndex == index;
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
//           height: 8.0,
//           width: isActive ? 24.0 : 8.0,
//           decoration: BoxDecoration(
//             color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
//             borderRadius: BorderRadius.circular(12),
//           ),
//         );
//       }),
//     );
//   }

//   // UI REFACTOR: _buildGlassEffectButton from WebSeries
//   Widget _buildGlassEffectButton({
//     required FocusNode focusNode,
//     required VoidCallback onTap,
//     required bool isSelected,
//     required Color focusColor,
//     required Widget child,
//   }) {
//     bool hasFocus = focusNode.hasFocus;
//     bool isHighlighted = hasFocus || isSelected;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(right: 15),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(30),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
//               decoration: BoxDecoration(
//                 color: hasFocus
//                     ? focusColor
//                     : isSelected
//                         ? focusColor.withOpacity(0.5)
//                         : Colors.white.withOpacity(0.08),
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.black.withOpacity(0.25),
//                     Colors.white.withOpacity(0.1),
//                   ],
//                   stops: const [0.0, 0.8],
//                 ),
//                 borderRadius: BorderRadius.circular(30),
//                 border: Border.all(
//                   color: hasFocus ? Colors.white : Colors.white.withOpacity(0.3),
//                   width: hasFocus ? 3 : 2,
//                 ),
//                 boxShadow: isHighlighted
//                     ? [
//                         BoxShadow(
//                           color: focusColor.withOpacity(0.8),
//                           blurRadius: 15,
//                           spreadRadius: 3,
//                         )
//                       ]
//                     : null,
//               ),
//               child: child,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // UI REFACTOR: _buildErrorWidget from WebSeries
//   Widget _buildErrorWidget() {
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.all(40),
//         padding: const EdgeInsets.all(32),
//         decoration: BoxDecoration(
//           color: ProfessionalColors.surfaceDark.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(color: Colors.white.withOpacity(0.1)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.red.withOpacity(0.1),
//               ),
//               child: const Icon(
//                 Icons.cloud_off_rounded,
//                 color: Colors.red,
//                 size: 60,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               _errorMessage ?? 'Something went wrong.',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: ProfessionalColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               focusNode: FocusNode(), // An unfocusable node
//               onPressed: () => _fetchDataForPage(forceRefresh: true),
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Try Again'),
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 backgroundColor: ProfessionalColors.accentBlue,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// }

// //==============================================================================
// // SECTION 3: REUSABLE UI COMPONENTS
// //==============================================================================

// // UI REFACTOR: OptimizedTvShowCard based on WebSeries card
// class OptimizedTvShowCard extends StatelessWidget {
//   final TvShowModel tvShow; // Use TvShowModel
//   final bool isFocused;
//   final VoidCallback onTap;
//   final double cardHeight;
//   final String? networkLogo;
//   final int uniqueIndex;

//   const OptimizedTvShowCard({
//     Key? key,
//     required this.tvShow, // Use TvShowModel
//     required this.isFocused,
//     required this.onTap,
//     required this.cardHeight,
//     this.networkLogo,
//     required this.uniqueIndex,
//   }) : super(key: key);

//   final List<Color> _focusColors = const [
//     ProfessionalColors.accentBlue,
//     ProfessionalColors.accentPurple,
//     ProfessionalColors.accentPink,
//     ProfessionalColors.accentOrange,
//     ProfessionalColors.accentRed
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final focusColor = _focusColors[uniqueIndex % _focusColors.length];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         SizedBox(
//           height: cardHeight,
//           child: AnimatedContainer(
//             duration: AnimationTiming.fast,
//             transform: isFocused
//                 ? (Matrix4.identity()..scale(1.05))
//                 : Matrix4.identity(),
//             transformAlignment: Alignment.center,
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8.0),
//                 border: isFocused
//                     ? Border.all(color: focusColor, width: 3)
//                     : Border.all(color: Colors.transparent, width: 3),
//                 boxShadow: isFocused
//                     ? [
//                         BoxShadow(
//                             color: focusColor.withOpacity(0.5),
//                             blurRadius: 12,
//                             spreadRadius: 1)
//                       ]
//                     : []),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(6.0),
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   _buildTvShowImage(), // Use updated image builder
//                   if (isFocused)
//                     Positioned(
//                         left: 5,
//                         top: 5,
//                         child: Container(
//                             color: Colors.black.withOpacity(0.4),
//                             child: Icon(Icons.play_circle_filled_outlined,
//                                 color: focusColor, size: 40))),
//                   if (networkLogo != null && networkLogo!.isNotEmpty)
//                     Positioned(
//                         top: 5,
//                         right: 5,
//                         child: CircleAvatar(
//                             radius: 12,
//                             backgroundImage: NetworkImage(networkLogo!),
//                             backgroundColor: Colors.black54)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 8.0, left: 2.0, right: 2.0),
//           child: Text(tvShow.name, // Use tvShow.name
//               style: TextStyle(
//                   color: isFocused
//                       ? focusColor
//                       : ProfessionalColors.textSecondary,
//                   fontSize: 14,
//                   fontWeight: isFocused ? FontWeight.bold : FontWeight.normal),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis),
//         ),
//       ],
//     );
//   }

//   // UI REFACTOR: _buildWebSeriesImage from WebSeries, adapted
//   Widget _buildTvShowImage() {
//     final imageUrl = tvShow.poster; // Use tvShow.poster
    
//     return imageUrl != null && imageUrl.isNotEmpty
//         ? Image.network(
//             imageUrl,
//             fit: BoxFit.contain, // Keep 'contain' from TvShow logic for logos
//             // `loadingBuilder` ka istemal placeholder dikhane ke liye kiya gaya hai.
//             loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//               if (loadingProgress == null) return child;
//               return _buildImagePlaceholder();
//             },
//             // `errorBuilder` ka istemal error hone par placeholder dikhane ke liye kiya gaya hai.
//             errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
//               debugPrint('Error loading item image: $imageUrl, Error: $exception');
//               return _buildImagePlaceholder();
//             },
//           )
//         : _buildImagePlaceholder();
//   }
  
//   // UI REFACTOR: _buildImagePlaceholder from WebSeries
//   Widget _buildImagePlaceholder() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             ProfessionalColors.accentGreen, // Use WebSeries colors
//             ProfessionalColors.accentBlue,
//           ],
//         ),
//       ),
//       child: const Icon(
//         Icons.tv_rounded, // Use TvShow icon
//         color: Colors.white,
//         size: 24,
//       ),
//     );
//   }
// }

// // UI REFACTOR: TvShowBannerSlider based on WebSeries
// class TvShowBannerSlider extends StatefulWidget {
//   final List<SliderModel> sliders;
//   final ValueChanged<int> onPageChanged;
//   final PageController controller;

//   const TvShowBannerSlider({
//     Key? key,
//     required this.sliders,
//     required this.onPageChanged,
//     required this.controller,
//   }) : super(key: key);

//   @override
//   _TvShowBannerSliderState createState() => _TvShowBannerSliderState();
// }

// class _TvShowBannerSliderState extends State<TvShowBannerSlider> {
//   Timer? _timer;
//   double _opacity = 1.0; // From WebSeries

//   @override
//   void initState() {
//     super.initState();
//     if (widget.sliders.length > 1) {
//       _startTimer();
//     }
//   }

//   @override
//   void didUpdateWidget(TvShowBannerSlider oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.sliders.length != widget.sliders.length) {
//       _timer?.cancel();
//       if (widget.sliders.length > 1) {
//         _startTimer();
//       }
//     }
//   }

//   void _startTimer() {
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 8), (timer) { // Use WebSeries 8s duration
//       if (!mounted || !widget.controller.hasClients || widget.sliders.length <= 1) return;

//       int currentPage = widget.controller.page?.round() ?? 0;
//       int nextPage = (currentPage + 1) % widget.sliders.length;

//       widget.controller.animateToPage(
//         nextPage,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.sliders.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return AnimatedOpacity( // Use WebSeries opacity
//       opacity: _opacity,
//       duration: const Duration(milliseconds: 400),
//       child: PageView.builder(
//         controller: widget.controller,
//         itemCount: widget.sliders.length,
//         onPageChanged: widget.onPageChanged,
//         itemBuilder: (context, index) {
//           final slider = widget.sliders[index];
//           return Stack(
//             fit: StackFit.expand,
//             children: [
//               Image.network(
//                 slider.banner,
//                 fit: BoxFit.cover,
//                 loadingBuilder: (context, child, progress) =>  
//                     progress == null ? child : Container(color: ProfessionalColors.surfaceDark),
//                 errorBuilder: (context, error, stackTrace) {
//                    debugPrint('Error loading slider image: ${slider.banner}');
//                    return Container(color: ProfessionalColors.surfaceDark);
//                 },
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.primaryDark.withOpacity(0.2),
//                       ProfessionalColors.primaryDark.withOpacity(0.4),
//                       ProfessionalColors.primaryDark.withOpacity(0.6),
//                       ProfessionalColors.primaryDark.withOpacity(0.9),
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     stops: const [0.0, 0.5, 0.7, 0.9], // Use WebSeries stops
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }





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
class TvShowModel { // Naam TvShowModel hi rakhte hain consistency ke liye
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

class TvShowSliderScreen extends StatefulWidget {
  final String title;
  final int? initialNetworkId; // ✅ YEH ADD KIYA GAYA HAI

  const TvShowSliderScreen({
    Key? key, 
    this.title = 'All TV Shows',
    this.initialNetworkId, // ✅ YEH ADD KIYA GAYA HAI
    })
      : super(key: key);

  @override
  _TvShowSliderScreenState createState() =>
      _TvShowSliderScreenState();
}

class _TvShowSliderScreenState
    extends State<TvShowSliderScreen>
    with SingleTickerProviderStateMixin {
  List<TvShowModel> _tvShowList = []; // Yeh ab Channels ki MASTER list hogi (Network change par update hoti hai)
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
  
  Map<String, int?> _channelFilters = {}; // Holds "Channel Name" -> Channel ID ("All" removed)
  String _selectedChannelFilterName = ''; // Default empty
  int? _selectedChannelFilterId; // Default null
  bool _isDisplayingShows = false;  

  List<TvShowModel> _currentViewMasterList = []; // NEW: Holds all items for the current filter (pre-search)
  List<TvShowModel> _displayList = []; // List jo UI mein render hogi (ya toh channels ya shows)
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
            if (_isVideoLoading && _errorMessage == null) // Detail page navigation
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
      fetchedNetworks.sort((a, b) => a.networksOrder.compareTo(b.networksOrder));

      if (fetchedNetworks.isEmpty) {
        throw Exception("No networks found.");
      }

      // ✅ --- START: YAHAN BADLAAV KIYA GAYA HAI ---
      
      // Initial network ID aur index dhoondhein
      int initialIndex = 0;
      int networkIdToFetch;

      if (widget.initialNetworkId != null) {
        int foundIndex = fetchedNetworks.indexWhere((n) => n.id == widget.initialNetworkId);
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
      final fetchedList = await _fetchTvShowsForNetwork(networkIdToFetch); // <-- NAYA
      
      // ✅ --- END: BADLAAV KHATAM ---

      if (!mounted) return;


      setState(() {
        _tvShowList = fetchedList;  
        if (_tvShowList.isEmpty) _errorMessage = "No TV Channels Found for this network."; // Updated message
      });

      if (_errorMessage == null) {
        _processInitialData();  
        _updateChannelFilters(); // This will select the first channel
        await _fetchDataForView(); // Fetch shows for the first channel
        _initializeFocusNodes();
        _startAnimations();

        // ✅ --- START: YAHAN BADLAAV KIYA GAYA HAI ---
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _networkFocusNodes.isNotEmpty && _focusedNetworkIndex < _networkFocusNodes.length) {
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
      var url = Uri.parse(SessionManager.baseUrl + 'getTvChannels?content_network=$networkId');
      final response = await https.get(url,
        // Uri.parse('https://dashboard.cpplayers.com/api/v3/getTvChannels?content_network=$networkId'),
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
            .map(
                (item) => TvShowModel.fromJson(item as Map<String, dynamic>))  
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
      var url = Uri.parse(SessionManager.baseUrl + 'getTvShows/$channelId');
    try {
      final response = await https.get(  url,
        // Uri.parse('https://dashboard.cpplayers.com/api/v2/getTvShows/$channelId'),
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
            .map((item) => TvShowItemModel.fromJson(item as Map<String, dynamic>))
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
            body: json.encode({"network_id": "", "data_for": "tvshows"}),  
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
      if (event is! RawKeyDownEvent || _isListLoading || _isLoading) return KeyEventResult.ignored;

    bool searchHasFocus = _searchButtonFocusNode.hasFocus;
    bool networkHasFocus = _networkFocusNodes.any((n) => n.hasFocus);
    bool channelFilterHasFocus = _channelFilterFocusNodes.any((n) => n.hasFocus);
    bool listHasFocus = _itemFocusNodes.any((n) => n.hasFocus);
    bool keyboardHasFocus = _keyboardFocusNodes.any((n) => n.hasFocus);
    final LogicalKeyboardKey key = event.logicalKey;

    if (key == LogicalKeyboardKey.goBack) {
      if (_showKeyboard) {
        setState(() { _showKeyboard = false; _focusedKeyRow = 0; _focusedKeyCol = 0; });
        _searchButtonFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (listHasFocus || channelFilterHasFocus || searchHasFocus) {  
          if (_networkFocusNodes.isNotEmpty) { _networkFocusNodes[_focusedNetworkIndex].requestFocus(); }
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (keyboardHasFocus && _showKeyboard) { return _navigateKeyboard(key); }

    if (searchHasFocus) {
      if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
        setState(() { _showKeyboard = true; _focusedKeyRow = 0; _focusedKeyCol = 0; });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _keyboardFocusNodes.isNotEmpty) { _keyboardFocusNodes[0].requestFocus(); }
        });
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowLeft) {
        // UI REFACTOR: Logic from WebSeries
        return KeyEventResult.handled; // Do nothing
      }
      if (key == LogicalKeyboardKey.arrowRight && _channelFilterFocusNodes.isNotEmpty) {  
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

    if ([ LogicalKeyboardKey.arrowUp, LogicalKeyboardKey.arrowDown, LogicalKeyboardKey.arrowLeft, LogicalKeyboardKey.arrowRight, LogicalKeyboardKey.select, LogicalKeyboardKey.enter ].contains(key)) {
      if (networkHasFocus) { _navigateNetworks(key); }
      else if (channelFilterHasFocus) { _navigateChannelFilters(key); }  
      else if (listHasFocus) { _navigateList(key); } // UI REFACTOR: Uses new _navigateList
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
      _navigateToTvShowDetails(currentList[_focusedItemIndex], _focusedItemIndex); // Use TvShow navigation
      return;
    }

    if (newIndex != _focusedItemIndex && newIndex >= 0 && newIndex < _itemFocusNodes.length) {
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
        } else if (key == LogicalKeyboardKey.arrowUp && _networkFocusNodes.isNotEmpty) {
            setState(() => _lastNavigationDirection = 'vertical');
            _networkFocusNodes[_focusedNetworkIndex].requestFocus();
        } else if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
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
      _updateAndScrollToFocus(
          _channelFilterFocusNodes, newIndex, _channelFilterScrollController, 160); // 160 is approx width
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
        
        newMasterList = showItems.map((show) => TvShowModel(
              id: show.id,
              name: show.name,
              poster: show.thumbnail,  
              banner: show.thumbnail,  
              updatedAt: '',  
              order: show.order,  
              genre: show.genre,
              language: null,
            )).toList();
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
      _focusedItemIndex = -1; // List index ko reset karein, lekin focus move na karein

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
      if (_apiNetworks.isEmpty || _focusedNetworkIndex >= _apiNetworks.length) return;  

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
          _errorMessage = "Failed to load channels for ${selectedNetwork.name}.";
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
    if (filterNames.isEmpty || _focusedChannelFilterIndex >= filterNames.length || _channelFilterFocusNodes.isEmpty) return;

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
      if (_apiNetworks.isEmpty || _focusedNetworkIndex >= _apiNetworks.length) return;  

    final selectedNetwork = _apiNetworks.firstWhere(
        (n) => n.name == _selectedNetworkName,
        orElse: () => ApiNetworkModel(id: -1, name: '', networksOrder: 9999));
        
    final tvShowSliders = selectedNetwork.sliders
        .where((s) => s.sliderFor == 'tvshows')
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

    if (_sliderPageController.hasClients && _currentTvShowSliders.isNotEmpty) { // Use TvShow variable
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
          if (channel.name.isNotEmpty && !newFilters.containsKey(channel.name)) {
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
        if (_searchText.isNotEmpty && !_searchText.endsWith(' ')) { // Logic from TvShow
          _searchText += ' ';
        }
      } else {
        _searchText += value;
      }
      _isSearching = _searchText.isNotEmpty; // TvShow logic
      _debounce?.cancel(); // TvShow logic
      _debounce = Timer(const Duration(milliseconds: 400), () { // TvShow logic
        _applySearchFilter(); // TvShow logic
      });
    });
  }

  Future<void> _navigateToTvShowDetails(
      TvShowModel item, int index) async {  
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
      ).catchError((e) { debugPrint("History update failed: $e"); });
    } catch (e) { debugPrint("Error getting userId for History: $e"); }

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
          if (index >= 0 && index < _itemFocusNodes.length) { // Restore focus logic
            _focusedItemIndex = index;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                  if(mounted && _itemFocusNodes.isNotEmpty && _focusedItemIndex < _itemFocusNodes.length) {
                    _itemFocusNodes[_focusedItemIndex].requestFocus();
                    _updateAndScrollToFocus(
                        _itemFocusNodes, _focusedItemIndex, _listScrollController, (bannerwdt * 1.2) + 12); // UI REFACTOR: Use 1.2 width
                  }
                });
          } else {
            _focusedItemIndex = -1;
            if(_itemFocusNodes.isNotEmpty) { _focusFirstListItemWithScroll(); }
            else if (_channelFilterFocusNodes.isNotEmpty && _focusedChannelFilterIndex >= 0) { _channelFilterFocusNodes[_focusedChannelFilterIndex].requestFocus(); }  
            else { _searchButtonFocusNode.requestFocus(); }
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
        _apiNetworks.length, (index) => FocusNode(debugLabel: 'Network-$index')..addListener(_setStateListener)); // Add listener
    _rebuildChannelFilterFocusNodes();
    _rebuildItemFocusNodes();
    _rebuildKeyboardFocusNodes();
  }

  void _rebuildChannelFilterFocusNodes() {
    _disposeFocusNodes(_channelFilterFocusNodes);
    _channelFilterFocusNodes = List.generate(
        _channelFilters.length, (index) => FocusNode(debugLabel: 'ChannelFilter-$index')..addListener(_setStateListener)); // Add listener
  }

  void _rebuildItemFocusNodes() {
    _disposeFocusNodes(_itemFocusNodes);
    final currentList = _displayList;
    _itemFocusNodes = List.generate(
        currentList.length, (index) => FocusNode(debugLabel: 'Item-$index')..addListener(_setStateListener)); // Add listener
  }

  void _rebuildKeyboardFocusNodes() {
    _disposeFocusNodes(_keyboardFocusNodes);
    int totalKeys =
        _keyboardLayout.fold(0, (prev, row) => prev + row.length);
    _keyboardFocusNodes =
        List.generate(totalKeys, (index) => FocusNode(debugLabel: 'Key-$index')..addListener(_setStateListener)); // Add listener
  }

  int _getFocusNodeIndexForKey(int row, int col) {
    int index = 0;
    for (int r = 0; r < row; r++) {
      index += _keyboardLayout[r].length;
    }
    return index + col;
  }

  // UI REFACTOR: Add _setStateListener
  void _setStateListener() { if (mounted) { setState(() {}); } }

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

  // UI REFACTOR: _buildPageContent from WebSeries
  Widget _buildPageContent() {
    return Padding(
      // Use WebSeries padding
      padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.02, vertical: screenhgt * 0.02),
      child: Column(
        children: [
          _buildTopFilterBar(),
          Expanded( // Use WebSeries layout
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
        SizedBox( // Keyboard placeholder
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
    if (_currentTvShowSliders.isNotEmpty) { // Use TvShow variable
      return TvShowBannerSlider( // Use TvShow widget
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
                  onError: (exception, stackTrace) { // Added error handler
                    debugPrint('Error loading background image: $_currentBackgroundUrl');
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
            if (index >= _networkFocusNodes.length) return const SizedBox.shrink(); // Guard
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
              child: _buildGlassEffectButton( // Use WebSeries button
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
            if (index == 0) { // Search Button
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
                  child:  Row(
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
            if (filterIndex >= filterNames.length || filterIndex >= _channelFilterFocusNodes.length) {
              return const SizedBox.shrink(); // Guard
            }
            final filterName = filterNames[filterIndex];
            final focusNode = _channelFilterFocusNodes[filterIndex];
            final isSelected = !_isSearching && _selectedChannelFilterName == filterName;

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
    
    if (currentList.isEmpty && !_isListLoading) { // Check global list loading
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
          padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.015),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            if (index >= _itemFocusNodes.length) return const SizedBox.shrink(); // Guard
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
                    _updateAndScrollToFocus(
                        _itemFocusNodes, index, _listScrollController, (bannerwdt * 1.2) + 12);
                  }
                },
                child: OptimizedTvShowCard( // Use new card
                  tvShow: item, // Pass TvShowModel
                  isFocused: _focusedItemIndex == index,
                  onTap: () =>
                      _navigateToTvShowDetails(item, index),
                  cardHeight: bannerhgt * 1.2, // Use WebSeries height
                  networkLogo: _isDisplayingShows ? null : _selectedNetworkLogo, // Keep TvShow logic
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
                  ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
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
    int startIndex = _getFocusNodeIndexForKey(rowIndex, 0); // Use TvShow function

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.asMap().entries.map((entry) {
        final colIndex = entry.key;
        final key = entry.value;
        if (startIndex + colIndex >= _keyboardFocusNodes.length) return const SizedBox.shrink(); // Guard
        final focusIndex = startIndex + colIndex;
        final focusNode = _keyboardFocusNodes[focusIndex];
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
    if (_currentTvShowSliders.length <= 1) { // Use TvShow variable
      return const SizedBox(height: 28); // Match WebSeries height (10+8+10)
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_currentTvShowSliders.length, (index) { // Use TvShow variable
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

  // UI REFACTOR: _buildWebSeriesImage from WebSeries, adapted
  Widget _buildTvShowImage() {
    final imageUrl = tvShow.poster; // Use tvShow.poster
    
    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            fit: BoxFit.fill, // Keep 'contain' from TvShow logic for logos
            // `loadingBuilder` ka istemal placeholder dikhane ke liye kiya gaya hai.
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildImagePlaceholder();
            },
            // `errorBuilder` ka istemal error hone par placeholder dikhane ke liye kiya gaya hai.
            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
              debugPrint('Error loading item image: $imageUrl, Error: $exception');
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
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) { // Use WebSeries 8s duration
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

    return AnimatedOpacity( // Use WebSeries opacity
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
                loadingBuilder: (context, child, progress) =>  
                    progress == null ? child : Container(color: ProfessionalColors.surfaceDark),
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