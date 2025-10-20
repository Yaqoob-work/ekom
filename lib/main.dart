// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:dio/dio.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:open_filex/open_filex.dart';
// // import 'package:package_info_plus/package_info_plus.dart';
// // import 'package:http/http.dart' as https;
// // import 'package:path_provider/path_provider.dart';
// // import 'menu/top_navigation_bar.dart';
// // import 'menu_screens/home_sub_screen/sub_vod.dart';
// // import 'menu_screens/live_screen.dart';
// // import 'menu_screens/home_screen.dart';
// // import 'menu_screens/notification_screen.dart';
// // import 'menu_screens/search_screen.dart';
// // import 'widgets/small_widgets/loading_indicator.dart';

// // // Global navigator key
// // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// // class MyHttpOverrides extends HttpOverrides {
// //   @override
// //   HttpClient createHttpClient(SecurityContext? context) {
// //     return super.createHttpClient(context)
// //       ..badCertificateCallback =
// //           (X509Certificate cert, String host, int port) => true;
// //   }
// // }

// // void main() {
// //   HttpOverrides.global = MyHttpOverrides();
// //   runApp(MyApp());
// // }

// // var highlightColor;
// // var cardColor;
// // var hintColor;
// // var borderColor;

// // var screenhgt;
// // var screenwdt;
// // var screensz;
// // var nametextsz;
// // var menutextsz;
// // var Headingtextsz;

// // var localImage;

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     highlightColor = Colors.blue;
// //     cardColor = const Color.fromARGB(255, 8, 1, 34);
// //     hintColor = Colors.white;
// //     borderColor = const Color.fromARGB(255, 247, 6, 118);
// //     localImage = Image.asset(
// //       'assets/logo.png',
// //       fit: BoxFit.fill,
// //     );

// //     return MaterialApp(
// //       navigatorKey: navigatorKey,
// //       debugShowCheckedModeBanner: false,
// //       initialRoute: '/',
// //       routes: {
// //         '/': (context) => MyHome(),
// //         '/notification': (context) => NotificationScreen(),
// //         '/category': (context) => HomeScreen(),
// //         '/search': (context) => SearchScreen(),
// //         '/vod': (context) => VOD(),
// //         '/live': (context) => LiveScreen(),
// //       },
// //     );
// //   }
// // }

// // class MyHome extends StatefulWidget {
// //   @override
// //   _MyHomeState createState() => _MyHomeState();
// // }

// // class _MyHomeState extends State<MyHome> {
// //   int _selectedPage = 0;
// //   late PageController _pageController;
// //   bool _tvenableAll = false;
// //   String _currentVersion = "";
// //   final ApkUpdater _apkUpdater = ApkUpdater();
// //   bool _isLoading = true;  // Loading state variable

// //   @override
// //   void initState() {
// //     super.initState();
// //     _pageController = PageController(initialPage: _selectedPage);
// //     _getAppVersion();
// //     _showHomePageFirst();  // Show Home page first
// //   }

// //   @override
// //   void dispose() {
// //     _pageController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _getAppVersion() async {
// //     PackageInfo packageInfo = await PackageInfo.fromPlatform();
// //     if (mounted) {
// //       setState(() {
// //         _currentVersion = packageInfo.version;
// //       });
// //     }
// //   }

// //   // Show Home page first and after a delay, check for update
// //   Future<void> _showHomePageFirst() async {
// //     // Show home page first and delay the update check
// //     // await Future.delayed(Duration(seconds: 3));  // 3 second delay before checking for update

// //     _fetchTvenableAllStatus();  // Check for update after delay
// //   }

// // //   Future<void> _fetchTvenableAllStatus() async {
// // //   try {
// // //     final response = await https.get(
// // //       Uri.parse('https://api.ekomflix.com/android/getSettings'),
// // //       headers: {
// // //         'x-api-key': 'vLQTuPZUxktl5mVW',
// // //       },
// // //     );

// // //     if (response.statusCode == 200) {
// // //       final data = jsonDecode(response.body);
// // //       String serverVersion = data['version'];
// // //       String releaseNotes = data['releaseNotes']; // Extract releaseNotes

// // //       print('Current Version: $_currentVersion');
// // //       print('Server Version: $serverVersion');

// // //       if (_isVersionNewer(serverVersion, _currentVersion)) {
// // //         // Delay the navigation to ensure context is available
// // //         WidgetsBinding.instance.addPostFrameCallback((_) {
// // //           String apkUrl = data['apkUrl'];
// // //           Navigator.pushReplacement(
// // //             context,
// // //             MaterialPageRoute(
// // //               builder: (context) => UpdatePage(
// // //                 apkUrl: apkUrl,
// // //                 serverVersion: serverVersion,
// // //                 releaseNotes: releaseNotes, // Pass releaseNotes to UpdatePage
// // //               ),
// // //             ),
// // //           );
// // //         });
// // //       } else {
// // //         if (mounted) {
// // //           setState(() {
// // //             _tvenableAll = data['tvenableAll'] == 1;
// // //           });
// // //         }
// // //       }
// // //     } else {
// // //       print('Failed to load settings');
// // //     }
// // //   } catch (e) {
// // //     print('Error: $e');
// // //   }
// // // }

// //   Future<void> _fetchTvenableAllStatus() async {
// //     try {
// //       final response = await https.get(
// //         Uri.parse('https://api.ekomflix.com/android/getSettings'),
// //         headers: {
// //           'x-api-key': 'vLQTuPZUxktl5mVW',
// //         },
// //       );

// //       if (response.statusCode == 200) {
// //         final data = jsonDecode(response.body);
// //         String serverVersion = data['version'];
// //       String releaseNotes = data['releaseNotes']; // Extract releaseNotes

// //         // print('Current Version: $_currentVersion');
// //         // print('Server Version: $serverVersion');

// //         if (_isVersionNewer(serverVersion, _currentVersion)) {
// //           String apkUrl = data['apkUrl'];

// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(builder: (context) => UpdatePage(
// //                 apkUrl: apkUrl,
// //                 serverVersion: serverVersion,
// //                 releaseNotes: releaseNotes, // Pass releaseNotes to UpdatePage
// //               ),)
// //           );
// //         } else {
// //           if (mounted) {
// //             setState(() {
// //               _tvenableAll = data['tvenableAll'] == 1;
// //               _isLoading = false;
// //             });
// //           }
// //         }
// //       } else {
// //         print('Failed to load settings');
// //               _isLoading = false;

// //       }
// //     } catch (e) {
// //       print('Error: $e');
// //               _isLoading = false;

// //     }
// //   }

// //   bool _isVersionNewer(String serverVersion, String currentVersion) {
// //     List<String> serverParts = serverVersion.split('.');
// //     List<String> currentParts = currentVersion.split('.');

// //     int length = serverParts.length > currentParts.length
// //         ? serverParts.length
// //         : currentParts.length;

// //     for (int i = 0; i < length; i++) {
// //       int serverPart = i < serverParts.length ? int.parse(serverParts[i]) : 0;
// //       int currentPart = i < currentParts.length ? int.parse(currentParts[i]) : 0;

// //       if (serverPart > currentPart) {
// //         return true;
// //       } else if (serverPart < currentPart) {
// //         return false;
// //       }
// //     }
// //     return false;
// //   }

// //   void _onPageSelected(int index) {
// //     if (mounted) {
// //       setState(() {
// //         _selectedPage = index;
// //       });
// //     }
// //     _pageController.jumpToPage(index);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //         if (_isLoading) {
// //       return Scaffold(
// //         backgroundColor: Colors.black,
// //         body: Center(
// //           child:LoadingIndicator(),
// //         ),
// //       );  // Show loading indicator while fetching data
// //     }
// //     List<Widget> pages = [
// //       HomeScreen(),
// //       VOD(),
// //       LiveScreen(),
// //       SearchScreen(),
// //       NotificationScreen(),
// //     ];

// //     return SafeArea(

// //       child: Scaffold(

// //         body: Column(
// //           children: [
// //             TopNavigationBar(
// //               selectedPage: _selectedPage,
// //               onPageSelected: _onPageSelected,
// //               tvenableAll: _tvenableAll,
// //             ),
// //             Expanded(
// //               child: PageView(
// //                 controller: _pageController,
// //                 onPageChanged: (index) {
// //                   if (mounted) {
// //                     setState(() {
// //                       _selectedPage = index;
// //                     });
// //                   }
// //                 },
// //                 children: pages,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class ApkUpdater {
// //   final Dio _dio = Dio();

// //   Future<void> downloadAndInstallApk(
// //     String apkUrl,
// //     String fileName,
// //     Function(double) progressCallback,
// //   ) async {
// //     Directory directory = await _getDownloadPath();
// //     String savePath = '${directory.path}/$fileName';
// //     print("APK save path: $savePath");

// //     try {
// //       await _dio.download(
// //         apkUrl,
// //         savePath,
// //         onReceiveProgress: (received, total) {
// //           double progress = 0.0;
// //           if (received != null && total != null && total > 0) {
// //             progress = received / total;
// //           }
// //           progressCallback(progress);
// //           // print('Download progress: ${(progress * 10).toStringAsFixed(0)}%');
// //         },
// //       );

// //       if (await File(savePath).exists()) {
// //         await _installApk(savePath);
// //       } else {
// //         print("APK file does not exist at $savePath");
// //       }
// //     } catch (e) {
// //       print("Error during APK download/install: $e");
// //       progressCallback(-1.0);
// //     }
// //   }

// //   Future<void> _installApk(String filePath) async {
// //     if (Platform.isAndroid) {
// //       await OpenFilex.open(filePath);
// //     }
// //   }

// //   Future<Directory> _getDownloadPath() async {
// //     return await getApplicationDocumentsDirectory();
// //   }
// // }

// // class UpdatePage extends StatefulWidget {
// //   final String apkUrl;
// //   final String serverVersion;
// //   final String releaseNotes;

// //   UpdatePage({
// //     required this.apkUrl,
// //     required this.serverVersion,
// //     required this.releaseNotes,
// //   });

// //   @override
// //   _UpdatePageState createState() => _UpdatePageState();
// // }

// // class _UpdatePageState extends State<UpdatePage> {
// //   final ApkUpdater apkUpdater = ApkUpdater();

// //   late FocusNode updateButtonFocusNode;
// //   late FocusNode cancelButtonFocusNode;

// //   FocusNode? currentFocusNode;

// //   double _downloadProgress = 0.0;
// //   bool _isDownloading = false;

// //   Color backgroundColor = cardColor;

// //   @override
// //   void initState() {
// //     super.initState();

// //     updateButtonFocusNode = FocusNode();
// //     cancelButtonFocusNode = FocusNode();

// //     updateButtonFocusNode.addListener(_onFocusChange);
// //     cancelButtonFocusNode.addListener(_onFocusChange);

// //     currentFocusNode = updateButtonFocusNode;

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (mounted) {
// //         FocusScope.of(context).requestFocus(updateButtonFocusNode);
// //       }
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     updateButtonFocusNode.removeListener(_onFocusChange);
// //     cancelButtonFocusNode.removeListener(_onFocusChange);
// //     updateButtonFocusNode.dispose();
// //     cancelButtonFocusNode.dispose();
// //     super.dispose();
// //   }

// //   void _onFocusChange() {
// //     if (mounted) {
// //       setState(() {
// //         if (updateButtonFocusNode.hasFocus) {
// //           // backgroundColor = Colors.blueGrey;
// //         } else if (cancelButtonFocusNode.hasFocus) {
// //           // backgroundColor = Colors.grey;
// //         } else {
// //           // backgroundColor = cardColor;
// //         }
// //       });
// //     }
// //   }

// //   bool _handleKeyEvent(FocusNode node, RawKeyEvent event) {
// //     if (event is RawKeyDownEvent) {
// //       if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
// //           event.logicalKey == LogicalKeyboardKey.arrowUp ||
// //           event.logicalKey == LogicalKeyboardKey.arrowLeft ||
// //           event.logicalKey == LogicalKeyboardKey.arrowRight) {
// //         _moveFocus(event.logicalKey);
// //         return true;
// //       } else if (event.logicalKey == LogicalKeyboardKey.select ||
// //           event.logicalKey == LogicalKeyboardKey.enter) {
// //         _activateButton(node);
// //         return true;
// //       }
// //     }
// //     return false;
// //   }

// //   void _moveFocus(LogicalKeyboardKey key) {
// //     if (mounted) {
// //       setState(() {
// //         if (currentFocusNode == updateButtonFocusNode) {
// //           if (key == LogicalKeyboardKey.arrowRight ||
// //               key == LogicalKeyboardKey.arrowDown) {
// //             // currentFocusNode = cancelButtonFocusNode;
// //             currentFocusNode = updateButtonFocusNode;

// //           }
// //         } else if (currentFocusNode == cancelButtonFocusNode) {
// //           if (key == LogicalKeyboardKey.arrowLeft ||
// //               key == LogicalKeyboardKey.arrowUp) {
// //             currentFocusNode = updateButtonFocusNode;
// //           }
// //         }
// //         FocusScope.of(context).requestFocus(currentFocusNode);
// //       });
// //     }
// //   }

// //   void _activateButton(FocusNode node) {
// //     if (node == updateButtonFocusNode) {
// //       _startUpdate();
// //     } else if (node == cancelButtonFocusNode) {
// //       _cancelUpdate();
// //     }
// //   }

// //   void _startUpdate() async {
// //     String fileName = 'update.apk';
// //     setState(() {
// //       _isDownloading = true;
// //       _downloadProgress = 0.0;
// //     });
// //     await apkUpdater.downloadAndInstallApk(widget.apkUrl, fileName, (progress) {
// //       if (mounted) {
// //         setState(() {
// //           _downloadProgress = progress;
// //         });
// //       }
// //     });
// //     if (mounted) {
// //       setState(() {
// //         _isDownloading = false;
// //       });
// //     }
// //   }

// //   void _cancelUpdate() {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(builder: (context) => MyHome()),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: cardColor ,
// //       body: RawKeyboardListener(
// //         focusNode: FocusNode(),
// //         onKey: (event) {
// //           _handleKeyEvent(currentFocusNode!, event);
// //         },
// //         child: Center(
// //           child: SingleChildScrollView(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               crossAxisAlignment: CrossAxisAlignment.center ,
// //               children: [
// //                 const Text(
// //                   'New Update Available',
// //                   style: TextStyle(
// //                     fontSize: 36,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20),
// //                 Text(
// //                   'Version ${widget.serverVersion}',
// //                   style: const TextStyle(
// //                     fontSize: 24,
// //                     color: Colors.white70,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20),
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
// //                   child: Text(
// //                     widget.releaseNotes,
// //                     style: const TextStyle(
// //                       fontSize: 20,
// //                       color: Colors.white,
// //                     ),
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 50),
// //                 if (_isDownloading)
// //                   Column(
// //                     children: [
// //                       Row(
// //                         children: [
// //                           Expanded(flex:1,child:  Text('')),
// //                           Expanded(flex:10,child:LinearProgressIndicator(
// //                             value: _downloadProgress,
// //                             backgroundColor: Colors.grey,
// //                             valueColor:
// //                                 const AlwaysStoppedAnimation<Color>(Colors.blue),
// //                           ), ),
// //                           Expanded(flex:1,child: Text('')),

