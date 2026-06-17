import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/main_dashboard_screen.dart';
import 'package:mobi_tv_entertainment/plan_expired_screen.dart';



class CommonSeasonModel {
  final String id;
  final String title;
  final int order;
  final String bannerUrl;
  final dynamic originalData; 

  CommonSeasonModel({
    required this.id, required this.title, required this.order, required this.bannerUrl, required this.originalData,
  });
}

class CommonEpisodeModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int order;
  final dynamic originalData; 

  CommonEpisodeModel({
    required this.id, required this.title, required this.description, required this.imageUrl, required this.order, required this.originalData,
  });
}

enum NavigationMode { seasons, episodes }

class SmartShowDetailsScreen extends StatefulWidget {
  final String showName;
  final String bannerUrl;
  final String focusIdentifier;

  // Generic Functions - Calling page se data aayega
  final Future<List<CommonSeasonModel>> Function() fetchSeasons;
  final Future<List<CommonEpisodeModel>> Function(String seasonId) fetchEpisodes;
  final Future<void> Function(CommonEpisodeModel episode) onEpisodeTap;

  const SmartShowDetailsScreen({
    Key? key,
    required this.showName,
    required this.bannerUrl,
    required this.focusIdentifier,
    required this.fetchSeasons,
    required this.fetchEpisodes,
    required this.onEpisodeTap,
  }) : super(key: key);

  @override
  _SmartShowDetailsScreenState createState() => _SmartShowDetailsScreenState();
}

