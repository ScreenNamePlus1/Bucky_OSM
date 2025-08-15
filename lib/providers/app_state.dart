import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  String userRole = 'customer'; // Default role
  String userId = '';

  void setUser(String id, String role) {
    userId = id;
    userRole = role;
    notifyListeners();
  }
}