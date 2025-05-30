import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sergio_pizza/domain/routers/routers.dart';
import 'domain/routers/routers.dart' show router;
import 'package:yandex_mapkit/yandex_mapkit.dart' as ymap;
import 'package:yandex_geocoder/yandex_geocoder.dart' as ygeo;

// GlobalKey для доступа к контексту глобально
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sergio Pizza',
      locale: const Locale('ru', 'RU'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],
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
        return FToastBuilder()(
            context,
            MediaQuery(
              data: mq.copyWith(textScaler: fontScale),
              child: child!,
            ));
      },
    );
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

class YandexMapScreen extends StatefulWidget {
  const YandexMapScreen({super.key});

  @override
  State<YandexMapScreen> createState() => _YandexMapScreenState();
}

class _YandexMapScreenState extends State<YandexMapScreen> {
  final ygeo.YandexGeocoder geocoder =
      ygeo.YandexGeocoder(apiKey: 'b5979b78-e513-40f3-9090-4929f3d65324');
  String? address;
  ymap.Point? point;

  @override
  void initState() {
    super.initState();
    _searchAddress();
  }

  Future<void> _searchAddress() async {
    // Пример прямого геокодинга
    final response = await geocoder.getGeocode(ygeo.DirectGeocodeRequest(
      addressGeocode: 'Москва, улица Тверская, 7',
      lang: ygeo.Lang.ru,
    ));
    if (response.firstPoint != null) {
      setState(() {
        address = 'Москва, улица Тверская, 7';
        point = ymap.Point(
          latitude: response.firstPoint!.lat,
          longitude: response.firstPoint!.lon,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yandex Map')),
      body: Stack(
        children: [
          ymap.YandexMap(
            mapObjects: point != null
                ? [
                    ymap.PlacemarkMapObject(
                      mapId: const ymap.MapObjectId('placemark'),
                      point: point!,
                      icon: ymap.PlacemarkIcon.single(
                        ymap.PlacemarkIconStyle(
                          image: ymap.BitmapDescriptor.fromAssetImage(
                              'assets/svg/pickup_point.svg'),
                          scale: 2,
                        ),
                      ),
                    ),
                  ]
                : [],
            onMapCreated: (controller) {},
          ),
          if (address != null)
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Адрес: $address'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
