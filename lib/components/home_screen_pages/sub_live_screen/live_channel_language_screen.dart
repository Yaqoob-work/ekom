// import 'dart:async';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_live_screen/language_channel_screen.dart';
// import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_loading_widget.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_retry_widget.dart';
// // ✅ Import Smart Widgets
// import 'package:provider/provider.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AnimationTiming {
//   static const Duration ultraFast = Duration(milliseconds: 150);
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration focus = Duration(milliseconds: 300);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// class Language {
//   final int id;
//   final String title;
//   final String logoUrl;
//   Language({required this.id, required this.title, required this.logoUrl});
//   factory Language.fromJson(Map<String, dynamic> json) {
//     return Language(
//         id: json['id'] ?? 0,
//         title: json['title'] ?? '',
//         logoUrl: json['logo'] ?? '');
//   }
// }

// class LiveChannelLanguageScreen extends StatefulWidget {
//   const LiveChannelLanguageScreen({Key? key}) : super(key: key);
//   @override
//   State<LiveChannelLanguageScreen> createState() =>
//       _LiveChannelLanguageScreenState();
// }

// class _LiveChannelLanguageScreenState extends State<LiveChannelLanguageScreen>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<Language> _languages = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isNavigating = false;

//   // ✅ Shadow State
//   bool _isSectionFocused = false;

//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   Map<String, FocusNode> languageFocusNodes = {};
//   Color _currentAccentColor = ProfessionalColorsForHomePages.accentBlue;
//   FocusNode? _firstLanguageFocusNode;

//   final FocusNode _retryFocusNode = FocusNode();
//   final ScrollController _scrollController = ScrollController();

//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _fetchLanguages();
//   }

//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();
//     _retryFocusNode.dispose();

//     String? firstLanguageId;
//     if (_languages.isNotEmpty) {
//       firstLanguageId = _languages[0].id.toString();
//     }

//     for (var entry in languageFocusNodes.entries) {
//       if (entry.key != firstLanguageId) {
//         try {
//           entry.value.dispose();
//         } catch (e) {}
//       }
//     }
//     languageFocusNodes.clear();
//     _scrollController.dispose();
//     _isNavigating = false;
//     super.dispose();
//   }

//   // void _setupFocusProvider() {
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     if (mounted) {
//   //       try {
//   //         final focusProvider =
//   //             Provider.of<FocusProvider>(context, listen: false);
//   //         if (_languages.isNotEmpty) {
//   //           final firstLanguageId = _languages[0].id.toString();
//   //           if (languageFocusNodes.containsKey(firstLanguageId)) {
//   //             _firstLanguageFocusNode = languageFocusNodes[firstLanguageId];
//   //           } else {
//   //             _firstLanguageFocusNode = FocusNode();
//   //             languageFocusNodes[firstLanguageId] = _firstLanguageFocusNode!;
//   //           }
//   //           if (_firstLanguageFocusNode != null) {
//   //             focusProvider.registerFocusNode(
//   //                 'liveChannelLanguage', _firstLanguageFocusNode!);
//   //             _firstLanguageFocusNode!.addListener(() {
//   //               if (!mounted) return;
//   //               if (_firstLanguageFocusNode!.hasFocus) {
//   //                 _scrollToFocusedItem(firstLanguageId);
//   //               }
//   //             });

//   //             // ✅ FORCE FOCUS FOR LIVE SCREEN (As requested for initial focus)
//   //             focusProvider.updateLastFocusedIdentifier('liveChannelLanguage');
//   //             _firstLanguageFocusNode!.requestFocus();
//   //           }
//   //         } else if (_errorMessage.isNotEmpty) {
//   //           focusProvider.registerFocusNode(
//   //               'liveChannelLanguage', _retryFocusNode);
//   //           focusProvider.updateLastFocusedIdentifier('liveChannelLanguage');
//   //           _retryFocusNode.requestFocus();
//   //         }
//   //       } catch (e) {
//   //         print('❌ Focus provider setup failed: $e');
//   //       }
//   //     }
//   //   });
//   // }


//   void _setupFocusProvider() {
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     if (mounted) {
//       try {
//         final focusProvider = Provider.of<FocusProvider>(context, listen: false);
//         final String myId = 'liveChannelLanguage'; // Is page ka identifier

//         if (_languages.isNotEmpty) {
//           final firstLanguageId = _languages[0].id.toString();
          
//           // Focus node assign karna
//           if (languageFocusNodes.containsKey(firstLanguageId)) {
//             _firstLanguageFocusNode = languageFocusNodes[firstLanguageId];
//           } else {
//             _firstLanguageFocusNode = FocusNode();
//             languageFocusNodes[firstLanguageId] = _firstLanguageFocusNode!;
//           }

//           if (_firstLanguageFocusNode != null) {
//             // 1. Register karein
//             focusProvider.registerFocusNode(myId, _firstLanguageFocusNode!);

//             // 2. ✅ CRITICAL FIX: Agar Dashboard isi page ka intezar kar raha hai
//             if (focusProvider.lastFocusedIdentifier == myId) {
//               _firstLanguageFocusNode!.requestFocus();
//             }

//             _firstLanguageFocusNode!.addListener(() {
//               if (!mounted) return;
//               if (_firstLanguageFocusNode!.hasFocus) {
//                 _scrollToFocusedItem(firstLanguageId);
//               }
//             });
//           }
//         }
//       } catch (e) {
//         print('❌ Focus provider setup failed: $e');
//       }
//     }
//   });
// }

//   void _initializeAnimations() {
//     _headerAnimationController =
//         AnimationController(duration: AnimationTiming.slow, vsync: this);
//     _listAnimationController =
//         AnimationController(duration: AnimationTiming.slow, vsync: this);
//     _headerSlideAnimation =
//         Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
//             CurvedAnimation(
//                 parent: _headerAnimationController,
//                 curve: Curves.easeOutCubic));
//     _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(
//             parent: _listAnimationController, curve: Curves.easeInOut));
//   }

//   Future<void> _fetchLanguages() async {
//     if (!mounted) return;
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });
//     try {
//       String authKey = SessionManager.authKey;
//       var url = Uri.parse(SessionManager.baseUrl + 'getAllLanguages');
//       final response = await https.get(url, headers: {
//         'auth-key': authKey,
//         'Content-Type': 'application/json',
//         'domain': SessionManager.savedDomain
//       }).timeout(const Duration(seconds: 20));
//       if (mounted && response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List<dynamic> languagesJson = data['languages'] ?? [];
//         if (mounted) {
//            setState(() {
//             _languages =
//                 languagesJson.map((json) => Language.fromJson(json)).toList();
//             _languages.sort((a, b) => a.id.compareTo(b.id));
//             _isLoading = false;
//             _initializeLanguageFocusNodes();
//           });
//   //         // NAYA: Data aane ke baad focus ko pakad kar rakhein
//   // Future.delayed(const Duration(milliseconds: 200), () {
//   //   if (mounted && _firstLanguageFocusNode != null) {
//   //     _firstLanguageFocusNode!.requestFocus();
//   //     print("🔥 Live Channel focused after API load");
//   //   }
//   // });
//    _restoreInternalFocus(); 
//         }
//         _headerAnimationController.forward();
//         _listAnimationController.forward();
//         _setupFocusProvider();
//       } else if (mounted) {
//         setState(() {
//           _errorMessage = "Failed: ${response.statusCode}";
//           _isLoading = false;
//         });
//         _setupFocusProvider();
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = "Network error";
//           _isLoading = false;
//         });
//         _setupFocusProvider();
//       }
//     }
//   }

//   void _initializeLanguageFocusNodes() {
//     languageFocusNodes.clear();
//     for (int i = 0; i < _languages.length; i++) {
//       var language = _languages[i];
//       try {
//         String languageId = language.id.toString();
//         languageFocusNodes[languageId] = FocusNode();
//         if (i > 0) {
//           languageFocusNodes[languageId]!.addListener(() {
//             if (!mounted) return;
//             if (languageFocusNodes[languageId]!.hasFocus) {
//               _scrollToFocusedItem(languageId);
//             }
//           });
//         }
//       } catch (e) {}
//     }
//   }

//   void _scrollToFocusedItem(String itemId) {
//     if (!mounted || !_scrollController.hasClients) return;
//     try {
//       int index =
//           _languages.indexWhere((language) => language.id.toString() == itemId);
//       if (index == -1) return;
//       double itemWidth =
//           (bannerwdt ?? MediaQuery.of(context).size.width * 0.18) + 12;
//       double targetScrollPosition = (index * itemWidth);
//       targetScrollPosition = targetScrollPosition.clamp(
//           0.0, _scrollController.position.maxScrollExtent);
//       _scrollController.animateTo(targetScrollPosition,
//           duration: const Duration(milliseconds: 400),
//           curve: Curves.easeOutCubic);
//     } catch (e) {}
//   }

//   // void _handleLanguageTap(Language language) async {
//   //   if (_isNavigating) return;
//   //   if (!mounted) return;
//   //   setState(() { _isNavigating = true; });
//   //   await Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageChannelsScreen(languageId: language.id.toString(), languageName: language.title)));
//   //   Future.delayed(Duration(milliseconds: 200), () { if (mounted) setState(() { _isNavigating = false; }); });
//   // }

//   void _handleLanguageTap(Language language) async {
//     if (_isNavigating || !mounted) return;

//     final focusProvider = Provider.of<FocusProvider>(context, listen: false);

//     // ✅ Save current state in Provider
//     focusProvider.updateLastFocusedIdentifier('liveChannelLanguage');
//     focusProvider.updateLastFocusedItemId(language.id.toString());

//     setState(() => _isNavigating = true);

//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LanguageChannelsScreen(
//           languageId: language.id.toString(),
//           languageName: language.title,
//         ),
//       ),
//     );

//     if (!mounted) return;
//     setState(() => _isNavigating = false);

