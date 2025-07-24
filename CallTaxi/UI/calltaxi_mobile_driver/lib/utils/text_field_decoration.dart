import 'package:flutter/material.dart';

InputDecoration customTextFieldDecoration(
  String label, {
  IconData? prefixIcon,
}) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Color(0xFFFF6F00)),
    ),
    prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
  );
}
