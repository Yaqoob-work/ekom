// import 'dart:convert'; 
// import 'package:http/http.dart' as https; 
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:math' as math; 

// // ? IMPORT EXIT & EXPIRED SCREENS
// import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// import 'package:mobi_tv_entertainment/plan_expired_screen.dart';

// // ? PAGES IMPORTS
// import 'package:mobi_tv_entertainment/components/home_screen_pages/above_18/above_eighteen.dart'; 
// import 'package:mobi_tv_entertainment/components/home_screen_pages/banner_slider_screen/banner_slider_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/kids_shows/kids_channels.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/movies_screen/movies.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_live_screen/live_channel_language_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/manage_tv_shows.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show_pak/tv_show_pak.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/manage_webseries.dart';
// import 'package:mobi_tv_entertainment/components/menu/top_navigation_bar.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/main.dart'; 
// import 'package:provider/provider.dart';
// import 'dart:ui'; 

// class MainDashboardScreen extends StatefulWidget {
//   const MainDashboardScreen({Key? key}) : super(key: key);

//   @override
//   _MainDashboardScreenState createState() => _MainDashboardScreenState();
// }

// class _MainDashboardScreenState extends State<MainDashboardScreen> {
//   bool _isLoading = true;
//   bool _isPlanExpired = false;
//     static const double _sideMenuWidthFactor = 0.14;

//   bool _showContentNetwork = false;
//   bool _showMovies = false;
//   bool _showWebseries = false;
//   bool _showTvShows = false;
//   bool _showTvShowsPak = false;
//   bool _showSports = false;
//   bool _showReligious = false;
//   bool _showKids = false;
//   bool _show18Plus = false;
//   bool _isAdultUnlocked = false;

//   List<String> _menuItems = [];
//   List<String> _pageIdentifiers = [];
//   late List<FocusNode> _menuFocusNodes = [];
//   DateTime _lastSidebarKeyTime = DateTime.now();

//   int _selectedIndex = 0; 
//   int _focusedIndex = 0;  
//   int _topNavSelectedIndex = 0; 
//   final FocusNode _bannerFocusNode = FocusNode();
  
//   late ScrollController _sidebarScrollController;

//   String _serverPin = "";
//   String _apiMessage = "";

//   @override
//   void initState() {
//     super.initState();
//     _sidebarScrollController = ScrollController();
//     _initializeDashboard();
//   }

//   Future<void> _initializeDashboard() async {
//     await _checkPlanStatus();
//     if (_isPlanExpired) return;
//     await _check18PlusStatus();
//     _buildDynamicMenu();

//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _setupDashboardController();
//         if (_menuFocusNodes.isNotEmpty) {
//           FocusScope.of(context).requestFocus(_menuFocusNodes[0]);
          
//           context.read<FocusProvider>().updateLastFocusedIdentifier('activeSidebar');
//           setState(() {
//             _focusedIndex = 0;
//             _selectedIndex = 0;
//           });
//         }
//       });
//     }
//   }

//   Future<void> _checkPlanStatus() async {
//     final String? authKey = SessionManager.authKey;

//     if (authKey == null || authKey.isEmpty) {
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
//         _apiMessage = res['message'] ?? 'Status Unknown';
//         final domainContent = res['domain_content'];

//         if (planExpired) {
//           _isPlanExpired = true;
//           if (Navigator.canPop(context)) Navigator.pop(context);
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(
//               builder: (context) => PlanExpiredScreen(apiMessage: _apiMessage),
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
//           Future.delayed(const Duration(milliseconds: 200), () {
//             if (mounted) _showExpiryWarningDialog(_apiMessage);
//           });
//         }
//       }
//     } catch (e) {
//       print("Error fetching Plan Status: $e");
//     }
//   }

//   Future<void> _check18PlusStatus() async {
//     try {
//       final url = Uri.parse("https://dashboard.cpplayers.com/api/v3/showabove18");
//       final headers = {
//         "auth-key": SessionManager.authKey,
//         "domain": SessionManager.savedDomain,
//       };
//       final response = await https.get(url, headers: headers);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == true && mounted) {
//           setState(() {
//             _show18Plus = true;
//             _serverPin = data['above18_pin'].toString();
//           });
//         }
//       }
//     } catch (e) {
//       print("Error fetching 18+ status: $e");
//     }
//   }

//   void _buildDynamicMenu() {
//     _menuItems.clear();
//     _pageIdentifiers.clear();

//     _menuItems.add('LIVE TV');
//     _pageIdentifiers.add('liveChannelLanguage');

//     if (_showContentNetwork) { _menuItems.add('CONTENTS'); _pageIdentifiers.add('subVod'); }
//     if (_showMovies) { _menuItems.add('RECENTLY ADDED'); _pageIdentifiers.add('manageMovies'); }
//     if (_showWebseries) { _menuItems.add('WEB SERIES'); _pageIdentifiers.add('manageWebseries'); }
//     if (_showTvShows) { _menuItems.add('TV SHOWS'); _pageIdentifiers.add('tvShows'); }
//     if (_showTvShowsPak) { _menuItems.add('TV SHOWS PAK'); _pageIdentifiers.add('tvShowPak'); }
//     if (_showReligious) { _menuItems.add('RELIGIOUS'); _pageIdentifiers.add('religiousChannels'); }
//     if (_showSports) { _menuItems.add('SPORTS'); _pageIdentifiers.add('sports'); }
//     if (_showKids) { _menuItems.add('KIDS ZONE'); _pageIdentifiers.add('kids_show'); }
    
//     if (_show18Plus) { 
//       _menuItems.add('18+'); 
//       _pageIdentifiers.add('eighteenPlus'); 
//     }

//     _menuFocusNodes = List.generate(_menuItems.length, (index) => FocusNode());
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

//   void _setupDashboardController() {
//     final fp = context.read<FocusProvider>();
    
//     if (_menuFocusNodes.isNotEmpty) {
//       fp.registerFocusNode('activeSidebar', _menuFocusNodes[_selectedIndex]);
//     }

//     fp.onDashboardNextPage = () {
//       int maxContentIndex = _menuItems.contains('18+') ? _menuItems.length - 2 : _menuItems.length - 1;
//       if (_selectedIndex < maxContentIndex) {
//         _changePageAndFocus(_selectedIndex + 1);
//       }
//     };

//     fp.onDashboardPrevPage = () {
//       if (_selectedIndex > 0) {
//         _changePageAndFocus(_selectedIndex - 1);
//       } else {
//         fp.requestFocus('watchNow'); 
//       }
//     };

//     fp.onBannerDown = () {
//       if (_pageIdentifiers.isNotEmpty) {
//         fp.requestFocus(_pageIdentifiers[_selectedIndex]);
//       }
//     };
//   }

//   void _changePageAndFocus(int newIndex) {
//     if (newIndex < 0 || newIndex >= _menuItems.length) return;

//     final targetId = _pageIdentifiers[newIndex];
    
//     setState(() {
//       _selectedIndex = newIndex;
//       _focusedIndex = newIndex; 
//     });

//     final fp = context.read<FocusProvider>();
//     fp.registerFocusNode('activeSidebar', _menuFocusNodes[newIndex]);
//     fp.updateLastFocusedIdentifier(targetId); 

//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         fp.requestFocus(targetId);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _sidebarScrollController.dispose();
//     for (var node in _menuFocusNodes) node.dispose();
//     _bannerFocusNode.dispose();
//     super.dispose();
//   }

//   void _showPinDialog() {
//     final TextEditingController _pinController = TextEditingController();
//     final FocusNode _inputFocus = FocusNode();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF2A2D3A),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: const Text("Enter 18+ PIN", style: TextStyle(color: Colors.white)),
//           content: TextField(
//             controller: _pinController,
//             focusNode: _inputFocus,
//             autofocus: true,
//             obscureText: true,
//             keyboardType: TextInputType.number,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               hintText: "Enter PIN",
//               hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
//               enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
//               focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
//             ),
//             onSubmitted: (_) => _validatePin(_pinController.text),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
//             ),
//             TextButton(
//               onPressed: () => _validatePin(_pinController.text),
//               child: const Text("Enter", style: TextStyle(color: Colors.blueAccent)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _validatePin(String inputPin) {
//     if (inputPin == _serverPin) {
//       Navigator.pop(context);
//       setState(() {
//         _isAdultUnlocked = true;
//         final idx = _menuItems.indexOf('18+');
//         if (idx != -1) {
//           _selectedIndex = idx;
//           _focusedIndex = idx;
//         }
//       });

//       Future.delayed(const Duration(milliseconds: 50), () {
//         if (!mounted) return;
//         final idx = _menuItems.indexOf('18+');
//         if (idx != -1 && _menuFocusNodes.length > idx) {
//           context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[idx]);
//           context.read<FocusProvider>().requestFocus('eighteenPlus');
//         }
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Invalid PIN"), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
//       );
//     }
//   }

//   Widget _getDynamicBottomContent() {
//     if (_pageIdentifiers.isEmpty || _selectedIndex >= _pageIdentifiers.length) return const SizedBox.shrink();
    
//     String currentId = _pageIdentifiers[_selectedIndex];
    
//     switch (currentId) {
//       case 'liveChannelLanguage': return const LiveChannelLanguageScreen();
//       case 'subVod': return const HorzontalVod();
//       case 'manageMovies': return const MoviesScreen();
//       case 'manageWebseries': return const ManageWebSeries();
//       case 'tvShows': return const ManageTvShows();
//       case 'tvShowPak': return const TvShowsPak();
//       case 'religiousChannels': return const ManageReligiousShows();
//       case 'sports': return const ManageSports();
//       case 'kids_show': return const ManageKidsShows();
//       case 'eighteenPlus': return _isAdultUnlocked ? const AdultMoviesScreen () : const SizedBox.shrink();
//       default: return const SizedBox.shrink();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
//       );
//     }

//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return 
//     // PopScope(
//     //   canPop: false,
//     //   onPopInvoked: (didPop) {
//     //     if (!didPop) {
//     //       Navigator.of(context).push(
//     //         PageRouteBuilder(
//     //           opaque: false,
//     //           pageBuilder: (context, _, __) => const ExitConfirmationScreen(
//     //             isFromBackButton: true,
//     //           ),
//     //         ),
//     //       );
//     //     }
//     //   },
//     PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (!didPop) {
//           // ? FIX: Check karein ki kya focus already sidebar par hai
//           final fp = context.read<FocusProvider>();
//           if (fp.lastFocusedIdentifier != 'activeSidebar') {
//             // Agar contents page (subVod) par hai, toh Exit karne ke bajaye Sidebar par bhejein
//             fp.requestFocus('activeSidebar');
//             return; 
//           }

//           // Agar focus already sidebar par hai, toh Exit screen dikhayein
//           Navigator.of(context).push(
//             PageRouteBuilder(
//               opaque: false,
//               pageBuilder: (context, _, __) => const ExitConfirmationScreen(
//                 isFromBackButton: true,
//               ),
//             ),
//           );
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black, 
//         body: Stack(
//           children: [
//             Positioned.fill(
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: screenHeight * 0.65, 
//                     width: screenWidth, 
//                     child: BannerSlider(
//                       focusNode: _bannerFocusNode,
//                     ),
//                   ),

//                   Expanded(
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child: Container(
//                         key: ValueKey<String>(_pageIdentifiers[_selectedIndex]),
//                         width: screenWidth, 
//                         child: _getDynamicBottomContent(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Sidebar Full Height lega aur Items Center mein rahenge
//             Positioned(
//               left: 0,
//               top: 0, 
//               bottom: 0,
//               child: ClipRRect(
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
//                   child: Container(
//                     width: screenWidth * kSideMenuWidthFactor,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.20), 
//                       border: Border(
//                         right: BorderSide(
//                           color: Colors.white.withOpacity(0.12), 
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: ListView.builder(
//                       controller: _sidebarScrollController, 
//                       clipBehavior: Clip.none, 
//                       // ? MAGIC FIX: ListView ke andar 40% vertical space de diya.
//                       // Isse List ka har element properly center tak aa payega.
//                       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.40),
//                       itemCount: _menuItems.length,
//                       itemBuilder: (context, index) {
//                         return AnimatedSidebarItem(
//                           title: _menuItems[index],
//                           focusNode: _menuFocusNodes[index],
//                           isSelected: _selectedIndex == index,
//                           is18PlusItem: _menuItems[index] == '18+',
//                           onTap: () {
//                             if (_menuItems[index] == '18+') {
//                               _showPinDialog();
//                               return;
//                             }
//                             setState(() {
//                               _selectedIndex = index;
//                               _focusedIndex = index;
//                               context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                             });
//                             Future.delayed(const Duration(milliseconds: 100), () {
//                               if (mounted) context.read<FocusProvider>().requestFocus(_pageIdentifiers[index]);
//                             });
//                           },
//                           onFocusChange: (hasFocus) {
//                             if (hasFocus) {
//                               setState(() {
//                                 _focusedIndex = index; 
//                                 context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                               });
//                             } else {
//                               setState(() {}); 
//                             }
//                           },
//                           onKey: (node, event) {
//                             if (event is RawKeyDownEvent) {
//                               if (event.logicalKey == LogicalKeyboardKey.arrowUp || 
//                                   event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                
//                                 final now = DateTime.now();
//                                 if (now.difference(_lastSidebarKeyTime).inMilliseconds < 350) {
//                                    return KeyEventResult.handled; 
//                                 }
//                                 _lastSidebarKeyTime = now; 

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                                   if (index < _menuItems.length - 1) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index + 1]);
//                                   }
//                                   return KeyEventResult.handled;
//                                 }

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                                   if (index > 0) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index - 1]);
//                                   } else {
//                                     context.read<FocusProvider>().requestFocus('topNavigation');
//                                   }
//                                   return KeyEventResult.handled;
//                                 }
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.enter ||
//                                   event.logicalKey == LogicalKeyboardKey.select) {
                                  
//                                  if (_menuItems[index] == '18+') {
//                                    _showPinDialog();
//                                    return KeyEventResult.handled;
//                                  }

//                                  final fp = context.read<FocusProvider>();
//                                  final targetId = _pageIdentifiers[index];

//                                  fp.updateLastFocusedIdentifier(targetId);

//                                  setState(() {
//                                    _selectedIndex = index; 
//                                    _focusedIndex = index;  
//                                  });

//                                  return KeyEventResult.handled;
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                                  if (_menuItems[index] == '18+' && !_isAdultUnlocked) return KeyEventResult.handled;

//                                  setState(() {
//                                    _selectedIndex = index;
//                                    _focusedIndex = index;
//                                  });

