import 'package:flutter/material.dart';

class LoginScreenAnimacion extends StatefulWidget {
  const LoginScreenAnimacion({super.key});

  @override
  State<LoginScreenAnimacion> createState() => _LoginScreenAnimacionState();
}

class _LoginScreenAnimacionState extends State<LoginScreenAnimacion>
    with TickerProviderStateMixin {
  double _boxWidth = 60.0; // Ancho inicial de la caja
  final TextEditingController _emailController = TextEditingController();

  // Controladores de animación
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _barController;
  double _barWidth = 0.0; // Ancho inicial de la barra

  bool _showInput = false; // Controla la visibilidad del input
  bool _showBar = false; // Controla la visibilidad de la barra

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Duración de la animación de la barra
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fadeController.dispose();
    _barController.dispose();
    super.dispose();
  }

  void _toggleBoxWidth() {
    setState(() {
      _boxWidth = _boxWidth == 60.0 ? 300.0 : 60.0;
      _showInput = false; // Oculta el input si se vuelve a cerrar
      _showBar = false; // Oculta la barra si se cierra
      _barWidth = 0.0; // Resetea el ancho de la barra
    });

    if (_boxWidth == 300.0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _showInput = true;
        });
        _fadeController.forward(); // Inicia la animación de fade para el input
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          _showBar = true;
        });
        _barController.forward(); // Inicia la animación de la barra
        setState(() {
          _barWidth = 260.0; // Ancho final de la barra
        });
      });
    } else {
      _fadeController.reverse(); // Reversa el fade si se cierra el cuadrado
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: _toggleBoxWidth,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _boxWidth,
            height: _showInput ? 120.0 : 60.0, // Ajusta la altura para incluir el input y la barra
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_showInput)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Ingrese su email',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 14),
                        autofocus: true,
                      ),
                    ),
                  ),
                if (_showBar)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _barWidth,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
