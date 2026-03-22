// import 'dart:async';
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';
// import 'package:mobi_tv_entertainment/components/widgets/smart_style_image_card.dart';

// class ProfessionalColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
//   static const accentOrange = Color(0xFFF59E0B);
//   static const accentPurple = Color(0xFF8B5CF6);
// }

// class AnimationTiming {
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
// }

// class MasterSliderLayout<T> extends StatefulWidget {
//   final String title;
//   final String logoUrl;
//   final bool isLoading;
//   final bool isListLoading; 
//   final bool isVideoLoading;
//   final String? errorMessage;
//   final VoidCallback onRetry;

//   final List<String> networkNames;
//   final int selectedNetworkIndex;
//   final Function(int)? onNetworkSelected;

//   final List<String> filterNames;
//   final int selectedFilterIndex;
//   final Function(int) onFilterSelected;
//   final Function(String) onSearch;

//   final List<T> contentList;
//   final Function(T, int) onContentTap;
//   final String Function(T) getTitle;
//   final String Function(T) getImageUrl;

//   final List<String> sliderImages;
//   final List<Color> focusColors;
//   final IconData placeholderIcon;
//   final String emptyMessage;
//   final double cardWidth;
//   final double cardHeight;

//   const MasterSliderLayout({
//     Key? key, required this.title, required this.logoUrl, required this.isLoading, this.isListLoading = false, required this.isVideoLoading, this.errorMessage, required this.onRetry, required this.networkNames, required this.selectedNetworkIndex, this.onNetworkSelected, required this.filterNames, required this.selectedFilterIndex, required this.onFilterSelected, required this.onSearch, required this.contentList, required this.onContentTap, required this.getTitle, required this.getImageUrl, required this.sliderImages, required this.focusColors, required this.placeholderIcon, required this.emptyMessage, required this.cardWidth, required this.cardHeight,
//   }) : super(key: key);

//   @override
//   State<MasterSliderLayout<T>> createState() => _MasterSliderLayoutState<T>();
// }

// class _MasterSliderLayoutState<T> extends State<MasterSliderLayout<T>> with SingleTickerProviderStateMixin {
//   bool _isDisposed = false;
//   bool _shouldFocusFirstItem = false; 

//   final FocusNode _widgetFocusNode = FocusNode();
//   late FocusNode _searchButtonFocusNode;
//   List<FocusNode> _networkFocusNodes = [];
//   List<FocusNode> _filterFocusNodes = [];
//   List<FocusNode> _itemFocusNodes = [];
//   List<FocusNode> _keyboardFocusNodes = [];

//   final ScrollController _networkScrollController = ScrollController();
//   final ScrollController _filterScrollController = ScrollController();
//   final ScrollController _itemScrollController = ScrollController();

//   late PageController _sliderPageController;
//   int _currentSliderPage = 0;
//   Timer? _sliderTimer;
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   bool _isSearching = false;
//   bool _showKeyboard = false;
//   String _searchText = '';
//   Timer? _debounce;
//   int _focusedKeyRow = 0;
//   int _focusedKeyCol = 0;
//   int _focusedItemIndex = -1;

//   final List<List<String>> _keyboardLayout = [
//     "1234567890".split(''), "qwertyuiop".split(''), "asdfghjkl".split(''), ["z", "x", "c", "v", "b", "n", "m", "DEL"], ["SPACE", "OK"],
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _isDisposed = false;
//     _sliderPageController = PageController();
//     _searchButtonFocusNode = FocusNode()..addListener(_setStateListener);
//     _widgetFocusNode.addListener(_setStateListener);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && !_isDisposed) Provider.of<InternalFocusProvider>(context, listen: false).updateName('');
//     });

//     _fadeController = AnimationController(duration: AnimationTiming.medium, vsync: this);
//     _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    
//     _initializeAllFocusNodes();
//     _setupSliderTimer();
//     _fadeController.forward();
//   }

//   // Helper to get keyboard flat index
//   int _getKeyboardNodeIndex(int row, int col) {
//     int idx = 0;
//     for (int i = 0; i < row; i++) idx += _keyboardLayout[i].length;
//     return idx + col;
//   }

//   @override
//   void didUpdateWidget(covariant MasterSliderLayout<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
    
//     // 🔥 FIX 1: Only rebuild specific nodes when THEIR list changes. 
//     // DO NOT rebuild keyboard nodes. This keeps focus intact while typing!
//     bool dataChanged = false;

//     if (oldWidget.contentList.length != widget.contentList.length) {
//       _disposeFocusNodes(_itemFocusNodes);
//       _itemFocusNodes = List.generate(widget.contentList.length, (i) => FocusNode()..addListener(_setStateListener));
//       _focusedItemIndex = -1;
//       dataChanged = true;
//     }
//     if (oldWidget.filterNames.length != widget.filterNames.length) {
//       _disposeFocusNodes(_filterFocusNodes);
//       _filterFocusNodes = List.generate(widget.filterNames.length, (i) => FocusNode()..addListener(_setStateListener));
//       dataChanged = true;
//     }
//     if (oldWidget.networkNames.length != widget.networkNames.length) {
//       _disposeFocusNodes(_networkFocusNodes);
//       _networkFocusNodes = List.generate(widget.networkNames.length, (i) => FocusNode()..addListener(_setStateListener));
//       dataChanged = true;
//     }
    
//     if (oldWidget.sliderImages != widget.sliderImages) {
//       _setupSliderTimer();
//     }

//     bool justFinishedPageLoad = oldWidget.isLoading == true && widget.isLoading == false;
//     bool justFinishedListLoad = oldWidget.isListLoading == true && widget.isListLoading == false;
//     bool contentAppeared = oldWidget.contentList.isEmpty && widget.contentList.isNotEmpty;

//     // 🔥 Auto-focus logic (Doesn't steal focus from Keyboard now)
//     if ((justFinishedPageLoad || justFinishedListLoad || contentAppeared || _shouldFocusFirstItem) && !_showKeyboard) {
      
