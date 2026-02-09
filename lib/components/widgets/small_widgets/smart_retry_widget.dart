
//==============================================================================
// ✅ 2. SMART RETRY WIDGET SERVICE (Advanced)
//==============================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/components/provider/focus_provider.dart';
import 'package:provider/provider.dart';

import '../../services/professional_colors_for_home_pages.dart';

class SmartRetryWidget extends StatefulWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final FocusNode focusNode;
  final Function(bool)? onFocusChange; // Optional callback
  
  // ✅ New Props for Reusability
  final String? providerIdentifier; // E.g., 'liveChannelLanguage' or 'subVod'
  final VoidCallback? onArrowUpOverride; // Custom logic if needed (like in Banner)
  
  const SmartRetryWidget({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
    required this.focusNode,
    this.onFocusChange,
    this.providerIdentifier,
    this.onArrowUpOverride,
  }) : super(key: key);

  @override
  _SmartRetryWidgetState createState() => _SmartRetryWidgetState();
}

class _SmartRetryWidgetState extends State<SmartRetryWidget> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) {
        setState(() => _hasFocus = widget.focusNode.hasFocus);
        widget.onFocusChange?.call(widget.focusNode.hasFocus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Focus(
        focusNode: widget.focusNode,
        onKey: (node, event) {
           if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.select) {
                 widget.onRetry();
                 return KeyEventResult.handled;
              }
              
              // ✅ Smart Navigation Logic
              if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                // Agar Custom Override diya hai (Jaise Banner ke liye), to wo use karein
                if (widget.onArrowUpOverride != null) {
                   widget.onArrowUpOverride!();
                   return KeyEventResult.handled;
                }
                // Nahi to Default Provider logic use karein
                if (widget.providerIdentifier != null) {
                  context.read<FocusProvider>().updateLastFocusedIdentifier(widget.providerIdentifier!);
                  context.read<FocusProvider>().focusPreviousRow();
                  return KeyEventResult.handled;
                }
              } 
              
              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                if (widget.providerIdentifier != null) {
                  context.read<FocusProvider>().updateLastFocusedIdentifier(widget.providerIdentifier!);
                  context.read<FocusProvider>().focusNextRow();
                  return KeyEventResult.handled;
                }
              }
           }
           return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: widget.onRetry,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            transform: Matrix4.identity()..scale(_hasFocus ? 1.1 : 1.0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _hasFocus 
                  ? ProfessionalColorsForHomePages.accentBlue 
                  : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _hasFocus ? Colors.white : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                if (_hasFocus)
                  BoxShadow(
                    color: ProfessionalColorsForHomePages.accentBlue.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                else
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: _hasFocus ? Colors.white : ProfessionalColorsForHomePages.accentRed,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  "RETRY CONNECTION",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: _hasFocus ? Colors.white : Colors.black87,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}