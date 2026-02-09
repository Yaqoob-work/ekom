import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_slider_screen.dart';
import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_loading_widget.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_retry_widget.dart';
import 'dart:math' as math;
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
// ✅ Import Smart Widgets
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:ui';

// ✅ ==========================================================
// MODELS & CONSTANTS
// ✅ ==========================================================
class AnimationTiming {
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration scroll = Duration(milliseconds: 800);
}

class SportsNetworkModel {
  final int id;
  final String name;
  final String? logo;
  final int status;

  SportsNetworkModel({required this.id, required this.name, this.logo, required this.status});

  factory SportsNetworkModel.fromJson(Map<String, dynamic> json) {
    return SportsNetworkModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'],
      status: json['status'] ?? 0,
    );
  }
}

// ✅ ==========================================================
// SPORTS NETWORK SERVICE
// ✅ ==========================================================
class SportsNetworkService {
  static Future<List<SportsNetworkModel>> getAllSportsNetworks() async {
    try {
      return await _fetchSportsNetworksFromApi();
    } catch (e) {
      print('❌ Error in getAllSportsNetworks: $e');
      throw Exception('Failed to load sports networks: $e');
    }
  }

  static Future<List<SportsNetworkModel>> _fetchSportsNetworksFromApi() async {
    try {
      String authKey = SessionManager.authKey;
      var url = Uri.parse(SessionManager.baseUrl + 'getNetworks');

      final response = await https.post(url, headers: {'auth-key': authKey, 'Content-Type': 'application/json', 'Accept': 'application/json', 'domain': SessionManager.savedDomain}, body: json.encode({"network_id": "", "data_for": "sports"})).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => SportsNetworkModel.fromJson(json)).where((n) => n.status == 1).toList();
      } else { throw Exception('API Error: ${response.statusCode}'); }
    } catch (e) { rethrow; }
  }
}

// ✅ ==========================================================
// MAIN WIDGET: ManageSports
// ✅ ==========================================================
class ManageSports extends StatefulWidget {
  const ManageSports({super.key});
  @override
  _ManageSportsState createState() => _ManageSportsState();
}

