// // import 'dart:math';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// // import 'package:provider/provider.dart';
// // import '../main.dart';
// // import '../widgets/utils/random_light_color_widget.dart';

// // class TopNavigationBar extends StatefulWidget {
// //   final int selectedPage;
// //   final ValueChanged<int> onPageSelected;
// //   final bool tvenableAll;

// //   const TopNavigationBar({
// //     required this.selectedPage,
// //     required this.onPageSelected,
// //     required this.tvenableAll,
// //   });

// //   @override
// //   _TopNavigationBarState createState() => _TopNavigationBarState();
// // }

// // class _TopNavigationBarState extends State<TopNavigationBar> {
// //   late List<FocusNode> _focusNodes;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _focusNodes = List.generate(5, (index) => FocusNode());

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _focusNodes[0].requestFocus();
// //       context.read<FocusProvider>().setTopNavigationFocusNode(_focusNodes[0]);
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     for (var node in _focusNodes) {
// //       node.dispose();
// //     }
// //     super.dispose();
// //   }

// //   // Color generator function
// //   Color _generateRandomColor() {
// //     final random = Random();
// //     return Color.fromRGBO(
// //       random.nextInt(256),
// //       random.nextInt(256),
// //       random.nextInt(256),
// //       1,
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
// //       Color backgroundColor = colorProvider.isItemFocused
// //           ? colorProvider.dominantColor.withOpacity(0.5)
// //           : cardColor;
// //       return Container(
// //         color: backgroundColor,
// //         child: Container(
// //           padding: EdgeInsets.symmetric(
// //               vertical: screenhgt * 0.01, horizontal: screenwdt * 0.04),
// //           color: cardColor,
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //             children: [
// //               IntrinsicWidth(
// //                 child: _buildNavigationItem('', 0, _focusNodes[0]),
// //               ),
// //               Spacer(),
// //               Row(
// //                 children: [
// //                   _buildNavigationItem('Vod', 1, _focusNodes[1]),
// //                   _buildNavigationItem('Live TV', 2, _focusNodes[2]),
// //                   _buildNavigationItem('Search', 3, _focusNodes[3]),
// //                   _buildNavigationItem('Youtube', 4, _focusNodes[4]),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     });
// //   }

// //   Widget _buildNavigationItem(String title, int index, FocusNode focusNode) {
// //     return Padding(
// //       padding: EdgeInsets.only(
// //           top: screenwdt * 0.007,
// //           left: screenwdt * 0.013,
// //           right: screenwdt * 0.013),
// //       child: IntrinsicWidth(
// //         child: Focus(
// //           focusNode: focusNode,
// //           onFocusChange: (hasFocus) {
// //             setState(() {
// //               if (hasFocus) {
// //                 // Navigation focus updates
// //                 if (index == 4) {
// //                   context
// //                       .read<FocusProvider>()
// //                       .setYoutubeSearchNavigationFocusNode(focusNode);
// //                 }

// //                 if (index == 3) {
// //                   context
// //                       .read<FocusProvider>()
// //                       .setSearchNavigationFocusNode(focusNode);
// //                 }
// //                 if (index == 2) {
// //                   context.read<FocusProvider>().setLiveTvFocusNode(focusNode);
// //                 }
// //                 if (index == 1) {
// //                   context.read<FocusProvider>().setVodMenuFocusNode(focusNode);
// //                 }

// //                 // Har baar naya color generate karein
// //                 final newColor = _generateRandomColor();
// //                 context.read<ColorProvider>().updateColor(newColor, true);
// //               } else {
// //                 context.read<ColorProvider>().resetColor();
// //               }
// //             });
// //           },
// //           onKeyEvent: (node, event) {
// //             if (event is KeyDownEvent) {
// //               if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
// //                 if (index == 1) {
// //                   Future.delayed(Duration(milliseconds: 100), () {
// //                     context.read<FocusProvider>().requestVodBannerFocus();
// //                   });
// //                 }
// //                 if (index == 2) {
// //                   Future.delayed(Duration(milliseconds: 100), () {
// //                     context.read<FocusProvider>().requestLiveScreenFocus();
// //                   });
// //                 }
// //                 if (index == 3) {
// //                   Future.delayed(Duration(milliseconds: 100), () {
// //                     context.read<FocusProvider>().requestSearchIconFocus();
// //                   });
// //                 }
// //                 if (index == 4) {
// //                   Future.delayed(Duration(milliseconds: 100), () {
// //                     context
// //                         .read<FocusProvider>()
// //                         .requestYoutubeSearchIconFocus();
// //                   });
// //                 }

// //                 Future.delayed(Duration(milliseconds: 100), () {
// //                   context.read<FocusProvider>().requestWatchNowFocus();
// //                 });

// //                 return KeyEventResult.handled;
// //               } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
// //                 _focusNodes[(index + 1) % _focusNodes.length].requestFocus();
// //                 return KeyEventResult.handled;
// //               } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
// //                 _focusNodes[
// //                         (index - 1 + _focusNodes.length) % _focusNodes.length]
// //                     .requestFocus();
// //                 return KeyEventResult.handled;
// //               } else if (event.logicalKey == LogicalKeyboardKey.select ||
// //                   event.logicalKey == LogicalKeyboardKey.enter) {
// //                 widget.onPageSelected(index);

// //                 if (index == 0) {
// //                   Future.delayed(Duration(milliseconds: 100), () {
// //                     context.read<FocusProvider>().requestWatchNowFocus();
// //                   });
// //                 }
// //                 if (index == 1) {
// //                   Future.delayed(Duration(milliseconds: 100), () {
// //                     context.read<FocusProvider>().requestVodBannerFocus();
// //                   });
// //                 }
// //                 if (index == 2) {
// //                   Future.delayed(Duration(milliseconds: 100), () {
// //                     context.read<FocusProvider>().requestLiveScreenFocus();
// //                   });
// //                 }
// //                 if (index == 3) {
// //                   Future.delayed(Duration(milliseconds: 100), () {
// //                     context.read<FocusProvider>().requestSearchIconFocus();
// //                   });
// //                 }
// //                 if (index == 4) {
// //                   Future.delayed(Duration(milliseconds: 100), () {
// //                     context
// //                         .read<FocusProvider>()
// //                         .requestYoutubeSearchIconFocus();
// //                   });
// //                 }

// //                 return KeyEventResult.handled;
// //               }
// //             }
// //             return KeyEventResult.ignored;
// //           },
// //           child: GestureDetector(
// //             onTap: () {
// //               widget.onPageSelected(index);
// //               focusNode.requestFocus();
// //             },
// //             child: RandomLightColorWidget(
// //               hasFocus: focusNode.hasFocus,
// //               childBuilder: (Color randomColor) {
// //                 return Container(
// //                   margin: EdgeInsets.all(screenwdt * 0.001),
// //                   decoration: BoxDecoration(
// //                     color: focusNode.hasFocus
// //                         ? const Color.fromARGB(255, 5, 3, 3)
// //                         : Colors.transparent,
// //                     borderRadius: BorderRadius.circular(8),
// //                     border: Border.all(
// //                       color: focusNode.hasFocus
// //                           ? randomColor
// //                           : Colors.transparent,
// //                       width: 2,
// //                     ),
// //                     boxShadow: focusNode.hasFocus
// //                         ? [
// //                             BoxShadow(
// //                               color: randomColor,
// //                               blurRadius: 15.0,
// //                               spreadRadius: 5.0,
// //                             ),
// //                           ]
// //                         : [],
// //                   ),
// //                   padding: EdgeInsets.symmetric(
// //                       vertical: screenhgt * 0.01, horizontal: screenwdt * 0.01),
// //                   child: index == 0
// //                       ? Image.asset(
// //                           'assets/logo3.png',
// //                           height: screenhgt * 0.05,
// //                         )
// //                       : Center(
// //                           child: Text(
// //                             title,
// //                             style: TextStyle(
// //                               // color: focusNode.hasFocus ? currentColor : hintColor,
// //                               color: widget.selectedPage == index
// //                                   ? Colors.red // Selected button text color red
// //                                   : (focusNode.hasFocus
// //                                       ? randomColor
// //                                       : hintColor),
// //                               fontSize: menutextsz,
// //                               fontWeight: focusNode.hasFocus
// //                                   ? FontWeight.bold
// //                                   : FontWeight.normal,
// //                             ),
// //                           ),
// //                         ),
// //                 );
// //               },
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }






// import 'dart:math';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:provider/provider.dart';
// import '../main.dart';
// import '../widgets/small_widgets/app_assets.dart';
// import '../widgets/utils/random_light_color_widget.dart';

// class TopNavigationBar extends StatefulWidget {
//   final int selectedPage;
//   final ValueChanged<int> onPageSelected;
//   final bool tvenableAll;

//   const TopNavigationBar({
//     required this.selectedPage,
//     required this.onPageSelected,
//     required this.tvenableAll,
//   });

//   @override
//   _TopNavigationBarState createState() => _TopNavigationBarState();
// }

// class _TopNavigationBarState extends State<TopNavigationBar> {
//   late List<FocusNode> _focusNodes;
//   final List<String> navItems = [/*'Vod', 'Live TV',*/ 'Search'];
//   String logoUrl = '';

//   @override
//   void initState() {
//     super.initState();
//     logoUrl = SessionManager.logoUrl;
//     print('logoUrl:$logoUrl');
//     _focusNodes = List.generate(navItems.length + 1, (index) => FocusNode());

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusNodes[0].requestFocus();
//       context.read<FocusProvider>().setTopNavigationFocusNode(_focusNodes[0]);
//     });
//   }

//   @override
//   void dispose() {
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   Color _generateRandomColor() {
//     final random = Random();
//     return Color.fromRGBO(
//       random.nextInt(256),
//       random.nextInt(256),
//       random.nextInt(256),
//       1,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('LOGOURL: "${SessionManager.logoUrl}"');
//     return PopScope(
//         canPop: false, // Back button se page pop nahi hoga
//         onPopInvoked: (didPop) {
//           if (!didPop) {
//             // Back button dabane par ye function call hoga
//             context.read<FocusProvider>().requestWatchNowFocus();
//           }
//         },
//         child:
//             Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//           Color backgroundColor = colorProvider.isItemFocused
//               ? colorProvider.dominantColor.withOpacity(0.8)
//               : cardColor;

//           return Container(
//             color: backgroundColor,
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                   vertical: screenhgt * 0.01, horizontal: screenwdt * 0.04),
//               color: cardColor,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   IntrinsicWidth(
//                     child: _buildNavigationItem('', 0, _focusNodes[0]),
//                   ),
//                   Spacer(),
//                   Row(
//                     children: List.generate(navItems.length, (i) {
//                       final index = i + 1; // offset by 1 due to logo
//                       return _buildNavigationItem(
//                           navItems[i], index, _focusNodes[index]);
//                     }),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }));
//   }

