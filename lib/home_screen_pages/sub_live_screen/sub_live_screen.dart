

// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:math';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:mobi_tv_entertainment/main.dart';
// // import 'package:mobi_tv_entertainment/home_screen_pages/sub_live_screen/news_grid_screen.dart';
// // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// // import 'package:mobi_tv_entertainment/provider/shared_data_provider.dart';
// // import 'package:mobi_tv_entertainment/video_widget/socket_service.dart';
// // import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// // import 'package:mobi_tv_entertainment/home_screen_pages/sub_live_screen/items/sub_live_item.dart';
// // import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// // import 'package:mobi_tv_entertainment/widgets/services/api_service.dart';
// // import 'package:mobi_tv_entertainment/widgets/small_widgets/empty_state.dart';
// // import 'package:mobi_tv_entertainment/widgets/small_widgets/error_message.dart';
// // import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../widgets/utils/random_light_color_widget.dart';
// // import 'channels_category.dart';

// // class SubLiveScreen extends StatefulWidget {
// //   final Function(bool)? onFocusChange; // Add this

// //   const SubLiveScreen(
// //       {Key? key, this.onFocusChange, required FocusNode focusNode})
// //       : super(key: key);
// //   @override
// //   _SubLiveScreenState createState() => _SubLiveScreenState();
// // }

// // class _SubLiveScreenState extends State<SubLiveScreen> {
// //   // final List<NewsItemModel> _musicList = [];
// //   Map<int, Color> _nodeColors = {};
// //   Map<String, FocusNode> newsItemFocusNodes = {};
// //   List<NewsItemModel> _musicList = [];
// //   final SocketService _socketService = SocketService();
// //   final ApiService _apiService = ApiService();
// //   bool _isLoading = true;
// //   String _errorMessage = '';
// //   bool _isNavigating = false;
// //   String _selectedCategory = 'Live'; // Default category
// //   int _maxRetries = 3;
// //   int _retryDelay = 5; // seconds
// //   final ScrollController _scrollController = ScrollController();

// //   final List<String> categories = [
// //     'Live',
// //     'Entertainment',
// //     'Music',
// //     'Movie',
// //     'News',
// //     'Sports',
// //     'Religious'
// //   ];

// //   Map<String, FocusNode> categoryFocusNodes = {};
// //   late FocusNode moreFocusNode;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _socketService.initSocket();
// //     fetchData();

// //     // // Add listeners to first category focus node
// //     // for (var category in categories) {
// //     //   categoryFocusNodes[category] = FocusNode()
// //     //     ..addListener(() {
// //     //       if (categoryFocusNodes[category]!.hasFocus) {
// //     //         widget.onFocusChange?.call(true);
// //     //       }
// //     //     });
// //     // }

// //     //     categories.forEach((category) {
// //     //   categoryFocusNodes[category] = FocusNode()
// //     //     ..addListener(() {
// //     //       if (categoryFocusNodes[category]!.hasFocus) {
// //     //         widget.onFocusChange?.call(true);
// //     //       }
// //     //     });
// //     // });

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       // Agar koi banner available nahi hai, tab category button focus set karein
// //       final firstCategoryNode = categoryFocusNodes[categories.first];
// //       if (firstCategoryNode != null) {
// //         context
// //             .read<FocusProvider>()
// //             .setFirstMusicItemFocusNode(firstCategoryNode);
// //       } else if (_musicList.isNotEmpty) {
// //         final firstItemId = _musicList[0].id;
// //         if (newsItemFocusNodes.containsKey(firstItemId)) {
// //           final focusNode = newsItemFocusNodes[firstItemId]!;
// //           context.read<FocusProvider>().setFirstMusicItemFocusNode(focusNode);
// //           //     "✅ MusicScreen: First music item focus node registered: $firstItemId");
// //         } else {
// //         }
// //       }
// //     });

// //     _loadCachedDataAndFetchMusic();
// //     _apiService.updateStream.listen((hasChanges) {
// //       if (hasChanges) {
// //         _loadCachedDataAndFetchMusic(); // Refetch data if changes occur
// //       }
// //     });

// //     // Initialize focus nodes for each category
// //     // for (var category in categories) {
// //     //   categoryFocusNodes[category] = FocusNode();
// //     // }
// //     // moreFocusNode = FocusNode();

// //     // Ensure category focus nodes are initialized
// //     for (var category in categories) {
// //       categoryFocusNodes.putIfAbsent(category, () => FocusNode());
// //     }

// //     // Ensure focus listener is added
// //     categoryFocusNodes[categories.first]!.addListener(() {
// //       if (categoryFocusNodes[categories.first]!.hasFocus) {
// //         widget.onFocusChange?.call(true);
// //       }
// //     });

// //     // Ensure more button focus node is initialized
// //     moreFocusNode = FocusNode();

// //     // Ensure news item focus nodes are properly initialized
// //     for (var item in _musicList) {
// //       newsItemFocusNodes.putIfAbsent(item.id, () => FocusNode());
// //     }
// //   }

// //   void _scrollToFocusedItem(String itemId) {
// //     if (newsItemFocusNodes[itemId] != null &&
// //         newsItemFocusNodes[itemId]!.hasFocus) {
// //       Scrollable.ensureVisible(
// //         newsItemFocusNodes[itemId]!.context!,
// //         alignment: 0.25, // Adjust alignment for better UX
// //         duration: Duration(milliseconds: 800),
// //         curve: Curves.linear,
// //       );
// //     }
// //   }

// //   // Add color generator function
// //   Color _generateRandomColor() {
// //     final random = Random();
// //     return Color.fromRGBO(
// //       random.nextInt(256),
// //       random.nextInt(256),
// //       random.nextInt(256),
// //       1,
// //     );
// //   }

// //   Future<void> _loadCachedDataAndFetchMusic() async {
// //     setState(() {
// //       _isLoading = true;
// //       _errorMessage = '';
// //     });

// //     try {
// //       // Step 1: Load cached data
// //       await _loadCachedMusicData();

// //       // Step 2: Fetch new data in the background and update UI if needed
// //       await _fetchMusicInBackground();
// //     } catch (e) {
// //       setState(() {
// //         // _errorMessage = 'Failed to load data';
// //         _isLoading = false;
// //       });
// //       // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //       //   content: Text("_loadCachedDataAndFetch: $e"),
// //       //   backgroundColor: Colors.red,
// //       // ));
// //     }
// //   }

// //   Future<void> _loadCachedMusicData() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final cachedMusic = prefs.getString('music_list');

// //       if (cachedMusic != null) {
// //         final List<dynamic> cachedData = json.decode(cachedMusic);
// //         setState(() {
// //           _musicList =
// //               cachedData.map((item) => NewsItemModel.fromJson(item)).toList();
// //           _isLoading = false; // Show cached data immediately
// //         });
// //       }
// //     } catch (e) {
// //       // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //       //   content: Text("_loadCachedData : $e"),
// //       //   backgroundColor: Colors.red,
// //       // ));
// //     }
// //   }

// //   Future<void> _fetchMusicInBackground() async {
// //     try {
// //       // Step 1: Fetch new data from API
// //       final newMusicList = await _apiService.fetchMusicData();

// //       // Step 2: Compare with cached data
// //       final prefs = await SharedPreferences.getInstance();
// //       final cachedMusic = prefs.getString('music_list');
// //       final String newMusicJson = json.encode(newMusicList);

// //       if (cachedMusic == null || cachedMusic != newMusicJson) {
// //         // Step 3: Update cache if new data is different
// //         await prefs.setString('music_list', newMusicJson);

// //         // Step 4: Update UI with new data
// //         setState(() {
// //           _musicList = newMusicList;
// //         });
// //       }
// //     } catch (e, stacktrace) {
// //     }
// //   }

// //   void _initializeNewsItemFocusNodes() {
// //     newsItemFocusNodes.clear();
// //     for (var item in _musicList) {
// //       newsItemFocusNodes[item.id] = FocusNode()
// //         ..addListener(() {
// //           if (newsItemFocusNodes[item.id]!.hasFocus) {
// //             _scrollToFocusedItem(item.id);
// //           }
// //         });
// //     }
// //   }

// //   Future<void> fetchData() async {
// //     setState(() {
// //       _isLoading = true;
// //       _errorMessage = '';
// //     });

// //     try {

// //       await _apiService.fetchSettings();

// //       await _apiService.fetchEntertainment();

// //       setState(() {
// //         _musicList.clear();


// //         // Use the selected category to determine which list to add
// //         switch (_selectedCategory.toLowerCase()) {
// //           case 'live':
// //             _musicList.addAll(_apiService.allChannelList);
// //             break;
// //           case 'entertainment':
// //             _musicList.addAll(_apiService.entertainmentList);
// //             break;
// //           case 'music':
// //             _musicList.addAll(_apiService.musicList);
// //             break;
// //           case 'movie':
// //             _musicList.addAll(_apiService.movieList);
// //             break;
// //           case 'news':
// //             _musicList.addAll(_apiService.newsList);
// //             break;
// //           case 'sports':
// //             _musicList.addAll(_apiService.sportsList);
// //             break;
// //           case 'religious':
// //             _musicList.addAll(_apiService.religiousList);
// //             break;
// //           default:
// //             _musicList.addAll(_apiService.musicList);
// //         }


// //         // Debug: Print first few items in _musicList
// //         if (_musicList.isNotEmpty) {
// //         } else {
// //         }

// //         _initializeNewsItemFocusNodes();
// //         _isLoading = false;
// //       });
// //     } catch (e, stackTrace) {
// //       setState(() {
// //         _errorMessage = 'Failed to load data: $e';
// //         _isLoading = false;
// //       });

// //       // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //       //   content: Text("fetchData error: $e"),
// //       //   backgroundColor: Colors.red,
// //       // ));
// //     }
// //   }

// //   void _scrollToFirstItem() {
// //     if (_scrollController.hasClients) {
// //       _scrollController.animateTo(
// //         0.0, // Scroll to beginning
// //         duration: Duration(milliseconds: 300),
// //         curve: Curves.easeInOut,
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.transparent,
// //       body: Column(
// //         children: [
// //           // SizedBox(height: screenhgt * 0.03),
// //           _buildCategoryButtons(),
// //           Expanded(child: _buildBody()),
// //         ],
// //       ),
// //     );
// //   }



// // // Replace your existing _buildCategoryButtons() method with this updated version:

// //   Widget _buildCategoryButtons() {
// //     return Container(
// //       padding: EdgeInsets.symmetric(vertical: screenhgt * 0.01),
// //       height: screenhgt * 0.1, // Parent container height
// //       child: Row(
// //         children: [
// //           ...categories.asMap().entries.map((entry) {
// //             int index = entry.key;
// //             String category = entry.value;
// //             final focusNode = categoryFocusNodes[category]!;

// //             return Focus(
// //               focusNode: focusNode,
// //               onFocusChange: (hasFocus) {
// //                 setState(() {
// //                   if (hasFocus) {
// //                     // Update color in the provider when category button is focused
// //                     final randomColor = _generateRandomColor();
// //                     context
// //                         .read<ColorProvider>()
// //                         .updateColor(randomColor, true);
// //                   } else {
// //                     // Reset color when focus is lost
// //                     context.read<ColorProvider>().resetColor();
// //                   }
// //                 });
// //               },
// //               onKey: (FocusNode node, RawKeyEvent event) {
// //                 if (event is RawKeyDownEvent) {
// //                   if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// //                     final sharedDataProvider =
// //                         context.read<SharedDataProvider>();
// //                     final lastPlayedVideos =
// //                         sharedDataProvider.lastPlayedVideos;

