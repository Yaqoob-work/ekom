




// import 'package:flutter/material.dart';
// import 'dart:async';

// class FocusProvider extends ChangeNotifier {
//   final Map<String, FocusNode> _focusNodes = {};
//   final Map<String, GlobalKey> _elementKeys = {};
//   final ScrollController scrollController = ScrollController();

//   // --- DURATION CONSTANTS ---
//   static const int _kLockDurationMs = 20;
//   static const int _kScrollDurationMs = 1200;

//   // --- NAVIGATION LOCK VARIABLES ---
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;
//   String _lastFocusedIdentifier = '';
//   String get lastFocusedIdentifier => _lastFocusedIdentifier;
// // FocusProvider class ke andar ye add karein:
// String? _lastFocusedItemId; // Banner ki unique ID ke liye

// String? get lastFocusedItemId => _lastFocusedItemId;

// void updateLastFocusedItemId(String itemId) {
//   _lastFocusedItemId = itemId;
//   print("FocusProvider: Setting lastFocusedItemId = $itemId");
//   // notifyListeners() ki zaroorat nahi agar hum sirf state save kar rahe hain
//   notifyListeners();
// }
//   // --- VISIBLE ROWS LIST ---
//   List<String> _visibleRowIdentifiers = [];
//   String _lastNavigationDirection = 'down';

//   final Set<String> _lockableIdentifiers = {
//     'watchNow',
//     'liveChannelLanguage',
//     'subVod',
//     'manageMovies',
//     'manageWebseries',
//     'tvShows',
//     'sports',
//     'religiousChannels',
//     'tvShowPak',
//     'kids_show',
//   };

//   void updateVisibleRowIdentifiers(List<String> identifiers) {
//     _visibleRowIdentifiers = identifiers;
//   }

//   // --- NAYE NAVIGATION METHODS ---

//   /// ✅ [UPDATED] Agli VISIBLE aur REGISTERED row par focus karta hai.
//   /// Agar last row hai, to focus wahin rakhta hai taaki lost na ho.
//   void focusNextRow() {
//     _lastNavigationDirection = 'down';
//     final currentIndex = _visibleRowIdentifiers.indexOf(_lastFocusedIdentifier);

//     if (currentIndex == -1 && _visibleRowIdentifiers.isNotEmpty) {
//       // Case 1: Focus lost completely, jump to first
//       requestFocus(_visibleRowIdentifiers[0]);
//     } 
//     else if (currentIndex < _visibleRowIdentifiers.length - 1) {
//       // Case 2: We are in the middle, look for next available node
//       bool foundNext = false;
      
//       // Loop through next items to find one that is registered
//       for (int i = currentIndex + 1; i < _visibleRowIdentifiers.length; i++) {
//         final String nextIdentifier = _visibleRowIdentifiers[i];
//         final node = _focusNodes[nextIdentifier];

//         if (node != null && node.canRequestFocus) {
//           print('FocusProvider: focusNextRow attempting: $nextIdentifier');
//           requestFocus(nextIdentifier);
//           foundNext = true;
//           return; 
//         } else {
//           print('FocusProvider: focusNextRow skipping: $nextIdentifier (not registered yet)');
//         }
//       }

//       // Case 3: Loop finished but no valid next node found (rare race condition)
//       if (!foundNext) {
//         print('FocusProvider: No valid next node found. Keeping focus on $_lastFocusedIdentifier');
//         requestFocus(_lastFocusedIdentifier); // Restore focus to current
//       }
//     } 
//     else {
//       // ✅ Case 4: We are at the LAST item (e.g. kids_show)
//       // Re-request focus on the current item so it doesn't get lost
//       print('FocusProvider: Reached bottom. Keeping focus on $_lastFocusedIdentifier');
//       requestFocus(_lastFocusedIdentifier);
//     }
//   }

//   /// ✅ [UPDATED] Pichli VISIBLE aur REGISTERED row par focus karta hai.
//   void focusPreviousRow() {
//     _lastNavigationDirection = 'up';
//     final currentIndex = _visibleRowIdentifiers.indexOf(_lastFocusedIdentifier);

//     if (currentIndex > 0) {
//       bool foundPrev = false;

//       // Look backwards for a registered node
//       for (int i = currentIndex - 1; i >= 0; i--) {
//         final String prevIdentifier = _visibleRowIdentifiers[i];
//         final node = _focusNodes[prevIdentifier]; 

//         if (node != null && node.canRequestFocus) {
//           print('FocusProvider: focusPreviousRow attempting: $prevIdentifier');
//           requestFocus(prevIdentifier);
//           foundPrev = true;
//           return; 
//         } else {
//           print('FocusProvider: focusPreviousRow skipping: $prevIdentifier (not registered yet)');
//         }
//       }
      
