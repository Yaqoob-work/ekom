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
//       if (mounted && !_isDisposed) Provider.of<FocusProvider>(context, listen: false).updateName('');
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
//                   Provider.of<FocusProvider>(context, listen: false).updateName(widget.getTitle(widget.contentList[0]));
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
//       Provider.of<FocusProvider>(context, listen: false).updateName(widget.getTitle(widget.contentList[i]));
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
//     final focusName = context.watch<FocusProvider>().focusedItemName;
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
//                 if (has && !_isDisposed) Provider.of<FocusProvider>(context, listen: false).updateName("SEARCH");
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
//                   Provider.of<FocusProvider>(context, listen: false).updateName(widget.getTitle(item));
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





// import 'dart:async';
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// // Assuming these exist in your project, keeping imports as is.
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/provider/internal_focus_provider.dart';
// // If smart_style_image_card is not used anymore in this file, you can remove this.
// // import 'package:mobi_tv_entertainment/components/widgets/smart_style_image_card.dart';

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
//   // Separate controller for button border animation to sync with cards
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
//   int _lastFocusedItemIndex = 0; // Remembers position in the list

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
//         Provider.of<FocusProvider>(context, listen: false)
//             .updateName('');
//     });

//     _fadeController =
//         AnimationController(duration: AnimationTiming.medium, vsync: this);
//     _fadeAnimation =
//         CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

//     // Initialize border animation for buttons
//     _borderAnimationController =
//         AnimationController(duration: const Duration(milliseconds: 2500), vsync: this)
//           ..repeat();

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
//       _itemFocusNodes = List.generate(widget.contentList.length,
//           (i) => FocusNode()..addListener(_setStateListener));
//       _focusedItemIndex = -1;
//     }
//     if (oldWidget.filterNames.length != widget.filterNames.length) {
//       _disposeFocusNodes(_filterFocusNodes);
//       _filterFocusNodes = List.generate(widget.filterNames.length,
//           (i) => FocusNode()..addListener(_setStateListener));
//     }
//     if (oldWidget.networkNames.length != widget.networkNames.length) {
//       _disposeFocusNodes(_networkFocusNodes);
//       _networkFocusNodes = List.generate(widget.networkNames.length,
//           (i) => FocusNode()..addListener(_setStateListener));
//     }

//     if (oldWidget.sliderImages != widget.sliderImages) {
//       _setupSliderTimer();
//     }

//     bool justFinishedPageLoad =
//         oldWidget.isLoading == true && widget.isLoading == false;
//     bool justFinishedListLoad =
//         oldWidget.isListLoading == true && widget.isListLoading == false;
//     bool contentAppeared =
//         oldWidget.contentList.isEmpty && widget.contentList.isNotEmpty;

