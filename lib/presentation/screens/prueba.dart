import 'package:flutter/material.dart';
import 'package:taller_ceramica/config/router/barril_screens.dart';
import 'package:taller_ceramica/models/usuario_models.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class Prueba extends StatelessWidget {
  const Prueba({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      floatingActionButton: FloatingActionButton(
  onPressed: () async {},
  child: const Icon(Icons.print),
),

    );
  }
}