//                                  context.read<FocusProvider>().requestFocus(_pageIdentifiers[_selectedIndex]);
//                                  return KeyEventResult.handled;
//                               }
//                             }
//                             return KeyEventResult.ignored;
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: SizedBox(
//                 height: screenHeight * 0.24, 
//                 child: TopNavigationBar(
//                   selectedPage: _topNavSelectedIndex,
//                   tvenableAll: true,
//                   onPageSelected: (index) => setState(() => _topNavSelectedIndex = index),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// class AnimatedSidebarItem extends StatefulWidget {
//   final String title;
//   final FocusNode focusNode;
//   final bool isSelected;
//   final bool is18PlusItem;
//   final VoidCallback onTap;
//   final ValueChanged<bool> onFocusChange; 
//   final FocusOnKeyCallback onKey;         

//   const AnimatedSidebarItem({
//     Key? key,
//     required this.title,
//     required this.focusNode,
//     required this.isSelected,
//     required this.is18PlusItem,
//     required this.onTap,
//     required this.onFocusChange,
//     required this.onKey,
//   }) : super(key: key);

//   @override
//   _AnimatedSidebarItemState createState() => _AnimatedSidebarItemState();
// }

// class _AnimatedSidebarItemState extends State<AnimatedSidebarItem> with SingleTickerProviderStateMixin {
//   late AnimationController _borderAnimationController;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _borderAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 2500),
//       vsync: this,
//     );
//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (mounted) {
//       setState(() {
//         _isFocused = widget.focusNode.hasFocus;
//       });
//       if (_isFocused) {
//         _borderAnimationController.repeat();
        
//         // ? SMOOTH SCROLLING FIX
//         // 50ms ka delay diya taaki UI pehle border paint kar le,
//         // phir bina frame drop ke smoothly scroll kare.
//         Future.delayed(const Duration(milliseconds: 50), () {
//           if (mounted) {
//             Scrollable.ensureVisible(
//               context,
//               alignment: 0.5, 
//               duration: const Duration(milliseconds: 350), // Thoda zyada time smooth slide ke liye
//               curve: Curves.easeOutCubic, // Premium glide effect
//             );
//           }
//         });

//       } else {
//         _borderAnimationController.stop();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _borderAnimationController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       focusNode: widget.focusNode,
//       onFocusChange: widget.onFocusChange,
//       onKey: widget.onKey,
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: Container(
//           height: 48, 
//           margin: const EdgeInsets.only(left: 25, right: 10, top: 3, bottom: 3), 
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: _isFocused
//                 ? [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 14, offset: const Offset(0, 5))]
//                 : [],
//           ),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               if (_isFocused)
//                 AnimatedBuilder(
//                   animation: _borderAnimationController,
//                   builder: (context, child) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         gradient: SweepGradient(
//                           colors: [
//                             Colors.white.withOpacity(0.1),
//                             Colors.white,
//                             Colors.white,
//                             Colors.white.withOpacity(0.1),
//                           ],
//                           stops: const [0.0, 0.25, 0.5, 1.0],
//                           transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
//                         ),
//                       ),
//                     );
//                   },
//                 ),

//               Padding(
//                 padding: EdgeInsets.all(_isFocused ? 5.0 : 0.0), 
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: _isFocused 
//                         ? Colors.black 
//                         : (widget.isSelected ? Colors.black.withOpacity(0.35) : Colors.transparent),
//                     borderRadius: BorderRadius.circular(_isFocused ? 4 : 8),
//                   ),
//                   child: Center(
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         Text(
//                           widget.title,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: _isFocused ? 13 : 12,
//                             fontWeight: _isFocused || widget.isSelected ? FontWeight.w900 : FontWeight.w700,
//                             letterSpacing: 0.5,
//                             shadows: [
//                               Shadow(
//                                 color: Colors.black.withOpacity(1.0),
//                                 blurRadius: 14,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                             foreground: Paint()
//                               ..style = PaintingStyle.stroke
//                               ..strokeWidth = 4
//                               ..color = Colors.black,
//                           ),
//                         ),
//                         Text(
//                           widget.title,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: _isFocused
//                                 ? Colors.white
//                                 : (widget.isSelected ? Colors.white : Colors.white),
//                             fontSize: _isFocused ? 13 : 12,
//                             fontWeight: _isFocused || widget.isSelected ? FontWeight.w900 : FontWeight.w500,
//                             letterSpacing: 0.5,
//                             // shadows: [
//                             //   Shadow(
//                             //     color: Colors.black.withOpacity(1.0),
//                             //     blurRadius: 14,
//                             //     offset: const Offset(0, 4),
//                             //   ),
//                             // ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





// import 'dart:convert'; 
// import 'package:http/http.dart' as https; 
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:math' as math; 

// // ✅ IMPORT EXIT & EXPIRED SCREENS
// import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// import 'package:mobi_tv_entertainment/plan_expired_screen.dart';

// // ✅ PAGES IMPORTS
// import 'package:mobi_tv_entertainment/components/home_screen_pages/above_18/above_eighteen.dart'; 
// import 'package:mobi_tv_entertainment/components/home_screen_pages/banner_slider_screen/banner_slider_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/kids_shows/kids_channels.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/movies_screen/movies.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_live_screen/live_channel_language_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/manage_tv_shows.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show_pak/tv_show_pak.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/manage_webseries.dart';
// import 'package:mobi_tv_entertainment/components/menu/top_navigation_bar.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/main.dart'; 
// import 'package:provider/provider.dart';
// import 'dart:ui'; 

// class MainDashboardScreen extends StatefulWidget {
//   const MainDashboardScreen({Key? key}) : super(key: key);

//   @override
//   _MainDashboardScreenState createState() => _MainDashboardScreenState();
// }

// class _MainDashboardScreenState extends State<MainDashboardScreen> {
//   bool _isLoading = true;
//   bool _isPlanExpired = false;

//   bool _showContentNetwork = false;
//   bool _showMovies = false;
//   bool _showWebseries = false;
//   bool _showTvShows = false;
//   bool _showTvShowsPak = false;
//   bool _showSports = false;
//   bool _showReligious = false;
//   bool _showKids = false;
//   bool _show18Plus = false;

//   List<String> _menuItems = [];
//   List<String> _pageIdentifiers = [];
//   late List<FocusNode> _menuFocusNodes = [];
//   DateTime _lastSidebarKeyTime = DateTime.now();

//   int _selectedIndex = 0; 
//   int _focusedIndex = 0;  
//   int _topNavSelectedIndex = 0; 
//   final FocusNode _bannerFocusNode = FocusNode();
  
//   late ScrollController _sidebarScrollController;

//   String _serverPin = "";
//   String _apiMessage = "";

//   @override
//   void initState() {
//     super.initState();
//     _sidebarScrollController = ScrollController();
//     _initializeDashboard();
//   }

//   Future<void> _initializeDashboard() async {
//     await _checkPlanStatus();
//     if (_isPlanExpired) return;
//     await _check18PlusStatus();
//     _buildDynamicMenu();

//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _setupDashboardController();
//         if (_menuFocusNodes.isNotEmpty) {
//           FocusScope.of(context).requestFocus(_menuFocusNodes[0]);
          
//           context.read<FocusProvider>().updateLastFocusedIdentifier('activeSidebar');
//           setState(() {
//             _focusedIndex = 0;
//             _selectedIndex = 0;
//           });
//         }
//       });
//     }
//   }

//   Future<void> _checkPlanStatus() async {
//     final String? authKey = SessionManager.authKey;

//     if (authKey == null || authKey.isEmpty) {
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
//         _apiMessage = res['message'] ?? 'Status Unknown';
//         final domainContent = res['domain_content'];

//         if (planExpired) {
//           _isPlanExpired = true;
//           if (Navigator.canPop(context)) Navigator.pop(context);
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(
//               builder: (context) => PlanExpiredScreen(apiMessage: _apiMessage),
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
//           _buildDynamicMenu();
//         }

//         if (planWillExpire) {
//           Future.delayed(const Duration(milliseconds: 200), () {
//             if (mounted) _showExpiryWarningDialog(_apiMessage);
//           });
//         }
//       }
//     } catch (e) {
//       print("Error fetching Plan Status: $e");
//     }
//   }

//   Future<void> _check18PlusStatus() async {
//     try {
//       final url = Uri.parse("https://dashboard.cpplayers.com/api/v3/showabove18");
//       final headers = {
//         "auth-key": SessionManager.authKey,
//         "domain": SessionManager.savedDomain,
//       };
//       final response = await https.get(url, headers: headers);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == true && mounted) {
//           setState(() {
//             _show18Plus = true;
//             _serverPin = data['above18_pin'].toString();
//           });
//         }
//       }
//     } catch (e) {
//       print("Error fetching 18+ status: $e");
//     }
//   }

//   // void _buildDynamicMenu() {
//   //   _menuItems.clear();
//   //   _pageIdentifiers.clear();

//   //   _menuItems.add('LIVE TV');
//   //   _pageIdentifiers.add('liveChannelLanguage');

//   //   if (_showContentNetwork) { _menuItems.add('CONTENTS'); _pageIdentifiers.add('subVod'); }
//   //   if (_showMovies) { _menuItems.add('RECENTLY ADDED'); _pageIdentifiers.add('manageMovies'); }
//   //   if (_showWebseries) { _menuItems.add('WEB SERIES'); _pageIdentifiers.add('manageWebseries'); }
//   //   if (_showTvShows) { _menuItems.add('TV SHOWS'); _pageIdentifiers.add('tvShows'); }
//   //   if (_showTvShowsPak) { _menuItems.add('TV SHOWS PAK'); _pageIdentifiers.add('tvShowPak'); }
//   //   if (_showReligious) { _menuItems.add('RELIGIOUS'); _pageIdentifiers.add('religiousChannels'); }
//   //   if (_showSports) { _menuItems.add('SPORTS'); _pageIdentifiers.add('sports'); }
//   //   if (_showKids) { _menuItems.add('KIDS ZONE'); _pageIdentifiers.add('kids_show'); }
    
//   //   if (_show18Plus) { 
//   //     _menuItems.add('18+'); 
//   //     _pageIdentifiers.add('eighteenPlus'); 
//   //   }

//   //   _menuFocusNodes = List.generate(_menuItems.length, (index) => FocusNode());
//   // }



//   void _buildDynamicMenu() {
//   setState(() { // Add setState here
//     _menuItems.clear();
//     _pageIdentifiers.clear();

//     _menuItems.add('LIVE TV');
//     _pageIdentifiers.add('liveChannelLanguage');

//     if (_showContentNetwork) { _menuItems.add('OTT APPS'); _pageIdentifiers.add('subVod'); }
//     if (_showMovies) { _menuItems.add('LATEST MOVIES'); _pageIdentifiers.add('manageMovies'); }
//     if (_showWebseries) { _menuItems.add('WEB SERIES'); _pageIdentifiers.add('manageWebseries'); }
//     if (_showTvShows) { _menuItems.add('TV SHOWS'); _pageIdentifiers.add('tvShows'); }
//     if (_showTvShowsPak) { _menuItems.add('TV SHOWS PAK'); _pageIdentifiers.add('tvShowPak'); }
//     if (_showReligious) { _menuItems.add('RELIGIOUS'); _pageIdentifiers.add('religiousChannels'); }
//     if (_showSports) { _menuItems.add('SPORTS'); _pageIdentifiers.add('sports'); }
//     if (_showKids) { _menuItems.add('KIDS ZONE'); _pageIdentifiers.add('kids_show'); }
    
//     if (_show18Plus) { 
//       _menuItems.add('18+'); 
//       _pageIdentifiers.add('eighteenPlus'); 
//     }

//     _menuFocusNodes = List.generate(_menuItems.length, (index) => FocusNode());
//   });
// }

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

//   void _setupDashboardController() {
//     final fp = context.read<FocusProvider>();
    
//     if (_menuFocusNodes.isNotEmpty) {
//       fp.registerFocusNode('activeSidebar', _menuFocusNodes[_selectedIndex]);
//     }

//     fp.onDashboardNextPage = () {
//       int maxContentIndex = _menuItems.contains('18+') ? _menuItems.length - 2 : _menuItems.length - 1;
//       if (_selectedIndex < maxContentIndex) {
//         _changePageAndFocus(_selectedIndex + 1);
//       }
//     };

//     fp.onDashboardPrevPage = () {
//       if (_selectedIndex > 0) {
//         _changePageAndFocus(_selectedIndex - 1);
//       } else {
//         fp.requestFocus('watchNow'); 
//       }
//     };

//     fp.onBannerDown = () {
//       if (_pageIdentifiers.isNotEmpty) {
//         fp.requestFocus(_pageIdentifiers[_selectedIndex]);
//       }
//     };
//   }

//   void _changePageAndFocus(int newIndex) {
//     if (newIndex < 0 || newIndex >= _menuItems.length) return;

//     final targetId = _pageIdentifiers[newIndex];
    
//     setState(() {
//       _selectedIndex = newIndex;
//       _focusedIndex = newIndex; 
//     });

//     final fp = context.read<FocusProvider>();
//     fp.registerFocusNode('activeSidebar', _menuFocusNodes[newIndex]);
//     fp.updateLastFocusedIdentifier(targetId); 

//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         fp.requestFocus(targetId);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _sidebarScrollController.dispose();
//     for (var node in _menuFocusNodes) node.dispose();
//     _bannerFocusNode.dispose();
//     super.dispose();
//   }

//   void _showPinDialog() {
//     final TextEditingController _pinController = TextEditingController();
//     final FocusNode _inputFocus = FocusNode();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF2A2D3A),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: const Text("Enter 18+ PIN", style: TextStyle(color: Colors.white)),
//           content: TextField(
//             controller: _pinController,
//             focusNode: _inputFocus,
//             autofocus: true,
//             obscureText: true,
//             keyboardType: TextInputType.number,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               hintText: "Enter PIN",
//               hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
//               enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
//               focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
//             ),
//             onSubmitted: (_) => _validatePin(_pinController.text),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
//             ),
//             TextButton(
//               onPressed: () => _validatePin(_pinController.text),
//               child: const Text("Enter", style: TextStyle(color: Colors.blueAccent)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // void _validatePin(String inputPin) {
//   //   if (inputPin == _serverPin) {
//   //     Navigator.pop(context);
//   //     Navigator.push(
//   //       context,
//   //       MaterialPageRoute(builder: (context) => const AdultMoviesScreen()),
//   //     );
//   //   } else {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text("Invalid PIN"), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
//   //     );
//   //   }
//   // }

//   void _validatePin(String inputPin) {
//     if (inputPin == _serverPin) {
//       Navigator.pop(context); // Dialog band karein
      
//       setState(() {
//         // 18+ wala index dhoondein aur use select karein
//         int adultIndex = _pageIdentifiers.indexOf('eighteenPlus');
//         if (adultIndex != -1) {
//           _selectedIndex = adultIndex;
//           _focusedIndex = adultIndex;
          
//           // Focus ko sidebar se hatakar content par bhejne ke liye (Optional)
//           context.read<FocusProvider>().updateLastFocusedIdentifier('eighteenPlus');
//         }
//       });
      
//       // Content screen ko request focus karein
//       Future.delayed(const Duration(milliseconds: 200), () {
//         if (mounted) context.read<FocusProvider>().requestFocus('eighteenPlus');
//       });

//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Invalid PIN"), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
//       );
//     }
//   }

//   Widget _getDynamicBottomContent() {
//     if (_pageIdentifiers.isEmpty || _selectedIndex >= _pageIdentifiers.length) return const SizedBox.shrink();
    
//     String currentId = _pageIdentifiers[_selectedIndex];
    
//     switch (currentId) {
//       case 'liveChannelLanguage': return const LiveChannelLanguageScreen();
//       case 'subVod': return const HorzontalVod();
//       case 'manageMovies': return const MoviesScreen();
//       case 'manageWebseries': return const ManageWebSeries();
//       case 'tvShows': return const ManageTvShows();
//       case 'tvShowPak': return const TvShowsPak();
//       case 'religiousChannels': return const ManageReligiousShows();
//       case 'sports': return const ManageSports();
//       case 'kids_show': return const ManageKidsShows();
//       case 'eighteenPlus': return const AdultMoviesScreen();
//       default: return const SizedBox.shrink();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
//       );
//     }

//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return 
//     // PopScope(
//     //   canPop: false,
//     //   onPopInvoked: (didPop) {
//     //     if (!didPop) {
//     //       Navigator.of(context).push(
//     //         PageRouteBuilder(
//     //           opaque: false,
//     //           pageBuilder: (context, _, __) => const ExitConfirmationScreen(
//     //             isFromBackButton: true,
//     //           ),
//     //         ),
//     //       );
//     //     }
//     //   },
//     PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (!didPop) {
//           // ✅ FIX: Check karein ki kya focus already sidebar par hai
//           final fp = context.read<FocusProvider>();
//           if (fp.lastFocusedIdentifier != 'activeSidebar') {
//             // Agar contents page (subVod) par hai, toh Exit karne ke bajaye Sidebar par bhejein
//             fp.requestFocus('activeSidebar');
//             return; 
//           }

//           // Agar focus already sidebar par hai, toh Exit screen dikhayein
//           Navigator.of(context).push(
//             PageRouteBuilder(
//               opaque: false,
//               pageBuilder: (context, _, __) => const ExitConfirmationScreen(
//                 isFromBackButton: true,
//               ),
//             ),
//           );
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black, 
//         body: Stack(
//           children: [
//             Positioned.fill(
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: screenHeight * 0.65, 
//                     width: screenWidth, 
//                     child: BannerSlider(
//                       focusNode: _bannerFocusNode,
//                     ),
//                   ),

//                   Expanded(
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child: Container(
//                         key: ValueKey<String>(_pageIdentifiers[_selectedIndex]),
//                         width: screenWidth, 
//                         child: _getDynamicBottomContent(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Sidebar Full Height lega aur Items Center mein rahenge
//             Positioned(
//               left: 0,
//               top: 0, 
//               bottom: 0,
//               child: ClipRRect(
//                 child: 
//                 BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
//                   child: Container(
//                     width: screenWidth * 0.14,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.40), 
//                       border: Border(
//                         right: BorderSide(
//                           color: Colors.white.withOpacity(0.2), 
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: ListView.builder(
//                       controller: _sidebarScrollController, 
//                       clipBehavior: Clip.none, 
//                       // ✅ MAGIC FIX: ListView ke andar 40% vertical space de diya.
//                       // Isse List ka har element properly center tak aa payega.
//                       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.40),
//                       itemCount: _menuItems.length,
//                       itemBuilder: (context, index) {
//                         return AnimatedSidebarItem(
//                           title: _menuItems[index],
//                           focusNode: _menuFocusNodes[index],
//                           isSelected: _selectedIndex == index,
//                           is18PlusItem: _menuItems[index] == '18+',
//                           onTap: () {
//                             if (_menuItems[index] == '18+') {
//                               _showPinDialog();
//                               return;
//                             }
//                             setState(() {
//                               _selectedIndex = index;
//                               _focusedIndex = index;
//                               context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                             });
//                             Future.delayed(const Duration(milliseconds: 100), () {
//                               if (mounted) context.read<FocusProvider>().requestFocus(_pageIdentifiers[index]);
//                             });
//                           },
//                           onFocusChange: (hasFocus) {
//                             if (hasFocus) {
//                               setState(() {
//                                 _focusedIndex = index; 
//                                 context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                               });
//                             } else {
//                               setState(() {}); 
//                             }
//                           },
//                           onKey: (node, event) {
//                             if (event is RawKeyDownEvent) {
//                               if (event.logicalKey == LogicalKeyboardKey.arrowUp || 
//                                   event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                
//                                 final now = DateTime.now();
//                                 if (now.difference(_lastSidebarKeyTime).inMilliseconds < 350) {
//                                    return KeyEventResult.handled; 
//                                 }
//                                 _lastSidebarKeyTime = now; 

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                                   if (index < _menuItems.length - 1) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index + 1]);
//                                   }
//                                   return KeyEventResult.handled;
//                                 }

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                                   if (index > 0) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index - 1]);
//                                   } else {
//                                     context.read<FocusProvider>().requestFocus('topNavigation');
//                                   }
//                                   return KeyEventResult.handled;
//                                 }
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.enter ||
//                                   event.logicalKey == LogicalKeyboardKey.select) {
                                  
//                                  if (_menuItems[index] == '18+') {
//                                    _showPinDialog();
//                                    return KeyEventResult.handled;
//                                  }

                                 

//                                  final fp = context.read<FocusProvider>();
//                                  final targetId = _pageIdentifiers[index];

//                                  fp.updateLastFocusedIdentifier(targetId);

//                                  setState(() {
//                                    _selectedIndex = index; 
//                                    _focusedIndex = index;  
//                                  });

//                                  return KeyEventResult.handled;
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                                 //  if (_menuItems[index] == '18+') return KeyEventResult.handled;
//                                 if (_menuItems[index] == '18+') {
//     // Agar page abhi tak selected nahi hai (yaani PIN nahi dala), toh PIN maangein
//     if (_selectedIndex != index) {
//       _showPinDialog();
//       return KeyEventResult.handled;
//     }
//     // Agar page pehle se selected hai, toh direct content (AdultMoviesScreen) par focus bhej dein
//     context.read<FocusProvider>().requestFocus('eighteenPlus'); 
//     return KeyEventResult.handled;
//   }

//                                  setState(() {
//                                    _selectedIndex = index;
//                                    _focusedIndex = index;
//                                  });

//                                  context.read<FocusProvider>().requestFocus(_pageIdentifiers[_selectedIndex]);
//                                  return KeyEventResult.handled;
//                               }
//                             }
//                             return KeyEventResult.ignored;
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: SizedBox(
//                 height: screenHeight * 0.24, 
//                 child: TopNavigationBar(
//                   selectedPage: _topNavSelectedIndex,
//                   tvenableAll: true,
//                   onPageSelected: (index) => setState(() => _topNavSelectedIndex = index),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// class AnimatedSidebarItem extends StatefulWidget {
//   final String title;
//   final FocusNode focusNode;
//   final bool isSelected;
//   final bool is18PlusItem;
//   final VoidCallback onTap;
//   final ValueChanged<bool> onFocusChange; 
//   final FocusOnKeyCallback onKey;         

//   const AnimatedSidebarItem({
//     Key? key,
//     required this.title,
//     required this.focusNode,
//     required this.isSelected,
//     required this.is18PlusItem,
//     required this.onTap,
//     required this.onFocusChange,
//     required this.onKey,
//   }) : super(key: key);

//   @override
//   _AnimatedSidebarItemState createState() => _AnimatedSidebarItemState();
// }

// class _AnimatedSidebarItemState extends State<AnimatedSidebarItem> with SingleTickerProviderStateMixin {
//   late AnimationController _borderAnimationController;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _borderAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 2500),
//       vsync: this,
//     );
//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (mounted) {
//       setState(() {
//         _isFocused = widget.focusNode.hasFocus;
//       });
//       if (_isFocused) {
//         _borderAnimationController.repeat();
        
//         // ✅ SMOOTH SCROLLING FIX
//         // 50ms ka delay diya taaki UI pehle border paint kar le,
//         // phir bina frame drop ke smoothly scroll kare.
//         Future.delayed(const Duration(milliseconds: 50), () {
//           if (mounted) {
//             Scrollable.ensureVisible(
//               context,
//               alignment: 0.5, 
//               duration: const Duration(milliseconds: 350), // Thoda zyada time smooth slide ke liye
//               curve: Curves.easeOutCubic, // Premium glide effect
//             );
//           }
//         });

//       } else {
//         _borderAnimationController.stop();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _borderAnimationController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       focusNode: widget.focusNode,
//       onFocusChange: widget.onFocusChange,
//       onKey: widget.onKey,
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: Container(
//           height: 48, 
//           margin: const EdgeInsets.only(left: 25, right: 10, top: 3, bottom: 3), 
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: _isFocused
//                 ? [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))]
//                 : [],
//           ),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               if (_isFocused)
//                 AnimatedBuilder(
//                   animation: _borderAnimationController,
//                   builder: (context, child) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         gradient: SweepGradient(
//                           colors: [
//                             Colors.white.withOpacity(0.1),
//                             Colors.white,
//                             Colors.white,
//                             Colors.white.withOpacity(0.1),
//                           ],
//                           stops: const [0.0, 0.25, 0.5, 1.0],
//                           transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
//                         ),
//                       ),
//                     );
//                   },
//                 ),

//               Padding(
//                 padding: EdgeInsets.all(_isFocused ? 5.0 : 0.0), 
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: _isFocused 
//                         ? Colors.black 
//                         : (widget.isSelected ? Colors.black.withOpacity(0.15) : Colors.transparent),
//                     borderRadius: BorderRadius.circular(_isFocused ? 4 : 8),
//                   ),
//                   child: Center(
//                     child: Text(
//                       widget.title,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: _isFocused 
//                             ? Colors.white 
//                             : (widget.isSelected ? Colors.black87 : Colors.black87),
//                         fontSize: _isFocused ? 13 : 11,
//                         fontWeight: _isFocused || widget.isSelected ? FontWeight.w900 : FontWeight.w700,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'dart:convert'; 
// import 'package:http/http.dart' as https; 
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/live_sports_screen/live_sports_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sd_movies_screen/sd_movies_screen.dart';
// import 'dart:math' as math; 

// // ✅ IMPORT EXIT & EXPIRED SCREENS
// import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// import 'package:mobi_tv_entertainment/plan_expired_screen.dart';

// // ✅ PAGES IMPORTS
// import 'package:mobi_tv_entertainment/components/home_screen_pages/above_18/above_eighteen.dart'; 
// import 'package:mobi_tv_entertainment/components/home_screen_pages/banner_slider_screen/banner_slider_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/kids_shows/kids_channels.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/movies_screen/movies.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_live_screen/live_channel_language_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/manage_tv_shows.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show_pak/tv_show_pak.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/manage_webseries.dart';
// import 'package:mobi_tv_entertainment/components/menu/top_navigation_bar.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/main.dart'; 
// import 'package:provider/provider.dart';
// import 'dart:ui'; 

// class MainDashboardScreen extends StatefulWidget {
//   const MainDashboardScreen({Key? key}) : super(key: key);

//   @override
//   _MainDashboardScreenState createState() => _MainDashboardScreenState();
// }

// // ✅ ADDED: AutomaticKeepAliveClientMixin to keep the state alive when navigating back
// class _MainDashboardScreenState extends State<MainDashboardScreen> with AutomaticKeepAliveClientMixin {
  
//   // ✅ ADDED: Required for AutomaticKeepAliveClientMixin
//   @override
//   bool get wantKeepAlive => true;

//   bool _isLoading = true;
//   bool _isPlanExpired = false;

//   bool _showContentNetwork = false;
//   bool _showMovies = false;
//   bool _showSdMovies = false;
//   bool _showWebseries = false;
//   bool _showTvShows = false;
//   bool _showTvShowsPak = false;
//   bool _showSports = false;
//   bool _showReligious = false;
//   bool _showKids = false;
//   bool _show18Plus = false;

//   List<String> _menuItems = [];
//   List<String> _pageIdentifiers = [];
//   late List<FocusNode> _menuFocusNodes = [];
//   DateTime _lastSidebarKeyTime = DateTime.now();

//   int _selectedIndex = 0; 
//   int _focusedIndex = 0;  
//   int _topNavSelectedIndex = 0; 
//   final FocusNode _bannerFocusNode = FocusNode();
  
//   late ScrollController _sidebarScrollController;

//   String _serverPin = "";
//   String _apiMessage = "";

//   @override
//   void initState() {
//     super.initState();
//     _sidebarScrollController = ScrollController();
//     _initializeDashboard();
//   }

//   Future<void> _initializeDashboard() async {
//     await _checkPlanStatus();
//     if (_isPlanExpired) return;
//     await _check18PlusStatus();
//     _buildDynamicMenu();

//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _setupDashboardController();
//         if (_menuFocusNodes.isNotEmpty) {
//           FocusScope.of(context).requestFocus(_menuFocusNodes[0]);
          
//           context.read<FocusProvider>().updateLastFocusedIdentifier('activeSidebar');
//           setState(() {
//             _focusedIndex = 0;
//             _selectedIndex = 0;
//           });
//         }
//       });
//     }
//   }

//   // ✅ ADDED: Function to load cached data if the API fails
//   void _loadCachedMenuSettings() {
//     try {
//       // Make sure you add getSavedDomainContent() to your SessionManager class
//       String? cachedData = SessionManager.getSavedDomainContent();
//       if (cachedData != null && cachedData.isNotEmpty) {
//         Map<String, dynamic> domainContent = json.decode(cachedData);
//         setState(() {
//           _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//           _showMovies = (domainContent['movies'] ?? 0) == 1;
//           // _showSdMovies = (domainContent['sd_movies'] ?? 0) == 1;
//           _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//           _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//           // _showTvShowsPak = (domainContent['tvshow_pak'] ?? 0) == 1;
//           // _showSports = (domainContent['sports'] ?? 0) == 1;
//           // _showReligious = (domainContent['religious'] ?? 0) == 1;
//           _showKids = (domainContent['kids_show'] ?? 0) == 1;
//         });
//         _buildDynamicMenu();
//       }
//     } catch (e) {
//       print("Error loading cached settings: $e");
//     }
//   }

//   Future<void> _checkPlanStatus() async {
//     final String? authKey = SessionManager.authKey;

//     if (authKey == null || authKey.isEmpty) {
//       _loadCachedMenuSettings(); // ✅ Load cache if auth key is missing
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
//         _apiMessage = res['message'] ?? 'Status Unknown';
//         final domainContent = res['domain_content'];

//         if (planExpired) {
//           _isPlanExpired = true;
//           if (Navigator.canPop(context)) Navigator.pop(context);
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(
//               builder: (context) => PlanExpiredScreen(apiMessage: _apiMessage),
//             ),
//             (route) => false,
//           );
//           return;
//         }

//         if (domainContent != null && domainContent is Map) {
//           // ✅ ADDED: Save this successful data locally for next time
//           SessionManager.saveDomainContent(json.encode(domainContent));

//           setState(() {
//             _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//             _showMovies = (domainContent['movies'] ?? 0) == 1;
//             // _showSdMovies = (domainContent['sd_movies'] ?? 0) == 1;
//             _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//             _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//             // _showTvShowsPak = (domainContent['tvshow_pak'] ?? 0) == 1;
//             // _showSports = (domainContent['sports'] ?? 0) == 1;
//             // _showReligious = (domainContent['religious'] ?? 0) == 1;
//             _showKids = (domainContent['kids_show'] ?? 0) == 1;
//           });
//           _buildDynamicMenu();
//         }

//         if (planWillExpire) {
//           Future.delayed(const Duration(milliseconds: 200), () {
//             if (mounted) _showExpiryWarningDialog(_apiMessage);
//           });
//         }
//       } else {
//         // ✅ ADDED: If API fails with non-200 code, load cached settings
//         _loadCachedMenuSettings();
//       }
//     } catch (e) {
//       print("Error fetching Plan Status: $e");
//       // ✅ ADDED: If no internet or timeout, load cached settings instead of empty menu
//       _loadCachedMenuSettings();
//     }
//   }

//   Future<void> _check18PlusStatus() async {
//     try {
//       final url = Uri.parse(SessionManager.baseUrl + 'showabove18');
//       final headers = {
//         "auth-key": SessionManager.authKey,
//         "domain": SessionManager.savedDomain,
//       };
//       final response = await https.get(url, headers: headers);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == true && mounted) {
//           setState(() {
//             _show18Plus = true;
//             _serverPin = data['above18_pin'].toString();
//           });
//         }
//       }
//     } catch (e) {
//       print("Error fetching 18+ status: $e");
//     }
//   }

//   void _buildDynamicMenu() {
//     setState(() { 
//       _menuItems.clear();
//       _pageIdentifiers.clear();

//       _menuItems.add('LIVE TV');
//       _pageIdentifiers.add('liveChannelLanguage');
//       _menuItems.add('LIVE SPORTS');
//       _pageIdentifiers.add('liveSports');

//       if (_showContentNetwork) { _menuItems.add('OTT APPS'); _pageIdentifiers.add('subVod'); }
//       if (_showMovies) { _menuItems.add('LATEST 4K MOVIES'); _pageIdentifiers.add('manageMovies'); }
//       // if (_showSdMovies) { _menuItems.add('LATEST SD MOVIES'); _pageIdentifiers.add('manageSdMovies'); }
//       if (_showWebseries) { _menuItems.add('WEB SERIES'); _pageIdentifiers.add('manageWebseries'); }
//       if (_showTvShows) { _menuItems.add('TV SHOWS'); _pageIdentifiers.add('tvShows'); }
//       // if (_showTvShowsPak) { _menuItems.add('TV SHOWS PAK'); _pageIdentifiers.add('tvShowPak'); }
//       // if (_showReligious) { _menuItems.add('RELIGIOUS'); _pageIdentifiers.add('religiousChannels'); }
//       // if (_showSports) { _menuItems.add('SPORTS'); _pageIdentifiers.add('sports'); }
//       if (_showKids) { _menuItems.add('KIDS ZONE'); _pageIdentifiers.add('kids_show'); }
      
//       if (_show18Plus) { 
//         _menuItems.add('18+'); 
//         _pageIdentifiers.add('eighteenPlus'); 
//       }

//       _menuFocusNodes = List.generate(_menuItems.length, (index) => FocusNode());
//     });
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

//   void _setupDashboardController() {
//     final fp = context.read<FocusProvider>();
    
//     if (_menuFocusNodes.isNotEmpty) {
//       fp.registerFocusNode('activeSidebar', _menuFocusNodes[_selectedIndex]);
//     }

//     fp.onDashboardNextPage = () {
//       int maxContentIndex = _menuItems.contains('18+') ? _menuItems.length - 2 : _menuItems.length - 1;
//       if (_selectedIndex < maxContentIndex) {
//         _changePageAndFocus(_selectedIndex + 1);
//       }
//     };

//     fp.onDashboardPrevPage = () {
//       if (_selectedIndex > 0) {
//         _changePageAndFocus(_selectedIndex - 1);
//       } else {
//         fp.requestFocus('watchNow'); 
//       }
//     };

//     fp.onBannerDown = () {
//       if (_pageIdentifiers.isNotEmpty) {
//         fp.requestFocus(_pageIdentifiers[_selectedIndex]);
//       }
//     };
//   }

//   void _changePageAndFocus(int newIndex) {
//     if (newIndex < 0 || newIndex >= _menuItems.length) return;

//     final targetId = _pageIdentifiers[newIndex];
    
//     setState(() {
//       _selectedIndex = newIndex;
//       _focusedIndex = newIndex; 
//     });

//     final fp = context.read<FocusProvider>();
//     fp.registerFocusNode('activeSidebar', _menuFocusNodes[newIndex]);
//     fp.updateLastFocusedIdentifier(targetId); 

//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         fp.requestFocus(targetId);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _sidebarScrollController.dispose();
//     for (var node in _menuFocusNodes) node.dispose();
//     _bannerFocusNode.dispose();
//     super.dispose();
//   }

//   void _showPinDialog() {
//     final TextEditingController _pinController = TextEditingController();
//     final FocusNode _inputFocus = FocusNode();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF2A2D3A),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: const Text("Enter 18+ PIN", style: TextStyle(color: Colors.white)),
//           content: TextField(
//             controller: _pinController,
//             focusNode: _inputFocus,
//             autofocus: true,
//             obscureText: true,
//             keyboardType: TextInputType.number,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               hintText: "Enter PIN",
//               hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
//               enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
//               focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
//             ),
//             onSubmitted: (_) => _validatePin(_pinController.text),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
//             ),
//             TextButton(
//               onPressed: () => _validatePin(_pinController.text),
//               child: const Text("Enter", style: TextStyle(color: Colors.blueAccent)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _validatePin(String inputPin) {
//     if (inputPin == _serverPin) {
//       Navigator.pop(context); // Dialog band karein
      
//       setState(() {
//         // 18+ wala index dhoondein aur use select karein
//         int adultIndex = _pageIdentifiers.indexOf('eighteenPlus');
//         if (adultIndex != -1) {
//           _selectedIndex = adultIndex;
//           _focusedIndex = adultIndex;
          
//           // Focus ko sidebar se hatakar content par bhejne ke liye (Optional)
//           context.read<FocusProvider>().updateLastFocusedIdentifier('eighteenPlus');
//         }
//       });
      
//       // Content screen ko request focus karein
//       Future.delayed(const Duration(milliseconds: 200), () {
//         if (mounted) context.read<FocusProvider>().requestFocus('eighteenPlus');
//       });

//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Invalid PIN"), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
//       );
//     }
//   }

//   Widget _getDynamicBottomContent() {
//     if (_pageIdentifiers.isEmpty || _selectedIndex >= _pageIdentifiers.length) return const SizedBox.shrink();
    
//     String currentId = _pageIdentifiers[_selectedIndex];
    
//     switch (currentId) {
//       case 'liveChannelLanguage': return const LiveChannelLanguageScreen();
//       case 'liveSports': return const LiveSportsScreen();
//       case 'subVod': return const HorzontalVod();
//       case 'manageMovies': return const MoviesScreen();
//       case 'manageSdMovies': return const SdMoviesScreen();
//       case 'manageWebseries': return const ManageWebSeries();
//       case 'tvShows': return const ManageTvShows();
//       // case 'tvShowPak': return const TvShowsPak();
//       // case 'religiousChannels': return const ManageReligiousShows();
//       case 'sports': return const ManageSports();
//       case 'kids_show': return const ManageKidsShows();
//       case 'eighteenPlus': return const AdultMoviesScreen();
//       default: return const SizedBox.shrink();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ✅ ADDED: This is required when using AutomaticKeepAliveClientMixin
//     super.build(context);

//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
//       );
//     }

//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (!didPop) {
//           final fp = context.read<FocusProvider>();
//           if (fp.lastFocusedIdentifier != 'activeSidebar') {
//             fp.requestFocus('activeSidebar');
//             return; 
//           }

//           Navigator.of(context).push(
//             PageRouteBuilder(
//               opaque: false,
//               pageBuilder: (context, _, __) => const ExitConfirmationScreen(
//                 isFromBackButton: true,
//               ),
//             ),
//           );
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black, 
//         body: Stack(
//           children: [
//             Positioned.fill(
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: screenHeight * 0.65, 
//                     width: screenWidth, 
//                     child: BannerSlider(
//                       focusNode: _bannerFocusNode,
//                     ),
//                   ),

//                   Expanded(
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child: Container(
//                         key: ValueKey<String>(_pageIdentifiers[_selectedIndex]),
//                         width: screenWidth, 
//                         child: _getDynamicBottomContent(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Positioned(
//               left: 0,
//               top: 0, 
//               bottom: 0,
//               child: ClipRRect(
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
//                   child: Container(
//                     width: screenWidth * 0.14,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.40), 
//                       border: Border(
//                         right: BorderSide(
//                           color: Colors.white.withOpacity(0.2), 
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: ListView.builder(
//                       controller: _sidebarScrollController, 
//                       clipBehavior: Clip.none, 
//                       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.40),
//                       itemCount: _menuItems.length,
//                       itemBuilder: (context, index) {
//                         return AnimatedSidebarItem(
//                           title: _menuItems[index],
//                           focusNode: _menuFocusNodes[index],
//                           isSelected: _selectedIndex == index,
//                           is18PlusItem: _menuItems[index] == '18+',
//                           onTap: () {
//                             if (_menuItems[index] == '18+') {
//                               _showPinDialog();
//                               return;
//                             }
//                             setState(() {
//                               _selectedIndex = index;
//                               _focusedIndex = index;
//                               context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                             });
//                             Future.delayed(const Duration(milliseconds: 100), () {
//                               if (mounted) context.read<FocusProvider>().requestFocus(_pageIdentifiers[index]);
//                             });
//                           },
//                           onFocusChange: (hasFocus) {
//                             if (hasFocus) {
//                               setState(() {
//                                 _focusedIndex = index; 
//                                 context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                               });
//                             } else {
//                               setState(() {}); 
//                             }
//                           },
//                           onKey: (node, event) {
//                             if (event is RawKeyDownEvent) {
//                               if (event.logicalKey == LogicalKeyboardKey.arrowUp || 
//                                   event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                
//                                 final now = DateTime.now();
//                                 if (now.difference(_lastSidebarKeyTime).inMilliseconds < 350) {
//                                    return KeyEventResult.handled; 
//                                 }
//                                 _lastSidebarKeyTime = now; 

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                                   if (index < _menuItems.length - 1) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index + 1]);
//                                   }
//                                   return KeyEventResult.handled;
//                                 }

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                                   if (index > 0) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index - 1]);
//                                   } else {
//                                     context.read<FocusProvider>().requestFocus('topNavigation');
//                                   }
//                                   return KeyEventResult.handled;
//                                 }
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.enter ||
//                                   event.logicalKey == LogicalKeyboardKey.select) {
                                 
//                                  if (_menuItems[index] == '18+') {
//                                    _showPinDialog();
//                                    return KeyEventResult.handled;
//                                  }

//                                  final fp = context.read<FocusProvider>();
//                                  final targetId = _pageIdentifiers[index];

//                                  fp.updateLastFocusedIdentifier(targetId);

//                                  setState(() {
//                                    _selectedIndex = index; 
//                                    _focusedIndex = index;  
//                                  });

//                                  return KeyEventResult.handled;
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                                 if (_menuItems[index] == '18+') {
//                                   if (_selectedIndex != index) {
//                                     _showPinDialog();
//                                     return KeyEventResult.handled;
//                                   }
//                                   context.read<FocusProvider>().requestFocus('eighteenPlus'); 
//                                   return KeyEventResult.handled;
//                                 }

//                                  setState(() {
//                                    _selectedIndex = index;
//                                    _focusedIndex = index;
//                                  });

//                                  context.read<FocusProvider>().requestFocus(_pageIdentifiers[_selectedIndex]);
//                                  return KeyEventResult.handled;
//                               }
//                             }
//                             return KeyEventResult.ignored;
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: SizedBox(
//                 height: screenHeight * 0.24, 
//                 child: TopNavigationBar(
//                   selectedPage: _topNavSelectedIndex,
//                   tvenableAll: true,
//                   onPageSelected: (index) => setState(() => _topNavSelectedIndex = index),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// class AnimatedSidebarItem extends StatefulWidget {
//   final String title;
//   final FocusNode focusNode;
//   final bool isSelected;
//   final bool is18PlusItem;
//   final VoidCallback onTap;
//   final ValueChanged<bool> onFocusChange; 
//   final FocusOnKeyCallback onKey;         

//   const AnimatedSidebarItem({
//     Key? key,
//     required this.title,
//     required this.focusNode,
//     required this.isSelected,
//     required this.is18PlusItem,
//     required this.onTap,
//     required this.onFocusChange,
//     required this.onKey,
//   }) : super(key: key);

//   @override
//   _AnimatedSidebarItemState createState() => _AnimatedSidebarItemState();
// }

// class _AnimatedSidebarItemState extends State<AnimatedSidebarItem> with SingleTickerProviderStateMixin {
//   late AnimationController _borderAnimationController;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _borderAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 2500),
//       vsync: this,
//     );
//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (mounted) {
//       setState(() {
//         _isFocused = widget.focusNode.hasFocus;
//       });
//       if (_isFocused) {
//         _borderAnimationController.repeat();
        
//         Future.delayed(const Duration(milliseconds: 50), () {
//           if (mounted) {
//             Scrollable.ensureVisible(
//               context,
//               alignment: 0.5, 
//               duration: const Duration(milliseconds: 350), 
//               curve: Curves.easeOutCubic, 
//             );
//           }
//         });

//       } else {
//         _borderAnimationController.stop();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _borderAnimationController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       focusNode: widget.focusNode,
//       onFocusChange: widget.onFocusChange,
//       onKey: widget.onKey,
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: Container(
//           height: 48, 
//           margin: const EdgeInsets.only(left: 25, right: 10, top: 3, bottom: 3), 
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: _isFocused
//                 ? [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))]
//                 : [],
//           ),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               if (_isFocused)
//                 AnimatedBuilder(
//                   animation: _borderAnimationController,
//                   builder: (context, child) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         gradient: SweepGradient(
//                           colors: [
//                             Colors.white.withOpacity(0.1),
//                             Colors.white,
//                             Colors.white,
//                             Colors.white.withOpacity(0.1),
//                           ],
//                           stops: const [0.0, 0.25, 0.5, 1.0],
//                           transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
//                         ),
//                       ),
//                     );
//                   },
//                 ),

//               Padding(
//                 padding: EdgeInsets.all(_isFocused ? 5.0 : 0.0), 
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: _isFocused 
//                         ? Colors.black 
//                         : (widget.isSelected ? Colors.black.withOpacity(0.15) : Colors.transparent),
//                     borderRadius: BorderRadius.circular(_isFocused ? 4 : 8),
//                   ),
//                   child: Center(
//                     child: Text(
//                       widget.title,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: _isFocused 
//                             ? Colors.white 
//                             : (widget.isSelected ? Colors.black87 : Colors.black87),
//                         fontSize: _isFocused ? 13 : 11,
//                         fontWeight: _isFocused || widget.isSelected ? FontWeight.w900 : FontWeight.w700,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }









// import 'dart:convert';
// import 'dart:io'; 
// import 'package:http/http.dart' as https; 
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/live_kids_screen/live_kids_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/live_sports_screen/live_sports_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sd_movies_screen/sd_movies_screen.dart';
// import 'dart:math' as math; 

// // ✅ IMPORT EXIT & EXPIRED SCREENS
// import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// // Agar neeche error aaye toh is import ko comment kar dena kyunki class yahi neeche likhi hai
// // import 'package:mobi_tv_entertainment/plan_expired_screen.dart';

// // ✅ PAGES IMPORTS
// import 'package:mobi_tv_entertainment/components/home_screen_pages/above_18/above_eighteen.dart'; 
// import 'package:mobi_tv_entertainment/components/home_screen_pages/banner_slider_screen/banner_slider_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/kids_shows/kids_channels.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/movies_screen/movies.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_live_screen/live_channel_language_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/manage_tv_shows.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show_pak/tv_show_pak.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/manage_webseries.dart';
// import 'package:mobi_tv_entertainment/components/menu/top_navigation_bar.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/main.dart'; 
// import 'package:provider/provider.dart';
// import 'dart:ui'; 

// class MainDashboardScreen extends StatefulWidget {
//   const MainDashboardScreen({Key? key}) : super(key: key);

//   @override
//   _MainDashboardScreenState createState() => _MainDashboardScreenState();
// }

// class _MainDashboardScreenState extends State<MainDashboardScreen> with AutomaticKeepAliveClientMixin {
  
//   @override
//   bool get wantKeepAlive => true;

//   bool _isLoading = true;
//   bool _isPlanExpired = false;

//   // ✅ VARIABLES FOR OVERLAY LOGIC
//   bool _shouldShowExpiryWarning = false;
//   bool _showExpiryOverlay = false;
//   int _daysLeft = 0;
//   final FocusNode _warningOkFocusNode = FocusNode();

//   bool _showContentNetwork = false;
//   bool _showMovies = false;
//   bool _showSdMovies = false;
//   bool _showWebseries = false;
//   bool _showTvShows = false;
//   bool _showTvShowsPak = false;
//   bool _showSports = false;
//   bool _showReligious = false;
//   bool _showKids = false;
//   bool _show18Plus = false;

//   List<String> _menuItems = [];
//   List<String> _pageIdentifiers = [];
//   late List<FocusNode> _menuFocusNodes = [];
//   DateTime _lastSidebarKeyTime = DateTime.now();

//   int _selectedIndex = 0; 
//   int _focusedIndex = 0;  
//   int _topNavSelectedIndex = 0; 
//   final FocusNode _bannerFocusNode = FocusNode();
  
//   late ScrollController _sidebarScrollController;

//   String _serverPin = "";
//   String _apiMessage = "";

//   @override
//   void initState() {
//     super.initState();
//     _sidebarScrollController = ScrollController();
//     _initializeDashboard();
//   }

//   Future<void> _initializeDashboard() async {
//     // 1. API se status check karein
//     await _checkPlanStatus();

//     if (!mounted) return;

//     // ✅ FIX: GUARANTEED RENDER LOGIC
//     // Agar plan expired hai toh yahan State update karke turant return ho jayein
//     if (_isPlanExpired) {
//       setState(() {
//         _isLoading = false; 
//       });
//       return; 
//     }

//     // 2. Agar plan active hai toh aage badhein
//     await _check18PlusStatus();
//     _buildDynamicMenu();

//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _setupDashboardController();
        
//         if (_menuFocusNodes.isNotEmpty) {
//           setState(() {
//             _focusedIndex = 0;
//             _selectedIndex = 0;
//           });
//         }

//         // ✅ WARNING OVERLAY LOGIC
//         if (_shouldShowExpiryWarning && mounted) {
//           setState(() {
//             _showExpiryOverlay = true;
//           });
          
//           Future.delayed(const Duration(milliseconds: 100), () {
//             if (mounted) FocusScope.of(context).requestFocus(_warningOkFocusNode);
//           });

//           // 5 SECOND AUTO-DISMISS LOGIC
//           Future.delayed(const Duration(seconds: 5), () {
//             if (mounted && _showExpiryOverlay) {
//               _dismissWarningOverlay();
//             }
//           });

//         } else if (_menuFocusNodes.isNotEmpty) {
//           FocusScope.of(context).requestFocus(_menuFocusNodes[0]);
//           context.read<FocusProvider>().updateLastFocusedIdentifier('activeSidebar');
//         }
//       });
//     }
//   }

//   void _dismissWarningOverlay() {
//     setState(() {
//       _showExpiryOverlay = false;
//     });
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (mounted && _menuFocusNodes.isNotEmpty) {
//         FocusScope.of(context).requestFocus(_menuFocusNodes[_selectedIndex]);
//         context.read<FocusProvider>().updateLastFocusedIdentifier('activeSidebar');
//       }
//     });
//   }

//   void _loadCachedMenuSettings() {
//     try {
//       String? cachedData = SessionManager.getSavedDomainContent();
//       if (cachedData != null && cachedData.isNotEmpty) {
//         Map<String, dynamic> domainContent = json.decode(cachedData);
//         setState(() {
//           _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//           _showMovies = (domainContent['movies'] ?? 0) == 1;
//           _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//           _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//           _showKids = (domainContent['kids_show'] ?? 0) == 1;
//         });
//         _buildDynamicMenu();
//       }
//     } catch (e) {
//       print("Error loading cached settings: $e");
//     }
//   }

//   Future<void> _checkPlanStatus() async {
//     final String? authKey = SessionManager.authKey;

//     if (authKey == null || authKey.isEmpty) {
//       _loadCachedMenuSettings(); 
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

//         final String expireValue = res['plan_expired'].toString().toLowerCase();
//         bool planExpired = (expireValue == 'true' || expireValue == '1');

//         final int daysLeft = res['days'] ?? 99;
//         _daysLeft = daysLeft;
//         bool planWillExpire = (daysLeft <= 3);

//         _apiMessage = res['message'] ?? 'Status Unknown';
//         final domainContent = res['domain_content'];

//         if (planExpired) {
//           _isPlanExpired = true; // Yahan sirf isko true karna hai
//           return; 
//         }

//         if (domainContent != null && domainContent is Map) {
//           SessionManager.saveDomainContent(json.encode(domainContent));

//           setState(() {
//             _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//             _showMovies = (domainContent['movies'] ?? 0) == 1;
//             _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//             _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//             _showKids = (domainContent['kids_show'] ?? 0) == 1;
//           });
//           _buildDynamicMenu();
//         }

//         if (planWillExpire) {
//           _shouldShowExpiryWarning = true;
//         }
//       } else {
//         _loadCachedMenuSettings();
//       }
//     } catch (e) {
//       print("Error fetching Plan Status: $e");
//       _loadCachedMenuSettings();
//     }
//   }

//   Future<void> _check18PlusStatus() async {
//     try {
//       final url = Uri.parse(SessionManager.baseUrl + 'showabove18');
//       final headers = {
//         "auth-key": SessionManager.authKey,
//         "domain": SessionManager.savedDomain,
//       };
//       final response = await https.get(url, headers: headers);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == true && mounted) {
//           setState(() {
//             _show18Plus = true;
//             _serverPin = data['above18_pin'].toString();
//           });
//         }
//       }
//     } catch (e) {
//       print("Error fetching 18+ status: $e");
//     }
//   }

//   void _buildDynamicMenu() {
//     setState(() { 
//       _menuItems.clear();
//       _pageIdentifiers.clear();

//       _menuItems.add('LIVE TV');
//       _pageIdentifiers.add('liveChannelLanguage');
//       _menuItems.add('LIVE SPORTS');
//       _pageIdentifiers.add('liveSports');

//       if (_showContentNetwork) { _menuItems.add('OTT APPS'); _pageIdentifiers.add('subVod'); }
//       if (_showMovies) { _menuItems.add('LATEST 4K MOVIES'); _pageIdentifiers.add('manageMovies'); }
//       if (_showWebseries) { _menuItems.add('WEB SERIES'); _pageIdentifiers.add('manageWebseries'); }
//       if (_showTvShows) { _menuItems.add('TV SHOWS'); _pageIdentifiers.add('tvShows'); }
//       if (_showKids) { _menuItems.add('KIDS ZONE'); _pageIdentifiers.add('kids_show'); }
      
//       if (_show18Plus) { 
//         _menuItems.add('18+'); 
//         _pageIdentifiers.add('eighteenPlus'); 
//       }

//       _menuFocusNodes = List.generate(_menuItems.length, (index) => FocusNode());
//     });
//   }

//   void _setupDashboardController() {
//     final fp = context.read<FocusProvider>();
    
//     if (_menuFocusNodes.isNotEmpty) {
//       fp.registerFocusNode('activeSidebar', _menuFocusNodes[_selectedIndex]);
//     }

//     fp.onDashboardNextPage = () {
//       if (_showExpiryOverlay) return; // Prevent focus interaction
//       int maxContentIndex = _menuItems.contains('18+') ? _menuItems.length - 2 : _menuItems.length - 1;
//       if (_selectedIndex < maxContentIndex) {
//         _changePageAndFocus(_selectedIndex + 1);
//       }
//     };

//     fp.onDashboardPrevPage = () {
//       if (_showExpiryOverlay) return; // Prevent focus interaction
//       if (_selectedIndex > 0) {
//         _changePageAndFocus(_selectedIndex - 1);
//       } else {
//         fp.requestFocus('watchNow'); 
//       }
//     };

//     fp.onBannerDown = () {
//       if (_showExpiryOverlay) return; // Prevent focus interaction
//       if (_pageIdentifiers.isNotEmpty) {
//         fp.requestFocus(_pageIdentifiers[_selectedIndex]);
//       }
//     };
//   }

//   void _changePageAndFocus(int newIndex) {
//     if (newIndex < 0 || newIndex >= _menuItems.length) return;

//     final targetId = _pageIdentifiers[newIndex];
    
//     setState(() {
//       _selectedIndex = newIndex;
//       _focusedIndex = newIndex; 
//     });

//     final fp = context.read<FocusProvider>();
//     fp.registerFocusNode('activeSidebar', _menuFocusNodes[newIndex]);
//     fp.updateLastFocusedIdentifier(targetId); 

//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         fp.requestFocus(targetId);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _sidebarScrollController.dispose();
//     for (var node in _menuFocusNodes) node.dispose();
//     _bannerFocusNode.dispose();
//     _warningOkFocusNode.dispose(); 
//     super.dispose();
//   }

//   void _showPinDialog() {
//     final TextEditingController _pinController = TextEditingController();
//     final FocusNode _inputFocus = FocusNode();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF2A2D3A),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: const Text("Enter 18+ PIN", style: TextStyle(color: Colors.white)),
//           content: TextField(
//             controller: _pinController,
//             focusNode: _inputFocus,
//             autofocus: true,
//             obscureText: true,
//             keyboardType: TextInputType.number,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               hintText: "Enter PIN",
//               hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
//               enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
//               focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
//             ),
//             onSubmitted: (_) => _validatePin(_pinController.text),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
//             ),
//             TextButton(
//               onPressed: () => _validatePin(_pinController.text),
//               child: const Text("Enter", style: TextStyle(color: Colors.blueAccent)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _validatePin(String inputPin) {
//     if (inputPin == _serverPin) {
//       Navigator.pop(context); 
      
//       setState(() {
//         int adultIndex = _pageIdentifiers.indexOf('eighteenPlus');
//         if (adultIndex != -1) {
//           _selectedIndex = adultIndex;
//           _focusedIndex = adultIndex;
          
//           context.read<FocusProvider>().updateLastFocusedIdentifier('eighteenPlus');
//         }
//       });
      
//       Future.delayed(const Duration(milliseconds: 200), () {
//         if (mounted) context.read<FocusProvider>().requestFocus('eighteenPlus');
//       });

//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Invalid PIN"), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
//       );
//     }
//   }

//   Widget _getDynamicBottomContent() {
//     if (_pageIdentifiers.isEmpty || _selectedIndex >= _pageIdentifiers.length) return const SizedBox.shrink();
    
//     String currentId = _pageIdentifiers[_selectedIndex];
    
//     switch (currentId) {
//       case 'liveChannelLanguage': return const LiveChannelLanguageScreen();
//       case 'liveSports': return const LiveSportsScreen();
//       case 'subVod': return const HorzontalVod();
//       case 'manageMovies': return const MoviesScreen();
//       case 'manageSdMovies': return const SdMoviesScreen();
//       case 'manageWebseries': return const ManageWebSeries();
//       case 'tvShows': return const ManageTvShows();
//       case 'sports': return const ManageSports();
//       case 'kids_show': return const ManageKidsShows();
//       case 'eighteenPlus': return const AdultMoviesScreen();
//       default: return const SizedBox.shrink();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     // 1. Agar API chal rahi hai toh Spinner dikhao
//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
//       );
//     }

//     // ✅ 2. BULLETPROOF SOLUTION: Agar expire hai toh seedha Expiry Screen render kardo
//     // Koi Navigation nahi! Direct Widget Return!
//     if (_isPlanExpired) {
//       return PlanExpiredScreen(apiMessage: _apiMessage);
//     }

//     // 3. Normal Dashboard (Agar active hai)
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (!didPop) {
//           if (_showExpiryOverlay) {
//             _dismissWarningOverlay();
//             return;
//           }

//           final fp = context.read<FocusProvider>();
//           if (fp.lastFocusedIdentifier != 'activeSidebar') {
//             fp.requestFocus('activeSidebar');
//             return; 
//           }

//           Navigator.of(context).push(
//             PageRouteBuilder(
//               opaque: false,
//               pageBuilder: (context, _, __) => const ExitConfirmationScreen(
//                 isFromBackButton: true,
//               ),
//             ),
//           );
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black, 
//         body: Stack(
//           children: [
//             Positioned.fill(
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: screenHeight * 0.65, 
//                     width: screenWidth, 
//                     child: BannerSlider(
//                       focusNode: _bannerFocusNode,
//                     ),
//                   ),

//                   Expanded(
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child: Container(
//                         key: ValueKey<String>(_pageIdentifiers[_selectedIndex]),
//                         width: screenWidth, 
//                         child: _getDynamicBottomContent(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Positioned(
//               left: 0,
//               top: 0, 
//               bottom: 0,
//               child: ClipRRect(
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
//                   child: Container(
//                     width: screenWidth * 0.14,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.40), 
//                       border: Border(
//                         right: BorderSide(
//                           color: Colors.white.withOpacity(0.2), 
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: ListView.builder(
//                       controller: _sidebarScrollController, 
//                       clipBehavior: Clip.none, 
//                       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.40),
//                       itemCount: _menuItems.length,
//                       itemBuilder: (context, index) {
//                         return AnimatedSidebarItem(
//                           title: _menuItems[index],
//                           focusNode: _menuFocusNodes[index],
//                           isSelected: _selectedIndex == index,
//                           is18PlusItem: _menuItems[index] == '18+',
//                           onTap: () {
//                             if (_showExpiryOverlay) return; // Block clicks
//                             if (_menuItems[index] == '18+') {
//                               _showPinDialog();
//                               return;
//                             }
//                             setState(() {
//                               _selectedIndex = index;
//                               _focusedIndex = index;
//                               context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                             });
//                             Future.delayed(const Duration(milliseconds: 100), () {
//                               if (mounted) context.read<FocusProvider>().requestFocus(_pageIdentifiers[index]);
//                             });
//                           },
//                           onFocusChange: (hasFocus) {
//                             if (hasFocus && !_showExpiryOverlay) {
//                               setState(() {
//                                 _focusedIndex = index; 
//                                 context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                               });
//                             } else {
//                               setState(() {}); 
//                             }
//                           },
//                           onKey: (node, event) {
//                             if (_showExpiryOverlay) return KeyEventResult.ignored; // Block keys

//                             if (event is RawKeyDownEvent) {
//                               if (event.logicalKey == LogicalKeyboardKey.arrowUp || 
//                                   event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                
//                                 final now = DateTime.now();
//                                 if (now.difference(_lastSidebarKeyTime).inMilliseconds < 350) {
//                                    return KeyEventResult.handled; 
//                                 }
//                                 _lastSidebarKeyTime = now; 

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                                   if (index < _menuItems.length - 1) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index + 1]);
//                                   }
//                                   return KeyEventResult.handled;
//                                 }

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                                   if (index > 0) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index - 1]);
//                                   } else {
//                                     context.read<FocusProvider>().requestFocus('topNavigation');
//                                   }
//                                   return KeyEventResult.handled;
//                                 }
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.enter ||
//                                   event.logicalKey == LogicalKeyboardKey.select) {
                                 
//                                  if (_menuItems[index] == '18+') {
//                                    _showPinDialog();
//                                    return KeyEventResult.handled;
//                                  }

//                                  final fp = context.read<FocusProvider>();
//                                  final targetId = _pageIdentifiers[index];

//                                  fp.updateLastFocusedIdentifier(targetId);

//                                  setState(() {
//                                    _selectedIndex = index; 
//                                    _focusedIndex = index;  
//                                  });

//                                  return KeyEventResult.handled;
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                                 if (_menuItems[index] == '18+') {
//                                   if (_selectedIndex != index) {
//                                     _showPinDialog();
//                                     return KeyEventResult.handled;
//                                   }
//                                   context.read<FocusProvider>().requestFocus('eighteenPlus'); 
//                                   return KeyEventResult.handled;
//                                 }

//                                  setState(() {
//                                    _selectedIndex = index;
//                                    _focusedIndex = index;
//                                  });

//                                  context.read<FocusProvider>().requestFocus(_pageIdentifiers[_selectedIndex]);
//                                  return KeyEventResult.handled;
//                               }
//                             }
//                             return KeyEventResult.ignored;
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: SizedBox(
//                 height: screenHeight * 0.24, 
//                 child: TopNavigationBar(
//                   selectedPage: _topNavSelectedIndex,
//                   tvenableAll: true,
//                   onPageSelected: (index) {
//                     if (!_showExpiryOverlay) setState(() => _topNavSelectedIndex = index);
//                   }
//                 ),
//               ),
//             ),

//             // ✅ CUSTOM BLURRED OVERLAY
//             if (_showExpiryOverlay)
//               Positioned.fill(
//                 child: ClipRRect(
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), 
//                     child: Container(
//                       color: Colors.black.withOpacity(0.5), 
//                       child: Center(
//                         child: Container(
//                           width: screenWidth * 0.45,
//                           padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[850],
//                             borderRadius: BorderRadius.circular(15.0),
//                             border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1),
//                             boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 55),
//                               const SizedBox(height: 15),
//                               const Text('Plan Expiry Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
//                               const SizedBox(height: 15),
//                               Text(_apiMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16)),
//                               const SizedBox(height: 15),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                 decoration: BoxDecoration(
//                                   color: Colors.redAccent.withOpacity(0.15),
//                                   borderRadius: BorderRadius.circular(6),
//                                   border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
//                                 ),
//                                 child: Text(
//                                   'Expires in: $_daysLeft Days',
//                                   style: const TextStyle(
//                                     color: Colors.redAccent, 
//                                     fontWeight: FontWeight.w900, 
//                                     fontSize: 18,
//                                     letterSpacing: 1.0,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 30),
//                               Focus(
//                                 focusNode: _warningOkFocusNode,
//                                 autofocus: true,
//                                 onKey: (node, event) {
//                                   if (event is RawKeyDownEvent) {
//                                     if (event.logicalKey == LogicalKeyboardKey.enter || 
//                                         event.logicalKey == LogicalKeyboardKey.select ||
//                                         event.logicalKey == LogicalKeyboardKey.numpadEnter) {
//                                       _dismissWarningOverlay();
//                                       return KeyEventResult.handled;
//                                     }
//                                   }
//                                   return KeyEventResult.ignored;
//                                 },
//                                 child: Builder(
//                                   builder: (btnContext) {
//                                     final isFocused = Focus.of(btnContext).hasFocus;
//                                     return ElevatedButton(
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: isFocused ? Colors.white : Colors.amber,
//                                         padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         elevation: isFocused ? 8 : 2,
//                                       ),
//                                       onPressed: _dismissWarningOverlay,
//                                       child: Text(
//                                         'O.K', 
//                                         style: TextStyle(
//                                           color: isFocused ? Colors.black : Colors.black87, 
//                                           fontWeight: FontWeight.w900,
//                                           fontSize: isFocused ? 18 : 16
//                                         )
//                                       ),
//                                     );
//                                   }
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }




// // ✅ 1. ADD THIS CUSTOM NOTIFICATION CLASS AT THE TOP
// class PlanUpdateNotification extends Notification {
//   final int daysLeft;
//   final bool isExpired;
//   final String message;

//   PlanUpdateNotification({
//     required this.daysLeft,
//     required this.isExpired,
//     required this.message,
//   });
// }


// class MainDashboardScreen extends StatefulWidget {
//   const MainDashboardScreen({Key? key}) : super(key: key);

//   @override
//   _MainDashboardScreenState createState() => _MainDashboardScreenState();
// }

// class _MainDashboardScreenState extends State<MainDashboardScreen> with AutomaticKeepAliveClientMixin , WidgetsBindingObserver {
  
//   @override
//   bool get wantKeepAlive => true;

//   bool _isLoading = true;
//   bool _isPlanExpired = false;

//   // ✅ VARIABLES FOR EXPIRY BANNER
//   bool _isPlanExpiring = false;
//   int _daysLeft = 0;

//   bool _showContentNetwork = false;
//   bool _showMovies = false;
//   bool _showSdMovies = false;
//   bool _showWebseries = false;
//   bool _showTvShows = false;
//   bool _showTvShowsPak = false;
//   bool _showSports = false;
//   bool _showReligious = false;
//   bool _showKids = false;
//   bool _show18Plus = false;

//   List<String> _menuItems = [];
//   List<String> _pageIdentifiers = [];
//   late List<FocusNode> _menuFocusNodes = [];
//   DateTime _lastSidebarKeyTime = DateTime.now();

//   int _selectedIndex = 0; 
//   int _focusedIndex = 0;  
//   int _topNavSelectedIndex = 0; 
//   final FocusNode _bannerFocusNode = FocusNode();
  
//   late ScrollController _sidebarScrollController;

//   String _serverPin = "";
//   String _apiMessage = "";

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _sidebarScrollController = ScrollController();
//   //   _initializeDashboard();
//   // }


//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this); // ✅ ADD THIS LINE
//     _sidebarScrollController = ScrollController();
//     _initializeDashboard();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this); // ✅ ADD THIS LINE
//     _sidebarScrollController.dispose();
//     for (var node in _menuFocusNodes) node.dispose();
//     _bannerFocusNode.dispose();
//     super.dispose();
//   }


//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
    
//     // ✅ TRIGGER WHEN APP COMES BACK FROM BACKGROUND / HOME BUTTON
//     if (state == AppLifecycleState.resumed) {
//       print("App Resumed: Re-checking Plan Status...");
      
//       // Call your API check silently
//       _checkPlanStatus().then((_) {
//         // If the plan expired while they were in the background, 
//         // update the UI immediately to show the Expiry Screen
//         if (_isPlanExpired && mounted) {
//           setState(() {}); 
//         }
//       });
//     }
//   }

//   Future<void> _initializeDashboard() async {
//     await _checkPlanStatus();

//     if (!mounted) return;

//     if (_isPlanExpired) {
//       setState(() {
//         _isLoading = false; 
//       });
//       return; 
//     }

//     await _check18PlusStatus();
//     _buildDynamicMenu();

//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _setupDashboardController();
        
//         if (_menuFocusNodes.isNotEmpty) {
//           setState(() {
//             _focusedIndex = 0;
//             _selectedIndex = 0;
//           });
//         }

//         if (_menuFocusNodes.isNotEmpty) {
//           FocusScope.of(context).requestFocus(_menuFocusNodes[0]);
//           context.read<FocusProvider>().updateLastFocusedIdentifier('activeSidebar');
//         }
//       });
//     }
//   }

//   void _loadCachedMenuSettings() {
//     try {
//       String? cachedData = SessionManager.getSavedDomainContent();
//       if (cachedData != null && cachedData.isNotEmpty) {
//         Map<String, dynamic> domainContent = json.decode(cachedData);
//         setState(() {
//           _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//           _showMovies = (domainContent['movies'] ?? 0) == 1;
//           _showSdMovies = (domainContent['sd_movies'] ?? 0) == 1;
//           _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//           _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//           _showKids = (domainContent['kids_show'] ?? 0) == 1;
//         });
//         _buildDynamicMenu();
//       }
//     } catch (e) {
//       print("Error loading cached settings: $e");
//     }
//   }

//   Future<void> _checkPlanStatus() async {
//     final String? authKey = SessionManager.authKey;

//     if (authKey == null || authKey.isEmpty) {
//       _loadCachedMenuSettings(); 
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

//         final String expireValue = res['plan_expired'].toString().toLowerCase();
//         bool planExpired = (expireValue == 'true' || expireValue == '1');

//         final int daysLeft = res['days'] ?? 99;
//         _daysLeft = daysLeft;
//         bool planWillExpire = (daysLeft <= 3);

//         _apiMessage = res['message'] ?? 'Status Unknown';
//         final domainContent = res['domain_content'];

//         if (planExpired) {
//           _isPlanExpired = true; 
//           return; 
//         }

//         if (domainContent != null && domainContent is Map) {
//           SessionManager.saveDomainContent(json.encode(domainContent));

//           setState(() {
//             _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//             _showMovies = (domainContent['movies'] ?? 0) == 1;
//             _showSdMovies = (domainContent['sd_movies'] ?? 0) == 1;
//             _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//             _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//             _showKids = (domainContent['kids_show'] ?? 0) == 1;
//           });
//           _buildDynamicMenu();
//         }

//         if (planWillExpire) {
//           setState(() {
//             _isPlanExpiring = true;
//           });
//         }
//       } else {
//         _loadCachedMenuSettings();
//       }
//     } catch (e) {
//       print("Error fetching Plan Status: $e");
//       _loadCachedMenuSettings();
//     }
//   }

//   Future<void> _check18PlusStatus() async {
//     try {
//       final url = Uri.parse(SessionManager.baseUrl + 'showabove18');
//       final headers = {
//         "auth-key": SessionManager.authKey,
//         "domain": SessionManager.savedDomain,
//       };
//       final response = await https.get(url, headers: headers);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == true && mounted) {
//           setState(() {
//             _show18Plus = true;
//             _serverPin = data['above18_pin'].toString();
//           });
//         }
//       }
//     } catch (e) {
//       print("Error fetching 18+ status: $e");
//     }
//   }

//   void _buildDynamicMenu() {
//     setState(() { 
//       _menuItems.clear();
//       _pageIdentifiers.clear();

//       _menuItems.add('LIVE TV');
//       _pageIdentifiers.add('liveChannelLanguage');
//       _menuItems.add('LIVE SPORTS');
//       _pageIdentifiers.add('liveSports');
//       _menuItems.add('LIVE KIDS');
//       _pageIdentifiers.add('liveKids');

//       if (_showContentNetwork) { _menuItems.add('OTT APPS'); _pageIdentifiers.add('subVod'); }
//       if (_showMovies) { _menuItems.add('LATEST 4K MOVIES'); _pageIdentifiers.add('manageMovies'); }
//       if (_showSdMovies) { _menuItems.add('LATEST SD MOVIES'); _pageIdentifiers.add('manageSdMovies'); }
//       if (_showWebseries) { _menuItems.add('WEB SERIES'); _pageIdentifiers.add('manageWebseries'); }
//       if (_showTvShows) { _menuItems.add('TV SHOWS'); _pageIdentifiers.add('tvShows'); }
//       if (_showKids) { _menuItems.add('KIDS ZONE'); _pageIdentifiers.add('kids_show'); }
      
//       if (_show18Plus) { 
//         _menuItems.add('18+'); 
//         _pageIdentifiers.add('eighteenPlus'); 
//       }

//       _menuFocusNodes = List.generate(_menuItems.length, (index) => FocusNode());
//     });
//   }

//   void _setupDashboardController() {
//     final fp = context.read<FocusProvider>();
    
//     if (_menuFocusNodes.isNotEmpty) {
//       fp.registerFocusNode('activeSidebar', _menuFocusNodes[_selectedIndex]);
//     }

//     fp.onDashboardNextPage = () {
//       int maxContentIndex = _menuItems.contains('18+') ? _menuItems.length - 2 : _menuItems.length - 1;
//       if (_selectedIndex < maxContentIndex) {
//         _changePageAndFocus(_selectedIndex + 1);
//       }
//     };

//     fp.onDashboardPrevPage = () {
//       if (_selectedIndex > 0) {
//         _changePageAndFocus(_selectedIndex - 1);
//       } else {
//         fp.requestFocus('watchNow'); 
//       }
//     };

//     fp.onBannerDown = () {
//       if (_pageIdentifiers.isNotEmpty) {
//         fp.requestFocus(_pageIdentifiers[_selectedIndex]);
//       }
//     };
//   }

//   void _changePageAndFocus(int newIndex) {
//     if (newIndex < 0 || newIndex >= _menuItems.length) return;

//     final targetId = _pageIdentifiers[newIndex];
    
//     setState(() {
//       _selectedIndex = newIndex;
//       _focusedIndex = newIndex; 
//     });

//     final fp = context.read<FocusProvider>();
//     fp.registerFocusNode('activeSidebar', _menuFocusNodes[newIndex]);
//     fp.updateLastFocusedIdentifier(targetId); 

//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         fp.requestFocus(targetId);
//       }
//     });
//   }

//   // @override
//   // void dispose() {
//   //   _sidebarScrollController.dispose();
//   //   for (var node in _menuFocusNodes) node.dispose();
//   //   _bannerFocusNode.dispose();
//   //   super.dispose();
//   // }

//   void _showPinDialog() {
//     final TextEditingController _pinController = TextEditingController();
//     final FocusNode _inputFocus = FocusNode();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF2A2D3A),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: const Text("Enter 18+ PIN", style: TextStyle(color: Colors.white)),
//           content: TextField(
//             controller: _pinController,
//             focusNode: _inputFocus,
//             autofocus: true,
//             obscureText: true,
//             keyboardType: TextInputType.number,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               hintText: "Enter PIN",
//               hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
//               enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
//               focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
//             ),
//             onSubmitted: (_) => _validatePin(_pinController.text),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
//             ),
//             TextButton(
//               onPressed: () => _validatePin(_pinController.text),
//               child: const Text("Enter", style: TextStyle(color: Colors.blueAccent)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _validatePin(String inputPin) {
//     if (inputPin == _serverPin) {
//       Navigator.pop(context); 
      
//       setState(() {
//         int adultIndex = _pageIdentifiers.indexOf('eighteenPlus');
//         if (adultIndex != -1) {
//           _selectedIndex = adultIndex;
//           _focusedIndex = adultIndex;
          
//           context.read<FocusProvider>().updateLastFocusedIdentifier('eighteenPlus');
//         }
//       });
      
//       Future.delayed(const Duration(milliseconds: 200), () {
//         if (mounted) context.read<FocusProvider>().requestFocus('eighteenPlus');
//       });

//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Invalid PIN"), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
//       );
//     }
//   }

//   Widget _getDynamicBottomContent() {
//     if (_pageIdentifiers.isEmpty || _selectedIndex >= _pageIdentifiers.length) return const SizedBox.shrink();
    
//     String currentId = _pageIdentifiers[_selectedIndex];
    
//     switch (currentId) {
//       case 'liveChannelLanguage': return const LiveChannelLanguageScreen();
//       case 'liveSports': return const LiveSportsScreen();
//       case 'liveKids': return const LiveKidsScreen();
//       case 'subVod': return const HorzontalVod();
//       case 'manageMovies': return const MoviesScreen();
//       case 'manageSdMovies': return const SdMoviesScreen();
//       case 'manageWebseries': return const ManageWebSeries();
//       case 'tvShows': return const ManageTvShows();
//       case 'sports': return const ManageSports();
//       case 'kids_show': return const ManageKidsShows();
//       case 'eighteenPlus': return const AdultMoviesScreen();
//       default: return const SizedBox.shrink();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
//       );
//     }

//     if (_isPlanExpired) {
//       return PlanExpiredScreen(apiMessage: _apiMessage);
//     }

//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (!didPop) {
//           final fp = context.read<FocusProvider>();
//           if (fp.lastFocusedIdentifier != 'activeSidebar') {
//             fp.requestFocus('activeSidebar');
//             return; 
//           }

//           Navigator.of(context).push(
//             PageRouteBuilder(
//               opaque: false,
//               pageBuilder: (context, _, __) => const ExitConfirmationScreen(
//                 isFromBackButton: true,
//               ),
//             ),
//           );
//         }
//       },

//       // ✅ 2. WRAP THE SCAFFOLD WITH NotificationListener
//       child: NotificationListener<PlanUpdateNotification>(
//         onNotification: (notification) {
//           if (notification.isExpired) {
//             setState(() {
//               _isPlanExpired = true;
//               _apiMessage = notification.message;
//             });
//           } else {
//             setState(() {
//               _isPlanExpiring = notification.daysLeft <= 3;
//               _daysLeft = notification.daysLeft;
//             });
//           }
//           return true; // Return true to cancel bubbling
//         },
//       child: Scaffold(
//         backgroundColor: Colors.black, 
//         body: Stack(
//           children: [
//             Positioned.fill(
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: screenHeight * 0.65, 
//                     width: screenWidth, 
//                     child: BannerSlider(
//                       focusNode: _bannerFocusNode,
//                       isPlanExpiring: _isPlanExpiring, // ✅ PASSING VARIABLE
//                       daysLeft: _daysLeft,             // ✅ PASSING VARIABLE
//                     ),
//                   ),

//                   Expanded(
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child: Container(
//                         key: ValueKey<String>(_pageIdentifiers[_selectedIndex]),
//                         width: screenWidth, 
//                         child: _getDynamicBottomContent(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Positioned(
//               left: 0,
//               top: 0, 
//               bottom: 0,
//               child: ClipRRect(
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
//                   child: Container(
//                     width: screenWidth * 0.14,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.40), 
//                       border: Border(
//                         right: BorderSide(
//                           color: Colors.white.withOpacity(0.2), 
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: ListView.builder(
//                       controller: _sidebarScrollController, 
//                       clipBehavior: Clip.none, 
//                       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.40),
//                       itemCount: _menuItems.length,
//                       itemBuilder: (context, index) {
//                         return AnimatedSidebarItem(
//                           title: _menuItems[index],
//                           focusNode: _menuFocusNodes[index],
//                           isSelected: _selectedIndex == index,
//                           is18PlusItem: _menuItems[index] == '18+',
//                           onTap: () {
//                             if (_menuItems[index] == '18+') {
//                               _showPinDialog();
//                               return;
//                             }
//                             setState(() {
//                               _selectedIndex = index;
//                               _focusedIndex = index;
//                               context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                             });
//                             Future.delayed(const Duration(milliseconds: 100), () {
//                               if (mounted) context.read<FocusProvider>().requestFocus(_pageIdentifiers[index]);
//                             });
//                           },
//                           onFocusChange: (hasFocus) {
//                             if (hasFocus) {
//                               setState(() {
//                                 _focusedIndex = index; 
//                                 context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                               });
//                             } else {
//                               setState(() {}); 
//                             }
//                           },
//                           onKey: (node, event) {
//                             if (event is RawKeyDownEvent) {
//                               if (event.logicalKey == LogicalKeyboardKey.arrowUp || 
//                                   event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                
//                                 final now = DateTime.now();
//                                 if (now.difference(_lastSidebarKeyTime).inMilliseconds < 350) {
//                                    return KeyEventResult.handled; 
//                                 }
//                                 _lastSidebarKeyTime = now; 

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                                   if (index < _menuItems.length - 1) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index + 1]);
//                                   }
//                                   return KeyEventResult.handled;
//                                 }

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                                   if (index > 0) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index - 1]);
//                                   } else {
//                                     context.read<FocusProvider>().requestFocus('topNavigation');
//                                   }
//                                   return KeyEventResult.handled;
//                                 }
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.enter ||
//                                   event.logicalKey == LogicalKeyboardKey.select) {
//                                  _checkPlanStatus();
//                                  if (_menuItems[index] == '18+') {
//                                    _showPinDialog();
//                                    return KeyEventResult.handled;
//                                  }

//                                  final fp = context.read<FocusProvider>();
//                                  final targetId = _pageIdentifiers[index];

//                                  fp.updateLastFocusedIdentifier(targetId);

//                                  setState(() {
//                                    _selectedIndex = index; 
//                                    _focusedIndex = index;  
//                                  });

//                                  return KeyEventResult.handled;
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                                 if (_menuItems[index] == '18+') {
//                                   if (_selectedIndex != index) {
//                                     _showPinDialog();
//                                     return KeyEventResult.handled;
//                                   }
//                                   context.read<FocusProvider>().requestFocus('eighteenPlus'); 
//                                   return KeyEventResult.handled;
//                                 }

//                                  setState(() {
//                                    _selectedIndex = index;
//                                    _focusedIndex = index;
//                                  });

//                                  context.read<FocusProvider>().requestFocus(_pageIdentifiers[_selectedIndex]);
//                                  return KeyEventResult.handled;
//                               }
//                             }
//                             return KeyEventResult.ignored;
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: SizedBox(
//                 height: screenHeight * 0.24, 
//                 child: TopNavigationBar(
//                   selectedPage: _topNavSelectedIndex,
//                   tvenableAll: true,
//                   onPageSelected: (index) {
//                     setState(() => _topNavSelectedIndex = index);
//                   }
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ));
//   }
// }

// // ✅ EXACT ORIGINAL ANIMATED SIDEBAR WIDGET FROM TURN 1
// class AnimatedSidebarItem extends StatefulWidget {
//   final String title;
//   final FocusNode focusNode;
//   final bool isSelected;
//   final bool is18PlusItem;
//   final VoidCallback onTap;
//   final ValueChanged<bool> onFocusChange; 
//   final FocusOnKeyCallback onKey;         

//   const AnimatedSidebarItem({
//     Key? key,
//     required this.title,
//     required this.focusNode,
//     required this.isSelected,
//     required this.is18PlusItem,
//     required this.onTap,
//     required this.onFocusChange,
//     required this.onKey,
//   }) : super(key: key);

//   @override
//   _AnimatedSidebarItemState createState() => _AnimatedSidebarItemState();
// }

// class _AnimatedSidebarItemState extends State<AnimatedSidebarItem> with SingleTickerProviderStateMixin {
//   late AnimationController _borderAnimationController;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _borderAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 2500),
//       vsync: this,
//     );
//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (mounted) {
//       setState(() {
//         _isFocused = widget.focusNode.hasFocus;
//       });
//       if (_isFocused) {
//         _borderAnimationController.repeat();
        
//         Future.delayed(const Duration(milliseconds: 50), () {
//           if (mounted) {
//             Scrollable.ensureVisible(
//               context,
//               alignment: 0.5, 
//               duration: const Duration(milliseconds: 350), 
//               curve: Curves.easeOutCubic, 
//             );
//           }
//         });

//       } else {
//         _borderAnimationController.stop();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _borderAnimationController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       focusNode: widget.focusNode,
//       onFocusChange: widget.onFocusChange,
//       onKey: widget.onKey,
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: Container(
//           height: 48, 
//           margin: const EdgeInsets.only(left: 25, right: 10, top: 3, bottom: 3), 
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: _isFocused
//                 ? [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))]
//                 : [],
//           ),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               if (_isFocused)
//                 AnimatedBuilder(
//                   animation: _borderAnimationController,
//                   builder: (context, child) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         gradient: SweepGradient(
//                           colors: [
//                             Colors.white.withOpacity(0.1),
//                             Colors.white,
//                             Colors.white,
//                             Colors.white.withOpacity(0.1),
//                           ],
//                           stops: const [0.0, 0.25, 0.5, 1.0],
//                           transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
//                         ),
//                       ),
//                     );
//                   },
//                 ),

//               Padding(
//                 padding: EdgeInsets.all(_isFocused ? 5.0 : 0.0), 
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: _isFocused 
//                         ? Colors.black 
//                         : (widget.isSelected ? Colors.black.withOpacity(0.15) : Colors.transparent),
//                     borderRadius: BorderRadius.circular(_isFocused ? 4 : 8),
//                   ),
//                   child: Center(
//                     child: Text(
//                       widget.title,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: _isFocused 
//                             ? Colors.white 
//                             : (widget.isSelected ? Colors.black87 : Colors.black87),
//                         fontSize: _isFocused ? 13 : 11,
//                         fontWeight: _isFocused || widget.isSelected ? FontWeight.w900 : FontWeight.w700,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





// // // ✅ EXACT ORIGINAL PLAN EXPIRED SCREEN AND TV ACTION BUTTON FROM TURN 1
// // class PlanExpiredScreen extends StatelessWidget {
// //   final String apiMessage;

// //   const PlanExpiredScreen({Key? key, required this.apiMessage}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return PopScope(
// //       canPop: false,
// //       child: Scaffold(
// //         body: Container(
// //           decoration: const BoxDecoration(
// //             gradient: LinearGradient(
// //               colors: [Color(0xFF232526), Color(0xFF414345)],
// //               begin: Alignment.topLeft,
// //               end: Alignment.bottomRight,
// //             ),
// //           ),
// //           child: SafeArea(
// //             child: Padding(
// //               padding: const EdgeInsets.all(30.0),
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 crossAxisAlignment: CrossAxisAlignment.stretch,
// //                 children: [
// //                   const Icon(
// //                     Icons.lock_clock_outlined,
// //                     size: 100,
// //                     color: Color(0xFFE74C3C),
// //                   ),
// //                   const SizedBox(height: 30),
// //                   const Text(
// //                     'Subscription Expired',
// //                     textAlign: TextAlign.center,
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 32,
// //                       fontWeight: FontWeight.bold,
// //                       letterSpacing: 1.2,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 15),
// //                   Text(
// //                     apiMessage,
// //                     textAlign: TextAlign.center,
// //                     style: const TextStyle(
// //                       color: Colors.white70,
// //                       fontSize: 18,
// //                       height: 1.5,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 50),

// //                   TvActionButton(
// //                     label: 'UPDATE PIN',
// //                     icon: Icons.refresh_rounded,
// //                     baseColor: Colors.blueAccent,
// //                     autoFocus: true, 
// //                     onPressed: () async {
// //                       await SessionManager.clearSession(keepDomain: true);

// //                       if (context.mounted) {
// //                         Navigator.pushAndRemoveUntil(
// //                           context,
// //                           MaterialPageRoute(builder: (context) => LoginScreen()),
// //                           (route) => false,
// //                         );
// //                       }
// //                     },
// //                   ),

// //                   const SizedBox(height: 25), 

// //                   TvActionButton(
// //                     label: 'EXIT THE APP',
// //                     icon: Icons.exit_to_app_rounded,
// //                     baseColor: const Color(0xFFE74C3C),
// //                     autoFocus: false,
// //                     onPressed: () async {
// //                       await SessionManager.clearSession(keepDomain: false);
// //                       SystemNavigator.pop();
// //                     },
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }




// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:http/http.dart' as https;
// // import 'package:mobi_tv_entertainment/main.dart'; // Ensure SessionManager & MyHome are imported

// class PlanExpiredScreen extends StatefulWidget {
//   final String apiMessage;

//   const PlanExpiredScreen({Key? key, required this.apiMessage}) : super(key: key);

//   @override
//   _PlanExpiredScreenState createState() => _PlanExpiredScreenState();
// }

// class _PlanExpiredScreenState extends State<PlanExpiredScreen> {
//   bool _isLoading = false;
  
//   // Focus nodes for TV remote navigation
//   final FocusNode _refreshFocus = FocusNode();
//   final FocusNode _exitFocus = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     // Request focus on the "Refresh Status" button by default when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(_refreshFocus);
//     });
//   }

//   @override
//   void dispose() {
//     _refreshFocus.dispose();
//     _exitFocus.dispose();
//     super.dispose();
//   }

//   // ✅ 1. FUNCTION TO CHECK PLAN STATUS
//   Future<void> _checkSubscriptionStatus() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);

//     final String? authKey = SessionManager.authKey;
//     if (authKey == null || authKey.isEmpty) {
//       setState(() => _isLoading = false);
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
//       ).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final res = json.decode(response.body);
//         final String expireValue = res['plan_expired'].toString().toLowerCase();
//         bool planExpired = (expireValue == 'true' || expireValue == '1');

//         if (!planExpired) {
//           // ✅ Plan is recharged! Navigate to Dashboard seamlessly without clearing session
//           if (mounted) {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => MyHome()),
//               (route) => false,
//             );
//           }
//         } else {
//           // ❌ Still expired. Show an attractive TV-friendly message.
//           _showRechargeAlert("Your plan is still expired. Please recharge to continue enjoying our services!");
//         }
//       } else {
//         _showRechargeAlert("Server error. Please try again later.");
//       }
//     } catch (e) {
//       _showRechargeAlert("Network error. Please check your internet connection.");
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   // ✅ 2. BEAUTIFUL SNACKBAR ALERT
//   void _showRechargeAlert(String message) {
//     if (!mounted) return;
    
//     // Using a Floating SnackBar which looks great on TV screens
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
//             const SizedBox(width: 15),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.redAccent.shade700,
//         duration: const Duration(seconds: 4),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: EdgeInsets.only(
//           bottom: MediaQuery.of(context).size.height * 0.1, 
//           left: MediaQuery.of(context).size.width * 0.2, 
//           right: MediaQuery.of(context).size.width * 0.2
//         ),
//         elevation: 10,
//       ),
//     );
//   }

//   void _exitApp() {
//     if (Platform.isAndroid) {
//       SystemNavigator.pop();
//     } else {
//       exit(0);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sw = MediaQuery.of(context).size.width;
//     final sh = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: const Color(0xFF1E1E1E), // Dark professional background
//       body: Center(
//         child: Container(
//           width: sw * 0.6,
//           padding: const EdgeInsets.all(40),
//           decoration: BoxDecoration(
//             color: const Color(0xFF2C2C2C),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.5),
//                 blurRadius: 20,
//                 spreadRadius: 5,
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Warning Icon
//               const Icon(Icons.error_outline_rounded, size: 80, color: Colors.redAccent),
//               const SizedBox(height: 20),
              
//               // Expiry Message Title
//               const Text(
//                 "Subscription Expired",
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 15),
              
//               // Dynamic API Message
//               Text(
//                 widget.apiMessage.isNotEmpty 
//                     ? widget.apiMessage 
//                     : "Your plan has expired. Please recharge your account to resume watching.",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   color: Colors.white70,
//                 ),
//               ),
//               const SizedBox(height: 40),

//               // Loading Spinner or Buttons
//               if (_isLoading)
//                 const CircularProgressIndicator(color: Colors.blueAccent)
//               else
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // ✅ EXIT BUTTON (Kept exactly as requested)
//                     _buildTVButton(
//                       label: "EXIT",
//                       icon: Icons.exit_to_app_rounded,
//                       focusNode: _exitFocus,
//                       onTap: _exitApp,
//                       defaultColor: Colors.grey.shade800,
//                       focusedColor: Colors.redAccent,
//                     ),
                    
//                     const SizedBox(width: 30),
                    
//                     // ✅ REFRESH STATUS BUTTON (Formerly Update Pin)
//                     _buildTVButton(
//                       label: "REFRESH STATUS",
//                       icon: Icons.refresh_rounded,
//                       focusNode: _refreshFocus,
//                       onTap: _checkSubscriptionStatus,
//                       defaultColor: Colors.grey.shade800,
//                       focusedColor: Colors.blueAccent,
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ✅ HELPER METHOD FOR TV-FRIENDLY BUTTONS
//   Widget _buildTVButton({
//     required String label,
//     required IconData icon,
//     required FocusNode focusNode,
//     required VoidCallback onTap,
//     required Color defaultColor,
//     required Color focusedColor,
//   }) {
//     return StatefulBuilder(
//       builder: (context, setState) {
//         return Focus(
//           focusNode: focusNode,
//           onFocusChange: (hasFocus) => setState(() {}),
//           onKey: (node, event) {
//             if (event is RawKeyDownEvent && 
//                (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
//               onTap();
//               return KeyEventResult.handled;
//             }
//             return KeyEventResult.ignored;
//           },
//           child: GestureDetector(
//             onTap: onTap,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//               decoration: BoxDecoration(
//                 color: focusNode.hasFocus ? focusedColor : defaultColor,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: focusNode.hasFocus ? Colors.white : Colors.transparent,
//                   width: 2,
//                 ),
//                 boxShadow: focusNode.hasFocus
//                     ? [BoxShadow(color: focusedColor.withOpacity(0.6), blurRadius: 15, spreadRadius: 2)]
//                     : [],
//               ),
//               child: Row(
//                 children: [
//                   Icon(icon, color: Colors.white, size: 24),
//                   const SizedBox(width: 10),
//                   Text(
//                     label,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }
//     );
//   }
// }

// class TvActionButton extends StatefulWidget {
//   final String label;
//   final IconData icon;
//   final Color baseColor;
//   final VoidCallback onPressed;
//   final bool autoFocus;

//   const TvActionButton({
//     Key? key,
//     required this.label,
//     required this.icon,
//     required this.baseColor,
//     required this.onPressed,
//     this.autoFocus = false,
//   }) : super(key: key);

//   @override
//   State<TvActionButton> createState() => _TvActionButtonState();
// }

// class _TvActionButtonState extends State<TvActionButton> {
//   bool _isFocused = false;

//   @override
//   Widget build(BuildContext context) {
//     return Transform.scale(
//       scale: _isFocused ? 1.05 : 1.0, 
//       child: Focus(
//         autofocus: widget.autoFocus,
//         onFocusChange: (hasFocus) {
//           setState(() {
//             _isFocused = hasFocus;
//           });
//         },
//         onKey: (node, event) {
//           if (event is RawKeyDownEvent) {
//             if (event.logicalKey == LogicalKeyboardKey.enter || 
//                 event.logicalKey == LogicalKeyboardKey.select ||
//                 event.logicalKey == LogicalKeyboardKey.numpadEnter) {
              
//               widget.onPressed();
//               return KeyEventResult.handled;
//             }
//           }
//           return KeyEventResult.ignored;
//         },
//         child: ElevatedButton.icon(
//           focusNode: null, 
//           icon: Icon(
//             widget.icon, 
//             color: Colors.white,
//             size: _isFocused ? 28 : 24,
//           ),
//           label: Text(
//             widget.label,
//             style: TextStyle(
//               fontSize: _isFocused ? 20 : 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: widget.baseColor,
//             padding: const EdgeInsets.symmetric(vertical: 15),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: _isFocused 
//                   ? const BorderSide(color: Colors.white, width: 3) 
//                   : BorderSide.none,
//             ),
//             elevation: _isFocused ? 12 : 6,
//             shadowColor: _isFocused ? Colors.white.withOpacity(0.4) : widget.baseColor,
//           ),
//           onPressed: widget.onPressed,
//         ),
//       ),
//     );
//   }
// }





// import 'dart:convert';
// import 'dart:io'; 
// import 'package:http/http.dart' as https; 
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/live_kids_screen/live_kids_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/live_sports_screen/live_sports_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sd_movies_screen/sd_movies_screen.dart';
// import 'dart:math' as math; 
// import 'package:qr_flutter/qr_flutter.dart'; // ✅ ADDED QR FLUTTER IMPORT

// // ✅ IMPORT EXIT & EXPIRED SCREENS
// import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// // Agar neeche error aaye toh is import ko comment kar dena kyunki class yahi neeche likhi hai
// // import 'package:mobi_tv_entertainment/plan_expired_screen.dart';

// // ✅ PAGES IMPORTS
// import 'package:mobi_tv_entertainment/components/home_screen_pages/above_18/above_eighteen.dart'; 
// import 'package:mobi_tv_entertainment/components/home_screen_pages/banner_slider_screen/banner_slider_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/kids_shows/kids_channels.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/movies_screen/movies.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_live_screen/live_channel_language_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/manage_tv_shows.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show_pak/tv_show_pak.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/manage_webseries.dart';
// import 'package:mobi_tv_entertainment/components/menu/top_navigation_bar.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/main.dart'; 
// import 'package:provider/provider.dart';
// import 'dart:ui'; 


// // ✅ 1. ADD THIS CUSTOM NOTIFICATION CLASS AT THE TOP
// class PlanUpdateNotification extends Notification {
//   final int daysLeft;
//   final bool isExpired;
//   final String message;

//   PlanUpdateNotification({
//     required this.daysLeft,
//     required this.isExpired,
//     required this.message,
//   });
// }


// class MainDashboardScreen extends StatefulWidget {
//   const MainDashboardScreen({Key? key}) : super(key: key);

//   @override
//   _MainDashboardScreenState createState() => _MainDashboardScreenState();
// }

// class _MainDashboardScreenState extends State<MainDashboardScreen> with AutomaticKeepAliveClientMixin , WidgetsBindingObserver {
  
//   @override
//   bool get wantKeepAlive => true;

//   bool _isLoading = true;
//   bool _isPlanExpired = false;

//   // ✅ VARIABLES FOR EXPIRY BANNER
//   bool _isPlanExpiring = false;
//   int _daysLeft = 0;

//   bool _showContentNetwork = false;
//   bool _showMovies = false;
//   bool _showSdMovies = false;
//   bool _showWebseries = false;
//   bool _showTvShows = false;
//   bool _showTvShowsPak = false;
//   bool _showSports = false;
//   bool _showReligious = false;
//   bool _showKids = false;
//   bool _show18Plus = false;

//   // ✅ VARIABLES FOR HELP POPUP
//   bool _showHelp = false;
//   String _whatsappUrl = "";
//   String _telegramUrl = "";

//   List<String> _menuItems = [];
//   List<String> _pageIdentifiers = [];
//   late List<FocusNode> _menuFocusNodes = [];
//   DateTime _lastSidebarKeyTime = DateTime.now();

//   int _selectedIndex = 0; 
//   int _focusedIndex = 0;  
//   int _topNavSelectedIndex = 0; 
//   final FocusNode _bannerFocusNode = FocusNode();
  
//   late ScrollController _sidebarScrollController;

//   String _serverPin = "";
//   String _apiMessage = "";

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this); // ✅ ADD THIS LINE
//     _sidebarScrollController = ScrollController();
//     _initializeDashboard();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this); // ✅ ADD THIS LINE
//     _sidebarScrollController.dispose();
//     for (var node in _menuFocusNodes) node.dispose();
//     _bannerFocusNode.dispose();
//     super.dispose();
//   }


//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
    
//     // ✅ TRIGGER WHEN APP COMES BACK FROM BACKGROUND / HOME BUTTON
//     if (state == AppLifecycleState.resumed) {
//       print("App Resumed: Re-checking Plan Status...");
      
//       // Call your API check silently
//       _checkPlanStatus().then((_) {
//         // If the plan expired while they were in the background, 
//         // update the UI immediately to show the Expiry Screen
//         if (_isPlanExpired && mounted) {
//           setState(() {}); 
//         }
//       });
//     }
//   }

//   Future<void> _initializeDashboard() async {
//     await _checkPlanStatus();

//     if (!mounted) return;

//     if (_isPlanExpired) {
//       setState(() {
//         _isLoading = false; 
//       });
//       return; 
//     }

//     await _check18PlusStatus();
//     await _fetchHelplines(); // ✅ ADDED HELPLINES API CALL
//     _buildDynamicMenu();

//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _setupDashboardController();
        
//         if (_menuFocusNodes.isNotEmpty) {
//           setState(() {
//             _focusedIndex = 0;
//             _selectedIndex = 0;
//           });
//         }

//         if (_menuFocusNodes.isNotEmpty) {
//           FocusScope.of(context).requestFocus(_menuFocusNodes[0]);
//           context.read<FocusProvider>().updateLastFocusedIdentifier('activeSidebar');
//         }
//       });
//     }
//   }

//   // ✅ FETCH HELPLINES API IMPLEMENTATION
//   Future<void> _fetchHelplines() async {
//     try {
//       final url = Uri.parse(SessionManager.baseUrl + 'get-helplines');
//       final response = await https.get(
//         url,
//         headers: {
//           "auth-key": SessionManager.authKey ?? "",
//           "domain": SessionManager.savedDomain ?? "",
//         },
//       );

//       if (response.statusCode == 200) {
//         final res = json.decode(response.body);
//         if (res['data'] != null) {
//           final data = res['data'];
//           if (data['status'] == 1 || data['status'] == true) {
//             if (mounted) {
//               setState(() {
//                 _showHelp = true;
//                 _whatsappUrl = data['whatsapp_url'] ?? "";
//                 _telegramUrl = data['telegram_url'] ?? "";
//               });
//             }
//           }
//         }
//       }
//     } catch (e) {
//       print("Error fetching helplines: $e");
//     }
//   }

//   void _loadCachedMenuSettings() {
//     try {
//       String? cachedData = SessionManager.getSavedDomainContent();
//       if (cachedData != null && cachedData.isNotEmpty) {
//         Map<String, dynamic> domainContent = json.decode(cachedData);
//         setState(() {
//           _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//           _showMovies = (domainContent['movies'] ?? 0) == 1;
//           _showSdMovies = (domainContent['sd_movies'] ?? 0) == 1;
//           _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//           _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//           _showKids = (domainContent['kids_show'] ?? 0) == 1;
//         });
//         _buildDynamicMenu();
//       }
//     } catch (e) {
//       print("Error loading cached settings: $e");
//     }
//   }

//   Future<void> _checkPlanStatus() async {
//     final String? authKey = SessionManager.authKey;

//     if (authKey == null || authKey.isEmpty) {
//       _loadCachedMenuSettings(); 
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

//         final String expireValue = res['plan_expired'].toString().toLowerCase();
//         bool planExpired = (expireValue == 'true' || expireValue == '1');

//         final int daysLeft = res['days'] ?? 99;
//         _daysLeft = daysLeft;
//         bool planWillExpire = (daysLeft <= 3);

//         _apiMessage = res['message'] ?? 'Status Unknown';
//         final domainContent = res['domain_content'];

//         if (planExpired) {
//           _isPlanExpired = true; 
//           return; 
//         }

//         if (domainContent != null && domainContent is Map) {
//           SessionManager.saveDomainContent(json.encode(domainContent));

//           setState(() {
//             _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//             _showMovies = (domainContent['movies'] ?? 0) == 1;
//             _showSdMovies = (domainContent['sd_movies'] ?? 0) == 1;
//             _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//             _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//             _showKids = (domainContent['kids_show'] ?? 0) == 1;
//           });
//           _buildDynamicMenu();
//         }

//         if (planWillExpire) {
//           setState(() {
//             _isPlanExpiring = true;
//           });
//         }
//       } else {
//         _loadCachedMenuSettings();
//       }
//     } catch (e) {
//       print("Error fetching Plan Status: $e");
//       _loadCachedMenuSettings();
//     }
//   }

//   Future<void> _check18PlusStatus() async {
//     try {
//       final url = Uri.parse(SessionManager.baseUrl + 'showabove18');
//       final headers = {
//         "auth-key": SessionManager.authKey,
//         "domain": SessionManager.savedDomain,
//       };
//       final response = await https.get(url, headers: headers);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == true && mounted) {
//           setState(() {
//             _show18Plus = true;
//             _serverPin = data['above18_pin'].toString();
//           });
//         }
//       }
//     } catch (e) {
//       print("Error fetching 18+ status: $e");
//     }
//   }

//   void _buildDynamicMenu() {
//     setState(() { 
//       // ✅ USE TEMP LISTS TO PREVENT UI GLITCHES
//       List<String> tempMenuItems = [];
//       List<String> tempPageIdentifiers = [];

//       tempMenuItems.add('LIVE TV');
//       tempPageIdentifiers.add('liveChannelLanguage');
//       tempMenuItems.add('LIVE SPORTS');
//       tempPageIdentifiers.add('liveSports');
//       tempMenuItems.add('LIVE KIDS');
//       tempPageIdentifiers.add('liveKids');

//       if (_showContentNetwork) { tempMenuItems.add('OTT APPS'); tempPageIdentifiers.add('subVod'); }
//       if (_showMovies) { tempMenuItems.add('LATEST 4K MOVIES'); tempPageIdentifiers.add('manageMovies'); }
//       if (_showSdMovies) { tempMenuItems.add('LATEST SD MOVIES'); tempPageIdentifiers.add('manageSdMovies'); }
//       if (_showWebseries) { tempMenuItems.add('WEB SERIES'); tempPageIdentifiers.add('manageWebseries'); }
//       if (_showTvShows) { tempMenuItems.add('TV SHOWS'); tempPageIdentifiers.add('tvShows'); }
//       if (_showKids) { tempMenuItems.add('KIDS ZONE'); tempPageIdentifiers.add('kids_show'); }
      
//       if (_show18Plus) { 
//         tempMenuItems.add('18+'); 
//         tempPageIdentifiers.add('eighteenPlus'); 
//       }

//       // ✅ ADD HELP BUTTON AT THE END
//       if (_showHelp) {
//         tempMenuItems.add('HELP');
//         tempPageIdentifiers.add('helpPopup');
//       }

//       _menuItems = tempMenuItems;
//       _pageIdentifiers = tempPageIdentifiers;

//       // ✅ FIX: DO NOT DESTROY FOCUS NODES IF MENU SIZE IS SAME
//       // Yeh prevent karega ki popup band hone par node completely gayab na ho jaye
//       if (_menuFocusNodes.length != _menuItems.length) {
//         for (var node in _menuFocusNodes) {
//           node.dispose();
//         }
//         _menuFocusNodes = List.generate(_menuItems.length, (index) => FocusNode());
//       }
//     });
//   }

//   void _setupDashboardController() {
//     final fp = context.read<FocusProvider>();
    
//     if (_menuFocusNodes.isNotEmpty) {
//       fp.registerFocusNode('activeSidebar', _menuFocusNodes[_selectedIndex]);
//     }

//     fp.onDashboardNextPage = () {
//       int maxContentIndex = _menuItems.length - 1;
//       if (_menuItems.contains('18+') && !_menuItems.contains('HELP')) {
//         maxContentIndex = _menuItems.length - 2;
//       } else if (_menuItems.contains('18+') && _menuItems.contains('HELP')) {
//         maxContentIndex = _menuItems.length - 3;
//       } else if (!_menuItems.contains('18+') && _menuItems.contains('HELP')) {
//         maxContentIndex = _menuItems.length - 2;
//       }

//       if (_selectedIndex < maxContentIndex) {
//         _changePageAndFocus(_selectedIndex + 1);
//       }
//     };

//     fp.onDashboardPrevPage = () {
//       if (_selectedIndex > 0) {
//         _changePageAndFocus(_selectedIndex - 1);
//       } else {
//         fp.requestFocus('watchNow'); 
//       }
//     };

//     fp.onBannerDown = () {
//       if (_pageIdentifiers.isNotEmpty) {
//         fp.requestFocus(_pageIdentifiers[_selectedIndex]);
//       }
//     };
//   }

//   void _changePageAndFocus(int newIndex) {
//     if (newIndex < 0 || newIndex >= _menuItems.length) return;

//     final targetId = _pageIdentifiers[newIndex];
    
//     setState(() {
//       _selectedIndex = newIndex;
//       _focusedIndex = newIndex; 
//     });

//     final fp = context.read<FocusProvider>();
//     fp.registerFocusNode('activeSidebar', _menuFocusNodes[newIndex]);
//     fp.updateLastFocusedIdentifier(targetId); 

//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         fp.requestFocus(targetId);
//       }
//     });
//   }

//   void _showPinDialog() {
//     final TextEditingController _pinController = TextEditingController();
//     final FocusNode _inputFocus = FocusNode();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF2A2D3A),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: const Text("Enter 18+ PIN", style: TextStyle(color: Colors.white)),
//           content: TextField(
//             controller: _pinController,
//             focusNode: _inputFocus,
//             autofocus: true,
//             obscureText: true,
//             keyboardType: TextInputType.number,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               hintText: "Enter PIN",
//               hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
//               enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
//               focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
//             ),
//             onSubmitted: (_) => _validatePin(_pinController.text),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
//             ),
//             TextButton(
//               onPressed: () => _validatePin(_pinController.text),
//               child: const Text("Enter", style: TextStyle(color: Colors.blueAccent)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _validatePin(String inputPin) {
//     if (inputPin == _serverPin) {
//       Navigator.pop(context); 
      
//       setState(() {
//         int adultIndex = _pageIdentifiers.indexOf('eighteenPlus');
//         if (adultIndex != -1) {
//           _selectedIndex = adultIndex;
//           _focusedIndex = adultIndex;
          
//           context.read<FocusProvider>().updateLastFocusedIdentifier('eighteenPlus');
//         }
//       });
      
//       Future.delayed(const Duration(milliseconds: 200), () {
//         if (mounted) context.read<FocusProvider>().requestFocus('eighteenPlus');
//       });

//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Invalid PIN"), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
//       );
//     }
//   }

//   // ✅ FLAG TO PREVENT DOUBLE CLICKS
//   bool _isHelpPopupOpen = false;

//   // ✅ HELP POPUP DIALOG WITH PERFECT FOCUS RESTORATION
//   void _showHelpPopup() {
//     if (_isHelpPopupOpen) return; 
//     _isHelpPopupOpen = true;

//     showDialog(
//       context: context,
//       barrierDismissible: true, 
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF2A2D3A),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: const Text(
//             "Scan for Support", 
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22), 
//             textAlign: TextAlign.center
//           ),
//           content: SizedBox(
//             width: 500, 
//             height: 220,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 if (_whatsappUrl.isNotEmpty)
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("WhatsApp", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
//                       const SizedBox(height: 15),
//                       Container(
//                         padding: const EdgeInsets.all(5),
//                         color: Colors.white,
//                         child: QrImageView(
//                           data: _whatsappUrl,
//                           version: QrVersions.auto,
//                           size: 130.0,
//                         ),
//                       ),
//                     ],
//                   ),
//                 if (_telegramUrl.isNotEmpty)
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Telegram", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 18)),
//                       const SizedBox(height: 15),
//                       Container(
//                         padding: const EdgeInsets.all(5),
//                         color: Colors.white,
//                         child: QrImageView(
//                           data: _telegramUrl,
//                           version: QrVersions.auto,
//                           size: 130.0,
//                         ),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//           actionsAlignment: MainAxisAlignment.center,
//           actions: [
//             StatefulBuilder(
//               builder: (context, setBtnState) {
//                 return Focus(
//                   autofocus: true, 
//                   onFocusChange: (hasFocus) {
//                     setBtnState(() {}); 
//                   },
//                   onKey: (node, event) {
//                     if (event is RawKeyDownEvent && 
//                        (event.logicalKey == LogicalKeyboardKey.enter || 
//                         event.logicalKey == LogicalKeyboardKey.select)) {
//                       Navigator.pop(context);
//                       return KeyEventResult.handled;
//                     }
//                     return KeyEventResult.ignored;
//                   },
//                   child: Builder(
//                     builder: (focusContext) {
//                       bool isFocused = Focus.of(focusContext).hasFocus;
                      
//                       return AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         transform: Matrix4.identity()..scale(isFocused ? 1.1 : 1.0), 
//                         transformAlignment: Alignment.center,
//                         padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
//                         decoration: BoxDecoration(
//                           color: isFocused ? Colors.white : Colors.redAccent, 
//                           borderRadius: BorderRadius.circular(8),
//                           boxShadow: isFocused 
//                               ? [const BoxShadow(color: Colors.white54, blurRadius: 15, spreadRadius: 2)] 
//                               : [], 
//                         ),
//                         child: Text(
//                           "Close", 
//                           style: TextStyle(
//                             color: isFocused ? Colors.redAccent : Colors.white, 
//                             fontWeight: FontWeight.w900, 
//                             fontSize: isFocused ? 18 : 16
//                           )
//                         ),
//                       );
//                     }
//                   ),
//                 );
//               }
//             ),
//           ],
//         );
//       },
//     ).then((_) {
//       _isHelpPopupOpen = false;
      
//       // ✅ DELAY TO ALLOW DIALOG TO UNMOUNT PROPERLY
//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted) {
//           int helpIndex = _menuItems.indexOf('HELP');
//           if (helpIndex != -1) {
//             setState(() {
//               _focusedIndex = helpIndex; // State UI refresh zaroori hai highlight ke liye
//             });
//             // ✅ DIRECT NODE REQUEST FOR BULLETPROOF FOCUS
//             _menuFocusNodes[helpIndex].requestFocus();
//             context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[helpIndex]);
//           }
//         }
//       });
//     });
//   }


//   Widget _getDynamicBottomContent() {
//     if (_pageIdentifiers.isEmpty || _selectedIndex >= _pageIdentifiers.length) return const SizedBox.shrink();
    
//     String currentId = _pageIdentifiers[_selectedIndex];
    
//     switch (currentId) {
//       case 'liveChannelLanguage': return const LiveChannelLanguageScreen();
//       case 'liveSports': return const LiveSportsScreen();
//       case 'liveKids': return const LiveKidsScreen();
//       case 'subVod': return const HorzontalVod();
//       case 'manageMovies': return const MoviesScreen();
//       case 'manageSdMovies': return const SdMoviesScreen();
//       case 'manageWebseries': return const ManageWebSeries();
//       case 'tvShows': return const ManageTvShows();
//       case 'sports': return const ManageSports();
//       case 'kids_show': return const ManageKidsShows();
//       case 'eighteenPlus': return const AdultMoviesScreen();
//       // ✅ ADDED DUMMY VIEW FOR HELP SO APP DOES NOT CRASH
//       case 'helpPopup': return const Center(child: Icon(Icons.support_agent_rounded, color: Colors.white24, size: 120));
//       default: return const SizedBox.shrink();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
//       );
//     }

//     if (_isPlanExpired) {
//       return PlanExpiredScreen(apiMessage: _apiMessage);
//     }

//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (!didPop) {
//           final fp = context.read<FocusProvider>();
//           if (fp.lastFocusedIdentifier != 'activeSidebar') {
//             fp.requestFocus('activeSidebar');
//             return; 
//           }

//           Navigator.of(context).push(
//             PageRouteBuilder(
//               opaque: false,
//               pageBuilder: (context, _, __) => const ExitConfirmationScreen(
//                 isFromBackButton: true,
//               ),
//             ),
//           );
//         }
//       },
//       child: NotificationListener<PlanUpdateNotification>(
//         onNotification: (notification) {
//           if (notification.isExpired) {
//             setState(() {
//               _isPlanExpired = true;
//               _apiMessage = notification.message;
//             });
//           } else {
//             setState(() {
//               _isPlanExpiring = notification.daysLeft <= 3;
//               _daysLeft = notification.daysLeft;
//             });
//           }
//           return true;
//         },
//       child: Scaffold(
//         backgroundColor: Colors.black, 
//         body: Stack(
//           children: [
//             Positioned.fill(
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: screenHeight * 0.65, 
//                     width: screenWidth, 
//                     child: BannerSlider(
//                       focusNode: _bannerFocusNode,
//                       isPlanExpiring: _isPlanExpiring,
//                       daysLeft: _daysLeft,             
//                     ),
//                   ),

//                   Expanded(
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child: Container(
//                         key: ValueKey<String>(_pageIdentifiers[_selectedIndex]),
//                         width: screenWidth, 
//                         child: _getDynamicBottomContent(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Positioned(
//               left: 0,
//               top: 0, 
//               bottom: 0,
//               child: ClipRRect(
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
//                   child: Container(
//                     width: screenWidth * 0.14,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.40), 
//                       border: Border(
//                         right: BorderSide(
//                           color: Colors.white.withOpacity(0.2), 
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: ListView.builder(
//                       controller: _sidebarScrollController, 
//                       clipBehavior: Clip.none, 
//                       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.40),
//                       itemCount: _menuItems.length,
//                       itemBuilder: (context, index) {
//                         return AnimatedSidebarItem(
//                           title: _menuItems[index],
//                           focusNode: _menuFocusNodes[index],
//                           isSelected: _selectedIndex == index,
//                           is18PlusItem: _menuItems[index] == '18+',
//                           onTap: () {
//                             if (_menuItems[index] == '18+') {
//                               _showPinDialog();
//                               return;
//                             }
//                             // ✅ OPEN POPUP ON CLICK
//                             if (_menuItems[index] == 'HELP') {
//                               setState(() {
//                                 _selectedIndex = index;
//                                 _focusedIndex = index;
//                               });
//                               _showHelpPopup();
//                               return;
//                             }
//                             setState(() {
//                               _selectedIndex = index;
//                               _focusedIndex = index;
//                               context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                             });
//                             Future.delayed(const Duration(milliseconds: 100), () {
//                               if (mounted) context.read<FocusProvider>().requestFocus(_pageIdentifiers[index]);
//                             });
//                           },
//                           onFocusChange: (hasFocus) {
//                             if (hasFocus) {
//                               setState(() {
//                                 _focusedIndex = index; 
//                                 context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                               });
//                             } else {
//                               setState(() {}); 
//                             }
//                           },
//                           onKey: (node, event) {
//                             if (event is RawKeyDownEvent) {
//                               if (event.logicalKey == LogicalKeyboardKey.arrowUp || 
//                                   event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                
//                                 final now = DateTime.now();
//                                 if (now.difference(_lastSidebarKeyTime).inMilliseconds < 350) {
//                                    return KeyEventResult.handled; 
//                                 }
//                                 _lastSidebarKeyTime = now; 

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                                   if (index < _menuItems.length - 1) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index + 1]);
//                                   }
//                                   return KeyEventResult.handled;
//                                 }

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                                   if (index > 0) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index - 1]);
//                                   } else {
//                                     context.read<FocusProvider>().requestFocus('topNavigation');
//                                   }
//                                   return KeyEventResult.handled;
//                                 }
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.enter ||
//                                   event.logicalKey == LogicalKeyboardKey.select) {
                                 
