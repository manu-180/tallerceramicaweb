import 'package:flutter/material.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/supabase/functions/obtener_total_info.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/functions/remover_usuario.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class MisClasesScreen extends StatefulWidget {
  const MisClasesScreen({super.key});

  @override
  State<MisClasesScreen> createState() => _MisClasesScreenState();
}

class _MisClasesScreenState extends State<MisClasesScreen> {
  final String usuario = "Manuel Navarro"; // Usuario actual (temporal)
  List<ClaseModels> clasesDelUsuario = []; // Clases donde está registrado

  Future<void> cargarClasesUsuario() async {
  final datos = await ObtenerTotalInfo().obtenerInfo();

  // Filtrar las clases donde el usuario está registrado
  clasesDelUsuario = datos.where((clase) => clase.mails.contains(usuario)).toList();

  // Ordenar las clases por ID
  clasesDelUsuario.sort((a, b) => a.id.compareTo(b.id));

  // Verificar si el widget sigue montado antes de llamar a setState
  if (mounted) {
    setState(() {}); // Actualizar la UI
  }
}


  @override
  void initState() {
    super.initState();
    cargarClasesUsuario(); // Cargar las clases del usuario al iniciar
  }

  @override
  Widget build(BuildContext context) {

    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: clasesDelUsuario.isEmpty
          ? const Center(
              child: Text('No estás registrado en ninguna clase.'),
            )
          : ListView.builder(
              itemCount: clasesDelUsuario.length,
              itemBuilder: (context, index) {
                final clase = clasesDelUsuario[index];
                final claseInfo =
                    '${clase.dia} ${clase.fecha} - ${clase.hora}';

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10), // Espaciado de la lista
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        claseInfo,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Lógica para cancelar la clase (opcional)
                          cancelarClase(clase.id, "Manuel Navarro");
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(166, 252, 93, 93),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(fontSize: 12, color: color.surface),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void cancelarClase(int claseId, String user) async {
    // Simula cancelar la inscripción en la clase
    final clase = clasesDelUsuario.firstWhere((clase) => clase.id == claseId);
    clase.mails.remove(usuario); // Remueve el usuario de la lista de correos
    setState(() {
      clasesDelUsuario =
          clasesDelUsuario.where((clase) => clase.mails.contains(usuario)).toList();
    });
    RemoverUsuario(supabase).removerUsuarioDeClase(claseId, user);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Has cancelado tu inscripción en la clase')),
    );
  }
}
