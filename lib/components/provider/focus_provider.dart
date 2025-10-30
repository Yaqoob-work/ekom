








  

  // =================================================================
  // DISPOSE METHOD
  // =================================================================










// focus_provider.dart - Refactored (No Delays & Null-Safe)






// import 'package:flutter/material.dart';

// class FocusProvider extends ChangeNotifier {
//   // 1. सभी FocusNodes को स्टोर करने के लिए एक Map
//   final Map<String, FocusNode> _focusNodes = {};

//   // 2. स्क्रॉलिंग के लिए Element Keys
//   final Map<String, GlobalKey> _elementKeys = {};
//   final ScrollController scrollController = ScrollController();

//   // 3. बटन फोकस स्टेट
//   // bool _isButtonFocused = false;
//   // bool get isButtonFocused => _isButtonFocused;
//   // Color? _currentFocusColor;
//   // Color? get currentFocusColor => _currentFocusColor;



//   // --- जेनेरिक फोकस मेथड्स ---

//   /// किसी भी FocusNode को एक नाम के साथ रजिस्टर करें
//   void registerFocusNode(String identifier, FocusNode node) {
//     // अगर इस नाम से कोई पुराना नोड है, तो उसे dispose करें
//     // if (_focusNodes.containsKey(identifier)) {
//     //   _focusNodes[identifier]?.dispose();
//     // }
//     _focusNodes[identifier] = node;

//     // // 'watchNow' के लिए विशेष लिस्नर
//     // if (identifier == 'watchNow') {
//     //   node.addListener(() {
//     //     if (node.hasFocus) {
//     //       scrollToElement('watchNow');
//     //     }
//     //   });
//     // }
//     notifyListeners();
//   }

//   // /// किसी भी रजिस्टर्ड FocusNode पर नाम से फोकस करें (बिना देरी के)
//   // void requestFocus(String identifier) {
//   //   final node = _focusNodes[identifier];
//   //   if (node == null || !node.canRequestFocus) {
//   //     print('FocusProvider: $identifier के लिए कोई नोड नहीं मिला।');
//   //     return;
//   //   }

//   //   // हर identifier के लिए विशेष लॉजिक (बिना देरी के)
//   //   switch (identifier) {
//   //     // --- सीधे फोकस ---
//   //     case 'topNavigation':
//   //     case 'searchNavigation':
//   //     case 'searchIcon':
//   //       node.requestFocus();
//   //       break;

//   //     // --- फोकस + बटन स्टेट + स्क्रॉल ---
//   //     case 'watchNow':
//   //       node.requestFocus();
//   //       setButtonFocus(true);
//   //       scrollToElement('watchNow');
//   //       break;

//   //     // --- फोकस + स्क्रॉल --- (Delay Removed)
//   //     case 'liveChannelLanguage':
//   //     case 'manageMovies':
//   //     case 'religiousChannels':
//   //       node.requestFocus();
//   //       scrollToElement(identifier);
//   //       break;

//   //     // --- फोकस + प्रिंट + स्क्रॉल --- (Delay Removed)
//   //     case 'subVod': // (was horizontalListNetworks)
//   //     case 'tvShows':
//   //     case 'sportsCategory':
//   //     case 'tvShowsPak':
//   //       if (node.context != null) {
//   //         node.requestFocus();
//   //         print('✅ Focus requested for $identifier');
//   //         scrollToElement(identifier);
//   //       }
//   //       break;

//   //     // --- डिफॉल्ट केस ---
//   //     default:
//   //       node.requestFocus();
//   //   }
//   // }

// // ❗️ फ़ाइल: focus_provider.dart
// // ❗️ FocusProvider -> requestFocus

//   void requestFocus(String identifier) {
//     final node = _focusNodes[identifier];
//     if (node == null) { // ❗️ simplified check
//       print('FocusProvider: $identifier के लिए कोई नोड नहीं मिला।');
//       return;
//     }

//     // ❗️❗️ FIX 3: YAHAN EK DELAY DAALEIN ❗️❗️
//     // Focus ko ek widget se doosre widget mein move karne ke liye 
//     // ek frame ka intezaar karna (ya 10ms) sabse safe hai.
//     Future.delayed(const Duration(milliseconds: 10), () {
//       if (!node.canRequestFocus) {
//          print('FocusProvider: $identifier पर फोकस नहीं किया जा सकता।');
//          return;
//       }

