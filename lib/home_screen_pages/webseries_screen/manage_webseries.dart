// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart'
//     as loading_indicator;
// import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../main.dart';
// import 'focussable_webseries_widget.dart';
// import '../../widgets/models/news_item_model.dart';
// import 'webseries_details_page.dart'; // Assuming you have this page

// class ManageWebseries extends StatefulWidget {
//   final FocusNode focusNode;
//   const ManageWebseries({Key? key, required this.focusNode}) : super(key: key);

//   @override
//   _ManageWebseriesState createState() => _ManageWebseriesState();
// }

// class _ManageWebseriesState extends State<ManageWebseries>
//     with AutomaticKeepAliveClientMixin {
//   List<Map<String, dynamic>> categories = [];
//   bool isLoading = true;
//   String debugMessage = "";

//   Map<String, Map<String, FocusNode>> focusNodesMap = {};
//   final ScrollController _scrollController = ScrollController();

//   @override
//   bool get wantKeepAlive => true;

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _loadCachedWebseriesDataAndFetch();
//   // }

//   // 1. अपनी existing _initializeFocusNodes method को replace करें:
//   void _initializeFocusNodes() {
//     focusNodesMap.clear();
//     for (var cat in categories) {
//       final catId = '${cat['id']}';
//       focusNodesMap[catId] = {};
//       final webSeriesList = cat['web_series'] as List<dynamic>;

//       for (int idx = 0; idx < webSeriesList.length; idx++) {
//         final series = webSeriesList[idx];
//         final seriesId = '${series['id']}';

//         // Create focus node with debug label
//         final focusNode =
//             FocusNode(debugLabel: 'webseries_${catId}_${seriesId}_$idx');

//         // ✅ IMPORTANT: Focus listener में scroll logic
//         focusNode.addListener(() {
//           if (focusNode.hasFocus && mounted && _scrollController.hasClients) {
//             // Direct scroll call - यह guaranteed काम करेगा
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _performReliableScroll(itemIndex: idx);
//             });
//           }
//         });

//         focusNodesMap[catId]![seriesId] = focusNode;
//       }
//     }
//   }

// // 2. Simple और Reliable Scroll Method:
//   void _performReliableScroll({required int itemIndex}) {
//     if (!mounted || !_scrollController.hasClients) return;

//     try {
//       // Calculate exact position based on your UI measurements
//       final double itemWidth =
//           MediaQuery.of(context).size.width * 0.19; // Your item width ratio
//       final double horizontalPadding = 0.0; // Your horizontal padding per item
//       final double totalItemWidth = itemWidth + (horizontalPadding * 2);

//       // Calculate target scroll position
//       final double targetOffset = itemIndex * totalItemWidth;
//       final double maxOffset = _scrollController.position.maxScrollExtent;
//       final double clampedOffset = targetOffset.clamp(0.0, maxOffset);

//       // Perform scroll animation
//       _scrollController
//           .animateTo(
//             clampedOffset,
//             duration: const Duration(milliseconds: 500),
//             curve: Curves.linear,
//           )
//           .then((_) {})
//           .catchError((error) {});
//     } catch (e) {}
//   }

// // 4. Build method में scroll controller का proper setup:
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     // Debug scroll state
//     if (_scrollController.hasClients) {
//     } else {}

//     return Consumer<ColorProvider>(
//       builder: (context, colorProv, child) {
//         // ... existing code ...

//         final bgColor = colorProv.isItemFocused
//             ? colorProv.dominantColor.withOpacity(0.3)
//             : Colors.black;

