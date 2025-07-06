import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final double size;
  final bool showBorder;

  const ProfileAvatar({
    super.key,
    this.size = 60,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: const Color(0xFF6C63FF),
                width: 3,
              )
            : null,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C63FF),
            Color(0xFF9C27B0),
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}
