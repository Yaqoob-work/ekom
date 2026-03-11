// // lib/components/provider/smooth_scroll_provider.dart
// import 'dart:async';
// import 'package:flutter/material.dart';

// class SmoothScrollProvider extends ChangeNotifier {
//   // Smooth scroll constants
//   static const int _scrollDurationMs = 350;
//   static const double _itemSpacing = 12.0;
  
//   // Row tracking
//   final List<String> _visibleRows = [];
//   String? _currentFocusedRow;
//   String? _currentFocusedItemId;
//   String? _lastFocusedItemId;
  
//   // Scroll controllers for each row
//   final Map<String, ScrollController> _rowScrollControllers = {};
//   final Map<String, List<String>> _rowItems = {};
//   final Map<String, double> _rowItemWidths = {};
  
//   // Focus nodes for each row's first item
//   final Map<String, FocusNode> _rowFocusNodes = {};
  
//   // Global keys for rows
//   final Map<String, GlobalKey> _rowKeys = {};
  
//   // Animation controllers for smooth transitions
//   final Map<String, AnimationController> _rowGlowControllers = {};
  
//   // Navigation lock
//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;
  
//   // Initial focus flag
//   bool _initialFocusSet = false;
  
//   // Getters
//   String? get currentFocusedRow => _currentFocusedRow;
//   String? get currentFocusedItemId => _currentFocusedItemId;
//   String? get lastFocusedItemId => _lastFocusedItemId;
  
//   // Update visible rows
//   void updateVisibleRows(List<String> rows) {
//     _visibleRows.clear();
//     _visibleRows.addAll(rows);
//     notifyListeners();
//   }
  
//   // Register row key
//   void registerRowKey(String rowId, GlobalKey key) {
//     _rowKeys[rowId] = key;
//   }
  
//   // Register scroll controller for a row
//   void registerRowScrollController(String rowId, ScrollController controller) {
//     _rowScrollControllers[rowId] = controller;
//   }
  
//   // Register items for a row
//   void registerRowItems(String rowId, List<String> itemIds, double itemWidth) {
//     _rowItems[rowId] = itemIds;
//     _rowItemWidths[rowId] = itemWidth;
//   }
  
//   // Register focus node for a row's first item
//   void registerRowFocusNode(String rowId, FocusNode node) {
//     _rowFocusNodes[rowId] = node;
//   }
  
//   // Register glow controller
//   void registerGlowController(String rowId, AnimationController controller) {
//     _rowGlowControllers[rowId] = controller;
//   }
  
//   // Update last focused item
//   void updateLastFocusedItemId(String itemId) {
//     _lastFocusedItemId = itemId;
//   }
  
//   // Set initial focus to first row's first item
//   void setInitialFocus() {
//     if (_initialFocusSet) return;
//     if (_visibleRows.isEmpty) return;
    
//     final firstRow = _visibleRows[0];
//     final focusNode = _rowFocusNodes[firstRow];
    
//     if (focusNode != null) {
//       _initialFocusSet = true;
//       _currentFocusedRow = firstRow;
      
//       Future.delayed(const Duration(milliseconds: 100), () {
//         focusNode.requestFocus();
//         smoothScrollToRow(firstRow);
//       });
//     }
//   }
  
//   // Smooth scroll to row with visual feedback
//   Future<void> smoothScrollToRow(String rowId) async {
//     if (_isNavigationLocked || !_visibleRows.contains(rowId)) return;
    
//     _lockNavigation();
    
//     final key = _rowKeys[rowId];
//     if (key?.currentContext == null) return;
    
//     _currentFocusedRow = rowId;
    
//     // Trigger glow animation
//     _startRowGlowAnimation(rowId);
    
//     // Smooth scroll to row
//     try {
//       await Scrollable.ensureVisible(
//         key!.currentContext!,
//         duration: const Duration(milliseconds: _scrollDurationMs),
//         curve: Curves.easeOutCubic,
//         alignment: 0.1, // Slightly above center
//       );
//     } catch (e) {
//       // Fallback
//     }
    
