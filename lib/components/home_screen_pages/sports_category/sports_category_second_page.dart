import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_final_details_page.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

//==============================================================================
// 1. DATA MODEL & CACHE MANAGER
//==============================================================================

/// Manages caching of sports tournament data to reduce network calls.
class SportsTournamentCacheManager {
  static const String _cacheKeyPrefix = 'sports_tournament_cache_';

  static String _getCacheKey(int sportsChannelId) =>
      '$_cacheKeyPrefix$sportsChannelId';

  /// Saves a list of tournaments to SharedPreferences.
  static Future<void> saveToCache(
      int sportsChannelId, List<SportsTournamentModel> tournaments) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData =
          tournaments.map((tournament) => tournament.toJson()).toList();
      await prefs.setString(
          _getCacheKey(sportsChannelId), json.encode(jsonData));
      print('✅ Cache saved for sports channel $sportsChannelId');
    } catch (e) {
      print('❌ Error saving to cache: $e');
    }
  }

  /// Loads a list of tournaments from SharedPreferences.
  static Future<List<SportsTournamentModel>?> loadFromCache(
      int sportsChannelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_getCacheKey(sportsChannelId));

      if (cachedData == null) return null;

      final List<dynamic> jsonData = json.decode(cachedData);
      return jsonData
          .map((item) => SportsTournamentModel.fromJson(item))
          .toList();
    } catch (e) {
      print('❌ Error loading from cache: $e');
      return null;
    }
  }

  /// Compares two lists of tournaments to see if the data has changed.
  static bool hasDataChanged(List<SportsTournamentModel> oldList,
      List<SportsTournamentModel> newList) {
    if (oldList.length != newList.length) return true;

    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i].id != newList[i].id ||
          oldList[i].title != newList[i].title ||
          oldList[i].updatedAt != newList[i].updatedAt) {
        return true;
      }
    }
    return false;
  }
}

/// Represents a single sports tournament.
class SportsTournamentModel {
  final int id;
  final int sportsCategoryId;
  final String title;
  final String? description;
  final String? logo;
  final String? startDate;
  final String? endDate;
  final int status;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final int sportsCatOrder;

  SportsTournamentModel({
    required this.id,
    required this.sportsCategoryId,
    required this.title,
    this.description,
    this.logo,
    this.startDate,
    this.endDate,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.sportsCatOrder,
  });

  factory SportsTournamentModel.fromJson(Map<String, dynamic> json) {
    return SportsTournamentModel(
      id: json['id'] ?? 0,
      sportsCategoryId: json['sports_category_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      logo: json['logo'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      sportsCatOrder: json['sports_cat_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sports_category_id': sportsCategoryId,
      'title': title,
      'description': description,
      'logo': logo,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'sports_cat_order': sportsCatOrder,
    };
  }
}

//==============================================================================
// 2. MAIN PAGE WIDGET
//==============================================================================

class SportsCategorySecondPage extends StatefulWidget {
  final int tvChannelId;
  final String channelName;
  final String? channelLogo;

  const SportsCategorySecondPage({
    Key? key,
    required this.tvChannelId,
    required this.channelName,
    this.channelLogo,
  }) : super(key: key);

