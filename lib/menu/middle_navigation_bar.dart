// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
// import 'package:provider/provider.dart';
// import '../main.dart';
// import '../widgets/small_widgets/app_assets.dart';
// import '../widgets/utils/random_light_color_widget.dart';

// class MiddleNavigationBar extends StatefulWidget {
//   final int selectedPage;
//   final ValueChanged<int> onPageSelected;
//   final FocusNode focusNode;
//   final int? maxPageIndex; // ✅ Dynamic max page index
//   final int? totalNavItems; // ✅ Total navigation items

//   const MiddleNavigationBar({
//     Key? key,
//     required this.selectedPage,
//     required this.onPageSelected,
//     required this.focusNode,
//     this.maxPageIndex, // Optional max page index for validation
//     this.totalNavItems, // Optional total nav items
//   }) : super(key: key);

//   @override
//   _MiddleNavigationBarState createState() => _MiddleNavigationBarState();
// }

// class _MiddleNavigationBarState extends State<MiddleNavigationBar> {
//   late List<FocusNode> _focusNodes;

//   // ✅ SINGLE SOURCE - Same as SubLiveScreen, no parameters
//   static const List<String> navItems = [
//     'Live', // Index 0
//     'Entertainment', // Index 1
//     'Music', // Index 2
//     'Movie', // Index 3
//     'News', // Index 4
//     'Sports', // Index 5
//     'Religious', // Index 6
//     'More' // Index 7
//   ];

//   @override
//   void initState() {
//     super.initState();

//     print('🔧 MiddleNavigationBar SINGLE SOURCE: $navItems');
//     print('🔧 Total nav items: ${navItems.length}');
//     print('🔧 Max page index: ${widget.maxPageIndex}');
//     print('🔧 Total provided nav items: ${widget.totalNavItems}');

//     _focusNodes = List.generate(navItems.length, (index) => FocusNode());

//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   if (_focusNodes.isNotEmpty) {
//     //     _focusNodes[0].requestFocus(); // Focus Live initially
//     //     try {
//     //       context.read<FocusProvider>().setMiddleNavigationFocusNode(_focusNodes[0]);
//     //     } catch (e) {
//     //       print('Focus provider error: $e');
//     //     }
//     //   }
//     // });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_focusNodes.isNotEmpty) {
//         // _focusNodes[0].requestFocus(); // Focus Live initially

//         try {
//           final focusProvider = context.read<FocusProvider>();
//           // focusProvider.setMiddleNavigationFocusNode(_focusNodes[0]);

//           // ✅ NEW: Register all navigation focus nodes
//           focusProvider.setMiddleNavigationFocusNodes(_focusNodes);

//           print(
//               '✅ Middle navigation focus nodes registered: ${_focusNodes.length}');
//         } catch (e) {
//           print('❌ Focus provider registration error: $e');
//         }
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
//     final random = Random();
//     return Color.fromRGBO(
//         random.nextInt(256), random.nextInt(256), random.nextInt(256), 1);
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('🎨 MiddleNavigationBar building: ${navItems.length} items');
//     print(
//         '🎯 Selected: ${widget.selectedPage} = ${widget.selectedPage < navItems.length ? navItems[widget.selectedPage] : "Invalid"}');
//     print('🎯 Valid page range: 0-${widget.maxPageIndex ?? "unknown"}');

//     return PopScope(
//         canPop: false,
//         onPopInvoked: (didPop) {
//           if (!didPop) {
//             try {
//               context.read<FocusProvider>().requestWatchNowFocus();
//             } catch (e) {
//               print('Back navigation error: $e');
//             }
//           }
//         },
//         child:
//             Consumer<ColorProvider>(builder: (context, colorProvider, child) {
//           Color backgroundColor = colorProvider.isItemFocused
//               ? colorProvider.dominantColor.withOpacity(0.5)
//               : cardColor;

//           return Container(
//             color: backgroundColor,
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                   vertical: screenhgt * 0.01, horizontal: screenwdt * 0.04),
//               color: cardColor,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: List.generate(navItems.length, (i) {
//                   print('🔨 Building: $i = ${navItems[i]}');
//                   return _buildNavigationItem(navItems[i], i, _focusNodes[i]);
//                 }),
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
//                 print('🎯 Focused: $title (index: $index)');