//     if ((justFinishedPageLoad ||
//             justFinishedListLoad ||
//             contentAppeared ||
//             _shouldFocusFirstItem) &&
//         !_showKeyboard) {
//       if (_shouldFocusFirstItem && !widget.isListLoading && !widget.isLoading) {
//         _shouldFocusFirstItem = false;
//       }

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!_isDisposed && mounted && !_showKeyboard) {
//           if (widget.contentList.isNotEmpty && _itemFocusNodes.isNotEmpty) {
//             Future.delayed(const Duration(milliseconds: 150), () {
//               if (!_isDisposed &&
//                   mounted &&
//                   _itemFocusNodes.isNotEmpty &&
//                   !_showKeyboard) {
//                 setState(() => _focusedItemIndex = 0);
//                 _itemFocusNodes[0].requestFocus();
//                 // Card width is defined as effective width due to symmetric margin 15+15
//                 _scrollToCenter(_itemScrollController, 0, widget.cardWidth + 30, 20);
//                 Provider.of<FocusProvider>(context, listen: false)
//                     .updateName(widget.getTitle(widget.contentList[0]));
//               }
//             });
//           } else if (justFinishedPageLoad &&
//               widget.networkNames.isNotEmpty &&
//               _networkFocusNodes.isNotEmpty) {
//             _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//           } else if (justFinishedPageLoad &&
//               _searchButtonFocusNode.canRequestFocus) {
//             _searchButtonFocusNode.requestFocus();
//           }
//         }
//       });
//     }
//   }

//   void _initializeAllFocusNodes() {
//     _networkFocusNodes = List.generate(widget.networkNames.length,
//         (i) => FocusNode()..addListener(_setStateListener));
//     _filterFocusNodes = List.generate(widget.filterNames.length,
//         (i) => FocusNode()..addListener(_setStateListener));
//     _itemFocusNodes = List.generate(widget.contentList.length,
//         (i) => FocusNode()..addListener(_setStateListener));
//     int totalKeys = _keyboardLayout.fold(0, (prev, row) => prev + row.length);
//     _keyboardFocusNodes = List.generate(
//         totalKeys, (i) => FocusNode()..addListener(_setStateListener));
//   }

//   void _setStateListener() {
//     if (mounted && !_isDisposed) setState(() {});
//   }

//   void _disposeFocusNodes(List<FocusNode> nodes) {
//     for (var node in nodes) {
//       node.removeListener(_setStateListener);
//       try {
//         node.dispose();
//       } catch (_) {}
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
//           _sliderPageController.animateToPage(next,
//               duration: const Duration(milliseconds: 500),
//               curve: Curves.easeInOut);
//         }
//       });
//     }
//   }

//   // UPDATED: Standard robust centering logic
//   void _scrollToCenter(ScrollController controller, int index, double itemEffectiveWidth, double listPaddingStart) {
//     if (!controller.hasClients) return;
//     double screenWidth = MediaQuery.of(context).size.width;
    
//     // Calculate start position of item within viewport context (assuming linear layout)
//     double itemStartPosition = listPaddingStart + (index * itemEffectiveWidth);
//     // Center of the item relative to the list start
//     double itemCenterPosition = itemStartPosition + (itemEffectiveWidth / 2);
//     // Half screen width is where we want that center to be
//     double screenCenter = screenWidth / 2;
    
//     // Desired offset is item center minus half screen
//     double targetOffset = itemCenterPosition - screenCenter;

//     controller.animateTo(
//       targetOffset.clamp(0.0, controller.position.maxScrollExtent),
//       duration: AnimationTiming.fast,
//       curve: Curves.easeInOut,
//     );
//   }

//   KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
//     if (_isDisposed || event is! RawKeyDownEvent || widget.isLoading)
//       return KeyEventResult.ignored;

//     final key = event.logicalKey;
//     if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape) {
//       if (_showKeyboard) {
//         setState(() {
//           _showKeyboard = false;
//           _focusedKeyRow = 0;
//           _focusedKeyCol = 0;
//         });
//         _searchButtonFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (_itemFocusNodes.any((n) => n.hasFocus) ||
//           _filterFocusNodes.any((n) => n.hasFocus) ||
//           _searchButtonFocusNode.hasFocus) {
//         if (_networkFocusNodes.isNotEmpty)
//           _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.ignored;
//     }

//     if (_showKeyboard && _keyboardFocusNodes.any((n) => n.hasFocus))
//       return _navigateKeyboard(key);
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
//         r--;
//         c = math.min(c, _keyboardLayout[r].length - 1);
//       } else {
//         if (_networkFocusNodes.isNotEmpty) {
//           _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//         }
//         return KeyEventResult.handled;
//       }
//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       if (r < _keyboardLayout.length - 1) {
//         r++;
//         c = math.min(c, _keyboardLayout[r].length - 1);
//       } else {
//         if (_filterFocusNodes.isNotEmpty) {
//           int targetFilter =
//               widget.selectedFilterIndex >= 0 ? widget.selectedFilterIndex : 0;
//           _filterFocusNodes[targetFilter].requestFocus();
//         } else {
//           _searchButtonFocusNode.requestFocus();
//         }
//         return KeyEventResult.handled;
//       }
//     } else if (key == LogicalKeyboardKey.arrowLeft && c > 0)
//       c--;
//     else if (key == LogicalKeyboardKey.arrowRight &&
//         c < _keyboardLayout[r].length - 1)
//       c++;
//     else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _handleKeyClick(_keyboardLayout[r][c]);
//       return KeyEventResult.handled;
//     }

//     if (r != _focusedKeyRow || c != _focusedKeyCol) {
//       setState(() {
//         _focusedKeyRow = r;
//         _focusedKeyCol = c;
//       });
//       int idx = _getKeyboardNodeIndex(r, c);
//       if (idx < _keyboardFocusNodes.length)
//         _keyboardFocusNodes[idx].requestFocus();
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
//           if (_searchText.isNotEmpty)
//             _searchText = _searchText.substring(0, _searchText.length - 1);
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
//         setState(() {
//           _focusedKeyRow = _keyboardLayout.length - 1;
//           _focusedKeyCol = 0;
//         });
//         _keyboardFocusNodes[_getKeyboardNodeIndex(_focusedKeyRow, _focusedKeyCol)]
//             .requestFocus();
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

//     if (key == LogicalKeyboardKey.arrowLeft && focusedIndex > 0)
//       focusedIndex--;
//     else if (key == LogicalKeyboardKey.arrowRight &&
//         focusedIndex < _networkFocusNodes.length - 1)
//       focusedIndex++;
//     else if (key == LogicalKeyboardKey.arrowDown) {
//       if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
//         setState(() {
//           _focusedKeyRow = 0;
//           _focusedKeyCol = 0;
//         });
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
//       // UPDATED: Center scrolling, assuming glass button width + margin ~ 160
//       _scrollToCenter(_networkScrollController, focusedIndex, 160, 20);
//     }
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateFilters(LogicalKeyboardKey key) {
//     int focusedIndex = _filterFocusNodes.indexWhere((n) => n.hasFocus);
//     if (focusedIndex == -1) focusedIndex = widget.selectedFilterIndex;

//     if (key == LogicalKeyboardKey.arrowLeft) {
//       if (focusedIndex > 0)
//         focusedIndex--;
//       else {
//         _searchButtonFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight &&
//         focusedIndex < _filterFocusNodes.length - 1)
//       focusedIndex++;
//     else if (key == LogicalKeyboardKey.arrowUp) {
//       if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
//         setState(() {
//           _focusedKeyRow = _keyboardLayout.length - 1;
//           _focusedKeyCol = 0;
//         });
//         _keyboardFocusNodes[_getKeyboardNodeIndex(_focusedKeyRow, _focusedKeyCol)]
//             .requestFocus();
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
//       // UPDATED: Center scrolling, assuming glass button width + margin ~ 160
//       _scrollToCenter(_filterScrollController, focusedIndex, 160, 20);
//     }
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateItems(LogicalKeyboardKey key) {
//     if (_isNavigationLocked) return KeyEventResult.handled;
//     _isNavigationLocked = true;
//     _navigationLockTimer = Timer(const Duration(milliseconds: 500), () {
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
//     } else if (key == LogicalKeyboardKey.arrowLeft && i > 0)
//       i--;
//     else if (key == LogicalKeyboardKey.arrowRight &&
//         i < _itemFocusNodes.length - 1)
//       i++;
//     else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _isNavigationLocked = false;
//       widget.onContentTap(widget.contentList[i], i);
//       return KeyEventResult.handled;
//     }

//     if (i != _focusedItemIndex && i >= 0 && i < _itemFocusNodes.length) {
//       setState(() => _focusedItemIndex = i);
//       _itemFocusNodes[i].requestFocus();
//       // UPDATED: Use specialized robust centering logic
//       _scrollToCenter(_itemScrollController, i, widget.cardWidth + 30, 20);
//       Provider.of<FocusProvider>(context, listen: false)
//           .updateName(widget.getTitle(widget.contentList[i]));
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
//                 children: [
//                   if (widget.networkNames.isNotEmpty) _buildTopFilterBar(),
//                   if (widget.networkNames.isEmpty) ...[
//                     SizedBox(height: MediaQuery.of(context).padding.top + 20),
//                     _buildBeautifulAppBar(),
//                   ],
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                             height: MediaQuery.of(context).size.height * 0.45,
//                             child: _showKeyboard
//                                 ? _buildSearchUI()
//                                 : const SizedBox.shrink()),
//                         _buildSliderIndicators(),
//                         _buildFilterBar(),
//                         const SizedBox(height: 10),
//                         _buildContentArea(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (widget.isLoading &&
//                 widget.contentList.isEmpty &&
//                 widget.filterNames.isEmpty)
//               Container(
//                 color: ProfessionalColors.primaryDark,
//                 child: const Center(
//                     child: CircularProgressIndicator(color: Colors.white)),
//               ),
//             if (widget.isVideoLoading && widget.errorMessage == null)
//               Positioned.fill(
//                   child: Container(
//                       color: Colors.black87,
//                       child: const Center(
//                           child:
//                               CircularProgressIndicator(color: Colors.white)))),
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
//       return const Expanded(
//           child: Center(child: CircularProgressIndicator(color: Colors.white)));
//     }
//     return _buildContentList();
//   }

//   Widget _buildBeautifulAppBar() {
//     final focusName = context.watch<FocusProvider>().focusedItemName;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//       decoration: BoxDecoration(
//           gradient: LinearGradient(
//               colors: [Colors.black.withOpacity(0.0), Colors.transparent],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter)),
//       child: Row(
//         children: [
//           Text(widget.title,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white)),
//           const SizedBox(width: 20),
//           Expanded(
//               child: Text(focusName,
//                   style: const TextStyle(
//                       color: ProfessionalColors.textSecondary,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 20),
//                   overflow: TextOverflow.ellipsis)),
//         ],
//       ),
//     );
//   }

//   Widget _buildTopFilterBar() {
//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: EdgeInsets.only(
//               top: MediaQuery.of(context).padding.top + 5, bottom: 5, left: 20),
//           decoration: BoxDecoration(
//               border: Border(
//                   bottom: BorderSide(
//                       color: Colors.white.withOpacity(0.1), width: 1))),
//           child: Row(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 35,
//                   child: ListView.builder(
//                     controller: _networkScrollController,
//                     scrollDirection: Axis.horizontal,
//                     itemCount: widget.networkNames.length,
//                     // Use standard clipping behavior to prevent scaling artifacts outside viewport
//                     itemBuilder: (ctx, i) {
//                       if (i >= _networkFocusNodes.length)
//                         return const SizedBox.shrink();
//                       bool isSelected = widget.selectedNetworkIndex == i;
//                       return Focus(
//                         focusNode: _networkFocusNodes[i],
//                         onFocusChange: (has) {
//                           // Centering logic on focus
//                           if (has && !_isDisposed) {
//                              _scrollToCenter(_networkScrollController, i, 160, 20);
//                           }
//                         },
//                         child: _buildGlassButton(
//                           focusNode: _networkFocusNodes[i],
//                           isSelected: isSelected,
//                           color: widget
//                               .focusColors[i % widget.focusColors.length],
//                           label: widget.networkNames[i].toUpperCase(),
//                           onTap: () {
//                             _shouldFocusFirstItem = true;
//                             if (widget.onNetworkSelected != null)
//                               widget.onNetworkSelected!(i);
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
//     if (widget.filterNames.isEmpty && !_isSearching)
//       return const SizedBox(height: 30);
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
//                   Provider.of<FocusProvider>(context, listen: false)
//                       .updateName("SEARCH");
//                    _scrollToCenter(_filterScrollController, 0, 160, 20);
//                 }
//               },
//               child: _buildGlassButton(
//                 focusNode: _searchButtonFocusNode,
//                 isSelected: _isSearching || _showKeyboard,
//                 color: ProfessionalColors.accentOrange,
//                 label: "SEARCH",
//                 icon: Icons.search,
//                 onTap: () => setState(() {
//                   _showKeyboard = true;
//                   _searchButtonFocusNode.requestFocus();
//                 }),
//               ),
//             );
//           }
//           int filterIdx = i - 1;
//           if (filterIdx >= _filterFocusNodes.length) return const SizedBox.shrink();
//           return Focus(
//             focusNode: _filterFocusNodes[filterIdx],
//             onFocusChange: (has) {
//               // Centering logic on focus
//               if (has && !_isDisposed) {
//                  _scrollToCenter(_filterScrollController, i, 160, 20);
//               }
//             },
//             child: _buildGlassButton(
//               focusNode: _filterFocusNodes[filterIdx],
//               isSelected:
//                   !_isSearching && widget.selectedFilterIndex == filterIdx,
//               color: widget
//                   .focusColors[filterIdx % widget.focusColors.length],
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
//       return Expanded(
//           child: Center(
//               child: Text(widget.emptyMessage,
//                   style: const TextStyle(color: Colors.white54, fontSize: 18))));
//     }
//     return Expanded(
//       child: ListView.builder(
//         controller: _itemScrollController,
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         clipBehavior: Clip.none, // Essential for large scale animation
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
//                   // UPDATED: Center scrolling logic
//                   _scrollToCenter(_itemScrollController, i, widget.cardWidth + 30, 20);
//                   Provider.of<FocusProvider>(context, listen: false)
//                       .updateName(widget.getTitle(item));
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

//   // // UPDATED: Glass button build logic with animated sweep border gradient
//   // Widget _buildGlassButton(
//   //     {required FocusNode focusNode,
//   //     required bool isSelected,
//   //     required Color color,
//   //     required String label,
//   //     IconData? icon,
//   //     required VoidCallback onTap}) {
//   //   bool hasFocus = focusNode.hasFocus;
//   //   return GestureDetector(
//   //     onTap: onTap,
//   //     child: Container(
//   //       margin: const EdgeInsets.only(right: 12),
//   //       // Fix width for reliable centering math (e.g., 148 + 12 margin = 160 effective)
//   //       width: 148, 
//   //       alignment: Alignment.center,
//   //       child: AnimatedBuilder(
//   //         animation: _borderAnimationController,
//   //         builder: (context, child) {
//   //           return Stack(
//   //              fit: StackFit.passthrough,
//   //              alignment: Alignment.center,
//   //              children: [
//   //               // 1. The Dynamic Animated Border (Matches card style exactly)
//   //               if (hasFocus)
//   //                  Container(
//   //                   decoration: BoxDecoration(
//   //                     borderRadius: BorderRadius.circular(30),
//   //                     gradient: SweepGradient(
//   //                       colors: [
//   //                         Colors.white.withOpacity(0.1),
//   //                         Colors.white,
//   //                         Colors.white,
//   //                         Colors.white.withOpacity(0.1)
//   //                       ],
//   //                       stops: const [0.0, 0.25, 0.5, 1.0],
//   //                       transform: GradientRotation(
//   //                           _borderAnimationController.value * 2 * math.pi),
//   //                     ),
//   //                   ),
//   //                 ),
//   //               // 2. The Button Content with Padding to show border
//   //               Padding(
//   //                  padding: EdgeInsets.all(hasFocus ? 2.5 : 0.0), // Padding shows the border
//   //                  child: ClipRRect(
//   //                   borderRadius: BorderRadius.circular(hasFocus ? 28 : 30),
//   //                   child: BackdropFilter(
//   //                     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//   //                     child: AnimatedContainer(
//   //                       duration: AnimationTiming.fast,
//   //                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
//   //                       alignment: Alignment.center,
//   //                       decoration: BoxDecoration(
//   //                         // When focused, background is black/transparent to highlight white border/text
//   //                         color: hasFocus 
//   //                             ? Colors.black.withOpacity(0.8) 
//   //                             : isSelected 
//   //                                 ? color.withOpacity(0.5) 
//   //                                 : Colors.white.withOpacity(0.08),
//   //                         borderRadius: BorderRadius.circular(hasFocus ? 28 : 30),
//   //                         // Optional outer subtle static border when unfocused
//   //                         border: !hasFocus ? Border.all(color: Colors.white.withOpacity(0.2), width: 1) : null,
//   //                         // Blue glow glow shadow only when focused
//   //                         boxShadow: hasFocus 
//   //                             ? [BoxShadow(color: color.withOpacity(0.7), blurRadius: 15, spreadRadius: 2)] 
//   //                             : null,
//   //                       ),
//   //                       child: Row(
//   //                         mainAxisSize: MainAxisSize.min,
//   //                         mainAxisAlignment: MainAxisAlignment.center,
//   //                         children: [
//   //                           if (icon != null) ...[
//   //                             Icon(icon, color: Colors.white, size: 16),
//   //                             const SizedBox(width: 8)
//   //                           ],
//   //                           Flexible(
//   //                              child: Text(label,
//   //                                 style: const TextStyle(
//   //                                     color: Colors.white, // Text is always white
//   //                                     fontWeight: FontWeight.bold,
//   //                                     fontSize: 14),
//   //                                 overflow: TextOverflow.ellipsis,
//   //                                 textAlign: TextAlign.center,
//   //                             ),
//   //                           ),
//   //                         ],
//   //                       ),
//   //                     ),
//   //                   ),
//   //                  ),
//   //               ),
//   //              ],
//   //           );
//   //         },
//   //       ),
//   //     ),
//   //   );
//   // }


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
//                 // 1. Animated Rotating Border (Visible only when focused)
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
//                 // 2. Your Original Glass Button (with padding to expose the border underneath)
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
//                           // Restored your original color logic
//                           color: hasFocus ? color : isSelected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(30),
//                           // Static border shows when unfocused, animated border shows when focused
//                           border: !hasFocus ? Border.all(color: Colors.white.withOpacity(0.3), width: 2) : null,
//                           // boxShadow: (hasFocus || isSelected) ? [BoxShadow(color: color.withOpacity(0.8), blurRadius: 15)] : null,
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
//               const Text("SEARCH",
//                   style: TextStyle(
//                       fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
//               const SizedBox(height: 24),
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 40),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                     color: Colors.white10,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: ProfessionalColors.accentPurple)),
//                 child: Text(_searchText.isEmpty ? 'Typing...' : _searchText,
//                     style: const TextStyle(color: Colors.white, fontSize: 22)),
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
//                     int idx = _keyboardLayout
//                             .take(r.key)
//                             .fold(0, (p, e) => p + e.length) +
//                         c.key;
//                     if (idx >= _keyboardFocusNodes.length)
//                       return const SizedBox.shrink();
//                     bool isFocused = _focusedKeyRow == r.key && _focusedKeyCol == c.key;
//                     String key = c.value;
//                     double w = key == 'SPACE'
//                         ? 150
//                         : (key == 'OK' || key == 'DEL' ? 70 : 40);
//                     return Container(
//                       width: w,
//                       height: 40,
//                       margin: const EdgeInsets.all(4),
//                       child: Focus(
//                         focusNode: _keyboardFocusNodes[idx],
//                         onFocusChange: (has) {
//                           if (has)
//                             setState(() {
//                               _focusedKeyRow = r.key;
//                               _focusedKeyCol = c.key;
//                             });
//                         },
//                         child: ElevatedButton(
//                           onPressed: () => _handleKeyClick(key),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: isFocused
//                                 ? ProfessionalColors.accentPurple
//                                 : Colors.white10,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 side: isFocused
//                                     ? const BorderSide(color: Colors.white, width: 2)
//                                     : BorderSide.none),
//                             padding: EdgeInsets.zero,
//                           ),
//                           child: Text(key,
//                               style: const TextStyle(color: Colors.white, fontSize: 18)),
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
//     if (widget.sliderImages.isEmpty)
//       return Container(color: ProfessionalColors.primaryDark);
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         PageView.builder(
//           controller: _sliderPageController,
//           itemCount: widget.sliderImages.length,
//           itemBuilder: (c, i) => CachedNetworkImage(
//               imageUrl: widget.sliderImages[i],
//               fit: BoxFit.fill,
//               errorWidget: (c, u, e) =>
//                   Container(color: ProfessionalColors.surfaceDark)),
//         ),
//       ],
//     );
//   }

//   // Widget _buildSliderIndicators() {
//   //   if (widget.sliderImages.length <= 1) return const SizedBox.shrink();
//   //   return Row(
//   //     mainAxisAlignment: MainAxisAlignment.center,
//   //     children: List.generate(
//   //         widget.sliderImages.length,
//   //         (i) => AnimatedContainer(
//   //               duration: AnimationTiming.fast,
//   //               margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
//   //               height: 6,
//   //               width: _currentSliderPage == i ? 20 : 6,
//   //               decoration: BoxDecoration(
//   //                   color: _currentSliderPage == i ? Colors.white : Colors.white54,
//   //                   borderRadius: BorderRadius.circular(10)),
//   //             )),
//   //   );
//   // }

// Widget _buildSliderIndicators() {
//     // Agar 1 ya usse kam image hai, toh empty SizedBox return karenge
//     // jiske height exactly indicator row (10 margin + 6 height + 10 margin = 26) ke barabar ho.
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
//           Text(widget.errorMessage ?? 'Something went wrong',
//               style: const TextStyle(color: Colors.white, fontSize: 18),
//               textAlign: TextAlign.center),
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

// class __MasterSliderCardState<T> extends State<_MasterSliderCard<T>>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _borderAnimationController;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController =
//         AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    
//     // UPDATED: Scale increase: 1.15 to 1.3
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
//         CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));

//     _borderAnimationController =
//         AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
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
//       if (!_borderAnimationController.isAnimating)
//         _borderAnimationController.repeat();
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
//       // Standard card wrapper width defined as cardWidth + horizontal margins
//       width: widget.cardWidth + 30, // Effective width: CardWidth + 15(left) + 15(right)
//       alignment: Alignment.center,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
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
//           // Spacer ensures title doesn't shift card vertical alignment significantly
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
//         // boxShadow: [
//         //   if (widget.isFocused)
//         //     BoxShadow(
//         //         color: Colors.black.withOpacity(0.95),
//         //         blurRadius: 35, // Increased blur for larger scale
//         //         spreadRadius: 10,
//         //         offset: const Offset(0, 15))
//         //   else
//         //     BoxShadow(
//         //         color: Colors.black.withOpacity(0.5),
//         //         blurRadius: 8,
//         //         spreadRadius: 1,
//         //         offset: const Offset(0, 4))
//         // ],
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
//                       transform: GradientRotation(
//                           _borderAnimationController.value * 2 * math.pi),
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
//                             radius: 12,
//                             backgroundImage:
//                                 CachedNetworkImageProvider(widget.logoUrl),
//                             backgroundColor: Colors.black54)),
//                 ],
//               ),
//             ),
//           ),
//           if (widget.isFocused)
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   border:
//                       Border.all(color: Colors.white.withOpacity(0.3), width: 1),
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
//           Icon(widget.placeholderIcon,
//               size: widget.cardHeight * 0.25, color: Colors.grey),
//         ]),
//       );

//   Widget _buildTitle() => Container(
//         width: widget.cardWidth,
//         // Height fixed to prevent image jump regardless of text lines
//         height: 48, 
//         padding: const EdgeInsets.symmetric(horizontal: 4),
//         alignment: Alignment.topCenter,
//         child: AnimatedDefaultTextStyle(
//           duration: const Duration(milliseconds: 250),
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           softWrap: true,
//           overflow: TextOverflow.ellipsis,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: widget.isFocused ? FontWeight.w900 : FontWeight.w400,
            
//             // UPDATED: Focused white, Unfocused Kala (black87 is suitable dark color)
//             color: widget.isFocused ? Colors.white : Colors.white,
            
//             letterSpacing: 0.5,
//             height: 1.2,
//           ),
//           child: Text(widget.getTitle(widget.item)),
//         ),
//       );
// }






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
//         Provider.of<FocusProvider>(context, listen: false).updateName('');
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
//                 Provider.of<FocusProvider>(context, listen: false).updateName(widget.getTitle(widget.contentList[0]));
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
//       Provider.of<FocusProvider>(context, listen: false).updateName(widget.getTitle(widget.contentList[i]));
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
//     final focusName = context.watch<FocusProvider>().focusedItemName;
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
//     final focusName = context.watch<FocusProvider>().focusedItemName;
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
//                   Provider.of<FocusProvider>(context, listen: false).updateName("SEARCH");
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
//   //                 Provider.of<FocusProvider>(context, listen: false).updateName(widget.getTitle(item));
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
//           Provider.of<FocusProvider>(context, listen: false).updateName(widget.getTitle(item));
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





// import 'dart:async';
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// // Assuming these exist in your project, keeping imports as is.
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
  
//   // Navigation lock variables for buttons
//   bool _isNetworkNavLocked = false;
//   bool _isFilterNavLocked = false;
//   Timer? _networkNavLockTimer;
//   Timer? _filterNavLockTimer;

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
//         Provider.of<FocusProvider>(context, listen: false)
//             .updateName('');
//     });

//     _fadeController =
//         AnimationController(duration: AnimationTiming.medium, vsync: this);
//     _fadeAnimation =
//         CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

//     _borderAnimationController =
//         AnimationController(duration: const Duration(milliseconds: 2500), vsync: this)
//           ..repeat();

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
//       _itemFocusNodes = List.generate(widget.contentList.length,
//           (i) => FocusNode()..addListener(_setStateListener));
//       _focusedItemIndex = -1;
//     }
//     if (oldWidget.filterNames.length != widget.filterNames.length) {
//       _disposeFocusNodes(_filterFocusNodes);
//       _filterFocusNodes = List.generate(widget.filterNames.length,
//           (i) => FocusNode()..addListener(_setStateListener));
//     }
//     if (oldWidget.networkNames.length != widget.networkNames.length) {
//       _disposeFocusNodes(_networkFocusNodes);
//       _networkFocusNodes = List.generate(widget.networkNames.length,
//           (i) => FocusNode()..addListener(_setStateListener));
//     }

//     if (oldWidget.sliderImages != widget.sliderImages) {
//       _setupSliderTimer();
//     }

//     bool justFinishedPageLoad =
//         oldWidget.isLoading == true && widget.isLoading == false;
//     bool justFinishedListLoad =
//         oldWidget.isListLoading == true && widget.isListLoading == false;
//     bool contentAppeared =
//         oldWidget.contentList.isEmpty && widget.contentList.isNotEmpty;

//     if ((justFinishedPageLoad ||
//             justFinishedListLoad ||
//             contentAppeared ||
//             _shouldFocusFirstItem) &&
//         !_showKeyboard) {
//       if (_shouldFocusFirstItem && !widget.isListLoading && !widget.isLoading) {
//         _shouldFocusFirstItem = false;
//       }

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!_isDisposed && mounted && !_showKeyboard) {
//           if (widget.contentList.isNotEmpty && _itemFocusNodes.isNotEmpty) {
//             Future.delayed(const Duration(milliseconds: 150), () {
//               if (!_isDisposed &&
//                   mounted &&
//                   _itemFocusNodes.isNotEmpty &&
//                   !_showKeyboard) {
//                 setState(() => _focusedItemIndex = 0);
//                 _itemFocusNodes[0].requestFocus();
//                 _scrollToCenter(_itemScrollController, 0, widget.cardWidth + 30, 20);
//                 Provider.of<FocusProvider>(context, listen: false)
//                     .updateName(widget.getTitle(widget.contentList[0]));
//               }
//             });
//           } else if (justFinishedPageLoad &&
//               widget.networkNames.isNotEmpty &&
//               _networkFocusNodes.isNotEmpty) {
//             _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//           } else if (justFinishedPageLoad &&
//               _searchButtonFocusNode.canRequestFocus) {
//             _searchButtonFocusNode.requestFocus();
//           }
//         }
//       });
//     }
//   }

//   void _initializeAllFocusNodes() {
//     _networkFocusNodes = List.generate(widget.networkNames.length,
//         (i) => FocusNode()..addListener(_setStateListener));
//     _filterFocusNodes = List.generate(widget.filterNames.length,
//         (i) => FocusNode()..addListener(_setStateListener));
//     _itemFocusNodes = List.generate(widget.contentList.length,
//         (i) => FocusNode()..addListener(_setStateListener));
//     int totalKeys = _keyboardLayout.fold(0, (prev, row) => prev + row.length);
//     _keyboardFocusNodes = List.generate(
//         totalKeys, (i) => FocusNode()..addListener(_setStateListener));
//   }

//   void _setStateListener() {
//     if (mounted && !_isDisposed) setState(() {});
//   }

//   void _disposeFocusNodes(List<FocusNode> nodes) {
//     for (var node in nodes) {
//       node.removeListener(_setStateListener);
//       try {
//         node.dispose();
//       } catch (_) {}
//     }
//     nodes.clear();
//   }

//   @override
//   void dispose() {
//     _isDisposed = true;
//     _sliderTimer?.cancel();
//     _debounce?.cancel();
//     _navigationLockTimer?.cancel();
//     _networkNavLockTimer?.cancel();
//     _filterNavLockTimer?.cancel();
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
//           _sliderPageController.animateToPage(next,
//               duration: const Duration(milliseconds: 500),
//               curve: Curves.easeInOut);
//         }
//       });
//     }
//   }

//   // // Helper method to get actual button width
//   // double _getButtonWidth(String label, {IconData? icon}) {
//   //   // Create a text painter to measure text width
//   //   final TextPainter textPainter = TextPainter(
//   //     text: TextSpan(
//   //       text: label,
//   //       style: const TextStyle(
//   //         fontSize: 14,
//   //         fontWeight: FontWeight.bold,
//   //       ),
//   //     ),
//   //     textDirection: TextDirection.ltr,
//   //   )..layout();
    
//   //   double textWidth = textPainter.width;
//   //   double iconWidth = icon != null ? 24.0 : 0.0; // Icon width + spacing
//   //   double horizontalPadding = 40.0; // 20 left + 20 right padding
    
//   //   return textWidth + iconWidth + horizontalPadding;
//   // }


//   // Helper method to get actual button width
//   double _getButtonWidth(String label, {IconData? icon}) {
//     // Create a text painter to measure text width
//     final TextPainter textPainter = TextPainter(
//       text: TextSpan(
//         text: label,
//         style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     )..layout();
    
//     double textWidth = textPainter.width;
//     double iconWidth = icon != null ? 24.0 : 0.0; // Icon width + spacing
    
//     // 40.0 for inner container padding + 6.0 for the focus border padding
//     double horizontalPadding = 60.0; 
    
//     return textWidth + iconWidth + horizontalPadding;
//   }

//   // void _scrollToCenter(ScrollController controller, int index, double itemWidth, double listPaddingStart) {
//   //   if (!controller.hasClients) return;
    
//   //   // Get the actual widget width including margin
//   //   double itemEffectiveWidth = itemWidth + 12; // 12 is the margin right from Container margin
    
//   //   // Calculate the scroll position
//   //   double screenWidth = MediaQuery.of(context).size.width;
    
//   //   // Get the actual position of the item
//   //   double itemStartPosition = listPaddingStart + (index * itemEffectiveWidth);
//   //   double itemCenterPosition = itemStartPosition + (itemWidth / 2);
//   //   double screenCenter = screenWidth / 2;
    
//   //   // Calculate target offset
//   //   double targetOffset = itemCenterPosition - screenCenter;
    
//   //   // Clamp to valid scroll range
//   //   targetOffset = targetOffset.clamp(0.0, controller.position.maxScrollExtent);
    
//   //   // Animate to position
//   //   controller.animateTo(
//   //     targetOffset,
//   //     duration: AnimationTiming.fast,
//   //     curve: Curves.easeInOut,
//   //   );
//   // }


// // void _scrollToCenter(ScrollController controller, int index, double itemWidth, double listPaddingStart) {
// //     if (!controller.hasClients) return;

// //     double screenWidth = MediaQuery.of(context).size.width;
// //     double itemStartPosition = listPaddingStart;

// //     // Calculate dynamic start position based on which list is scrolling
// //     if (controller == _networkScrollController) {
// //       // Sum widths of all preceding network buttons
// //       for (int i = 0; i < index; i++) {
// //         itemStartPosition += _getButtonWidth(widget.networkNames[i].toUpperCase()) + 12; // 12 is the right margin
// //       }
// //     } else if (controller == _filterScrollController) {
// //       if (index > 0) {
// //         // Add Search button width first (since it sits at index 0)
// //         itemStartPosition += _getButtonWidth("SEARCH", icon: Icons.search) + 12;
// //         // Add preceding filter buttons
// //         for (int i = 0; i < index - 1; i++) {
// //           itemStartPosition += _getButtonWidth(widget.filterNames[i].toUpperCase()) + 12;
// //         }
// //       }
// //     } else {
// //       // Standard calculation for fixed-width lists (like your movie cards)
// //       double itemEffectiveWidth = itemWidth + 12; 
// //       itemStartPosition += (index * itemEffectiveWidth);
// //     }

// //     // Calculate the center point
// //     double itemCenterPosition = itemStartPosition + (itemWidth / 2);
// //     double screenCenter = screenWidth / 2;
// //     double targetOffset = itemCenterPosition - screenCenter;

// //     // Safely clamp the offset so it doesn't overscroll
// //     if (controller.position.hasContentDimensions) {
// //       targetOffset = targetOffset.clamp(0.0, controller.position.maxScrollExtent);
// //     } else {
// //       targetOffset = math.max(0.0, targetOffset);
// //     }

// //     controller.animateTo(
// //       targetOffset,
// //       duration: AnimationTiming.fast,
// //       curve: Curves.easeInOut,
// //     );
// //   }



// void _scrollToCenter(ScrollController controller, int index, double itemWidth, double listPaddingStart) {
//   if (!controller.hasClients) return;

//   double screenWidth = MediaQuery.of(context).size.width;
//   double itemStartPosition = listPaddingStart;

//   // 1. Calculate the exact position of the item in the list
//   if (controller == _networkScrollController) {
//     for (int i = 0; i < index; i++) {
//       itemStartPosition += _getButtonWidth(widget.networkNames[i].toUpperCase()) + 12;
//     }
//   } else if (controller == _filterScrollController) {
//     if (index > 0) {
//       itemStartPosition += _getButtonWidth("SEARCH", icon: Icons.search) + 12;
//       for (int i = 0; i < index - 1; i++) {
//         itemStartPosition += _getButtonWidth(widget.filterNames[i].toUpperCase()) + 12;
//       }
//     }
//   } else {
//     // For Movie/Content Cards
//     double itemEffectiveWidth = itemWidth; // Yahan +30 mat karein, itemWidth parameter hi total width honi chahiye
//     itemStartPosition += (index * itemEffectiveWidth);
//   }

//   // 2. Calculate target: Item Center - Screen Center
//   // Isse item screen ke bilkul beech mein aane ki koshish karega
//   double targetOffset = (itemStartPosition + (itemWidth / 2)) - (screenWidth / 2);

//   // 3. Clamp the offset so it doesn't scroll into empty space
//   double maxScroll = controller.position.maxScrollExtent;
//   targetOffset = targetOffset.clamp(0.0, maxScroll);

//   controller.animateTo(
//     targetOffset,
//     duration: AnimationTiming.fast,
//     curve: Curves.easeInOut,
//   );
// }

//   KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
//     if (_isDisposed || event is! RawKeyDownEvent || widget.isLoading)
//       return KeyEventResult.ignored;

//     final key = event.logicalKey;
//     if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape) {
//       if (_showKeyboard) {
//         setState(() {
//           _showKeyboard = false;
//           _focusedKeyRow = 0;
//           _focusedKeyCol = 0;
//         });
//         _searchButtonFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (_itemFocusNodes.any((n) => n.hasFocus) ||
//           _filterFocusNodes.any((n) => n.hasFocus) ||
//           _searchButtonFocusNode.hasFocus) {
//         if (_networkFocusNodes.isNotEmpty)
//           _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.ignored;
//     }

//     if (_showKeyboard && _keyboardFocusNodes.any((n) => n.hasFocus))
//       return _navigateKeyboard(key);
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
//         r--;
//         c = math.min(c, _keyboardLayout[r].length - 1);
//       } else {
//         if (_networkFocusNodes.isNotEmpty) {
//           _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//         }
//         return KeyEventResult.handled;
//       }
//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       if (r < _keyboardLayout.length - 1) {
//         r++;
//         c = math.min(c, _keyboardLayout[r].length - 1);
//       } else {
//         if (_filterFocusNodes.isNotEmpty) {
//           int targetFilter =
//               widget.selectedFilterIndex >= 0 ? widget.selectedFilterIndex : 0;
//           _filterFocusNodes[targetFilter].requestFocus();
//         } else {
//           _searchButtonFocusNode.requestFocus();
//         }
//         return KeyEventResult.handled;
//       }
//     } else if (key == LogicalKeyboardKey.arrowLeft && c > 0)
//       c--;
//     else if (key == LogicalKeyboardKey.arrowRight &&
//         c < _keyboardLayout[r].length - 1)
//       c++;
//     else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _handleKeyClick(_keyboardLayout[r][c]);
//       return KeyEventResult.handled;
//     }

//     if (r != _focusedKeyRow || c != _focusedKeyCol) {
//       setState(() {
//         _focusedKeyRow = r;
//         _focusedKeyCol = c;
//       });
//       int idx = _getKeyboardNodeIndex(r, c);
//       if (idx < _keyboardFocusNodes.length)
//         _keyboardFocusNodes[idx].requestFocus();
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
//           if (_searchText.isNotEmpty)
//             _searchText = _searchText.substring(0, _searchText.length - 1);
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
//         setState(() {
//           _focusedKeyRow = _keyboardLayout.length - 1;
//           _focusedKeyCol = 0;
//         });
//         _keyboardFocusNodes[_getKeyboardNodeIndex(_focusedKeyRow, _focusedKeyCol)]
//             .requestFocus();
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
//     if (_isNetworkNavLocked) return KeyEventResult.handled;
//     _isNetworkNavLocked = true;
//     _networkNavLockTimer = Timer(const Duration(milliseconds: 500), () {
//       if (mounted) setState(() => _isNetworkNavLocked = false);
//     });

//     int focusedIndex = _networkFocusNodes.indexWhere((n) => n.hasFocus);
//     if (focusedIndex == -1) focusedIndex = widget.selectedNetworkIndex;

//     if (key == LogicalKeyboardKey.arrowLeft && focusedIndex > 0)
//       focusedIndex--;
//     else if (key == LogicalKeyboardKey.arrowRight &&
//         focusedIndex < _networkFocusNodes.length - 1)
//       focusedIndex++;
//     else if (key == LogicalKeyboardKey.arrowDown) {
//       if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
//         setState(() {
//           _focusedKeyRow = 0;
//           _focusedKeyCol = 0;
//         });
//         _keyboardFocusNodes[0].requestFocus();
//       } else {
//         _searchButtonFocusNode.requestFocus();
//       }
//       _isNetworkNavLocked = false;
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _shouldFocusFirstItem = true;
//       if (widget.onNetworkSelected != null) widget.onNetworkSelected!(focusedIndex);
//       _isNetworkNavLocked = false;
//       return KeyEventResult.handled;
//     }

//     if (focusedIndex != _networkFocusNodes.indexWhere((n) => n.hasFocus)) {
//       _networkFocusNodes[focusedIndex].requestFocus();
      
//       // Calculate actual button width for centering
//       double buttonWidth = _getButtonWidth(
//         widget.networkNames[focusedIndex].toUpperCase()
//       );
      
//       _scrollToCenter(_networkScrollController, focusedIndex, buttonWidth, 20);
//     }
//     _isNetworkNavLocked = false;
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateFilters(LogicalKeyboardKey key) {
//     if (_isFilterNavLocked) return KeyEventResult.handled;
//     _isFilterNavLocked = true;
//     _filterNavLockTimer = Timer(const Duration(milliseconds: 500), () {
//       if (mounted) setState(() => _isFilterNavLocked = false);
//     });

//     int focusedIndex = _filterFocusNodes.indexWhere((n) => n.hasFocus);
//     if (focusedIndex == -1) focusedIndex = widget.selectedFilterIndex;

//     if (key == LogicalKeyboardKey.arrowLeft) {
//       if (focusedIndex > 0)
//         focusedIndex--;
//       else {
//         _searchButtonFocusNode.requestFocus();
//         _isFilterNavLocked = false;
//         return KeyEventResult.handled;
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight &&
//         focusedIndex < _filterFocusNodes.length - 1)
//       focusedIndex++;
//     else if (key == LogicalKeyboardKey.arrowUp) {
//       if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
//         setState(() {
//           _focusedKeyRow = _keyboardLayout.length - 1;
//           _focusedKeyCol = 0;
//         });
//         _keyboardFocusNodes[_getKeyboardNodeIndex(_focusedKeyRow, _focusedKeyCol)]
//             .requestFocus();
//       } else if (_networkFocusNodes.isNotEmpty) {
//         _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//       }
//       _isFilterNavLocked = false;
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
//       int target = _lastFocusedItemIndex;
//       if (target >= _itemFocusNodes.length) target = _itemFocusNodes.length - 1;
//       if (target < 0) target = 0;

//       setState(() => _focusedItemIndex = target);
//       _itemFocusNodes[target].requestFocus();
//       _isFilterNavLocked = false;
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _shouldFocusFirstItem = true;
//       widget.onFilterSelected(focusedIndex);
//       _isFilterNavLocked = false;
//       return KeyEventResult.handled;
//     }

//     if (focusedIndex != _filterFocusNodes.indexWhere((n) => n.hasFocus)) {
//       _filterFocusNodes[focusedIndex].requestFocus();
      
//       // Calculate actual button width for centering
//       double buttonWidth = _getButtonWidth(
//         widget.filterNames[focusedIndex].toUpperCase()
//       );
      
//       // +1 because filter list includes search button at index 0
//       _scrollToCenter(_filterScrollController, focusedIndex + 1, buttonWidth, 20);
//     }
//     _isFilterNavLocked = false;
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateItems(LogicalKeyboardKey key) {
//     if (_isNavigationLocked) return KeyEventResult.handled;
//     _isNavigationLocked = true;
//     _navigationLockTimer = Timer(const Duration(milliseconds: 500), () {
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
//     } else if (key == LogicalKeyboardKey.arrowLeft && i > 0)
//       i--;
//     else if (key == LogicalKeyboardKey.arrowRight &&
//         i < _itemFocusNodes.length - 1)
//       i++;
//     else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _isNavigationLocked = false;
//       widget.onContentTap(widget.contentList[i], i);
//       return KeyEventResult.handled;
//     }

//     if (i != _focusedItemIndex && i >= 0 && i < _itemFocusNodes.length) {
//       setState(() => _focusedItemIndex = i);
//       _itemFocusNodes[i].requestFocus();
//       // _scrollToCenter(_itemScrollController, i, widget.cardWidth + 30, 20);
//       _scrollToCenter(_itemScrollController, i, widget.cardWidth + 20, 20);
//       Provider.of<FocusProvider>(context, listen: false)
//           .updateName(widget.getTitle(widget.contentList[i]));
//     } else {
//       _isNavigationLocked = false;
//     }
//     return KeyEventResult.handled;
//   }

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
//                 children: [
//                   SizedBox(height: screenhgt * 0.04,),
//                   if (widget.networkNames.isNotEmpty) _buildTopFilterBar(),
//                   if (widget.networkNames.isEmpty) ...[
//                     SizedBox(height: MediaQuery.of(context).padding.top + 20),
//                     _buildBeautifulAppBar(),
//                   ],
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                             height: MediaQuery.of(context).size.height * 0.4,
//                             child: _showKeyboard
//                                 ? _buildSearchUI()
//                                 : const SizedBox.shrink()),
//                         _buildSliderIndicators(),
//                         _buildFilterBar(),
//                         const SizedBox(height: 20),
//                         _buildContentArea(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (widget.isLoading &&
//                 widget.contentList.isEmpty &&
//                 widget.filterNames.isEmpty)
//               Container(
//                 color: ProfessionalColors.primaryDark,
//                 child: const Center(
//                     child: CircularProgressIndicator(color: Colors.white)),
//               ),
//             if (widget.isVideoLoading && widget.errorMessage == null)
//               Positioned.fill(
//                   child: Container(
//                       color: Colors.black87,
//                       child: const Center(
//                           child:
//                               CircularProgressIndicator(color: Colors.white)))),
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
//       return const Expanded(
//           child: Center(child: CircularProgressIndicator(color: Colors.white)));
//     }
//     return _buildContentList();
//   }

//   Widget _buildBeautifulAppBar() {
//     final focusName = context.watch<FocusProvider>().focusedItemName;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//       decoration: BoxDecoration(
//           gradient: LinearGradient(
//               colors: [Colors.black.withOpacity(0.0), Colors.transparent],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter)),
//       child: Row(
//         children: [
//           Text(widget.title,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white)),
//           const SizedBox(width: 20),
//           Expanded(
//               child: Text(focusName,
//                   style: const TextStyle(
//                       color: ProfessionalColors.textSecondary,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 20),
//                   overflow: TextOverflow.ellipsis)),
//         ],
//       ),
//     );
//   }

//   Widget _buildTopFilterBar() {
//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: EdgeInsets.only(
//               top: MediaQuery.of(context).padding.top + 5, bottom: 5, left: screenwdt * 0.03),
//           decoration: BoxDecoration(
//               border: Border(
//                   bottom: BorderSide(
//                       color: Colors.white.withOpacity(0.1), width: 1))),
//           child: Row(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 35,
//                   child: ListView.builder(
//                     controller: _networkScrollController,
//                     scrollDirection: Axis.horizontal,
//         cacheExtent: 5000,

//                     itemCount: widget.networkNames.length,
//                     itemBuilder: (ctx, i) {
//                       if (i >= _networkFocusNodes.length)
//                         return const SizedBox.shrink();
//                       bool isSelected = widget.selectedNetworkIndex == i;
                      
//                       // Calculate button width
//                       double buttonWidth = _getButtonWidth(
//                         widget.networkNames[i].toUpperCase()
//                       );
                      
//                       return Focus(
//                         focusNode: _networkFocusNodes[i],
//                         onFocusChange: (has) {
//                           if (has && !_isDisposed) {
//                             _scrollToCenter(
//                               _networkScrollController, 
//                               i, 
//                               buttonWidth, 
//                               20
//                             );
//                           }
//                         },
//                         child: _buildGlassButton(
//                           focusNode: _networkFocusNodes[i],
//                           isSelected: isSelected,
//                           color: widget
//                               .focusColors[i % widget.focusColors.length],
//                           label: widget.networkNames[i].toUpperCase(),
//                           customWidth: buttonWidth,
//                           onTap: () {
//                             _shouldFocusFirstItem = true;
//                             if (widget.onNetworkSelected != null)
//                               widget.onNetworkSelected!(i);
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
//     if (widget.filterNames.isEmpty && !_isSearching)
//       return const SizedBox(height: 30);
    
//     return SizedBox(
//       height: 35,
//       child: ListView.builder(
//         controller: _filterScrollController,
//         scrollDirection: Axis.horizontal,
//         cacheExtent: 5000,
//         itemCount: widget.filterNames.length + 1,
//         padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.03),
//         itemBuilder: (ctx, i) {
//           if (i == 0) {
//             // Search button width
//             double searchButtonWidth = _getButtonWidth("SEARCH", icon: Icons.search);
            
//             return Focus(
//               focusNode: _searchButtonFocusNode,
//               onFocusChange: (has) {
//                 if (has && !_isDisposed) {
//                   Provider.of<FocusProvider>(context, listen: false)
//                       .updateName("SEARCH");
//                   _scrollToCenter(_filterScrollController, 0, searchButtonWidth, 20);
//                 }
//               },
//               child: _buildGlassButton(
//                 focusNode: _searchButtonFocusNode,
//                 isSelected: _isSearching || _showKeyboard,
//                 color: ProfessionalColors.accentOrange,
//                 label: "SEARCH",
//                 icon: Icons.search,
//                 customWidth: searchButtonWidth,
//                 onTap: () => setState(() {
//                   _showKeyboard = true;
//                   _searchButtonFocusNode.requestFocus();
//                 }),
//               ),
//             );
//           }
          
//           int filterIdx = i - 1;
//           if (filterIdx >= _filterFocusNodes.length) return const SizedBox.shrink();
          
//           // Calculate filter button width
//           double buttonWidth = _getButtonWidth(
//             widget.filterNames[filterIdx].toUpperCase()
//           );
          
//           return Focus(
//             focusNode: _filterFocusNodes[filterIdx],
//             onFocusChange: (has) {
//               if (has && !_isDisposed) {
//                 _scrollToCenter(_filterScrollController, i, buttonWidth, 20);
//               }
//             },
//             child: _buildGlassButton(
//               focusNode: _filterFocusNodes[filterIdx],
//               isSelected:
//                   !_isSearching && widget.selectedFilterIndex == filterIdx,
//               color: widget
//                   .focusColors[filterIdx % widget.focusColors.length],
//               label: widget.filterNames[filterIdx].toUpperCase(),
//               customWidth: buttonWidth,
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
//       return Expanded(
//           child: Center(
//               child: Text(widget.emptyMessage,
//                   style: const TextStyle(color: Colors.white54, fontSize: 18))));
//     }
//     return Expanded(
//       child: ListView.builder(
//         controller: _itemScrollController,
//         scrollDirection: Axis.horizontal,
//         padding:  EdgeInsets.symmetric(horizontal: screenwdt * 0.05),
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
//                   _scrollToCenter(_itemScrollController, i, widget.cardWidth + 30, 20);
//                   Provider.of<FocusProvider>(context, listen: false)
//                       .updateName(widget.getTitle(item));
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

//   Widget _buildGlassButton({
//     required FocusNode focusNode,
//     required bool isSelected,
//     required Color color,
//     required String label,
//     IconData? icon,
//     required VoidCallback onTap,
//     double? customWidth,
//   }) {
//     bool hasFocus = focusNode.hasFocus;
//     double buttonWidth = customWidth ?? _getButtonWidth(label, icon: icon);
    
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: buttonWidth,
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
//                           border: !hasFocus ? Border.all(color: Colors.white.withOpacity(0.5), width: 2) : null,
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
//               const Text("SEARCH",
//                   style: TextStyle(
//                       fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
//               const SizedBox(height: 20),
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 40),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                     color: Colors.white10,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: ProfessionalColors.accentPurple)),
//                 child: Text(_searchText.isEmpty ? 'Typing...' : _searchText,
//                     style: const TextStyle(color: Colors.white, fontSize: 22)),
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
//                     int idx = _keyboardLayout
//                             .take(r.key)
//                             .fold(0, (p, e) => p + e.length) +
//                         c.key;
//                     if (idx >= _keyboardFocusNodes.length)
//                       return const SizedBox.shrink();
//                     bool isFocused = _focusedKeyRow == r.key && _focusedKeyCol == c.key;
//                     String key = c.value;
//                     double w = key == 'SPACE'
//                         ? 150
//                         : (key == 'OK' || key == 'DEL' ? 70 : 40);
//                     return Container(
//                       width: w,
//                       height: 35,
//                       margin: const EdgeInsets.all(4),
//                       child: Focus(
//                         focusNode: _keyboardFocusNodes[idx],
//                         onFocusChange: (has) {
//                           if (has)
//                             setState(() {
//                               _focusedKeyRow = r.key;
//                               _focusedKeyCol = c.key;
//                             });
//                         },
//                         child: ElevatedButton(
//                           onPressed: () => _handleKeyClick(key),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: isFocused
//                                 ? ProfessionalColors.accentPurple
//                                 : Colors.white10,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 side: isFocused
//                                     ? const BorderSide(color: Colors.white, width: 2)
//                                     : BorderSide.none),
//                             padding: EdgeInsets.zero,
//                           ),
//                           child: Text(key,
//                               style: const TextStyle(color: Colors.white, fontSize: 18)),
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
//     if (widget.sliderImages.isEmpty)
//       return Container(color: ProfessionalColors.primaryDark);
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         PageView.builder(
//           controller: _sliderPageController,
//           itemCount: widget.sliderImages.length,
//           onPageChanged: (index) {
//             setState(() {
//               _currentSliderPage = index;
//             });
//           },
//           itemBuilder: (c, i) => CachedNetworkImage(
//               imageUrl: widget.sliderImages[i],
//               fit: BoxFit.fill,
//               errorWidget: (c, u, e) =>
//                   Container(color: ProfessionalColors.surfaceDark)),
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
//           Text(widget.errorMessage ?? 'Something went wrong',
//               style: const TextStyle(color: Colors.white, fontSize: 18),
//               textAlign: TextAlign.center),
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

// class __MasterSliderCardState<T> extends State<_MasterSliderCard<T>>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _borderAnimationController;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController =
//         AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
//         CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));

//     _borderAnimationController =
//         AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
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
//       if (!_borderAnimationController.isAnimating)
//         _borderAnimationController.repeat();
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
//   //     width: widget.cardWidth + 30,
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



//   // _MasterSliderCard class ke andar build method mein change karein:
// @override
// Widget build(BuildContext context) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 10), // Spacing between cards
//     child: SizedBox(
//       width: widget.cardWidth, // Extra +30 hata dein
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           AnimatedBuilder(
//             animation: _scaleAnimation,
//             builder: (context, child) => Transform.scale(
//               scale: _scaleAnimation.value,
//               child: Focus(
//                 focusNode: widget.focusNode,
//                 child: GestureDetector(
//                   onTap: widget.onTap,
//                   child: _buildPoster(),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 15), // Title aur image ke beech space
//           _buildTitle(),
//         ],
//       ),
//     ),
//   );
// }

//   // Widget _buildPoster() {
//   //   return Container(
//   //     height: widget.cardHeight,
//   //     width: widget.cardWidth,
//   //     decoration: BoxDecoration(
//   //       borderRadius: BorderRadius.circular(8),
//   //     ),
//   //     child: Stack(
//   //       fit: StackFit.expand,
//   //       children: [
//   //         if (widget.isFocused)
//   //           AnimatedBuilder(
//   //             animation: _borderAnimationController,
//   //             builder: (context, child) {
//   //               return Container(
//   //                 decoration: BoxDecoration(
//   //                   borderRadius: BorderRadius.circular(8),
//   //                   gradient: SweepGradient(
//   //                     colors: [
//   //                       Colors.white.withOpacity(0.1),
//   //                       Colors.white,
//   //                       Colors.white,
//   //                       Colors.white.withOpacity(0.1)
//   //                     ],
//   //                     stops: const [0.0, 0.25, 0.5, 1.0],
//   //                     transform: GradientRotation(
//   //                         _borderAnimationController.value * 2 * math.pi),
//   //                   ),
//   //                 ),
//   //               );
//   //             },
//   //           ),
//   //         Padding(
//   //           padding: EdgeInsets.all(widget.isFocused ? 3.5 : 0.0),
//   //           child: ClipRRect(
//   //             borderRadius: BorderRadius.circular(widget.isFocused ? 5 : 8),
//   //             child: Stack(
//   //               fit: StackFit.expand,
//   //               children: [
//   //                 CachedNetworkImage(
//   //                   imageUrl: widget.getImageUrl(widget.item),
//   //                   fit: BoxFit.cover,
//   //                   placeholder: (c, u) => _placeholder(),
//   //                   errorWidget: (c, u, e) => _placeholder(),
//   //                 ),
//   //                 if (widget.logoUrl.isNotEmpty)
//   //                   Positioned(
//   //                       top: 5,
//   //                       right: 5,
//   //                       child: CircleAvatar(
//   //                           radius: 12,
//   //                           backgroundImage:
//   //                               CachedNetworkImageProvider(widget.logoUrl),
//   //                           backgroundColor: Colors.black54)),
//   //               ],
//   //             ),
//   //           ),
//   //         ),
//   //         if (widget.isFocused)
//   //           Positioned.fill(
//   //             child: Container(
//   //               decoration: BoxDecoration(
//   //                 borderRadius: BorderRadius.circular(8),
//   //                 border:
//   //                     Border.all(color: Colors.white.withOpacity(0.3), width: 1),
//   //               ),
//   //             ),
//   //           ),
//   //       ],
//   //     ),
//   //   );
//   // }



//   Widget _buildPoster() {
//     return Container(
//       height: widget.cardHeight,
//       width: widget.cardWidth,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         // // ADDED: Black shadow for the focused image
//         // boxShadow: widget.isFocused
//         //     ? [
//         //         BoxShadow(
//         //           color: Colors.black, // Deep black shadow
//         //           blurRadius: 40, // How soft the shadow is
//         //           spreadRadius: 18, // How far the shadow extends
//         //           offset: const Offset(0, 10), // Pushes the shadow down slightly
//         //         ),
//         //       ]
//         //     : [],
//                 boxShadow: [
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
//                       transform: GradientRotation(
//                           _borderAnimationController.value * 2 * math.pi),
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
//                             radius: 12,
//                             backgroundImage:
//                                 CachedNetworkImageProvider(widget.logoUrl),
//                             backgroundColor: Colors.black54)),
//                 ],
//               ),
//             ),
//           ),
//           if (widget.isFocused)
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   border:
//                       Border.all(color: Colors.white.withOpacity(0.3), width: 1),
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
//           Icon(widget.placeholderIcon,
//               size: widget.cardHeight * 0.25, color: Colors.grey),
//         ]),
//       );

//   // Widget _buildTitle() => Container(
//   //       width: widget.cardWidth,
//   //       height: 48,
//   //       padding: const EdgeInsets.symmetric(horizontal: 4),
//   //       alignment: Alignment.topCenter,
//   //       child: AnimatedDefaultTextStyle(
//   //         duration: const Duration(milliseconds: 250),
//   //         textAlign: TextAlign.center,
//   //         maxLines: 2,
//   //         softWrap: true,
//   //         overflow: TextOverflow.ellipsis,
//   //         style: TextStyle(
//   //           fontSize: 14,
//   //           fontWeight: widget.isFocused ? FontWeight.w900 : FontWeight.w400,
//   //           color: Colors.white,
//   //           letterSpacing: 0.5,
//   //           height: 1.2,
//   //         ),
//   //         child: Text(widget.getTitle(widget.item)),
//   //       ),
//   //     );
//   Widget _buildTitle() => Container(
//         width: widget.cardWidth,
//         height: 48,
//         padding: const EdgeInsets.symmetric(horizontal: 4),
//         alignment: Alignment.topCenter,
//         child: AnimatedDefaultTextStyle(
//           duration: const Duration(milliseconds: 250),
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           softWrap: true,
//           overflow: TextOverflow.ellipsis,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: widget.isFocused ? FontWeight.w900 : FontWeight.w400,
//             color: Colors.white,
//             letterSpacing: 0.5,
//             height: 1.2,
//             // ADDED: Text shadow to make the name easily visible
//             shadows: widget.isFocused
//                 ? [
//                     Shadow(
//                       color: Colors.black,
//                       blurRadius: 10,
//                       offset: const Offset(0, 10),
//                     ),
//                   ]
//                 : [],
//           ),
//           child: Text(widget.getTitle(widget.item)),
//         ),
//       );
// }




// import 'dart:async';
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
// import 'package:provider/provider.dart';

// // Assuming these exist in your project, keeping imports as is.
// import 'package:mobi_tv_entertainment/main.dart';

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
  
//   // Controls whether the list should shuffle once per filter
//   final bool shouldShuffle;

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
//     this.shouldShuffle = false,
//   }) : super(key: key);

//   @override
//   State<MasterSliderLayout<T>> createState() => _MasterSliderLayoutState<T>();
// }

// class _MasterSliderLayoutState<T> extends State<MasterSliderLayout<T>>
//     with TickerProviderStateMixin {
  
//   // Holds the permanent background image if slider is empty
//   String? _fallbackBackgroundImageUrl;

//   // Local list used for display
//   List<T> _displayList = [];
  
//   // Cache to store shuffled orders mapped by a string key
//   final Map<String, List<T>> _shuffledCache = {};
  
//   bool _isDisposed = false;
//   bool _shouldFocusFirstItem = false;
  
//   // Navigation lock variables for buttons
//   bool _isNetworkNavLocked = false;
//   bool _isFilterNavLocked = false;
//   Timer? _networkNavLockTimer;
//   Timer? _filterNavLockTimer;

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

//     // Initialize list and capture fallback image if available
//     _displayList = List.from(widget.contentList);
    
//     if (widget.contentList.isNotEmpty) {
//       _fallbackBackgroundImageUrl = widget.getImageUrl(widget.contentList.first);
//     }

//     // Shuffle and cache only if shouldShuffle is true
//     if (_displayList.isNotEmpty && widget.shouldShuffle) {
//       _displayList.shuffle();
//       String cacheKey = "filter_${widget.selectedFilterIndex}";
//       _shuffledCache[cacheKey] = List.from(_displayList);
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && !_isDisposed)
//         Provider.of<FocusProvider>(context, listen: false)
//             .updateName('');
//     });

//     _fadeController =
//         AnimationController(duration: AnimationTiming.medium, vsync: this);
//     _fadeAnimation =
//         CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

//     _borderAnimationController =
//         AnimationController(duration: const Duration(milliseconds: 2500), vsync: this)
//           ..repeat();

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

//     bool filterChanged = oldWidget.selectedFilterIndex != widget.selectedFilterIndex;
//     bool dataChanged = oldWidget.contentList != widget.contentList;
//     bool finishedLoading = (oldWidget.isLoading && !widget.isLoading) || 
//                            (oldWidget.isListLoading && !widget.isListLoading);

//     // Only process the list if something actually changed OR finished loading
//     if (filterChanged || dataChanged || finishedLoading) {
      
//       // Wait until loading is COMPLETELY finished and data is available
//       if (!widget.isLoading && !widget.isListLoading && widget.contentList.isNotEmpty) {
        
//         // Lock in the fallback background image ONCE
//         if (_fallbackBackgroundImageUrl == null) {
//           _fallbackBackgroundImageUrl = widget.getImageUrl(widget.contentList.first);
//         }

//         if (widget.shouldShuffle) {
//           // Create a unique key for this specific list
//           String cacheKey = _isSearching ? "search" : "filter_${widget.selectedFilterIndex}";

//           // Check if we have a cached shuffled order for this filter
//           if (_shuffledCache.containsKey(cacheKey) && _shuffledCache[cacheKey]!.length == widget.contentList.length) {
//             // Use saved order from cache
//             _displayList = List.from(_shuffledCache[cacheKey]!);
//           } else {
//             // First time: Shuffle and save to cache
//             _displayList = List.from(widget.contentList);
//             _displayList.shuffle();
//             _shuffledCache[cacheKey] = List.from(_displayList);
//           }
//         } else {
//           // SHUFFLING DISABLED: Display exactly as received
//           _displayList = List.from(widget.contentList);
//         }

//         // Generate focus nodes ONLY if the list size changed (prevents focus loss)
//         if (_itemFocusNodes.length != _displayList.length) {
//           _disposeFocusNodes(_itemFocusNodes);
//           _itemFocusNodes = List.generate(_displayList.length, (i) => FocusNode()..addListener(_setStateListener));
//           _focusedItemIndex = -1;
//         }

//       } else if (widget.contentList.isEmpty && !widget.isLoading) {
//         // Clear list if empty
//         _displayList = [];
//         if (_itemFocusNodes.isNotEmpty) {
//           _disposeFocusNodes(_itemFocusNodes);
//           _focusedItemIndex = -1;
//         }
//       }
//     }

//     if (oldWidget.filterNames.length != widget.filterNames.length) {
//       _disposeFocusNodes(_filterFocusNodes);
//       _filterFocusNodes = List.generate(widget.filterNames.length,
//           (i) => FocusNode()..addListener(_setStateListener));
//     }
//     if (oldWidget.networkNames.length != widget.networkNames.length) {
//       _disposeFocusNodes(_networkFocusNodes);
//       _networkFocusNodes = List.generate(widget.networkNames.length,
//           (i) => FocusNode()..addListener(_setStateListener));
//     }

//     if (oldWidget.sliderImages != widget.sliderImages) {
//       _setupSliderTimer();
//     }

//     bool justFinishedPageLoad =
//         oldWidget.isLoading == true && widget.isLoading == false;
//     bool justFinishedListLoad =
//         oldWidget.isListLoading == true && widget.isListLoading == false;
//     bool contentAppeared =
//         oldWidget.contentList.isEmpty && widget.contentList.isNotEmpty;

//     if ((justFinishedPageLoad ||
//             justFinishedListLoad ||
//             contentAppeared ||
//             _shouldFocusFirstItem) &&
//         !_showKeyboard) {
//       if (_shouldFocusFirstItem && !widget.isListLoading && !widget.isLoading) {
//         _shouldFocusFirstItem = false;
//       }

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!_isDisposed && mounted && !_showKeyboard) {
//           if (_displayList.isNotEmpty && _itemFocusNodes.isNotEmpty) {
//             Future.delayed(const Duration(milliseconds: 150), () {
//               if (!_isDisposed &&
//                   mounted &&
//                   _itemFocusNodes.isNotEmpty &&
//                   !_showKeyboard) {
//                 setState(() => _focusedItemIndex = 0);
//                 _itemFocusNodes[0].requestFocus();
//                 _scrollToCenter(_itemScrollController, 0, widget.cardWidth + 30, 20);
//                 Provider.of<FocusProvider>(context, listen: false)
//                     .updateName(widget.getTitle(_displayList[0]));
//               }
//             });
//           } else if (justFinishedPageLoad &&
//               widget.networkNames.isNotEmpty &&
//               _networkFocusNodes.isNotEmpty) {
//             _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//           } else if (justFinishedPageLoad &&
//               _searchButtonFocusNode.canRequestFocus) {
//             _searchButtonFocusNode.requestFocus();
//           }
//         }
//       });
//     }
//   }

//   void _initializeAllFocusNodes() {
//     _networkFocusNodes = List.generate(widget.networkNames.length,
//         (i) => FocusNode()..addListener(_setStateListener));
//     _filterFocusNodes = List.generate(widget.filterNames.length,
//         (i) => FocusNode()..addListener(_setStateListener));
//     _itemFocusNodes = List.generate(_displayList.length,
//         (i) => FocusNode()..addListener(_setStateListener));
//     int totalKeys = _keyboardLayout.fold(0, (prev, row) => prev + row.length);
//     _keyboardFocusNodes = List.generate(
//         totalKeys, (i) => FocusNode()..addListener(_setStateListener));
//   }

//   void _setStateListener() {
//     if (mounted && !_isDisposed) setState(() {});
//   }

//   void _disposeFocusNodes(List<FocusNode> nodes) {
//     for (var node in nodes) {
//       node.removeListener(_setStateListener);
//       try {
//         node.dispose();
//       } catch (_) {}
//     }
//     nodes.clear();
//   }

//   @override
//   void dispose() {
//     _isDisposed = true;
//     _sliderTimer?.cancel();
//     _debounce?.cancel();
//     _navigationLockTimer?.cancel();
//     _networkNavLockTimer?.cancel();
//     _filterNavLockTimer?.cancel();
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
//           _sliderPageController.animateToPage(next,
//               duration: const Duration(milliseconds: 500),
//               curve: Curves.easeInOut);
//         }
//       });
//     }
//   }

//   // Helper method to get actual button width
//   double _getButtonWidth(String label, {IconData? icon}) {
//     final TextPainter textPainter = TextPainter(
//       text: TextSpan(
//         text: label,
//         style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     )..layout();
    
//     double textWidth = textPainter.width;
//     double iconWidth = icon != null ? 24.0 : 0.0;
    
//     // 40.0 for inner container padding + 6.0 for the focus border padding
//     double horizontalPadding = 60.0; 
    
//     return textWidth + iconWidth + horizontalPadding;
//   }

//   void _scrollToCenter(ScrollController controller, int index, double itemWidth, double listPaddingStart) {
//     if (!controller.hasClients) return;

//     double screenWidth = MediaQuery.of(context).size.width;
//     double itemStartPosition = listPaddingStart;

//     if (controller == _networkScrollController) {
//       for (int i = 0; i < index; i++) {
//         itemStartPosition += _getButtonWidth(widget.networkNames[i].toUpperCase()) + 12;
//       }
//     } else if (controller == _filterScrollController) {
//       if (index > 0) {
//         itemStartPosition += _getButtonWidth("SEARCH", icon: Icons.search) + 12;
//         for (int i = 0; i < index - 1; i++) {
//           itemStartPosition += _getButtonWidth(widget.filterNames[i].toUpperCase()) + 12;
//         }
//       }
//     } else {
//       double itemEffectiveWidth = itemWidth; 
//       itemStartPosition += (index * itemEffectiveWidth);
//     }

//     double targetOffset = (itemStartPosition + (itemWidth / 2)) - (screenWidth / 2);

//     double maxScroll = controller.position.maxScrollExtent;
//     targetOffset = targetOffset.clamp(0.0, maxScroll);

//     controller.animateTo(
//       targetOffset,
//       duration: AnimationTiming.fast,
//       curve: Curves.easeInOut,
//     );
//   }

//   KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
//     if (_isDisposed || event is! RawKeyDownEvent || widget.isLoading)
//       return KeyEventResult.ignored;

//     final key = event.logicalKey;
//     if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape) {
//       if (_showKeyboard) {
//         setState(() {
//           _showKeyboard = false;
//           _focusedKeyRow = 0;
//           _focusedKeyCol = 0;
//         });
//         _searchButtonFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (_itemFocusNodes.any((n) => n.hasFocus) ||
//           _filterFocusNodes.any((n) => n.hasFocus) ||
//           _searchButtonFocusNode.hasFocus) {
//         if (_networkFocusNodes.isNotEmpty)
//           _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.ignored;
//     }

//     if (_showKeyboard && _keyboardFocusNodes.any((n) => n.hasFocus))
//       return _navigateKeyboard(key);
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
//         r--;
//         c = math.min(c, _keyboardLayout[r].length - 1);
//       } else {
//         if (_networkFocusNodes.isNotEmpty) {
//           _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//         }
//         return KeyEventResult.handled;
//       }
//     } else if (key == LogicalKeyboardKey.arrowDown) {
//       if (r < _keyboardLayout.length - 1) {
//         r++;
//         c = math.min(c, _keyboardLayout[r].length - 1);
//       } else {
//         if (_filterFocusNodes.isNotEmpty) {
//           int targetFilter =
//               widget.selectedFilterIndex >= 0 ? widget.selectedFilterIndex : 0;
//           _filterFocusNodes[targetFilter].requestFocus();
//         } else {
//           _searchButtonFocusNode.requestFocus();
//         }
//         return KeyEventResult.handled;
//       }
//     } else if (key == LogicalKeyboardKey.arrowLeft && c > 0)
//       c--;
//     else if (key == LogicalKeyboardKey.arrowRight &&
//         c < _keyboardLayout[r].length - 1)
//       c++;
//     else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _handleKeyClick(_keyboardLayout[r][c]);
//       return KeyEventResult.handled;
//     }

//     if (r != _focusedKeyRow || c != _focusedKeyCol) {
//       setState(() {
//         _focusedKeyRow = r;
//         _focusedKeyCol = c;
//       });
//       int idx = _getKeyboardNodeIndex(r, c);
//       if (idx < _keyboardFocusNodes.length)
//         _keyboardFocusNodes[idx].requestFocus();
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
//           if (_searchText.isNotEmpty)
//             _searchText = _searchText.substring(0, _searchText.length - 1);
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
//         setState(() {
//           _focusedKeyRow = _keyboardLayout.length - 1;
//           _focusedKeyCol = 0;
//         });
//         _keyboardFocusNodes[_getKeyboardNodeIndex(_focusedKeyRow, _focusedKeyCol)]
//             .requestFocus();
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
//     if (_isNetworkNavLocked) return KeyEventResult.handled;
//     _isNetworkNavLocked = true;
//     _networkNavLockTimer = Timer(const Duration(milliseconds: 500), () {
//       if (mounted) setState(() => _isNetworkNavLocked = false);
//     });

//     int focusedIndex = _networkFocusNodes.indexWhere((n) => n.hasFocus);
//     if (focusedIndex == -1) focusedIndex = widget.selectedNetworkIndex;

//     if (key == LogicalKeyboardKey.arrowLeft && focusedIndex > 0)
//       focusedIndex--;
//     else if (key == LogicalKeyboardKey.arrowRight &&
//         focusedIndex < _networkFocusNodes.length - 1)
//       focusedIndex++;
//     else if (key == LogicalKeyboardKey.arrowDown) {
//       if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
//         setState(() {
//           _focusedKeyRow = 0;
//           _focusedKeyCol = 0;
//         });
//         _keyboardFocusNodes[0].requestFocus();
//       } else {
//         _searchButtonFocusNode.requestFocus();
//       }
//       _isNetworkNavLocked = false;
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _shouldFocusFirstItem = true;
//       if (widget.onNetworkSelected != null) widget.onNetworkSelected!(focusedIndex);
//       _isNetworkNavLocked = false;
//       return KeyEventResult.handled;
//     }

//     if (focusedIndex != _networkFocusNodes.indexWhere((n) => n.hasFocus)) {
//       _networkFocusNodes[focusedIndex].requestFocus();
      
//       double buttonWidth = _getButtonWidth(
//         widget.networkNames[focusedIndex].toUpperCase()
//       );
      
//       _scrollToCenter(_networkScrollController, focusedIndex, buttonWidth, 20);
//     }
//     _isNetworkNavLocked = false;
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateFilters(LogicalKeyboardKey key) {
//     if (_isFilterNavLocked) return KeyEventResult.handled;
//     _isFilterNavLocked = true;
//     _filterNavLockTimer = Timer(const Duration(milliseconds: 500), () {
//       if (mounted) setState(() => _isFilterNavLocked = false);
//     });

//     int focusedIndex = _filterFocusNodes.indexWhere((n) => n.hasFocus);
//     if (focusedIndex == -1) focusedIndex = widget.selectedFilterIndex;

//     if (key == LogicalKeyboardKey.arrowLeft) {
//       if (focusedIndex > 0)
//         focusedIndex--;
//       else {
//         _searchButtonFocusNode.requestFocus();
//         _isFilterNavLocked = false;
//         return KeyEventResult.handled;
//       }
//     } else if (key == LogicalKeyboardKey.arrowRight &&
//         focusedIndex < _filterFocusNodes.length - 1)
//       focusedIndex++;
//     else if (key == LogicalKeyboardKey.arrowUp) {
//       if (_showKeyboard && _keyboardFocusNodes.isNotEmpty) {
//         setState(() {
//           _focusedKeyRow = _keyboardLayout.length - 1;
//           _focusedKeyCol = 0;
//         });
//         _keyboardFocusNodes[_getKeyboardNodeIndex(_focusedKeyRow, _focusedKeyCol)]
//             .requestFocus();
//       } else if (_networkFocusNodes.isNotEmpty) {
//         _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
//       }
//       _isFilterNavLocked = false;
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
//       int target = _lastFocusedItemIndex;
//       if (target >= _itemFocusNodes.length) target = _itemFocusNodes.length - 1;
//       if (target < 0) target = 0;

//       setState(() => _focusedItemIndex = target);
//       _itemFocusNodes[target].requestFocus();
//       _isFilterNavLocked = false;
//       return KeyEventResult.handled;
//     } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _shouldFocusFirstItem = true;
//       widget.onFilterSelected(focusedIndex);
//       _isFilterNavLocked = false;
//       return KeyEventResult.handled;
//     }

//     if (focusedIndex != _filterFocusNodes.indexWhere((n) => n.hasFocus)) {
//       _filterFocusNodes[focusedIndex].requestFocus();
      
//       double buttonWidth = _getButtonWidth(
//         widget.filterNames[focusedIndex].toUpperCase()
//       );
      
//       _scrollToCenter(_filterScrollController, focusedIndex + 1, buttonWidth, 20);
//     }
//     _isFilterNavLocked = false;
//     return KeyEventResult.handled;
//   }

//   KeyEventResult _navigateItems(LogicalKeyboardKey key) {
//     if (_isNavigationLocked) return KeyEventResult.handled;
//     _isNavigationLocked = true;
//     _navigationLockTimer = Timer(const Duration(milliseconds: 500), () {
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
//     } else if (key == LogicalKeyboardKey.arrowLeft && i > 0)
//       i--;
//     else if (key == LogicalKeyboardKey.arrowRight &&
//         i < _itemFocusNodes.length - 1)
//       i++;
//     else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
//       _isNavigationLocked = false;
//       widget.onContentTap(_displayList[i], i);
//       return KeyEventResult.handled;
//     }

//     if (i != _focusedItemIndex && i >= 0 && i < _itemFocusNodes.length) {
//       setState(() => _focusedItemIndex = i);
//       _itemFocusNodes[i].requestFocus();
//       _scrollToCenter(_itemScrollController, i, widget.cardWidth + 20, 20);
//       Provider.of<FocusProvider>(context, listen: false)
//           .updateName(widget.getTitle(_displayList[i]));
//     } else {
//       _isNavigationLocked = false;
//     }
//     return KeyEventResult.handled;
//   }

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
//                 children: [
//                   SizedBox(height: MediaQuery.of(context).size.height * 0.04,),
//                   if (widget.networkNames.isNotEmpty) _buildTopFilterBar(),
//                   if (widget.networkNames.isEmpty) ...[
//                     SizedBox(height: MediaQuery.of(context).padding.top + 20),
//                     _buildBeautifulAppBar(),
//                   ],
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                             height: MediaQuery.of(context).size.height * 0.4,
//                             child: _showKeyboard
//                                 ? _buildSearchUI()
//                                 : const SizedBox.shrink()),
//                         _buildSliderIndicators(),
//                         _buildFilterBar(),
//                         const SizedBox(height: 20),
//                         _buildContentArea(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (widget.isLoading &&
//                 _displayList.isEmpty &&
//                 widget.filterNames.isEmpty)
//               Container(
//                 color: ProfessionalColors.primaryDark,
//                 child: const Center(
//                     child: CircularProgressIndicator(color: Colors.white)),
//               ),
//             if (widget.isVideoLoading && widget.errorMessage == null)
//               Positioned.fill(
//                   child: Container(
//                       color: Colors.black87,
//                       child: const Center(
//                           child:
//                               CircularProgressIndicator(color: Colors.white)))),
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
//       return const Expanded(
//           child: Center(child: CircularProgressIndicator(color: Colors.white)));
//     }
//     return _buildContentList();
//   }

//   Widget _buildBeautifulAppBar() {
//     final focusName = context.watch<FocusProvider>().focusedItemName;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//       decoration: BoxDecoration(
//           gradient: LinearGradient(
//               colors: [Colors.black.withOpacity(0.0), Colors.transparent],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter)),
//       child: Row(
//         children: [
//           Text(widget.title,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: 26, color: Colors.white)),
//           const SizedBox(width: 20),
//           Expanded(
//               child: Text(focusName,
//                   style: const TextStyle(
//                       color: ProfessionalColors.textSecondary,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 20),
//                   overflow: TextOverflow.ellipsis)),
//         ],
//       ),
//     );
//   }

//   Widget _buildTopFilterBar() {
//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: EdgeInsets.only(
//               top: MediaQuery.of(context).padding.top + 5, bottom: 5, left: MediaQuery.of(context).size.width * 0.03),
//           decoration: BoxDecoration(
//               border: Border(
//                   bottom: BorderSide(
//                       color: Colors.white.withOpacity(0.1), width: 1))),
//           child: Row(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 35,
//                   child: ListView.builder(
//                     controller: _networkScrollController,
//                     scrollDirection: Axis.horizontal,
//         cacheExtent: 5000,

//                     itemCount: widget.networkNames.length,
//                     itemBuilder: (ctx, i) {
//                       if (i >= _networkFocusNodes.length)
//                         return const SizedBox.shrink();
//                       bool isSelected = widget.selectedNetworkIndex == i;
                      
//                       double buttonWidth = _getButtonWidth(
//                         widget.networkNames[i].toUpperCase()
//                       );
                      
//                       return Focus(
//                         focusNode: _networkFocusNodes[i],
//                         onFocusChange: (has) {
//                           if (has && !_isDisposed) {
//                             _scrollToCenter(
//                               _networkScrollController, 
//                               i, 
//                               buttonWidth, 
//                               20
//                             );
//                           }
//                         },
//                         child: _buildGlassButton(
//                           focusNode: _networkFocusNodes[i],
//                           isSelected: isSelected,
//                           color: widget
//                               .focusColors[i % widget.focusColors.length],
//                           label: widget.networkNames[i].toUpperCase(),
//                           customWidth: buttonWidth,
//                           onTap: () {
//                             _shouldFocusFirstItem = true;
//                             if (widget.onNetworkSelected != null)
//                               widget.onNetworkSelected!(i);
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

//   // Widget _buildFilterBar() {
//   //   if (widget.filterNames.isEmpty && !_isSearching)
//   //     return const SizedBox(height: 30);
    
//   //   return SizedBox(
//   //     height: 35,
//   //     child: ListView.builder(
//   //       controller: _filterScrollController,
//   //       scrollDirection: Axis.horizontal,
//   //       cacheExtent: 5000,
//   //       itemCount: widget.filterNames.length + 1,
//   //       padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
//   //       itemBuilder: (ctx, i) {
//   //         if (i == 0) {
//   //           double searchButtonWidth = _getButtonWidth("SEARCH", icon: Icons.search);
            
//   //           return Focus(
//   //             focusNode: _searchButtonFocusNode,
//   //             onFocusChange: (has) {
//   //               if (has && !_isDisposed) {
//   //                 Provider.of<FocusProvider>(context, listen: false)
//   //                     .updateName("SEARCH");
//   //                 _scrollToCenter(_filterScrollController, 0, searchButtonWidth, 20);
//   //               }
//   //             },
//   //             child: _buildGlassButton(
//   //               focusNode: _searchButtonFocusNode,
//   //               isSelected: _isSearching || _showKeyboard,
//   //               color: ProfessionalColors.accentOrange,
//   //               label: "SEARCH",
//   //               icon: Icons.search,
//   //               customWidth: searchButtonWidth,
//   //               onTap: () => setState(() {
//   //                 _showKeyboard = true;
//   //                 _searchButtonFocusNode.requestFocus();
//   //               }),
//   //             ),
//   //           );
//   //         }
          
//   //         int filterIdx = i - 1;
//   //         if (filterIdx >= _filterFocusNodes.length) return const SizedBox.shrink();
          
//   //         double buttonWidth = _getButtonWidth(
//   //           widget.filterNames[filterIdx].toUpperCase()
//   //         );
          
//   //         return Focus(
//   //           focusNode: _filterFocusNodes[filterIdx],
//   //           onFocusChange: (has) {
//   //             if (has && !_isDisposed) {
//   //               _scrollToCenter(_filterScrollController, i, buttonWidth, 20);
//   //             }
//   //           },
//   //           child: _buildGlassButton(
//   //             focusNode: _filterFocusNodes[filterIdx],
//   //             isSelected:
//   //                 !_isSearching && widget.selectedFilterIndex == filterIdx,
//   //             color: widget
//   //                 .focusColors[filterIdx % widget.focusColors.length],
//   //             label: widget.filterNames[filterIdx].toUpperCase(),
//   //             customWidth: buttonWidth,
//   //             onTap: () {
//   //               _shouldFocusFirstItem = true;
//   //               widget.onFilterSelected(filterIdx);
//   //             },
//   //           ),
//   //         );
//   //       },
//   //     ),
//   //   );
//   // }


// Widget _buildFilterBar() {
//   if (widget.filterNames.isEmpty && !_isSearching)
//     return const SizedBox(height: 30);

//   // 1. Prioritize labels
//   List<String> prioritizedList = List.from(widget.filterNames);
//   if (prioritizedList.contains("Web Series")) {
//     prioritizedList.remove("Web Series");
//     prioritizedList.insert(0, "Web Series");
//   }
//   if (prioritizedList.contains("Latest")) {
//     prioritizedList.remove("Latest");
//     int targetIdx = prioritizedList.contains("Web Series") ? 1 : 0;
//     prioritizedList.insert(targetIdx, "Latest");
//   }

//   return SizedBox(
//     height: 35,
//     child: ListView.builder(
//       controller: _filterScrollController,
//       scrollDirection: Axis.horizontal,
//       cacheExtent: 5000,
//       itemCount: prioritizedList.length + 1,
//       padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
//       itemBuilder: (ctx, i) {
//         if (i == 0) {
//           // SEARCH Button logic remains same
//           double searchButtonWidth = _getButtonWidth("SEARCH", icon: Icons.search);
//           return Focus(
//             focusNode: _searchButtonFocusNode,
//             onFocusChange: (has) {
//               if (has && !_isDisposed) {
//                 Provider.of<FocusProvider>(context, listen: false)
//                     .updateName("SEARCH");
//                 _scrollToCenter(_filterScrollController, 0, searchButtonWidth, 20);
//               }
//             },
//             child: _buildGlassButton(
//               focusNode: _searchButtonFocusNode,
//               isSelected: _isSearching || _showKeyboard,
//               color: ProfessionalColors.accentOrange,
//               label: "SEARCH",
//               icon: Icons.search,
//               customWidth: searchButtonWidth,
//               onTap: () => setState(() {
//                 _showKeyboard = true;
//                 _searchButtonFocusNode.requestFocus();
//               }),
//             ),
//           );
//         }

//         // --- FIXED FOCUS LOGIC ---
//         int currentIdx = i - 1; // Prioritized index
//         String labelText = prioritizedList[currentIdx];
        
//         // Original index find karein taaki hum sahi data aur SAHI FocusNode utha sakein
//         int originalFilterIdx = widget.filterNames.indexOf(labelText);
        
//         // CRITICAL: Hum 'i-1' wala node nahi, balki 'original' node use karenge 
//         // par usse 'Focus' widget ke andar wrap karenge sequence maintain karne ke liye.
//         FocusNode correctNode = _filterFocusNodes[originalFilterIdx];
        
//         double buttonWidth = _getButtonWidth(labelText.toUpperCase());

//         return Focus(
//           focusNode: correctNode, // Sequence sync ho gaya
//           onKey: (node, event) {
//             // Yahan hum manual navigation handle karenge taaki sequence mat toote
//             if (event is RawKeyDownEvent) {
//               if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                 if (i < prioritizedList.length) {
//                   // Agle prioritized item ka original index nikalein
//                   String nextLabel = prioritizedList[currentIdx + 1];
//                   int nextOriginalIdx = widget.filterNames.indexOf(nextLabel);
//                   _filterFocusNodes[nextOriginalIdx].requestFocus();
//                   return KeyEventResult.handled;
//                 }
//               } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//                 if (i == 1) {
//                   _searchButtonFocusNode.requestFocus();
//                   return KeyEventResult.handled;
//                 } else {
//                   // Pichle prioritized item ka original index nikalein
//                   String prevLabel = prioritizedList[currentIdx - 1];
//                   int prevOriginalIdx = widget.filterNames.indexOf(prevLabel);
//                   _filterFocusNodes[prevOriginalIdx].requestFocus();
//                   return KeyEventResult.handled;
//                 }
//               }
//             }
//             return KeyEventResult.ignored;
//           },
//           onFocusChange: (has) {
//             if (has && !_isDisposed) {
//               _scrollToCenter(_filterScrollController, i, buttonWidth, 20);
//             }
//           },
//           child: _buildGlassButton(
//             focusNode: correctNode,
//             isSelected: !_isSearching && widget.selectedFilterIndex == originalFilterIdx,
//             color: widget.focusColors[originalFilterIdx % widget.focusColors.length],
//             label: labelText.toUpperCase(),
//             customWidth: buttonWidth,
//             onTap: () {
//               _shouldFocusFirstItem = true;
//               widget.onFilterSelected(originalFilterIdx);
//             },
//           ),
//         );
//       },
//     ),
//   );
// }

//   Widget _buildContentList() {
//     if (_displayList.isEmpty) {
//       return Expanded(
//           child: Center(
//               child: Text(widget.emptyMessage,
//                   style: const TextStyle(color: Colors.white54, fontSize: 18))));
//     }
//     return Expanded(
//       child: ListView.builder(
//         controller: _itemScrollController,
//         scrollDirection: Axis.horizontal,
//         padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
//         clipBehavior: Clip.none,
//         itemCount: _displayList.length,
//         itemBuilder: (ctx, i) {
//           if (i >= _itemFocusNodes.length) return const SizedBox.shrink();
//           final item = _displayList[i];
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
//                   _scrollToCenter(_itemScrollController, i, widget.cardWidth + 30, 20);
//                   Provider.of<FocusProvider>(context, listen: false)
//                       .updateName(widget.getTitle(item));
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

//   Widget _buildGlassButton({
//     required FocusNode focusNode,
//     required bool isSelected,
//     required Color color,
//     required String label,
//     IconData? icon,
//     required VoidCallback onTap,
//     double? customWidth,
//   }) {
//     bool hasFocus = focusNode.hasFocus;
//     double buttonWidth = customWidth ?? _getButtonWidth(label, icon: icon);
    
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: buttonWidth,
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
//                           border: !hasFocus ? Border.all(color: Colors.white.withOpacity(0.5), width: 2) : null,
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
//               const Text("SEARCH",
//                   style: TextStyle(
//                       fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
//               const SizedBox(height: 20),
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 40),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                     color: Colors.white10,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: ProfessionalColors.accentPurple)),
//                 child: Text(_searchText.isEmpty ? 'Typing...' : _searchText,
//                     style: const TextStyle(color: Colors.white, fontSize: 22)),
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
//                     int idx = _keyboardLayout
//                             .take(r.key)
//                             .fold(0, (p, e) => p + e.length) +
//                         c.key;
//                     if (idx >= _keyboardFocusNodes.length)
//                       return const SizedBox.shrink();
//                     bool isFocused = _focusedKeyRow == r.key && _focusedKeyCol == c.key;
//                     String key = c.value;
//                     double w = key == 'SPACE'
//                         ? 150
//                         : (key == 'OK' || key == 'DEL' ? 70 : 40);
//                     return Container(
//                       width: w,
//                       height: 35,
//                       margin: const EdgeInsets.all(4),
//                       child: Focus(
//                         focusNode: _keyboardFocusNodes[idx],
//                         onFocusChange: (has) {
//                           if (has)
//                             setState(() {
//                               _focusedKeyRow = r.key;
//                               _focusedKeyCol = c.key;
//                             });
//                         },
//                         child: ElevatedButton(
//                           onPressed: () => _handleKeyClick(key),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: isFocused
//                                 ? ProfessionalColors.accentPurple
//                                 : Colors.white10,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 side: isFocused
//                                     ? const BorderSide(color: Colors.white, width: 2)
//                                     : BorderSide.none),
//                             padding: EdgeInsets.zero,
//                           ),
//                           child: Text(key,
//                               style: const TextStyle(color: Colors.white, fontSize: 18)),
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
//     // Fallback: If no slider images are provided, use the permanent fallback image
//     if (widget.sliderImages.isEmpty) {
//       if (_fallbackBackgroundImageUrl != null) {
//         return Stack(
//           fit: StackFit.expand,
//           children: [
//             CachedNetworkImage(
//               imageUrl: _fallbackBackgroundImageUrl!,
//               fit: BoxFit.cover,
//               errorWidget: (c, u, e) => Container(color: ProfessionalColors.primaryDark),
//             ),
//             // Dark overlay to ensure text readability
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black.withOpacity(0.4),
//                     ProfessionalColors.primaryDark.withOpacity(0.9),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         );
//       }
//       return Container(color: ProfessionalColors.primaryDark);
//     }

