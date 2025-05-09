import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sergio_pizza/presentation/screen/auth/bloc/auth_bloc.dart';
import 'package:sergio_pizza/presentation/screen/auth/widgets/bottom_auth.dart';
import 'package:sergio_pizza/presentation/screen/main/bloc/main_bloc.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  final phoneController = TextEditingController();
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
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        extendBody: true,
        bottomNavigationBar: BottomAuth(
          isEnable: true,
          onPressed: () {
            context.go('/reg');
          },
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          bloc: bloc,
          buildWhen: (previous, current) {
            if (previous.status != current.status &&
                current.status.isSuccessEnter) {
              Get.find<MainBloc>().add(GetUserEvent());
              context.go('/main');
            }

            return true;
          },
          builder: (context, state) {
            return Column(children: [TextField(controller: phoneController)]);
          },
        ),
      ),
    );
  }
}