//     // ✅ Restore focus when coming back
//     // _restoreFocusAfterNavigation();
//   }

//   // Widget _buildLanguageItem(Language language, int index, double screenWidth, double screenHeight) {
//   //   String languageId = language.id.toString();
//   //   FocusNode? focusNode = languageFocusNodes[languageId];
//   //   if (focusNode == null) return const SizedBox.shrink();

//   //   return Focus(
//   //     focusNode: focusNode,
//   //     onFocusChange: (hasFocus) async {
//   //        if (!mounted) return;
//   //        // ✅ Update Shadow
//   //        setState(() => _isSectionFocused = hasFocus);

//   //       if (hasFocus) {
//   //         try {
//   //           Color dominantColor = ProfessionalColorsForHomePages.gradientColors[math.Random().nextInt(ProfessionalColorsForHomePages.gradientColors.length)];
//   //            if (!mounted) return;
//   //           setState(() { _currentAccentColor = dominantColor; });
//   //           context.read<ColorProvider>().updateColor(dominantColor, true);
//   //         } catch (e) {}
//   //       } else {
//   //         context.read<ColorProvider>().resetColor();
//   //       }
//   //     },
//   //     onKey: (FocusNode node, RawKeyEvent event) {
//   //       if (event is RawKeyDownEvent) {
//   //         final key = event.logicalKey;
//   //         if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.arrowLeft) {
//   //           if (_isNavigationLocked) return KeyEventResult.handled;
//   //            if (!mounted) return KeyEventResult.ignored;
//   //           setState(() => _isNavigationLocked = true);
//   //           _navigationLockTimer = Timer(const Duration(milliseconds: 600), () { if (mounted) setState(() => _isNavigationLocked = false); });
//   //           if (key == LogicalKeyboardKey.arrowRight) {
//   //             if (index < _languages.length - 1) {
//   //               String nextLanguageId = _languages[index + 1].id.toString();
//   //                if (languageFocusNodes.containsKey(nextLanguageId)) FocusScope.of(context).requestFocus(languageFocusNodes[nextLanguageId]);
//   //                else { _navigationLockTimer?.cancel(); if (mounted) setState(() => _isNavigationLocked = false); }
//   //             } else { _navigationLockTimer?.cancel(); if (mounted) setState(() => _isNavigationLocked = false); }
//   //           } else if (key == LogicalKeyboardKey.arrowLeft) {
//   //             if (index > 0) {
//   //               String prevLanguageId = _languages[index - 1].id.toString();
//   //                if (languageFocusNodes.containsKey(prevLanguageId)) FocusScope.of(context).requestFocus(languageFocusNodes[prevLanguageId]);
//   //                else { _navigationLockTimer?.cancel(); if (mounted) setState(() => _isNavigationLocked = false); }
//   //             } else { _navigationLockTimer?.cancel(); if (mounted) setState(() => _isNavigationLocked = false); }
//   //           }
//   //           return KeyEventResult.handled;
//   //         }
//   //         if (key == LogicalKeyboardKey.arrowUp) {
//   //           context.read<ColorProvider>().resetColor();
//   //           FocusScope.of(context).unfocus();
//   //           context.read<FocusProvider>().focusPreviousRow();
//   //           return KeyEventResult.handled;
//   //         } else if (key == LogicalKeyboardKey.arrowDown) {
//   //           context.read<ColorProvider>().resetColor();
//   //           FocusScope.of(context).unfocus();
//   //           context.read<FocusProvider>().focusNextRow();
//   //           return KeyEventResult.handled;
//   //         } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//   //           _handleLanguageTap(language);
//   //           return KeyEventResult.handled;
//   //         }
//   //       }
//   //       return KeyEventResult.ignored;
//   //     },
//   //     child: GestureDetector(
//   //       onTap: () => _handleLanguageTap(language),
//   //       child: ProfessionalLanguageCard(
//   //         language: language,
//   //         focusNode: focusNode,
//   //         onTap: () => _handleLanguageTap(language),
//   //         onColorChange: (color) {
//   //            if(mounted) {
//   //              setState(() { _currentAccentColor = color; });
//   //              context.read<ColorProvider>().updateColor(color, true);
//   //            }
//   //         },
//   //         index: index,
//   //         categoryTitle: "LANGUAGES",
//   //       ),
//   //     ),
//   //   );
//   // }

//   // void _restoreFocusAfterNavigation() {
//   //   WidgetsBinding.instance.addPostFrameCallback((_) async {
//   //     if (!mounted) return;

//   //     // Transition complete hone ka wait karein
//   //     await Future.delayed(const Duration(milliseconds: 300));

//   //     final focusProvider = Provider.of<FocusProvider>(context, listen: false);
//   //     final lastId = focusProvider.lastFocusedItemId;

//   //     if (lastId != null && languageFocusNodes.containsKey(lastId)) {
//   //       // Saved ID wala node dhoondhein aur request karein
//   //       FocusNode targetNode = languageFocusNodes[lastId]!;
//   //       _scrollToFocusedItem(lastId); // List ko wahan scroll karein
//   //       targetNode.requestFocus();
//   //     }
//   //   });
//   // }



