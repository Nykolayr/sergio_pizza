import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class DeliverTextField extends StatelessWidget {
  final String hintText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final bool numbersOnly;
  final TextInputType? keyboardType;

  const DeliverTextField({
    super.key,
    required this.hintText,
    this.initialValue,
    this.onChanged,
    this.maxLines = 1,
    this.numbersOnly = false,
    this.keyboardType,
  });

  // Конструктор для числовых полей (квартира, подъезд, этаж, домофон)
  const DeliverTextField.number({
    super.key,
    required this.hintText,
    this.initialValue,
    this.onChanged,
  })  : maxLines = 1,
        numbersOnly = true,
        keyboardType = TextInputType.number;

  // Конструктор для адреса
  const DeliverTextField.address({
    super.key,
    required this.hintText,
    this.initialValue,
    this.onChanged,
  })  : maxLines = 1,
        numbersOnly = false,
        keyboardType = TextInputType.streetAddress;

  // Конструктор для комментария
  const DeliverTextField.comment({
    super.key,
    required this.hintText,
    this.initialValue,
    this.onChanged,
  })  : maxLines = 3,
        numbersOnly = false,
        keyboardType = TextInputType.multiline;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      maxLines: maxLines,
      keyboardType: numbersOnly ? TextInputType.number : keyboardType,
      inputFormatters:
          numbersOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.greyLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.greyLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.blue),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
