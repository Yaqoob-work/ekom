// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/provider/internal_focus_provider.dart';
// import 'package:mobi_tv_entertainment/services/history_service.dart';
// import 'package:mobi_tv_entertainment/video_widget/live_video_screen.dart';
// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // ==========================================================
// // ENUMS, HELPERS AND DATA MODELS
// // ==========================================================

// enum LoadingState { initial, loading, loaded, error }

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
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
// }

// class NewsChannel {
//   final int id;
//   final String name;
//   final String banner;
//   final String url;
//   final String genres;
//   final int status;
//   final String streamType;
//   final String contentType;

//   NewsChannel({
//     required this.id,
//     required this.name,
//     required this.banner,
//     required this.url,
//     required this.genres,
//     required this.status,
//     required this.streamType,
//     required this.contentType,
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
//       contentType: json['content_type']?.toString() ?? '',
//     );
//   }
// }

// // ==========================================================
// // MAIN SCREEN WIDGET
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

// class _LanguageChannelsScreenState extends State<LanguageChannelsScreen> {
//   LoadingState _loadingState = LoadingState.initial;
//   String? _error;

//   // Data state
//   List<NewsChannel> _allChannels = [];
//   List<String> _genres = [];
//   Map<String, List<NewsChannel>> _channelsByGenre = {};
//   int _selectedGenreIndex = 0;
//   List<NewsChannel> _currentDisplayList = [];
//   String _backgroundImageUrl = '';

//   // Search state
//   bool _isSearching = false;
//   bool _showKeyboard = false;
//   String _searchText = '';
//   Timer? _debounce;
//   List<NewsChannel> _searchResults = [];
//   bool _isSearchLoading = false;
//   bool _isVideoLoading = false;

//   // Focus Nodes
//   late FocusNode _searchButtonFocusNode;
//   List<FocusNode> _genreFocusNodes = [];
//   List<FocusNode> _channelFocusNodes = [];

//   // Keys and Controllers
//   List<GlobalKey> _genreButtonKeys = [];
//   List<GlobalKey> _channelCardKeys = [];
//   final ScrollController _genreScrollController = ScrollController();
//   final ScrollController _channelScrollController = ScrollController();

//   final List<Color> _focusColors = [
//     ProfessionalColors.accentBlue,
//     ProfessionalColors.accentPurple,
//     ProfessionalColors.accentGreen,
//     ProfessionalColors.accentOrange,
//     ProfessionalColors.accentPink,
//     ProfessionalColors.accentRed
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _searchButtonFocusNode = FocusNode();
//     _searchButtonFocusNode.addListener(() {
//       if (mounted) {
//         setState(() {});
//         if (_searchButtonFocusNode.hasFocus) {
//           Provider.of<InternalFocusProvider>(context, listen: false).updateName("Search");
//         }
//       }
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<InternalFocusProvider>(context, listen: false).updateName('');
//       _fetchAndProcessData();
//     });
//   }

//   @override
//   void dispose() {
//     _cleanupResources();
//     super.dispose();
//   }

//   void _cleanupResources() {
//     _searchButtonFocusNode.dispose();
//     for (var node in _genreFocusNodes) node.dispose();
//     for (var node in _channelFocusNodes) node.dispose();
//     _genreScrollController.dispose();
//     _channelScrollController.dispose();
//     _debounce?.cancel();
//   }

//   Future<void> _fetchAndProcessData() async {
//     if (mounted) setState(() => _loadingState = LoadingState.loading);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final authKey = prefs.getString('result_auth_key') ?? '';

//       final response = await https.post(
//         Uri.parse('https://dashboard.cpplayers.com/api/v2/getAllLiveTV'),
//         headers: {
//           'auth-key': authKey,
//           'domain': 'coretechinfo.com',
//           'Content-Type': 'application/json'
//         },
//         body: json.encode({"genere": "", "languageId": widget.languageId}),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> channelsData = json.decode(response.body);
//         _allChannels = channelsData
//             .map((item) => NewsChannel.fromJson(item))
//             .where((channel) => channel.status == 1)
//             .toList();

//         if (_allChannels.isEmpty) {
//           throw Exception('No channels found for this language.');
//         }

//         final Map<String, List<NewsChannel>> channelsByGenre = {};
//         final Set<String> uniqueGenres = {};

//         for (final channel in _allChannels) {
//           final genres = channel.genres.split(',').map((g) => g.trim()).toList();
//           for (var genre in genres) {
//             if (genre.isNotEmpty) {
//               uniqueGenres.add(genre);
//               channelsByGenre.putIfAbsent(genre, () => []).add(channel);
//             }
//           }
//         }

//         List<String> sortedGenres = uniqueGenres.toList()..sort();

//         if (!mounted) return;
//         setState(() {
//           _genres = sortedGenres;
//           _channelsByGenre = channelsByGenre;
//           _selectedGenreIndex = 0;
//           _backgroundImageUrl = _allChannels.first.banner;

//           _genreFocusNodes = List.generate(_genres.length, (_) => FocusNode());
//           _genreButtonKeys = List.generate(_genres.length, (_) => GlobalKey());

//           for (int i = 0; i < _genres.length; i++) {
//             _genreFocusNodes[i].addListener(() {
//               if (_genreFocusNodes[i].hasFocus) _onGenreFocus(i);
//             });
//           }
//           _loadingState = LoadingState.loaded;
//         });

//         _shuffleAndSetDisplayList();
//         _rebuildChannelNodes();

//         Future.delayed(const Duration(milliseconds: 200), () {
//           if (mounted && _searchButtonFocusNode.canRequestFocus) {
//             _searchButtonFocusNode.requestFocus();
//           }
//         });
//       } else {
//         throw Exception('API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = e.toString();
//           _loadingState = LoadingState.error;
//         });
//       }
//     }
//   }

//   void _shuffleAndSetDisplayList() {
//     if (_genres.isEmpty) return;
//     final originalList = _channelsByGenre[_genres[_selectedGenreIndex]] ?? [];
//     final shuffledList = List<NewsChannel>.from(originalList)..shuffle();
//     setState(() {
//       _currentDisplayList = shuffledList;
//     });
//   }

//   void _rebuildChannelNodes() {
//     if (!mounted) return;
//     for (var node in _channelFocusNodes) node.dispose();

//     final currentList = _isSearching ? _searchResults : _currentDisplayList;
//     _channelFocusNodes = List.generate(currentList.length, (_) => FocusNode());
//     _channelCardKeys = List.generate(currentList.length, (_) => GlobalKey());

//     for (int i = 0; i < currentList.length; i++) {
//       _channelFocusNodes[i].addListener(() {
//         if (_channelFocusNodes[i].hasFocus) _onChannelFocus(i);
//       });
//     }
//   }

//   void _performSearch(String searchTerm) {
//     _debounce?.cancel();
//     if (searchTerm.trim().isEmpty) {
//       setState(() {
//         _isSearching = false;
//         _isSearchLoading = false;
//         _searchResults.clear();
//         _rebuildChannelNodes();
//       });
//       return;
//     }

//     setState(() {
//       _isSearchLoading = true;
//       _isSearching = true;
//       _searchResults.clear();
//     });

//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       if (!mounted) return;
//       final results = _allChannels.where((channel) =>
//         channel.name.toLowerCase().contains(searchTerm.toLowerCase())
//       ).toList();

//       setState(() {
//         _searchResults = results;
//         _isSearchLoading = false;
//         _rebuildChannelNodes();
//       });
//     });
//   }

//   void _onKeyPressed(String value) {
//     setState(() {
//       if (value == 'OK') {
//         _showKeyboard = false;
//         if (_channelFocusNodes.isNotEmpty) {
//           _channelFocusNodes.first.requestFocus();
//         } else {
//           _searchButtonFocusNode.requestFocus();
//         }
//         return;
//       }

//       if (value == 'DEL') {
//         if (_searchText.isNotEmpty) {
//           _searchText = _searchText.substring(0, _searchText.length - 1);
//         }
//       } else {
//         _searchText += value;
//       }
//       _performSearch(_searchText);
//     });
//   }

//   void _updateChannelsForGenre(int index) {
//     if (_isSearching) {
//       setState(() {
//         _isSearching = false;
//         _searchText = '';
//         _searchResults.clear();
//       });
//     }
//     if (_selectedGenreIndex == index) {
//       _shuffleAndSetDisplayList();
//       _rebuildChannelNodes();
//       return;
//     }
//     setState(() => _selectedGenreIndex = index);
//     _shuffleAndSetDisplayList();
//     _rebuildChannelNodes();
//   }

//   void _onGenreFocus(int index) {
//     if (!mounted || index >= _genres.length) return;
//     Provider.of<InternalFocusProvider>(context, listen: false).updateName(_genres[index]);

//     final buttonContext = _genreButtonKeys[index].currentContext;
//     if (buttonContext != null) {
//       Scrollable.ensureVisible(buttonContext,
//           duration: const Duration(milliseconds: 300), curve: Curves.easeOut, alignment: 0.5);
//     }
//   }

//   void _onChannelFocus(int index) {
//     if (!mounted) return;
//     final currentList = _isSearching ? _searchResults : _currentDisplayList;
//     if (index < currentList.length) {
//       Provider.of<InternalFocusProvider>(context, listen: false).updateName(currentList[index].name);
//     }
//     final cardContext = _channelCardKeys[index].currentContext;
//     if (cardContext != null) {
//       Scrollable.ensureVisible(cardContext,
//           duration: const Duration(milliseconds: 300), curve: Curves.easeOut, alignment: 0.5);
//     }
//   }

//   Future<void> _playChannel(NewsChannel channel) async {
//     if (_isVideoLoading) return;
//     setState(() => _isVideoLoading = true);

//     try {
//       int? userId = int.tryParse((await SharedPreferences.getInstance()).getString('user_id') ?? '');
//       if (userId != null) {
//         await HistoryService.updateUserHistory(
//             userId: userId, contentType: int.tryParse(channel.contentType) ?? 4, eventId: channel.id,
//             eventTitle: channel.name, url: channel.url, categoryId: 0);
//       }
//     } catch (e) {
//       if (kDebugMode) print("History update failed: $e");
//     }

//     try {
//       List<NewsItemModel> allChannelsForPlayer = _allChannels.map((c) => NewsItemModel(
//         id: c.id.toString(), videoId: '', name: c.name, description: '', banner: c.banner,
//         poster: c.banner, category: c.genres, url: c.url, streamType: c.streamType,
//         type: c.streamType, genres: c.genres, status: c.status.toString(),
//         index: _allChannels.indexOf(c).toString(), image: c.banner, unUpdatedUrl: c.url, updatedAt: '',
//       )).toList();

//       NewsItemModel currentChannel = allChannelsForPlayer.firstWhere((item) => item.id == channel.id.toString());

//       if (!mounted) return;
//       await Navigator.push(context,
//         MaterialPageRoute(builder: (context) => LiveVideoScreen(
//           videoUrl: currentChannel.url, bannerImageUrl: currentChannel.banner, source: 'isLive',
//           channelList: allChannelsForPlayer, videoId: int.tryParse(currentChannel.id),
//           name: currentChannel.name, liveStatus: true, updatedAt: currentChannel.updatedAt,
//         )),
//       );
//     } catch (e) {
//       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error playing channel: $e')));
//     } finally {
//       if (mounted) setState(() => _isVideoLoading = false);
//     }
//   }

//   // ==========================================================
//   // BUILD METHODS
//   // ==========================================================

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     // MODIFIED: This constant is no longer used for the SizedBox height but is kept for the ChannelCard.
//     const double bannerhgt = 100.0;

