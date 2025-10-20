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






import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/video_widget/live_video_screen.dart';
import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================================
// ENUMS, HELPERS AND DATA MODELS
// ==========================================================

enum LoadingState { initial, loading, loaded, error }

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
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
}

// NEW: Data model for slider items from the languages API
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

class NewsChannel {
  final int id;
  final String name;
  final String banner;
  final String url;
  final String genres;
  final int status;
  final String streamType;
  final String contentType;

  NewsChannel({
    required this.id,
    required this.name,
    required this.banner,
    required this.url,
    required this.genres,
    required this.status,
    required this.streamType,
    required this.contentType,
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
      contentType: json['content_type']?.toString() ?? '',
    );
  }
}

// ==========================================================
// MAIN SCREEN WIDGET
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

class _LanguageChannelsScreenState extends State<LanguageChannelsScreen> {
  LoadingState _loadingState = LoadingState.initial;
  String? _error;

  // Data state
  List<NewsChannel> _allChannels = [];
  List<String> _genres = [];
  Map<String, List<NewsChannel>> _channelsByGenre = {};
  int _selectedGenreIndex = 0;
  List<NewsChannel> _currentDisplayList = [];
  String _backgroundImageUrl = '';

  // NEW: Slider state variables
  List<SliderItem> _sliders = [];
  PageController? _sliderPageController;
  Timer? _sliderTimer;
  int _currentSliderPage = 0;

  // Search state
  bool _isSearching = false;
  bool _showKeyboard = false;
  String _searchText = '';
  Timer? _debounce;
  List<NewsChannel> _searchResults = [];
  bool _isSearchLoading = false;
  bool _isVideoLoading = false;

  // Focus Nodes
  late FocusNode _searchButtonFocusNode;
  List<FocusNode> _genreFocusNodes = [];
  List<FocusNode> _channelFocusNodes = [];

  // Keys and Controllers
  List<GlobalKey> _genreButtonKeys = [];
  List<GlobalKey> _channelCardKeys = [];
  final ScrollController _genreScrollController = ScrollController();
  final ScrollController _channelScrollController = ScrollController();
    bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;

  final List<Color> _focusColors = [
    ProfessionalColors.accentBlue,
    ProfessionalColors.accentPurple,
    ProfessionalColors.accentGreen,
    ProfessionalColors.accentOrange,
    ProfessionalColors.accentPink,
    ProfessionalColors.accentRed
  ];

  @override
  void initState() {
    super.initState();
    _searchButtonFocusNode = FocusNode();
    _searchButtonFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
        if (_searchButtonFocusNode.hasFocus) {
          Provider.of<InternalFocusProvider>(context, listen: false)
              .updateName("Search");
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InternalFocusProvider>(context, listen: false).updateName('');
      _fetchAndProcessData();
    });
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  void _cleanupResources() {
    _searchButtonFocusNode.dispose();
    for (var node in _genreFocusNodes) node.dispose();
    for (var node in _channelFocusNodes) node.dispose();
    _genreScrollController.dispose();
    _channelScrollController.dispose();
    _debounce?.cancel();
    // NEW: Dispose slider resources
    _sliderPageController?.dispose();
    _sliderTimer?.cancel();
    _navigationLockTimer?.cancel();
  }

