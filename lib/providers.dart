import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final userProvider = FutureProvider<AppUser?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUser();
});
class AppStateNotifier extends StateNotifier<String?> {
  AppStateNotifier(this.ref) : super(null) {
    _init();
  }
  final Ref ref;
  Future<void> _init() async {
    final user = await ref.watch(userProvider.future);
    state = user?.id;
  }
  void updateUserId(String? userId) {
    state = userId;
  }
}
final appStateProvider = StateNotifierProvider<AppStateNotifier, String?>(
  (ref) => AppStateNotifier(ref),
);