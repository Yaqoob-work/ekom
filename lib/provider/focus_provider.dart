// focus_provider.dart - Complete working code according to your structure
import 'package:flutter/material.dart';

class FocusProvider extends ChangeNotifier {
  // =================================================================
  // REFRESH STATE MANAGEMENT
  // =================================================================
  bool _shouldRefreshBanners = false;
  bool _shouldRefreshLastPlayed = false;
  String _refreshSource = '';

  // Getters
  bool get shouldRefreshBanners => _shouldRefreshBanners;
  bool get shouldRefreshLastPlayed => _shouldRefreshLastPlayed;
  String get refreshSource => _refreshSource;

  // Refresh banners
  void refreshBanners({String source = 'unknown'}) {
    _shouldRefreshBanners = true;
    _refreshSource = source;
    notifyListeners();
  }

  // Refresh last played videos
  void refreshLastPlayed({String source = 'unknown'}) {
    _shouldRefreshLastPlayed = true;
    _refreshSource = source;
    notifyListeners();
  }

  // Refresh both
  void refreshAll({String source = 'unknown'}) {
    _shouldRefreshBanners = true;
    _shouldRefreshLastPlayed = true;
    _refreshSource = source;
    notifyListeners();
  }

  // Reset flags after refresh is done
  void markBannersRefreshed() {
    _shouldRefreshBanners = false;
    notifyListeners();
  }

  void markLastPlayedRefreshed() {
    _shouldRefreshLastPlayed = false;
    notifyListeners();
  }

  void markAllRefreshed() {
    _shouldRefreshBanners = false;
    _shouldRefreshLastPlayed = false;
    _refreshSource = '';
    notifyListeners();
  }

  // =================================================================
  // SCROLL CONTROLLER AND FOCUS STATE
  // =================================================================
  final ScrollController scrollController = ScrollController();

  // Focus state variables
  bool _isButtonFocused = false;
  bool _isLastPlayedFocused = false;
  bool _isVodfirstbannerFocussed = false;
  int _focusedVideoIndex = -1;
  Color? _currentFocusColor;

  // Store global keys for elements that need scrolling
  final Map<String, GlobalKey> _elementKeys = {};

  // Getters
  bool get isButtonFocused => _isButtonFocused;
  bool get isLastPlayedFocused => _isLastPlayedFocused;
  bool get isVodfirstbannerFocussed => _isVodfirstbannerFocussed;
  int get focusedVideoIndex => _focusedVideoIndex;
  Color? get currentFocusColor => _currentFocusColor;

  // =================================================================
  // FOCUS NODES DECLARATIONS
  // =================================================================
  FocusNode? watchNowFocusNode;
  FocusNode? firstLastPlayedFocusNode;
  FocusNode? firstMusicItemFocusNode;
  FocusNode? firstSubVodFocusNode;
  FocusNode? _firstLastPlayedFocusNode;
  FocusNode? _firstSubVodFocusNode;
  // FocusNode? _homeCategoryFirstItemFocusNode;
  FocusNode? _firstManageMoviesFocusNode;
  FocusNode? _firstManageWebseriesFocusNode;
  FocusNode? _searchIconFocusNode;
  FocusNode? _youtubeSearchIconFocusNode;
  FocusNode? _searchNavigationFocusNode;
  FocusNode? _youtubeSearchNavigationFocusNode;
  // FocusNode? _homeCategoryFirstBannerFocusNode;
  FocusNode? _firstMusicItemFocusNode;
  FocusNode? _newsItemFocusNode;
  FocusNode? firstItemFocusNode;
  FocusNode? _liveTvFocusNode;
  FocusNode? _VodMenuFocusNode;
  FocusNode? firstVodBannerFocusNode;
  FocusNode? topNavigationFocusNode;
  FocusNode? middleNavigationFocusNode;


int _currentSelectedNavIndex = 0;

    void setCurrentSelectedNavIndex(int index) {
    _currentSelectedNavIndex = index;
    notifyListeners();
    print('✅ Current selected nav index set to: $index');
  }

