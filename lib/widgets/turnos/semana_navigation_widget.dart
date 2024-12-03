import 'package:flutter/material.dart';

class SemanaNavigationWidget extends StatelessWidget {
  final VoidCallback onPressedBack;
  final VoidCallback onPressedForward;

  const SemanaNavigationWidget({
    super.key,
    required this.onPressedBack,
    required this.onPressedForward,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: onPressedBack,
          ),
          const Text(
            'Semana', // Puedes poner el texto de la semana actual aquí si lo deseas
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: onPressedForward,
          ),
        ],
      ),
    );
  }
}