//     // ab har identifier ke liye special logic
//     switch (identifier) {
//       // --- Seedhe focus ---
//       case 'topNavigation':
//       case 'searchNavigation':
//       case 'searchIcon':
//         node.requestFocus();
//         break;

//       // // --- Focus + button state + scroll ---
//       // case 'watchNow':
//       //   node.requestFocus();
//       //   // setButtonFocus(true);
//       //   scrollToElement('watchNow');
//       //   break;

//       // --- Focus + scroll ---
//       case 'watchNow':
//       case 'liveChannelLanguage':
//       case 'subVod':
//       case 'manageMovies': // ⬅️ YEH AAPKA CASE HAI
//       case 'manageWebseries':
//       case 'tvShows':
//       case 'sportsCategory':
//       case 'religiousChannels':
//       case 'tvShowsPak':
//         node.requestFocus(); // ❗️ Ab yeh delay ke baad run hoga
//         scrollToElement(identifier);
//         break;

//       // // --- Focus + print + scroll ---
       
      
//       //   if (node.context != null) {
//       //     node.requestFocus(); // ❗️ Ab yeh delay ke baad run hoga
//       //     print('✅ Focus requested for $identifier');
//       //     scrollToElement(identifier);
//       //   }
//       //   break;

//       // --- Default case ---
//       default:
//         node.requestFocus();
//     }
//   }); // ❗️ Delay wrapper ko yahan band karein
//   }


//   // --- वेब-सीरीज़ (बिना देरी के) ---

//   // void setFirstWebseriesFocusNode(Future<void> Function() callback) {
//   //   _requestFirstWebseriesFocusCallback = callback;
//   // }

//   // void requestFirstWebseriesFocus() {
//   //   _requestFirstWebseriesFocusCallback?.call();
//   //   // Delay हटा दिया गया
//   //   scrollToElement('manageWebseries');
//   // }

//   // --- अन्य मेथड्स (पहले जैसे ही) ---

//   // void setButtonFocus(bool focused, {Color? color}) {
//   //   _isButtonFocused = focused;
//   //   if (focused) {
//   //     _currentFocusColor = color;
//   //   }
//   //   notifyListeners();
//   // }

//   // void resetFocus() {
//   //   _isButtonFocused = false;
//   //   _currentFocusColor = null;
//   //   notifyListeners();
//   // }

//   // --- स्क्रॉलिंग मेथड्स (पहले जैसे ही) ---

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

//   // --- 🌟 FIX HERE 🌟 ---
//   // 'key' null हो सकता है, इसलिए 'key.currentContext' को
//   // एक्सेस करने के बजाय 'key?.currentContext' का उपयोग करें।
//   void scrollToElement(String identifier) {
//     final key = _elementKeys[identifier];
    
//     // key?.currentContext का उपयोग करने से:
//     // 1. अगर key null है, तो 'context' null हो जाएगा।
//     // 2. अगर key null नहीं है, तो 'context' को 'currentContext' की वैल्यू मिल जाएगी।
//     final BuildContext? context = key?.currentContext;

//     // अगर context null नहीं है (मतलब key भी null नहीं था और currentContext भी null नहीं था)
//     if (context != null) {
//       Scrollable.ensureVisible(
//         context,
//         alignment: 0.05,
//         duration: const Duration(milliseconds: 800),
//         curve: Curves.linear,
//       );
//     }
//   }

//   // --- Dispose ---
//   @override
//   void dispose() {
//     scrollController.dispose();
//     // Map में मौजूद सभी FocusNodes को एक साथ dispose करें
//     for (var node in _focusNodes.values) {
//       node.dispose();
//     }
//     _focusNodes.clear();
//     super.dispose();
//   }
// }





// // focus_provider.dart - Refactored and Shorter
// import 'package:flutter/material.dart';

// class FocusProvider extends ChangeNotifier {
//   // 1. सभी FocusNodes को स्टोर करने के लिए एक Map
//   final Map<String, FocusNode> _focusNodes = {};

//   // 2. स्क्रॉलिंग के लिए Element Keys (यह पहले जैसा ही है)
//   final Map<String, GlobalKey> _elementKeys = {};
//   final ScrollController scrollController = ScrollController();