class _ManageSportsState extends State<ManageSports>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  List<SportsNetworkModel> _fullSportsList = [];
  List<SportsNetworkModel> _displayedSportsList = [];
  bool _showViewAll = false;
  bool isLoading = true;
  String _errorMessage = ''; // ✅ Error State
  int focusedIndex = -1;
  Color _currentAccentColor = ProfessionalColorsForHomePages.accentBlue;
  
  // ✅ Shadow State
  bool _isSectionFocused = false;

  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  Map<String, FocusNode> sportsFocusNodes = {};
  FocusNode? _firstSportsFocusNode;
  late FocusNode _viewAllFocusNode;
  
  // ✅ Retry Focus Node
  final FocusNode _retryFocusNode = FocusNode();
  
  bool _hasReceivedFocus = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _viewAllFocusNode = FocusNode();
    _initializeAnimations();
    _initializeFocusListeners();
    fetchSportsNetworks(); 
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    _viewAllFocusNode.dispose();
    _retryFocusNode.dispose();

    String? firstNetworkId;
    if (_fullSportsList.isNotEmpty) firstNetworkId = _fullSportsList[0].id.toString();

    for (var entry in sportsFocusNodes.entries) {
      if (entry.key != firstNetworkId) {
        try { entry.value.dispose(); } catch (e) {}
      }
    }
    sportsFocusNodes.clear();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(duration: AnimationTiming.slow, vsync: this);
    _listAnimationController = AnimationController(duration: AnimationTiming.slow, vsync: this);
    _headerSlideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutCubic));
    _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _listAnimationController, curve: Curves.easeInOut));
  }

  void _initializeFocusListeners() {
    _viewAllFocusNode.addListener(_onViewAllFocusChange);
  }

  void _onViewAllFocusChange() {
    if (mounted && _viewAllFocusNode.hasFocus) {
      setState(() => _isSectionFocused = true); // ✅ Shadow Update
      setState(() => focusedIndex = _displayedSportsList.length);
      _scrollToPosition(focusedIndex);
    }
  }

  void _scrollToPosition(int index) {
    if (!mounted || !_scrollController.hasClients) return;
    try {
      double itemWidth = bannerwdt + 12;
      double targetPosition = index * itemWidth;
      targetPosition = targetPosition.clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.animateTo(targetPosition, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } catch (e) {}
  }

  void _setupSportsFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final focusProvider = Provider.of<FocusProvider>(context, listen: false);
        
        if (_displayedSportsList.isNotEmpty) {
          // Success Case
          final firstNetworkId = _displayedSportsList[0].id.toString();
          _firstSportsFocusNode = sportsFocusNodes[firstNetworkId];

          if (_firstSportsFocusNode != null) {
            focusProvider.registerFocusNode('sports', _firstSportsFocusNode!);
            
            _firstSportsFocusNode!.addListener(() {
              if (mounted && _firstSportsFocusNode!.hasFocus) {
                if (!_hasReceivedFocus) _hasReceivedFocus = true;
                setState(() => focusedIndex = 0);
                _scrollToPosition(0);
              }
            });
          }
        } else if (_errorMessage.isNotEmpty) {
           // Error Case
           focusProvider.registerFocusNode('sports', _retryFocusNode);
        }
      }
    });
  }

  Future<void> fetchSportsNetworks() async {
    if (!mounted) return;
    setState(() { isLoading = true; _errorMessage = ''; });
    try {
      final fetchedNetworks = await SportsNetworkService.getAllSportsNetworks();
      if (mounted) {
        _fullSportsList = fetchedNetworks;
        if (_fullSportsList.length > 10) {
          _displayedSportsList = _fullSportsList.sublist(0, 10);
        } else {
          _displayedSportsList = _fullSportsList;
        }
        _showViewAll = _fullSportsList.isNotEmpty;
        
        setState(() => isLoading = false);
        if (_fullSportsList.isNotEmpty) {
          _createFocusNodesForItems();
          _setupSportsFocusProvider(); 
          _headerAnimationController.forward();
          _listAnimationController.forward();
        }
      }
    } catch (e) {
      if (mounted) setState(() { isLoading = false; _errorMessage = 'Failed to load Sports Channels'; });
      _setupSportsFocusProvider();
    }
  }

  void _createFocusNodesForItems() {
    sportsFocusNodes.clear();
    for (int i = 0; i < _displayedSportsList.length; i++) {
      String networkId = _displayedSportsList[i].id.toString();
      sportsFocusNodes[networkId] = FocusNode();
      if (i > 0) {
        sportsFocusNodes[networkId]!.addListener(() {
          if (mounted && sportsFocusNodes[networkId]!.hasFocus) {
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

  void _navigateToGridPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SportsSliderScreen(initialNetworkId: null)));
  }

  void _navigateToGridPageWithNetwork(SportsNetworkModel network) async {
    try {
      int? currentUserId = SessionManager.userId;
      await HistoryService.updateUserHistory(userId: currentUserId!, contentType: 4, eventId: network.id, eventTitle: network.name, url: '', categoryId: 0);
    } catch (e) {}
    Navigator.push(context, MaterialPageRoute(builder: (context) => SportsSliderScreen(initialNetworkId: network.id)));
  }

  // ✅ ERROR WIDGET (Smart UI)
  Widget _buildErrorWidget(double height) {
    return SizedBox(
      height: height,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: ProfessionalColorsForHomePages.cardDark.withOpacity(0.3), borderRadius: BorderRadius.circular(50), border: Border.all(color: ProfessionalColorsForHomePages.accentRed.withOpacity(0.3))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 20, color: ProfessionalColorsForHomePages.accentRed),
              const SizedBox(width: 10),
              Flexible(child: Text("Connection Failed", style: const TextStyle(color: ProfessionalColorsForHomePages.textPrimary, fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 15),
              // ✅ Smart Retry Widget
              SmartRetryWidget(
                errorMessage: _errorMessage,
                onRetry: fetchSportsNetworks,
                focusNode: _retryFocusNode,
                providerIdentifier: 'sports',
                onFocusChange: (hasFocus) {
                   if(mounted) setState(() => _isSectionFocused = hasFocus);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(double screenWidth, double screenHeight) {
    double effectiveBannerHgt = bannerhgt ?? screenHeight * 0.2;
    double effectiveBannerWdt = bannerwdt ?? screenWidth * 0.18;

    if (isLoading) {
      // ✅ Smart Loading
      return SmartLoadingWidget(itemWidth: effectiveBannerWdt, itemHeight: effectiveBannerHgt);
    } else if (_errorMessage.isNotEmpty) {
      // ✅ Smart Error
      return _buildErrorWidget(effectiveBannerHgt);
    } else if (_fullSportsList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildSportsList(screenWidth, screenHeight);
    }
  }

  Widget _buildEmptyWidget() {
    return const Center(child: Text("No Sports Channels Found", style: TextStyle(color: Colors.white, fontSize: 12)));
  }

  Widget _buildSportsList(double screenWidth, double screenHeight) {
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
          itemCount: _displayedSportsList.length + (_showViewAll ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _displayedSportsList.length) {
              var network = _displayedSportsList[index];
              return _buildSportsItem(network, index, screenWidth, screenHeight);
            } else {
              return _buildViewAllButton(screenWidth, screenHeight);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSportsItem(SportsNetworkModel network, int index, double screenWidth, double screenHeight) {
    String networkId = network.id.toString();
    FocusNode? focusNode = sportsFocusNodes[networkId];
    if (focusNode == null) return const SizedBox.shrink();

    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) async {
        if (mounted) setState(() => _isSectionFocused = hasFocus); // ✅ Shadow Update
        if (hasFocus) {
          Color dominantColor = ProfessionalColorsForHomePages.accentBlue;
          setState(() {
            _currentAccentColor = dominantColor;
            focusedIndex = index;
            _hasReceivedFocus = true;
          });
          context.read<ColorProvider>().updateColor(dominantColor, true);
        } else {
          bool isAnyItemFocused = sportsFocusNodes.values.any((node) => node.hasFocus);
          if (!mounted) return;
          if (!isAnyItemFocused && !_viewAllFocusNode.hasFocus) {
            context.read<ColorProvider>().resetColor();
          }
        }
      },
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.arrowRight) {
            if (index < _displayedSportsList.length - 1) {
              String nextNetworkId = _displayedSportsList[index + 1].id.toString();
              FocusScope.of(context).requestFocus(sportsFocusNodes[nextNetworkId]);
            } else if (_showViewAll) {
              FocusScope.of(context).requestFocus(_viewAllFocusNode);
            }
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              String prevNetworkId = _displayedSportsList[index - 1].id.toString();
              FocusScope.of(context).requestFocus(sportsFocusNodes[prevNetworkId]);
            }
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowUp) {
            setState(() { focusedIndex = -1; _hasReceivedFocus = false; });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            context.read<FocusProvider>().updateLastFocusedIdentifier('sports');
            context.read<FocusProvider>().focusPreviousRow();
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowDown) {
            setState(() { focusedIndex = -1; _hasReceivedFocus = false; });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            context.read<FocusProvider>().updateLastFocusedIdentifier('sports');
            context.read<FocusProvider>().focusNextRow();
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
            _navigateToGridPageWithNetwork(network);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _navigateToGridPageWithNetwork(network),
        child: ProfessionalSportsCard(
          network: network,
          focusNode: focusNode,
          onTap: () => _navigateToGridPageWithNetwork(network),
          onColorChange: (color) {
            if (mounted) setState(() => _currentAccentColor = color);
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
        if (mounted) setState(() => _isSectionFocused = hasFocus); // ✅ Shadow Update
        if (hasFocus) {
          setState(() { focusedIndex = _displayedSportsList.length; _hasReceivedFocus = true; });
          context.read<ColorProvider>().updateColor(ProfessionalColorsForHomePages.accentBlue, true);
          _scrollToPosition(focusedIndex);
        } else {
          bool isAnyItemFocused = sportsFocusNodes.values.any((node) => node.hasFocus);
          if (!mounted) return;
          if (!isAnyItemFocused) context.read<ColorProvider>().resetColor();
        }
      },
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.arrowLeft) {
            if (_displayedSportsList.isNotEmpty) {
              String prevNetworkId = _displayedSportsList.last.id.toString();
              FocusScope.of(context).requestFocus(sportsFocusNodes[prevNetworkId]);
            }
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowUp) {
            setState(() { focusedIndex = -1; _hasReceivedFocus = false; });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            context.read<FocusProvider>().updateLastFocusedIdentifier('sports');
            context.read<FocusProvider>().focusPreviousRow();
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowDown) {
            setState(() { focusedIndex = -1; _hasReceivedFocus = false; });
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            context.read<FocusProvider>().updateLastFocusedIdentifier('sports');
            context.read<FocusProvider>().focusNextRow();
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
            _navigateToGridPage();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _navigateToGridPage,
        child: ProfessionalSportsViewAllButton(
          focusNode: _viewAllFocusNode,
          onTap: _navigateToGridPage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = (screenhgt ?? screenHeight) * 0.38;

    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        
        bool showShadow = _isSectionFocused;

        return Scaffold(
          backgroundColor: Colors.white,
          body: ClipRect(
            child: SizedBox(
              height: containerHeight,
              child: Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: (screenhgt ?? screenHeight) * 0.02),
                      _buildProfessionalTitle(screenWidth),
                      SizedBox(height: (screenhgt ?? screenHeight) * 0.01),
                      Expanded(child: _buildBody(screenWidth, screenHeight)),
                    ],
                  ),
                  
                  // ✅ SHADOW OVERLAY
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          gradient: showShadow
                              ? LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.8), 
                                    Colors.transparent,             
                                    Colors.transparent,             
                                    Colors.black.withOpacity(0.8), 
                                  ],
                                  stops: const [0.0, 0.25, 0.75, 1.0], 
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalTitle(double screenWidth) {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [ProfessionalColorsForHomePages.accentBlue, ProfessionalColorsForHomePages.accentGreen],
              ).createShader(bounds),
              child: const Text('SPORTS', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 2.0)),
            ),
          ],
        ),
      ),
    );
  }
}



// ✅ ==========================================================
// ✅ Supporting Widgets (Adapted for Sports Theme)
// ✅ ==========================================================

class ProfessionalSportsCard extends StatefulWidget {
  final SportsNetworkModel network;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;

  const ProfessionalSportsCard({
    Key? key,
    required this.network,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
  }) : super(key: key);

  @override
  _ProfessionalSportsCardState createState() =>
      _ProfessionalSportsCardState();
}

class _ProfessionalSportsCardState
    extends State<ProfessionalSportsCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  Color _dominantColor = ProfessionalColorsForHomePages.accentBlue;
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
    // final colors = ProfessionalColorsForHomePages.gradientColors;
    // _dominantColor = colors[math.Random().nextInt(colors.length)];
       _dominantColor = ProfessionalColorsForHomePages.accentBlue;

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
            ProfessionalColorsForHomePages.cardDark,
            ProfessionalColorsForHomePages.surfaceDark,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer, // ✅ Updated Icon
            size: height * 0.25,
            color: ProfessionalColorsForHomePages.textSecondary,
          ),
          const SizedBox(height: 8),
          const Text(
            'SPORTS',
            style: TextStyle(
              color: ProfessionalColorsForHomePages.textSecondary,
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
          color: _isFocused ? _dominantColor : ProfessionalColorsForHomePages.textPrimary,
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

class ProfessionalSportsViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;

  const ProfessionalSportsViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
  }) : super(key: key);

  @override
  _ProfessionalSportsViewAllButtonState createState() =>
      _ProfessionalSportsViewAllButtonState();
}

