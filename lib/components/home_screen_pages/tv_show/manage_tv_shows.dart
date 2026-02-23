




// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_final_details_page.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_slider_screen.dart';
// import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_loading_widget.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_retry_widget.dart';
// import 'dart:math' as math;
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';
// // ✅ Import Smart Widgets
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:ui';

// // ✅ ==========================================================
// // MODELS & CONSTANTS
// // ✅ ==========================================================
// class AnimationTiming {
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// class TVShowNetworkModel {
//   final int id;
//   final String name;
//   final String? logo;
//   final int status;

//   TVShowNetworkModel({required this.id, required this.name, this.logo, required this.status});

//   factory TVShowNetworkModel.fromJson(Map<String, dynamic> json) {
//     return TVShowNetworkModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       logo: json['logo'],
//       status: json['status'] ?? 0,
//     );
//   }
// }

// // ✅ ==========================================================
// // TV SHOW NETWORK SERVICE
// // ✅ ==========================================================
// class TVShowNetworkService {
//   static const String _cacheKeyTVShows = 'cached_tv_shows';
//   static const String _cacheKeyTimestamp = 'cached_tv_shows_timestamp';
//   static const int _cacheDurationMs = 60 * 60 * 1000;

//   static Future<List<TVShowNetworkModel>> getAllTVShowNetworks({bool forceRefresh = false}) async {
//     final prefs = await SharedPreferences.getInstance();
//     if (!forceRefresh && await _shouldUseCache(prefs)) {
//       final cached = await _getCachedTVShowNetworks(prefs);
//       if (cached.isNotEmpty) {
//         _loadFreshDataInBackground();
//         return cached;
//       }
//     }
//     return await _fetchFreshTVShowNetworks(prefs);
//   }

//   static Future<bool> _shouldUseCache(SharedPreferences prefs) async {
//     final timestampStr = prefs.getString(_cacheKeyTimestamp);
//     if (timestampStr == null) return false;
//     final cachedTimestamp = int.tryParse(timestampStr) ?? 0;
//     return DateTime.now().millisecondsSinceEpoch - cachedTimestamp < _cacheDurationMs;
//   }

//   static Future<List<TVShowNetworkModel>> _getCachedTVShowNetworks(SharedPreferences prefs) async {
//     final cachedData = prefs.getString(_cacheKeyTVShows);
//     if (cachedData == null) return [];
//     try {
//       final List<dynamic> jsonData = json.decode(cachedData);
//       return jsonData.map((json) => TVShowNetworkModel.fromJson(json)).where((n) => n.status == 1).toList();
//     } catch (e) { return []; }
//   }

//   static Future<List<TVShowNetworkModel>> _fetchFreshTVShowNetworks(SharedPreferences prefs) async {
//     try {
//       String authKey = SessionManager.authKey;
//       var url = Uri.parse(SessionManager.baseUrl + 'getNetworks');
//       final response = await https.post(url, headers: {'auth-key': authKey, 'Content-Type': 'application/json', 'domain': SessionManager.savedDomain}, body: json.encode({"network_id": "", "data_for": "tvshows"})).timeout(const Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         final activeNetworks = jsonData.map((json) => TVShowNetworkModel.fromJson(json)).where((n) => n.status == 1).toList();
//         await _cacheTVShowNetworks(prefs, jsonData);
//         return activeNetworks;
//       } else { throw Exception('API Error: ${response.statusCode}'); }
//     } catch (e) { rethrow; }
//   }

//   static Future<void> _cacheTVShowNetworks(SharedPreferences prefs, List<dynamic> data) async {
//     await prefs.setString(_cacheKeyTVShows, json.encode(data));
//     await prefs.setString(_cacheKeyTimestamp, DateTime.now().millisecondsSinceEpoch.toString());
//   }

//   static void _loadFreshDataInBackground() {
//     Future.delayed(const Duration(milliseconds: 500), () async {
//       try { final prefs = await SharedPreferences.getInstance(); await _fetchFreshTVShowNetworks(prefs); } catch (e) {}
//     });
//   }
// }

// // ✅ ==========================================================
// // MAIN WIDGET: ManageTvShows
// // ✅ ==========================================================
// class ManageTvShows extends StatefulWidget {
//   const ManageTvShows({super.key});
//   @override
//   _ManageTvShowsState createState() => _ManageTvShowsState();
// }

// class _ManageTvShowsState extends State<ManageTvShows>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<TVShowNetworkModel> _fullTVShowNetworkList = [];
//   List<TVShowNetworkModel> _displayedTVShowNetworkList = [];
//   bool _showViewAll = false;
//   bool isLoading = true;
//   String _errorMessage = ''; // ✅ Error State
//   int focusedIndex = -1;
//   Color _currentAccentColor = ProfessionalColorsForHomePages.accentGreen;
  
//   // ✅ Shadow State
//   bool _isSectionFocused = false;

//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   Map<String, FocusNode> tvShowNetworkFocusNodes = {};
//   FocusNode? _firstTVShowNetworkFocusNode;
//   late FocusNode _viewAllFocusNode;
  
//   // ✅ Retry Focus Node
//   final FocusNode _retryFocusNode = FocusNode();
  
//   bool _hasReceivedFocus = false;
//   late ScrollController _scrollController;
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _viewAllFocusNode = FocusNode();
//     _initializeAnimations();
//     _initializeFocusListeners();
//     fetchTVShowNetworksWithCache();
//   }

//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();
//     _viewAllFocusNode.dispose();
//     _retryFocusNode.dispose();
    
//     String? firstNetworkId;
//     if (_fullTVShowNetworkList.isNotEmpty) firstNetworkId = _fullTVShowNetworkList[0].id.toString();

