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

class UserRegPage extends StatefulWidget {
  const UserRegPage({super.key});

  @override
  State<UserRegPage> createState() => UserRegPageState();
}

class UserRegPageState extends State<UserRegPage> with WidgetsBindingObserver {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final birthDateController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  AuthBloc bloc = Get.find<AuthBloc>();
  bool isEnable = false;
  double keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    passwordController.addListener(validateForm);
    confirmPasswordController.addListener(validateForm);
    nameController.addListener(validateForm);
    emailController.addListener(validateForm);
    birthDateController.addListener(validateForm);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding
        .instance.platformDispatcher.views.first.viewInsets.bottom;
    setState(() {
      keyboardHeight = bottomInset /
          WidgetsBinding
              .instance.platformDispatcher.views.first.devicePixelRatio;
    });
  }

  void validateForm() {
    setState(() {
      isEnable = passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          birthDateController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    emailController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: BlocBuilder<AuthBloc, AuthState>(
          bloc: bloc,
          buildWhen: (previous, current) {
            if (previous.status != current.status &&
                current.status.isSuccessRegister) {
              context.goNamed('карта доставки');
            }
            return true;
          },
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      top: 80, bottom: 30, right: 20, left: 20),
                  child: Form(
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
                          controller: nameController,
                          type: AppTextFieldType.text,
                        ),
                        AppTextFormField(
                          label: 'Email',
                          controller: emailController,
                          type: AppTextFieldType.email,
                        ),
                        AppDateField(
                          label: 'Дата рождения',
                          controller: birthDateController,
                          errorText: null,
                        ),
                        AppTextFormField(
                          label: 'Пароль',
                          controller: passwordController,
                          type: AppTextFieldType.password,
                        ),
                        const Gap(20),
                        AppTextFormField(
                          label: 'Подтвердите пароль',
                          controller: confirmPasswordController,
                          type: AppTextFieldType.password,
                        ),
                        const Gap(20),
                        if (state.error.isNotEmpty)
                          Text(state.error,
                              style: AppText.text12lb
                                  .copyWith(color: AppColor.red)),
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
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: EdgeInsets.only(
              bottom: keyboardHeight,
            ),
            color: Colors.white,
            child: ButtonWide(
              text: 'Сохранить',
              isEnable: isEnable,
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (formKey.currentState?.validate() ?? false) {
                  bloc.add(RegPhoneEvent(
                    name: nameController.text,
                    birthDate: birthDateController.text,
                    password: passwordController.text,
                    confirmPassword: confirmPasswordController.text,
                    email: emailController.text,
                  ));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