// //                         ],
// //                       ),
// //                       const SizedBox(height: 10),
// //                       Text(
// //                         'Downloading... ${(_downloadProgress * 100).toStringAsFixed(0)}%',
// //                         style: const TextStyle(
// //                           fontSize: 20,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                     ],
// //                   )
// //                 else
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Focus(
// //                         focusNode: updateButtonFocusNode,
// //                         child: GestureDetector(
// //                           onTap: _startUpdate,
// //                           child: Container(
// //                             width: 200,
// //                             height: 60,
// //                             decoration: BoxDecoration(
// //                               color: updateButtonFocusNode.hasFocus
// //                                   ? Colors.black
// //                                   : Colors.grey,
// //                               borderRadius: BorderRadius.circular(8),
// //                             ),
// //                             alignment: Alignment.center,
// //                             child:  Text(
// //                               'Update Now',
// //                               style: TextStyle(
// //                                 fontSize: 24,
// //                                color:  updateButtonFocusNode.hasFocus
// //                                   ? Colors.green
// //                                   : Colors.black,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       // const SizedBox(width: 30),
// //                       // Focus(
// //                       //   focusNode: cancelButtonFocusNode,
// //                       //   child: GestureDetector(
// //                       //     onTap: _cancelUpdate,
// //                       //     child: Container(
// //                       //       width: 200,
// //                       //       height: 60,
// //                       //       decoration: BoxDecoration(
// //                       //         color: cancelButtonFocusNode.hasFocus
// //                       //             ? Colors.black
// //                       //             : Colors.grey,
// //                       //         borderRadius: BorderRadius.circular(8),
// //                       //       ),
// //                       //       alignment: Alignment.center,
// //                       //       child:  Text(
// //                       //         'Cancel',
// //                       //         style: TextStyle(
// //                       //           fontSize: 24,
// //                       //           color: cancelButtonFocusNode.hasFocus
// //                       //             ? Colors.red
// //                       //             : Colors.black,
// //                       //         ),
// //                       //       ),
// //                       //     ),
// //                       //   ),
// //                       // ),
// //                     ],
// //                   ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:mobi_tv_entertainment/home_screen_pages/home_screen.dart';
// // import 'package:mobi_tv_entertainment/menu_screens/youtube_search_screen.dart';
// // import 'package:mobi_tv_entertainment/menu_screens/search_screen.dart';
// // import 'package:mobi_tv_entertainment/menu_screens/live_screen.dart';
// // import 'package:http/http.dart' as https;
// // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// // import 'package:mobi_tv_entertainment/provider/shared_data_provider.dart';
// // import 'package:package_info_plus/package_info_plus.dart';
// // import 'package:provider/provider.dart';
// // import 'package:url_launcher/url_launcher.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:device_info_plus/device_info_plus.dart';
// // import 'menu/top_navigation_bar.dart';
// // import 'home_screen_pages/sub_vod_screen/sub_vod.dart';

// // // Global variable for authentication key
// // String globalAuthKey = '';

// // class MyHttpOverrides extends HttpOverrides {
// //   @override
// //   HttpClient createHttpClient(SecurityContext? context) {
// //     return super.createHttpClient(context)
// //       ..badCertificateCallback =
// //           (X509Certificate cert, String host, int port) => true;
// //   }
// // }

// // void main() {
// //   HttpOverrides.global = MyHttpOverrides();
// //   runApp(
// //     MultiProvider(
// //       providers: [
// //         ChangeNotifierProvider(create: (_) => ColorProvider()),
// //         ChangeNotifierProvider(create: (_) => FocusProvider()),
// //         ChangeNotifierProvider(create: (_) => SharedDataProvider()),
// //         // ChangeNotifierProvider(create: (_) => MusicProvider()),
// //       ],
// //       child: MyApp(),
// //     ),
// //   );
// // }

// // String baseUrl = 'https://dashboard.cpplayers.com/public/api/';
// // var highlightColor;
// // var cardColor;
// // var hintColor;
// // var borderColor;

// // var screenhgt;
// // var screenwdt;
// // var screensz;
// // var nametextsz;
// // var menutextsz;
// // var minitextsz;
// // var Headingtextsz;

// // var localImage;

// // class MyApp extends StatefulWidget {
// //   @override
// //   _MyAppState createState() => _MyAppState();
// // }

// // class _MyAppState extends State<MyApp> {
// //   @override
// //   void initState() {
// //     super.initState();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     screenhgt = MediaQuery.of(context).size.height;
// //     screenwdt = MediaQuery.of(context).size.width;
// //     screensz = MediaQuery.of(context).size;
// //     nametextsz = MediaQuery.of(context).size.width / 60.0;
// //     menutextsz = MediaQuery.of(context).size.width / 70;
// //     minitextsz = MediaQuery.of(context).size.width / 80;
// //     Headingtextsz = MediaQuery.of(context).size.width / 50;
// //     highlightColor = Colors.blue;
// //     cardColor = const Color.fromARGB(200, 0, 0, 0).withOpacity(0.7);
// //     hintColor = Colors.white;
// //     borderColor = Color.fromARGB(255, 247, 6, 118);
// //     localImage = Image.asset(
// //       'assets/logo.png',
// //       fit: BoxFit.fill,
// //     );

// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: SplashScreen(), // Start with splash screen to check login status
// //       routes: {
// //         '/mainscreen': (context) => HomeScreen(),
// //         '/search': (context) => SearchScreen(),
// //         '/vod': (context) => VOD(),
// //         '/live': (context) => LiveScreen(),
// //         '/home': (context) => MyHome(),
// //         '/login': (context) => LoginScreen(),
// //       },
// //     );
// //   }
// // }

// // class SplashScreen extends StatefulWidget {
// //   @override
// //   _SplashScreenState createState() => _SplashScreenState();
// // }

// // class _SplashScreenState extends State<SplashScreen> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     _checkLoginStatus();
// //   }

// //   Future<void> _checkLoginStatus() async {
// //     // Show splash for at least 2 seconds
// //     await Future.delayed(Duration(seconds: 2));

// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
// //     String? authKey = prefs.getString('result_auth_key');
// //     String? userData = prefs.getString('user_data');

// //     if (isLoggedIn && authKey != null && userData != null) {
// //       // User is already logged in, go to main app
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (context) => MyHome()),
// //       );
// //     } else {
// //       // User not logged in, go to login screen
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (context) => LoginScreen()),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: cardColor,
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             // Logo
// //             Container(
// //               width: 150,
// //               height: 150,
// //               child: localImage,
// //             ),
// //             SizedBox(height: 30),
// //             // Loading indicator
// //             CircularProgressIndicator(
// //               valueColor: AlwaysStoppedAnimation<Color>(highlightColor),
// //             ),
// //             SizedBox(height: 20),
// //             Text(
// //               'Loading...',
// //               style: TextStyle(
// //                 color: hintColor,
// //                 fontSize: nametextsz,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class LoginScreen extends StatefulWidget {
// //   @override
// //   _LoginScreenState createState() => _LoginScreenState();
// // }

// // class _LoginScreenState extends State<LoginScreen> {
// //   final TextEditingController _pinController = TextEditingController();
// //   bool _isLoading = false;
// //   String _errorMessage = '';
// //   String _deviceSerial = '';
// //   late FocusNode _pinFocusNode;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _pinFocusNode = FocusNode();
// //     _loadDeviceSerial();
// //         Future.delayed(Duration(milliseconds: 100), () {
// //       if (mounted) _pinFocusNode.requestFocus();
// //     });
// //   }

// //   Future<void> _loadDeviceSerial() async {
// //     String serial = await _getDeviceSerialNumber();
// //     setState(() {
// //       _deviceSerial = serial;
// //     });
// //   }

// //   Future<String> _getDeviceSerialNumber() async {
// //     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
// //     String serialNumber = '';

// //     try {
// //       if (Platform.isAndroid) {
// //         AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
// //         serialNumber = androidInfo.id; // Using Android ID as serial number
// //       } else if (Platform.isIOS) {
// //         IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
// //         serialNumber = iosInfo.identifierForVendor ?? '';
// //       }
// //     } catch (e) {
// //       serialNumber = '123456789'; // Fallback serial number
// //     }

// //     return serialNumber;
// //   }

// // //   // Global auth key ko properly load karne ke liye yeh function replace karein
// // // Future<void> _loadGlobalAuthKey() async {
// // //   SharedPreferences prefs = await SharedPreferences.getInstance();
// // //   String? authKey = prefs.getString('result_auth_key');

// // //   print('🔑 Checking auth key in SharedPreferences...');
// // //   print('🔑 Found auth key: $authKey');

// // //   if (authKey != null && authKey.isNotEmpty) {
// // //     globalAuthKey = authKey; // Global variable set karein
// // //     print('✅ Global auth key loaded successfully: $globalAuthKey');
// // //   } else {
// // //     print('❌ No auth key found in SharedPreferences');

// // //     // Debug: Check all keys in SharedPreferences
// // //     Set<String> allKeys = prefs.getKeys();
// // //     print('🔍 All SharedPreferences keys: $allKeys');

// // //     // Check for alternative key names
// // //     String? altKey1 = prefs.getString('result_result_auth_key');
// // //     String? altKey2 = prefs.getString('user_result_auth_key');
// // //     String? altKey3 = prefs.getString('api_key');

// // //     print('🔍 Alternative keys:');
// // //     print('  result_result_auth_key: $altKey1');
// // //     print('  user_result_auth_key: $altKey2');
// // //     print('  api_key: $altKey3');

// // //     if (altKey1 != null) {
// // //       globalAuthKey = altKey1;
// // //       print('✅ Using alternative auth key: $globalAuthKey');
// // //     }
// // //   }
// // // }

// // // Login function mein yeh changes karein (main.dart mein)
// // Future<void> _login() async {
// //   if (_pinController.text.isEmpty) {
// //     setState(() {
// //       _errorMessage = 'Please enter your PIN';
// //     });
// //     return;
// //   }

// //   setState(() {
// //     _isLoading = true;
// //     _errorMessage = '';
// //   });

// //   try {
// //     String serialNumber = await _getDeviceSerialNumber();

// //     final response = await https.post(
// //       Uri.parse('https://dashboard.cpplayers.com/api/login'),
// //       headers: {
// //         'Content-Type': 'application/json',
// //       },
// //       body: jsonEncode({
// //         'token': '',
// //         'mac_address': serialNumber,
// //         'login_pin': _pinController.text,
// //       }),
// //     );

// //     print('🌐 Login API Response: ${response.body}');
// //     final data = jsonDecode(response.body);

// //     if (data['status'] == true) {
// //       String authKey = data['result_result_auth_key'];
// //       print('✅ Login successful, received auth key: $authKey');

// //       // Save auth data
// //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //       await prefs.setString('result_auth_key', authKey);
// //       await prefs.setString('user_data', jsonEncode(data['data']));
// //       await prefs.setString('user_pin', _pinController.text);
// //       await prefs.setString('device_serial', serialNumber);
// //       await prefs.setBool('is_logged_in', true);
// //       await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);

// //       // Set global variable immediately
// //       globalAuthKey = authKey;
// //       print('✅ Global auth key set: $globalAuthKey');

// //       // Verify that it's saved correctly
// //       String? savedKey = prefs.getString('result_auth_key');
// //       print('✅ Verified saved auth key: $savedKey');

// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (context) => MyHome()),
// //       );
// //     } else {
// //       setState(() {
// //         _errorMessage = data['msg'] ?? 'Login failed';
// //       });
// //     }
// //   } catch (e) {
// //     print('❌ Login error: $e');
// //     setState(() {
// //       _errorMessage = 'Network error. Please try again.';
// //     });
// //   } finally {
// //     setState(() {
// //       _isLoading = false;
// //     });
// //   }
// // }

// //   // String globalAuthKey = '';

// //   // Future<void> _login() async {
// //   //   if (_pinController.text.isEmpty) {
// //   //     setState(() {
// //   //       _errorMessage = 'Please enter your PIN';
// //   //     });
// //   //     return;
// //   //   }

// //   //   setState(() {
// //   //     _isLoading = true;
// //   //     _errorMessage = '';
// //   //   });

// //   //   try {
// //   //     String serialNumber = await _getDeviceSerialNumber();

// //   //     final response = await https.post(
// //   //       Uri.parse('https://dashboard.cpplayers.com/api/login'),
// //   //       headers: {
// //   //         'Content-Type': 'application/json',
// //   //       },
// //   //       body: jsonEncode({
// //   //         'token': '',
// //   //         'mac_address': serialNumber,
// //   //         'login_pin': _pinController.text,
// //   //       }),
// //   //     );

