// // Updated HomeScreen with News Channels Integration
// import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/religious_channel/religious_channel.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/sports_category/sports_category.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/tv_show/tv_show.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/tv_show_pak/tv_show_pak.dart';
// import 'package:mobi_tv_entertainment/menu/middle_navigation_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/manage_webseries.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';

// import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/services.dart';
// import 'banner_slider_screen/banner_slider_screen.dart';
// import 'movies_screen/movies.dart';
// import 'sub_live_screen/live_channel_language_screen.dart';
// import 'sub_live_screen/sub_live_screen.dart';

// void main() {
//   runApp(const HomeScreen());
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // final SocketService _socketService = SocketService();
//   final GlobalKey watchNowKey = GlobalKey();
//   final GlobalKey subLiveKey = GlobalKey();
//   final GlobalKey liveChannelLanguageKey = GlobalKey();
//   final GlobalKey subVodKey = GlobalKey();
//   final GlobalKey manageMoviesKey = GlobalKey();
//   final GlobalKey manageWebseriesKey = GlobalKey();
//   final GlobalKey tvShowsKey = GlobalKey();
//   final GlobalKey tvShowsPakKey = GlobalKey();
//   final GlobalKey sportsKey = GlobalKey();
//   final GlobalKey religiousChannelKey = GlobalKey();

//   late FocusNode watchNowFocusNode;
//   late FocusNode subLiveFocusNode;
//   late FocusNode firstSubVodFocusNode;
//   late FocusNode manageMoviesFocusNode;
//   late FocusNode manageWebseriesFocusNode;
//   late FocusNode tvShowsFocusNode;
//   late FocusNode sportsFocusNode;

//   bool _isLoading = false;
//   int _selectedPage = 0;

//   late UpdateChecker _updateChecker;

//   // Future<void> _ensureAuthKeyLoaded() async {
//   //   await AuthManager.initialize();
//   // }

//   @override
//   void initState() {
//     super.initState();
//     // Initialize focus nodes
//     watchNowFocusNode = FocusNode();
//     subLiveFocusNode = FocusNode();
//     firstSubVodFocusNode = FocusNode();
//     manageMoviesFocusNode = FocusNode();
//     manageWebseriesFocusNode = FocusNode();
//     tvShowsFocusNode = FocusNode();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final focusProvider = context.read<FocusProvider>();

//       // Set focus nodes - UPDATED WITH YOUR EXACT METHOD NAMES
//       focusProvider.setWatchNowFocusNode(watchNowFocusNode);
//       // focusProvider.setFirstMusicItemFocusNode(subLiveFocusNode);
//       focusProvider
//           .setFirstHorizontalListNetworksFocusNode(firstSubVodFocusNode);
//       focusProvider.setFirstManageMoviesFocusNode(manageMoviesFocusNode);
//       // focusProvider.setFirstManageWebseriesFocusNode(manageWebseriesFocusNode);
//       focusProvider.setFirstTVShowsFocusNode(tvShowsFocusNode);

//       // Register element keys
//       context.read<FocusProvider>().registerElementKey('watchNow', watchNowKey);
//       focusProvider.registerElementKey('liveChannelLanguage', liveChannelLanguageKey);
//       focusProvider.registerElementKey('subLiveScreen', subLiveKey);
//       focusProvider.registerElementKey('subVod', subVodKey);
//       focusProvider.registerElementKey('manageMovies', manageMoviesKey);
//       focusProvider.registerElementKey('manageWebseries', manageWebseriesKey);
//       focusProvider.registerElementKey('tvShows', tvShowsKey);
//       focusProvider.registerElementKey('sports', sportsKey);
//       focusProvider.registerElementKey(
//           'religiousChannels', religiousChannelKey);
//       focusProvider.registerElementKey('tvShowPak', tvShowsPakKey);
//     });
//   }

//   @override
//   void dispose() {
//     final focusProvider = context.read<FocusProvider>();
//     focusProvider.unregisterElementKey('watchNow');
//     focusProvider.unregisterElementKey('subLiveScreen');
//     focusProvider.unregisterElementKey('subVod');
//     focusProvider.unregisterElementKey('manageMovies');
//     focusProvider.unregisterElementKey('manageWebseries');
//     focusProvider.unregisterElementKey('tvShows');
//     focusProvider.unregisterElementKey('tvShowPak');
//     focusProvider.unregisterElementKey('sports');

//     // Clean up focus nodes
//     watchNowFocusNode.dispose();
//     subLiveFocusNode.dispose();
//     firstSubVodFocusNode.dispose();
//     manageMoviesFocusNode.dispose();
//     manageWebseriesFocusNode.dispose();
//     tvShowsFocusNode.dispose();
//     sportsFocusNode.dispose();
//     // _socketService.dispose();
//     super.dispose();
//   }

//   // // Handle back button press
//   // Future<bool> _onWillPop() async {
//   //   // Close the app when back button is pressed
//   //   SystemNavigator.pop();
//   //   return false; // Return false to prevent default back navigation
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//       Color backgroundColor = colorProvider.isItemFocused
//           ? colorProvider.dominantColor.withOpacity(0.2)
//           : cardColor;

//       // Get the calculated height for ManageMovies
//       // final double manageMoviesHeight = _calculateManageMoviesHeight(context);

//       return PopScope(
//         canPop: false, // Default back navigation ko rokein

