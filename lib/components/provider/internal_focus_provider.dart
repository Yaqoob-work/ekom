// ==========================================================
// 1. FOCUS PROVIDER
// ==========================================================

import 'package:flutter/foundation.dart';

class InternalFocusProvider with ChangeNotifier {
  String _focusedItemName = '';

  String get focusedItemName => _focusedItemName;

  void updateName(String newName) {
    if (_focusedItemName == newName) return;
    _focusedItemName = newName;
    notifyListeners();
  }
}