// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:provider/provider.dart';
// import '../main.dart';
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

//   @override
//   void initState() {
//     super.initState();
//     _focusNodes = List.generate(5, (index) => FocusNode());

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

//   // Color generator function
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
//     return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//       Color backgroundColor = colorProvider.isItemFocused
//           ? colorProvider.dominantColor.withOpacity(0.5)
//           : cardColor;
//       return Container(
//         color: backgroundColor,
//         child: Container(
//           padding: EdgeInsets.symmetric(
//               vertical: screenhgt * 0.01, horizontal: screenwdt * 0.04),
//           color: cardColor,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               IntrinsicWidth(
//                 child: _buildNavigationItem('', 0, _focusNodes[0]),
//               ),
//               Spacer(),
//               Row(
//                 children: [
//                   _buildNavigationItem('Vod', 1, _focusNodes[1]),
//                   _buildNavigationItem('Live TV', 2, _focusNodes[2]),
//                   _buildNavigationItem('Search', 3, _focusNodes[3]),
//                   _buildNavigationItem('Youtube', 4, _focusNodes[4]),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }

//   Widget _buildNavigationItem(String title, int index, FocusNode focusNode) {
//     return Padding(
//       padding: EdgeInsets.only(
//           top: screenwdt * 0.007,
//           left: screenwdt * 0.013,
//           right: screenwdt * 0.013),
//       child: IntrinsicWidth(
//         child: Focus(
//           focusNode: focusNode,
//           onFocusChange: (hasFocus) {
//             setState(() {
//               if (hasFocus) {
//                 // Navigation focus updates
//                 if (index == 4) {
//                   context
//                       .read<FocusProvider>()
//                       .setYoutubeSearchNavigationFocusNode(focusNode);
//                 }

//                 if (index == 3) {
//                   context
//                       .read<FocusProvider>()
//                       .setSearchNavigationFocusNode(focusNode);
//                 }
//                 if (index == 2) {
//                   context.read<FocusProvider>().setLiveTvFocusNode(focusNode);
//                 }
//                 if (index == 1) {
//                   context.read<FocusProvider>().setVodMenuFocusNode(focusNode);
//                 }

//                 // Har baar naya color generate karein
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
//                 if (index == 1) {
//                   Future.delayed(Duration(milliseconds: 100), () {
//                     context.read<FocusProvider>().requestVodBannerFocus();
//                   });
//                 }
//                 if (index == 2) {
//                   Future.delayed(Duration(milliseconds: 100), () {
//                     context.read<FocusProvider>().requestLiveScreenFocus();
//                   });
//                 }
//                 if (index == 3) {
//                   Future.delayed(Duration(milliseconds: 100), () {
//                     context.read<FocusProvider>().requestSearchIconFocus();
//                   });
//                 }
//                 if (index == 4) {
//                   Future.delayed(Duration(milliseconds: 100), () {
//                     context
//                         .read<FocusProvider>()
//                         .requestYoutubeSearchIconFocus();
//                   });
//                 }

//                 Future.delayed(Duration(milliseconds: 100), () {
//                   context.read<FocusProvider>().requestWatchNowFocus();
//                 });

//                 return KeyEventResult.handled;
//               } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                 _focusNodes[(index + 1) % _focusNodes.length].requestFocus();
//                 return KeyEventResult.handled;
//               } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//                 _focusNodes[
//                         (index - 1 + _focusNodes.length) % _focusNodes.length]
//                     .requestFocus();
//                 return KeyEventResult.handled;
//               } else if (event.logicalKey == LogicalKeyboardKey.select ||
//                   event.logicalKey == LogicalKeyboardKey.enter) {
//                 widget.onPageSelected(index);