//     for (var entry in tvShowNetworkFocusNodes.entries) {
//       if (entry.key != firstNetworkId) {
//         try { entry.value.dispose(); } catch (e) {}
//       }
//     }
//     tvShowNetworkFocusNodes.clear();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _initializeAnimations() {
//     _headerAnimationController = AnimationController(duration: AnimationTiming.slow, vsync: this);
//     _listAnimationController = AnimationController(duration: AnimationTiming.slow, vsync: this);
//     _headerSlideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutCubic));
//     _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _listAnimationController, curve: Curves.easeInOut));
//   }

//   void _initializeFocusListeners() {
//     _viewAllFocusNode.addListener(_onViewAllFocusChange);
//   }

//   void _onViewAllFocusChange() {
//     if (mounted && _viewAllFocusNode.hasFocus) {
//       setState(() => _isSectionFocused = true); // ✅ Shadow Update
//       setState(() => focusedIndex = _displayedTVShowNetworkList.length);
//       _scrollToPosition(focusedIndex);
//     }
//   }

//   void _scrollToPosition(int index) {
//     if (!mounted || !_scrollController.hasClients) return;
//     try {
//       double itemWidth = bannerwdt + 12;
//       double targetPosition = index * itemWidth;
//       targetPosition = targetPosition.clamp(0.0, _scrollController.position.maxScrollExtent);
//       _scrollController.animateTo(targetPosition, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
//     } catch (e) {}
//   }

//   void _setupTVShowNetworkFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         final focusProvider = Provider.of<FocusProvider>(context, listen: false);
        
//         if (_displayedTVShowNetworkList.isNotEmpty) {
//           // Success Case
//           final firstNetworkId = _displayedTVShowNetworkList[0].id.toString();
//           _firstTVShowNetworkFocusNode = tvShowNetworkFocusNodes[firstNetworkId];

//           if (_firstTVShowNetworkFocusNode != null) {
//             focusProvider.registerFocusNode('tvShows', _firstTVShowNetworkFocusNode!);
            
//             _firstTVShowNetworkFocusNode!.addListener(() {
//               if (mounted && _firstTVShowNetworkFocusNode!.hasFocus) {
//                 if (!_hasReceivedFocus) _hasReceivedFocus = true;
//                 setState(() => focusedIndex = 0);
//                 _scrollToPosition(0);
//               }
//             });
//           }
//         } else if (_errorMessage.isNotEmpty) {
//            // Error Case
//            focusProvider.registerFocusNode('tvShows', _retryFocusNode);
//         }
//       }
//     });
//   }

//   Future<void> fetchTVShowNetworksWithCache() async {
//     if (!mounted) return;
//     setState(() { isLoading = true; _errorMessage = ''; });
//     try {
//       final fetchedNetworks = await TVShowNetworkService.getAllTVShowNetworks();
//       if (mounted) {
//         _fullTVShowNetworkList = fetchedNetworks;
//         if (_fullTVShowNetworkList.length > 10) {
//           _displayedTVShowNetworkList = _fullTVShowNetworkList.sublist(0, 10);
//         } else {
//           _displayedTVShowNetworkList = _fullTVShowNetworkList;
//         }
//         _showViewAll = _fullTVShowNetworkList.isNotEmpty;
        
//         setState(() => isLoading = false);
//         if (_fullTVShowNetworkList.isNotEmpty) {
//           _createFocusNodesForItems();
//           _setupTVShowNetworkFocusProvider();
//           _headerAnimationController.forward();
//           _listAnimationController.forward();
//           _restoreInternalFocus();
//         }
        
//       }
//     } catch (e) {
//       if (mounted) setState(() { isLoading = false; _errorMessage = 'Failed to load TV Shows'; });
//       _setupTVShowNetworkFocusProvider();
//     }
//   }

//   void _createFocusNodesForItems() {
//     tvShowNetworkFocusNodes.clear();
//     for (int i = 0; i < _displayedTVShowNetworkList.length; i++) {
//       String networkId = _displayedTVShowNetworkList[i].id.toString();
//       tvShowNetworkFocusNodes[networkId] = FocusNode();
//       if (i > 0) {
//         tvShowNetworkFocusNodes[networkId]!.addListener(() {
//           if (mounted && tvShowNetworkFocusNodes[networkId]!.hasFocus) {
//             setState(() {
//               focusedIndex = i;
//               _hasReceivedFocus = true;
//             });
//             _scrollToPosition(i);
//           }
//         });
//       }
//     }
//   }


//   void _restoreInternalFocus() {
//   WidgetsBinding.instance.addPostFrameCallback((_) async {
//     if (!mounted) return;

//     // TV navigation transition ke liye delay
//     await Future.delayed(const Duration(milliseconds: 300));

//     final focusProvider = Provider.of<FocusProvider>(context, listen: false);
//     final savedItemId = focusProvider.lastFocusedItemId;

//     // Check karein ki kya saved ID hamare nodes map mein mojud hai
//     if (savedItemId != null && tvShowNetworkFocusNodes.containsKey(savedItemId)) {
//       final nodeToFocus = tvShowNetworkFocusNodes[savedItemId]!;
      
//       if (nodeToFocus.canRequestFocus) {
//         FocusScope.of(context).requestFocus(nodeToFocus);
        
//         // Index nikal kar scroll aur state update karein
//         int index = _displayedTVShowNetworkList.indexWhere((v) => v.id.toString() == savedItemId);
//         if (index != -1) {
//           _scrollToPosition(index);
//           setState(() => focusedIndex = index);
//         }
//       }
//     }
//   });
// }

//   void _navigateToTVShowNetworkDetails(TVShowNetworkModel network) async {
//     final focusProvider = Provider.of<FocusProvider>(context, listen: false);
  
