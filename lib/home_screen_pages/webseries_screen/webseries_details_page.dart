// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import '../../video_widget/socket_service.dart';

// class SeasonModel {
//   final int id;
//   final String sessionName;
//   final int seasonOrder;
//   final int webSeriesId;
//   final int status;

//   SeasonModel({
//     required this.id,
//     required this.sessionName,
//     required this.seasonOrder,
//     required this.webSeriesId,
//     required this.status,
//   });

//   factory SeasonModel.fromJson(Map<String, dynamic> json) {
//     return SeasonModel(
//       id: json['id'] ?? 0,
//       sessionName: json['Session_Name'] ?? '',
//       seasonOrder: json['season_order'] ?? 1,
//       webSeriesId: json['web_series_id'] ?? 0,
//       status: json['status'] ?? 1,
//     );
//   }
// }

// class WebSeriesDetailsPage extends StatefulWidget {
//   final int id;
//   final List<NewsItemModel> channelList;
//   final String source;
//   final String banner;
//   final String name;

//   const WebSeriesDetailsPage({
//     Key? key,
//     required this.id,
//     required this.channelList,
//     required this.source,
//     required this.banner,
//     required this.name,
//   }) : super(key: key);

//   @override
//   _WebSeriesDetailsPageState createState() => _WebSeriesDetailsPageState();
// }

// class _WebSeriesDetailsPageState extends State<WebSeriesDetailsPage>
//     with WidgetsBindingObserver {
//   final SocketService _socketService = SocketService();
//   final ScrollController _scrollController = ScrollController();
//   final ScrollController _seasonsScrollController = ScrollController();
//   final FocusNode _mainFocusNode = FocusNode();

//   bool _isLoading = true;
//   bool _isProcessing = false;
//   bool _isLoadingEpisodes = false;

//   List<SeasonModel> _seasons = [];
//   Map<int, List<NewsItemModel>> _episodesMap = {};

//   int _selectedSeasonIndex = 0;
//   int _selectedEpisodeIndex = 0;

//   final Map<int, FocusNode> _seasonsFocusNodes = {};
//   final Map<String, FocusNode> _episodeFocusNodes = {};

//   String _errorMessage = "";
//   String _authKey = '';

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _socketService.initSocket();
//     _loadAuthKey();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _scrollController.dispose();
//     _seasonsScrollController.dispose();
//     _mainFocusNode.dispose();
//     _seasonsFocusNodes.values.forEach((node) => node.dispose());
//     _episodeFocusNodes.values.forEach((node) => node.dispose());
//     _socketService.dispose();
//     super.dispose();
//   }

//   Future<void> _loadAuthKey() async {
//     await AuthManager.initialize();
//     setState(() {
//       _authKey = AuthManager.authKey;
//       if (_authKey.isEmpty) {
//         _authKey = globalAuthKey;
//       }
//     });

//     print('🔑 WebSeriesDetailsPage - Auth key loaded: $_authKey');

//     if (_authKey.isEmpty) {
//       setState(() {
//         _errorMessage = "Authentication required. Please login again.";
//         _isLoading = false;
//       });
//       return;
//     }

//     _initializePage();
//   }

//   Future<void> _initializePage() async {
//     await _fetchSeasons();
//     if (_seasons.isNotEmpty) {
//       await _fetchEpisodes(_seasons.first.id);
//     }
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(_mainFocusNode);
//     });
//   }

//   Future<void> _fetchSeasons() async {
//     if (_authKey.isEmpty) {
//       setState(() {
//         _errorMessage = "No authentication key available";
//         _isLoading = false;
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = "Loading seasons...";
//     });

//     try {
//       final response = await https.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getSeasons/${widget.id}'),
//         headers: {
//           'auth-key': _authKey,
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 15));

//       print('🌐 Seasons API Response Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         String responseBody = response.body.trim();
//         if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
//           final List<dynamic> data = jsonDecode(responseBody);

//           // Initialize focus nodes for seasons
//           _seasonsFocusNodes.clear();

//           setState(() {
//             _seasons = data.map((season) => SeasonModel.fromJson(season)).toList();
//             _isLoading = false;
//             _errorMessage = "";
//           });

//           // Create focus nodes for each season
//           for (int i = 0; i < _seasons.length; i++) {
//             _seasonsFocusNodes[i] = FocusNode();
//           }

//           // Set initial focus on first season
//           if (_seasons.isNotEmpty) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               if (mounted) {
//                 _seasonsFocusNodes[0]?.requestFocus();
//               }
//             });
//           }
//         } else {
//           setState(() {
//             _isLoading = false;
//             _errorMessage = "Invalid response format from server";
//           });
//         }
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = "Authentication failed. Please login again.";
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = "Failed to load seasons (${response.statusCode})";
//         });
//       }
//     } catch (e) {
//       print('❌ Error fetching seasons: $e');
//       setState(() {
//         _isLoading = false;
//         _errorMessage = "Error: ${e.toString()}";
//       });
//     }
//   }