  int get currentSelectedNavIndex => _currentSelectedNavIndex;

  // ✅ NEW: Request focus to current selected navigation's first channel
  void requestCurrentNavFirstChannelFocus() {
    if (_channelFirstFocusNodes.containsKey(_currentSelectedNavIndex)) {
      _channelFirstFocusNodes[_currentSelectedNavIndex]?.requestFocus();
      scrollToElement('subLiveScreen');
      notifyListeners();
      print('✅ Focusing first channel for current nav index: $_currentSelectedNavIndex');
    } else {
      print('❌ No first channel focus found for current nav index: $_currentSelectedNavIndex');
    }
  }

  // News Channels Focus Nodes (NEW)
  FocusNode? _firstNewsChannelFocusNode;
  FocusNode? _newsChannelsViewAllFocusNode;
  ScrollController? _newsChannelsScrollController;

  void setFirstNewsChannelFocusNode(FocusNode node) {
    _firstNewsChannelFocusNode = node;
    notifyListeners();
  }

  void requestFirstNewsChannelFocus() {
    if (_firstNewsChannelFocusNode != null) {
      _firstNewsChannelFocusNode!.requestFocus();
      notifyListeners();
      scrollToElement('subLiveScreen');
    }
  }

  void requestNewsChannelsFocus() {
    requestFirstNewsChannelFocus();
  }

  // News Channels Focus Nodes (NEW)
  FocusNode? _firstMusicChannelFocusNode;
  FocusNode? _musicChannelsViewAllFocusNode;
  ScrollController? _musicChannelsScrollController;

  // =================================================================
  // NEWS CHANNELS METHODS (NEW)
  // =================================================================
  void setFirstMusicChannelFocusNode(FocusNode node) {
    _firstMusicChannelFocusNode = node;
    notifyListeners();
  }

  // =================================================================
  // SCROLL CONTROLLERS MANAGEMENT
  // =================================================================
  ScrollController? _moviesScrollController;
  ScrollController? _webseriesScrollController;
  Map<String, ScrollController> _webseriesScrollControllers = {};

  void setMoviesScrollController(ScrollController controller) {
    _moviesScrollController = controller;
  }

  void setwebseriesScrollController(ScrollController controller) {
    _webseriesScrollController = controller;
  }

  void setWebseriesScrollControllers(
      Map<String, ScrollController> controllers) {
    _webseriesScrollControllers = controllers;
    notifyListeners();
  }

