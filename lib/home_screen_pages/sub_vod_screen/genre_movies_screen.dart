import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
import 'package:mobi_tv_entertainment/provider/device_info_provider.dart';
import 'package:mobi_tv_entertainment/services/history_service.dart';
// import 'package:mobi_tv_entertainment/utils/session_manager.dart'; // Assuming SessionManager exists
import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player.dart';
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/video_widget/youtube_webview_player.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Professional Color Palette
class ProfessionalColors {
  static const primaryDark = Color(0xFF0A0E1A);
  static const surfaceDark = Color(0xFF1A1D29);
  static const cardDark = Color(0xFF2A2D3A);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentGreen = Color(0xFF10B981);
  static const accentRed = Color(0xFFEF4444);
  static const accentOrange = Color(0xFFF59E0B);
  static const accentPink = Color(0xFFEC4899);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const focusGlow = Color(0xFF60A5FA);
}

// Data Models
class GenreResponse {
  final bool status;
  final List<String> genres;
  GenreResponse({required this.status, required this.genres});
  factory GenreResponse.fromJson(Map<String, dynamic> json) {
    return GenreResponse(
      status: json['status'],
      genres: List<String>.from(json['genres']),
    );
  }
}

class MovieResponse {
  final bool status;
  final int total;
  final List<Movie> data;
  MovieResponse({required this.status, required this.total, required this.data});
  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    return MovieResponse(
      status: json['status'],
      total: json['total'],
      data: (json['data'] as List).map((i) => Movie.fromJson(i)).toList(),
    );
  }
}
class Movie {
  final int id;
  final String name;
  final String? banner;
  final String? poster;
  final String? description;
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
    this.contentType,
    this.sourceType,
    this.youtubeTrailer,
    this.updatedAt,
    this.movieUrl,
    this.status,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      name: json['name'],
      banner: json['banner'],
      poster: json['poster'],
      description: json['description'],
      contentType: json['content_type'],
      sourceType: json['source_type'],
      youtubeTrailer: json['youtube_trailer'],
      updatedAt: json['updated_at'],
      movieUrl: json['movie_url'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'name': name, 'banner': banner, 'poster': poster,
      'description': description, 'content_type': contentType, 'source_type': sourceType,
      'youtube_trailer': youtubeTrailer, 'updated_at': updatedAt, 'movie_url': movieUrl,
      'status': status,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie.fromJson(map);
  }

  String getPlayableUrl() {
    if (sourceType == 'YoutubeLive') {
      return movieUrl ?? '';
    }
    if (youtubeTrailer != null && youtubeTrailer!.isNotEmpty) {
      return youtubeTrailer!;
    }
    return movieUrl ?? '';
  }
}

