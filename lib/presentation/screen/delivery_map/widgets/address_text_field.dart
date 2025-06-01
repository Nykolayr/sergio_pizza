import 'package:flutter/material.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/bloc/delivery_map_bloc.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class AddressTextField extends StatelessWidget {
  final DeliveryMapBloc bloc;
  final DeliveryMapState state;

  const AddressTextField({
    super.key,
    required this.bloc,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    // Определяем какой адрес показывать
    final currentAddress = state.tempDeliveryAddress ?? state.detectedAddress;

    // Город всегда должен быть определен
    final currentCity =
        currentAddress?.city ?? bloc.detectedCity ?? 'Зеленоград';

    final isExpanded = state.tempDeliveryAddress != null;

    return TextField(
      controller: TextEditingController(text: currentAddress?.address ?? ''),
      keyboardType: TextInputType.streetAddress,
      readOnly: true, // TODO: Сделать редактируемым после настройки логики
      decoration: InputDecoration(
        hintText: 'Адрес доставки',
        prefixText: '$currentCity, ',
        prefixStyle: TextStyle(
          fontSize: 16,
          color: AppColor.black,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.greyLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.greyLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.blue),
        ),
      ),
      onChanged: (value) {
        // TODO: Включить обратно когда поле станет редактируемым
        /*
        // Если панель свернута - разворачиваем её
        if (!isExpanded) {
          bloc.add(const ExpandDeliveryPanel());
        }

        // Обновляем адрес
        final baseAddress = currentAddress ??
            DeliveryAddress.empty().copyWith(city: currentCity);
        final updatedAddress = baseAddress.copyWith(
          address: value,
          city: currentCity, // Принудительно сохраняем город
        );
        bloc.add(UpdateDeliveryAddress(updatedAddress));
        */
      },
    );
  }
}