//         return Container(
//           color: bgColor,
//           child: Container(
//             color: Colors.black54,
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Column(
//                 children: List.generate(categories.length, (catIdx) {
//                   final cat = categories[catIdx];
//                   final list = cat['web_series'] as List<dynamic>;
//                   final catId = '${cat['id']}';

//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         child: Text(
//                           cat['category'].toString().toUpperCase(),
//                           style: TextStyle(
//                             color: hintColor,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),

//                       // ✅ Enhanced ListView with better key and controller
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.34,
//                         child: ListView.builder(
//                           key: ValueKey(
//                               'webseries_listview_$catId'), // Unique key
//                           controller: _scrollController,
//                           scrollDirection: Axis.horizontal,
//                           physics: const BouncingScrollPhysics(),

//                           // ✅ IMPORTANT: Ensure physics allow scrolling
//                           clipBehavior: Clip.none,

//                           itemCount: list.length > 7 ? 8 : list.length + 1,
//                           itemBuilder: (context, idx) {
//                             if ((list.length >= 7 && idx == 7) ||
//                                 (list.length < 7 && idx == list.length)) {
//                               return ViewAllWidget(
//                                 categoryText: cat['category'],
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => CategoryMoviesGridView(
//                                         category: cat,
//                                         web_series: list,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             }

//                             final item = list[idx];
//                             final sid = '${item['id']}';
//                             final node = focusNodesMap[catId]?[sid];

//                             return Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 0),
//                               child: FocussableWebseriesWidget(
//                                 // key: ValueKey('webseries_${item['id']}_$idx'),
//                                 key: ValueKey('webseries_${item['id']}_$idx'),
//                                 imageUrl: item['poster']?.toString() ?? '',
//                                 name: item['name']?.toString() ?? '',
//                                 focusNode: node ?? FocusNode(),

//                                 onFocusChange: (hasFocus) {
//                                   if (hasFocus) {
//                                     _performReliableScroll(itemIndex: idx);

//                                     // Backup scroll
//                                     Future.delayed(Duration(milliseconds: 200),
//                                         () {
//                                       if (mounted)
//                                         _performReliableScroll(itemIndex: idx);
//                                     });
//                                   }
//                                 },

//                                 onUpPress: () {
//                                   context
//                                       .read<FocusProvider>()
//                                       .requestFirstMoviesFocus();
//                                 },

//                                 onTap: () => navigateToDetails(
//                                   item,
//                                   cat['category'],
//                                   item['banner']?.toString() ??
//                                       item['poster']?.toString() ??
//                                       '',
//                                   item['name']?.toString() ?? '',
//                                   catIdx,
//                                 ),

//                                 fetchPaletteColor: (url) =>
//                                     PaletteColorService()
//                                         .getSecondaryColor(url),
//                               ),
//                             );
//                           },
//                         ),
//                       ),

//                       const SizedBox(height: 16),
//                     ],
//                   );
//                 }),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

// // 5. ScrollController के साथ debug helper:
//   void debugScrollController() {
//     if (_scrollController.hasClients) {
//       final position = _scrollController.position;
//     }
//   }

// // Fixed _sortByIndex method - यह main issue है:

//   List<dynamic> _sortByIndex(List<dynamic> list) {
//     try {
//       list.sort((a, b) {
//         // ✅ Fix: Handle both int and string types for index
//         dynamic indexA = a['index'];
//         dynamic indexB = b['index'];

//         int numA = 0;
//         int numB = 0;

//         // Handle different types of index values
//         if (indexA is int) {
//           numA = indexA;
//         } else if (indexA is String) {
//           numA = int.tryParse(indexA) ?? 0;
//         } else {
//           numA = 0;
//         }

//         if (indexB is int) {
//           numB = indexB;
//         } else if (indexB is String) {
//           numB = int.tryParse(indexB) ?? 0;
//         } else {
//           numB = 0;
//         }

//         return numA.compareTo(numB);
//       });

//       return list;
//     } catch (e) {
//       return list; // Return unsorted list if sorting fails
//     }
//   }

// // Updated _fetchWebseriesInBackground method with better error handling:
//   Future<void> _fetchWebseriesInBackground() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = AuthManager.authKey;
//       if (authKey.isEmpty) {
//         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//       }

//       final response = await http.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         if (response.body.isEmpty) {
//           return;
//         }

//         try {
//           final List<dynamic> flatData = jsonDecode(response.body);

//           if (flatData.isEmpty) {
//             setState(() {
//               categories = [];
//               isLoading = false;
//             });
//             return;
//           }

//           // Log first item structure
//           if (flatData.isNotEmpty) {}

//           // ✅ Fix: Simple grouping without custom_tag dependency
//           final Map<String, List<dynamic>> grouped = {};

//           // Group all items into "Web Series" category
//           if (flatData.isNotEmpty) {
//             grouped['Web Series'] = flatData;
//           }

//           // ✅ Fix: Create categories with proper error handling
//           final List<Map<String, dynamic>> newCats = [];

//           for (var entry in grouped.entries) {
//             try {
//               final sortedItems = _sortByIndex(List.from(entry.value));
//               newCats.add({
//                 'id': '1', // Default ID since no custom_tag
//                 'category': entry.key,
//                 'web_series': sortedItems,
//               });
//             } catch (e) {
//               // Add category without sorting if sorting fails
//               newCats.add({
//                 'id': '1',
//                 'category': entry.key,
//                 'web_series': entry.value,
//               });
//             }
//           }

//           // ✅ Fix: Safe JSON encoding with error handling
//           try {
//             final newJson = jsonEncode(newCats);
//             final cached = prefs.getString('webseries_list');

//             if (cached == null || cached != newJson) {
//               await prefs.setString('webseries_list', newJson);

//               setState(() {
//                 categories = newCats;
//                 _initializeFocusNodes();
//               });
//               _registerWebseriesFocus();
//             } else {
//               // Even if cache unchanged, ensure UI is updated
//               setState(() {
//                 categories = newCats;
//                 _initializeFocusNodes();
//               });
//               _registerWebseriesFocus();
//             }
//           } catch (e) {
//             // Still update UI even if caching fails
//             setState(() {
//               categories = newCats;
//               _initializeFocusNodes();
//             });
//             _registerWebseriesFocus();
//           }
//         } catch (e) {}
//       } else {}
//     } catch (e) {
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

// // Also fix the fetchData method:
//   Future<void> fetchData() async {
//     if (!mounted) return;
//     setState(() {
//       isLoading = true;
//       debugMessage = "Loading...";
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = AuthManager.authKey;
//       if (authKey.isEmpty) {
//         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//       }

//       final response = await http.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 15));

//       if (!mounted) return;

//       if (response.statusCode == 200 && response.body.isNotEmpty) {
//         final List<dynamic> flatData = jsonDecode(response.body);

//         // ✅ Fix: Simple grouping
//         final Map<String, List<dynamic>> grouped = {};

//         if (flatData.isNotEmpty) {
//           grouped['Web Series'] = flatData;
//         }

//         final List<Map<String, dynamic>> nonEmptyCategories = [];

//         for (var entry in grouped.entries) {
//           try {
//             final sortedItems = _sortByIndex(List.from(entry.value));
//             nonEmptyCategories.add({
//               'id': '1',
//               'category': entry.key,
//               'web_series': sortedItems,
//             });
//           } catch (e) {
//             nonEmptyCategories.add({
//               'id': '1',
//               'category': entry.key,
//               'web_series': entry.value,
//             });
//           }
//         }

//         Provider.of<FocusProvider>(context, listen: false)
//             .updateCategoryCountWebseries(nonEmptyCategories.length);

//         final Map<String, Map<String, FocusNode>> newFocusMap = {};
//         for (var cat in nonEmptyCategories) {
//           final cid = '${cat['id']}';
//           newFocusMap[cid] = {
//             for (var series in cat['web_series']) '${series['id']}': FocusNode()
//           };
//         }

//         setState(() {
//           categories = nonEmptyCategories;
//           focusNodesMap = newFocusMap;
//           isLoading = false;
//           debugMessage = "Loaded ${nonEmptyCategories.length} categories";
//         });

//         Future.delayed(const Duration(milliseconds: 300), () {
//           if (mounted && categories.isNotEmpty) {
//             final firstCid = '${categories[0]['id']}';
//             final firstSid =
//                 '${(categories[0]['web_series'] as List).first['id']}';
//             final node = focusNodesMap[firstCid]?[firstSid];
//             if (node != null) {
//               Provider.of<FocusProvider>(context, listen: false)
//                   .setFirstManageWebseriesFocusNode(node);
//             }
//           }
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//           debugMessage = "Error: ${response.statusCode}";
//         });

//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   SnackBar(content: Text('API Error: ${response.statusCode}')),
//         // );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         debugMessage = "Network Error: $e";
//       });
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   SnackBar(content: Text('Network Error: $e')),
//       // );
//     }
//   }

// // Debug method to check categories state:
//   void debugCategoriesState() {
//     if (categories.isNotEmpty) {
//       // for (int i = 0; i < categories.length; i++) {
//       //   final cat = categories[i];
//       // }
//     }
//   }

// // 3. अगर आप category based grouping चाहते हैं तो यह function use करें:
//   Map<String, List<dynamic>> createSmartGrouping(List<dynamic> flatData) {
//     final Map<String, List<dynamic>> grouped = {};

//     for (var item in flatData) {
//       String categoryName = 'Web Series'; // Default category

//       // आप अलग-अलग fields के base पर categories बना सकते हैं:

//       // Option 1: content_type के base पर
//       if (item['content_type'] == 1) {
//         categoryName = 'Movies';
//       } else if (item['content_type'] == 2) {
//         categoryName = 'Web Series';
//       }

//       grouped.putIfAbsent(categoryName, () => []).add(item);
//     }

//     return grouped;
//   }

//   @override
//   void initState() {
//     super.initState();

//     // Check SharedPreferences
//     SharedPreferences.getInstance().then((prefs) {
//       final storedKey = prefs.getString('auth_key');
//       final cachedData = prefs.getString('webseries_list');
//     });

//     // Manual API test
//     // testWebseriesAPI();

//     // Regular initialization
//     _loadCachedWebseriesDataAndFetch();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<FocusProvider>(context, listen: false)
//           .setwebseriesScrollController(_scrollController);

//       if (mounted && categories.isNotEmpty) {
//         final firstCid = '${categories[0]['id']}';
//         final firstSid = '${categories[0]['web_series'].first['id']}';
//         final node = focusNodesMap[firstCid]?[firstSid];
//         if (node != null) {
//           Provider.of<FocusProvider>(context, listen: false)
//               .setFirstManageWebseriesFocusNode(node);
//         }
//       }
//     });
//   }

//   Future<void> _loadCachedWebseriesDataAndFetch() async {
//     setState(() {
//       isLoading = true;
//       debugMessage = '';
//     });

//     try {
//       // Load cached data
//       final prefs = await SharedPreferences.getInstance();
//       final cached = prefs.getString('webseries_list');
//       if (cached != null) {
//         final List<dynamic> cachedData = jsonDecode(cached);
//         setState(() {
//           categories = List<Map<String, dynamic>>.from(cachedData);
//           _initializeFocusNodes(); // Add this line
//           isLoading = false;
//         });
//         _registerWebseriesFocus(); // Add this line
//       }

//       // Background fetch & update if changed
//       await _fetchWebseriesInBackground();
//     } catch (e) {
//       setState(() {
//         debugMessage = "Failed to load webseries";
//         isLoading = false;
//       });
//     }
//   }

//   // Add this method to register focus with provider:
//   void _registerWebseriesFocus() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (categories.isNotEmpty && mounted) {
//         final firstCid = '${categories[0]['id']}';
//         final firstWebSeries = categories[0]['web_series'] as List<dynamic>;
//         if (firstWebSeries.isNotEmpty) {
//           final firstSid = '${firstWebSeries[0]['id']}';
//           final node = focusNodesMap[firstCid]?[firstSid];
//           if (node != null) {
//             context
//                 .read<FocusProvider>()
//                 .setFirstManageWebseriesFocusNode(node);
//           }
//         }
//       }
//     });
//   }

//   void navigateToDetails(
//       dynamic movie, String source, String banner, String name, int idx) {
//     final List<NewsItemModel> channelList =
//         (categories[idx]['web_series'] as List<dynamic>)
//             .map((m) => NewsItemModel(
//                   id: m['id']?.toString() ?? '', // Safe string conversion
//                   name: m['name']?.toString() ?? '',
//                   poster: m['poster']?.toString() ?? '',
//                   banner: m['banner']?.toString() ?? '',
//                   description: m['description']?.toString() ?? '',
//                   category: source,
//                   index: '',
//                   url: '',
//                   videoId: '',
//                   streamType: '',
//                   type: '',
//                   genres: '',
//                   status: '',
//                   image: '',
//                   unUpdatedUrl: '',
//                 ))
//             .toList();

//     // Safe ID conversion for navigation
//     int movieId;
//     if (movie['id'] is int) {
//       movieId = movie['id'];
//     } else if (movie['id'] is String) {
//       try {
//         movieId = int.parse(movie['id']);
//       } catch (e) {
//         return; // Don't navigate if ID is invalid
//       }
//     } else {
//       return; // Invalid ID, don't navigate
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => WebSeriesDetailsPage(
//           id: movieId,
//           channelList: channelList,
//           source: 'manage-web_series',
//           banner: banner,
//           poster: movie['poster']?.toString() ?? '',
//           name: name,
//         ),
//       ),
//     );
//   }
// }
// // ----------------------------------------------
// // View All button at end of row
// // ----------------------------------------------

// class ViewAllWidget extends StatefulWidget {
//   final VoidCallback onTap;
//   final String categoryText;
//   const ViewAllWidget({
//     Key? key,
//     required this.onTap,
//     required this.categoryText,
//   }) : super(key: key);

//   @override
//   _ViewAllWidgetState createState() => _ViewAllWidgetState();
// }

// class _ViewAllWidgetState extends State<ViewAllWidget> {
//   bool isFocused = false;
//   Color focusColor = highlightColor;
//   FocusNode _focusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     _focusNode.addListener(() {
//       setState(() {
//         isFocused = _focusNode.hasFocus;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double normalHeight = screenhgt * 0.21;
//     final double focusedHeight = screenhgt * 0.24;
//     final double heightGrowth = focusedHeight - normalHeight;
//     final double verticalOffset = isFocused ? -(heightGrowth / 2) : 0;

//     return Focus(
//       focusNode: _focusNode,
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//               event.logicalKey == LogicalKeyboardKey.select) {
//             widget.onTap();
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () {
//           widget.onTap();
//           _focusNode.requestFocus();
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Using Stack for true bidirectional expansion
//             Container(
//               width: screenwdt * 0.19,
//               height:
//                   normalHeight, // Fixed container height is the normal height
//               child: Stack(
//                 clipBehavior: Clip.none, // Allow items to overflow the stack
//                 alignment: Alignment.center,
//                 children: [
//                   AnimatedPositioned(
//                     duration: const Duration(milliseconds: 800),
//                     top: isFocused
//                         ? -(heightGrowth / 2)
//                         : 0, // Move up when focused
//                     left: 0,
//                     width: screenwdt * 0.19,
//                     height: isFocused ? focusedHeight : normalHeight,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(4.0),
//                         border: isFocused
//                             ? Border.all(
//                                 color: focusColor,
//                                 width: 4.0,
//                               )
//                             : Border.all(
//                                 color: Colors.transparent,
//                                 width: 4.0,
//                               ),
//                         color: Colors.grey[800],
//                         boxShadow: isFocused
//                             ? [
//                                 BoxShadow(
//                                   color: focusColor,
//                                   blurRadius: 25,
//                                   spreadRadius: 10,
//                                 )
//                               ]
//                             : [],
//                       ),
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'View All',
//                               style: TextStyle(
//                                 color: isFocused ? focusColor : hintColor,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             Text(
//                               widget.categoryText,
//                               style: TextStyle(
//                                 color: isFocused ? focusColor : hintColor,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             Text(
//                               'web_series',
//                               style: TextStyle(
//                                 color: isFocused ? focusColor : hintColor,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 10),
//             Container(
//               width: screenwdt * 0.17,
//               child: Column(
//                 children: [
//                   Text(
//                     (widget.categoryText),
//                     style: TextStyle(
//                       color: isFocused ? focusColor : Colors.grey,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ----------------------------------------------
// // Full–screen grid when "View All" is tapped
// // ----------------------------------------------
// class CategoryMoviesGridView extends StatefulWidget {
//   final Map<String, dynamic> category;
//   final List<dynamic> web_series;
//   const CategoryMoviesGridView({
//     Key? key,
//     required this.category,
//     required this.web_series,
//   }) : super(key: key);

//   @override
//   _CategoryMoviesGridViewState createState() => _CategoryMoviesGridViewState();
// }

// class _CategoryMoviesGridViewState extends State<CategoryMoviesGridView> {
//   bool _isLoading = false;
//   late Map<String, FocusNode> _nodes;

//   @override
//   void initState() {
//     super.initState();
//     _nodes = {for (var m in widget.web_series) '${m['id']}': FocusNode()};
//   }

//   @override
//   void dispose() {
//     for (var node in _nodes.values) node.dispose();
//     super.dispose();
//   }

//   Future<bool> _onWillPop() async {
//     if (_isLoading) {
//       setState(() => _isLoading = false);
//       return false;
//     }
//     return true;
//   }

//   void navigateToDetails(dynamic movie) {
//     final channelList = widget.web_series.map((m) {
//       return NewsItemModel(
//         id: m['id']?.toString() ?? '', // Safe string conversion
//         name: m['name']?.toString() ?? '',
//         poster: m['poster']?.toString() ?? '',
//         banner: m['banner']?.toString() ?? '',
//         description: m['description']?.toString() ?? '',
//         category: widget.category['category'],
//         index: '',
//         url: '',
//         videoId: '',
//         streamType: '',
//         type: '',
//         genres: '',
//         status: '',
//         image: '',
//         unUpdatedUrl: '',
//       );
//     }).toList();

//     // Safe ID conversion for navigation
//     int movieId;
//     if (movie['id'] is int) {
//       movieId = movie['id'];
//     } else if (movie['id'] is String) {
//       try {
//         movieId = int.parse(movie['id']);
//       } catch (e) {
//         return; // Don't navigate if ID is invalid
//       }
//     } else {
//       return; // Invalid ID, don't navigate
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => WebSeriesDetailsPage(
//           id: movieId,
//           channelList: channelList,
//           source: 'manage_web_series',
//           banner: {movie['banner'] ?? movie['poster']}?.toString() ?? '',
//           poster: {movie['poster'] ?? movie['banner']}?.toString() ?? '',
//           name: movie['name']?.toString() ?? '',
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Stack(
//           children: [
//             GridView.builder(
//               padding: const EdgeInsets.all(16),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 5,
//                 // mainAxisSpacing: 12,
//                 // crossAxisSpacing: 12,
//                 // childAspectRatio: 0.7,
//               ),
//               itemCount: widget.web_series.length,
//               itemBuilder: (_, idx) {
//                 final m = widget.web_series[idx];
//                 final id = '${m['id']}';

//                 return FocussableWebseriesWidget(
//                   key: ValueKey('webseries_${m['id']}_$idx'),
//                   imageUrl: m['poster']?.toString() ?? '',
//                   name: m['name']?.toString() ?? '',
//                   focusNode: _nodes[id]!,
//                   onTap: () {
//                     setState(() => _isLoading = true);
//                     navigateToDetails(m);
//                     setState(() => _isLoading = false);
//                   },
//                   fetchPaletteColor: (url) =>
//                       PaletteColorService().getSecondaryColor(url),
//                 );
//               },
//             ),
//             if (_isLoading) Center(child: loading_indicator.LoadingIndicator()),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart'
    as loading_indicator;
import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import 'focussable_webseries_widget.dart';
import '../../widgets/models/news_item_model.dart';
import 'webseries_details_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Professional Colors for WebSeries (same as Movies)
class ProfessionalWebSeriesColors {
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
class WebSeriesAnimationTiming {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration focus = Duration(milliseconds: 700); // Slow like movies
  static const Duration scroll = Duration(milliseconds: 800);
}

// Professional WebSeries Card Widget
class ProfessionalWebSeriesCard extends StatefulWidget {
  final dynamic webSeries;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;
  final int index;
  final VoidCallback? onUpPress;

  const ProfessionalWebSeriesCard({
    Key? key,
    required this.webSeries,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
    required this.index,
    this.onUpPress,
  }) : super(key: key);

  @override
  _ProfessionalWebSeriesCardState createState() =>
      _ProfessionalWebSeriesCardState();
}

class _ProfessionalWebSeriesCardState extends State<ProfessionalWebSeriesCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  Color _dominantColor = ProfessionalWebSeriesColors.accentBlue;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: WebSeriesAnimationTiming.focus,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: WebSeriesAnimationTiming.medium,
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.04, // Same as movies
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

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });

    if (_isFocused) {
      _scaleController.forward();
      _glowController.forward();
      _generateDominantColor();
      widget.onColorChange(_dominantColor);
      HapticFeedback.lightImpact();
    } else {
      _scaleController.reverse();
      _glowController.reverse();
    }
  }

  void _generateDominantColor() {
    final colors = ProfessionalWebSeriesColors.gradientColors;
    _dominantColor = colors[math.Random().nextInt(colors.length)];
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
            margin: EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfessionalPoster(screenWidth, screenHeight),
                // SizedBox(height: 10),
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
            _buildWebSeriesImage(screenWidth, posterHeight),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            _buildSeriesBadge(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebSeriesImage(double screenWidth, double posterHeight) {
    final imageUrl = widget.webSeries['poster']?.toString() ??
        widget.webSeries['banner']?.toString() ??
        '';

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

  Widget _buildImagePlaceholder(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalWebSeriesColors.cardDark,
            ProfessionalWebSeriesColors.surfaceDark,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tv_rounded,
            size: height * 0.25,
            color: ProfessionalWebSeriesColors.textSecondary,
          ),
          SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              color: ProfessionalWebSeriesColors.textSecondary,
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

  Widget _buildSeriesBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tv,
              color: Colors.white,
              size: 8,
            ),
            SizedBox(width: 2),
            Text(
              'SERIES',
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
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalTitle(double screenWidth) {
    final seriesName =
        widget.webSeries['name']?.toString()?.toUpperCase() ?? 'UNKNOWN';

    return Container(
      width: screenWidth * 0.18,
      child: AnimatedDefaultTextStyle(
        duration: WebSeriesAnimationTiming.medium,
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11,
          fontWeight: FontWeight.w600,
          color: _isFocused
              ? _dominantColor
              : ProfessionalWebSeriesColors.textPrimary,
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
          seriesName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// Enhanced View All Button for WebSeries
class ProfessionalWebSeriesViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;
  final String categoryText;
  final int totalSeries;

  const ProfessionalWebSeriesViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
    required this.categoryText,
    required this.totalSeries,
  }) : super(key: key);

  @override
  _ProfessionalWebSeriesViewAllButtonState createState() =>
      _ProfessionalWebSeriesViewAllButtonState();
}

class _ProfessionalWebSeriesViewAllButtonState
    extends State<ProfessionalWebSeriesViewAllButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;
  late AnimationController _breathingController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _breathingAnimation;

  bool _isFocused = false;
  Color _currentColor = ProfessionalWebSeriesColors.accentBlue;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: WebSeriesAnimationTiming.focus,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: WebSeriesAnimationTiming.medium,
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _breathingController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

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

    _breathingAnimation = Tween<double>(
      begin: 0.95,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
      if (_isFocused) {
        _currentColor = ProfessionalWebSeriesColors.gradientColors[math.Random()
            .nextInt(ProfessionalWebSeriesColors.gradientColors.length)];
        HapticFeedback.mediumImpact();
      }
    });

    if (_isFocused) {
      _scaleController.forward();
      _glowController.forward();
      _shimmerController.repeat();
    } else {
      _scaleController.reverse();
      _glowController.reverse();
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    _breathingController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.19,
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([
              _scaleAnimation,
              _glowAnimation,
              _breathingAnimation,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _isFocused
                    ? _scaleAnimation.value
                    : _breathingAnimation.value,
                child: Container(
                  height: _isFocused ? screenHeight * 0.3 : screenHeight * 0.25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (_isFocused) ...[
                        BoxShadow(
                          color: _currentColor.withOpacity(0.4),
                          blurRadius: 25,
                          spreadRadius: 3,
                          offset: Offset(0, 8),
                        ),
                      ] else ...[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        _buildWebSeriesStyleBackground(),
                        if (_isFocused) _buildFocusBorder(),
                        if (_isFocused) _buildShimmerEffect(),
                        _buildCenterContent(),
                        _buildQualityBadge(),
                        if (_isFocused) _buildHoverOverlay(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 10),
          _buildAdvancedTitle(),
        ],
      ),
    );
  }

  Widget _buildWebSeriesStyleBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isFocused
              ? [
                  _currentColor.withOpacity(0.8),
                  _currentColor.withOpacity(0.6),
                  ProfessionalWebSeriesColors.cardDark.withOpacity(0.9),
                ]
              : [
                  ProfessionalWebSeriesColors.cardDark,
                  ProfessionalWebSeriesColors.surfaceDark,
                  ProfessionalWebSeriesColors.cardDark.withOpacity(0.8),
                ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.3),
            ],
          ),
        ),
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
            color: _currentColor,
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
                  _currentColor.withOpacity(0.15),
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

  Widget _buildCenterContent() {
    return Center(
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
                      ? _currentColor.withOpacity(0.6)
                      : Colors.black.withOpacity(0.5),
                  blurRadius: _isFocused ? 8 : 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isFocused
                    ? [
                        _currentColor.withOpacity(0.3),
                        _currentColor.withOpacity(0.1),
                      ]
                    : [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.1),
                      ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _isFocused
                    ? _currentColor.withOpacity(0.5)
                    : Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${widget.totalSeries}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'ALL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
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
              _currentColor.withOpacity(0.1),
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
              Icons.explore_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedTitle() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.18,
      child: AnimatedDefaultTextStyle(
        duration: WebSeriesAnimationTiming.medium,
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11,
          fontWeight: FontWeight.w600,
          color: _isFocused
              ? _currentColor
              : ProfessionalWebSeriesColors.textPrimary,
          letterSpacing: 0.5,
          shadows: _isFocused
              ? [
                  Shadow(
                    color: _currentColor.withOpacity(0.6),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          widget.categoryText.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// Enhanced Main WebSeries Screen - COMPLETE WIDGET
class ProfessionalManageWebseries extends StatefulWidget {
  final FocusNode focusNode;
  const ProfessionalManageWebseries({Key? key, required this.focusNode})
      : super(key: key);

  @override
  _ProfessionalManageWebseriesState createState() =>
      _ProfessionalManageWebseriesState();
}

class _ProfessionalManageWebseriesState
    extends State<ProfessionalManageWebseries>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  // Data
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String debugMessage = "";

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _categoryAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _categoryFadeAnimation;

  // Focus Management
  Map<String, Map<String, FocusNode>> focusNodesMap = {};
  Map<String, FocusNode> viewAllFocusNodes = {}; // 🔧 ViewAll focus nodes map
  final ScrollController _scrollController = ScrollController();

  // Services
  final PaletteColorService _paletteColorService = PaletteColorService();

  @override
  void initState() {
    super.initState();

    _initializeAnimations();
    _loadCachedWebseriesDataAndFetch();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FocusProvider>(context, listen: false)
          .setwebseriesScrollController(_scrollController);
    });
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: WebSeriesAnimationTiming.slow,
      vsync: this,
    );

    _categoryAnimationController = AnimationController(
      duration: WebSeriesAnimationTiming.slow,
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

  void _initializeFocusNodes() {
    focusNodesMap.clear();
    viewAllFocusNodes.clear(); // 🔧 Clear ViewAll nodes too
    
    for (var cat in categories) {
      final catId = '${cat['id']}';
      focusNodesMap[catId] = {};
      
      // 🔧 CREATE: ViewAll focus node for each category
      viewAllFocusNodes[catId] = FocusNode(debugLabel: 'viewAll_$catId');
      
      final webSeriesList = cat['web_series'] as List<dynamic>;

      for (int idx = 0; idx < webSeriesList.length; idx++) {
        final series = webSeriesList[idx];
        final seriesId = '${series['id']}';

        final focusNode =
            FocusNode(debugLabel: 'webseries_${catId}_${seriesId}_$idx');

        focusNode.addListener(() {
          if (focusNode.hasFocus && mounted && _scrollController.hasClients) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _performReliableScroll(itemIndex: idx);
            });
          }
        });

        focusNodesMap[catId]![seriesId] = focusNode;
      }
    }
  }

  void _performReliableScroll({required int itemIndex}) {
    if (!mounted || !_scrollController.hasClients) return;

    try {
      final double itemWidth = MediaQuery.of(context).size.width * 0.19;
      final double horizontalPadding = 6.0; // Your margin
      final double totalItemWidth = itemWidth + (horizontalPadding * 2);

      final double targetOffset = itemIndex * totalItemWidth;
      final double maxOffset = _scrollController.position.maxScrollExtent;
      final double clampedOffset = targetOffset.clamp(0.0, maxOffset);

      _scrollController
          .animateTo(
            clampedOffset,
            duration: WebSeriesAnimationTiming.scroll,
            curve: Curves.easeInOutCubic,
          )
          .then((_) {})
          .catchError((error) {});
    } catch (e) {
    }
  }

  List<dynamic> _sortByIndex(List<dynamic> list) {
    try {
      list.sort((a, b) {
        dynamic indexA = a['index'];
        dynamic indexB = b['index'];

        int numA = 0;
        int numB = 0;

        if (indexA is int) {
          numA = indexA;
        } else if (indexA is String) {
          numA = int.tryParse(indexA) ?? 0;
        }

        if (indexB is int) {
          numB = indexB;
        } else if (indexB is String) {
          numB = int.tryParse(indexB) ?? 0;
        }

        return numA.compareTo(numB);
      });

      return list;
    } catch (e) {
      return list;
    }
  }



  // REPLACE this entire method:
Future<void> _loadCachedWebseriesDataAndFetch() async {
  setState(() {
    isLoading = true;
    debugMessage = '';
  });

  try {
    // Step 1: Load cached data first
    await _loadCachedWebseriesData();

    // Step 2: If no cached data or empty categories, fetch fresh data
    if (categories.isEmpty) {
      await _fetchWebseriesDirectly();
    } else {
      await _fetchWebseriesInBackground();
    }

    // Start animations after data loads
    _headerAnimationController.forward();
    _categoryAnimationController.forward();
  } catch (e) {
    setState(() {
      debugMessage = "Failed to load webseries: $e";
      isLoading = false;
    });
  }
}



// ADD this new method:
Future<void> _loadCachedWebseriesData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('webseries_list');
    
    if (cached != null && cached.isNotEmpty) {
      final List<dynamic> cachedData = jsonDecode(cached);
      setState(() {
        categories = List<Map<String, dynamic>>.from(cachedData);
        _initializeFocusNodes();
        isLoading = false;
      });
      _registerWebseriesFocus();
    } else {
    }
  } catch (e) {
    setState(() {
      debugMessage = 'Error loading cached data: $e';
    });
  }
}



// ADD this new method:
Future<void> _fetchWebseriesDirectly() async {
  try {
    
    final prefs = await SharedPreferences.getInstance();
    String authKey = AuthManager.authKey;
    if (authKey.isEmpty) {
      authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
    }

    final response = await http.get(
      Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
      headers: {
        'auth-key': authKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final List<dynamic> flatData = jsonDecode(response.body);

      if (flatData.isNotEmpty) {
        final Map<String, List<dynamic>> grouped = {'Web Series': flatData};
        final List<Map<String, dynamic>> newCats = [];

        for (var entry in grouped.entries) {
          try {
            final sortedItems = _sortByIndex(List.from(entry.value));
            newCats.add({
              'id': '1',
              'category': entry.key,
              'web_series': sortedItems,
            });
          } catch (e) {
            newCats.add({
              'id': '1',
              'category': entry.key,
              'web_series': entry.value,
            });
          }
        }


        if (mounted) {
          setState(() {
            categories = newCats;
            _initializeFocusNodes();
            isLoading = false;
            debugMessage = '';
          });

          // Save to cache for next time
          final newJson = jsonEncode(newCats);
          await prefs.setString('webseries_list', newJson);

          _registerWebseriesFocus();
        }
      } else {
        throw Exception('Empty data received from API');
      }
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  }
}


// REPLACE the existing _fetchWebseriesInBackground method with:
Future<void> _fetchWebseriesInBackground() async {
  try {
    
    final prefs = await SharedPreferences.getInstance();
    String authKey = AuthManager.authKey;
    if (authKey.isEmpty) {
      authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
    }

    final response = await http.get(
      Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
      headers: {
        'auth-key': authKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final List<dynamic> flatData = jsonDecode(response.body);

      if (flatData.isNotEmpty) {
        final Map<String, List<dynamic>> grouped = {'Web Series': flatData};
        final List<Map<String, dynamic>> newCats = [];

        for (var entry in grouped.entries) {
          try {
            final sortedItems = _sortByIndex(List.from(entry.value));
            newCats.add({
              'id': '1',
              'category': entry.key,
              'web_series': sortedItems,
            });
          } catch (e) {
            newCats.add({
              'id': '1',
              'category': entry.key,
              'web_series': entry.value,
            });
          }
        }

        final newJson = jsonEncode(newCats);
        final cached = prefs.getString('webseries_list');

        if (cached == null || cached != newJson) {
          await prefs.setString('webseries_list', newJson);

          if (mounted) {
            setState(() {
              categories = newCats;
              _initializeFocusNodes();
            });
            _registerWebseriesFocus();
          }
        } else {
        }
      }
    }
  } catch (e) {
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}



  // Future<void> _fetchWebseriesInBackground() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     String authKey = AuthManager.authKey;
  //     if (authKey.isEmpty) {
  //       authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
  //     }

  //     final response = await http.get(
  //       Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
  //       headers: {
  //         'auth-key': authKey,
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200 && response.body.isNotEmpty) {
  //       final List<dynamic> flatData = jsonDecode(response.body);

  //       if (flatData.isNotEmpty) {
  //         final Map<String, List<dynamic>> grouped = {'Web Series': flatData};
  //         final List<Map<String, dynamic>> newCats = [];

  //         for (var entry in grouped.entries) {
  //           try {
  //             final sortedItems = _sortByIndex(List.from(entry.value));
  //             newCats.add({
  //               'id': '1',
  //               'category': entry.key,
  //               'web_series': sortedItems,
  //             });
  //           } catch (e) {
  //             newCats.add({
  //               'id': '1',
  //               'category': entry.key,
  //               'web_series': entry.value,
  //             });
  //           }
  //         }

  //         try {
  //           final newJson = jsonEncode(newCats);
  //           final cached = prefs.getString('webseries_list');

  //           if (cached == null || cached != newJson) {
  //             await prefs.setString('webseries_list', newJson);

  //             if (mounted) {
  //               setState(() {
  //                 categories = newCats;
  //                 _initializeFocusNodes();
  //               });
  //               _registerWebseriesFocus();
  //             }
  //           }
  //         } catch (e) {
  //           if (mounted) {
  //             setState(() {
  //               categories = newCats;
  //               _initializeFocusNodes();
  //             });
  //             _registerWebseriesFocus();
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   }
  // }

  // Future<void> _loadCachedWebseriesDataAndFetch() async {
  //   setState(() {
  //     isLoading = true;
  //     debugMessage = '';
  //   });

  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final cached = prefs.getString('webseries_list');
  //     if (cached != null) {
  //       final List<dynamic> cachedData = jsonDecode(cached);
  //       setState(() {
  //         categories = List<Map<String, dynamic>>.from(cachedData);
  //         _initializeFocusNodes();
  //         isLoading = false;
  //       });

  //       // Start animations after cached data loads
  //       _headerAnimationController.forward();
  //       _categoryAnimationController.forward();
  //       _registerWebseriesFocus();
  //     }

  //     await _fetchWebseriesInBackground();
  //   } catch (e) {
  //     setState(() {
  //       debugMessage = "Failed to load webseries";
  //       isLoading = false;
  //     });
  //   }
  // }

  void _registerWebseriesFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (categories.isNotEmpty && mounted) {
        final firstCid = '${categories[0]['id']}';
        final firstWebSeries = categories[0]['web_series'] as List<dynamic>;
        if (firstWebSeries.isNotEmpty) {
          final firstSid = '${firstWebSeries[0]['id']}';
          final node = focusNodesMap[firstCid]?[firstSid];
          if (node != null) {
            context
                .read<FocusProvider>()
                .setFirstManageWebseriesFocusNode(node);
          }
        }
      }
    });
  }

  void navigateToDetails(dynamic webSeries, String source, String banner,
      String name, int categoryIndex) {
    final List<NewsItemModel> channelList =
        (categories[categoryIndex]['web_series'] as List<dynamic>)
            .map((m) => NewsItemModel(
                  id: m['id']?.toString() ?? '',
                  name: m['name']?.toString() ?? '',
                  poster: m['poster']?.toString() ?? '',
                  banner: m['banner']?.toString() ?? '',
                  description: m['description']?.toString() ?? '',
                  category: source,
                  index: '',
                  url: '',
                  videoId: '',
                  streamType: '',
                  type: '',
                  genres: '',
                  status: '',
                  image: '',
                  unUpdatedUrl: '',
                ))
            .toList();

    int seriesId;
    if (webSeries['id'] is int) {
      seriesId = webSeries['id'];
    } else if (webSeries['id'] is String) {
      try {
        seriesId = int.parse(webSeries['id']);
      } catch (e) {
        return;
      }
    } else {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebSeriesDetailsPage(
          id: seriesId,
          channelList: channelList,
          source: 'manage-web_series',
          banner: banner,
          poster: webSeries['poster']?.toString() ?? '',
          name: name,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _categoryAnimationController.dispose();

    // 🔧 DISPOSE: ViewAll focus nodes
    for (var node in viewAllFocusNodes.values) {
      try {
        node.dispose();
      } catch (e) {
      }
    }

    for (var categoryNodes in focusNodesMap.values) {
      for (var node in categoryNodes.values) {
        try {
          node.dispose();
        } catch (e) {
        }
      }
    }

    try {
      _scrollController.dispose();
    } catch (e) {
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<ColorProvider>(
      builder: (context, colorProv, child) {
        final bgColor = colorProv.isItemFocused
            ? colorProv.dominantColor.withOpacity(0.1)
            : ProfessionalWebSeriesColors.primaryDark;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                bgColor,
                ProfessionalWebSeriesColors.primaryDark,
                ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.5),
              ],
            ),
          ),
          child: Column(
            children: [
              // SizedBox(height: screenhgt * 0.02),
              // _buildProfessionalTitle(),
              SizedBox(height: screenhgt * 0.01),
              Expanded(child: _buildBody()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfessionalTitle() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  ProfessionalWebSeriesColors.accentPurple,
                  ProfessionalWebSeriesColors.accentBlue,
                ],
              ).createShader(bounds),
              child: Text(
                'WEB SERIES',
                style: TextStyle(
                  fontSize: Headingtextsz,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            if (categories.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ProfessionalWebSeriesColors.accentPurple.withOpacity(0.2),
                      ProfessionalWebSeriesColors.accentBlue.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ProfessionalWebSeriesColors.accentPurple
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tv,
                      size: 14,
                      color: ProfessionalWebSeriesColors.textSecondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '${_getTotalSeriesCount()} Series',
                      style: TextStyle(
                        color: ProfessionalWebSeriesColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _getTotalSeriesCount() {
    int total = 0;
    for (var category in categories) {
      total += (category['web_series'] as List<dynamic>).length;
    }
    return total;
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildProfessionalLoadingIndicator();
    } else if (categories.isEmpty) {
      return _buildNoDataWidget();
    } else {
      return _buildCategoriesList();
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
                  ProfessionalWebSeriesColors.accentPurple,
                  ProfessionalWebSeriesColors.accentBlue,
                  ProfessionalWebSeriesColors.accentGreen,
                  ProfessionalWebSeriesColors.accentPurple,
                ],
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ProfessionalWebSeriesColors.primaryDark,
              ),
              child: Icon(
                Icons.tv_rounded,
                color: ProfessionalWebSeriesColors.textPrimary,
                size: 28,
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading Web Series...',
            style: TextStyle(
              color: ProfessionalWebSeriesColors.textPrimary,
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
              color: ProfessionalWebSeriesColors.surfaceDark,
            ),
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                ProfessionalWebSeriesColors.accentPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalWebSeriesColors.accentPurple.withOpacity(0.2),
                  ProfessionalWebSeriesColors.accentPurple.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.tv_off,
              size: 40,
              color: ProfessionalWebSeriesColors.accentPurple,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Web Series Found',
            style: TextStyle(
              color: ProfessionalWebSeriesColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for new content',
            style: TextStyle(
              color: ProfessionalWebSeriesColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return FadeTransition(
      opacity: _categoryFadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: List.generate(categories.length, (catIdx) {
            final cat = categories[catIdx];
            final list = cat['web_series'] as List<dynamic>;
            final catId = '${cat['id']}';

            return _buildCategorySection(cat, list, catId, catIdx);
          }),
        ),
      ),
    );
  }

  Widget _buildCategorySection(Map<String, dynamic> category, 
      List<dynamic> seriesList, String categoryId, int categoryIndex) {
    
    // 🔧 GET: ViewAll focus node from the map instead of creating new
    final viewAllFocusNode = viewAllFocusNodes[categoryId]!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryHeader(category),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.38,
          child: ListView.builder(
            key: ValueKey('webseries_listview_$categoryId'),
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
            cacheExtent: 1200,
            itemCount: seriesList.length > 7 ? 8 : seriesList.length + 1,
            itemBuilder: (context, idx) {
              if ((seriesList.length >= 7 && idx == 7) ||
                  (seriesList.length < 7 && idx == seriesList.length)) {
                return _buildEnhancedViewAllButton(
                    category, seriesList, viewAllFocusNode, categoryIndex);
              }

              final item = seriesList[idx];
              final seriesId = '${item['id']}';
              final node = focusNodesMap[categoryId]?[seriesId];

              return _buildEnhancedWebSeriesItem(
                  item, node, categoryIndex, idx, viewAllFocusNode, seriesList);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEnhancedWebSeriesItem(
      dynamic webSeries,
      FocusNode? node,
      int categoryIndex,
      int itemIndex,
      FocusNode viewAllFocusNode,
      List<dynamic> seriesList) {
    if (node == null) return SizedBox.shrink();

    return Focus(
      focusNode: node,
      onFocusChange: (hasFocus) async {
        if (hasFocus && mounted) {
          try {
            Color dominantColor = await _paletteColorService.getSecondaryColor(
              webSeries['poster']?.toString() ?? '',
              fallbackColor: ProfessionalWebSeriesColors.accentPurple,
            );
            if (mounted) {
              context.read<ColorProvider>().updateColor(dominantColor, true);
            }
          } catch (e) {
            if (mounted) {
              context
                  .read<ColorProvider>()
                  .updateColor(ProfessionalWebSeriesColors.accentPurple, true);
            }
          }
          _performReliableScroll(itemIndex: itemIndex);
        } else if (mounted) {
          context.read<ColorProvider>().resetColor();
        }
      },
      onKey: (FocusNode focusNode, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            // 🔧 CRITICAL FIX: Proper last index calculation
            int lastDisplayedIndex = math.min(6, seriesList.length - 1);
            
            
            if (itemIndex < lastDisplayedIndex) {
              // Normal navigation to next series
              if (itemIndex + 1 < seriesList.length) {
                String nextSeriesId = seriesList[itemIndex + 1]['id'].toString();
                String categoryId = '${categories[categoryIndex]['id']}';
                final nextNode = focusNodesMap[categoryId]?[nextSeriesId];
                if (nextNode != null) {
                  FocusScope.of(context).requestFocus(nextNode);
                  return KeyEventResult.handled;
                }
              }
            } else if (itemIndex == lastDisplayedIndex && seriesList.length > 7) {
              // 🔧 CRITICAL: Last displayed item से ViewAll पर focus
              FocusScope.of(context).requestFocus(viewAllFocusNode);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (itemIndex > 0) {
              String prevSeriesId = seriesList[itemIndex - 1]['id'].toString();
              String categoryId = '${categories[categoryIndex]['id']}';
              final prevNode = focusNodesMap[categoryId]?[prevSeriesId];
              if (prevNode != null) {
                FocusScope.of(context).requestFocus(prevNode);
                return KeyEventResult.handled;
              }
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            context.read<FocusProvider>().requestFirstMoviesFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Navigate to next category
            if (categoryIndex + 1 < categories.length) {
              final nextCategory = categories[categoryIndex + 1];
              final nextCategoryId = '${nextCategory['id']}';
              final nextSeriesList = nextCategory['web_series'] as List<dynamic>;
              if (nextSeriesList.isNotEmpty) {
                final firstSeriesId = '${nextSeriesList[0]['id']}';
                final firstNode = focusNodesMap[nextCategoryId]?[firstSeriesId];
                if (firstNode != null) {
                  FocusScope.of(context).requestFocus(firstNode);
                  return KeyEventResult.handled;
                }
              }
            }
            return KeyEventResult.ignored;
          } else if (event.logicalKey == LogicalKeyboardKey.select) {
            navigateToDetails(
              webSeries,
              categories[categoryIndex]['category'],
              webSeries['banner']?.toString() ??
                  webSeries['poster']?.toString() ??
                  '',
              webSeries['name']?.toString() ?? '',
              categoryIndex,
            );
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => navigateToDetails(
          webSeries,
          categories[categoryIndex]['category'],
          webSeries['banner']?.toString() ??
              webSeries['poster']?.toString() ??
              '',
          webSeries['name']?.toString() ?? '',
          categoryIndex,
        ),
        child: ProfessionalWebSeriesCard(
          webSeries: webSeries,
          focusNode: node,
          onTap: () => navigateToDetails(
            webSeries,
            categories[categoryIndex]['category'],
            webSeries['banner']?.toString() ??
                webSeries['poster']?.toString() ??
                '',
            webSeries['name']?.toString() ?? '',
            categoryIndex,
          ),
          onColorChange: (color) {
            if (mounted) {
              context.read<ColorProvider>().updateColor(color, true);
            }
          },
          index: itemIndex,
          onUpPress: () {
            context.read<FocusProvider>().requestFirstMoviesFocus();
          },
        ),
      ),
    );
  }



// ================================
// ENHANCED VIEWALL BUTTON: With Perfect Left Arrow Navigation
// ================================

  Widget _buildEnhancedViewAllButton(Map<String, dynamic> category,
      List<dynamic> seriesList, FocusNode viewAllFocusNode, int categoryIndex) {
    return Focus(
      focusNode: viewAllFocusNode,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            // Stay on ViewAll - no further navigation
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            // ✅ PERFECT: ViewAll से last series पर focus
            if (seriesList.isNotEmpty) {
              int lastIndex =
                  seriesList.length >= 7 ? 6 : seriesList.length - 1;
              String lastSeriesId = seriesList[lastIndex]['id'].toString();
              String categoryId = '${category['id']}';
              final lastNode = focusNodesMap[categoryId]?[lastSeriesId];
              if (lastNode != null) {
                FocusScope.of(context).requestFocus(lastNode);
                return KeyEventResult.handled;
              }
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            context.read<FocusProvider>().requestFirstMoviesFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Navigate to next category's first item
            if (categoryIndex + 1 < categories.length) {
              final nextCategory = categories[categoryIndex + 1];
              final nextCategoryId = '${nextCategory['id']}';
              final nextSeriesList =
                  nextCategory['web_series'] as List<dynamic>;
              if (nextSeriesList.isNotEmpty) {
                final firstSeriesId = '${nextSeriesList[0]['id']}';
                final firstNode = focusNodesMap[nextCategoryId]?[firstSeriesId];
                if (firstNode != null) {
                  FocusScope.of(context).requestFocus(firstNode);
                  return KeyEventResult.handled;
                }
              }
            }
            return KeyEventResult.ignored;
          } else if (event.logicalKey == LogicalKeyboardKey.select) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfessionalCategoryWebSeriesGridView(
                  category: category,
                  web_series: seriesList,
                ),
              ),
            );
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfessionalCategoryWebSeriesGridView(
                category: category,
                web_series: seriesList,
              ),
            ),
          );
        },
        child: ProfessionalWebSeriesViewAllButton(
          focusNode: viewAllFocusNode,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfessionalCategoryWebSeriesGridView(
                  category: category,
                  web_series: seriesList,
                ),
              ),
            );
          },
          categoryText: category['category'].toString(),
          totalSeries: seriesList.length,
        ),
      ),
    );
  }

// ================================
// 📋 STEP BY STEP CHANGES NEEDED:
// ================================

/*
🔧 CHANGES TO MAKE IN YOUR CODE:

1. ✅ REPLACE _buildCategorySection method:
   - Add viewAllFocusNode creation
   - Use _buildEnhancedViewAllButton and _buildEnhancedWebSeriesItem

2. ✅ REPLACE _buildWebSeriesItem method:
   - Add complete arrow key navigation
   - Add right arrow to ViewAll logic

3. ✅ REPLACE _buildViewAllButton method:
   - Add proper left arrow to last series logic
   - Add down arrow for next category navigation

🎯 NAVIGATION FLOW RESULT:

RIGHT ARROW FLOW:
Series0 → Series1 → Series2 → Series3 → Series4 → Series5 → Series6 → ViewAll

LEFT ARROW FLOW:
ViewAll → Series6 → Series5 → Series4 → Series3 → Series2 → Series1 → Series0

UP/DOWN FLOW:
- Up Arrow: All items → Movies section
- Down Arrow: Items/ViewAll → Next category's first item

🚀 TESTING COMMANDS:
- Right arrow on last series (index 6): Should go to ViewAll
- Left arrow on ViewAll: Should go to last series (index 6)
- All navigation should be smooth with proper focus

💡 CRITICAL POINTS:
1. ViewAll FocusNode created in _buildCategorySection
2. Passed to both ViewAll button and all series items
3. Direct focus management instead of relying on ListView
4. Proper index calculation for last displayed item
*/

  // Widget _buildCategorySection(Map<String, dynamic> category, List<dynamic> seriesList, String categoryId, int categoryIndex) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildCategoryHeader(category),
  //       SizedBox(
  //         height: MediaQuery.of(context).size.height * 0.38,
  //         child: ListView.builder(
  //           key: ValueKey('webseries_listview_$categoryId'),
  //           controller: _scrollController,
  //           scrollDirection: Axis.horizontal,
  //           physics: const BouncingScrollPhysics(),
  //           clipBehavior: Clip.none,
  //           padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
  //           cacheExtent: 1200,
  //           itemCount: seriesList.length > 7 ? 8 : seriesList.length + 1,
  //           itemBuilder: (context, idx) {
  //             if ((seriesList.length >= 7 && idx == 7) ||
  //                 (seriesList.length < 7 && idx == seriesList.length)) {
  //               return _buildViewAllButton(category, seriesList);
  //             }

  //             final item = seriesList[idx];
  //             final seriesId = '${item['id']}';
  //             final node = focusNodesMap[categoryId]?[seriesId];

  //             return _buildWebSeriesItem(item, node, categoryIndex, idx);
  //           },
  //         ),
  //       ),
  //       const SizedBox(height: 20),
  //     ],
  //   );
  // }

  Widget _buildCategoryHeader(Map<String, dynamic> category) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ProfessionalWebSeriesColors.accentPurple,
                  ProfessionalWebSeriesColors.accentBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              category['category'].toString().toUpperCase(),
              style: TextStyle(
                color: ProfessionalWebSeriesColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: 1.0,
              ),
            ),
          ),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //   decoration: BoxDecoration(
          //     color: ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.6),
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(
          //       color:
          //           ProfessionalWebSeriesColors.accentPurple.withOpacity(0.3),
          //       width: 1,
          //     ),
          //   ),
          //   child: Text(
          //     '${(category['web_series'] as List<dynamic>).length}',
          //     style: TextStyle(
          //       color: ProfessionalWebSeriesColors.textSecondary,
          //       fontSize: 12,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),

          if (categories.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ProfessionalWebSeriesColors.accentPurple.withOpacity(0.2),
                      ProfessionalWebSeriesColors.accentBlue.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ProfessionalWebSeriesColors.accentPurple
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tv,
                      size: 14,
                      color: ProfessionalWebSeriesColors.textSecondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '${_getTotalSeriesCount()} Series',
                      style: TextStyle(
                        color: ProfessionalWebSeriesColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  // 🔧 FIXED: WebSeries Navigation और ViewAll Size Issues

// ================================
// STEP 1: WebSeries ViewAll Button Focus Management Fix
// ================================

  Widget _buildViewAllButton(
      Map<String, dynamic> category, List<dynamic> seriesList) {
    final viewAllFocusNode = FocusNode();

    return Focus(
      focusNode: viewAllFocusNode,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            // ✅ ViewAll से right arrow - stay on ViewAll
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            // ✅ FIX: ViewAll से left arrow - last series पर focus
            if (seriesList.isNotEmpty) {
              // Last displayed series index calculate करें
              int lastIndex =
                  seriesList.length >= 7 ? 6 : seriesList.length - 1;
              String lastSeriesId = seriesList[lastIndex]['id'].toString();
              String categoryId = '${category['id']}';
              final lastNode = focusNodesMap[categoryId]?[lastSeriesId];
              if (lastNode != null) {
                FocusScope.of(context).requestFocus(lastNode);
                return KeyEventResult.handled;
              }
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            context.read<FocusProvider>().requestFirstMoviesFocus();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            // Next category या end of content
            return KeyEventResult.ignored;
          } else if (event.logicalKey == LogicalKeyboardKey.select) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfessionalCategoryWebSeriesGridView(
                  category: category,
                  web_series: seriesList,
                ),
              ),
            );
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfessionalCategoryWebSeriesGridView(
                category: category,
                web_series: seriesList,
              ),
            ),
          );
        },
        child: ProfessionalWebSeriesViewAllButton(
          focusNode: viewAllFocusNode,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfessionalCategoryWebSeriesGridView(
                  category: category,
                  web_series: seriesList,
                ),
              ),
            );
          },
          categoryText: category['category'].toString(),
          totalSeries: seriesList.length,
        ),
      ),
    );
  }
}