//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           if (_loadingState == LoadingState.loaded)
//             _showKeyboard
//                 ? Container(color: ProfessionalColors.primaryDark)
//                 : _buildStaticBackground(),
//           if (_loadingState == LoadingState.loading || _loadingState == LoadingState.initial)
//             const Center(child: CircularProgressIndicator())
//           else if (_error != null)
//             Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.white)))
//           else
//             Column(
//               children: [
//                 SizedBox(
//                   height: screenSize.height * 0.63,
//                   child: _showKeyboard ? _buildSearchUI() : const SizedBox.shrink(),
//                 ),
//                 _buildGenreButtons(),
//                 // MODIFIED: Reduced height from bannerhgt * 1.5 to bannerhgt * 1.3 to prevent overflow.
//                 SizedBox(height: bannerhgt * 1.3, child: _buildChannelsList()),
//               ],
//             ),
//           if (_loadingState == LoadingState.loaded)
//             Positioned(top: 0, left: 0, right: 0, child: _buildBeautifulAppBar()),
//           if (_isVideoLoading)
//             Container(
//               color: Colors.black.withOpacity(0.7),
//               child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStaticBackground() {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         if (_backgroundImageUrl.isNotEmpty)
//           Image.network(_backgroundImageUrl, fit: BoxFit.cover,
//             errorBuilder: (c, e, s) => Container(color: ProfessionalColors.primaryDark)),
//         Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter, end: Alignment.bottomCenter,
//               colors: [
//                 Colors.transparent,
//                 ProfessionalColors.primaryDark.withOpacity(0.5),
//                 ProfessionalColors.primaryDark,
//               ],
//               stops: const [0.4, 0.7, 1.0],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBeautifulAppBar() {
//     final focusedName = context.watch<InternalFocusProvider>().focusedItemName;
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter, end: Alignment.bottomCenter,
//           colors: [
//             ProfessionalColors.primaryDark.withOpacity(0.8),
//             ProfessionalColors.primaryDark.withOpacity(0.5),
//             Colors.transparent
//           ]
//         ),
//       ),
//       child: Padding(
//         padding: EdgeInsets.only(
//           top: MediaQuery.of(context).padding.top + 10, left: 40, right: 40, bottom: 10),
//         child: Row(
//           children: [
//             GradientText(widget.languageName,
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//               gradient: const LinearGradient(colors: [
//                 ProfessionalColors.accentPink,
//                 ProfessionalColors.accentPurple,
//               ])
//             ),
//             const SizedBox(width: 40),
//             Expanded(
//               child: Text(focusedName,
//                 textAlign: TextAlign.left,
//                 style: const TextStyle(color: ProfessionalColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 20),
//                 overflow: TextOverflow.ellipsis
//               )
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGenreButtons() {
//     return SizedBox(
//       height: 60,
//       child: ListView.builder(
//         controller: _genreScrollController,
//         scrollDirection: Axis.horizontal,
//         itemCount: _genres.length + 1,
//         padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
//         itemBuilder: (context, index) {
//           if (index == 0) {
//             // Search Button
//             return Focus(
//               focusNode: _searchButtonFocusNode,
//               onKey: (node, event) {
//                 if (event is RawKeyDownEvent && (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.select)) {
//                   setState(() => _showKeyboard = true);
//                   return KeyEventResult.handled;
//                 }
//                 if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                   if (_genreFocusNodes.isNotEmpty) {
//                     _genreFocusNodes.first.requestFocus();
//                     return KeyEventResult.handled;
//                   }
//                 }
//                 return KeyEventResult.ignored;
//               },
//               child: GestureDetector(
//                 onTap: () {
//                   _searchButtonFocusNode.requestFocus();
//                   setState(() => _showKeyboard = true);
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.only(right: 15),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(30),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: _searchButtonFocusNode.hasFocus
//                               ? ProfessionalColors.accentOrange.withOpacity(0.7)
//                               : Colors.white.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(30),
//                           border: Border.all(
//                             color: _searchButtonFocusNode.hasFocus ? Colors.white : Colors.white.withOpacity(0.3),
//                             width: _searchButtonFocusNode.hasFocus ? 3 : 2,
//                           ),
//                         ),
//                         child: const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.search, color: Colors.white),
//                             SizedBox(width: 8),
//                             Text("Search", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }
//           // Genre Buttons
//           final genreIndex = index - 1;
//           final genre = _genres[genreIndex];
//           final isSelected = !_isSearching && _selectedGenreIndex == genreIndex;
//           return Focus(
//             focusNode: _genreFocusNodes[genreIndex],
//             onKey: (node, event) {
//               if (event is RawKeyDownEvent) {
//                 if (event.logicalKey == LogicalKeyboardKey.arrowLeft && genreIndex == 0) {
//                   _searchButtonFocusNode.requestFocus();
//                   return KeyEventResult.handled;
//                 }
//                 if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.select) {
//                   _updateChannelsForGenre(genreIndex);
//                   return KeyEventResult.handled;
//                 }
//               }
//               return KeyEventResult.ignored;
//             },
//             child: GestureDetector(
//               onTap: () => _genreFocusNodes[genreIndex].requestFocus(),
//               child: Container(
//                 key: _genreButtonKeys[genreIndex],
//                 margin: const EdgeInsets.only(right: 15),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(30.0),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: isSelected ? _focusColors[genreIndex % _focusColors.length].withOpacity(0.6) : Colors.white.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(30),
//                         border: Border.all(
//                           color: _genreFocusNodes[genreIndex].hasFocus ? Colors.white : Colors.white.withOpacity(0.3),
//                           width: _genreFocusNodes[genreIndex].hasFocus ? 3 : 2,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(genre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildChannelsList() {
//     final currentList = _isSearching ? _searchResults : _currentDisplayList;

//     if (_isSearchLoading) return const Center(child: CircularProgressIndicator());
//     if (currentList.isEmpty) {
//       return Center(
//         child: Text(
//           _isSearching && _searchText.isNotEmpty ? "No results found for '$_searchText'" : "No channels available for this genre.",
//           style: const TextStyle(color: ProfessionalColors.textSecondary, fontSize: 16)
//         ),
//       );
//     }
//     return Padding(
//       padding: const EdgeInsets.only(top: 10.0),
//       child: ListView.builder(
//         controller: _channelScrollController,
//         scrollDirection: Axis.horizontal,
//         itemCount: currentList.length,
//         padding: const EdgeInsets.symmetric(horizontal: 40.0),
//         itemBuilder: (context, index) {
//           final channel = currentList[index];
//           return Focus(
//             focusNode: _channelFocusNodes[index],
//             onKey: (node, event) {
//               if (event is RawKeyDownEvent && (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
//                 _playChannel(channel);
//                 return KeyEventResult.handled;
//               }
//               return KeyEventResult.ignored;
//             },
//             child: ChannelCard(
//                 key: _channelCardKeys[index],
//                 channel: channel,
//                 focusNode: _channelFocusNodes[index],
//                 focusColors: _focusColors,
//                 uniqueIndex: index,
//                 onTap: () => _playChannel(channel)),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSearchUI() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           flex: 4,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const GradientText("Search for Channels", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                   gradient: LinearGradient(colors: [ProfessionalColors.accentBlue, ProfessionalColors.accentPurple])),
//                 const SizedBox(height: 24),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: ProfessionalColors.accentPurple, width: 2),
//                   ),
//                   child: Text(
//                     _searchText.isEmpty ? 'Start typing...' : _searchText,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: _searchText.isEmpty ? Colors.white54 : Colors.white,
//                       fontSize: 22, fontWeight: FontWeight.w600,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Expanded(flex: 6, child: _buildQwertyKeyboard()),
//       ],
//     );
//   }

//   Widget _buildQwertyKeyboard() {
//     final row1 = "1234567890".split('');
//     final row2 = "QWERTYUIOP".split('');
//     final row3 = "ASDFGHJKL".split('');
//     final row4 = "ZXCVBNM,.".split('');
//     final row5 = ["DEL", " ", "OK"];

//     return Container(
//       color: Colors.transparent,
//       padding: const EdgeInsets.all(10),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildKeyboardRow(row1),
//           _buildKeyboardRow(row2),
//           _buildKeyboardRow(row3),
//           _buildKeyboardRow(row4),
//           _buildKeyboardRow(row5),
//         ],
//       ),
//     );
//   }

//   Widget _buildKeyboardRow(List<String> keys) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: keys.map((key) {
//         return Expanded(
//           flex: (key == ' ' || key == 'OK' || key == 'DEL') ? 2 : 1,
//           child: Container(
//             margin: const EdgeInsets.all(4),
//             child: ElevatedButton(
//               onPressed: () => _onKeyPressed(key),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white.withOpacity(0.1), foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 // MODIFIED: Reduced vertical padding from 16 to 12 to make keyboard shorter.
//                 padding: const EdgeInsets.symmetric(vertical: 12)
//               ),
//               child: Text(key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

// // ==========================================================
// // REUSABLE WIDGETS
// // ==========================================================

// class ChannelCard extends StatefulWidget {
//   final NewsChannel channel;
//   final FocusNode focusNode;
//   final List<Color> focusColors;
//   final int uniqueIndex;
//   final VoidCallback onTap;

//   const ChannelCard(
//       {super.key,
//       required this.channel,
//       required this.focusNode,
//       required this.focusColors,
//       required this.uniqueIndex,
//       required this.onTap});

//   @override
//   State<ChannelCard> createState() => _ChannelCardState();
// }

// class _ChannelCardState extends State<ChannelCard> {
//   bool _hasFocus = false;

//   @override
//   void initState() {
//     super.initState();
//     widget.focusNode.addListener(_onFocusChange);
//   }

//   @override
//   void dispose() {
//     widget.focusNode.removeListener(_onFocusChange);
//     super.dispose();
//   }

//   void _onFocusChange() {
//     if (mounted && widget.focusNode.hasFocus != _hasFocus) {
//       setState(() => _hasFocus = widget.focusNode.hasFocus);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final focusColor = widget.focusColors[widget.uniqueIndex % widget.focusColors.length];
//     final screenSize = MediaQuery.of(context).size;

//     return Container(
//       width: screenSize.width / 8,
//       margin: const EdgeInsets.only(right: 12.0),
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Expanded(
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8.0),
//                     border: _hasFocus ? Border.all(color: focusColor, width: 3) : Border.all(color: Colors.transparent, width: 3),
//                     boxShadow: _hasFocus ? [BoxShadow(color: focusColor.withOpacity(0.5), blurRadius: 12, spreadRadius: 1)] : [],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(6.0),
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       Image.network(widget.channel.banner, fit: BoxFit.cover,
//                         errorBuilder: (c, e, s) => Container(color: ProfessionalColors.cardDark, child: Center(child: Icon(Icons.tv, color: Colors.white54))),
//                         loadingBuilder: (c, child, progress) => progress == null ? child : Container(color: ProfessionalColors.cardDark)
//                       ),
//                        if (_hasFocus)
//                         Container(color: Colors.black.withOpacity(0.4), child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40)),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//                 padding: const EdgeInsets.only(top: 4.0, left: 2.0, right: 2.0),
//                 child: Text(widget.channel.name,
//                     style: TextStyle(color: _hasFocus ? focusColor : ProfessionalColors.textSecondary, fontSize: 14),
//                     maxLines: 1, overflow: TextOverflow.ellipsis)),
//           ],
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

// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';
// import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // ==========================================================
// // ENUMS, HELPERS AND DATA MODELS
// // ==========================================================

// enum LoadingState { initial, loading, loaded, error }

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
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
// }

// // NEW: Data model for slider items from the languages API
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

// class NewsChannel {
//   final int id;
//   final String name;
//   final String banner;
//   final String url;
//   final String genres;
//   final int status;
//   final String streamType;
//   final String contentType;

//   NewsChannel({
//     required this.id,
//     required this.name,
//     required this.banner,
//     required this.url,
//     required this.genres,
//     required this.status,
//     required this.streamType,
//     required this.contentType,
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
//       contentType: json['content_type']?.toString() ?? '',
//     );
//   }
// }

// // ==========================================================
// // MAIN SCREEN WIDGET
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

// class _LanguageChannelsScreenState extends State<LanguageChannelsScreen> {
//   LoadingState _loadingState = LoadingState.initial;
//   String? _error;

//   // Data state
//   List<NewsChannel> _allChannels = [];
//   List<String> _genres = [];
//   Map<String, List<NewsChannel>> _channelsByGenre = {};
//   int _selectedGenreIndex = 0;
//   List<NewsChannel> _currentDisplayList = [];
//   String _backgroundImageUrl = '';

//   // NEW: Slider state variables
//   List<SliderItem> _sliders = [];
//   PageController? _sliderPageController;
//   Timer? _sliderTimer;
//   int _currentSliderPage = 0;

//   // Search state
//   bool _isSearching = false;
//   bool _showKeyboard = false;
//   String _searchText = '';
//   Timer? _debounce;
//   List<NewsChannel> _searchResults = [];
//   bool _isSearchLoading = false;
//   bool _isVideoLoading = false;

//   // Focus Nodes
//   late FocusNode _searchButtonFocusNode;
//   List<FocusNode> _genreFocusNodes = [];
//   List<FocusNode> _channelFocusNodes = [];

//   // Keys and Controllers
//   List<GlobalKey> _genreButtonKeys = [];
//   List<GlobalKey> _channelCardKeys = [];
//   final ScrollController _genreScrollController = ScrollController();
//   final ScrollController _channelScrollController = ScrollController();
//     bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   final List<Color> _focusColors = [
//     ProfessionalColors.accentBlue,
//     ProfessionalColors.accentPurple,
//     ProfessionalColors.accentGreen,
//     ProfessionalColors.accentOrange,
//     ProfessionalColors.accentPink,
//     ProfessionalColors.accentRed
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _searchButtonFocusNode = FocusNode();
//     _searchButtonFocusNode.addListener(() {
//       if (mounted) {
//         setState(() {});
//         if (_searchButtonFocusNode.hasFocus) {
//           Provider.of<InternalFocusProvider>(context, listen: false)
//               .updateName("Search");
//         }
//       }
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<InternalFocusProvider>(context, listen: false).updateName('');
//       _fetchAndProcessData();
//     });
//   }

//   @override
//   void dispose() {
//     _cleanupResources();
//     super.dispose();
//   }

//   void _cleanupResources() {
//     _searchButtonFocusNode.dispose();
//     for (var node in _genreFocusNodes) node.dispose();
//     for (var node in _channelFocusNodes) node.dispose();
//     _genreScrollController.dispose();
//     _channelScrollController.dispose();
//     _debounce?.cancel();
//     // NEW: Dispose slider resources
//     _sliderPageController?.dispose();
//     _sliderTimer?.cancel();
//     _navigationLockTimer?.cancel();
//   }

//   // MODIFIED: This function now also fetches language data for the slider.
//   Future<void> _fetchAndProcessData() async {
//     if (mounted) setState(() => _loadingState = LoadingState.loading);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//             String authKey = SessionManager.authKey ;
//       var url = Uri.parse(SessionManager.baseUrl + 'getAllLanguages');

//       // --- NEW: Fetch slider data ---
//       try {
//         final languagesResponse = await https.get(url,
//           // Uri.parse(

//           //     'https://dashboard.cpplayers.com/public/api/v2/getAllLanguages'
//           //     ),
//           headers: {
//             'auth-key': authKey,
//             'domain': SessionManager.savedDomain,
//           },
//         );

//         if (languagesResponse.statusCode == 200) {
//           final languagesData = json.decode(languagesResponse.body);
//           if (languagesData['status'] == true &&
//               languagesData['languages'] is List) {
//             final allLanguages = languagesData['languages'] as List;
//             // Find the language that matches the current screen's language ID
//             final currentLanguage = allLanguages.firstWhere(
//               (lang) => lang['id'].toString() == widget.languageId,
//               orElse: () => null,
//             );

//             if (currentLanguage != null &&
//                 currentLanguage['slider'] is List &&
//                 (currentLanguage['slider'] as List).isNotEmpty) {
//               final sliderData = currentLanguage['slider'] as List;
//               if (mounted) {
//                 setState(() {
//                   _sliders = sliderData
//                       .map((item) => SliderItem.fromJson(item))
//                       .toList();
//                 });
//               }
//             }
//           }
//         }
//       } catch (e) {
//         // If fetching sliders fails, we can ignore it and proceed
//         if (kDebugMode) {
//           print("Could not fetch slider data: $e");
//         }
//       }
//       // --- End of new slider fetch logic ---

//       final response = await https.post(
//         Uri.parse(
//           SessionManager.baseUrl + 'getAllLiveTV'
//           // 'https://dashboard.cpplayers.com/api/v2/getAllLiveTV'
//           ),
//         headers: {
//           'auth-key': authKey,
//           // 'domain': 'coretechinfo.com',
//           'domain': SessionManager.savedDomain ,
//           'Content-Type': 'application/json'
//         },
//         body: json.encode({"genere": "", "languageId": widget.languageId}),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> channelsData = json.decode(response.body);
//         _allChannels = channelsData
//             .map((item) => NewsChannel.fromJson(item))
//             .where((channel) => channel.status == 1)
//             .toList();

//         if (_allChannels.isEmpty) {
//           throw Exception('No channels found for this language.');
//         }

//         final Map<String, List<NewsChannel>> channelsByGenre = {};
//         final Set<String> uniqueGenres = {};

//         for (final channel in _allChannels) {
//           final genres = channel.genres.split(',').map((g) => g.trim()).toList();
//           for (var genre in genres) {
//             if (genre.isNotEmpty) {
//               uniqueGenres.add(genre);
//               channelsByGenre.putIfAbsent(genre, () => []).add(channel);
//             }
//           }
//         }

//         List<String> sortedGenres = uniqueGenres.toList()..sort();

//         if (!mounted) return;
//         setState(() {
//           _genres = sortedGenres;
//           _channelsByGenre = channelsByGenre;
//           _selectedGenreIndex = 0;
//           // Set fallback background image, which will be used if no slider exists
//           _backgroundImageUrl = _allChannels.first.banner;

//           _genreFocusNodes = List.generate(_genres.length, (_) => FocusNode());
//           _genreButtonKeys = List.generate(_genres.length, (_) => GlobalKey());

//           for (int i = 0; i < _genres.length; i++) {
//             _genreFocusNodes[i].addListener(() {
//               if (_genreFocusNodes[i].hasFocus) _onGenreFocus(i);
//             });
//           }
//           _loadingState = LoadingState.loaded;
//         });

//         _shuffleAndSetDisplayList();
//         _rebuildChannelNodes();
//         _setupSliderTimer(); // NEW: Setup the slider timer

//         Future.delayed(const Duration(milliseconds: 200), () {
//           if (mounted && _searchButtonFocusNode.canRequestFocus) {
//             _searchButtonFocusNode.requestFocus();
//           }
//         });
//       } else {
//         throw Exception('API Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = e.toString();
//           _loadingState = LoadingState.error;
//         });
//       }
//     }
//   }

//   // NEW: Method to set up the auto-scrolling timer for the slider
//   void _setupSliderTimer() {
//     _sliderTimer?.cancel();
//     if (_sliders.length > 1 && mounted) {
//       _sliderPageController = PageController(initialPage: 0);
//       _sliderTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
//         if (!mounted || _sliderPageController?.hasClients == false) return;

//         int nextPage = _currentSliderPage + 1;
//         if (nextPage >= _sliders.length) {
//           _sliderPageController?.jumpToPage(0);
//         } else {
//           _sliderPageController?.animateToPage(
//             nextPage,
//             duration: const Duration(milliseconds: 800),
//             curve: Curves.easeInOut,
//           );
//         }
//       });
//     }
//   }

//   void _shuffleAndSetDisplayList() {
//     if (_genres.isEmpty) return;
//     final originalList = _channelsByGenre[_genres[_selectedGenreIndex]] ?? [];
//     // final shuffledList = List<NewsChannel>.from(originalList)..shuffle();
//     setState(() {
//       // _currentDisplayList = shuffledList;
//       _currentDisplayList = originalList;
//     });
//   }

//   void _rebuildChannelNodes() {
//     if (!mounted) return;
//     for (var node in _channelFocusNodes) node.dispose();

//     final currentList = _isSearching ? _searchResults : _currentDisplayList;
//     _channelFocusNodes = List.generate(currentList.length, (_) => FocusNode());
//     _channelCardKeys = List.generate(currentList.length, (_) => GlobalKey());

//     for (int i = 0; i < currentList.length; i++) {
//       _channelFocusNodes[i].addListener(() {
//         if (_channelFocusNodes[i].hasFocus) _onChannelFocus(i);
//       });
//     }
//   }

//   void _performSearch(String searchTerm) {
//     _debounce?.cancel();
//     if (searchTerm.trim().isEmpty) {
//       setState(() {
//         _isSearching = false;
//         _isSearchLoading = false;
//         _searchResults.clear();
//         _rebuildChannelNodes();
//       });
//       return;
//     }

//     setState(() {
//       _isSearchLoading = true;
//       _isSearching = true;
//       _searchResults.clear();
//     });

//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       if (!mounted) return;
//       final results = _allChannels
//           .where((channel) =>
//               channel.name.toLowerCase().contains(searchTerm.toLowerCase()))
//           .toList();

//       setState(() {
//         _searchResults = results;
//         _isSearchLoading = false;
//         _rebuildChannelNodes();
//       });
//     });
//   }

//   void _onKeyPressed(String value) {
//     setState(() {
//       if (value == 'OK') {
//         _showKeyboard = false;
//         if (_channelFocusNodes.isNotEmpty) {
//           _channelFocusNodes.first.requestFocus();
//         } else {
//           _searchButtonFocusNode.requestFocus();
//         }
//         return;
//       }

//       if (value == 'DEL') {
//         if (_searchText.isNotEmpty) {
//           _searchText = _searchText.substring(0, _searchText.length - 1);
//         }
//       } else {
//         _searchText += value;
//       }
//       _performSearch(_searchText);
//     });
//   }

//   void _updateChannelsForGenre(int index) {
//     if (_isSearching) {
//       setState(() {
//         _isSearching = false;
//         _searchText = '';
//         _searchResults.clear();
//       });
//     }
//     if (_selectedGenreIndex == index) {
//       // _shuffleAndSetDisplayList();
//       // _rebuildChannelNodes();
//       return;
//     }
//     setState(() => _selectedGenreIndex = index);
//     _shuffleAndSetDisplayList();
//     _rebuildChannelNodes();
//   }

//   void _onGenreFocus(int index) {
//     if (!mounted || index >= _genres.length) return;
//     Provider.of<InternalFocusProvider>(context, listen: false)
//         .updateName(_genres[index]);

//     final buttonContext = _genreButtonKeys[index].currentContext;
//     if (buttonContext != null) {
//       Scrollable.ensureVisible(buttonContext,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//           alignment: 0.5);
//     }
//   }

//   void _onChannelFocus(int index) {
//     if (!mounted) return;
//     final currentList = _isSearching ? _searchResults : _currentDisplayList;
//     if (index < currentList.length) {
//       Provider.of<InternalFocusProvider>(context, listen: false)
//           .updateName(currentList[index].name);
//     }
//     final cardContext = _channelCardKeys[index].currentContext;
//     if (cardContext != null) {
//       Scrollable.ensureVisible(cardContext,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//           alignment: 0.5);
//     }
//   }

//   // Future<void> _playChannel(NewsChannel channel) async {
//   //   if (_isVideoLoading) return;
//   //   setState(() => _isVideoLoading = true);

//   //   try {
//   //     int? userId = int.tryParse(
//   //         (await SharedPreferences.getInstance()).getString('user_id') ?? '');
//   //     if (userId != null) {
//   //       await HistoryService.updateUserHistory(
//   //           userId: userId,
//   //           contentType: int.tryParse(channel.contentType) ?? 4,
//   //           eventId: channel.id,
//   //           eventTitle: channel.name,
//   //           url: channel.url,
//   //           categoryId: 0);
//   //     }
//   //   } catch (e) {
//   //     if (kDebugMode) print("History update failed: $e");
//   //   }

//   //   try {
//   //     List<NewsItemModel> allChannelsForPlayer = _allChannels
//   //         .map((c) => NewsItemModel(
//   //               id: c.id.toString(),
//   //               videoId: '',
//   //               name: c.name,
//   //               description: '',
//   //               banner: c.banner,
//   //               poster: c.banner,
//   //               category: c.genres,
//   //               url: c.url,
//   //               streamType: c.streamType,
//   //               type: c.streamType,
//   //               genres: c.genres,
//   //               status: c.status.toString(),
//   //               index: _allChannels.indexOf(c).toString(),
//   //               image: c.banner,
//   //               unUpdatedUrl: c.url,
//   //               updatedAt: '',
//   //             ))
//   //         .toList();

//   //     NewsItemModel currentChannel = allChannelsForPlayer
//   //         .firstWhere((item) => item.id == channel.id.toString());

//   //     if (!mounted) return;
//   //     await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (context) => LiveVideoScreen(
//   //           videoUrl: currentChannel.url,
//   //           bannerImageUrl: currentChannel.banner,
//   //           source: 'isLive',
//   //           channelList: allChannelsForPlayer,
//   //           videoId: int.tryParse(currentChannel.id),
//   //           name: currentChannel.name,
//   //           liveStatus: true,
//   //           updatedAt: currentChannel.updatedAt,
//   //         ),
//   //       ),
//   //     );
//   //   } catch (e) {
//   //     if (mounted)
//   //       ScaffoldMessenger.of(context)
//   //           .showSnackBar(SnackBar(content: Text('Error playing channel: $e')));
//   //   } finally {
//   //     if (mounted) setState(() => _isVideoLoading = false);
//   //   }
//   // }

//   Future<void> _playChannel(NewsChannel channel) async {
//     if (_isVideoLoading) return;
//     setState(() => _isVideoLoading = true);

//     try {
//       int? userId = int.tryParse(
//           (await SharedPreferences.getInstance()).getString('user_id') ?? '');
//       if (userId != null) {
//         await HistoryService.updateUserHistory(
//             userId: userId,
//             contentType: int.tryParse(channel.contentType) ?? 4,
//             eventId: channel.id,
//             eventTitle: channel.name,
//             url: channel.url,
//             categoryId: 0);
//       }
//     } catch (e) {
//       if (kDebugMode) print("History update failed: $e");
//     }

//     try {
//       // --- YAHAN BADLAV SHURU HOTA HAI ---

//       // Step 1: Pata karein ki current mein kaun si list active hai.
//       final List<NewsChannel> sourceList =
//           _isSearching ? _searchResults : _currentDisplayList;

//       // Step 2: Active list (sourceList) se player ke liye list banayein, na ki _allChannels se.
//       List<NewsItemModel> channelsForPlayer = sourceList
//           .map((c) => NewsItemModel(
//                 id: c.id.toString(),
//                 videoId: '',
//                 name: c.name,
//                 description: '',
//                 banner: c.banner,
//                 poster: c.banner,
//                 category: c.genres,
//                 url: c.url,
//                 streamType: c.streamType,
//                 type: c.streamType,
//                 genres: c.genres,
//                 status: c.status.toString(),
//                 index: sourceList.indexOf(c).toString(), // sourceList use karein
//                 image: c.banner,
//                 unUpdatedUrl: c.url,
//                 updatedAt: '',
//               ))
//           .toList();

//       NewsItemModel currentChannel = channelsForPlayer
//           .firstWhere((item) => item.id == channel.id.toString());

//       // --- BADLAV YAHAN KHATAM HOTA HAI ---

//       if (!mounted) return;
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => VideoScreen (
//             videoUrl: currentChannel.url,
//             bannerImageUrl: currentChannel.banner,
//             source: 'isLive',
//             // Step 3: Filter ki hui nayi list (channelsForPlayer) ko pass karein.
//             channelList: channelsForPlayer,
//             videoId: int.tryParse(currentChannel.id),
//             name: currentChannel.name,
//             liveStatus: true,
//             updatedAt: currentChannel.updatedAt,
//           ),
//         ),
//       );
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Error playing channel: $e')));
//     } finally {
//       if (mounted) setState(() => _isVideoLoading = false);
//     }
//   }

//   // ==========================================================
//   // BUILD METHODS
//   // ==========================================================

//   @override
//   Widget build(BuildContext context) {
//     // const double bannerhgt = 100.0;

//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           if (_loadingState == LoadingState.loaded)
//             _showKeyboard
//                 ? Container(color: ProfessionalColors.primaryDark)
//                 // MODIFIED: This now conditionally shows the slider or static image
//                 : _buildStaticBackground(),
//           if (_loadingState == LoadingState.loading ||
//               _loadingState == LoadingState.initial)
//             const Center(child: CircularProgressIndicator())
//           else if (_error != null)
//             Center(
//                 child: Text('Error: $_error',
//                     style: const TextStyle(color: Colors.white)))
//           else
//             Column(
//               children: [
//                 SizedBox(
//                   height: screenhgt * 0.68,
//                   child: _showKeyboard
//                       ? _buildSearchUI()
//                       : const SizedBox.shrink(),
//                 ),
//                 _buildGenreButtons(),
//                 SizedBox(
//                     height: bannerhgt * 1.5, child: _buildChannelsList()),
//               ],
//             ),
//           if (_loadingState == LoadingState.loaded)
//             Positioned(
//                 top: 0, left: 0, right: 0, child: _buildBeautifulAppBar()),
//           if (_isVideoLoading)
//             Container(
//               color: Colors.black.withOpacity(0.7),
//               child: const Center(
//                   child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
//             ),
//         ],
//       ),
//     );
//   }

// // MODIFIED: This widget now builds a PageView slider if sliders are available.
//   Widget _buildStaticBackground() {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         // Conditionally build PageView or fallback Image
//         if (_sliders.isNotEmpty && _sliderPageController != null)
//           PageView.builder(
//             controller: _sliderPageController,
//             itemCount: _sliders.length,
//             onPageChanged: (index) {
//               if (mounted) {
//                 setState(() => _currentSliderPage = index);
//               }
//             },
//             itemBuilder: (context, index) {
//               final slider = _sliders[index];
//               return Image.network(
//                 slider.banner,
//                 // YAHAN BADLAV KAREIN: .cover se .fill karein
//                 fit: BoxFit.fill,
//                 errorBuilder: (c, e, s) =>
//                     Container(color: ProfessionalColors.primaryDark),
//               );
//             },
//           )
//         else if (_backgroundImageUrl.isNotEmpty)
//           // Fallback to the original background
//           Image.network(
//             _backgroundImageUrl,
//              // Aap chahein to isse bhi .fill kar sakte hain
//             fit: BoxFit.cover,
//             errorBuilder: (c, e, s) =>
//                 Container(color: ProfessionalColors.primaryDark),
//           )
//         else
//           Container(color: ProfessionalColors.primaryDark),

//         // Gradient overlay
//         // Container(
//         //   decoration: BoxDecoration(
//         //     gradient: LinearGradient(
//         //       begin: Alignment.topCenter,
//         //       end: Alignment.bottomCenter,
//         //       colors: [
//         //         Colors.transparent,
//         //         ProfessionalColors.primaryDark.withOpacity(0.5),
//         //         ProfessionalColors.primaryDark,
//         //       ],
//         //       stops: const [0.4, 0.7, 1.0],
//         //     ),
//         //   ),
//         // ),

//          // Gradient overlay
//         Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 // YAHAN BADLAV KAREIN: Colors ko aur zyada dark banayein
//                 ProfessionalColors.primaryDark.withOpacity(0.2), // Start a bit darker
//                 ProfessionalColors.primaryDark.withOpacity(0.4), // Mid-point darker
//                 ProfessionalColors.primaryDark.withOpacity(0.6), // Mid-point darker
//                 ProfessionalColors.primaryDark, // Full dark at the bottom
//               ],
//               stops: const [0.3, 0.6, 0.7,9.0], // Stops ko bhi adjust kar sakte hain
//               // stops: const [0.4, 0.7, 1.0], // Original stops
//             ),
//           ),
//         ),
//         // NEW: Slider indicator
//         if (_sliders.length > 1)
//           Positioned(
//             bottom: screenhgt * 0.35, // Adjust this value to position it above the lists
//             left: 0,
//             right: 0,
//             child: _buildSliderIndicator(),
//           )
//       ],
//     );
//   }

//   // NEW: Widget to build the slider indicator dots
//   Widget _buildSliderIndicator() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: _sliders.asMap().entries.map((entry) {
//         int index = entry.key;
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           width: _currentSliderPage == index ? 12.0 : 8.0,
//           height: _currentSliderPage == index ? 12.0 : 8.0,
//           margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: _currentSliderPage == index
//                 ? ProfessionalColors.accentBlue
//                 : Colors.white.withOpacity(0.4),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildBeautifulAppBar() {
//     final focusedName = context.watch<InternalFocusProvider>().focusedItemName;
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               ProfessionalColors.primaryDark.withOpacity(0.8),
//               ProfessionalColors.primaryDark.withOpacity(0.5),
//               Colors.transparent
//             ]),
//       ),
//       child: Padding(
//         padding: EdgeInsets.only(
//             top: MediaQuery.of(context).padding.top + 10,
//             left: 40,
//             right: 40,
//             bottom: 10),
//         child: Row(
//           children: [
//             GradientText(widget.languageName,
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//                 gradient: const LinearGradient(colors: [
//                   ProfessionalColors.accentPink,
//                   ProfessionalColors.accentPurple,
//                 ])),
//             const SizedBox(width: 40),
//             Expanded(
//                 child: Text(focusedName,
//                     textAlign: TextAlign.left,
//                     style: const TextStyle(
//                         color: ProfessionalColors.textSecondary,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20),
//                     overflow: TextOverflow.ellipsis)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGenreButtons() {
//     return SizedBox(
//       height: 30,
//       child: ListView.builder(
//         controller: _genreScrollController,
//         scrollDirection: Axis.horizontal,
//         itemCount: _genres.length + 1,
//         padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.03, vertical: 1),
//         itemBuilder: (context, index) {
//           if (index == 0) {
//             // Search Button
//             return Focus(
//               focusNode: _searchButtonFocusNode,
//               onKey: (node, event) {
//                 if (event is RawKeyDownEvent &&
//                     (event.logicalKey == LogicalKeyboardKey.enter ||
//                         event.logicalKey == LogicalKeyboardKey.select)) {
//                   setState(() => _showKeyboard = true);
//                   return KeyEventResult.handled;
//                 }
//                 if (event is RawKeyDownEvent &&
//                     event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                   if (_genreFocusNodes.isNotEmpty) {
//                     _genreFocusNodes.first.requestFocus();
//                     return KeyEventResult.handled;
//                   }
//                 }
//                 return KeyEventResult.ignored;
//               },
//               child: GestureDetector(
//                 onTap: () {
//                   _searchButtonFocusNode.requestFocus();
//                   setState(() => _showKeyboard = true);
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.only(right: 15),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(30),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 1),
//                         decoration: BoxDecoration(
//                           color: _searchButtonFocusNode.hasFocus
//                               ? ProfessionalColors.accentOrange.withOpacity(0.7)
//                               : Colors.white.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(30),
//                           border: Border.all(
//                             color: _searchButtonFocusNode.hasFocus
//                                 ? Colors.white
//                                 : Colors.white.withOpacity(0.3),
//                             width: _searchButtonFocusNode.hasFocus ? 3 : 2,
//                           ),
//                         ),
//                         child:  Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.search, color: Colors.white),
//                             SizedBox(width: 8),
//                             Text(("Search").toUpperCase(),
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16)),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }
//           // Genre Buttons
//           final genreIndex = index - 1;
//           final genre = _genres[genreIndex];
//           final isSelected = !_isSearching && _selectedGenreIndex == genreIndex;
//           return Focus(
//             focusNode: _genreFocusNodes[genreIndex],
//             onKey: (node, event) {
//               if (event is RawKeyDownEvent) {
//                 if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
//                     genreIndex == 0) {
//                   _searchButtonFocusNode.requestFocus();
//                   return KeyEventResult.handled;
//                 }
//                 if (event.logicalKey == LogicalKeyboardKey.enter ||
//                     event.logicalKey == LogicalKeyboardKey.select) {
//                   _updateChannelsForGenre(genreIndex);
//                   return KeyEventResult.handled;
//                 }
//               }
//               return KeyEventResult.ignored;
//             },
//             child: GestureDetector(
//               onTap: () => _genreFocusNodes[genreIndex].requestFocus(),
//               child: Container(
//                 key: _genreButtonKeys[genreIndex],
//                 margin: const EdgeInsets.only(right: 15),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(30.0),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 1),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? _focusColors[genreIndex % _focusColors.length]
//                                 .withOpacity(0.6)
//                             : Colors.white.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(30),
//                         border: Border.all(
//                           color: _genreFocusNodes[genreIndex].hasFocus
//                               ? Colors.white
//                               : Colors.white.withOpacity(0.3),
//                           width: _genreFocusNodes[genreIndex].hasFocus ? 3 : 2,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(genre.toUpperCase(),
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16)),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildChannelsList() {
//     final currentList = _isSearching ? _searchResults : _currentDisplayList;

//     if (_isSearchLoading) return const Center(child: CircularProgressIndicator());
//     if (currentList.isEmpty) {
//       return Center(
//         child: Text(
//             _isSearching && _searchText.isNotEmpty
//                 ? "No results found for '$_searchText'"
//                 : "No channels available for this genre.",
//             style: const TextStyle(
//                 color: ProfessionalColors.textSecondary, fontSize: 16)),
//       );
//     }
//     return Padding(
//       padding: const EdgeInsets.only(top: 10.0),
//       child: ListView.builder(
//         controller: _channelScrollController,
//         scrollDirection: Axis.horizontal,
//         itemCount: currentList.length,
//         padding:  EdgeInsets.symmetric(horizontal: screenwdt *0.03 ),
//         itemBuilder: (context, index) {
//           final channel = currentList[index];
//           return Focus(
//             focusNode: _channelFocusNodes[index],
//             // onKey: (node, event) {
//             //   if (event is RawKeyDownEvent &&
//             //       (event.logicalKey == LogicalKeyboardKey.select ||
//             //           event.logicalKey == LogicalKeyboardKey.enter)) {
//             //     _playChannel(channel);
//             //     return KeyEventResult.handled;
//             //   }
//             //   return KeyEventResult.ignored;
//             // },
//                      onKey: (node, event) {
//             if (event is RawKeyDownEvent) {
//               final key = event.logicalKey;

//               // --- हॉरिजॉन्टल मूवमेंट (लेफ्ट/राइट) के लिए थ्रॉटलिंग ---
//               if (key == LogicalKeyboardKey.arrowRight ||
//                   key == LogicalKeyboardKey.arrowLeft) {

//                 // 1. अगर नेविगेशन लॉक्ड है, तो कुछ न करें
//                 if (_isNavigationLocked) return KeyEventResult.handled;

//                 // 2. नेविगेशन को लॉक करें और 300ms का टाइमर शुरू करें
//                 setState(() => _isNavigationLocked = true);
//                 _navigationLockTimer = Timer(const Duration(milliseconds: 700), () {
//                   if (mounted) setState(() => _isNavigationLocked = false);
//                 });

//                 // 3. अब फोकस बदलें
//                 final currentList = _isSearching ? _searchResults : _currentDisplayList;

//                 if (key == LogicalKeyboardKey.arrowRight) {
//                   if (index < currentList.length - 1) {
//                     _channelFocusNodes[index + 1].requestFocus();
//                   } else {
//                     _navigationLockTimer?.cancel();
//                     if (mounted) setState(() => _isNavigationLocked = false);
//                   }
//                 } else if (key == LogicalKeyboardKey.arrowLeft) {
//                   if (index > 0) {
//                     _channelFocusNodes[index - 1].requestFocus();
//                   } else {
//                     _navigationLockTimer?.cancel();
//                     if (mounted) setState(() => _isNavigationLocked = false);
//                   }
//                 }
//                 return KeyEventResult.handled;
//               }

//               // --- वर्टिकल मूवमेंट (ऊपर) ---
//               if (key == LogicalKeyboardKey.arrowUp) {
//                 if (_genres.isNotEmpty) {
//                     _genreFocusNodes[_selectedGenreIndex].requestFocus();
//                 } else {
//                     _searchButtonFocusNode.requestFocus();
//                 }
//                 return KeyEventResult.handled;
//               }

//               // --- एक्शन (सेलेक्ट/एंटर) ---
//               if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//                 _playChannel(channel);
//                 return KeyEventResult.handled;
//               }
//             }
//             return KeyEventResult.ignored;
//           },
//             child: ChannelCard(
//                 key: _channelCardKeys[index],
//                 channel: channel,
//                 focusNode: _channelFocusNodes[index],
//                 focusColors: _focusColors,
//                 uniqueIndex: index,
//                 onTap: () => _playChannel(channel)),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSearchUI() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           flex: 4,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const GradientText("Search for Channels",
//                     style:
//                         TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                     gradient: LinearGradient(colors: [
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple
//                     ])),
//                 const SizedBox(height: 24),
//                 Container(
//                   width: double.infinity,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                         color: ProfessionalColors.accentPurple, width: 2),
//                   ),
//                   child: Text(
//                     _searchText.isEmpty ? 'Start typing...' : _searchText,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color:
//                           _searchText.isEmpty ? Colors.white54 : Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Expanded(flex: 6, child: _buildQwertyKeyboard()),
//       ],
//     );
//   }

//   Widget _buildQwertyKeyboard() {
//     final row1 = "1234567890".split('');
//     final row2 = "QWERTYUIOP".split('');
//     final row3 = "ASDFGHJKL".split('');
//     final row4 = "ZXCVBNM,.".split('');
//     final row5 = ["DEL", " ", "OK"];

//     return Container(
//       color: Colors.transparent,
//       padding: const EdgeInsets.all(10),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildKeyboardRow(row1),
//           _buildKeyboardRow(row2),
//           _buildKeyboardRow(row3),
//           _buildKeyboardRow(row4),
//           _buildKeyboardRow(row5),
//         ],
//       ),
//     );
//   }

//   Widget _buildKeyboardRow(List<String> keys) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: keys.map((key) {
//         return Expanded(
//           flex: (key == ' ' || key == 'OK' || key == 'DEL') ? 2 : 1,
//           child: Container(
//             margin: const EdgeInsets.all(4),
//             child: ElevatedButton(
//               onPressed: () => _onKeyPressed(key),
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white.withOpacity(0.1),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   padding: const EdgeInsets.symmetric(vertical: 12)),
//               child: Text(key,
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold)),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

