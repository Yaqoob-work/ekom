



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
//   void focusNextRow() {
//     _lastNavigationDirection = 'down';
//     final currentIndex = _visibleRowIdentifiers.indexOf(_lastFocusedIdentifier);

//     if (currentIndex == -1 && _visibleRowIdentifiers.isNotEmpty) {
//       // Agar kisi row par focus nahi hai, toh pehli visible row par focus karo
//       requestFocus(_visibleRowIdentifiers[0]);
//     } else if (currentIndex < _visibleRowIdentifiers.length - 1) {
      
//       // --- NAYA LOGIC (Race Condition Fix) ---
//       // Agle item se check karna shuru karein
//       for (int i = currentIndex + 1; i < _visibleRowIdentifiers.length; i++) {
//         final String nextIdentifier = _visibleRowIdentifiers[i];
//         final node = _focusNodes[nextIdentifier]; // Check karein ki node register hai ya nahi

//         if (node != null && node.canRequestFocus) {
//           // Valid, registered node mil gaya. Focus karein.
//           print('FocusProvider: focusNextRow attempting: $nextIdentifier');
//           requestFocus(nextIdentifier);
//           return; // Loop band karein
//         } else {
//           // Node ya toh null hai (register nahi hua) ya focus nahi ho sakta.
//           // Loop ko agle item ke liye jaari rakhein.
//           print('FocusProvider: focusNextRow skipping: $nextIdentifier (not registered yet)');
//         }
//       }
//       // Agar loop poora ho gaya aur koi node nahi mila
//       print('FocusProvider: focusNextRow found no available nodes after $_lastFocusedIdentifier');
//       // --- NAYA LOGIC KHATAM ---
//     }
//   }

//   /// ✅ [UPDATED] Pichli VISIBLE aur REGISTERED row par focus karta hai.
//   void focusPreviousRow() {
//     _lastNavigationDirection = 'up';
//     final currentIndex = _visibleRowIdentifiers.indexOf(_lastFocusedIdentifier);

//     if (currentIndex > 0) {
      
//       // --- NAYA LOGIC (Race Condition Fix) ---
//       // Pichle item se check karna shuru karein
//       for (int i = currentIndex - 1; i >= 0; i--) {
//         final String prevIdentifier = _visibleRowIdentifiers[i];
//         final node = _focusNodes[prevIdentifier]; // Check karein ki node register hai ya nahi

//         if (node != null && node.canRequestFocus) {
//           // Valid, registered node mil gaya. Focus karein.
//           print('FocusProvider: focusPreviousRow attempting: $prevIdentifier');
//           requestFocus(prevIdentifier);
//           return; // Loop band karein
//         } else {
//           // Node ya toh null hai (register nahi hua) ya focus nahi ho sakta.
//           // Loop ko pichle item ke liye jaari rakhein.
//           print('FocusProvider: focusPreviousRow skipping: $prevIdentifier (not registered yet)');
//         }
//       }
//       // Agar loop poora ho gaya aur koi node nahi mila
//       print('FocusProvider: focusPreviousRow found no available nodes before $_lastFocusedIdentifier');
//       // --- NAYA LOGIC KHATAM ---

//     } else if (currentIndex == 0) {
//       // Yahan aap Top Navigation Bar ya Search icon par focus bhej sakte hain
//       // requestFocus('topNavigation');
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
//       _navigationLockTimer = Timer(
//           const Duration(milliseconds: _kLockDurationMs), () { 
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
//          _lastFocusedIdentifier = identifier;
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
// final double targetAlignment = (_lastNavigationDirection == 'up') 
//                                     ? 0.5   // Center mein (ArrowUp ke liye)
//                                     : 0.5; // Top par (ArrowDown ke liye)
//     if (context != null) {
//       Scrollable.ensureVisible(
//         context,
//         alignment: targetAlignment,
//         duration: const Duration(milliseconds: _kScrollDurationMs),
//         curve: Curves.linear ,
//       );
//     }
//   }



//   // FocusProvider.dart ke andar (kisi bhi jagah, methods ke sath)

//   /// ✅ NAYA METHOD: Provider ki state ko manually sync karne ke liye
//   void updateLastFocusedIdentifier(String identifier) {
//     if (_visibleRowIdentifiers.contains(identifier)) {
//       _lastFocusedIdentifier = identifier;
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

  // --- DURATION CONSTANTS ---
  static const int _kLockDurationMs = 20;
  static const int _kScrollDurationMs = 1200;

  // --- NAVIGATION LOCK VARIABLES ---
  bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;
  String _lastFocusedIdentifier = '';
  String get lastFocusedIdentifier => _lastFocusedIdentifier;
// FocusProvider class ke andar ye add karein:
String? _lastFocusedItemId; // Banner ki unique ID ke liye

String? get lastFocusedItemId => _lastFocusedItemId;

