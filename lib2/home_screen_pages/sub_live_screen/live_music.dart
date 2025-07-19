// import 'dart:async';

// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:http/http.dart' as https;
// import 'package:provider/provider.dart';

// // Import your providers (adjust paths as needed)
// // import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// // import 'package:mobi_tv_entertainment/provider/color_provider.dart';

// // Professional Color Palette - Exact same as movies
// class ProfessionalColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentGreen = Color(0xFF10B981);
//   static const accentRed = Color(0xFFEF4444);
//   static const accentOrange = Color(0xFFF59E0B);
//   static const accentPink = Color(0xFFEC4899);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
//   static const focusGlow = Color(0xFF60A5FA);

//   static List<Color> gradientColors = [
//     accentBlue,
//     accentPurple,
//     accentGreen,
//     accentRed,
//     accentOrange,
//     accentPink,
//   ];
// }

// // Professional Animation Durations - Exact same as movies
// class AnimationTiming {
//   static const Duration ultraFast = Duration(milliseconds: 150);
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration focus = Duration(milliseconds: 300);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// class LiveMusic extends StatefulWidget {
//   final Function(bool)? onFocusChange;
//   final FocusNode focusNode;

//   const LiveMusic({Key? key, this.onFocusChange, required this.focusNode})
//       : super(key: key);

//   @override
//   _LiveMusicState createState() => _LiveMusicState();
// }

// class _LiveMusicState extends State<LiveMusic>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   // Core data
//   List<NewsChannel> newsChannelsList = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isNavigating = false;

//   // Animation Controllers
//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   // Focus management
//   Map<String, FocusNode> musicChannelFocusNodes = {};
//   FocusNode? _viewAllFocusNode;
//   Color _currentAccentColor = ProfessionalColors.accentBlue;

//   // Controllers
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _initializeViewAllFocusNode();
//     _setupFocusProvider();
//     _fetchNewsChannels();
//   }

//   void _setupFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         try {
//           final focusProvider =
//               Provider.of<FocusProvider>(context, listen: false);
//           // Set scroll controller for focus provider
//           focusProvider.setMusicChannelsScrollController(_scrollController);
//         } catch (e) {
//           print('Focus provider setup failed: $e');
//         }
//       }
//     });
//   }

//   void _initializeAnimations() {
//     _headerAnimationController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _listAnimationController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _headerSlideAnimation = Tween<Offset>(
//       begin: const Offset(0, -1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _headerAnimationController,
//       curve: Curves.easeOutCubic,
//     ));

//     _listFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _listAnimationController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   void _initializeViewAllFocusNode() {
//     _viewAllFocusNode = FocusNode()
//       ..addListener(() {
//         if (mounted && _viewAllFocusNode!.hasFocus) {
//           setState(() {
//             _currentAccentColor = ProfessionalColors.gradientColors[
//                 math.Random()
//                     .nextInt(ProfessionalColors.gradientColors.length)];
//           });
//         }
//       });
//   }

//   Future<void> _fetchNewsChannels() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = prefs.getString('auth_key') ?? '';

//       final response = await https.get(
//         Uri.parse(
//             'https://acomtv.coretechinfo.com/public/api/getFeaturedLiveTV'),
//         headers: {'auth-key': authKey},
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);

//         if (data.containsKey('Music')) {
//           final List<dynamic> newsData = data['Music'];

//           if (mounted) {
//             setState(() {
//               newsChannelsList =
//                   newsData.map((item) => NewsChannel.fromJson(item)).toList();
//               _initializeMusicChannelFocusNodes();
//               _isLoading = false;
//             });

//             // Start animations after data loads
//             _headerAnimationController.forward();
//             _listAnimationController.forward();
//           }
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _errorMessage = 'Failed to load channels (${response.statusCode})';
//             _isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Network error: Please check connection';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _initializeMusicChannelFocusNodes() {
//     // Clear existing focus nodes
//     for (var node in musicChannelFocusNodes.values) {
//       try {
//         node.removeListener(() {});
//         node.dispose();
//       } catch (e) {}
//     }
//     musicChannelFocusNodes.clear();

//     // Create focus nodes for each news channel
//     for (var channel in newsChannelsList) {
//       try {
//         String channelId = channel.id.toString();
//         musicChannelFocusNodes[channelId] = FocusNode()
//           ..addListener(() {
//             if (mounted && musicChannelFocusNodes[channelId]!.hasFocus) {
//               _scrollToFocusedItem(channelId);
//             }
//           });
//       } catch (e) {
//         // Silent error handling
//       }
//     }

//     // Register with focus provider
//     _registerMusicChannelsFocus();
//   }

//   void _registerMusicChannelsFocus() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && newsChannelsList.isNotEmpty) {
//         try {
//           final focusProvider =
//               Provider.of<FocusProvider>(context, listen: false);

//           // Register first news channel with focus provider
//           final firstChannelId = newsChannelsList[0].id.toString();
//           if (musicChannelFocusNodes.containsKey(firstChannelId)) {
//             focusProvider.setFirstMusicChannelFocusNode(
//                 musicChannelFocusNodes[firstChannelId]!);
//           }

//           // Register ViewAll focus node
//           if (_viewAllFocusNode != null) {
//             focusProvider.setMusicChannelsViewAllFocusNode(_viewAllFocusNode!);
//           }
//         } catch (e) {
//           print('Focus provider registration failed: $e');
//         }
//       }
//     });
//   }

//   void _scrollToFocusedItem(String itemId) {
//     if (!mounted) return;

//     try {
//       final focusNode = musicChannelFocusNodes[itemId];
//       if (focusNode != null &&
//           focusNode.hasFocus &&
//           focusNode.context != null) {
//         Scrollable.ensureVisible(
//           focusNode.context!,
//           alignment: 0.02,
//           duration: AnimationTiming.scroll,
//           curve: Curves.easeInOutCubic,
//         );
//       }
//     } catch (e) {}
//   }

//   List<NewsItemModel> _convertNewsChannelsToNewsItems() {
//     return newsChannelsList.map((channel) {
//       return NewsItemModel(
//         id: channel.id.toString(),
//         videoId: '',
//         name: channel.name,
//         description: channel.description ?? '',
//         banner: channel.banner,
//         poster: channel.banner, // Banner ko poster ke liye use kar sakte hain
//         category: 'news',
//         url: channel.url,
//         streamType: channel.streamType,
//         type: channel.streamType,
//         genres: channel.genres,
//         status: channel.status.toString(),
//         index: newsChannelsList.indexOf(channel).toString(),
//         image: channel.banner,
//         unUpdatedUrl: channel.url,
//       );
//     }).toList();
//   }

