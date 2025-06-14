



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart' as loading_indicator;
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

//   @override
//   void initState() {
//     super.initState();
//     _loadCachedWebseriesDataAndFetch();
//   }


//   Future<void> _loadCachedWebseriesDataAndFetch() async {
//   setState(() {
//     isLoading = true;
//     debugMessage = '';
//   });

//   try {
//     // Load cached data
//     final prefs = await SharedPreferences.getInstance();
//     final cached = prefs.getString('webseries_list');
//     if (cached != null) {
//       final List<dynamic> cachedData = jsonDecode(cached);
//       setState(() {
//         categories = List<Map<String, dynamic>>.from(cachedData);
//         _initializeFocusNodes(); // Add this line
//         isLoading = false;
//       });
//       _registerWebseriesFocus(); // Add this line
//     }

//     // Background fetch & update if changed
//     await _fetchWebseriesInBackground();
//   } catch (e) {
//     setState(() {
//       debugMessage = "Failed to load webseries";
//       isLoading = false;
//     });
//   }
// }

// // Add this method to initialize focus nodes:
// void _initializeFocusNodes() {
//   focusNodesMap.clear();
//   for (var cat in categories) {
//     final catId = '${cat['id']}';
//     focusNodesMap[catId] = {};
//     final webSeriesList = cat['web_series'] as List<dynamic>;
//     for (var series in webSeriesList) {
//       final seriesId = '${series['id']}';
//       focusNodesMap[catId]![seriesId] = FocusNode()
//         ..addListener(() {
//           if (focusNodesMap[catId]![seriesId]!.hasFocus) {
//             _scrollToFocusedItem(catId, seriesId);
//           }
//         });
//     }
//   }
// }