//       if (_shouldFocusFirstItem && !widget.isListLoading && !widget.isLoading) {
//         _shouldFocusFirstItem = false; 
//       }

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!_isDisposed && mounted && !_showKeyboard) {
//            if (widget.contentList.isNotEmpty && _itemFocusNodes.isNotEmpty) {
//               Future.delayed(const Duration(milliseconds: 150), () {
//                 if (!_isDisposed && mounted && _itemFocusNodes.isNotEmpty && !_showKeyboard) {
//                   setState(() => _focusedItemIndex = 0);
//                   _itemFocusNodes[0].requestFocus();
//                   _scrollToFocus(_itemScrollController, 0, widget.cardWidth + 15);
//                   Provider.of<InternalFocusProvider>(context, listen: false).updateName(widget.getTitle(widget.contentList[0]));
//                 }
//               });
//            } else if (justFinishedPageLoad && widget.networkNames.isNotEmpty && _networkFocusNodes.isNotEmpty) {
//               _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//            } else if (justFinishedPageLoad && _searchButtonFocusNode.canRequestFocus) {
//               _searchButtonFocusNode.requestFocus();
//            }
//         }
//       });
//     }
//   }

//   void _initializeAllFocusNodes() {
//     _networkFocusNodes = List.generate(widget.networkNames.length, (i) => FocusNode()..addListener(_setStateListener));
//     _filterFocusNodes = List.generate(widget.filterNames.length, (i) => FocusNode()..addListener(_setStateListener));
//     _itemFocusNodes = List.generate(widget.contentList.length, (i) => FocusNode()..addListener(_setStateListener));
//     int totalKeys = _keyboardLayout.fold(0, (prev, row) => prev + row.length);
//     _keyboardFocusNodes = List.generate(totalKeys, (i) => FocusNode()..addListener(_setStateListener));
//   }

//   void _setStateListener() {
//     if (mounted && !_isDisposed) setState(() {});
//   }

//   void _disposeFocusNodes(List<FocusNode> nodes) {
//     for (var node in nodes) { node.removeListener(_setStateListener); try { node.dispose(); } catch (_) {} }
//     nodes.clear();
//   }

//   @override
//   void dispose() {
//     _isDisposed = true;
//     _sliderTimer?.cancel();
//     _debounce?.cancel();
//     _navigationLockTimer?.cancel();
//     _sliderPageController.dispose();
//     _fadeController.dispose();
//     _widgetFocusNode.dispose();
//     _searchButtonFocusNode.dispose();
//     _networkScrollController.dispose();
//     _filterScrollController.dispose();
//     _itemScrollController.dispose();
//     _disposeFocusNodes(_networkFocusNodes);
//     _disposeFocusNodes(_filterFocusNodes);
//     _disposeFocusNodes(_itemFocusNodes);
//     _disposeFocusNodes(_keyboardFocusNodes);
//     super.dispose();
//   }

//   void _setupSliderTimer() {
//     _sliderTimer?.cancel();
//     if (widget.sliderImages.length > 1) {
//       _sliderTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
//         if (!_isDisposed && mounted && _sliderPageController.hasClients) {
//           int next = (_sliderPageController.page?.round() ?? 0) + 1;
//           if (next >= widget.sliderImages.length) next = 0;
//           _sliderPageController.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
//         }
//       });
//     }
//   }

//   void _scrollToFocus(ScrollController controller, int index, double itemWidth) {
//     if (!controller.hasClients) return;
//     double screenWidth = MediaQuery.of(context).size.width;
//     double offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
//     controller.animateTo(offset.clamp(0.0, controller.position.maxScrollExtent), duration: AnimationTiming.fast, curve: Curves.easeInOut);
//   }

//   KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
//     if (_isDisposed || event is! RawKeyDownEvent || widget.isLoading) return KeyEventResult.ignored;

//     final key = event.logicalKey;
//     if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape) {
//       if (_showKeyboard) {
//         setState(() { _showKeyboard = false; _focusedKeyRow = 0; _focusedKeyCol = 0; });
//         _searchButtonFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (_itemFocusNodes.any((n) => n.hasFocus) || _filterFocusNodes.any((n) => n.hasFocus) || _searchButtonFocusNode.hasFocus) {
//         if (_networkFocusNodes.isNotEmpty) _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.ignored;
//     }

//     if (_showKeyboard && _keyboardFocusNodes.any((n) => n.hasFocus)) return _navigateKeyboard(key);
//     if (_searchButtonFocusNode.hasFocus) return _navigateSearchBtn(key);
//     if (_networkFocusNodes.any((n) => n.hasFocus)) return _navigateNetworks(key);
//     if (_filterFocusNodes.any((n) => n.hasFocus)) return _navigateFilters(key);
//     if (_itemFocusNodes.any((n) => n.hasFocus)) return _navigateItems(key);

//     return KeyEventResult.ignored;
//   }

//   // 🔥 FIX 2: PRECISE KEYBOARD ROUTING
//   KeyEventResult _navigateKeyboard(LogicalKeyboardKey key) {
//     int r = _focusedKeyRow, c = _focusedKeyCol;
    
//     if (key == LogicalKeyboardKey.arrowUp) {
//       if (r > 0) { 
//         r--; c = math.min(c, _keyboardLayout[r].length - 1); 
//       } else {
//         // First row se ArrowUp -> Top Network Bar par bhejo
//         if (_networkFocusNodes.isNotEmpty) {
//           _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//         }
//         return KeyEventResult.handled;
//       }
//     }
//     else if (key == LogicalKeyboardKey.arrowDown) {
//       if (r < _keyboardLayout.length - 1) { 
//         r++; c = math.min(c, _keyboardLayout[r].length - 1); 
//       } else {
//         // Last row se ArrowDown -> Genre Bar/Search Button par bhejo
//         if (_filterFocusNodes.isNotEmpty) {
//           int targetFilter = widget.selectedFilterIndex >= 0 ? widget.selectedFilterIndex : 0;
//           _filterFocusNodes[targetFilter].requestFocus();
//         } else {
//           _searchButtonFocusNode.requestFocus();
//         }
//         return KeyEventResult.handled;
//       }
//     }
//     else if (key == LogicalKeyboardKey.arrowLeft && c > 0) c--;
//     else if (key == LogicalKeyboardKey.arrowRight && c < _keyboardLayout[r].length - 1) c++;
//     else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _handleKeyClick(_keyboardLayout[r][c]);
//       return KeyEventResult.handled;
//     }

//     if (r != _focusedKeyRow || c != _focusedKeyCol) {
//       setState(() { _focusedKeyRow = r; _focusedKeyCol = c; });
//       int idx = _getKeyboardNodeIndex(r, c);
//       if (idx < _keyboardFocusNodes.length) _keyboardFocusNodes[idx].requestFocus();
//     }
//     return KeyEventResult.handled;
//   }

//   void _handleKeyClick(String val) {
//     setState(() {
//       if (val == "OK") { 
//         _showKeyboard = false; 
//         _debounce?.cancel();
//         widget.onSearch(_searchText.trim()); // Execute immediately
//         // Focus first item when data arrives, managed by _shouldFocusFirstItem
//         _shouldFocusFirstItem = true;
//         _searchButtonFocusNode.requestFocus(); // Temp park
//       } 
//       else {
//         if (val == "DEL") { if (_searchText.isNotEmpty) _searchText = _searchText.substring(0, _searchText.length - 1); } 
//         else if (val == "SPACE") { _searchText += " "; } 
//         else { _searchText += val; }
        
//         _isSearching = _searchText.isNotEmpty;
        
//         // 10 Second debounce logic (Focus stays on keyboard!)
//         _debounce?.cancel();
//         _debounce = Timer(const Duration(seconds: 10), () {
//           if (mounted && _showKeyboard) widget.onSearch(_searchText.trim());
//         });
//       }
//     });
//   }

//   KeyEventResult _navigateSearchBtn(LogicalKeyboardKey key) {
//     if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       setState(() => _showKeyboard = true);
//       if (_keyboardFocusNodes.isNotEmpty) _keyboardFocusNodes[0].requestFocus();
//     } else if (key == LogicalKeyboardKey.arrowRight && _filterFocusNodes.isNotEmpty) {
//       _filterFocusNodes[0].requestFocus();
//     } else if (key == LogicalKeyboardKey.arrowUp) {
//       if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
//          // Keyboard open hai to ArrowUp keyboard ki aakhri row pe le jayega
//          setState(() { _focusedKeyRow = _keyboardLayout.length - 1; _focusedKeyCol = 0; });
//          _keyboardFocusNodes[_getKeyboardNodeIndex(_focusedKeyRow, _focusedKeyCol)].requestFocus();
//       } else if (_networkFocusNodes.isNotEmpty) {
//         _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//       }
//     } else if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
//       setState(() => _focusedItemIndex = 0);
//       _itemFocusNodes[0].requestFocus();
//     }
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateNetworks(LogicalKeyboardKey key) {
//     int focusedIndex = _networkFocusNodes.indexWhere((n) => n.hasFocus);
//     if (focusedIndex == -1) focusedIndex = widget.selectedNetworkIndex;

//     if (key == LogicalKeyboardKey.arrowLeft && focusedIndex > 0) focusedIndex--;
//     else if (key == LogicalKeyboardKey.arrowRight && focusedIndex < _networkFocusNodes.length - 1) focusedIndex++;
//     else if (key == LogicalKeyboardKey.arrowDown) {
//       if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
//         // Keyboard open hai to ArrowDown pehli row pe le jayega
//         setState(() { _focusedKeyRow = 0; _focusedKeyCol = 0; });
//         _keyboardFocusNodes[0].requestFocus();
//       } else {
//         _searchButtonFocusNode.requestFocus();
//       }
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _shouldFocusFirstItem = true; // Auto-focus flag
//       if (widget.onNetworkSelected != null) widget.onNetworkSelected!(focusedIndex);
//       return KeyEventResult.handled;
//     }
    
//     if (focusedIndex != _networkFocusNodes.indexWhere((n) => n.hasFocus)) {
//       _networkFocusNodes[focusedIndex].requestFocus();
//       _scrollToFocus(_networkScrollController, focusedIndex, 160);
//     }
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateFilters(LogicalKeyboardKey key) {
//     int focusedIndex = _filterFocusNodes.indexWhere((n) => n.hasFocus);
//     if (focusedIndex == -1) focusedIndex = widget.selectedFilterIndex; 

//     if (key == LogicalKeyboardKey.arrowLeft) {
//       if (focusedIndex > 0) focusedIndex--; else { _searchButtonFocusNode.requestFocus(); return KeyEventResult.handled; }
//     } else if (key == LogicalKeyboardKey.arrowRight && focusedIndex < _filterFocusNodes.length - 1) focusedIndex++;
//     else if (key == LogicalKeyboardKey.arrowUp) {
//       if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
//          // Keyboard open hai to ArrowUp keyboard ki aakhri row pe le jayega
//          setState(() { _focusedKeyRow = _keyboardLayout.length - 1; _focusedKeyCol = 0; });
//          _keyboardFocusNodes[_getKeyboardNodeIndex(_focusedKeyRow, _focusedKeyCol)].requestFocus();
//       } else if (_networkFocusNodes.isNotEmpty) {
//         _networkFocusNodes[widget.selectedNetworkIndex].requestFocus(); 
//       }
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
//       setState(() => _focusedItemIndex = 0);
//       _itemFocusNodes[0].requestFocus(); 
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _shouldFocusFirstItem = true; // Auto-focus flag
//       widget.onFilterSelected(focusedIndex);
//       return KeyEventResult.handled;
//     }

//     if (focusedIndex != _filterFocusNodes.indexWhere((n) => n.hasFocus)) {
//       _filterFocusNodes[focusedIndex].requestFocus();
//       _scrollToFocus(_filterScrollController, focusedIndex, 160);
//     }
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateItems(LogicalKeyboardKey key) {
//     if (_isNavigationLocked) return KeyEventResult.handled;
//     _isNavigationLocked = true;
//     _navigationLockTimer = Timer(const Duration(milliseconds: 300), () { if (mounted) setState(() => _isNavigationLocked = false); });

//     int i = _focusedItemIndex;
//     if (key == LogicalKeyboardKey.arrowUp) {
//       if (_filterFocusNodes.isNotEmpty && widget.selectedFilterIndex >= 0) _filterFocusNodes[widget.selectedFilterIndex].requestFocus();
//       else _searchButtonFocusNode.requestFocus();
//       setState(() => _focusedItemIndex = -1);
//       _isNavigationLocked = false;
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.arrowLeft && i > 0) i--;
//     else if (key == LogicalKeyboardKey.arrowRight && i < _itemFocusNodes.length - 1) i++;
//     else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _isNavigationLocked = false;
//       widget.onContentTap(widget.contentList[i], i);
//       return KeyEventResult.handled;
//     }

//     if (i != _focusedItemIndex && i >= 0 && i < _itemFocusNodes.length) {
//       setState(() => _focusedItemIndex = i);
//       _itemFocusNodes[i].requestFocus();
//       _scrollToFocus(_itemScrollController, i, widget.cardWidth + 15);
//       Provider.of<InternalFocusProvider>(context, listen: false).updateName(widget.getTitle(widget.contentList[i]));
//     } else {
//       _isNavigationLocked = false;
//     }
//     return KeyEventResult.handled;
//   }

//   // ==========================================================
//   // BUILD UI
//   // ==========================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Focus(
//         focusNode: _widgetFocusNode,
//         autofocus: true,
//         onKey: _onKeyHandler,
//         child: Stack(
//           children: [
//             _buildBackgroundSlider(),
            
//             // Ensure UI Shell is always visible
//             FadeTransition(
//               opacity: _fadeAnimation,
//               child: Column(
//                 children: [
//                   if (widget.networkNames.isNotEmpty) _buildTopFilterBar(),
//                   if (widget.networkNames.isEmpty) ...[
//                      SizedBox(height: MediaQuery.of(context).padding.top + 20),
//                      _buildBeautifulAppBar(),
//                   ],
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(height: MediaQuery.of(context).size.height * 0.45, child: _showKeyboard ? _buildSearchUI() : const SizedBox.shrink()),
//                         _buildSliderIndicators(),
//                         _buildFilterBar(),
//                         const SizedBox(height: 10),
                        
//                         // Content Area (Handles localized loading gracefully)
//                         _buildContentArea(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             if (widget.isLoading && widget.contentList.isEmpty && widget.filterNames.isEmpty)
//               Container(
//                 color: ProfessionalColors.primaryDark,
//                 child: const Center(child: CircularProgressIndicator(color: Colors.white)),
//               ),

//             if (widget.isVideoLoading && widget.errorMessage == null)
//               Positioned.fill(child: Container(color: Colors.black87, child: const Center(child: CircularProgressIndicator(color: Colors.white)))),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContentArea() {
//     if (widget.errorMessage != null) {
//       return Expanded(child: _buildErrorWidget());
//     }
//     if (widget.isLoading || widget.isListLoading) {
//       return const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.white)));
//     }
//     return _buildContentList();
//   }

//   Widget _buildBeautifulAppBar() {
//     final focusName = context.watch<InternalFocusProvider>().focusedItemName;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//       decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.5), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
//       child: Row(
//         children: [
//           Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white)),
//           const SizedBox(width: 20),
//           Expanded(child: Text(focusName, style: const TextStyle(color: ProfessionalColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 20), overflow: TextOverflow.ellipsis)),
//         ],
//       ),
//     );
//   }

//   Widget _buildTopFilterBar() {
//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5, bottom: 5, left: 20),
//           decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1))),
//           child: Row(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 35,
//                   child: ListView.builder(
//                     controller: _networkScrollController,
//                     scrollDirection: Axis.horizontal,
//                     itemCount: widget.networkNames.length,
//                     itemBuilder: (ctx, i) {
//                       if (i >= _networkFocusNodes.length) return const SizedBox.shrink();
//                       bool isSelected = widget.selectedNetworkIndex == i;
//                       return Focus(
//                         focusNode: _networkFocusNodes[i],
//                         onFocusChange: (has) { 
//                           // if (has && widget.onNetworkSelected != null && widget.selectedNetworkIndex != i) {
//                           //   widget.onNetworkSelected!(i); 
//                           // } 
//                         },
//                         child: _buildGlassButton(
//                           focusNode: _networkFocusNodes[i],
//                           isSelected: isSelected,
//                           color: widget.focusColors[i % widget.focusColors.length],
//                           label: widget.networkNames[i].toUpperCase(),
//                           onTap: () { 
//                             _shouldFocusFirstItem = true; 
//                             if (widget.onNetworkSelected != null) widget.onNetworkSelected!(i); 
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterBar() {
//     if (widget.filterNames.isEmpty && !_isSearching) return const SizedBox(height: 30);
//     return SizedBox(
//       height: 35,
//       child: ListView.builder(
//         controller: _filterScrollController,
//         scrollDirection: Axis.horizontal,
//         itemCount: widget.filterNames.length + 1,
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         itemBuilder: (ctx, i) {
//           if (i == 0) {
//             return Focus(
//               focusNode: _searchButtonFocusNode,
//               onFocusChange: (has) {
//                 if (has && !_isDisposed) Provider.of<InternalFocusProvider>(context, listen: false).updateName("SEARCH");
//               },
//               child: _buildGlassButton(
//                 focusNode: _searchButtonFocusNode,
//                 isSelected: _isSearching || _showKeyboard,
//                 color: ProfessionalColors.accentOrange,
//                 label: "SEARCH",
//                 icon: Icons.search,
//                 onTap: () => setState(() { _showKeyboard = true; _searchButtonFocusNode.requestFocus(); }),
//               ),
//             );
//           }
//           int filterIdx = i - 1;
//           if (filterIdx >= _filterFocusNodes.length) return const SizedBox.shrink();
//           return Focus(
//             focusNode: _filterFocusNodes[filterIdx],
//             onFocusChange: (has) { 
//               // if (has && widget.selectedFilterIndex != filterIdx) {
//               //    widget.onFilterSelected(filterIdx); 
//               // } 
//             },
//             child: _buildGlassButton(
//               focusNode: _filterFocusNodes[filterIdx],
//               isSelected: !_isSearching && widget.selectedFilterIndex == filterIdx,
//               color: widget.focusColors[filterIdx % widget.focusColors.length],
//               label: widget.filterNames[filterIdx].toUpperCase(),
//               onTap: () { 
//                 _shouldFocusFirstItem = true; 
//                 widget.onFilterSelected(filterIdx); 
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildContentList() {
//     if (widget.contentList.isEmpty) {
//       return Expanded(child: Center(child: Text(widget.emptyMessage, style: const TextStyle(color: Colors.white54, fontSize: 18))));
//     }
//     return Expanded(
//       child: ListView.builder(
//         controller: _itemScrollController,
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         clipBehavior: Clip.none,
//         itemCount: widget.contentList.length,
//         itemBuilder: (ctx, i) {
//           if (i >= _itemFocusNodes.length) return const SizedBox.shrink();
//           final item = widget.contentList[i];
//           return _MasterSliderCard<T>(
//             item: item,
//             focusNode: _itemFocusNodes[i],
//             isFocused: _focusedItemIndex == i,
//             focusColor: widget.focusColors[i % widget.focusColors.length],
//             onTap: () => widget.onContentTap(item, i),
//             onFocusChange: (has) {
//               if (has && !_isDisposed) {
//                 if (_focusedItemIndex != i) {
//                   setState(() => _focusedItemIndex = i);
//                   _scrollToFocus(_itemScrollController, i, widget.cardWidth + 15);
//                   Provider.of<InternalFocusProvider>(context, listen: false).updateName(widget.getTitle(item));
//                 }
//               }
//             },
//             getTitle: widget.getTitle,
//             getImageUrl: widget.getImageUrl,
//             cardWidth: widget.cardWidth,
//             cardHeight: widget.cardHeight,
//             placeholderIcon: widget.placeholderIcon,
//             logoUrl: widget.logoUrl,
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildGlassButton({required FocusNode focusNode, required bool isSelected, required Color color, required String label, IconData? icon, required VoidCallback onTap}) {
//     bool hasFocus = focusNode.hasFocus;
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(right: 12),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(30),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//             child: AnimatedContainer(
//               duration: AnimationTiming.fast,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
//               decoration: BoxDecoration(
//                 color: hasFocus ? color : isSelected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(30),
//                 border: Border.all(color: hasFocus ? Colors.white : Colors.white.withOpacity(0.3), width: hasFocus ? 3 : 2),
//                 boxShadow: (hasFocus || isSelected) ? [BoxShadow(color: color.withOpacity(0.8), blurRadius: 15)] : null,
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (icon != null) ...[Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 8)],
//                   Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchUI() {
//     return Row(
//       children: [
//         Expanded(
//           flex: 4,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text("SEARCH", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
//               const SizedBox(height: 24),
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 40),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10), border: Border.all(color: ProfessionalColors.accentPurple)),
//                 child: Text(_searchText.isEmpty ? 'Typing...' : _searchText, style: const TextStyle(color: Colors.white, fontSize: 22)),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           flex: 6,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: _keyboardLayout.asMap().entries.map((r) => Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: r.value.asMap().entries.map((c) {
//                 int idx = _keyboardLayout.take(r.key).fold(0, (p, e) => p + e.length) + c.key;
//                 if (idx >= _keyboardFocusNodes.length) return const SizedBox.shrink();
//                 bool isFocused = _focusedKeyRow == r.key && _focusedKeyCol == c.key;
//                 String key = c.value;
//                 double w = key == 'SPACE' ? 150 : (key == 'OK' || key == 'DEL' ? 70 : 40);
//                 return Container(
//                   width: w, height: 40, margin: const EdgeInsets.all(4),
//                   child: Focus(
//                     focusNode: _keyboardFocusNodes[idx],
//                     onFocusChange: (has) { if (has) setState(() { _focusedKeyRow = r.key; _focusedKeyCol = c.key; }); },
//                     child: ElevatedButton(
//                       onPressed: () => _handleKeyClick(key),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: isFocused ? ProfessionalColors.accentPurple : Colors.white10,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: isFocused ? const BorderSide(color: Colors.white, width: 2) : BorderSide.none),
//                         padding: EdgeInsets.zero,
//                       ),
//                       child: Text(key, style: const TextStyle(color: Colors.white, fontSize: 18)),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             )).toList(),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _buildBackgroundSlider() {
//     if (widget.sliderImages.isEmpty) return Container(color: ProfessionalColors.primaryDark);
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         PageView.builder(
//           controller: _sliderPageController,
//           itemCount: widget.sliderImages.length,
//           itemBuilder: (c, i) => CachedNetworkImage(imageUrl: widget.sliderImages[i], fit: BoxFit.cover, errorWidget: (c,u,e) => Container(color: ProfessionalColors.surfaceDark)),
//         ),
//         Container(
//           // decoration: BoxDecoration(
//           //   gradient: LinearGradient(
//           //     colors: [Colors.transparent, ProfessionalColors.primaryDark.withOpacity(0.8), ProfessionalColors.primaryDark],
//           //     begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0.3, 0.7, 1.0],
//           //   ),
//           // ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSliderIndicators() {
//     if (widget.sliderImages.length <= 1) return const SizedBox.shrink();
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(widget.sliderImages.length, (i) => AnimatedContainer(
//         duration: AnimationTiming.fast,
//         margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
//         height: 6, width: _currentSliderPage == i ? 20 : 6,
//         decoration: BoxDecoration(color: _currentSliderPage == i ? Colors.white : Colors.white54, borderRadius: BorderRadius.circular(10)),
//       )),
//     );
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.cloud_off, color: Colors.red, size: 60),
//           const SizedBox(height: 20),
//           Text(widget.errorMessage ?? 'Something went wrong', style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             focusNode: FocusNode(), onPressed: widget.onRetry, icon: const Icon(Icons.refresh), label: const Text('Try Again'),
//           )
//         ],
//       ),
//     );
//   }
// }

// // 🔥 CARD WITH FIXED TITLE HEIGHT (Prevents Image Shrinking)
// class _MasterSliderCard<T> extends StatefulWidget {
//   final T item;
//   final FocusNode focusNode;
//   final bool isFocused;
//   final Color focusColor;
//   final VoidCallback onTap;
//   final Function(bool) onFocusChange;
//   final String Function(T) getTitle;
//   final String Function(T) getImageUrl;
//   final double cardWidth;
//   final double cardHeight;
//   final IconData placeholderIcon;
//   final String logoUrl;

//   const _MasterSliderCard({
//     Key? key, required this.item, required this.focusNode, required this.isFocused, required this.focusColor, required this.onTap, required this.onFocusChange, required this.getTitle, required this.getImageUrl, required this.cardWidth, required this.cardHeight, required this.placeholderIcon, required this.logoUrl,
//   }) : super(key: key);

//   @override
//   __MasterSliderCardState<T> createState() => __MasterSliderCardState<T>();
// }

// class __MasterSliderCardState<T> extends State<_MasterSliderCard<T>> with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _borderAnimationController;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic)); 
//     _borderAnimationController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
//     widget.focusNode.addListener(_handleFocus);
//     _syncFocusState();
//   }

//   @override
//   void didUpdateWidget(covariant _MasterSliderCard<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.focusNode != widget.focusNode) {
//       oldWidget.focusNode.removeListener(_handleFocus);
//       widget.focusNode.addListener(_handleFocus);
//     }
//     if (oldWidget.isFocused != widget.isFocused) {
//       _syncFocusState();
//     }
//   }

//   void _syncFocusState() {
//     if (widget.isFocused) {
//       _scaleController.forward();
//       if (!_borderAnimationController.isAnimating) _borderAnimationController.repeat();
//     } else {
//       _scaleController.reverse();
//       _borderAnimationController.stop();
//     }
//   }

//   void _handleFocus() {
//     if (!mounted) return;
//     widget.onFocusChange(widget.focusNode.hasFocus);
//   }

//   @override
//   void dispose() {
//     widget.focusNode.removeListener(_handleFocus);
//     _scaleController.dispose();
//     _borderAnimationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: widget.cardWidth,
//       margin: const EdgeInsets.symmetric(horizontal: 15), 
//       alignment: Alignment.center, 
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _scaleAnimation,
//             builder: (context, child) => Transform.scale(
//               scale: _scaleAnimation.value,
//               child: GestureDetector(
//                 onTap: widget.onTap,
//                 child: Focus(
//                   focusNode: widget.focusNode,
//                   child: _buildPoster(),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           _buildTitle(),
//         ],
//       ),
//     );
//   }

//   Widget _buildPoster() {
//     return Container(
//       height: widget.cardHeight,
//       width: widget.cardWidth,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           if (widget.isFocused) BoxShadow(color: Colors.black.withOpacity(0.95), blurRadius: 25, spreadRadius: 8, offset: const Offset(0, 12))
//           else BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))
//         ],
//       ),
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           if (widget.isFocused)
//             AnimatedBuilder(
//               animation: _borderAnimationController,
//               builder: (context, child) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     gradient: SweepGradient(
//                       colors: [Colors.white.withOpacity(0.1), Colors.white, Colors.white, Colors.white.withOpacity(0.1)],
//                       stops: const [0.0, 0.25, 0.5, 1.0],
//                       transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           Padding(
//             padding: EdgeInsets.all(widget.isFocused ? 3.5 : 0.0),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(widget.isFocused ? 5 : 8),
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   CachedNetworkImage(
//                     imageUrl: widget.getImageUrl(widget.item),
//                     fit: BoxFit.cover,
//                     placeholder: (c, u) => _placeholder(),
//                     errorWidget: (c, u, e) => _placeholder(),
//                   ),
//                   if (widget.logoUrl.isNotEmpty)
//                     Positioned(
//                       top: 5, right: 5, 
//                       child: CircleAvatar(radius: 12, backgroundImage: CachedNetworkImageProvider(widget.logoUrl), backgroundColor: Colors.black54)
//                     ),
//                 ],
//               ),
//             ),
//           ),
//           if (widget.isFocused)
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _placeholder() => Container(
//     color: ProfessionalColors.cardDark,
//     child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//       Icon(widget.placeholderIcon, size: widget.cardHeight * 0.25, color: Colors.grey),
//     ]),
//   );

//   // FIXED HEIGHT ENSURES IMAGE STAYS EXACTLY THE SAME SIZE REGARDLESS OF 1 OR 2 TEXT LINES
//   Widget _buildTitle() => Container(
//     width: widget.cardWidth,
//     height: 42, 
//     alignment: Alignment.topCenter,
//     child: AnimatedDefaultTextStyle(
//       duration: const Duration(milliseconds: 250),
//       style: TextStyle(
//         fontSize: 14,
//         fontWeight: widget.isFocused ? FontWeight.w800 : FontWeight.w600,
//         color: widget.isFocused ? widget.focusColor : Colors.white70,
//         letterSpacing: 0.5,
//         height: 1.2,
//       ),
//       child: Text(widget.getTitle(widget.item), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
//     ),
//   );
// }





import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Assuming these exist in your project, keeping imports as is.
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';
// If smart_style_image_card is not used anymore in this file, you can remove this.
// import 'package:mobi_tv_entertainment/components/widgets/smart_style_image_card.dart';

class ProfessionalColors {
  static const primaryDark = Color(0xFF0A0E1A);
  static const surfaceDark = Color(0xFF1A1D29);
  static const cardDark = Color(0xFF2A2D3A);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const accentOrange = Color(0xFFF59E0B);
  static const accentPurple = Color(0xFF8B5CF6);
}

class AnimationTiming {
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
}

class MasterSliderLayout<T> extends StatefulWidget {
  final String title;
  final String logoUrl;
  final bool isLoading;
  final bool isListLoading;
  final bool isVideoLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  final List<String> networkNames;
  final int selectedNetworkIndex;
  final Function(int)? onNetworkSelected;

  final List<String> filterNames;
  final int selectedFilterIndex;
  final Function(int) onFilterSelected;
  final Function(String) onSearch;

  final List<T> contentList;
  final Function(T, int) onContentTap;
  final String Function(T) getTitle;
  final String Function(T) getImageUrl;

  final List<String> sliderImages;
  final List<Color> focusColors;
  final IconData placeholderIcon;
  final String emptyMessage;
  final double cardWidth;
  final double cardHeight;

  const MasterSliderLayout({
    Key? key,
    required this.title,
    required this.logoUrl,
    required this.isLoading,
    this.isListLoading = false,
    required this.isVideoLoading,
    this.errorMessage,
    required this.onRetry,
    required this.networkNames,
    required this.selectedNetworkIndex,
    this.onNetworkSelected,
    required this.filterNames,
    required this.selectedFilterIndex,
    required this.onFilterSelected,
    required this.onSearch,
    required this.contentList,
    required this.onContentTap,
    required this.getTitle,
    required this.getImageUrl,
    required this.sliderImages,
    required this.focusColors,
    required this.placeholderIcon,
    required this.emptyMessage,
    required this.cardWidth,
    required this.cardHeight,
  }) : super(key: key);

  @override
  State<MasterSliderLayout<T>> createState() => _MasterSliderLayoutState<T>();
}

class _MasterSliderLayoutState<T> extends State<MasterSliderLayout<T>>
    with TickerProviderStateMixin {
  bool _isDisposed = false;
  bool _shouldFocusFirstItem = false;

  final FocusNode _widgetFocusNode = FocusNode();
  late FocusNode _searchButtonFocusNode;
  List<FocusNode> _networkFocusNodes = [];
  List<FocusNode> _filterFocusNodes = [];
  List<FocusNode> _itemFocusNodes = [];
  List<FocusNode> _keyboardFocusNodes = [];

  final ScrollController _networkScrollController = ScrollController();
  final ScrollController _filterScrollController = ScrollController();
  final ScrollController _itemScrollController = ScrollController();

  late PageController _sliderPageController;
  int _currentSliderPage = 0;
  Timer? _sliderTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  // Separate controller for button border animation to sync with cards
  late AnimationController _borderAnimationController;

  bool _isNavigationLocked = false;
  Timer? _navigationLockTimer;

  bool _isSearching = false;
  bool _showKeyboard = false;
  String _searchText = '';
  Timer? _debounce;
  int _focusedKeyRow = 0;
  int _focusedKeyCol = 0;
  int _focusedItemIndex = -1;
  int _lastFocusedItemIndex = 0; // Remembers position in the list

  final List<List<String>> _keyboardLayout = [
    "1234567890".split(''),
    "qwertyuiop".split(''),
    "asdfghjkl".split(''),
    ["z", "x", "c", "v", "b", "n", "m", "DEL"],
    ["SPACE", "OK"],
  ];

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    _sliderPageController = PageController();
    _searchButtonFocusNode = FocusNode()..addListener(_setStateListener);
    _widgetFocusNode.addListener(_setStateListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed)
        Provider.of<InternalFocusProvider>(context, listen: false)
            .updateName('');
    });

    _fadeController =
        AnimationController(duration: AnimationTiming.medium, vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    // Initialize border animation for buttons
    _borderAnimationController =
        AnimationController(duration: const Duration(milliseconds: 2500), vsync: this)
          ..repeat();

    _initializeAllFocusNodes();
    _setupSliderTimer();
    _fadeController.forward();
  }

  int _getKeyboardNodeIndex(int row, int col) {
    int idx = 0;
    for (int i = 0; i < row; i++) idx += _keyboardLayout[i].length;
    return idx + col;
  }

  @override
  void didUpdateWidget(covariant MasterSliderLayout<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.contentList.length != widget.contentList.length) {
      _disposeFocusNodes(_itemFocusNodes);
      _itemFocusNodes = List.generate(widget.contentList.length,
          (i) => FocusNode()..addListener(_setStateListener));
      _focusedItemIndex = -1;
    }
    if (oldWidget.filterNames.length != widget.filterNames.length) {
      _disposeFocusNodes(_filterFocusNodes);
      _filterFocusNodes = List.generate(widget.filterNames.length,
          (i) => FocusNode()..addListener(_setStateListener));
    }
    if (oldWidget.networkNames.length != widget.networkNames.length) {
      _disposeFocusNodes(_networkFocusNodes);
      _networkFocusNodes = List.generate(widget.networkNames.length,
          (i) => FocusNode()..addListener(_setStateListener));
    }

    if (oldWidget.sliderImages != widget.sliderImages) {
      _setupSliderTimer();
    }

    bool justFinishedPageLoad =
        oldWidget.isLoading == true && widget.isLoading == false;
    bool justFinishedListLoad =
        oldWidget.isListLoading == true && widget.isListLoading == false;
    bool contentAppeared =
        oldWidget.contentList.isEmpty && widget.contentList.isNotEmpty;

    if ((justFinishedPageLoad ||
            justFinishedListLoad ||
            contentAppeared ||
            _shouldFocusFirstItem) &&
        !_showKeyboard) {
      if (_shouldFocusFirstItem && !widget.isListLoading && !widget.isLoading) {
        _shouldFocusFirstItem = false;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted && !_showKeyboard) {
          if (widget.contentList.isNotEmpty && _itemFocusNodes.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 150), () {
              if (!_isDisposed &&
                  mounted &&
                  _itemFocusNodes.isNotEmpty &&
                  !_showKeyboard) {
                setState(() => _focusedItemIndex = 0);
                _itemFocusNodes[0].requestFocus();
                // Card width is defined as effective width due to symmetric margin 15+15
                _scrollToCenter(_itemScrollController, 0, widget.cardWidth + 30, 20);
                Provider.of<InternalFocusProvider>(context, listen: false)
                    .updateName(widget.getTitle(widget.contentList[0]));
              }
            });
          } else if (justFinishedPageLoad &&
              widget.networkNames.isNotEmpty &&
              _networkFocusNodes.isNotEmpty) {
            _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
          } else if (justFinishedPageLoad &&
              _searchButtonFocusNode.canRequestFocus) {
            _searchButtonFocusNode.requestFocus();
          }
        }
      });
    }
  }

  void _initializeAllFocusNodes() {
    _networkFocusNodes = List.generate(widget.networkNames.length,
        (i) => FocusNode()..addListener(_setStateListener));
    _filterFocusNodes = List.generate(widget.filterNames.length,
        (i) => FocusNode()..addListener(_setStateListener));
    _itemFocusNodes = List.generate(widget.contentList.length,
        (i) => FocusNode()..addListener(_setStateListener));
    int totalKeys = _keyboardLayout.fold(0, (prev, row) => prev + row.length);
    _keyboardFocusNodes = List.generate(
        totalKeys, (i) => FocusNode()..addListener(_setStateListener));
  }

  void _setStateListener() {
    if (mounted && !_isDisposed) setState(() {});
  }

  void _disposeFocusNodes(List<FocusNode> nodes) {
    for (var node in nodes) {
      node.removeListener(_setStateListener);
      try {
        node.dispose();
      } catch (_) {}
    }
    nodes.clear();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _sliderTimer?.cancel();
    _debounce?.cancel();
    _navigationLockTimer?.cancel();
    _sliderPageController.dispose();
    _fadeController.dispose();
    _borderAnimationController.dispose();
    _widgetFocusNode.dispose();
    _searchButtonFocusNode.dispose();
    _networkScrollController.dispose();
    _filterScrollController.dispose();
    _itemScrollController.dispose();
    _disposeFocusNodes(_networkFocusNodes);
    _disposeFocusNodes(_filterFocusNodes);
    _disposeFocusNodes(_itemFocusNodes);
    _disposeFocusNodes(_keyboardFocusNodes);
    super.dispose();
  }

  void _setupSliderTimer() {
    _sliderTimer?.cancel();
    if (widget.sliderImages.length > 1) {
      _sliderTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
        if (!_isDisposed && mounted && _sliderPageController.hasClients) {
          int next = (_sliderPageController.page?.round() ?? 0) + 1;
          if (next >= widget.sliderImages.length) next = 0;
          _sliderPageController.animateToPage(next,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut);
        }
      });
    }
  }

  // UPDATED: Standard robust centering logic
  void _scrollToCenter(ScrollController controller, int index, double itemEffectiveWidth, double listPaddingStart) {
    if (!controller.hasClients) return;
    double screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate start position of item within viewport context (assuming linear layout)
    double itemStartPosition = listPaddingStart + (index * itemEffectiveWidth);
    // Center of the item relative to the list start
    double itemCenterPosition = itemStartPosition + (itemEffectiveWidth / 2);
    // Half screen width is where we want that center to be
    double screenCenter = screenWidth / 2;
    
    // Desired offset is item center minus half screen
    double targetOffset = itemCenterPosition - screenCenter;

    controller.animateTo(
      targetOffset.clamp(0.0, controller.position.maxScrollExtent),
      duration: AnimationTiming.fast,
      curve: Curves.easeInOut,
    );
  }

  KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
    if (_isDisposed || event is! RawKeyDownEvent || widget.isLoading)
      return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape) {
      if (_showKeyboard) {
        setState(() {
          _showKeyboard = false;
          _focusedKeyRow = 0;
          _focusedKeyCol = 0;
        });
        _searchButtonFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
      if (_itemFocusNodes.any((n) => n.hasFocus) ||
          _filterFocusNodes.any((n) => n.hasFocus) ||
          _searchButtonFocusNode.hasFocus) {
        if (_networkFocusNodes.isNotEmpty)
          _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (_showKeyboard && _keyboardFocusNodes.any((n) => n.hasFocus))
      return _navigateKeyboard(key);
    if (_searchButtonFocusNode.hasFocus) return _navigateSearchBtn(key);
    if (_networkFocusNodes.any((n) => n.hasFocus)) return _navigateNetworks(key);
    if (_filterFocusNodes.any((n) => n.hasFocus)) return _navigateFilters(key);
    if (_itemFocusNodes.any((n) => n.hasFocus)) return _navigateItems(key);

    return KeyEventResult.ignored;
  }

  KeyEventResult _navigateKeyboard(LogicalKeyboardKey key) {
    int r = _focusedKeyRow, c = _focusedKeyCol;

    if (key == LogicalKeyboardKey.arrowUp) {
      if (r > 0) {
        r--;
        c = math.min(c, _keyboardLayout[r].length - 1);
      } else {
        if (_networkFocusNodes.isNotEmpty) {
          _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
        }
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.arrowDown) {
      if (r < _keyboardLayout.length - 1) {
        r++;
        c = math.min(c, _keyboardLayout[r].length - 1);
      } else {
        if (_filterFocusNodes.isNotEmpty) {
          int targetFilter =
              widget.selectedFilterIndex >= 0 ? widget.selectedFilterIndex : 0;
          _filterFocusNodes[targetFilter].requestFocus();
        } else {
          _searchButtonFocusNode.requestFocus();
        }
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.arrowLeft && c > 0)
      c--;
    else if (key == LogicalKeyboardKey.arrowRight &&
        c < _keyboardLayout[r].length - 1)
      c++;
    else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _handleKeyClick(_keyboardLayout[r][c]);
      return KeyEventResult.handled;
    }

    if (r != _focusedKeyRow || c != _focusedKeyCol) {
      setState(() {
        _focusedKeyRow = r;
        _focusedKeyCol = c;
      });
      int idx = _getKeyboardNodeIndex(r, c);
      if (idx < _keyboardFocusNodes.length)
        _keyboardFocusNodes[idx].requestFocus();
    }
    return KeyEventResult.handled;
  }

  void _handleKeyClick(String val) {
    setState(() {
      if (val == "OK") {
        _showKeyboard = false;
        _debounce?.cancel();
        widget.onSearch(_searchText.trim());
        _shouldFocusFirstItem = true;
        _searchButtonFocusNode.requestFocus();
      } else {
        if (val == "DEL") {
          if (_searchText.isNotEmpty)
            _searchText = _searchText.substring(0, _searchText.length - 1);
        } else if (val == "SPACE") {
          _searchText += " ";
        } else {
          _searchText += val;
        }

        _isSearching = _searchText.isNotEmpty;

        _debounce?.cancel();
        _debounce = Timer(const Duration(seconds: 10), () {
          if (mounted && _showKeyboard) widget.onSearch(_searchText.trim());
        });
      }
    });
  }

  KeyEventResult _navigateSearchBtn(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      setState(() => _showKeyboard = true);
      if (_keyboardFocusNodes.isNotEmpty) _keyboardFocusNodes[0].requestFocus();
    } else if (key == LogicalKeyboardKey.arrowRight && _filterFocusNodes.isNotEmpty) {
      _filterFocusNodes[0].requestFocus();
    } else if (key == LogicalKeyboardKey.arrowUp) {
      if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
        setState(() {
          _focusedKeyRow = _keyboardLayout.length - 1;
          _focusedKeyCol = 0;
        });
        _keyboardFocusNodes[_getKeyboardNodeIndex(_focusedKeyRow, _focusedKeyCol)]
            .requestFocus();
      } else if (_networkFocusNodes.isNotEmpty) {
        _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
      }
    } else if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
      int target = _lastFocusedItemIndex;
      if (target >= _itemFocusNodes.length) target = _itemFocusNodes.length - 1;
      if (target < 0) target = 0;

      setState(() => _focusedItemIndex = target);
      _itemFocusNodes[target].requestFocus();
    }
    return KeyEventResult.handled;
  }

  KeyEventResult _navigateNetworks(LogicalKeyboardKey key) {
    int focusedIndex = _networkFocusNodes.indexWhere((n) => n.hasFocus);
    if (focusedIndex == -1) focusedIndex = widget.selectedNetworkIndex;

    if (key == LogicalKeyboardKey.arrowLeft && focusedIndex > 0)
      focusedIndex--;
    else if (key == LogicalKeyboardKey.arrowRight &&
        focusedIndex < _networkFocusNodes.length - 1)
      focusedIndex++;
    else if (key == LogicalKeyboardKey.arrowDown) {
      if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
        setState(() {
          _focusedKeyRow = 0;
          _focusedKeyCol = 0;
        });
        _keyboardFocusNodes[0].requestFocus();
      } else {
        _searchButtonFocusNode.requestFocus();
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _shouldFocusFirstItem = true;
      if (widget.onNetworkSelected != null) widget.onNetworkSelected!(focusedIndex);
      return KeyEventResult.handled;
    }

    if (focusedIndex != _networkFocusNodes.indexWhere((n) => n.hasFocus)) {
      _networkFocusNodes[focusedIndex].requestFocus();
      // UPDATED: Center scrolling, assuming glass button width + margin ~ 160
      _scrollToCenter(_networkScrollController, focusedIndex, 160, 20);
    }
    return KeyEventResult.handled;
  }

  KeyEventResult _navigateFilters(LogicalKeyboardKey key) {
    int focusedIndex = _filterFocusNodes.indexWhere((n) => n.hasFocus);
    if (focusedIndex == -1) focusedIndex = widget.selectedFilterIndex;

    if (key == LogicalKeyboardKey.arrowLeft) {
      if (focusedIndex > 0)
        focusedIndex--;
      else {
        _searchButtonFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.arrowRight &&
        focusedIndex < _filterFocusNodes.length - 1)
      focusedIndex++;
    else if (key == LogicalKeyboardKey.arrowUp) {
      if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
        setState(() {
          _focusedKeyRow = _keyboardLayout.length - 1;
          _focusedKeyCol = 0;
        });
        _keyboardFocusNodes[_getKeyboardNodeIndex(_focusedKeyRow, _focusedKeyCol)]
            .requestFocus();
      } else if (_networkFocusNodes.isNotEmpty) {
        _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
      int target = _lastFocusedItemIndex;
      if (target >= _itemFocusNodes.length) target = _itemFocusNodes.length - 1;
      if (target < 0) target = 0;

      setState(() => _focusedItemIndex = target);
      _itemFocusNodes[target].requestFocus();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _shouldFocusFirstItem = true;
      widget.onFilterSelected(focusedIndex);
      return KeyEventResult.handled;
    }

    if (focusedIndex != _filterFocusNodes.indexWhere((n) => n.hasFocus)) {
      _filterFocusNodes[focusedIndex].requestFocus();
      // UPDATED: Center scrolling, assuming glass button width + margin ~ 160
      _scrollToCenter(_filterScrollController, focusedIndex, 160, 20);
    }
    return KeyEventResult.handled;
  }

  KeyEventResult _navigateItems(LogicalKeyboardKey key) {
    if (_isNavigationLocked) return KeyEventResult.handled;
    _isNavigationLocked = true;
    _navigationLockTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isNavigationLocked = false);
    });

    int i = _focusedItemIndex;
    if (key == LogicalKeyboardKey.arrowUp) {
      _lastFocusedItemIndex = _focusedItemIndex >= 0 ? _focusedItemIndex : 0;

      if (_filterFocusNodes.isNotEmpty && widget.selectedFilterIndex >= 0)
        _filterFocusNodes[widget.selectedFilterIndex].requestFocus();
      else
        _searchButtonFocusNode.requestFocus();

      setState(() => _focusedItemIndex = -1);
      _isNavigationLocked = false;
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowLeft && i > 0)
      i--;
    else if (key == LogicalKeyboardKey.arrowRight &&
        i < _itemFocusNodes.length - 1)
      i++;
    else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _isNavigationLocked = false;
      widget.onContentTap(widget.contentList[i], i);
      return KeyEventResult.handled;
    }

    if (i != _focusedItemIndex && i >= 0 && i < _itemFocusNodes.length) {
      setState(() => _focusedItemIndex = i);
      _itemFocusNodes[i].requestFocus();
      // UPDATED: Use specialized robust centering logic
      _scrollToCenter(_itemScrollController, i, widget.cardWidth + 30, 20);
      Provider.of<InternalFocusProvider>(context, listen: false)
          .updateName(widget.getTitle(widget.contentList[i]));
    } else {
      _isNavigationLocked = false;
    }
    return KeyEventResult.handled;
  }

  // ==========================================================
  // BUILD UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfessionalColors.primaryDark,
      body: Focus(
        focusNode: _widgetFocusNode,
        autofocus: true,
        onKey: _onKeyHandler,
        child: Stack(
          children: [
            _buildBackgroundSlider(),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  if (widget.networkNames.isNotEmpty) _buildTopFilterBar(),
                  if (widget.networkNames.isEmpty) ...[
                    SizedBox(height: MediaQuery.of(context).padding.top + 20),
                    _buildBeautifulAppBar(),
                  ],
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.45,
                            child: _showKeyboard
                                ? _buildSearchUI()
                                : const SizedBox.shrink()),
                        _buildSliderIndicators(),
                        _buildFilterBar(),
                        const SizedBox(height: 10),
                        _buildContentArea(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isLoading &&
                widget.contentList.isEmpty &&
                widget.filterNames.isEmpty)
              Container(
                color: ProfessionalColors.primaryDark,
                child: const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
              ),
            if (widget.isVideoLoading && widget.errorMessage == null)
              Positioned.fill(
                  child: Container(
                      color: Colors.black87,
                      child: const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white)))),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    if (widget.errorMessage != null) {
      return Expanded(child: _buildErrorWidget());
    }
    if (widget.isLoading || widget.isListLoading) {
      return const Expanded(
          child: Center(child: CircularProgressIndicator(color: Colors.white)));
    }
    return _buildContentList();
  }

  Widget _buildBeautifulAppBar() {
    final focusName = context.watch<InternalFocusProvider>().focusedItemName;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.0), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Row(
        children: [
          Text(widget.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white)),
          const SizedBox(width: 20),
          Expanded(
              child: Text(focusName,
                  style: const TextStyle(
                      color: ProfessionalColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildTopFilterBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 5, bottom: 5, left: 20),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1), width: 1))),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 35,
                  child: ListView.builder(
                    controller: _networkScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.networkNames.length,
                    // Use standard clipping behavior to prevent scaling artifacts outside viewport
                    itemBuilder: (ctx, i) {
                      if (i >= _networkFocusNodes.length)
                        return const SizedBox.shrink();
                      bool isSelected = widget.selectedNetworkIndex == i;
                      return Focus(
                        focusNode: _networkFocusNodes[i],
                        onFocusChange: (has) {
                          // Centering logic on focus
                          if (has && !_isDisposed) {
                             _scrollToCenter(_networkScrollController, i, 160, 20);
                          }
                        },
                        child: _buildGlassButton(
                          focusNode: _networkFocusNodes[i],
                          isSelected: isSelected,
                          color: widget
                              .focusColors[i % widget.focusColors.length],
                          label: widget.networkNames[i].toUpperCase(),
                          onTap: () {
                            _shouldFocusFirstItem = true;
                            if (widget.onNetworkSelected != null)
                              widget.onNetworkSelected!(i);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    if (widget.filterNames.isEmpty && !_isSearching)
      return const SizedBox(height: 30);
    return SizedBox(
      height: 35,
      child: ListView.builder(
        controller: _filterScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.filterNames.length + 1,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (ctx, i) {
          if (i == 0) {
            return Focus(
              focusNode: _searchButtonFocusNode,
              onFocusChange: (has) {
                if (has && !_isDisposed) {
                  Provider.of<InternalFocusProvider>(context, listen: false)
                      .updateName("SEARCH");
                   _scrollToCenter(_filterScrollController, 0, 160, 20);
                }
              },
              child: _buildGlassButton(
                focusNode: _searchButtonFocusNode,
                isSelected: _isSearching || _showKeyboard,
                color: ProfessionalColors.accentOrange,
                label: "SEARCH",
                icon: Icons.search,
                onTap: () => setState(() {
                  _showKeyboard = true;
                  _searchButtonFocusNode.requestFocus();
                }),
              ),
            );
          }
          int filterIdx = i - 1;
          if (filterIdx >= _filterFocusNodes.length) return const SizedBox.shrink();
          return Focus(
            focusNode: _filterFocusNodes[filterIdx],
            onFocusChange: (has) {
              // Centering logic on focus
              if (has && !_isDisposed) {
                 _scrollToCenter(_filterScrollController, i, 160, 20);
              }
            },
            child: _buildGlassButton(
              focusNode: _filterFocusNodes[filterIdx],
              isSelected:
                  !_isSearching && widget.selectedFilterIndex == filterIdx,
              color: widget
                  .focusColors[filterIdx % widget.focusColors.length],
              label: widget.filterNames[filterIdx].toUpperCase(),
              onTap: () {
                _shouldFocusFirstItem = true;
                widget.onFilterSelected(filterIdx);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentList() {
    if (widget.contentList.isEmpty) {
      return Expanded(
          child: Center(
              child: Text(widget.emptyMessage,
                  style: const TextStyle(color: Colors.white54, fontSize: 18))));
    }
    return Expanded(
      child: ListView.builder(
        controller: _itemScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        clipBehavior: Clip.none, // Essential for large scale animation
        itemCount: widget.contentList.length,
        itemBuilder: (ctx, i) {
          if (i >= _itemFocusNodes.length) return const SizedBox.shrink();
          final item = widget.contentList[i];
          return _MasterSliderCard<T>(
            item: item,
            focusNode: _itemFocusNodes[i],
            isFocused: _focusedItemIndex == i,
            focusColor: widget.focusColors[i % widget.focusColors.length],
            onTap: () => widget.onContentTap(item, i),
            onFocusChange: (has) {
              if (has && !_isDisposed) {
                if (_focusedItemIndex != i) {
                  setState(() => _focusedItemIndex = i);
                  // UPDATED: Center scrolling logic
                  _scrollToCenter(_itemScrollController, i, widget.cardWidth + 30, 20);
                  Provider.of<InternalFocusProvider>(context, listen: false)
                      .updateName(widget.getTitle(item));
                }
              }
            },
            getTitle: widget.getTitle,
            getImageUrl: widget.getImageUrl,
            cardWidth: widget.cardWidth,
            cardHeight: widget.cardHeight,
            placeholderIcon: widget.placeholderIcon,
            logoUrl: widget.logoUrl,
          );
        },
      ),
    );
  }

  // // UPDATED: Glass button build logic with animated sweep border gradient
  // Widget _buildGlassButton(
  //     {required FocusNode focusNode,
  //     required bool isSelected,
  //     required Color color,
  //     required String label,
  //     IconData? icon,
  //     required VoidCallback onTap}) {
  //   bool hasFocus = focusNode.hasFocus;
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       margin: const EdgeInsets.only(right: 12),
  //       // Fix width for reliable centering math (e.g., 148 + 12 margin = 160 effective)
  //       width: 148, 
  //       alignment: Alignment.center,
  //       child: AnimatedBuilder(
  //         animation: _borderAnimationController,
  //         builder: (context, child) {
  //           return Stack(
  //              fit: StackFit.passthrough,
  //              alignment: Alignment.center,
  //              children: [
  //               // 1. The Dynamic Animated Border (Matches card style exactly)
  //               if (hasFocus)
  //                  Container(
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(30),
  //                     gradient: SweepGradient(
  //                       colors: [
  //                         Colors.white.withOpacity(0.1),
  //                         Colors.white,
  //                         Colors.white,
  //                         Colors.white.withOpacity(0.1)
  //                       ],
  //                       stops: const [0.0, 0.25, 0.5, 1.0],
  //                       transform: GradientRotation(
  //                           _borderAnimationController.value * 2 * math.pi),
  //                     ),
  //                   ),
  //                 ),
  //               // 2. The Button Content with Padding to show border
  //               Padding(
  //                  padding: EdgeInsets.all(hasFocus ? 2.5 : 0.0), // Padding shows the border
  //                  child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(hasFocus ? 28 : 30),
  //                   child: BackdropFilter(
  //                     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  //                     child: AnimatedContainer(
  //                       duration: AnimationTiming.fast,
  //                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
  //                       alignment: Alignment.center,
  //                       decoration: BoxDecoration(
  //                         // When focused, background is black/transparent to highlight white border/text
  //                         color: hasFocus 
  //                             ? Colors.black.withOpacity(0.8) 
  //                             : isSelected 
  //                                 ? color.withOpacity(0.5) 
  //                                 : Colors.white.withOpacity(0.08),
  //                         borderRadius: BorderRadius.circular(hasFocus ? 28 : 30),
  //                         // Optional outer subtle static border when unfocused
  //                         border: !hasFocus ? Border.all(color: Colors.white.withOpacity(0.2), width: 1) : null,
  //                         // Blue glow glow shadow only when focused
  //                         boxShadow: hasFocus 
  //                             ? [BoxShadow(color: color.withOpacity(0.7), blurRadius: 15, spreadRadius: 2)] 
  //                             : null,
  //                       ),
  //                       child: Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           if (icon != null) ...[
  //                             Icon(icon, color: Colors.white, size: 16),
  //                             const SizedBox(width: 8)
  //                           ],
  //                           Flexible(
  //                              child: Text(label,
  //                                 style: const TextStyle(
  //                                     color: Colors.white, // Text is always white
  //                                     fontWeight: FontWeight.bold,
  //                                     fontSize: 14),
  //                                 overflow: TextOverflow.ellipsis,
  //                                 textAlign: TextAlign.center,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                  ),
  //               ),
  //              ],
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }


  Widget _buildGlassButton({required FocusNode focusNode, required bool isSelected, required Color color, required String label, IconData? icon, required VoidCallback onTap}) {
    bool hasFocus = focusNode.hasFocus;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: AnimatedBuilder(
          animation: _borderAnimationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // 1. Animated Rotating Border (Visible only when focused)
                if (hasFocus)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: SweepGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white,
                            Colors.white,
                            Colors.white.withOpacity(0.1)
                          ],
                          stops: const [0.0, 0.25, 0.5, 1.0],
                          transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
                        ),
                      ),
                    ),
                  ),
                // 2. Your Original Glass Button (with padding to expose the border underneath)
                Padding(
                  padding: EdgeInsets.all(hasFocus ? 3.0 : 0.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: AnimatedContainer(
                        duration: AnimationTiming.fast,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        decoration: BoxDecoration(
                          // Restored your original color logic
                          color: hasFocus ? color : isSelected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(30),
                          // Static border shows when unfocused, animated border shows when focused
                          border: !hasFocus ? Border.all(color: Colors.white.withOpacity(0.3), width: 2) : null,
                          boxShadow: (hasFocus || isSelected) ? [BoxShadow(color: color.withOpacity(0.8), blurRadius: 15)] : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (icon != null) ...[Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 8)],
                            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchUI() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("SEARCH",
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ProfessionalColors.accentPurple)),
                child: Text(_searchText.isEmpty ? 'Typing...' : _searchText,
                    style: const TextStyle(color: Colors.white, fontSize: 22)),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _keyboardLayout.asMap().entries.map((r) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: r.value.asMap().entries.map((c) {
                    int idx = _keyboardLayout
                            .take(r.key)
                            .fold(0, (p, e) => p + e.length) +
                        c.key;
                    if (idx >= _keyboardFocusNodes.length)
                      return const SizedBox.shrink();
                    bool isFocused = _focusedKeyRow == r.key && _focusedKeyCol == c.key;
                    String key = c.value;
                    double w = key == 'SPACE'
                        ? 150
                        : (key == 'OK' || key == 'DEL' ? 70 : 40);
                    return Container(
                      width: w,
                      height: 40,
                      margin: const EdgeInsets.all(4),
                      child: Focus(
                        focusNode: _keyboardFocusNodes[idx],
                        onFocusChange: (has) {
                          if (has)
                            setState(() {
                              _focusedKeyRow = r.key;
                              _focusedKeyCol = c.key;
                            });
                        },
                        child: ElevatedButton(
                          onPressed: () => _handleKeyClick(key),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFocused
                                ? ProfessionalColors.accentPurple
                                : Colors.white10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: isFocused
                                    ? const BorderSide(color: Colors.white, width: 2)
                                    : BorderSide.none),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(key,
                              style: const TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                    );
                  }).toList(),
                )).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildBackgroundSlider() {
    if (widget.sliderImages.isEmpty)
      return Container(color: ProfessionalColors.primaryDark);
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _sliderPageController,
          itemCount: widget.sliderImages.length,
          itemBuilder: (c, i) => CachedNetworkImage(
              imageUrl: widget.sliderImages[i],
              fit: BoxFit.fill,
              errorWidget: (c, u, e) =>
                  Container(color: ProfessionalColors.surfaceDark)),
        ),
      ],
    );
  }

  // Widget _buildSliderIndicators() {
  //   if (widget.sliderImages.length <= 1) return const SizedBox.shrink();
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: List.generate(
  //         widget.sliderImages.length,
  //         (i) => AnimatedContainer(
  //               duration: AnimationTiming.fast,
  //               margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
  //               height: 6,
  //               width: _currentSliderPage == i ? 20 : 6,
  //               decoration: BoxDecoration(
  //                   color: _currentSliderPage == i ? Colors.white : Colors.white54,
  //                   borderRadius: BorderRadius.circular(10)),
  //             )),
  //   );
  // }

Widget _buildSliderIndicators() {
    // Agar 1 ya usse kam image hai, toh empty SizedBox return karenge
    // jiske height exactly indicator row (10 margin + 6 height + 10 margin = 26) ke barabar ho.
    if (widget.sliderImages.length <= 1) return const SizedBox(height: 26);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          widget.sliderImages.length,
          (i) => AnimatedContainer(
                duration: AnimationTiming.fast,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                height: 6,
                width: _currentSliderPage == i ? 20 : 6,
                decoration: BoxDecoration(
                    color: _currentSliderPage == i ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(10)),
              )),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          Text(widget.errorMessage ?? 'Something went wrong',
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            focusNode: FocusNode(),
            onPressed: widget.onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          )
        ],
      ),
    );
  }
}

class _MasterSliderCard<T> extends StatefulWidget {
  final T item;
  final FocusNode focusNode;
  final bool isFocused;
  final Color focusColor;
  final VoidCallback onTap;
  final Function(bool) onFocusChange;
  final String Function(T) getTitle;
  final String Function(T) getImageUrl;
  final double cardWidth;
  final double cardHeight;
  final IconData placeholderIcon;
  final String logoUrl;

  const _MasterSliderCard({
    Key? key,
    required this.item,
    required this.focusNode,
    required this.isFocused,
    required this.focusColor,
    required this.onTap,
    required this.onFocusChange,
    required this.getTitle,
    required this.getImageUrl,
    required this.cardWidth,
    required this.cardHeight,
    required this.placeholderIcon,
    required this.logoUrl,
  }) : super(key: key);

  @override
  __MasterSliderCardState<T> createState() => __MasterSliderCardState<T>();
}

class __MasterSliderCardState<T> extends State<_MasterSliderCard<T>>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _borderAnimationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController =
        AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    
    // UPDATED: Scale increase: 1.15 to 1.3
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));

    _borderAnimationController =
        AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
    widget.focusNode.addListener(_handleFocus);
    _syncFocusState();
  }

  @override
  void didUpdateWidget(covariant _MasterSliderCard<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocus);
      widget.focusNode.addListener(_handleFocus);
    }
    if (oldWidget.isFocused != widget.isFocused) {
      _syncFocusState();
    }
  }

  void _syncFocusState() {
    if (widget.isFocused) {
      _scaleController.forward();
      if (!_borderAnimationController.isAnimating)
        _borderAnimationController.repeat();
    } else {
      _scaleController.reverse();
      _borderAnimationController.stop();
    }
  }

  void _handleFocus() {
    if (!mounted) return;
    widget.onFocusChange(widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocus);
    _scaleController.dispose();
    _borderAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Standard card wrapper width defined as cardWidth + horizontal margins
      width: widget.cardWidth + 30, // Effective width: CardWidth + 15(left) + 15(right)
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTap: widget.onTap,
                child: Focus(
                  focusNode: widget.focusNode,
                  child: _buildPoster(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Spacer ensures title doesn't shift card vertical alignment significantly
          _buildTitle(),
        ],
      ),
    );
  }

  Widget _buildPoster() {
    return Container(
      height: widget.cardHeight,
      width: widget.cardWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          if (widget.isFocused)
            BoxShadow(
                color: Colors.black.withOpacity(0.95),
                blurRadius: 35, // Increased blur for larger scale
                spreadRadius: 10,
                offset: const Offset(0, 15))
          else
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 4))
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.isFocused)
            AnimatedBuilder(
              animation: _borderAnimationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: SweepGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white,
                        Colors.white,
                        Colors.white.withOpacity(0.1)
                      ],
                      stops: const [0.0, 0.25, 0.5, 1.0],
                      transform: GradientRotation(
                          _borderAnimationController.value * 2 * math.pi),
                    ),
                  ),
                );
              },
            ),
          Padding(
            padding: EdgeInsets.all(widget.isFocused ? 3.5 : 0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.isFocused ? 5 : 8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.getImageUrl(widget.item),
                    fit: BoxFit.cover,
                    placeholder: (c, u) => _placeholder(),
                    errorWidget: (c, u, e) => _placeholder(),
                  ),
                  if (widget.logoUrl.isNotEmpty)
                    Positioned(
                        top: 5,
                        right: 5,
                        child: CircleAvatar(
                            radius: 12,
                            backgroundImage:
                                CachedNetworkImageProvider(widget.logoUrl),
                            backgroundColor: Colors.black54)),
                ],
              ),
            ),
          ),
          if (widget.isFocused)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: ProfessionalColors.cardDark,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(widget.placeholderIcon,
              size: widget.cardHeight * 0.25, color: Colors.grey),
        ]),
      );

  Widget _buildTitle() => Container(
        width: widget.cardWidth,
        // Height fixed to prevent image jump regardless of text lines
        height: 48, 
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.topCenter,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          textAlign: TextAlign.center,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: widget.isFocused ? FontWeight.w900 : FontWeight.w400,
            
            // UPDATED: Focused white, Unfocused Kala (black87 is suitable dark color)
            color: widget.isFocused ? Colors.white : Colors.white,
            
            letterSpacing: 0.5,
            height: 1.2,
          ),
          child: Text(widget.getTitle(widget.item)),
        ),
      );
}






