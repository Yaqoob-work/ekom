import 'dart:math' as math;

import 'package:flutter/material.dart';

class SmartStyleImageCard extends StatefulWidget {
  final Widget image;
  final String title;
  final double width;
  final double height;
  final bool isFocused;
  final Color? focusGlowColor;
  final Color? focusedTitleColor;
  final Color? unfocusedTitleColor;
  final bool showTitle;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry titlePadding;
  final double focusedScale;
  final double titleSpacing;
  final double titleFontSize;
  final int titleMaxLines;
  final TextAlign titleTextAlign;
  final CrossAxisAlignment cardCrossAxisAlignment;
  final FontWeight focusedTitleFontWeight;
  final FontWeight unfocusedTitleFontWeight;
  final double borderRadius;
  final double imageBorderRadius;
  final Alignment scaleAlignment;
  final Widget? posterOverlay;
  final Widget? focusedOverlay;

  const SmartStyleImageCard({
    super.key,
    required this.image,
    required this.title,
    required this.width,
    required this.height,
    required this.isFocused,
    this.focusGlowColor,
    this.focusedTitleColor,
    this.unfocusedTitleColor,
    this.showTitle = true,
    this.margin = EdgeInsets.zero,
    this.titlePadding = EdgeInsets.zero,
    this.focusedScale = 1.28,
    this.titleSpacing = 16,
    this.titleFontSize = 13,
    this.titleMaxLines = 1,
    this.titleTextAlign = TextAlign.center,
    this.cardCrossAxisAlignment = CrossAxisAlignment.center,
    this.focusedTitleFontWeight = FontWeight.w800,
    this.unfocusedTitleFontWeight = FontWeight.w600,
    this.borderRadius = 8,
    this.imageBorderRadius = 5,
    this.scaleAlignment = Alignment.centerRight,
    this.posterOverlay,
    this.focusedOverlay,
  });

  @override
  State<SmartStyleImageCard> createState() => _SmartStyleImageCardState();
}

class _SmartStyleImageCardState extends State<SmartStyleImageCard>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _borderAnimationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _borderAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.focusedScale,
    ).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    _syncFocusState();
  }

  @override
  void didUpdateWidget(covariant SmartStyleImageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedScale != oldWidget.focusedScale) {
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: widget.focusedScale,
      ).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
      );
    }

    if (widget.isFocused != oldWidget.isFocused ||
        widget.focusedScale != oldWidget.focusedScale) {
      if (widget.isFocused) {
        _scaleController.forward();
        _borderAnimationController.repeat();
      } else {
        _scaleController.reverse();
        _borderAnimationController.stop();
      }
    }
  }

  void _syncFocusState() {
    if (widget.isFocused) {
      _scaleController.value = 1.0;
      _borderAnimationController.repeat();
    } else {
      _scaleController.value = 0.0;
      _borderAnimationController.stop();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _borderAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color glowColor = widget.focusGlowColor ?? Colors.white;

    return Container(
      width: widget.width,
      margin: widget.margin,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: widget.cardCrossAxisAlignment,
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              alignment: widget.scaleAlignment,
              child: child,
            ),
            child: _buildPoster(glowColor),
          ),
          if (widget.showTitle) ...[
            SizedBox(height: widget.titleSpacing),
            _buildTitle(),
          ],
        ],
      ),
    );
  }

  Widget _buildPoster(Color glowColor) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          if (widget.isFocused)
            BoxShadow(
              color: glowColor.withOpacity(0.55),
              blurRadius: 25,
              spreadRadius: 8,
              offset: const Offset(0, 12),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
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
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    gradient: SweepGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white,
                        Colors.white,
                        Colors.white.withOpacity(0.1),
                      ],
                      stops: const [0.0, 0.25, 0.5, 1.0],
                      transform: GradientRotation(
                        _borderAnimationController.value * 2 * math.pi,
                      ),
                    ),
                  ),
                );
              },
            ),
          Padding(
            padding: EdgeInsets.all(widget.isFocused ? 3.5 : 0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                widget.isFocused
                    ? widget.imageBorderRadius
                    : widget.borderRadius,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.image,
                  if (widget.posterOverlay != null) widget.posterOverlay!,
                ],
              ),
            ),
          ),
          if (widget.isFocused)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          if (widget.isFocused && widget.focusedOverlay != null)
            Positioned.fill(child: widget.focusedOverlay!),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: widget.titlePadding,
      child: SizedBox(
        width: widget.width,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontSize: widget.titleFontSize,
            fontWeight: widget.isFocused
                ? widget.focusedTitleFontWeight
                : widget.unfocusedTitleFontWeight,
            color: widget.isFocused
                ? (widget.focusedTitleColor ?? Colors.white)
                : (widget.unfocusedTitleColor ?? Colors.white70),
            letterSpacing: 0.5,
          ),
          child: Text(
            widget.title,
            textAlign: widget.titleTextAlign,
            maxLines: widget.titleMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