//   Widget _buildNavigationItem(String title, int index, FocusNode focusNode) {
//     return Padding(
//       padding: EdgeInsets.only(
//         top: screenwdt * 0.007,
//         left: screenwdt * 0.013,
//         right: screenwdt * 0.013,
//       ),
//       child: IntrinsicWidth(
//         child: Focus(
//           focusNode: focusNode,
//           onFocusChange: (hasFocus) {
//             setState(() {
//               if (hasFocus) {
//                 switch (index) {
//                   // case 1:
//                   //   context
//                   //       .read<FocusProvider>()
//                   //       .setVodMenuFocusNode(focusNode);
//                   //   break;
//                   // case 2:
//                   //   context.read<FocusProvider>().setLiveTvFocusNode(focusNode);
//                   //   break;
//                   case 1:
//                     context
//                         .read<FocusProvider>()
//                         .setSearchNavigationFocusNode(focusNode);
//                     break;
//                   // case 4:
//                   //   context
//                   //       .read<FocusProvider>()
//                   //       .setYoutubeSearchNavigationFocusNode(focusNode);
//                   //   break;
//                 }

//                 final newColor = _generateRandomColor();
//                 context.read<ColorProvider>().updateColor(newColor, true);
//               } else {
//                 context.read<ColorProvider>().resetColor();
//               }
//             });
//           },
//           onKeyEvent: (node, event) {
//             if (event is KeyDownEvent) {
//               if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                 if (index == widget.selectedPage) {
//                   switch (index) {
//                     case 0:
//                       context.read<FocusProvider>().requestWatchNowFocus();
//                       break;
//                     // case 1:
//                     //   context.read<FocusProvider>().requestVodBannerFocus();
//                     //   break;
//                     // case 2:
//                     //   context.read<FocusProvider>().requestLiveScreenFocus();
//                     //   break;
//                     case 1:
//                       context.read<FocusProvider>().requestSearchIconFocus();
//                       break;
//                     // case 4:
//                     //   context
//                     //       .read<FocusProvider>()
//                     //       .requestYoutubeSearchIconFocus();
//                     //   break;
//                   }
//                 } else {
//                   context.read<FocusProvider>().requestWatchNowFocus();
//                 }
//                 return KeyEventResult.handled;
//               } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//                   event.logicalKey == LogicalKeyboardKey.select) {
//                 switch (index) {
//                   case 0:
//                     context.read<FocusProvider>().requestWatchNowFocus();
//                     break;
//                   // case 1:
//                   //   context.read<FocusProvider>().requestVodBannerFocus();
//                   //   break;
//                   // case 2:
//                   //   context.read<FocusProvider>().requestLiveScreenFocus();
//                   //   break;
//                   case 1:
//                     context.read<FocusProvider>().requestSearchIconFocus();
//                     break;
//                   // case 4:
//                   //   context
//                   //       .read<FocusProvider>()
//                   //       .requestYoutubeSearchIconFocus();
//                   //   break;
//                 }

//                 widget.onPageSelected(index);
//                 return KeyEventResult.handled;
//               } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                 _focusNodes[(index + 1) % _focusNodes.length].requestFocus();
//                 return KeyEventResult.handled;
//               } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//                 _focusNodes[
//                         (index - 1 + _focusNodes.length) % _focusNodes.length]
//                     .requestFocus();
//                 return KeyEventResult.handled;
//               }
//             }
//             return KeyEventResult.ignored;
//           },
//           child: GestureDetector(
//             onTap: () {
//               widget.onPageSelected(index);
//               focusNode.requestFocus();
//             },
//             child: RandomLightColorWidget(
//               hasFocus: focusNode.hasFocus,
//               childBuilder: (Color randomColor) {
//                 return Container(
//                   margin: EdgeInsets.all(screenwdt * 0.001),
//                   decoration: BoxDecoration(
//                     color: focusNode.hasFocus
//                         ? const Color.fromARGB(255, 5, 3, 3)
//                         : Colors.transparent,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color:
//                           focusNode.hasFocus ? randomColor : Colors.transparent,
//                       width: 2,
//                     ),
//                     boxShadow: focusNode.hasFocus
//                         ? [
//                             BoxShadow(
//                               color: randomColor,
//                               blurRadius: 15.0,
//                               spreadRadius: 5.0,
//                             ),
//                           ]
//                         : [],
//                   ),
//                   padding: EdgeInsets.symmetric(
//                     vertical: screenhgt * 0.01,
//                     horizontal: screenwdt * 0.01,
//                   ),
//                   child: index == 0
//                       ? // With custom colors and high contrast
// // AppAssets.localImage(
// //   width: screenhgt * 0.1,
// //   textColor: Colors.yellow,
// //   backgroundColor: Colors.black12,
// //   glowColor: Colors.red,
// //   highContrast: true,
// // )

// // AppAssets.logoSmall()
//                       // Image.asset(
//                       //     'assets/logo3.png',
//                       //     height: screenhgt * 0.05,
//                       //   )
//                       // if (logo.isNotEmpty) // Check karein ki URL khali na ho
//                       CachedNetworkImage(
//                           imageUrl: SessionManager.logoUrl ,
//                           height: screenhgt *
//                               0.05, // Apni zaroorat ke hisab se height/width set karein
//                           placeholder: (context, url) =>
//                               CircularProgressIndicator(), // Jab tak image load ho rahi hai
//                           errorWidget: (context, url, error) =>
//                               Icon(Icons.error)
//                           // Agar image load na ho paye
//                           )
//                       : index == 4 // Youtube icon
//                           ? Image.asset(
//                               'assets/youtube.png',
//                               height: screenhgt * 0.05,
//                             )
//                           : Center(
//                               child: Text(
//                                 title,
//                                 style: TextStyle(
//                                   color: widget.selectedPage == index
//                                       ? Colors.red
//                                       : (focusNode.hasFocus
//                                           ? randomColor
//                                           : hintColor),
//                                   fontSize: menutextsz,
//                                   fontWeight: focusNode.hasFocus
//                                       ? FontWeight.bold
//                                       : FontWeight.normal,
//                                 ),
//                               ),
//                             ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }










// import 'dart:math';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:provider/provider.dart';
// import '../main.dart';
// import '../widgets/small_widgets/app_assets.dart';

// // ✅ Professional Color Palette
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

// class TopNavigationBar extends StatefulWidget {
//   final int selectedPage;
//   final ValueChanged<int> onPageSelected;
//   final bool tvenableAll;

//   const TopNavigationBar({
//     required this.selectedPage,
//     required this.onPageSelected,
//     required this.tvenableAll,
//   });

//   @override
//   _TopNavigationBarState createState() => _TopNavigationBarState();
// }

// class _TopNavigationBarState extends State<TopNavigationBar>
//     with SingleTickerProviderStateMixin {
//   late List<FocusNode> _focusNodes;
//   final List<NavItem> navItems = [
//     NavItem(title: 'Search', icon: Icons.search),
//   ];
//   String logoUrl = '';
//   late AnimationController _animationController;
//   int _currentColorIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     logoUrl = SessionManager.logoUrl;
//     print('logoUrl:$logoUrl');
//     _focusNodes = List.generate(navItems.length + 1, (index) => FocusNode());