void updateLastFocusedItemId(String itemId) {
  _lastFocusedItemId = itemId;
  print("FocusProvider: Setting lastFocusedItemId = $itemId");
  // notifyListeners() ki zaroorat nahi agar hum sirf state save kar rahe hain
  notifyListeners();
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
  };

  void updateVisibleRowIdentifiers(List<String> identifiers) {
    _visibleRowIdentifiers = identifiers;
  }

  // --- NAYE NAVIGATION METHODS ---

  /// ✅ [UPDATED] Agli VISIBLE aur REGISTERED row par focus karta hai.
  /// Agar last row hai, to focus wahin rakhta hai taaki lost na ho.
  void focusNextRow() {
    _lastNavigationDirection = 'down';
    final currentIndex = _visibleRowIdentifiers.indexOf(_lastFocusedIdentifier);

    if (currentIndex == -1 && _visibleRowIdentifiers.isNotEmpty) {
      // Case 1: Focus lost completely, jump to first
      requestFocus(_visibleRowIdentifiers[0]);
    } 
    else if (currentIndex < _visibleRowIdentifiers.length - 1) {
      // Case 2: We are in the middle, look for next available node
      bool foundNext = false;
      
      // Loop through next items to find one that is registered
      for (int i = currentIndex + 1; i < _visibleRowIdentifiers.length; i++) {
        final String nextIdentifier = _visibleRowIdentifiers[i];
        final node = _focusNodes[nextIdentifier];

        if (node != null && node.canRequestFocus) {
          print('FocusProvider: focusNextRow attempting: $nextIdentifier');
          requestFocus(nextIdentifier);
          foundNext = true;
          return; 
        } else {
          print('FocusProvider: focusNextRow skipping: $nextIdentifier (not registered yet)');
        }
      }

      // Case 3: Loop finished but no valid next node found (rare race condition)
      if (!foundNext) {
        print('FocusProvider: No valid next node found. Keeping focus on $_lastFocusedIdentifier');
        requestFocus(_lastFocusedIdentifier); // Restore focus to current
      }
    } 
    else {
      // ✅ Case 4: We are at the LAST item (e.g. kids_show)
      // Re-request focus on the current item so it doesn't get lost
      print('FocusProvider: Reached bottom. Keeping focus on $_lastFocusedIdentifier');
      requestFocus(_lastFocusedIdentifier);
    }
  }

  /// ✅ [UPDATED] Pichli VISIBLE aur REGISTERED row par focus karta hai.
  void focusPreviousRow() {
    _lastNavigationDirection = 'up';
    final currentIndex = _visibleRowIdentifiers.indexOf(_lastFocusedIdentifier);

    if (currentIndex > 0) {
      bool foundPrev = false;

      // Look backwards for a registered node
      for (int i = currentIndex - 1; i >= 0; i--) {
        final String prevIdentifier = _visibleRowIdentifiers[i];
        final node = _focusNodes[prevIdentifier]; 

        if (node != null && node.canRequestFocus) {
          print('FocusProvider: focusPreviousRow attempting: $prevIdentifier');
          requestFocus(prevIdentifier);
          foundPrev = true;
          return; 
        } else {
          print('FocusProvider: focusPreviousRow skipping: $prevIdentifier (not registered yet)');
        }
      }
      
      // If no valid previous node found, keep focus here
      if (!foundPrev) {
         requestFocus(_lastFocusedIdentifier);
      }

    } else if (currentIndex == 0) {
      // ✅ Case: Top of the list
      // Option A: Go to Top Navigation (Search/Settings)
      // requestFocus('topNavigation'); 
      
      // Option B: Keep focus on first item (prevent loss)
      print('FocusProvider: Reached top. Keeping focus on $_lastFocusedIdentifier');
      requestFocus(_lastFocusedIdentifier);
    }
  }
  // -----------------------------

  void registerFocusNode(String identifier, FocusNode node) {
    _focusNodes[identifier] = node;
    notifyListeners();
  }

  void requestFocus(String identifier) {
    final node = _focusNodes[identifier];
    if (node == null) {
      print('FocusProvider: $identifier के लिए कोई नोड नहीं मिला।');
      return;
    }

    // --- LOCK LOGIC ---
    final bool requiresLock = _lockableIdentifiers.contains(identifier);
    final bool shouldApplyLock = requiresLock;

    if (shouldApplyLock && _isNavigationLocked) {
      print('FocusProvider: Navigation locked, request for $identifier ignored.');
      return;
    }

    if (shouldApplyLock) {
      _isNavigationLocked = true;
      _navigationLockTimer?.cancel();
      _navigationLockTimer = Timer(const Duration(milliseconds: _kLockDurationMs), () {
        _isNavigationLocked = false;
      });
    }
    // --- LOCK LOGIC KHATAM ---

    Future.delayed(const Duration(milliseconds: 10), () {
      if (!node.canRequestFocus) {
        print('FocusProvider: $identifier पर फोकस नहीं किया जा सकता।');
        if (shouldApplyLock) {
          _isNavigationLocked = false;
          _navigationLockTimer?.cancel();
        }
        return;
      }

      // --- YEH ZAROORI HAI ---
      if (_visibleRowIdentifiers.contains(identifier)) {
        _lastFocusedIdentifier = identifier;
      }
      // ------------------------

      // --- SWITCH CASE ---
      switch (identifier) {
        case 'topNavigation':
        case 'aboveEighteen':
        case 'searchNavigation':
        case 'searchIcon':
          node.requestFocus();
          break;

        case 'watchNow':
        case 'liveChannelLanguage':
        case 'subVod':
        case 'manageMovies':
        case 'manageWebseries':
        case 'tvShows':
        case 'sports':
        case 'religiousChannels':
        case 'tvShowPak':
        case 'kids_show':
          node.requestFocus();
          scrollToElement(identifier); // Scroll function call karein
          break;

        default:
          node.requestFocus();
      }
      // --- SWITCH CASE KHATAM ---
    });
  }

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
    final BuildContext? context = key?.currentContext;
    final double targetAlignment = (_lastNavigationDirection == 'up')
        ? 0.5 // Center mein (ArrowUp ke liye)
        : 0.5; // Top par (ArrowDown ke liye)
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: targetAlignment,
        duration: const Duration(milliseconds: _kScrollDurationMs),
        curve: Curves.linear,
      );
    }
  }

  /// ✅ NAYA METHOD: Provider ki state ko manually sync karne ke liye
  void updateLastFocusedIdentifier(String identifier) {
    if (_visibleRowIdentifiers.contains(identifier)) {
      
      _lastFocusedIdentifier = identifier;
      notifyListeners();
      print('FocusProvider: Internal state updated manually to: $identifier');
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