// // ==========================================================
// // REUSABLE WIDGETS
// // ==========================================================

// class ChannelCard extends StatefulWidget {
//   final NewsChannel channel;
//   final FocusNode focusNode;
//   final List<Color> focusColors;
//   final int uniqueIndex;
//   final VoidCallback onTap;

//   const ChannelCard(
//       {super.key,
//       required this.channel,
//       required this.focusNode,
//       required this.focusColors,
//       required this.uniqueIndex,
//       required this.onTap});

//   @override
//   State<ChannelCard> createState() => _ChannelCardState();
// }

// class _ChannelCardState extends State<ChannelCard> {
//   bool _hasFocus = false;

//   @override
//   void initState() {
//     super.initState();
//     widget.focusNode.addListener(_onFocusChange);
//   }

//   @override
//   void dispose() {
//     widget.focusNode.removeListener(_onFocusChange);
//     super.dispose();
//   }

//   void _onFocusChange() {
//     if (mounted && widget.focusNode.hasFocus != _hasFocus) {
//       setState(() => _hasFocus = widget.focusNode.hasFocus);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final focusColor =
//         widget.focusColors[widget.uniqueIndex % widget.focusColors.length];
//     final screenSize = MediaQuery.of(context).size;

//     return Container(
//       width: bannerwdt,
//       margin: const EdgeInsets.only(right: 12.0),
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Expanded(
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8.0),
//                   border: _hasFocus
//                       ? Border.all(color: focusColor, width: 3)
//                       : Border.all(color: Colors.transparent, width: 3),
//                   boxShadow: _hasFocus
//                       ? [
//                           BoxShadow(
//                               color: focusColor.withOpacity(0.5),
//                               blurRadius: 12,
//                               spreadRadius: 1)
//                         ]
//                       : [],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(6.0),
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       Image.network(widget.channel.banner, fit: BoxFit.cover,
//                           errorBuilder: (c, e, s) => Container(
//                               color: ProfessionalColors.cardDark,
//                               child: Center(
//                                   child: Icon(Icons.tv, color: Colors.white54))),
//                           loadingBuilder: (c, child, progress) =>
//                               progress == null
//                                   ? child
//                                   : Container(color: ProfessionalColors.cardDark)),
//                       if (_hasFocus)
//                         Container(
//                             color: Colors.black.withOpacity(0.4),
//                             child: Icon(Icons.play_arrow_rounded,
//                                 color: Colors.white, size: 40)),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//                 padding:
//                     const EdgeInsets.only(top: 4.0, left: 2.0, right: 2.0),
//                 child: Text(widget.channel.name,
//                     style: TextStyle(
//                         color: _hasFocus
//                             ? focusColor
//                             : ProfessionalColors.textSecondary,
//                         fontSize: 14),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis)),
//           ],
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
//       shaderCallback: (bounds) =>
//           gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
//       child: Text(text, style: style),
//     );
//   }
// }








// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';
// import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // ==========================================================
// // ENUMS, HELPERS AND DATA MODELS
// // ==========================================================

// enum LoadingState { initial, loading, loaded, error }

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
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
// }

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

// class NewsChannel {
//   final int id;
//   final String name;
//   final String banner;
//   final String url;
//   final String genres;
//   final int status;
//   final String streamType;
//   final String contentType;

//   NewsChannel({
//     required this.id,
//     required this.name,
//     required this.banner,
//     required this.url,
//     required this.genres,
//     required this.status,
//     required this.streamType,
//     required this.contentType,
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
//       contentType: json['content_type']?.toString() ?? '',
//     );
//   }
// }

// // ==========================================================
// // MAIN SCREEN WIDGET
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

// class _LanguageChannelsScreenState extends State<LanguageChannelsScreen> {
//   LoadingState _loadingState = LoadingState.initial;
//   String? _error;

//   // Data state
//   List<NewsChannel> _allChannels = [];
//   List<String> _genres = [];
//   Map<String, List<NewsChannel>> _channelsByGenre = {};
//   int _selectedGenreIndex = 0;
//   List<NewsChannel> _currentDisplayList = [];
//   String _backgroundImageUrl = '';

//   // Slider state
//   List<SliderItem> _sliders = [];
//   PageController? _sliderPageController;
//   Timer? _sliderTimer;
//   int _currentSliderPage = 0;

//   // Search state
//   bool _isSearching = false;
//   bool _showKeyboard = false;
//   String _searchText = '';
//   Timer? _debounce;
//   List<NewsChannel> _searchResults = [];
//   bool _isSearchLoading = false;
//   bool _isVideoLoading = false;

//   // Focus Nodes
//   late FocusNode _searchButtonFocusNode;
//   List<FocusNode> _genreFocusNodes = [];
//   List<FocusNode> _channelFocusNodes = [];

//   // Keys and Controllers
//   List<GlobalKey> _genreButtonKeys = [];
//   List<GlobalKey> _channelCardKeys = [];
//   final ScrollController _genreScrollController = ScrollController();
//   final ScrollController _channelScrollController = ScrollController();
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   final List<Color> _focusColors = [
//     ProfessionalColors.accentBlue,
//     ProfessionalColors.accentPurple,
//     ProfessionalColors.accentGreen,
//     ProfessionalColors.accentOrange,
//     ProfessionalColors.accentPink,
//     ProfessionalColors.accentRed
//   ];

//   @override
//   void initState() {
//     super.initState();
//     SecureUrlService.refreshSettings();
//     _searchButtonFocusNode = FocusNode();
//     _searchButtonFocusNode.addListener(() {
//       if (mounted) {
//         setState(() {});
//         if (_searchButtonFocusNode.hasFocus) {
//           Provider.of<InternalFocusProvider>(context, listen: false)
//               .updateName("Search");
//         }
//       }
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<InternalFocusProvider>(context, listen: false).updateName('');
//       _fetchAndProcessData();
//     });
//   }

//   @override
//   void dispose() {
//     _cleanupResources();
//     super.dispose();
//   }

//   void _cleanupResources() {
//     _searchButtonFocusNode.dispose();
//     for (var node in _genreFocusNodes) node.dispose();
//     for (var node in _channelFocusNodes) node.dispose();
//     _genreScrollController.dispose();
//     _channelScrollController.dispose();
//     _debounce?.cancel();
//     _sliderPageController?.dispose();
//     _sliderTimer?.cancel();
//     _navigationLockTimer?.cancel();
//   }

//   // ==========================================================
//   // API FETCHING LOGIC (UPDATED WITH GENRE API)
//   // ==========================================================

//   Future<void> _fetchAndProcessData() async {
//     if (mounted) setState(() => _loadingState = LoadingState.loading);
//     try {
//       final authKey = SessionManager.authKey;
//       final domain = SessionManager.savedDomain;
//       final headers = {
//         'auth-key': authKey,
//         'domain': domain,
//         'Content-Type': 'application/json'
//       };

//       // 1. URLs Define karein
//       // NOTE: Check your API documentation for the exact Genre URL for Live TV.
//       // Usually it is 'getGenreByContentLive' or similar.
//       var langUrl = Uri.parse(SessionManager.baseUrl + 'getAllLanguages');
//       var tvUrl = Uri.parse(SessionManager.baseUrl + 'getAllLiveTV');
//       var genreUrl =
//           Uri.parse(SessionManager.baseUrl + 'getGenreByContentNetwork');

//       // 2. Parallel Calls (Sliders, Channels, Genres)
//       final results = await Future.wait([
//         https.get(langUrl, headers: headers), // 0: Languages (Sliders)
//         https.post(tvUrl,
//             headers: headers,
//             body: json.encode({
//               "genere": "",
//               "languageId": widget.languageId
//             })), // 1: Channels
//         https.post(genreUrl,
//             headers: headers,
//             body: json
//                 .encode({"language_id": widget.languageId})), // 2: Genres (NEW)
//       ]);

//       final langRes = results[0];
//       final tvRes = results[1];
//       final genreRes = results[2];

//       // --- Processing Sliders ---
//       if (langRes.statusCode == 200) {
//         try {
//           final languagesData = json.decode(langRes.body);
//           if (languagesData['status'] == true &&
//               languagesData['languages'] is List) {
//             final allLanguages = languagesData['languages'] as List;
//             final currentLanguage = allLanguages.firstWhere(
//               (lang) => lang['id'].toString() == widget.languageId,
//               orElse: () => null,
//             );

//             if (currentLanguage != null &&
//                 currentLanguage['slider'] is List &&
//                 (currentLanguage['slider'] as List).isNotEmpty) {
//               final sliderData = currentLanguage['slider'] as List;
//               if (mounted) {
//                 setState(() {
//                   _sliders = sliderData
//                       .map((item) => SliderItem.fromJson(item))
//                       .toList();
//                 });
//               }
//             }
//           }
//         } catch (e) {
//           if (kDebugMode) print("Slider fetch error: $e");
//         }
//       }

//       // --- Processing Genres and Channels ---
//       if (tvRes.statusCode == 200 && genreRes.statusCode == 200) {
//         // A. Parse Channels
//         final List<dynamic> channelsData = json.decode(tvRes.body);
//         _allChannels = channelsData
//             .map((item) => NewsChannel.fromJson(item))
//             .where((channel) => channel.status == 1)
//             .toList();

//         if (_allChannels.isEmpty) {
//           throw Exception('No channels found for this language.');
//         }

//         // B. Parse Genres from API
//         final genreData = json.decode(genreRes.body);
//         List<String> apiGenres = [];

//         if (genreData['status'] == true && genreData['genres'] != null) {
//           // Assuming API returns { "status": true, "genres": ["News", "Sports"] }
//           apiGenres = List<String>.from(genreData['genres']);
//         }

//         // Agar API se genres nahi mile, to fallback to extraction (Safety)
//         if (apiGenres.isEmpty) {
//           final Set<String> extractedGenres = {};
//           for (final channel in _allChannels) {
//             final gList =
//                 channel.genres.split(',').map((g) => g.trim()).toList();
//             extractedGenres.addAll(gList.where((g) => g.isNotEmpty));
//           }
//           apiGenres = extractedGenres.toList()..sort();
//         }

//         // C. Map Channels to API Genres
//         final Map<String, List<NewsChannel>> channelsByGenre = {};

//         // Initialize map for all API genres
//         for (var genre in apiGenres) {
//           channelsByGenre[genre] = [];
//         }

//         // Distribute channels
//         for (final channel in _allChannels) {
//           final channelGenres =
//               channel.genres.split(',').map((g) => g.trim()).toList();
//           for (var cGenre in channelGenres) {
//             // Sirf wahi genres use karein jo API list mein hain
//             if (channelsByGenre.containsKey(cGenre)) {
//               channelsByGenre[cGenre]!.add(channel);
//             }
//           }
//         }

//         // Remove empty genres if you want cleaner UI (Optional)
//         apiGenres.removeWhere((genre) => channelsByGenre[genre]!.isEmpty);

//         if (!mounted) return;
//         setState(() {
//           _genres = apiGenres;
//           _channelsByGenre = channelsByGenre;
//           _selectedGenreIndex = 0;
//           _backgroundImageUrl = _allChannels.first.banner;

//           _genreFocusNodes = List.generate(_genres.length, (_) => FocusNode());
//           _genreButtonKeys = List.generate(_genres.length, (_) => GlobalKey());

//           for (int i = 0; i < _genres.length; i++) {
//             _genreFocusNodes[i].addListener(() {
//               if (_genreFocusNodes[i].hasFocus) _onGenreFocus(i);
//             });
//           }
//           _loadingState = LoadingState.loaded;
//         });

//         _shuffleAndSetDisplayList();
//         _rebuildChannelNodes();
//         _setupSliderTimer();

//         Future.delayed(const Duration(milliseconds: 200), () {
//           if (mounted && _searchButtonFocusNode.canRequestFocus) {
//             _searchButtonFocusNode.requestFocus();
//           }
//         });
//       } else {
//         throw Exception(
//             'API Error. TV: ${tvRes.statusCode}, Genre: ${genreRes.statusCode}');
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = e.toString();
//           _loadingState = LoadingState.error;
//         });
//       }
//     }
//   }

//   void _setupSliderTimer() {
//     _sliderTimer?.cancel();
//     if (_sliders.length > 1 && mounted) {
//       _sliderPageController = PageController(initialPage: 0);
//       _sliderTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
//         if (!mounted || _sliderPageController?.hasClients == false) return;

//         int nextPage = _currentSliderPage + 1;
//         if (nextPage >= _sliders.length) {
//           _sliderPageController?.jumpToPage(0);
//         } else {
//           _sliderPageController?.animateToPage(
//             nextPage,
//             duration: const Duration(milliseconds: 800),
//             curve: Curves.easeInOut,
//           );
//         }
//       });
//     }
//   }

//   void _shuffleAndSetDisplayList() {
//     if (_genres.isEmpty) return;
//     final originalList = _channelsByGenre[_genres[_selectedGenreIndex]] ?? [];
//     setState(() {
//       _currentDisplayList = originalList;
//     });
//   }

//   void _rebuildChannelNodes() {
//     if (!mounted) return;
//     for (var node in _channelFocusNodes) node.dispose();

//     final currentList = _isSearching ? _searchResults : _currentDisplayList;
//     _channelFocusNodes = List.generate(currentList.length, (_) => FocusNode());
//     _channelCardKeys = List.generate(currentList.length, (_) => GlobalKey());

//     for (int i = 0; i < currentList.length; i++) {
//       _channelFocusNodes[i].addListener(() {
//         if (_channelFocusNodes[i].hasFocus) _onChannelFocus(i);
//       });
//     }
//   }

//   void _performSearch(String searchTerm) {
//     _debounce?.cancel();
//     if (searchTerm.trim().isEmpty) {
//       setState(() {
//         _isSearching = false;
//         _isSearchLoading = false;
//         _searchResults.clear();
//         _rebuildChannelNodes();
//       });
//       return;
//     }

//     setState(() {
//       _isSearchLoading = true;
//       _isSearching = true;
//       _searchResults.clear();
//     });

//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       if (!mounted) return;
//       final results = _allChannels
//           .where((channel) =>
//               channel.name.toLowerCase().contains(searchTerm.toLowerCase()))
//           .toList();

//       setState(() {
//         _searchResults = results;
//         _isSearchLoading = false;
//         _rebuildChannelNodes();
//       });
//     });
//   }

//   void _onKeyPressed(String value) {
//     setState(() {
//       if (value == 'OK') {
//         _showKeyboard = false;
//         if (_channelFocusNodes.isNotEmpty) {
//           _channelFocusNodes.first.requestFocus();
//         } else {
//           _searchButtonFocusNode.requestFocus();
//         }
//         return;
//       }

//       if (value == 'DEL') {
//         if (_searchText.isNotEmpty) {
//           _searchText = _searchText.substring(0, _searchText.length - 1);
//         }
//       } else {
//         _searchText += value;
//       }
//       _performSearch(_searchText);
//     });
//   }

//   void _updateChannelsForGenre(int index) {
//     if (_isSearching) {
//       setState(() {
//         _isSearching = false;
//         _searchText = '';
//         _searchResults.clear();
//       });
//     }
//     if (_selectedGenreIndex == index) {
//       return;
//     }
//     setState(() => _selectedGenreIndex = index);
//     _shuffleAndSetDisplayList();
//     _rebuildChannelNodes();
//   }

//   void _onGenreFocus(int index) {
//     if (!mounted || index >= _genres.length) return;
//     Provider.of<InternalFocusProvider>(context, listen: false)
//         .updateName(_genres[index]);

//     final buttonContext = _genreButtonKeys[index].currentContext;
//     if (buttonContext != null) {
//       Scrollable.ensureVisible(buttonContext,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//           alignment: 0.5);
//     }
//   }

//   void _onChannelFocus(int index) {
//     if (!mounted) return;
//     final currentList = _isSearching ? _searchResults : _currentDisplayList;
//     if (index < currentList.length) {
//       Provider.of<InternalFocusProvider>(context, listen: false)
//           .updateName(currentList[index].name);
//     }
//     final cardContext = _channelCardKeys[index].currentContext;
//     if (cardContext != null) {
//       Scrollable.ensureVisible(cardContext,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//           alignment: 0.5);
//     }
//   }

//   Future<void> _playChannel(NewsChannel channel) async {
//     if (_isVideoLoading) return;
//     setState(() => _isVideoLoading = true);

//     try {
//       int? userId = int.tryParse(
//           (await SharedPreferences.getInstance()).getString('user_id') ?? '');
//       if (userId != null) {
//         await HistoryService.updateUserHistory(
//             userId: userId,
//             contentType: int.tryParse(channel.contentType) ?? 4,
//             eventId: channel.id,
//             eventTitle: channel.name,
//             url: channel.url,
//             categoryId: 0);
//       }
//     } catch (e) {
//       if (kDebugMode) print("History update failed: $e");
//     }

//     try {
//       final List<NewsChannel> sourceList =
//           _isSearching ? _searchResults : _currentDisplayList;

//       List<NewsItemModel> channelsForPlayer = sourceList
//           .map((c) => NewsItemModel(
//                 id: c.id.toString(),
//                 videoId: '',
//                 name: c.name,
//                 description: '',
//                 banner: c.banner,
//                 poster: c.banner,
//                 category: c.genres,
//                 url: c.url,
//                 streamType: c.streamType,
//                 type: c.streamType,
//                 genres: c.genres,
//                 status: c.status.toString(),
//                 index: sourceList.indexOf(c).toString(),
//                 image: c.banner,
//                 unUpdatedUrl: c.url,
//                 updatedAt: '',
//               ))
//           .toList();

//       NewsItemModel currentChannel = channelsForPlayer
//           .firstWhere((item) => item.id == channel.id.toString());

//       if (!mounted) return;
//       String rawUrl = currentChannel.url;
//       // String playableUrl = await SecureUrlService.getSecureUrl(rawUrl);
//       if (rawUrl.isNotEmpty) {
//         if (currentChannel.sourceType == 'YoutubeLive' ||
//             (
//               // currentChannel.youtubeTrailer != null &&
//                 currentChannel.url.isNotEmpty)) {
//           final deviceInfo = context.read<DeviceInfoProvider>();
//           if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
//             await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => YoutubeWebviewPlayer(
//                         videoUrl: rawUrl, name: currentChannel.name)));
//           } else {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => CustomYoutubePlayer(
//                   videoData: VideoData(
//                     id: currentChannel.id.toString(),
//                     title: currentChannel.name,
//                     youtubeUrl: rawUrl,
//                     thumbnail: currentChannel.poster ?? currentChannel.banner ?? '',
//                     description: currentChannel.description ?? '',
//                   ),
//                   playlist: const [],
//                 ),
//               ),
//             );
//           }
//         } else {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => VideoScreen(
//                 videoUrl: rawUrl,
//                 bannerImageUrl: currentChannel.banner,
//                 source: 'isLive',
//                 channelList: channelsForPlayer,
//                 videoId: int.tryParse(currentChannel.id),
//                 name: currentChannel.name,
//                 liveStatus: true,
//                 updatedAt: currentChannel.updatedAt,
//               ),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Error playing channel: $e')));
//     } finally {
//       if (mounted) setState(() => _isVideoLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           if (_loadingState == LoadingState.loaded)
//             _showKeyboard
//                 ? Container(color: ProfessionalColors.primaryDark)
//                 : _buildStaticBackground(),
//           if (_loadingState == LoadingState.loading ||
//               _loadingState == LoadingState.initial)
//             const Center(child: CircularProgressIndicator())
//           else if (_error != null)
//             Center(
//                 child: Text('Error: $_error',
//                     style: const TextStyle(color: Colors.white)))
//           else
//             Column(
//               children: [
//                 SizedBox(
//                   height: screenhgt * 0.68,
//                   child: _showKeyboard
//                       ? _buildSearchUI()
//                       : const SizedBox.shrink(),
//                 ),
//                 _buildGenreButtons(),
//                 SizedBox(height: bannerhgt * 1.5, child: _buildChannelsList()),
//               ],
//             ),
//           if (_loadingState == LoadingState.loaded)
//             Positioned(
//                 top: 0, left: 0, right: 0, child: _buildBeautifulAppBar()),
//           if (_isVideoLoading)
//             Container(
//               color: Colors.black.withOpacity(0.7),
//               child: const Center(
//                   child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStaticBackground() {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         if (_sliders.isNotEmpty && _sliderPageController != null)
//           PageView.builder(
//             controller: _sliderPageController,
//             itemCount: _sliders.length,
//             onPageChanged: (index) {
//               if (mounted) {
//                 setState(() => _currentSliderPage = index);
//               }
//             },
//             itemBuilder: (context, index) {
//               final slider = _sliders[index];
//               return Image.network(
//                 slider.banner,
//                 fit: BoxFit.fill,
//                 errorBuilder: (c, e, s) =>
//                     Container(color: ProfessionalColors.primaryDark),
//               );
//             },
//           )
//         else if (_backgroundImageUrl.isNotEmpty)
//           Image.network(
//             _backgroundImageUrl,
//             fit: BoxFit.cover,
//             errorBuilder: (c, e, s) =>
//                 Container(color: ProfessionalColors.primaryDark),
//           )
//         else
//           Container(color: ProfessionalColors.primaryDark),
//         Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 ProfessionalColors.primaryDark.withOpacity(0.2),
//                 ProfessionalColors.primaryDark.withOpacity(0.4),
//                 ProfessionalColors.primaryDark.withOpacity(0.6),
//                 ProfessionalColors.primaryDark,
//               ],
//               stops: const [0.3, 0.6, 0.7, 0.9],
//             ),
//           ),
//         ),
//         if (_sliders.length > 1)
//           Positioned(
//             bottom: screenhgt * 0.35,
//             left: 0,
//             right: 0,
//             child: _buildSliderIndicator(),
//           )
//       ],
//     );
//   }

//   Widget _buildSliderIndicator() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: _sliders.asMap().entries.map((entry) {
//         int index = entry.key;
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           width: _currentSliderPage == index ? 12.0 : 8.0,
//           height: _currentSliderPage == index ? 12.0 : 8.0,
//           margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: _currentSliderPage == index
//                 ? ProfessionalColors.accentBlue
//                 : Colors.white.withOpacity(0.4),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildBeautifulAppBar() {
//     final focusedName = context.watch<InternalFocusProvider>().focusedItemName;
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               ProfessionalColors.primaryDark.withOpacity(0.8),
//               ProfessionalColors.primaryDark.withOpacity(0.5),
//               Colors.transparent
//             ]),
//       ),
//       child: Padding(
//         padding: EdgeInsets.only(
//             top: MediaQuery.of(context).padding.top + 10,
//             left: 40,
//             right: 40,
//             bottom: 10),
//         child: Row(
//           children: [
//             GradientText(widget.languageName,
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//                 gradient: const LinearGradient(colors: [
//                   ProfessionalColors.accentPink,
//                   ProfessionalColors.accentPurple,
//                 ])),
//             const SizedBox(width: 40),
//             Expanded(
//                 child: Text(focusedName,
//                     textAlign: TextAlign.left,
//                     style: const TextStyle(
//                         color: ProfessionalColors.textSecondary,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20),
//                     overflow: TextOverflow.ellipsis)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGenreButtons() {
//     return SizedBox(
//       height: 30,
//       child: ListView.builder(
//         controller: _genreScrollController,
//         scrollDirection: Axis.horizontal,
//         itemCount: _genres.length + 1,
//         padding:
//             EdgeInsets.symmetric(horizontal: screenwdt * 0.03, vertical: 1),
//         itemBuilder: (context, index) {
//           if (index == 0) {
//             return Focus(
//               focusNode: _searchButtonFocusNode,
//               onKey: (node, event) {
//                 if (event is RawKeyDownEvent &&
//                     (event.logicalKey == LogicalKeyboardKey.enter ||
//                         event.logicalKey == LogicalKeyboardKey.select)) {
//                   setState(() => _showKeyboard = true);
//                   return KeyEventResult.handled;
//                 }
//                 if (event is RawKeyDownEvent &&
//                     event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                   if (_genreFocusNodes.isNotEmpty) {
//                     _genreFocusNodes.first.requestFocus();
//                     return KeyEventResult.handled;
//                   }
//                 }
//                 return KeyEventResult.ignored;
//               },
//               child: GestureDetector(
//                 onTap: () {
//                   _searchButtonFocusNode.requestFocus();
//                   setState(() => _showKeyboard = true);
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.only(right: 15),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(30),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 1),
//                         decoration: BoxDecoration(
//                           color: _searchButtonFocusNode.hasFocus
//                               ? ProfessionalColors.accentOrange.withOpacity(0.7)
//                               : Colors.white.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(30),
//                           border: Border.all(
//                             color: _searchButtonFocusNode.hasFocus
//                                 ? Colors.white
//                                 : Colors.white.withOpacity(0.3),
//                             width: _searchButtonFocusNode.hasFocus ? 3 : 2,
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.search, color: Colors.white),
//                             SizedBox(width: 8),
//                             Text(("Search").toUpperCase(),
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16)),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }
//           final genreIndex = index - 1;
//           final genre = _genres[genreIndex];
//           final isSelected = !_isSearching && _selectedGenreIndex == genreIndex;
//           return Focus(
//             focusNode: _genreFocusNodes[genreIndex],
//             onKey: (node, event) {
//               if (event is RawKeyDownEvent) {
//                 if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
//                     genreIndex == 0) {
//                   _searchButtonFocusNode.requestFocus();
//                   return KeyEventResult.handled;
//                 }
//                 if (event.logicalKey == LogicalKeyboardKey.enter ||
//                     event.logicalKey == LogicalKeyboardKey.select) {
//                   _updateChannelsForGenre(genreIndex);
//                   return KeyEventResult.handled;
//                 }
//               }
//               return KeyEventResult.ignored;
//             },
//             child: GestureDetector(
//               onTap: () => _genreFocusNodes[genreIndex].requestFocus(),
//               child: Container(
//                 key: _genreButtonKeys[genreIndex],
//                 margin: const EdgeInsets.only(right: 15),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(30.0),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 1),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? _focusColors[genreIndex % _focusColors.length]
//                                 .withOpacity(0.6)
//                             : Colors.white.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(30),
//                         border: Border.all(
//                           color: _genreFocusNodes[genreIndex].hasFocus
//                               ? Colors.white
//                               : Colors.white.withOpacity(0.3),
//                           width: _genreFocusNodes[genreIndex].hasFocus ? 3 : 2,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(genre.toUpperCase(),
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16)),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildChannelsList() {
//     final currentList = _isSearching ? _searchResults : _currentDisplayList;

//     if (_isSearchLoading)
//       return const Center(child: CircularProgressIndicator());
//     if (currentList.isEmpty) {
//       return Center(
//         child: Text(
//             _isSearching && _searchText.isNotEmpty
//                 ? "No results found for '$_searchText'"
//                 : "No channels available for this genre.",
//             style: const TextStyle(
//                 color: ProfessionalColors.textSecondary, fontSize: 16)),
//       );
//     }
//     return Padding(
//       padding: const EdgeInsets.only(top: 10.0),
//       child: ListView.builder(
//         controller: _channelScrollController,
//         scrollDirection: Axis.horizontal,
//         itemCount: currentList.length,
//         padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.03),
//         itemBuilder: (context, index) {
//           final channel = currentList[index];
//           return Focus(
//             focusNode: _channelFocusNodes[index],
//             onKey: (node, event) {
//               if (event is RawKeyDownEvent) {
//                 final key = event.logicalKey;
//                 if (key == LogicalKeyboardKey.arrowRight ||
//                     key == LogicalKeyboardKey.arrowLeft) {
//                   if (_isNavigationLocked) return KeyEventResult.handled;

//                   setState(() => _isNavigationLocked = true);
//                   _navigationLockTimer =
//                       Timer(const Duration(milliseconds: 700), () {
//                     if (mounted) setState(() => _isNavigationLocked = false);
//                   });

//                   if (key == LogicalKeyboardKey.arrowRight) {
//                     if (index < currentList.length - 1) {
//                       _channelFocusNodes[index + 1].requestFocus();
//                     } else {
//                       _navigationLockTimer?.cancel();
//                       if (mounted) setState(() => _isNavigationLocked = false);
//                     }
//                   } else if (key == LogicalKeyboardKey.arrowLeft) {
//                     if (index > 0) {
//                       _channelFocusNodes[index - 1].requestFocus();
//                     } else {
//                       _navigationLockTimer?.cancel();
//                       if (mounted) setState(() => _isNavigationLocked = false);
//                     }
//                   }
//                   return KeyEventResult.handled;
//                 }

//                 if (key == LogicalKeyboardKey.arrowUp) {
//                   if (_genres.isNotEmpty) {
//                     _genreFocusNodes[_selectedGenreIndex].requestFocus();
//                   } else {
//                     _searchButtonFocusNode.requestFocus();
//                   }
//                   return KeyEventResult.handled;
//                 }

//                 if (key == LogicalKeyboardKey.select ||
//                     key == LogicalKeyboardKey.enter) {
//                   _playChannel(channel);
//                   return KeyEventResult.handled;
//                 }
//               }
//               return KeyEventResult.ignored;
//             },
//             child: ChannelCard(
//                 key: _channelCardKeys[index],
//                 channel: channel,
//                 focusNode: _channelFocusNodes[index],
//                 focusColors: _focusColors,
//                 uniqueIndex: index,
//                 onTap: () => _playChannel(channel)),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSearchUI() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           flex: 4,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const GradientText("Search for Channels",
//                     style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                     gradient: LinearGradient(colors: [
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple
//                     ])),
//                 const SizedBox(height: 24),
//                 Container(
//                   width: double.infinity,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                         color: ProfessionalColors.accentPurple, width: 2),
//                   ),
//                   child: Text(
//                     _searchText.isEmpty ? 'Start typing...' : _searchText,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color:
//                           _searchText.isEmpty ? Colors.white54 : Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Expanded(flex: 6, child: _buildQwertyKeyboard()),
//       ],
//     );
//   }

//   Widget _buildQwertyKeyboard() {
//     final row1 = "1234567890".split('');
//     final row2 = "QWERTYUIOP".split('');
//     final row3 = "ASDFGHJKL".split('');
//     final row4 = "ZXCVBNM,.".split('');
//     final row5 = ["DEL", " ", "OK"];

//     return Container(
//       color: Colors.transparent,
//       padding: const EdgeInsets.all(10),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildKeyboardRow(row1),
//           _buildKeyboardRow(row2),
//           _buildKeyboardRow(row3),
//           _buildKeyboardRow(row4),
//           _buildKeyboardRow(row5),
//         ],
//       ),
//     );
//   }

//   Widget _buildKeyboardRow(List<String> keys) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: keys.map((key) {
//         return Expanded(
//           flex: (key == ' ' || key == 'OK' || key == 'DEL') ? 2 : 1,
//           child: Container(
//             margin: const EdgeInsets.all(4),
//             child: ElevatedButton(
//               onPressed: () => _onKeyPressed(key),
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white.withOpacity(0.1),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   padding: const EdgeInsets.symmetric(vertical: 12)),
//               child: Text(key,
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold)),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