//     // Original slider
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         PageView.builder(
//           controller: _sliderPageController,
//           itemCount: widget.sliderImages.length,
//           onPageChanged: (index) {
//             setState(() {
//               _currentSliderPage = index;
//             });
//           },
//           itemBuilder: (c, i) => CachedNetworkImage(
//               imageUrl: widget.sliderImages[i],
//               fit: BoxFit.fill,
//               errorWidget: (c, u, e) =>
//                   Container(color: ProfessionalColors.surfaceDark)),
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
//           Text(widget.errorMessage ?? 'Something went wrong',
//               style: const TextStyle(color: Colors.white, fontSize: 18),
//               textAlign: TextAlign.center),
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

// class __MasterSliderCardState<T> extends State<_MasterSliderCard<T>>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _borderAnimationController;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController =
//         AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
//         CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));

//     _borderAnimationController =
//         AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
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
//       if (!_borderAnimationController.isAnimating)
//         _borderAnimationController.repeat();
//     } else {
//       _scaleController.reverse();
//       _borderAnimationController.stop();
//     }
//   }

//   void _handleFocus() {
//     if (!mounted) return;
//     widget.onFocusChange(widget.focusNode.hasFocus);
//   }


// Color _getBadgeColor(String genre) {
//   String g = genre.toLowerCase();
//   // Hum priority keywords ke liye specific color denge
//   if (g.contains("web series")) return Colors.red.withOpacity(0.6); // 60% Transparency
//   if (g.contains("tv show")) return Colors.blue.withOpacity(0.6);
//   if (g.contains("latest")) return Colors.orange.withOpacity(0.6);
//   return Colors.transparent; // Agar inme se kuch nahi hai to badge nahi dikhega
// }

// String _getCleanGenre(String genre) {
//   String g = genre.toLowerCase();
//   // Sirf specific words ko filter karke wapas bhej rahe hain
//   if (g.contains("web series")) return "WEB SERIES";
//   if (g.contains("tv show")) return "TV SHOW";
//   if (g.contains("latest")) return "LATEST";
//   return ""; // Baaki genres (Action, Thriller) ke liye khali string
// }

//   @override
//   void dispose() {
//     widget.focusNode.removeListener(_handleFocus);
//     _scaleController.dispose();
//     _borderAnimationController.dispose();
//     super.dispose();
//   }

// @override
// Widget build(BuildContext context) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 10),
//     child: SizedBox(
//       width: widget.cardWidth,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           AnimatedBuilder(
//             animation: _scaleAnimation,
//             builder: (context, child) => Transform.scale(
//               scale: _scaleAnimation.value,
//               child: Focus(
//                 focusNode: widget.focusNode,
//                 child: GestureDetector(
//                   onTap: widget.onTap,
//                   child: _buildPoster(),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 15),
//           _buildTitle(),
//         ],
//       ),
//     ),
//   );
// }





//   // Widget _buildPoster() {
//   //   return Container(
//   //     height: widget.cardHeight,
//   //     width: widget.cardWidth,
//   //     decoration: BoxDecoration(
//   //       borderRadius: BorderRadius.circular(8),
//   //       boxShadow: [
//   //         if (widget.isFocused) BoxShadow(color: Colors.black.withOpacity(0.95), blurRadius: 25, spreadRadius: 8, offset: const Offset(0, 12))
//   //         else BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))
//   //       ],
//   //     ),
//   //     child: Stack(
//   //       fit: StackFit.expand,
//   //       children: [
//   //         if (widget.isFocused)
//   //           AnimatedBuilder(
//   //             animation: _borderAnimationController,
//   //             builder: (context, child) {
//   //               return Container(
//   //                 decoration: BoxDecoration(
//   //                   borderRadius: BorderRadius.circular(8),
//   //                   gradient: SweepGradient(
//   //                     colors: [Colors.white.withOpacity(0.1), Colors.white, Colors.white, Colors.white.withOpacity(0.1)],
//   //                     stops: const [0.0, 0.25, 0.5, 1.0],
//   //                     transform: GradientRotation(
//   //                         _borderAnimationController.value * 2 * math.pi),
//   //                   ),
//   //                 ),
//   //               );
//   //             },
//   //           ),
//   //         Padding(
//   //           padding: EdgeInsets.all(widget.isFocused ? 3.5 : 0.0),
//   //           child: ClipRRect(
//   //             borderRadius: BorderRadius.circular(widget.isFocused ? 5 : 8),
//   //             child: Stack(
//   //               fit: StackFit.expand,
//   //               children: [
//   //                 CachedNetworkImage(
//   //                   imageUrl: widget.getImageUrl(widget.item),
//   //                   fit: BoxFit.cover,
//   //                   placeholder: (c, u) => _placeholder(),
//   //                   errorWidget: (c, u, e) => _placeholder(),
//   //                 ),
//   //                 if (widget.logoUrl.isNotEmpty)
//   //                   Positioned(
//   //                       top: 5,
//   //                       right: 5,
//   //                       child: CircleAvatar(
//   //                           radius: 12,
//   //                           backgroundImage:
//   //                               CachedNetworkImageProvider(widget.logoUrl),
//   //                           backgroundColor: Colors.black54)),
//   //               ],
//   //             ),
//   //           ),
//   //         ),
//   //         if (widget.isFocused)
//   //           Positioned.fill(
//   //             child: Container(
//   //               decoration: BoxDecoration(
//   //                 borderRadius: BorderRadius.circular(8),
//   //                 border:
//   //                     Border.all(color: Colors.white.withOpacity(0.3), width: 1),
//   //               ),
//   //             ),
//   //           ),
//   //       ],
//   //     ),
//   //   );
//   // }


// Widget _buildPoster() {
//   final dynamic item = widget.item;
//   final String rawGenre = item.genres ?? "";
  
//   // Cleaned text aur color nikalte hain
//   final String displayGenre = _getCleanGenre(rawGenre);
//   final Color badgeColor = _getBadgeColor(rawGenre);

//   return Container(
//     height: widget.cardHeight,
//     width: widget.cardWidth,
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(8),
//       boxShadow: [
//         if (widget.isFocused) 
//           BoxShadow(color: Colors.black.withOpacity(0.95), blurRadius: 25, spreadRadius: 8, offset: const Offset(0, 12))
//         else 
//           BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))
//       ],
//     ),
//     child: Stack(
//       fit: StackFit.expand,
//       children: [
//         // Focus Border (Existing)
//         if (widget.isFocused)
//           AnimatedBuilder(
//             animation: _borderAnimationController,
//             builder: (context, child) {
//               return Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   gradient: SweepGradient(
//                     colors: [Colors.white.withOpacity(0.1), Colors.white, Colors.white, Colors.white.withOpacity(0.1)],
//                     stops: const [0.0, 0.25, 0.5, 1.0],
//                     transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
//                   ),
//                 ),
//               );
//             },
//           ),
        
//         Padding(
//           padding: EdgeInsets.all(widget.isFocused ? 3.5 : 0.0),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(widget.isFocused ? 5 : 8),
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 CachedNetworkImage(
//                   imageUrl: widget.getImageUrl(widget.item),
//                   fit: BoxFit.cover,
//                   placeholder: (c, u) => _placeholder(),
//                   errorWidget: (c, u, e) => _placeholder(),
//                 ),

//                 // --- UPDATED SUBTLE BADGE ---
//                 if (displayGenre.isNotEmpty)
//                   Positioned(
//                     top: 6,
//                     left: 6,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: badgeColor, // Filtered Color with low opacity
//                         borderRadius: BorderRadius.circular(2),
//                         border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5), // Patli border for definition
//                       ),
//                       child: Text(
//                         displayGenre,
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.9), // Text bhi thoda transparent
//                           fontSize: nametextsz * 0.6 , // Chota font size
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: 0.3,
//                         ),
//                       ),
//                     ),
//                   ),

//                 // Logo Logic (Existing)
//                 if (widget.logoUrl.isNotEmpty)
//                   Positioned(
//                     top: 5,
//                     right: 5,
//                     child: CircleAvatar(
//                       radius: 10, // Logo thoda chota kiya balance ke liye
//                       backgroundImage: CachedNetworkImageProvider(widget.logoUrl),
//                       backgroundColor: Colors.black45,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

//   Widget _placeholder() => Container(
//         color: ProfessionalColors.cardDark,
//         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Icon(widget.placeholderIcon,
//               size: widget.cardHeight * 0.25, color: Colors.grey),
//         ]),
//       );

//   Widget _buildTitle() => Container(
//         width: widget.cardWidth,
//         height: 48,
//         padding: const EdgeInsets.symmetric(horizontal: 4),
//         alignment: Alignment.topCenter,
//         child: AnimatedDefaultTextStyle(
//           duration: const Duration(milliseconds: 250),
//           textAlign: TextAlign.center,
//           maxLines: 2,
//           softWrap: true,
//           overflow: TextOverflow.ellipsis,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: widget.isFocused ? FontWeight.w900 : FontWeight.w400,
//             color: Colors.white,
//             letterSpacing: 0.5,
//             height: 1.2,
//             shadows: widget.isFocused
//                 ? [
//                     const Shadow(
//                       color: Colors.black,
//                       blurRadius: 10,
//                       offset: Offset(0, 10),
//                     ),
//                   ]
//                 : [],
//           ),
//           child: Text(widget.getTitle(widget.item)),
//         ),
//       );
// }




import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/components/widgets/focused_overlay_list.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:provider/provider.dart';

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
  static const Duration medium = Duration(milliseconds: 600);
}


