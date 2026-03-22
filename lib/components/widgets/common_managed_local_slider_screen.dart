import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/components/widgets/common_slider_screen.dart';
import 'package:mobi_tv_entertainment/main.dart';

class CommonManagedSliderBanner {
  final String id;
  final String title;
  final String imageUrl;

  const CommonManagedSliderBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
  });
}

class CommonManagedLocalSliderData<TFilter, TItem> {
  final List<CommonManagedSliderBanner> banners;
  final List<TFilter> filters;
  final List<TItem> items;
  final String? initialFilterId;
  final String? trailingImageUrl;

  const CommonManagedLocalSliderData({
    this.banners = const [],
    this.filters = const [],
    this.items = const [],
    this.initialFilterId,
    this.trailingImageUrl,
  });
}

class CommonManagedLocalSliderScreen<TFilter, TItem> extends StatefulWidget {
  final String pageTitle;
  final List<Color> titleGradient;
  final Color backgroundColor;
  final Future<CommonManagedLocalSliderData<TFilter, TItem>> Function()
      fetchPageData;
  final Future<void> Function(TItem item, List<TItem> visibleItems) onItemTap;
  final String Function(TFilter filter) filterIdBuilder;
  final String Function(TFilter filter) filterLabelBuilder;
  final Iterable<String> Function(TItem item) itemFilterIdsBuilder;
  final String Function(TItem item) itemIdBuilder;
  final String Function(TItem item) itemTitleBuilder;
  final String? Function(TItem item) itemImageUrlBuilder;
  final String? Function(TItem item)? itemSearchTextBuilder;
  final String? Function(TItem item)? itemNetworkLogoBuilder;
  final String? trailingImageUrl;
  final double? trailingImageHeight;
  final IconData placeholderIcon;
  final List<Color> focusColors;
  final Color searchFocusColor;
  final Color searchActionColor;
  final bool showSearchAction;
  final bool useCachedImage;
  final List<Color>? placeholderGradientColors;
  final Color? placeholderBackgroundColor;
  final EdgeInsetsGeometry headerPadding;
  final List<Color>? headerBackgroundGradient;
  final Border? headerBorder;
  final EdgeInsetsGeometry actionBarPadding;
  final double actionBarHeight;
  final double searchSectionHeight;
  final double gapAfterIndicators;
  final double gapBeforeList;
  final double bottomSpacing;
  final double? topBarHeight;
  final double? cardWidth;
  final double? cardHeight;
  final EdgeInsetsGeometry listPadding;
  final EdgeInsetsGeometry itemMargin;
  final EdgeInsetsGeometry titlePadding;
  final double titleSpacing;
  final double titleFontSize;
  final FontWeight focusedTitleFontWeight;
  final FontWeight unfocusedTitleFontWeight;
  final Color? focusedTitleColor;
  final Color unfocusedTitleColor;
  final TextAlign titleTextAlign;
  final int titleMaxLines;
  final CrossAxisAlignment cardCrossAxisAlignment;
  final bool showFocusedScrim;
  final double focusedScrimOpacity;
  final Alignment focusedIconAlignment;
  final EdgeInsetsGeometry focusedIconPadding;
  final Color? focusedIconBackgroundColor;
  final EdgeInsetsGeometry focusedIconInnerPadding;
  final IconData focusedIcon;
  final double focusedIconSize;
  final double borderRadius;
  final double imageBorderRadius;
  final List<List<String>> keyboardLayout;
  final Duration bannerAutoSlideDuration;
  final Duration navigationLockDuration;
  final Widget Function(BuildContext context, String? error, VoidCallback retry)?
      errorBuilder;
  final Widget Function(BuildContext context, bool isSearching, String searchText)?
      emptyStateBuilder;
  final Widget? overlay;

  const CommonManagedLocalSliderScreen({
    super.key,
    required this.pageTitle,
    required this.titleGradient,
    required this.fetchPageData,
    required this.onItemTap,
    required this.filterIdBuilder,
    required this.filterLabelBuilder,
    required this.itemFilterIdsBuilder,
    required this.itemIdBuilder,
    required this.itemTitleBuilder,
    required this.itemImageUrlBuilder,
    required this.placeholderIcon,
    required this.focusColors,
    this.backgroundColor = Colors.black,
    this.itemSearchTextBuilder,
    this.itemNetworkLogoBuilder,
    this.trailingImageUrl,
    this.trailingImageHeight,
    this.searchFocusColor = const Color(0xFF8B5CF6),
    this.searchActionColor = const Color(0xFFF59E0B),
    this.showSearchAction = true,
    this.useCachedImage = false,
    this.placeholderGradientColors,
    this.placeholderBackgroundColor,
    this.headerPadding = const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    this.headerBackgroundGradient,
    this.headerBorder,
    this.actionBarPadding = const EdgeInsets.symmetric(horizontal: 40),
    this.actionBarHeight = 38,
    this.searchSectionHeight = 200,
    this.gapAfterIndicators = 10,
    this.gapBeforeList = 15,
    this.bottomSpacing = 15,
    this.topBarHeight,
    this.cardWidth,
    this.cardHeight,
    this.listPadding = const EdgeInsets.symmetric(horizontal: 40),
    this.itemMargin = const EdgeInsets.only(right: 15),
    this.titlePadding = EdgeInsets.zero,
    this.titleSpacing = 8,
    this.titleFontSize = 12,
    this.focusedTitleFontWeight = FontWeight.bold,
    this.unfocusedTitleFontWeight = FontWeight.normal,
    this.focusedTitleColor,
    this.unfocusedTitleColor = Colors.white60,
    this.titleTextAlign = TextAlign.center,
    this.titleMaxLines = 1,
    this.cardCrossAxisAlignment = CrossAxisAlignment.center,
    this.showFocusedScrim = false,
    this.focusedScrimOpacity = 0.4,
    this.focusedIconAlignment = Alignment.topLeft,
    this.focusedIconPadding = const EdgeInsets.only(left: 5, top: 5),
    this.focusedIconBackgroundColor,
    this.focusedIconInnerPadding = const EdgeInsets.all(0),
    this.focusedIcon = Icons.play_circle_filled_outlined,
    this.focusedIconSize = 30,
    this.borderRadius = 8,
    this.imageBorderRadius = 6,
    this.keyboardLayout = const [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm', 'DEL'],
      ['SPACE', 'OK'],
    ],
    this.bannerAutoSlideDuration = const Duration(seconds: 8),
    this.navigationLockDuration = const Duration(milliseconds: 500),
    this.errorBuilder,
    this.emptyStateBuilder,
    this.overlay,
  });

  @override
  State<CommonManagedLocalSliderScreen<TFilter, TItem>> createState() =>
      _CommonManagedLocalSliderScreenState<TFilter, TItem>();
}

class _CommonManagedLocalSliderScreenState<TFilter, TItem>
    extends State<CommonManagedLocalSliderScreen<TFilter, TItem>>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  bool _isDisposed = false;
  bool _isSearching = false;
  bool _showKeyboard = false;
  bool _isNavigationLocked = false;
  String _searchText = '';
  String _focusedHeaderText = '';
  String? _selectedFilterId;
  int _focusedFilterIndex = 0;
  int _focusedItemIndex = -1;
  int _focusedKeyRow = 0;
  int _focusedKeyCol = 0;
  int _currentBannerIndex = 0;

  List<TFilter> _filters = [];
  List<TItem> _allItems = [];
  List<TItem> _displayItems = [];
  List<CommonManagedSliderBanner> _banners = [];
  String? _resolvedTrailingImageUrl;

  final FocusNode _rootFocusNode = FocusNode();
  final FocusNode _searchButtonFocusNode = FocusNode();
  final ScrollController _filterScrollController = ScrollController();
  final ScrollController _itemScrollController = ScrollController();
  late final PageController _bannerController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  List<FocusNode> _filterFocusNodes = [];
  List<FocusNode> _itemFocusNodes = [];
  List<FocusNode> _keyboardFocusNodes = [];

  Timer? _bannerTimer;
  Timer? _navigationLockTimer;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _bannerTimer?.cancel();
    _navigationLockTimer?.cancel();
    _bannerController.dispose();
    _fadeController.dispose();
    _rootFocusNode.dispose();
    _searchButtonFocusNode.dispose();
    _filterScrollController.dispose();
    _itemScrollController.dispose();
    _disposeFocusNodes(_filterFocusNodes);
    _disposeFocusNodes(_itemFocusNodes);
    _disposeFocusNodes(_keyboardFocusNodes);
    super.dispose();
  }

  void _disposeFocusNodes(List<FocusNode> nodes) {
    for (final node in nodes) {
      try {
        node.dispose();
      } catch (_) {}
    }
    nodes.clear();
  }

  Future<void> _loadData() async {
    if (_isDisposed) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await widget.fetchPageData();
      if (_isDisposed || !mounted) {
        return;
      }

      _filters = data.filters;
      _allItems = data.items;
      _banners = data.banners.where((banner) => banner.imageUrl.isNotEmpty).toList();
      _resolvedTrailingImageUrl = data.trailingImageUrl ?? widget.trailingImageUrl;
      _selectedFilterId = data.initialFilterId ??
          (_filters.isNotEmpty ? widget.filterIdBuilder(_filters.first) : null);
      _searchText = '';
      _isSearching = false;
      _showKeyboard = false;
      _focusedFilterIndex = 0;
      _focusedItemIndex = -1;
      _currentBannerIndex = 0;
      _focusedHeaderText = '';

      _applyFilters();
      _rebuildFocusNodes();
      _setupBannerTimer();
      _fadeController
        ..reset()
        ..forward();

      setState(() {
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted && _searchButtonFocusNode.canRequestFocus) {
          _searchButtonFocusNode.requestFocus();
          setState(() {
            _focusedHeaderText = 'SEARCH';
          });
        }
      });
    } catch (error) {
      if (_isDisposed || !mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  void _setupBannerTimer() {
    _bannerTimer?.cancel();
    if (_banners.length <= 1) {
      return;
    }

    _bannerTimer = Timer.periodic(widget.bannerAutoSlideDuration, (_) {
      if (_isDisposed || !_bannerController.hasClients) {
        return;
      }

      final nextIndex = (_currentBannerIndex + 1) % _banners.length;
      _bannerController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  void _rebuildFocusNodes() {
    _disposeFocusNodes(_filterFocusNodes);
    _disposeFocusNodes(_itemFocusNodes);
    _disposeFocusNodes(_keyboardFocusNodes);

    _filterFocusNodes = List.generate(_filters.length, (_) => FocusNode());
    _itemFocusNodes = List.generate(_displayItems.length, (_) => FocusNode());
    final totalKeyboardKeys =
        widget.keyboardLayout.fold<int>(0, (sum, row) => sum + row.length);
    _keyboardFocusNodes = List.generate(totalKeyboardKeys, (_) => FocusNode());
  }

  void _applyFilters() {
    final normalizedSearch = _searchText.trim().toLowerCase();
    final filterId = _selectedFilterId;

    final filtered = _allItems.where((item) {
      final matchesFilter = filterId == null ||
          widget
              .itemFilterIdsBuilder(item)
              .map((value) => value.trim())
              .contains(filterId);

      if (!matchesFilter) {
        return false;
      }

      if (normalizedSearch.isEmpty) {
        return true;
      }

      final searchValue = (widget.itemSearchTextBuilder?.call(item) ??
              widget.itemTitleBuilder(item))
          .toLowerCase();
      return searchValue.contains(normalizedSearch);
    }).toList();

    _displayItems = filtered;
  }

  Future<void> _scrollToItem(int index) async {
    if (!_itemScrollController.hasClients || index < 0) {
      return;
    }

    final baseWidth = widget.cardWidth ?? bannerwdt ?? 160.0;
    final width = baseWidth + _horizontalMarginForItem();
    final target = index * width;
    await _itemScrollController.animateTo(
      target.clamp(0.0, _itemScrollController.position.maxScrollExtent).toDouble(),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _scrollToFilter(int index) async {
    if (!_filterScrollController.hasClients || index < 0) {
      return;
    }

    const estimatedWidth = 160.0;
    final target = index * estimatedWidth;
    await _filterScrollController.animateTo(
      target.clamp(0.0, _filterScrollController.position.maxScrollExtent).toDouble(),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  double _horizontalMarginForItem() {
    if (widget.itemMargin is EdgeInsets) {
      final margin = widget.itemMargin as EdgeInsets;
      return margin.left + margin.right;
    }
    if (widget.itemMargin is EdgeInsetsDirectional) {
      final margin = widget.itemMargin as EdgeInsetsDirectional;
      return margin.start + margin.end;
    }
    return 0;
  }

  void _updateSearchText(String key) {
    setState(() {
      if (key == 'DEL') {
        if (_searchText.isNotEmpty) {
          _searchText = _searchText.substring(0, _searchText.length - 1);
        }
      } else if (key == 'SPACE' || key == ' ') {
        _searchText = '$_searchText ';
      } else if (key == 'OK') {
        _showKeyboard = false;
      } else {
        _searchText = '$_searchText$key';
      }

      _isSearching = _searchText.trim().isNotEmpty;
      _applyFilters();
      _focusedItemIndex = _displayItems.isEmpty ? -1 : 0;
      _rebuildFocusNodes();
    });

    if (key == 'OK') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_displayItems.isNotEmpty && _itemFocusNodes.isNotEmpty) {
          _itemFocusNodes.first.requestFocus();
          _handleItemFocused(0);
        } else {
          _searchButtonFocusNode.requestFocus();
          setState(() {
            _focusedHeaderText = 'SEARCH';
          });
        }
      });
    }
  }

  KeyEventResult _navigateKeyboard(LogicalKeyboardKey key) {
    final rowCount = widget.keyboardLayout.length;
    final currentRowLength = widget.keyboardLayout[_focusedKeyRow].length;

    if (key == LogicalKeyboardKey.arrowLeft && _focusedKeyCol > 0) {
      setState(() => _focusedKeyCol--);
    } else if (key == LogicalKeyboardKey.arrowRight &&
        _focusedKeyCol < currentRowLength - 1) {
      setState(() => _focusedKeyCol++);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      if (_focusedKeyRow > 0) {
        setState(() {
          _focusedKeyRow--;
          _focusedKeyCol = _focusedKeyCol.clamp(0, widget.keyboardLayout[_focusedKeyRow].length - 1).toInt();
        });
      } else {
        setState(() => _showKeyboard = false);
        _searchButtonFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.arrowDown &&
        _focusedKeyRow < rowCount - 1) {
      setState(() {
        _focusedKeyRow++;
        _focusedKeyCol = _focusedKeyCol.clamp(0, widget.keyboardLayout[_focusedKeyRow].length - 1).toInt();
      });
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.select) {
      _updateSearchText(widget.keyboardLayout[_focusedKeyRow][_focusedKeyCol]);
      return KeyEventResult.handled;
    }

    final focusIndex = _keyboardFocusIndex(_focusedKeyRow, _focusedKeyCol);
    if (focusIndex < _keyboardFocusNodes.length) {
      _keyboardFocusNodes[focusIndex].requestFocus();
    }
    return KeyEventResult.handled;
  }

  int _keyboardFocusIndex(int row, int col) {
    int index = 0;
    for (int i = 0; i < row; i++) {
      index += widget.keyboardLayout[i].length;
    }
    return index + col;
  }

  KeyEventResult _navigateFromSearch(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
      setState(() {
        _showKeyboard = true;
        _focusedKeyRow = 0;
        _focusedKeyCol = 0;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_keyboardFocusNodes.isNotEmpty) {
          _keyboardFocusNodes.first.requestFocus();
        }
      });
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowRight && _filterFocusNodes.isNotEmpty) {
      _filterFocusNodes.first.requestFocus();
      _handleFilterFocused(0);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowDown && _itemFocusNodes.isNotEmpty) {
      _itemFocusNodes.first.requestFocus();
      _handleItemFocused(0);
      return KeyEventResult.handled;
    }

    return KeyEventResult.handled;
  }

  KeyEventResult _navigateFilters(LogicalKeyboardKey key) {
    int newIndex = _focusedFilterIndex;

    if (key == LogicalKeyboardKey.arrowLeft) {
      if (newIndex > 0) {
        newIndex--;
      } else if (widget.showSearchAction) {
        _searchButtonFocusNode.requestFocus();
        setState(() {
          _focusedHeaderText = 'SEARCH';
        });
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (newIndex < _filterFocusNodes.length - 1) {
        newIndex++;
      }
    } else if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.select) {
      _selectFilterByIndex(_focusedFilterIndex);
      if (_itemFocusNodes.isNotEmpty) {
        _itemFocusNodes.first.requestFocus();
        _handleItemFocused(0);
      }
      return KeyEventResult.handled;
    }

    if (newIndex != _focusedFilterIndex) {
      _filterFocusNodes[newIndex].requestFocus();
      _handleFilterFocused(newIndex);
      _scrollToFilter(newIndex);
    }

    return KeyEventResult.handled;
  }

  KeyEventResult _navigateItems(LogicalKeyboardKey key) {
    if (_isNavigationLocked) {
      return KeyEventResult.handled;
    }

    if (_focusedItemIndex < 0 || _itemFocusNodes.isEmpty) {
      return KeyEventResult.ignored;
    }

    setState(() {
      _isNavigationLocked = true;
    });
    _navigationLockTimer?.cancel();
    _navigationLockTimer = Timer(widget.navigationLockDuration, () {
      if (!_isDisposed && mounted) {
        setState(() {
          _isNavigationLocked = false;
        });
      }
    });

    int newIndex = _focusedItemIndex;
    if (key == LogicalKeyboardKey.arrowUp) {
      if (_filterFocusNodes.isNotEmpty) {
        _filterFocusNodes[_focusedFilterIndex].requestFocus();
        _handleFilterFocused(_focusedFilterIndex);
      } else if (widget.showSearchAction) {
        _searchButtonFocusNode.requestFocus();
        setState(() {
          _focusedHeaderText = 'SEARCH';
        });
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowLeft && newIndex > 0) {
      newIndex--;
    } else if (key == LogicalKeyboardKey.arrowRight &&
        newIndex < _itemFocusNodes.length - 1) {
      newIndex++;
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.select) {
      _handleSafeItemTap(_displayItems[_focusedItemIndex]);
      return KeyEventResult.handled;
    }

    if (newIndex != _focusedItemIndex) {
      _itemFocusNodes[newIndex].requestFocus();
      _handleItemFocused(newIndex);
    }

    return KeyEventResult.handled;
  }

  Future<void> _handleSafeItemTap(TItem item) async {
    await widget.onItemTap(item, List<TItem>.unmodifiable(_displayItems));

    if (_isDisposed || !mounted) {
      return;
    }

    final restoredIndex = _displayItems.indexWhere(
      (current) => widget.itemIdBuilder(current) == widget.itemIdBuilder(item),
    );
    if (restoredIndex >= 0 && restoredIndex < _itemFocusNodes.length) {
      await _scrollToItem(restoredIndex);
      _itemFocusNodes[restoredIndex].requestFocus();
      _handleItemFocused(restoredIndex);
    }
  }

  void _handleFilterFocused(int index) {
    if (_isDisposed || !mounted || index < 0 || index >= _filters.length) {
      return;
    }

    setState(() {
      _focusedFilterIndex = index;
      _focusedHeaderText = widget.filterLabelBuilder(_filters[index]).toUpperCase();
    });
  }

  void _handleItemFocused(int index) {
    if (_isDisposed || !mounted || index < 0 || index >= _displayItems.length) {
      return;
    }

    setState(() {
      _focusedItemIndex = index;
      _focusedHeaderText = widget.itemTitleBuilder(_displayItems[index]).toUpperCase();
    });
    _scrollToItem(index);
  }

  void _selectFilterByIndex(int index) {
    if (index < 0 || index >= _filters.length) {
      return;
    }

    setState(() {
      _focusedFilterIndex = index;
      _selectedFilterId = widget.filterIdBuilder(_filters[index]);
      _applyFilters();
      _focusedItemIndex = _displayItems.isEmpty ? -1 : 0;
      _rebuildFocusNodes();
    });
  }

  KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    final keyboardHasFocus = _keyboardFocusNodes.any((focusNode) => focusNode.hasFocus);
    final filtersHaveFocus = _filterFocusNodes.any((focusNode) => focusNode.hasFocus);
    final itemsHaveFocus = _itemFocusNodes.any((focusNode) => focusNode.hasFocus);
    final searchHasFocus = _searchButtonFocusNode.hasFocus;

    if (key == LogicalKeyboardKey.goBack) {
      if (_showKeyboard) {
        setState(() {
          _showKeyboard = false;
          _focusedKeyRow = 0;
          _focusedKeyCol = 0;
        });
        _searchButtonFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (keyboardHasFocus && _showKeyboard) {
      return _navigateKeyboard(key);
    }
    if (searchHasFocus) {
      return _navigateFromSearch(key);
    }
    if (filtersHaveFocus) {
      return _navigateFilters(key);
    }
    if (itemsHaveFocus) {
      return _navigateItems(key);
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCardWidth = widget.cardWidth ?? (bannerwdt ?? MediaQuery.of(context).size.width * 0.18);
    final effectiveCardHeight = widget.cardHeight ?? (bannerhgt ?? MediaQuery.of(context).size.height * 0.2);
    final effectiveTopBarHeight = widget.topBarHeight ?? MediaQuery.of(context).padding.top + 60;

    return CommonSliderScreen(
      backgroundColor: widget.backgroundColor,
      focusNode: _rootFocusNode,
      onKey: _onKeyHandler,
      background: _buildBackground(),
      isLoading: _isLoading,
      loadingWidget: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      errorWidget: _error == null
          ? null
          : (widget.errorBuilder?.call(context, _error, _loadData) ??
              Center(
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              )),
      content: CommonBottomAlignedSliderContent(
        topBar: _buildHeader(),
        topBarHeight: effectiveTopBarHeight,
        fadeAnimation: _fadeAnimation,
        searchSection: _buildSearchSection(),
        showSearchSection: _showKeyboard,
        searchSectionHeight: widget.searchSectionHeight,
        sliderIndicators: CommonSliderIndicatorRow(
          count: _banners.length,
          currentIndex: _currentBannerIndex,
          activeColor: widget.focusColors.isNotEmpty ? widget.focusColors.first : Colors.white,
        ),
        filtersBar: _buildActionBar(),
        gapAfterIndicators: widget.gapAfterIndicators,
        gapBeforeList: widget.gapBeforeList,
        listSection: SizedBox(
          height: effectiveCardHeight + 50,
          child: _buildItemsList(effectiveCardWidth, effectiveCardHeight),
        ),
        bottomSpacing: widget.bottomSpacing,
      ),
      overlay: widget.overlay,
    );
  }

  Widget _buildBackground() {
    if (_banners.isEmpty) {
      return Container(color: widget.backgroundColor);
    }

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              if (!_isDisposed && mounted) {
                setState(() {
                  _currentBannerIndex = index;
                });
              }
            },
            itemBuilder: (context, index) {
              return Image.network(
                _banners[index].imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: widget.backgroundColor),
              );
            },
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    widget.backgroundColor.withOpacity(0.55),
                    widget.backgroundColor,
                  ],
                  stops: const [0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return CommonSliderTitleHeader(
      title: widget.pageTitle,
      focusedText: _focusedHeaderText,
      titleGradient: widget.titleGradient,
      trailingImageUrl: _resolvedTrailingImageUrl,
      trailingImageHeight: widget.trailingImageHeight,
      padding: widget.headerPadding,
      backgroundGradient: widget.headerBackgroundGradient,
      border: widget.headerBorder,
    );
  }

  Widget _buildActionBar() {
    final items = <CommonSliderActionItemData>[];

    if (widget.showSearchAction) {
      items.add(
        buildCommonSliderSearchAction(
          focusNode: _searchButtonFocusNode,
          isSelected: _isSearching,
          focusColor: widget.searchActionColor,
          onFocusChange: (hasFocus) {
            if (hasFocus && mounted) {
              setState(() {
                _focusedHeaderText = 'SEARCH';
              });
            }
          },
          onTap: () {
            if (!_isDisposed) {
              setState(() {
                _showKeyboard = true;
                _focusedKeyRow = 0;
                _focusedKeyCol = 0;
              });
            }
          },
        ),
      );
    }

    items.addAll(
      buildCommonSliderActionItems<TFilter>(
        items: _filters,
        focusNodes: _filterFocusNodes,
        labelBuilder: widget.filterLabelBuilder,
        isSelectedBuilder: (filter) =>
            widget.filterIdBuilder(filter) == _selectedFilterId && !_isSearching,
        focusColorBuilder: (index, _) => widget.focusColors[index % widget.focusColors.length],
        onTapBuilder: (index, _, focusNode) => () {
          focusNode.requestFocus();
          _selectFilterByIndex(index);
        },
        onFocusChangeBuilder: (index, filter, _) => (hasFocus) {
          if (hasFocus) {
            _handleFilterFocused(index);
          }
        },
      ),
    );

    return CommonSliderActionBar(
      items: items,
      controller: _filterScrollController,
      padding: widget.actionBarPadding,
      height: widget.actionBarHeight,
    );
  }

  Widget _buildItemsList(double width, double height) {
    return CommonSliderPosterList<TItem>(
      items: _displayItems,
      focusNodes: _itemFocusNodes,
      focusedIndex: _focusedItemIndex,
      controller: _itemScrollController,
      padding: widget.listPadding,
      clipBehavior: Clip.none,
      cardWidth: width,
      cardHeight: height,
      titleBuilder: widget.itemTitleBuilder,
      imageUrlBuilder: widget.itemImageUrlBuilder,
      onTapBuilder: (item) => () => _handleSafeItemTap(item),
      onItemFocused: (index, _) => _handleItemFocused(index),
      focusColorBuilder: (index, _) => widget.focusColors[index % widget.focusColors.length],
      networkLogoBuilder: widget.itemNetworkLogoBuilder,
      placeholderIcon: widget.placeholderIcon,
      placeholderGradientColors: widget.placeholderGradientColors,
      placeholderBackgroundColor: widget.placeholderBackgroundColor,
      useCachedImage: widget.useCachedImage,
      itemMargin: widget.itemMargin,
      titlePadding: widget.titlePadding,
      titleSpacing: widget.titleSpacing,
      titleFontSize: widget.titleFontSize,
      focusedTitleFontWeight: widget.focusedTitleFontWeight,
      unfocusedTitleFontWeight: widget.unfocusedTitleFontWeight,
      focusedTitleColor: widget.focusedTitleColor,
      unfocusedTitleColor: widget.unfocusedTitleColor,
      titleTextAlign: widget.titleTextAlign,
      titleMaxLines: widget.titleMaxLines,
      cardCrossAxisAlignment: widget.cardCrossAxisAlignment,
      showFocusedScrim: widget.showFocusedScrim,
      focusedScrimOpacity: widget.focusedScrimOpacity,
      focusedIconAlignment: widget.focusedIconAlignment,
      focusedIconPadding: widget.focusedIconPadding,
      focusedIconBackgroundColor: widget.focusedIconBackgroundColor,
      focusedIconInnerPadding: widget.focusedIconInnerPadding,
      focusedIcon: widget.focusedIcon,
      focusedIconSize: widget.focusedIconSize,
      borderRadius: widget.borderRadius,
      imageBorderRadius: widget.imageBorderRadius,
      emptyState: widget.emptyStateBuilder?.call(
            context,
            _isSearching,
            _searchText,
          ) ??
          Center(
            child: Text(
              _isSearching && _searchText.isNotEmpty
                  ? "No results found for '$_searchText'"
                  : 'No items available.',
              style: const TextStyle(color: Colors.white54),
            ),
          ),
    );
  }

  Widget _buildSearchSection() {
    return CommonSliderSearchPanel(
      text: _searchText,
      keyboardLayout: widget.keyboardLayout,
      focusedRow: _focusedKeyRow,
      focusedCol: _focusedKeyCol,
      focusNodes: _keyboardFocusNodes,
      focusColor: widget.searchFocusColor,
      padding: widget.actionBarPadding,
      margin: const EdgeInsets.only(bottom: 20),
    );
  }
}