// // ==========================================================
// // REUSABLE WIDGETS
// // ==========================================================

// class ChannelCard extends StatefulWidget {
//   final NewsChannel channel;
//   final FocusNode focusNode;
//   final List<Color> focusColors;
//   final int uniqueIndex;
//   final VoidCallback onTap;

//   const ChannelCard(
//       {super.key,
//       required this.channel,
//       required this.focusNode,
//       required this.focusColors,
//       required this.uniqueIndex,
//       required this.onTap});

//   @override
//   State<ChannelCard> createState() => _ChannelCardState();
// }

// class _ChannelCardState extends State<ChannelCard> {
//   bool _hasFocus = false;

//   @override
//   void initState() {
//     super.initState();
//     widget.focusNode.addListener(_onFocusChange);
//   }

//   @override
//   void dispose() {
//     widget.focusNode.removeListener(_onFocusChange);
//     super.dispose();
//   }

//   void _onFocusChange() {
//     if (mounted && widget.focusNode.hasFocus != _hasFocus) {
//       setState(() => _hasFocus = widget.focusNode.hasFocus);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final focusColor =
//         widget.focusColors[widget.uniqueIndex % widget.focusColors.length];

//     return Container(
//       width: bannerwdt,
//       margin: const EdgeInsets.only(right: 12.0),
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Expanded(
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8.0),
//                   border: _hasFocus
//                       ? Border.all(color: focusColor, width: 3)
//                       : Border.all(color: Colors.transparent, width: 3),
//                   boxShadow: _hasFocus
//                       ? [
//                           BoxShadow(
//                               color: focusColor.withOpacity(0.5),
//                               blurRadius: 12,
//                               spreadRadius: 1)
//                         ]
//                       : [],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(6.0),
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       Image.network(widget.channel.banner,
//                           fit: BoxFit.cover,
//                           errorBuilder: (c, e, s) => Container(
//                               color: ProfessionalColors.cardDark,
//                               child: Center(
//                                   child:
//                                       Icon(Icons.tv, color: Colors.white54))),
//                           loadingBuilder: (c, child, progress) => progress ==
//                                   null
//                               ? child
//                               : Container(color: ProfessionalColors.cardDark)),
//                       if (_hasFocus)
//                         Container(
//                             color: Colors.black.withOpacity(0.4),
//                             child: Icon(Icons.play_arrow_rounded,
//                                 color: Colors.white, size: 40)),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//                 padding: const EdgeInsets.only(top: 4.0, left: 2.0, right: 2.0),
//                 child: Text(widget.channel.name,
//                     style: TextStyle(
//                         color: _hasFocus
//                             ? focusColor
//                             : ProfessionalColors.textSecondary,
//                         fontSize: 14),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class GradientText extends StatelessWidget {
//   const GradientText(this.text,
//       {super.key, required this.gradient, this.style});
//   final String text;
//   final TextStyle? style;
//   final Gradient gradient;

//   @override
//   Widget build(BuildContext context) {
//     return ShaderMask(
//       blendMode: BlendMode.srcIn,
//       shaderCallback: (bounds) => gradient
//           .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
//       child: Text(text, style: style),
//     );
//   }
// }





import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

// Import your project specific files
// Update these imports based on your folder structure
import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
import 'package:mobi_tv_entertainment/components/video_widget/secure_url_service.dart';
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/components/video_widget/youtube_webview_player.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';

// ==========================================================
// CONSTANTS & THEME
// ==========================================================

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
  static const accentTeal = Color(0xFF06B6D4);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
}