//   // 1. Current position save karein
//   focusProvider.updateLastFocusedIdentifier('tvShows');
//   focusProvider.updateLastFocusedItemId(network.id.toString());
//     try {
//       int? currentUserId = SessionManager.userId;
//       await HistoryService.updateUserHistory(userId: currentUserId!, contentType: 4, eventId: network.id, eventTitle: network.name, url: '', categoryId: 0);
//     } catch (e) {}
//     await Navigator.push(context, MaterialPageRoute(builder: (context) => TvShowFinalDetailsPage (id: network.id, name: network.name, banner: network.logo??'', poster: network.logo ??'',)));
//     _restoreInternalFocus();
//   }

//   void _navigateToGridPage() {
//     Navigator.push(context, MaterialPageRoute(builder: (context) => TvShowSliderScreen(initialNetworkId: null)));
//   }

//   void _navigateToGridPageWithNetwork(TVShowNetworkModel network) {
//     Navigator.push(context, MaterialPageRoute(builder: (context) => TvShowSliderScreen(initialNetworkId: network.id)));
//   }

//   // ✅ ERROR WIDGET (Smart UI)
//   Widget _buildErrorWidget(double height) {
//     return SizedBox(
//       height: height,
//       child: Center(
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 10),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(color: ProfessionalColorsForHomePages.cardDark.withOpacity(0.3), borderRadius: BorderRadius.circular(50), border: Border.all(color: ProfessionalColorsForHomePages.accentRed.withOpacity(0.3))),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline_rounded, size: 20, color: ProfessionalColorsForHomePages.accentRed),
//               const SizedBox(width: 10),
//               Flexible(child: Text("Connection Failed", style: const TextStyle(color: ProfessionalColorsForHomePages.textPrimary, fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
//               const SizedBox(width: 15),
//               // ✅ Smart Retry Widget
//               SmartRetryWidget(
//                 errorMessage: _errorMessage,
//                 onRetry: fetchTVShowNetworksWithCache,
//                 focusNode: _retryFocusNode,
//                 providerIdentifier: 'tvShows',
//                 onFocusChange: (hasFocus) {
//                    if(mounted) setState(() => _isSectionFocused = hasFocus);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(double screenWidth, double screenHeight) {
//     double effectiveBannerHgt = bannerhgt ?? screenHeight * 0.2;
//     double effectiveBannerWdt = bannerwdt ?? screenWidth * 0.18;

//     if (isLoading) {
//       // ✅ Smart Loading
//       return SmartLoadingWidget(itemWidth: effectiveBannerWdt, itemHeight: effectiveBannerHgt);
//     } else if (_errorMessage.isNotEmpty) {
//       // ✅ Smart Error
//       return _buildErrorWidget(effectiveBannerHgt);
//     } else if (_fullTVShowNetworkList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildTVShowNetworksList(screenWidth, screenHeight);
//     }
//   }

//   Widget _buildEmptyWidget() {
//     return const Center(child: Text("No TV Shows Found", style: TextStyle(color: Colors.white, fontSize: 12)));
//   }