//   // Updated _handleChannelTap method
//   Future<void> _handleChannelTap(NewsChannel channel) async {
//     if (_isNavigating) return;
//     _isNavigating = true;

//     bool shouldPlayVideo = true;
//     bool shouldPop = true;
//     bool dialogShown = false;

//     if (mounted) {
//       dialogShown = true;
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return WillPopScope(
//             onWillPop: () async {
//               _isNavigating = false;
//               return true;
//             },
//             child: Center(
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 50,
//                       height: 50,
//                       child: const CircularProgressIndicator(
//                         strokeWidth: 3,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           ProfessionalColors.accentBlue,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Loading channel...',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     }

//     Timer(Duration(seconds: 10), () {
//       _isNavigating = false;
//     });

//     try {
//       // Current channel ko NewsItemModel में convert करें
//       NewsItemModel currentChannel = NewsItemModel(
//         id: channel.id.toString(),
//         videoId: '',
//         name: channel.name,
//         description: channel.description ?? '',
//         banner: channel.banner,
//         poster: channel.banner,
//         category: 'news',
//         url: channel.url,
//         streamType: channel.streamType,
//         type: channel.streamType,
//         genres: channel.genres,
//         status: channel.status.toString(),
//         index: newsChannelsList.indexOf(channel).toString(),
//         image: channel.banner,
//         unUpdatedUrl: channel.url,
//       );

//       // Sabhi channels ko convert करें - YE LINE IMPORTANT HAI ↓
//       List<NewsItemModel> allChannels = _convertNewsChannelsToNewsItems();

//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }

//       bool liveStatus = true;

//       if (shouldPlayVideo) {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VideoScreen(
//               videoUrl: currentChannel.url,
//               bannerImageUrl: currentChannel.banner,
//               startAtPosition: Duration.zero,
//               videoType: currentChannel.streamType,
//               channelList: allChannels, // YE WALA LINE CHANGE HAI
//               isLive: true,
//               isVOD: false,
//               isBannerSlider: false,
//               source: 'isLiveScreen',
//               isSearch: false,
//               videoId: int.tryParse(currentChannel.id),
//               unUpdatedUrl: currentChannel.url,
//               name: currentChannel.name,
//               seasonId: null,
//               isLastPlayedStored: false,
//               liveStatus: liveStatus,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (dialogShown) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Something Went Wrong')),
//       );
//     } finally {
//       _isNavigating = false;
//     }
//   }

//   // Future<void> _handleChannelTap(NewsChannel channel) async {
//   //   if (_isNavigating || !mounted) return;

//   //   _isNavigating = true;
//   //   bool dialogShown = false;

//   //   try {
//   //     if (mounted) {
//   //       dialogShown = true;
//   //       showDialog(
//   //         context: context,
//   //         barrierDismissible: false,
//   //         builder: (BuildContext context) {
//   //           return WillPopScope(
//   //             onWillPop: () async {
//   //               _isNavigating = false;
//   //               return true;
//   //             },
//   //             child: Center(
//   //               child: Container(
//   //                 padding: const EdgeInsets.all(20),
//   //                 decoration: BoxDecoration(
//   //                   color: Colors.black.withOpacity(0.8),
//   //                   borderRadius: BorderRadius.circular(15),
//   //                 ),
//   //                 child: Column(
//   //                   mainAxisSize: MainAxisSize.min,
//   //                   children: [
//   //                     Container(
//   //                       width: 50,
//   //                       height: 50,
//   //                       child: const CircularProgressIndicator(
//   //                         strokeWidth: 3,
//   //                         valueColor: AlwaysStoppedAnimation<Color>(
//   //                           ProfessionalColors.accentBlue,
//   //                         ),
//   //                       ),
//   //                     ),
//   //                     const SizedBox(height: 16),
//   //                     const Text(
//   //                       'Loading channel...',
//   //                       style: TextStyle(
//   //                         color: Colors.white,
//   //                         fontSize: 16,
//   //                         fontWeight: FontWeight.w500,
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //             ),
//   //           );
//   //         },
//   //       );
//   //     }

//   //     // Simulate loading for demo
//   //     // await Future.delayed(const Duration(seconds: 2));

//   //     if (mounted && _isNavigating) {
//   //       if (dialogShown) {
//   //         Navigator.of(context, rootNavigator: true).pop();
//   //       }

//   //        await Navigator.push(
//   //         context,
//   //         MaterialPageRoute(
//   //           builder: (context) => VideoScreen(
//   //             videoUrl: channel.url,
//   //             bannerImageUrl: channel.banner,
//   //             startAtPosition: Duration.zero,
//   //             videoType: channel.streamType,
//   //             channelList: newsChannelsList,
//   //             isLive: true,
//   //             isVOD: false,
//   //             isBannerSlider: false,
//   //             source: 'isLiveScreen',
//   //             isSearch: false,
//   //             videoId: channel.id,
//   //             unUpdatedUrl: channel.url,
//   //             name: channel.name,
//   //             seasonId: null,
//   //             isLastPlayedStored: false,
//   //             liveStatus: true,
//   //           ),
//   //         ),
//   //       );

//   //       // // Show success message
//   //       // ScaffoldMessenger.of(context).showSnackBar(
//   //       //   SnackBar(
//   //       //     content: Row(
//   //       //       children: [
//   //       //         const Icon(Icons.tv, color: Colors.white, size: 20),
//   //       //         const SizedBox(width: 8),
//   //       //         Expanded(
//   //       //           child: Text(
//   //       //             'Now playing: ${channel.name}',
//   //       //             style: const TextStyle(fontWeight: FontWeight.w500),
//   //       //           ),
//   //       //         ),
//   //       //       ],
//   //       //     ),
//   //       //     backgroundColor: ProfessionalColors.accentGreen,
//   //       //     behavior: SnackBarBehavior.floating,
//   //       //     shape: RoundedRectangleBorder(
//   //       //       borderRadius: BorderRadius.circular(10),
//   //       //     ),
//   //       //     duration: const Duration(seconds: 3),
//   //       //   ),
//   //       // );

//   //       // Here you can navigate to video player
//   //       // Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen()));
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       if (dialogShown) {
//   //         Navigator.of(context, rootNavigator: true).pop();
//   //       }
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: Text('Error: ${e.toString()}'),
//   //           backgroundColor: ProfessionalColors.accentRed,
//   //         ),
//   //       );
//   //     }
//   //   } finally {
//   //     _isNavigating = false;
//   //   }
//   // }

//   void _navigateToNewsChannelsGrid() {
//     if (!_isNavigating && mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ProfessionalNewsChannelsGridView(
//               newsChannelsList: newsChannelsList),
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();

//     for (var entry in musicChannelFocusNodes.entries) {
//       try {
//         entry.value.removeListener(() {});
//         entry.value.dispose();
//       } catch (e) {}
//     }
//     musicChannelFocusNodes.clear();

//     try {
//       _viewAllFocusNode?.removeListener(() {});
//       _viewAllFocusNode?.dispose();
//     } catch (e) {}

//     try {
//       _scrollController.dispose();
//     } catch (e) {}

//     _isNavigating = false;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Column(
//         children: [
//           SizedBox(height: screenHeight * 0.02),
//           _buildProfessionalTitle(screenWidth),
//           SizedBox(height: screenHeight * 0.01),
//           Expanded(child: _buildBody(screenWidth, screenHeight)),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     return SlideTransition(
//       position: _headerSlideAnimation,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             ShaderMask(
//               shaderCallback: (bounds) => const LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentBlue,
//                   ProfessionalColors.accentPurple,
//                 ],
//               ).createShader(bounds),
//               child: const Text(
//                 'NEWS',
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//             ),
//             if (newsChannelsList.isNotEmpty)
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue.withOpacity(0.2),
//                       ProfessionalColors.accentPurple.withOpacity(0.2),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   '${newsChannelsList.length} Channels',
//                   style: const TextStyle(
//                     color: ProfessionalColors.textSecondary,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(double screenWidth, double screenHeight) {
//     if (_isLoading) {
//       return const ProfessionalLoadingIndicator(
//           message: 'Loading News Channels...');
//     } else if (_errorMessage.isNotEmpty) {
//       return _buildErrorWidget();
//     } else if (newsChannelsList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildMusicChannelsList(screenWidth, screenHeight);
//     }
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentRed.withOpacity(0.2),
//                   ProfessionalColors.accentRed.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.error_outline_rounded,
//               size: 40,
//               color: ProfessionalColors.accentRed,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Oops! Something went wrong',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _errorMessage,
//             style: const TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _fetchNewsChannels,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: ProfessionalColors.accentBlue,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Try Again',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentBlue.withOpacity(0.2),
//                   ProfessionalColors.accentBlue.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.tv_outlined,
//               size: 40,
//               color: ProfessionalColors.accentBlue,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Something Wrong',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Check back later for new content',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMusicChannelsList(double screenWidth, double screenHeight) {
//     bool showViewAll = newsChannelsList.length > 7;

//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: Container(
//         height: screenHeight * 0.38,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.none,
//           controller: _scrollController,
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//           cacheExtent: 1200,
//           itemCount: showViewAll ? 8 : newsChannelsList.length,
//           itemBuilder: (context, index) {
//             if (showViewAll && index == 7) {
//               return Focus(
//                 focusNode: _viewAllFocusNode,
//                 onKey: (FocusNode node, RawKeyEvent event) {
//                   if (event is RawKeyDownEvent) {
//                     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowLeft) {
//                       if (newsChannelsList.isNotEmpty &&
//                           newsChannelsList.length > 6) {
//                         String channelId = newsChannelsList[6].id.toString();
//                         FocusScope.of(context)
//                             .requestFocus(musicChannelFocusNodes[channelId]);
//                         return KeyEventResult.handled;
//                       }
//                     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                       // Navigate to movies section
//                       // try {
//                       //   context.read<FocusProvider>().requestFirstMoviesFocus();
//                       // } catch (e) {
//                       //   print('Movies focus request failed: $e');
//                       // }
//                       try {
//                         context
//                             .read<FocusProvider>()
//                             .requestMusicNavigationFocus();
//                         print('🎵 Navigating to Music navigation button');
//                       } catch (e) {
//                         print('❌ Music navigation focus failed: $e');
//                         // Fallback to general middle navigation focus
//                         try {
//                           context
//                               .read<FocusProvider>()
//                               .requestMiddleNavigationFocus(2);
//                         } catch (e2) {
//                           print('❌ Fallback navigation focus failed: $e2');
//                         }
//                         return KeyEventResult.handled;
//                       }
//                     } else if (event.logicalKey ==
//                         LogicalKeyboardKey.arrowDown) {
//                       // Navigate to web series or next section
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 50), () {
//                         if (mounted) {
//                           try {
//                             context
//                                 .read<FocusProvider>()
//                                 .requestFirstSubVodFocus();
//                           } catch (e) {
//                             print('Web series focus request failed: $e');
//                           }
//                         }
//                       });
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.select) {
//                       _navigateToNewsChannelsGrid();
//                       return KeyEventResult.handled;
//                     }
//                   }
//                   return KeyEventResult.ignored;
//                 },
//                 child: GestureDetector(
//                   onTap: _navigateToNewsChannelsGrid,
//                   child: ProfessionalViewAllButton(
//                     focusNode: _viewAllFocusNode!,
//                     onTap: _navigateToNewsChannelsGrid,
//                     totalChannels: newsChannelsList.length,
//                   ),
//                 ),
//               );
//             }

//             var channel = newsChannelsList[index];
//             return _buildNewsChannelItem(
//                 channel, index, screenWidth, screenHeight);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildNewsChannelItem(
//       NewsChannel channel, int index, double screenWidth, double screenHeight) {
//     String channelId = channel.id.toString();

//     musicChannelFocusNodes.putIfAbsent(
//       channelId,
//       () => FocusNode()
//         ..addListener(() {
//           if (mounted && musicChannelFocusNodes[channelId]!.hasFocus) {
//             _scrollToFocusedItem(channelId);
//           }
//         }),
//     );

//     return Focus(
//       focusNode: musicChannelFocusNodes[channelId],
//       onFocusChange: (hasFocus) async {
//         if (hasFocus && mounted) {
//           try {
//             // Update color provider with channel theme colors
//             Color dominantColor = ProfessionalColors.gradientColors[
//                 math.Random()
//                     .nextInt(ProfessionalColors.gradientColors.length)];

//             // Update color provider
//             try {
//               context.read<ColorProvider>().updateColor(dominantColor, true);
//             } catch (e) {
//               print('Color provider update failed: $e');
//             }

//             // Notify parent widget about focus change
//             widget.onFocusChange?.call(true);
//           } catch (e) {
//             print('Focus change handling failed: $e');
//           }
//         } else if (mounted) {
//           try {
//             context.read<ColorProvider>().resetColor();
//           } catch (e) {
//             print('Color reset failed: $e');
//           }
//           widget.onFocusChange?.call(false);
//         }
//       },
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//             if (index < newsChannelsList.length - 1 && index != 6) {
//               String nextChannelId = newsChannelsList[index + 1].id.toString();
//               FocusScope.of(context)
//                   .requestFocus(musicChannelFocusNodes[nextChannelId]);
//               return KeyEventResult.handled;
//             } else if (index == 6 && newsChannelsList.length > 7) {
//               FocusScope.of(context).requestFocus(_viewAllFocusNode);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//             if (index > 0) {
//               String prevChannelId = newsChannelsList[index - 1].id.toString();
//               FocusScope.of(context)
//                   .requestFocus(musicChannelFocusNodes[prevChannelId]);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             // Navigate to movies section
//             // try {
//             //   context.read<FocusProvider>().requestMiddleNavigationFocus(2);
//             // } catch (e) {
//             //   print('Movies focus request failed: $e');
//             // }
//             try {
//               context.read<FocusProvider>().requestMusicNavigationFocus();
//               print('🎵 Navigating to Music navigation button');
//             } catch (e) {
//               print('❌ Music navigation focus failed: $e');
//               // Fallback to general middle navigation focus
//               try {
//                 context.read<FocusProvider>().requestMiddleNavigationFocus(2);
//               } catch (e2) {
//                 print('❌ Fallback navigation focus failed: $e2');
//               }
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             // Navigate to web series or next section
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 50), () {
//               if (mounted) {
//                 try {
//                   // context.read<FocusProvider>().requestFirstWebseriesFocus();
//                   context.read<FocusProvider>().requestSubVodFocus();
//                 } catch (e) {
//                   print('Web series focus request failed: $e');
//                 }
//               }
//             });
//             return KeyEventResult.ignored;
//           } else if (event.logicalKey == LogicalKeyboardKey.select) {
//             _handleChannelTap(channel);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () => _handleChannelTap(channel),
//         child: ProfessionalNewsChannelCard(
//           channel: channel,
//           focusNode: musicChannelFocusNodes[channelId]!,
//           onTap: () => _handleChannelTap(channel),
//           onColorChange: (color) {
//             setState(() {
//               _currentAccentColor = color;
//             });
//           },
//           index: index,
//         ),
//       ),
//     );
//   }
// }

// // Professional News Channel Card Widget - Same style as movie card
// class ProfessionalNewsChannelCard extends StatefulWidget {
//   final NewsChannel channel;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;

//   const ProfessionalNewsChannelCard({
//     Key? key,
//     required this.channel,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//   }) : super(key: key);

//   @override
//   _ProfessionalNewsChannelCardState createState() =>
//       _ProfessionalNewsChannelCardState();
// }

// class _ProfessionalNewsChannelCardState
//     extends State<ProfessionalNewsChannelCard> with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _glowController;
//   late AnimationController _shimmerController;

//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;
//   late Animation<double> _shimmerAnimation;

//   Color _dominantColor = ProfessionalColors.accentBlue;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();

//     _scaleController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _glowController = AnimationController(
//       duration: AnimationTiming.medium,
//       vsync: this,
//     );

//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.06,
//     ).animate(CurvedAnimation(
//       parent: _scaleController,
//       curve: Curves.easeOutCubic,
//     ));

//     _glowAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _glowController,
//       curve: Curves.easeInOut,
//     ));

//     _shimmerAnimation = Tween<double>(
//       begin: -1.0,
//       end: 2.0,
//     ).animate(CurvedAnimation(
//       parent: _shimmerController,
//       curve: Curves.easeInOut,
//     ));

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _scaleController.forward();
//       _glowController.forward();
//       _generateDominantColor();
//       widget.onColorChange(_dominantColor);
//       HapticFeedback.lightImpact();
//     } else {
//       _scaleController.reverse();
//       _glowController.reverse();
//     }
//   }

//   void _generateDominantColor() {
//     final colors = ProfessionalColors.gradientColors;
//     _dominantColor = colors[math.Random().nextInt(colors.length)];
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     _glowController.dispose();
//     _shimmerController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return AnimatedBuilder(
//       animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Container(
//             width: screenWidth * 0.19,
//             margin: const EdgeInsets.symmetric(horizontal: 6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _buildProfessionalPoster(screenWidth, screenHeight),
//                 _buildProfessionalTitle(screenWidth),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
//     final posterHeight = _isFocused ? screenHeight * 0.28 : screenHeight * 0.22;

//     return Container(
//       height: posterHeight,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           if (_isFocused) ...[
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.4),
//               blurRadius: 25,
//               spreadRadius: 3,
//               offset: const Offset(0, 8),
//             ),
//             BoxShadow(
//               color: _dominantColor.withOpacity(0.2),
//               blurRadius: 45,
//               spreadRadius: 6,
//               offset: const Offset(0, 15),
//             ),
//           ] else ...[
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 10,
//               spreadRadius: 2,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Stack(
//           children: [
//             _buildChannelImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildStatusBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildChannelImage(double screenWidth, double posterHeight) {
//     return Container(
//       width: double.infinity,
//       height: posterHeight,
//       child: widget.channel.banner.isNotEmpty
//           ? Image.network(
//               widget.channel.banner,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) =>
//                   _buildImagePlaceholder(posterHeight),
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return _buildImagePlaceholder(posterHeight);
//               },
//             )
//           : _buildImagePlaceholder(posterHeight),
//     );
//   }

//   Widget _buildImagePlaceholder(double height) {
//     return Container(
//       height: height,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalColors.cardDark,
//             ProfessionalColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.tv_outlined,
//             size: height * 0.25,
//             color: ProfessionalColors.textSecondary,
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'NEWS',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             decoration: BoxDecoration(
//               color: ProfessionalColors.accentBlue.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'LIVE',
//               style: TextStyle(
//                 color: ProfessionalColors.accentBlue,
//                 fontSize: 8,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFocusBorder() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             width: 3,
//             color: _dominantColor,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmerEffect() {
//     return AnimatedBuilder(
//       animation: _shimmerAnimation,
//       builder: (context, child) {
//         return Positioned.fill(
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               gradient: LinearGradient(
//                 begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
//                 end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
//                 colors: [
//                   Colors.transparent,
//                   _dominantColor.withOpacity(0.15),
//                   Colors.transparent,
//                 ],
//                 stops: [0.0, 0.5, 1.0],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStatusBadge() {
//     return Positioned(
//       top: 8,
//       right: 8,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//         decoration: BoxDecoration(
//           color: widget.channel.status == 1
//               ? ProfessionalColors.accentGreen.withOpacity(0.9)
//               : ProfessionalColors.accentRed.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 6,
//               height: 6,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(width: 4),
//             Text(
//               widget.channel.status == 1 ? 'LIVE' : 'OFF',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 8,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHoverOverlay() {
//     return Positioned.fill(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               _dominantColor.withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: const Icon(
//               Icons.play_arrow_rounded,
//               color: Colors.white,
//               size: 30,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     final channelName = widget.channel.name.toUpperCase();

//     return Container(
//       width: screenWidth * 0.18,
//       child: AnimatedDefaultTextStyle(
//         duration: AnimationTiming.medium,
//         style: TextStyle(
//           fontSize: _isFocused ? 13 : 11,
//           fontWeight: FontWeight.w600,
//           color: _isFocused ? _dominantColor : ProfessionalColors.textPrimary,
//           letterSpacing: 0.5,
//           shadows: _isFocused
//               ? [
//                   Shadow(
//                     color: _dominantColor.withOpacity(0.6),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Text(
//           channelName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // Professional View All Button - Same as movies
// class ProfessionalViewAllButton extends StatefulWidget {
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int totalChannels;

//   const ProfessionalViewAllButton({
//     Key? key,
//     required this.focusNode,
//     required this.onTap,
//     required this.totalChannels,
//   }) : super(key: key);

//   @override
//   _ProfessionalViewAllButtonState createState() =>
//       _ProfessionalViewAllButtonState();
// }

// class _ProfessionalViewAllButtonState extends State<ProfessionalViewAllButton>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _rotateController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _rotateAnimation;

//   bool _isFocused = false;
//   Color _currentColor = ProfessionalColors.accentBlue;

//   @override
//   void initState() {
//     super.initState();

//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     )..repeat(reverse: true);

//     _rotateController = AnimationController(
//       duration: const Duration(milliseconds: 3000),
//       vsync: this,
//     )..repeat();

//     _pulseAnimation = Tween<double>(
//       begin: 0.85,
//       end: 1.15,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));

//     _rotateAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_rotateController);

//     widget.focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     setState(() {
//       _isFocused = widget.focusNode.hasFocus;
//       if (_isFocused) {
//         _currentColor = ProfessionalColors.gradientColors[
//             math.Random().nextInt(ProfessionalColors.gradientColors.length)];
//         HapticFeedback.mediumImpact();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _rotateController.dispose();
//     widget.focusNode.removeListener(_handleFocusChange);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Container(
//       width: screenWidth * 0.19,
//       margin: const EdgeInsets.symmetric(horizontal: 6),
//       child: Column(
//         children: [
//           AnimatedBuilder(
//             animation: _isFocused ? _pulseAnimation : _rotateAnimation,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: _isFocused ? _pulseAnimation.value : 1.0,
//                 child: Transform.rotate(
//                   angle: _isFocused ? 0 : _rotateAnimation.value * 2 * math.pi,
//                   child: Container(
//                     height:
//                         _isFocused ? screenHeight * 0.28 : screenHeight * 0.22,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: _isFocused
//                             ? [
//                                 _currentColor,
//                                 _currentColor.withOpacity(0.7),
//                               ]
//                             : [
//                                 ProfessionalColors.cardDark,
//                                 ProfessionalColors.surfaceDark,
//                               ],
//                       ),
//                       boxShadow: [
//                         if (_isFocused) ...[
//                           BoxShadow(
//                             color: _currentColor.withOpacity(0.4),
//                             blurRadius: 25,
//                             spreadRadius: 3,
//                             offset: const Offset(0, 8),
//                           ),
//                         ] else ...[
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.4),
//                             blurRadius: 10,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ],
//                     ),
//                     child: _buildViewAllContent(),
//                   ),
//                 ),
//               );
//             },
//           ),
//           _buildViewAllTitle(),
//         ],
//       ),
//     );
//   }

//   Widget _buildViewAllContent() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         border: _isFocused
//             ? Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 2,
//               )
//             : null,
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.1),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.grid_view_rounded,
//                   size: _isFocused ? 45 : 35,
//                   color: Colors.white,
//                 ),
//                 Text(
//                   'VIEW ALL',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: _isFocused ? 14 : 12,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.25),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '${widget.totalChannels}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildViewAllTitle() {
//     return AnimatedDefaultTextStyle(
//       duration: AnimationTiming.medium,
//       style: TextStyle(
//         fontSize: _isFocused ? 13 : 11,
//         fontWeight: FontWeight.w600,
//         color: _isFocused ? _currentColor : ProfessionalColors.textPrimary,
//         letterSpacing: 0.5,
//         shadows: _isFocused
//             ? [
//                 Shadow(
//                   color: _currentColor.withOpacity(0.6),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ]
//             : [],
//       ),
//       child: const Text(
//         'ALL CHANNELS',
//         textAlign: TextAlign.center,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }
// }

// // Enhanced Loading Indicator - Same as movies
// class ProfessionalLoadingIndicator extends StatefulWidget {
//   final String message;

//   const ProfessionalLoadingIndicator({
//     Key? key,
//     this.message = 'Loading...',
//   }) : super(key: key);

//   @override
//   _ProfessionalLoadingIndicatorState createState() =>
//       _ProfessionalLoadingIndicatorState();
// }

// class _ProfessionalLoadingIndicatorState
//     extends State<ProfessionalLoadingIndicator> with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _animation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_controller);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _animation,
//             builder: (context, child) {
//               return Container(
//                 width: 70,
//                 height: 70,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: SweepGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple,
//                       ProfessionalColors.accentGreen,
//                       ProfessionalColors.accentBlue,
//                     ],
//                     stops: [0.0, 0.3, 0.7, 1.0],
//                     transform: GradientRotation(_animation.value * 2 * math.pi),
//                   ),
//                 ),
//                 child: Container(
//                   margin: const EdgeInsets.all(5),
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: ProfessionalColors.primaryDark,
//                   ),
//                   child: const Icon(
//                     Icons.tv_rounded,
//                     color: ProfessionalColors.textPrimary,
//                     size: 28,
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 24),
//           Text(
//             widget.message,
//             style: const TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             width: 200,
//             height: 3,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(2),
//               color: ProfessionalColors.surfaceDark,
//             ),
//             child: AnimatedBuilder(
//               animation: _animation,
//               builder: (context, child) {
//                 return LinearProgressIndicator(
//                   value: _animation.value,
//                   backgroundColor: Colors.transparent,
//                   valueColor: const AlwaysStoppedAnimation<Color>(
//                     ProfessionalColors.accentBlue,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Professional News Channels Grid View - Same as movies grid
// class ProfessionalNewsChannelsGridView extends StatefulWidget {
//   final List<NewsChannel> newsChannelsList;

