import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sergio_pizza/presentation/screen/auth/bloc/auth_bloc.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';
import 'package:sergio_pizza/presentation/widgets/app_date_field.dart';
import 'package:sergio_pizza/presentation/widgets/buttons.dart';
import 'package:flutter/gestures.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sergio_pizza/presentation/widgets/text_field.dart';

class AuthRegPage extends StatefulWidget {
  const AuthRegPage({super.key});

  @override
  State<AuthRegPage> createState() => AuthRegPageState();
}

class AuthRegPageState extends State<AuthRegPage> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final birthDateController = TextEditingController();
  final maskFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  AuthBloc bloc = Get.find<AuthBloc>();
  bool isEnable = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    phoneController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
    nameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    birthDateController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      isEnable = maskFormatter.getUnmaskedText().length == 10 &&
          passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty &&
          passwordController.text == confirmPasswordController.text &&
          nameController.text.length >= 4 &&
          emailController.text.isNotEmpty &&
          _isValidEmail(emailController.text) &&
          birthDateController.text.isNotEmpty;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    emailController.dispose();
    birthDateController.dispose();
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
              current.status.isSuccessEnter) {
            context.go('/auth/code');
          }
          return true;
        },
        builder: (context, state) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 80, bottom: 20, right: 20, left: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text('Регистрация',
                                  textAlign: TextAlign.center,
                                  style: AppText.text20sb),
                            ),
                            const Gap(40),
                            AppTextFormField(
                              label: 'Имя',
                              controller: nameController,
                              type: AppTextFieldType.text,
                            ),
                            AppDateField(
                              label: 'Дата рождения',
                              controller: birthDateController,
                              errorText: null,
                            ),
                            AppTextFormField(
                              label: 'Email',
                              controller: emailController,
                              type: AppTextFieldType.email,
                            ),
                            Text('Введите номер телефона',
                                style: AppText.text12lb
                                    .copyWith(color: AppColor.greyText2)),
                            const Gap(12),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text('🇷🇺',
                                      style: TextStyle(fontSize: 18)),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: phoneController,
                                    inputFormatters: [maskFormatter],
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      hintText: '+7 (___) ___-__-__',
                                      hintStyle: TextStyle(
                                        color: Color(0xFFAAB2C9),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none,
                                      isCollapsed: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    onChanged: (value) {
                                      // Валидация теперь происходит через listeners
                                    },
                                  ),
                                ),
                              ],
                            ),
                            // const Gap(10),
                            // Container(
                            //   margin: const EdgeInsets.only(top: 2),
                            //   width: double.infinity,
                            //   height: 1,
                            //   color: const Color(0xFFE5E5E5),
                            // ),
                            // const Gap(20),
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
                                      .copyWith(color: AppColor.red))
                            else
                              const Gap(10),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                style: AppText.text10grey,
                                children: [
                                  const TextSpan(
                                      text:
                                          'Нажимая кнопку, вы соглашаетесь с '),
                                  TextSpan(
                                    text: 'пользовательским соглашением',
                                    style: TextStyle(color: AppColor.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // TODO: открыть пользовательское соглашение
                                      },
                                  ),
                                  const TextSpan(text: ' и '),
                                  TextSpan(
                                    text:
                                        'политикой обработки персональных данных',
                                    style: TextStyle(color: AppColor.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // TODO: открыть политику обработки
                                      },
                                  ),
                                ],
                              ),
                            ),
                            const Gap(20),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  context.go('/auth');
                                },
                                child: Text('Уже есть аккаунт? Войти',
                                    style: AppText.text12lb
                                        .copyWith(color: AppColor.blue)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          ButtonWide(
                            text: 'Зарегистрироваться',
                            isEnable: isEnable,
                            onPressed: () {
                              if (_formKey.currentState!.validate() &&
                                  passwordController.text ==
                                      confirmPasswordController.text) {
                                bloc.add(RegPhoneEvent(
                                  phone: phoneController.text,
                                  password: passwordController.text,
                                  confirmPassword:
                                      confirmPasswordController.text,
                                  name: nameController.text,
                                  email: emailController.text,
                                  birthDate: birthDateController.text,
                                ));
                              }
                            },
                          ),
                          const Gap(40),
                        ],
                      ),
                    ]),
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
