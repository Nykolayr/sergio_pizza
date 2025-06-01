import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/bloc/delivery_map_bloc.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/close_icon.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/handle.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';
import 'package:sergio_pizza/domain/models/delivery_type.dart';
import 'package:sergio_pizza/presentation/widgets/buttons.dart';
import 'package:sergio_pizza/presentation/widgets/custom_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/address_text_field.dart';

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
        bool isExpanded = state.isPanelExpanded;

        if (isExpanded) {
          // Если есть временный адрес - максимальная высота
          panelHeight = MediaQuery.of(context).size.height * 0.9;
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
                // Крестик закрытия (показываем только когда панель развернута)

                if (isExpanded) ...[
                  const HandleLine(),
                  CloseIcon(
                    onPressed: () {
                      bloc.add(const ClearDeliveryAddress());
                    },
                  ),
                ],

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
                      if (state.isPanelExpanded) {
                        bloc.add(const SaveDeliveryAddress());
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (context.mounted) {
                            context.go('/main');
                          }
                        });
                      } else {
                        // Если панель свернута - разворачиваем панель
                        bloc.add(const DeliverHerePressed());
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
    final isExpanded = state.isPanelExpanded;

    if (!isExpanded) {
      // Свернутое состояние
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(25),
          Row(
            children: [
              Text('Ваш адрес:',
                  style: AppText.text12lb.copyWith(color: AppColor.grey)),
              const Spacer(),
              Text('Доставим в течение ${state.remainingMinutes} минут',
                  style: AppText.text14bold.copyWith(color: AppColor.blueDark)),
            ],
          ),
          const Gap(12),

          // Передаем блок и состояние как параметры
          AddressTextField(bloc: bloc, state: state),
        ],
      );
    }

    // Развернутое состояние
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Передаем блок и состояние как параметры
        AddressTextField(bloc: bloc, state: state),
        const Gap(16),
        // Ряд с номером квартиры и подъездом
        Row(
          children: [
            Expanded(
              child: DeliverTextField.number(
                hintText: 'Номер квартиры',
                initialValue: state.tempDeliveryAddress?.apartment ?? '',
                onChanged: (value) {
                  final updatedAddress =
                      state.tempDeliveryAddress!.copyWith(apartment: value);
                  bloc.add(UpdateDeliveryAddress(updatedAddress));
                },
              ),
            ),
            const Gap(16),
            Expanded(
              child: DeliverTextField.number(
                hintText: 'Подъезд',
                initialValue: state.tempDeliveryAddress?.entrance ?? '',
                onChanged: (value) {
                  final updatedAddress =
                      state.tempDeliveryAddress!.copyWith(entrance: value);
                  bloc.add(UpdateDeliveryAddress(updatedAddress));
                },
              ),
            ),
          ],
        ),

        const Gap(16),

        // Ряд с этажом и домофоном
        Row(
          children: [
            Expanded(
              child: DeliverTextField.number(
                hintText: 'Этаж',
                initialValue: state.tempDeliveryAddress?.floor ?? '',
                onChanged: (value) {
                  final updatedAddress =
                      state.tempDeliveryAddress!.copyWith(floor: value);
                  bloc.add(UpdateDeliveryAddress(updatedAddress));
                },
              ),
            ),
            const Gap(16),
            Expanded(
              child: DeliverTextField.number(
                hintText: 'Домофон',
                initialValue: state.tempDeliveryAddress?.intercom ?? '',
                onChanged: (value) {
                  final updatedAddress =
                      state.tempDeliveryAddress!.copyWith(intercom: value);
                  bloc.add(UpdateDeliveryAddress(updatedAddress));
                },
              ),
            ),
          ],
        ),

        const Gap(16),

        // Комментарий для курьера
        DeliverTextField.comment(
          hintText: 'Комментарий для курьера',
          initialValue: state.tempDeliveryAddress?.comment ?? '',
          onChanged: (value) {
            final updatedAddress =
                state.tempDeliveryAddress!.copyWith(comment: value);
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
