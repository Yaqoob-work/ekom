// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/provider/internal_focus_provider.dart';
// import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/video_widget/youtube_webview_player.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
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

//   String getPlayableUrl() {
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
//       {required this.status,
//       required this.data,
//       required this.contentSliders});

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

// //==============================================================================
// // SECTION 2: MAIN PAGE WIDGET AND STATE
// //==============================================================================

// class GenreMoviesScreen extends StatefulWidget {
//   final String tvChannelId;
//   final String logoUrl;
//   final String title;
//   const GenreMoviesScreen(
//       {super.key,
//       required this.tvChannelId,
//       required this.logoUrl,
//       required this.title});
//   @override
//   State<GenreMoviesScreen> createState() => _GenreMoviesScreenState();
// }

// class _GenreMoviesScreenState extends State<GenreMoviesScreen>
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
//         child: Stack(
//           children: [
//             _buildBackgroundOrSlider(),
//             _isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(color: Colors.white))
//                 : _errorMessage != null
//                     ? _buildErrorWidget()
//                     : _buildPageContent(),
//             if (_isVideoLoading && _errorMessage == null)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.8),
//                   child: const Center(
//                     child: CircularProgressIndicator(color: Colors.white),
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
//       final prefs = await SharedPreferences.getInstance();
//       final authKey = prefs.getString('result_auth_key') ?? '56456456456';
//       final response = await http.post(
//         Uri.parse(
//             'https://dashboard.cpplayers.com/api/v2/getAllContentsOfNetworkNew'),
//         headers: {
//           'auth-key': authKey,
//           'domain': 'coretechinfo.com',
//           'Accept': 'application/json',
//           'Content-Type': 'application/json'
//         },
//         body: json.encode(
//             {"genre": "", "network_id": widget.tvChannelId, "limit": 500}),
//       );

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final movieData = MovieResponse.fromJson(json.decode(response.body));
//         if (movieData.status) {
//           _allMovies =
//               movieData.data.where((movie) => movie.status == 1).toList();
//           _contentSliders = movieData.contentSliders
//               .where((s) => s.sliderFor == 'movies')
//               .toList();
//           _processInitialData();
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
//         throw Exception('API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage =
//               "Failed to load movies.\nPlease check your connection.";
//         });
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _processInitialData() {
//     final Map<String, List<Movie>> moviesByGenre = {};
//     for (final movie in _allMovies) {
//       final genres = movie.genres
//           .split(',')
//           .map((g) => g.trim())
//           .where((g) => g.isNotEmpty);
//       for (var genre in genres) {
//         moviesByGenre.putIfAbsent(genre, () => []).add(movie);
//       }
//     }

//     List<String> sortedGenres = moviesByGenre.keys.toList();
//     if (sortedGenres.contains('Web Series')) {
//       sortedGenres.remove('Web Series');
//       sortedGenres.sort();
//       sortedGenres.insert(0, 'Web Series');
//     } else {
//       sortedGenres.sort();
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
//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       _updateSelectedGenre();
//       if (_movieFocusNodes.isNotEmpty) {
//         _focusFirstMovieItemWithScroll();
//       }
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       _updateSelectedGenre();
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
//     _navigationLockTimer = Timer(const Duration(milliseconds: 300), () {
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
//       String playableUrl = content.getPlayableUrl();
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
//       } else if (playableUrl.isNotEmpty) {
//         if (content.sourceType == 'YoutubeLive' ||
//             (content.youtubeTrailer != null &&
//                 content.youtubeTrailer!.isNotEmpty)) {
//           final deviceInfo = context.read<DeviceInfoProvider>();
//           if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//             await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => YoutubeWebviewPlayer(
//                         videoUrl: playableUrl, name: content.name)));
//           } else {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => CustomYoutubePlayer(
//                   videoData: VideoData(
//                     id: content.id.toString(),
//                     title: content.name,
//                     youtubeUrl: playableUrl,
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
//                 videoUrl: playableUrl,
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
//       _sliderTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
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
//           height: screenhgt * 0.52,
//           child: _showKeyboard ? _buildSearchUI() : const SizedBox.shrink(),
//         ),
//         _buildSliderIndicators(),
//         _buildGenreAndSearchButtons(),
//         SizedBox(height: screenhgt * 0.02),
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
//               return CachedNetworkImage(
//                 imageUrl: slider.banner ?? '',
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) =>
//                     Container(color: ProfessionalColors.surfaceDark),
//                 errorWidget: (context, url, error) =>
//                     Container(color: ProfessionalColors.surfaceDark),
//               );
//             },
//           )
//         else
//           // Fallback if no sliders
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
//     // This line listens to the provider for the focused item's name
//     final focusedName = context.watch<InternalFocusProvider>().focusedItemName;

//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: EdgeInsets.only(
//             top: MediaQuery.of(context).padding.top + 7,
//             bottom: 2,
//             left: 20,
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
//               // Colorful Title
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

//               // Focused Item Name (Flexible to prevent overflow)
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

