import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:libriflow/core/network/api_client.dart';
import 'package:libriflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:libriflow/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:libriflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:libriflow/features/auth/domain/usecases/login_user.dart';
import 'package:libriflow/features/auth/domain/usecases/signup_user.dart';
import 'package:libriflow/features/auth/presentation/providers/auth_provider.dart';
import 'package:libriflow/features/home/data/datasources/home_local_datasource.dart';
import 'package:libriflow/features/home/data/repositories/home_repository_impl.dart';
import 'package:libriflow/features/home/domain/usecases/change_tab_usecase.dart';
import 'package:libriflow/features/home/domain/usecases/get_current_tab_usecase.dart';
import 'package:libriflow/features/home/presentation/providers/home_provider.dart';
import 'package:libriflow/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:libriflow/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:libriflow/features/profile/domain/usecases/get_profile.dart';
import 'package:libriflow/features/profile/domain/usecases/update_profile.dart';
import 'package:libriflow/features/profile/domain/usecases/upload_profile_image.dart';
import 'package:libriflow/features/profile/presentation/providers/profile_provider.dart';
import 'package:libriflow/features/home/presentation/views/splash_screen.dart';
import 'package:libriflow/features/reservations/data/datasources/reservation_remote_datasource.dart';
import 'package:libriflow/features/reservations/data/repositories/reservation_repository_impl.dart';
import 'package:libriflow/features/reservations/domain/usecases/cancel_reservation.dart';
import 'package:libriflow/features/reservations/domain/usecases/create_reservation.dart';
import 'package:libriflow/features/reservations/domain/usecases/get_my_reservations.dart';
import 'package:libriflow/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:libriflow/features/recommendations/data/datasources/recommendation_local_datasource.dart';
import 'package:libriflow/features/recommendations/data/datasources/recommendation_remote_datasource.dart';
import 'package:libriflow/features/recommendations/data/repositories/recommendation_repository_impl.dart';
import 'package:libriflow/features/recommendations/domain/usecases/get_recommendations.dart';
import 'package:libriflow/features/recommendations/presentation/providers/recommendation_provider.dart';
import 'package:libriflow/features/borrowings/data/datasources/borrowing_remote_datasource.dart';
import 'package:libriflow/features/borrowings/data/repositories/borrowing_repository_impl.dart';
import 'package:libriflow/features/borrowings/domain/usecases/borrowing_usecases.dart';
import 'package:libriflow/features/borrowings/presentation/providers/borrowing_provider.dart';
import 'package:libriflow/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:libriflow/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:libriflow/features/payments/domain/usecases/payment_usecases.dart';
import 'package:libriflow/features/payments/presentation/providers/payment_provider.dart';
import 'package:libriflow/features/scanner/data/datasources/scanner_remote_datasource.dart';
import 'package:libriflow/features/scanner/data/repositories/scanner_repository_impl.dart';
import 'package:libriflow/features/scanner/domain/usecases/borrow_by_qr_code.dart';
import 'package:libriflow/features/scanner/presentation/providers/scanner_provider.dart';
import 'package:libriflow/features/admin/presentation/providers/admin_books_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final authBox = await Hive.openBox('auth');
  final homeBox = await Hive.openBox('home_settings');
  final recommendationBox = await Hive.openBox('recommendations');
  await Hive.openBox('books'); // Initialize books box

  final apiClient = ApiClient();
  final String? savedToken = authBox.get('token');
  if (savedToken != null) {
    apiClient.setToken(savedToken);
  }

  runApp(
    MyApp(
      authBox: authBox,
      homeBox: homeBox,
      recommendationBox: recommendationBox,
    ),
  );
}

class MyApp extends StatelessWidget {
  final Box authBox;
  final Box homeBox;
  final Box recommendationBox;

  const MyApp({
    super.key,
    required this.authBox,
    required this.homeBox,
    required this.recommendationBox,
  });

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepositoryImpl(
      remote: AuthRemoteDatasourceImpl(),
      local: AuthLocalDatasourceImpl(authBox),
    );

    final homeRepository = HomeRepositoryImpl(
      HomeLocalDatasourceImpl(homeBox),
    );

    final profileRepository = ProfileRepositoryImpl(
      ProfileRemoteDataSourceImpl(),
    );

    final reservationRepository = ReservationRepositoryImpl(
      ReservationRemoteDataSourceImpl(),
    );

    final recommendationRepository = RecommendationRepositoryImpl(
      remote: RecommendationRemoteDataSourceImpl(),
      local: RecommendationLocalDataSourceImpl(recommendationBox),
    );

    final borrowingRepository = BorrowingRepositoryImpl(
      remoteDataSource: BorrowingRemoteDataSourceImpl(),
    );

    final paymentRepository = PaymentRepositoryImpl(
      remoteDataSource: PaymentRemoteDataSourceImpl(),
    );

    final scannerRepository = ScannerRepositoryImpl(
      remoteDataSource: ScannerRemoteDataSourceImpl(),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            loginUser: LoginUser(authRepository),
            signupUser: SignupUser(authRepository),
            repository: authRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeProvider(
            changeTabUseCase: ChangeTabUseCase(homeRepository),
            getCurrentTabUseCase: GetCurrentTabUseCase(homeRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(
            getProfile: GetProfile(profileRepository),
            updateProfile: UpdateProfile(profileRepository),
            uploadProfileImage: UploadProfileImage(profileRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ReservationProvider(
            getMyReservations: GetMyReservations(reservationRepository),
            createReservation: CreateReservation(reservationRepository),
            cancelReservationUseCase: CancelReservation(reservationRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RecommendationProvider(
            getRecommendations: GetRecommendations(recommendationRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => BorrowingProvider(
            getMyBorrowingsUseCase: GetMyBorrowingsUseCase(repository: borrowingRepository),
            getActiveBorrowingsUseCase: GetActiveBorrowingsUseCase(repository: borrowingRepository),
            getBorrowingDetailsUseCase: GetBorrowingDetailsUseCase(repository: borrowingRepository),
            returnBorrowingUseCase: ReturnBorrowingUseCase(repository: borrowingRepository),
            getBorrowingStatsUseCase: GetBorrowingStatsUseCase(repository: borrowingRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PaymentProvider(
            getMyPaymentsUseCase: GetMyPaymentsUseCase(repository: paymentRepository),
            getUnpaidFinesUseCase: GetUnpaidFinesUseCase(repository: paymentRepository),
            createPaymentUseCase: CreatePaymentUseCase(repository: paymentRepository),
            verifyPaymentUseCase: VerifyPaymentUseCase(repository: paymentRepository),
            getPaymentDetailsUseCase: GetPaymentDetailsUseCase(repository: paymentRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ScannerProvider(
            borrowByQRCodeUseCase: BorrowByQRCodeUseCase(repository: scannerRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AdminBooksProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const SplashScreen(),
      ),
    );
  }
}