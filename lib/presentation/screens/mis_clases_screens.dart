import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taller_ceramica/providers/auth_notifier.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class MisClasesScreen extends ConsumerStatefulWidget {
  const MisClasesScreen({super.key});

  @override
  ConsumerState<MisClasesScreen> createState() => _MisClasesScreenState();
}

class _MisClasesScreenState extends ConsumerState<MisClasesScreen> {
  List<ClaseModels> clasesDelUsuario = [];

  // Cargar clases para el usuario actual
  Future<void> cargarClasesUsuario(String fullname) async {
    final datos = await ObtenerTotalInfo().obtenerInfo();
    clasesDelUsuario = datos
        .where((clase) => clase.mails.contains(fullname))
        .toList();
    clasesDelUsuario.sort((a, b) => a.id.compareTo(b.id));
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider); // Estado inicial del usuario
    if (user != null) {
      cargarClasesUsuario(user.userMetadata?['fullname']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider); // Observa el estado del usuario
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: user == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'Para ver tus clases debes iniciar sesión!',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: color.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : clasesDelUsuario.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_busy, size: 80, color: Colors.grey),
                      const SizedBox(height: 20),
                      Text(
                        'No estás inscripto en ninguna clase',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: color.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: clasesDelUsuario.length,
                  itemBuilder: (context, index) {
                    final clase = clasesDelUsuario[index];
                    final claseInfo = '${clase.dia} ${clase.fecha} - ${clase.hora}';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
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
                              cancelarClase(
                                clase.id,
                                user.userMetadata?['fullname'],
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(166, 252, 93, 93),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 12,
                                color: color.surface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void cancelarClase(int claseId, String fullname) async {
    // Simula cancelar la inscripción en la clase
    final clase =
        clasesDelUsuario.firstWhere((clase) => clase.id == claseId);
    clase.mails.remove(fullname); // Remueve el usuario de la lista de correos
    setState(() {
      clasesDelUsuario = clasesDelUsuario
          .where((clase) => clase.mails.contains(fullname))
          .toList();
    });
    await RemoverUsuario(Supabase.instance.client).removerUsuarioDeClase(
      claseId,
      fullname,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Has cancelado tu inscripción en la clase'),
      ),
    );
  }
}