// //   //     final data = jsonDecode(response.body);

// //   //     if (data['status'] == true) {

// //   //       globalAuthKey = data['result_result_auth_key'];
// //   //       // Login successful, save auth data and navigate to main app
// //   //       SharedPreferences prefs = await SharedPreferences.getInstance();
// //   //       await prefs.setString('result_auth_key', data['result_result_auth_key']);
// //   //       await prefs.setString('user_data', jsonEncode(data['data']));
// //   //       await prefs.setString('user_pin', _pinController.text); // Save PIN for future use
// //   //       await prefs.setString('device_serial', serialNumber); // Save device serial
// //   //       await prefs.setBool('is_logged_in', true);
// //   //       await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);

// //   //       Navigator.pushReplacement(
// //   //         context,
// //   //         MaterialPageRoute(builder: (context) => MyHome()),
// //   //       );
// //   //     } else {
// //   //       setState(() {
// //   //         _errorMessage = data['msg'] ?? 'Login failed';
// //   //       });
// //   //     }
// //   //   } catch (e) {
// //   //     setState(() {
// //   //       _errorMessage = 'Network error. Please try again.';
// //   //     });
// //   //   } finally {
// //   //     setState(() {
// //   //       _isLoading = false;
// //   //     });
// //   //   }
// //   // }

// //   Future<bool> _isAlreadyLoggedIn() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     return prefs.getBool('is_logged_in') ?? false;
// //   }

// //   Future<void> _logout() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.clear(); // Clear all stored data
// //     setState(() {
// //       _errorMessage = 'Previous session cleared. Please login again.';
// //     });
// //   }

// //   @override
// // Widget build(BuildContext context) {
// //   return Scaffold(
// //     backgroundColor: cardColor,
// //     resizeToAvoidBottomInset: true, // Ensure body resizes on keyboard open
// //     body: SafeArea(
// //       child: Center(
// //         child: SingleChildScrollView( // Prevent overflow
// //           padding: EdgeInsets.all(20),
// //           child: Container(
// //             margin: EdgeInsets.symmetric(horizontal: 20),
// //             decoration: BoxDecoration(
// //               color: cardColor,
// //               borderRadius: BorderRadius.circular(10),
// //               border: Border.all(color: borderColor, width: 2),
// //             ),
// //             child: Padding(
// //               padding: const EdgeInsets.all(20.0),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   SizedBox(height: 20),
// //                   Text(
// //                     'Enter PIN to Continue',
// //                     style: TextStyle(
// //                       color: hintColor,
// //                       fontSize: Headingtextsz,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   SizedBox(height: 30),
// //                   Container(
// //                     width: double.infinity,
// //                     padding: EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey.withOpacity(0.2),
// //                       borderRadius: BorderRadius.circular(8),
// //                       border: Border.all(color: borderColor.withOpacity(0.5), width: 1),
// //                     ),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           'Device Serial Number:',
// //                           style: TextStyle(
// //                             color: hintColor.withOpacity(0.7),
// //                             fontSize: minitextsz,
// //                           ),
// //                         ),
// //                         SizedBox(height: 5),
// //                         Text(
// //                           _deviceSerial.isEmpty ? 'Loading...' : _deviceSerial,
// //                           style: TextStyle(
// //                             color: hintColor,
// //                             fontSize: nametextsz,
// //                             fontWeight: FontWeight.bold,
// //                             letterSpacing: 1,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: 20),
// //                   TextField(
// //                     controller: _pinController,
// //                     focusNode: _pinFocusNode,
// //                     keyboardType: TextInputType.number,
// //                     obscureText: true,
// //                     maxLength: 10,
// //                     style: TextStyle(
// //                       color: hintColor,
// //                       fontSize: nametextsz,
// //                       letterSpacing: 2,
// //                     ),
// //                     decoration: InputDecoration(
// //                       hintText: 'Enter your PIN',
// //                       hintStyle: TextStyle(color: hintColor.withOpacity(0.7)),
// //                       enabledBorder: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                         borderSide: BorderSide(color: borderColor, width: 1),
// //                       ),
// //                       focusedBorder: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                         borderSide: BorderSide(color: highlightColor, width: 2),
// //                       ),
// //                       counterText: '',
// //                     ),
// //                     onSubmitted: (value) => _login(),
// //                   ),
// //                   SizedBox(height: 20),
// //                   if (_errorMessage.isNotEmpty)
// //                     Container(
// //                       padding: EdgeInsets.all(10),
// //                       margin: EdgeInsets.only(bottom: 20),
// //                       decoration: BoxDecoration(
// //                         color: Colors.red.withOpacity(0.2),
// //                         borderRadius: BorderRadius.circular(5),
// //                         border: Border.all(color: Colors.red, width: 1),
// //                       ),
// //                       child: Text(
// //                         _errorMessage,
// //                         style: TextStyle(
// //                           color: Colors.red,
// //                           fontSize: minitextsz,
// //                         ),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                     ),
// //                   SizedBox(
// //                     width: double.infinity,
// //                     height: 50,
// //                     child: ElevatedButton(
// //                       onPressed: _isLoading ? null : _login,
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: highlightColor,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                       ),
// //                       child: _isLoading
// //                           ? CircularProgressIndicator(
// //                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //                             )
// //                           : Text(
// //                               'LOGIN',
// //                               style: TextStyle(
// //                                 color: Colors.white,
// //                                 fontSize: nametextsz,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                     ),
// //                   ),
// //                   SizedBox(height: 20),
// //                   FutureBuilder<bool>(
// //                     future: _isAlreadyLoggedIn(),
// //                     builder: (context, snapshot) {
// //                       if (snapshot.data == true) {
// //                         return TextButton(
// //                           onPressed: _logout,
// //                           child: Text(
// //                             'Logout from previous session',
// //                             style: TextStyle(
// //                               color: Colors.red,
// //                               fontSize: minitextsz,
// //                             ),
// //                           ),
// //                         );
// //                       }
// //                       return SizedBox.shrink();
// //                     },
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     ),
// //   );
// // }

// //   @override
// //   void dispose() {
// //     _pinController.dispose();
// //     _pinFocusNode.dispose();
// //     super.dispose();
// //   }
// // }

// // class UpdateChecker {
// //   static const String LAST_UPDATE_CHECK_KEY = 'last_update_check';
// //   static const String FORCE_UPDATE_TIME_KEY = 'force_update_time';
// //   static const Duration CHECK_INTERVAL = Duration(hours: 8);

// //   late BuildContext context;
// //   Timer? _timer;
// //   bool _forceUpdate = false;
// //   bool _isDialogShowing = false;

// //   UpdateChecker(this.context) {
// //     _startUpdateCheckTimer();
// //   }

// //   void _startUpdateCheckTimer() {
// //     _checkForUpdate(); // Check immediately on start
// //     _timer = Timer.periodic(CHECK_INTERVAL, (timer) {
// //       _checkForUpdate();
// //     });
// //   }

// //   Future<void> _checkForUpdate() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final lastCheck = prefs.getInt(LAST_UPDATE_CHECK_KEY) ?? 0;
// //     final now = DateTime.now().millisecondsSinceEpoch;

// //     if (now - lastCheck >= CHECK_INTERVAL.inMilliseconds || _forceUpdate) {
// //       await prefs.setInt(LAST_UPDATE_CHECK_KEY, now);

// //       try {
// //         final response = await https.get(
// //           Uri.parse('https://api.ekomflix.com/android/getSettings'),
// //           headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
// //         );

// //         if (response.statusCode == 200) {
// //           final data = jsonDecode(response.body);

// //           String apiVersion = data['playstore_version'] ?? "";
// //           String apkUrl = data['playstore_apkUrl'];
// //           String releaseNotes = data['playstore_releaseNotes'];

// //           int forceUpdateTime =
// //               DateTime.parse(data['playstore_forceUpdateTime'])
// //                   .millisecondsSinceEpoch;

// //           PackageInfo packageInfo = await PackageInfo.fromPlatform();
// //           String appVersion = packageInfo.version;

// //           if (_isVersionGreater(apiVersion, appVersion)) {
// //             if (forceUpdateTime > 0 && now >= forceUpdateTime) {
// //               _forceUpdate = true;
// //               await prefs.setInt(FORCE_UPDATE_TIME_KEY, forceUpdateTime);
// //             }
// //             if (!_isDialogShowing) {
// //               _showUpdateDialog(apkUrl, releaseNotes, appVersion, apiVersion);
// //             }
// //           }
// //         }
// //       } catch (e) {
// //         // Handle error
// //       }
// //     }
// //   }

// //   bool _isVersionGreater(String v1, String v2) {
// //     List<int> v1Parts = v1.split('.').map(int.parse).toList();
// //     List<int> v2Parts = v2.split('.').map(int.parse).toList();

// //     for (int i = 0; i < v1Parts.length && i < v2Parts.length; i++) {
// //       if (v1Parts[i] > v2Parts[i]) return true;
// //       if (v1Parts[i] < v2Parts[i]) return false;
// //     }

// //     return v1Parts.length > v2Parts.length;
// //   }

// //   void _showUpdateDialog(String apkUrl, String releaseNotes,
// //       String currentVersion, String newVersion) {
// //     _isDialogShowing = true;
// //     showDialog(
// //       barrierColor: Colors.black54,
// //       context: context,
// //       barrierDismissible: !_forceUpdate,
// //       builder: (BuildContext context) {
// //         return WillPopScope(
// //           onWillPop: () async => !_forceUpdate,
// //           child: AlertDialog(
// //             backgroundColor: cardColor,
// //             title: Center(
// //                 child: Text('NEW UPDATE AVAILABLE',
// //                     style: TextStyle(color: hintColor))),
// //             actions: [
// //               if (!_forceUpdate)
// //                 TextButton(
// //                   onPressed: () {
// //                     Navigator.of(context).pop();
// //                     _isDialogShowing = false;
// //                   },
// //                   child: Center(child: Text('Later')),
// //                 ),
// //               TextButton(
// //                 onPressed: () {
// //                   _launchURL(apkUrl);
// //                 },
// //                 child: Center(child: Text('Update Now')),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     ).then((_) {
// //       if (_forceUpdate) {
// //         _showUpdateDialog(apkUrl, releaseNotes, currentVersion, newVersion);
// //       } else {
// //         _isDialogShowing = false;
// //       }
// //     });
// //   }

// //   Future<void> _launchURL(String url) async {
// //     if (await canLaunch(url)) {
// //       await launch(url);
// //     } else {
// //       throw 'Could not launch $url';
// //     }
// //   }

// //   void dispose() {
// //     _timer?.cancel();
// //   }
// // }

// // class MyHome extends StatefulWidget {
// //   @override
// //   _MyHomeState createState() => _MyHomeState();
// // }

// // class _MyHomeState extends State<MyHome> {
// //   int _selectedPage = 0;
// //   late PageController _pageController;
// //   bool _tvenableAll = false;
// //   late UpdateChecker _updateChecker;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _pageController = PageController(initialPage: _selectedPage);
// //     _fetchTvenableAllStatus();
// //     _updateChecker = UpdateChecker(context);
// //     // Login check is now handled in SplashScreen
// //   }

// //   @override
// //   void dispose() {
// //     _pageController.dispose();
// //     _updateChecker.dispose();
// //     super.dispose();
// //   }

// //   void _onPageSelected(int index) {
// //     setState(() {
// //       _selectedPage = index;
// //     });
// //     _pageController.jumpToPage(index);
// //   }

// //   Future<void> _fetchTvenableAllStatus() async {
// //     try {
// //       final response = await https.get(
// //         Uri.parse('https://api.ekomflix.com/android/getSettings'),
// //         headers: {
// //           'x-api-key': 'vLQTuPZUxktl5mVW',
// //         },
// //       );

// //       if (response.statusCode == 200) {
// //         final data = jsonDecode(response.body);
// //         setState(() {
// //           _tvenableAll = data['tvenableAll'] == 1;
// //         });
// //       } else {
// //         print('Failed to load settings');
// //       }
// //     } catch (e) {
// //       print('Error: ');
// //     }
// //   }