  @override
  _SportsCategorySecondPageState createState() =>
      _SportsCategorySecondPageState();
}

class _SportsCategorySecondPageState extends State<SportsCategorySecondPage>
    with TickerProviderStateMixin {
  List<SportsTournamentModel> tournamentsList = [];
  bool isLoading = true;
  bool isBackgroundRefreshing = false;
  String? errorMessage;
  int gridFocusedIndex = 0;
  final int columnsCount = 6;
  Map<int, FocusNode> gridFocusNodes = {};
  late ScrollController _scrollController;

  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late AnimationController _headerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
    _startAnimations();
    _loadDataWithCache();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    _headerController.dispose();
    _scrollController.dispose();
    for (var node in gridFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _staggerController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _headerController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _headerController, curve: Curves.easeOutCubic));
  }

  void _startAnimations() {
    _headerController.forward();
    _fadeController.forward();
  }

  Future<void> _loadDataWithCache() async {
    print(
        '🔄 Loading data with cache for sports channel ${widget.tvChannelId}');
    final cachedData =
        await SportsTournamentCacheManager.loadFromCache(widget.tvChannelId);

    if (cachedData != null && cachedData.isNotEmpty) {
      setState(() {
        tournamentsList = cachedData;
        isLoading = false;
        errorMessage = null;
      });
      _createGridFocusNodes();
      _staggerController.forward();
      print('✅ Cached data displayed instantly');
      _refreshDataInBackground();
    } else {
      fetchSportsTournaments();
    }
  }

  Future<void> fetchSportsTournaments() async {
    try {
      if (!mounted) return;
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      String authKey = SessionManager.authKey ;
      var url = Uri.parse(SessionManager.baseUrl + 'getsportTournament/${widget.tvChannelId}');

      final response = await https.get(url,
        // Uri.parse(
        //     'https://dashboard.cpplayers.com/public/api/v2/getsportTournament/${widget.tvChannelId}'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain': SessionManager.savedDomain,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final tournaments = jsonData
            .map((item) => SportsTournamentModel.fromJson(item))
            .toList();
        tournaments
            .sort((a, b) => a.sportsCatOrder.compareTo(b.sportsCatOrder));

        await SportsTournamentCacheManager.saveToCache(
            widget.tvChannelId, tournaments);

        setState(() {
          tournamentsList = tournaments;
          isLoading = false;
        });

        if (tournamentsList.isNotEmpty) {
          _createGridFocusNodes();
          _staggerController.forward();
        } else {
          setState(() {
            errorMessage = 'No tournaments found for this sports category';
          });
        }
      } else {
        throw Exception('Failed to load tournaments: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading tournaments: $e';
      });
      print('❌ Error fetching tournaments: $e');
    }
  }

  Future<void> _refreshDataInBackground() async {
    if (isBackgroundRefreshing) return;
    setState(() => isBackgroundRefreshing = true);

    try {
      String authKey = SessionManager.authKey ;
      var url = Uri.parse(SessionManager.baseUrl + 'getsportTournament/${widget.tvChannelId}');

      final response = await https.get(url,
        // Uri.parse(
        //     'https://dashboard.cpplayers.com/public/api/v2/getsportTournament/${widget.tvChannelId}'),
        headers: {'auth-key': authKey, 'domain': SessionManager.savedDomain},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final newData = jsonData
            .map((item) => SportsTournamentModel.fromJson(item))
            .toList();
        newData.sort((a, b) => a.sportsCatOrder.compareTo(b.sportsCatOrder));

        if (SportsTournamentCacheManager.hasDataChanged(
            tournamentsList, newData)) {
          print('📱 Data changed, updating UI and cache');
          await SportsTournamentCacheManager.saveToCache(
              widget.tvChannelId, newData);

          final currentFocusedIndex = gridFocusedIndex;
          setState(() => tournamentsList = newData);
          _createGridFocusNodes();

          if (currentFocusedIndex < tournamentsList.length) {
            setState(() => gridFocusedIndex = currentFocusedIndex);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              gridFocusNodes[currentFocusedIndex]?.requestFocus();
            });
          }
        } else {
          print('✅ No changes detected in background refresh');
        }
      }
    } catch (e) {
      print('❌ Background refresh failed: $e');
    } finally {
      if (mounted) {
        setState(() => isBackgroundRefreshing = false);
      }
    }
  }

  void _createGridFocusNodes() {
    for (var node in gridFocusNodes.values) {
      node.dispose();
    }
    gridFocusNodes.clear();

    for (int i = 0; i < tournamentsList.length; i++) {
      gridFocusNodes[i] = FocusNode();
      gridFocusNodes[i]!.addListener(() {
        if (gridFocusNodes[i]!.hasFocus) {
          setState(() => gridFocusedIndex = i);
          _ensureItemVisible(i);
        }
      });
    }

    if (tournamentsList.isNotEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _focusFirstGridItem());
    }
  }

  void _focusFirstGridItem() {
    if (tournamentsList.isNotEmpty && gridFocusNodes.containsKey(0)) {
      setState(() => gridFocusedIndex = 0);
      gridFocusNodes[0]?.requestFocus();
    }
  }

  Future<void> _onTournamentSelected(SportsTournamentModel tournament) async {
    HapticFeedback.mediumImpact();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentFinalDetailsPage(
          id: tournament.id,
          banner: tournament.logo ?? '',
          poster: tournament.logo ?? '',
          name: tournament.title,
          updatedAt: tournament.updatedAt ?? '',
        ),
      ),
    );
  }

  void _navigateGrid(LogicalKeyboardKey key) {
    int newIndex = gridFocusedIndex;
    final int totalItems = tournamentsList.length;
    final int currentRow = gridFocusedIndex ~/ columnsCount;
    final int currentCol = gridFocusedIndex % columnsCount;

    if (key == LogicalKeyboardKey.arrowRight) {
      if (gridFocusedIndex < totalItems - 1) newIndex++;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (gridFocusedIndex > 0) newIndex--;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      if ((currentRow + 1) * columnsCount + currentCol < totalItems) {
        newIndex += columnsCount;
      }
    } else if (key == LogicalKeyboardKey.arrowUp) {
      if (currentRow > 0) newIndex -= columnsCount;
    }

    if (newIndex != gridFocusedIndex) {
      setState(() => gridFocusedIndex = newIndex);
      gridFocusNodes[newIndex]?.requestFocus();
    }
  }

  void _ensureItemVisible(int index) {
    if (_scrollController.hasClients) {
      final int row = index ~/ columnsCount;
      final double itemHeight =
          (MediaQuery.of(context).size.width / columnsCount) / 1.5;
      final double targetOffset =
          row * (itemHeight + 15); // itemHeight + spacing
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ProfessionalColors.primaryDark,
                  ProfessionalColors.surfaceDark.withOpacity(0.8),
                  ProfessionalColors.primaryDark,
                ],
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
          if (isBackgroundRefreshing) _buildUpdatingIndicator(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const ProfessionalTournamentLoadingIndicator(
          message: 'Loading Tournaments...');
    }
    if (errorMessage != null) {
      return _buildErrorWidget();
    }
    if (tournamentsList.isEmpty) {
      return _buildEmptyWidget();
    }
    return _buildGridView();
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.channelName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            //   decoration: BoxDecoration(
            //     color: ProfessionalColors.accentGreen.withOpacity(0.2),
            //     borderRadius: BorderRadius.circular(15),
            //   ),
            //   child: Text(
            //     '${tournamentsList.length} Tournaments',
            //     style: const TextStyle(
            //       color: ProfessionalColors.accentGreen,
            //       fontSize: 12,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return Focus(
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if ([
            LogicalKeyboardKey.arrowUp,
            LogicalKeyboardKey.arrowDown,
            LogicalKeyboardKey.arrowLeft,
            LogicalKeyboardKey.arrowRight
          ].contains(event.logicalKey)) {
            _navigateGrid(event.logicalKey);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.select) {
            if (gridFocusedIndex < tournamentsList.length) {
              _onTournamentSelected(tournamentsList[gridFocusedIndex]);
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          controller: _scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.5,
          ),
          itemCount: tournamentsList.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _staggerController,
              builder: (context, child) {
                final delay = (index / tournamentsList.length) * 0.5;
                final animationValue =
                    Interval(delay, delay + 0.5, curve: Curves.easeOutCubic)
                        .transform(_staggerController.value);
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: SportsTournamentCard(
                      tournament: tournamentsList[index],
                      focusNode: gridFocusNodes[index]!,
                      onTap: () =>
                          _onTournamentSelected(tournamentsList[index]),
                      isFocused: gridFocusedIndex == index,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 40, color: ProfessionalColors.accentRed),
          const SizedBox(height: 24),
          const Text('Error Loading Tournaments',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          Text(errorMessage ?? 'Unknown error occurred',
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchSportsTournaments,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_outlined,
              size: 40, color: ProfessionalColors.accentGreen),
          const SizedBox(height: 24),
          Text('No Tournaments Found for ${widget.channelName}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Check back later for new tournaments',
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildUpdatingIndicator() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ProfessionalColors.accentGreen.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ),
            SizedBox(width: 6),
            Text('Updating',
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

//==============================================================================
// 3. TOURNAMENT CARD WIDGET
//==============================================================================

class SportsTournamentCard extends StatefulWidget {
  final SportsTournamentModel tournament;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final bool isFocused;

  const SportsTournamentCard({
    Key? key,
    required this.tournament,
    required this.focusNode,
    required this.onTap,
    required this.isFocused,
  }) : super(key: key);

  @override
  _SportsTournamentCardState createState() => _SportsTournamentCardState();
}

class _SportsTournamentCardState extends State<SportsTournamentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  Color _dominantColor = ProfessionalColors.accentGreen;

  @override
  void initState() {
    super.initState();
    _hoverController =
        AnimationController(duration: AnimationTiming.medium, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));

    widget.focusNode.addListener(_handleFocusChange);
    // Initialize state based on initial focus
    _handleFocusChange();
  }

  @override
  void didUpdateWidget(SportsTournamentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFocused != oldWidget.isFocused) {
      _handleFocusChange();
    }
  }

  void _handleFocusChange() {
    if (widget.isFocused) {
      _hoverController.forward();
      _generateDominantColor();
    } else {
      _hoverController.reverse();
    }
  }

  void _generateDominantColor() {
    final colors = ProfessionalColors.gradientColors;
    _dominantColor = colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  if (widget.isFocused)
                    BoxShadow(
                      color: _dominantColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildTournamentImage(),
                    _buildGradientOverlay(),
                    _buildTournamentInfo(),
                    if (widget.isFocused) _buildFocusBorder(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTournamentImage() {
    final logoUrl = widget.tournament.logo;
    return (logoUrl != null && logoUrl.isNotEmpty)
        ? Image.network(
            logoUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : _buildImagePlaceholder(),
            errorBuilder: (context, error, stack) => _buildImagePlaceholder(),
          )
        : _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: ProfessionalColors.cardDark,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_outlined, size: 40, color: Colors.white38),
          SizedBox(height: 8),
          Text(
            'TOURNAMENT',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusBorder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 3, color: _dominantColor),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentInfo() {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: Text(
        widget.tournament.title.toUpperCase(),
        style: TextStyle(
          color: widget.isFocused ? _dominantColor : Colors.white,
          fontSize: widget.isFocused ? 13 : 12,
          fontWeight: FontWeight.w600,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// A custom loading indicator widget.
class ProfessionalTournamentLoadingIndicator extends StatelessWidget {
  final String message;
  const ProfessionalTournamentLoadingIndicator(
      {Key? key, this.message = 'Loading...'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
              color: ProfessionalColors.accentGreen),
          const SizedBox(height: 32),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please wait...',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Defines the color palette for the app.
class ProfessionalColors {
  static const Color primaryDark = Color(0xFF0A0E1A);
  static const Color surfaceDark = Color(0xFF1A1D29);
  static const Color cardDark = Color(0xFF252837);
  static const Color accentGreen = Color(0xFF00D9FF);
  static const Color accentBlue = Color(0xFF0099CC);
  static const Color accentRed = Color(0xFFFF5555);

  static const List<Color> gradientColors = [
    accentGreen,
    accentBlue,
    Color(0xFF00BFA5),
    Color(0xFF7C4DFF),
  ];
}

/// Defines standard animation durations.
class AnimationTiming {
  static const Duration medium = Duration(milliseconds: 300);
}