//         // ✅ onPopInvoked KO UPDATE KAREIN
//         onPopInvoked: (didPop) {
//           // agar pop nahi hua hai (jo ki nahi hoga kyunki canPop: false hai)...
//           if (!didPop) {
//             // ...to hamari custom exit screen dikhayein
//             Navigator.of(context).push(
//               PageRouteBuilder(
//                 opaque: false,
//                 pageBuilder: (context, _, __) => const ExitConfirmationScreen(
//                   // Hum true bhej rahe hain kyunki yeh back button se trigger hua hai
//                   isFromBackButton: true,
//                 ),
//               ),
//             );
//           }
//         },
//         child: Scaffold(
//           backgroundColor: backgroundColor,
//           body: Container(
//             width: screenwdt,
//             height: screenhgt,
//             color: Colors.transparent,
//             child: SingleChildScrollView(
//               controller: context.read<FocusProvider>().scrollController,
//               child: Container(
//                 // margin: EdgeInsets.symmetric(horizontal: screenwdt * 0.03),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       height: screenhgt * 0.55,
//                       width: screenwdt,
//                       key: watchNowKey,
//                       child: BannerSlider(
//                         focusNode: watchNowFocusNode,
//                       ),
//                     ),
//                     Container(
//                       height: screenhgt * 0.38,
//                       key: liveChannelLanguageKey,
//                       child: LiveChannelLanguageScreen(
//                           // Note: SubLiveScreen now contains news channels
//                           // The focus management is handled inside SubLiveScreen
//                           ),
//                     ),
//                     // Container(
//                     //   height: screenhgt * 0.48,
//                     //   key: subLiveKey,
//                     //   child: SubLiveScreen(
//                     //       // Note: SubLiveScreen now contains news channels
//                     //       // The focus management is handled inside SubLiveScreen
//                     //       ),
//                     // ),
//                     SizedBox(
//                       height: screenhgt * 0.38,
//                       key: subVodKey,
//                       child: HorzontalVod(
//                           // focusNode: firstSubVodFocusNode,
//                           ),
//                     ),
//                     SizedBox(
//                       height: screenhgt * 0.38,
//                       key: manageMoviesKey,
//                       child: MoviesScreen(
//                           // focusNode: manageMoviesFocusNode,
//                           ),
//                     ),
//                     SizedBox(
//                       height: screenhgt * 0.38,
//                       key: manageWebseriesKey,
//                       child:  ManageWebSeries(
//                           // focusNode: manageWebseriesFocusNode,
//                           ),
//                     ),
//                     SizedBox(
//                         height: screenhgt * 0.38,
//                         key: tvShowsKey,
//                         child:
//                             // HorizontalChannelList(
//                             //   // focusNode: manageWebseriesFocusNode,
//                             // ),
//                              ManageTvShows()),
//                     SizedBox(
//                         height: screenhgt * 0.38,
//                         // key: sportsKey,
//                         child:
//                             // HorizontalChannelList(
//                             //   // focusNode: manageWebseriesFocusNode,
//                             // ),
//                             sports(
//                           key: sportsKey,
//                         )),
//                     SizedBox(
//                         height: screenhgt * 0.38,
//                         key: religiousChannelKey,
//                         child:  ManageReligiousShows()),
//                     SizedBox(
//                         height: screenhgt * 0.38,
//                         key: tvShowsPakKey,
//                         child: TvShowPak()),
//                     if (_isLoading) Center(child: LoadingIndicator()),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }

// // Zaroori packages import karein
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/services.dart'; // ✅ App close karne ke liye import kiya gaya

// // Flutter/Project ke baaki imports
// import 'package:flutter/material.dart';
// import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/religious_channel/religious_channel.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/sports_category/sports_category.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/tv_show/tv_show.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/tv_show_pak/tv_show_pak.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/manage_webseries.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
// import 'package:provider/provider.dart';
// import 'banner_slider_screen/banner_slider_screen.dart';
// import 'movies_screen/movies.dart';
// import 'sub_live_screen/live_channel_language_screen.dart';

// // ✅ Yahan apni actual Login Screen ki file import karein (agar zaroorat pade)
// // import 'package:mobi_tv_entertainment/login_screen.dart'; // Example

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // Global Keys
//   final GlobalKey watchNowKey = GlobalKey();
//   final GlobalKey subLiveKey = GlobalKey();
//   final GlobalKey liveChannelLanguageKey = GlobalKey();
//   final GlobalKey subVodKey = GlobalKey();
//   final GlobalKey manageMoviesKey = GlobalKey();
//   final GlobalKey manageWebseriesKey = GlobalKey();
//   final GlobalKey tvShowsKey = GlobalKey();
//   final GlobalKey tvShowsPakKey = GlobalKey();
//   final GlobalKey sportsKey = GlobalKey();
//   final GlobalKey religiousChannelKey = GlobalKey();

//   // Focus Nodes
//   late FocusNode watchNowFocusNode;
//   late FocusNode subLiveFocusNode;
//   late FocusNode firstSubVodFocusNode;
//   late FocusNode manageMoviesFocusNode;
//   late FocusNode manageWebseriesFocusNode;
//   late FocusNode tvShowsFocusNode;
//   late FocusNode sportsFocusNode;

//   // State Variables
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     // Focus nodes initialize karein
//     watchNowFocusNode = FocusNode();
//     subLiveFocusNode = FocusNode();
//     firstSubVodFocusNode = FocusNode();
//     manageMoviesFocusNode = FocusNode();
//     manageWebseriesFocusNode = FocusNode();
//     tvShowsFocusNode = FocusNode();

//     // UI render hone ke baad API call aur provider setup karein
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Plan status check karne ke liye function call karein
//       _checkPlanAndShowPopup();

//       // Provider setup
//       final focusProvider = context.read<FocusProvider>();
//       focusProvider.setWatchNowFocusNode(watchNowFocusNode);
//       focusProvider.setFirstHorizontalListNetworksFocusNode(firstSubVodFocusNode);
//       focusProvider.setFirstManageMoviesFocusNode(manageMoviesFocusNode);
//       focusProvider.setFirstTVShowsFocusNode(tvShowsFocusNode);

