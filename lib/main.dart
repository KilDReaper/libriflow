import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:libriflow/core/network/api_client.dart';
import 'package:libriflow/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:libriflow/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:libriflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:libriflow/features/auth/domain/usecases/login_user.dart';
import 'package:libriflow/features/auth/domain/usecases/signup_user.dart';
import 'package:libriflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:libriflow/features/home/data/datasources/home_local_datasource.dart';
import 'package:libriflow/features/home/data/repositories/home_repository_impl.dart';
import 'package:libriflow/features/home/domain/usecases/change_tab_usecase.dart';
import 'package:libriflow/features/home/domain/usecases/get_current_tab_usecase.dart';
import 'package:libriflow/features/home/presentation/bloc/home_bloc.dart';
import 'package:libriflow/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:libriflow/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:libriflow/features/profile/domain/usecases/get_profile.dart';
import 'package:libriflow/features/profile/domain/usecases/update_profile.dart';
import 'package:libriflow/features/profile/domain/usecases/upload_profile_image.dart';
import 'package:libriflow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:libriflow/features/home/presentation/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final authBox = await Hive.openBox('auth');
  final homeBox = await Hive.openBox('home_settings');

  final apiClient = ApiClient();
  final String? savedToken = authBox.get('token');
  if (savedToken != null) {
    apiClient.setToken(savedToken);
  }

  runApp(MyApp(authBox: authBox, homeBox: homeBox));
}

class MyApp extends StatelessWidget {
  final Box authBox;
  final Box homeBox;

  const MyApp({
    super.key,
    required this.authBox,
    required this.homeBox,
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

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            loginUser: LoginUser(authRepository),
            signupUser: SignupUser(authRepository),
            repository: authRepository,
          ),
        ),
        BlocProvider(
          create: (context) => HomeBloc(
            changeTabUseCase: ChangeTabUseCase(homeRepository),
            getCurrentTabUseCase: GetCurrentTabUseCase(homeRepository),
          ),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(
            getProfile: GetProfile(profileRepository),
            updateProfile: UpdateProfile(profileRepository), 
            uploadProfileImage: UploadProfileImage(profileRepository),
          ),
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