//   // 3. बटन फोकस स्टेट (यह पहले जैसा ही है)
//   bool _isButtonFocused = false;
//   bool get isButtonFocused => _isButtonFocused;
//   Color? _currentFocusColor;
//   Color? get currentFocusColor => _currentFocusColor;

//   // 4. वेब-सीरीज़ के लिए विशेष कॉलबैक (यह अलग था, इसलिए इसे अलग रखा गया है)
//   Future<void> Function()? _requestFirstWebseriesFocusCallback;

//   // --- जेनेरिक फोकस मेथड्स ---

//   /// किसी भी FocusNode को एक नाम के साथ रजिस्टर करें
//   void registerFocusNode(String identifier, FocusNode node) {
//     // अगर इस नाम से कोई पुराना नोड है, तो उसे dispose करें
//     if (_focusNodes.containsKey(identifier)) {
//       _focusNodes[identifier]?.dispose();
//     }
//     _focusNodes[identifier] = node;

//     // 'watchNow' के लिए विशेष लिस्नर
//     if (identifier == 'watchNow') {
//       node.addListener(() {
//         if (node.hasFocus) {
//           scrollToElement('watchNow');
//         }
//       });
//     }
//     notifyListeners();
//   }

//   /// किसी भी रजिस्टर्ड FocusNode पर नाम से फोकस करें
//   void requestFocus(String identifier) {
//     final node = _focusNodes[identifier];
//     if (node == null || !node.canRequestFocus) {
//       print('FocusProvider: $identifier के लिए कोई नोड नहीं मिला।');
//       return;
//     }

//     // हर identifier के लिए विशेष लॉजिक (जो आपके पुराने request... मेथड्स में था)
//     switch (identifier) {
//       // --- सीधे फोकस ---
//       case 'topNavigation':
//       case 'searchNavigation':
//       case 'searchIcon':
//         node.requestFocus();
//         break;

//       // --- फोकस + बटन स्टेट + स्क्रॉल ---
//       case 'watchNow':
//         node.requestFocus();
//         setButtonFocus(true);
//         scrollToElement('watchNow');
//         break;

//       // --- देरी + फोकस + देरी + स्क्रॉल ---
//       case 'liveChannelLanguage':
//       case 'manageMovies':
//       case 'religiousChannels':
//         Future.delayed(const Duration(milliseconds: 50), () {
//           node.requestFocus();
//           Future.delayed(const Duration(milliseconds: 50), () {
//             scrollToElement(identifier);
//           });
//         });
//         break;

//       // --- फोकस + प्रिंट + स्क्रॉल (कुछ में डबल स्क्रॉल) ---
//       case 'subVod': // (was horizontalListNetworks)
//       case 'tvShows':
//       case 'sportsCategory':
//       case 'tvShowsPak':
//         if (node.context != null) {
//           node.requestFocus();
//           print('✅ Focus requested for $identifier');
//           scrollToElement(identifier);

//           if (identifier == 'tvShows' || identifier == 'sportsCategory') {
//             Future.delayed(const Duration(milliseconds: 50), () {
//               scrollToElement(identifier);
//             });
//           }
//         }
//         break;

//       // --- डिफॉल्ट केस ---
//       default:
//         node.requestFocus();
//     }
//   }

//   // --- वेब-सीरीज़ (यह अलग लॉजिक का उपयोग करता है) ---

//   void setFirstWebseriesFocusNode(Future<void> Function() callback) {
//     _requestFirstWebseriesFocusCallback = callback;
//   }

//   void requestFirstWebseriesFocus() {
//     _requestFirstWebseriesFocusCallback?.call();
//     Future.delayed(const Duration(milliseconds: 200), () {
//       scrollToElement('manageWebseries');
//     });
//   }

//   // --- अन्य मेथड्स (पहले जैसे ही) ---

//   void setButtonFocus(bool focused, {Color? color}) {
//     _isButtonFocused = focused;
//     if (focused) {
//       _currentFocusColor = color;
//     }
//     notifyListeners();
//   }

//   void resetFocus() {
//     _isButtonFocused = false;
//     _currentFocusColor = null;
//     notifyListeners();
//   }

//   // --- स्क्रॉलिंग मेथड्स (पहले जैसे ही) ---

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
//     if (key?.currentContext == null) {
//       return;
//     }
//     final BuildContext? context = key?.currentContext;
//     if (context != null) {
//       Scrollable.ensureVisible(
//         context,
//         alignment: 0.05,
//         duration: const Duration(milliseconds: 800),
//         curve: Curves.linear,
//       );
//     }
//   }

