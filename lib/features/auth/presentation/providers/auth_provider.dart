import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource_impl.dart';
import '../../data/datasources/biometric_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/biometric_repository_impl.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/signup_user.dart';
import '../../domain/usecases/biometric_usecases.dart';
import '../../../../core/network/api_client.dart';

enum AuthStatus { initial, loading, loggedIn, loggedOut, error }

// State class to hold auth state
class AuthState {
  final AuthStatus status;
  final String? token;
  final String? errorMessage;
  final bool isBiometricAvailable;

  AuthState({
    this.status = AuthStatus.initial,
    this.token,
    this.errorMessage,
    this.isBiometricAvailable = false,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isLoggedIn => status == AuthStatus.loggedIn;

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    String? errorMessage,
    bool? isBiometricAvailable,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      errorMessage: errorMessage,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
    );
  }
}

// Providers for dependencies (these will be injected from main.dart or created here)
final authRemoteDataSourceProvider = Provider((ref) => AuthRemoteDatasourceImpl());

final authLocalDataSourceProvider = Provider<AuthLocalDatasource>((ref) {
  // This will need to be overridden with the actual Hive box in main.dart
  throw UnimplementedError('authLocalDataSourceProvider must be overridden with Hive box');
});

final authRepositoryProvider = Provider((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
  );
});

final biometricDatasourceProvider = Provider<BiometricLocalDatasource>((ref) {
  // This will need to be overridden with the actual Hive box in main.dart
  throw UnimplementedError('biometricDatasourceProvider must be overridden with Hive box');
});

final biometricRepositoryProvider = Provider((ref) {
  return BiometricRepositoryImpl(ref.watch(biometricDatasourceProvider));
});

// Use case providers
final loginUserProvider = Provider((ref) {
  return LoginUser(ref.watch(authRepositoryProvider));
});

final signupUserProvider = Provider((ref) {
  return SignupUser(ref.watch(authRepositoryProvider));
});

final authenticateWithBiometricProvider = Provider((ref) {
  return AuthenticateWithBiometric(ref.watch(biometricRepositoryProvider));
});

final checkBiometricAvailabilityProvider = Provider((ref) {
  return CheckBiometricAvailability(ref.watch(biometricRepositoryProvider));
});

final getSavedBiometricEmailProvider = Provider((ref) {
  return GetSavedBiometricEmail(ref.watch(biometricRepositoryProvider));
});

final saveBiometricEmailProvider = Provider((ref) {
  return SaveBiometricEmail(ref.watch(biometricRepositoryProvider));
});

final clearBiometricEmailProvider = Provider((ref) {
  return ClearBiometricEmail(ref.watch(biometricRepositoryProvider));
});

// StateNotifier to manage auth state
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUser loginUser;
  final SignupUser signupUser;
  final Ref ref;

  AuthNotifier({
    required this.loginUser,
    required this.signupUser,
    required this.ref,
  }) : super(AuthState());

  // Check if biometric is available
  Future<void> checkBiometricStatus() async {
    try {
      final checkBiometric = ref.read(checkBiometricAvailabilityProvider);
      final isAvailable = await checkBiometric();
      state = state.copyWith(isBiometricAvailable: isAvailable);
    } catch (e) {
      state = state.copyWith(isBiometricAvailable: false);
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );

    try {
      final user = await loginUser(email, password);
      ApiClient().setToken(user.token);

      // Save email so biometric login can identify the account later.
      final saveBiometric = ref.read(saveBiometricEmailProvider);
      await saveBiometric(email);
      
      state = state.copyWith(
        status: AuthStatus.loggedIn,
        token: user.token,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  // Biometric login
  Future<void> loginWithBiometric() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );

    try {
      final checkBiometric = ref.read(checkBiometricAvailabilityProvider);
      final isAvailable = await checkBiometric();
      state = state.copyWith(isBiometricAvailable: isAvailable);
      if (!isAvailable) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Biometric authentication is not available on this device.',
        );
        return;
      }

      // Authenticate using biometric
      final authenticate = ref.read(authenticateWithBiometricProvider);
      final isAuthenticated = await authenticate();
      if (!isAuthenticated) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Biometric authentication was cancelled.',
        );
        return;
      }

      // Get saved email
      final getSavedEmail = ref.read(getSavedBiometricEmailProvider);
      final savedEmail = await getSavedEmail();
      if (savedEmail == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'No saved biometric login found. Please login with your email and password first.',
        );
        return;
      }

      // Check if we have a saved token for this email
      final repository = ref.read(authRepositoryProvider);
      final isLoggedInPreviously = await repository.isLoggedIn();
      if (isLoggedInPreviously) {
        // Use saved token
        final token = await repository.getToken();
        if (token != null && token.isNotEmpty) {
          ApiClient().setToken(token);
          state = state.copyWith(
            status: AuthStatus.loggedIn,
            token: token,
          );
          return;
        }
      }

      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Session expired. Please login with your email and password.',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  // Signup
  Future<void> signup({
    required String email,
    required String username,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );

    try {
      final user = await signupUser(
        email,
        username,
        phone,
        password,
        confirmPassword,
      );
      ApiClient().setToken(user.token);
      state = state.copyWith(
        status: AuthStatus.loggedIn,
        token: user.token,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Keep local token/email so user can return using biometric login.
      ApiClient().clearToken();
      state = state.copyWith(
        status: AuthStatus.loggedOut,
        token: null,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  // Set token from local storage
  void setToken(String token) {
    ApiClient().setToken(token);
    state = state.copyWith(
      status: AuthStatus.loggedIn,
      token: token,
    );
  }

  // Enable biometric for an email
  Future<void> enableBiometricForEmail(String email) async {
    try {
      final saveBiometric = ref.read(saveBiometricEmailProvider);
      await saveBiometric(email);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to enable biometric login',
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Main provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUser: ref.watch(loginUserProvider),
    signupUser: ref.watch(signupUserProvider),
    ref: ref,
  );
});
