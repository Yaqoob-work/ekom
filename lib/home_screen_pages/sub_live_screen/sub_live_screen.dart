



import 'package:mobi_tv_entertainment/home_screen_pages/sub_live_screen/channels_category.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/sub_live_screen/live_all.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/menu/middle_navigation_bar.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubLiveScreen extends StatefulWidget {
  @override
  State<SubLiveScreen> createState() => _SubLiveScreenState();
}

class _SubLiveScreenState extends State<SubLiveScreen> {
  int _selectedPage = 0;
  late PageController _pageController;

  // ✅ Focus nodes for all pages
  final FocusNode _liveChannelsFocusNode = FocusNode();
  final FocusNode _entertainmentChannelsFocusNode = FocusNode();
  final FocusNode _musicChannelsFocusNode = FocusNode();
  final FocusNode _movieChannelsFocusNode = FocusNode();
  final FocusNode _newsChannelsFocusNode = FocusNode();
  final FocusNode _sportsChannelsFocusNode = FocusNode();
  final FocusNode _religiousChannelsFocusNode = FocusNode();

  // ✅ Navigation items - SINGLE SOURCE
  static const List<String> navItems = [
    'Live', // Index 0
    'Entertainment', // Index 1
    'Music', // Index 2
    'Movie', // Index 3
    'News', // Index 4
    'Sports', // Index 5
    'Religious', // Index 6
    'More' // Index 7 - Special case, navigates to separate page
  ];

  // ✅ Pages using GenericLiveChannels for most pages
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();

    // ✅ Initialize pages with GenericLiveChannels
    pages = [
      // LiveChannelPage(focusNode: _liveChannelsFocusNode),           // 0 - Live (special case)
      GenericLiveChannels(
        // 0 - Live ✅ (Fixed)
        focusNode: _liveChannelsFocusNode,
        apiCategory: 'All',
        displayTitle: 'LIVE',
        navigationIndex: 0, // ✅ Correct index
      ),

      GenericLiveChannels(
        // 1 - Entertainment ✅
        focusNode: _entertainmentChannelsFocusNode,
        apiCategory: 'Entertainment',
        displayTitle: 'ENTERTAINMENT',
        navigationIndex: 1,
      ),

      GenericLiveChannels(
        // 2 - Music ✅
        focusNode: _musicChannelsFocusNode,
        apiCategory: 'Music',
        displayTitle: 'MUSIC',
        navigationIndex: 2,
      ),

      GenericLiveChannels(
        // 3 - Movie ✅
        focusNode: _movieChannelsFocusNode,
        apiCategory: 'Movies',
        displayTitle: 'MOVIES',
        navigationIndex: 3,
      ),

      GenericLiveChannels(
        // 4 - News ✅
        focusNode: _newsChannelsFocusNode,
        apiCategory: 'News',
        displayTitle: 'NEWS',
        navigationIndex: 4,
      ),

      GenericLiveChannels(
        // 5 - Sports ✅
        focusNode: _sportsChannelsFocusNode,
        apiCategory: 'Sports',
        displayTitle: 'SPORTS',
        navigationIndex: 5,
      ),

      GenericLiveChannels(
        // 6 - Religious ✅
        focusNode: _religiousChannelsFocusNode,
        apiCategory: 'Religios',
        displayTitle: 'RELIGIOUS',
        navigationIndex: 6,
      ),
      // Note: More (Index 7) is NOT in PageView - it navigates to separate screen
    ];

    _pageController = PageController(initialPage: 0);

    print('🎯 Navigation items: ${navItems.length}');
    print('🎯 Pages for PageView: ${pages.length}');
    print('🎯 Valid page range: 0-${pages.length - 1}');

    // ✅ Register all focus nodes with FocusProvider
    // ✅ Register focus nodes AFTER pages are created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final focusProvider =
            Provider.of<FocusProvider>(context, listen: false);

        // ✅ Register Live channels focus node FIRST
        // focusProvider.setLiveChannelsFocusNode(_liveChannelsFocusNode);

        // ✅ Register all generic channel focus nodes with correct indices
        focusProvider.registerGenericChannelFocus(
            0, ScrollController(), _liveChannelsFocusNode);
        focusProvider.registerGenericChannelFocus(
            1, ScrollController(), _entertainmentChannelsFocusNode);
        focusProvider.registerGenericChannelFocus(
            2, ScrollController(), _musicChannelsFocusNode);
        focusProvider.registerGenericChannelFocus(
            3, ScrollController(), _movieChannelsFocusNode);
        focusProvider.registerGenericChannelFocus(
            4, ScrollController(), _newsChannelsFocusNode);
        focusProvider.registerGenericChannelFocus(
            5, ScrollController(), _sportsChannelsFocusNode);
        focusProvider.registerGenericChannelFocus(
            6, ScrollController(), _religiousChannelsFocusNode);

        // ✅ Legacy compatibility
        focusProvider.setFirstMusicChannelFocusNode(_musicChannelsFocusNode);
        focusProvider.setFirstNewsChannelFocusNode(_newsChannelsFocusNode);

