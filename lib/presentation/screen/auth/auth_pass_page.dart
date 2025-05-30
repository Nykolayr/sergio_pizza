import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/presentation/screen/auth/bloc/auth_bloc.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';
import 'package:sergio_pizza/presentation/widgets/buttons.dart';
import 'package:flutter/gestures.dart';

class AuthPassPage extends StatefulWidget {
  const AuthPassPage({super.key});

  @override
  State<AuthPassPage> createState() => AuthPassPageState();
}

class AuthPassPageState extends State<AuthPassPage>
    with WidgetsBindingObserver {
  final passController = TextEditingController();

  AuthBloc bloc = Get.find<AuthBloc>();
  bool isEnable = false;
  double keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    passController.dispose();
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
              // context.goNamed('ввод кода');
            }
            return true;
          },
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      top: 80, bottom: 30, right: 20, left: 20),
                  child: Column(
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
                            child: Text('🇷🇺', style: TextStyle(fontSize: 18)),
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
                                text: 'Нажимая кнопку, вы соглашаетесь с '),
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
                              text: 'политикой обработки персональных данных',
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
              text: 'Войти',
              isEnable: isEnable,
              onPressed: () {
                FocusScope.of(context).unfocus();
                bloc.add(TryLoginEvent(phone: passController.text));
              },
            ),
          ),
        ),
      ),
    );
  }
}