// //   void _showLogoutDialog() {
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return AlertDialog(
// //           backgroundColor: cardColor,
// //           title: Text(
// //             'Logout',
// //             style: TextStyle(color: hintColor),
// //           ),
// //           content: Text(
// //             'Are you sure you want to logout?',
// //             style: TextStyle(color: hintColor),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.of(context).pop(),
// //               child: Text('Cancel'),
// //             ),
// //             TextButton(
// //               onPressed: () async {
// //                 Navigator.of(context).pop();
// //                 await _logout();
// //               },
// //               child: Text('Logout', style: TextStyle(color: Colors.red)),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Future<void> _logout() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     await prefs.clear(); // Clear all stored data

// //     Navigator.pushAndRemoveUntil(
// //       context,
// //       MaterialPageRoute(builder: (context) => LoginScreen()),
// //       (route) => false, // Remove all previous routes
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     List<Widget> pages = [
// //       HomeScreen(),
// //       VOD(),
// //       LiveScreen(),
// //       SearchScreen(),
// //       YoutubeSearchScreen()
// //     ];

// //     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
// //       // Get background color based on provider state
// //       Color backgroundColor = colorProvider.isItemFocused
// //           ? colorProvider.dominantColor.withOpacity(0.5)
// //           : cardColor;
// //       return SafeArea(
// //         child: Scaffold(
// //           body: Container(
// //             color: backgroundColor,
// //             child: Stack(
// //               children: [
// //                 Container(
// //                   width: screenwdt,
// //                   height: screenhgt,
// //                   color: cardColor,
// //                   child: Column(
// //                     children: [
// //                       // Top Navigation with Logout option
// //                       Container(
// //                         child: Stack(
// //                           children: [
// //                             TopNavigationBar(
// //                               selectedPage: _selectedPage,
// //                               onPageSelected: _onPageSelected,
// //                               tvenableAll: _tvenableAll,
// //                             ),
// //                             // Logout button positioned at top right
// //                             Positioned(
// //                               top: 10,
// //                               right: 10,
// //                               child: GestureDetector(
// //                                 onTap: _showLogoutDialog,
// //                                 child: Container(
// //                                   padding: EdgeInsets.all(8),
// //                                   decoration: BoxDecoration(
// //                                     color: Colors.red.withOpacity(0.7),
// //                                     borderRadius: BorderRadius.circular(20),
// //                                   ),
// //                                   child: Icon(
// //                                     Icons.logout,
// //                                     color: Colors.white,
// //                                     size: 20,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       Expanded(
// //                         child: PageView(
// //                           controller: _pageController,
// //                           onPageChanged: (index) {
// //                             setState(() {
// //                               _selectedPage = index;
// //                             });
// //                           },
// //                           children: pages,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       );
// //     });
// //   }
// // }

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:animate_do/animate_do.dart'; // Import kiya gaya package
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:sensors_plus/sensors_plus.dart'; // For Parallax effect
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/home_screen.dart';
// import 'package:mobi_tv_entertainment/menu_screens/youtube_search_screen.dart';
// import 'package:mobi_tv_entertainment/menu_screens/search_screen.dart';
// import 'package:mobi_tv_entertainment/menu_screens/live_screen.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'menu/top_navigation_bar.dart';
// import 'home_screen_pages/sub_vod_screen/sub_vod.dart';
// import 'widgets/small_widgets/app_assets.dart';
// import 'widgets/small_widgets/loading_indicator.dart';
// import 'package:intl/date_symbol_data_local.dart';

// // Global variable for authentication key
// String globalAuthKey = '';

// // Auth key manager class
// class AuthManager {
//   static String _authKey = '';
//   static bool _isInitialized = false;

//   static String get authKey => _authKey;

//   static Future<void> initialize() async {
//     if (!_isInitialized) {
//       await _loadAuthKey();
//       _isInitialized = true;
//     }
//   }

//   static Future<void> _loadAuthKey() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? authKey = prefs.getString('result_auth_key');

//       if (authKey != null && authKey.isNotEmpty) {
//         _authKey = authKey;
//         globalAuthKey =
//             authKey; // Also set global variable for backward compatibility
//       } else {}
//     } catch (e) {}
//   }

//   static Future<void> setAuthKey(String authKey) async {
//     _authKey = authKey;
//     globalAuthKey = authKey; // Also set global variable

//     // Save to SharedPreferences
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('result_auth_key', authKey);
//   }

//   static Future<void> clearAuthKey() async {
//     _authKey = '';
//     globalAuthKey = '';

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('result_auth_key');
//   }

//   static bool get hasValidAuthKey => _authKey.isNotEmpty;
// }

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

// void main() async {

// WidgetsFlutterBinding.ensureInitialized();

//   HttpOverrides.global = MyHttpOverrides();
//   await initializeDateFormatting(null, null);
//      SystemChrome.setEnabledSystemUIMode(
//     SystemUiMode.immersiveSticky,
//     overlays: [],
//   );

//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       systemNavigationBarColor: Colors.transparent,
//       statusBarBrightness: Brightness.dark,
//       statusBarIconBrightness: Brightness.light,
//       systemNavigationBarIconBrightness: Brightness.light,
//     ),
//   );

//     // ✅ Provider ko initialize karein
//   final deviceInfoProvider = DeviceInfoProvider();
//   await deviceInfoProvider.loadDeviceInfo(); // ✅ Device info pehle hi load kar lein

//   runApp(
//     MultiProvider(
//       providers: [
//         // ChangeNotifierProvider(create: (_) => DeviceInfoProvider()),
//         ChangeNotifierProvider(create: (_) => ColorProvider()),
//         ChangeNotifierProvider(create: (_) => FocusProvider()),
//         ChangeNotifierProvider.value(value: deviceInfoProvider),
//         // ChangeNotifierProvider(create: (_) => SharedDataProvider()),
//       ],
//       child: MyApp(),
//     ),
//   );
// }

// String baseUrl = 'https://dashboard.cpplayers.com/public/api/';
// var highlightColor;
// var cardColor;
// var hintColor;
// var borderColor;

// var screenhgt;
// var screenwdt;
// var bannerwdt;
// var bannerhgt;
// var focussedBannerwdt;
// var focussedBannerhgt;
// var screensz;
// var nametextsz;
// var menutextsz;
// var minitextsz;
// var Headingtextsz;

// String localImage = 'assets/logo.png';
// String streamImage = 'assets/streamstarting.gif';

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     // Initialize auth manager
//     AuthManager.initialize();
//   }

//   @override
//   Widget build(BuildContext context) {
//     screenhgt = MediaQuery.of(context).size.height;
//     screenwdt = MediaQuery.of(context).size.width;
//     bannerwdt = screenwdt * 0.15;
//     bannerhgt = screenhgt * 0.17;
//     focussedBannerwdt = screenwdt * 0.15;
//     focussedBannerhgt = screenhgt * 0.21;
//     screensz = MediaQuery.of(context).size;
//     nametextsz = MediaQuery.of(context).size.width / 60.0;
//     menutextsz = MediaQuery.of(context).size.width / 70;
//     minitextsz = MediaQuery.of(context).size.width / 80;
//     Headingtextsz = MediaQuery.of(context).size.width / 50;
//     highlightColor = Colors.blue;
//     cardColor = const Color.fromARGB(200, 0, 0, 0).withOpacity(0.7);
//     hintColor = Colors.white;
//     borderColor = Color.fromARGB(255, 247, 6, 118);

// // ✅ SOLUTION: localImage ko global getter banayiye
// // Widget get localImage => AppAssets.localImage();

// // ✅ ALTERNATIVE: Function approach
// // Widget  localImage({double? width, double? height, bool animated = false}) {
// //   return AppAssets.localImage(
// //     width: width,
// //     height: height,
// //     animated: animated,
// //   );
// // }

//     // localImage = '/assets/app_assets.dart';

//     // ✅ SOLUTION: localImage ko global getter banayiye
// // Widget get localImage => AppAssets.localImage();

// // ✅ ALTERNATIVE: Function approach
//     Widget localImage({double? width, double? height, bool animated = false}) {
//       return AppAssets.localImage(
//         width: width,
//         height: height,
//         animated: animated,
//       );
//     }
// // localImage = Container(
// //   decoration: BoxDecoration(
// //     borderRadius: BorderRadius.circular(screenwdt * 0.01),
// //     boxShadow: [
// //       // Much darker and stronger shadows
// //       BoxShadow(
// //         color: Colors.black.withOpacity(0.95), // Increased opacity
// //         blurRadius: 25,
// //         spreadRadius: 3,
// //         offset: Offset(0, 10),
// //       ),
// //       BoxShadow(
// //         color: Colors.black.withOpacity(0.8),
// //         blurRadius: 50,
// //         spreadRadius: 8,
// //         offset: Offset(0, 20),
// //       ),
// //       // Additional deep shadow for more darkness
// //       BoxShadow(
// //         color: Colors.black.withOpacity(0.6),
// //         blurRadius: 80,
// //         spreadRadius: 15,
// //         offset: Offset(0, 30),
// //       ),
// //     ],
// //   ),
// //   child: ClipRRect(
// //     borderRadius: BorderRadius.circular(screenwdt * 0.0),
// //     child: Container(
// //       foregroundDecoration: BoxDecoration(
// //         // Much darker gradient overlay
// //         gradient: LinearGradient(
// //           begin: Alignment.topCenter,
// //           end: Alignment.bottomCenter,
// //           colors: [
// //             Colors.black.withOpacity(0.3),  // Much darker start
// //             Colors.black.withOpacity(0.4),  // Darker middle
// //             Colors.black.withOpacity(0.5),  // Very dark end
// //           ],
// //           stops: [0.0, 0.5, 1.0],
// //         ),
// //         borderRadius: BorderRadius.circular(screenwdt * 0.0),
// //       ),
// //       child: Image.asset(
// //         'assets/logo.png',
// //         fit: BoxFit.cover,
// //       ),
// //     ),
// //   ),
// // );

//     // localImage = Container(
//     //   width: double.infinity,
//     //   padding: const EdgeInsets.all(20),
//     //   child:
//     //   EkomLogoWidget(
//     //     width: AppLogos.getResponsiveWidth(MediaQuery.of(context).size.width),
//     //     animated: true,
//     //   ),
//     // );

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SplashScreen(),
//       routes: {
//         '/mainscreen': (context) => HomeScreen(),
//         '/search': (context) => SearchScreen(),
//         '/vod': (context) => VOD(),
//         '/live': (context) => LiveScreen(),
//         '/home': (context) => MyHome(),
//         '/login': (context) => LoginScreen(),
//       },
//     );
//   }
// }

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     // Show splash for at least 2 seconds
//     await Future.delayed(Duration(seconds: 2));

//     // Initialize auth manager first
//     await AuthManager.initialize();

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
//     String? authKey = prefs.getString('result_auth_key');
//     String? userData = prefs.getString('user_data');

//     if (isLoggedIn && authKey != null && userData != null) {
//       // Set auth key in AuthManager
//       await AuthManager.setAuthKey(authKey);

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => MyHome()),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: cardColor,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: screenwdt * 0.5,
//               height: screenhgt * 0.5,
//               child: Image.asset('assets/streamstarting.gif'),
//             ),
//             // SizedBox(height: 30),
//             // CircularProgressIndicator(
//             //   valueColor: AlwaysStoppedAnimation<Color>(highlightColor),
//             // ),
//             // SizedBox(height: 20),
//             LoadingIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with TickerProviderStateMixin {
//   final TextEditingController _pinController = TextEditingController();
//   bool _isLoading = false;
//   String _errorMessage = '';
//   String _deviceSerial = '';
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _fadeController = AnimationController(
//       duration: Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0, 0.5),
//       end: Offset.zero,
//     ).animate(
//         CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

//     _initializeScreen();
//   }

//   Future<void> _initializeScreen() async {
//     _loadDeviceSerial();
//     _fadeController.forward();
//     await Future.delayed(Duration(milliseconds: 200));
//     _slideController.forward();
//   }

//   Future<void> _loadDeviceSerial() async {
//     try {
//       String serial = await _getDeviceSerialNumber();
//       if (mounted) setState(() => _deviceSerial = serial);
//     } catch (e) {
//       if (mounted) setState(() => _deviceSerial = '123456789');
//     }
//   }

//   Future<String> _getDeviceSerialNumber() async {
//     try {
//       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//       if (Platform.isAndroid) {
//         AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//         return androidInfo.id;
//       } else if (Platform.isIOS) {
//         IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//         return iosInfo.identifierForVendor ??
//             'iOS-${DateTime.now().millisecondsSinceEpoch}';
//       }
//     } catch (_) {}
//     return 'DEVICE-${DateTime.now().millisecondsSinceEpoch}';
//   }

//   Future<void> _login() async {
//     if (_pinController.text.trim().isEmpty ||
//         _pinController.text.trim().length < 10) {
//       _showError('Please enter a valid PIN');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       String serialNumber = _deviceSerial.isNotEmpty
//           ? _deviceSerial
//           : await _getDeviceSerialNumber();

//       bool loginSuccess = false;
//       String authKey = '';
//       Map<String, dynamic>? userData;

//       final loginEndpoints = [
//         // {
//         //   'url': 'https://dashboard.cpplayers.com/public/api/login',
//         //   'body': {
//         //     'token': '',
//         //     'mac_address': serialNumber,
//         //     'login_pin': _pinController.text.trim(),
//         //   }
//         // },
//         {
//           'url': 'https://dashboard.cpplayers.com/api/login',
//           'body': {
//             'token': '',
//             'mac_address': serialNumber,
//             'login_pin': _pinController.text.trim(),
//           }
//         },
//         // {
//         //   'url': 'https://dashboard.cpplayers.com/api/auth/login',
//         //   'body': {
//         //     'mac_address': serialNumber,
//         //     'pin': _pinController.text.trim(),
//         //   }
//         // },
//       ];

//       for (final endpoint in loginEndpoints) {
//         try {
//           final response = await https
//               .post(
//                 Uri.parse(endpoint['url'] as String),
//                 headers: {
//                   'Content-Type': 'application/json',
//                   'Accept': 'application/json',
//                   'User-Agent': 'MobiTV-Flutter-App',
//                 },
//                 body: jsonEncode(endpoint['body']),
//               )
//               .timeout(Duration(seconds: 15));

//           if (response.statusCode == 200) {
//             final data = jsonDecode(response.body);

//             if (data['status'] == true || data['success'] == true) {
//               authKey = data['result_result_auth_key'] ??
//                   data['result_auth_key'] ??
//                   data['token'] ??
//                   '';
//               userData = data['data'] ?? data['user'] ?? {};

//               if (authKey.isNotEmpty) {
//                 loginSuccess = true;
//                 break;
//               }
//             }
//           }
//         } catch (_) {}
//       }

//       if (loginSuccess && authKey.isNotEmpty) {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await Future.wait([
//           prefs.setString('result_auth_key', authKey),
//           prefs.setString('user_data', jsonEncode(userData ?? {})),
//           prefs.setString('user_pin', _pinController.text.trim()),
//           prefs.setString('device_serial', serialNumber),
//           prefs.setBool('is_logged_in', true),
//           prefs.setInt(
//               'login_timestamp', DateTime.now().millisecondsSinceEpoch),
//         ]);

//         await AuthManager.setAuthKey(authKey);

//         Navigator.pushReplacement(
//           context,
//           PageRouteBuilder(
//             pageBuilder: (context, animation, _) => MyHome(),
//             transitionsBuilder: (_, animation, __, child) =>
//                 FadeTransition(opacity: animation, child: child),
//             transitionDuration: Duration(milliseconds: 500),
//           ),
//         );
//       } else {
//         _showError('Invalid PIN. Please check and try again.');
//       }
//     } catch (e) {
//       _showError(
//           'Login failed. ${e.toString().contains('Timeout') ? 'Check your internet.' : 'Try again.'}');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showError(String message) {
//     if (!mounted) return;
//     setState(() => _errorMessage = message);
//     Timer(Duration(seconds: 5), () {
//       if (mounted) setState(() => _errorMessage = '');
//     });
//   }

//   @override
//   void dispose() {
//     _pinController.dispose();
//     _fadeController.dispose();
//     _slideController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: cardColor,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//             child: SlideTransition(
//               position: _slideAnimation,
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Logo
//                     Container(
//                       width: 120,
//                       height: 120,
//                       margin: EdgeInsets.only(bottom: 30),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white.withOpacity(0.1),
//                         border: Border.all(
//                           color: borderColor.withOpacity(0.3),
//                           width: 2,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.3),
//                             blurRadius: 20,
//                             spreadRadius: 5,
//                           ),
//                         ],
//                       ),
//                       child: ClipOval(
//                         child: Padding(
//                           padding: EdgeInsets.all(20),
//                           child: Image.asset(
//                             'assets/streamstarting.gif',
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                     ),

//                     Text(
//                       'Enter your PIN',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: Headingtextsz,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1,
//                       ),
//                     ),

//                     SizedBox(height: 20),

//                     // PIN Display
//                     Container(
//                       padding: EdgeInsets.all(10),
//                       child: Text(
//                         _pinController.text.padRight(10, '_'),
//                         style: TextStyle(
//                           fontSize: nametextsz * 1.3,
//                           letterSpacing: 6,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: 20),

//                     // Number Pad
//                     Wrap(
//                       spacing: 12,
//                       runSpacing: 12,
//                       alignment: WrapAlignment.center,
//                       children: List.generate(12, (index) {
//                         String label = '';
//                         if (index < 9) {
//                           label = '${index + 1}';
//                         } else if (index == 9) {
//                           label = 'Del';
//                         } else if (index == 10) {
//                           label = '0';
//                         } else if (index == 11) {
//                           label = 'OK';
//                         }

//                         return SizedBox(
//                           width: screenwdt * 0.18,
//                           height: 55,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               if (label == 'Del') {
//                                 if (_pinController.text.isNotEmpty) {
//                                   setState(() {
//                                     _pinController.text = _pinController.text
//                                         .substring(
//                                             0, _pinController.text.length - 1);
//                                   });
//                                 }
//                               } else if (label == 'OK') {
//                                 _login();
//                               } else {
//                                 if (_pinController.text.length < 10) {
//                                   setState(() {
//                                     _pinController.text += label;
//                                   });
//                                 }
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white.withOpacity(0.1),
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             child: Text(
//                               label,
//                               style: TextStyle(
//                                 fontSize: nametextsz * 1.2,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         );
//                       }),
//                     ),

//                     SizedBox(height: 25),

//                     if (_isLoading)
//                       CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),

//                     if (_errorMessage.isNotEmpty)
//                       Padding(
//                         padding: EdgeInsets.only(top: 20),
//                         child: Text(
//                           _errorMessage,
//                           style: TextStyle(
//                               color: Colors.red, fontSize: minitextsz),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Rest of your existing code (UpdateChecker, MyHome, etc.) remains the same...
// class UpdateChecker {
//   static const String LAST_UPDATE_CHECK_KEY = 'last_update_check';
//   static const String FORCE_UPDATE_TIME_KEY = 'force_update_time';
//   static const Duration CHECK_INTERVAL = Duration(hours: 8);

//   late BuildContext context;
//   Timer? _timer;
//   bool _forceUpdate = false;
//   bool _isDialogShowing = false;

//   UpdateChecker(this.context) {
//     _startUpdateCheckTimer();
//   }

//   void _startUpdateCheckTimer() {
//     _checkForUpdate();
//     _timer = Timer.periodic(CHECK_INTERVAL, (timer) {
//       _checkForUpdate();
//     });
//   }

//   Future<void> _checkForUpdate() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lastCheck = prefs.getInt(LAST_UPDATE_CHECK_KEY) ?? 0;
//     final now = DateTime.now().millisecondsSinceEpoch;

//     if (now - lastCheck >= CHECK_INTERVAL.inMilliseconds || _forceUpdate) {
//       await prefs.setInt(LAST_UPDATE_CHECK_KEY, now);

//       try {
//         final response = await https.get(
//           Uri.parse('https://api.ekomflix.com/android/getSettings'),
//           headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
//         );

//         if (response.statusCode == 200) {
//           final data = jsonDecode(response.body);

//           String apiVersion = data['playstore_version'] ?? "";
//           String apkUrl = data['playstore_apkUrl'];
//           String releaseNotes = data['playstore_releaseNotes'];

//           int forceUpdateTime =
//               DateTime.parse(data['playstore_forceUpdateTime'])
//                   .millisecondsSinceEpoch;

//           PackageInfo packageInfo = await PackageInfo.fromPlatform();
//           String appVersion = packageInfo.version;

//           if (_isVersionGreater(apiVersion, appVersion)) {
//             if (forceUpdateTime > 0 && now >= forceUpdateTime) {
//               _forceUpdate = true;
//               await prefs.setInt(FORCE_UPDATE_TIME_KEY, forceUpdateTime);
//             }
//             if (!_isDialogShowing) {
//               _showUpdateDialog(apkUrl, releaseNotes, appVersion, apiVersion);
//             }
//           }
//         }
//       } catch (e) {
//         // Handle error
//       }
//     }
//   }

//   bool _isVersionGreater(String v1, String v2) {
//     List<int> v1Parts = v1.split('.').map(int.parse).toList();
//     List<int> v2Parts = v2.split('.').map(int.parse).toList();

//     for (int i = 0; i < v1Parts.length && i < v2Parts.length; i++) {
//       if (v1Parts[i] > v2Parts[i]) return true;
//       if (v1Parts[i] < v2Parts[i]) return false;
//     }

//     return v1Parts.length > v2Parts.length;
//   }

//   void _showUpdateDialog(String apkUrl, String releaseNotes,
//       String currentVersion, String newVersion) {
//     _isDialogShowing = true;
//     showDialog(
//       barrierColor: Colors.black54,
//       context: context,
//       barrierDismissible: !_forceUpdate,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async => !_forceUpdate,
//           child: AlertDialog(
//             backgroundColor: cardColor,
//             title: Center(
//                 child: Text('NEW UPDATE AVAILABLE',
//                     style: TextStyle(color: hintColor))),
//             actions: [
//               if (!_forceUpdate)
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     _isDialogShowing = false;
//                   },
//                   child: Center(child: Text('Later')),
//                 ),
//               TextButton(
//                 onPressed: () {
//                   _launchURL(apkUrl);
//                 },
//                 child: Center(child: Text('Update Now')),
//               ),
//             ],
//           ),
//         );
//       },
//     ).then((_) {
//       if (_forceUpdate) {
//         _showUpdateDialog(apkUrl, releaseNotes, currentVersion, newVersion);
//       } else {
//         _isDialogShowing = false;
//       }
//     });
//   }

//   Future<void> _launchURL(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   void dispose() {
//     _timer?.cancel();
//   }
// }

// class MyHome extends StatefulWidget {
//   @override
//   _MyHomeState createState() => _MyHomeState();
// }

// class _MyHomeState extends State<MyHome> {
//   int _selectedPage = 0;
//   late PageController _pageController;
//   bool _tvenableAll = false;
//   late UpdateChecker _updateChecker;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: _selectedPage);
//     _fetchTvenableAllStatus();
//     _updateChecker = UpdateChecker(context);

//     // Ensure auth key is loaded when entering main app
//     _ensureAuthKeyLoaded();
//   }

//   Future<void> _ensureAuthKeyLoaded() async {
//     await AuthManager.initialize();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _updateChecker.dispose();
//     super.dispose();
//   }

//   void _onPageSelected(int index) {
//     setState(() {
//       _selectedPage = index;
//     });
//     _pageController.jumpToPage(index);
//   }

//   Future<void> _fetchTvenableAllStatus() async {
//     try {
//       final response = await https.get(
//         Uri.parse('https://api.ekomflix.com/android/getSettings'),
//         headers: {
//           'x-api-key': 'vLQTuPZUxktl5mVW',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _tvenableAll = data['tvenableAll'] == 1;
//         });
//       } else {}
//     } catch (e) {}
//   }

//   // void _showLogoutDialog() {
//   //   showDialog(
//   //     context: context,
//   //     builder: (BuildContext context) {
//   //       return AlertDialog(
//   //         backgroundColor: cardColor,
//   //         title: Text(
//   //           'Logout',
//   //           style: TextStyle(color: hintColor),
//   //         ),
//   //         content: Text(
//   //           'Are you sure you want to logout?',
//   //           style: TextStyle(color: hintColor),
//   //         ),
//   //         actions: [
//   //           TextButton(
//   //             onPressed: () => Navigator.of(context).pop(),
//   //             child: Text('Cancel'),
//   //           ),
//   //           TextButton(
//   //             onPressed: () async {
//   //               Navigator.of(context).pop();
//   //               await _logout();
//   //             },
//   //             child: Text('Logout', style: TextStyle(color: Colors.red)),
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }

//   // Future<void> _logout() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   await prefs.clear();
//   //   await AuthManager.clearAuthKey();

//   //   Navigator.pushAndRemoveUntil(
//   //     context,
//   //     MaterialPageRoute(builder: (context) => LoginScreen()),
//   //     (route) => false,
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     List<Widget> pages = [
//       HomeScreen(),
//       VOD(),
//       LiveScreen(),
//       SearchScreen(),
//       YoutubeSearchScreen()
//     ];

//     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//       Color backgroundColor = colorProvider.isItemFocused
//           ? colorProvider.dominantColor.withOpacity(0.5)
//           : cardColor;
//       return SafeArea(
//         child: Scaffold(
//           body: Container(
//             color: backgroundColor,
//             child: Stack(
//               children: [
//                 Container(
//                   width: screenwdt,
//                   height: screenhgt,
//                   color: cardColor,
//                   child: Column(
//                     children: [
//                       Container(
//                         child: Stack(
//                           children: [
//                             TopNavigationBar(
//                               selectedPage: _selectedPage,
//                               onPageSelected: _onPageSelected,
//                               tvenableAll: _tvenableAll,
//                             ),
//                             // Positioned(
//                             //   top: 10,
//                             //   right: 10,
//                             //   child: GestureDetector(
//                             //     onTap: _showLogoutDialog,
//                             //     child: Container(
//                             //       padding: EdgeInsets.all(8),
//                             //       decoration: BoxDecoration(
//                             //         color: Colors.red.withOpacity(0.7),
//                             //         borderRadius: BorderRadius.circular(20),
//                             //       ),
//                             //       child: Icon(
//                             //         Icons.logout,
//                             //         color: Colors.white,
//                             //         size: 20,
//                             //       ),
//                             //     ),
//                             //   ),
//                             // ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: PageView(
//                           controller: _pageController,
//                           onPageChanged: (index) {
//                             setState(() {
//                               _selectedPage = index;
//                             });
//                           },
//                           children: pages,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }

// // lib/main.dart

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/home_screen_pages/home_screen.dart';
// import 'package:mobi_tv_entertainment/menu_screens/live_screen.dart';
// import 'package:mobi_tv_entertainment/menu_screens/search_screen.dart';
// import 'package:mobi_tv_entertainment/menu_screens/youtube_search_screen.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/device_info_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:intl/date_symbol_data_local.dart';

// import 'home_screen_pages/sub_vod_screen/sub_vod.dart';
// import 'menu/top_navigation_bar.dart';

// // lib/provider/session_manager.dart

// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class SessionManager {
//   static bool _isInitialized = false;

//   // --- Session Data ---
//   static String _authKey = '';
//   static String _imageBaseUrl = '';
//   static Map<String, dynamic>? _userData;
//   static String _logoUrl = '';

//   // ✅ Step 1: Feature flags ke liye naye variables banayein
//   static bool _showMovies = false;
//   static bool _showWebseries = false;
//   static bool _showTvShow = false;
//   static bool _showTvShowPak = false;
//   static bool _showKidsShow = false;
//   static bool _showReligious = false;
//   static bool _showSports = false;
//   static bool _showStageShows = false;
//   static bool _showLaughterShows = false;
//   static bool _showContentNetwork = false;
//   static bool _showSearch = false;

//   // --- Public Getters ---
//   static String get authKey => _authKey;
//   static String get imageBaseUrl => _imageBaseUrl;
//   static Map<String, dynamic>? get userData => _userData;
//   static String get logoUrl => _logoUrl;
//   static bool get isLoggedIn => _authKey.isNotEmpty && _userData != null;

//   // ✅ Step 2: Feature flags ke liye public getters banayein
//   static bool get showMovies => _showMovies;
//   static bool get showWebseries => _showWebseries;
//   static bool get showTvShow => _showTvShow;
//   static bool get showTvShowPak => _showTvShowPak;
//   static bool get showKidsShow => _showKidsShow;
//   static bool get showReligious => _showReligious;
//   static bool get showSports => _showSports;
//   static bool get showStageShows => _showStageShows;
//   static bool get showLaughterShows => _showLaughterShows;
//   static bool get showContentNetwork => _showContentNetwork;
//   static bool get showSearch => _showSearch;

//   // --- Methods ---

//   static Future<void> initialize() async {
//     if (!_isInitialized) {
//       await _loadSession();
//       _isInitialized = true;
//     }
//   }

//   static Future<void> _loadSession() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       _authKey = prefs.getString('result_auth_key') ?? '';
//       _imageBaseUrl = prefs.getString('image_base_url') ?? '';
//       _logoUrl = prefs.getString('logo_url') ?? '';

//       String? userDataString = prefs.getString('user_data');
//       if (userDataString != null) {
//         _userData = jsonDecode(userDataString);
//       }

//       // ✅ Step 3: SharedPreferences se feature flags load karein
//       _showMovies = prefs.getBool('show_movies') ?? false;
//       _showWebseries = prefs.getBool('show_webseries') ?? false;
//       _showTvShow = prefs.getBool('show_tvshow') ?? false;
//       _showTvShowPak = prefs.getBool('show_tvshow_pak') ?? false;
//       _showKidsShow = prefs.getBool('show_kids_show') ?? false;
//       _showReligious = prefs.getBool('show_religious') ?? false;
//       _showSports = prefs.getBool('show_sports') ?? false;
//       _showStageShows = prefs.getBool('show_stage_shows') ?? false;
//       _showLaughterShows = prefs.getBool('show_laughter_shows') ?? false;
//       _showContentNetwork = prefs.getBool('show_content_network') ?? false;
//       _showSearch = prefs.getBool('show_search') ?? false;

//     } catch (e) {
//       // Error hone par sab clear kar dein
//       await clearSession();
//     }
//   }

//   static Future<void> saveSession(Map<String, dynamic> apiResponse) async {

//   print("--- 1. saveSession के अंदर ---"); // मार्कर 1
//   SharedPreferences prefs = await SharedPreferences.getInstance();

//   _authKey = apiResponse['result_result_auth_key'] ?? '';
//   _imageBaseUrl = apiResponse['imageBaseUrl'] ?? '';
//   _userData = apiResponse['data'] as Map<String, dynamic>?;

//   if (_userData != null && _userData!['domain_content'] != null) {
//     final domainContent = _userData!['domain_content'];
//     print("--- 2. domain_content मिला: $domainContent ---"); // मार्कर 2

//     _logoUrl = domainContent['logo'] ?? 'API_SE_URL_NULL_AAYA'; // डीबगिंग के लिए डिफ़ॉल्ट टेक्स्ट
//     print("--- 3. निकाला गया LogoURLs: $_logoUrl ---"); // मार्कर 3
//   } else {
//     print("--- गड़बड़: userData या domain_content null है! ---"); // एरर केस
//     _logoUrl = '';
//   }

//   // SharedPreferences में डेटा write karein
//   await prefs.setString('logo_url', _logoUrl);
//   print("--- 4. SharedPreferences में '$_logoUrl' सेव किया गया। ---"); // मार्कर 4

//     // // SharedPreferences prefs = await SharedPreferences.getInstance();

//     // // Basic info save karein
//     // _authKey = apiResponse['result_result_auth_key'] ?? '';
//     // _imageBaseUrl = apiResponse['imageBaseUrl'] ?? '';
//     // _userData = apiResponse['data'] as Map<String, dynamic>?;

//     // Logo aur feature flags save karein
//     if (_userData != null && _userData!['domain_content'] != null) {
//       final domainContent = _userData!['domain_content'];
//       _logoUrl = domainContent['logo'] ?? '';

//       // ✅ Step 4: API se feature flags nikalein aur unhe boolean mein convert karein
//       _showMovies = (domainContent['movies'] ?? 0) == 1;
//       _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//       _showTvShow = (domainContent['tvshow'] ?? 0) == 1;
//       _showTvShowPak = (domainContent['tvshow_pak'] ?? 0) == 1;
//       _showKidsShow = (domainContent['kids_show'] ?? 0) == 1;
//       _showReligious = (domainContent['religious'] ?? 0) == 1;
//       _showSports = (domainContent['sports'] ?? 0) == 1;
//       _showStageShows = (domainContent['stage_shows'] ?? 0) == 1;
//       _showLaughterShows = (domainContent['laughter_shows'] ?? 0) == 1;
//       _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//       _showSearch = (domainContent['search'] ?? 0) == 1;
//     }

//     // SharedPreferences mein data write karein
//     await prefs.setString('result_auth_key', _authKey);
//     await prefs.setString('image_base_url', _imageBaseUrl);
//     await prefs.setString('logo_url', _logoUrl);
//     if (_userData != null) {
//       await prefs.setString('user_data', jsonEncode(_userData));
//     }

//     // ✅ Step 5: Feature flags ko SharedPreferences mein save karein
//     await prefs.setBool('show_movies', _showMovies);
//     await prefs.setBool('show_webseries', _showWebseries);
//     await prefs.setBool('show_tvshow', _showTvShow);
//     await prefs.setBool('show_tvshow_pak', _showTvShowPak);
//     await prefs.setBool('show_kids_show', _showKidsShow);
//     await prefs.setBool('show_religious', _showReligious);
//     await prefs.setBool('show_sports', _showSports);
//     await prefs.setBool('show_stage_shows', _showStageShows);
//     await prefs.setBool('show_laughter_shows', _showLaughterShows);
//     await prefs.setBool('show_content_network', _showContentNetwork);
//     await prefs.setBool('show_search', _showSearch);

//     await prefs.setBool('is_logged_in', true);
//   }

//   static Future<void> clearSession() async {
//     // Sabhi variables ko reset karein
//     _authKey = '';
//     _imageBaseUrl = '';
//     _userData = null;
//     _logoUrl = '';

//     // ✅ Step 6: Logout par feature flags ko bhi reset karein
//     _showMovies = false;
//     _showWebseries = false;
//     _showTvShow = false;
//     _showTvShowPak = false;
//     _showKidsShow = false;
//     _showReligious = false;
//     _showSports = false;
//     _showStageShows = false;
//     _showLaughterShows = false;
//     _showContentNetwork = false;
//     _showSearch = false;

//     // SharedPreferences se saara data delete karein
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }
// }

// // Global variable for backward compatibility (optional but can be helpful)
// String get globalAuthKey => SessionManager.authKey;

// // HttpOverrides to allow self-signed certificates (keep as is)
// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   HttpOverrides.global = MyHttpOverrides();
//   await initializeDateFormatting(null, null);

//   // ✅ Initialize SessionManager at app start
//   await SessionManager.initialize();

//   SystemChrome.setEnabledSystemUIMode(
//     SystemUiMode.immersiveSticky,
//     overlays: [],
//   );

//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       systemNavigationBarColor: Colors.transparent,
//       statusBarBrightness: Brightness.dark,
//       statusBarIconBrightness: Brightness.light,
//       systemNavigationBarIconBrightness: Brightness.light,
//     ),
//   );

//   final deviceInfoProvider = DeviceInfoProvider();
//   await deviceInfoProvider.loadDeviceInfo();

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ColorProvider()),
//         ChangeNotifierProvider(create: (_) => FocusProvider()),
//         ChangeNotifierProvider.value(value: deviceInfoProvider),
//       ],
//       child: MyApp(),
//     ),
//   );
// }

