
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sub_vod_screen/sub_vod.dart';
import 'focussable_manage_movies_widget.dart';

class Movies extends StatefulWidget {
  final Function(bool)? onFocusChange;
  final FocusNode focusNode;

  const Movies({Key? key, this.onFocusChange, required this.focusNode})
      : super(key: key);

  @override
  _MoviesState createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  List<dynamic> moviesList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final PaletteColorService _paletteColorService = PaletteColorService();
  Map<String, FocusNode> movieFocusNodes = {};
  final ScrollController _scrollController = ScrollController();
  FocusNode? _viewAllFocusNode;
  Color _viewAllColor = Colors.grey;
  bool _isNavigating = false;
  int _maxRetries = 3;
  int _retryDelay = 5; // seconds

  // Image caching properties
  Map<String, Widget> _imageCache = {};
  Map<String, Uint8List?> _decodedImages = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<FocusProvider>().setMoviesScrollController(_scrollController);
      Provider.of<FocusProvider>(context, listen: false)
          .setMoviesScrollController(_scrollController);
    });

    _viewAllFocusNode = FocusNode()
      ..addListener(() {
        if (_viewAllFocusNode!.hasFocus) {
          setState(() {
            _viewAllColor =
                Colors.primaries[Random().nextInt(Colors.primaries.length)];
          });
        }
      });
    _loadCachedDataAndFetchMovies();
    _initializeMovieFocusNodes();
  }

// Fix 1: Update the sorting logic to handle null values safely
  void _sortMoviesData(List<dynamic> data) {
    if (data.isNotEmpty) {
      data.sort((a, b) {
        // Handle null values in index field
        final aIndex = a['index'];
        final bIndex = b['index'];

        // If both are null, they're equal
        if (aIndex == null && bIndex == null) return 0;

        // If a is null but b isn't, a comes after b
        if (aIndex == null) return 1;

        // If b is null but a isn't, a comes before b
        if (bIndex == null) return -1;

        // Convert to int safely
        int aVal = 0;
        int bVal = 0;

        if (aIndex is num) {
          aVal = aIndex.toInt();
        } else if (aIndex is String) {
          aVal = int.tryParse(aIndex) ?? 0;
        }

        if (bIndex is num) {
          bVal = bIndex.toInt();
        } else if (bIndex is String) {
          bVal = int.tryParse(bIndex) ?? 0;
        }

        return aVal.compareTo(bVal);
      });
    }
  }

// Fix 2: Update your _fetchMoviesInBackground method
  Future<void> _fetchMoviesInBackground() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String authKey = AuthManager.authKey;
      if (authKey.isEmpty) {
        authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
      }

      final response = await http.get(
        Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllMovies'),
        headers: {'auth-key': authKey},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Use the safe sorting method
        _sortMoviesData(data);

        // Compare with cached data
        final prefs = await SharedPreferences.getInstance();
        final cachedMovies = prefs.getString('movies_list');
        final String newMoviesJson = json.encode(data);

        if (cachedMovies == null || cachedMovies != newMoviesJson) {
          await prefs.setString('movies_list', newMoviesJson);

          setState(() {
            moviesList = data;
            _initializeMovieFocusNodes();
          });
        }
      }
    } catch (e) {}
  }

// Fix 3: Update your _fetchMovies method
  Future<void> _fetchMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String authKey = AuthManager.authKey;
      if (authKey.isEmpty) {
        authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
      }

      final response = await http.get(
        Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllMovies'),
        headers: {'auth-key': authKey},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Use the safe sorting method
        _sortMoviesData(data);

        // Save to cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('movies_list', json.encode(data));

        setState(() {
          moviesList = data;
          _initializeMovieFocusNodes();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load movies';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
        _isLoading = false;
      });
    }
  }

// Fix 4: Add null-safe helper methods for your data handling

// Fix 5: Update your NewsItemModel conversion to be more robust
  List<NewsItemModel> _convertToNewsItemModels(List<dynamic> movies) {
    return movies.map((m) {
      // Use null-safe conversion
      Map<String, dynamic> movie = m as Map<String, dynamic>;

      return NewsItemModel(
        id: movie.safeString('id'),
        name: movie.safeString('name'),
        banner: movie.safeString('banner'),
        poster: movie.safeString('poster'),
        description: movie.safeString('description'),
        url: movie.safeString('url'),
        streamType: movie.safeString('streamType'),
        type: movie.safeString('type'),
        genres: movie.safeString('genres'),
        status: movie.safeString('status'),
        videoId: movie.safeString('videoId'),
        index: movie.safeString('index'),
        image: '',unUpdatedUrl: '',
      );
    }).toList();
  }






