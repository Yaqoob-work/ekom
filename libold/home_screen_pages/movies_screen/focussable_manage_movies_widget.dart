// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:mobi_tv_entertainment/main.dart';
// // // // // import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
// // // // // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // // // // import 'package:provider/provider.dart';

// // // // // class FocussableManageMoviesWidget extends StatefulWidget {
// // // // //   final String imageUrl;
// // // // //   final String name;
// // // // //   final VoidCallback onTap;
// // // // //   final Future<Color> Function(String imageUrl) fetchPaletteColor;
// // // // //   final FocusNode? focusNode;
// // // // //   final Function(bool)? onFocusChange;
// // // // //   final double? width;
// // // // //   final double? height;
// // // // //   final double? focusedHeight;

// // // // //   const FocussableManageMoviesWidget({
// // // // //     required this.imageUrl,
// // // // //     required this.name,
// // // // //     required this.onTap,
// // // // //     required this.fetchPaletteColor,
// // // // //     this.focusNode,
// // // // //     this.onFocusChange,
// // // // //     this.width,
// // // // //     this.height,
// // // // //     this.focusedHeight,
// // // // //   });

// // // // //   @override
// // // // //   _FocussableManageMoviesWidgetState createState() => _FocussableManageMoviesWidgetState();
// // // // // }

// // // // // class _FocussableManageMoviesWidgetState extends State<FocussableManageMoviesWidget> {
// // // // //   bool isFocused = false;
// // // // //   Color paletteColor = Colors.pink;
// // // // //   late FocusNode _focusNode;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _focusNode = widget.focusNode ?? FocusNode();
// // // // //     _focusNode.addListener(_handleFocusChange);
// // // // //     _updatePaletteColor();
// // // // //   }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     _focusNode.removeListener(_handleFocusChange);
// // // // //     if (widget.focusNode == null) {
// // // // //       _focusNode.dispose();
// // // // //     }
// // // // //     super.dispose();
// // // // //   }

// // // // //   void _handleFocusChange() {
// // // // //     final hasFocus = _focusNode.hasFocus;
// // // // //     setState(() {
// // // // //       isFocused = hasFocus;
// // // // //     });
// // // // //     widget.onFocusChange?.call(hasFocus);

// // // // //     if (hasFocus) {
// // // // //       context.read<ColorProvider>().updateColor(paletteColor, true);
// // // // //     } else {
// // // // //       context.read<ColorProvider>().resetColor();
// // // // //     }
// // // // //   }

// // // // //   Future<void> _updatePaletteColor() async {
// // // // //     try {
// // // // //       final color = await widget.fetchPaletteColor(widget.imageUrl);
// // // // //       if (mounted) {
// // // // //         setState(() {
// // // // //           paletteColor = color;
// // // // //         });
// // // // //       }
// // // // //     } catch (_) {
// // // // //       if (mounted) {
// // // // //         setState(() {
// // // // //           paletteColor = Colors.grey;
// // // // //         });
// // // // //       }
// // // // //     }
// // // // //   }

// // // // //   // Removed customDisplayImage function as we're using the provided displayImage function

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     final double containerWidth = widget.width ?? screenwdt * 0.19;
// // // // //     final double normalHeight = widget.height ?? screenhgt * 0.21;
// // // // //     final double focusedHeight = widget.focusedHeight ?? screenhgt * 0.24;

// // // // //     // Calculate the growth in height when focused (difference between focused and normal height)
// // // // //     final double heightGrowth = focusedHeight - normalHeight;

// // // // //     // Calculate the vertical position shift when focused (to center the expanded item)
// // // // //     final double verticalOffset = isFocused ? -(heightGrowth / 2) : 0;

// // // // //     return FocusableActionDetector(
// // // // //       focusNode: _focusNode,
// // // // //       onFocusChange: (hasFocus) {
// // // // //         if (hasFocus) {
// // // // //           context.read<ColorProvider>().updateColor(paletteColor, true);
// // // // //         }
// // // // //       },
// // // // //       actions: {
// // // // //         ActivateIntent: CallbackAction<ActivateIntent>(
// // // // //           onInvoke: (ActivateIntent intent) {
// // // // //             widget.onTap();
// // // // //             return null;
// // // // //           },
// // // // //         ),
// // // // //       },

// // // // //       child: GestureDetector(
// // // // //         onTap: widget.onTap,
// // // // //         child: Column(
// // // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // // //           crossAxisAlignment: CrossAxisAlignment.center,
// // // // //           children: [
// // // // //             // Using Stack for true bidirectional expansion
// // // // //             Container(
// // // // //               width: containerWidth,
// // // // //               height: normalHeight, // Fixed container height is the normal height
// // // // //               child: Stack(
// // // // //                 clipBehavior: Clip.none, // Allow items to overflow the stack
// // // // //                 alignment: Alignment.center,
// // // // //                 children: [
// // // // //                   // Animated container for the image
// // // // //                   AnimatedPositioned(
// // // // //                     duration: const Duration(milliseconds: 400),
// // // // //                     top: isFocused ? -(heightGrowth / 2) : 0, // Move up when focused
// // // // //                     left: 0,
// // // // //                     width: containerWidth,
// // // // //                     height: isFocused ? focusedHeight : normalHeight,
// // // // //                     child: Container(
// // // // //                       decoration: BoxDecoration(
// // // // //                         border: Border.all(
// // // // //                           color: isFocused ? paletteColor : Colors.transparent,
// // // // //                           width: 4.0,
// // // // //                         ),
// // // // //                         boxShadow: isFocused
// // // // //                             ? [
// // // // //                                 BoxShadow(
// // // // //                                   color: paletteColor,
// // // // //                                   blurRadius: 25,
// // // // //                                   spreadRadius: 10,
// // // // //                                 ),
// // // // //                               ]
// // // // //                             : [],
// // // // //                       ),
// // // // //                       child: ClipRRect(
// // // // //                         borderRadius: BorderRadius.circular(4.0),
// // // // //                         child: displayImage(
// // // // //                           widget.imageUrl,
// // // // //                           width: containerWidth,
// // // // //                           height: isFocused ? focusedHeight : normalHeight,
// // // // //                         ),
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //                 ],
// // // // //               ),
// // // // //             ),
// // // // //             SizedBox(height: 10),
// // // // //             Container(
// // // // //               width: containerWidth,
// // // // //               child: Text(
// // // // //                 widget.name.toUpperCase(),
// // // // //                 style: TextStyle(
// // // // //                   color: isFocused ? paletteColor : Colors.grey,
// // // // //                   fontWeight: FontWeight.bold,
// // // // //                 ),
// // // // //                 textAlign: TextAlign.center,
// // // // //                 overflow: TextOverflow.ellipsis,
// // // // //                 maxLines: 1,
// // // // //               ),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:mobi_tv_entertainment/main.dart';
// // // // import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
// // // // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // // // import 'package:provider/provider.dart';

// // // // class FocusableMoviesWidget extends StatefulWidget {
// // // //   final String imageUrl;
// // // //   final String name;
// // // //   final VoidCallback onTap;
// // // //   final Future<Color> Function(String imageUrl) fetchPaletteColor;
// // // //   final FocusNode? focusNode;
// // // //   final Function(bool)? onFocusChange;
// // // //   final double? width;
// // // //   final double? height;
// // // //   final double? focusedHeight;
// // // //   final VoidCallback? onUpPress;

// // // //   const FocusableMoviesWidget({
// // // //     required this.imageUrl,
// // // //     required this.name,
// // // //     required this.onTap,
// // // //     required this.fetchPaletteColor,
// // // //     this.focusNode,
// // // //     this.onFocusChange,
// // // //     this.width,
// // // //     this.height,
// // // //     this.focusedHeight,
// // // //     this.onUpPress,
// // // //   });

// // // //   @override
// // // //   _FocusableMoviesWidgetState createState() => _FocusableMoviesWidgetState();
// // // // }

// // // // class _FocusableMoviesWidgetState extends State<FocusableMoviesWidget> {
// // // //   bool isFocused = false;
// // // //   Color paletteColor = Colors.pink;
// // // //   late FocusNode _focusNode;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _focusNode = widget.focusNode ?? FocusNode();
// // // //     _focusNode.addListener(_handleFocusChange);
// // // //     _updatePaletteColor();
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _focusNode.removeListener(_handleFocusChange);
// // // //     if (widget.focusNode == null) {
// // // //       _focusNode.dispose();
// // // //     }
// // // //     super.dispose();
// // // //   }

// // // //   void _handleFocusChange() {
// // // //     final hasFocus = _focusNode.hasFocus;
// // // //     setState(() {
// // // //       isFocused = hasFocus;
// // // //     });
// // // //     widget.onFocusChange?.call(hasFocus);

// // // //     if (hasFocus) {
// // // //       context.read<ColorProvider>().updateColor(paletteColor, true);
// // // //     } else {
// // // //       context.read<ColorProvider>().resetColor();
// // // //     }
// // // //   }

// // // //   Future<void> _updatePaletteColor() async {
// // // //     try {
// // // //       final color = await widget.fetchPaletteColor(widget.imageUrl);
// // // //       if (mounted) {
// // // //         setState(() {
// // // //           paletteColor = color;
// // // //         });
// // // //       }
// // // //     } catch (_) {
// // // //       if (mounted) {
// // // //         setState(() {
// // // //           paletteColor = Colors.grey;
// // // //         });
// // // //       }
// // // //     }
// // // //   }

// // // //   // Removed customDisplayImage function as we're using the provided displayImage function

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final double containerWidth = widget.width ?? screenwdt * 0.19;
// // // //     final double normalHeight = widget.height ?? screenhgt * 0.21;
// // // //     final double focusedHeight = widget.focusedHeight ?? screenhgt * 0.24;

// // // //     // Calculate the growth in height when focused (difference between focused and normal height)
// // // //     final double heightGrowth = focusedHeight - normalHeight;

// // // //     // Calculate the vertical position shift when focused (to center the expanded item)
// // // //     final double verticalOffset = isFocused ? -(heightGrowth / 2) : 0;

// // // //     return FocusableActionDetector(
// // // //       focusNode: _focusNode,
// // // //       onFocusChange: (hasFocus) {
// // // //         if (hasFocus) {
// // // //           context.read<ColorProvider>().updateColor(paletteColor, true);
// // // //         }
// // // //       },