//                 try {
//                   final focusProvider = context.read<FocusProvider>();
//                   // Set focus provider methods if they exist
//                   switch (index) {
//                     case 0: // Live
//                       if (focusProvider.setLiveTvFocusNode != null) {
//                         focusProvider.setLiveTvFocusNode!(focusNode);
//                       }
//                       break;
//                     case 1: // Entertainment
//                       if (focusProvider.setVodMenuFocusNode != null) {
//                         focusProvider.setVodMenuFocusNode!(focusNode);
//                       }
//                       break;
//                     // Add other cases if methods exist
//                   }
//                 } catch (e) {
//                   print('Focus provider method error: $e');
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
//                 print('⬇️ Arrow down: $title (index: $index)');
//                 // ✅ Validate index before calling onPageSelected
//                 if (index >= 0 && index < navItems.length) {
//                   widget.onPageSelected(index);
//                 } else {
//                   print('❌ Invalid index for navigation: $index');
//                 }
//                 return KeyEventResult.handled;
//               } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//                   event.logicalKey == LogicalKeyboardKey.select) {
//                 print('✅ Enter: $title (index: $index)');
//                 // ✅ Validate index before calling onPageSelected
//                 widget.onPageSelected(index);
//                 // if (index >= 0 && index < navItems.length) {
//                 //   widget.onPageSelected(index);
//                 // } else {
//                 //   print('❌ Invalid index for selection: $index');
//                 // }
//                 return KeyEventResult.handled;
//               } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                 int nextIndex = (index + 1) % _focusNodes.length;
//                 print('➡️ Next: ${navItems[nextIndex]} (index: $nextIndex)');
//                 _focusNodes[nextIndex].requestFocus();
//                 return KeyEventResult.handled;
//               } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//                 int prevIndex =
//                     (index - 1 + _focusNodes.length) % _focusNodes.length;
//                 print('⬅️ Prev: ${navItems[prevIndex]} (index: $prevIndex)');
//                 _focusNodes[prevIndex].requestFocus();
//                 return KeyEventResult.handled;
//               }
//             }
//             return KeyEventResult.ignored;
//           },
//           child: GestureDetector(
//             onTap: () {
//               print('🖱️ Tapped: $title (index: $index)');
//               // ✅ Validate index before calling onPageSelected
//               if (index >= 0 && index < navItems.length) {
//                 widget.onPageSelected(index);
//                 focusNode.requestFocus();
//               } else {
//                 print('❌ Invalid index for tap: $index');
//               }
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
//                     horizontal: screenwdt * 0.005,
//                   ),
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       color: widget.selectedPage == index
//                           ? Colors.red // Selected item is red
//                           : (focusNode.hasFocus ? randomColor : hintColor),
//                       fontSize: menutextsz,
//                       fontWeight: focusNode.hasFocus
//                           ? FontWeight.bold
//                           : FontWeight.normal,
//                     ),
//                   ),
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../widgets/small_widgets/app_assets.dart';
import '../widgets/utils/random_light_color_widget.dart';

class MiddleNavigationBar extends StatefulWidget {
  final int selectedPage;
  final ValueChanged<int> onPageSelected;
  final FocusNode focusNode;
  final int? maxPageIndex;
  final int? totalNavItems;

  const MiddleNavigationBar({
    Key? key,
    required this.selectedPage,
    required this.onPageSelected,
    required this.focusNode,
    this.maxPageIndex,
    this.totalNavItems,
  }) : super(key: key);

  @override
  _MiddleNavigationBarState createState() => _MiddleNavigationBarState();
}

class _MiddleNavigationBarState extends State<MiddleNavigationBar> {
  late List<FocusNode> _focusNodes;

  static const List<String> navItems = [
    'Live',
    'Entertainment',
    'Music',
    'Movie',
    'News',
    'Sports',
    'Religious',
    'More'
  ];

