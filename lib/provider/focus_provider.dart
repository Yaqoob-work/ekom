





import 'package:flutter/material.dart';
import 'package:mobi_tv_entertainment/main.dart';

class FocusProvider extends ChangeNotifier {



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


  
  // ScrollController for managing scroll position
  final ScrollController scrollController = ScrollController();

  // Focus state variables
  bool _isButtonFocused = false;
  bool _isLastPlayedFocused = false;
  bool _isVodfirstbannerFocussed = false;
  int _focusedVideoIndex = -1;
  Color? _currentFocusColor;

  // Focus nodes for navigation
  FocusNode? watchNowFocusNode;
  FocusNode? firstLastPlayedFocusNode;
  FocusNode? firstMusicItemFocusNode;
  FocusNode? firstSubVodFocusNode;

  // Store global keys for elements that need scrolling
  final Map<String, GlobalKey> _elementKeys = {};

  // Getters
  bool get isButtonFocused => _isButtonFocused;
  bool get isLastPlayedFocused => _isLastPlayedFocused;
  bool get isVodfirstbannerFocussed => _isVodfirstbannerFocussed;
  int get focusedVideoIndex => _focusedVideoIndex;
  Color? get currentFocusColor => _currentFocusColor;

  // // Register element keys for scrolling
  // void registerElementKey(String identifier, GlobalKey key) {
  //   _elementKeys[identifier] = key;
  // }


  


  FocusNode? _firstLastPlayedFocusNode;

  void setFirstLastPlayedFocusNode(FocusNode node) {
    _firstLastPlayedFocusNode = node;
  }

  void requestFirstLastPlayedFocus() {
    _firstLastPlayedFocusNode?.requestFocus();
    notifyListeners();
  }



  



  FocusNode? _firstSubVodFocusNode;

 FocusNode? _homeCategoryFirstItemFocusNode;

  FocusNode? getHomeCategoryFirstItemFocusNode() => _homeCategoryFirstItemFocusNode;

  void setHomeCategoryFirstItemFocusNode(FocusNode focusNode) {
    _homeCategoryFirstItemFocusNode = focusNode;
    notifyListeners();
  }

  void requestHomeCategoryFirstItemFocus() {
    if (_homeCategoryFirstItemFocusNode != null) {
      _homeCategoryFirstItemFocusNode!.requestFocus();
    } else {
    }
  }


