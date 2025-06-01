import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/bloc/delivery_map_bloc.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';
import 'package:sergio_pizza/domain/models/delivery_type.dart';

class TabsMap extends StatelessWidget {
  const TabsMap({super.key});

  @override
  Widget build(BuildContext context) {
    DeliveryMapBloc bloc = Get.find<DeliveryMapBloc>();

    // Список всех типов доставки
    final deliveryTypes = DeliveryType.values;

    return BlocBuilder<DeliveryMapBloc, DeliveryMapState>(
      bloc: bloc,
      builder: (context, state) {
        return Container(
          height: 58,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0x00000000).withValues(alpha: 0.10),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            children: deliveryTypes.map((type) {
              final isSelected = state.deliveryType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => bloc.add(SelectDeliveryType(type)),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColor.blueDark : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        type.displayName, // Используем displayName из enum
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? AppColor.white : AppColor.blueDark,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
