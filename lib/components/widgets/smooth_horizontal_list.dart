// // lib/components/widgets/smooth_horizontal_list.dart
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import '../provider/smooth_scroll_provider.dart';

// class SmoothHorizontalList<T> extends StatefulWidget {
//   final String rowId;
//   final List<T> items;
//   final String Function(T) itemId;
//   final Widget Function(T, int, bool) itemBuilder;
//   final double itemWidth;
//   final double itemHeight;
//   final double focusedItemHeight;
//   final VoidCallback? onViewAllTap;
//   final bool showViewAll;
//   final Widget? viewAllBuilder;

//   const SmoothHorizontalList({
//     Key? key,
//     required this.rowId,
//     required this.items,
//     required this.itemId,
//     required this.itemBuilder,
//     required this.itemWidth,
//     required this.itemHeight,
//     required this.focusedItemHeight,
//     this.onViewAllTap,
//     this.showViewAll = false,
//     this.viewAllBuilder,
//   }) : super(key: key);

//   @override
//   State<SmoothHorizontalList> createState() => _SmoothHorizontalListState<T>();
// }

// class _SmoothHorizontalListState<T> extends State<SmoothHorizontalList<T>> 
//     with AutomaticKeepAliveClientMixin {
//   late ScrollController _scrollController;
//   final Map<String, FocusNode> _itemFocusNodes = {};
//   String? _focusedItemId;
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;
//   bool _isRegistered = false;

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
    
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _registerWithProvider();
//     });
//   }

//   void _registerWithProvider() {
//     if (_isRegistered) return;
//     _isRegistered = true;
    
//     final provider = context.read<SmoothScrollProvider>();
    
//     // Register scroll controller
//     provider.registerRowScrollController(widget.rowId, _scrollController);
    
//     // Register items
//     final itemIds = widget.items.map((item) => widget.itemId(item)).toList();
//     provider.registerRowItems(widget.rowId, itemIds, widget.itemWidth);
    
//     // Create and register focus node for first item
//     if (widget.items.isNotEmpty) {
//       final firstId = widget.itemId(widget.items.first);
//       final firstNode = FocusNode(debugLabel: '${widget.rowId}_$firstId');
//       _itemFocusNodes[firstId] = firstNode;
//       provider.registerRowFocusNode(widget.rowId, firstNode);
      
//       // Add listener for first item
//       firstNode.addListener(() {
//         if (firstNode.hasFocus) {
//           setState(() => _focusedItemId = firstId);
//           provider.smoothScrollToItem(widget.rowId, firstId);
//           provider.updateLastFocusedItemId(firstId);
//         }
//       });
//     }
    
//     // Create focus nodes for other items
//     for (int i = 1; i < widget.items.length; i++) {
//       final itemId = widget.itemId(widget.items[i]);
//       final node = FocusNode(debugLabel: '${widget.rowId}_$itemId');
//       _itemFocusNodes[itemId] = node;
      
//       node.addListener(() {
//         if (node.hasFocus) {
//           setState(() => _focusedItemId = itemId);
//           provider.smoothScrollToItem(widget.rowId, itemId);
//           provider.updateLastFocusedItemId(itemId);
//         }
//       });
//     }
    
//     // Create view all focus node if needed
//     if (widget.showViewAll && widget.onViewAllTap != null) {
//       final viewAllId = '${widget.rowId}_view_all';
//       final viewAllNode = FocusNode(debugLabel: viewAllId);
//       _itemFocusNodes[viewAllId] = viewAllNode;
      
//       viewAllNode.addListener(() {
//         if (viewAllNode.hasFocus) {
//           setState(() => _focusedItemId = viewAllId);
//           provider.updateLastFocusedItemId(viewAllId);
//         }
//       });
//     }
    
//     // Try to set initial focus for the first row
//     if (widget.rowId == 'liveChannelLanguage' && widget.items.isNotEmpty) {
//       Future.delayed(const Duration(milliseconds: 200), () {
//         if (mounted) {
//           final firstNode = _itemFocusNodes[widget.itemId(widget.items.first)];
//           firstNode?.requestFocus();
//           provider.setInitialFocus();
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     for (var node in _itemFocusNodes.values) {
//       node.dispose();
//     }
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
    
//     return NotificationListener<ScrollNotification>(
//       onNotification: (notification) {
//         if (notification is ScrollStartNotification) {
//           setState(() => _isNavigationLocked = true);
//           _navigationLockTimer?.cancel();
//           _navigationLockTimer = Timer(const Duration(milliseconds: 300), () {
//             if (mounted) setState(() => _isNavigationLocked = false);
//           });
//         }
//         return false;
//       },
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         controller: _scrollController,
//         physics: const ClampingScrollPhysics(),
//         itemCount: widget.items.length + (widget.showViewAll ? 1 : 0),
//         itemBuilder: (context, index) {
//           if (widget.showViewAll && index == widget.items.length) {
//             return _buildViewAllItem();
//           }
          
//           final item = widget.items[index];
//           final itemId = widget.itemId(item);
          
//           return _buildListItem(item, itemId, index);
//         },
//       ),
//     );
//   }

//   Widget _buildListItem(T item, String itemId, int index) {
//     final isFocused = _focusedItemId == itemId;
//     final focusNode = _itemFocusNodes[itemId];
    
//     if (focusNode == null) return const SizedBox.shrink();

//     return Focus(
//       focusNode: focusNode,
//       onKey: (node, event) => _handleKeyEvent(event, index, itemId),
//       child: GestureDetector(
//         onTap: () => _handleItemTap(item),
//         child: widget.itemBuilder(item, index, isFocused),
//       ),
//     );
//   }

//   Widget _buildViewAllItem() {
//     if (widget.onViewAllTap == null) return const SizedBox.shrink();
    
//     final viewAllId = '${widget.rowId}_view_all';
//     final isFocused = _focusedItemId == viewAllId;
//     final focusNode = _itemFocusNodes[viewAllId];
    
//     if (focusNode == null) return const SizedBox.shrink();

//     return Focus(
//       focusNode: focusNode,
//       onKey: (node, event) => _handleViewAllKeyEvent(event),
//       child: GestureDetector(
//         onTap: widget.onViewAllTap,
//         child: widget.viewAllBuilder != null
//             ? widget.viewAllBuilder!
//             : _defaultViewAllBuilder(isFocused),
//       ),
//     );
//   }

//   Widget _defaultViewAllBuilder(bool isFocused) {
//     return Container(
//       width: widget.itemWidth,
//       margin: const EdgeInsets.symmetric(horizontal: 6),
//       child: Column(
//         children: [
//           Container(
//             height: isFocused ? widget.focusedItemHeight : widget.itemHeight,
//             decoration: BoxDecoration(
//               color: Colors.grey[800],
//               borderRadius: BorderRadius.circular(12),
//               border: isFocused
//                   ? Border.all(color: Colors.blue, width: 3)
//                   : null,
//               boxShadow: isFocused ? [
//                 BoxShadow(
//                   color: Colors.blue.withOpacity(0.4),
//                   blurRadius: 20,
//                   spreadRadius: 5,
//                 ),
//               ] : null,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.grid_view,
//                   color: isFocused ? Colors.blue : Colors.white,
//                   size: 40,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'VIEW ALL',
//                   style: TextStyle(
//                     color: isFocused ? Colors.blue : Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'SEE ALL',
//             style: TextStyle(
//               color: isFocused ? Colors.blue : Colors.grey,
//               fontSize: isFocused ? 13 : 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   KeyEventResult _handleKeyEvent(RawKeyEvent event, int index, String itemId) {
//     if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
//     if (_isNavigationLocked) return KeyEventResult.handled;

//     if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//       if (index < widget.items.length - 1) {
//         final nextId = widget.itemId(widget.items[index + 1]);
//         _itemFocusNodes[nextId]?.requestFocus();
//       } else if (widget.showViewAll) {
//         final viewAllId = '${widget.rowId}_view_all';
//         _itemFocusNodes[viewAllId]?.requestFocus();
//       }
//       return KeyEventResult.handled;
//     }

//     if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       if (index > 0) {
//         final prevId = widget.itemId(widget.items[index - 1]);
//         _itemFocusNodes[prevId]?.requestFocus();
//       }
//       return KeyEventResult.handled;
//     }

//     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       context.read<SmoothScrollProvider>().navigateToPreviousRow();
//       return KeyEventResult.handled;
//     }

//     if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       context.read<SmoothScrollProvider>().navigateToNextRow();
//       return KeyEventResult.handled;
//     }

//     return KeyEventResult.ignored;
//   }

//   KeyEventResult _handleViewAllKeyEvent(RawKeyEvent event) {
//     if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
//     if (_isNavigationLocked) return KeyEventResult.handled;

//     if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//       if (widget.items.isNotEmpty) {
//         final lastId = widget.itemId(widget.items.last);
//         _itemFocusNodes[lastId]?.requestFocus();
//       }
//       return KeyEventResult.handled;
//     }

//     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       context.read<SmoothScrollProvider>().navigateToPreviousRow();
//       return KeyEventResult.handled;
//     }

//     if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       context.read<SmoothScrollProvider>().navigateToNextRow();
//       return KeyEventResult.handled;
//     }

//     if (event.logicalKey == LogicalKeyboardKey.enter ||
//         event.logicalKey == LogicalKeyboardKey.select) {
//       widget.onViewAllTap?.call();
//       return KeyEventResult.handled;
//     }

//     return KeyEventResult.ignored;
//   }

//   void _handleItemTap(T item) {
//     // Override in child classes
//   }
// }