//                 if (index == 0) {
//                   Future.delayed(Duration(milliseconds: 100), () {
//                     context.read<FocusProvider>().requestWatchNowFocus();
//                   });
//                 }
//                 if (index == 1) {
//                   Future.delayed(Duration(milliseconds: 100), () {
//                     context.read<FocusProvider>().requestVodBannerFocus();
//                   });
//                 }
//                 if (index == 2) {
//                   Future.delayed(Duration(milliseconds: 100), () {
//                     context.read<FocusProvider>().requestLiveScreenFocus();
//                   });
//                 }
//                 if (index == 3) {
//                   Future.delayed(Duration(milliseconds: 100), () {
//                     context.read<FocusProvider>().requestSearchIconFocus();
//                   });
//                 }
//                 if (index == 4) {
//                   Future.delayed(Duration(milliseconds: 100), () {
//                     context
//                         .read<FocusProvider>()
//                         .requestYoutubeSearchIconFocus();
//                   });
//                 }

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
//                       color: focusNode.hasFocus
//                           ? randomColor
//                           : Colors.transparent,
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
//                       vertical: screenhgt * 0.01, horizontal: screenwdt * 0.01),
//                   child: index == 0
//                       ? Image.asset(
//                           'assets/logo3.png',
//                           height: screenhgt * 0.05,
//                         )
//                       : Center(
//                           child: Text(
//                             title,
//                             style: TextStyle(
//                               // color: focusNode.hasFocus ? currentColor : hintColor,
//                               color: widget.selectedPage == index
//                                   ? Colors.red // Selected button text color red
//                                   : (focusNode.hasFocus
//                                       ? randomColor
//                                       : hintColor),
//                               fontSize: menutextsz,
//                               fontWeight: focusNode.hasFocus
//                                   ? FontWeight.bold
//                                   : FontWeight.normal,
//                             ),
//                           ),
//                         ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }






import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../widgets/small_widgets/app_assets.dart';
import '../widgets/utils/random_light_color_widget.dart';

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

class _TopNavigationBarState extends State<TopNavigationBar> {
  late List<FocusNode> _focusNodes;
  final List<String> navItems = ['Vod', 'Live TV', 'Search'];
  String logoUrl = '';

