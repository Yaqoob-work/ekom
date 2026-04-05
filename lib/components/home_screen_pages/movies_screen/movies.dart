




// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_loading_widget.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_retry_widget.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
// // ✅ Import Smart Widgets (Ensure this file exists as created previously)
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // ✅ ==========================================================
// // MODELS & HELPERS
// // ==========================================================

// class AnimationTiming {
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// class Movie {
//   final int id;
//   final String name;
//   final String updatedAt;
//   final String description;
//   final String genres;
//   final String releaseDate;
//   final int? runtime;
//   final String? poster;
//   final String? banner;
//   final String sourceType;
//   final String movieUrl;
//   final List<Network> networks;
//   final int status;
//   final int movieOrder;

//   Movie({
//     required this.id,
//     required this.name,
//     required this.updatedAt,
//     required this.description,
//     required this.genres,
//     required this.releaseDate,
//     this.runtime,
//     this.poster,
//     this.banner,
//     required this.sourceType,
//     required this.movieUrl,
//     required this.networks,
//     required this.status,
//     required this.movieOrder,
//   });

//   factory Movie.fromJson(Map<String, dynamic> json) {
//     return Movie(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       description: json['description'] ?? '',
//       genres: json['genres']?.toString() ?? '',
//       releaseDate: json['release_date'] ?? '',
//       runtime: json['runtime'],
//       poster: json['poster'],
//       banner: json['banner'],
//       sourceType: json['source_type'] ?? '',
//       movieUrl: json['movie_url'] ?? '',
//       networks: (json['networks'] as List?)
//               ?.map((network) => Network.fromJson(network))
//               .toList() ??
//           [],
//       status: json['status'] ?? 0,
//       movieOrder: json['movie_order'] ?? 0,
//     );
//   }
// }

// class Network {
//   final int id;
//   final String name;
//   final String logo;

//   Network({required this.id, required this.name, required this.logo});

//   factory Network.fromJson(Map<String, dynamic> json) {
//     return Network(id: json['id'] ?? 0, name: json['name'] ?? '', logo: json['logo'] ?? '');
//   }
// }

// // Image Helpers
// Widget displayImage(String imageUrl, {double? width, double? height, BoxFit fit = BoxFit.fill}) {
//   if (imageUrl.isEmpty || imageUrl == 'localImage' || imageUrl.contains('localhost')) return _buildImgError(width, height);
//   if (imageUrl.startsWith('data:image')) {
//     try {
//       Uint8List imageBytes = base64Decode(imageUrl.split(',').last);
//       return Image.memory(imageBytes, fit: fit, width: width, height: height, errorBuilder: (c, e, s) => _buildImgError(width, height));
//     } catch (e) { return _buildImgError(width, height); }
//   } else if (imageUrl.startsWith('http')) {
//     if (imageUrl.toLowerCase().endsWith('.svg')) {
//       return SvgPicture.network(imageUrl, width: width, height: height, fit: fit, placeholderBuilder: (c) => _buildImgLoader(width, height));
//     } else {
//       return Image.network(imageUrl, width: width, height: height, fit: fit, headers: const {'User-Agent': 'Flutter App'}, loadingBuilder: (c, child, progress) => progress == null ? child : _buildImgLoader(width, height), errorBuilder: (c, e, s) => _buildImgError(width, height));
//     }
//   } else { return _buildImgError(width, height); }
// }
// Widget _buildImgLoader(double? width, double? height) => SizedBox(width: width, height: height, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))));
// Widget _buildImgError(double? width, double? height) => Container(width: width, height: height, decoration: const BoxDecoration(gradient: LinearGradient(colors: [ProfessionalColorsForHomePages.accentGreen, ProfessionalColorsForHomePages.accentBlue])), child: const Icon(Icons.broken_image, color: Colors.white, size: 24));


// // ✅ ==========================================================
// // MOVIE SERVICE
// // ==========================================================
// class MovieService {
//   static const String _cacheKeyMoviesList = 'cached_movies_list';
//   static const String _cacheKeyMoviesListTimestamp = 'cached_movies_list_timestamp';
//   static const int _cacheDurationMs = 60 * 60 * 1000; 