// // void _restoreInternalFocus() {
// //     if (!mounted) return;
// //     final focusProvider = Provider.of<FocusProvider>(context, listen: false);
// //     final savedItemId = focusProvider.lastFocusedItemId;

// //     Future.delayed(const Duration(milliseconds: 200), () {
// //       if (!mounted) return;
// //       FocusNode? nodeToFocus;
// //       String idToScroll = '';

// //       // 1. Agar koi item pehle se save hai (Details page se back aane par)
// //       if (savedItemId != null && savedItemId.isNotEmpty && languageFocusNodes.containsKey(savedItemId)) {
// //         nodeToFocus = languageFocusNodes[savedItemId];
// //         idToScroll = savedItemId;
// //       } 
// //       // 2. ✅ Agar naya page load hua hai, toh default FIRST ITEM par focus do
// //       else if (_languages.isNotEmpty) {
// //         idToScroll = _languages[0].id.toString();
// //         nodeToFocus = languageFocusNodes[idToScroll];
// //       }

// //       // Focus lagao aur list ko wahan scroll karo
// //       if (nodeToFocus != null && !nodeToFocus.hasFocus) {
// //         FocusScope.of(context).requestFocus(nodeToFocus);
// //         if (idToScroll.isNotEmpty) _scrollToFocusedItem(idToScroll);
// //       }
// //     });
// //   }



// void _restoreInternalFocus() {
//     if (!mounted) return;
//     final focusProvider = Provider.of<FocusProvider>(context, listen: false);
    
//     // ✅ ADDED: Check karein ki kya Dashboard actually isi page par focus chahta hai
//     // Agar identifier 'activeSidebar' hai (yani user sidebar par khada hai), 
//     // toh ye list zabardasti focus NAHI mangegi.
//     if (focusProvider.lastFocusedIdentifier != 'liveChannelLanguage') {
//       return; // Silent exit. No focus stealing!
//     }

//     final savedItemId = focusProvider.lastFocusedItemId;

//     Future.delayed(const Duration(milliseconds: 200), () {
//       if (!mounted) return;
//       FocusNode? nodeToFocus;
//       String idToScroll = '';

//       // 1. Agar koi item pehle se save hai (Details page se back aane par)
//       if (savedItemId != null && savedItemId.isNotEmpty && languageFocusNodes.containsKey(savedItemId)) {
//         nodeToFocus = languageFocusNodes[savedItemId];
//         idToScroll = savedItemId;
//       } 
//       // 2. Agar naya page load hua hai aur Dashboard ka focus isi par hai
//       else if (_languages.isNotEmpty) {
//         idToScroll = _languages[0].id.toString();
//         nodeToFocus = languageFocusNodes[idToScroll];
//       }

//       // Focus lagao aur list ko wahan scroll karo
//       if (nodeToFocus != null && !nodeToFocus.hasFocus) {
//         FocusScope.of(context).requestFocus(nodeToFocus);
//         if (idToScroll.isNotEmpty) _scrollToFocusedItem(idToScroll);
//       }
//     });
//   }


//   Widget _buildLanguageItem(
//       Language language, int index, double screenWidth, double screenHeight) {
//     String languageId = language.id.toString();
//     FocusNode? focusNode = languageFocusNodes[languageId];
//     if (focusNode == null) return const SizedBox.shrink();

//     return Focus(
//       focusNode: focusNode,
//       // onFocusChange: (hasFocus) async {
//       //   if (!mounted) return;

//       //   // ✅ CRITICAL FIX: Sirf tab setState karein jab value actually change ho rahi ho
//       //   // Ye focus flickering aur gayab hone se bachayega
//       //   if (_isSectionFocused != hasFocus) {
//       //      setState(() => _isSectionFocused = hasFocus);
//       //   }

//       //   if (hasFocus) {
//       //     try {
//       //       Color dominantColor = ProfessionalColorsForHomePages.gradientColors[math.Random().nextInt(ProfessionalColorsForHomePages.gradientColors.length)];
//       //       if (!mounted) return;
//       //       setState(() { _currentAccentColor = dominantColor; });
//       //       context.read<ColorProvider>().updateColor(dominantColor, true);
//       //     } catch (e) {}
//       //   } else {
//       //     // Optional: Reset logic if needed, but carefully
//       //     // context.read<ColorProvider>().resetColor();
//       //   }
//       // },

//       // _buildLanguageItem ke andar onFocusChange mein:
//       onFocusChange: (hasFocus) async {
//         if (!mounted) return;

//         if (_isSectionFocused != hasFocus) {
//           setState(() => _isSectionFocused = hasFocus);
//         }