class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Styling the lines. Opacity is set low so the grid doesn't overpower your content.
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.15) // Subtle black lines
      ..strokeWidth = 1.0; // Very thin lines

    // Spacing of 10.0 pixels gives roughly the "5 lines per centimeter" feel
    double spacing = 5.0;

    // Draw Vertical Lines
    for (double i = 0; i <= size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw Horizontal Lines
    for (double i = 0; i <= size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
  
  final bool shouldShuffle;

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
    this.shouldShuffle = false,
  }) : super(key: key);

  @override
  State<MasterSliderLayout<T>> createState() => _MasterSliderLayoutState<T>();
}

class _MasterSliderLayoutState<T> extends State<MasterSliderLayout<T>>
    with TickerProviderStateMixin {
  
  // --- DYNAMIC MATH FOR AUTO-SCALING ---
  // Calculates spacing and zoom based on the cardWidth provided by the parent
  double get _dynamicSpacing => widget.cardWidth * 0.08; 
  double get _itemFullWidth => widget.cardWidth + _dynamicSpacing; 
  double get _dynamicScale => 1.0 + (60.0 / widget.cardWidth); 

  double get _listPadding => MediaQuery.of(context).size.width * 0.05; // 5% horizontal padding

  String? _fallbackBackgroundImageUrl;
  List<T> _displayList = [];
  final Map<String, List<T>> _shuffledCache = {};
  
  bool _isDisposed = false;
  bool _shouldFocusFirstItem = false;
  
  bool _isNetworkNavLocked = false;
  bool _isFilterNavLocked = false;
  Timer? _networkNavLockTimer;
  Timer? _filterNavLockTimer;

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
  int _lastFocusedItemIndex = 0;

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

    _displayList = List.from(widget.contentList);
    
    if (widget.contentList.isNotEmpty) {
      _fallbackBackgroundImageUrl = widget.getImageUrl(widget.contentList.first);
    }

    if (_displayList.isNotEmpty && widget.shouldShuffle) {
      _displayList.shuffle();
      String cacheKey = "filter_${widget.selectedFilterIndex}";
      _shuffledCache[cacheKey] = List.from(_displayList);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed)
        Provider.of<FocusProvider>(context, listen: false).updateName('');
    });

    _fadeController = AnimationController(duration: AnimationTiming.medium, vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    _borderAnimationController =
        AnimationController(duration: const Duration(milliseconds: 2500), vsync: this)..repeat();

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

    bool filterChanged = oldWidget.selectedFilterIndex != widget.selectedFilterIndex;
    bool dataChanged = oldWidget.contentList != widget.contentList;
    bool finishedLoading = (oldWidget.isLoading && !widget.isLoading) || 
                           (oldWidget.isListLoading && !widget.isListLoading);

    if (filterChanged || dataChanged || finishedLoading) {
      if (!widget.isLoading && !widget.isListLoading && widget.contentList.isNotEmpty) {
        if (_fallbackBackgroundImageUrl == null) {
          _fallbackBackgroundImageUrl = widget.getImageUrl(widget.contentList.first);
        }

        if (widget.shouldShuffle) {
          String cacheKey = _isSearching ? "search" : "filter_${widget.selectedFilterIndex}";
          if (_shuffledCache.containsKey(cacheKey) && _shuffledCache[cacheKey]!.length == widget.contentList.length) {
            _displayList = List.from(_shuffledCache[cacheKey]!);
          } else {
            _displayList = List.from(widget.contentList);
            _displayList.shuffle();
            _shuffledCache[cacheKey] = List.from(_displayList);
          }
        } else {
          _displayList = List.from(widget.contentList);
        }

        if (_itemFocusNodes.length != _displayList.length) {
          _disposeFocusNodes(_itemFocusNodes);
          _itemFocusNodes = List.generate(_displayList.length, (i) => FocusNode()..addListener(_setStateListener));
          _focusedItemIndex = -1;
        }

      } else if (widget.contentList.isEmpty && !widget.isLoading) {
        _displayList = [];
        if (_itemFocusNodes.isNotEmpty) {
          _disposeFocusNodes(_itemFocusNodes);
          _focusedItemIndex = -1;
        }
      }
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

    bool justFinishedPageLoad = oldWidget.isLoading == true && widget.isLoading == false;
    bool justFinishedListLoad = oldWidget.isListLoading == true && widget.isListLoading == false;
    bool contentAppeared = oldWidget.contentList.isEmpty && widget.contentList.isNotEmpty;

    if ((justFinishedPageLoad || justFinishedListLoad || contentAppeared || _shouldFocusFirstItem) && !_showKeyboard) {
      if (_shouldFocusFirstItem && !widget.isListLoading && !widget.isLoading) {
        _shouldFocusFirstItem = false;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted && !_showKeyboard) {
          if (_displayList.isNotEmpty && _itemFocusNodes.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (!_isDisposed && mounted && _itemFocusNodes.isNotEmpty && !_showKeyboard) {
                setState(() => _focusedItemIndex = 0);
                _itemFocusNodes[0].requestFocus();
                _scrollToCenter(_itemScrollController, 0, _itemFullWidth, _listPadding);
                Provider.of<FocusProvider>(context, listen: false)
                    .updateName(widget.getTitle(_displayList[0]));
              }
            });
          } else if (justFinishedPageLoad && widget.networkNames.isNotEmpty && _networkFocusNodes.isNotEmpty) {
            _networkFocusNodes[widget.selectedNetworkIndex].requestFocus();
          } else if (justFinishedPageLoad && _searchButtonFocusNode.canRequestFocus) {
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
    _itemFocusNodes = List.generate(_displayList.length,
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
    _networkNavLockTimer?.cancel();
    _filterNavLockTimer?.cancel();
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
              duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      });
    }
  }

  double _getButtonWidth(String label, {IconData? icon}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    
    double textWidth = textPainter.width;
    double iconWidth = icon != null ? 24.0 : 0.0;
    double horizontalPadding = 60.0; 
    
    return textWidth + iconWidth + horizontalPadding;
  }

  void _scrollToCenter(ScrollController controller, int index, double itemWidth, double listPaddingStart) {
    if (!controller.hasClients) return;

    double screenWidth = MediaQuery.of(context).size.width;
    double itemStartPosition = listPaddingStart;

    if (controller == _networkScrollController) {
      for (int i = 0; i < index; i++) {
        itemStartPosition += _getButtonWidth(widget.networkNames[i].toUpperCase()) + 12;
      }
    } else if (controller == _filterScrollController) {
      if (index > 0) {
        itemStartPosition += _getButtonWidth("SEARCH", icon: Icons.search) + 12;
        for (int i = 0; i < index - 1; i++) {
          itemStartPosition += _getButtonWidth(widget.filterNames[i].toUpperCase()) + 12;
        }
      }
    } else {
      double itemEffectiveWidth = itemWidth; 
      itemStartPosition += (index * itemEffectiveWidth);
    }

    double targetOffset = (itemStartPosition + (itemWidth / 2)) - (screenWidth / 2);
    double maxScroll = controller.position.maxScrollExtent;
    targetOffset = targetOffset.clamp(0.0, maxScroll);

    controller.animateTo(
      targetOffset,
      duration: AnimationTiming.medium,
      curve: Curves.easeInOut,
    );
  }

  KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
    if (_isDisposed || event is! RawKeyDownEvent || widget.isLoading)
      return KeyEventResult.ignored;

    final key = event.logicalKey;
    if ( key == LogicalKeyboardKey.escape) {
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
          int targetFilter = widget.selectedFilterIndex >= 0 ? widget.selectedFilterIndex : 0;
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
    if (_isNetworkNavLocked) return KeyEventResult.handled;
    _isNetworkNavLocked = true;
    _networkNavLockTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isNetworkNavLocked = false);
    });

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
      _isNetworkNavLocked = false;
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _shouldFocusFirstItem = true;
      if (widget.onNetworkSelected != null) widget.onNetworkSelected!(focusedIndex);
      _isNetworkNavLocked = false;
      return KeyEventResult.handled;
    }

    if (focusedIndex != _networkFocusNodes.indexWhere((n) => n.hasFocus)) {
      _networkFocusNodes[focusedIndex].requestFocus();
      double buttonWidth = _getButtonWidth(widget.networkNames[focusedIndex].toUpperCase());
      _scrollToCenter(_networkScrollController, focusedIndex, buttonWidth, 20);
    }
    _isNetworkNavLocked = false;
    return KeyEventResult.handled;
  }

  KeyEventResult _navigateFilters(LogicalKeyboardKey key) {
    if (_isFilterNavLocked) return KeyEventResult.handled;
    _isFilterNavLocked = true;
    _filterNavLockTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isFilterNavLocked = false);
    });

    int focusedIndex = _filterFocusNodes.indexWhere((n) => n.hasFocus);
    if (focusedIndex == -1) focusedIndex = widget.selectedFilterIndex;

    if (key == LogicalKeyboardKey.arrowLeft) {
      if (focusedIndex > 0)
        focusedIndex--;
      else {
        _searchButtonFocusNode.requestFocus();
        _isFilterNavLocked = false;
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
      _isFilterNavLocked = false;
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
      int target = _lastFocusedItemIndex;
      if (target >= _itemFocusNodes.length) target = _itemFocusNodes.length - 1;
      if (target < 0) target = 0;

      setState(() => _focusedItemIndex = target);
      _itemFocusNodes[target].requestFocus();
      _isFilterNavLocked = false;
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _shouldFocusFirstItem = true;
      widget.onFilterSelected(focusedIndex);
      _isFilterNavLocked = false;
      return KeyEventResult.handled;
    }

    if (focusedIndex != _filterFocusNodes.indexWhere((n) => n.hasFocus)) {
      _filterFocusNodes[focusedIndex].requestFocus();
      double buttonWidth = _getButtonWidth(widget.filterNames[focusedIndex].toUpperCase());
      _scrollToCenter(_filterScrollController, focusedIndex + 1, buttonWidth, 20);
    }
    _isFilterNavLocked = false;
    return KeyEventResult.handled;
  }

  KeyEventResult _navigateItems(LogicalKeyboardKey key) {
    if (_isNavigationLocked) return KeyEventResult.handled;
    _isNavigationLocked = true;
    _navigationLockTimer = Timer(const Duration(milliseconds: 600), () {
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
      widget.onContentTap(_displayList[i], i);
      return KeyEventResult.handled;
    }

    if (i != _focusedItemIndex && i >= 0 && i < _itemFocusNodes.length) {
      setState(() => _focusedItemIndex = i);
      _itemFocusNodes[i].requestFocus();
      
      _scrollToCenter(_itemScrollController, i, _itemFullWidth, _listPadding);
      
      Provider.of<FocusProvider>(context, listen: false)
          .updateName(widget.getTitle(_displayList[i]));
    } else {
      _isNavigationLocked = false;
    }
    return KeyEventResult.handled;
  }



  Widget _buildBrandNameOnly() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF00E5FF), // Bright Cyan
          Color(0xFF2979FF), // Deep Blue
          Color(0xFFD500F9), // Neon Purple
        ],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        widget.title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w900, 
          fontSize: 32, 
          letterSpacing: 6.0,
          color: Colors.white, 
          shadows: [
            Shadow(color: Color(0xFF00E5FF), blurRadius: 12, offset: Offset(0, 0)),
            Shadow(color: Colors.black, blurRadius: 8, offset: Offset(2, 4)),
            Shadow(color: Colors.black87, blurRadius: 20, offset: Offset(0, 10)),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   double headerHeight = 90;
  //   double keyboardAreaHeight = MediaQuery.of(context).size.height * 0.4; 
  //   double filterBarHeight = 45;
  //   double spacing = 10;
    
  //   double sliderAreaHeight = headerHeight + keyboardAreaHeight + filterBarHeight + spacing;

  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     body: Focus(
  //       focusNode: _widgetFocusNode,
  //       autofocus: true,
  //       onKey: _onKeyHandler,
  //       child: Stack(
  //         children: [
  //           // 1. Dynamic Background Slider
  //           Positioned(
  //             top: 0,
  //             left: 0,
  //             right: 0,
  //             height: sliderAreaHeight,
  //             child: _buildBackgroundSlider(),
  //           ),

  //           FadeTransition(
  //             opacity: _fadeAnimation,
  //             child: Column(
  //               children: [
  //                 // HEADER AREA
  //                 SizedBox(
  //                   height: headerHeight, 
  //                   child: Align(
  //                     alignment: Alignment.bottomCenter,
  //                     child: widget.networkNames.isNotEmpty 
  //                         ? _buildTopFilterBar() 
  //                         : _buildBeautifulAppBar(),
  //                   ),
  //                 ),

  //                 // THE KEYBOARD & INDICATORS AREA
  //                 SizedBox(
  //                   height: keyboardAreaHeight,
  //                   child: Stack(
  //                     children: [
  //                       // 1. The Search UI that toggles on and off
  //                       Positioned.fill(
  //                         child: AnimatedSwitcher(
  //                           duration: const Duration(milliseconds: 500),
  //                           switchInCurve: Curves.easeIn,
  //                           switchOutCurve: Curves.easeOut,
  //                           child: _showKeyboard 
  //                               ? _buildSearchUI() 
  //                               : const SizedBox.shrink(),
  //                         ),
  //                       ),
                        
  //                       // 2. 🔥 The Slider Indicators 🔥
  //                       // Permanently aligned to the bottom of the left 40% section (exactly under the input box)
  //                       Align(
  //                         alignment: Alignment.bottomLeft,
  //                         child: Container(
  //                           width: MediaQuery.of(context).size.width * 0.4, // Matches the flex: 4 ratio
  //                           padding: const EdgeInsets.only(bottom: 20),
  //                           child: _buildSliderIndicators(),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
                  
  //                 // FILTER BAR ON SLIDER
  //                 SizedBox(
  //                   height: filterBarHeight,
  //                   child: _buildFilterBar(),
  //                 ),
                  
  //                 // WHITE AREA WITH ENHANCED BLACK SHADOW & STRAIGHT CORNERS
  //                 Expanded(
  //                   child: Container(
  //                     width: double.infinity,
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       // No border radius here for straight edges
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.black.withOpacity(0.8), 
  //                           blurRadius: 30, 
  //                           spreadRadius: 5, 
  //                           offset: const Offset(0, -8), 
  //                         ),
  //                       ],
  //                     ),
  //                     child: Column(
  //                       children: [
  //                         const SizedBox(height: 30), 
  //                         Expanded(child: _buildContentArea()),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
            
  //           if (widget.isLoading && _displayList.isEmpty && widget.filterNames.isEmpty)
  //             Container(
  //               color: ProfessionalColors.primaryDark,
  //               child: const Center(child: CircularProgressIndicator(color: Colors.white)),
  //             ),
  //           if (widget.isVideoLoading && widget.errorMessage == null)
  //             Positioned.fill(
  //                 child: Container(
  //                     color: Colors.black87,
  //                     child: const Center(child: CircularProgressIndicator(color: Colors.white)))),
  //         ],
  //       ),
  //     ),
  //   );
  // }



@override
  Widget build(BuildContext context) {
    bool hasNetworks = widget.networkNames.isNotEmpty;

    // --- DYNAMIC HEIGHT CALCULATIONS ---
    double topSectionHeight = hasNetworks ? 90.0 : 90.0; 
    double keyboardAreaHeight = MediaQuery.of(context).size.height * 0.4; 
    double filterBarHeight = 45.0;
    double spacing = 10.0;
    
    double sliderAreaHeight = topSectionHeight + keyboardAreaHeight + filterBarHeight + spacing;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Focus(
        focusNode: _widgetFocusNode,
        autofocus: true,
        onKey: _onKeyHandler,
        child: Stack(
          children: [
            // 1. Dynamic Background Slider
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: sliderAreaHeight,
              child: _buildBackgroundSlider(),
            ),

            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. TOPMOST LAYER ---
                  SizedBox(
                    height: topSectionHeight, 
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: hasNetworks 
                          ? _buildTopFilterBar() 
                          : _buildBeautifulAppBar(),
                    ),
                  ),

                  // // --- 2. THE KEYBOARD & INDICATORS AREA ---
                  // SizedBox(
                  //   height: keyboardAreaHeight,
                  //   child: Stack(
                  //     children: [
                  //       // Search UI
                  //       Positioned.fill(
                  //         child: AnimatedSwitcher(
                  //           duration: const Duration(milliseconds: 500),
                  //           switchInCurve: Curves.easeIn,
                  //           switchOutCurve: Curves.easeOut,
                  //           child: _showKeyboard 
                  //               ? _buildSearchUI() 
                  //               : const SizedBox.shrink(),
                  //         ),
                  //       ),
                        
                  //       // The Slider Indicators
                  //       Align(
                  //         alignment: Alignment.bottomLeft,
                  //         child: Container(
                  //           width: MediaQuery.of(context).size.width * 0.4, 
                  //           padding: const EdgeInsets.only(bottom: 20),
                  //           child: _buildSliderIndicators(),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),



                  // --- 2. THE KEYBOARD & INDICATORS AREA ---
                  SizedBox(
                    height: keyboardAreaHeight,
                    child: Stack(
                      children: [
                        // Search UI & Permanent Title
                        Positioned.fill(
                          child: _buildSearchUI(), // <--- Always call this now
                        ),
                        
                        // The Slider Indicators
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4, 
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildSliderIndicators(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // --- 3. FILTER BAR ON SLIDER ---
                  SizedBox(
                    height: filterBarHeight,
                    child: _buildFilterBar(),
                  ),
                  
                  // --- 4. WHITE AREA WITH ENHANCED BLACK SHADOW ---
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8), 
                            blurRadius: 30, 
                            spreadRadius: 5, 
                            offset: const Offset(0, -8), 
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 30), 
                          _buildContentArea(),
                        ],
                      ),
                    ),
                  ),


                  // // --- 4. WHITE AREA WITH ENHANCED BLACK SHADOW ---
                  // Expanded(
                  //   child: Container(
                  //     width: double.infinity,
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withOpacity(0.8), 
                  //           blurRadius: 30, 
                  //           spreadRadius: 5, 
                  //           offset: const Offset(0, -8), 
                  //         ),
                  //       ],
                  //     ),
                  //     // ADDED CustomPaint HERE to draw the background grid
                  //     child: CustomPaint(
                  //       painter: GridPainter(),
                  //       child: Column(
                  //         children: [
                  //           const SizedBox(height: 30), 
                  //           _buildContentArea(),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            
            // Loading Overlays
            if (widget.isLoading && _displayList.isEmpty && widget.filterNames.isEmpty)
              Container(
                color: ProfessionalColors.primaryDark,
                child: const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            if (widget.isVideoLoading && widget.errorMessage == null)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: const Center(child: CircularProgressIndicator(color: Colors.white))
                )
              ),
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
          child: Center(child: CircularProgressIndicator(color: Colors.blue)));
    }
    return _buildContentList();
  }

  // Widget _buildBeautifulAppBar() {
  //   final focusName = context.watch<FocusProvider>().focusedItemName;
    
  //   return Container(
  //     padding: const EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 10),
  //     child: Row(
  //       children: [
  //         ShaderMask(
  //           shaderCallback: (bounds) => const LinearGradient(
  //             colors: [Color(0xFF00E5FF), Color(0xFF7000FF)],
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //           ).createShader(bounds),
  //           child: Text(
  //             widget.title.toUpperCase(),
  //             style: const TextStyle(
  //               fontWeight: FontWeight.w900, 
  //               fontSize: 30,
  //               letterSpacing: 1.5,
  //               color: Colors.white,
  //               shadows: [
  //                 Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(2, 2)),
  //               ],
  //             ),
  //           ),
  //         ),
          
  //         Container(
  //           height: 24,
  //           width: 3,
  //           margin: const EdgeInsets.symmetric(horizontal: 20),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF00E5FF), 
  //             borderRadius: BorderRadius.circular(10),
  //             boxShadow: const [
  //               BoxShadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
  //             ],
  //           ),
  //         ),
          
  //         Expanded(
  //           child: AnimatedSwitcher(
  //             duration: const Duration(milliseconds: 300),
  //             switchInCurve: Curves.easeOutCubic,
  //             switchOutCurve: Curves.easeInCubic,
  //             transitionBuilder: (Widget child, Animation<double> animation) {
  //               return FadeTransition(
  //                 opacity: animation,
  //                 child: SlideTransition(
  //                   position: Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(animation),
  //                   child: child,
  //                 ),
  //               );
  //             },
  //             child: Text(
  //               focusName,
  //               key: ValueKey<String>(focusName), 
  //               style: const TextStyle(
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.w600,
  //                 fontSize: 22,
  //                 letterSpacing: 0.5,
  //                 shadows: [
  //                   Shadow(color: Colors.black, blurRadius: 8, offset: Offset(2, 2)),
  //                 ],
  //               ),
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

