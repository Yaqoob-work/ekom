




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





  // 1. अपनी existing _initializeFocusNodes method को replace करें:
void _initializeFocusNodes() {
  focusNodesMap.clear();
  for (var cat in categories) {
    final catId = '${cat['id']}';
    focusNodesMap[catId] = {};
    final webSeriesList = cat['web_series'] as List<dynamic>;
    
    for (int idx = 0; idx < webSeriesList.length; idx++) {
      final series = webSeriesList[idx];
      final seriesId = '${series['id']}';
      
      // Create focus node with debug label
      final focusNode = FocusNode(debugLabel: 'webseries_${catId}_${seriesId}_$idx');
      
      // ✅ IMPORTANT: Focus listener में scroll logic
      focusNode.addListener(() {
        if (focusNode.hasFocus && mounted && _scrollController.hasClients) {
          
          // Direct scroll call - यह guaranteed काम करेगा
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _performReliableScroll(itemIndex: idx);
          });
        }
      });
      
      focusNodesMap[catId]![seriesId] = focusNode;
    }
  }
}

// 2. Simple और Reliable Scroll Method:
void _performReliableScroll({required int itemIndex}) {
  if (!mounted || !_scrollController.hasClients) return;
  
  try {
    // Calculate exact position based on your UI measurements
    final double itemWidth = MediaQuery.of(context).size.width * 0.19; // Your item width ratio
    final double horizontalPadding = 6.0; // Your horizontal padding per item  
    final double totalItemWidth = itemWidth + (horizontalPadding * 2);
    
    // Calculate target scroll position
    final double targetOffset = itemIndex * totalItemWidth;
    final double maxOffset = _scrollController.position.maxScrollExtent;
    final double clampedOffset = targetOffset.clamp(0.0, maxOffset);
    
    
    // Perform scroll animation
    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ).then((_) {
    }).catchError((error) {
    });
    
  } catch (e) {
  }
}