// // // //       actions: {
// // // //         // ActivateIntent: CallbackAction<ActivateIntent>(
// // // //         //   onInvoke: (ActivateIntent intent) {
// // // //         //     widget.onTap();
// // // //         //     return null;
// // // //         //   },
// // // //         // ),
// // // //         ActivateIntent: CallbackAction<ActivateIntent>(
// // // //           onInvoke: (ActivateIntent intent) {
// // // //             // Handle both cases - up press and normal tap
// // // //             if (widget.onUpPress != null && _focusNode.hasFocus) {
// // // //               widget.onUpPress!();
// // // //             } else {
// // // //               widget.onTap();
// // // //             }
// // // //             return null;
// // // //           },
// // // //         ),
// // // //       },

// // // //       shortcuts: {
// // // //         // Add this to handle both Enter and Select keys
// // // //         LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
// // // //         LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
// // // //       },

// // // //       child: GestureDetector(
// // // //         onTap: widget.onTap,
// // // //         child: Column(
// // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // //           crossAxisAlignment: CrossAxisAlignment.center,
// // // //           children: [
// // // //             // Using Stack for true bidirectional expansion
// // // //             Container(
// // // //               width: containerWidth,
// // // //               height: normalHeight, // Fixed container height is the normal height
// // // //               child: Stack(
// // // //                 clipBehavior: Clip.none, // Allow items to overflow the stack
// // // //                 alignment: Alignment.center,
// // // //                 children: [
// // // //                   // Animated container for the image
// // // //                   AnimatedPositioned(
// // // //                     duration: const Duration(milliseconds: 400),
// // // //                     top: isFocused ? -(heightGrowth / 2) : 0, // Move up when focused
// // // //                     left: 0,
// // // //                     width: containerWidth,
// // // //                     height: isFocused ? focusedHeight : normalHeight,
// // // //                     child: Container(
// // // //                       decoration: BoxDecoration(
// // // //                         border: Border.all(
// // // //                           color: isFocused ? paletteColor : Colors.transparent,
// // // //                           width: 4.0,
// // // //                         ),
// // // //                         boxShadow: isFocused
// // // //                             ? [
// // // //                                 BoxShadow(
// // // //                                   color: paletteColor,
// // // //                                   blurRadius: 25,
// // // //                                   spreadRadius: 10,
// // // //                                 ),
// // // //                               ]
// // // //                             : [],
// // // //                       ),
// // // //                       child: ClipRRect(
// // // //                         borderRadius: BorderRadius.circular(4.0),
// // // //                         child: displayImage(
// // // //                           widget.imageUrl,
// // // //                           width: containerWidth,
// // // //                           height: isFocused ? focusedHeight : normalHeight,
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //             SizedBox(height: 10),
// // // //             Container(
// // // //               width: containerWidth,
// // // //               child: Text(
// // // //                 widget.name.toUpperCase(),
// // // //                 style: TextStyle(
// // // //                   color: isFocused ? paletteColor : Colors.grey,
// // // //                   fontWeight: FontWeight.bold,
// // // //                 ),
// // // //                 textAlign: TextAlign.center,
// // // //                 overflow: TextOverflow.ellipsis,
// // // //                 maxLines: 1,
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:mobi_tv_entertainment/main.dart';
// // // // import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
// // // // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // // // import 'package:provider/provider.dart';
// // // // import 'package:cached_network_image/cached_network_image.dart';
// // // // import 'dart:convert';

// // // // class FocusableMoviesWidget extends StatefulWidget {
// // // //   final String imageUrl;
// // // //   final String name;
// // // //   final VoidCallback onTap;
// // // //   final Future<Color> Function(String imageUrl) fetchPaletteColor;
// // // //   final FocusNode? focusNode;
// // // //   final Function(bool)? onFocusChange;
// // // //   final double? width;
// // // //   final double? height;
// // // //   final double? focusedHeight;
// // // //   final VoidCallback? onUpPress;

// // // //   const FocusableMoviesWidget({
// // // //     required this.imageUrl,
// // // //     required this.name,
// // // //     required this.onTap,
// // // //     required this.fetchPaletteColor,
// // // //     this.focusNode,
// // // //     this.onFocusChange,
// // // //     this.width,
// // // //     this.height,
// // // //     this.focusedHeight,
// // // //     this.onUpPress,
// // // //   });

// // // //   @override
// // // //   _FocusableMoviesWidgetState createState() => _FocusableMoviesWidgetState();
// // // // }

// // // // class _FocusableMoviesWidgetState extends State<FocusableMoviesWidget> {
// // // //   bool isFocused = false;
// // // //   Color paletteColor = Colors.pink;
// // // //   late FocusNode _focusNode;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _focusNode = widget.focusNode ?? FocusNode();
// // // //     _focusNode.addListener(_handleFocusChange);
// // // //     _updatePaletteColor();
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _focusNode.removeListener(_handleFocusChange);
// // // //     if (widget.focusNode == null) {
// // // //       _focusNode.dispose();
// // // //     }
// // // //     super.dispose();
// // // //   }

// // // //   void _handleFocusChange() {
// // // //     final hasFocus = _focusNode.hasFocus;
// // // //     setState(() {
// // // //       isFocused = hasFocus;
// // // //     });
// // // //     widget.onFocusChange?.call(hasFocus);

// // // //     if (hasFocus) {
// // // //       context.read<ColorProvider>().updateColor(paletteColor, true);
// // // //     } else {
// // // //       context.read<ColorProvider>().resetColor();
// // // //     }
// // // //   }

// // // //   Future<void> _updatePaletteColor() async {
// // // //     try {
// // // //       final color = await widget.fetchPaletteColor(widget.imageUrl);
// // // //       if (mounted) {
// // // //         setState(() {
// // // //           paletteColor = color;
// // // //         });
// // // //       }
// // // //     } catch (_) {
// // // //       if (mounted) {
// // // //         setState(() {
// // // //           paletteColor = Colors.grey;
// // // //         });
// // // //       }
// // // //     }
// // // //   }

// // // //   // Custom image display function that handles both network and data images
// // // //   Widget _buildImageWidget(String imageUrl, {required double width, required double height}) {
// // // //     if (imageUrl.startsWith('data:image/')) {
// // // //       // Handle data:image format
// // // //       try {
// // // //         final String base64String = imageUrl.split(',')[1];
// // // //         final Uint8List bytes = base64Decode(base64String);

// // // //         return Image.memory(
// // // //           bytes,
// // // //           width: width,
// // // //           height: height,
// // // //           fit: BoxFit.cover,
// // // //           errorBuilder: (context, error, stackTrace) {
// // // //             return Container(
// // // //               width: width,
// // // //               height: height,
// // // //               color: Colors.grey[800],
// // // //               child: Icon(
// // // //                 Icons.error,
// // // //                 color: Colors.white,
// // // //                 size: 30,
// // // //               ),
// // // //             );
// // // //           },
// // // //         );
// // // //       } catch (e) {
// // // //         // If base64 decoding fails, show error container
// // // //         return Container(
// // // //           width: width,
// // // //           height: height,
// // // //           color: Colors.grey[800],
// // // //           child: Icon(
// // // //             Icons.error,
// // // //             color: Colors.white,
// // // //             size: 30,
// // // //           ),
// // // //         );
// // // //       }
// // // //     } else {
// // // //       // Handle network images
// // // //       return CachedNetworkImage(
// // // //         imageUrl: imageUrl,
// // // //         width: width,
// // // //         height: height,
// // // //         fit: BoxFit.cover,
// // // //         placeholder: (context, url) => Container(
// // // //           width: width,
// // // //           height: height,
// // // //           color: Colors.grey[800],
// // // //           child: Center(
// // // //             child: CircularProgressIndicator(
// // // //               strokeWidth: 2,
// // // //               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// // // //             ),
// // // //           ),
// // // //         ),
// // // //         errorWidget: (context, url, error) => Container(
// // // //           width: width,
// // // //           height: height,
// // // //           color: Colors.grey[800],
// // // //           child: Icon(
// // // //             Icons.error,
// // // //             color: Colors.white,
// // // //             size: 30,
// // // //           ),
// // // //         ),
// // // //       );
// // // //     }
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final double containerWidth = widget.width ?? screenwdt * 0.19;
// // // //     final double normalHeight = widget.height ?? screenhgt * 0.20;
// // // //     final double focusedHeight = widget.focusedHeight ?? screenhgt * 0.25;

// // // //     // Calculate the growth in height when focused (difference between focused and normal height)
// // // //     final double heightGrowth = focusedHeight - normalHeight;

// // // //     // Calculate the vertical position shift when focused (to center the expanded item)
// // // //     final double verticalOffset = isFocused ? -(heightGrowth / 2) : 0;

// // // //     return FocusableActionDetector(
// // // //       focusNode: _focusNode,
// // // //       onFocusChange: (hasFocus) {
// // // //         if (hasFocus) {
// // // //           context.read<ColorProvider>().updateColor(paletteColor, true);
// // // //         }
// // // //       },

// // // //       actions: {
// // // //         ActivateIntent: CallbackAction<ActivateIntent>(
// // // //           onInvoke: (ActivateIntent intent) {
// // // //             // Handle both cases - up press and normal tap
// // // //             if (widget.onUpPress != null && _focusNode.hasFocus) {
// // // //               widget.onUpPress!();
// // // //             } else {
// // // //               widget.onTap();
// // // //             }
// // // //             return null;
// // // //           },
// // // //         ),
// // // //       },

// // // //       shortcuts: {
// // // //         // Add this to handle both Enter and Select keys
// // // //         LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
// // // //         LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
// // // //       },