//   // --- Dispose ---
//   @override
//   void dispose() {
//     scrollController.dispose();
//     // Map में मौजूद सभी FocusNodes को एक साथ dispose करें
//     for (var node in _focusNodes.values) {
//       node.dispose();
//     }
//     _focusNodes.clear();
//     super.dispose();
//   }
// }






// import 'package:flutter/material.dart';

// class FocusProvider extends ChangeNotifier {
//   final Map<String, FocusNode> _focusNodes = {};
//   final Map<String, GlobalKey> _elementKeys = {};
//   final ScrollController scrollController = ScrollController();

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

//     Future.delayed(const Duration(milliseconds: 10), () {
//       if (!node.canRequestFocus) {
//         print('FocusProvider: $identifier पर फोकस नहीं किया जा सकता।');
//         return;
//       }

//       switch (identifier) {
//         case 'topNavigation':
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
//         case 'sportsCategory':
//         case 'religiousChannels':
//         case 'tvShowsPak':
//           node.requestFocus();
//           scrollToElement(identifier);
//           break;

//         default:
//           node.requestFocus();
//       }
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

//     if (context != null) {
//       Scrollable.ensureVisible(
//         context,
//         alignment: 0.05,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.linear,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     scrollController.dispose();
//     for (var node in _focusNodes.values) {
//       node.dispose();
//     }
//     _focusNodes.clear();
//     super.dispose();
//   }
// }




// import 'package:flutter/material.dart';
// import 'dart:async'; // Timer ke liye yeh import add karein

// class FocusProvider extends ChangeNotifier {
//   final Map<String, FocusNode> _focusNodes = {};
//   final Map<String, GlobalKey> _elementKeys = {};
//   final ScrollController scrollController = ScrollController();

//   // --- NAVIGATION LOCK VARIABLES ---
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   // In identifiers ki list banayein jin par lock lagana hai
//   // Yeh woh items hain jo horizontal lists mein ho sakte hain
//   final Set<String> _lockableIdentifiers = {
//     'watchNow',
//     'liveChannelLanguage',
//     'subVod',
//     'manageMovies',
//     'manageWebseries',
//     'tvShows',
//     'sportsCategory',
//     'religiousChannels',
//     'tvShowsPak',
//     // Aap is list mein aur identifiers add kar sakte hain
//   };
//   // ---------------------------------

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

//     // --- YAHAN BADLAV KIYA GAYA HAI ---

//     // 1. Check karein ki kya is identifier par lock lagna chahiye
//     final bool requiresLock = _lockableIdentifiers.contains(identifier);

//     // 2. Agar lock chahiye aur navigation pehle se locked hai, toh request ignore karein
//     if (requiresLock && _isNavigationLocked) {
//       print('FocusProvider: Navigation locked, request for $identifier ignored.');
//       return;
//     }

//     // 3. Agar lock chahiye, toh lock set karein aur timer start karein
//     if (requiresLock) {
//       _isNavigationLocked = true;
//       _navigationLockTimer?.cancel(); // Purana timer (agar hai) cancel karein
//       _navigationLockTimer = Timer(const Duration(milliseconds: 400), () { 
//         // Duration 400ms se 600ms rakh sakte hain
//         _isNavigationLocked = false;
//       });
//     }
//     // --- BADLAV KHATAM ---

//     Future.delayed(const Duration(milliseconds: 10), () {
//       if (!node.canRequestFocus) {
//         print('FocusProvider: $identifier पर फोकस नहीं किया जा सकता।');
        
//         // Agar focus request fail ho, toh lock turant hata dein
//         if (requiresLock) {
//           _isNavigationLocked = false;
//           _navigationLockTimer?.cancel();
//         }
//         return;
//       }

//       switch (identifier) {
//         case 'topNavigation':
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
//         case 'sportsCategory':
//         case 'religiousChannels':
//         case 'tvShowsPak':
//           node.requestFocus();
//           scrollToElement(identifier);
//           break;

//         default:
//           node.requestFocus();
//       }
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

//     if (context != null) {
//       Scrollable.ensureVisible(
//         context,
//         alignment: 0.05,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.linear,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel(); // Dispose mein timer ko cancel karna zaroori hai
//     scrollController.dispose();
//     for (var node in _focusNodes.values) {
//       node.dispose();
//     }
//     _focusNodes.clear();
//     super.dispose();
//   }
// }



