import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/bloc/delivery_map_bloc.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/search_text_field.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class PickupBottomPanel extends StatefulWidget {
  const PickupBottomPanel({super.key});

  @override
  State<PickupBottomPanel> createState() => _PickupBottomPanelState();
}

class _PickupBottomPanelState extends State<PickupBottomPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Слушаем изменения фокуса
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        // При получении фокуса - разворачиваем панель
        final bloc = Get.find<DeliveryMapBloc>();
        if (!bloc.state.isPanelExpanded) {
          bloc.add(const DeliverHerePressed());
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

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
          // Развернутое состояние - полный экран для поиска
          panelHeight = MediaQuery.of(context).size.height * 0.9;
        } else {
          // Свернутое состояние - компактная панель
          panelHeight = 120 + MediaQuery.of(context).padding.bottom;
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
                // Верхняя область с поиском
                Expanded(
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      // Свайп вверх - разворачиваем панель
                      if (details.delta.dy < -5 && !isExpanded) {
                        bloc.add(const DeliverHerePressed());
                      } else if (details.delta.dy > 5 && isExpanded) {
                        // Свайп вниз - сворачиваем панель
                        _searchFocusNode.unfocus(); // Убираем фокус
                        bloc.add(const ClosePanelEvent());
                      }
                    },
                    behavior: HitTestBehavior.translucent,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Поисковая строка
                          SearchTextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            hintText: 'Название или адрес ресторана',
                            onTap: () {
                              if (!isExpanded) {
                                bloc.add(const DeliverHerePressed());
                              }
                            },
                          ),

                          // Контент для развернутого состояния (пока пустой)
                          if (isExpanded) ...[
                            const Gap(24),
                            Center(
                              child: Text(
                                'Здесь будет список ресторанов',
                                style: AppText.text14lb
                                    .copyWith(color: AppColor.grey),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
