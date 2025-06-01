import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final VoidCallback? onTap;

  const SearchTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColor.greySearch,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Gap(12),
            Icon(
              Icons.search,
              color: AppColor.greySearch,
              size: 24,
            ),
            const Gap(8),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: AppText.text14lb.copyWith(
                    color: AppColor.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: AppText.text14lb.copyWith(
                  color: AppColor.black,
                ),
              ),
            ),
            const Gap(12),
          ],
        ),
      ),
    );
  }
}
