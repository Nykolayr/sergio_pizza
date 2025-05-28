import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class AppTextFormField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final AppTextFieldType type;

  const AppTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.type = AppTextFieldType.text,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  bool _isPasswordVisible = false;

  String? _validator(String? value) {
    switch (widget.type) {
      case AppTextFieldType.text:
        if (value == null || value.isEmpty) {
          return 'Поле обязательно для заполнения';
        }
        if (value.length < 4) {
          return 'Минимум 4 символа';
        }
        break;
      case AppTextFieldType.email:
        if (value == null || value.isEmpty) {
          return 'Email обязателен для заполнения';
        }
        if (!_isValidEmail(value)) {
          return 'Неверный формат email';
        }
        break;
      case AppTextFieldType.password:
        if (value == null || value.isEmpty) {
          return 'Пароль обязателен для заполнения';
        }
        if (value.length < 6) {
          return 'Минимум 6 символов';
        }
        break;
    }
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  TextInputType get _keyboardType {
    switch (widget.type) {
      case AppTextFieldType.text:
        return TextInputType.text;
      case AppTextFieldType.email:
        return TextInputType.emailAddress;
      case AppTextFieldType.password:
        return TextInputType.visiblePassword;
    }
  }

  String get _hintText {
    switch (widget.type) {
      case AppTextFieldType.text:
        return 'Введите текст';
      case AppTextFieldType.email:
        return 'Введите email';
      case AppTextFieldType.password:
        return 'Введите пароль';
    }
  }

  Widget? get _suffixIcon {
    if (widget.type == AppTextFieldType.password) {
      return IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: AppColor.greyText2,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(12),
        Text(
          widget.label,
          style: TextStyle(
            color: AppColor.greyText2,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextFormField(
          controller: widget.controller,
          keyboardType: _keyboardType,
          obscureText:
              widget.type == AppTextFieldType.password && !_isPasswordVisible,
          validator: _validator,
          decoration: InputDecoration(
            hintText: _hintText,
            hintStyle: TextStyle(
              color: Color(0xFFAAB2C9),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColor.greyText2,
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColor.blue,
                width: 1,
              ),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColor.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColor.red,
                width: 1,
              ),
            ),
            suffixIcon: _suffixIcon,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
          style: TextStyle(
            color: AppColor.greyText2,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

enum AppTextFieldType {
  text,
  email,
  password,
}