//         if (hasFocus) {
//           // 🔥 Color update ko frame ke baad karein taaki focus set hone mein rukawat na aaye
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (mounted) {
//               final focusProvider =
//                   Provider.of<FocusProvider>(context, listen: false);
//               focusProvider.updateLastFocusedItemId(languageId);
//               try {
//                 Color dominantColor = ProfessionalColorsForHomePages
//                         .gradientColors[
//                     math.Random().nextInt(
//                         ProfessionalColorsForHomePages.gradientColors.length)];
//                 setState(() {
//                   _currentAccentColor = dominantColor;
//                 });
//                 context.read<ColorProvider>().updateColor(dominantColor, true);
//               } catch (e) {}
//             }
//           });
//         }
//       },
//       // onKey: (FocusNode node, RawKeyEvent event) {
//       //   // ... (Baaki code same rahega aapka key handling ka) ...
//       //   if (event is RawKeyDownEvent) {
//       //     final key = event.logicalKey;
//       //     if (key == LogicalKeyboardKey.arrowRight ||
//       //         key == LogicalKeyboardKey.arrowLeft) {
//       //       if (_isNavigationLocked) return KeyEventResult.handled;
//       //       if (!mounted) return KeyEventResult.ignored;
//       //       setState(() => _isNavigationLocked = true);
//       //       _navigationLockTimer = Timer(const Duration(milliseconds: 600), () {
//       //         if (mounted) setState(() => _isNavigationLocked = false);
//       //       });
//       //       if (key == LogicalKeyboardKey.arrowRight) {
//       //         if (index < _languages.length - 1) {
//       //           String nextLanguageId = _languages[index + 1].id.toString();
//       //           if (languageFocusNodes.containsKey(nextLanguageId))
//       //             FocusScope.of(context)
//       //                 .requestFocus(languageFocusNodes[nextLanguageId]);
//       //           else {
//       //             _navigationLockTimer?.cancel();
//       //             if (mounted) setState(() => _isNavigationLocked = false);
//       //           }
//       //         } else {
//       //           _navigationLockTimer?.cancel();
//       //           if (mounted) setState(() => _isNavigationLocked = false);
//       //         }
//       //       } else if (key == LogicalKeyboardKey.arrowLeft) {
//       //         if (index > 0) {
//       //           String prevLanguageId = _languages[index - 1].id.toString();
//       //           if (languageFocusNodes.containsKey(prevLanguageId))
//       //             FocusScope.of(context)
//       //                 .requestFocus(languageFocusNodes[prevLanguageId]);
//       //           else {
//       //             _navigationLockTimer?.cancel();
//       //             if (mounted) setState(() => _isNavigationLocked = false);
//       //           }
//       //         } else {
//       //           _navigationLockTimer?.cancel();
//       //           if (mounted) setState(() => _isNavigationLocked = false);
//       //         }
//       //       }
//       //       return KeyEventResult.handled;
//       //     }
//       //     if (key == LogicalKeyboardKey.arrowUp) {
//       //       context.read<ColorProvider>().resetColor();
//       //       FocusScope.of(context).unfocus();
//       //       context.read<FocusProvider>().focusPreviousRow();
//       //       return KeyEventResult.handled;
//       //     } else if (key == LogicalKeyboardKey.arrowDown) {
//       //       context.read<ColorProvider>().resetColor();
//       //       FocusScope.of(context).unfocus();
//       //       context.read<FocusProvider>().focusNextRow();
//       //       return KeyEventResult.handled;
//       //     } else if (key == LogicalKeyboardKey.select ||
//       //         key == LogicalKeyboardKey.enter) {
//       //       _handleLanguageTap(language);
//       //       return KeyEventResult.handled;
//       //     }
//       //   }
//       //   return KeyEventResult.ignored;
//       // },
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           final key = event.logicalKey;
          
//           if (key == LogicalKeyboardKey.arrowRight ||
//               key == LogicalKeyboardKey.arrowLeft) {
            
//             if (_isNavigationLocked) return KeyEventResult.handled;
//             if (!mounted) return KeyEventResult.ignored;
            
//             setState(() => _isNavigationLocked = true);
//             _navigationLockTimer = Timer(const Duration(milliseconds: 600), () {
//               if (mounted) setState(() => _isNavigationLocked = false);
//             });

//             if (key == LogicalKeyboardKey.arrowRight) {
//               if (index < _languages.length - 1) {
//                 String nextLanguageId = _languages[index + 1].id.toString();
//                 if (languageFocusNodes.containsKey(nextLanguageId)) {
//                   FocusScope.of(context)
//                       .requestFocus(languageFocusNodes[nextLanguageId]);
//                 } else {
//                   _navigationLockTimer?.cancel();
//                   if (mounted) setState(() => _isNavigationLocked = false);
//                 }
//               } else {
//                 _navigationLockTimer?.cancel();
//                 if (mounted) setState(() => _isNavigationLocked = false);
//               }
//             } 
            
//             // ✅ 1. LEFT ARROW UPDATE
//             else if (key == LogicalKeyboardKey.arrowLeft) {
//               if (index > 0) {
//                 String prevLanguageId = _languages[index - 1].id.toString();
//                 if (languageFocusNodes.containsKey(prevLanguageId)) {
//                   FocusScope.of(context)
//                       .requestFocus(languageFocusNodes[prevLanguageId]);
//                 } else {
//                   _navigationLockTimer?.cancel();
//                   if (mounted) setState(() => _isNavigationLocked = false);
//                 }
//               } else {
//                 // Agar Index 0 par left dabaya jaye to sidebar par focus bhejo
//                 _navigationLockTimer?.cancel();
//                 if (mounted) setState(() => _isNavigationLocked = false);
                
//                 context.read<ColorProvider>().resetColor();
//                 context.read<FocusProvider>().requestFocus('activeSidebar');
//               }
//             }
//             return KeyEventResult.handled;
//           }

//           // ✅ 2. UP ARROW UPDATE
//           if (key == LogicalKeyboardKey.arrowUp) {
//             // context.read<ColorProvider>().resetColor();
//             // FocusScope.of(context).unfocus();
//             // // Up dabane par Banner Slider par bhejein
//             // context.read<FocusProvider>().requestFocus('watchNow'); 
//             return KeyEventResult.handled;
            
//           // ✅ 3. DOWN ARROW UPDATE
//           } 
//     //       else if (key == LogicalKeyboardKey.arrowDown) {
//     //       //   context.read<ColorProvider>().resetColor();
//     //       //   FocusScope.of(context).unfocus();
//     //       //   // Down dabane par agla page open karein
//     //       //   context.read<FocusProvider>().triggerDashboardNextPage(); 
//     //       //   return KeyEventResult.handled;
//     //         context.read<ColorProvider>().resetColor();
//     // FocusScope.of(context).unfocus();
    
//     // // 1. Dashboard ko switch karo (Next Page: CONTENTS)
//     // context.read<FocusProvider>().triggerDashboardNextPage(); 
    

//     //       } 
//     // ✅ DOWN ARROW UPDATE
//  else if (key == LogicalKeyboardKey.arrowDown) {
//   // context.read<ColorProvider>().resetColor();
//   // FocusScope.of(context).unfocus();
  
//   // // Dashboard ko CONTENTS page par switch karne ka signal dein
//   // final fp = context.read<FocusProvider>();
  
//   // // Agle page ka ID set karein taaki wo load hote hi focus pakad le
//   // fp.updateLastFocusedIdentifier('subVod'); 
  
//   // // Dashboard switch trigger karein
//   // fp.triggerDashboardNextPage(); 
  
//   return KeyEventResult.handled;
// }
          
//           else if (key == LogicalKeyboardKey.select ||
//               key == LogicalKeyboardKey.enter) {
//             _handleLanguageTap(language);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () => _handleLanguageTap(language),
//         child: ProfessionalLanguageCard(
//           language: language,
//           focusNode: focusNode,
//           onTap: () => _handleLanguageTap(language),
//           onColorChange: (color) {
//             if (mounted) {
//               setState(() {
//                 _currentAccentColor = color;
//               });
//               context.read<ColorProvider>().updateColor(color, true);
//             }
//           },
//           index: index,
//           categoryTitle: "LANGUAGES",
//         ),
//       ),
//     );
//   }

//   Widget _buildLanguagesList(double screenWidth, double screenHeight) {
//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         clipBehavior: Clip.none,
//         controller: _scrollController,
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//         cacheExtent: 9999,
//         itemCount: _languages.length,
//         itemBuilder: (context, index) {
//           var language = _languages[index];
//           return _buildLanguageItem(language, index, screenWidth, screenHeight);
//         },
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     return SlideTransition(
//       position: _headerSlideAnimation,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//         child: Row(
//           children: [
//             ShaderMask(
//               shaderCallback: (bounds) => const LinearGradient(
//                 colors: [
//                   ProfessionalColorsForHomePages.accentBlue,
//                   ProfessionalColorsForHomePages.accentPurple
//                 ],
//               ).createShader(bounds),
//               child: const Text("LIVE CHANNELS",
//                   style: TextStyle(
//                       fontSize: 24,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 2.0)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorWidget(double height) {
//     return SizedBox(
//       height: height,
//       child: Center(
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 10),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//               color: ProfessionalColorsForHomePages.cardDark.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(50),
//               border: Border.all(
//                   color: ProfessionalColorsForHomePages.accentRed
//                       .withOpacity(0.3))),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline_rounded,
//                   size: 20, color: ProfessionalColorsForHomePages.accentRed),
//               const SizedBox(width: 10),
//               Flexible(
//                   child: Text(
//                       _errorMessage.isNotEmpty ? _errorMessage : "Error",
//                       style: const TextStyle(
//                           color: ProfessionalColorsForHomePages.textPrimary,
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis)),
//               const SizedBox(width: 15),
//               // ✅ REUSABLE SMART RETRY
//               SmartRetryWidget(
//                 errorMessage: _errorMessage,
//                 onRetry: _fetchLanguages,
//                 focusNode: _retryFocusNode,
//                 providerIdentifier: 'liveChannelLanguage',
//                 onFocusChange: (hasFocus) {
//                   if (mounted) setState(() => _isSectionFocused = hasFocus);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(double screenWidth, double screenHeight) {
//     double effectiveBannerHgt = bannerhgt ?? screenHeight * 0.2;
//     double effectiveBannerWdt = bannerwdt ?? screenWidth * 0.18;

