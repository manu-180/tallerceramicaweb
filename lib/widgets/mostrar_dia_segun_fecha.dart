
import 'package:flutter/material.dart';
import 'package:taller_ceramica/utils/dia_con_fecha.dart';

class MostrarDiaSegunFecha extends StatelessWidget {
  const MostrarDiaSegunFecha({
    super.key, 
    required this.text,
    required this.colors,
    required this.color,
    required this.cambiarFecha,
  });

  final ColorScheme colors;
  final Color color;
  final String text;
  final void Function(bool) cambiarFecha;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            boxShadow: [
              BoxShadow(
                color: colors.primaryContainer.withOpacity(0.15),
                blurRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              cambiarFecha(false);
            },
            icon: const Icon(Icons.arrow_left, size: 28),
            color: Colors.black,
          ),
        ),
        SizedBox(width: screenWidth * 0.05),
        Container(
          padding: const EdgeInsets.all(16.0),
          width: screenWidth * 0.35,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.secondaryContainer,
                colors.primary.withOpacity(0.6)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Center(
            child: Text(
              text.isEmpty ? "-" : DiaConFecha().obtenerDiaDeLaSemana(text),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.05),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              cambiarFecha(true);
            },
            icon: const Icon(Icons.arrow_right, size: 28),
            color: Colors.black, // Color del ícono (puedes personalizarlo)
          ),
        ),
      ],
    );
  }
}
