import 'package:flutter/foundation.dart';

/// The selected bottom-nav tab. Provided app-wide so any screen — including
/// pushed routes like the in-app store browser — can switch tabs.
class ShellController extends ChangeNotifier {
  int _tab = 0;
  int get tab => _tab;

  static const home = 0;
  static const stores = 1;
  static const cart = 2;
  static const orders = 3;
  static const me = 4;

  void goToTab(int i) {
    if (_tab == i) return;
    _tab = i;
    notifyListeners();
  }
}