//     // ✅ REUSABLE SMART LOADING
//     if (_isLoading)
//       return SmartLoadingWidget(
//           itemWidth: effectiveBannerWdt, itemHeight: effectiveBannerHgt);
//     else if (_errorMessage.isNotEmpty)
//       return _buildErrorWidget(effectiveBannerHgt);
//     else if (_languages.isEmpty)
//       return const Center(
//           child: Text("No Languages Available",
//               style: TextStyle(color: Colors.white, fontSize: 12)));
//     else
//       return _buildLanguagesList(screenWidth, screenHeight);
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     double containerHeight = (screenhgt ?? screenHeight) * 0.38;

//     return Consumer<ColorProvider>(
//       builder: (context, colorProvider, child) {
//         bool showShadow = _isSectionFocused;

//         return FocusScope(
//           child: Scaffold(
//             backgroundColor: Colors.white,
//             body: ClipRect(
//               child: SizedBox(
//                 height: containerHeight,
//                 child: Stack(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: (screenhgt ?? screenHeight) * 0.01),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           child: _buildProfessionalTitle(screenWidth),
//                         ),
//                         Expanded(
//                           child: _buildBody(screenWidth, screenHeight),
//                         ),
//                       ],
//                     ),

//                     // ✅ CINEMATIC SHADOW OVERLAY
//                     Positioned.fill(
//                       child: IgnorePointer(
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeOut,
//                           decoration: BoxDecoration(
//                             gradient: showShadow
//                                 ? LinearGradient(
//                                     begin: Alignment.topCenter,
//                                     end: Alignment.bottomCenter,
//                                     colors: [
//                                       Colors.black
//                                           .withOpacity(0.8), // Shadow Top
//                                       Colors.transparent,
//                                       Colors.transparent,
//                                       Colors.black
//                                           .withOpacity(0.8), // Shadow Bottom
//                                     ],
//                                     stops: const [0.0, 0.25, 0.75, 1.0],
//                                   )
//                                 : null,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // ... ProfessionalLanguageCard Class (Same as before) ...
// class ProfessionalLanguageCard extends StatefulWidget {
//   final Language language;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalLanguageCard({
//     Key? key,
//     required this.language,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalLanguageCardState createState() =>
//       _ProfessionalLanguageCardState();
// }

