import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sergio_pizza/presentation/screen/auth/bloc/auth_bloc.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';
import 'package:sergio_pizza/presentation/widgets/buttons.dart';
import 'package:sergio_pizza/presentation/widgets/data_field.dart';
import 'package:sergio_pizza/presentation/widgets/text_field.dart';

class AuthRegPage extends StatefulWidget {
  const AuthRegPage({super.key});

  @override
  State<AuthRegPage> createState() => AuthRegPageState();
}

class AuthRegPageState extends State<AuthRegPage> {
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dateController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  AuthBloc bloc = Get.find<AuthBloc>();
  bool isEnable = false;
  bool isKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    dateController.text = '01.01.2000';
    nameController.addListener(_checkFields);
    lastNameController.addListener(_checkFields);
    dateController.addListener(_checkFields);
  }

  void _checkFields() {
    final enable = nameController.text.trim().isNotEmpty &&
        lastNameController.text.trim().isNotEmpty &&
        dateController.text.trim().isNotEmpty;
    if (isEnable != enable) {
      setState(() {
        isEnable = enable;
      });
    }
  }

  @override
  void dispose() {
    nameController.removeListener(_checkFields);
    lastNameController.removeListener(_checkFields);
    dateController.removeListener(_checkFields);
    nameController.dispose();
    lastNameController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      extendBody: true,
      body: BlocBuilder<AuthBloc, AuthState>(
        bloc: bloc,
        buildWhen: (previous, current) {
          if (previous.status != current.status &&
              current.status.isSuccessRegister) {
            context.go('/main');
          }
          return true;
        },
        builder: (context, state) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 80, bottom: 20, right: 20, left: 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text('Один шаг до завершения регистрации',
                                  textAlign: TextAlign.center,
                                  style: AppText.text20sb),
                            ),
                            const Gap(20),
                            AppTextFormField(
                              label: 'Имя',
                              hint: 'Ваше имя',
                              controller: nameController,
                              keyboardType: TextInputType.text,
                            ),
                            AppTextFormField(
                              label: 'Фамилия',
                              hint: 'Ваша фамилия',
                              controller: lastNameController,
                              keyboardType: TextInputType.text,
                            ),
                            AppDateField(
                              label: 'Дата рождения',
                              controller: dateController,
                              errorText: null,
                            ),
                            const Gap(30),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          ButtonWide(
                            text: 'Сохранить',
                            isEnable: !isKeyboardOpen && isEnable,
                            onPressed: () {
                              bloc.add(AuthRegEvent(
                                name: nameController.text,
                                lastName: lastNameController.text,
                                birthDate: dateController.text,
                              ));
                            },
                          ),
                          const Gap(20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (state.status.isLoading)
                const Positioned.fill(
                  child: Center(
                    child: AppLoader(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