//                                  if (_menuItems[index] == '18+') {
//                                    _checkPlanStatus();
//                                    _showPinDialog();
//                                    return KeyEventResult.handled;
//                                  }
                                 
//                                  // ✅ OPEN POPUP ON ENTER
//                                  if (_menuItems[index] == 'HELP') {
//                                    setState(() {
//                                      _selectedIndex = index;
//                                      _focusedIndex = index;
//                                    });
//                                    _showHelpPopup();
//                                    return KeyEventResult.handled;
//                                  }

//                                  _checkPlanStatus(); // Moved here so it doesn't run when hitting Help

//                                  final fp = context.read<FocusProvider>();
//                                  final targetId = _pageIdentifiers[index];

//                                  fp.updateLastFocusedIdentifier(targetId);

//                                  setState(() {
//                                    _selectedIndex = index; 
//                                    _focusedIndex = index;  
//                                  });

//                                  return KeyEventResult.handled;
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                                 if (_menuItems[index] == '18+') {
//                                   if (_selectedIndex != index) {
//                                     _showPinDialog();
//                                     return KeyEventResult.handled;
//                                   }
//                                   context.read<FocusProvider>().requestFocus('eighteenPlus'); 
//                                   return KeyEventResult.handled;
//                                 }
//                                 // ✅ BLOCK RIGHT NAVIGATION IF ON HELP SCREEN
//                                 if (_menuItems[index] == 'HELP') {
//                                    return KeyEventResult.handled; 
//                                 }

//                                  setState(() {
//                                    _selectedIndex = index;
//                                    _focusedIndex = index;
//                                  });

//                                  context.read<FocusProvider>().requestFocus(_pageIdentifiers[_selectedIndex]);
//                                  return KeyEventResult.handled;
//                               }
//                             }
//                             return KeyEventResult.ignored;
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: SizedBox(
//                 height: screenHeight * 0.24, 
//                 child: TopNavigationBar(
//                   selectedPage: _topNavSelectedIndex,
//                   tvenableAll: true,
//                   onPageSelected: (index) {
//                     setState(() => _topNavSelectedIndex = index);
//                   }
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ));
//   }
// }