  // MODIFIED: This function now also fetches language data for the slider.
  Future<void> _fetchAndProcessData() async {
    if (mounted) setState(() => _loadingState = LoadingState.loading);
    try {
      final prefs = await SharedPreferences.getInstance();
      final authKey = prefs.getString('result_auth_key') ?? '';

      // --- NEW: Fetch slider data ---
      try {
        final languagesResponse = await https.get(
          Uri.parse(
              'https://dashboard.cpplayers.com/public/api/v2/getAllLanguages'),
          headers: {
            'auth-key': authKey,
            'domain': 'coretechinfo.com',
          },
        );

        if (languagesResponse.statusCode == 200) {
          final languagesData = json.decode(languagesResponse.body);
          if (languagesData['status'] == true &&
              languagesData['languages'] is List) {
            final allLanguages = languagesData['languages'] as List;
            // Find the language that matches the current screen's language ID
            final currentLanguage = allLanguages.firstWhere(
              (lang) => lang['id'].toString() == widget.languageId,
              orElse: () => null,
            );

            if (currentLanguage != null &&
                currentLanguage['slider'] is List &&
                (currentLanguage['slider'] as List).isNotEmpty) {
              final sliderData = currentLanguage['slider'] as List;
              if (mounted) {
                setState(() {
                  _sliders = sliderData
                      .map((item) => SliderItem.fromJson(item))
                      .toList();
                });
              }
            }
          }
        }
      } catch (e) {
        // If fetching sliders fails, we can ignore it and proceed
        if (kDebugMode) {
          print("Could not fetch slider data: $e");
        }
      }
      // --- End of new slider fetch logic ---

      final response = await https.post(
        Uri.parse('https://dashboard.cpplayers.com/api/v2/getAllLiveTV'),
        headers: {
          'auth-key': authKey,
          'domain': 'coretechinfo.com',
          'Content-Type': 'application/json'
        },
        body: json.encode({"genere": "", "languageId": widget.languageId}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> channelsData = json.decode(response.body);
        _allChannels = channelsData
            .map((item) => NewsChannel.fromJson(item))
            .where((channel) => channel.status == 1)
            .toList();

        if (_allChannels.isEmpty) {
          throw Exception('No channels found for this language.');
        }

        final Map<String, List<NewsChannel>> channelsByGenre = {};
        final Set<String> uniqueGenres = {};

        for (final channel in _allChannels) {
          final genres = channel.genres.split(',').map((g) => g.trim()).toList();
          for (var genre in genres) {
            if (genre.isNotEmpty) {
              uniqueGenres.add(genre);
              channelsByGenre.putIfAbsent(genre, () => []).add(channel);
            }
          }
        }

        List<String> sortedGenres = uniqueGenres.toList()..sort();

        if (!mounted) return;
        setState(() {
          _genres = sortedGenres;
          _channelsByGenre = channelsByGenre;
          _selectedGenreIndex = 0;
          // Set fallback background image, which will be used if no slider exists
          _backgroundImageUrl = _allChannels.first.banner;

          _genreFocusNodes = List.generate(_genres.length, (_) => FocusNode());
          _genreButtonKeys = List.generate(_genres.length, (_) => GlobalKey());

          for (int i = 0; i < _genres.length; i++) {
            _genreFocusNodes[i].addListener(() {
              if (_genreFocusNodes[i].hasFocus) _onGenreFocus(i);
            });
          }
          _loadingState = LoadingState.loaded;
        });

        _shuffleAndSetDisplayList();
        _rebuildChannelNodes();
        _setupSliderTimer(); // NEW: Setup the slider timer

        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && _searchButtonFocusNode.canRequestFocus) {
            _searchButtonFocusNode.requestFocus();
          }
        });
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loadingState = LoadingState.error;
        });
      }
    }
  }

  // NEW: Method to set up the auto-scrolling timer for the slider
  void _setupSliderTimer() {
    _sliderTimer?.cancel();
    if (_sliders.length > 1 && mounted) {
      _sliderPageController = PageController(initialPage: 0);
      _sliderTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (!mounted || _sliderPageController?.hasClients == false) return;

        int nextPage = _currentSliderPage + 1;
        if (nextPage >= _sliders.length) {
          _sliderPageController?.jumpToPage(0);
        } else {
          _sliderPageController?.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _shuffleAndSetDisplayList() {
    if (_genres.isEmpty) return;
    final originalList = _channelsByGenre[_genres[_selectedGenreIndex]] ?? [];
    // final shuffledList = List<NewsChannel>.from(originalList)..shuffle();
    setState(() {
      // _currentDisplayList = shuffledList;
      _currentDisplayList = originalList;
    });
  }

  void _rebuildChannelNodes() {
    if (!mounted) return;
    for (var node in _channelFocusNodes) node.dispose();

    final currentList = _isSearching ? _searchResults : _currentDisplayList;
    _channelFocusNodes = List.generate(currentList.length, (_) => FocusNode());
    _channelCardKeys = List.generate(currentList.length, (_) => GlobalKey());

    for (int i = 0; i < currentList.length; i++) {
      _channelFocusNodes[i].addListener(() {
        if (_channelFocusNodes[i].hasFocus) _onChannelFocus(i);
      });
    }
  }

  void _performSearch(String searchTerm) {
    _debounce?.cancel();
    if (searchTerm.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _isSearchLoading = false;
        _searchResults.clear();
        _rebuildChannelNodes();
      });
      return;
    }

    setState(() {
      _isSearchLoading = true;
      _isSearching = true;
      _searchResults.clear();
    });

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final results = _allChannels
          .where((channel) =>
              channel.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();

      setState(() {
        _searchResults = results;
        _isSearchLoading = false;
        _rebuildChannelNodes();
      });
    });
  }

  void _onKeyPressed(String value) {
    setState(() {
      if (value == 'OK') {
        _showKeyboard = false;
        if (_channelFocusNodes.isNotEmpty) {
          _channelFocusNodes.first.requestFocus();
        } else {
          _searchButtonFocusNode.requestFocus();
        }
        return;
      }

      if (value == 'DEL') {
        if (_searchText.isNotEmpty) {
          _searchText = _searchText.substring(0, _searchText.length - 1);
        }
      } else {
        _searchText += value;
      }
      _performSearch(_searchText);
    });
  }

  void _updateChannelsForGenre(int index) {
    if (_isSearching) {
      setState(() {
        _isSearching = false;
        _searchText = '';
        _searchResults.clear();
      });
    }
    if (_selectedGenreIndex == index) {
      // _shuffleAndSetDisplayList();
      // _rebuildChannelNodes();
      return;
    }
    setState(() => _selectedGenreIndex = index);
    _shuffleAndSetDisplayList();
    _rebuildChannelNodes();
  }

  void _onGenreFocus(int index) {
    if (!mounted || index >= _genres.length) return;
    Provider.of<InternalFocusProvider>(context, listen: false)
        .updateName(_genres[index]);

    final buttonContext = _genreButtonKeys[index].currentContext;
    if (buttonContext != null) {
      Scrollable.ensureVisible(buttonContext,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 0.5);
    }
  }

  void _onChannelFocus(int index) {
    if (!mounted) return;
    final currentList = _isSearching ? _searchResults : _currentDisplayList;
    if (index < currentList.length) {
      Provider.of<InternalFocusProvider>(context, listen: false)
          .updateName(currentList[index].name);
    }
    final cardContext = _channelCardKeys[index].currentContext;
    if (cardContext != null) {
      Scrollable.ensureVisible(cardContext,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 0.5);
    }
  }

  // Future<void> _playChannel(NewsChannel channel) async {
  //   if (_isVideoLoading) return;
  //   setState(() => _isVideoLoading = true);

  //   try {
  //     int? userId = int.tryParse(
  //         (await SharedPreferences.getInstance()).getString('user_id') ?? '');
  //     if (userId != null) {
  //       await HistoryService.updateUserHistory(
  //           userId: userId,
  //           contentType: int.tryParse(channel.contentType) ?? 4,
  //           eventId: channel.id,
  //           eventTitle: channel.name,
  //           url: channel.url,
  //           categoryId: 0);
  //     }
  //   } catch (e) {
  //     if (kDebugMode) print("History update failed: $e");
  //   }

  //   try {
  //     List<NewsItemModel> allChannelsForPlayer = _allChannels
  //         .map((c) => NewsItemModel(
  //               id: c.id.toString(),
  //               videoId: '',
  //               name: c.name,
  //               description: '',
  //               banner: c.banner,
  //               poster: c.banner,
  //               category: c.genres,
  //               url: c.url,
  //               streamType: c.streamType,
  //               type: c.streamType,
  //               genres: c.genres,
  //               status: c.status.toString(),
  //               index: _allChannels.indexOf(c).toString(),
  //               image: c.banner,
  //               unUpdatedUrl: c.url,
  //               updatedAt: '',
  //             ))
  //         .toList();

  //     NewsItemModel currentChannel = allChannelsForPlayer
  //         .firstWhere((item) => item.id == channel.id.toString());

  //     if (!mounted) return;
  //     await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => LiveVideoScreen(
  //           videoUrl: currentChannel.url,
  //           bannerImageUrl: currentChannel.banner,
  //           source: 'isLive',
  //           channelList: allChannelsForPlayer,
  //           videoId: int.tryParse(currentChannel.id),
  //           name: currentChannel.name,
  //           liveStatus: true,
  //           updatedAt: currentChannel.updatedAt,
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     if (mounted)
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text('Error playing channel: $e')));
  //   } finally {
  //     if (mounted) setState(() => _isVideoLoading = false);
  //   }
  // }



  Future<void> _playChannel(NewsChannel channel) async {
    if (_isVideoLoading) return;
    setState(() => _isVideoLoading = true);

    try {
      int? userId = int.tryParse(
          (await SharedPreferences.getInstance()).getString('user_id') ?? '');
      if (userId != null) {
        await HistoryService.updateUserHistory(
            userId: userId,
            contentType: int.tryParse(channel.contentType) ?? 4,
            eventId: channel.id,
            eventTitle: channel.name,
            url: channel.url,
            categoryId: 0);
      }
    } catch (e) {
      if (kDebugMode) print("History update failed: $e");
    }

    try {
      // --- YAHAN BADLAV SHURU HOTA HAI ---

      // Step 1: Pata karein ki current mein kaun si list active hai.
      final List<NewsChannel> sourceList =
          _isSearching ? _searchResults : _currentDisplayList;

      // Step 2: Active list (sourceList) se player ke liye list banayein, na ki _allChannels se.
      List<NewsItemModel> channelsForPlayer = sourceList
          .map((c) => NewsItemModel(
                id: c.id.toString(),
                videoId: '',
                name: c.name,
                description: '',
                banner: c.banner,
                poster: c.banner,
                category: c.genres,
                url: c.url,
                streamType: c.streamType,
                type: c.streamType,
                genres: c.genres,
                status: c.status.toString(),
                index: sourceList.indexOf(c).toString(), // sourceList use karein
                image: c.banner,
                unUpdatedUrl: c.url,
                updatedAt: '',
              ))
          .toList();

      NewsItemModel currentChannel = channelsForPlayer
          .firstWhere((item) => item.id == channel.id.toString());
      
      // --- BADLAV YAHAN KHATAM HOTA HAI ---

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoScreen (
            videoUrl: currentChannel.url,
            bannerImageUrl: currentChannel.banner,
            source: 'isLive',
            // Step 3: Filter ki hui nayi list (channelsForPlayer) ko pass karein.
            channelList: channelsForPlayer,
            videoId: int.tryParse(currentChannel.id),
            name: currentChannel.name,
            liveStatus: true,
            updatedAt: currentChannel.updatedAt,
          ),
        ),
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error playing channel: $e')));
    } finally {
      if (mounted) setState(() => _isVideoLoading = false);
    }
  }

  // ==========================================================
  // BUILD METHODS
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    // const double bannerhgt = 100.0;

    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_loadingState == LoadingState.loaded)
            _showKeyboard
                ? Container(color: ProfessionalColors.primaryDark)
                // MODIFIED: This now conditionally shows the slider or static image
                : _buildStaticBackground(),
          if (_loadingState == LoadingState.loading ||
              _loadingState == LoadingState.initial)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
                child: Text('Error: $_error',
                    style: const TextStyle(color: Colors.white)))
          else
            Column(
              children: [
                SizedBox(
                  height: screenhgt * 0.68,
                  child: _showKeyboard
                      ? _buildSearchUI()
                      : const SizedBox.shrink(),
                ),
                _buildGenreButtons(),
                SizedBox(
                    height: bannerhgt * 1.5, child: _buildChannelsList()),
              ],
            ),
          if (_loadingState == LoadingState.loaded)
            Positioned(
                top: 0, left: 0, right: 0, child: _buildBeautifulAppBar()),
          if (_isVideoLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
            ),
        ],
      ),
    );
  }