// class _ProfessionalLanguageCardState extends State<ProfessionalLanguageCard>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _glowController;
//   late AnimationController _shimmerController;

//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<double> _shimmerAnimation;

//   Color _dominantColor = ProfessionalColorsForHomePages.accentBlue;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();

//     _scaleController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _glowController = AnimationController(
//       duration: AnimationTiming.medium,
//       vsync: this,
//     );

//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.06,
//     ).animate(CurvedAnimation(
//       parent: _scaleController,
//       curve: Curves.easeOutCubic,
//     ));

//     _glowAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _glowController,
//       curve: Curves.easeInOut,
//     ));

//     _shimmerAnimation = Tween<double>(
//       begin: -1.0,
//       end: 2.0,
//     ).animate(CurvedAnimation(
//       parent: _shimmerController,
//       curve: Curves.easeInOut,
//     ));

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (!mounted) return;

//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _scaleController.forward();
//       _glowController.forward();
//       _shimmerController.repeat();
//       _generateDominantColor();
//       widget.onColorChange(_dominantColor);
//       HapticFeedback.lightImpact();
//     } else {
//       _scaleController.reverse();
//       _glowController.reverse();
//       _shimmerController.stop();
//     }
//   }

//   void _generateDominantColor() {
//     _dominantColor = ProfessionalColorsForHomePages.accentBlue;
//   }

//   @override
//   void dispose() {
//     widget.focusNode.removeListener(_handleFocusChange);
//     _scaleController.dispose();
//     _glowController.dispose();
//     _shimmerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     double effectiveBannerWdt = bannerwdt ?? screenWidth * 0.18;

//     return AnimatedBuilder(
//       animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Container(
//             width: effectiveBannerWdt,
//             margin: const EdgeInsets.symmetric(horizontal: 6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _buildProfessionalPoster(screenWidth, screenHeight),
//                 _buildProfessionalTitle(screenWidth, effectiveBannerWdt),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
//     final posterHeight = _isFocused
//         ? (focussedBannerhgt ?? screenHeight * 0.22)
//         : (bannerhgt ?? screenHeight * 0.2);

//     return Container(
//       height: posterHeight,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           if (_isFocused) ...[
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.4),
//               blurRadius: 25,
//               spreadRadius: 3,
//               offset: const Offset(0, 8),
//             ),
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.2),
//               blurRadius: 45,
//               spreadRadius: 6,
//               offset: const Offset(0, 15),
//             ),
//           ] else ...[
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 10,
//               spreadRadius: 2,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Stack(
//           children: [
//             _buildLanguageImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildLanguageBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLanguageImage(double screenWidth, double posterHeight) {
//     final String imageUrl = widget.language.logoUrl;
//     final String cacheKey = widget.language.id.toString();

