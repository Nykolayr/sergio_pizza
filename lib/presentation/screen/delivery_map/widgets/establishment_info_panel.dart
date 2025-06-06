import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sergio_pizza/domain/models/establishment.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/bloc/delivery_map_bloc.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/close_icon.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/handle.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class EstablishmentInfoPanel extends StatelessWidget {
  final Establishment establishment;

  const EstablishmentInfoPanel({
    super.key,
    required this.establishment,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = Get.find<DeliveryMapBloc>();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HandleLine(),
              CloseIcon(
                onPressed: () {
                  bloc.add(SelectEstablishment(establishment));
                },
              ),
              Row(
                children: [
                  // Расстояние
                  Text(
                    establishment.formattedDistance.isNotEmpty
                        ? establishment.formattedDistance
                        : '4.2 км',
                    style: AppText.text12sb.copyWith(color: AppColor.greyText2),
                  ),

                  const Gap(8),
                  // Тип заведения
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: establishment.isOpen
                          ? AppColor.blueDark
                          : AppColor.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      establishment.type.displayName,
                      style: AppText.text12sb.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Название заведения (используем тип + адрес)
              Text(
                '${establishment.type.displayName} ${establishment.address}',
                style: AppText.text16bold,
              ),
              const SizedBox(height: 4),

              // Адрес
              Text(
                establishment.address,
                style: AppText.text14mb.copyWith(
                  color: AppColor.grey,
                ),
              ),
              const SizedBox(height: 8),

              // Время работы
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: establishment.isOpen ? AppColor.green : AppColor.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    establishment.formattedWorkingHours,
                    style: AppText.text12sb.copyWith(
                      color:
                          establishment.isOpen ? AppColor.green : AppColor.red,
                    ),
                  ),
                ],
              ),
              const Gap(12),

              // Описание времени доставки
              if (establishment.isOpen &&
                  establishment.formattedEstimatedTime.isNotEmpty)
                Text(
                  establishment.formattedEstimatedTime,
                  style: AppText.text12mb.copyWith(
                    color: AppColor.grey,
                  ),
                ),
              const SizedBox(height: 16),

              // Кнопка действия
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: establishment.isOpen
                      ? () {
                          context.pushNamed('Общая');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: establishment.isOpen
                        ? AppColor.blueDark
                        : AppColor.yellowLight,
                    foregroundColor: establishment.isOpen
                        ? Colors.white
                        : AppColor.yellowLight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    establishment.isOpen
                        ? 'Выбрать этот ${establishment.type.displayName.toLowerCase()}'
                        : 'Уведомить, если откроется',
                    style: establishment.isOpen
                        ? AppText.text14sb.copyWith(color: Colors.white)
                        : AppText.text14sb.copyWith(color: AppColor.grey),
                  ),
                ),
              ),

              // Добавляем отступ снизу для безопасной зоны
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }
}
