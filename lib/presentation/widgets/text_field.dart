import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class AppTextFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? errorText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.errorText,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(12),
        Text(
          label,
          style: TextStyle(
            color: isError ? AppColor.red : AppColor.greyText2,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Color(0xFFAAB2C9),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isError ? AppColor.red : AppColor.greyText2,
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isError ? AppColor.red : AppColor.greyText2,
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
            suffixIcon: suffixIcon,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            errorText: errorText,
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
