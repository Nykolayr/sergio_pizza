import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sergio_pizza/presentation/screen/auth/bloc/auth_bloc.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';
import 'package:sergio_pizza/presentation/widgets/buttons.dart';
import 'dart:async';

class AuthCodePage extends StatefulWidget {
  const AuthCodePage({super.key});

  @override
  State<AuthCodePage> createState() => AuthCodePageState();
}

class AuthCodePageState extends State<AuthCodePage>
    with WidgetsBindingObserver {
  AuthBloc bloc = Get.find<AuthBloc>();
  bool isEnable = false;
  double fieldWidth = 60;
  static const int fieldsCount = 4;
  static const double gap = 15.0;
  double keyboardHeight = 0;

  // Переменные для таймера
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _canResendCode = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Запускаем таймер при входе на страницу
    _startTimer();
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

  void _calculateFieldWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalGaps = gap * (fieldsCount - 1);
    fieldWidth = (screenWidth - 40 - totalGaps) / fieldsCount;
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = 60;
      _canResendCode = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResendCode = true;
          timer.cancel();
        }
      });
    });
  }

  void _onResendCode() {
    bloc.add(SendAcceptEvent(phone: ''));
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _calculateFieldWidth(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      extendBody: true,
      body: BlocBuilder<AuthBloc, AuthState>(
          bloc: bloc,
          buildWhen: (previous, current) {
            if (previous.status != current.status &&
                current.status.isSuccessCode) {
              context.goNamed('регистрация пользователя');
            }
            // Перезапускаем таймер при успешной отправке кода
            if (previous.status != current.status &&
                current.status.isSuccessAccept) {
              _startTimer();
            }
            return true;
          },
          builder: (context, state) {
            final isError = state.error.isNotEmpty;
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      top: 80, bottom: 30, right: 20, left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Введите код, отправленный в СМС на указанный номер',
                          textAlign: TextAlign.center, style: AppText.text20sb),
                      const Gap(30),
                      RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: AppText.text14lb,
                          children: [
                            TextSpan(text: 'Код отправлен в смс на номер '),
                            TextSpan(
                              style: AppText.text14sb,
                              text: state.phone,
                            ),
                          ],
                        ),
                      ),
                      //TODO: убрать, как только сделаем бэк
                      const Gap(20),
                      Text('Код ${state.code} для тестов',
                          style: AppText.text14lb),
                      const Gap(20),
                      GestureDetector(
                        onTap: () {
                          context.pop();
                        },
                        child: Text('Изменить номер',
                            style: AppText.text14sb
                                .copyWith(color: AppColor.blueLight)),
                      ),
                      const Gap(40),
                      // Ввод кода
                      PinCodeTextField(
                        appContext: context,
                        length: fieldsCount,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(12),
                          fieldHeight: fieldWidth,
                          fieldWidth: fieldWidth,
                          activeColor:
                              isError ? Colors.transparent : Color(0xFFE5E5E5),
                          selectedColor:
                              isError ? Colors.transparent : AppColor.blueLight,
                          inactiveColor:
                              isError ? Colors.transparent : Color(0xFFE5E5E5),
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                          borderWidth: isError ? 0.1 : 1,
                          inActiveBoxShadow: isError
                              ? [
                                  BoxShadow(
                                    color: Color(0xFFE93F3F)
                                        .withAlpha((255 * 0.15).toInt()),
                                    blurRadius: 12,
                                    spreadRadius: 0,
                                    offset: Offset(0, 0),
                                  ),
                                ]
                              : [],
                        ),
                        textStyle: TextStyle(
                          color: isError ? Colors.red : Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                        cursorColor: Colors.black,
                        animationDuration: Duration(milliseconds: 200),
                        enableActiveFill: true,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          Logger.i('sendCode value >>>>> $value');
                          if (value.length == 4) {
                            bloc.add(SendCodeEvent(code: value));
                          }
                        },
                      ),
                      if (isError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            state.error,
                            style:
                                AppText.text14lb.copyWith(color: AppColor.red),
                            textAlign: TextAlign.center,
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
          }),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: EdgeInsets.only(
            bottom: keyboardHeight,
          ),
          color: Colors.white,
          child: ButtonWide(
            text: _canResendCode
                ? 'Выслать новый код'
                : 'Повторная отправка через $_remainingSeconds сек',
            isEnable: _canResendCode,
            onPressed: _canResendCode ? _onResendCode : () {},
          ),
        ),
      ),
    );
  }
}