// import 'package:flutter/material.dart';
// import 'dart:async'; // Timer ke liye yeh import add karein

// class FocusProvider extends ChangeNotifier {
//   final Map<String, FocusNode> _focusNodes = {};
//   final Map<String, GlobalKey> _elementKeys = {};
//   final ScrollController scrollController = ScrollController();

//   // --- DURATION CONSTANTS ---
//   // Lock 1 second (1000ms) tak rahega
//   static const int _kLockDurationMs = 11; // <-- YEH LOCK KE LIYE HAI
//   // Scroll animation 800ms tak chalega
//   static const int _kScrollDurationMs = 800; // <-- YEH SCROLL KE LIYE HAI
//   // -------------------------

//   // --- NAVIGATION LOCK VARIABLES ---
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;
//   String _lastFocusedIdentifier = '';

//   final Set<String> _lockableIdentifiers = {
//     'watchNow',
//     'liveChannelLanguage',
//     'subVod',
//     'manageMovies',
//     'manageWebseries',
//     'tvShows',
//     'sportsCategory',
//     'religiousChannels',
//     'tvShowsPak',
//   };
//   // ---------------------------------

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

//     // Agar lock chahiye aur navigation pehle se locked hai, toh request ignore karein
//     if (shouldApplyLock && _isNavigationLocked) {
//       print(
//           'FocusProvider: Navigation locked, request for $identifier ignored.');
//       return; // <-- YAHIN PAR REQUEST IGNORE HOTI HAI
//     }

//     // Agar lock chahiye, toh lock set karein
//     if (shouldApplyLock) {
//       _isNavigationLocked = true;
//       _navigationLockTimer?.cancel();
//       // Lock ke liye _kLockDurationMs (1000ms) ka istemal karein
//       _navigationLockTimer = Timer(
//           const Duration(milliseconds: _kLockDurationMs), () { 
//         _isNavigationLocked = false;
//       });
//     }
//     // --- LOCK LOGIC KHATAM ---

//     // Future.delayed ko 10ms par set karein
//     Future.delayed(const Duration(milliseconds: 10), () { 
//       if (!node.canRequestFocus) {
//         print('FocusProvider: $identifier पर फोकस नहीं किया जा सकता।');
//         if (shouldApplyLock) {
//           _isNavigationLocked = false;
//           _navigationLockTimer?.cancel();
//         }
//         return;
//       }

//       _lastFocusedIdentifier = identifier;

//       // --- SWITCH CASE WALA TAREEKA WAPAS ---
//       switch (identifier) {
//         case 'topNavigation':
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
//         case 'sportsCategory':
//         case 'religiousChannels':
//         case 'tvShowsPak':
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

//     if (context != null) {
//       Scrollable.ensureVisible(
//         context,
//         alignment: 0.05,
//         // Scroll ke liye _kScrollDurationMs (800ms) ka istemal karein
//         duration: const Duration(milliseconds: _kScrollDurationMs), // <-- BADLAV YAHAN
//         curve: Curves.easeOut,
//       );
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




// import 'package:flutter/material.dart';
// import 'dart:async'; // Timer ke liye yeh import add karein

// class FocusProvider extends ChangeNotifier {
//   final Map<String, FocusNode> _focusNodes = {};
//   final Map<String, GlobalKey> _elementKeys = {};
//   final ScrollController scrollController = ScrollController();

//   // --- DURATION CONSTANTS ---
//   static const int _kLockDurationMs = 11; // <-- YEH LOCK KE LIYE HAI
//   static const int _kScrollDurationMs = 800; // <-- YEH SCROLL KE LIYE HAI
//   // -------------------------

//   // --- NAVIGATION LOCK VARIABLES ---
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;
//   String _lastFocusedIdentifier = '';
//   // ---------------------------------

//   // --- NAYA VARIABLE ---
//   // Yeh list sirf visible rows ke identifiers rakhegi
//   List<String> _visibleRowIdentifiers = [];
//   // -------------------