//   Future<void> _fetchEpisodes(int seasonId) async {
//     // Check if episodes are already cached
//     if (_episodesMap.containsKey(seasonId)) {
//       setState(() {
//         _selectedSeasonIndex = _seasons.indexWhere((season) => season.id == seasonId);
//         _selectedEpisodeIndex = 0;
//       });
//       _setInitialEpisodeFocus();
//       return;
//     }

//     if (_authKey.isEmpty) {
//       setState(() {
//         _errorMessage = "No authentication key available";
//         _isLoadingEpisodes = false;
//       });
//       return;
//     }

//     setState(() {
//       _isLoadingEpisodes = true;
//       _errorMessage = "Loading episodes...";
//     });

//     try {
//       final response = await https.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getEpisodes/$seasonId/0'),
//         headers: {
//           'auth-key': _authKey,
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 15));

//       print('🌐 Episodes API Response Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         String responseBody = response.body.trim();
//         if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
//           final List<dynamic> data = jsonDecode(responseBody);

//           // Clear old episode focus nodes for this season
//           _episodeFocusNodes.clear();

//           final episodes = data.map((e) => NewsItemModel.fromJson(e)).toList();

//           // Create focus nodes for episodes
//           for (var episode in episodes) {
//             _episodeFocusNodes[episode.id] = FocusNode();
//           }

//           setState(() {
//             _episodesMap[seasonId] = episodes;
//             _selectedSeasonIndex = _seasons.indexWhere((s) => s.id == seasonId);
//             _selectedEpisodeIndex = 0;
//             _isLoadingEpisodes = false;
//             _errorMessage = "";
//           });