Widget _buildBeautifulAppBar() {
    final focusName = context.watch<FocusProvider>().focusedItemName;
    final String displayText = focusName.isEmpty ? "" : focusName;
    
    return Container(
      margin: const EdgeInsets.only(left: 50, right: 50, top: 30, bottom: 10),
      height: screenhgt * 0.1, 
      color: Colors.transparent,
      // color: Colors.black26 ,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Premium App Logo with Cyan Glow
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.8),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: widget.logoUrl.isNotEmpty 
                  ? CachedNetworkImage(
                      imageUrl: widget.logoUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => _fallbackLogoIcon(),
                    )
                  : _fallbackLogoIcon(),
            ),
          ),
          const SizedBox(width: 25),

          // 2. Cinematic Brand Name Text
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFF00E5FF), // Bright Cyan
                Color(0xFF2979FF), // Deep Blue
                Color(0xFFD500F9), // Neon Purple
              ],
              stops: [0.0, 0.5, 1.0], // 3-step gradient for a metallic look
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              widget.title.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w900, 
                fontSize: 32, // Increased size
                letterSpacing: 6.0, // Wider, cinematic spacing
                color: Colors.white, 
                shadows: [
                  // Neon aura glow
                  Shadow(color: Color(0xFF00E5FF), blurRadius: 12, offset: Offset(0, 0)),
                  // 3D Depth drop shadows
                  Shadow(color: Colors.black, blurRadius: 8, offset: Offset(2, 4)),
                  Shadow(color: Colors.black87, blurRadius: 20, offset: Offset(0, 10)),
                ],
              ),
            ),
          ),
          
          // 3. Sleek Glowing Separator
          Container(
            height: 35,
            width: 3,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          
          // 4. Ultra-Crisp Dynamic Content Title
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0.0), 
                      end: Offset.zero
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: 
              // Container(
              //   key: ValueKey<String>(displayText),
              //   alignment: Alignment.centerLeft,
              //   child: ShaderMask(
              //     shaderCallback: (bounds) => const LinearGradient(
              //       colors: [
              //         Color(0xFF00B0FF), // Bright light blue
              //         Color.fromARGB(255, 208, 4, 235), 
              //         Color.fromARGB(255, 212, 101, 10), // Very light cyan
              //       ],
              //       stops: [0.0, 0.6, 1.0],
              //       begin: Alignment.topLeft ,
              //       end: Alignment.bottomRight,
              //     ).createShader(bounds),
              //     child: Text(
              //       displayText,
              //       style: const TextStyle(
              //         color: Colors.white,
              //         fontWeight: FontWeight.w700, // Increased weight for sharpness
              //         fontSize: 22, // Increased size
              //         letterSpacing: 1.5,
              //         shadows: [
              //           // Soft icy glow
              //           Shadow(color: Color(0xFF00B0FF), blurRadius: 15, offset: Offset(0, 0)),
              //           // Hard black drop shadow to contrast against the slider image
              //           Shadow(color: Colors.black, blurRadius: 10, offset: Offset(2, 4)),
              //         ],
              //       ),
              //       maxLines: 1,
              //       overflow: TextOverflow.ellipsis,
              //     ),
              //   ),
              // ),

              // 4. Ultra-Crisp Dynamic Content Title

     Container(
      key: ValueKey<String>(displayText),
      alignment: Alignment.centerLeft,
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [
            Color(0xFF00B0FF), // Bright light blue
            Color.fromARGB(255, 208, 4, 235), 
            Color.fromARGB(255, 212, 101, 10), // Very light cyan
          ],
          stops: [0.0, 0.6, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Text(
          displayText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 1.5,
            // YAHAN SE SHADOWS REMOVE KAR DI GAYI HAIN
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  ),

            
          ),
        ],
      ),
    );
  }

  Widget _fallbackLogoIcon() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 35),
    );
  }

  // Widget _fallbackLogoIcon() {
  //   return Container(
  //     decoration: const BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [Color(0xFF00E5FF), Color(0xFF7000FF)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //     ),
  //     child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 35),
  //   );
  // }

  // // Helper widget in case the logoURL is empty or fails to load
  // Widget _fallbackLogoIcon() {
  //   return Container(
  //     decoration: const BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [Color(0xFF00E5FF), Color(0xFF7000FF)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //     ),
  //     child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 35),
  //   );
  // }

  Widget _buildTopFilterBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
              top: 20, bottom: 5, left: MediaQuery.of(context).size.width * 0.03),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1))),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    controller: _networkScrollController,
                    scrollDirection: Axis.horizontal,
                    cacheExtent: 5000,
                    itemCount: widget.networkNames.length,
                    itemBuilder: (ctx, i) {
                      if (i >= _networkFocusNodes.length) return const SizedBox.shrink();
                      bool isSelected = widget.selectedNetworkIndex == i;
                      double buttonWidth = _getButtonWidth(widget.networkNames[i].toUpperCase());
                      
                      return Focus(
                        focusNode: _networkFocusNodes[i],
                        onFocusChange: (has) {
                          if (has && !_isDisposed) {
                            _scrollToCenter(_networkScrollController, i, buttonWidth, 20);
                          }
                        },
                        child: _buildGlassButton(
                          focusNode: _networkFocusNodes[i],
                          isSelected: isSelected,
                          color: widget.focusColors[i % widget.focusColors.length],
                          label: widget.networkNames[i].toUpperCase(),
                          customWidth: buttonWidth,
                          onTap: () {
                            _shouldFocusFirstItem = true;
                            if (widget.onNetworkSelected != null) widget.onNetworkSelected!(i);
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
    if (widget.filterNames.isEmpty && !_isSearching) return const SizedBox(height: 30);

    List<String> prioritizedList = List.from(widget.filterNames);
    if (prioritizedList.contains("Web Series")) {
      prioritizedList.remove("Web Series");
      prioritizedList.insert(0, "Web Series");
    }
    if (prioritizedList.contains("Latest")) {
      prioritizedList.remove("Latest");
      int targetIdx = prioritizedList.contains("Web Series") ? 1 : 0;
      prioritizedList.insert(targetIdx, "Latest");
    }

    return SizedBox(
      height: 35,
      child: ListView.builder(
        controller: _filterScrollController,
        scrollDirection: Axis.horizontal,
        cacheExtent: 5000,
        itemCount: prioritizedList.length + 1,
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
        itemBuilder: (ctx, i) {
          if (i == 0) {
            double searchButtonWidth = _getButtonWidth("SEARCH", icon: Icons.search);
            return Focus(
              focusNode: _searchButtonFocusNode,
              onFocusChange: (has) {
                if (has && !_isDisposed) {
                  Provider.of<FocusProvider>(context, listen: false).updateName("SEARCH");
                  _scrollToCenter(_filterScrollController, 0, searchButtonWidth, 20);
                }
              },
              child: _buildGlassButton(
                focusNode: _searchButtonFocusNode,
                isSelected: _isSearching || _showKeyboard,
                color: ProfessionalColors.accentOrange,
                label: "SEARCH",
                icon: Icons.search,
                customWidth: searchButtonWidth,
                onTap: () => setState(() {
                  _showKeyboard = true;
                  _searchButtonFocusNode.requestFocus();
                }),
              ),
            );
          }

          int currentIdx = i - 1; 
          String labelText = prioritizedList[currentIdx];
          int originalFilterIdx = widget.filterNames.indexOf(labelText);
          
          if (originalFilterIdx < 0 || originalFilterIdx >= _filterFocusNodes.length) {
            return const SizedBox.shrink();
          }

          FocusNode correctNode = _filterFocusNodes[originalFilterIdx];
          double buttonWidth = _getButtonWidth(labelText.toUpperCase());

          return Focus(
            focusNode: correctNode,
            onKey: (node, event) {
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  if (i < prioritizedList.length) {
                    String nextLabel = prioritizedList[currentIdx + 1];
                    int nextOriginalIdx = widget.filterNames.indexOf(nextLabel);
                    _filterFocusNodes[nextOriginalIdx].requestFocus();
                    return KeyEventResult.handled;
                  }
                } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  if (i == 1) {
                    _searchButtonFocusNode.requestFocus();
                    return KeyEventResult.handled;
                  } else {
                    String prevLabel = prioritizedList[currentIdx - 1];
                    int prevOriginalIdx = widget.filterNames.indexOf(prevLabel);
                    _filterFocusNodes[prevOriginalIdx].requestFocus();
                    return KeyEventResult.handled;
                  }
                }
              }
              return KeyEventResult.ignored;
            },
            onFocusChange: (has) {
              if (has && !_isDisposed) {
                _scrollToCenter(_filterScrollController, i, buttonWidth, 20);
              }
            },
            child: _buildGlassButton(
              focusNode: correctNode,
              isSelected: !_isSearching && widget.selectedFilterIndex == originalFilterIdx,
              color: widget.focusColors[originalFilterIdx % widget.focusColors.length],
              label: labelText.toUpperCase(),
              customWidth: buttonWidth,
              onTap: () {
                _shouldFocusFirstItem = true;
                widget.onFilterSelected(originalFilterIdx);
              },
            ),
          );
        },
      ),
    );
  }

  // Widget _buildContentList() {
  //   if (_displayList.isEmpty) {
  //     return Expanded(
  //         child: Center(
  //             child: Text(widget.emptyMessage,
  //                 style: const TextStyle(color: Colors.black54, fontSize: 18))));
  //   }
    
  //   return Expanded(
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.35), 
  //             blurRadius: 20, 
  //             spreadRadius: 5, 
  //             offset: const Offset(0, 5), 
  //           ),
  //         ],
  //       ),
  //       child: FocusedOverlayList(
  //         controller: _itemScrollController,
  //         scrollDirection: Axis.horizontal,
  //         padding: EdgeInsets.symmetric(horizontal: _listPadding), 
  //         itemCount: _displayList.length,
  //         overlayAlignment: Alignment.topLeft,
  //         focusedIndex: _focusedItemIndex,
  //         itemExtent: _itemFullWidth, 
          
  //         itemBuilder: (ctx, i) {
  //           if (i >= _itemFocusNodes.length) return const SizedBox.shrink();
  //           final item = _displayList[i];
            
  //           return _MasterSliderCard<T>(
  //             item: item,
  //             focusNode: _itemFocusNodes[i],
  //             isFocused: false, 
  //             focusColor: widget.focusColors[i % widget.focusColors.length],
  //             onTap: () => widget.onContentTap(item, i),
  //             onFocusChange: (has) {
  //               if (has && !_isDisposed) {
  //                 if (_focusedItemIndex != i) {
  //                   setState(() => _focusedItemIndex = i);
                    
  //                   _scrollToCenter(_itemScrollController, i, _itemFullWidth, _listPadding);
                    
  //                   Provider.of<FocusProvider>(context, listen: false)
  //                       .updateName(widget.getTitle(item));
  //                 }
  //               }
  //             },
  //             getTitle: widget.getTitle,
  //             getImageUrl: widget.getImageUrl,
  //             cardWidth: widget.cardWidth,
  //             cardHeight: widget.cardHeight,
  //             placeholderIcon: widget.placeholderIcon,
  //             logoUrl: widget.logoUrl,
  //             dynamicSpacing: _dynamicSpacing,
  //             dynamicScale: _dynamicScale,
  //           );
  //         },

  //         focusedPlaceholderBuilder: (ctx, i) {
  //           if (i < 0 || i >= _displayList.length) return const SizedBox.shrink();
  //           final item = _displayList[i];
            
  //           return _MasterSliderCard<T>(
  //             item: item,
  //             focusNode: _itemFocusNodes[i], // REAL NODE
  //             isFocused: false, 
  //             focusColor: widget.focusColors[i % widget.focusColors.length],
  //             onTap: () => widget.onContentTap(item, i),
  //             onFocusChange: (has) {
  //               if (has && !_isDisposed) {
  //                 if (_focusedItemIndex != i) {
  //                   setState(() => _focusedItemIndex = i);
  //                   _scrollToCenter(_itemScrollController, i, _itemFullWidth, _listPadding);
  //                   Provider.of<FocusProvider>(context, listen: false)
  //                       .updateName(widget.getTitle(item));
  //                 }
  //               }
  //             },
  //             getTitle: widget.getTitle,
  //             getImageUrl: widget.getImageUrl,
  //             cardWidth: widget.cardWidth,
  //             cardHeight: widget.cardHeight,
  //             placeholderIcon: widget.placeholderIcon,
  //             logoUrl: widget.logoUrl,
  //             dynamicSpacing: _dynamicSpacing,
  //             dynamicScale: _dynamicScale,
  //           );
  //         },
          
  //         focusedItemBuilder: (ctx, i) {
  //           if (i < 0 || i >= _displayList.length) return const SizedBox.shrink();
  //           final item = _displayList[i];
            
  //           return _MasterSliderCard<T>(
  //             item: item,
  //             focusNode: FocusNode(), 
  //             isFocused: true, 
  //             focusColor: widget.focusColors[i % widget.focusColors.length],
  //             onTap: () => widget.onContentTap(item, i),
  //             onFocusChange: (_) {},
  //             getTitle: widget.getTitle,
  //             getImageUrl: widget.getImageUrl,
  //             cardWidth: widget.cardWidth,
  //             cardHeight: widget.cardHeight,
  //             placeholderIcon: widget.placeholderIcon,
  //             logoUrl: widget.logoUrl,
  //             dynamicSpacing: _dynamicSpacing,
  //             dynamicScale: _dynamicScale,
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

