import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const MenuButton({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48), // Full-width button
        ),
        child: Text(title),
      ),
    );
  }
}