// //                     if (lastPlayedVideos.isNotEmpty) {
// //                       context
// //                           .read<FocusProvider>()
// //                           .requestFirstLastPlayedFocus();
// //                       return KeyEventResult.handled;
// //                     }
// //                   } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
// //                     if (_musicList.isNotEmpty) {
// //                       // Ensure first item is visible by scrolling to start
// //                       _scrollToFirstItem();

// //                       // Request focus after scrolling animation
// //                       Future.delayed(Duration(milliseconds: 150), () {
// //                         final firstId = _musicList[0].id;
// //                         final nextNode = newsItemFocusNodes[firstId];
// //                         if (nextNode != null && nextNode.context != null) {
// //                           FocusScope.of(context).requestFocus(nextNode);

// //                           // Double ensure visibility
// //                           Future.delayed(Duration(milliseconds: 50), () {
// //                             _scrollToFocusedItem(firstId);
// //                           });
// //                         }
// //                       });
// //                       // context.read<FocusProvider>().requestSubVodFocus();
// //                       return KeyEventResult.handled;
// //                     }
// //                   } else if (event.logicalKey ==
// //                       LogicalKeyboardKey.arrowRight) {
// //                     if (index == categories.length - 1) {
// //                       FocusScope.of(context).requestFocus(moreFocusNode);
// //                     } else {
// //                       FocusScope.of(context).requestFocus(
// //                           categoryFocusNodes[categories[index + 1]]);
// //                     }
// //                     return KeyEventResult.handled;
// //                   } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
// //                     if (index == 0) {
// //                       FocusScope.of(context).requestFocus(moreFocusNode);
// //                     } else {
// //                       FocusScope.of(context).requestFocus(
// //                           categoryFocusNodes[categories[index - 1]]);
// //                     }
// //                     return KeyEventResult.handled;
// //                   } else if (event.logicalKey == LogicalKeyboardKey.enter ||
// //                       event.logicalKey == LogicalKeyboardKey.select) {
// //                     _selectCategory(category);
// //                     return KeyEventResult.handled;
// //                   }
// //                 }
// //                 return KeyEventResult.ignored;
// //               },
// //               child: Builder(
// //                 builder: (BuildContext context) {
// //                   final bool hasFocus = Focus.of(context).hasFocus;
// //                   final currentColor =
// //                       context.watch<ColorProvider>().dominantColor;
// //                   return RandomLightColorWidget(
// //                     hasFocus: hasFocus,
// //                     childBuilder: (Color randomColor) {
// //                       return Container(
// //                         margin: EdgeInsets.all(
// //                             screenwdt * 0.001), // Reduced padding
// //                         decoration: BoxDecoration(
// //                           color: Colors.transparent,
// //                           borderRadius: BorderRadius.circular(8),
// //                           border: Border.all(
// //                             color: hasFocus ? currentColor : Colors.transparent,
// //                             width: 2,
// //                           ),
// //                         ),
// //                         child: TextButton(
// //                           onPressed: () => _selectCategory(category),
// //                           style: ButtonStyle(
// //                             padding: MaterialStateProperty.all(EdgeInsets.zero),
// //                           ),
// //                           child: Center(
// //                             child: Text(
// //                               category,
// //                               style: TextStyle(
// //                                 fontSize: menutextsz,
// //                                 color: _selectedCategory == category
// //                                     ? borderColor
// //                                     : (hasFocus ? currentColor : hintColor),
// //                                 fontWeight:
// //                                     _selectedCategory == category || hasFocus
// //                                         ? FontWeight.bold
// //                                         : FontWeight.normal,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   );
// //                 },
// //               ),
// //             );
// //           }).toList(),

// //           // More button remains the same
// //           Expanded(
// //             child: Focus(
// //               focusNode: moreFocusNode,
// //               onFocusChange: (hasFocus) {
// //                 setState(() {
// //                   if (hasFocus) {
// //                     // Update color in the provider when "More" button is focused
// //                     final randomColor = _generateRandomColor();
// //                     context
// //                         .read<ColorProvider>()
// //                         .updateColor(randomColor, true);
// //                   } else {
// //                     // Reset color when focus is lost
// //                     context.read<ColorProvider>().resetColor();
// //                   }
// //                 });
// //               },
// //               onKey: (FocusNode node, RawKeyEvent event) {
// //                 if (event is RawKeyDownEvent) {
// //                   if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
// //                     FocusScope.of(context)
// //                         .requestFocus(categoryFocusNodes[categories.first]);
// //                     return KeyEventResult.handled;
// //                   } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
// //                     FocusScope.of(context)
// //                         .requestFocus(categoryFocusNodes[categories.last]);
// //                     return KeyEventResult.handled;
// //                   } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// //                     final sharedDataProvider =
// //                         context.read<SharedDataProvider>();
// //                     final lastPlayedVideos =
// //                         sharedDataProvider.lastPlayedVideos;

// //                     if (lastPlayedVideos.isNotEmpty) {
// //                       // Request focus for the first banner in lastPlayedVideos
// //                       context
// //                           .read<FocusProvider>()
// //                           .requestFirstLastPlayedFocus();
// //                       return KeyEventResult.handled;
// //                     }
// //                   } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
// //                     if (_musicList.isNotEmpty) {
// //                       // Ensure first item is visible by scrolling to start
// //                       _scrollToFirstItem();

// //                       // Request focus after scrolling animation
// //                       Future.delayed(Duration(milliseconds: 150), () {
// //                         final firstId = _musicList[0].id;
// //                         final nextNode = newsItemFocusNodes[firstId];
// //                         if (nextNode != null && nextNode.context != null) {
// //                           FocusScope.of(context).requestFocus(nextNode);

// //                           // Double ensure visibility
// //                           Future.delayed(Duration(milliseconds: 50), () {
// //                             _scrollToFocusedItem(firstId);
// //                           });
// //                         }
// //                       });