// // Add this method to register focus with provider:
// void _registerWebseriesFocus() {
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     if (categories.isNotEmpty && mounted) {
//       final firstCid = '${categories[0]['id']}';
//       final firstWebSeries = categories[0]['web_series'] as List<dynamic>;
//       if (firstWebSeries.isNotEmpty) {
//         final firstSid = '${firstWebSeries[0]['id']}';
//         final node = focusNodesMap[firstCid]?[firstSid];
//         if (node != null) {
//           context.read<FocusProvider>().setFirstManageWebseriesFocusNode(node);
//           print('🎭 Registered First Webseries FocusNode: $node');
//         }
//       }
//     }
//   });
// }

// // Update the _fetchWebseriesInBackground method:
// Future<void> _fetchWebseriesInBackground() async {
//   try {
//     final response = await http.get(
//       Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//       headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> flatData = jsonDecode(response.body);
//       final Map<String, List<dynamic>> grouped = {};
//       for (var item in flatData) {
//         final tagName = item['custom_tag']?['custom_tags_name'] ?? 'Unknown';
//         grouped.putIfAbsent(tagName, () => []).add(item);
//       }
//       final List<Map<String, dynamic>> newCats = grouped.entries.map((e) => {
//         'id': e.value.first['custom_tag']?['custom_tags_id'] ?? '0',
//         'category': e.key,
//         'web_series': _sortByIndex(e.value),
//       }).toList();

//       final prefs = await SharedPreferences.getInstance();
//       final newJson = jsonEncode(newCats);
//       final cached = prefs.getString('webseries_list');

//       if (cached == null || cached != newJson) {
//         await prefs.setString('webseries_list', newJson);
//         setState(() {
//           categories = newCats;
//           _initializeFocusNodes(); // Re-initialize focus nodes
//         });
//         _registerWebseriesFocus(); // Re-register focus
//       }
//     }
//   } catch (e) {
//     print('Error in background fetch: $e');
//   } finally {
//     setState(() {
//       isLoading = false;
//     });
//   }
// }


//   // // Fix: Remove _categories, use only categories
//   // Future<void> _loadCachedWebseriesDataAndFetch() async {
//   //   setState(() {
//   //     isLoading = true;
//   //     debugMessage = '';
//   //   });

//   //   try {
//   //     // Load cached data
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final cached = prefs.getString('webseries_list');
//   //     if (cached != null) {
//   //       final List<dynamic> cachedData = jsonDecode(cached);
//   //       setState(() {
//   //         categories = List<Map<String, dynamic>>.from(cachedData);
//   //         isLoading = false;
//   //       });
//   //     }

//   //     // 2. Background fetch & update if changed
//   //     await _fetchWebseriesInBackground();
//   //   } catch (e) {
//   //     setState(() {
//   //       debugMessage = "Failed to load webseries";
//   //       isLoading = false;
//   //     });
//   //   }
//   // }

//   // Future<void> _fetchWebseriesInBackground() async {
//   //   try {
//   //     final response = await http.get(
//   //       Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//   //       headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
//   //     );
//   //     if (response.statusCode == 200) {
//   //       final List<dynamic> flatData = jsonDecode(response.body);
//   //       final Map<String, List<dynamic>> grouped = {};
//   //       for (var item in flatData) {
//   //         final tagName = item['custom_tag']?['custom_tags_name'] ?? 'Unknown';
//   //         grouped.putIfAbsent(tagName, () => []).add(item);
//   //       }
//   //       final List<Map<String, dynamic>> newCats = grouped.entries.map((e) => {
//   //         'id': e.value.first['custom_tag']?['custom_tags_id'] ?? '0',
//   //         'category': e.key,
//   //         'web_series': _sortByIndex(e.value),
//   //       }).toList();

//   //       final prefs = await SharedPreferences.getInstance();
//   //       final newJson = jsonEncode(newCats);
//   //       final cached = prefs.getString('webseries_list');

//   //       if (cached == null || cached != newJson) {
//   //         await prefs.setString('webseries_list', newJson);
//   //         setState(() {
//   //           categories = newCats;
//   //         });
//   //       }
//   //       // even if not updated, ensure UI sees latest!
//   //       setState(() {
//   //         categories = newCats;
//   //       });
//   //     }
//   //   } catch (e) {
//   //     // ignore error, only update isLoading
//   //   } finally {
//   //     setState(() {
//   //       isLoading = false;
//   //     });
//   //   }
//   // }

//   List<dynamic> _sortByIndex(List<dynamic> list) {
//     list.sort((a, b) =>
//         (int.tryParse(a['index'] ?? '0') ?? 0)
//             .compareTo(int.tryParse(b['index'] ?? '0') ?? 0));
//     return list;
//   }








//   Future<void> _fetchDataWithRetry() async {
//     try {
//       await fetchData();
//     } catch (_) {
//       Future.delayed(const Duration(seconds: 2), () {
//         if (mounted) fetchData();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     for (var cat in focusNodesMap.values) {
//       for (var node in cat.values) node.dispose();
//     }
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Future<void> fetchData() async {
//     if (!mounted) return;
//     setState(() {
//       isLoading = true;
//       debugMessage = "Loading...";
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//         headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
//       ).timeout(const Duration(seconds: 15));

//       if (!mounted) return;

//       if (response.statusCode == 200 && response.body.isNotEmpty) {
//         // 1. Decode flat list
//         final List<dynamic> flatData = jsonDecode(response.body);

//         // 2. Group by custom_tag.custom_tags_name
//         final Map<String, List<dynamic>> grouped = {};
//         for (var item in flatData) {
//           final tagName = item['custom_tag']?['custom_tags_name'] ?? 'Unknown';
//           grouped.putIfAbsent(tagName, () => []).add(item);
//         }

//         // 3. Shape into [{ id, category, web_series: […] }, …]
//         final List<Map<String, dynamic>> nonEmptyCategories = grouped.entries
//             .map((e) => {
//                   'id': e.value.first['custom_tag']?['custom_tags_id'] ?? '0',
//                   'category': e.key,
//                   'web_series': e.value,
//                 })
//             .toList();

//         // 4. Update provider & build focus nodes
//         Provider.of<FocusProvider>(context, listen: false)
//             .updateCategoryCountWebseries(nonEmptyCategories.length);

//         final Map<String, Map<String, FocusNode>> newFocusMap = {};
//         for (var cat in nonEmptyCategories) {
//           final cid = '${cat['id']}';
//           newFocusMap[cid] = {
//             for (var series in cat['web_series']) '${series['id']}': FocusNode()
//           };
//         }

//         // 5. Set state
//         setState(() {
//           categories = nonEmptyCategories;
//           focusNodesMap = newFocusMap;
//           isLoading = false;
//           debugMessage = "Loaded ${nonEmptyCategories.length} categories";
//         });


        

//         // 6. Give first item initial focus
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
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Something went wrong')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         debugMessage = "Error: $e";
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   void navigateToDetails(
//       dynamic movie, String source, String banner, String name, int idx) {
//     final List<NewsItemModel> channelList =
//         (categories[idx]['web_series'] as List<dynamic>)
//             .map((m) => NewsItemModel(
//                   id: m['id'],
//                   name: m['name'],
//                   poster: m['poster'],
//                   banner: m['banner'],
//                   description: m['description'] ?? '',
//                   category: source,
//                   index: '',
//                   url: '',
//                   videoId: '',
//                   streamType: '',
//                   type: '',
//                   genres: '',
//                   status: '',
//                   image: '',
//                 ))
//             .toList();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => WebSeriesDetailsPage(
//           id: int.parse(movie['id']),
//           channelList: channelList,
//           source: 'manage-web_series',
//           banner: banner,
//           name: name,
//         ),
//       ),
//     );
//   }

//   // void _scrollToFocusedItem(String catId, String seriesId) {
//   //   final node = focusNodesMap[catId]?[seriesId];
//   //   if (node?.hasFocus != true || !_scrollController.hasClients) return;
//   //   final ctx = node!.context;
//   //   if (ctx != null && mounted) {
//   //     Scrollable.ensureVisible(
//   //       ctx,
//   //       alignment: 0.05,
//   //       duration: const Duration(milliseconds: 400),
//   //     );
//   //   }
//   // }

//   void _scrollToFocusedItem(String catId, String seriesId) {
//   final node = focusNodesMap[catId]?[seriesId];
//   if (node?.hasFocus != true || !_scrollController.hasClients) return;
//   final ctx = node!.context;
//   if (ctx != null && mounted) {
//     Scrollable.ensureVisible(
//       ctx,
//       alignment: 0.05,
//       duration: const Duration(milliseconds: 400),
//     );
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // for AutomaticKeepAliveClientMixin
//     return Consumer<ColorProvider>(
//       builder: (context, colorProv, child) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (categories.isNotEmpty) {
//             final firstCid = '${categories[0]['id']}';
//             final firstSid = '${categories[0]['web_series'].first['id']}';
//             final node = focusNodesMap[firstCid]?[firstSid];
//             if (node != null) {
//               Provider.of<FocusProvider>(context, listen: false)
//                   .setFirstManageWebseriesFocusNode(node);
//             }
//           }
//         });



//         final bgColor = colorProv.isItemFocused
//             ? colorProv.dominantColor.withOpacity(0.3)
//             : Colors.black;

//         if (isLoading) {
//           return Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 loading_indicator.LoadingIndicator(),
//                 const SizedBox(height: 12),
//                 Text(debugMessage, style: const TextStyle(color: Colors.white)),
//               ],
//             ),
//           );
//         }

//         if (categories.isEmpty) {
//           return const Center(
//             child: Text('No Content', style: TextStyle(color: Colors.white)),
//           );
//         }

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
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 8,
//                         ),
//                         child: Text(
//                           cat['category'].toString().toUpperCase(),
//                           style: TextStyle(
//                             color: hintColor,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.34,
//                         child: ListView.builder(
//                           controller: _scrollController,
//                           scrollDirection: Axis.horizontal,
//                           itemCount: list.length > 7 ? 8 : list.length + 1,
//                           itemBuilder: (_, idx) {
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
//                                   const EdgeInsets.symmetric(horizontal: 6),
//                               child: FocussableWebseriesWidget(
//                                 imageUrl: item['poster'],
//                                 name: item['name'],
//                                 // focusNode: node!,
//                                 focusNode: node ?? FocusNode(),

//                                 onFocusChange: (hasFocus) {
//                                   if (hasFocus)
//                                     _scrollToFocusedItem(catId, sid);
//                                 },
//                                 onUpPress: () {
//                                   // Request focus for ManageMovies first item
//                                   context
//                                       .read<FocusProvider>()
//                                       .requestManageMoviesFocus();
//                                 },
                                
//                                 onTap: () => navigateToDetails(
//                                   item,
//                                   cat['category'],
//                                   item['banner'],
//                                   item['name'],
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
//                     duration: const Duration(milliseconds: 400),
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
// // Full–screen grid when “View All” is tapped
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
//         id: m['id'],
//         name: m['name'],
//         poster: m['poster'],
//         banner: m['banner'],
//         description: m['description'] ?? '',
//         category: widget.category['category'],
//         index: '',
//         url: '',
//         videoId: '',
//         streamType: '',
//         type: '',
//         genres: '',
//         status: '',
//         image: '',
//       );
//     }).toList();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => WebSeriesDetailsPage(
//           id: int.parse(movie['id']),
//           channelList: channelList,
//           source: 'manage_web_series',
//           banner: movie['banner'],
//           name: movie['name'],
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
//                 mainAxisSpacing: 12,
//                 crossAxisSpacing: 12,
//                 childAspectRatio: 0.7,
//               ),
//               itemCount: widget.web_series.length,
//               itemBuilder: (_, idx) {
//                 final m = widget.web_series[idx];
//                 final id = '${m['id']}';
//                 return FocussableWebseriesWidget(
//                   imageUrl: m['poster'],
//                   name: m['name'],
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






import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart' as loading_indicator;
import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import 'focussable_webseries_widget.dart';
import '../../widgets/models/news_item_model.dart';
import 'webseries_details_page.dart'; // Assuming you have this page

class ManageWebseries extends StatefulWidget {
  final FocusNode focusNode;
  const ManageWebseries({Key? key, required this.focusNode}) : super(key: key);

  @override
  _ManageWebseriesState createState() => _ManageWebseriesState();
}

class _ManageWebseriesState extends State<ManageWebseries>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String debugMessage = "";

  Map<String, Map<String, FocusNode>> focusNodesMap = {};
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  // @override
  // void initState() {
  //   super.initState();
  //   _loadCachedWebseriesDataAndFetch();
  // }


// Fixed _sortByIndex method - यह main issue है:

List<dynamic> _sortByIndex(List<dynamic> list) {
  try {
    list.sort((a, b) {
      // ✅ Fix: Handle both int and string types for index
      dynamic indexA = a['index'];
      dynamic indexB = b['index'];
      
      int numA = 0;
      int numB = 0;
      
      // Handle different types of index values
      if (indexA is int) {
        numA = indexA;
      } else if (indexA is String) {
        numA = int.tryParse(indexA) ?? 0;
      } else {
        numA = 0;
      }
      
      if (indexB is int) {
        numB = indexB;
      } else if (indexB is String) {
        numB = int.tryParse(indexB) ?? 0;
      } else {
        numB = 0;
      }
      
      return numA.compareTo(numB);
    });
    
    // print('✅ Successfully sorted ${list.length} items by index');
    return list;
  } catch (e) {
    // print('🚨 Error in _sortByIndex: $e');
    // print('🚨 Returning unsorted list');
    return list; // Return unsorted list if sorting fails
  }
}

// Updated _fetchWebseriesInBackground method with better error handling:
Future<void> _fetchWebseriesInBackground() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String authKey = AuthManager.authKey;
    if (authKey.isEmpty) {
      authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
    }

    // print('🔑 Webseries - Using Auth Key: "$authKey"');

    final response = await http.get(
      Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
      headers: {
        'auth-key': authKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // print('📡 Webseries - Response Status: ${response.statusCode}');
    // print('📄 Webseries - Response Body Length: ${response.body.length}');
    
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        // print('⚠️ Webseries - Empty response body');
        return;
      }

      try {
        final List<dynamic> flatData = jsonDecode(response.body);
        print('📊 Webseries - Decoded ${flatData.length} items');
        
        if (flatData.isEmpty) {
          print('⚠️ Webseries - No data in response');
          setState(() {
            categories = [];
            isLoading = false;
          });
          return;
        }

        // Log first item structure
        if (flatData.isNotEmpty) {
          // print('📋 Webseries - First item structure: ${flatData[0]}');
          // print('📋 Webseries - First item keys: ${flatData[0].keys.toList()}');
          // print('📋 Webseries - Index field type: ${flatData[0]['index'].runtimeType}');
          // print('📋 Webseries - Index value: ${flatData[0]['index']}');
        }
        
        // ✅ Fix: Simple grouping without custom_tag dependency
        final Map<String, List<dynamic>> grouped = {};
        
        // Group all items into "Web Series" category
        if (flatData.isNotEmpty) {
          grouped['Web Series'] = flatData;
        }
        
        print('📂 Webseries - Grouped into ${grouped.length} categories');
        print('📂 Webseries - Category names: ${grouped.keys.toList()}');
        
        // ✅ Fix: Create categories with proper error handling
        final List<Map<String, dynamic>> newCats = [];
        
        for (var entry in grouped.entries) {
          try {
            final sortedItems = _sortByIndex(List.from(entry.value));
            newCats.add({
              'id': '1', // Default ID since no custom_tag
              'category': entry.key,
              'web_series': sortedItems,
            });
            // print('📂 Webseries - Category: ${entry.key} (${sortedItems.length} items)');
          } catch (e) {
            // print('🚨 Error processing category ${entry.key}: $e');
            // Add category without sorting if sorting fails
            newCats.add({
              'id': '1',
              'category': entry.key,
              'web_series': entry.value,
            });
          }
        }

        // print('📂 Webseries - Successfully created ${newCats.length} categories');

        // ✅ Fix: Safe JSON encoding with error handling
        try {
          final newJson = jsonEncode(newCats);
          final cached = prefs.getString('webseries_list');

          if (cached == null || cached != newJson) {
            await prefs.setString('webseries_list', newJson);
            // print('💾 Webseries - Cache updated');
            
            setState(() {
              categories = newCats;
              _initializeFocusNodes();
            });
            _registerWebseriesFocus();
          } else {
            // print('📋 Webseries - Data unchanged, using cache');
            // Even if cache unchanged, ensure UI is updated
            setState(() {
              categories = newCats;
              _initializeFocusNodes();
            });
            _registerWebseriesFocus();
          }
        } catch (e) {
          print('🚨 Webseries - JSON Encode Error: $e');
          // Still update UI even if caching fails
          setState(() {
            categories = newCats;
            _initializeFocusNodes();
          });
          _registerWebseriesFocus();
        }
        
      } catch (e) {
        // print('🚨 Webseries - JSON Decode Error: $e');
        // print('📄 Webseries - Raw response: ${response.body}');
      }
    } else {
      // print('❌ Webseries - API Error Status: ${response.statusCode}');
      // print('❌ Webseries - Error Body: ${response.body}');
    }
  } catch (e) {
    // print('🚨 Webseries - Network/Exception Error: $e');
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

// Also fix the fetchData method:
Future<void> fetchData() async {
  if (!mounted) return;
  setState(() {
    isLoading = true;
    debugMessage = "Loading...";
  });

  try {
    final prefs = await SharedPreferences.getInstance();
    String authKey = AuthManager.authKey;
    if (authKey.isEmpty) {
      authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
    }

    // print('🔑 fetchData - Using Auth Key: "$authKey"');

    final response = await http.get(
      Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
      headers: {
        'auth-key': authKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (!mounted) return;

    // print('📡 fetchData - Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final List<dynamic> flatData = jsonDecode(response.body);
      print('📊 fetchData - Fetched ${flatData.length} items');

      // ✅ Fix: Simple grouping
      final Map<String, List<dynamic>> grouped = {};
      
      if (flatData.isNotEmpty) {
        grouped['Web Series'] = flatData;
      }

      final List<Map<String, dynamic>> nonEmptyCategories = [];
      
      for (var entry in grouped.entries) {
        try {
          final sortedItems = _sortByIndex(List.from(entry.value));
          nonEmptyCategories.add({
            'id': '1',
            'category': entry.key,
            'web_series': sortedItems,
          });
        } catch (e) {
          // print('🚨 fetchData - Error processing category: $e');
          nonEmptyCategories.add({
            'id': '1',
            'category': entry.key,
            'web_series': entry.value,
          });
        }
      }

      Provider.of<FocusProvider>(context, listen: false)
          .updateCategoryCountWebseries(nonEmptyCategories.length);

      final Map<String, Map<String, FocusNode>> newFocusMap = {};
      for (var cat in nonEmptyCategories) {
        final cid = '${cat['id']}';
        newFocusMap[cid] = {
          for (var series in cat['web_series']) '${series['id']}': FocusNode()
        };
      }

      setState(() {
        categories = nonEmptyCategories;
        focusNodesMap = newFocusMap;
        isLoading = false;
        debugMessage = "Loaded ${nonEmptyCategories.length} categories";
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && categories.isNotEmpty) {
          final firstCid = '${categories[0]['id']}';
          final firstSid =
              '${(categories[0]['web_series'] as List).first['id']}';
          final node = focusNodesMap[firstCid]?[firstSid];
          if (node != null) {
            Provider.of<FocusProvider>(context, listen: false)
                .setFirstManageWebseriesFocusNode(node);
          }
        }
      });
    } else {
      // print('❌ fetchData - Error Response: ${response.statusCode} - ${response.body}');
      setState(() {
        isLoading = false;
        debugMessage = "Error: ${response.statusCode}";
      });
      
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('API Error: ${response.statusCode}')),
      // );
    }
  } catch (e) {
    // print('🚨 fetchData - Exception: $e');
    setState(() {
      isLoading = false;
      debugMessage = "Network Error: $e";
    });
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Network Error: $e')),
    // );
  }
}

// Debug method to check categories state:
void debugCategoriesState() {
  // print('🔍 === CATEGORIES DEBUG ===');
  // print('🔍 categories.length: ${categories.length}');
  // print('🔍 isLoading: $isLoading');
  // print('🔍 debugMessage: "$debugMessage"');
  
  if (categories.isNotEmpty) {
    // for (int i = 0; i < categories.length; i++) {
    //   final cat = categories[i];
    //   print('🔍 Category $i: ${cat['category']} (${cat['web_series'].length} items)');
    // }
  }
  // print('🔍 === CATEGORIES DEBUG END ===');
}

// // Add this to your build method for debugging:
// @override
// Widget build(BuildContext context) {
//   super.build(context);
  
//   // Debug categories state
//   debugCategoriesState();
  
//   return Consumer<ColorProvider>(
//     builder: (context, colorProv, child) {
//       // ... rest of your build method
//     },
//   );
// }

// // 1. _fetchWebseriesInBackground method में grouping logic को update करें
// Future<void> _fetchWebseriesInBackground() async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     String authKey = AuthManager.authKey;
//     if (authKey.isEmpty) {
//       authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//     }

//     print('🔑 Webseries - Using Auth Key: "$authKey"');

//     final response = await http.get(
//       Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//       headers: {
//         'auth-key': authKey,
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     );

//     print('📡 Webseries - Response Status: ${response.statusCode}');
//     print('📄 Webseries - Response Body Length: ${response.body.length}');
    
//     if (response.statusCode == 200) {
//       if (response.body.isEmpty) {
//         print('⚠️ Webseries - Empty response body');
//         return;
//       }

//       try {
//         final List<dynamic> flatData = jsonDecode(response.body);
//         print('📊 Webseries - Decoded ${flatData.length} items');
        
//         if (flatData.isEmpty) {
//           print('⚠️ Webseries - No data in response');
//           setState(() {
//             categories = [];
//             isLoading = false;
//           });
//           return;
//         }

//         // Log first item structure
//         if (flatData.isNotEmpty) {
//           print('📋 Webseries - First item structure: ${flatData[0]}');
//           print('📋 Webseries - First item keys: ${flatData[0].keys.toList()}');
//         }
        
//         // ✅ Fix: API response में custom_tag नहीं है, सभी items को "Web Series" category में डालें
//         final Map<String, List<dynamic>> grouped = {};
        
//         // Option 1: सभी items को single category में डालें
//         if (flatData.isNotEmpty) {
//           grouped['Web Series'] = flatData;
//         }
        
//         // Option 2: अगर कोई category field है तो उसका use करें
//         // for (var item in flatData) {
//         //   // यहाँ आप कोई दूसरा field use कर सकते हैं category के लिए
//         //   final categoryName = item['type'] == 1 ? 'Movies' : 'Web Series';
//         //   grouped.putIfAbsent(categoryName, () => []).add(item);
//         // }
        
//         print('📂 Webseries - Grouped into ${grouped.length} categories');
//         print('📂 Webseries - Category names: ${grouped.keys.toList()}');
        
//         final List<Map<String, dynamic>> newCats = grouped.entries.map((e) => {
//           'id': '1', // Default ID since no custom_tag
//           'category': e.key,
//           'web_series': _sortByIndex(e.value),
//         }).toList();

//         print('📂 Webseries - Created ${newCats.length} categories');
//         for (var cat in newCats) {
//           print('📂 Webseries - Category: ${cat['category']} (${(cat['web_series'] as List).length} items)');
//         }

//         final newJson = jsonEncode(newCats);
//         final cached = prefs.getString('webseries_list');

//         if (cached == null || cached != newJson) {
//           await prefs.setString('webseries_list', newJson);
//           print('💾 Webseries - Cache updated');
//           setState(() {
//             categories = newCats;
//             _initializeFocusNodes();
//           });
//           _registerWebseriesFocus();
//         } else {
//           print('📋 Webseries - Data unchanged, using cache');
//         }
//       } catch (e) {
//         print('🚨 Webseries - JSON Decode Error: $e');
//         print('📄 Webseries - Raw response: ${response.body}');
//       }
//     } else {
//       print('❌ Webseries - API Error Status: ${response.statusCode}');
//       print('❌ Webseries - Error Body: ${response.body}');
//     }
//   } catch (e) {
//     print('🚨 Webseries - Network/Exception Error: $e');
//   } finally {
//     setState(() {
//       isLoading = false;
//     });
//   }
// }

// // 2. fetchData method को भी update करें
// Future<void> fetchData() async {
//   if (!mounted) return;
//   setState(() {
//     isLoading = true;
//     debugMessage = "Loading...";
//   });

//   try {
//     final prefs = await SharedPreferences.getInstance();
//     String authKey = AuthManager.authKey;
//     if (authKey.isEmpty) {
//       authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//     }

//     print('🔑 fetchData - Using Auth Key: "$authKey"');

//     final response = await http.get(
//       Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//       headers: {
//         'auth-key': authKey,
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     ).timeout(const Duration(seconds: 15));