//       // Element keys register karein
//       context.read<FocusProvider>().registerElementKey('watchNow', watchNowKey);
//       focusProvider.registerElementKey('liveChannelLanguage', liveChannelLanguageKey);
//       focusProvider.registerElementKey('subLiveScreen', subLiveKey);
//       focusProvider.registerElementKey('subVod', subVodKey);
//       focusProvider.registerElementKey('manageMovies', manageMoviesKey);
//       focusProvider.registerElementKey('manageWebseries', manageWebseriesKey);
//       focusProvider.registerElementKey('tvShows', tvShowsKey);
//       focusProvider.registerElementKey('sports', sportsKey);
//       focusProvider.registerElementKey('religiousChannels', religiousChannelKey);
//       focusProvider.registerElementKey('tvShowPak', tvShowsPakKey);
//     });
//   }

//   // API Call aur Popup Logic ke liye function
//   Future<void> _checkPlanAndShowPopup() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? authKey = prefs.getString('auth_key');

//     if (authKey == null || authKey.isEmpty) {
//       print('Auth Key not found. Cannot check plan expiry.');
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('https://dashboard.cpplayers.com/public/api/v2/checkExpiryPlan'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': 'coretechinfo.com',
//         },
//       ).timeout(
//         const Duration(seconds: 30),
//       );

//       if (response.statusCode == 200) {
//         final res = json.decode(response.body);

//         if (!mounted) return;

//         final bool logout = res['logout'] ?? false;
//         final bool planExpired = res['planExpired'] ?? false;
//         final bool status = res['status'] ?? false;
//         final String message = res['message'] ?? 'An error occurred.';

//         if (logout && planExpired) {
//           _showPlanExpiredPopup(message);
//         } else if (status) {
//           _showExpiryWarningPopup(message);
//         }

//       } else {
//         print('Server Error while checking plan: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Network Error or Timeout while checking plan: $e');
//     }
//   }

//   // Plan expire hone par yeh popup dikhega (Logout wala)
//   void _showPlanExpiredPopup(String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // User isko band nahi kar sakta
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Plan Expired'),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               // ✅ TV remote se focus ke liye 'autofocus: true'
//               autofocus: true,
//               child: const Text('OK'),
//               onPressed: () {
//                 // ✅ OK press karne par app close ho jayegi
//                 SystemNavigator.pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Plan expire hone se pehle yeh warning popup dikhega
//   void _showExpiryWarningPopup(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Plan Expiry Alert'),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               // ✅ Is button par bhi focus add kar diya hai
//               autofocus: true,
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Sirf popup band karein
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     final focusProvider = context.read<FocusProvider>();
//     focusProvider.unregisterElementKey('watchNow');
//     focusProvider.unregisterElementKey('subLiveScreen');
//     focusProvider.unregisterElementKey('subVod');
//     focusProvider.unregisterElementKey('manageMovies');
//     focusProvider.unregisterElementKey('manageWebseries');
//     focusProvider.unregisterElementKey('tvShows');
//     focusProvider.unregisterElementKey('tvShowPak');
//     focusProvider.unregisterElementKey('sports');

//     // Focus nodes clean up karein
//     watchNowFocusNode.dispose();
//     subLiveFocusNode.dispose();
//     firstSubVodFocusNode.dispose();
//     manageMoviesFocusNode.dispose();
//     manageWebseriesFocusNode.dispose();
//     tvShowsFocusNode.dispose();
//     sportsFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//       Color backgroundColor = colorProvider.isItemFocused
//           ? colorProvider.dominantColor.withOpacity(0.2)
//           : cardColor;

//       return PopScope(
//         canPop: false, // Default back navigation ko rokein
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
//           backgroundColor: backgroundColor,
//           body: Container(
//             width: screenwdt,
//             height: screenhgt,
//             color: Colors.transparent,
//             child: SingleChildScrollView(
//               controller: context.read<FocusProvider>().scrollController,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     height: screenhgt * 0.55,
//                     width: screenwdt,
//                     key: watchNowKey,
//                     child: BannerSlider(focusNode: watchNowFocusNode),
//                   ),
//                   Container(
//                     height: screenhgt * 0.38,
//                     key: liveChannelLanguageKey,
//                     child: const LiveChannelLanguageScreen(),
//                   ),
//                   SizedBox(
//                     height: screenhgt * 0.38,
//                     key: subVodKey,
//                     child: const HorzontalVod(),
//                   ),
//                   SizedBox(
//                     height: screenhgt * 0.38,
//                     key: manageMoviesKey,
//                     child: const MoviesScreen(),
//                   ),
//                   SizedBox(
//                     height: screenhgt * 0.38,
//                     key: manageWebseriesKey,
//                     child: const  ManageWebSeries(),
//                   ),
//                   SizedBox(
//                       height: screenhgt * 0.38,
//                       key: tvShowsKey,
//                       child: const  ManageTvShows()
//                   ),
//                   SizedBox(
//                       height: screenhgt * 0.38,
//                       child: sports(
//                         key: sportsKey,
//                       )
//                   ),
//                   SizedBox(
//                       height: screenhgt * 0.38,
//                       key: religiousChannelKey,
//                       child: const  ManageReligiousShows()
//                   ),
//                   SizedBox(
//                       height: screenhgt * 0.38,
//                       key: tvShowsPakKey,
//                       child: const TvShowPak()
//                   ),
//                   if (_isLoading) Center(child: LoadingIndicator()),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }






// // Zaroori packages import karein
// import 'dart:convert';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/home_screen_pages/plan_expired_screen.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/services.dart';

// // Flutter/Project ke baaki imports
// import 'package:flutter/material.dart';
// import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/religious_channel/religious_channel.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/sports_category/sports_category.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/tv_show/tv_show.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/tv_show_pak/tv_show_pak.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/manage_webseries.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
// import 'package:provider/provider.dart';
// import 'banner_slider_screen/banner_slider_screen.dart';
// import 'movies_screen/movies.dart';
// import 'sub_live_screen/live_channel_language_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // State Variables
//   bool _isLoading = true; // Shuru mein loading state true rahegi

//   // Global Keys
//   final GlobalKey watchNowKey = GlobalKey();
//   final GlobalKey liveChannelLanguageKey = GlobalKey();
//   final GlobalKey subVodKey = GlobalKey();
//   final GlobalKey manageMoviesKey = GlobalKey();
//   final GlobalKey manageWebseriesKey = GlobalKey();
//   final GlobalKey tvShowsKey = GlobalKey();
//   final GlobalKey tvShowsPakKey = GlobalKey();
//   final GlobalKey sportsKey = GlobalKey();
//   final GlobalKey religiousChannelKey = GlobalKey();

//   // Focus Nodes
//   late FocusNode watchNowFocusNode;
//   late FocusNode firstSubVodFocusNode;
//   late FocusNode manageMoviesFocusNode;
//   late FocusNode tvShowsFocusNode;
//   late FocusNode sportsFocusNode;
//   late FocusNode manageWebseriesFocusNode;
//   late FocusNode subLiveFocusNode;

//   @override
//   void initState() {
//     super.initState();
//     // Focus nodes initialize karein
//     watchNowFocusNode = FocusNode();
//     firstSubVodFocusNode = FocusNode();
//     manageMoviesFocusNode = FocusNode();
//     tvShowsFocusNode = FocusNode();
//     sportsFocusNode = FocusNode();
//     manageWebseriesFocusNode = FocusNode();
//     subLiveFocusNode = FocusNode();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // API call karke plan ka status check karega
//       _checkPlanStatus();

//       // Provider setup
//       final focusProvider = context.read<FocusProvider>();
//       focusProvider.setWatchNowFocusNode(watchNowFocusNode);
//       focusProvider
//           .setFirstHorizontalListNetworksFocusNode(firstSubVodFocusNode);
//       focusProvider.setFirstManageMoviesFocusNode(manageMoviesFocusNode);
//       focusProvider.setFirstTVShowsFocusNode(tvShowsFocusNode);

//       // Element keys register karein
//       context.read<FocusProvider>().registerElementKey('watchNow', watchNowKey);
//       focusProvider.registerElementKey(
//           'liveChannelLanguage', liveChannelLanguageKey);
//       focusProvider.registerElementKey('subVod', subVodKey);
//       focusProvider.registerElementKey('manageMovies', manageMoviesKey);
//       focusProvider.registerElementKey('manageWebseries', manageWebseriesKey);
//       focusProvider.registerElementKey('tvShows', tvShowsKey);
//       focusProvider.registerElementKey('sports', sportsKey);
//       focusProvider.registerElementKey(
//           'religiousChannels', religiousChannelKey);
//       focusProvider.registerElementKey('tvShowPak', tvShowsPakKey);
//     });
//   }

//   // Naya UI wala Dialog function
//   void _showExpiryWarningDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.grey[850], // Dark theme ke liye
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           icon: const Icon(Icons.warning_amber_rounded,
//               color: Colors.amber, size: 48),
//           title: const Text(
//             'Plan Expiry Alert',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//           content: Text(
//             message,
//             textAlign: TextAlign.center,
//             style: const TextStyle(color: Colors.white70),
//           ),
//           actionsAlignment: MainAxisAlignment.center,
//           actions: <Widget>[
//             TextButton(
//               style: TextButton.styleFrom(
//                   backgroundColor: Colors.amber,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0))),
//               child: const Text(
//                 'O.K',
//                 style:
//                     TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Dialog band karein
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // PRODUCTION-READY API FUNCTION - UPDATED LOGIC KE SAATH
//   Future<void> _checkPlanStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? authKey = SessionManager.authKey;

//     if (authKey == null || authKey.isEmpty) {
//       print('Auth Key not found. Cannot check plan expiry.');
//       if (mounted) setState(() => _isLoading = false);
//       return;
//     }

//     try {
//       final response = await https.get(
//         Uri.parse(
//             'https://dashboard.cpplayers.com/public/api/v2/checkExpiryPlan'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': 'coretechinfo.com',
//         },
//       ).timeout(const Duration(seconds: 20));

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final res = json.decode(response.body);

//         // Naye API keys ko parse karein, default values ke saath
//         final bool planExpired = res['plan_expired'] ?? false;
//         final bool planWillExpire = res['plan_will_expire'] ?? false;
//         final String message = res['message'] ?? 'Unknown status';

//         // NAYI CONDITIONS YAHAN CHECK HONGI
//         // Condition 1: Agar plan expire ho gaya hai
//         if (planExpired) {
//           // User ko permanent PlanExpiredScreen par bhej do
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) => PlanExpiredScreen(apiMessage: message),
//             ),
//           );
//         }
//         // Condition 2: Agar plan jald hi expire hone wala hai
//         else if (planWillExpire) {
//           // Pehle Home Screen load hone do
//           setState(() => _isLoading = false);
//           // Phir uske upar warning dialog dikhao
//           _showExpiryWarningDialog(message);
//         }
//         // Condition 3: Agar sab theek hai
//         else {
//           // Loading band kardo aur Home Screen dikhao
//           setState(() => _isLoading = false);
//         }
//       } else {
//         // Server se error aane par
//         print('Server Error while checking plan: ${response.statusCode}');
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       // Network ya anya error aane par
//       print('Network Error or Timeout while checking plan: $e');
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     // Sabhi focus nodes ko aache se dispose karein
//     watchNowFocusNode.dispose();
//     firstSubVodFocusNode.dispose();
//     manageMoviesFocusNode.dispose();
//     tvShowsFocusNode.dispose();
//     sportsFocusNode.dispose();
//     manageWebseriesFocusNode.dispose();
//     subLiveFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Jab tak API call chal rahi hai, loading indicator dikhao
//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(
//           child: CircularProgressIndicator(
//             color: Colors.white,
//           ),
//         ),
//       );
//     }

//     // Jab loading poori ho jaaye, tab asli UI dikhao
//     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//       Color backgroundColor = colorProvider.isItemFocused
//           ? colorProvider.dominantColor.withOpacity(0.2)
//           : cardColor;

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
//           backgroundColor: backgroundColor,
//           body: Container(
//             width: screenwdt,
//             height: screenhgt,
//             color: Colors.transparent,
//             child: SingleChildScrollView(
//               controller: context.read<FocusProvider>().scrollController,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     height: screenhgt * 0.55,
//                     width: screenwdt,
//                     key: watchNowKey,
//                     child: BannerSlider(focusNode: watchNowFocusNode),
//                   ),
//                   Container(
//                     height: screenhgt * 0.38,
//                     key: liveChannelLanguageKey,
//                     child: const LiveChannelLanguageScreen(),
//                   ),
//                   SizedBox(
//                     height: screenhgt * 0.38,
//                     key: subVodKey,
//                     child: const HorzontalVod(),
//                   ),
//                   SizedBox(
//                     height: screenhgt * 0.38,
//                     key: manageMoviesKey,
//                     child: const MoviesScreen(),
//                   ),
//                   SizedBox(
//                     height: screenhgt * 0.38,
//                     key: manageWebseriesKey,
//                     child: const ManageWebSeries(),
//                   ),
//                   SizedBox(
//                       height: screenhgt * 0.38,
//                       key: tvShowsKey,
//                       child: const ManageTvShows()),
//                   SizedBox(
//                       height: screenhgt * 0.38,
//                       child: sports(
//                         key: sportsKey,
//                       )),
//                   SizedBox(
//                       height: screenhgt * 0.38,
//                       key: religiousChannelKey,
//                       child: const ManageReligiousShows()),
//                   SizedBox(
//                       height: screenhgt * 0.38,
//                       key: tvShowsPakKey,
//                       child: const TvShowPak()),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }





// // Zaroori packages import karein
// import 'dart:convert';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/plan_expired_screen.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/services.dart';

// // Flutter/Project ke baaki imports
// import 'package:flutter/material.dart';
// import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/tv_show.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show_pak/tv_show_pak.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/manage_webseries.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/loading_indicator.dart';
// import 'package:provider/provider.dart';
// import 'components/home_screen_pages/banner_slider_screen/banner_slider_screen.dart';
// import 'components/home_screen_pages/movies_screen/movies.dart';
// import 'components/home_screen_pages/sub_live_screen/live_channel_language_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // State Variables
//   bool _isLoading = true; // Shuru mein loading state true rahegi

//   // NAYE STATE VARIABLES (CONTENT VISIBILITY KE LIYE)
//   // Inki default value false hai, API call ke baad yeh update honge.
//   bool _showMovies = false;
//   bool _showWebseries = false;
//   bool _showTvShows = false;
//   bool _showTvShowsPak = false;
//   bool _showSports = false;
//   bool _showReligious = false;
//   bool _showContentNetwork = false; // "HorzontalVod" ke liye (API key: content_network)

//   // Global Keys
//   final GlobalKey watchNowKey = GlobalKey();
//   final GlobalKey liveChannelLanguageKey = GlobalKey();
//   final GlobalKey subVodKey = GlobalKey();
//   final GlobalKey manageMoviesKey = GlobalKey();
//   final GlobalKey manageWebseriesKey = GlobalKey();
//   final GlobalKey tvShowsKey = GlobalKey();
//   final GlobalKey tvShowsPakKey = GlobalKey();
//   final GlobalKey sportsKey = GlobalKey();
//   final GlobalKey religiousChannelKey = GlobalKey();

//   // Focus Nodes
//   late FocusNode watchNowFocusNode;
//   late FocusNode firstSubVodFocusNode;
//   late FocusNode manageMoviesFocusNode;
//   late FocusNode tvShowsFocusNode;
//   late FocusNode sportsFocusNode;
//   late FocusNode manageWebseriesFocusNode;
//   late FocusNode subLiveFocusNode;

//   @override
//   void initState() {
//     super.initState();
//     // Focus nodes initialize karein
//     watchNowFocusNode = FocusNode();
//     firstSubVodFocusNode = FocusNode();
//     manageMoviesFocusNode = FocusNode();
//     tvShowsFocusNode = FocusNode();
//     sportsFocusNode = FocusNode();
//     manageWebseriesFocusNode = FocusNode();
//     subLiveFocusNode = FocusNode();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // API call karke plan ka status aur content visibility check karega
//       _checkPlanStatus();

//       // Provider setup
//       final focusProvider = context.read<FocusProvider>();
//       // ❗️ पुराने .set... मेथड्स की जगह नया .registerFocusNode मेथड
//       focusProvider.registerFocusNode('watchNow', watchNowFocusNode);
//       focusProvider.registerFocusNode('subVod', firstSubVodFocusNode);
//       focusProvider.registerFocusNode('manageMovies', manageMoviesFocusNode);
//       focusProvider.registerFocusNode('tvShows', tvShowsFocusNode);
//       // Element keys register karein
//       context.read<FocusProvider>().registerElementKey('watchNow', watchNowKey);
//       focusProvider.registerElementKey(
//           'liveChannelLanguage', liveChannelLanguageKey);
//       focusProvider.registerElementKey('subVod', subVodKey);
//       focusProvider.registerElementKey('manageMovies', manageMoviesKey);
//       focusProvider.registerElementKey('manageWebseries', manageWebseriesKey);
//       focusProvider.registerElementKey('tvShows', tvShowsKey);
//       focusProvider.registerElementKey('sports', sportsKey);
//       focusProvider.registerElementKey(
//           'religiousChannels', religiousChannelKey);
//       focusProvider.registerElementKey('tvShowPak', tvShowsPakKey);
//     });
//   }

//   // Naya UI wala Dialog function
//   void _showExpiryWarningDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.grey[850], // Dark theme ke liye
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           icon: const Icon(Icons.warning_amber_rounded,
//               color: Colors.amber, size: 48),
//           title: const Text(
//             'Plan Expiry Alert',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//           content: Text(
//             message,
//             textAlign: TextAlign.center,
//             style: const TextStyle(color: Colors.white70),
//           ),
//           actionsAlignment: MainAxisAlignment.center,
//           actions: <Widget>[
//             TextButton(
//               style: TextButton.styleFrom(
//                   backgroundColor: Colors.amber,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0))),
//               child: const Text(
//                 'O.K',
//                 style:
//                     TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Dialog band karein
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // PRODUCTION-READY API FUNCTION - UPDATED LOGIC KE SAATH
//   Future<void> _checkPlanStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? authKey = SessionManager.authKey;

//     if (authKey == null || authKey.isEmpty) {
//       print('Auth Key not found. Cannot check plan expiry.');
//       if (mounted) setState(() => _isLoading = false);
//       return;
//     }

//     try {
//       final response = await https.get(
//         Uri.parse(
//             'https://dashboard.cpplayers.com/public/api/v2/checkExpiryPlan'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'domain': 'coretechinfo.com',
//         },
//       ).timeout(const Duration(seconds: 20));

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final res = json.decode(response.body);

//         final bool planExpired = res['plan_expired'] ?? false;
//         final bool planWillExpire = res['plan_will_expire'] ?? false;
//         final String message = res['message'] ?? 'Unknown status';
//         // Domain content ko parse karein
//         final domainContent = res['domain_content'];

//         // Condition 1: Agar plan expire ho gaya hai
//         if (planExpired) {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) => PlanExpiredScreen(apiMessage: message),
//             ),
//           );
//         } else {
//           // Home screen dikhane se pehle visibility flags set karein
//           if (domainContent != null && domainContent is Map) {
//             setState(() {
//               // Har key ke liye check karein aur state update karein
//               // Agar API mein key maujood na ho to default 0 maanein (hide)
//               _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//               _showMovies = (domainContent['movies'] ?? 0) == 1;
//               _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//               _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//               _showTvShowsPak = (domainContent['tvshow_pak'] ?? 0) == 1;
//               _showSports = (domainContent['sports'] ?? 0) == 1;
//               _showReligious = (domainContent['religious'] ?? 0) == 1;
//             });
//           }

//           // Condition 2: Agar plan jald hi expire hone wala hai
//           if (planWillExpire) {
//             setState(() => _isLoading = false);
//             _showExpiryWarningDialog(message);
//           }
//           // Condition 3: Agar sab theek hai
//           else {
//             setState(() => _isLoading = false);
//           }
//         }
//       } else {
//         print('Server Error while checking plan: ${response.statusCode}');
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       print('Network Error or Timeout while checking plan: $e');
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   void dispose() {

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Jab tak API call chal rahi hai, loading indicator dikhao
//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(
//           child: CircularProgressIndicator(
//             color: Colors.white,
//           ),
//         ),
//       );
//     }

//     // Jab loading poori ho jaaye, tab asli UI dikhao
//     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//       Color backgroundColor = colorProvider.isItemFocused
//           ? colorProvider.dominantColor.withOpacity(0.2)
//           : cardColor;

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
//           backgroundColor: backgroundColor,
//           body: Container(
//             width: screenwdt,
//             height: screenhgt,
//             color: Colors.transparent,
//             child: SingleChildScrollView(
//               controller: context.read<FocusProvider>().scrollController,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Ye widgets hamesha dikhenge
//                   Container(
//                     height: screenhgt * 0.65,
//                     width: screenwdt,
//                     key: watchNowKey,
//                     child: BannerSlider(focusNode: watchNowFocusNode),
//                   ),
//                   Container(
//                     height: screenhgt * 0.38,
//                     key: liveChannelLanguageKey,
//                     child: const LiveChannelLanguageScreen(),
//                   ),

//                   // ---- SHARTIYA WIDGETS (CONDITIONAL WIDGETS) ----
//                   // Yahan se widgets tabhi dikhenge jab API se permission milegi

//                   // API Key: "content_network"
//                   if (_showContentNetwork)
//                     SizedBox(
//                       height: screenhgt * 0.38,
//                       key: subVodKey,
//                       child: const HorzontalVod(),
//                     ),

//                   // API Key: "movies"
//                   if (_showMovies)
//                     SizedBox(
//                       height: screenhgt * 0.38,
//                       key: manageMoviesKey,
//                       child: const MoviesScreen(),
//                     ),

//                   // API Key: "webseries"
//                   if (_showWebseries)
//                     SizedBox(
//                       height: screenhgt * 0.38,
//                       key: manageWebseriesKey,
//                       child: const ManageWebSeries(),
//                     ),

//                   // API Key: "tvshow"
//                   if (_showTvShows)
//                     SizedBox(
//                         height: screenhgt * 0.38,
//                         key: tvShowsKey,
//                         child: const ManageTvShows()),

//                   // API Key: "sports"
//                   if (_showSports)
//                     SizedBox(
//                         height: screenhgt * 0.38,
//                         child: sports(
//                           key: sportsKey,
//                         )),

//                   // API Key: "religious"
//                   if (_showReligious)
//                     SizedBox(
//                         height: screenhgt * 0.38,
//                         key: religiousChannelKey,
//                         child: const ManageReligiousShows()),

//                   // API Key: "tvshow_pak"
//                   if (_showTvShowsPak)
//                     SizedBox(
//                         height: screenhgt * 0.38,
//                         key: tvShowsPakKey,
//                         child: const TvShowPak()),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }







// Zaroori packages import karein
import 'dart:convert';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/plan_expired_screen.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

// Flutter/Project ke baaki imports
import 'package:flutter/material.dart';
import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/manage_tv_shows.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show_pak/tv_show_pak.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/manage_webseries.dart';
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'components/home_screen_pages/banner_slider_screen/banner_slider_screen.dart';
import 'components/home_screen_pages/movies_screen/movies.dart';
import 'components/home_screen_pages/sub_live_screen/live_channel_language_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State Variables
  bool _isLoading = true; // Shuru mein loading state true rahegi

  // NAYE STATE VARIABLES (CONTENT VISIBILITY KE LIYE)
  bool _showMovies = false;
  bool _showWebseries = false;
  bool _showTvShows = false;
  bool _showTvShowsPak = false;
  bool _showSports = false;
  bool _showReligious = false;
  bool _showContentNetwork = false; // "HorzontalVod" ke liye (API key: content_network)

  // Global Keys
  final GlobalKey watchNowKey = GlobalKey();
  final GlobalKey liveChannelLanguageKey = GlobalKey();
  final GlobalKey subVodKey = GlobalKey();
  final GlobalKey manageMoviesKey = GlobalKey();
  final GlobalKey manageWebseriesKey = GlobalKey();
  final GlobalKey tvShowsKey = GlobalKey();
  final GlobalKey tvShowsPakKey = GlobalKey();
  final GlobalKey sportsKey = GlobalKey();
  final GlobalKey religiousChannelKey = GlobalKey();

  // Focus Nodes
  late FocusNode watchNowFocusNode;
  late FocusNode firstSubVodFocusNode;
  late FocusNode manageMoviesFocusNode;
  late FocusNode tvShowsFocusNode;
  late FocusNode sportsFocusNode;
  late FocusNode manageWebseriesFocusNode;
  late FocusNode subLiveFocusNode;

  @override
  void initState() {
    super.initState();
    // Focus nodes initialize karein
    watchNowFocusNode = FocusNode();
    firstSubVodFocusNode = FocusNode();
    manageMoviesFocusNode = FocusNode();
    tvShowsFocusNode = FocusNode();
    sportsFocusNode = FocusNode();
    manageWebseriesFocusNode = FocusNode();
    subLiveFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // API call karke plan ka status aur content visibility check karega
      _checkPlanStatus();

      // Provider setup
      final focusProvider = context.read<FocusProvider>();
      // ❗️ Naya .registerFocusNode method
      focusProvider.registerFocusNode('watchNow', watchNowFocusNode);
      focusProvider.registerFocusNode('subVod', firstSubVodFocusNode);
      focusProvider.registerFocusNode('manageMovies', manageMoviesFocusNode);
      focusProvider.registerFocusNode('tvShows', tvShowsFocusNode);
      
      // (Baaqi focus nodes bhi register karein agar zaroorat ho)
      // focusProvider.registerFocusNode('sports', sportsFocusNode);
      // focusProvider.registerFocusNode('manageWebseries', manageWebseriesFocusNode);
      // focusProvider.registerFocusNode('subLive', subLiveFocusNode);

      // Element keys register karein
      // Yeh IDs FocusProvider ke _lockableIdentifiers se match honi chahiye
      focusProvider.registerElementKey('watchNow', watchNowKey);
      focusProvider.registerElementKey('liveChannelLanguage', liveChannelLanguageKey);
      focusProvider.registerElementKey('subVod', subVodKey);
      focusProvider.registerElementKey('manageMovies', manageMoviesKey);
      focusProvider.registerElementKey('manageWebseries', manageWebseriesKey);
      focusProvider.registerElementKey('tvShows', tvShowsKey);
      focusProvider.registerElementKey('sports', sportsKey);
      focusProvider.registerElementKey('religiousChannels', religiousChannelKey); // ID check karein
      focusProvider.registerElementKey('tvShowPak', tvShowsPakKey); // ID check karein
    });
  }

  // Naya UI wala Dialog function
  void _showExpiryWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850], // Dark theme ke liye
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          icon: const Icon(Icons.warning_amber_rounded,
              color: Colors.amber, size: 48),
          title: const Text(
            'Plan Expiry Alert',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0))),
              child: const Text(
                'O.K',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dialog band karein
              },
            ),
          ],
        );
      },
    );
  }

  // PRODUCTION-READY API FUNCTION
  Future<void> _checkPlanStatus() async {
    // final prefs = await SharedPreferences.getInstance();
    final String? authKey = SessionManager.authKey;

    if (authKey == null || authKey.isEmpty) {
      print('Auth Key not found. Cannot check plan expiry.');
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      var url = Uri.parse(SessionManager.baseUrl + 'checkExpiryPlan');

      final response = await https.get(url,
        // Uri.parse(
          // SessionManager.baseUrl + 'checkExpiryPlan' 
            // 'https://dashboard.cpplayers.com/public/api/v2/checkExpiryPlan'
            // ),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'domain': 'coretechinfo.com',
          'domain': SessionManager.savedDomain,
        },
      ).timeout(const Duration(seconds: 20));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final res = json.decode(response.body);

        final bool planExpired = res['plan_expired'] ?? false;
        final bool planWillExpire = res['plan_will_expire'] ?? false;
        final String message = res['message'] ?? 'Unknown status';
        final domainContent = res['domain_content'];

        // Condition 1: Agar plan expire ho gaya hai
        if (planExpired) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PlanExpiredScreen(apiMessage: message),
            ),
          );
        } else {
          // Home screen dikhane se pehle visibility flags set karein
          if (domainContent != null && domainContent is Map) {
            setState(() {
              _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
              _showMovies = (domainContent['movies'] ?? 0) == 1;
              _showWebseries = (domainContent['webseries'] ?? 0) == 1;
              _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
              _showTvShowsPak = (domainContent['tvshow_pak'] ?? 0) == 1;
              _showSports = (domainContent['sports'] ?? 0) == 1;
              _showReligious = (domainContent['religious'] ?? 0) == 1;
            });
          }

          // Condition 2: Agar plan jald hi expire hone wala hai
          if (planWillExpire) {
            setState(() => _isLoading = false);
            _showExpiryWarningDialog(message);
          }
          // Condition 3: Agar sab theek hai
          else {
            setState(() => _isLoading = false);
          }
        }
      } else {
        print('Server Error while checking plan: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Network Error or Timeout while checking plan: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    // --- MODIFIED ---
    // State mein banaye gaye sabhi FocusNodes ko dispose karein
    watchNowFocusNode.dispose();
    firstSubVodFocusNode.dispose();
    manageMoviesFocusNode.dispose();
    tvShowsFocusNode.dispose();
    sportsFocusNode.dispose();
    manageWebseriesFocusNode.dispose();
    subLiveFocusNode.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Jab tak API call chal rahi hai, loading indicator dikhao
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    // --- NAYA CODE ---
    // 1. Visible rows ki ek dynamic list banayein
    final List<String> visibleRows = [
      'watchNow', // Hamesha visible
      'liveChannelLanguage', // Hamesha visible
    ];

    // 2. Shart (condition) ke aadhar par baaki rows add karein
    if (_showContentNetwork) visibleRows.add('subVod');
    if (_showMovies) visibleRows.add('manageMovies');
    if (_showWebseries) visibleRows.add('manageWebseries');
    if (_showTvShows) visibleRows.add('tvShows');
    if (_showSports) visibleRows.add('sports');
    if (_showReligious) visibleRows.add('religiousChannels'); // ID match karein
    if (_showTvShowsPak) visibleRows.add('tvShowPak'); // ID match karein

    // 3. FocusProvider ko yeh list update karne ko kahein
    // 'read' ka istemal karein kyunki humein sirf function call karna hai.
    context.read<FocusProvider>().updateVisibleRowIdentifiers(visibleRows);
    // --- NAYA CODE KHATAM ---


    // Jab loading poori ho jaaye, tab asli UI dikhao
    return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
      Color backgroundColor = colorProvider.isItemFocused
          ? colorProvider.dominantColor.withOpacity(0.2)
          : cardColor;

      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (context, _, __) => const ExitConfirmationScreen(
                  isFromBackButton: true,
                ),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: backgroundColor,
          body: Container(
            width: screenwdt,
            height: screenhgt,
            color: Colors.transparent,
            child: SingleChildScrollView(
              controller: context.read<FocusProvider>().scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ye widgets hamesha dikhenge
                  Container(
                    height: screenhgt * 0.65,
                    width: screenwdt,
                    key: watchNowKey,
                    child: BannerSlider(focusNode: watchNowFocusNode),
                  ),
                  Container(
                    height: screenhgt * 0.38,
                    key: liveChannelLanguageKey,
                    child: const LiveChannelLanguageScreen(),
                  ),

                  // ---- SHARTIYA WIDGETS (CONDITIONAL WIDGETS) ----
                  
                  // API Key: "content_network"
                  if (_showContentNetwork)
                    SizedBox(
                      height: screenhgt * 0.38,
                      key: subVodKey,
                      child: const HorzontalVod(),
                    ),

                  // API Key: "movies"
                  if (_showMovies)
                    SizedBox(
                      height: screenhgt * 0.38,
                      key: manageMoviesKey,
                      child: const MoviesScreen(),
                    ),

                  // API Key: "webseries"
                  if (_showWebseries)
                    SizedBox(
                      height: screenhgt * 0.38,
                      key: manageWebseriesKey,
                      child: const ManageWebSeries(),
                    ),

                  // API Key: "tvshow"
                  if (_showTvShows)
                    SizedBox(
                        height: screenhgt * 0.38,
                        key: tvShowsKey,
                        child: const ManageTvShows()),

                  // API Key: "sports"
                  if (_showSports)
                    SizedBox(
                        height: screenhgt * 0.38,
                        // child: SportsCategory(
                        //   key: sportsKey,
                        // )),
                        child: ManageSports(
                          key: sportsKey,
                        )),

                  // API Key: "religious"
                  if (_showReligious)
                    SizedBox(
                        height: screenhgt * 0.38,
                        key: religiousChannelKey,
                        child: const ManageReligiousShows()),

                  // API Key: "tvshow_pak"
                  if (_showTvShowsPak)
                    SizedBox(
                        height: screenhgt * 0.38,
                        key: tvShowsPakKey,
                        child: const TvShowsPak()),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}



