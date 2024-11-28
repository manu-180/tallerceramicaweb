import 'package:flutter/material.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: FilledButton(onPressed: () async {
        final datos = await ObtenerTotalInfo().printInfo();
        print(datos);
        
      },child: const Text("print info"),),
    );
  }
}