class _SmartShowDetailsScreenState extends State<SmartShowDetailsScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  final FocusNode _mainFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _seasonsScrollController = ScrollController();

  List<CommonSeasonModel> _seasons = [];
  Map<String, List<CommonEpisodeModel>> _episodesMap = {};

  int _selectedSeasonIndex = 0;
  int _selectedEpisodeIndex = 0;
  NavigationMode _currentMode = NavigationMode.seasons;

  final Map<int, FocusNode> _seasonsFocusNodes = {};
  final Map<String, FocusNode> _episodeFocusNodes = {};

  bool _isLoading = true;
  bool _isProcessing = false;
  bool _isLoadingEpisodes = false;
  String _errorMessage = "";

  late AnimationController _navigationModeController;
  late AnimationController _pageTransitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _loadSeasons();
  }

  void _initializeAnimations() {
    _navigationModeController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _pageTransitionController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _pageTransitionController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _pageTransitionController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mainFocusNode.dispose();
    _scrollController.dispose();
    _seasonsScrollController.dispose();
    _seasonsFocusNodes.values.forEach((node) => node.dispose());
    _episodeFocusNodes.values.forEach((node) => node.dispose());
    _navigationModeController.dispose();
    _pageTransitionController.dispose();
    super.dispose();
  }

  Future<void> _loadSeasons() async {
    setState(() { _isLoading = true; _errorMessage = ""; });
    try {
      final seasons = await widget.fetchSeasons();
      if (mounted) {
        setState(() { _seasons = seasons; _isLoading = false; });
        _seasonsFocusNodes.clear();
        for (int i = 0; i < _seasons.length; i++) { _seasonsFocusNodes[i] = FocusNode(); }

        if (_seasons.isNotEmpty) {
          _pageTransitionController.forward();
          await _loadEpisodes(_seasons[0].id);
          WidgetsBinding.instance.addPostFrameCallback((_) => _seasonsFocusNodes[0]?.requestFocus());
        }
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _errorMessage = e.toString(); });
    }
  }

  Future<void> _loadEpisodes(String seasonId) async {
    if (_episodesMap.containsKey(seasonId)) {
      setState(() {
        _selectedSeasonIndex = _seasons.indexWhere((s) => s.id == seasonId);
        _selectedEpisodeIndex = 0;
      });
      _setNavigationMode(NavigationMode.episodes);
      return;
    }
    setState(() => _isLoadingEpisodes = true);
    try {
      final episodes = await widget.fetchEpisodes(seasonId);
      if (mounted) {
        for (var ep in episodes) { _episodeFocusNodes[ep.id] = FocusNode(); }
        setState(() {
          _episodesMap[seasonId] = episodes;
          _selectedSeasonIndex = _seasons.indexWhere((s) => s.id == seasonId);
          _selectedEpisodeIndex = 0;
          _isLoadingEpisodes = false;
        });
        _setNavigationMode(NavigationMode.episodes);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingEpisodes = false);
    }
  }

  // ✅ PLAN VERIFICATION (Yahan rahega taaki har calling page ko baar baar check na karna pade)
  Future<bool> _verifyPlanStatusLocally() async {
    final String? authKey = SessionManager.authKey;
    if (authKey == null || authKey.isEmpty) return true; 
    try {
      var url = Uri.parse(SessionManager.baseUrl + 'checkExpiryPlan');
      final response = await https.get(url, headers: {'auth-key': authKey, 'Content-Type': 'application/json', 'domain': SessionManager.savedDomain}).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        final expireValue = res['plan_expired'].toString().toLowerCase();
        if (expireValue == 'true' || expireValue == '1') {
          if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => PlanExpiredScreen(apiMessage: res['message'] ?? 'Subscription Expired')), (route) => false);
          return false;
        }
      }
    } catch (e) { print(e); }
    return true; 
  }

  Future<void> _handleEpisodeTap(CommonEpisodeModel episode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    bool isPlanSafe = await _verifyPlanStatusLocally();
    if (!isPlanSafe) {
      if (mounted) setState(() => _isProcessing = false);
      return; 
    }
    
    // Calling page ko function transfer kiya
    await widget.onEpisodeTap(episode);
    
    if (mounted) setState(() => _isProcessing = false);
  }

  void _setNavigationMode(NavigationMode mode) {
    setState(() => _currentMode = mode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mode == NavigationMode.seasons) {
        _navigationModeController.reverse();
        _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
      } else {
        _navigationModeController.forward();
        if (_currentEpisodes.isNotEmpty) {
          _episodeFocusNodes[_currentEpisodes[_selectedEpisodeIndex].id]?.requestFocus();
        }
      }
    });
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (_isProcessing || event is! RawKeyDownEvent) return;
    if (_currentMode == NavigationMode.seasons) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown && _selectedSeasonIndex < _seasons.length - 1) {
        setState(() => _selectedSeasonIndex++); _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp && _selectedSeasonIndex > 0) {
        setState(() => _selectedSeasonIndex--); _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
      } else if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (_seasons.isNotEmpty) _loadEpisodes(_seasons[_selectedSeasonIndex].id);
      }
    } else {
      final episodes = _currentEpisodes;
      if (event.logicalKey == LogicalKeyboardKey.arrowDown && _selectedEpisodeIndex < episodes.length - 1) {
        setState(() => _selectedEpisodeIndex++); _scrollAndFocusEpisode(_selectedEpisodeIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp && _selectedEpisodeIndex > 0) {
        setState(() => _selectedEpisodeIndex--); _scrollAndFocusEpisode(_selectedEpisodeIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.select) {
        _handleEpisodeTap(episodes[_selectedEpisodeIndex]);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.escape) {
        _setNavigationMode(NavigationMode.seasons);
      }
    }
  }

  Future<void> _scrollAndFocusEpisode(int index) async {
    final node = _episodeFocusNodes[_currentEpisodes[index].id];
    if (node?.context != null) {
      await Scrollable.ensureVisible(node!.context!, duration: const Duration(milliseconds: 300), alignment: 0.5);
      node.requestFocus();
    }
  }

  List<CommonEpisodeModel> get _currentEpisodes {
    if (_seasons.isEmpty || _selectedSeasonIndex >= _seasons.length) return [];
    return _episodesMap[_seasons[_selectedSeasonIndex].id] ?? [];
  }

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
            // Background Layer
            Positioned.fill(child: widget.bannerUrl.isNotEmpty ? CachedNetworkImage(imageUrl: widget.bannerUrl, fit: BoxFit.cover, errorWidget: (c,e,s) => Container(color: const Color(0xFF1a1a2e))) : Container(color: const Color(0xFF1a1a2e))),
            Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.4), Colors.black.withOpacity(0.9)], begin: Alignment.topCenter, end: Alignment.bottomCenter)))),
            
            // Header
            Positioned(top: 0, left: 0, right: 0, height: 100, child: Center(child: Text(widget.showName.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5)))),
            
            // Main Content
            Positioned(
              top: 100, left: 0, right: 0, bottom: 20,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _isLoading 
                    ? const Center(child: SpinKitFadingCircle(color: Colors.blue, size: 50))
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(children: [Expanded(flex: 3, child: _buildSeasonsPanel()), const SizedBox(width: 20), Expanded(flex: 5, child: _buildEpisodesPanel())]),
                      ),
                ),
              ),
            ),
            
            if (_isProcessing) Container(color: Colors.black54, child: const Center(child: SpinKitPulse(color: Colors.green, size: 80)))
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonsPanel() {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: _currentMode == NavigationMode.seasons ? Colors.blue.withOpacity(0.5) : Colors.white10, width: 2)),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.2), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: const BorderRadius.vertical(top: Radius.circular(14))), child: Row(children: [const Icon(Icons.list_alt, color: Colors.blue), const SizedBox(width: 12), const Text("SEASONS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const Spacer(), Text('${_seasons.length}', style: const TextStyle(color: Colors.blue))])),
        Expanded(child: ListView.builder(controller: _seasonsScrollController, itemCount: _seasons.length, itemBuilder: (context, index) {
          final season = _seasons[index];
          final isFocused = _currentMode == NavigationMode.seasons && index == _selectedSeasonIndex;
          return GestureDetector(
            onTap: () => _loadEpisodes(season.id),
            child: Focus(
              focusNode: _seasonsFocusNodes[index],
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: isFocused ? Colors.blue.withOpacity(0.2) : Colors.grey[900]?.withOpacity(0.4), borderRadius: BorderRadius.circular(12), border: isFocused ? Border.all(color: Colors.blue) : null),
                child: Row(children: [
                  CircleAvatar(backgroundColor: Colors.blue, child: Text("S${season.order}", style: const TextStyle(color: Colors.white))),
                  const SizedBox(width: 16),
                  Expanded(child: Text(season.title, style: TextStyle(color: isFocused ? Colors.blue : Colors.white, fontWeight: FontWeight.bold))),
                ]),
              ),
            ),
          );
        })),
      ]),
    );
  }

  Widget _buildEpisodesPanel() {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: _currentMode == NavigationMode.episodes ? Colors.green.withOpacity(0.5) : Colors.white10, width: 2)),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green.withOpacity(0.2), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: const BorderRadius.vertical(top: Radius.circular(14))), child: Row(children: [const Icon(Icons.play_circle_outline, color: Colors.green), const SizedBox(width: 12), const Text("EPISODES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const Spacer(), Text('${_currentEpisodes.length}', style: const TextStyle(color: Colors.green))])),
        Expanded(child: _isLoadingEpisodes ? const Center(child: SpinKitFadingCircle(color: Colors.green, size: 50)) : _buildEpisodesList()),
      ]),
    );
  }

  Widget _buildEpisodesList() {
    if (_currentEpisodes.isEmpty) return const Center(child: Text("No Episodes Found", style: TextStyle(color: Colors.white54)));
    return ListView.builder(controller: _scrollController, itemCount: _currentEpisodes.length, itemBuilder: (context, index) {
      final ep = _currentEpisodes[index];
      final isFocused = _currentMode == NavigationMode.episodes && index == _selectedEpisodeIndex;
      return GestureDetector(
        onTap: () => _handleEpisodeTap(ep),
        child: Focus(
          focusNode: _episodeFocusNodes[ep.id],
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(color: isFocused ? Colors.green.withOpacity(0.2) : Colors.grey[900]?.withOpacity(0.4), borderRadius: BorderRadius.circular(16), border: isFocused ? Border.all(color: Colors.green) : null),
            child: Row(children: [
              Container(margin: const EdgeInsets.all(12), width: 140, height: 90, child: ClipRRect(borderRadius: BorderRadius.circular(12), child: ep.imageUrl.isNotEmpty ? CachedNetworkImage(imageUrl: ep.imageUrl, fit: BoxFit.cover, errorWidget: (c,u,e) => Container(color: Colors.grey[850], child: const Icon(Icons.play_circle_outline, color: Colors.white24))) : Container(color: Colors.grey[850], child: const Icon(Icons.play_circle_outline, color: Colors.white24)))),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(ep.title, style: TextStyle(color: isFocused ? Colors.green : Colors.white, fontWeight: FontWeight.bold)), Text('Episode ${ep.order}', style: const TextStyle(color: Colors.white54, fontSize: 12))])),
              if (isFocused) const Padding(padding: EdgeInsets.only(right: 16.0), child: Icon(Icons.play_arrow, color: Colors.green, size: 32))
            ]),
          ),
        ),
      );
    });
  }
}