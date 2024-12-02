import 'package:flutter/material.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor; // Color del tema

    return Scaffold(
      appBar: const CustomAppBar(), // Usa el AppBar personalizado
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título grande
            Text(
              '¡Bienvenido a Taller de Cerámica Ricardo Rojas!',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Texto de bienvenida
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '¡Hola y bienvenido a nuestro taller de cerámica, un espacio donde la creatividad se mezcla con la tradición para dar forma a piezas únicas y llenas de vida!',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 20),

            // Imagen 1
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Bordes redondeados
                child: Image.asset(
                  'assets/images/creando.png',
                  height: 500,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Subtítulo
            Text(
              '¿Qué hacemos?',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),

            // Texto sobre el taller
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Aquí, en nuestro taller, creamos desde pequeñas piezas decorativas hasta grandes obras de arte, todas con un toque especial y un diseño único.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 20),

            // Imagen 2
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Bordes redondeados
                child: Image.asset(
                  'assets/images/bici.webp',
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Texto final
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Ofrecemos clases para todos los niveles, desde principiantes hasta expertos, donde podrás aprender las técnicas de modelado, esmaltado y cocción, explorando tus propias ideas y estilo.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 30),

            // Aquí va el footer que se verá solo cuando llegues al final de la página
            const SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