// // Global variables
// String baseUrl = 'https://dashboard.cpplayers.com/public/api/';
// var highlightColor;
// var cardColor;
// var hintColor;
// var borderColor;

// var screenhgt;
// var screenwdt;
// var bannerwdt;
// var bannerhgt;
// var focussedBannerwdt;
// var focussedBannerhgt;
// var screensz;
// var nametextsz;
// var menutextsz;
// var minitextsz;
// var Headingtextsz;

// String localImage = 'assets/logo.png';
// String streamImage = 'assets/streamstarting.gif';

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     screenhgt = MediaQuery.of(context).size.height;
//     screenwdt = MediaQuery.of(context).size.width;
//     bannerwdt = screenwdt * 0.15;
//     bannerhgt = screenhgt * 0.17;
//     focussedBannerwdt = screenwdt * 0.15;
//     focussedBannerhgt = screenhgt * 0.21;
//     screensz = MediaQuery.of(context).size;
//     nametextsz = MediaQuery.of(context).size.width / 60.0;
//     menutextsz = MediaQuery.of(context).size.width / 70;
//     minitextsz = MediaQuery.of(context).size.width / 80;
//     Headingtextsz = MediaQuery.of(context).size.width / 50;
//     highlightColor = Colors.blue;
//     cardColor = const Color.fromARGB(200, 0, 0, 0).withOpacity(0.7);
//     hintColor = Colors.white;
//     borderColor = Color.fromARGB(255, 247, 6, 118);

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SplashScreen(),
//       routes: {
//         '/mainscreen': (context) => HomeScreen(),
//         '/search': (context) => SearchScreen(),
//         '/vod': (context) => VOD(),
//         '/live': (context) => LiveScreen(),
//         '/home': (context) => MyHome(),
//         '/login': (context) => LoginScreen(),
//       },
//     );
//   }
// }

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     // Show splash for at least 2 seconds
//     await Future.delayed(Duration(seconds: 2));