//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 300),
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusNodes[0].requestFocus();
//       context.read<FocusProvider>().setTopNavigationFocusNode(_focusNodes[0]);
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   Color _getNextColor() {
//     _currentColorIndex =
//         (_currentColorIndex + 1) % ProfessionalColors.gradientColors.length;
//     return ProfessionalColors.gradientColors[_currentColorIndex];
//   }




// @override
// Widget build(BuildContext context) {
//   return PopScope(
//     canPop: false,
//     onPopInvoked: (didPop) {
//       if (!didPop) {
//         context.read<FocusProvider>().requestWatchNowFocus();
//       }
//     },
//     child: Consumer<ColorProvider>(
//       builder: (context, colorProvider, child) {
//         final bool isFocused = colorProvider.isItemFocused;
//         final Color dominantColor = colorProvider.dominantColor;

//         // ✅ Jab item focused ho to ye decoration use hoga
//         final focusedDecoration = BoxDecoration(
//           color: dominantColor.withOpacity(0.25), // Solid color background
//           boxShadow: [
//             BoxShadow(
//               color: dominantColor.withOpacity(0.4), // Background se glow effect
//               blurRadius: 30,
//               offset: const Offset(0, 4),
//             ),
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 20,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         );

//         // ✅ Default decoration
//         final defaultDecoration = BoxDecoration(
//           color: ProfessionalColors.primaryDark, // Default solid color
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 20,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         );

//         // ✅ Smooth transition ke liye AnimatedContainer
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//           decoration: isFocused ? focusedDecoration : defaultDecoration,
//           child: Container(
//             padding: EdgeInsets.symmetric(
//               vertical: screenhgt * 0.015,
//               horizontal: screenwdt * 0.04,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Logo Section
//                 _buildLogoItem(_focusNodes[0]),

//                 // Navigation Items
//                 Row(
//                   children: List.generate(navItems.length, (i) {
//                     final index = i + 1;
//                     return _buildNavigationItem(
//                       navItems[i],
//                       index,
//                       _focusNodes[index],
//                     );
//                   }),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     ),
//   );
// }