// import 'dart:async';
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';

// class ProfessionalColors {
//   static const primaryDark = Color(0xFF0A0E1A);
//   static const surfaceDark = Color(0xFF1A1D29);
//   static const cardDark = Color(0xFF2A2D3A);
//   static const textPrimary = Color(0xFFFFFFFF);
//   static const textSecondary = Color(0xFFB3B3B3);
//   static const accentOrange = Color(0xFFF59E0B);
//   static const accentPurple = Color(0xFF8B5CF6);
// }

// class AnimationTiming {
//   static const Duration fast = Duration(milliseconds: 250);
//   static const Duration medium = Duration(milliseconds: 400);
// }

// class MasterSliderLayout<T> extends StatefulWidget {
//   final String title;
//   final String logoUrl;
//   final bool isLoading;
//   final bool isListLoading;
//   final bool isVideoLoading;
//   final String? errorMessage;
//   final VoidCallback onRetry;

//   final List<String> networkNames;
//   final int selectedNetworkIndex;
//   final Function(int)? onNetworkSelected;

//   final List<String> filterNames;
//   final int selectedFilterIndex;
//   final Function(int) onFilterSelected;
//   final Function(String) onSearch;

//   final List<T> contentList;
//   final Function(T, int) onContentTap;
//   final String Function(T) getTitle;
//   final String Function(T) getImageUrl;

