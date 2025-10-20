










// import 'dart:async';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/home_screen_pages/sub_live_screen/language_channel_screen.dart' hide bannerwdt, focussedBannerhgt, bannerhgt;
// import 'package:provider/provider.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';


// //==============================================================================
// // PROFESSIONAL UI HELPERS
// //==============================================================================
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

// class AnimationTiming {
//   static const Duration ultraFast = Duration(milliseconds: 150);
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration focus = Duration(milliseconds: 300);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// //==============================================================================
// // DATA MODEL
// //==============================================================================
// class Language {
//   final int id;
//   final String title;
//   final String logoUrl;

//   Language({required this.id, required this.title, required this.logoUrl});

//   factory Language.fromJson(Map<String, dynamic> json) {
//     return Language(
//       id: json['id'], 
//       title: json['title'], 
//       logoUrl: json['logo']
//     );
//   }
// }

// //==============================================================================
// // PROFESSIONAL LANGUAGE CARD WIDGET (Updated to match Movie Card)
// //==============================================================================
// class ProfessionalLanguageCard extends StatefulWidget {
//   final Language language;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalLanguageCard({
//     Key? key,
//     required this.language,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalLanguageCardState createState() => _ProfessionalLanguageCardState();
// }

// class _ProfessionalLanguageCardState extends State<ProfessionalLanguageCard>
//     with TickerProviderStateMixin {
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
//     if (!mounted) return;
    
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
//     setState(() {
//       _dominantColor = colors[math.Random().nextInt(colors.length)];
//     });
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
//             width: bannerwdt,
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
//     final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;

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
//             _buildLanguageImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildLanguageBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }




//   // // ✅✅✅ FIX START: The problem was here ✅✅✅
//   // // We now use a stable imageUrl and cacheKey to prevent reloading on every focus change.
//   // Widget _buildLanguageImage(double screenWidth, double posterHeight) {
//   //   // A stable URL that doesn't change on rebuilds.
//   //   final String imageUrl = widget.language.logoUrl;
//   //   // A stable and unique cache key based on the language ID.
//   //   final String cacheKey = widget.language.id.toString();
    
//   //   return SizedBox(
//   //     width: double.infinity,
//   //     height: posterHeight,
//   //     child: widget.language.logoUrl.isNotEmpty
//   //         ? CachedNetworkImage(
//   //             imageUrl: imageUrl, // Using stable URL
//   //             fit: BoxFit.cover,
//   //             memCacheHeight: 300,
//   //             cacheKey: cacheKey, // Using stable cache key
//   //             placeholder: (context, url) => _buildImagePlaceholder(posterHeight),
//   //             errorWidget: (context, url, error) => _buildImagePlaceholder(posterHeight),
//   //           )
//   //         : _buildImagePlaceholder(posterHeight),
//   //   );
//   // }
//   // // ✅✅✅ FIX END ✅✅✅



//   Widget _buildLanguageImage(double screenWidth, double posterHeight) {
//   final String imageUrl = widget.language.logoUrl;

//   return SizedBox(
//     width: double.infinity,
//     height: posterHeight,
//     child: widget.language.logoUrl.isNotEmpty
//         ? Image.network(
//             imageUrl,
//             fit: BoxFit.cover,
//             // यह तब तक प्लेसहोल्डर दिखाएगा जब तक इमेज लोड हो रही है
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) {
//                 return child; // इमेज सफलतापूर्वक लोड हो गई
//               }
//               return _buildImagePlaceholder(posterHeight); // लोडिंग के दौरान प्लेसहोल्डर दिखाएं
//             },
//             // अगर इमेज लोड होने में कोई एरर आता है तो यह प्लेसहोल्डर दिखाएगा
//             errorBuilder: (context, error, stackTrace) {
//               return _buildImagePlaceholder(posterHeight); // एरर पर प्लेसहोल्डर दिखाएं
//             },
//           )
//         : _buildImagePlaceholder(posterHeight),
//   );
// }

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
//             Icons.language,
//             size: height * 0.25,
//             color: ProfessionalColors.textSecondary,
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "LANGUAGE",
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
//               'HD',
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
//                 stops: const [0.0, 0.5, 1.0],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildLanguageBadge() {
//     String languageType = 'LIVE';
//     Color badgeColor = ProfessionalColors.accentRed;


//     return Positioned(
//       top: 8,
//       right: 8,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//         decoration: BoxDecoration(
//           color: badgeColor.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Text(
//           languageType,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 8,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget _buildHoverOverlay() {
//   //   return Positioned.fill(
//   //     child: Container(
//   //       decoration: BoxDecoration(
//   //         borderRadius: BorderRadius.circular(12),
//   //         gradient: LinearGradient(
//   //           begin: Alignment.topCenter,
//   //           end: Alignment.bottomCenter,
//   //           colors: [
//   //             Colors.transparent,
//   //             _dominantColor.withOpacity(0.1),
//   //           ],
//   //         ),
//   //       ),
//   //       child: Center(
//   //         child: Container(
//   //           padding: const EdgeInsets.all(10),
//   //           decoration: BoxDecoration(
//   //             color: Colors.black.withOpacity(0.7),
//   //             borderRadius: BorderRadius.circular(25),
//   //           ),
//   //           child: const Icon(
//   //             Icons.play_arrow_rounded,
//   //             color: Colors.white,
//   //             size: 30,
//   //           ),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }



//   // In lib/home_screen_pages/sub_live_screen/live_channel_language_screen.dart
// // Inside the _ProfessionalLanguageCardState class

// Widget _buildHoverOverlay() {
//   return Positioned.fill(
//     child: Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.transparent,
//             _dominantColor.withOpacity(0.1),
//           ],
//         ),
//       ),
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.7),
//             borderRadius: BorderRadius.circular(25),
//           ),
//           // ✅✅✅ CHANGE WAS MADE HERE ✅✅✅
//           // The 'const' is removed and color is changed from Colors.white to _dominantColor.
//           child: Icon( 
//             Icons.play_arrow_rounded,
//             color: _dominantColor, // Use the dynamic dominant color
//             size: 30,
//           ),
//         ),
//       ),
//     ),
//   );
// }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     final languageName = widget.language.title.toUpperCase();

