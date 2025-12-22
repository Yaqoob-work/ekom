import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
// ⚠️ ENSURE YOU HAVE THIS FILE OR RENAME THE IMPORT TO YOUR KIDS SLIDER SCREEN
// import 'package:mobi_tv_entertainment/components/home_screen_pages/kids_channel/kids_channel_slider_screen.dart';
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

// ✅ Professional Color Palette (Kept same for consistency)
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
    accentPink, // Prioritized Pink/Blue for Kids theme
    accentBlue,
    accentOrange,
    accentGreen,
    accentPurple,
    accentRed,
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
// ✅ [RENAMED] Kids Network Model
// ✅ ==========================================================
class KidsNetworkModel {
  final int id;
  final String name;
  final String? logo;
  final int status;

  KidsNetworkModel({
    required this.id,
    required this.name,
    this.logo,
    required this.status,
  });

  factory KidsNetworkModel.fromJson(Map<String, dynamic> json) {
    return KidsNetworkModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'],
      status: json['status'] ?? 0,
    );
  }
}

// ✅ ==========================================================
// ✅ [RENAMED & MODIFIED] KidsNetworkService
// ✅ ==========================================================
class KidsNetworkService {
  
  /// Main method to get all Kids Networks (Direct API Call)
  static Future<List<KidsNetworkModel>> getAllKidsNetworks() async {
    try {
      print('🧸 Loading Fresh Kids Networks from API...'); 
      return await _fetchKidsNetworksFromApi();
    } catch (e) {
      print('❌ Error in getAllKidsNetworks: $e');
      throw Exception('Failed to load kids networks: $e');
    }
  }