//   final List<String> sliderImages;
//   final List<Color> focusColors;
//   final IconData placeholderIcon;
//   final String emptyMessage;
//   final double cardWidth;
//   final double cardHeight;

//   const MasterSliderLayout({
//     Key? key,
//     required this.title,
//     required this.logoUrl,
//     required this.isLoading,
//     this.isListLoading = false,
//     required this.isVideoLoading,
//     this.errorMessage,
//     required this.onRetry,
//     required this.networkNames,
//     required this.selectedNetworkIndex,
//     this.onNetworkSelected,
//     required this.filterNames,
//     required this.selectedFilterIndex,
//     required this.onFilterSelected,
//     required this.onSearch,
//     required this.contentList,
//     required this.onContentTap,
//     required this.getTitle,
//     required this.getImageUrl,
//     required this.sliderImages,
//     required this.focusColors,
//     required this.placeholderIcon,
//     required this.emptyMessage,
//     required this.cardWidth,
//     required this.cardHeight,
//   }) : super(key: key);

//   @override
//   State<MasterSliderLayout<T>> createState() => _MasterSliderLayoutState<T>();
// }

// class _MasterSliderLayoutState<T> extends State<MasterSliderLayout<T>>
//     with TickerProviderStateMixin {
//   bool _isDisposed = false;
//   bool _shouldFocusFirstItem = false;