//     return SizedBox(
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
//           languageName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// //==============================================================================
// // PROFESSIONAL LOADING INDICATOR
// //==============================================================================
// class ProfessionalLoadingIndicator extends StatefulWidget {
//   final String message;

//   const ProfessionalLoadingIndicator({
//     Key? key,
//     this.message = 'Loading...',
//   }) : super(key: key);

//   @override
//   _ProfessionalLoadingIndicatorState createState() => _ProfessionalLoadingIndicatorState();
// }

// class _ProfessionalLoadingIndicatorState extends State<ProfessionalLoadingIndicator> 
//     with TickerProviderStateMixin {
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
//                     colors: const [
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple,
//                       ProfessionalColors.accentGreen,
//                       ProfessionalColors.accentBlue,
//                     ],
//                     stops: const [0.0, 0.3, 0.7, 1.0],
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
//                     Icons.language,
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

// //==============================================================================
// // MAIN LIVE CHANNEL LANGUAGE SCREEN (Updated to match Movies Screen)
// //==============================================================================
// class LiveChannelLanguageScreen extends StatefulWidget {
//   const LiveChannelLanguageScreen({Key? key}) : super(key: key);

//   @override
//   State<LiveChannelLanguageScreen> createState() => _LiveChannelLanguageScreenState();
// }

// class _LiveChannelLanguageScreenState extends State<LiveChannelLanguageScreen>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<Language> _languages = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isNavigating = false;

//   // Animation Controllers
//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   // Focus management
//   Map<String, FocusNode> languageFocusNodes = {};
//   Color _currentAccentColor = ProfessionalColors.accentBlue;

//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _listFocusNode = FocusNode();
  
//   // Navigation index for FocusProvider
//   final int navigationIndex = 2;



//       bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;


//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _fetchLanguages().then((_) {
//       _setupFocusProvider();
//     });
//   }

//   void _setupFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         try {
//           final focusProvider = Provider.of<FocusProvider>(context, listen: false);
          
//           focusProvider.registerGenericChannelFocus(
//             navigationIndex, 
//             _scrollController, 
//             _listFocusNode
//           );

//           if (_languages.isNotEmpty) {
//             final firstLanguageId = _languages[0].id.toString();
//             if (languageFocusNodes.containsKey(firstLanguageId)) {
//               focusProvider.setLiveChannelLanguageFocusNode(
//                 languageFocusNodes[firstLanguageId]!
//               );
//             }
//           }

//           print('✅ Generic focus registered for Languages List (index: $navigationIndex)');
//         } catch (e) {
//           print('❌ Language Screen Focus provider setup failed: $e');
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

//   Future<void> _fetchLanguages() async {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       String authKey = SessionManager.authKey;
//       final response = await https.get(
//         Uri.parse('https://dashboard.cpplayers.com/api/v2/getAllLanguages'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'domain': 'coretechinfo.com'
//         },
//       );

//       if (mounted && response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List<dynamic> languagesJson = data['languages'] ?? [];
        
//         setState(() {
//           _languages = languagesJson.map((json) => Language.fromJson(json)).toList();
//           _isLoading = false;
//           _initializeLanguageFocusNodes();
//         });

//         _headerAnimationController.forward();
//         _listAnimationController.forward();
//       } else if (mounted) {
//         setState(() {
//           _errorMessage = "Failed to load. Status: ${response.statusCode}";
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = "Network error: Please check connection";
//           _isLoading = false;
//         });
//       }
//       print('❌ Error fetching languages: $e');
//     }
//   }

//   void _initializeLanguageFocusNodes() {
//     for (var node in languageFocusNodes.values) {
//       try {
//         node.removeListener(() {});
//         node.dispose();
//       } catch (e) {}
//     }
//     languageFocusNodes.clear();

//     for (var language in _languages) {
//       try {
//         String languageId = language.id.toString();
//         languageFocusNodes[languageId] = FocusNode()
//           ..addListener(() {
//             if (mounted && languageFocusNodes[languageId]!.hasFocus) {
//               _scrollToFocusedItem(languageId);
//             }
//           });
//       } catch (e) {}
//     }
//   }

