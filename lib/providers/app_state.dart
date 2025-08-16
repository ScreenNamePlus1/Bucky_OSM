import 'package:flutter/foundation.dart';

class AppState with ChangeNotifier {
  String? _userId;
  String? _userRole;

  AppState() : _userId = null, _userRole = 'customer';

  String? get userId => _userId;
  String? get userRole => _userRole;

  void setUser(if (!['customer', 'driver'].contains(role)) throw Exception('Invalid role');) {
    _userId = id;
    _userRole = role ?? 'customer';
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _userRole = null;
    notifyListeners();
  }
}