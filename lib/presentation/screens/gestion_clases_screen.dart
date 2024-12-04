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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                DropdownButton<String>(
                  hint: const Text('Seleccione una fecha'),
                  value: fechaSeleccionada,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      seleccionarFecha(newValue);
                    }
                  },
                  items: fechasDisponibles.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: clasesFiltradas.length,
                    itemBuilder: (context, index) {
                      final clase = clasesFiltradas[index];
                      return ListTile(
                        title: Text('${clase.fecha} - ${clase.hora}'),
                        subtitle: Text('Lugares disponibles: ${clase.lugarDisponible}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => modificarLugarDisponible(clase.id, true),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => modificarLugarDisponible(clase.id, false),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: mostrarDialogoAgregarClase,
                  child: const Text('Agregar Clase'),
                ),
              ],
            ),
    );
  }
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

  Future<void> modificarLugarDisponible(int id, bool incrementar) async {
  try {
    if (incrementar) {
      await ModificarLugarDisponible().agregarlugarDisponible(id);
    } else {
      await ModificarLugarDisponible().removerlugarDisponible(id);
    }

    // Recargar los datos después de la modificación
    await cargarDatos();

    // Filtrar nuevamente según la fecha seleccionada
    if (fechaSeleccionada != null) {
      seleccionarFecha(fechaSeleccionada!);
    }
  } catch (e) {
    debugPrint('Error al modificar lugar disponible: $e');
  }
}

Future<void> mostrarDialogoAgregarClase() async {
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
            onPressed: () async {
              if (horaController.text.isNotEmpty && fechaSeleccionada != null) {
                final nuevaClase = ClaseModels(
                  id: await GenerarId().generarIdClase(),
                  fecha: fechaSeleccionada!,
                  hora: horaController.text,
                  dia: '',
                  semana: '',
                  mails: [],
                  lugarDisponible: 10,
                );

                try {
                  await supabase.from('usuarios').insert({
                    'id': nuevaClase.id,
                    'semana': nuevaClase.semana,
                    'dia': nuevaClase.dia,
                    'fecha': nuevaClase.fecha,
                    'hora': nuevaClase.hora,
                    'mails': nuevaClase.mails.length,
                    'lugar_disponible': nuevaClase.lugarDisponible,
                  });

                  // Recargar los datos después de agregar la clase
                  await cargarDatos();
                  if (fechaSeleccionada != null) {
                    seleccionarFecha(fechaSeleccionada!);
                  }
                } catch (e) {
                  debugPrint('Error al agregar clase: $e');
                }

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

  
  
}