//       // If no valid previous node found, keep focus here
//       if (!foundPrev) {
//          requestFocus(_lastFocusedIdentifier);
//       }

//     } else if (currentIndex == 0) {
//       // ✅ Case: Top of the list
//       // Option A: Go to Top Navigation (Search/Settings)
//       // requestFocus('topNavigation'); 
      
//       // Option B: Keep focus on first item (prevent loss)
//       print('FocusProvider: Reached top. Keeping focus on $_lastFocusedIdentifier');
//       requestFocus(_lastFocusedIdentifier);
//     }
//   }
//   // -----------------------------

//   void registerFocusNode(String identifier, FocusNode node) {
//     _focusNodes[identifier] = node;
//     notifyListeners();
//   }

//   void requestFocus(String identifier) {
//     final node = _focusNodes[identifier];
//     if (node == null) {
//       print('FocusProvider: $identifier के लिए कोई नोड नहीं मिला।');
//       return;
//     }

//     // --- LOCK LOGIC ---
//     final bool requiresLock = _lockableIdentifiers.contains(identifier);
//     final bool shouldApplyLock = requiresLock;

//     if (shouldApplyLock && _isNavigationLocked) {
//       print('FocusProvider: Navigation locked, request for $identifier ignored.');
//       return;
//     }

//     if (shouldApplyLock) {
//       _isNavigationLocked = true;
//       _navigationLockTimer?.cancel();
//       _navigationLockTimer = Timer(const Duration(milliseconds: _kLockDurationMs), () {
//         _isNavigationLocked = false;
//       });
//     }
//     // --- LOCK LOGIC KHATAM ---

//     Future.delayed(const Duration(milliseconds: 10), () {
//       if (!node.canRequestFocus) {
//         print('FocusProvider: $identifier पर फोकस नहीं किया जा सकता।');
//         if (shouldApplyLock) {
//           _isNavigationLocked = false;
//           _navigationLockTimer?.cancel();
//         }
//         return;
//       }

//       // --- YEH ZAROORI HAI ---
//       if (_visibleRowIdentifiers.contains(identifier)) {
//         _lastFocusedIdentifier = identifier;
//       }
//       // ------------------------

//       // --- SWITCH CASE ---
//       switch (identifier) {
//         case 'topNavigation':
//         case 'aboveEighteen':
//         case 'searchNavigation':
//         case 'searchIcon':
//           node.requestFocus();
//           break;

//         case 'watchNow':
//         case 'liveChannelLanguage':
//         case 'subVod':
//         case 'manageMovies':
//         case 'manageWebseries':
//         case 'tvShows':
//         case 'sports':
//         case 'religiousChannels':
//         case 'tvShowPak':
//         case 'kids_show':
//           node.requestFocus();
//           scrollToElement(identifier); // Scroll function call karein
//           break;

//         default:
//           node.requestFocus();
//       }
//       // --- SWITCH CASE KHATAM ---
//     });
//   }

//   void registerElementKey(String identifier, GlobalKey key) {
//     final bool isNewKey = _elementKeys[identifier] != key;
//     _elementKeys[identifier] = key;
//     if (isNewKey) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         notifyListeners();
//       });
//     }
//   }

//   void unregisterElementKey(String identifier) {
//     _elementKeys.remove(identifier);
//     notifyListeners();
//   }

//   void scrollToElement(String identifier) {
//     final key = _elementKeys[identifier];
//     final BuildContext? context = key?.currentContext;
//     final double targetAlignment = (_lastNavigationDirection == 'up')
//         ? 0.5 // Center mein (ArrowUp ke liye)
//         : 0.5; // Top par (ArrowDown ke liye)
//     if (context != null) {
//       Scrollable.ensureVisible(
//         context,
//         alignment: targetAlignment,
//         duration: const Duration(milliseconds: _kScrollDurationMs),
//         curve: Curves.linear,
//       );
//     }
//   }

//   /// ✅ NAYA METHOD: Provider ki state ko manually sync karne ke liye
//   void updateLastFocusedIdentifier(String identifier) {
//     if (_visibleRowIdentifiers.contains(identifier)) {
      
//       _lastFocusedIdentifier = identifier;
//       notifyListeners();
//       print('FocusProvider: Internal state updated manually to: $identifier');
//     }
//   }

//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     scrollController.dispose();
//     for (var node in _focusNodes.values) {
//       node.dispose();
//     }
//     _focusNodes.clear();
//     super.dispose();
//   }
// }




