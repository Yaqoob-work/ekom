import 'dart:async';
import 'dart:convert';
import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/video_widget/custom_video_player.dart';
import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
import 'package:provider/provider.dart';

enum NavigationMode {
  seasons,
  episodes,
}

// ==========================================
// NEW DATA MODELS FOR KID CHANNELS
// ==========================================

class KidShowSeasonModel {
  final int id;
  final String seasonName;
  final int seasonOrder;
  final int showId;
  final String? banner;
  final int status;

  KidShowSeasonModel({
    required this.id,
    required this.seasonName,
    required this.seasonOrder,
    required this.showId,
    this.banner,
    required this.status,
  });

  factory KidShowSeasonModel.fromJson(Map<String, dynamic> json) {
    return KidShowSeasonModel(
      id: json['id'] ?? 0,
      seasonName: json['season_name'] ?? '',
      seasonOrder: json['season_order'] ?? 0,
      showId: json['show_id'] ?? 0,
      banner: json['banner'],
      status: json['status'] ?? 1,
    );
  }
}

class KidShowEpisodeModel {
  final int id;
  final String episodeName;
  final String episodeImage;
  final String episodeDescription;
  final int episodeOrder;
  final int seasonId;
  final String source;
  final String url;
  final int status;

  KidShowEpisodeModel({
    required this.id,
    required this.episodeName,
    required this.episodeImage,
    required this.episodeDescription,
    required this.episodeOrder,
    required this.seasonId,
    required this.source,
    required this.url,
    required this.status,
  });

  factory KidShowEpisodeModel.fromJson(Map<String, dynamic> json) {
    return KidShowEpisodeModel(
      id: json['id'] ?? 0,
      episodeName: json['Episoade_Name'] ?? '',
      episodeImage: json['episoade_image'] ?? '',
      episodeDescription: json['episoade_description'] ?? '',
      episodeOrder: json['episoade_order'] ?? 0,
      seasonId: json['season_id'] ?? 0,
      source: json['source'] ?? 'youtube',
      url: json['url'] ?? '',
      status: json['status'] ?? 1,
    );
  }
}

// ==========================================
// MAIN PAGE WIDGET
// ==========================================

class KidChannelsDetailsPage extends StatefulWidget {
  final int id;
  final String banner;
  final String poster;
  final String name;

  const KidChannelsDetailsPage({
    Key? key,
    required this.id,
    required this.banner,
    required this.poster,
    required this.name,
  }) : super(key: key);

  @override
  _KidChannelsDetailsPageState createState() => _KidChannelsDetailsPageState();
}

