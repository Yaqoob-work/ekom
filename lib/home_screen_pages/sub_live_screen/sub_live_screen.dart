// import 'package:mobi_tv_entertainment/home_screen_pages/sub_live_screen/channels_category.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/sub_live_screen/live_all.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/menu/middle_navigation_bar.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SubLiveScreen extends StatefulWidget {
//   const SubLiveScreen({super.key});
//   @override
//   State<SubLiveScreen> createState() => _SubLiveScreenState();
// }

// class _SubLiveScreenState extends State<SubLiveScreen> {
//   int _selectedPage = 0;
//   late PageController _pageController;

//   // ✅ Focus nodes for all pages
//   final FocusNode _liveChannelsFocusNode = FocusNode();
//   final FocusNode _entertainmentChannelsFocusNode = FocusNode();
//   final FocusNode _musicChannelsFocusNode = FocusNode();
//   final FocusNode _movieChannelsFocusNode = FocusNode();
//   final FocusNode _newsChannelsFocusNode = FocusNode();
//   final FocusNode _sportsChannelsFocusNode = FocusNode();
//   final FocusNode _religiousChannelsFocusNode = FocusNode();

//   // ✅ Navigation items - SINGLE SOURCE
//   static const List<String> navItems = [
//     'Live', // Index 0
//     'Entertainment', // Index 1
//     'Music', // Index 2
//     'Movie', // Index 3
//     'News', // Index 4
//     'Sports', // Index 5
//     'Religious', // Index 6
//     'More' // Index 7 - Special case, navigates to separate page
//   ];

//   // ✅ Pages using GenericLiveChannels for most pages
//   late List<Widget> pages;

//   @override
//   void initState() {
//     super.initState();

//     // ✅ Initialize pages with GenericLiveChannels
//     pages = [
//       // LiveChannelPage(focusNode: _liveChannelsFocusNode),           // 0 - Live (special case)
//       GenericLiveChannels(
//         // 0 - Live ✅ (Fixed)
//         focusNode: _liveChannelsFocusNode,
//         apiCategory: 'All',
//         displayTitle: 'LIVE',
//         navigationIndex: 0, // ✅ Correct index
//       ),

//       GenericLiveChannels(
//         // 1 - Entertainment ✅
//         focusNode: _entertainmentChannelsFocusNode,
//         apiCategory: 'Entertainment',
//         displayTitle: 'ENTERTAINMENT',
//         navigationIndex: 1,
//       ),

//       GenericLiveChannels(
//         // 2 - Music ✅
//         focusNode: _musicChannelsFocusNode,
//         apiCategory: 'Music',
//         displayTitle: 'MUSIC',
//         navigationIndex: 2,
//       ),

//       GenericLiveChannels(
//         // 3 - Movie ✅
//         focusNode: _movieChannelsFocusNode,
//         apiCategory: 'Movies',
//         displayTitle: 'MOVIES',
//         navigationIndex: 3,
//       ),

//       GenericLiveChannels(
//         // 4 - News ✅
//         focusNode: _newsChannelsFocusNode,
//         apiCategory: 'News',
//         displayTitle: 'NEWS',
//         navigationIndex: 4,
//       ),

//       GenericLiveChannels(
//         // 5 - Sports ✅
//         focusNode: _sportsChannelsFocusNode,
//         apiCategory: 'Sports',
//         displayTitle: 'SPORTS',
//         navigationIndex: 5,
//       ),

//       GenericLiveChannels(
//         // 6 - Religious ✅
//         focusNode: _religiousChannelsFocusNode,
//         apiCategory: 'Religios',
//         displayTitle: 'RELIGIOUS',
//         navigationIndex: 6,
//       ),
//       // Note: More (Index 7) is NOT in PageView - it navigates to separate screen
//     ];

//     _pageController = PageController(initialPage: 0);

//     print('🎯 Navigation items: ${navItems.length}');
//     print('🎯 Pages for PageView: ${pages.length}');
//     print('🎯 Valid page range: 0-${pages.length - 1}');