//     // ✅ Use SessionManager to check login status
//     if (SessionManager.isLoggedIn) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => MyHome()),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: cardColor,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: screenwdt * 0.5,
//               height: screenhgt * 0.5,
//               child: Image.asset('assets/streamstarting.gif'),
//             ),
//             LoadingIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with TickerProviderStateMixin {
//   final TextEditingController _pinController = TextEditingController();
//   bool _isLoading = false;
//   String _errorMessage = '';
//   String _deviceSerial = '';
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _fadeController = AnimationController(
//       duration: Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0, 0.5),
//       end: Offset.zero,
//     ).animate(
//         CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

//     _initializeScreen();
//   }

//   Future<void> _initializeScreen() async {
//     _loadDeviceSerial();
//     _fadeController.forward();
//     await Future.delayed(Duration(milliseconds: 200));
//     _slideController.forward();
//   }

//   Future<void> _loadDeviceSerial() async {
//     try {
//       String serial = await _getDeviceSerialNumber();
//       if (mounted) setState(() => _deviceSerial = serial);
//     } catch (e) {
//       if (mounted) setState(() => _deviceSerial = '123456789');
//     }
//   }

//   Future<String> _getDeviceSerialNumber() async {
//     try {
//       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//       if (Platform.isAndroid) {
//         AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//         return androidInfo.id;
//       } else if (Platform.isIOS) {
//         IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//         return iosInfo.identifierForVendor ??
//             'iOS-${DateTime.now().millisecondsSinceEpoch}';
//       }
//     } catch (_) {}
//     return 'DEVICE-${DateTime.now().millisecondsSinceEpoch}';
//   }

//   Future<void> _login() async {
//     if (_pinController.text.trim().length < 10) {
//       _showError('Please enter a valid 10-digit PIN');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       String serialNumber = _deviceSerial.isNotEmpty
//           ? _deviceSerial
//           : await _getDeviceSerialNumber();

//       final response = await https
//           .post(
//             // Uri.parse('https://dashboard.cpplayers.com/api/login'),
//             Uri.parse('https://dashboard.cpplayers.com/api/v2/login'),
//             headers: {
//               'Content-Type': 'application/json',
//               'Accept': 'application/json',
//               'User-Agent': 'MobiTV-Flutter-App',
//             },
//             body: jsonEncode({
//               'token': '',
//               'mac_address': serialNumber,
//               'login_pin': _pinController.text.trim(),
//               'domain':'coretechinfo.com'

//             }),
//           )
//           .timeout(Duration(seconds: 15));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         if (data['status'] == true) {
//           // ✅ Save all session data using the manager
//           await SessionManager.saveSession(data);

//           // Save pin and serial separately if needed for other purposes
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setString('user_pin', _pinController.text.trim());
//           await prefs.setString('device_serial', serialNumber);

//           Navigator.pushReplacement(
//             context,
//             PageRouteBuilder(
//               pageBuilder: (context, animation, _) => MyHome(),
//               transitionsBuilder: (_, animation, __, child) =>
//                   FadeTransition(opacity: animation, child: child),
//               transitionDuration: Duration(milliseconds: 500),
//             ),
//           );
//         } else {
//           _showError(data['msg'] ?? 'Invalid PIN. Please try again.');
//         }
//       } else {
//         _showError('Server error. Please try again later.');
//       }
//     } catch (e) {
//       _showError(
//           'Login failed. ${e.toString().contains('Timeout') ? 'Check your internet.' : 'Try again.'}');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showError(String message) {
//     if (!mounted) return;
//     setState(() => _errorMessage = message);
//     Timer(Duration(seconds: 5), () {
//       if (mounted) setState(() => _errorMessage = '');
//     });
//   }

//   @override
//   void dispose() {
//     _pinController.dispose();
//     _fadeController.dispose();
//     _slideController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Login Screen UI remains the same
//     return Scaffold(
//       backgroundColor: cardColor,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//             child: SlideTransition(
//               position: _slideAnimation,
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 120,
//                       height: 120,
//                       margin: EdgeInsets.only(bottom: 30),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white.withOpacity(0.1),
//                         border: Border.all(
//                           color: borderColor.withOpacity(0.3),
//                           width: 2,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.3),
//                             blurRadius: 20,
//                             spreadRadius: 5,
//                           ),
//                         ],
//                       ),
//                       child: ClipOval(
//                         child: Padding(
//                           padding: EdgeInsets.all(20),
//                           child: Image.asset(
//                             'assets/streamstarting.gif',
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                     ),

