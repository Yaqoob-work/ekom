import 'package:flutter/material.dart';

class FocusedOverlayList extends StatelessWidget {
  final ScrollController controller;
  final EdgeInsetsGeometry padding;
  final int itemCount;
  final int focusedIndex;
  final double itemExtent;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder focusedItemBuilder; final IndexedWidgetBuilder? focusedPlaceholderBuilder;
  final Axis scrollDirection;
  final Alignment overlayAlignment;
  final Offset overlayOffset;

  const FocusedOverlayList({
    super.key,
    required this.controller,
    required this.padding,
    required this.itemCount,
    required this.focusedIndex,
    required this.itemExtent,
    required this.itemBuilder,
    required this.focusedItemBuilder,    this.focusedPlaceholderBuilder,
    this.scrollDirection = Axis.horizontal,
    this.overlayAlignment = Alignment.centerLeft,
    this.overlayOffset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsets resolvedPadding = padding.resolve(Directionality.of(context));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ListView.builder(
          controller: controller,
          scrollDirection: scrollDirection,
          clipBehavior: Clip.none,
          padding: padding,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final child = itemBuilder(context, index);
            if (index == focusedIndex) {            if (focusedPlaceholderBuilder != null) {             return focusedPlaceholderBuilder!(context, index);}              return Opacity(opacity: 0.0, child: child);            }
            return child;
          },
        ),
        if (focusedIndex >= 0 && focusedIndex < itemCount)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final double scrollOffset = controller.hasClients ? controller.offset : 0.0;
                  final double mainPadding = scrollDirection == Axis.horizontal
                      ? resolvedPadding.left
                      : resolvedPadding.top;
                  final double mainOffset = (focusedIndex * itemExtent) - scrollOffset + mainPadding;
                  return Transform.translate(
                    offset: scrollDirection == Axis.horizontal
                        ? Offset(mainOffset, 0)
                        : Offset(0, mainOffset),
                    child: Transform.translate(
                      offset: overlayOffset,
                      child: Align(
                        alignment: overlayAlignment,
                        child: child,
                      ),
                    ),
                  );
                },
                child: focusedItemBuilder(context, focusedIndex),
              ),
            ),
          ),
      ],
    );
  }
}