class _ProfessionalSportsViewAllButtonState
    extends State<ProfessionalSportsViewAllButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;
  final Color _focusColor = ProfessionalColorsForHomePages.accentBlue;

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
            ProfessionalColorsForHomePages.cardDark.withOpacity(0.8),
            ProfessionalColorsForHomePages.surfaceDark.withOpacity(0.8),
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
                    _isFocused ? _focusColor : ProfessionalColorsForHomePages.textPrimary,
              ),
              const SizedBox(height: 8),
              Text(
                'VIEW ALL',
                style: TextStyle(
                  color:
                      _isFocused ? _focusColor : ProfessionalColorsForHomePages.textPrimary,
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
          color: _isFocused ? _focusColor : ProfessionalColorsForHomePages.textPrimary,
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

class ProfessionalSportsLoadingIndicator extends StatefulWidget {
  final String message;
  const ProfessionalSportsLoadingIndicator({
    Key? key,
    this.message = 'Loading...',
  }) : super(key: key);

  @override
  _ProfessionalSportsLoadingIndicatorState createState() =>
      _ProfessionalSportsLoadingIndicatorState();
}

class _ProfessionalSportsLoadingIndicatorState
    extends State<ProfessionalSportsLoadingIndicator>
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
                      ProfessionalColorsForHomePages.accentBlue,
                      ProfessionalColorsForHomePages.accentGreen,
                      ProfessionalColorsForHomePages.accentRed,
                      ProfessionalColorsForHomePages.accentBlue,
                    ],
                    stops: [0.0, 0.3, 0.7, 1.0],
                    transform: GradientRotation(_animation.value * 2 * math.pi),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ProfessionalColorsForHomePages.primaryDark,
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    color: ProfessionalColorsForHomePages.textPrimary,
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
              color: ProfessionalColorsForHomePages.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}