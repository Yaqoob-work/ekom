// import 'package:flutter/material.dart';

// class CommonSliderPage extends StatelessWidget {
//   final Color backgroundColor;
//   final FocusNode focusNode;
//   final FocusOnKeyCallback? onKey;
//   final Widget background;
//   final bool isLoading;
//   final Widget loadingWidget;
//   final Widget? errorWidget;
//   final Widget content;
//   final Widget? overlay;

//   const CommonSliderPage({
//     super.key,
//     required this.backgroundColor,
//     required this.focusNode,
//     this.onKey,
//     required this.background,
//     required this.isLoading,
//     required this.loadingWidget,
//     required this.content,
//     this.errorWidget,
//     this.overlay,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: Focus(
//         focusNode: focusNode,
//         autofocus: true,
//         onKey: onKey,
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             background,
//             if (isLoading)
//               loadingWidget
//             else if (errorWidget != null)
//               errorWidget!
//             else
//               content,
//             if (overlay != null) overlay!,
//           ],
//         ),
//       ),
//     );
//   }
// }