// Widget _buildContentList() {
//     if (_displayList.isEmpty) {
//       return Expanded(
//           child: Center(
//               child: Text(widget.emptyMessage,
//                   style: const TextStyle(color: Colors.black54, fontSize: 18))));
//     }
    
//     return Expanded(
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.35), 
//               blurRadius: 20, 
//               spreadRadius: 5, 
//               offset: const Offset(0, 5), 
//             ),
//           ],
//         ),
//         child: FocusedOverlayList(
//           controller: _itemScrollController,
//           scrollDirection: Axis.horizontal,
//           padding: EdgeInsets.symmetric(horizontal: _listPadding), 
//           itemCount: _displayList.length,
//           overlayAlignment: Alignment.topLeft,
//           focusedIndex: _focusedItemIndex,
//           itemExtent: _itemFullWidth, 
          
//           itemBuilder: (ctx, i) {
//             if (i >= _itemFocusNodes.length) return const SizedBox.shrink();
//             final item = _displayList[i];
            
//             return _MasterSliderCard<T>(
//               // ✅ FIX: Added a unique Key for the normal item
//               key: ValueKey<String>('normal_${item.hashCode}_$i'),
//               item: item,
//               focusNode: _itemFocusNodes[i],
//               isFocused: false, 
//               focusColor: widget.focusColors[i % widget.focusColors.length],
//               onTap: () => widget.onContentTap(item, i),
//               onFocusChange: (has) {
//                 if (has && !_isDisposed) {
//                   if (_focusedItemIndex != i) {
//                     setState(() => _focusedItemIndex = i);
                    