//   Widget _buildTVShowNetworksList(double screenWidth, double screenHeight) {
//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: Container(
//         height: screenHeight * 0.38,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.none,
//           controller: _scrollController,
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//           cacheExtent: 9999,
//           itemCount: _displayedTVShowNetworkList.length + (_showViewAll ? 1 : 0),
//           itemBuilder: (context, index) {
//             if (index < _displayedTVShowNetworkList.length) {
//               var network = _displayedTVShowNetworkList[index];
//               return _buildTVShowNetworkItem(network, index, screenWidth, screenHeight);
//             } else {
//               return _buildViewAllButton(screenWidth, screenHeight);
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildTVShowNetworkItem(TVShowNetworkModel network, int index, double screenWidth, double screenHeight) {
//     String networkId = network.id.toString();
//     FocusNode? focusNode = tvShowNetworkFocusNodes[networkId];
//     if (focusNode == null) return const SizedBox.shrink();

//     return Focus(
//       focusNode: focusNode,
//       onFocusChange: (hasFocus) async {
//         if (mounted) setState(() => _isSectionFocused = hasFocus); // ✅ Shadow Update
//         if (hasFocus) {
//           context.read<FocusProvider>().updateLastFocusedItemId(networkId);
//           Color dominantColor = ProfessionalColorsForHomePages.accentBlue;
//           setState(() {
//             _currentAccentColor = dominantColor;
//             focusedIndex = index;
//             _hasReceivedFocus = true;
//           });
//           context.read<ColorProvider>().updateColor(dominantColor, true);
//           _scrollToPosition(index);
//         } else {
//           bool isAnyItemFocused = tvShowNetworkFocusNodes.values.any((node) => node.hasFocus);
//           if (!mounted) return;
//           if (!isAnyItemFocused && !_viewAllFocusNode.hasFocus) {
//             context.read<ColorProvider>().resetColor();
//           }
//         }
//       },
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent) {
//           final key = event.logicalKey;
//           if (key == LogicalKeyboardKey.arrowRight) {
//             if (index < _displayedTVShowNetworkList.length - 1) {
//               String nextNetworkId = _displayedTVShowNetworkList[index + 1].id.toString();
//               FocusScope.of(context).requestFocus(tvShowNetworkFocusNodes[nextNetworkId]);
//             } else if (_showViewAll) {
//               FocusScope.of(context).requestFocus(_viewAllFocusNode);
//             }
//             return KeyEventResult.handled;
//           } else if (key == LogicalKeyboardKey.arrowLeft) {
//             if (index > 0) {
//               String prevNetworkId = _displayedTVShowNetworkList[index - 1].id.toString();
//               FocusScope.of(context).requestFocus(tvShowNetworkFocusNodes[prevNetworkId]);
//             }
//             return KeyEventResult.handled;
//           } else if (key == LogicalKeyboardKey.arrowUp) {
//             setState(() { focusedIndex = -1; _hasReceivedFocus = false; });
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus();
//             context.read<FocusProvider>().updateLastFocusedIdentifier('tvShows');
//             context.read<FocusProvider>().focusPreviousRow();
//             return KeyEventResult.handled;
//           } else if (key == LogicalKeyboardKey.arrowDown) {
//             setState(() { focusedIndex = -1; _hasReceivedFocus = false; });
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus();
//             context.read<FocusProvider>().updateLastFocusedIdentifier('tvShows');
//             context.read<FocusProvider>().focusNextRow();
//             return KeyEventResult.handled;
//           } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
//             _navigateToGridPageWithNetwork(network);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () => _navigateToGridPageWithNetwork(network),
//         child: ProfessionalTVShowNetworkCard(
//           network: network,
//           focusNode: focusNode,
//           onTap: () => _navigateToGridPageWithNetwork(network),
//           onColorChange: (color) {
//             if (mounted) setState(() => _currentAccentColor = color);
//             context.read<ColorProvider>().updateColor(color, true);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildViewAllButton(double screenWidth, double screenHeight) {
//     return Focus(
//       focusNode: _viewAllFocusNode,
//       onFocusChange: (hasFocus) {
//         if (mounted) setState(() => _isSectionFocused = hasFocus); // ✅ Shadow Update
//         if (hasFocus) {
//           setState(() { focusedIndex = _displayedTVShowNetworkList.length; _hasReceivedFocus = true; });
//           context.read<ColorProvider>().updateColor(ProfessionalColorsForHomePages.accentPurple, true);
//           _scrollToPosition(focusedIndex);
//         } else {
//           bool isAnyItemFocused = tvShowNetworkFocusNodes.values.any((node) => node.hasFocus);
//           if (!mounted) return;
//           if (!isAnyItemFocused) context.read<ColorProvider>().resetColor();
//         }
//       },
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent) {
//           final key = event.logicalKey;
//           if (key == LogicalKeyboardKey.arrowRight) {
//       return KeyEventResult.handled; // Iska matlab "is key ka kaam khatam, aage kuch mat karo"
//     } 
    
//     else
//           if (key == LogicalKeyboardKey.arrowLeft) {
//             if (_displayedTVShowNetworkList.isNotEmpty) {
//               String prevNetworkId = _displayedTVShowNetworkList.last.id.toString();
//               FocusScope.of(context).requestFocus(tvShowNetworkFocusNodes[prevNetworkId]);
//             }
//             return KeyEventResult.handled;
//           } 
//           else if (key == LogicalKeyboardKey.arrowUp) {
//             setState(() { focusedIndex = -1; _hasReceivedFocus = false; });
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus();
//             context.read<FocusProvider>().updateLastFocusedIdentifier('tvShows');
//             context.read<FocusProvider>().focusPreviousRow();
//             return KeyEventResult.handled;
//           } else if (key == LogicalKeyboardKey.arrowDown) {
//             setState(() { focusedIndex = -1; _hasReceivedFocus = false; });
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus();
//             context.read<FocusProvider>().updateLastFocusedIdentifier('tvShows');
//             context.read<FocusProvider>().focusNextRow();
//             return KeyEventResult.handled;
//           } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
//             _navigateToGridPage();
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: _navigateToGridPage,
//         child: ProfessionalTVShowNetworkViewAllButton(
//           focusNode: _viewAllFocusNode,
//           onTap: _navigateToGridPage,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     double containerHeight = (screenhgt ?? screenHeight) * 0.38;

//     return Consumer<ColorProvider>(
//       builder: (context, colorProvider, child) {
        
//         bool showShadow = _isSectionFocused;

//         return  Container(
//               height: containerHeight,
//               color: Colors.white,

//               child: Stack(
//                 children: [
//                   Column(
//                     children: [
//                       SizedBox(height: (screenhgt ?? screenHeight) * 0.02),
//                       _buildProfessionalTitle(screenWidth),
//                       SizedBox(height: (screenhgt ?? screenHeight) * 0.01),
//                       Expanded(child: _buildBody(screenWidth, screenHeight)),
//                     ],
//                   ),
                  
//                   // ✅ SHADOW OVERLAY
//                   Positioned.fill(
//                     child: IgnorePointer(
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.easeOut,
//                         decoration: BoxDecoration(
//                           gradient: showShadow
//                               ? LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     Colors.black.withOpacity(0.8), 
//                                     Colors.transparent,             
//                                     Colors.transparent,             
//                                     Colors.black.withOpacity(0.8), 
//                                   ],
//                                   stops: const [0.0, 0.25, 0.75, 1.0], 
//                                 )
//                               : null,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//         );
//       },
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     return SlideTransition(
//       position: _headerSlideAnimation,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//         child: Row(
//           children: [
//             ShaderMask(
//               shaderCallback: (bounds) => const LinearGradient(
//                 colors: [ProfessionalColorsForHomePages.accentGreen, ProfessionalColorsForHomePages.accentBlue],
//               ).createShader(bounds),
//               child: const Text('TV SHOWS', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 2.0)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ... (ProfessionalTVShowNetworkCard and ViewAllButton - Unchanged from previous snippets) ...
// // Copy them here. No changes needed.

// // ✅ ==========================================================
// // ✅ [RENAMED] Supporting Widgets
// // ✅ ==========================================================

// // ✅ [RENAMED] Professional TVShowNetwork Card
// class ProfessionalTVShowNetworkCard extends StatefulWidget {
//   final TVShowNetworkModel network; // ✅ Use TVShowNetworkModel
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;

//   const ProfessionalTVShowNetworkCard({
//     Key? key,
//     required this.network, // ✅ Use TVShowNetworkModel
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//   }) : super(key: key);

//   @override
//   _ProfessionalTVShowNetworkCardState createState() =>
//       _ProfessionalTVShowNetworkCardState();
// }

// class _ProfessionalTVShowNetworkCardState
//     extends State<ProfessionalTVShowNetworkCard> with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _glowController;
//   late AnimationController _shimmerController;

//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<double> _shimmerAnimation;

//   Color _dominantColor = ProfessionalColorsForHomePages.accentBlue;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController =
//         AnimationController(duration: AnimationTiming.slow, vsync: this);
//     _glowController =
//         AnimationController(duration: AnimationTiming.medium, vsync: this);
//     _shimmerController = AnimationController(
//         duration: const Duration(milliseconds: 1500), vsync: this)
//       ..repeat();

//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
//         CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
//     _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
//     _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
//         CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (!mounted) return;
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _scaleController.forward();
//       _glowController.forward();
//       _generateDominantColor();
//       widget.onColorChange(_dominantColor);
//       HapticFeedback.lightImpact();
//     } else {
//       _scaleController.reverse();
//       _glowController.reverse();
//     }
//   }

//   void _generateDominantColor() {
//     // final colors = ProfessionalColorsForHomePages.gradientColors;
//     // _dominantColor = colors[math.Random().nextInt(colors.length)];
//     final colors = ProfessionalColorsForHomePages.accentBlue;
//     _dominantColor = colors;
//   }

//   @override
//   void dispose() {
//     widget.focusNode.removeListener(_handleFocusChange);
//     _scaleController.dispose();
//     _glowController.dispose();
//     _shimmerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return AnimatedBuilder(
//       animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Container(
//             width: bannerwdt,
//             margin: const EdgeInsets.symmetric(horizontal: 6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _buildProfessionalPoster(screenWidth, screenHeight),
//                 _buildProfessionalTitle(screenWidth),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
//     final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;

//     return Container(
//       height: posterHeight,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           if (_isFocused) ...[
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.4),
//               blurRadius: 25,
//               spreadRadius: 3,
//               offset: const Offset(0, 8),
//             ),
//           ] else ...[
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 10,
//               spreadRadius: 2,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Stack(
//           children: [
//             _buildNetworkImage(screenWidth, posterHeight), // ✅ Use new method
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ [ADAPTED] Build image
//   Widget _buildNetworkImage(double screenWidth, double posterHeight) {
//     return Container(
//       width: double.infinity,
//       height: posterHeight,
//       child: widget.network.logo != null && widget.network.logo!.isNotEmpty
//           ? Image.network(
//               widget.network.logo!,
//               fit: BoxFit.cover,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return _buildImagePlaceholder(posterHeight);
//               },
//               errorBuilder: (context, error, stackTrace) =>
//                   _buildImagePlaceholder(posterHeight),
//             )
//           : _buildImagePlaceholder(posterHeight),
//     );
//   }

//   Widget _buildImagePlaceholder(double height) {
//     return Container(
//       height: height,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalColorsForHomePages.cardDark,
//             ProfessionalColorsForHomePages.surfaceDark,
//           ],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.live_tv_rounded, // ✅ Updated Icon
//             size: height * 0.25,
//             color: ProfessionalColorsForHomePages.textSecondary,
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'TV SHOW', // ✅ Updated Text
//             style: TextStyle(
//               color: ProfessionalColorsForHomePages.textSecondary,
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFocusBorder() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             width: 3,
//             color: _dominantColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmerEffect() {
//     return AnimatedBuilder(
//       animation: _shimmerAnimation,
//       builder: (context, child) {
//         return Positioned.fill(
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               gradient: LinearGradient(
//                 begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
//                 end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
//                 colors: [
//                   Colors.transparent,
//                   _dominantColor.withOpacity(0.15),
//                   Colors.transparent,
//                 ],
//                 stops: [0.0, 0.5, 1.0],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHoverOverlay() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               _dominantColor.withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: Icon(
//               Icons.play_arrow_rounded, // You can change this icon
//               color: _dominantColor,
//               size: 30,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ✅ [ADAPTED] Build title
//   Widget _buildProfessionalTitle(double screenWidth) {
//     final networkName = widget.network.name.toUpperCase();

//     return Container(
//       width: bannerwdt,
//       child: AnimatedDefaultTextStyle(
//         duration: AnimationTiming.medium,
//         style: TextStyle(
//           fontSize: _isFocused ? 13 : 11,
//           fontWeight: FontWeight.w600,
//           color: _isFocused
//               ? _dominantColor
//               : ProfessionalColorsForHomePages.primaryDark,
//           letterSpacing: 0.5,
//           shadows: _isFocused
//               ? [
//                   Shadow(
//                     color: _dominantColor.withOpacity(0.6),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Text(
//           networkName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // ✅ [RENAMED] View All Button Widget
// class ProfessionalTVShowNetworkViewAllButton extends StatefulWidget {
//   final FocusNode focusNode;
//   final VoidCallback onTap;

//   const ProfessionalTVShowNetworkViewAllButton({
//     Key? key,
//     required this.focusNode,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   _ProfessionalTVShowNetworkViewAllButtonState createState() =>
//       _ProfessionalTVShowNetworkViewAllButtonState();
// }

// class _ProfessionalTVShowNetworkViewAllButtonState
//     extends State<ProfessionalTVShowNetworkViewAllButton>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late Animation<double> _scaleAnimation;
//   bool _isFocused = false;
//   final Color _focusColor = ProfessionalColorsForHomePages.accentPurple;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController =
//         AnimationController(duration: AnimationTiming.slow, vsync: this);
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
//         CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (!mounted) return;
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _scaleController.forward();
//       HapticFeedback.lightImpact();
//     } else {
//       _scaleController.reverse();
//     }
//   }

//   @override
//   void dispose() {
//     widget.focusNode.removeListener(_handleFocusChange);
//     _scaleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _scaleAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Container(
//             width: bannerwdt,
//             margin: const EdgeInsets.symmetric(horizontal: 6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _buildButtonBody(),
//                 _buildButtonTitle(),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildButtonBody() {
//     final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;
//     return Container(
//       height: posterHeight,
//       width: bannerwdt,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalColorsForHomePages.cardDark.withOpacity(0.8),
//             ProfessionalColorsForHomePages.surfaceDark.withOpacity(0.8),
//           ],
//         ),
//         border: Border.all(
//           width: _isFocused ? 3 : 0,
//           color: _isFocused ? _focusColor : Colors.transparent,
//         ),
//         boxShadow: [
//           if (_isFocused)
//             BoxShadow(
//               color: _focusColor.withOpacity(0.4),
//               blurRadius: 25,
//               spreadRadius: 3,
//             ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 size: 30,
//                 color: _isFocused
//                     ? _focusColor
//                     : ProfessionalColorsForHomePages.textPrimary,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'VIEW ALL',
//                 style: TextStyle(
//                   color: _isFocused
//                       ? _focusColor
//                       : ProfessionalColorsForHomePages.textPrimary,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildButtonTitle() {
//     return Container(
//       width: bannerwdt,
//       child: AnimatedDefaultTextStyle(
//         duration: AnimationTiming.medium,
//         style: TextStyle(
//           fontSize: _isFocused ? 13 : 11,
//           fontWeight: FontWeight.w600,
//           color: _isFocused
//               ? _focusColor
//               : ProfessionalColorsForHomePages.textPrimary,
//         ),
//         child: const Text(
//           'SEE ALL',
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // ✅ [RENAMED] Professional Loading Indicator
// class ProfessionalTVShowNetworkLoadingIndicator extends StatefulWidget {
//   final String message;
//   const ProfessionalTVShowNetworkLoadingIndicator({
//     Key? key,
//     this.message = 'Loading...',
//   }) : super(key: key);

//   @override
//   _ProfessionalTVShowNetworkLoadingIndicatorState createState() =>
//       _ProfessionalTVShowNetworkLoadingIndicatorState();
// }

// class _ProfessionalTVShowNetworkLoadingIndicatorState
//     extends State<ProfessionalTVShowNetworkLoadingIndicator>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//         duration: const Duration(milliseconds: 1500), vsync: this)
//       ..repeat();
//     _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
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
//           AnimatedBuilder(
//             animation: _animation,
//             builder: (context, child) {
//               return Container(
//                 width: 70,
//                 height: 70,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: SweepGradient(
//                     colors: const [
//                       ProfessionalColorsForHomePages.accentGreen,
//                       ProfessionalColorsForHomePages.accentBlue,
//                       ProfessionalColorsForHomePages.accentOrange,
//                       ProfessionalColorsForHomePages.accentGreen,
//                     ],
//                     stops: [0.0, 0.3, 0.7, 1.0],
//                     transform: GradientRotation(_animation.value * 2 * math.pi),
//                   ),
//                 ),
//                 child: Container(
//                   margin: const EdgeInsets.all(5),
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: ProfessionalColorsForHomePages.primaryDark,
//                   ),
//                   child: const Icon(
//                     Icons.live_tv_rounded,
//                     color: ProfessionalColorsForHomePages.textPrimary,
//                     size: 28,
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 24),
//           Text(
//             widget.message,
//             style: const TextStyle(
//               color: ProfessionalColorsForHomePages.textPrimary,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as https;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

// ✅ Custom Imports (Make sure paths match your project structure)
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_loading_widget.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_retry_widget.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_final_details_page.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_slider_screen.dart';

// ✅ ==========================================================
// DATA MODELS & PARSING (Using High-Performance Isolate)
// ==========================================================
enum LoadingState { initial, loading, rebuilding, loaded, error }

class AnimationTiming {
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration scroll = Duration(milliseconds: 800);
}

class TVShowNetworkModel {
  final int id;
  final String name;
  final String? logo;
  final int status;

  TVShowNetworkModel({
    required this.id, 
    required this.name, 
    this.logo, 
    required this.status
  });

  factory TVShowNetworkModel.fromJson(Map<String, dynamic> json) {
    return TVShowNetworkModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'],
      status: json['status'] ?? 0,
    );
  }
}