// //                       // context.read<FocusProvider>().requestSubVodFocus();
// //                       return KeyEventResult.handled;
// //                     }
// //                   } else if (event.logicalKey == LogicalKeyboardKey.enter ||
// //                       event.logicalKey == LogicalKeyboardKey.select) {
// //                     _navigateToChannelsCategory();
// //                     return KeyEventResult.handled;
// //                   }
// //                 }
// //                 return KeyEventResult.ignored;
// //               },
// //               child: Builder(
// //                 builder: (BuildContext context) {
// //                   final bool hasFocus = Focus.of(context).hasFocus;
// //                   final Color currentColor =
// //                       context.watch<ColorProvider>().dominantColor;
// //                   return Align(
// //                     alignment: Alignment.centerLeft,
// //                     child: RandomLightColorWidget(
// //                       hasFocus: hasFocus,
// //                       childBuilder: (Color randomColor) {
// //                         return Container(
// //                           margin: EdgeInsets.all(
// //                               screenwdt * 0.001), // Reduced padding
// //                           decoration: BoxDecoration(
// //                             color: Colors.transparent,
// //                             borderRadius: BorderRadius.circular(8),
// //                             border: Border.all(
// //                               color:
// //                                   hasFocus ? currentColor : Colors.transparent,
// //                               width: 2,
// //                             ),
// //                           ),
// //                           child: TextButton(
// //                             onPressed: _navigateToChannelsCategory,
// //                             style: ButtonStyle(
// //                               padding:
// //                                   MaterialStateProperty.all(EdgeInsets.zero),
// //                             ),
// //                             child: Text(
// //                               'More',
// //                               style: TextStyle(
// //                                 fontSize: menutextsz,
// //                                 color: hasFocus ? currentColor : hintColor,
// //                                 fontWeight: hasFocus
// //                                     ? FontWeight.bold
// //                                     : FontWeight.normal,
// //                               ),
// //                             ),
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _navigateToChannelsCategory() {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => ChannelsCategory(),
// //       ),
// //     );
// //   }

// //   // void _selectCategory(String category) {
// //   //   setState(() {
// //   //     _selectedCategory = category;
// //   //   });
// //   //   fetchData();
// //   // }

// //   void _selectCategory(String category) {
// //     setState(() {
// //       _selectedCategory = category;
// //     });

// //     fetchData().then((_) {
// //       if (_musicList.isNotEmpty) {
// //         final firstItemId = _musicList[0].id;
// //         if (newsItemFocusNodes.containsKey(firstItemId)) {
// //           // Request focus for the first item in the selected category
// //           context
// //               .read<FocusProvider>()
// //               .requestNewsItemFocusNode(newsItemFocusNodes[firstItemId]!);
// //         }
// //       }
// //     });
// //   }

// //   Widget _buildBody() {
// //     if (_isLoading) {
// //       return LoadingIndicator();
// //     } else if (_errorMessage.isNotEmpty) {
// //       return ErrorMessage(message: _errorMessage);
// //     } else if (_musicList.isEmpty) {
// //       return EmptyState(message: 'No items found for $_selectedCategory');
// //     } else {
// //       return _buildNewsList();
// //     }
// //   }

// //   Widget _buildNewsList() {
// //     int totalItems = _musicList.length;
// //     bool showViewAll = totalItems > 10;

// //     return ListView.builder(
// //       clipBehavior: Clip.none,
// //       scrollDirection: Axis.horizontal,
// //       controller: _scrollController,
// //       itemCount: showViewAll ? 11 : totalItems,
// //       itemBuilder: (context, index) {
// //         if (showViewAll && index == 10) {
// //           return _buildViewAllItem();
// //         }
// //         return _buildNewsItem(_musicList[index], index);
// //       },
// //     );
// //   }

// //   Widget _buildViewAllItem() {
// //     return Focus(
// //       onKey: (FocusNode node, RawKeyEvent event) {
// //         if (event is RawKeyDownEvent) {
// //           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
// //             // Prevent moving focus beyond "View All"
// //             return KeyEventResult.handled;
// //           }
// //           if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// //             // Prevent moving focus beyond "View All"
// //             FocusScope.of(context)
// //                 .requestFocus(categoryFocusNodes[_selectedCategory]);
// //             return KeyEventResult.handled;
// //           }
// //           if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
// //             // Prevent moving focus beyond "View All"
// //             context.read<FocusProvider>().requestSubVodFocus(); // यह call करें
// //             // context.read<FocusProvider>().requestSubVodFocus();
// //             // return KeyEventResult.handled;
// //           }
// //         }
// //         return KeyEventResult.ignored;
// //       },
// //       child: NewsItem(
// //         key: Key('view_all'),
// //         item: NewsItemModel(
// //           id: 'view_all',
// //           name: _selectedCategory.toUpperCase(),
// //           description: ' $_selectedCategory ',
// //           banner: '',
// //           poster: '',
// //           category: '',
// //           url: '',
// //           streamType: '',
// //           type: '',
// //           genres: '',
// //           status: '',
// //           videoId: '',
// //           index: '',
// //           image: '',
// //           unUpdatedUrl: '',
// //         ),
// //         onTap: _navigateToViewAllScreen,
// //         onEnterPress: _handleEnterPress,
// //       ),
// //     );
// //   }

// //   Widget _buildNewsItem(NewsItemModel item, int index) {
// //     // newsItemFocusNodes.putIfAbsent(item.id, () => FocusNode());
// //     newsItemFocusNodes.putIfAbsent(
// //         item.id,
// //         () => FocusNode()
// //           ..addListener(() {
// //             if (newsItemFocusNodes[item.id]!.hasFocus) {
// //               _scrollToFocusedItem(item.id);
// //             }
// //           }));
// //     return NewsItem(
// //       key: Key(item.id),
// //       hideDescription: true,
// //       item: item,
// //       focusNode: newsItemFocusNodes[item.id],
// //       onTap: () => _navigateToVideoScreen(item),
// //       onEnterPress: _handleEnterPress,
// //       onUpPress: () {
// //         // Request focus for current category
// //         FocusScope.of(context)
// //             .requestFocus(categoryFocusNodes[_selectedCategory]);
// //       },
// //       onDownPress: () {
// //         // Request focus for the first SubVod item
// //         // context.read<FocusProvider>().requestSubVodFocus();
// //         context.read<FocusProvider>().forceSubVodFocus();

// //       },
// //     );
// //   }

// //   void _handleEnterPress(String itemId) {
// //     if (itemId == 'view_all') {
// //       _navigateToViewAllScreen();
// //     } else {
// //       final selectedItem = _musicList.firstWhere((item) => item.id == itemId);
// //       _navigateToVideoScreen(selectedItem);
// //     }
// //   }

// //   Future<void> _navigateToVideoScreen(NewsItemModel newsItem) async {
// //     if (_isNavigating) return;
// //     _isNavigating = true;

// //     bool shouldPlayVideo = true;
// //     bool shouldPop = true;

// //     // Show loading indicator while video is loading
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (BuildContext context) {
// //         return WillPopScope(
// //           onWillPop: () async {
// //             shouldPlayVideo = false;
// //             shouldPop = false;
// //             return true;
// //           },
// //           child: LoadingIndicator(),
// //         );
// //       },
// //     );

// //     Timer(Duration(seconds: 10), () {
// //       _isNavigating = false;
// //     });

// //     try {
// //       String originalUrl = newsItem.url;
// //       if (newsItem.streamType == 'YoutubeLive') {
// //         // Retry fetching the updated URL if stream type is YouTube Live
// //         for (int i = 0; i < _maxRetries; i++) {
// //           try {
// //             String updatedUrl =
// //                 await _socketService.getUpdatedUrl(newsItem.url);
// //             // await  'https://www.youtube.com/watch?v=${newsItem.url}';

// //             newsItem = NewsItemModel(
// //               id: newsItem.id,
// //               videoId: '',
// //               name: newsItem.name,
// //               description: newsItem.description,
// //               banner: newsItem.banner,
// //               poster: newsItem.poster,
// //               category: newsItem.category,
// //               url: updatedUrl,
// //               streamType: 'M3u8',
// //               type: 'M3u8',
// //               genres: newsItem.genres,
// //               status: newsItem.status,
// //               index: newsItem.index,
// //               image: '',
// //               unUpdatedUrl: '',
// //             );
// //             break; // Exit loop when URL is successfully updated
// //           } catch (e) {
// //             if (i == _maxRetries - 1) rethrow; // Rethrow error on last retry
// //             await Future.delayed(
// //                 Duration(seconds: _retryDelay)); // Delay before next retry
// //           }
// //         }
// //       }

// //       if (shouldPop) {
// //         Navigator.of(context, rootNavigator: true).pop();
// //       }

// //       bool liveStatus = true;

// //       if (shouldPlayVideo) {
// //         await Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (context) => VideoScreen(
// //               videoUrl: newsItem.url,
// //               bannerImageUrl: newsItem.banner,
// //               startAtPosition: Duration.zero,
// //               videoType: newsItem.streamType,
// //               channelList: _musicList,
// //               isLive: true,
// //               isVOD: false,
// //               isBannerSlider: false,
// //               source: 'isLiveScreen',
// //               isSearch: false,
// //               videoId: int.tryParse(newsItem.id),
// //               unUpdatedUrl: originalUrl,
// //               name: newsItem.name,
// //               seasonId: null,
// //               isLastPlayedStored: false,
// //               liveStatus: liveStatus,
// //             ),
// //           ),
// //         );
// //       }
// //       // }
// //     } catch (e) {
// //       if (shouldPop) {
// //         Navigator.of(context, rootNavigator: true).pop();
// //       }
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Something Went Wrong')),
// //       );
// //     } finally {
// //       _isNavigating = false;
// //     }
// //   }

// //   void _navigateToViewAllScreen() {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => NewsGridScreen(
// //           newsList: _musicList,
// //         ),
// //       ),
// //     );
// //   }

// //   // @override
// //   // void dispose() {
// //   //   _socketService.dispose();
// //   //   categoryFocusNodes.values.forEach((node) => node.dispose());
// //   //   moreFocusNode.dispose();
// //   //   super.dispose();
// //   // }

// //   @override
// //   void dispose() {
// //     _socketService.dispose();
// //     // categoryFocusNodes.values.forEach((node) {
// //     //   if (node.hasFocus) node.unfocus();
// //     //   node.dispose();
// //     // });
// //     // moreFocusNode.dispose();
// //     for (var node in categoryFocusNodes.values) {
// //       node.dispose();
// //     }

// //     for (var node in newsItemFocusNodes.values) {
// //       node.dispose();
// //     }

// //     moreFocusNode.dispose();
// //     super.dispose();
// //   }
// // }





// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/sub_live_screen/news_grid_screen.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/provider/shared_data_provider.dart';
// import 'package:mobi_tv_entertainment/video_widget/socket_service.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import 'package:mobi_tv_entertainment/widgets/services/api_service.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/empty_state.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/error_message.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
// import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../../widgets/utils/random_light_color_widget.dart';
// import 'channels_category.dart';

// // Professional Colors for SubLive (Live TV)
// class ProfessionalSubLiveColors {
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

//   static List<Color> gradientColors = [
//     accentBlue,
//     accentPurple,
//     accentGreen,
//     accentRed,
//     accentOrange,
//     accentPink,
//   ];
// }

// // Professional Animation Timings
// class SubLiveAnimationTiming {
//   static const Duration ultraFast = Duration(milliseconds: 150);
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration focus = Duration(milliseconds: 700);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// // Professional Channel Card Widget
// class ProfessionalChannelCard extends StatefulWidget {
//   final NewsItemModel item;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;
//   final VoidCallback? onUpPress;
//   final VoidCallback? onDownPress;

//   const ProfessionalChannelCard({
//     Key? key,
//     required this.item,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//     this.onUpPress,
//     this.onDownPress,
//   }) : super(key: key);

//   @override
//   _ProfessionalChannelCardState createState() =>
//       _ProfessionalChannelCardState();
// }

// class _ProfessionalChannelCardState extends State<ProfessionalChannelCard>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _glowController;
//   late AnimationController _shimmerController;

//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<double> _shimmerAnimation;

//   Color _dominantColor = ProfessionalSubLiveColors.accentBlue;
//   bool _isFocused = false;
//   final PaletteColorService _paletteColorService = PaletteColorService();

//   @override
//   void initState() {
//     super.initState();

//     _scaleController = AnimationController(
//       duration: SubLiveAnimationTiming.focus,
//       vsync: this,
//     );

//     _glowController = AnimationController(
//       duration: SubLiveAnimationTiming.medium,
//       vsync: this,
//     );

//     _shimmerController = AnimationController(
//       duration: Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.04,
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

//   void _handleFocusChange() async {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _scaleController.forward();
//       _glowController.forward();
      
//       if (widget.item.id == 'view_all') {
//         _dominantColor = ProfessionalSubLiveColors.accentBlue;
//       } else {
//         try {
//           _dominantColor = await _paletteColorService.getSecondaryColor(
//             widget.item.banner,
//             fallbackColor: ProfessionalSubLiveColors.accentBlue,
//           );
//         } catch (e) {
//           _dominantColor = ProfessionalSubLiveColors.accentBlue;
//         }
//       }
      
//       widget.onColorChange(_dominantColor);
//       HapticFeedback.lightImpact();
//       setState(() {});
//     } else {
//       _scaleController.reverse();
//       _glowController.reverse();
//     }
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     _glowController.dispose();
//     _shimmerController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return AnimatedBuilder(
//       animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Container(
//             width: screenWidth * 0.19,
//             margin: EdgeInsets.symmetric(horizontal: 6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _buildProfessionalPoster(screenWidth, screenHeight),
//                 _buildProfessionalTitle(screenWidth),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
//     final posterHeight = _isFocused ? screenHeight * 0.25 : screenHeight * 0.20;

//     return Container(
//       margin: EdgeInsets.only(top: 15),
//       height: posterHeight,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           if (_isFocused) ...[
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.4),
//               blurRadius: 25,
//               spreadRadius: 3,
//               offset: Offset(0, 8),
//             ),
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.2),
//               blurRadius: 45,
//               spreadRadius: 6,
//               offset: Offset(0, 15),
//             ),
//           ] else ...[
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 10,
//               spreadRadius: 2,
//               offset: Offset(0, 5),
//             ),
//           ],
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Stack(
//           children: [
//             _buildChannelImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildLiveBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildChannelImage(double screenWidth, double posterHeight) {
//     if (widget.item.id == 'view_all') {
//       return _buildViewAllContent(posterHeight);
//     }

//     final imageUrl = widget.item.banner.isNotEmpty 
//         ? widget.item.banner 
//         : widget.item.poster;

//     return Container(
//       width: double.infinity,
//       height: posterHeight,
//       child: imageUrl.isNotEmpty
//           ? CachedNetworkImage(
//               imageUrl: imageUrl,
//               fit: BoxFit.cover,
//               placeholder: (context, url) =>
//                   _buildImagePlaceholder(posterHeight),
//               errorWidget: (context, url, error) =>
//                   _buildImagePlaceholder(posterHeight),
//             )
//           : _buildImagePlaceholder(posterHeight),
//     );
//   }

//   Widget _buildViewAllContent(double height) {
//     return Container(
//       height: height,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: _isFocused
//               ? [
//                   _dominantColor.withOpacity(0.8),
//                   _dominantColor.withOpacity(0.6),
//                   ProfessionalSubLiveColors.cardDark.withOpacity(0.9),
//                 ]
//               : [
//                   ProfessionalSubLiveColors.cardDark,
//                   ProfessionalSubLiveColors.surfaceDark,
//                   ProfessionalSubLiveColors.cardDark.withOpacity(0.8),
//                 ],
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(_isFocused ? 0.2 : 0.1),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(_isFocused ? 0.4 : 0.2),
//                   width: 2,
//                 ),
//               ),
//               child: Icon(
//                 Icons.tv_rounded,
//                 size: _isFocused ? 45 : 35,
//                 color: Colors.white,
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               'VIEW ALL',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: _isFocused ? 14 : 12,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.5,
//                 shadows: [
//                   Shadow(
//                     color: _isFocused
//                         ? _dominantColor.withOpacity(0.6)
//                         : Colors.black.withOpacity(0.5),
//                     blurRadius: _isFocused ? 8 : 4,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 6),
//             Text(
//               widget.item.name.toUpperCase(),
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.9),
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImagePlaceholder(double height) {
//     return Container(
//       height: height,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalSubLiveColors.cardDark,
//             ProfessionalSubLiveColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.live_tv_rounded,
//             size: height * 0.25,
//             color: ProfessionalSubLiveColors.textSecondary,
//           ),
//           SizedBox(height: 8),
//           Text(
//             'No Image',
//             style: TextStyle(
//               color: ProfessionalSubLiveColors.textSecondary,
//               fontSize: 10,
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
//                 stops: [0.0, 0.5, 1.0],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildLiveBadge() {
//     if (widget.item.id == 'view_all') return SizedBox.shrink();
    
//     return Positioned(
//       top: 8,
//       right: 8,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//         decoration: BoxDecoration(
//           color: Colors.red.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(6),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.red.withOpacity(0.3),
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 6,
//               height: 6,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white,
//               ),
//             ),
//             SizedBox(width: 4),
//             Text(
//               'LIVE',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 8,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
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
//             padding: EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: Icon(
//               widget.item.id == 'view_all' 
//                   ? Icons.explore_rounded 
//                   : Icons.play_arrow_rounded,
//               color: Colors.white,
//               size: 30,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     final channelName = widget.item.name.toUpperCase();

//     return Container(
//       width: screenWidth * 0.18,
//       margin: EdgeInsets.only(top: 10),
//       child: AnimatedDefaultTextStyle(
//         duration: SubLiveAnimationTiming.medium,
//         style: TextStyle(
//           fontSize: _isFocused ? 13 : 11,
//           fontWeight: FontWeight.w600,
//           color: _isFocused
//               ? _dominantColor
//               : ProfessionalSubLiveColors.textPrimary,
//           letterSpacing: 0.5,
//           shadows: _isFocused
//               ? [
//                   Shadow(
//                     color: _dominantColor.withOpacity(0.6),
//                     blurRadius: 10,
//                     offset: Offset(0, 2),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Text(
//           channelName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // Enhanced NewsItem for backward compatibility
// class NewsItem extends StatefulWidget {
//   final NewsItemModel item;
//   final VoidCallback onTap;
//   final ValueChanged<String> onEnterPress;
//   final bool hideDescription;
//   final FocusNode? focusNode;
//   final Function(bool)? onFocusChange;
//   final VoidCallback? onUpPress;
//   final VoidCallback? onDownPress;

//   NewsItem({
//     Key? key,
//     required this.item,
//     required this.onTap,
//     required this.onEnterPress,
//     this.hideDescription = false,
//     this.focusNode,
//     this.onFocusChange,
//     this.onUpPress,
//     this.onDownPress,
//   }) : super(key: key);

//   @override
//   _NewsItemState createState() => _NewsItemState();
// }

// class _NewsItemState extends State<NewsItem> {
//   bool isFocused = false;
//   Color dominantColor = Colors.white.withOpacity(0.5);
//   final PaletteColorService _paletteColorService = PaletteColorService();

//   void _handleFocusChange(bool hasFocus) async {
//     setState(() {
//       isFocused = hasFocus;
//     });

//     if (hasFocus) {
//       if (widget.item.id == 'view_all') {
//         dominantColor = ProfessionalSubLiveColors.accentBlue;
//       } else {
//         dominantColor = await _paletteColorService.getSecondaryColor(
//           widget.item.banner,
//           fallbackColor: Colors.grey,
//         );
//       }
//       // Update color using provider
//       context.read<ColorProvider>().updateColor(dominantColor, true);
//       setState(() {});
//     } else {
//       // Reset color when item loses focus
//       context.read<ColorProvider>().resetColor();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       focusNode: widget.focusNode,
//       onFocusChange: _handleFocusChange,
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             widget.onDownPress?.call();
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             widget.onUpPress?.call();
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.select) {
//             widget.onEnterPress(widget.item.id);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: ProfessionalChannelCard(
//           item: widget.item,
//           focusNode: widget.focusNode!,
//           onTap: widget.onTap,
//           onColorChange: (color) {
//             if (mounted) {
//               context.read<ColorProvider>().updateColor(color, true);
//             }
//           },
//           index: 0,
//           onUpPress: widget.onUpPress,
//           onDownPress: widget.onDownPress,
//         ),
//       ),
//     );
//   }
// }

// // Enhanced SubLiveScreen with Professional UI
// class SubLiveScreen extends StatefulWidget {
//   final Function(bool)? onFocusChange;
//   final FocusNode focusNode;

//   const SubLiveScreen({
//     Key? key, 
//     this.onFocusChange, 
//     required this.focusNode
//   }) : super(key: key);

//   @override
//   _SubLiveScreenState createState() => _SubLiveScreenState();
// }

// class _SubLiveScreenState extends State<SubLiveScreen>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   // Data
//   Map<int, Color> _nodeColors = {};
//   Map<String, FocusNode> newsItemFocusNodes = {};
//   List<NewsItemModel> _musicList = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isNavigating = false;
//   String _selectedCategory = 'Live';
//   int _maxRetries = 3;
//   int _retryDelay = 5;

//   // Animation Controllers
//   late AnimationController _headerAnimationController;
//   late AnimationController _categoryAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _categoryFadeAnimation;

//   // Focus Management
//   final ScrollController _scrollController = ScrollController();
//   Map<String, FocusNode> categoryFocusNodes = {};
//   late FocusNode moreFocusNode;

//   // Services
//   final SocketService _socketService = SocketService();
//   final ApiService _apiService = ApiService();
//   final PaletteColorService _paletteColorService = PaletteColorService();

//   final List<String> categories = [
//     'Live',
//     'Entertainment',
//     'Music',
//     'Movie',
//     'News',
//     'Sports',
//     'Religious'
//   ];

//   @override
//   void initState() {
//     super.initState();
    
//     _initializeAnimations();
//     _initializeFocusManagement();
//     _initializeServices();
//     _loadCachedDataAndFetchMusic();
//   }

//   void _initializeAnimations() {
//     _headerAnimationController = AnimationController(
//       duration: SubLiveAnimationTiming.slow,
//       vsync: this,
//     );

//     _categoryAnimationController = AnimationController(
//       duration: SubLiveAnimationTiming.slow,
//       vsync: this,
//     );

//     _headerSlideAnimation = Tween<Offset>(
//       begin: Offset(0, -1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _headerAnimationController,
//       curve: Curves.easeOutCubic,
//     ));

//     _categoryFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _categoryAnimationController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   void _initializeFocusManagement() {
//     // Initialize category focus nodes
//     for (var category in categories) {
//       categoryFocusNodes.putIfAbsent(category, () => FocusNode());
//     }

//     // Initialize more button focus node
//     moreFocusNode = FocusNode();

//     // Add focus listener to first category
//     categoryFocusNodes[categories.first]!.addListener(() {
//       if (categoryFocusNodes[categories.first]!.hasFocus) {
//         widget.onFocusChange?.call(true);
//       }
//     });

//     // Register initial focus in post frame callback
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final firstCategoryNode = categoryFocusNodes[categories.first];
//       if (firstCategoryNode != null) {
//         context
//             .read<FocusProvider>()
//             .setFirstMusicItemFocusNode(firstCategoryNode);
//       } else if (_musicList.isNotEmpty) {
//         final firstItemId = _musicList[0].id;
//         if (newsItemFocusNodes.containsKey(firstItemId)) {
//           final focusNode = newsItemFocusNodes[firstItemId]!;
//           context.read<FocusProvider>().setFirstMusicItemFocusNode(focusNode);
//         }
//       }
//     });
//   }

//   void _initializeServices() {
//     _socketService.initSocket();
    
//     _apiService.updateStream.listen((hasChanges) {
//       if (hasChanges) {
//         _loadCachedDataAndFetchMusic();
//       }
//     });
//   }

//   // Add color generator function
//   Color _generateRandomColor() {
//     final random = Random();
//     return Color.fromRGBO(
//       random.nextInt(256),
//       random.nextInt(256),
//       random.nextInt(256),
//       1,
//     );
//   }

//   Future<void> _loadCachedDataAndFetchMusic() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       await _loadCachedMusicData();
//       await _fetchMusicInBackground();
      
//       // Start animations after data loads
//       _headerAnimationController.forward();
//       _categoryAnimationController.forward();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _loadCachedMusicData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cachedMusic = prefs.getString('music_list');

//       if (cachedMusic != null) {
//         final List<dynamic> cachedData = json.decode(cachedMusic);
//         setState(() {
//           _musicList =
//               cachedData.map((item) => NewsItemModel.fromJson(item)).toList();
//           _isLoading = false;
//         });
//         _initializeNewsItemFocusNodes();
//       }
//     } catch (e) {
//     }
//   }

//   Future<void> _fetchMusicInBackground() async {
//     try {
//       final newMusicList = await _apiService.fetchMusicData();
//       final prefs = await SharedPreferences.getInstance();
//       final cachedMusic = prefs.getString('music_list');
//       final String newMusicJson = json.encode(newMusicList);

//       if (cachedMusic == null || cachedMusic != newMusicJson) {
//         await prefs.setString('music_list', newMusicJson);
//         setState(() {
//           _musicList = newMusicList;
//         });
//         _initializeNewsItemFocusNodes();
//       }
//     } catch (e, stacktrace) {
//     }
//   }

//   void _initializeNewsItemFocusNodes() {
//     newsItemFocusNodes.clear();
//     for (var item in _musicList) {
//       newsItemFocusNodes[item.id] = FocusNode()
//         ..addListener(() {
//           if (newsItemFocusNodes[item.id]!.hasFocus) {
//             _scrollToFocusedItem(item.id);
//           }
//         });
//     }
//   }

//   void _scrollToFocusedItem(String itemId) {
//     if (newsItemFocusNodes[itemId] != null &&
//         newsItemFocusNodes[itemId]!.hasFocus) {
//       Scrollable.ensureVisible(
//         newsItemFocusNodes[itemId]!.context!,
//         alignment: 0.25,
//         duration: Duration(milliseconds: 800),
//         curve: Curves.linear,
//       );
//     }
//   }

//   Future<void> fetchData() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       await _apiService.fetchSettings();
//       await _apiService.fetchEntertainment();

//       setState(() {
//         _musicList.clear();

//         switch (_selectedCategory.toLowerCase()) {
//           case 'live':
//             _musicList.addAll(_apiService.allChannelList);
//             break;
//           case 'entertainment':
//             _musicList.addAll(_apiService.entertainmentList);
//             break;
//           case 'music':
//             _musicList.addAll(_apiService.musicList);
//             break;
//           case 'movie':
//             _musicList.addAll(_apiService.movieList);
//             break;
//           case 'news':
//             _musicList.addAll(_apiService.newsList);
//             break;
//           case 'sports':
//             _musicList.addAll(_apiService.sportsList);
//             break;
//           case 'religious':
//             _musicList.addAll(_apiService.religiousList);
//             break;
//           default:
//             _musicList.addAll(_apiService.musicList);
//         }

//         _initializeNewsItemFocusNodes();
//         _isLoading = false;
//       });
//     } catch (e, stackTrace) {
//       setState(() {
//         _errorMessage = 'Failed to load data: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   void _scrollToFirstItem() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         0.0,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return Consumer<ColorProvider>(
//       builder: (context, colorProv, child) {
//         final bgColor = colorProv.isItemFocused
//             ? colorProv.dominantColor.withOpacity(0.1)
//             : ProfessionalSubLiveColors.primaryDark;

//         return Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 bgColor,
//                 ProfessionalSubLiveColors.primaryDark,
//                 ProfessionalSubLiveColors.surfaceDark.withOpacity(0.5),
//               ],
//             ),
//           ),
//           child: Column(
//             children: [
//               SizedBox(height: screenhgt * 0.01),
//               _buildProfessionalCategoryButtons(),
//               Expanded(child: _buildBody()),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfessionalCategoryButtons() {
//     return SlideTransition(
//       position: _headerSlideAnimation,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: screenhgt * 0.01),
//         height: screenhgt * 0.1,
//         child: Row(
//           children: [
//             ...categories.asMap().entries.map((entry) {
//               int index = entry.key;
//               String category = entry.value;
//               final focusNode = categoryFocusNodes[category]!;

//               return _buildCategoryButton(category, index, focusNode);
//             }).toList(),
//             _buildMoreButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryButton(String category, int index, FocusNode focusNode) {
//     return Expanded(
//       child: Focus(
//         focusNode: focusNode,
//         onFocusChange: (hasFocus) {
//           setState(() {
//             if (hasFocus) {
//               final randomColor = _generateRandomColor();
//               context.read<ColorProvider>().updateColor(randomColor, true);
//             } else {
//               context.read<ColorProvider>().resetColor();
//             }
//           });
//         },
//         onKey: (FocusNode node, RawKeyEvent event) {
//           if (event is RawKeyDownEvent) {
//             if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//               final sharedDataProvider = context.read<SharedDataProvider>();
//               final lastPlayedVideos = sharedDataProvider.lastPlayedVideos;

//               if (lastPlayedVideos.isNotEmpty) {
//                 context.read<FocusProvider>().requestFirstLastPlayedFocus();
//                 return KeyEventResult.handled;
//               }
//             } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//               if (_musicList.isNotEmpty) {
//                 _scrollToFirstItem();
//                 Future.delayed(Duration(milliseconds: 150), () {
//                   final firstId = _musicList[0].id;
//                   final nextNode = newsItemFocusNodes[firstId];
//                   if (nextNode != null && nextNode.context != null) {
//                     FocusScope.of(context).requestFocus(nextNode);
//                     Future.delayed(Duration(milliseconds: 50), () {
//                       _scrollToFocusedItem(firstId);
//                     });
//                   }
//                 });
//                 return KeyEventResult.handled;
//               }
//             } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//               if (index == categories.length - 1) {
//                 FocusScope.of(context).requestFocus(moreFocusNode);
//               } else {
//                 FocusScope.of(context).requestFocus(
//                     categoryFocusNodes[categories[index + 1]]);
//               }
//               return KeyEventResult.handled;
//             } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//               if (index == 0) {
//                 FocusScope.of(context).requestFocus(moreFocusNode);
//               } else {
//                 FocusScope.of(context).requestFocus(
//                     categoryFocusNodes[categories[index - 1]]);
//               }
//               return KeyEventResult.handled;
//             } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//                 event.logicalKey == LogicalKeyboardKey.select) {
//               _selectCategory(category);
//               return KeyEventResult.handled;
//             }
//           }
//           return KeyEventResult.ignored;
//         },
//         child: Builder(
//           builder: (BuildContext context) {
//             final bool hasFocus = Focus.of(context).hasFocus;
//             final currentColor = context.watch<ColorProvider>().dominantColor;
            
//             return Container(
//               margin: EdgeInsets.symmetric(horizontal: screenwdt * 0.005),
//               decoration: BoxDecoration(
//                 gradient: hasFocus
//                     ? LinearGradient(
//                         colors: [
//                           currentColor.withOpacity(0.2),
//                           currentColor.withOpacity(0.1),
//                         ],
//                       )
//                     : null,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: hasFocus ? currentColor : Colors.transparent,
//                   width: 2,
//                 ),
//                 boxShadow: hasFocus
//                     ? [
//                         BoxShadow(
//                           color: currentColor.withOpacity(0.3),
//                           blurRadius: 8,
//                           offset: Offset(0, 4),
//                         ),
//                       ]
//                     : [],
//               ),
//               child: TextButton(
//                 onPressed: () => _selectCategory(category),
//                 style: ButtonStyle(
//                   padding: MaterialStateProperty.all(EdgeInsets.zero),
//                   backgroundColor: MaterialStateProperty.all(Colors.transparent),
//                 ),
//                 child: Center(
//                   child: Text(
//                     category.toUpperCase(),
//                     style: TextStyle(
//                       fontSize: menutextsz,
//                       color: _selectedCategory == category
//                           ? ProfessionalSubLiveColors.accentBlue
//                           : (hasFocus ? currentColor : hintColor),
//                       fontWeight: _selectedCategory == category || hasFocus
//                           ? FontWeight.bold
//                           : FontWeight.w500,
//                       letterSpacing: 0.5,
//                       shadows: hasFocus
//                           ? [
//                               Shadow(
//                                 color: currentColor.withOpacity(0.6),
//                                 blurRadius: 4,
//                                 offset: Offset(0, 2),
//                               ),
//                             ]
//                           : [],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildMoreButton() {
//     return Expanded(
//       child: Focus(
//         focusNode: moreFocusNode,
//         onFocusChange: (hasFocus) {
//           setState(() {
//             if (hasFocus) {
//               final randomColor = _generateRandomColor();
//               context.read<ColorProvider>().updateColor(randomColor, true);
//             } else {
//               context.read<ColorProvider>().resetColor();
//             }
//           });
//         },
//         onKey: (FocusNode node, RawKeyEvent event) {
//           if (event is RawKeyDownEvent) {
//             if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//               FocusScope.of(context)
//                   .requestFocus(categoryFocusNodes[categories.first]);
//               return KeyEventResult.handled;
//             } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//               FocusScope.of(context)
//                   .requestFocus(categoryFocusNodes[categories.last]);
//               return KeyEventResult.handled;
//             } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//               final sharedDataProvider = context.read<SharedDataProvider>();
//               final lastPlayedVideos = sharedDataProvider.lastPlayedVideos;

//               if (lastPlayedVideos.isNotEmpty) {
//                 context.read<FocusProvider>().requestFirstLastPlayedFocus();
//                 return KeyEventResult.handled;
//               }
//             } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//               if (_musicList.isNotEmpty) {
//                 _scrollToFirstItem();
//                 Future.delayed(Duration(milliseconds: 150), () {
//                   final firstId = _musicList[0].id;
//                   final nextNode = newsItemFocusNodes[firstId];
//                   if (nextNode != null && nextNode.context != null) {
//                     FocusScope.of(context).requestFocus(nextNode);
//                     Future.delayed(Duration(milliseconds: 50), () {
//                       _scrollToFocusedItem(firstId);
//                     });
//                   }
//                 });
//                 return KeyEventResult.handled;
//               }
//             } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//                 event.logicalKey == LogicalKeyboardKey.select) {
//               _navigateToChannelsCategory();
//               return KeyEventResult.handled;
//             }
//           }
//           return KeyEventResult.ignored;
//         },
//         child: Builder(
//           builder: (BuildContext context) {
//             final bool hasFocus = Focus.of(context).hasFocus;
//             final Color currentColor = context.watch<ColorProvider>().dominantColor;
            
//             return Align(
//               alignment: Alignment.centerLeft,
//               child: Container(
//                 margin: EdgeInsets.symmetric(horizontal: screenwdt * 0.005),
//                 decoration: BoxDecoration(
//                   gradient: hasFocus
//                       ? LinearGradient(
//                           colors: [
//                             currentColor.withOpacity(0.2),
//                             currentColor.withOpacity(0.1),
//                           ],
//                         )
//                       : null,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: hasFocus ? currentColor : Colors.transparent,
//                     width: 2,
//                   ),
//                   boxShadow: hasFocus
//                       ? [
//                           BoxShadow(
//                             color: currentColor.withOpacity(0.3),
//                             blurRadius: 8,
//                             offset: Offset(0, 4),
//                           ),
//                         ]
//                       : [],
//                 ),
//                 child: TextButton(
//                   onPressed: _navigateToChannelsCategory,
//                   style: ButtonStyle(
//                     padding: MaterialStateProperty.all(EdgeInsets.zero),
//                     backgroundColor: MaterialStateProperty.all(Colors.transparent),
//                   ),
//                   child: Text(
//                     'MORE',
//                     style: TextStyle(
//                       fontSize: menutextsz,
//                       color: hasFocus ? currentColor : hintColor,
//                       fontWeight: hasFocus ? FontWeight.bold : FontWeight.w500,
//                       letterSpacing: 0.5,
//                       shadows: hasFocus
//                           ? [
//                               Shadow(
//                                 color: currentColor.withOpacity(0.6),
//                                 blurRadius: 4,
//                                 offset: Offset(0, 2),
//                               ),
//                             ]
//                           : [],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   void _navigateToChannelsCategory() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChannelsCategory(),
//       ),
//     );
//   }

//   void _selectCategory(String category) {
//     setState(() {
//       _selectedCategory = category;
//     });

//     fetchData().then((_) {
//       if (_musicList.isNotEmpty) {
//         final firstItemId = _musicList[0].id;
//         if (newsItemFocusNodes.containsKey(firstItemId)) {
//           context
//               .read<FocusProvider>()
//               .requestNewsItemFocusNode(newsItemFocusNodes[firstItemId]!);
//         }
//       }
//     });
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return _buildProfessionalLoadingIndicator();
//     } else if (_errorMessage.isNotEmpty) {
//       return ErrorMessage(message: _errorMessage);
//     } else if (_musicList.isEmpty) {
//       return EmptyState(message: 'No items found for $_selectedCategory');
//     } else {
//       return _buildChannelsList();
//     }
//   }

//   Widget _buildProfessionalLoadingIndicator() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 70,
//             height: 70,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: SweepGradient(
//                 colors: [
//                   ProfessionalSubLiveColors.accentPurple,
//                   ProfessionalSubLiveColors.accentBlue,
//                   ProfessionalSubLiveColors.accentGreen,
//                   ProfessionalSubLiveColors.accentPurple,
//                 ],
//               ),
//             ),
//             child: Container(
//               margin: EdgeInsets.all(5),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: ProfessionalSubLiveColors.primaryDark,
//               ),
//               child: Icon(
//                 Icons.live_tv_rounded,
//                 color: ProfessionalSubLiveColors.textPrimary,
//                 size: 28,
//               ),
//             ),
//           ),
//           SizedBox(height: 24),
//           Text(
//             'Loading $_selectedCategory Channels...',
//             style: TextStyle(
//               color: ProfessionalSubLiveColors.textPrimary,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: 12),
//           Container(
//             width: 200,
//             height: 3,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(2),
//               color: ProfessionalSubLiveColors.surfaceDark,
//             ),
//             child: LinearProgressIndicator(
//               backgroundColor: Colors.transparent,
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 ProfessionalSubLiveColors.accentPurple,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChannelsList() {
//     return FadeTransition(
//       opacity: _categoryFadeAnimation,
//       child: Container(
//         height: MediaQuery.of(context).size.height * 0.38,
//         child: ListView.builder(
//           clipBehavior: Clip.none,
//           scrollDirection: Axis.horizontal,
//           controller: _scrollController,
//           itemCount: _musicList.length > 10 ? 11 : _musicList.length,
//           itemBuilder: (context, index) {
//             if (_musicList.length > 10 && index == 10) {
//               return _buildViewAllItem();
//             }
//             return _buildChannelItem(_musicList[index], index);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildViewAllItem() {
//     final viewAllFocusNode = FocusNode();
//     final viewAllItem = NewsItemModel(
//       id: 'view_all',
//       name: _selectedCategory.toUpperCase(),
//       description: ' $_selectedCategory ',
//       banner: '',
//       poster: '',
//       category: '',
//       url: '',
//       streamType: '',
//       type: '',
//       genres: '',
//       status: '',
//       videoId: '',
//       index: '',
//       image: '',
//       unUpdatedUrl: '',
//     );

//     return Focus(
//       focusNode: viewAllFocusNode,
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//             return KeyEventResult.handled;
//           }
//           if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             FocusScope.of(context)
//                 .requestFocus(categoryFocusNodes[_selectedCategory]);
//             return KeyEventResult.handled;
//           }
//           if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             context.read<FocusProvider>().requestSubVodFocus();
//             return KeyEventResult.handled;
//           }
//           if (event.logicalKey == LogicalKeyboardKey.select) {
//             _navigateToViewAllScreen();
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: _navigateToViewAllScreen,
//         child: ProfessionalChannelCard(
//           item: viewAllItem,
//           focusNode: viewAllFocusNode,
//           onTap: _navigateToViewAllScreen,
//           onColorChange: (color) {
//             if (mounted) {
//               context.read<ColorProvider>().updateColor(color, true);
//             }
//           },
//           index: 10,
//           onUpPress: () {
//             FocusScope.of(context)
//                 .requestFocus(categoryFocusNodes[_selectedCategory]);
//           },
//           onDownPress: () {
//             context.read<FocusProvider>().requestSubVodFocus();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildChannelItem(NewsItemModel item, int index) {
//     newsItemFocusNodes.putIfAbsent(
//         item.id,
//         () => FocusNode()
//           ..addListener(() {
//             if (newsItemFocusNodes[item.id]!.hasFocus) {
//               _scrollToFocusedItem(item.id);
//             }
//           }));

//     return Focus(
//       focusNode: newsItemFocusNodes[item.id],
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             FocusScope.of(context)
//                 .requestFocus(categoryFocusNodes[_selectedCategory]);
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             context.read<FocusProvider>().forceSubVodFocus();
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.select) {
//             _navigateToVideoScreen(item);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () => _navigateToVideoScreen(item),
//         child: ProfessionalChannelCard(
//           item: item,
//           focusNode: newsItemFocusNodes[item.id]!,
//           onTap: () => _navigateToVideoScreen(item),
//           onColorChange: (color) {
//             if (mounted) {
//               context.read<ColorProvider>().updateColor(color, true);
//             }
//           },
//           index: index,
//           onUpPress: () {
//             FocusScope.of(context)
//                 .requestFocus(categoryFocusNodes[_selectedCategory]);
//           },
//           onDownPress: () {
//             context.read<FocusProvider>().forceSubVodFocus();
//           },
//         ),
//       ),
//     );
//   }

//   void _handleEnterPress(String itemId) {
//     if (itemId == 'view_all') {
//       _navigateToViewAllScreen();
//     } else {
//       final selectedItem = _musicList.firstWhere((item) => item.id == itemId);
//       _navigateToVideoScreen(selectedItem);
//     }
//   }

//   Future<void> _navigateToVideoScreen(NewsItemModel newsItem) async {
//     if (_isNavigating) return;
//     _isNavigating = true;

//     bool shouldPlayVideo = true;
//     bool shouldPop = true;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async {
//             shouldPlayVideo = false;
//             shouldPop = false;
//             return true;
//           },
//           child: LoadingIndicator(),
//         );
//       },
//     );

//     Timer(Duration(seconds: 10), () {
//       _isNavigating = false;
//     });

//     try {
//       String originalUrl = newsItem.url;
//       if (newsItem.streamType == 'YoutubeLive') {
//         for (int i = 0; i < _maxRetries; i++) {
//           try {
//             String updatedUrl =
//                 await _socketService.getUpdatedUrl(newsItem.url);

//             newsItem = NewsItemModel(
//               id: newsItem.id,
//               videoId: '',
//               name: newsItem.name,
//               description: newsItem.description,
//               banner: newsItem.banner,
//               poster: newsItem.poster,
//               category: newsItem.category,
//               url: updatedUrl,
//               streamType: 'M3u8',
//               type: 'M3u8',
//               genres: newsItem.genres,
//               status: newsItem.status,
//               index: newsItem.index,
//               image: '',
//               unUpdatedUrl: '',
//             );
//             break;
//           } catch (e) {
//             if (i == _maxRetries - 1) rethrow;
//             await Future.delayed(Duration(seconds: _retryDelay));
//           }
//         }
//       }

//       if (shouldPop) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//       bool liveStatus = true;

//       if (shouldPlayVideo) {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VideoScreen(
//               videoUrl: newsItem.url,
//               bannerImageUrl: newsItem.banner,
//               startAtPosition: Duration.zero,
//               videoType: newsItem.streamType,
//               channelList: _musicList,
//               isLive: true,
//               isVOD: false,
//               isBannerSlider: false,
//               source: 'isLiveScreen',
//               isSearch: false,
//               videoId: int.tryParse(newsItem.id),
//               unUpdatedUrl: originalUrl,
//               name: newsItem.name,
//               seasonId: null,
//               isLastPlayedStored: false,
//               liveStatus: liveStatus,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (shouldPop) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Something Went Wrong')),
//       );
//     } finally {
//       _isNavigating = false;
//     }
//   }

//   void _navigateToViewAllScreen() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => NewsGridScreen(
//           newsList: _musicList,
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _headerAnimationController.dispose();
//     _categoryAnimationController.dispose();
//     _socketService.dispose();
    
//     for (var node in categoryFocusNodes.values) {
//       node.dispose();
//     }

//     for (var node in newsItemFocusNodes.values) {
//       node.dispose();
//     }

//     moreFocusNode.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
// }






import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/sub_live_screen/news_grid_screen.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/provider/shared_data_provider.dart';
import 'package:mobi_tv_entertainment/video_widget/socket_service.dart';
import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/video_widget/youtube_player.dart';
import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
import 'package:mobi_tv_entertainment/widgets/services/api_service.dart';
import 'package:mobi_tv_entertainment/widgets/small_widgets/empty_state.dart';
import 'package:mobi_tv_entertainment/widgets/small_widgets/error_message.dart';
import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/utils/random_light_color_widget.dart';
import 'channels_category.dart';

// Professional Colors for SubLive (Live TV)
class ProfessionalSubLiveColors {
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

  static List<Color> gradientColors = [
    accentBlue,
    accentPurple,
    accentGreen,
    accentRed,
    accentOrange,
    accentPink,
  ];
}

// Professional Animation Timings
class SubLiveAnimationTiming {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration focus = Duration(milliseconds: 700);
  static const Duration scroll = Duration(milliseconds: 800);
}

// Professional Channel Card Widget
class ProfessionalChannelCard extends StatefulWidget {
  final NewsItemModel item;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;
  final int index;
  final VoidCallback? onUpPress;
  final VoidCallback? onDownPress;

  const ProfessionalChannelCard({
    Key? key,
    required this.item,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
    required this.index,
    this.onUpPress,
    this.onDownPress,
  }) : super(key: key);

  @override
  _ProfessionalChannelCardState createState() =>
      _ProfessionalChannelCardState();
}

class _ProfessionalChannelCardState extends State<ProfessionalChannelCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  Color _dominantColor = ProfessionalSubLiveColors.accentBlue;
  bool _isFocused = false;
  final PaletteColorService _paletteColorService = PaletteColorService();

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: SubLiveAnimationTiming.focus,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: SubLiveAnimationTiming.medium,
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() async {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });

    if (_isFocused) {
      _scaleController.forward();
      _glowController.forward();
      
      if (widget.item.id == 'view_all') {
        _dominantColor = ProfessionalSubLiveColors.accentBlue;
      } else {
        try {
          _dominantColor = await _paletteColorService.getSecondaryColor(
            widget.item.banner,
            fallbackColor: ProfessionalSubLiveColors.accentBlue,
          );
        } catch (e) {
          _dominantColor = ProfessionalSubLiveColors.accentBlue;
        }
      }
      
      widget.onColorChange(_dominantColor);
      HapticFeedback.lightImpact();
      setState(() {});
    } else {
      _scaleController.reverse();
      _glowController.reverse();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: screenWidth * 0.19,
            margin: EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfessionalPoster(screenWidth, screenHeight),
                _buildProfessionalTitle(screenWidth),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
    final posterHeight = _isFocused ? screenHeight * 0.25 : screenHeight * 0.20;

    return Container(
      margin: EdgeInsets.only(top: 15),
      height: posterHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (_isFocused) ...[
            BoxShadow(
              color: _dominantColor.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 3,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: _dominantColor.withOpacity(0.2),
              blurRadius: 45,
              spreadRadius: 6,
              offset: Offset(0, 15),
            ),
          ] else ...[
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            _buildChannelImage(screenWidth, posterHeight),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            _buildLiveBadge(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelImage(double screenWidth, double posterHeight) {
    if (widget.item.id == 'view_all') {
      return _buildViewAllContent(posterHeight);
    }

    final imageUrl = widget.item.banner.isNotEmpty 
        ? widget.item.banner 
        : widget.item.poster;

    return Container(
      width: double.infinity,
      height: posterHeight,
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  _buildImagePlaceholder(posterHeight),
              errorWidget: (context, url, error) =>
                  _buildImagePlaceholder(posterHeight),
            )
          : _buildImagePlaceholder(posterHeight),
    );
  }

  Widget _buildViewAllContent(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isFocused
              ? [
                  _dominantColor.withOpacity(0.8),
                  _dominantColor.withOpacity(0.6),
                  ProfessionalSubLiveColors.cardDark.withOpacity(0.9),
                ]
              : [
                  ProfessionalSubLiveColors.cardDark,
                  ProfessionalSubLiveColors.surfaceDark,
                  ProfessionalSubLiveColors.cardDark.withOpacity(0.8),
                ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(_isFocused ? 0.2 : 0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(_isFocused ? 0.4 : 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.tv_rounded,
                size: _isFocused ? 45 : 35,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'VIEW ALL',
              style: TextStyle(
                color: Colors.white,
                fontSize: _isFocused ? 14 : 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: _isFocused
                        ? _dominantColor.withOpacity(0.6)
                        : Colors.black.withOpacity(0.5),
                    blurRadius: _isFocused ? 8 : 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6),
            // Text(
            //   widget.item.name.toUpperCase(),
            //   style: TextStyle(
            //     color: Colors.white.withOpacity(0.9),
            //     fontSize: 11,
            //     fontWeight: FontWeight.w600,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalSubLiveColors.cardDark,
            ProfessionalSubLiveColors.surfaceDark,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.live_tv_rounded,
            size: height * 0.25,
            color: ProfessionalSubLiveColors.textSecondary,
          ),
          SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              color: ProfessionalSubLiveColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusBorder() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 3,
            color: _dominantColor,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
                end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
                colors: [
                  Colors.transparent,
                  _dominantColor.withOpacity(0.15),
                  Colors.transparent,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveBadge() {
    if (widget.item.id == 'view_all') return SizedBox.shrink();
    
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 4),
            Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoverOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              _dominantColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              widget.item.id == 'view_all' 
                  ? Icons.explore_rounded 
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalTitle(double screenWidth) {
    final channelName = widget.item.name.toUpperCase();

    return Container(
      width: screenWidth * 0.18,
      margin: EdgeInsets.only(top: 10),
      child: AnimatedDefaultTextStyle(
        duration: SubLiveAnimationTiming.medium,
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11,
          fontWeight: FontWeight.w600,
          color: _isFocused
              ? _dominantColor
              : ProfessionalSubLiveColors.textPrimary,
          letterSpacing: 0.5,
          shadows: _isFocused
              ? [
                  Shadow(
                    color: _dominantColor.withOpacity(0.6),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          channelName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// Enhanced NewsItem for backward compatibility
class NewsItem extends StatefulWidget {
  final NewsItemModel item;
  final VoidCallback onTap;
  final ValueChanged<String> onEnterPress;
  final bool hideDescription;
  final FocusNode? focusNode;
  final Function(bool)? onFocusChange;
  final VoidCallback? onUpPress;
  final VoidCallback? onDownPress;

  NewsItem({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onEnterPress,
    this.hideDescription = false,
    this.focusNode,
    this.onFocusChange,
    this.onUpPress,
    this.onDownPress,
  }) : super(key: key);

  @override
  _NewsItemState createState() => _NewsItemState();
}

class _NewsItemState extends State<NewsItem> {
  bool isFocused = false;
  Color dominantColor = Colors.white.withOpacity(0.5);
  final PaletteColorService _paletteColorService = PaletteColorService();

  void _handleFocusChange(bool hasFocus) async {
    setState(() {
      isFocused = hasFocus;
    });

    if (hasFocus) {
      if (widget.item.id == 'view_all') {
        dominantColor = ProfessionalSubLiveColors.accentBlue;
      } else {
        dominantColor = await _paletteColorService.getSecondaryColor(
          widget.item.banner,
          fallbackColor: Colors.grey,
        );
      }
      // Update color using provider
      context.read<ColorProvider>().updateColor(dominantColor, true);
      setState(() {});
    } else {
      // Reset color when item loses focus
      context.read<ColorProvider>().resetColor();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: _handleFocusChange,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            widget.onDownPress?.call();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            widget.onUpPress?.call();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.select) {
            widget.onEnterPress(widget.item.id);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: EdgeInsets.only(left: 40),
          child: ProfessionalChannelCard(
            item: widget.item,
            focusNode: widget.focusNode!,
            onTap: widget.onTap,
            onColorChange: (color) {
              if (mounted) {
                context.read<ColorProvider>().updateColor(color, true);
              }
            },
            index: 0,
            onUpPress: widget.onUpPress,
            onDownPress: widget.onDownPress,
          ),
        ),
      ),
    );
  }
}

// Enhanced SubLiveScreen with Professional UI
class SubLiveScreen extends StatefulWidget {
  final Function(bool)? onFocusChange;
  final FocusNode focusNode;

  const SubLiveScreen({
    Key? key, 
    this.onFocusChange, 
    required this.focusNode
  }) : super(key: key);

  @override
  _SubLiveScreenState createState() => _SubLiveScreenState();
}

class _SubLiveScreenState extends State<SubLiveScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  // Data
  Map<int, Color> _nodeColors = {};
  Map<String, FocusNode> newsItemFocusNodes = {};
  List<NewsItemModel> _musicList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isNavigating = false;
  String _selectedCategory = 'Live';
  int _maxRetries = 3;
  int _retryDelay = 5;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _categoryAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _categoryFadeAnimation;

  // Focus Management
  final ScrollController _scrollController = ScrollController();
  Map<String, FocusNode> categoryFocusNodes = {};
  late FocusNode moreFocusNode;
  late FocusNode viewAllFocusNode; // 🔧 NEW: Dedicated View All focus node

  // Services
  final SocketService _socketService = SocketService();
  final ApiService _apiService = ApiService();
  final PaletteColorService _paletteColorService = PaletteColorService();

  final List<String> categories = [
    'Live',
    'Entertainment',
    'Music',
    'Movie',
    'News',
    'Sports',
    'Religious'
  ];

  @override
  void initState() {
    super.initState();
    
    _initializeAnimations();
    _initializeFocusManagement();
    _initializeServices();
    
    // Start with fetching data immediately and then load cached data
    _loadCachedDataAndFetchMusic();
    
    // Also call fetchData as fallback
    fetchData();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: SubLiveAnimationTiming.slow,
      vsync: this,
    );

    _categoryAnimationController = AnimationController(
      duration: SubLiveAnimationTiming.slow,
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _categoryFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _categoryAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeFocusManagement() {
    // Initialize category focus nodes
    for (var category in categories) {
      categoryFocusNodes.putIfAbsent(category, () => FocusNode());
    }

    // Initialize more button focus node
    moreFocusNode = FocusNode();
    
    // 🔧 NEW: Initialize View All focus node
    viewAllFocusNode = FocusNode();

    // Add focus listener to first category
    categoryFocusNodes[categories.first]!.addListener(() {
      if (categoryFocusNodes[categories.first]!.hasFocus) {
        widget.onFocusChange?.call(true);
      }
    });

    // Register initial focus in post frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final firstCategoryNode = categoryFocusNodes[categories.first];
      if (firstCategoryNode != null) {
        context
            .read<FocusProvider>()
            .setFirstMusicItemFocusNode(firstCategoryNode);
      } else if (_musicList.isNotEmpty) {
        final firstItemId = _musicList[0].id;
        if (newsItemFocusNodes.containsKey(firstItemId)) {
          final focusNode = newsItemFocusNodes[firstItemId]!;
          context.read<FocusProvider>().setFirstMusicItemFocusNode(focusNode);
        }
      }
    });
  }

  void _initializeServices() {
    _socketService.initSocket();
    
    _apiService.updateStream.listen((hasChanges) {
      if (hasChanges) {
        _loadCachedDataAndFetchMusic();
      }
    });
  }

  // Add color generator function
  Color _generateRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  Future<void> _loadCachedDataAndFetchMusic() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Step 1: Load cached data first
      await _loadCachedMusicData();
      
      // Step 2: If no cached data or musicList is empty, fetch fresh data
      if (_musicList.isEmpty) {
        await fetchData(); // Call fetchData directly for fresh API call
      } else {
        await _fetchMusicInBackground();
      }
      
      // Start animations after data loads
      _headerAnimationController.forward();
      _categoryAnimationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCachedMusicData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedMusic = prefs.getString('music_list');

      if (cachedMusic != null) {
        final List<dynamic> cachedData = json.decode(cachedMusic);
        setState(() {
          _musicList =
              cachedData.map((item) => NewsItemModel.fromJson(item)).toList();
          _isLoading = false;
        });
        _initializeNewsItemFocusNodes();
      }
    } catch (e) {
    }
  }

  Future<void> _fetchMusicInBackground() async {
    try {
      
      // Use the same logic as fetchData but for background update
      await _apiService.fetchSettings();
      await _apiService.fetchEntertainment();
      
      List<NewsItemModel> newMusicList = [];
      
      switch (_selectedCategory.toLowerCase()) {
        case 'live':
          newMusicList = _apiService.allChannelList;
          break;
        case 'entertainment':
          newMusicList = _apiService.entertainmentList;
          break;
        case 'music':
          newMusicList = _apiService.musicList;
          break;
        case 'movie':
          newMusicList = _apiService.movieList;
          break;
        case 'news':
          newMusicList = _apiService.newsList;
          break;
        case 'sports':
          newMusicList = _apiService.sportsList;
          break;
        case 'religious':
          newMusicList = _apiService.religiousList;
          break;
        default:
          newMusicList = _apiService.musicList;
      }

      final prefs = await SharedPreferences.getInstance();
      final cachedMusic = prefs.getString('music_list');
      final String newMusicJson = json.encode(newMusicList.map((item) => item.toJson()).toList());

      if (cachedMusic == null || cachedMusic != newMusicJson) {
        await prefs.setString('music_list', newMusicJson);
        
        if (mounted) {
          setState(() {
            _musicList = newMusicList;
          });
          _initializeNewsItemFocusNodes();
        }
      } else {
      }
    } catch (e, stacktrace) {
      // Don't update UI for background fetch errors
    }
  }

  void _initializeNewsItemFocusNodes() {
    newsItemFocusNodes.clear();
    for (var item in _musicList) {
      newsItemFocusNodes[item.id] = FocusNode()
        ..addListener(() {
          if (newsItemFocusNodes[item.id]!.hasFocus) {
            _scrollToFocusedItem(item.id);
          }
        });
    }
  }

  void _scrollToFocusedItem(String itemId) {
    if (newsItemFocusNodes[itemId] != null &&
        newsItemFocusNodes[itemId]!.hasFocus) {
      Scrollable.ensureVisible(
        newsItemFocusNodes[itemId]!.context!,
        alignment: 0.25,
        duration: Duration(milliseconds: 800),
        curve: Curves.linear,
      );
    }
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {

      await _apiService.fetchSettings();

      await _apiService.fetchEntertainment();

      setState(() {
        _musicList.clear();


        // Use the selected category to determine which list to add
        switch (_selectedCategory.toLowerCase()) {
          case 'live':
            _musicList.addAll(_apiService.allChannelList);
            break;
          case 'entertainment':
            _musicList.addAll(_apiService.entertainmentList);
            break;
          case 'music':
            _musicList.addAll(_apiService.musicList);
            break;
          case 'movie':
            _musicList.addAll(_apiService.movieList);
            break;
          case 'news':
            _musicList.addAll(_apiService.newsList);
            break;
          case 'sports':
            _musicList.addAll(_apiService.sportsList);
            break;
          case 'religious':
            _musicList.addAll(_apiService.religiousList);
            break;
          default:
            _musicList.addAll(_apiService.musicList);
        }


        // Debug: Print first few items in _musicList
        if (_musicList.isNotEmpty) {
        } else {
        }

        _initializeNewsItemFocusNodes();
        _isLoading = false;
      });

      // Save to cache after successful fetch
      try {
        final prefs = await SharedPreferences.getInstance();
        final String musicJson = json.encode(_musicList.map((item) => item.toJson()).toList());
        await prefs.setString('music_list', musicJson);
      } catch (cacheError) {
        // Don't fail the whole operation if cache save fails
      }

    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  void _scrollToFirstItem() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<ColorProvider>(
      builder: (context, colorProv, child) {
        final bgColor = colorProv.isItemFocused
            ? colorProv.dominantColor.withOpacity(0.1)
            : ProfessionalSubLiveColors.primaryDark;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                bgColor,
                ProfessionalSubLiveColors.primaryDark,
                ProfessionalSubLiveColors.surfaceDark.withOpacity(0.5),
              ],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: screenhgt * 0.01),
              _buildProfessionalCategoryButtons(),
              Expanded(child: _buildBody()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfessionalCategoryButtons() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: screenhgt * 0.01),
        height: screenhgt * 0.1,
        child: Row(
          children: [
            ...categories.asMap().entries.map((entry) {
              int index = entry.key;
              String category = entry.value;
              final focusNode = categoryFocusNodes[category]!;

              return _buildCategoryButton(category, index, focusNode);
            }).toList(),
            _buildMoreButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category, int index, FocusNode focusNode) {
    return Expanded(
      child: Focus(
        focusNode: focusNode,
        onFocusChange: (hasFocus) {
          setState(() {
            if (hasFocus) {
              final randomColor = _generateRandomColor();
              context.read<ColorProvider>().updateColor(randomColor, true);
            } else {
              context.read<ColorProvider>().resetColor();
            }
          });
        },
        onKey: (FocusNode node, RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              final sharedDataProvider = context.read<SharedDataProvider>();
              final lastPlayedVideos = sharedDataProvider.lastPlayedVideos;

              if (lastPlayedVideos.isNotEmpty) {
                context.read<FocusProvider>().requestFirstLastPlayedFocus();
                return KeyEventResult.handled;
              }
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              if (_musicList.isNotEmpty) {
                _scrollToFirstItem();
                Future.delayed(Duration(milliseconds: 150), () {
                  final firstId = _musicList[0].id;
                  final nextNode = newsItemFocusNodes[firstId];
                  if (nextNode != null && nextNode.context != null) {
                    FocusScope.of(context).requestFocus(nextNode);
                    Future.delayed(Duration(milliseconds: 50), () {
                      _scrollToFocusedItem(firstId);
                    });
                  }
                });
                return KeyEventResult.handled;
              }
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              if (index == categories.length - 1) {
                FocusScope.of(context).requestFocus(moreFocusNode);
              } else {
                FocusScope.of(context).requestFocus(
                    categoryFocusNodes[categories[index + 1]]);
              }
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              if (index == 0) {
                FocusScope.of(context).requestFocus(moreFocusNode);
              } else {
                FocusScope.of(context).requestFocus(
                    categoryFocusNodes[categories[index - 1]]);
              }
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.select) {
              _selectCategory(category);
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Builder(
          builder: (BuildContext context) {
            final bool hasFocus = Focus.of(context).hasFocus;
            final currentColor = context.watch<ColorProvider>().dominantColor;
            
            return Container(
              margin: EdgeInsets.symmetric(horizontal: screenwdt * 0.005),
              decoration: BoxDecoration(
                gradient: hasFocus
                    ? LinearGradient(
                        colors: [
                          currentColor.withOpacity(0.2),
                          currentColor.withOpacity(0.1),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasFocus ? currentColor : Colors.transparent,
                  width: 2,
                ),
                boxShadow: hasFocus
                    ? [
                        BoxShadow(
                          color: currentColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: TextButton(
                onPressed: () => _selectCategory(category),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                ),
                child: Center(
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      fontSize: menutextsz / 1.2,
                      color: _selectedCategory == category
                          ? ProfessionalSubLiveColors.accentBlue
                          : (hasFocus ? currentColor : hintColor),
                      fontWeight: _selectedCategory == category || hasFocus
                          ? FontWeight.bold
                          : FontWeight.w500,
                      letterSpacing: 0.5,
                      shadows: hasFocus
                          ? [
                              Shadow(
                                color: currentColor.withOpacity(0.6),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMoreButton() {
    return Expanded(
      child: Focus(
        focusNode: moreFocusNode,
        onFocusChange: (hasFocus) {
          setState(() {
            if (hasFocus) {
              final randomColor = _generateRandomColor();
              context.read<ColorProvider>().updateColor(randomColor, true);
            } else {
              context.read<ColorProvider>().resetColor();
            }
          });
        },
        onKey: (FocusNode node, RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              FocusScope.of(context)
                  .requestFocus(categoryFocusNodes[categories.first]);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              FocusScope.of(context)
                  .requestFocus(categoryFocusNodes[categories.last]);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              final sharedDataProvider = context.read<SharedDataProvider>();
              final lastPlayedVideos = sharedDataProvider.lastPlayedVideos;

              if (lastPlayedVideos.isNotEmpty) {
                context.read<FocusProvider>().requestFirstLastPlayedFocus();
                return KeyEventResult.handled;
              }
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              if (_musicList.isNotEmpty) {
                _scrollToFirstItem();
                Future.delayed(Duration(milliseconds: 150), () {
                  final firstId = _musicList[0].id;
                  final nextNode = newsItemFocusNodes[firstId];
                  if (nextNode != null && nextNode.context != null) {
                    FocusScope.of(context).requestFocus(nextNode);
                    Future.delayed(Duration(milliseconds: 50), () {
                      _scrollToFocusedItem(firstId);
                    });
                  }
                });
                return KeyEventResult.handled;
              }
            } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.select) {
              _navigateToChannelsCategory();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Builder(
          builder: (BuildContext context) {
            final bool hasFocus = Focus.of(context).hasFocus;
            final Color currentColor = context.watch<ColorProvider>().dominantColor;
            
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: screenwdt * 0.005),
                decoration: BoxDecoration(
                  gradient: hasFocus
                      ? LinearGradient(
                          colors: [
                            currentColor.withOpacity(0.2),
                            currentColor.withOpacity(0.1),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasFocus ? currentColor : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: hasFocus
                      ? [
                          BoxShadow(
                            color: currentColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: TextButton(
                  onPressed: _navigateToChannelsCategory,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Text(
                    'MORE',
                    style: TextStyle(
                      fontSize: menutextsz,
                      color: hasFocus ? currentColor : hintColor,
                      fontWeight: hasFocus ? FontWeight.bold : FontWeight.w500,
                      letterSpacing: 0.5,
                      shadows: hasFocus
                          ? [
                              Shadow(
                                color: currentColor.withOpacity(0.6),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToChannelsCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChannelsCategory(),
      ),
    );
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });

    fetchData().then((_) {
      if (_musicList.isNotEmpty) {
        final firstItemId = _musicList[0].id;
        if (newsItemFocusNodes.containsKey(firstItemId)) {
          context
              .read<FocusProvider>()
              .requestNewsItemFocusNode(newsItemFocusNodes[firstItemId]!);
        }
      }
    });
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildProfessionalLoadingIndicator();
    } else if (_errorMessage.isNotEmpty) {
      return ErrorMessage(message: _errorMessage);
    } else if (_musicList.isEmpty) {
      return EmptyState(message: 'No items found for $_selectedCategory');
    } else {
      return _buildChannelsList();
    }
  }

  Widget _buildProfessionalLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  ProfessionalSubLiveColors.accentPurple,
                  ProfessionalSubLiveColors.accentBlue,
                  ProfessionalSubLiveColors.accentGreen,
                  ProfessionalSubLiveColors.accentPurple,
                ],
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ProfessionalSubLiveColors.primaryDark,
              ),
              child: Icon(
                Icons.live_tv_rounded,
                color: ProfessionalSubLiveColors.textPrimary,
                size: 28,
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading $_selectedCategory Channels...',
            style: TextStyle(
              color: ProfessionalSubLiveColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: 200,
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: ProfessionalSubLiveColors.surfaceDark,
            ),
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                ProfessionalSubLiveColors.accentPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelsList() {
    return FadeTransition(
      opacity: _categoryFadeAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.38,
        child: ListView.builder(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          itemCount: _musicList.length > 10 ? 11 : _musicList.length,
          itemBuilder: (context, index) {
            if (_musicList.length > 10 && index == 10) {
              return _buildViewAllItem();
            }
            return _buildChannelItem(_musicList[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildViewAllItem() {
    final viewAllItem = NewsItemModel(
      id: 'view_all',
      name: _selectedCategory.toUpperCase(),
      description: ' $_selectedCategory ',
      banner: '',
      poster: '',
      category: '',
      url: '',
      streamType: '',
      type: '',
      genres: '',
      status: '',
      videoId: '',
      index: '',
      image: '',
      unUpdatedUrl: '',
    );

    return Focus(
      focusNode: viewAllFocusNode, // 🔧 FIX: Use dedicated focus node
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            // Stay on View All, no further navigation
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            // 🔧 FIX: Go back to 10th item (index 9)
            if (_musicList.length > 9) {
              final lastDisplayedItem = _musicList[9];
              final lastNode = newsItemFocusNodes[lastDisplayedItem.id];
              if (lastNode != null) {
                FocusScope.of(context).requestFocus(lastNode);
              }
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            FocusScope.of(context)
                .requestFocus(categoryFocusNodes[_selectedCategory]);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            context.read<FocusProvider>().requestSubVodFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.select) {
            _navigateToViewAllScreen();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _navigateToViewAllScreen,
        child: ProfessionalChannelCard(
          item: viewAllItem,
          focusNode: viewAllFocusNode, // 🔧 FIX: Use dedicated focus node
          onTap: _navigateToViewAllScreen,
          onColorChange: (color) {
            if (mounted) {
              context.read<ColorProvider>().updateColor(color, true);
            }
          },
          index: 10,
          onUpPress: () {
            FocusScope.of(context)
                .requestFocus(categoryFocusNodes[_selectedCategory]);
          },
          onDownPress: () {
            context.read<FocusProvider>().requestSubVodFocus();
          },
        ),
      ),
    );
  }

  Widget _buildChannelItem(NewsItemModel item, int index) {
    newsItemFocusNodes.putIfAbsent(
        item.id,
        () => FocusNode()
          ..addListener(() {
            if (newsItemFocusNodes[item.id]!.hasFocus) {
              _scrollToFocusedItem(item.id);
            }
          }));

    return Focus(
      focusNode: newsItemFocusNodes[item.id],
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            FocusScope.of(context)
                .requestFocus(categoryFocusNodes[_selectedCategory]);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            context.read<FocusProvider>().forceSubVodFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            // 🔧 PERFECT FIX: 10th item (index 9) के बाद View All पर focus करें
            if (_musicList.length > 10 && index == 9) {
              // यह 10th item है, अब View All पर focus करें
              FocusScope.of(context).requestFocus(viewAllFocusNode);
              return KeyEventResult.handled;
            } else if (index < _musicList.length - 1 && index < 9) {
              // Normal navigation to next item (केवल पहले 10 items के लिए)
              final nextItem = _musicList[index + 1];
              final nextNode = newsItemFocusNodes[nextItem.id];
              if (nextNode != null) {
                FocusScope.of(context).requestFocus(nextNode);
              }
              return KeyEventResult.handled;
            }
            // अगर यह last item है या 10+ items हैं, तो कुछ नहीं करें
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              final prevItem = _musicList[index - 1];
              final prevNode = newsItemFocusNodes[prevItem.id];
              if (prevNode != null) {
                FocusScope.of(context).requestFocus(prevNode);
              }
              return KeyEventResult.handled;
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.select) {
            _navigateToVideoScreen(item);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _navigateToVideoScreen(item),
        child: ProfessionalChannelCard(
          item: item,
          focusNode: newsItemFocusNodes[item.id]!,
          onTap: () => _navigateToVideoScreen(item),
          onColorChange: (color) {
            if (mounted) {
              context.read<ColorProvider>().updateColor(color, true);
            }
          },
          index: index,
          onUpPress: () {
            FocusScope.of(context)
                .requestFocus(categoryFocusNodes[_selectedCategory]);
          },
          onDownPress: () {
            context.read<FocusProvider>().forceSubVodFocus();
          },
        ),
      ),
    );
  }

  void _handleEnterPress(String itemId) {
    if (itemId == 'view_all') {
      _navigateToViewAllScreen();
    } else {
      final selectedItem = _musicList.firstWhere((item) => item.id == itemId);
      _navigateToVideoScreen(selectedItem);
    }
  }

  Future<void> _navigateToVideoScreen(NewsItemModel newsItem) async {
    if (_isNavigating) return;
    _isNavigating = true;

    bool shouldPlayVideo = true;
    bool shouldPop = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            shouldPlayVideo = false;
            shouldPop = false;
            return true;
          },
          child: LoadingIndicator(),
        );
      },
    );

    Timer(Duration(seconds: 10), () {
      _isNavigating = false;
    });

    try {
      String originalUrl = newsItem.url;
      // if (newsItem.streamType == 'YoutubeLive') {
        // for (int i = 0; i < _maxRetries; i++) {
          // try {
            // String updatedUrl =
                // await _socketService.getUpdatedUrl(newsItem.url);

            newsItem = NewsItemModel(
              id: newsItem.id,
              videoId: '',
              name: newsItem.name,
              description: newsItem.description,
              banner: newsItem.banner,
              poster: newsItem.poster,
              category: newsItem.category,
              url: originalUrl,
              streamType: 'M3u8',
              type: 'M3u8',
              genres: newsItem.genres,
              status: newsItem.status,
              index: newsItem.index,
              image: '',
              unUpdatedUrl: '',
            );
            // break;
          } catch (e) {
            // if (i == _maxRetries - 1) rethrow;
            // await Future.delayed(Duration(seconds: _retryDelay));
          }
        // }
      // }

      if (shouldPop) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      bool liveStatus = true;

      if (shouldPlayVideo) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScreen(
              videoUrl: newsItem.url,
              bannerImageUrl: newsItem.banner,
              startAtPosition: Duration.zero,
              videoType: newsItem.streamType,
              channelList: _musicList,
              isLive: true,
              isVOD: false,
              isBannerSlider: false,
              source: 'isLiveScreen',
              isSearch: false,
              videoId: int.tryParse(newsItem.id),
              unUpdatedUrl: newsItem.url,
              name: newsItem.name,
              seasonId: null,
              isLastPlayedStored: false,
              liveStatus: liveStatus,
            ),
              //              builder: (context) => YouTubePlayerScreen(
              //    videoData: VideoData(
              //      id: newsItem.id,
              //      title: newsItem.name,
              //      youtubeUrl: newsItem.url,
              //      thumbnail: newsItem.banner,
              //      description:'',
              //    ),
              //    playlist: _musicList.map((m) => VideoData(
              //      id: m.id,
              //      title: m.name,
              //      youtubeUrl: m.url,
              //      thumbnail: m.banner,
              //      description: m.description,
              //    )).toList(),
              // ),
          ),
        );
      }
    // } catch (e) {
    //   if (shouldPop) {
    //     Navigator.of(context, rootNavigator: true).pop();
    //   }
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Something Went Wrong')),
    //   );
    // } finally {
    //   _isNavigating = false;
    // }
  }

  void _navigateToViewAllScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsGridScreen(
          newsList: _musicList,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _categoryAnimationController.dispose();
    _socketService.dispose();
    
    for (var node in categoryFocusNodes.values) {
      node.dispose();
    }

    for (var node in newsItemFocusNodes.values) {
      node.dispose();
    }

    moreFocusNode.dispose();
    viewAllFocusNode.dispose(); // 🔧 NEW: Dispose View All focus node
    _scrollController.dispose();
    super.dispose();
  }
}