//                     _scrollToCenter(_itemScrollController, i, _itemFullWidth, _listPadding);
                    
//                     Provider.of<FocusProvider>(context, listen: false)
//                         .updateName(widget.getTitle(item));
//                   }
//                 }
//               },
//               getTitle: widget.getTitle,
//               getImageUrl: widget.getImageUrl,
//               cardWidth: widget.cardWidth,
//               cardHeight: widget.cardHeight,
//               placeholderIcon: widget.placeholderIcon,
//               logoUrl: widget.logoUrl,
//               dynamicSpacing: _dynamicSpacing,
//               dynamicScale: _dynamicScale,
//             );
//           },

//           focusedPlaceholderBuilder: (ctx, i) {
//             if (i < 0 || i >= _displayList.length) return const SizedBox.shrink();
//             final item = _displayList[i];
            
//             return _MasterSliderCard<T>(
//               // ✅ FIX: Added a unique Key for the placeholder item
//               key: ValueKey<String>('placeholder_${item.hashCode}_$i'),
//               item: item,
//               focusNode: _itemFocusNodes[i], 
//               isFocused: false, 
//               focusColor: widget.focusColors[i % widget.focusColors.length],
//               onTap: () => widget.onContentTap(item, i),
//               onFocusChange: (has) {
//                 if (has && !_isDisposed) {
//                   if (_focusedItemIndex != i) {
//                     setState(() => _focusedItemIndex = i);
//                     _scrollToCenter(_itemScrollController, i, _itemFullWidth, _listPadding);
//                     Provider.of<FocusProvider>(context, listen: false)
//                         .updateName(widget.getTitle(item));
//                   }
//                 }
//               },
//               getTitle: widget.getTitle,
//               getImageUrl: widget.getImageUrl,
//               cardWidth: widget.cardWidth,
//               cardHeight: widget.cardHeight,
//               placeholderIcon: widget.placeholderIcon,
//               logoUrl: widget.logoUrl,
//               dynamicSpacing: _dynamicSpacing,
//               dynamicScale: _dynamicScale,
//             );
//           },
          
//           focusedItemBuilder: (ctx, i) {
//             if (i < 0 || i >= _displayList.length) return const SizedBox.shrink();
//             final item = _displayList[i];
            
//             return _MasterSliderCard<T>(
//               // ✅ FIX: Added a unique Key for the active overlay item
//               key: ValueKey<String>('focused_${item.hashCode}_$i'),
//               item: item,
//               focusNode: FocusNode(), 
//               isFocused: true, 
//               focusColor: widget.focusColors[i % widget.focusColors.length],
//               onTap: () => widget.onContentTap(item, i),
//               onFocusChange: (_) {},
//               getTitle: widget.getTitle,
//               getImageUrl: widget.getImageUrl,
//               cardWidth: widget.cardWidth,
//               cardHeight: widget.cardHeight,
//               placeholderIcon: widget.placeholderIcon,
//               logoUrl: widget.logoUrl,
//               dynamicSpacing: _dynamicSpacing,
//               dynamicScale: _dynamicScale,
//             );
//           },
//         ),
//       ),
//     );
//   }



