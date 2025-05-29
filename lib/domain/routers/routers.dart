import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sergio_pizza/common/function.dart';
import 'package:sergio_pizza/presentation/screen/auth/auth_code_page.dart';
import 'package:sergio_pizza/presentation/screen/auth/auth_page.dart';
import 'package:sergio_pizza/presentation/screen/auth/auth_reg_page.dart';
import 'package:sergio_pizza/presentation/screen/auth/auth_sms_page.dart';
import 'package:sergio_pizza/presentation/screen/auth/user_reg_page.dart';
import 'package:sergio_pizza/presentation/screen/main/main_page.dart';
import 'package:sergio_pizza/presentation/screen/splash/splash_page.dart';

/// роутер приложения
final GoRouter router = GoRouter(
  // observers: [GoNavigatorObserver()],
  debugLogDiagnostics: true,
  initialLocation: '/splash',
  routes: <GoRoute>[
    GoRoute(
      name: 'сплэш',
      path: '/splash',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.fade,
        context: context,
        state: state,
        child: const SplashPage(),
      ),
    ),
    GoRoute(
      name: 'авторизация по смс',
      path: '/sms',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.leftToRight,
        context: context,
        state: state,
        child: const AuthSmsPage(),
      ),
      routes: <GoRoute>[
        GoRoute(
          name: 'ввод кода',
          path: '/code',
          pageBuilder: (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.rightToLeft,
            context: context,
            state: state,
            child: const AuthCodePage(),
          ),
          routes: <GoRoute>[
            GoRoute(
              name: 'регистрация пользователя',
              path: '/reg',
              pageBuilder: (context, state) => buildPageWithDefaultTransition(
                type: PageTransitionType.rightToLeft,
                context: context,
                state: state,
                child: const UserRegPage(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      name: 'авторизация',
      path: '/auth',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.leftToRight,
        context: context,
        state: state,
        child: const AuthPage(),
      ),
      routes: <GoRoute>[
        GoRoute(
          name: 'Регистрация пользователя',
          path: '/auth/reg',
          pageBuilder: (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.rightToLeft,
            context: context,
            state: state,
            child: const AuthRegPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      name: 'Общая',
      path: '/main',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.leftToRight,
        context: context,
        state: state,
        child: const MainPage(),
      ),
      routes: <GoRoute>[],
    ),
  ],
);
