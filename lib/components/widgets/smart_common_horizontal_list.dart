// import 'dart:async';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_loading_widget.dart';
// import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_retry_widget.dart';
// import 'package:mobi_tv_entertainment/main.dart'; 
// import 'package:provider/provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
// import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';

// // ✅ 1. GENERIC CONTENT MODEL
// class CommonContentModel {
//   final String id;
//   final String title;
//   final String imageUrl;
//   final String badgeText;
//   final dynamic originalData; 

//   CommonContentModel({
//     required this.id,
//     required this.title,
//     required this.imageUrl,
//     required this.badgeText,
//     required this.originalData,
//   });
// }

// // ✅ 2. MASTER HORIZONTAL LIST WIDGET
// class SmartCommonHorizontalList extends StatefulWidget {
//   final String sectionTitle;
//   final List<Color> titleGradient;
//   final Color accentColor;
//   final IconData placeholderIcon;
//   final String badgeDefaultText;
  
//   final String focusIdentifier; 
//   final String? nextFocusIdentifier; 
  
//   final Future<List<CommonContentModel>> Function() fetchApiData; 
//   final Future<void> Function(CommonContentModel) onItemTap;
//   final Future<void> Function()? onViewAllTap;
  
//   final int maxVisibleItems;

//   const SmartCommonHorizontalList({
//     Key? key,
//     required this.sectionTitle,
//     required this.titleGradient,
//     required this.accentColor,
//     required this.placeholderIcon,
//     this.badgeDefaultText = '',
//     required this.focusIdentifier,
//     this.nextFocusIdentifier,
//     required this.fetchApiData,
//     required this.onItemTap,
//     this.onViewAllTap,
//     this.maxVisibleItems = 10,
//   }) : super(key: key);

//   @override
//   _SmartCommonHorizontalListState createState() => _SmartCommonHorizontalListState();
// }

// class _SmartCommonHorizontalListState extends State<SmartCommonHorizontalList> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<CommonContentModel> _fullList = [];
//   List<CommonContentModel> _displayedList = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
  
//   bool _isSectionFocused = false;
//   int _focusedIndex = -1;

//   late AnimationController _headerAnimationController;
//   late AnimationController _listAnimationController;
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<double> _listFadeAnimation;

//   final Map<String, FocusNode> _itemFocusNodes = {};
//   final FocusNode _viewAllFocusNode = FocusNode();
//   final FocusNode _retryFocusNode = FocusNode();
  
//   late ScrollController _scrollController;
//   bool _isNavigationLocked = false;
//   bool _isNavigating = false; 
//   Timer? _navLockTimer;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _initializeAnimations();
//     _loadDataDirectlyFromApi();
//   }

//   void _initializeAnimations() {
//     _headerAnimationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
//     _listAnimationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
//     _headerSlideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutCubic));
//     _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _listAnimationController, curve: Curves.easeInOut));
//   }

//   @override
//   void dispose() {
//     _navLockTimer?.cancel();
//     _headerAnimationController.dispose();
//     _listAnimationController.dispose();
//     _viewAllFocusNode.dispose();
//     _retryFocusNode.dispose();
//     _scrollController.dispose();
//     for (var node in _itemFocusNodes.values) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> _loadDataDirectlyFromApi() async {
//     if (!mounted) return;
//     setState(() { _isLoading = true; _errorMessage = ''; });

//     try {
//       final fetchedData = await widget.fetchApiData();
//       if (mounted) {
//         _fullList = fetchedData;
//         _displayedList = _fullList.length > widget.maxVisibleItems 
//             ? _fullList.sublist(0, widget.maxVisibleItems) 
//             : _fullList;
            
//         setState(() => _isLoading = false);
        
//         if (_displayedList.isNotEmpty) {
//           _createFocusNodes();
//           _setupFocusProvider();
//           _headerAnimationController.forward();
//           _listAnimationController.forward();
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() { _isLoading = false; _errorMessage = 'Failed to load content'; });
//         _setupFocusProvider();
//       }
//     }
//   }

//   void _createFocusNodes() {
//     _itemFocusNodes.clear();
//     for (int i = 0; i < _displayedList.length; i++) {
//       String id = _displayedList[i].id;
//       _itemFocusNodes[id] = FocusNode();
//       _itemFocusNodes[id]!.addListener(() {
//         if (mounted && _itemFocusNodes[id]!.hasFocus) {
//           setState(() => _focusedIndex = i);
//           _scrollToPosition(i);
//         }
//       });
//     }
    
//     _viewAllFocusNode.addListener(() {
//       if (mounted && _viewAllFocusNode.hasFocus) {
//         setState(() => _focusedIndex = _displayedList.length);
//         _scrollToPosition(_focusedIndex);
//       }
//     });
//   }

//   void _setupFocusProvider() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       final fp = Provider.of<FocusProvider>(context, listen: false);
      
//       if (_displayedList.isNotEmpty) {
//         String? savedId = fp.lastFocusedItemId;
//         FocusNode entryNode = _itemFocusNodes[_displayedList[0].id]!;
        
//         if (savedId != null && _itemFocusNodes.containsKey(savedId)) {
//            entryNode = _itemFocusNodes[savedId]!;
//         }
        
//         fp.registerFocusNode(widget.focusIdentifier, entryNode);
        
//         if (fp.lastFocusedIdentifier == widget.focusIdentifier) {
//           entryNode.requestFocus();
//           int idx = _displayedList.indexWhere((item) => item.id == savedId);
//           if (idx != -1) _scrollToPosition(idx);
//         }
//       } else if (_errorMessage.isNotEmpty) {
//         fp.registerFocusNode(widget.focusIdentifier, _retryFocusNode);
//       }
//     });
//   }

