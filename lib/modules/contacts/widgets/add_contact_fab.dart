import 'package:flutter/material.dart';

class AddContactFab extends StatelessWidget {
  final VoidCallback onPressed;

  const AddContactFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: const Color(0xFF25D366),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.person_add_alt_1,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}