class _KidChannelsDetailsPageState extends State<KidChannelsDetailsPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _seasonsScrollController = ScrollController();
  final FocusNode _mainFocusNode = FocusNode();

  // Data structures
  List<KidShowSeasonModel> _seasons = [];
  Map<int, List<KidShowEpisodeModel>> _episodesMap = {};

  int _selectedSeasonIndex = 0;
  int _selectedEpisodeIndex = 0;

  NavigationMode _currentMode = NavigationMode.seasons;

  final Map<int, FocusNode> _seasonsFocusNodes = {};
  final Map<String, FocusNode> _episodeFocusNodes = {};

  String _errorMessage = "";

  // Loading states
  bool _isLoading = true;
  bool _isProcessing = false;
  bool _isLoadingEpisodes = false;

  // Animation Controllers
  late AnimationController _navigationModeController;
  late AnimationController _pageTransitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    SecureUrlService.refreshSettings();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _initializePage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _seasonsScrollController.dispose();
    _mainFocusNode.dispose();
    _seasonsFocusNodes.values.forEach((node) => node.dispose());
    _episodeFocusNodes.values.forEach((node) => node.dispose());
    _navigationModeController.dispose();
    _pageTransitionController.dispose();
    super.dispose();
  }

  // Filter methods for active content
  List<KidShowSeasonModel> _filterActiveSeasons(
      List<KidShowSeasonModel> seasons) {
    return seasons.where((season) => season.status == 1).toList();
  }

  List<KidShowEpisodeModel> _filterActiveEpisodes(
      List<KidShowEpisodeModel> episodes) {
    return episodes.where((episode) => episode.status == 1).toList();
  }

  Future<void> _initializePage() async {
    print('🚀 Initializing Kids Page for show ${widget.id}');
    await _fetchSeasonsFromAPI();
  }

  // Fetch seasons directly from API (No Cache)
  Future<void> _fetchSeasonsFromAPI() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      String authKey = SessionManager.authKey;
      var url =
          Uri.parse(SessionManager.baseUrl + 'getKidsShowSeasons/${widget.id}');

      final response = await https.get(url, headers: {
        'auth-key': authKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'domain': SessionManager.savedDomain,
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();
        if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
          final List<dynamic> data = jsonDecode(responseBody);
          final seasons = data
              .map((season) => KidShowSeasonModel.fromJson(season))
              .toList();

          final activeSeasons = _filterActiveSeasons(seasons);

          setState(() {
            _seasons = activeSeasons;
            _isLoading = false;
          });

          // Create focus nodes
          _seasonsFocusNodes.clear();
          for (int i = 0; i < _seasons.length; i++) {
            _seasonsFocusNodes[i] = FocusNode();
          }

          if (_seasons.isNotEmpty) {
            _setNavigationMode(NavigationMode.seasons);
            _pageTransitionController.forward();
            // Automatically fetch episodes for first season
            await _fetchEpisodes(_seasons[0].id);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _seasonsFocusNodes[0]?.requestFocus();
              }
            });
          }
        } else {
          throw Exception('Invalid JSON format');
        }
      } else {
        throw Exception('Failed to load seasons (${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  // Fetch episodes directly from API (No Cache)
  Future<void> _fetchEpisodes(int seasonId) async {
    // Check if already loaded in memory (temporary map)
    if (_episodesMap.containsKey(seasonId)) {
      setState(() {
        _selectedSeasonIndex =
            _seasons.indexWhere((season) => season.id == seasonId);
        _selectedEpisodeIndex = 0;
      });
      _setNavigationMode(NavigationMode.episodes);
      return;
    }

    setState(() {
      _isLoadingEpisodes = true;
    });

    try {
      String authKey = SessionManager.authKey;
      // Note: Assuming the endpoint structure is similar, adjust if needed
      var url = Uri.parse(
          SessionManager.baseUrl + 'getKidsShowSeasonsEpisodes/$seasonId');

      final response = await https.get(url, headers: {
        'auth-key': authKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'domain': SessionManager.savedDomain,
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();
        if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
          final List<dynamic> data = jsonDecode(responseBody);
          final episodes =
              data.map((e) => KidShowEpisodeModel.fromJson(e)).toList();
          final activeEpisodes = _filterActiveEpisodes(episodes);

          // Create focus nodes
          for (var episode in activeEpisodes) {
            _episodeFocusNodes[episode.id.toString()] = FocusNode();
          }

          setState(() {
            _episodesMap[seasonId] = activeEpisodes;
            _selectedSeasonIndex = _seasons.indexWhere((s) => s.id == seasonId);
            _selectedEpisodeIndex = 0;
            _isLoadingEpisodes = false;
          });

          _setNavigationMode(NavigationMode.episodes);
        }
      } else {
        throw Exception('Failed to load episodes for season $seasonId');
      }
    } catch (e) {
      setState(() {
        _isLoadingEpisodes = false;
        _errorMessage = "Error loading episodes: ${e.toString()}";
      });
    }
  }

  Future<void> _playEpisode(KidShowEpisodeModel episode) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      print('Updating user history for: ${episode.episodeName}');
      int? currentUserId = SessionManager.userId;

      await HistoryService.updateUserHistory(
        userId: currentUserId!,
        contentType: 4,
        eventId: episode.id,
        eventTitle: episode.episodeName,
        url: episode.url,
        categoryId: 0,
      );
    } catch (e) {
      print("History update failed, but proceeding to play. Error: $e");
    }

    try {
      if (mounted) {
        String rawUrl = episode.url;
        print('rawurl: $rawUrl');
        String playableUrl = await SecureUrlService.getSecureUrl(rawUrl);
        if (episode.source.toLowerCase() == 'youtube') {
          final deviceInfo = context.read<DeviceInfoProvider>();

          if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => YoutubeWebviewPlayer(
                  videoUrl: playableUrl,
                  name: episode.episodeName,
                ),
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomYoutubePlayer(
                  videoData: VideoData(
                    id: playableUrl,
                    title: episode.episodeName,
                    youtubeUrl: playableUrl,
                    thumbnail: episode.episodeImage,
                    description: episode.episodeDescription,
                  ),
                  playlist: [
                    VideoData(
                      id: playableUrl,
                      title: episode.episodeName,
                      youtubeUrl: playableUrl,
                      thumbnail: episode.episodeImage,
                      description: episode.episodeDescription,
                    ),
                  ],
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
                bannerImageUrl: episode.episodeImage,
                channelList: [],
                videoId: episode.id,
                name: episode.episodeName,
                liveStatus: false,
                updatedAt: '',
                source: 'isKidsShow',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error playing video'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // Animation Initialization
  void _initializeAnimations() {
    _navigationModeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _setNavigationMode(NavigationMode mode) {
    setState(() {
      _currentMode = mode;
    });

    if (mode == NavigationMode.seasons) {
      _navigationModeController.reverse();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
      });
    } else {
      _navigationModeController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentEpisodes.isNotEmpty) {
          _episodeFocusNodes[
                  _currentEpisodes[_selectedEpisodeIndex].id.toString()]
              ?.requestFocus();
        }
      });
    }
  }

  // Navigation Logic
  void _handleKeyEvent(RawKeyEvent event) {
    if (_isProcessing) return;

    if (event is RawKeyDownEvent) {
      switch (_currentMode) {
        case NavigationMode.seasons:
          _handleSeasonsNavigation(event);
          break;
        case NavigationMode.episodes:
          _handleEpisodesNavigation(event);
          break;
      }
    }
  }

  void _handleSeasonsNavigation(RawKeyEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        if (_selectedSeasonIndex < _seasons.length - 1) {
          setState(() {
            _selectedSeasonIndex++;
          });
          _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
        }
        break;

      case LogicalKeyboardKey.arrowUp:
        if (_selectedSeasonIndex > 0) {
          setState(() {
            _selectedSeasonIndex--;
          });
          _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
        }
        break;

      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.arrowRight:
        if (_seasons.isNotEmpty) {
          _selectSeason(_selectedSeasonIndex);
        }
        break;
    }
  }

  void _handleEpisodesNavigation(RawKeyEvent event) {
    final episodes = _currentEpisodes;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        if (_selectedEpisodeIndex < episodes.length - 1) {
          setState(() {
            _selectedEpisodeIndex++;
          });
          _scrollAndFocusEpisode(_selectedEpisodeIndex);
        }
        break;

      case LogicalKeyboardKey.arrowUp:
        if (_selectedEpisodeIndex > 0) {
          setState(() {
            _selectedEpisodeIndex--;
          });
          _scrollAndFocusEpisode(_selectedEpisodeIndex);
        }
        break;

      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.select:
        if (episodes.isNotEmpty) {
          _playEpisode(episodes[_selectedEpisodeIndex]);
        }
        break;

      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.escape:
        _setNavigationMode(NavigationMode.seasons);
        break;
    }
  }

  void _selectSeason(int index) {
    if (index >= 0 && index < _seasons.length) {
      setState(() {
        _selectedSeasonIndex = index;
      });
      _fetchEpisodes(_seasons[index].id);
    }
  }

  void _onSeasonTap(int index) {
    setState(() {
      _selectedSeasonIndex = index;
      _currentMode = NavigationMode.seasons;
    });
    _seasonsFocusNodes[index]?.requestFocus();
    _selectSeason(index);
  }

  void _onEpisodeTap(int index) {
    if (_currentEpisodes.isNotEmpty && index < _currentEpisodes.length) {
      setState(() {
        _selectedEpisodeIndex = index;
        _currentMode = NavigationMode.episodes;
      });
      _episodeFocusNodes[_currentEpisodes[index].id.toString()]?.requestFocus();
      _playEpisode(_currentEpisodes[index]);
    }
  }

  Future<void> _scrollAndFocusEpisode(int index) async {
    if (index < 0 || index >= _currentEpisodes.length) return;

    final context =
        _episodeFocusNodes[_currentEpisodes[index].id.toString()]?.context;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    }
  }

  List<KidShowEpisodeModel> get _currentEpisodes {
    if (_seasons.isEmpty || _selectedSeasonIndex >= _seasons.length) {
      return [];
    }
    return _episodesMap[_seasons[_selectedSeasonIndex].id] ?? [];
  }

  // ==========================================
  // UI BUILD METHODS
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: _mainFocusNode,
        autofocus: true,
        onKey: _handleKeyEvent,
        child: Stack(
          children: [
            _buildBackgroundLayer(),
            _buildMainContentWithLayout(),
            if (_isProcessing) _buildProcessingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundLayer() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            widget.banner,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Color(0xFF1a1a2e)),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContentWithLayout() {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      bottom: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) return _buildLoadingWidget();
    if (_errorMessage.isNotEmpty) return _buildErrorWidget();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildSeasonsPanel(),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: _buildEpisodesPanel(),
          ),
        ],
      ),
    );
  }

  // SEASONS PANEL
  Widget _buildSeasonsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _currentMode == NavigationMode.seasons
              ? Colors.blue.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.list_alt, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.name.toUpperCase(),
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${_seasons.length}',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _seasonsScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _seasons.length,
              itemBuilder: (context, index) => _buildSeasonItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonItem(int index) {
    final season = _seasons[index];
    final isSelected = index == _selectedSeasonIndex;
    final isFocused = _currentMode == NavigationMode.seasons && isSelected;

    return GestureDetector(
      onTap: () => _onSeasonTap(index),
      child: Focus(
        focusNode: _seasonsFocusNodes[index],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isFocused
                ? LinearGradient(colors: [
                    Colors.blue.withOpacity(0.3),
                    Colors.blue.withOpacity(0.1)
                  ])
                : isSelected
                    ? LinearGradient(colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05)
                      ])
                    : null,
            borderRadius: BorderRadius.circular(12),
            border: isFocused ? Border.all(color: Colors.blue, width: 2) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isFocused ? Colors.blue : Colors.grey[700],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    'S${season.seasonOrder}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  season.seasonName,
                  style: TextStyle(
                    color: isFocused ? Colors.blue : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // EPISODES PANEL
  Widget _buildEpisodesPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _currentMode == NavigationMode.episodes
              ? Colors.green.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.play_circle_outline, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Text('EPISODES',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${_currentEpisodes.length}',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoadingEpisodes
                ? _buildLoadingWidget()
                : _currentEpisodes.isEmpty
                    ? _buildEmptyEpisodesState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: _currentEpisodes.length,
                        itemBuilder: (context, index) =>
                            _buildEpisodeItem(index),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeItem(int index) {
    final episode = _currentEpisodes[index];
    final isSelected = index == _selectedEpisodeIndex;
    final isFocused = _currentMode == NavigationMode.episodes && isSelected;

    return GestureDetector(
      onTap: () => _onEpisodeTap(index),
      child: Focus(
        focusNode: _episodeFocusNodes[episode.id.toString()],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isFocused
                ? LinearGradient(colors: [
                    Colors.green.withOpacity(0.3),
                    Colors.green.withOpacity(0.1)
                  ])
                : isSelected
                    ? LinearGradient(colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05)
                      ])
                    : null,
            borderRadius: BorderRadius.circular(16),
            border:
                isFocused ? Border.all(color: Colors.green, width: 2) : null,
          ),
          child: Row(
            children: [
              // Thumbnail
              Container(
                margin: const EdgeInsets.all(12),
                width: 140,
                height: 90,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: episode.episodeImage,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[800], child: Icon(Icons.error)),
                  ),
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode.episodeName,
                        style: TextStyle(
                          color: isFocused ? Colors.green : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Ready label
                      if (isFocused)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'PRESS ENTER TO PLAY',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Play Icon
              if (isFocused || isSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 32),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyEpisodesState() {
    return Center(
      child:
          Text("No Episodes Available", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(child: SpinKitFadingCircle(color: Colors.blue, size: 50.0));
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error, color: Colors.red, size: 40),
          Text(_errorMessage, style: TextStyle(color: Colors.white)),
          ElevatedButton(onPressed: _initializePage, child: Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: SpinKitPulse(color: Colors.blue, size: 80),
      ),
    );
  }
}