//   static Future<List<Movie>> getMoviesForList({bool forceRefresh = false}) async {
//     final prefs = await SharedPreferences.getInstance();
//     if (!forceRefresh && await _shouldUseCache(prefs, _cacheKeyMoviesListTimestamp)) {
//       final cachedMovies = await _getCachedMovies(prefs, _cacheKeyMoviesList);
//       if (cachedMovies.isNotEmpty) {
//         _loadFreshListDataInBackground();
//         return cachedMovies;
//       }
//     }
//     return await _fetchFreshMoviesList(prefs);
//   }

//   static Future<bool> _shouldUseCache(SharedPreferences prefs, String timestampKey) async {
//     final timestampStr = prefs.getString(timestampKey);
//     if (timestampStr == null) return false;
//     final cachedTimestamp = int.tryParse(timestampStr);
//     if (cachedTimestamp == null) return false;
//     return DateTime.now().millisecondsSinceEpoch - cachedTimestamp < _cacheDurationMs;
//   }

//   static Future<List<Movie>> _getCachedMovies(SharedPreferences prefs, String cacheKey) async {
//     final cachedData = prefs.getString(cacheKey);
//     if (cachedData == null || cachedData.isEmpty) return [];
//     try {
//       final List<dynamic> jsonData = json.decode(cachedData);
//       return jsonData.where((m) => (m['status'] ?? 0) == 1).map((json) => Movie.fromJson(json)).toList();
//     } catch (e) { return []; }
//   }

//   static Future<List<Movie>> _fetchFreshMoviesList(SharedPreferences prefs) async {
//     try {
//       String authKey = SessionManager.authKey;
//       var url = Uri.parse(SessionManager.baseUrl + 'getAllMovies?records=50');
//       final response = await https.get(url, headers: {'auth-key': authKey, 'Content-Type': 'application/json', 'domain': SessionManager.savedDomain});

//       if (response.statusCode == 200) {
//         final dynamic responseBody = json.decode(response.body);
//         List<dynamic> jsonData = (responseBody is List) ? responseBody : (responseBody['data'] as List);
        
//         final filteredData = jsonData.where((m) => (m['status'] ?? 0) == 1).toList();
//         final movies = filteredData.map((json) => Movie.fromJson(json)).toList();
//         movies.sort((a, b) => a.movieOrder.compareTo(b.movieOrder));
        
//         await _cacheMovies(prefs, filteredData, _cacheKeyMoviesList, _cacheKeyMoviesListTimestamp);
//         return movies;
//       } else { throw Exception('API Error: ${response.statusCode}'); }
//     } catch (e) { rethrow; }
//   }

//   static Future<void> _cacheMovies(SharedPreferences prefs, List<dynamic> data, String dataKey, String timeKey) async {
//     await prefs.setString(dataKey, json.encode(data));
//     await prefs.setString(timeKey, DateTime.now().millisecondsSinceEpoch.toString());
//   }

//   static void _loadFreshListDataInBackground() {
//     Future.delayed(const Duration(milliseconds: 500), () async {
//       try { final prefs = await SharedPreferences.getInstance(); await _fetchFreshMoviesList(prefs); } catch (e) {}
//     });
//   }
// }

// // ✅ ==========================================================
// // MAIN WIDGET: MoviesHorizontalList
// // ==========================================================
// class ProfessionalMoviesHorizontalList extends StatefulWidget {
//   final Function(bool)? onFocusChange;
//   final FocusNode focusNode;
//   final String displayTitle;
//   final int navigationIndex;

//   const ProfessionalMoviesHorizontalList({
//     Key? key,
//     this.onFocusChange,
//     required this.focusNode,
//     this.displayTitle = "RECENTLY ADDED",
//     required this.navigationIndex,
//   }) : super(key: key);

//   @override
//   _ProfessionalMoviesHorizontalListState createState() => _ProfessionalMoviesHorizontalListState();
// }
// class _ProfessionalMoviesHorizontalListState
//     extends State<ProfessionalMoviesHorizontalList>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<Movie> displayMoviesList = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isNavigating = false;
  
//   // ✅ Shadow State
//   bool _isSectionFocused = false;

//   // ✅ FIXED: Defined missing variable
//   Color _currentAccentColor = ProfessionalColorsForHomePages.accentBlue;

//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   Map<String, FocusNode> movieFocusNodes = {};
  
//   // ✅ Retry Focus Node
//   final FocusNode _retryFocusNode = FocusNode();
  
