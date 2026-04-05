





// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:math' as math;

// // Import your project specific files
// // Update these imports based on your folder structure
// import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';
// import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';

// // ==========================================================
// // CONSTANTS & THEME
// // ==========================================================

// class ProfessionalColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentGreen = Color(0xFF10B981);
//   static const accentRed = Color(0xFFEF4444);
//   static const accentOrange = Color(0xFFF59E0B);
//   static const accentPink = Color(0xFFEC4899);
//   static const accentTeal = Color(0xFF06B6D4);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
// }

// class AnimationTiming {
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
// }

// // ==========================================================
// // DATA MODELS
// // ==========================================================

// class SliderItem {
//   final int id;
//   final String title;
//   final String banner;

//   SliderItem({required this.id, required this.title, required this.banner});

//   factory SliderItem.fromJson(Map<String, dynamic> json) {
//     return SliderItem(
//       id: json['id'] ?? 0,
//       title: json['title'] ?? 'Untitled',
//       banner: json['banner'] ?? '',
//     );
//   }
// }

// // class NewsChannel {
// //   final int id;
// //   final String name;
// //   final String banner;
// //   final String url;
// //   final String genres;
// //   final int status;
// //   final String streamType;
// //   final String contentType;
// //   final String sourceType;
// //   final String? updatedAt;

// //   NewsChannel({
// //     required this.id,
// //     required this.name,
// //     required this.banner,
// //     required this.url,
// //     required this.genres,
// //     required this.status,
// //     required this.streamType,
// //     required this.contentType,
// //     this.sourceType = '',
// //     this.updatedAt,
// //   });

// //   factory NewsChannel.fromJson(Map<String, dynamic> json) {
// //     return NewsChannel(
// //       id: json['id'] ?? 0,
// //       name: json['channel_name'] ?? 'Untitled Channel',
// //       banner: json['channel_logo'] ?? '',
// //       url: json['channel_link'] ?? '',
// //       genres: json['genres'] ?? 'General',
// //       status: json['status'] ?? 0,
// //       streamType: json['stream_type'] ?? 'M3u8',
// //       contentType: json['content_type']?.toString() ?? '',
// //       sourceType: json['source_type'] ?? '',
// //       updatedAt: json['updated_at'],
// //     );
// //   }
// // }


// class NewsChannel {
//   final int id;
//   final String name;
//   final String banner;
//   final String url;
//   final String genres;
//   final int status;
//   final String streamType;
//   final String contentType; // String expected
//   final String sourceType;
//   final String? updatedAt;

//   NewsChannel({
//     required this.id,
//     required this.name,
//     required this.banner,
//     required this.url,
//     required this.genres,
//     required this.status,
//     required this.streamType,
//     required this.contentType,
//     this.sourceType = '',
//     this.updatedAt,
//   });

//   factory NewsChannel.fromJson(Map<String, dynamic> json) {
//     return NewsChannel(
//       id: json['id'] ?? 0,
//       name: json['channel_name'] ?? 'Untitled Channel',
//       banner: json['channel_logo'] ?? '',
//       url: json['channel_link'] ?? '',
//       genres: json['genres'] ?? 'General',
//       status: json['status'] ?? 0,
//       streamType: json['stream_type'] ?? 'M3u8',
      
//       // 🔥 FIX: Add .toString() here
//       // यह लाइन नंबर (int) को सेफली स्ट्रिंग में बदल देगी
//       contentType: json['content_type']?.toString() ?? '', 
      
//       sourceType: json['source_type'] ?? '',
//       updatedAt: json['updated_at'],
//     );
//   }
// }

// // ==========================================================
// // MAIN SCREEN
// // ==========================================================

// class LanguageChannelsScreen extends StatefulWidget {
//   final String languageId;
//   final String languageName;

//   const LanguageChannelsScreen({
//     super.key,
//     required this.languageId,
//     required this.languageName,
//   });

//   @override
//   State<LanguageChannelsScreen> createState() => _LanguageChannelsScreenState();
// }

// class _LanguageChannelsScreenState extends State<LanguageChannelsScreen> with SingleTickerProviderStateMixin {
//   // --- Data State ---
//   List<NewsChannel> _allChannels = [];
//   Map<String, List<NewsChannel>> _channelsByGenre = {};
//   List<NewsChannel> _currentDisplayList = [];
//   List<String> _genres = [];
//   List<SliderItem> _sliders = [];

//   // --- UI State Flags ---
//   bool _isLoading = true;
//   bool _isSearching = false;
//   bool _isVideoLoading = false;
//   bool _isGenreSwitching = false;
//   bool _isProcessing = false;
//   bool _isDisposed = false;
//   String? _error;
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;
//   static const Duration _navigationLockDuration = Duration(milliseconds: 500);

//   // --- Focus Management ---
//   int _focusedGenreIndex = 0;
//   int _focusedChannelIndex = -1;
//   String _selectedGenre = '';
  
//   final FocusNode _widgetFocusNode = FocusNode();
//   late FocusNode _searchButtonFocusNode;
  
//   List<FocusNode> _genreFocusNodes = [];
//   List<FocusNode> _channelFocusNodes = [];
//   List<FocusNode> _keyboardFocusNodes = [];

//   // --- Scroll Controllers ---
//   final ScrollController _genreScrollController = ScrollController();
//   final ScrollController _channelScrollController = ScrollController();

//   // --- Slider Management ---
//   late PageController _sliderPageController;
//   int _currentSliderPage = 0;
//   Timer? _sliderTimer;

//   // --- Search System ---
//   bool _showKeyboard = false;
//   String _searchText = '';
//   List<NewsChannel> _searchResults = [];
//   int _focusedKeyRow = 0;
//   int _focusedKeyCol = 0;
//   final List<List<String>> _keyboardLayout = [
//     "1234567890".split(''),
//     "qwertyuiop".split(''),
//     "asdfghjkl".split(''),
//     ["z", "x", "c", "v", "b", "n", "m", "DEL"],
//     ["SPACE", "OK"],
//   ];

//   // --- Animation ---
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   // --- Colors ---
//   final List<Color> _focusColors = [
//     ProfessionalColors.accentBlue,
//     ProfessionalColors.accentPurple,
//     ProfessionalColors.accentGreen,
//     ProfessionalColors.accentOrange,
//     ProfessionalColors.accentPink,
//     ProfessionalColors.accentRed,
//     ProfessionalColors.accentTeal,
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _isDisposed = false;
//     SecureUrlService.refreshSettings();
//     _sliderPageController = PageController();
//     _searchButtonFocusNode = FocusNode();
//     _initializeAnimations();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_isDisposed) {
//         Provider.of<InternalFocusProvider>(context, listen: false).updateName('');
//         _fetchAndProcessData();
//       }
//     });
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       duration: AnimationTiming.medium,
//       vsync: this,
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void dispose() {
//     _isDisposed = true;
//     _sliderTimer?.cancel();
//     _genreChangeDebounce?.cancel();
//     _navigationLockTimer?.cancel();
//     _sliderPageController.dispose();
//     _fadeController.dispose();
//     _genreScrollController.dispose();
//     _channelScrollController.dispose();
//     _widgetFocusNode.dispose();
//     _searchButtonFocusNode.dispose();
//     _disposeAllFocusNodes();
//     super.dispose();
//   }

//   void _disposeAllFocusNodes() {
//     FocusManager.instance.primaryFocus?.unfocus();
//     for (var node in _genreFocusNodes) {
//       try { node.dispose(); } catch (_) {}
//     }
//     _genreFocusNodes.clear();

//     for (var node in _channelFocusNodes) {
//       try { node.dispose(); } catch (_) {}
//     }
//     _channelFocusNodes.clear();

//     for (var node in _keyboardFocusNodes) {
//       try { node.dispose(); } catch (_) {}
//     }
//     _keyboardFocusNodes.clear();
//   }

//   // ==========================================================
//   // DATA FETCHING (UPDATED FIX)
//   // ==========================================================

//   // Future<void> _fetchAndProcessData() async {
//   //   if (_isDisposed) return;

//   //   try {
//   //     final headers = {
//   //       'auth-key': SessionManager.authKey,
//   //       'domain': SessionManager.savedDomain,
//   //       'Content-Type': 'application/json'
//   //     };

//   //     final results = await Future.wait([
//   //       https.get(Uri.parse(SessionManager.baseUrl + 'getAllLanguages'), headers: headers),
//   //       https.post(
//   //         Uri.parse(SessionManager.baseUrl + 'getAllLiveTV'),
//   //         headers: headers,
//   //         body: json.encode({
//   //           "genere": "",
//   //           "languageId": widget.languageId
//   //         })
//   //       ),
//   //       https.post(
//   //          Uri.parse(SessionManager.baseUrl + 'getGenreByContentNetwork'), 
//   //          headers: headers,
//   //          body: json.encode({"language_id": widget.languageId})
//   //       ),
//   //     ]);

//   //     if (_isDisposed) return;

//   //     // --- 1. Process Sliders (Languages) ---
//   //     List<SliderItem> tempSliders = [];
//   //     if (results[0].statusCode == 200) {
//   //       final langData = json.decode(results[0].body);
//   //       if (langData['languages'] is List) {
//   //         // Safe Comparison Fix
//   //         final currentLang = (langData['languages'] as List).firstWhere(
//   //           (l) => l['id'].toString().trim() == widget.languageId.toString().trim(),
//   //           orElse: () => null
//   //         );
//   //         if (currentLang != null && currentLang['slider'] is List) {
//   //            tempSliders = (currentLang['slider'] as List)
//   //                .map((i) => SliderItem.fromJson(i))
//   //                .toList();
//   //         }
//   //       }
//   //     }

//   //     // --- 2. Process Channels & Genres ---
//   //     if (results[1].statusCode == 200) {
//   //       final List<dynamic> channelsData = json.decode(results[1].body);
//   //       _allChannels = channelsData
//   //           .map((item) => NewsChannel.fromJson(item))
//   //           .where((c) => c.status == 1)
//   //           .toList();

//   //       final genreRes = results[2];
//   //       List<String> apiGenres = [];
//   //       if (genreRes.statusCode == 200) {
//   //          final gData = json.decode(genreRes.body);
//   //          if (gData['genres'] != null) {
//   //            apiGenres = List<String>.from(gData['genres']);
//   //          }
//   //       }

//   //       if (apiGenres.isEmpty) {
//   //         final Set<String> extracted = {};
//   //         for (var c in _allChannels) {
//   //           c.genres.split(',').forEach((g) => extracted.add(g.trim()));
//   //         }
//   //         extracted.removeWhere((e) => e.isEmpty);
//   //         apiGenres = extracted.toList()..sort();
//   //       }

//   //       Map<String, List<NewsChannel>> mapTemp = {};
//   //       for (var g in apiGenres) {
//   //         mapTemp[g] = _allChannels.where((c) => c.genres.contains(g)).toList();
//   //       }
        
//   //       apiGenres.removeWhere((g) => (mapTemp[g] ?? []).isEmpty);
//   //       _genres = apiGenres;
//   //       _channelsByGenre = mapTemp;

//   //       if (!_isDisposed && mounted) {
//   //          setState(() {
//   //            _sliders = tempSliders; // Update Sliders
//   //            if (_genres.isNotEmpty) {
//   //              _selectedGenre = _genres[0];
//   //              _currentDisplayList = _channelsByGenre[_selectedGenre] ?? [];
//   //            } else {
//   //              _currentDisplayList = _allChannels;
//   //            }
//   //            _isLoading = false;
//   //          });

//   //          _rebuildNodes();
//   //          _setupSliderTimer();
//   //          _fadeController.forward();

//   //          Future.delayed(const Duration(milliseconds: 300), () {
//   //            if (!_isDisposed && mounted && _searchButtonFocusNode.canRequestFocus) {
//   //              _searchButtonFocusNode.requestFocus();
//   //            }
//   //          });
//   //       }
//   //     } else {
//   //       throw Exception("API Error");
//   //     }
//   //   } catch (e) {
//   //     if (!_isDisposed && mounted) {
//   //       setState(() {
//   //         _isLoading = false;
//   //         _error = e.toString();
//   //       });
//   //     }
//   //   }
//   // }




//   Future<void> _fetchAndProcessData() async {
//     if (_isDisposed) return;

//     try {
//       final headers = {
//         'auth-key': SessionManager.authKey,
//         'domain': SessionManager.savedDomain,
//         'Content-Type': 'application/json'
//       };

//       final results = await Future.wait([
//         https.get(Uri.parse(SessionManager.baseUrl + 'getAllLanguages'), headers: headers),
//         https.post(
//           Uri.parse(SessionManager.baseUrl + 'getAllLiveTV'),
//           headers: headers,
//           body: json.encode({
//             "genere": "",
//             "languageId": widget.languageId
//           })
//         ),
//         https.post(
//             Uri.parse(SessionManager.baseUrl + 'getGenreByContentNetwork'), 
//             headers: headers,
//             body: json.encode({"language_id": widget.languageId})
//         ),
//       ]);

//       if (_isDisposed) return;

//       // --- 1. Process Sliders (Languages) ---
//       List<SliderItem> tempSliders = [];
//       if (results[0].statusCode == 200) {
//         final langData = json.decode(results[0].body);
//         if (langData['languages'] is List) {
//           final currentLang = (langData['languages'] as List).firstWhere(
//             (l) => l['id'].toString().trim() == widget.languageId.toString().trim(),
//             orElse: () => null
//           );
//           if (currentLang != null && currentLang['slider'] is List) {
//              tempSliders = (currentLang['slider'] as List)
//                  .map((i) => SliderItem.fromJson(i))
//                  .toList();
//           }
//         }
//       }

//       // --- 2. Process Channels & Genres ---
//       if (results[1].statusCode == 200) {
//         final dynamic _decoded_channelsData = json.decode(results[1].body);
//         final List<dynamic> channelsData = safeDecodeList(_decoded_channelsData);
//         _allChannels = channelsData
//             .map((item) => NewsChannel.fromJson(item))
//             .where((c) => c.status == 1)
//             .toList();

//         // 🔥 FALLBACK LOGIC ADDED HERE 🔥
//         // Agar API se Slider nahi mila, to pehle channel ka banner use karein
//         if (tempSliders.isEmpty && _allChannels.isNotEmpty) {
//            tempSliders.add(SliderItem(
//              id: 0, 
//              title: _allChannels.first.name, 
//              banner: _allChannels.first.banner
//            ));
//         }

//         final genreRes = results[2];
//         List<String> apiGenres = [];
//         if (genreRes.statusCode == 200) {
//            final gData = json.decode(genreRes.body);
//            if (gData['genres'] != null) {
//              apiGenres = List<String>.from(gData['genres']);
//            }
//         }

//         if (apiGenres.isEmpty) {
//           final Set<String> extracted = {};
//           for (var c in _allChannels) {
//             c.genres.split(',').forEach((g) => extracted.add(g.trim()));
//           }
//           extracted.removeWhere((e) => e.isEmpty);
//           apiGenres = extracted.toList()..sort();
//         }

//         Map<String, List<NewsChannel>> mapTemp = {};
//         for (var g in apiGenres) {
//           mapTemp[g] = _allChannels.where((c) => c.genres.contains(g)).toList();
//         }
        
//         apiGenres.removeWhere((g) => (mapTemp[g] ?? []).isEmpty);
//         _genres = apiGenres;
//         _channelsByGenre = mapTemp;

//         if (!_isDisposed && mounted) {
//            setState(() {
//              _sliders = tempSliders; // Ab isme fallback image bhi hogi
//              if (_genres.isNotEmpty) {
//                _selectedGenre = _genres[0];
//                _currentDisplayList = _channelsByGenre[_selectedGenre] ?? [];
//              } else {
//                _currentDisplayList = _allChannels;
//              }
//              _isLoading = false;
//            });

//            _rebuildNodes();
//            _setupSliderTimer();
//            _fadeController.forward();

//            Future.delayed(const Duration(milliseconds: 300), () {
//              if (!_isDisposed && mounted && _searchButtonFocusNode.canRequestFocus) {
//                _searchButtonFocusNode.requestFocus();
//              }
//            });
//         }
//       } else {
//         throw Exception("API Error");
//       }
//     } catch (e) {
//       if (!_isDisposed && mounted) {
//         setState(() {
//           _isLoading = false;
//           _error = e.toString();
//         });
//       }
//     }
//   }

//   // ==========================================================
//   // NODE & TIMER MANAGEMENT
//   // ==========================================================

//   void _rebuildNodes() {
//     if (_isDisposed) return;
//     _disposeAllFocusNodes();

//     _genreFocusNodes = List.generate(_genres.length, (_) => FocusNode());

//     final list = _isSearching ? _searchResults : _currentDisplayList;
//     _channelFocusNodes = List.generate(list.length, (_) => FocusNode());

//     int totalKeys = _keyboardLayout.fold(0, (p, r) => p + r.length);
//     _keyboardFocusNodes = List.generate(totalKeys, (_) => FocusNode());
//   }

//   void _rebuildChannelNodes() {
//     if (_isDisposed) return;
//     for (var node in _channelFocusNodes) {
//       try { node.dispose(); } catch (_) {}
//     }
//     _channelFocusNodes.clear();

//     final list = _isSearching ? _searchResults : _currentDisplayList;
//     _channelFocusNodes = List.generate(list.length, (_) => FocusNode());
//   }

//   void _setupSliderTimer() {
//     _sliderTimer?.cancel();
//     if (_sliders.length > 1) {
//       _sliderTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
//         if (_isDisposed || !_sliderPageController.hasClients) {
//           timer.cancel();
//           return;
//         }
//         int next = (_sliderPageController.page?.round() ?? 0) + 1;
//         if (next >= _sliders.length) next = 0;
//         _sliderPageController.animateToPage(
//           next,
//           duration: const Duration(milliseconds: 800),
//           curve: Curves.easeInOut
//         );
//       });
//     }
//   }

//   // ==========================================================
//   // SCROLLING HELPERS
//   // ==========================================================

//   void _scrollGenreToFocus(int index) {
//     if (_isDisposed || !_genreScrollController.hasClients) return;
//     try {
//       double screenW = MediaQuery.of(context).size.width;
//       double itemW = 120.0; 
//       double offset = (index * itemW) - (screenW / 2) + (itemW / 2);
//       if (offset < 0) offset = 0;
//       if (offset > _genreScrollController.position.maxScrollExtent) {
//         offset = _genreScrollController.position.maxScrollExtent;
//       }
//       _genreScrollController.animateTo(
//         offset, duration: AnimationTiming.fast, curve: Curves.easeOutCubic
//       );
//     } catch (_) {}
//   }

//   void _scrollChannelToFocus(int index) {
//     if (_isDisposed || !_channelScrollController.hasClients) return;
//     try {
//       double screenW = MediaQuery.of(context).size.width;
//       double itemW = bannerwdt + 15.0; 
//       double offset = (index * itemW) - (screenW / 2) + (itemW / 2);
//       if (offset < 0) offset = 0;
//       if (offset > _channelScrollController.position.maxScrollExtent) {
//         offset = _channelScrollController.position.maxScrollExtent;
//       }
//       _channelScrollController.animateTo(
//         offset, duration: AnimationTiming.fast, curve: Curves.easeOutCubic
//       );
//     } catch (_) {}
//   }

//   // ==========================================================
//   // KEYBOARD NAVIGATION HANDLER
//   // ==========================================================

//   KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
//     if (_isDisposed) return KeyEventResult.handled;
//     if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
//     if (_isProcessing || _isGenreSwitching) return KeyEventResult.handled;

//     final key = event.logicalKey;

//     if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape) {
//       if (_showKeyboard) {
//         setState(() => _showKeyboard = false);
//         _searchButtonFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.ignored; 
//     }

//     if (_showKeyboard) return _navigateVirtualKeyboard(key);
//     if (_searchButtonFocusNode.hasFocus) return _navigateSearchBtn(key);
//     if (_genreFocusNodes.any((n) => n.hasFocus)) return _navigateGenres(key);
//     if (_channelFocusNodes.any((n) => n.hasFocus)) return _navigateChannels(key);

//     return KeyEventResult.ignored;
//   }

//   KeyEventResult _navigateSearchBtn(LogicalKeyboardKey key) {
//     if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       setState(() => _showKeyboard = true);
//       if (_keyboardFocusNodes.isNotEmpty) _keyboardFocusNodes[0].requestFocus();
//     } else if (key == LogicalKeyboardKey.arrowRight && _genreFocusNodes.isNotEmpty) {
//       _genreFocusNodes[0].requestFocus();
//     } else if (key == LogicalKeyboardKey.arrowDown && _channelFocusNodes.isNotEmpty) {
//       _focusChannelAtIndex(0);
//     }
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateGenres(LogicalKeyboardKey key) {
//     if (_genres.isEmpty) return KeyEventResult.handled;
    
//     int i = _focusedGenreIndex;
//     if (i < 0) i = 0;

//     if (key == LogicalKeyboardKey.arrowLeft) {
//       if (i > 0) {
//         i--;
//       } else {
//         _searchButtonFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight && i < _genres.length - 1) {
//       i++;
//     } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _changeGenre(i);
//       return KeyEventResult.handled;
//     }

//     if (i != _focusedGenreIndex) {
//       setState(() => _focusedGenreIndex = i);
//       _genreFocusNodes[i].requestFocus();
//       _scrollGenreToFocus(i);
//     }
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateChannels(LogicalKeyboardKey key) {
//     final list = _isSearching ? _searchResults : _currentDisplayList;
//     if (list.isEmpty) return KeyEventResult.handled;
//     if (_isNavigationLocked) return KeyEventResult.handled;
//     _isNavigationLocked = true;
//     _navigationLockTimer?.cancel();
//     _navigationLockTimer = Timer(_navigationLockDuration, () {
//       if (!_isDisposed && mounted) setState(() => _isNavigationLocked = false);
//     });

//     int i = _focusedChannelIndex;
//     if (i < 0) i = 0;
//     if (i >= list.length) i = list.length - 1;

//     if (key == LogicalKeyboardKey.arrowUp) {
//       setState(() => _focusedChannelIndex = -1);
//       if (_focusedGenreIndex >= 0 && _focusedGenreIndex < _genres.length) {
//         _genreFocusNodes[_focusedGenreIndex].requestFocus();
//       } else {
//         _searchButtonFocusNode.requestFocus();
//       }
//       return KeyEventResult.handled;
//     }

//     if (key == LogicalKeyboardKey.arrowLeft && i > 0) i--;
//     else if (key == LogicalKeyboardKey.arrowRight && i < list.length - 1) i++;
//     else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _playChannel(list[i]);
//       return KeyEventResult.handled;
//     }

//     if (i != _focusedChannelIndex) {
//       _focusChannelAtIndex(i);
//     }
//     return KeyEventResult.handled;
//   }

//   void _focusChannelAtIndex(int index) {
//     if (_isDisposed || _channelFocusNodes.isEmpty) return;
//     final list = _isSearching ? _searchResults : _currentDisplayList;
//     if (index >= list.length) return;

//     setState(() => _focusedChannelIndex = index);
    
//     Future.delayed(const Duration(milliseconds: 50), () {
//       if (!_isDisposed && mounted && index < _channelFocusNodes.length) {
//         _channelFocusNodes[index].requestFocus();
//         _scrollChannelToFocus(index);
//       }
//     });
//   }

//   // ==========================================================
//   // GENRE SWITCHING
//   // ==========================================================
  
//   Timer? _genreChangeDebounce;

//   void _changeGenre(int index) {
//     if (_isDisposed || _isGenreSwitching || _isProcessing) return;
//     if (index < 0 || index >= _genres.length) return;

//     _genreChangeDebounce?.cancel();
//     _navigationLockTimer?.cancel();
//     _genreChangeDebounce = Timer(const Duration(milliseconds: 50), () {
//       if (!_isDisposed && mounted) _executeGenreChange(index);
//     });
//   }

//   void _executeGenreChange(int index) {
//     if (_isDisposed) return;
//     _isGenreSwitching = true;

//     final newGenre = _genres[index];
//     final newList = _channelsByGenre[newGenre] ?? [];

//     setState(() {
//       _focusedGenreIndex = index;
//       _selectedGenre = newGenre;
//       _isSearching = false;
//       _searchResults = [];
//       _searchText = '';
//       _focusedChannelIndex = -1;
//       _currentDisplayList = newList;
//     });

//     Future.microtask(() {
//       if (_isDisposed) return;
//       _rebuildChannelNodes();
      
//       if (_channelScrollController.hasClients) {
//         _channelScrollController.jumpTo(0);
//       }

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!_isDisposed && mounted && _channelFocusNodes.isNotEmpty) {
//            setState(() => _focusedChannelIndex = 0);
//            Future.delayed(const Duration(milliseconds: 100), () {
//              if (!_isDisposed && mounted && _channelFocusNodes.isNotEmpty) {
//                _channelFocusNodes[0].requestFocus();
//              }
//              _isGenreSwitching = false;
//            });
//         } else {
//           _isGenreSwitching = false;
//         }
//       });
//     });
//   }

//   // ==========================================================
//   // VIRTUAL KEYBOARD LOGIC
//   // ==========================================================

//   KeyEventResult _navigateVirtualKeyboard(LogicalKeyboardKey key) {
//     int r = _focusedKeyRow;
//     int c = _focusedKeyCol;

//     if (key == LogicalKeyboardKey.arrowUp && r > 0) {
//       r--;
//     } else if (key == LogicalKeyboardKey.arrowDown && r < _keyboardLayout.length - 1) {
//       r++;
//       c = math.min(c, _keyboardLayout[r].length - 1);
//     } else if (key == LogicalKeyboardKey.arrowLeft && c > 0) {
//       c--;
//     } else if (key == LogicalKeyboardKey.arrowRight && c < _keyboardLayout[r].length - 1) {
//       c++;
//     } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _onKeyClick(_keyboardLayout[r][c]);
//       return KeyEventResult.handled;
//     }

//     if (r != _focusedKeyRow || c != _focusedKeyCol) {
//       setState(() {
//         _focusedKeyRow = r;
//         _focusedKeyCol = c;
//       });
//       int idx = 0;
//       for (int i = 0; i < r; i++) idx += _keyboardLayout[i].length;
//       idx += c;
//       if (idx < _keyboardFocusNodes.length) {
//         _keyboardFocusNodes[idx].requestFocus();
//       }
//     }
//     return KeyEventResult.handled;
//   }

//   void _onKeyClick(String val) {
//     if (_isDisposed) return;
//     setState(() {
//       if (val == "OK") {
//         _showKeyboard = false;
//         _searchButtonFocusNode.requestFocus();
//       } else if (val == "DEL") {
//         if (_searchText.isNotEmpty) _searchText = _searchText.substring(0, _searchText.length - 1);
//       } else if (val == "SPACE") {
//         _searchText += " ";
//       } else {
//         _searchText += val;
//       }
//       _performSearch(_searchText);
//     });
//   }

//   void _performSearch(String t) {
//     if (_isDisposed) return;
//     setState(() {
//       if (t.isEmpty) {
//         _isSearching = false;
//         _searchResults = [];
//       } else {
//         _isSearching = true;
//         _searchResults = _allChannels.where((c) => c.name.toUpperCase().contains(t.toUpperCase())).toList();
//       }
//       _rebuildChannelNodes();
//     });
//   }





//   Future<void> _playChannel(NewsChannel channel) async {
//     if (_isDisposed || _isProcessing || _isVideoLoading) return;

//     setState(() {
//       _isProcessing = true;
//       _isVideoLoading = true;
//     });

//     try {
//       // --- 1. History Service (Surrounded by Try-Catch so it doesn't stop playback) ---
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         String userIdStr = prefs.getString('user_id') ?? '';
//         int? userId = int.tryParse(userIdStr);
        
//         if (userId != null) {
//           // 🔥 FIX: Ensure all parameters match what HistoryService expects
//           // If HistoryService expects Strings, we convert them. 
//           // If it expects ints, int.tryParse handles it.
//           await HistoryService.updateUserHistory(
//             userId: userId,
//             // 🔥 Possible Error Source: Converting to String just in case
//             contentType: int.tryParse(channel.contentType) ?? 4, 
//             eventId: channel.id, 
//             eventTitle: channel.name,
//             url: channel.url,
//             categoryId: 0
//           );
//         }
//       } catch (historyError) {
//         print("History Update Failed (Non-fatal): $historyError");
//       }

//       // --- 2. Playback Logic ---
//       String playableUrl = channel.url; 
//       if (playableUrl.isEmpty) throw Exception("Empty URL");

//       final deviceInfo = context.read<DeviceInfoProvider>();
      
//       // Check for Youtube
//       if (channel.streamType == 'YoutubeLive' || (channel.url.contains('youtube') || channel.url.contains('youtu.be'))) {
//          if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(builder: (c) => YoutubeWebviewPlayer(videoUrl: playableUrl, name: channel.name))
//             );
//          } else {
//             // Raw Youtube ID check
//             String videoId = playableUrl;
//             // If it's a full URL, extract ID (Basic check)
//             if (playableUrl.contains('v=')) {
//                videoId = playableUrl.split('v=')[1].split('&')[0];
//             } else if (playableUrl.contains('youtu.be/')) {
//                videoId = playableUrl.split('youtu.be/')[1].split('?')[0];
//             }

//             await Navigator.push(
//               context,
//               MaterialPageRoute(builder: (c) => CustomYoutubePlayer(
//                 videoData: VideoData(
//                   id: videoId,
//                   title: channel.name,
//                   youtubeUrl: playableUrl,
//                   thumbnail: channel.banner,
//                   description: ''
//                 ),
//                 playlist: const []
//               ))
//             );
//          }
//       } else {
//         // --- 3. M3U8 / Other Player ---
//         final list = _isSearching ? _searchResults : _currentDisplayList;
        
//         // 🔥 FIX: Converting everything to String explicitly to prevent Type Cast Errors
//         List<NewsItemModel> playerList = list.map((c) => NewsItemModel(
//           id: c.id.toString(),
//           name: c.name,
//           banner: c.banner,
//           url: c.url,
//           streamType: c.streamType,
//           status: c.status.toString(),
//           genres: c.genres,
//           videoId: '', 
//           description: '', 
//           poster: c.banner, 
//           category: c.genres, 
//           type: c.streamType, 
//           index: '0', 
//           image: c.banner, 
//           unUpdatedUrl: c.url, 
//           updatedAt: ''
//         )).toList();

//         await Navigator.push(
//           context,
//           MaterialPageRoute(builder: (c) => VideoScreen(
//             videoUrl: playableUrl,
//             bannerImageUrl: channel.banner,
//             source: 'isLive',
//             channelList: playerList,
//             videoId: channel.id,
//             name: channel.name,
//             liveStatus: true,
//             updatedAt: channel.updatedAt ?? '',
//           ))
//         );
//       }

//     } catch (e) {
//       if (!_isDisposed && mounted) {
//         print("Playback Error Details: $e"); // Check console for exact line
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Playback Error: ${e.toString()}'), backgroundColor: Colors.red,)
//         );
//       }
//     } finally {
//       if (!_isDisposed && mounted) {
//         setState(() {
//           _isProcessing = false;
//           _isVideoLoading = false;
//         });
//       }
//     }
//   }

//   // ==========================================================
//   // BUILD UI
//   // ==========================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Focus(
//         focusNode: _widgetFocusNode,
//         autofocus: true,
//         onKey: _onKeyHandler,
//         child: Stack(
//           fit: StackFit.expand, // 🔥 CRITICAL FIX
//           children: [
//             _buildBackgroundSlider(),
//             if (_isLoading)
//               const Center(child: CircularProgressIndicator(color: Colors.white))
//             else if (_error != null)
//               Center(child: Text("Error: $_error", style: const TextStyle(color: Colors.white)))
//             else
//               FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     SizedBox(
//                       height: MediaQuery.of(context).padding.top + 60,
//                       child: _buildBeautifulAppBar(),
//                     ),
//                     const Spacer(),
//                     if (_showKeyboard) _buildSearchUI(),
//                     _buildSliderIndicators(),
//                     const SizedBox(height: 10),
//                     _buildGenreBarWithGlassEffect(),
//                     const SizedBox(height: 15),
//                     SizedBox(
//                       height: bannerhgt + 50,
//                       child: _buildChannelsList(),
//                     ),
//                     const SizedBox(height: 15),
//                   ],
//                 ),
//               ),
            
//             if (_isVideoLoading)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black54,
//                   child: const Center(child: CircularProgressIndicator(color: Colors.white)),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBackgroundSlider() {
//     return RepaintBoundary(
//       child: SizedBox.expand( // 🔥 CRITICAL FIX
//         child: Stack(
//           fit: StackFit.expand, // 🔥 CRITICAL FIX
//           children: [
//             if (_sliders.isNotEmpty)
//               PageView.builder(
//                 controller: _sliderPageController,
//                 itemCount: _sliders.length,
//                 onPageChanged: (i) {
//                   if (!_isDisposed && mounted) setState(() => _currentSliderPage = i);
//                 },
//                 itemBuilder: (c, i) => Image.network(
//                   _sliders[i].banner,
//                   fit: BoxFit.cover,
//                   errorBuilder: (c,e,s) => Container(color: Colors.black),
//                 ),
//               )
//             else 
//               Container(color: ProfessionalColors.primaryDark),
            
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent,
//                       ProfessionalColors.primaryDark.withOpacity(0.7),
//                       ProfessionalColors.primaryDark
//                     ],
//                     stops: const [0.3, 0.6, 1.0],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBeautifulAppBar() {
//     final focusName = context.watch<InternalFocusProvider>().focusedItemName;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.black.withOpacity(0.5), Colors.transparent],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           GradientText(
//             widget.languageName,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
//             gradient: const LinearGradient(
//               colors: [
//                 ProfessionalColors.accentPink,
//                 ProfessionalColors.accentPurple,
//                 ProfessionalColors.accentBlue,
//               ],
//             ),
//           ),
//           const SizedBox(width: 20),
//           Expanded(
//             child: Text(
//               focusName,
//               style: const TextStyle(
//                 color: ProfessionalColors.textSecondary,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 20,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGenreBarWithGlassEffect() {
//     return SizedBox(
//       height: 38,
//       child: ListView.builder(
//         controller: _genreScrollController,
//         scrollDirection: Axis.horizontal,
//         itemCount: _genres.length + 1,

//         padding: const EdgeInsets.symmetric(horizontal: 40),
//         itemBuilder: (context, index) {
//           if (index == 0) {
//              return _buildGlassEffectButton(
//                focusNode: _searchButtonFocusNode,
//                label: "SEARCH",
//                icon: Icons.search,
//                isSelected: _isSearching,
//                focusColor: ProfessionalColors.accentOrange,
//                marginLeft: 0,
//                marginRight: 12,
//                onFocusChange: (hasFocus) {
//                  if (hasFocus && !_isDisposed && mounted) {
//                    Provider.of<InternalFocusProvider>(context, listen: false).updateName("Search");
//                  }
//                },
//                onTap: () {
//                  if (!_isDisposed) {
//                    _searchButtonFocusNode.requestFocus();
//                    setState(() => _showKeyboard = true);
//                  }
//                },
//              );
//           }

//           final genreIndex = index - 1;
//           final genre = _genres[genreIndex];
//           final focusNode = _genreFocusNodes[genreIndex];
//           final isSelected = !_isSearching && _selectedGenre == genre;
//           final focusColor = _focusColors[genreIndex % _focusColors.length];

//           return _buildGlassEffectButton(
//             focusNode: focusNode,
//             label: genre.toUpperCase(),
//             icon: null,
//             isSelected: isSelected,
//             focusColor: focusColor,
//             marginLeft: 12,
//             marginRight: 12,
//             onFocusChange: (hasFocus) {
//               if (hasFocus && !_isDisposed && mounted) {
//                 setState(() => _focusedGenreIndex = genreIndex);
//                 Provider.of<InternalFocusProvider>(context, listen: false).updateName(genre);
//               }
//             },
//             onTap: () {
//                if (!_isDisposed) {
//                  focusNode.requestFocus();
//                  _changeGenre(genreIndex);
//                }
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildGlassEffectButton({
//     required FocusNode focusNode,
//     required String label,
//     required IconData? icon,
//     required bool isSelected,
//     required Color focusColor,
//     required double marginLeft,
//     required double marginRight,
//     required Function(bool) onFocusChange,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: EdgeInsets.only(left: marginLeft, right: marginRight),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(30),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//             child: Focus(
//               focusNode: focusNode,
//               onFocusChange: onFocusChange,
//               child: AnimatedContainer(
//                 duration: AnimationTiming.fast,
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: focusNode.hasFocus
//                       ? focusColor
//                       : isSelected
//                           ? focusColor.withOpacity(0.5)
//                           : Colors.white.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(30),
//                   border: Border.all(
//                     color: focusNode.hasFocus ? Colors.white : Colors.white.withOpacity(0.3),
//                     width: focusNode.hasFocus ? 3 : 2,
//                   ),
//                   boxShadow: focusNode.hasFocus
//                       ? [BoxShadow(color: focusColor.withOpacity(0.8), blurRadius: 15, spreadRadius: 3)]
//                       : null,
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (icon != null) ...[Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 8)],
//                     Text(
//                       label,
//                       style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildChannelsList() {
//     final list = _isSearching ? _searchResults : _currentDisplayList;
//     if (list.isEmpty) return const Center(child: Text("No Channels Available", style: TextStyle(color: Colors.white54)));
    
//     final safeCount = math.min(list.length, _channelFocusNodes.length);

//     return ListView.builder(
//       key: ValueKey('channels_${_selectedGenre}_${_isSearching}'),
//       controller: _channelScrollController,
//       scrollDirection: Axis.horizontal,
//       clipBehavior: Clip.none,
//       padding: const EdgeInsets.symmetric(horizontal: 40),
//       itemCount: safeCount,
//       itemBuilder: (context, index) {
//         if (index >= list.length || index >= _channelFocusNodes.length) return const SizedBox.shrink();

//         return ChannelItemWithColorSystem(
//           key: ValueKey('${list[index].id}_$index'),
//           channel: list[index],
//           focusNode: _channelFocusNodes[index],
//           isFocused: _focusedChannelIndex == index,
//           uniqueIndex: index,
//           focusColors: _focusColors,
//           onFocus: () {
//             if (!_isDisposed && mounted) {
//               setState(() => _focusedChannelIndex = index);
//               Provider.of<InternalFocusProvider>(context, listen: false).updateName(list[index].name);
//             }
//           },
//           onTap: () => _playChannel(list[index]),
//         );
//       },
//     );
//   }

//   Widget _buildSearchUI() {
//     return Container(
//       height: 200,
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.symmetric(horizontal: 40),
//       child: Row(
//         children: [
//           Expanded(
//             child: Center(
//               child: Text(
//                 _searchText.isEmpty ? "SEARCH..." : _searchText,
//                 style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//           Expanded(flex: 2, child: _buildKeyboardKeys()),
//         ],
//       ),
//     );
//   }

//   Widget _buildKeyboardKeys() {
//     int nodeIdx = 0;
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: _keyboardLayout.asMap().entries.map((rEntry) {
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: rEntry.value.asMap().entries.map((cEntry) {
//             final key = cEntry.value;
//             final isFocused = _focusedKeyRow == rEntry.key && _focusedKeyCol == cEntry.key;
//             final idx = nodeIdx++;
//             double w = (key == "SPACE") ? 150 : (key == "OK" || key == "DEL" ? 60 : 35);
            
//             return Container(
//               margin: const EdgeInsets.all(2),
//               width: w,
//               height: 32,
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 100),
//                 decoration: BoxDecoration(
//                   color: isFocused ? ProfessionalColors.accentPurple : Colors.black87,
//                   borderRadius: BorderRadius.circular(4),
//                   border: Border.all(color: isFocused ? Colors.white : Colors.white10, width: isFocused ? 2 : 1),
//                   boxShadow: isFocused ? [BoxShadow(color: ProfessionalColors.accentPurple.withOpacity(0.5), blurRadius: 8)] : null,
//                 ),
//                 child: Center(
//                   child: Text(
//                     key,
//                     style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: isFocused ? FontWeight.bold : FontWeight.normal),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildSliderIndicators() {
//     if (_sliders.isEmpty) return const SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10), // Added padding
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: List.generate(_sliders.length, (i) => 
//           AnimatedContainer(
//             duration: AnimationTiming.fast,
//             margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
//             height: 8,
//             width: _currentSliderPage == i ? 24 : 8,
//             decoration: BoxDecoration(
//               color: _currentSliderPage == i ? ProfessionalColors.accentBlue : Colors.white.withOpacity(0.5),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 2, offset: const Offset(0, 1))
//               ]
//             ),
//           )
//         ),
//       ),
//     );
//   }
// }

// // ==========================================================
// // CHANNEL ITEM COMPONENT
// // ==========================================================

// class ChannelItemWithColorSystem extends StatefulWidget {
//   final NewsChannel channel;
//   final FocusNode focusNode;
//   final bool isFocused;
//   final int uniqueIndex;
//   final List<Color> focusColors;
//   final VoidCallback onFocus;
//   final VoidCallback onTap;

//   const ChannelItemWithColorSystem({
//     super.key,
//     required this.channel,
//     required this.focusNode,
//     required this.isFocused,
//     required this.uniqueIndex,
//     required this.focusColors,
//     required this.onFocus,
//     required this.onTap,
//   });

//   @override
//   State<ChannelItemWithColorSystem> createState() => _ChannelItemWithColorSystemState();
// }

// class _ChannelItemWithColorSystemState extends State<ChannelItemWithColorSystem> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   Color get _focusColor => widget.focusColors[widget.uniqueIndex % widget.focusColors.length];

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
    
//     return RepaintBoundary(
//       child: Padding(
//         padding: const EdgeInsets.only(right: 15),
//         child: InkWell(
//           focusNode: widget.focusNode,
//           onFocusChange: (has) {
//             if (has) widget.onFocus();
//           },
//           onTap: widget.onTap,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               AnimatedContainer(
//                 duration: AnimationTiming.fast,
//                 width: bannerwdt, 
//                 height: bannerhgt, 
//                 transform: widget.isFocused ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
//                 transformAlignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: widget.isFocused ? _focusColor : Colors.white10,
//                     width: widget.isFocused ? 3 : 1,
//                   ),
//                   boxShadow: widget.isFocused ? [BoxShadow(color: _focusColor.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)] : [],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(5),
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       Image.network(
//                         widget.channel.banner,
//                         fit: BoxFit.cover,
//                         errorBuilder: (c, e, s) => Container(
//                           color: ProfessionalColors.cardDark,
//                           child: const Icon(Icons.tv, color: Colors.white24, size: 40),
//                         ),
//                       ),
//                       if (widget.isFocused)
//                         Container(color: Colors.black12, child: Icon(Icons.play_circle_fill, color: _focusColor, size: 30)),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               SizedBox(
//                 width: bannerwdt,
//                 child: Text(
//                   widget.channel.name,
//                   maxLines: 1,
//                   textAlign: TextAlign.center,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: widget.isFocused ? _focusColor : Colors.white60,
//                     fontSize: 12,
//                     fontWeight: widget.isFocused ? FontWeight.bold : FontWeight.normal,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class GradientText extends StatelessWidget {
//   const GradientText(this.text, {super.key, required this.gradient, this.style});
//   final String text;
//   final TextStyle? style;
//   final Gradient gradient;

//   @override
//   Widget build(BuildContext context) {
//     return ShaderMask(
//       blendMode: BlendMode.srcIn,
//       shaderCallback: (bounds) => gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
//       child: Text(text, style: style),
//     );
//   }
// }





