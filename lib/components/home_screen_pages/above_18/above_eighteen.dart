import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/home_screen_pages/above_18/above_eighteen_slider_screen.dart';
// ⚠️ ENSURE YOU HAVE THIS FILE. IF YOU HAVE A SPECIFIC 'ADULT' SLIDER, IMPORT THAT INSTEAD.
// FOR NOW, WE ARE REUSING THE GRID SCREEN STRUCTURE.
import 'package:mobi_tv_entertainment/components/home_screen_pages/kids_shows/kid_channels_slider_screen.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show_second_page.dart';
import 'dart:math' as math;
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:ui';

// ✅ Professional Color Palette (Tweaked for 18+ Theme)
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

  // ✅ Changed Gradient Priority: Red/Purple first for 18+ look
  static List<Color> gradientColors = [
    accentRed,
    accentPurple,
    accentBlue,
    accentOrange,
    accentPink,
    accentGreen,
  ];
}

// ✅ Animation Durations
class AnimationTiming {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration focus = Duration(milliseconds: 300);
  static const Duration scroll = Duration(milliseconds: 800);
}

// ✅ ==========================================================
// ✅ [RENAMED] Adult Content Model
// ✅ ==========================================================
class AdultContentModel {
  final int id;
  final String name;
  final String? logo;
  final int status;

  AdultContentModel({
    required this.id,
    required this.name,
    this.logo,
    required this.status,
  });

  factory AdultContentModel.fromJson(Map<String, dynamic> json) {
    return AdultContentModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'],
      status: json['status'] ?? 0,
    );
  }
}

// ✅ ==========================================================
// ✅ [RENAMED & MODIFIED] AdultContentService
// ✅ ==========================================================
class AdultContentService {
  /// Main method to get all Adult Content (Direct API Call)
  static Future<List<AdultContentModel>> getAllAdultContent() async {
    try {
      print('🔞 Loading Fresh Adult Content from API...');
      return await _fetchAdultContentFromApi();
    } catch (e) {
      print('❌ Error in getAllAdultContent: $e');
      throw Exception('Failed to load adult content: $e');
    }
  }