class AnimationTiming {
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
}

// ==========================================================
// DATA MODELS
// ==========================================================

class SliderItem {
  final int id;
  final String title;
  final String banner;

  SliderItem({required this.id, required this.title, required this.banner});

  factory SliderItem.fromJson(Map<String, dynamic> json) {
    return SliderItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled',
      banner: json['banner'] ?? '',
    );
  }
}

// class NewsChannel {
//   final int id;
//   final String name;
//   final String banner;
//   final String url;
//   final String genres;
//   final int status;
//   final String streamType;
//   final String contentType;
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
//       contentType: json['content_type']?.toString() ?? '',
//       sourceType: json['source_type'] ?? '',
//       updatedAt: json['updated_at'],
//     );
//   }
// }


class NewsChannel {
  final int id;
  final String name;
  final String banner;
  final String url;
  final String genres;
  final int status;
  final String streamType;
  final String contentType; // String expected
  final String sourceType;
  final String? updatedAt;

  NewsChannel({
    required this.id,
    required this.name,
    required this.banner,
    required this.url,
    required this.genres,
    required this.status,
    required this.streamType,
    required this.contentType,
    this.sourceType = '',
    this.updatedAt,
  });

  factory NewsChannel.fromJson(Map<String, dynamic> json) {
    return NewsChannel(
      id: json['id'] ?? 0,
      name: json['channel_name'] ?? 'Untitled Channel',
      banner: json['channel_logo'] ?? '',
      url: json['channel_link'] ?? '',
      genres: json['genres'] ?? 'General',
      status: json['status'] ?? 0,
      streamType: json['stream_type'] ?? 'M3u8',
      
      // 🔥 FIX: Add .toString() here
      // यह लाइन नंबर (int) को सेफली स्ट्रिंग में बदल देगी
      contentType: json['content_type']?.toString() ?? '', 
      
      sourceType: json['source_type'] ?? '',
      updatedAt: json['updated_at'],
    );
  }
}