//   final FocusNode _widgetFocusNode = FocusNode();
//   late FocusNode _searchButtonFocusNode;
//   List<FocusNode> _networkFocusNodes = [];
//   List<FocusNode> _filterFocusNodes = [];
//   List<FocusNode> _itemFocusNodes = [];
//   List<FocusNode> _keyboardFocusNodes = [];

//   final ScrollController _networkScrollController = ScrollController();
//   final ScrollController _filterScrollController = ScrollController();
//   final ScrollController _itemScrollController = ScrollController();

//   late PageController _sliderPageController;
//   int _currentSliderPage = 0;
//   Timer? _sliderTimer;
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//   late AnimationController _borderAnimationController;

//   bool _isNavigationLocked = false;
//   Timer? _navigationLockTimer;

//   bool _isSearching = false;
//   bool _showKeyboard = false;
//   String _searchText = '';
//   Timer? _debounce;
//   int _focusedKeyRow = 0;
//   int _focusedKeyCol = 0;
//   int _focusedItemIndex = -1;
//   int _lastFocusedItemIndex = 0; 

//   final List<List<String>> _keyboardLayout = [
//     "1234567890".split(''),
//     "qwertyuiop".split(''),
//     "asdfghjkl".split(''),
//     ["z", "x", "c", "v", "b", "n", "m", "DEL"],
//     ["SPACE", "OK"],
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _isDisposed = false;
//     _sliderPageController = PageController();
//     _searchButtonFocusNode = FocusNode()..addListener(_setStateListener);
//     _widgetFocusNode.addListener(_setStateListener);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && !_isDisposed)
//         Provider.of<InternalFocusProvider>(context, listen: false).updateName('');
//     });

