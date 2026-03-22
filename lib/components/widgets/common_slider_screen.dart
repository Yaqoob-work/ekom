import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommonSliderScreen extends StatelessWidget {
  final Color backgroundColor;
  final FocusNode focusNode;
  final FocusOnKeyCallback? onKey;
  final Widget background;
  final bool isLoading;
  final Widget loadingWidget;
  final Widget content;
  final Widget? errorWidget;
  final Widget? overlay;
  final bool expandStack;
  final bool centerStackChild;

  const CommonSliderScreen({
    super.key,
    required this.backgroundColor,
    required this.focusNode,
    required this.background,
    required this.isLoading,
    required this.loadingWidget,
    required this.content,
    this.onKey,
    this.errorWidget,
    this.overlay,
    this.expandStack = true,
    this.centerStackChild = false,
  });

  @override
  Widget build(BuildContext context) {
    final stack = Stack(
      fit: expandStack ? StackFit.expand : StackFit.loose,
      children: [
        background,
        if (isLoading)
          loadingWidget
        else if (errorWidget != null)
          errorWidget!
        else
          content,
        if (overlay != null) overlay!,
      ],
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Focus(
        focusNode: focusNode,
        autofocus: true,
        onKey: onKey,
        child: centerStackChild ? Center(child: stack) : stack,
      ),
    );
  }
}

class CommonTopAlignedSliderContent extends StatelessWidget {
  final Widget header;
  final Widget listSection;
  final EdgeInsetsGeometry padding;
  final Animation<double>? fadeAnimation;
  final Widget? searchSection;
  final bool showSearchSection;
  final double searchSectionHeight;
  final Widget? sliderIndicators;
  final Widget? filtersBar;
  final double gapAfterIndicators;
  final double gapBeforeList;
  final double bottomSpacing;

  const CommonTopAlignedSliderContent({
    super.key,
    required this.header,
    required this.listSection,
    this.padding = EdgeInsets.zero,
    this.fadeAnimation,
    this.searchSection,
    this.showSearchSection = false,
    this.searchSectionHeight = 0,
    this.sliderIndicators,
    this.filtersBar,
    this.gapAfterIndicators = 10,
    this.gapBeforeList = 15,
    this.bottomSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        if (searchSection != null)
          SizedBox(
            height: searchSectionHeight,
            child: showSearchSection ? searchSection! : const SizedBox.shrink(),
          ),
        if (sliderIndicators != null) sliderIndicators!,
        if (filtersBar != null) ...[
          SizedBox(height: gapAfterIndicators),
          filtersBar!,
        ],
        SizedBox(height: gapBeforeList),
        listSection,
        SizedBox(height: bottomSpacing),
      ],
    );

    return Padding(
      padding: padding,
      child: Column(
        children: [
          header,
          Expanded(
            child: fadeAnimation == null
                ? body
                : FadeTransition(
                    opacity: fadeAnimation!,
                    child: body,
                  ),
          ),
        ],
      ),
    );
  }
}

class CommonBottomAlignedSliderContent extends StatelessWidget {
  final Widget? topBar;
  final double? topBarHeight;
  final Widget listSection;
  final Animation<double>? fadeAnimation;
  final Widget? searchSection;
  final bool showSearchSection;
  final double searchSectionHeight;
  final Widget? sliderIndicators;
  final Widget? filtersBar;
  final double gapAfterIndicators;
  final double gapBeforeList;
  final double bottomSpacing;

  const CommonBottomAlignedSliderContent({
    super.key,
    this.topBar,
    this.topBarHeight,
    required this.listSection,
    this.fadeAnimation,
    this.searchSection,
    this.showSearchSection = false,
    this.searchSectionHeight = 0,
    this.sliderIndicators,
    this.filtersBar,
    this.gapAfterIndicators = 10,
    this.gapBeforeList = 15,
    this.bottomSpacing = 15,
  });

  @override
  Widget build(BuildContext context) {
    final body = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (topBar != null)
          topBarHeight == null
              ? topBar!
              : SizedBox(height: topBarHeight, child: topBar),
        const Spacer(),
        if (searchSection != null)
          SizedBox(
            height: searchSectionHeight,
            child: showSearchSection ? searchSection! : const SizedBox.shrink(),
          ),
        if (sliderIndicators != null) sliderIndicators!,
        if (filtersBar != null) ...[
          SizedBox(height: gapAfterIndicators),
          filtersBar!,
        ],
        SizedBox(height: gapBeforeList),
        listSection,
        SizedBox(height: bottomSpacing),
      ],
    );

    return fadeAnimation == null
        ? body
        : FadeTransition(
            opacity: fadeAnimation!,
            child: body,
          );
  }
}

class CommonSliderTitleHeader extends StatelessWidget {
  final String title;
  final String focusedText;
  final List<Color> titleGradient;
  final EdgeInsetsGeometry padding;
  final double titleFontSize;
  final double focusedFontSize;
  final FontWeight focusedFontWeight;
  final Color focusedTextColor;
  final String? trailingImageUrl;
  final double? trailingImageHeight;
  final bool blurBackground;
  final List<Color>? backgroundGradient;
  final Border? border;

  const CommonSliderTitleHeader({
    super.key,
    required this.title,
    required this.focusedText,
    required this.titleGradient,
    this.padding = const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    this.titleFontSize = 26,
    this.focusedFontSize = 20,
    this.focusedFontWeight = FontWeight.w600,
    this.focusedTextColor = const Color(0xFFB3B3B3),
    this.trailingImageUrl,
    this.trailingImageHeight,
    this.blurBackground = false,
    this.backgroundGradient,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: backgroundGradient == null
            ? null
            : LinearGradient(
                colors: backgroundGradient!,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        border: border,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: titleGradient,
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              focusedText,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: focusedTextColor,
                fontWeight: focusedFontWeight,
                fontSize: focusedFontSize,
              ),
            ),
          ),
          if (trailingImageUrl != null && trailingImageUrl!.isNotEmpty)
            SizedBox(
              height: trailingImageHeight,
              child: Image.network(
                trailingImageUrl!,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );

    if (!blurBackground) return content;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: content,
      ),
    );
  }
}

class CommonSliderTabItemData {
  final String label;
  final FocusNode focusNode;
  final bool isSelected;
  final Color focusColor;
  final VoidCallback onTap;
  final ValueChanged<bool>? onFocusChange;

  const CommonSliderTabItemData({
    required this.label,
    required this.focusNode,
    required this.isSelected,
    required this.focusColor,
    required this.onTap,
    this.onFocusChange,
  });
}

class CommonSliderActionItemData {
  final String label;
  final FocusNode focusNode;
  final bool isSelected;
  final Color focusColor;
  final VoidCallback onTap;
  final ValueChanged<bool>? onFocusChange;
  final IconData? icon;

  const CommonSliderActionItemData({
    required this.label,
    required this.focusNode,
    required this.isSelected,
    required this.focusColor,
    required this.onTap,
    this.onFocusChange,
    this.icon,
  });
}

List<CommonSliderTabItemData> buildCommonSliderTabItems<T>({
  required List<T> items,
  required List<FocusNode> focusNodes,
  required String Function(T item) labelBuilder,
  required bool Function(T item) isSelectedBuilder,
  required Color Function(int index, T item) focusColorBuilder,
  required VoidCallback Function(int index, T item, FocusNode focusNode)
      onTapBuilder,
  ValueChanged<bool>? Function(int index, T item, FocusNode focusNode)?
      onFocusChangeBuilder,
}) {
  final mappedItems = <CommonSliderTabItemData>[];

  for (int index = 0; index < items.length; index++) {
    if (index >= focusNodes.length) {
      continue;
    }

    final item = items[index];
    final focusNode = focusNodes[index];
    mappedItems.add(
      CommonSliderTabItemData(
        label: labelBuilder(item),
        focusNode: focusNode,
        isSelected: isSelectedBuilder(item),
        focusColor: focusColorBuilder(index, item),
        onTap: onTapBuilder(index, item, focusNode),
        onFocusChange: onFocusChangeBuilder?.call(index, item, focusNode),
      ),
    );
  }

  return mappedItems;
}

CommonSliderActionItemData buildCommonSliderSearchAction({
  required FocusNode focusNode,
  required bool isSelected,
  required Color focusColor,
  required VoidCallback onTap,
  ValueChanged<bool>? onFocusChange,
  String label = 'Search',
  IconData icon = Icons.search,
}) {
  return CommonSliderActionItemData(
    label: label,
    focusNode: focusNode,
    isSelected: isSelected,
    focusColor: focusColor,
    onTap: onTap,
    onFocusChange: onFocusChange,
    icon: icon,
  );
}

List<CommonSliderActionItemData> buildCommonSliderActionItems<T>({
  required List<T> items,
  required List<FocusNode> focusNodes,
  required String Function(T item) labelBuilder,
  required bool Function(T item) isSelectedBuilder,
  required Color Function(int index, T item) focusColorBuilder,
  required VoidCallback Function(int index, T item, FocusNode focusNode)
      onTapBuilder,
  ValueChanged<bool>? Function(int index, T item, FocusNode focusNode)?
      onFocusChangeBuilder,
  List<CommonSliderActionItemData> leadingItems = const [],
}) {
  final mappedItems = <CommonSliderActionItemData>[...leadingItems];

  for (int index = 0; index < items.length; index++) {
    if (index >= focusNodes.length) {
      continue;
    }

    final item = items[index];
    final focusNode = focusNodes[index];
    mappedItems.add(
      CommonSliderActionItemData(
        label: labelBuilder(item),
        focusNode: focusNode,
        isSelected: isSelectedBuilder(item),
        focusColor: focusColorBuilder(index, item),
        onTap: onTapBuilder(index, item, focusNode),
        onFocusChange: onFocusChangeBuilder?.call(index, item, focusNode),
      ),
    );
  }

  return mappedItems;
}
class CommonSliderTopTabsBar extends StatelessWidget {
  final List<CommonSliderTabItemData> items;
  final ScrollController? controller;
  final EdgeInsetsGeometry padding;
  final double height;
  final double topPadding;
  final double bottomPadding;
  final Color borderColor;