// // Fix 6: Update your _handleMovieTap method
//   Future<void> _handleMovieTap(dynamic movie) async {
//     if (_isNavigating) return;
//     _isNavigating = true;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async {
//             _isNavigating = false;
//             return true;
//           },
//           child: Center(child: CircularProgressIndicator()),
//         );
//       },
//     );

//     try {
//       // Use the safe conversion method
//       List<NewsItemModel> allMovies = _convertToNewsItemModels(moviesList);
//       print('allMovies: $allMovies');
//       Navigator.of(context, rootNavigator: true).pop();

//       // Safe ID handling
//       Map<String, dynamic> movieMap = movie as Map<String, dynamic>;
//       int movieId = movieMap.safeInt('id');

//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => DetailsPage(
//             id: movieId,
//             channelList: allMovies,
//             source: 'isMovieScreen',
//             banner: movieMap.safeString('banner'),
//             name: movieMap.safeString('name'),
//           ),
//         ),
//       );
//     } catch (e) {
//       Navigator.of(context, rootNavigator: true).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     } finally {
//       _isNavigating = false;
//     }
//   }





Future<void> _handleMovieTap(dynamic movie) async {
  if (_isNavigating) return;
  _isNavigating = true;

  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          _isNavigating = false;
          return true;
        },
        child: Center(child: CircularProgressIndicator()),
      );
    },
  );

  try {
    // Fetch fresh data from API before navigation
    List<NewsItemModel> freshMovies = await _fetchFreshMoviesData();
    
    // If fresh data fetch fails, fall back to cached data
    if (freshMovies.isEmpty) {
      freshMovies = _convertToNewsItemModels(moviesList);
    }

    // Close loading dialog
    Navigator.of(context, rootNavigator: true).pop();

    // Safe ID handling
    Map<String, dynamic> movieMap = movie as Map<String, dynamic>;
    int movieId = movieMap.safeInt('id');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          id: movieId,
          channelList: freshMovies, // Use fresh data instead of cached
          source: 'isMovieScreen',
          banner: movieMap.safeString('banner'),
          name: movieMap.safeString('name'),
        ),
      ),
    );
  } catch (e) {
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  } finally {
    _isNavigating = false;
  }
}

// Add this new method to fetch fresh movies data
Future<List<NewsItemModel>> _fetchFreshMoviesData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String authKey = AuthManager.authKey;
    if (authKey.isEmpty) {
      authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
    }

    final response = await http.get(
      Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllMovies'),
      headers: {'auth-key': authKey},
    ).timeout(Duration(seconds: 10)); // Add timeout for better UX

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      
      // Sort data using the safe sorting method
      _sortMoviesData(data);
      
      // Convert to NewsItemModel list and return
      return _convertToNewsItemModels(data);
    } else {
      print('Failed to fetch fresh movies: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error fetching fresh movies data: $e');
    return [];
  }
}