        print('✅ All focus nodes registered with Live fixed');
      } catch (e) {
        print('❌ Focus registration failed: $e');
      }
    });
  }

  // ✅ GENERIC: Page selection handling for all pages
  // void _onPageSelected(int index) {
  //   print('🎯 Selected: Index $index = ${index < navItems.length ? navItems[index] : "Out of range"}');

  //   // ✅ Handle More button specially
  //   if (index == 7) { // More button (last item)
  //     print('📁 Navigating to More page');
  //     _navigateToMorePage();
  //     return;
  //   }

  //   // ✅ Validate index is within page range
  //   if (index < 0 || index >= pages.length) {
  //     print('❌ Invalid page index: $index (Valid range: 0-${pages.length - 1})');
  //     return;
  //   }

  //   // ✅ Navigate to page
  //   setState(() {
  //     _selectedPage = index;
  //   });

  //   _pageController.jumpToPage(index);

  //   // ✅ GENERIC: Handle focus for all pages with proper delay
  //   Future.delayed(Duration(milliseconds: 150), () {
  //     if (mounted) {
  //       try {
  //         final focusProvider = Provider.of<FocusProvider>(context, listen: false);

  //         switch (index) {
  //           case 0: // Live - special case
  //             print('🔴 Focusing Live channels');
  //             _liveChannelsFocusNode.requestFocus();
  //             focusProvider.requestLiveChannelsFocus();
  //             break;

  //           default: // All other pages use generic method ✅
  //             print('🎯 Focusing ${navItems[index]} channels (index: $index)');
  //             focusProvider.requestFirstChannelFocus(index);
  //         }
  //       } catch (e) {
  //         print('❌ Focus request failed for index $index: $e');
  //       }
  //     }
  //   });
  // }

  // SubLiveScreen में _onPageSelected method को update करें:

  void _onPageSelected(int index) {
    print(
        '🎯 Selected: Index $index = ${index < navItems.length ? navItems[index] : "Out of range"}');

    // ✅ Handle More button specially
    if (index == 7) {
      // More button (last item)
      print('📁 Navigating to More page');
      _navigateToMorePage();
      return;
    }

    // ✅ Validate index is within page range
    if (index < 0 || index >= pages.length) {
      print(
          '❌ Invalid page index: $index (Valid range: 0-${pages.length - 1})');
      return;
    }

    // ✅ Navigate to page
    setState(() {
      _selectedPage = index;
    });


        // ✅ NEW: Update FocusProvider with current selected index
    try {
      context.read<FocusProvider>().setCurrentSelectedNavIndex(index);
    } catch (e) {
      print('❌ Error setting nav index from SubLiveScreen: $e');
    }

    _pageController.jumpToPage(index);

    // ✅ FIXED: Handle focus for ALL pages including Live (index 0)
    Future.delayed(Duration(milliseconds: 150), () {
      if (mounted) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);

          // ✅ UNIFIED: Use generic method for ALL pages including Live
          print('🎯 Focusing ${navItems[index]} channels (index: $index)');
          focusProvider.requestFirstChannelFocus(index);
        } catch (e) {
          print('❌ Focus request failed for index $index: $e');
        }
      }
    });
  }

// ✅ FIXED: Handle page focus (used by both navigation and swipe)
  void _handlePageFocus(int index) {
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);

          // ✅ UNIFIED: Use generic method for ALL pages including Live
          print(
              '🎯 Auto-focusing ${navItems[index]} channels on swipe (index: $index)');
          focusProvider.requestFirstChannelFocus(index);
        } catch (e) {
          print('❌ Auto-focus failed for page $index: $e');
        }
      }
    });
  }

  void _navigateToMorePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChannelsCategory()),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building SubLiveScreen');
    print(
        '🎯 Selected: $_selectedPage (${_selectedPage < navItems.length ? navItems[_selectedPage] : "Invalid"})');
    print('🎯 Page exists: ${_selectedPage < pages.length}');

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Container(
                width: screenwdt,
                height: screenhgt,
                color: cardColor,
                child: Column(
                  children: [
                    Container(
                      child: Stack(
                        children: [
                          MiddleNavigationBar(
                            selectedPage: _selectedPage,
                            onPageSelected: _onPageSelected,
                            focusNode: FocusNode(),
                            maxPageIndex:
                                pages.length - 1, // ✅ Pass valid range
                            totalNavItems:
                                navItems.length, // ✅ Pass total nav items
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          print('📖 PageView changed to: $index');
                          // ✅ Validate before setting state
                          if (index >= 0 &&
                              index < pages.length &&
                              index < navItems.length) {
                            setState(() {
                              _selectedPage = index;
                            });
                            print(
                                '✅ Page changed to: $index = ${navItems[index]}');

                            // ✅ GENERIC: Handle focus on page swipe too
                            _handlePageFocus(index);
                          } else {
                            print('❌ Invalid page change: $index');
                          }
                        },
                        children: pages, // ✅ Use dynamic pages list
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // // ✅ GENERIC: Handle page focus (used by both navigation and swipe)
  // void _handlePageFocus(int index) {
  //   Future.delayed(Duration(milliseconds: 100), () {
  //     if (mounted) {
  //       try {
  //         final focusProvider = Provider.of<FocusProvider>(context, listen: false);

  //         switch (index) {
  //           case 0: // Live - special case
  //             print('🔴 Auto-focusing Live channels on swipe');
  //             focusProvider.requestLiveChannelsFocus();
  //             break;

  //           default: // All other pages use generic method ✅
  //             print('🎯 Auto-focusing ${navItems[index]} channels on swipe (index: $index)');
  //             focusProvider.requestFirstChannelFocus(index);
  //         }
  //       } catch (e) {
  //         print('❌ Auto-focus failed for page $index: $e');
  //       }
  //     }
  //   });
  // }

  @override
  void dispose() {
    _liveChannelsFocusNode.dispose();
    _entertainmentChannelsFocusNode.dispose();
    _musicChannelsFocusNode.dispose();
    _movieChannelsFocusNode.dispose();
    _newsChannelsFocusNode.dispose();
    _sportsChannelsFocusNode.dispose();
    _religiousChannelsFocusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