  const CommonSliderTopTabsBar({
    super.key,
    required this.items,
    this.controller,
    this.padding = const EdgeInsets.only(left: 16, right: 0),
    this.height = 30,
    this.topPadding = 5,
    this.bottomPadding = 5,
    this.borderColor = const Color.fromRGBO(255, 255, 255, 0.1),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + topPadding,
            bottom: bottomPadding,
          ).add(padding.resolve(Directionality.of(context))),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: borderColor, width: 1),
            ),
          ),
          child: SizedBox(
            height: height,
            child: ListView.builder(
              controller: controller,
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _CommonGlassButton(
                  focusNode: item.focusNode,
                  isSelected: item.isSelected,
                  focusColor: item.focusColor,
                  onTap: item.onTap,
                  onFocusChange: item.onFocusChange,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item.label.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: item.focusNode.hasFocus || item.isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CommonSliderActionBar extends StatelessWidget {
  final List<CommonSliderActionItemData> items;
  final ScrollController? controller;
  final EdgeInsetsGeometry padding;
  final double height;
  final Widget? emptyState;

  const CommonSliderActionBar({
    super.key,
    required this.items,
    this.controller,
    this.padding = const EdgeInsets.symmetric(horizontal: 40),
    this.height = 38,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return emptyState ?? SizedBox(height: height);
    }

    return SizedBox(
      height: height,
      child: Center(
        child: ListView.builder(
          controller: controller,
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          padding: padding,
          itemBuilder: (context, index) {
            final item = items[index];
            return _CommonGlassButton(
              focusNode: item.focusNode,
              isSelected: item.isSelected,
              focusColor: item.focusColor,
              onTap: item.onTap,
              onFocusChange: item.onFocusChange,
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 12,
                right: 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.icon != null) ...[
                    Icon(item.icon, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    item.label.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class CommonSliderSearchPanel extends StatelessWidget {
  final String text;
  final List<List<String>> keyboardLayout;
  final int focusedRow;
  final int focusedCol;
  final List<FocusNode>? focusNodes;
  final Color focusColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double keyHeight;
  final double defaultKeyWidth;
  final double spaceKeyWidth;
  final double actionKeyWidth;

  const CommonSliderSearchPanel({
    super.key,
    required this.text,
    required this.keyboardLayout,
    required this.focusedRow,
    required this.focusedCol,
    this.focusNodes,
    this.focusColor = const Color(0xFF8B5CF6),
    this.padding = const EdgeInsets.symmetric(horizontal: 40),
    this.margin = const EdgeInsets.only(bottom: 20),
    this.keyHeight = 32,
    this.defaultKeyWidth = 35,
    this.spaceKeyWidth = 150,
    this.actionKeyWidth = 60,
  });

  @override
  Widget build(BuildContext context) {
    int nodeIndex = 0;

    return Container(
      margin: margin,
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                text.isEmpty ? 'SEARCH...' : text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: keyboardLayout.asMap().entries.map((rowEntry) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: rowEntry.value.asMap().entries.map((colEntry) {
                    final key = colEntry.value;
                    final isFocused =
                        focusedRow == rowEntry.key && focusedCol == colEntry.key;
                    final width = _keyWidthFor(key, defaultKeyWidth);
                    final focusNode =
                        focusNodes != null && nodeIndex < focusNodes!.length
                            ? focusNodes![nodeIndex]
                            : null;
                    nodeIndex++;

                    final keyChild = Container(
                      margin: const EdgeInsets.all(2),
                      width: width,
                      height: keyHeight,
                      decoration: BoxDecoration(
                        color: isFocused ? focusColor : Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isFocused ? Colors.white : Colors.white10,
                          width: isFocused ? 2 : 1,
                        ),
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: focusColor.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          key,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight:
                                isFocused ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );

                    return focusNode == null
                        ? keyChild
                        : Focus(focusNode: focusNode, child: keyChild);
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  double _keyWidthFor(String key, double defaultWidth) {
    if (key == 'SPACE' || key == ' ') return spaceKeyWidth;
    if (key == 'OK' || key == 'DEL') return actionKeyWidth;
    return defaultWidth;
  }
}
class CommonSliderIndicatorRow extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color? inactiveColor;
  final double activeWidth;
  final double inactiveWidth;
  final double height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry itemMargin;
  final List<BoxShadow>? activeShadows;

  const CommonSliderIndicatorRow({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.activeColor,
    this.inactiveColor,
    this.activeWidth = 24,
    this.inactiveWidth = 8,
    this.height = 8,
    this.padding = const EdgeInsets.only(bottom: 10),
    this.itemMargin = const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
    this.activeShadows,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: itemMargin,
            height: height,
            width: currentIndex == index ? activeWidth : inactiveWidth,
            decoration: BoxDecoration(
              color: currentIndex == index
                  ? activeColor
                  : (inactiveColor ?? Colors.white.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: currentIndex == index ? activeShadows : null,
            ),
          ),
        ),
      ),
    );
  }
}

class CommonSliderHorizontalList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;
  final double? cacheExtent;
  final Clip clipBehavior;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final Widget? emptyState;

  const CommonSliderHorizontalList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.cacheExtent,
    this.clipBehavior = Clip.hardEdge,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) {
      return emptyState ?? const SizedBox.shrink();
    }

    return ListView.builder(
      controller: controller,
      scrollDirection: Axis.horizontal,
      padding: padding,
      physics: physics,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

class CommonSliderPosterList<T> extends StatelessWidget {
  final List<T> items;
  final List<FocusNode> focusNodes;
  final int focusedIndex;
  final ScrollController? controller;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;
  final double? cacheExtent;
  final Clip clipBehavior;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final Widget? emptyState;
  final String Function(T item) titleBuilder;
  final String? Function(T item) imageUrlBuilder;
  final VoidCallback Function(T item) onTapBuilder;
  final void Function(int index, T item)? onItemFocused;
  final Color Function(int index, T item) focusColorBuilder;
  final String? Function(T item)? networkLogoBuilder;
  final double cardWidth;
  final double cardHeight;
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
  final IconData placeholderIcon;
  final List<Color>? placeholderGradientColors;
  final Color? placeholderBackgroundColor;
  final bool useCachedImage;
  final BoxFit imageFit;
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

  const CommonSliderPosterList({
    super.key,
    required this.items,
    required this.focusNodes,
    required this.focusedIndex,
    required this.titleBuilder,
    required this.imageUrlBuilder,
    required this.onTapBuilder,
    required this.focusColorBuilder,
    required this.cardWidth,
    required this.cardHeight,
    required this.placeholderIcon,
    this.controller,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.cacheExtent,
    this.clipBehavior = Clip.hardEdge,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.emptyState,
    this.onItemFocused,
    this.networkLogoBuilder,
    this.itemMargin = EdgeInsets.zero,
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
    this.placeholderGradientColors,
    this.placeholderBackgroundColor,
    this.useCachedImage = false,
    this.imageFit = BoxFit.cover,
    this.showFocusedScrim = false,
    this.focusedScrimOpacity = 0.4,
    this.focusedIconAlignment = Alignment.topLeft,
    this.focusedIconPadding = const EdgeInsets.only(left: 5, top: 5),
    this.focusedIconBackgroundColor,
    this.focusedIconInnerPadding = const EdgeInsets.all(0),
    this.focusedIcon = Icons.play_circle_filled_outlined,
    this.focusedIconSize = 40,
    this.borderRadius = 8,
    this.imageBorderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    final safeItemCount =
        items.length < focusNodes.length ? items.length : focusNodes.length;

    return CommonSliderHorizontalList(
      itemCount: safeItemCount,
      controller: controller,
      padding: padding,
      physics: physics,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      emptyState: emptyState,
      itemBuilder: (context, index) {
        final item = items[index];
        return CommonSliderPosterCard(
          title: titleBuilder(item),
          imageUrl: imageUrlBuilder(item),
          focusNode: focusNodes[index],
          isFocused: focusedIndex == index,
          focusColor: focusColorBuilder(index, item),
          onTap: onTapBuilder(item),
          onFocus: () => onItemFocused?.call(index, item),
          networkLogoUrl: networkLogoBuilder?.call(item),
          width: cardWidth,
          height: cardHeight,
          margin: itemMargin,
          titlePadding: titlePadding,
          titleSpacing: titleSpacing,
          titleFontSize: titleFontSize,
          focusedTitleFontWeight: focusedTitleFontWeight,
          unfocusedTitleFontWeight: unfocusedTitleFontWeight,
          focusedTitleColor: focusedTitleColor,
          unfocusedTitleColor: unfocusedTitleColor,
          titleTextAlign: titleTextAlign,
          titleMaxLines: titleMaxLines,
          cardCrossAxisAlignment: cardCrossAxisAlignment,
          placeholderIcon: placeholderIcon,
          placeholderGradientColors: placeholderGradientColors,
          placeholderBackgroundColor: placeholderBackgroundColor,
          useCachedImage: useCachedImage,
          imageFit: imageFit,
          showFocusedScrim: showFocusedScrim,
          focusedScrimOpacity: focusedScrimOpacity,
          focusedIconAlignment: focusedIconAlignment,
          focusedIconPadding: focusedIconPadding,
          focusedIconBackgroundColor: focusedIconBackgroundColor,
          focusedIconInnerPadding: focusedIconInnerPadding,
          focusedIcon: focusedIcon,
          focusedIconSize: focusedIconSize,
          borderRadius: borderRadius,
          imageBorderRadius: imageBorderRadius,
        );
      },
    );
  }
}

class CommonSliderPosterCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final FocusNode focusNode;
  final bool isFocused;
  final Color focusColor;
  final VoidCallback onTap;
  final VoidCallback? onFocus;
  final String? networkLogoUrl;
  final double width;
  final double height;
  final EdgeInsetsGeometry margin;
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
  final IconData placeholderIcon;
  final List<Color>? placeholderGradientColors;
  final Color? placeholderBackgroundColor;
  final bool useCachedImage;
  final BoxFit imageFit;
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

  const CommonSliderPosterCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.focusNode,
    required this.isFocused,
    required this.focusColor,
    required this.onTap,
    required this.width,
    required this.height,
    required this.placeholderIcon,
    this.onFocus,
    this.networkLogoUrl,
    this.margin = EdgeInsets.zero,
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
    this.placeholderGradientColors,
    this.placeholderBackgroundColor,
    this.useCachedImage = false,
    this.imageFit = BoxFit.cover,
    this.showFocusedScrim = false,
    this.focusedScrimOpacity = 0.4,
    this.focusedIconAlignment = Alignment.topLeft,
    this.focusedIconPadding = const EdgeInsets.only(left: 5, top: 5),
    this.focusedIconBackgroundColor,
    this.focusedIconInnerPadding = const EdgeInsets.all(0),
    this.focusedIcon = Icons.play_circle_filled_outlined,
    this.focusedIconSize = 40,
    this.borderRadius = 8,
    this.imageBorderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: width,
        margin: margin,
        child: InkWell(
          focusNode: focusNode,
          onTap: onTap,
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              onFocus?.call();
            }
          },
          child: Column(
            crossAxisAlignment: cardCrossAxisAlignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: height,
                width: width,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  transform: isFocused
                      ? (Matrix4.identity()..scale(1.05))
                      : Matrix4.identity(),
                  transformAlignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: isFocused
                        ? Border.all(color: focusColor, width: 3)
                        : Border.all(color: Colors.transparent, width: 3),
                    boxShadow: isFocused
                        ? [
                            BoxShadow(
                              color: focusColor.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : const [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(imageBorderRadius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImage(),
                        if (isFocused) _buildFocusedOverlay(),
                        if (networkLogoUrl != null && networkLogoUrl!.isNotEmpty)
                          Positioned(
                            top: 5,
                            right: 5,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundImage: useCachedImage
                                  ? CachedNetworkImageProvider(networkLogoUrl!)
                                  : NetworkImage(networkLogoUrl!),
                              backgroundColor: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: titleSpacing),
              Padding(
                padding: titlePadding,
                child: SizedBox(
                  width: width,
                  child: Text(
                    title,
                    maxLines: titleMaxLines,
                    textAlign: titleTextAlign,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isFocused
                          ? (focusedTitleColor ?? focusColor)
                          : unfocusedTitleColor,
                      fontSize: titleFontSize,
                      fontWeight: isFocused
                          ? focusedTitleFontWeight
                          : unfocusedTitleFontWeight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) {
      return _buildPlaceholder();
    }

    if (useCachedImage) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: imageFit,
        placeholder: (context, _) => _buildPlaceholder(),
        errorWidget: (context, _, __) => _buildPlaceholder(),
      );
    }

    return Image.network(
      url,
      fit: imageFit,
      errorBuilder: (context, _, __) => _buildPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildFocusedOverlay() {
    final icon = _buildFocusedIcon();

    if (showFocusedScrim) {
      return Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(focusedScrimOpacity),
          child: Padding(
            padding: focusedIconPadding,
            child: Align(
              alignment: focusedIconAlignment,
              child: icon,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: focusedIconPadding,
      child: Align(
        alignment: focusedIconAlignment,
        child: icon,
      ),
    );
  }

  Widget _buildFocusedIcon() {
    final icon = Icon(
      focusedIcon,
      color: focusColor,
      size: focusedIconSize,
    );

    if (focusedIconBackgroundColor == null) {
      return icon;
    }

    return Container(
      padding: focusedIconInnerPadding,
      decoration: BoxDecoration(
        color: focusedIconBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: icon,
    );
  }

  Widget _buildPlaceholder() {
    final colors = placeholderGradientColors;

    return Container(
      decoration: BoxDecoration(
        color: placeholderBackgroundColor,
        gradient: colors != null && colors.length >= 2
            ? LinearGradient(colors: colors)
            : null,
      ),
      child: Center(
        child: Icon(
          placeholderIcon,
          color: Colors.white.withOpacity(0.7),
          size: 32,
        ),
      ),
    );
  }
}
class _CommonGlassButton extends StatelessWidget {
  final FocusNode focusNode;
  final bool isSelected;
  final Color focusColor;
  final VoidCallback onTap;
  final ValueChanged<bool>? onFocusChange;
  final EdgeInsetsGeometry margin;
  final Widget child;

  const _CommonGlassButton({
    required this.focusNode,
    required this.isSelected,
    required this.focusColor,
    required this.onTap,
    required this.child,
    this.onFocusChange,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isFocused = focusNode.hasFocus;

    return Focus(
      focusNode: focusNode,
      onFocusChange: onFocusChange,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: margin,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: (isSelected || isFocused)
                ? focusColor.withOpacity(0.35)
                : Colors.white.withOpacity(0.08),
            border: Border.all(
              color: isFocused || isSelected
                  ? focusColor
                  : Colors.white.withOpacity(0.35),
              width: isFocused ? 2 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: focusColor.withOpacity(0.35),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}