  /// Fetch data from API
  static Future<List<KidsNetworkModel>> _fetchKidsNetworksFromApi() async {
    try {
      String authKey = SessionManager.authKey;
      var url = Uri.parse(SessionManager.baseUrl + 'getNetworks');

      final response = await https
          .post(url,
            headers: {
              'auth-key': authKey,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'domain': SessionManager.savedDomain,
            },
            // ✅ [CRITICAL CHANGE] "data_for" set to "kidchannels"
            body: json.encode({"network_id": "", "data_for": "kidchannels"}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        final allNetworks = jsonData
            .map((json) =>
                KidsNetworkModel.fromJson(json as Map<String, dynamic>))
            .toList();

        final activeNetworks =
            allNetworks.where((network) => network.status == 1).toList();

        print(
            '✅ Successfully loaded ${activeNetworks.length} active Kids networks');
        return activeNetworks;
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error fetching kids networks: $e');
      rethrow;
    }
  }
}

// ✅ ==========================================================
// ✅ [RENAMED] Main Widget: ManageKidsShows
// ✅ ==========================================================
class ManageKidsShows extends StatefulWidget {
  const ManageKidsShows({super.key});
  @override
  _ManageKidsShowsState createState() => _ManageKidsShowsState();
}

class _ManageKidsShowsState extends State<ManageKidsShows>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  // ✅ [RENAMED] State variables
  List<KidsNetworkModel> _fullKidsList = [];
  List<KidsNetworkModel> _displayedKidsList = [];
  bool _showViewAll = false;
  bool isLoading = true;
  int focusedIndex = -1;
  Color _currentAccentColor = ProfessionalColors.accentPink;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  // ✅ [RENAMED] Focus variables
  Map<String, FocusNode> kidsFocusNodes = {};
  FocusNode? _firstKidsFocusNode;
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
    fetchKidsNetworks(); // ✅ Direct Fetch
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();

    _viewAllFocusNode.removeListener(_onViewAllFocusChange);
    _viewAllFocusNode.dispose();

    // Dispose logic
    String? firstNetworkId;
    if (_fullKidsList.isNotEmpty) {
      firstNetworkId = _fullKidsList[0].id.toString();
    }

    for (var entry in kidsFocusNodes.entries) {
      if (entry.key != firstNetworkId) {
        try {
          entry.value.removeListener(() {});
          entry.value.dispose();
        } catch (e) {}
      }
    }
    kidsFocusNodes.clear();
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
        focusedIndex = _displayedKidsList.length; 
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
      print('Error scrolling in kids list: $e');
    }
  }

  // ✅ [RENAMED & UPDATED KEY]
  void _setupKidsFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _displayedKidsList.isNotEmpty) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);
          final firstNetworkId = _displayedKidsList[0].id.toString();
          _firstKidsFocusNode =
              kidsFocusNodes[firstNetworkId];

          if (_firstKidsFocusNode != null) {
            // ✅ [UPDATED KEY] 'kidsChannels'
            focusProvider.registerFocusNode(
                'kidchannels', _firstKidsFocusNode!);
            
            _firstKidsFocusNode!.addListener(() {
              if (mounted && _firstKidsFocusNode!.hasFocus) {
                if (!_hasReceivedFocus) {
                  _hasReceivedFocus = true;
                }
                setState(() => focusedIndex = 0);
                _scrollToPosition(0);
              }
            });
          }
        } catch (e) {
          print('❌ Kids focus provider setup failed: $e');
        }
      }
    });
  }

  // ✅ [RENAMED] No Cache Logic
  Future<void> fetchKidsNetworks() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      // ✅ Calling the new Service
      final fetchedNetworks = await KidsNetworkService.getAllKidsNetworks();

      if (mounted) {
        _fullKidsList = fetchedNetworks;
        
        if (_fullKidsList.length > 10) {
          _displayedKidsList = _fullKidsList.sublist(0, 10);
        } else {
          _displayedKidsList = _fullKidsList;
        }
        _showViewAll = _fullKidsList.isNotEmpty;

        setState(() {
          isLoading = false;
        });

        if (_fullKidsList.isNotEmpty) {
          _createFocusNodesForItems();
          _setupKidsFocusProvider(); 
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
      print('Error fetching Kids Networks: $e');
    }
  }

  void _createFocusNodesForItems() {
    kidsFocusNodes.clear();

    for (int i = 0; i < _displayedKidsList.length; i++) {
      String networkId = _displayedKidsList[i].id.toString();
      kidsFocusNodes[networkId] = FocusNode();

      if (i > 0) {
        kidsFocusNodes[networkId]!.addListener(() {
          if (mounted && kidsFocusNodes[networkId]!.hasFocus) {
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
  void _navigateToKidsDetails(KidsNetworkModel network) async {
    print('🎬 Navigating to Kids Details: ${network.name}');

    try {
      int? currentUserId = SessionManager.userId;
      await HistoryService.updateUserHistory(
        userId: currentUserId!,
        contentType: 4, 
        eventId: network.id,
        eventTitle: network.name,
        url: '',
        categoryId: 0, 
      );
    } catch (e) {
      print("History update failed: $e");
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        // ✅ Reusing the same details page structure
        builder: (context) => TVShowDetailsPage(
          tvChannelId: network.id,
          channelName: network.name,
          channelLogo: network.logo,
        ),
      ),
    );
  }

  void _navigateToGridPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KidChannelsSliderScreen(
          initialNetworkId: null, 
        ),
      ),
    );
  }

  void _navigateToGridPageWithNetwork(KidsNetworkModel network) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KidChannelsSliderScreen (
          initialNetworkId: network.id, 
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

  Widget _buildKidsItem(KidsNetworkModel network, int index,
      double screenWidth, double screenHeight) {
    String networkId = network.id.toString();
    FocusNode? focusNode = kidsFocusNodes[networkId];

    if (focusNode == null) return const SizedBox.shrink();

    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) async {
        if (!mounted) return;
        if (hasFocus) {
          try {
            Color dominantColor = ProfessionalColors.gradientColors[
                math.Random().nextInt(ProfessionalColors.gradientColors.length)];
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
              kidsFocusNodes.values.any((node) => node.hasFocus);
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
            if (index < _displayedKidsList.length - 1) {
              String nextNetworkId =
                  _displayedKidsList[index + 1].id.toString();
              FocusScope.of(context)
                  .requestFocus(kidsFocusNodes[nextNetworkId]);
            } else if (_showViewAll) {
              FocusScope.of(context).requestFocus(_viewAllFocusNode);
            }
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              String prevNetworkId =
                  _displayedKidsList[index - 1].id.toString();
              FocusScope.of(context)
                  .requestFocus(kidsFocusNodes[prevNetworkId]);
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
            _navigateToGridPageWithNetwork(network);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _navigateToGridPageWithNetwork(network),
        child: ProfessionalKidsCard(
          network: network,
          focusNode: focusNode,
          onTap: () => _navigateToGridPageWithNetwork(network),
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
            focusedIndex = _displayedKidsList.length;
            _hasReceivedFocus = true;
          });
          context
              .read<ColorProvider>()
              .updateColor(ProfessionalColors.accentPurple, true);
          _scrollToPosition(focusedIndex);
        } else {
          bool isAnyItemFocused =
              kidsFocusNodes.values.any((node) => node.hasFocus);
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
            if (_displayedKidsList.isNotEmpty) {
              String prevNetworkId =
                  _displayedKidsList.last.id.toString();
              FocusScope.of(context)
                  .requestFocus(kidsFocusNodes[prevNetworkId]);
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
        child: ProfessionalKidsViewAllButton(
          focusNode: _viewAllFocusNode,
          onTap: _navigateToGridPage,
        ),
      ),
    );
  }

  Widget _buildKidsList(double screenWidth, double screenHeight) {
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
          itemCount:
              _displayedKidsList.length + (_showViewAll ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _displayedKidsList.length) {
              var network = _displayedKidsList[index];
              return _buildKidsItem(
                  network, index, screenWidth, screenHeight);
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
                  ProfessionalColors.accentPink, // Playful colors
                  ProfessionalColors.accentBlue,
                ],
              ).createShader(bounds),
              child: const Text(
                'KIDS ZONE', // ✅ Title Updated
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
      return ProfessionalKidsLoadingIndicator(
          message: 'Loading Kids Channels...');
    } else if (_fullKidsList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildKidsList(screenWidth, screenHeight);
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
                  ProfessionalColors.accentPink.withOpacity(0.2),
                  ProfessionalColors.accentPink.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.toys_rounded, // ✅ Icon Updated for Kids theme
              size: 40,
              color: ProfessionalColors.accentPink,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Kids Channels Found', // ✅ Text Updated
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for cartoons',
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
// ✅ Supporting Widgets (Adapted for Kids Theme)
// ✅ ==========================================================

class ProfessionalKidsCard extends StatefulWidget {
  final KidsNetworkModel network;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;

  const ProfessionalKidsCard({
    Key? key,
    required this.network,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
  }) : super(key: key);

  @override
  _ProfessionalKidsCardState createState() =>
      _ProfessionalKidsCardState();
}

class _ProfessionalKidsCardState
    extends State<ProfessionalKidsCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  Color _dominantColor = ProfessionalColors.accentPink;
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
      child: widget.network.logo != null && widget.network.logo!.isNotEmpty
          ? Image.network(
              widget.network.logo!,
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
            Icons.toys_rounded, // ✅ Updated Icon
            size: height * 0.25,
            color: ProfessionalColors.textSecondary,
          ),
          const SizedBox(height: 8),
          const Text(
            'KIDS',
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
    final networkName = widget.network.name.toUpperCase();

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
          networkName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class ProfessionalKidsViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;

  const ProfessionalKidsViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
  }) : super(key: key);

  @override
  _ProfessionalKidsViewAllButtonState createState() =>
      _ProfessionalKidsViewAllButtonState();
}

class _ProfessionalKidsViewAllButtonState
    extends State<ProfessionalKidsViewAllButton>
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

class ProfessionalKidsLoadingIndicator extends StatefulWidget {
  final String message;
  const ProfessionalKidsLoadingIndicator({
    Key? key,
    this.message = 'Loading...',
  }) : super(key: key);

  @override
  _ProfessionalKidsLoadingIndicatorState createState() =>
      _ProfessionalKidsLoadingIndicatorState();
}

class _ProfessionalKidsLoadingIndicatorState
    extends State<ProfessionalKidsLoadingIndicator>
    with TickerProviderStateMixin {
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
                      ProfessionalColors.accentPink,
                      ProfessionalColors.accentBlue,
                      ProfessionalColors.accentOrange,
                      ProfessionalColors.accentGreen,
                      ProfessionalColors.accentPink,
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
                    Icons.toys_rounded,
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