//     // ✅ Register all focus nodes with FocusProvider
//     // ✅ Register focus nodes AFTER pages are created
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       try {
//         final focusProvider =
//             Provider.of<FocusProvider>(context, listen: false);

//         // ✅ Register Live channels focus node FIRST
//         // focusProvider.setLiveChannelsFocusNode(_liveChannelsFocusNode);

//         // ✅ Register all generic channel focus nodes with correct indices
//         focusProvider.registerGenericChannelFocus(
//             0, ScrollController(), _liveChannelsFocusNode);
//         focusProvider.registerGenericChannelFocus(
//             1, ScrollController(), _entertainmentChannelsFocusNode);
//         focusProvider.registerGenericChannelFocus(
//             2, ScrollController(), _musicChannelsFocusNode);
//         focusProvider.registerGenericChannelFocus(
//             3, ScrollController(), _movieChannelsFocusNode);
//         focusProvider.registerGenericChannelFocus(
//             4, ScrollController(), _newsChannelsFocusNode);
//         focusProvider.registerGenericChannelFocus(
//             5, ScrollController(), _sportsChannelsFocusNode);
//         focusProvider.registerGenericChannelFocus(
//             6, ScrollController(), _religiousChannelsFocusNode);

//         // ✅ Legacy compatibility
//         focusProvider.setFirstMusicChannelFocusNode(_musicChannelsFocusNode);
//         focusProvider.setFirstNewsChannelFocusNode(_newsChannelsFocusNode);

//         print('✅ All focus nodes registered with Live fixed');
//       } catch (e) {
//         print('❌ Focus registration failed: $e');
//       }
//     });
//   }

//   // ✅ GENERIC: Page selection handling for all pages
//   // void _onPageSelected(int index) {
//   //   print('🎯 Selected: Index $index = ${index < navItems.length ? navItems[index] : "Out of range"}');

//   //   // ✅ Handle More button specially
//   //   if (index == 7) { // More button (last item)
//   //     print('📁 Navigating to More page');
//   //     _navigateToMorePage();
//   //     return;
//   //   }

//   //   // ✅ Validate index is within page range
//   //   if (index < 0 || index >= pages.length) {
//   //     print('❌ Invalid page index: $index (Valid range: 0-${pages.length - 1})');
//   //     return;
//   //   }

//   //   // ✅ Navigate to page
//   //   setState(() {
//   //     _selectedPage = index;
//   //   });

//   //   _pageController.jumpToPage(index);

//   //   // ✅ GENERIC: Handle focus for all pages with proper delay
//   //   Future.delayed(Duration(milliseconds: 150), () {
//   //     if (mounted) {
//   //       try {
//   //         final focusProvider = Provider.of<FocusProvider>(context, listen: false);

//   //         switch (index) {
//   //           case 0: // Live - special case
//   //             print('🔴 Focusing Live channels');
//   //             _liveChannelsFocusNode.requestFocus();
//   //             focusProvider.requestLiveChannelsFocus();
//   //             break;

//   //           default: // All other pages use generic method ✅
//   //             print('🎯 Focusing ${navItems[index]} channels (index: $index)');
//   //             focusProvider.requestFirstChannelFocus(index);
//   //         }
//   //       } catch (e) {
//   //         print('❌ Focus request failed for index $index: $e');
//   //       }
//   //     }
//   //   });
//   // }

//   // SubLiveScreen में _onPageSelected method को update करें:

//   void _onPageSelected(int index) {
//     print(
//         '🎯 Selected: Index $index = ${index < navItems.length ? navItems[index] : "Out of range"}');

//     // ✅ Handle More button specially
//     if (index == 7) {
//       // More button (last item)
//       print('📁 Navigating to More page');
//       _navigateToMorePage();
//       return;
//     }

//     // ✅ Validate index is within page range
//     if (index < 0 || index >= pages.length) {
//       print(
//           '❌ Invalid page index: $index (Valid range: 0-${pages.length - 1})');
//       return;
//     }

//     // ✅ Navigate to page
//     setState(() {
//       _selectedPage = index;
//     });

//         // ✅ NEW: Update FocusProvider with current selected index
//     try {
//       context.read<FocusProvider>().setCurrentSelectedNavIndex(index);
//     } catch (e) {
//       print('❌ Error setting nav index from SubLiveScreen: $e');
//     }

//     _pageController.jumpToPage(index);

//     // ✅ FIXED: Handle focus for ALL pages including Live (index 0)
//     Future.delayed(Duration(milliseconds: 150), () {
//       if (mounted) {
//         try {
//           final focusProvider =
//               Provider.of<FocusProvider>(context, listen: false);

//           // ✅ UNIFIED: Use generic method for ALL pages including Live
//           print('🎯 Focusing ${navItems[index]} channels (index: $index)');
//           focusProvider.requestFirstChannelFocus(index);
//         } catch (e) {
//           print('❌ Focus request failed for index $index: $e');
//         }
//       }
//     });
//   }

// // ✅ FIXED: Handle page focus (used by both navigation and swipe)
//   void _handlePageFocus(int index) {
//     Future.delayed(Duration(milliseconds: 100), () {
//       if (mounted) {
//         try {
//           final focusProvider =
//               Provider.of<FocusProvider>(context, listen: false);

//           // ✅ UNIFIED: Use generic method for ALL pages including Live
//           print(
//               '🎯 Auto-focusing ${navItems[index]} channels on swipe (index: $index)');
//           focusProvider.requestFirstChannelFocus(index);
//         } catch (e) {
//           print('❌ Auto-focus failed for page $index: $e');
//         }
//       }
//     });
//   }

//   void _navigateToMorePage() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => ChannelsCategory()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('🏗️ Building SubLiveScreen');
//     print(
//         '🎯 Selected: $_selectedPage (${_selectedPage < navItems.length ? navItems[_selectedPage] : "Invalid"})');
//     print('🎯 Page exists: ${_selectedPage < pages.length}');

//     return SafeArea(
//       child: Scaffold(
//         body: Container(
//           color: Colors.black,
//           child: Stack(
//             children: [
//               Container(
//                 width: screenwdt,
//                 height: screenhgt,
//                 color: cardColor,
//                 child: Column(
//                   children: [
//                     Container(
//                       child: Stack(
//                         children: [
//                           MiddleNavigationBar(
//                             selectedPage: _selectedPage,
//                             onPageSelected: _onPageSelected,
//                             focusNode: FocusNode(),
//                             maxPageIndex:
//                                 pages.length - 1, // ✅ Pass valid range
//                             totalNavItems:
//                                 navItems.length, // ✅ Pass total nav items
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: PageView(
//                         controller: _pageController,
//                         onPageChanged: (index) {
//                           print('📖 PageView changed to: $index');
//                           // ✅ Validate before setting state
//                           if (index >= 0 &&
//                               index < pages.length &&
//                               index < navItems.length) {
//                             setState(() {
//                               _selectedPage = index;
//                             });
//                             print(
//                                 '✅ Page changed to: $index = ${navItems[index]}');

//                             // ✅ GENERIC: Handle focus on page swipe too
//                             _handlePageFocus(index);
//                           } else {
//                             print('❌ Invalid page change: $index');
//                           }
//                         },
//                         children: pages, // ✅ Use dynamic pages list
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // // ✅ GENERIC: Handle page focus (used by both navigation and swipe)
//   // void _handlePageFocus(int index) {
//   //   Future.delayed(Duration(milliseconds: 100), () {
//   //     if (mounted) {
//   //       try {
//   //         final focusProvider = Provider.of<FocusProvider>(context, listen: false);

//   //         switch (index) {
//   //           case 0: // Live - special case
//   //             print('🔴 Auto-focusing Live channels on swipe');
//   //             focusProvider.requestLiveChannelsFocus();
//   //             break;

//   //           default: // All other pages use generic method ✅
//   //             print('🎯 Auto-focusing ${navItems[index]} channels on swipe (index: $index)');
//   //             focusProvider.requestFirstChannelFocus(index);
//   //         }
//   //       } catch (e) {
//   //         print('❌ Auto-focus failed for page $index: $e');
//   //       }
//   //     }
//   //   });
//   // }

//   @override
//   void dispose() {
//     _liveChannelsFocusNode.dispose();
//     _entertainmentChannelsFocusNode.dispose();
//     _musicChannelsFocusNode.dispose();
//     _movieChannelsFocusNode.dispose();
//     _newsChannelsFocusNode.dispose();
//     _sportsChannelsFocusNode.dispose();
//     _religiousChannelsFocusNode.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }
// }







// Zaroori imports add karein
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobi_tv_entertainment/home_screen_pages/sub_live_screen/channels_category.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/sub_live_screen/live_all.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/menu/middle_navigation_bar.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubLiveScreen extends StatefulWidget {
  const SubLiveScreen({super.key});
  @override
  State<SubLiveScreen> createState() => _SubLiveScreenState();
}

class _SubLiveScreenState extends State<SubLiveScreen> {
  int _selectedPage = 0;
  late PageController _pageController;

  // ✅ NEW: State variables for dynamic content
  List<String> _navItems = [];
  List<Widget> _pages = [];
  List<FocusNode> _focusNodes = [];
  bool _isLoading = true;

  // ❌ REMOVED: Hardcoded focus nodes and navItems list
  // final FocusNode _liveChannelsFocusNode = FocusNode(); ...etc
  // static const List<String> navItems = [ ... ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    // ✅ NEW: Fetch data and set up the screen
    _fetchAndSetupPages();
  }

  // ✅ NEW: Function to fetch genres and build pages, focus nodes, etc.
  Future<void> _fetchAndSetupPages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String authKey = prefs.getString('result_auth_key') ?? '';
      final response = await https.get(
        Uri.parse('https://dashboard.cpplayers.com/api/v2/getLiveTvGenreList'),
        headers: {'auth-key': authKey},
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData['status'] == true && decodedData['data'] is List) {
          final List<dynamic> genreData = decodedData['data'];

          // Temporary lists to build before updating state
          List<String> tempNavItems = [];
          List<Widget> tempPages = [];
          List<FocusNode> tempFocusNodes = [];

          // Create pages and focus nodes for each genre from the API
          for (int i = 0; i < genreData.length; i++) {
            String genre = genreData[i]['genre'].toString();
            FocusNode focusNode = FocusNode();

            tempNavItems.add(genre);
            tempFocusNodes.add(focusNode);
            tempPages.add(
              GenericLiveChannels(
                focusNode: focusNode,
                apiCategory: genre, // Use genre name for API call
                displayTitle: genre.toUpperCase(),
                navigationIndex: i,
              ),
            );
          }

          // Add the 'More' button to the navigation list
          tempNavItems.add('More');

          // Update the state with the dynamically created lists
          if (mounted) {
            setState(() {
              _navItems = tempNavItems;
              _pages = tempPages;
              _focusNodes = tempFocusNodes;
              _isLoading = false;
            });
          }

          // Register all the new focus nodes with the provider
          _registerFocusNodes();
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
        print("API Error: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Exception fetching genres: $e");
    }
  }

  // ✅ NEW: Helper function to register focus nodes
  void _registerFocusNodes() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);
          for (int i = 0; i < _focusNodes.length; i++) {
            focusProvider.registerGenericChannelFocus(
                i, ScrollController(), _focusNodes[i]);
          }
          print('✅ All ${_focusNodes.length} dynamic focus nodes registered.');
        } catch (e) {
          print('❌ Dynamic focus registration failed: $e');
        }
      }
    });
  }

  // 🔄 MODIFIED: Logic updated to handle dynamic list length
  void _onPageSelected(int index) {
    print(
        '🎯 Selected: Index $index = ${index < _navItems.length ? _navItems[index] : "Out of range"}');

    // Handle 'More' button, its index is now dynamic (_pages.length)
    if (index == _pages.length) {
      print('📁 Navigating to More page');
      _navigateToMorePage();
      return;
    }

    if (index < 0 || index >= _pages.length) {
      print(
          '❌ Invalid page index: $index (Valid range: 0-${_pages.length - 1})');
      return;
    }

    setState(() {
      _selectedPage = index;
    });

    try {
      context.read<FocusProvider>().setCurrentSelectedNavIndex(index);
    } catch (e) {
      print('❌ Error setting nav index: $e');
    }

    _pageController.jumpToPage(index);
    _handlePageFocus(index);
  }

  // 🔄 MODIFIED: No changes needed here, but it now works with dynamic data
  void _handlePageFocus(int index) {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        try {
          Provider.of<FocusProvider>(context, listen: false)
              .requestFirstChannelFocus(index);
          print(
              '🎯 Auto-focusing ${_navItems[index]} channels (index: $index)');
        } catch (e) {
          print('❌ Auto-focus failed for page $index: $e');
        }
      }
    });
  }

  void _navigateToMorePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChannelsCategory()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ NEW: Show a loading screen while data is being fetched
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: Column(
            children: [
              MiddleNavigationBar(
                selectedPage: _selectedPage,
                onPageSelected: _onPageSelected,
                focusNode: FocusNode(), // This can be a temporary node
                maxPageIndex: _pages.length - 1,
                totalNavItems: _navItems.length,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    if (index >= 0 && index < _pages.length) {
                      setState(() {
                        _selectedPage = index;
                      });
                      _handlePageFocus(index);
                    }
                  },
                  children: _pages, // ✅ Use dynamic pages list
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔄 MODIFIED: Dispose loop for dynamic focus nodes
  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }
}
