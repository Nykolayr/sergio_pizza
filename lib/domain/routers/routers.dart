import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sergio_pizza/common/function.dart';
import 'package:sergio_pizza/presentation/screen/auth/auth_page.dart';
import 'package:sergio_pizza/presentation/screen/auth/auth_reg_page.dart';
import 'package:sergio_pizza/presentation/screen/main/main_page.dart';
import 'package:sergio_pizza/presentation/screen/splash/splash_page.dart';

/// роутер приложения
final GoRouter router = GoRouter(
  // observers: [GoNavigatorObserver()],
  debugLogDiagnostics: true,
  initialLocation: '/main',

  // Get.find<UserRepository>().isReg ? '/main' : '/reg',
  routes: <GoRoute>[
    GoRoute(
      name: 'сплэш',
      path: '/splash',
      pageBuilder:
          (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.fade,
            context: context,
            state: state,
            child: SplashPage(isReg: state.extra as bool),
          ),
    ),
    GoRoute(
      name: 'авторизация',
      path: '/auth',
      pageBuilder:
          (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.leftToRight,
            context: context,
            state: state,
            child: const AuthPage(),
          ),
      routes: <GoRoute>[],
    ),
    GoRoute(
      name: 'регистрация',
      path: '/reg',
      pageBuilder:
          (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.rightToLeft,
            context: context,
            state: state,
            child: const AuthRegPage(),
          ),
      routes: <GoRoute>[],
    ),
    GoRoute(
      name: 'Общая',
      path: '/main',
      pageBuilder:
          (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.leftToRight,
            context: context,
            state: state,
            child: const MainPage(),
          ),
      routes: <GoRoute>[],
    ),
  ],
);