//     _fadeController = AnimationController(duration: AnimationTiming.medium, vsync: this);
//     _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

//     _borderAnimationController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this)..repeat();

//     _initializeAllFocusNodes();
//     _setupSliderTimer();
//     _fadeController.forward();
//   }

//   int _getKeyboardNodeIndex(int row, int col) {
//     int idx = 0;
//     for (int i = 0; i < row; i++) idx += _keyboardLayout[i].length;
//     return idx + col;
//   }

//   @override
//   void didUpdateWidget(covariant MasterSliderLayout<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (oldWidget.contentList.length != widget.contentList.length) {
//       _disposeFocusNodes(_itemFocusNodes);
//       _itemFocusNodes = List.generate(widget.contentList.length, (i) => FocusNode()..addListener(_setStateListener));
//       _focusedItemIndex = -1;
//     }
//     if (oldWidget.filterNames.length != widget.filterNames.length) {
//       _disposeFocusNodes(_filterFocusNodes);
//       _filterFocusNodes = List.generate(widget.filterNames.length, (i) => FocusNode()..addListener(_setStateListener));
//     }
//     if (oldWidget.networkNames.length != widget.networkNames.length) {
//       _disposeFocusNodes(_networkFocusNodes);
//       _networkFocusNodes = List.generate(widget.networkNames.length, (i) => FocusNode()..addListener(_setStateListener));
//     }

//     if (oldWidget.sliderImages != widget.sliderImages) {
//       _setupSliderTimer();
//     }

//     bool justFinishedPageLoad = oldWidget.isLoading == true && widget.isLoading == false;
//     bool justFinishedListLoad = oldWidget.isListLoading == true && widget.isListLoading == false;
//     bool contentAppeared = oldWidget.contentList.isEmpty && widget.contentList.isNotEmpty;