import 'package:flutter/material.dart';
import 'dart:async';

class FocusProvider extends ChangeNotifier {
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, GlobalKey> _elementKeys = {};
  final ScrollController scrollController = ScrollController();

  // --- UPDATED CONSTANTS FOR SMOOTHER SCROLL ---
  static const int _kLockDurationMs = 50; // Thoda badhaya taaki rapid clicks handle hon
  static const int _kScrollDurationMs = 200; // 1200ms se kam kiya taaki lag na lage

  // --- NAVIGATION LOCK VARIABLES ---
  bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;
  String _lastFocusedIdentifier = '';
  String get lastFocusedIdentifier => _lastFocusedIdentifier;

  String? _lastFocusedItemId; 
  String? get lastFocusedItemId => _lastFocusedItemId;

  void updateLastFocusedItemId(String itemId) {
    _lastFocusedItemId = itemId;
    // notifyListeners(); // Performance ke liye off rakha hai
  }

  // --- VISIBLE ROWS LIST ---
  List<String> _visibleRowIdentifiers = [];
  String _lastNavigationDirection = 'down';

  final Set<String> _lockableIdentifiers = {
    'watchNow',
    'liveChannelLanguage',
    'subVod',
    'manageMovies',
    'manageWebseries',
    'tvShows',
    'sports',
    'religiousChannels',
    'tvShowPak',
    'kids_show',
    'aboveEighteen', // Agar future mein add karein
  };

  void updateVisibleRowIdentifiers(List<String> identifiers) {
    _visibleRowIdentifiers = identifiers;
  }

  // --- NAVIGATION METHODS ---

  void focusNextRow() {
    _lastNavigationDirection = 'down';
    final currentIndex = _visibleRowIdentifiers.indexOf(_lastFocusedIdentifier);

    if (currentIndex == -1 && _visibleRowIdentifiers.isNotEmpty) {
      requestFocus(_visibleRowIdentifiers[0]);
    } 
    else if (currentIndex < _visibleRowIdentifiers.length - 1) {
      bool foundNext = false;
      for (int i = currentIndex + 1; i < _visibleRowIdentifiers.length; i++) {
        final String nextIdentifier = _visibleRowIdentifiers[i];
        final node = _focusNodes[nextIdentifier];

        if (node != null && node.canRequestFocus) {
          requestFocus(nextIdentifier);
          foundNext = true;
          return; 
        }
      }
      if (!foundNext) {
        requestFocus(_lastFocusedIdentifier);
      }
    } 
    else {
      requestFocus(_lastFocusedIdentifier);
    }
  }

  void focusPreviousRow() {
    _lastNavigationDirection = 'up';
    final currentIndex = _visibleRowIdentifiers.indexOf(_lastFocusedIdentifier);

    if (currentIndex > 0) {
      bool foundPrev = false;
      for (int i = currentIndex - 1; i >= 0; i--) {
        final String prevIdentifier = _visibleRowIdentifiers[i];
        final node = _focusNodes[prevIdentifier]; 

        if (node != null && node.canRequestFocus) {
          requestFocus(prevIdentifier);
          foundPrev = true;
          return; 
        }
      }
      if (!foundPrev) {
         requestFocus(_lastFocusedIdentifier);
      }
    } else if (currentIndex == 0) {
      requestFocus(_lastFocusedIdentifier);
    }
  }

  // -----------------------------

  void registerFocusNode(String identifier, FocusNode node) {
    _focusNodes[identifier] = node;
    // notifyListeners(); // Bar bar rebuild se bachne ke liye comment kiya
  }

  // void requestFocus(String identifier) {
  //   final node = _focusNodes[identifier];
  //   if (node == null) {
  //    // Agar main node nahi mil raha toh check karein ki kya ye kisi sub-item ki row hai
  //    return;
  // }

    

  //   // --- LOCK LOGIC ---
  //   final bool requiresLock = _lockableIdentifiers.contains(identifier);

  //   if (requiresLock && _isNavigationLocked) return;

  //   if (requiresLock) {
  //     _isNavigationLocked = true;
  //     _navigationLockTimer?.cancel();
  //     _navigationLockTimer = Timer(const Duration(milliseconds: _kLockDurationMs), () {
  //       _isNavigationLocked = false;
  //     });
  //   }

  //   Future.microtask(() {
  //     if (!node.canRequestFocus) {
  //       if (requiresLock) {
  //         _isNavigationLocked = false;
  //         _navigationLockTimer?.cancel();
  //       }
  //       return;
  //     }

  //     if (_visibleRowIdentifiers.contains(identifier)) {
  //       _lastFocusedIdentifier = identifier;
  //     }