// MODIFIED: This widget now builds a PageView slider if sliders are available.
  Widget _buildStaticBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Conditionally build PageView or fallback Image
        if (_sliders.isNotEmpty && _sliderPageController != null)
          PageView.builder(
            controller: _sliderPageController,
            itemCount: _sliders.length,
            onPageChanged: (index) {
              if (mounted) {
                setState(() => _currentSliderPage = index);
              }
            },
            itemBuilder: (context, index) {
              final slider = _sliders[index];
              return Image.network(
                slider.banner,
                // YAHAN BADLAV KAREIN: .cover se .fill karein
                fit: BoxFit.fill,
                errorBuilder: (c, e, s) =>
                    Container(color: ProfessionalColors.primaryDark),
              );
            },
          )
        else if (_backgroundImageUrl.isNotEmpty)
          // Fallback to the original background
          Image.network(
            _backgroundImageUrl,
             // Aap chahein to isse bhi .fill kar sakte hain
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) =>
                Container(color: ProfessionalColors.primaryDark),
          )
        else
          Container(color: ProfessionalColors.primaryDark),

        // Gradient overlay
        // Container(
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       begin: Alignment.topCenter,
        //       end: Alignment.bottomCenter,
        //       colors: [
        //         Colors.transparent,
        //         ProfessionalColors.primaryDark.withOpacity(0.5),
        //         ProfessionalColors.primaryDark,
        //       ],
        //       stops: const [0.4, 0.7, 1.0],
        //     ),
        //   ),
        // ),


         // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // YAHAN BADLAV KAREIN: Colors ko aur zyada dark banayein
                ProfessionalColors.primaryDark.withOpacity(0.2), // Start a bit darker
                ProfessionalColors.primaryDark.withOpacity(0.4), // Mid-point darker
                ProfessionalColors.primaryDark.withOpacity(0.6), // Mid-point darker
                ProfessionalColors.primaryDark, // Full dark at the bottom
              ],
              stops: const [0.3, 0.6, 0.7,9.0], // Stops ko bhi adjust kar sakte hain
              // stops: const [0.4, 0.7, 1.0], // Original stops
            ),
          ),
        ),
        // NEW: Slider indicator
        if (_sliders.length > 1)
          Positioned(
            bottom: screenhgt * 0.35, // Adjust this value to position it above the lists
            left: 0,
            right: 0,
            child: _buildSliderIndicator(),
          )
      ],
    );
  }


  // NEW: Widget to build the slider indicator dots
  Widget _buildSliderIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _sliders.asMap().entries.map((entry) {
        int index = entry.key;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentSliderPage == index ? 12.0 : 8.0,
          height: _currentSliderPage == index ? 12.0 : 8.0,
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentSliderPage == index
                ? ProfessionalColors.accentBlue
                : Colors.white.withOpacity(0.4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBeautifulAppBar() {
    final focusedName = context.watch<InternalFocusProvider>().focusedItemName;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ProfessionalColors.primaryDark.withOpacity(0.8),
              ProfessionalColors.primaryDark.withOpacity(0.5),
              Colors.transparent
            ]),
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            left: 40,
            right: 40,
            bottom: 10),
        child: Row(
          children: [
            GradientText(widget.languageName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                gradient: const LinearGradient(colors: [
                  ProfessionalColors.accentPink,
                  ProfessionalColors.accentPurple,
                ])),
            const SizedBox(width: 40),
            Expanded(
                child: Text(focusedName,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        color: ProfessionalColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreButtons() {
    return SizedBox(
      height: 30,
      child: ListView.builder(
        controller: _genreScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _genres.length + 1,
        padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.03, vertical: 1),
        itemBuilder: (context, index) {
          if (index == 0) {
            // Search Button
            return Focus(
              focusNode: _searchButtonFocusNode,
              onKey: (node, event) {
                if (event is RawKeyDownEvent &&
                    (event.logicalKey == LogicalKeyboardKey.enter ||
                        event.logicalKey == LogicalKeyboardKey.select)) {
                  setState(() => _showKeyboard = true);
                  return KeyEventResult.handled;
                }
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  if (_genreFocusNodes.isNotEmpty) {
                    _genreFocusNodes.first.requestFocus();
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: GestureDetector(
                onTap: () {
                  _searchButtonFocusNode.requestFocus();
                  setState(() => _showKeyboard = true);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 1),
                        decoration: BoxDecoration(
                          color: _searchButtonFocusNode.hasFocus
                              ? ProfessionalColors.accentOrange.withOpacity(0.7)
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _searchButtonFocusNode.hasFocus
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            width: _searchButtonFocusNode.hasFocus ? 3 : 2,
                          ),
                        ),
                        child:  Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 8),
                            Text(("Search").toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          // Genre Buttons
          final genreIndex = index - 1;
          final genre = _genres[genreIndex];
          final isSelected = !_isSearching && _selectedGenreIndex == genreIndex;
          return Focus(
            focusNode: _genreFocusNodes[genreIndex],
            onKey: (node, event) {
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
                    genreIndex == 0) {
                  _searchButtonFocusNode.requestFocus();
                  return KeyEventResult.handled;
                }
                if (event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.select) {
                  _updateChannelsForGenre(genreIndex);
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: GestureDetector(
              onTap: () => _genreFocusNodes[genreIndex].requestFocus(),
              child: Container(
                key: _genreButtonKeys[genreIndex],
                margin: const EdgeInsets.only(right: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _focusColors[genreIndex % _focusColors.length]
                                .withOpacity(0.6)
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _genreFocusNodes[genreIndex].hasFocus
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          width: _genreFocusNodes[genreIndex].hasFocus ? 3 : 2,
                        ),
                      ),
                      child: Center(
                        child: Text(genre.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChannelsList() {
    final currentList = _isSearching ? _searchResults : _currentDisplayList;

    if (_isSearchLoading) return const Center(child: CircularProgressIndicator());
    if (currentList.isEmpty) {
      return Center(
        child: Text(
            _isSearching && _searchText.isNotEmpty
                ? "No results found for '$_searchText'"
                : "No channels available for this genre.",
            style: const TextStyle(
                color: ProfessionalColors.textSecondary, fontSize: 16)),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: ListView.builder(
        controller: _channelScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: currentList.length,
        padding:  EdgeInsets.symmetric(horizontal: screenwdt *0.03 ),
        itemBuilder: (context, index) {
          final channel = currentList[index];
          return Focus(
            focusNode: _channelFocusNodes[index],
            // onKey: (node, event) {
            //   if (event is RawKeyDownEvent &&
            //       (event.logicalKey == LogicalKeyboardKey.select ||
            //           event.logicalKey == LogicalKeyboardKey.enter)) {
            //     _playChannel(channel);
            //     return KeyEventResult.handled;
            //   }
            //   return KeyEventResult.ignored;
            // },
                     onKey: (node, event) {
            if (event is RawKeyDownEvent) {
              final key = event.logicalKey;

              // --- हॉरिजॉन्टल मूवमेंट (लेफ्ट/राइट) के लिए थ्रॉटलिंग ---
              if (key == LogicalKeyboardKey.arrowRight ||
                  key == LogicalKeyboardKey.arrowLeft) {
                    
                // 1. अगर नेविगेशन लॉक्ड है, तो कुछ न करें
                if (_isNavigationLocked) return KeyEventResult.handled;

                // 2. नेविगेशन को लॉक करें और 300ms का टाइमर शुरू करें
                setState(() => _isNavigationLocked = true);
                _navigationLockTimer = Timer(const Duration(milliseconds: 700), () {
                  if (mounted) setState(() => _isNavigationLocked = false);
                });

                // 3. अब फोकस बदलें
                final currentList = _isSearching ? _searchResults : _currentDisplayList;

                if (key == LogicalKeyboardKey.arrowRight) {
                  if (index < currentList.length - 1) {
                    _channelFocusNodes[index + 1].requestFocus();
                  } else {
                    _navigationLockTimer?.cancel();
                    if (mounted) setState(() => _isNavigationLocked = false);
                  }
                } else if (key == LogicalKeyboardKey.arrowLeft) {
                  if (index > 0) {
                    _channelFocusNodes[index - 1].requestFocus();
                  } else {
                    _navigationLockTimer?.cancel();
                    if (mounted) setState(() => _isNavigationLocked = false);
                  }
                }
                return KeyEventResult.handled;
              }

              // --- वर्टिकल मूवमेंट (ऊपर) ---
              if (key == LogicalKeyboardKey.arrowUp) {
                if (_genres.isNotEmpty) {
                    _genreFocusNodes[_selectedGenreIndex].requestFocus();
                } else {
                    _searchButtonFocusNode.requestFocus();
                }
                return KeyEventResult.handled;
              }

              // --- एक्शन (सेलेक्ट/एंटर) ---
              if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
                _playChannel(channel);
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
            child: ChannelCard(
                key: _channelCardKeys[index],
                channel: channel,
                focusNode: _channelFocusNodes[index],
                focusColors: _focusColors,
                uniqueIndex: index,
                onTap: () => _playChannel(channel)),
          );
        },
      ),
    );
  }

  Widget _buildSearchUI() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const GradientText("Search for Channels",
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    gradient: LinearGradient(colors: [
                      ProfessionalColors.accentBlue,
                      ProfessionalColors.accentPurple
                    ])),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: ProfessionalColors.accentPurple, width: 2),
                  ),
                  child: Text(
                    _searchText.isEmpty ? 'Start typing...' : _searchText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          _searchText.isEmpty ? Colors.white54 : Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(flex: 6, child: _buildQwertyKeyboard()),
      ],
    );
  }

  Widget _buildQwertyKeyboard() {
    final row1 = "1234567890".split('');
    final row2 = "QWERTYUIOP".split('');
    final row3 = "ASDFGHJKL".split('');
    final row4 = "ZXCVBNM,.".split('');
    final row5 = ["DEL", " ", "OK"];

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildKeyboardRow(row1),
          _buildKeyboardRow(row2),
          _buildKeyboardRow(row3),
          _buildKeyboardRow(row4),
          _buildKeyboardRow(row5),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        return Expanded(
          flex: (key == ' ' || key == 'OK' || key == 'DEL') ? 2 : 1,
          child: Container(
            margin: const EdgeInsets.all(4),
            child: ElevatedButton(
              onPressed: () => _onKeyPressed(key),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12)),
              child: Text(key,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ==========================================================
// REUSABLE WIDGETS
// ==========================================================

class ChannelCard extends StatefulWidget {
  final NewsChannel channel;
  final FocusNode focusNode;
  final List<Color> focusColors;
  final int uniqueIndex;
  final VoidCallback onTap;

  const ChannelCard(
      {super.key,
      required this.channel,
      required this.focusNode,
      required this.focusColors,
      required this.uniqueIndex,
      required this.onTap});

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted && widget.focusNode.hasFocus != _hasFocus) {
      setState(() => _hasFocus = widget.focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusColor =
        widget.focusColors[widget.uniqueIndex % widget.focusColors.length];
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: bannerwdt,
      margin: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: _hasFocus
                      ? Border.all(color: focusColor, width: 3)
                      : Border.all(color: Colors.transparent, width: 3),
                  boxShadow: _hasFocus
                      ? [
                          BoxShadow(
                              color: focusColor.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 1)
                        ]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(widget.channel.banner, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                              color: ProfessionalColors.cardDark,
                              child: Center(
                                  child: Icon(Icons.tv, color: Colors.white54))),
                          loadingBuilder: (c, child, progress) =>
                              progress == null
                                  ? child
                                  : Container(color: ProfessionalColors.cardDark)),
                      if (_hasFocus)
                        Container(
                            color: Colors.black.withOpacity(0.4),
                            child: Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 40)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
                padding:
                    const EdgeInsets.only(top: 4.0, left: 2.0, right: 2.0),
                child: Text(widget.channel.name,
                    style: TextStyle(
                        color: _hasFocus
                            ? focusColor
                            : ProfessionalColors.textSecondary,
                        fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
          ],
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
      shaderCallback: (bounds) =>
          gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: style),
    );
  }
}