//     return SizedBox(
//       width: double.infinity,
//       height: posterHeight,
//       child: imageUrl.isNotEmpty
//           ? CachedNetworkImage(
//             memCacheHeight: 250, 
//   memCacheWidth: 200, // Width bhi de dein
//               imageUrl: imageUrl,
//               cacheKey: cacheKey,
//               fit: BoxFit.cover,
//               placeholder: (context, url) =>
//                   _buildImagePlaceholder(posterHeight),
//               errorWidget: (context, url, error) {
//                 return _buildImagePlaceholder(posterHeight);
//               })
//           : _buildImagePlaceholder(posterHeight),
//     );
//   }

//   Widget _buildImagePlaceholder(double height) {
//     return Container(
//       height: height,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalColorsForHomePages.cardDark,
//             ProfessionalColorsForHomePages.surfaceDark,
//           ],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.language,
//             size: height * 0.25,
//             color: ProfessionalColorsForHomePages.textSecondary,
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "LANGUAGE",
//             style: TextStyle(
//               color: ProfessionalColorsForHomePages.textSecondary,
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             decoration: BoxDecoration(
//               color: ProfessionalColorsForHomePages.accentBlue.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'LIVE',
//               style: TextStyle(
//                 color: ProfessionalColorsForHomePages.accentBlue,
//                 fontSize: 8,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFocusBorder() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             width: 3,
//             color: _dominantColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmerEffect() {
//     return AnimatedBuilder(
//       animation: _shimmerAnimation,
//       builder: (context, child) {
//         return Positioned.fill(
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               gradient: LinearGradient(
//                 begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
//                 end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
//                 colors: [
//                   Colors.transparent,
//                   _dominantColor.withOpacity(0.15),
//                   Colors.transparent,
//                 ],
//                 stops: const [0.0, 0.5, 1.0],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildLanguageBadge() {
//     String languageType = 'LIVE';
//     Color badgeColor = ProfessionalColorsForHomePages.accentRed;

//     return Positioned(
//       top: 8,
//       right: 8,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//         decoration: BoxDecoration(
//           color: badgeColor.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Text(
//           languageType,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 8,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHoverOverlay() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               _dominantColor.withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: Icon(
//               Icons.play_arrow_rounded,
//               color: _dominantColor,
//               size: 30,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth, double cardWidth) {
//     final languageName = widget.language.title.toUpperCase();

//     return SizedBox(
//       width: cardWidth,
//       child: AnimatedDefaultTextStyle(
//         duration: AnimationTiming.medium,
//         style: TextStyle(
//           fontSize: _isFocused ? 13 : 11,
//           fontWeight: FontWeight.w600,
//           color: _isFocused ? _dominantColor : Colors.black,
//           letterSpacing: 0.5,
//           shadows: _isFocused
//               ? [
//                   Shadow(
//                     color: _dominantColor.withOpacity(0.6),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Text(
//           languageName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }





import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_live_screen/language_channel_screen.dart';
import 'package:mobi_tv_entertainment/components/widgets/smart_common_horizontal_list.dart'; 

class LiveChannelLanguageScreen extends StatefulWidget {
  const LiveChannelLanguageScreen({Key? key}) : super(key: key);
  @override
  State<LiveChannelLanguageScreen> createState() => _LiveChannelLanguageScreenState();
}

class _LiveChannelLanguageScreenState extends State<LiveChannelLanguageScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<List<CommonContentModel>> fetchLanguagesAPI() async {
    var url = Uri.parse(SessionManager.baseUrl + 'getAllLanguages');
    final response = await https.get(url, headers: {'auth-key': SessionManager.authKey, 'Content-Type': 'application/json', 'domain': SessionManager.savedDomain}).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body)['languages'] ?? [];
      jsonData.sort((a, b) => (a['id'] ?? 0).compareTo(b['id'] ?? 0));

      return jsonData.map((item) => CommonContentModel(
        id: item['id'].toString(), title: item['title'] ?? 'Unknown', imageUrl: item['logo'] ?? '', badgeText: 'LIVE', originalData: item,
      )).toList();
    } else { throw Exception('Failed to load languages'); }
  }

  Future<void> _onItemTap(CommonContentModel item) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageChannelsScreen(languageId: item.id, languageName: item.title)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SmartCommonHorizontalList(
      sectionTitle: "LIVE CHANNELS",
      titleGradient: const [ProfessionalColorsForHomePages.accentBlue, ProfessionalColorsForHomePages.accentPurple],
      accentColor: ProfessionalColorsForHomePages.accentBlue,
      placeholderIcon: Icons.language, badgeDefaultText: 'LIVE',
      focusIdentifier: 'liveChannelLanguage',
      fetchApiData: fetchLanguagesAPI,
      onItemTap: _onItemTap,
      maxVisibleItems: 100, // No view all
    );
  }
}