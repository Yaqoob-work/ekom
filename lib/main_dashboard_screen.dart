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




import 'dart:convert'; 
import 'package:http/http.dart' as https; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/live_sports_screen/live_sports_screen.dart';
import 'package:mobi_tv_entertainment/components/home_screen_pages/sd_movies_screen/sd_movies_screen.dart';
import 'dart:math' as math; 

// ✅ IMPORT EXIT & EXPIRED SCREENS
import 'package:mobi_tv_entertainment/exit_confirmation_screen.dart';
import 'package:mobi_tv_entertainment/plan_expired_screen.dart';

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

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({Key? key}) : super(key: key);

  @override
  _MainDashboardScreenState createState() => _MainDashboardScreenState();
}

// ✅ ADDED: AutomaticKeepAliveClientMixin to keep the state alive when navigating back
class _MainDashboardScreenState extends State<MainDashboardScreen> with AutomaticKeepAliveClientMixin {
  
  // ✅ ADDED: Required for AutomaticKeepAliveClientMixin
  @override
  bool get wantKeepAlive => true;

  bool _isLoading = true;
  bool _isPlanExpired = false;

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

  List<String> _menuItems = [];
  List<String> _pageIdentifiers = [];
  late List<FocusNode> _menuFocusNodes = [];
  DateTime _lastSidebarKeyTime = DateTime.now();

  int _selectedIndex = 0; 
  int _focusedIndex = 0;  
  int _topNavSelectedIndex = 0; 
  final FocusNode _bannerFocusNode = FocusNode();
  
  late ScrollController _sidebarScrollController;

  String _serverPin = "";
  String _apiMessage = "";

