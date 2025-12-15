// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data'; // Required for Uint8List (kTransparentImage)
// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart'; // ✅ Re-enabled
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:math' as math;
// import 'package:http/http.dart' as https;

// // NOTE: Update imports according to your project structure
// // import 'package:mobi_tv_entertainment/components/home_screen_pages/religious/religious_final_details_page.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel_details_page.dart';
// import 'package:mobi_tv_entertainment/main.dart'; 
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';

// //==============================================================================
// // SECTION 1: COMMON CLASSES AND MODELS
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

// // Model: ReligiousChannelModel
// class ReligiousChannelModel { 
//   final int id;
//   final String name; 
//   final String updatedAt;
//   final String? poster; 
//   final String? banner; 
//   final String? genre; 
//   final int order;
//   final String? language;

//   ReligiousChannelModel({
//     required this.id,
//     required this.name,
//     required this.updatedAt,
//     this.poster,
//     this.banner,
//     this.genre,
//     required this.order,
//     this.language,
//   });

//   factory ReligiousChannelModel.fromJson(Map<String, dynamic> json) {
//     return ReligiousChannelModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       poster: json['logo'], 
//       banner: json['logo'], 
//       genre: null,
//       order: json['order'] ?? 9999,
//       language: json['language'],
//     );
//   }
// }

// // Model: ReligiousShowItemModel
// class ReligiousShowItemModel {
//   final int id;
//   final String name;
//   final String? thumbnail;
//   final String? genre;
//   final int religiousChannelId;
//   final int order;

//   ReligiousShowItemModel({
//     required this.id,
//     required this.name,
//     this.thumbnail,
//     this.genre,
//     required this.religiousChannelId,
//     required this.order,
//   });

//   factory ReligiousShowItemModel.fromJson(Map<String, dynamic> json) {
//     return ReligiousShowItemModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       thumbnail: json['thumbnail'],
//       genre: json['genre'],
//       religiousChannelId: json['religious_channel_id'] ?? 0,
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

// class ProfessionalReligiousLoadingIndicator extends StatelessWidget {
//   final String message;
//   const ProfessionalReligiousLoadingIndicator({Key? key, required this.message})
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
// //==============================================================================

// class ReligiousChannelSliderScreen extends StatefulWidget {
//   final String title;
//   final int? initialNetworkId;

//   const ReligiousChannelSliderScreen({
//     Key? key, 
//     this.title = 'Religious Channels',
//     this.initialNetworkId,
//     })
//       : super(key: key);

//   @override
//   _ReligiousChannelSliderScreenState createState() =>
//       _ReligiousChannelSliderScreenState();
// }

// class _ReligiousChannelSliderScreenState
//     extends State<ReligiousChannelSliderScreen>
//     with SingleTickerProviderStateMixin {
  
//   List<ReligiousChannelModel> _religiousChannelList = []; 
//   bool _isLoading = true; 
//   bool _isListLoading = false; 
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
  
//   Map<String, int?> _channelFilters = {}; 
//   String _selectedChannelFilterName = ''; 
//   int? _selectedChannelFilterId; 
//   bool _isDisplayingShows = false;  

//   List<ReligiousChannelModel> _currentViewMasterList = []; 
//   List<ReligiousChannelModel> _displayList = []; 
//   List<ApiNetworkModel> _apiNetworks = [];
//   List<String> _uniqueNetworks = [];
  
//   // Animation and Loading State
//   bool _isVideoLoading = false; 
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//   String? _currentBackgroundUrl;
//   List<SliderModel> _currentReligiousSliders = [];
//   int _currentSliderIndex = 0;

//   String _lastNavigationDirection = 'horizontal';

//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   // Search State
//   bool _isSearching = false;
//   bool _showKeyboard = false;
//   String _searchText = '';
//   Timer? _debounce;
//   late FocusNode _searchButtonFocusNode;

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
//     _searchButtonFocusNode.addListener(_setStateListener); 
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
//             _isLoading 
//                 ? const Center(
//                     child: ProfessionalReligiousLoadingIndicator(
//                         message: 'Loading Religious Channels...'))  
//                 : _errorMessage != null
//                     ? _buildErrorWidget() 
//                     : _buildPageContent(), 
//             if (_isVideoLoading && _errorMessage == null) 
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.8),
//                   child: const Center(
//                     child: ProfessionalReligiousLoadingIndicator(
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
//   // SECTION 2.1: DATA FETCHING
//   //=================================================

//   Future<void> _fetchDataForPage({bool forceRefresh = false}) async {
//     if (!mounted) return;
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       // 1. Fetch Networks (Direct API call, no SharedPreferences caching)
//       final fetchedNetworks = await _fetchNetworks();
//       if (!mounted) return;
//       fetchedNetworks.sort((a, b) => a.networksOrder.compareTo(b.networksOrder));

//       if (fetchedNetworks.isEmpty) {
//         throw Exception("No networks found.");
//       }

//       int initialIndex = 0;
//       int networkIdToFetch;

//       if (widget.initialNetworkId != null) {
//         int foundIndex = fetchedNetworks.indexWhere((n) => n.id == widget.initialNetworkId);
//         if (foundIndex != -1) {
//           initialIndex = foundIndex; 
//         }
//       }

//       final initialNetwork = fetchedNetworks[initialIndex];
//       networkIdToFetch = initialNetwork.id;

//       setState(() {
//         _apiNetworks = fetchedNetworks;
//         _uniqueNetworks = _apiNetworks.map((n) => n.name).toList();
//         _focusedNetworkIndex = initialIndex; 
//         _selectedNetworkName = initialNetwork.name;
//       });