// Fix 7: Add retry mechanism for network failures
  Future<void> _fetchMoviesWithRetry({int retryCount = 0}) async {
    try {
      await _fetchMovies();
    } catch (e) {
      if (retryCount < _maxRetries) {
        await Future.delayed(Duration(seconds: _retryDelay));
        await _fetchMoviesWithRetry(retryCount: retryCount + 1);
      } else {
        setState(() {
          _errorMessage = 'Failed to load movies after $_maxRetries attempts';
          _isLoading = false;
        });
      }
    }
  }

  // Add this method to your _MoviesState class, similar to MusicScreen
  void _scrollToFirstItem() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // Scroll to beginning
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }


  
// Replace your existing _buildMoviePoster method with this enhanced version
Widget _buildMoviePoster(dynamic movie) {
  String movieId = movie['id'].toString();
  bool isFocused = movieFocusNodes[movieId]?.hasFocus ?? false;
  Color dominantColor = context.watch<ColorProvider>().dominantColor;

  final String imageUrl =
      movie['banner']?.toString() ?? movie['poster']?.toString() ?? '';

  return AnimatedContainer(
    padding: EdgeInsets.symmetric(horizontal: screenwdt*0.002),
    curve: Curves.linear, // Gentle curve for smooth scaling
    width: MediaQuery.of(context).size.width * 0.19,
    height: isFocused
        ? MediaQuery.of(context).size.height * 0.26 // Moderate height increase
        : MediaQuery.of(context).size.height * 0.20,
    duration: const Duration(milliseconds: 800), // Slower duration for gradual effect
    decoration: BoxDecoration(
      border: Border.all(
        color: isFocused ? dominantColor : Colors.transparent,
        width:  5.0 , // Slightly reduced border width
      ),
      boxShadow: isFocused
          ? [
              BoxShadow(
                color: dominantColor.withOpacity(0.8), // Softer shadow
                blurRadius: 25.0, 
                spreadRadius: 6.0, // Reduced spread for subtle effect
                offset: Offset(0, 3), 
              ),
              // Additional inner glow effect
              BoxShadow(
                color: dominantColor.withOpacity(0.5),
                blurRadius: 12.0,
                spreadRadius: 1.0,
                offset: Offset(0, 0),
              ),
            ]
          : [
              // Subtle shadow even when not focused
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6.0,
                spreadRadius: 0.5,
                offset: Offset(0, 2),
              ),
            ],
      borderRadius: BorderRadius.circular(0), 
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 0), // Match the outer duration
        curve: Curves.linear, // Same curve for consistency
        child: _buildOptimizedImage(
          imageUrl,
          movieId,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          
        ),
      ),
    ),
  );
}

// Also enhance the movie title animation
Widget _buildMovieTitle(dynamic movie) {
  String movieId = movie['id'].toString();
  bool isFocused = movieFocusNodes[movieId]?.hasFocus ?? false;
  Color dominantColor = context.watch<ColorProvider>().dominantColor;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 800), // Match poster animation timing
    curve: Curves.easeInOut, // Consistent curve
    width: MediaQuery.of(context).size.width * 0.15,
    child: AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 800), // Slower text animation
      curve: Curves.easeInOut,
      style: TextStyle(
        fontSize: isFocused ? nametextsz * 1.0 : nametextsz, // Subtle size increase
        fontWeight: FontWeight.bold,
        color: isFocused ? dominantColor : Colors.white,
        shadows: isFocused
            ? [
                Shadow(
                  color: dominantColor.withOpacity(0.4),
                  blurRadius: 6.0,
                  offset: Offset(0, 1),
                ),
              ]
            : [],
      ),
      child: Text(
        movie['name']?.toString()?.toUpperCase() ?? '',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}