// // // //       child: GestureDetector(
// // // //         onTap: widget.onTap,
// // // //         child: Column(
// // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // //           crossAxisAlignment: CrossAxisAlignment.center,
// // // //           children: [
// // // //             // Using Stack for true bidirectional expansion
// // // //             Container(
// // // //               width: containerWidth,
// // // //               height: normalHeight, // Fixed container height is the normal height
// // // //               child: Stack(
// // // //                 clipBehavior: Clip.none, // Allow items to overflow the stack
// // // //                 alignment: Alignment.center,
// // // //                 children: [
// // // //                   // Animated container for the image
// // // //                   AnimatedPositioned(
// // // //                     duration: const Duration(milliseconds: 400),
// // // //                     top: isFocused ? -(heightGrowth / 2) : 0, // Move up when focused
// // // //                     left: 0,
// // // //                     width: containerWidth,
// // // //                     height: isFocused ? focusedHeight : normalHeight,
// // // //                     child: Container(
// // // //                       decoration: BoxDecoration(
// // // //                         border: Border.all(
// // // //                           color: isFocused ? paletteColor : Colors.transparent,
// // // //                           width: 4.0,
// // // //                         ),
// // // //                         boxShadow: isFocused
// // // //                             ? [
// // // //                                 BoxShadow(
// // // //                                   color: paletteColor,
// // // //                                   blurRadius: 25,
// // // //                                   spreadRadius: 10,
// // // //                                 ),
// // // //                               ]
// // // //                             : [],
// // // //                       ),
// // // //                       child: ClipRRect(
// // // //                         borderRadius: BorderRadius.circular(4.0),
// // // //                         child: _buildImageWidget(
// // // //                           widget.imageUrl,
// // // //                           width: containerWidth,
// // // //                           height: isFocused ? focusedHeight : normalHeight,
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //             SizedBox(height: 10),
// // // //             Container(
// // // //               width: containerWidth,
// // // //               child: Text(
// // // //                 widget.name.toUpperCase(),
// // // //                 style: TextStyle(
// // // //                   color: isFocused ? paletteColor : Colors.grey,
// // // //                   fontWeight: FontWeight.bold,
// // // //                 ),
// // // //                 textAlign: TextAlign.center,
// // // //                 overflow: TextOverflow.ellipsis,
// // // //                 maxLines: 1,
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }






// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:mobi_tv_entertainment/main.dart';
// // // import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
// // // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:cached_network_image/cached_network_image.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// // // import 'dart:convert';

// // // class FocusableMoviesWidget extends StatefulWidget {
// // //   final String imageUrl;
// // //   final String name;
// // //   final VoidCallback onTap;
// // //   final Future<Color> Function(String imageUrl) fetchPaletteColor;
// // //   final FocusNode? focusNode;
// // //   final Function(bool)? onFocusChange;
// // //   final double? width;
// // //   final double? height;
// // //   final double? focusedHeight;
// // //   final VoidCallback? onUpPress;

// // //   // Add these new parameters for fresh data fetch
// // //   final dynamic movieData; // The current movie data
// // //   final String? source; // 'isMovieScreen' or other source

// // //   const FocusableMoviesWidget({
// // //     required this.imageUrl,
// // //     required this.name,
// // //     required this.onTap,
// // //     required this.fetchPaletteColor,
// // //     this.focusNode,
// // //     this.onFocusChange,
// // //     this.width,
// // //     this.height,
// // //     this.focusedHeight,
// // //     this.onUpPress,
// // //     this.movieData,
// // //     this.source,
// // //   });

// // //   @override
// // //   _FocusableMoviesWidgetState createState() => _FocusableMoviesWidgetState();
// // // }

// // // class _FocusableMoviesWidgetState extends State<FocusableMoviesWidget> {
// // //   bool isFocused = false;
// // //   Color paletteColor = Colors.pink;
// // //   late FocusNode _focusNode;
// // //   bool _isNavigating = false;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _focusNode = widget.focusNode ?? FocusNode();
// // //     _focusNode.addListener(_handleFocusChange);
// // //     _updatePaletteColor();
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _focusNode.removeListener(_handleFocusChange);
// // //     if (widget.focusNode == null) {
// // //       _focusNode.dispose();
// // //     }
// // //     super.dispose();
// // //   }

// // //   void _handleFocusChange() {
// // //     final hasFocus = _focusNode.hasFocus;
// // //     setState(() {
// // //       isFocused = hasFocus;
// // //     });
// // //     widget.onFocusChange?.call(hasFocus);

// // //     if (hasFocus) {
// // //       context.read<ColorProvider>().updateColor(paletteColor, true);
// // //     } else {
// // //       context.read<ColorProvider>().resetColor();
// // //     }
// // //   }

// // //   Future<void> _updatePaletteColor() async {
// // //     try {
// // //       final color = await widget.fetchPaletteColor(widget.imageUrl);
// // //       if (mounted) {
// // //         setState(() {
// // //           paletteColor = color;
// // //         });
// // //       }
// // //     } catch (_) {
// // //       if (mounted) {
// // //         setState(() {
// // //           paletteColor = Colors.grey;
// // //         });
// // //       }
// // //     }
// // //   }

// // //   // Method to fetch fresh movies data
// // //   Future<List<NewsItemModel>> _fetchFreshMoviesData() async {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       String authKey = AuthManager.authKey;
// // //       if (authKey.isEmpty) {
// // //         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
// // //       }

// // //       final response = await http.get(
// // //         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllMovies'),
// // //         headers: {'auth-key': authKey},
// // //       ).timeout(Duration(seconds: 10));

// // //       if (response.statusCode == 200) {
// // //         List<dynamic> data = json.decode(response.body);

// // //         // Sort data safely
// // //         if (data.isNotEmpty) {
// // //           data.sort((a, b) {
// // //             final aIndex = a['index'];
// // //             final bIndex = b['index'];
// // //             if (aIndex == null && bIndex == null) return 0;
// // //             if (aIndex == null) return 1;
// // //             if (bIndex == null) return -1;

// // //             int aVal = 0;
// // //             int bVal = 0;

// // //             if (aIndex is num) {
// // //               aVal = aIndex.toInt();
// // //             } else if (aIndex is String) {
// // //               aVal = int.tryParse(aIndex) ?? 0;
// // //             }

// // //             if (bIndex is num) {
// // //               bVal = bIndex.toInt();
// // //             } else if (bIndex is String) {
// // //               bVal = int.tryParse(bIndex) ?? 0;
// // //             }

// // //             return aVal.compareTo(bVal);
// // //           });
// // //         }

// // //         // Convert to NewsItemModel
// // //         return data
// // //             .map((m) => NewsItemModel(
// // //                   id: m['id'].toString(),
// // //                   name: m['name']?.toString() ?? '',
// // //                   banner: m['banner']?.toString() ?? '',
// // //                   poster: m['poster']?.toString() ?? '',
// // //                   description: m['description']?.toString() ?? '',
// // //                   url: m['url']?.toString() ?? '',
// // //                   streamType: m['streamType']?.toString() ?? '',
// // //                   type: m['type']?.toString() ?? '',
// // //                   genres: m['genres']?.toString() ?? '',
// // //                   status: m['status']?.toString() ?? '',
// // //                   videoId: m['videoId']?.toString() ?? '',
// // //                   index: m['index']?.toString() ?? '',
// // //                   image: '',
// // //                   unUpdatedUrl: '',
// // //                 ))
// // //             .toList();
// // //       } else {
// // //         print('Failed to fetch fresh movies: ${response.statusCode}');
// // //         return [];
// // //       }
// // //     } catch (e) {
// // //       print('Error fetching fresh movies data: $e');
// // //       return [];
// // //     }
// // //   }

// // //   // Updated tap handler with fresh data fetch
// // //   Future<void> _handleTapWithFreshData() async {
// // //     if (_isNavigating || widget.movieData == null) return;
// // //     _isNavigating = true;

// // //     // Show loading indicator
// // //     showDialog(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (BuildContext context) {
// // //         return WillPopScope(
// // //           onWillPop: () async {
// // //             _isNavigating = false;
// // //             return true;
// // //           },
// // //           child: Center(child: CircularProgressIndicator()),
// // //         );
// // //       },
// // //     );

// // //     try {
// // //       // Fetch fresh data
// // //       List<NewsItemModel> freshMovies = await _fetchFreshMoviesData();

// // //       // Close loading dialog
// // //       Navigator.of(context, rootNavigator: true).pop();

// // //       // Handle movie ID conversion safely
// // //       int movieIdInt;
// // //       final movieData = widget.movieData;

// // //       if (movieData['id'] is int) {
// // //         movieIdInt = movieData['id'];
// // //       } else if (movieData['id'] is String) {
// // //         try {
// // //           movieIdInt = int.parse(movieData['id']);
// // //         } catch (e) {
// // //           _isNavigating = false;
// // //           return; // Don't navigate if ID is invalid
// // //         }
// // //       } else {
// // //         _isNavigating = false;
// // //         return; // Invalid ID, don't navigate
// // //       }

// // //       // Navigate to details page with fresh data
// // //       await Navigator.push(
// // //         context,
// // //         MaterialPageRoute(
// // //           builder: (context) => DetailsPage(
// // //             id: movieIdInt,
// // //             channelList: freshMovies, // Use fresh data
// // //             source: widget.source ?? 'isMovieScreen',
// // //             banner: movieData['banner']?.toString() ?? '',
// // //             name: movieData['name']?.toString() ?? '',
// // //           ),
// // //         ),
// // //       );
// // //     } catch (e) {
// // //       // Close loading dialog and show error
// // //       Navigator.of(context, rootNavigator: true).pop();
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text('Error loading movie: ${e.toString()}')),
// // //       );
// // //     } finally {
// // //       _isNavigating = false;
// // //     }
// // //   }

// // //   // Custom image display function that handles both network and data images
// // //   Widget _buildImageWidget(String imageUrl,
// // //       {required double width, required double height}) {
// // //     if (imageUrl.isEmpty) {
// // //       return Container(
// // //         width: width,
// // //         height: height,
// // //         color: Colors.grey[800],
// // //         child: Icon(
// // //           Icons.image_not_supported,
// // //           color: Colors.white,
// // //           size: 30,
// // //         ),
// // //       );
// // //     }

// // //     if (imageUrl.startsWith('data:image/')) {
// // //       // Handle data:image format
// // //       try {
// // //         if (!imageUrl.contains(',')) {
// // //           return _buildErrorWidget(width, height);
// // //         }

// // //         final String base64String = imageUrl.split(',')[1];
// // //         if (base64String.isEmpty) {
// // //           return _buildErrorWidget(width, height);
// // //         }

// // //         final Uint8List bytes = base64Decode(base64String);

