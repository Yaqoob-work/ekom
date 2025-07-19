import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'dart:math' as math;
import 'package:mobi_tv_entertainment/home_screen_pages/tv_show/tv_show_second_page.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/tvshows_screen/tvshows_details_page.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

// ✅ Professional Color Palette (same as Movies & WebSeries)
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

  static List<Color> gradientColors = [
    accentBlue,
    accentPurple,
    accentGreen,
    accentRed,
    accentOrange,
    accentPink,
  ];
}

// ✅ Professional Animation Durations
class AnimationTiming {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration focus = Duration(milliseconds: 300);
  static const Duration scroll = Duration(milliseconds: 800);
}

// ✅ TV Show Model
class TVShowModel {
  final int id;
  final String name;
  final String? description;
  // final String? poster;
  final String? logo;
  final String? releaseDate;
  final String? genres;
  final String? rating;
  final String? language;

  TVShowModel({
    required this.id,
    required this.name,
    this.description,
    // this.poster,
    this.logo,
    this.releaseDate,
    this.genres,
    this.rating,
    this.language,
  });

  factory TVShowModel.fromJson(Map<String, dynamic> json) {
    return TVShowModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      // poster: json['poster'],
      logo: json['logo'],
      releaseDate: json['release_date'],
      genres: json['genres'],
      rating: json['rating'],
      language: json['language'],
    );
  }
}

// ✅ Professional TV Show Card
class ProfessionalTVShowCard extends StatefulWidget {
  final TVShowModel tvShow;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;
  final int index;
  final String categoryTitle;

