// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/webseries_details_page.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
// import 'package:provider/provider.dart';
// import 'dart:math' as math;

// //==============================================================================
// // SECTION 1: COMMON CLASSES, MODELS, AND CONSTANTS
// //==============================================================================

// class ProfessionalColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentPink = Color(0xFFEC4899);
//   static const accentOrange = Color(0xFFF59E0B);
//   static const accentRed = Color(0xFFEF4444);
//   static const accentGreen = Color(0xFF10B981);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
// }

// class AnimationTiming {
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
// }

// class ContentSlider {
//   final int id;
//   final String title;
//   final String? banner;
//   final String? sliderFor;

//   ContentSlider(
//       {required this.id, required this.title, this.banner, this.sliderFor});

//   factory ContentSlider.fromJson(Map<String, dynamic> json) {
//     return ContentSlider(
//       id: json['id'] ?? 0,
//       title: json['title'] ?? 'No Title',
//       banner: json['banner'],
//       sliderFor: json['slider_for'],
//     );
//   }
// }

// class Movie {
//   final int id;
//   final String name;
//   final String? banner;
//   final String? poster;
//   final String? description;
//   final String genres;
//   final int? contentType;
//   final String? sourceType;
//   final String? youtubeTrailer;
//   final String? updatedAt;
//   final String? movieUrl;
//   final int? status;

//   Movie({
//     required this.id,
//     required this.name,
//     this.banner,
//     this.poster,
//     this.description,
//     required this.genres,
//     this.contentType,
//     this.sourceType,
//     this.youtubeTrailer,
//     this.updatedAt,
//     this.movieUrl,
//     this.status,
//   });

//   factory Movie.fromJson(Map<String, dynamic> json) {
//     return Movie(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? 'No Name',
//       banner: json['banner'],
//       poster: json['poster'],
//       description: json['description'],
//       genres: json['genres'] ?? 'Uncategorized',
//       contentType: json['content_type'],
//       sourceType: json['source_type'],
//       youtubeTrailer: json['youtube_trailer'],
//       updatedAt: json['updated_at'],
//       movieUrl: json['movie_url'],
//       status: json['status'],
//     );
//   }

//   String getrawUrl() {
//     if (sourceType == 'YoutubeLive') return movieUrl ?? '';
//     if (youtubeTrailer != null && youtubeTrailer!.isNotEmpty) {
//       return youtubeTrailer!;
//     }
//     return movieUrl ?? '';
//   }
// }

// class MovieResponse {
//   final bool status;
//   final List<Movie> data;
//   final List<ContentSlider> contentSliders;

//   MovieResponse(
//       {required this.status, required this.data, required this.contentSliders});

//   factory MovieResponse.fromJson(Map<String, dynamic> json) {
//     List<T> parseList<T>(
//         String key, T Function(Map<String, dynamic>) fromJson) {
//       if (json[key] is List) {
//         return (json[key] as List)
//             .map((i) => fromJson(i as Map<String, dynamic>))
//             .toList();
//       }
//       return [];
//     }

//     return MovieResponse(
//       status: json['status'] ?? false,
//       data: parseList('data', (i) => Movie.fromJson(i)),
//       contentSliders:
//           parseList('content_sliders', (i) => ContentSlider.fromJson(i)),
//     );
//   }
// }

// // *** NEW CLASS FOR GENRE API RESPONSE ***
// class GenreResponse {
//   final bool status;
//   final List<String> genres;

//   GenreResponse({required this.status, required this.genres});

//   factory GenreResponse.fromJson(Map<String, dynamic> json) {
//     return GenreResponse(
//       status: json['status'] ?? false,
//       genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
//     );
//   }
// }

// //==============================================================================
// // SECTION 2: MAIN PAGE WIDGET AND STATE
// //==============================================================================

// class ContentSliderScreen extends StatefulWidget {
//   final String tvChannelId;
//   final String logoUrl;
//   final String title;
//   const ContentSliderScreen(
//       {super.key,
//       required this.tvChannelId,
//       required this.logoUrl,
//       required this.title});
//   @override
//   State<ContentSliderScreen> createState() => ContentSliderScreenState();
// }

// class ContentSliderScreenState extends State<ContentSliderScreen>
//     with SingleTickerProviderStateMixin {
//   // Data State
//   List<Movie> _allMovies = [];
//   Map<String, List<Movie>> _moviesByGenre = {};
//   List<Movie> _filteredMovies = [];
//   List<String> _genres = [];
//   List<ContentSlider> _contentSliders = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   // UI and Filter State
//   int _focusedGenreIndex = 0;
//   int _focusedMovieIndex = -1;
//   String _selectedGenre = '';
//   late PageController _sliderPageController;
//   int _currentSliderPage = 0;
//   Timer? _sliderTimer;
//   bool _isVideoLoading = false;
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   // Focus and Scroll Controllers
//   final FocusNode _widgetFocusNode = FocusNode();
//   final ScrollController _genreScrollController = ScrollController();
//   final ScrollController _movieScrollController = ScrollController();
//   late FocusNode _searchButtonFocusNode;
//   List<FocusNode> _genreFocusNodes = [];
//   List<FocusNode> _movieFocusNodes = [];
//   List<FocusNode> _keyboardFocusNodes = [];

//   // Search State
//   bool _isSearching = false;
//   bool _showKeyboard = false;
//   String _searchText = '';
//   Timer? _debounce;
//   List<Movie> _searchResults = [];
//   bool _isSearchLoading = false;

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

