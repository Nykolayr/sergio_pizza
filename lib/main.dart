import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/injects.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';
import 'package:sergio_pizza/domain/routers/routers.dart';
import 'package:sergio_pizza/presentation/screen/splash/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool initialized = false;
  bool isReg = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (!initialized &&
            snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashPage(isReg: isReg),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          initialized = true;
          return MaterialApp.router(
            title: 'Sergio Pizza',
            theme: ThemeData(
              fontFamily: 'ProximaNova',
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            debugShowCheckedModeBanner: false,
            routeInformationProvider: router.routeInformationProvider,
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate,
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              final fontScale = mq.textScaler.clamp(
                minScaleFactor: 0.9,
                maxScaleFactor: 1.1,
              );
              return MediaQuery(
                data: mq.copyWith(textScaler: fontScale),
                child: child!,
              );
            },
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashPage(isReg: isReg),
        );
      },
    );
  }

  Future<void> _initializeApp() async {
    await initMain(); // Ждем инициализации
    await Future.delayed(const Duration(seconds: 2)); // Дополнительная задержка

    final userRepository = Get.find<UserRepository>();
    isReg = userRepository.isReg;

    if (isReg) {
      router.go('/main');
    } else {
      router.go('/auth');
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }
}