  // 4. FocusProvider में scroll functionality add करें
ScrollController? _moviesScrollController;

void setMoviesScrollController(ScrollController controller) {
  _moviesScrollController = controller;
}

void _scrollToFirstMovieItem() {
  if (_moviesScrollController != null && _moviesScrollController!.hasClients) {
    _moviesScrollController!.animateTo(
      0.02,
      duration: Duration(milliseconds: 800),
      curve: Curves.linear,
    );
  }
}
  // 4. FocusProvider में scroll functionality add करें  webseries
ScrollController? _webseriesScrollController;

void setwebseriesScrollController(ScrollController controller) {
  _webseriesScrollController = controller;
}

// void _scrolslToFirstwebseriesItem() {
//   if (_webseriesScrollController != null && _webseriesScrollController!.hasClients) {
//     _webseriesScrollController!.animateTo(
//       0.02,
//       duration: Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
// }



// 3. FocusProvider में ये method add करें (MusicScreen pattern follow करते हुए)
void requestFirstMoviesFocus() {
  if (_firstManageMoviesFocusNode != null) {
    // Pehle scroll करें first item को visible करने के लिए
    _scrollToFirstMovieItem();
    // Scroll के बाद focus request करें
    Future.delayed(const Duration(milliseconds: 50), () {
      _firstManageMoviesFocusNode!.requestFocus();
    scrollToElement('manageMovies');
      
      // Double ensure visibility
      Future.delayed(const Duration(milliseconds: 50), () {
    scrollToElement('manageMovies');

        // _scrollToFirstMovieItem();
      });
    });
  } else {
  }
}





// void requestManageMoviesFocusWithScroll() {
//   // Pehle scroll करें
//   if (_moviesScrollController?.hasClients == true) {
//     _moviesScrollController!.animateTo(0.0,
//       duration: Duration(milliseconds: 800),
//       curve: Curves.linear);
//   }
  
//   // Phir focus request करें
//   Future.delayed(Duration(milliseconds: 50), () {
//     _firstManageMoviesFocusNode?.requestFocus();
//   });
// }



// In your FocusProvider class, add this method:
Map<String, ScrollController> _webseriesScrollControllers = {};

void setWebseriesScrollControllers(Map<String, ScrollController> controllers) {
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






// void requestManageWebseriesFocusWithScroll() {
//   // Pehle scroll करें
//   if (_webseriesScrollController?.hasClients == true) {
//     _webseriesScrollController!.animateTo(0.0,
//       duration: Duration(milliseconds: 300),
//       curve: Curves.easeInOut);
//   }
  
//   // Phir focus request करें
//   Future.delayed(Duration(milliseconds: 150), () {
//     _firstManageWebseriesFocusNode?.requestFocus();
//   });
// }

  


  FocusNode? _firstManageMoviesFocusNode;
  FocusNode? _firstManageWebseriesFocusNode;
  bool _webseriesFocusPrepared = false;

  // Movies focus management
  void setFirstManageMoviesFocusNode(FocusNode node) {
    _firstManageMoviesFocusNode = node;
    notifyListeners();
  }

  // void requestManageMoviesFocus() {
  //   if (_firstManageMoviesFocusNode != null) {
  //     _firstManageMoviesFocusNode!.requestFocus();
  //   }
  // }


  

  // Webseries focus management
  void prepareWebseriesFocus() {
    _webseriesFocusPrepared = true;
    notifyListeners();
  }

  void setFirstManageWebseriesFocusNode(FocusNode node) {
    _firstManageWebseriesFocusNode = node;
    notifyListeners();
  }

  //   void requestFirstWebseriesFocus() {
  //   if (_firstManageWebseriesFocusNode != null) {
  //     _scrolslToFirstwebseriesItem(); 
  //     _firstManageWebseriesFocusNode!.requestFocus();
  //   } else {
  //   }
  // }



  // 3. FocusProvider में ये method add करें (MusicScreen pattern follow करते हुए)
void requestFirstWebseriesFocus() {
  if (_firstManageWebseriesFocusNode != null) {
    // Pehle scroll करें first item को visible करने के लिए
    // _scrolslToFirstwebseriesItem();
    
    // Scroll के बाद focus request करें
    Future.delayed(const Duration(milliseconds: 50), () {
      _firstManageWebseriesFocusNode!.requestFocus();
      
      // Double ensure visibility
      Future.delayed(const Duration(milliseconds: 50), () {
        // _scrolslToFirstwebseriesItem();
      });
    });
  } else {
  }
}







  

  // void requestFirstWebseriesFocus() {
  //   if (_firstManageWebseriesFocusNode != null) {
  //     _firstManageWebseriesFocusNode!.requestFocus();
  //   } 
  // }

  // Add this to clear focus nodes when not needed
  void clearWebseriesFocus() {
    _firstManageWebseriesFocusNode = null;
    _webseriesFocusPrepared = false;
  }







// // In FocusProvider:
// FocusNode? manageWebseriesFirstNode;
// void setFirstManageWebseriesFocusNode(FocusNode? node) {
//   manageWebseriesFirstNode = node;
// }
// void requestManageWebseriesFocus() {
//   // Try to request focus after a short delay so that widget is built
//   if (manageWebseriesFirstNode != null) {
//     Future.delayed(Duration(milliseconds: 30), () {
//       if (manageWebseriesFirstNode!.canRequestFocus) {
//         manageWebseriesFirstNode!.requestFocus();
//       }
//     });
//   }
// }



// // Add these to your existing FocusProvider class

// FocusNode? _firstManageWebseriesFocusNode;
// bool _isWebseriesReady = false;
// // final Map<String, GlobalKey> _elementKeys = {}; // This should already exist in your code

// // Set the first focus node for webseries
// void setFirstManageWebseriesFocusNode(FocusNode node) {
//   _firstManageWebseriesFocusNode?.dispose(); // Dispose old node if exists
//   _firstManageWebseriesFocusNode = node;

//   _isWebseriesReady = true;
//   notifyListeners();
// }

// // Request focus on webseries with retry logic
// void requestManageWebseriesFocus() {
//   if (_firstManageWebseriesFocusNode != null && 
//       _firstManageWebseriesFocusNode!.context != null) {
//     _firstManageWebseriesFocusNode!.requestFocus();
    

//     scrollToElement('manageWebseries');
//   } else {
//     _isWebseriesReady = false;
    
//     // Retry mechanism - removed 'mounted' check as it's not needed here
//     Future.delayed(Duration(milliseconds: 100), () {
//       if (!_isWebseriesReady) { // Removed 'mounted' check
//         requestManageWebseriesFocus();
//       }
//     });
//   }
// }



  FocusNode? _searchIconFocusNode;

  void setSearchIconFocusNode(FocusNode focusNode) {
    _searchIconFocusNode = focusNode;
  }

  void requestSearchIconFocus() {
    if (_searchIconFocusNode != null && _searchIconFocusNode!.canRequestFocus) {
      _searchIconFocusNode!.requestFocus();
    }
  }

  FocusNode? _youtubeSearchIconFocusNode;

  void setYoutubeSearchIconFocusNode(FocusNode focusNode) {
    _youtubeSearchIconFocusNode = focusNode;
  }

  void requestYoutubeSearchIconFocus() {
    if (_youtubeSearchIconFocusNode != null && _youtubeSearchIconFocusNode!.canRequestFocus) {
      _youtubeSearchIconFocusNode!.requestFocus();
    }
  }



    FocusNode? _searchNavigationFocusNode;

  void setSearchNavigationFocusNode(FocusNode node) {
    _searchNavigationFocusNode = node;
  }

  void requestSearchNavigationFocus() {
    _searchNavigationFocusNode?.requestFocus();
  }


  FocusNode? _youtubeSearchNavigationFocusNode;

  void setYoutubeSearchNavigationFocusNode(FocusNode node) {
    _youtubeSearchNavigationFocusNode = node;
  }

  void requestYoutubeSearchNavigationFocus() {
    _youtubeSearchNavigationFocusNode?.requestFocus();
  }


  // // In focus_provider.dart
  // void registerElementKey(String identifier, GlobalKey key) {
  //   _elementKeys[identifier] = key;
  //   notifyListeners();
  // }


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
  // Fetch the key from _elementKeys
  final key = _elementKeys[identifier];

  if (key?.currentContext == null) {
    return; // Exit early if key isn't valid
  }

  final BuildContext? context = key?.currentContext;
  if (context != null) {
    Scrollable.ensureVisible(
      context,
      alignment: 0.2, // Align the element at the top
      duration: const Duration(milliseconds: 800), // Animation duration
      curve: Curves.linear, // Smooth scrolling
    );
  } else {
  }
}



FocusNode? _homeCategoryFirstBannerFocusNode;

