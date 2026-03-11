






// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as https;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// // --- PROJECT IMPORTS ---
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/plan_expired_screen.dart';
// import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';

// // --- SCREEN IMPORTS ---
// import 'package:mobi_tv_entertainment/components/home_screen_pages/banner_slider_screen/banner_slider_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_live_screen/live_channel_language_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/movies_screen/movies.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/manage_webseries.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/manage_tv_shows.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show_pak/tv_show_pak.dart';

// // --- UPDATED IMPORTS FOR KIDS & ADULT ---
// import 'package:mobi_tv_entertainment/components/home_screen_pages/kids_shows/kids_channels.dart'; // Ensure this path is correct
// import 'package:mobi_tv_entertainment/components/home_screen_pages/above_18/above_eighteen.dart'; // Ensure this path is correct

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // --- STATE VARIABLES ---
//   bool _isLoading = true;

//   // Content Visibility Flags
//   bool _showContentNetwork = false;
//   bool _showMovies = false;
//   bool _showWebseries = false;
//   bool _showTvShows = false;
//   bool _showTvShowsPak = false;
//   bool _showSports = false;
//   bool _showReligious = false;
//   bool _showKids = false; // ✅ Fixed: New variable for Kids
//   // bool _showAdult = false; // ✅ Fixed: New variable for Above 18

//   // --- GLOBAL KEYS ---
//   final GlobalKey watchNowKey = GlobalKey();
//   final GlobalKey liveChannelLanguageKey = GlobalKey();
//   final GlobalKey subVodKey = GlobalKey();
//   final GlobalKey manageMoviesKey = GlobalKey();
//   final GlobalKey manageWebseriesKey = GlobalKey();
//   final GlobalKey tvShowsKey = GlobalKey();
//   final GlobalKey tvShowsPakKey = GlobalKey();
//   final GlobalKey sportsKey = GlobalKey();
//   final GlobalKey religiousChannelKey = GlobalKey();
//   final GlobalKey kidsShowKey = GlobalKey();
//   // final GlobalKey aboveEighteenKey = GlobalKey();

//   // --- FOCUS NODES ---
//   late FocusNode watchNowFocusNode;
//   late FocusNode firstSubVodFocusNode;
//   late FocusNode manageMoviesFocusNode;
//   late FocusNode tvShowsFocusNode;
  
//   // Note: Other focus nodes are handled internally by their widgets, 
//   // but we initialize these main ones for initial entry points.

//   @override
//   void initState() {
//     super.initState();
    
//     // Initialize Focus Nodes
//     watchNowFocusNode = FocusNode();
//     firstSubVodFocusNode = FocusNode();
//     manageMoviesFocusNode = FocusNode();
//     tvShowsFocusNode = FocusNode();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // 1. API Call
//       _checkPlanStatus();

//       // 2. Provider Registration
//       final focusProvider = context.read<FocusProvider>();

//       // Register entry focus nodes
//       focusProvider.registerFocusNode('watchNow', watchNowFocusNode);
//       focusProvider.registerFocusNode('subVod', firstSubVodFocusNode);
//       focusProvider.registerFocusNode('manageMovies', manageMoviesFocusNode);
//       focusProvider.registerFocusNode('tvShows', tvShowsFocusNode);

//       // Register Keys (Essential for scrolling to the widget)
//       focusProvider.registerElementKey('watchNow', watchNowKey);
//       focusProvider.registerElementKey('liveChannelLanguage', liveChannelLanguageKey);
//       focusProvider.registerElementKey('subVod', subVodKey);
//       focusProvider.registerElementKey('manageMovies', manageMoviesKey);
//       focusProvider.registerElementKey('manageWebseries', manageWebseriesKey);
//       focusProvider.registerElementKey('tvShows', tvShowsKey);
//       focusProvider.registerElementKey('sports', sportsKey);
//       focusProvider.registerElementKey('religiousChannels', religiousChannelKey);
//       focusProvider.registerElementKey('tvShowPak', tvShowsPakKey);
//       focusProvider.registerElementKey('kids_show', kidsShowKey);
//       // focusProvider.registerElementKey('aboveEighteen', aboveEighteenKey);
//     });
//   }

//   // --- API CHECK FUNCTION ---
//   Future<void> _checkPlanStatus() async {
//     final String? authKey = SessionManager.authKey;