//   // ✅ SCROLL TO POSITION (AB YE FUTURE RETURN KAREGA TAAKI HUM WAIT KAR SAKEIN)
//   Future<void> _scrollToPosition(int index) async {
//     if (!_scrollController.hasClients) return;
//     double itemWidth = (bannerwdt ?? 150) + 30; 
//     double targetOffset = index * itemWidth;
//     await _scrollController.animateTo(
//       targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
//       duration: const Duration(milliseconds: 300), 
//       curve: Curves.easeOutCubic,
//     );
//   }

//   // ✅ ULTIMATE BULLETPROOF NAVIGATION & RESTORE
//   Future<void> _handleSafeNavigation(CommonContentModel? item, bool isViewAll) async {
//     if (_isNavigating) return; 
//     setState(() => _isNavigating = true);

//     final fp = Provider.of<FocusProvider>(context, listen: false);
//     fp.updateLastFocusedIdentifier(widget.focusIdentifier);
//     if (item != null) fp.updateLastFocusedItemId(item.id);

//     final String? savedId = item?.id;
//     final int targetIndex = isViewAll ? _displayedList.length : _displayedList.indexOf(item!);

//     // ✅ NEXT PAGE PAR JAA RAHE HAIN
//     if (isViewAll && widget.onViewAllTap != null) {
//       await widget.onViewAllTap!();
//     } else if (item != null) {
//       await widget.onItemTap(item);
//     }

//     // ✅ FIX 1: WAPAS AANE PAR ANIMATION KHATAM HONE KA WAIT KARO
//     await Future.delayed(const Duration(milliseconds: 500));

//     if (!mounted) return;
//     setState(() {
//       _isNavigating = false;
//       _focusedIndex = targetIndex;
//       _isSectionFocused = true;
//     });

//     // ✅ FIX 2: PEHLE SCROLL KARO TAAKI ITEM SCREEN PAR AA JAYE (AWAIT)
//     await _scrollToPosition(targetIndex);

//     // ✅ FIX 3: AB ZABARDASTI FOCUS KHEENCHO
//     if (!mounted) return;
//     FocusNode? targetNode = isViewAll ? _viewAllFocusNode : _itemFocusNodes[savedId];
    
//     if (targetNode != null) {
//       context.read<ColorProvider>().updateColor(widget.accentColor, true);
//       targetNode.requestFocus();

//       // Backup check in case OS still fighting
//       Future.delayed(const Duration(milliseconds: 150), () {
//         if (mounted && !targetNode.hasFocus && targetNode.canRequestFocus) {
//           targetNode.requestFocus();
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final sw = MediaQuery.of(context).size.width;
//     final sh = MediaQuery.of(context).size.height;
//     double containerHeight = (screenhgt ?? sh) * 0.38;

//     return Container(
//       height: containerHeight,
//       color: Colors.white,
//       child: Stack(
//         children: [
//           Positioned(
//             left: 0,
//             top: 0,
//             bottom: 0,
//             width: sw * 0.14, // should match side menu width
//             child: Container(
//               color: Colors.grey.withOpacity(0.60),
//             ),
//           ),
//           Column(
//             children: [
//               SizedBox(height: (screenhgt ?? sh) * 0.01),
//               _buildTitle(sw),
//               Expanded(child: _buildBody(sw, sh)),
//             ],
//           ),
//           if (_isSectionFocused) _buildShadowOverlay(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTitle(double sw) {
//     String selectedItemName = "";
//     if (_focusedIndex != -1 && _focusedIndex < _displayedList.length && _isSectionFocused) {
//       selectedItemName = _displayedList[_focusedIndex].title.toUpperCase();
//     } else if (_focusedIndex == _displayedList.length && _isSectionFocused) {
//       selectedItemName = "VIEW ALL";
//     }

//     return SlideTransition(
//       position: _headerSlideAnimation,
//       child: Padding(
//         padding: EdgeInsets.only(left: sw * kSideMenuWidthFactor, right: sw * 0.025),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ShaderMask(
//               shaderCallback: (bounds) => LinearGradient(colors: widget.titleGradient).createShader(bounds),
//               child: Text(widget.sectionTitle, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 2.0)),
//             ),
//             if (selectedItemName.isNotEmpty) ...[
//               const SizedBox(width: 15),
//               const Text("|", style: TextStyle(fontSize: 22, color: Colors.grey, fontWeight: FontWeight.w300)),
//               const SizedBox(width: 15),
//               Expanded(
//                 child: AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 200),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     key: ValueKey<String>(selectedItemName),
//                     child: Text(
//                       selectedItemName,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w800, letterSpacing: 1.0),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(double sw, double sh) {
//     double bh = bannerhgt ?? sh * 0.2;
//     double bw = bannerwdt ?? sw * 0.18;

//     if (_isLoading) {
//       return SmartLoadingWidget(itemWidth: bw, itemHeight: bh);
//     } else if (_errorMessage.isNotEmpty) {
//       return Center(child: SmartRetryWidget(
//         errorMessage: _errorMessage, 
//         onRetry: _loadDataDirectlyFromApi, 
//         focusNode: _retryFocusNode, 
//         providerIdentifier: widget.focusIdentifier,
//         onFocusChange: (f) => setState(() => _isSectionFocused = f)
//       ));
//     } else if (_displayedList.isEmpty) {
//       return Center(child: Text("No ${widget.sectionTitle} Found", style: const TextStyle(color: Colors.grey, fontSize: 12)));
//     } else {
//       return _buildList(sw, sh);
//     }
//   }

//   Widget _buildList(double sw, double sh) {
//     bool showViewAll = widget.onViewAllTap != null && _fullList.isNotEmpty;
//     int itemCount = _displayedList.length + (showViewAll ? 1 : 0);

