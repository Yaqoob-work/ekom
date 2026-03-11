// // lib/components/widgets/smooth_scroll_row.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../provider/smooth_scroll_provider.dart';

// class SmoothScrollRow extends StatefulWidget {
//   final String rowId;
//   final double height;
//   final Widget child;
//   final GlobalKey? rowKey;

//   const SmoothScrollRow({
//     Key? key,
//     required this.rowId,
//     required this.height,
//     required this.child,
//     this.rowKey,
//   }) : super(key: key);

//   @override
//   State<SmoothScrollRow> createState() => _SmoothScrollRowState();
// }

// class _SmoothScrollRowState extends State<SmoothScrollRow> 
//     with SingleTickerProviderStateMixin {
//   late AnimationController _glowController;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _glowController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
    
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = context.read<SmoothScrollProvider>();
//       provider.registerGlowController(widget.rowId, _glowController);
//       if (widget.rowKey != null) {
//         provider.registerRowKey(widget.rowId, widget.rowKey!);
//       }
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final provider = context.watch<SmoothScrollProvider>();
//     final isCurrentRow = provider.currentFocusedRow == widget.rowId;
    
//     if (isCurrentRow != _isFocused) {
//       setState(() => _isFocused = isCurrentRow);
//       if (isCurrentRow) {
//         _glowController.forward();
//       } else {
//         _glowController.reverse();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       key: widget.rowKey,
//       duration: const Duration(milliseconds: 200),
//       height: widget.height,
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(
//             color: _isFocused 
//                 ? Colors.white.withOpacity(0.2) 
//                 : Colors.transparent,
//             width: 1,
//           ),
//           bottom: BorderSide(
//             color: _isFocused 
//                 ? Colors.white.withOpacity(0.2) 
//                 : Colors.transparent,
//             width: 1,
//           ),
//         ),
//       ),
//       child: Stack(
//         children: [
//           widget.child,
          
//           // Top glow indicator
//           if (_isFocused)
//             Positioned(
//               left: 0,
//               right: 0,
//               top: 0,
//               child: FadeTransition(
//                 opacity: _glowController,
//                 child: Container(
//                   height: 2,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.transparent,
//                         Colors.white.withOpacity(0.5),
//                         Colors.transparent,
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
            
//           // Bottom glow indicator
//           if (_isFocused)
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: FadeTransition(
//                 opacity: _glowController,
//                 child: Container(
//                   height: 2,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.transparent,
//                         Colors.white.withOpacity(0.5),
//                         Colors.transparent,
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _glowController.dispose();
//     super.dispose();
//   }
// }