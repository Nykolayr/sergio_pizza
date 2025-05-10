import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sergio_pizza/presentation/screen/auth/bloc/auth_bloc.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';
import 'package:sergio_pizza/presentation/widgets/buttons.dart';

class AuthCodePage extends StatefulWidget {
  const AuthCodePage({super.key});

  @override
  State<AuthCodePage> createState() => AuthCodePageState();
}

class AuthCodePageState extends State<AuthCodePage> {
  AuthBloc bloc = Get.find<AuthBloc>();
  bool isEnable = false;
  double fieldWidth = 60;
  static const int fieldsCount = 4;
  static const double gap = 15.0;

  @override
  void initState() {
    super.initState();
    final screenWidth = WidgetsBinding.instance.window.physicalSize.width /
        WidgetsBinding.instance.window.devicePixelRatio;
    final totalGaps = gap * (fieldsCount - 1);
    fieldWidth = (screenWidth - 40 - totalGaps) / fieldsCount;
  }

  @override
  void dispose() {
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
                current.status.isSuccessCode) {
              context.go('/auth/code/reg');
            }
            return true;
          },
          builder: (context, state) {
            final isError = state.error.isNotEmpty;
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 80, bottom: 20, right: 20, left: 20),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).viewInsets.bottom -
                            160, // 160 = top + bottom padding
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                    'Введите код, отправленный в СМС на указанный номер',
                                    textAlign: TextAlign.center,
                                    style: AppText.text20sb),
                                const Gap(30),
                                RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(
                                    style: AppText.text14lb,
                                    children: [
                                      TextSpan(
                                          text:
                                              'Код отправлен в смс на номер '),
                                      TextSpan(
                                        style: AppText.text14sb,
                                        text: state.phone,
                                      ),
                                    ],
                                  ),
                                ),
                                //TODO: убрать, как только сделаем бэк
                                const Gap(20),
                                Text('Код 5555 для тестов',
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
                                    activeColor: isError
                                        ? Colors.transparent
                                        : Color(0xFFE5E5E5),
                                    selectedColor: isError
                                        ? Colors.transparent
                                        : AppColor.blueLight,
                                    inactiveColor: isError
                                        ? Colors.transparent
                                        : Color(0xFFE5E5E5),
                                    activeFillColor: Colors.white,
                                    inactiveFillColor: Colors.white,
                                    selectedFillColor: Colors.white,
                                    borderWidth: isError ? 0.1 : 1,
                                    inActiveBoxShadow: isError
                                        ? [
                                            BoxShadow(
                                              color: Color(0xFFE93F3F)
                                                  .withAlpha(
                                                      (255 * 0.15).toInt()),
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
                                  animationDuration:
                                      Duration(milliseconds: 200),
                                  enableActiveFill: true,
                                  keyboardType: TextInputType.number,
                                  // controller: codeController,
                                  onChanged: (value) {
                                    if (value.length == 4) {
                                      bloc.add(AuthCodeEvent(code: value));
                                    }
                                  },
                                ),
                                if (isError)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      state.error,
                                      style: AppText.text14lb
                                          .copyWith(color: AppColor.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                            Column(
                              children: [
                                ButtonWide(
                                  text: 'Выслать новый код',
                                  isEnable: true,
                                  onPressed: () {
                                    bloc.add(AuthCodeNewEvent());
                                  },
                                ),
                                const Gap(20),
                              ],
                            ),
                          ],
                        ),
                      ),
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
          }),
    );
  }
}