//               // const Spacer(),

//               // Network Logo
//               if (widget.logoUrl.isNotEmpty)
//                 SizedBox(
//                   height: screenhgt * 0.05,
//                   child: CachedNetworkImage(imageUrl: widget.logoUrl ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGenreAndSearchButtons() {
//     return SizedBox(
//       height: screenhgt * 0.07,
//       child: Center(
//         child: ListView.builder(
//           controller: _genreScrollController,
//           scrollDirection: Axis.horizontal,
//           itemCount: _genres.length + 1, // +1 for Search button
//           padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.01),
//           itemBuilder: (context, index) {
//             if (index == 0) {
//               // Search Button
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
//                         "Search",
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
//                 cardHeight: bannerhgt * 1.2,
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
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
//                     fontWeight: isFocused ? FontWeight.bold : FontWeight.normal),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMovieImage() {
//     final imageUrl = movie.poster ?? movie.banner;
//     return imageUrl != null && imageUrl.isNotEmpty
//         ? CachedNetworkImage(
//             imageUrl: imageUrl,
//             fit: BoxFit.cover,
//             placeholder: (context, url) => _buildImagePlaceholder(),
//             errorWidget: (context, url, error) => _buildImagePlaceholder(),
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
// // import 'package:cached_network_image/cached_network_image.dart'; // YEH HATA DIYA GAYA HAI
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/webseries_details_page.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
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

//   String getPlayableUrl() {
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

// //==============================================================================
// // SECTION 2: MAIN PAGE WIDGET AND STATE
// //==============================================================================

// class GenreMoviesScreen extends StatefulWidget {
//   final String tvChannelId;
//   final String logoUrl;
//   final String title;
//   const GenreMoviesScreen(
//       {super.key,
//       required this.tvChannelId,
//       required this.logoUrl,
//       required this.title});
//   @override
//   State<GenreMoviesScreen> createState() => _GenreMoviesScreenState();
// }

// class _GenreMoviesScreenState extends State<GenreMoviesScreen>
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

//     _sliderPageController = PageController();
//     _searchButtonFocusNode = FocusNode();
//     _fetchDataForPage();
//     _initializeAnimations();
//     print('getBaseUrl: ${SessionManager.baseUrl}');
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
//   // SECTION 2.1: DATA FETCHING AND PROCESSING
//   //=================================================

//   Future<void> _fetchDataForPage({bool forceRefresh = false}) async {
//     if (!mounted) return;
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final authKey = SessionManager.authKey;
//       var url = Uri.parse(SessionManager.baseUrl + 'getAllContentsOfNetworkNew');
//       final response = await https.post(
//         // Uri.parse(
//           url,
//           // SessionManager.baseUrl + 'getAllContentsOfNetworkNew'
//             // 'https://dashboard.cpplayers.com/api/v2/getAllContentsOfNetworkNew'

