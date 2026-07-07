import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';

final _logger = Logger();

// User state provider
final userStateProvider = StateNotifierProvider<UserStateNotifier, AsyncValue<UserModel?>>((ref) {
  return UserStateNotifier();
});

// Authentication state provider
final authStateProvider = StreamProvider<bool>((ref) async* {
  final supabase = SupabaseService();
  yield supabase.currentUser != null;
});

// Current user ID provider
final currentUserIdProvider = Provider<String?>((ref) {
  final supabase = SupabaseService();
  return supabase.currentUser?.id;
});

// Current session provider
final currentSessionProvider = Provider((ref) {
  final supabase = SupabaseService();
  return supabase.currentSession;
});

class UserStateNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final _supabase = SupabaseService();

  UserStateNotifier() : super(const AsyncValue.loading()) {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId != null) {
        await loadUser(userId);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      final userData = await _supabase.getUserProfile(userId);
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _logger.e('Error loading user: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      state = const AsyncValue.loading();
      await _supabase.updateUserProfile(
        userId: user.id,
        updates: user.toJson(),
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _logger.e('Error updating user: $e');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userType,
  }) async {
    try {
      state = const AsyncValue.loading();
      final response = await _supabase.signUp(
        email: email,
        password: password,
        fullName: fullName,
        userType: userType,
      );

      if (response.user != null) {
        final user = UserModel(
          id: response.user!.id,
          email: email,
          fullName: fullName,
          userType: userType,
          avatarUrl: null,
          bio: '',
          rating: 0,
          createdAt: DateTime.now(),
        );
        state = AsyncValue.data(user);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _logger.e('Sign up error: $e');
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      final response = await _supabase.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await loadUser(response.user!.id);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _logger.e('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      state = const AsyncValue.loading();
      await _supabase.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _logger.e('Sign out error: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.resetPassword(email);
    } catch (e) {
      _logger.e('Password reset error: $e');
      rethrow;
    }
  }
}

// Sign up provider
final signUpProvider = FutureProvider.family<void, ({
  String email,
  String password,
  String fullName,
  String userType,
})>((ref, params) async {
  final notifier = ref.read(userStateProvider.notifier);
  await notifier.signUp(
    email: params.email,
    password: params.password,
    fullName: params.fullName,
    userType: params.userType,
  );
});

// Sign in provider
final signInProvider = FutureProvider.family<void, ({
  String email,
  String password,
})>((ref, params) async {
  final notifier = ref.read(userStateProvider.notifier);
  await notifier.signIn(
    email: params.email,
    password: params.password,
  );
});

// Sign out provider
final signOutProvider = FutureProvider<void>((ref) async {
  final notifier = ref.read(userStateProvider.notifier);
  await notifier.signOut();
});

// Reset password provider
final resetPasswordProvider = FutureProvider.family<void, String>((ref, email) async {
  final notifier = ref.read(userStateProvider.notifier);
  await notifier.resetPassword(email);
});