// // //         return Image.memory(
// // //           bytes,
// // //           width: width,
// // //           height: height,
// // //           fit: BoxFit.cover,
// // //           gaplessPlayback: true,
// // //           errorBuilder: (context, error, stackTrace) {
// // //             return _buildErrorWidget(width, height);
// // //           },
// // //         );
// // //       } catch (e) {
// // //         return _buildErrorWidget(width, height);
// // //       }
// // //     } else if (imageUrl.startsWith('http://') ||
// // //         imageUrl.startsWith('https://')) {
// // //       // Handle network images
// // //       return CachedNetworkImage(
// // //         imageUrl: imageUrl,
// // //         width: width,
// // //         height: height,
// // //         fit: BoxFit.cover,
// // //         memCacheWidth: (width * 2).toInt(),
// // //         memCacheHeight: (height * 2).toInt(),
// // //         placeholder: (context, url) => Image.asset(localImage),
// // //         errorWidget: (context, url, error) => Image.asset(localImage),
// // //       );
// // //     } else {
// // //       return _buildErrorWidget(width, height);
// // //     }
// // //   }

// // //   Widget _buildErrorWidget(double width, double height) {
// // //     return Container(
// // //       width: width,
// // //       height: height,
// // //       color: Colors.grey[800],
// // //       child: Icon(
// // //         Icons.broken_image,
// // //         color: Colors.white,
// // //         size: 30,
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final double containerWidth = widget.width ?? screenwdt * 0.19;
// // //     final double normalHeight = widget.height ?? screenhgt * 0.20;
// // //     final double focusedHeight = widget.focusedHeight ?? screenhgt * 0.25;

// // //     // Calculate the growth in height when focused (difference between focused and normal height)
// // //     final double heightGrowth = focusedHeight - normalHeight;

// // //     return FocusableActionDetector(
// // //       focusNode: _focusNode,
// // //       onFocusChange: (hasFocus) {
// // //         if (hasFocus) {
// // //           context.read<ColorProvider>().updateColor(paletteColor, true);
// // //         }
// // //       },
// // //       actions: {
// // //         ActivateIntent: CallbackAction<ActivateIntent>(
// // //           onInvoke: (ActivateIntent intent) {
// // //             // Handle both cases - up press and normal tap
// // //             if (widget.onUpPress != null && _focusNode.hasFocus) {
// // //               widget.onUpPress!();
// // //             } else {
// // //               // Use fresh data fetch method instead of original onTap
// // //               if (widget.movieData != null) {
// // //                 _handleTapWithFreshData();
// // //               } else {
// // //                 widget.onTap(); // Fallback to original onTap if no movieData
// // //               }
// // //             }
// // //             return null;
// // //           },
// // //         ),
// // //       },
// // //       shortcuts: {
// // //         // Add this to handle both Enter and Select keys
// // //         LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
// // //         LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
// // //       },
// // //       child: GestureDetector(
// // //         onTap: () {
// // //           // Use fresh data fetch method for gesture tap too
// // //           if (widget.movieData != null) {
// // //             _handleTapWithFreshData();
// // //           } else {
// // //             widget.onTap(); // Fallback to original onTap if no movieData
// // //           }
// // //         },
// // //         child: Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           crossAxisAlignment: CrossAxisAlignment.center,
// // //           children: [
// // //             // Using Stack for true bidirectional expansion
// // //             Container(
// // //               width: containerWidth,
// // //               height:
// // //                   normalHeight, // Fixed container height is the normal height
// // //               child: Stack(
// // //                 clipBehavior: Clip.none, // Allow items to overflow the stack
// // //                 alignment: Alignment.center,
// // //                 children: [
// // //                   // Animated container for the image
// // //                   AnimatedPositioned(
// // //                     duration: const Duration(milliseconds: 800),
// // //                     top: isFocused
// // //                         ? -(heightGrowth / 2)
// // //                         : 0, // Move up when focused
// // //                     left: 0,
// // //                     width: containerWidth,
// // //                     height: isFocused ? focusedHeight : normalHeight,
// // //                     child: Container(
// // //                       decoration: BoxDecoration(
// // //                         border: Border.all(
// // //                           color: isFocused ? paletteColor : Colors.transparent,
// // //                           width: 4.0,
// // //                         ),
// // //                         boxShadow: isFocused
// // //                             ? [
// // //                                 BoxShadow(
// // //                                   color: paletteColor,
// // //                                   blurRadius: 25,
// // //                                   spreadRadius: 10,
// // //                                 ),
// // //                               ]
// // //                             : [],
// // //                       ),
// // //                       child: ClipRRect(
// // //                         borderRadius: BorderRadius.circular(4.0),
// // //                         child: _buildImageWidget(
// // //                           widget.imageUrl,
// // //                           width: containerWidth,
// // //                           height: isFocused ? focusedHeight : normalHeight,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //             SizedBox(height: 10),
// // //             Container(
// // //               width: containerWidth,
// // //               child: Text(
// // //                 widget.name.toUpperCase(),
// // //                 style: TextStyle(
// // //                   color: isFocused ? paletteColor : Colors.grey,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //                 textAlign: TextAlign.center,
// // //                 overflow: TextOverflow.ellipsis,
// // //                 maxLines: 1,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }




// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:mobi_tv_entertainment/main.dart';
// // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // import 'package:provider/provider.dart';
// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// // import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// // import 'dart:convert';

// // class FocussableMoviesWidget extends StatefulWidget {
// //   final String imageUrl;
// //   final String name;
// //   final VoidCallback onTap;
// //   final Future<Color> Function(String imageUrl) fetchPaletteColor;
// //   final FocusNode? focusNode;
// //   final Function(bool)? onFocusChange;
// //   final double? width;
// //   final double? height;
// //   final double? focusedHeight;
// //   final VoidCallback? onUpPress;

// //   // Add these new parameters for fresh data fetch
// //   final dynamic movieData; // The current movie data
// //   final String? source; // 'isMovieScreen' or other source

// //   const FocussableMoviesWidget({
// //     Key? key, // Add this line to fix the error
// //     required this.imageUrl,
// //     required this.name,
// //     required this.onTap,
// //     required this.fetchPaletteColor,
// //     this.focusNode,
// //     this.onFocusChange,
// //     this.width,
// //     this.height,
// //     this.focusedHeight,
// //     this.onUpPress,
// //     this.movieData,
// //     this.source,
// //   }) : super(key: key); // Add this super call

// //   @override
// //   _FocusableMoviesWidgetState createState() => _FocusableMoviesWidgetState();
// // }

// // class _FocusableMoviesWidgetState extends State<FocussableMoviesWidget> {
// //   bool isFocused = false;
// //   Color paletteColor = Colors.pink;
// //   late FocusNode _focusNode;
// //   bool _isNavigating = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _focusNode = widget.focusNode ?? FocusNode();
// //     _focusNode.addListener(_handleFocusChange);
// //     _updatePaletteColor();
// //   }

// //   @override
// //   void dispose() {
// //     _focusNode.removeListener(_handleFocusChange);
// //     if (widget.focusNode == null) {
// //       _focusNode.dispose();
// //     }
// //     super.dispose();
// //   }

// //   void _handleFocusChange() {
// //     final hasFocus = _focusNode.hasFocus;
// //     setState(() {
// //       isFocused = hasFocus;
// //     });
// //     widget.onFocusChange?.call(hasFocus);

// //     if (hasFocus) {
// //       context.read<ColorProvider>().updateColor(paletteColor, true);
// //     } else {
// //       context.read<ColorProvider>().resetColor();
// //     }
// //   }

// //   Future<void> _updatePaletteColor() async {
// //     try {
// //       final color = await widget.fetchPaletteColor(widget.imageUrl);
// //       if (mounted) {
// //         setState(() {
// //           paletteColor = color;
// //         });
// //       }
// //     } catch (_) {
// //       if (mounted) {
// //         setState(() {
// //           paletteColor = Colors.grey;
// //         });
// //       }
// //     }
// //   }

// //   // Method to fetch fresh movies data with new API structure
// //   Future<List<NewsItemModel>> _fetchFreshMoviesData() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       String authKey = AuthManager.authKey;
// //       if (authKey.isEmpty) {
// //         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
// //       }

// //       final response = await http.get(
// //         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllMovies'),
// //         headers: {'auth-key': authKey},
// //       ).timeout(Duration(seconds: 10));

// //       if (response.statusCode == 200) {
// //         List<dynamic> data = json.decode(response.body);

// //         // Sort data safely by ID since index is null
// //         if (data.isNotEmpty) {
// //           data.sort((a, b) {
// //             final aId = a['id'];
// //             final bId = b['id'];
// //             if (aId == null && bId == null) return 0;
// //             if (aId == null) return 1;
// //             if (bId == null) return -1;

// //             int aVal = 0;
// //             int bVal = 0;

// //             if (aId is num) {
// //               aVal = aId.toInt();
// //             } else if (aId is String) {
// //               aVal = int.tryParse(aId) ?? 0;
// //             }

// //             if (bId is num) {
// //               bVal = bId.toInt();
// //             } else if (bId is String) {
// //               bVal = int.tryParse(bId) ?? 0;
// //             }

// //             return aVal.compareTo(bVal);
// //           });
// //         }

// //         // Convert to NewsItemModel with new API structure
// //         return data
// //             .map((m) => NewsItemModel(
// //                   id: m['id'].toString(),
// //                   name: m['name']?.toString() ?? '',
// //                   banner: m['banner']?.toString() ?? '',
// //                   poster: m['poster']?.toString() ?? '',
// //                   description: m['description']?.toString() ?? '',
// //                   url: m['movie_url']?.toString() ?? '', // Use movie_url from new API
// //                   streamType: m['source_type']?.toString() ?? '',
// //                   type: m['type']?.toString() ?? '',
// //                   genres: m['genres']?.toString() ?? '',
// //                   status: m['status']?.toString() ?? '',
// //                   videoId: m['id']?.toString() ?? '',
// //                   index: m['id']?.toString() ?? '', // Use id as index since index is null
// //                   image: m['banner']?.toString() ?? '',
// //                   unUpdatedUrl: m['movie_url']?.toString() ?? '',
// //                   contentType: m['content_type']?.toString() ?? '1',
// //                   contentId: m['id']?.toString() ?? '',
// //                   liveStatus: false, // Movies are not live
// //                 ))
// //             .toList();
// //       } else {
// //         print('Failed to fetch fresh movies: ${response.statusCode}');
// //         return [];
// //       }
// //     } catch (e) {
// //       print('Error fetching fresh movies data: $e');
// //       return [];
// //     }
// //   }