//   Widget _buildLogoItem(FocusNode focusNode) {
//     return Focus(
//       focusNode: focusNode,
//       onFocusChange: (hasFocus) {
//         setState(() {
//           if (hasFocus) {
//             _animationController.forward();
//             context.read<ColorProvider>().updateColor(
//                   ProfessionalColors.focusGlow,
//                   true,
//                 );
//           } else {
//             _animationController.reverse();
//             context.read<ColorProvider>().resetColor();
//           }
//         });
//       },
//       onKeyEvent: (node, event) => _handleKeyEvent(node, event, 0),
//       child: GestureDetector(
//         onTap: () {
//           widget.onPageSelected(0);
//           focusNode.requestFocus();
//         },
//         child: AnimatedContainer(
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           padding: EdgeInsets.all(screenwdt * 0.008),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             gradient: focusNode.hasFocus
//                 ? LinearGradient(
//                     colors: [
//                       ProfessionalColors.accentBlue,
//                       ProfessionalColors.accentPurple,
//                     ],
//                   )
//                 : null,
//             boxShadow: focusNode.hasFocus
//                 ? [
//                     BoxShadow(
//                       color: ProfessionalColors.focusGlow.withOpacity(0.6),
//                       blurRadius: 20,
//                       spreadRadius: 2,
//                     ),
//                   ]
//                 : [],
//           ),
//           child: Container(
//             padding: EdgeInsets.all(screenwdt * 0.006),
//             decoration: BoxDecoration(
//               color: focusNode.hasFocus
//                   ? ProfessionalColors.primaryDark
//                   : Colors.transparent,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: CachedNetworkImage(
//               imageUrl: SessionManager.logoUrl,
//               height: screenhgt * 0.05,
//               placeholder: (context, url) => SizedBox(
//                 height: screenhgt * 0.05,
//                 width: screenhgt * 0.05,
//                 child: Center(
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       ProfessionalColors.accentBlue,
//                     ),
//                   ),
//                 ),
//               ),
//               errorWidget: (context, url, error) => Icon(
//                 Icons.broken_image,
//                 color: ProfessionalColors.textSecondary,
//                 size: screenhgt * 0.05,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavigationItem(
//     NavItem item,
//     int index,
//     FocusNode focusNode,
//   ) {
//     return Padding(
//       padding: EdgeInsets.only(left: screenwdt * 0.02),
//       child: Focus(
//         focusNode: focusNode,
//         onFocusChange: (hasFocus) {
//           setState(() {
//             if (hasFocus) {
//               _animationController.forward();
//               switch (index) {
//                 case 1:
//                   context
//                       .read<FocusProvider>()
//                       .setSearchNavigationFocusNode(focusNode);
//                   break;
//               }
//               final newColor = _getNextColor();
//               context.read<ColorProvider>().updateColor(newColor, true);
//             } else {
//               _animationController.reverse();
//               context.read<ColorProvider>().resetColor();
//             }
//           });
//         },
//         onKeyEvent: (node, event) => _handleKeyEvent(node, event, index),
//         child: GestureDetector(
//           onTap: () {
//             widget.onPageSelected(index);
//             focusNode.requestFocus();
//           },
//           child: AnimatedContainer(
//             duration: Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             padding: EdgeInsets.symmetric(
//               vertical: screenhgt * 0.012,
//               horizontal: screenwdt * 0.025,
//             ),
//             decoration: BoxDecoration(
//               gradient: focusNode.hasFocus
//                   ? LinearGradient(
//                       colors: [
//                         ProfessionalColors
//                             .gradientColors[_currentColorIndex]
//                             .withOpacity(0.3),
//                         ProfessionalColors
//                             .gradientColors[(_currentColorIndex + 1) %
//                                 ProfessionalColors.gradientColors.length]
//                             .withOpacity(0.3),
//                       ],
//                     )
//                   : null,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: focusNode.hasFocus
//                     ? ProfessionalColors.gradientColors[_currentColorIndex]
//                     : widget.selectedPage == index
//                         ? ProfessionalColors.accentBlue.withOpacity(0.5)
//                         : Colors.transparent,
//                 width: 2,
//               ),
//               boxShadow: focusNode.hasFocus
//                   ? [
//                       BoxShadow(
//                         color: ProfessionalColors
//                             .gradientColors[_currentColorIndex]
//                             .withOpacity(0.5),
//                         blurRadius: 15,
//                         spreadRadius: 2,
//                       ),
//                     ]
//                   : [],
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   item.icon,
//                   color: focusNode.hasFocus
//                       ? ProfessionalColors.textPrimary
//                       : widget.selectedPage == index
//                           ? ProfessionalColors.accentBlue
//                           : ProfessionalColors.textSecondary,
//                   size: screenhgt * 0.03,
//                 ),
//                 SizedBox(width: screenwdt * 0.01),
//                 Text(
//                   item.title,
//                   style: TextStyle(
//                     color: focusNode.hasFocus
//                         ? ProfessionalColors.textPrimary
//                         : widget.selectedPage == index
//                             ? ProfessionalColors.accentBlue
//                             : ProfessionalColors.textSecondary,
//                     fontSize: menutextsz,
//                     fontWeight:
//                         focusNode.hasFocus ? FontWeight.bold : FontWeight.w500,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   KeyEventResult _handleKeyEvent(
//     FocusNode node,
//     KeyEvent event,
//     int index,
//   ) {
//     if (event is KeyDownEvent) {
//       if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//         if (index == widget.selectedPage) {
//           switch (index) {
//             case 0:
//               context.read<FocusProvider>().requestWatchNowFocus();
//               break;
//             case 1:
//               context.read<FocusProvider>().requestSearchIconFocus();
//               break;
//           }
//         } else {
//           context.read<FocusProvider>().requestWatchNowFocus();
//         }
//         return KeyEventResult.handled;
//       } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//           event.logicalKey == LogicalKeyboardKey.select) {
//         switch (index) {
//           case 0:
//             context.read<FocusProvider>().requestWatchNowFocus();
//             break;
//           case 1:
//             context.read<FocusProvider>().requestSearchIconFocus();
//             break;
//         }
//         widget.onPageSelected(index);
//         return KeyEventResult.handled;
//       } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//         _focusNodes[(index + 1) % _focusNodes.length].requestFocus();
//         return KeyEventResult.handled;
//       } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//         _focusNodes[(index - 1 + _focusNodes.length) % _focusNodes.length]
//             .requestFocus();
//         return KeyEventResult.handled;
//       }
//     }
//     return KeyEventResult.ignored;
//   }
// }

// // Helper class for navigation items
// class NavItem {
//   final String title;
//   final IconData icon;

//   NavItem({required this.title, required this.icon});
// }






import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/components/menu_screens/search_screen.dart';
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../widgets/small_widgets/app_assets.dart';

// ✅ Professional Color Palette
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

class TopNavigationBar extends StatefulWidget {
  final int selectedPage;
  final ValueChanged<int> onPageSelected;
  final bool tvenableAll;

  const TopNavigationBar({
    required this.selectedPage,
    required this.onPageSelected,
    required this.tvenableAll,
  });

  @override
  _TopNavigationBarState createState() => _TopNavigationBarState();
}