//     if (authKey == null || authKey.isEmpty) {
//       if (mounted && Navigator.canPop(context)) Navigator.pop(context);
//       if (mounted) setState(() => _isLoading = false);
//       return;
//     }

//     try {
//       var url = Uri.parse(SessionManager.baseUrl + 'checkExpiryPlan');

//       final response = await https.get(
//         url,
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': SessionManager.savedDomain,
//         },
//       ).timeout(const Duration(seconds: 20));

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final res = json.decode(response.body);

//         final bool planExpired = (res['plan_expired'] == true ||
//             res['plan_expired'] == 1 ||
//             res['plan_expired'] == "1");
//         final bool planWillExpire =
//             (res['plan_will_expire'] == true || res['plan_will_expire'] == 1);
//         final String message = res['message'] ?? 'Status Unknown';
//         final domainContent = res['domain_content'];

//         if (planExpired) {
//           if (Navigator.canPop(context)) Navigator.pop(context);
//           await Future.delayed(const Duration(milliseconds: 100));
//           if (!mounted) return;
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(
//               builder: (context) => PlanExpiredScreen(apiMessage: message),
//             ),
//             (route) => false,
//           );
//           return;
//         }

//         // --- ✅ FIX: Parsing Logic Updated ---
//         if (domainContent != null && domainContent is Map) {
//           setState(() {
//             _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//             _showMovies = (domainContent['movies'] ?? 0) == 1;
//             _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//             _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//             _showTvShowsPak = (domainContent['tvshow_pak'] ?? 0) == 1;
//             _showSports = (domainContent['sports'] ?? 0) == 1;
//             _showReligious = (domainContent['religious'] ?? 0) == 1;
//             // Correctly assigning specific variables
//             _showKids = (domainContent['kids_show'] ?? 0) == 1; 
//             // Assuming API key is 'adult' or enabling by default if not present
//             // _showAdult = (domainContent['adult'] ?? 1) == 1; 
//           });
//         }

//         if (planWillExpire) {
//           setState(() => _isLoading = false);
//           if (Navigator.canPop(context)) Navigator.pop(context);
//           Future.delayed(const Duration(milliseconds: 200), () {
//             if (mounted) _showExpiryWarningDialog(message);
//           });
//         } else {
//           if (Navigator.canPop(context)) Navigator.pop(context);
//           setState(() => _isLoading = false);
//         }
//       } else {
//         if (Navigator.canPop(context)) Navigator.pop(context);
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       if (Navigator.canPop(context)) Navigator.pop(context);
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showExpiryWarningDialog(String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.grey[850],
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
//           icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 48),
//           title: const Text('Plan Expiry Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//           content: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
//           actionsAlignment: MainAxisAlignment.center,
//           actions: <Widget>[
//             TextButton(
//               style: TextButton.styleFrom(backgroundColor: Colors.amber),
//               child: const Text('O.K', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     watchNowFocusNode.dispose();
//     firstSubVodFocusNode.dispose();
//     manageMoviesFocusNode.dispose();
//     tvShowsFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(backgroundColor: Colors.black);
//     }

//     // --- ✅ FIX: Visibility & Order Logic Updated ---
//     // The order here MUST match the Widget tree order below
//     final List<String> visibleRows = [
//       'watchNow',
//       'liveChannelLanguage',
//     ];

//     if (_showContentNetwork) visibleRows.add('subVod');
//     if (_showMovies) visibleRows.add('manageMovies');
//     if (_showWebseries) visibleRows.add('manageWebseries');
//     if (_showTvShows) visibleRows.add('tvShows');
//     if (_showSports) visibleRows.add('sports');
//     if (_showReligious) visibleRows.add('religiousChannels');
//     if (_showTvShowsPak) visibleRows.add('tvShowPak');
    
//     // Explicitly adding Kids and Adult based on their own flags
//     if (_showKids) visibleRows.add('kids_show');
//     // if (_showAdult) visibleRows.add('aboveEighteen');

//     // Update Provider
//     context.read<FocusProvider>().updateVisibleRowIdentifiers(visibleRows);

//     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//       // Determine background color
//       Color backgroundColor = colorProvider.isItemFocused
//           ? colorProvider.dominantColor.withOpacity(0.2)
//           : const Color(0xFF0A0E1A); // Default dark background

//       return PopScope(
//         canPop: false,
//         onPopInvoked: (didPop) {
//           if (!didPop) {
//             Navigator.of(context).push(
//               PageRouteBuilder(
//                 opaque: false,
//                 pageBuilder: (context, _, __) => const ExitConfirmationScreen(
//                   isFromBackButton: true,
//                 ),
//               ),
//             );
//           }
//         },
//         child: Scaffold(
//           // backgroundColor: backgroundColor,
//           backgroundColor: Colors.white,
//           body: Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             color: Colors.transparent,
//             child: SingleChildScrollView(
//               controller: context.read<FocusProvider>().scrollController,
//               physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 1. Banner
//                   Container(
//                     height: MediaQuery.of(context).size.height * 0.65,
//                     width: MediaQuery.of(context).size.width,
//                     key: watchNowKey,
//                     child: BannerSlider(focusNode: watchNowFocusNode),
//                   ),

//                   // 2. Live Channels
//                   Container(
//                     height: MediaQuery.of(context).size.height * 0.30,
//                     width: MediaQuery.of(context).size.width,
//                     key: liveChannelLanguageKey,
//                     child: const LiveChannelLanguageScreen(),
//                   ),

//                   // 3. Dynamic Sections
//                   if (_showContentNetwork)
//                     SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: subVodKey,
//                       child: const HorzontalVod(),
//                     ),

//                   if (_showMovies)
//                     SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: manageMoviesKey,
//                       child: const MoviesScreen(),
//                     ),

//                   if (_showWebseries)
//                     SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: manageWebseriesKey,
//                       child: const ManageWebSeries(),
//                     ),

//                   if (_showTvShows)
//                     SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: tvShowsKey,
//                       child: const ManageTvShows(),
//                     ),

//                   if (_showSports)
//                     SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: sportsKey,
//                       child: const ManageSports(),
//                     ),

//                   if (_showReligious)
//                     SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: religiousChannelKey,
//                       child: const ManageReligiousShows(),
//                     ),

//                   if (_showTvShowsPak)
//                     SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: tvShowsPakKey,
//                       child: const TvShowsPak(),
//                     ),

//                   // --- ✅ FIX: Kids Section ---
//                   if (_showKids)
//                     SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: kidsShowKey,
//                       child: const ManageKidsShows(),
//                     ),

//                   // // --- ✅ FIX: Above 18 Section ---
//                   // if (_showAdult)
//                   //   SizedBox(
//                   //     height: MediaQuery.of(context).size.height * 0.38,
//                   //     key: aboveEighteenKey,
//                   //     child: const AboveEighteen(),
//                   //   ),
                    
//                   // Extra padding at bottom for better scrolling experience
//                   SizedBox(height: 50),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }






// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as https;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// // --- PROJECT IMPORTS ---
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/plan_expired_screen.dart';
// import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';

// // --- SCREEN IMPORTS ---
// import 'package:mobi_tv_entertainment/components/home_screen_pages/banner_slider_screen/banner_slider_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_live_screen/live_channel_language_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/movies_screen/movies.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/manage_webseries.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/manage_tv_shows.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show_pak/tv_show_pak.dart';

// // --- UPDATED IMPORTS FOR KIDS & ADULT ---
// import 'package:mobi_tv_entertainment/components/home_screen_pages/kids_shows/kids_channels.dart'; 
// import 'package:mobi_tv_entertainment/components/home_screen_pages/above_18/above_eighteen.dart'; 

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // --- STATE VARIABLES ---
//   bool _isLoading = true;

//   // Content Visibility Flags
//   bool _showContentNetwork = false;
//   bool _showMovies = false;
//   bool _showWebseries = false;
//   bool _showTvShows = false;
//   bool _showTvShowsPak = false;
//   bool _showSports = false;
//   bool _showReligious = false;
//   bool _showKids = false; 
//   // bool _showAdult = false; 
  

//   // --- GLOBAL KEYS ---
//   final GlobalKey watchNowKey = GlobalKey();
//   final GlobalKey liveChannelLanguageKey = GlobalKey();
//   final GlobalKey subVodKey = GlobalKey();
//   final GlobalKey manageMoviesKey = GlobalKey();
//   final GlobalKey manageWebseriesKey = GlobalKey();
//   final GlobalKey tvShowsKey = GlobalKey();
//   final GlobalKey tvShowsPakKey = GlobalKey();
//   final GlobalKey sportsKey = GlobalKey();
//   final GlobalKey religiousChannelKey = GlobalKey();
//   final GlobalKey kidsShowKey = GlobalKey();
//   // final GlobalKey aboveEighteenKey = GlobalKey();

//   // --- FOCUS NODES ---
//   late FocusNode watchNowFocusNode;
//   late FocusNode firstSubVodFocusNode;
//   late FocusNode manageMoviesFocusNode;
//   late FocusNode tvShowsFocusNode;
  
//   @override
//   void initState() {
//     super.initState();
    
//     // Initialize Focus Nodes
//     watchNowFocusNode = FocusNode();
//     firstSubVodFocusNode = FocusNode();
//     manageMoviesFocusNode = FocusNode();
//     tvShowsFocusNode = FocusNode();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // 1. API Call
//       _checkPlanStatus();

//       // 2. Provider Registration
//       final focusProvider = context.read<FocusProvider>();

//       // Register entry focus nodes
//       focusProvider.registerFocusNode('watchNow', watchNowFocusNode);
//       focusProvider.registerFocusNode('subVod', firstSubVodFocusNode);
//       focusProvider.registerFocusNode('manageMovies', manageMoviesFocusNode);
//       focusProvider.registerFocusNode('tvShows', tvShowsFocusNode);

//       // Register Keys (Essential for scrolling to the widget)
//       focusProvider.registerElementKey('watchNow', watchNowKey);
//       focusProvider.registerElementKey('liveChannelLanguage', liveChannelLanguageKey);
//       focusProvider.registerElementKey('subVod', subVodKey);
//       focusProvider.registerElementKey('manageMovies', manageMoviesKey);
//       focusProvider.registerElementKey('manageWebseries', manageWebseriesKey);
//       focusProvider.registerElementKey('tvShows', tvShowsKey);
//       focusProvider.registerElementKey('sports', sportsKey);
//       focusProvider.registerElementKey('religiousChannels', religiousChannelKey);
//       focusProvider.registerElementKey('tvShowPak', tvShowsPakKey);
//       focusProvider.registerElementKey('kids_show', kidsShowKey);
//       // focusProvider.registerElementKey('aboveEighteen', aboveEighteenKey);

// Future.delayed(const Duration(milliseconds: 800), () { // Thoda delay badhaya safety ke liye
//    if (mounted) {
//      final focusProvider = context.read<FocusProvider>();
//      // Agar user ne manually kahin aur move nahi kiya hai, tabhi request karein
//      if (focusProvider.lastFocusedIdentifier == '' || focusProvider.lastFocusedIdentifier == 'liveChannelLanguage') {
//        focusProvider.requestFocus('liveChannelLanguage');
//      }
//    }
// });
//     });
//   }

//   // --- API CHECK FUNCTION ---
//   Future<void> _checkPlanStatus() async {
//     final String? authKey = SessionManager.authKey;

//     if (authKey == null || authKey.isEmpty) {
//       if (mounted && Navigator.canPop(context)) Navigator.pop(context);
//       if (mounted) setState(() => _isLoading = false);
//       return;
//     }

//     try {
//       var url = Uri.parse(SessionManager.baseUrl + 'checkExpiryPlan');

//       final response = await https.get(
//         url,
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': SessionManager.savedDomain,
//         },
//       ).timeout(const Duration(seconds: 20));

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final res = json.decode(response.body);

//         final bool planExpired = (res['plan_expired'] == true ||
//             res['plan_expired'] == 1 ||
//             res['plan_expired'] == "1");
//         final bool planWillExpire =
//             (res['plan_will_expire'] == true || res['plan_will_expire'] == 1);
//         final String message = res['message'] ?? 'Status Unknown';
//         final domainContent = res['domain_content'];

//         if (planExpired) {
//           if (Navigator.canPop(context)) Navigator.pop(context);
//           await Future.delayed(const Duration(milliseconds: 100));
//           if (!mounted) return;
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(
//               builder: (context) => PlanExpiredScreen(apiMessage: message),
//             ),
//             (route) => false,
//           );
//           return;
//         }

//         if (domainContent != null && domainContent is Map) {
//           setState(() {
//             _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//             _showMovies = (domainContent['movies'] ?? 0) == 1;
//             _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//             _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//             _showTvShowsPak = (domainContent['tvshow_pak'] ?? 0) == 1;
//             _showSports = (domainContent['sports'] ?? 0) == 1;
//             _showReligious = (domainContent['religious'] ?? 0) == 1;
//             _showKids = (domainContent['kids_show'] ?? 0) == 1; 
//             // _showAdult = (domainContent['adult'] ?? 1) == 1; 
//           });
//         }

//         if (planWillExpire) {
//           setState(() => _isLoading = false);
//           if (Navigator.canPop(context)) Navigator.pop(context);
//           Future.delayed(const Duration(milliseconds: 200), () {
//             if (mounted) _showExpiryWarningDialog(message);
//           });
//         } else {
//           if (Navigator.canPop(context)) Navigator.pop(context);
//           setState(() => _isLoading = false);
//         }
//       } else {
//         if (Navigator.canPop(context)) Navigator.pop(context);
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       if (Navigator.canPop(context)) Navigator.pop(context);
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showExpiryWarningDialog(String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.grey[850],
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
//           icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 48),
//           title: const Text('Plan Expiry Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//           content: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
//           actionsAlignment: MainAxisAlignment.center,
//           actions: <Widget>[
//             TextButton(
//               style: TextButton.styleFrom(backgroundColor: Colors.amber),
//               child: const Text('O.K', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     watchNowFocusNode.dispose();
//     firstSubVodFocusNode.dispose();
//     manageMoviesFocusNode.dispose();
//     tvShowsFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(backgroundColor: Colors.black);
//     }

//     // --- VISIBILITY & ORDER LOGIC ---
//     final List<String> visibleRows = [
//       'watchNow',
//       'liveChannelLanguage',
//     ];

//     if (_showContentNetwork) visibleRows.add('subVod');
//     if (_showMovies) visibleRows.add('manageMovies');
//     if (_showWebseries) visibleRows.add('manageWebseries');
//     if (_showTvShows) visibleRows.add('tvShows');
//     if (_showSports) visibleRows.add('sports');
//     if (_showReligious) visibleRows.add('religiousChannels');
//     if (_showTvShowsPak) visibleRows.add('tvShowPak');
//     if (_showKids) visibleRows.add('kids_show');
//     // if (_showAdult) visibleRows.add('aboveEighteen');

//     // Update Provider
//     context.read<FocusProvider>().updateVisibleRowIdentifiers(visibleRows);

//     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//       return PopScope(
//         canPop: false,
//         onPopInvoked: (didPop) {
//           if (!didPop) {
//             Navigator.of(context).push(
//               PageRouteBuilder(
//                 opaque: false,
//                 pageBuilder: (context, _, __) => const ExitConfirmationScreen(
//                   isFromBackButton: true,
//                 ),
//               ),
//             );
//           }
//         },
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           body: Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             color: Colors.transparent,
//             // ✅ [UPDATED] Replaced SingleChildScrollView + Column with ListView
//             child: ListView(
//               controller: context.read<FocusProvider>().scrollController,
//               physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
//               // // ✅ [CRITICAL] Keeps downstream widgets alive in memory so focus isn't lost
//               // cacheExtent: 5000,
//               // ✅ FIX: Change 5000 to 800 (Enough to preload next row, but saves memory)
//   cacheExtent: 400, 
  
//   // ✅ OPTIMIZATION: Helps Flutter calculate scroll position faster
//   addAutomaticKeepAlives: true,
//   addRepaintBoundaries: true, 
//               children: [
                
//                 // 1. Banner
//                 RepaintBoundary(
//                   child: SizedBox (
//                     height: MediaQuery.of(context).size.height * 0.65,
//                     key: watchNowKey,
//                     child: BannerSlider(focusNode: watchNowFocusNode),
//                   ),
//                 ),

//                 // 2. Live Channels
//                 RepaintBoundary(
//                   child: SizedBox (
//                   height: MediaQuery.of(context).size.height * 0.30,
//                   key: liveChannelLanguageKey,
//                   child: const LiveChannelLanguageScreen(),
//                 )),

//                 // 3. Dynamic Sections
//                 if (_showContentNetwork)
//                   RepaintBoundary(
//                   child: SizedBox (
//                     height: MediaQuery.of(context).size.height * 0.30,
//                     key: subVodKey,
//                     child: const HorzontalVod(),
//                   )),

//                 if (_showMovies)
//                   RepaintBoundary(
//                   child: SizedBox (
//                     height: MediaQuery.of(context).size.height * 0.30,
//                     key: manageMoviesKey,
//                     child: const MoviesScreen(),
//                   )),

//                 if (_showWebseries)
//                   RepaintBoundary(
//                   child: SizedBox (
//                     height: MediaQuery.of(context).size.height * 0.30,
//                     key: manageWebseriesKey,
//                     child: const ManageWebSeries(),
//                   )),

//                 if (_showTvShows)
//                   RepaintBoundary(
//                   child: SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.30,
//                     key: tvShowsKey,
//                     child: const ManageTvShows(),
//                   )),

//                 if (_showSports)
//                   RepaintBoundary(
//                   child: SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.30,
//                     key: sportsKey,
//                     child: const ManageSports(),
//                   )),

//                 if (_showReligious)
//                   RepaintBoundary(
//                   child: SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.30,
//                     key: religiousChannelKey,
//                     child: const ManageReligiousShows(),
//                   )),

//                 if (_showTvShowsPak)
//                   RepaintBoundary(
//                   child: SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.30,
//                     key: tvShowsPakKey,
//                     child: const TvShowsPak(),
//                   )),

//                 // --- Kids Section ---
//                 if (_showKids)
//                   RepaintBoundary(
//                   child:  SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.30,
//                     key: kidsShowKey,
//                     child: const ManageKidsShows(),
//                   )),

//                 // // --- Above 18 Section ---
//                 // if (_showAdult)
//                 //   SizedBox(
//                 //     height: MediaQuery.of(context).size.height * 0.38,
//                 //     key: aboveEighteenKey,
//                 //     child: const AboveEighteen(),
//                 //   ),
                  
//                 // Extra padding at bottom for better scrolling experience
//                 const SizedBox(height: 50),
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }








// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as https;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// // --- PROJECT IMPORTS ---
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/plan_expired_screen.dart';
// import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';

// // --- SCREEN IMPORTS ---
// import 'package:mobi_tv_entertainment/components/home_screen_pages/banner_slider_screen/banner_slider_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_live_screen/live_channel_language_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/movies_screen/movies.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/manage_webseries.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/manage_tv_shows.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show_pak/tv_show_pak.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/kids_shows/kids_channels.dart'; 

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // --- STATE VARIABLES ---
//   bool _isLoading = true;

//   // Content Visibility Flags
//   bool _showContentNetwork = false;
//   bool _showMovies = false;
//   bool _showWebseries = false;
//   bool _showTvShows = false;
//   bool _showTvShowsPak = false;
//   bool _showSports = false;
//   bool _showReligious = false;
//   bool _showKids = false;

//   // --- GLOBAL KEYS ---
//   final GlobalKey watchNowKey = GlobalKey();
//   final GlobalKey liveChannelLanguageKey = GlobalKey();
//   final GlobalKey subVodKey = GlobalKey();
//   final GlobalKey manageMoviesKey = GlobalKey();
//   final GlobalKey manageWebseriesKey = GlobalKey();
//   final GlobalKey tvShowsKey = GlobalKey();
//   final GlobalKey tvShowsPakKey = GlobalKey();
//   final GlobalKey sportsKey = GlobalKey();
//   final GlobalKey religiousChannelKey = GlobalKey();
//   final GlobalKey kidsShowKey = GlobalKey();

//   // --- FOCUS NODES ---
//   late FocusNode watchNowFocusNode;
//   late FocusNode firstSubVodFocusNode;
//   late FocusNode manageMoviesFocusNode;
//   late FocusNode tvShowsFocusNode;
  
//   @override
//   void initState() {
//     super.initState();
    
//     // Initialize Focus Nodes
//     watchNowFocusNode = FocusNode();
//     firstSubVodFocusNode = FocusNode();
//     manageMoviesFocusNode = FocusNode();
//     tvShowsFocusNode = FocusNode();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // 1. API Call
//       _checkPlanStatus();

//       // 2. Provider Registration
//       final focusProvider = context.read<FocusProvider>();

//       // Register entry focus nodes
//       focusProvider.registerFocusNode('watchNow', watchNowFocusNode);
//       focusProvider.registerFocusNode('subVod', firstSubVodFocusNode);
//       focusProvider.registerFocusNode('manageMovies', manageMoviesFocusNode);
//       focusProvider.registerFocusNode('tvShows', tvShowsFocusNode);

//       // // Register Keys (Essential for scrolling to the widget)
//       // focusProvider.registerElementKey('watchNow', watchNowKey);
//       // focusProvider.registerElementKey('liveChannelLanguage', liveChannelLanguageKey);
//       // focusProvider.registerElementKey('subVod', subVodKey);
//       // focusProvider.registerElementKey('manageMovies', manageMoviesKey);
//       // focusProvider.registerElementKey('manageWebseries', manageWebseriesKey);
//       // focusProvider.registerElementKey('tvShows', tvShowsKey);
//       // focusProvider.registerElementKey('sports', sportsKey);
//       // focusProvider.registerElementKey('religiousChannels', religiousChannelKey);
//       // focusProvider.registerElementKey('tvShowPak', tvShowsPakKey);
//       // focusProvider.registerElementKey('kids_show', kidsShowKey);

//       // ✅ OPTIMIZED: Reduced delay from 800ms to 500ms (Fire TV style)
//       Future.delayed(const Duration(milliseconds: 1000), () {
//         if (mounted) {
//           final focusProvider = context.read<FocusProvider>();
//           // ✅ Simplified check - only if truly no focus
//           if (focusProvider.lastFocusedIdentifier.isEmpty) {
//             focusProvider.requestFocus('liveChannelLanguage');
//           }
//         }
//       });
//     });
//   }

//   // --- API CHECK FUNCTION ---
//   Future<void> _checkPlanStatus() async {
//     final String? authKey = SessionManager.authKey;

//     if (authKey == null || authKey.isEmpty) {
//       if (mounted && Navigator.canPop(context)) Navigator.pop(context);
//       if (mounted) setState(() => _isLoading = false);
//       return;
//     }

//     try {
//       var url = Uri.parse(SessionManager.baseUrl + 'checkExpiryPlan');

//       final response = await https.get(
//         url,
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': SessionManager.savedDomain,
//         },
//       ).timeout(const Duration(seconds: 20));

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final res = json.decode(response.body);

//         final bool planExpired = (res['plan_expired'] == true ||
//             res['plan_expired'] == 1 ||
//             res['plan_expired'] == "1");
//         final bool planWillExpire =
//             (res['plan_will_expire'] == true || res['plan_will_expire'] == 1);
//         final String message = res['message'] ?? 'Status Unknown';
//         final domainContent = res['domain_content'];

//         if (planExpired) {
//           if (Navigator.canPop(context)) Navigator.pop(context);
//           await Future.delayed(const Duration(milliseconds: 100));
//           if (!mounted) return;
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(
//               builder: (context) => PlanExpiredScreen(apiMessage: message),
//             ),
//             (route) => false,
//           );
//           return;
//         }

//         if (domainContent != null && domainContent is Map) {
//           setState(() {
//             _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//             _showMovies = (domainContent['movies'] ?? 0) == 1;
//             _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//             _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//             _showTvShowsPak = (domainContent['tvshow_pak'] ?? 0) == 1;
//             _showSports = (domainContent['sports'] ?? 0) == 1;
//             _showReligious = (domainContent['religious'] ?? 0) == 1;
//             _showKids = (domainContent['kids_show'] ?? 0) == 1;
//           });
//         }

//         if (planWillExpire) {
//           setState(() => _isLoading = false);
//           if (Navigator.canPop(context)) Navigator.pop(context);
//           Future.delayed(const Duration(milliseconds: 200), () {
//             if (mounted) _showExpiryWarningDialog(message);
//           });
//         } else {
//           if (Navigator.canPop(context)) Navigator.pop(context);
//           setState(() => _isLoading = false);
//         }
//       } else {
//         if (Navigator.canPop(context)) Navigator.pop(context);
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       if (Navigator.canPop(context)) Navigator.pop(context);
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showExpiryWarningDialog(String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.grey[850],
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
//           icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 48),
//           title: const Text('Plan Expiry Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//           content: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
//           actionsAlignment: MainAxisAlignment.center,
//           actions: <Widget>[
//             TextButton(
//               style: TextButton.styleFrom(backgroundColor: Colors.amber),
//               child: const Text('O.K', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     watchNowFocusNode.dispose();
//     firstSubVodFocusNode.dispose();
//     manageMoviesFocusNode.dispose();
//     tvShowsFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(backgroundColor: Colors.black);
//     }

//     // --- VISIBILITY & ORDER LOGIC ---
//     final List<String> visibleRows = [
//       'watchNow',
//       'liveChannelLanguage',
//     ];

//     if (_showContentNetwork) visibleRows.add('subVod');
//     if (_showMovies) visibleRows.add('manageMovies');
//     if (_showWebseries) visibleRows.add('manageWebseries');
//     if (_showTvShows) visibleRows.add('tvShows');
//     if (_showSports) visibleRows.add('sports');
//     if (_showReligious) visibleRows.add('religiousChannels');
//     if (_showTvShowsPak) visibleRows.add('tvShowPak');
//     if (_showKids) visibleRows.add('kids_show');

//     // Update Provider
//     context.read<FocusProvider>().updateVisibleRowIdentifiers(visibleRows);

//     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//       return PopScope(
//         canPop: false,
//         onPopInvoked: (didPop) {
//           if (!didPop) {
//             Navigator.of(context).push(
//               PageRouteBuilder(
//                 opaque: false,
//                 pageBuilder: (context, _, __) => const ExitConfirmationScreen(
//                   isFromBackButton: true,
//                 ),
//               ),
//             );
//           }
//         },
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           body: Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             color: Colors.transparent,
//             // ✅ OPTIMIZED ListView with Fire TV settings
//             child: ListView(
//               controller: context.read<FocusProvider>().scrollController,
//               physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              
//               // ✅ OPTIMIZED: Reduced from 400 to 300 (saves memory, improves smoothness)
//               cacheExtent: 300,
              
//               // ✅ Performance optimizations
//               addAutomaticKeepAlives: true,
//               addRepaintBoundaries: true,
              
//               children: [
//                 // 1. Banner
//                 RepaintBoundary(
//                   child: SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.65,
//                     key: watchNowKey,
//                     child: BannerSlider(focusNode: watchNowFocusNode),
//                   ),
//                 ),

//                 // 2. Live Channels
//                 RepaintBoundary(
//                   child: SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.30,
//                     key: liveChannelLanguageKey,
//                     child: const LiveChannelLanguageScreen(),
//                   ),
//                 ),

//                 // 3. Dynamic Sections
//                 if (_showContentNetwork)
//                   RepaintBoundary(
//                     child: SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: subVodKey,
//                       child: const HorzontalVod(),
//                     ),
//                   ),

//                 if (_showMovies)
//                   RepaintBoundary(
//                     child: SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: manageMoviesKey,
//                       child: const MoviesScreen(),
//                     ),
//                   ),

//                 if (_showWebseries)
//                   RepaintBoundary(
//                     child: SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: manageWebseriesKey,
//                       child: const ManageWebSeries(),
//                     ),
//                   ),

//                 if (_showTvShows)
//                   RepaintBoundary(
//                     child: SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: tvShowsKey,
//                       child: const ManageTvShows(),
//                     ),
//                   ),

//                 if (_showSports)
//                   RepaintBoundary(
//                     child: SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: sportsKey,
//                       child: const ManageSports(),
//                     ),
//                   ),

//                 if (_showReligious)
//                   RepaintBoundary(
//                     child: SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: religiousChannelKey,
//                       child: const ManageReligiousShows(),
//                     ),
//                   ),

//                 if (_showTvShowsPak)
//                   RepaintBoundary(
//                     child: SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: tvShowsPakKey,
//                       child: const TvShowsPak(),
//                     ),
//                   ),

//                 // --- Kids Section ---
//                 if (_showKids)
//                   RepaintBoundary(
//                     child: SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.30,
//                       key: kidsShowKey,
//                       child: const ManageKidsShows(),
//                     ),
//                   ),
                  
//                 // ✅ Extra padding for smooth scrolling at bottom
//                 const SizedBox(height: 50),
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }