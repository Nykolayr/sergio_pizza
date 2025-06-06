import 'package:flutter/material.dart';
import 'package:sergio_pizza/presentation/screen/favorite/favorite_app_bar.dart';
import 'package:sergio_pizza/presentation/screen/favorite/favorite_page.dart';
import 'package:sergio_pizza/presentation/screen/menu/menu_app_bar.dart';
import 'package:sergio_pizza/presentation/screen/menu/menu_page.dart';
import 'package:sergio_pizza/presentation/screen/order/order_app_bar.dart';
import 'package:sergio_pizza/presentation/screen/order/order_page.dart';
import 'package:sergio_pizza/presentation/screen/profile/profile_app_bar.dart';
import 'package:sergio_pizza/presentation/screen/profile/profile_page.dart';
import 'package:sergio_pizza/presentation/screen/trash/trash_app_bar.dart';
import 'package:sergio_pizza/presentation/screen/trash/trash_page.dart';

enum MainPages {
  menu,
  favorite,
  trash,
  order,
  profile;

  String get title => switch (this) {
        menu => 'Меню',
        favorite => 'Избранное',
        trash => 'Корзина',
        order => 'Заказы',
        profile => 'Профиль',
      };

  Widget get page => switch (this) {
        menu => const MenuPage(),
        favorite => const FavoritePage(),
        trash => const TrashPage(),
        order => const OrderPage(),
        profile => const ProfilePage(),
      };

  String get icon => switch (this) {
        menu => 'assets/svg/menu.svg',
        favorite => 'assets/svg/favorite.svg',
        trash => 'assets/svg/trash.svg',
        order => 'assets/svg/order.svg',
        profile => 'assets/svg/profile.svg',
      };

  Widget get appBar => switch (this) {
        menu => const MenuAppBar(),
        favorite => const FavoriteAppBar(),
        trash => const TrashAppBar(),
        order => const OrderAppBar(),
        profile => const ProfileAppBar(),
      };
}
