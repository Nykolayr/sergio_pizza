import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sergio_pizza/common/function.dart';
import 'package:sergio_pizza/presentation/screen/auth/auth_code_page.dart';
import 'package:sergio_pizza/presentation/screen/auth/auth_pass_page.dart';
import 'package:sergio_pizza/presentation/screen/auth/auth_enter_page.dart';
import 'package:sergio_pizza/presentation/screen/auth/user_reg_page.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/delivery_map_page.dart';
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
      name: 'авторизация',
      path: '/auth',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.leftToRight,
        context: context,
        state: state,
        child: const AuthEnterPage(),
      ),
      routes: <GoRoute>[
        GoRoute(
          name: 'ввод пароля',
          path: '/pass',
          pageBuilder: (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.rightToLeft,
            context: context,
            state: state,
            child: const AuthPassPage(),
          ),
        ),
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
      name: 'Общая',
      path: '/main',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.leftToRight,
        context: context,
        state: state,
        child: const MainPage(),
      ),
      routes: <GoRoute>[
        GoRoute(
          name: 'доставка',
          path: '/delivery',
          pageBuilder: (context, state) => buildPageWithDefaultTransition(
            type: PageTransitionType.leftToRight,
            context: context,
            state: state,
            child: const DeliveryMapPage(),
          ),
        ),
      ],
    ),
  ],
);