  //     // --- FOCUS & SCROLL LOGIC ---
  //     node.requestFocus();
      
  //     // Sabhi lockable identifiers ke liye scroll call karein
  //     if (_lockableIdentifiers.contains(identifier)) {
  //       scrollToElement(identifier);
  //     }
  //   });
  // }



//   void requestFocus(String identifier) {
//   final node = _focusNodes[identifier];
//   if (node == null) return;

//   // Agar navigation locked hai toh return karein
//   final bool requiresLock = _lockableIdentifiers.contains(identifier);
//   if (requiresLock && _isNavigationLocked) return;

//   // ✅ Update identifier immediately 
//   _lastFocusedIdentifier = identifier;

//   Future.microtask(() {
//     if (!node.canRequestFocus) return;
    
//     // Sirf request karein, notifyListeners() ki zarurat nahi hai agar sirf focus switch ho raha hai
//     node.requestFocus();
    
//     if (_lockableIdentifiers.contains(identifier)) {
//       scrollToElement(identifier);
//     }
//   });
// }



void requestFocus(String identifier) {
    final node = _focusNodes[identifier];
    if (node == null) return;

    final bool requiresLock = _lockableIdentifiers.contains(identifier);
    if (requiresLock && _isNavigationLocked) return;

    _lastFocusedIdentifier = identifier;

    // ✅ Focus request ko scroll ke saath sync karein
    Future.delayed(Duration.zero, () {
      if (!node.canRequestFocus) return;
      node.requestFocus();
      
      if (_lockableIdentifiers.contains(identifier)) {
        scrollToElement(identifier);
      }
    });
  }

  void scrollToElement(String identifier) {
    final key = _elementKeys[identifier];
    if (key?.currentContext == null) return;

    final BuildContext context = key!.currentContext!;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero, ancestor: scrollController.position.context.storageContext.findRenderObject());
    
    // ✅ Custom calculation taaki makkhan ki tarah scroll ho
    final double targetOffset = scrollController.offset + position.dy - (MediaQuery.of(context).size.height / 3);

    scrollController.animateTo(
      targetOffset.clamp(0.0, scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: _kScrollDurationMs),
      curve: Curves.easeOutCubic, // Isse smoothness badh jayegi
    );
  }

  void registerElementKey(String identifier, GlobalKey key) {
    _elementKeys[identifier] = key;
  }

  void unregisterElementKey(String identifier) {
    _elementKeys.remove(identifier);
  }

  // /// ✅ [UPDATED] Smooth Scrolling Method
  // void scrollToElement(String identifier) {
  //   final key = _elementKeys[identifier];
    
  //   // Agar key null hai ya widget tree mein abhi attach nahi hua hai
  //   if (key?.currentContext == null) return;

  //   final BuildContext context = key!.currentContext!;

  //   // 0.5 matlab item ko screen ke center mein lana
  //   final double targetAlignment = 0.5;

  //   Scrollable.ensureVisible(
  //     context,
  //     alignment: targetAlignment,
  //     duration: const Duration(milliseconds: _kScrollDurationMs),
  //     // ✅ Linear ki jagah EaseInOutCubic use karein (Makkhan scrolling)
  //     curve: Curves.easeInOutCubic, 
  //     alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
  //   );
  // }

  void updateLastFocusedIdentifier(String identifier) {
    if (_visibleRowIdentifiers.contains(identifier)) {
      _lastFocusedIdentifier = identifier;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _navigationLockTimer?.cancel();
    scrollController.dispose();
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    _focusNodes.clear();
    super.dispose();
  }
}



// import 'package:flutter/material.dart';
// import 'dart:async';

// class FocusProvider extends ChangeNotifier {
//   final Map<String, FocusNode> _focusNodes = {};
//   final Map<String, GlobalKey> _elementKeys = {};
//   final ScrollController scrollController = ScrollController();

//   // --- DURATION CONSTANTS ---
//   // Inhe yahan se change karne par poori app ki speed control hogi
//   static const int _kLockDurationMs = 50; 
//   static const int _kScrollDurationMs = 400; // 400ms smooth feel ke liye best hai

//   // --- NAVIGATION LOCK VARIABLES ---
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;
//   String _lastFocusedIdentifier = '';
//   String get lastFocusedIdentifier => _lastFocusedIdentifier;

//   String? _lastFocusedItemId; 
//   String? get lastFocusedItemId => _lastFocusedItemId;

//   void updateLastFocusedItemId(String itemId) {
//     _lastFocusedItemId = itemId;
//   }

