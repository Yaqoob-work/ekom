import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/components/widgets/common_managed_local_slider_screen.dart';
import 'package:mobi_tv_entertainment/components/widgets/common_slider_screen.dart';
import 'package:mobi_tv_entertainment/main.dart';

class CommonManagedSliderOption<T> {
  final String id;
  final String label;
  final T value;
  final String? imageUrl;

  const CommonManagedSliderOption({
    required this.id,
    required this.label,
    required this.value,
    this.imageUrl,
  });
}

class CommonManagedTabbedSliderSection<TFilter, TItem> {
  final List<CommonManagedSliderBanner> banners;
  final List<CommonManagedSliderOption<TFilter>> filters;
  final List<TItem> items;
  final String? initialFilterId;
  final String? backgroundImageUrl;

  const CommonManagedTabbedSliderSection({
    this.banners = const [],
    this.filters = const [],
    this.items = const [],
    this.initialFilterId,
    this.backgroundImageUrl,
  });
}

class CommonManagedTabbedSliderData<TTab, TFilter, TItem> {
  final List<CommonManagedSliderOption<TTab>> tabs;
  final String? initialTabId;
  final CommonManagedTabbedSliderSection<TFilter, TItem> initialSection;

  const CommonManagedTabbedSliderData({
    this.tabs = const [],
    this.initialTabId,
    required this.initialSection,
  });
}

class CommonManagedTabbedSliderScreen<TTab, TFilter, TItem>
    extends StatefulWidget {
  final Color backgroundColor;
  final Future<CommonManagedTabbedSliderData<TTab, TFilter, TItem>> Function()
      fetchInitialData;
  final Future<CommonManagedTabbedSliderSection<TFilter, TItem>> Function(
    CommonManagedSliderOption<TTab> tab,
  ) onTabSelected;
  final Future<List<TItem>> Function(
    CommonManagedSliderOption<TFilter> filter,
    CommonManagedSliderOption<TTab> tab,
  ) onFilterSelected;
  final Future<void> Function(TItem item, List<TItem> visibleItems) onItemTap;
  final String Function(TItem item) itemIdBuilder;
  final String Function(TItem item) itemTitleBuilder;
  final String? Function(TItem item) itemImageUrlBuilder;
  final String? Function(TItem item)? itemSearchTextBuilder;
  final String? Function(TItem item)? itemNetworkLogoBuilder;
  final IconData placeholderIcon;
  final List<Color> focusColors;
  final Color searchActionColor;
  final Color searchFocusColor;
  final bool showSearchAction;
  final bool useCachedImage;
  final BoxFit imageFit;
  final List<Color>? placeholderGradientColors;
  final Color? placeholderBackgroundColor;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry tabsPadding;
  final double tabsHeight;
  final EdgeInsetsGeometry actionBarPadding;
  final double actionBarHeight;
  final double searchSectionHeight;
  final double gapAfterIndicators;
  final double gapBeforeList;
  final double bottomSpacing;
  final double? cardWidth;
  final double? cardHeight;
  final double? listSectionHeight;
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
  final Widget? loadingWidget;
  final Widget Function(BuildContext context, String? error, VoidCallback retry)?
      errorBuilder;
  final Widget Function(BuildContext context, bool isSearching, String searchText)?
      emptyStateBuilder;
  final Widget Function(BuildContext context, bool isBusy)? overlayBuilder;

  const CommonManagedTabbedSliderScreen({
    super.key,
    required this.fetchInitialData,
    required this.onTabSelected,
    required this.onFilterSelected,
    required this.onItemTap,
    required this.itemIdBuilder,
    required this.itemTitleBuilder,
    required this.itemImageUrlBuilder,
    required this.placeholderIcon,
    required this.focusColors,
    this.backgroundColor = Colors.black,
    this.itemSearchTextBuilder,
    this.itemNetworkLogoBuilder,
    this.searchActionColor = const Color(0xFFF59E0B),
    this.searchFocusColor = const Color(0xFF8B5CF6),
    this.showSearchAction = true,
    this.useCachedImage = false,
    this.imageFit = BoxFit.cover,
    this.placeholderGradientColors,
    this.placeholderBackgroundColor,
    this.contentPadding = EdgeInsets.zero,
    this.tabsPadding = const EdgeInsets.only(left: 16, right: 0),
    this.tabsHeight = 30,
    this.actionBarPadding = const EdgeInsets.symmetric(horizontal: 40),
    this.actionBarHeight = 38,
    this.searchSectionHeight = 200,
    this.gapAfterIndicators = 0,
    this.gapBeforeList = 15,
    this.bottomSpacing = 0,
    this.cardWidth,
    this.cardHeight,
    this.listSectionHeight,
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
    this.loadingWidget,
    this.errorBuilder,
    this.emptyStateBuilder,
    this.overlayBuilder,
  });

  @override
  State<CommonManagedTabbedSliderScreen<TTab, TFilter, TItem>> createState() =>
      _CommonManagedTabbedSliderScreenState<TTab, TFilter, TItem>();
}

class _CommonManagedTabbedSliderScreenState<TTab, TFilter, TItem>
    extends State<CommonManagedTabbedSliderScreen<TTab, TFilter, TItem>> {
  bool _isLoading = true;
  bool _isDisposed = false;
  bool _isBusy = false;
  bool _isSearching = false;
  bool _showKeyboard = false;
  bool _isNavigationLocked = false;
  String? _error;
  String _searchText = '';
  String? _selectedTabId;
  String? _selectedFilterId;
  int _focusedTabIndex = 0;
  int _focusedFilterIndex = 0;
  int _focusedItemIndex = -1;
  int _focusedKeyRow = 0;
  int _focusedKeyCol = 0;
  int _currentBannerIndex = 0;

  List<CommonManagedSliderOption<TTab>> _tabs = [];
  List<CommonManagedSliderOption<TFilter>> _filters = [];
  List<TItem> _baseItems = [];
  List<TItem> _displayItems = [];
  List<CommonManagedSliderBanner> _banners = [];
  String? _backgroundImageUrl;

  final FocusNode _rootFocusNode = FocusNode();
  final FocusNode _searchButtonFocusNode = FocusNode();
  final ScrollController _tabsScrollController = ScrollController();
  final ScrollController _filterScrollController = ScrollController();
  final ScrollController _itemScrollController = ScrollController();
  late final PageController _bannerController;

  List<FocusNode> _tabFocusNodes = [];
  List<FocusNode> _filterFocusNodes = [];
  List<FocusNode> _itemFocusNodes = [];
  List<FocusNode> _keyboardFocusNodes = [];

  Timer? _bannerTimer;
  Timer? _navigationLockTimer;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _loadInitialData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _bannerTimer?.cancel();
    _navigationLockTimer?.cancel();
    _rootFocusNode.dispose();
    _searchButtonFocusNode.dispose();
    _tabsScrollController.dispose();
    _filterScrollController.dispose();
    _itemScrollController.dispose();
    _bannerController.dispose();
    _disposeFocusNodes(_tabFocusNodes);
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

  Future<void> _loadInitialData() async {
    if (_isDisposed) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await widget.fetchInitialData();
      if (_isDisposed || !mounted) {
        return;
      }

      _tabs = data.tabs;
      _selectedTabId = data.initialTabId ?? (_tabs.isNotEmpty ? _tabs.first.id : null);
      _focusedTabIndex = _tabs.indexWhere((tab) => tab.id == _selectedTabId);
      if (_focusedTabIndex < 0) {
        _focusedTabIndex = 0;
      }

      _disposeFocusNodes(_tabFocusNodes);
      _tabFocusNodes = List.generate(_tabs.length, (_) => FocusNode());

      _applySection(data.initialSection, resetSearch: true);
      _setupBannerTimer();

      setState(() {
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed &&
            mounted &&
            _tabFocusNodes.isNotEmpty &&
            _focusedTabIndex < _tabFocusNodes.length) {
          _tabFocusNodes[_focusedTabIndex].requestFocus();
          _scrollToTab(_focusedTabIndex);
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

  void _applySection(
    CommonManagedTabbedSliderSection<TFilter, TItem> section, {
    bool resetSearch = false,
  }) {
    _filters = section.filters;
    _baseItems = section.items;
    _banners = section.banners.where((banner) => banner.imageUrl.isNotEmpty).toList();
    _backgroundImageUrl = section.backgroundImageUrl;
    _selectedFilterId = section.initialFilterId ?? (_filters.isNotEmpty ? _filters.first.id : null);
    _focusedFilterIndex = _filters.indexWhere((filter) => filter.id == _selectedFilterId);
    if (_focusedFilterIndex < 0) {
      _focusedFilterIndex = _filters.isEmpty ? -1 : 0;
    }
    _currentBannerIndex = 0;
    if (resetSearch) {
      _searchText = '';
      _isSearching = false;
      _showKeyboard = false;
    }
    _applySearch();
    _rebuildSectionFocusNodes();
  }

  void _rebuildSectionFocusNodes() {
    _disposeFocusNodes(_filterFocusNodes);
    _disposeFocusNodes(_itemFocusNodes);
    _disposeFocusNodes(_keyboardFocusNodes);

    _filterFocusNodes = List.generate(_filters.length, (_) => FocusNode());
    _itemFocusNodes = List.generate(_displayItems.length, (_) => FocusNode());
    final totalKeyboardKeys = widget.keyboardLayout.fold<int>(0, (sum, row) => sum + row.length);
    _keyboardFocusNodes = List.generate(totalKeyboardKeys, (_) => FocusNode());
  }

  void _applySearch() {
    final normalizedSearch = _searchText.trim().toLowerCase();
    if (normalizedSearch.isEmpty) {
      _displayItems = List<TItem>.from(_baseItems);
      return;
    }

    _displayItems = _baseItems.where((item) {
      final searchValue =
          (widget.itemSearchTextBuilder?.call(item) ?? widget.itemTitleBuilder(item))
              .toLowerCase();
      return searchValue.contains(normalizedSearch);
    }).toList();
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

  CommonManagedSliderOption<TTab>? get _selectedTab {
    if (_tabs.isEmpty || _selectedTabId == null) {
      return null;
    }
    final index = _tabs.indexWhere((tab) => tab.id == _selectedTabId);
    if (index < 0 || index >= _tabs.length) {
      return null;
    }
    return _tabs[index];
  }

  Future<void> _selectTab(int index) async {
    if (index < 0 || index >= _tabs.length || _isBusy) {
      return;
    }

    final tab = _tabs[index];
    setState(() {
      _isBusy = true;
      _focusedTabIndex = index;
      _selectedTabId = tab.id;
      _focusedItemIndex = -1;
    });

    try {
      final section = await widget.onTabSelected(tab);
      if (_isDisposed || !mounted) {
        return;
      }

      setState(() {
        _applySection(section, resetSearch: true);
        _isBusy = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed &&
            mounted &&
            index < _tabFocusNodes.length &&
            _tabFocusNodes[index].canRequestFocus) {
          _tabFocusNodes[index].requestFocus();
          _scrollToTab(index);
        }
      });
    } catch (error) {
      if (_isDisposed || !mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _isBusy = false;
      });
    }
  }

  Future<void> _selectFilter(int index) async {
    final selectedTab = _selectedTab;
    if (selectedTab == null || index < 0 || index >= _filters.length || _isBusy) {
      return;
    }

    final filter = _filters[index];
    setState(() {
      _isBusy = true;
      _focusedFilterIndex = index;
      _selectedFilterId = filter.id;
      _focusedItemIndex = -1;
    });

    try {
      final items = await widget.onFilterSelected(filter, selectedTab);
      if (_isDisposed || !mounted) {
        return;
      }

      setState(() {
        _baseItems = items;
        _applySearch();
        _disposeFocusNodes(_itemFocusNodes);
        _itemFocusNodes = List.generate(_displayItems.length, (_) => FocusNode());
        _isBusy = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed &&
            mounted &&
            index < _filterFocusNodes.length &&
            _filterFocusNodes[index].canRequestFocus) {
          _filterFocusNodes[index].requestFocus();
          _scrollToFilter(index);
        }
      });
    } catch (error) {
      if (_isDisposed || !mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _isBusy = false;
      });
    }
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

  Future<void> _scrollToTab(int index) async {
    if (!_tabsScrollController.hasClients || index < 0) {
      return;
    }

    const estimatedWidth = 170.0;
    final target = index * estimatedWidth;
    await _tabsScrollController.animateTo(
      target.clamp(0.0, _tabsScrollController.position.maxScrollExtent).toDouble(),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _scrollToFilter(int index) async {
    if (!_filterScrollController.hasClients || index < 0) {
      return;
    }

    const estimatedWidth = 170.0;
    final target = index * estimatedWidth;
    await _filterScrollController.animateTo(
      target.clamp(0.0, _filterScrollController.position.maxScrollExtent).toDouble(),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
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

  void _handleItemFocused(int index) {
    if (_isDisposed || !mounted || index < 0 || index >= _displayItems.length) {
      return;
    }
    setState(() {
      _focusedItemIndex = index;
    });
    _scrollToItem(index);
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
      _applySearch();
      _disposeFocusNodes(_itemFocusNodes);
      _itemFocusNodes = List.generate(_displayItems.length, (_) => FocusNode());
      _focusedItemIndex = _displayItems.isEmpty ? -1 : 0;
    });

    if (key == 'OK') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_displayItems.isNotEmpty && _itemFocusNodes.isNotEmpty) {
          _itemFocusNodes.first.requestFocus();
          _handleItemFocused(0);
        } else {
          _searchButtonFocusNode.requestFocus();
        }
      });
    }
  }

  int _keyboardFocusIndex(int row, int col) {
    int index = 0;
    for (int i = 0; i < row; i++) {
      index += widget.keyboardLayout[i].length;
    }
    return index + col;
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

  KeyEventResult _navigateTabs(LogicalKeyboardKey key) {
    int newIndex = _focusedTabIndex;

    if (key == LogicalKeyboardKey.arrowLeft) {
      if (newIndex > 0) {
        newIndex--;
      }
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (newIndex < _tabFocusNodes.length - 1) {
        newIndex++;
      }
    } else if (key == LogicalKeyboardKey.arrowDown) {
      if (widget.showSearchAction) {
        _searchButtonFocusNode.requestFocus();
      } else if (_filterFocusNodes.isNotEmpty) {
        final focusIndex =
            _focusedFilterIndex.clamp(0, _filterFocusNodes.length - 1).toInt();
        _filterFocusNodes[focusIndex].requestFocus();
      } else if (_itemFocusNodes.isNotEmpty) {
        _itemFocusNodes.first.requestFocus();
        _handleItemFocused(0);
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.select) {
      _selectTab(_focusedTabIndex);
      return KeyEventResult.handled;
    }

    if (newIndex != _focusedTabIndex) {
      setState(() => _focusedTabIndex = newIndex);
      _tabFocusNodes[newIndex].requestFocus();
      _scrollToTab(newIndex);
    }

    return KeyEventResult.handled;
  }

  KeyEventResult _navigateSearch(LogicalKeyboardKey key) {
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

    if (key == LogicalKeyboardKey.arrowUp && _tabFocusNodes.isNotEmpty) {
      _tabFocusNodes[_focusedTabIndex].requestFocus();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowRight && _filterFocusNodes.isNotEmpty) {
      final focusIndex =
            _focusedFilterIndex.clamp(0, _filterFocusNodes.length - 1).toInt();
      _filterFocusNodes[focusIndex].requestFocus();
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
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (newIndex < _filterFocusNodes.length - 1) {
        newIndex++;
      }
    } else if (key == LogicalKeyboardKey.arrowUp) {
      if (_tabFocusNodes.isNotEmpty) {
        _tabFocusNodes[_focusedTabIndex].requestFocus();
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      if (_itemFocusNodes.isNotEmpty) {
        _itemFocusNodes.first.requestFocus();
        _handleItemFocused(0);
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.select) {
      _selectFilter(_focusedFilterIndex);
      return KeyEventResult.handled;
    }

    if (newIndex != _focusedFilterIndex &&
        newIndex >= 0 &&
        newIndex < _filterFocusNodes.length) {
      setState(() => _focusedFilterIndex = newIndex);
      _filterFocusNodes[newIndex].requestFocus();
      _scrollToFilter(newIndex);
    }

    return KeyEventResult.handled;
  }

  KeyEventResult _navigateItems(LogicalKeyboardKey key) {
    if (_isNavigationLocked || _focusedItemIndex < 0 || _itemFocusNodes.isEmpty) {
      return KeyEventResult.handled;
    }

    setState(() => _isNavigationLocked = true);
    _navigationLockTimer?.cancel();
    _navigationLockTimer = Timer(widget.navigationLockDuration, () {
      if (!_isDisposed && mounted) {
        setState(() => _isNavigationLocked = false);
      }
    });

    int newIndex = _focusedItemIndex;
    if (key == LogicalKeyboardKey.arrowUp) {
      if (_filterFocusNodes.isNotEmpty) {
        final focusIndex =
            _focusedFilterIndex.clamp(0, _filterFocusNodes.length - 1).toInt();
        _filterFocusNodes[focusIndex].requestFocus();
      } else if (widget.showSearchAction) {
        _searchButtonFocusNode.requestFocus();
      } else if (_tabFocusNodes.isNotEmpty) {
        _tabFocusNodes[_focusedTabIndex].requestFocus();
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

  KeyEventResult _onKeyHandler(FocusNode node, RawKeyEvent event) {
    if (event is! RawKeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    final keyboardHasFocus = _keyboardFocusNodes.any((focusNode) => focusNode.hasFocus);
    final tabHasFocus = _tabFocusNodes.any((focusNode) => focusNode.hasFocus);
    final filterHasFocus = _filterFocusNodes.any((focusNode) => focusNode.hasFocus);
    final itemHasFocus = _itemFocusNodes.any((focusNode) => focusNode.hasFocus);
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
      return _navigateSearch(key);
    }
    if (tabHasFocus) {
      return _navigateTabs(key);
    }
    if (filterHasFocus) {
      return _navigateFilters(key);
    }
    if (itemHasFocus) {
      return _navigateItems(key);
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCardWidth = widget.cardWidth ?? (bannerwdt ?? MediaQuery.of(context).size.width * 0.18);
    final effectiveCardHeight = widget.cardHeight ?? (bannerhgt ?? MediaQuery.of(context).size.height * 0.2);
    final effectiveListSectionHeight = widget.listSectionHeight ?? (effectiveCardHeight + 50);

    return CommonSliderScreen(
      backgroundColor: widget.backgroundColor,
      focusNode: _rootFocusNode,
      onKey: _onKeyHandler,
      background: _buildBackground(),
      isLoading: _isLoading,
      loadingWidget: widget.loadingWidget ?? const Center(child: CircularProgressIndicator(color: Colors.white)),
      errorWidget: _error == null
          ? null
          : (widget.errorBuilder?.call(context, _error, _loadInitialData) ??
              Center(
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              )),
      content: CommonTopAlignedSliderContent(
        padding: widget.contentPadding,
        header: _buildTabsBar(),
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
        bottomSpacing: widget.bottomSpacing,
        listSection: SizedBox(
          height: effectiveListSectionHeight,
          child: _buildItemsList(effectiveCardWidth, effectiveCardHeight),
        ),
      ),
      overlay: widget.overlayBuilder?.call(context, _isBusy),
    );
  }

  Widget _buildBackground() {
    if (_banners.isNotEmpty) {
      return RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _bannerController,
              itemCount: _banners.length,
              onPageChanged: (index) {
                if (!_isDisposed && mounted) {
                  setState(() => _currentBannerIndex = index);
                }
              },
              itemBuilder: (context, index) {
                return Image.network(
                  _banners[index].imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: widget.backgroundColor),
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
                      widget.backgroundColor.withOpacity(0.15),
                      widget.backgroundColor.withOpacity(0.45),
                      widget.backgroundColor.withOpacity(0.75),
                      widget.backgroundColor,
                    ],
                    stops: const [0.0, 0.45, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_backgroundImageUrl != null && _backgroundImageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _backgroundImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: widget.backgroundColor),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.backgroundColor.withOpacity(0.2),
                    widget.backgroundColor.withOpacity(0.45),
                    widget.backgroundColor.withOpacity(0.75),
                    widget.backgroundColor,
                  ],
                  stops: const [0.0, 0.45, 0.7, 1.0],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Container(color: widget.backgroundColor);
  }

  Widget _buildTabsBar() {
    return CommonSliderTopTabsBar(
      items: [
        for (int index = 0; index < _tabs.length; index++)
          CommonSliderTabItemData(
            label: _tabs[index].label,
            focusNode: _tabFocusNodes[index],
            isSelected: _tabs[index].id == _selectedTabId,
            focusColor: widget.focusColors[index % widget.focusColors.length],
            onTap: () {
              _tabFocusNodes[index].requestFocus();
              _selectTab(index);
            },
            onFocusChange: (hasFocus) {
              if (hasFocus && mounted) {
                setState(() => _focusedTabIndex = index);
              }
            },
          ),
      ],
      controller: _tabsScrollController,
      padding: widget.tabsPadding,
      height: widget.tabsHeight,
    );
  }

  Widget _buildActionBar() {
    final items = <CommonSliderActionItemData>[];
    if (widget.showSearchAction) {
      items.add(
        buildCommonSliderSearchAction(
          focusNode: _searchButtonFocusNode,
          isSelected: _isSearching || _showKeyboard,
          focusColor: widget.searchActionColor,
          onTap: () {
            if (!_isDisposed) {
              _searchButtonFocusNode.requestFocus();
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
            }
          },
        ),
      );
    }

    items.addAll(
      buildCommonSliderActionItems<CommonManagedSliderOption<TFilter>>(
        items: _filters,
        focusNodes: _filterFocusNodes,
        labelBuilder: (filter) => filter.label,
        isSelectedBuilder: (filter) => !_isSearching && _selectedFilterId == filter.id,
        focusColorBuilder: (index, _) => widget.focusColors[index % widget.focusColors.length],
        onTapBuilder: (index, _, focusNode) => () {
          focusNode.requestFocus();
          _selectFilter(index);
        },
        onFocusChangeBuilder: (index, _, __) => (hasFocus) {
          if (hasFocus && mounted) {
            setState(() => _focusedFilterIndex = index);
          }
        },
      ),
    );

    return CommonSliderActionBar(
      items: items,
      controller: _filterScrollController,
      padding: widget.actionBarPadding,
      height: widget.actionBarHeight,
      emptyState: SizedBox(height: widget.actionBarHeight),
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
      imageFit: widget.imageFit,
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
      emptyState: widget.emptyStateBuilder?.call(context, _isSearching, _searchText) ??
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