// class AnimatedSidebarItem extends StatefulWidget {
//   final String title;
//   final FocusNode focusNode;
//   final bool isSelected;
//   final bool is18PlusItem;
//   final VoidCallback onTap;
//   final ValueChanged<bool> onFocusChange; 
//   final FocusOnKeyCallback onKey;          

//   const AnimatedSidebarItem({
//     Key? key,
//     required this.title,
//     required this.focusNode,
//     required this.isSelected,
//     required this.is18PlusItem,
//     required this.onTap,
//     required this.onFocusChange,
//     required this.onKey,
//   }) : super(key: key);

//   @override
//   _AnimatedSidebarItemState createState() => _AnimatedSidebarItemState();
// }

// class _AnimatedSidebarItemState extends State<AnimatedSidebarItem> with SingleTickerProviderStateMixin {
//   late AnimationController _borderAnimationController;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _borderAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 2500),
//       vsync: this,
//     );
//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (mounted) {
//       setState(() {
//         _isFocused = widget.focusNode.hasFocus;
//       });
//       if (_isFocused) {
//         _borderAnimationController.repeat();
        
//         Future.delayed(const Duration(milliseconds: 50), () {
//           if (mounted) {
//             Scrollable.ensureVisible(
//               context,
//               alignment: 0.5, 
//               duration: const Duration(milliseconds: 350), 
//               curve: Curves.easeOutCubic, 
//             );
//           }
//         });

