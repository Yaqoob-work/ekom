




// import 'dart:async';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/professional_web_series_grid_page.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/webseries_details_page.dart';
// import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_loading_widget.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_retry_widget.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';
// // ✅ Import Smart Widgets
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import 'dart:math' as math;
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

// class NetworkModel {
//   final int id;
//   final String name;
//   final String? logo;

//   NetworkModel({required this.id, required this.name, this.logo});

//   factory NetworkModel.fromJson(Map<String, dynamic> json) {
//     return NetworkModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       logo: json['logo'],
//     );
//   }
// }

// class WebSeriesModel {
//   final int id;
//   final String name;
//   final String updatedAt;
//   final String? description;
//   final String? poster;
//   final String? banner;
//   final String? releaseDate;
//   final String? genres;
//   final int seriesOrder;
//   final List<NetworkModel> networks;

//   WebSeriesModel({
//     required this.id,
//     required this.name,
//     required this.updatedAt,
//     this.description,
//     this.poster,
//     this.banner,
//     this.releaseDate,
//     this.genres,
//     required this.seriesOrder,
//     this.networks = const [],
//   });

//   factory WebSeriesModel.fromJson(Map<String, dynamic> json) {
//     List<NetworkModel> parsedNetworks = [];
//     final dynamic networksJson = json['networks'];
//     if (networksJson != null && networksJson is List) {
//       for (final item in networksJson) {
//         if (item != null && item is Map<String, dynamic>) {
//           parsedNetworks.add(NetworkModel.fromJson(item));
//         }
//       }
//     }

//     return WebSeriesModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       description: json['description'],
//       poster: json['poster'],
//       banner: json['banner'],
//       releaseDate: json['release_date'],
//       genres: json['genres'],
//       seriesOrder: json['series_order'] ?? 9999,
//       networks: parsedNetworks,
//     );
//   }
// }

// // ✅ ==========================================================
// // WEB SERIES SERVICE
// // ✅ ==========================================================
// class WebSeriesService {
//   static const int _limitedListSize = 20;

//   static Future<List<WebSeriesModel>> getLimitedWebSeries() async {
//     try {
//       return await _fetchAndFilterWebSeries();
//     } catch (e) {
//       print('❌ Error in getLimitedWebSeries: $e');
//       throw Exception('Failed to load limited web series: $e');
//     }
//   }

//   static Future<List<WebSeriesModel>> _fetchAndFilterWebSeries() async {
//     try {
//       String authKey = SessionManager.authKey;
//       var url = Uri.parse(
//           SessionManager.baseUrl + 'getAllWebSeries?page1&records=11');