  void setHomeCategoryFirstBannerFocusNode(FocusNode focusNode) {
    _homeCategoryFirstBannerFocusNode = focusNode;
  }

  FocusNode? getHomeCategoryFirstBannerFocusNode() {
    return _homeCategoryFirstBannerFocusNode;
  }





 FocusNode? _firstMusicItemFocusNode;

  // Register focus node for the first music item
  // void setFirstMusicItemFocusNode(FocusNode focusNode) {
  //   _firstMusicItemFocusNode = focusNode;
  // }

  FocusNode? getFirstMusicItemFocusNode() {
    return _firstMusicItemFocusNode;
  }





    void setFirstMusicItemFocusNode(FocusNode node) {
      
    firstMusicItemFocusNode = node;
    node.addListener(() {
      if (node.hasFocus) {
        scrollToElement('subLiveScreen');
      }
    });
    notifyListeners();
  }



  // // Request focus for the first music item
  // void requestMusicItemFocuss(BuildContext context) {
  //   if (_firstMusicItemFocusNode != null) {
  //     FocusScope.of(context).requestFocus(_firstMusicItemFocusNode);
  //   }
  // }


  void requestMusicItemFocus(BuildContext context) {
  if (firstMusicItemFocusNode != null) {
    Future.delayed(Duration(milliseconds: 100), () {
      if (firstMusicItemFocusNode!.canRequestFocus) {
        firstMusicItemFocusNode!.requestFocus();
              // resetFocus();
      scrollToElement('subLiveScreen');
      } else {
      }
    });
  } else {
  }
}


  
  // void requestMusicItemFocus(BuildContext context) {
  //   if (firstMusicItemFocusNode != null) {
       