Widget _buildContentList() {
    if (_displayList.isEmpty) {
      return Expanded(
          child: Center(
              child: Text(widget.emptyMessage,
                  style: const TextStyle(color: Colors.black54, fontSize: 18))));
    }
    
    return Expanded(
      // 🔥 REMOVED the extra Container and BoxDecoration here to fix the double shadow/extra line
      child: FocusedOverlayList(
        controller: _itemScrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: _listPadding), 
        itemCount: _displayList.length,
        overlayAlignment: Alignment.topLeft,
        focusedIndex: _focusedItemIndex,
        itemExtent: _itemFullWidth, 
        
        itemBuilder: (ctx, i) {
          if (i >= _itemFocusNodes.length) return const SizedBox.shrink();
          final item = _displayList[i];
          
          return _MasterSliderCard<T>(
            key: ValueKey<String>('normal_${item.hashCode}_$i'),
            item: item,
            focusNode: _itemFocusNodes[i],
            isFocused: false, 
            focusColor: widget.focusColors[i % widget.focusColors.length],
            onTap: () => widget.onContentTap(item, i),
            onFocusChange: (has) {
              if (has && !_isDisposed) {
                if (_focusedItemIndex != i) {
                  setState(() => _focusedItemIndex = i);
                  _scrollToCenter(_itemScrollController, i, _itemFullWidth, _listPadding);
                  Provider.of<FocusProvider>(context, listen: false)
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
            dynamicSpacing: _dynamicSpacing,
            dynamicScale: _dynamicScale,
          );
        },

        focusedPlaceholderBuilder: (ctx, i) {
          if (i < 0 || i >= _displayList.length) return const SizedBox.shrink();
          final item = _displayList[i];
          
          return _MasterSliderCard<T>(
            key: ValueKey<String>('placeholder_${item.hashCode}_$i'),
            item: item,
            focusNode: _itemFocusNodes[i], 
            isFocused: false, 
            focusColor: widget.focusColors[i % widget.focusColors.length],
            onTap: () => widget.onContentTap(item, i),
            onFocusChange: (has) {
              if (has && !_isDisposed) {
                if (_focusedItemIndex != i) {
                  setState(() => _focusedItemIndex = i);
                  _scrollToCenter(_itemScrollController, i, _itemFullWidth, _listPadding);
                  Provider.of<FocusProvider>(context, listen: false)
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
            dynamicSpacing: _dynamicSpacing,
            dynamicScale: _dynamicScale,
          );
        },
        
        focusedItemBuilder: (ctx, i) {
          if (i < 0 || i >= _displayList.length) return const SizedBox.shrink();
          final item = _displayList[i];
          
          return _MasterSliderCard<T>(
            key: ValueKey<String>('focused_${item.hashCode}_$i'),
            item: item,
            focusNode: FocusNode(), 
            isFocused: true, 
            focusColor: widget.focusColors[i % widget.focusColors.length],
            onTap: () => widget.onContentTap(item, i),
            onFocusChange: (_) {},
            getTitle: widget.getTitle,
            getImageUrl: widget.getImageUrl,
            cardWidth: widget.cardWidth,
            cardHeight: widget.cardHeight,
            placeholderIcon: widget.placeholderIcon,
            logoUrl: widget.logoUrl,
            dynamicSpacing: _dynamicSpacing,
            dynamicScale: _dynamicScale,
          );
        },
      ),
    );
  }

  Widget _buildGlassButton({
    required FocusNode focusNode,
    required bool isSelected,
    required Color color,
    required String label,
    IconData? icon,
    required VoidCallback onTap,
    double? customWidth,
  }) {
    bool hasFocus = focusNode.hasFocus;
    double buttonWidth = customWidth ?? _getButtonWidth(label, icon: icon);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonWidth,
        margin: const EdgeInsets.only(right: 12),
        child: AnimatedBuilder(
          animation: _borderAnimationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
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
                          color: hasFocus ? color : isSelected ? color.withOpacity(0.5) : Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(30),
                          border: !hasFocus ? Border.all(color: Colors.white.withOpacity(0.5), width: 1.5) : null,
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

  // Widget _buildSearchUI() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         flex: 4,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             const Text("SEARCH",
  //                 style: TextStyle(
  //                     fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
  //             const SizedBox(height: 20),
  //             Container(
  //               margin: const EdgeInsets.symmetric(horizontal: 40),
  //               padding: const EdgeInsets.all(16),
  //               decoration: BoxDecoration(
  //                   color: Colors.white10,
  //                   borderRadius: BorderRadius.circular(10),
  //                   border: Border.all(color: ProfessionalColors.accentPurple)),
  //               child: Text(_searchText.isEmpty ? 'Typing...' : _searchText,
  //                   style: const TextStyle(color: Colors.white, fontSize: 22)),
  //             ),
  //           ],
  //         ),
  //       ),
  //       Expanded(
  //         flex: 6,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: _keyboardLayout.asMap().entries.map((r) => Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: r.value.asMap().entries.map((c) {
  //                   int idx = _keyboardLayout
  //                           .take(r.key)
  //                           .fold(0, (p, e) => p + e.length) +
  //                       c.key;
  //                   if (idx >= _keyboardFocusNodes.length)
  //                     return const SizedBox.shrink();
  //                   bool isFocused = _focusedKeyRow == r.key && _focusedKeyCol == c.key;
  //                   String key = c.value;
  //                   double w = key == 'SPACE'
  //                       ? 150
  //                       : (key == 'OK' || key == 'DEL' ? 70 : 40);
  //                   return Container(
  //                     width: w,
  //                     height: 35,
  //                     margin: const EdgeInsets.all(2),
  //                     child: Focus(
  //                       focusNode: _keyboardFocusNodes[idx],
  //                       onFocusChange: (has) {
  //                         if (has)
  //                           setState(() {
  //                             _focusedKeyRow = r.key;
  //                             _focusedKeyCol = c.key;
  //                           });
  //                       },
  //                       child: ElevatedButton(
  //                         onPressed: () => _handleKeyClick(key),
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: isFocused
  //                               ? ProfessionalColors.accentPurple
  //                               : Colors.white10,
  //                           shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(8),
  //                               side: isFocused
  //                                   ? const BorderSide(color: Colors.white, width: 2)
  //                                   : BorderSide.none),
  //                           padding: EdgeInsets.zero,
  //                         ),
  //                         child: Text(key,
  //                             style: const TextStyle(color: Colors.white, fontSize: 18)),
  //                       ),
  //                     ),
  //                   );
  //                 }).toList(),
  //               )).toList(),
  //         ),
  //       )
  //     ],
  //   );
  // }


// Widget _buildSearchUI() {
//     // Fetch the currently focused item name
//     final focusName = context.watch<FocusProvider>().focusedItemName;
//     final String displayText = focusName.isEmpty ? "Search" : focusName;

//     return Row(
//       children: [
//         // LEFT SIDE: Focused Name and Search Input
//         Expanded(
//           flex: 4,
//           child: Padding(
//             padding: const EdgeInsets.only(left: 40, right: 20), // Adjusted for better TV alignment
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start, // Align text and box to the left
//               children: [
//                 // 1. Focused Image Name (Right above the search box)
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 300),
//                   child: ShaderMask(
//                     key: ValueKey<String>(displayText),
//                     shaderCallback: (bounds) => const LinearGradient(
//                       colors: [Colors.white, Color(0xFF00E5FF)],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ).createShader(bounds),
//                     child: Text(
//                       displayText,
//                       style: const TextStyle(
//                         fontSize: 24, 
//                         fontWeight: FontWeight.w800, 
//                         color: Colors.white,
//                         letterSpacing: 1.2,
//                         shadows: [
//                           Shadow(color: Color(0xFF00B0FF), blurRadius: 10, offset: Offset(0, 0)),
//                           Shadow(color: Colors.black, blurRadius: 5, offset: Offset(1, 2)),
//                         ]
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 12), // Space between title and input box
                
//                 // 2. Wide, Slim Search Input Box
//                 Container(
//                   width: double.infinity, // Stretches to fill available space
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
//                   decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.6), // Slightly darker for better contrast
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: ProfessionalColors.accentPurple, width: 1.5),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.5),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         )
//                       ]
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.search, color: Colors.white70, size: 20),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           _searchText.isEmpty ? 'Type to search...' : _searchText,
//                           style: TextStyle(
//                             color: _searchText.isEmpty ? Colors.white54 : Colors.white, 
//                             fontSize: 18, 
//                             fontWeight: FontWeight.w500
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       // Optional: Show a blinking cursor effect when empty
//                       if (_searchText.isEmpty)
//                         Container(
//                           width: 2,
//                           height: 18,
//                           color: Colors.white70,
//                         )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
        
//         // RIGHT SIDE: The Keyboard 
//         Expanded(
//           flex: 6,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: _keyboardLayout.asMap().entries.map((r) => Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: r.value.asMap().entries.map((c) {
//                   int idx = _keyboardLayout
//                           .take(r.key)
//                           .fold(0, (p, e) => p + e.length) +
//                       c.key;
//                   if (idx >= _keyboardFocusNodes.length) {
//                     return const SizedBox.shrink();
//                   }
//                   bool isFocused = _focusedKeyRow == r.key && _focusedKeyCol == c.key;
//                   String key = c.value;
//                   double w = key == 'SPACE'
//                       ? 150
//                       : (key == 'OK' || key == 'DEL' ? 70 : 40);
//                   return Container(
//                     width: w,
//                     height: 35, 
//                     margin: const EdgeInsets.all(2),
//                     child: Focus(
//                       focusNode: _keyboardFocusNodes[idx],
//                       onFocusChange: (has) {
//                         if (has) {
//                           setState(() {
//                             _focusedKeyRow = r.key;
//                             _focusedKeyCol = c.key;
//                           });
//                         }
//                       },
//                       child: ElevatedButton(
//                         onPressed: () => _handleKeyClick(key),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: isFocused
//                               ? ProfessionalColors.accentPurple
//                               : Colors.white10,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(6),
//                               side: isFocused
//                                   ? const BorderSide(color: Colors.white, width: 2)
//                                   : BorderSide.none),
//                           padding: EdgeInsets.zero,
//                         ),
//                         child: Text(key,
//                             style: const TextStyle(color: Colors.white, fontSize: 16)),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               )).toList(),
//           ),
//         )
//       ],
//     );
//   }


// Widget _buildSearchUI() {
//     // Fetch the currently focused item name
//     final focusName = context.watch<FocusProvider>().focusedItemName;
//     final String displayText = focusName.isEmpty ? "Search" : focusName;

//     return Row(
//       children: [
//         // LEFT SIDE: Focused Name and Search Input
//         Expanded(
//           flex: 4,
//           child: Padding(
//             padding: const EdgeInsets.only(left: 40, right: 20), // Adjusted for better TV alignment
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start, // Align text and box to the left
//               children: [
//                 // 1. Focused Image Name (ALWAYS VISIBLE)
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 300),
//                   child: ShaderMask(
//                     key: ValueKey<String>(displayText),
//                     shaderCallback: (bounds) => const LinearGradient(
//                       colors: [Colors.white, Color(0xFF00E5FF)],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ).createShader(bounds),
//                     child: Text(
//                       displayText,
//                       style: const TextStyle(
//                         fontSize: 24, 
//                         fontWeight: FontWeight.w800, 
//                         color: Colors.white,
//                         letterSpacing: 1.2,
//                         shadows: [
//                           Shadow(color: Color(0xFF00B0FF), blurRadius: 10, offset: Offset(0, 0)),
//                           Shadow(color: Colors.black, blurRadius: 5, offset: Offset(1, 2)),
//                         ]
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
                
//                 // Animate the space and input box out when keyboard is hidden
//                 AnimatedSize(
//                   duration: const Duration(milliseconds: 400),
//                   curve: Curves.easeInOut,
//                   child: _showKeyboard 
//                     ? Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 12), // Space between title and input box
//                           // 2. Wide, Slim Search Input Box
//                           Container(
//                             width: double.infinity, // Stretches to fill available space
//                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
//                             decoration: BoxDecoration(
//                                 color: Colors.black.withOpacity(0.6), // Slightly darker for better contrast
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(color: ProfessionalColors.accentPurple, width: 1.5),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.5),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 4),
//                                   )
//                                 ]
//                             ),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.search, color: Colors.white70, size: 20),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                   child: Text(
//                                     _searchText.isEmpty ? 'Type to search...' : _searchText,
//                                     style: TextStyle(
//                                       color: _searchText.isEmpty ? Colors.white54 : Colors.white, 
//                                       fontSize: 18, 
//                                       fontWeight: FontWeight.w500
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 // Optional: Show a blinking cursor effect when empty
//                                 if (_searchText.isEmpty)
//                                   Container(
//                                     width: 2,
//                                     height: 18,
//                                     color: Colors.white70,
//                                   )
//                               ],
//                             ),
//                           ),
//                         ],
//                       )
//                     : const SizedBox(width: double.infinity, height: 0),
//                 ),
//               ],
//             ),
//           ),
//         ),
        
//         // RIGHT SIDE: The Keyboard (ANIMATED IN AND OUT)
//         Expanded(
//           flex: 6,
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 400),
//             child: _showKeyboard
//                 ? Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: _keyboardLayout.asMap().entries.map((r) => Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: r.value.asMap().entries.map((c) {
//                           int idx = _keyboardLayout
//                                   .take(r.key)
//                                   .fold(0, (p, e) => p + e.length) +
//                               c.key;
//                           if (idx >= _keyboardFocusNodes.length) {
//                             return const SizedBox.shrink();
//                           }
//                           bool isFocused = _focusedKeyRow == r.key && _focusedKeyCol == c.key;
//                           String key = c.value;
//                           double w = key == 'SPACE'
//                               ? 150
//                               : (key == 'OK' || key == 'DEL' ? 70 : 40);
//                           return Container(
//                             width: w,
//                             height: 35, 
//                             margin: const EdgeInsets.all(2),
//                             child: Focus(
//                               focusNode: _keyboardFocusNodes[idx],
//                               onFocusChange: (has) {
//                                 if (has) {
//                                   setState(() {
//                                     _focusedKeyRow = r.key;
//                                     _focusedKeyCol = c.key;
//                                   });
//                                 }
//                               },
//                               child: ElevatedButton(
//                                 onPressed: () => _handleKeyClick(key),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: isFocused
//                                       ? ProfessionalColors.accentPurple
//                                       : Colors.white10,
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(6),
//                                       side: isFocused
//                                           ? const BorderSide(color: Colors.white, width: 2)
//                                           : BorderSide.none),
//                                   padding: EdgeInsets.zero,
//                                 ),
//                                 child: Text(key,
//                                     style: const TextStyle(color: Colors.white, fontSize: 16)),
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       )).toList(),
//                   )
//                 : const SizedBox.shrink(), // Disappears cleanly when not searching
//           ),
//         )
//       ],
//     );
//   }


Widget _buildSearchUI() {
    // Fetch the currently focused item name
    final focusName = context.watch<FocusProvider>().focusedItemName;
    final String displayText = focusName.isEmpty ? "Search" : focusName;
    
    // Check if Top Filter Bar is active (networks exist)
    final bool hasNetworks = widget.networkNames.isNotEmpty;

    return Row(
      children: [
        // LEFT SIDE: Focused Name and Search Input
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.only(left: 40, right: 20), // Adjusted for better TV alignment
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center, // Align text and box to the left
              children: [
                // 1. Focused Image Name (ONLY SHOW IF NETWORKS EXIST)
                if (hasNetworks) ...[
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: ShaderMask(
                      key: ValueKey<String>(displayText),
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFF00E5FF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: Text(
                        displayText,
                        style: const TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.w800, 
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(color: Color(0xFF00B0FF), blurRadius: 10, offset: Offset(0, 0)),
                            Shadow(color: Colors.black, blurRadius: 5, offset: Offset(1, 2)),
                          ]
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), // Space between title and input box
                ],
                
                // Animate the space and input box out when keyboard is hidden
                AnimatedSize(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: _showKeyboard 
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!hasNetworks) const SizedBox(height: 12), // Fallback space if title is hidden
                          // 2. Wide, Slim Search Input Box
                          Container(
                            width: double.infinity, // Stretches to fill available space
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6), // Slightly darker for better contrast
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: ProfessionalColors.accentPurple, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.white70, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _searchText.isEmpty ? 'Type to search...' : _searchText,
                                    style: TextStyle(
                                      color: _searchText.isEmpty ? Colors.white54 : Colors.white, 
                                      fontSize: 18, 
                                      fontWeight: FontWeight.w500
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Optional: Show a blinking cursor effect when empty
                                if (_searchText.isEmpty)
                                  Container(
                                    width: 2,
                                    height: 18,
                                    color: Colors.white70,
                                  )
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(width: double.infinity, height: 0),
                ),
              ],
            ),
          ),
        ),
        
        // RIGHT SIDE: The Keyboard (ANIMATED IN AND OUT)
        Expanded(
          flex: 6,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _showKeyboard
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _keyboardLayout.asMap().entries.map((r) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: r.value.asMap().entries.map((c) {
                          int idx = _keyboardLayout
                                  .take(r.key)
                                  .fold(0, (p, e) => p + e.length) +
                              c.key;
                          if (idx >= _keyboardFocusNodes.length) {
                            return const SizedBox.shrink();
                          }
                          bool isFocused = _focusedKeyRow == r.key && _focusedKeyCol == c.key;
                          String key = c.value;
                          double w = key == 'SPACE'
                              ? 150
                              : (key == 'OK' || key == 'DEL' ? 70 : 40);
                          return Container(
                            width: w,
                            height: 35, 
                            margin: const EdgeInsets.all(2),
                            child: Focus(
                              focusNode: _keyboardFocusNodes[idx],
                              onFocusChange: (has) {
                                if (has) {
                                  setState(() {
                                    _focusedKeyRow = r.key;
                                    _focusedKeyCol = c.key;
                                  });
                                }
                              },
                              child: ElevatedButton(
                                onPressed: () => _handleKeyClick(key),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFocused
                                      ? ProfessionalColors.accentPurple
                                      : Colors.white10,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      side: isFocused
                                          ? const BorderSide(color: Colors.white, width: 2)
                                          : BorderSide.none),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(key,
                                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                              ),
                            ),
                          );
                        }).toList(),
                      )).toList(),
                  )
                : const SizedBox.shrink(), // Disappears cleanly when not searching
          ),
        )
      ],
    );
  }


  Widget _buildBackgroundSlider() {
    if (widget.sliderImages.isEmpty) {
      if (_fallbackBackgroundImageUrl != null) {
        return Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: _fallbackBackgroundImageUrl!,
              fit: BoxFit.fill ,
              errorWidget: (c, u, e) => Container(color: ProfessionalColors.primaryDark),
            ),
          ],
        );
      }
      return Container(color: ProfessionalColors.primaryDark);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _sliderPageController,
          itemCount: widget.sliderImages.length,
          onPageChanged: (index) {
            setState(() {
              _currentSliderPage = index;
            });
          },
          itemBuilder: (c, i) => CachedNetworkImage(
              imageUrl: widget.sliderImages[i],
              fit: BoxFit.fill,
              errorWidget: (c, u, e) =>
                  Container(color: ProfessionalColors.surfaceDark)),
        ),
      ],
    );
  }

  Widget _buildSliderIndicators() {
    if (widget.sliderImages.length <= 1) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          widget.sliderImages.length,
          (i) => AnimatedContainer(
                duration: AnimationTiming.fast,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 7, 
                width: _currentSliderPage == i ? 22 : 7,
                decoration: BoxDecoration(
                    color: _currentSliderPage == i ? Colors.white : Colors.white60,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))
                    ]
                ),
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
              style: const TextStyle(color: Colors.black87, fontSize: 18), 
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
  final double dynamicSpacing;
  final double dynamicScale;

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
    required this.dynamicSpacing,
    required this.dynamicScale,
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
        AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    
    // --- DYNAMIC SCALE APPLED HERE ---
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.dynamicScale).animate(
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
    if (oldWidget.dynamicScale != widget.dynamicScale) {
      _scaleAnimation = Tween<double>(begin: 1.0, end: widget.dynamicScale).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
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

  Color _getBadgeColor(String genre) {
    String g = genre.toLowerCase();
    if (g.contains("web series")) return Colors.red.withOpacity(0.6); 
    if (g.contains("tv show")) return Colors.blue.withOpacity(0.6);
    if (g.contains("latest")) return Colors.orange.withOpacity(0.6);
    return Colors.transparent; 
  }

  String _getCleanGenre(String genre) {
    String g = genre.toLowerCase();
    if (g.contains("web series")) return "WEB SERIES";
    if (g.contains("tv show")) return "TV SHOW";
    if (g.contains("latest")) return "LATEST";
    return ""; 
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
    return Padding(
      // --- DYNAMIC PADDING APPLIED HERE ---
      padding: EdgeInsets.symmetric(horizontal: widget.dynamicSpacing / 2),
      child: SizedBox(
        width: widget.cardWidth, // Strict parent boundary
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnimation.value,
                child: Focus(
                  focusNode: widget.focusNode,
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: _buildPoster(),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: widget.isFocused ? 30 : 5), 
            
            SizedBox(
              height: 40, 
              child: OverflowBox(
                maxWidth: widget.cardWidth * 2.5, 
                maxHeight: 40,
                child: _buildTitle(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: widget.isFocused ? (widget.cardWidth * 2.0) : widget.cardWidth,
      alignment: Alignment.topCenter,
      child: Text(
        widget.getTitle(widget.item),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: widget.isFocused ? 18.0 : 14.0,
          fontWeight: widget.isFocused ? FontWeight.w900 : FontWeight.w500,
          color: widget.isFocused ? Colors.white : Colors.black, 
          letterSpacing: 0.5,
          height: 1.2,
          shadows: widget.isFocused
              ? const [
                  Shadow(color: Colors.black, blurRadius: 15, offset: Offset(0, 3)),
                  Shadow(color: Colors.black87, blurRadius: 5, offset: Offset(0, 1)),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildPoster() {
    final dynamic item = widget.item;
    
    String rawGenre = "";
    try {
      rawGenre = item.genres ?? "";
    } catch (_) {
      rawGenre = "";
    }
    
    final String displayGenre = _getCleanGenre(rawGenre);
    final Color badgeColor = _getBadgeColor(rawGenre);
    double nametextsz = 14.0; 

    return Container(
      height: widget.cardHeight,
      width: widget.cardWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          if (widget.isFocused) 
            BoxShadow(color: Colors.black.withOpacity(0.95), blurRadius: 25, spreadRadius: 8, offset: const Offset(0, 12))
          else 
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))
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
                      colors: [Colors.white.withOpacity(0.1), Colors.white, Colors.white, Colors.white.withOpacity(0.1)],
                      stops: const [0.0, 0.25, 0.5, 1.0],
                      transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
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
                    fit: BoxFit.fill,
                    placeholder: (c, u) => _placeholder(),
                    errorWidget: (c, u, e) => _placeholder(),
                  ),

                  if (displayGenre.isNotEmpty)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor, 
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5), 
                        ),
                        child: Text(
                          displayGenre,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9), 
                            fontSize: nametextsz * 0.5 , 
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                  if (widget.logoUrl.isNotEmpty)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: CircleAvatar(
                        radius: 10, 
                        backgroundImage: CachedNetworkImageProvider(widget.logoUrl),
                        backgroundColor: Colors.black45,
                      ),
                    ),
                ],
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
}