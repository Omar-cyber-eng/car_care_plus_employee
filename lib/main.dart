import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/networking/dio_factory.dart';
import 'package:car_care_plus/features/cars/data/repos/cars_repo.dart';
import 'package:car_care_plus/features/cars/logic/cars_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:car_care_plus/Localization/l10n/app_localization.dart';
import 'package:car_care_plus/core/routing/app_routes.dart';
import 'package:car_care_plus/features/auth/data/auth_remote_data_source.dart';
import 'package:car_care_plus/features/auth/data/auth_repository_impl.dart';
import 'package:car_care_plus/features/auth/presentation/cubit/auth_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ar'); // اللغة الافتراضية

  late final AppRouter _appRouter;
  late final AuthRepositoryImpl _authRepository;
  late final CarsRepo _carsRepo;

  @override
  void initState() {
    super.initState();

    // 1️⃣ تهيئة Dio والـ ApiService
    final dio = DioFactory.getDio();
    final apiService = ApiService();

    // 2️⃣ تهيئة الطبقات الخاصة بـ Auth و Cars
    final authRemoteDataSource = AuthRemoteDataSourceImpl(dio: dio);
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
    );
    _carsRepo = CarsRepo(apiService);

    // 3️⃣ تهيئة الـ AppRouter
    _appRouter = AppRouter(
      onLanguageChanged: (newLocale) {
        setState(() {
          _locale = newLocale;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              create: (context) => AuthCubit(authRepository: _authRepository),
            ),
            BlocProvider<CarsCubit>(
              create: (context) => CarsCubit(_carsRepo)..getUserCars(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: _locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // 🔗 استخدام الروت نيم هنا
            initialRoute: Routes.mainLayout,
            onGenerateRoute: _appRouter.generateRoute,
          ),
        );
      },
    );
  }
}