//                     Text(
//                       'Enter your PIN',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: Headingtextsz,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1,
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     Container(
//                       padding: EdgeInsets.all(10),
//                       child: Text(
//                         _pinController.text.padRight(10, '_'),
//                         style: TextStyle(
//                           fontSize: nametextsz * 1.3,
//                           letterSpacing: 6,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     Wrap(
//                       spacing: 12,
//                       runSpacing: 12,
//                       alignment: WrapAlignment.center,
//                       children: List.generate(12, (index) {
//                         String label = '';
//                         if (index < 9) {
//                           label = '${index + 1}';
//                         } else if (index == 9) {
//                           label = 'Del';
//                         } else if (index == 10) {
//                           label = '0';
//                         } else if (index == 11) {
//                           label = 'OK';
//                         }

//                         return SizedBox(
//                           width: screenwdt * 0.18,
//                           height: 55,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               if (label == 'Del') {
//                                 if (_pinController.text.isNotEmpty) {
//                                   setState(() {
//                                     _pinController.text = _pinController.text
//                                         .substring(
//                                             0, _pinController.text.length - 1);
//                                   });
//                                 }
//                               } else if (label == 'OK') {
//                                 _login();
//                               } else {
//                                 if (_pinController.text.length < 10) {
//                                   setState(() {
//                                     _pinController.text += label;
//                                   });
//                                 }
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white.withOpacity(0.1),
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             child: Text(
//                               label,
//                               style: TextStyle(
//                                 fontSize: nametextsz * 1.2,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         );
//                       }),
//                     ),

//                     SizedBox(height: 25),

//                     if (_isLoading)
//                       CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),

//                     if (_errorMessage.isNotEmpty)
//                       Padding(
//                         padding: EdgeInsets.only(top: 20),
//                         child: Text(
//                           _errorMessage,
//                           style: TextStyle(
//                               color: Colors.red, fontSize: minitextsz),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }






import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
import 'package:mobi_tv_entertainment/home_screen.dart';
import 'package:mobi_tv_entertainment/components/menu_screens/live_screen.dart';
import 'package:mobi_tv_entertainment/components/menu_screens/search_screen.dart';
import 'package:mobi_tv_entertainment/components/menu_screens/youtube_search_screen.dart';
import 'package:mobi_tv_entertainment/components/models/channel_data_cache.dart';
import 'package:mobi_tv_entertainment/components/models/content_item.dart';
import 'package:mobi_tv_entertainment/components/models/horizontal_vod_cache.dart';
import 'package:mobi_tv_entertainment/components/models/horizontal_vod_model.dart';
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/device_info_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/loading_indicator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'components/menu/top_navigation_bar.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:video_player_avplay/video_player_avplay.dart'; // <-- Add this import
import 'package:flutter/material.dart';
// import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
// import 'package:media_kit_video/media_kit_video.dart'; // Provides [VideoController] & [Video] etc.

class SessionManager {
  static bool _isInitialized = false;

  // --- Session Data ---
  static String _authKey = '';
  static String _imageBaseUrl = '';
  static Map<String, dynamic>? _userData;
  static String _logoUrl = '';
  static String _savedDomain = '';
  static int? _userId; // ✅ 1. User ID ke liye naya variable

  // --- Feature flags (No changes here) ---
  static bool _showMovies = false;
  static bool _showWebseries = false;
  static bool _showTvShow = false;
  static bool _showTvShowPak = false;
  static bool _showKidsShow = false;
  static bool _showReligious = false;
  static bool _showSports = false;
  static bool _showStageShows = false;
  static bool _showLaughterShows = false;
  static bool _showContentNetwork = false;
  static bool _showSearch = false;

  // --- Public Getters ---
  static String get authKey => _authKey;
  static String get imageBaseUrl => _imageBaseUrl;
  static Map<String, dynamic>? get userData => _userData;
  static String get logoUrl => _logoUrl;
  static String get savedDomain => _savedDomain;
  static int? get userId => _userId; // ✅ 2. User ID ke liye public getter
  static bool get isLoggedIn => _authKey.isNotEmpty && _userData != null;

  // --- Feature flag getters (No changes here) ---
  static bool get showMovies => _showMovies;
  static bool get showWebseries => _showWebseries;
  static bool get showTvShow => _showTvShow;
  static bool get showTvShowPak => _showTvShowPak;
  static bool get showKidsShow => _showKidsShow;
  static bool get showReligious => _showReligious;
  static bool get showSports => _showSports;
  static bool get showStageShows => _showStageShows;
  static bool get showLaughterShows => _showLaughterShows;
  static bool get showContentNetwork => _showContentNetwork;
  static bool get showSearch => _showSearch;

  // --- Methods ---
  static Future<void> initialize() async {
    if (!_isInitialized) {
      await _loadSession();
      _isInitialized = true;
    }
  }

  static Future<void> _loadSession() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _authKey = prefs.getString('result_auth_key') ?? '';
      _imageBaseUrl = prefs.getString('image_base_url') ?? '';
      _logoUrl = prefs.getString('logo_url') ?? '';
      _savedDomain = prefs.getString('saved_domain') ?? '';
      _userId = prefs.getInt('user_id'); // ✅ 3. Saved ID ko load karein

      String? userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        _userData = jsonDecode(userDataString);
      }

      _showMovies = prefs.getBool('show_movies') ?? false;
      _showWebseries = prefs.getBool('show_webseries') ?? false;
      _showTvShow = prefs.getBool('show_tvshow') ?? false;
      _showTvShowPak = prefs.getBool('show_tvshow_pak') ?? false;
      _showKidsShow = prefs.getBool('show_kids_show') ?? false;
      _showReligious = prefs.getBool('show_religious') ?? false;
      _showSports = prefs.getBool('show_sports') ?? false;
      _showStageShows = prefs.getBool('show_stage_shows') ?? false;
      _showLaughterShows = prefs.getBool('show_laughter_shows') ?? false;
      _showContentNetwork = prefs.getBool('show_content_network') ?? false;
      _showSearch = prefs.getBool('show_search') ?? false;
    } catch (e) {
      await clearSession();
    }
  }

  static Future<void> saveSession(Map<String, dynamic> apiResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _authKey = apiResponse['result_auth_key'] ?? '';
    _imageBaseUrl = apiResponse['imageBaseUrl'] ?? '';
    _userData = apiResponse['data'] as Map<String, dynamic>?;

    // ✅ 4. API response se 'id' nikalein aur save karein
    if (_userData != null && _userData!['id'] != null) {
      _userId = _userData!['id'];
      await prefs.setInt('user_id', _userId!);
    }

    if (_userData != null && _userData!['domain'] != null) {
      _savedDomain = _userData!['domain'];
      await prefs.setString('saved_domain', _savedDomain);
    }

    if (_userData != null && _userData!['domain_content'] != null) {
      final domainContent = _userData!['domain_content'];
      _logoUrl = domainContent['logo'] ?? '';
      _showMovies = (domainContent['movies'] ?? 0) == 1;
      _showWebseries = (domainContent['webseries'] ?? 0) == 1;
      _showTvShow = (domainContent['tvshow'] ?? 0) == 1;
      _showTvShowPak = (domainContent['tvshow_pak'] ?? 0) == 1;
      _showKidsShow = (domainContent['kids_show'] ?? 0) == 1;
      _showReligious = (domainContent['religious'] ?? 0) == 1;
      _showSports = (domainContent['sports'] ?? 0) == 1;
      _showStageShows = (domainContent['stage_shows'] ?? 0) == 1;
      _showLaughterShows = (domainContent['laughter_shows'] ?? 0) == 1;
      _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
      _showSearch = (domainContent['search'] ?? 0) == 1;
    }

    await prefs.setString('result_auth_key', _authKey);
    await prefs.setString('image_base_url', _imageBaseUrl);
    await prefs.setString('logo_url', _logoUrl);
    if (_userData != null) {
      await prefs.setString('user_data', jsonEncode(_userData));
    }
    await prefs.setBool('is_logged_in', true);

    await prefs.setBool('show_movies', _showMovies);
    await prefs.setBool('show_webseries', _showWebseries);
    await prefs.setBool('show_tvshow', _showTvShow);
    await prefs.setBool('show_tvshow_pak', _showTvShowPak);
    await prefs.setBool('show_kids_show', _showKidsShow);
    await prefs.setBool('show_religious', _showReligious);
    await prefs.setBool('show_sports', _showSports);
    await prefs.setBool('show_stage_shows', _showStageShows);
    await prefs.setBool('show_laughter_shows', _showLaughterShows);
    await prefs.setBool('show_content_network', _showContentNetwork);
    await prefs.setBool('show_search', _showSearch);
  }

  static Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('result_auth_key');
    await prefs.remove('user_data');
    await prefs.remove('is_logged_in');
    await prefs.remove('user_id'); // ✅ 5. Logout par ID ko remove karein

    // Variables reset karein
    _authKey = '';
    _userData = null;
    _logoUrl = '';
    _userId = null; // ✅ 6. Variable ko bhi reset karein
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  // VideoPlayerAvplay.init();
  WidgetsFlutterBinding.ensureInitialized();
  // MediaKit.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await initializeDateFormatting(null, null);
  await SessionManager.initialize();

  // SystemChrome.setEnabledSystemUIMode(
  //   SystemUiMode.immersiveSticky,
  //   overlays: [],
  // );

  // SystemChrome.setSystemUIOverlayStyle(
  //   const SystemUiOverlayStyle(
  //     statusBarColor: Colors.transparent,
  //     systemNavigationBarColor: Colors.transparent,
  //     statusBarBrightness: Brightness.dark,
  //     statusBarIconBrightness: Brightness.light,
  //     systemNavigationBarIconBrightness: Brightness.light,
  //   ),
  // );

  // // Hive को Flutter के लिए इनिशियलाइज़ करें
  // // await Hive.initFlutter();

  // // TypeAdapters को रजिस्टर करें
  // // महत्वपूर्ण: सुनिश्चित करें कि typeId आपके मॉडल में दिए गए आईडी से मेल खाता है
  // Hive.registerAdapter(ChannelDataCacheAdapter()); // typeId: 0
  // Hive.registerAdapter(ContentItemAdapter()); // typeId: 1
  // Hive.registerAdapter(NetworkDataAdapter()); // typeId: 2
  // Hive.registerAdapter(HorizontalVodModelAdapter()); // typeId: 3
  // Hive.registerAdapter(HorizontalVodCacheAdapter()); // typeId: 4

  // // Hive बॉक्स खोलें जिसे आप ऐप में इस्तेमाल करेंगे
  // await Hive.openBox('channelCache');
  // await Hive.openBox('vodCache');
  final deviceInfoProvider = DeviceInfoProvider();
  await deviceInfoProvider.loadDeviceInfo();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ColorProvider()),
        ChangeNotifierProvider(create: (_) => FocusProvider()),
        ChangeNotifierProvider.value(value: deviceInfoProvider),
        ChangeNotifierProvider(create: (_) => InternalFocusProvider()),
      ],
      child: MyApp(),
    ),
  );
}

// Global variables
String baseUrl = 'https://dashboard.cpplayers.com/public/api/';
var highlightColor;
var cardColor;
var hintColor;
var borderColor;

var screenhgt;
var screenwdt;
var bannerwdt;
var bannerhgt;
var focussedBannerwdt;
var focussedBannerhgt;
var screensz;
var nametextsz;
var menutextsz;
var minitextsz;
var Headingtextsz;

String localImage = 'assets/cpPlayer.png';
String streamImage = 'assets/streamstarting.gif';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    screenhgt = MediaQuery.of(context).size.height;
    screenwdt = MediaQuery.of(context).size.width;
    bannerwdt = screenwdt * 0.13;
    bannerhgt = screenhgt * 0.15;
    focussedBannerwdt = screenwdt * 0.13;
    focussedBannerhgt = screenhgt * 0.19;
    screensz = MediaQuery.of(context).size;
    nametextsz = MediaQuery.of(context).size.width / 60.0;
    menutextsz = MediaQuery.of(context).size.width / 70;
    minitextsz = MediaQuery.of(context).size.width / 80;
    Headingtextsz = MediaQuery.of(context).size.width / 50;
    highlightColor = Colors.blue;
    cardColor = const Color.fromARGB(200, 0, 0, 0).withOpacity(0.7);
    hintColor = Colors.white;
    borderColor = Color.fromARGB(255, 247, 6, 118);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        '/mainscreen': (context) => HomeScreen(),
        '/search': (context) => SearchScreen(),
        // '/vod': (context) => VOD(),
        // '/live': (context) => LiveScreen(),
        '/home': (context) => MyHome(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 2));

    if (SessionManager.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHome()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenwdt * 0.5,
              height: screenhgt * 0.5,
              child: Image.asset('assets/streamstarting.gif'),
            ),
            LoadingIndicator(),
          ],
        ),
      ),
    );
  }
}

// Paste this updated LoginScreen widget and its State class into your main.dart file.
// All other parts of your file can remain the same.