//     if (!mounted) return;

//     print('📡 fetchData - Response Status: ${response.statusCode}');
    
//     if (response.statusCode == 200 && response.body.isNotEmpty) {
//       final List<dynamic> flatData = jsonDecode(response.body);
//       print('📊 fetchData - Fetched ${flatData.length} items');

//       // ✅ Fix: API response के अनुसार grouping
//       final Map<String, List<dynamic>> grouped = {};
      
//       // Simple grouping - सभी items को "Web Series" में डालें
//       if (flatData.isNotEmpty) {
//         grouped['Web Series'] = flatData;
//       }

//       final List<Map<String, dynamic>> nonEmptyCategories = grouped.entries
//           .map((e) => {
//                 'id': '1', // Default ID
//                 'category': e.key,
//                 'web_series': e.value,
//               })
//           .toList();

//       Provider.of<FocusProvider>(context, listen: false)
//           .updateCategoryCountWebseries(nonEmptyCategories.length);

//       final Map<String, Map<String, FocusNode>> newFocusMap = {};
//       for (var cat in nonEmptyCategories) {
//         final cid = '${cat['id']}';
//         newFocusMap[cid] = {
//           for (var series in cat['web_series']) '${series['id']}': FocusNode()
//         };
//       }

//       setState(() {
//         categories = nonEmptyCategories;
//         focusNodesMap = newFocusMap;
//         isLoading = false;
//         debugMessage = "Loaded ${nonEmptyCategories.length} categories";
//       });