// 4. Build method में scroll controller का proper setup:
@override
Widget build(BuildContext context) {
  super.build(context);
  
  // Debug scroll state
  if (_scrollController.hasClients) {
  } else {
  }
  
  return Consumer<ColorProvider>(
    builder: (context, colorProv, child) {
      // ... existing code ...

              final bgColor = colorProv.isItemFocused
            ? colorProv.dominantColor.withOpacity(0.3)
            : Colors.black;
      
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
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        cat['category'].toString().toUpperCase(),
                        style: TextStyle(
                          color: hintColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    
                    // ✅ Enhanced ListView with better key and controller
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.34,
                      child: ListView.builder(
                        key: ValueKey('webseries_listview_$catId'), // Unique key
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        
                        // ✅ IMPORTANT: Ensure physics allow scrolling
                        clipBehavior: Clip.none,
                        
                        itemCount: list.length > 7 ? 8 : list.length + 1,
                        itemBuilder: (context, idx) {
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
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: FocussableWebseriesWidget(
                              // key: ValueKey('webseries_${item['id']}_$idx'),
                              key: ValueKey('webseries_${item['id']}_$idx'),
                              imageUrl: item['poster']?.toString() ?? '',
                              name: item['name']?.toString() ?? '',
                              focusNode: node ?? FocusNode(),
                              
                              onFocusChange: (hasFocus) {
                                if (hasFocus) {
                                  _performReliableScroll(itemIndex: idx);
                                  
                                  // Backup scroll
                                  Future.delayed(Duration(milliseconds: 200), () {
                                    if (mounted) _performReliableScroll(itemIndex: idx);
                                  });
                                }
                              },
                              
                              onUpPress: () {
                                context.read<FocusProvider>().requestFirstMoviesFocus();
                              },
                              
                              onTap: () => navigateToDetails(
                                item,
                                cat['category'],
                                item['banner']?.toString() ?? '',
                                item['name']?.toString() ?? '',
                                catIdx,
                              ),
                              
                              fetchPaletteColor: (url) =>
                                  PaletteColorService().getSecondaryColor(url),
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

// 5. ScrollController के साथ debug helper:
void debugScrollController() {
  
  if (_scrollController.hasClients) {
    final position = _scrollController.position;
  }
  
}




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
    
    return list;
  } catch (e) {
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


    final response = await http.get(
      Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
      headers: {
        'auth-key': authKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return;
      }

      try {
        final List<dynamic> flatData = jsonDecode(response.body);
        
        if (flatData.isEmpty) {
          setState(() {
            categories = [];
            isLoading = false;
          });
          return;
        }

        // Log first item structure
        if (flatData.isNotEmpty) {
        }
        
        // ✅ Fix: Simple grouping without custom_tag dependency
        final Map<String, List<dynamic>> grouped = {};
        
        // Group all items into "Web Series" category
        if (flatData.isNotEmpty) {
          grouped['Web Series'] = flatData;
        }
        
        
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
          } catch (e) {
            // Add category without sorting if sorting fails
            newCats.add({
              'id': '1',
              'category': entry.key,
              'web_series': entry.value,
            });
          }
        }


        // ✅ Fix: Safe JSON encoding with error handling
        try {
          final newJson = jsonEncode(newCats);
          final cached = prefs.getString('webseries_list');

          if (cached == null || cached != newJson) {
            await prefs.setString('webseries_list', newJson);
            
            setState(() {
              categories = newCats;
              _initializeFocusNodes();
            });
            _registerWebseriesFocus();
          } else {
            // Even if cache unchanged, ensure UI is updated
            setState(() {
              categories = newCats;
              _initializeFocusNodes();
            });
            _registerWebseriesFocus();
          }
        } catch (e) {
          // Still update UI even if caching fails
          setState(() {
            categories = newCats;
            _initializeFocusNodes();
          });
          _registerWebseriesFocus();
        }
        
      } catch (e) {
      }
    } else {
    }
  } catch (e) {
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


    final response = await http.get(
      Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
      headers: {
        'auth-key': authKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (!mounted) return;

    
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final List<dynamic> flatData = jsonDecode(response.body);

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
      setState(() {
        isLoading = false;
        debugMessage = "Error: ${response.statusCode}";
      });
      
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('API Error: ${response.statusCode}')),
      // );
    }
  } catch (e) {
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
  
  if (categories.isNotEmpty) {
    // for (int i = 0; i < categories.length; i++) {
    //   final cat = categories[i];
    // }
  }
}



// void _scrollToFocusedItem(String catId, String seriesId) {
//   final node = focusNodesMap[catId]?[seriesId];
//   if (node?.hasFocus != true || !_scrollController.hasClients) return;
  
//   final ctx = node!.context;
//   if (ctx != null && mounted) {
//     // Get the RenderBox of the focused item
//     final RenderBox? renderBox = ctx.findRenderObject() as RenderBox?;
//     if (renderBox != null) {
//       // Get item's position relative to the viewport
//       final position = renderBox.localToGlobal(Offset.zero);
//       final itemWidth = renderBox.size.width;
//       final screenWidth = MediaQuery.of(context).size.width;
      
//       // Calculate center position
//       final targetScrollOffset = _scrollController.offset + 
//           position.dx - (screenWidth / 2) + (itemWidth / 2);
      
//       // Animate to center the focused item
//       _scrollController.animateTo(
//         targetScrollOffset.clamp(
//           _scrollController.position.minScrollExtent,
//           _scrollController.position.maxScrollExtent,
//         ),
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
// }



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
//             // Add a small delay to ensure widget is built
//             Future.delayed(Duration(milliseconds: 150), () {
//               // You need to provide the itemIndex as the third argument
//               final webSeriesList = cat['web_series'] as List<dynamic>;
//               final itemIndex = webSeriesList.indexWhere((s) => '${s['id']}' == seriesId);
//               _performGuaranteedScroll(catId, seriesId, );
//             });
//           }
//         });
//     }
//   }
// }



// 2. Guaranteed Scroll Method with multiple fallbacks
void _performGuaranteedScroll(String catId, String seriesId) {
  // Immediate scroll attempt
  _scrollToFocusedItem(catId, seriesId);
  
  // Backup scroll attempts with delays
  Future.delayed(Duration(milliseconds: 100), () {
    _scrollToFocusedItem(catId, seriesId);
  });
  
  Future.delayed(Duration(milliseconds: 300), () {
    _scrollToFocusedItem(catId, seriesId);
  });
  
  // Final fallback scroll
  Future.delayed(Duration(milliseconds: 500), () {
    _scrollToFocusedItem(catId, seriesId);
  });
}

// 3. Enhanced scroll method with better error handling
void _scrollToFocusedItem(String catId, String seriesId) {
  try {
    final node = focusNodesMap[catId]?[seriesId];
    
    // Check if node has focus और scroll controller available है
    if (node?.hasFocus != true) {
      return;
    }
    
    if (!_scrollController.hasClients) {
      return;
    }
    
    final ctx = node!.context;
    if (ctx == null) {
      return;
    }
    
    // Check if widget is still mounted
    if (!mounted) {
      return;
    }
    
    // Get RenderBox for position calculation
    final RenderBox? renderBox = ctx.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      // Fallback to Scrollable.ensureVisible
      _fallbackScroll(ctx);
      return;
    }
    
    // Calculate precise scroll position
    final position = renderBox.localToGlobal(Offset.zero);
    final itemWidth = renderBox.size.width;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate target scroll offset to center the item
    final currentOffset = _scrollController.offset;
    final targetOffset = currentOffset + position.dx - (screenWidth * 0.2); // 20% from left
    
    // Ensure offset is within bounds
    final minOffset = _scrollController.position.minScrollExtent;
    final maxOffset = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(minOffset, maxOffset);
    
    
    // Animate to target position
    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ).catchError((error) {
      // Try fallback scroll on error
      _fallbackScroll(ctx);
    });
    
  } catch (e) {
    // Try fallback scroll method
    final node = focusNodesMap[catId]?[seriesId];
    if (node?.context != null) {
      _fallbackScroll(node!.context!);
    }
  }
}

// 4. Fallback scroll method using Scrollable.ensureVisible
void _fallbackScroll(BuildContext context) {
  try {
    Scrollable.ensureVisible(
      context,
      alignment: 0.2, // 20% from left
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  } catch (e) {
  }
}







// 5. Alternative scroll method using item index (if you have item positions)
void _scrollByIndex(String catId, String seriesId, int itemIndex) {
  if (!_scrollController.hasClients) return;
  
  try {
    // Calculate approximate position based on item width
    final itemWidth = MediaQuery.of(context).size.width * 0.19; // Your item width
    final itemSpacing = 12.0; // Your padding
    final totalItemWidth = itemWidth + itemSpacing;
    
    final targetOffset = itemIndex * totalItemWidth;
    final maxOffset = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxOffset);
    
    
    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  } catch (e) {
  }
}



// void _scrollToFocusedItem(String catId, String seriesId) {
//   final node = focusNodesMap[catId]?[seriesId];
//   if (node?.hasFocus != true || !_scrollController.hasClients) return;
  
//   final ctx = node!.context;
//   if (ctx != null && mounted) {
//     // Get the RenderBox of the focused item
//     final RenderBox? renderBox = ctx.findRenderObject() as RenderBox?;
//     if (renderBox != null) {
//       // Calculate the position of the item relative to the viewport
//       final position = renderBox.localToGlobal(Offset.zero);
//       final itemWidth = renderBox.size.width;
      
//       // Calculate the scroll offset needed to bring the item to the left
//       final targetOffset = _scrollController.offset + position.dx - 20; // 20 is padding
      
//       // Ensure the offset stays within valid bounds
//       final clampedOffset = targetOffset.clamp(
//         _scrollController.position.minScrollExtent,
//         _scrollController.position.maxScrollExtent,
//       );
      
//       // Animate to the calculated position
//       _scrollController.animateTo(
//         clampedOffset,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
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
    

    
    grouped.putIfAbsent(categoryName, () => []).add(item);
  }
  
  return grouped;
}






