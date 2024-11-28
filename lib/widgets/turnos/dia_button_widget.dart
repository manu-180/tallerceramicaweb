import 'package:flutter/material.dart';

class DiaButtonWidget extends StatelessWidget {
  final String diaFecha;
  final VoidCallback onPressed;

  const DiaButtonWidget({
    Key? key,
    required this.diaFecha,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(diaFecha, style: const TextStyle(fontSize: 11)),
      ),
    );
  }
}