//   // --- VISIBLE ROWS LIST ---
//   List<String> _visibleRowIdentifiers = [];
//   String _lastNavigationDirection = 'down';

//   // In identifiers par scroll aur lock logic apply hoga
//   final Set<String> _lockableIdentifiers = {
//     'watchNow',
//     'liveChannelLanguage',
//     'subVod',
//     'manageMovies',
//     'manageWebseries',
//     'tvShows',
//     'sports',
//     'religiousChannels',
//     'tvShowPak',
//     'kids_show',
//     'aboveEighteen',
//   };

//   void updateVisibleRowIdentifiers(List<String> identifiers) {
//     _visibleRowIdentifiers = identifiers;
//   }

//   // --- NAVIGATION METHODS ---

//   void focusNextRow() {
//     _lastNavigationDirection = 'down';
//     final currentIndex = _visibleRowIdentifiers.indexOf(_lastFocusedIdentifier);

//     if (currentIndex == -1 && _visibleRowIdentifiers.isNotEmpty) {
//       requestFocus(_visibleRowIdentifiers[0]);
//     } 
//     else if (currentIndex < _visibleRowIdentifiers.length - 1) {
//       for (int i = currentIndex + 1; i < _visibleRowIdentifiers.length; i++) {
//         final String nextIdentifier = _visibleRowIdentifiers[i];
//         final node = _focusNodes[nextIdentifier];

//         if (node != null && node.canRequestFocus) {
//           requestFocus(nextIdentifier);
//           return; 
//         }
//       }
//     } else {
//       // Reached bottom, keep focus on last item
//       requestFocus(_lastFocusedIdentifier);
//     }
//   }

//   void focusPreviousRow() {
//     _lastNavigationDirection = 'up';
//     final currentIndex = _visibleRowIdentifiers.indexOf(_lastFocusedIdentifier);

//     if (currentIndex > 0) {
//       for (int i = currentIndex - 1; i >= 0; i--) {
//         final String prevIdentifier = _visibleRowIdentifiers[i];
//         final node = _focusNodes[prevIdentifier]; 

//         if (node != null && node.canRequestFocus) {
//           requestFocus(prevIdentifier);
//           return; 
//         }
//       }
//     } else {
//       // Reached top, keep focus or move to top nav
//       requestFocus(_lastFocusedIdentifier);
//     }
//   }

//   // --- REGISTRATION METHODS ---

//   void registerFocusNode(String identifier, FocusNode node) {
//     _focusNodes[identifier] = node;
//   }

//   void registerElementKey(String identifier, GlobalKey key) {
//     _elementKeys[identifier] = key;
//   }

//   void unregisterElementKey(String identifier) {
//     _elementKeys.remove(identifier);
//   }

//   // --- CORE FOCUS & SCROLL LOGIC ---

//   void requestFocus(String identifier) {
//     final node = _focusNodes[identifier];
//     if (node == null) return;

//     final bool requiresLock = _lockableIdentifiers.contains(identifier);
    
//     // 1. Navigation Lock check (Rapid clicks prevent karne ke liye)
//     if (requiresLock && _isNavigationLocked) return;

//     if (requiresLock) {
//       _isNavigationLocked = true;
//       _navigationLockTimer?.cancel();
//       _navigationLockTimer = Timer(const Duration(milliseconds: _kLockDurationMs), () {
//         _isNavigationLocked = false;
//       });
//     }

//     _lastFocusedIdentifier = identifier;

//     // 2. Focus and Scroll execution
//     Future.delayed(Duration.zero, () {
//       if (!node.canRequestFocus) return;
      
//       node.requestFocus();
      
//       if (_lockableIdentifiers.contains(identifier)) {
//         scrollToElement(identifier);
//       }
//     });
//   }

//   void scrollToElement(String identifier) {
//     final key = _elementKeys[identifier];
//     if (key?.currentContext == null) return;

//     final BuildContext context = key!.currentContext!;

//     // alignment: 0.5 ka matlab hai item screen ke center mein aayega
//     Scrollable.ensureVisible(
//       context,
//       alignment: 0.5,
//       duration: const Duration(milliseconds: _kScrollDurationMs),
//       curve: Curves.easeOutCubic, // Smooth animation
//     );
//   }

//   void updateLastFocusedIdentifier(String identifier) {
//     if (_visibleRowIdentifiers.contains(identifier)) {
//       _lastFocusedIdentifier = identifier;
//       notifyListeners();
//     }
//   }

//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     scrollController.dispose();
//     for (var node in _focusNodes.values) {
//       node.dispose();
//     }
//     _focusNodes.clear();
//     super.dispose();
//   }
// }