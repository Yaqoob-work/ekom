





// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import '../../video_widget/socket_service.dart';

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
//   final FocusNode _mainFocusNode = FocusNode();
//   bool _isLoading = true;
//   bool _isProcessing = false;
//   List<NewsItemModel> _seasons = [];
//   Map<String, List<NewsItemModel>> _episodesMap = {};
//   int _selectedSeasonIndex = 0;
//   int _selectedEpisodeIndex = 0;
//   final Map<String, FocusNode> _episodeFocusNodes = {};
//   String _errorMessage = "";

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _socketService.initSocket();
//     _initializePage();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _scrollController.dispose();
//     _mainFocusNode.dispose();
//     _episodeFocusNodes.values.forEach((node) => node.dispose());
//     _socketService.dispose();
//     super.dispose();
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
//     setState(() {
//       _isLoading = true;
//       _errorMessage = "Loading seasons...";
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getSeasons/${widget.id}'),
//         headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
//       ).timeout(const Duration(seconds: 15));

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           _seasons = data.map((season) => NewsItemModel.fromJson(season)).toList();
//           _isLoading = false;
//           _errorMessage = "";
//         });
//       } else {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = "Failed to load seasons";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = "Error: ${e.toString()}";
//       });
//     }
//   }

//   Future<void> _fetchEpisodes(String seasonId) async {
//     if (_episodesMap.containsKey(seasonId)) {
//       setState(() {
//         _selectedSeasonIndex = _seasons.indexWhere((season) => season.id == seasonId);
//         _selectedEpisodeIndex = 0;
//       });
//       _setInitialFocus();
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = "Loading episodes...";
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getEpisodes/$seasonId/0'),
//         headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
//       ).timeout(const Duration(seconds: 15));

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         _episodeFocusNodes.clear();

//         final episodes = data.map((e) => NewsItemModel.fromJson(e)).toList();
//         for (var episode in episodes) {
//           _episodeFocusNodes[episode.id] = FocusNode();
//         }

//         setState(() {
//           _episodesMap[seasonId] = episodes;
//           _selectedSeasonIndex = _seasons.indexWhere((s) => s.id == seasonId);
//           _selectedEpisodeIndex = 0;
//           _isLoading = false;
//           _errorMessage = "";
//         });
//         _setInitialFocus();
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = "Error: ${e.toString()}";
//       });
//     }
//   }


  

//   void _setInitialFocus() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_currentEpisodes.isNotEmpty) {
//         _scrollAndFocus(0);
//       }
//     });
//   }

//   Future<void> _scrollToIndex(int index) async {
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

//   void _scrollAndFocus(int index) async {
//     await _scrollToIndex(index);
//     if (mounted && index < _currentEpisodes.length) {
//       FocusScope.of(context).requestFocus(
//         _episodeFocusNodes[_currentEpisodes[index].id],
//       );
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
//     final episodes = _currentEpisodes;
//     if (episodes.isEmpty || _isProcessing) return;

//     if (event is RawKeyDownEvent) {
//       switch (event.logicalKey) {
//         case LogicalKeyboardKey.arrowDown:
//           if (_selectedEpisodeIndex < episodes.length - 1) {
//             final newIndex = _selectedEpisodeIndex + 1;
//             setState(() => _selectedEpisodeIndex = newIndex);
//             _scrollAndFocus(newIndex);
//           }
//           break;

//         case LogicalKeyboardKey.arrowUp:
//           if (_selectedEpisodeIndex > 0) {
//             final newIndex = _selectedEpisodeIndex - 1;
//             setState(() => _selectedEpisodeIndex = newIndex);
//             _scrollAndFocus(newIndex);
//           }
//           break;

//         case LogicalKeyboardKey.enter:
//         case LogicalKeyboardKey.select:
//           _playEpisode(episodes[_selectedEpisodeIndex]);
//           break;
//         default:
//           break;
//       }
//     }
//   }