//   final ScrollController _scrollController = ScrollController();
//   final int _maxItemsToShow = 50;
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   @override
//   void initState() {
//     super.initState();
//     SecureUrlService.refreshSettings();
//     _initializeAnimations();
//     _fetchDisplayMovies();
//   }

//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();
//     _retryFocusNode.dispose();
//     _cleanupFocusNodes();
//     _scrollController.dispose();
//     _isNavigating = false;
//     super.dispose();
//   }

//   void _initializeAnimations() {
//     _headerAnimationController = AnimationController(duration: AnimationTiming.slow, vsync: this);
//     _listAnimationController = AnimationController(duration: AnimationTiming.slow, vsync: this);
    
//     _headerSlideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutCubic));
    
//     _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
//         .animate(CurvedAnimation(parent: _listAnimationController, curve: Curves.easeInOut));
//   }

//   Future<void> _fetchDisplayMovies() async {
//     if (!mounted) return;
//     setState(() { _isLoading = true; _errorMessage = ''; });

//     try {
//       final fetchedMovies = await MovieService.getMoviesForList();
//       if (fetchedMovies.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             displayMoviesList = fetchedMovies.take(_maxItemsToShow).toList();
//             _isLoading = false;
//             _initializeMovieFocusNodes();
//           });
//           _headerAnimationController.forward();
//           _listAnimationController.forward();
//           _setupFocusProvider();
//         }
//       } else {
//         if (mounted) setState(() { _errorMessage = 'No movies found'; _isLoading = false; });
//         _setupFocusProvider();
//       }
//     } catch (e) {
//       if (mounted) setState(() { _errorMessage = 'Network error'; _isLoading = false; });
//       _setupFocusProvider();
//     }
//   }

//   void _cleanupFocusNodes() {
//     String? firstMovieId;
//     if (displayMoviesList.isNotEmpty) firstMovieId = displayMoviesList[0].id.toString();
//     for (var entry in movieFocusNodes.entries) {
//       if (entry.key != firstMovieId) {
//         try { entry.value.dispose(); } catch (e) {}
//       }
//     }
//     movieFocusNodes.clear();
//   }

//   void _initializeMovieFocusNodes() {
//     movieFocusNodes.clear();
//     for (var movie in displayMoviesList) {
//       try {
//         String movieId = movie.id.toString();
//         movieFocusNodes[movieId] = FocusNode()
//           ..addListener(() {
//             if (mounted && movieFocusNodes[movieId]!.hasFocus) {
//               _scrollToFocusedItem(movieId);
//             }
//           });
//       } catch (e) {}
//     }
//   }

