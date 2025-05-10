import 'package:flutter/material.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class AppDateField extends StatelessWidget {
  final String label;
  final String? errorText;
  final TextEditingController controller;

  const AppDateField({
    super.key,
    required this.label,
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isError ? AppColor.red : AppColor.greyText2,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextFormField(
          readOnly: true,
          controller: controller,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _parseDate(controller.text) ?? DateTime(2000, 1, 1),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              controller.text = _formatDate(picked);
            }
          },
          decoration: InputDecoration(
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
            suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFAAB2C9)),
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

  DateTime? _parseDate(String value) {
    final parts = value.split('.');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]) ?? 1;
      final month = int.tryParse(parts[1]) ?? 1;
      final year = int.tryParse(parts[2]) ?? 2000;
      return DateTime(year, month, day);
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