//       // 2. Fetch Religious Channels for the *selected* network
//       final fetchedList = await _fetchReligiousChannelsForNetwork(networkIdToFetch); 
      
//       if (!mounted) return;

//       setState(() {
//         _religiousChannelList = fetchedList;  
//         if (_religiousChannelList.isEmpty) _errorMessage = "No Religious Channels Found.";
//       });

//       if (_errorMessage == null) {
//         _processInitialData();  
//         _updateChannelFilters(); 
//         await _fetchDataForView(); 
//         _initializeFocusNodes();
//         _startAnimations();

//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted && _networkFocusNodes.isNotEmpty && _focusedNetworkIndex < _networkFocusNodes.length) {
//             _networkFocusNodes[_focusedNetworkIndex].requestFocus();
//             _updateAndScrollToFocus(
//               _networkFocusNodes,
//               _focusedNetworkIndex,
//               _networkScrollController,
//               160 
//             );
//           }
//         });
//       }
//         setState(() => _isLoading = false);

//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage =
//               "Failed to load data.\nPlease check your connection.";
//           debugPrint("Error fetching initial data: $e");
//         });
//       }
//     }
//   }

//   Future<List<ReligiousChannelModel>> _fetchReligiousChannelsForNetwork(int networkId) async {
//     try {
//       String authKey = SessionManager.authKey ;
//       var url = Uri.parse(SessionManager.baseUrl + 'getReligiousChannels?content_network=$networkId');
//       final response = await https.get(url,
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': SessionManager.savedDomain
//         },
//       ).timeout(const Duration(seconds: 30));

//       if (!mounted) return [];

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         return jsonData
//             .map(
//                 (item) => ReligiousChannelModel.fromJson(item as Map<String, dynamic>))  
//             .toList()
//               ..sort((a, b) => a.order.compareTo(b.order));  
//       } else {
//         throw Exception('API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Failed to load religious channels for network $networkId: $e');  
//       throw Exception('Failed to load religious channels for network $networkId: $e');
//     }
//   }

//   Future<List<ReligiousShowItemModel>> _fetchReligiousShowsForChannel(int channelId) async {
//       String authKey = SessionManager.authKey ;
//       var url = Uri.parse(SessionManager.baseUrl + 'getReligiousShows/$channelId');
//     try {
//       final response = await https.get(url,
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': SessionManager.savedDomain,
//         },
//       ).timeout(const Duration(seconds: 30));

//       if (!mounted) return [];

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         return jsonData
//             .map((item) => ReligiousShowItemModel.fromJson(item as Map<String, dynamic>))
//             .toList()
//               ..sort((a, b) => a.order.compareTo(b.order));  
//       } else {
//         throw Exception('API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Failed to load religious shows for channel $channelId: $e');
//       throw Exception('Failed to load religious shows for channel $channelId: $e');
//     }
//   }

//   Future<List<ApiNetworkModel>> _fetchNetworks() async {
//       String authKey = SessionManager.authKey ;
//       var url = Uri.parse(SessionManager.baseUrl + 'getNetworks');
//     try {
//       final response = await https
//           .post(url,
//             headers: {
//               'auth-key': authKey,
//               'Content-Type': 'application/json',
//               'Accept': 'application/json',
//               'domain': SessionManager.savedDomain,
//             },
//             body: json.encode({"network_id": "", "data_for": "religiouschannels"}),  
//           )
//           .timeout(const Duration(seconds: 30));

//         if (!mounted) return [];

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         return jsonData
//             .map((item) => ApiNetworkModel.fromJson(item as Map<String, dynamic>))
//             .toList();
//       } else {
//         throw Exception('API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//         debugPrint('Failed to load networks: $e');
//       throw Exception('Failed to load networks: $e');
//     }
//   }

//   void _processInitialData() {
//     if (_apiNetworks.isEmpty) return;
//     _updateSelectedNetworkData(); 
//   }


//   //=================================================
//   // SECTION 2.2: KEYBOARD AND FOCUS NAVIGATION
//   //=================================================

//   void _focusFirstListItemWithScroll() {
//     if (_itemFocusNodes.isEmpty) return;

//     if (_listScrollController.hasClients) {
//       _listScrollController.animateTo(
//         0.0,
//         duration: AnimationTiming.fast, 
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

//   KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
//       if (event is! RawKeyDownEvent || _isListLoading || _isLoading) return KeyEventResult.ignored;

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
//           if (_networkFocusNodes.isNotEmpty) { _networkFocusNodes[_focusedNetworkIndex].requestFocus(); }
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.handled;
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
//         return KeyEventResult.handled; 
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
//           _focusFirstListItemWithScroll();
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.handled;
//     }

//     if ([ LogicalKeyboardKey.arrowUp, LogicalKeyboardKey.arrowDown, LogicalKeyboardKey.arrowLeft, LogicalKeyboardKey.arrowRight, LogicalKeyboardKey.select, LogicalKeyboardKey.enter ].contains(key)) {
//       if (networkHasFocus) { _navigateNetworks(key); }
//       else if (channelFilterHasFocus) { _navigateChannelFilters(key); }  
//       else if (listHasFocus) { _navigateList(key); } 
//       return KeyEventResult.handled;
//     }

//     return KeyEventResult.ignored;
//   }

//   void _navigateList(LogicalKeyboardKey key) {
//     if (_isNavigationLocked) return;
//     if (_focusedItemIndex == -1 || _itemFocusNodes.isEmpty) return;

//     setState(() {
//       _isNavigationLocked = true;
//     });

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
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();
//       return;

