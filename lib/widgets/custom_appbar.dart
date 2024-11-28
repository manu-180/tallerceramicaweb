import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize; // Tamaño del AppBar

  const CustomAppBar({super.key})
      : preferredSize = const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: color.primary, // Color de fondo
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context.go("/"); // Navega a la ruta principal
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Taller de',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color.surface,
                  ),
                ),
                Text(
                  'Cerámica',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color.surface
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16), // Espacio entre el texto y el botón
          PopupMenuButton<String>(
            onSelected: (value) {
              // Maneja la navegación según la opción seleccionada
              if (value == '/turnos') {
                context.go('/turnos');
              } else if (value == '/misclases') {
                context.go('/misclases');
              } else if (value == '/gestionhorarios') {
                context.go('/gestionhorarios');
              } 
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: '/turnos',
                child: Text('Turnos'),
              ),
              const PopupMenuItem(
                value: '/misclases',
                child: Text('Mis clases' ,),
              ),
              const PopupMenuItem(
                value: '/gestionhorarios',
                child: Text('gestion horarios' ,),
              ),
              
            ],
            icon: Icon(Icons.more_vert, color: color.surface,), // Icono del botón desplegable
          ),
        ],
      ),
    );
  }
}