@override
void initState() {
  super.initState();
  
  
  // Check SharedPreferences
  SharedPreferences.getInstance().then((prefs) {
    final storedKey = prefs.getString('auth_key');
    final cachedData = prefs.getString('webseries_list');
  });
  
  // Manual API test
  // testWebseriesAPI();
  
  // Regular initialization
  _loadCachedWebseriesDataAndFetch();


   WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted && categories.isNotEmpty) {
      final firstCid = '${categories[0]['id']}';
      final firstSid = '${categories[0]['web_series'].first['id']}';
      final node = focusNodesMap[firstCid]?[firstSid];
      if (node != null) {
        Provider.of<FocusProvider>(context, listen: false)
            .setFirstManageWebseriesFocusNode(node);
      }
      
    }
  });
}


// // Update your FocusNode listener initialization to use the new method:
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
//             // Use any of the above methods:
//             _scrollToFocusedItem(catId, seriesId); // Simplest
//             // OR
//             // _scrollToFocusedItemEnhanced(catId, seriesId); // More control
//             // OR  
//             // _smartScrollToFocusedItem(catId, seriesId, centerAlign: true); // Flexible
//           }
//         });
//     }
//   }
// }


// // Update your FocusNode listener initialization to use the new method:
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
//             // Use any of the above methods:
//             // _scrollToFocusedItemAlternative(catId, seriesId); // Simplest
//             _scrollToFocusedItem(catId, seriesId); // Simplest
//             // OR
//             // _scrollToFocusedItemEnhanced(catId, seriesId); // More control
//             // OR  
//             // _smartScrollToFocusedItem(catId, seriesId, centerAlign: true); // Flexible
//           }
//         });
//     }
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
          }
        }
      }
    });
  }



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
                  unUpdatedUrl: '',
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
        return; // Don't navigate if ID is invalid
      }
    } else {
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




  

  // void _scrollToFocusedItem(String catId, String seriesId) {
  //   final node = focusNodesMap[catId]?[seriesId];
  //   if (node?.hasFocus != true || !_scrollController.hasClients) return;
  //   final ctx = node!.context;
  //   if (ctx != null && mounted) {
  //     Scrollable.ensureVisible(
  //       ctx,
  //       alignment: 0.05,
  //       duration: const Duration(milliseconds: 800),
  //     );
  //   }
  // }




//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // for AutomaticKeepAliveClientMixin
//     debugCategoriesState();
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
//                                   const EdgeInsets.symmetric(horizontal: 0),
//                                    key: ValueKey('webseries_${item['id']}'),
//                               child: FocussableWebseriesWidget(
//                                 imageUrl: item['poster']?.toString() ?? '',
//                                 name: item['name']?.toString() ?? '',
//                                 focusNode: node ?? FocusNode(),
//                                 onFocusChange: (hasFocus) {
//                                   if (hasFocus)
//                                     _scrollToFocusedItem(catId, sid);
//                                 },
//                                 onUpPress: () {
//                                   // Request focus for ManageMovies first item
//                                   context
//                                       .read<FocusProvider>()
//                                       .requestFirstMoviesFocus();
//                                 },
//                                 onTap: () => navigateToDetails(
//                                   item,
//                                   cat['category'],
//                                   item['banner']?.toString() ?? '',
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
                    duration: const Duration(milliseconds: 800),
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
        unUpdatedUrl: '',
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
        return; // Don't navigate if ID is invalid
      }
    } else {
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
                  key: ValueKey('webseries_${m['id']}_$idx'),
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