  //     firstMusicItemFocusNode!.requestFocus();
  //     // FocusScope.of(context).requestFocus(_firstMusicItemFocusNode);
  //     resetFocus();
  //     scrollToElement('musicItem');
  //   }
  // }


  



 void requestNewsItemFocusNode(FocusNode focusNode) {
    if (focusNode.canRequestFocus) {
      
      focusNode.requestFocus();
    }
  }



   // News items ke focus nodes store karne ke liye map
  final Map<String, FocusNode> _newsItemFocusNodes = {};

  // Pehla focus node ka ID store karne ke liye variable
  String? _firstNewsItemId;

  // Register news item focus node
  void registerNewsItemFocusNode(String id, FocusNode node) {
    _newsItemFocusNodes[id] = node;
    _firstNewsItemId ??= id; // Pehla item ID store karein
    notifyListeners();
  }

  // Get news item focus node
  FocusNode? getNewsItemFocusNode(String id) {
    return _newsItemFocusNodes[id];
  }

  // Get first news item focus node
  FocusNode? getFirstNewsItemFocusNode() {
    if (_firstNewsItemId != null) {
      return _newsItemFocusNodes[_firstNewsItemId];
    }
    return null;
  }

  // Remove a focus node (optional)
  void unregisterNewsItemFocusNode(String id) {
    _newsItemFocusNodes.remove(id);
    notifyListeners();
  }
  







 FocusNode? _newsItemFocusNode;

  // void registerNewsItemFocusNode(FocusNode node) {
  //   _newsItemFocusNode = node;
  //   notifyListeners(); 
  // }

  void requestNewsItemFocus() {
    if (_newsItemFocusNode?.context != null) {
      _newsItemFocusNode?.requestFocus();
    } else {
    }
  }

  

  FocusNode? firstItemFocusNode;

  // FocusProvider(FocusNode node) {
  //   liveScreenFocusNode = node;
  // }

  // void setLiveScreenFocusNode(FocusNode node) {
  //   liveScreenFocusNode = node;
  //   node.addListener(() {
  //     //   if (node.hasFocus) {
  //     //     scrollToElement('homeCategoryFirstBanner');
  //     //   }
  //   });
  // }

  // void requestLiveScreenFocus() {
  //   if (liveScreenFocusNode != null) {
  //     liveScreenFocusNode!.requestFocus();
  //     setLiveScreenFocusNode(liveScreenFocusNode!);
  //   }
  // }


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

  FocusNode? _liveTvFocusNode;

  void setLiveTvFocusNode(FocusNode node) {
    _liveTvFocusNode = node;
  }

  void requestLiveTvFocus() {
    _liveTvFocusNode?.requestFocus();
  }





  FocusNode? _VodMenuFocusNode;

  void setVodMenuFocusNode(FocusNode node) {
    _VodMenuFocusNode = node;
  }

  void requestVodMenuFocus() {
    _VodMenuFocusNode?.requestFocus();
  }


  // Focus node setters with scroll behavior
  void setWatchNowFocusNode(FocusNode node) {
    watchNowFocusNode = node;
    node.addListener(() {
      if (node.hasFocus) {
        scrollToElement('watchNow');
      }
    });
  }