  void scrollWebseriesToFirst(String categoryId) {
    final controller = _webseriesScrollControllers[categoryId];
    if (controller != null && controller.hasClients) {
      controller.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToFirstMovieItem() {
    if (_moviesScrollController != null &&
        _moviesScrollController!.hasClients) {
      _moviesScrollController!.animateTo(
        0.02,
        duration: Duration(milliseconds: 800),
        curve: Curves.linear,
      );
    }
  }

  // =================================================================
  // MOVIES METHODS
  // =================================================================
  void setFirstManageMoviesFocusNode(FocusNode node) {
    _firstManageMoviesFocusNode = node;
    notifyListeners();
  }

  void requestFirstMoviesFocus() {
    if (_firstManageMoviesFocusNode != null) {
      _scrollToFirstMovieItem();
      Future.delayed(const Duration(milliseconds: 50), () {
        _firstManageMoviesFocusNode!.requestFocus();
        scrollToElement('manageMovies');
        Future.delayed(const Duration(milliseconds: 50), () {
          scrollToElement('manageMovies');
        });
      });
    }
  }

  void requestMoviesFocus() {
    requestFirstMoviesFocus();
  }

  // =================================================================
  // WEB SERIES METHODS
  // =================================================================
  // bool _webseriesFocusPrepared = false;

  // void prepareWebseriesFocus() {
  //   _webseriesFocusPrepared = true;
  //   notifyListeners();
  // }

  void setFirstManageWebseriesFocusNode(FocusNode node) {
    _firstManageWebseriesFocusNode = node;
    notifyListeners();
  }

  void requestFirstWebseriesFocus() {
    if (_firstManageWebseriesFocusNode != null) {
      Future.delayed(const Duration(milliseconds: 50), () {
        _firstManageWebseriesFocusNode!.requestFocus();
        scrollToElement('manageWebseries');
        Future.delayed(const Duration(milliseconds: 50), () {
          scrollToElement('manageWebseries');
        });
      });
    }
  }

  // =================================================================
  // SEARCH METHODS
  // =================================================================
  void setSearchIconFocusNode(FocusNode focusNode) {
    _searchIconFocusNode = focusNode;
  }

  void requestSearchIconFocus() {
    if (_searchIconFocusNode != null && _searchIconFocusNode!.canRequestFocus) {
      _searchIconFocusNode!.requestFocus();
    }
  }

  void setYoutubeSearchIconFocusNode(FocusNode focusNode) {
    _youtubeSearchIconFocusNode = focusNode;
  }

  void requestYoutubeSearchIconFocus() {
    if (_youtubeSearchIconFocusNode != null &&
        _youtubeSearchIconFocusNode!.canRequestFocus) {
      _youtubeSearchIconFocusNode!.requestFocus();
    }
  }

  void setSearchNavigationFocusNode(FocusNode node) {
    _searchNavigationFocusNode = node;
  }

  void requestSearchNavigationFocus() {
    _searchNavigationFocusNode?.requestFocus();
  }

  void setYoutubeSearchNavigationFocusNode(FocusNode node) {
    _youtubeSearchNavigationFocusNode = node;
  }

  void requestYoutubeSearchNavigationFocus() {
    _youtubeSearchNavigationFocusNode?.requestFocus();
  }

  // =================================================================
  // ELEMENT KEYS MANAGEMENT
  // =================================================================
  void registerElementKey(String identifier, GlobalKey key) {
    final bool isNewKey = _elementKeys[identifier] != key;
    _elementKeys[identifier] = key;
    if (isNewKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void unregisterElementKey(String identifier) {
    _elementKeys.remove(identifier);
    notifyListeners();
  }

  void scrollToElement(String identifier) {
    final key = _elementKeys[identifier];
    if (key?.currentContext == null) {
      return;
    }
    final BuildContext? context = key?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.01,
        duration: const Duration(milliseconds: 800),
        curve: Curves.linear,
      );
    }
  }

  void requestMusicItemFocusSimple() {
    if (firstMusicItemFocusNode != null) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (firstMusicItemFocusNode!.canRequestFocus) {
          firstMusicItemFocusNode!.requestFocus();
          scrollToElement('subLiveScreen');
        }
      });
    }
  }

  void resetFocus() {
    _isButtonFocused = false;
    _isLastPlayedFocused = false;
    _focusedVideoIndex = -1;
    _currentFocusColor = null;
    notifyListeners();
  }

  // =================================================================
  // LIVE SCREEN METHODS
  // =================================================================
  void setLiveScreenFocusNode(FocusNode node) {
    firstItemFocusNode = node;
  }

  void requestLiveScreenFocus() {
    if (firstItemFocusNode != null) {
      firstItemFocusNode!.requestFocus();
      if (firstItemFocusNode != null) {
        setLiveScreenFocusNode(firstItemFocusNode!);
      }
    }
  }

  void setLiveTvFocusNode(FocusNode node) {
    _liveTvFocusNode = node;
  }

  void requestLiveTvFocus() {
    _liveTvFocusNode?.requestFocus();
  }

  void setVodMenuFocusNode(FocusNode node) {
    _VodMenuFocusNode = node;
  }

  void requestVodMenuFocus() {
    _VodMenuFocusNode?.requestFocus();
  }

  // =================================================================
  // BANNER/WATCH NOW METHODS
  // =================================================================
  void setWatchNowFocusNode(FocusNode node) {
    watchNowFocusNode = node;
    node.addListener(() {
      if (node.hasFocus) {
        scrollToElement('watchNow');
      }
    });
  }

  void requestWatchNowFocus() {
    if (watchNowFocusNode != null) {
      watchNowFocusNode!.requestFocus();
      setButtonFocus(true);
      scrollToElement('watchNow');
    }
  }

  void setButtonFocus(bool focused, {Color? color}) {
    _isButtonFocused = focused;
    if (focused) {
      _currentFocusColor = color;
      _isLastPlayedFocused = false;
      _focusedVideoIndex = -1;
    }
    notifyListeners();
  }

  void setFirstVodBannerFocusNode(FocusNode node) {
    firstVodBannerFocusNode = node;
    node.addListener(() {
      // Optional scroll behavior
    });
  }

  void requestVodBannerFocus() {
    if (firstVodBannerFocusNode != null) {
      firstVodBannerFocusNode!.requestFocus();
    }
  }

  void setTopNavigationFocusNode(FocusNode node) {
    topNavigationFocusNode = node;
  }

  void requestTopNavigationFocus() {
    if (topNavigationFocusNode != null) {
      topNavigationFocusNode!.requestFocus();
      setTopNavigationFocusNode(topNavigationFocusNode!);
    }
  }

  void setMiddleNavigationFocusNode(FocusNode node) {
    middleNavigationFocusNode = node;
  }

  void requestMiddleNavigationFocus() {
    if (middleNavigationFocusNode != null) {
      middleNavigationFocusNode!.requestFocus();
      setMiddleNavigationFocusNode(middleNavigationFocusNode!);
    }
  }

  // FocusProvider में ये methods add/update करें:

// ✅ Live TV specific focus node
  FocusNode? _liveChannelsFocusNode;

// ✅ Set Live channels focus node
  void setLiveChannelsFocusNode(FocusNode node) {
    _liveChannelsFocusNode = node;
    notifyListeners();
    print('✅ Live channels focus node registered');
  }

// ✅ Request Live channels focus
  void requestLiveChannelsFocus() {
    if (_liveChannelsFocusNode != null) {
      _liveChannelsFocusNode!.requestFocus();
      scrollToElement('subLiveScreen');
      notifyListeners();
      print('✅ Live channels focus requested');
    } else {
      print('❌ Live channels focus node not found');
    }
  }

  // ✅ 5. GENERIC: Request any page's first channel focus
  void requestFirstChannelFocus(int navIndex) {
    if (_channelFirstFocusNodes.containsKey(navIndex)) {
      _channelFirstFocusNodes[navIndex]?.requestFocus();
      scrollToElement('subLiveScreen');
      notifyListeners();
      print('✅ Focusing first channel for index: $navIndex');
    } else {
      print('❌ First channel focus failed for index: $navIndex');
    }
  }

  // =================================================================
  // SUB VOD METHODS
  // =================================================================
  BuildContext? _subVodContext;

  void setFirstSubVodFocusNode(FocusNode node) {
    firstSubVodFocusNode = node;
    node.addListener(() {
      if (node.hasFocus) {
        scrollToElement('subVod');
      }
    });
  }

  void setSubVodContext(BuildContext context) {
    _subVodContext = context;
  }

  void requestSubVodFocus() {
    if (firstSubVodFocusNode != null) {
      firstSubVodFocusNode!.requestFocus();
      setVodFirstBannerFocus(true);
      Future.delayed(Duration(milliseconds: 50), () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (firstSubVodFocusNode!.canRequestFocus) {
            firstSubVodFocusNode!.requestFocus();
          }
        });
      });
      scrollToElement('subVod');
    }
  }

  void setVodFirstBannerFocus(bool focused) {
    _isVodfirstbannerFocussed = focused;
    notifyListeners();
  }

  void requestFirstSubVodFocus() {
    if (firstSubVodFocusNode != null) {
      firstSubVodFocusNode!.requestFocus();
      setFirstSubVodFocusNode(firstSubVodFocusNode!);
      Future.delayed(Duration(milliseconds: 100), () {
        firstSubVodFocusNode!.requestFocus();
      });
      scrollToElement('subVod');
    }
  }

  // =================================================================
  // NAVIGATION HELPERS (SIMPLIFIED)
  // =================================================================
  void navigateUpSimple() {
    if (_firstNewsChannelFocusNode?.hasFocus == true) {
      requestMoviesFocus();
    } else if (_firstManageMoviesFocusNode?.hasFocus == true) {
      // requestSubVodFocus();
      requestFirstHorizontalListNetworksFocus();
    } else if (firstSubVodFocusNode?.hasFocus == true) {
      requestMusicItemFocusSimple();
    } else if (firstMusicItemFocusNode?.hasFocus == true) {
      requestWatchNowFocus();
    }
  }

  void navigateDownSimple() {
    if (watchNowFocusNode?.hasFocus == true) {
      requestMusicItemFocusSimple();
    } else if (firstMusicItemFocusNode?.hasFocus == true) {
      // requestSubVodFocus();
      requestFirstHorizontalListNetworksFocus();
    } else if (firstSubVodFocusNode?.hasFocus == true) {
      requestMoviesFocus();
    } else if (_firstManageMoviesFocusNode?.hasFocus == true) {
      requestNewsChannelsFocus();
    } else if (_firstNewsChannelFocusNode?.hasFocus == true) {
      requestFirstWebseriesFocus();
    }
  }

  List<FocusNode>? _middleNavigationFocusNodes;
  Map<int, FocusNode> _channelFirstFocusNodes = {};
  Map<int, ScrollController> _channelScrollControllers = {};
  Map<int, FocusNode> _viewAllFocusNodes = {};

  // ✅ 1. Set middle navigation focus nodes
  void setMiddleNavigationFocusNodes(List<FocusNode> nodes) {
    _middleNavigationFocusNodes = nodes;
    notifyListeners();
  }

  // ✅ 2. GENERIC: Register any page's channel focus
  void registerGenericChannelFocus(int navIndex,
      ScrollController scrollController, FocusNode firstChannelNode) {
    _channelScrollControllers[navIndex] = scrollController;
    _channelFirstFocusNodes[navIndex] = firstChannelNode;
    notifyListeners();
    print('✅ Registered generic focus for index: $navIndex');
  }

  // ✅ 3. GENERIC: Register ViewAll focus node
  void registerViewAllFocusNode(int navIndex, FocusNode viewAllNode) {
    _viewAllFocusNodes[navIndex] = viewAllNode;
    notifyListeners();
  }

  // ✅ 4. GENERIC: Request focus for any navigation index
  void requestNavigationFocus(int navIndex) {
    if (_middleNavigationFocusNodes != null &&
        navIndex >= 0 &&
        navIndex < _middleNavigationFocusNodes!.length) {
      _middleNavigationFocusNodes![navIndex].requestFocus();
      print('✅ Focusing navigation index: $navIndex');
    } else {
      print('❌ Navigation focus failed for index: $navIndex');
    }
  }

  FocusNode? _firstTVShowsFocusNode;
  // ✅ TV Shows functions (नए)
  void setFirstTVShowsFocusNode(FocusNode focusNode) {
    _firstTVShowsFocusNode = focusNode;
  }

  void requestFirstTVShowsFocus() {
    if (_firstTVShowsFocusNode != null &&
        _firstTVShowsFocusNode!.context != null) {
      _firstTVShowsFocusNode!.requestFocus();
      print('✅ TV Shows first focus requested');
      scrollToElement('tvShows');
    }

  }

  FocusNode? _firstHorizontalListNetworksFocusNode;
  // ✅ TV Shows functions (नए)
  void setFirstHorizontalListNetworksFocusNode(FocusNode focusNode) {
    _firstHorizontalListNetworksFocusNode = focusNode;
  }

  void requestFirstHorizontalListNetworksFocus() {
    if (_firstHorizontalListNetworksFocusNode != null &&
        _firstHorizontalListNetworksFocusNode!.context != null) {
      _firstHorizontalListNetworksFocusNode!.requestFocus();
      print('✅ TV Shows first focus requested');
      scrollToElement('subVod');

    }
  }

  // =================================================================
  // DISPOSE METHOD
  // =================================================================
  @override
  void dispose() {
    scrollController.dispose();
    watchNowFocusNode?.dispose();
    firstLastPlayedFocusNode?.dispose();
    firstMusicItemFocusNode?.dispose();
    firstSubVodFocusNode?.dispose();
    _firstManageMoviesFocusNode?.dispose();
    _firstManageWebseriesFocusNode?.dispose();
    _firstNewsChannelFocusNode?.dispose();
    _newsChannelsViewAllFocusNode?.dispose();
    super.dispose();
  }
}

// class FocusProvider extends ChangeNotifier {
  // =================================================================
  // NEWS CHANNELS METHODS (NEW)
  // =================================================================

  // void setNewsChannelsViewAllFocusNode(FocusNode node) {
  //   _newsChannelsViewAllFocusNode = node;
  //   notifyListeners();
  // }

  // void setNewsChannelsScrollController(ScrollController controller) {
  //   _newsChannelsScrollController = controller;
  // }

  // void requestNewsChannelsViewAllFocus() {
  //   if (_newsChannelsViewAllFocusNode != null) {
  //     _newsChannelsViewAllFocusNode!.requestFocus();
  //     notifyListeners();
  //   }
  // }

  // void setMusicChannelsViewAllFocusNode(FocusNode node) {
  //   _musicChannelsViewAllFocusNode = node;
  //   notifyListeners();
  // }

  // void setMusicChannelsScrollController(ScrollController controller) {
  //   _musicChannelsScrollController = controller;
  // }

  // void requestFirstMusicChannelFocus() {
  //   if (_firstMusicChannelFocusNode != null) {
  //     _firstMusicChannelFocusNode!.requestFocus();
  //     notifyListeners();
  //     scrollToElement('subLiveScreen');
  //   }
  // }

  // void requestMusicChannelsViewAllFocus() {
  //   if (_musicChannelsViewAllFocusNode != null) {
  //     _musicChannelsViewAllFocusNode!.requestFocus();
  //     notifyListeners();
  //   }
  // }

  // void requestMusicChannelsFocus() {
  //   requestFirstMusicChannelFocus();
  // }

  // =================================================================
  // LAST PLAYED METHODS
  // =================================================================
  // void setFirstLastPlayedFocusNode(FocusNode node) {
  //   _firstLastPlayedFocusNode = node;
  // }

  // void requestFirstLastPlayedFocus() {
  //   _firstLastPlayedFocusNode?.requestFocus();
  //   notifyListeners();
  // }

  // void requestLastPlayedFocus() {
  //   if (firstLastPlayedFocusNode != null) {
  //     firstLastPlayedFocusNode!.requestFocus();
  //     setLastPlayedFocus(0);
  //     scrollToElement('lastPlayed');
  //   }
  // }

  // void requestWebSeriesFocus() {
  //   requestFirstWebseriesFocus();
  // }

  // void clearWebseriesFocus() {
  //   _firstManageWebseriesFocusNode = null;
  //   _webseriesFocusPrepared = false;
  // }

  // =================================================================
  // MUSIC/SUB LIVE METHODS
  // =================================================================
  // FocusNode? getFirstMusicItemFocusNode() {
  //   return _firstMusicItemFocusNode;
  // }

  // void setFirstMusicItemFocusNode(FocusNode node) {
  //   firstMusicItemFocusNode = node;
  //   node.addListener(() {
  //     if (node.hasFocus) {
  //       scrollToElement('subLiveScreen');
  //     }
  //   });
  //   notifyListeners();
  // }

  // void requestMusicItemFocus(BuildContext context) {
  //   if (firstMusicItemFocusNode != null) {
  //     Future.delayed(Duration(milliseconds: 100), () {
  //       if (firstMusicItemFocusNode!.canRequestFocus) {
  //         firstMusicItemFocusNode!.requestFocus();
  //         scrollToElement('subLiveScreen');
  //       }
  //     });
  //   }
  // }

  // =================================================================
  // NEWS ITEMS METHODS
  // =================================================================
  // final Map<String, FocusNode> _newsItemFocusNodes = {};
  // String? _firstNewsItemId;

  // void requestNewsItemFocusNode(FocusNode focusNode) {
  //   if (focusNode.canRequestFocus) {
  //     focusNode.requestFocus();
  //   }
  // }

  // void registerNewsItemFocusNode(String id, FocusNode node) {
  //   _newsItemFocusNodes[id] = node;
  //   _firstNewsItemId ??= id;
  //   notifyListeners();
  // }

  // FocusNode? getNewsItemFocusNode(String id) {
  //   return _newsItemFocusNodes[id];
  // }

  // FocusNode? getFirstNewsItemFocusNode() {
  //   if (_firstNewsItemId != null) {
  //     return _newsItemFocusNodes[_firstNewsItemId];
  //   }
  //   return null;
  // }

  // void unregisterNewsItemFocusNode(String id) {
  //   _newsItemFocusNodes.remove(id);
  //   notifyListeners();
  // }

  // void requestNewsItemFocus() {
  //   if (_newsItemFocusNode?.context != null) {
  //     _newsItemFocusNode?.requestFocus();
  //   }
  // }

// // ✅ Updated generic method to handle Live (index 0)
// void requestFirstChannelFocus(int navIndex) {
//   if (navIndex == 0) {
//     // Special handling for Live page
//     requestLiveChannelsFocus();
//     return;
//   }

//   if (_channelFirstFocusNodes.containsKey(navIndex)) {
//     _channelFirstFocusNodes[navIndex]?.requestFocus();
//     scrollToElement('subLiveScreen');
//     notifyListeners();
//     print('✅ Focusing first channel for index: $navIndex');
//   } else {
//     print('❌ First channel focus failed for index: $navIndex');
//   }
// }

  // Live TV related focus nodes
  // FocusNode? _liveTvNavigationFocusNode;

  // // Navigation focus nodes for other sections
  // FocusNode? _newsNavigationFocusNode;
  // FocusNode? _sportsNavigationFocusNode;
  // FocusNode? _religiousNavigationFocusNode;
  // FocusNode? _moreNavigationFocusNode;

  // void setLiveTvFocusNode(FocusNode node) {
  //   _liveTvNavigationFocusNode = node;
  // }

  // void setNewsNavigationFocusNode(FocusNode node) {
  //   _newsNavigationFocusNode = node;
  // }

  // void setSportsNavigationFocusNode(FocusNode node) {
  //   _sportsNavigationFocusNode = node;
  // }

  // void setReligiousNavigationFocusNode(FocusNode node) {
  //   _religiousNavigationFocusNode = node;
  // }

  // void setMoreNavigationFocusNode(FocusNode node) {
  //   _moreNavigationFocusNode = node;
  // }

  // void requestSportsContentFocus() {
  //   // Add your sports content focus logic
  // }

  // void requestReligiousContentFocus() {
  //   // Add your religious content focus logic
  // }

  // void forceSubVodFocus() {
  //   if (firstSubVodFocusNode == null) {
  //     return;
  //   }
  //   firstSubVodFocusNode!.requestFocus();
  //   Future.delayed(Duration(milliseconds: 100), () {
  //     if (!firstSubVodFocusNode!.hasFocus) {
  //       firstSubVodFocusNode!.requestFocus();
  //     }
  //   });
  //   Future.delayed(Duration(milliseconds: 200), () {
  //     if (!firstSubVodFocusNode!.hasFocus && _subVodContext != null) {
  //       FocusScope.of(_subVodContext!).requestFocus(firstSubVodFocusNode!);
  //     }
  //   });
  // }

  // void forceSubVodFocusWithContext(BuildContext context) {
  //   if (firstSubVodFocusNode == null) {
  //     return;
  //   }
  //   FocusScope.of(context).unfocus();
  //   Future.delayed(Duration(milliseconds: 50), () {
  //     FocusScope.of(context).requestFocus(firstSubVodFocusNode!);
  //     Future.delayed(Duration(milliseconds: 100), () {
  //       // Success callback if needed
  //     });
  //   });
  // }

  // void nuclearSubVodFocus(BuildContext context) {
  //   if (firstSubVodFocusNode == null) {
  //     return;
  //   }
  //   FocusScope.of(context).unfocus();
  //   Future.delayed(Duration(milliseconds: 100), () {
  //     FocusScope.of(context).requestFocus(firstSubVodFocusNode!);
  //     Future.delayed(Duration(milliseconds: 50), () {
  //       firstSubVodFocusNode!.requestFocus();
  //       Future.delayed(Duration(milliseconds: 50), () {
  //         if (!firstSubVodFocusNode!.hasFocus) {
  //           firstSubVodFocusNode!.requestFocus();
  //         }
  //         Future.delayed(Duration(milliseconds: 100), () {
  //           // Final verification
  //         });
  //       });
  //     });
  //   });
  // }

  // FocusNode? getFirstSubVodFocusNode() {
  //   return _firstSubVodFocusNode;
  // }

  // =================================================================
  // FOCUS STATE MANAGEMENT
  // =================================================================

  // void setLastPlayedFocus(int index) {
  //   _isLastPlayedFocused = true;
  //   _focusedVideoIndex = index;
  //   _isButtonFocused = false;
  //   notifyListeners();
  // }



  // void updateFocusColor(Color color) {
  //   _currentFocusColor = color;
  //   notifyListeners();
  // }

  // =================================================================
  // CATEGORY COUNT MANAGEMENT
  // =================================================================
  // int _categoryCountMovies = 0;
  // int _categoryCountWebseries = 0;
  // double _totalHeightMovies = 0.0;
  // double _totalHeightWebseries = 0.0;

  // int get categoryCount => _categoryCountMovies;
  // double get totalHeight => _totalHeightMovies;
  // int get categoryCountWebseries => _categoryCountWebseries;
  // double get totalHeightWebseries => _totalHeightWebseries;

  // void updateCategoryCountMovies(int count) {
  //   _categoryCountMovies = count;
  //   notifyListeners();
  // }

  // void updateCategoryCountWebseries(int count) {
  //   _categoryCountWebseries = count;
  //   notifyListeners();
  // }