//           _setInitialEpisodeFocus();
//         } else {
//           setState(() {
//             _isLoadingEpisodes = false;
//             _errorMessage = "Invalid episodes response format";
//           });
//         }
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         setState(() {
//           _isLoadingEpisodes = false;
//           _errorMessage = "Authentication failed. Please login again.";
//         });
//       } else {
//         setState(() {
//           _isLoadingEpisodes = false;
//           _errorMessage = "Failed to load episodes (${response.statusCode})";
//         });
//       }
//     } catch (e) {
//       print('❌ Error fetching episodes: $e');
//       setState(() {
//         _isLoadingEpisodes = false;
//         _errorMessage = "Error: ${e.toString()}";
//       });
//     }
//   }

//   void _setInitialEpisodeFocus() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_currentEpisodes.isNotEmpty) {
//         _scrollAndFocusEpisode(0);
//       }
//     });
//   }

//   Future<void> _scrollToEpisodeIndex(int index) async {
//     if (index < 0 || index >= _currentEpisodes.length) return;

//     final context = _episodeFocusNodes[_currentEpisodes[index].id]?.context;
//     if (context != null) {
//       await Scrollable.ensureVisible(
//         context,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         alignment: 0.35,
//       );
//     }
//   }

//   void _scrollAndFocusEpisode(int index) async {
//     await _scrollToEpisodeIndex(index);
//     if (mounted && index < _currentEpisodes.length) {
//       FocusScope.of(context).requestFocus(
//         _episodeFocusNodes[_currentEpisodes[index].id],
//       );
//     }
//   }

//   void _selectSeason(int index) {
//     if (index >= 0 && index < _seasons.length) {
//       setState(() {
//         _selectedSeasonIndex = index;
//       });
//       _fetchEpisodes(_seasons[index].id);
//     }
//   }

//   bool isYoutubeUrl(String? url) {
//     if (url == null || url.isEmpty) return false;
//     url = url.toLowerCase().trim();
//     return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url) ||
//            url.contains('youtube.com') ||
//            url.contains('youtu.be') ||
//            url.contains('youtube.com/shorts/');
//   }

//   Future<void> _playEpisode(NewsItemModel episode) async {
//     if (_isProcessing) return;

//     setState(() => _isProcessing = true);

//     try {
//       String url = episode.url;
//       print("Original URL: $url");

//       if (isYoutubeUrl(url)) {
//         try {
//           url = await _socketService.getUpdatedUrl(url)
//             .timeout(const Duration(seconds: 10), onTimeout: () => url);
//           print("Updated URL: $url");
//         } catch (e) {
//           print("Error updating URL: $e");
//         }
//       }

//       if (mounted) {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VideoScreen(
//               videoUrl: url,
//               unUpdatedUrl: episode.url,
//               channelList: _currentEpisodes,
//               bannerImageUrl: widget.banner,
//               startAtPosition: Duration.zero,
//               videoType: widget.source,
//               isLive: false,
//               isVOD: false,
//               isSearch: false,
//               isBannerSlider: false,
//               videoId: int.tryParse(episode.id),
//               source: 'webseries_details_page',
//               name: episode.name,
//               liveStatus: false,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       print("Error playing episode: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error playing video')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//       }
//     }
//   }

//   void _handleKeyEvent(RawKeyEvent event) {
//     if (_isProcessing) return;

//     if (event is RawKeyDownEvent) {
//       // If we're in seasons mode (no episodes loaded or episodes are loading)
//       if (_currentEpisodes.isEmpty || _isLoadingEpisodes) {
//         switch (event.logicalKey) {
//           case LogicalKeyboardKey.arrowDown:
//             if (_selectedSeasonIndex < _seasons.length - 1) {
//               final newIndex = _selectedSeasonIndex + 1;
//               _selectSeason(newIndex);
//               _seasonsFocusNodes[newIndex]?.requestFocus();
//             }
//             break;

//           case LogicalKeyboardKey.arrowUp:
//             if (_selectedSeasonIndex > 0) {
//               final newIndex = _selectedSeasonIndex - 1;
//               _selectSeason(newIndex);
//               _seasonsFocusNodes[newIndex]?.requestFocus();
//             }
//             break;

//           case LogicalKeyboardKey.enter:
//           case LogicalKeyboardKey.select:
//             if (_seasons.isNotEmpty) {
//               _fetchEpisodes(_seasons[_selectedSeasonIndex].id);
//             }
//             break;
//         }
//       } else {
//         // We're in episodes mode
//         final episodes = _currentEpisodes;
//         switch (event.logicalKey) {
//           case LogicalKeyboardKey.arrowDown:
//             if (_selectedEpisodeIndex < episodes.length - 1) {
//               final newIndex = _selectedEpisodeIndex + 1;
//               setState(() => _selectedEpisodeIndex = newIndex);
//               _scrollAndFocusEpisode(newIndex);
//             }
//             break;

//           case LogicalKeyboardKey.arrowUp:
//             if (_selectedEpisodeIndex > 0) {
//               final newIndex = _selectedEpisodeIndex - 1;
//               setState(() => _selectedEpisodeIndex = newIndex);
//               _scrollAndFocusEpisode(newIndex);
//             }
//             break;

//           case LogicalKeyboardKey.arrowLeft:
//             // Go back to seasons selection
//             setState(() {
//               _selectedEpisodeIndex = 0;
//             });
//             _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
//             break;

//           case LogicalKeyboardKey.enter:
//           case LogicalKeyboardKey.select:
//             _playEpisode(episodes[_selectedEpisodeIndex]);
//             break;
//         }
//       }
//     }
//   }

//   List<NewsItemModel> get _currentEpisodes {
//     if (_seasons.isEmpty || _selectedSeasonIndex >= _seasons.length) {
//       return [];
//     }
//     return _episodesMap[_seasons[_selectedSeasonIndex].id] ?? [];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: RawKeyboardListener(
//         focusNode: _mainFocusNode,
//         autofocus: true,
//         onKey: _handleKeyEvent,
//         child: Stack(
//           children: [
//             // Background Image
//             Positioned.fill(
//               child: Image.network(
//                 widget.banner,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => Container(color: Colors.black),
//               ),
//             ),

//             // Gradient Overlay
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.black.withOpacity(0.3),
//                       Colors.black.withOpacity(0.7),
//                       Colors.black,
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//               ),
//             ),

//             // Main Content
//             if (_isLoading && _seasons.isEmpty)
//               Center(child: LoadingIndicator())
//             else if (_errorMessage.isNotEmpty && _seasons.isEmpty)
//               Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error_outline, color: Colors.red, size: 60),
//                     SizedBox(height: 20),
//                     Text(
//                       _errorMessage,
//                       style: TextStyle(color: Colors.white, fontSize: 18),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: () => _loadAuthKey(),
//                       child: Text('Retry'),
//                     ),
//                   ],
//                 ),
//               )
//             else
//               _buildContent(),

//             // Processing Overlay
//             if (_isProcessing)
//               Container(
//                 color: Colors.black54,
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
//                       ),
//                       SizedBox(height: 20),
//                       Text(
//                         'Loading video...',
//                         style: TextStyle(color: Colors.white, fontSize: 18),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContent() {
//     return Row(
//       children: [
//         // Left side - Seasons List
//         Container(
//           width: MediaQuery.of(context).size.width * 0.3,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: MediaQuery.of(context).size.height * 0.1),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Text(
//                   "SEASONS",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),
//               Expanded(
//                 child: _buildSeasonsList(),
//               ),
//             ],
//           ),
//         ),

//         // Right side - Episodes List
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: MediaQuery.of(context).size.height * 0.1),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Text(
//                   "EPISODES",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),
//               Expanded(
//                 child: _isLoadingEpisodes
//                     ? Center(child: LoadingIndicator())
//                     : _buildEpisodesList(),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSeasonsList() {
//     return ListView.builder(
//       controller: _seasonsScrollController,
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       itemCount: _seasons.length,
//       itemBuilder: (context, index) => _buildSeasonItem(index),
//     );
//   }

//   Widget _buildSeasonItem(int index) {
//     final season = _seasons[index];
//     final isSelected = index == _selectedSeasonIndex;

//     return Focus(
//       focusNode: _seasonsFocusNodes[index],
//       onFocusChange: (hasFocus) {
//         if (hasFocus && _selectedSeasonIndex != index) {
//           setState(() => _selectedSeasonIndex = index);
//         }
//       },
//       child: GestureDetector(
//         onTap: () {
//           _selectSeason(index);
//           _seasonsFocusNodes[index]?.requestFocus();
//         },
//         child: Container(
//           margin: EdgeInsets.symmetric(vertical: 8),
//           padding: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? highlightColor.withOpacity(0.3)
//                 : Colors.grey[900]?.withOpacity(0.6),
//             borderRadius: BorderRadius.circular(8),
//             border: isSelected
//                 ? Border.all(color: highlightColor, width: 2)
//                 : null,
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: isSelected ? highlightColor : Colors.grey[700],
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${season.seasonOrder}',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       season.sessionName,
//                       style: TextStyle(
//                         color: isSelected ? highlightColor : Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       'Season ${season.seasonOrder}',
//                       style: TextStyle(
//                         color: Colors.grey[400],
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (isSelected)
//                 Icon(
//                   Icons.arrow_forward_ios,
//                   color: highlightColor,
//                   size: 16,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEpisodesList() {
//     final episodes = _currentEpisodes;

//     if (episodes.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.video_library_outlined,
//               color: Colors.grey[600],
//               size: 64,
//             ),
//             SizedBox(height: 16),
//             Text(
//               "No episodes available",
//               style: TextStyle(
//                 color: Colors.grey[400],
//                 fontSize: 18,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "Select a season to view episodes",
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       controller: _scrollController,
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       itemCount: episodes.length,
//       itemBuilder: (context, index) => _buildEpisodeItem(index),
//     );
//   }

//   Widget _buildEpisodeItem(int index) {
//     final episode = _currentEpisodes[index];
//     final isSelected = index == _selectedEpisodeIndex;
//     final isProcessing = _isProcessing && isSelected;

//     return Focus(
//       focusNode: _episodeFocusNodes[episode.id],
//       onFocusChange: (hasFocus) {
//         if (hasFocus && _selectedEpisodeIndex != index) {
//           setState(() => _selectedEpisodeIndex = index);
//         }
//       },
//       child: GestureDetector(
//         onTap: () {
//           if (!_isProcessing) {
//             setState(() => _selectedEpisodeIndex = index);
//             _playEpisode(episode);
//           }
//         },
//         child: Container(
//           margin: EdgeInsets.symmetric(vertical: 8),
//           decoration: BoxDecoration(
//             color: Colors.grey[900]?.withOpacity(0.8),
//             borderRadius: BorderRadius.circular(8),
//             border: isSelected
//                 ? Border.all(color: highlightColor, width: 2)
//                 : null,
//           ),
//           child: Row(
//             children: [
//               // Thumbnail
//               Container(
//                 margin: EdgeInsets.all(8),
//                 width: 120,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(6),
//                       child: Image.network(
//                         widget.banner,
//                         fit: BoxFit.cover,
//                         width: 120,
//                         height: 80,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             width: 120,
//                             height: 80,
//                             color: Colors.grey[800],
//                             child: Center(
//                               child: Text(
//                                 "EP ${index + 1}",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     if (isProcessing)
//                       CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                   ],
//                 ),
//               ),

//               // Episode Info
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         episode.name,
//                         style: TextStyle(
//                           color: isSelected ? highlightColor : Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       if (episode.description.isNotEmpty) ...[
//                         SizedBox(height: 4),
//                         Text(
//                           episode.description,
//                           style: TextStyle(
//                             color: Colors.grey[400],
//                             fontSize: 12,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),

//               // Play Icon
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: isProcessing
//                     ? SizedBox(
//                         width: 24,
//                         height: 24,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(highlightColor),
//                         ),
//                       )
//                     : Icon(
//                         Icons.play_circle_outline,
//                         color: isSelected ? highlightColor : Colors.white,
//                         size: 32,
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class LoadingIndicator extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SpinKitFadingCircle(
//           color: Colors.white,
//           size: 50.0,
//         ),
//         SizedBox(height: 20),
//         Text(
//           'Loading...',
//           style: TextStyle(color: Colors.white),
//         ),
//       ],
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
import '../../video_widget/socket_service.dart';

enum NavigationMode {
  seasons,
  episodes,
}

class SeasonModel {
  final int id;
  final String sessionName;
  final String banner;
  final int seasonOrder;
  final int webSeriesId;
  final int status;

  SeasonModel({
    required this.id,
    required this.sessionName,
    required this.banner,
    required this.seasonOrder,
    required this.webSeriesId,
    required this.status,
  });

  factory SeasonModel.fromJson(Map<String, dynamic> json) {
    return SeasonModel(
      id: json['id'] ?? 0,
      sessionName: json['Session_Name'] ?? '',
      banner: json['banner'] ?? '',
      seasonOrder: json['season_order'] ?? 1,
      webSeriesId: json['web_series_id'] ?? 0,
      status: json['status'] ?? 1,
    );
  }
}

class WebSeriesDetailsPage extends StatefulWidget {
  final int id;
  final List<NewsItemModel> channelList;
  final String source;
  final String banner;
  final String name;

  const WebSeriesDetailsPage({
    Key? key,
    required this.id,
    required this.channelList,
    required this.source,
    required this.banner,
    required this.name,
  }) : super(key: key);

  @override
  _WebSeriesDetailsPageState createState() => _WebSeriesDetailsPageState();
}

class _WebSeriesDetailsPageState extends State<WebSeriesDetailsPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final SocketService _socketService = SocketService();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _seasonsScrollController = ScrollController();
  final FocusNode _mainFocusNode = FocusNode();

  // Animation Controllers
  late AnimationController _navigationModeController;
  late AnimationController _instructionController;
  late AnimationController _pageTransitionController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  bool _isProcessing = false;
  bool _isLoadingEpisodes = false;

  List<SeasonModel> _seasons = [];
  Map<int, List<NewsItemModel>> _episodesMap = {};

  int _selectedSeasonIndex = 0;
  int _selectedEpisodeIndex = 0;

  NavigationMode _currentMode = NavigationMode.seasons;

  final Map<int, FocusNode> _seasonsFocusNodes = {};
  final Map<String, FocusNode> _episodeFocusNodes = {};

  String _errorMessage = "";
  String _authKey = '';

  bool _showInstructions = true;
  Timer? _instructionTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _socketService.initSocket();

    _initializeAnimations();
    _loadAuthKey();
    _startInstructionTimer();
  }

  void _initializeAnimations() {
    _navigationModeController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _instructionController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _pageTransitionController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _seasonsScrollController.dispose();
    _mainFocusNode.dispose();
    _seasonsFocusNodes.values.forEach((node) => node.dispose());
    _episodeFocusNodes.values.forEach((node) => node.dispose());
    _socketService.dispose();
    _navigationModeController.dispose();
    _instructionController.dispose();
    _pageTransitionController.dispose();
    _instructionTimer?.cancel();
    super.dispose();
  }

  void _startInstructionTimer() {
    _instructionController.forward();
    _instructionTimer = Timer(Duration(seconds: 6), () {
      if (mounted) {
        _instructionController.reverse();
        setState(() {
          _showInstructions = false;
        });
      }
    });
  }

  void _showInstructionsAgain() {
    setState(() {
      _showInstructions = true;
    });
    _instructionController.forward();
    _startInstructionTimer();
  }

  Future<void> _loadAuthKey() async {
    await AuthManager.initialize();
    setState(() {
      _authKey = AuthManager.authKey;
      if (_authKey.isEmpty) {
        _authKey = globalAuthKey;
      }
    });

    if (_authKey.isEmpty) {
      setState(() {
        _errorMessage = "Authentication required. Please login again.";
        _isLoading = false;
      });
      return;
    }

    _initializePage();
  }

  Future<void> _initializePage() async {
    await _fetchSeasons();
    if (_seasons.isNotEmpty) {
      _setNavigationMode(NavigationMode.seasons);
      _pageTransitionController.forward();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_mainFocusNode);
    });
  }

  void _setNavigationMode(NavigationMode mode) {
    setState(() {
      _currentMode = mode;
    });

    if (mode == NavigationMode.seasons) {
      _navigationModeController.reverse();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
      });
    } else {
      _navigationModeController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentEpisodes.isNotEmpty) {
          _episodeFocusNodes[_currentEpisodes[_selectedEpisodeIndex].id]
              ?.requestFocus();
        }
      });
    }
  }

  Future<void> _fetchSeasons() async {
    if (_authKey.isEmpty) {
      setState(() {
        _errorMessage = "No authentication key available";
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "Loading seasons...";
    });

    try {
      final response = await https.get(
        Uri.parse(
            'https://acomtv.coretechinfo.com/public/api/getSeasons/${widget.id}'),
        headers: {
          'auth-key': _authKey,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();
        if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
          final List<dynamic> data = jsonDecode(responseBody);

          _seasonsFocusNodes.clear();

          setState(() {
            _seasons =
                data.map((season) => SeasonModel.fromJson(season)).toList();
            _isLoading = false;
            _errorMessage = "";
          });

          for (int i = 0; i < _seasons.length; i++) {
            _seasonsFocusNodes[i] = FocusNode();
          }

          if (_seasons.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _seasonsFocusNodes[0]?.requestFocus();
              }
            });
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = "Invalid response format from server";
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load seasons (${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  Future<void> _fetchEpisodes(int seasonId) async {
    if (_episodesMap.containsKey(seasonId)) {
      setState(() {
        _selectedSeasonIndex =
            _seasons.indexWhere((season) => season.id == seasonId);
        _selectedEpisodeIndex = 0;
      });
      _setNavigationMode(NavigationMode.episodes);
      return;
    }

    setState(() {
      _isLoadingEpisodes = true;
    });

    try {
      final response = await https.get(
        Uri.parse(
            'https://acomtv.coretechinfo.com/public/api/getEpisodes/$seasonId/0'),
        headers: {
          'auth-key': _authKey,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();
        if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
          final List<dynamic> data = jsonDecode(responseBody);

          _episodeFocusNodes.clear();

          final episodes = data.map((e) => NewsItemModel.fromJson(e)).toList();

          for (var episode in episodes) {
            _episodeFocusNodes[episode.id] = FocusNode();
          }

          setState(() {
            _episodesMap[seasonId] = episodes;
            _selectedSeasonIndex = _seasons.indexWhere((s) => s.id == seasonId);
            _selectedEpisodeIndex = 0;
            _isLoadingEpisodes = false;
          });

          _setNavigationMode(NavigationMode.episodes);
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingEpisodes = false;
        _errorMessage = "Error loading episodes: ${e.toString()}";
      });
    }
  }

  void _selectSeason(int index) {
    if (index >= 0 && index < _seasons.length) {
      setState(() {
        _selectedSeasonIndex = index;
      });
      _fetchEpisodes(_seasons[index].id);
    }
  }

  Future<void> _playEpisode(NewsItemModel episode) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      String url = episode.url;

      if (isYoutubeUrl(url)) {
        try {
          url = await _socketService
              .getUpdatedUrl(url)
              .timeout(const Duration(seconds: 10), onTimeout: () => url);
        } catch (e) {
          print("Error updating URL: $e");
        }
      }

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScreen(
              videoUrl: url,
              unUpdatedUrl: episode.url,
              channelList: _currentEpisodes,
              bannerImageUrl: widget.banner,
              startAtPosition: Duration.zero,
              videoType: widget.source,
              isLive: false,
              isVOD: false,
              isSearch: false,
              isBannerSlider: false,
              videoId: int.tryParse(episode.id),
              source: 'webseries_details_page',
              name: episode.name,
              liveStatus: false,
              seasonId:_seasons[_selectedSeasonIndex].id,
              isLastPlayedStored:false,

            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing video'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  bool isYoutubeUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    url = url.toLowerCase().trim();
    return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url) ||
        url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        url.contains('youtube.com/shorts/');
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (_isProcessing) return;

    if (event is RawKeyDownEvent) {
      switch (_currentMode) {
        case NavigationMode.seasons:
          _handleSeasonsNavigation(event);
          break;
        case NavigationMode.episodes:
          _handleEpisodesNavigation(event);
          break;
      }
    }
  }

  void _handleSeasonsNavigation(RawKeyEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        if (_selectedSeasonIndex < _seasons.length - 1) {
          setState(() {
            _selectedSeasonIndex++;
          });
          _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
        }
        break;

      case LogicalKeyboardKey.arrowUp:
        if (_selectedSeasonIndex > 0) {
          setState(() {
            _selectedSeasonIndex--;
          });
          _seasonsFocusNodes[_selectedSeasonIndex]?.requestFocus();
        }
        break;

      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.arrowRight:
        if (_seasons.isNotEmpty) {
          _selectSeason(_selectedSeasonIndex);
        }
        break;

      case LogicalKeyboardKey.escape:
      case LogicalKeyboardKey.goBack:
        Navigator.pop(context);
        break;
    }
  }

  void _handleEpisodesNavigation(RawKeyEvent event) {
    final episodes = _currentEpisodes;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        if (_selectedEpisodeIndex < episodes.length - 1) {
          setState(() {
            _selectedEpisodeIndex++;
          });
          _scrollAndFocusEpisode(_selectedEpisodeIndex);
        }
        break;

      case LogicalKeyboardKey.arrowUp:
        if (_selectedEpisodeIndex > 0) {
          setState(() {
            _selectedEpisodeIndex--;
          });
          _scrollAndFocusEpisode(_selectedEpisodeIndex);
        }
        break;

      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.select:
        if (episodes.isNotEmpty) {
          _playEpisode(episodes[_selectedEpisodeIndex]);
        }
        break;

      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.escape:
        _setNavigationMode(NavigationMode.seasons);
        break;

      case LogicalKeyboardKey.goBack:
        Navigator.pop(context);
        break;
    }
  }

  Future<void> _scrollAndFocusEpisode(int index) async {
    if (index < 0 || index >= _currentEpisodes.length) return;

    final context = _episodeFocusNodes[_currentEpisodes[index].id]?.context;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    }
  }

  List<NewsItemModel> get _currentEpisodes {
    if (_seasons.isEmpty || _selectedSeasonIndex >= _seasons.length) {
      return [];
    }
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
            // 🎨 Beautiful Background
            _buildBackgroundLayer(),

            // 📱 Main Content with proper spacing
            _buildMainContentWithLayout(),

            // 🎯 Top Navigation Bar (Fixed Position)
            _buildTopNavigationBar(),

            // ❓ Help Button (Fixed Position)
            _buildHelpButton(),

            // 📋 Instructions Overlay (Bottom)
            if (_showInstructions) _buildInstructionsOverlay(),

            // ⏳ Processing Overlay
            if (_isProcessing) _buildProcessingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundLayer() {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.network(
            widget.banner,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f0f23),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),

        // Gradient Overlays for better readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Side gradients for better separation
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopNavigationBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // Current Mode Indicator
                AnimatedBuilder(
                  animation: _navigationModeController,
                  builder: (context, child) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: _currentMode == NavigationMode.seasons
                              ? Colors.blue
                              : Colors.green,
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_currentMode == NavigationMode.seasons
                                    ? Colors.blue
                                    : Colors.green)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _currentMode == NavigationMode.seasons
                                ? Icons.list_alt
                                : Icons.play_circle_outline,
                            color: _currentMode == NavigationMode.seasons
                                ? Colors.blue
                                : Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            _currentMode == NavigationMode.seasons
                                ? 'BROWSING SEASONS'
                                : 'BROWSING EPISODES',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                Spacer(),

                // Series Title
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      widget.name.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpButton() {
    return Positioned(
      top: 50,
      right: 20,
      child: SafeArea(
        child: GestureDetector(
          onTap: _showInstructionsAgain,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(25),
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'HELP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContentWithLayout() {
    return Positioned(
      top: 100, // Below navigation bar
      left: 0,
      right: 0,
      bottom: 80, // Above instructions
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading && _seasons.isEmpty) {
      return _buildLoadingWidget();
    }

    if (_errorMessage.isNotEmpty && _seasons.isEmpty) {
      return _buildErrorWidget();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel - Seasons
          Expanded(
            flex: 2,
            child: _buildSeasonsPanel(),
          ),

          SizedBox(width: 20),

          // Right Panel - Episodes
          Expanded(
            flex: 3,
            child: _buildEpisodesPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _currentMode == NavigationMode.seasons
              ? Colors.blue.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.2),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.list_alt,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "SEASONS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_seasons.length}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Seasons List
          Expanded(
            child: _buildSeasonsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _currentMode == NavigationMode.episodes
              ? Colors.green.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.2),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "EPISODES",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (_seasons.isNotEmpty &&
                        _selectedSeasonIndex < _seasons.length)
                      Text(
                        _seasons[_selectedSeasonIndex].sessionName,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentEpisodes.length}',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Episodes List
          Expanded(
            child: _isLoadingEpisodes
                ? _buildLoadingWidget()
                : _buildEpisodesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonsList() {
    return ListView.builder(
      controller: _seasonsScrollController,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _seasons.length,
      itemBuilder: (context, index) => _buildSeasonItem(index),
    );
  }

  Widget _buildSeasonItem(int index) {
    final season = _seasons[index];
    final isSelected = index == _selectedSeasonIndex;
    final isFocused = _currentMode == NavigationMode.seasons && isSelected;
    final episodeCount = _episodesMap[season.id]?.length ?? 0;

    return Focus(
      focusNode: _seasonsFocusNodes[index],
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isFocused
              ? LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.3),
                    Colors.blue.withOpacity(0.1),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
          color: !isFocused && !isSelected
              ? Colors.grey[900]?.withOpacity(0.4)
              : null,
          borderRadius: BorderRadius.circular(12),
          border: isFocused
              ? Border.all(color: Colors.blue, width: 2)
              : isSelected
                  ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                  : null,
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            // Season Number with beautiful styling
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isFocused
                      ? [Colors.blue, Colors.blue.shade300]
                      : [Colors.grey[700]!, Colors.grey[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: (isFocused ? Colors.blue : Colors.grey[700]!)
                        .withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Center(
                child: Image.network(
                  season.banner,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                        // gradient: LinearGradient(
                        //   colors: [
                        //     Color(0xFF1a1a2e),
                        //     Color(0xFF16213e),
                        //     Color(0xFF0f0f23),
                        //   ],
                        //   begin: Alignment.topLeft,
                        //   end: Alignment.bottomRight,
                        ),
                  ),
                ),
              ),

              // Text(
              //   '${season.banner}',
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontWeight: FontWeight.bold,
              //     fontSize: 18,
              //   ),
              // ),
              // ),
            ),

            SizedBox(width: 16),

            // Season Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    season.sessionName,
                    style: TextStyle(
                      color: isFocused ? Colors.blue : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFocused
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.grey[700]?.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Season ${season.seasonOrder}',
                          style: TextStyle(
                            color: isFocused ? Colors.blue : Colors.grey[300],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (episodeCount > 0) ...[
                        SizedBox(width: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$episodeCount episodes',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Arrow indicator with animation
            AnimatedRotation(
              turns: isFocused ? 0.0 : -0.25,
              duration: Duration(milliseconds: 300),
              child: Icon(
                Icons.chevron_right,
                color: isFocused ? Colors.blue : Colors.grey[600],
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodesList() {
    final episodes = _currentEpisodes;

    if (episodes.isEmpty) {
      return _buildEmptyEpisodesState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: episodes.length,
      itemBuilder: (context, index) => _buildEpisodeItem(index),
    );
  }

  Widget _buildEmptyEpisodesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[800]?.withOpacity(0.3),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.video_library_outlined,
              color: Colors.grey[500],
              size: 64,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "No Episodes Available",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Select a season to view episodes",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          if (_currentMode == NavigationMode.seasons) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Text(
                "Press → or ENTER to select season",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEpisodeItem(int index) {
    final episode = _currentEpisodes[index];
    final isSelected = index == _selectedEpisodeIndex;
    final isFocused = _currentMode == NavigationMode.episodes && isSelected;
    final isProcessing = _isProcessing && isSelected;

    return Focus(
      focusNode: _episodeFocusNodes[episode.id],
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: isFocused
              ? LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.3),
                    Colors.green.withOpacity(0.1),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
          color: !isFocused && !isSelected
              ? Colors.grey[900]?.withOpacity(0.4)
              : null,
          borderRadius: BorderRadius.circular(16),
          border: isFocused
              ? Border.all(color: Colors.green, width: 2)
              : isSelected
                  ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                  : null,
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            // Enhanced Thumbnail
            Container(
              margin: EdgeInsets.all(12),
              width: 140,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      episode.banner,
                      fit: BoxFit.cover,
                      width: 140,
                      height: 90,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 140,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey[800]!,
                                Colors.grey[700]!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.video_library,
                                  color: Colors.grey[400],
                                  size: 28,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "EP ${index + 1}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Play/Loading overlay with beautiful animations
                  if (isProcessing)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: SpinKitRing(
                        color: Colors.green,
                        size: 30,
                        lineWidth: 3,
                      ),
                    )
                  else if (isFocused)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.green.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 28,
                      ),
                    )
                  else if (isSelected)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),

            // Episode Information
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Episode Title
                    Text(
                      episode.name,
                      style: TextStyle(
                        color: isFocused ? Colors.green : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8),

                    // Episode Description
                    if (episode.description.isNotEmpty)
                      Text(
                        episode.description,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                    SizedBox(height: 12),

                    // Episode Metadata
                    Row(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isFocused
                                  ? [
                                      Colors.green.withOpacity(0.3),
                                      Colors.green.withOpacity(0.1)
                                    ]
                                  : [
                                      Colors.grey[700]!.withOpacity(0.5),
                                      Colors.grey[800]!.withOpacity(0.3)
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isFocused
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.grey[600]!.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Episode ${index + 1}',
                            style: TextStyle(
                              color:
                                  isFocused ? Colors.green : Colors.grey[300],
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        if (isFocused)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'READY TO PLAY',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Action Button Area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: isFocused ? 1.2 : 1.0,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isFocused
                              ? [Colors.green, Colors.green.shade400]
                              : isSelected
                                  ? [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.1)
                                    ]
                                  : [Colors.grey[700]!, Colors.grey[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.5),
                                  blurRadius: 12,
                                  spreadRadius: 3,
                                )
                              ]
                            : null,
                      ),
                      child: isProcessing
                          ? SpinKitRing(
                              color: Colors.white,
                              size: 24,
                              lineWidth: 2,
                            )
                          : Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                    ),
                  ),
                  if (isFocused) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PRESS ENTER',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _instructionController,
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.95),
                Colors.black.withOpacity(0.85),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: highlightColor.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: highlightColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gamepad, color: highlightColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'NAVIGATION GUIDE',
                    style: TextStyle(
                      color: highlightColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (_currentMode == NavigationMode.seasons) ...[
                    _buildInstructionItem(
                        '↑ ↓', 'Navigate Seasons', Icons.list_alt),
                    _buildInstructionItem(
                        '→ ENTER', 'Select Season', Icons.chevron_right),
                    _buildInstructionItem('← BACK', 'Exit', Icons.exit_to_app),
                  ] else ...[
                    _buildInstructionItem(
                        '↑ ↓', 'Navigate Episodes', Icons.video_library),
                    _buildInstructionItem(
                        'ENTER', 'Play Episode', Icons.play_arrow),
                    _buildInstructionItem(
                        '← BACK', 'Back to Seasons', Icons.arrow_back),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String keys, String action, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                highlightColor.withOpacity(0.3),
                highlightColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: highlightColor.withOpacity(0.5)),
          ),
          child: Text(
            keys,
            style: TextStyle(
              color: highlightColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(height: 6),
        Icon(icon, color: Colors.white70, size: 16),
        SizedBox(height: 4),
        Text(
          action,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: highlightColor,
            size: 60.0,
          ),
          SizedBox(height: 20),
          Text(
            'Loading...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.5), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _loadAuthKey(),
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: highlightColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: highlightColor.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitPulse(
                color: highlightColor,
                size: 80,
              ),
              SizedBox(height: 24),
              Text(
                'Loading Video...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please wait',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      color: highlightColor,
      size: 50.0,
    );
  }
}
