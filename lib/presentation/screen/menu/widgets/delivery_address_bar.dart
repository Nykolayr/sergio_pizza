import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sergio_pizza/domain/models/delivery_type.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/bloc/delivery_map_bloc.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class DeliveryAddressBar extends StatelessWidget {
  const DeliveryAddressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final deliveryMapBloc = Get.find<DeliveryMapBloc>();

    return BlocBuilder<DeliveryMapBloc, DeliveryMapState>(
      bloc: deliveryMapBloc,
      builder: (context, state) {
        final user = state.user;

        // Формируем строку адреса в зависимости от типа доставки
        String addressText = '';

        if (user.deliveryType == DeliveryType.delivery) {
          // Для доставки берем deliveryAddress
          final deliveryAddress = user.deliveryAddress;
          if (deliveryAddress.isNotEmpty) {
            if (deliveryAddress.city.isNotEmpty &&
                deliveryAddress.address.isNotEmpty) {
              addressText =
                  '${deliveryAddress.city}, ${deliveryAddress.address}';
            } else if (deliveryAddress.city.isNotEmpty) {
              addressText = deliveryAddress.city;
            } else if (deliveryAddress.address.isNotEmpty) {
              addressText = deliveryAddress.address;
            }
          }

          // Если адрес пустой, показываем заглушку для доставки
          if (addressText.isEmpty) {
            addressText = 'Выберите адрес доставки';
          }
        } else {
          // Для самовывоза берем pickupAddress
          final pickupAddress = user.pickupAddress;
          if (pickupAddress.isNotEmpty) {
            addressText = pickupAddress.address;
          } else {
            addressText = 'Выберите точку самовывоза';
          }
        }

        return GestureDetector(
          onTap: () {
            context.pushNamed('карта доставки');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Иконка машинки в сером кружке
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/svg/car.svg',
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
                const Gap(12),
                // Адрес и время доставки
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              addressText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Стрелка напротив адреса
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: AppColor.blueDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.deliveryType == DeliveryType.delivery
                            ? 'Доставим в течение 45 минут'
                            : 'Заберите в удобное время',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
