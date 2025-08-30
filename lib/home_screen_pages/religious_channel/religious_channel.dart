// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:math' as math;
// // import 'dart:ui';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// // import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart'
// //     as loading_indicator;
// // import 'package:mobi_tv_entertainment/widgets/utils/color_service.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../main.dart';
// // import 'focussable_webseries_widget.dart';
// // import '../../widgets/models/news_item_model.dart';
// // import 'webseries_details_page.dart';
// // import 'package:cached_network_image/cached_network_image.dart';

// // // Professional Colors for WebSeries (same as Movies)
// // class ProfessionalWebSeriesColors {
// //   static const primaryDark = Color(0xFF0A0E1A);
// //   static const surfaceDark = Color(0xFF1A1D29);
// //   static const cardDark = Color(0xFF2A2D3A);
// //   static const accentBlue = Color(0xFF3B82F6);
// //   static const accentPurple = Color(0xFF8B5CF6);
// //   static const accentGreen = Color(0xFF10B981);
// //   static const accentRed = Color(0xFFEF4444);
// //   static const accentOrange = Color(0xFFF59E0B);
// //   static const accentPink = Color(0xFFEC4899);
// //   static const textPrimary = Color(0xFFFFFFFF);
// //   static const textSecondary = Color(0xFFB3B3B3);

// //   static List<Color> gradientColors = [
// //     accentBlue,
// //     accentPurple,
// //     accentGreen,
// //     accentRed,
// //     accentOrange,
// //     accentPink,
// //   ];
// // }

// // // Professional Animation Timings
// // class WebSeriesAnimationTiming {
// //   static const Duration ultraFast = Duration(milliseconds: 150);
// //   static const Duration fast = Duration(milliseconds: 250);
// //   static const Duration medium = Duration(milliseconds: 400);
// //   static const Duration slow = Duration(milliseconds: 600);
// //   static const Duration focus = Duration(milliseconds: 700); // Slow like movies
// //   static const Duration scroll = Duration(milliseconds: 800);
// // }

// // // Professional WebSeries Card Widget
// // class ProfessionalWebSeriesCard extends StatefulWidget {
// //   final dynamic webSeries;
// //   final FocusNode focusNode;
// //   final VoidCallback onTap;
// //   final Function(Color) onColorChange;
// //   final int index;
// //   final VoidCallback? onUpPress;

// //   const ProfessionalWebSeriesCard({
// //     Key? key,
// //     required this.webSeries,
// //     required this.focusNode,
// //     required this.onTap,
// //     required this.onColorChange,
// //     required this.index,
// //     this.onUpPress,
// //   }) : super(key: key);

// //   @override
// //   _ProfessionalWebSeriesCardState createState() =>
// //       _ProfessionalWebSeriesCardState();
// // }

// // class _ProfessionalWebSeriesCardState extends State<ProfessionalWebSeriesCard>
// //     with TickerProviderStateMixin {
// //   late AnimationController _scaleController;
// //   late AnimationController _glowController;
// //   late AnimationController _shimmerController;

// //   late Animation<double> _scaleAnimation;
// //   late Animation<double> _glowAnimation;
// //   late Animation<double> _shimmerAnimation;

// //   Color _dominantColor = ProfessionalWebSeriesColors.accentBlue;
// //   bool _isFocused = false;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _scaleController = AnimationController(
// //       duration: WebSeriesAnimationTiming.focus,
// //       vsync: this,
// //     );

// //     _glowController = AnimationController(
// //       duration: WebSeriesAnimationTiming.medium,
// //       vsync: this,
// //     );

// //     _shimmerController = AnimationController(
// //       duration: Duration(milliseconds: 1500),
// //       vsync: this,
// //     )..repeat();

// //     _scaleAnimation = Tween<double>(
// //       begin: 1.0,
// //       end: 1.04, // Same as movies
// //     ).animate(CurvedAnimation(
// //       parent: _scaleController,
// //       curve: Curves.easeOutCubic,
// //     ));

// //     _glowAnimation = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(CurvedAnimation(
// //       parent: _glowController,
// //       curve: Curves.easeInOut,
// //     ));

// //     _shimmerAnimation = Tween<double>(
// //       begin: -1.0,
// //       end: 2.0,
// //     ).animate(CurvedAnimation(
// //       parent: _shimmerController,
// //       curve: Curves.easeInOut,
// //     ));

// //     widget.focusNode.addListener(_handleFocusChange);
// //   }

// //   void _handleFocusChange() {
// //     setState(() {
// //       _isFocused = widget.focusNode.hasFocus;
// //     });

// //     if (_isFocused) {
// //       _scaleController.forward();
// //       _glowController.forward();
// //       _generateDominantColor();
// //       widget.onColorChange(_dominantColor);
// //       HapticFeedback.lightImpact();
// //     } else {
// //       _scaleController.reverse();
// //       _glowController.reverse();
// //     }
// //   }

// //   void _generateDominantColor() {
// //     final colors = ProfessionalWebSeriesColors.gradientColors;
// //     _dominantColor = colors[math.Random().nextInt(colors.length)];
// //   }

// //   @override
// //   void dispose() {
// //     _scaleController.dispose();
// //     _glowController.dispose();
// //     _shimmerController.dispose();
// //     widget.focusNode.removeListener(_handleFocusChange);
// //     super.dispose();
// //   }

// //   // Helper method for URL validation
// //   bool _isValidImageUrl(String url) {
// //     if (url.isEmpty) return false;

// //     try {
// //       final uri = Uri.parse(url);
// //       if (!uri.hasAbsolutePath) return false;
// //       if (uri.scheme != 'http' && uri.scheme != 'https') return false;

// //       final path = uri.path.toLowerCase();
// //       return path.contains('.jpg') ||
// //           path.contains('.jpeg') ||
// //           path.contains('.png') ||
// //           path.contains('.webp') ||
// //           path.contains('.gif') ||
// //           path.contains('image') ||
// //           path.contains('thumb') ||
// //           path.contains('banner') ||
// //           path.contains('poster');
// //     } catch (e) {
// //       return false;
// //     }
// //   }

// //   // Enhanced image widget builder
// //   Widget _buildEnhancedWebSeriesImage(double width, double height) {
// //     // Priority order: poster → banner → fallback
// //     final posterUrl = widget.webSeries['poster']?.toString() ?? '';
// //     final bannerUrl = widget.webSeries['banner']?.toString() ?? '';