//         headers: {
//           'auth-key': authKey,
//           // 'domain': 'coretechinfo.com',
//           'domain': SessionManager.savedDomain,
//           'Accept': 'application/json',
//           'Content-Type': 'application/json'
//         },
//         // ),
//         body: json.encode(
//             // {"genre": "", "network_id": widget.tvChannelId, "limit": 500}),
//             {"genre": "", "network_id": widget.tvChannelId,}),
//       );

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final movieData = MovieResponse.fromJson(json.decode(response.body));
//         if (movieData.status) {
//           _allMovies =
//               movieData.data.where((movie) => movie.status == 1).toList();
//           _contentSliders = movieData.contentSliders
//               .where((s) => s.sliderFor == 'movies')
//               .toList();
//           _processInitialData();
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
//         throw Exception('API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage =
//               "Failed to load movies.\nPlease check your connection.";
//         });
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _processInitialData() {
//     final Map<String, List<Movie>> moviesByGenre = {};
//     for (final movie in _allMovies) {
//       final genres = movie.genres
//           .split(',')
//           .map((g) => g.trim())
//           .where((g) => g.isNotEmpty);
//       for (var genre in genres) {
//         moviesByGenre.putIfAbsent(genre, () => []).add(movie);
//       }
//     }

//     List<String> sortedGenres = moviesByGenre.keys.toList();
//     if (sortedGenres.contains('Web Series')) {
//       sortedGenres.remove('Web Series');
//       sortedGenres.sort();
//       sortedGenres.insert(0, 'Web Series');
//     } else {
//       sortedGenres.sort();
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

//   // KeyEventResult _navigateGenres(LogicalKeyboardKey key) {
//   //   int newIndex = _focusedGenreIndex;
//   //   if (key == LogicalKeyboardKey.arrowLeft) {
//   //     if (newIndex > 0) {
//   //       newIndex--;
//   //     } else {
//   //       _searchButtonFocusNode.requestFocus();
//   //       return KeyEventResult.handled;
//   //     }
//   //   } else if (key == LogicalKeyboardKey.arrowRight) {
//   //     if (newIndex < _genres.length - 1) {
//   //       newIndex++;
//   //     }
//   //   } else if (key == LogicalKeyboardKey.arrowDown) {
//   //     _updateSelectedGenre();
//   //     if (_movieFocusNodes.isNotEmpty) {
//   //       _focusFirstMovieItemWithScroll();
//   //     }
//   //     return KeyEventResult.handled;
//   //   } else if (key == LogicalKeyboardKey.select ||
//   //       key == LogicalKeyboardKey.enter) {
//   //     _updateSelectedGenre();
//   //     return KeyEventResult.handled;
//   //   }

//   //   if (newIndex != _focusedGenreIndex) {
//   //     setState(() => _focusedGenreIndex = newIndex);
//   //     _genreFocusNodes[newIndex].requestFocus();
//   //     _updateAndScrollToFocus(
//   //         _genreFocusNodes, newIndex, _genreScrollController, 160);
//   //   }
//   //   return KeyEventResult.handled;
//   // }

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
//     } else if (key ==
//             LogicalKeyboardKey.arrowDown || // YAHAN BADLAV KIYA GAYA HAI
//         key == LogicalKeyboardKey.select ||
//         key == LogicalKeyboardKey.enter) {
//       _updateSelectedGenre();
//       if (_movieFocusNodes.isNotEmpty) {
//         _focusFirstMovieItemWithScroll(); // Ab enter/select se bhi focus movie par jaayega
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
//       String playableUrl = content.getPlayableUrl();
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
//       } else if (playableUrl.isNotEmpty) {
//         if (content.sourceType == 'YoutubeLive' ||
//             (content.youtubeTrailer != null &&
//                 content.youtubeTrailer!.isNotEmpty)) {
//           final deviceInfo = context.read<DeviceInfoProvider>();
//           if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//             await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => YoutubeWebviewPlayer(
//                         videoUrl: playableUrl, name: content.name)));
//           } else {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => CustomYoutubePlayer(
//                   videoData: VideoData(
//                     id: content.id.toString(),
//                     title: content.name,
//                     youtubeUrl: playableUrl,
//                     thumbnail: content.poster ?? content.banner ?? '',
//                     description: content.description ?? '',
//                   ),
//                   playlist: const [],
//                 ),
//               ),
//             );
//           }
//         } else {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => VideoScreen(
//                   videoUrl: playableUrl,
//                   bannerImageUrl: content.poster ?? content.banner ?? '',
//                   videoId: content.id,
//                   name: content.name,
//                   updatedAt: content.updatedAt ?? '',
//                   source: 'isVod',
//                   channelList: const [],
//                   liveStatus: false,
//                 ),
//               ),
//             );

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
//               // BADLA GAYA: CachedNetworkImage ko Image.network se replace kiya gaya hai
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
//           // Fallback if no sliders
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
//     // This line listens to the provider for the focused item's name
//     final focusedName = context.watch<InternalFocusProvider>().focusedItemName;

//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: EdgeInsets.only(
//             top:  screenhgt * 0.02,
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
//               // Colorful Title
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

//               // Focused Item Name (Flexible to prevent overflow)
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

//               // const Spacer(),

//               // Network Logo
//               if (widget.logoUrl.isNotEmpty)
//                 SizedBox(
//                   height: screenhgt * 0.05,
//                   // BADLA GAYA: CachedNetworkImage ko Image.network se replace kiya gaya hai
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
//           itemCount: _genres.length + 1, // +1 for Search button
//           padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.03),
//           itemBuilder: (context, index) {
//             if (index == 0) {
//               // Search Button
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

//             // Genre Buttons
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
//     final imageUrl =  movie.banner;
//     // BADLA GAYA: CachedNetworkImage ko Image.network se replace kiya gaya hai
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






import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/webseries_details_page.dart';
import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';
import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

//==============================================================================
// SECTION 1: COMMON CLASSES, MODELS, AND CONSTANTS
//==============================================================================

class ProfessionalColors {
  static const primaryDark = Color(0xFF0A0E1A);
  static const surfaceDark = Color(0xFF1A1D29);
  static const cardDark = Color(0xFF2A2D3A);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentPink = Color(0xFFEC4899);
  static const accentOrange = Color(0xFFF59E0B);
  static const accentRed = Color(0xFFEF4444);
  static const accentGreen = Color(0xFF10B981);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
}

class AnimationTiming {
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
}

class ContentSlider {
  final int id;
  final String title;
  final String? banner;
  final String? sliderFor;

  ContentSlider(
      {required this.id, required this.title, this.banner, this.sliderFor});

  factory ContentSlider.fromJson(Map<String, dynamic> json) {
    return ContentSlider(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      banner: json['banner'],
      sliderFor: json['slider_for'],
    );
  }
}

class Movie {
  final int id;
  final String name;
  final String? banner;
  final String? poster;
  final String? description;
  final String genres;
  final int? contentType;
  final String? sourceType;
  final String? youtubeTrailer;
  final String? updatedAt;
  final String? movieUrl;
  final int? status;

  Movie({
    required this.id,
    required this.name,
    this.banner,
    this.poster,
    this.description,
    required this.genres,
    this.contentType,
    this.sourceType,
    this.youtubeTrailer,
    this.updatedAt,
    this.movieUrl,
    this.status,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      banner: json['banner'],
      poster: json['poster'],
      description: json['description'],
      genres: json['genres'] ?? 'Uncategorized',
      contentType: json['content_type'],
      sourceType: json['source_type'],
      youtubeTrailer: json['youtube_trailer'],
      updatedAt: json['updated_at'],
      movieUrl: json['movie_url'],
      status: json['status'],
    );
  }

  String getPlayableUrl() {
    if (sourceType == 'YoutubeLive') return movieUrl ?? '';
    if (youtubeTrailer != null && youtubeTrailer!.isNotEmpty) {
      return youtubeTrailer!;
    }
    return movieUrl ?? '';
  }
}

class MovieResponse {
  final bool status;
  final List<Movie> data;
  final List<ContentSlider> contentSliders;

  MovieResponse(
      {required this.status, required this.data, required this.contentSliders});

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(
        String key, T Function(Map<String, dynamic>) fromJson) {
      if (json[key] is List) {
        return (json[key] as List)
            .map((i) => fromJson(i as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    return MovieResponse(
      status: json['status'] ?? false,
      data: parseList('data', (i) => Movie.fromJson(i)),
      contentSliders:
          parseList('content_sliders', (i) => ContentSlider.fromJson(i)),
    );
  }
}

// *** NEW CLASS FOR GENRE API RESPONSE ***
class GenreResponse {
  final bool status;
  final List<String> genres;

  GenreResponse({required this.status, required this.genres});

  factory GenreResponse.fromJson(Map<String, dynamic> json) {
    return GenreResponse(
      status: json['status'] ?? false,
      genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
    );
  }
}

//==============================================================================
// SECTION 2: MAIN PAGE WIDGET AND STATE
//==============================================================================

class GenreMoviesScreen extends StatefulWidget {
  final String tvChannelId;
  final String logoUrl;
  final String title;
  const GenreMoviesScreen(
      {super.key,
      required this.tvChannelId,
      required this.logoUrl,
      required this.title});
  @override
  State<GenreMoviesScreen> createState() => _GenreMoviesScreenState();
}

class _GenreMoviesScreenState extends State<GenreMoviesScreen>
    with SingleTickerProviderStateMixin {
  // Data State
  List<Movie> _allMovies = [];
  Map<String, List<Movie>> _moviesByGenre = {};
  List<Movie> _filteredMovies = [];
  List<String> _genres = [];
  List<ContentSlider> _contentSliders = [];
  bool _isLoading = true;
  String? _errorMessage;

  // UI and Filter State
  int _focusedGenreIndex = 0;
  int _focusedMovieIndex = -1;
  String _selectedGenre = '';
  late PageController _sliderPageController;
  int _currentSliderPage = 0;
  Timer? _sliderTimer;
  bool _isVideoLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Focus and Scroll Controllers
  final FocusNode _widgetFocusNode = FocusNode();
  final ScrollController _genreScrollController = ScrollController();
  final ScrollController _movieScrollController = ScrollController();
  late FocusNode _searchButtonFocusNode;
  List<FocusNode> _genreFocusNodes = [];
  List<FocusNode> _movieFocusNodes = [];
  List<FocusNode> _keyboardFocusNodes = [];

  // Search State
  bool _isSearching = false;
  bool _showKeyboard = false;
  String _searchText = '';
  Timer? _debounce;
  List<Movie> _searchResults = [];
  bool _isSearchLoading = false;

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

  // Performance Fix: Navigation Lock for fast remote presses
  bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;

  final List<Color> _focusColors = [
    ProfessionalColors.accentBlue,
    ProfessionalColors.accentPurple,
    ProfessionalColors.accentGreen,
    ProfessionalColors.accentOrange,
    ProfessionalColors.accentPink,
    ProfessionalColors.accentRed
  ];

  @override
  void initState() {
    super.initState();
    SecureUrlService.refreshSettings();
    _sliderPageController = PageController();
    _searchButtonFocusNode = FocusNode();
    _fetchDataForPage();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _sliderPageController.dispose();
    _fadeController.dispose();
    _widgetFocusNode.dispose();
    _genreScrollController.dispose();
    _movieScrollController.dispose();
    _searchButtonFocusNode.dispose();
    _debounce?.cancel();
    _sliderTimer?.cancel();
    _navigationLockTimer?.cancel();

    _disposeFocusNodes(_genreFocusNodes);
    _disposeFocusNodes(_movieFocusNodes);
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
        child: Center(
          child: Stack(
            children: [
              _buildBackgroundOrSlider(),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : _errorMessage != null
                      ? _buildErrorWidget()
                      : _buildPageContent(),
              if (_isVideoLoading && _errorMessage == null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  //=================================================
  // SECTION 2.1: DATA FETCHING AND PROCESSING (UPDATED)
  //=================================================

  Future<void> _fetchDataForPage({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authKey = SessionManager.authKey;
      final domain = SessionManager.savedDomain;

      // URLs Setup
      // Note: Genre API URL based on your requirement
      var genreUrl = Uri.parse(
          'https://dashboard.cpplayers.com/api/v3/getGenreByContentNetwork');
      var movieUrl =
          Uri.parse(SessionManager.baseUrl + 'getAllContentsOfNetworkNew');

      final headers = {
        'auth-key': authKey,
        'domain': domain, // 'coretechinfo.com' or saved domain
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };

      // 1. Parallel API Calls (Fetching Genres and Movies at same time)
      final results = await Future.wait([
        // Call 1: Fetch Genres
        https.post(
          genreUrl,
          headers: headers,
          body: json.encode({
            "data_for": "",
            // Parsing network_id to integer as shown in screenshot
            "network_id": int.tryParse(widget.tvChannelId) ?? 0
          }),
        ),
        // Call 2: Fetch Movies
        https.post(
          movieUrl,
          headers: headers,
          body: json.encode({
            "genre": "",
            "network_id": widget.tvChannelId,
          }),
        ),
      ]);

      final genreRes = results[0];
      final movieRes = results[1];

      if (!mounted) return;

      if (genreRes.statusCode == 200 && movieRes.statusCode == 200) {
        // 2. Parsing Responses
        final genreData = GenreResponse.fromJson(json.decode(genreRes.body));
        final movieData = MovieResponse.fromJson(json.decode(movieRes.body));

        if (genreData.status && movieData.status) {
          _allMovies =
              movieData.data.where((movie) => movie.status == 1).toList();
          _contentSliders = movieData.contentSliders
              .where((s) => s.sliderFor == 'movies')
              .toList();

          // 3. Process Data using API Genres
          _processDataWithApiGenres(genreData.genres);

          _initializeFocusNodes();
          _startAnimations();
          _setupSliderTimer();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Provider.of<InternalFocusProvider>(context, listen: false)
                  .updateName('');
              if (_searchButtonFocusNode.canRequestFocus) {
                _searchButtonFocusNode.requestFocus();
              }
            }
          });
        } else {
          throw Exception('API returned status false.');
        }
      } else {
        throw Exception(
            'API Error. Genres: ${genreRes.statusCode}, Movies: ${movieRes.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              "Failed to load content.\nPlease check your connection.";
        });
      }
      print("Error fetching data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // UPDATED FUNCTION: Uses genres from API to organize movies
  void _processDataWithApiGenres(List<String> apiGenres) {
    final Map<String, List<Movie>> moviesByGenre = {};

    // 1. Create list from API response
    List<String> sortedGenres = List.from(apiGenres);

    // 2. Priority Sorting for "Web Series"
    if (sortedGenres.contains('Web Series')) {
      sortedGenres.remove('Web Series');
      // sortedGenres.sort(); // Uncomment if you want A-Z sorting for others
      sortedGenres.insert(0, 'Web Series');
    }

    // 3. Initialize Map with empty lists for all API genres
    for (var genre in sortedGenres) {
      moviesByGenre[genre] = [];
    }

    // 4. Distribute movies into genres
    for (final movie in _allMovies) {
      // Split movie genres string (e.g. "Action, Drama")
      final movieGenresList = movie.genres
          .split(',')
          .map((g) => g.trim())
          .where((g) => g.isNotEmpty)
          .toList();

      // Check if movie belongs to any of our API genres
      for (var movieGenre in movieGenresList) {
        if (moviesByGenre.containsKey(movieGenre)) {
          moviesByGenre[movieGenre]!.add(movie);
        }
      }
    }

    setState(() {
      _moviesByGenre = moviesByGenre;
      _genres = sortedGenres;
      if (_genres.isNotEmpty) {
        _selectedGenre = _genres[0];
      }
    });

    _applyFilters();
  }

  //=================================================
  // SECTION 2.2: KEYBOARD AND FOCUS NAVIGATION
  //=================================================

  KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;

    bool searchHasFocus = _searchButtonFocusNode.hasFocus;
    bool genreHasFocus = _genreFocusNodes.any((n) => n.hasFocus);
    bool movieHasFocus = _movieFocusNodes.any((n) => n.hasFocus);
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
      return KeyEventResult.ignored; // Allow navigator to pop
    }

    if (keyboardHasFocus && _showKeyboard) {
      return _navigateKeyboard(key);
    }

    if (searchHasFocus) return _navigateFromSearch(key);
    if (genreHasFocus) return _navigateGenres(key);
    if (movieHasFocus) return _navigateMovies(key);

    return KeyEventResult.ignored;
  }

  KeyEventResult _navigateFromSearch(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      setState(() => _showKeyboard = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _keyboardFocusNodes.isNotEmpty) {
          _keyboardFocusNodes[0].requestFocus();
        }
      });
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight && _genreFocusNodes.isNotEmpty) {
      _genreFocusNodes[0].requestFocus();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown && _movieFocusNodes.isNotEmpty) {
      _focusFirstMovieItemWithScroll();
      return KeyEventResult.handled;
    }
    return KeyEventResult.handled;
  }

  KeyEventResult _navigateGenres(LogicalKeyboardKey key) {
    int newIndex = _focusedGenreIndex;
    if (key == LogicalKeyboardKey.arrowLeft) {
      if (newIndex > 0) {
        newIndex--;
      } else {
        _searchButtonFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (newIndex < _genres.length - 1) {
        newIndex++;
      }
    } else if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter) {
      _updateSelectedGenre();
      if (_movieFocusNodes.isNotEmpty) {
        _focusFirstMovieItemWithScroll();
      }
      return KeyEventResult.handled;
    }

    if (newIndex != _focusedGenreIndex) {
      setState(() => _focusedGenreIndex = newIndex);
      _genreFocusNodes[newIndex].requestFocus();
      _updateAndScrollToFocus(
          _genreFocusNodes, newIndex, _genreScrollController, 160);
    }
    return KeyEventResult.handled;
  }

  KeyEventResult _navigateMovies(LogicalKeyboardKey key) {
    if (_isNavigationLocked) return KeyEventResult.handled;
    if (_focusedMovieIndex < 0 || _movieFocusNodes.isEmpty) {
      return KeyEventResult.ignored;
    }

    setState(() => _isNavigationLocked = true);
    _navigationLockTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isNavigationLocked = false);
    });

    int newIndex = _focusedMovieIndex;
    final currentList = _isSearching ? _searchResults : _filteredMovies;

    if (key == LogicalKeyboardKey.arrowUp) {
      _genreFocusNodes[_focusedGenreIndex].requestFocus();
      setState(() => _focusedMovieIndex = -1);
      _isNavigationLocked = false;
      _navigationLockTimer?.cancel();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (newIndex > 0) newIndex--;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (newIndex < currentList.length - 1) newIndex++;
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter) {
      _isNavigationLocked = false;
      _navigationLockTimer?.cancel();
      _playContent(currentList[_focusedMovieIndex]);
      return KeyEventResult.handled;
    }

    if (newIndex != _focusedMovieIndex) {
      setState(() => _focusedMovieIndex = newIndex);
      if (newIndex < _movieFocusNodes.length) {
        _movieFocusNodes[newIndex].requestFocus();
        _updateAndScrollToFocus(_movieFocusNodes, newIndex,
            _movieScrollController, (screenwdt / 7) + 12);
      }
    } else {
      _navigationLockTimer?.cancel();
      if (mounted) setState(() => _isNavigationLocked = false);
    }

    return KeyEventResult.handled;
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
    setState(() {
      _filteredMovies = _moviesByGenre[_selectedGenre] ?? [];
      _filteredMovies.shuffle();
      _rebuildMovieFocusNodes();
      _focusedMovieIndex = -1;
    });
  }

  void _updateSelectedGenre() {
    setState(() {
      _selectedGenre = _genres[_focusedGenreIndex];
      _applyFilters();
    });
  }

  void _performSearch(String searchTerm) {
    _debounce?.cancel();
    if (searchTerm.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _isSearchLoading = false;
        _searchResults.clear();
        _rebuildMovieFocusNodes();
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

      final results = _allMovies
          .where((movie) =>
              movie.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();

      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearchLoading = false;
        _rebuildMovieFocusNodes();
      });
    });
  }

  void _onKeyPressed(String value) {
    setState(() {
      if (value == 'OK') {
        _showKeyboard = false;
        if (_movieFocusNodes.isNotEmpty) {
          _movieFocusNodes.first.requestFocus();
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

  Future<void> _playContent(Movie content) async {
    if (_isVideoLoading || !mounted) return;
    setState(() => _isVideoLoading = true);

    try {
      // String playableUrl = content.getPlayableUrl();
      String rawUrl = content.getPlayableUrl();
      print('rawurl: $rawUrl');
      String playableUrl = await SecureUrlService.getSecureUrl(rawUrl);
      print('playableUrl: $playableUrl');
      if (content.contentType == 2) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebSeriesDetailsPage(
              id: content.id,
              banner: content.banner ?? '',
              poster: content.poster ?? '',
              logo: widget.logoUrl,
              name: content.name,
              updatedAt: content.updatedAt ?? '',
            ),
          ),
        );
      } else if (playableUrl.isNotEmpty) {
        if (content.sourceType == 'YoutubeLive' ||
            (content.youtubeTrailer != null &&
                content.youtubeTrailer!.isNotEmpty)) {
          final deviceInfo = context.read<DeviceInfoProvider>();
          if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => YoutubeWebviewPlayer(
                        videoUrl: playableUrl, name: content.name)));
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomYoutubePlayer(
                  videoData: VideoData(
                    id: content.id.toString(),
                    title: content.name,
                    youtubeUrl: playableUrl,
                    thumbnail: content.poster ?? content.banner ?? '',
                    description: content.description ?? '',
                  ),
                  playlist: const [],
                ),
              ),
            );
          }
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoScreen(
                videoUrl: playableUrl,
                bannerImageUrl: content.poster ?? content.banner ?? '',
                videoId: content.id,
                name: content.name,                                                                                                                   
                updatedAt: content.updatedAt ?? '',
                source: 'isVod',
                channelList: const [],
                liveStatus: false,
              ),
            ),
          );
        }
      } else {
        throw Exception('No playable video URL found.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error playing content: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isVideoLoading = false);
      }
    }
  }

  void _setupSliderTimer() {
    _sliderTimer?.cancel();
    if (_contentSliders.length > 1) {
      _sliderTimer = Timer.periodic(const Duration(seconds: 8), (Timer timer) {
        if (!mounted || !_sliderPageController.hasClients) return;
        int nextPage = (_sliderPageController.page?.round() ?? 0) + 1;
        if (nextPage >= _contentSliders.length) {
          nextPage = 0;
        }
        _sliderPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
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
    _disposeFocusNodes(_genreFocusNodes);
    _genreFocusNodes =
        List.generate(_genres.length, (i) => FocusNode(debugLabel: 'Genre-$i'));
    _rebuildMovieFocusNodes();
    _rebuildKeyboardFocusNodes();
  }

  void _rebuildMovieFocusNodes() {
    _disposeFocusNodes(_movieFocusNodes);
    final currentList = _isSearching ? _searchResults : _filteredMovies;
    _movieFocusNodes = List.generate(
        currentList.length, (i) => FocusNode(debugLabel: 'Movie-$i'));
  }

  void _rebuildKeyboardFocusNodes() {
    _disposeFocusNodes(_keyboardFocusNodes);
    int totalKeys = _keyboardLayout.fold(0, (prev, row) => prev + row.length);
    _keyboardFocusNodes = List.generate(
        totalKeys, (index) => FocusNode(debugLabel: 'Key-$index'));
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
    double scrollPosition =
        (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    controller.animateTo(
      scrollPosition.clamp(0.0, controller.position.maxScrollExtent),
      duration: AnimationTiming.fast,
      curve: Curves.easeInOut,
    );
  }

  void _focusFirstMovieItemWithScroll() {
    if (_movieFocusNodes.isEmpty) return;
    if (_movieScrollController.hasClients) {
      _movieScrollController.animateTo(0.0,
          duration: AnimationTiming.fast, curve: Curves.easeInOut);
    }
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted && _movieFocusNodes.isNotEmpty) {
        setState(() => _focusedMovieIndex = 0);
        _movieFocusNodes[0].requestFocus();
      }
    });
  }

  //=================================================
  // SECTION 2.5: WIDGET BUILDER METHODS
  //=================================================

  Widget _buildPageContent() {
    return Column(
      children: [
        _buildBeautifulAppBar(),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildContentBody(),
          ),
        ),
      ],
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
        SizedBox(height: screenhgt * 0.01),
        _buildMoviesList(),
      ],
    );
  }

  Widget _buildBackgroundOrSlider() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_contentSliders.isNotEmpty)
          PageView.builder(
            controller: _sliderPageController,
            itemCount: _contentSliders.length,
            onPageChanged: (index) {
              if (mounted) setState(() => _currentSliderPage = index);
            },
            itemBuilder: (context, index) {
              final slider = _contentSliders[index];
              return Image.network(
                slider.banner ?? '',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(color: ProfessionalColors.surfaceDark);
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: ProfessionalColors.surfaceDark);
                },
              );
            },
          )
        else
          Container(
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
  }

  Widget _buildBeautifulAppBar() {
    final focusedName = context.watch<InternalFocusProvider>().focusedItemName;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            top: screenhgt * 0.02,
            bottom: 2,
            left: screenwdt * 0.03,
            right: 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.0),
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
              GradientText(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                gradient: const LinearGradient(
                  colors: [
                    ProfessionalColors.accentPink,
                    ProfessionalColors.accentPurple,
                    ProfessionalColors.accentBlue,
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  focusedName,
                  style: const TextStyle(
                    color: ProfessionalColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.logoUrl.isNotEmpty)
                SizedBox(
                  height: screenhgt * 0.05,
                  child: Image.network(
                    widget.logoUrl,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenreAndSearchButtons() {
    return SizedBox(
      height: 30,
      child: Center(
        child: ListView.builder(
          controller: _genreScrollController,
          scrollDirection: Axis.horizontal,
          cacheExtent: 9999,
          itemCount: _genres.length + 1, // +1 for Search button
          padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.03),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Focus(
                focusNode: _searchButtonFocusNode,
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    Provider.of<InternalFocusProvider>(context, listen: false)
                        .updateName("Search");
                  }
                },
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "SEARCH",
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

            final genreIndex = index - 1;
            final genre = _genres[genreIndex];
            final focusNode = _genreFocusNodes[genreIndex];
            final isSelected = !_isSearching && _selectedGenre == genre;

            return Focus(
              focusNode: focusNode,
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  setState(() => _focusedGenreIndex = genreIndex);
                  Provider.of<InternalFocusProvider>(context, listen: false)
                      .updateName(genre);
                }
              },
              child: _buildGlassEffectButton(
                focusNode: focusNode,
                isSelected: isSelected,
                focusColor: _focusColors[genreIndex % _focusColors.length],
                onTap: () {
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

  Widget _buildMoviesList() {
    final currentList = _isSearching ? _searchResults : _filteredMovies;

    if (_isSearchLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (currentList.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            _isSearching && _searchText.isNotEmpty
                ? "No results found for '$_searchText'"
                : 'No movies available for this filter.',
            style: const TextStyle(
                color: ProfessionalColors.textSecondary, fontSize: 16),
          ),
        ),
      );
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: ListView.builder(
          clipBehavior: Clip.none,
          cacheExtent: 9999,
          controller: _movieScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            final movie = currentList[index];
            return InkWell(
              focusNode: _movieFocusNodes[index],
              onTap: () => _playContent(movie),
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  setState(() => _focusedMovieIndex = index);
                  Provider.of<InternalFocusProvider>(context, listen: false)
                      .updateName(movie.name);
                  _updateAndScrollToFocus(_movieFocusNodes, index,
                      _movieScrollController, (screenwdt / 7) + 12);
                }
              },
              child: MovieCard(
                movie: movie,
                isFocused: _focusedMovieIndex == index,
                onTap: () => _playContent(movie),
                cardHeight: bannerhgt * 1.1,
                logoUrl: widget.logoUrl,
                uniqueIndex: index,
                focusColors: _focusColors,
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
                const Text(
                  "Search Movies",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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

  Widget _buildQwertyKeyboard() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
        final isFocused =
            _focusedKeyRow == rowIndex && _focusedKeyCol == colIndex;
        double width;
        if (key == ' ') {
          width = screenwdt * 0.315;
        } else if (key == 'OK' || key == 'DEL') {
          width = screenwdt * 0.09;
        } else {
          width = screenwdt * 0.045;
        }

        return Container(
          width: width,
          height: screenhgt * 0.08,
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
    if (_contentSliders.length <= 1) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_contentSliders.length, (index) {
        bool isActive = _currentSliderPage == index;
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              decoration: BoxDecoration(
                color: hasFocus
                    ? focusColor
                    : isSelected
                        ? focusColor.withOpacity(0.5)
                        : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color:
                      hasFocus ? Colors.white : Colors.white.withOpacity(0.3),
                  width: hasFocus ? 3 : 2,
                ),
                boxShadow: hasFocus
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: Colors.white, size: 50),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An unknown error occurred.',
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _fetchDataForPage(forceRefresh: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: ProfessionalColors.accentBlue,
            ),
          ),
        ],
      ),
    );
  }
}

//==============================================================================
// SECTION 3: REUSABLE UI COMPONENTS
//==============================================================================

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isFocused;
  final VoidCallback onTap;
  final double cardHeight;
  final String logoUrl;
  final int uniqueIndex;
  final List<Color> focusColors;

  const MovieCard({
    super.key,
    required this.movie,
    required this.isFocused,
    required this.onTap,
    required this.cardHeight,
    required this.logoUrl,
    required this.uniqueIndex,
    required this.focusColors,
  });

  @override
  Widget build(BuildContext context) {
    final focusColor = focusColors[uniqueIndex % focusColors.length];

    return Container(
      width: screenwdt / 7,
      margin: const EdgeInsets.only(right: 12.0),
      child: Column(
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
                    _buildMovieImage(),
                    if (isFocused)
                      Positioned(
                          left: 5,
                          top: 5,
                          child: Container(
                              color: Colors.black.withOpacity(0.4),
                              child: Icon(Icons.play_circle_filled_outlined,
                                  color: focusColor, size: 40))),
                    if (logoUrl.isNotEmpty)
                      Positioned(
                          top: 5,
                          right: 5,
                          child: CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(logoUrl),
                              backgroundColor: Colors.black54)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.0, left: 2.0, right: 2.0),
            child: Text(movie.name,
                style: TextStyle(
                    color: isFocused
                        ? focusColor
                        : ProfessionalColors.textSecondary,
                    fontSize: 14,
                    fontWeight:
                        isFocused ? FontWeight.bold : FontWeight.normal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieImage() {
    final imageUrl = movie.banner;
    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildImagePlaceholder();
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          )
        : _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: ProfessionalColors.cardDark,
      child: Center(
        child: Icon(
          Icons.movie_creation_outlined,
          size: 50,
          color: ProfessionalColors.textSecondary.withOpacity(0.5),
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}




