// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:provider/provider.dart';

// // Custom intent for up arrow activation
// class UpActivateIntent extends ActivateIntent {
//   const UpActivateIntent();
// }

// class FocussableWebseriesWidget extends StatefulWidget {

//   final String imageUrl;
//   final String name;
//   final VoidCallback onTap;
//   final Future<Color> Function(String imageUrl) fetchPaletteColor;
//   final FocusNode? focusNode;
//   final Function(bool)? onFocusChange;
//   final double? width;
//   final double? height;
//   final double? focusedHeight;
//   final VoidCallback? onUpPress;

//   const FocussableWebseriesWidget({
//     required this.imageUrl,
//     required this.name,
//     required this.onTap,
//     required this.fetchPaletteColor,
//     this.focusNode,
//     this.onFocusChange,
//     this.width,
//     this.height,
//     this.focusedHeight,
//     this.onUpPress,
//   });

//   @override
//   _FocussableWebseriesWidgetState createState() => _FocussableWebseriesWidgetState();
// }

// class _FocussableWebseriesWidgetState extends State<FocussableWebseriesWidget> {
//   bool isFocused = false;
//   Color paletteColor = Colors.pink;
//   late FocusNode _focusNode;

//   @override
//   void initState() {
//     super.initState();
//     _focusNode = widget.focusNode ?? FocusNode();
//     _focusNode.addListener(_handleFocusChange);
//     _updatePaletteColor();
//   }

//   @override
//   void dispose() {
//     _focusNode.removeListener(_handleFocusChange);
//     if (widget.focusNode == null) {
//       _focusNode.dispose();
//     }
//     super.dispose();
//   }

//   void _handleFocusChange() {
//     final hasFocus = _focusNode.hasFocus;
//     setState(() {
//       isFocused = hasFocus;
//     });
//     widget.onFocusChange?.call(hasFocus);

//     if (hasFocus) {
//       context.read<ColorProvider>().updateColor(paletteColor, true);
//     } else {
//       context.read<ColorProvider>().resetColor();
//     }
//   }

//   Future<void> _updatePaletteColor() async {
//     try {
//       final color = await widget.fetchPaletteColor(widget.imageUrl);
//       if (mounted) {
//         setState(() {
//           paletteColor = color;
//         });
//       }
//     } catch (_) {
//       if (mounted) {
//         setState(() {
//           paletteColor = Colors.grey;
//         });
//       }
//     }
//   }

//   // Removed customDisplayImage function as we're using the provided displayImage function

//   @override
//   Widget build(BuildContext context) {
//     final double containerWidth = widget.width ?? screenwdt * 0.19;
//     final double normalHeight = widget.height ?? screenhgt * 0.20;
//     final double focusedHeight = widget.focusedHeight ?? screenhgt * 0.25;

//     // Calculate the growth in height when focused (difference between focused and normal height)
//     final double heightGrowth = focusedHeight - normalHeight;

//     // Calculate the vertical position shift when focused (to center the expanded item)
//     final double verticalOffset = isFocused ? -(heightGrowth / 2) : 0;

//     return FocusableActionDetector(
//       focusNode: _focusNode,
//       onFocusChange: (hasFocus) {
//         if (hasFocus) {
//           context.read<ColorProvider>().updateColor(paletteColor, true);
//         }
//       },

//       actions: {
//         // ActivateIntent: CallbackAction<ActivateIntent>(
//         //   onInvoke: (ActivateIntent intent) {
//         //     widget.onTap();
//         //     return null;
//         //   },
//         // ),
//       // Separate action for up navigation
//       if (widget.onUpPress != null)
//         ActivateIntent: CallbackAction<ActivateIntent>(
//           onInvoke: (ActivateIntent intent) {
//             // Only call onUpPress if this is from an up arrow key
//             if (intent is UpActivateIntent) {
//               widget.onUpPress!();
//               return null;
//             }
//             // Otherwise handle normal tap/enter
//             widget.onTap();
//             return null;
//           },
//         ),
//     },
//     shortcuts: {
//       // Handle Enter/Select keys separately
//       LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
//       LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
//       // Add explicit up arrow handling if needed
//       if (widget.onUpPress != null)
//         LogicalKeySet(LogicalKeyboardKey.arrowUp): UpActivateIntent(),

//       },