//   // Performance Fix: Navigation Lock for fast remote presses
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   final List<Color> _focusColors = [
//     ProfessionalColors.accentBlue,
//     ProfessionalColors.accentPurple,
//     ProfessionalColors.accentGreen,
//     ProfessionalColors.accentOrange,
//     ProfessionalColors.accentPink,
//     ProfessionalColors.accentRed
//   ];

//   @override
//   void initState() {
//     super.initState();
//     SecureUrlService.refreshSettings();
//     _sliderPageController = PageController();
//     _searchButtonFocusNode = FocusNode();
//     _fetchDataForPage();
//     _initializeAnimations();
//   }

//   @override
//   void dispose() {
//     _sliderPageController.dispose();
//     _fadeController.dispose();
//     _widgetFocusNode.dispose();
//     _genreScrollController.dispose();
//     _movieScrollController.dispose();
//     _searchButtonFocusNode.dispose();
//     _debounce?.cancel();
//     _sliderTimer?.cancel();
//     _navigationLockTimer?.cancel();

//     _disposeFocusNodes(_genreFocusNodes);
//     _disposeFocusNodes(_movieFocusNodes);
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
//         child: Center(
//           child: Stack(
//             children: [
//               _buildBackgroundOrSlider(),
//               _isLoading
//                   ? const Center(
//                       child: CircularProgressIndicator(color: Colors.white))
//                   : _errorMessage != null
//                       ? _buildErrorWidget()
//                       : _buildPageContent(),
//               if (_isVideoLoading && _errorMessage == null)
//                 Positioned.fill(
//                   child: Container(
//                     color: Colors.black.withOpacity(0.8),
//                     child: const Center(
//                       child: CircularProgressIndicator(color: Colors.white),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   //=================================================
//   // SECTION 2.1: DATA FETCHING AND PROCESSING (UPDATED)
//   //=================================================

//   Future<void> _fetchDataForPage({bool forceRefresh = false}) async {
//     if (!mounted) return;
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final authKey = SessionManager.authKey;
//       final domain = SessionManager.savedDomain;

//       // URLs Setup
//       // Note: Genre API URL based on your requirement
//       var genreUrl = Uri.parse(
//           'https://dashboard.cpplayers.com/api/v3/getGenreByContentNetwork');
//       var movieUrl =
//           Uri.parse(SessionManager.baseUrl + 'getAllContentsOfNetworkNew');

//       final headers = {
//         'auth-key': authKey,
//         'domain': domain, // 'coretechinfo.com' or saved domain
//         'Accept': 'application/json',
//         'Content-Type': 'application/json'
//       };

//       // 1. Parallel API Calls (Fetching Genres and Movies at same time)
//       final results = await Future.wait([
//         // Call 1: Fetch Genres
//         https.post(
//           genreUrl,
//           headers: headers,
//           body: json.encode({
//             "data_for": "",
//             // Parsing network_id to integer as shown in screenshot
//             "network_id": int.tryParse(widget.tvChannelId) ?? 0
//           }),
//         ),
//         // Call 2: Fetch Movies
//         https.post(
//           movieUrl,
//           headers: headers,
//           body: json.encode({
//             "genre": "",
//             "network_id": widget.tvChannelId,
//           }),
//         ),
//       ]);

//       final genreRes = results[0];
//       final movieRes = results[1];

//       if (!mounted) return;

//       if (genreRes.statusCode == 200 && movieRes.statusCode == 200) {
//         // 2. Parsing Responses
//         final genreData = GenreResponse.fromJson(json.decode(genreRes.body));
//         final movieData = MovieResponse.fromJson(json.decode(movieRes.body));

//         if (genreData.status && movieData.status) {
//           _allMovies =
//               movieData.data.where((movie) => movie.status == 1).toList();
//           _contentSliders = movieData.contentSliders
//               .where((s) => s.sliderFor == 'movies')
//               .toList();

//           // 3. Process Data using API Genres
//           _processDataWithApiGenres(genreData.genres);

//           _initializeFocusNodes();
//           _startAnimations();
//           _setupSliderTimer();

//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (mounted) {
//               Provider.of<InternalFocusProvider>(context, listen: false)
//                   .updateName('');
//               if (_searchButtonFocusNode.canRequestFocus) {
//                 _searchButtonFocusNode.requestFocus();
//               }
//             }
//           });
//         } else {
//           throw Exception('API returned status false.');
//         }
//       } else {
//         throw Exception(
//             'API Error. Genres: ${genreRes.statusCode}, Movies: ${movieRes.statusCode}');
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage =
//               "Failed to load content.\nPlease check your connection.";
//         });
//       }
//       print("Error fetching data: $e");
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   // UPDATED FUNCTION: Uses genres from API to organize movies
//   void _processDataWithApiGenres(List<String> apiGenres) {
//     final Map<String, List<Movie>> moviesByGenre = {};

//     // 1. Create list from API response
//     List<String> sortedGenres = List.from(apiGenres);

//     // 2. Priority Sorting for "Web Series"
//     if (sortedGenres.contains('Web Series')) {
//       sortedGenres.remove('Web Series');
//       // sortedGenres.sort(); // Uncomment if you want A-Z sorting for others
//       sortedGenres.insert(0, 'Web Series');
//     }

//     // 3. Initialize Map with empty lists for all API genres
//     for (var genre in sortedGenres) {
//       moviesByGenre[genre] = [];
//     }

//     // 4. Distribute movies into genres
//     for (final movie in _allMovies) {
//       // Split movie genres string (e.g. "Action, Drama")
//       final movieGenresList = movie.genres
//           .split(',')
//           .map((g) => g.trim())
//           .where((g) => g.isNotEmpty)
//           .toList();

//       // Check if movie belongs to any of our API genres
//       for (var movieGenre in movieGenresList) {
//         if (moviesByGenre.containsKey(movieGenre)) {
//           moviesByGenre[movieGenre]!.add(movie);
//         }
//       }
//     }

//     setState(() {
//       _moviesByGenre = moviesByGenre;
//       _genres = sortedGenres;
//       if (_genres.isNotEmpty) {
//         _selectedGenre = _genres[0];
//       }
//     });

//     _applyFilters();
//   }

//   //=================================================
//   // SECTION 2.2: KEYBOARD AND FOCUS NAVIGATION
//   //=================================================

//   KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
//     if (event is! RawKeyDownEvent) return KeyEventResult.ignored;

//     bool searchHasFocus = _searchButtonFocusNode.hasFocus;
//     bool genreHasFocus = _genreFocusNodes.any((n) => n.hasFocus);
//     bool movieHasFocus = _movieFocusNodes.any((n) => n.hasFocus);
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
//       return KeyEventResult.ignored; // Allow navigator to pop
//     }

//     if (keyboardHasFocus && _showKeyboard) {
//       return _navigateKeyboard(key);
//     }

//     if (searchHasFocus) return _navigateFromSearch(key);
//     if (genreHasFocus) return _navigateGenres(key);
//     if (movieHasFocus) return _navigateMovies(key);

//     return KeyEventResult.ignored;
//   }

//   KeyEventResult _navigateFromSearch(LogicalKeyboardKey key) {
//     if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       setState(() => _showKeyboard = true);
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && _keyboardFocusNodes.isNotEmpty) {
//           _keyboardFocusNodes[0].requestFocus();
//         }
//       });
//       return KeyEventResult.handled;
//     }
//     if (key == LogicalKeyboardKey.arrowRight && _genreFocusNodes.isNotEmpty) {
//       _genreFocusNodes[0].requestFocus();
//       return KeyEventResult.handled;
//     }
//     if (key == LogicalKeyboardKey.arrowDown && _movieFocusNodes.isNotEmpty) {
//       _focusFirstMovieItemWithScroll();
//       return KeyEventResult.handled;
//     }
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateGenres(LogicalKeyboardKey key) {
//     int newIndex = _focusedGenreIndex;
//     if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newIndex > 0) {
//         newIndex--;
//       } else {
//         _searchButtonFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       if (newIndex < _genres.length - 1) {
//         newIndex++;
//       }
//     } else if (key == LogicalKeyboardKey.arrowDown ||
//         key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       _updateSelectedGenre();
//       if (_movieFocusNodes.isNotEmpty) {
//         _focusFirstMovieItemWithScroll();
//       }
//       return KeyEventResult.handled;
//     }

//     if (newIndex != _focusedGenreIndex) {
//       setState(() => _focusedGenreIndex = newIndex);
//       _genreFocusNodes[newIndex].requestFocus();
//       _updateAndScrollToFocus(
//           _genreFocusNodes, newIndex, _genreScrollController, 160);
//     }
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateMovies(LogicalKeyboardKey key) {
//     if (_isNavigationLocked) return KeyEventResult.handled;
//     if (_focusedMovieIndex < 0 || _movieFocusNodes.isEmpty) {
//       return KeyEventResult.ignored;
//     }

//     setState(() => _isNavigationLocked = true);
//     _navigationLockTimer = Timer(const Duration(milliseconds: 600), () {
//       if (mounted) setState(() => _isNavigationLocked = false);
//     });

//     int newIndex = _focusedMovieIndex;
//     final currentList = _isSearching ? _searchResults : _filteredMovies;

//     if (key == LogicalKeyboardKey.arrowUp) {
//       _genreFocusNodes[_focusedGenreIndex].requestFocus();
//       setState(() => _focusedMovieIndex = -1);
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.arrowLeft) {
//       if (newIndex > 0) newIndex--;
//     } else if (key == LogicalKeyboardKey.arrowRight) {
//       if (newIndex < currentList.length - 1) newIndex++;
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       _isNavigationLocked = false;
//       _navigationLockTimer?.cancel();
//       _playContent(currentList[_focusedMovieIndex]);
//       return KeyEventResult.handled;
//     }

//     if (newIndex != _focusedMovieIndex) {
//       setState(() => _focusedMovieIndex = newIndex);
//       if (newIndex < _movieFocusNodes.length) {
//         _movieFocusNodes[newIndex].requestFocus();
//         _updateAndScrollToFocus(_movieFocusNodes, newIndex,
//             _movieScrollController, (screenwdt / 7) + 12);
//       }
//     } else {
//       _navigationLockTimer?.cancel();
//       if (mounted) setState(() => _isNavigationLocked = false);
//     }

//     return KeyEventResult.handled;
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
//     setState(() {
//       _filteredMovies = _moviesByGenre[_selectedGenre] ?? [];
//       _filteredMovies.shuffle();
//       _rebuildMovieFocusNodes();
//       _focusedMovieIndex = -1;
//     });
//   }

//   void _updateSelectedGenre() {
//     setState(() {
//       _selectedGenre = _genres[_focusedGenreIndex];
//       _applyFilters();
//     });
//   }

//   void _performSearch(String searchTerm) {
//     _debounce?.cancel();
//     if (searchTerm.trim().isEmpty) {
//       setState(() {
//         _isSearching = false;
//         _isSearchLoading = false;
//         _searchResults.clear();
//         _rebuildMovieFocusNodes();
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

//       final results = _allMovies
//           .where((movie) =>
//               movie.name.toLowerCase().contains(searchTerm.toLowerCase()))
//           .toList();

//       if (!mounted) return;
//       setState(() {
//         _searchResults = results;
//         _isSearchLoading = false;
//         _rebuildMovieFocusNodes();
//       });
//     });
//   }

//   void _onKeyPressed(String value) {
//     setState(() {
//       if (value == 'OK') {
//         _showKeyboard = false;
//         if (_movieFocusNodes.isNotEmpty) {
//           _movieFocusNodes.first.requestFocus();
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

//   Future<void> _playContent(Movie content) async {
//     if (_isVideoLoading || !mounted) return;
//     setState(() => _isVideoLoading = true);

//     try {
//       // String rawUrl = content.getrawUrl();
//       String rawUrl = content.getrawUrl();
//       print('rawurl: $rawUrl');
//       // String rawUrl = await SecureUrlService.getSecureUrl(rawUrl);
//       // print('rawUrl: $rawUrl');
//       if (content.contentType == 2) {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => WebSeriesDetailsPage(
//               id: content.id,
//               banner: content.banner ?? '',
//               poster: content.poster ?? '',
//               logo: widget.logoUrl,
//               name: content.name,
//               updatedAt: content.updatedAt ?? '',
//             ),
//           ),
//         );
//       } else if (rawUrl.isNotEmpty) {
//         if (content.sourceType == 'YoutubeLive' ||
//             (content.youtubeTrailer != null &&
//                 content.youtubeTrailer!.isNotEmpty)) {
//           final deviceInfo = context.read<DeviceInfoProvider>();
//           if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//             await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => YoutubeWebviewPlayer(
//                         videoUrl: rawUrl, name: content.name)));
//           } else {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => CustomYoutubePlayer(
//                   videoData: VideoData(
//                     id: content.id.toString(),
//                     title: content.name,
//                     youtubeUrl: rawUrl,
//                     thumbnail: content.poster ?? content.banner ?? '',
//                     description: content.description ?? '',
//                   ),
//                   playlist: const [],
//                 ),
//               ),
//             );
//           }
//         } else {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => VideoScreen(
//                 videoUrl: rawUrl,
//                 bannerImageUrl: content.poster ?? content.banner ?? '',
//                 videoId: content.id,
//                 name: content.name,
//                 updatedAt: content.updatedAt ?? '',
//                 source: 'isVod',
//                 channelList: const [],
//                 liveStatus: false,
//               ),
//             ),
//           );
//         }
//       } else {
//         throw Exception('No playable video URL found.');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error playing content: ${e.toString()}')));
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isVideoLoading = false);
//       }
//     }
//   }

//   void _setupSliderTimer() {
//     _sliderTimer?.cancel();
//     if (_contentSliders.length > 1) {
//       _sliderTimer = Timer.periodic(const Duration(seconds: 8), (Timer timer) {
//         if (!mounted || !_sliderPageController.hasClients) return;
//         int nextPage = (_sliderPageController.page?.round() ?? 0) + 1;
//         if (nextPage >= _contentSliders.length) {
//           nextPage = 0;
//         }
//         _sliderPageController.animateToPage(
//           nextPage,
//           duration: const Duration(milliseconds: 800),
//           curve: Curves.easeInOut,
//         );
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
//     _disposeFocusNodes(_genreFocusNodes);
//     _genreFocusNodes =
//         List.generate(_genres.length, (i) => FocusNode(debugLabel: 'Genre-$i'));
//     _rebuildMovieFocusNodes();
//     _rebuildKeyboardFocusNodes();
//   }

//   void _rebuildMovieFocusNodes() {
//     _disposeFocusNodes(_movieFocusNodes);
//     final currentList = _isSearching ? _searchResults : _filteredMovies;
//     _movieFocusNodes = List.generate(
//         currentList.length, (i) => FocusNode(debugLabel: 'Movie-$i'));
//   }

//   void _rebuildKeyboardFocusNodes() {
//     _disposeFocusNodes(_keyboardFocusNodes);
//     int totalKeys = _keyboardLayout.fold(0, (prev, row) => prev + row.length);
//     _keyboardFocusNodes = List.generate(
//         totalKeys, (index) => FocusNode(debugLabel: 'Key-$index'));
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
//     double scrollPosition =
//         (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
//     controller.animateTo(
//       scrollPosition.clamp(0.0, controller.position.maxScrollExtent),
//       duration: AnimationTiming.fast,
//       curve: Curves.easeInOut,
//     );
//   }

//   void _focusFirstMovieItemWithScroll() {
//     if (_movieFocusNodes.isEmpty) return;
//     if (_movieScrollController.hasClients) {
//       _movieScrollController.animateTo(0.0,
//           duration: AnimationTiming.fast, curve: Curves.easeInOut);
//     }
//     Future.delayed(const Duration(milliseconds: 250), () {
//       if (mounted && _movieFocusNodes.isNotEmpty) {
//         setState(() => _focusedMovieIndex = 0);
//         _movieFocusNodes[0].requestFocus();
//       }
//     });
//   }

//   //=================================================
//   // SECTION 2.5: WIDGET BUILDER METHODS
//   //=================================================

//   Widget _buildPageContent() {
//     return Column(
//       children: [
//         _buildBeautifulAppBar(),
//         Expanded(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: _buildContentBody(),
//           ),
//         ),
//       ],
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
//         SizedBox(height: screenhgt * 0.01),
//         _buildMoviesList(),
//       ],
//     );
//   }

//   Widget _buildBackgroundOrSlider() {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         if (_contentSliders.isNotEmpty)
//           PageView.builder(
//             controller: _sliderPageController,
//             itemCount: _contentSliders.length,
//             onPageChanged: (index) {
//               if (mounted) setState(() => _currentSliderPage = index);
//             },
//             itemBuilder: (context, index) {
//               final slider = _contentSliders[index];
//               return Image.network(
//                 slider.banner ?? '',
//                 fit: BoxFit.cover,
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return Container(color: ProfessionalColors.surfaceDark);
//                 },
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(color: ProfessionalColors.surfaceDark);
//                 },
//               );
//             },
//           )
//         else
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColors.primaryDark,
//                   ProfessionalColors.surfaceDark,
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//         Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 ProfessionalColors.primaryDark.withOpacity(0.2),
//                 ProfessionalColors.primaryDark.withOpacity(0.4),
//                 ProfessionalColors.primaryDark.withOpacity(0.6),
//                 ProfessionalColors.primaryDark.withOpacity(0.9),
//               ],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               stops: const [0.0, 0.5, 0.7, 0.9],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBeautifulAppBar() {
//     final focusedName = context.watch<InternalFocusProvider>().focusedItemName;

//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: EdgeInsets.only(
//             top: screenhgt * 0.02,
//             bottom: 2,
//             left: screenwdt * 0.03,
//             right: 20,
//           ),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Colors.black.withOpacity(0.1),
//                 Colors.black.withOpacity(0.0),
//               ],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//             border: Border(
//               bottom: BorderSide(
//                 color: Colors.white.withOpacity(0.1),
//                 width: 1,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               GradientText(
//                 widget.title,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 24,
//                 ),
//                 gradient: const LinearGradient(
//                   colors: [
//                     ProfessionalColors.accentPink,
//                     ProfessionalColors.accentPurple,
//                     ProfessionalColors.accentBlue,
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 24),
//               Expanded(
//                 child: Text(
//                   focusedName,
//                   style: const TextStyle(
//                     color: ProfessionalColors.textSecondary,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               if (widget.logoUrl.isNotEmpty)
//                 SizedBox(
//                   height: screenhgt * 0.05,
//                   child: Image.network(
//                     widget.logoUrl,
//                     errorBuilder: (context, error, stackTrace) =>
//                         const SizedBox.shrink(),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGenreAndSearchButtons() {
//     return SizedBox(
//       height: 30,
//       child: Center(
//         child: ListView.builder(
//           controller: _genreScrollController,
//           scrollDirection: Axis.horizontal,
//           cacheExtent: 9999,
//           itemCount: _genres.length + 1, // +1 for Search button
//           padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.03),
//           itemBuilder: (context, index) {
//             if (index == 0) {
//               return Focus(
//                 focusNode: _searchButtonFocusNode,
//                 onFocusChange: (hasFocus) {
//                   if (hasFocus) {
//                     Provider.of<InternalFocusProvider>(context, listen: false)
//                         .updateName("Search");
//                   }
//                 },
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
//                   child: const Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.search, color: Colors.white),
//                       SizedBox(width: 8),
//                       Text(
//                         "SEARCH",
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

//             final genreIndex = index - 1;
//             final genre = _genres[genreIndex];
//             final focusNode = _genreFocusNodes[genreIndex];
//             final isSelected = !_isSearching && _selectedGenre == genre;

//             return Focus(
//               focusNode: focusNode,
//               onFocusChange: (hasFocus) {
//                 if (hasFocus) {
//                   setState(() => _focusedGenreIndex = genreIndex);
//                   Provider.of<InternalFocusProvider>(context, listen: false)
//                       .updateName(genre);
//                 }
//               },
//               child: _buildGlassEffectButton(
//                 focusNode: focusNode,
//                 isSelected: isSelected,
//                 focusColor: _focusColors[genreIndex % _focusColors.length],
//                 onTap: () {
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

//   Widget _buildMoviesList() {
//     final currentList = _isSearching ? _searchResults : _filteredMovies;

//     if (_isSearchLoading) {
//       return const Expanded(child: Center(child: CircularProgressIndicator()));
//     }

//     if (currentList.isEmpty) {
//       return Expanded(
//         child: Center(
//           child: Text(
//             _isSearching && _searchText.isNotEmpty
//                 ? "No results found for '$_searchText'"
//                 : 'No movies available for this filter.',
//             style: const TextStyle(
//                 color: ProfessionalColors.textSecondary, fontSize: 16),
//           ),
//         ),
//       );
//     }
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.only(top: 1.0),
//         child: ListView.builder(
//           clipBehavior: Clip.none,
//           cacheExtent: 9999,
//           controller: _movieScrollController,
//           scrollDirection: Axis.horizontal,
//           padding: const EdgeInsets.symmetric(horizontal: 30.0),
//           itemCount: currentList.length,
//           itemBuilder: (context, index) {
//             final movie = currentList[index];
//             return InkWell(
//               focusNode: _movieFocusNodes[index],
//               onTap: () => _playContent(movie),
//               onFocusChange: (hasFocus) {
//                 if (hasFocus) {
//                   setState(() => _focusedMovieIndex = index);
//                   Provider.of<InternalFocusProvider>(context, listen: false)
//                       .updateName(movie.name);
//                   _updateAndScrollToFocus(_movieFocusNodes, index,
//                       _movieScrollController, (screenwdt / 7) + 12);
//                 }
//               },
//               child: MovieCard(
//                 movie: movie,
//                 isFocused: _focusedMovieIndex == index,
//                 onTap: () => _playContent(movie),
//                 cardHeight: bannerhgt * 1.1,
//                 logoUrl: widget.logoUrl,
//                 uniqueIndex: index,
//                 focusColors: _focusColors,
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
//                 const Text(
//                   "Search Movies",
//                   style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white),
//                 ),
//                 const SizedBox(height: 24),
//                 Container(
//                   width: double.infinity,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                         color: ProfessionalColors.accentPurple, width: 2),
//                   ),
//                   child: Text(
//                     _searchText.isEmpty ? 'Start typing...' : _searchText,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color:
//                           _searchText.isEmpty ? Colors.white54 : Colors.white,
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
//         mainAxisAlignment: MainAxisAlignment.center,
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
//         final isFocused =
//             _focusedKeyRow == rowIndex && _focusedKeyCol == colIndex;
//         double width;
//         if (key == ' ') {
//           width = screenwdt * 0.315;
//         } else if (key == 'OK' || key == 'DEL') {
//           width = screenwdt * 0.09;
//         } else {
//           width = screenwdt * 0.045;
//         }

//         return Container(
//           width: width,
//           height: screenhgt * 0.08,
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
//     if (_contentSliders.length <= 1) {
//       return const SizedBox.shrink();
//     }
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(_contentSliders.length, (index) {
//         bool isActive = _currentSliderPage == index;
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
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
//               decoration: BoxDecoration(
//                 color: hasFocus
//                     ? focusColor
//                     : isSelected
//                         ? focusColor.withOpacity(0.5)
//                         : Colors.white.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(30),
//                 border: Border.all(
//                   color:
//                       hasFocus ? Colors.white : Colors.white.withOpacity(0.3),
//                   width: hasFocus ? 3 : 2,
//                 ),
//                 boxShadow: hasFocus
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
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.cloud_off, color: Colors.white, size: 50),
//           const SizedBox(height: 16),
//           Text(
//             _errorMessage ?? 'An unknown error occurred.',
//             style: const TextStyle(color: Colors.white, fontSize: 18),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: () => _fetchDataForPage(forceRefresh: true),
//             icon: const Icon(Icons.refresh),
//             label: const Text('Try Again'),
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: ProfessionalColors.accentBlue,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// //==============================================================================
// // SECTION 3: REUSABLE UI COMPONENTS
// //==============================================================================

// class MovieCard extends StatelessWidget {
//   final Movie movie;
//   final bool isFocused;
//   final VoidCallback onTap;
//   final double cardHeight;
//   final String logoUrl;
//   final int uniqueIndex;
//   final List<Color> focusColors;

//   const MovieCard({
//     super.key,
//     required this.movie,
//     required this.isFocused,
//     required this.onTap,
//     required this.cardHeight,
//     required this.logoUrl,
//     required this.uniqueIndex,
//     required this.focusColors,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final focusColor = focusColors[uniqueIndex % focusColors.length];

//     return Container(
//       width: screenwdt / 7,
//       margin: const EdgeInsets.only(right: 12.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           SizedBox(
//             height: cardHeight,
//             child: AnimatedContainer(
//               duration: AnimationTiming.fast,
//               transform: isFocused
//                   ? (Matrix4.identity()..scale(1.05))
//                   : Matrix4.identity(),
//               transformAlignment: Alignment.center,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8.0),
//                   border: isFocused
//                       ? Border.all(color: focusColor, width: 3)
//                       : Border.all(color: Colors.transparent, width: 3),
//                   boxShadow: isFocused
//                       ? [
//                           BoxShadow(
//                               color: focusColor.withOpacity(0.5),
//                               blurRadius: 12,
//                               spreadRadius: 1)
//                         ]
//                       : []),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(6.0),
//                 child: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     _buildMovieImage(),
//                     if (isFocused)
//                       Positioned(
//                           left: 5,
//                           top: 5,
//                           child: Container(
//                               color: Colors.black.withOpacity(0.4),
//                               child: Icon(Icons.play_circle_filled_outlined,
//                                   color: focusColor, size: 40))),
//                     if (logoUrl.isNotEmpty)
//                       Positioned(
//                           top: 5,
//                           right: 5,
//                           child: CircleAvatar(
//                               radius: 12,
//                               backgroundImage: NetworkImage(logoUrl),
//                               backgroundColor: Colors.black54)),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 2.0, left: 2.0, right: 2.0),
//             child: Text(movie.name,
//                 style: TextStyle(
//                     color: isFocused
//                         ? focusColor
//                         : ProfessionalColors.textSecondary,
//                     fontSize: 14,
//                     fontWeight:
//                         isFocused ? FontWeight.bold : FontWeight.normal),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMovieImage() {
//     final imageUrl = movie.banner;
//     return imageUrl != null && imageUrl.isNotEmpty
//         ? Image.network(
//             imageUrl,
//             fit: BoxFit.cover,
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return _buildImagePlaceholder();
//             },
//             errorBuilder: (context, error, stackTrace) {
//               return _buildImagePlaceholder();
//             },
//           )
//         : _buildImagePlaceholder();
//   }

//   Widget _buildImagePlaceholder() {
//     return Container(
//       color: ProfessionalColors.cardDark,
//       child: Center(
//         child: Icon(
//           Icons.movie_creation_outlined,
//           size: 50,
//           color: ProfessionalColors.textSecondary.withOpacity(0.5),
//         ),
//       ),
//     );
//   }
// }

// class GradientText extends StatelessWidget {
//   const GradientText(
//     this.text, {
//     super.key,
//     required this.gradient,
//     this.style,
//   });

//   final String text;
//   final TextStyle? style;
//   final Gradient gradient;

//   @override
//   Widget build(BuildContext context) {
//     return ShaderMask(
//       blendMode: BlendMode.srcIn,
//       shaderCallback: (bounds) => gradient.createShader(
//         Rect.fromLTWH(0, 0, bounds.width, bounds.height),
//       ),
//       child: Text(text, style: style),
//     );
//   }
// }








// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:provider/provider.dart';
// import 'dart:math' as math;

// // Your imports - keep as-is
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/webseries_details_page.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
// import 'package:mobi_tv_entertainment/components/widgets/smart_style_image_card.dart';

// const double itemSpacing = 15.0;
// const double genreItemWidth = 120.0;

// class ProfessionalColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentPink = Color(0xFFEC4899);
//   static const accentOrange = Color(0xFFF59E0B);
//   static const accentRed = Color(0xFFEF4444);
//   static const accentGreen = Color(0xFF10B981);
//   static const accentTeal = Color(0xFF06B6D4);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
// }

// class AnimationTiming {
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
// }

// class Movie {
//   final int id;
//   final String name;
//   final String? banner;
//   final String genres;
//   final String? description;
//   final int? contentType;
//   final String? sourceType;
//   final String? youtubeTrailer;
//   final String? updatedAt;
//   final String? movieUrl;
//   final int? status;

//   Movie({
//     required this.id,
//     required this.name,
//     this.banner,
//     required this.genres,
//     this.description,
//     this.contentType,
//     this.sourceType,
//     this.youtubeTrailer,
//     this.updatedAt,
//     this.movieUrl,
//     this.status,
//   });

//   factory Movie.fromJson(Map<String, dynamic> json) => Movie(
//         id: json['id'] ?? 0,
//         name: json['name'] ?? 'No Name',
//         banner: json['banner'],
//         genres: json['genres'] ?? 'Uncategorized',
//         description: json['description'],
//         contentType: json['content_type'],
//         sourceType: json['source_type'],
//         youtubeTrailer: json['youtube_trailer'],
//         updatedAt: json['updated_at'],
//         movieUrl: json['movie_url'],
//         status: json['status'],
//       );

//   String getrawUrl() {
//     if (sourceType == 'YoutubeLive') return movieUrl ?? '';
//     if (youtubeTrailer != null && youtubeTrailer!.isNotEmpty) return youtubeTrailer!;
//     return movieUrl ?? '';
//   }
// }

// class ContentSlider {
//   final String? banner;
//   ContentSlider({this.banner});
//   factory ContentSlider.fromJson(Map<String, dynamic> json) => ContentSlider(banner: json['banner']);
// }

// class ContentSliderScreen extends StatefulWidget {
//   final String tvChannelId;
//   final String logoUrl;
//   final String title;
//   const ContentSliderScreen({super.key, required this.tvChannelId, required this.logoUrl, required this.title});

//   @override
//   State<ContentSliderScreen> createState() => ContentSliderScreenState();
// }

// class ContentSliderScreenState extends State<ContentSliderScreen> with SingleTickerProviderStateMixin {
//   // Data
//   List<Movie> _allMovies = [];
//   Map<String, List<Movie>> _moviesByGenre = {};
//   List<Movie> _filteredMovies = [];
//   List<String> _genres = [];
//   List<ContentSlider> _contentSliders = [];

//   // Flags
//   bool _isLoading = true;
//   bool _isSearching = false;
//   bool _isVideoLoading = false;
//   bool _isGenreSwitching = false;
//   bool _isProcessing = false;
//   bool _isDisposed = false;
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;
//   static const Duration _navigationLockDuration = Duration(milliseconds: 500);

//   // Focus
//   int _focusedGenreIndex = 0;
//   int _focusedMovieIndex = -1;
//   String _selectedGenre = '';

//   // Controllers
//   late PageController _sliderPageController;
//   int _currentSliderPage = 0;
//   Timer? _sliderTimer;

//   final FocusNode _widgetFocusNode = FocusNode();
//   final ScrollController _genreScrollController = ScrollController();
//   final ScrollController _movieScrollController = ScrollController();
//   late FocusNode _searchButtonFocusNode;

//   List<FocusNode> _genreFocusNodes = [];
//   List<FocusNode> _movieFocusNodes = [];
//   List<FocusNode> _keyboardFocusNodes = [];

//   // Screen & Padding Calculation
//   double _screenWidth = 0;

//   // Search
//   bool _showKeyboard = false;
//   String _searchText = '';
//   List<Movie> _searchResults = [];
//   int _focusedKeyRow = 0;
//   int _focusedKeyCol = 0;
//   final List<List<String>> _keyboardLayout = [
//     "1234567890".split(''),
//     "qwertyuiop".split(''),
//     "asdfghjkl".split(''),
//     ["z", "x", "c", "v", "b", "n", "m", "DEL"],
//     ["SPACE", "OK"],
//   ];

//   // 🔥 COLOR CHANGING SYSTEM
//   final List<Color> _focusColors = [
//     ProfessionalColors.accentBlue,
//     ProfessionalColors.accentPurple,
//     ProfessionalColors.accentGreen,
//     ProfessionalColors.accentOrange,
//     ProfessionalColors.accentPink,
//     ProfessionalColors.accentRed,
//     ProfessionalColors.accentTeal,
//   ];

//   // Animations
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _isDisposed = false; // 🔥 Initialize
//     _sliderPageController = PageController();
//     _searchButtonFocusNode = FocusNode();
//     _initializeAnimations();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_isDisposed) {
//         setState(() {
//           _screenWidth = MediaQuery.of(context).size.width;
//         });
//         _fetchData();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _isDisposed = true; // 🔥 MARK AS DISPOSED FIRST
    
//     // Cancel all timers
//     _sliderTimer?.cancel();
//     _sliderTimer = null;
    
//     _genreChangeDebounce?.cancel();
//     _genreChangeDebounce = null;
//     _navigationLockTimer?.cancel();
    
//     // Dispose controllers
//     _sliderPageController.dispose();
//     _fadeController.dispose();
    
//     // Dispose scroll controllers
//     _genreScrollController.dispose();
//     _movieScrollController.dispose();
    
//     // Dispose all focus nodes
//     _widgetFocusNode.dispose();
//     _searchButtonFocusNode.dispose();
//     _disposeAllFocusNodes();
    
//     super.dispose();
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       duration: AnimationTiming.medium,
//       vsync: this,
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     );
//   }

//   // 🔥 ENHANCED: Dispose all focus nodes safely
//   void _disposeAllFocusNodes() {
//     // Clear keyboard focus first
//     FocusManager.instance.primaryFocus?.unfocus();
    
//     // Dispose genre focus nodes
//     for (var node in _genreFocusNodes) {
//       try {
//         node.dispose();
//       } catch (e) {
//         print('Error disposing genre focus node: $e');
//       }
//     }
//     _genreFocusNodes.clear();
    
//     // Dispose movie focus nodes
//     for (var node in _movieFocusNodes) {
//       try {
//         node.dispose();
//       } catch (e) {
//         print('Error disposing movie focus node: $e');
//       }
//     }
//     _movieFocusNodes.clear();
    
//     // Dispose keyboard focus nodes
//     for (var node in _keyboardFocusNodes) {
//       try {
//         node.dispose();
//       } catch (e) {
//         print('Error disposing keyboard focus node: $e');
//       }
//     }
//     _keyboardFocusNodes.clear();
//   }

//   Future<void> _fetchData() async {
//     if (_isDisposed) return; // 🔥 CHECK IF DISPOSED
    
//     try {
//       final headers = {
//         'auth-key': SessionManager.authKey, 
//         'domain': SessionManager.savedDomain, 
//         'Content-Type': 'application/json'
//       };
      
//       final results = await Future.wait([
//         https.post(
//           Uri.parse(SessionManager.baseUrl + 'getGenreByContentNetwork'), 
//           headers: headers, 
//           body: json.encode({"network_id": int.tryParse(widget.tvChannelId) ?? 0})
//         ),
//         https.post(
//           Uri.parse(SessionManager.baseUrl + 'getAllContentsOfNetworkNew'), 
//           headers: headers, 
//           body: json.encode({"network_id": widget.tvChannelId})
//         ),
//       ]);

//       if (_isDisposed) return; // 🔥 CHECK AGAIN AFTER AWAIT

//       if (results[0].statusCode == 200 && results[1].statusCode == 200) {
//         final gData = json.decode(results[0].body);
//         final mData = json.decode(results[1].body);

//         _allMovies = (mData['data'] as List).map((i) => Movie.fromJson(i)).where((m) => m.status == 1).toList();
//         _contentSliders = (mData['content_sliders'] as List).map((i) => ContentSlider.fromJson(i)).toList();
//         _genres = List<String>.from(gData['genres'] ?? []);

//         if (_genres.contains('Web Series')) {
//           _genres.remove('Web Series');
//           _genres.insert(0, 'Web Series');
//         }
        
//         // 🔥 OPTIMIZED: Pre-compute movies by genre
//         final moviesByGenreTemp = <String, List<Movie>>{};
//         for (var g in _genres) {
//           moviesByGenreTemp[g] = _allMovies.where((m) => m.genres.contains(g)).toList();
//         }
//         _moviesByGenre = moviesByGenreTemp;

//         if (!_isDisposed && mounted) {
//           setState(() {
//             if (_genres.isNotEmpty) _selectedGenre = _genres[0];
//             _filteredMovies = _moviesByGenre[_selectedGenre] ?? [];
//             _isLoading = false;
//           });
          
//           _rebuildNodes();
//           _setupSliderTimer();
//           _fadeController.forward();
          
//           // 🔥 DELAYED FOCUS WITH SAFETY CHECK
//           Future.delayed(const Duration(milliseconds: 300), () {
//             if (!_isDisposed && mounted && _searchButtonFocusNode.canRequestFocus) {
//               _searchButtonFocusNode.requestFocus();
//             }
//           });
//         }
//       }
//     } catch (e) {
//       if (!_isDisposed && mounted) {
//         setState(() => _isLoading = false);
//       }
//       print('Fetch data error: $e');
//     }
//   }

//   void _rebuildNodes() {
//     if (_isDisposed) return;
    
//     // Dispose old nodes first
//     _disposeAllFocusNodes();
    
//     // Create new nodes
//     _genreFocusNodes = List.generate(_genres.length, (i) => FocusNode());
//     _rebuildMovieFocusNodes();
//     _rebuildKeyboardFocusNodes();
//   }

//   void _rebuildMovieFocusNodes() {
//     if (_isDisposed) return;
    
//     // Dispose old movie nodes
//     for (var node in _movieFocusNodes) {
//       try { node.dispose(); } catch (e) {}
//     }
//     _movieFocusNodes.clear();
    
//     // Create new ones
//     final list = _isSearching ? _searchResults : _filteredMovies;
//     _movieFocusNodes = List.generate(list.length, (i) => FocusNode());
//   }

//   void _rebuildKeyboardFocusNodes() {
//     if (_isDisposed) return;
    
//     // Dispose old keyboard nodes
//     for (var node in _keyboardFocusNodes) {
//       try { node.dispose(); } catch (e) {}
//     }
//     _keyboardFocusNodes.clear();
    
//     // Create new ones
//     int total = _keyboardLayout.fold(0, (p, r) => p + r.length);
//     _keyboardFocusNodes = List.generate(total, (i) => FocusNode());
//   }

//   void _setupSliderTimer() {
//     _sliderTimer?.cancel();
//     if (_contentSliders.length > 1) {
//       _sliderTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//         if (_isDisposed || !_sliderPageController.hasClients) {
//           timer.cancel();
//           return;
//         }
//         int next = (_sliderPageController.page?.round() ?? 0) + 1;
//         if (next >= _contentSliders.length) next = 0;
//         _sliderPageController.animateToPage(
//           next, 
//           duration: const Duration(milliseconds: 800), 
//           curve: Curves.easeInOut
//         );
//       });
//     }
//   }

//   // ===============================================
//   // SEPARATE SCROLL FUNCTIONS
//   // ===============================================

//   void _scrollGenreToFocus(int index) {
//     if (_isDisposed || !_genreScrollController.hasClients) return;

//     try {
//       double screenWidth = MediaQuery.of(context).size.width;
      
//       double genreItemTotalWidth = genreItemWidth + 24;
//       double genreListViewPadding = 40.0;
//       double firstItemLeftPadding = genreListViewPadding + (index == 0 ? 0 : 12);
//       double itemPosition = firstItemLeftPadding + (index * genreItemTotalWidth);
      
//       double itemCenter = itemPosition + (genreItemWidth / 2);
//       double screenCenter = screenWidth / 2;
//       double targetOffset = itemCenter - screenCenter;

//       if (targetOffset < 0) targetOffset = 0;
//       if (targetOffset > _genreScrollController.position.maxScrollExtent) {
//         targetOffset = _genreScrollController.position.maxScrollExtent;
//       }

//       _genreScrollController.animateTo(
//         targetOffset,
//         duration: AnimationTiming.fast,
//         curve: Curves.easeOutCubic,
//       );
//     } catch (e) {
//       // Silent fail
//     }
//   }

//   void _scrollMovieToFocus(int index) {
//     if (_isDisposed || !_movieScrollController.hasClients) return;

//     try {
//       double screenWidth = MediaQuery.of(context).size.width;
      
//       double movieItemTotalWidth = bannerwdt + itemSpacing;
//       double movieListViewPadding = 40.0;
//       double firstItemLeftPadding = movieListViewPadding;
//       double itemPosition = firstItemLeftPadding + (index * movieItemTotalWidth);
      
//       double itemCenter = itemPosition + (bannerwdt / 2);
//       double screenCenter = screenWidth / 2;
//       double targetOffset = itemCenter - screenCenter;

//       if (targetOffset < 0) targetOffset = 0;
//       if (targetOffset > _movieScrollController.position.maxScrollExtent) {
//         targetOffset = _movieScrollController.position.maxScrollExtent;
//       }

//       _movieScrollController.animateTo(
//         targetOffset,
//         duration: AnimationTiming.fast,
//         curve: Curves.easeOutCubic,
//       );
//     } catch (e) {
//       // Silent fail
//     }
//   }

//   // ===============================================
//   // NAVIGATION WITH CRASH PROTECTION
//   // ===============================================
//   KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
//     if (_isDisposed) return KeyEventResult.handled; // 🔥 SAFETY CHECK
    
//     if (event is! RawKeyDownEvent) return KeyEventResult.ignored;

//     if (_isProcessing || _isGenreSwitching || _isDisposed) {
//       return KeyEventResult.handled;
//     }

//     final key = event.logicalKey;

//     if (key == LogicalKeyboardKey.goBack) {
//       if (_showKeyboard) {
//         setState(() => _showKeyboard = false);
//         _searchButtonFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.ignored;
//     }

//     if (_showKeyboard) return _navigateKeyboard(key);
//     if (_searchButtonFocusNode.hasFocus) return _navigateSearch(key);
//     if (_genreFocusNodes.any((n) => n.hasFocus)) return _navigateGenres(key);
//     if (_movieFocusNodes.any((n) => n.hasFocus)) return _navigateMovies(key);

//     return KeyEventResult.ignored;
//   }

//   KeyEventResult _navigateSearch(LogicalKeyboardKey key) {
//     if (_isDisposed) return KeyEventResult.handled;
    
//     if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       setState(() => _showKeyboard = true);
//       if (_keyboardFocusNodes.isNotEmpty) _keyboardFocusNodes[0].requestFocus();
//     } else if (key == LogicalKeyboardKey.arrowRight && _genreFocusNodes.isNotEmpty) {
//       _genreFocusNodes[0].requestFocus();
//     } else if (key == LogicalKeyboardKey.arrowDown && _movieFocusNodes.isNotEmpty) {
//       _focusMovieAtIndex(0);
//     }
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateGenres(LogicalKeyboardKey key) {
//     if (_isDisposed || _genreFocusNodes.isEmpty || _genres.isEmpty) {
//       return KeyEventResult.handled;
//     }
    
//     if (_focusedGenreIndex < 0 || _focusedGenreIndex >= _genres.length) {
//       _focusedGenreIndex = 0;
//     }

//     int i = _focusedGenreIndex;

//     if (key == LogicalKeyboardKey.arrowLeft) {
//       if (i > 0) {
//         i--;
//       } else {
//         _searchButtonFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight && i < _genres.length - 1) {
//       i++;
//     } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _changeGenre(i);
//       return KeyEventResult.handled;
//     }

//     if (i != _focusedGenreIndex && i >= 0 && i < _genreFocusNodes.length) {
//       setState(() => _focusedGenreIndex = i);
//       _genreFocusNodes[i].requestFocus();
//       _scrollGenreToFocus(i + 1);
//     }
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateMovies(LogicalKeyboardKey key) {
//     if (_isDisposed) return KeyEventResult.handled;
    
//     final list = _isSearching ? _searchResults : _filteredMovies;
    
//     if (list.isEmpty || _movieFocusNodes.isEmpty) return KeyEventResult.handled;
//     if (_isNavigationLocked) return KeyEventResult.handled;
//     _isNavigationLocked = true;
//     _navigationLockTimer?.cancel();
//     _navigationLockTimer = Timer(_navigationLockDuration, () {
//       if (!_isDisposed && mounted) setState(() => _isNavigationLocked = false);
//     });
    
//     if (_focusedMovieIndex < 0 || _focusedMovieIndex >= _movieFocusNodes.length) {
//       _focusedMovieIndex = 0;
//     }
//     if (_focusedMovieIndex >= list.length) {
//       _focusedMovieIndex = list.length - 1;
//     }

//     int i = _focusedMovieIndex;

//     if (key == LogicalKeyboardKey.arrowUp) {
//       setState(() => _focusedMovieIndex = -1);
//       if (_focusedGenreIndex >= 0 && _focusedGenreIndex < _genreFocusNodes.length) {
//         _genreFocusNodes[_focusedGenreIndex].requestFocus();
//       }
//       return KeyEventResult.handled;
//     }

//     if (key == LogicalKeyboardKey.arrowLeft && i > 0) {
//       i--;
//     } else if (key == LogicalKeyboardKey.arrowRight && i < list.length - 1) {
//       i++;
//     } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       if (i >= 0 && i < list.length) {
//         _playContent(list[i]);
//       }
//       return KeyEventResult.handled;
//     }

//     if (i >= 0 && i < _movieFocusNodes.length && i < list.length) {
//       if (i != _focusedMovieIndex) {
//         setState(() => _focusedMovieIndex = i);
//         _movieFocusNodes[i].requestFocus();
//         _scrollMovieToFocus(i);
//       }
//     }
//     return KeyEventResult.handled;
//   }

//   // ===============================================
//   // GENRE CHANGE
//   // ===============================================
//   Timer? _genreChangeDebounce;

//   void _changeGenre(int index) {
//     if (_isDisposed || _isGenreSwitching || _isProcessing) return;
//     if (index < 0 || index >= _genres.length) return;

//     _genreChangeDebounce?.cancel();
//     _genreChangeDebounce = Timer(const Duration(milliseconds: 50), () {
//       if (!_isDisposed && mounted) {
//         _executeGenreChange(index);
//       }
//     });
//   }

//   void _executeGenreChange(int index) {
//     if (_isDisposed) return;
    
//     _isGenreSwitching = true;

//     final newGenre = _genres[index];
//     final newMovies = _moviesByGenre[newGenre] ?? [];

//     setState(() {
//       _focusedGenreIndex = index;
//       _selectedGenre = newGenre;
//       _isSearching = false;
//       _searchResults = [];
//       _searchText = '';
//       _focusedMovieIndex = -1;
//     });

//     Future.microtask(() {
//       if (_isDisposed || !mounted) {
//         _isGenreSwitching = false;
//         return;
//       }

//       // Dispose old nodes
//       for (var node in _movieFocusNodes) {
//         try { node.dispose(); } catch (e) {}
//       }
//       _movieFocusNodes.clear();

//       setState(() {
//         _filteredMovies = newMovies;
//         _movieFocusNodes = List.generate(_filteredMovies.length, (_) => FocusNode());
//       });

//       if (_movieScrollController.hasClients) {
//         try {
//           _movieScrollController.jumpTo(0);
//         } catch (_) {}
//       }

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_isDisposed || !mounted) {
//           _isGenreSwitching = false;
//           return;
//         }

//         if (_movieFocusNodes.isNotEmpty) {
//           setState(() => _focusedMovieIndex = 0);
          
//           Future.delayed(const Duration(milliseconds: 100), () {
//             if (!_isDisposed && mounted && _movieFocusNodes.isNotEmpty) {
//               try {
//                 _movieFocusNodes[0].requestFocus();
//               } catch (_) {}
//             }
//             _isGenreSwitching = false;
//           });
//         } else {
//           _isGenreSwitching = false;
//         }
//       });
//     });
//   }

//   void _focusMovieAtIndex(int index) {
//     if (_isDisposed || !mounted) return;
    
//     if (_movieFocusNodes.isEmpty) return;
//     if (index < 0 || index >= _movieFocusNodes.length) return;

//     final list = _isSearching ? _searchResults : _filteredMovies;
//     if (index >= list.length) return;

//     setState(() => _focusedMovieIndex = index);
    
//     Future.delayed(const Duration(milliseconds: 50), () {
//       if (_isDisposed || !mounted) return;
//       if (index >= 0 && index < _movieFocusNodes.length) {
//         _movieFocusNodes[index].requestFocus();
//       }
//     });
    
//     if (_movieScrollController.hasClients) {
//       _scrollMovieToFocus(index);
//     }
//   }

//   KeyEventResult _navigateKeyboard(LogicalKeyboardKey key) {
//     if (_isDisposed) return KeyEventResult.handled;
    
//     int r = _focusedKeyRow;
//     int c = _focusedKeyCol;
//     if (key == LogicalKeyboardKey.arrowUp && r > 0) {
//       r--;
//     } else if (key == LogicalKeyboardKey.arrowDown && r < _keyboardLayout.length - 1) {
//       r++;
//       c = math.min(c, _keyboardLayout[r].length - 1);
//     } else if (key == LogicalKeyboardKey.arrowLeft && c > 0) {
//       c--;
//     } else if (key == LogicalKeyboardKey.arrowRight && c < _keyboardLayout[r].length - 1) {
//       c++;
//     } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _onKeyClick(_keyboardLayout[r][c]);
//       return KeyEventResult.handled;
//     }

//     setState(() {
//       _focusedKeyRow = r;
//       _focusedKeyCol = c;
//     });
//     int idx = 0;
//     for (int i = 0; i < r; i++) idx += _keyboardLayout[i].length;
//     if (idx + c < _keyboardFocusNodes.length) {
//       _keyboardFocusNodes[idx + c].requestFocus();
//     }
//     return KeyEventResult.handled;
//   }

//   void _onKeyClick(String val) {
//     if (_isDisposed) return;
    
//     setState(() {
//       if (val == "OK") {
//         _showKeyboard = false;
//         _searchButtonFocusNode.requestFocus();
//       } else if (val == "DEL") {
//         if (_searchText.isNotEmpty) _searchText = _searchText.substring(0, _searchText.length - 1);
//       } else if (val == "SPACE") {
//         _searchText += " ";
//       } else {
//         _searchText += val;
//       }
//       _performSearch(_searchText);
//     });
//   }

//   void _performSearch(String t) {
//     if (_isDisposed) return;
    
//     setState(() {
//       if (t.isEmpty) {
//         _isSearching = false;
//         _searchResults = [];
//       } else {
//         _isSearching = true;
//         _searchResults = _allMovies.where((m) => m.name.toUpperCase().contains(t.toUpperCase())).toList();
//       }
//       _rebuildMovieFocusNodes();
//     });
//   }

//   // ===============================================
//   // PLAY CONTENT WITH CRASH PROTECTION
//   // ===============================================
//   Future<void> _playContent(Movie m) async {
//     if (_isDisposed || _isProcessing) return;
    
//     setState(() {
//       _isProcessing = true;
//       _isVideoLoading = true;
//     });

//     try {
//       String rawUrl = m.getrawUrl();
      
//       // 🔥 SAFE NAVIGATION WITH ERROR HANDLING
//       if (m.contentType == 2) {
//         final result = await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (c) => WebSeriesDetailsPage(
//               id: m.id,
//               banner: m.banner ?? '',
//               poster: '',
//               logo: widget.logoUrl,
//               name: m.name,
//               updatedAt: m.updatedAt ?? '',
//             ),
//           ),
//         ).catchError((e) {
//           print('Navigation error: $e');
//           return null;
//         });
//       } else if (rawUrl.isNotEmpty) {
//         final deviceInfo = context.read<DeviceInfoProvider>();
//         if (m.sourceType == 'YoutubeLive' || (m.youtubeTrailer != null && m.youtubeTrailer!.isNotEmpty)) {
//           if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (c) => YoutubeWebviewPlayer(videoUrl: rawUrl, name: m.name),
//               ),
//             ).catchError((e) {
//               print('YoutubeWebviewPlayer navigation error: $e');
//               return null;
//             });
//           } else {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (c) => CustomYoutubePlayer(
//                   videoData: VideoData(
//                     id: m.id.toString(),
//                     title: m.name,
//                     youtubeUrl: rawUrl,
//                     thumbnail: m.banner ?? '',
//                     description: m.description ?? '',
//                   ),
//                   playlist: const [],
//                 ),
//               ),
//             ).catchError((e) {
//               print('CustomYoutubePlayer navigation error: $e');
//               return null;
//             });
//           }
//         } else {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (c) => VideoScreen(
//                 videoUrl: rawUrl,
//                 bannerImageUrl: m.banner ?? '',
//                 videoId: m.id,
//                 name: m.name,
//                 updatedAt: m.updatedAt ?? '',
//                 source: 'isVod',
//                 channelList: const [],
//                 liveStatus: false,
//               ),
//             ),
//           ).catchError((e) {
//             print('VideoScreen navigation error: $e');
//             return null;
//           });
//         }
//       }
//     } catch (e) {
//       print('Play content error: $e');
//       if (!_isDisposed && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${e.toString()}'),
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     } finally {
//       if (!_isDisposed && mounted) {
//         setState(() {
//           _isProcessing = false;
//           _isVideoLoading = false;
//         });
//       }
//     }
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
//             _buildBackgroundSlider(),
//             if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.white))
//             else FadeTransition(
//               opacity: _fadeAnimation,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   // 🔥 FIXED: AppBar height reduced by 50%
//                   SizedBox(
//                     height: MediaQuery.of(context).padding.top + 60, // Reduced from 80 to 40
//                     child: _buildBeautifulAppBar(),
//                   ),
//                   const Spacer(),
//                   if (_showKeyboard) _buildSearchUI(),
//                   _buildSliderIndicators(),
//                   const SizedBox(height: 10),
//                   _buildGenreBarWithGlassEffect(),
//                   const SizedBox(height: 15),
//                   SizedBox(
//                     height: bannerhgt * 1.5,
//                     child: _buildMoviesRowWithColorSystem(),
//                   ),
//                   const SizedBox(height: 15),
//                 ],
//               ),
//             ),
//             if (_isVideoLoading) Positioned.fill(
//               child: Container(
//                 color: Colors.black54,
//                 child: const Center(child: CircularProgressIndicator(color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBackgroundSlider() {
//     return RepaintBoundary(
//       child: Stack(
//         children: [
//           if (_contentSliders.isNotEmpty)
//             PageView.builder(
//               controller: _sliderPageController,
//               itemCount: _contentSliders.length,
//               onPageChanged: (i) {
//                 if (!_isDisposed) {
//                   setState(() => _currentSliderPage = i);
//                 }
//               },
//               itemBuilder: (c, i) => Image.network(
//                 _contentSliders[i].banner ?? '',
//                 fit: BoxFit.cover,
//                 cacheHeight: 1080,
//                 gaplessPlayback: true,
//                 errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return Container(color: Colors.black);
//                 },
//               ),
//             ),
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.transparent,
//                     ProfessionalColors.primaryDark.withOpacity(0.5),
//                     ProfessionalColors.primaryDark
//                   ],
//                   stops: const [0.3, 0.6, 1.0],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 🔥 UPDATED APP BAR WITH REDUCED HEIGHT
//   Widget _buildBeautifulAppBar() {
//     final focusName = context.watch<InternalFocusProvider>().focusedItemName;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10), // Reduced padding
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.black.withOpacity(0.1),
//             Colors.black.withOpacity(0.0),
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.white.withOpacity(0.1),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           GradientText(
//             widget.title,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 26, // Reduced font size
//             ),
//             gradient: const LinearGradient(
//               colors: [
//                 ProfessionalColors.accentPink,
//                 ProfessionalColors.accentPurple,
//                 ProfessionalColors.accentBlue,
//               ],
//             ),
//           ),
//           const SizedBox(width: 20), // Reduced spacing
//           Expanded(
//             child: Text(
//               focusName,
//               style: const TextStyle(
//                 color: ProfessionalColors.textSecondary,
//                 fontWeight: FontWeight.w600, // Lighter weight
//                 fontSize: 20, // Reduced font size
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           if (widget.logoUrl.isNotEmpty)
//             SizedBox(
//               height: 30, // Reduced logo size
//               child: Image.network(
//                 widget.logoUrl,
//                 errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchUI() {
//     return Container(
//       height: 200,
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.symmetric(horizontal: 40),
//       child: Row(
//         children: [
//           Expanded(
//             child: Center(
//               child: Text(
//                 _searchText.isEmpty ? "SEARCH..." : _searchText,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(flex: 2, child: _buildKeyboardKeys()),
//         ],
//       ),
//     );
//   }

//   Widget _buildKeyboardKeys() {
//     int nodeIdx = 0;
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: _keyboardLayout.asMap().entries.map((rEntry) {
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: rEntry.value.asMap().entries.map((cEntry) {
//             final key = cEntry.value;
//             final isFocused = _focusedKeyRow == rEntry.key && _focusedKeyCol == cEntry.key;
//             final idx = nodeIdx++;
//             double w = (key == "SPACE") ? 150 : (key == "OK" || key == "DEL" ? 60 : 35);
//             return Container(
//               margin: const EdgeInsets.all(2),
//               width: w,
//               height: 32,
//               child: Focus(
//                 focusNode: idx < _keyboardFocusNodes.length ? _keyboardFocusNodes[idx] : FocusNode(),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: isFocused ? ProfessionalColors.accentPurple : Colors.black87,
//                     borderRadius: BorderRadius.circular(4),
//                     border: Border.all(
//                       color: isFocused ? Colors.white : Colors.white10,
//                       width: isFocused ? 2 : 1,
//                     ),
//                     boxShadow: isFocused
//                         ? [
//                             BoxShadow(
//                               color: ProfessionalColors.accentPurple.withOpacity(0.5),
//                               blurRadius: 8,
//                               spreadRadius: 1,
//                             )
//                           ]
//                         : null,
//                   ),
//                   child: Center(
//                     child: Text(
//                       key,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 11,
//                         fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildGenreBarWithGlassEffect() {
//     return SizedBox(
//       height: 38,
//       child: ListView.builder(
//         controller: _genreScrollController,
//         scrollDirection: Axis.horizontal,
//         itemCount: _genres.length + 1,
//         padding: const EdgeInsets.symmetric(horizontal: 40),
//         itemBuilder: (context, index) {
//           if (index == 0) {
//             return _buildGlassEffectButton(
//               focusNode: _searchButtonFocusNode,
//               label: "SEARCH",
//               icon: Icons.search,
//               isSelected: _isSearching,
//               focusColor: ProfessionalColors.accentOrange,
//               marginLeft: 0,
//               marginRight: 12,
//               onFocusChange: (hasFocus) {
//                 if (hasFocus && !_isDisposed && mounted) {
//                   Provider.of<InternalFocusProvider>(context, listen: false).updateName("SEARCH");
//                 }
//               },
//               onTap: () {
//                 if (!_isDisposed) {
//                   _searchButtonFocusNode.requestFocus();
//                   setState(() => _showKeyboard = true);
//                   if (_keyboardFocusNodes.isNotEmpty) {
//                     _keyboardFocusNodes[0].requestFocus();
//                   }
//                 }
//               },
//             );
//           }

//           final genreIndex = index - 1;
//           final genre = _genres[genreIndex];
//           final focusNode = _genreFocusNodes[genreIndex];
//           final isSelected = !_isSearching && _selectedGenre == genre;
//           final focusColor = _focusColors[genreIndex % _focusColors.length];

//           return _buildGlassEffectButton(
//             focusNode: focusNode,
//             label: genre.toUpperCase(),
//             icon: null,
//             isSelected: isSelected,
//             focusColor: focusColor,
//             marginLeft: 12,
//             marginRight: 12,
//             onFocusChange: (hasFocus) {
//               if (hasFocus && !_isDisposed && mounted) {
//                 setState(() => _focusedGenreIndex = genreIndex);
//                 Provider.of<InternalFocusProvider>(context, listen: false).updateName(genre);
//               }
//             },
//             onTap: () {
//               if (!_isDisposed) {
//                 focusNode.requestFocus();
//                 _changeGenre(genreIndex);
//               }
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildGlassEffectButton({
//     required FocusNode focusNode,
//     required String label,
//     required IconData? icon,
//     required bool isSelected,
//     required Color focusColor,
//     required double marginLeft,
//     required double marginRight,
//     required Function(bool) onFocusChange,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: EdgeInsets.only(left: marginLeft, right: marginRight),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(30),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//             child: Focus(
//               focusNode: focusNode,
//               onFocusChange: onFocusChange,
//               child: AnimatedContainer(
//                 duration: AnimationTiming.fast,
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: focusNode.hasFocus
//                       ? focusColor
//                       : isSelected
//                           ? focusColor.withOpacity(0.5)
//                           : Colors.white.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(30),
//                   border: Border.all(
//                     color: focusNode.hasFocus ? Colors.white : Colors.white.withOpacity(0.3),
//                     width: focusNode.hasFocus ? 3 : 2,
//                   ),
//                   boxShadow: focusNode.hasFocus
//                       ? [
//                           BoxShadow(
//                             color: focusColor.withOpacity(0.8),
//                             blurRadius: 15,
//                             spreadRadius: 3,
//                           )
//                         ]
//                       : null,
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (icon != null) ...[
//                       Icon(icon, color: Colors.white, size: 16),
//                       const SizedBox(width: 8),
//                     ],
//                     Text(
//                       label,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMoviesRowWithColorSystem() {
//     final list = _isSearching ? _searchResults : _filteredMovies;
//     if (list.isEmpty) return const Center(child: Text("No Content Available", style: TextStyle(color: Colors.white54)));

//     final safeItemCount = math.min(list.length, _movieFocusNodes.length);

//     return ListView.builder(
//       key: ValueKey('movies_${_selectedGenre}_${_isSearching}_${safeItemCount}'),
//       controller: _movieScrollController,
//       scrollDirection: Axis.horizontal,
//       padding: const EdgeInsets.symmetric(horizontal: 40),
//       physics: const ClampingScrollPhysics(),
//       cacheExtent: 800,
//       clipBehavior: Clip.none,
//       addAutomaticKeepAlives: true,
//       addRepaintBoundaries: true,
//       itemCount: safeItemCount,
//       itemBuilder: (context, index) {
//         if (index >= list.length || index >= _movieFocusNodes.length) {
//           return const SizedBox.shrink();
//         }

//         return MovieItemWithColorSystem(
//           key: ValueKey('${list[index].id}_$index'),
//           movie: list[index],
//           focusNode: _movieFocusNodes[index],
//           isFocused: _focusedMovieIndex == index,
//           uniqueIndex: index,
//           focusColors: _focusColors,
//           onFocus: () {
//             if (!_isDisposed && mounted) {
//               setState(() => _focusedMovieIndex = index);
//             }
//           },
//           onTap: () => _playContent(list[index]),
//         );
//       },
//     );
//   }

//   Widget _buildSliderIndicators() {
//     if (_contentSliders.isEmpty) return const SizedBox.shrink();

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(
//         _contentSliders.length,
//         (i) => AnimatedContainer(
//           duration: AnimationTiming.fast,
//           margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
//           height: 8,
//           width: _currentSliderPage == i ? 24 : 8,
//           decoration: BoxDecoration(
//             color: _currentSliderPage == i ? Colors.white : Colors.white.withOpacity(0.5),
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // MOVIE ITEM WITH COLOR SYSTEM
// class MovieItemWithColorSystem extends StatefulWidget {
//   final Movie movie;
//   final FocusNode focusNode;
//   final bool isFocused;
//   final int uniqueIndex;
//   final List<Color> focusColors;
//   final VoidCallback onFocus;
//   final VoidCallback onTap;

//   const MovieItemWithColorSystem({
//     super.key,
//     required this.movie,
//     required this.focusNode,
//     required this.isFocused,
//     required this.uniqueIndex,
//     required this.focusColors,
//     required this.onFocus,
//     required this.onTap,
//   });

//   @override
//   State<MovieItemWithColorSystem> createState() => _MovieItemWithColorSystemState();
// }

// class _MovieItemWithColorSystemState extends State<MovieItemWithColorSystem> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   Color get _focusColor {
//     return widget.focusColors[widget.uniqueIndex % widget.focusColors.length];
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return RepaintBoundary(
//       child: Padding(
//         padding: const EdgeInsets.only(right: itemSpacing),
//         // padding: const EdgeInsets.only(right: itemSpacing, top: 10),
//         child: InkWell(
//           focusNode: widget.focusNode,
//           onFocusChange: (has) {
//             if (has) {
//               widget.onFocus();
//               Provider.of<InternalFocusProvider>(context, listen: false).updateName(widget.movie.name);
//             }
//           },
//           onTap: widget.onTap,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SmartStyleImageCard(
//                 image: Image.network(
//                   widget.movie.banner ?? '',
//                   fit: BoxFit.cover,
//                   cacheWidth: (bannerwdt * 1.5).toInt(),
//                   errorBuilder: (c, e, s) => Container(
//                     color: ProfessionalColors.cardDark,
//                     child: Center(
//                       child: Icon(
//                         Icons.movie_creation_outlined,
//                         size: 40,
//                         color: ProfessionalColors.textSecondary.withOpacity(0.5),
//                       ),
//                     ),
//                   ),
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return Container(
//                       color: ProfessionalColors.cardDark,
//                       child: const Center(
//                         child: SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white24,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 title: widget.movie.name,
//                 width: bannerwdt,
//                 height: bannerhgt,
//                 isFocused: widget.isFocused,
//                 focusGlowColor: _focusColor,
//                 focusedTitleColor: Colors.white,
//                 unfocusedTitleColor: Colors.white60,
//                 titleFontSize: 12,
//                 titleSpacing: 8,
//                 titleTextAlign: TextAlign.center,
//                 cardCrossAxisAlignment: CrossAxisAlignment.center,
//                 unfocusedTitleFontWeight: FontWeight.normal,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // GRADIENT TEXT WIDGET
// class GradientText extends StatelessWidget {
//   const GradientText(
//     this.text, {
//     super.key,
//     required this.gradient,
//     this.style,
//   });

//   final String text;
//   final TextStyle? style;
//   final Gradient gradient;

//   @override
//   Widget build(BuildContext context) {
//     return ShaderMask(
//       blendMode: BlendMode.srcIn,
//       shaderCallback: (bounds) => gradient.createShader(
//         Rect.fromLTWH(0, 0, bounds.width, bounds.height),
//       ),
//       child: Text(text, style: style),
//     );
//   }
// }





import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_final_details_page.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_slider_screen.dart';
import 'package:provider/provider.dart';

// Your imports - keep as-is
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/webseries_details_page.dart';
import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
import 'package:mobi_tv_entertainment/components/widgets/master_slider_layout.dart'; // 🔥 THE MASTER WIDGET

class Movie {
  final int id;
  final String name;
  final String? banner;
  final String genres;
  final String? description;
  final int? contentType;
  final String? sourceType;
  final String? youtubeTrailer;
  final String? updatedAt;
  final String? movieUrl;
  final int? status;

  Movie({
    required this.id, required this.name, this.banner, required this.genres,
    this.description, this.contentType, this.sourceType, this.youtubeTrailer,
    this.updatedAt, this.movieUrl, this.status,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
        // id: json['id'] ?? 0,
        // name: json['name'] ?? 'No Name',
        // banner: json['banner'],
        // genres: json['genres'] ?? 'Uncategorized',
        // description: json['description'],
        // contentType: json['content_type'],
        id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      banner: json['banner'] ?? json['thumbnail'], // Thumbnail ko banner ki tarah use karein agar banner null ho
      // Dono singular aur plural fields ko check karein
      genres: json['genres'] ?? json['genre'] ?? 'Uncategorized', 
      description: json['description'],
      contentType: json['content_type'],
        sourceType: json['source_type'],
        youtubeTrailer: json['youtube_trailer'],
        updatedAt: json['updated_at'],
        movieUrl: json['movie_url'],
        status: json['status'],
      );

  String getrawUrl() {
    if (sourceType == 'YoutubeLive') return movieUrl ?? '';
    if (youtubeTrailer != null && youtubeTrailer!.isNotEmpty) return youtubeTrailer!;
    return movieUrl ?? '';
  }
}

class ContentSlider {
  final String? banner;
  ContentSlider({this.banner});
  factory ContentSlider.fromJson(Map<String, dynamic> json) => ContentSlider(banner: json['banner']);
}

class ContentSliderScreen extends StatefulWidget {
  final String tvChannelId;
  final String logoUrl;
  final String title;
  const ContentSliderScreen({super.key, required this.tvChannelId, required this.logoUrl, required this.title});

  @override
  State<ContentSliderScreen> createState() => ContentSliderScreenState();
}

class ContentSliderScreenState extends State<ContentSliderScreen> {
  bool _isDisposed = false;
  bool _isLoading = true;
  bool _isListLoading = false; // 🔥 ADDED FOR SMOOTH TAB SWITCHING
  bool _isVideoLoading = false;
  String? _error;

  List<Movie> _allMovies = [];
  Map<String, List<Movie>> _moviesByGenre = {};
  List<Movie> _displayList = [];
  List<String> _genres = [];
  List<String> _sliderImages = [];

  int _selectedGenreIndex = 0;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    _fetchData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final headers = {
        'auth-key': SessionManager.authKey, 
        'domain': SessionManager.savedDomain, 
        'Content-Type': 'application/json'
      };
      
      final results = await Future.wait([
        https.post(
          Uri.parse(SessionManager.baseUrl + 'getGenreByContentNetwork'), 
          headers: headers, 
          body: json.encode({"network_id": int.tryParse(widget.tvChannelId) ?? 0})
        ),
        https.post(
          Uri.parse(SessionManager.baseUrl + 'getAllContentsOfNetworkNew'), 
          headers: headers, 
          body: json.encode({"network_id": widget.tvChannelId, })
        ),
      ]);

      if (_isDisposed || !mounted) return;

      if (results[0].statusCode == 200 && results[1].statusCode == 200) {
        final gData = json.decode(results[0].body);
        final mData = json.decode(results[1].body);

        _allMovies = (mData['data'] as List).map((i) => Movie.fromJson(i)).where((m) => m.status == 1).toList();
        
        final List<ContentSlider> contentSliders = (mData['content_sliders'] as List).map((i) => ContentSlider.fromJson(i)).toList();
        _sliderImages = contentSliders.where((s) => s.banner != null).map((e) => e.banner!).toList();
        
        _genres = List<String>.from(gData['genres'] ?? []);
        if (_genres.contains('Web Series')) {
          _genres.remove('Web Series');
          _genres.insert(0, 'Web Series');
        }
        
        final moviesByGenreTemp = <String, List<Movie>>{};
        for (var g in _genres) {
          moviesByGenreTemp[g] = _allMovies.where((m) => m.genres.contains(g)).toList();
        }
        _moviesByGenre = moviesByGenreTemp;

        setState(() {
          if (_genres.isNotEmpty) {
            _selectedGenreIndex = 0;
            _displayList = _moviesByGenre[_genres[0]] ?? [];
          } else {
            _displayList = _allMovies;
          }
          _isLoading = false;
        });
      } else {
        throw Exception("API Error");
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _error = "Failed to load content.\nPlease check your connection.";
        });
      }
      debugPrint('Fetch data error: $e');
    }
  }

  void _onGenreChange(int index) {
    if (_isDisposed || !mounted) return;
    setState(() {
      _isListLoading = true;
      _selectedGenreIndex = index;
      _searchText = '';
    });
    
    // Simulate slight delay to allow MasterSliderLayout to process the loading state
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isDisposed || !mounted) return;
      setState(() {
        _displayList = _moviesByGenre[_genres[index]] ?? [];
        _isListLoading = false;
      });
    });
  }

  void _onSearch(String query) {
    if (_isDisposed || !mounted) return;
    setState(() {
      _searchText = query;
      if (query.isEmpty) {
        _displayList = _genres.isNotEmpty ? (_moviesByGenre[_genres[_selectedGenreIndex]] ?? []) : _allMovies;
      } else {
        _displayList = _allMovies.where((m) => m.name.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  Future<void> _playContent(Movie m, int index) async {
    if (_isDisposed || _isVideoLoading) return;
    
    setState(() => _isVideoLoading = true);

    try {
      String rawUrl = m.getrawUrl();
      
      // 🔥 SAFE NAVIGATION WITH ERROR HANDLING
      if (m.contentType == 2) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => WebSeriesDetailsPage(
              id: m.id,
              banner: m.banner ?? '',
              poster: '',
              logo: widget.logoUrl,
              name: m.name,
              updatedAt: m.updatedAt ?? '',
            ),
          ),
        ).catchError((e) {
          debugPrint('Navigation error: $e');
          return null;
        });
      }else
      if (m.contentType == 4) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => TvShowFinalDetailsPage(
              id: m.id,
              banner: m.banner ?? '',
              poster: '',
              // logo: widget.logoUrl,
              name: m.name,
              // updatedAt: m.updatedAt ?? '',
            ),
          ),
        ).catchError((e) {
          debugPrint('Navigation error: $e');
          return null;
        });
      }
      
       else if (rawUrl.isNotEmpty) {
        final deviceInfo = context.read<DeviceInfoProvider>();
        if (m.sourceType == 'YoutubeLive' || (m.youtubeTrailer != null && m.youtubeTrailer!.isNotEmpty)) {
          if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => YoutubeWebviewPlayer(videoUrl: rawUrl, name: m.name),
              ),
            ).catchError((e) => null);
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => CustomYoutubePlayer(
                  videoData: VideoData(
                    id: m.id.toString(),
                    title: m.name,
                    youtubeUrl: rawUrl,
                    thumbnail: m.banner ?? '',
                    description: m.description ?? '',
                  ),
                  playlist: const [],
                ),
              ),
            ).catchError((e) => null);
          }
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => VideoScreen(
                videoUrl: rawUrl,
                bannerImageUrl: m.banner ?? '',
                videoId: m.id,
                name: m.name,
                updatedAt: m.updatedAt ?? '',
                source: 'isVod',
                channelList: const [],
                liveStatus: false,
                streamType: m.sourceType ?? ''
              ),
            ),
          ).catchError((e) => null);
        }
      }
    } catch (e) {
      debugPrint('Play content error: $e');
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isVideoLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterSliderLayout<Movie>(
      title: widget.title,
      logoUrl: widget.logoUrl,
      isLoading: _isLoading,
      isListLoading: _isListLoading, // 🔥 Passed loading state for smooth tab transitions
      isVideoLoading: _isVideoLoading,
      errorMessage: _error,
      onRetry: _fetchData,
      
      networkNames: const [], // No top networks for this page
      selectedNetworkIndex: 0,
      
      filterNames: _genres,
      selectedFilterIndex: _selectedGenreIndex,
      onFilterSelected: _onGenreChange,
      onSearch: _onSearch,
      shouldShuffle: true,
      contentList: _displayList,
      onContentTap: _playContent,
      getTitle: (m) => m.name,
      getImageUrl: (m) => m.banner ?? '',
      
      sliderImages: _sliderImages,
      focusColors: const [
        Color(0xFF3B82F6), // Blue
        Color(0xFF8B5CF6), // Purple
        Color(0xFF10B981), // Green
        Color(0xFFF59E0B), // Orange
        Color(0xFFEC4899), // Pink
        Color(0xFFEF4444), // Red
        Color(0xFF06B6D4), // Teal
      ],
      placeholderIcon: Icons.movie_creation_outlined,
      emptyMessage: "No Content Available",
      cardWidth: bannerwdt ,
      cardHeight: bannerhgt,
    );
  }
}