//   // void _setupFocusProvider() {
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     if (mounted) {
//   //       try {
//   //         final focusProvider = Provider.of<FocusProvider>(context, listen: false);
          
//   //         if (displayMoviesList.isNotEmpty) {
//   //           final firstMovieId = displayMoviesList[0].id.toString();
//   //           if (movieFocusNodes.containsKey(firstMovieId)) {
//   //             focusProvider.registerFocusNode('manageMovies', movieFocusNodes[firstMovieId]!);
//   //           }
//   //         } else if (_errorMessage.isNotEmpty) {
//   //            focusProvider.registerFocusNode('manageMovies', _retryFocusNode);
//   //         }
//   //       } catch (e) {}
//   //     }
//   //   });
//   // }


// void _setupFocusProvider() {
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     if (mounted) {
//       try {
//         final focusProvider = Provider.of<FocusProvider>(context, listen: false);
//         const String myId = 'manageMovies'; // Aapka Page Identifier

//         if (displayMoviesList.isNotEmpty) {
//           final firstMovieId = displayMoviesList[0].id.toString();
//           final firstNode = movieFocusNodes[firstMovieId];

//           if (firstNode != null) {
//             // 1. Register karein
//             focusProvider.registerFocusNode(myId, firstNode);

//             // 2. ✅ CRITICAL FIX: Agar Dashboard isi page par focus bhejna chahta hai
//             if (focusProvider.lastFocusedIdentifier == myId) {
//               firstNode.requestFocus();
//             }
//           }
//         } else if (_errorMessage.isNotEmpty) {
//           focusProvider.registerFocusNode(myId, _retryFocusNode);
//           if (focusProvider.lastFocusedIdentifier == myId) {
//             _retryFocusNode.requestFocus();
//           }
//         }
//       } catch (e) {}
//     }
//   });
// }


//   void _scrollToFocusedItem(String itemId) {
//     if (!mounted || !_scrollController.hasClients) return;
//     try {
//       int index = displayMoviesList.indexWhere((movie) => movie.id.toString() == itemId);
//       if (index == -1) return;
//       double itemWidth = bannerwdt + 12;
//       double targetScrollPosition = (index * itemWidth);
//       targetScrollPosition = targetScrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent);
//       _scrollController.animateTo(targetScrollPosition, duration: AnimationTiming.scroll, curve: Curves.easeOutCubic);
//     } catch (e) {}
//   }

//   Future<void> _handleMovieTap(Movie movie) async {
//     if (_isNavigating) return;
//     _isNavigating = true;

//     try {
//       int? currentUserId = SessionManager.userId;
//       await HistoryService.updateUserHistory(userId: currentUserId!, contentType: 1, eventId: movie.id, eventTitle: movie.name, url: movie.movieUrl, categoryId: 0);
//     } catch (e) {}

//     if (mounted) showDialog(context: context, barrierDismissible: false, builder: (c) => Center(child: CircularProgressIndicator(color: ProfessionalColorsForHomePages.accentBlue)));

//     try {
//       if (mounted) Navigator.of(context, rootNavigator: true).pop();
//       String rawUrl = movie.movieUrl;
      
//       if (mounted) {
//         await Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(
//           videoUrl: rawUrl,
//           bannerImageUrl: movie.banner ?? movie.poster ?? '',
//           channelList: [],
//           source: 'isRecentlyAdded',
//           videoId: movie.id,
//           name: movie.name,
//           liveStatus: false,
//           updatedAt: movie.updatedAt,
//         )));
//       }
//     } catch (e) {
//       if (mounted) Navigator.of(context, rootNavigator: true).pop();
//     } finally {
//       Future.delayed(const Duration(milliseconds: 500), () {
//         if(mounted) _isNavigating = false;
//       });
//     }
//   }

//   // ✅ UPDATED ERROR WIDGET (Using Smart Widget)
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
//                 onRetry: _fetchDisplayMovies,
//                 focusNode: _retryFocusNode,
//                 providerIdentifier: 'manageMovies',
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

//     if (_isLoading) {
//       return SmartLoadingWidget(itemWidth: effectiveBannerWdt, itemHeight: effectiveBannerHgt);
//     } else if (_errorMessage.isNotEmpty) {
//       return _buildErrorWidget(effectiveBannerHgt);
//     } else if (displayMoviesList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildMoviesList(screenWidth, screenHeight);
//     }
//   }

//   Widget _buildEmptyWidget() {
//     return Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.movie_outlined, size: 24, color: Colors.grey), SizedBox(width: 10), Text("No Movies Found", style: TextStyle(color: Colors.white, fontSize: 12))]));
//   }

//   Widget _buildMoviesList(double screenWidth, double screenHeight) {
//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: SizedBox(
//         height: (screenhgt ?? MediaQuery.of(context).size.height) * 0.38,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.none,
//           cacheExtent: 9999,
//           controller: _scrollController,
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//           itemCount: displayMoviesList.length,
//           itemBuilder: (context, index) {
//             var movie = displayMoviesList[index];
//             return _buildMovieItem(movie, index, screenWidth, screenHeight);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildMovieItem(Movie movie, int index, double screenWidth, double screenHeight) {
//     String movieId = movie.id.toString();
//     if (!movieFocusNodes.containsKey(movieId)) return const SizedBox.shrink();

//     return Focus(
//       focusNode: movieFocusNodes[movieId],
//       onFocusChange: (hasFocus) async {
//         if (mounted) setState(() => _isSectionFocused = hasFocus); // ✅ Shadow Update
//         if (hasFocus && mounted) {
//           try {
//             Color dominantColor = ProfessionalColorsForHomePages.accentBlue;
//             // ✅ Fixed: Now _currentAccentColor is defined
//             setState(() { _currentAccentColor = dominantColor; });
//             context.read<ColorProvider>().updateColor(dominantColor, true);
//             widget.onFocusChange?.call(true);
//           } catch (e) {}
//         } else if (mounted) {
//           context.read<ColorProvider>().resetColor();
//           widget.onFocusChange?.call(false);
//         }
//       },
//       // onKey: (node, event) {
//       //   if (event is RawKeyDownEvent) {
//       //     final key = event.logicalKey;
//       //     if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.arrowLeft) {
//       //       if (_isNavigationLocked) return KeyEventResult.handled;
//       //       setState(() => _isNavigationLocked = true);
//       //       _navigationLockTimer = Timer(const Duration(milliseconds: 600), () { if (mounted) setState(() => _isNavigationLocked = false); });
//       //       if (key == LogicalKeyboardKey.arrowRight) {
//       //         if (index < displayMoviesList.length - 1) { String nextId = displayMoviesList[index + 1].id.toString(); FocusScope.of(context).requestFocus(movieFocusNodes[nextId]); } 
//       //         else { _navigationLockTimer?.cancel(); if (mounted) setState(() => _isNavigationLocked = false); }
//       //       } else if (key == LogicalKeyboardKey.arrowLeft) {
//       //         if (index > 0) { String prevId = displayMoviesList[index - 1].id.toString(); FocusScope.of(context).requestFocus(movieFocusNodes[prevId]); } 
//       //         else { _navigationLockTimer?.cancel(); if (mounted) setState(() => _isNavigationLocked = false); }
//       //       }
//       //       return KeyEventResult.handled;
//       //     }
//       //     if (key == LogicalKeyboardKey.arrowUp) {
//       //       context.read<ColorProvider>().resetColor();
//       //       context.read<FocusProvider>().updateLastFocusedIdentifier('manageMovies');
//       //       context.read<FocusProvider>().focusPreviousRow();
//       //       return KeyEventResult.handled;
//       //     } else if (key == LogicalKeyboardKey.arrowDown) {
//       //       context.read<ColorProvider>().resetColor();
//       //       context.read<FocusProvider>().updateLastFocusedIdentifier('manageMovies');
//       //       context.read<FocusProvider>().focusNextRow();
//       //       return KeyEventResult.handled;
//       //     } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
//       //       _handleMovieTap(movie);
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
//               if (index < displayMoviesList.length - 1) { 
//                 String nextId = displayMoviesList[index + 1].id.toString(); 
//                 FocusScope.of(context).requestFocus(movieFocusNodes[nextId]); 
//               } else { 
//                 _navigationLockTimer?.cancel(); 
//                 if (mounted) setState(() => _isNavigationLocked = false); 
//               }
//             } 
            
//             // ✅ 1. LEFT ARROW UPDATE
//             else if (key == LogicalKeyboardKey.arrowLeft) {
//               if (index > 0) { 
//                 String prevId = displayMoviesList[index - 1].id.toString(); 
//                 FocusScope.of(context).requestFocus(movieFocusNodes[prevId]); 
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
//             // context.read<FocusProvider>().requestFocus('watchNow');
//             return KeyEventResult.handled;
            
//           // ✅ 3. DOWN ARROW UPDATE (Next Page ke liye)
//           } 
//           // else if (key == LogicalKeyboardKey.arrowDown) {
//           //   context.read<ColorProvider>().resetColor();
//           //   FocusScope.of(context).unfocus();
//           //   context.read<FocusProvider>().triggerDashboardNextPage();
//           //   return KeyEventResult.handled;
            
//           // }
//           // movies_screen.dart ke andar onKey logic:
// // if (key == LogicalKeyboardKey.arrowDown) {
// //     context.read<ColorProvider>().resetColor();
// //     FocusScope.of(context).unfocus();
    
// //     context.read<FocusProvider>().triggerDashboardNextPage(); 
    

// //     return KeyEventResult.handled;
// // }
// // Movies list ke onKey handler ke andar
// if (key == LogicalKeyboardKey.arrowDown) {
//     // context.read<ColorProvider>().resetColor();
//     // FocusScope.of(context).unfocus();
    
//     // final fp = context.read<FocusProvider>();
    
//     // // Agle row ka ID (e.g., 'manageWebseries') set karein
//     // fp.updateLastFocusedIdentifier('manageWebseries'); 
    
//     // // Dashboard switch trigger karein
//     // fp.triggerDashboardNextPage(); 
    
//     return KeyEventResult.handled;
// }
//            else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
//             _handleMovieTap(movie);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () => _handleMovieTap(movie),
//         child: ProfessionalMovieCard(
//           movie: movie,
//           focusNode: movieFocusNodes[movieId]!,
//           onTap: () => _handleMovieTap(movie),
//           onColorChange: (color) {},
//           index: index,
//           categoryTitle: widget.displayTitle,
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

//         return Container(
//               height: containerHeight,
//               child: Stack(
//                 children: [
//                   Column(
//                     children: [
//                       SizedBox(height: (screenhgt ?? screenHeight) * 0.01),
//                       _buildProfessionalTitle(screenWidth),
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
//                                     Colors.black.withOpacity(0.8), // Top Shadow
//                                     Colors.transparent,
//                                     Colors.transparent,
//                                     Colors.black.withOpacity(0.8), // Bottom Shadow
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
//     // Check if widget.displayTitle is not null, otherwise provide a default
//     // Or if movie name is needed, ensure movie list is not empty
//     String titleText = widget.displayTitle;

//     return SlideTransition(
//       position: _headerSlideAnimation,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//         child: Row(
//           children: [
//             ShaderMask(
//               shaderCallback: (bounds) => const LinearGradient(
//                 colors: [
//                   ProfessionalColorsForHomePages.accentBlue,
//                   ProfessionalColorsForHomePages.accentPurple,
//                 ],
//               ).createShader(bounds),
//               child: Text(
//                 titleText,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
 
// // ✅ Professional Movie Card (Unchanged)
// class ProfessionalMovieCard extends StatefulWidget {
//   final Movie movie;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalMovieCard({
//     Key? key,
//     required this.movie,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalMovieCardState createState() => _ProfessionalMovieCardState();
// }

// class _ProfessionalMovieCardState extends State<ProfessionalMovieCard>
//     with TickerProviderStateMixin {
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

//     _scaleController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _glowController = AnimationController(
//       duration: AnimationTiming.medium,
//       vsync: this,
//     );

//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.06,
//     ).animate(CurvedAnimation(
//       parent: _scaleController,
//       curve: Curves.easeOutCubic,
//     ));

//     _glowAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _glowController,
//       curve: Curves.easeInOut,
//     ));

//     _shimmerAnimation = Tween<double>(
//       begin: -1.0,
//       end: 2.0,
//     ).animate(CurvedAnimation(
//       parent: _shimmerController,
//       curve: Curves.easeInOut,
//     ));

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _scaleController.forward();
//       _glowController.forward();
//       _shimmerController.repeat();
//       _generateDominantColor();
//       widget.onColorChange(_dominantColor);
//       HapticFeedback.lightImpact();
//     } else {
//       _scaleController.reverse();
//       _glowController.reverse();
//       _shimmerController.stop();
//     }
//   }

//   void _generateDominantColor() {
//     _dominantColor = ProfessionalColorsForHomePages.accentBlue;
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     _glowController.dispose();
//     _shimmerController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
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
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.2),
//               blurRadius: 45,
//               spreadRadius: 6,
//               offset: const Offset(0, 15),
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
//             _buildMovieImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildGenreBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMovieImage(double screenWidth, double posterHeight) {
//     final String uniqueImageUrl = "${widget.movie.banner}?v=${widget.movie.updatedAt}";
//     final String uniqueCacheKey = "${widget.movie.id.toString()}_${widget.movie.updatedAt}";
//     return Container(
//       width: double.infinity,
//       height: posterHeight,
//       child: widget.movie.banner != null && widget.movie.banner!.isNotEmpty
//           ? CachedNetworkImage(
//               imageUrl: uniqueImageUrl,
//               fit: BoxFit.cover,
//               memCacheHeight: 250, 
//   memCacheWidth: 200, // Width bhi de dein
//               cacheKey: uniqueCacheKey,
//               placeholder: (context, url) => _buildImagePlaceholder(posterHeight),
//               errorWidget: (context, url, error) => _buildImagePlaceholder(posterHeight),
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
//             Icons.movie_outlined,
//             size: height * 0.25,
//             color: ProfessionalColorsForHomePages.textSecondary,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             widget.categoryTitle,
//             style: TextStyle(
//               color: ProfessionalColorsForHomePages.textSecondary,
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             decoration: BoxDecoration(
//               color: ProfessionalColorsForHomePages.accentBlue.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'HD',
//               style: TextStyle(
//                 color: ProfessionalColorsForHomePages.accentBlue,
//                 fontSize: 8,
//                 fontWeight: FontWeight.bold,
//               ),
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
//                 stops: const [0.0, 0.5, 1.0],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildGenreBadge() {
//     String genre = 'HD';
//     Color badgeColor = ProfessionalColorsForHomePages.accentBlue;

//     if (widget.movie.genres.toLowerCase().contains('comedy')) {
//       genre = 'COMEDY';
//       badgeColor = ProfessionalColorsForHomePages.accentGreen;
//     } else if (widget.movie.genres.toLowerCase().contains('action')) {
//       genre = 'ACTION';
//       badgeColor = ProfessionalColorsForHomePages.accentRed;
//     } else if (widget.movie.genres.toLowerCase().contains('romantic')) {
//       genre = 'ROMANCE';
//       badgeColor = ProfessionalColorsForHomePages.accentPink;
//     } else if (widget.movie.genres.toLowerCase().contains('drama')) {
//       genre = 'DRAMA';
//       badgeColor = ProfessionalColorsForHomePages.accentPurple;
//     }

//     return Positioned(
//       top: 8,
//       right: 8,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//         decoration: BoxDecoration(
//           color: badgeColor.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Text(
//           genre,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 8,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
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
//             child: const Icon(
//               Icons.play_arrow_rounded,
//               color: Colors.white,
//               size: 30,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     final movieName = widget.movie.name.toUpperCase();

//     return Container(
//       width: bannerwdt,
//       child: AnimatedDefaultTextStyle(
//         duration: AnimationTiming.medium,
//         style: TextStyle(
//           fontSize: _isFocused ? 13 : 11,
//           fontWeight: FontWeight.w600,
//           color: _isFocused ? _dominantColor : ProfessionalColorsForHomePages.primaryDark,
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
//           movieName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // Wrapper class for Screen
// class MoviesScreen extends StatefulWidget {
//   const MoviesScreen({super.key});
//   @override
//   _MoviesScreenState createState() => _MoviesScreenState();
// }

// class _MoviesScreenState extends State<MoviesScreen> {
//   final FocusNode _moviesFocusNode = FocusNode();

//   @override
//   void dispose() {
//     _moviesFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: ProfessionalMoviesHorizontalList(
//           focusNode: _moviesFocusNode,
//           displayTitle: "RECENTLY ADDED",
//           navigationIndex: 3,
//           onFocusChange: (bool hasFocus) {
//             print('Movies section focus: $hasFocus');
//           },
//         ),
//       ),
//     );
//   }
// }




import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/widgets/smart_common_horizontal_list.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});
  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<List<CommonContentModel>> fetchMoviesAPI() async {
    var url = Uri.parse(SessionManager.baseUrl + 'getAllMovies?records=50');
    final response = await https.get(url, headers: {'auth-key': SessionManager.authKey, 'Content-Type': 'application/json', 'domain': SessionManager.savedDomain}).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final dynamic responseBody = json.decode(response.body);
      List<dynamic> jsonData = (responseBody is List) ? responseBody : (responseBody['data'] as List);
      var activeData = jsonData.where((m) => m['status'] == 1 || m['status'] == '1').toList();
      activeData.sort((a, b) => (a['movie_order'] ?? 0).compareTo(b['movie_order'] ?? 0));

      return activeData.map((item) {
        String badge = 'HD';
        String rawGenres = (item['genres'] ?? '').toString().toLowerCase();
        if (rawGenres.contains('comedy')) badge = 'COMEDY';
        else if (rawGenres.contains('action')) badge = 'ACTION';
        else if (rawGenres.contains('romantic')) badge = 'ROMANCE';

        return CommonContentModel(id: item['id'].toString(), title: item['name'] ?? 'Unknown', imageUrl: item['banner'] ?? item['poster'] ?? '', badgeText: badge, originalData: item);
      }).toList();
    } else { throw Exception('Failed to load movies'); }
  }

  Future<void> _onItemTap(CommonContentModel item) async {
    final movieData = item.originalData;
    try { await HistoryService.updateUserHistory(userId: SessionManager.userId!, contentType: 1, eventId: int.parse(item.id), eventTitle: item.title, url: movieData['movie_url'] ?? '', categoryId: 0); } catch (e) {}
    await Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(videoUrl: movieData['movie_url'] ?? '', bannerImageUrl: item.imageUrl, channelList: const [], source: 'isRecentlyAdded', videoId: int.parse(item.id), name: item.title, liveStatus: false, updatedAt: movieData['updated_at'] ?? '')));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SmartCommonHorizontalList(
      sectionTitle: "LATEST MOVIES",
      titleGradient: const [ProfessionalColorsForHomePages.accentBlue, ProfessionalColorsForHomePages.accentPurple],
      accentColor: ProfessionalColorsForHomePages.accentBlue,
      placeholderIcon: Icons.movie_outlined, badgeDefaultText: 'HD',
      focusIdentifier: 'manageMovies',
      fetchApiData: fetchMoviesAPI,
      onItemTap: _onItemTap,
      maxVisibleItems: 50, // No view all
    );
  }
}





// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';
// import 'package:mobi_tv_entertainment/components/widgets/smart_common_horizontal_list.dart';

// class MoviesScreen extends StatefulWidget {
//   const MoviesScreen({super.key});
//   @override
//   State<MoviesScreen> createState() => _MoviesScreenState();
// }

// class _MoviesScreenState extends State<MoviesScreen> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   Future<List<CommonContentModel>> fetchMoviesAPI() async {
//     var url = Uri.parse(SessionManager.baseUrl + 'getAllMovies?records=50');
//     final response = await https.get(
//       url, 
//       headers: {
//         'auth-key': SessionManager.authKey, 
//         'Content-Type': 'application/json', 
//         'domain': SessionManager.savedDomain
//       }
//     ).timeout(const Duration(seconds: 30));

//     if (response.statusCode == 200) {
//       final dynamic responseBody = json.decode(response.body);
//       List<dynamic> jsonData = (responseBody is List) ? responseBody : (responseBody['data'] as List);
//       var activeData = jsonData.where((m) => m['status'] == 1 || m['status'] == '1').toList();
      
//       // ✅ SORTING BY MOVIE ORDER
//       activeData.sort((a, b) {
//         // Safely parse movie_order to handle nulls or string values
//         int orderA = a['movie_order'] != null ? int.tryParse(a['movie_order'].toString()) ?? 0 : 0;
//         int orderB = b['movie_order'] != null ? int.tryParse(b['movie_order'].toString()) ?? 0 : 0;
        