//     return FadeTransition(
//       opacity: _listFadeAnimation,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         clipBehavior: Clip.none,
//         controller: _scrollController,
//         padding: EdgeInsets.only(left: sw * kSideMenuWidthFactor, right: sw * 0.7),
//         itemCount: itemCount,
//         itemBuilder: (context, index) {
//           if (index < _displayedList.length) {
//             return _buildItemCard(_displayedList[index], index);
//           } else {
//             return _buildViewAllCard();
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildItemCard(CommonContentModel item, int index) {
//     FocusNode? node = _itemFocusNodes[item.id];
//     if (node == null) return const SizedBox.shrink();

//     return Focus(
//       focusNode: node,
//       onFocusChange: (hasFocus) {
//         if (mounted) setState(() => _isSectionFocused = hasFocus);
//         if (hasFocus) {
//           final fp = context.read<FocusProvider>();
//           fp.updateLastFocusedIdentifier(widget.focusIdentifier); 
//           fp.updateLastFocusedItemId(item.id);
//           fp.registerFocusNode(widget.focusIdentifier, node);
//           context.read<ColorProvider>().updateColor(ProfessionalColorsForHomePages.accentBlue, true);
//         } else {
//           bool anyFocused = _itemFocusNodes.values.any((n) => n.hasFocus) || _viewAllFocusNode.hasFocus;
//           if (!anyFocused && mounted) context.read<ColorProvider>().resetColor();
//         }
//       },
//       onKey: (node, event) => _handleKeyboardNavigation(event, index, false, item),
//       child: GestureDetector(
//         onTap: () => _handleSafeNavigation(item, false),
//         child: CommonContentCardWidget(
//           item: item,
//           focusNode: node,
//           placeholderIcon: widget.placeholderIcon,
//           defaultBadge: widget.badgeDefaultText,
//         ),
//       ),
//     );
//   }

//   Widget _buildViewAllCard() {
//     return Focus(
//       focusNode: _viewAllFocusNode,
//       onFocusChange: (hasFocus) {
//         if (mounted) setState(() => _isSectionFocused = hasFocus);
//         if (hasFocus) {
//           final fp = context.read<FocusProvider>();
//           fp.updateLastFocusedIdentifier(widget.focusIdentifier);
//           fp.registerFocusNode(widget.focusIdentifier, _viewAllFocusNode);
//           context.read<ColorProvider>().updateColor(widget.accentColor, true);
//         } else {
//           bool anyFocused = _itemFocusNodes.values.any((n) => n.hasFocus);
//           if (!anyFocused && mounted) context.read<ColorProvider>().resetColor();
//         }
//       },
//       onKey: (node, event) => _handleKeyboardNavigation(event, _displayedList.length, true, null),
//       child: GestureDetector(
//         onTap: () => _handleSafeNavigation(null, true),
//         child: CommonViewAllContentsStyleCard(focusNode: _viewAllFocusNode),
//       ),
//     );
//   }

//   KeyEventResult _handleKeyboardNavigation(RawKeyEvent event, int index, bool isViewAll, CommonContentModel? item) {
//     if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
//     final key = event.logicalKey;

//     if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.arrowLeft) {
//       if (_isNavigationLocked) return KeyEventResult.handled;
//       setState(() => _isNavigationLocked = true);
//       _navLockTimer = Timer(const Duration(milliseconds: 500), () { if (mounted) setState(() => _isNavigationLocked = false); });

//       if (key == LogicalKeyboardKey.arrowRight) {
//         if (!isViewAll && index < _displayedList.length - 1) {
//           FocusScope.of(context).requestFocus(_itemFocusNodes[_displayedList[index + 1].id]);
//         } else if (!isViewAll && widget.onViewAllTap != null && _fullList.isNotEmpty) {
//           FocusScope.of(context).requestFocus(_viewAllFocusNode);
//         }
//       } else if (key == LogicalKeyboardKey.arrowLeft) {
//         if (isViewAll) {
//           FocusScope.of(context).requestFocus(_itemFocusNodes[_displayedList.last.id]);
//         } else if (index > 0) {
//           FocusScope.of(context).requestFocus(_itemFocusNodes[_displayedList[index - 1].id]);
//         } else {
//           _navLockTimer?.cancel();
//           if (mounted) setState(() => _isNavigationLocked = false);
//           context.read<ColorProvider>().resetColor();
//           context.read<FocusProvider>().requestFocus('activeSidebar');
//         }
//       }
//       return KeyEventResult.handled;
//     }

//     if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.arrowDown) {
//       return KeyEventResult.handled; 
//     } 
    
//     if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
//       _handleSafeNavigation(item, isViewAll);
//       return KeyEventResult.handled;
//     }
//     return KeyEventResult.ignored;
//   }

//   Widget _buildShadowOverlay() {
//     return IgnorePointer(
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter, end: Alignment.bottomCenter,
//             colors: [Colors.black.withOpacity(0.8), Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.8)],
//             stops: const [0.0, 0.25, 0.75, 1.0],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CommonContentCardWidget extends StatefulWidget {
//   final CommonContentModel item;
//   final FocusNode focusNode;
//   final IconData placeholderIcon;
//   final String defaultBadge;

//   const CommonContentCardWidget({
//     Key? key, required this.item, required this.focusNode, required this.placeholderIcon, required this.defaultBadge
//   }) : super(key: key);

//   @override
//   _CommonContentCardWidgetState createState() => _CommonContentCardWidgetState();
// }

// class _CommonContentCardWidgetState extends State<CommonContentCardWidget> with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _borderAnimationController;
//   late Animation<double> _scaleAnimation;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.28).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
//     _borderAnimationController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
//     widget.focusNode.addListener(_handleFocus);
//   }

//   void _handleFocus() {
//     if (!mounted) return;
//     setState(() => _isFocused = widget.focusNode.hasFocus);
//     if (_isFocused) {
//       _scaleController.forward();
//       _borderAnimationController.repeat();
//       HapticFeedback.lightImpact();
//     } else {
//       _scaleController.reverse();
//       _borderAnimationController.stop();
//     }
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
//       width: bannerwdt,
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
//               child: _buildPoster(),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildTitle(),
//         ],
//       ),
//     );
//   }

//   Widget _buildPoster() {
//     double h = bannerhgt ?? 150;
//     return Container(
//       height: h,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           if (_isFocused) BoxShadow(color: Colors.black.withOpacity(0.95), blurRadius: 25, spreadRadius: 8, offset: const Offset(0, 12))
//           else BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))
//         ],
//       ),
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           if (_isFocused)
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
//             padding: EdgeInsets.all(_isFocused ? 3.5 : 0.0),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(_isFocused ? 5 : 8),
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   widget.item.imageUrl.isNotEmpty 
//                       ? Image.network(widget.item.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => _placeholder(h))
//                       : _placeholder(h),
                  
//                   if (widget.item.badgeText.isNotEmpty || widget.defaultBadge.isNotEmpty)
//                     Positioned(top: 6, right: 6, child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
//                       decoration: BoxDecoration(color: ProfessionalColorsForHomePages.accentGreen.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
//                       child: Text(widget.item.badgeText.isNotEmpty ? widget.item.badgeText : widget.defaultBadge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
//                     )),
//                 ],
//               ),
//             ),
//           ),

//           if (_isFocused)
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

//   Widget _placeholder(double h) => Container(
//     color: ProfessionalColorsForHomePages.cardDark,
//     child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//       Icon(widget.placeholderIcon, size: h * 0.25, color: Colors.grey),
//     ]),
//   );

//   Widget _buildTitle() => SizedBox(
//     width: bannerwdt,
//     child: AnimatedDefaultTextStyle(
//       duration: const Duration(milliseconds: 250),
//       style: TextStyle(
//         fontSize: 13,
//         fontWeight: _isFocused ? FontWeight.w800 : FontWeight.w600,
//         color: _isFocused ? Colors.white : Colors.black,
//         letterSpacing: 0.5,
//       ),
//       child: Text(widget.item.title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
//     ),
//   );
// }

// class CommonViewAllContentsStyleCard extends StatefulWidget {
//   final FocusNode focusNode;
//   const CommonViewAllContentsStyleCard({Key? key, required this.focusNode}) : super(key: key);
//   @override
//   _CommonViewAllContentsStyleCardState createState() => _CommonViewAllContentsStyleCardState();
// }

// class _CommonViewAllContentsStyleCardState extends State<CommonViewAllContentsStyleCard> with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _borderAnimationController;
//   late Animation<double> _scaleAnimation;
//   bool _isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.28).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
//     _borderAnimationController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
//     widget.focusNode.addListener(_handleFocus);
//   }

//   void _handleFocus() {
//     if (!mounted) return;
//     setState(() => _isFocused = widget.focusNode.hasFocus);
//     if (_isFocused) {
//       _scaleController.forward();
//       _borderAnimationController.repeat();
//     } else {
//       _scaleController.reverse();
//       _borderAnimationController.stop();
//     }
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
//     double h = bannerhgt ?? 150;
    
//     return Container(
//       width: bannerwdt,
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
//               child: Container(
//                 height: h,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     if (_isFocused) BoxShadow(color: Colors.black.withOpacity(0.95), blurRadius: 25, spreadRadius: 8, offset: const Offset(0, 12))
//                     else BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))
//                   ],
//                 ),
//                 child: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     if (_isFocused)
//                       AnimatedBuilder(
//                         animation: _borderAnimationController,
//                         builder: (context, child) {
//                           return Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               gradient: SweepGradient(
//                                 colors: [Colors.white.withOpacity(0.1), Colors.white, Colors.white, Colors.white.withOpacity(0.1)],
//                                 stops: const [0.0, 0.25, 0.5, 1.0],
//                                 transform: GradientRotation(_borderAnimationController.value * 2 * math.pi),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     Padding(
//                       padding: EdgeInsets.all(_isFocused ? 3.5 : 0.0),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(_isFocused ? 5 : 8),
//                         child: Container(
//                           color: ProfessionalColorsForHomePages.cardDark,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 30),
//                               const SizedBox(height: 8),
//                               const Text("VIEW ALL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     if (_isFocused)
//                       Positioned.fill(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: bannerwdt,
//             child: AnimatedDefaultTextStyle(
//               duration: const Duration(milliseconds: 250),
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: _isFocused ? FontWeight.w800 : FontWeight.w600,
//                 color: _isFocused ? Colors.white : Colors.black,
//                 letterSpacing: 0.5,
//               ),
//               child: const Text('SEE ALL', textAlign: TextAlign.center, maxLines: 1),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_loading_widget.dart';
import 'package:mobi_tv_entertainment/components/widgets/small_widgets/smart_retry_widget.dart';
import 'package:mobi_tv_entertainment/main.dart'; 
import 'package:provider/provider.dart';
import 'package:mobi_tv_entertainment/components/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';

// ✅ 1. GENERIC CONTENT MODEL
class CommonContentModel {
  final String id;
  final String title;
  final String imageUrl;
  final String badgeText;
  final dynamic originalData; 

  CommonContentModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.badgeText,
    required this.originalData,
  });
}

// ✅ 2. MASTER HORIZONTAL LIST WIDGET
class SmartCommonHorizontalList extends StatefulWidget {
  final String sectionTitle;
  final List<Color> titleGradient;
  final Color accentColor;
  final IconData placeholderIcon;
  final String badgeDefaultText;
  
  final String focusIdentifier; 
  final String? nextFocusIdentifier; 
  
  final Future<List<CommonContentModel>> Function() fetchApiData; 
  final Future<void> Function(CommonContentModel) onItemTap;
  final Future<void> Function()? onViewAllTap;
  
  final int maxVisibleItems;

  const SmartCommonHorizontalList({
    Key? key,
    required this.sectionTitle,
    required this.titleGradient,
    required this.accentColor,
    required this.placeholderIcon,
    this.badgeDefaultText = '',
    required this.focusIdentifier,
    this.nextFocusIdentifier,
    required this.fetchApiData,
    required this.onItemTap,
    this.onViewAllTap,
    this.maxVisibleItems = 10,
  }) : super(key: key);

  @override
  _SmartCommonHorizontalListState createState() => _SmartCommonHorizontalListState();
}

class _SmartCommonHorizontalListState extends State<SmartCommonHorizontalList> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  List<CommonContentModel> _fullList = [];
  List<CommonContentModel> _displayedList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  bool _isSectionFocused = false;
  int _focusedIndex = -1;

  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _listFadeAnimation;

  final Map<String, FocusNode> _itemFocusNodes = {};
  final FocusNode _viewAllFocusNode = FocusNode();
  final FocusNode _retryFocusNode = FocusNode();
  
  late ScrollController _scrollController;
  bool _isNavigationLocked = false;
  bool _isNavigating = false; 
  Timer? _navLockTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
    _loadDataDirectlyFromApi();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _listAnimationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _headerSlideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutCubic));
    _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _listAnimationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _navLockTimer?.cancel();
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    _viewAllFocusNode.dispose();
    _retryFocusNode.dispose();
    _scrollController.dispose();
    for (var node in _itemFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDataDirectlyFromApi() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final fetchedData = await widget.fetchApiData();
      if (mounted) {
        _fullList = fetchedData;
        _displayedList = _fullList.length > widget.maxVisibleItems 
            ? _fullList.sublist(0, widget.maxVisibleItems) 
            : _fullList;
            
        setState(() => _isLoading = false);
        
        if (_displayedList.isNotEmpty) {
          _createFocusNodes();
          _setupFocusProvider();
          _headerAnimationController.forward();
          _listAnimationController.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; _errorMessage = 'Failed to load content'; });
        _setupFocusProvider();
      }
    }
  }

  void _createFocusNodes() {
    _itemFocusNodes.clear();
    for (int i = 0; i < _displayedList.length; i++) {
      String id = _displayedList[i].id;
      _itemFocusNodes[id] = FocusNode();
      _itemFocusNodes[id]!.addListener(() {
        if (mounted && _itemFocusNodes[id]!.hasFocus) {
          setState(() => _focusedIndex = i);
          _scrollToPosition(i);
        }
      });
    }
    
    _viewAllFocusNode.addListener(() {
      if (mounted && _viewAllFocusNode.hasFocus) {
        setState(() => _focusedIndex = _displayedList.length);
        _scrollToPosition(_focusedIndex);
      }
    });
  }

  void _setupFocusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final fp = Provider.of<FocusProvider>(context, listen: false);
      
      if (_displayedList.isNotEmpty) {
        String? savedId = fp.lastFocusedItemId;
        FocusNode entryNode = _itemFocusNodes[_displayedList[0].id]!;
        
        if (savedId != null && _itemFocusNodes.containsKey(savedId)) {
           entryNode = _itemFocusNodes[savedId]!;
        }
        
        fp.registerFocusNode(widget.focusIdentifier, entryNode);
        
        if (fp.lastFocusedIdentifier == widget.focusIdentifier) {
          entryNode.requestFocus();
          int idx = _displayedList.indexWhere((item) => item.id == savedId);
          if (idx != -1) _scrollToPosition(idx);
        }
      } else if (_errorMessage.isNotEmpty) {
        fp.registerFocusNode(widget.focusIdentifier, _retryFocusNode);
      }
    });
  }

  // ✅ SCROLL TO POSITION (AB YE FUTURE RETURN KAREGA TAAKI HUM WAIT KAR SAKEIN)
  Future<void> _scrollToPosition(int index) async {
    if (!_scrollController.hasClients) return;
    double itemWidth = (bannerwdt ?? 150) + 30; 
    double targetOffset = index * itemWidth;
    await _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 600), 
      curve: Curves.linear,
    );
  }

  // ✅ ULTIMATE BULLETPROOF NAVIGATION & RESTORE
  Future<void> _handleSafeNavigation(CommonContentModel? item, bool isViewAll) async {
    if (_isNavigating) return; 
    setState(() => _isNavigating = true);

    final fp = Provider.of<FocusProvider>(context, listen: false);
    fp.updateLastFocusedIdentifier(widget.focusIdentifier);
    if (item != null) fp.updateLastFocusedItemId(item.id);

    final String? savedId = item?.id;
    final int targetIndex = isViewAll ? _displayedList.length : _displayedList.indexOf(item!);

    // ✅ NEXT PAGE PAR JAA RAHE HAIN
    if (isViewAll && widget.onViewAllTap != null) {
      await widget.onViewAllTap!();
    } else if (item != null) {
      await widget.onItemTap(item);
    }

    // ✅ FIX 1: WAPAS AANE PAR ANIMATION KHATAM HONE KA WAIT KARO
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    setState(() {
      _isNavigating = false;
      _focusedIndex = targetIndex;
      _isSectionFocused = true;
    });

    // ✅ FIX 2: PEHLE SCROLL KARO TAAKI ITEM SCREEN PAR AA JAYE (AWAIT)
    await _scrollToPosition(targetIndex);

    // ✅ FIX 3: AB ZABARDASTI FOCUS KHEENCHO
    if (!mounted) return;
    FocusNode? targetNode = isViewAll ? _viewAllFocusNode : _itemFocusNodes[savedId];
    
    if (targetNode != null) {
      context.read<ColorProvider>().updateColor(widget.accentColor, true);
      targetNode.requestFocus();

      // Backup check in case OS still fighting
      Future.delayed(const Duration(milliseconds:400), () {
        if (mounted && !targetNode.hasFocus && targetNode.canRequestFocus) {
          targetNode.requestFocus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    double containerHeight = (screenhgt ?? sh) * 0.38;

    return Container(
      height: containerHeight,
      color: Colors.white,
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: (screenhgt ?? sh) * 0.01),
              _buildTitle(sw),
              Expanded(child: _buildBody(sw, sh)),
            ],
          ),
          if (_isSectionFocused) _buildShadowOverlay(),
        ],
      ),
    );
  }

  Widget _buildTitle(double sw) {
    String selectedItemName = "";
    if (_focusedIndex != -1 && _focusedIndex < _displayedList.length && _isSectionFocused) {
      selectedItemName = _displayedList[_focusedIndex].title.toUpperCase();
    } else if (_focusedIndex == _displayedList.length && _isSectionFocused) {
      selectedItemName = "VIEW ALL";
    }

    return SlideTransition(
      position: _headerSlideAnimation,
      child: Padding(
        padding: EdgeInsets.only(left: sw * 0.16, right: sw * 0.025),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(colors: widget.titleGradient).createShader(bounds),
              child: Text(widget.sectionTitle, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 2.0)),
            ),
            if (selectedItemName.isNotEmpty) ...[
              const SizedBox(width: 15),
              const Text("|", style: TextStyle(fontSize: 22, color: Colors.grey, fontWeight: FontWeight.w300)),
              const SizedBox(width: 15),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    key: ValueKey<String>(selectedItemName),
                    child: Text(
                      selectedItemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w800, letterSpacing: 1.0),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(double sw, double sh) {
    double bh = bannerhgt ?? sh * 0.2;
    double bw = bannerwdt ?? sw * 0.18;

    if (_isLoading) {
      return SmartLoadingWidget(itemWidth: bw, itemHeight: bh);
    } else if (_errorMessage.isNotEmpty) {
      return Center(child: SmartRetryWidget(
        errorMessage: _errorMessage, 
        onRetry: _loadDataDirectlyFromApi, 
        focusNode: _retryFocusNode, 
        providerIdentifier: widget.focusIdentifier,
        onFocusChange: (f) => setState(() => _isSectionFocused = f)
      ));
    } else if (_displayedList.isEmpty) {
      return Center(child: Text("No ${widget.sectionTitle} Found", style: const TextStyle(color: Colors.grey, fontSize: 12)));
    } else {
      return _buildList(sw, sh);
    }
  }




  // Widget _buildList(double sw, double sh) {
  //   bool showViewAll = widget.onViewAllTap != null && _fullList.isNotEmpty;
  //   int itemCount = _displayedList.length + (showViewAll ? 1 : 0);
  //   final double itemWidth = bannerwdt ?? sw * 0.18;
  //   const double horizontalMargin = 15.0;
  //   final double itemExtent = itemWidth + (horizontalMargin * 2);
  //   final List<int> paintOrder = _buildPaintOrder(itemCount);

  //   return FadeTransition(
  //     opacity: _listFadeAnimation,
  //     child: LayoutBuilder(
  //       builder: (context, constraints) => SingleChildScrollView(
  //         scrollDirection: Axis.horizontal,
  //         clipBehavior: Clip.none,
  //         controller: _scrollController,
  //         padding: EdgeInsets.only(left: sw * 0.16, right: sw * 0.7),
  //         child: SizedBox(
  //           width: itemCount * itemExtent,
  //           height: constraints.maxHeight,
  //           child: Stack(
  //             clipBehavior: Clip.none,
  //             children: [
  //               for (final index in paintOrder)
  //                 Positioned(
  //                   left: index * itemExtent,
  //                   top: 0,
  //                   bottom: 0,
  //                   child: index < _displayedList.length
  //                       ? _buildItemCard(_displayedList[index], index)
  //                       : _buildViewAllCard(),
  //                 ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }



  Widget _buildList(double sw, double sh) {
    bool showViewAll = widget.onViewAllTap != null && _fullList.isNotEmpty;
    int itemCount = _displayedList.length + (showViewAll ? 1 : 0);
    final double itemWidth = bannerwdt ?? sw * 0.18;
    const double horizontalMargin = 15.0;
    final double itemExtent = itemWidth + (horizontalMargin * 2);
    final List<int> paintOrder = _buildPaintOrder(itemCount);

    return FadeTransition(
      opacity: _listFadeAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          controller: _scrollController,
          padding: EdgeInsets.only(left: sw * 0.16, right: sw * 0.7),
          child: SizedBox(
            width: itemCount * itemExtent,
            height: constraints.maxHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final index in paintOrder)
                  Positioned(
                    // ✅ FIX: Add a unique Key here so Flutter preserves the animation state
                    key: ValueKey<String>(
                      index < _displayedList.length 
                          ? 'positioned-${_displayedList[index].id}' 
                          : 'positioned-view-all'
                    ),
                    left: index * itemExtent,
                    top: 0,
                    bottom: 0,
                    child: index < _displayedList.length
                        ? _buildItemCard(_displayedList[index], index)
                        : _buildViewAllCard(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<int> _buildPaintOrder(int itemCount) {
    final List<int> order = List<int>.generate(itemCount, (index) => index);
    final int elevatedIndex = _isSectionFocused ? _focusedIndex : -1;

    if (elevatedIndex < 0 || elevatedIndex >= itemCount) {
      return order;
    }

    order.remove(elevatedIndex);
    order.add(elevatedIndex);
    return order;
  }

  Widget _buildItemCard(CommonContentModel item, int index) {
    FocusNode? node = _itemFocusNodes[item.id];
    if (node == null) return const SizedBox.shrink();

    return Focus(
      key: ValueKey<String>('content-card-${item.id}'),
      focusNode: node,
      onFocusChange: (hasFocus) {
        if (mounted) setState(() => _isSectionFocused = hasFocus);
        if (hasFocus) {
          final fp = context.read<FocusProvider>();
          fp.updateLastFocusedIdentifier(widget.focusIdentifier); 
          fp.updateLastFocusedItemId(item.id);
          fp.registerFocusNode(widget.focusIdentifier, node);
          context.read<ColorProvider>().updateColor(ProfessionalColorsForHomePages.accentBlue, true);
        } else {
          bool anyFocused = _itemFocusNodes.values.any((n) => n.hasFocus) || _viewAllFocusNode.hasFocus;
          if (!anyFocused && mounted) context.read<ColorProvider>().resetColor();
        }
      },
      onKey: (node, event) => _handleKeyboardNavigation(event, index, false, item),
      child: GestureDetector(
        onTap: () => _handleSafeNavigation(item, false),
        child: CommonContentCardWidget(
          item: item,
          focusNode: node,
          placeholderIcon: widget.placeholderIcon,
          defaultBadge: widget.badgeDefaultText,
        ),
      ),
    );
  }

  Widget _buildViewAllCard() {
    return Focus(
      key: const ValueKey<String>('content-card-view-all'),
      focusNode: _viewAllFocusNode,
      onFocusChange: (hasFocus) {
        if (mounted) setState(() => _isSectionFocused = hasFocus);
        if (hasFocus) {
          final fp = context.read<FocusProvider>();
          fp.updateLastFocusedIdentifier(widget.focusIdentifier);
          fp.registerFocusNode(widget.focusIdentifier, _viewAllFocusNode);
          context.read<ColorProvider>().updateColor(widget.accentColor, true);
        } else {
          bool anyFocused = _itemFocusNodes.values.any((n) => n.hasFocus);
          if (!anyFocused && mounted) context.read<ColorProvider>().resetColor();
        }
      },
      onKey: (node, event) => _handleKeyboardNavigation(event, _displayedList.length, true, null),
      child: GestureDetector(
        onTap: () => _handleSafeNavigation(null, true),
        child: CommonViewAllContentsStyleCard(focusNode: _viewAllFocusNode),
      ),
    );
  }

  KeyEventResult _handleKeyboardNavigation(RawKeyEvent event, int index, bool isViewAll, CommonContentModel? item) {
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.arrowLeft) {
      if (_isNavigationLocked) return KeyEventResult.handled;
      setState(() => _isNavigationLocked = true);
      _navLockTimer = Timer(const Duration(milliseconds: 600), () { if (mounted) setState(() => _isNavigationLocked = false); });

      if (key == LogicalKeyboardKey.arrowRight) {
        if (!isViewAll && index < _displayedList.length - 1) {
          FocusScope.of(context).requestFocus(_itemFocusNodes[_displayedList[index + 1].id]);
        } else if (!isViewAll && widget.onViewAllTap != null && _fullList.isNotEmpty) {
          FocusScope.of(context).requestFocus(_viewAllFocusNode);
        }
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        if (isViewAll) {
          FocusScope.of(context).requestFocus(_itemFocusNodes[_displayedList.last.id]);
        } else if (index > 0) {
          FocusScope.of(context).requestFocus(_itemFocusNodes[_displayedList[index - 1].id]);
        } else {
          _navLockTimer?.cancel();
          if (mounted) setState(() => _isNavigationLocked = false);
          context.read<ColorProvider>().resetColor();
          context.read<FocusProvider>().requestFocus('activeSidebar');
        }
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.arrowDown) {
      return KeyEventResult.handled; 
    } 
    
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
      _handleSafeNavigation(item, isViewAll);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _buildShadowOverlay() {
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.8)],
            stops: const [0.0, 0.25, 0.75, 1.0],
          ),
        ),
      ),
    );
  }
}

class CommonContentCardWidget extends StatefulWidget {
  final CommonContentModel item;
  final FocusNode focusNode;
  final IconData placeholderIcon;
  final String defaultBadge;

  const CommonContentCardWidget({
    Key? key, required this.item, required this.focusNode, required this.placeholderIcon, required this.defaultBadge
  }) : super(key: key);

  @override
  _CommonContentCardWidgetState createState() => _CommonContentCardWidgetState();
}

class _CommonContentCardWidgetState extends State<CommonContentCardWidget> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _borderAnimationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _scaleController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
  //   _scaleAnimation = Tween<double>(begin: 1.0, end: 1.28).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
  //   _borderAnimationController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
  //   widget.focusNode.addListener(_handleFocus);
  //   _syncFocusState();
  // }

  // @override
  // void didUpdateWidget(covariant CommonContentCardWidget oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.focusNode != widget.focusNode) {
  //     oldWidget.focusNode.removeListener(_handleFocus);
  //     widget.focusNode.addListener(_handleFocus);
  //   }
  //   _syncFocusState();
  // }




  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.28).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
    _borderAnimationController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
    
    widget.focusNode.addListener(_handleFocus);
    
    // Set the initial state without forcing an animation snap later
    _isFocused = widget.focusNode.hasFocus;
    _scaleController.value = _isFocused ? 1.0 : 0.0;
    if (_isFocused) {
      _borderAnimationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CommonContentCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocus);
      widget.focusNode.addListener(_handleFocus);
      // Let handleFocus drive the smooth animation if the node changes
      _handleFocus(); 
    }
  }

  void _handleFocus() {
    if (!mounted) return;
    final bool hasFocus = widget.focusNode.hasFocus;
    if (_isFocused == hasFocus) return;

    setState(() => _isFocused = hasFocus);
    if (hasFocus) {
      _scaleController.forward();
      _borderAnimationController.repeat();
      HapticFeedback.lightImpact();
    } else {
      _scaleController.reverse();
      _borderAnimationController.stop();
    }
  }

  void _syncFocusState() {
    _isFocused = widget.focusNode.hasFocus;
    _scaleController.value = _isFocused ? 1.0 : 0.0;
    if (_isFocused) {
      if (!_borderAnimationController.isAnimating) {
        _borderAnimationController.repeat();
      }
    } else {
      _borderAnimationController.stop();
    }
  }

  // void _handleFocus() {
  //   if (!mounted) return;
  //   final bool hasFocus = widget.focusNode.hasFocus;
  //   if (_isFocused == hasFocus) return;

  //   setState(() => _isFocused = hasFocus);
  //   if (hasFocus) {
  //     _scaleController.forward();
  //     _borderAnimationController.repeat();
  //     HapticFeedback.lightImpact();
  //   } else {
  //     _scaleController.reverse();
  //     _borderAnimationController.stop();
  //   }
  // }

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
      width: bannerwdt,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildPoster(),
            ),
          ),
          const SizedBox(height: 16),
          _buildTitle(),
        ],
      ),
    );
  }

  Widget _buildPoster() {
    double h = bannerhgt ?? 150;
    return Container(
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          if (_isFocused) BoxShadow(color: Colors.black.withOpacity(0.95), blurRadius: 25, spreadRadius: 8, offset: const Offset(0, 12))
          else BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_isFocused)
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
            padding: EdgeInsets.all(_isFocused ? 3.5 : 0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_isFocused ? 5 : 8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.item.imageUrl.isNotEmpty 
                      ? Image.network(widget.item.imageUrl,
                      cacheWidth: 300, 
                       fit: BoxFit.cover, errorBuilder: (c, e, s) => _placeholder(h))
                      : _placeholder(h),
                  
                  if (widget.item.badgeText.isNotEmpty || widget.defaultBadge.isNotEmpty)
                    Positioned(top: 6, right: 6, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                      decoration: BoxDecoration(color: ProfessionalColorsForHomePages.accentGreen.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
                      child: Text(widget.item.badgeText.isNotEmpty ? widget.item.badgeText : widget.defaultBadge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    )),
                ],
              ),
            ),
          ),

          if (_isFocused)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder(double h) => Container(
    color: ProfessionalColorsForHomePages.cardDark,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(widget.placeholderIcon, size: h * 0.25, color: Colors.grey),
    ]),
  );

  Widget _buildTitle() => SizedBox(
    width: bannerwdt,
    child: AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 600),
      style: TextStyle(
        fontSize: 13,
        fontWeight: _isFocused ? FontWeight.w800 : FontWeight.w600,
        color: _isFocused ? Colors.white : Colors.black,
        letterSpacing: 0.5,
      ),
      child: Text(widget.item.title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
  );
}

class CommonViewAllContentsStyleCard extends StatefulWidget {
  final FocusNode focusNode;
  const CommonViewAllContentsStyleCard({Key? key, required this.focusNode}) : super(key: key);
  @override
  _CommonViewAllContentsStyleCardState createState() => _CommonViewAllContentsStyleCardState();
}

class _CommonViewAllContentsStyleCardState extends State<CommonViewAllContentsStyleCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _borderAnimationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _scaleController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
  //   _scaleAnimation = Tween<double>(begin: 1.0, end: 1.28).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
  //   _borderAnimationController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
  //   widget.focusNode.addListener(_handleFocus);
  //   _syncFocusState();
  // }

  // @override
  // void didUpdateWidget(covariant CommonViewAllContentsStyleCard oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.focusNode != widget.focusNode) {
  //     oldWidget.focusNode.removeListener(_handleFocus);
  //     widget.focusNode.addListener(_handleFocus);
  //   }
  //   _syncFocusState();
  // }



  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.28).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic));
    _borderAnimationController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
    
    widget.focusNode.addListener(_handleFocus);
    
    // Set the initial state
    _isFocused = widget.focusNode.hasFocus;
    _scaleController.value = _isFocused ? 1.0 : 0.0;
    if (_isFocused) {
      _borderAnimationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CommonViewAllContentsStyleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocus);
      widget.focusNode.addListener(_handleFocus);
      _handleFocus();
    }
  }

  void _handleFocus() {
    if (!mounted) return;
    final bool hasFocus = widget.focusNode.hasFocus;
    if (_isFocused == hasFocus) return;

    setState(() => _isFocused = hasFocus);
    if (hasFocus) {
      _scaleController.forward();
      _borderAnimationController.repeat();
    } else {
      _scaleController.reverse();
      _borderAnimationController.stop();
    }
  }

  void _syncFocusState() {
    _isFocused = widget.focusNode.hasFocus;
    _scaleController.value = _isFocused ? 1.0 : 0.0;
    if (_isFocused) {
      if (!_borderAnimationController.isAnimating) {
        _borderAnimationController.repeat();
      }
    } else {
      _borderAnimationController.stop();
    }
  }

  // void _handleFocus() {
  //   if (!mounted) return;
  //   final bool hasFocus = widget.focusNode.hasFocus;
  //   if (_isFocused == hasFocus) return;

  //   setState(() => _isFocused = hasFocus);
  //   if (hasFocus) {
  //     _scaleController.forward();
  //     _borderAnimationController.repeat();
  //   } else {
  //     _scaleController.reverse();
  //     _borderAnimationController.stop();
  //   }
  // }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocus);
    _scaleController.dispose();
    _borderAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double h = bannerhgt ?? 150;
    
    return Container(
      width: bannerwdt,
      margin: const EdgeInsets.symmetric(horizontal: 15), 
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    if (_isFocused) BoxShadow(color: Colors.black.withOpacity(0.95), blurRadius: 25, spreadRadius: 8, offset: const Offset(0, 12))
                    else BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 4))
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_isFocused)
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
                      padding: EdgeInsets.all(_isFocused ? 3.5 : 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(_isFocused ? 5 : 8),
                        child: Container(
                          color: ProfessionalColorsForHomePages.cardDark,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 30),
                              const SizedBox(height: 8),
                              const Text("VIEW ALL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_isFocused)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: bannerwdt,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 600),
              style: TextStyle(
                fontSize: 13,
                fontWeight: _isFocused ? FontWeight.w800 : FontWeight.w600,
                color: _isFocused ? Colors.white : Colors.black,
                letterSpacing: 0.5,
              ),
              child: const Text('SEE ALL', textAlign: TextAlign.center, maxLines: 1),
            ),
          ),
        ],
      ),
    );
  }
}