//   void _scrollToFocusedItem(String itemId) {
//     if (!mounted || !_scrollController.hasClients) return;

//     try {
//       // final screenWidth = MediaQuery.of(context).size.width;
//       int index = _languages.indexWhere((language) => language.id.toString() == itemId);
//       if (index == -1) return;

//       double itemWidth = bannerwdt + 12; // Including margin
//       double targetScrollPosition = (index * itemWidth);

//       targetScrollPosition = targetScrollPosition.clamp(
//         0.0,
//         _scrollController.position.maxScrollExtent,
//       );

//       _scrollController.animateTo(
//         targetScrollPosition,
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeOutCubic,
//       );
//     } catch (e) {
//       print('Error scrolling to language item: $e');
//     }
//   }

//   // ✅ MODIFIED: This function now handles navigation to the LanguageChannelsScreen.
//   void _handleLanguageTap(Language language) async {
//     if (_isNavigating) return;
    
//     // Immediately set the flag to prevent multiple navigations
//     setState(() {
//       _isNavigating = true;
//     });

//     // Navigate and wait for the new screen to be closed
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LanguageChannelsScreen(
//           languageId: language.id.toString(),
//           languageName: language.title,
//         ),
//       ),
//     );

//     // After returning, reset the flag if the widget is still in the tree
//     if (mounted) {
//       setState(() {
//         _isNavigating = false;
//       });
//     }
//   }

//   // Widget _buildLanguageItem(Language language, int index, double screenWidth, double screenHeight) {
//   //   String languageId = language.id.toString();

//   //   languageFocusNodes.putIfAbsent(
//   //     languageId,
//   //     () => FocusNode()
//   //       ..addListener(() {
//   //         if (mounted && languageFocusNodes[languageId]!.hasFocus) {
//   //           _scrollToFocusedItem(languageId);
//   //         }
//   //       }),
//   //   );

//   //   return Focus(
//   //     focusNode: languageFocusNodes[languageId],
//   //     onFocusChange: (hasFocus) async {
//   //       if (hasFocus && mounted) {
//   //         try {
//   //           Color dominantColor = ProfessionalColors.gradientColors[
//   //               math.Random().nextInt(ProfessionalColors.gradientColors.length)];

//   //           setState(() {
//   //             _currentAccentColor = dominantColor;
//   //           });

//   //           context.read<ColorProvider>().updateColor(dominantColor, true);
//   //         } catch (e) {
//   //           print('Focus change handling failed: $e');
//   //         }
//   //       } else if (mounted) {
//   //         context.read<ColorProvider>().resetColor();
//   //       }
//   //     },
//   //     onKey: (FocusNode node, RawKeyEvent event) {
//   //       if (event is RawKeyDownEvent) {
//   //         if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//   //           if (index < _languages.length - 1) {
//   //             String nextLanguageId = _languages[index + 1].id.toString();
//   //             FocusScope.of(context).requestFocus(languageFocusNodes[nextLanguageId]);
//   //             return KeyEventResult.handled;
//   //           }
//   //         } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//   //           if (index > 0) {
//   //             String prevLanguageId = _languages[index - 1].id.toString();
//   //             FocusScope.of(context).requestFocus(languageFocusNodes[prevLanguageId]);
//   //           }
//   //           return KeyEventResult.handled;
//   //         }
//   //         // else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//   //         //   context.read<ColorProvider>().resetColor();
//   //         //   FocusScope.of(context).unfocus();
//   //         //   Future.delayed(const Duration(milliseconds: 50), () {
//   //         //     if (mounted) {
//   //         //       // ✅ FIXED: Now this will properly request focus on language screen's first item
//   //         //       // when coming from horizontal VOD screen
//   //         //       // try {
//   //         //       //   context.read<FocusProvider>().requestFirstHorizontalListNetworksFocus();
//   //         //       // } catch (e) {
//   //         //       //   print('Arrow up focus request failed: $e');
//   //         //       // }
//   //         //     }
//   //         //   });
//   //         //   return KeyEventResult.handled;
//   //         // } 
//   //         else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//   //           context.read<ColorProvider>().resetColor();
//   //           FocusScope.of(context).unfocus();
//   //           Future.delayed(const Duration(milliseconds: 50), () {
//   //             if (mounted) {
//   //               try {
//   //                 context
//   //                     .read<FocusProvider>()
//   //                     .requestFirstHorizontalListNetworksFocus();
//   //               } catch (e) {
//   //                 print('Next section focus request failed: $e');
//   //               }
//   //             }
//   //           });
//   //           return KeyEventResult.handled;
//   //         } else if (event.logicalKey == LogicalKeyboardKey.select) {
//   //           _handleLanguageTap(language);
//   //           return KeyEventResult.handled;
//   //         }
//   //       }
//   //       return KeyEventResult.ignored;
//   //     },
//   //     child: GestureDetector(
//   //       onTap: () => _handleLanguageTap(language),
//   //       child: ProfessionalLanguageCard(
//   //         language: language,
//   //         focusNode: languageFocusNodes[languageId]!,
//   //         onTap: () => _handleLanguageTap(language),
//   //         onColorChange: (color) {
//   //           setState(() {
//   //             _currentAccentColor = color;
//   //           });
//   //           context.read<ColorProvider>().updateColor(color, true);
//   //         },
//   //         index: index,
//   //         categoryTitle: "LANGUAGES",
//   //       ),
//   //     ),
//   //   );
//   // }




//   // Ye function live_channel_language_screen.dart mein hai.
// // Puraane function ko is naye function se replace karein.
// Widget _buildLanguageItem(Language language, int index, double screenWidth, double screenHeight) {
//   String languageId = language.id.toString();

//   languageFocusNodes.putIfAbsent(
//     languageId,
//     () => FocusNode()
//       ..addListener(() {
//         if (mounted && languageFocusNodes[languageId]!.hasFocus) {
//           _scrollToFocusedItem(languageId);
//         }
//       }),
//   );

//   return Focus(
//     focusNode: languageFocusNodes[languageId],
//     onFocusChange: (hasFocus) async {
//       if (hasFocus && mounted) {
//         try {
//           Color dominantColor = ProfessionalColors.gradientColors[
//               math.Random().nextInt(ProfessionalColors.gradientColors.length)];
//           setState(() {
//             _currentAccentColor = dominantColor;
//           });
//           context.read<ColorProvider>().updateColor(dominantColor, true);
//         } catch (e) {
//           print('Focus change handling failed: $e');
//         }
//       } else if (mounted) {
//         context.read<ColorProvider>().resetColor();
//       }
//     },
//     // ✅✅✅ YAHAN BADLAV KIYA GAYA HAI ✅✅✅
//     // onKey: (FocusNode node, RawKeyEvent event) {
//     //   if (event is RawKeyDownEvent) {
//     //     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//     //       if (index < _languages.length - 1) {
//     //         String nextLanguageId = _languages[index + 1].id.toString();
//     //         FocusScope.of(context).requestFocus(languageFocusNodes[nextLanguageId]);
//     //         return KeyEventResult.handled;
//     //       }
//     //     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//     //       if (index > 0) {
//     //         String prevLanguageId = _languages[index - 1].id.toString();
//     //         FocusScope.of(context).requestFocus(languageFocusNodes[prevLanguageId]);
//     //       }
//     //       return KeyEventResult.handled;
//     //     } 
//     //     // ✅ Naya logic: Arrow Up ke liye
//     //     else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//     //       context.read<ColorProvider>().resetColor();
//     //       FocusScope.of(context).unfocus();
//     //       Future.delayed(const Duration(milliseconds: 50), () {
//     //         if (mounted) {
//     //           try {
//     //             // Aapke FocusProvider ka function yahan call ho raha hai
//     //             context.read<FocusProvider>().requestWatchNowFocus();
//     //           } catch (e) {
//     //             print('Arrow up focus request failed: $e');
//     //           }
//     //         }
//     //       });
//     //       return KeyEventResult.handled;
//     //     } 
//     //     else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//     //       context.read<ColorProvider>().resetColor();
//     //       FocusScope.of(context).unfocus();
//     //       Future.delayed(const Duration(milliseconds: 50), () {
//     //         if (mounted) {
//     //           try {
//     //             context
//     //                 .read<FocusProvider>()
//     //                 .requestFirstHorizontalListNetworksFocus();
//     //           } catch (e) {
//     //             print('Next section focus request failed: $e');
//     //           }
//     //         }
//     //       });
//     //       return KeyEventResult.handled;
//     //     } else if (event.logicalKey == LogicalKeyboardKey.select) {
//     //       _handleLanguageTap(language);
//     //       return KeyEventResult.handled;
//     //     }
//     //   }
//     //   return KeyEventResult.ignored;
//     // },
//         onKey: (FocusNode node, RawKeyEvent event) {
//       if (event is RawKeyDownEvent) {
//         final key = event.logicalKey;

//         // --- हॉरिजॉन्टल मूवमेंट (लेफ्ट/राइट) के लिए थ्रॉटलिंग ---
//         if (key == LogicalKeyboardKey.arrowRight ||
//             key == LogicalKeyboardKey.arrowLeft) {
              
//           // 1. अगर नेविगेशन लॉक्ड है, तो कुछ न करें
//           if (_isNavigationLocked) return KeyEventResult.handled;

//           // 2. नेविगेशन को लॉक करें और 300ms का टाइमर शुरू करें
//           setState(() => _isNavigationLocked = true);
//           _navigationLockTimer = Timer(const Duration(milliseconds: 600), () {
//             if (mounted) setState(() => _isNavigationLocked = false);
//           });

//           // 3. अब फोकस बदलें
//           if (key == LogicalKeyboardKey.arrowRight) {
//             if (index < _languages.length - 1) {
//               String nextLanguageId = _languages[index + 1].id.toString();
//               FocusScope.of(context).requestFocus(languageFocusNodes[nextLanguageId]);
//             } else {
//               // अगर लिस्ट के अंत में हैं, तो लॉक तुरंत हटा दें
//               _navigationLockTimer?.cancel();
//               if (mounted) setState(() => _isNavigationLocked = false);
//             }
//           } else if (key == LogicalKeyboardKey.arrowLeft) {
//             if (index > 0) {
//               String prevLanguageId = _languages[index - 1].id.toString();
//               FocusScope.of(context).requestFocus(languageFocusNodes[prevLanguageId]);
//             } else {
//               // अगर लिस्ट की शुरुआत में हैं, तो लॉक तुरंत हटा दें
//               _navigationLockTimer?.cancel();
//               if (mounted) setState(() => _isNavigationLocked = false);
//             }
//           }
//           return KeyEventResult.handled;
//         }

//         // --- बाकी कीज़ (अप/डाउन/सेलेक्ट) को तुरंत हैंडल करें ---
//         if (key == LogicalKeyboardKey.arrowUp) {
//           context.read<ColorProvider>().resetColor();
//           FocusScope.of(context).unfocus();
//           Future.delayed(const Duration(milliseconds: 50), () {
//             if (mounted) {
//               try {
//                 context.read<FocusProvider>().requestWatchNowFocus();
//               } catch (e) {
//                 print('Arrow up focus request failed: $e');
//               }
//             }
//           });
//           return KeyEventResult.handled;
//         } else if (key == LogicalKeyboardKey.arrowDown) {
//           context.read<ColorProvider>().resetColor();
//           FocusScope.of(context).unfocus();
//           Future.delayed(const Duration(milliseconds: 50), () {
//             if (mounted) {
//               try {
//                 context
//                     .read<FocusProvider>()
//                     .requestFirstHorizontalListNetworksFocus();
//               } catch (e) {
//                 print('Next section focus request failed: $e');
//               }
//             }
//           });
//           return KeyEventResult.handled;
//         } else if (key == LogicalKeyboardKey.select) {
//           _handleLanguageTap(language);
//           return KeyEventResult.handled;
//         }
//       }
//       return KeyEventResult.ignored;
//     },
//     child: GestureDetector(
//       onTap: () => _handleLanguageTap(language),
//       child: ProfessionalLanguageCard(
//         language: language,
//         focusNode: languageFocusNodes[languageId]!,
//         onTap: () => _handleLanguageTap(language),
//         onColorChange: (color) {
//           setState(() {
//             _currentAccentColor = color;
//           });
//           context.read<ColorProvider>().updateColor(color, true);
//         },
//         index: index,
//         categoryTitle: "LANGUAGES",
//       ),
//     ),
//   );
// }

//   // In lib/home_screen_pages/sub_live_screen/live_channel_language_screen.dart
//   Widget _buildLanguagesList(double screenWidth, double screenHeight) {
//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       // ✅ FIX: Remove the fixed height from this Container.
//       // Let the Expanded widget from the build method manage the height.
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         clipBehavior: Clip.none,
//         controller: _scrollController,
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
//         cacheExtent: 9999,
//         itemCount: _languages.length,
//         itemBuilder: (context, index) {
//           var language = _languages[index];
//           return _buildLanguageItem(language, index, screenWidth, screenHeight);
//         },
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
//                 "LIVE CHANNELS",
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(double screenWidth, double screenHeight) {
//     if (_isLoading) {
//       return ProfessionalLoadingIndicator(message: 'Loading Languages...');
//     } else if (_errorMessage.isNotEmpty) {
//       return _buildErrorWidget();
//     } else if (_languages.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildLanguagesList(screenWidth, screenHeight);
//     }
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: bannerwdt,
//             height: bannerhgt,
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
//             onPressed: _fetchLanguages,
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
//             width: bannerwdt,
//             height: bannerhgt,
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
//               Icons.language,
//               size: 40,
//               color: ProfessionalColors.accentBlue,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No Languages Available',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Check back later for language options',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();

//     for (var entry in languageFocusNodes.entries) {
//       try {
//         entry.value.removeListener(() {});
//         entry.value.dispose();
//       } catch (e) {}
//     }
//     languageFocusNodes.clear();

//     try {
//       _scrollController.dispose();
//       _listFocusNode.dispose();
//     } catch (e) {}

//     _isNavigating = false;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     // ✅ FIX: Uncommented these lines to define screenWidth and screenHeight.
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Consumer<ColorProvider>(
//       builder: (context, colorProvider, child) {
//         final bgColor = colorProvider.isItemFocused
//             ? colorProvider.dominantColor.withOpacity(0.1)
//             : ProfessionalColors.primaryDark;

//         return Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Container(
//              // ✅ FIX: Replaced undefined variable `screenhgt` with `screenHeight`.
//             height: screenHeight * 0.38, 
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   bgColor,
//                   bgColor.withOpacity(0.8),
//                   ProfessionalColors.primaryDark,
//                 ],
//               ),
//             ),
//             child: Column(
//               children: [
//                 // ✅ FIX: Replaced undefined variables with locally defined ones.
//                 SizedBox(height: screenHeight * 0.02),
//                 _buildProfessionalTitle(screenWidth),
//                 SizedBox(height: screenHeight * 0.01),
//                 Expanded(
//                   child: _buildBody(screenWidth, screenHeight),
//                 ), 
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }






import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/home_screen_pages/sub_live_screen/language_channel_screen.dart' hide bannerwdt, focussedBannerhgt, bannerhgt;
import 'package:provider/provider.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';


//==============================================================================
// PROFESSIONAL UI HELPERS
//==============================================================================
class ProfessionalColors {
  static const primaryDark = Color(0xFF0A0E1A);
  static const surfaceDark = Color(0xFF1A1D29);
  static const cardDark = Color(0xFF2A2D3A);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentGreen = Color(0xFF10B981);
  static const accentRed = Color(0xFFEF4444);
  static const accentOrange = Color(0xFFF59E0B);
  static const accentPink = Color(0xFFEC4899);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const focusGlow = Color(0xFF60A5FA);

  static List<Color> gradientColors = [
    accentBlue,
    accentPurple,
    accentGreen,
    accentRed,
    accentOrange,
    accentPink,
  ];
}

class AnimationTiming {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration focus = Duration(milliseconds: 300);
  static const Duration scroll = Duration(milliseconds: 800);
}

//==============================================================================
// DATA MODEL
//==============================================================================
class Language {
  final int id;
  final String title;
  final String logoUrl;

  Language({required this.id, required this.title, required this.logoUrl});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'], 
      title: json['title'], 
      logoUrl: json['logo']
    );
  }
}