//       final response = await https.get(
//         url,
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': SessionManager.savedDomain
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         final List<dynamic> filteredData = jsonData.where((item) {
//           if (item is Map<String, dynamic> && item.containsKey('status')) {
//             return item['status'] == 1 || item['status'] == '1';
//           }
//           return false;
//         }).toList();

//         final List<dynamic> processedData =
//             filteredData.take(_limitedListSize).toList();
//         List<WebSeriesModel> webSeries = processedData
//             .map(
//                 (json) => WebSeriesModel.fromJson(json as Map<String, dynamic>))
//             .toList();

//         webSeries.sort((a, b) => a.seriesOrder.compareTo(b.seriesOrder));
//         return webSeries;
//       } else {
//         throw Exception(
//             'API Error: ${response.statusCode} - ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('❌ Error fetching fresh limited web series: $e');
//       rethrow;
//     }
//   }
// }

// // ✅ ==========================================================
// // MAIN WIDGET: ManageWebSeries
// // ✅ ==========================================================
// class ManageWebSeries extends StatefulWidget {
//   const ManageWebSeries({super.key});
//   @override
//   _ManageWebSeriesState createState() => _ManageWebSeriesState();
// }

// class _ManageWebSeriesState extends State<ManageWebSeries>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<WebSeriesModel> webSeriesList = [];
//   bool isLoading = true;
//   String _errorMessage = ''; // ✅ Error State
//   int focusedIndex = -1;
//   final int maxHorizontalItems = 10;

//   // ✅ Shadow State
//   bool _isSectionFocused = false;

//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   Map<String, FocusNode> webseriesFocusNodes = {};
//   FocusNode? _viewAllFocusNode;

//   // ✅ Retry Focus Node
//   final FocusNode _retryFocusNode = FocusNode();

//   FocusNode? _firstWebSeriesFocusNode;
//   bool _hasReceivedFocusFromMovies = false;

//   late ScrollController _scrollController;
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _initializeAnimations();
//     _initializeFocusNodes();
//     // fetchWebSeries();
// fetchWebSeries().then((_) {
//   _restoreInternalFocus();
// });
//   }

//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();

//     // Dispose nodes safely
//     String? firstWebSeriesId;
//     if (webSeriesList.isNotEmpty)
//       firstWebSeriesId = webSeriesList[0].id.toString();

//     for (var entry in webseriesFocusNodes.entries) {
//       if (entry.key != firstWebSeriesId) {
//         try {
//           entry.value.dispose();
//         } catch (e) {}
//       }
//     }
//     webseriesFocusNodes.clear();
//     _viewAllFocusNode?.dispose();
//     _retryFocusNode.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _initializeAnimations() {
//     _headerAnimationController =
//         AnimationController(duration: AnimationTiming.slow, vsync: this);
//     _listAnimationController =
//         AnimationController(duration: AnimationTiming.slow, vsync: this);

//     _headerSlideAnimation =
//         Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
//             CurvedAnimation(
//                 parent: _headerAnimationController,
//                 curve: Curves.easeOutCubic));
//     _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(
//             parent: _listAnimationController, curve: Curves.easeInOut));
//   }

//   void _initializeFocusNodes() {
//     _viewAllFocusNode = FocusNode();
//   }

//   Future<void> _scrollToPosition(int index) async {
//     if (!mounted || !_scrollController.hasClients) return;
//     try {
//       double itemWidth = bannerwdt + 12;
//       double targetPosition = (index * itemWidth) - 5;
//       targetPosition =
//           targetPosition.clamp(0.0, _scrollController.position.maxScrollExtent);
//       await _scrollController.animateTo(targetPosition,
//           duration: const Duration(milliseconds: 350),
//           curve: Curves.easeOutCubic);
//     } catch (e) {
//       print('Error scrolling in webseries: $e');
//     }
//   }

//   // void _setupFocusProvider() {
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     if (mounted) {
//   //       final focusProvider =
//   //           Provider.of<FocusProvider>(context, listen: false);

//   //       if (webSeriesList.isNotEmpty) {
//   //         // Success Case
//   //         final firstWebSeriesId = webSeriesList[0].id.toString();
//   //         _firstWebSeriesFocusNode = webseriesFocusNodes[firstWebSeriesId];

//   //         if (_firstWebSeriesFocusNode != null) {
//   //           focusProvider.registerFocusNode(
//   //               'manageWebseries', _firstWebSeriesFocusNode!);

//   //           _firstWebSeriesFocusNode?.addListener(() {
//   //             if (mounted && _firstWebSeriesFocusNode!.hasFocus) {
//   //               if (!_hasReceivedFocusFromMovies)
//   //                 _hasReceivedFocusFromMovies = true;
//   //               setState(() => focusedIndex = 0);
//   //               _scrollToPosition(0);
//   //             }
//   //           });
//   //         }
//   //       } else if (_errorMessage.isNotEmpty) {
//   //         // Error Case
//   //         focusProvider.registerFocusNode('manageWebseries', _retryFocusNode);
//   //       }
//   //     }
//   //   });
//   // }


//   void _setupFocusProvider() {
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     if (mounted) {
//       final focusProvider = Provider.of<FocusProvider>(context, listen: false);
//       const String myId = 'manageWebseries'; // Is page ka ID

//       if (webSeriesList.isNotEmpty) {
//         final firstWebSeriesId = webSeriesList[0].id.toString();
//         _firstWebSeriesFocusNode = webseriesFocusNodes[firstWebSeriesId];

//         if (_firstWebSeriesFocusNode != null) {
//           // 1. Register focus node
//           focusProvider.registerFocusNode(myId, _firstWebSeriesFocusNode!);

//           // 2. ✅ CRITICAL FIX: Check if Dashboard is asking this page to take focus
//           if (focusProvider.lastFocusedIdentifier == myId) {
//             _firstWebSeriesFocusNode!.requestFocus();
//           }

//           _firstWebSeriesFocusNode?.addListener(() {
//             if (mounted && _firstWebSeriesFocusNode!.hasFocus) {
//               if (!_hasReceivedFocusFromMovies) {
//                 _hasReceivedFocusFromMovies = true;
//               }
//               setState(() => focusedIndex = 0);
//               _scrollToPosition(0);
//             }
//           });
//         }
//       } else if (_errorMessage.isNotEmpty) {
//         // Error state focus
//         focusProvider.registerFocusNode(myId, _retryFocusNode);
//         if (focusProvider.lastFocusedIdentifier == myId) {
//           _retryFocusNode.requestFocus();
//         }
//       }
//     }
//   });
// }

//   Future<void> fetchWebSeries() async {
//     if (!mounted) return;
//     setState(() {
//       isLoading = true;
//       _errorMessage = '';
//     });
//     try {
//       final fetchedWebSeries = await WebSeriesService.getLimitedWebSeries();
//       if (mounted) {
//         setState(() {
//           webSeriesList = fetchedWebSeries;
//           isLoading = false;
//         });
//         _createFocusNodesForItems();
//         _headerAnimationController.forward();
//         _listAnimationController.forward();
//         _setupFocusProvider();
//       }
//     } catch (e) {
//       if (mounted)
//         setState(() {
//           isLoading = false;
//           _errorMessage = 'Failed to load web series';
//         });
//       _setupFocusProvider();
//       print('Error fetching WebSeries: $e');
//     }
//   }

//   void _createFocusNodesForItems() {
//     webseriesFocusNodes.clear();
//     for (int i = 0; i < webSeriesList.length && i < maxHorizontalItems; i++) {
//       String webSeriesId = webSeriesList[i].id.toString();
//       webseriesFocusNodes[webSeriesId] = FocusNode();
//       if (i > 0) {
//         webseriesFocusNodes[webSeriesId]!.addListener(() {
//           if (mounted && webseriesFocusNodes[webSeriesId]!.hasFocus) {
//             setState(() {
//               focusedIndex = i;
//               _hasReceivedFocusFromMovies = true;
//             });
//             _scrollToPosition(i);
//           }
//         });
//       }
//     }
//   }




// void _restoreInternalFocus() {
//   if (!mounted) return;
  
//   final focusProvider = Provider.of<FocusProvider>(context, listen: false);
//   final savedItemId = focusProvider.lastFocusedItemId;

//   if (savedItemId != null && webseriesFocusNodes.containsKey(savedItemId)) {
//     final nodeToFocus = webseriesFocusNodes[savedItemId]!;
    
//     // Recursive function jo focus check karega jab tak mil na jaye
//     void tryFocus(int count) {
//       if (count > 10 || !mounted) return; // Max 10 attempts (1 second total)

//       Future.delayed(Duration(milliseconds: 100), () {
//         if (!mounted) return;
        
//         // Agar node taiyaar hai aur abhi tak focused nahi hai
//         if (nodeToFocus.canRequestFocus && !nodeToFocus.hasFocus) {
//           print("Attempt $count: Requesting focus for $savedItemId");
//           FocusScope.of(context).requestFocus(nodeToFocus);
          
//           // UI aur Scroll sync karein
//           int index = webSeriesList.indexWhere((v) => v.id.toString() == savedItemId);
//           if (index != -1) {
//              _scrollToPosition(index);
//              setState(() => focusedIndex = index);
//           }
//         } else if (!nodeToFocus.hasFocus) {
//           // Agla attempt karein agar focus nahi mila
//           tryFocus(count + 1);
//         }
//       });
//     }
    
//     tryFocus(1);
//   }
// }

//   void _navigateToWebSeriesDetails(WebSeriesModel webSeries) async {
//     final focusProvider = Provider.of<FocusProvider>(context, listen: false);

//     // 1. Current state save karein
//     focusProvider.updateLastFocusedIdentifier('manageWebseries');
//     focusProvider.updateLastFocusedItemId(webSeries.id.toString());

//     try {
//       int? currentUserId = SessionManager.userId;
//       final int? parsedId = webSeries.id;
//       await HistoryService.updateUserHistory(
//           userId: currentUserId!,
//           contentType: 2,
//           eventId: parsedId!,
//           eventTitle: webSeries.name,
//           url: '',
//           categoryId: 0);
//     } catch (e) {}
//     await Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => WebSeriesDetailsPage(
//                 id: webSeries.id,
//                 banner: webSeries.banner ?? webSeries.poster ?? '',
//                 poster: webSeries.poster ?? webSeries.banner ?? '',
//                 logo: webSeries.poster ?? webSeries.banner ?? '',
//                 name: webSeries.name,
//                 updatedAt: webSeries.updatedAt)));

//      _restoreInternalFocus();
  
//   }

//   void _navigateToGridPage() {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) =>
//                 const ProfessionalWebSeriesGridPage(title: 'All Web Series')));
//   }

//   // ✅ ERROR WIDGET (Using Smart Widget)
//   Widget _buildErrorWidget(double height) {
//     return SizedBox(
//       height: height,
//       child: Center(
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 10),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//               color: ProfessionalColorsForHomePages.cardDark.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(50),
//               border: Border.all(
//                   color: ProfessionalColorsForHomePages.accentRed
//                       .withOpacity(0.3))),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline_rounded,
//                   size: 20, color: ProfessionalColorsForHomePages.accentRed),
//               const SizedBox(width: 10),
//               Flexible(
//                   child: Text("Connection Failed",
//                       style: const TextStyle(
//                           color: ProfessionalColorsForHomePages.textPrimary,
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis)),
//               const SizedBox(width: 15),
//               // ✅ Smart Retry Widget
//               SmartRetryWidget(
//                 errorMessage: _errorMessage,
//                 onRetry: fetchWebSeries,
//                 focusNode: _retryFocusNode,
//                 providerIdentifier: 'manageWebseries',
//                 onFocusChange: (hasFocus) {
//                   if (mounted) setState(() => _isSectionFocused = hasFocus);
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
//       return SmartLoadingWidget(
//           itemWidth: effectiveBannerWdt, itemHeight: effectiveBannerHgt);
//     } else if (_errorMessage.isNotEmpty) {
//       // ✅ Smart Error
//       return _buildErrorWidget(effectiveBannerHgt);
//     } else if (webSeriesList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildWebSeriesList();
//     }
//   }

//   Widget _buildEmptyWidget() {
//     return const Center(
//         child: Text("No Web Series Found",
//             style: TextStyle(color: Colors.white, fontSize: 12)));
//   }

//   Widget _buildWebSeriesList() {
//     bool showViewAll = webSeriesList.length > maxHorizontalItems;
//     int itemCount = math.min(webSeriesList.length, maxHorizontalItems);

//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: SizedBox(
//         height: 300,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.none,
//           cacheExtent: 9999,
//           controller: _scrollController,
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           itemCount: showViewAll ? itemCount + 1 : itemCount,
//           itemBuilder: (context, index) {
//             if (showViewAll && index == itemCount) {
//               return _buildViewAllButton();
//             }
//             var webSeries = webSeriesList[index];
//             return _buildWebSeriesItem(webSeries, index);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildWebSeriesItem(WebSeriesModel webSeries, int index) {
//     String webSeriesId = webSeries.id.toString();
//     FocusNode? focusNode = webseriesFocusNodes[webSeriesId];
//     if (focusNode == null) return const SizedBox.shrink();

//     return Focus(
//       focusNode: focusNode,
//       onFocusChange: (hasFocus) {
//         if (mounted)
//           setState(() => _isSectionFocused = hasFocus); // ✅ Shadow Update
//         if (hasFocus) {
//           context.read<FocusProvider>().updateLastFocusedItemId(webSeriesId);
//           Color dominantColor = ProfessionalColorsForHomePages.accentBlue;
//           context.read<ColorProvider>().updateColor(dominantColor, true);
//           setState(() => focusedIndex = index);
//           _scrollToPosition(index);
//         }
//       },
//       // onKey: (node, event) {
//       //   if (event is RawKeyDownEvent) {
//       //     final key = event.logicalKey;
//       //     if (key == LogicalKeyboardKey.arrowRight ||
//       //         key == LogicalKeyboardKey.arrowLeft) {
//       //       if (_isNavigationLocked) return KeyEventResult.handled;
//       //       setState(() => _isNavigationLocked = true);
//       //       _navigationLockTimer = Timer(const Duration(milliseconds: 600), () {
//       //         if (mounted) setState(() => _isNavigationLocked = false);
//       //       });
//       //       if (key == LogicalKeyboardKey.arrowRight) {
//       //         int nextIndex = index + 1;
//       //         if (nextIndex < webSeriesList.length &&
//       //             nextIndex < maxHorizontalItems) {
//       //           FocusScope.of(context).requestFocus(webseriesFocusNodes[
//       //               webSeriesList[nextIndex].id.toString()]);
//       //         } else if (webSeriesList.length > maxHorizontalItems) {
//       //           FocusScope.of(context).requestFocus(_viewAllFocusNode);
//       //         }
//       //       } else if (key == LogicalKeyboardKey.arrowLeft) {
//       //         if (index > 0) {
//       //           FocusScope.of(context).requestFocus(webseriesFocusNodes[
//       //               webSeriesList[index - 1].id.toString()]);
//       //         }
//       //       }
//       //       return KeyEventResult.handled;
//       //     }
//       //     // ✅ Vertical Navigation
//       //     if (key == LogicalKeyboardKey.arrowUp) {
//       //       context.read<ColorProvider>().resetColor();
//       //       context
//       //           .read<FocusProvider>()
//       //           .updateLastFocusedIdentifier('manageWebseries');
//       //       context.read<FocusProvider>().focusPreviousRow();
//       //       _hasReceivedFocusFromMovies = false;
//       //       return KeyEventResult.handled;
//       //     } else if (key == LogicalKeyboardKey.arrowDown) {
//       //       context.read<ColorProvider>().resetColor();
//       //       context
//       //           .read<FocusProvider>()
//       //           .updateLastFocusedIdentifier('manageWebseries');
//       //       context.read<FocusProvider>().focusNextRow();
//       //       _hasReceivedFocusFromMovies = false;
//       //       return KeyEventResult.handled;
//       //     } else if (key == LogicalKeyboardKey.select ||
//       //         key == LogicalKeyboardKey.enter) {
//       //       _navigateToWebSeriesDetails(webSeries);
//       //       return KeyEventResult.handled;
//       //     }
//       //   }
//       //   return KeyEventResult.ignored;
//       // },
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent) {
//           final key = event.logicalKey;
          
//           if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.arrowLeft) {
//             if (_isNavigationLocked) return KeyEventResult.handled;
//             setState(() => _isNavigationLocked = true);
//             _navigationLockTimer = Timer(const Duration(milliseconds: 600), () {
//               if (mounted) setState(() => _isNavigationLocked = false);
//             });

//             if (key == LogicalKeyboardKey.arrowRight) {
//               int nextIndex = index + 1;
//               if (nextIndex < webSeriesList.length && nextIndex < maxHorizontalItems) {
//                 FocusScope.of(context).requestFocus(webseriesFocusNodes[webSeriesList[nextIndex].id.toString()]);
//               } else if (webSeriesList.length > maxHorizontalItems) {
//                 FocusScope.of(context).requestFocus(_viewAllFocusNode);
//               }
//             } 
            
//             // ✅ 1. LEFT ARROW LOGIC UPDATE
//             else if (key == LogicalKeyboardKey.arrowLeft) {
//               if (index > 0) {
//                 FocusScope.of(context).requestFocus(webseriesFocusNodes[webSeriesList[index - 1].id.toString()]);
//               } else {
//                 // Agar Index 0 par left dabaya jaye to sidebar par focus bhejo
//                 _navigationLockTimer?.cancel();
//                 if (mounted) setState(() => _isNavigationLocked = false);
                
//                 context.read<ColorProvider>().resetColor();
//                 context.read<FocusProvider>().requestFocus('activeSidebar');
//               }
//             }
//             return KeyEventResult.handled;
//           }
          
//           // ✅ 2. UP ARROW UPDATE (Banner par jane ke liye)
//           if (key == LogicalKeyboardKey.arrowUp) {
//             // context.read<ColorProvider>().resetColor();
//             // FocusScope.of(context).unfocus();
//             // _hasReceivedFocusFromMovies = false;
//             // context.read<FocusProvider>().requestFocus('watchNow');
//             return KeyEventResult.handled;
            
//           // ✅ 3. DOWN ARROW UPDATE (Next Page ke liye)
//           } 
//           // else if (key == LogicalKeyboardKey.arrowDown) {
//           //   context.read<ColorProvider>().resetColor();
//           //   FocusScope.of(context).unfocus();
//           //   _hasReceivedFocusFromMovies = false;
//           //   context.read<FocusProvider>().triggerDashboardNextPage();
//           //   return KeyEventResult.handled;
            
//           // } 
//           // _buildWebSeriesItem ke onKey handler ke andar
// else if (key == LogicalKeyboardKey.arrowDown) {
//     // context.read<ColorProvider>().resetColor();
//     // FocusScope.of(context).unfocus();
//     // _hasReceivedFocusFromMovies = false;

//     // final fp = context.read<FocusProvider>();
    
//     // // ✅ Agle page ka identifier ('tvShows') set karein
//     // fp.updateLastFocusedIdentifier('tvShows'); 
    
//     // // Dashboard ko next page par move karein
//     // fp.triggerDashboardNextPage();
    
//     return KeyEventResult.handled;
// }
//           else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//             _navigateToWebSeriesDetails(webSeries);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () => _navigateToWebSeriesDetails(webSeries),
//         child: ProfessionalWebSeriesCard(
//           webSeries: webSeries,
//           focusNode: focusNode,
//           onTap: () => _navigateToWebSeriesDetails(webSeries),
//         ),
//       ),
//     );
//   }

//   Widget _buildViewAllButton() {
//     return Focus(
//       focusNode: _viewAllFocusNode,
//       onFocusChange: (hasFocus) {
//         if (mounted)
//           setState(() => _isSectionFocused = hasFocus); // ✅ Shadow Update
//         if (hasFocus)
//           context
//               .read<ColorProvider>()
//               .updateColor(ProfessionalColorsForHomePages.accentBlue, true);
//       },
//       // onKey: (node, event) {
//       //   if (event is RawKeyDownEvent) {
//       //     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {

//       //       return KeyEventResult.handled;
//       //     }
          
//       //     if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       //       FocusScope.of(context).requestFocus(webseriesFocusNodes[
//       //           webSeriesList[maxHorizontalItems - 1].id.toString()]);
//       //       return KeyEventResult.handled;
//       //     }
//       //     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       //       context.read<ColorProvider>().resetColor();
//       //       context
//       //           .read<FocusProvider>()
//       //           .updateLastFocusedIdentifier('manageWebseries');
//       //       context.read<FocusProvider>().focusPreviousRow();
//       //       return KeyEventResult.handled;
//       //     }
//       //     if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       //       context.read<ColorProvider>().resetColor();
//       //       context
//       //           .read<FocusProvider>()
//       //           .updateLastFocusedIdentifier('manageWebseries');
//       //       context.read<FocusProvider>().focusNextRow();
//       //       return KeyEventResult.handled;
//       //     }
//       //     if (event.logicalKey == LogicalKeyboardKey.select ||
//       //         event.logicalKey == LogicalKeyboardKey.enter) {
//       //       _navigateToGridPage();
//       //       return KeyEventResult.handled;
//       //     }
//       //   }
//       //   return KeyEventResult.ignored;
//       // },
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent) {
//           final key = event.logicalKey;
          
//           if (key == LogicalKeyboardKey.arrowRight) {
//             return KeyEventResult.handled;
//           } 
          
//           if (key == LogicalKeyboardKey.arrowLeft) {
//             FocusScope.of(context).requestFocus(webseriesFocusNodes[webSeriesList[maxHorizontalItems - 1].id.toString()]);
//             return KeyEventResult.handled;
//           }
          
//           // ✅ UP ARROW UPDATE
//           if (key == LogicalKeyboardKey.arrowUp) {
//             // context.read<ColorProvider>().resetColor();
//             // context.read<FocusProvider>().requestFocus('watchNow');
//             return KeyEventResult.handled;
//           }
          
//           // // ✅ DOWN ARROW UPDATE
//           // if (key == LogicalKeyboardKey.arrowDown) {
//           //   context.read<ColorProvider>().resetColor();
//           //   context.read<FocusProvider>().triggerDashboardNextPage();
//           //   return KeyEventResult.handled;
//           // }
//           // _buildViewAllButton ke onKey handler ke andar:
// if (key == LogicalKeyboardKey.arrowDown) {
//     // context.read<ColorProvider>().resetColor();
    
//     // final fp = context.read<FocusProvider>();
    
//     // // Agle page ka identifier set karein
//     // fp.updateLastFocusedIdentifier('tvShows');
    
//     // // Dashboard trigger karein
//     // fp.triggerDashboardNextPage();
    
//     return KeyEventResult.handled;
// }
          
//           if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//             _navigateToGridPage();
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: _navigateToGridPage,
//         child: ProfessionalWebSeriesViewAllButton(
//           focusNode: _viewAllFocusNode!,
//           onTap: _navigateToGridPage,
//           totalItems: webSeriesList.length,
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
//         // ✅ CINEMATIC SHADOW LOGIC
//         bool showShadow = _isSectionFocused;

//         return Container(
//               height: containerHeight,
//               child: Stack(
//                 children: [
//                   Column(
//                     children: [
//                       const SizedBox(height: 5),
//                       _buildProfessionalTitle(),
//                       const SizedBox(height: 10),
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

//   Widget _buildProfessionalTitle() {
//     return SlideTransition(
//       position: _headerSlideAnimation,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 25.0),
//         child: Row(
//           children: [
//             ShaderMask(
//               shaderCallback: (bounds) => const LinearGradient(
//                 colors: [
//                   ProfessionalColorsForHomePages.accentPurple,
//                   ProfessionalColorsForHomePages.accentBlue
//                 ],
//               ).createShader(bounds),
//               child: const Text('WEB SERIES',
//                   style: TextStyle(
//                       fontSize: 24,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 2.0)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ... (ProfessionalWebSeriesCard & ProfessionalWebSeriesViewAllButton code remains unchanged) ...
// // Copy them from your existing file.

// class ProfessionalWebSeriesCard extends StatefulWidget {
//   final WebSeriesModel webSeries;
//   final FocusNode focusNode;
//   final VoidCallback onTap;

//   const ProfessionalWebSeriesCard({
//     Key? key,
//     required this.webSeries,
//     required this.focusNode,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesCardState createState() =>
//       _ProfessionalWebSeriesCardState();
// }

// class _ProfessionalWebSeriesCardState extends State<ProfessionalWebSeriesCard>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late Animation<double> _scaleAnimation;
//   bool _isFocused = false;

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
//     setState(() => _isFocused = widget.focusNode.hasFocus);
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
//     final colorProvider = context.watch<ColorProvider>();
//     final dominantColor = colorProvider.isItemFocused && _isFocused
//         ? colorProvider.dominantColor
//         : ProfessionalColorsForHomePages.accentBlue;

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
//                 _buildProfessionalPoster(dominantColor),
//                 _buildProfessionalTitle(dominantColor),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfessionalPoster(Color dominantColor) {
//     final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;
//     return Container(
//       height: posterHeight,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         border: _isFocused ? Border.all(color: dominantColor, width: 3) : null,
//         boxShadow: [
//           if (_isFocused)
//             BoxShadow(
//               color: dominantColor.withOpacity(0.4),
//               blurRadius: 25,
//               spreadRadius: 3,
//               offset: const Offset(0, 8),
//             ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.4),
//             blurRadius: 10,
//             spreadRadius: 2,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Stack(
//           children: [
//             _buildWebSeriesImage(posterHeight),
//             if (_isFocused) _buildHoverOverlay(dominantColor),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWebSeriesImage(double posterHeight) {
//     final String uniqueImageUrl =
//         "${widget.webSeries.banner}?v=${widget.webSeries.updatedAt}";
//     final String uniqueCacheKey =
//         "${widget.webSeries.id.toString()}_${widget.webSeries.updatedAt}";
//     return SizedBox(
//       width: double.infinity,
//       height: posterHeight,
//       child: widget.webSeries.banner != null &&
//               widget.webSeries.banner!.isNotEmpty
//           ? CachedNetworkImage(
//               imageUrl: uniqueImageUrl,
//               fit: BoxFit.cover,
//               memCacheHeight: 250, 
//   memCacheWidth: 200, // Width bhi de dein
//               cacheKey: uniqueCacheKey,
//               placeholder: (context, url) => _buildImagePlaceholder(),
//               errorWidget: (context, url, error) => _buildImagePlaceholder(),
//             )
//           : _buildImagePlaceholder(),
//     );
//   }

//   Widget _buildImagePlaceholder() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalColorsForHomePages.cardDark,
//             ProfessionalColorsForHomePages.surfaceDark
//           ],
//         ),
//       ),
//       child: const Center(
//         child: Icon(Icons.tv_outlined,
//             size: 40, color: ProfessionalColorsForHomePages.textSecondary),
//       ),
//     );
//   }

//   Widget _buildHoverOverlay(Color dominantColor) {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.transparent, dominantColor.withOpacity(0.1)],
//           ),
//         ),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child:
//                 Icon(Icons.play_arrow_rounded, color: dominantColor, size: 30),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(Color dominantColor) {
//     return SizedBox(
//       width: bannerwdt,
//       child: AnimatedDefaultTextStyle(
//         duration: AnimationTiming.medium,
//         style: TextStyle(
//           fontSize: _isFocused ? 13 : 11,
//           fontWeight: FontWeight.w600,
//           color: _isFocused
//               ? dominantColor
//               : ProfessionalColorsForHomePages.primaryDark,
//           letterSpacing: 0.5,
//         ),
//         child: Text(
//           widget.webSeries.name.toUpperCase(),
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// class ProfessionalWebSeriesViewAllButton extends StatefulWidget {
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int totalItems;

//   const ProfessionalWebSeriesViewAllButton({
//     Key? key,
//     required this.focusNode,
//     required this.onTap,
//     required this.totalItems,
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesViewAllButtonState createState() =>
//       _ProfessionalWebSeriesViewAllButtonState();
// }

// class _ProfessionalWebSeriesViewAllButtonState
//     extends State<ProfessionalWebSeriesViewAllButton> {
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (mounted) setState(() => _isFocused = widget.focusNode.hasFocus);
//   }

//   @override
//   void dispose() {
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorProvider = context.watch<ColorProvider>();
//     final dominantColor = colorProvider.isItemFocused && _isFocused
//         ? colorProvider.dominantColor
//         : ProfessionalColorsForHomePages.accentPurple;

//     return Container(
//       width: bannerwdt,
//       margin: const EdgeInsets.symmetric(horizontal: 6),
//       child: Column(
//         children: [
//           AnimatedContainer(
//             duration: AnimationTiming.fast,
//             height: _isFocused ? focussedBannerhgt : bannerhgt,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: _isFocused
//                   ? Border.all(color: dominantColor, width: 3)
//                   : null,
//               gradient: const LinearGradient(
//                 colors: [
//                   ProfessionalColorsForHomePages.cardDark,
//                   ProfessionalColorsForHomePages.surfaceDark
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.grid_view_rounded,
//                     size: 35, color: _isFocused ? dominantColor : Colors.white),
//                 const SizedBox(height: 8),
//                 Text('VIEW ALL',
//                     style: TextStyle(
//                         color: _isFocused ? dominantColor : Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14)),
//               ],
//             ),
//           ),
//           AnimatedDefaultTextStyle(
//             duration: AnimationTiming.medium,
//             style: TextStyle(
//               fontSize: _isFocused ? 13 : 11,
//               fontWeight: FontWeight.w600,
//               color: _isFocused
//                   ? dominantColor
//                   : ProfessionalColorsForHomePages.textPrimary,
//             ),
//             child: const Text('ALL SERIES', textAlign: TextAlign.center),
//           )
//         ],
//       ),
//     );
//   }
// }





import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/webseries_details_page.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/professional_web_series_grid_page.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/widgets/smart_common_horizontal_list.dart';

class ManageWebSeries extends StatefulWidget {
  const ManageWebSeries({super.key});
  @override
  State<ManageWebSeries> createState() => _ManageWebSeriesState();
}

class _ManageWebSeriesState extends State<ManageWebSeries> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<List<CommonContentModel>> fetchWebSeriesAPI() async {
    var url = Uri.parse(SessionManager.baseUrl + 'getAllWebSeries?page1&records=11');
    final response = await https.get(url, headers: {'auth-key': SessionManager.authKey, 'Content-Type': 'application/json', 'domain': SessionManager.savedDomain}).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final dynamic _decoded_jsonData = json.decode(response.body);
      List<dynamic> jsonData = safeDecodeList(_decoded_jsonData);
      var activeData = jsonData.where((item) => item['status'] == 1 || item['status'] == '1').toList();
      activeData.sort((a, b) => (a['series_order'] ?? 9999).compareTo(b['series_order'] ?? 9999));

      return activeData.map((item) => CommonContentModel(
        id: item['id'].toString(), title: item['name'] ?? 'Unknown', imageUrl: item['banner'] ?? item['poster'] ?? '', badgeText: 'HD', originalData: item,
      )).toList();
    } else { throw Exception('Failed to load web series'); }
  }

  Future<void> _onItemTap(CommonContentModel item) async {
    final data = item.originalData;
    try { await HistoryService.updateUserHistory(userId: SessionManager.userId!, contentType: 2, eventId: int.parse(item.id), eventTitle: item.title, url: '', categoryId: 0); } catch (e) {}
    await Navigator.push(context, MaterialPageRoute(builder: (context) => WebSeriesDetailsPage(id: int.parse(item.id), banner: data['banner'] ?? data['poster'] ?? '', poster: data['poster'] ?? data['banner'] ?? '', logo: data['poster'] ?? data['banner'] ?? '', name: item.title, updatedAt: data['updated_at'] ?? '')));
  }

  Future<void> _onViewAllTap() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfessionalWebSeriesGridPage(title: 'All Web Series')));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SmartCommonHorizontalList(
      sectionTitle: "WEB SERIES",
      titleGradient: const [ProfessionalColorsForHomePages.accentPurple, ProfessionalColorsForHomePages.accentBlue],
      accentColor: ProfessionalColorsForHomePages.accentBlue,
      placeholderIcon: Icons.tv_outlined, badgeDefaultText: 'HD',
      focusIdentifier: 'manageWebseries',
      fetchApiData: fetchWebSeriesAPI,
      onItemTap: _onItemTap,
      onViewAllTap: _onViewAllTap, // View All dikhega
      maxVisibleItems: 10,
    );
  }
}