// 🔧 FIXED: Enhanced Grid View for WebSeries with Enter Key Navigation
class ProfessionalCategoryWebSeriesGridView extends StatefulWidget {
  final Map<String, dynamic> category;
  final List<dynamic> web_series;

  const ProfessionalCategoryWebSeriesGridView({
    Key? key,
    required this.category,
    required this.web_series,
  }) : super(key: key);

  @override
  _ProfessionalCategoryWebSeriesGridViewState createState() =>
      _ProfessionalCategoryWebSeriesGridViewState();
}

class _ProfessionalCategoryWebSeriesGridViewState
    extends State<ProfessionalCategoryWebSeriesGridView>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late Map<String, FocusNode> _nodes;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _nodes = {for (var m in widget.web_series) '${m['id']}': FocusNode()};

    _initializeAnimations();
    _startStaggeredAnimation();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startStaggeredAnimation() {
    _fadeController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    for (var node in _nodes.values) node.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_isLoading) {
      setState(() => _isLoading = false);
      return false;
    }
    return true;
  }

  void navigateToDetails(dynamic webSeries) {
    final channelList = widget.web_series.map((m) {
      return NewsItemModel(
        id: m['id']?.toString() ?? '',
        name: m['name']?.toString() ?? '',
        poster: m['poster']?.toString() ?? '',
        banner: m['banner']?.toString() ?? '',
        description: m['description']?.toString() ?? '',
        category: widget.category['category'],
        index: '',
        url: '',
        videoId: '',
        streamType: '',
        type: '',
        genres: '',
        status: '',
        image: '',
        unUpdatedUrl: '',
      );
    }).toList();

    int seriesId;
    if (webSeries['id'] is int) {
      seriesId = webSeries['id'];
    } else if (webSeries['id'] is String) {
      try {
        seriesId = int.parse(webSeries['id']);
      } catch (e) {
        return;
      }
    } else {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebSeriesDetailsPage(
          id: seriesId,
          channelList: channelList,
          source: 'manage_web_series',
          banner: webSeries['banner']?.toString() ??
              webSeries['poster']?.toString() ??
              '',
          poster: webSeries['poster']?.toString() ??
              webSeries['banner']?.toString() ??
              '',
          name: webSeries['name']?.toString() ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: ProfessionalWebSeriesColors.primaryDark,
        body: Stack(
          children: [
            // Enhanced Background
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    ProfessionalWebSeriesColors.accentPurple.withOpacity(0.1),
                    ProfessionalWebSeriesColors.primaryDark,
                    ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.8),
                    ProfessionalWebSeriesColors.primaryDark,
                  ],
                ),
              ),
            ),

            // Main Content
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildProfessionalAppBar(),
                  Expanded(
                    child: _buildWebSeriesGrid(),
                  ),
                ],
              ),
            ),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: _buildLoadingIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.95),
            ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: ProfessionalWebSeriesColors.accentPurple.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalWebSeriesColors.accentPurple.withOpacity(0.3),
                  ProfessionalWebSeriesColors.accentBlue.withOpacity(0.3),
                ],
              ),
              border: Border.all(
                color:
                    ProfessionalWebSeriesColors.accentPurple.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      ProfessionalWebSeriesColors.accentPurple,
                      ProfessionalWebSeriesColors.accentBlue,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    widget.category['category'].toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ProfessionalWebSeriesColors.accentPurple
                            .withOpacity(0.3),
                        ProfessionalWebSeriesColors.accentBlue.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: ProfessionalWebSeriesColors.accentPurple
                          .withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tv_rounded,
                        size: 14,
                        color: ProfessionalWebSeriesColors.textSecondary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${widget.web_series.length} Series Available',
                        style: TextStyle(
                          color: ProfessionalWebSeriesColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ProfessionalWebSeriesColors.cardDark.withOpacity(0.6),
            ),
            child: IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: ProfessionalWebSeriesColors.textSecondary,
                size: 20,
              ),
              onPressed: () {
                // Add search functionality
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebSeriesGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        itemCount: widget.web_series.length,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          final webSeries = widget.web_series[index];
          String seriesId = webSeries['id'].toString();

          return AnimatedBuilder(
            animation: _staggerController,
            builder: (context, child) {
              final delay = (index / widget.web_series.length) * 0.5;
              final animationValue = Interval(
                delay,
                delay + 0.5,
                curve: Curves.easeOutCubic,
              ).transform(_staggerController.value);

              return Transform.translate(
                offset: Offset(0, 50 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue,
                  child: ProfessionalGridWebSeriesCard(
                    webSeries: webSeries,
                    focusNode: _nodes[seriesId]!,
                    onTap: () {
                      setState(() => _isLoading = true);
                      navigateToDetails(webSeries);
                      setState(() => _isLoading = false);
                    },
                    index: index,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(
              ProfessionalWebSeriesColors.accentPurple,
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Loading Series...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// 🔧 FIXED: Professional Grid WebSeries Card with Enter Key Navigation
class ProfessionalGridWebSeriesCard extends StatefulWidget {
  final dynamic webSeries;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int index;

  const ProfessionalGridWebSeriesCard({
    Key? key,
    required this.webSeries,
    required this.focusNode,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  _ProfessionalGridWebSeriesCardState createState() =>
      _ProfessionalGridWebSeriesCardState();
}

class _ProfessionalGridWebSeriesCardState
    extends State<ProfessionalGridWebSeriesCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  Color _dominantColor = ProfessionalWebSeriesColors.accentPurple;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: WebSeriesAnimationTiming.focus,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: WebSeriesAnimationTiming.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });

    if (_isFocused) {
      _hoverController.forward();
      _glowController.forward();
      _generateDominantColor();
      HapticFeedback.lightImpact();
    } else {
      _hoverController.reverse();
      _glowController.reverse();
    }
  }

  void _generateDominantColor() {
    final colors = ProfessionalWebSeriesColors.gradientColors;
    _dominantColor = colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _glowController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      // 🔧 CRITICAL FIX: Add onKey handler for Enter key navigation
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            // 🎯 FIXED: Enter/Select key triggers navigation
            widget.onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    if (_isFocused) ...[
                      BoxShadow(
                        color: _dominantColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: Offset(0, 8),
                      ),
                      BoxShadow(
                        color: _dominantColor.withOpacity(0.2),
                        blurRadius: 35,
                        spreadRadius: 4,
                        offset: Offset(0, 12),
                      ),
                    ] else ...[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      _buildWebSeriesImage(),
                      if (_isFocused) _buildFocusBorder(),
                      _buildGradientOverlay(),
                      _buildWebSeriesInfo(),
                      if (_isFocused) _buildPlayButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWebSeriesImage() {
    final imageUrl = widget.webSeries['poster']?.toString() ??
        widget.webSeries['banner']?.toString() ??
        '';

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImagePlaceholder(),
              errorWidget: (context, url, error) => _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalWebSeriesColors.cardDark,
            ProfessionalWebSeriesColors.surfaceDark,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv_rounded,
              size: 40,
              color: ProfessionalWebSeriesColors.textSecondary,
            ),
            SizedBox(height: 8),
            Text(
              'No Image',
              style: TextStyle(
                color: ProfessionalWebSeriesColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusBorder() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 3,
            color: _dominantColor,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebSeriesInfo() {
    final seriesName = widget.webSeries['name']?.toString() ?? 'Unknown';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              seriesName.toUpperCase(),
              style: TextStyle(
                color: _isFocused ? _dominantColor : Colors.white,
                fontSize: _isFocused ? 13 : 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (_isFocused) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _dominantColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _dominantColor.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tv,
                          color: _dominantColor,
                          size: 8,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'SERIES',
                          style: TextStyle(
                            color: _dominantColor,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'HD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _dominantColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: _dominantColor.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}





// // Enhanced Grid View for WebSeries
// class ProfessionalCategoryWebSeriesGridView extends StatefulWidget {
//   final Map<String, dynamic> category;
//   final List<dynamic> web_series;

//   const ProfessionalCategoryWebSeriesGridView({
//     Key? key,
//     required this.category,
//     required this.web_series,
//   }) : super(key: key);

//   @override
//   _ProfessionalCategoryWebSeriesGridViewState createState() =>
//       _ProfessionalCategoryWebSeriesGridViewState();
// }

// class _ProfessionalCategoryWebSeriesGridViewState
//     extends State<ProfessionalCategoryWebSeriesGridView>
//     with TickerProviderStateMixin {
//   bool _isLoading = false;
//   late Map<String, FocusNode> _nodes;

//   // Animation Controllers
//   late AnimationController _fadeController;
//   late AnimationController _staggerController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _nodes = {for (var m in widget.web_series) '${m['id']}': FocusNode()};

//     _initializeAnimations();
//     _startStaggeredAnimation();
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       duration: Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _staggerController = AnimationController(
//       duration: Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   void _startStaggeredAnimation() {
//     _fadeController.forward();
//     _staggerController.forward();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _staggerController.dispose();
//     for (var node in _nodes.values) node.dispose();
//     super.dispose();
//   }

//   Future<bool> _onWillPop() async {
//     if (_isLoading) {
//       setState(() => _isLoading = false);
//       return false;
//     }
//     return true;
//   }

//   void navigateToDetails(dynamic webSeries) {
//     final channelList = widget.web_series.map((m) {
//       return NewsItemModel(
//         id: m['id']?.toString() ?? '',
//         name: m['name']?.toString() ?? '',
//         poster: m['poster']?.toString() ?? '',
//         banner: m['banner']?.toString() ?? '',
//         description: m['description']?.toString() ?? '',
//         category: widget.category['category'],
//         index: '',
//         url: '',
//         videoId: '',
//         streamType: '',
//         type: '',
//         genres: '',
//         status: '',
//         image: '',
//         unUpdatedUrl: '',
//       );
//     }).toList();

//     int seriesId;
//     if (webSeries['id'] is int) {
//       seriesId = webSeries['id'];
//     } else if (webSeries['id'] is String) {
//       try {
//         seriesId = int.parse(webSeries['id']);
//       } catch (e) {
//         return;
//       }
//     } else {
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => WebSeriesDetailsPage(
//           id: seriesId,
//           channelList: channelList,
//           source: 'manage_web_series',
//           banner: webSeries['banner']?.toString() ??
//               webSeries['poster']?.toString() ??
//               '',
//           poster: webSeries['poster']?.toString() ??
//               webSeries['banner']?.toString() ??
//               '',
//           name: webSeries['name']?.toString() ?? '',
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: ProfessionalWebSeriesColors.primaryDark,
//         body: Stack(
//           children: [
//             // Enhanced Background
//             Container(
//               decoration: BoxDecoration(
//                 gradient: RadialGradient(
//                   center: Alignment.topRight,
//                   radius: 1.5,
//                   colors: [
//                     ProfessionalWebSeriesColors.accentPurple.withOpacity(0.1),
//                     ProfessionalWebSeriesColors.primaryDark,
//                     ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.8),
//                     ProfessionalWebSeriesColors.primaryDark,
//                   ],
//                 ),
//               ),
//             ),

//             // Main Content
//             FadeTransition(
//               opacity: _fadeAnimation,
//               child: Column(
//                 children: [
//                   _buildProfessionalAppBar(),
//                   Expanded(
//                     child: _buildWebSeriesGrid(),
//                   ),
//                 ],
//               ),
//             ),

//             // Loading Overlay
//             if (_isLoading)
//               Container(
//                 color: Colors.black.withOpacity(0.7),
//                 child: Center(
//                   child: _buildLoadingIndicator(),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalAppBar() {
//     return Container(
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 10,
//         left: 20,
//         right: 20,
//         bottom: 20,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.95),
//             ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.7),
//             Colors.transparent,
//           ],
//         ),
//         border: Border(
//           bottom: BorderSide(
//             color: ProfessionalWebSeriesColors.accentPurple.withOpacity(0.2),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalWebSeriesColors.accentPurple.withOpacity(0.3),
//                   ProfessionalWebSeriesColors.accentBlue.withOpacity(0.3),
//                 ],
//               ),
//               border: Border.all(
//                 color:
//                     ProfessionalWebSeriesColors.accentPurple.withOpacity(0.5),
//                 width: 1,
//               ),
//             ),
//             child: IconButton(
//               icon: Icon(
//                 Icons.arrow_back_rounded,
//                 color: Colors.white,
//                 size: 24,
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ShaderMask(
//                   shaderCallback: (bounds) => LinearGradient(
//                     colors: [
//                       ProfessionalWebSeriesColors.accentPurple,
//                       ProfessionalWebSeriesColors.accentBlue,
//                     ],
//                   ).createShader(bounds),
//                   child: Text(
//                     widget.category['category'].toString(),
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         ProfessionalWebSeriesColors.accentPurple
//                             .withOpacity(0.3),
//                         ProfessionalWebSeriesColors.accentBlue.withOpacity(0.3),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(
//                       color: ProfessionalWebSeriesColors.accentPurple
//                           .withOpacity(0.5),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.tv_rounded,
//                         size: 14,
//                         color: ProfessionalWebSeriesColors.textSecondary,
//                       ),
//                       SizedBox(width: 6),
//                       Text(
//                         '${widget.web_series.length} Series Available',
//                         style: TextStyle(
//                           color: ProfessionalWebSeriesColors.textSecondary,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: ProfessionalWebSeriesColors.cardDark.withOpacity(0.6),
//             ),
//             child: IconButton(
//               icon: Icon(
//                 Icons.search_rounded,
//                 color: ProfessionalWebSeriesColors.textSecondary,
//                 size: 20,
//               ),
//               onPressed: () {
//                 // Add search functionality
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWebSeriesGrid() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       child: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 5,
//           mainAxisSpacing: 16,
//           crossAxisSpacing: 16,
//           childAspectRatio: 0.68,
//         ),
//         itemCount: widget.web_series.length,
//         clipBehavior: Clip.none,
//         itemBuilder: (context, index) {
//           final webSeries = widget.web_series[index];
//           String seriesId = webSeries['id'].toString();

//           return AnimatedBuilder(
//             animation: _staggerController,
//             builder: (context, child) {
//               final delay = (index / widget.web_series.length) * 0.5;
//               final animationValue = Interval(
//                 delay,
//                 delay + 0.5,
//                 curve: Curves.easeOutCubic,
//               ).transform(_staggerController.value);

//               return Transform.translate(
//                 offset: Offset(0, 50 * (1 - animationValue)),
//                 child: Opacity(
//                   opacity: animationValue,
//                   child: ProfessionalGridWebSeriesCard(
//                     webSeries: webSeries,
//                     focusNode: _nodes[seriesId]!,
//                     onTap: () {
//                       setState(() => _isLoading = true);
//                       navigateToDetails(webSeries);
//                       setState(() => _isLoading = false);
//                     },
//                     index: index,
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: 60,
//           height: 60,
//           child: CircularProgressIndicator(
//             strokeWidth: 4,
//             valueColor: AlwaysStoppedAnimation<Color>(
//               ProfessionalWebSeriesColors.accentPurple,
//             ),
//           ),
//         ),
//         SizedBox(height: 20),
//         Text(
//           'Loading Series...',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Professional Grid WebSeries Card
// class ProfessionalGridWebSeriesCard extends StatefulWidget {
//   final dynamic webSeries;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int index;

//   const ProfessionalGridWebSeriesCard({
//     Key? key,
//     required this.webSeries,
//     required this.focusNode,
//     required this.onTap,
//     required this.index,
//   }) : super(key: key);

//   @override
//   _ProfessionalGridWebSeriesCardState createState() =>
//       _ProfessionalGridWebSeriesCardState();
// }

// class _ProfessionalGridWebSeriesCardState
//     extends State<ProfessionalGridWebSeriesCard> with TickerProviderStateMixin {
//   late AnimationController _hoverController;
//   late AnimationController _glowController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;

//   Color _dominantColor = ProfessionalWebSeriesColors.accentPurple;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();

//     _hoverController = AnimationController(
//       duration: WebSeriesAnimationTiming.focus,
//       vsync: this,
//     );

//     _glowController = AnimationController(
//       duration: WebSeriesAnimationTiming.medium,
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.05,
//     ).animate(CurvedAnimation(
//       parent: _hoverController,
//       curve: Curves.easeOutCubic,
//     ));

//     _glowAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _glowController,
//       curve: Curves.easeInOut,
//     ));

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _hoverController.forward();
//       _glowController.forward();
//       _generateDominantColor();
//       HapticFeedback.lightImpact();
//     } else {
//       _hoverController.reverse();
//       _glowController.reverse();
//     }
//   }

//   void _generateDominantColor() {
//     final colors = ProfessionalWebSeriesColors.gradientColors;
//     _dominantColor = colors[math.Random().nextInt(colors.length)];
//   }

//   @override
//   void dispose() {
//     _hoverController.dispose();
//     _glowController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       focusNode: widget.focusNode,
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: AnimatedBuilder(
//           animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
//           builder: (context, child) {
//             return Transform.scale(
//               scale: _scaleAnimation.value,
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     if (_isFocused) ...[
//                       BoxShadow(
//                         color: _dominantColor.withOpacity(0.4),
//                         blurRadius: 20,
//                         spreadRadius: 2,
//                         offset: Offset(0, 8),
//                       ),
//                       BoxShadow(
//                         color: _dominantColor.withOpacity(0.2),
//                         blurRadius: 35,
//                         spreadRadius: 4,
//                         offset: Offset(0, 12),
//                       ),
//                     ] else ...[
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 8,
//                         spreadRadius: 1,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: Stack(
//                     children: [
//                       _buildWebSeriesImage(),
//                       if (_isFocused) _buildFocusBorder(),
//                       _buildGradientOverlay(),
//                       _buildWebSeriesInfo(),
//                       if (_isFocused) _buildPlayButton(),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildWebSeriesImage() {
//     final imageUrl = widget.webSeries['poster']?.toString() ??
//         widget.webSeries['banner']?.toString() ??
//         '';

//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       child: imageUrl.isNotEmpty
//           ? CachedNetworkImage(
//               imageUrl: imageUrl,
//               fit: BoxFit.cover,
//               placeholder: (context, url) => _buildImagePlaceholder(),
//               errorWidget: (context, url, error) => _buildImagePlaceholder(),
//             )
//           : _buildImagePlaceholder(),
//     );
//   }

//   Widget _buildImagePlaceholder() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalWebSeriesColors.cardDark,
//             ProfessionalWebSeriesColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.tv_rounded,
//               size: 40,
//               color: ProfessionalWebSeriesColors.textSecondary,
//             ),
//             SizedBox(height: 8),
//             Text(
//               'No Image',
//               style: TextStyle(
//                 color: ProfessionalWebSeriesColors.textSecondary,
//                 fontSize: 10,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFocusBorder() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             width: 3,
//             color: _dominantColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGradientOverlay() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               Colors.transparent,
//               Colors.black.withOpacity(0.7),
//               Colors.black.withOpacity(0.9),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildWebSeriesInfo() {
//     final seriesName = widget.webSeries['name']?.toString() ?? 'Unknown';

//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Padding(
//         padding: EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               seriesName.toUpperCase(),
//               style: TextStyle(
//                 color: _isFocused ? _dominantColor : Colors.white,
//                 fontSize: _isFocused ? 13 : 12,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5,
//                 shadows: [
//                   Shadow(
//                     color: Colors.black.withOpacity(0.8),
//                     blurRadius: 4,
//                     offset: Offset(0, 1),
//                   ),
//                 ],
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (_isFocused) ...[
//               SizedBox(height: 4),
//               Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: _dominantColor.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: _dominantColor.withOpacity(0.4),
//                         width: 1,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.tv,
//                           color: _dominantColor,
//                           size: 8,
//                         ),
//                         SizedBox(width: 2),
//                         Text(
//                           'SERIES',
//                           style: TextStyle(
//                             color: _dominantColor,
//                             fontSize: 8,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 6),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       'HD',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 8,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlayButton() {
//     return Positioned(
//       top: 12,
//       right: 12,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: _dominantColor.withOpacity(0.9),
//           boxShadow: [
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.4),
//               blurRadius: 8,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Icon(
//           Icons.play_arrow_rounded,
//           color: Colors.white,
//           size: 24,
//         ),
//       ),
//     );
//   }
// }

// // Usage Instructions and Integration Guide
// /*
// 🎯 INTEGRATION GUIDE:

// 1. Replace your existing ManageWebseries class with ProfessionalManageWebseries
// 2. Replace ViewAllWidget with ProfessionalWebSeriesViewAllButton  
// 3. Replace CategoryMoviesGridView with ProfessionalCategoryWebSeriesGridView
// 4. Add the Professional color scheme and timing classes

// 🔄 MAIN REPLACEMENTS:

// OLD CODE:
// ```dart
// class ManageWebseries extends StatefulWidget {
//   // ... existing code
// }
// ```

// NEW CODE:
// ```dart
// class ProfessionalManageWebseries extends StatefulWidget {
//   // ... enhanced code with animations
// }
// ```

// 🎨 KEY FEATURES ADDED:

// ✅ Professional color scheme matching movies
// ✅ Smooth animations (700ms duration like movies)
// ✅ Enhanced shadows and glow effects
// ✅ Professional loading indicators
// ✅ Shimmer effects on focus
// ✅ Staggered grid animations
// ✅ Enhanced app bar with gradients
// ✅ Better error handling
// ✅ Improved focus management
// ✅ TV series badges instead of movie badges
// ✅ Purple/Blue gradient theme for WebSeries

// 📱 RESULT:
// Your WebSeries screen will now perfectly match the professional 
// Movies screen with consistent animations, colors, and effects!

// 🚀 All features from the Movies screen are now available for WebSeries:
// - Same animation timing (700ms)
// - Same scale effects (1.04x)
// - Same shadow patterns
// - Same shimmer effects
// - Same professional loading
// - Same grid layout
// - Same focus management
// */