// //     return Container(
// //       width: width,
// //       height: height,
// //       child: Stack(
// //         children: [
// //           // Default background with series icon
// //           Container(
// //             width: width,
// //             height: height,
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //                 colors: [
// //                   ProfessionalWebSeriesColors.cardDark,
// //                   ProfessionalWebSeriesColors.surfaceDark,
// //                 ],
// //               ),
// //             ),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(
// //                   Icons.tv_rounded,
// //                   size: height * 0.25,
// //                   color: ProfessionalWebSeriesColors.textSecondary,
// //                 ),
// //                 SizedBox(height: 8),
// //                 Text(
// //                   'SERIES',
// //                   style: TextStyle(
// //                     color: ProfessionalWebSeriesColors.textSecondary,
// //                     fontSize: 10,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           // Try poster first
// //           if (_isValidImageUrl(posterUrl))
// //             _buildCachedImage(posterUrl, width, height)
// //           // Fallback to banner
// //           else if (_isValidImageUrl(bannerUrl))
// //             _buildCachedImage(bannerUrl, width, height),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildCachedImage(String imageUrl, double width, double height) {
// //     return CachedNetworkImage(
// //       imageUrl: imageUrl,
// //       width: width,
// //       height: height,
// //       fit: BoxFit.cover,
// //       placeholder: (context, url) => Container(
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             colors: [
// //               ProfessionalWebSeriesColors.cardDark,
// //               ProfessionalWebSeriesColors.surfaceDark,
// //             ],
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //           ),
// //         ),
// //         child: Center(
// //           child: CircularProgressIndicator(
// //             strokeWidth: 2,
// //             valueColor: AlwaysStoppedAnimation<Color>(
// //               ProfessionalWebSeriesColors.accentPurple,
// //             ),
// //           ),
// //         ),
// //       ),
// //       errorWidget: (context, url, error) =>
// //           Container(), // Show background fallback
// //       fadeInDuration: const Duration(milliseconds: 300),
// //       fadeOutDuration: const Duration(milliseconds: 100),
// //       memCacheWidth: 200,
// //       memCacheHeight: 300,
// //       maxWidthDiskCache: 400,
// //       maxHeightDiskCache: 600,
// //     );
// //   }

// //   // ================================
// //   // STEP 4: Replace _buildWebSeriesImage method
// //   // ================================

// //   Widget _buildWebSeriesImage(double screenWidth, double posterHeight) {
// //     return Container(
// //       width: double.infinity,
// //       height: posterHeight,
// //       child: _buildEnhancedWebSeriesImage(double.infinity, posterHeight),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final screenWidth = MediaQuery.of(context).size.width;
// //     final screenHeight = MediaQuery.of(context).size.height;

// //     return AnimatedBuilder(
// //       animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
// //       builder: (context, child) {
// //         return Transform.scale(
// //           scale: _scaleAnimation.value,
// //           child: Container(
// //             width: screenWidth * 0.19,
// //             margin: EdgeInsets.symmetric(horizontal: 6),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.center,
// //               children: [
// //                 _buildProfessionalPoster(screenWidth, screenHeight),
// //                 // SizedBox(height: 10),
// //                 _buildProfessionalTitle(screenWidth),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildProfessionalPoster(double screenWidth, double screenHeight) {
// //     final posterHeight = _isFocused ? screenHeight * 0.25 : screenHeight * 0.20;

// //     return Container(
// //       margin: EdgeInsets.only(top: 15),
// //       height: posterHeight,
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [
// //           if (_isFocused) ...[
// //             BoxShadow(
// //               color: _dominantColor.withOpacity(0.4),
// //               blurRadius: 25,
// //               spreadRadius: 3,
// //               offset: Offset(0, 8),
// //             ),
// //             BoxShadow(
// //               color: _dominantColor.withOpacity(0.2),
// //               blurRadius: 45,
// //               spreadRadius: 6,
// //               offset: Offset(0, 15),
// //             ),
// //           ] else ...[
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.4),
// //               blurRadius: 10,
// //               spreadRadius: 2,
// //               offset: Offset(0, 5),
// //             ),
// //           ],
// //         ],
// //       ),
// //       child: ClipRRect(
// //         borderRadius: BorderRadius.circular(12),
// //         child: Stack(
// //           children: [
// //             _buildWebSeriesImage(screenWidth, posterHeight),
// //             if (_isFocused) _buildFocusBorder(),
// //             if (_isFocused) _buildShimmerEffect(),
// //             _buildSeriesBadge(),
// //             if (_isFocused) _buildHoverOverlay(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // Widget _buildWebSeriesImage(double screenWidth, double posterHeight) {
// //   //   final imageUrl = widget.webSeries['poster']?.toString() ??
// //   //       widget.webSeries['banner']?.toString() ??
// //   //       '';

// //   //   return Container(
// //   //     width: double.infinity,
// //   //     height: posterHeight,
// //   //     child: imageUrl.isNotEmpty
// //   //         ? CachedNetworkImage(
// //   //             imageUrl: imageUrl,
// //   //             fit: BoxFit.cover,
// //   //             placeholder: (context, url) =>
// //   //                 _buildImagePlaceholder(posterHeight),
// //   //             errorWidget: (context, url, error) =>
// //   //                 _buildImagePlaceholder(posterHeight),
// //   //           )
// //   //         : _buildImagePlaceholder(posterHeight),
// //   //   );
// //   // }

// //   Widget _buildImagePlaceholder(double height) {
// //     return Container(
// //       height: height,
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [
// //             ProfessionalWebSeriesColors.cardDark,
// //             ProfessionalWebSeriesColors.surfaceDark,
// //           ],
// //         ),
// //       ),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(
// //             Icons.tv_rounded,
// //             size: height * 0.25,
// //             color: ProfessionalWebSeriesColors.textSecondary,
// //           ),
// //           SizedBox(height: 8),
// //           Text(
// //             'No Image',
// //             style: TextStyle(
// //               color: ProfessionalWebSeriesColors.textSecondary,
// //               fontSize: 10,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildFocusBorder() {
// //     return Positioned.fill(
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(
// //             width: 3,
// //             color: _dominantColor,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildShimmerEffect() {
// //     return AnimatedBuilder(
// //       animation: _shimmerAnimation,
// //       builder: (context, child) {
// //         return Positioned.fill(
// //           child: Container(
// //             decoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(12),
// //               gradient: LinearGradient(
// //                 begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
// //                 end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
// //                 colors: [
// //                   Colors.transparent,
// //                   _dominantColor.withOpacity(0.15),
// //                   Colors.transparent,
// //                 ],
// //                 stops: [0.0, 0.5, 1.0],
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildSeriesBadge() {
// //     return Positioned(
// //       top: 8,
// //       right: 8,
// //       child: Container(
// //         padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
// //         decoration: BoxDecoration(
// //           color: Colors.black.withOpacity(0.8),
// //           borderRadius: BorderRadius.circular(6),
// //         ),
// //         child: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Icon(
// //               Icons.tv,
// //               color: Colors.white,
// //               size: 8,
// //             ),
// //             SizedBox(width: 2),
// //             Text(
// //               'SERIES',
// //               style: TextStyle(
// //                 color: Colors.white,
// //                 fontSize: 8,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildHoverOverlay() {
// //     return Positioned.fill(
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [
// //               Colors.transparent,
// //               _dominantColor.withOpacity(0.1),
// //             ],
// //           ),
// //         ),
// //         child: Center(
// //           child: Container(
// //             padding: EdgeInsets.all(10),
// //             decoration: BoxDecoration(
// //               color: Colors.black.withOpacity(0.7),
// //               borderRadius: BorderRadius.circular(25),
// //             ),
// //             child: Icon(
// //               Icons.play_arrow_rounded,
// //               color: Colors.white,
// //               size: 30,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildProfessionalTitle(double screenWidth) {
// //     final seriesName =
// //         widget.webSeries['name']?.toString()?.toUpperCase() ?? 'UNKNOWN';

// //     return Container(
// //       width: screenWidth * 0.18,
// //       child: AnimatedDefaultTextStyle(
// //         duration: WebSeriesAnimationTiming.medium,
// //         style: TextStyle(
// //           fontSize: _isFocused ? 13 : 11,
// //           fontWeight: FontWeight.w600,
// //           color: _isFocused
// //               ? _dominantColor
// //               : ProfessionalWebSeriesColors.textPrimary,
// //           letterSpacing: 0.5,
// //           shadows: _isFocused
// //               ? [
// //                   Shadow(
// //                     color: _dominantColor.withOpacity(0.6),
// //                     blurRadius: 10,
// //                     offset: Offset(0, 2),
// //                   ),
// //                 ]
// //               : [],
// //         ),
// //         child: Text(
// //           seriesName,
// //           textAlign: TextAlign.center,
// //           maxLines: 2,
// //           overflow: TextOverflow.ellipsis,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // Enhanced View All Button for WebSeries
// // class ProfessionalWebSeriesViewAllButton extends StatefulWidget {
// //   final FocusNode focusNode;
// //   final VoidCallback onTap;
// //   final String categoryText;
// //   final int totalSeries;

// //   const ProfessionalWebSeriesViewAllButton({
// //     Key? key,
// //     required this.focusNode,
// //     required this.onTap,
// //     required this.categoryText,
// //     required this.totalSeries,
// //   }) : super(key: key);

// //   @override
// //   _ProfessionalWebSeriesViewAllButtonState createState() =>
// //       _ProfessionalWebSeriesViewAllButtonState();
// // }

// // class _ProfessionalWebSeriesViewAllButtonState
// //     extends State<ProfessionalWebSeriesViewAllButton>
// //     with TickerProviderStateMixin {
// //   late AnimationController _scaleController;
// //   late AnimationController _glowController;
// //   late AnimationController _shimmerController;
// //   late AnimationController _breathingController;

// //   late Animation<double> _scaleAnimation;
// //   late Animation<double> _glowAnimation;
// //   late Animation<double> _shimmerAnimation;
// //   late Animation<double> _breathingAnimation;

// //   bool _isFocused = false;
// //   Color _currentColor = ProfessionalWebSeriesColors.accentBlue;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _scaleController = AnimationController(
// //       duration: WebSeriesAnimationTiming.focus,
// //       vsync: this,
// //     );

// //     _glowController = AnimationController(
// //       duration: WebSeriesAnimationTiming.medium,
// //       vsync: this,
// //     );

// //     _shimmerController = AnimationController(
// //       duration: Duration(milliseconds: 2000),
// //       vsync: this,
// //     );

// //     _breathingController = AnimationController(
// //       duration: Duration(milliseconds: 3000),
// //       vsync: this,
// //     )..repeat(reverse: true);

// //     _scaleAnimation = Tween<double>(
// //       begin: 1.0,
// //       end: 1.04,
// //     ).animate(CurvedAnimation(
// //       parent: _scaleController,
// //       curve: Curves.easeOutCubic,
// //     ));

// //     _glowAnimation = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(CurvedAnimation(
// //       parent: _glowController,
// //       curve: Curves.easeInOut,
// //     ));

// //     _shimmerAnimation = Tween<double>(
// //       begin: -1.0,
// //       end: 2.0,
// //     ).animate(CurvedAnimation(
// //       parent: _shimmerController,
// //       curve: Curves.easeInOut,
// //     ));

// //     _breathingAnimation = Tween<double>(
// //       begin: 0.95,
// //       end: 1.02,
// //     ).animate(CurvedAnimation(
// //       parent: _breathingController,
// //       curve: Curves.easeInOut,
// //     ));

// //     widget.focusNode.addListener(_handleFocusChange);
// //   }

// //   void _handleFocusChange() {
// //     setState(() {
// //       _isFocused = widget.focusNode.hasFocus;
// //       if (_isFocused) {
// //         _currentColor = ProfessionalWebSeriesColors.gradientColors[math.Random()
// //             .nextInt(ProfessionalWebSeriesColors.gradientColors.length)];
// //         HapticFeedback.mediumImpact();
// //       }
// //     });

// //     if (_isFocused) {
// //       _scaleController.forward();
// //       _glowController.forward();
// //       _shimmerController.repeat();
// //     } else {
// //       _scaleController.reverse();
// //       _glowController.reverse();
// //       _shimmerController.stop();
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _scaleController.dispose();
// //     _glowController.dispose();
// //     _shimmerController.dispose();
// //     _breathingController.dispose();
// //     widget.focusNode.removeListener(_handleFocusChange);
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final screenWidth = MediaQuery.of(context).size.width;
// //     final screenHeight = MediaQuery.of(context).size.height;

// //     return Container(
// //       width: screenWidth * 0.19,
// //       margin: EdgeInsets.symmetric(horizontal: 15),
// //       child: Column(
// //         children: [
// //           AnimatedBuilder(
// //             animation: Listenable.merge([
// //               _scaleAnimation,
// //               _glowAnimation,
// //               _breathingAnimation,
// //             ]),
// //             builder: (context, child) {
// //               return Transform.scale(
// //                 scale: _isFocused
// //                     ? _scaleAnimation.value
// //                     : _breathingAnimation.value,
// //                 child: Container(
// //                   height: _isFocused ? screenHeight * 0.3 : screenHeight * 0.25,
// //                   decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(12),
// //                     boxShadow: [
// //                       if (_isFocused) ...[
// //                         BoxShadow(
// //                           color: _currentColor.withOpacity(0.4),
// //                           blurRadius: 25,
// //                           spreadRadius: 3,
// //                           offset: Offset(0, 8),
// //                         ),
// //                       ] else ...[
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.4),
// //                           blurRadius: 10,
// //                           offset: Offset(0, 5),
// //                         ),
// //                       ],
// //                     ],
// //                   ),
// //                   child: ClipRRect(
// //                     borderRadius: BorderRadius.circular(12),
// //                     child: Stack(
// //                       children: [
// //                         _buildWebSeriesStyleBackground(),
// //                         if (_isFocused) _buildFocusBorder(),
// //                         if (_isFocused) _buildShimmerEffect(),
// //                         _buildCenterContent(),
// //                         _buildQualityBadge(),
// //                         if (_isFocused) _buildHoverOverlay(),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //           SizedBox(height: 10),
// //           _buildAdvancedTitle(),
// //         ],
// //       ),
// //     );
// //   }

// //   // Widget _buildWebSeriesStyleBackground() {
// //   //   return Container(
// //   //     decoration: BoxDecoration(
// //   //       gradient: LinearGradient(
// //   //         begin: Alignment.topLeft,
// //   //         end: Alignment.bottomRight,
// //   //         colors: _isFocused
// //   //             ? [
// //   //                 _currentColor.withOpacity(0.8),
// //   //                 _currentColor.withOpacity(0.6),
// //   //                 ProfessionalWebSeriesColors.cardDark.withOpacity(0.9),
// //   //               ]
// //   //             : [
// //   //                 ProfessionalWebSeriesColors.cardDark,
// //   //                 ProfessionalWebSeriesColors.surfaceDark,
// //   //                 ProfessionalWebSeriesColors.cardDark.withOpacity(0.8),
// //   //               ],
// //   //       ),
// //   //     ),
// //   //     child: Container(
// //   //       decoration: BoxDecoration(
// //   //         gradient: LinearGradient(
// //   //           begin: Alignment.topCenter,
// //   //           end: Alignment.bottomCenter,
// //   //           colors: [
// //   //             Colors.transparent,
// //   //             Colors.black.withOpacity(0.1),
// //   //             Colors.black.withOpacity(0.3),
// //   //           ],
// //   //         ),
// //   //       ),
// //   //     ),
// //   //   );
// //   // }

// //   Widget _buildWebSeriesStyleBackground() {
// //     return Container(
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: _isFocused
// //               ? [
// //                   _currentColor.withOpacity(0.8),
// //                   _currentColor.withOpacity(0.6),
// //                   ProfessionalWebSeriesColors.cardDark.withOpacity(0.9),
// //                 ]
// //               : [
// //                   ProfessionalWebSeriesColors.cardDark,
// //                   ProfessionalWebSeriesColors.surfaceDark,
// //                   ProfessionalWebSeriesColors.cardDark.withOpacity(0.8),
// //                 ],
// //         ),
// //       ),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [
// //               Colors.transparent,
// //               Colors.black.withOpacity(0.1),
// //               Colors.black.withOpacity(0.3),
// //             ],
// //           ),
// //         ),
// //         // Add subtle pattern or texture
// //         child: CustomPaint(
// //           painter: _isFocused ? GridPatternPainter(_currentColor) : null,
// //           child: Container(),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildFocusBorder() {
// //     return Positioned.fill(
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(
// //             width: 3,
// //             color: _currentColor,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildShimmerEffect() {
// //     return AnimatedBuilder(
// //       animation: _shimmerAnimation,
// //       builder: (context, child) {
// //         return Positioned.fill(
// //           child: Container(
// //             decoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(12),
// //               gradient: LinearGradient(
// //                 begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
// //                 end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
// //                 colors: [
// //                   Colors.transparent,
// //                   _currentColor.withOpacity(0.15),
// //                   Colors.transparent,
// //                 ],
// //                 stops: [0.0, 0.5, 1.0],
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildCenterContent() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             padding: EdgeInsets.all(12),
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               color: Colors.white.withOpacity(_isFocused ? 0.2 : 0.1),
// //               border: Border.all(
// //                 color: Colors.white.withOpacity(_isFocused ? 0.4 : 0.2),
// //                 width: 2,
// //               ),
// //             ),
// //             child: Icon(
// //               Icons.tv_rounded,
// //               size: _isFocused ? 45 : 35,
// //               color: Colors.white,
// //             ),
// //           ),
// //           SizedBox(height: 12),
// //           Text(
// //             'VIEW ALL',
// //             style: TextStyle(
// //               color: Colors.white,
// //               fontSize: _isFocused ? 14 : 12,
// //               fontWeight: FontWeight.bold,
// //               letterSpacing: 1.5,
// //               shadows: [
// //                 Shadow(
// //                   color: _isFocused
// //                       ? _currentColor.withOpacity(0.6)
// //                       : Colors.black.withOpacity(0.5),
// //                   blurRadius: _isFocused ? 8 : 4,
// //                   offset: Offset(0, 2),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           SizedBox(height: 6),
// //           Container(
// //             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 colors: _isFocused
// //                     ? [
// //                         _currentColor.withOpacity(0.3),
// //                         _currentColor.withOpacity(0.1),
// //                       ]
// //                     : [
// //                         Colors.white.withOpacity(0.25),
// //                         Colors.white.withOpacity(0.1),
// //                       ],
// //               ),
// //               borderRadius: BorderRadius.circular(15),
// //               border: Border.all(
// //                 color: _isFocused
// //                     ? _currentColor.withOpacity(0.5)
// //                     : Colors.white.withOpacity(0.3),
// //                 width: 1,
// //               ),
// //             ),
// //             child: Text(
// //               '${widget.totalSeries}',
// //               style: TextStyle(
// //                 color: Colors.white,
// //                 fontSize: 11,
// //                 fontWeight: FontWeight.w700,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildQualityBadge() {
// //     return Positioned(
// //       top: 8,
// //       right: 8,
// //       child: Container(
// //         padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
// //         decoration: BoxDecoration(
// //           color: Colors.black.withOpacity(0.8),
// //           borderRadius: BorderRadius.circular(6),
// //         ),
// //         child: Text(
// //           'ALL',
// //           style: TextStyle(
// //             color: Colors.white,
// //             fontSize: 9,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildHoverOverlay() {
// //     return Positioned.fill(
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(12),
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [
// //               Colors.transparent,
// //               _currentColor.withOpacity(0.1),
// //             ],
// //           ),
// //         ),
// //         child: Center(
// //           child: Container(
// //             padding: EdgeInsets.all(10),
// //             decoration: BoxDecoration(
// //               color: Colors.black.withOpacity(0.7),
// //               borderRadius: BorderRadius.circular(25),
// //             ),
// //             child: Icon(
// //               Icons.explore_rounded,
// //               color: Colors.white,
// //               size: 30,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildAdvancedTitle() {
// //     return Container(
// //       width: MediaQuery.of(context).size.width * 0.18,
// //       child: AnimatedDefaultTextStyle(
// //         duration: WebSeriesAnimationTiming.medium,
// //         style: TextStyle(
// //           fontSize: _isFocused ? 13 : 11,
// //           fontWeight: FontWeight.w600,
// //           color: _isFocused
// //               ? _currentColor
// //               : ProfessionalWebSeriesColors.textPrimary,
// //           letterSpacing: 0.5,
// //           shadows: _isFocused
// //               ? [
// //                   Shadow(
// //                     color: _currentColor.withOpacity(0.6),
// //                     blurRadius: 10,
// //                     offset: Offset(0, 2),
// //                   ),
// //                 ]
// //               : [],
// //         ),
// //         child: Text(
// //           widget.categoryText.toUpperCase(),
// //           textAlign: TextAlign.center,
// //           maxLines: 2,
// //           overflow: TextOverflow.ellipsis,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class GridPatternPainter extends CustomPainter {
// //   final Color color;

// //   GridPatternPainter(this.color);

// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final paint = Paint()
// //       ..color = color.withOpacity(0.1)
// //       ..strokeWidth = 1
// //       ..style = PaintingStyle.stroke;

// //     final spacing = 20.0;

// //     // Draw grid pattern
// //     for (double i = 0; i < size.width; i += spacing) {
// //       canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
// //     }

// //     for (double i = 0; i < size.height; i += spacing) {
// //       canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
// //     }
// //   }

// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// // }

// // // Enhanced Main WebSeries Screen - COMPLETE WIDGET
// // class ProfessionalManageWebseries extends StatefulWidget {
// //   final FocusNode focusNode;
// //   const ProfessionalManageWebseries({Key? key, required this.focusNode})
// //       : super(key: key);

// //   @override
// //   _ProfessionalManageWebseriesState createState() =>
// //       _ProfessionalManageWebseriesState();
// // }

// // class _ProfessionalManageWebseriesState
// //     extends State<ProfessionalManageWebseries>
// //     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
// //   @override
// //   bool get wantKeepAlive => true;

// //   // Data
// //   List<Map<String, dynamic>> categories = [];
// //   bool isLoading = true;
// //   String debugMessage = "";

// //   // Animation Controllers
// //   late AnimationController _headerAnimationController;
// //   late AnimationController _categoryAnimationController;
// //   late Animation<Offset> _headerSlideAnimation;
// //   late Animation<double> _categoryFadeAnimation;

// //   // Focus Management
// //   Map<String, Map<String, FocusNode>> focusNodesMap = {};
// //   Map<String, FocusNode> viewAllFocusNodes = {}; // 🔧 ViewAll focus nodes map
// //   final ScrollController _scrollController = ScrollController();

// //   // Services
// //   final PaletteColorService _paletteColorService = PaletteColorService();

// //   @override
// //   void initState() {
// //     super.initState();

// //     _initializeAnimations();
// //     _loadCachedWebseriesDataAndFetch();

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       Provider.of<FocusProvider>(context, listen: false)
// //           .setwebseriesScrollController(_scrollController);
// //     });
// //   }

// //   void _initializeAnimations() {
// //     _headerAnimationController = AnimationController(
// //       duration: WebSeriesAnimationTiming.slow,
// //       vsync: this,
// //     );

// //     _categoryAnimationController = AnimationController(
// //       duration: WebSeriesAnimationTiming.slow,
// //       vsync: this,
// //     );

// //     _headerSlideAnimation = Tween<Offset>(
// //       begin: Offset(0, -1),
// //       end: Offset.zero,
// //     ).animate(CurvedAnimation(
// //       parent: _headerAnimationController,
// //       curve: Curves.easeOutCubic,
// //     ));

// //     _categoryFadeAnimation = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(CurvedAnimation(
// //       parent: _categoryAnimationController,
// //       curve: Curves.easeInOut,
// //     ));
// //   }

// //   void _initializeFocusNodes() {
// //     focusNodesMap.clear();
// //     viewAllFocusNodes.clear(); // 🔧 Clear ViewAll nodes too

// //     for (var cat in categories) {
// //       final catId = '${cat['id']}';
// //       focusNodesMap[catId] = {};

// //       // 🔧 CREATE: ViewAll focus node for each category
// //       viewAllFocusNodes[catId] = FocusNode(debugLabel: 'viewAll_$catId');

// //       final webSeriesList = cat['web_series'] as List<dynamic>;

// //       for (int idx = 0; idx < webSeriesList.length; idx++) {
// //         final series = webSeriesList[idx];
// //         final seriesId = '${series['id']}';

// //         final focusNode =
// //             FocusNode(debugLabel: 'webseries_${catId}_${seriesId}_$idx');

// //         focusNode.addListener(() {
// //           if (focusNode.hasFocus && mounted && _scrollController.hasClients) {
// //             WidgetsBinding.instance.addPostFrameCallback((_) {
// //               _performReliableScroll(itemIndex: idx);
// //             });
// //           }
// //         });

// //         focusNodesMap[catId]![seriesId] = focusNode;
// //       }
// //     }
// //   }

// //   void _performReliableScroll({required int itemIndex}) {
// //     if (!mounted || !_scrollController.hasClients) return;

// //     try {
// //       final double itemWidth = MediaQuery.of(context).size.width * 0.19;
// //       final double horizontalPadding = 6.0; // Your margin
// //       final double totalItemWidth = itemWidth + (horizontalPadding * 2);

// //       final double targetOffset = itemIndex * totalItemWidth;
// //       final double maxOffset = _scrollController.position.maxScrollExtent;
// //       final double clampedOffset = targetOffset.clamp(0.0, maxOffset);

// //       _scrollController
// //           .animateTo(
// //             clampedOffset,
// //             duration: WebSeriesAnimationTiming.scroll,
// //             curve: Curves.easeInOutCubic,
// //           )
// //           .then((_) {})
// //           .catchError((error) {});
// //     } catch (e) {}
// //   }

// //   List<dynamic> _sortByIndex(List<dynamic> list) {
// //     try {
// //       list.sort((a, b) {
// //         dynamic indexA = a['index'];
// //         dynamic indexB = b['index'];

// //         int numA = 0;
// //         int numB = 0;

// //         if (indexA is int) {
// //           numA = indexA;
// //         } else if (indexA is String) {
// //           numA = int.tryParse(indexA) ?? 0;
// //         }

// //         if (indexB is int) {
// //           numB = indexB;
// //         } else if (indexB is String) {
// //           numB = int.tryParse(indexB) ?? 0;
// //         }

// //         return numA.compareTo(numB);
// //       });

// //       return list;
// //     } catch (e) {
// //       return list;
// //     }
// //   }

// //   // REPLACE this entire method:
// //   Future<void> _loadCachedWebseriesDataAndFetch() async {
// //     setState(() {
// //       isLoading = true;
// //       debugMessage = '';
// //     });

// //     try {
// //       // Step 1: Load cached data first
// //       await _loadCachedWebseriesData();

// //       // Step 2: If no cached data or empty categories, fetch fresh data
// //       if (categories.isEmpty) {
// //         await _fetchWebseriesDirectly();
// //       } else {
// //         await _fetchWebseriesInBackground();
// //       }

// //       // Start animations after data loads
// //       _headerAnimationController.forward();
// //       _categoryAnimationController.forward();
// //     } catch (e) {
// //       setState(() {
// //         debugMessage = "Failed to load webseries: $e";
// //         isLoading = false;
// //       });
// //     }
// //   }

// // // ADD this new method:
// //   Future<void> _loadCachedWebseriesData() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final cached = prefs.getString('webseries_list');

// //       if (cached != null && cached.isNotEmpty) {
// //         final List<dynamic> cachedData = jsonDecode(cached);
// //         setState(() {
// //           categories = List<Map<String, dynamic>>.from(cachedData);
// //           _initializeFocusNodes();
// //           isLoading = false;
// //         });
// //         _registerWebseriesFocus();
// //       } else {}
// //     } catch (e) {
// //       setState(() {
// //         debugMessage = 'Error loading cached data: $e';
// //       });
// //     }
// //   }

// // // ADD this new method:
// //   Future<void> _fetchWebseriesDirectly() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       String authKey = AuthManager.authKey;
// //       if (authKey.isEmpty) {
// //         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
// //       }

// //       final response = await http.get(
// //         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
// //         headers: {
// //           'auth-key': authKey,
// //           'Content-Type': 'application/json',
// //           'Accept': 'application/json',
// //         },
// //       );

// //       if (response.statusCode == 200 && response.body.isNotEmpty) {
// //         final List<dynamic> flatData = jsonDecode(response.body);

// //         if (flatData.isNotEmpty) {
// //           final Map<String, List<dynamic>> grouped = {'Web Series': flatData};
// //           final List<Map<String, dynamic>> newCats = [];

// //           for (var entry in grouped.entries) {
// //             try {
// //               final sortedItems = _sortByIndex(List.from(entry.value));
// //               newCats.add({
// //                 'id': '1',
// //                 'category': entry.key,
// //                 'web_series': sortedItems,
// //               });
// //             } catch (e) {
// //               newCats.add({
// //                 'id': '1',
// //                 'category': entry.key,
// //                 'web_series': entry.value,
// //               });
// //             }
// //           }

// //           if (mounted) {
// //             setState(() {
// //               categories = newCats;
// //               _initializeFocusNodes();
// //               isLoading = false;
// //               debugMessage = '';
// //             });

// //             // Save to cache for next time
// //             final newJson = jsonEncode(newCats);
// //             await prefs.setString('webseries_list', newJson);

// //             _registerWebseriesFocus();
// //           }
// //         } else {
// //           throw Exception('Empty data received from API');
// //         }
// //       } else {
// //         throw Exception('API error: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       rethrow;
// //     }
// //   }

// // // REPLACE the existing _fetchWebseriesInBackground method with:
// //   Future<void> _fetchWebseriesInBackground() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       String authKey = AuthManager.authKey;
// //       if (authKey.isEmpty) {
// //         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
// //       }

// //       final response = await http.get(
// //         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
// //         headers: {
// //           'auth-key': authKey,
// //           'Content-Type': 'application/json',
// //           'Accept': 'application/json',
// //         },
// //       );

// //       if (response.statusCode == 200 && response.body.isNotEmpty) {
// //         final List<dynamic> flatData = jsonDecode(response.body);

// //         if (flatData.isNotEmpty) {
// //           final Map<String, List<dynamic>> grouped = {'Web Series': flatData};
// //           final List<Map<String, dynamic>> newCats = [];

// //           for (var entry in grouped.entries) {
// //             try {
// //               final sortedItems = _sortByIndex(List.from(entry.value));
// //               newCats.add({
// //                 'id': '1',
// //                 'category': entry.key,
// //                 'web_series': sortedItems,
// //               });
// //             } catch (e) {
// //               newCats.add({
// //                 'id': '1',
// //                 'category': entry.key,
// //                 'web_series': entry.value,
// //               });
// //             }
// //           }

// //           final newJson = jsonEncode(newCats);
// //           final cached = prefs.getString('webseries_list');

// //           if (cached == null || cached != newJson) {
// //             await prefs.setString('webseries_list', newJson);

// //             if (mounted) {
// //               setState(() {
// //                 categories = newCats;
// //                 _initializeFocusNodes();
// //               });
// //               _registerWebseriesFocus();
// //             }
// //           } else {}
// //         }
// //       }
// //     } catch (e) {
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           isLoading = false;
// //         });
// //       }
// //     }
// //   }

// //   // Future<void> _fetchWebseriesInBackground() async {
// //   //   try {
// //   //     final prefs = await SharedPreferences.getInstance();
// //   //     String authKey = AuthManager.authKey;
// //   //     if (authKey.isEmpty) {
// //   //       authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
// //   //     }

// //   //     final response = await http.get(
// //   //       Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
// //   //       headers: {
// //   //         'auth-key': authKey,
// //   //         'Content-Type': 'application/json',
// //   //         'Accept': 'application/json',
// //   //       },
// //   //     );

// //   //     if (response.statusCode == 200 && response.body.isNotEmpty) {
// //   //       final List<dynamic> flatData = jsonDecode(response.body);

// //   //       if (flatData.isNotEmpty) {
// //   //         final Map<String, List<dynamic>> grouped = {'Web Series': flatData};
// //   //         final List<Map<String, dynamic>> newCats = [];

// //   //         for (var entry in grouped.entries) {
// //   //           try {
// //   //             final sortedItems = _sortByIndex(List.from(entry.value));
// //   //             newCats.add({
// //   //               'id': '1',
// //   //               'category': entry.key,
// //   //               'web_series': sortedItems,
// //   //             });
// //   //           } catch (e) {
// //   //             newCats.add({
// //   //               'id': '1',
// //   //               'category': entry.key,
// //   //               'web_series': entry.value,
// //   //             });
// //   //           }
// //   //         }

// //   //         try {
// //   //           final newJson = jsonEncode(newCats);
// //   //           final cached = prefs.getString('webseries_list');

// //   //           if (cached == null || cached != newJson) {
// //   //             await prefs.setString('webseries_list', newJson);

// //   //             if (mounted) {
// //   //               setState(() {
// //   //                 categories = newCats;
// //   //                 _initializeFocusNodes();
// //   //               });
// //   //               _registerWebseriesFocus();
// //   //             }
// //   //           }
// //   //         } catch (e) {
// //   //           if (mounted) {
// //   //             setState(() {
// //   //               categories = newCats;
// //   //               _initializeFocusNodes();
// //   //             });
// //   //             _registerWebseriesFocus();
// //   //           }
// //   //         }
// //   //       }
// //   //     }
// //   //   } catch (e) {
// //   //   } finally {
// //   //     if (mounted) {
// //   //       setState(() {
// //   //         isLoading = false;
// //   //       });
// //   //     }
// //   //   }
// //   // }

// //   // Future<void> _loadCachedWebseriesDataAndFetch() async {
// //   //   setState(() {
// //   //     isLoading = true;
// //   //     debugMessage = '';
// //   //   });

// //   //   try {
// //   //     final prefs = await SharedPreferences.getInstance();
// //   //     final cached = prefs.getString('webseries_list');
// //   //     if (cached != null) {
// //   //       final List<dynamic> cachedData = jsonDecode(cached);
// //   //       setState(() {
// //   //         categories = List<Map<String, dynamic>>.from(cachedData);
// //   //         _initializeFocusNodes();
// //   //         isLoading = false;
// //   //       });

// //   //       // Start animations after cached data loads
// //   //       _headerAnimationController.forward();
// //   //       _categoryAnimationController.forward();
// //   //       _registerWebseriesFocus();
// //   //     }

// //   //     await _fetchWebseriesInBackground();
// //   //   } catch (e) {
// //   //     setState(() {
// //   //       debugMessage = "Failed to load webseries";
// //   //       isLoading = false;
// //   //     });
// //   //   }
// //   // }

// //   void _registerWebseriesFocus() {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (categories.isNotEmpty && mounted) {
// //         final firstCid = '${categories[0]['id']}';
// //         final firstWebSeries = categories[0]['web_series'] as List<dynamic>;
// //         if (firstWebSeries.isNotEmpty) {
// //           final firstSid = '${firstWebSeries[0]['id']}';
// //           final node = focusNodesMap[firstCid]?[firstSid];
// //           if (node != null) {
// //             context
// //                 .read<FocusProvider>()
// //                 .setFirstManageWebseriesFocusNode(node);
// //           }
// //         }
// //       }
// //     });
// //   }

// //   void navigateToDetails(dynamic webSeries, String source, String banner,
// //       String name, int categoryIndex) {
// //     final List<NewsItemModel> channelList =
// //         (categories[categoryIndex]['web_series'] as List<dynamic>)
// //             .map((m) => NewsItemModel(
// //                   id: m['id']?.toString() ?? '',
// //                   name: m['name']?.toString() ?? '',
// //                   poster: m['poster']?.toString() ?? '',
// //                   banner: m['banner']?.toString() ?? '',
// //                   description: m['description']?.toString() ?? '',
// //                   category: source,
// //                   index: '',
// //                   url: '',
// //                   videoId: '',
// //                   streamType: '',
// //                   type: '',
// //                   genres: '',
// //                   status: '',
// //                   image: '',
// //                   unUpdatedUrl: '',
// //                 ))
// //             .toList();

// //     int seriesId;
// //     if (webSeries['id'] is int) {
// //       seriesId = webSeries['id'];
// //     } else if (webSeries['id'] is String) {
// //       try {
// //         seriesId = int.parse(webSeries['id']);
// //       } catch (e) {
// //         return;
// //       }
// //     } else {
// //       return;
// //     }

// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => WebSeriesDetailsPage(
// //           id: seriesId,
// //           // channelList: channelList,
// //           // source: 'manage-web_series',
// //           banner: banner,
// //           poster: webSeries['poster']?.toString() ?? '',
// //           name: name,
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _headerAnimationController.dispose();
// //     _categoryAnimationController.dispose();

// //     // 🔧 DISPOSE: ViewAll focus nodes
// //     for (var node in viewAllFocusNodes.values) {
// //       try {
// //         node.dispose();
// //       } catch (e) {}
// //     }

// //     for (var categoryNodes in focusNodesMap.values) {
// //       for (var node in categoryNodes.values) {
// //         try {
// //           node.dispose();
// //         } catch (e) {}
// //       }
// //     }

// //     try {
// //       _scrollController.dispose();
// //     } catch (e) {}

// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     super.build(context);

// //     return Consumer<ColorProvider>(
// //       builder: (context, colorProv, child) {
// //         final bgColor = colorProv.isItemFocused
// //             ? colorProv.dominantColor.withOpacity(0.1)
// //             : ProfessionalWebSeriesColors.primaryDark;

// //         return Container(
// //           decoration: BoxDecoration(
// //             gradient: LinearGradient(
// //               begin: Alignment.topCenter,
// //               end: Alignment.bottomCenter,
// //               colors: [
// //                 bgColor,
// //                 ProfessionalWebSeriesColors.primaryDark,
// //                 ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.5),
// //               ],
// //             ),
// //           ),
// //           child: Column(
// //             children: [
// //               // SizedBox(height: screenhgt * 0.02),
// //               // _buildProfessionalTitle(),
// //               SizedBox(height: screenhgt * 0.01),
// //               Expanded(child: _buildBody()),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildProfessionalTitle() {
// //     return SlideTransition(
// //       position: _headerSlideAnimation,
// //       child: Container(
// //         padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             ShaderMask(
// //               shaderCallback: (bounds) => LinearGradient(
// //                 colors: [
// //                   ProfessionalWebSeriesColors.accentPurple,
// //                   ProfessionalWebSeriesColors.accentBlue,
// //                 ],
// //               ).createShader(bounds),
// //               child: Text(
// //                 'WEB SERIES',
// //                 style: TextStyle(
// //                   fontSize: Headingtextsz,
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.w700,
// //                   letterSpacing: 2.0,
// //                 ),
// //               ),
// //             ),
// //             if (categories.isNotEmpty)
// //               Container(
// //                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //                 decoration: BoxDecoration(
// //                   gradient: LinearGradient(
// //                     colors: [
// //                       ProfessionalWebSeriesColors.accentPurple.withOpacity(0.2),
// //                       ProfessionalWebSeriesColors.accentBlue.withOpacity(0.2),
// //                     ],
// //                   ),
// //                   borderRadius: BorderRadius.circular(20),
// //                   border: Border.all(
// //                     color: ProfessionalWebSeriesColors.accentPurple
// //                         .withOpacity(0.3),
// //                     width: 1,
// //                   ),
// //                 ),
// //                 child: Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     Icon(
// //                       Icons.tv,
// //                       size: 14,
// //                       color: ProfessionalWebSeriesColors.textSecondary,
// //                     ),
// //                     SizedBox(width: 6),
// //                     Text(
// //                       '${_getTotalSeriesCount()} Series',
// //                       style: TextStyle(
// //                         color: ProfessionalWebSeriesColors.textSecondary,
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   int _getTotalSeriesCount() {
// //     int total = 0;
// //     for (var category in categories) {
// //       total += (category['web_series'] as List<dynamic>).length;
// //     }
// //     return total;
// //   }

// //   Widget _buildBody() {
// //     if (isLoading) {
// //       return _buildProfessionalLoadingIndicator();
// //     } else if (categories.isEmpty) {
// //       return _buildNoDataWidget();
// //     } else {
// //       return _buildCategoriesList();
// //     }
// //   }

// //   Widget _buildProfessionalLoadingIndicator() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 70,
// //             height: 70,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               gradient: SweepGradient(
// //                 colors: [
// //                   ProfessionalWebSeriesColors.accentPurple,
// //                   ProfessionalWebSeriesColors.accentBlue,
// //                   ProfessionalWebSeriesColors.accentGreen,
// //                   ProfessionalWebSeriesColors.accentPurple,
// //                 ],
// //               ),
// //             ),
// //             child: Container(
// //               margin: EdgeInsets.all(5),
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 color: ProfessionalWebSeriesColors.primaryDark,
// //               ),
// //               child: Icon(
// //                 Icons.tv_rounded,
// //                 color: ProfessionalWebSeriesColors.textPrimary,
// //                 size: 28,
// //               ),
// //             ),
// //           ),
// //           SizedBox(height: 24),
// //           Text(
// //             'Loading Web Series...',
// //             style: TextStyle(
// //               color: ProfessionalWebSeriesColors.textPrimary,
// //               fontSize: 16,
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //           SizedBox(height: 12),
// //           Container(
// //             width: 200,
// //             height: 3,
// //             decoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(2),
// //               color: ProfessionalWebSeriesColors.surfaceDark,
// //             ),
// //             child: LinearProgressIndicator(
// //               backgroundColor: Colors.transparent,
// //               valueColor: AlwaysStoppedAnimation<Color>(
// //                 ProfessionalWebSeriesColors.accentPurple,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildNoDataWidget() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 80,
// //             height: 80,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               gradient: LinearGradient(
// //                 colors: [
// //                   ProfessionalWebSeriesColors.accentPurple.withOpacity(0.2),
// //                   ProfessionalWebSeriesColors.accentPurple.withOpacity(0.1),
// //                 ],
// //               ),
// //             ),
// //             child: Icon(
// //               Icons.tv_off,
// //               size: 40,
// //               color: ProfessionalWebSeriesColors.accentPurple,
// //             ),
// //           ),
// //           SizedBox(height: 24),
// //           Text(
// //             'No Web Series Found',
// //             style: TextStyle(
// //               color: ProfessionalWebSeriesColors.textPrimary,
// //               fontSize: 18,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //           SizedBox(height: 8),
// //           Text(
// //             'Check back later for new content',
// //             style: TextStyle(
// //               color: ProfessionalWebSeriesColors.textSecondary,
// //               fontSize: 14,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildCategoriesList() {
// //     return FadeTransition(
// //       opacity: _categoryFadeAnimation,
// //       child: SingleChildScrollView(
// //         physics: const BouncingScrollPhysics(),
// //         child: Column(
// //           children: List.generate(categories.length, (catIdx) {
// //             final cat = categories[catIdx];
// //             final list = cat['web_series'] as List<dynamic>;
// //             final catId = '${cat['id']}';

// //             return _buildCategorySection(cat, list, catId, catIdx);
// //           }),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildCategorySection(Map<String, dynamic> category,
// //       List<dynamic> seriesList, String categoryId, int categoryIndex) {
// //     // 🔧 GET: ViewAll focus node from the map instead of creating new
// //     final viewAllFocusNode = viewAllFocusNodes[categoryId]!;

// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         _buildCategoryHeader(category),
// //         SizedBox(
// //           height: MediaQuery.of(context).size.height * 0.38,
// //           child: ListView.builder(
// //             key: ValueKey('webseries_listview_$categoryId'),
// //             controller: _scrollController,
// //             scrollDirection: Axis.horizontal,
// //             physics: const BouncingScrollPhysics(),
// //             clipBehavior: Clip.none,
// //             padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
// //             cacheExtent: 1200,
// //             itemCount: seriesList.length > 7 ? 8 : seriesList.length + 1,
// //             itemBuilder: (context, idx) {
// //               if ((seriesList.length >= 7 && idx == 7) ||
// //                   (seriesList.length < 7 && idx == seriesList.length)) {
// //                 return _buildEnhancedViewAllButton(
// //                     category, seriesList, viewAllFocusNode, categoryIndex);
// //               }

// //               final item = seriesList[idx];
// //               final seriesId = '${item['id']}';
// //               final node = focusNodesMap[categoryId]?[seriesId];

// //               return _buildEnhancedWebSeriesItem(
// //                   item, node, categoryIndex, idx, viewAllFocusNode, seriesList);
// //             },
// //           ),
// //         ),
// //         const SizedBox(height: 20),
// //       ],
// //     );
// //   }

// //   Widget _buildEnhancedWebSeriesItem(
// //       dynamic webSeries,
// //       FocusNode? node,
// //       int categoryIndex,
// //       int itemIndex,
// //       FocusNode viewAllFocusNode,
// //       List<dynamic> seriesList) {
// //     if (node == null) return SizedBox.shrink();

// //     return Focus(
// //       focusNode: node,
// //       onFocusChange: (hasFocus) async {
// //         if (hasFocus && mounted) {
// //           try {
// //             Color dominantColor = await _paletteColorService.getSecondaryColor(
// //               webSeries['poster']?.toString() ?? '',
// //               fallbackColor: ProfessionalWebSeriesColors.accentPurple,
// //             );
// //             if (mounted) {
// //               context.read<ColorProvider>().updateColor(dominantColor, true);
// //             }
// //           } catch (e) {
// //             if (mounted) {
// //               context
// //                   .read<ColorProvider>()
// //                   .updateColor(ProfessionalWebSeriesColors.accentPurple, true);
// //             }
// //           }
// //           _performReliableScroll(itemIndex: itemIndex);
// //         } else if (mounted) {
// //           context.read<ColorProvider>().resetColor();
// //         }
// //       },
// //       onKey: (FocusNode focusNode, RawKeyEvent event) {
// //         if (event is RawKeyDownEvent) {
// //           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
// //             // 🔧 CRITICAL FIX: Proper last index calculation
// //             int lastDisplayedIndex = math.min(6, seriesList.length - 1);

// //             if (itemIndex < lastDisplayedIndex) {
// //               // Normal navigation to next series
// //               if (itemIndex + 1 < seriesList.length) {
// //                 String nextSeriesId =
// //                     seriesList[itemIndex + 1]['id'].toString();
// //                 String categoryId = '${categories[categoryIndex]['id']}';
// //                 final nextNode = focusNodesMap[categoryId]?[nextSeriesId];
// //                 if (nextNode != null) {
// //                   FocusScope.of(context).requestFocus(nextNode);
// //                   return KeyEventResult.handled;
// //                 }
// //               }
// //             } else if (itemIndex == lastDisplayedIndex &&
// //                 seriesList.length > 7) {
// //               // 🔧 CRITICAL: Last displayed item से ViewAll पर focus
// //               FocusScope.of(context).requestFocus(viewAllFocusNode);
// //               return KeyEventResult.handled;
// //             }
// //           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
// //             if (itemIndex > 0) {
// //               String prevSeriesId = seriesList[itemIndex - 1]['id'].toString();
// //               String categoryId = '${categories[categoryIndex]['id']}';
// //               final prevNode = focusNodesMap[categoryId]?[prevSeriesId];
// //               if (prevNode != null) {
// //                 FocusScope.of(context).requestFocus(prevNode);
// //                 return KeyEventResult.handled;
// //               }
// //             }
// //           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// //             context.read<FocusProvider>().requestFirstMoviesFocus();
// //             return KeyEventResult.handled;
// //           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
// //             // Navigate to next category
// //             if (categoryIndex + 1 < categories.length) {
// //               final nextCategory = categories[categoryIndex + 1];
// //               final nextCategoryId = '${nextCategory['id']}';
// //               final nextSeriesList =
// //                   nextCategory['web_series'] as List<dynamic>;
// //               if (nextSeriesList.isNotEmpty) {
// //                 final firstSeriesId = '${nextSeriesList[0]['id']}';
// //                 final firstNode = focusNodesMap[nextCategoryId]?[firstSeriesId];
// //                 if (firstNode != null) {
// //                   FocusScope.of(context).requestFocus(firstNode);
// //                   return KeyEventResult.handled;
// //                 }
// //               }
// //             }
// //             return KeyEventResult.ignored;
// //           } else if (event.logicalKey == LogicalKeyboardKey.select) {
// //             navigateToDetails(
// //               webSeries,
// //               categories[categoryIndex]['category'],
// //               webSeries['banner']?.toString() ??
// //                   webSeries['poster']?.toString() ??
// //                   '',
// //               webSeries['name']?.toString() ?? '',
// //               categoryIndex,
// //             );
// //             return KeyEventResult.handled;
// //           }
// //         }
// //         return KeyEventResult.ignored;
// //       },
// //       child: GestureDetector(
// //         onTap: () => navigateToDetails(
// //           webSeries,
// //           categories[categoryIndex]['category'],
// //           webSeries['banner']?.toString() ??
// //               webSeries['poster']?.toString() ??
// //               '',
// //           webSeries['name']?.toString() ?? '',
// //           categoryIndex,
// //         ),
// //         child: ProfessionalWebSeriesCard(
// //           webSeries: webSeries,
// //           focusNode: node,
// //           onTap: () => navigateToDetails(
// //             webSeries,
// //             categories[categoryIndex]['category'],
// //             webSeries['banner']?.toString() ??
// //                 webSeries['poster']?.toString() ??
// //                 '',
// //             webSeries['name']?.toString() ?? '',
// //             categoryIndex,
// //           ),
// //           onColorChange: (color) {
// //             if (mounted) {
// //               context.read<ColorProvider>().updateColor(color, true);
// //             }
// //           },
// //           index: itemIndex,
// //           onUpPress: () {
// //             context.read<FocusProvider>().requestFirstMoviesFocus();
// //           },
// //         ),
// //       ),
// //     );
// //   }

// // // ================================
// // // ENHANCED VIEWALL BUTTON: With Perfect Left Arrow Navigation
// // // ================================

// //   Widget _buildEnhancedViewAllButton(Map<String, dynamic> category,
// //       List<dynamic> seriesList, FocusNode viewAllFocusNode, int categoryIndex) {
// //     return Focus(
// //       focusNode: viewAllFocusNode,
// //       onKey: (FocusNode node, RawKeyEvent event) {
// //         if (event is RawKeyDownEvent) {
// //           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
// //             // Stay on ViewAll - no further navigation
// //             return KeyEventResult.handled;
// //           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
// //             // ✅ PERFECT: ViewAll से last series पर focus
// //             if (seriesList.isNotEmpty) {
// //               int lastIndex =
// //                   seriesList.length >= 7 ? 6 : seriesList.length - 1;
// //               String lastSeriesId = seriesList[lastIndex]['id'].toString();
// //               String categoryId = '${category['id']}';
// //               final lastNode = focusNodesMap[categoryId]?[lastSeriesId];
// //               if (lastNode != null) {
// //                 FocusScope.of(context).requestFocus(lastNode);
// //                 return KeyEventResult.handled;
// //               }
// //             }
// //           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// //             context.read<FocusProvider>().requestFirstMoviesFocus();
// //             return KeyEventResult.handled;
// //           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
// //             // Navigate to next category's first item
// //             if (categoryIndex + 1 < categories.length) {
// //               final nextCategory = categories[categoryIndex + 1];
// //               final nextCategoryId = '${nextCategory['id']}';
// //               final nextSeriesList =
// //                   nextCategory['web_series'] as List<dynamic>;
// //               if (nextSeriesList.isNotEmpty) {
// //                 final firstSeriesId = '${nextSeriesList[0]['id']}';
// //                 final firstNode = focusNodesMap[nextCategoryId]?[firstSeriesId];
// //                 if (firstNode != null) {
// //                   FocusScope.of(context).requestFocus(firstNode);
// //                   return KeyEventResult.handled;
// //                 }
// //               }
// //             }
// //             return KeyEventResult.ignored;
// //           } else if (event.logicalKey == LogicalKeyboardKey.select) {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (_) => ProfessionalCategoryWebSeriesGridView(
// //                   category: category,
// //                   web_series: seriesList,
// //                 ),
// //               ),
// //             );
// //             return KeyEventResult.handled;
// //           }
// //         }
// //         return KeyEventResult.ignored;
// //       },
// //       child: GestureDetector(
// //         onTap: () {
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //               builder: (_) => ProfessionalCategoryWebSeriesGridView(
// //                 category: category,
// //                 web_series: seriesList,
// //               ),
// //             ),
// //           );
// //         },
// //         child: ProfessionalWebSeriesViewAllButton(
// //           focusNode: viewAllFocusNode,
// //           onTap: () {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (_) => ProfessionalCategoryWebSeriesGridView(
// //                   category: category,
// //                   web_series: seriesList,
// //                 ),
// //               ),
// //             );
// //           },
// //           categoryText: category['category'].toString(),
// //           totalSeries: seriesList.length,
// //         ),
// //       ),
// //     );
// //   }

// // // ================================
// // // 📋 STEP BY STEP CHANGES NEEDED:
// // // ================================

// // /*
// // 🔧 CHANGES TO MAKE IN YOUR CODE:

// // 1. ✅ REPLACE _buildCategorySection method:
// //    - Add viewAllFocusNode creation
// //    - Use _buildEnhancedViewAllButton and _buildEnhancedWebSeriesItem

// // 2. ✅ REPLACE _buildWebSeriesItem method:
// //    - Add complete arrow key navigation
// //    - Add right arrow to ViewAll logic

// // 3. ✅ REPLACE _buildViewAllButton method:
// //    - Add proper left arrow to last series logic
// //    - Add down arrow for next category navigation

// // 🎯 NAVIGATION FLOW RESULT:

// // RIGHT ARROW FLOW:
// // Series0 → Series1 → Series2 → Series3 → Series4 → Series5 → Series6 → ViewAll

// // LEFT ARROW FLOW:
// // ViewAll → Series6 → Series5 → Series4 → Series3 → Series2 → Series1 → Series0

// // UP/DOWN FLOW:
// // - Up Arrow: All items → Movies section
// // - Down Arrow: Items/ViewAll → Next category's first item

// // 🚀 TESTING COMMANDS:
// // - Right arrow on last series (index 6): Should go to ViewAll
// // - Left arrow on ViewAll: Should go to last series (index 6)
// // - All navigation should be smooth with proper focus

// // 💡 CRITICAL POINTS:
// // 1. ViewAll FocusNode created in _buildCategorySection
// // 2. Passed to both ViewAll button and all series items
// // 3. Direct focus management instead of relying on ListView
// // 4. Proper index calculation for last displayed item
// // */

// //   // Widget _buildCategorySection(Map<String, dynamic> category, List<dynamic> seriesList, String categoryId, int categoryIndex) {
// //   //   return Column(
// //   //     crossAxisAlignment: CrossAxisAlignment.start,
// //   //     children: [
// //   //       _buildCategoryHeader(category),
// //   //       SizedBox(
// //   //         height: MediaQuery.of(context).size.height * 0.38,
// //   //         child: ListView.builder(
// //   //           key: ValueKey('webseries_listview_$categoryId'),
// //   //           controller: _scrollController,
// //   //           scrollDirection: Axis.horizontal,
// //   //           physics: const BouncingScrollPhysics(),
// //   //           clipBehavior: Clip.none,
// //   //           padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025),
// //   //           cacheExtent: 1200,
// //   //           itemCount: seriesList.length > 7 ? 8 : seriesList.length + 1,
// //   //           itemBuilder: (context, idx) {
// //   //             if ((seriesList.length >= 7 && idx == 7) ||
// //   //                 (seriesList.length < 7 && idx == seriesList.length)) {
// //   //               return _buildViewAllButton(category, seriesList);
// //   //             }

// //   //             final item = seriesList[idx];
// //   //             final seriesId = '${item['id']}';
// //   //             final node = focusNodesMap[categoryId]?[seriesId];

// //   //             return _buildWebSeriesItem(item, node, categoryIndex, idx);
// //   //           },
// //   //         ),
// //   //       ),
// //   //       const SizedBox(height: 20),
// //   //     ],
// //   //   );
// //   // }

// //   Widget _buildCategoryHeader(Map<String, dynamic> category) {
// //     return Padding(
// //       padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.025, vertical: 8),
// //       child: Row(
// //         children: [
// //           Container(
// //             width: 4,
// //             height: 24,
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 colors: [
// //                   ProfessionalWebSeriesColors.accentPurple,
// //                   ProfessionalWebSeriesColors.accentBlue,
// //                 ],
// //               ),
// //               borderRadius: BorderRadius.circular(2),
// //             ),
// //           ),
// //           SizedBox(width: 12),
// //           Expanded(
// //             child: Text(
// //               category['category'].toString().toUpperCase(),
// //               style: TextStyle(
// //                 color: ProfessionalWebSeriesColors.textPrimary,
// //                 fontWeight: FontWeight.w700,
// //                 fontSize: 18,
// //                 letterSpacing: 1.0,
// //               ),
// //             ),
// //           ),
// //           // Container(
// //           //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //           //   decoration: BoxDecoration(
// //           //     color: ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.6),
// //           //     borderRadius: BorderRadius.circular(12),
// //           //     border: Border.all(
// //           //       color:
// //           //           ProfessionalWebSeriesColors.accentPurple.withOpacity(0.3),
// //           //       width: 1,
// //           //     ),
// //           //   ),
// //           //   child: Text(
// //           //     '${(category['web_series'] as List<dynamic>).length}',
// //           //     style: TextStyle(
// //           //       color: ProfessionalWebSeriesColors.textSecondary,
// //           //       fontSize: 12,
// //           //       fontWeight: FontWeight.w600,
// //           //     ),
// //           //   ),
// //           // ),

// //           if (categories.isNotEmpty)
// //             Container(
// //               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                   colors: [
// //                     ProfessionalWebSeriesColors.accentPurple.withOpacity(0.2),
// //                     ProfessionalWebSeriesColors.accentBlue.withOpacity(0.2),
// //                   ],
// //                 ),
// //                 borderRadius: BorderRadius.circular(20),
// //                 border: Border.all(
// //                   color:
// //                       ProfessionalWebSeriesColors.accentPurple.withOpacity(0.3),
// //                   width: 1,
// //                 ),
// //               ),
// //               child: Row(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Icon(
// //                     Icons.tv,
// //                     size: 14,
// //                     color: ProfessionalWebSeriesColors.textSecondary,
// //                   ),
// //                   SizedBox(width: 6),
// //                   Text(
// //                     '${_getTotalSeriesCount()} Series',
// //                     style: TextStyle(
// //                       color: ProfessionalWebSeriesColors.textSecondary,
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   // 🔧 FIXED: WebSeries Navigation और ViewAll Size Issues

// // // ================================
// // // STEP 1: WebSeries ViewAll Button Focus Management Fix
// // // ================================

// //   Widget _buildViewAllButton(
// //       Map<String, dynamic> category, List<dynamic> seriesList) {
// //     final viewAllFocusNode = FocusNode();

// //     return Focus(
// //       focusNode: viewAllFocusNode,
// //       onKey: (FocusNode node, RawKeyEvent event) {
// //         if (event is RawKeyDownEvent) {
// //           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
// //             // ✅ ViewAll से right arrow - stay on ViewAll
// //             return KeyEventResult.handled;
// //           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
// //             // ✅ FIX: ViewAll से left arrow - last series पर focus
// //             if (seriesList.isNotEmpty) {
// //               // Last displayed series index calculate करें
// //               int lastIndex =
// //                   seriesList.length >= 7 ? 6 : seriesList.length - 1;
// //               String lastSeriesId = seriesList[lastIndex]['id'].toString();
// //               String categoryId = '${category['id']}';
// //               final lastNode = focusNodesMap[categoryId]?[lastSeriesId];
// //               if (lastNode != null) {
// //                 FocusScope.of(context).requestFocus(lastNode);
// //                 return KeyEventResult.handled;
// //               }
// //             }
// //           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
// //             context.read<FocusProvider>().requestFirstMoviesFocus();
// //             return KeyEventResult.handled;
// //           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
// //             // Next category या end of content
// //             return KeyEventResult.ignored;
// //           } else if (event.logicalKey == LogicalKeyboardKey.select) {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (_) => ProfessionalCategoryWebSeriesGridView(
// //                   category: category,
// //                   web_series: seriesList,
// //                 ),
// //               ),
// //             );
// //             return KeyEventResult.handled;
// //           }
// //         }
// //         return KeyEventResult.ignored;
// //       },
// //       child: GestureDetector(
// //         onTap: () {
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //               builder: (_) => ProfessionalCategoryWebSeriesGridView(
// //                 category: category,
// //                 web_series: seriesList,
// //               ),
// //             ),
// //           );
// //         },
// //         child: ProfessionalWebSeriesViewAllButton(
// //           focusNode: viewAllFocusNode,
// //           onTap: () {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (_) => ProfessionalCategoryWebSeriesGridView(
// //                   category: category,
// //                   web_series: seriesList,
// //                 ),
// //               ),
// //             );
// //           },
// //           categoryText: category['category'].toString(),
// //           totalSeries: seriesList.length,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // 🔧 FIXED: Enhanced Grid View for WebSeries with Enter Key Navigation
// // class ProfessionalCategoryWebSeriesGridView extends StatefulWidget {
// //   final Map<String, dynamic> category;
// //   final List<dynamic> web_series;

// //   const ProfessionalCategoryWebSeriesGridView({
// //     Key? key,
// //     required this.category,
// //     required this.web_series,
// //   }) : super(key: key);

// //   @override
// //   _ProfessionalCategoryWebSeriesGridViewState createState() =>
// //       _ProfessionalCategoryWebSeriesGridViewState();
// // }

// // class _ProfessionalCategoryWebSeriesGridViewState
// //     extends State<ProfessionalCategoryWebSeriesGridView>
// //     with TickerProviderStateMixin {
// //   bool _isLoading = false;
// //   late Map<String, FocusNode> _nodes;

// //   // Animation Controllers
// //   late AnimationController _fadeController;
// //   late AnimationController _staggerController;
// //   late Animation<double> _fadeAnimation;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _nodes = {for (var m in widget.web_series) '${m['id']}': FocusNode()};

// //     _initializeAnimations();
// //     _startStaggeredAnimation();
// //   }

// //   void _initializeAnimations() {
// //     _fadeController = AnimationController(
// //       duration: Duration(milliseconds: 600),
// //       vsync: this,
// //     );

// //     _staggerController = AnimationController(
// //       duration: Duration(milliseconds: 1200),
// //       vsync: this,
// //     );

// //     _fadeAnimation = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(CurvedAnimation(
// //       parent: _fadeController,
// //       curve: Curves.easeInOut,
// //     ));
// //   }

// //   void _startStaggeredAnimation() {
// //     _fadeController.forward();
// //     _staggerController.forward();
// //   }

// //   @override
// //   void dispose() {
// //     _fadeController.dispose();
// //     _staggerController.dispose();
// //     for (var node in _nodes.values) node.dispose();
// //     super.dispose();
// //   }

// //   Future<bool> _onWillPop() async {
// //     if (_isLoading) {
// //       setState(() => _isLoading = false);
// //       return false;
// //     }
// //     return true;
// //   }

// //   void navigateToDetails(dynamic webSeries) {
// //     final channelList = widget.web_series.map((m) {
// //       return NewsItemModel(
// //         id: m['id']?.toString() ?? '',
// //         name: m['name']?.toString() ?? '',
// //         poster: m['poster']?.toString() ?? '',
// //         banner: m['banner']?.toString() ?? '',
// //         description: m['description']?.toString() ?? '',
// //         category: widget.category['category'],
// //         index: '',
// //         url: '',
// //         videoId: '',
// //         streamType: '',
// //         type: '',
// //         genres: '',
// //         status: '',
// //         image: '',
// //         unUpdatedUrl: '',
// //       );
// //     }).toList();

// //     int seriesId;
// //     if (webSeries['id'] is int) {
// //       seriesId = webSeries['id'];
// //     } else if (webSeries['id'] is String) {
// //       try {
// //         seriesId = int.parse(webSeries['id']);
// //       } catch (e) {
// //         return;
// //       }
// //     } else {
// //       return;
// //     }

// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => WebSeriesDetailsPage(
// //           id: seriesId,
// //           // channelList: channelList,
// //           // source: 'manage_web_series',
// //           banner: webSeries['banner']?.toString() ??
// //               webSeries['poster']?.toString() ??
// //               '',
// //           poster: webSeries['poster']?.toString() ??
// //               webSeries['banner']?.toString() ??
// //               '',
// //           name: webSeries['name']?.toString() ?? '',
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: _onWillPop,
// //       child: Scaffold(
// //         backgroundColor: ProfessionalWebSeriesColors.primaryDark,
// //         body: Stack(
// //           children: [
// //             // Enhanced Background
// //             Container(
// //               decoration: BoxDecoration(
// //                 gradient: RadialGradient(
// //                   center: Alignment.topRight,
// //                   radius: 1.5,
// //                   colors: [
// //                     ProfessionalWebSeriesColors.accentPurple.withOpacity(0.1),
// //                     ProfessionalWebSeriesColors.primaryDark,
// //                     ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.8),
// //                     ProfessionalWebSeriesColors.primaryDark,
// //                   ],
// //                 ),
// //               ),
// //             ),

// //             // Main Content
// //             FadeTransition(
// //               opacity: _fadeAnimation,
// //               child: Column(
// //                 children: [
// //                   _buildProfessionalAppBar(),
// //                   Expanded(
// //                     child: _buildWebSeriesGrid(),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             // Loading Overlay
// //             if (_isLoading)
// //               Container(
// //                 color: Colors.black.withOpacity(0.7),
// //                 child: Center(
// //                   child: _buildLoadingIndicator(),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildProfessionalAppBar() {
// //     return Container(
// //       padding: EdgeInsets.only(
// //         top: MediaQuery.of(context).padding.top + 10,
// //         left: 20,
// //         right: 20,
// //         bottom: 20,
// //       ),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topCenter,
// //           end: Alignment.bottomCenter,
// //           colors: [
// //             ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.95),
// //             ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.7),
// //             Colors.transparent,
// //           ],
// //         ),
// //         border: Border(
// //           bottom: BorderSide(
// //             color: ProfessionalWebSeriesColors.accentPurple.withOpacity(0.2),
// //             width: 1,
// //           ),
// //         ),
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               gradient: LinearGradient(
// //                 colors: [
// //                   ProfessionalWebSeriesColors.accentPurple.withOpacity(0.3),
// //                   ProfessionalWebSeriesColors.accentBlue.withOpacity(0.3),
// //                 ],
// //               ),
// //               border: Border.all(
// //                 color:
// //                     ProfessionalWebSeriesColors.accentPurple.withOpacity(0.5),
// //                 width: 1,
// //               ),
// //             ),
// //             child: IconButton(
// //               icon: Icon(
// //                 Icons.arrow_back_rounded,
// //                 color: Colors.white,
// //                 size: 24,
// //               ),
// //               onPressed: () => Navigator.pop(context),
// //             ),
// //           ),
// //           SizedBox(width: 16),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 ShaderMask(
// //                   shaderCallback: (bounds) => LinearGradient(
// //                     colors: [
// //                       ProfessionalWebSeriesColors.accentPurple,
// //                       ProfessionalWebSeriesColors.accentBlue,
// //                     ],
// //                   ).createShader(bounds),
// //                   child: Text(
// //                     widget.category['category'].toString(),
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 24,
// //                       fontWeight: FontWeight.w700,
// //                       letterSpacing: 1.0,
// //                     ),
// //                   ),
// //                 ),
// //                 SizedBox(height: 4),
// //                 Container(
// //                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(
// //                       colors: [
// //                         ProfessionalWebSeriesColors.accentPurple
// //                             .withOpacity(0.3),
// //                         ProfessionalWebSeriesColors.accentBlue.withOpacity(0.3),
// //                       ],
// //                     ),
// //                     borderRadius: BorderRadius.circular(15),
// //                     border: Border.all(
// //                       color: ProfessionalWebSeriesColors.accentPurple
// //                           .withOpacity(0.5),
// //                       width: 1,
// //                     ),
// //                   ),
// //                   child: Row(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Icon(
// //                         Icons.tv_rounded,
// //                         size: 14,
// //                         color: ProfessionalWebSeriesColors.textSecondary,
// //                       ),
// //                       SizedBox(width: 6),
// //                       Text(
// //                         '${widget.web_series.length} Series Available',
// //                         style: TextStyle(
// //                           color: ProfessionalWebSeriesColors.textSecondary,
// //                           fontSize: 12,
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Container(
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               color: ProfessionalWebSeriesColors.cardDark.withOpacity(0.6),
// //             ),
// //             child: IconButton(
// //               icon: Icon(
// //                 Icons.search_rounded,
// //                 color: ProfessionalWebSeriesColors.textSecondary,
// //                 size: 20,
// //               ),
// //               onPressed: () {
// //                 // Add search functionality
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildWebSeriesGrid() {
// //     return Padding(
// //       padding: EdgeInsets.symmetric(horizontal: 20),
// //       child: GridView.builder(
// //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //           crossAxisCount: 5,
// //           mainAxisSpacing: 16,
// //           crossAxisSpacing: 16,
// //           childAspectRatio: 0.68,
// //         ),
// //         itemCount: widget.web_series.length,
// //         clipBehavior: Clip.none,
// //         itemBuilder: (context, index) {
// //           final webSeries = widget.web_series[index];
// //           String seriesId = webSeries['id'].toString();

// //           return AnimatedBuilder(
// //             animation: _staggerController,
// //             builder: (context, child) {
// //               final delay = (index / widget.web_series.length) * 0.5;
// //               final animationValue = Interval(
// //                 delay,
// //                 delay + 0.5,
// //                 curve: Curves.easeOutCubic,
// //               ).transform(_staggerController.value);

// //               return Transform.translate(
// //                 offset: Offset(0, 50 * (1 - animationValue)),
// //                 child: Opacity(
// //                   opacity: animationValue,
// //                   child: ProfessionalGridWebSeriesCard(
// //                     webSeries: webSeries,
// //                     focusNode: _nodes[seriesId]!,
// //                     onTap: () {
// //                       setState(() => _isLoading = true);
// //                       navigateToDetails(webSeries);
// //                       setState(() => _isLoading = false);
// //                     },
// //                     index: index,
// //                   ),
// //                 ),
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildLoadingIndicator() {
// //     return Column(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         Container(
// //           width: 60,
// //           height: 60,
// //           child: CircularProgressIndicator(
// //             strokeWidth: 4,
// //             valueColor: AlwaysStoppedAnimation<Color>(
// //               ProfessionalWebSeriesColors.accentPurple,
// //             ),
// //           ),
// //         ),
// //         SizedBox(height: 20),
// //         Text(
// //           'Loading Series...',
// //           style: TextStyle(
// //             color: Colors.white,
// //             fontSize: 18,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // // 🔧 FIXED: Professional Grid WebSeries Card with Enter Key Navigation
// // class ProfessionalGridWebSeriesCard extends StatefulWidget {
// //   final dynamic webSeries;
// //   final FocusNode focusNode;
// //   final VoidCallback onTap;
// //   final int index;

// //   const ProfessionalGridWebSeriesCard({
// //     Key? key,
// //     required this.webSeries,
// //     required this.focusNode,
// //     required this.onTap,
// //     required this.index,
// //   }) : super(key: key);

// //   @override
// //   _ProfessionalGridWebSeriesCardState createState() =>
// //       _ProfessionalGridWebSeriesCardState();
// // }

// // class _ProfessionalGridWebSeriesCardState
// //     extends State<ProfessionalGridWebSeriesCard> with TickerProviderStateMixin {
// //   late AnimationController _hoverController;
// //   late AnimationController _glowController;
// //   late Animation<double> _scaleAnimation;
// //   late Animation<double> _glowAnimation;

// //   Color _dominantColor = ProfessionalWebSeriesColors.accentPurple;
// //   bool _isFocused = false;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _hoverController = AnimationController(
// //       duration: WebSeriesAnimationTiming.focus,
// //       vsync: this,
// //     );

// //     _glowController = AnimationController(
// //       duration: WebSeriesAnimationTiming.medium,
// //       vsync: this,
// //     );

// //     _scaleAnimation = Tween<double>(
// //       begin: 1.0,
// //       end: 1.05,
// //     ).animate(CurvedAnimation(
// //       parent: _hoverController,
// //       curve: Curves.easeOutCubic,
// //     ));

// //     _glowAnimation = Tween<double>(
// //       begin: 0.0,
// //       end: 1.0,
// //     ).animate(CurvedAnimation(
// //       parent: _glowController,
// //       curve: Curves.easeInOut,
// //     ));

// //     widget.focusNode.addListener(_handleFocusChange);
// //   }

// //   void _handleFocusChange() {
// //     setState(() {
// //       _isFocused = widget.focusNode.hasFocus;
// //     });

// //     if (_isFocused) {
// //       _hoverController.forward();
// //       _glowController.forward();
// //       _generateDominantColor();
// //       HapticFeedback.lightImpact();
// //     } else {
// //       _hoverController.reverse();
// //       _glowController.reverse();
// //     }
// //   }

// //   void _generateDominantColor() {
// //     final colors = ProfessionalWebSeriesColors.gradientColors;
// //     _dominantColor = colors[math.Random().nextInt(colors.length)];
// //   }

// //   @override
// //   void dispose() {
// //     _hoverController.dispose();
// //     _glowController.dispose();
// //     widget.focusNode.removeListener(_handleFocusChange);
// //     super.dispose();
// //   }

// //   bool _isValidImageUrl(String url) {
// //     if (url.isEmpty) return false;

// //     try {
// //       final uri = Uri.parse(url);
// //       if (!uri.hasAbsolutePath) return false;
// //       if (uri.scheme != 'http' && uri.scheme != 'https') return false;

// //       final path = uri.path.toLowerCase();
// //       return path.contains('.jpg') ||
// //           path.contains('.jpeg') ||
// //           path.contains('.png') ||
// //           path.contains('.webp') ||
// //           path.contains('.gif') ||
// //           path.contains('image') ||
// //           path.contains('thumb') ||
// //           path.contains('banner') ||
// //           path.contains('poster');
// //     } catch (e) {
// //       return false;
// //     }
// //   }

// //   // ↓ REPLACE _buildWebSeriesImage method

// //   Widget _buildWebSeriesImage() {
// //     final posterUrl = widget.webSeries['poster']?.toString() ?? '';
// //     final bannerUrl = widget.webSeries['banner']?.toString() ?? '';

// //     return Container(
// //       width: double.infinity,
// //       height: double.infinity,
// //       child: Stack(
// //         children: [
// //           // Default background with series info
// //           Container(
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //                 colors: [
// //                   ProfessionalWebSeriesColors.cardDark,
// //                   ProfessionalWebSeriesColors.surfaceDark,
// //                 ],
// //               ),
// //             ),
// //             child: Center(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Icon(
// //                     Icons.tv_rounded,
// //                     size: 40,
// //                     color: ProfessionalWebSeriesColors.textSecondary,
// //                   ),
// //                   SizedBox(height: 8),
// //                   Text(
// //                     'SERIES',
// //                     style: TextStyle(
// //                       color: ProfessionalWebSeriesColors.textSecondary,
// //                       fontSize: 10,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   SizedBox(height: 4),
// //                   Container(
// //                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                     decoration: BoxDecoration(
// //                       color: ProfessionalWebSeriesColors.accentPurple
// //                           .withOpacity(0.2),
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Text(
// //                       'HD',
// //                       style: TextStyle(
// //                         color: ProfessionalWebSeriesColors.accentPurple,
// //                         fontSize: 8,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           // Try poster first
// //           if (_isValidImageUrl(posterUrl))
// //             CachedNetworkImage(
// //               imageUrl: posterUrl,
// //               fit: BoxFit.cover,
// //               width: double.infinity,
// //               height: double.infinity,
// //               placeholder: (context, url) => Container(
// //                 decoration: BoxDecoration(
// //                   gradient: LinearGradient(
// //                     colors: [
// //                       ProfessionalWebSeriesColors.cardDark,
// //                       ProfessionalWebSeriesColors.surfaceDark,
// //                     ],
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight,
// //                   ),
// //                 ),
// //                 child: Center(
// //                   child: CircularProgressIndicator(
// //                     strokeWidth: 2,
// //                     valueColor: AlwaysStoppedAnimation<Color>(
// //                       ProfessionalWebSeriesColors.accentPurple,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               errorWidget: (context, url, error) {
// //                 // Fallback to banner
// //                 if (_isValidImageUrl(bannerUrl)) {
// //                   return CachedNetworkImage(
// //                     imageUrl: bannerUrl,
// //                     fit: BoxFit.cover,
// //                     width: double.infinity,
// //                     height: double.infinity,
// //                     errorWidget: (context, url, error) => Container(),
// //                   );
// //                 }
// //                 return Container(); // Show background fallback
// //               },
// //               fadeInDuration: const Duration(milliseconds: 300),
// //               fadeOutDuration: const Duration(milliseconds: 100),
// //             )
// //           // Fallback to banner if poster is invalid
// //           else if (_isValidImageUrl(bannerUrl))
// //             CachedNetworkImage(
// //               imageUrl: bannerUrl,
// //               fit: BoxFit.cover,
// //               width: double.infinity,
// //               height: double.infinity,
// //               placeholder: (context, url) => Container(
// //                 decoration: BoxDecoration(
// //                   gradient: LinearGradient(
// //                     colors: [
// //                       ProfessionalWebSeriesColors.cardDark,
// //                       ProfessionalWebSeriesColors.surfaceDark,
// //                     ],
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight,
// //                   ),
// //                 ),
// //                 child: Center(
// //                   child: CircularProgressIndicator(
// //                     strokeWidth: 2,
// //                     valueColor: AlwaysStoppedAnimation<Color>(
// //                       ProfessionalWebSeriesColors.accentPurple,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               errorWidget: (context, url, error) => Container(),
// //               fadeInDuration: const Duration(milliseconds: 300),
// //               fadeOutDuration: const Duration(milliseconds: 100),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ↓ REPLACE _buildImagePlaceholder method (if exists)

// //   Widget _buildImagePlaceholder() {
// //     return Container(
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [
// //             ProfessionalWebSeriesColors.cardDark,
// //             ProfessionalWebSeriesColors.surfaceDark,
// //           ],
// //         ),
// //       ),
// //       child: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               Icons.tv_rounded,
// //               size: 40,
// //               color: ProfessionalWebSeriesColors.textSecondary,
// //             ),
// //             SizedBox(height: 8),
// //             Text(
// //               'WEB SERIES',
// //               style: TextStyle(
// //                 color: ProfessionalWebSeriesColors.textSecondary,
// //                 fontSize: 10,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             SizedBox(height: 4),
// //             Container(
// //               padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //               decoration: BoxDecoration(
// //                 color:
// //                     ProfessionalWebSeriesColors.accentPurple.withOpacity(0.2),
// //                 borderRadius: BorderRadius.circular(6),
// //               ),
// //               child: Text(
// //                 'HD QUALITY',
// //                 style: TextStyle(
// //                   color: ProfessionalWebSeriesColors.accentPurple,
// //                   fontSize: 8,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Focus(
// //       focusNode: widget.focusNode,
// //       // 🔧 CRITICAL FIX: Add onKey handler for Enter key navigation
// //       onKey: (FocusNode node, RawKeyEvent event) {
// //         if (event is RawKeyDownEvent) {
// //           if (event.logicalKey == LogicalKeyboardKey.select ||
// //               event.logicalKey == LogicalKeyboardKey.enter) {
// //             // 🎯 FIXED: Enter/Select key triggers navigation
// //             widget.onTap();
// //             return KeyEventResult.handled;
// //           }
// //         }
// //         return KeyEventResult.ignored;
// //       },
// //       child: GestureDetector(
// //         onTap: widget.onTap,
// //         child: AnimatedBuilder(
// //           animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
// //           builder: (context, child) {
// //             return Transform.scale(
// //               scale: _scaleAnimation.value,
// //               child: Container(
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(15),
// //                   boxShadow: [
// //                     if (_isFocused) ...[
// //                       BoxShadow(
// //                         color: _dominantColor.withOpacity(0.4),
// //                         blurRadius: 20,
// //                         spreadRadius: 2,
// //                         offset: Offset(0, 8),
// //                       ),
// //                       BoxShadow(
// //                         color: _dominantColor.withOpacity(0.2),
// //                         blurRadius: 35,
// //                         spreadRadius: 4,
// //                         offset: Offset(0, 12),
// //                       ),
// //                     ] else ...[
// //                       BoxShadow(
// //                         color: Colors.black.withOpacity(0.3),
// //                         blurRadius: 8,
// //                         spreadRadius: 1,
// //                         offset: Offset(0, 4),
// //                       ),
// //                     ],
// //                   ],
// //                 ),
// //                 child: ClipRRect(
// //                   borderRadius: BorderRadius.circular(15),
// //                   child: Stack(
// //                     children: [
// //                       _buildWebSeriesImage(),
// //                       if (_isFocused) _buildFocusBorder(),
// //                       _buildGradientOverlay(),
// //                       _buildWebSeriesInfo(),
// //                       if (_isFocused) _buildPlayButton(),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   // Widget _buildWebSeriesImage() {
// //   //   final imageUrl = widget.webSeries['poster']?.toString() ??
// //   //       widget.webSeries['banner']?.toString() ??
// //   //       '';

// //   //   return Container(
// //   //     width: double.infinity,
// //   //     height: double.infinity,
// //   //     child: imageUrl.isNotEmpty
// //   //         ? CachedNetworkImage(
// //   //             imageUrl: imageUrl,
// //   //             fit: BoxFit.cover,
// //   //             placeholder: (context, url) => _buildImagePlaceholder(),
// //   //             errorWidget: (context, url, error) => _buildImagePlaceholder(),
// //   //           )
// //   //         : _buildImagePlaceholder(),
// //   //   );
// //   // }

// //   // Widget _buildImagePlaceholder() {
// //   //   return Container(
// //   //     decoration: BoxDecoration(
// //   //       gradient: LinearGradient(
// //   //         begin: Alignment.topLeft,
// //   //         end: Alignment.bottomRight,
// //   //         colors: [
// //   //           ProfessionalWebSeriesColors.cardDark,
// //   //           ProfessionalWebSeriesColors.surfaceDark,
// //   //         ],
// //   //       ),
// //   //     ),
// //   //     child: Center(
// //   //       child: Column(
// //   //         mainAxisAlignment: MainAxisAlignment.center,
// //   //         children: [
// //   //           Icon(
// //   //             Icons.tv_rounded,
// //   //             size: 40,
// //   //             color: ProfessionalWebSeriesColors.textSecondary,
// //   //           ),
// //   //           SizedBox(height: 8),
// //   //           Text(
// //   //             'No Image',
// //   //             style: TextStyle(
// //   //               color: ProfessionalWebSeriesColors.textSecondary,
// //   //               fontSize: 10,
// //   //             ),
// //   //           ),
// //   //         ],
// //   //       ),
// //   //     ),
// //   //   );
// //   // }

// //   Widget _buildFocusBorder() {
// //     return Positioned.fill(
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(15),
// //           border: Border.all(
// //             width: 3,
// //             color: _dominantColor,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildGradientOverlay() {
// //     return Positioned.fill(
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(15),
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [
// //               Colors.transparent,
// //               Colors.transparent,
// //               Colors.black.withOpacity(0.7),
// //               Colors.black.withOpacity(0.9),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildWebSeriesInfo() {
// //     final seriesName = widget.webSeries['name']?.toString() ?? 'Unknown';

// //     return Positioned(
// //       bottom: 0,
// //       left: 0,
// //       right: 0,
// //       child: Padding(
// //         padding: EdgeInsets.all(12),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Text(
// //               seriesName.toUpperCase(),
// //               style: TextStyle(
// //                 color: _isFocused ? _dominantColor : Colors.white,
// //                 fontSize: _isFocused ? 13 : 12,
// //                 fontWeight: FontWeight.w600,
// //                 letterSpacing: 0.5,
// //                 shadows: [
// //                   Shadow(
// //                     color: Colors.black.withOpacity(0.8),
// //                     blurRadius: 4,
// //                     offset: Offset(0, 1),
// //                   ),
// //                 ],
// //               ),
// //               maxLines: 2,
// //               overflow: TextOverflow.ellipsis,
// //             ),
// //             if (_isFocused) ...[
// //               SizedBox(height: 4),
// //               Row(
// //                 children: [
// //                   Container(
// //                     padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //                     decoration: BoxDecoration(
// //                       color: _dominantColor.withOpacity(0.2),
// //                       borderRadius: BorderRadius.circular(8),
// //                       border: Border.all(
// //                         color: _dominantColor.withOpacity(0.4),
// //                         width: 1,
// //                       ),
// //                     ),
// //                     child: Row(
// //                       mainAxisSize: MainAxisSize.min,
// //                       children: [
// //                         Icon(
// //                           Icons.tv,
// //                           color: _dominantColor,
// //                           size: 8,
// //                         ),
// //                         SizedBox(width: 2),
// //                         Text(
// //                           'SERIES',
// //                           style: TextStyle(
// //                             color: _dominantColor,
// //                             fontSize: 8,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(width: 6),
// //                   Container(
// //                     padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.2),
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Text(
// //                       'HD',
// //                       style: TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 8,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildPlayButton() {
// //     return Positioned(
// //       top: 12,
// //       right: 12,
// //       child: Container(
// //         width: 40,
// //         height: 40,
// //         decoration: BoxDecoration(
// //           shape: BoxShape.circle,
// //           color: _dominantColor.withOpacity(0.9),
// //           boxShadow: [
// //             BoxShadow(
// //               color: _dominantColor.withOpacity(0.4),
// //               blurRadius: 8,
// //               offset: Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: Icon(
// //           Icons.play_arrow_rounded,
// //           color: Colors.white,
// //           size: 24,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // // Enhanced Grid View for WebSeries
// // // class ProfessionalCategoryWebSeriesGridView extends StatefulWidget {
// // //   final Map<String, dynamic> category;
// // //   final List<dynamic> web_series;

// // //   const ProfessionalCategoryWebSeriesGridView({
// // //     Key? key,
// // //     required this.category,
// // //     required this.web_series,
// // //   }) : super(key: key);

// // //   @override
// // //   _ProfessionalCategoryWebSeriesGridViewState createState() =>
// // //       _ProfessionalCategoryWebSeriesGridViewState();
// // // }

// // // class _ProfessionalCategoryWebSeriesGridViewState
// // //     extends State<ProfessionalCategoryWebSeriesGridView>
// // //     with TickerProviderStateMixin {
// // //   bool _isLoading = false;
// // //   late Map<String, FocusNode> _nodes;

// // //   // Animation Controllers
// // //   late AnimationController _fadeController;
// // //   late AnimationController _staggerController;
// // //   late Animation<double> _fadeAnimation;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _nodes = {for (var m in widget.web_series) '${m['id']}': FocusNode()};

// // //     _initializeAnimations();
// // //     _startStaggeredAnimation();
// // //   }

// // //   void _initializeAnimations() {
// // //     _fadeController = AnimationController(
// // //       duration: Duration(milliseconds: 600),
// // //       vsync: this,
// // //     );

// // //     _staggerController = AnimationController(
// // //       duration: Duration(milliseconds: 1200),
// // //       vsync: this,
// // //     );

// // //     _fadeAnimation = Tween<double>(
// // //       begin: 0.0,
// // //       end: 1.0,
// // //     ).animate(CurvedAnimation(
// // //       parent: _fadeController,
// // //       curve: Curves.easeInOut,
// // //     ));
// // //   }

// // //   void _startStaggeredAnimation() {
// // //     _fadeController.forward();
// // //     _staggerController.forward();
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _fadeController.dispose();
// // //     _staggerController.dispose();
// // //     for (var node in _nodes.values) node.dispose();
// // //     super.dispose();
// // //   }

// // //   Future<bool> _onWillPop() async {
// // //     if (_isLoading) {
// // //       setState(() => _isLoading = false);
// // //       return false;
// // //     }
// // //     return true;
// // //   }

// // //   void navigateToDetails(dynamic webSeries) {
// // //     final channelList = widget.web_series.map((m) {
// // //       return NewsItemModel(
// // //         id: m['id']?.toString() ?? '',
// // //         name: m['name']?.toString() ?? '',
// // //         poster: m['poster']?.toString() ?? '',
// // //         banner: m['banner']?.toString() ?? '',
// // //         description: m['description']?.toString() ?? '',
// // //         category: widget.category['category'],
// // //         index: '',
// // //         url: '',
// // //         videoId: '',
// // //         streamType: '',
// // //         type: '',
// // //         genres: '',
// // //         status: '',
// // //         image: '',
// // //         unUpdatedUrl: '',
// // //       );
// // //     }).toList();

// // //     int seriesId;
// // //     if (webSeries['id'] is int) {
// // //       seriesId = webSeries['id'];
// // //     } else if (webSeries['id'] is String) {
// // //       try {
// // //         seriesId = int.parse(webSeries['id']);
// // //       } catch (e) {
// // //         return;
// // //       }
// // //     } else {
// // //       return;
// // //     }

// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(
// // //         builder: (_) => WebSeriesDetailsPage(
// // //           id: seriesId,
// // //           channelList: channelList,
// // //           source: 'manage_web_series',
// // //           banner: webSeries['banner']?.toString() ??
// // //               webSeries['poster']?.toString() ??
// // //               '',
// // //           poster: webSeries['poster']?.toString() ??
// // //               webSeries['banner']?.toString() ??
// // //               '',
// // //           name: webSeries['name']?.toString() ?? '',
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return WillPopScope(
// // //       onWillPop: _onWillPop,
// // //       child: Scaffold(
// // //         backgroundColor: ProfessionalWebSeriesColors.primaryDark,
// // //         body: Stack(
// // //           children: [
// // //             // Enhanced Background
// // //             Container(
// // //               decoration: BoxDecoration(
// // //                 gradient: RadialGradient(
// // //                   center: Alignment.topRight,
// // //                   radius: 1.5,
// // //                   colors: [
// // //                     ProfessionalWebSeriesColors.accentPurple.withOpacity(0.1),
// // //                     ProfessionalWebSeriesColors.primaryDark,
// // //                     ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.8),
// // //                     ProfessionalWebSeriesColors.primaryDark,
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),

// // //             // Main Content
// // //             FadeTransition(
// // //               opacity: _fadeAnimation,
// // //               child: Column(
// // //                 children: [
// // //                   _buildProfessionalAppBar(),
// // //                   Expanded(
// // //                     child: _buildWebSeriesGrid(),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),

// // //             // Loading Overlay
// // //             if (_isLoading)
// // //               Container(
// // //                 color: Colors.black.withOpacity(0.7),
// // //                 child: Center(
// // //                   child: _buildLoadingIndicator(),
// // //                 ),
// // //               ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildProfessionalAppBar() {
// // //     return Container(
// // //       padding: EdgeInsets.only(
// // //         top: MediaQuery.of(context).padding.top + 10,
// // //         left: 20,
// // //         right: 20,
// // //         bottom: 20,
// // //       ),
// // //       decoration: BoxDecoration(
// // //         gradient: LinearGradient(
// // //           begin: Alignment.topCenter,
// // //           end: Alignment.bottomCenter,
// // //           colors: [
// // //             ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.95),
// // //             ProfessionalWebSeriesColors.surfaceDark.withOpacity(0.7),
// // //             Colors.transparent,
// // //           ],
// // //         ),
// // //         border: Border(
// // //           bottom: BorderSide(
// // //             color: ProfessionalWebSeriesColors.accentPurple.withOpacity(0.2),
// // //             width: 1,
// // //           ),
// // //         ),
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           Container(
// // //             decoration: BoxDecoration(
// // //               shape: BoxShape.circle,
// // //               gradient: LinearGradient(
// // //                 colors: [
// // //                   ProfessionalWebSeriesColors.accentPurple.withOpacity(0.3),
// // //                   ProfessionalWebSeriesColors.accentBlue.withOpacity(0.3),
// // //                 ],
// // //               ),
// // //               border: Border.all(
// // //                 color:
// // //                     ProfessionalWebSeriesColors.accentPurple.withOpacity(0.5),
// // //                 width: 1,
// // //               ),
// // //             ),
// // //             child: IconButton(
// // //               icon: Icon(
// // //                 Icons.arrow_back_rounded,
// // //                 color: Colors.white,
// // //                 size: 24,
// // //               ),
// // //               onPressed: () => Navigator.pop(context),
// // //             ),
// // //           ),
// // //           SizedBox(width: 16),
// // //           Expanded(
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 ShaderMask(
// // //                   shaderCallback: (bounds) => LinearGradient(
// // //                     colors: [
// // //                       ProfessionalWebSeriesColors.accentPurple,
// // //                       ProfessionalWebSeriesColors.accentBlue,
// // //                     ],
// // //                   ).createShader(bounds),
// // //                   child: Text(
// // //                     widget.category['category'].toString(),
// // //                     style: TextStyle(
// // //                       color: Colors.white,
// // //                       fontSize: 24,
// // //                       fontWeight: FontWeight.w700,
// // //                       letterSpacing: 1.0,
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 SizedBox(height: 4),
// // //                 Container(
// // //                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// // //                   decoration: BoxDecoration(
// // //                     gradient: LinearGradient(
// // //                       colors: [
// // //                         ProfessionalWebSeriesColors.accentPurple
// // //                             .withOpacity(0.3),
// // //                         ProfessionalWebSeriesColors.accentBlue.withOpacity(0.3),
// // //                       ],
// // //                     ),
// // //                     borderRadius: BorderRadius.circular(15),
// // //                     border: Border.all(
// // //                       color: ProfessionalWebSeriesColors.accentPurple
// // //                           .withOpacity(0.5),
// // //                       width: 1,
// // //                     ),
// // //                   ),
// // //                   child: Row(
// // //                     mainAxisSize: MainAxisSize.min,
// // //                     children: [
// // //                       Icon(
// // //                         Icons.tv_rounded,
// // //                         size: 14,
// // //                         color: ProfessionalWebSeriesColors.textSecondary,
// // //                       ),
// // //                       SizedBox(width: 6),
// // //                       Text(
// // //                         '${widget.web_series.length} Series Available',
// // //                         style: TextStyle(
// // //                           color: ProfessionalWebSeriesColors.textSecondary,
// // //                           fontSize: 12,
// // //                           fontWeight: FontWeight.w500,
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //           Container(
// // //             decoration: BoxDecoration(
// // //               shape: BoxShape.circle,
// // //               color: ProfessionalWebSeriesColors.cardDark.withOpacity(0.6),
// // //             ),
// // //             child: IconButton(
// // //               icon: Icon(
// // //                 Icons.search_rounded,
// // //                 color: ProfessionalWebSeriesColors.textSecondary,
// // //                 size: 20,
// // //               ),
// // //               onPressed: () {
// // //                 // Add search functionality
// // //               },
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildWebSeriesGrid() {
// // //     return Padding(
// // //       padding: EdgeInsets.symmetric(horizontal: 20),
// // //       child: GridView.builder(
// // //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// // //           crossAxisCount: 5,
// // //           mainAxisSpacing: 16,
// // //           crossAxisSpacing: 16,
// // //           childAspectRatio: 0.68,
// // //         ),
// // //         itemCount: widget.web_series.length,
// // //         clipBehavior: Clip.none,
// // //         itemBuilder: (context, index) {
// // //           final webSeries = widget.web_series[index];
// // //           String seriesId = webSeries['id'].toString();

// // //           return AnimatedBuilder(
// // //             animation: _staggerController,
// // //             builder: (context, child) {
// // //               final delay = (index / widget.web_series.length) * 0.5;
// // //               final animationValue = Interval(
// // //                 delay,
// // //                 delay + 0.5,
// // //                 curve: Curves.easeOutCubic,
// // //               ).transform(_staggerController.value);

// // //               return Transform.translate(
// // //                 offset: Offset(0, 50 * (1 - animationValue)),
// // //                 child: Opacity(
// // //                   opacity: animationValue,
// // //                   child: ProfessionalGridWebSeriesCard(
// // //                     webSeries: webSeries,
// // //                     focusNode: _nodes[seriesId]!,
// // //                     onTap: () {
// // //                       setState(() => _isLoading = true);
// // //                       navigateToDetails(webSeries);
// // //                       setState(() => _isLoading = false);
// // //                     },
// // //                     index: index,
// // //                   ),
// // //                 ),
// // //               );
// // //             },
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildLoadingIndicator() {
// // //     return Column(
// // //       mainAxisAlignment: MainAxisAlignment.center,
// // //       children: [
// // //         Container(
// // //           width: 60,
// // //           height: 60,
// // //           child: CircularProgressIndicator(
// // //             strokeWidth: 4,
// // //             valueColor: AlwaysStoppedAnimation<Color>(
// // //               ProfessionalWebSeriesColors.accentPurple,
// // //             ),
// // //           ),
// // //         ),
// // //         SizedBox(height: 20),
// // //         Text(
// // //           'Loading Series...',
// // //           style: TextStyle(
// // //             color: Colors.white,
// // //             fontSize: 18,
// // //             fontWeight: FontWeight.w600,
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // // }

// // // // Professional Grid WebSeries Card
// // // class ProfessionalGridWebSeriesCard extends StatefulWidget {
// // //   final dynamic webSeries;
// // //   final FocusNode focusNode;
// // //   final VoidCallback onTap;
// // //   final int index;

// // //   const ProfessionalGridWebSeriesCard({
// // //     Key? key,
// // //     required this.webSeries,
// // //     required this.focusNode,
// // //     required this.onTap,
// // //     required this.index,
// // //   }) : super(key: key);

// // //   @override
// // //   _ProfessionalGridWebSeriesCardState createState() =>
// // //       _ProfessionalGridWebSeriesCardState();
// // // }

// // // class _ProfessionalGridWebSeriesCardState
// // //     extends State<ProfessionalGridWebSeriesCard> with TickerProviderStateMixin {
// // //   late AnimationController _hoverController;
// // //   late AnimationController _glowController;
// // //   late Animation<double> _scaleAnimation;
// // //   late Animation<double> _glowAnimation;

// // //   Color _dominantColor = ProfessionalWebSeriesColors.accentPurple;
// // //   bool _isFocused = false;

// // //   @override
// // //   void initState() {
// // //     super.initState();

// // //     _hoverController = AnimationController(
// // //       duration: WebSeriesAnimationTiming.focus,
// // //       vsync: this,
// // //     );

// // //     _glowController = AnimationController(
// // //       duration: WebSeriesAnimationTiming.medium,
// // //       vsync: this,
// // //     );

// // //     _scaleAnimation = Tween<double>(
// // //       begin: 1.0,
// // //       end: 1.05,
// // //     ).animate(CurvedAnimation(
// // //       parent: _hoverController,
// // //       curve: Curves.easeOutCubic,
// // //     ));

// // //     _glowAnimation = Tween<double>(
// // //       begin: 0.0,
// // //       end: 1.0,
// // //     ).animate(CurvedAnimation(
// // //       parent: _glowController,
// // //       curve: Curves.easeInOut,
// // //     ));

// // //     widget.focusNode.addListener(_handleFocusChange);
// // //   }

// // //   void _handleFocusChange() {
// // //     setState(() {
// // //       _isFocused = widget.focusNode.hasFocus;
// // //     });

// // //     if (_isFocused) {
// // //       _hoverController.forward();
// // //       _glowController.forward();
// // //       _generateDominantColor();
// // //       HapticFeedback.lightImpact();
// // //     } else {
// // //       _hoverController.reverse();
// // //       _glowController.reverse();
// // //     }
// // //   }

// // //   void _generateDominantColor() {
// // //     final colors = ProfessionalWebSeriesColors.gradientColors;
// // //     _dominantColor = colors[math.Random().nextInt(colors.length)];
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _hoverController.dispose();
// // //     _glowController.dispose();
// // //     widget.focusNode.removeListener(_handleFocusChange);
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Focus(
// // //       focusNode: widget.focusNode,
// // //       child: GestureDetector(
// // //         onTap: widget.onTap,
// // //         child: AnimatedBuilder(
// // //           animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
// // //           builder: (context, child) {
// // //             return Transform.scale(
// // //               scale: _scaleAnimation.value,
// // //               child: Container(
// // //                 decoration: BoxDecoration(
// // //                   borderRadius: BorderRadius.circular(15),
// // //                   boxShadow: [
// // //                     if (_isFocused) ...[
// // //                       BoxShadow(
// // //                         color: _dominantColor.withOpacity(0.4),
// // //                         blurRadius: 20,
// // //                         spreadRadius: 2,
// // //                         offset: Offset(0, 8),
// // //                       ),
// // //                       BoxShadow(
// // //                         color: _dominantColor.withOpacity(0.2),
// // //                         blurRadius: 35,
// // //                         spreadRadius: 4,
// // //                         offset: Offset(0, 12),
// // //                       ),
// // //                     ] else ...[
// // //                       BoxShadow(
// // //                         color: Colors.black.withOpacity(0.3),
// // //                         blurRadius: 8,
// // //                         spreadRadius: 1,
// // //                         offset: Offset(0, 4),
// // //                       ),
// // //                     ],
// // //                   ],
// // //                 ),
// // //                 child: ClipRRect(
// // //                   borderRadius: BorderRadius.circular(15),
// // //                   child: Stack(
// // //                     children: [
// // //                       _buildWebSeriesImage(),
// // //                       if (_isFocused) _buildFocusBorder(),
// // //                       _buildGradientOverlay(),
// // //                       _buildWebSeriesInfo(),
// // //                       if (_isFocused) _buildPlayButton(),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ),
// // //             );
// // //           },
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildWebSeriesImage() {
// // //     final imageUrl = widget.webSeries['poster']?.toString() ??
// // //         widget.webSeries['banner']?.toString() ??
// // //         '';

// // //     return Container(
// // //       width: double.infinity,
// // //       height: double.infinity,
// // //       child: imageUrl.isNotEmpty
// // //           ? CachedNetworkImage(
// // //               imageUrl: imageUrl,
// // //               fit: BoxFit.cover,
// // //               placeholder: (context, url) => _buildImagePlaceholder(),
// // //               errorWidget: (context, url, error) => _buildImagePlaceholder(),
// // //             )
// // //           : _buildImagePlaceholder(),
// // //     );
// // //   }

// // //   Widget _buildImagePlaceholder() {
// // //     return Container(
// // //       decoration: BoxDecoration(
// // //         gradient: LinearGradient(
// // //           begin: Alignment.topLeft,
// // //           end: Alignment.bottomRight,
// // //           colors: [
// // //             ProfessionalWebSeriesColors.cardDark,
// // //             ProfessionalWebSeriesColors.surfaceDark,
// // //           ],
// // //         ),
// // //       ),
// // //       child: Center(
// // //         child: Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: [
// // //             Icon(
// // //               Icons.tv_rounded,
// // //               size: 40,
// // //               color: ProfessionalWebSeriesColors.textSecondary,
// // //             ),
// // //             SizedBox(height: 8),
// // //             Text(
// // //               'No Image',
// // //               style: TextStyle(
// // //                 color: ProfessionalWebSeriesColors.textSecondary,
// // //                 fontSize: 10,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildFocusBorder() {
// // //     return Positioned.fill(
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(15),
// // //           border: Border.all(
// // //             width: 3,
// // //             color: _dominantColor,
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildGradientOverlay() {
// // //     return Positioned.fill(
// // //       child: Container(
// // //         decoration: BoxDecoration(
// // //           borderRadius: BorderRadius.circular(15),
// // //           gradient: LinearGradient(
// // //             begin: Alignment.topCenter,
// // //             end: Alignment.bottomCenter,
// // //             colors: [
// // //               Colors.transparent,
// // //               Colors.transparent,
// // //               Colors.black.withOpacity(0.7),
// // //               Colors.black.withOpacity(0.9),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildWebSeriesInfo() {
// // //     final seriesName = widget.webSeries['name']?.toString() ?? 'Unknown';

// // //     return Positioned(
// // //       bottom: 0,
// // //       left: 0,
// // //       right: 0,
// // //       child: Padding(
// // //         padding: EdgeInsets.all(12),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             Text(
// // //               seriesName.toUpperCase(),
// // //               style: TextStyle(
// // //                 color: _isFocused ? _dominantColor : Colors.white,
// // //                 fontSize: _isFocused ? 13 : 12,
// // //                 fontWeight: FontWeight.w600,
// // //                 letterSpacing: 0.5,
// // //                 shadows: [
// // //                   Shadow(
// // //                     color: Colors.black.withOpacity(0.8),
// // //                     blurRadius: 4,
// // //                     offset: Offset(0, 1),
// // //                   ),
// // //                 ],
// // //               ),
// // //               maxLines: 2,
// // //               overflow: TextOverflow.ellipsis,
// // //             ),
// // //             if (_isFocused) ...[
// // //               SizedBox(height: 4),
// // //               Row(
// // //                 children: [
// // //                   Container(
// // //                     padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// // //                     decoration: BoxDecoration(
// // //                       color: _dominantColor.withOpacity(0.2),
// // //                       borderRadius: BorderRadius.circular(8),
// // //                       border: Border.all(
// // //                         color: _dominantColor.withOpacity(0.4),
// // //                         width: 1,
// // //                       ),
// // //                     ),
// // //                     child: Row(
// // //                       mainAxisSize: MainAxisSize.min,
// // //                       children: [
// // //                         Icon(
// // //                           Icons.tv,
// // //                           color: _dominantColor,
// // //                           size: 8,
// // //                         ),
// // //                         SizedBox(width: 2),
// // //                         Text(
// // //                           'SERIES',
// // //                           style: TextStyle(
// // //                             color: _dominantColor,
// // //                             fontSize: 8,
// // //                             fontWeight: FontWeight.bold,
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                   SizedBox(width: 6),
// // //                   Container(
// // //                     padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.white.withOpacity(0.2),
// // //                       borderRadius: BorderRadius.circular(8),
// // //                     ),
// // //                     child: Text(
// // //                       'HD',
// // //                       style: TextStyle(
// // //                         color: Colors.white,
// // //                         fontSize: 8,
// // //                         fontWeight: FontWeight.bold,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ],
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildPlayButton() {
// // //     return Positioned(
// // //       top: 12,
// // //       right: 12,
// // //       child: Container(
// // //         width: 40,
// // //         height: 40,
// // //         decoration: BoxDecoration(
// // //           shape: BoxShape.circle,
// // //           color: _dominantColor.withOpacity(0.9),
// // //           boxShadow: [
// // //             BoxShadow(
// // //               color: _dominantColor.withOpacity(0.4),
// // //               blurRadius: 8,
// // //               offset: Offset(0, 2),
// // //             ),
// // //           ],
// // //         ),
// // //         child: Icon(
// // //           Icons.play_arrow_rounded,
// // //           color: Colors.white,
// // //           size: 24,
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // // Usage Instructions and Integration Guide
// // // /*
// // // 🎯 INTEGRATION GUIDE:

// // // 1. Replace your existing ManageWebseries class with ProfessionalManageWebseries
// // // 2. Replace ViewAllWidget with ProfessionalWebSeriesViewAllButton
// // // 3. Replace CategoryMoviesGridView with ProfessionalCategoryWebSeriesGridView
// // // 4. Add the Professional color scheme and timing classes

// // // 🔄 MAIN REPLACEMENTS:

// // // OLD CODE:
// // // ```dart
// // // class ManageWebseries extends StatefulWidget {
// // //   // ... existing code
// // // }
// // // ```

// // // NEW CODE:
// // // ```dart
// // // class ProfessionalManageWebseries extends StatefulWidget {
// // //   // ... enhanced code with animations
// // // }
// // // ```

// // // 🎨 KEY FEATURES ADDED:

// // // ✅ Professional color scheme matching movies
// // // ✅ Smooth animations (700ms duration like movies)
// // // ✅ Enhanced shadows and glow effects
// // // ✅ Professional loading indicators
// // // ✅ Shimmer effects on focus
// // // ✅ Staggered grid animations
// // // ✅ Enhanced app bar with gradients
// // // ✅ Better error handling
// // // ✅ Improved focus management
// // // ✅ TV series badges instead of movie badges
// // // ✅ Purple/Blue gradient theme for WebSeries

// // // 📱 RESULT:
// // // Your WebSeries screen will now perfectly match the professional
// // // Movies screen with consistent animations, colors, and effects!

// // // 🚀 All features from the Movies screen are now available for WebSeries:
// // // - Same animation timing (700ms)
// // // - Same scale effects (1.04x)
// // // - Same shadow patterns
// // // - Same shimmer effects
// // // - Same professional loading
// // // - Same grid layout
// // // - Same focus management
// // // */

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:math' as math;
// import 'dart:ui';

// // ✅ Professional Color Palette (same as Movies)
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

// // ✅ Professional Animation Durations
// class AnimationTiming {
//   static const Duration ultraFast = Duration(milliseconds: 150);
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
//   static const Duration slow = Duration(milliseconds: 600);
//   static const Duration focus = Duration(milliseconds: 300);
//   static const Duration scroll = Duration(milliseconds: 800);
// }

// // ✅ WebSeries Model (same structure)
// class WebSeriesModel {
//   final int id;
//   final String name;
//   final String? description;
//   final String? poster;
//   final String? banner;
//   final String? releaseDate;
//   final String? genres;

//   WebSeriesModel({
//     required this.id,
//     required this.name,
//     this.description,
//     this.poster,
//     this.banner,
//     this.releaseDate,
//     this.genres,
//   });

//   factory WebSeriesModel.fromJson(Map<String, dynamic> json) {
//     return WebSeriesModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       description: json['description'],
//       poster: json['poster'],
//       banner: json['banner'],
//       releaseDate: json['release_date'],
//       genres: json['genres'],
//     );
//   }
// }

// // 🚀 Enhanced WebSeries Service with Caching (Similar to TV Shows)
// class WebSeriesService {
//   // Cache keys
//   static const String _cacheKeyWebSeries = 'cached_web_series';
//   static const String _cacheKeyTimestamp = 'cached_web_series_timestamp';
//   static const String _cacheKeyAuthKey = 'auth_key';

//   // Cache duration (in milliseconds) - 1 hour
//   static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

//   /// Main method to get all web series with caching
//   static Future<List<WebSeriesModel>> getAllWebSeries({bool forceRefresh = false}) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // Check if we should use cache
//       if (!forceRefresh && await _shouldUseCache(prefs)) {
//         print('📦 Loading Web Series from cache...');
//         final cachedWebSeries = await _getCachedWebSeries(prefs);
//         if (cachedWebSeries.isNotEmpty) {
//           print('✅ Successfully loaded ${cachedWebSeries.length} web series from cache');

//           // Load fresh data in background (without waiting)
//           _loadFreshDataInBackground();

//           return cachedWebSeries;
//         }
//       }

//       // Load fresh data if no cache or force refresh
//       print('🌐 Loading fresh Web Series from API...');
//       return await _fetchFreshWebSeries(prefs);

//     } catch (e) {
//       print('❌ Error in getAllWebSeries: $e');

//       // Try to return cached data as fallback
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final cachedWebSeries = await _getCachedWebSeries(prefs);
//         if (cachedWebSeries.isNotEmpty) {
//           print('🔄 Returning cached data as fallback');
//           return cachedWebSeries;
//         }
//       } catch (cacheError) {
//         print('❌ Cache fallback also failed: $cacheError');
//       }

//       throw Exception('Failed to load web series: $e');
//     }
//   }

//   /// Check if cached data is still valid
//   static Future<bool> _shouldUseCache(SharedPreferences prefs) async {
//     try {
//       final timestampStr = prefs.getString(_cacheKeyTimestamp);
//       if (timestampStr == null) return false;

//       final cachedTimestamp = int.tryParse(timestampStr);
//       if (cachedTimestamp == null) return false;

//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
//       final cacheAge = currentTimestamp - cachedTimestamp;

//       final isValid = cacheAge < _cacheDurationMs;

//       if (isValid) {
//         final ageMinutes = (cacheAge / (1000 * 60)).round();
//         print('📦 WebSeries Cache is valid (${ageMinutes} minutes old)');
//       } else {
//         final ageMinutes = (cacheAge / (1000 * 60)).round();
//         print('⏰ WebSeries Cache expired (${ageMinutes} minutes old)');
//       }

//       return isValid;
//     } catch (e) {
//       print('❌ Error checking WebSeries cache validity: $e');
//       return false;
//     }
//   }

//   /// Get web series from cache
//   static Future<List<WebSeriesModel>> _getCachedWebSeries(SharedPreferences prefs) async {
//     try {
//       final cachedData = prefs.getString(_cacheKeyWebSeries);
//       if (cachedData == null || cachedData.isEmpty) {
//         print('📦 No cached WebSeries data found');
//         return [];
//       }

//       final List<dynamic> jsonData = json.decode(cachedData);
//       final webSeries = jsonData
//           .map((json) => WebSeriesModel.fromJson(json as Map<String, dynamic>))
//           .toList();

//       print('📦 Successfully loaded ${webSeries.length} web series from cache');
//       return webSeries;
//     } catch (e) {
//       print('❌ Error loading cached web series: $e');
//       return [];
//     }
//   }

//   /// Fetch fresh web series from API and cache them
//   static Future<List<WebSeriesModel>> _fetchFreshWebSeries(SharedPreferences prefs) async {
//     try {
//       String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';

//       final response = await http.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllWebSeries'),
//         headers: {
//           'auth-key': authKey,
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ).timeout(
//         const Duration(seconds: 30),
//         onTimeout: () {
//           throw Exception('Request timeout');
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);

//         final webSeries = jsonData
//             .map((json) => WebSeriesModel.fromJson(json as Map<String, dynamic>))
//             .toList();

//         // Cache the fresh data
//         await _cacheWebSeries(prefs, jsonData);

//         print('✅ Successfully loaded ${webSeries.length} fresh web series from API');
//         return webSeries;

//       } else {
//         throw Exception('API Error: ${response.statusCode} - ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('❌ Error fetching fresh web series: $e');
//       rethrow;
//     }
//   }

//   /// Cache web series data
//   static Future<void> _cacheWebSeries(SharedPreferences prefs, List<dynamic> webSeriesData) async {
//     try {
//       final jsonString = json.encode(webSeriesData);
//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

//       // Save web series data and timestamp
//       await Future.wait([
//         prefs.setString(_cacheKeyWebSeries, jsonString),
//         prefs.setString(_cacheKeyTimestamp, currentTimestamp),
//       ]);

//       print('💾 Successfully cached ${webSeriesData.length} web series');
//     } catch (e) {
//       print('❌ Error caching web series: $e');
//     }
//   }

//   /// Load fresh data in background without blocking UI
//   static void _loadFreshDataInBackground() {
//     Future.delayed(const Duration(milliseconds: 500), () async {
//       try {
//         print('🔄 Loading fresh web series data in background...');
//         final prefs = await SharedPreferences.getInstance();
//         await _fetchFreshWebSeries(prefs);
//         print('✅ WebSeries background refresh completed');
//       } catch (e) {
//         print('⚠️ WebSeries background refresh failed: $e');
//       }
//     });
//   }

//   /// Clear all cached data
//   static Future<void> clearCache() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await Future.wait([
//         prefs.remove(_cacheKeyWebSeries),
//         prefs.remove(_cacheKeyTimestamp),
//       ]);
//       print('🗑️ WebSeries cache cleared successfully');
//     } catch (e) {
//       print('❌ Error clearing WebSeries cache: $e');
//     }
//   }

//   /// Get cache info for debugging
//   static Future<Map<String, dynamic>> getCacheInfo() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final timestampStr = prefs.getString(_cacheKeyTimestamp);
//       final cachedData = prefs.getString(_cacheKeyWebSeries);

//       if (timestampStr == null || cachedData == null) {
//         return {
//           'hasCachedData': false,
//           'cacheAge': 0,
//           'cachedWebSeriesCount': 0,
//           'cacheSize': 0,
//         };
//       }

//       final cachedTimestamp = int.tryParse(timestampStr) ?? 0;
//       final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
//       final cacheAge = currentTimestamp - cachedTimestamp;
//       final cacheAgeMinutes = (cacheAge / (1000 * 60)).round();

//       final List<dynamic> jsonData = json.decode(cachedData);
//       final cacheSizeKB = (cachedData.length / 1024).round();

//       return {
//         'hasCachedData': true,
//         'cacheAge': cacheAgeMinutes,
//         'cachedWebSeriesCount': jsonData.length,
//         'cacheSize': cacheSizeKB,
//         'isValid': cacheAge < _cacheDurationMs,
//       };
//     } catch (e) {
//       print('❌ Error getting WebSeries cache info: $e');
//       return {
//         'hasCachedData': false,
//         'cacheAge': 0,
//         'cachedWebSeriesCount': 0,
//         'cacheSize': 0,
//         'error': e.toString(),
//       };
//     }
//   }

//   /// Force refresh data (bypass cache)
//   static Future<List<WebSeriesModel>> forceRefresh() async {
//     print('🔄 Force refreshing WebSeries data...');
//     return await getAllWebSeries(forceRefresh: true);
//   }
// }

// // 🚀 Enhanced ProfessionalWebSeriesHorizontalList with Caching
// class ProfessionalWebSeriesHorizontalList extends StatefulWidget {
//   @override
//   _ProfessionalWebSeriesHorizontalListState createState() =>
//       _ProfessionalWebSeriesHorizontalListState();
// }

// class _ProfessionalWebSeriesHorizontalListState
//     extends State<ProfessionalWebSeriesHorizontalList>
//     with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<WebSeriesModel> webSeriesList = [];
//   bool isLoading = true;
//   int focusedIndex = -1;
//   final int maxHorizontalItems = 7;
//   Color _currentAccentColor = ProfessionalColors.accentPurple;

//   // Animation Controllers
//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   Map<String, FocusNode> webseriesFocusNodes = {};
//   FocusNode? _viewAllFocusNode;
//   FocusNode? _firstWebSeriesFocusNode;
//   bool _hasReceivedFocusFromMovies = false;

//   late ScrollController _scrollController;
//   final double _itemWidth = 156.0;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _initializeAnimations();
//     _initializeFocusNodes();

//     // 🚀 Use enhanced caching service
//     fetchWebSeriesWithCache();
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

//   void _initializeFocusNodes() {
//     _viewAllFocusNode = FocusNode();
//     print('✅ WebSeries focus nodes initialized');
//   }

//   void _scrollToPosition(int index) {
//     if (index < webSeriesList.length && index < maxHorizontalItems) {
//       String webSeriesId = webSeriesList[index].id.toString();
//       if (webseriesFocusNodes.containsKey(webSeriesId)) {
//         final focusNode = webseriesFocusNodes[webSeriesId]!;

//         Scrollable.ensureVisible(
//           focusNode.context!,
//           duration: AnimationTiming.scroll,
//           curve: Curves.easeInOutCubic,
//           alignment: 0.03,
//           alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
//         );

//         print('🎯 Scrollable.ensureVisible for index $index: ${webSeriesList[index].name}');
//       }
//     } else if (index == maxHorizontalItems && _viewAllFocusNode != null) {
//       Scrollable.ensureVisible(
//         _viewAllFocusNode!.context!,
//         duration: AnimationTiming.scroll,
//         curve: Curves.easeInOutCubic,
//         alignment: 0.2,
//         alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
//       );

//       print('🎯 Scrollable.ensureVisible for ViewAll button');
//     }
//   }

//   void _setupFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && webSeriesList.isNotEmpty) {
//         try {
//           final focusProvider = Provider.of<FocusProvider>(context, listen: false);

//           final firstWebSeriesId = webSeriesList[0].id.toString();

//           if (!webseriesFocusNodes.containsKey(firstWebSeriesId)) {
//             webseriesFocusNodes[firstWebSeriesId] = FocusNode();
//             print('✅ Created focus node for first webseries: $firstWebSeriesId');
//           }

//           _firstWebSeriesFocusNode = webseriesFocusNodes[firstWebSeriesId];

//           _firstWebSeriesFocusNode!.addListener(() {
//             if (_firstWebSeriesFocusNode!.hasFocus && !_hasReceivedFocusFromMovies) {
//               _hasReceivedFocusFromMovies = true;
//               setState(() {
//                 focusedIndex = 0;
//               });
//               _scrollToPosition(0);
//               print('✅ WebSeries received focus from movies and scrolled');
//             }
//           });

//           focusProvider.setFirstManageWebseriesFocusNode(_firstWebSeriesFocusNode!);
//           print('✅ WebSeries first focus node registered: ${webSeriesList[0].name}');

//         } catch (e) {
//           print('❌ WebSeries focus provider setup failed: $e');
//         }
//       }
//     });
//   }

//   // 🚀 Enhanced fetch method with caching
//   Future<void> fetchWebSeriesWithCache() async {
//     if (!mounted) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Use cached data first, then fresh data
//       final fetchedWebSeries = await WebSeriesService.getAllWebSeries();

//       if (fetchedWebSeries.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             webSeriesList = fetchedWebSeries;
//             isLoading = false;
//           });

//           _createFocusNodesForItems();
//           _setupFocusProvider();

//           // Start animations after data loads
//           _headerAnimationController.forward();
//           _listAnimationController.forward();

//           // Debug cache info
//           _debugCacheInfo();
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//       print('Error fetching WebSeries with cache: $e');
//     }
//   }

//   // 🆕 Debug method to show cache information
//   Future<void> _debugCacheInfo() async {
//     try {
//       final cacheInfo = await WebSeriesService.getCacheInfo();
//       print('📊 WebSeries Cache Info: $cacheInfo');
//     } catch (e) {
//       print('❌ Error getting WebSeries cache info: $e');
//     }
//   }

//   // 🆕 Force refresh web series
//   Future<void> _forceRefreshWebSeries() async {
//     if (!mounted) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Force refresh bypasses cache
//       final fetchedWebSeries = await WebSeriesService.forceRefresh();

//       if (fetchedWebSeries.isNotEmpty) {
//         if (mounted) {
//           setState(() {
//             webSeriesList = fetchedWebSeries;
//             isLoading = false;
//           });

//           _createFocusNodesForItems();
//           _setupFocusProvider();

//           _headerAnimationController.forward();
//           _listAnimationController.forward();

//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Web Series refreshed successfully'),
//               backgroundColor: ProfessionalColors.accentPurple,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           );
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//       print('❌ Error force refreshing web series: $e');
//     }
//   }

//   void _createFocusNodesForItems() {
//     for (var node in webseriesFocusNodes.values) {
//       try {
//         node.removeListener(() {});
//         node.dispose();
//       } catch (e) {}
//     }
//     webseriesFocusNodes.clear();

//     for (int i = 0; i < webSeriesList.length && i < maxHorizontalItems; i++) {
//       String webSeriesId = webSeriesList[i].id.toString();
//       if (!webseriesFocusNodes.containsKey(webSeriesId)) {
//         webseriesFocusNodes[webSeriesId] = FocusNode();

//         webseriesFocusNodes[webSeriesId]!.addListener(() {
//           if (mounted && webseriesFocusNodes[webSeriesId]!.hasFocus) {
//             setState(() {
//               focusedIndex = i;
//               _hasReceivedFocusFromMovies = true;
//             });
//             _scrollToPosition(i);
//             print('✅ WebSeries $i focused and scrolled: ${webSeriesList[i].name}');
//           }
//         });
//       }
//     }
//     print('✅ Created ${webseriesFocusNodes.length} webseries focus nodes with auto-scroll');
//   }

//   void _navigateToWebSeriesDetails(WebSeriesModel webSeries) {
//     print('🎬 Navigating to WebSeries Details: ${webSeries.name}');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => WebSeriesDetailsPage(
//           id: webSeries.id,
//           banner: webSeries.banner ?? webSeries.poster ?? '',
//           poster: webSeries.poster ?? webSeries.banner ?? '',
//           name: webSeries.name,
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from WebSeries Details');
//       Future.delayed(Duration(milliseconds: 300), () {
//         if (mounted) {
//           int currentIndex = webSeriesList.indexWhere((ws) => ws.id == webSeries.id);
//           if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
//             String webSeriesId = webSeries.id.toString();
//             if (webseriesFocusNodes.containsKey(webSeriesId)) {
//               setState(() {
//                 focusedIndex = currentIndex;
//                 _hasReceivedFocusFromMovies = true;
//               });
//               webseriesFocusNodes[webSeriesId]!.requestFocus();
//               _scrollToPosition(currentIndex);
//               print('✅ Restored focus to ${webSeries.name}');
//             }
//           }
//         }
//       });
//     });
//   }

//   void _navigateToGridPage() {
//     print('🎬 Navigating to WebSeries Grid Page...');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProfessionalWebSeriesGridPage(
//           webSeriesList: webSeriesList,
//           title: 'Web Series',
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from grid page');
//       Future.delayed(Duration(milliseconds: 300), () {
//         if (mounted && _viewAllFocusNode != null) {
//           setState(() {
//             focusedIndex = maxHorizontalItems;
//             _hasReceivedFocusFromMovies = true;
//           });
//           _viewAllFocusNode!.requestFocus();
//           _scrollToPosition(maxHorizontalItems);
//           print('✅ Focused back to ViewAll button and scrolled');
//         }
//       });
//     });
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   super.build(context);
//   //   final screenWidth = MediaQuery.of(context).size.width;
//   //   final screenHeight = MediaQuery.of(context).size.height;

//   //   return

//   //    Scaffold(
//   //     backgroundColor: Colors.transparent,
//   //     body: Container(
//   //       decoration: BoxDecoration(
//   //         gradient: LinearGradient(
//   //           begin: Alignment.topCenter,
//   //           end: Alignment.bottomCenter,
//   //           colors: [
//   //             ProfessionalColors.primaryDark,
//   //             ProfessionalColors.surfaceDark.withOpacity(0.5),
//   //           ],
//   //         ),
//   //       ),
//   //       child: Column(
//   //         children: [
//   //           SizedBox(height: screenHeight * 0.02),
//   //           _buildProfessionalTitle(screenWidth),
//   //           SizedBox(height: screenHeight * 0.01),
//   //           Expanded(child: _buildBody(screenWidth, screenHeight)),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   //   @override
//   // void initState() {
//   //   super.initState();
//   //   _scrollController = ScrollController();
//   //   _initializeAnimations();
//   //   _initializeFocusNodes();

//   //   fetchWebSeriesWithCache();
//   // }

//   // ... [Keep all existing methods until build method]

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     // ✅ ADD: Consumer to listen to color changes
//     return Consumer<ColorProvider>(
//       builder: (context, colorProvider, child) {
//         final bgColor = colorProvider.isItemFocused
//             ? colorProvider.dominantColor.withOpacity(0.1)
//             : ProfessionalColors.primaryDark;

//         return Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Container(
//             // ✅ ENHANCED: Dynamic background gradient based on focused item
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   bgColor,
//                   // ProfessionalColors.primaryDark,
//                   // ProfessionalColors.surfaceDark.withOpacity(0.5),

//                      bgColor.withOpacity(0.8),
//                 ProfessionalColors.primaryDark,
//                 ],
//               ),
//             ),
//             child: Column(
//               children: [
//                 SizedBox(height: screenHeight * 0.02),
//                 _buildProfessionalTitle(screenWidth),
//                 SizedBox(height: screenHeight * 0.01),
//                 Expanded(child: _buildBody(screenWidth, screenHeight)),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // 🚀 Enhanced Title with Cache Status and Refresh Button
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
//                   ProfessionalColors.accentPurple,
//                   ProfessionalColors.accentBlue,
//                 ],
//               ).createShader(bounds),
//               child: Text(
//                 'WEB SERIES',
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2.0,
//                 ),
//               ),
//             ),
//             Row(
//               children: [
//                 // // 🆕 Refresh Button
//                 // GestureDetector(
//                 //   onTap: isLoading ? null : _forceRefreshWebSeries,
//                 //   child: Container(
//                 //     padding: const EdgeInsets.all(8),
//                 //     decoration: BoxDecoration(
//                 //       color: ProfessionalColors.accentPurple.withOpacity(0.2),
//                 //       borderRadius: BorderRadius.circular(8),
//                 //       border: Border.all(
//                 //         color: ProfessionalColors.accentPurple.withOpacity(0.3),
//                 //         width: 1,
//                 //       ),
//                 //     ),
//                 //     child: isLoading
//                 //         ? SizedBox(
//                 //             width: 16,
//                 //             height: 16,
//                 //             child: CircularProgressIndicator(
//                 //               strokeWidth: 2,
//                 //               valueColor: AlwaysStoppedAnimation<Color>(
//                 //                 ProfessionalColors.accentPurple,
//                 //               ),
//                 //             ),
//                 //           )
//                 //         : Icon(
//                 //             Icons.refresh,
//                 //             size: 16,
//                 //             color: ProfessionalColors.accentPurple,
//                 //           ),
//                 //   ),
//                 // ),
//                 // const SizedBox(width: 12),
//                 // Web Series Count
//                 if (webSeriesList.length > 0)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           ProfessionalColors.accentPurple.withOpacity(0.2),
//                           ProfessionalColors.accentBlue.withOpacity(0.2),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: ProfessionalColors.accentPurple.withOpacity(0.3),
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       '${webSeriesList.length} Series Available',
//                       style: const TextStyle(
//                         color: ProfessionalColors.textSecondary,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(double screenWidth, double screenHeight) {
//     if (isLoading) {
//       return ProfessionalWebSeriesLoadingIndicator(
//           message: 'Loading Web Series...');
//     } else if (webSeriesList.isEmpty) {
//       return _buildEmptyWidget();
//     } else {
//       return _buildWebSeriesList(screenWidth, screenHeight);
//     }
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
//                   ProfessionalColors.accentPurple.withOpacity(0.2),
//                   ProfessionalColors.accentPurple.withOpacity(0.1),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.tv_outlined,
//               size: 40,
//               color: ProfessionalColors.accentPurple,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No Web Series Found',
//             style: TextStyle(
//               color: ProfessionalColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Check back later for new episodes',
//             style: TextStyle(
//               color: ProfessionalColors.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWebSeriesList(double screenWidth, double screenHeight) {
//     bool showViewAll = webSeriesList.length > 7;

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
//           itemCount: showViewAll ? 8 : webSeriesList.length,
//           itemBuilder: (context, index) {
//             if (showViewAll && index == 7) {
//               return Focus(
//                 focusNode: _viewAllFocusNode,
//                 onFocusChange: (hasFocus) {
//                   if (hasFocus && mounted) {
//                     Color viewAllColor = ProfessionalColors.gradientColors[
//                         math.Random().nextInt(ProfessionalColors.gradientColors.length)];

//                     setState(() {
//                       _currentAccentColor = viewAllColor;
//                     });
//                   }
//                 },
//                 onKey: (FocusNode node, RawKeyEvent event) {
//                   if (event is RawKeyDownEvent) {
//                     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//                       if (webSeriesList.isNotEmpty && webSeriesList.length > 6) {
//                         String webSeriesId = webSeriesList[6].id.toString();
//                         FocusScope.of(context).requestFocus(webseriesFocusNodes[webSeriesId]);
//                         return KeyEventResult.handled;
//                       }
//                     } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                       setState(() {
//                         focusedIndex = -1;
//                         _hasReceivedFocusFromMovies = false;
//                       });
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 100), () {
//                         if (mounted) {
//                           try {
//                             Provider.of<FocusProvider>(context, listen: false)
//                                 .requestFirstMoviesFocus();
//                             print('✅ Navigating back to movies from webseries');
//                           } catch (e) {
//                             print('❌ Failed to navigate to movies: $e');
//                           }
//                         }
//                       });
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                       setState(() {
//                         focusedIndex = -1;
//                         _hasReceivedFocusFromMovies = false;
//                       });
//                       FocusScope.of(context).unfocus();
//                       Future.delayed(const Duration(milliseconds: 100), () {
//                         if (mounted) {
//                           try {
//                             Provider.of<FocusProvider>(context, listen: false)
//                                 .requestFirstTVShowsFocus();
//                             print('✅ Navigating to TV Shows from webseries ViewAll');
//                           } catch (e) {
//                             print('❌ Failed to navigate to TV Shows: $e');
//                           }
//                         }
//                       });
//                       return KeyEventResult.handled;
//                     } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//                                event.logicalKey == LogicalKeyboardKey.select) {
//                       print('🎬 ViewAll button pressed - Opening Grid Page...');
//                       _navigateToGridPage();
//                       return KeyEventResult.handled;
//                     }
//                   }
//                   return KeyEventResult.ignored;
//                 },
//                 child: GestureDetector(
//                   onTap: _navigateToGridPage,
//                   child: ProfessionalWebSeriesViewAllButton(
//                     focusNode: _viewAllFocusNode!,
//                     onTap: _navigateToGridPage,
//                     totalItems: webSeriesList.length,
//                     itemType: 'WEB SERIES',
//                   ),
//                 ),
//               );
//             }

//             var webSeries = webSeriesList[index];
//             return _buildWebSeriesItem(webSeries, index, screenWidth, screenHeight);
//           },
//         ),
//       ),
//     );
//   }

//     // ✅ ENHANCED: WebSeries item with color provider integration
//   Widget _buildWebSeriesItem(WebSeriesModel webSeries, int index, double screenWidth, double screenHeight) {
//     String webSeriesId = webSeries.id.toString();

//     webseriesFocusNodes.putIfAbsent(
//       webSeriesId,
//       () => FocusNode()
//         ..addListener(() {
//           if (mounted && webseriesFocusNodes[webSeriesId]!.hasFocus) {
//             _scrollToPosition(index);
//           }
//         }),
//     );

//     return Focus(
//       focusNode: webseriesFocusNodes[webSeriesId],
//       onFocusChange: (hasFocus) async {
//         if (hasFocus && mounted) {
//           try {
//             Color dominantColor = ProfessionalColors.gradientColors[
//                 math.Random().nextInt(ProfessionalColors.gradientColors.length)];

//             setState(() {
//               _currentAccentColor = dominantColor;
//               focusedIndex = index;
//               _hasReceivedFocusFromMovies = true;
//             });

//             // ✅ ADD: Update color provider
//             context.read<ColorProvider>().updateColor(dominantColor, true);
//           } catch (e) {
//             print('Focus change handling failed: $e');
//           }
//         } else if (mounted) {
//           // ✅ ADD: Reset color when focus lost
//           context.read<ColorProvider>().resetColor();
//         }
//       },
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//             if (index < webSeriesList.length - 1 && index != 6) {
//               String nextWebSeriesId = webSeriesList[index + 1].id.toString();
//               FocusScope.of(context).requestFocus(webseriesFocusNodes[nextWebSeriesId]);
//               return KeyEventResult.handled;
//             } else if (index == 6 && webSeriesList.length > 7) {
//               FocusScope.of(context).requestFocus(_viewAllFocusNode);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//             if (index > 0) {
//               String prevWebSeriesId = webSeriesList[index - 1].id.toString();
//               FocusScope.of(context).requestFocus(webseriesFocusNodes[prevWebSeriesId]);
//               return KeyEventResult.handled;
//             }
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             setState(() {
//               focusedIndex = -1;
//               _hasReceivedFocusFromMovies = false;
//             });
//             // ✅ ADD: Reset color when navigating away
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 100), () {
//               if (mounted) {
//                 try {
//                   Provider.of<FocusProvider>(context, listen: false)
//                       .requestFirstMoviesFocus();
//                   print('✅ Navigating back to movies from webseries');
//                 } catch (e) {
//                   print('❌ Failed to navigate to movies: $e');
//                 }
//               }
//             });
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//             setState(() {
//               focusedIndex = -1;
//               _hasReceivedFocusFromMovies = false;
//             });
//             // ✅ ADD: Reset color when navigating away
//             context.read<ColorProvider>().resetColor();
//             FocusScope.of(context).unfocus();
//             Future.delayed(const Duration(milliseconds: 100), () {
//               if (mounted) {
//                 try {
//                   Provider.of<FocusProvider>(context, listen: false)
//                       .requestFirstTVShowsFocus();
//                   print('✅ Navigating to TV Shows from webseries');
//                 } catch (e) {
//                   print('❌ Failed to navigate to TV Shows: $e');
//                 }
//               }
//             });
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//                      event.logicalKey == LogicalKeyboardKey.select) {
//             print('🎬 Enter pressed on ${webSeries.name} - Opening Details Page...');
//             _navigateToWebSeriesDetails(webSeries);
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () => _navigateToWebSeriesDetails(webSeries),
//         child: ProfessionalWebSeriesCard(
//           webSeries: webSeries,
//           focusNode: webseriesFocusNodes[webSeriesId]!,
//           onTap: () => _navigateToWebSeriesDetails(webSeries),
//           onColorChange: (color) {
//             setState(() {
//               _currentAccentColor = color;
//             });
//             // ✅ ADD: Update color provider when card changes color
//             context.read<ColorProvider>().updateColor(color, true);
//           },
//           index: index,
//           categoryTitle: 'WEB SERIES',
//         ),
//       ),
//     );
//   }

//   // Widget _buildWebSeriesItem(WebSeriesModel webSeries, int index, double screenWidth, double screenHeight) {
//   //   String webSeriesId = webSeries.id.toString();

//   //   webseriesFocusNodes.putIfAbsent(
//   //     webSeriesId,
//   //     () => FocusNode()
//   //       ..addListener(() {
//   //         if (mounted && webseriesFocusNodes[webSeriesId]!.hasFocus) {
//   //           _scrollToPosition(index);
//   //         }
//   //       }),
//   //   );

//   //   return Focus(
//   //     focusNode: webseriesFocusNodes[webSeriesId],
//   //     onFocusChange: (hasFocus) async {
//   //       if (hasFocus && mounted) {
//   //         try {
//   //           Color dominantColor = ProfessionalColors.gradientColors[
//   //               math.Random().nextInt(ProfessionalColors.gradientColors.length)];

//   //           setState(() {
//   //             _currentAccentColor = dominantColor;
//   //             focusedIndex = index;
//   //             _hasReceivedFocusFromMovies = true;
//   //           });
//   //         } catch (e) {
//   //           print('Focus change handling failed: $e');
//   //         }
//   //       }
//   //     },
//   //     onKey: (FocusNode node, RawKeyEvent event) {
//   //       if (event is RawKeyDownEvent) {
//   //         if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//   //           if (index < webSeriesList.length - 1 && index != 6) {
//   //             String nextWebSeriesId = webSeriesList[index + 1].id.toString();
//   //             FocusScope.of(context).requestFocus(webseriesFocusNodes[nextWebSeriesId]);
//   //             return KeyEventResult.handled;
//   //           } else if (index == 6 && webSeriesList.length > 7) {
//   //             FocusScope.of(context).requestFocus(_viewAllFocusNode);
//   //             return KeyEventResult.handled;
//   //           }
//   //         } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//   //           if (index > 0) {
//   //             String prevWebSeriesId = webSeriesList[index - 1].id.toString();
//   //             FocusScope.of(context).requestFocus(webseriesFocusNodes[prevWebSeriesId]);
//   //             return KeyEventResult.handled;
//   //           }
//   //         } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//   //           setState(() {
//   //             focusedIndex = -1;
//   //             _hasReceivedFocusFromMovies = false;
//   //           });
//   //           FocusScope.of(context).unfocus();
//   //           Future.delayed(const Duration(milliseconds: 100), () {
//   //             if (mounted) {
//   //               try {
//   //                 Provider.of<FocusProvider>(context, listen: false)
//   //                     .requestFirstMoviesFocus();
//   //                 print('✅ Navigating back to movies from webseries');
//   //               } catch (e) {
//   //                 print('❌ Failed to navigate to movies: $e');
//   //               }
//   //             }
//   //           });
//   //           return KeyEventResult.handled;
//   //         } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//   //           setState(() {
//   //             focusedIndex = -1;
//   //             _hasReceivedFocusFromMovies = false;
//   //           });
//   //           FocusScope.of(context).unfocus();
//   //           Future.delayed(const Duration(milliseconds: 100), () {
//   //             if (mounted) {
//   //               try {
//   //                 Provider.of<FocusProvider>(context, listen: false)
//   //                     .requestFirstTVShowsFocus();
//   //                 print('✅ Navigating to TV Shows from webseries');
//   //               } catch (e) {
//   //                 print('❌ Failed to navigate to TV Shows: $e');
//   //               }
//   //             }
//   //           });
//   //           return KeyEventResult.handled;
//   //         } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//   //                    event.logicalKey == LogicalKeyboardKey.select) {
//   //           print('🎬 Enter pressed on ${webSeries.name} - Opening Details Page...');
//   //           _navigateToWebSeriesDetails(webSeries);
//   //           return KeyEventResult.handled;
//   //         }
//   //       }
//   //       return KeyEventResult.ignored;
//   //     },
//   //     child: GestureDetector(
//   //       onTap: () => _navigateToWebSeriesDetails(webSeries),
//   //       child: ProfessionalWebSeriesCard(
//   //         webSeries: webSeries,
//   //         focusNode: webseriesFocusNodes[webSeriesId]!,
//   //         onTap: () => _navigateToWebSeriesDetails(webSeries),
//   //         onColorChange: (color) {
//   //           setState(() {
//   //             _currentAccentColor = color;
//   //           });
//   //         },
//   //         index: index,
//   //         categoryTitle: 'WEB SERIES',
//   //       ),
//   //     ),
//   //   );
//   // }

//   @override
//   void dispose() {
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();

//     for (var entry in webseriesFocusNodes.entries) {
//       try {
//         entry.value.removeListener(() {});
//         entry.value.dispose();
//       } catch (e) {}
//     }
//     webseriesFocusNodes.clear();

//     try {
//       _viewAllFocusNode?.removeListener(() {});
//       _viewAllFocusNode?.dispose();
//     } catch (e) {}

//     try {
//       _scrollController.dispose();
//     } catch (e) {}

//     super.dispose();
//   }
// }

// // 🚀 Enhanced Cache Management Utility Class
// class CacheManager {
//   /// Clear all app caches
//   static Future<void> clearAllCaches() async {
//     try {
//       await Future.wait([
//         WebSeriesService.clearCache(),
//         // Add other service cache clears here
//         // MoviesService.clearCache(),
//         // TVShowsService.clearCache(),
//       ]);
//       print('🗑️ All caches cleared successfully');
//     } catch (e) {
//       print('❌ Error clearing all caches: $e');
//     }
//   }

//   /// Get comprehensive cache info for all services
//   static Future<Map<String, dynamic>> getAllCacheInfo() async {
//     try {
//       final webSeriesCacheInfo = await WebSeriesService.getCacheInfo();
//       // Add other service cache info here
//       // final moviesCacheInfo = await MoviesService.getCacheInfo();
//       // final tvShowsCacheInfo = await TVShowsService.getCacheInfo();

//       return {
//         'webSeries': webSeriesCacheInfo,
//         // 'movies': moviesCacheInfo,
//         // 'tvShows': tvShowsCacheInfo,
//         'totalCacheSize': _calculateTotalCacheSize([
//           webSeriesCacheInfo,
//           // moviesCacheInfo,
//           // tvShowsCacheInfo,
//         ]),
//       };
//     } catch (e) {
//       print('❌ Error getting all cache info: $e');
//       return {
//         'error': e.toString(),
//         'webSeries': {'hasCachedData': false},
//       };
//     }
//   }

//   static int _calculateTotalCacheSize(List<Map<String, dynamic>> cacheInfos) {
//     int totalSize = 0;
//     for (final info in cacheInfos) {
//       if (info['cacheSize'] is int) {
//         totalSize += info['cacheSize'] as int;
//       }
//     }
//     return totalSize;
//   }

//   /// Force refresh all data
//   static Future<void> forceRefreshAllData() async {
//     try {
//       await Future.wait([
//         WebSeriesService.forceRefresh(),
//         // Add other service force refreshes here
//         // MoviesService.forceRefresh(),
//         // TVShowsService.forceRefresh(),
//       ]);
//       print('🔄 All data force refreshed successfully');
//     } catch (e) {
//       print('❌ Error force refreshing all data: $e');
//     }
//   }
// }

// // ✅ Professional WebSeries Card (Movies style)
// class ProfessionalWebSeriesCard extends StatefulWidget {
//   final WebSeriesModel webSeries;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final Function(Color) onColorChange;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalWebSeriesCard({
//     Key? key,
//     required this.webSeries,
//     required this.focusNode,
//     required this.onTap,
//     required this.onColorChange,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesCardState createState() => _ProfessionalWebSeriesCardState();
// }

// class _ProfessionalWebSeriesCardState extends State<ProfessionalWebSeriesCard>
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
//             _buildWebSeriesImage(screenWidth, posterHeight),
//             if (_isFocused) _buildFocusBorder(),
//             if (_isFocused) _buildShimmerEffect(),
//             _buildGenreBadge(),
//             if (_isFocused) _buildHoverOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWebSeriesImage(double screenWidth, double posterHeight) {
//     return Container(
//       width: double.infinity,
//       height: posterHeight,
//       child: widget.webSeries.banner != null && widget.webSeries.banner!.isNotEmpty
//           ? Image.network(
//               widget.webSeries.banner!,
//               fit: BoxFit.cover,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return _buildImagePlaceholder(posterHeight);
//               },
//               errorBuilder: (context, error, stackTrace) =>
//                   _buildImagePlaceholder(posterHeight),
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
//           Text(
//             'WEB SERIES',
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
//               color: ProfessionalColors.accentPurple.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'HD',
//               style: TextStyle(
//                 color: ProfessionalColors.accentPurple,
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

//   Widget _buildGenreBadge() {
//     String genre = 'SERIES';
//     Color badgeColor = ProfessionalColors.accentPurple;

//     if (widget.webSeries.genres != null) {
//       if (widget.webSeries.genres!.toLowerCase().contains('drama')) {
//         genre = 'DRAMA';
//         badgeColor = ProfessionalColors.accentPurple;
//       } else if (widget.webSeries.genres!.toLowerCase().contains('thriller')) {
//         genre = 'THRILLER';
//         badgeColor = ProfessionalColors.accentRed;
//       } else if (widget.webSeries.genres!.toLowerCase().contains('comedy')) {
//         genre = 'COMEDY';
//         badgeColor = ProfessionalColors.accentGreen;
//       } else if (widget.webSeries.genres!.toLowerCase().contains('romance')) {
//         genre = 'ROMANCE';
//         badgeColor = ProfessionalColors.accentPink;
//       }
//     }

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
//           genre,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 8,
//             fontWeight: FontWeight.bold,
//           ),
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
//             child: Icon(
//               Icons.play_arrow_rounded,
//               color: _dominantColor,
//               size: 30,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionalTitle(double screenWidth) {
//     final webSeriesName = widget.webSeries.name.toUpperCase();

//     return Container(
//       width: bannerwdt,
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
//           webSeriesName,
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// // ✅ Professional View All Button (same as movies)
// class ProfessionalWebSeriesViewAllButton extends StatefulWidget {
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int totalItems;
//   final String itemType;

//   const ProfessionalWebSeriesViewAllButton({
//     Key? key,
//     required this.focusNode,
//     required this.onTap,
//     required this.totalItems,
//     this.itemType = 'WEB SERIES',
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesViewAllButtonState createState() =>
//       _ProfessionalWebSeriesViewAllButtonState();
// }

// class _ProfessionalWebSeriesViewAllButtonState extends State<ProfessionalWebSeriesViewAllButton>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _rotateController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _rotateAnimation;

//   bool _isFocused = false;
//   Color _currentColor = ProfessionalColors.accentPurple;

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
//       width: bannerwdt,
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
//                     height: _isFocused ? screenHeight * 0.28 : screenHeight * 0.22,
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
//                   Icons.tv_rounded,
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
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.25),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '${widget.totalItems}',
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
//       child: Text(
//         'ALL ${widget.itemType}',
//         textAlign: TextAlign.center,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }
// }

// // ✅ Professional Loading Indicator
// class ProfessionalWebSeriesLoadingIndicator extends StatefulWidget {
//   final String message;

//   const ProfessionalWebSeriesLoadingIndicator({
//     Key? key,
//     this.message = 'Loading Web Series...',
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesLoadingIndicatorState createState() =>
//       _ProfessionalWebSeriesLoadingIndicatorState();
// }

// class _ProfessionalWebSeriesLoadingIndicatorState extends State<ProfessionalWebSeriesLoadingIndicator>
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
//                     colors: [
//                       ProfessionalColors.accentPurple,
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPink,
//                       ProfessionalColors.accentPurple,
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
//                     ProfessionalColors.accentPurple,
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

// // ✅ Professional WebSeries Grid Page
// class ProfessionalWebSeriesGridPage extends StatefulWidget {
//   final List<WebSeriesModel> webSeriesList;
//   final String title;

//   const ProfessionalWebSeriesGridPage({
//     Key? key,
//     required this.webSeriesList,
//     this.title = 'All Web Series',
//   }) : super(key: key);

//   @override
//   _ProfessionalWebSeriesGridPageState createState() => _ProfessionalWebSeriesGridPageState();
// }

// class _ProfessionalWebSeriesGridPageState extends State<ProfessionalWebSeriesGridPage>
//     with TickerProviderStateMixin {
//   int gridFocusedIndex = 0;
//   final int columnsCount = 6;
//   Map<int, FocusNode> gridFocusNodes = {};
//   late ScrollController _scrollController;

//   // Animation Controllers
//   late AnimationController _fadeController;
//   late AnimationController _staggerController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _createGridFocusNodes();
//     _initializeAnimations();
//     _startStaggeredAnimation();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusFirstGridItem();
//     });
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

//   void _createGridFocusNodes() {
//     for (int i = 0; i < widget.webSeriesList.length; i++) {
//       gridFocusNodes[i] = FocusNode();
//       gridFocusNodes[i]!.addListener(() {
//         if (gridFocusNodes[i]!.hasFocus) {
//           _ensureItemVisible(i);
//         }
//       });
//     }
//   }

//   void _focusFirstGridItem() {
//     if (gridFocusNodes.containsKey(0)) {
//       setState(() {
//         gridFocusedIndex = 0;
//       });
//       gridFocusNodes[0]!.requestFocus();
//     }
//   }

//   void _ensureItemVisible(int index) {
//     if (_scrollController.hasClients) {
//       final int row = index ~/ columnsCount;
//       final double itemHeight = 200.0;
//       final double targetOffset = row * itemHeight;

//       _scrollController.animateTo(
//         targetOffset,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void _navigateGrid(LogicalKeyboardKey key) {
//     int newIndex = gridFocusedIndex;
//     final int totalItems = widget.webSeriesList.length;
//     final int currentRow = gridFocusedIndex ~/ columnsCount;
//     final int currentCol = gridFocusedIndex % columnsCount;

//     switch (key) {
//       case LogicalKeyboardKey.arrowRight:
//         if (gridFocusedIndex < totalItems - 1) {
//           newIndex = gridFocusedIndex + 1;
//         }
//         break;

//       case LogicalKeyboardKey.arrowLeft:
//         if (gridFocusedIndex > 0) {
//           newIndex = gridFocusedIndex - 1;
//         }
//         break;

//       case LogicalKeyboardKey.arrowDown:
//         final int nextRowIndex = (currentRow + 1) * columnsCount + currentCol;
//         if (nextRowIndex < totalItems) {
//           newIndex = nextRowIndex;
//         }
//         break;

//       case LogicalKeyboardKey.arrowUp:
//         if (currentRow > 0) {
//           final int prevRowIndex = (currentRow - 1) * columnsCount + currentCol;
//           newIndex = prevRowIndex;
//         }
//         break;
//     }

//     if (newIndex != gridFocusedIndex && newIndex >= 0 && newIndex < totalItems) {
//       setState(() {
//         gridFocusedIndex = newIndex;
//       });
//       gridFocusNodes[newIndex]!.requestFocus();
//     }
//   }

//   void _navigateToWebSeriesDetails(WebSeriesModel webSeries, int index) {
//     print('🎬 Grid: Navigating to WebSeries Details: ${webSeries.name}');

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => WebSeriesDetailsPage(
//           id: webSeries.id,
//           banner: webSeries.banner ?? webSeries.poster ?? '',
//           poster: webSeries.poster ?? webSeries.banner ?? '',
//           name: webSeries.name,
//         ),
//       ),
//     ).then((_) {
//       print('🔙 Returned from WebSeries Details to Grid');
//       Future.delayed(Duration(milliseconds: 300), () {
//         if (mounted && gridFocusNodes.containsKey(index)) {
//           setState(() {
//             gridFocusedIndex = index;
//           });
//           gridFocusNodes[index]!.requestFocus();
//           print('✅ Restored grid focus to index $index');
//         }
//       });
//     });
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
//                   child: _buildGridView(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfessionalAppBar() {
//     return Container(
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 10,
//         left: 40,
//         right: 40,
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
//                 const SizedBox(height: 10),

//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [
//                   ProfessionalColors.accentPurple.withOpacity(0.2),
//                   ProfessionalColors.accentBlue.withOpacity(0.2),
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
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ShaderMask(
//                   shaderCallback: (bounds) => const LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentPurple,
//                       ProfessionalColors.accentBlue,
//                     ],
//                   ).createShader(bounds),
//                   child: Text(
//                     widget.title,
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
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         ProfessionalColors.accentPurple.withOpacity(0.2),
//                         ProfessionalColors.accentBlue.withOpacity(0.1),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(
//                       color: ProfessionalColors.accentPurple.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Text(
//                     '${widget.webSeriesList.length} Web Series Available',
//                     style: const TextStyle(
//                       color: ProfessionalColors.accentPurple,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),

//               ],
//             ),
//           ),
//                 const SizedBox(height: 10),

//         ],
//       ),

//     );
//   }

//   Widget _buildGridView() {
//     if (widget.webSeriesList.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   colors: [
//                     ProfessionalColors.accentPurple.withOpacity(0.2),
//                     ProfessionalColors.accentPurple.withOpacity(0.1),
//                   ],
//                 ),
//               ),
//               child: const Icon(
//                 Icons.tv_outlined,
//                 size: 40,
//                 color: ProfessionalColors.accentPurple,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No ${widget.title} Found',
//               style: TextStyle(
//                 color: ProfessionalColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Check back later for new episodes',
//               style: TextStyle(
//                 color: ProfessionalColors.textSecondary,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Focus(
//       autofocus: true,
//       onKey: (node, event) {
//         if (event is RawKeyDownEvent) {
//           // if (event.logicalKey == LogicalKeyboardKey.escape ||
//           //     event.logicalKey == LogicalKeyboardKey.goBack) {
//           //   Navigator.pop(context);
//           //   return KeyEventResult.handled;
//           // } else
//            if ([
//             LogicalKeyboardKey.arrowUp,
//             LogicalKeyboardKey.arrowDown,
//             LogicalKeyboardKey.arrowLeft,
//             LogicalKeyboardKey.arrowRight,
//           ].contains(event.logicalKey)) {
//             _navigateGrid(event.logicalKey);
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//                      event.logicalKey == LogicalKeyboardKey.select) {
//             if (gridFocusedIndex < widget.webSeriesList.length) {
//               _navigateToWebSeriesDetails(
//                 widget.webSeriesList[gridFocusedIndex],
//                 gridFocusedIndex,
//               );
//             }
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: Padding(
//         padding: EdgeInsets.all(20),
//         child: GridView.builder(
//           controller: _scrollController,
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             // crossAxisCount: columnsCount,
//             crossAxisCount: columnsCount,
//             crossAxisSpacing: 15,
//             mainAxisSpacing: 15,
//             childAspectRatio: 1.5,
//           ),
//           itemCount: widget.webSeriesList.length,
//           itemBuilder: (context, index) {
//             return AnimatedBuilder(
//               animation: _staggerController,
//               builder: (context, child) {
//                 final delay = (index / widget.webSeriesList.length) * 0.5;
//                 final animationValue = Interval(
//                   delay,
//                   delay + 0.5,
//                   curve: Curves.easeOutCubic,
//                 ).transform(_staggerController.value);

//                 return Transform.translate(
//                   offset: Offset(0, 50 * (1 - animationValue)),
//                   child: Opacity(
//                     opacity: animationValue,
//                     child: ProfessionalGridWebSeriesCard(
//                       webSeries: widget.webSeriesList[index],
//                       focusNode: gridFocusNodes[index]!,
//                       onTap: () => _navigateToWebSeriesDetails(widget.webSeriesList[index], index),
//                       index: index,
//                       categoryTitle: widget.title,
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _staggerController.dispose();
//     _scrollController.dispose();
//     for (var node in gridFocusNodes.values) {
//       try {
//         node.dispose();
//       } catch (e) {}
//     }
//     super.dispose();
//   }
// }

// // ✅ Professional Grid WebSeries Card
// class ProfessionalGridWebSeriesCard extends StatefulWidget {
//   final WebSeriesModel webSeries;
//   final FocusNode focusNode;
//   final VoidCallback onTap;
//   final int index;
//   final String categoryTitle;

//   const ProfessionalGridWebSeriesCard({
//     Key? key,
//     required this.webSeries,
//     required this.focusNode,
//     required this.onTap,
//     required this.index,
//     required this.categoryTitle,
//   }) : super(key: key);

//   @override
//   _ProfessionalGridWebSeriesCardState createState() => _ProfessionalGridWebSeriesCardState();
// }

// class _ProfessionalGridWebSeriesCardState extends State<ProfessionalGridWebSeriesCard>
//     with TickerProviderStateMixin {
//   late AnimationController _hoverController;
//   late AnimationController _glowController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _glowAnimation;

//   Color _dominantColor = ProfessionalColors.accentPurple;
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
//                       _buildWebSeriesImage(),
//                       if (_isFocused) _buildFocusBorder(),
//                       _buildGradientOverlay(),
//                       _buildWebSeriesInfo(),
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

//   Widget _buildWebSeriesImage() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       child: widget.webSeries.banner != null && widget.webSeries.banner!.isNotEmpty
//           ? Image.network(
//               widget.webSeries.banner!,
//               fit: BoxFit.cover,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return _buildImagePlaceholder();
//               },
//               errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
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
//             Text(
//               'WEB SERIES',
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
//                 color: ProfessionalColors.accentPurple.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Text(
//                 'HD',
//                 style: TextStyle(
//                   color: ProfessionalColors.accentPurple,
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

//   Widget _buildWebSeriesInfo() {
//     final webSeriesName = widget.webSeries.name;

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
//               webSeriesName.toUpperCase(),
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
//             if (_isFocused && widget.webSeries.genres != null) ...[
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: ProfessionalColors.accentPurple.withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: ProfessionalColors.accentPurple.withOpacity(0.5),
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       widget.webSeries.genres!.toUpperCase(),
//                       style: const TextStyle(
//                         color: ProfessionalColors.accentPurple,
//                         fontSize: 8,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: _dominantColor.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: _dominantColor.withOpacity(0.4),
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       'SERIES',
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobi_tv_entertainment/home_screen_pages/religious_channel/religious_channel_details_page.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/webseries_details_page.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:ui';

// ✅ Professional Color Palette (same as Movies)
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

// ✅ Professional Animation Durations
class AnimationTiming {
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration focus = Duration(milliseconds: 300);
  static const Duration scroll = Duration(milliseconds: 800);
}

// ✅ Religious Channel Model
class ReligiousChannelModel {
  final int id;
  final String name;
  final String? logo;
  final String? description;
  final String language;
  final int status;
  final int relOrder;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  ReligiousChannelModel({
    required this.id,
    required this.name,
    this.logo,
    this.description,
    required this.language,
    required this.status,
    required this.relOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory ReligiousChannelModel.fromJson(Map<String, dynamic> json) {
    return ReligiousChannelModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'],
      description: json['description'],
      language: json['language'] ?? '',
      status: json['status'] ?? 0,
      relOrder: json['rel_order'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
    );
  }
}

// 🚀 Enhanced Religious Channels Service with Caching
class ReligiousChannelsService {
  // Cache keys
  static const String _cacheKeyChannels = 'cached_religious_channels';
  static const String _cacheKeyTimestamp =
      'cached_religious_channels_timestamp';
  static const String _cacheKeyAuthKey = 'auth_key';

  // Cache duration (in milliseconds) - 1 hour
  static const int _cacheDurationMs = 60 * 60 * 1000; // 1 hour

  /// Main method to get all religious channels with caching
  static Future<List<ReligiousChannelModel>> getAllReligiousChannels(
      {bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we should use cache
      if (!forceRefresh && await _shouldUseCache(prefs)) {
        print('📦 Loading Religious Channels from cache...');
        final cachedChannels = await _getCachedChannels(prefs);
        if (cachedChannels.isNotEmpty) {
          print(
              '✅ Successfully loaded ${cachedChannels.length} religious channels from cache');

          // Load fresh data in background (without waiting)
          _loadFreshDataInBackground();

          return cachedChannels;
        }
      }

      // Load fresh data if no cache or force refresh
      print('🌐 Loading fresh Religious Channels from API...');
      return await _fetchFreshChannels(prefs);
    } catch (e) {
      print('❌ Error in getAllReligiousChannels: $e');

      // Try to return cached data as fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedChannels = await _getCachedChannels(prefs);
        if (cachedChannels.isNotEmpty) {
          print('🔄 Returning cached data as fallback');
          return cachedChannels;
        }
      } catch (cacheError) {
        print('❌ Cache fallback also failed: $cacheError');
      }

      throw Exception('Failed to load religious channels: $e');
    }
  }

  /// Check if cached data is still valid
  static Future<bool> _shouldUseCache(SharedPreferences prefs) async {
    try {
      final timestampStr = prefs.getString(_cacheKeyTimestamp);
      if (timestampStr == null) return false;

      final cachedTimestamp = int.tryParse(timestampStr);
      if (cachedTimestamp == null) return false;

      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      final cacheAge = currentTimestamp - cachedTimestamp;

      final isValid = cacheAge < _cacheDurationMs;

      if (isValid) {
        final ageMinutes = (cacheAge / (1000 * 60)).round();
        print(
            '📦 Religious Channels Cache is valid (${ageMinutes} minutes old)');
      } else {
        final ageMinutes = (cacheAge / (1000 * 60)).round();
        print('⏰ Religious Channels Cache expired (${ageMinutes} minutes old)');
      }

      return isValid;
    } catch (e) {
      print('❌ Error checking Religious Channels cache validity: $e');
      return false;
    }
  }

  /// Get religious channels from cache
  static Future<List<ReligiousChannelModel>> _getCachedChannels(
      SharedPreferences prefs) async {
    try {
      final cachedData = prefs.getString(_cacheKeyChannels);
      if (cachedData == null || cachedData.isEmpty) {
        print('📦 No cached Religious Channels data found');
        return [];
      }

      final List<dynamic> jsonData = json.decode(cachedData);
      final channels = jsonData
          .map((json) =>
              ReligiousChannelModel.fromJson(json as Map<String, dynamic>))
          .toList();

      print(
          '📦 Successfully loaded ${channels.length} religious channels from cache');
      return channels;
    } catch (e) {
      print('❌ Error loading cached religious channels: $e');
      return [];
    }
  }

  /// Fetch fresh religious channels from API and cache them
  static Future<List<ReligiousChannelModel>> _fetchFreshChannels(
      SharedPreferences prefs) async {
    try {
      String authKey = prefs.getString(_cacheKeyAuthKey) ?? '';

      final response = await http.get(
        Uri.parse(
            'https://acomtv.coretechinfo.com/public/api/v2/getReligiousChannels'),
        headers: {
          'auth-key': authKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'domain': 'coretechinfo.com',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        final channels = jsonData
            .map((json) =>
                ReligiousChannelModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache the fresh data
        await _cacheChannels(prefs, jsonData);

        print(
            '✅ Successfully loaded ${channels.length} fresh religious channels from API');
        return channels;
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Error fetching fresh religious channels: $e');
      rethrow;
    }
  }

  /// Cache religious channels data
  static Future<void> _cacheChannels(
      SharedPreferences prefs, List<dynamic> channelsData) async {
    try {
      final jsonString = json.encode(channelsData);
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Save channels data and timestamp
      await Future.wait([
        prefs.setString(_cacheKeyChannels, jsonString),
        prefs.setString(_cacheKeyTimestamp, currentTimestamp),
      ]);

      print('💾 Successfully cached ${channelsData.length} religious channels');
    } catch (e) {
      print('❌ Error caching religious channels: $e');
    }
  }

  /// Load fresh data in background without blocking UI
  static void _loadFreshDataInBackground() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        print('🔄 Loading fresh religious channels data in background...');
        final prefs = await SharedPreferences.getInstance();
        await _fetchFreshChannels(prefs);
        print('✅ Religious Channels background refresh completed');
      } catch (e) {
        print('⚠️ Religious Channels background refresh failed: $e');
      }
    });
  }

  /// Clear all cached data
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_cacheKeyChannels),
        prefs.remove(_cacheKeyTimestamp),
      ]);
      print('🗑️ Religious Channels cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing Religious Channels cache: $e');
    }
  }

  /// Get cache info for debugging
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString(_cacheKeyTimestamp);
      final cachedData = prefs.getString(_cacheKeyChannels);

      if (timestampStr == null || cachedData == null) {
        return {
          'hasCachedData': false,
          'cacheAge': 0,
          'cachedChannelsCount': 0,
          'cacheSize': 0,
        };
      }

      final cachedTimestamp = int.tryParse(timestampStr) ?? 0;
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      final cacheAge = currentTimestamp - cachedTimestamp;
      final cacheAgeMinutes = (cacheAge / (1000 * 60)).round();

      final List<dynamic> jsonData = json.decode(cachedData);
      final cacheSizeKB = (cachedData.length / 1024).round();

      return {
        'hasCachedData': true,
        'cacheAge': cacheAgeMinutes,
        'cachedChannelsCount': jsonData.length,
        'cacheSize': cacheSizeKB,
        'isValid': cacheAge < _cacheDurationMs,
      };
    } catch (e) {
      print('❌ Error getting Religious Channels cache info: $e');
      return {
        'hasCachedData': false,
        'cacheAge': 0,
        'cachedChannelsCount': 0,
        'cacheSize': 0,
        'error': e.toString(),
      };
    }
  }

  /// Force refresh data (bypass cache)
  static Future<List<ReligiousChannelModel>> forceRefresh() async {
    print('🔄 Force refreshing Religious Channels data...');
    return await getAllReligiousChannels(forceRefresh: true);
  }
}

// 🚀 Enhanced ProfessionalReligiousChannelsHorizontalList with Caching
class ProfessionalReligiousChannelsHorizontalList extends StatefulWidget {
  @override
  _ProfessionalReligiousChannelsHorizontalListState createState() =>
      _ProfessionalReligiousChannelsHorizontalListState();
}

class _ProfessionalReligiousChannelsHorizontalListState
    extends State<ProfessionalReligiousChannelsHorizontalList>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  List<ReligiousChannelModel> channelsList = [];
  bool isLoading = true;
  int focusedIndex = -1;
  final int maxHorizontalItems = 7;
  Color _currentAccentColor = ProfessionalColors.accentOrange;

  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  Map<String, FocusNode> channelsFocusNodes = {};
  FocusNode? _viewAllFocusNode;
  FocusNode? _firstChannelFocusNode;
  bool _hasReceivedFocusFromWebSeries = false;

  late ScrollController _scrollController;
  final double _itemWidth = 156.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
    _initializeFocusNodes();

    // 🚀 Use enhanced caching service
    fetchChannelsWithCache();
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

  void _initializeFocusNodes() {
    _viewAllFocusNode = FocusNode();
    print('✅ Religious Channels focus nodes initialized');
  }

  void _scrollToPosition(int index) {
    if (index < channelsList.length && index < maxHorizontalItems) {
      String channelId = channelsList[index].id.toString();
      if (channelsFocusNodes.containsKey(channelId)) {
        final focusNode = channelsFocusNodes[channelId]!;

        Scrollable.ensureVisible(
          focusNode.context!,
          duration: AnimationTiming.scroll,
          curve: Curves.easeInOutCubic,
          alignment: 0.03,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        );

        print(
            '🎯 Scrollable.ensureVisible for index $index: ${channelsList[index].name}');
      }
    } else if (index == maxHorizontalItems && _viewAllFocusNode != null) {
      Scrollable.ensureVisible(
        _viewAllFocusNode!.context!,
        duration: AnimationTiming.scroll,
        curve: Curves.easeInOutCubic,
        alignment: 0.2,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );

      print('🎯 Scrollable.ensureVisible for ViewAll button');
    }
  }

  void _setupFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && channelsList.isNotEmpty) {
        try {
          final focusProvider =
              Provider.of<FocusProvider>(context, listen: false);

          final firstChannelId = channelsList[0].id.toString();

          if (!channelsFocusNodes.containsKey(firstChannelId)) {
            channelsFocusNodes[firstChannelId] = FocusNode();
            print(
                '✅ Created focus node for first religious channel: $firstChannelId');
          }

          _firstChannelFocusNode = channelsFocusNodes[firstChannelId];

          _firstChannelFocusNode!.addListener(() {
            if (_firstChannelFocusNode!.hasFocus &&
                !_hasReceivedFocusFromWebSeries) {
              _hasReceivedFocusFromWebSeries = true;
              setState(() {
                focusedIndex = 0;
              });
              _scrollToPosition(0);
              print(
                  '✅ Religious Channels received focus from web series and scrolled');
            }
          });

          // Register with focus provider using appropriate method
          focusProvider
              .setFirstReligiousChannelFocusNode(_firstChannelFocusNode!);
          print(
              '✅ Religious Channels first focus node registered: ${channelsList[0].name}');
        } catch (e) {
          print('❌ Religious Channels focus provider setup failed: $e');
        }
      }
    });
  }

  // 🚀 Enhanced fetch method with caching
  Future<void> fetchChannelsWithCache() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Use cached data first, then fresh data
      final fetchedChannels =
          await ReligiousChannelsService.getAllReligiousChannels();

      if (fetchedChannels.isNotEmpty) {
        if (mounted) {
          setState(() {
            channelsList = fetchedChannels;
            isLoading = false;
          });

          _createFocusNodesForItems();
          _setupFocusProvider();

          // Start animations after data loads
          _headerAnimationController.forward();
          _listAnimationController.forward();

          // Debug cache info
          _debugCacheInfo();
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching Religious Channels with cache: $e');
    }
  }

  // 🆕 Debug method to show cache information
  Future<void> _debugCacheInfo() async {
    try {
      final cacheInfo = await ReligiousChannelsService.getCacheInfo();
      print('📊 Religious Channels Cache Info: $cacheInfo');
    } catch (e) {
      print('❌ Error getting Religious Channels cache info: $e');
    }
  }

  // 🆕 Force refresh channels
  Future<void> _forceRefreshChannels() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Force refresh bypasses cache
      final fetchedChannels = await ReligiousChannelsService.forceRefresh();

      if (fetchedChannels.isNotEmpty) {
        if (mounted) {
          setState(() {
            channelsList = fetchedChannels;
            isLoading = false;
          });

          _createFocusNodesForItems();
          _setupFocusProvider();

          _headerAnimationController.forward();
          _listAnimationController.forward();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Religious Channels refreshed successfully'),
              backgroundColor: ProfessionalColors.accentOrange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('❌ Error force refreshing religious channels: $e');
    }
  }

  void _createFocusNodesForItems() {
    for (var node in channelsFocusNodes.values) {
      try {
        node.removeListener(() {});
        node.dispose();
      } catch (e) {}
    }
    channelsFocusNodes.clear();

    for (int i = 0; i < channelsList.length && i < maxHorizontalItems; i++) {
      String channelId = channelsList[i].id.toString();
      if (!channelsFocusNodes.containsKey(channelId)) {
        channelsFocusNodes[channelId] = FocusNode();

        channelsFocusNodes[channelId]!.addListener(() {
          if (mounted && channelsFocusNodes[channelId]!.hasFocus) {
            setState(() {
              focusedIndex = i;
              _hasReceivedFocusFromWebSeries = true;
            });
            _scrollToPosition(i);
            print(
                '✅ Religious Channel $i focused and scrolled: ${channelsList[i].name}');
          }
        });
      }
    }
    print(
        '✅ Created ${channelsFocusNodes.length} religious channels focus nodes with auto-scroll');
  }

  // void _navigateToChannelDetails(ReligiousChannelModel channel) {
  //   print('📺 Navigating to Religious Channel Details: ${channel.name}');

  //   // For now, show a dialog with channel info
  //   // You can replace this with your channel details page
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: ProfessionalColors.cardDark,
  //       title: Text(
  //         channel.name,
  //         style: TextStyle(color: ProfessionalColors.textPrimary),
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Language: ${channel.language}',
  //             style: TextStyle(color: ProfessionalColors.textSecondary),
  //           ),
  //           if (channel.description != null) ...[
  //             SizedBox(height: 8),
  //             Text(
  //               'Description: ${channel.description}',
  //               style: TextStyle(color: ProfessionalColors.textSecondary),
  //             ),
  //           ],
  //           SizedBox(height: 8),
  //           Text(
  //             'Status: ${channel.status == 1 ? "Active" : "Inactive"}',
  //             style: TextStyle(
  //               color: channel.status == 1
  //                   ? ProfessionalColors.accentGreen
  //                   : ProfessionalColors.accentRed,
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'Close',
  //             style: TextStyle(color: ProfessionalColors.accentOrange),
  //           ),
  //         ),
  //       ],
  //     ),
  //   ).then((_) {
  //     print('🔙 Returned from Channel Details');
  //     Future.delayed(Duration(milliseconds: 300), () {
  //       if (mounted) {
  //         int currentIndex = channelsList.indexWhere((ch) => ch.id == channel.id);
  //         if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
  //           String channelId = channel.id.toString();
  //           if (channelsFocusNodes.containsKey(channelId)) {
  //             setState(() {
  //               focusedIndex = currentIndex;
  //               _hasReceivedFocusFromWebSeries = true;
  //             });
  //             channelsFocusNodes[channelId]!.requestFocus();
  //             _scrollToPosition(currentIndex);
  //             print('✅ Restored focus to ${channel.name}');
  //           }
  //         }
  //       }
  //     });
  //   });
  // }

// ✅ Updated _navigateToChannelDetails method in ProfessionalReligiousChannelsHorizontalList

  void _navigateToChannelDetails(ReligiousChannelModel channel) {
    print('📺 Navigating to Religious Channel Details: ${channel.name}');

    // Navigate to ReligiousChannelDetailsPage instead of showing dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReligiousChannelDetailsPage(
          id: channel.id,
          banner: channel.logo ?? '', // Use logo as banner if available
          poster: channel.logo ?? '', // Use logo as poster if available
          name: channel.name,
        ),
      ),
    );
    //.then((_) {
    //   print('🔙 Returned from Religious Channel Details');
    //   Future.delayed(Duration(milliseconds: 300), () {
    //     if (mounted) {
    //       int currentIndex = channelsList.indexWhere((ch) => ch.id == channel.id);
    //       if (currentIndex != -1 && currentIndex < maxHorizontalItems) {
    //         String channelId = channel.id.toString();
    //         if (channelsFocusNodes.containsKey(channelId)) {
    //           setState(() {
    //             focusedIndex = currentIndex;
    //             _hasReceivedFocusFromWebSeries = true;
    //           });
    //           channelsFocusNodes[channelId]!.requestFocus();
    //           _scrollToPosition(currentIndex);
    //           print('✅ Restored focus to ${channel.name}');
    //         }
    //       }
    //     }
    //   });
    // });
  }

  void _navigateToGridPage() {
    print('📺 Navigating to Religious Channels Grid Page...');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalReligiousChannelsGridPage(
          channelsList: channelsList,
          title: 'Religious Channels',
        ),
      ),
    ).then((_) {
      print('🔙 Returned from grid page');
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted && _viewAllFocusNode != null) {
          setState(() {
            focusedIndex = maxHorizontalItems;
            _hasReceivedFocusFromWebSeries = true;
          });
          _viewAllFocusNode!.requestFocus();
          _scrollToPosition(maxHorizontalItems);
          print('✅ Focused back to ViewAll button and scrolled');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ✅ ADD: Consumer to listen to color changes
    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        final bgColor = colorProvider.isItemFocused
            ? colorProvider.dominantColor.withOpacity(0.1)
            : ProfessionalColors.primaryDark;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            // ✅ ENHANCED: Dynamic background gradient based on focused item
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
                Expanded(child: _buildBody(screenWidth, screenHeight)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🚀 Enhanced Title with Cache Status
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
                  ProfessionalColors.accentOrange,
                  ProfessionalColors.accentRed,
                ],
              ).createShader(bounds),
              child: Text(
                'RELIGIOUS CHANNELS',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            Row(
              children: [
                // Channels Count
                if (channelsList.length > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ProfessionalColors.accentOrange.withOpacity(0.2),
                          ProfessionalColors.accentRed.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ProfessionalColors.accentOrange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${channelsList.length} Channels Available',
                      style: const TextStyle(
                        color: ProfessionalColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(double screenWidth, double screenHeight) {
    if (isLoading) {
      return ProfessionalReligiousChannelsLoadingIndicator(
          message: 'Loading Religious Channels...');
    } else if (channelsList.isEmpty) {
      return _buildEmptyWidget();
    } else {
      return _buildChannelsList(screenWidth, screenHeight);
    }
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalColors.accentOrange.withOpacity(0.2),
                  ProfessionalColors.accentOrange.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.tv_outlined,
              size: 40,
              color: ProfessionalColors.accentOrange,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Religious Channels Found',
            style: TextStyle(
              color: ProfessionalColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new channels',
            style: TextStyle(
              color: ProfessionalColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelsList(double screenWidth, double screenHeight) {
    bool showViewAll = channelsList.length > 7;

    return FadeTransition(
      opacity: _listFadeAnimation,
      child: Container(
        height: screenHeight * 0.38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
          cacheExtent: 1200,
          itemCount: showViewAll ? 8 : channelsList.length,
          itemBuilder: (context, index) {
            if (showViewAll && index == 7) {
              return Focus(
                focusNode: _viewAllFocusNode,
                onFocusChange: (hasFocus) {
                  if (hasFocus && mounted) {
                    Color viewAllColor = ProfessionalColors.gradientColors[
                        math.Random()
                            .nextInt(ProfessionalColors.gradientColors.length)];

                    setState(() {
                      _currentAccentColor = viewAllColor;
                    });
                  }
                },
                onKey: (FocusNode node, RawKeyEvent event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                      return KeyEventResult.handled;
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowLeft) {
                      if (channelsList.isNotEmpty && channelsList.length > 6) {
                        String channelId = channelsList[6].id.toString();
                        FocusScope.of(context)
                            .requestFocus(channelsFocusNodes[channelId]);
                        return KeyEventResult.handled;
                      }
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      setState(() {
                        focusedIndex = -1;
                        _hasReceivedFocusFromWebSeries = false;
                      });
                      FocusScope.of(context).unfocus();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          try {
                            // Provider.of<FocusProvider>(context, listen: false)
                            //     .requestFirstSportsCategoryFocus();
                            Provider.of<FocusProvider>(context, listen: false)
                                .requestFirstSportsCategoryFocus();
                            print(
                                '✅ Navigating back to web series from religious channels');
                          } catch (e) {
                            print('❌ Failed to navigate to web series: $e');
                          }
                        }
                      });
                      return KeyEventResult.handled;
                    } else if (event.logicalKey ==
                        LogicalKeyboardKey.arrowDown) {
                      setState(() {
                        focusedIndex = -1;
                        _hasReceivedFocusFromWebSeries = false;
                      });
                      FocusScope.of(context).unfocus();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          try {
                            Provider.of<FocusProvider>(context, listen: false)
                                .requestFirstTVShowsPakFocus();
                            print(
                                '✅ Navigating to TV Shows from religious channels ViewAll');
                          } catch (e) {
                            print('❌ Failed to navigate to TV Shows: $e');
                          }
                        }
                      });
                      return KeyEventResult.handled;
                    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                        event.logicalKey == LogicalKeyboardKey.select) {
                      print('📺 ViewAll button pressed - Opening Grid Page...');
                      _navigateToGridPage();
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: GestureDetector(
                  onTap: _navigateToGridPage,
                  child: ProfessionalReligiousChannelsViewAllButton(
                    focusNode: _viewAllFocusNode!,
                    onTap: _navigateToGridPage,
                    totalItems: channelsList.length,
                    itemType: 'CHANNELS',
                  ),
                ),
              );
            }

            var channel = channelsList[index];
            return _buildChannelItem(channel, index, screenWidth, screenHeight);
          },
        ),
      ),
    );
  }

  // ✅ ENHANCED: Channel item with color provider integration
  Widget _buildChannelItem(ReligiousChannelModel channel, int index,
      double screenWidth, double screenHeight) {
    String channelId = channel.id.toString();

    channelsFocusNodes.putIfAbsent(
      channelId,
      () => FocusNode()
        ..addListener(() {
          if (mounted && channelsFocusNodes[channelId]!.hasFocus) {
            _scrollToPosition(index);
          }
        }),
    );

    return Focus(
      focusNode: channelsFocusNodes[channelId],
      onFocusChange: (hasFocus) async {
        if (hasFocus && mounted) {
          try {
            Color dominantColor = ProfessionalColors.gradientColors[
                math.Random()
                    .nextInt(ProfessionalColors.gradientColors.length)];

            setState(() {
              _currentAccentColor = dominantColor;
              focusedIndex = index;
              _hasReceivedFocusFromWebSeries = true;
            });

            // ✅ ADD: Update color provider
            context.read<ColorProvider>().updateColor(dominantColor, true);
          } catch (e) {
            print('Focus change handling failed: $e');
          }
        } else if (mounted) {
          // ✅ ADD: Reset color when focus lost
          context.read<ColorProvider>().resetColor();
        }
      },
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (index < channelsList.length - 1 && index != 6) {
              String nextChannelId = channelsList[index + 1].id.toString();
              FocusScope.of(context)
                  .requestFocus(channelsFocusNodes[nextChannelId]);
              return KeyEventResult.handled;
            } else if (index == 6 && channelsList.length > 7) {
              FocusScope.of(context).requestFocus(_viewAllFocusNode);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (index > 0) {
              String prevChannelId = channelsList[index - 1].id.toString();
              FocusScope.of(context)
                  .requestFocus(channelsFocusNodes[prevChannelId]);
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            setState(() {
              focusedIndex = -1;
              _hasReceivedFocusFromWebSeries = false;
            });
            // ✅ ADD: Reset color when navigating away
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                try {
                  Provider.of<FocusProvider>(context, listen: false)
                      .requestFirstSportsCategoryFocus();
                  print(
                      '✅ Navigating back to web series from religious channels');
                } catch (e) {
                  print('❌ Failed to navigate to web series: $e');
                }
              }
            });
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            setState(() {
              focusedIndex = -1;
              _hasReceivedFocusFromWebSeries = false;
            });
            // ✅ ADD: Reset color when navigating away
            context.read<ColorProvider>().resetColor();
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                try {
                  Provider.of<FocusProvider>(context, listen: false)
                      .requestFirstTVShowsPakFocus();
                  print('✅ Navigating to TV Shows from religious channels');
                } catch (e) {
                  print('❌ Failed to navigate to TV Shows: $e');
                }
              }
            });
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.select) {
            print('📺 Enter pressed on ${channel.name} - Opening Details...');
            _navigateToChannelDetails(channel);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _navigateToChannelDetails(channel),
        child: ProfessionalReligiousChannelCard(
          channel: channel,
          focusNode: channelsFocusNodes[channelId]!,
          onTap: () => _navigateToChannelDetails(channel),
          onColorChange: (color) {
            setState(() {
              _currentAccentColor = color;
            });
            // ✅ ADD: Update color provider when card changes color
            context.read<ColorProvider>().updateColor(color, true);
          },
          index: index,
          categoryTitle: 'RELIGIOUS CHANNELS',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();

    for (var entry in channelsFocusNodes.entries) {
      try {
        entry.value.removeListener(() {});
        entry.value.dispose();
      } catch (e) {}
    }
    channelsFocusNodes.clear();

    try {
      _viewAllFocusNode?.removeListener(() {});
      _viewAllFocusNode?.dispose();
    } catch (e) {}

    try {
      _scrollController.dispose();
    } catch (e) {}

    super.dispose();
  }
}

// ✅ Professional Religious Channel Card
class ProfessionalReligiousChannelCard extends StatefulWidget {
  final ReligiousChannelModel channel;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final Function(Color) onColorChange;
  final int index;
  final String categoryTitle;

  const ProfessionalReligiousChannelCard({
    Key? key,
    required this.channel,
    required this.focusNode,
    required this.onTap,
    required this.onColorChange,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalReligiousChannelCardState createState() =>
      _ProfessionalReligiousChannelCardState();
}

class _ProfessionalReligiousChannelCardState
    extends State<ProfessionalReligiousChannelCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  Color _dominantColor = ProfessionalColors.accentOrange;
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
    _dominantColor = colors[math.Random().nextInt(colors.length)];
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
            _buildChannelImage(screenWidth, posterHeight),
            if (_isFocused) _buildFocusBorder(),
            if (_isFocused) _buildShimmerEffect(),
            _buildLanguageBadge(),
            if (_isFocused) _buildHoverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelImage(double screenWidth, double posterHeight) {
    return Container(
      width: double.infinity,
      height: posterHeight,
      child: widget.channel.logo != null && widget.channel.logo!.isNotEmpty
          ? Image.network(
              widget.channel.logo!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder(posterHeight);
              },
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(posterHeight),
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
            Icons.radio_rounded,
            size: height * 0.25,
            color: ProfessionalColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            'RELIGIOUS',
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
              color: ProfessionalColors.accentOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: ProfessionalColors.accentOrange,
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
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageBadge() {
    String language = widget.channel.language.toUpperCase();
    Color badgeColor = ProfessionalColors.accentOrange;

    // Different colors for different languages
    if (language.toLowerCase().contains('hindi')) {
      badgeColor = ProfessionalColors.accentOrange;
    } else if (language.toLowerCase().contains('punjabi')) {
      badgeColor = ProfessionalColors.accentGreen;
    } else if (language.toLowerCase().contains('english')) {
      badgeColor = ProfessionalColors.accentBlue;
    } else if (language.toLowerCase().contains('urdu')) {
      badgeColor = ProfessionalColors.accentPurple;
    }

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
          language,
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
    final channelName = widget.channel.name.toUpperCase();

    return Container(
      width: bannerwdt,
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
          channelName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ✅ Professional View All Button for Religious Channels
class ProfessionalReligiousChannelsViewAllButton extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int totalItems;
  final String itemType;

  const ProfessionalReligiousChannelsViewAllButton({
    Key? key,
    required this.focusNode,
    required this.onTap,
    required this.totalItems,
    this.itemType = 'CHANNELS',
  }) : super(key: key);

  @override
  _ProfessionalReligiousChannelsViewAllButtonState createState() =>
      _ProfessionalReligiousChannelsViewAllButtonState();
}

class _ProfessionalReligiousChannelsViewAllButtonState
    extends State<ProfessionalReligiousChannelsViewAllButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  bool _isFocused = false;
  Color _currentColor = ProfessionalColors.accentOrange;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotateController);

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
      if (_isFocused) {
        _currentColor = ProfessionalColors.gradientColors[
            math.Random().nextInt(ProfessionalColors.gradientColors.length)];
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: bannerwdt,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _isFocused ? _pulseAnimation : _rotateAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isFocused ? _pulseAnimation.value : 1.0,
                child: Transform.rotate(
                  angle: _isFocused ? 0 : _rotateAnimation.value * 2 * math.pi,
                  child: Container(
                    height:
                        _isFocused ? focussedBannerhgt : bannerhgt ,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isFocused
                            ? [
                                _currentColor,
                                _currentColor.withOpacity(0.7),
                              ]
                            : [
                                ProfessionalColors.cardDark,
                                ProfessionalColors.surfaceDark,
                              ],
                      ),
                      boxShadow: [
                        if (_isFocused) ...[
                          BoxShadow(
                            color: _currentColor.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 3,
                            offset: const Offset(0, 8),
                          ),
                        ] else ...[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ],
                    ),
                    child: _buildViewAllContent(),
                  ),
                ),
              );
            },
          ),
          _buildViewAllTitle(),
        ],
      ),
    );
  }

  Widget _buildViewAllContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: _isFocused
            ? Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.radio_rounded,
                  size: _isFocused ? 45 : 35,
                  color: Colors.white,
                ),
                Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _isFocused ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.totalItems}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewAllTitle() {
    return AnimatedDefaultTextStyle(
      duration: AnimationTiming.medium,
      style: TextStyle(
        fontSize: _isFocused ? 13 : 11,
        fontWeight: FontWeight.w600,
        color: _isFocused ? _currentColor : ProfessionalColors.textPrimary,
        letterSpacing: 0.5,
        shadows: _isFocused
            ? [
                Shadow(
                  color: _currentColor.withOpacity(0.6),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Text(
        'ALL ${widget.itemType}',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ✅ Professional Loading Indicator for Religious Channels
class ProfessionalReligiousChannelsLoadingIndicator extends StatefulWidget {
  final String message;

  const ProfessionalReligiousChannelsLoadingIndicator({
    Key? key,
    this.message = 'Loading Religious Channels...',
  }) : super(key: key);

  @override
  _ProfessionalReligiousChannelsLoadingIndicatorState createState() =>
      _ProfessionalReligiousChannelsLoadingIndicatorState();
}

class _ProfessionalReligiousChannelsLoadingIndicatorState
    extends State<ProfessionalReligiousChannelsLoadingIndicator>
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
                    colors: [
                      ProfessionalColors.accentOrange,
                      ProfessionalColors.accentRed,
                      ProfessionalColors.accentPink,
                      ProfessionalColors.accentOrange,
                    ],
                    stops: [0.0, 0.3, 0.7, 1.0],
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
                    Icons.radio_rounded,
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
                    ProfessionalColors.accentOrange,
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

// ✅ Professional Religious Channels Grid Page
class ProfessionalReligiousChannelsGridPage extends StatefulWidget {
  final List<ReligiousChannelModel> channelsList;
  final String title;

  const ProfessionalReligiousChannelsGridPage({
    Key? key,
    required this.channelsList,
    this.title = 'All Religious Channels',
  }) : super(key: key);

  @override
  _ProfessionalReligiousChannelsGridPageState createState() =>
      _ProfessionalReligiousChannelsGridPageState();
}

class _ProfessionalReligiousChannelsGridPageState
    extends State<ProfessionalReligiousChannelsGridPage>
    with TickerProviderStateMixin {
  int gridFocusedIndex = 0;
  final int columnsCount = 6;
  Map<int, FocusNode> gridFocusNodes = {};
  late ScrollController _scrollController;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _createGridFocusNodes();
    _initializeAnimations();
    _startStaggeredAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusFirstGridItem();
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startStaggeredAnimation() {
    _fadeController.forward();
    _staggerController.forward();
  }

  void _createGridFocusNodes() {
    for (int i = 0; i < widget.channelsList.length; i++) {
      gridFocusNodes[i] = FocusNode();
      gridFocusNodes[i]!.addListener(() {
        if (gridFocusNodes[i]!.hasFocus) {
          _ensureItemVisible(i);
        }
      });
    }
  }

  void _focusFirstGridItem() {
    if (gridFocusNodes.containsKey(0)) {
      setState(() {
        gridFocusedIndex = 0;
      });
      gridFocusNodes[0]!.requestFocus();
    }
  }

  void _ensureItemVisible(int index) {
    if (_scrollController.hasClients) {
      final int row = index ~/ columnsCount;
      final double itemHeight = 200.0;
      final double targetOffset = row * itemHeight;

      _scrollController.animateTo(
        targetOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateGrid(LogicalKeyboardKey key) {
    int newIndex = gridFocusedIndex;
    final int totalItems = widget.channelsList.length;
    final int currentRow = gridFocusedIndex ~/ columnsCount;
    final int currentCol = gridFocusedIndex % columnsCount;

    switch (key) {
      case LogicalKeyboardKey.arrowRight:
        if (gridFocusedIndex < totalItems - 1) {
          newIndex = gridFocusedIndex + 1;
        }
        break;

      case LogicalKeyboardKey.arrowLeft:
        if (gridFocusedIndex > 0) {
          newIndex = gridFocusedIndex - 1;
        }
        break;

      case LogicalKeyboardKey.arrowDown:
        final int nextRowIndex = (currentRow + 1) * columnsCount + currentCol;
        if (nextRowIndex < totalItems) {
          newIndex = nextRowIndex;
        }
        break;

      case LogicalKeyboardKey.arrowUp:
        if (currentRow > 0) {
          final int prevRowIndex = (currentRow - 1) * columnsCount + currentCol;
          newIndex = prevRowIndex;
        }
        break;
    }

    if (newIndex != gridFocusedIndex &&
        newIndex >= 0 &&
        newIndex < totalItems) {
      setState(() {
        gridFocusedIndex = newIndex;
      });
      gridFocusNodes[newIndex]!.requestFocus();
    }
  }

  void _navigateToChannelDetails(ReligiousChannelModel channel, int index) {
    print('📺 Grid: Navigating to Religious Channel Details: ${channel.name}');

    // Navigate to ReligiousChannelDetailsPage instead of showing dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReligiousChannelDetailsPage(
          id: channel.id,
          banner: channel.logo ?? '', // Use logo as banner if available
          poster: channel.logo ?? '', // Use logo as poster if available
          name: channel.name,
        ),
      ),
    );
    // .then((_) {
    //     print('🔙 Returned from Channel Details to Grid');
    //     Future.delayed(Duration(milliseconds: 300), () {
    //       if (mounted && gridFocusNodes.containsKey(index)) {
    //         setState(() {
    //           gridFocusedIndex = index;
    //         });
    //         gridFocusNodes[index]!.requestFocus();
    //         print('✅ Restored grid focus to index $index');
    //       }
    //     });
    //   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ProfessionalColors.primaryDark,
                  ProfessionalColors.surfaceDark.withOpacity(0.8),
                  ProfessionalColors.primaryDark,
                ],
              ),
            ),
          ),

          // Main Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildProfessionalAppBar(),
                Expanded(
                  child: _buildGridView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 40,
        right: 40,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ProfessionalColors.surfaceDark.withOpacity(0.9),
            ProfessionalColors.surfaceDark.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ProfessionalColors.accentOrange.withOpacity(0.2),
                  ProfessionalColors.accentRed.withOpacity(0.2),
                ],
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      ProfessionalColors.accentOrange,
                      ProfessionalColors.accentRed,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ProfessionalColors.accentOrange.withOpacity(0.2),
                        ProfessionalColors.accentRed.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: ProfessionalColors.accentOrange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${widget.channelsList.length} Channels Available',
                    style: const TextStyle(
                      color: ProfessionalColors.accentOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    if (widget.channelsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ProfessionalColors.accentOrange.withOpacity(0.2),
                    ProfessionalColors.accentOrange.withOpacity(0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.radio_rounded,
                size: 40,
                color: ProfessionalColors.accentOrange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${widget.title} Found',
              style: TextStyle(
                color: ProfessionalColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for new channels',
              style: TextStyle(
                color: ProfessionalColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Focus(
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if ([
            LogicalKeyboardKey.arrowUp,
            LogicalKeyboardKey.arrowDown,
            LogicalKeyboardKey.arrowLeft,
            LogicalKeyboardKey.arrowRight,
          ].contains(event.logicalKey)) {
            _navigateGrid(event.logicalKey);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.select) {
            if (gridFocusedIndex < widget.channelsList.length) {
              _navigateToChannelDetails(
                widget.channelsList[gridFocusedIndex],
                gridFocusedIndex,
              );
            }
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Padding(
        padding: EdgeInsets.all(20),
        child: GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnsCount,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.5,
          ),
          itemCount: widget.channelsList.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _staggerController,
              builder: (context, child) {
                final delay = (index / widget.channelsList.length) * 0.5;
                final animationValue = Interval(
                  delay,
                  delay + 0.5,
                  curve: Curves.easeOutCubic,
                ).transform(_staggerController.value);

                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: ProfessionalGridReligiousChannelCard(
                      channel: widget.channelsList[index],
                      focusNode: gridFocusNodes[index]!,
                      onTap: () => _navigateToChannelDetails(
                          widget.channelsList[index], index),
                      index: index,
                      categoryTitle: widget.title,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    _scrollController.dispose();
    for (var node in gridFocusNodes.values) {
      try {
        node.dispose();
      } catch (e) {}
    }
    super.dispose();
  }
}

// ✅ Professional Grid Religious Channel Card
class ProfessionalGridReligiousChannelCard extends StatefulWidget {
  final ReligiousChannelModel channel;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final int index;
  final String categoryTitle;

  const ProfessionalGridReligiousChannelCard({
    Key? key,
    required this.channel,
    required this.focusNode,
    required this.onTap,
    required this.index,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  _ProfessionalGridReligiousChannelCardState createState() =>
      _ProfessionalGridReligiousChannelCardState();
}

class _ProfessionalGridReligiousChannelCardState
    extends State<ProfessionalGridReligiousChannelCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  Color _dominantColor = ProfessionalColors.accentOrange;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: AnimationTiming.slow,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: AnimationTiming.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });

    if (_isFocused) {
      _hoverController.forward();
      _glowController.forward();
      _generateDominantColor();
      HapticFeedback.lightImpact();
    } else {
      _hoverController.reverse();
      _glowController.reverse();
    }
  }

  void _generateDominantColor() {
    final colors = ProfessionalColors.gradientColors;
    _dominantColor = colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _glowController.dispose();
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    if (_isFocused) ...[
                      BoxShadow(
                        color: _dominantColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: _dominantColor.withOpacity(0.2),
                        blurRadius: 35,
                        spreadRadius: 4,
                        offset: const Offset(0, 12),
                      ),
                    ] else ...[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      _buildChannelImage(),
                      if (_isFocused) _buildFocusBorder(),
                      _buildGradientOverlay(),
                      _buildChannelInfo(),
                      if (_isFocused) _buildPlayButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChannelImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: widget.channel.logo != null && widget.channel.logo!.isNotEmpty
          ? Image.network(
              widget.channel.logo!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder();
              },
              errorBuilder: (context, error, stackTrace) =>
                  _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.radio_rounded,
              size: 40,
              color: ProfessionalColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              'RELIGIOUS',
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
                color: ProfessionalColors.accentOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: ProfessionalColors.accentOrange,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusBorder() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 3,
            color: _dominantColor,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelInfo() {
    final channelName = widget.channel.name;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              channelName.toUpperCase(),
              style: TextStyle(
                color: _isFocused ? _dominantColor : Colors.white,
                fontSize: _isFocused ? 13 : 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (_isFocused) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ProfessionalColors.accentOrange.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ProfessionalColors.accentOrange.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.channel.language.toUpperCase(),
                      style: const TextStyle(
                        color: ProfessionalColors.accentOrange,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _dominantColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _dominantColor.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.channel.status == 1 ? 'LIVE' : 'OFFLINE',
                      style: TextStyle(
                        color: _dominantColor,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _dominantColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: _dominantColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
