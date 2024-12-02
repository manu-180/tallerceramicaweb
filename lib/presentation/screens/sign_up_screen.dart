import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class SignUpScreen extends StatelessWidget {

  final TextEditingController fullnamecontroller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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

                final AuthResponse res = await supabase.auth.signUp(
                    email: email,
                    password: password,
                    data: {'fullname': fullname},
                  );
                  final Session? session = res.session;
                  final User? user = res.user;
                  // context.go("/");
              },
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