//   List<NewsItemModel> get _currentEpisodes =>
//       _episodesMap[_seasons[_selectedSeasonIndex].id] ?? [];

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

//   // Widget _buildContent() {
//   //   return SingleChildScrollView(
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         SizedBox(height: MediaQuery.of(context).size.height * 0.12),
          
//   //         // Episodes Section
//   //         Padding(
//   //           padding: const EdgeInsets.symmetric(horizontal: 16),
//   //           child: Text(
//   //             "EPISODES",
//   //             style: TextStyle(
//   //               color: Colors.white,
//   //               fontSize: Headingtextsz * 1.5,
//   //               fontWeight: FontWeight.bold,
//   //             ),
//   //           ),
//   //         ),
          
//   //         SizedBox(height: 8),
          
//   //         if (_seasons.isNotEmpty)
//   //           _buildEpisodesListView(),
//   //       ],
//   //     ),
//   //   );
//   // }



// Widget _buildContent() {
//   return Stack(
//     children: [
//       // Background content
//       Positioned.fill(
//         child: Container(),
//       ),
      
//       // Right-aligned episodes list with scroll
//       Positioned(
//         right: 0,
//         top: MediaQuery.of(context).size.height * 0,
//         bottom: 0,
//         width: MediaQuery.of(context).size.width * 0.5,
//         child: SingleChildScrollView(
//           controller: _scrollController,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Episodes Section Title
//               // Padding(
//               //   padding: const EdgeInsets.symmetric(horizontal: 16),
//               //   child: Text(
//               //     "EPISODES",
//               //     style: TextStyle(
//               //       color: Colors.white,
//               //       fontSize: Headingtextsz * 1.5,
//               //       fontWeight: FontWeight.bold,
//               //     ),
//               //   ),
//               // ),
              
//               SizedBox(height: 8),
              
//               // Episodes List
//               if (_seasons.isNotEmpty)
//                 _buildEpisodesListView(),
//             ],
//           ),
//         ),
//       ),
//     ],
//   );
// }

// Widget _buildEpisodesListView() {
//   final episodes = _currentEpisodes;
  
//   if (episodes.isEmpty) {
//     return Container(
//       height: 100,
//       child: Center(
//         child: Text(
//           "...",
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }

//   return ListView.builder(
//     key: PageStorageKey('episodes-list-${_seasons[_selectedSeasonIndex].id}'),
//     padding: EdgeInsets.only(bottom: 40),
//     shrinkWrap: true, // Important for nested ListView
//     physics: NeverScrollableScrollPhysics(), // Disable inner scrolling
//     itemCount: episodes.length,
//     itemBuilder: (context, index) => _buildEpisodeItem(index),
//   );
// }

//   // Widget _buildEpisodesListView() {
//   //   final episodes = _currentEpisodes;
    
//   //   if (episodes.isEmpty) {
//   //     return Container(
//   //       height: 100,
//   //       child: Center(
//   //         child: Text(
//   //           "No episodes available",
//   //           style: TextStyle(color: Colors.white),
//   //         ),
//   //       ),
//   //     );
//   //   }

//   //   return ListView.builder(
//   //     key: PageStorageKey('episodes-list-${_seasons[_selectedSeasonIndex].id}'),
//   //     padding: EdgeInsets.symmetric(horizontal: 16),
//   //     shrinkWrap: true,
//   //     physics: NeverScrollableScrollPhysics(),
//   //     itemCount: episodes.length,
//   //     itemBuilder: (context, index) => _buildEpisodeItem(index),
//   //   );
//   // }


// //   Widget _buildEpisodesListView() {
// //   final episodes = _currentEpisodes;
  
// //   if (episodes.isEmpty) {
// //     return Container(
// //       height: 100,
// //       child: Center(
// //         child: Text(
// //           "No episodes available",
// //           style: TextStyle(color: Colors.white),
// //         ),
// //       ),
// //     );
// //   }

// //   return ListView.builder(
// //     key: PageStorageKey('episodes-list-${_seasons[_selectedSeasonIndex].id}'),
// //     padding: EdgeInsets.only(bottom: 40), // Removed horizontal padding
// //     shrinkWrap: true,
// //     physics: NeverScrollableScrollPhysics(),
// //     itemCount: episodes.length,
// //     itemBuilder: (context, index) => _buildEpisodeItem(index),
// //   );
// // }

//   Widget _buildEpisodeItem(int index) {
//     final episode = _currentEpisodes[index];
//     final isSelected = index == _selectedEpisodeIndex;
//     final isProcessing = _isProcessing && isSelected;

//     return FocusTraversalOrder(
//       order: NumericFocusOrder(index.toDouble()),
//       child: Focus(
//         focusNode: _episodeFocusNodes[episode.id],
//         onFocusChange: (hasFocus) {
//           if (hasFocus && _selectedEpisodeIndex != index) {
//             setState(() => _selectedEpisodeIndex = index);
//           }
//         },
//         child: GestureDetector(
//           onTap: () {
//             if (!_isProcessing) {
//               setState(() => _selectedEpisodeIndex = index);
//               _playEpisode(episode);
//             }
//           },
//           child: Container(
//             //  margin: EdgeInsets.symmetric(vertical: screenhgt * 0.01),
//             margin: EdgeInsets.symmetric(
//                 vertical: screenhgt * 0.01, horizontal: screenwdt * 0.05),
//             decoration: BoxDecoration(
//               color: Colors.grey[900]?.withOpacity(0.8),
//               borderRadius: BorderRadius.circular(8),
//               border: isSelected
//                   ? Border.all(color: highlightColor, width: 2)
//                   : null,
//             ),
//             child: Row(
//               children: [
//                 // Thumbnail
//                 Container(
//                   margin: EdgeInsets.all(5),
//                   width: 150,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(8),
//                       bottomLeft: Radius.circular(8),
//                     ),
//                   ),
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(8),
//                           bottomLeft: Radius.circular(8),
//                         ),
//                         child: Image.network(
//                           widget.banner,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               color: Colors.grey[800],
//                               child: Center(
//                                 child: Text(
//                                   "EP ${episode.order}",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       if (isProcessing)
//                         CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                     ],
//                   ),
//                 ),
                
//                 // Episode Info
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           episode.name,
//                           style: TextStyle(
//                             color: isSelected ? highlightColor : Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         if (episode.description.isNotEmpty) ...[
//                           SizedBox(height: 4),
//                           Text(
//                             episode.description,
//                             style: TextStyle(
//                               color: Colors.grey[400],
//                               fontSize: 12,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
                