// Enhanced View All item animation
Widget _buildViewAllItem() {
  bool isFocused = _viewAllFocusNode?.hasFocus ?? false;

  return Focus(
    focusNode: _viewAllFocusNode,
    onKey: (FocusNode node, RawKeyEvent event) {
      if (event is RawKeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          if (moviesList.isNotEmpty) {
            String movieId = moviesList[6]['id'].toString();
            FocusScope.of(context).requestFocus(movieFocusNodes[movieId]);
            return KeyEventResult.handled;
          }
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          context.read<FocusProvider>().requestSubVodFocus();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          FocusScope.of(context).unfocus();
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              context.read<FocusProvider>().requestFirstWebseriesFocus();
            }
          });
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.select) {
          _navigateToMoviesGrid();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    },
    child: GestureDetector(
      onTap: _navigateToMoviesGrid,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 1000), // Slower, gentle animation
            curve: Curves.easeInOut, // Smooth curve
            width: MediaQuery.of(context).size.width * 0.19,
            height: isFocused
                ? MediaQuery.of(context).size.height * 0.26 // Match other items
                : MediaQuery.of(context).size.height * 0.20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: Colors.grey[800],
              border: Border.all(
                color: isFocused ? _viewAllColor : Colors.transparent,
                width: isFocused ? 3.0 : 0.0,
              ),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: _viewAllColor.withOpacity(0.5),
                        blurRadius: 25.0,
                        spreadRadius: 6.0,
                        offset: Offset(0, 3),
                      ),
                      BoxShadow(
                        color: _viewAllColor.withOpacity(0.3),
                        blurRadius: 12.0,
                        spreadRadius: 1.0,
                        offset: Offset(0, 0),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6.0,
                        spreadRadius: 0.5,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 800),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isFocused ? 15 : 14, // Gentle size change
                      shadows: isFocused
                          ? [
                              Shadow(
                                color: _viewAllColor.withOpacity(0.4),
                                blurRadius: 6.0,
                                offset: Offset(0, 1),
                              ),
                            ]
                          : [],
                    ),
                    child: Text('View All'),
                  ),
                  SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 800),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isFocused ? 16 : 15, // Gentle size change
                      shadows: isFocused
                          ? [
                              Shadow(
                                color: _viewAllColor.withOpacity(0.4),
                                blurRadius: 6.0,
                                offset: Offset(0, 1),
                              ),
                            ]
                          : [],
                    ),
                    child: Text('MOVIES'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            width: MediaQuery.of(context).size.width * 0.15,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 800),
              style: TextStyle(
                color: isFocused ? _viewAllColor : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isFocused ? nametextsz * 1.05 : nametextsz, // Subtle change
                shadows: isFocused
                    ? [
                        Shadow(
                          color: _viewAllColor.withOpacity(0.4),
                          blurRadius: 6.0,
                          offset: Offset(0, 1),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                'MOVIES',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}




  // Optimized image building with caching
  Widget _buildOptimizedImage(String imageUrl, String movieId,
      {required double width, required double height}) {
    // Check cache first
    if (_imageCache.containsKey(movieId)) {
      return _imageCache[movieId]!;
    }

    Widget imageWidget;

    if (imageUrl.isEmpty) {
      imageWidget = _buildErrorWidget(width, height, 'Empty URL');
    } else if (imageUrl.startsWith('data:image/')) {
      // Handle data images with caching
      if (_decodedImages.containsKey(movieId)) {
        final bytes = _decodedImages[movieId];
        if (bytes != null) {
          imageWidget = Image.memory(
            bytes,
            width: width,
            height: height,
            fit: BoxFit.cover ,
            gaplessPlayback: true, // Prevents flicker
          );
        } else {
          imageWidget = _buildErrorWidget(width, height, 'Decode failed');
        }
      } else {
        // Decode and cache
        try {
          if (imageUrl.contains(',')) {
            final String base64String = imageUrl.split(',')[1];
            final Uint8List bytes = base64Decode(base64String);
            _decodedImages[movieId] = bytes;

            imageWidget = Image.memory(
              bytes,
              width: width,
              height: height,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorWidget(width, height, 'Display error');
              },
            );
          } else {
            _decodedImages[movieId] = null;
            imageWidget = _buildErrorWidget(width, height, 'Invalid format');
          }
        } catch (e) {
          _decodedImages[movieId] = null;
          imageWidget = _buildErrorWidget(width, height, 'Decode error');
        }
      }
    } else if (imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://')) {
      // Handle network images
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        memCacheWidth: (width * 2).toInt(), // Optimize memory cache
        memCacheHeight: (height * 2).toInt(),
        placeholder: (context, url) => localImage,
        errorWidget: (context, url, error) {
          return localImage;
        },
      );
    } else {
      imageWidget = _buildErrorWidget(width, height, 'Unknown format');
    }

    // Cache the widget (but don't cache network images as they handle their own caching)
    if (!imageUrl.startsWith('http')) {
      _imageCache[movieId] = imageWidget;
    }

    return imageWidget;
  }

  // Helper method for error widgets
  Widget _buildErrorWidget(double width, double height, String errorType) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.white,
            size: 30,
          ),
          if (errorType.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              errorType,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // Add this method to clear cache when needed (call in dispose or when data changes)
  void _clearImageCache() {
    _imageCache.clear();
    _decodedImages.clear();
  }

  // Update your dispose method to include cache clearing
  @override
  void dispose() {
    _clearImageCache();
    for (var node in movieFocusNodes.values) {
      node.dispose();
    }
    _viewAllFocusNode?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Also update _initializeMovieFocusNodes to clear cache when data changes
  void _initializeMovieFocusNodes() {
    _clearImageCache(); // Clear cache when movie data changes
    movieFocusNodes.clear();
    for (var movie in moviesList) {
      String movieId = movie['id'].toString(); // Convert to string consistently
      movieFocusNodes[movieId] = FocusNode()
        ..addListener(() {
          if (movieFocusNodes[movieId]!.hasFocus) {
            _scrollToFocusedItem(movieId);
          }
        });
    }
    _registerMoviesFocus();
  }

  // 2. _registerMoviesFocus method को update करें
  void _registerMoviesFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final focusProvider = context.read<FocusProvider>();

      if (moviesList.isNotEmpty) {
        final firstMovieId =
            moviesList[0]['id'].toString(); // Convert to string
        if (movieFocusNodes.containsKey(firstMovieId)) {
          focusProvider
              .setFirstManageMoviesFocusNode(movieFocusNodes[firstMovieId]!);
        }
      }
    });
  }

  Future<void> _loadCachedDataAndFetchMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Step 1: Load cached data
      await _loadCachedMoviesData();

      // Step 2: Fetch new data in the background and update UI if needed
      await _fetchMoviesInBackground();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load movies';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCachedMoviesData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedMovies = prefs.getString('movies_list');

      if (cachedMovies != null) {
        final List<dynamic> cachedData = json.decode(cachedMovies);
        setState(() {
          moviesList = cachedData;
          _initializeMovieFocusNodes();
          _isLoading = false; // Show cached data immediately
        });
      } else {
        // If no cached data, fetch from API immediately
        await _fetchMovies();
      }
    } catch (e) {
      // If cache fails, try to fetch from API
      await _fetchMovies();
    }
  }


  void _scrollToFocusedItem(String itemId) {
    if (movieFocusNodes[itemId] != null && movieFocusNodes[itemId]!.hasFocus) {
      Scrollable.ensureVisible(
        movieFocusNodes[itemId]!.context!,
        alignment: 0.25,
        duration: Duration(milliseconds: 800),
        curve: Curves.linear,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          SizedBox(height: screenhgt * 0.03),
          _buildTitle(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'MOVIES',
            style: TextStyle(
              fontSize: Headingtextsz,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      return Center(
          child: Text(_errorMessage, style: TextStyle(color: Colors.white)));
    } else if (moviesList.isEmpty) {
      return Center(
          child:
              Text('No movies found', style: TextStyle(color: Colors.white)));
    } else {
      return _buildMoviesList();
    }
  }

  Widget _buildMoviesList() {
    bool showViewAll = moviesList.length > 7;
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      itemCount: showViewAll ? 8 : moviesList.length,
      itemBuilder: (context, index) {
        if (showViewAll && index == 7) {
          return _buildViewAllItem();
        }
        var movie = moviesList[index];
        return _buildMovieItem(movie, index);
      },
    );
  }



  Widget _buildMovieItem(dynamic movie, int index) {
    String movieId = movie['id'].toString(); // Convert to string consistently

    movieFocusNodes.putIfAbsent(
      movieId,
      () => FocusNode()
        ..addListener(() {
          if (movieFocusNodes[movieId]!.hasFocus) {
            _scrollToFocusedItem(movieId);
          }
        }),
    );

    return Focus(
      focusNode: movieFocusNodes[movieId],
      onFocusChange: (hasFocus) async {
        if (hasFocus) {
          Color dominantColor = await _paletteColorService.getSecondaryColor(
            movie['poster']?.toString() ?? '',
            fallbackColor: Colors.grey,
          );
          context.read<ColorProvider>().updateColor(dominantColor, true);
        } else {
          context.read<ColorProvider>().resetColor();
        }
      },
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (index < moviesList.length - 1 && index != 6) {
              String nextMovieId = moviesList[index + 1]['id'].toString();
              FocusScope.of(context).requestFocus(movieFocusNodes[nextMovieId]);
              return KeyEventResult.handled;
            } else if (index == 6 && moviesList.length > 7) {
              FocusScope.of(context).requestFocus(_viewAllFocusNode);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              String prevMovieId = moviesList[index - 1]['id'].toString();
              FocusScope.of(context).requestFocus(movieFocusNodes[prevMovieId]);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            context.read<FocusProvider>().requestSubVodFocus();
            return KeyEventResult.handled;
          }
          //  else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          //   // Fix: Unfocus current and request webseries focus with delay
          //   _scrollToFirstItem();
          //   FocusScope.of(context).unfocus();
          //   Future.delayed(const Duration(milliseconds: 800), () {
          //     if (mounted) {
          //       context.read<FocusProvider>().requestFirstWebseriesFocus();
          //     }
          //   });
          //   return KeyEventResult.handled;
          // }

          // In your Movies widget (where you handle key events):

          else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Unfocus current and request webseries focus
            FocusScope.of(context).unfocus();

            // Add a small delay to ensure widgets are built
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                Provider.of<FocusProvider>(context, listen: false)
                    .requestFirstWebseriesFocus();
              }
            });

            return KeyEventResult.ignored;
          } else if (event.logicalKey == LogicalKeyboardKey.select) {
            _handleMovieTap(movie);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _handleMovieTap(movie),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMoviePoster(movie),
            SizedBox(height: 8),
            _buildMovieTitle(movie),
          ],
        ),
      ),
    );
  }

  // Enhanced _buildImageWidget method with better error handling
  Widget _buildImageWidget(String imageUrl,
      {required double width, required double height}) {
    // Check if imageUrl is null or empty
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[800],
        child: Icon(
          Icons.image_not_supported,
          color: Colors.white,
          size: 30,
        ),
      );
    }

    if (imageUrl.startsWith('data:image/')) {
      // Handle data:image format
      try {
        // Check if the format is correct
        if (!imageUrl.contains(',')) {
          return _buildErrorWidget(width, height, 'Invalid data format');
        }

        final String base64String = imageUrl.split(',')[1];

        if (base64String.isEmpty) {
          return _buildErrorWidget(width, height, 'Empty base64');
        }

        final Uint8List bytes = base64Decode(base64String);

        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget(width, height, 'Memory error');
          },
        );
      } catch (e) {
        return _buildErrorWidget(width, height, 'Decode error');
      }
    } else if (imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://')) {
      // Handle network images using CachedNetworkImage
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey[800],
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          return _buildErrorWidget(width, height, 'Network error');
        },
      );
    } else {
      return _buildErrorWidget(width, height, 'Unknown format');
    }
  }


  void _navigateToMoviesGrid() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoviesGridView(moviesList: moviesList),
      ),
    );
  }
}