// ==========================================================
// MAIN SCREEN
// ==========================================================

class LanguageChannelsScreen extends StatefulWidget {
  final String languageId;
  final String languageName;

  const LanguageChannelsScreen({
    super.key,
    required this.languageId,
    required this.languageName,
  });

  @override
  State<LanguageChannelsScreen> createState() => _LanguageChannelsScreenState();
}

class _LanguageChannelsScreenState extends State<LanguageChannelsScreen> with SingleTickerProviderStateMixin {
  // --- Data State ---
  List<NewsChannel> _allChannels = [];
  Map<String, List<NewsChannel>> _channelsByGenre = {};
  List<NewsChannel> _currentDisplayList = [];
  List<String> _genres = [];
  List<SliderItem> _sliders = [];

  // --- UI State Flags ---
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isVideoLoading = false;
  bool _isGenreSwitching = false;
  bool _isProcessing = false;
  bool _isDisposed = false;
  String? _error;

  // --- Focus Management ---
  int _focusedGenreIndex = 0;
  int _focusedChannelIndex = -1;
  String _selectedGenre = '';
  
  final FocusNode _widgetFocusNode = FocusNode();
  late FocusNode _searchButtonFocusNode;
  
  List<FocusNode> _genreFocusNodes = [];
  List<FocusNode> _channelFocusNodes = [];
  List<FocusNode> _keyboardFocusNodes = [];

  // --- Scroll Controllers ---
  final ScrollController _genreScrollController = ScrollController();
  final ScrollController _channelScrollController = ScrollController();

  // --- Slider Management ---
  late PageController _sliderPageController;
  int _currentSliderPage = 0;
  Timer? _sliderTimer;

  // --- Search System ---
  bool _showKeyboard = false;
  String _searchText = '';
  List<NewsChannel> _searchResults = [];
  int _focusedKeyRow = 0;
  int _focusedKeyCol = 0;
  final List<List<String>> _keyboardLayout = [
    "1234567890".split(''),
    "qwertyuiop".split(''),
    "asdfghjkl".split(''),
    ["z", "x", "c", "v", "b", "n", "m", "DEL"],
    ["SPACE", "OK"],
  ];