//                 // Play Icon
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: isProcessing
//                       ? SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(highlightColor),
//                           ),
//                         )
//                       : Icon(
//                           Icons.play_circle_outline,
//                           color: isSelected ? highlightColor : Colors.white,
//                           size: 32,
//                         ),
//                 ),
//               ],
//             ),
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
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
import '../../video_widget/socket_service.dart';

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
    with WidgetsBindingObserver {
  final SocketService _socketService = SocketService();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _mainFocusNode = FocusNode();
  bool _isLoading = true;
  bool _isProcessing = false;
  List<NewsItemModel> _seasons = [];
  Map<String, List<NewsItemModel>> _episodesMap = {};
  int _selectedSeasonIndex = 0;
  int _selectedEpisodeIndex = 0;
  final Map<String, FocusNode> _episodeFocusNodes = {};
  String _errorMessage = "";
  
  // Add auth key variable
  String _authKey = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _socketService.initSocket();
    _loadAuthKey(); // Load auth key first
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _mainFocusNode.dispose();
    _episodeFocusNodes.values.forEach((node) => node.dispose());
    _socketService.dispose();
    super.dispose();
  }

  // Method to load auth key from AuthManager
  Future<void> _loadAuthKey() async {
    await AuthManager.initialize();
    setState(() {
      _authKey = AuthManager.authKey;
      // Also try global variable as fallback
      if (_authKey.isEmpty) {
        _authKey = globalAuthKey;
      }
    });
    
    print('🔑 WebSeriesDetailsPage - Auth key loaded: $_authKey');
    
    // If no auth key found, show error
    if (_authKey.isEmpty) {
      setState(() {
        _errorMessage = "Authentication required. Please login again.";
        _isLoading = false;
      });
      return;
    }
    
    // Now initialize the page with auth key
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _fetchSeasons();
    if (_seasons.isNotEmpty) {
      await _fetchEpisodes(_seasons.first.id);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_mainFocusNode);
    });
  }

  Future<void> _fetchSeasons() async {
    // Check if auth key is available
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
      final response = await http.get(
        Uri.parse('https://acomtv.coretechinfo.com/public/api/getSeasons/${widget.id}'),
        headers: {
          'auth-key': _authKey, // Use dynamic auth key instead of hard-coded
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('🌐 Seasons API Response Status: ${response.statusCode}');
      print('🌐 Seasons API Response Body (first 200 chars): ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');

      if (response.statusCode == 200) {
        // Check if response is valid JSON
        String responseBody = response.body.trim();
        if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
          final List<dynamic> data = jsonDecode(responseBody);
          setState(() {
            _seasons = data.map((season) => NewsItemModel.fromJson(season)).toList();
            _isLoading = false;
            _errorMessage = "";
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = "Invalid response format from server";
          });
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Authentication failed. Please login again.";
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load seasons (${response.statusCode})";
        });
      }
    } catch (e) {
      print('❌ Error fetching seasons: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  Future<void> _fetchEpisodes(String seasonId) async {
    if (_episodesMap.containsKey(seasonId)) {
      setState(() {
        _selectedSeasonIndex = _seasons.indexWhere((season) => season.id == seasonId);
        _selectedEpisodeIndex = 0;
      });
      _setInitialFocus();
      return;
    }

    // Check if auth key is available
    if (_authKey.isEmpty) {
      setState(() {
        _errorMessage = "No authentication key available";
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "Loading episodes...";
    });

    try {
      final response = await http.get(
        Uri.parse('https://acomtv.coretechinfo.com/public/api/getEpisodes/$seasonId/0'),
        headers: {
          'auth-key': _authKey, // Use dynamic auth key instead of hard-coded
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('🌐 Episodes API Response Status: ${response.statusCode}');
      print('🌐 Episodes API Response Body (first 200 chars): ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');

      if (response.statusCode == 200) {
        // Check if response is valid JSON
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
            _isLoading = false;
            _errorMessage = "";
          });
          _setInitialFocus();
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = "Invalid response format from server";
          });
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Authentication failed. Please login again.";
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load episodes (${response.statusCode})";
        });
      }
    } catch (e) {
      print('❌ Error fetching episodes: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  void _setInitialFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentEpisodes.isNotEmpty) {
        _scrollAndFocus(0);
      }
    });
  }

  Future<void> _scrollToIndex(int index) async {
    if (index < 0 || index >= _currentEpisodes.length) return;

    final context = _episodeFocusNodes[_currentEpisodes[index].id]?.context;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.35,
      );
    }
  }

  void _scrollAndFocus(int index) async {
    await _scrollToIndex(index);
    if (mounted && index < _currentEpisodes.length) {
      FocusScope.of(context).requestFocus(
        _episodeFocusNodes[_currentEpisodes[index].id],
      );
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

  Future<void> _playEpisode(NewsItemModel episode) async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);

    try {
      String url = episode.url;
      print("Original URL: $url");

      if (isYoutubeUrl(url)) {
        try {
          url = await _socketService.getUpdatedUrl(url)
            .timeout(const Duration(seconds: 10), onTimeout: () => url);
          print("Updated URL: $url");
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
            ),
          ),
        );
      }
    } catch (e) {
      print("Error playing episode: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing video')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    final episodes = _currentEpisodes;
    if (episodes.isEmpty || _isProcessing) return;

    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
          if (_selectedEpisodeIndex < episodes.length - 1) {
            final newIndex = _selectedEpisodeIndex + 1;
            setState(() => _selectedEpisodeIndex = newIndex);
            _scrollAndFocus(newIndex);
          }
          break;

        case LogicalKeyboardKey.arrowUp:
          if (_selectedEpisodeIndex > 0) {
            final newIndex = _selectedEpisodeIndex - 1;
            setState(() => _selectedEpisodeIndex = newIndex);
            _scrollAndFocus(newIndex);
          }
          break;

        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.select:
          _playEpisode(episodes[_selectedEpisodeIndex]);
          break;
        default:
          break;
      }
    }
  }

  List<NewsItemModel> get _currentEpisodes =>
      _episodesMap[_seasons[_selectedSeasonIndex].id] ?? [];

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
            // Background Image
            Positioned.fill(
              child: Image.network(
                widget.banner,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black),
              ),
            ),
            
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                      Colors.black,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            
            // Main Content
            if (_isLoading && _seasons.isEmpty)
              Center(child: LoadingIndicator())
            else if (_errorMessage.isNotEmpty && _seasons.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    SizedBox(height: 20),
                    Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _loadAuthKey(); // Retry loading
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              _buildContent(),
            
            // Processing Overlay
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Loading video...',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        // Background content
        Positioned.fill(
          child: Container(),
        ),
        
        // Right-aligned episodes list with scroll
        Positioned(
          right: 0,
          top: MediaQuery.of(context).size.height * 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.5,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                
                // Episodes List
                if (_seasons.isNotEmpty)
                  _buildEpisodesListView(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodesListView() {
    final episodes = _currentEpisodes;
    
    if (episodes.isEmpty) {
      return Container(
        height: 100,
        child: Center(
          child: Text(
            "...",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return ListView.builder(
      key: PageStorageKey('episodes-list-${_seasons[_selectedSeasonIndex].id}'),
      padding: EdgeInsets.only(bottom: 40),
      shrinkWrap: true, // Important for nested ListView
      physics: NeverScrollableScrollPhysics(), // Disable inner scrolling
      itemCount: episodes.length,
      itemBuilder: (context, index) => _buildEpisodeItem(index),
    );
  }

  Widget _buildEpisodeItem(int index) {
    final episode = _currentEpisodes[index];
    final isSelected = index == _selectedEpisodeIndex;
    final isProcessing = _isProcessing && isSelected;

    return FocusTraversalOrder(
      order: NumericFocusOrder(index.toDouble()),
      child: Focus(
        focusNode: _episodeFocusNodes[episode.id],
        onFocusChange: (hasFocus) {
          if (hasFocus && _selectedEpisodeIndex != index) {
            setState(() => _selectedEpisodeIndex = index);
          }
        },
        child: GestureDetector(
          onTap: () {
            if (!_isProcessing) {
              setState(() => _selectedEpisodeIndex = index);
              _playEpisode(episode);
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(
                vertical: screenhgt * 0.01, horizontal: screenwdt * 0.05),
            decoration: BoxDecoration(
              color: Colors.grey[900]?.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: highlightColor, width: 2)
                  : null,
            ),
            child: Row(
              children: [
                // Thumbnail
                Container(
                  margin: EdgeInsets.all(5),
                  width: 150,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        child: Image.network(
                          widget.banner,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: Center(
                                child: Text(
                                  "EP ${episode.order}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (isProcessing)
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                    ],
                  ),
                ),
                
                // Episode Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          episode.name,
                          style: TextStyle(
                            color: isSelected ? highlightColor : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (episode.description.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            episode.description,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Play Icon
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: isProcessing
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(highlightColor),
                          ),
                        )
                      : Icon(
                          Icons.play_circle_outline,
                          color: isSelected ? highlightColor : Colors.white,
                          size: 32,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitFadingCircle(
          color: Colors.white,
          size: 50.0,
        ),
        SizedBox(height: 20),
        Text(
          'Loading...',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}