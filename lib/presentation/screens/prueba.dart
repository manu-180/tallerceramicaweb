import 'package:flutter/material.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/utils/generar_fechas.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class Prueba extends StatelessWidget {
  const Prueba({super.key});

  
  


  @override
  Widget build(BuildContext context) {
    final DateTime fechaInicio = DateTime(2024, 12, 2); // 2 de diciembre de 2024
    final DateTime fechaFin = DateTime(2025, 1, 3);  
    final List<String> resultado = GenerarFechas().generarFechas(fechaInicio, fechaFin);
    



    return Scaffold(
      appBar: const CustomAppBar(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Prueba interna actualizada'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () async {
    for (final fecha in resultado.asMap().entries) {
    await supabase.from('respaldo').update({ 'fecha': fecha.value }).eq('id', fecha.key + 1);

    }
  },
  child: const Icon(Icons.print),
),

    );
  }
}