//   // ✅ 6. Keep existing specific methods for backward compatibility
//   void requestMusicNavigationFocus() => requestNavigationFocus(2);
//   void requestNewsNavigationFocus() => requestNavigationFocus(4);
//   void requestMovieNavigationFocus() => requestNavigationFocus(3);
//   void requestEntertainmentNavigationFocus() => requestNavigationFocus(1);
//   void requestSportsNavigationFocus() => requestNavigationFocus(5);
//   void requestReligiousNavigationFocus() => requestNavigationFocus(6);
//   void requestLiveNavigationFocus() => requestNavigationFocus(0);

//   // ✅ 7. Enhanced specific channel focus methods
//   void requestEntertainmentChannelsFocus() => requestFirstChannelFocus(1);
//   void requestMovieChannelsFocus() => requestFirstChannelFocus(3);
//   void requestSportsChannelsFocus() => requestFirstChannelFocus(5);
//   void requestReligiousChannelsFocus() => requestFirstChannelFocus(6);

//   // ✅ DEBUGGING HELPER - Add this method in FocusProvider for testing
// // focus_provider.dart में add करें:

// void testWebseriesFocus() {
//   print('🔍 Testing webseries focus...');
//   print('First webseries focus node: $_firstManageWebseriesFocusNode');
//   if (_firstManageWebseriesFocusNode != null) {
//     print('Can request focus: ${_firstManageWebseriesFocusNode!.canRequestFocus}');
//     print('Has focus: ${_firstManageWebseriesFocusNode!.hasFocus}');
//     _firstManageWebseriesFocusNode!.requestFocus();
//     print('✅ Focus requested for webseries');
//   } else {
//     print('❌ No webseries focus node found');
//   }
// }
// }