//==============================================================================
// PROFESSIONAL LANGUAGE CARD WIDGET
//==============================================================================
class ProfessionalLanguageCard extends StatefulWidget {
  final Language language;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;
  final int index;
  final String categoryTitle;

  const ProfessionalLanguageCard({
    Key? key,
    required this.language,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalLanguageCardState createState() => _ProfessionalLanguageCardState();
}

class _ProfessionalLanguageCardState extends State<ProfessionalLanguageCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  Color _dominantColor = ProfessionalColors.accentBlue;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: AnimationTiming.medium,
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;
    
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });

    if (_isFocused) {
      _scaleController.forward();
      _glowController.forward();
      _generateDominantColor();
      widget.onColorChange(_dominantColor);
      HapticFeedback.lightImpact();
    } else {
      _scaleController.reverse();
      _glowController.reverse();
    }
  }

  void _generateDominantColor() {
    final colors = ProfessionalColors.gradientColors;
    setState(() {
      _dominantColor = colors[math.Random().nextInt(colors.length)];
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: bannerwdt,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfessionalPoster(screenWidth, screenHeight),
                _buildProfessionalTitle(screenWidth),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
    final posterHeight = _isFocused ? focussedBannerhgt : bannerhgt;

    return Container(
      height: posterHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (_isFocused) ...[
            BoxShadow(
              color: _dominantColor.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 3,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: _dominantColor.withOpacity(0.2),
              blurRadius: 45,
              spreadRadius: 6,
              offset: const Offset(0, 15),
            ),
          ] else ...[
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            _buildLanguageImage(screenWidth, posterHeight),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            _buildLanguageBadge(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageImage(double screenWidth, double posterHeight) {
    final String imageUrl = widget.language.logoUrl;
    final String cacheKey = widget.language.id.toString();

    return SizedBox(
      width: double.infinity,
      height: posterHeight,
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              cacheKey: cacheKey,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImagePlaceholder(posterHeight),
              errorWidget: (context, url, error) => _buildImagePlaceholder(posterHeight),
            )
          : _buildImagePlaceholder(posterHeight),
    );
  }


  Widget _buildImagePlaceholder(double height) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ProfessionalColors.cardDark,
            ProfessionalColors.surfaceDark,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.language,
            size: height * 0.25,
            color: ProfessionalColors.textSecondary,
          ),
          const SizedBox(height: 8),
          const Text(
            "LANGUAGE",
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ProfessionalColors.accentBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'HD',
              style: TextStyle(
                color: ProfessionalColors.accentBlue,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusBorder() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 3,
            color: _dominantColor,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
                end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
                colors: [
                  Colors.transparent,
                  _dominantColor.withOpacity(0.15),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageBadge() {
    String languageType = 'LIVE';
    Color badgeColor = ProfessionalColors.accentRed;


    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          languageType,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHoverOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              _dominantColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon( 
              Icons.play_arrow_rounded,
              color: _dominantColor,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalTitle(double screenWidth) {
    final languageName = widget.language.title.toUpperCase();

    return SizedBox(
      width: screenWidth * 0.18,
      child: AnimatedDefaultTextStyle(
        duration: AnimationTiming.medium,
        style: TextStyle(
          fontSize: _isFocused ? 13 : 11,
          fontWeight: FontWeight.w600,
          color: _isFocused ? _dominantColor : ProfessionalColors.textPrimary,
          letterSpacing: 0.5,
          shadows: _isFocused
              ? [
                  Shadow(
                    color: _dominantColor.withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          languageName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

//==============================================================================
// PROFESSIONAL LOADING INDICATOR
//==============================================================================
class ProfessionalLoadingIndicator extends StatefulWidget {
  final String message;

  const ProfessionalLoadingIndicator({
    Key? key,
    this.message = 'Loading...',
  }) : super(key: key);

  @override
  _ProfessionalLoadingIndicatorState createState() => _ProfessionalLoadingIndicatorState();
}

class _ProfessionalLoadingIndicatorState extends State<ProfessionalLoadingIndicator> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: const [
                      ProfessionalColors.accentBlue,
                      ProfessionalColors.accentPurple,
                      ProfessionalColors.accentGreen,
                      ProfessionalColors.accentBlue,
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                    transform: GradientRotation(_animation.value * 2 * math.pi),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ProfessionalColors.primaryDark,
                  ),
                  child: const Icon(
                    Icons.language,
                    color: ProfessionalColors.textPrimary,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            widget.message,
            style: const TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 200,
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: ProfessionalColors.surfaceDark,
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _animation.value,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    ProfessionalColors.accentBlue,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//==============================================================================
// MAIN LIVE CHANNEL LANGUAGE SCREEN
//==============================================================================
class LiveChannelLanguageScreen extends StatefulWidget {
  const LiveChannelLanguageScreen({Key? key}) : super(key: key);

  @override
  State<LiveChannelLanguageScreen> createState() => _LiveChannelLanguageScreenState();
}

class _LiveChannelLanguageScreenState extends State<LiveChannelLanguageScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  List<Language> _languages = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isNavigating = false;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  // Focus management
  Map<String, FocusNode> languageFocusNodes = {};
  Color _currentAccentColor = ProfessionalColors.accentBlue;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _listFocusNode = FocusNode();
  
  final int navigationIndex = 2;

  // ✅ NEW: State variables for navigation throttling
  bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;


  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchLanguages().then((_) {
      _setupFocusProvider();
    });
  }

  void _setupFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final focusProvider = Provider.of<FocusProvider>(context, listen: false);
          
          focusProvider.registerGenericChannelFocus(
            navigationIndex, 
            _scrollController, 
            _listFocusNode
          );

          if (_languages.isNotEmpty) {
            final firstLanguageId = _languages[0].id.toString();
            if (languageFocusNodes.containsKey(firstLanguageId)) {
              focusProvider.setLiveChannelLanguageFocusNode(
                languageFocusNodes[firstLanguageId]!
              );
            }
          }

          print('✅ Generic focus registered for Languages List (index: $navigationIndex)');
        } catch (e) {
          print('❌ Language Screen Focus provider setup failed: $e');
        }
      }
    });
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _listFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _fetchLanguages() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String authKey = SessionManager.authKey;
      final response = await https.get(
        Uri.parse('https://dashboard.cpplayers.com/api/v2/getAllLanguages'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'domain': 'coretechinfo.com'
        },
      );

      if (mounted && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> languagesJson = data['languages'] ?? [];
        
        setState(() {
          _languages = languagesJson.map((json) => Language.fromJson(json)).toList();
          _isLoading = false;
          _initializeLanguageFocusNodes();
        });

        _headerAnimationController.forward();
        _listAnimationController.forward();
      } else if (mounted) {
        setState(() {
          _errorMessage = "Failed to load. Status: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Network error: Please check connection";
          _isLoading = false;
        });
      }
      print('❌ Error fetching languages: $e');
    }
  }

  void _initializeLanguageFocusNodes() {
    for (var node in languageFocusNodes.values) {
      try {
        node.removeListener(() {});
        node.dispose();
      } catch (e) {}
    }
    languageFocusNodes.clear();

    for (var language in _languages) {
      try {
        String languageId = language.id.toString();
        languageFocusNodes[languageId] = FocusNode()
          ..addListener(() {
            if (mounted && languageFocusNodes[languageId]!.hasFocus) {
              _scrollToFocusedItem(languageId);
            }
          });
      } catch (e) {}
    }
  }

  void _scrollToFocusedItem(String itemId) {
    if (!mounted || !_scrollController.hasClients) return;

    try {
      int index = _languages.indexWhere((language) => language.id.toString() == itemId);
      if (index == -1) return;

      double itemWidth = bannerwdt + 12; // Including margin
      double targetScrollPosition = (index * itemWidth);

      targetScrollPosition = targetScrollPosition.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      _scrollController.animateTo(
        targetScrollPosition,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } catch (e) {
      print('Error scrolling to language item: $e');
    }
  }

  void _handleLanguageTap(Language language) async {
    if (_isNavigating) return;
    
    setState(() {
      _isNavigating = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LanguageChannelsScreen(
          languageId: language.id.toString(),
          languageName: language.title,
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _isNavigating = false;
      });
    }
  }

  // ✅ MODIFIED: This function now includes the throttling logic for left/right navigation.
  Widget _buildLanguageItem(Language language, int index, double screenWidth, double screenHeight) {
    String languageId = language.id.toString();

    languageFocusNodes.putIfAbsent(
      languageId,
      () => FocusNode()
        ..addListener(() {
          if (mounted && languageFocusNodes[languageId]!.hasFocus) {
            _scrollToFocusedItem(languageId);
          }
        }),
    );

    return Focus(
      focusNode: languageFocusNodes[languageId],
      onFocusChange: (hasFocus) async {
        if (hasFocus && mounted) {
          try {
            Color dominantColor = ProfessionalColors.gradientColors[
                math.Random().nextInt(ProfessionalColors.gradientColors.length)];
            setState(() {
              _currentAccentColor = dominantColor;
            });
            context.read<ColorProvider>().updateColor(dominantColor, true);
          } catch (e) {
            print('Focus change handling failed: $e');
          }
        } else if (mounted) {
          context.read<ColorProvider>().resetColor();
        }
      },
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          final key = event.logicalKey;

          // --- Throttling for Horizontal Movement (Left/Right) ---
          if (key == LogicalKeyboardKey.arrowRight ||
              key == LogicalKeyboardKey.arrowLeft) {
                
            // 1. If navigation is locked, do nothing.
            if (_isNavigationLocked) return KeyEventResult.handled;

            // 2. Lock navigation and start a timer.
            setState(() => _isNavigationLocked = true);
            _navigationLockTimer = Timer(const Duration(milliseconds: 600), () {
              if (mounted) setState(() => _isNavigationLocked = false);
            });

            // 3. Now, change the focus.
            if (key == LogicalKeyboardKey.arrowRight) {
              if (index < _languages.length - 1) {
                String nextLanguageId = _languages[index + 1].id.toString();
                FocusScope.of(context).requestFocus(languageFocusNodes[nextLanguageId]);
              } else {
                // If at the end of the list, unlock immediately.
                _navigationLockTimer?.cancel();
                if (mounted) setState(() => _isNavigationLocked = false);
              }
            } else if (key == LogicalKeyboardKey.arrowLeft) {
              if (index > 0) {
                String prevLanguageId = _languages[index - 1].id.toString();
                FocusScope.of(context).requestFocus(languageFocusNodes[prevLanguageId]);
              } else {
                // If at the start of the list, unlock immediately.
                _navigationLockTimer?.cancel();
                if (mounted) setState(() => _isNavigationLocked = false);
              }
            }
            return KeyEventResult.handled;
          }

          // --- Handle other keys (Up/Down/Select) immediately ---
          if (key == LogicalKeyboardKey.arrowUp) {
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                try {
                  context.read<FocusProvider>().requestWatchNowFocus();
                } catch (e) {
                  print('Arrow up focus request failed: $e');
                }
              }
            });
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.arrowDown) {
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                try {
                  context
                      .read<FocusProvider>()
                      .requestFirstHorizontalListNetworksFocus();
                } catch (e) {
                  print('Next section focus request failed: $e');
                }
              }
            });
            return KeyEventResult.handled;
          } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
            _handleLanguageTap(language);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _handleLanguageTap(language),
        child: ProfessionalLanguageCard(
          language: language,
          focusNode: languageFocusNodes[languageId]!,
          onTap: () => _handleLanguageTap(language),
          onColorChange: (color) {
            if(mounted) {
              setState(() {
                _currentAccentColor = color;
              });
              context.read<ColorProvider>().updateColor(color, true);
            }
          },
          index: index,
          categoryTitle: "LANGUAGES",
        ),
      ),
    );
  }

  Widget _buildLanguagesList(double screenWidth, double screenHeight) {
    return FadeTransition(
      opacity: _listFadeAnimation,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
        cacheExtent: 9999,
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          var language = _languages[index];
          return _buildLanguageItem(language, index, screenWidth, screenHeight);
        },
      ),
    );
  }

  Widget _buildProfessionalTitle(double screenWidth) {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  ProfessionalColors.accentBlue,
                  ProfessionalColors.accentPurple,
                ],
              ).createShader(bounds),
              child: const Text(
                "LIVE CHANNELS",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(double screenWidth, double screenHeight) {
    if (_isLoading) {
      return ProfessionalLoadingIndicator(message: 'Loading Languages...');
    } else if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    } else if (_languages.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildLanguagesList(screenWidth, screenHeight);
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: bannerwdt,
            height: bannerhgt,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalColors.accentRed.withOpacity(0.2),
                  ProfessionalColors.accentRed.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: ProfessionalColors.accentRed,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: const TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchLanguages,
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfessionalColors.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: bannerwdt,
            height: bannerhgt,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalColors.accentBlue.withOpacity(0.2),
                  ProfessionalColors.accentBlue.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.language,
              size: 40,
              color: ProfessionalColors.accentBlue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Languages Available',
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for language options',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // ✅ MODIFIED: Cancel the timer on dispose
    _navigationLockTimer?.cancel();
    _headerAnimationController.dispose();
    _listAnimationController.dispose();

    for (var entry in languageFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
      } catch (e) {}
    }
    languageFocusNodes.clear();

    try {
      _scrollController.dispose();
      _listFocusNode.dispose();
    } catch (e) {}

    _isNavigating = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        final bgColor = colorProvider.isItemFocused
            ? colorProvider.dominantColor.withOpacity(0.1)
            : ProfessionalColors.primaryDark;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            height: screenHeight * 0.38, 
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bgColor,
                  bgColor.withOpacity(0.8),
                  ProfessionalColors.primaryDark,
                ],
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                _buildProfessionalTitle(screenWidth),
                SizedBox(height: screenHeight * 0.01),
                Expanded(
                  child: _buildBody(screenWidth, screenHeight),
                ), 
              ],
            ),
          ),
        );
      },
    );
  }
}