//       } else {
//         _borderAnimationController.stop();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _borderAnimationController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       focusNode: widget.focusNode,
//       onFocusChange: widget.onFocusChange,
//       onKey: widget.onKey,
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: Container(
//           height: 48, 
//           margin: const EdgeInsets.only(left: 25, right: 10, top: 3, bottom: 3), 
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: _isFocused
//                 ? [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))]
//                 : [],
//           ),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               if (_isFocused)
//                 AnimatedBuilder(
//                   animation: _borderAnimationController,
//                   builder: (context, child) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         gradient: SweepGradient(
//                           colors: [
//                             Colors.white.withOpacity(0.1),
//                             Colors.white,
//                             Colors.white,
//                             Colors.white.withOpacity(0.1),
//                           ],
//                           stops: const [0.0, 0.25, 0.5, 1.0],
//                           transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
//                         ),
//                       ),
//                     );
//                   },
//                 ),

//               Padding(
//                 padding: EdgeInsets.all(_isFocused ? 5.0 : 0.0), 
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: _isFocused 
//                         ? Colors.black 
//                         : (widget.isSelected ? Colors.black.withOpacity(0.15) : Colors.transparent),
//                     borderRadius: BorderRadius.circular(_isFocused ? 4 : 8),
//                   ),
//                   child: Center(
//                     child: Text(
//                       widget.title,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: _isFocused 
//                             ? Colors.white 
//                             : (widget.isSelected ? Colors.black87 : Colors.black87),
//                         fontSize: _isFocused ? 13 : 11,
//                         fontWeight: _isFocused || widget.isSelected ? FontWeight.w900 : FontWeight.w700,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PlanExpiredScreen extends StatefulWidget {
//   final String apiMessage;

//   const PlanExpiredScreen({Key? key, required this.apiMessage}) : super(key: key);

//   @override
//   _PlanExpiredScreenState createState() => _PlanExpiredScreenState();
// }

// class _PlanExpiredScreenState extends State<PlanExpiredScreen> {
//   bool _isLoading = false;
  
//   final FocusNode _refreshFocus = FocusNode();
//   final FocusNode _exitFocus = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(_refreshFocus);
//     });
//   }

//   @override
//   void dispose() {
//     _refreshFocus.dispose();
//     _exitFocus.dispose();
//     super.dispose();
//   }

//   Future<void> _checkSubscriptionStatus() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);

//     final String? authKey = SessionManager.authKey;
//     if (authKey == null || authKey.isEmpty) {
//       setState(() => _isLoading = false);
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
//       ).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final res = json.decode(response.body);
//         final String expireValue = res['plan_expired'].toString().toLowerCase();
//         bool planExpired = (expireValue == 'true' || expireValue == '1');

//         if (!planExpired) {
//           if (mounted) {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => MyHome()),
//               (route) => false,
//             );
//           }
//         } else {
//           _showRechargeAlert("Your plan is still expired. Please recharge to continue enjoying our services!");
//         }
//       } else {
//         _showRechargeAlert("Server error. Please try again later.");
//       }
//     } catch (e) {
//       _showRechargeAlert("Network error. Please check your internet connection.");
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _showRechargeAlert(String message) {
//     if (!mounted) return;
    
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
//             const SizedBox(width: 15),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.redAccent.shade700,
//         duration: const Duration(seconds: 4),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: EdgeInsets.only(
//           bottom: MediaQuery.of(context).size.height * 0.1, 
//           left: MediaQuery.of(context).size.width * 0.2, 
//           right: MediaQuery.of(context).size.width * 0.2
//         ),
//         elevation: 10,
//       ),
//     );
//   }

//   void _exitApp() {
//     if (Platform.isAndroid) {
//       SystemNavigator.pop();
//     } else {
//       exit(0);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sw = MediaQuery.of(context).size.width;
//     final sh = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: const Color(0xFF1E1E1E), 
//       body: Center(
//         child: Container(
//           width: sw * 0.6,
//           padding: const EdgeInsets.all(40),
//           decoration: BoxDecoration(
//             color: const Color(0xFF2C2C2C),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.5),
//                 blurRadius: 20,
//                 spreadRadius: 5,
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.error_outline_rounded, size: 80, color: Colors.redAccent),
//               const SizedBox(height: 20),
              
//               const Text(
//                 "Subscription Expired",
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 15),
              
//               Text(
//                 widget.apiMessage.isNotEmpty 
//                     ? widget.apiMessage 
//                     : "Your plan has expired. Please recharge your account to resume watching.",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   color: Colors.white70,
//                 ),
//               ),
//               const SizedBox(height: 40),