// //   // Updated tap handler to directly navigate to VideoScreen
// //   Future<void> _handleTapWithVideoScreen() async {
// //     if (_isNavigating || widget.movieData == null) return;
// //     _isNavigating = true;

// //     // Show loading indicator
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (BuildContext context) {
// //         return WillPopScope(
// //           onWillPop: () async {
// //             _isNavigating = false;
// //             return true;
// //           },
// //           child: Center(child: CircularProgressIndicator()),
// //         );
// //       },
// //     );

// //     try {
// //       // Fetch fresh data
// //       List<NewsItemModel> freshMovies = await _fetchFreshMoviesData();

// //       // Close loading dialog
// //       Navigator.of(context, rootNavigator: true).pop();

// //       // Handle movie data safely
// //       final movieData = widget.movieData;

// //       // Safe ID conversion
// //       int movieIdInt;
// //       if (movieData['id'] is int) {
// //         movieIdInt = movieData['id'];
// //       } else if (movieData['id'] is String) {
// //         try {
// //           movieIdInt = int.parse(movieData['id']);
// //         } catch (e) {
// //           _isNavigating = false;
// //           return;
// //         }
// //       } else {
// //         _isNavigating = false;
// //         return;
// //       }

// //       // Extract video URL from movie data
// //       String videoUrl = movieData['movie_url']?.toString() ?? '';
// //       if (videoUrl.isEmpty) {
// //         String youtubeTrailer = movieData['youtube_trailer']?.toString() ?? '';
// //         if (youtubeTrailer.isNotEmpty) {
// //           if (youtubeTrailer.length == 11) {
// //             // It's a YouTube ID
// //             videoUrl = 'https://www.youtube.com/watch?v=$youtubeTrailer';
// //           } else if (youtubeTrailer.contains('youtube.com') || youtubeTrailer.contains('youtu.be')) {
// //             // It's already a full URL
// //             videoUrl = youtubeTrailer;
// //           }
// //         }
// //       }

// //       if (videoUrl.isEmpty) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Video URL not available for this movie')),
// //         );
// //         _isNavigating = false;
// //         return;
// //       }

// //       // Navigate directly to VideoScreen
// //       await Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => VideoScreen(
// //             videoUrl: videoUrl,
// //             unUpdatedUrl: videoUrl,
// //             channelList: freshMovies.isNotEmpty ? freshMovies : _createFallbackChannelList(),
// //             bannerImageUrl: movieData['banner']?.toString() ?? '',
// //             startAtPosition: Duration.zero,
// //             videoType: 'movie',
// //             isLive: false,
// //             isVOD: true,
// //             isLastPlayedStored: false,
// //             isSearch: false,
// //             isHomeCategory: false,
// //             isBannerSlider: false,
// //             videoId: movieIdInt,
// //             seasonId: 0,
// //             source: widget.source ?? 'isMovieScreen',
// //             name: movieData['name']?.toString() ?? '',
// //             liveStatus: false,
// //           ),
// //         ),
// //       );
// //     } catch (e) {
// //       // Close loading dialog and show error
// //       Navigator.of(context, rootNavigator: true).pop();
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error loading movie: ${e.toString()}')),
// //       );
// //     } finally {
// //       _isNavigating = false;
// //     }
// //   }

// //   // Create a fallback channel list if fresh data fetch fails
// //   List<NewsItemModel> _createFallbackChannelList() {
// //     if (widget.movieData == null) return [];

// //     final movieData = widget.movieData;
// //     return [
// //       NewsItemModel(
// //         id: movieData['id'].toString(),
// //         name: movieData['name']?.toString() ?? '',
// //         banner: movieData['banner']?.toString() ?? '',
// //         poster: movieData['poster']?.toString() ?? '',
// //         description: movieData['description']?.toString() ?? '',
// //         url: movieData['movie_url']?.toString() ?? '',
// //         streamType: movieData['source_type']?.toString() ?? '',
// //         type: movieData['type']?.toString() ?? '',
// //         genres: movieData['genres']?.toString() ?? '',
// //         status: movieData['status']?.toString() ?? '',
// //         videoId: movieData['id']?.toString() ?? '',
// //         index: movieData['id']?.toString() ?? '',
// //         image: movieData['banner']?.toString() ?? '',
// //         unUpdatedUrl: movieData['movie_url']?.toString() ?? '',
// //         contentType: movieData['content_type']?.toString() ?? '1',
// //         contentId: movieData['id']?.toString() ?? '',
// //         liveStatus: false,
// //       )
// //     ];
// //   }

// //   // Custom image display function that handles both network and data images
// //   Widget _buildImageWidget(String imageUrl,
// //       {required double width, required double height}) {
// //     if (imageUrl.isEmpty) {
// //       return Container(
// //         width: width,
// //         height: height,
// //         color: Colors.grey[800],
// //         child: Icon(
// //           Icons.image_not_supported,
// //           color: Colors.white,
// //           size: 30,
// //         ),
// //       );
// //     }

// //     if (imageUrl.startsWith('data:image/')) {
// //       // Handle data:image format
// //       try {
// //         if (!imageUrl.contains(',')) {
// //           return _buildErrorWidget(width, height);
// //         }

// //         final String base64String = imageUrl.split(',')[1];
// //         if (base64String.isEmpty) {
// //           return _buildErrorWidget(width, height);
// //         }

// //         final Uint8List bytes = base64Decode(base64String);

// //         return Image.memory(
// //           bytes,
// //           width: width,
// //           height: height,
// //           fit: BoxFit.cover,
// //           gaplessPlayback: true,
// //           errorBuilder: (context, error, stackTrace) {
// //             return _buildErrorWidget(width, height);
// //           },
// //         );
// //       } catch (e) {
// //         return _buildErrorWidget(width, height);
// //       }
// //     } else if (imageUrl.startsWith('http://') ||
// //         imageUrl.startsWith('https://')) {
// //       // Handle network images
// //       return CachedNetworkImage(
// //         imageUrl: imageUrl,
// //         width: width,
// //         height: height,
// //         fit: BoxFit.cover,
// //         memCacheWidth: (width * 2).toInt(),
// //         memCacheHeight: (height * 2).toInt(),
// //         placeholder: (context, url) => Image.asset(localImage),
// //         errorWidget: (context, url, error) => Image.asset(localImage),
// //       );
// //     } else {
// //       return _buildErrorWidget(width, height);
// //     }
// //   }

// //   Widget _buildErrorWidget(double width, double height) {
// //     return Container(
// //       width: width,
// //       height: height,
// //       color: Colors.grey[800],
// //       child: Icon(
// //         Icons.broken_image,
// //         color: Colors.white,
// //         size: 30,
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final double containerWidth = widget.width ?? screenwdt * 0.19;
// //     final double normalHeight = widget.height ?? screenhgt * 0.20;
// //     final double focusedHeight = widget.focusedHeight ?? screenhgt * 0.25;

// //     // Calculate the growth in height when focused (difference between focused and normal height)
// //     final double heightGrowth = focusedHeight - normalHeight;

// //     return FocusableActionDetector(
// //       focusNode: _focusNode,
// //       onFocusChange: (hasFocus) {
// //         if (hasFocus) {
// //           context.read<ColorProvider>().updateColor(paletteColor, true);
// //         }
// //       },
// //       actions: {
// //         ActivateIntent: CallbackAction<ActivateIntent>(
// //           onInvoke: (ActivateIntent intent) {
// //             // Handle both cases - up press and normal tap
// //             if (widget.onUpPress != null && _focusNode.hasFocus) {
// //               widget.onUpPress!();
// //             } else {
// //               // Use VideoScreen navigation method instead of details page
// //               if (widget.movieData != null) {
// //                 _handleTapWithVideoScreen();
// //               } else {
// //                 widget.onTap(); // Fallback to original onTap if no movieData
// //               }
// //             }
// //             return null;
// //           },
// //         ),
// //       },
// //       shortcuts: {
// //         // Add this to handle both Enter and Select keys
// //         LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
// //         LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
// //       },
// //       child: GestureDetector(
// //         onTap: () {
// //           // Use VideoScreen navigation method for gesture tap too
// //           if (widget.movieData != null) {
// //             _handleTapWithVideoScreen();
// //           } else {
// //             widget.onTap(); // Fallback to original onTap if no movieData
// //           }
// //         },
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [
// //             // Using Stack for true bidirectional expansion
// //             Container(
// //               width: containerWidth,
// //               height:
// //                   normalHeight, // Fixed container height is the normal height
// //               child: Stack(
// //                 clipBehavior: Clip.none, // Allow items to overflow the stack
// //                 alignment: Alignment.center,
// //                 children: [
// //                   // Animated container for the image
// //                   AnimatedPositioned(
// //                     duration: const Duration(milliseconds: 800),
// //                     top: isFocused
// //                         ? -(heightGrowth / 2)
// //                         : 0, // Move up when focused
// //                     left: 0,
// //                     width: containerWidth,
// //                     height: isFocused ? focusedHeight : normalHeight,
// //                     child: Container(
// //                       decoration: BoxDecoration(
// //                         border: Border.all(
// //                           color: isFocused ? paletteColor : Colors.transparent,
// //                           width: 4.0,
// //                         ),
// //                         boxShadow: isFocused
// //                             ? [
// //                                 BoxShadow(
// //                                   color: paletteColor,
// //                                   blurRadius: 25,
// //                                   spreadRadius: 10,
// //                                 ),
// //                               ]
// //                             : [],
// //                       ),
// //                       child: ClipRRect(
// //                         borderRadius: BorderRadius.circular(4.0),
// //                         child: _buildImageWidget(
// //                           widget.imageUrl,
// //                           width: containerWidth,
// //                           height: isFocused ? focusedHeight : normalHeight,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             SizedBox(height: 10),
// //             Container(
// //               width: containerWidth,
// //               child: Text(
// //                 widget.name.toUpperCase(),
// //                 style: TextStyle(
// //                   color: isFocused ? paletteColor : Colors.grey,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //                 textAlign: TextAlign.center,
// //                 overflow: TextOverflow.ellipsis,
// //                 maxLines: 1,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }






// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'dart:convert';

// class FocussableMoviesWidget extends StatefulWidget {
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

//   // Add these new parameters for fresh data fetch
//   final dynamic movieData; // The current movie data
//   final String? source; // 'isMovieScreen' or other source

//   const FocussableMoviesWidget({
//     Key? key, // Add this line to fix the error
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
//     this.movieData,
//     this.source,
//   }) : super(key: key); // Add this super call

//   @override
//   _FocusableMoviesWidgetState createState() => _FocusableMoviesWidgetState();
// }

// class _FocusableMoviesWidgetState extends State<FocussableMoviesWidget> {
//   bool isFocused = false;
//   Color paletteColor = Colors.pink;
//   late FocusNode _focusNode;
//   bool _isNavigating = false;

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

//   // Method to fetch fresh movies data with new API structure
//   Future<List<NewsItemModel>> _fetchFreshMoviesData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = AuthManager.authKey;
//       if (authKey.isEmpty) {
//         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//       }

//       final response = await http.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllMovies'),
//         headers: {'auth-key': authKey},
//       ).timeout(Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);

//         // Sort data safely by ID since index is null
//         if (data.isNotEmpty) {
//           data.sort((a, b) {
//             final aId = a['id'];
//             final bId = b['id'];
//             if (aId == null && bId == null) return 0;
//             if (aId == null) return 1;
//             if (bId == null) return -1;

//             int aVal = 0;
//             int bVal = 0;

//             if (aId is num) {
//               aVal = aId.toInt();
//             } else if (aId is String) {
//               aVal = int.tryParse(aId) ?? 0;
//             }

//             if (bId is num) {
//               bVal = bId.toInt();
//             } else if (bId is String) {
//               bVal = int.tryParse(bId) ?? 0;
//             }

//             return aVal.compareTo(bVal);
//           });
//         }

//         // Convert to NewsItemModel with new API structure
//         return data
//             .map((m) => NewsItemModel(
//                   id: m['id'].toString(),
//                   name: m['name']?.toString() ?? '',
//                   banner: m['banner']?.toString() ?? '',
//                   poster: m['poster']?.toString() ?? '',
//                   description: m['description']?.toString() ?? '',
//                   url: m['movie_url']?.toString() ?? '', // Use movie_url from new API
//                   streamType: m['source_type']?.toString() ?? '',
//                   type: m['type']?.toString() ?? '',
//                   genres: m['genres']?.toString() ?? '',
//                   status: m['status']?.toString() ?? '',
//                   videoId: m['id']?.toString() ?? '',
//                   index: m['id']?.toString() ?? '', // Use id as index since index is null
//                   image: m['banner']?.toString() ?? '',
//                   unUpdatedUrl: m['movie_url']?.toString() ?? '',
//                   contentType: m['content_type']?.toString() ?? '1',
//                   contentId: m['id']?.toString() ?? '',
//                   liveStatus: false, // Movies are not live
//                 ))
//             .toList();
//       } else {
//         print('Failed to fetch fresh movies: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       print('Error fetching fresh movies data: $e');
//       return [];
//     }
//   }

//   // Updated tap handler to directly navigate to VideoScreen
//   Future<void> _handleTapWithVideoScreen() async {
//     if (_isNavigating || widget.movieData == null) return;
//     _isNavigating = true;

//     // Show loading indicator
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async {
//             _isNavigating = false;
//             return true;
//           },
//           child: Center(child: CircularProgressIndicator()),
//         );
//       },
//     );

//     try {
//       // Fetch fresh data
//       List<NewsItemModel> freshMovies = await _fetchFreshMoviesData();

//       // Close loading dialog
//       Navigator.of(context, rootNavigator: true).pop();

//       // Handle movie data safely
//       final movieData = widget.movieData;

//       // Safe ID conversion
//       int movieIdInt;
//       if (movieData['id'] is int) {
//         movieIdInt = movieData['id'];
//       } else if (movieData['id'] is String) {
//         try {
//           movieIdInt = int.parse(movieData['id']);
//         } catch (e) {
//           _isNavigating = false;
//           return;
//         }
//       } else {
//         _isNavigating = false;
//         return;
//       }

//       // Extract video URL from movie data
//       String videoUrl = movieData['movie_url']?.toString() ?? '';
//       if (videoUrl.isEmpty) {
//         String youtubeTrailer = movieData['youtube_trailer']?.toString() ?? '';
//         if (youtubeTrailer.isNotEmpty) {
//           if (youtubeTrailer.length == 11) {
//             // It's a YouTube ID
//             videoUrl = 'https://www.youtube.com/watch?v=$youtubeTrailer';
//           } else if (youtubeTrailer.contains('youtube.com') || youtubeTrailer.contains('youtu.be')) {
//             // It's already a full URL
//             videoUrl = youtubeTrailer;
//           }
//         }
//       }

//       if (videoUrl.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Video URL not available for this movie')),
//         );
//         _isNavigating = false;
//         return;
//       }

//       // Navigate directly to VideoScreen
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => VideoScreen(
//             videoUrl: videoUrl,
//             unUpdatedUrl: videoUrl,
//             channelList: freshMovies.isNotEmpty ? freshMovies : _createFallbackChannelList(),
//             bannerImageUrl: movieData['banner']?.toString() ?? '',
//             startAtPosition: Duration.zero,
//             videoType: 'movie',
//             isLive: false,
//             isVOD: true,
//             isLastPlayedStored: false,
//             isSearch: false,
//             isHomeCategory: false,
//             isBannerSlider: false,
//             videoId: movieIdInt,
//             seasonId: 0,
//             source: widget.source ?? 'isMovieScreen',
//             name: movieData['name']?.toString() ?? '',
//             liveStatus: false,
//           ),
//         ),
//       );
//     } catch (e) {
//       // Close loading dialog and show error
//       Navigator.of(context, rootNavigator: true).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading movie: ${e.toString()}')),
//       );
//     } finally {
//       _isNavigating = false;
//     }
//   }

//   // Create a fallback channel list if fresh data fetch fails
//   List<NewsItemModel> _createFallbackChannelList() {
//     if (widget.movieData == null) return [];

//     final movieData = widget.movieData;
//     return [
//       NewsItemModel(
//         id: movieData['id'].toString(),
//         name: movieData['name']?.toString() ?? '',
//         banner: movieData['banner']?.toString() ?? '',
//         poster: movieData['poster']?.toString() ?? '',
//         description: movieData['description']?.toString() ?? '',
//         url: movieData['movie_url']?.toString() ?? '',
//         streamType: movieData['source_type']?.toString() ?? '',
//         type: movieData['type']?.toString() ?? '',
//         genres: movieData['genres']?.toString() ?? '',
//         status: movieData['status']?.toString() ?? '',
//         videoId: movieData['id']?.toString() ?? '',
//         index: movieData['id']?.toString() ?? '',
//         image: movieData['banner']?.toString() ?? '',
//         unUpdatedUrl: movieData['movie_url']?.toString() ?? '',
//         contentType: movieData['content_type']?.toString() ?? '1',
//         contentId: movieData['id']?.toString() ?? '',
//         liveStatus: false,
//       )
//     ];
//   }

//   // Custom image display function that handles both network and data images
//   Widget _buildImageWidget(String imageUrl,
//       {required double width, required double height}) {
//     if (imageUrl.isEmpty) {
//       return Container(
//         width: width,
//         height: height,
//         color: Colors.grey[800],
//         child: Icon(
//           Icons.image_not_supported,
//           color: Colors.white,
//           size: 30,
//         ),
//       );
//     }

//     if (imageUrl.startsWith('data:image/')) {
//       // Handle data:image format
//       try {
//         if (!imageUrl.contains(',')) {
//           return _buildErrorWidget(width, height);
//         }

//         final String base64String = imageUrl.split(',')[1];
//         if (base64String.isEmpty) {
//           return _buildErrorWidget(width, height);
//         }

//         final Uint8List bytes = base64Decode(base64String);

//         return Image.memory(
//           bytes,
//           width: width,
//           height: height,
//           fit: BoxFit.cover,
//           gaplessPlayback: true,
//           errorBuilder: (context, error, stackTrace) {
//             return _buildErrorWidget(width, height);
//           },
//         );
//       } catch (e) {
//         return _buildErrorWidget(width, height);
//       }
//     } else if (imageUrl.startsWith('http://') ||
//         imageUrl.startsWith('https://')) {
//       // Handle network images
//       return CachedNetworkImage(
//         imageUrl: imageUrl,
//         width: width,
//         height: height,
//         fit: BoxFit.cover,
//         memCacheWidth: (width * 2).toInt(),
//         memCacheHeight: (height * 2).toInt(),
//         placeholder: (context, url) => Image.asset(localImage),
//         errorWidget: (context, url, error) => Image.asset(localImage),
//       );
//     } else {
//       return _buildErrorWidget(width, height);
//     }
//   }

//   Widget _buildErrorWidget(double width, double height) {
//     return Container(
//       width: width,
//       height: height,
//       color: Colors.grey[800],
//       child: Icon(
//         Icons.broken_image,
//         color: Colors.white,
//         size: 30,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double containerWidth = widget.width ?? screenwdt * 0.19;
//     final double normalHeight = widget.height ?? screenhgt * 0.20;
//     final double focusedHeight = widget.focusedHeight ?? screenhgt * 0.25;

//     // Calculate the growth in height when focused (difference between focused and normal height)
//     final double heightGrowth = focusedHeight - normalHeight;

//     return Focus(
//       focusNode: _focusNode,
//       onKey: (FocusNode node, RawKeyEvent event) {
//         if (event is RawKeyDownEvent) {
//           if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//             widget.onUpPress?.call();
//             return KeyEventResult.handled;
//           } else if (event.logicalKey == LogicalKeyboardKey.enter ||
//               event.logicalKey == LogicalKeyboardKey.select) {
//             // Use VideoScreen navigation method
//             if (widget.movieData != null) {
//               _handleTapWithVideoScreen();
//             } else {
//               widget.onTap();
//             }
//             return KeyEventResult.handled;
//           }
//         }
//         return KeyEventResult.ignored;
//       },
//       child: GestureDetector(
//         onTap: () {
//           // Use VideoScreen navigation method for gesture tap too
//           if (widget.movieData != null) {
//             _handleTapWithVideoScreen();
//           } else {
//             widget.onTap();
//           }
//         },
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Using Stack for true bidirectional expansion
//             Container(
//               width: containerWidth,
//               height:
//                   normalHeight, // Fixed container height is the normal height
//               child: Stack(
//                 clipBehavior: Clip.none, // Allow items to overflow the stack
//                 alignment: Alignment.center,
//                 children: [
//                   // Animated container for the image
//                   AnimatedPositioned(
//                     duration: const Duration(milliseconds: 800),
//                     top: isFocused
//                         ? -(heightGrowth / 2)
//                         : 0, // Move up when focused
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
//                         child: _buildImageWidget(
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



// // import 'package:flutter/material.dart';
// // import 'package:mobi_tv_entertainment/main.dart';
// // import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
// // import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// // import 'package:provider/provider.dart';

// // class FocussableManageMoviesWidget extends StatefulWidget {
// //   final String imageUrl;
// //   final String name;
// //   final VoidCallback onTap;
// //   final Future<Color> Function(String imageUrl) fetchPaletteColor;
// //   final FocusNode? focusNode;
// //   final Function(bool)? onFocusChange;
// //   final double? width;
// //   final double? height;
// //   final double? focusedHeight;

// //   const FocussableManageMoviesWidget({
// //     required this.imageUrl,
// //     required this.name,
// //     required this.onTap,
// //     required this.fetchPaletteColor,
// //     this.focusNode,
// //     this.onFocusChange,
// //     this.width,
// //     this.height,
// //     this.focusedHeight,
// //   });

// //   @override
// //   _FocussableManageMoviesWidgetState createState() => _FocussableManageMoviesWidgetState();
// // }

// // class _FocussableManageMoviesWidgetState extends State<FocussableManageMoviesWidget> {
// //   bool isFocused = false;
// //   Color paletteColor = Colors.pink;
// //   late FocusNode _focusNode;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _focusNode = widget.focusNode ?? FocusNode();
// //     _focusNode.addListener(_handleFocusChange);
// //     _updatePaletteColor();
// //   }

// //   @override
// //   void dispose() {
// //     _focusNode.removeListener(_handleFocusChange);
// //     if (widget.focusNode == null) {
// //       _focusNode.dispose();
// //     }
// //     super.dispose();
// //   }

// //   void _handleFocusChange() {
// //     final hasFocus = _focusNode.hasFocus;
// //     setState(() {
// //       isFocused = hasFocus;
// //     });
// //     widget.onFocusChange?.call(hasFocus);

// //     if (hasFocus) {
// //       context.read<ColorProvider>().updateColor(paletteColor, true);
// //     } else {
// //       context.read<ColorProvider>().resetColor();
// //     }
// //   }

// //   Future<void> _updatePaletteColor() async {
// //     try {
// //       final color = await widget.fetchPaletteColor(widget.imageUrl);
// //       if (mounted) {
// //         setState(() {
// //           paletteColor = color;
// //         });
// //       }
// //     } catch (_) {
// //       if (mounted) {
// //         setState(() {
// //           paletteColor = Colors.grey;
// //         });
// //       }
// //     }
// //   }

// //   // Removed customDisplayImage function as we're using the provided displayImage function

// //   @override
// //   Widget build(BuildContext context) {
// //     final double containerWidth = widget.width ?? screenwdt * 0.19;
// //     final double normalHeight = widget.height ?? screenhgt * 0.21;
// //     final double focusedHeight = widget.focusedHeight ?? screenhgt * 0.24;
    
// //     // Calculate the growth in height when focused (difference between focused and normal height)
// //     final double heightGrowth = focusedHeight - normalHeight;
    
// //     // Calculate the vertical position shift when focused (to center the expanded item)
// //     final double verticalOffset = isFocused ? -(heightGrowth / 2) : 0;

// //     return FocusableActionDetector(
// //       focusNode: _focusNode,
// //       onFocusChange: (hasFocus) {
// //         if (hasFocus) {
// //           context.read<ColorProvider>().updateColor(paletteColor, true);
// //         }
// //       },
// //       actions: {
// //         ActivateIntent: CallbackAction<ActivateIntent>(
// //           onInvoke: (ActivateIntent intent) {
// //             widget.onTap();
// //             return null;
// //           },
// //         ),
// //       },
      
// //       child: GestureDetector(
// //         onTap: widget.onTap,
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [
// //             // Using Stack for true bidirectional expansion
// //             Container(
// //               width: containerWidth,
// //               height: normalHeight, // Fixed container height is the normal height
// //               child: Stack(
// //                 clipBehavior: Clip.none, // Allow items to overflow the stack
// //                 alignment: Alignment.center,
// //                 children: [
// //                   // Animated container for the image
// //                   AnimatedPositioned(
// //                     duration: const Duration(milliseconds: 400),
// //                     top: isFocused ? -(heightGrowth / 2) : 0, // Move up when focused
// //                     left: 0,
// //                     width: containerWidth,
// //                     height: isFocused ? focusedHeight : normalHeight,
// //                     child: Container(
// //                       decoration: BoxDecoration(
// //                         border: Border.all(
// //                           color: isFocused ? paletteColor : Colors.transparent,
// //                           width: 4.0,
// //                         ),
// //                         boxShadow: isFocused
// //                             ? [
// //                                 BoxShadow(
// //                                   color: paletteColor,
// //                                   blurRadius: 25,
// //                                   spreadRadius: 10,
// //                                 ),
// //                               ]
// //                             : [],
// //                       ),
// //                       child: ClipRRect(
// //                         borderRadius: BorderRadius.circular(4.0),
// //                         child: displayImage(
// //                           widget.imageUrl,
// //                           width: containerWidth,
// //                           height: isFocused ? focusedHeight : normalHeight,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             SizedBox(height: 10),
// //             Container(
// //               width: containerWidth,
// //               child: Text(
// //                 widget.name.toUpperCase(),
// //                 style: TextStyle(
// //                   color: isFocused ? paletteColor : Colors.grey,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //                 textAlign: TextAlign.center,
// //                 overflow: TextOverflow.ellipsis,
// //                 maxLines: 1,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }






// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:provider/provider.dart';

// class FocusableMoviesWidget extends StatefulWidget {
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

//   const FocusableMoviesWidget({
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
//   _FocusableMoviesWidgetState createState() => _FocusableMoviesWidgetState();
// }

// class _FocusableMoviesWidgetState extends State<FocusableMoviesWidget> {
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
//     final double normalHeight = widget.height ?? screenhgt * 0.21;
//     final double focusedHeight = widget.focusedHeight ?? screenhgt * 0.24;
    
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
//         ActivateIntent: CallbackAction<ActivateIntent>(
//           onInvoke: (ActivateIntent intent) {
//             // Handle both cases - up press and normal tap
//             if (widget.onUpPress != null && _focusNode.hasFocus) {
//               widget.onUpPress!();
//             } else {
//               widget.onTap();
//             }
//             return null;
//           },
//         ),
//       },

      
      
//       shortcuts: {
//         // Add this to handle both Enter and Select keys
//         LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
//         LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
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




// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'dart:convert';

// class FocusableMoviesWidget extends StatefulWidget {
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

//   const FocusableMoviesWidget({
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
//   _FocusableMoviesWidgetState createState() => _FocusableMoviesWidgetState();
// }

// class _FocusableMoviesWidgetState extends State<FocusableMoviesWidget> {
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

//   // Custom image display function that handles both network and data images
//   Widget _buildImageWidget(String imageUrl, {required double width, required double height}) {
//     if (imageUrl.startsWith('data:image/')) {
//       // Handle data:image format
//       try {
//         final String base64String = imageUrl.split(',')[1];
//         final Uint8List bytes = base64Decode(base64String);
        
//         return Image.memory(
//           bytes,
//           width: width,
//           height: height,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return Container(
//               width: width,
//               height: height,
//               color: Colors.grey[800],
//               child: Icon(
//                 Icons.error,
//                 color: Colors.white,
//                 size: 30,
//               ),
//             );
//           },
//         );
//       } catch (e) {
//         // If base64 decoding fails, show error container
//         return Container(
//           width: width,
//           height: height,
//           color: Colors.grey[800],
//           child: Icon(
//             Icons.error,
//             color: Colors.white,
//             size: 30,
//           ),
//         );
//       }
//     } else {
//       // Handle network images
//       return CachedNetworkImage(
//         imageUrl: imageUrl,
//         width: width,
//         height: height,
//         fit: BoxFit.cover,
//         placeholder: (context, url) => Container(
//           width: width,
//           height: height,
//           color: Colors.grey[800],
//           child: Center(
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//             ),
//           ),
//         ),
//         errorWidget: (context, url, error) => Container(
//           width: width,
//           height: height,
//           color: Colors.grey[800],
//           child: Icon(
//             Icons.error,
//             color: Colors.white,
//             size: 30,
//           ),
//         ),
//       );
//     }
//   }

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
//         ActivateIntent: CallbackAction<ActivateIntent>(
//           onInvoke: (ActivateIntent intent) {
//             // Handle both cases - up press and normal tap
//             if (widget.onUpPress != null && _focusNode.hasFocus) {
//               widget.onUpPress!();
//             } else {
//               widget.onTap();
//             }
//             return null;
//           },
//         ),
//       },
      
//       shortcuts: {
//         // Add this to handle both Enter and Select keys
//         LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
//         LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
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
//                         child: _buildImageWidget(
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




// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
// import 'package:mobi_tv_entertainment/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/video_widget/video_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mobi_tv_entertainment/widgets/models/news_item_model.dart';
// import 'dart:convert';

// class FocusableMoviesWidget extends StatefulWidget {
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
  
//   // Add these new parameters for fresh data fetch
//   final dynamic movieData; // The current movie data
//   final String? source; // 'isMovieScreen' or other source

//   const FocusableMoviesWidget({
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
//     this.movieData,
//     this.source,
//   });

//   @override
//   _FocusableMoviesWidgetState createState() => _FocusableMoviesWidgetState();
// }

// class _FocusableMoviesWidgetState extends State<FocusableMoviesWidget> {
//   bool isFocused = false;
//   Color paletteColor = Colors.pink;
//   late FocusNode _focusNode;
//   bool _isNavigating = false;

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

//   // Method to fetch fresh movies data
//   Future<List<NewsItemModel>> _fetchFreshMoviesData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String authKey = AuthManager.authKey;
//       if (authKey.isEmpty) {
//         authKey = prefs.getString('auth_key') ?? 'vLQTuPZUxktl5mVW';
//       }

//       final response = await http.get(
//         Uri.parse('https://acomtv.coretechinfo.com/public/api/getAllMovies'),
//         headers: {'auth-key': authKey},
//       ).timeout(Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         List<dynamic> data = json.decode(response.body);
        
//         // Sort data safely
//         if (data.isNotEmpty) {
//           data.sort((a, b) {
//             final aIndex = a['index'];
//             final bIndex = b['index'];
//             if (aIndex == null && bIndex == null) return 0;
//             if (aIndex == null) return 1;
//             if (bIndex == null) return -1;
            
//             int aVal = 0;
//             int bVal = 0;
            
//             if (aIndex is num) {
//               aVal = aIndex.toInt();
//             } else if (aIndex is String) {
//               aVal = int.tryParse(aIndex) ?? 0;
//             }
            
//             if (bIndex is num) {
//               bVal = bIndex.toInt();
//             } else if (bIndex is String) {
//               bVal = int.tryParse(bIndex) ?? 0;
//             }
            
//             return aVal.compareTo(bVal);
//           });
//         }
        
//         // Convert to NewsItemModel
//         return data.map((m) => NewsItemModel(
//           id: m['id'].toString(),
//           name: m['name']?.toString() ?? '',
//           banner: m['banner']?.toString() ?? '',
//           poster: m['poster']?.toString() ?? '',
//           description: m['description']?.toString() ?? '',
//           url: m['url']?.toString() ?? '',
//           streamType: m['streamType']?.toString() ?? '',
//           type: m['type']?.toString() ?? '',
//           genres: m['genres']?.toString() ?? '',
//           status: m['status']?.toString() ?? '',
//           videoId: m['videoId']?.toString() ?? '',
//           index: m['index']?.toString() ?? '',
//           image: '',unUpdatedUrl: '',
//         )).toList();
//       } else {
//         print('Failed to fetch fresh movies: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       print('Error fetching fresh movies data: $e');
//       return [];
//     }
//   }

//   // Updated tap handler with fresh data fetch
//   Future<void> _handleTapWithFreshData() async {
//     if (_isNavigating || widget.movieData == null) return;
//     _isNavigating = true;

//     // Show loading indicator
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async {
//             _isNavigating = false;
//             return true;
//           },
//           child: Center(child: CircularProgressIndicator()),
//         );
//       },
//     );

//     try {
//       // Fetch fresh data
//       List<NewsItemModel> freshMovies = await _fetchFreshMoviesData();
      
//       // Close loading dialog
//       Navigator.of(context, rootNavigator: true).pop();

//       // Handle movie ID conversion safely
//       int movieIdInt;
//       final movieData = widget.movieData;
      
//       if (movieData['id'] is int) {
//         movieIdInt = movieData['id'];
//       } else if (movieData['id'] is String) {
//         try {
//           movieIdInt = int.parse(movieData['id']);
//         } catch (e) {
//           _isNavigating = false;
//           return; // Don't navigate if ID is invalid
//         }
//       } else {
//         _isNavigating = false;
//         return; // Invalid ID, don't navigate
//       }

//       // Navigate to details page with fresh data
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => VideoScreen (
//             // id: movieIdInt,
//             channelList: freshMovies, // Use fresh data
//             source: widget.source ?? 'isMovieScreen',
//             // banner: movieData['banner']?.toString() ?? '',
//             name: movieData['name']?.toString() ?? '',
//              videoUrl: movieData['movie_url'], unUpdatedUrl: movieData['movie_url'], bannerImageUrl: movieData['banner'], startAtPosition: Duration.zero,
//               videoType: '', isLive: false, isVOD: false, isLastPlayedStored: false, isSearch: false, isBannerSlider: false, videoId: null, seasonId: 0, liveStatus: false,
//           ),
//         ),
//       );
//     } catch (e) {
//       // Close loading dialog and show error
//       Navigator.of(context, rootNavigator: true).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading movie: ${e.toString()}')),
//       );
//     } finally {
//       _isNavigating = false;
//     }
//   }

//   // Custom image display function that handles both network and data images
//   Widget _buildImageWidget(String imageUrl, {required double width, required double height}) {
//     if (imageUrl.isEmpty) {
//       return Container(
//         width: width,
//         height: height,
//         color: Colors.grey[800],
//         child: Icon(
//           Icons.image_not_supported,
//           color: Colors.white,
//           size: 30,
//         ),
//       );
//     }

//     if (imageUrl.startsWith('data:image/')) {
//       // Handle data:image format
//       try {
//         if (!imageUrl.contains(',')) {
//           return _buildErrorWidget(width, height);
//         }
        
//         final String base64String = imageUrl.split(',')[1];
//         if (base64String.isEmpty) {
//           return _buildErrorWidget(width, height);
//         }
        
//         final Uint8List bytes = base64Decode(base64String);
        
//         return Image.memory(
//           bytes,
//           width: width,
//           height: height,
//           fit: BoxFit.cover,
//           gaplessPlayback: true,
//           errorBuilder: (context, error, stackTrace) {
//             return _buildErrorWidget(width, height);
//           },
//         );
//       } catch (e) {
//         return Image.asset(localImage);
//       }
//     } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
//       // Handle network images
//       return CachedNetworkImage(
//         imageUrl: imageUrl,
//         width: width,
//         height: height,
//         fit: BoxFit.cover,
//         memCacheWidth: (width * 2).toInt(),
//         memCacheHeight: (height * 2).toInt(),
//         placeholder: (context, url) => Image.asset(localImage),
//         errorWidget: (context, url, error) => Image.asset(localImage),
//       );
//     } else {
//       return _buildErrorWidget(width, height);
//     }
//   }

//   Widget _buildErrorWidget(double width, double height) {
//     return Container(
//       width: width,
//       height: height,
//       color: Colors.grey[800],
//       child: Icon(
//         Icons.broken_image,
//         color: Colors.white,
//         size: 30,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double containerWidth = widget.width ?? screenwdt * 0.19;
//     final double normalHeight = widget.height ?? screenhgt * 0.20;
//     final double focusedHeight = widget.focusedHeight ?? screenhgt * 0.25;
    
//     // Calculate the growth in height when focused (difference between focused and normal height)
//     final double heightGrowth = focusedHeight - normalHeight;

//     return FocusableActionDetector(
//       focusNode: _focusNode,
//       onFocusChange: (hasFocus) {
//         if (hasFocus) {
//           context.read<ColorProvider>().updateColor(paletteColor, true);
//         }
//       },
      
//       actions: {
//         ActivateIntent: CallbackAction<ActivateIntent>(
//           onInvoke: (ActivateIntent intent) {
//             // Handle both cases - up press and normal tap
//             if (widget.onUpPress != null && _focusNode.hasFocus) {
//               widget.onUpPress!();
//             } else {
//               // Use fresh data fetch method instead of original onTap
//               if (widget.movieData != null) {
//                 _handleTapWithFreshData();
//               } else {
//                 widget.onTap(); // Fallback to original onTap if no movieData
//               }
//             }
//             return null;
//           },
//         ),
//       },
      
//       shortcuts: {
//         // Add this to handle both Enter and Select keys
//         LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
//         LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
//       },
      
//       child: GestureDetector(
//         onTap: () {
//           // Use fresh data fetch method for gesture tap too
//           if (widget.movieData != null) {
//             _handleTapWithFreshData();
//           } else {
//             widget.onTap(); // Fallback to original onTap if no movieData
//           }
//         },
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
//                     duration: const Duration(milliseconds: 800),
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
//                         child: _buildImageWidget(
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





import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FocusableMoviesWidget extends StatefulWidget {
  final String imageUrl;
  final String name;
  final VoidCallback onTap; // Keep this as fallback
  final Future<Color> Function(String imageUrl) fetchPaletteColor;
  final FocusNode? focusNode;
  final Function(bool)? onFocusChange;
  final double? width;
  final double? height;
  final double? focusedHeight;
  final VoidCallback? onUpPress;
  
  // Remove duplicate navigation parameters
  final dynamic movieData;
  final String? source;

  const FocusableMoviesWidget({
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
    this.movieData,
    this.source,
  });

  @override
  _FocusableMoviesWidgetState createState() => _FocusableMoviesWidgetState();
}

class _FocusableMoviesWidgetState extends State<FocusableMoviesWidget> {
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

  // Remove the duplicate navigation logic - use parent widget's onTap instead
  void _handleTap() {
    // Simply call the parent's onTap - let parent handle all navigation logic
    widget.onTap();
  }

  Widget _buildImageWidget(String imageUrl, {required double width, required double height}) {
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[800],
        child: Icon(
          Icons.image_not_supported,
          color: Colors.white,
          size: 30,
        ),
      );
    }

    if (imageUrl.startsWith('data:image/')) {
      try {
        if (!imageUrl.contains(',')) {
          return _buildErrorWidget(width, height);
        }
        
        final String base64String = imageUrl.split(',')[1];
        if (base64String.isEmpty) {
          return _buildErrorWidget(width, height);
        }
        
        final Uint8List bytes = base64Decode(base64String);
        
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget(width, height);
          },
        );
      } catch (e) {
        return Container() ;
      }
    } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        memCacheWidth: (width * 2).toInt(),
        memCacheHeight: (height * 2).toInt(),
        placeholder: (context, url) => Image.asset(localImage),
        errorWidget: (context, url, error) => Image.asset(localImage),
      );
    } else {
      return _buildErrorWidget(width, height);
    }
  }

  Widget _buildErrorWidget(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[800],
      child: Icon(
        Icons.broken_image,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double containerWidth = widget.width ?? screenwdt * 0.19;
    final double normalHeight = widget.height ?? screenhgt * 0.20;
    final double focusedHeight = widget.focusedHeight ?? screenhgt * 0.25;
    final double heightGrowth = focusedHeight - normalHeight;

    return FocusableActionDetector(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          context.read<ColorProvider>().updateColor(paletteColor, true);
        }
      },
      
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            if (widget.onUpPress != null && _focusNode.hasFocus) {
              widget.onUpPress!();
            } else {
              _handleTap(); // Use simplified tap handler
            }
            return null;
          },
        ),
      },
      
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
      },
      
      child: GestureDetector(
        onTap: _handleTap, // Use simplified tap handler
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: containerWidth,
              height: normalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 800),
                    top: isFocused ? -(heightGrowth / 2) : 0,
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
                        child: _buildImageWidget(
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