//   const ProfessionalNewsChannelsGridView(
//       {Key? key, required this.newsChannelsList})
//       : super(key: key);

//   @override
//   _ProfessionalNewsChannelsGridViewState createState() =>
//       _ProfessionalNewsChannelsGridViewState();
// }

// class _ProfessionalNewsChannelsGridViewState
//     extends State<ProfessionalNewsChannelsGridView>
//     with TickerProviderStateMixin {
//   late Map<String, FocusNode> _channelFocusNodes;
//   bool _isLoading = false;

//   // Animation Controllers
//   late AnimationController _fadeController;
//   late AnimationController _staggerController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _channelFocusNodes = {
//       for (var channel in widget.newsChannelsList)
//         channel.id.toString(): FocusNode()
//     };

//     // Set up focus for the first channel
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (widget.newsChannelsList.isNotEmpty) {
//         final firstChannelId = widget.newsChannelsList[0].id.toString();
//         if (_channelFocusNodes.containsKey(firstChannelId)) {
//           FocusScope.of(context)
//               .requestFocus(_channelFocusNodes[firstChannelId]);
//         }
//       }
//     });

//     _initializeAnimations();
//     _startStaggeredAnimation();
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _staggerController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
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

//   Future<void> _handleGridChannelTap(NewsChannel channel) async {
//     if (_isLoading || !mounted) return;

//     setState(() {
//       _isLoading = true;
//     });

//     bool dialogShown = false;
//     try {
//       if (mounted) {
//         dialogShown = true;
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return WillPopScope(
//               onWillPop: () async {
//                 setState(() {
//                   _isLoading = false;
//                 });
//                 return true;
//               },
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.85),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 60,
//                         height: 60,
//                         child: const CircularProgressIndicator(
//                           strokeWidth: 4,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             ProfessionalColors.accentBlue,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'Loading Channel...',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Please wait',
//                         style: TextStyle(
//                           color: ProfessionalColors.textSecondary,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       }

//       // Current channel ko NewsItemModel में convert करें
//       NewsItemModel currentChannel = NewsItemModel(
//         id: channel.id.toString(),
//         videoId: '',
//         name: channel.name,
//         description: channel.description ?? '',
//         banner: channel.banner,
//         poster: channel.banner,
//         category: 'news',
//         url: channel.url,
//         streamType: channel.streamType,
//         type: channel.streamType,
//         genres: channel.genres,
//         status: channel.status.toString(),
//         index: widget.newsChannelsList.indexOf(channel).toString(),
//         image: channel.banner,
//         unUpdatedUrl: channel.url,
//       );

//       // Sabhi channels को convert करें
//       List<NewsItemModel> allChannels = widget.newsChannelsList.map((ch) {
//         return NewsItemModel(
//           id: ch.id.toString(),
//           videoId: '',
//           name: ch.name,
//           description: ch.description ?? '',
//           banner: ch.banner,
//           poster: ch.banner,
//           category: 'news',
//           url: ch.url,
//           streamType: ch.streamType,
//           type: ch.streamType,
//           genres: ch.genres,
//           status: ch.status.toString(),
//           index: widget.newsChannelsList.indexOf(ch).toString(),
//           image: ch.banner,
//           unUpdatedUrl: ch.url,
//         );
//       }).toList();

//       if (mounted) {
//         if (dialogShown) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }

//         // VideoScreen navigate करें with all channels
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VideoScreen(
//               videoUrl: currentChannel.url,
//               bannerImageUrl: currentChannel.banner,
//               startAtPosition: Duration.zero,
//               videoType: currentChannel.streamType,
//               channelList: allChannels, // Sabhi channels pass kar rahe hain
//               isLive: true,
//               isVOD: false,
//               isBannerSlider: false,
//               source: 'isLiveScreen',
//               isSearch: false,
//               videoId: int.tryParse(currentChannel.id),
//               unUpdatedUrl: currentChannel.url,
//               name: currentChannel.name,
//               seasonId: null,
//               isLastPlayedStored: false,
//               liveStatus: true,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         if (dialogShown) {
//           Navigator.of(context, rootNavigator: true).pop();
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Error loading channel'),
//             backgroundColor: ProfessionalColors.accentRed,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // Future<void> _handleGridChannelTap(NewsChannel channel) async {
//   //   if (_isLoading || !mounted) return;

//   //   setState(() {
//   //     _isLoading = true;
//   //   });

//   //   bool dialogShown = false;
//   //   try {
//   //     if (mounted) {
//   //       dialogShown = true;
//   //       showDialog(
//   //         context: context,
//   //         barrierDismissible: false,
//   //         builder: (BuildContext context) {
//   //           return WillPopScope(
//   //             onWillPop: () async {
//   //               setState(() {
//   //                 _isLoading = false;
//   //               });
//   //               return true;
//   //             },
//   //             child: Center(
//   //               child: Container(
//   //                 padding: const EdgeInsets.all(24),
//   //                 decoration: BoxDecoration(
//   //                   color: Colors.black.withOpacity(0.85),
//   //                   borderRadius: BorderRadius.circular(20),
//   //                   border: Border.all(
//   //                     color: ProfessionalColors.accentBlue.withOpacity(0.3),
//   //                     width: 1,
//   //                   ),
//   //                 ),
//   //                 child: Column(
//   //                   mainAxisSize: MainAxisSize.min,
//   //                   children: [
//   //                     Container(
//   //                       width: 60,
//   //                       height: 60,
//   //                       child: const CircularProgressIndicator(
//   //                         strokeWidth: 4,
//   //                         valueColor: AlwaysStoppedAnimation<Color>(
//   //                           ProfessionalColors.accentBlue,
//   //                         ),
//   //                       ),
//   //                     ),
//   //                     const SizedBox(height: 20),
//   //                     const Text(
//   //                       'Loading Channel...',
//   //                       style: TextStyle(
//   //                         color: Colors.white,
//   //                         fontSize: 18,
//   //                         fontWeight: FontWeight.w600,
//   //                       ),
//   //                     ),
//   //                     const SizedBox(height: 8),
//   //                     const Text(
//   //                       'Please wait',
//   //                       style: TextStyle(
//   //                         color: ProfessionalColors.textSecondary,
//   //                         fontSize: 14,
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //             ),
//   //           );
//   //         },
//   //       );
//   //     }

//   //     // Simulate loading
//   //     await Future.delayed(const Duration(seconds: 2));

//   //     if (mounted) {
//   //       if (dialogShown) {
//   //         Navigator.of(context, rootNavigator: true).pop();
//   //       }

//   //       // Show success message
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: Row(
//   //             children: [
//   //               const Icon(Icons.tv, color: Colors.white, size: 20),
//   //               const SizedBox(width: 8),
//   //               Expanded(
//   //                 child: Text(
//   //                   'Now playing: ${channel.name}',
//   //                   style: const TextStyle(fontWeight: FontWeight.w500),
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //           backgroundColor: ProfessionalColors.accentGreen,
//   //           behavior: SnackBarBehavior.floating,
//   //           shape: RoundedRectangleBorder(
//   //             borderRadius: BorderRadius.circular(10),
//   //           ),
//   //           duration: const Duration(seconds: 3),
//   //         ),
//   //       );

//   //       // Navigate to video player here
//   //       // Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen()));
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       if (dialogShown) {
//   //         Navigator.of(context, rootNavigator: true).pop();
//   //       }
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: const Text('Error loading channel'),
//   //           backgroundColor: ProfessionalColors.accentRed,
//   //           behavior: SnackBarBehavior.floating,
//   //           shape: RoundedRectangleBorder(
//   //             borderRadius: BorderRadius.circular(10),
//   //           ),
//   //         ),
//   //       );
//   //     }
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() {
//   //         _isLoading = false;
//   //       });
//   //     }
//   //   }
//   // }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _staggerController.dispose();
//     for (var node in _channelFocusNodes.values) {
//       try {
//         node.dispose();
//       } catch (e) {}
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Stack(
//         children: [
//           // Background Gradient
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   ProfessionalColors.primaryDark,
//                   ProfessionalColors.surfaceDark.withOpacity(0.8),
//                   ProfessionalColors.primaryDark,
//                 ],
//               ),
//             ),
//           ),

//           // Main Content
//           FadeTransition(
//             opacity: _fadeAnimation,
//             child: Column(
//               children: [
//                 _buildProfessionalAppBar(),
//                 Expanded(
//                   child: _buildChannelsGrid(),
//                 ),
//               ],
//             ),
//           ),

//           // Loading Overlay
//           if (_isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.7),
//               child: const Center(
//                 child:
//                     ProfessionalLoadingIndicator(message: 'Loading Channel...'),
//               ),
//             ),
//         ],
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
//             ProfessionalColors.surfaceDark.withOpacity(0.9),
//             ProfessionalColors.surfaceDark.withOpacity(0.7),
//             Colors.transparent,
//           ],
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentBlue.withOpacity(0.2),
//                   ProfessionalColors.accentPurple.withOpacity(0.2),
//                 ],
//               ),
//             ),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.arrow_back_rounded,
//                 color: Colors.white,
//                 size: 24,
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ShaderMask(
//                   shaderCallback: (bounds) => const LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple,
//                     ],
//                   ).createShader(bounds),
//                   child: const Text(
//                     'News',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         ProfessionalColors.accentBlue.withOpacity(0.2),
//                         ProfessionalColors.accentPurple.withOpacity(0.2),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(
//                       color: ProfessionalColors.accentBlue.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Text(
//                     '${widget.newsChannelsList.length} Channels Available',
//                     style: const TextStyle(
//                       color: ProfessionalColors.textSecondary,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChannelsGrid() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 5,
//           mainAxisSpacing: 16,
//           crossAxisSpacing: 16,
//           childAspectRatio: 1.6,
//         ),
//         itemCount: widget.newsChannelsList.length,
//         clipBehavior: Clip.none,
//         itemBuilder: (context, index) {
//           final channel = widget.newsChannelsList[index];
//           String channelId = channel.id.toString();

//           return AnimatedBuilder(
//             animation: _staggerController,
//             builder: (context, child) {
//               final delay = (index / widget.newsChannelsList.length) * 0.5;
//               final animationValue = Interval(
//                 delay,
//                 delay + 0.5,
//                 curve: Curves.easeOutCubic,
//               ).transform(_staggerController.value);

//               return Transform.translate(
//                 offset: Offset(0, 50 * (1 - animationValue)),
//                 child: Opacity(
//                   opacity: animationValue,
//                   child: ProfessionalGridNewsChannelCard(
//                     channel: channel,
//                     focusNode: _channelFocusNodes[channelId]!,
//                     onTap: () => _handleGridChannelTap(channel),
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
// }

// // Professional Grid News Channel Card - Same style as grid movie card
// class ProfessionalGridNewsChannelCard extends StatefulWidget {
//   final NewsChannel channel;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int index;

//   const ProfessionalGridNewsChannelCard({
//     Key? key,
//     required this.channel,
//     required this.focusNode,
//     required this.onTap,
//     required this.index,
//   }) : super(key: key);

//   @override
//   _ProfessionalGridNewsChannelCardState createState() =>
//       _ProfessionalGridNewsChannelCardState();
// }

// class _ProfessionalGridNewsChannelCardState
//     extends State<ProfessionalGridNewsChannelCard>
//     with TickerProviderStateMixin {
//   late AnimationController _hoverController;
//   late AnimationController _glowController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;

//   Color _dominantColor = ProfessionalColors.accentBlue;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();

//     _hoverController = AnimationController(
//       duration: AnimationTiming.slow,
//       vsync: this,
//     );

//     _glowController = AnimationController(
//       duration: AnimationTiming.medium,
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
//     final colors = ProfessionalColors.gradientColors;
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
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.select ||
//               event.logicalKey == LogicalKeyboardKey.enter) {
//             widget.onTap();
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
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
//                         offset: const Offset(0, 8),
//                       ),
//                       BoxShadow(
//                         color: _dominantColor.withOpacity(0.2),
//                         blurRadius: 35,
//                         spreadRadius: 4,
//                         offset: const Offset(0, 12),
//                       ),
//                     ] else ...[
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 8,
//                         spreadRadius: 1,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: Stack(
//                     children: [
//                       _buildChannelImage(),
//                       if (_isFocused) _buildFocusBorder(),
//                       _buildGradientOverlay(),
//                       _buildChannelInfo(),
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

//   Widget _buildChannelImage() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       child: widget.channel.banner.isNotEmpty
//           ? Image.network(
//               widget.channel.banner,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) =>
//                   _buildImagePlaceholder(),
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return _buildImagePlaceholder();
//               },
//             )
//           : _buildImagePlaceholder(),
//     );
//   }

//   Widget _buildImagePlaceholder() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ProfessionalColors.cardDark,
//             ProfessionalColors.surfaceDark,
//           ],
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.tv_outlined,
//               size: 40,
//               color: ProfessionalColors.textSecondary,
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'NEWS',
//               style: TextStyle(
//                 color: ProfessionalColors.textSecondary,
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(
//                 color: ProfessionalColors.accentBlue.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Text(
//                 'LIVE',
//                 style: TextStyle(
//                   color: ProfessionalColors.accentBlue,
//                   fontSize: 8,
//                   fontWeight: FontWeight.bold,
//                 ),
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

//   Widget _buildChannelInfo() {
//     final channelName = widget.channel.name;

//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               channelName.toUpperCase(),
//               style: TextStyle(
//                 color: _isFocused ? _dominantColor : Colors.white,
//                 fontSize: _isFocused ? 13 : 12,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5,
//                 shadows: [
//                   Shadow(
//                     color: Colors.black.withOpacity(0.8),
//                     blurRadius: 4,
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (_isFocused) ...[
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: widget.channel.status == 1
//                           ? ProfessionalColors.accentGreen.withOpacity(0.3)
//                           : ProfessionalColors.accentRed.withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: widget.channel.status == 1
//                             ? ProfessionalColors.accentGreen.withOpacity(0.5)
//                             : ProfessionalColors.accentRed.withOpacity(0.5),
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       widget.channel.status == 1 ? 'LIVE' : 'OFF',
//                       style: TextStyle(
//                         color: widget.channel.status == 1
//                             ? ProfessionalColors.accentGreen
//                             : ProfessionalColors.accentRed,
//                         fontSize: 8,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: _dominantColor.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: _dominantColor.withOpacity(0.4),
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       '#${widget.channel.channelNumber}',
//                       style: TextStyle(
//                         color: _dominantColor,
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
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: const Icon(
//           Icons.play_arrow_rounded,
//           color: Colors.white,
//           size: 24,
//         ),
//       ),
//     );
//   }
// }

// // News Channel Model Class
// class NewsChannel {
//   final int id;
//   final int channelNumber;
//   final String name;
//   final String? description;
//   final String banner;
//   final String url;
//   final String streamType;
//   final String genres;
//   final int status;

//   NewsChannel({
//     required this.id,
//     required this.channelNumber,
//     required this.name,
//     this.description,
//     required this.banner,
//     required this.url,
//     required this.streamType,
//     required this.genres,
//     required this.status,
//   });

//   factory NewsChannel.fromJson(Map<String, dynamic> json) {
//     return NewsChannel(
//       id: json['id'] ?? 0,
//       channelNumber: json['channel_number'] ?? 0,
//       name: json['name'] ?? '',
//       description: json['description'],
//       banner: json['banner'] ?? '',
//       url: json['url'] ?? '',
//       streamType: json['stream_type'] ?? '',
//       genres: json['genres'] ?? '',
//       status: json['status'] ?? 0,
//     );
//   }
// }

// /*
// =================================================================
// Focus Provider Integration Methods
// =================================================================

// Add these methods to your FocusProvider class:

// class FocusProvider extends ChangeNotifier {
//   // News Channels Focus Nodes
//   FocusNode? _firstNewsChannelFocusNode;
//   FocusNode? _newsChannelsViewAllFocusNode;
//   ScrollController? _newsChannelsScrollController;

//   // News Channels Focus Management
//   void setFirstNewsChannelFocusNode(FocusNode node) {
//     _firstNewsChannelFocusNode = node;
//   }

//   void setNewsChannelsViewAllFocusNode(FocusNode node) {
//     _newsChannelsViewAllFocusNode = node;
//   }

//   void setNewsChannelsScrollController(ScrollController controller) {
//     _newsChannelsScrollController = controller;
//   }

//   void requestFirstNewsChannelFocus() {
//     if (_firstNewsChannelFocusNode != null) {
//       _firstNewsChannelFocusNode!.requestFocus();
//     }
//   }

//   void requestNewsChannelsViewAllFocus() {
//     if (_newsChannelsViewAllFocusNode != null) {
//       _newsChannelsViewAllFocusNode!.requestFocus();
//     }
//   }

//   void requestNewsChannelsFocus() {
//     requestFirstNewsChannelFocus();
//   }

//   // Navigation Methods
//   void requestMoviesFocus() {
//     // Navigate to movies section
//     if (_firstMoviesFocusNode != null) {
//       _firstMoviesFocusNode!.requestFocus();
//     }
//   }

//   void requestWebSeriesFocus() {
//     // Navigate to web series section
//     if (_firstWebSeriesFocusNode != null) {
//       _firstWebSeriesFocusNode!.requestFocus();
//     }
//   }

//   void requestFirstWebseriesFocus() {
//     requestWebSeriesFocus();
//   }
// }

// =================================================================
// Usage in your main widget:
// =================================================================

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final FocusNode _newsChannelsFocusNode = FocusNode();

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => FocusProvider(),
//       child: Scaffold(
//         backgroundColor: ProfessionalColors.primaryDark,
//         body: SafeArea(
//           child: Column(
//             children: [
//               // Your banner section
              
//               // Movies Section
//               MoviesWidget(
//                 focusNode: _moviesFocusNode,
//                 onFocusChange: (hasFocus) {
//                   // Handle movies focus
//                 },
//               ),
              
//               // News Channels Section
//               NewsChannelList(
//                 focusNode: _newsChannelsFocusNode,
//                 onFocusChange: (hasFocus) {
//                   // Handle news channels focus
//                 },
//               ),
              
//               // Web Series Section
//               WebSeriesWidget(
//                 focusNode: _webSeriesFocusNode,
//                 onFocusChange: (hasFocus) {
//                   // Handle web series focus
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _newsChannelsFocusNode.dispose();
//     super.dispose();
//   }
// }

// =================================================================
// */
// class NewsChannelsFocusHelper {
//   static void requestFirstNewsChannelFocus(BuildContext context) {
//     try {
//       // You can implement this method in your FocusProvider
//       // Provider.of<FocusProvider>(context, listen: false).requestFirstNewsChannelFocus();
//     } catch (e) {
//       print('Focus provider not available: $e');
//     }
//   }

//   static void requestNewsChannelsViewAllFocus(BuildContext context) {
//     try {
//       // You can implement this method in your FocusProvider
//       // Provider.of<FocusProvider>(context, listen: false).requestNewsChannelsViewAllFocus();
//     } catch (e) {
//       print('Focus provider not available: $e');
//     }
//   }

//   static void setNewsChannelsScrollController(
//       BuildContext context, ScrollController controller) {
//     try {
//       // You can implement this method in your FocusProvider
//       // Provider.of<FocusProvider>(context, listen: false).setNewsChannelsScrollController(controller);
//     } catch (e) {
//       print('Focus provider not available: $e');
//     }
//   }
// }

// // Usage Example with Focus Provider Integration
// class NewsChannelsDemo extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: SafeArea(
//         child: LiveMusic(
//           focusNode: FocusNode(), // You can get this from focus provider
//           onFocusChange: (hasFocus) {
//             // Handle focus changes for parent widget
//             print('News channels focus changed: $hasFocus');
//           },
//         ),
//       ),
//     );
//   }
// }