  const ProfessionalTVShowCard({
    Key? key,
    required this.tvShow,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalTVShowCardState createState() => _ProfessionalTVShowCardState();
}

class _ProfessionalTVShowCardState extends State<ProfessionalTVShowCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  Color _dominantColor = ProfessionalColors.accentGreen;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: AnimationTiming.medium,
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });

    if (_isFocused) {
      _scaleController.forward();
      _glowController.forward();
      _generateDominantColor();
      widget.onColorChange(_dominantColor);
      HapticFeedback.lightImpact();
    } else {
      _scaleController.reverse();
      _glowController.reverse();
    }
  }

  void _generateDominantColor() {
    final colors = ProfessionalColors.gradientColors;
    _dominantColor = colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: screenWidth * 0.19,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfessionalPoster(screenWidth, screenHeight),
                _buildProfessionalTitle(screenWidth),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
    final posterHeight = _isFocused ? screenHeight * 0.28 : screenHeight * 0.22;

    return Container(
      height: posterHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (_isFocused) ...[
            BoxShadow(
              color: _dominantColor.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 3,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: _dominantColor.withOpacity(0.2),
              blurRadius: 45,
              spreadRadius: 6,
              offset: const Offset(0, 15),
            ),
          ] else ...[
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            _buildTVShowImage(screenWidth, posterHeight),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            _buildGenreBadge(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTVShowImage(double screenWidth, double posterHeight) {
    return Container(
      width: double.infinity,
      height: posterHeight,
      child: widget.tvShow.logo != null && widget.tvShow.logo!.isNotEmpty
          ? Image.network(
              widget.tvShow.logo!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder(posterHeight);
              },
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(posterHeight),
            )
          : _buildImagePlaceholder(posterHeight),
    );
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalColors.cardDark,
            ProfessionalColors.surfaceDark,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.live_tv_rounded,
            size: height * 0.25,
            color: ProfessionalColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            'TV SHOW',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ProfessionalColors.accentGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: ProfessionalColors.accentGreen,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusBorder() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 3,
            color: _dominantColor,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
                end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
                colors: [
                  Colors.transparent,
                  _dominantColor.withOpacity(0.15),
                  Colors.transparent,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenreBadge() {
    String genre = 'SHOW';
    Color badgeColor = ProfessionalColors.accentGreen;

    if (widget.tvShow.genres != null) {
      if (widget.tvShow.genres!.toLowerCase().contains('news')) {
        genre = 'NEWS';
        badgeColor = ProfessionalColors.accentRed;
      } else if (widget.tvShow.genres!.toLowerCase().contains('sports')) {
        genre = 'SPORTS';
        badgeColor = ProfessionalColors.accentOrange;
      } else if (widget.tvShow.genres!.toLowerCase().contains('entertainment')) {
        genre = 'ENTERTAINMENT';
        badgeColor = ProfessionalColors.accentPink;
      } else if (widget.tvShow.genres!.toLowerCase().contains('documentary')) {
        genre = 'DOCUMENTARY';
        badgeColor = ProfessionalColors.accentBlue;
      }
    }

    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          genre,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHoverOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              _dominantColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: _dominantColor,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalTitle(double screenWidth) {
    final tvShowName = widget.tvShow.name.toUpperCase();

    return Container(
      width: screenWidth * 0.18,
      child: AnimatedDefaultTextStyle(
        duration: AnimationTiming.medium,
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11,
          fontWeight: FontWeight.w600,
          color: _isFocused ? _dominantColor : ProfessionalColors.textPrimary,
          letterSpacing: 0.5,
          shadows: _isFocused
              ? [
                  Shadow(
                    color: _dominantColor.withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          tvShowName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ✅ Professional View All Button for TV Shows
class ProfessionalTVShowViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int totalItems;
  final String itemType;

  const ProfessionalTVShowViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
    required this.totalItems,
    this.itemType = 'TV SHOWS',
  }) : super(key: key);

  @override
  _ProfessionalTVShowViewAllButtonState createState() =>
      _ProfessionalTVShowViewAllButtonState();
}

class _ProfessionalTVShowViewAllButtonState extends State<ProfessionalTVShowViewAllButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  bool _isFocused = false;
  Color _currentColor = ProfessionalColors.accentGreen;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotateController);

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
      if (_isFocused) {
        _currentColor = ProfessionalColors.gradientColors[
            math.Random().nextInt(ProfessionalColors.gradientColors.length)];
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.19,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _isFocused ? _pulseAnimation : _rotateAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isFocused ? _pulseAnimation.value : 1.0,
                child: Transform.rotate(
                  angle: _isFocused ? 0 : _rotateAnimation.value * 2 * math.pi,
                  child: Container(
                    height: _isFocused ? screenHeight * 0.28 : screenHeight * 0.22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isFocused
                            ? [
                                _currentColor,
                                _currentColor.withOpacity(0.7),
                              ]
                            : [
                                ProfessionalColors.cardDark,
                                ProfessionalColors.surfaceDark,
                              ],
                      ),
                      boxShadow: [
                        if (_isFocused) ...[
                          BoxShadow(
                            color: _currentColor.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 3,
                            offset: const Offset(0, 8),
                          ),
                        ] else ...[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ],
                    ),
                    child: _buildViewAllContent(),
                  ),
                ),
              );
            },
          ),
          _buildViewAllTitle(),
        ],
      ),
    );
  }

  Widget _buildViewAllContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: _isFocused
            ? Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.live_tv_rounded,
                  size: _isFocused ? 45 : 35,
                  color: Colors.white,
                ),
                Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _isFocused ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.totalItems}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewAllTitle() {
    return AnimatedDefaultTextStyle(
      duration: AnimationTiming.medium,
      style: TextStyle(
        fontSize: _isFocused ? 13 : 11,
        fontWeight: FontWeight.w600,
        color: _isFocused ? _currentColor : ProfessionalColors.textPrimary,
        letterSpacing: 0.5,
        shadows: _isFocused
            ? [
                Shadow(
                  color: _currentColor.withOpacity(0.6),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Text(
        'ALL ${widget.itemType}',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ✅ Professional Loading Indicator for TV Shows
class ProfessionalTVShowLoadingIndicator extends StatefulWidget {
  final String message;

  const ProfessionalTVShowLoadingIndicator({
    Key? key,
    this.message = 'Loading TV Shows...',
  }) : super(key: key);

  @override
  _ProfessionalTVShowLoadingIndicatorState createState() =>
      _ProfessionalTVShowLoadingIndicatorState();
}

class _ProfessionalTVShowLoadingIndicatorState extends State<ProfessionalTVShowLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      ProfessionalColors.accentGreen,
                      ProfessionalColors.accentBlue,
                      ProfessionalColors.accentOrange,
                      ProfessionalColors.accentGreen,
                    ],
                    stops: [0.0, 0.3, 0.7, 1.0],
                    transform: GradientRotation(_animation.value * 2 * math.pi),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ProfessionalColors.primaryDark,
                  ),
                  child: const Icon(
                    Icons.live_tv_rounded,
                    color: ProfessionalColors.textPrimary,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            widget.message,
            style: const TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 200,
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: ProfessionalColors.surfaceDark,
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _animation.value,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    ProfessionalColors.accentGreen,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Main Professional TV Shows Widget
class ProfessionalTVShowsHorizontalList extends StatefulWidget {
  @override
  _ProfessionalTVShowsHorizontalListState createState() =>
      _ProfessionalTVShowsHorizontalListState();
}

class _ProfessionalTVShowsHorizontalListState
    extends State<ProfessionalTVShowsHorizontalList>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  List<TVShowModel> tvShowsList = [];
  bool isLoading = true;
  int focusedIndex = -1;
  final int maxHorizontalItems = 7;
  Color _currentAccentColor = ProfessionalColors.accentGreen;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  Map<String, FocusNode> tvshowsFocusNodes = {};
  FocusNode? _viewAllFocusNode;
  FocusNode? _firstTVShowFocusNode;
  bool _hasReceivedFocusFromWebSeries = false;

  late ScrollController _scrollController;
  final double _itemWidth = 156.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
    _initializeFocusNodes();
    fetchTVShows();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _listFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeFocusNodes() {
    _viewAllFocusNode = FocusNode();
    print('✅ TV Shows focus nodes initialized');
  }

  // ✅ Updated scroll function using Scrollable.ensureVisible
  void _scrollToPosition(int index) {
    if (index < tvShowsList.length && index < maxHorizontalItems) {
      String tvShowId = tvShowsList[index].id.toString();
      if (tvshowsFocusNodes.containsKey(tvShowId)) {
        final focusNode = tvshowsFocusNodes[tvShowId]!;
        
        Scrollable.ensureVisible(
          focusNode.context!,
          duration: AnimationTiming.scroll,
          curve: Curves.easeInOutCubic,
          alignment: 0.03,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        );
        
        print('🎯 TV Shows: Scrollable.ensureVisible for index $index: ${tvShowsList[index].name}');
      }
    } else if (index == maxHorizontalItems && _viewAllFocusNode != null) {
      Scrollable.ensureVisible(
        _viewAllFocusNode!.context!,
        duration: AnimationTiming.scroll,
        curve: Curves.easeInOutCubic,
        alignment: 0.2,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
      
      print('🎯 TV Shows: Scrollable.ensureVisible for ViewAll button');
    }
  }

  // ✅ Setup TV Shows Focus Provider
  void _setupTVShowsFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && tvShowsList.isNotEmpty) {
        try {
          final focusProvider = Provider.of<FocusProvider>(context, listen: false);

          final firstTVShowId = tvShowsList[0].id.toString();

          if (!tvshowsFocusNodes.containsKey(firstTVShowId)) {
            tvshowsFocusNodes[firstTVShowId] = FocusNode();
            print('✅ Created focus node for first TV show: $firstTVShowId');
          }

          _firstTVShowFocusNode = tvshowsFocusNodes[firstTVShowId];

          _firstTVShowFocusNode!.addListener(() {
            if (_firstTVShowFocusNode!.hasFocus && !_hasReceivedFocusFromWebSeries) {
              _hasReceivedFocusFromWebSeries = true;
              setState(() {
                focusedIndex = 0;
              });
              _scrollToPosition(0);
              print('✅ TV Shows received focus from webseries and scrolled');
            }
          });

          // ✅ TV Shows का first focus node register करें
          focusProvider.setFirstTVShowsFocusNode(_firstTVShowFocusNode!);

          print('✅ TV Shows first focus node registered: ${tvShowsList[0].name}');

        } catch (e) {
          print('❌ TV Shows focus provider setup failed: $e');
        }
      }
    });
  }

  Future<void> fetchTVShows() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String authKey = prefs.getString('auth_key') ?? '';

      final response = await https.get(
        Uri.parse('https://acomtv.coretechinfo.com/public/api/getTvChannels'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          tvShowsList = jsonData.map((item) => TVShowModel.fromJson(item)).toList();
          isLoading = false;
        });

        if (tvShowsList.isNotEmpty) {
          _createFocusNodesForItems();
          _setupTVShowsFocusProvider();
          
          // Start animations after data loads
          _headerAnimationController.forward();
          _listAnimationController.forward();
        }
      } else {
        throw Exception('Failed to load TV shows');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching TV shows: $e');
    }
  }

  void _createFocusNodesForItems() {
    for (var node in tvshowsFocusNodes.values) {
      try {
        node.removeListener(() {});
        node.dispose();
      } catch (e) {}
    }
    tvshowsFocusNodes.clear();

    for (int i = 0; i < tvShowsList.length && i < maxHorizontalItems; i++) {
      String tvShowId = tvShowsList[i].id.toString();
      if (!tvshowsFocusNodes.containsKey(tvShowId)) {
        tvshowsFocusNodes[tvShowId] = FocusNode();

        tvshowsFocusNodes[tvShowId]!.addListener(() {
          if (mounted && tvshowsFocusNodes[tvShowId]!.hasFocus) {
            setState(() {
              focusedIndex = i;
              _hasReceivedFocusFromWebSeries = true;
            });
            _scrollToPosition(i);
            print('✅ TV Show $i focused and scrolled: ${tvShowsList[i].name}');
          }
        });
      }
    }
    print('✅ Created ${tvshowsFocusNodes.length} TV show focus nodes with auto-scroll');
  }

  // void _navigateToTVShowDetails(TVShowModel tvShow) {
  //   print('🎬 Navigating to TV Show Details: ${tvShow.name}');

  //   // Navigator.push(
  //   //   context,
  //   //   MaterialPageRoute(
  //   //     builder: (context) => TVShowDetailsPage(
  //   //       id: tvShow.id,
  //   //       banner: tvShow.banner ?? tvShow.poster ?? '',
  //   //       poster: tvShow.poster ?? tvShow.banner ?? '',
  //   //       name: tvShow.name,
  //   //     ),
  //   //   ),
  //   // ).then((_) {
  //   //   print('🔙 Returned from TV Show Details');
  //   //   Future.delayed(Duration(milliseconds: 300), () {
  //   //     if (mounted) {
  //   //       int currentIndex = tvShowsList.indexWhere((ts) => ts.id == tvShow.id);
  //   //       if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
  //   //         String tvShowId = tvShow.id.toString();
  //   //         if (tvshowsFocusNodes.containsKey(tvShowId)) {
  //   //           setState(() {
  //   //             focusedIndex = currentIndex;
  //   //             _hasReceivedFocusFromWebSeries = true;
  //   //           });
  //   //           tvshowsFocusNodes[tvShowId]!.requestFocus();
  //   //           _scrollToPosition(currentIndex);
  //   //           print('✅ Restored focus to ${tvShow.name}');
  //   //         }
  //   //       }
  //   //     }
  //   //   });
  //   // });
  // }



  
