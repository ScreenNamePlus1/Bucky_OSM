import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppState extends StateNotifier<Map<String, String?>> {
  AppState() : super({'userId': null, 'userRole': 'customer'});

  String? get userId => state['userId'];
  String? get userRole => state['userRole'];

  void setUser(String? id, String? role) {
    if (role != null && !['customer', 'driver'].contains(role)) {
      throw Exception('Invalid role');
    }
    state = {'userId': id, 'userRole': role ?? 'customer'};
  }

  void clearUser() {
    state = {'userId': null, 'userRole': null};
  }
}

final appStateProvider = StateNotifierProvider<AppState, Map<String, String?>>(
  (ref) => AppState(),
);