//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();
//       return;

//     } else if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newIndex > 0) {
//         newIndex--;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       final currentList = _displayList; 
//       if (newIndex + 1 < currentList.length) {
//         newIndex++;
//         setState(() => _lastNavigationDirection = 'horizontal');
//       }
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();

//       final currentList = _displayList; 
//       _navigateToReligiousDetails(currentList[_focusedItemIndex], _focusedItemIndex); 
//       return;
//     }

//     if (newIndex != _focusedItemIndex && newIndex >= 0 && newIndex < _itemFocusNodes.length) {
//       setState(() => _focusedItemIndex = newIndex);
//       _itemFocusNodes[newIndex].requestFocus();
//     } else {
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();
//     }
//   }

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

//   void _navigateChannelFilters(LogicalKeyboardKey key) {
//     final filterNames = _channelFilters.keys.toList();
    
//     if (filterNames.isEmpty) {
//         if (key == LogicalKeyboardKey.arrowLeft) {
//             _searchButtonFocusNode.requestFocus();
//         } else if (key == LogicalKeyboardKey.arrowUp && _networkFocusNodes.isNotEmpty) {
//             setState(() => _lastNavigationDirection = 'vertical');
//             _networkFocusNodes[_focusedNetworkIndex].requestFocus();
//         } else if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
//             setState(() => _lastNavigationDirection = 'vertical');
//             _focusFirstListItemWithScroll();
//         }
//         return; 
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
//       if (_itemFocusNodes.isNotEmpty) {
//         _focusFirstListItemWithScroll();
//       }
//       return;
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       _updateSelectedChannelFilter(); 
//       return;
//     }
//     if (newIndex != _focusedChannelFilterIndex) {
//       setState(() => _focusedChannelFilterIndex = newIndex);
//       _channelFilterFocusNodes[newIndex].requestFocus();
//       _updateAndScrollToFocus(
//           _channelFilterFocusNodes, newIndex, _channelFilterScrollController, 160); 
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

//     List<ReligiousChannelModel> newMasterList = [];

//     try {
//       if (_selectedChannelFilterId != null) {
//         final List<ReligiousShowItemModel> showItems =
//             await _fetchReligiousShowsForChannel(_selectedChannelFilterId!); 
        
//         newMasterList = showItems.map((show) => ReligiousChannelModel(
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
//     });

//     _startAnimations();
//   }
  
//   void _applySearchFilter() {
//     if (!mounted) return;

//     List<ReligiousChannelModel> filteredList = [];
//     if (_isSearching && _searchText.isNotEmpty) {
//       final searchTerm = _searchText.toLowerCase();
//       filteredList = _currentViewMasterList.where((item) {
//         return item.name.toLowerCase().contains(searchTerm);
//       }).toList();
//     } else {
//       filteredList = List.from(_currentViewMasterList);
//     }

//     setState(() {
//       _displayList = filteredList; 
//       _rebuildItemFocusNodes();
//       _focusedItemIndex = -1; 
//     });
//     _startAnimations();
//   }

//   void _updateSelectedNetwork() async {
//       if (_apiNetworks.isEmpty || _focusedNetworkIndex >= _apiNetworks.length) return;  

//     final selectedNetwork = _apiNetworks[_focusedNetworkIndex];
//     _debounce?.cancel();  

//     setState(() {
//       _isListLoading = true;  
//       _errorMessage = null;  
//         _displayList = [];  
//         _currentViewMasterList.clear();
//         _rebuildItemFocusNodes();  
//         _isSearching = false;  
//         _searchText = '';
//     });

//     try {
//       final newChannelList = await _fetchReligiousChannelsForNetwork(selectedNetwork.id); 
//       if (!mounted) return;

//       setState(() {
//         _religiousChannelList = newChannelList;  
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
//           _religiousChannelList = [];  
//           _displayList = [];
//           _currentViewMasterList.clear();
//             _updateChannelFilters();  
//             _rebuildChannelFilterFocusNodes();
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
//       if (_apiNetworks.isEmpty || _focusedNetworkIndex >= _apiNetworks.length) return;  

//     final selectedNetwork = _apiNetworks.firstWhere(
//         (n) => n.name == _selectedNetworkName,
//         orElse: () => ApiNetworkModel(id: -1, name: '', networksOrder: 9999));
        
//     final religiousSliders = selectedNetwork.sliders
//         .where((s) => s.sliderFor == 'religious') 
//         .toList();

//     setState(() {
//       _selectedNetworkLogo = selectedNetwork.logo;
//       _currentReligiousSliders = religiousSliders; 
//       _currentSliderIndex = 0;
//       if (religiousSliders.isNotEmpty) {
//         _currentBackgroundUrl = religiousSliders.first.banner;
//       } else {
//         _currentBackgroundUrl = selectedNetwork.logo;
//       }
//     });

//     if (_sliderPageController.hasClients && _currentReligiousSliders.isNotEmpty) { 
//       _sliderPageController.jumpToPage(0);
//     }
//   }

//   void _updateChannelFilters() {
//     setState(() {
//       if (_religiousChannelList.isEmpty) {
//         _channelFilters = {};  
//       } else {
//         final Map<String, int?> newFilters = {};  
//         for (final channel in _religiousChannelList) {
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
//     });
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
//         if (_searchText.isNotEmpty && !_searchText.endsWith(' ')) { 
//           _searchText += ' ';
//         }
//       } else {
//         _searchText += value;
//       }
//       _isSearching = _searchText.isNotEmpty; 
//       _debounce?.cancel(); 
//       _debounce = Timer(const Duration(milliseconds: 400), () { 
//         _applySearchFilter(); 
//       });
//     });
//   }