//               if (_isLoading)
//                 const CircularProgressIndicator(color: Colors.blueAccent)
//               else
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildTVButton(
//                       label: "EXIT",
//                       icon: Icons.exit_to_app_rounded,
//                       focusNode: _exitFocus,
//                       onTap: _exitApp,
//                       defaultColor: Colors.grey.shade800,
//                       focusedColor: Colors.redAccent,
//                     ),
                    
//                     const SizedBox(width: 30),
                    
//                     _buildTVButton(
//                       label: "REFRESH STATUS",
//                       icon: Icons.refresh_rounded,
//                       focusNode: _refreshFocus,
//                       onTap: _checkSubscriptionStatus,
//                       defaultColor: Colors.grey.shade800,
//                       focusedColor: Colors.blueAccent,
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTVButton({
//     required String label,
//     required IconData icon,
//     required FocusNode focusNode,
//     required VoidCallback onTap,
//     required Color defaultColor,
//     required Color focusedColor,
//   }) {
//     return StatefulBuilder(
//       builder: (context, setState) {
//         return Focus(
//           focusNode: focusNode,
//           onFocusChange: (hasFocus) => setState(() {}),
//           onKey: (node, event) {
//             if (event is RawKeyDownEvent && 
//                (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
//               onTap();
//               return KeyEventResult.handled;
//             }
//             return KeyEventResult.ignored;
//           },
//           child: GestureDetector(
//             onTap: onTap,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//               decoration: BoxDecoration(
//                 color: focusNode.hasFocus ? focusedColor : defaultColor,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: focusNode.hasFocus ? Colors.white : Colors.transparent,
//                   width: 2,
//                 ),
//                 boxShadow: focusNode.hasFocus
//                     ? [BoxShadow(color: focusedColor.withOpacity(0.6), blurRadius: 15, spreadRadius: 2)]
//                     : [],
//               ),
//               child: Row(
//                 children: [
//                   Icon(icon, color: Colors.white, size: 24),
//                   const SizedBox(width: 10),
//                   Text(
//                     label,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }
//     );
//   }
// }

// class TvActionButton extends StatefulWidget {
//   final String label;
//   final IconData icon;
//   final Color baseColor;
//   final VoidCallback onPressed;
//   final bool autoFocus;

//   const TvActionButton({
//     Key? key,
//     required this.label,
//     required this.icon,
//     required this.baseColor,
//     required this.onPressed,
//     this.autoFocus = false,
//   }) : super(key: key);

//   @override
//   State<TvActionButton> createState() => _TvActionButtonState();
// }

// class _TvActionButtonState extends State<TvActionButton> {
//   bool _isFocused = false;

//   @override
//   Widget build(BuildContext context) {
//     return Transform.scale(
//       scale: _isFocused ? 1.05 : 1.0, 
//       child: Focus(
//         autofocus: widget.autoFocus,
//         onFocusChange: (hasFocus) {
//           setState(() {
//             _isFocused = hasFocus;
//           });
//         },
//         onKey: (node, event) {
//           if (event is RawKeyDownEvent) {
//             if (event.logicalKey == LogicalKeyboardKey.enter || 
//                 event.logicalKey == LogicalKeyboardKey.select ||
//                 event.logicalKey == LogicalKeyboardKey.numpadEnter) {
              
//               widget.onPressed();
//               return KeyEventResult.handled;
//             }
//           }
//           return KeyEventResult.ignored;
//         },
//         child: ElevatedButton.icon(
//           focusNode: null, 
//           icon: Icon(
//             widget.icon, 
//             color: Colors.white,
//             size: _isFocused ? 28 : 24,
//           ),
//           label: Text(
//             widget.label,
//             style: TextStyle(
//               fontSize: _isFocused ? 20 : 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: widget.baseColor,
//             padding: const EdgeInsets.symmetric(vertical: 15),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: _isFocused 
//                   ? const BorderSide(color: Colors.white, width: 3) 
//                   : BorderSide.none,
//             ),
//             elevation: _isFocused ? 12 : 6,
//             shadowColor: _isFocused ? Colors.white.withOpacity(0.4) : widget.baseColor,
//           ),
//           onPressed: widget.onPressed,
//         ),
//       ),
//     );
//   }
// }






// import 'dart:convert';
// import 'dart:io'; 
// import 'package:http/http.dart' as https; 
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/live_kids_screen/live_kids_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/live_sports_screen/live_sports_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sd_movies_screen/sd_movies_screen.dart';
// import 'dart:math' as math; 
// import 'package:qr_flutter/qr_flutter.dart'; // ✅ ADDED QR FLUTTER IMPORT

// // ✅ IMPORT EXIT & EXPIRED SCREENS
// import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// // Agar neeche error aaye toh is import ko comment kar dena kyunki class yahi neeche likhi hai
// // import 'package:mobi_tv_entertainment/plan_expired_screen.dart';

// // ✅ PAGES IMPORTS
// import 'package:mobi_tv_entertainment/components/home_screen_pages/above_18/above_eighteen.dart'; 
// import 'package:mobi_tv_entertainment/components/home_screen_pages/banner_slider_screen/banner_slider_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/kids_shows/kids_channels.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/movies_screen/movies.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_live_screen/live_channel_language_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/manage_tv_shows.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show_pak/tv_show_pak.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/manage_webseries.dart';
// import 'package:mobi_tv_entertainment/components/menu/top_navigation_bar.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/main.dart'; 
// import 'package:provider/provider.dart';
// import 'dart:ui'; 


// // ✅ 1. ADD THIS CUSTOM NOTIFICATION CLASS AT THE TOP
// class PlanUpdateNotification extends Notification {
//   final int daysLeft;
//   final bool isExpired;
//   final String message;

//   PlanUpdateNotification({
//     required this.daysLeft,
//     required this.isExpired,
//     required this.message,
//   });
// }


// class MainDashboardScreen extends StatefulWidget {
//   const MainDashboardScreen({Key? key}) : super(key: key);

//   @override
//   _MainDashboardScreenState createState() => _MainDashboardScreenState();
// }

// class _MainDashboardScreenState extends State<MainDashboardScreen> with AutomaticKeepAliveClientMixin , WidgetsBindingObserver {
  
//   @override
//   bool get wantKeepAlive => true;

//   bool _isLoading = true;
//   bool _isPlanExpired = false;

//   // ✅ VARIABLES FOR EXPIRY BANNER
//   bool _isPlanExpiring = false;
//   int _daysLeft = 0;

//   bool _showContentNetwork = false;
//   bool _showMovies = false;
//   bool _showSdMovies = false;
//   bool _showWebseries = false;
//   bool _showTvShows = false;
//   bool _showTvShowsPak = false;
//   bool _showSports = false;
//   bool _showReligious = false;
//   bool _showKids = false;
//   bool _show18Plus = false;

//   // ✅ VARIABLES FOR HELP POPUP
//   bool _showHelp = false;
//   String _whatsappUrl = "";
//   String _telegramUrl = "";

//   List<String> _menuItems = [];
//   List<String> _pageIdentifiers = [];
//   late List<FocusNode> _menuFocusNodes = [];
//   DateTime _lastSidebarKeyTime = DateTime.now();

//   int _selectedIndex = 0; 
//   int _focusedIndex = 0;  
//   int _topNavSelectedIndex = 0; 
//   final FocusNode _bannerFocusNode = FocusNode();
  
//   late ScrollController _sidebarScrollController;

//   String _serverPin = "";
//   String _apiMessage = "";

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this); // ✅ ADD THIS LINE
//     _sidebarScrollController = ScrollController();
//     _initializeDashboard();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this); // ✅ ADD THIS LINE
//     _sidebarScrollController.dispose();
//     for (var node in _menuFocusNodes) node.dispose();
//     _bannerFocusNode.dispose();
//     super.dispose();
//   }


//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
    
//     // ✅ TRIGGER WHEN APP COMES BACK FROM BACKGROUND / HOME BUTTON
//     if (state == AppLifecycleState.resumed) {
//       print("App Resumed: Re-checking Plan Status...");
      
//       // Call your API check silently
//       _checkPlanStatus().then((_) {
//         // If the plan expired while they were in the background, 
//         // update the UI immediately to show the Expiry Screen
//         if (_isPlanExpired && mounted) {
//           setState(() {}); 
//         }
//       });
//     }
//   }

//   Future<void> _initializeDashboard() async {
//     await _checkPlanStatus();

//     if (!mounted) return;

//     if (_isPlanExpired) {
//       setState(() {
//         _isLoading = false; 
//       });
//       return; 
//     }

//     await _check18PlusStatus();
//     await _fetchHelplines(); // ✅ ADDED HELPLINES API CALL
//     _buildDynamicMenu();

//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _setupDashboardController();
        
//         if (_menuFocusNodes.isNotEmpty) {
//           setState(() {
//             _focusedIndex = 0;
//             _selectedIndex = 0;
//           });
//         }

//         if (_menuFocusNodes.isNotEmpty) {
//           FocusScope.of(context).requestFocus(_menuFocusNodes[0]);
//           context.read<FocusProvider>().updateLastFocusedIdentifier('activeSidebar');
//         }
//       });
//     }
//   }

//   // ✅ FETCH HELPLINES API IMPLEMENTATION
//   Future<void> _fetchHelplines() async {
//     try {
//       final url = Uri.parse(SessionManager.baseUrl + 'get-helplines');
//       final response = await https.get(
//         url,
//         headers: {
//           "auth-key": SessionManager.authKey ?? "",
//           "domain": SessionManager.savedDomain ?? "",
//         },
//       );

//       if (response.statusCode == 200) {
//         final res = json.decode(response.body);
//         if (res['data'] != null) {
//           final data = res['data'];
//           if (data['status'] == 1 || data['status'] == true) {
//             if (mounted) {
//               setState(() {
//                 _showHelp = true;
//                 _whatsappUrl = data['whatsapp_url'] ?? "";
//                 _telegramUrl = data['telegram_url'] ?? "";
//               });
//             }
//           }
//         }
//       }
//     } catch (e) {
//       print("Error fetching helplines: $e");
//     }
//   }

//   void _loadCachedMenuSettings() {
//     try {
//       String? cachedData = SessionManager.getSavedDomainContent();
//       if (cachedData != null && cachedData.isNotEmpty) {
//         Map<String, dynamic> domainContent = json.decode(cachedData);
//         setState(() {
//           _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//           _showMovies = (domainContent['movies'] ?? 0) == 1;
//           _showSdMovies = (domainContent['sd_movies'] ?? 0) == 1;
//           _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//           _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//           _showKids = (domainContent['kids_show'] ?? 0) == 1;
//         });
//         _buildDynamicMenu();
//       }
//     } catch (e) {
//       print("Error loading cached settings: $e");
//     }
//   }

//   Future<void> _checkPlanStatus() async {
//     final String? authKey = SessionManager.authKey;

//     if (authKey == null || authKey.isEmpty) {
//       _loadCachedMenuSettings(); 
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

//         final String expireValue = res['plan_expired'].toString().toLowerCase();
//         bool planExpired = (expireValue == 'true' || expireValue == '1');

//         final int daysLeft = res['days'] ?? 99;
//         _daysLeft = daysLeft;
//         bool planWillExpire = (daysLeft <= 3);

//         _apiMessage = res['message'] ?? 'Status Unknown';
//         final domainContent = res['domain_content'];

//         if (planExpired) {
//           _isPlanExpired = true; 
//           return; 
//         }

//         if (domainContent != null && domainContent is Map) {
//           SessionManager.saveDomainContent(json.encode(domainContent));

//           setState(() {
//             _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//             _showMovies = (domainContent['movies'] ?? 0) == 1;
//             _showSdMovies = (domainContent['sd_movies'] ?? 0) == 1;
//             _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//             _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//             _showKids = (domainContent['kids_show'] ?? 0) == 1;
//           });
//           _buildDynamicMenu();
//         }

//         if (planWillExpire) {
//           setState(() {
//             _isPlanExpiring = true;
//           });
//         }
//       } else {
//         _loadCachedMenuSettings();
//       }
//     } catch (e) {
//       print("Error fetching Plan Status: $e");
//       _loadCachedMenuSettings();
//     }
//   }

//   Future<void> _check18PlusStatus() async {
//     try {
//       final url = Uri.parse(SessionManager.baseUrl + 'showabove18');
//       final headers = {
//         "auth-key": SessionManager.authKey,
//         "domain": SessionManager.savedDomain,
//       };
//       final response = await https.get(url, headers: headers);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == true && mounted) {
//           setState(() {
//             _show18Plus = true;
//             _serverPin = data['above18_pin'].toString();
//           });
//         }
//       }
//     } catch (e) {
//       print("Error fetching 18+ status: $e");
//     }
//   }

//   void _buildDynamicMenu() {
//     setState(() { 
//       // ✅ USE TEMP LISTS TO PREVENT UI GLITCHES
//       List<String> tempMenuItems = [];
//       List<String> tempPageIdentifiers = [];

//       tempMenuItems.add('LIVE TV');
//       tempPageIdentifiers.add('liveChannelLanguage');
//       tempMenuItems.add('LIVE SPORTS');
//       tempPageIdentifiers.add('liveSports');
//       tempMenuItems.add('LIVE KIDS');
//       tempPageIdentifiers.add('liveKids');

//       if (_showContentNetwork) { tempMenuItems.add('OTT APPS'); tempPageIdentifiers.add('subVod'); }
//       if (_showMovies) { tempMenuItems.add('LATEST 4K MOVIES'); tempPageIdentifiers.add('manageMovies'); }
//       if (_showSdMovies) { tempMenuItems.add('LATEST SD MOVIES'); tempPageIdentifiers.add('manageSdMovies'); }
//       if (_showWebseries) { tempMenuItems.add('WEB SERIES'); tempPageIdentifiers.add('manageWebseries'); }
//       if (_showTvShows) { tempMenuItems.add('TV SHOWS'); tempPageIdentifiers.add('tvShows'); }
//       if (_showKids) { tempMenuItems.add('KIDS ZONE'); tempPageIdentifiers.add('kids_show'); }
      
//       if (_show18Plus) { 
//         tempMenuItems.add('18+'); 
//         tempPageIdentifiers.add('eighteenPlus'); 
//       }

//       // ✅ ADD HELP BUTTON AT THE END
//       if (_showHelp) {
//         tempMenuItems.add('HELP');
//         tempPageIdentifiers.add('helpPopup');
//       }

//       _menuItems = tempMenuItems;
//       _pageIdentifiers = tempPageIdentifiers;

//       // ✅ FIX: DO NOT DESTROY FOCUS NODES IF MENU SIZE IS SAME
//       // Yeh prevent karega ki popup band hone par node completely gayab na ho jaye
//       if (_menuFocusNodes.length != _menuItems.length) {
//         for (var node in _menuFocusNodes) {
//           node.dispose();
//         }
//         _menuFocusNodes = List.generate(_menuItems.length, (index) => FocusNode());
//       }
//     });
//   }

//   void _setupDashboardController() {
//     final fp = context.read<FocusProvider>();
    
//     if (_menuFocusNodes.isNotEmpty) {
//       fp.registerFocusNode('activeSidebar', _menuFocusNodes[_selectedIndex]);
//     }

//     fp.onDashboardNextPage = () {
//       int maxContentIndex = _menuItems.length - 1;
//       if (_menuItems.contains('18+') && !_menuItems.contains('HELP')) {
//         maxContentIndex = _menuItems.length - 2;
//       } else if (_menuItems.contains('18+') && _menuItems.contains('HELP')) {
//         maxContentIndex = _menuItems.length - 3;
//       } else if (!_menuItems.contains('18+') && _menuItems.contains('HELP')) {
//         maxContentIndex = _menuItems.length - 2;
//       }

//       if (_selectedIndex < maxContentIndex) {
//         _changePageAndFocus(_selectedIndex + 1);
//       }
//     };

//     fp.onDashboardPrevPage = () {
//       if (_selectedIndex > 0) {
//         _changePageAndFocus(_selectedIndex - 1);
//       } else {
//         fp.requestFocus('watchNow'); 
//       }
//     };

//     fp.onBannerDown = () {
//       if (_pageIdentifiers.isNotEmpty) {
//         fp.requestFocus(_pageIdentifiers[_selectedIndex]);
//       }
//     };
//   }

//   void _changePageAndFocus(int newIndex) {
//     if (newIndex < 0 || newIndex >= _menuItems.length) return;

//     final targetId = _pageIdentifiers[newIndex];
    
//     setState(() {
//       _selectedIndex = newIndex;
//       _focusedIndex = newIndex; 
//     });

//     final fp = context.read<FocusProvider>();
//     fp.registerFocusNode('activeSidebar', _menuFocusNodes[newIndex]);
//     fp.updateLastFocusedIdentifier(targetId); 

//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         fp.requestFocus(targetId);
//       }
//     });
//   }

//   void _showPinDialog() {
//     final TextEditingController _pinController = TextEditingController();
//     final FocusNode _inputFocus = FocusNode();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF2A2D3A),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: const Text("Enter 18+ PIN", style: TextStyle(color: Colors.white)),
//           content: TextField(
//             controller: _pinController,
//             focusNode: _inputFocus,
//             autofocus: true,
//             obscureText: true,
//             keyboardType: TextInputType.number,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               hintText: "Enter PIN",
//               hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
//               enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
//               focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
//             ),
//             onSubmitted: (_) => _validatePin(_pinController.text),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
//             ),
//             TextButton(
//               onPressed: () => _validatePin(_pinController.text),
//               child: const Text("Enter", style: TextStyle(color: Colors.blueAccent)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _validatePin(String inputPin) {
//     if (inputPin == _serverPin) {
//       Navigator.pop(context); 
      
//       setState(() {
//         int adultIndex = _pageIdentifiers.indexOf('eighteenPlus');
//         if (adultIndex != -1) {
//           _selectedIndex = adultIndex;
//           _focusedIndex = adultIndex;
          
//           context.read<FocusProvider>().updateLastFocusedIdentifier('eighteenPlus');
//         }
//       });
      
//       Future.delayed(const Duration(milliseconds: 200), () {
//         if (mounted) context.read<FocusProvider>().requestFocus('eighteenPlus');
//       });

//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Invalid PIN"), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
//       );
//     }
//   }

// // ✅ FLAG TO PREVENT DOUBLE CLICKS
//   bool _isHelpPopupOpen = false;

//   // ✅ HELP POPUP DIALOG WITH ALWAYS VISIBLE PIN
//   void _showHelpPopup() {
//     if (_isHelpPopupOpen) return; 
//     _isHelpPopupOpen = true;

//     // 👇 AGAR AAPKA LOGIN PIN SESSION MANAGER MEIN HAI TO YAHAN GET KAREIN
//     String displayPin = SessionManager.loginPin ?? "N/A";
//     // String displayPin = _serverPin.isNotEmpty ? _serverPin : "Not Set"; 

//     showDialog(
//       context: context,
//       barrierDismissible: true, 
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF2A2D3A),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: const Text(
//             "Scan for Support", 
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22), 
//             textAlign: TextAlign.center
//           ),
//           content: SizedBox(
//             width: 500, 
//             height: 280, 
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // ✅ PIN HUMESHA SHOW HOGA (Condition hata di gayi hai)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 25.0),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.black45,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.amberAccent.withOpacity(0.5), width: 1),
//                     ),
//                     child: Text(
//                       "CURRENT PIN: $displayPin", // 👈 APNA VARIABLE YAHAN DAALEIN
//                       style: const TextStyle(
//                         color: Colors.amberAccent,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 22,
//                         letterSpacing: 2.0,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     if (_whatsappUrl.isNotEmpty)
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("WhatsApp", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
//                           const SizedBox(height: 15),
//                           Container(
//                             padding: const EdgeInsets.all(5),
//                             color: Colors.white,
//                             child: QrImageView(
//                               data: _whatsappUrl,
//                               version: QrVersions.auto,
//                               size: 130.0,
//                             ),
//                           ),
//                         ],
//                       ),
//                     if (_telegramUrl.isNotEmpty)
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("Telegram", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 18)),
//                           const SizedBox(height: 15),
//                           Container(
//                             padding: const EdgeInsets.all(5),
//                             color: Colors.white,
//                             child: QrImageView(
//                               data: _telegramUrl,
//                               version: QrVersions.auto,
//                               size: 130.0,
//                             ),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           actionsAlignment: MainAxisAlignment.center,
//           actions: [
//             StatefulBuilder(
//               builder: (context, setBtnState) {
//                 return Focus(
//                   autofocus: true, 
//                   onFocusChange: (hasFocus) {
//                     setBtnState(() {}); 
//                   },
//                   onKey: (node, event) {
//                     if (event is RawKeyDownEvent && 
//                        (event.logicalKey == LogicalKeyboardKey.enter || 
//                         event.logicalKey == LogicalKeyboardKey.select)) {
//                       Navigator.pop(context);
//                       return KeyEventResult.handled;
//                     }
//                     return KeyEventResult.ignored;
//                   },
//                   child: Builder(
//                     builder: (focusContext) {
//                       bool isFocused = Focus.of(focusContext).hasFocus;
                      
//                       return AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         transform: Matrix4.identity()..scale(isFocused ? 1.1 : 1.0), 
//                         transformAlignment: Alignment.center,
//                         padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
//                         decoration: BoxDecoration(
//                           color: isFocused ? Colors.white : Colors.redAccent, 
//                           borderRadius: BorderRadius.circular(8),
//                           boxShadow: isFocused 
//                               ? [const BoxShadow(color: Colors.white54, blurRadius: 15, spreadRadius: 2)] 
//                               : [], 
//                         ),
//                         child: Text(
//                           "Close", 
//                           style: TextStyle(
//                             color: isFocused ? Colors.redAccent : Colors.white, 
//                             fontWeight: FontWeight.w900, 
//                             fontSize: isFocused ? 18 : 16
//                           )
//                         ),
//                       );
//                     }
//                   ),
//                 );
//               }
//             ),
//           ],
//         );
//       },
//     ).then((_) {
//       _isHelpPopupOpen = false;
      
//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted) {
//           int helpIndex = _menuItems.indexOf('HELP');
//           if (helpIndex != -1) {
//             setState(() {
//               _focusedIndex = helpIndex; 
//             });
//             _menuFocusNodes[helpIndex].requestFocus();
//             context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[helpIndex]);
//           }
//         }
//       });
//     });
//   }


//   Widget _getDynamicBottomContent() {
//     if (_pageIdentifiers.isEmpty || _selectedIndex >= _pageIdentifiers.length) return const SizedBox.shrink();
    
//     String currentId = _pageIdentifiers[_selectedIndex];
    
//     switch (currentId) {
//       case 'liveChannelLanguage': return const LiveChannelLanguageScreen();
//       case 'liveSports': return const LiveSportsScreen();
//       case 'liveKids': return const LiveKidsScreen();
//       case 'subVod': return const HorzontalVod();
//       case 'manageMovies': return const MoviesScreen();
//       case 'manageSdMovies': return const SdMoviesScreen();
//       case 'manageWebseries': return const ManageWebSeries();
//       case 'tvShows': return const ManageTvShows();
//       case 'sports': return const ManageSports();
//       case 'kids_show': return const ManageKidsShows();
//       case 'eighteenPlus': return const AdultMoviesScreen();
//       // ✅ ADDED DUMMY VIEW FOR HELP SO APP DOES NOT CRASH
//       case 'helpPopup': return const Center(child: Icon(Icons.support_agent_rounded, color: Colors.white24, size: 120));
//       default: return const SizedBox.shrink();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
//       );
//     }

//     if (_isPlanExpired) {
//       return PlanExpiredScreen(apiMessage: _apiMessage);
//     }

//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (!didPop) {
//           final fp = context.read<FocusProvider>();
//           if (fp.lastFocusedIdentifier != 'activeSidebar') {
//             fp.requestFocus('activeSidebar');
//             return; 
//           }

//           Navigator.of(context).push(
//             PageRouteBuilder(
//               opaque: false,
//               pageBuilder: (context, _, __) => const ExitConfirmationScreen(
//                 isFromBackButton: true,
//               ),
//             ),
//           );
//         }
//       },
//       child: NotificationListener<PlanUpdateNotification>(
//         onNotification: (notification) {
//           if (notification.isExpired) {
//             setState(() {
//               _isPlanExpired = true;
//               _apiMessage = notification.message;
//             });
//           } else {
//             setState(() {
//               _isPlanExpiring = notification.daysLeft <= 3;
//               _daysLeft = notification.daysLeft;
//             });
//           }
//           return true;
//         },
//       child: Scaffold(
//         backgroundColor: Colors.black, 
//         body: Stack(
//           children: [
//             Positioned.fill(
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: screenHeight * 0.65, 
//                     width: screenWidth, 
//                     child: BannerSlider(
//                       focusNode: _bannerFocusNode,
//                       isPlanExpiring: _isPlanExpiring,
//                       daysLeft: _daysLeft,             
//                     ),
//                   ),

//                   Expanded(
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child: Container(
//                         key: ValueKey<String>(_pageIdentifiers[_selectedIndex]),
//                         width: screenWidth, 
//                         child: _getDynamicBottomContent(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Positioned(
//               left: 0,
//               top: 0, 
//               bottom: 0,
//               child: ClipRRect(
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
//                   child: Container(
//                     width: screenWidth * 0.14,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.40), 
//                       border: Border(
//                         right: BorderSide(
//                           color: Colors.white.withOpacity(0.2), 
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: ListView.builder(
//                       controller: _sidebarScrollController, 
//                       clipBehavior: Clip.none, 
//                       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.40),
//                       itemCount: _menuItems.length,
//                       itemBuilder: (context, index) {
//                         return AnimatedSidebarItem(
//                           title: _menuItems[index],
//                           focusNode: _menuFocusNodes[index],
//                           isSelected: _selectedIndex == index,
//                           is18PlusItem: _menuItems[index] == '18+',
//                           onTap: () {
//                             if (_menuItems[index] == '18+') {
//                               _showPinDialog();
//                               return;
//                             }
//                             // ✅ OPEN POPUP ON CLICK
//                             if (_menuItems[index] == 'HELP') {
//                               setState(() {
//                                 _selectedIndex = index;
//                                 _focusedIndex = index;
//                               });
//                               _showHelpPopup();
//                               return;
//                             }
//                             setState(() {
//                               _selectedIndex = index;
//                               _focusedIndex = index;
//                               context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                             });
//                             Future.delayed(const Duration(milliseconds: 100), () {
//                               if (mounted) context.read<FocusProvider>().requestFocus(_pageIdentifiers[index]);
//                             });
//                           },
//                           onFocusChange: (hasFocus) {
//                             if (hasFocus) {
//                               setState(() {
//                                 _focusedIndex = index; 
//                                 context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                               });
//                             } else {
//                               setState(() {}); 
//                             }
//                           },
//                           onKey: (node, event) {
//                             if (event is RawKeyDownEvent) {
//                               if (event.logicalKey == LogicalKeyboardKey.arrowUp || 
//                                   event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                
//                                 final now = DateTime.now();
//                                 if (now.difference(_lastSidebarKeyTime).inMilliseconds < 350) {
//                                    return KeyEventResult.handled; 
//                                 }
//                                 _lastSidebarKeyTime = now; 

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                                   if (index < _menuItems.length - 1) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index + 1]);
//                                   }
//                                   return KeyEventResult.handled;
//                                 }

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                                   if (index > 0) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index - 1]);
//                                   } else {
//                                     context.read<FocusProvider>().requestFocus('topNavigation');
//                                   }
//                                   return KeyEventResult.handled;
//                                 }
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.enter ||
//                                   event.logicalKey == LogicalKeyboardKey.select) {
                                 
//                                  if (_menuItems[index] == '18+') {
//                                    _checkPlanStatus();
//                                    _showPinDialog();
//                                    return KeyEventResult.handled;
//                                  }
                                 
//                                  // ✅ OPEN POPUP ON ENTER
//                                  if (_menuItems[index] == 'HELP') {
//                                    setState(() {
//                                      _selectedIndex = index;
//                                      _focusedIndex = index;
//                                    });
//                                    _showHelpPopup();
//                                    return KeyEventResult.handled;
//                                  }

//                                  _checkPlanStatus(); // Moved here so it doesn't run when hitting Help

//                                  final fp = context.read<FocusProvider>();
//                                  final targetId = _pageIdentifiers[index];

//                                  fp.updateLastFocusedIdentifier(targetId);

//                                  setState(() {
//                                    _selectedIndex = index; 
//                                    _focusedIndex = index;  
//                                  });

//                                  return KeyEventResult.handled;
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                                 if (_menuItems[index] == '18+') {
//                                   if (_selectedIndex != index) {
//                                     _showPinDialog();
//                                     return KeyEventResult.handled;
//                                   }
//                                   context.read<FocusProvider>().requestFocus('eighteenPlus'); 
//                                   return KeyEventResult.handled;
//                                 }
//                                 // ✅ BLOCK RIGHT NAVIGATION IF ON HELP SCREEN
//                                 if (_menuItems[index] == 'HELP') {
//                                    return KeyEventResult.handled; 
//                                 }

//                                  setState(() {
//                                    _selectedIndex = index;
//                                    _focusedIndex = index;
//                                  });

//                                  context.read<FocusProvider>().requestFocus(_pageIdentifiers[_selectedIndex]);
//                                  return KeyEventResult.handled;
//                               }
//                             }
//                             return KeyEventResult.ignored;
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: SizedBox(
//                 height: screenHeight * 0.24, 
//                 child: TopNavigationBar(
//                   selectedPage: _topNavSelectedIndex,
//                   tvenableAll: true,
//                   onPageSelected: (index) {
//                     setState(() => _topNavSelectedIndex = index);
//                   }
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ));
//   }
// }

// class AnimatedSidebarItem extends StatefulWidget {
//   final String title;
//   final FocusNode focusNode;
//   final bool isSelected;
//   final bool is18PlusItem;
//   final VoidCallback onTap;
//   final ValueChanged<bool> onFocusChange; 
//   final FocusOnKeyCallback onKey;          

//   const AnimatedSidebarItem({
//     Key? key,
//     required this.title,
//     required this.focusNode,
//     required this.isSelected,
//     required this.is18PlusItem,
//     required this.onTap,
//     required this.onFocusChange,
//     required this.onKey,
//   }) : super(key: key);

//   @override
//   _AnimatedSidebarItemState createState() => _AnimatedSidebarItemState();
// }

// class _AnimatedSidebarItemState extends State<AnimatedSidebarItem> with SingleTickerProviderStateMixin {
//   late AnimationController _borderAnimationController;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _borderAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 2500),
//       vsync: this,
//     );
//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (mounted) {
//       setState(() {
//         _isFocused = widget.focusNode.hasFocus;
//       });
//       if (_isFocused) {
//         _borderAnimationController.repeat();
        
//         Future.delayed(const Duration(milliseconds: 50), () {
//           if (mounted) {
//             Scrollable.ensureVisible(
//               context,
//               alignment: 0.5, 
//               duration: const Duration(milliseconds: 350), 
//               curve: Curves.easeOutCubic, 
//             );
//           }
//         });

//       } else {
//         _borderAnimationController.stop();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _borderAnimationController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       focusNode: widget.focusNode,
//       onFocusChange: widget.onFocusChange,
//       onKey: widget.onKey,
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: Container(
//           height: 48, 
//           margin: const EdgeInsets.only(left: 25, right: 10, top: 3, bottom: 3), 
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: _isFocused
//                 ? [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))]
//                 : [],
//           ),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               if (_isFocused)
//                 AnimatedBuilder(
//                   animation: _borderAnimationController,
//                   builder: (context, child) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         gradient: SweepGradient(
//                           colors: [
//                             Colors.white.withOpacity(0.1),
//                             Colors.white,
//                             Colors.white,
//                             Colors.white.withOpacity(0.1),
//                           ],
//                           stops: const [0.0, 0.25, 0.5, 1.0],
//                           transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
//                         ),
//                       ),
//                     );
//                   },
//                 ),

//               Padding(
//                 padding: EdgeInsets.all(_isFocused ? 5.0 : 0.0), 
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: _isFocused 
//                         ? Colors.black 
//                         : (widget.isSelected ? Colors.black.withOpacity(0.15) : Colors.transparent),
//                     borderRadius: BorderRadius.circular(_isFocused ? 4 : 8),
//                   ),
//                   child: Center(
//                     child: Text(
//                       widget.title,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: _isFocused 
//                             ? Colors.white 
//                             : (widget.isSelected ? Colors.black87 : Colors.black87),
//                         fontSize: _isFocused ? 13 : 11,
//                         fontWeight: _isFocused || widget.isSelected ? FontWeight.w900 : FontWeight.w700,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PlanExpiredScreen extends StatefulWidget {
//   final String apiMessage;

//   const PlanExpiredScreen({Key? key, required this.apiMessage}) : super(key: key);

//   @override
//   _PlanExpiredScreenState createState() => _PlanExpiredScreenState();
// }

// class _PlanExpiredScreenState extends State<PlanExpiredScreen> {
//   bool _isLoading = false;
  
//   final FocusNode _refreshFocus = FocusNode();
//   final FocusNode _exitFocus = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(_refreshFocus);
//     });
//   }

//   @override
//   void dispose() {
//     _refreshFocus.dispose();
//     _exitFocus.dispose();
//     super.dispose();
//   }

//   Future<void> _checkSubscriptionStatus() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);

//     final String? authKey = SessionManager.authKey;
//     if (authKey == null || authKey.isEmpty) {
//       setState(() => _isLoading = false);
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
//       ).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final res = json.decode(response.body);
//         final String expireValue = res['plan_expired'].toString().toLowerCase();
//         bool planExpired = (expireValue == 'true' || expireValue == '1');

//         if (!planExpired) {
//           if (mounted) {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => MyHome()),
//               (route) => false,
//             );
//           }
//         } else {
//           _showRechargeAlert("Your plan is still expired. Please recharge to continue enjoying our services!");
//         }
//       } else {
//         _showRechargeAlert("Server error. Please try again later.");
//       }
//     } catch (e) {
//       _showRechargeAlert("Network error. Please check your internet connection.");
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _showRechargeAlert(String message) {
//     if (!mounted) return;
    
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
//             const SizedBox(width: 15),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.redAccent.shade700,
//         duration: const Duration(seconds: 4),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: EdgeInsets.only(
//           bottom: MediaQuery.of(context).size.height * 0.1, 
//           left: MediaQuery.of(context).size.width * 0.2, 
//           right: MediaQuery.of(context).size.width * 0.2
//         ),
//         elevation: 10,
//       ),
//     );
//   }

//   void _exitApp() {
//     if (Platform.isAndroid) {
//       SystemNavigator.pop();
//     } else {
//       exit(0);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sw = MediaQuery.of(context).size.width;
//     final sh = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: const Color(0xFF1E1E1E), 
//       body: Center(
//         child: Container(
//           width: sw * 0.6,
//           padding: const EdgeInsets.all(40),
//           decoration: BoxDecoration(
//             color: const Color(0xFF2C2C2C),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.5),
//                 blurRadius: 20,
//                 spreadRadius: 5,
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.error_outline_rounded, size: 80, color: Colors.redAccent),
//               const SizedBox(height: 20),
              
//               const Text(
//                 "Subscription Expired",
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 15),
              
//               Text(
//                 widget.apiMessage.isNotEmpty 
//                     ? widget.apiMessage 
//                     : "Your plan has expired. Please recharge your account to resume watching.",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   color: Colors.white70,
//                 ),
//               ),
//               const SizedBox(height: 40),