//   // --- MODIFIED SET ---
//   // Yeh IDs `HomeScreen` mein register ki gayi keys se *bilkul* match honi chahiye
//   final Set<String> _lockableIdentifiers = {
//     'watchNow',
//     'liveChannelLanguage',
//     'subVod',
//     'manageMovies',
//     'manageWebseries',
//     'tvShows',
//     'sportsCategory',
//     'religiousChannels', // HomeScreen mein 'religiousChannels' register kiya tha
//     'tvShowPak',         // HomeScreen mein 'tvShowPak' register kiya tha
//   };
//   // ---------------------------------

//   // --- NAYA METHOD ---
//   /// HomeScreen is method ko call karke visible rows ki list update karega
//   void updateVisibleRowIdentifiers(List<String> identifiers) {
//     _visibleRowIdentifiers = identifiers;
//     // Hum notifyListeners() nahi call kar rahe kyunki
//     // UI ko is list ke change hone par rebuild hone ki zaroorat nahi hai.
//   }
//   // --------------------

//   // --- NAYE NAVIGATION METHODS ---

//   /// Agli VISIBLE row par focus karta hai.
//   /// Yeh method aapke row widgets (jaise BannerSlider, LiveChannelLanguageScreen)
//   /// ke 'Arrow Down' key event par call hona chahiye.
//   void focusNextRow() {
//     // Check karo ki last focus kahan tha
//     final currentIndex = _visibleRowIdentifiers.indexOf(_lastFocusedIdentifier);

//     if (currentIndex == -1 && _visibleRowIdentifiers.isNotEmpty) {
//       // Agar kisi row par focus nahi hai, toh pehli visible row par focus karo
//       requestFocus(_visibleRowIdentifiers[0]);
//     } else if (currentIndex < _visibleRowIdentifiers.length - 1) {
//       // Agar list ke aakhir mein nahi hain, toh agli row par jao
//       final String nextIdentifier = _visibleRowIdentifiers[currentIndex + 1];
//       requestFocus(nextIdentifier);
//     }
//     // Agar aakhri row par hain, toh kuch mat karo
//   }

//   /// Pichli VISIBLE row par focus karta hai.
//   /// Yeh method aapke row widgets ke 'Arrow Up' key event par call hona chahiye.
//   void focusPreviousRow() {
//     // Check karo ki last focus kahan tha
//     final currentIndex = _visibleRowIdentifiers.indexOf(_lastFocusedIdentifier);

//     if (currentIndex > 0) {
//       // Agar pehli row par nahi hain, toh pichli row par jao
//       final String prevIdentifier = _visibleRowIdentifiers[currentIndex - 1];
//       requestFocus(prevIdentifier);
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

//   /// Yeh method rows ke andar (left/right) navigation, ya
//   /// naye methods (focusNextRow/focusPreviousRow) ke zariye call hoga.
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
//       print(
//           'FocusProvider: Navigation locked, request for $identifier ignored.');
//       return; // <-- YAHIN PAR REQUEST IGNORE HOTI HAI
//     }

//     if (shouldApplyLock) {
//       _isNavigationLocked = true;
//       _navigationLockTimer?.cancel();
//       // Lock ke liye _kLockDurationMs ka istemal karein
//       _navigationLockTimer = Timer(
//           const Duration(milliseconds: _kLockDurationMs), () {
//         _isNavigationLocked = false;
//       });
//     }
//     // --- LOCK LOGIC KHATAM ---

//     // Future.delayed ko 10ms par set karein
//     Future.delayed(const Duration(milliseconds: 10), () {
//       if (!node.canRequestFocus) {
//         print('FocusProvider: $identifier पर फोकस नहीं किया जा सकता।');
//         if (shouldApplyLock) {
//           _isNavigationLocked = false;
//           _navigationLockTimer?.cancel();
//         }
//         return;
//       }

//       // --- MODIFIED ---
//       // Last focused item ko update karein,
//       // taaki 'focusNextRow' aur 'focusPreviousRow' kaam kar sakein
//       if (_visibleRowIdentifiers.contains(identifier)) {
//         _lastFocusedIdentifier = identifier;
//       }
//       // ----------------

//       // --- MODIFIED SWITCH CASE ---
//       // IDs ko _lockableIdentifiers se match karein
//       switch (identifier) {
//         case 'topNavigation':
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
//         case 'sportsCategory':
//         case 'religiousChannels': // ID Matched
//         case 'tvShowPak':         // ID Matched
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