    // Focus request methods with scroll behavior
  void requestWatchNowFocus() {
    if (watchNowFocusNode != null) {
      watchNowFocusNode!.requestFocus();
      setButtonFocus(true);
      scrollToElement('watchNow');
    }
  }

  // FocusNode? firstHomeCategoryFocusNode;

  // void setFirstHomeCategoryFocusNode(FocusNode node) {
  //   firstHomeCategoryFocusNode = node;
  //   node.addListener(() {
  //     if (node.hasFocus) {
  //       scrollToElement('homeCategoryFirstBanner');
  //     }
  //   });
  // }

  // void requestHomeCategoryFocus() {
  //   if (firstHomeCategoryFocusNode != null) {
  //     firstHomeCategoryFocusNode!.requestFocus();
  //     setFirstHomeCategoryFocusNode(firstHomeCategoryFocusNode!);

  //     scrollToElement('homeCategoryFirstBanner');
  //   } else {
  //   }
  // }


  

  FocusNode? firstVodBannerFocusNode;

  void setFirstVodBannerFocusNode(FocusNode node) {
    firstVodBannerFocusNode = node;
    node.addListener(() {
      // if (node.hasFocus) {
      //   scrollToElement('vodFirstBanner');
      // }
    });
  }

  void requestVodBannerFocus() {
    if (firstVodBannerFocusNode != null) {
      firstVodBannerFocusNode!.requestFocus();
      // scrollToElement('vodFirstBanner');
    } else {
    }
  }

  FocusNode? topNavigationFocusNode;

  void setTopNavigationFocusNode(FocusNode node) {
    topNavigationFocusNode = node;
  }

  void requestTopNavigationFocus() {
    if (topNavigationFocusNode != null) {
      topNavigationFocusNode!.requestFocus();
      setTopNavigationFocusNode(topNavigationFocusNode!);
      // scrollToElement('topNavigation'); // Optional, scroll if necessary

    } else {
    }
  }

void requestSubVodFocus() {
  if (firstSubVodFocusNode != null) {
          firstSubVodFocusNode!.requestFocus();

    setVodFirstBannerFocus(true);


    Future.delayed(Duration(milliseconds: 50), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (firstSubVodFocusNode!.canRequestFocus) {
          firstSubVodFocusNode!.requestFocus();
        } else {
        }
      });
    });

    scrollToElement('subVod');
  } else {
  }
}



    // FocusNode? firstSubVodFocusNode;
  BuildContext? _subVodContext; // Store context for forceful focus
  
  // SIMPLE REGISTRATION - no automatic focus
  void setFirstSubVodFocusNode(FocusNode node) {
    firstSubVodFocusNode = node;
    
    node.addListener(() {
    });
  }
  
  // Store context for forceful focus
  void setSubVodContext(BuildContext context) {
    _subVodContext = context;
  }
  
  // 🚀 FORCEFUL FOCUS METHOD 1 - Multiple attempts
  void forceSubVodFocus() {
    
    if (firstSubVodFocusNode == null) {
      return;
    }
    
    firstSubVodFocusNode!.requestFocus();
    
    // Attempt 2: With delay
    Future.delayed(Duration(milliseconds: 100), () {
      if (!firstSubVodFocusNode!.hasFocus) {
        firstSubVodFocusNode!.requestFocus();
      }
    });
    
    // Attempt 3: Force with context
    Future.delayed(Duration(milliseconds: 200), () {
      if (!firstSubVodFocusNode!.hasFocus && _subVodContext != null) {
        FocusScope.of(_subVodContext!).requestFocus(firstSubVodFocusNode!);
      }
    });
    
    // // Final check
    // Future.delayed(Duration(milliseconds: 500), () {
    //   if (firstSubVodFocusNode!.hasFocus) {
    //   } else {
    //   }
    // });
  }
  
  // 🚀 FORCEFUL FOCUS METHOD 2 - With context parameter
  void forceSubVodFocusWithContext(BuildContext context) {
    
    if (firstSubVodFocusNode == null) {
      return;
    }
    
    // Unfocus any currently focused node first
    FocusScope.of(context).unfocus();
    
    Future.delayed(Duration(milliseconds: 50), () {
      FocusScope.of(context).requestFocus(firstSubVodFocusNode!);
      
      Future.delayed(Duration(milliseconds: 100), () {
      });
    });
  }
  
  // 🚀 NUCLEAR OPTION - Complete focus reset and force
  void nuclearSubVodFocus(BuildContext context) {
    
    if (firstSubVodFocusNode == null) {
      return;
    }
    
    // Step 1: Unfocus everything
    FocusScope.of(context).unfocus();
    
    // Step 2: Wait and force focus
    Future.delayed(Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(firstSubVodFocusNode!);
      
      // Step 3: Double force
      Future.delayed(Duration(milliseconds: 50), () {
        firstSubVodFocusNode!.requestFocus();
        
        // Step 4: Triple force if needed
        Future.delayed(Duration(milliseconds: 50), () {
          if (!firstSubVodFocusNode!.hasFocus) {
            firstSubVodFocusNode!.requestFocus();
          }
          
          // Final verification
          Future.delayed(Duration(milliseconds: 100), () {
          });
        });
      });
    });
  }



    // FocusNode? firstSubVodFocusNode;
  
  // void setFirstSubVodFocusNode(FocusNode node) {
  //   firstSubVodFocusNode = node;
  //     // firstSubVodFocusNode!.requestFocus();
    
  //   node.addListener(() {
  //     if (node.hasFocus) {
  //       if (_isVodfirstbannerFocussed) {
  //         scrollToElement('subVod');
  //       }
  //     }
  //   });
  // }
  
  // 🎯 ADD THIS METHOD
  void requestFirstSubVodFocus() {
    
    if (firstSubVodFocusNode != null) {
      firstSubVodFocusNode!.requestFocus();
      setFirstSubVodFocusNode(firstSubVodFocusNode!);
      
      // Check after a delay
      Future.delayed(Duration(milliseconds: 100), () {
      firstSubVodFocusNode!.requestFocus();

      });
      
      scrollToElement('subVod');
    } else {
    }
  }