// ✅ Updated _navigateToTVShowDetails method for your main TV Shows widget
void _navigateToTVShowDetails(TVShowModel tvShow) {
  print('🎬 Navigating to TV Show Details: ${tvShow.name}');

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TVShowDetailsPage(
        tvChannelId: tvShow.id, // TV Show का ID pass करें
        channelName: tvShow.name,
        channelLogo: tvShow.logo,
      ),
    ),
  ).then((_) {
    print('🔙 Returned from TV Show Details');
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        int currentIndex = tvShowsList.indexWhere((ts) => ts.id == tvShow.id);
        if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
          String tvShowId = tvShow.id.toString();
          if (tvshowsFocusNodes.containsKey(tvShowId)) {
            setState(() {
              focusedIndex = currentIndex;
              _hasReceivedFocusFromWebSeries = true;
            });
            tvshowsFocusNodes[tvShowId]!.requestFocus();
            _scrollToPosition(currentIndex);
            print('✅ Restored focus to ${tvShow.name}');
          }
        }
      }
    });
  });
}

  void _navigateToGridPage() {
    print('🎬 Navigating to TV Shows Grid Page...');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalTVShowsGridPage(
          tvShowsList: tvShowsList,
          title: 'TV Shows',
        ),
      ),
    ).then((_) {
      print('🔙 Returned from TV shows grid page');
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted && _viewAllFocusNode != null) {
          setState(() {
            focusedIndex = maxHorizontalItems;
            _hasReceivedFocusFromWebSeries = true;
          });
          _viewAllFocusNode!.requestFocus();
          _scrollToPosition(maxHorizontalItems);
          print('✅ Focused back to ViewAll button and scrolled');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ProfessionalColors.primaryDark,
              ProfessionalColors.surfaceDark.withOpacity(0.5),
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            _buildProfessionalTitle(screenWidth),
            SizedBox(height: screenHeight * 0.01),
            Expanded(child: _buildBody(screenWidth, screenHeight)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalTitle(double screenWidth) {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  ProfessionalColors.accentGreen,
                  ProfessionalColors.accentBlue,
                ],
              ).createShader(bounds),
              child: Text(
                'TV SHOWS',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            if (tvShowsList.length > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ProfessionalColors.accentGreen.withOpacity(0.2),
                      ProfessionalColors.accentBlue.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ProfessionalColors.accentGreen.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${tvShowsList.length} Shows Available',
                  style: const TextStyle(
                    color: ProfessionalColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(double screenWidth, double screenHeight) {
    if (isLoading) {
      return ProfessionalTVShowLoadingIndicator(
          message: 'Loading TV Shows...');
    } else if (tvShowsList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildTVShowsList(screenWidth, screenHeight);
    }
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalColors.accentGreen.withOpacity(0.2),
                  ProfessionalColors.accentGreen.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.live_tv_outlined,
              size: 40,
              color: ProfessionalColors.accentGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No TV Shows Found',
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new shows',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTVShowsList(double screenWidth, double screenHeight) {
    bool showViewAll = tvShowsList.length > 7;

    return FadeTransition(
      opacity: _listFadeAnimation,
      child: Container(
        height: screenHeight * 0.38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
          cacheExtent: 1200,
          itemCount: showViewAll ? 8 : tvShowsList.length,
          itemBuilder: (context, index) {
            if (showViewAll && index == 7) {
              return Focus(
                focusNode: _viewAllFocusNode,
                onFocusChange: (hasFocus) {
                  if (hasFocus && mounted) {
                    Color viewAllColor = ProfessionalColors.gradientColors[
                        math.Random().nextInt(ProfessionalColors.gradientColors.length)];

                    setState(() {
                      _currentAccentColor = viewAllColor;
                    });
                  }
                },
                onKey: (FocusNode node, RawKeyEvent event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                      return KeyEventResult.handled;
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                      if (tvShowsList.isNotEmpty && tvShowsList.length > 6) {
                        String tvShowId = tvShowsList[6].id.toString();
                        FocusScope.of(context).requestFocus(tvshowsFocusNodes[tvShowId]);
                        return KeyEventResult.handled;
                      }
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      // ✅ Arrow Up: WebSeries पर वापस भेजें
                      setState(() {
                        focusedIndex = -1;
                        _hasReceivedFocusFromWebSeries = false;
                      });
                      FocusScope.of(context).unfocus();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          try {
                            Provider.of<FocusProvider>(context, listen: false)
                                .requestFirstWebseriesFocus();
                            print('✅ Navigating back to webseries from TV shows ViewAll');
                          } catch (e) {
                            print('❌ Failed to navigate to webseries: $e');
                          }
                        }
                      });
                      return KeyEventResult.handled;
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                      // ✅ Arrow Down: Next section (अगला section add करें जब ready हो)
                      return KeyEventResult.handled;
                    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                               event.logicalKey == LogicalKeyboardKey.select) {
                      print('🎬 ViewAll button pressed - Opening Grid Page...');
                      _navigateToGridPage();
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: GestureDetector(
                  onTap: _navigateToGridPage,
                  child: ProfessionalTVShowViewAllButton(
                    focusNode: _viewAllFocusNode!,
                    onTap: _navigateToGridPage,
                    totalItems: tvShowsList.length,
                    itemType: 'TV SHOWS',
                  ),
                ),
              );
            }

            var tvShow = tvShowsList[index];
            return _buildTVShowItem(tvShow, index, screenWidth, screenHeight);
          },
        ),
      ),
    );
  }

  Widget _buildTVShowItem(TVShowModel tvShow, int index, double screenWidth, double screenHeight) {
    String tvShowId = tvShow.id.toString();

    tvshowsFocusNodes.putIfAbsent(
      tvShowId,
      () => FocusNode()
        ..addListener(() {
          if (mounted && tvshowsFocusNodes[tvShowId]!.hasFocus) {
            _scrollToPosition(index);
          }
        }),
    );

    return Focus(
      focusNode: tvshowsFocusNodes[tvShowId],
      onFocusChange: (hasFocus) async {
        if (hasFocus && mounted) {
          try {
            Color dominantColor = ProfessionalColors.gradientColors[
                math.Random().nextInt(ProfessionalColors.gradientColors.length)];

            setState(() {
              _currentAccentColor = dominantColor;
              focusedIndex = index;
              _hasReceivedFocusFromWebSeries = true;
            });
          } catch (e) {
            print('Focus change handling failed: $e');
          }
        }
      },
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (index < tvShowsList.length - 1 && index != 6) {
              String nextTVShowId = tvShowsList[index + 1].id.toString();
              FocusScope.of(context).requestFocus(tvshowsFocusNodes[nextTVShowId]);
              return KeyEventResult.handled;
            } else if (index == 6 && tvShowsList.length > 7) {
              FocusScope.of(context).requestFocus(_viewAllFocusNode);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              String prevTVShowId = tvShowsList[index - 1].id.toString();
              FocusScope.of(context).requestFocus(tvshowsFocusNodes[prevTVShowId]);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // ✅ Arrow Up: WebSeries पर वापस भेजें
            setState(() {
              focusedIndex = -1;
              _hasReceivedFocusFromWebSeries = false;
            });
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                try {
                  Provider.of<FocusProvider>(context, listen: false)
                      .requestFirstWebseriesFocus();
                  print('✅ Navigating back to webseries from TV shows');
                } catch (e) {
                  print('❌ Failed to navigate to webseries: $e');
                }
              }
            });
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // ✅ Arrow Down: Next section (अगला section add करें जब ready हो)
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                     event.logicalKey == LogicalKeyboardKey.select) {
            print('🎬 Enter pressed on ${tvShow.name} - Opening Details Page...');
            _navigateToTVShowDetails(tvShow);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _navigateToTVShowDetails(tvShow),
        child: ProfessionalTVShowCard(
          tvShow: tvShow,
          focusNode: tvshowsFocusNodes[tvShowId]!,
          onTap: () => _navigateToTVShowDetails(tvShow),
          onColorChange: (color) {
            setState(() {
              _currentAccentColor = color;
            });
          },
          index: index,
          categoryTitle: 'TV SHOWS',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();

    for (var entry in tvshowsFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
      } catch (e) {}
    }
    tvshowsFocusNodes.clear();

    try {
      _viewAllFocusNode?.removeListener(() {});
      _viewAllFocusNode?.dispose();
    } catch (e) {}

    try {
      _scrollController.dispose();
    } catch (e) {}

    super.dispose();
  }
}