//               if (_isLoading)
//                 const CircularProgressIndicator(color: Colors.blueAccent)
//               else
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildTVButton(
//                       label: "EXIT",
//                       icon: Icons.exit_to_app_rounded,
//                       focusNode: _exitFocus,
//                       onTap: _exitApp,
//                       defaultColor: Colors.grey.shade800,
//                       focusedColor: Colors.redAccent,
//                     ),
                    
//                     const SizedBox(width: 30),
                    
//                     _buildTVButton(
//                       label: "REFRESH STATUS",
//                       icon: Icons.refresh_rounded,
//                       focusNode: _refreshFocus,
//                       onTap: _checkSubscriptionStatus,
//                       defaultColor: Colors.grey.shade800,
//                       focusedColor: Colors.blueAccent,
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTVButton({
//     required String label,
//     required IconData icon,
//     required FocusNode focusNode,
//     required VoidCallback onTap,
//     required Color defaultColor,
//     required Color focusedColor,
//   }) {
//     return StatefulBuilder(
//       builder: (context, setState) {
//         return Focus(
//           focusNode: focusNode,
//           onFocusChange: (hasFocus) => setState(() {}),
//           onKey: (node, event) {
//             if (event is RawKeyDownEvent && 
//                (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
//               onTap();
//               return KeyEventResult.handled;
//             }
//             return KeyEventResult.ignored;
//           },
//           child: GestureDetector(
//             onTap: onTap,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//               decoration: BoxDecoration(
//                 color: focusNode.hasFocus ? focusedColor : defaultColor,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: focusNode.hasFocus ? Colors.white : Colors.transparent,
//                   width: 2,
//                 ),
//                 boxShadow: focusNode.hasFocus
//                     ? [BoxShadow(color: focusedColor.withOpacity(0.6), blurRadius: 15, spreadRadius: 2)]
//                     : [],
//               ),
//               child: Row(
//                 children: [
//                   Icon(icon, color: Colors.white, size: 24),
//                   const SizedBox(width: 10),
//                   Text(
//                     label,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }
//     );
//   }
// }

// class TvActionButton extends StatefulWidget {
//   final String label;
//   final IconData icon;
//   final Color baseColor;
//   final VoidCallback onPressed;
//   final bool autoFocus;

//   const TvActionButton({
//     Key? key,
//     required this.label,
//     required this.icon,
//     required this.baseColor,
//     required this.onPressed,
//     this.autoFocus = false,
//   }) : super(key: key);

//   @override
//   State<TvActionButton> createState() => _TvActionButtonState();
// }

// class _TvActionButtonState extends State<TvActionButton> {
//   bool _isFocused = false;

//   @override
//   Widget build(BuildContext context) {
//     return Transform.scale(
//       scale: _isFocused ? 1.05 : 1.0, 
//       child: Focus(
//         autofocus: widget.autoFocus,
//         onFocusChange: (hasFocus) {
//           setState(() {
//             _isFocused = hasFocus;
//           });
//         },
//         onKey: (node, event) {
//           if (event is RawKeyDownEvent) {
//             if (event.logicalKey == LogicalKeyboardKey.enter || 
//                 event.logicalKey == LogicalKeyboardKey.select ||
//                 event.logicalKey == LogicalKeyboardKey.numpadEnter) {
              
//               widget.onPressed();
//               return KeyEventResult.handled;
//             }
//           }
//           return KeyEventResult.ignored;
//         },
//         child: ElevatedButton.icon(
//           focusNode: null, 
//           icon: Icon(
//             widget.icon, 
//             color: Colors.white,
//             size: _isFocused ? 28 : 24,
//           ),
//           label: Text(
//             widget.label,
//             style: TextStyle(
//               fontSize: _isFocused ? 20 : 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: widget.baseColor,
//             padding: const EdgeInsets.symmetric(vertical: 15),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: _isFocused 
//                   ? const BorderSide(color: Colors.white, width: 3) 
//                   : BorderSide.none,
//             ),
//             elevation: _isFocused ? 12 : 6,
//             shadowColor: _isFocused ? Colors.white.withOpacity(0.4) : widget.baseColor,
//           ),
//           onPressed: widget.onPressed,
//         ),
//       ),
//     );
//   }
// }






// import 'dart:convert';
// import 'dart:io'; 
// import 'package:http/http.dart' as https; 
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/live_kids_screen/live_kids_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/live_sports_screen/live_sports_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sd_movies_screen/sd_movies_screen.dart';
// import 'dart:math' as math; 
// import 'package:qr_flutter/qr_flutter.dart'; 
// import 'package:shared_preferences/shared_preferences.dart'; // ✅ ADDED SHARED PREFERENCES IMPORT

// // ✅ IMPORT EXIT & EXPIRED SCREENS
// import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// // Agar neeche error aaye toh is import ko comment kar dena kyunki class yahi neeche likhi hai
// // import 'package:mobi_tv_entertainment/plan_expired_screen.dart';

// // ✅ PAGES IMPORTS
// import 'package:mobi_tv_entertainment/components/home_screen_pages/above_18/above_eighteen.dart'; 
// import 'package:mobi_tv_entertainment/components/home_screen_pages/banner_slider_screen/banner_slider_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/kids_shows/kids_channels.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/movies_screen/movies.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_live_screen/live_channel_language_screen.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/manage_tv_shows.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show_pak/tv_show_pak.dart';
// import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/manage_webseries.dart';
// import 'package:mobi_tv_entertainment/components/menu/top_navigation_bar.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/main.dart'; 
// import 'package:provider/provider.dart';
// import 'dart:ui'; 


// // ✅ 1. ADD THIS CUSTOM NOTIFICATION CLASS AT THE TOP
// class PlanUpdateNotification extends Notification {
//   final int daysLeft;
//   final bool isExpired;
//   final String message;

//   PlanUpdateNotification({
//     required this.daysLeft,
//     required this.isExpired,
//     required this.message,
//   });
// }


// class MainDashboardScreen extends StatefulWidget {
//   const MainDashboardScreen({Key? key}) : super(key: key);

//   @override
//   _MainDashboardScreenState createState() => _MainDashboardScreenState();
// }

// class _MainDashboardScreenState extends State<MainDashboardScreen> with AutomaticKeepAliveClientMixin , WidgetsBindingObserver {
  
//   @override
//   bool get wantKeepAlive => true;

//   bool _isLoading = true;
//   bool _isPlanExpired = false;

//   // ✅ VARIABLES FOR EXPIRY BANNER
//   bool _isPlanExpiring = false;
//   int _daysLeft = 0;

//   bool _showContentNetwork = false;
//   bool _showMovies = false;
//   bool _showSdMovies = false;
//   bool _showWebseries = false;
//   bool _showTvShows = false;
//   bool _showTvShowsPak = false;
//   bool _showSports = false;
//   bool _showReligious = false;
//   bool _showKids = false;
//   bool _show18Plus = false;

//   // ✅ VARIABLES FOR HELP POPUP
//   bool _showHelp = false;
//   String _whatsappUrl = "";
//   String _telegramUrl = "";
//   String _loginPin = ""; // ✅ VARIABLE TO STORE LOGIN PIN

//   List<String> _menuItems = [];
//   List<String> _pageIdentifiers = [];
//   late List<FocusNode> _menuFocusNodes = [];
//   DateTime _lastSidebarKeyTime = DateTime.now();

//   int _selectedIndex = 0; 
//   int _focusedIndex = 0;  
//   int _topNavSelectedIndex = 0; 
//   final FocusNode _bannerFocusNode = FocusNode();
  
//   late ScrollController _sidebarScrollController;

//   String _serverPin = "";
//   String _apiMessage = "";

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this); 
//     _sidebarScrollController = ScrollController();
//     _initializeDashboard();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this); 
//     _sidebarScrollController.dispose();
//     for (var node in _menuFocusNodes) node.dispose();
//     _bannerFocusNode.dispose();
//     super.dispose();
//   }


//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
    
//     // ✅ TRIGGER WHEN APP COMES BACK FROM BACKGROUND / HOME BUTTON
//     if (state == AppLifecycleState.resumed) {
//       print("App Resumed: Re-checking Plan Status...");
      
//       // Call your API check silently
//       _checkPlanStatus().then((_) {
//         if (_isPlanExpired && mounted) {
//           setState(() {}); 
//         }
//       });
//     }
//   }

//   Future<void> _initializeDashboard() async {
//     // ✅ FETCH LOGIN PIN FROM SHARED PREFERENCES
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _loginPin = prefs.getString('user_pin') ?? "Not Set";

//     await _checkPlanStatus();

//     if (!mounted) return;

//     if (_isPlanExpired) {
//       setState(() {
//         _isLoading = false; 
//       });
//       return; 
//     }

//     await _check18PlusStatus();
//     await _fetchHelplines(); 
//     _buildDynamicMenu();

//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _setupDashboardController();
        
//         if (_menuFocusNodes.isNotEmpty) {
//           setState(() {
//             _focusedIndex = 0;
//             _selectedIndex = 0;
//           });
//         }

//         if (_menuFocusNodes.isNotEmpty) {
//           FocusScope.of(context).requestFocus(_menuFocusNodes[0]);
//           context.read<FocusProvider>().updateLastFocusedIdentifier('activeSidebar');
//         }
//       });
//     }
//   }

//   // ✅ FETCH HELPLINES API IMPLEMENTATION
//   Future<void> _fetchHelplines() async {
//     try {
//       final url = Uri.parse(SessionManager.baseUrl + 'get-helplines');
//       final response = await https.get(
//         url,
//         headers: {
//           "auth-key": SessionManager.authKey ?? "",
//           "domain": SessionManager.savedDomain ?? "",
//         },
//       );

//       if (response.statusCode == 200) {
//         final res = json.decode(response.body);
//         if (res['data'] != null) {
//           final data = res['data'];
//           if (data['status'] == 1 || data['status'] == true) {
//             if (mounted) {
//               setState(() {
//                 _showHelp = true;
//                 _whatsappUrl = data['whatsapp_url'] ?? "";
//                 _telegramUrl = data['telegram_url'] ?? "";
//               });
//             }
//           }
//         }
//       }
//     } catch (e) {
//       print("Error fetching helplines: $e");
//     }
//   }

//   void _loadCachedMenuSettings() {
//     try {
//       String? cachedData = SessionManager.getSavedDomainContent();
//       if (cachedData != null && cachedData.isNotEmpty) {
//         Map<String, dynamic> domainContent = json.decode(cachedData);
//         setState(() {
//           _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//           _showMovies = (domainContent['movies'] ?? 0) == 1;
//           _showSdMovies = (domainContent['sd_movies'] ?? 0) == 1;
//           _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//           _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//           _showKids = (domainContent['kids_show'] ?? 0) == 1;
//         });
//         _buildDynamicMenu();
//       }
//     } catch (e) {
//       print("Error loading cached settings: $e");
//     }
//   }

//   Future<void> _checkPlanStatus() async {
//     final String? authKey = SessionManager.authKey;

//     if (authKey == null || authKey.isEmpty) {
//       _loadCachedMenuSettings(); 
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

//         final String expireValue = res['plan_expired'].toString().toLowerCase();
//         bool planExpired = (expireValue == 'true' || expireValue == '1');

//         final int daysLeft = res['days'] ?? 99;
//         _daysLeft = daysLeft;
//         bool planWillExpire = (daysLeft <= 3);

//         _apiMessage = res['message'] ?? 'Status Unknown';
//         final domainContent = res['domain_content'];

//         if (planExpired) {
//           _isPlanExpired = true; 
//           return; 
//         }

//         if (domainContent != null && domainContent is Map) {
//           SessionManager.saveDomainContent(json.encode(domainContent));

//           setState(() {
//             _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
//             _showMovies = (domainContent['movies'] ?? 0) == 1;
//             _showSdMovies = (domainContent['sd_movies'] ?? 0) == 1;
//             _showWebseries = (domainContent['webseries'] ?? 0) == 1;
//             _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
//             _showKids = (domainContent['kids_show'] ?? 0) == 1;
//           });
//           _buildDynamicMenu();
//         }

//         if (planWillExpire) {
//           setState(() {
//             _isPlanExpiring = true;
//           });
//         }
//       } else {
//         _loadCachedMenuSettings();
//       }
//     } catch (e) {
//       print("Error fetching Plan Status: $e");
//       _loadCachedMenuSettings();
//     }
//   }

//   Future<void> _check18PlusStatus() async {
//     try {
//       final url = Uri.parse(SessionManager.baseUrl + 'showabove18');
//       final headers = {
//         "auth-key": SessionManager.authKey,
//         "domain": SessionManager.savedDomain,
//       };
//       final response = await https.get(url, headers: headers);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == true && mounted) {
//           setState(() {
//             _show18Plus = true;
//             _serverPin = data['above18_pin'].toString();
//           });
//         }
//       }
//     } catch (e) {
//       print("Error fetching 18+ status: $e");
//     }
//   }

//   void _buildDynamicMenu() {
//     setState(() { 
//       // ✅ USE TEMP LISTS TO PREVENT UI GLITCHES
//       List<String> tempMenuItems = [];
//       List<String> tempPageIdentifiers = [];

//       tempMenuItems.add('LIVE TV');
//       tempPageIdentifiers.add('liveChannelLanguage');
//       tempMenuItems.add('LIVE SPORTS');
//       tempPageIdentifiers.add('liveSports');
//       tempMenuItems.add('LIVE KIDS');
//       tempPageIdentifiers.add('liveKids');

//       if (_showContentNetwork) { tempMenuItems.add('OTT APPS'); tempPageIdentifiers.add('subVod'); }
//       if (_showMovies) { tempMenuItems.add('LATEST 4K MOVIES'); tempPageIdentifiers.add('manageMovies'); }
//       if (_showSdMovies) { tempMenuItems.add('LATEST SD MOVIES'); tempPageIdentifiers.add('manageSdMovies'); }
//       if (_showWebseries) { tempMenuItems.add('WEB SERIES'); tempPageIdentifiers.add('manageWebseries'); }
//       if (_showTvShows) { tempMenuItems.add('TV SHOWS'); tempPageIdentifiers.add('tvShows'); }
//       if (_showKids) { tempMenuItems.add('KIDS ZONE'); tempPageIdentifiers.add('kids_show'); }
      
//       if (_show18Plus) { 
//         tempMenuItems.add('18+'); 
//         tempPageIdentifiers.add('eighteenPlus'); 
//       }

//       // ✅ ADD HELP BUTTON AT THE END
//       if (_showHelp) {
//         tempMenuItems.add('HELP');
//         tempPageIdentifiers.add('helpPopup');
//       }

//       _menuItems = tempMenuItems;
//       _pageIdentifiers = tempPageIdentifiers;

//       // ✅ FIX: DO NOT DESTROY FOCUS NODES IF MENU SIZE IS SAME
//       if (_menuFocusNodes.length != _menuItems.length) {
//         for (var node in _menuFocusNodes) {
//           node.dispose();
//         }
//         _menuFocusNodes = List.generate(_menuItems.length, (index) => FocusNode());
//       }
//     });
//   }

//   void _setupDashboardController() {
//     final fp = context.read<FocusProvider>();
    
//     if (_menuFocusNodes.isNotEmpty) {
//       fp.registerFocusNode('activeSidebar', _menuFocusNodes[_selectedIndex]);
//     }

//     fp.onDashboardNextPage = () {
//       int maxContentIndex = _menuItems.length - 1;
//       if (_menuItems.contains('18+') && !_menuItems.contains('HELP')) {
//         maxContentIndex = _menuItems.length - 2;
//       } else if (_menuItems.contains('18+') && _menuItems.contains('HELP')) {
//         maxContentIndex = _menuItems.length - 3;
//       } else if (!_menuItems.contains('18+') && _menuItems.contains('HELP')) {
//         maxContentIndex = _menuItems.length - 2;
//       }

//       if (_selectedIndex < maxContentIndex) {
//         _changePageAndFocus(_selectedIndex + 1);
//       }
//     };

//     fp.onDashboardPrevPage = () {
//       if (_selectedIndex > 0) {
//         _changePageAndFocus(_selectedIndex - 1);
//       } else {
//         fp.requestFocus('watchNow'); 
//       }
//     };

//     fp.onBannerDown = () {
//       if (_pageIdentifiers.isNotEmpty) {
//         fp.requestFocus(_pageIdentifiers[_selectedIndex]);
//       }
//     };
//   }

//   void _changePageAndFocus(int newIndex) {
//     if (newIndex < 0 || newIndex >= _menuItems.length) return;

//     final targetId = _pageIdentifiers[newIndex];
    
//     setState(() {
//       _selectedIndex = newIndex;
//       _focusedIndex = newIndex; 
//     });

//     final fp = context.read<FocusProvider>();
//     fp.registerFocusNode('activeSidebar', _menuFocusNodes[newIndex]);
//     fp.updateLastFocusedIdentifier(targetId); 

//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         fp.requestFocus(targetId);
//       }
//     });
//   }

//   void _showPinDialog() {
//     final TextEditingController _pinController = TextEditingController();
//     final FocusNode _inputFocus = FocusNode();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF2A2D3A),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: const Text("Enter 18+ PIN", style: TextStyle(color: Colors.white)),
//           content: TextField(
//             controller: _pinController,
//             focusNode: _inputFocus,
//             autofocus: true,
//             obscureText: true,
//             keyboardType: TextInputType.number,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               hintText: "Enter PIN",
//               hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
//               enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
//               focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
//             ),
//             onSubmitted: (_) => _validatePin(_pinController.text),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
//             ),
//             TextButton(
//               onPressed: () => _validatePin(_pinController.text),
//               child: const Text("Enter", style: TextStyle(color: Colors.blueAccent)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _validatePin(String inputPin) {
//     if (inputPin == _serverPin) {
//       Navigator.pop(context); 
      
//       setState(() {
//         int adultIndex = _pageIdentifiers.indexOf('eighteenPlus');
//         if (adultIndex != -1) {
//           _selectedIndex = adultIndex;
//           _focusedIndex = adultIndex;
          
//           context.read<FocusProvider>().updateLastFocusedIdentifier('eighteenPlus');
//         }
//       });
      
//       Future.delayed(const Duration(milliseconds: 200), () {
//         if (mounted) context.read<FocusProvider>().requestFocus('eighteenPlus');
//       });

//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Invalid PIN"), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
//       );
//     }
//   }

//   // ✅ FLAG TO PREVENT DOUBLE CLICKS
//   bool _isHelpPopupOpen = false;

//   // ✅ HELP POPUP DIALOG WITH ALWAYS VISIBLE LOGIN PIN
//   void _showHelpPopup() {
//     if (_isHelpPopupOpen) return; 
//     _isHelpPopupOpen = true;

//     showDialog(
//       context: context,
//       barrierDismissible: true, 
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: const Color(0xFF2A2D3A),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: const Text(
//             "Scan for Support", 
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22), 
//             textAlign: TextAlign.center
//           ),
//           content: SizedBox(
//             width: 500, 
//             height: 280, 
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // ✅ REAL LOGIN PIN FETCHED FROM SHARED PREFERENCES
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 25.0),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.black45,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.amberAccent.withOpacity(0.5), width: 1),
//                     ),
//                     child: Text(
//                       "CURRENT PIN: $_loginPin",
//                       style: const TextStyle(
//                         color: Colors.amberAccent,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 22,
//                         letterSpacing: 2.0,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     if (_whatsappUrl.isNotEmpty)
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("WhatsApp", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
//                           const SizedBox(height: 15),
//                           Container(
//                             padding: const EdgeInsets.all(5),
//                             color: Colors.white,
//                             child: QrImageView(
//                               data: _whatsappUrl,
//                               version: QrVersions.auto,
//                               size: 130.0,
//                             ),
//                           ),
//                         ],
//                       ),
//                     if (_telegramUrl.isNotEmpty)
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("Paypal", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 18)),
//                           const SizedBox(height: 15),
//                           Container(
//                             padding: const EdgeInsets.all(5),
//                             color: Colors.white,
//                             child: QrImageView(
//                               data: _telegramUrl,
//                               version: QrVersions.auto,
//                               size: 130.0,
//                             ),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           actionsAlignment: MainAxisAlignment.center,
//           actions: [
//             StatefulBuilder(
//               builder: (context, setBtnState) {
//                 return Focus(
//                   autofocus: true, 
//                   onFocusChange: (hasFocus) {
//                     setBtnState(() {}); 
//                   },
//                   onKey: (node, event) {
//                     if (event is RawKeyDownEvent && 
//                        (event.logicalKey == LogicalKeyboardKey.enter || 
//                         event.logicalKey == LogicalKeyboardKey.select)) {
//                       Navigator.pop(context);
//                       return KeyEventResult.handled;
//                     }
//                     return KeyEventResult.ignored;
//                   },
//                   child: Builder(
//                     builder: (focusContext) {
//                       bool isFocused = Focus.of(focusContext).hasFocus;
                      
//                       return AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         transform: Matrix4.identity()..scale(isFocused ? 1.1 : 1.0), 
//                         transformAlignment: Alignment.center,
//                         padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
//                         decoration: BoxDecoration(
//                           color: isFocused ? Colors.white : Colors.redAccent, 
//                           borderRadius: BorderRadius.circular(8),
//                           boxShadow: isFocused 
//                               ? [const BoxShadow(color: Colors.white54, blurRadius: 15, spreadRadius: 2)] 
//                               : [], 
//                         ),
//                         child: Text(
//                           "Close", 
//                           style: TextStyle(
//                             color: isFocused ? Colors.redAccent : Colors.white, 
//                             fontWeight: FontWeight.w900, 
//                             fontSize: isFocused ? 18 : 16
//                           )
//                         ),
//                       );
//                     }
//                   ),
//                 );
//               }
//             ),
//           ],
//         );
//       },
//     ).then((_) {
//       _isHelpPopupOpen = false;
      
//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted) {
//           int helpIndex = _menuItems.indexOf('HELP');
//           if (helpIndex != -1) {
//             setState(() {
//               _focusedIndex = helpIndex; 
//             });
//             _menuFocusNodes[helpIndex].requestFocus();
//             context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[helpIndex]);
//           }
//         }
//       });
//     });
//   }


//   Widget _getDynamicBottomContent() {
//     if (_pageIdentifiers.isEmpty || _selectedIndex >= _pageIdentifiers.length) return const SizedBox.shrink();
    
//     String currentId = _pageIdentifiers[_selectedIndex];
    
//     switch (currentId) {
//       case 'liveChannelLanguage': return const LiveChannelLanguageScreen();
//       case 'liveSports': return const LiveSportsScreen();
//       case 'liveKids': return const LiveKidsScreen();
//       case 'subVod': return const HorzontalVod();
//       case 'manageMovies': return const MoviesScreen();
//       case 'manageSdMovies': return const SdMoviesScreen();
//       case 'manageWebseries': return const ManageWebSeries();
//       case 'tvShows': return const ManageTvShows();
//       case 'sports': return const ManageSports();
//       case 'kids_show': return const ManageKidsShows();
//       case 'eighteenPlus': return const AdultMoviesScreen();
//       case 'helpPopup': return const Center(child: Icon(Icons.support_agent_rounded, color: Colors.white24, size: 120));
//       default: return const SizedBox.shrink();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     if (_isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
//       );
//     }

//     if (_isPlanExpired) {
//       return PlanExpiredScreen(apiMessage: _apiMessage);
//     }

//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (!didPop) {
//           final fp = context.read<FocusProvider>();
//           if (fp.lastFocusedIdentifier != 'activeSidebar') {
//             fp.requestFocus('activeSidebar');
//             return; 
//           }

//           Navigator.of(context).push(
//             PageRouteBuilder(
//               opaque: false,
//               pageBuilder: (context, _, __) => const ExitConfirmationScreen(
//                 isFromBackButton: true,
//               ),
//             ),
//           );
//         }
//       },
//       child: NotificationListener<PlanUpdateNotification>(
//         onNotification: (notification) {
//           if (notification.isExpired) {
//             setState(() {
//               _isPlanExpired = true;
//               _apiMessage = notification.message;
//             });
//           } else {
//             setState(() {
//               _isPlanExpiring = notification.daysLeft <= 3;
//               _daysLeft = notification.daysLeft;
//             });
//           }
//           return true;
//         },
//       child: Scaffold(
//         backgroundColor: Colors.black, 
//         body: Stack(
//           children: [
//             Positioned.fill(
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: screenHeight * 0.65, 
//                     width: screenWidth, 
//                     child: BannerSlider(
//                       focusNode: _bannerFocusNode,
//                       isPlanExpiring: _isPlanExpiring,
//                       daysLeft: _daysLeft,             
//                     ),
//                   ),

//                   Expanded(
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child: Container(
//                         key: ValueKey<String>(_pageIdentifiers[_selectedIndex]),
//                         width: screenWidth, 
//                         child: _getDynamicBottomContent(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Positioned(
//               left: 0,
//               top: 0, 
//               bottom: 0,
//               child: ClipRRect(
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
//                   child: Container(
//                     width: screenWidth * 0.14,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.40), 
//                       border: Border(
//                         right: BorderSide(
//                           color: Colors.white.withOpacity(0.2), 
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: ListView.builder(
//                       controller: _sidebarScrollController, 
//                       clipBehavior: Clip.none, 
//                       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.40),
//                       itemCount: _menuItems.length,
//                       itemBuilder: (context, index) {
//                         return AnimatedSidebarItem(
//                           title: _menuItems[index],
//                           focusNode: _menuFocusNodes[index],
//                           isSelected: _selectedIndex == index,
//                           is18PlusItem: _menuItems[index] == '18+',
//                           onTap: () {
//                             if (_menuItems[index] == '18+') {
//                               _showPinDialog();
//                               return;
//                             }
//                             if (_menuItems[index] == 'HELP') {
//                               setState(() {
//                                 _selectedIndex = index;
//                                 _focusedIndex = index;
//                               });
//                               _showHelpPopup();
//                               return;
//                             }
//                             setState(() {
//                               _selectedIndex = index;
//                               _focusedIndex = index;
//                               context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                             });
//                             Future.delayed(const Duration(milliseconds: 100), () {
//                               if (mounted) context.read<FocusProvider>().requestFocus(_pageIdentifiers[index]);
//                             });
//                           },
//                           onFocusChange: (hasFocus) {
//                             if (hasFocus) {
//                               setState(() {
//                                 _focusedIndex = index; 
//                                 context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
//                               });
//                             } else {
//                               setState(() {}); 
//                             }
//                           },
//                           onKey: (node, event) {
//                             if (event is RawKeyDownEvent) {
//                               if (event.logicalKey == LogicalKeyboardKey.arrowUp || 
//                                   event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                
//                                 final now = DateTime.now();
//                                 if (now.difference(_lastSidebarKeyTime).inMilliseconds < 350) {
//                                    return KeyEventResult.handled; 
//                                 }
//                                 _lastSidebarKeyTime = now; 

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                                   if (index < _menuItems.length - 1) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index + 1]);
//                                   }
//                                   return KeyEventResult.handled;
//                                 }

//                                 if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                                   if (index > 0) {
//                                     FocusScope.of(context).requestFocus(_menuFocusNodes[index - 1]);
//                                   } else {
//                                     context.read<FocusProvider>().requestFocus('topNavigation');
//                                   }
//                                   return KeyEventResult.handled;
//                                 }
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.enter ||
//                                   event.logicalKey == LogicalKeyboardKey.select) {
                                 
//                                  if (_menuItems[index] == '18+') {
//                                    _checkPlanStatus();
//                                    _showPinDialog();
//                                    return KeyEventResult.handled;
//                                  }
                                 
//                                  if (_menuItems[index] == 'HELP') {
//                                    setState(() {
//                                      _selectedIndex = index;
//                                      _focusedIndex = index;
//                                    });
//                                    _showHelpPopup();
//                                    return KeyEventResult.handled;
//                                  }

//                                  _checkPlanStatus(); 

//                                  final fp = context.read<FocusProvider>();
//                                  final targetId = _pageIdentifiers[index];

//                                  fp.updateLastFocusedIdentifier(targetId);

//                                  setState(() {
//                                    _selectedIndex = index; 
//                                    _focusedIndex = index;  
//                                  });

//                                  return KeyEventResult.handled;
//                               }

//                               if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                                 if (_menuItems[index] == '18+') {
//                                   if (_selectedIndex != index) {
//                                     _showPinDialog();
//                                     return KeyEventResult.handled;
//                                   }
//                                   context.read<FocusProvider>().requestFocus('eighteenPlus'); 
//                                   return KeyEventResult.handled;
//                                 }
//                                 if (_menuItems[index] == 'HELP') {
//                                    return KeyEventResult.handled; 
//                                 }

//                                  setState(() {
//                                    _selectedIndex = index;
//                                    _focusedIndex = index;
//                                  });

//                                  context.read<FocusProvider>().requestFocus(_pageIdentifiers[_selectedIndex]);
//                                  return KeyEventResult.handled;
//                               }
//                             }
//                             return KeyEventResult.ignored;
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: SizedBox(
//                 height: screenHeight * 0.24, 
//                 child: TopNavigationBar(
//                   selectedPage: _topNavSelectedIndex,
//                   tvenableAll: true,
//                   onPageSelected: (index) {
//                     setState(() => _topNavSelectedIndex = index);
//                   }
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ));
//   }
// }

// class AnimatedSidebarItem extends StatefulWidget {
//   final String title;
//   final FocusNode focusNode;
//   final bool isSelected;
//   final bool is18PlusItem;
//   final VoidCallback onTap;
//   final ValueChanged<bool> onFocusChange; 
//   final FocusOnKeyCallback onKey;          

//   const AnimatedSidebarItem({
//     Key? key,
//     required this.title,
//     required this.focusNode,
//     required this.isSelected,
//     required this.is18PlusItem,
//     required this.onTap,
//     required this.onFocusChange,
//     required this.onKey,
//   }) : super(key: key);

//   @override
//   _AnimatedSidebarItemState createState() => _AnimatedSidebarItemState();
// }

// class _AnimatedSidebarItemState extends State<AnimatedSidebarItem> with SingleTickerProviderStateMixin {
//   late AnimationController _borderAnimationController;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _borderAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 2500),
//       vsync: this,
//     );
//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (mounted) {
//       setState(() {
//         _isFocused = widget.focusNode.hasFocus;
//       });
//       if (_isFocused) {
//         _borderAnimationController.repeat();
        
//         Future.delayed(const Duration(milliseconds: 50), () {
//           if (mounted) {
//             Scrollable.ensureVisible(
//               context,
//               alignment: 0.5, 
//               duration: const Duration(milliseconds: 350), 
//               curve: Curves.easeOutCubic, 
//             );
//           }
//         });

//       } else {
//         _borderAnimationController.stop();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _borderAnimationController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       focusNode: widget.focusNode,
//       onFocusChange: widget.onFocusChange,
//       onKey: widget.onKey,
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: Container(
//           height: 48, 
//           margin: const EdgeInsets.only(left: 25, right: 10, top: 3, bottom: 3), 
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: _isFocused
//                 ? [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))]
//                 : [],
//           ),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               if (_isFocused)
//                 AnimatedBuilder(
//                   animation: _borderAnimationController,
//                   builder: (context, child) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         gradient: SweepGradient(
//                           colors: [
//                             Colors.white.withOpacity(0.1),
//                             Colors.white,
//                             Colors.white,
//                             Colors.white.withOpacity(0.1),
//                           ],
//                           stops: const [0.0, 0.25, 0.5, 1.0],
//                           transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
//                         ),
//                       ),
//                     );
//                   },
//                 ),

//               Padding(
//                 padding: EdgeInsets.all(_isFocused ? 5.0 : 0.0), 
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: _isFocused 
//                         ? Colors.black 
//                         : (widget.isSelected ? Colors.black.withOpacity(0.15) : Colors.transparent),
//                     borderRadius: BorderRadius.circular(_isFocused ? 4 : 8),
//                   ),
//                   child: Center(
//                     child: Text(
//                       widget.title,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: _isFocused 
//                             ? Colors.white 
//                             : (widget.isSelected ? Colors.black87 : Colors.black87),
//                         fontSize: _isFocused ? 13 : 11,
//                         fontWeight: _isFocused || widget.isSelected ? FontWeight.w900 : FontWeight.w700,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PlanExpiredScreen extends StatefulWidget {
//   final String apiMessage;

//   const PlanExpiredScreen({Key? key, required this.apiMessage}) : super(key: key);

//   @override
//   _PlanExpiredScreenState createState() => _PlanExpiredScreenState();
// }

// class _PlanExpiredScreenState extends State<PlanExpiredScreen> {
//   bool _isLoading = false;
  
//   final FocusNode _refreshFocus = FocusNode();
//   final FocusNode _exitFocus = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(_refreshFocus);
//     });
//   }

//   @override
//   void dispose() {
//     _refreshFocus.dispose();
//     _exitFocus.dispose();
//     super.dispose();
//   }

//   Future<void> _checkSubscriptionStatus() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);

//     final String? authKey = SessionManager.authKey;
//     if (authKey == null || authKey.isEmpty) {
//       setState(() => _isLoading = false);
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
//       ).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final res = json.decode(response.body);
//         final String expireValue = res['plan_expired'].toString().toLowerCase();
//         bool planExpired = (expireValue == 'true' || expireValue == '1');

//         if (!planExpired) {
//           if (mounted) {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => MyHome()),
//               (route) => false,
//             );
//           }
//         } else {
//           _showRechargeAlert("Your plan is still expired. Please recharge to continue enjoying our services!");
//         }
//       } else {
//         _showRechargeAlert("Server error. Please try again later.");
//       }
//     } catch (e) {
//       _showRechargeAlert("Network error. Please check your internet connection.");
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _showRechargeAlert(String message) {
//     if (!mounted) return;
    
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
//             const SizedBox(width: 15),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.redAccent.shade700,
//         duration: const Duration(seconds: 4),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: EdgeInsets.only(
//           bottom: MediaQuery.of(context).size.height * 0.1, 
//           left: MediaQuery.of(context).size.width * 0.2, 
//           right: MediaQuery.of(context).size.width * 0.2
//         ),
//         elevation: 10,
//       ),
//     );
//   }

//   void _exitApp() {
//     if (Platform.isAndroid) {
//       SystemNavigator.pop();
//     } else {
//       exit(0);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sw = MediaQuery.of(context).size.width;
//     final sh = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: const Color(0xFF1E1E1E), 
//       body: Center(
//         child: Container(
//           width: sw * 0.6,
//           padding: const EdgeInsets.all(40),
//           decoration: BoxDecoration(
//             color: const Color(0xFF2C2C2C),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.5),
//                 blurRadius: 20,
//                 spreadRadius: 5,
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.error_outline_rounded, size: 80, color: Colors.redAccent),
//               const SizedBox(height: 20),
              
//               const Text(
//                 "Subscription Expired",
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 15),
              
//               Text(
//                 widget.apiMessage.isNotEmpty 
//                     ? widget.apiMessage 
//                     : "Your plan has expired. Please recharge your account to resume watching.",
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   color: Colors.white70,
//                 ),
//               ),
//               const SizedBox(height: 40),