//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted && categories.isNotEmpty) {
//           final firstCid = '${categories[0]['id']}';
//           final firstSid =
//               '${(categories[0]['web_series'] as List).first['id']}';
//           final node = focusNodesMap[firstCid]?[firstSid];
//           if (node != null) {
//             Provider.of<FocusProvider>(context, listen: false)
//                 .setFirstManageWebseriesFocusNode(node);
//           }
//         }
//       });
//     } else {
//       print('❌ fetchData - Error Response: ${response.statusCode} - ${response.body}');
//       setState(() {
//         isLoading = false;
//         debugMessage = "Error: ${response.statusCode}";
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('API Error: ${response.statusCode}')),
//       );
//     }
//   } catch (e) {
//     print('🚨 fetchData - Exception: $e');
//     setState(() {
//       isLoading = false;
//       debugMessage = "Network Error: $e";
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Network Error: $e')),
//     );
//   }
// }

// 3. अगर आप category based grouping चाहते हैं तो यह function use करें:
Map<String, List<dynamic>> createSmartGrouping(List<dynamic> flatData) {
  final Map<String, List<dynamic>> grouped = {};
  
  for (var item in flatData) {
    String categoryName = 'Web Series'; // Default category
    
    // आप अलग-अलग fields के base पर categories बना सकते हैं:
    
    // Option 1: content_type के base पर
    if (item['content_type'] == 1) {
      categoryName = 'Movies';
    } else if (item['content_type'] == 2) {
      categoryName = 'Web Series';
    }
    
    // Option 2: name के base पर (अगर name में कुछ pattern है)
    // String name = item['name']?.toString()?.toLowerCase() ?? '';
    // if (name.contains('wildlife') || name.contains('animals')) {
    //   categoryName = 'Nature';
    // } else if (name.contains('drama')) {
    //   categoryName = 'Drama';
    // }
    
    // Option 3: featured के base पर
    // if (item['featured'] == 1) {
    //   categoryName = 'Featured';
    // } else {
    //   categoryName = 'Regular';
    // }
    
    grouped.putIfAbsent(categoryName, () => []).add(item);
  }
  
  return grouped;
}