class MoviesGridView extends StatefulWidget {
  final List<dynamic> moviesList;

  const MoviesGridView({Key? key, required this.moviesList}) : super(key: key);

  @override
  _MoviesGridViewState createState() => _MoviesGridViewState();
}

class _MoviesGridViewState extends State<MoviesGridView> {
  late Map<String, FocusNode> _movieFocusNodes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _movieFocusNodes = {
      for (var movie in widget.moviesList)
        movie['id'].toString(): FocusNode() // Convert to string consistently
    };
  }

  @override
  void dispose() {
    for (var node in _movieFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: widget.moviesList.length,
           

            
itemBuilder: (context, index) {
  final movie = widget.moviesList[index];
  String movieId = movie['id'].toString();

  return FocusableMoviesWidget(
    imageUrl: movie['banner']?.toString() ?? '',
    name: movie['name']?.toString() ?? '',
    focusNode: _movieFocusNodes[movieId]!,
    
    // Pass the movie data for fresh fetch
    movieData: movie,
    source: 'isMovieScreen',
    
    // Remove the old onTap since it's now handled internally
    onTap: () {
      // This is now just a fallback - the widget will handle fresh data fetch internally
      print('Fallback onTap called');
    },
    
    fetchPaletteColor: (url) =>
        PaletteColorService().getSecondaryColor(url),
  );
},

          ),
          if (_isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

// Helper extension for safe type conversion (optional addition)
extension SafeTypeConversion on Map<String, dynamic> {
  String safeString(String key, [String defaultValue = '']) {
    final value = this[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  int safeInt(String key, [int defaultValue = 0]) {
    final value = this[key];
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }
}

// Usage example with the extension (you can use this in your movie handling):
/*
// Instead of:
movie['id'].toString()

// You can use:
movie.safeString('id')

// For integer conversion:
// Instead of:
int.parse(movie['id'])

// You can use:
movie.safeInt('id')
*/