//               if (_isLoading)
//                 const CircularProgressIndicator(color: Colors.blueAccent)
//               else
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildTVButton(
//                       label: "EXIT",
//                       icon: Icons.exit_to_app_rounded,
//                       focusNode: _exitFocus,
//                       onTap: _exitApp,
//                       defaultColor: Colors.grey.shade800,
//                       focusedColor: Colors.redAccent,
//                     ),
                    
//                     const SizedBox(width: 30),
                    
//                     _buildTVButton(
//                       label: "REFRESH STATUS",
//                       icon: Icons.refresh_rounded,
//                       focusNode: _refreshFocus,
//                       onTap: _checkSubscriptionStatus,
//                       defaultColor: Colors.grey.shade800,
//                       focusedColor: Colors.blueAccent,
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTVButton({
//     required String label,
//     required IconData icon,
//     required FocusNode focusNode,
//     required VoidCallback onTap,
//     required Color defaultColor,
//     required Color focusedColor,
//   }) {
//     return StatefulBuilder(
//       builder: (context, setState) {
//         return Focus(
//           focusNode: focusNode,
//           onFocusChange: (hasFocus) => setState(() {}),
//           onKey: (node, event) {
//             if (event is RawKeyDownEvent && 
//                (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
//               onTap();
//               return KeyEventResult.handled;
//             }
//             return KeyEventResult.ignored;
//           },
//           child: GestureDetector(
//             onTap: onTap,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//               decoration: BoxDecoration(
//                 color: focusNode.hasFocus ? focusedColor : defaultColor,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: focusNode.hasFocus ? Colors.white : Colors.transparent,
//                   width: 2,
//                 ),
//                 boxShadow: focusNode.hasFocus
//                     ? [BoxShadow(color: focusedColor.withOpacity(0.6), blurRadius: 15, spreadRadius: 2)]
//                     : [],
//               ),
//               child: Row(
//                 children: [
//                   Icon(icon, color: Colors.white, size: 24),
//                   const SizedBox(width: 10),
//                   Text(
//                     label,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }
//     );
//   }
// }

// class TvActionButton extends StatefulWidget {
//   final String label;
//   final IconData icon;
//   final Color baseColor;
//   final VoidCallback onPressed;
//   final bool autoFocus;

//   const TvActionButton({
//     Key? key,
//     required this.label,
//     required this.icon,
//     required this.baseColor,
//     required this.onPressed,
//     this.autoFocus = false,
//   }) : super(key: key);

//   @override
//   State<TvActionButton> createState() => _TvActionButtonState();
// }

// class _TvActionButtonState extends State<TvActionButton> {
//   bool _isFocused = false;

//   @override
//   Widget build(BuildContext context) {
//     return Transform.scale(
//       scale: _isFocused ? 1.05 : 1.0, 
//       child: Focus(
//         autofocus: widget.autoFocus,
//         onFocusChange: (hasFocus) {
//           setState(() {
//             _isFocused = hasFocus;
//           });
//         },
//         onKey: (node, event) {
//           if (event is RawKeyDownEvent) {
//             if (event.logicalKey == LogicalKeyboardKey.enter || 
//                 event.logicalKey == LogicalKeyboardKey.select ||
//                 event.logicalKey == LogicalKeyboardKey.numpadEnter) {
              
//               widget.onPressed();
//               return KeyEventResult.handled;
//             }
//           }
//           return KeyEventResult.ignored;
//         },
//         child: ElevatedButton.icon(
//           focusNode: null, 
//           icon: Icon(
//             widget.icon, 
//             color: Colors.white,
//             size: _isFocused ? 28 : 24,
//           ),
//           label: Text(
//             widget.label,
//             style: TextStyle(
//               fontSize: _isFocused ? 20 : 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: widget.baseColor,
//             padding: const EdgeInsets.symmetric(vertical: 15),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: _isFocused 
//                   ? const BorderSide(color: Colors.white, width: 3) 
//                   : BorderSide.none,
//             ),
//             elevation: _isFocused ? 12 : 6,
//             shadowColor: _isFocused ? Colors.white.withOpacity(0.4) : widget.baseColor,
//           ),
//           onPressed: widget.onPressed,
//         ),
//       ),
//     );
//   }
// }






import 'dart:convert';
import 'dart:io'; 
import 'package:http/http.dart' as https; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/live_kids_screen/live_kids_screen.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/live_sports_screen/live_sports_screen.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/sd_movies_screen/sd_movies_screen.dart';
import 'dart:math' as math; 
import 'package:qr_flutter/qr_flutter.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; // ✅ ADDED SHARED PREFERENCES IMPORT

// ✅ IMPORT EXIT & EXPIRED SCREENS
import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
// Agar neeche error aaye toh is import ko comment kar dena kyunki class yahi neeche likhi hai
// import 'package:mobi_tv_entertainment/plan_expired_screen.dart';

// ✅ PAGES IMPORTS
import 'package:mobi_tv_entertainment/components/home_screen_pages/above_18/above_eighteen.dart'; 
import 'package:mobi_tv_entertainment/components/home_screen_pages/banner_slider_screen/banner_slider_screen.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/kids_shows/kids_channels.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/movies_screen/movies.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/religious_channel/religious_channel.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/sports_category/sports_category.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_live_screen/live_channel_language_screen.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_vod_screen/horzontal_vod.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show/manage_tv_shows.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/tv_show_pak/tv_show_pak.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/webseries_screen/manage_webseries.dart';
import 'package:mobi_tv_entertainment/components/menu/top_navigation_bar.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/main.dart'; 
import 'package:provider/provider.dart';
import 'dart:ui'; 

// ✅ 1. ADD THIS CUSTOM NOTIFICATION CLASS AT THE TOP
class PlanUpdateNotification extends Notification {
  final int daysLeft;
  final bool isExpired;
  final String message;

  PlanUpdateNotification({
    required this.daysLeft,
    required this.isExpired,
    required this.message,
  });
}

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({Key? key}) : super(key: key);

  @override
  _MainDashboardScreenState createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> with AutomaticKeepAliveClientMixin , WidgetsBindingObserver {
  
  @override
  bool get wantKeepAlive => true;

  bool _isLoading = true;
  bool _isPlanExpired = false;

  // ✅ VARIABLES FOR EXPIRY BANNER
  bool _isPlanExpiring = false;
  int _daysLeft = 0;

  bool _showContentNetwork = false;
  bool _showMovies = false;
  bool _showSdMovies = false;
  bool _showWebseries = false;
  bool _showTvShows = false;
  bool _showTvShowsPak = false;
  bool _showSports = false;
  bool _showReligious = false;
  bool _showKids = false;
  bool _show18Plus = false;

  // ✅ VARIABLES FOR HELP
  bool _showHelp = false;
  String _whatsappUrl = "";
  String _telegramUrl = "";
  String _loginPin = ""; // ✅ VARIABLE TO STORE LOGIN PIN

  List<String> _menuItems = [];
  List<String> _pageIdentifiers = [];
  late List<FocusNode> _menuFocusNodes = [];
  DateTime _lastSidebarKeyTime = DateTime.now();

  int _selectedIndex = 0; 
  int _focusedIndex = 0;  
  int _topNavSelectedIndex = 0; 
  final FocusNode _bannerFocusNode = FocusNode();
  
  // ✅ FOCUS NODE FOR FIXED HELP BUTTON
  final FocusNode _helpFocusNode = FocusNode();
  
  late ScrollController _sidebarScrollController;

  String _serverPin = "";
  String _apiMessage = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); 
    _sidebarScrollController = ScrollController();
    _initializeDashboard();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); 
    _sidebarScrollController.dispose();
    for (var node in _menuFocusNodes) node.dispose();
    _bannerFocusNode.dispose();
    _helpFocusNode.dispose(); // ✅ ADDED THIS
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // ✅ TRIGGER WHEN APP COMES BACK FROM BACKGROUND / HOME BUTTON
    if (state == AppLifecycleState.resumed) {
      print("App Resumed: Re-checking Plan Status...");
      
      // Call your API check silently
      _checkPlanStatus().then((_) {
        if (_isPlanExpired && mounted) {
          setState(() {}); 
        }
      });
    }
  }

  Future<void> _initializeDashboard() async {
    // ✅ FETCH LOGIN PIN FROM SHARED PREFERENCES
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _loginPin = prefs.getString('user_pin') ?? "Not Set";

    await _checkPlanStatus();

    if (!mounted) return;

    if (_isPlanExpired) {
      setState(() {
        _isLoading = false; 
      });
      return; 
    }

    await _check18PlusStatus();
    await _fetchHelplines(); 
    _buildDynamicMenu();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setupDashboardController();
        
        if (_menuFocusNodes.isNotEmpty) {
          setState(() {
            _focusedIndex = 0;
            _selectedIndex = 0;
          });
        }

        if (_menuFocusNodes.isNotEmpty) {
          FocusScope.of(context).requestFocus(_menuFocusNodes[0]);
          context.read<FocusProvider>().updateLastFocusedIdentifier('activeSidebar');
        }
      });
    }
  }

  // ✅ FETCH HELPLINES API IMPLEMENTATION
  Future<void> _fetchHelplines() async {
    try {
      final url = Uri.parse(SessionManager.baseUrl + 'get-helplines');
      final response = await https.get(
        url,
        headers: {
          "auth-key": SessionManager.authKey ?? "",
          "domain": SessionManager.savedDomain ?? "",
        },
      );

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        if (res['data'] != null) {
          final data = res['data'];
          if (data['status'] == 1 || data['status'] == true) {
            if (mounted) {
              setState(() {
                // _showHelp = true;
                _showHelp = false;
                _whatsappUrl = data['whatsapp_url'] ?? "";
                _telegramUrl = data['telegram_url'] ?? "";
              });
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching helplines: $e");
    }
  }

  void _loadCachedMenuSettings() {
    try {
      String? cachedData = SessionManager.getSavedDomainContent();
      if (cachedData != null && cachedData.isNotEmpty) {
        Map<String, dynamic> domainContent = json.decode(cachedData);
        setState(() {
          _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
          _showMovies = (domainContent['movies'] ?? 0) == 1;
          _showSdMovies = (domainContent['sd_movies'] ?? 0) == 1;
          _showWebseries = (domainContent['webseries'] ?? 0) == 1;
          _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
          _showKids = (domainContent['kids_show'] ?? 0) == 1;
        });
        _buildDynamicMenu();
      }
    } catch (e) {
      print("Error loading cached settings: $e");
    }
  }

  Future<void> _checkPlanStatus() async {
    final String? authKey = SessionManager.authKey;

    if (authKey == null || authKey.isEmpty) {
      _loadCachedMenuSettings(); 
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      var url = Uri.parse(SessionManager.baseUrl + 'checkExpiryPlan');
      final response = await https.get(
        url,
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain': SessionManager.savedDomain,
        },
      ).timeout(const Duration(seconds: 20));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final res = json.decode(response.body);

        final String expireValue = res['plan_expired'].toString().toLowerCase();
        bool planExpired = (expireValue == 'true' || expireValue == '1');

        final int daysLeft = res['days'] ?? 99;
        _daysLeft = daysLeft;
        bool planWillExpire = (daysLeft <= 3);

        _apiMessage = res['message'] ?? 'Status Unknown';
        final domainContent = res['domain_content'];

        if (planExpired) {
          _isPlanExpired = true; 
          return; 
        }

        if (domainContent != null && domainContent is Map) {
          SessionManager.saveDomainContent(json.encode(domainContent));

          setState(() {
            _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
            _showMovies = (domainContent['movies'] ?? 0) == 1;
            _showSdMovies = (domainContent['sd_movies'] ?? 0) == 1;
            _showWebseries = (domainContent['webseries'] ?? 0) == 1;
            _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
            _showKids = (domainContent['kids_show'] ?? 0) == 1;
          });
          _buildDynamicMenu();
        }

        if (planWillExpire) {
          setState(() {
            _isPlanExpiring = true;
          });
        }
      } else {
        _loadCachedMenuSettings();
      }
    } catch (e) {
      print("Error fetching Plan Status: $e");
      _loadCachedMenuSettings();
    }
  }

  Future<void> _check18PlusStatus() async {
    try {
      final url = Uri.parse(SessionManager.baseUrl + 'showabove18');
      final headers = {
        "auth-key": SessionManager.authKey,
        "domain": SessionManager.savedDomain,
      };
      final response = await https.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && mounted) {
          setState(() {
            _show18Plus = true;
            _serverPin = data['above18_pin'].toString();
          });
        }
      }
    } catch (e) {
      print("Error fetching 18+ status: $e");
    }
  }

  void _buildDynamicMenu() {
    setState(() { 
      // ✅ USE TEMP LISTS TO PREVENT UI GLITCHES
      List<String> tempMenuItems = [];
      List<String> tempPageIdentifiers = [];

      tempMenuItems.add('LIVE TV');
      tempPageIdentifiers.add('liveChannelLanguage');
      tempMenuItems.add('LIVE SPORTS');
      tempPageIdentifiers.add('liveSports');
      tempMenuItems.add('LIVE KIDS');
      tempPageIdentifiers.add('liveKids');

      if (_showContentNetwork) { tempMenuItems.add('OTT APPS'); tempPageIdentifiers.add('subVod'); }
      if (_showMovies) { tempMenuItems.add('LATEST 4K MOVIES'); tempPageIdentifiers.add('manageMovies'); }
      if (_showSdMovies) { tempMenuItems.add('LATEST SD MOVIES'); tempPageIdentifiers.add('manageSdMovies'); }
      if (_showWebseries) { tempMenuItems.add('WEB SERIES'); tempPageIdentifiers.add('manageWebseries'); }
      if (_showTvShows) { tempMenuItems.add('TV SHOWS'); tempPageIdentifiers.add('tvShows'); }
      if (_showKids) { tempMenuItems.add('KIDS ZONE'); tempPageIdentifiers.add('kids_show'); }
      
      if (_show18Plus) { 
        tempMenuItems.add('18+'); 
        tempPageIdentifiers.add('eighteenPlus'); 
      }

      // ✅ REMOVED HELP FROM DYNAMIC LIST

      _menuItems = tempMenuItems;
      _pageIdentifiers = tempPageIdentifiers;

      // ✅ FIX: DO NOT DESTROY FOCUS NODES IF MENU SIZE IS SAME
      if (_menuFocusNodes.length != _menuItems.length) {
        for (var node in _menuFocusNodes) {
          node.dispose();
        }
        _menuFocusNodes = List.generate(_menuItems.length, (index) => FocusNode());
      }
    });
  }

  void _setupDashboardController() {
    final fp = context.read<FocusProvider>();
    
    if (_menuFocusNodes.isNotEmpty) {
      fp.registerFocusNode('activeSidebar', _menuFocusNodes[_selectedIndex]);
    }

    fp.onDashboardNextPage = () {
      int maxContentIndex = _menuItems.length - 1;
      
      // ✅ SIMPLIFIED: Only check for 18+ since HELP is gone
      if (_menuItems.contains('18+')) {
        maxContentIndex = _menuItems.length - 2;
      }

      if (_selectedIndex < maxContentIndex) {
        _changePageAndFocus(_selectedIndex + 1);
      }
    };

    fp.onDashboardPrevPage = () {
      if (_selectedIndex > 0) {
        _changePageAndFocus(_selectedIndex - 1);
      } else {
        fp.requestFocus('watchNow'); 
      }
    };

    fp.onBannerDown = () {
      if (_pageIdentifiers.isNotEmpty) {
        fp.requestFocus(_pageIdentifiers[_selectedIndex]);
      }
    };
  }

  void _changePageAndFocus(int newIndex) {
    if (newIndex < 0 || newIndex >= _menuItems.length) return;

    final targetId = _pageIdentifiers[newIndex];
    
    setState(() {
      _selectedIndex = newIndex;
      _focusedIndex = newIndex; 
    });

    final fp = context.read<FocusProvider>();
    fp.registerFocusNode('activeSidebar', _menuFocusNodes[newIndex]);
    fp.updateLastFocusedIdentifier(targetId); 

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        fp.requestFocus(targetId);
      }
    });
  }

  void _showPinDialog() {
    final TextEditingController _pinController = TextEditingController();
    final FocusNode _inputFocus = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2D3A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Enter 18+ PIN", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _pinController,
            focusNode: _inputFocus,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter PIN",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
            ),
            onSubmitted: (_) => _validatePin(_pinController.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () => _validatePin(_pinController.text),
              child: const Text("Enter", style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  void _validatePin(String inputPin) {
    if (inputPin == _serverPin) {
      Navigator.pop(context); 
      
      setState(() {
        int adultIndex = _pageIdentifiers.indexOf('eighteenPlus');
        if (adultIndex != -1) {
          _selectedIndex = adultIndex;
          _focusedIndex = adultIndex;
          
          context.read<FocusProvider>().updateLastFocusedIdentifier('eighteenPlus');
        }
      });
      
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) context.read<FocusProvider>().requestFocus('eighteenPlus');
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid PIN"), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
    }
  }

  // ✅ NEW METHOD TO NAVIGATE TO SEPARATE HELP SCREEN
  void _navigateToHelpScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpSupportScreen(
          loginPin: _loginPin,
          whatsappUrl: _whatsappUrl,
          telegramUrl: _telegramUrl,
        ),
      ),
    ).then((_) {
      // ✅ Restore focus to the Help button when returning from the new page
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _helpFocusNode.requestFocus();
          context.read<FocusProvider>().registerFocusNode('activeSidebar', _helpFocusNode);
        }
      });
    });
  }

  Widget _getDynamicBottomContent() {
    if (_pageIdentifiers.isEmpty || _selectedIndex >= _pageIdentifiers.length) return const SizedBox.shrink();
    
    String currentId = _pageIdentifiers[_selectedIndex];
    
    switch (currentId) {
      case 'liveChannelLanguage': return const LiveChannelLanguageScreen();
      case 'liveSports': return const LiveSportsScreen();
      case 'liveKids': return const LiveKidsScreen();
      case 'subVod': return const HorzontalVod();
      case 'manageMovies': return const MoviesScreen();
      case 'manageSdMovies': return const SdMoviesScreen();
      case 'manageWebseries': return const ManageWebSeries();
      case 'tvShows': return const ManageTvShows();
      case 'sports': return const ManageSports();
      case 'kids_show': return const ManageKidsShows();
      case 'eighteenPlus': return const AdultMoviesScreen();
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      );
    }

    if (_isPlanExpired) {
      return PlanExpiredScreen(apiMessage: _apiMessage);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          final fp = context.read<FocusProvider>();
          if (fp.lastFocusedIdentifier != 'activeSidebar') {
            fp.requestFocus('activeSidebar');
            return; 
          }

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
      child: NotificationListener<PlanUpdateNotification>(
        onNotification: (notification) {
          if (notification.isExpired) {
            setState(() {
              _isPlanExpired = true;
              _apiMessage = notification.message;
            });
          } else {
            setState(() {
              _isPlanExpiring = notification.daysLeft <= 3;
              _daysLeft = notification.daysLeft;
            });
          }
          return true;
        },
      child: Scaffold(
        backgroundColor: Colors.black, 
        body: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.65, 
                    width: screenWidth, 
                    child: BannerSlider(
                      focusNode: _bannerFocusNode,
                      isPlanExpiring: _isPlanExpiring,
                      daysLeft: _daysLeft,             
                    ),
                  ),

                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey<String>(_pageIdentifiers[_selectedIndex]),
                        width: screenWidth, 
                        child: _getDynamicBottomContent(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 0,
              top: 0, 
              bottom: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
                  child: Container(
                    width: screenWidth * 0.14,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.40), 
                      border: Border(
                        right: BorderSide(
                          color: Colors.white.withOpacity(0.2), 
                          width: 1,
                        ),
                      ),
                    ),
                    // ✅ MODIFIED SIDEBAR WITH FIXED HELP AT BOTTOM
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _sidebarScrollController, 
                            clipBehavior: Clip.none, 
                            padding: EdgeInsets.only(top: screenHeight * 0.40, bottom: 20),
                            itemCount: _menuItems.length,
                            itemBuilder: (context, index) {
                              return AnimatedSidebarItem(
                                title: _menuItems[index],
                                focusNode: _menuFocusNodes[index],
                                isSelected: _selectedIndex == index,
                                is18PlusItem: _menuItems[index] == '18+',
                                onTap: () {
                                  if (_menuItems[index] == '18+') {
                                    _showPinDialog();
                                    return;
                                  }
                                  setState(() {
                                    _selectedIndex = index;
                                    _focusedIndex = index;
                                    context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
                                  });
                                  Future.delayed(const Duration(milliseconds: 100), () {
                                    if (mounted) context.read<FocusProvider>().requestFocus(_pageIdentifiers[index]);
                                  });
                                },
                                onFocusChange: (hasFocus) {
                                  if (hasFocus) {
                                    setState(() {
                                      _focusedIndex = index; 
                                      context.read<FocusProvider>().registerFocusNode('activeSidebar', _menuFocusNodes[index]);
                                    });
                                  } else {
                                    setState(() {}); 
                                  }
                                },
                                onKey: (node, event) {
                                  if (event is RawKeyDownEvent) {
                                    if (event.logicalKey == LogicalKeyboardKey.arrowUp || 
                                        event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                      
                                      final now = DateTime.now();
                                      if (now.difference(_lastSidebarKeyTime).inMilliseconds < 350) {
                                         return KeyEventResult.handled; 
                                      }
                                      _lastSidebarKeyTime = now; 

                                      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                        if (index < _menuItems.length - 1) {
                                          FocusScope.of(context).requestFocus(_menuFocusNodes[index + 1]);
                                        } else if (_showHelp) {
                                          // ✅ JUMP TO FIXED HELP BUTTON
                                          FocusScope.of(context).requestFocus(_helpFocusNode);
                                        }
                                        return KeyEventResult.handled;
                                      }

                                      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                        if (index > 0) {
                                          FocusScope.of(context).requestFocus(_menuFocusNodes[index - 1]);
                                        } else {
                                          context.read<FocusProvider>().requestFocus('topNavigation');
                                        }
                                        return KeyEventResult.handled;
                                      }
                                    }

                                    if (event.logicalKey == LogicalKeyboardKey.enter ||
                                        event.logicalKey == LogicalKeyboardKey.select) {
                                       
                                       if (_menuItems[index] == '18+') {
                                         _checkPlanStatus();
                                         _showPinDialog();
                                         return KeyEventResult.handled;
                                       }
                                       
                                       _checkPlanStatus(); 

                                       final fp = context.read<FocusProvider>();
                                       final targetId = _pageIdentifiers[index];

                                       fp.updateLastFocusedIdentifier(targetId);

                                       setState(() {
                                         _selectedIndex = index; 
                                         _focusedIndex = index;  
                                       });

                                       return KeyEventResult.handled;
                                    }

                                    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                                      if (_menuItems[index] == '18+') {
                                        if (_selectedIndex != index) {
                                          _showPinDialog();
                                          return KeyEventResult.handled;
                                        }
                                        context.read<FocusProvider>().requestFocus('eighteenPlus'); 
                                        return KeyEventResult.handled;
                                      }

                                      setState(() {
                                        _selectedIndex = index;
                                        _focusedIndex = index;
                                      });

                                      context.read<FocusProvider>().requestFocus(_pageIdentifiers[_selectedIndex]);
                                      return KeyEventResult.handled;
                                    }
                                  }
                                  return KeyEventResult.ignored;
                                },
                              );
                            },
                          ),
                        ),
                        
                        // ✅ FIXED HELP BUTTON AT BOTTOM
                        if (_showHelp)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: AnimatedSidebarItem(
                              title: 'HELP',
                              focusNode: _helpFocusNode,
                              isSelected: false, 
                              is18PlusItem: false,
                              onTap: () => _navigateToHelpScreen(),
                              onFocusChange: (hasFocus) {
                                if (hasFocus) {
                                  context.read<FocusProvider>().registerFocusNode('activeSidebar', _helpFocusNode);
                                  setState(() {}); 
                                }
                              },
                              onKey: (node, event) {
                                if (event is RawKeyDownEvent) {
                                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                    // ✅ GO BACK UP TO THE LAST MENU ITEM
                                    if (_menuFocusNodes.isNotEmpty) {
                                      FocusScope.of(context).requestFocus(_menuFocusNodes.last);
                                    }
                                    return KeyEventResult.handled;
                                  }
                                  if (event.logicalKey == LogicalKeyboardKey.enter || 
                                      event.logicalKey == LogicalKeyboardKey.select) {
                                    _navigateToHelpScreen();
                                    return KeyEventResult.handled;
                                  }
                                  if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                                    context.read<FocusProvider>().requestFocus(_pageIdentifiers[_selectedIndex]);
                                    return KeyEventResult.handled;
                                  }
                                  if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                    return KeyEventResult.handled; // Block going further down
                                  }
                                }
                                return KeyEventResult.ignored;
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: screenHeight * 0.24, 
                child: TopNavigationBar(
                  selectedPage: _topNavSelectedIndex,
                  tvenableAll: true,
                  onPageSelected: (index) {
                    setState(() => _topNavSelectedIndex = index);
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class AnimatedSidebarItem extends StatefulWidget {
  final String title;
  final FocusNode focusNode;
  final bool isSelected;
  final bool is18PlusItem;
  final VoidCallback onTap;
  final ValueChanged<bool> onFocusChange; 
  final FocusOnKeyCallback onKey;          

  const AnimatedSidebarItem({
    Key? key,
    required this.title,
    required this.focusNode,
    required this.isSelected,
    required this.is18PlusItem,
    required this.onTap,
    required this.onFocusChange,
    required this.onKey,
  }) : super(key: key);

  @override
  _AnimatedSidebarItemState createState() => _AnimatedSidebarItemState();
}

class _AnimatedSidebarItemState extends State<AnimatedSidebarItem> with SingleTickerProviderStateMixin {
  late AnimationController _borderAnimationController;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _borderAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
      if (_isFocused) {
        _borderAnimationController.repeat();
        
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            Scrollable.ensureVisible(
              context,
              alignment: 0.5, 
              duration: const Duration(milliseconds: 350), 
              curve: Curves.easeOutCubic, 
            );
          }
        });

      } else {
        _borderAnimationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _borderAnimationController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: widget.onFocusChange,
      onKey: widget.onKey,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 48, 
          margin: const EdgeInsets.only(left: 25, right: 10, top: 3, bottom: 3), 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isFocused
                ? [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))]
                : [],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_isFocused)
                AnimatedBuilder(
                  animation: _borderAnimationController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: SweepGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white,
                            Colors.white,
                            Colors.white.withOpacity(0.1),
                          ],
                          stops: const [0.0, 0.25, 0.5, 1.0],
                          transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
                        ),
                      ),
                    );
                  },
                ),

              Padding(
                padding: EdgeInsets.all(_isFocused ? 5.0 : 0.0), 
                child: Container(
                  decoration: BoxDecoration(
                    color: _isFocused 
                        ? Colors.black 
                        : (widget.isSelected ? Colors.black.withOpacity(0.15) : Colors.transparent),
                    borderRadius: BorderRadius.circular(_isFocused ? 4 : 8),
                  ),
                  child: Center(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _isFocused 
                            ? Colors.white 
                            : (widget.isSelected ? Colors.black87 : Colors.black87),
                        fontSize: _isFocused ? 13 : 11,
                        fontWeight: _isFocused || widget.isSelected ? FontWeight.w900 : FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlanExpiredScreen extends StatefulWidget {
  final String apiMessage;

  const PlanExpiredScreen({Key? key, required this.apiMessage}) : super(key: key);

  @override
  _PlanExpiredScreenState createState() => _PlanExpiredScreenState();
}

class _PlanExpiredScreenState extends State<PlanExpiredScreen> {
  bool _isLoading = false;
  
  final FocusNode _refreshFocus = FocusNode();
  final FocusNode _exitFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_refreshFocus);
    });
  }

  @override
  void dispose() {
    _refreshFocus.dispose();
    _exitFocus.dispose();
    super.dispose();
  }

  Future<void> _checkSubscriptionStatus() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final String? authKey = SessionManager.authKey;
    if (authKey == null || authKey.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      var url = Uri.parse(SessionManager.baseUrl + 'checkExpiryPlan');
      final response = await https.get(
        url,
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain': SessionManager.savedDomain,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        final String expireValue = res['plan_expired'].toString().toLowerCase();
        bool planExpired = (expireValue == 'true' || expireValue == '1');

        if (!planExpired) {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MyHome()),
              (route) => false,
            );
          }
        } else {
          _showRechargeAlert("Your plan is still expired. Please recharge to continue enjoying our services!");
        }
      } else {
        _showRechargeAlert("Server error. Please try again later.");
      }
    } catch (e) {
      _showRechargeAlert("Network error. Please check your internet connection.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRechargeAlert(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1, 
          left: MediaQuery.of(context).size.width * 0.2, 
          right: MediaQuery.of(context).size.width * 0.2
        ),
        elevation: 10,
      ),
    );
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), 
      body: Center(
        child: Container(
          width: sw * 0.6,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 80, color: Colors.redAccent),
              const SizedBox(height: 20),
              
              const Text(
                "Subscription Expired",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              
              Text(
                widget.apiMessage.isNotEmpty 
                    ? widget.apiMessage 
                    : "Your plan has expired. Please recharge your account to resume watching.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),

              if (_isLoading)
                const CircularProgressIndicator(color: Colors.blueAccent)
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTVButton(
                      label: "EXIT",
                      icon: Icons.exit_to_app_rounded,
                      focusNode: _exitFocus,
                      onTap: _exitApp,
                      defaultColor: Colors.grey.shade800,
                      focusedColor: Colors.redAccent,
                    ),
                    
                    const SizedBox(width: 30),
                    
                    _buildTVButton(
                      label: "REFRESH STATUS",
                      icon: Icons.refresh_rounded,
                      focusNode: _refreshFocus,
                      onTap: _checkSubscriptionStatus,
                      defaultColor: Colors.grey.shade800,
                      focusedColor: Colors.blueAccent,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTVButton({
    required String label,
    required IconData icon,
    required FocusNode focusNode,
    required VoidCallback onTap,
    required Color defaultColor,
    required Color focusedColor,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Focus(
          focusNode: focusNode,
          onFocusChange: (hasFocus) => setState(() {}),
          onKey: (node, event) {
            if (event is RawKeyDownEvent && 
               (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
              onTap();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: focusNode.hasFocus ? focusedColor : defaultColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: focusNode.hasFocus ? Colors.white : Colors.transparent,
                  width: 2,
                ),
                boxShadow: focusNode.hasFocus
                    ? [BoxShadow(color: focusedColor.withOpacity(0.6), blurRadius: 15, spreadRadius: 2)]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}

class TvActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color baseColor;
  final VoidCallback onPressed;
  final bool autoFocus;

  const TvActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.baseColor,
    required this.onPressed,
    this.autoFocus = false,
  }) : super(key: key);

  @override
  State<TvActionButton> createState() => _TvActionButtonState();
}

class _TvActionButtonState extends State<TvActionButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _isFocused ? 1.05 : 1.0, 
      child: Focus(
        autofocus: widget.autoFocus,
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        onKey: (node, event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter || 
                event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter) {
              
              widget.onPressed();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: ElevatedButton.icon(
          focusNode: null, 
          icon: Icon(
            widget.icon, 
            color: Colors.white,
            size: _isFocused ? 28 : 24,
          ),
          label: Text(
            widget.label,
            style: TextStyle(
              fontSize: _isFocused ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.baseColor,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: _isFocused 
                  ? const BorderSide(color: Colors.white, width: 3) 
                  : BorderSide.none,
            ),
            elevation: _isFocused ? 12 : 6,
            shadowColor: _isFocused ? Colors.white.withOpacity(0.4) : widget.baseColor,
          ),
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}

// ✅ NEW SEPARATE HELP SCREEN WITH D-PAD SUPPORT
class HelpSupportScreen extends StatefulWidget {
  final String loginPin;
  final String whatsappUrl;
  final String telegramUrl;

  const HelpSupportScreen({
    Key? key,
    required this.loginPin,
    required this.whatsappUrl,
    required this.telegramUrl,
  }) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final FocusNode _backFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _backFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _backFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: Container(
          width: 550,
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D3A),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Scan for Support",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.5), width: 1.5),
                ),
                child: Text(
                  "CURRENT PIN: ${widget.loginPin}",
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.whatsappUrl.isNotEmpty)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("WhatsApp", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.white,
                          child: QrImageView(
                            data: widget.whatsappUrl,
                            version: QrVersions.auto,
                            size: 140.0,
                          ),
                        ),
                      ],
                    ),
                  if (widget.telegramUrl.isNotEmpty)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Paypal", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.white,
                          child: QrImageView(
                            data: widget.telegramUrl,
                            version: QrVersions.auto,
                            size: 140.0,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 40),
              Focus(
                focusNode: _backFocusNode,
                onKey: (node, event) {
                  if (event is RawKeyDownEvent &&
                      (event.logicalKey == LogicalKeyboardKey.enter ||
                       event.logicalKey == LogicalKeyboardKey.select)) {
                    Navigator.pop(context);
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: Builder(
                  builder: (focusContext) {
                    bool isFocused = Focus.of(focusContext).hasFocus;
                    return GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()..scale(isFocused ? 1.05 : 1.0),
                        transformAlignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                        decoration: BoxDecoration(
                          color: isFocused ? Colors.white : Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isFocused
                              ? [const BoxShadow(color: Colors.white54, blurRadius: 15, spreadRadius: 2)]
                              : [],
                        ),
                        child: Text(
                          "Go Back",
                          style: TextStyle(
                            color: isFocused ? Colors.redAccent : Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: isFocused ? 20 : 18,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}