  @override
  void initState() {
    super.initState();

    print('🔧 MiddleNavigationBar SINGLE SOURCE: $navItems');
    print('🔧 Total nav items: ${navItems.length}');
    print('🔧 Max page index: ${widget.maxPageIndex}');
    print('🔧 Total provided nav items: ${widget.totalNavItems}');

    _focusNodes = List.generate(navItems.length, (index) => FocusNode());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        try {
          final focusProvider = context.read<FocusProvider>();
          focusProvider.setMiddleNavigationFocusNodes(_focusNodes);

          print('✅ Middle navigation focus nodes registered: ${_focusNodes.length}');
        } catch (e) {
          print('❌ Focus provider registration error: $e');
        }
      }
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
        random.nextInt(256), random.nextInt(256), random.nextInt(256), 1);
  }

  // ✅ NEW: Method to scroll to middle navigation bar
  void _scrollToMiddleNavigation() {
    try {
      final focusProvider = context.read<FocusProvider>();
      final scrollController = focusProvider.scrollController;
      
      if (scrollController.hasClients) {
        // Calculate the position of middle navigation bar
        // Assuming it's after the banner slider (screenhgt * 0.5)
        final targetPosition = screenhgt * 0.5 - 10; // Adjust offset as needed
        
        scrollController.animateTo(
          targetPosition,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        
        print('📜 Scrolled to middle navigation bar');
      }
    } catch (e) {
      print('❌ Scroll to navigation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 MiddleNavigationBar building: ${navItems.length} items');
    print('🎯 Selected: ${widget.selectedPage} = ${widget.selectedPage < navItems.length ? navItems[widget.selectedPage] : "Invalid"}');
    print('🎯 Valid page range: 0-${widget.maxPageIndex ?? "unknown"}');

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            try {
              context.read<FocusProvider>().requestWatchNowFocus();
            } catch (e) {
              print('Back navigation error: $e');
            }
          }
        },
        child: Consumer<ColorProvider>(builder: (context, colorProvider, child) {
          Color backgroundColor = colorProvider.isItemFocused
              ? colorProvider.dominantColor.withOpacity(0.5)
              : cardColor;

          return Container(
            color: backgroundColor,
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: screenhgt * 0.01, horizontal: screenwdt * 0.04),
              color: cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(navItems.length, (i) {
                  print('🔨 Building: $i = ${navItems[i]}');
                  return _buildNavigationItem(navItems[i], i, _focusNodes[i]);
                }),
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
                print('🎯 Focused: $title (index: $index)');

                // ✅ NEW: Auto-scroll to middle navigation when any button gets focus
                _scrollToMiddleNavigation();

                // try {
                //   final focusProvider = context.read<FocusProvider>();
                //   switch (index) {
                //     case 0: // Live
                //       if (focusProvider.setLiveTvFocusNode != null) {
                //         focusProvider.setLiveTvFocusNode!(focusNode);
                //       }
                //       break;
                //     case 1: // Entertainment
                //       if (focusProvider.setVodMenuFocusNode != null) {
                //         focusProvider.setVodMenuFocusNode!(focusNode);
                //       }
                //       break;
                //   }
                // } catch (e) {
                //   print('Focus provider method error: $e');
                // }

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
                print('⬇️ Arrow down: $title (index: $index)');
                if (index >= 0 && index < navItems.length) {
                  widget.onPageSelected(index);
                } else {
                  print('❌ Invalid index for navigation: $index');
                }
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.select) {
                print('✅ Enter: $title (index: $index)');
                widget.onPageSelected(index);
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                int nextIndex = (index + 1) % _focusNodes.length;
                print('➡️ Next: ${navItems[nextIndex]} (index: $nextIndex)');
                _focusNodes[nextIndex].requestFocus();
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                int prevIndex = (index - 1 + _focusNodes.length) % _focusNodes.length;
                print('⬅️ Prev: ${navItems[prevIndex]} (index: $prevIndex)');
                _focusNodes[prevIndex].requestFocus();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            onTap: () {
              print('🖱️ Tapped: $title (index: $index)');
              if (index >= 0 && index < navItems.length) {
                widget.onPageSelected(index);
                focusNode.requestFocus();
              } else {
                print('❌ Invalid index for tap: $index');
              }
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
                      color: focusNode.hasFocus ? randomColor : Colors.transparent,
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
                    horizontal: screenwdt * 0.005,
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: widget.selectedPage == index
                          ? Colors.red
                          : (focusNode.hasFocus ? randomColor : hintColor),
                      fontSize: menutextsz,
                      fontWeight: focusNode.hasFocus
                          ? FontWeight.bold
                          : FontWeight.normal,
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