//     notifyListeners();
//   }
  
//   // Smooth scroll to item within a row
//   void smoothScrollToItem(String rowId, String itemId) {
//     final controller = _rowScrollControllers[rowId];
//     final items = _rowItems[rowId];
//     final itemWidth = _rowItemWidths[rowId];
    
//     if (controller == null || items == null || itemWidth == null) return;
    
//     final index = items.indexOf(itemId);
//     if (index == -1) return;
    
//     final targetOffset = index * (itemWidth + _itemSpacing);
    
//     controller.animateTo(
//       targetOffset.clamp(0.0, controller.position.maxScrollExtent),
//       duration: const Duration(milliseconds: _scrollDurationMs),
//       curve: Curves.easeOutCubic,
//     );
    
//     _currentFocusedItemId = itemId;
//     notifyListeners();
//   }
  
//   // Navigate to next row
//   void navigateToNextRow() {
//     if (_isNavigationLocked) return;
//     if (_currentFocusedRow == null || _visibleRows.isEmpty) return;
    
//     final currentIndex = _visibleRows.indexOf(_currentFocusedRow!);
//     if (currentIndex < _visibleRows.length - 1) {
//       final nextRow = _visibleRows[currentIndex + 1];
//       smoothScrollToRow(nextRow);
      
//       // Focus the first item of next row after scroll
//       Future.delayed(const Duration(milliseconds: 100), () {
//         final focusNode = _rowFocusNodes[nextRow];
//         if (focusNode != null && focusNode.canRequestFocus) {
//           focusNode.requestFocus();
//         }
//       });
//     }
//   }
  
//   // Navigate to previous row
//   void navigateToPreviousRow() {
//     if (_isNavigationLocked) return;
//     if (_currentFocusedRow == null || _visibleRows.isEmpty) return;
    
//     final currentIndex = _visibleRows.indexOf(_currentFocusedRow!);
//     if (currentIndex > 0) {
//       final prevRow = _visibleRows[currentIndex - 1];
//       smoothScrollToRow(prevRow);
      
//       // Focus the first item of previous row after scroll
//       Future.delayed(const Duration(milliseconds: 100), () {
//         final focusNode = _rowFocusNodes[prevRow];
//         if (focusNode != null && focusNode.canRequestFocus) {
//           focusNode.requestFocus();
//         }
//       });
//     }
//   }
  
//   // Restore focus after navigation
//   void restoreFocus() {
//     if (_lastFocusedItemId == null) return;
    
//     // Find which row contains this item
//     String? targetRow;
//     String? targetItem;
    
//     for (var entry in _rowItems.entries) {
//       if (entry.value.contains(_lastFocusedItemId)) {
//         targetRow = entry.key;
//         targetItem = _lastFocusedItemId;
//         break;
//       }
//     }
    
//     if (targetRow != null && targetItem != null) {
//       // First scroll to row
//       smoothScrollToRow(targetRow);
      
//       // Then focus the item
//       Future.delayed(const Duration(milliseconds: 200), () {
//         final focusNode = _rowFocusNodes[targetRow];
//         if (focusNode != null) {
//           focusNode.requestFocus();
//         }
//         smoothScrollToItem(targetRow!, targetItem!);
//       });
//     }
//   }
  
//   // Navigation lock
//   void _lockNavigation() {
//     _isNavigationLocked = true;
//     _navigationLockTimer?.cancel();
//     _navigationLockTimer = Timer(const Duration(milliseconds: 400), () {
//       _isNavigationLocked = false;
//     });
//   }
  
//   // Row glow animation
//   void _startRowGlowAnimation(String rowId) {
//     final controller = _rowGlowControllers[rowId];
//     if (controller != null) {
//       controller.forward().then((_) {
//         controller.reverse();
//       });
//     }
//   }
  
//   @override
//   void dispose() {
//     _navigationLockTimer?.cancel();
//     for (var controller in _rowGlowControllers.values) {
//       controller.dispose();
//     }
//     for (var controller in _rowScrollControllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
// }