// Background Task for JSON Parsing to prevent UI lag (Code 1 Style)
List<TVShowNetworkModel> _parseTVShowData(String jsonString) {
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData
      .map((json) => TVShowNetworkModel.fromJson(json))
      .where((n) => n.status == 1)
      .toList();
}

// ✅ Image Helper (Supports Network, SVG, and Base64)
Widget displayImage(String imageUrl, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
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
      return Image.network(imageUrl, width: width, height: height, fit: fit, errorBuilder: (c, e, s) => _buildImgError(width, height));
    }
  } else { return _buildImgError(width, height); }
}

Widget _buildImgLoader(double? width, double? height) => SizedBox(width: width, height: height, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white24))));
Widget _buildImgError(double? width, double? height) => Container(width: width, height: height, color: Colors.grey[900], child: const Icon(Icons.broken_image, color: Colors.white24, size: 24));

// ✅ ==========================================================
// MAIN WIDGET: ManageTvShows
// ✅ ==========================================================
class ManageTvShows extends StatefulWidget {
  const ManageTvShows({super.key});
  @override
  _ManageTvShowsState createState() => _ManageTvShowsState();
}

class _ManageTvShowsState extends State<ManageTvShows>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  LoadingState _loadingState = LoadingState.initial;
  List<TVShowNetworkModel> _fullList = [];
  List<TVShowNetworkModel> _displayedList = [];
  String _errorMessage = '';
  int focusedIndex = -1;
  bool _isSectionFocused = false;
  bool _isNavigationLocked = false;
  Timer? _navLockTimer;

  Map<String, FocusNode> _tvFocusNodes = {};
  final FocusNode _viewAllFocusNode = FocusNode();
  final FocusNode _retryFocusNode = FocusNode();
  late ScrollController _scrollController;

  late AnimationController _listAnimationController;
  late Animation<double> _listFadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _listAnimationController = AnimationController(duration: AnimationTiming.slow, vsync: this);
    _listFadeAnimation = CurvedAnimation(parent: _listAnimationController, curve: Curves.easeInOut);
    _fetchTVShows();
  }

  Future<void> _fetchTVShows() async {
    if (mounted) setState(() => _loadingState = LoadingState.loading);
    try {
      String authKey = SessionManager.authKey;
      var url = Uri.parse("${SessionManager.baseUrl}getNetworks");
      final response = await https.post(url, headers: {
        'auth-key': authKey,
        'Content-Type': 'application/json',
        'domain': SessionManager.savedDomain
      }, body: json.encode({"network_id": "", "data_for": "tvshows"})).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final parsedData = await compute(_parseTVShowData, response.body);
        _applyDataToState(parsedData);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = e.toString(); _loadingState = LoadingState.error; });
      _setupFocusInProvider();
    }
  }

  void _applyDataToState(List<TVShowNetworkModel> data) {
    if (!mounted) return;
    _tvFocusNodes.forEach((_, node) => node.dispose());
    _tvFocusNodes.clear();

    _fullList = data;
    _displayedList = _fullList.length > 10 ? _fullList.sublist(0, 10) : _fullList;

    for (var item in _displayedList) {
      _tvFocusNodes[item.id.toString()] = FocusNode();
    }

    setState(() => _loadingState = LoadingState.loaded);
    _setupFocusInProvider();
    _listAnimationController.forward();
  }

  void _setupFocusInProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final fp = Provider.of<FocusProvider>(context, listen: false);
      if (_displayedList.isNotEmpty) {
        fp.registerFocusNode('tvShows', _tvFocusNodes[_displayedList[0].id.toString()]!);
      } else if (_loadingState == LoadingState.error) {
        fp.registerFocusNode('tvShows', _retryFocusNode);
      }
    });
  }

  // ✅ Fixed Scroll with .toDouble() to solve your num error
  void _scrollToPosition(int index) {
    if (!_scrollController.hasClients) return;
    double itemWidth = (bannerwdt + 12).toDouble();
    double targetOffset = (index * itemWidth).toDouble();
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: AnimationTiming.scroll,
      curve: Curves.easeOutCubic,
    );
  }

  void _restoreFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      final fp = Provider.of<FocusProvider>(context, listen: false);
      final savedId = fp.lastFocusedItemId;
      if (savedId != null && _tvFocusNodes.containsKey(savedId)) {
        _tvFocusNodes[savedId]!.requestFocus();
        int idx = _displayedList.indexWhere((n) => n.id.toString() == savedId);
        if (idx != -1) _scrollToPosition(idx);
      }
    });
  }

  @override
  void dispose() {
    _navLockTimer?.cancel();
    _listAnimationController.dispose();
    _scrollController.dispose();
    _viewAllFocusNode.dispose();
    _retryFocusNode.dispose();
    _tvFocusNodes.forEach((_, node) => node.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    double h = (screenhgt ?? sh) * 0.38;

    return Container(
      height: h,
      color: Colors.white,
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: (screenhgt ?? sh) * 0.02),
              _buildProfessionalTitle(sw),
              Expanded(child: _buildBody(sw, sh)),
            ],
          ),
          if (_isSectionFocused) _buildShadowOverlay(),
        ],
      ),
    );
  }

  Widget _buildProfessionalTitle(double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.025),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [ProfessionalColorsForHomePages.accentGreen, ProfessionalColorsForHomePages.accentBlue],
            ).createShader(bounds),
            child: const Text('TV SHOWS', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 2.0)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(double sw, double sh) {
    double bh = bannerhgt ?? sh * 0.2;
    double bw = bannerwdt ?? sw * 0.18;

    switch (_loadingState) {
      case LoadingState.loading:
        return SmartLoadingWidget(itemWidth: bw, itemHeight: bh);
      case LoadingState.error:
        return Center(child: SmartRetryWidget(
          errorMessage: _errorMessage, 
          onRetry: _fetchTVShows, 
          focusNode: _retryFocusNode, 
          providerIdentifier: 'tvShows', 
          onFocusChange: (f) => setState(() => _isSectionFocused = f)
        ));
      case LoadingState.loaded:
        if (_displayedList.isEmpty) return const Center(child: Text("No TV Shows Found"));
        return _buildTVShowList(sw, sh);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTVShowList(double sw, double sh) {
    return FadeTransition(
      opacity: _listFadeAnimation,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: sw * 0.025),
        itemCount: _displayedList.length + (_fullList.length > 10 ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _displayedList.length) {
            return _buildTVShowItem(_displayedList[index], index);
          } else {
            return _buildViewAllButton();
          }
        },
      ),
    );
  }

  Widget _buildTVShowItem(TVShowNetworkModel network, int index) {
    String id = network.id.toString();
    FocusNode node = _tvFocusNodes[id]!;

    return Focus(
      focusNode: node,
      onFocusChange: (f) {
        if (mounted) setState(() => _isSectionFocused = f);
        if (f) {
          context.read<FocusProvider>().updateLastFocusedItemId(id);
          _scrollToPosition(index);
          setState(() => focusedIndex = index);
          context.read<ColorProvider>().updateColor(ProfessionalColorsForHomePages.accentBlue, true);
        }
      },
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.arrowLeft) {
            if (_isNavigationLocked) return KeyEventResult.handled;
            setState(() => _isNavigationLocked = true);
            _navLockTimer = Timer(const Duration(milliseconds: 150), () => setState(() => _isNavigationLocked = false));
          }
          if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
            _navigateToDetails(network);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.arrowUp) {
            context.read<FocusProvider>().focusPreviousRow();
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.arrowDown) {
            context.read<FocusProvider>().focusNextRow();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _navigateToDetails(network),
        child: ProfessionalTVShowNetworkCard(
          network: network,
          focusNode: node,
          onTap: () => _navigateToDetails(network),
          onColorChange: (c) {},
        ),
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Focus(
      focusNode: _viewAllFocusNode,
      onFocusChange: (f) {
        if (mounted) setState(() => _isSectionFocused = f);
        if (f) {
          _scrollToPosition(_displayedList.length);
          setState(() => focusedIndex = 999);
          context.read<ColorProvider>().updateColor(ProfessionalColorsForHomePages.accentPurple, true);
        }
      },
      onKey: (node, event) {
        if (event is RawKeyDownEvent && (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.select)) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TvShowSliderScreen(initialNetworkId: null)));
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TvShowSliderScreen(initialNetworkId: null))),
        child: ProfessionalTVShowNetworkViewAllButton(focusNode: _viewAllFocusNode, onTap: () {}),
      ),
    );
  }

  void _navigateToDetails(TVShowNetworkModel network) async {
    final fp = Provider.of<FocusProvider>(context, listen: false);
    fp.updateLastFocusedIdentifier('tvShows');
    fp.updateLastFocusedItemId(network.id.toString());
    
    try {
      await HistoryService.updateUserHistory(userId: SessionManager.userId!, contentType: 4, eventId: network.id, eventTitle: network.name, url: '', categoryId: 0);
    } catch (e) {}

    await Navigator.push(context, MaterialPageRoute(builder: (context) => TvShowFinalDetailsPage(
      id: network.id, 
      name: network.name, 
      banner: network.logo ?? '', 
      poster: network.logo ?? ''
    )));
    _restoreFocus();
  }

  Widget _buildShadowOverlay() {
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.8)],
            stops: const [0.0, 0.2, 0.8, 1.0],
          ),
        ),
      ),
    );
  }
}