// 4. अगर आप smart grouping use करना चाहते हैं तो _fetchWebseriesInBackground में यह line replace करें:
// final Map<String, List<dynamic>> grouped = createSmartGrouping(flatData);

// 5. Enhanced initState with detailed debugging
@override
void initState() {
  super.initState();
  
  // print('🔍 === WEBSERIES INIT START ===');
  // print('🔍 AuthManager.authKey: "${AuthManager.authKey}"');
  
  // Check SharedPreferences
  SharedPreferences.getInstance().then((prefs) {
    final storedKey = prefs.getString('auth_key');
    // print('🔍 SharedPreferences auth_key: "$storedKey"');
    final cachedData = prefs.getString('webseries_list');
    // print('🔍 Cached webseries data exists: ${cachedData != null}');
    // print('🔍 === WEBSERIES INIT END ===');
  });
  
  // Manual API test
  // testWebseriesAPI();
  
  // Regular initialization
  _loadCachedWebseriesDataAndFetch();
}

// // 6. Updated testWebseriesAPI method
// void testWebseriesAPI() async {
//   try {
//     print('🧪 Testing Webseries API manually...');
    
//     final response = await http.get(
//       Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//       headers: {
//         'auth-key': 'vLQTuPZUxktl5mVW',
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     );
    
//     // print('🧪 Test Response Status: ${response.statusCode}');
//     // print('🧪 Test Response Body Length: ${response.body.length}');
    
//     if (response.statusCode == 200) {
//       try {
//         final data = jsonDecode(response.body);
//         print('🧪 Test Success - Data type: ${data.runtimeType}');
//         if (data is List) {
//           print('🧪 Test Success - Items count: ${data.length}');
//           if (data.isNotEmpty) {
//             print('🧪 Test Success - First item: ${data[0]}');
//             print('🧪 Test Success - Available fields: ${data[0].keys.toList()}');
            
//             // Check for possible category fields
//             var item = data[0];
//             print('🧪 Possible category fields:');
//             print('🧪 - content_type: ${item['content_type']}');
//             print('🧪 - type: ${item['type']}');
//             print('🧪 - featured: ${item['featured']}');
//             print('🧪 - status: ${item['status']}');
//             print('🧪 - name: ${item['name']}');
//           }
//         }
//       } catch (e) {
//         print('🧪 Test JSON Error: $e');
//       }
//     } else {
//       print('🧪 Test Failed - Status: ${response.statusCode}');
//       print('🧪 Test Failed - Body: ${response.body}');
//     }
//   } catch (e) {
//     print('🧪 Test Network Error: $e');
//   }
// }


//   // 1. Enhanced debugging के साथ _fetchWebseriesInBackground
// Future<void> _fetchWebseriesInBackground() async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     String authKey = AuthManager.authKey;
//     if (authKey.isEmpty) {
//       authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//     }

//     print('🔑 Webseries - Using Auth Key: "$authKey"');
//     print('🔑 Webseries - AuthManager.authKey: "${AuthManager.authKey}"');
//     print('🔑 Webseries - Key length: ${authKey.length}');

//     final response = await http.get(
//       Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//       headers: {
//         'auth-key': authKey,
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     );

//     print('📡 Webseries - Response Status: ${response.statusCode}');
//     print('📡 Webseries - Response Headers: ${response.headers}');
//     print('📄 Webseries - Response Body Length: ${response.body.length}');
    
//     if (response.body.isNotEmpty) {
//       print('📄 Webseries - Response Preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
//     }
    
//     if (response.statusCode == 200) {
//       if (response.body.isEmpty) {
//         print('⚠️ Webseries - Empty response body');
//         return;
//       }

//       try {
//         final List<dynamic> flatData = jsonDecode(response.body);
//         print('📊 Webseries - Decoded ${flatData.length} items');
        
//         if (flatData.isEmpty) {
//           print('⚠️ Webseries - No data in response');
//           setState(() {
//             categories = [];
//             isLoading = false;
//           });
//           return;
//         }

//         // Log first item structure
//         if (flatData.isNotEmpty) {
//           print('📋 Webseries - First item structure: ${flatData[0]}');
//           print('📋 Webseries - First item keys: ${flatData[0].keys.toList()}');
//           if (flatData[0]['custom_tag'] != null) {
//             print('📋 Webseries - Custom tag: ${flatData[0]['custom_tag']}');
//           }
//         }
        
//         final Map<String, List<dynamic>> grouped = {};
//         for (var item in flatData) {
//           final tagName = item['custom_tag']?['custom_tags_name'] ?? 'Unknown';
//           grouped.putIfAbsent(tagName, () => []).add(item);
//         }
        
//         print('📂 Webseries - Grouped into ${grouped.length} categories');
//         print('📂 Webseries - Category names: ${grouped.keys.toList()}');
        
//         final List<Map<String, dynamic>> newCats = grouped.entries.map((e) => {
//           'id': e.value.first['custom_tag']?['custom_tags_id'] ?? '0',
//           'category': e.key,
//           'web_series': _sortByIndex(e.value),
//         }).toList();

//         print('📂 Webseries - Created ${newCats.length} categories');
//         for (var cat in newCats) {
//           print('📂 Webseries - Category: ${cat['category']} (${(cat['web_series'] as List).length} items)');
//         }

//         final newJson = jsonEncode(newCats);
//         final cached = prefs.getString('webseries_list');