//   Future<void> _navigateToReligiousDetails(
//       ReligiousChannelModel item, int index) async {  
//     if (_isVideoLoading) return;
//     setState(() => _isVideoLoading = true);
    
//     try {
//       int? currentUserId = SessionManager.userId;
//       HistoryService.updateUserHistory(
//         userId: currentUserId!,
//         contentType: 5, // Assuming 5 for Religious
//         eventId: item.id,  
//         eventTitle: item.name,  
//         url: '',
//         categoryId: 0,
//       ).catchError((e) { debugPrint("History update failed: $e"); });
//     } catch (e) { debugPrint("Error getting userId for History: $e"); }

//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ReligiousChannelDetailsPage( 
//           id: item.id,  
//           banner: item.banner ?? item.poster ?? '',  
//           poster: item.poster ?? item.banner ?? '',  
//           name: item.name, updatedAt: item.updatedAt ,  
//         ),
//       ),
//     );

//     if (mounted) {
//       setState(() {
//         _isVideoLoading = false;
//           if (index >= 0 && index < _itemFocusNodes.length) { 
//             _focusedItemIndex = index;
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                   if(mounted && _itemFocusNodes.isNotEmpty && _focusedItemIndex < _itemFocusNodes.length) {
//                     _itemFocusNodes[_focusedItemIndex].requestFocus();
//                     _updateAndScrollToFocus(
//                         _itemFocusNodes, _focusedItemIndex, _listScrollController, (bannerwdt * 1.2) + 12); 
//                   }
//                 });
//           } else {
//             _focusedItemIndex = -1;
//             if(_itemFocusNodes.isNotEmpty) { _focusFirstListItemWithScroll(); }
//             else if (_channelFilterFocusNodes.isNotEmpty && _focusedChannelFilterIndex >= 0) { _channelFilterFocusNodes[_focusedChannelFilterIndex].requestFocus(); }  
//             else { _searchButtonFocusNode.requestFocus(); }
//           }
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
//     _fadeController.reset(); 
//     _fadeController.forward();
//   }

//   void _initializeFocusNodes() {
//     _disposeFocusNodes(_networkFocusNodes);
//     _networkFocusNodes = List.generate(
//         _apiNetworks.length, (index) => FocusNode(debugLabel: 'Network-$index')..addListener(_setStateListener)); 
//     _rebuildChannelFilterFocusNodes();
//     _rebuildItemFocusNodes();
//     _rebuildKeyboardFocusNodes();
//   }

//   void _rebuildChannelFilterFocusNodes() {
//     _disposeFocusNodes(_channelFilterFocusNodes);
//     _channelFilterFocusNodes = List.generate(
//         _channelFilters.length, (index) => FocusNode(debugLabel: 'ChannelFilter-$index')..addListener(_setStateListener)); 
//   }

//   void _rebuildItemFocusNodes() {
//     _disposeFocusNodes(_itemFocusNodes);
//     final currentList = _displayList;
//     _itemFocusNodes = List.generate(
//         currentList.length, (index) => FocusNode(debugLabel: 'Item-$index')..addListener(_setStateListener)); 
//   }

//   void _rebuildKeyboardFocusNodes() {
//     _disposeFocusNodes(_keyboardFocusNodes);
//     int totalKeys =
//         _keyboardLayout.fold(0, (prev, row) => prev + row.length);
//     _keyboardFocusNodes =
//         List.generate(totalKeys, (index) => FocusNode(debugLabel: 'Key-$index')..addListener(_setStateListener)); 
//   }

//   int _getFocusNodeIndexForKey(int row, int col) {
//     int index = 0;
//     for (int r = 0; r < row; r++) {
//       index += _keyboardLayout[r].length;
//     }
//     return index + col;
//   }

//   void _setStateListener() { if (mounted) { setState(() {}); } }

//   void _disposeFocusNodes(List<FocusNode> nodes) {
//     for (var node in nodes) {
//       node.removeListener(_setStateListener); 
//       node.dispose();
//     }
//     nodes.clear(); 
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
//         _buildChannelFilterAndSearchButtons(), 
//         SizedBox(height: screenhgt * 0.02),
//         _buildReligiousList(), 
//       ],
//     );
//   }
  
//   Widget _buildBackgroundOrSlider() {
//     if (_currentReligiousSliders.isNotEmpty) { 
//       return ReligiousBannerSlider( 
//         sliders: _currentReligiousSliders, 
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
//                   // ✅ Use CachedNetworkImageProvider
//                   image: CachedNetworkImageProvider(_currentBackgroundUrl!), 
//                   fit: BoxFit.cover,
//                   onError: (exception, stackTrace) { 
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

//   Widget _buildNetworkFilter() {
//     return SizedBox(
//       height: 30,
//       child: Center(
//         child: ListView.builder(
//           controller: _networkScrollController,
//           scrollDirection: Axis.horizontal,
//           itemCount: _uniqueNetworks.length,
//           itemBuilder: (context, index) {
//             if (index >= _networkFocusNodes.length) return const SizedBox.shrink(); 
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

//   Widget _buildChannelFilterAndSearchButtons() {
//     final filterNames = _channelFilters.keys.toList();

//     if (filterNames.isEmpty && !_isSearching) {
//       return const SizedBox(height: 30); 
//     }
    
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
//                   isSelected: _isSearching || _showKeyboard, 
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
//                   if (hasFocus) {
//                     setState(() => _focusedChannelFilterIndex = filterIndex);
//                   }
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

//   Widget _buildReligiousList() {
//     final currentList = _displayList;

//     if (currentList.isEmpty && !_isListLoading) { 
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
//                   Icons.temple_hindu_rounded, 
//                   size: 25,
//                   color: ProfessionalColors.textSecondary,
//                 ),
//                 Text(
//                   _isSearching && _searchText.isNotEmpty
//                       ? "No results found for '$_searchText'"
//                       : 'No religious content available.', 
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
//             if (index >= _itemFocusNodes.length) return const SizedBox.shrink(); 
//             final item = currentList[index];
//             final focusNode = _itemFocusNodes[index];
            
//             return Container(
//               width: bannerwdt * 1.2, 
//               margin: const EdgeInsets.only(right: 12.0),
//               child: InkWell(
//                 focusNode: focusNode,
//                 onTap: () => _navigateToReligiousDetails(item, index), 
//                 onFocusChange: (hasFocus) {
//                   if (hasFocus) {
//                     setState(() => _focusedItemIndex = index);
//                     _updateAndScrollToFocus(
//                         _itemFocusNodes, index, _listScrollController, (bannerwdt * 1.2) + 12);
//                   }
//                 },
//                 child: OptimizedReligiousCard( 
//                   item: item, 
//                   isFocused: _focusedItemIndex == index,
//                   onTap: () =>
//                       _navigateToReligiousDetails(item, index),
//                   cardHeight: bannerhgt * 1.2, 
//                   networkLogo: _isDisplayingShows ? null : _selectedNetworkLogo, 
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
//                   child: Text(
//                     "Search in $_selectedChannelFilterName", 
//                     style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                     maxLines: 2, 
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
//     int startIndex = _getFocusNodeIndexForKey(rowIndex, 0); 

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

//   Widget _buildSliderIndicators() {
//     if (_currentReligiousSliders.length <= 1) { 
//       return const SizedBox(height: 28); 
//     }
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(_currentReligiousSliders.length, (index) { 
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
//               focusNode: FocusNode(), 
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

// class OptimizedReligiousCard extends StatelessWidget {
//   final ReligiousChannelModel item; 
//   final bool isFocused;
//   final VoidCallback onTap;
//   final double cardHeight;
//   final String? networkLogo;
//   final int uniqueIndex;

//   const OptimizedReligiousCard({
//     Key? key,
//     required this.item, 
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
//               borderRadius: BorderRadius.circular(8.0),
//               border: isFocused
//                   ? Border.all(color: focusColor, width: 3)
//                   : Border.all(color: Colors.transparent, width: 3),
//               boxShadow: isFocused
//                   ? [
//                       BoxShadow(
//                           color: focusColor.withOpacity(0.5),
//                           blurRadius: 12,
//                           spreadRadius: 1)
//                     ]
//                   : []),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(6.0),
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   _buildReligiousImage(), 
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
//                             backgroundImage: CachedNetworkImageProvider(networkLogo!), // ✅ Cached
//                             backgroundColor: Colors.black54)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 8.0, left: 2.0, right: 2.0),
//           child: Text(item.name, 
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

//   Widget _buildReligiousImage() {
//     final imageUrl = item.poster; 
    
//     return imageUrl != null && imageUrl.isNotEmpty
//         ? CachedNetworkImage( // ✅ Use CachedNetworkImage
//             imageUrl: imageUrl,
//             fit: BoxFit.fill, 
//             placeholder: (context, url) => _buildImagePlaceholder(),
//             errorWidget: (context, url, error) {
//               debugPrint('Error loading item image: $imageUrl, Error: $error');
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
//         Icons.temple_hindu_outlined, 
//         color: Colors.white,
//         size: 24,
//       ),
//     );
//   }
// }

// class ReligiousBannerSlider extends StatefulWidget {
//   final List<SliderModel> sliders;
//   final ValueChanged<int> onPageChanged;
//   final PageController controller;

//   const ReligiousBannerSlider({
//     Key? key,
//     required this.sliders,
//     required this.onPageChanged,
//     required this.controller,
//   }) : super(key: key);

//   @override
//   _ReligiousBannerSliderState createState() => _ReligiousBannerSliderState();
// }

// class _ReligiousBannerSliderState extends State<ReligiousBannerSlider> {
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
//   void didUpdateWidget(ReligiousBannerSlider oldWidget) {
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
//               CachedNetworkImage( // ✅ Use CachedNetworkImage
//                 imageUrl: slider.banner,
//                 fit: BoxFit.fill,
//                 placeholder: (context, url) => Container(color: ProfessionalColors.surfaceDark),
//                 errorWidget: (context, url, error) {
//                     debugPrint('Error loading slider image: ${slider.banner}');
//                     return Container(color: ProfessionalColors.surfaceDark);
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







import 'dart:async';
import 'dart:convert';
import 'dart:typed_data'; // Required for Uint8List
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ Images ke liye Cache
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as https;

// NOTE: Apne project structure ke hisaab se imports check karein
// import 'package:mobi_tv_entertainment/components/home_screen_pages/religious/religious_final_details_page.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel_details_page.dart';
import 'package:mobi_tv_entertainment/main.dart'; // bannerhgt aur bannerwdt ke liye
import 'package:mobi_tv_entertainment/components/services/history_service.dart';

//==============================================================================
// SECTION 1: COMMON CLASSES AND MODELS
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

// Model: ReligiousChannelModel (Channels)
class ReligiousChannelModel { 
  final int id;
  final String name; 
  final String updatedAt;
  final String? poster; 
  final String? banner; 
  final String? genre; 
  final int order;
  final String? language;

  ReligiousChannelModel({
    required this.id,
    required this.name,
    required this.updatedAt,
    this.poster,
    this.banner,
    this.genre,
    required this.order,
    this.language,
  });

  factory ReligiousChannelModel.fromJson(Map<String, dynamic> json) {
    return ReligiousChannelModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      poster: json['logo'], // API 'logo' maps to poster
      banner: json['logo'], 
      genre: null,
      order: json['order'] ?? 9999,
      language: json['language'],
    );
  }
}

// Model: ReligiousShowItemModel (Shows inside a channel)
class ReligiousShowItemModel {
  final int id;
  final String title;
  final String? thumbnail;
  final String? genre;
  final int religiousChannelId;
  final int order;

  ReligiousShowItemModel({
    required this.id,
    required this.title,
    this.thumbnail,
    this.genre,
    required this.religiousChannelId,
    required this.order,
  });

  factory ReligiousShowItemModel.fromJson(Map<String, dynamic> json) {
    return ReligiousShowItemModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'],
      genre: json['genre'],
      religiousChannelId: json['religious_channel_id'] ?? 0,
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

class ProfessionalReligiousLoadingIndicator extends StatelessWidget {
  final String message;
  const ProfessionalReligiousLoadingIndicator({Key? key, required this.message})
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
//==============================================================================

class ReligiousChannelSliderScreen extends StatefulWidget {
  final String title;
  final int? initialNetworkId;

  const ReligiousChannelSliderScreen({
    Key? key, 
    this.title = 'Religious Channels',
    this.initialNetworkId,
    })
      : super(key: key);

  @override
  _ReligiousChannelSliderScreenState createState() =>
      _ReligiousChannelSliderScreenState();
}

class _ReligiousChannelSliderScreenState
    extends State<ReligiousChannelSliderScreen>
    with SingleTickerProviderStateMixin {
  
  List<ReligiousChannelModel> _religiousChannelList = []; 
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
  String _selectedNetworkName = '';
  String? _selectedNetworkLogo;
  
  Map<String, int?> _channelFilters = {}; 
  String _selectedChannelFilterName = ''; 
  int? _selectedChannelFilterId; 
  bool _isDisplayingShows = false;  

  List<ReligiousChannelModel> _currentViewMasterList = []; 
  List<ReligiousChannelModel> _displayList = []; 
  List<ApiNetworkModel> _apiNetworks = [];
  List<String> _uniqueNetworks = [];
  
  // Animation and Loading State
  bool _isVideoLoading = false; 
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _currentBackgroundUrl;
  List<SliderModel> _currentReligiousSliders = [];
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
                    child: ProfessionalReligiousLoadingIndicator(
                        message: 'Loading Religious Channels...'))  
                : _errorMessage != null
                    ? _buildErrorWidget() 
                    : _buildPageContent(), 
            if (_isVideoLoading && _errorMessage == null) 
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: const Center(
                    child: ProfessionalReligiousLoadingIndicator(
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
      fetchedNetworks.sort((a, b) => a.networksOrder.compareTo(b.networksOrder));

      if (fetchedNetworks.isEmpty) {
        throw Exception("No networks found.");
      }

      int initialIndex = 0;
      int networkIdToFetch;

      if (widget.initialNetworkId != null) {
        int foundIndex = fetchedNetworks.indexWhere((n) => n.id == widget.initialNetworkId);
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
        _selectedNetworkName = initialNetwork.name;
      });

      // 2. Fetch Religious Channels
      final fetchedList = await _fetchReligiousChannelsForNetwork(networkIdToFetch); 
      
      if (!mounted) return;

      setState(() {
        _religiousChannelList = fetchedList;  
        if (_religiousChannelList.isEmpty) _errorMessage = "No Religious Channels Found.";
      });

      if (_errorMessage == null) {
        _processInitialData();  
        _updateChannelFilters(); 
        await _fetchDataForView(); 
        _initializeFocusNodes();
        _startAnimations();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _networkFocusNodes.isNotEmpty && _focusedNetworkIndex < _networkFocusNodes.length) {
            _networkFocusNodes[_focusedNetworkIndex].requestFocus();
            _updateAndScrollToFocus(
              _networkFocusNodes,
              _focusedNetworkIndex,
              _networkScrollController,
              160 
            );
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

  Future<List<ReligiousChannelModel>> _fetchReligiousChannelsForNetwork(int networkId) async {
    try {
      String authKey = SessionManager.authKey ;
      var url = Uri.parse(SessionManager.baseUrl + 'getReligiousChannels?content_network=$networkId');
      final response = await https.get(url,
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
                (item) => ReligiousChannelModel.fromJson(item as Map<String, dynamic>))  
            .toList()
              ..sort((a, b) => a.order.compareTo(b.order));  
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load religious channels for network $networkId: $e');  
      throw Exception('Failed to load religious channels for network $networkId: $e');
    }
  }

  Future<List<ReligiousShowItemModel>> _fetchReligiousShowsForChannel(int channelId) async {
      String authKey = SessionManager.authKey ;
      var url = Uri.parse(SessionManager.baseUrl + 'getReligiousShows/$channelId');
    try {
      final response = await https.get(url,
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
            .map((item) => ReligiousShowItemModel.fromJson(item as Map<String, dynamic>))
            .toList()
              ..sort((a, b) => a.order.compareTo(b.order));  
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load religious shows for channel $channelId: $e');
      throw Exception('Failed to load religious shows for channel $channelId: $e');
    }
  }

  Future<List<ApiNetworkModel>> _fetchNetworks() async {
      String authKey = SessionManager.authKey ;
      var url = Uri.parse(SessionManager.baseUrl + 'getNetworks');
    try {
      final response = await https
          .post(url,
            headers: {
              'auth-key': authKey,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'domain': SessionManager.savedDomain,
            },
            body: json.encode({"network_id": "", "data_for": "religiouschannels"}),  
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
        return KeyEventResult.handled; 
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
      else if (listHasFocus) { _navigateList(key); } 
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
      _navigateToReligiousDetails(currentList[_focusedItemIndex], _focusedItemIndex); 
      return;
    }

    if (newIndex != _focusedItemIndex && newIndex >= 0 && newIndex < _itemFocusNodes.length) {
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
    final filterNames = _channelFilters.keys.toList();
    
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

    List<ReligiousChannelModel> newMasterList = [];

    try {
      if (_selectedChannelFilterId != null) {
        final List<ReligiousShowItemModel> showItems =
            await _fetchReligiousShowsForChannel(_selectedChannelFilterId!); 
        
        newMasterList = showItems.map((show) => ReligiousChannelModel(
              id: show.id,
              name: show.title,
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
    });

    _startAnimations();
  }
  
  void _applySearchFilter() {
    if (!mounted) return;

    List<ReligiousChannelModel> filteredList = [];
    if (_isSearching && _searchText.isNotEmpty) {
      final searchTerm = _searchText.toLowerCase();
      filteredList = _currentViewMasterList.where((item) {
        return item.name.toLowerCase().contains(searchTerm);
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
      final newChannelList = await _fetchReligiousChannelsForNetwork(selectedNetwork.id); 
      if (!mounted) return;

      setState(() {
        _religiousChannelList = newChannelList;  
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
          _religiousChannelList = [];  
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
        
    final religiousSliders = selectedNetwork.sliders
        .where((s) => s.sliderFor == 'religiouschannels') 
        .toList();

    setState(() {
      _selectedNetworkLogo = selectedNetwork.logo;
      _currentReligiousSliders = religiousSliders; 
      _currentSliderIndex = 0;
      if (religiousSliders.isNotEmpty) {
        _currentBackgroundUrl = religiousSliders.first.banner;
      } else {
        _currentBackgroundUrl = selectedNetwork.logo;
      }
    });

    if (_sliderPageController.hasClients && _currentReligiousSliders.isNotEmpty) { 
      _sliderPageController.jumpToPage(0);
    }
  }

  void _updateChannelFilters() {
    setState(() {
      if (_religiousChannelList.isEmpty) {
        _channelFilters = {};  
      } else {
        final Map<String, int?> newFilters = {};  
        for (final channel in _religiousChannelList) {
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

  Future<void> _navigateToReligiousDetails(
      ReligiousChannelModel item, int index) async {  
    if (_isVideoLoading) return;
    setState(() => _isVideoLoading = true);
    
    try {
      int? currentUserId = SessionManager.userId;
      HistoryService.updateUserHistory(
        userId: currentUserId!,
        contentType: 5, // 5 = Religious Content
        eventId: item.id,  
        eventTitle: item.name,  
        url: '',
        categoryId: 0,
      ).catchError((e) { debugPrint("History update failed: $e"); });
    } catch (e) { debugPrint("Error getting userId for History: $e"); }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReligiousChannelDetailsPage( 
          id: item.id,  
          banner: item.banner ?? item.poster ?? '',  
          poster: item.poster ?? item.banner ?? '',  
          name: item.name,  updatedAt:item.updatedAt,
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _isVideoLoading = false;
          if (index >= 0 && index < _itemFocusNodes.length) { 
            _focusedItemIndex = index;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                  if(mounted && _itemFocusNodes.isNotEmpty && _focusedItemIndex < _itemFocusNodes.length) {
                    _itemFocusNodes[_focusedItemIndex].requestFocus();
                    _updateAndScrollToFocus(
                        _itemFocusNodes, _focusedItemIndex, _listScrollController, (bannerwdt * 1.1) + 15); 
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
    _fadeController.reset(); 
    _fadeController.forward();
  }

  void _initializeFocusNodes() {
    _disposeFocusNodes(_networkFocusNodes);
    _networkFocusNodes = List.generate(
        _apiNetworks.length, (index) => FocusNode(debugLabel: 'Network-$index')..addListener(_setStateListener)); 
    _rebuildChannelFilterFocusNodes();
    _rebuildItemFocusNodes();
    _rebuildKeyboardFocusNodes();
  }

  void _rebuildChannelFilterFocusNodes() {
    _disposeFocusNodes(_channelFilterFocusNodes);
    _channelFilterFocusNodes = List.generate(
        _channelFilters.length, (index) => FocusNode(debugLabel: 'ChannelFilter-$index')..addListener(_setStateListener)); 
  }

  void _rebuildItemFocusNodes() {
    _disposeFocusNodes(_itemFocusNodes);
    final currentList = _displayList;
    _itemFocusNodes = List.generate(
        currentList.length, (index) => FocusNode(debugLabel: 'Item-$index')..addListener(_setStateListener)); 
  }

  void _rebuildKeyboardFocusNodes() {
    _disposeFocusNodes(_keyboardFocusNodes);
    int totalKeys =
        _keyboardLayout.fold(0, (prev, row) => prev + row.length);
    _keyboardFocusNodes =
        List.generate(totalKeys, (index) => FocusNode(debugLabel: 'Key-$index')..addListener(_setStateListener)); 
  }

  int _getFocusNodeIndexForKey(int row, int col) {
    int index = 0;
    for (int r = 0; r < row; r++) {
      index += _keyboardLayout[r].length;
    }
    return index + col;
  }

  void _setStateListener() { if (mounted) { setState(() {}); } }

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
        _buildChannelFilterAndSearchButtons(), 
        SizedBox(height: screenhgt * 0.02),
        _buildReligiousList(), // ✅ List build call
      ],
    );
  }
  
  Widget _buildBackgroundOrSlider() {
    if (_currentReligiousSliders.isNotEmpty) { 
      return ReligiousBannerSlider( 
        sliders: _currentReligiousSliders, 
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
                  image: CachedNetworkImageProvider(_currentBackgroundUrl!), // ✅ Cache
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) { 
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
            if (index >= _networkFocusNodes.length) return const SizedBox.shrink(); 
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

  Widget _buildChannelFilterAndSearchButtons() {
    final filterNames = _channelFilters.keys.toList();

    if (filterNames.isEmpty && !_isSearching) {
      return const SizedBox(height: 30); 
    }
    
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
                  isSelected: _isSearching || _showKeyboard, 
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

  Widget _buildReligiousList() {
    final currentList = _displayList;

    if (currentList.isEmpty && !_isListLoading) { 
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
                  Icons.temple_hindu_rounded, 
                  size: 25,
                  color: ProfessionalColors.textSecondary,
                ),
                Text(
                  _isSearching && _searchText.isNotEmpty
                      ? "No results found for '$_searchText'"
                      : 'No religious content available.', 
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
    
    // ✅ FIXED: Adjusted width and spacing for better text visibility
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 1.0, bottom: 10.0), // Bottom padding added
        child: ListView.builder(
          controller: _listScrollController,
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.015),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            if (index >= _itemFocusNodes.length) return const SizedBox.shrink(); 
            final item = currentList[index];
            final focusNode = _itemFocusNodes[index];
            
            return Container(
              width: bannerwdt * 1.1, // Width sufficient for text
              margin: const EdgeInsets.only(right: 15.0), 
              alignment: Alignment.topCenter,
              child: InkWell(
                focusNode: focusNode,
                onTap: () => _navigateToReligiousDetails(item, index), 
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    setState(() => _focusedItemIndex = index);
                    _updateAndScrollToFocus(
                        _itemFocusNodes, index, _listScrollController, (bannerwdt * 1.1) + 15);
                  }
                },
                child: OptimizedReligiousCard( 
                  item: item, 
                  isFocused: _focusedItemIndex == index,
                  onTap: () =>
                      _navigateToReligiousDetails(item, index),
                  // ✅ FIXED: Height 1.0 allows room for text in parent container
                  cardHeight: bannerhgt * 1.0, 
                  networkLogo: _isDisplayingShows ? null : _selectedNetworkLogo, 
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
                  child: Text(
                    "Search in $_selectedChannelFilterName", 
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    maxLines: 2, 
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

  Widget _buildSliderIndicators() {
    if (_currentReligiousSliders.length <= 1) { 
      return const SizedBox(height: 28); 
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_currentReligiousSliders.length, (index) { 
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
              focusNode: FocusNode(), 
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

class OptimizedReligiousCard extends StatelessWidget {
  final ReligiousChannelModel item; 
  final bool isFocused;
  final VoidCallback onTap;
  final double cardHeight;
  final String? networkLogo;
  final int uniqueIndex;

  const OptimizedReligiousCard({
    Key? key,
    required this.item, 
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

    // ✅ FIXED: Layout ensures text is visible below image
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
                  _buildReligiousImage(), 
                  if (isFocused)
                    Positioned(
                        left: 0, right: 0, top: 0, bottom: 0, 
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
                            backgroundImage: CachedNetworkImageProvider(networkLogo!),
                            backgroundColor: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
        // const SizedBox(height: 8), // Spacing between Image and Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
              item.name, 
              textAlign: TextAlign.center, 
              style: TextStyle(
                  color: isFocused
                      ? focusColor
                      : Colors.white, // ✅ White color for visibility
                  fontSize: 15, 
                  fontWeight: isFocused ? FontWeight.bold : FontWeight.w500,
                  shadows: [
                     Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 2, offset: Offset(0, 1))
                  ]
              ),
              maxLines: 2, 
              overflow: TextOverflow.ellipsis
          ),
        ),
      ],
    );
  }

  Widget _buildReligiousImage() {
    final imageUrl = item.poster; 
    
    return imageUrl != null && imageUrl.isNotEmpty
        ? CachedNetworkImage( // ✅ Cached
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
            ProfessionalColors.accentGreen, 
            ProfessionalColors.accentBlue,
          ],
        ),
      ),
      child: const Icon(
        Icons.temple_hindu_outlined, 
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class ReligiousBannerSlider extends StatefulWidget {
  final List<SliderModel> sliders;
  final ValueChanged<int> onPageChanged;
  final PageController controller;

  const ReligiousBannerSlider({
    Key? key,
    required this.sliders,
    required this.onPageChanged,
    required this.controller,
  }) : super(key: key);

  @override
  _ReligiousBannerSliderState createState() => _ReligiousBannerSliderState();
}

class _ReligiousBannerSliderState extends State<ReligiousBannerSlider> {
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
  void didUpdateWidget(ReligiousBannerSlider oldWidget) {
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
              CachedNetworkImage( // ✅ Cached
                imageUrl: slider.banner,
                fit: BoxFit.fill,
                placeholder: (context, url) => Container(color: ProfessionalColors.surfaceDark),
                errorWidget: (context, url, error) {
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