  // --- Animation ---
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // --- Colors ---
  final List<Color> _focusColors = [
    ProfessionalColors.accentBlue,
    ProfessionalColors.accentPurple,
    ProfessionalColors.accentGreen,
    ProfessionalColors.accentOrange,
    ProfessionalColors.accentPink,
    ProfessionalColors.accentRed,
    ProfessionalColors.accentTeal,
  ];

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    SecureUrlService.refreshSettings();
    _sliderPageController = PageController();
    _searchButtonFocusNode = FocusNode();
    _initializeAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        Provider.of<InternalFocusProvider>(context, listen: false).updateName('');
        _fetchAndProcessData();
      }
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AnimationTiming.medium,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _sliderTimer?.cancel();
    _genreChangeDebounce?.cancel();
    _sliderPageController.dispose();
    _fadeController.dispose();
    _genreScrollController.dispose();
    _channelScrollController.dispose();
    _widgetFocusNode.dispose();
    _searchButtonFocusNode.dispose();
    _disposeAllFocusNodes();
    super.dispose();
  }

  void _disposeAllFocusNodes() {
    FocusManager.instance.primaryFocus?.unfocus();
    for (var node in _genreFocusNodes) {
      try { node.dispose(); } catch (_) {}
    }
    _genreFocusNodes.clear();

    for (var node in _channelFocusNodes) {
      try { node.dispose(); } catch (_) {}
    }
    _channelFocusNodes.clear();

    for (var node in _keyboardFocusNodes) {
      try { node.dispose(); } catch (_) {}
    }
    _keyboardFocusNodes.clear();
  }

  // ==========================================================
  // DATA FETCHING (UPDATED FIX)
  // ==========================================================

  // Future<void> _fetchAndProcessData() async {
  //   if (_isDisposed) return;

  //   try {
  //     final headers = {
  //       'auth-key': SessionManager.authKey,
  //       'domain': SessionManager.savedDomain,
  //       'Content-Type': 'application/json'
  //     };

  //     final results = await Future.wait([
  //       https.get(Uri.parse(SessionManager.baseUrl + 'getAllLanguages'), headers: headers),
  //       https.post(
  //         Uri.parse(SessionManager.baseUrl + 'getAllLiveTV'),
  //         headers: headers,
  //         body: json.encode({
  //           "genere": "",
  //           "languageId": widget.languageId
  //         })
  //       ),
  //       https.post(
  //          Uri.parse(SessionManager.baseUrl + 'getGenreByContentNetwork'), 
  //          headers: headers,
  //          body: json.encode({"language_id": widget.languageId})
  //       ),
  //     ]);

  //     if (_isDisposed) return;

  //     // --- 1. Process Sliders (Languages) ---
  //     List<SliderItem> tempSliders = [];
  //     if (results[0].statusCode == 200) {
  //       final langData = json.decode(results[0].body);
  //       if (langData['languages'] is List) {
  //         // Safe Comparison Fix
  //         final currentLang = (langData['languages'] as List).firstWhere(
  //           (l) => l['id'].toString().trim() == widget.languageId.toString().trim(),
  //           orElse: () => null
  //         );
  //         if (currentLang != null && currentLang['slider'] is List) {
  //            tempSliders = (currentLang['slider'] as List)
  //                .map((i) => SliderItem.fromJson(i))
  //                .toList();
  //         }
  //       }
  //     }

  //     // --- 2. Process Channels & Genres ---
  //     if (results[1].statusCode == 200) {
  //       final List<dynamic> channelsData = json.decode(results[1].body);
  //       _allChannels = channelsData
  //           .map((item) => NewsChannel.fromJson(item))
  //           .where((c) => c.status == 1)
  //           .toList();

  //       final genreRes = results[2];
  //       List<String> apiGenres = [];
  //       if (genreRes.statusCode == 200) {
  //          final gData = json.decode(genreRes.body);
  //          if (gData['genres'] != null) {
  //            apiGenres = List<String>.from(gData['genres']);
  //          }
  //       }

  //       if (apiGenres.isEmpty) {
  //         final Set<String> extracted = {};
  //         for (var c in _allChannels) {
  //           c.genres.split(',').forEach((g) => extracted.add(g.trim()));
  //         }
  //         extracted.removeWhere((e) => e.isEmpty);
  //         apiGenres = extracted.toList()..sort();
  //       }

  //       Map<String, List<NewsChannel>> mapTemp = {};
  //       for (var g in apiGenres) {
  //         mapTemp[g] = _allChannels.where((c) => c.genres.contains(g)).toList();
  //       }
        
  //       apiGenres.removeWhere((g) => (mapTemp[g] ?? []).isEmpty);
  //       _genres = apiGenres;
  //       _channelsByGenre = mapTemp;

  //       if (!_isDisposed && mounted) {
  //          setState(() {
  //            _sliders = tempSliders; // Update Sliders
  //            if (_genres.isNotEmpty) {
  //              _selectedGenre = _genres[0];
  //              _currentDisplayList = _channelsByGenre[_selectedGenre] ?? [];
  //            } else {
  //              _currentDisplayList = _allChannels;
  //            }
  //            _isLoading = false;
  //          });

  //          _rebuildNodes();
  //          _setupSliderTimer();
  //          _fadeController.forward();

  //          Future.delayed(const Duration(milliseconds: 300), () {
  //            if (!_isDisposed && mounted && _searchButtonFocusNode.canRequestFocus) {
  //              _searchButtonFocusNode.requestFocus();
  //            }
  //          });
  //       }
  //     } else {
  //       throw Exception("API Error");
  //     }
  //   } catch (e) {
  //     if (!_isDisposed && mounted) {
  //       setState(() {
  //         _isLoading = false;
  //         _error = e.toString();
  //       });
  //     }
  //   }
  // }




  Future<void> _fetchAndProcessData() async {
    if (_isDisposed) return;

    try {
      final headers = {
        'auth-key': SessionManager.authKey,
        'domain': SessionManager.savedDomain,
        'Content-Type': 'application/json'
      };

      final results = await Future.wait([
        https.get(Uri.parse(SessionManager.baseUrl + 'getAllLanguages'), headers: headers),
        https.post(
          Uri.parse(SessionManager.baseUrl + 'getAllLiveTV'),
          headers: headers,
          body: json.encode({
            "genere": "",
            "languageId": widget.languageId
          })
        ),
        https.post(
            Uri.parse(SessionManager.baseUrl + 'getGenreByContentNetwork'), 
            headers: headers,
            body: json.encode({"language_id": widget.languageId})
        ),
      ]);

      if (_isDisposed) return;

      // --- 1. Process Sliders (Languages) ---
      List<SliderItem> tempSliders = [];
      if (results[0].statusCode == 200) {
        final langData = json.decode(results[0].body);
        if (langData['languages'] is List) {
          final currentLang = (langData['languages'] as List).firstWhere(
            (l) => l['id'].toString().trim() == widget.languageId.toString().trim(),
            orElse: () => null
          );
          if (currentLang != null && currentLang['slider'] is List) {
             tempSliders = (currentLang['slider'] as List)
                 .map((i) => SliderItem.fromJson(i))
                 .toList();
          }
        }
      }

      // --- 2. Process Channels & Genres ---
      if (results[1].statusCode == 200) {
        final List<dynamic> channelsData = json.decode(results[1].body);
        _allChannels = channelsData
            .map((item) => NewsChannel.fromJson(item))
            .where((c) => c.status == 1)
            .toList();

        // 🔥 FALLBACK LOGIC ADDED HERE 🔥
        // Agar API se Slider nahi mila, to pehle channel ka banner use karein
        if (tempSliders.isEmpty && _allChannels.isNotEmpty) {
           tempSliders.add(SliderItem(
             id: 0, 
             title: _allChannels.first.name, 
             banner: _allChannels.first.banner
           ));
        }

        final genreRes = results[2];
        List<String> apiGenres = [];
        if (genreRes.statusCode == 200) {
           final gData = json.decode(genreRes.body);
           if (gData['genres'] != null) {
             apiGenres = List<String>.from(gData['genres']);
           }
        }

        if (apiGenres.isEmpty) {
          final Set<String> extracted = {};
          for (var c in _allChannels) {
            c.genres.split(',').forEach((g) => extracted.add(g.trim()));
          }
          extracted.removeWhere((e) => e.isEmpty);
          apiGenres = extracted.toList()..sort();
        }

        Map<String, List<NewsChannel>> mapTemp = {};
        for (var g in apiGenres) {
          mapTemp[g] = _allChannels.where((c) => c.genres.contains(g)).toList();
        }
        
        apiGenres.removeWhere((g) => (mapTemp[g] ?? []).isEmpty);
        _genres = apiGenres;
        _channelsByGenre = mapTemp;

        if (!_isDisposed && mounted) {
           setState(() {
             _sliders = tempSliders; // Ab isme fallback image bhi hogi
             if (_genres.isNotEmpty) {
               _selectedGenre = _genres[0];
               _currentDisplayList = _channelsByGenre[_selectedGenre] ?? [];
             } else {
               _currentDisplayList = _allChannels;
             }
             _isLoading = false;
           });

           _rebuildNodes();
           _setupSliderTimer();
           _fadeController.forward();

           Future.delayed(const Duration(milliseconds: 300), () {
             if (!_isDisposed && mounted && _searchButtonFocusNode.canRequestFocus) {
               _searchButtonFocusNode.requestFocus();
             }
           });
        }
      } else {
        throw Exception("API Error");
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  // ==========================================================
  // NODE & TIMER MANAGEMENT
  // ==========================================================

  void _rebuildNodes() {
    if (_isDisposed) return;
    _disposeAllFocusNodes();

    _genreFocusNodes = List.generate(_genres.length, (_) => FocusNode());

    final list = _isSearching ? _searchResults : _currentDisplayList;
    _channelFocusNodes = List.generate(list.length, (_) => FocusNode());

    int totalKeys = _keyboardLayout.fold(0, (p, r) => p + r.length);
    _keyboardFocusNodes = List.generate(totalKeys, (_) => FocusNode());
  }

  void _rebuildChannelNodes() {
    if (_isDisposed) return;
    for (var node in _channelFocusNodes) {
      try { node.dispose(); } catch (_) {}
    }
    _channelFocusNodes.clear();

    final list = _isSearching ? _searchResults : _currentDisplayList;
    _channelFocusNodes = List.generate(list.length, (_) => FocusNode());
  }

  void _setupSliderTimer() {
    _sliderTimer?.cancel();
    if (_sliders.length > 1) {
      _sliderTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
        if (_isDisposed || !_sliderPageController.hasClients) {
          timer.cancel();
          return;
        }
        int next = (_sliderPageController.page?.round() ?? 0) + 1;
        if (next >= _sliders.length) next = 0;
        _sliderPageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut
        );
      });
    }
  }

  // ==========================================================
  // SCROLLING HELPERS
  // ==========================================================

  void _scrollGenreToFocus(int index) {
    if (_isDisposed || !_genreScrollController.hasClients) return;
    try {
      double screenW = MediaQuery.of(context).size.width;
      double itemW = 120.0; 
      double offset = (index * itemW) - (screenW / 2) + (itemW / 2);
      if (offset < 0) offset = 0;
      if (offset > _genreScrollController.position.maxScrollExtent) {
        offset = _genreScrollController.position.maxScrollExtent;
      }
      _genreScrollController.animateTo(
        offset, duration: AnimationTiming.fast, curve: Curves.easeOutCubic
      );
    } catch (_) {}
  }

  void _scrollChannelToFocus(int index) {
    if (_isDisposed || !_channelScrollController.hasClients) return;
    try {
      double screenW = MediaQuery.of(context).size.width;
      double itemW = bannerwdt + 15.0; 
      double offset = (index * itemW) - (screenW / 2) + (itemW / 2);
      if (offset < 0) offset = 0;
      if (offset > _channelScrollController.position.maxScrollExtent) {
        offset = _channelScrollController.position.maxScrollExtent;
      }
      _channelScrollController.animateTo(
        offset, duration: AnimationTiming.fast, curve: Curves.easeOutCubic
      );
    } catch (_) {}
  }

  // ==========================================================
  // KEYBOARD NAVIGATION HANDLER
  // ==========================================================

  KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
    if (_isDisposed) return KeyEventResult.handled;
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
    if (_isProcessing || _isGenreSwitching) return KeyEventResult.handled;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape) {
      if (_showKeyboard) {
        setState(() => _showKeyboard = false);
        _searchButtonFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored; 
    }

    if (_showKeyboard) return _navigateVirtualKeyboard(key);
    if (_searchButtonFocusNode.hasFocus) return _navigateSearchBtn(key);
    if (_genreFocusNodes.any((n) => n.hasFocus)) return _navigateGenres(key);
    if (_channelFocusNodes.any((n) => n.hasFocus)) return _navigateChannels(key);

    return KeyEventResult.ignored;
  }

  KeyEventResult _navigateSearchBtn(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      setState(() => _showKeyboard = true);
      if (_keyboardFocusNodes.isNotEmpty) _keyboardFocusNodes[0].requestFocus();
    } else if (key == LogicalKeyboardKey.arrowRight && _genreFocusNodes.isNotEmpty) {
      _genreFocusNodes[0].requestFocus();
    } else if (key == LogicalKeyboardKey.arrowDown && _channelFocusNodes.isNotEmpty) {
      _focusChannelAtIndex(0);
    }
    return KeyEventResult.handled;
  }

  KeyEventResult _navigateGenres(LogicalKeyboardKey key) {
    if (_genres.isEmpty) return KeyEventResult.handled;
    
    int i = _focusedGenreIndex;
    if (i < 0) i = 0;

    if (key == LogicalKeyboardKey.arrowLeft) {
      if (i > 0) {
        i--;
      } else {
        _searchButtonFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.arrowRight && i < _genres.length - 1) {
      i++;
    } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _changeGenre(i);
      return KeyEventResult.handled;
    }

    if (i != _focusedGenreIndex) {
      setState(() => _focusedGenreIndex = i);
      _genreFocusNodes[i].requestFocus();
      _scrollGenreToFocus(i);
    }
    return KeyEventResult.handled;
  }

  KeyEventResult _navigateChannels(LogicalKeyboardKey key) {
    final list = _isSearching ? _searchResults : _currentDisplayList;
    if (list.isEmpty) return KeyEventResult.handled;

    int i = _focusedChannelIndex;
    if (i < 0) i = 0;
    if (i >= list.length) i = list.length - 1;

    if (key == LogicalKeyboardKey.arrowUp) {
      setState(() => _focusedChannelIndex = -1);
      if (_focusedGenreIndex >= 0 && _focusedGenreIndex < _genres.length) {
        _genreFocusNodes[_focusedGenreIndex].requestFocus();
      } else {
        _searchButtonFocusNode.requestFocus();
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowLeft && i > 0) i--;
    else if (key == LogicalKeyboardKey.arrowRight && i < list.length - 1) i++;
    else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _playChannel(list[i]);
      return KeyEventResult.handled;
    }

    if (i != _focusedChannelIndex) {
      _focusChannelAtIndex(i);
    }
    return KeyEventResult.handled;
  }

  void _focusChannelAtIndex(int index) {
    if (_isDisposed || _channelFocusNodes.isEmpty) return;
    final list = _isSearching ? _searchResults : _currentDisplayList;
    if (index >= list.length) return;

    setState(() => _focusedChannelIndex = index);
    
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_isDisposed && mounted && index < _channelFocusNodes.length) {
        _channelFocusNodes[index].requestFocus();
        _scrollChannelToFocus(index);
      }
    });
  }

  // ==========================================================
  // GENRE SWITCHING
  // ==========================================================
  
  Timer? _genreChangeDebounce;

  void _changeGenre(int index) {
    if (_isDisposed || _isGenreSwitching || _isProcessing) return;
    if (index < 0 || index >= _genres.length) return;

    _genreChangeDebounce?.cancel();
    _genreChangeDebounce = Timer(const Duration(milliseconds: 50), () {
      if (!_isDisposed && mounted) _executeGenreChange(index);
    });
  }

  void _executeGenreChange(int index) {
    if (_isDisposed) return;
    _isGenreSwitching = true;

    final newGenre = _genres[index];
    final newList = _channelsByGenre[newGenre] ?? [];

    setState(() {
      _focusedGenreIndex = index;
      _selectedGenre = newGenre;
      _isSearching = false;
      _searchResults = [];
      _searchText = '';
      _focusedChannelIndex = -1;
      _currentDisplayList = newList;
    });

    Future.microtask(() {
      if (_isDisposed) return;
      _rebuildChannelNodes();
      
      if (_channelScrollController.hasClients) {
        _channelScrollController.jumpTo(0);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted && _channelFocusNodes.isNotEmpty) {
           setState(() => _focusedChannelIndex = 0);
           Future.delayed(const Duration(milliseconds: 100), () {
             if (!_isDisposed && mounted && _channelFocusNodes.isNotEmpty) {
               _channelFocusNodes[0].requestFocus();
             }
             _isGenreSwitching = false;
           });
        } else {
          _isGenreSwitching = false;
        }
      });
    });
  }

  // ==========================================================
  // VIRTUAL KEYBOARD LOGIC
  // ==========================================================

  KeyEventResult _navigateVirtualKeyboard(LogicalKeyboardKey key) {
    int r = _focusedKeyRow;
    int c = _focusedKeyCol;

    if (key == LogicalKeyboardKey.arrowUp && r > 0) {
      r--;
    } else if (key == LogicalKeyboardKey.arrowDown && r < _keyboardLayout.length - 1) {
      r++;
      c = math.min(c, _keyboardLayout[r].length - 1);
    } else if (key == LogicalKeyboardKey.arrowLeft && c > 0) {
      c--;
    } else if (key == LogicalKeyboardKey.arrowRight && c < _keyboardLayout[r].length - 1) {
      c++;
    } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _onKeyClick(_keyboardLayout[r][c]);
      return KeyEventResult.handled;
    }

    if (r != _focusedKeyRow || c != _focusedKeyCol) {
      setState(() {
        _focusedKeyRow = r;
        _focusedKeyCol = c;
      });
      int idx = 0;
      for (int i = 0; i < r; i++) idx += _keyboardLayout[i].length;
      idx += c;
      if (idx < _keyboardFocusNodes.length) {
        _keyboardFocusNodes[idx].requestFocus();
      }
    }
    return KeyEventResult.handled;
  }

  void _onKeyClick(String val) {
    if (_isDisposed) return;
    setState(() {
      if (val == "OK") {
        _showKeyboard = false;
        _searchButtonFocusNode.requestFocus();
      } else if (val == "DEL") {
        if (_searchText.isNotEmpty) _searchText = _searchText.substring(0, _searchText.length - 1);
      } else if (val == "SPACE") {
        _searchText += " ";
      } else {
        _searchText += val;
      }
      _performSearch(_searchText);
    });
  }

  void _performSearch(String t) {
    if (_isDisposed) return;
    setState(() {
      if (t.isEmpty) {
        _isSearching = false;
        _searchResults = [];
      } else {
        _isSearching = true;
        _searchResults = _allChannels.where((c) => c.name.toUpperCase().contains(t.toUpperCase())).toList();
      }
      _rebuildChannelNodes();
    });
  }

  // // ==========================================================
  // // PLAY VIDEO LOGIC
  // // ==========================================================

  // Future<void> _playChannel(NewsChannel channel) async {
  //   if (_isDisposed || _isProcessing || _isVideoLoading) return;

  //   setState(() {
  //     _isProcessing = true;
  //     _isVideoLoading = true;
  //   });

  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     int? userId = int.tryParse(prefs.getString('user_id') ?? '');
  //     if (userId != null) {
  //       HistoryService.updateUserHistory(
  //         userId: userId,
  //         contentType: int.tryParse(channel.contentType) ?? 4,
  //         eventId: channel.id,
  //         eventTitle: channel.name,
  //         url: channel.url,
  //         categoryId: 0
  //       ).catchError((e) => print("History Error: $e"));
  //     }

  //     String playableUrl = channel.url; 
  //     if (playableUrl.isEmpty) throw Exception("Empty URL");

  //     final deviceInfo = context.read<DeviceInfoProvider>();
      
  //     if (channel.streamType == 'YoutubeLive' || (channel.url.contains('youtube') || channel.url.contains('youtu.be'))) {
  //        if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {


  //           await Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (c) => YoutubeWebviewPlayer(videoUrl: playableUrl, name: channel.name))
  //           );
  //       print("YoutubeWebviewPlayer: $playableUrl");

  //        } else {

  //           await Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (c) => CustomYoutubePlayer(
  //               videoData: VideoData(
  //                 id: channel.id.toString(),
  //                 title: channel.name,
  //                 youtubeUrl: playableUrl,
  //                 thumbnail: channel.banner,
  //                 description: ''
  //               ),
  //               playlist: const []
  //             ))
  //           );
  //       print("CustomYoutubePlayer: $playableUrl");

  //        }
  //     } else {

  //       final list = _isSearching ? _searchResults : _currentDisplayList;
  //       List<NewsItemModel> playerList = list.map((c) => NewsItemModel(
  //         id: c.id.toString(),
  //         name: c.name,
  //         banner: c.banner,
  //         url: c.url,
  //         streamType: c.streamType,
  //         status: c.status.toString(),
  //         genres: c.genres,
  //         videoId: '', description: '', poster: c.banner, category: c.genres, 
  //         type: c.streamType, index: '0', image: c.banner, unUpdatedUrl: c.url, updatedAt: ''
  //       )).toList();

  //       await Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (c) => VideoScreen(
  //           videoUrl: playableUrl,
  //           bannerImageUrl: channel.banner,
  //           source: 'isLive',
  //           channelList: playerList,
  //           videoId: channel.id,
  //           name: channel.name,
  //           liveStatus: true,
  //           updatedAt: channel.updatedAt ?? '',
  //         ))
  //       );
  //       print("vlc_playing: $playableUrl");

  //     }

  //   } catch (e) {
  //     if (!_isDisposed && mounted) {
  //       print("Playbackerror: $e");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Playback Error: ${e.toString()}'), backgroundColor: Colors.red,)
  //       );
  //     }
  //   } finally {
  //     if (!_isDisposed && mounted) {
  //       setState(() {
  //         _isProcessing = false;
  //         _isVideoLoading = false;
  //       });
  //     }
  //   }
  // }



  Future<void> _playChannel(NewsChannel channel) async {
    if (_isDisposed || _isProcessing || _isVideoLoading) return;

    setState(() {
      _isProcessing = true;
      _isVideoLoading = true;
    });

    try {
      // --- 1. History Service (Surrounded by Try-Catch so it doesn't stop playback) ---
      try {
        final prefs = await SharedPreferences.getInstance();
        String userIdStr = prefs.getString('user_id') ?? '';
        int? userId = int.tryParse(userIdStr);
        
        if (userId != null) {
          // 🔥 FIX: Ensure all parameters match what HistoryService expects
          // If HistoryService expects Strings, we convert them. 
          // If it expects ints, int.tryParse handles it.
          await HistoryService.updateUserHistory(
            userId: userId,
            // 🔥 Possible Error Source: Converting to String just in case
            contentType: int.tryParse(channel.contentType) ?? 4, 
            eventId: channel.id, 
            eventTitle: channel.name,
            url: channel.url,
            categoryId: 0
          );
        }
      } catch (historyError) {
        print("History Update Failed (Non-fatal): $historyError");
      }

      // --- 2. Playback Logic ---
      String playableUrl = channel.url; 
      if (playableUrl.isEmpty) throw Exception("Empty URL");

      final deviceInfo = context.read<DeviceInfoProvider>();
      
      // Check for Youtube
      if (channel.streamType == 'YoutubeLive' || (channel.url.contains('youtube') || channel.url.contains('youtu.be'))) {
         if (deviceInfo.deviceName == 'AFTSS : Amazon Fire Stick HD') {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => YoutubeWebviewPlayer(videoUrl: playableUrl, name: channel.name))
            );
         } else {
            // Raw Youtube ID check
            String videoId = playableUrl;
            // If it's a full URL, extract ID (Basic check)
            if (playableUrl.contains('v=')) {
               videoId = playableUrl.split('v=')[1].split('&')[0];
            } else if (playableUrl.contains('youtu.be/')) {
               videoId = playableUrl.split('youtu.be/')[1].split('?')[0];
            }

            await Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => CustomYoutubePlayer(
                videoData: VideoData(
                  id: videoId,
                  title: channel.name,
                  youtubeUrl: playableUrl,
                  thumbnail: channel.banner,
                  description: ''
                ),
                playlist: const []
              ))
            );
         }
      } else {
        // --- 3. M3U8 / Other Player ---
        final list = _isSearching ? _searchResults : _currentDisplayList;
        
        // 🔥 FIX: Converting everything to String explicitly to prevent Type Cast Errors
        List<NewsItemModel> playerList = list.map((c) => NewsItemModel(
          id: c.id.toString(),
          name: c.name,
          banner: c.banner,
          url: c.url,
          streamType: c.streamType,
          status: c.status.toString(),
          genres: c.genres,
          videoId: '', 
          description: '', 
          poster: c.banner, 
          category: c.genres, 
          type: c.streamType, 
          index: '0', 
          image: c.banner, 
          unUpdatedUrl: c.url, 
          updatedAt: ''
        )).toList();

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => VideoScreen(
            videoUrl: playableUrl,
            bannerImageUrl: channel.banner,
            source: 'isLive',
            channelList: playerList,
            videoId: channel.id,
            name: channel.name,
            liveStatus: true,
            updatedAt: channel.updatedAt ?? '',
          ))
        );
      }

    } catch (e) {
      if (!_isDisposed && mounted) {
        print("Playback Error Details: $e"); // Check console for exact line
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playback Error: ${e.toString()}'), backgroundColor: Colors.red,)
        );
      }
    } finally {
      if (!_isDisposed && mounted) {
        setState(() {
          _isProcessing = false;
          _isVideoLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // BUILD UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Focus(
        focusNode: _widgetFocusNode,
        autofocus: true,
        onKey: _onKeyHandler,
        child: Stack(
          fit: StackFit.expand, // 🔥 CRITICAL FIX
          children: [
            _buildBackgroundSlider(),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.white))
            else if (_error != null)
              Center(child: Text("Error: $_error", style: const TextStyle(color: Colors.white)))
            else
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).padding.top + 60,
                      child: _buildBeautifulAppBar(),
                    ),
                    const Spacer(),
                    if (_showKeyboard) _buildSearchUI(),
                    _buildSliderIndicators(),
                    const SizedBox(height: 10),
                    _buildGenreBarWithGlassEffect(),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: bannerhgt + 50,
                      child: _buildChannelsList(),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            
            if (_isVideoLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundSlider() {
    return RepaintBoundary(
      child: SizedBox.expand( // 🔥 CRITICAL FIX
        child: Stack(
          fit: StackFit.expand, // 🔥 CRITICAL FIX
          children: [
            if (_sliders.isNotEmpty)
              PageView.builder(
                controller: _sliderPageController,
                itemCount: _sliders.length,
                onPageChanged: (i) {
                  if (!_isDisposed && mounted) setState(() => _currentSliderPage = i);
                },
                itemBuilder: (c, i) => Image.network(
                  _sliders[i].banner,
                  fit: BoxFit.cover,
                  errorBuilder: (c,e,s) => Container(color: Colors.black),
                ),
              )
            else 
              Container(color: ProfessionalColors.primaryDark),
            
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      ProfessionalColors.primaryDark.withOpacity(0.7),
                      ProfessionalColors.primaryDark
                    ],
                    stops: const [0.3, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeautifulAppBar() {
    final focusName = context.watch<InternalFocusProvider>().focusedItemName;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.5), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GradientText(
            widget.languageName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            gradient: const LinearGradient(
              colors: [
                ProfessionalColors.accentPink,
                ProfessionalColors.accentPurple,
                ProfessionalColors.accentBlue,
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              focusName,
              style: const TextStyle(
                color: ProfessionalColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreBarWithGlassEffect() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        controller: _genreScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _genres.length + 1,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        itemBuilder: (context, index) {
          if (index == 0) {
             return _buildGlassEffectButton(
               focusNode: _searchButtonFocusNode,
               label: "SEARCH",
               icon: Icons.search,
               isSelected: _isSearching,
               focusColor: ProfessionalColors.accentOrange,
               marginLeft: 0,
               marginRight: 12,
               onFocusChange: (hasFocus) {
                 if (hasFocus && !_isDisposed && mounted) {
                   Provider.of<InternalFocusProvider>(context, listen: false).updateName("Search");
                 }
               },
               onTap: () {
                 if (!_isDisposed) {
                   _searchButtonFocusNode.requestFocus();
                   setState(() => _showKeyboard = true);
                 }
               },
             );
          }

          final genreIndex = index - 1;
          final genre = _genres[genreIndex];
          final focusNode = _genreFocusNodes[genreIndex];
          final isSelected = !_isSearching && _selectedGenre == genre;
          final focusColor = _focusColors[genreIndex % _focusColors.length];

          return _buildGlassEffectButton(
            focusNode: focusNode,
            label: genre.toUpperCase(),
            icon: null,
            isSelected: isSelected,
            focusColor: focusColor,
            marginLeft: 12,
            marginRight: 12,
            onFocusChange: (hasFocus) {
              if (hasFocus && !_isDisposed && mounted) {
                setState(() => _focusedGenreIndex = genreIndex);
                Provider.of<InternalFocusProvider>(context, listen: false).updateName(genre);
              }
            },
            onTap: () {
               if (!_isDisposed) {
                 focusNode.requestFocus();
                 _changeGenre(genreIndex);
               }
            },
          );
        },
      ),
    );
  }

  Widget _buildGlassEffectButton({
    required FocusNode focusNode,
    required String label,
    required IconData? icon,
    required bool isSelected,
    required Color focusColor,
    required double marginLeft,
    required double marginRight,
    required Function(bool) onFocusChange,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: marginLeft, right: marginRight),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Focus(
              focusNode: focusNode,
              onFocusChange: onFocusChange,
              child: AnimatedContainer(
                duration: AnimationTiming.fast,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: focusNode.hasFocus
                      ? focusColor
                      : isSelected
                          ? focusColor.withOpacity(0.5)
                          : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: focusNode.hasFocus ? Colors.white : Colors.white.withOpacity(0.3),
                    width: focusNode.hasFocus ? 3 : 2,
                  ),
                  boxShadow: focusNode.hasFocus
                      ? [BoxShadow(color: focusColor.withOpacity(0.8), blurRadius: 15, spreadRadius: 3)]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 8)],
                    Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelsList() {
    final list = _isSearching ? _searchResults : _currentDisplayList;
    if (list.isEmpty) return const Center(child: Text("No Channels Available", style: TextStyle(color: Colors.white54)));
    
    final safeCount = math.min(list.length, _channelFocusNodes.length);

    return ListView.builder(
      key: ValueKey('channels_${_selectedGenre}_${_isSearching}'),
      controller: _channelScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      itemCount: safeCount,
      itemBuilder: (context, index) {
        if (index >= list.length || index >= _channelFocusNodes.length) return const SizedBox.shrink();

        return ChannelItemWithColorSystem(
          key: ValueKey('${list[index].id}_$index'),
          channel: list[index],
          focusNode: _channelFocusNodes[index],
          isFocused: _focusedChannelIndex == index,
          uniqueIndex: index,
          focusColors: _focusColors,
          onFocus: () {
            if (!_isDisposed && mounted) {
              setState(() => _focusedChannelIndex = index);
              Provider.of<InternalFocusProvider>(context, listen: false).updateName(list[index].name);
            }
          },
          onTap: () => _playChannel(list[index]),
        );
      },
    );
  }

  Widget _buildSearchUI() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                _searchText.isEmpty ? "SEARCH..." : _searchText,
                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(flex: 2, child: _buildKeyboardKeys()),
        ],
      ),
    );
  }

  Widget _buildKeyboardKeys() {
    int nodeIdx = 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _keyboardLayout.asMap().entries.map((rEntry) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rEntry.value.asMap().entries.map((cEntry) {
            final key = cEntry.value;
            final isFocused = _focusedKeyRow == rEntry.key && _focusedKeyCol == cEntry.key;
            final idx = nodeIdx++;
            double w = (key == "SPACE") ? 150 : (key == "OK" || key == "DEL" ? 60 : 35);
            
            return Container(
              margin: const EdgeInsets.all(2),
              width: w,
              height: 32,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  color: isFocused ? ProfessionalColors.accentPurple : Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isFocused ? Colors.white : Colors.white10, width: isFocused ? 2 : 1),
                  boxShadow: isFocused ? [BoxShadow(color: ProfessionalColors.accentPurple.withOpacity(0.5), blurRadius: 8)] : null,
                ),
                child: Center(
                  child: Text(
                    key,
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: isFocused ? FontWeight.bold : FontWeight.normal),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildSliderIndicators() {
    if (_sliders.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10), // Added padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_sliders.length, (i) => 
          AnimatedContainer(
            duration: AnimationTiming.fast,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            height: 8,
            width: _currentSliderPage == i ? 24 : 8,
            decoration: BoxDecoration(
              color: _currentSliderPage == i ? ProfessionalColors.accentBlue : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 2, offset: const Offset(0, 1))
              ]
            ),
          )
        ),
      ),
    );
  }
}

// ==========================================================
// CHANNEL ITEM COMPONENT
// ==========================================================

class ChannelItemWithColorSystem extends StatefulWidget {
  final NewsChannel channel;
  final FocusNode focusNode;
  final bool isFocused;
  final int uniqueIndex;
  final List<Color> focusColors;
  final VoidCallback onFocus;
  final VoidCallback onTap;

  const ChannelItemWithColorSystem({
    super.key,
    required this.channel,
    required this.focusNode,
    required this.isFocused,
    required this.uniqueIndex,
    required this.focusColors,
    required this.onFocus,
    required this.onTap,
  });

  @override
  State<ChannelItemWithColorSystem> createState() => _ChannelItemWithColorSystemState();
}

class _ChannelItemWithColorSystemState extends State<ChannelItemWithColorSystem> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Color get _focusColor => widget.focusColors[widget.uniqueIndex % widget.focusColors.length];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: InkWell(
          focusNode: widget.focusNode,
          onFocusChange: (has) {
            if (has) widget.onFocus();
          },
          onTap: widget.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AnimationTiming.fast,
                width: bannerwdt, 
                height: bannerhgt, 
                transform: widget.isFocused ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isFocused ? _focusColor : Colors.white10,
                    width: widget.isFocused ? 3 : 1,
                  ),
                  boxShadow: widget.isFocused ? [BoxShadow(color: _focusColor.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)] : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.channel.banner,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: ProfessionalColors.cardDark,
                          child: const Icon(Icons.tv, color: Colors.white24, size: 40),
                        ),
                      ),
                      if (widget.isFocused)
                        Container(color: Colors.black12, child: Icon(Icons.play_circle_fill, color: _focusColor, size: 30)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: bannerwdt,
                child: Text(
                  widget.channel.name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.isFocused ? _focusColor : Colors.white60,
                    fontSize: 12,
                    fontWeight: widget.isFocused ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.gradient, this.style});
  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: style),
    );
  }
}





