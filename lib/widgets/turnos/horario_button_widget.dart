import 'package:flutter/material.dart';
import 'package:taller_ceramica/models/clase_models.dart'; // Si tienes un modelo de clase, importa aquí

class HorarioButtonWidget extends StatelessWidget {
  final ClaseModels clase; // Usando un modelo de clase
  const HorarioButtonWidget({
    Key? key,
    required this.clase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          // Acción al hacer clic, por ejemplo, mostrar detalles de la clase
          // Podrías navegar a una página o mostrar un diálogo con la información
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          '${clase.hora} - ${clase.dia}', // Muestra la hora y el lugar
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
