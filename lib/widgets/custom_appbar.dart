import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize; // Tamaño del AppBar

  const CustomAppBar({super.key}) : preferredSize = const Size.fromHeight(60.0);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isMenuOpen = false; // Estado para controlar si el menú está abierto

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
                    color: color.surface,
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
              } else if (value == '/usuarios') {
                context.go('/usuarios');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: '/turnos',
                child: Text('Turnos'),
              ),
              const PopupMenuItem(
                value: '/misclases',
                child: Text('Mis clases'),
              ),
              const PopupMenuItem(
                value: '/gestionhorarios',
                child: Text('Gestión horarios'),
              ),
              const PopupMenuItem(
                value: '/usuarios',
                child: Text('Usuarios'),
              ),
            ],
            icon: AnimatedRotation(
              turns: _isMenuOpen ? 0.5 : 0.0, // Rota el ícono cuando el menú está abierto
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.arrow_drop_down, color: color.surface),
            ),
            onOpened: () {
              setState(() {
                _isMenuOpen = true; // Menú abierto
              });
            },
            onCanceled: () {
              setState(() {
                _isMenuOpen = false; // Menú cerrado
              });
            },
            offset: const Offset(0, 45), // Ajusta la posición hacia abajo
          ),
        ],
      ),
    );
  }
}