// ✅ Professional TVShow Card Widget
class ProfessionalTVShowNetworkCard extends StatefulWidget {
  final TVShowNetworkModel network;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;

  const ProfessionalTVShowNetworkCard({
    Key? key,
    required this.network,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
  }) : super(key: key);

  @override
  _ProfessionalTVShowNetworkCardState createState() => _ProfessionalTVShowNetworkCardState();
}

class _ProfessionalTVShowNetworkCardState extends State<ProfessionalTVShowNetworkCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(duration: AnimationTiming.medium, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
    widget.focusNode.addListener(_handleFocus);
  }

  void _handleFocus() {
    if (!mounted) return;
    setState(() => _isFocused = widget.focusNode.hasFocus);
    if (_isFocused) {
      _scaleController.forward();
      HapticFeedback.lightImpact();
    } else {
      _scaleController.reverse();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    widget.focusNode.removeListener(_handleFocus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          width: bannerwdt,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              _buildPoster(),
              _buildTitle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoster() {
    double h = _isFocused ? focussedBannerhgt : bannerhgt;
    return Container(
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _isFocused ? ProfessionalColorsForHomePages.accentBlue.withOpacity(0.4) : Colors.black.withOpacity(0.3),
            blurRadius: _isFocused ? 20 : 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            displayImage(widget.network.logo ?? '', fit: BoxFit.cover, width: double.infinity, height: h),
            if (_isFocused) Container(decoration: BoxDecoration(border: Border.all(color: ProfessionalColorsForHomePages.accentBlue, width: 3), borderRadius: BorderRadius.circular(12))),
            if (_isFocused) Center(child: Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.8), size: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        widget.network.name.toUpperCase(),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: _isFocused ? 12 : 11,
          fontWeight: FontWeight.w600,
          color: _isFocused ? ProfessionalColorsForHomePages.accentBlue : Colors.black87,
        ),
      ),
    );
  }
}

// Professional View All Button Widget (As in Code 2)
class ProfessionalTVShowNetworkViewAllButton extends StatelessWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;

  const ProfessionalTVShowNetworkViewAllButton({Key? key, required this.focusNode, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isFocused = focusNode.hasFocus;
    double h = isFocused ? focussedBannerhgt : bannerhgt;

    return Container(
      width: bannerwdt,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Container(
            height: h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isFocused ? ProfessionalColorsForHomePages.accentPurple : Colors.grey[200],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward_ios_rounded, color: isFocused ? Colors.white : Colors.black54),
                const SizedBox(height: 10),
                Text("VIEW ALL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isFocused ? Colors.white : Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text("SEE ALL", style: TextStyle(fontSize: 11, color: isFocused ? ProfessionalColorsForHomePages.accentPurple : Colors.black54)),
        ],
      ),
    );
  }
}