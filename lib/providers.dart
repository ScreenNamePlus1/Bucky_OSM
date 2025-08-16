import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

final userProvider = FutureProvider<AppUser?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUser();
});

class AppState extends StateNotifier<Map<String, String?>> {
  AppState(this.ref) : super({'userId': null, 'userRole': 'customer'}) {
    _init();
  }
  final Ref ref;

  Future<void> _init() async {
    final user = await ref.watch(userProvider.future);
    state = {'userId': user?.id, 'userRole': user?.role ?? 'customer'};
  }

  void setUser(String? userId, String? role) {
    if (role != null && !['customer', 'driver'].contains(role)) {
      throw Exception('Invalid role');
    }
    state = {'userId': userId, 'userRole': role ?? 'customer'};
  }

  void clearUser() {
    state = {'userId': null, 'userRole': null};
  }
}

final appStateProvider = StateNotifierProvider<AppState, Map<String, String?>>(
  (ref) => AppState(ref),
);