  /// Fetch data from API
  static Future<List<AdultContentModel>> _fetchAdultContentFromApi() async {
    try {
      String authKey = SessionManager.authKey;
      var url = Uri.parse(SessionManager.baseUrl + 'getNetworks');

      final response = await https
          .post(
            url,
            headers: {
              'auth-key': authKey,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'domain': SessionManager.savedDomain,
            },
            // ✅ [CRITICAL CHANGE] "data_for" set to "adultmovies"
            body: json.encode({"network_id": "", "data_for": "adultmovies"}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        final allContent = jsonData
            .map((json) =>
                AdultContentModel.fromJson(json as Map<String, dynamic>))
            .toList();

        final activeContent =
            allContent.where((item) => item.status == 1).toList();

        print(
            '✅ Successfully loaded ${activeContent.length} active Adult items');
        return activeContent;
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error fetching adult content: $e');
      rethrow;
    }
  }
}

// ✅ ==========================================================
// ✅ [RENAMED] Main Widget: AboveEighteen
// ✅ ==========================================================
class AboveEighteen extends StatefulWidget {
  const AboveEighteen({super.key});
  @override
  _AboveEighteenState createState() => _AboveEighteenState();
}

class _AboveEighteenState extends State<AboveEighteen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  // ✅ [RENAMED] State variables
  List<AdultContentModel> _fullContentList = [];
  List<AdultContentModel> _displayedContentList = [];
  bool _showViewAll = false;
  bool isLoading = true;
  int focusedIndex = -1;
  Color _currentAccentColor = ProfessionalColors.accentRed; // Default to Red

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  // ✅ [RENAMED] Focus variables
  Map<String, FocusNode> contentFocusNodes = {};
  FocusNode? _firstContentFocusNode;
  late FocusNode _viewAllFocusNode;
  bool _hasReceivedFocus = false;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _viewAllFocusNode = FocusNode();
    _initializeAnimations();
    _initializeFocusListeners();
    fetchAdultContent(); // ✅ Direct Fetch
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();

    _viewAllFocusNode.removeListener(_onViewAllFocusChange);
    _viewAllFocusNode.dispose();

    // Dispose logic
    String? firstContentId;
    if (_fullContentList.isNotEmpty) {
      firstContentId = _fullContentList[0].id.toString();
    }

    for (var entry in contentFocusNodes.entries) {
      if (entry.key != firstContentId) {
        try {
          entry.value.removeListener(() {});
          entry.value.dispose();
        } catch (e) {}
      }
    }
    contentFocusNodes.clear();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _headerAnimationController =
        AnimationController(duration: AnimationTiming.slow, vsync: this);
    _listAnimationController =
        AnimationController(duration: AnimationTiming.slow, vsync: this);

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _headerAnimationController, curve: Curves.easeOutCubic));

    _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _listAnimationController, curve: Curves.easeInOut));
  }

  void _initializeFocusListeners() {
    _viewAllFocusNode.addListener(_onViewAllFocusChange);
  }

  void _onViewAllFocusChange() {
    if (mounted && _viewAllFocusNode.hasFocus) {
      setState(() {
        focusedIndex = _displayedContentList.length;
      });
      _scrollToPosition(focusedIndex);
    }
  }

  void _scrollToPosition(int index) {
    if (!mounted || !_scrollController.hasClients) return;
    try {
      double itemWidth = bannerwdt + 12;
      double targetPosition = index * itemWidth;
      targetPosition =
          targetPosition.clamp(0.0, _scrollController.position.maxScrollExtent);

      _scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } catch (e) {
      print('Error scrolling in list: $e');
    }
  }

  // ✅ [RENAMED & UPDATED KEY]
  void _setupContentFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _displayedContentList.isNotEmpty) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);
          final firstContentId = _displayedContentList[0].id.toString();
          _firstContentFocusNode = contentFocusNodes[firstContentId];

          if (_firstContentFocusNode != null) {
            // ✅ [CRITICAL CHANGE] Key changed to 'adultmovies'
            // This ensures it doesn't clash with 'kidchannels'
            focusProvider.registerFocusNode(
                'aboveEighteen', _firstContentFocusNode!);

            _firstContentFocusNode!.addListener(() {
              if (mounted && _firstContentFocusNode!.hasFocus) {
                if (!_hasReceivedFocus) {
                  _hasReceivedFocus = true;
                }
                setState(() => focusedIndex = 0);
                _scrollToPosition(0);
              }
            });
          }
        } catch (e) {
          print('❌ Adult focus provider setup failed: $e');
        }
      }
    });
  }

  Future<void> fetchAdultContent() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      // ✅ Calling the new Service
      final fetchedContent = await AdultContentService.getAllAdultContent();

      if (mounted) {
        _fullContentList = fetchedContent;

        if (_fullContentList.length > 10) {
          _displayedContentList = _fullContentList.sublist(0, 10);
        } else {
          _displayedContentList = _fullContentList;
        }
        _showViewAll = _fullContentList.isNotEmpty;

        setState(() {
          isLoading = false;
        });

        if (_fullContentList.isNotEmpty) {
          _createFocusNodesForItems();
          _setupContentFocusProvider();
          _headerAnimationController.forward();
          _listAnimationController.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching Adult Content: $e');
    }
  }

  void _createFocusNodesForItems() {
    contentFocusNodes.clear();

    for (int i = 0; i < _displayedContentList.length; i++) {
      String contentId = _displayedContentList[i].id.toString();
      contentFocusNodes[contentId] = FocusNode();

      if (i > 0) {
        contentFocusNodes[contentId]!.addListener(() {
          if (mounted && contentFocusNodes[contentId]!.hasFocus) {
            setState(() {
              focusedIndex = i;
              _hasReceivedFocus = true;
            });
            _scrollToPosition(i);
          }
        });
      }
    }
  }

  // ✅ [RENAMED] Navigation
  void _navigateToDetails(AdultContentModel content) async {
    print('🎬 Navigating to Details: ${content.name}');

    try {
      int? currentUserId = SessionManager.userId;
      await HistoryService.updateUserHistory(
        userId: currentUserId!,
        contentType: 4,
        eventId: content.id,
        eventTitle: content.name,
        url: '',
        categoryId: 0,
      );
    } catch (e) {
      print("History update failed: $e");
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        // ✅ Reusing details page
        builder: (context) => TVShowDetailsPage(
          tvChannelId: content.id,
          channelName: content.name,
          channelLogo: content.logo,
        ),
      ),
    );
  }

  void _navigateToGridPage() {
    // ⚠️ NOTE: If you have a specific 'AdultChannelsSliderScreen', use that here.
    // Otherwise, we reuse the generic grid screen.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboveEighteenSliderScreen(
          // initialNetworkId: null, 
          tvChannelId: '', logoUrl: '', title: '',
        ),
      ),
    );
  }

  void _navigateToGridPageWithId(AdultContentModel content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboveEighteenSliderScreen(
          tvChannelId:  content.id.toString(), logoUrl: '', title: '',
          // initialNetworkId: content.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        final bgColor = colorProvider.isItemFocused
            ? colorProvider.dominantColor.withOpacity(0.1)
            : ProfessionalColors.primaryDark;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bgColor,
                  bgColor.withOpacity(0.8),
                  ProfessionalColors.primaryDark,
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
      },
    );
  }

  Widget _buildContentItem(AdultContentModel content, int index,
      double screenWidth, double screenHeight) {
    String contentId = content.id.toString();
    FocusNode? focusNode = contentFocusNodes[contentId];

    if (focusNode == null) return const SizedBox.shrink();

    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) async {
        if (!mounted) return;
        if (hasFocus) {
          try {
            Color dominantColor = ProfessionalColors.gradientColors[
                math.Random()
                    .nextInt(ProfessionalColors.gradientColors.length)];
            setState(() {
              _currentAccentColor = dominantColor;
              focusedIndex = index;
              _hasReceivedFocus = true;
            });
            context.read<ColorProvider>().updateColor(dominantColor, true);
            _scrollToPosition(index);
          } catch (e) {
            print('Focus change handling failed: $e');
          }
        } else {
          bool isAnyItemFocused =
              contentFocusNodes.values.any((node) => node.hasFocus);
          if (!mounted) return;
          if (!isAnyItemFocused && !_viewAllFocusNode.hasFocus) {
            context.read<ColorProvider>().resetColor();
          }
        }
      },
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          final key = event.logicalKey;

          if (key == LogicalKeyboardKey.arrowRight) {
            if (index < _displayedContentList.length - 1) {
              String nextContentId =
                  _displayedContentList[index + 1].id.toString();
              FocusScope.of(context)
                  .requestFocus(contentFocusNodes[nextContentId]);
            } else if (_showViewAll) {
              FocusScope.of(context).requestFocus(_viewAllFocusNode);
            }
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              String prevContentId =
                  _displayedContentList[index - 1].id.toString();
              FocusScope.of(context)
                  .requestFocus(contentFocusNodes[prevContentId]);
            }
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowUp) {
            setState(() {
              focusedIndex = -1;
              _hasReceivedFocus = false;
            });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                context.read<FocusProvider>().focusPreviousRow();
              }
            });
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowDown) {
            setState(() {
              focusedIndex = -1;
              _hasReceivedFocus = false;
            });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                context.read<FocusProvider>().focusNextRow();
              }
            });
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.select) {
            _navigateToGridPageWithId(content);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _navigateToGridPageWithId(content),
        child: ProfessionalContentCard(
          content: content,
          focusNode: focusNode,
          onTap: () => _navigateToGridPageWithId(content),
          onColorChange: (color) {
            if (!mounted) return;
            setState(() {
              _currentAccentColor = color;
            });
            context.read<ColorProvider>().updateColor(color, true);
          },
        ),
      ),
    );
  }

  Widget _buildViewAllButton(double screenWidth, double screenHeight) {
    return Focus(
      focusNode: _viewAllFocusNode,
      onFocusChange: (hasFocus) {
        if (!mounted) return;
        if (hasFocus) {
          setState(() {
            focusedIndex = _displayedContentList.length;
            _hasReceivedFocus = true;
          });
          context
              .read<ColorProvider>()
              .updateColor(ProfessionalColors.accentPurple, true);
          _scrollToPosition(focusedIndex);
        } else {
          bool isAnyItemFocused =
              contentFocusNodes.values.any((node) => node.hasFocus);
          if (!mounted) return;
          if (!isAnyItemFocused) {
            context.read<ColorProvider>().resetColor();
          }
        }
      },
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          final key = event.logicalKey;

          if (key == LogicalKeyboardKey.arrowLeft) {
            if (_displayedContentList.isNotEmpty) {
              String prevContentId = _displayedContentList.last.id.toString();
              FocusScope.of(context)
                  .requestFocus(contentFocusNodes[prevContentId]);
            }
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowUp) {
            setState(() {
              focusedIndex = -1;
              _hasReceivedFocus = false;
            });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                context.read<FocusProvider>().focusPreviousRow();
              }
            });
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowDown) {
            setState(() {
              focusedIndex = -1;
              _hasReceivedFocus = false;
            });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                context.read<FocusProvider>().focusNextRow();
              }
            });
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.enter ||
              key == LogicalKeyboardKey.select) {
            _navigateToGridPage();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _navigateToGridPage,
        child: ProfessionalViewAllButton(
          focusNode: _viewAllFocusNode,
          onTap: _navigateToGridPage,
        ),
      ),
    );
  }

  Widget _buildContentList(double screenWidth, double screenHeight) {
    return FadeTransition(
      opacity: _listFadeAnimation,
      child: Container(
        height: screenHeight * 0.38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
          cacheExtent: 9999,
          itemCount: _displayedContentList.length + (_showViewAll ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _displayedContentList.length) {
              var content = _displayedContentList[index];
              return _buildContentItem(
                  content, index, screenWidth, screenHeight);
            } else {
              return _buildViewAllButton(screenWidth, screenHeight);
            }
          },
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
                  ProfessionalColors.accentRed, // Darker/Mature colors
                  ProfessionalColors.accentPurple,
                ],
              ).createShader(bounds),
              child: const Text(
                '18+ ZONE', // ✅ Title Updated
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
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
      return ProfessionalLoadingIndicator(message: 'Loading 18+ Content...');
    } else if (_fullContentList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildContentList(screenWidth, screenHeight);
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
                  ProfessionalColors.accentRed.withOpacity(0.2),
                  ProfessionalColors.accentRed.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.movie_filter_rounded, // ✅ Icon Updated for 18+ theme
              size: 40,
              color: ProfessionalColors.accentRed,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Content Found', // ✅ Text Updated
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ ==========================================================
// ✅ Supporting Widgets (Renamed for generic/adult use)
// ✅ ==========================================================

class ProfessionalContentCard extends StatefulWidget {
  final AdultContentModel content;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;

  const ProfessionalContentCard({
    Key? key,
    required this.content,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
  }) : super(key: key);

  @override
  _ProfessionalContentCardState createState() =>
      _ProfessionalContentCardState();
}

class _ProfessionalContentCardState extends State<ProfessionalContentCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  Color _dominantColor = ProfessionalColors.accentRed;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _scaleController =
        AnimationController(duration: AnimationTiming.slow, vsync: this);
    _glowController =
        AnimationController(duration: AnimationTiming.medium, vsync: this);
    _shimmerController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this)
      ..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;
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
    widget.focusNode.removeListener(_handleFocusChange);
    _scaleController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
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
            width: bannerwdt,
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
    final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;

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
            _buildNetworkImage(screenWidth, posterHeight),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImage(double screenWidth, double posterHeight) {
    return Container(
        width: double.infinity,
        height: posterHeight,
        child: widget.content.logo != null && widget.content.logo!.isNotEmpty
            ? Image.network(
                widget.content.logo!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildImagePlaceholder(posterHeight);
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(posterHeight),
              )
            : _buildImagePlaceholder(posterHeight));
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
            Icons.local_movies_rounded, // ✅ Updated Icon
            size: height * 0.25,
            color: ProfessionalColors.textSecondary,
          ),
          const SizedBox(height: 8),
          const Text(
            '18+',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
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
    final contentName = widget.content.name.toUpperCase();

    return Container(
      width: bannerwdt,
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
          contentName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class ProfessionalViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;

  const ProfessionalViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
  }) : super(key: key);

  @override
  _ProfessionalViewAllButtonState createState() =>
      _ProfessionalViewAllButtonState();
}