//         // Use orderB.compareTo(orderA) for Descending (Highest order first / Latest)
//         // Use orderA.compareTo(orderB) for Ascending (Lowest order first)
//         return orderA.compareTo(orderB); 
//       });

//       return activeData.map((item) {
//         String badge = 'HD';
//         String rawGenres = (item['genres'] ?? '').toString().toLowerCase();
//         if (rawGenres.contains('comedy')) badge = 'COMEDY';
//         else if (rawGenres.contains('action')) badge = 'ACTION';
//         else if (rawGenres.contains('romantic')) badge = 'ROMANCE';

//         return CommonContentModel(
//           id: item['id'].toString(), 
//           title: item['name'] ?? 'Unknown', 
//           imageUrl: item['banner'] ?? item['poster'] ?? '', 
//           badgeText: badge, 
//           originalData: item
//         );
//       }).toList();
//     } else { 
//       throw Exception('Failed to load movies'); 
//     }
//   }

//   Future<void> _onItemTap(CommonContentModel item) async {
//     final movieData = item.originalData;
//     try { 
//       await HistoryService.updateUserHistory(
//         userId: SessionManager.userId!, 
//         contentType: 1, 
//         eventId: int.parse(item.id), 
//         eventTitle: item.title, 
//         url: movieData['movie_url'] ?? '', 
//         categoryId: 0
//       ); 
//     } catch (e) {}
    
//     await Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(
//       videoUrl: movieData['movie_url'] ?? '', 
//       bannerImageUrl: item.imageUrl, 
//       channelList: const [], 
//       source: 'isRecentlyAdded', 
//       videoId: int.parse(item.id), 
//       name: item.title, 
//       liveStatus: false, 
//       updatedAt: movieData['updated_at'] ?? ''
//     )));
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return SmartCommonHorizontalList(
//       sectionTitle: "LATEST MOVIES",
//       titleGradient: const [ProfessionalColorsForHomePages.accentBlue, ProfessionalColorsForHomePages.accentPurple],
//       accentColor: ProfessionalColorsForHomePages.accentBlue,
//       placeholderIcon: Icons.movie_outlined, 
//       badgeDefaultText: 'HD',
//       focusIdentifier: 'manageMovies',
//       fetchApiData: fetchMoviesAPI,
//       onItemTap: _onItemTap,
//       maxVisibleItems: 50, // No view all
//     );
//   }
// }




