// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:taller_ceramica/models/usuario_models.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  bool isLoading = true;
  List<UsuarioModels> usuarios = [];

  Future<void> cargarUsuarios() async {
    setState(() {
      isLoading = true;
    });

    final datos = await ObtenerTotalInfo().obtenerInfoUsuarios();
    if (mounted) {
      setState(() {
        usuarios = datos;
        // Ordenar usuarios alfabéticamente por el nombre completo (fullname)
        usuarios.sort((a, b) => a.fullname.compareTo(b.fullname));
        isLoading = false;
      });
    }
  }

  Future<void> eliminarUsuario(int userId) async {
    await EliminarUsuario().eliminarDeBaseDatos(userId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario eliminado exitosamente')),
    );
    await cargarUsuarios();
  }

  Future<void> agregarCredito(String user) async {
    final resultado = await ModificarCredito().agregarCreditoUsuario(user);
    if (resultado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crédito agregado exitosamente')),
      );
      await cargarUsuarios();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al agregar el crédito')),
      );
    }
  }

  Future<void> removerCredito(String user) async {
    final resultado = await ModificarCredito().removerCreditoUsuario(user);
    if (resultado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crédito removido exitosamente')),
      );
      await cargarUsuarios();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al remover el crédito')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text('${usuario.fullname} '),
                      subtitle: Text(usuario.clasesDisponibles == 1
                          ? "(${usuario.clasesDisponibles} credito)"
                          : "(${usuario.clasesDisponibles} creditos)"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => eliminarUsuario(usuario.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () => agregarCredito(usuario.fullname),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.remove, color: Colors.orange),
                            onPressed: () => removerCredito(usuario.fullname),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
