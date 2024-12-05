import 'package:flutter/material.dart';
import 'package:taller_ceramica/main.dart';
import 'package:taller_ceramica/models/clase_models.dart';
import 'package:taller_ceramica/supabase/functions/generar_id.dart';
import 'package:taller_ceramica/supabase/functions/modificar_lugar_disponible.dart';
import 'package:taller_ceramica/supabase/supabase_barril.dart';
import 'package:taller_ceramica/widgets/custom_appbar.dart';

class GestionDeClasesScreen extends StatefulWidget {
  const GestionDeClasesScreen({super.key});

  @override
  State<GestionDeClasesScreen> createState() => _GestionDeClasesScreenState();
}

class _GestionDeClasesScreenState extends State<GestionDeClasesScreen> {
  List<String> fechasDisponibles = [];
  String? fechaSeleccionada;
  List<ClaseModels> clasesDisponibles = [];
  List<ClaseModels> clasesFiltradas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fechasDisponibles = generarFechasLunesAViernes();
    cargarDatos();
  }

  List<String> generarFechasLunesAViernes() {
    return [
      '02/12', '03/12', '04/12', '05/12', '06/12',
      '09/12', '10/12', '11/12', '12/12', '13/12',
      '16/12', '17/12', '18/12', '19/12', '20/12',
      '23/12', '24/12', '26/12', '27/12',
      '30/12', '31/12',
    ];
  }

  Future<void> cargarDatos() async {
    try {
      final datos = await ObtenerTotalInfo().obtenerInfo();

      final datosDiciembre = datos.where((clase) {
        final fecha = clase.fecha;
        return fecha.endsWith('/12');
      }).toList();

      setState(() {
        clasesDisponibles = datosDiciembre;
        clasesFiltradas = datosDiciembre;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error cargando datos: $e');
    }
  }

  void seleccionarFecha(String fecha) {
    setState(() {
      fechaSeleccionada = fecha;
      clasesFiltradas = clasesDisponibles.where((clase) {
        return clase.fecha == fechaSeleccionada;
      }).toList();
    });
  }

  Future<void> mostrarDialogoAgregarClase() async {
    final newid =await GenerarId().generarIdClase();
    TextEditingController horaController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Agregar nueva clase"),
          content: TextField(
            controller: horaController,
            decoration: const InputDecoration(
              hintText: 'Ingrese la hora de la clase',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (horaController.text.isNotEmpty) {
                  setState(() {
                    // Lógica para agregar una nueva clase
                    final nuevaClase = ClaseModels(
                      id: newid, // Generar ID único
                      fecha: fechaSeleccionada!,
                      hora: horaController.text,
                      dia: '', // Día asociado
                      semana: "", // Semana asociada
                      mails: [],
                      lugarDisponible: 10, // Valor predeterminado
                    );
                    supabase.from('usuarios').insert({
                        'id': newid,
                        'semana': "",
                        'dia': "",
                        'fecha': "",
                        'hora': "mujer",
                        'mails': 0,
                        'lugar_disponible': 0,
                      });
                    clasesFiltradas.add(nuevaClase);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Agregar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: fechaSeleccionada,
              hint: const Text('Selecciona una fecha'),
              onChanged: (value) {
                seleccionarFecha(value!);
              },
              items: fechasDisponibles.map((fecha) {
                return DropdownMenuItem(
                  value: fecha,
                  child: Text(fecha),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            if (isLoading) const CircularProgressIndicator(),
            if (!isLoading && fechaSeleccionada != null && clasesFiltradas.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: clasesFiltradas.length,
                  itemBuilder: (context, index) {
                    final clase = clasesFiltradas[index];
                    return Card(
                      child: ListTile(
                        title: Text('${clase.hora} - Lugares disponibles: ${clase.lugarDisponible}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                ModificarLugarDisponible().agregarlugarDisponible(clase.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                ModificarLugarDisponible().removerlugarDisponible(clase.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  clasesFiltradas.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (fechaSeleccionada != null) {
                  mostrarDialogoAgregarClase();
                }
              },
              child: const Text("Agregar nueva clase"),
            ),
          ],
        ),
      ),
    );
  }
}