//         if (cached == null || cached != newJson) {
//           await prefs.setString('webseries_list', newJson);
//           print('💾 Webseries - Cache updated');
//           setState(() {
//             categories = newCats;
//             _initializeFocusNodes();
//           });
//           _registerWebseriesFocus();
//         } else {
//           print('📋 Webseries - Data unchanged, using cache');
//         }
//       } catch (e) {
//         print('🚨 Webseries - JSON Decode Error: $e');
//         print('📄 Webseries - Raw response: ${response.body}');
//       }
//     } else {
//       print('❌ Webseries - API Error Status: ${response.statusCode}');
//       print('❌ Webseries - Error Body: ${response.body}');
      
//       // Try to decode error response
//       try {
//         final errorData = jsonDecode(response.body);
//         print('❌ Webseries - Error Data: $errorData');
//       } catch (e) {
//         print('❌ Webseries - Raw Error Response: ${response.body}');
//       }
//     }
//   } catch (e) {
//     print('🚨 Webseries - Network/Exception Error: $e');
//     print('🚨 Webseries - Error Type: ${e.runtimeType}');
//   } finally {
//     setState(() {
//       isLoading = false;
//     });
//   }
// }




// // 2. Enhanced fetchData method
// Future<void> fetchData() async {
//   if (!mounted) return;
//   setState(() {
//     isLoading = true;
//     debugMessage = "Loading...";
//   });

//   try {
//     final prefs = await SharedPreferences.getInstance();
//     String authKey = AuthManager.authKey;
//     if (authKey.isEmpty) {
//       authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//     }

//     print('🔑 fetchData - Using Auth Key: "$authKey"');

//     final response = await http.get(
//       Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//       headers: {
//         'auth-key': authKey,
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     ).timeout(const Duration(seconds: 15));

//     if (!mounted) return;

//     print('📡 fetchData - Response Status: ${response.statusCode}');
    
//     if (response.statusCode == 200 && response.body.isNotEmpty) {
//       final List<dynamic> flatData = jsonDecode(response.body);
//       print('📊 fetchData - Fetched ${flatData.length} items');

//       final Map<String, List<dynamic>> grouped = {};
//       for (var item in flatData) {
//         final tagName = item['custom_tag']?['custom_tags_name'] ?? 'Unknown';
//         grouped.putIfAbsent(tagName, () => []).add(item);
//       }

//       final List<Map<String, dynamic>> nonEmptyCategories = grouped.entries
//           .map((e) => {
//                 'id': e.value.first['custom_tag']?['custom_tags_id'] ?? '0',
//                 'category': e.key,
//                 'web_series': e.value,
//               })
//           .toList();

//       Provider.of<FocusProvider>(context, listen: false)
//           .updateCategoryCountWebseries(nonEmptyCategories.length);

//       final Map<String, Map<String, FocusNode>> newFocusMap = {};
//       for (var cat in nonEmptyCategories) {
//         final cid = '${cat['id']}';
//         newFocusMap[cid] = {
//           for (var series in cat['web_series']) '${series['id']}': FocusNode()
//         };
//       }

//       setState(() {
//         categories = nonEmptyCategories;
//         focusNodesMap = newFocusMap;
//         isLoading = false;
//         debugMessage = "Loaded ${nonEmptyCategories.length} categories";
//       });

//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted && categories.isNotEmpty) {
//           final firstCid = '${categories[0]['id']}';
//           final firstSid =
//               '${(categories[0]['web_series'] as List).first['id']}';
//           final node = focusNodesMap[firstCid]?[firstSid];
//           if (node != null) {
//             Provider.of<FocusProvider>(context, listen: false)
//                 .setFirstManageWebseriesFocusNode(node);
//           }
//         }
//       });
//     } else {
//       print('❌ fetchData - Error Response: ${response.statusCode} - ${response.body}');
//       setState(() {
//         isLoading = false;
//         debugMessage = "Error: ${response.statusCode} - ${response.body.length > 50 ? response.body.substring(0, 50) + '...' : response.body}";
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('API Error: ${response.statusCode}')),
//       );
//     }
//   } catch (e) {
//     print('🚨 fetchData - Exception: $e');
//     setState(() {
//       isLoading = false;
//       debugMessage = "Network Error: $e";
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Network Error: $e')),
//     );
//   }
// }

// // 3. Manual API test with auth-key
// void testWebseriesAPI() async {
//   try {
//     print('🧪 Testing Webseries API manually...');
    
//     // Test with default key
//     var response = await http.get(
//       Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//       headers: {
//         'auth-key': 'vLQTuPZUxktl5mVW',
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     );
    
//     print('🧪 Test Response Status: ${response.statusCode}');
//     print('🧪 Test Response Headers: ${response.headers}');
//     print('🧪 Test Response Body Length: ${response.body.length}');
    
//     if (response.body.isNotEmpty) {
//       print('🧪 Test Response Preview: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}...');
//     }
    
//     if (response.statusCode == 200) {
//       try {
//         final data = jsonDecode(response.body);
//         print('🧪 Test Success - Data type: ${data.runtimeType}');
//         if (data is List) {
//           print('🧪 Test Success - Items count: ${data.length}');
//           if (data.isNotEmpty) {
//             print('🧪 Test Success - First item keys: ${data[0].keys.toList()}');
//             print('🧪 Test Success - First item: ${data[0]}');
//           }
//         }
//       } catch (e) {
//         print('🧪 Test JSON Error: $e');
//       }
//     } else {
//       print('🧪 Test Failed - Status: ${response.statusCode}');
//       print('🧪 Test Failed - Body: ${response.body}');
//     }

//     // Also test with AuthManager key
//     final prefs = await SharedPreferences.getInstance();
//     String authKey = AuthManager.authKey;
//     if (authKey.isEmpty) {
//       authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//     }
    
//     if (authKey != 'vLQTuPZUxktl5mVW') {
//       print('🧪 Testing with AuthManager key: "$authKey"');
//       response = await http.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       print('🧪 AuthManager Test Status: ${response.statusCode}');
//       print('🧪 AuthManager Test Body Length: ${response.body.length}');
//     }
    
