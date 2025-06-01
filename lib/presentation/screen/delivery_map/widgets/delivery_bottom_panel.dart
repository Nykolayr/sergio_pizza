import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/bloc/delivery_map_bloc.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';
import 'package:sergio_pizza/domain/models/delivery_type.dart';
import 'package:sergio_pizza/domain/models/delivery_address.dart';
import 'package:sergio_pizza/presentation/widgets/buttons.dart';
import 'package:sergio_pizza/presentation/widgets/custom_text_field.dart';
import 'package:go_router/go_router.dart';

class DeliveryBottomPanel extends StatelessWidget {
  const DeliveryBottomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    DeliveryMapBloc bloc = Get.find<DeliveryMapBloc>();

    return BlocBuilder<DeliveryMapBloc, DeliveryMapState>(
      bloc: bloc,
      builder: (context, state) {
        // Определяем высоту панели
        double panelHeight;
        bool isExpanded = state.tempDeliveryAddress != null;

        if (isExpanded) {
          // Если есть временный адрес - максимальная высота
          panelHeight = MediaQuery.of(context).size.height * 0.8;
        } else {
          // Если временного адреса нет - минимальная высота
          panelHeight = 210 + MediaQuery.of(context).padding.bottom;
        }

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          bottom: 0,
          left: 0,
          right: 0,
          height: panelHeight,
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x00000000).withValues(alpha: 0.10),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Хендлер для свайпа
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColor.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Крестик закрытия (показываем только когда панель развернута)
                if (isExpanded)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        print('🔥 Крестик нажат!'); // Для отладки
                        // Сворачиваем панель - очищаем адрес
                        bloc.add(const ClearDeliveryAddress());
                        print(
                            '🔥 Событие ClearDeliveryAddress отправлено!'); // Для отладки
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 8),
                        child: Icon(
                          Icons.close,
                          color: AppColor.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                // Прокручиваемый контент
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: state.user.deliveryType == DeliveryType.delivery
                        ? _buildDeliveryContent(state, bloc)
                        : _buildPickupContent(state, bloc),
                  ),
                ),

                // Кнопка всегда внизу
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 16 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: ButtonWide(
                    text: 'Доставить сюда',
                    onPressed: () {
                      if (state.tempDeliveryAddress != null) {
                        // Если панель развернута - сохраняем и закрываем карту
                        bloc.add(const SaveDeliveryAddress());
                        Future.delayed(const Duration(milliseconds: 100), () {
                          context.go('/main');
                        });
                      } else {
                        // Если панель свернута - разворачиваем панель
                        final addressToExpand = state.detectedAddress ??
                            DeliveryAddress.empty().copyWith(
                              city: 'Зеленоград',
                            );
                        bloc.add(UpdateDeliveryAddress(addressToExpand));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeliveryContent(DeliveryMapState state, DeliveryMapBloc bloc) {
    // Определяем какой адрес показывать
    final currentAddress = state.tempDeliveryAddress ??
        state.detectedAddress ??
        state.user.deliveryAddress;

    final isExpanded = state.tempDeliveryAddress != null;

    if (!isExpanded) {
      // Свернутое состояние - показываем адрес с префиксом города
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Ваш адрес:',
                  style: TextStyle(fontSize: 14, color: AppColor.grey)),
              const Spacer(),
              Text('Доставим в течение 50 минут',
                  style: TextStyle(fontSize: 12, color: AppColor.blue)),
            ],
          ),
          const SizedBox(height: 12),

          // Адрес с префиксом города
          DeliverTextField.addressWithCity(
            hintText: 'Адрес доставки',
            prefixText: currentAddress?.city ?? 'Зеленоград',
            initialValue: currentAddress?.address ?? '',
            onChanged: (value) {
              final baseAddress = currentAddress ??
                  DeliveryAddress.empty().copyWith(
                    city: state.detectedAddress?.city ?? 'Зеленоград',
                  );
              final updatedAddress = baseAddress.copyWith(address: value);
              bloc.add(UpdateDeliveryAddress(updatedAddress));
            },
          ),
        ],
      );
    }

    // Развернутое состояние - все поля
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Адрес с префиксом города
        DeliverTextField.addressWithCity(
          hintText: 'Адрес доставки',
          prefixText: currentAddress?.city ?? 'Зеленоград',
          initialValue: currentAddress?.address ?? '',
          onChanged: (value) {
            final updatedAddress = currentAddress!.copyWith(address: value);
            bloc.add(UpdateDeliveryAddress(updatedAddress));
          },
        ),

        const SizedBox(height: 16),

        // Ряд с номером квартиры и подъездом
        Row(
          children: [
            Expanded(
              child: DeliverTextField.number(
                hintText: 'Номер квартиры',
                initialValue: currentAddress?.apartment ?? '',
                onChanged: (value) {
                  final updatedAddress =
                      currentAddress!.copyWith(apartment: value);
                  bloc.add(UpdateDeliveryAddress(updatedAddress));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DeliverTextField.number(
                hintText: 'Подъезд',
                initialValue: currentAddress?.entrance ?? '',
                onChanged: (value) {
                  final updatedAddress =
                      currentAddress!.copyWith(entrance: value);
                  bloc.add(UpdateDeliveryAddress(updatedAddress));
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Ряд с этажом и домофоном
        Row(
          children: [
            Expanded(
              child: DeliverTextField.number(
                hintText: 'Этаж',
                initialValue: currentAddress?.floor ?? '',
                onChanged: (value) {
                  final updatedAddress = currentAddress!.copyWith(floor: value);
                  bloc.add(UpdateDeliveryAddress(updatedAddress));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DeliverTextField.number(
                hintText: 'Домофон',
                initialValue: currentAddress?.intercom ?? '',
                onChanged: (value) {
                  final updatedAddress =
                      currentAddress!.copyWith(intercom: value);
                  bloc.add(UpdateDeliveryAddress(updatedAddress));
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Комментарий для курьера
        DeliverTextField.comment(
          hintText: 'Комментарий для курьера',
          initialValue: currentAddress?.comment ?? '',
          onChanged: (value) {
            final updatedAddress = currentAddress!.copyWith(comment: value);
            bloc.add(UpdateDeliveryAddress(updatedAddress));
          },
        ),
      ],
    );
  }

  Widget _buildPickupContent(DeliveryMapState state, DeliveryMapBloc bloc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            'Выберите точку самовывоза',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColor.black,
            ),
          ),
          // Здесь будет список точек самовывоза
        ],
      ),
    );
  }
}