//     if (context != null) {
//       Scrollable.ensureVisible(
//         context,
//         alignment: 0.05,
//         // Scroll ke liye _kScrollDurationMs (800ms) ka istemal karein
//         duration: const Duration(milliseconds: _kScrollDurationMs),
//         curve: Curves.easeOut,
//       );
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
  static const int _kLockDurationMs = 11; 
  static const int _kScrollDurationMs = 800; 

  // --- NAVIGATION LOCK VARIABLES ---
  bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;
  String _lastFocusedIdentifier = '';

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
    'sportsCategory',
    'religiousChannels',
    'tvShowPak',
  };

  void updateVisibleRowIdentifiers(List<String> identifiers) {
    _visibleRowIdentifiers = identifiers;
  }

  // --- NAYE NAVIGATION METHODS ---

  /// ✅ [UPDATED] Agli VISIBLE aur REGISTERED row par focus karta hai.
  void focusNextRow() {
    _lastNavigationDirection = 'down';
    final currentIndex = _visibleRowIdentifiers.indexOf(_lastFocusedIdentifier);

    if (currentIndex == -1 && _visibleRowIdentifiers.isNotEmpty) {
      // Agar kisi row par focus nahi hai, toh pehli visible row par focus karo
      requestFocus(_visibleRowIdentifiers[0]);
    } else if (currentIndex < _visibleRowIdentifiers.length - 1) {
      
      // --- NAYA LOGIC (Race Condition Fix) ---
      // Agle item se check karna shuru karein
      for (int i = currentIndex + 1; i < _visibleRowIdentifiers.length; i++) {
        final String nextIdentifier = _visibleRowIdentifiers[i];
        final node = _focusNodes[nextIdentifier]; // Check karein ki node register hai ya nahi

        if (node != null && node.canRequestFocus) {
          // Valid, registered node mil gaya. Focus karein.
          print('FocusProvider: focusNextRow attempting: $nextIdentifier');
          requestFocus(nextIdentifier);
          return; // Loop band karein
        } else {
          // Node ya toh null hai (register nahi hua) ya focus nahi ho sakta.
          // Loop ko agle item ke liye jaari rakhein.
          print('FocusProvider: focusNextRow skipping: $nextIdentifier (not registered yet)');
        }
      }
      // Agar loop poora ho gaya aur koi node nahi mila
      print('FocusProvider: focusNextRow found no available nodes after $_lastFocusedIdentifier');
      // --- NAYA LOGIC KHATAM ---
    }
  }

  /// ✅ [UPDATED] Pichli VISIBLE aur REGISTERED row par focus karta hai.
  void focusPreviousRow() {
    _lastNavigationDirection = 'up';
    final currentIndex = _visibleRowIdentifiers.indexOf(_lastFocusedIdentifier);

    if (currentIndex > 0) {
      
      // --- NAYA LOGIC (Race Condition Fix) ---
      // Pichle item se check karna shuru karein
      for (int i = currentIndex - 1; i >= 0; i--) {
        final String prevIdentifier = _visibleRowIdentifiers[i];
        final node = _focusNodes[prevIdentifier]; // Check karein ki node register hai ya nahi

        if (node != null && node.canRequestFocus) {
          // Valid, registered node mil gaya. Focus karein.
          print('FocusProvider: focusPreviousRow attempting: $prevIdentifier');
          requestFocus(prevIdentifier);
          return; // Loop band karein
        } else {
          // Node ya toh null hai (register nahi hua) ya focus nahi ho sakta.
          // Loop ko pichle item ke liye jaari rakhein.
          print('FocusProvider: focusPreviousRow skipping: $prevIdentifier (not registered yet)');
        }
      }
      // Agar loop poora ho gaya aur koi node nahi mila
      print('FocusProvider: focusPreviousRow found no available nodes before $_lastFocusedIdentifier');
      // --- NAYA LOGIC KHATAM ---

    } else if (currentIndex == 0) {
      // Yahan aap Top Navigation Bar ya Search icon par focus bhej sakte hain
      // requestFocus('topNavigation');
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
      _navigationLockTimer = Timer(
          const Duration(milliseconds: _kLockDurationMs), () { 
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
        case 'sportsCategory':
        case 'religiousChannels':
        case 'tvShowPak': 
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
                                    ? 0.5   // Center mein (ArrowUp ke liye)
                                    : 0.05; // Top par (ArrowDown ke liye)
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: targetAlignment,
        duration: const Duration(milliseconds: _kScrollDurationMs),
        curve: Curves.easeOut,
      );
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