//   } catch (e) {
//     print('🧪 Test Network Error: $e');
//   }
// }

  Future<void> _loadCachedWebseriesDataAndFetch() async {
    setState(() {
      isLoading = true;
      debugMessage = '';
    });

    try {
      // Load cached data
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('webseries_list');
      if (cached != null) {
        final List<dynamic> cachedData = jsonDecode(cached);
        setState(() {
          categories = List<Map<String, dynamic>>.from(cachedData);
          _initializeFocusNodes(); // Add this line
          isLoading = false;
        });
        _registerWebseriesFocus(); // Add this line
      }

      // Background fetch & update if changed
      await _fetchWebseriesInBackground();
    } catch (e) {
      setState(() {
        debugMessage = "Failed to load webseries";
        isLoading = false;
      });
    }
  }

  // Add this method to initialize focus nodes:
  void _initializeFocusNodes() {
    focusNodesMap.clear();
    for (var cat in categories) {
      final catId = '${cat['id']}';
      focusNodesMap[catId] = {};
      final webSeriesList = cat['web_series'] as List<dynamic>;
      for (var series in webSeriesList) {
        final seriesId = '${series['id']}';
        focusNodesMap[catId]![seriesId] = FocusNode()
          ..addListener(() {
            if (focusNodesMap[catId]![seriesId]!.hasFocus) {
              _scrollToFocusedItem(catId, seriesId);
            }
          });
      }
    }
  }

  // Add this method to register focus with provider:
  void _registerWebseriesFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (categories.isNotEmpty && mounted) {
        final firstCid = '${categories[0]['id']}';
        final firstWebSeries = categories[0]['web_series'] as List<dynamic>;
        if (firstWebSeries.isNotEmpty) {
          final firstSid = '${firstWebSeries[0]['id']}';
          final node = focusNodesMap[firstCid]?[firstSid];
          if (node != null) {
            context.read<FocusProvider>().setFirstManageWebseriesFocusNode(node);
            print('🎭 Registered First Webseries FocusNode: $node');
          }
        }
      }
    });
  }

  // // Update the _fetchWebseriesInBackground method with AuthKey:
  // Future<void> _fetchWebseriesInBackground() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     String authKey = AuthManager.authKey;
  //     if (authKey.isEmpty) {
  //       // Fallback to SharedPreferences if AuthManager doesn't have it
  //       authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
  //     }

  //     final response = await http.get(
  //       Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
  //       headers: {'auth-key': authKey}, // Updated header key
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> flatData = jsonDecode(response.body);
  //       final Map<String, List<dynamic>> grouped = {};
  //       for (var item in flatData) {
  //         final tagName = item['custom_tag']?['custom_tags_name'] ?? 'Unknown';
  //         grouped.putIfAbsent(tagName, () => []).add(item);
  //       }
  //       final List<Map<String, dynamic>> newCats = grouped.entries.map((e) => {
  //         'id': e.value.first['custom_tag']?['custom_tags_id'] ?? '0',
  //         'category': e.key,
  //         'web_series': _sortByIndex(e.value),
  //       }).toList();

  //       final newJson = jsonEncode(newCats);
  //       final cached = prefs.getString('webseries_list');

  //       if (cached == null || cached != newJson) {
  //         await prefs.setString('webseries_list', newJson);
  //         setState(() {
  //           categories = newCats;
  //           _initializeFocusNodes(); // Re-initialize focus nodes
  //         });
  //         _registerWebseriesFocus(); // Re-register focus
  //       }
  //     }
  //   } catch (e) {
  //     print('Error in background fetch: $e');
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  // List<dynamic> _sortByIndex(List<dynamic> list) {
  //   list.sort((a, b) =>
  //       (int.tryParse(a['index'] ?? '0') ?? 0)
  //           .compareTo(int.tryParse(b['index'] ?? '0') ?? 0));
  //   return list;
  // }

  // Future<void> _fetchDataWithRetry() async {
  //   try {
  //     await fetchData();
  //   } catch (_) {
  //     Future.delayed(const Duration(seconds: 2), () {
  //       if (mounted) fetchData();
  //     });
  //   }
  // }

  // @override
  // void dispose() {
  //   for (var cat in focusNodesMap.values) {
  //     for (var node in cat.values) node.dispose();
  //   }
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  // Future<void> fetchData() async {
  //   if (!mounted) return;
  //   setState(() {
  //     isLoading = true;
  //     debugMessage = "Loading...";
  //   });

  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     String authKey = AuthManager.authKey;
  //     if (authKey.isEmpty) {
  //       // Fallback to SharedPreferences if AuthManager doesn't have it
  //       authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
  //     }

  //     final response = await http.get(
  //       Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
  //       headers: {'auth-key': authKey}, // Updated header key
  //     ).timeout(const Duration(seconds: 15));

  //     if (!mounted) return;

  //     if (response.statusCode == 200 && response.body.isNotEmpty) {
  //       // 1. Decode flat list
  //       final List<dynamic> flatData = jsonDecode(response.body);

  //       // 2. Group by custom_tag.custom_tags_name
  //       final Map<String, List<dynamic>> grouped = {};
  //       for (var item in flatData) {
  //         final tagName = item['custom_tag']?['custom_tags_name'] ?? 'Unknown';
  //         grouped.putIfAbsent(tagName, () => []).add(item);
  //       }

  //       // 3. Shape into [{ id, category, web_series: […] }, …]
  //       final List<Map<String, dynamic>> nonEmptyCategories = grouped.entries
  //           .map((e) => {
  //                 'id': e.value.first['custom_tag']?['custom_tags_id'] ?? '0',
  //                 'category': e.key,
  //                 'web_series': e.value,
  //               })
  //           .toList();

  //       // 4. Update provider & build focus nodes
  //       Provider.of<FocusProvider>(context, listen: false)
  //           .updateCategoryCountWebseries(nonEmptyCategories.length);

  //       final Map<String, Map<String, FocusNode>> newFocusMap = {};
  //       for (var cat in nonEmptyCategories) {
  //         final cid = '${cat['id']}';
  //         newFocusMap[cid] = {
  //           for (var series in cat['web_series']) '${series['id']}': FocusNode()
  //         };
  //       }

  //       // 5. Set state
  //       setState(() {
  //         categories = nonEmptyCategories;
  //         focusNodesMap = newFocusMap;
  //         isLoading = false;
  //         debugMessage = "Loaded ${nonEmptyCategories.length} categories";
  //       });

  //       // 6. Give first item initial focus
  //       Future.delayed(const Duration(milliseconds: 300), () {
  //         if (mounted && categories.isNotEmpty) {
  //           final firstCid = '${categories[0]['id']}';
  //           final firstSid =
  //               '${(categories[0]['web_series'] as List).first['id']}';
  //           final node = focusNodesMap[firstCid]?[firstSid];
  //           if (node != null) {
  //             Provider.of<FocusProvider>(context, listen: false)
  //                 .setFirstManageWebseriesFocusNode(node);
  //           }
  //         }
  //       });
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //         debugMessage = "Error: ${response.statusCode}";
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Something went wrong')),
  //       );
  //     }
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //       debugMessage = "Error: $e";
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //   }
  // }

  void navigateToDetails(
      dynamic movie, String source, String banner, String name, int idx) {
    final List<NewsItemModel> channelList =
        (categories[idx]['web_series'] as List<dynamic>)
            .map((m) => NewsItemModel(
                  id: m['id']?.toString() ?? '', // Safe string conversion
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
                ))
            .toList();

    // Safe ID conversion for navigation
    int movieId;
    if (movie['id'] is int) {
      movieId = movie['id'];
    } else if (movie['id'] is String) {
      try {
        movieId = int.parse(movie['id']);
      } catch (e) {
        print('Error parsing movie ID: ${movie['id']}');
        return; // Don't navigate if ID is invalid
      }
    } else {
      print('Invalid movie ID type: ${movie['id'].runtimeType}');
      return; // Invalid ID, don't navigate
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebSeriesDetailsPage(
          id: movieId,
          channelList: channelList,
          source: 'manage-web_series',
          banner: banner,
          name: name,
        ),
      ),
    );
  }

  void _scrollToFocusedItem(String catId, String seriesId) {
    final node = focusNodesMap[catId]?[seriesId];
    if (node?.hasFocus != true || !_scrollController.hasClients) return;
    final ctx = node!.context;
    if (ctx != null && mounted) {
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.05,
        duration: const Duration(milliseconds: 400),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin
    debugCategoriesState();
    return Consumer<ColorProvider>(
      builder: (context, colorProv, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (categories.isNotEmpty) {
            final firstCid = '${categories[0]['id']}';
            final firstSid = '${categories[0]['web_series'].first['id']}';
            final node = focusNodesMap[firstCid]?[firstSid];
            if (node != null) {
              Provider.of<FocusProvider>(context, listen: false)
                  .setFirstManageWebseriesFocusNode(node);
            }
          }
        });

        final bgColor = colorProv.isItemFocused
            ? colorProv.dominantColor.withOpacity(0.3)
            : Colors.black;

        if (isLoading) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                loading_indicator.LoadingIndicator(),
                const SizedBox(height: 12),
                Text(debugMessage, style: const TextStyle(color: Colors.white)),
              ],
            ),
          );
        }

        if (categories.isEmpty) {
          return const Center(
            child: Text('No Content', style: TextStyle(color: Colors.white)),
          );
        }

        return Container(
          color: bgColor,
          child: Container(
            color: Colors.black54,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: List.generate(categories.length, (catIdx) {
                  final cat = categories[catIdx];
                  final list = cat['web_series'] as List<dynamic>;
                  final catId = '${cat['id']}';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          cat['category'].toString().toUpperCase(),
                          style: TextStyle(
                            color: hintColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.34,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: list.length > 7 ? 8 : list.length + 1,
                          itemBuilder: (_, idx) {
                            if ((list.length >= 7 && idx == 7) ||
                                (list.length < 7 && idx == list.length)) {
                              return ViewAllWidget(
                                categoryText: cat['category'],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CategoryMoviesGridView(
                                        category: cat,
                                        web_series: list,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }

                            final item = list[idx];
                            final sid = '${item['id']}';
                            final node = focusNodesMap[catId]?[sid];

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: FocussableWebseriesWidget(
                                imageUrl: item['poster']?.toString() ?? '',
                                name: item['name']?.toString() ?? '',
                                focusNode: node ?? FocusNode(),
                                onFocusChange: (hasFocus) {
                                  if (hasFocus)
                                    _scrollToFocusedItem(catId, sid);
                                },
                                onUpPress: () {
                                  // Request focus for ManageMovies first item
                                  context
                                      .read<FocusProvider>()
                                      .requestManageMoviesFocus();
                                },
                                onTap: () => navigateToDetails(
                                  item,
                                  cat['category'],
                                  item['banner']?.toString() ?? '',
                                  item['name']?.toString() ?? '',
                                  catIdx,
                                ),
                                fetchPaletteColor: (url) =>
                                    PaletteColorService()
                                        .getSecondaryColor(url),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------
// View All button at end of row
// ----------------------------------------------
class ViewAllWidget extends StatefulWidget {
  final VoidCallback onTap;
  final String categoryText;
  const ViewAllWidget({
    Key? key,
    required this.onTap,
    required this.categoryText,
  }) : super(key: key);

  @override
  _ViewAllWidgetState createState() => _ViewAllWidgetState();
}

class _ViewAllWidgetState extends State<ViewAllWidget> {
  bool isFocused = false;
  Color focusColor = highlightColor;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double normalHeight = screenhgt * 0.21;
    final double focusedHeight = screenhgt * 0.24;
    final double heightGrowth = focusedHeight - normalHeight;
    final double verticalOffset = isFocused ? -(heightGrowth / 2) : 0;

    return Focus(
      focusNode: _focusNode,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.select) {
            widget.onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () {
          widget.onTap();
          _focusNode.requestFocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using Stack for true bidirectional expansion
            Container(
              width: screenwdt * 0.19,
              height:
                  normalHeight, // Fixed container height is the normal height
              child: Stack(
                clipBehavior: Clip.none, // Allow items to overflow the stack
                alignment: Alignment.center,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    top: isFocused
                        ? -(heightGrowth / 2)
                        : 0, // Move up when focused
                    left: 0,
                    width: screenwdt * 0.19,
                    height: isFocused ? focusedHeight : normalHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        border: isFocused
                            ? Border.all(
                                color: focusColor,
                                width: 4.0,
                              )
                            : Border.all(
                                color: Colors.transparent,
                                width: 4.0,
                              ),
                        color: Colors.grey[800],
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: focusColor,
                                  blurRadius: 25,
                                  spreadRadius: 10,
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'View All',
                              style: TextStyle(
                                color: isFocused ? focusColor : hintColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              widget.categoryText,
                              style: TextStyle(
                                color: isFocused ? focusColor : hintColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                overflow: TextOverflow.ellipsis,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'web_series',
                              style: TextStyle(
                                color: isFocused ? focusColor : hintColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: screenwdt * 0.17,
              child: Column(
                children: [
                  Text(
                    (widget.categoryText),
                    style: TextStyle(
                      color: isFocused ? focusColor : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------
// Full–screen grid when "View All" is tapped
// ----------------------------------------------
class CategoryMoviesGridView extends StatefulWidget {
  final Map<String, dynamic> category;
  final List<dynamic> web_series;
  const CategoryMoviesGridView({
    Key? key,
    required this.category,
    required this.web_series,
  }) : super(key: key);

  @override
  _CategoryMoviesGridViewState createState() => _CategoryMoviesGridViewState();
}

class _CategoryMoviesGridViewState extends State<CategoryMoviesGridView> {
  bool _isLoading = false;
  late Map<String, FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _nodes = {for (var m in widget.web_series) '${m['id']}': FocusNode()};
  }

  @override
  void dispose() {
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

  void navigateToDetails(dynamic movie) {
    final channelList = widget.web_series.map((m) {
      return NewsItemModel(
        id: m['id']?.toString() ?? '', // Safe string conversion
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
      );
    }).toList();

    // Safe ID conversion for navigation
    int movieId;
    if (movie['id'] is int) {
      movieId = movie['id'];
    } else if (movie['id'] is String) {
      try {
        movieId = int.parse(movie['id']);
      } catch (e) {
        print('Error parsing movie ID: ${movie['id']}');
        return; // Don't navigate if ID is invalid
      }
    } else {
      print('Invalid movie ID type: ${movie['id'].runtimeType}');
      return; // Invalid ID, don't navigate
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebSeriesDetailsPage(
          id: movieId,
          channelList: channelList,
          source: 'manage_web_series',
          banner: movie['banner']?.toString() ?? '',
          name: movie['name']?.toString() ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: widget.web_series.length,
              itemBuilder: (_, idx) {
                final m = widget.web_series[idx];
                final id = '${m['id']}';
                return FocussableWebseriesWidget(
                  imageUrl: m['poster']?.toString() ?? '',
                  name: m['name']?.toString() ?? '',
                  focusNode: _nodes[id]!,
                  onTap: () {
                    setState(() => _isLoading = true);
                    navigateToDetails(m);
                    setState(() => _isLoading = false);
                  },
                  fetchPaletteColor: (url) =>
                      PaletteColorService().getSecondaryColor(url),
                );
              },
            ),
            if (_isLoading) Center(child: loading_indicator.LoadingIndicator()),
          ],
        ),
      ),
    );
  }
}