  @override
  void initState() {
    super.initState();
    _sidebarScrollController = ScrollController();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await _checkPlanStatus();
    if (_isPlanExpired) return;
    await _check18PlusStatus();
    _buildDynamicMenu();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setupDashboardController();
        if (_menuFocusNodes.isNotEmpty) {
          FocusScope.of(context).requestFocus(_menuFocusNodes[0]);
          
          context.read<FocusProvider>().updateLastFocusedIdentifier('activeSidebar');
          setState(() {
            _focusedIndex = 0;
            _selectedIndex = 0;
          });
        }
      });
    }
  }

  // ✅ ADDED: Function to load cached data if the API fails
  void _loadCachedMenuSettings() {
    try {
      // Make sure you add getSavedDomainContent() to your SessionManager class
      String? cachedData = SessionManager.getSavedDomainContent();
      if (cachedData != null && cachedData.isNotEmpty) {
        Map<String, dynamic> domainContent = json.decode(cachedData);
        setState(() {
          _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
          _showMovies = (domainContent['movies'] ?? 0) == 1;
          // _showSdMovies = (domainContent['sd_movies'] ?? 0) == 1;
          _showWebseries = (domainContent['webseries'] ?? 0) == 1;
          _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
          // _showTvShowsPak = (domainContent['tvshow_pak'] ?? 0) == 1;
          // _showSports = (domainContent['sports'] ?? 0) == 1;
          // _showReligious = (domainContent['religious'] ?? 0) == 1;
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
      _loadCachedMenuSettings(); // ✅ Load cache if auth key is missing
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

        final bool planExpired = (res['plan_expired'] == true ||
            res['plan_expired'] == 1 ||
            res['plan_expired'] == "1");
        final bool planWillExpire =
            (res['plan_will_expire'] == true || res['plan_will_expire'] == 1);
        _apiMessage = res['message'] ?? 'Status Unknown';
        final domainContent = res['domain_content'];

        if (planExpired) {
          _isPlanExpired = true;
          if (Navigator.canPop(context)) Navigator.pop(context);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => PlanExpiredScreen(apiMessage: _apiMessage),
            ),
            (route) => false,
          );
          return;
        }

        if (domainContent != null && domainContent is Map) {
          // ✅ ADDED: Save this successful data locally for next time
          SessionManager.saveDomainContent(json.encode(domainContent));

          setState(() {
            _showContentNetwork = (domainContent['content_network'] ?? 0) == 1;
            _showMovies = (domainContent['movies'] ?? 0) == 1;
            // _showSdMovies = (domainContent['sd_movies'] ?? 0) == 1;
            _showWebseries = (domainContent['webseries'] ?? 0) == 1;
            _showTvShows = (domainContent['tvshow'] ?? 0) == 1;
            // _showTvShowsPak = (domainContent['tvshow_pak'] ?? 0) == 1;
            // _showSports = (domainContent['sports'] ?? 0) == 1;
            // _showReligious = (domainContent['religious'] ?? 0) == 1;
            _showKids = (domainContent['kids_show'] ?? 0) == 1;
          });
          _buildDynamicMenu();
        }

        if (planWillExpire) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) _showExpiryWarningDialog(_apiMessage);
          });
        }
      } else {
        // ✅ ADDED: If API fails with non-200 code, load cached settings
        _loadCachedMenuSettings();
      }
    } catch (e) {
      print("Error fetching Plan Status: $e");
      // ✅ ADDED: If no internet or timeout, load cached settings instead of empty menu
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
      _menuItems.clear();
      _pageIdentifiers.clear();

      _menuItems.add('LIVE TV');
      _pageIdentifiers.add('liveChannelLanguage');
      _menuItems.add('LIVE SPORTS');
      _pageIdentifiers.add('liveSports');

      if (_showContentNetwork) { _menuItems.add('OTT APPS'); _pageIdentifiers.add('subVod'); }
      if (_showMovies) { _menuItems.add('LATEST 4K MOVIES'); _pageIdentifiers.add('manageMovies'); }
      // if (_showSdMovies) { _menuItems.add('LATEST SD MOVIES'); _pageIdentifiers.add('manageSdMovies'); }
      if (_showWebseries) { _menuItems.add('WEB SERIES'); _pageIdentifiers.add('manageWebseries'); }
      if (_showTvShows) { _menuItems.add('TV SHOWS'); _pageIdentifiers.add('tvShows'); }
      // if (_showTvShowsPak) { _menuItems.add('TV SHOWS PAK'); _pageIdentifiers.add('tvShowPak'); }
      // if (_showReligious) { _menuItems.add('RELIGIOUS'); _pageIdentifiers.add('religiousChannels'); }
      // if (_showSports) { _menuItems.add('SPORTS'); _pageIdentifiers.add('sports'); }
      if (_showKids) { _menuItems.add('KIDS ZONE'); _pageIdentifiers.add('kids_show'); }
      
      if (_show18Plus) { 
        _menuItems.add('18+'); 
        _pageIdentifiers.add('eighteenPlus'); 
      }

      _menuFocusNodes = List.generate(_menuItems.length, (index) => FocusNode());
    });
  }

  void _showExpiryWarningDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 48),
          title: const Text('Plan Expiry Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text('O.K', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _setupDashboardController() {
    final fp = context.read<FocusProvider>();
    
    if (_menuFocusNodes.isNotEmpty) {
      fp.registerFocusNode('activeSidebar', _menuFocusNodes[_selectedIndex]);
    }

    fp.onDashboardNextPage = () {
      int maxContentIndex = _menuItems.contains('18+') ? _menuItems.length - 2 : _menuItems.length - 1;
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

  @override
  void dispose() {
    _sidebarScrollController.dispose();
    for (var node in _menuFocusNodes) node.dispose();
    _bannerFocusNode.dispose();
    super.dispose();
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
      Navigator.pop(context); // Dialog band karein
      
      setState(() {
        // 18+ wala index dhoondein aur use select karein
        int adultIndex = _pageIdentifiers.indexOf('eighteenPlus');
        if (adultIndex != -1) {
          _selectedIndex = adultIndex;
          _focusedIndex = adultIndex;
          
          // Focus ko sidebar se hatakar content par bhejne ke liye (Optional)
          context.read<FocusProvider>().updateLastFocusedIdentifier('eighteenPlus');
        }
      });
      
      // Content screen ko request focus karein
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) context.read<FocusProvider>().requestFocus('eighteenPlus');
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid PIN"), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
    }
  }

  Widget _getDynamicBottomContent() {
    if (_pageIdentifiers.isEmpty || _selectedIndex >= _pageIdentifiers.length) return const SizedBox.shrink();
    
    String currentId = _pageIdentifiers[_selectedIndex];
    
    switch (currentId) {
      case 'liveChannelLanguage': return const LiveChannelLanguageScreen();
      case 'liveSports': return const LiveSportsScreen();
      case 'subVod': return const HorzontalVod();
      case 'manageMovies': return const MoviesScreen();
      case 'manageSdMovies': return const SdMoviesScreen();
      case 'manageWebseries': return const ManageWebSeries();
      case 'tvShows': return const ManageTvShows();
      // case 'tvShowPak': return const TvShowsPak();
      // case 'religiousChannels': return const ManageReligiousShows();
      case 'sports': return const ManageSports();
      case 'kids_show': return const ManageKidsShows();
      case 'eighteenPlus': return const AdultMoviesScreen();
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ADDED: This is required when using AutomaticKeepAliveClientMixin
    super.build(context);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      );
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
                    child: ListView.builder(
                      controller: _sidebarScrollController, 
                      clipBehavior: Clip.none, 
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.40),
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
                                   _showPinDialog();
                                   return KeyEventResult.handled;
                                 }

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
                  onPageSelected: (index) => setState(() => _topNavSelectedIndex = index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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