//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Using Stack for true bidirectional expansion
//             Container(
//               width: containerWidth,
//               height: normalHeight, // Fixed container height is the normal height
//               child: Stack(
//                 clipBehavior: Clip.none, // Allow items to overflow the stack
//                 alignment: Alignment.center,
//                 children: [
//                   // Animated container for the image
//                   AnimatedPositioned(
//                     duration: const Duration(milliseconds: 400),
//                     top: isFocused ? -(heightGrowth / 2) : 0, // Move up when focused
//                     left: 0,
//                     width: containerWidth,
//                     height: isFocused ? focusedHeight : normalHeight,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: isFocused ? paletteColor : Colors.transparent,
//                           width: 4.0,
//                         ),
//                         boxShadow: isFocused
//                             ? [
//                                 BoxShadow(
//                                   color: paletteColor,
//                                   blurRadius: 25,
//                                   spreadRadius: 10,
//                                 ),
//                               ]
//                             : [],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(4.0),
//                         child: displayImage(
//                           widget.imageUrl,
//                           width: containerWidth,
//                           height: isFocused ? focusedHeight : normalHeight,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 10),
//             Container(
//               width: containerWidth,
//               child: Text(
//                 widget.name.toUpperCase(),
//                 style: TextStyle(
//                   color: isFocused ? paletteColor : Colors.grey,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 1,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:provider/provider.dart';

// Custom intent for up arrow activation
class UpActivateIntent extends ActivateIntent {
  const UpActivateIntent();
}

class FocussableWebseriesWidget extends StatefulWidget {
  final String imageUrl;
  final String name;
  final VoidCallback onTap;
  final Future<Color> Function(String imageUrl) fetchPaletteColor;
  final FocusNode? focusNode;
  final Function(bool)? onFocusChange;
  final double? width;
  final double? height;
  final double? focusedHeight;
  final VoidCallback? onUpPress;

  const FocussableWebseriesWidget({
    required this.imageUrl,
    required this.name,
    required this.onTap,
    required this.fetchPaletteColor,
    this.focusNode,
    this.onFocusChange,
    this.width,
    this.height,
    this.focusedHeight,
    this.onUpPress,
    required ValueKey<String> key,
  });

  @override
  _FocussableWebseriesWidgetState createState() =>
      _FocussableWebseriesWidgetState();
}

class _FocussableWebseriesWidgetState extends State<FocussableWebseriesWidget> {
  bool isFocused = false;
  Color paletteColor = Colors.pink;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _updatePaletteColor();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    final hasFocus = _focusNode.hasFocus;
    setState(() {
      isFocused = hasFocus;
    });
    widget.onFocusChange?.call(hasFocus);

    if (hasFocus) {
      context.read<ColorProvider>().updateColor(paletteColor, true);
    } else {
      context.read<ColorProvider>().resetColor();
    }
  }

  Future<void> _updatePaletteColor() async {
    try {
      final color = await widget.fetchPaletteColor(widget.imageUrl);
      if (mounted) {
        setState(() {
          paletteColor = color;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          paletteColor = Colors.grey;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double containerWidth = widget.width ?? screenwdt * 0.19;
    final double normalHeight = widget.height ?? screenhgt * 0.20;
    final double focusedHeight = widget.focusedHeight ?? screenhgt * 0.25;

    // Calculate the growth in height when focused (difference between focused and normal height)
    final double heightGrowth = focusedHeight - normalHeight;

    // Calculate the vertical position shift when focused (to center the expanded item)
    final double verticalOffset = isFocused ? -(heightGrowth / 2) : 0;

    return FocusableActionDetector(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          context.read<ColorProvider>().updateColor(paletteColor, true);
        }
      },
      actions: {
        // ✅ Fixed: Direct ActivateIntent handling for Enter/Select keys
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            widget.onTap(); // Direct call to onTap
            return null;
          },
        ),
        // ✅ Separate action for up navigation
        if (widget.onUpPress != null)
          UpActivateIntent: CallbackAction<UpActivateIntent>(
            onInvoke: (UpActivateIntent intent) {
              widget.onUpPress!();
              return null;
            },
          ),
      },
      shortcuts: {
        // ✅ Fixed: Enter/Select keys trigger ActivateIntent
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
        // ✅ Up arrow triggers separate UpActivateIntent
        if (widget.onUpPress != null)
          LogicalKeySet(LogicalKeyboardKey.arrowUp): UpActivateIntent(),
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Using Stack for true bidirectional expansion
            Container(
              width: containerWidth,
              height:
                  normalHeight, // Fixed container height is the normal height
              child: Stack(
                clipBehavior: Clip.none, // Allow items to overflow the stack
                alignment: Alignment.center,
                children: [
                  // Animated container for the image
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    top: isFocused
                        ? -(heightGrowth / 2)
                        : 0, // Move up when focused
                    left: 0,
                    width: containerWidth,
                    height: isFocused ? focusedHeight : normalHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isFocused ? paletteColor : Colors.transparent,
                          width: 4.0,
                        ),
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: paletteColor,
                                  blurRadius: 25,
                                  spreadRadius: 10,
                                ),
                              ]
                            : [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: displayImage(
                          widget.imageUrl,
                          width: containerWidth,
                          height: isFocused ? focusedHeight : normalHeight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: containerWidth,
              child: Text(
                widget.name.toUpperCase(),
                style: TextStyle(
                  color: isFocused ? paletteColor : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