enum InputFocus { domain, pin }

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();
  InputFocus _currentFocus = InputFocus.domain;
  bool _isShiftEnabled = false;

  bool _isLoading = false;
  String _errorMessage = '';
  String _deviceSerial = '';
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    if (mounted) {
      setState(() {
        _domainController.text = SessionManager.savedDomain;
        if (_domainController.text.isNotEmpty) {
          _currentFocus = InputFocus.pin;
        }
      });
    }

    _loadDeviceSerial();
    _fadeController.forward();
    await Future.delayed(Duration(milliseconds: 200));
    _slideController.forward();
  }

  Future<void> _loadDeviceSerial() async {
    try {
      String serial = await _getDeviceSerialNumber();
      if (mounted) setState(() => _deviceSerial = serial);
    } catch (e) {
      if (mounted) setState(() => _deviceSerial = '123456789');
    }
  }

  Future<String> _getDeviceSerialNumber() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ??
            'iOS-${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (_) {}
    return 'DEVICE-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _login() async {
    if (_domainController.text.trim().isEmpty) {
      _showError('Please enter a valid domain');
      return;
    }
    if (_pinController.text.trim().length < 10) {
      _showError('Please enter a valid 10-digit PIN');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String serialNumber = _deviceSerial.isNotEmpty
          ? _deviceSerial
          : await _getDeviceSerialNumber();

      final response = await https
          .post(
            Uri.parse('https://dashboard.cpplayers.com/api/v2/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'MobiTV-Flutter-App',
            },
            body: jsonEncode({
              'token': '',
              'mac_address': serialNumber,
              'login_pin': _pinController.text.trim(),
              'domain': _domainController.text.trim(),
            }),
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          await SessionManager.saveSession(data);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_pin', _pinController.text.trim());
          await prefs.setString('device_serial', serialNumber);

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, _) => MyHome(),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: Duration(milliseconds: 500),
            ),
          );
        } else {
          _showError(data['msg'] ?? 'Invalid credentials. Please try again.');
        }
      } else {
        _showError('Server error. Please try again later.');
      }
    } catch (e) {
      _showError(
          'Login failed. ${e.toString().contains('Timeout') ? 'Check your internet.' : 'Try again.'}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _errorMessage = message);
    Timer(Duration(seconds: 5), () {
      if (mounted) setState(() => _errorMessage = '');
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _domainController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String value) {
    setState(() {
      if (value == 'OK') {
        if (_currentFocus == InputFocus.domain) {
          _currentFocus = InputFocus.pin;
        } else {
          _login();
        }
        return;
      }

      if (value == 'SHIFT') {
        _isShiftEnabled = !_isShiftEnabled;
        return;
      }

      TextEditingController activeController =
          _currentFocus == InputFocus.domain
              ? _domainController
              : _pinController;

      // if (value == 'DEL') {
      //   if (activeController.text.isNotEmpty) {
      //     activeController.text = activeController.text
      //         .substring(0, activeController.text.length - 1);
      //   }
      // }
      // This is the new, updated code
      if (value == 'DEL') {
        // If the active text field has text in it, delete one character.
        if (activeController.text.isNotEmpty) {
          activeController.text = activeController.text
              .substring(0, activeController.text.length - 1);
        }
        // NEW LOGIC: If the active field is the PIN field AND it's empty,
        // pressing 'DEL' will move the focus back to the domain field.
        else if (_currentFocus == InputFocus.pin) {
          setState(() {
            _currentFocus = InputFocus.domain;
          });
        }
      } else if (_currentFocus == InputFocus.pin) {
        if (RegExp(r'^[0-9]$').hasMatch(value) &&
            activeController.text.length < 10) {
          activeController.text += value;
        }
      } else {
        activeController.text += value;
      }
    });
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required InputFocus focus,
    bool isPin = false,
  }) {
    final bool isActive = _currentFocus == focus;
    String displayText = controller.text;

    if (isPin) {
      displayText = displayText.padRight(10, '_');
    }
    if (controller.text.isEmpty) {
      displayText = hint;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.06),
      child: GestureDetector(
        onTap: () => setState(() => _currentFocus = focus),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? borderColor : Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Text(
            displayText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: controller.text.isEmpty ? Colors.white54 : Colors.white,
              // fontSize: nametextsz * (isPin ? 1.4 : 0.9),
              fontSize: nametextsz * 1.4,
              letterSpacing: isPin ? 5 : 1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Reduced padding for a more compact view
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reduced logo size and margin
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: borderColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Image.asset(
                            'assets/streamstarting.gif',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // Fields are now in a Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Enter your Domain',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: menutextsz,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildInputField(
                                controller: _domainController,
                                hint: 'example.com',
                                focus: InputFocus.domain,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20), // Space between fields
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Enter your PIN',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: menutextsz,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildInputField(
                                controller: _pinController,
                                hint: '__________',
                                focus: InputFocus.pin,
                                isPin: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20), // Reduced spacing
                    if (_currentFocus == InputFocus.pin)
                      _buildNumpad()
                    else
                      _buildQwertyKeyboard(),

                    SizedBox(height: 20), // Reduced spacing
                    if (_isLoading)
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: minitextsz * 1.2,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Wrap(
      spacing: 10, // Reduced spacing
      runSpacing: 10, // Reduced spacing
      alignment: WrapAlignment.center,
      children: List.generate(12, (index) {
        String label = '';
        if (index < 9) {
          label = '${index + 1}';
        } else if (index == 9) {
          label = 'DEL';
        } else if (index == 10) {
          label = '0';
        } else if (index == 11) {
          label = 'OK';
        }
        // Reduced key width
        return _buildKey(label, width: screenwdt * 0.20);
      }),
    );
  }

  Widget _buildQwertyKeyboard() {
    final row1 = "1234567890.".split('');
    final row2 = "qwertyuiop,".split('');
    final row3 = "asdfghjkl:/".split('');
    final row4 = ["DEL", ..."zxcvbnm".split(''), "DEL"];
    final row5 = [/*"coretechinfo.com",*/ "SHIFT", "@", " ", ".com", "OK"];

    return Column(
      children: [
        _buildKeyboardRow(row1),
        _buildKeyboardRow(row2),
        _buildKeyboardRow(row3),
        _buildKeyboardRow(row4),
        _buildKeyboardRow(row5, isSpecialRow: true),
      ],
    );
  }

  Widget _buildKeyboardRow(List<String> keys, {bool isSpecialRow = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        // Reduced key widths
        double width = screenwdt * 0.07;
        if (key == ' ') width = screenwdt * 0.18;
        if (key == 'OK' || key == 'SHIFT' || key == '.com' || key == 'DEL')
          width = screenwdt * 0.11;

        String displayKey = key;
        if (key != 'SHIFT' && key != 'DEL' && key != 'OK' && key.length == 1) {
          displayKey = _isShiftEnabled ? key.toUpperCase() : key.toLowerCase();
        }

        return _buildKey(displayKey, originalKey: key, width: width);
      }).toList(),
    );
  }

  Widget _buildKey(String label, {String? originalKey, double? width}) {
    final keyToProcess = originalKey ?? label;

    return Container(
      // Adjusted width and height for smaller buttons
      width: width ?? screenwdt * 0.18,
      height: screenhgt * 0.1,
      // Reduced margin for less padding between keys
      margin: const EdgeInsets.all(2),
      child: ElevatedButton(
        onPressed: () => _onKeyPressed(keyToProcess),
        style: ElevatedButton.styleFrom(
            backgroundColor: (keyToProcess == 'SHIFT' && _isShiftEnabled)
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // slightly smaller radius
            ),
            padding: EdgeInsets.zero),
        child: Text(
          label,
          style: TextStyle(
            fontSize: nametextsz * 1.7, // Slightly smaller font
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Rest of your code (UpdateChecker, MyHome, etc.)
// ...
class UpdateChecker {
  static const String LAST_UPDATE_CHECK_KEY = 'last_update_check';
  static const String FORCE_UPDATE_TIME_KEY = 'force_update_time';
  static const Duration CHECK_INTERVAL = Duration(hours: 8);

  late BuildContext context;
  Timer? _timer;
  bool _forceUpdate = false;
  bool _isDialogShowing = false;

  UpdateChecker(this.context) {
    _startUpdateCheckTimer();
  }

  void _startUpdateCheckTimer() {
    _checkForUpdate();
    _timer = Timer.periodic(CHECK_INTERVAL, (timer) {
      _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(LAST_UPDATE_CHECK_KEY) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastCheck >= CHECK_INTERVAL.inMilliseconds || _forceUpdate) {
      await prefs.setInt(LAST_UPDATE_CHECK_KEY, now);

      try {
        final response = await https.get(
          Uri.parse('https://api.ekomflix.com/android/getSettings'),
          headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          String apiVersion = data['playstore_version'] ?? "";
          String apkUrl = data['playstore_apkUrl'] ?? '';
          String releaseNotes = data['playstore_releaseNotes'] ?? '';

          int forceUpdateTime =
              DateTime.parse(data['playstore_forceUpdateTime'])
                  .millisecondsSinceEpoch;

          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          String appVersion = packageInfo.version;

          if (_isVersionGreater(apiVersion, appVersion)) {
            if (forceUpdateTime > 0 && now >= forceUpdateTime) {
              _forceUpdate = true;
              await prefs.setInt(FORCE_UPDATE_TIME_KEY, forceUpdateTime);
            }
            if (!_isDialogShowing) {
              _showUpdateDialog(apkUrl, releaseNotes, appVersion, apiVersion);
            }
          }
        }
      } catch (e) {
        // Handle error
      }
    }
  }

  bool _isVersionGreater(String v1, String v2) {
    List<int> v1Parts = v1.split('.').map(int.parse).toList();
    List<int> v2Parts = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < v1Parts.length && i < v2Parts.length; i++) {
      if (v1Parts[i] > v2Parts[i]) return true;
      if (v1Parts[i] < v2Parts[i]) return false;
    }

    return v1Parts.length > v2Parts.length;
  }

  void _showUpdateDialog(String apkUrl, String releaseNotes,
      String currentVersion, String newVersion) {
    _isDialogShowing = true;
    showDialog(
      barrierColor: Colors.black54,
      context: context,
      barrierDismissible: !_forceUpdate,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => !_forceUpdate,
          child: AlertDialog(
            backgroundColor: cardColor,
            title: Center(
                child: Text('NEW UPDATE AVAILABLE',
                    style: TextStyle(color: hintColor))),
            actions: [
              if (!_forceUpdate)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _isDialogShowing = false;
                  },
                  child: Center(child: Text('Later')),
                ),
              TextButton(
                onPressed: () {
                  _launchURL(apkUrl);
                },
                child: Center(child: Text('Update Now')),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (_forceUpdate) {
        _showUpdateDialog(apkUrl, releaseNotes, currentVersion, newVersion);
      } else {
        _isDialogShowing = false;
      }
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int _selectedPage = 0;
  late PageController _pageController;
  bool _tvenableAll = false;
  late UpdateChecker _updateChecker;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedPage);
    _fetchTvenableAllStatus();
    _updateChecker = UpdateChecker(context);

    // Example of how to access user data
    // You can access user data anywhere like this:
    String? userName = SessionManager.userData?['name'];
    print('Logged in user: $userName');

    String? imageUrl = SessionManager.imageBaseUrl;
    print('Base Image URL: $imageUrl');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInitialLoadingScreen();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _updateChecker.dispose();
    super.dispose();
  }

  // ✅ YEH NAYA FUNCTION ADD KAREIN
  void _showInitialLoadingScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        // opaque: false, screen ko transparent banata hai
        opaque: false,
        pageBuilder: (context, _, __) => const ExitConfirmationScreen(
          // Hum false bhej rahe hain kyunki yeh app start par call ho raha hai
          isFromBackButton: false,
        ),
      ),
    );
  }

  void _onPageSelected(int index) {
    setState(() {
      _selectedPage = index;
    });
    _pageController.jumpToPage(index);
  }

  Future<void> _fetchTvenableAllStatus() async {
    try {
      final response = await https.get(
        Uri.parse('https://api.ekomflix.com/android/getSettings'),
        headers: {
          'x-api-key': 'vLQTuPZUxktl5mVW',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _tvenableAll = data['tvenableAll'] == 1;
        });
      } else {}
    } catch (e) {}
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text(
            'Logout',
            style: TextStyle(color: hintColor),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: hintColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout();
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    // ✅ Clear session using the manager
    await SessionManager.clearSession();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   List<Widget> pages = [
  //     HomeScreen(),
  //     // VOD(),
  //     // LiveScreen(),
  //     SearchScreen(),
  //     // YoutubeSearchScreen()
  //   ];

  //   return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
  //     Color backgroundColor = colorProvider.isItemFocused
  //         ? colorProvider.dominantColor.withOpacity(0.5)
  //         : cardColor;
  //     return SafeArea(
  //       child: Scaffold(
  //         body: Container(
  //           color: backgroundColor,
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
  //                           TopNavigationBar(
  //                             selectedPage: _selectedPage,
  //                             onPageSelected: _onPageSelected,
  //                             tvenableAll: _tvenableAll,
  //                           ),
  //                           // Positioned(
  //                           //   top: 10,
  //                           //   right: 10,
  //                           //   child: GestureDetector(
  //                           //     onTap: _showLogoutDialog, // Enable logout button
  //                           //     child: Container(
  //                           //       padding: EdgeInsets.all(8),
  //                           //       decoration: BoxDecoration(
  //                           //         color: Colors.red.withOpacity(0.7),
  //                           //         borderRadius: BorderRadius.circular(20),
  //                           //       ),
  //                           //       child: Icon(
  //                           //         Icons.logout,
  //                           //         color: Colors.white,
  //                           //         size: 20,
  //                           //       ),
  //                           //     ),
  //                           //   ),
  //                           // ),
  //                         ],
  //                       ),
  //                     ),
  //                     Expanded(
  //                       child: PageView(
  //                         controller: _pageController,
  //                         onPageChanged: (index) {
  //                           setState(() {
  //                             _selectedPage = index;
  //                           });
  //                         },
  //                         children: pages,
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
  //   });
  // }

  // ✅ YEH 'MyHome' KA NAYA BUILD METHOD HAI

@override
Widget build(BuildContext context) {
  List<Widget> pages = [
    HomeScreen(),
    SearchScreen(),
  ];

  // Hum 'SafeArea' ko hata rahe hain taaki content poori screen par dikhe
  return Scaffold(
    // Consumer ko 'body' ke andar le aayein
    body: Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        
        // Background color logic waisi hi rahegi
        Color backgroundColor = colorProvider.isItemFocused
            ? colorProvider.dominantColor.withOpacity(0.5)
            : cardColor;

        // Yeh Container ab poora background banayega
        return Container(
          color: backgroundColor, // Animated background color
          
          // ✅ YEH HAI ASLI STACK LAYOUT
          child: Stack(
            children: [
              
              // 1. CONTENT (PEECHE)
              // PageView ab 'Expanded' mein nahi hai.
              // Yeh poori screen lega aur Stack mein sabse peeche rahega.
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedPage = index;
                  });
                },
                children: pages,
              ),

              // 2. APP BAR (OOPAR)
              // TopNavigationBar ko 'Positioned' karke oopar fix kar diya hai.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: TopNavigationBar(
                  selectedPage: _selectedPage,
                  onPageSelected: _onPageSelected,
                  tvenableAll: _tvenableAll,
                ),
              ),

              // Aapka logout button (agar future mein add karein)
              // Positioned(
              //   top: 10,
              //   right: 10,
              //   child: GestureDetector(
              //     onTap: _showLogoutDialog,
              //     ...
              //   ),
              // ),
            ],
          ),
        );
      },
    ),
  );
}
}
