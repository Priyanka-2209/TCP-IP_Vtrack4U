import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isFocused;
  final bool isEmpty;
  final FocusNode focusNode;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool isDarkMode;
  final Function(String) onChanged;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.isFocused,
    required this.isEmpty,
    required this.focusNode,
    required this.controller,
    required this.keyboardType,
    required this.textInputAction,
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isFocused
            ? (isDarkMode
                ? Colors.grey[700]
                : Colors.white)
            : (isDarkMode
                ? Colors.grey[800]
                : const Color(0xFFF1F0F5)),
        border: !isFocused && isEmpty
            ? Border.all(width: 1, color: Colors.red)
            : Border.all(width: 1, color: const Color(0xFF123456)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.all(10),
          suffixIcon: isEmpty
              ? const Icon(
                  Icons.warning,
                  color: Colors.red,
                )
              : null,
        ),
      ),
    );
  }
}