class _ProfessionalViewAllButtonState extends State<ProfessionalViewAllButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;
  final Color _focusColor = ProfessionalColors.accentPurple;

  @override
  void initState() {
    super.initState();
    _scaleController =
        AnimationController(duration: AnimationTiming.slow, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });

    if (_isFocused) {
      _scaleController.forward();
      HapticFeedback.lightImpact();
    } else {
      _scaleController.reverse();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: bannerwdt,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildButtonBody(),
                _buildButtonTitle(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonBody() {
    final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;
    return Container(
      height: posterHeight,
      width: bannerwdt,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalColors.cardDark.withOpacity(0.8),
            ProfessionalColors.surfaceDark.withOpacity(0.8),
          ],
        ),
        border: Border.all(
          width: _isFocused ? 3 : 0,
          color: _isFocused ? _focusColor : Colors.transparent,
        ),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: _focusColor.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 3,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 30,
                color:
                    _isFocused ? _focusColor : ProfessionalColors.textPrimary,
              ),
              const SizedBox(height: 8),
              Text(
                'VIEW ALL',
                style: TextStyle(
                  color:
                      _isFocused ? _focusColor : ProfessionalColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonTitle() {
    return Container(
      width: bannerwdt,
      child: AnimatedDefaultTextStyle(
        duration: AnimationTiming.medium,
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11,
          fontWeight: FontWeight.w600,
          color: _isFocused ? _focusColor : ProfessionalColors.textPrimary,
        ),
        child: const Text(
          'SEE ALL',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class ProfessionalLoadingIndicator extends StatefulWidget {
  final String message;
  const ProfessionalLoadingIndicator({
    Key? key,
    this.message = 'Loading...',
  }) : super(key: key);

  @override
  _ProfessionalLoadingIndicatorState createState() =>
      _ProfessionalLoadingIndicatorState();
}

class _ProfessionalLoadingIndicatorState
    extends State<ProfessionalLoadingIndicator> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this)
      ..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
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
                    colors: const [
                      ProfessionalColors.accentRed,
                      ProfessionalColors.accentPurple,
                      ProfessionalColors.accentOrange,
                      ProfessionalColors.accentBlue,
                      ProfessionalColors.accentRed,
                    ],
                    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
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
                    Icons.movie_filter_rounded,
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
        ],
      ),
    );
  }
}
