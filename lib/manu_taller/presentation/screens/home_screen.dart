import 'package:flutter/material.dart';
import 'package:taller_ceramica/ivanna_taller/presentation/functions_screens/box_text.dart';
import 'package:taller_ceramica/ivanna_taller/supabase/supabase_barril.dart';
import 'package:taller_ceramica/ivanna_taller/widgets/custom_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['fullname'] ?? '';
    final firstName = fullName.split(' ').first;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido a Taller de Cerámica Ricardo Rojas!',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            BoxText(
                text: user != null
                    ? "¡Hola $firstName y bienvenido/a a nuestro taller de cerámica, un espacio donde la creatividad se mezcla con la tradición para dar forma a piezas únicas y llenas de vida!"
                    : "¡Hola y bienvenido/a a nuestro taller de cerámica, un espacio donde la creatividad se mezcla con la tradición para dar forma a piezas únicas y llenas de vida!"),
            const SizedBox(height: 20),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/creando.png',
                  height: 500,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '¿Qué hacemos?',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Aquí, en nuestro taller, creamos desde pequeñas piezas decorativas hasta grandes obras de arte, todas con un toque especial y un diseño único.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/bici.webp',
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Ofrecemos clases para todos los niveles, desde principiantes hasta expertos, donde podrás aprender las técnicas de modelado, esmaltado y cocción, explorando tus propias ideas y estilo.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