//   void requestFirstSubVodFocus() {
//   if (firstSubVodFocusNode != null) {
//     firstSubVodFocusNode!.requestFocus();
//     scrollToElement('subVod');
//   } else {
//   }
// }


//   void requestFirstSubVodFocus() {
//   if (firstSubVodFocusNode != null) {
//     firstSubVodFocusNode!.requestFocus();
    
//     // Optional: Add scroll behavior
//     scrollToElement('subVod');
//   } else {
//   }
// }




// // 🎯 MISSING METHOD - यह add करना होगा
// void requestFirstSubVodFocus() {
//   if (firstSubVodFocusNode != null) {
//     firstSubVodFocusNode!.requestFocus();
    
//     // Optional: Add scroll behavior if needed
//     scrollToElement('subVod');
//   } else {
//   }
// }

// // 🔧 ALSO UPDATE your existing setFirstSubVodFocusNode method:
// void setFirstSubVodFocusNode(FocusNode node) {
//   firstSubVodFocusNode = node;
//   _firstSubVodFocusNode = node; // Also set the private variable if you're using it
//   node.addListener(() {
//     if (node.hasFocus) {
//       // Only scroll if explicitly requested
//       if (_isVodfirstbannerFocussed) {
//         scrollToElement('subVod');
//       }
//     }
//   });
// }


  // void setFirstSubVodFocusNode(FocusNode node) {
  //   firstSubVodFocusNode = node;
  //   node.addListener(() {
  //     if (node.hasFocus) {
  //       // Only scroll if explicitly requested
  //       if (_isVodfirstbannerFocussed) {
  //         scrollToElement('subVod');
  //       }
  //     }
  //   });
  // }

  void setVodFirstBannerFocus(bool focused) {
    _isVodfirstbannerFocussed = focused;
    notifyListeners();
  }





  void requestLastPlayedFocus() {
    if (firstLastPlayedFocusNode != null) {
      firstLastPlayedFocusNode!.requestFocus();
      setLastPlayedFocus(0);
      scrollToElement('lastPlayed');
    }
  }



  FocusNode? getFirstSubVodFocusNode() {
    return _firstSubVodFocusNode;
  }


  

  // void requestSubVodFocus(BuildContext context) {
  //   if (firstSubVodFocusNode != null) {
  //     firstSubVodFocusNode!.requestFocus();
  //     setFirstSubVodFocusNode(firstSubVodFocusNode!);
  //     scrollToElement('subVod');

  //   } else {
  //   }
  // }



  // Rest of the methods remain same
  void setButtonFocus(bool focused, {Color? color}) {
    _isButtonFocused = focused;
    if (focused) {
      _currentFocusColor = color;
      _isLastPlayedFocused = false;
      _focusedVideoIndex = -1;
    }
    notifyListeners();
  }

  void setLastPlayedFocus(int index) {
    _isLastPlayedFocused = true;
    _focusedVideoIndex = index;
    _isButtonFocused = false;
    notifyListeners();
  }

  void resetFocus() {
    _isButtonFocused = false;
    _isLastPlayedFocused = false;
    _focusedVideoIndex = -1;
    _currentFocusColor = null;
    notifyListeners();
  }

  // FocusNode? _subVodFocusNode;

  // FocusNode? get subVodFocusNode => _subVodFocusNode;

  void updateFocusColor(Color color) {
    _currentFocusColor = color;
    notifyListeners();
  }


  // Other existing properties and methods...
  
  // ScrollController for the main screen
  // final ScrollController scrollController = ScrollController();
  
  // Map to store element keys
  // final Map<String, GlobalKey> _elementKeys = {};
  
  // Focus nodes
  FocusNode? _watchNowFocusNode;
  // FocusNode? _firstMusicItemFocusNode;
  // FocusNode? _firstSubVodFocusNode;
  // FocusNode? _firstManageMoviesFocusNode;
  
  // Category count for ManageMovies
  int _categoryCountMovies = 0;
  
  // Height calculation for ManageMovies
  double _totalHeightMovies = 0.0;
  
  // Getters
  int get categoryCount => _categoryCountMovies;
  double get totalHeight => _totalHeightMovies;
  
  // Update category count from ManageMovies
  void updateCategoryCountMovies(int count) {
    _categoryCountMovies = count;
    
    // You might want to calculate total height here if needed
    // _totalHeight = count * someHeightPerCategory;
    
    notifyListeners();
  }

  // Category count for ManageMovies
  int _categoryCountWebseries = 0;
  
  // Height calculation for ManageMovies
  double _totalHeightWebseries = 0.0;
  
  // Getters
  int get categoryCountWebseries => _categoryCountWebseries;
  double get totalHeightWebseries => _totalHeightWebseries;
  
  // Update category count from ManageMovies
  void updateCategoryCountWebseries(int count) {
    _categoryCountWebseries = count;
    
    // You might want to calculate total height here if needed
    // _totalHeight = count * someHeightPerCategory;
    
    notifyListeners();
  }
  









  // FocusNode? firstManageMoviesFocusNode;

  // void setFirstManageMoviesFocusNode(FocusNode node) {
  //   firstManageMoviesFocusNode = node;
  //   notifyListeners();
  // }

  // void requestManageMoviesFocus() {
  //   firstManageMoviesFocusNode?.requestFocus();
  //     scrollToElement('manageMovies');
  // }



  // FocusNode? firstManageWebseriesFocusNode;

  // void setFirstManageWebseriesFocusNode(FocusNode node) {
  //   firstManageWebseriesFocusNode = node;
  //   notifyListeners();
  // }

  // void requestManageWebseriesFocus() {
  //   firstManageWebseriesFocusNode?.requestFocus();
  //     scrollToElement('manageWebseries');
  // }


  
  // Focus navigation methods and other functionality...


  @override
  void dispose() {
    scrollController.dispose();
    watchNowFocusNode?.dispose();
    firstLastPlayedFocusNode?.dispose();
    firstMusicItemFocusNode?.dispose();
    super.dispose();
  }
}