//     if ((justFinishedPageLoad || justFinishedListLoad || contentAppeared || _shouldFocusFirstItem) && !_showKeyboard) {
//       if (_shouldFocusFirstItem && !widget.isListLoading && !widget.isLoading) {
//         _shouldFocusFirstItem = false;
//       }

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!_isDisposed && mounted && !_showKeyboard) {
//           if (widget.contentList.isNotEmpty && _itemFocusNodes.isNotEmpty) {
//             Future.delayed(const Duration(milliseconds: 150), () {
//               if (!_isDisposed && mounted && _itemFocusNodes.isNotEmpty && !_showKeyboard) {
//                 setState(() => _focusedItemIndex = 0);
//                 _itemFocusNodes[0].requestFocus();
//                 _scrollToCenter(_itemScrollController, 0, widget.cardWidth + 8, 20);
//                 Provider.of<InternalFocusProvider>(context, listen: false).updateName(widget.getTitle(widget.contentList[0]));
//               }
//             });
//           } else if (justFinishedPageLoad && widget.networkNames.isNotEmpty && _networkFocusNodes.isNotEmpty) {
//             _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//           } else if (justFinishedPageLoad && _searchButtonFocusNode.canRequestFocus) {
//             _searchButtonFocusNode.requestFocus();
//           }
//         }
//       });
//     }
//   }

//   void _initializeAllFocusNodes() {
//     _networkFocusNodes = List.generate(widget.networkNames.length, (i) => FocusNode()..addListener(_setStateListener));
//     _filterFocusNodes = List.generate(widget.filterNames.length, (i) => FocusNode()..addListener(_setStateListener));
//     _itemFocusNodes = List.generate(widget.contentList.length, (i) => FocusNode()..addListener(_setStateListener));
//     int totalKeys = _keyboardLayout.fold(0, (prev, row) => prev + row.length);
//     _keyboardFocusNodes = List.generate(totalKeys, (i) => FocusNode()..addListener(_setStateListener));
//   }

//   void _setStateListener() {
//     if (mounted && !_isDisposed) setState(() {});
//   }

//   void _disposeFocusNodes(List<FocusNode> nodes) {
//     for (var node in nodes) {
//       node.removeListener(_setStateListener);
//       try { node.dispose(); } catch (_) {}
//     }
//     nodes.clear();
//   }

//   @override
//   void dispose() {
//     _isDisposed = true;
//     _sliderTimer?.cancel();
//     _debounce?.cancel();
//     _navigationLockTimer?.cancel();
//     _sliderPageController.dispose();
//     _fadeController.dispose();
//     _borderAnimationController.dispose();
//     _widgetFocusNode.dispose();
//     _searchButtonFocusNode.dispose();
//     _networkScrollController.dispose();
//     _filterScrollController.dispose();
//     _itemScrollController.dispose();
//     _disposeFocusNodes(_networkFocusNodes);
//     _disposeFocusNodes(_filterFocusNodes);
//     _disposeFocusNodes(_itemFocusNodes);
//     _disposeFocusNodes(_keyboardFocusNodes);
//     super.dispose();
//   }

//   void _setupSliderTimer() {
//     _sliderTimer?.cancel();
//     if (widget.sliderImages.length > 1) {
//       _sliderTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
//         if (!_isDisposed && mounted && _sliderPageController.hasClients) {
//           int next = (_sliderPageController.page?.round() ?? 0) + 1;
//           if (next >= widget.sliderImages.length) next = 0;
//           _sliderPageController.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
//         }
//       });
//     }
//   }

//   void _scrollToCenter(ScrollController controller, int index, double itemEffectiveWidth, double listPaddingStart) {
//     if (!controller.hasClients) return;
//     double screenWidth = MediaQuery.of(context).size.width;
//     double itemStartPosition = listPaddingStart + (index * itemEffectiveWidth);
//     double itemCenterPosition = itemStartPosition + (itemEffectiveWidth / 2);
//     double screenCenter = screenWidth / 2;
//     double targetOffset = itemCenterPosition - screenCenter;

//     controller.animateTo(
//       targetOffset.clamp(0.0, controller.position.maxScrollExtent),
//       duration: AnimationTiming.fast,
//       curve: Curves.easeInOut,
//     );
//   }

//   KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
//     if (_isDisposed || event is! RawKeyDownEvent || widget.isLoading) return KeyEventResult.ignored;

//     final key = event.logicalKey;
//     if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape) {
//       if (_showKeyboard) {
//         setState(() { _showKeyboard = false; _focusedKeyRow = 0; _focusedKeyCol = 0; });
//         _searchButtonFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (_itemFocusNodes.any((n) => n.hasFocus) || _filterFocusNodes.any((n) => n.hasFocus) || _searchButtonFocusNode.hasFocus) {
//         if (_networkFocusNodes.isNotEmpty) _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.ignored;
//     }

//     if (_showKeyboard && _keyboardFocusNodes.any((n) => n.hasFocus)) return _navigateKeyboard(key);
//     if (_searchButtonFocusNode.hasFocus) return _navigateSearchBtn(key);
//     if (_networkFocusNodes.any((n) => n.hasFocus)) return _navigateNetworks(key);
//     if (_filterFocusNodes.any((n) => n.hasFocus)) return _navigateFilters(key);
//     if (_itemFocusNodes.any((n) => n.hasFocus)) return _navigateItems(key);

//     return KeyEventResult.ignored;
//   }

//   KeyEventResult _navigateKeyboard(LogicalKeyboardKey key) {
//     int r = _focusedKeyRow, c = _focusedKeyCol;

//     if (key == LogicalKeyboardKey.arrowUp) {
//       if (r > 0) {
//         r--; c = math.min(c, _keyboardLayout[r].length - 1);
//       } else {
//         if (_networkFocusNodes.isNotEmpty) _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//         return KeyEventResult.handled;
//       }
//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       if (r < _keyboardLayout.length - 1) {
//         r++; c = math.min(c, _keyboardLayout[r].length - 1);
//       } else {
//         if (_filterFocusNodes.isNotEmpty) {
//           int targetFilter = widget.selectedFilterIndex >= 0 ? widget.selectedFilterIndex : 0;
//           _filterFocusNodes[targetFilter].requestFocus();
//         } else {
//           _searchButtonFocusNode.requestFocus();
//         }
//         return KeyEventResult.handled;
//       }
//     } else if (key == LogicalKeyboardKey.arrowLeft && c > 0) c--;
//     else if (key == LogicalKeyboardKey.arrowRight && c < _keyboardLayout[r].length - 1) c++;
//     else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _handleKeyClick(_keyboardLayout[r][c]);
//       return KeyEventResult.handled;
//     }

//     if (r != _focusedKeyRow || c != _focusedKeyCol) {
//       setState(() { _focusedKeyRow = r; _focusedKeyCol = c; });
//       int idx = _getKeyboardNodeIndex(r, c);
//       if (idx < _keyboardFocusNodes.length) _keyboardFocusNodes[idx].requestFocus();
//     }
//     return KeyEventResult.handled;
//   }

//   void _handleKeyClick(String val) {
//     setState(() {
//       if (val == "OK") {
//         _showKeyboard = false;
//         _debounce?.cancel();
//         widget.onSearch(_searchText.trim());
//         _shouldFocusFirstItem = true;
//         _searchButtonFocusNode.requestFocus();
//       } else {
//         if (val == "DEL") {
//           if (_searchText.isNotEmpty) _searchText = _searchText.substring(0, _searchText.length - 1);
//         } else if (val == "SPACE") {
//           _searchText += " ";
//         } else {
//           _searchText += val;
//         }

//         _isSearching = _searchText.isNotEmpty;

//         _debounce?.cancel();
//         _debounce = Timer(const Duration(seconds: 10), () {
//           if (mounted && _showKeyboard) widget.onSearch(_searchText.trim());
//         });
//       }
//     });
//   }

//   KeyEventResult _navigateSearchBtn(LogicalKeyboardKey key) {
//     if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       setState(() => _showKeyboard = true);
//       if (_keyboardFocusNodes.isNotEmpty) _keyboardFocusNodes[0].requestFocus();
//     } else if (key == LogicalKeyboardKey.arrowRight && _filterFocusNodes.isNotEmpty) {
//       _filterFocusNodes[0].requestFocus();
//     } else if (key == LogicalKeyboardKey.arrowUp) {
//       if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
//         setState(() { _focusedKeyRow = _keyboardLayout.length - 1; _focusedKeyCol = 0; });
//         _keyboardFocusNodes[_getKeyboardNodeIndex(_focusedKeyRow, _focusedKeyCol)].requestFocus();
//       } else if (_networkFocusNodes.isNotEmpty) {
//         _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//       }
//     } else if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
//       int target = _lastFocusedItemIndex;
//       if (target >= _itemFocusNodes.length) target = _itemFocusNodes.length - 1;
//       if (target < 0) target = 0;

//       setState(() => _focusedItemIndex = target);
//       _itemFocusNodes[target].requestFocus();
//     }
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateNetworks(LogicalKeyboardKey key) {
//     int focusedIndex = _networkFocusNodes.indexWhere((n) => n.hasFocus);
//     if (focusedIndex == -1) focusedIndex = widget.selectedNetworkIndex;

//     if (key == LogicalKeyboardKey.arrowLeft && focusedIndex > 0) focusedIndex--;
//     else if (key == LogicalKeyboardKey.arrowRight && focusedIndex < _networkFocusNodes.length - 1) focusedIndex++;
//     else if (key == LogicalKeyboardKey.arrowDown) {
//       if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
//         setState(() { _focusedKeyRow = 0; _focusedKeyCol = 0; });
//         _keyboardFocusNodes[0].requestFocus();
//       } else {
//         _searchButtonFocusNode.requestFocus();
//       }
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _shouldFocusFirstItem = true;
//       if (widget.onNetworkSelected != null) widget.onNetworkSelected!(focusedIndex);
//       return KeyEventResult.handled;
//     }

//     if (focusedIndex != _networkFocusNodes.indexWhere((n) => n.hasFocus)) {
//       _networkFocusNodes[focusedIndex].requestFocus();
//       _scrollToCenter(_networkScrollController, focusedIndex, 160, 20);
//     }
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateFilters(LogicalKeyboardKey key) {
//     int focusedIndex = _filterFocusNodes.indexWhere((n) => n.hasFocus);
//     if (focusedIndex == -1) focusedIndex = widget.selectedFilterIndex;

//     if (key == LogicalKeyboardKey.arrowLeft) {
//       if (focusedIndex > 0) focusedIndex--;
//       else { _searchButtonFocusNode.requestFocus(); return KeyEventResult.handled; }
//     } else if (key == LogicalKeyboardKey.arrowRight && focusedIndex < _filterFocusNodes.length - 1) focusedIndex++;
//     else if (key == LogicalKeyboardKey.arrowUp) {
//       if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
//         setState(() { _focusedKeyRow = _keyboardLayout.length - 1; _focusedKeyCol = 0; });
//         _keyboardFocusNodes[_getKeyboardNodeIndex(_focusedKeyRow, _focusedKeyCol)].requestFocus();
//       } else if (_networkFocusNodes.isNotEmpty) {
//         _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//       }
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
//       int target = _lastFocusedItemIndex;
//       if (target >= _itemFocusNodes.length) target = _itemFocusNodes.length - 1;
//       if (target < 0) target = 0;

//       setState(() => _focusedItemIndex = target);
//       _itemFocusNodes[target].requestFocus();
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _shouldFocusFirstItem = true;
//       widget.onFilterSelected(focusedIndex);
//       return KeyEventResult.handled;
//     }

//     if (focusedIndex != _filterFocusNodes.indexWhere((n) => n.hasFocus)) {
//       _filterFocusNodes[focusedIndex].requestFocus();
//       _scrollToCenter(_filterScrollController, focusedIndex, 160, 20);
//     }
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateItems(LogicalKeyboardKey key) {
//     if (_isNavigationLocked) return KeyEventResult.handled;
//     _isNavigationLocked = true;
//     _navigationLockTimer = Timer(const Duration(milliseconds: 300), () {
//       if (mounted) setState(() => _isNavigationLocked = false);
//     });

//     int i = _focusedItemIndex;
//     if (key == LogicalKeyboardKey.arrowUp) {
//       _lastFocusedItemIndex = _focusedItemIndex >= 0 ? _focusedItemIndex : 0;

//       if (_filterFocusNodes.isNotEmpty && widget.selectedFilterIndex >= 0)
//         _filterFocusNodes[widget.selectedFilterIndex].requestFocus();
//       else
//         _searchButtonFocusNode.requestFocus();

//       setState(() => _focusedItemIndex = -1);
//       _isNavigationLocked = false;
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.arrowLeft && i > 0) i--;
//     else if (key == LogicalKeyboardKey.arrowRight && i < _itemFocusNodes.length - 1) i++;
//     else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _isNavigationLocked = false;
//       widget.onContentTap(widget.contentList[i], i);
//       return KeyEventResult.handled;
//     }

//     if (i != _focusedItemIndex && i >= 0 && i < _itemFocusNodes.length) {
//       setState(() => _focusedItemIndex = i);
//       _itemFocusNodes[i].requestFocus();
//       _scrollToCenter(_itemScrollController, i, widget.cardWidth + 8, 20);
//       Provider.of<InternalFocusProvider>(context, listen: false).updateName(widget.getTitle(widget.contentList[i]));
//     } else {
//       _isNavigationLocked = false;
//     }
//     return KeyEventResult.handled;
//   }

//   // ==========================================================
//   // BUILD UI
//   // ==========================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ProfessionalColors.primaryDark,
//       body: Focus(
//         focusNode: _widgetFocusNode,
//         autofocus: true,
//         onKey: _onKeyHandler,
//         child: Stack(
//           children: [
//             _buildBackgroundSlider(),
//             FadeTransition(
//               opacity: _fadeAnimation,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (widget.networkNames.isNotEmpty) ...[
//                     _buildTopFilterBar(),
//                     // Newly Added Title Below Network Filter Bar
//                     _buildFocusedTitleBar(),
//                   ],
//                   if (widget.networkNames.isEmpty) ...[
//                     SizedBox(height: MediaQuery.of(context).padding.top + 20),
//                     _buildBeautifulAppBar(),
//                   ],
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                             height: widget.networkNames.isNotEmpty?MediaQuery.of(context).size.height * 0.35:MediaQuery.of(context).size.height * 0.45,
//                             child: _showKeyboard ? _buildSearchUI() : const SizedBox.shrink()),
//                         _buildSliderIndicators(),
//                         _buildFilterBar(),
//                         const SizedBox(height: 30),
//                         _buildContentArea(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (widget.isLoading && widget.contentList.isEmpty && widget.filterNames.isEmpty)
//               Container(
//                 color: ProfessionalColors.primaryDark,
//                 child: const Center(child: CircularProgressIndicator(color: Colors.white)),
//               ),
//             if (widget.isVideoLoading && widget.errorMessage == null)
//               Positioned.fill(
//                   child: Container(
//                       color: Colors.black87,
//                       child: const Center(child: CircularProgressIndicator(color: Colors.white)))),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContentArea() {
//     if (widget.errorMessage != null) return Expanded(child: _buildErrorWidget());
//     if (widget.isLoading || widget.isListLoading) {
//       return const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.white)));
//     }
//     return _buildContentList();
//   }

//   Widget _buildBeautifulAppBar() {
//     final focusName = context.watch<InternalFocusProvider>().focusedItemName;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//       decoration: BoxDecoration(
//           gradient: LinearGradient(
//               colors: [Colors.black.withOpacity(0.0), Colors.transparent],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter)),
//       child: Row(
//         children: [
//           Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white)),
//           const SizedBox(width: 20),
//           Expanded(
//               child: Text(focusName,
//                   style: const TextStyle(color: ProfessionalColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 20),
//                   overflow: TextOverflow.ellipsis)),
//         ],
//       ),
//     );
//   }

//   // This is the new widget to show the focused image name below _buildTopFilterBar
//   Widget _buildFocusedTitleBar() {
//     final focusName = context.watch<InternalFocusProvider>().focusedItemName;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//       child: Text(
//         focusName,
//         style: const TextStyle(
//           color: ProfessionalColors.textSecondary,
//           fontWeight: FontWeight.w600,
//           fontSize: 20,
//         ),
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }

//   Widget _buildTopFilterBar() {
//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5, bottom: 5, left: 20),
//           decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1))),
//           child: Row(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 35,
//                   child: ListView.builder(
//                     controller: _networkScrollController,
//                     scrollDirection: Axis.horizontal,
//                     itemCount: widget.networkNames.length,
//                     itemBuilder: (ctx, i) {
//                       if (i >= _networkFocusNodes.length) return const SizedBox.shrink();
//                       bool isSelected = widget.selectedNetworkIndex == i;
//                       return Focus(
//                         focusNode: _networkFocusNodes[i],
//                         onFocusChange: (has) {
//                           if (has && !_isDisposed) _scrollToCenter(_networkScrollController, i, 160, 20);
//                         },
//                         child: _buildGlassButton(
//                           focusNode: _networkFocusNodes[i],
//                           isSelected: isSelected,
//                           color: widget.focusColors[i % widget.focusColors.length],
//                           label: widget.networkNames[i].toUpperCase(),
//                           onTap: () {
//                             _shouldFocusFirstItem = true;
//                             if (widget.onNetworkSelected != null) widget.onNetworkSelected!(i);
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterBar() {
//     if (widget.filterNames.isEmpty && !_isSearching) return const SizedBox(height: 30);
//     return SizedBox(
//       height: 35,
//       child: ListView.builder(
//         controller: _filterScrollController,
//         scrollDirection: Axis.horizontal,
//         itemCount: widget.filterNames.length + 1,
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         itemBuilder: (ctx, i) {
//           if (i == 0) {
//             return Focus(
//               focusNode: _searchButtonFocusNode,
//               onFocusChange: (has) {
//                 if (has && !_isDisposed) {
//                   Provider.of<InternalFocusProvider>(context, listen: false).updateName("SEARCH");
//                   _scrollToCenter(_filterScrollController, 0, 160, 20);
//                 }
//               },
//               child: _buildGlassButton(
//                 focusNode: _searchButtonFocusNode,
//                 isSelected: _isSearching || _showKeyboard,
//                 color: ProfessionalColors.accentOrange,
//                 label: "SEARCH",
//                 icon: Icons.search,
//                 onTap: () => setState(() { _showKeyboard = true; _searchButtonFocusNode.requestFocus(); }),
//               ),
//             );
//           }
//           int filterIdx = i - 1;
//           if (filterIdx >= _filterFocusNodes.length) return const SizedBox.shrink();
//           return Focus(
//             focusNode: _filterFocusNodes[filterIdx],
//             onFocusChange: (has) {
//               if (has && !_isDisposed) _scrollToCenter(_filterScrollController, i, 160, 20);
//             },
//             child: _buildGlassButton(
//               focusNode: _filterFocusNodes[filterIdx],
//               isSelected: !_isSearching && widget.selectedFilterIndex == filterIdx,
//               color: widget.focusColors[filterIdx % widget.focusColors.length],
//               label: widget.filterNames[filterIdx].toUpperCase(),
//               onTap: () {
//                 _shouldFocusFirstItem = true;
//                 widget.onFilterSelected(filterIdx);
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Widget _buildContentList() {
//   //   if (widget.contentList.isEmpty) {
//   //     return Expanded(child: Center(child: Text(widget.emptyMessage, style: const TextStyle(color: Colors.white54, fontSize: 18))));
//   //   }
//   //   return Expanded(
//   //     child: ListView.builder(
//   //       controller: _itemScrollController,
//   //       scrollDirection: Axis.horizontal,
//   //       padding: const EdgeInsets.symmetric(horizontal: 20),
//   //       clipBehavior: Clip.none, 
//   //       itemCount: widget.contentList.length,
//   //       itemBuilder: (ctx, i) {
//   //         if (i >= _itemFocusNodes.length) return const SizedBox.shrink();
//   //         final item = widget.contentList[i];
//   //         return 
//   //         Material(
//   //         color: Colors.transparent,
//   //         type: MaterialType.transparency,
//   //         child:
//   //         _MasterSliderCard<T>(
//   //           item: item,
//   //           key: ValueKey(i),
//   //           focusNode: _itemFocusNodes[i],
//   //           isFocused: _focusedItemIndex == i,
//   //           focusColor: widget.focusColors[i % widget.focusColors.length],
//   //           onTap: () => widget.onContentTap(item, i),
//   //           onFocusChange: (has) {
//   //             if (has && !_isDisposed) {
//   //               if (_focusedItemIndex != i) {
//   //                 setState(() => _focusedItemIndex = i);
//   //                 _scrollToCenter(_itemScrollController, i, widget.cardWidth + 8, 20);
//   //                 Provider.of<InternalFocusProvider>(context, listen: false).updateName(widget.getTitle(item));
//   //               }
//   //             }
//   //           },
//   //           getTitle: widget.getTitle,
//   //           getImageUrl: widget.getImageUrl,
//   //           cardWidth: widget.cardWidth,
//   //           cardHeight: widget.cardHeight,
//   //           placeholderIcon: widget.placeholderIcon,
//   //           logoUrl: widget.logoUrl,
//   //         ));
//   //       },
//   //     ),
//   //   );
//   // }


// Widget _buildContentList() {
//     if (widget.contentList.isEmpty) {
//       return Expanded(child: Center(child: Text(widget.emptyMessage, style: const TextStyle(color: Colors.white54, fontSize: 18))));
//     }

//     // The physical step width of each item MUST match the sizing in _MasterSliderCard
//     final double stepWidth = widget.cardWidth + 20;

//     return Expanded(
//       child: SingleChildScrollView(
//         controller: _itemScrollController,
//         scrollDirection: Axis.horizontal,
//         clipBehavior: Clip.none,
//         // The vertical: 40 padding prevents the bottom overflow error during the 1.3x scale
//         padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 1), 
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             // Row of background items
//             Row(
//               children: List.generate(widget.contentList.length, (i) {
//                 final item = widget.contentList[i];
//                 bool isFocused = _focusedItemIndex == i;

//                 return Opacity(
//                   opacity: isFocused ? 0.0 : 1.0, 
//                   child: _buildItemCard(item, i),
//                 );
//               }),
//             ),
            
//             // Focused Item Overlay (Z-Index fix)
//             if (_focusedItemIndex >= 0 && _focusedItemIndex < widget.contentList.length)
//               Positioned(
//                 left: _focusedItemIndex * stepWidth, // perfectly synced positioning
//                 top: 0, 
//                 child: _buildItemCard(widget.contentList[_focusedItemIndex], _focusedItemIndex, forceFocused: true),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

// // Helper method taaki code repeat na ho
// Widget _buildItemCard(T item, int i, {bool forceFocused = false}) {
//   return _MasterSliderCard<T>(
//     key: ValueKey("card_$i"),
//     item: item,
//     focusNode: _itemFocusNodes[i],
//     isFocused: forceFocused || _focusedItemIndex == i,
//     focusColor: widget.focusColors[i % widget.focusColors.length],
//     onTap: () => widget.onContentTap(item, i),
//     onFocusChange: (has) {
//       if (has && !_isDisposed) {
//         if (_focusedItemIndex != i) {
//           setState(() => _focusedItemIndex = i);
//           _scrollToCenter(_itemScrollController, i, widget.cardWidth + 8, 60);
//           Provider.of<InternalFocusProvider>(context, listen: false).updateName(widget.getTitle(item));
//         }
//       }
//     },
//     getTitle: widget.getTitle,
//     getImageUrl: widget.getImageUrl,
//     cardWidth: widget.cardWidth,
//     cardHeight: widget.cardHeight,
//     placeholderIcon: widget.placeholderIcon,
//     logoUrl: widget.logoUrl,
//   );
// }

//   Widget _buildGlassButton({required FocusNode focusNode, required bool isSelected, required Color color, required String label, IconData? icon, required VoidCallback onTap}) {
//     bool hasFocus = focusNode.hasFocus;
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(right: 12),
//         child: AnimatedBuilder(
//           animation: _borderAnimationController,
//           builder: (context, child) {
//             return Stack(
//               alignment: Alignment.center,
//               children: [
//                 if (hasFocus)
//                   Positioned.fill(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(30),
//                         gradient: SweepGradient(
//                           colors: [
//                             Colors.white.withOpacity(0.1),
//                             Colors.white,
//                             Colors.white,
//                             Colors.white.withOpacity(0.1)
//                           ],
//                           stops: const [0.0, 0.25, 0.5, 1.0],
//                           transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
//                         ),
//                       ),
//                     ),
//                   ),
//                 Padding(
//                   padding: EdgeInsets.all(hasFocus ? 3.0 : 0.0),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(30),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                       child: AnimatedContainer(
//                         duration: AnimationTiming.fast,
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: hasFocus ? color : isSelected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(30),
//                           border: !hasFocus ? Border.all(color: Colors.white.withOpacity(0.3), width: 2) : null,
//                           boxShadow: (hasFocus || isSelected) ? [BoxShadow(color: color.withOpacity(0.8), blurRadius: 15)] : null,
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             if (icon != null) ...[Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 8)],
//                             Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchUI() {
//     return Row(
//       children: [
//         Expanded(
//           flex: 4,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text("SEARCH", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
//               const SizedBox(height: 24),
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 40),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10), border: Border.all(color: ProfessionalColors.accentPurple)),
//                 child: Text(_searchText.isEmpty ? 'Typing...' : _searchText, style: const TextStyle(color: Colors.white, fontSize: 22)),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           flex: 6,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: _keyboardLayout.asMap().entries.map((r) => Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: r.value.asMap().entries.map((c) {
//                     int idx = _keyboardLayout.take(r.key).fold(0, (p, e) => p + e.length) + c.key;
//                     if (idx >= _keyboardFocusNodes.length) return const SizedBox.shrink();
//                     bool isFocused = _focusedKeyRow == r.key && _focusedKeyCol == c.key;
//                     String key = c.value;
//                     double w = key == 'SPACE' ? 150 : (key == 'OK' || key == 'DEL' ? 70 : 40);
//                     return Container(
//                       width: w,
//                       height: 25,
//                       margin: const EdgeInsets.all(4),
//                       child: Focus(
//                         focusNode: _keyboardFocusNodes[idx],
//                         onFocusChange: (has) {
//                           if (has) setState(() { _focusedKeyRow = r.key; _focusedKeyCol = c.key; });
//                         },
//                         child: ElevatedButton(
//                           onPressed: () => _handleKeyClick(key),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: isFocused ? ProfessionalColors.accentPurple : Colors.white10,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 side: isFocused ? const BorderSide(color: Colors.white, width: 2) : BorderSide.none),
//                             padding: EdgeInsets.zero,
//                           ),
//                           child: Text(key, style: const TextStyle(color: Colors.white, fontSize: 18)),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 )).toList(),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _buildBackgroundSlider() {
//     if (widget.sliderImages.isEmpty) return Container(color: ProfessionalColors.primaryDark);
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         PageView.builder(
//           controller: _sliderPageController,
//           itemCount: widget.sliderImages.length,
//           itemBuilder: (c, i) => CachedNetworkImage(
//               imageUrl: widget.sliderImages[i], fit: BoxFit.fill, errorWidget: (c, u, e) => Container(color: ProfessionalColors.surfaceDark)),
//         ),
//       ],
//     );
//   }

//   Widget _buildSliderIndicators() {
//     if (widget.sliderImages.length <= 1) return const SizedBox(height: 26);
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(
//           widget.sliderImages.length,
//           (i) => AnimatedContainer(
//                 duration: AnimationTiming.fast,
//                 margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
//                 height: 6,
//                 width: _currentSliderPage == i ? 20 : 6,
//                 decoration: BoxDecoration(
//                     color: _currentSliderPage == i ? Colors.white : Colors.white54,
//                     borderRadius: BorderRadius.circular(10)),
//               )),
//     );
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.cloud_off, color: Colors.red, size: 60),
//           const SizedBox(height: 20),
//           Text(widget.errorMessage ?? 'Something went wrong', style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             focusNode: FocusNode(),
//             onPressed: widget.onRetry,
//             icon: const Icon(Icons.refresh),
//             label: const Text('Try Again'),
//           )
//         ],
//       ),
//     );
//   }
// }

// class _MasterSliderCard<T> extends StatefulWidget {
//   final T item;
//   final FocusNode focusNode;
//   final bool isFocused;
//   final Color focusColor;
//   final VoidCallback onTap;
//   final Function(bool) onFocusChange;
//   final String Function(T) getTitle;
//   final String Function(T) getImageUrl;
//   final double cardWidth;
//   final double cardHeight;
//   final IconData placeholderIcon;
//   final String logoUrl;

//   const _MasterSliderCard({
//     Key? key,
//     required this.item,
//     required this.focusNode,
//     required this.isFocused,
//     required this.focusColor,
//     required this.onTap,
//     required this.onFocusChange,
//     required this.getTitle,
//     required this.getImageUrl,
//     required this.cardWidth,
//     required this.cardHeight,
//     required this.placeholderIcon,
//     required this.logoUrl,
//   }) : super(key: key);

//   @override
//   __MasterSliderCardState<T> createState() => __MasterSliderCardState<T>();
// }

// class __MasterSliderCardState<T> extends State<_MasterSliderCard<T>> with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _borderAnimationController;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
//     _borderAnimationController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
//     widget.focusNode.addListener(_handleFocus);
//     _syncFocusState();
//   }

//   @override
//   void didUpdateWidget(covariant _MasterSliderCard<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.focusNode != widget.focusNode) {
//       oldWidget.focusNode.removeListener(_handleFocus);
//       widget.focusNode.addListener(_handleFocus);
//     }
//     if (oldWidget.isFocused != widget.isFocused) {
//       _syncFocusState();
//     }
//   }

//   void _syncFocusState() {
//     if (widget.isFocused) {
//       _scaleController.forward();
//       if (!_borderAnimationController.isAnimating) _borderAnimationController.repeat();
//     } else {
//       _scaleController.reverse();
//       _borderAnimationController.stop();
//     }
//   }

//   void _handleFocus() {
//     if (!mounted) return;
//     widget.onFocusChange(widget.focusNode.hasFocus);
//   }

//   @override
//   void dispose() {
//     widget.focusNode.removeListener(_handleFocus);
//     _scaleController.dispose();
//     _borderAnimationController.dispose();
//     super.dispose();
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return Container(
//   //     width: widget.cardWidth + 8, 
//   //     alignment: Alignment.center,
//   //     child: Column(
//   //       mainAxisSize: MainAxisSize.min,
//   //       mainAxisAlignment: MainAxisAlignment.center,
//   //       crossAxisAlignment: CrossAxisAlignment.center,
//   //       children: [
//   //         AnimatedBuilder(
//   //           animation: _scaleAnimation,
//   //           builder: (context, child) => Transform.scale(
//   //             scale: _scaleAnimation.value,
//   //             child: GestureDetector(
//   //               onTap: widget.onTap,
//   //               child: Focus(
//   //                 focusNode: widget.focusNode,
//   //                 child: _buildPoster(),
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //         const SizedBox(height: 12),
//   //         _buildTitle(),
//   //       ],
//   //     ),
//   //   );
//   // }



// //   @override
// // Widget build(BuildContext context) {
// //   // Is logic se focused item ki hierarchy priority badh jayegi
// //   return Center(
// //     child: SizedBox(
// //       width: widget.cardWidth + 8,
// //       // Stack ka use isliye taaki agar Scale ho toh wo piche waale items ke upar overlay kare
// //       child: Stack(
// //         clipBehavior: Clip.none,
// //         alignment: Alignment.center,
// //         children: [
// //           Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               AnimatedBuilder(
// //                 animation: _scaleAnimation,
// //                 builder: (context, child) => Transform.scale(
// //                   scale: _scaleAnimation.value,
// //                   // Tiling/Overlap fix: 
// //                   // Agar focused hai toh iska order priority high honi chahiye
// //                   child: Container(
// //                     child: GestureDetector(
// //                       onTap: widget.onTap,
// //                       child: Focus(
// //                         focusNode: widget.focusNode,
// //                         child: _buildPoster(),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 12),
// //               _buildTitle(),
// //             ],
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// // }



// @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: widget.cardWidth + 20, // 20px total spacing buffer
//       child: AnimatedBuilder(
//         animation: _scaleAnimation,
//         builder: (context, child) {
//           return Transform.scale(
//             scale: _scaleAnimation.value,
//             child: Column(
//               children: [
//                 Container(
//                   // Centers the scaling visually within the 20px buffer
//                   margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 1), 
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       if (widget.isFocused)
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.5),
//                           blurRadius: 5,
//                           spreadRadius: 5,
//                         )
//                     ],
//                   ),
//                   child: GestureDetector(
//                     onTap: widget.onTap,
//                     child: Focus(
//                       focusNode: widget.focusNode,
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min, // Prevents vertical stretching
//                         children: [
//                           _buildPoster(),
//                           // const SizedBox(height: 12),
//                           // _buildTitle(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 _buildTitle(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildPoster() {
//     return Container(
//       height: widget.cardHeight,
//       width: widget.cardWidth,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           if (widget.isFocused)
//             BoxShadow(color: Colors.black.withOpacity(0.7), blurRadius: 10, spreadRadius: 5, offset: const Offset(0, 15))
//           // else
//             // BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))
//         ],
//       ),
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           if (widget.isFocused)
//             AnimatedBuilder(
//               animation: _borderAnimationController,
//               builder: (context, child) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     gradient: SweepGradient(
//                       colors: [
//                         Colors.white.withOpacity(0.1),
//                         Colors.white,
//                         Colors.white,
//                         Colors.white.withOpacity(0.1)
//                       ],
//                       stops: const [0.0, 0.25, 0.5, 1.0],
//                       transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           Padding(
//             padding: EdgeInsets.all(widget.isFocused ? 3.5 : 0.0),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(widget.isFocused ? 5 : 8),
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   CachedNetworkImage(
//                     imageUrl: widget.getImageUrl(widget.item),
//                     fit: BoxFit.cover,
//                     placeholder: (c, u) => _placeholder(),
//                     errorWidget: (c, u, e) => _placeholder(),
//                   ),
//                   if (widget.logoUrl.isNotEmpty)
//                     Positioned(
//                         top: 5,
//                         right: 5,
//                         child: CircleAvatar(
//                             radius: 12, backgroundImage: CachedNetworkImageProvider(widget.logoUrl), backgroundColor: Colors.black54)),
//                 ],
//               ),
//             ),
//           ),
//           if (widget.isFocused)
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _placeholder() => Container(
//         color: ProfessionalColors.cardDark,
//         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Icon(widget.placeholderIcon, size: widget.cardHeight * 0.25, color: Colors.grey),
//         ]),
//       );

//   Widget _buildTitle() => Container(
//         width: widget.cardWidth,
//         padding: const EdgeInsets.symmetric(horizontal: 4),
//         height: 48, 
//         alignment: Alignment.topCenter,
//         child: AnimatedDefaultTextStyle(
//           duration: const Duration(milliseconds: 250),
//           textAlign: TextAlign.center,
//           softWrap: true,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: widget.isFocused ? FontWeight.w800 : FontWeight.w600,
//             color: widget.isFocused ? Colors.white : Colors.white70,
//             letterSpacing: 0.5,
//             height: 1.2,
//           ),
//           child: Text(widget.getTitle(widget.item)),
//         ),
//       );
// }