Future<String> _fetchAndCacheDataIsolate(Map<String, String> params) async {
  final String tvChannelId = params['tvChannelId']!;
  final String authKey = params['authKey']!;

  try {
    final genresResponse = await http.get(
      Uri.parse('https://dashboard.cpplayers.com/api/v2/getGenreByContentNetwork/$tvChannelId'),
      headers: {'auth-key': authKey, 'Accept': 'application/json', 'domain': 'coretechinfo.com'},
    );

    if (genresResponse.statusCode != 200) {
      throw Exception('Failed to load genres in isolate');
    }
    final genreData = GenreResponse.fromJson(json.decode(genresResponse.body));
    if (!genreData.status) {
      return '';
    }

    final genres = genreData.genres;
    final Map<String, List<Movie>> moviesByGenre = {};

    for (final genre in genres) {
      final moviesResponse = await http.post(
        Uri.parse('https://dashboard.cpplayers.com/api/v2/getAllContentsOfNetworkNew?page=1&records=7'),
        headers: {'auth-key': authKey, 'domain': 'coretechinfo.com', 'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode({"genre": genre, "network_id": tvChannelId}),
      );

      if (moviesResponse.statusCode == 200) {
        final movieData = MovieResponse.fromJson(json.decode(moviesResponse.body));
        if (movieData.status && movieData.data.isNotEmpty) {
          final activeMovies = movieData.data.where((movie) => movie.status == 1).toList();
          if (activeMovies.isNotEmpty) {
            moviesByGenre[genre] = activeMovies;
          }
        }
      }
    }
    
    final Map<String, dynamic> serializableData = {
      'genres': genres,
      'moviesByGenre': moviesByGenre.map((key, value) => MapEntry(key, value.map((m) => m.toMap()).toList())),
    };

    return json.encode(serializableData);
  } catch (e) {
    print("Isolate Error: $e");
    return '';
  }
}


class GenreMoviesScreen extends StatefulWidget {
  final String tvChannelId;
  final String logoUrl;
  final String title;

  const GenreMoviesScreen({
    super.key,
    required this.tvChannelId,
    required this.logoUrl,
    required this.title,
  });

  @override
  State<GenreMoviesScreen> createState() => _GenreMoviesScreenState();
}

class _GenreMoviesScreenState extends State<GenreMoviesScreen> {
  bool _isLoading = true;
  String? _error;
  List<String> _genres = [];
  final Map<String, List<Movie>> _moviesByGenre = {};
  
  final List<List<FocusNode>> _focusNodes = [];
  final ScrollController _verticalScrollController = ScrollController();
  final Map<int, ScrollController> _horizontalScrollControllers = {};
  final List<GlobalKey> _rowKeys = [];
  final List<List<GlobalKey>> _cardKeys = [];

  final List<Color> _focusColors = [
    ProfessionalColors.accentBlue, ProfessionalColors.accentPurple, ProfessionalColors.accentGreen,
    ProfessionalColors.accentOrange, ProfessionalColors.accentPink, ProfessionalColors.accentRed,
  ];
  final List<Gradient> _genreBackgrounds = const [
    LinearGradient(colors: [Color(0xFF1A1D29), Color(0xFF0F121E)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
    LinearGradient(colors: [Color(0xFF1C1A29), Color(0xFF110F1E)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
    LinearGradient(colors: [Color(0xFF1A2129), Color(0xFF0F161E)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
    LinearGradient(colors: [Color(0xFF211A29), Color(0xFF160F1E)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
  ];
  bool _isVideoLoading = false;
  
  String _focusedItemName = '';

  String get _cacheKey => 'genre_movies_cache_${widget.tvChannelId}';

  @override
  void initState() {
    super.initState();
    _focusedItemName = widget.title; // Initialize with the screen's static title.
    _loadInitialData();
  }
  
  @override
  void dispose() {
    for (var row in _focusNodes) {
      for (var node in row) {
        node.dispose();
      }
    }
    _verticalScrollController.dispose();
    _horizontalScrollControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
  
  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);

    if (cachedData != null && cachedData.isNotEmpty) {
      _parseAndSetState(cachedData);
      setState(() { _isLoading = false; });
      _refreshDataInBackground();
    } else {
      await _fetchDataWithLoading();
    }
  }
  
  Future<void> _refreshDataInBackground() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authKey = prefs.getString('auth_key') ?? '';

      final String freshDataJson = await compute(_fetchAndCacheDataIsolate, {
        'tvChannelId': widget.tvChannelId,
        'authKey': authKey,
      });

      if (freshDataJson.isNotEmpty) {
        await prefs.setString(_cacheKey, freshDataJson);
        print("Cache successfully updated in the background.");
      }
    } catch (e) {
      print("Background refresh failed: $e");
    }
  }
  
  Future<void> _fetchDataWithLoading() async {
    setState(() { _isLoading = true; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final authKey = prefs.getString('auth_key') ?? '';

      final String freshDataJson = await _fetchAndCacheDataIsolate({
        'tvChannelId': widget.tvChannelId,
        'authKey': authKey,
      });

      if (freshDataJson.isNotEmpty) {
        await prefs.setString(_cacheKey, freshDataJson);
        _parseAndSetState(freshDataJson);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _parseAndSetState(String jsonData) {
    final data = json.decode(jsonData) as Map<String, dynamic>;
    
    _focusNodes.clear();
    _cardKeys.clear();
    _rowKeys.clear();
    _horizontalScrollControllers.values.forEach((c) => c.dispose());
    _horizontalScrollControllers.clear();

    _genres = List<String>.from(data['genres']);
    _moviesByGenre.clear();
    _moviesByGenre.addAll((data['moviesByGenre'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        (value as List).map((movieMap) => Movie.fromMap(movieMap)).toList(),
      ),
    ));

    _rowKeys.addAll(List.generate(_genres.length, (_) => GlobalKey()));

    for (int i = 0; i < _genres.length; i++) {
      final genre = _genres[i];
      final movies = _moviesByGenre[genre] ?? [];
      if (movies.isEmpty) continue;

      int nodeCount = movies.length + (movies.length == 7 ? 1 : 0);
      
      var rowNodes = List.generate(nodeCount, (_) => FocusNode());
      var rowCardKeys = List.generate(nodeCount, (_) => GlobalKey());
      _cardKeys.add(rowCardKeys);
      
      _horizontalScrollControllers[i] = ScrollController();

      for (int j = 0; j < nodeCount; j++) {
        rowNodes[j].addListener(() {
          if (rowNodes[j].hasFocus) {
            _onItemFocusChange(i, j);
          }
        });
      }
      _focusNodes.add(rowNodes);
    }

    if(mounted) {
      setState(() {});
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_focusNodes.isNotEmpty && _focusNodes.first.isNotEmpty) {
          _focusNodes.first.first.requestFocus();
        }
      });
    }
  }
  
void _onItemFocusChange(int genreIndex, int movieIndex) {
  final genre = _genres[genreIndex];
  final movies = _moviesByGenre[genre] ?? [];
  if (movieIndex < movies.length) {
    final Movie focusedMovie = movies[movieIndex];
    if (mounted) setState(() => _focusedItemName = focusedMovie.name);
  } else {
    if (mounted) setState(() => _focusedItemName = "View All");
  }

  _scrollToFocusedVertical(genreIndex);
  _scrollToFocusedHorizontal(genreIndex, movieIndex);
}

void _scrollToFocusedVertical(int genreIndex) {
  final rowContext = _rowKeys[genreIndex].currentContext;
  if (rowContext == null) return;

  final renderBox = rowContext.findRenderObject() as RenderBox;
  final rowOffset = renderBox.localToGlobal(Offset.zero);
  final scrollOffset = _verticalScrollController.offset;

  const appBarHeight = 100.0; // Adjusted for new AppBar
  final rowTop = rowOffset.dy + scrollOffset - (screenhgt * 0.5 - appBarHeight * 0.5);

  _verticalScrollController.animateTo(
    rowTop.clamp(0.0, _verticalScrollController.position.maxScrollExtent),
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOut,
  );
}

void _scrollToFocusedHorizontal(int genreIndex, int movieIndex) {
  final scrollController = _horizontalScrollControllers[genreIndex];
  if (scrollController == null) return;
  
  final cardContext = _cardKeys[genreIndex][movieIndex].currentContext;
  if (cardContext == null) return;
  
  final renderBox = cardContext.findRenderObject() as RenderBox;
  final cardOffset = renderBox.localToGlobal(Offset.zero, ancestor: scrollController.position.context.storageContext.findRenderObject());
  
  double targetOffset = scrollController.offset + cardOffset.dx - 40;
  
  targetOffset = targetOffset.clamp(0.0, scrollController.position.maxScrollExtent);
  
  scrollController.animateTo(
    targetOffset,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
}
  
  Future<void> _playContent(Movie content) async {
    if (_isVideoLoading || !mounted) return;
    setState(() { _isVideoLoading = true; });
    try {
      String playableUrl = content.getPlayableUrl();
      try {
        // await HistoryService.updateUserHistory(...);
      } catch (e) { print("History update failed, but proceeding to play. Error: $e"); }
      if (content.contentType == 2) {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => WebSeriesDetailsPage(
            id: content.id, banner: content.banner ?? '', poster: content.poster ?? '',
            logo: widget.logoUrl, name: content.name, updatedAt: content.updatedAt ?? '',
          ),),);
        return;
      }
      if (playableUrl.isEmpty) { throw Exception('No video URL found'); }
      if (!mounted) return;
      if (content.sourceType == 'YoutubeLive' || (content.youtubeTrailer != null && content.youtubeTrailer!.isNotEmpty)) {
        final deviceInfo = context.read<DeviceInfoProvider>();
        if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => YoutubeWebviewPlayer(videoUrl: playableUrl, name: content.name)));
        } else {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => CustomYoutubePlayer(
              videoData: VideoData(
                id: content.id.toString(), title: content.name, youtubeUrl: playableUrl,
                thumbnail: content.poster ?? content.banner ?? '', description: content.description ?? '',
              ), playlist: [],
            )));
        }
      } else {
        await Navigator.push(context, MaterialPageRoute( builder: (context) => VideoScreen(
            videoUrl: playableUrl, bannerImageUrl: content.poster ?? content.banner ?? '',
            videoId: content.id, name: content.name, updatedAt: content.updatedAt ?? '',
            source: 'isVod', channelList: [], liveStatus: false,
          ),),);
      }
    } catch (e) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'))); }
    } finally {
      if (mounted) { setState(() { _isVideoLoading = false; }); }
    }
  }

  void _navigateToGridPage(String genre) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => GenreGridScreen(
      genre: genre, tvChannelId: widget.tvChannelId, logoUrl: widget.logoUrl,
    ),),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [ProfessionalColors.primaryDark, Color(0xFF06080F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Main Scrollable Content
          CustomScrollView(
            controller: _verticalScrollController,
            slivers: [
              // Padding to prevent content from being hidden by the custom AppBar
              SliverPadding(padding: EdgeInsets.only(top: 100.0)),
              _isLoading
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()))
                  : _error != null
                      ? SliverFillRemaining(
                          child: Center(child: Text('Error: $_error')))
                      : _buildGenresList(),
            ],
          ),
          // The new fixed AppBar positioned on top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildBeautifulAppBar(),
          ),
          // Loading indicator overlay
          if (_isVideoLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
            ),
        ],
      ),
    );
  }

  Widget _buildBeautifulAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ProfessionalColors.primaryDark.withOpacity(0.95),
            ProfessionalColors.surfaceDark.withOpacity(0.9),
            ProfessionalColors.surfaceDark.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: ProfessionalColors.accentBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              right: 30,
              bottom: 10,
            ),
            child: Row(
              children: [
                // Back Button
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        ProfessionalColors.accentBlue.withOpacity(0.3),
                        ProfessionalColors.accentPurple.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),

                // MODIFIED: Replaced Text with GradientText for the main title
                GradientText(
                  widget.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  gradient: const LinearGradient(colors: [
                    ProfessionalColors.accentPink,
                    ProfessionalColors.accentPurple,
                    ProfessionalColors.accentBlue,
                  ]),
                ),
                const SizedBox(width: 40),
                // Focused Banner Name (in remaining space)
                Expanded(
                  child: Text(
                    _focusedItemName,
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: ProfessionalColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Logo
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.logoUrl),
                    radius: 20,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenresList() {
    final activeGenres = _genres.where((genre) => _moviesByGenre[genre]?.isNotEmpty ?? false).toList();
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final genre = activeGenres[index];
          final genreIndexInOriginal = _genres.indexOf(genre);
          final movies = _moviesByGenre[genre] ?? [];

          final bool hasViewAll = movies.length == 7;
          final int itemCount = movies.length + (hasViewAll ? 1 : 0);

          return Container(
            key: _rowKeys[genreIndexInOriginal],
            decoration: BoxDecoration(gradient: _genreBackgrounds[genreIndexInOriginal % _genreBackgrounds.length]),
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, bottom: 5.0),
                  // MODIFIED: Replaced Text with GradientText for genre titles
                  child: GradientText(
                    genre,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    gradient: const LinearGradient(
                      colors: [
                        ProfessionalColors.accentGreen,
                        ProfessionalColors.accentOrange,
                        ProfessionalColors.accentPink,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                SizedBox(
                  height: bannerhgt + 25,
                  child: ListView.builder(
                    controller: _horizontalScrollControllers[genreIndexInOriginal],
                    scrollDirection: Axis.horizontal,
                    itemCount: itemCount,
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    itemBuilder: (context, movieIndex) {
                      if (hasViewAll && movieIndex == movies.length) {
                        return ViewAllCard(
                          key: _cardKeys[genreIndexInOriginal][movieIndex],
                          focusNode: _focusNodes[genreIndexInOriginal][movieIndex],
                          focusColors: _focusColors,
                          uniqueIndex: genreIndexInOriginal * 10 + movieIndex,
                          onTap: () => _navigateToGridPage(genre),
                        );
                      }
                      
                      final movie = movies[movieIndex];
                      return MovieCard(
                        key: _cardKeys[genreIndexInOriginal][movieIndex],
                        movie: movie,
                        logoUrl: widget.logoUrl,
                        focusNode: _focusNodes[genreIndexInOriginal][movieIndex],
                        focusColors: _focusColors,
                        uniqueIndex: genreIndexInOriginal * 10 + movieIndex,
                        onTap: () => _playContent(movie),
                        isFirst: movieIndex == 0,
                        isLast: !hasViewAll && movieIndex == movies.length - 1,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        childCount: activeGenres.length,
      ),
    );
  }
}

class MovieCard extends StatefulWidget {
  final Movie movie;
  final String logoUrl;
  final FocusNode focusNode;
  final List<Color> focusColors;
  final int uniqueIndex;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const MovieCard({
    super.key,
    required this.movie,
    required this.logoUrl,
    required this.focusNode,
    required this.focusColors,
    required this.uniqueIndex,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted && widget.focusNode.hasFocus != _hasFocus) {
      setState(() {
        _hasFocus = widget.focusNode.hasFocus;
      });
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
        widget.onTap();
        return KeyEventResult.handled;
      }
      if (widget.isFirst && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        return KeyEventResult.handled;
      }
      if (widget.isLast && event.logicalKey == LogicalKeyboardKey.arrowRight) {
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final focusColor = widget.focusColors[widget.uniqueIndex % widget.focusColors.length];

    return Focus(
      focusNode: widget.focusNode,
      onKey: _handleKeyEvent,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: bannerwdt ,
          margin: const EdgeInsets.only(right: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: _hasFocus
                        ? Border.all(color: focusColor, width: 3)
                        : Border.all(color: Colors.transparent, width: 3),
                    boxShadow: _hasFocus
                        ? [BoxShadow(color: focusColor.withOpacity(0.5), blurRadius: 12, spreadRadius: 1)]
                        : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildBannerImage(),
                        if (widget.movie.contentType == 2)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ProfessionalColors.accentPurple.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: const Text(
                                'Web Series',
                                style: TextStyle(
                                  color: ProfessionalColors.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        if (_hasFocus)
                          Positioned (
                            left: 5,
                            top: 5,
                            child: Container(
                              color: Colors.black.withOpacity(0.4),
                              child: Icon(Icons.play_circle_filled_outlined, color: focusColor, size: 40),
                            ),
                          ),
                        Positioned(
                          top: 5, right: 5,
                          child: CircleAvatar(
                            radius: 12, backgroundImage: NetworkImage(widget.logoUrl), backgroundColor: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 2.0, right: 2.0),
                child: Text(
                  widget.movie.name,
                  style:  TextStyle(color: _hasFocus ? focusColor : ProfessionalColors.textSecondary, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerImage() {
    return displayImage(
      widget.movie.banner ?? '',
      fit: BoxFit.cover,
    );
  }
}

class ViewAllCard extends StatefulWidget {
  final FocusNode focusNode;
  final List<Color> focusColors;
  final int uniqueIndex;
  final VoidCallback onTap;

  const ViewAllCard({
    super.key,
    required this.focusNode,
    required this.focusColors,
    required this.uniqueIndex,
    required this.onTap,
  });

  @override
  State<ViewAllCard> createState() => _ViewAllCardState();
}

class _ViewAllCardState extends State<ViewAllCard> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted && widget.focusNode.hasFocus != _hasFocus) {
      setState(() {
        _hasFocus = widget.focusNode.hasFocus;
      });
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
        widget.onTap();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final focusColor = widget.focusColors[widget.uniqueIndex % widget.focusColors.length];
    
    return Focus(
      focusNode: widget.focusNode,
      onKey: _handleKeyEvent,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: bannerwdt,
          margin: const EdgeInsets.only(right: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: _hasFocus
                ? Border.all(color: focusColor, width: 3)
                : Border.all(color: Colors.transparent, width: 3),
            boxShadow: _hasFocus
                ? [BoxShadow(color: ProfessionalColors.focusGlow.withOpacity(0.7), blurRadius: 12, spreadRadius: 1)]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              color: ProfessionalColors.cardDark,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward, color: _hasFocus ? focusColor : Colors.white70, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      "View All",
                      style: TextStyle(color: _hasFocus ? focusColor : Colors.white70, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GenreGridScreen extends StatefulWidget {
  final String genre;
  final String tvChannelId;
  final String logoUrl;

  const GenreGridScreen({
    super.key,
    required this.genre,
    required this.tvChannelId,
    required this.logoUrl,
  });

  @override
  State<GenreGridScreen> createState() => _GenreGridScreenState();
}

class _GenreGridScreenState extends State<GenreGridScreen> {
  bool _isLoading = true;
  String? _error;
  List<Movie> _movies = [];
  List<FocusNode> _focusNodes = [];
  List<GlobalKey> _cardKeys = [];
  bool _isVideoLoading = false;
  
  String _focusedMovieName = '';

  final List<Color> _focusColors = [
    ProfessionalColors.accentBlue, ProfessionalColors.accentPurple, ProfessionalColors.accentGreen,
    ProfessionalColors.accentOrange, ProfessionalColors.accentPink, ProfessionalColors.accentRed,
  ];

  @override
  void initState() {
    super.initState();
    _focusedMovieName = widget.genre;
    _fetchGridData();
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
  
  void _onItemFocusChange(int index) {
    if (index >= 0 && index < _movies.length) {
      if (mounted) {
        setState(() {
          _focusedMovieName = _movies[index].name;
        });
      }
    }

    if (index < 0 || index >= _cardKeys.length) return;
    final context = _cardKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        alignment: 0.15,
      );
    }
  }

  Future<void> _fetchGridData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authKey = prefs.getString('auth_key') ?? '';

      final moviesResponse = await http.post(
        Uri.parse(
          'https://dashboard.cpplayers.com/api/v2/getAllContentsOfNetworkNew'),
        headers: {
          'auth-key': authKey, 'domain': 'coretechinfo.com',
          'Accept': 'application/json', 'Content-Type': 'application/json',
        },
        body: json
            .encode({"genre": widget.genre, "network_id": widget.tvChannelId}),
      );

      if (moviesResponse.statusCode == 200) {
        final movieData =
            MovieResponse.fromJson(json.decode(moviesResponse.body));
        if (movieData.status) {
          _movies = movieData.data.where((movie) => movie.status == 1).toList();
          _focusNodes = List.generate(_movies.length, (index) => FocusNode());
          _cardKeys = List.generate(_movies.length, (index) => GlobalKey());

          for (int i = 0; i < _focusNodes.length; i++) {
            _focusNodes[i].addListener(() {
              if (_focusNodes[i].hasFocus) {
                _onItemFocusChange(i);
              }
            });
          }
        }
      } else {
        throw Exception('Failed to load content for ${widget.genre}');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          if (_focusNodes.isNotEmpty) {
            _focusNodes.first.requestFocus();
          }
        });
      }
    }
  }

  Future<void> _playContent(Movie content) async {
    if (_isVideoLoading || !mounted) return;
    setState(() { _isVideoLoading = true; });
    try {
      String playableUrl = content.getPlayableUrl();

      try {
        // await HistoryService.updateUserHistory(...);
      } catch (e) { print("History update failed, but proceeding to play. Error: $e"); }

      if (content.contentType == 2) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebSeriesDetailsPage(
              id: content.id, banner: content.banner ?? '', poster: content.poster ?? '',
              logo: widget.logoUrl, name: content.name, updatedAt: content.updatedAt ?? '',
            ),
          ),
        );
        return;
      }

      if (playableUrl.isEmpty) { throw Exception('No video URL found'); }

      if (!mounted) return;

      if (content.sourceType == 'YoutubeLive' ||
          (content.youtubeTrailer != null &&
              content.youtubeTrailer!.isNotEmpty)) {
        final deviceInfo = context.read<DeviceInfoProvider>();
        if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      YoutubeWebviewPlayer(videoUrl: playableUrl, name: content.name)));
        } else {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CustomYoutubePlayer(
                      videoData: VideoData(
                        id: content.id.toString(), title: content.name, youtubeUrl: playableUrl,
                        thumbnail: content.poster ?? content.banner ?? '',
                        description: content.description ?? '',
                      ),
                      playlist: [],
                    )));
        }
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScreen(
              videoUrl: playableUrl, bannerImageUrl: content.poster ?? content.banner ?? '',
              videoId: content.id, name: content.name, updatedAt: content.updatedAt ?? '',
              source: 'isVod', channelList: [], liveStatus: false,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isVideoLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [ProfessionalColors.primaryDark, Color(0xFF06080F)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverPadding(padding: EdgeInsets.only(top: 100.0)),
              _isLoading
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                : _error != null
                  ? SliverFillRemaining(child: Center(child: Text('Error: $_error')))
                  : _buildContentGrid(),
            ]
          ),
            Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildBeautifulAppBar(),
          ),
          if (_isVideoLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )),
            ),
        ],
      ),
    );
  }

  Widget _buildBeautifulAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ProfessionalColors.primaryDark.withOpacity(0.95),
            ProfessionalColors.surfaceDark.withOpacity(0.9),
            ProfessionalColors.surfaceDark.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: ProfessionalColors.accentBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                right: 30,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          ProfessionalColors.accentBlue.withOpacity(0.3),
                          ProfessionalColors.accentPurple.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // MODIFIED: Replaced Text with GradientText for the genre title in grid view
                  GradientText(
                    widget.genre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    gradient: const LinearGradient(colors: [
                      ProfessionalColors.accentPink,
                      ProfessionalColors.accentPurple,
                      ProfessionalColors.accentBlue,
                    ]),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      _focusedMovieName,
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: ProfessionalColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                        Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.logoUrl),
                      radius: 20,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
        ),
      ),
    );
  }


  Widget _buildContentGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(30.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 1.5,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final movie = _movies[index];
            return MovieCard(
              key: _cardKeys[index],
              movie: movie,
              logoUrl: widget.logoUrl,
              focusNode: _focusNodes[index],
              focusColors: _focusColors,
              uniqueIndex: index,
              onTap: () => _playContent(movie),
            );
          },
          childCount: _movies.length,
        ),
      ),
    );
  }
}

// ==========================================================
// NEW WIDGET: A reusable widget to display text with a gradient fill.
// ==========================================================
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

// ==========================================================
// Helper functions (displayImage etc.) - NO CHANGES NEEDED
// ==========================================================
Uint8List _getImageFromBase64String(String base64String) {
  return base64Decode(base64String.split(',').last);
}

Widget displayImage(
  String imageUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.fill,
}) {
  if (imageUrl.isEmpty || imageUrl == 'localImage') {
    return _buildErrorWidget(width, height);
  }
  if (imageUrl.contains('localhost')) {
    return _buildErrorWidget(width, height);
  }
  if (imageUrl.startsWith('data:image')) {
    try {
      Uint8List imageBytes = _getImageFromBase64String(imageUrl);
      return Image.memory(
        imageBytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget(width, height);
        },
      );
    } catch (e) {
      return _buildErrorWidget(width, height);
    }
  } else if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
    if (imageUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) {
          return _buildLoadingWidget(width, height);
        },
      );
    } else {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        headers: const {
          'User-Agent': 'Flutter App',
        },
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return _buildLoadingWidget(width, height);
        },
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return _buildErrorWidget(width, height);
        },
      );
    }
  } else {
    return _buildErrorWidget(width, height);
  }
}

Widget _buildErrorWidget(double? width, double? height) {
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
      Icons.broken_image,
      color: Colors.white,
      size: 24,
    ),
  );
}

Widget _buildLoadingWidget(double? width, double? height) {
  return SizedBox(
    width: width,
    height: height,
    child: const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    ),
  );
}