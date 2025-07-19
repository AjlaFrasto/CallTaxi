import 'dart:convert';
import 'package:flutter/material.dart';

class CustomPictureDesign extends StatelessWidget {
  final String? base64;
  final double size;
  final IconData fallbackIcon;
  final Color borderColor;
  final Color iconColor;
  final Color backgroundColor;

  const CustomPictureDesign({
    super.key,
    required this.base64,
    this.size = 140,
    this.fallbackIcon = Icons.account_circle,
    this.borderColor = Colors.orange,
    this.iconColor = Colors.orange,
    this.backgroundColor = const Color(0xFFFFF3E0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: base64 == null || base64!.isEmpty
          ? CircleAvatar(
              radius: size / 2,
              backgroundColor: backgroundColor,
              child: Icon(fallbackIcon, size: size * 0.6, color: iconColor),
            )
          : (() {
              try {
                final bytes = base64Decode(base64!);
                return CircleAvatar(
                  radius: size / 2,
                  backgroundImage: MemoryImage(bytes),
                  backgroundColor: backgroundColor,
                );
              } catch (e) {
                return CircleAvatar(
                  radius: size / 2,
                  backgroundColor: backgroundColor,
                  child: Icon(fallbackIcon, size: size * 0.6, color: iconColor),
                );
              }
            })(),
    );
  }
}