class _TopNavigationBarState extends State<TopNavigationBar>
    with SingleTickerProviderStateMixin {
  late List<FocusNode> _focusNodes;
  final List<NavItem> navItems = [
    NavItem(title: 'Search', icon: Icons.search),
  ];
  String logoUrl = '';
  late AnimationController _animationController;
  int _currentColorIndex = 0;

  @override
  void initState() {
    super.initState();
    logoUrl = SessionManager.logoUrl;
    print('logoUrl:$logoUrl');
    _focusNodes = List.generate(navItems.length + 1, (index) => FocusNode());

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
      context.read<FocusProvider>().registerFocusNode('topNavigation', _focusNodes[0]);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getNextColor() {
    _currentColorIndex =
        (_currentColorIndex + 1) % ProfessionalColors.gradientColors.length;
    return ProfessionalColors.gradientColors[_currentColorIndex];
  }




@override
Widget build(BuildContext context) {
  return PopScope(
    canPop: false,
    onPopInvoked: (didPop) {
      if (!didPop) {
        context.read<FocusProvider>().requestFocus('watchNow');
      }
    },
    child: Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        final bool isFocused = colorProvider.isItemFocused;
        final Color dominantColor = colorProvider.dominantColor;

        // ✅ Jab item focused ho to ye decoration use hoga
        final focusedDecoration = BoxDecoration(
          color: dominantColor.withOpacity(0.25), // Solid color background
          boxShadow: [
            BoxShadow(
              color: dominantColor.withOpacity(0.4), // Background se glow effect
              blurRadius: 30,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        );

        // // ✅ Default decoration
        // final defaultDecoration = BoxDecoration(
        //   color: ProfessionalColors.primaryDark, // Default solid color
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withOpacity(0.3),
        //       blurRadius: 20,
        //       offset: const Offset(0, 4),
        //     ),
        //   ],
        // );


        // top_navigation_bar.dart ke 'build' method mein

// ✅ Default decoration
final defaultDecoration = BoxDecoration(
  // ✅ RANG KO TRANSPARENT KIYA GAYA HAI
  color: ProfessionalColors.primaryDark.withOpacity(0.65), // 65% opacity
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ],
);

        // ✅ Smooth transition ke liye AnimatedContainer
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          decoration: isFocused ? focusedDecoration : defaultDecoration,
          child: Container(
            padding: EdgeInsets.only(
              top: screenhgt * 0.03,
              right: screenwdt * 0.04,
              bottom: screenhgt * 0.015,
              left: screenwdt * 0.04,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                // Logo Section
                _buildLogoItem(_focusNodes[0]),

                // Navigation Items
                Row(
                  children: List.generate(navItems.length, (i) {
                    final index = i + 1;
                    return _buildNavigationItem(
                      navItems[i],
                      index,
                      _focusNodes[index],
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildLogoItem(FocusNode focusNode) {
  bool hasFocus = focusNode.hasFocus;
  // ✅ Current color ko yahan access karenge taaki decoration mein use kar sakein
  Color currentAccentColor = ProfessionalColors.gradientColors[_currentColorIndex];

  return AnimatedScale(
    scale: hasFocus ? 1.08 : 1.0,
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
    child: Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) {
        setState(() {
          if (hasFocus) {
            _animationController.forward();
            
            // ✨ YAHAN BADLAV KIYA GAYA HAI ✨
            // Ab logo bhi naya color lega, fixed color nahi
            final newColor = _getNextColor();
            context.read<ColorProvider>().updateColor(newColor, true);

          } else {
            _animationController.reverse();
            context.read<ColorProvider>().resetColor();
          }
        });
      },
      onKeyEvent: (node, event) => _handleKeyEvent(node, event, 0),
      child: GestureDetector(
        onTap: () {
          widget.onPageSelected(0);
          focusNode.requestFocus();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal:  screenwdt * 0.012,vertical: screenhgt * 0.007),
          decoration: BoxDecoration(
            color: hasFocus
                ? ProfessionalColors.surfaceDark
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              // ✨ YAHAN BHI BADLAV KIYA GAYA HAI ✨
              // Ab border ka color fixed nahi, dynamic hai
              color: hasFocus
                  ? currentAccentColor 
                  : Colors.white.withOpacity(0.1),
              width: hasFocus ? 2.5 : 1.5,
            ),
            boxShadow: hasFocus
                ? [
                    BoxShadow(
                      // ✨ AUR YAHAN BHI ✨
                      // Shadow ka color bhi ab dynamic hai
                      color: currentAccentColor.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: CachedNetworkImage(
            imageUrl: SessionManager.logoUrl,
            height: screenhgt * 0.05,
            placeholder: (context, url) => SizedBox(
              height: screenhgt * 0.05,
              width: screenhgt * 0.05,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ProfessionalColors.accentBlue,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.broken_image,
              color: ProfessionalColors.textSecondary,
              size: screenhgt * 0.05,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildNavigationItem(
  NavItem item,
  int index,
  FocusNode focusNode,
) {
  bool isSelected = widget.selectedPage == index;
  bool hasFocus = focusNode.hasFocus;
  
  // ✅ Yahan se accent color milta hai jo poore bar ka background glow banata hai
  Color currentAccentColor = ProfessionalColors.gradientColors[_currentColorIndex];

  return AnimatedScale(
    scale: hasFocus ? 1.08 : 1.0, // Thoda subtle pop effect
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
    child: Padding(
      padding: EdgeInsets.only(left: screenwdt * 0.02),
      child: Focus(
        focusNode: focusNode,
        onFocusChange: (hasFocus) {
          setState(() {
            if (hasFocus) {
              _animationController.forward();
              switch (index) {
                case 1:
                  context
                      .read<FocusProvider>()
                      .registerFocusNode('searchNavigation', focusNode);
                  break;
              }
              // ✨ YEH IMPORTANT HAI: Ye line poore navigation bar ka color badalti hai
              final newColor = _getNextColor();
              context.read<ColorProvider>().updateColor(newColor, true);
            } else {
              _animationController.reverse();
              context.read<ColorProvider>().resetColor();
            }
          });
        },
        onKeyEvent: (node, event) => _handleKeyEvent(node, event, index),
        child: GestureDetector(
          // onTap: () {
          //   widget.onPageSelected(index);
          //   focusNode.requestFocus();
          // },
          onTap: () {
            if (index == 1) { // index 1 = Search button
              // Naya logic: Search page par navigate karein
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            } else {
              // Purana logic (agar future mein aur buttons add hote hain)
              widget.onPageSelected(index);
              focusNode.requestFocus();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              vertical: screenhgt * 0.012,
              horizontal: screenwdt * 0.025,
            ),
            decoration: BoxDecoration(
              // ✅ FOCUSED STATE: Solid background + Colored Border
              color: hasFocus
                  ? ProfessionalColors.surfaceDark // Dark solid background
                  : isSelected
                      ? ProfessionalColors.accentBlue.withOpacity(0.15)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                // ✅ Border focus par highlight hota hai
                color: hasFocus
                    ? currentAccentColor
                    : isSelected
                        ? ProfessionalColors.accentBlue.withOpacity(0.4)
                        : Colors.white.withOpacity(0.1),
                width: hasFocus ? 2.5 : 1.5,
              ),
              boxShadow: hasFocus
                  ? [
                      // ✅ Shadow bhi focus color se glow karta hai
                      BoxShadow(
                        color: currentAccentColor.withOpacity(0.5),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  color: hasFocus
                      ? currentAccentColor // Icon bhi focus color ka hoga
                      : isSelected
                          ? ProfessionalColors.accentBlue
                          : ProfessionalColors.textSecondary,
                  size: screenhgt * 0.04,
                ),
                SizedBox(width: screenwdt * 0.01),
                Text(
                  item.title,
                  style: TextStyle(
                    color: hasFocus
                        ? ProfessionalColors.textPrimary // Text white rahega
                        : isSelected
                            ? ProfessionalColors.accentBlue
                            : ProfessionalColors.textSecondary,
                    fontSize: menutextsz,
                    fontWeight:
                        hasFocus ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  KeyEventResult _handleKeyEvent(
    FocusNode node,
    KeyEvent event,
    int index,
  ) {
    if (event is KeyDownEvent) {
      if (index == 1) { 
        // Aur user Enter, Select, ya Arrow Down dabata hai
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.arrowDown) {
          
          // SearchScreen par navigate karein
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
          return KeyEventResult.handled; // Event ko handle kar liya
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (index == widget.selectedPage) {
          switch (index) {
            case 0:
              context.read<FocusProvider>().requestFocus('watchNow');
              break;
            case 1:
              context.read<FocusProvider>().requestFocus('searchIcon');
              break;
          }
        } else {
          context.read<FocusProvider>().requestFocus('watchNow');
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        switch (index) {
          case 0:
            context.read<FocusProvider>().requestFocus('watchNow');
            break;
          case 1:
            context.read<FocusProvider>().requestFocus('searchIcon');
            break;
        }
        widget.onPageSelected(index);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _focusNodes[(index + 1) % _focusNodes.length].requestFocus();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _focusNodes[(index - 1 + _focusNodes.length) % _focusNodes.length]
            .requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}

// Helper class for navigation items
class NavItem {
  final String title;
  final IconData icon;

  NavItem({required this.title, required this.icon});
}