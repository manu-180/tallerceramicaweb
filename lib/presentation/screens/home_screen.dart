import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taller'),
      ),
      body: Column(
        children: [
          FilledButton(onPressed: (){context.push("/turnos");}, child: const Text('Ir a turnos')),
          FilledButton(onPressed: (){}, child: const Text("Prueba"))
        ],
      )
    );
  }
}