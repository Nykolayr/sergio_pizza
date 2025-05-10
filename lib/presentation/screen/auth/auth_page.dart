import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sergio_pizza/presentation/screen/auth/bloc/auth_bloc.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';
import 'package:sergio_pizza/presentation/widgets/buttons.dart';
import 'package:flutter/gestures.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  final phoneController = TextEditingController();
  final maskFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  AuthBloc bloc = Get.find<AuthBloc>();
  bool isEnable = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    phoneController.dispose();
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text('Укажите номер \nтелефона',
                                  textAlign: TextAlign.center,
                                  style: AppText.text20sb),
                            ),
                            const Gap(30),
                            Center(
                              child: Text('На него отправим код подтверждения',
                                  style: AppText.text14sb),
                            ),
                            const Gap(40),
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
                                      setState(() {
                                        isEnable = maskFormatter
                                                .getUnmaskedText()
                                                .length ==
                                            10;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const Gap(10),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: double.infinity,
                              height: 1,
                              color: const Color(0xFFE5E5E5),
                            ),
                            const Gap(30),
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
                                    style: TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // TODO: открыть пользовательское соглашение
                                      },
                                  ),
                                  const TextSpan(text: ' и '),
                                  TextSpan(
                                    text:
                                        'политикой обработки персональных данных',
                                    style: TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // TODO: открыть политику обработки
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            ButtonWide(
                              text: 'Отправить код',
                              isEnable: isEnable,
                              onPressed: () {
                                bloc.add(AuthPhoneEvent(
                                    phone: phoneController.text));
                              },
                            ),
                            const Gap(20),
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
      ),
    );
  }
}