  @override
  void initState() {
    super.initState();
    logoUrl = SessionManager.logoUrl;
    print('logoUrl:$logoUrl');
    _focusNodes = List.generate(navItems.length + 1, (index) => FocusNode());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
      context.read<FocusProvider>().setTopNavigationFocusNode(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Color _generateRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('LOGOURL: "${SessionManager.logoUrl}"');
    return PopScope(
        canPop: false, // Back button se page pop nahi hoga
        onPopInvoked: (didPop) {
          if (!didPop) {
            // Back button dabane par ye function call hoga
            context.read<FocusProvider>().requestWatchNowFocus();
          }
        },
        child:
            Consumer<ColorProvider>(builder: (context, colorProvider, child) {
          Color backgroundColor = colorProvider.isItemFocused
              ? colorProvider.dominantColor.withOpacity(0.8)
              : cardColor;

          return Container(
            color: backgroundColor,
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: screenhgt * 0.01, horizontal: screenwdt * 0.04),
              color: cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IntrinsicWidth(
                    child: _buildNavigationItem('', 0, _focusNodes[0]),
                  ),
                  Spacer(),
                  Row(
                    children: List.generate(navItems.length, (i) {
                      final index = i + 1; // offset by 1 due to logo
                      return _buildNavigationItem(
                          navItems[i], index, _focusNodes[index]);
                    }),
                  ),
                ],
              ),
            ),
          );
        }));
  }

  Widget _buildNavigationItem(String title, int index, FocusNode focusNode) {
    return Padding(
      padding: EdgeInsets.only(
        top: screenwdt * 0.007,
        left: screenwdt * 0.013,
        right: screenwdt * 0.013,
      ),
      child: IntrinsicWidth(
        child: Focus(
          focusNode: focusNode,
          onFocusChange: (hasFocus) {
            setState(() {
              if (hasFocus) {
                switch (index) {
                  case 1:
                    context
                        .read<FocusProvider>()
                        .setVodMenuFocusNode(focusNode);
                    break;
                  case 2:
                    context.read<FocusProvider>().setLiveTvFocusNode(focusNode);
                    break;
                  case 3:
                    context
                        .read<FocusProvider>()
                        .setSearchNavigationFocusNode(focusNode);
                    break;
                  case 4:
                    context
                        .read<FocusProvider>()
                        .setYoutubeSearchNavigationFocusNode(focusNode);
                    break;
                }

                final newColor = _generateRandomColor();
                context.read<ColorProvider>().updateColor(newColor, true);
              } else {
                context.read<ColorProvider>().resetColor();
              }
            });
          },
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                if (index == widget.selectedPage) {
                  switch (index) {
                    case 0:
                      context.read<FocusProvider>().requestWatchNowFocus();
                      break;
                    case 1:
                      context.read<FocusProvider>().requestVodBannerFocus();
                      break;
                    case 2:
                      context.read<FocusProvider>().requestLiveScreenFocus();
                      break;
                    case 3:
                      context.read<FocusProvider>().requestSearchIconFocus();
                      break;
                    case 4:
                      context
                          .read<FocusProvider>()
                          .requestYoutubeSearchIconFocus();
                      break;
                  }
                } else {
                  context.read<FocusProvider>().requestWatchNowFocus();
                }
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.select) {
                switch (index) {
                  case 0:
                    context.read<FocusProvider>().requestWatchNowFocus();
                    break;
                  case 1:
                    context.read<FocusProvider>().requestVodBannerFocus();
                    break;
                  case 2:
                    context.read<FocusProvider>().requestLiveScreenFocus();
                    break;
                  case 3:
                    context.read<FocusProvider>().requestSearchIconFocus();
                    break;
                  case 4:
                    context
                        .read<FocusProvider>()
                        .requestYoutubeSearchIconFocus();
                    break;
                }

                widget.onPageSelected(index);
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                _focusNodes[(index + 1) % _focusNodes.length].requestFocus();
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                _focusNodes[
                        (index - 1 + _focusNodes.length) % _focusNodes.length]
                    .requestFocus();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            onTap: () {
              widget.onPageSelected(index);
              focusNode.requestFocus();
            },
            child: RandomLightColorWidget(
              hasFocus: focusNode.hasFocus,
              childBuilder: (Color randomColor) {
                return Container(
                  margin: EdgeInsets.all(screenwdt * 0.001),
                  decoration: BoxDecoration(
                    color: focusNode.hasFocus
                        ? const Color.fromARGB(255, 5, 3, 3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          focusNode.hasFocus ? randomColor : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: focusNode.hasFocus
                        ? [
                            BoxShadow(
                              color: randomColor,
                              blurRadius: 15.0,
                              spreadRadius: 5.0,
                            ),
                          ]
                        : [],
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenhgt * 0.01,
                    horizontal: screenwdt * 0.01,
                  ),
                  child: index == 0
                      ? // With custom colors and high contrast
// AppAssets.localImage(
//   width: screenhgt * 0.1,
//   textColor: Colors.yellow,
//   backgroundColor: Colors.black12,
//   glowColor: Colors.red,
//   highContrast: true,
// )

// AppAssets.logoSmall()
                      // Image.asset(
                      //     'assets/logo3.png',
                      //     height: screenhgt * 0.05,
                      //   )
                      // if (logo.isNotEmpty) // Check karein ki URL khali na ho
                      CachedNetworkImage(
                          imageUrl: SessionManager.logoUrl ,
                          height: screenhgt *
                              0.05, // Apni zaroorat ke hisab se height/width set karein
                          placeholder: (context, url) =>
                              CircularProgressIndicator(), // Jab tak image load ho rahi hai
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error)
                          // Agar image load na ho paye
                          )
                      : index == 4 // Youtube icon
                          ? Image.asset(
                              'assets/youtube.png',
                              height: screenhgt * 0.05,
                            )
                          : Center(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: widget.selectedPage == index
                                      ? Colors.red
                                      : (focusNode.hasFocus
                                          ? randomColor
                                          : hintColor),
                                  fontSize: menutextsz,
                                  fontWeight: focusNode.hasFocus
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}



// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart'; // NEW: Google Fonts import
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:provider/provider.dart';
// import '../main.dart'; // Make sure your screen sizes are defined here

// // ✅ Professional Color Palette
// class ProfessionalColors {
//   static const accentBlue = Color(0xFF3B82F6);
//   static const accentPurple = Color(0xFF8B5CF6);
//   static const accentGreen = Color(0xFF10B981);
//   static const accentRed = Color(0xFFEF4444);
//   static const accentOrange = Color(0xFFF59E0B);
//   static const accentPink = Color(0xFFEC4899);
  
//   static List<Color> gradientColors = [
//     accentBlue, accentPurple, accentGreen, accentRed, accentOrange, accentPink,
//   ];
// }

// class TopNavigationBar extends StatefulWidget {
//   final int selectedPage;
//   final ValueChanged<int> onPageSelected;
//   final bool tvenableAll;

//   const TopNavigationBar({
//     super.key,
//     required this.selectedPage,
//     required this.onPageSelected,
//     required this.tvenableAll,
//   });

//   @override
//   _TopNavigationBarState createState() => _TopNavigationBarState();
// }

// class _TopNavigationBarState extends State<TopNavigationBar> {
//   late List<FocusNode> _focusNodes;
//   final List<String> navItems = ['Vod', 'Live TV', 'Search'];
//   late Color _currentFocusColor;

//   @override
//   void initState() {
//     super.initState();
//     _focusNodes = List.generate(navItems.length + 1, (index) => FocusNode());
//     _currentFocusColor = _generateRandomColor();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         _focusNodes[0].requestFocus();
//         context.read<FocusProvider>().setTopNavigationFocusNode(_focusNodes[0]);
//       }
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
//     final professionalColors = ProfessionalColors.gradientColors;
//     return professionalColors[Random().nextInt(professionalColors.length)];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//         canPop: false,
//         onPopInvoked: (didPop) {
//           if (!didPop) {
//             context.read<FocusProvider>().requestWatchNowFocus();
//           }
//         },
//         child: Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//           Color backgroundColor = colorProvider.isItemFocused
//               ? colorProvider.dominantColor.withOpacity(0.8)
//               : cardColor;

//           return Container(
//             color: backgroundColor,
//             child: Container(
//               // padding: EdgeInsets.symmetric(
//               //     vertical: screenhgt * 0.02, horizontal: screenwdt * 0.04),
//               padding: EdgeInsets.only(
//                   top: screenhgt * 0.03,
//                   bottom: screenhgt * 0.01,
//                   left: screenwdt * 0.04,
//                   right: screenwdt * 0.04),
//               color: cardColor,
//               child: Row(
//                 children: [
//                   _buildNavigationItem('', 0, _focusNodes[0]),
//                   const Spacer(),
//                   Row(
//                     children: List.generate(navItems.length, (i) {
//                       final index = i + 1;
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

//   // UPDATED: BEUTIFIED NAVIGATION ITEM WIDGET
//   Widget _buildNavigationItem(String title, int index, FocusNode focusNode) {
//     final isFocused = focusNode.hasFocus;
//     final transform = isFocused ? (Matrix4.identity()..scale(1.1)) : Matrix4.identity();

//     final Map<int, IconData> navIcons = {
//       1: Icons.movie_filter_outlined,
//       2: Icons.live_tv_rounded,
//       3: Icons.search_rounded,
//     };

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: screenwdt * 0.01, vertical: screenhgt * 0.005),
//       child: Focus(
//         focusNode: focusNode,
//         onFocusChange: (hasFocus) {
//           setState(() {
//             if (hasFocus) {
//               _currentFocusColor = _generateRandomColor();
//               context.read<ColorProvider>().updateColor(_currentFocusColor, true);
//               // Focus Provider related calls...
//             } else {
//               context.read<ColorProvider>().resetColor();
//             }
//           });
//         },
//         onKeyEvent: (node, event) {
//           // Aapka onKeyEvent logic yahan paste karein...
//           // For brevity, I've omitted the detailed key event logic
//           if (event is KeyDownEvent) {
//              if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                 _focusNodes[(index + 1) % _focusNodes.length].requestFocus();
//                 return KeyEventResult.handled;
//               } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//                 _focusNodes[
//                         (index - 1 + _focusNodes.length) % _focusNodes.length]
//                     .requestFocus();
//                 return KeyEventResult.handled;
//               } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//                   event.logicalKey == LogicalKeyboardKey.select) {
//                 widget.onPageSelected(index);
//                  // Focus transfer logic...
//                 return KeyEventResult.handled;
//               }
//           }
//           return KeyEventResult.ignored;
//         },
//         child: GestureDetector(
//           onTap: () {
//             widget.onPageSelected(index);
//             focusNode.requestFocus();
//           },
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 250),
//             curve: Curves.easeInOut,
//             transform: transform,
//             transformAlignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: isFocused ? _currentFocusColor.withOpacity(0.15) : Colors.transparent,
//               borderRadius: BorderRadius.circular(30), // Pill shape
//               border: Border.all(
//                 color: isFocused ? _currentFocusColor : Colors.transparent,
//                 width: 2,
//               ),
//               boxShadow: isFocused ? [
//                 BoxShadow(
//                   color: _currentFocusColor.withOpacity(0.5),
//                   blurRadius: 15.0,
//                   spreadRadius: 1.0,
//                 ),
//               ] : [],
//             ),
//             padding: EdgeInsets.symmetric(
//               vertical: screenhgt * 0.008,
//               horizontal: screenwdt * 0.015,
//             ),
//             child: index == 0
//                 ? Image.asset('assets/logo3.png', height: screenhgt * 0.05)
//                 : Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (navIcons.containsKey(index))
//                         Icon(
//                           navIcons[index],
//                           color: isFocused ? Colors.white : hintColor,
//                           size: menutextsz * 1.1,
//                         ),
//                       if (navIcons.containsKey(index)) const SizedBox(width: 8),
//                       Text(
//                         title,
//                         style: GoogleFonts.poppins(
//                           color: isFocused ? Colors.white : hintColor,
//                           fontSize: menutextsz,
//                           fontWeight: isFocused ? FontWeight.w600 : FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }