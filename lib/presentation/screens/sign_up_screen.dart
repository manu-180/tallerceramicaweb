// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController fullnamecontroller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignUpScreen({super.key});

  String capitalize(String input) {
  if (input.isEmpty) return input;
  
  return input
      .split(' ') // Divide el string en palabras.
      .map((word) => word.isEmpty 
          ? word 
          : word[0].toUpperCase() + word.substring(1).toLowerCase()) // Capitaliza cada palabra.
      .join(' '); // Une las palabras con un espacio.
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: fullnamecontroller,
              decoration: const InputDecoration(
                labelText: 'Nombre y apellido',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final fullname = fullnamecontroller.text.trim();
                final email = emailController.text.trim();
                final password = passwordController.text.trim();
                try {
                  final AuthResponse res = await supabase.auth.signUp(
                    email: email,
                    password: password,
                    data: {'fullname': capitalize(fullname)},
                  );
                  await supabase.from('usuarios').insert(
                    {
                    'usuario': email, 
                    'fullname': capitalize(fullname), 
                    'user_uid': res.user?.id, 
                    'sexo': "mujer", 
                    'clases_disponibles': 0, 
                    'theme': 0, 
                    'recuperar': 0, 
                    'trigger_alert': 0,
                     "clases_canceladas" : []
                     }
                     );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Registro exitoso. Por favor, verifica tu correo.',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Opcional: Redirigir después del éxito
                  // context.go("/");
                } on AuthException catch (e) {
                  // Captura errores relacionados con la autenticación y muestra un mensaje
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error de registro: ${e.message}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  // Captura errores inesperados y muestra un mensaje genérico
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ocurrió un error inesperado. Por favor, intenta nuevamente.',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