// ✅ Professional TV Shows Grid Page
class ProfessionalTVShowsGridPage extends StatefulWidget {
  final List<TVShowModel> tvShowsList;
  final String title;

  const ProfessionalTVShowsGridPage({
    Key? key,
    required this.tvShowsList,
    this.title = 'All TV Shows',
  }) : super(key: key);

  @override
  _ProfessionalTVShowsGridPageState createState() => _ProfessionalTVShowsGridPageState();
}

class _ProfessionalTVShowsGridPageState extends State<ProfessionalTVShowsGridPage>
    with TickerProviderStateMixin {
  int gridFocusedIndex = 0;
  final int columnsCount = 5;
  Map<int, FocusNode> gridFocusNodes = {};
  late ScrollController _scrollController;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _createGridFocusNodes();
    _initializeAnimations();
    _startStaggeredAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusFirstGridItem();
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startStaggeredAnimation() {
    _fadeController.forward();
    _staggerController.forward();
  }

  void _createGridFocusNodes() {
    for (int i = 0; i < widget.tvShowsList.length; i++) {
      gridFocusNodes[i] = FocusNode();
      gridFocusNodes[i]!.addListener(() {
        if (gridFocusNodes[i]!.hasFocus) {
          _ensureItemVisible(i);
        }
      });
    }
  }

  void _focusFirstGridItem() {
    if (gridFocusNodes.containsKey(0)) {
      setState(() {
        gridFocusedIndex = 0;
      });
      gridFocusNodes[0]!.requestFocus();
    }
  }

  void _ensureItemVisible(int index) {
    if (_scrollController.hasClients) {
      final int row = index ~/ columnsCount;
      final double itemHeight = 200.0;
      final double targetOffset = row * itemHeight;

      _scrollController.animateTo(
        targetOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateGrid(LogicalKeyboardKey key) {
    int newIndex = gridFocusedIndex;
    final int totalItems = widget.tvShowsList.length;
    final int currentRow = gridFocusedIndex ~/ columnsCount;
    final int currentCol = gridFocusedIndex % columnsCount;

    switch (key) {
      case LogicalKeyboardKey.arrowRight:
        if (gridFocusedIndex < totalItems - 1) {
          newIndex = gridFocusedIndex + 1;
        }
        break;

      case LogicalKeyboardKey.arrowLeft:
        if (gridFocusedIndex > 0) {
          newIndex = gridFocusedIndex - 1;
        }
        break;

      case LogicalKeyboardKey.arrowDown:
        final int nextRowIndex = (currentRow + 1) * columnsCount + currentCol;
        if (nextRowIndex < totalItems) {
          newIndex = nextRowIndex;
        }
        break;

      case LogicalKeyboardKey.arrowUp:
        if (currentRow > 0) {
          final int prevRowIndex = (currentRow - 1) * columnsCount + currentCol;
          newIndex = prevRowIndex;
        }
        break;
    }

    if (newIndex != gridFocusedIndex && newIndex >= 0 && newIndex < totalItems) {
      setState(() {
        gridFocusedIndex = newIndex;
      });
      gridFocusNodes[newIndex]!.requestFocus();
    }
  }

  void _navigateToTVShowDetails(TVShowModel tvShow, int index) {
    print('🎬 Grid: Navigating to TV Show Details: ${tvShow.name}');


    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => TVShowDetailsPage(
    //       id: tvShow.id,
    //       banner: tvShow.banner ?? tvShow.poster ?? '',
    //       poster: tvShow.poster ?? tvShow.banner ?? '',
    //       name: tvShow.name,
    //     ),
    //   ),
    // ).then((_) {
    //   print('🔙 Returned from TV Show Details to Grid');
    //   Future.delayed(Duration(milliseconds: 300), () {
    //     if (mounted && gridFocusNodes.containsKey(index)) {
    //       setState(() {
    //         gridFocusedIndex = index;
    //       });
    //       gridFocusNodes[index]!.requestFocus();
    //       print('✅ Restored grid focus to index $index');
    //     }
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Stack(
        children: [
          // Background Gradient
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

          // Main Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildProfessionalAppBar(),
                Expanded(
                  child: _buildGridView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ProfessionalColors.surfaceDark.withOpacity(0.9),
            ProfessionalColors.surfaceDark.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalColors.accentGreen.withOpacity(0.2),
                  ProfessionalColors.accentBlue.withOpacity(0.2),
                ],
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      ProfessionalColors.accentGreen,
                      ProfessionalColors.accentBlue,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ProfessionalColors.accentGreen.withOpacity(0.2),
                        ProfessionalColors.accentBlue.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: ProfessionalColors.accentGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${widget.tvShowsList.length} TV Shows Available',
                    style: const TextStyle(
                      color: ProfessionalColors.accentGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    if (widget.tvShowsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ProfessionalColors.accentGreen.withOpacity(0.2),
                    ProfessionalColors.accentGreen.withOpacity(0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.live_tv_outlined,
                size: 40,
                color: ProfessionalColors.accentGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${widget.title} Found',
              style: TextStyle(
                color: ProfessionalColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for new shows',
              style: TextStyle(
                color: ProfessionalColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Focus(
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape ||
              event.logicalKey == LogicalKeyboardKey.goBack) {
            Navigator.pop(context);
            return KeyEventResult.handled;
          } else if ([
            LogicalKeyboardKey.arrowUp,
            LogicalKeyboardKey.arrowDown,
            LogicalKeyboardKey.arrowLeft,
            LogicalKeyboardKey.arrowRight,
          ].contains(event.logicalKey)) {
            _navigateGrid(event.logicalKey);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                     event.logicalKey == LogicalKeyboardKey.select) {
            if (gridFocusedIndex < widget.tvShowsList.length) {
              _navigateToTVShowDetails(
                widget.tvShowsList[gridFocusedIndex],
                gridFocusedIndex,
              );
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Padding(
        padding: EdgeInsets.all(20),
        child: GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnsCount,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.7,
          ),
          itemCount: widget.tvShowsList.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _staggerController,
              builder: (context, child) {
                final delay = (index / widget.tvShowsList.length) * 0.5;
                final animationValue = Interval(
                  delay,
                  delay + 0.5,
                  curve: Curves.easeOutCubic,
                ).transform(_staggerController.value);

                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: ProfessionalGridTVShowCard(
                      tvShow: widget.tvShowsList[index],
                      focusNode: gridFocusNodes[index]!,
                      onTap: () => _navigateToTVShowDetails(widget.tvShowsList[index], index),
                      index: index,
                      categoryTitle: widget.title,
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

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    _scrollController.dispose();
    for (var node in gridFocusNodes.values) {
      try {
        node.dispose();
      } catch (e) {}
    }
    super.dispose();
  }
}

// ✅ Professional Grid TV Show Card
class ProfessionalGridTVShowCard extends StatefulWidget {
  final TVShowModel tvShow;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int index;
  final String categoryTitle;

  const ProfessionalGridTVShowCard({
    Key? key,
    required this.tvShow,
    required this.focusNode,
    required this.onTap,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalGridTVShowCardState createState() => _ProfessionalGridTVShowCardState();
}

class _ProfessionalGridTVShowCardState extends State<ProfessionalGridTVShowCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  Color _dominantColor = ProfessionalColors.accentGreen;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: AnimationTiming.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });

    if (_isFocused) {
      _hoverController.forward();
      _glowController.forward();
      _generateDominantColor();
      HapticFeedback.lightImpact();
    } else {
      _hoverController.reverse();
      _glowController.reverse();
    }
  }

  void _generateDominantColor() {
    final colors = ProfessionalColors.gradientColors;
    _dominantColor = colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _glowController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    if (_isFocused) ...[
                      BoxShadow(
                        color: _dominantColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: _dominantColor.withOpacity(0.2),
                        blurRadius: 35,
                        spreadRadius: 4,
                        offset: const Offset(0, 12),
                      ),
                    ] else ...[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      _buildTVShowImage(),
                      if (_isFocused) _buildFocusBorder(),
                      _buildGradientOverlay(),
                      _buildTVShowInfo(),
                      if (_isFocused) _buildPlayButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTVShowImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: widget.tvShow.logo != null && widget.tvShow.logo!.isNotEmpty
          ? Image.network(
              widget.tvShow.logo!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder();
              },
              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalColors.cardDark,
            ProfessionalColors.surfaceDark,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.live_tv_outlined,
              size: 40,
              color: ProfessionalColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              'TV SHOW',
              style: TextStyle(
                color: ProfessionalColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ProfessionalColors.accentGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: ProfessionalColors.accentGreen,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusBorder() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 3,
            color: _dominantColor,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTVShowInfo() {
    final tvShowName = widget.tvShow.name;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tvShowName.toUpperCase(),
              style: TextStyle(
                color: _isFocused ? _dominantColor : Colors.white,
                fontSize: _isFocused ? 13 : 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (_isFocused && widget.tvShow.genres != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ProfessionalColors.accentGreen.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ProfessionalColors.accentGreen.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.tvShow.genres!.toUpperCase(),
                      style: const TextStyle(
                        color: ProfessionalColors.accentGreen,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _dominantColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _dominantColor.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'LIVE',
                      style: TextStyle(
                        color: _dominantColor,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _dominantColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: _dominantColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}



