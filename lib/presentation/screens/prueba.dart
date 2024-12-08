import 'package:flutter/material.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class Prueba extends StatelessWidget {
  const Prueba({super.key});



  @override
  Widget build(BuildContext context) {
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
  onPressed: () async {},
  child: const Icon(Icons.print),
),

    );
  }
}
