import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:h8_fli_biometric_starter/data/datasources/biometric_data_source.dart';
import 'package:h8_fli_biometric_starter/data/datasources/remote_data_source.dart';
import 'package:h8_fli_biometric_starter/data/repositories/biometric_repository_impl.dart';
import 'package:h8_fli_biometric_starter/domain/repositories/biometric_repository.dart';
import 'package:h8_fli_biometric_starter/domain/usecases/biometric_usecase.dart';
import 'package:h8_fli_biometric_starter/firebase_options.dart';
import 'package:h8_fli_biometric_starter/manager/geo_bloc.dart';
import 'package:h8_fli_biometric_starter/presentation/managers/biometric_bloc.dart';
import 'package:h8_fli_biometric_starter/presentation/pages/auth_page.dart';
import 'package:h8_fli_biometric_starter/service/geo_service.dart';
import 'package:h8_fli_biometric_starter/view/geo_view.dart';
import 'package:local_auth/local_auth.dart';

/// MARK: Setup Platform (Android).
// TODO: 1. Update minSDK inside android/app/build.gradle.kts to 23.
// TODO: 2. Add the following permission inside AndroidManifest.xml file.
/*
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
*/
// TODO: 3. Change the MainActivity type to FlutterFragmentActivity. android/app/src/main/kotlin

/// MARK: Setup Platform (iOS).
// TODO: 1. Add the following permission inside Info.plist file.
/*
<key>NSFaceIDUsageDescription</key>
<string>Application need to use Face ID to secure your data</string>
*/

// MARK: Dependency injection.
// TODO: 1. Add dependency injection for managing the dependencies easily.
final locator = GetIt.instance;

void initDependencies() {
  locator.registerLazySingleton<LocalAuthentication>(
    () => LocalAuthentication(),
  );

  locator.registerLazySingleton<BiometricDataSource>(
    () => BiometricDataSource(localAuth: locator()),
  );

  locator.registerLazySingleton<RemoteDataSource>(() => RemoteDataSource());

  //MARK: Repository
  locator.registerLazySingleton<BiometricRepository>(
    () => BiometricRepositoryImpl(
      dataSource: locator(),
      remoteDataSource: locator(),
    ),
  );

  locator.registerLazySingleton<GeoService>(() => GeoService());
  //MARK: Usecase
  locator.registerLazySingleton<BiometricCheckAvailabilityUseCase>(
    () => BiometricCheckAvailabilityUseCase(repository: locator()),
  );
  locator.registerLazySingleton<BiometricAuthenticateUseCase>(
    () => BiometricAuthenticateUseCase(repository: locator()),
  );

  //MARK: State Management
  locator.registerFactory<BiometricBloc>(
    () => BiometricBloc(
      checkAvailabilityUseCase: locator(),
      authenticateUseCase: locator(),
    ),
  );
  locator.registerFactory<GeoBloc>(() => GeoBloc(service: locator()));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // MARK: Dependency injection.
  // TODO: 2. Initialize the dependency injection here.
  initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // TODO: Define the routing system.
    /*
      There are two pages in this app. Create the routes configuration
      for that pages, then set page that handle the auth process
      as the initial route.
    */
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => locator<BiometricBloc>()),
        BlocProvider(create: (context) => locator<GeoBloc>()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        initialRoute: '/auth',
        routes: {
          '/auth': (context) => const AuthPage(),
          '/home': (context) => const GeoView(),
        },
      ),
    );
  }
}
